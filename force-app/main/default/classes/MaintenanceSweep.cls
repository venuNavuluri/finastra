// Specs - http://almtools/confluence/display/TO/Maintenance+Sweep

public with sharing class MaintenanceSweep {

// ----------------------------------------------------------------------------------------------

/* If the argument to this function is true then it will create actual opportunities 
else it will dump the opty data in the 'MS Opportunities Validation Records' table */

/* For next Year
Reset the flags
        - Account --> MS_Opty_Created__c
        - Auto - Opportunity - MS_LI_Created__c
USD might need to be changed to Euros
Check the CA billing group and not the Account billing group
Change the field Annual_Maintenance_2017_Base__c to Annual Maintenace
*/
    public static void generateMSweepOpportunitiesCount(Boolean insertOpty) {
    List<Account> acctBaseline = new List<Account>();
    DateTime yearStartDate = DateTime.newInstance(System.Now().year() , 1, 1, 0, 0, 0);
    
    if(insertOpty) // Pick Accounts for actual opportunity insertion
         acctBaseline =  [Select Id, Name, Sales_Region__c,Site,  (select Id,name from Troy_Assets__r ca where ca.CA_Billing_Status__c='Active billing' and CA_Billing_Group__c !=null  limit 1)/*, (select Id,name from Billing_Groups__r  limit 1)*/ ,
         (select id, ForecastCategoryName, Sales_Region_FY07__c,Account.Name, Account_Site__c ,Misys_Forecast__c, Rating__c, Approval_Status__c  from Opportunities where Maintenance_Sweep_Status__c !=null and createddate >= :yearStartDate /* 2017-01-01T00:00:00.000Z */ limit 1 ) From Account  where MS_Opty_Created__c = false ]; 
     else // Pick Accounts for the preValidation table
         acctBaseline =  [Select Id, Name, Sales_Region__c,Site, (select Id,name from Troy_Assets__r ca where ca.CA_Billing_Status__c='Active billing' and CA_Billing_Group__c !=null limit 1)/*, (select Id,name from Billing_Groups__r  limit 1)*/ ,
         (select id, ForecastCategoryName, Sales_Region_FY07__c,Account.Name, Account_Site__c ,Misys_Forecast__c, Rating__c, Approval_Status__c  from Opportunities where Maintenance_Sweep_Status__c !=null and createddate >= :yearStartDate /* 2017-01-01T00:00:00.000Z */ limit 1  ) From Account  /*where MS_Opty_Created__c = false - this is commented since we can do these accoun t in one go*/ ]; 
    List<Account> msAccounts = new List<Account>();
    for (Account ac : acctBaseline )
    {
        if(ac.Troy_Assets__r.size() > 0) {
        if( ac.opportunities.size() == 0 || insertOpty == false) {
            msAccounts.add(ac);
			}
			}
    } 
	System.debug('Accounts remaining for insertOpty: ' + insertOpty + '  : ' + msAccounts.size());
	}
public static void generateMSweepOpportunities(Boolean insertOpty){

    List<Account> acctBaseline = new List<Account>();
    
    DateTime yearStartDate = DateTime.newInstance(System.Now().year() , 1, 1, 0, 0, 0);
    
    if(insertOpty) // Pick Accounts for actual opportunity insertion
         acctBaseline =  [Select Id, Name, Sales_Region__c,Site,  (select Id,name from Troy_Assets__r ca where ca.CA_Billing_Status__c='Active billing' and CA_Billing_Group__c !=null  limit 1)/*, (select Id,name from Billing_Groups__r  limit 1)*/ ,
         (select id, ForecastCategoryName, Sales_Region_FY07__c,Account.Name, Account_Site__c ,Misys_Forecast__c, Rating__c, Approval_Status__c  from Opportunities where Maintenance_Sweep_Status__c !=null and createddate >= :yearStartDate /* 2017-01-01T00:00:00.000Z */ limit 1 ) From Account  where MS_Opty_Created__c = false ]; 
     else // Pick Accounts for the preValidation table
         acctBaseline =  [Select Id, Name, Sales_Region__c,Site, (select Id,name from Troy_Assets__r ca where ca.CA_Billing_Status__c='Active billing' and CA_Billing_Group__c !=null limit 1)/*, (select Id,name from Billing_Groups__r  limit 1)*/ ,
         (select id, ForecastCategoryName, Sales_Region_FY07__c,Account.Name, Account_Site__c ,Misys_Forecast__c, Rating__c, Approval_Status__c  from Opportunities where Maintenance_Sweep_Status__c !=null and createddate >= :yearStartDate /* 2017-01-01T00:00:00.000Z */ limit 1  ) From Account  /*where MS_Opty_Created__c = false - this is commented since we can do these accoun t in one go*/ ]; 
       
    List<Account> msAccounts = new List<Account>();
  
    
    MS_Limits__c msLimit  = MS_Limits__c.getValues('MS Default Limits');
    Integer accountLimit = Integer.valueof(msLimit.Limit_Accounts_for_Opty_Creation__c);

    If(!insertOpty)
    accountLimit  = 1800;
    // Identify Accounts for which we need to create opportunites
    for (Account ac : acctBaseline )
    {
        if(ac.Troy_Assets__r.size() > 0 /*&& ac.Billing_Groups__r.size() > 0 remove the Billing group check on account*/ && msAccounts.size()<accountLimit)
        if( ac.opportunities.size() == 0 || insertOpty == false)
            msAccounts.add(ac);
    } 
 
    // Create the Maintenance Sweep Opportunities
    List<Opportunity> msOpps = new List<Opportunity>();
    for (Account acc:msAccounts)
    {
        Opportunity msOpty =  createOpportunity(acc);
        msOpps.add(msOpty);
   
        acc.MS_Opty_Created__c = true;
    }
   //update this in one transaction
    if(msOpps.size()>0 && insertOpty)
       insert msOpps;
    if(msAccounts.size()>0 && insertOpty)
       update msAccounts;
   
    if(!insertOpty)
       insertOptyinValidationtable(msOpps);

}

private static void insertOptyinValidationtable(Opportunity[] msOpps)
{

    List<MS_Opportunities_Validation_Records__c> msOptyValidationList = new List<MS_Opportunities_Validation_Records__c>();

    for(Opportunity opp:msOpps)
    {
        MS_Opportunities_Validation_Records__c msOptyValidation = new MS_Opportunities_Validation_Records__c();
        msOptyValidation.Account_Site__c = opp.Account_Site__c;
        msOptyValidation.Account__c = opp.AccountId;
        msOptyValidation.CloseDate__c = opp.CloseDate;
        msOptyValidation.CurrencyIsoCode__c = opp.CurrencyIsoCode;
        msOptyValidation.ForecastCategoryName__c = opp.ForecastCategoryName;
        msOptyValidation.Misys_Forecast__c = opp.Misys_Forecast__c;
        msOptyValidation.Rating__c = opp.Rating__c;
        msOptyValidation.Sales_Region_FY07__c = opp.Sales_Region_FY07__c;
        msOptyValidation.StageName__c = opp.StageName;
        msOptyValidation.Rollup_Calculate_Batch_Hold__c = true;
        msOptyValidation.RecordTypeId__c = '01220000000UYrGAAW'; //  [Select Id from RecordType where Name = 'Maintenance Renewal' and  SobjectType = 'Opportunity' limit 1].Id
        msOptyValidation.opty_name__c = opp.Name;
        msOptyValidation.Maintenance_Sweep_Status__c = 'Auto Created';
        msOptyValidation.OwnerId = '00520000000hYH6'; //Pat Jones
        
        msOptyValidationList.add(msOptyValidation);
  
    }
    
    if(msOptyValidationList.size()>0)
        insert msOptyValidationList;
}

/* If the argument to this function is true then it will create actual opportunity Line Items 
else it will dump the opty data in the 'MS Opportunities LI Validation Records' table */

    private static void insertOptyLineItemsinValidationtable(OpportunityLineItem[] msOppLIs)
     {
    
        List<MS_Opportunities_LI_Validation_Record__c> msOptyLIValidationList = new List<MS_Opportunities_LI_Validation_Record__c>();
        Set<ID> priceBookEntryId = new Set<ID>();
        for (OpportunityLineItem oli:msOppLIs)
        {
            priceBookEntryId.add(oli.PricebookEntryId);
        }
    
        map<ID,PricebookEntry> priceBookentryMaptoProduct = new map<Id,PricebookEntry>([SELECT Product2Id FROM PricebookEntry where id in :priceBookEntryId]);
    
        for(OpportunityLineItem oppLI: msOppLIs)
        {
            MS_Opportunities_LI_Validation_Record__c msOptyLIValidation = new MS_Opportunities_LI_Validation_Record__c();
       
            msOptyLIValidation.Add_to_Standard_Increase_Amount__c = oppLI.Add_to_Standard_Increase_Amount__c;
            msOptyLIValidation.Contract_Asset__c = oppLI.Contract_Asset__c;
            msOptyLIValidation.Description__c = oppLI.Description;
            msOptyLIValidation.Misys_Standard_Rate_for_Contract_Asset__c = oppLI.Misys_Standard_Rate_for_Contract_Asset__c;
            msOptyLIValidation.Opportunity__c = oppLI.OpportunityId;
            msOptyLIValidation.Quantity__c = oppLI.Quantity;
            msOptyLIValidation.TotalPrice__c = oppLI.TotalPrice;
            msOptyLIValidation.PricebookEntryId__c = oppLI.PricebookEntryId;
            msOptyLIValidation.OwnerId = '00520000000hYH6'; // Pat Jones
            if(priceBookentryMaptoProduct.get(oppLI.PricebookEntryId)!=null){
                msOptyLIValidation.product__c = (priceBookentryMaptoProduct.get(oppLI.PricebookEntryId)).Product2Id;
            }
            
            msOptyLIValidation.MS_New_Uplift_Amount__c = oppLI.MS_New_Uplift_Amount__c;
            
            msOptyLIValidationList.add(msOptyLIValidation);
        }
        
        if(msOptyLIValidationList.size()>0)
           insert msOptyLIValidationList;
  }

     public static void generateMSweepOpportunitiesLineItems(Boolean insertOptyLineItems)
       {
            // Get the Account with MS Optys
            List<Account> acctBaseline = new List<Account>();
            List<Account> msAccounts = new List<Account>();
            DateTime yearStartDate = DateTime.newInstance(System.Now().year() , 1, 1, 0, 0, 0);
            
            if(insertOptyLineItems)
              {
                acctBaseline = [Select /*OFL*/ Id, Name, (select id from Opportunities where Maintenance_Sweep_Status__c !=null  and createddate >= :yearStartDate /*2017-01-01T00:00:00.000Z*/ /*and creation date is greater than last year MS opty creation date*/ limit 1 ) From Account where   MS_Opty_LI_Created__c = false  ]; 
              }
            else 
              {
                acctBaseline = [Select /*OFL*/ Id, Name, MS_OLI_Validation_Record__c, (select id from Opportunities where Maintenance_Sweep_Status__c !=null and createddate >= :yearStartDate /*2017-01-01T00:00:00.000Z*/  limit 1 ) From Account where   MS_OLI_Validation_Record__c = false  ]; 
              }
         
             // Identify Accounts for which we need to create opportunites linie items
             for (Account ac : acctBaseline )
             {
                if( ac.opportunities.size() > 0)
                msAccounts.add(ac);
             } 
    
            // Get the Account and all the CA and generate opty line items  
            // Add opportunity LINE ITEM related fields here
            // LIMIT Accounts for OLI generation here
            List<Account> msAccountWithCA =  new List<Account>();
            MS_Limits__c msLimit  = MS_Limits__c.getValues('MS Default Limits');
            Integer Limit_Accounts_for_Actual_OLI = Integer.valueof(msLimit.Limit_Accounts_for_Actual_OLI__c);
            Integer Limit_Accounts_for_Dump_OLI = Integer.valueof(msLimit.Limit_Accounts_for_Dump_OLI__c);
            
           // DateTime yearStartDate = DateTime.newInstance(System.Now().year() , 1, 1, 0, 0, 0);
    
            if(insertOptyLineItems)
              msAccountWithCA =  [Select /*OFL*/ Id, Name,  (select Id,name,Product__r.Name,CA_Recurring_Fees_Index__r.Name,CA_Recurring_Fees_percent__c, CA_Recurring_Fees_Index_Type__c,CA_RF_Index_Rate__c,CA_Recurring_Fees_Rate_Increase_Min__c,CA_Recurring_Fees_Rate_Increase_Max__c, CA_Recurring_Fees_Earliest_Review_Date__c,CA_Recurring_Fees_Review_Month__c,CA_Uplift_Final_for_Change_Order__c,convertcurrency(Annual_Maintenance_2017_Base__c),MS_New_Uplift_Amount__c from Troy_Assets__r ca where ca.CA_Billing_Status__c='Active billing' ),
              (select id,CurrencyIsoCode, Maintenance_Sweep_Status__c, CloseDate, MS_LI_Created__c,Rating__c from Opportunities where Maintenance_Sweep_Status__c !=null and MS_LI_Created__c = false and createddate >= :yearStartDate /*2017-01-01T00:00:00.000Z*/ limit 1 )
              From Account where id in :msAccounts and MS_Opty_LI_Created__c = false  limit :Limit_Accounts_for_Actual_OLI/*limit 5 use this as a param*/];
            else {
               msAccountWithCA =  [Select /*OFL*/ Id, Name,  (select Id,name,Product__r.Name,CA_Recurring_Fees_Index__r.Name,CA_Recurring_Fees_percent__c, CA_Recurring_Fees_Index_Type__c,CA_RF_Index_Rate__c,CA_Recurring_Fees_Rate_Increase_Min__c,CA_Recurring_Fees_Rate_Increase_Max__c, CA_Recurring_Fees_Earliest_Review_Date__c,CA_Recurring_Fees_Review_Month__c,CA_Uplift_Final_for_Change_Order__c,convertcurrency(Annual_Maintenance_2017_Base__c),MS_New_Uplift_Amount__c from Troy_Assets__r ca where ca.CA_Billing_Status__c='Active billing' ),
               (select id,CurrencyIsoCode, Maintenance_Sweep_Status__c, CloseDate, MS_LI_Created__c,Rating__c from Opportunities where Maintenance_Sweep_Status__c !=null and createddate >= :yearStartDate /*2017-01-01T00:00:00.000Z*/ limit 1 )
               From Account where id in :msAccounts and MS_OLI_Validation_Record__c = false limit :Limit_Accounts_for_Dump_OLI];
              }
              
             //---- Pick products upfront
             Legacy_Product_Mapping__c[] lpm = [select /*OFL*/ Id,Current_Product__c, Legacy_Product__c from Legacy_Product_Mapping__c ];
             Set<String> productName = new Set<String>();
             Set<String> productIDSet = new Set<String>();
             for(Legacy_Product_Mapping__c pn: lpm) // review
                productName.add(pn.Current_Product__c);

             for (Account acc:msAccountWithCA)
              {
                for(Contract_Asset__c ca: acc.Troy_Assets__r)
                 {
                    String productName_Replace = ca.Product__r.Name;
                    productIDSet.add(ca.Product__r.Id);
                    if(productName_Replace !=null)
                    productName_Replace = productName_Replace .replace(': Legacy Billing Summary', ': RLF/Maintenance/Subscription Summary');
                    productName.add(productName_Replace);
                 }
              }
            PricebookEntry[] pbItem = [SELECT /*OFL*/ id, name, Pricebook2Id,Product2Id,IsActive,CurrencyIsoCode,Product2.Family, Product2.CanUseRevenueSchedule FROM PricebookEntry where name in :productName and pricebook2Id = '01s20000000Q0FF' and IsActive=true and CurrencyIsoCode = 'USD' and Product2.Family Like '%RLF%' ]; 
            PricebookEntry[] pbItemBasedonID = [SELECT /*OFL*/ id, name, Pricebook2Id,Product2Id,IsActive,CurrencyIsoCode,Product2.Family, Product2.CanUseRevenueSchedule FROM PricebookEntry where Product2Id in :productIDSet and pricebook2Id = '01s20000000Q0FF' and IsActive=true and CurrencyIsoCode = 'USD'  ]; 

      
            // create OLI for msAccountWithCA
            List<OpportunityLineItem> msOLIs = new List<OpportunityLineItem>();
            List<Opportunity> optyToUpdate = new List<Opportunity>();
            List<Contract_Asset__c> CAtoUpdate = new List<Contract_Asset__c>();
            
            OpportunityLineItem currentOLI;
            
            for (Account acc:msAccountWithCA)
             {
             if(acc.opportunities.size()> 0)
              {
                Contract_Asset__c[] contractAssetList = acc.Troy_Assets__r;
                Opportunity msOp = acc.opportunities[0];
                
                for( Contract_Asset__c ca :contractAssetList)
                {
                    currentOLI = createOpportunityLineItem(msOp,ca,pbItem,pbItemBasedonID,lpm);
                    msOLIs.add(currentOLI);
                    ca.MS_New_Uplift_Amount__c = currentOLI.MS_New_Uplift_Amount__c;
                    CAtoUpdate.add(ca);
                }
                // flag to say LI generated
                msOp.MS_LI_Created__c = true;
                // update msOp;
                optyToUpdate.add(msOp);
             }
             if(insertOptyLineItems)
               acc.MS_Opty_LI_Created__c = true;
             else
               acc.MS_OLI_Validation_Record__c = true;
           }
            //update this in one transaction (validation + account and oli + accounts)
        if(msOLIs.size() > 0 && insertOptyLineItems)
           insert msOLIs;
        if(optyToUpdate.size()>0 && insertOptyLineItems)
           update optyToUpdate;
        if(msAccountWithCA.size()>0 && insertOptyLineItems)
           update msAccountWithCA;
           
       // there is an addtional requirement from Vista to update the contract asset value based on the MS OLI calculation    
         Set<ID> catoUpdateIDs = new Set<ID>();
         
         for(Contract_Asset__c ca: CAtoUpdate)
           {
            catoUpdateIDs.add(ca.Id);
           }
           
           /* Currency Conversion */
           list<CurrencyType> coversionRates = [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE];
           
           // the orginal contract asset query coverts the Asset Value to user currency (for subsequent calcuations) so we need addtional query to update the 'updated asset value' otherwise the orginal annual maintenance field might be update with wrong (converted currency value)
           Map<id,Contract_Asset__c> catoUpdate1 = new Map<id,Contract_Asset__c>([Select Id, MS_New_Uplift_Amount__c,CurrencyIsoCode,Updated_Asset_Value__c from Contract_Asset__c where id in :catoUpdateIDs]);
           
           Contract_Asset__c ca1; 
           for(Contract_Asset__c ca: CAtoUpdate)
            {
             ca1 = catoUpdate1.get(ca.id);
             ca1.MS_New_Uplift_Amount__c = ca.MS_New_Uplift_Amount__c;
             if(!ca1.CurrencyIsoCode.equalsIgnoreCase('USD'))
             ca1.Updated_Asset_Value__c = covertCurrency(coversionRates, (Double)ca.MS_New_Uplift_Amount__c, ca1.CurrencyIsoCode );
             else
             ca1.Updated_Asset_Value__c = ca.MS_New_Uplift_Amount__c; 
            }
                  
         // this is to record the updated asset value on contract asset
        if(CAtoUpdate.size()>0 && insertOptyLineItems)
           update catoUpdate1.values();
           
        //----------------- Below is to update the validation tables i.e. it would intest opty or OLI records   
        
        if(msOLIs.size()>0 && !insertOptyLineItems)
           insertOptyLineItemsinValidationtable(msOLIs);
           
        // this is to update the Maintenance Sweep related flags on Account
        if(acctBaseline.size()>0 && !insertOptyLineItems)
           update msAccountWithCA;
      
        /*System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('2.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
        System.debug('3. Number of script statements used so far : ' + Limits.getDmlStatements());
        System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('5.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());*/
      }                                     

public static Double covertCurrency(list<CurrencyType> coversionRates, Double usdAmount, String currencyIsoCode )
{
    
    for(CurrencyType c: coversionRates)
    {
        if(c.ISOCode.equalsIgnoreCase(currencyIsoCode))
            return usdAmount * c.ConversionRate;
    }
    return 0; // as such this should never be the case since the record exist in the given currency

}
public static OpportunityLineItem createOpportunityLineItem(Opportunity o, Contract_Asset__c ca, PricebookEntry[] pbItem, PricebookEntry[] pbItembasedonID, Legacy_Product_Mapping__c[] lpm){
        //PricebookEntry pbItem = [select Id from PricebookEntry where IsActive=true and CurrencyIsoCode=:o.CurrencyIsoCode and Product2.CanUseRevenueSchedule=true and Product2.Family=:productFamily LIMIT 1]; 
        
        /*String productName = ca.Product__r.Name;
        Legacy_Product_Mapping__c[] lpm = [select  Current_Product__c from Legacy_Product_Mapping__c where Legacy_Product__c = :productName limit 1];

        if (lpm.size()>0)
        productName = lpm[0].Current_Product__c;
        
        productName = productName.replace(': Legacy Billing Summary', ': RLF/Maintenance/Subscription Summary');
        
        // we need to push this query up so that its not in a for loop
        PricebookEntry[] pbItem = [SELECT id, name, Pricebook2Id,Product2Id,IsActive,CurrencyIsoCode,Product2.Family, Product2.CanUseRevenueSchedule FROM PricebookEntry where name = :productName and pricebook2Id = '01s20000000Q0FF' and IsActive=true and CurrencyIsoCode = 'USD' and Product2.Family Like '%RLF%' limit 1]; 
        */
        
        
        //Determine the uplift / rate to be applied
        Decimal renewalRate = 0 ;
        
        if(ca.CA_Recurring_Fees_Index_Type__c!=null && ca.CA_Recurring_Fees_Index_Type__c.equalsIgnoreCase('fix'))
        renewalRate = ca.CA_Uplift_Final_for_Change_Order__c;
        else
        renewalRate = 0;

        OpportunityLineItem rec = new OpportunityLineItem();
        
        ID PricebookEntryId;
        String productName = ca.Product__r.Name;
        String productID = ca.Product__r.Id;
        //****** Start - get the productId - the query happened outside the for loop
        for (Legacy_Product_Mapping__c lpe: lpm)
        {
            if(lpe.Legacy_Product__c == productName)
            productName = lpe.Current_Product__c;
        }
        if(productName!=null)
        productName = productName.replace(': Legacy Billing Summary', ': RLF/Maintenance/Subscription Summary');
        
        // check based on the product id firt
          for (PricebookEntry pbe: pbItembasedonID)
        {
            
            if( pbe.Product2Id == productID)
              PricebookEntryId = pbe.id;
            
        }
        
        // check based on the name afterward - we need to do this because the name legacy billing summary has to be replaced by RLF/Maintenance.. in a number of cases
       if(PricebookEntryId==null ){
        for (PricebookEntry pbe: pbItem)
        {
            if(pbe.name == productName) 
               PricebookEntryId = pbe.id;
            
          //  if(PricebookEntryId==null && pbe.Product2Id == productID)
            //  PricebookEntryId = pbe.id;
            
        }
        
       }
        
       
        //****** END  - get the productId

        String defaultProductAssigned = '';
        //** - Product ID Assignment
        if(PricebookEntryId!=null)
        rec.PricebookEntryId = PricebookEntryId;
        else
        {
        rec.PricebookEntryId = '01u2000000Nn4kSAAR'; // *********** Need to Decide about a default product*/
        defaultProductAssigned = 'Default product assigned,,,;';
        }
        
        
        Decimal totalLIPrice = 0;
        If (ca.Annual_Maintenance_2017_Base__c!=null) // need to convert the amount to USD - auto converted based on user currency
        totalLIPrice = ca.Annual_Maintenance_2017_Base__c;
        
        // get the HML rating from opportunity and apply the rate accordingly
        Decimal CA_RF_Standard_Increase_to_be_applied = 0.00;
        If(o.Rating__c == 'High')
        CA_RF_Standard_Increase_to_be_applied = Decimal.valueOf(Label.Opportunity_High);
        else if (o.Rating__c == 'Medium')
        CA_RF_Standard_Increase_to_be_applied = Decimal.valueOf(Label.Opportunity_Medium);
        else if (o.Rating__c == 'Low')
        CA_RF_Standard_Increase_to_be_applied = Decimal.valueOf(Label.Opportunity_Low);
        
        
        //https://emea.salesforce.com/setup/cur/currencylist.jsp
        // https://emea.salesforce.com/_ui/system/organization/AdvancedCurrencyManagement - we used the default converter in the query
        Decimal reviewCycleLength = getReviewCycleLength(ca);
        Decimal inRate = getVariableRate(ca,CA_RF_Standard_Increase_to_be_applied);
       // System.Debug('CA Id: ' + ca.Id);
        rec.OpportunityId = o.Id;
        rec.Quantity = 1;
        rec.TotalPrice = (totalLIPrice*reviewCycleLength*inRate)/100;
        //rec.Product2Id = ca.Product__c;
        If (ca.Annual_Maintenance_2017_Base__c!=null) 
        rec.MS_New_Uplift_Amount__c = ca.Annual_Maintenance_2017_Base__c + rec.TotalPrice;
        else 
        rec.MS_New_Uplift_Amount__c = 0;
       
        //Formatter - May be create another function for this - Increase terms = Misys Standard Rate,,,,; rate used for amt calc is 5%
        String rateString= '';
        
        if(ca.CA_Recurring_Fees_Index__r.Name!=null)
        rateString+=ca.CA_Recurring_Fees_Index__r.Name +',';
        else
            rateString+=',';
        
        If (ca.CA_Recurring_Fees_percent__c!=null)
            rateString+=ca.CA_Recurring_Fees_percent__c +',';
        else
            rateString+=',';
        
        If (ca.CA_Recurring_Fees_Index_Type__c!=null)
            rateString+=ca.CA_Recurring_Fees_Index_Type__c +',';
        else
            rateString+=',';
        
        If (ca.CA_Recurring_Fees_Rate_Increase_Min__c!=null)
            rateString+=ca.CA_Recurring_Fees_Rate_Increase_Min__c +',';
        else
           rateString+=',';
        
        If (ca.CA_Recurring_Fees_Rate_Increase_Max__c!=null)
            rateString+=ca.CA_Recurring_Fees_Rate_Increase_Max__c+',' ;
        else
            rateString+=',';

        If (ca.CA_Recurring_Fees_Earliest_Review_Date__c!=null)  
        {    
   
           Datetime dt = ca.CA_Recurring_Fees_Earliest_Review_Date__c;
           String day = dt.format('dd');
           String month = dt.format('MMMMM'); 
            if(month.length()>3)
            month = month.substring(0,3);  
            
           String year= dt.format('yy');           
           rateString+='Earliest Review Date='+day + month + year;  
         }
        else
            rateString+='Earliest Review Date=';
            
     /*   If (ca.CA_Recurring_Fees_Review_Month__c!=null)
            rateString+='Review Month='+ca.CA_Recurring_Fees_Review_Month__c ;
        else
            rateString+='Review Month=';
     */   
     if(reviewCycleLength!=null)
     {
        if(reviewCycleLength==1) 
        rateString+=',1';
        else{
        Decimal roundedCycleLength = reviewCycleLength.setScale(7);
        rateString+=','+roundedCycleLength;
        }
        
     }
     else
        rateString+=',';
        
        //Increase terms:Misys Standard Rate,,,,,Earliest Review Date=01Jan19; rate used:4.0%; Base Amount: 8495.84
       // String lineDescription = defaultProductAssigned+'Increase terms:'+ ca.CA_Recurring_Fees_Index__r.Name +',CA RF+/-:'+ ca.CA_Recurring_Fees_percent__c+'%,CA RF Index Type:'+ca.CA_Recurring_Fees_Index_Type__c+';CA RF Rate Increase Min:'+ca.CA_Recurring_Fees_Rate_Increase_Min__c+'%CA RF Rate Increase Max:'+ca.CA_Recurring_Fees_Rate_Increase_Max__c+'%; rate used:'+ inRate + '%; Base Amount:' + totalLIPrice;
     //   String lineDescription = defaultProductAssigned+'Increase terms:'+ ca.CA_Recurring_Fees_Index__r.Name +rateString+'; rate used:'+ inRate + '%; Base Amount:' + totalLIPrice;
        String lineDescription = defaultProductAssigned+'Increase terms:'+ rateString+'; rate used:'+ inRate + '%; Base Amount:' + totalLIPrice;
       
        rec.Description = lineDescription;
        rec.Contract_Asset__c = ca.Id;
        rec.Misys_Standard_Rate_for_Contract_Asset__c = CA_RF_Standard_Increase_to_be_applied;
        
        /*Set the Add to Standard Increase Amount flag */
        If(ca.CA_Recurring_Fees_Index__r.Name == 'Misys Standard Rate' && (ca.CA_Recurring_Fees_percent__c==null )  && (ca.CA_Recurring_Fees_Rate_Increase_Min__c==null) && (ca.CA_Recurring_Fees_Rate_Increase_Max__c ==null))
        rec.Add_to_Standard_Increase_Amount__c = true;
        
       // rec.OwnerId = '00520000000hYH6'; // Pat Jones - Master Child
        
        
        return rec;
    }

/*Contract_Asset__c caList = [select id,CA_Recurring_Fees_Earliest_Review_Date__c,CA_Recurring_Fees_Review_Month__c from Contract_Asset__c where id = 'a1d20000001k60X'];
System.Debug('Value: ' + MaintenanceSweep.getReviewCycleLength(caList));*/

    //static as sometime we have to doa standalone test
    /* Review Cycle lenght may vary from 0-1. It depend on the review date */
    public static Decimal getReviewCycleLength(Contract_Asset__c ca ) 
    {
        If (ca.CA_Recurring_Fees_Earliest_Review_Date__c == null || ca.CA_Recurring_Fees_Review_Month__c == null)
        return 1;
    
        //String erdString = ca.CA_Recurring_Fees_Earliest_Review_Date__c;
        String reviewMonth = ca.CA_Recurring_Fees_Review_Month__c;
    
        Integer reviewMonthInt = 1;
        
        if(reviewMonth.contains('Jan')) reviewMonthInt = 1;
        if(reviewMonth.contains('Feb')) reviewMonthInt = 2;
        if(reviewMonth.contains('Mar')) reviewMonthInt = 3;
        if(reviewMonth.contains('Apr')) reviewMonthInt = 4;
        if(reviewMonth.contains('May')) reviewMonthInt = 5;
        if(reviewMonth.contains('Jun')) reviewMonthInt = 6;
        if(reviewMonth.contains('Jul')) reviewMonthInt = 7;
        if(reviewMonth.contains('Aug')) reviewMonthInt = 8;
        if(reviewMonth.contains('Sep')) reviewMonthInt = 9;
        if(reviewMonth.contains('Oct')) reviewMonthInt = 10;
        if(reviewMonth.contains('Nov')) reviewMonthInt = 11;
        if(reviewMonth.contains('Dec')) reviewMonthInt = 12;  
        
        integer currentYear = System.now().year();  
    
        Date review_Month_start_date = Date.newInstance(currentYear +1 /*2018*/, reviewMonthInt , 01); // change this for the next year
        //Date erd = setStringToDateFormat(erdString);
        // erd - end review date
        Date erd = ca.CA_Recurring_Fees_Earliest_Review_Date__c;
        
        Decimal returnValue = 1;
        
        if(erd<review_Month_start_date )
            returnValue  = 1;
        else if(erd > review_Month_start_date.addDays(365))
            returnValue  = 0;
        else 
        {
            returnValue = (erd.daysBetween(review_Month_start_date) +365);
            returnValue = returnValue/365;
        }
        
        return returnValue;
    
    }
    
    /*getVariableRate is based on the logic on the contract asset formula fields */
    public static Decimal getVariableRate(Contract_Asset__c ca, Decimal CA_RF_Standard_Increase_to_be_applied)
    
    {
        Decimal tempRate = 0;
        Decimal indexRate = 0;
        Decimal CARecurringFeePercent = 0;
        String rIndex = '';
        String rIndexType = '';
        
        
        // Calculate Inital / Temp rate - this is based on the formula field on Contract Asset called CA Uplift % Before Min/Max
        if(ca.CA_Recurring_Fees_Index__r.Name!=null)
        rIndex = ca.CA_Recurring_Fees_Index__r.Name;
        
        if(ca.CA_Recurring_Fees_Index_Type__c!=null)
        rIndexType= ca.CA_Recurring_Fees_Index_Type__c;
        
        if (ca.CA_RF_Index_Rate__c!=null)
        indexRate = ca.CA_RF_Index_Rate__c;
        
        if (ca.CA_Recurring_Fees_percent__c!=null)
        CARecurringFeePercent = ca.CA_Recurring_Fees_percent__c;
        
        If (rIndex == 'Misys Standard Rate')
            tempRate = (/*4.00*/ CA_RF_Standard_Increase_to_be_applied + CARecurringFeePercent);
        else 
        {
            if (rIndexType.equalsIgnoreCase('fix'))
               tempRate = indexRate + CARecurringFeePercent;
            else 
            {
            
            tempRate = CA_RF_Standard_Increase_to_be_applied; /*4.0*/
            if(tempRate > (indexRate + CARecurringFeePercent))
            tempRate = indexRate + CARecurringFeePercent;
            }
        }
        
        /*MAX(IF(CA_Recurring_Fees_Rate_Increase_Min__c>CA_Uplift_Before_Min_Max__c,
        CA_Recurring_Fees_Rate_Increase_Min__c,
        IF(CA_Recurring_Fees_Rate_Increase_Max__c<CA_Uplift_Before_Min_Max__c,CA_Recurring_Fees_Rate_Increase_Max__c,
        CA_Uplift_Before_Min_Max__c)),0)
        */
    
        // Calculate Final Rate - this is based on the formula field on Contract Asset called CA Uplift Final % for Change Order
        Decimal finalRate = 0;
        Decimal caRFeeRateIncreaseMin = 0;
        Decimal caRFeeRateIncreaseMax = 0;
        
        if(ca.CA_Recurring_Fees_Rate_Increase_Min__c!=null)
        caRFeeRateIncreaseMin = ca.CA_Recurring_Fees_Rate_Increase_Min__c;
        
        if(ca.CA_Recurring_Fees_Rate_Increase_Max__c!=null)
        caRFeeRateIncreaseMax = ca.CA_Recurring_Fees_Rate_Increase_Max__c;
        
        if (caRFeeRateIncreaseMin>tempRate && ca.CA_Recurring_Fees_Rate_Increase_Min__c!=null)
        finalRate = caRFeeRateIncreaseMin;
        else 
        {
            if (caRFeeRateIncreaseMax<temprate && ca.CA_Recurring_Fees_Rate_Increase_Max__c!=null)
                finalRate = caRFeeRateIncreaseMax;
            else 
                finalRate = tempRate;
        }
    
        if(finalRate < 0)
        finalRate = 0;
    
        return finalRate;
    }

    public static Opportunity createOpportunity(Account a)
     {
        Opportunity rec = new Opportunity();
        rec.RecordTypeId = '01220000000UYrGAAW'; //  [Select Id from RecordType where Name = 'Maintenance Renewal' and  SobjectType = 'Opportunity' limit 1].Id
        integer currentYear = System.now().year(); 
        rec.Name = a.Name + ' - 2019 Annual Increase'; // change this from  - 2018 Annual Increase // change this from  - 2017 Annual Increase
        rec.AccountId = a.Id;
        rec.StageName = '6. Negotiate';
        rec.CurrencyIsoCode = 'USD';
       
        Date closeDate= Date.newInstance(currentYear/*2017*/, 12, 31);//.dateGmt();
        rec.CloseDate = closeDate;
        rec.Maintenance_Sweep_Status__c = 'Auto Created';
        rec.Sales_Region_FY07__c = a.Sales_Region__c;
        rec.Account_Site__c = a.Site;
        rec.Misys_Forecast__c = 'Likely';
        rec.ForecastCategoryName = 'Pipeline';
        rec.Approval_Status__c = 'Not required';
        rec.Rating__c = 'Medium'; // Note this need to be update manually by the CAT team
        // Hold rollups
        rec.Rollup_Calculate_Batch_Hold__c = true;
        rec.OwnerId = '00520000000hYH6'; // Pat Jones
        return rec;
     }
    
    public static Date setStringToDateFormat(String myDate) 
      {
          String[] myDateOnly = myDate.split(' ');
          String[] strDate = myDateOnly[0].split('/');
          Integer myIntDate = integer.valueOf(strDate[0]);
          Integer myIntMonth = integer.valueOf(strDate[1]);
          Integer myIntYear = integer.valueOf(strDate[2]);
          Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
          return d;
       }

    /*Roll up Standard Amount */
    public static void doStandardAmountRollUpForMSOpportunities()
     {
        DateTime yearStartDate = DateTime.newInstance(System.Now().year() , 1, 1, 0, 0, 0);
        MS_Limits__c msLimit  = MS_Limits__c.getValues('MS Default Limits');
        Integer MS_Standard_Amount_Roll_Up = Integer.valueof(msLimit.MS_Standard_Amount_Roll_Up__c);
        Map<Id,Opportunity> oppMap = new Map<ID,opportunity>( [Select Id,Increase_Amount__c,MS_Rollup_Done__c  from opportunity where MS_Rollup_Done__c = false and MS_LI_Created__c = true and Maintenance_Sweep_Status__c!=null and createddate >= :yearStartDate  /*2017-01-01T00:00:00.000Z*/ limit :MS_Standard_Amount_Roll_Up /*and Id in ('0068E000004cJav' , '0068E000004cF2v')*/]);
        AggregateResult[] groupedResult = [select  opportunityid ,sum(totalprice) sumPrice from opportunityLineItem where opportunityid in :oppMap.keyset() and Add_to_Standard_Increase_Amount__c = true  and createddate >= :yearStartDate  /*2017-01-01T00:00:00.000Z*/  group by opportunityid ];
        
        
        Opportunity opty = new Opportunity();
        
        for(AggregateResult ar : groupedResult) {
            opty = oppMap.get((ID)ar.get('opportunityid'));
            opty.Increase_Amount__c  = (Decimal)ar.get('sumPrice');
        }
        
        for(Opportunity optyFromMap: oppMap.values())
        {
            optyFromMap.MS_Rollup_Done__c = true;
        }
        update oppMap.values();
     }
     
     
     /*Clear the rollup Flag
     
     List<Opportunity> optys= [Select Id,MS_Rollup_Done__c  from Opportunity where MS_Rollup_Done__c = true  and Maintenance_Sweep_Status__c!=null limit 400];

for (Opportunity o :optys)
{
o.MS_Rollup_Done__c = false;
}
update optys;

*/
//MaintenanceSweep.setLetterTypeValueonMSOpty();
 /*Letter Type */
    public static void setLetterTypeValueonMSOpty()
     {
        DateTime yearStartDate = DateTime.newInstance(System.Now().year() , 1, 1, 0, 0, 0);
        MS_Limits__c msLimit  = MS_Limits__c.getValues('MS Default Limits');
        Integer MS_Standard_Amount_Roll_Up = Integer.valueof(msLimit.MS_Standard_Amount_Roll_Up__c); // using the same limits as standard roll up - changeif required
       // Get the optys to determine the letter type
        Map<Id,Opportunity> oppMap = new Map<ID,opportunity>( [Select Id,Letter_Type__c,MS_Rollup_Done__c,Letter_Type_Rollup_Done__c  from opportunity where /*MS_Rollup_Done__c =false and*/  Letter_Type_Rollup_Done__c = false and MS_LI_Created__c = true and createddate >= :yearStartDate  /*2017-01-01T00:00:00.000Z*/ /*and Id in ('0068E000004bL1V')*/ and Maintenance_Sweep_Status__c!=null limit :MS_Standard_Amount_Roll_Up ]);
        // get the LIs with standard rate for the optys selected in oppMap
        AggregateResult[] groupedResultSILIs = [select  opportunityid ,count(Id) TotalStandardIncreaseLIs from opportunityLineItem where opportunityid in :oppMap.keyset() and Add_to_Standard_Increase_Amount__c = true and totalprice>0  and createddate >= :yearStartDate  /*2017-01-01T00:00:00.000Z*/  group by opportunityid ];
        
        // get the total LIs for the optys selected in oppMap
        AggregateResult[] groupedResultLIs = [select  opportunityid ,count(Id) TotalLIs from opportunityLineItem where opportunityid in :oppMap.keyset() and totalprice>0 and createddate >= :yearStartDate  /*2017-01-01T00:00:00.000Z*/  group by opportunityid ];
       //add amount =0.00
        Opportunity optySI = new Opportunity();
        Opportunity opty = new Opportunity();
        //this will store the SI LI against the optys
        Map<ID, Integer> totalSILIMap = new Map<ID, Integer>();
         Map<ID, String> resultMap = new Map<ID, String>();

        Integer totalLICount = 0;
        Integer totalSILICount = -1;
        
        String result;
        // get the Standard LIs and put in in the totalSILIMap map to be reference in the next loop
        for(AggregateResult ar : groupedResultSILIs ) {
            optySI = oppMap.get((ID)ar.get('opportunityid'));
            totalSILICount = (Integer)ar.get('TotalStandardIncreaseLIs');
            totalSILIMap.put(optySI.id, totalSILICount );
            }
        // get the total LI and compare it to the standard LIs stored in the totalSILIMap map loop
        for(AggregateResult ar : groupedResultLIs) {
            opty = oppMap.get((ID)ar.get('opportunityid'));
            totalLICount = (Integer)ar.get('TotalLIs');

            if(totalSILIMap.get(opty.id)!=null)
             totalSILICount  = (Integer)totalSILIMap.get(opty.id);
             else
             totalSILICount = -1;
            // make the comparison and set the string
             if ( totalLICount != totalSILICount) 
             result = 'According to Contract';
             else
             result = 'Standard';
            
            resultMap.put(opty.id,result);
        }
     
        for(Opportunity optyFromMap: oppMap.values())
        {
            //optyFromMap.MS_Rollup_Done__c = true; //-todo change this
            optyFromMap.Letter_Type_Rollup_Done__c = true;
            if(resultMap.get(optyFromMap.id)!=null)
            optyFromMap.Letter_type__c = resultMap.get(optyFromMap.id);
        
         //  else
           // optyFromMap.Letter_type__c = 'Standard'; // Pat said in this case leave this as blank
        }
        update oppMap.values();
     }
     
     // Question for Pat - what if they are all zeros - https://cs87.salesforce.com/0068E0000060Ptn ?

// this is a validation to check if any duplicate line items were generated during the MS oli creation process
// please note that the reason for why this may happen is unknown
 public static void identifyDuplicateMSLIs()
     {
        DateTime yearStartDate = DateTime.newInstance(System.Now().year() , 1, 1, 0, 0, 0);
        
        List<Opportunity> msOpps = [select id from opportunity where Maintenance_Sweep_Status__c = 'Auto Created' and createddate >= :yearStartDate /*2017-01-01T00:00:00.000Z*/];
        List<OpportunityLineItem> msOlis = [select id, Contract_Asset_ID_18char__c from opportunitylineitem where opportunityid in :msOpps and createddate >= :yearStartDate /*2017-01-01T00:00:00.000Z*/];
        
        AggregateResult[] groupedResultLIs = [select count(id) totalCAs,Contract_Asset__c from opportunitylineitem where opportunityid in :msOpps  and createddate >= :yearStartDate /*2017-01-01T00:00:00.000Z*/ group by Contract_Asset__c];
        
        integer totalCACount = 0;
        Set<Id> duplicateCAs = new Set<ID>();
        ID caID;
        
        for(AggregateResult ar : groupedResultLIs) 
        {
                  //  opty = oppMap.get((ID)ar.get('Contract_Asset__c'));
                    
                    totalCACount = -1;
                    totalCACount = (Integer)ar.get('totalCAs');
                    caID = (ID)ar.get('Contract_Asset__c');
        
                    if(totalCACount  >1 && caID!=null)
                        duplicateCAs.add(caID);
            
        }
            
        System.Debug('duplicateCAs: ' + duplicateCAs);
                                        
        // get the oli id and manually delete the one which has higher id
        List<OpportunityLineItem> duplicateMSOlis = [select id,name, Contract_Asset_ID_18char__c from opportunitylineitem where Contract_Asset__c in : duplicateCAs and name like '%:(System.Now().year()+1)%' /*this was 2017 before */  and createddate >= :yearStartDate /*2017-01-01T00:00:00.000Z*/];

        for (OpportunityLineItem oli: duplicateMSOlis) 
            System.Debug('Duplicate OLI Id and Name:' + oli.id +'-' + oli.name + '\n'  );
    
    }
  
    }