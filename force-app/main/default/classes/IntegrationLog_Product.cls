public class IntegrationLog_Product
{
    private static Id TheStandardPricebookId;
    
    private static Id getTheStandardPricebookId()
    {
        if (TheStandardPricebookId == null) {
            //Get the Id of the Standard pricebook
            Pricebook2 stdPB = [select Id from Pricebook2 where isStandard = true LIMIT 1];
            TheStandardPricebookId = stdPB.Id;
        }
        return TheStandardPricebookId;
    }
    
    public static void processPMPRODREC(List<Integration_Log__c> IntLogsPMPRODREC, Set<Id> idsPMPRODREC){
        List<Integration_Log__c> ilsToCreate = new List<Integration_Log__c>();
        List<Integration_Log__c> ilsToUpdate = new List<Integration_Log__c>();
        Set<Id> prodIdsToUpdate = new Set<Id>();
        
        //If the Integration log record has a SFDC ID stated, then it is an update of an existing record
        for(Integration_Log__c il : IntLogsPMPRODREC){
            if(il.SFDC_Id__c == null){
                ilsToCreate.add(il);
            }else{
                ilsToUpdate.add(il);
                prodIdsToUpdate.add(il.SFDC_Id__c);
                if (il != null) {   System.debug('IntegrationLog.processPMPRODREC - il.SFDC_Id__c: ' + il.SFDC_Id__c); }        
            }
        }
        
        //If there are Products to create
        if(!ilsToCreate.isEmpty()){ doInserts(ilsToCreate); }
        
        if(!ilsToUpdate.isEmpty()){ doUpdates(ilsToUpdate, prodIdsToUpdate); }
        
    }

    private static Map<Id, Product2> getExistingProductsMap(Set<Id> prodIdsToUpdate)
    {
        Map<Id, Product2> existingProductsMap = new Map<Id, Product2>([
            select Id, Name, Description, IsAsset__c, Is_RLF_Asset__c,
                ProductCode, Product_Family_Misys__c, Product_Codes_Sun__c, 
                IsActive, Payaway__c, Business_Area__c, 
                Business_Area_Scope__c, IPR_Owner_Cognos__c, IPR_Owner_Sun__c, 
                Coral_ProdNo__c, Coral_PCID__c, Date_Coral_Update__c, 
                Family, Product_Set__c, Line_of_Business__c, 
                Acct_By_Sub__c, NS_3PP_Vendor_Name__c,NS_Item_Name__c, NS_Tax_Schedule__c, 
                NS_Item_Category__c, NS_Item_Sub_Category_1__c, NS_Item_Sub_Category_2__c, 
                NS_Cost_Centre__c, NS_Income_Account__c, NS_Deferred_Revenue_Acct__c, 
                NS_Accrued_Income_Acct__c, NS_Rev_Rec_Template__c, NS_Expense_Acct__c, 
                NS_Deferred_Expense_Acct__c, NS_Product_Dimension__c, NS_Item_Type__c, 
                NS_IPR_Item_Code__c, UPID__c, 
                NS_Item_Category_ID__c, NS_Item_Sub_Category_1_ID__c, NS_Item_Sub_Category_2_ID__c, 
                NS_Cost_Centre_ID__c, NS_Income_Account_ID__c, 
                NS_Deferred_Revenue_Acct_ID__c, NS_Accrued_Income_Acct_ID__c, NS_Rev_Rec_Template_ID__c, 
                Display_Seq_Number__c, NS_Expense_Acct_ID__c, NS_Deferred_Expense_Acct_ID__c, 
                GA__c, NS_Product_Dimension_ID__c, NS_Item_Type_ID__c, 
                NS_IPR_Item__c, NS_IPR_Item_Internal_ID__c,
                GA_Estimated_Date__c, GA_Avail_Date__c, Third_Party_Vendor_Description__c, 
                Pearl_Mastered__c, Pearl_Master_Sync_Date__c, Vendor_BSch_Trigger__c,ProdAnalysisCodes__c 
            from Product2 
            where Id in :prodIdsToUpdate]
        );
        return existingProductsMap;
    }
    
    
    private static string processSingleIL(Product2 productToUpdate, Integration_Log__c ilToUpdate)
    {
        string error = null;
        if (productToUpdate == null) {
            error = 'The product ID does not exist in SF: ' + ilToUpdate.SFDC_Id__c;
            System.debug(LoggingLevel.ERROR, 'IntegrationLog.processPMPRODREC - ' + error);
            return error;
        }
        
        try {
            if (ilToUpdate.RecordTypeId == Label.Integration_RecTypeId_PMPRODGAS) {
                loadGAInfoToProduct(productToUpdate, ilToUpdate);
            }
            else { // full product change record
                loadIntegrationLogToProduct(productToUpdate, ilToUpdate);
            }
        }
        catch (Exception e) {
            return e.getMessage() + ' at ' + e.getStackTraceString(); 
        }
        return null;
    }
    
    private static void doUpdates(Integration_Log__c[] ilsToUpdate, Set<Id> prodIdsToUpdate)
    {
        //Remove Duplicates based on External Id for sorting and SFDC Id
        ilsToUpdate = IntegrationLogUtils.removeDuplicates(ilsToUpdate);
        
        Map<Id, Product2> existingProductsMap = getExistingProductsMap(prodIdsToUpdate);
        
        List<Integration_Log__c> ilsProcessed = new List<Integration_Log__c>();
        List<Product2> productsToUpdate = new List<Product2>();
        string error;
        
        for(Integration_Log__c ilToUpdate : ilsToUpdate) {
            System.debug('IntegrationLog.processPMPRODREC ilToUpdate: ' + ilToUpdate);
            Product2 productToUpdate = existingProductsMap.get(ilToUpdate.SFDC_Id__c);
            error = processSingleIL(productToUpdate, ilToUpdate);
            if (error == null) {
                ilsProcessed.add(ilToUpdate);
                productsToUpdate.add(productToUpdate);
            }
            else { IntegrationLogUtils.setErrorOnILRecord(ilToUpdate, error); }
        }
        
        if(productsToUpdate.isEmpty()) { return; }
        try {
            Database.SaveResult[] saveResults = Database.update(productsToUpdate, false);
            
            for(Integer i = 0; i < saveResults.size(); i++) {
                Integration_Log__c intLog = ilsProcessed[i];
                
                if(saveResults[i].isSuccess()) {
                    intLog.isSuccess__c = true;
                    intLog.Status__c = 'Success';
                    intLog.SFDC_Id__c = saveResults[i].getId();
                }
                else { IntegrationLogUtils.setErrorOnILRecord(intLog, saveResults[i].getErrors()); }
            }
        }
        catch(Exception e) {
            for (Integration_Log__c intLog : ilsProcessed) { IntegrationLogUtils.setErrorOnILRecord(intLog, e.getMessage()); }
        }
    }
    
    private static void doInserts(Integration_Log__c[] ilsToCreate)
    {
        List<Product2> productsToCreate = new List<Product2>();
        
        for(Integration_Log__c ilToCreate : ilsToCreate){
            Product2 productToCreate = new Product2();
            loadIntegrationLogToProduct(productToCreate, ilToCreate);               
            productsToCreate.add(productToCreate);
        }
        
        if(productsToCreate.isEmpty()) { return; }
            
        try { 
            //Here we assume that the list of records to create is in the same order as the SaveResult records that are returned
            //Insert the new Products
            Database.SaveResult[] saveResults = Database.Insert(productsToCreate, false);
            
            List<PricebookEntry> stdPBEsToCreate = new List<PricebookEntry>();
            Map<Id,Integration_Log__c> mNewProductToIntLog = new map<Id,Integration_Log__c>();  
            
            //For each Product created
            for(Integer i = 0; i < saveResults.size(); i++){
                Integration_Log__c intLog = ilsToCreate[i];
                mNewProductToIntLog.put(saveResults[i].getId(),intLog);
                
                //If the product record was saved successfully, proceed with creating the pricebook entries
                if(saveResults[i].isSuccess()) {
                    intLog.isSuccess__c = true;
                    intLog.Status__c = 'Success';
                    
                    addPBEsForCurrencies(intLog.LongString1__c, saveResults[i].getId(), stdPBEsToCreate);
                }
                else { IntegrationLogUtils.setErrorOnILRecord(intLog, saveResults[i].getErrors()); }
            }

            insertStdPBEs(stdPBEsToCreate);
                    
            createAndInsertNonStdPBEs(stdPBEsToCreate, mNewProductToIntLog);

        }
        catch(Exception e) {
            for (Integration_Log__c intLog : ilsToCreate) { IntegrationLogUtils.setErrorOnILRecord(intLog, e.getMessage()); }
        }
    }
    
    private static void createAndInsertNonStdPBEs(List<PricebookEntry> stdPBEsToCreate, Map<Id,Integration_Log__c> mNewProductToIntLog)
    {
        List<PricebookEntry> pbesToCreate = new List<PricebookEntry>();     
        //Now loop back through the list of Standard Pricebook entries, and create the entries in the specified pricebook
        for(PricebookEntry standardPBE : stdPBEsToCreate)
        {       
            //Get the IntLog record
            Integration_Log__c thisIntLog = mNewProductToIntLog.get(standardPBE.Product2Id);
            
            PricebookEntry pbe = new PricebookEntry();
            pbe.CurrencyIsoCode = standardPBE.CurrencyISOCode;
            pbe.UnitPrice = 0;
            if(thisIntLog.NumField6__c != null)
                pbe.UseStandardPrice = Boolean.valueOf(thisIntLog.NumField6__c.intValue().format());
            pbe.Pricebook2Id = thisIntLog.GenString9__c;
            pbe.Product2Id = standardPBE.product2id;
            pbe.IsActive = true;
            pbesToCreate.add(pbe);
        }
        
        try {
            //Insert the full list of PricebookEntry records
            if(!pbesToCreate.isEmpty()){
                Database.SaveResult[] pbeSaveResults = Database.Insert(pbesToCreate, false);
            }   
        }       
        catch(Exception e){
            System.debug('XXX IntegrationLog: processPMPRODREC: Error in creating PBEs: ' + e.getMessage());
        }           
    }

    private static void insertStdPBEs(List<PricebookEntry> stdPBEsToCreate)
    {
        //Insert the full list of Standard pricebook entries
        try{
            if(!stdPBEsToCreate.isEmpty()){
                Database.SaveResult[] stdPBEsSaveResult = Database.Insert(stdPBEsToCreate,false);
            }
        }
        catch(Exception e){
            System.debug('XXX IntegrationLog: processPMPRODREC: Error in creating Standard PBEs: ' + e.getMessage());
        }
    }
    
    private static void addPBEsForCurrencies(string semicolonSeparatedCurrencies, Id productId, List<PricebookEntry> stdPBEsToCreate)
    {
        //Split the currencies and put them in a list
        List<String> lCurrencies = new List<String>();
        if(semicolonSeparatedCurrencies != null){
            lCurrencies = semicolonSeparatedCurrencies.split(';');
        }
                    
        //Create the Standard pricebook entry records, which must exist before adding to another pricebook
        for(String curr1 : lCurrencies)
        {
            PricebookEntry stdPBE = new PricebookEntry();
            stdPBE.pricebook2id = getTheStandardPricebookId();
            stdPBE.product2id = productId;
            stdPBE.unitprice = 0;
            stdPBE.isActive = true;
            stdPBE.CurrencyIsoCode = curr1;
            stdPBEsToCreate.add(stdPBE);
        }
    }
    
    private static void loadGAInfoToProduct(Product2 prod, Integration_Log__c intLog)
    {
        prod.Pearl_RecID__c = ConversionUtils.StringFieldToInt(intLog.External_Id__c);
        prod.GA__c = ConversionUtils.NumFieldToBool(intLog.NumField18__c);
        prod.GA_Estimated_Date__c = ConversionUtils.DateTimeToDate(intLog.DateField2__c);
        prod.GA_Avail_Date__c = ConversionUtils.DateTimeToDate(intLog.DateField3__c);
    }
    
    private static void loadIntegrationLogToProduct(Product2 prod, Integration_Log__c intLog)
    {
        loadGAInfoToProduct(prod, intLog);
        prod.Name = intLog.GenString1__c;
        prod.Description = intLog.GenString35__c;
        prod.ProductCode = intLog.GenString2__c;
        prod.Product_Family_Misys__c = intLog.GenString3__c;
        prod.Product_Codes_Sun__c = intLog.GenString4__c;
        prod.Business_Area__c = intLog.GenString5__c;
        prod.Business_Area_Scope__c = intLog.GenString6__c;
        prod.IPR_Owner_Cognos__c = intLog.GenString7__c;
        prod.IPR_Owner_Sun__c = intLog.GenString8__c;
        prod.Family = intLog.GenString10__c;
        prod.Product_Set__c = intLog.GenString11__c;
        prod.Line_of_Business__c = intLog.GenString12__c;
        
      //  prod.Acct_By_Sub__c = intLog.GenString13__c;
        prod.NS_3PP_Vendor_Name__c = intLog.GenString13__c;
       
      
        prod.NS_Item_Name__c = intLog.GenString14__c;
        prod.NS_Tax_Schedule__c = intLog.GenString15__c;
        
        if (intLog.GenString16__c != null) {
            string[] nsCategoryAndSubCategories = intLog.GenString16__c.split('/');
            for (integer i = 0; i < nsCategoryAndSubCategories.size(); i++) {
                if (i == 0) { prod.NS_Item_Category__c = nsCategoryAndSubCategories[i]; }
                if (i == 1) { prod.NS_Item_Sub_Category_1__c = nsCategoryAndSubCategories[i]; }
                if (i == 2) { prod.NS_Item_Sub_Category_2__c = nsCategoryAndSubCategories[i]; }
            }
        }
        prod.NS_Cost_Centre__c = intLog.GenString17__c;
        prod.NS_Income_Account__c = intLog.GenString18__c;
        prod.NS_Deferred_Revenue_Acct__c = intLog.GenString19__c;
        prod.NS_Accrued_Income_Acct__c = intLog.GenString20__c;
        prod.NS_Rev_Rec_Template__c = intLog.GenString21__c;
        prod.NS_Expense_Acct__c = intLog.GenString22__c;
        prod.NS_Deferred_Expense_Acct__c = intLog.GenString23__c;
        prod.Vendor_BSch_Trigger__c = intLog.GenString36__c;
        
         prod.NS_Revenue_Recognition_Rule_Description__c= intLog.GenString37__c;
         prod.NS_Revenue_Recognition_Forecast_Rule_Des__c= intLog.GenString38__c;
        
        
        
        prod.NS_Product_Dimension__c = intLog.GenString24__c;
        prod.NS_Item_Type__c = intLog.GenString25__c;
        prod.NS_IPR_Item_Code__c = intLog.GenString26__c;
        prod.NS_Export_To_OA__c = (intLog.GenString27__c != null && intLog.GenString27__c == 'PS Product');
    /*  if (intLog.GenString27__c == 'PS Product') {
            prod.Type__c = intLog.GenString27__c;
        }
        */
        prod.Type__c = intLog.GenString27__c;
        prod.UPID__c = intLog.GenString28__c;

        string licenceGroup = intLog.GenString29__c;
        prod.Licence_Group__c = MisysStringUtils.ConvertPearlLicenceGroup(licenceGroup);
        if (licenceGroup == null) {
            prod.Licence_Group_No_Key__c = true;
        }
        else {
            if (licenceGroup == 'ELS:K Products') { prod.Licence_Group_ELS__c = true; }
            else if (licenceGroup == 'ELS:KVAR Products') { prod.Licence_Group_ELS_KVAR__c = true; }
            else if (licenceGroup == 'GMS:GMS') { prod.Licence_Group_GMS__c = true; }
            else if (licenceGroup == 'LoanIQ:LoanIQ') { prod.Licence_Group_LoanIQ__c = true; }
            else if (licenceGroup == 'No Key:Products') { prod.Licence_Group_No_Key__c = true; }
            else if (licenceGroup == 'Sophis:Sophis') { prod.Licence_Group_Sophis__c = true; }
            else if (licenceGroup == 'Summit:Summit') { prod.Licence_Group_Summit__c = true; }
            else if (licenceGroup == 'TopOffice:Top Office') { prod.Licence_Group_TopOffice__c = true; }
            else if (licenceGroup == 'MGR:MGR') { prod.Licence_Group_MGR__c = true; }
        }
        prod.NS_IPR_Item__c = intLog.GenString30__c;
        prod.NS_Default_OpenAir_Billing_Rule__c = intLog.GenString31__c;
        prod.NS_OpenAir_Rev_Rec_Rule__c = intLog.GenString32__c;
        prod.SO_Grouping__c = intLog.GenString33__c;
        prod.NS_Opex_Capex_Name__c = intLog.GenString34__c;
        
        prod.Coral_ProdNo__c = intLog.NumField3__c;
        prod.Coral_PCID__c = intLog.NumField4__c;
        prod.Pearl_Master_Sync_Date__c = DateTime.now();
        prod.Pearl_Mastered__c = intLog.Boolean1__c;
        if(intLog.NumField1__c != null && intLog.NumField1__c.intValue().format() == '1'){
            prod.IsActive = true;
        }
        if(intLog.NumField2__c != null && intLog.NumField2__c.intValue().format() == '1'){
            prod.Payaway__c = true;
        }
        else if(intLog.NumField2__c != null && intLog.NumField2__c.intValue().format() == '0'){
            prod.Payaway__c = false;
        }
    
        if(intLog.NumField5__c != null && intLog.NumField5__c.intValue().format() == '1'){
            //prod.IsAsset__c = true; //Comment this line when the switch from ILF to RLF happens
            prod.Is_RLF_Asset__c = true; //Uncomment this line when the switch from ILF to RLF happens
        } else {
            prod.Is_RLF_Asset__c = false; 
        }
        prod.NS_Tax_Schedule_ID__c = ConversionUtils.IntToString(intLog.NumField6__c);
        prod.NS_Item_Category_ID__c = ConversionUtils.IntToString(intLog.NumField7__c);
        prod.NS_Item_Sub_Category_1_ID__c = ConversionUtils.IntToString(intLog.NumField8__c);
        prod.NS_Item_Sub_Category_2_ID__c = ConversionUtils.IntToString(intLog.NumField9__c);
        prod.NS_Cost_Centre_ID__c = ConversionUtils.IntToString(intLog.NumField10__c);
        prod.NS_Income_Account_ID__c = ConversionUtils.IntToString(intLog.NumField11__c);
        prod.NS_Deferred_Revenue_Acct_ID__c = ConversionUtils.IntToString(intLog.NumField12__c);
        prod.NS_Accrued_Income_Acct_ID__c = ConversionUtils.IntToString(intLog.NumField13__c);
        prod.NS_Rev_Rec_Template_ID__c = ConversionUtils.IntToString(intLog.NumField14__c);
        prod.Display_Seq_Number__c = ConversionUtils.IntToString(intLog.NumField15__c);
        prod.NS_Expense_Acct_ID__c = ConversionUtils.IntToString(intLog.NumField16__c);
        prod.NS_Deferred_Expense_Acct_ID__c = ConversionUtils.IntToString(intLog.NumField17__c);
        prod.NS_Product_Dimension_ID__c = ConversionUtils.IntToString(intLog.NumField19__c);
        prod.NS_Item_Type_ID__c = ConversionUtils.IntToString(intLog.NumField20__c);
        prod.NS_IPR_Split_Percentage__c = MathUtils.NVL(intLog.NumField22__c) * 100;
        prod.NS_IPR_Owner_ID__c = ConversionUtils.IntToString(intLog.NumField23__c);
        prod.NS_3PP_Vendor_ID__c = ConversionUtils.IntToString(intLog.NumField24__c);
        prod.NS_Default_Delivered__c = ConversionUtils.NumFieldToBool(intLog.NumField25__c);
        prod.NS_Default_OpenAir_Billing_Rule_Int_ID__c = ConversionUtils.IntToString(intLog.NumField26__c);
        prod.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c = ConversionUtils.IntToString(intLog.NumField27__c);
        prod.NS_Opex_Capex_ID__c = ConversionUtils.IntToString(intLog.NumField28__c);
        prod.Can_Be_Fulfilled_Delivered__c = ConversionUtils.NumFieldToBool(intLog.NumField29__c);
        
        prod.NS_Rev_Rev_Rule_ID__c = ConversionUtils.IntToString(intLog.NumField31__c);
        prod.NS_Rev_Rev_Forecast_Rule_ID__c = ConversionUtils.IntToString(intLog.NumField32__c);
        
        prod.ProdAnalysisCodes__c = intLog.LongString3__c;
        
        prod.Date_Coral_Update__c = intLog.DateField1__c;
        prod.Third_Party_Vendor_Description__c = intLog.LongString2__c;
        if(intLog.NumField30__c != null && intLog.NumField30__c.intValue().format() == '1'){
            prod.NS_Create_3PP_Event__c = true;
        } else {
            prod.NS_Create_3PP_Event__c = false;
        }
    }
    
}