/**
 * @File Name          : TestDataFactory.cls
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 31/07/2019, 11:02:28
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    31/07/2019, 11:00:41   Peter Sabry     Initial Version
**/
@isTest
public class TestDataFactory {
    
    private static final String accNAME = 'Test Account';
    private static final String NS_INTERNAL_ID = '12345';
    //G.B - 05.06.2019
    public static User getRunningUser(String profileName){
        Profile userRunningProfile = [SELECT Id FROM Profile WHERE Name=:profileName];
        User runningUser = new User(Alias = 'testuser', 
                                Email='runningUser@lebill.com', 
                                EmailEncodingKey='UTF-8', 
                                LastName='Testing', 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_GB', 
                                ProfileId = userRunningProfile.Id, 
                                TimeZoneSidKey='Europe/London', 
                                UserName='runningUser@lebill.com');
         return runningUser;
    }
    //G.B - 05.06.2019
    public static void bypassCPQValidation(){
        CPQValidations__c bypassVR = CPQValidations__c.getOrgDefaults();
        bypassVR.Bypass__c = true;
        insert bypassVR;
    }
    public static Account createAccount(String accNAME){
        Account acc = new Account(Name = accNAME);
        insert acc;        
        return acc;
    }
    public static Account createAccount( Boolean dbInsert, String accNAME ){
        Account acc = new Account(Name = accNAME);
        if(dbInsert){
            insert acc;
        }
        return acc;
    } 
    
    public static Opportunity createOpportunity(Account acc){
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id);
        opp.StageName = 'Open';
        opp.Service_Type__c = 'Academy Training';
        opp.Service_Sub_Type__c  = 'Client';
        opp.CloseDate = system.today() + 30;
        opp.RecordTypeID='01220000000UYLr';
        //opp.Finastra_Led_Cloud_Deal__c='No';
        
        insert opp;        
        return opp;
    }    
    public static Opportunity createOpportunity(Account acc,Boolean dbInsert ){
        Opportunity opp = new Opportunity(Name = 'Opp1', AccountId = acc.Id);
        opp.StageName = 'Open';
        opp.CloseDate = system.today() + 30;
        if(dbInsert){
            insert opp;
        }
        return opp;
    }
    
    public static Contract createContract(Account acc, Opportunity opp){
        Contract con = new Contract();
        Billing_Entity__c be = createBillingEntity();
        con.Name = 'Test Con';
        con.AccountId = acc.Id;
        con.Misys_Entity__c = be.Id;
        con.CurrencyIsoCode = 'USD';
        con.Misys_Opportunity__c = opp.Id;
        con.Recurring_Fees_Start_Planned__c = system.today()+10;    
        con.StartDate = System.today();
        insert con;           
        return con;
    }
    
    public static Billing_Entity__c createBillingEntity(){
        Billing_Entity__c be = new Billing_Entity__c();
        be.name = 'Test Entity';
        be.BE_Active__c = true;
        insert be;
        return be;       
    }
    public static Billing_Entity__c createBillingEntity(Boolean dbInsert){
        Billing_Entity__c be = new Billing_Entity__c();
        be.name = 'Test Entity';
        if(dbInsert){
            insert be;
        }
        return be;       
    }
    
    public static SBQQ__Subscription__c createILF_Subscription(Contract con){
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Contract__c = con.Id;
        sub.SBQQ__Quantity__c = 1;
        sub.Initial_Sales_Order_Type__c = 'ILF - ILF';
        sub.Inital_NS_Item__c = createNsItem().Id;
        sub.Sold_Value__c = 100.0;
        sub.Initial_Price__c = 90.0;        
        sub.Pro_Rata_Calculated__c = false;
        insert sub;
        return sub;
    }    
    public static SBQQ__Subscription__c createILF_Subscription(Contract con,Boolean dbInsert){
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Contract__c = con.Id;
        sub.SBQQ__Quantity__c = 1;
        sub.Initial_Sales_Order_Type__c = 'ILF - ILF';
        sub.Inital_NS_Item__c = createNsItem().Id;
        sub.Sold_Value__c = 100.0;
        sub.Initial_Price__c = 90.0;
        if(dbInsert){
            insert sub;
        }
        return sub;
    }

    public static SBQQ__Subscription__c createRLF_Subscription(Contract con,Boolean dbInsert){
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Contract__c = con.Id;
        sub.SBQQ__Quantity__c = 1;
        sub.Initial_Sales_Order_Type__c = 'On Premise RLF';
        sub.Inital_NS_Item__c = createNsItem().Id;
        //sub.Revenue_Type__c = 'RLF';
        sub.Sold_Value__c = 100.0;
        sub.Initial_Price__c = 90.0;
        if(dbInsert){
            insert sub;
        }
        return sub;
    }
    
    public static void createPS_Subscription(Contract con, Id bScheduleId, Id bgId){
        
        List<SBQQ__Subscription__c> psSUbs = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c tempSub;
        for (Integer i = 0; i < 5; i++) {
            tempSub = new SBQQ__Subscription__c();
            tempSub.Billing_Group__c = bgId;
            tempSub.SBQQ__Contract__c = con.Id;
            tempSub.SBQQ__Quantity__c = 1;
            tempSub.Initial_Sales_Order_Type__c = 'PS - PS';
            tempSub.Inital_NS_Item__c = createNsItem().Id;
            tempSub.Sold_Value__c = 100.0;
            tempSub.LineItem_Process_Type__c = 'SVTM'; 
            tempSub.Initial_Price__c = 90.0;
            if(Math.mod(i, 2) == 1)
                tempSub.Opportunity_Billing_Schedule__c = bScheduleId;
            psSUbs.add(tempSub);
        }   
        
        insert psSUbs;        
    }    
    public static SBQQ__Subscription__c createPS_Subscription(Contract con,Boolean dbInsert){
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();        
        sub.SBQQ__Contract__c = con.Id;
        sub.SBQQ__Quantity__c = 1;
        sub.Initial_Sales_Order_Type__c = 'PS - PSS';
        Sub.LineItem_Process_Type__c = 'SVFP';
        sub.Inital_NS_Item__c = createNsItem().Id;
        sub.Sold_Value__c = 100.0;
        sub.Initial_Price__c = 90.0;
        if(dbInsert){
            insert sub;
        }
        return sub;
    }
    
    public static void createRLF_Subscription(Contract con, Id bgId){
        
        List <String> billingFrequency = new List<String>{ 'Annual', 'Quarterly', 'Semiannual', 'Biennial', 'Monthly', 'Triennial', 'Quinquennial' };
           
            List<Product2> prods = new List<Product2>();
        Product2 prod1 = new Product2(  Name = 'testProd'
                                      , NS_Internal_ID__c = NS_INTERNAL_ID
                                      , ProductCode='RLF'
                                      , Family = 'RLF (CM)'
                                      , SO_Grouping__c = 'RLF-RLF'
                                      , CY_Billing_Current_Amount__c = 10.00
                                      , CY_Billing_Previous_Amount__c = 12.00
                                      , UPID__c = '1234561'
                                      , CanUseRevenueSchedule = true
                                      , Product_Set__c = 'Almonde'
                                      , Licence_Group_GMS__c = true
                                      , Sku_group__c = 'test SKU 1');
        
        insert prod1;
            
            List<SBQQ__Subscription__c> rlfSubs = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c tempSub;
        for (Integer i = 0; i < 7; i++) {
            tempSub = new SBQQ__Subscription__c();
            tempSub.SBQQ__Contract__c = con.Id;
            tempSub.SBQQ__Quantity__c = 1;
            tempSub.SBQQ__Product__c = prod1.id;
            tempSub.Recurring_Sales_Order_Type__c = 'RLF - RLF';
            tempSub.Billing_Group__c = bgId;
            tempSub.Billing_Day__c = 1;
            tempSub.Billing_Month__c = 'January';
            tempSub.SBQQ__BillingFrequency__c = billingFrequency[i];
            tempSub.Recurring_NS_Item__c = createNsItem().Id;
            tempSub.SBQQ__NetPrice__c = 100;
            tempSub.RF_Start_Planned_Date__c = system.today();
            tempSub.Prorata_Days__c = 5;
            tempSub.Next_Billing_Date__c = system.today().addDays(10);
            rlfSubs.add(tempSub);
        }   
        rlfSubs[0].SBQQ__BillingType__c = 'Advance';
        
        insert rlfSubs;      
    }
    
    public static NS_Item__c createNsItem(){
        NS_Item__c item = new NS_Item__c();
        item.Name = 'NS Item1';
        item.NS_Product_Dimension_ID__c = '100';
        item.Payaway__c = true;
        insert item;
        return item;
    }    
    public static NS_Item__c createNsItem(Boolean dbInsert ){
        NS_Item__c item = new NS_Item__c();
        item.Name = 'NS Item1';
        item.NS_Product_Dimension_ID__c = '100';
        if(dbInsert) {
            insert item;
        }
        return item;
    }
    
    public static void add_NsCostCenterList(){
        NS_Cost_Centre__c cc = new NS_Cost_Centre__c();
        cc.NS_Cost_Centre_Internal_Id__c = '61';
        insert cc;
        
        cc = new NS_Cost_Centre__c();
        cc.NS_Cost_Centre_Internal_Id__c = '82';
        insert cc;
        
        system.assertEquals(2, [SELECT COUNT() FROM NS_Cost_Centre__c where NS_Cost_Centre_Internal_Id__c='61' or NS_Cost_Centre_Internal_Id__c='82'], 'inserted NS Cost Center with 61, 82 values');
        
    }
    
    public static void add_NsProdList(){
        NS_Product__c prod = new NS_Product__c();
        prod.NS_Product_Internal_Id__c = '100';
        insert prod;        
    }
    
    public static void add_NsAccountList(){
        NS_Account__c nsAcc = new NS_Account__c();
        nsAcc.NS_Account_Internal_Id__c = 'test1';
        insert nsAcc;
        
        nsAcc = new NS_Account__c();
        nsAcc.NS_Account_Internal_Id__c = 'test2';
        insert nsAcc;        
    }
    
    public static Id add_OppBillingSchedule(Opportunity opp){
        // insert billing schedule
        Opportunity_Billing_Schedule__c bs = new Opportunity_Billing_Schedule__c();
        bs.Opportunity__c = opp.Id;
        bs.Processing_Type__c = 'SVTM';
        insert bs;
        
        // inserting billing scheule items
        Opportunity_Billing_Schedule_Item__c items = new Opportunity_Billing_Schedule_Item__c();
        items.Opportunity_Billing_Schedule__c = bs.Id;
        items.Line__c = 20;
        insert items;
        return bs.Id;
    }
    
    public static void add_NsCurrencyMap(){
        NS_Currency__c curr = new NS_Currency__c();
        curr.Name = 'USD';
        insert curr;
    }
    
    public static Billing_Group__c createBillingGroup(Contract con){
        Billing_Group__c bg = new Billing_Group__c();
        bg.Original_Contract__c = con.Id;
        bg.BG_Client_Contracting_Name__c = con.AccountId;
        bg.Account_by_Sub__c = con.Billing_Group_Entity__c;
        bg.Original_Opportunity__c = con.SBQQ__Opportunity__c;
        bg.CurrencyIsoCode = con.Opportunity_Currency_Code__c;
        bg.Current_Sales_Order_Start_Date__c = con.StartDate;
        bg.NS_Subscription_Memo__c = con.Memo__c;
        bg.BG_Misys_Billing_Entity__c = con.Misys_Entity__c;
        bg.BG_Client_Bill_To__c = con.Bill_To__c;
        bg.BG_Client_Ship_To__c = con.Ship_To__c;
        bg.BG_Billing_Group_Active__c = true;
        bg.BG_Data_Status__c = 'BGWiz Created';        
        bg.Original_Contract_Expiry_Date__c = con.Contract_Expiry_Date__c;
        insert bg;
        return bg;
    }  
    public static Billing_Group__c createBillingGroup1(Contract con){
        Billing_Group__c bg = new Billing_Group__c();
        bg.Original_Contract__c = con.Id;
        bg.BG_Client_Contracting_Name__c = con.AccountId;
        bg.Original_Opportunity__c = con.SBQQ__Opportunity__c;
        bg.CurrencyIsoCode = con.Opportunity_Currency_Code__c;
        bg.Current_Sales_Order_Start_Date__c = con.StartDate;
        bg.BG_Misys_Billing_Entity__c = con.Misys_Entity__c;
        bg.BG_Billing_Group_Active__c = true;
        bg.BG_Data_Status__c = 'BGWiz Created';        
        bg.Original_Contract_Expiry_Date__c = con.Contract_Expiry_Date__c;
        insert bg;
        return bg;
    }  
    
    public static Billing_Group__c createBillingGroup(Contract con,Boolean dbInsert){
        Billing_Group__c bg = new Billing_Group__c();
        bg.Original_Contract__c = con.Id;
        bg.BG_Client_Contracting_Name__c = con.AccountId;
        bg.Account_by_Sub__c = con.Billing_Group_Entity__c;
        bg.Original_Opportunity__c = con.SBQQ__Opportunity__c;
        bg.CurrencyIsoCode = con.Opportunity_Currency_Code__c;
        bg.Current_Sales_Order_Start_Date__c = con.StartDate;
        bg.NS_Subscription_Memo__c = con.Memo__c;
        bg.BG_Misys_Billing_Entity__c = con.Misys_Entity__c;
        bg.BG_Client_Bill_To__c = con.Bill_To__c;
        bg.BG_Client_Ship_To__c = con.Ship_To__c;
        bg.BG_Billing_Group_Active__c = true;
        bg.BG_Data_Status__c = 'BGWiz Created';
        bg.Original_Contract_Expiry_Date__c = con.Contract_Expiry_Date__c;
        if(dbInsert) {
            insert bg;
        }
        return bg;
    } 
    
    public static void addRevRecoginationTemplate(){
        NS_Revenue_Recognition_Template__c temp = new NS_Revenue_Recognition_Template__c();
        temp.Name = 'POC';
        insert temp;
    }
    
    public static void setUpTransfromBatchData() {
        List<Product2> prods = new List<Product2>();
        Product2 prod1 = new Product2(  Name = 'testProd'
                                      , NS_Internal_ID__c = NS_INTERNAL_ID
                                      , ProductCode='RLF'
                                      , Family = 'RLF (CM)'
                                      , SO_Grouping__c = 'RLF-RLF'
                                      , CY_Billing_Current_Amount__c = 10.00
                                      , CY_Billing_Previous_Amount__c = 12.00
                                      , UPID__c = '1234561'
                                      , CanUseRevenueSchedule = true
                                      , Product_Set__c = 'Almonde'
                                      , Licence_Group_GMS__c = true
                                      , Sku_group__c = 'test SKU 1');
        prods.add(prod1);
        insert prods;
        
        NS_Item__c nsItm = new NS_Item__c();
        nsItm.NS_Internal_ID__c=NS_INTERNAL_ID;
        insert nsItm;
        Account acc = TestUtility.createAccount('Test Account');
        System__c sys = TestUtility.createSystem(acc);
        Contract con = TestUtility.sampleContract(acc.id);
        insert con;
        Product_Set__c ps = TestUtility.sampleProductSet(acc.Id);
        insert ps;
        Client_Asset__c cta = TestUtility.sampleClientAsset(ps.id);
        cta.Account__c = acc.id;
        insert cta;
        List<NS_Billing_Frequency__c> bgFreqs = new List<NS_Billing_Frequency__c>();
        NS_Billing_Frequency__c bgFreq1 = new NS_Billing_Frequency__c();
        bgFreq1.Name='Yearly';
        bgFreqs.add(bgFreq1);
        insert bgFreqs;
        
        NS_Subscriptions__c nsSub = new NS_Subscriptions__c();
        nsSub.Next_Billing_Date__c=System.today(); 
        insert nsSub; 
        List<Billing_Group__c> bgs = new List<Billing_Group__c>();
        Billing_Group__c bg1 = TestAssetUtils.createBillingGroup();
        bg1.Fixed_Billing_Date__c=System.today();
        bg1.NS_Billing_Frequency__c=bgFreq1.id;
        bg1.BG_Client_Contracting_Name__c=acc.id;
        bg1.NS_Subscription_Billing_Method__c='Advance';
        bg1.Original_Contract__c = con.id;
        bgs.add(bg1);
        update bgs;
        
        RF_Index__c rfIndex = new RF_Index__c();
        rfIndex.RF_Index_Active__c = true;
        rfIndex.Name = 'Misys Standard Rate';
        insert rfIndex;
        
        List<Contract_Asset__c> cnts =new List<Contract_Asset__c>();
        Contract_Asset__c cnt1 = TestUtility.sampleContractAsset(cta.id, sys.id, acc.id);
        cnt1.CA_Recurring_Fees_Index_Type__c='CAP';
        cnt1.CA_Recurring_Fees_Index__c= rfIndex.Id;
        cnt1.CA_Billing_Group__c=bg1.id;
        cnt1.CA_Recurring_Fees_percent__c=10;
        cnt1.CA_Recurring_Fees_Rate_Increase_Max__c=20;
        cnt1.CA_Recurring_Fees_Rate_Increase_Min__c=10;
        cnt1.CA_Billing_Status__c='Active billing';
        cnt1.Licence_Band__c='VBP8';
        cnt1.License_Metric__c='Concurrent User';
        cnt1.License_Status__c='Superceded';
        cnt1.NS_Subscription__c=nsSub.id;
        cnt1.Annual_Maintenance__c=10;
        cnt1.Current_Fair_Value__c=10;
        cnt1.Product__c=prod1.id;
        cnts.add(cnt1);
        insert cnts;
    } 
    
    public static void setUpLinkBGBatchData() {
        List<Product2> prods = new List<Product2>();
        Product2 prod1 = new Product2(  Name = 'testProd'
                                      , NS_Internal_ID__c = NS_INTERNAL_ID
                                      , ProductCode='RLF'
                                      , Family = 'RLF (CM)'
                                      , SO_Grouping__c = 'RLF-RLF'
                                      , CY_Billing_Current_Amount__c = 10.00
                                      , CY_Billing_Previous_Amount__c = 12.00
                                      , UPID__c = '1234561'
                                      , CanUseRevenueSchedule = true
                                      , Product_Set__c = 'Almonde'
                                      , Licence_Group_GMS__c = true
                                      , Sku_group__c = 'test SKU 1');
        prods.add(prod1);
        insert prods;
        
        NS_Item__c nsItm = new NS_Item__c();
        nsItm.NS_Internal_ID__c=NS_INTERNAL_ID;
        insert nsItm;
        Account acc = TestUtility.createAccount('Test Account');
        System__c sys = TestUtility.createSystem(acc);
        Product_Set__c ps = TestUtility.sampleProductSet(acc.Id);
        insert ps;
        Client_Asset__c cta = TestUtility.sampleClientAsset(ps.id);
        cta.Account__c = acc.id;
        insert cta;
        List<NS_Billing_Frequency__c> bgFreqs = new List<NS_Billing_Frequency__c>();
        NS_Billing_Frequency__c bgFreq1 = new NS_Billing_Frequency__c();
        bgFreq1.Name='Yearly';
        bgFreqs.add(bgFreq1);
        insert bgFreqs;
        
        NS_Subscriptions__c nsSub = new NS_Subscriptions__c();
        nsSub.Next_Billing_Date__c=System.today(); 
        insert nsSub; 
        List<Billing_Group__c> bgs = new List<Billing_Group__c>();
        Billing_Group__c bg1 = TestAssetUtils.createBillingGroup();
        bg1.Fixed_Billing_Date__c=System.today();
        bg1.NS_Billing_Frequency__c=bgFreq1.id;
        bg1.BG_Client_Contracting_Name__c=acc.id;
        bg1.NS_Subscription_Billing_Method__c='Advance';
        bgs.add(bg1);
        update bgs;
        
        RF_Index__c rfIndex = new RF_Index__c();
        insert rfIndex;
        
        List<Contract_Asset__c> cnts =new List<Contract_Asset__c>();
        Contract_Asset__c cnt1 = TestUtility.sampleContractAsset(cta.id, sys.id, acc.id);
        cnt1.CA_Recurring_Fees_Index_Type__c='CAP';
        cnt1.CA_Recurring_Fees_Index__c= rfIndex.Id;
        cnt1.CA_Billing_Group__c=bg1.id;
        cnt1.CA_Recurring_Fees_percent__c=10;
        cnt1.CA_Recurring_Fees_Rate_Increase_Max__c=10;
        cnt1.CA_Recurring_Fees_Rate_Increase_Min__c=10;
        cnt1.CA_Billing_Status__c='Active billing';
        cnt1.Licence_Band__c='VBP8';
        cnt1.License_Metric__c='Concurrent User';
        cnt1.License_Status__c='Superceded';
        cnt1.NS_Subscription__c=nsSub.id;
        cnt1.Annual_Maintenance__c=10;
        cnt1.Current_Fair_Value__c=10;
        cnt1.Product__c=prod1.id;
        cnts.add(cnt1);
        insert cnts;
    } 
    
    public static Sovos_Tax_Determination__c createSovosTaxDetermination( Boolean dbInert ) {
        Sovos_Tax_Determination__c sovosTax = new Sovos_Tax_Determination__c();
        sovosTax.Software_Delivery_Type__c = 'Electronic';
        sovosTax.Delivery_Type__c = 'Electronic';
        sovosTax.Tax_Type__c = 'Maintenance';
        sovosTax.Sub_Type__c = 'Custom';
        sovosTax.TWE_Sovos_Code__c = '1357924';
        if(dbInert) {
            insert sovosTax;
        }
        return  sovosTax;
    }
    
    public static NS_Project__c createNSProject( Boolean dbInert ) {
        NS_Product__c product = new NS_Product__c(name = 'test_prod');
        insert product;
        NS_Project__c project = new NS_Project__c(  Project_Product__c = product.id,
                                                  Project_Name__c = 'Test Proj',
                                                  Deferred_Account_Type__c ='PS', 
                                                  OpenAir_Project_Stage__c = 'Pipeline',
                                                  SFDC_Opportunity_Category__c = 'Omitted', 
                                                  OA_Project_Template__c = 'TEMPLATE - Pre-Sales Project',
                                                  Project_Category__c = 'Training' );
        if(dbInert) {
            insert project;
        }
        return project;
    }
    
    public static void createMileStones(Id projId, Id sitemId){
        
        NS_Project_Milestone__c[] tList = new List<NS_Project_Milestone__c>();
        for(Integer i = 0; i < 2; i++){
            tList.add(new NS_Project_Milestone__c(NS_Project__c = projId, Opportunity_Billing_Schedule_Item__c = sitemId));
        }
        insert tList;
    }
    
    public static void createVBSList(Id projId){
        NS_Vendor_Billing_Schedule__c[] vbList = new List<NS_Vendor_Billing_Schedule__c>();
        for(Integer i = 0; i < 2; i++){
            vbList.add(new NS_Vendor_Billing_Schedule__c(NS_Project__c = projId, CurrencyIsoCode = 'USD', SOI_Amount__c = 100));
        }
        insert vbList;
    }
    
    public static Integration_Log__c createILog(){
        Integration_Log__c log = new Integration_Log__c();
        log.RecordTypeId = Label.Integration_RecTypeId_PPOPPLINE;
        system.debug(Label.Integration_RecTypeId_PPOPPLINE);
        return log; 
    }
    
    public static void init_NS_maps(){
        TestDataFactory.add_NsCostCenterList();        
        TestDataFactory.add_NsProdList();         
        TestDataFactory.add_NsAccountList();        
        TestDataFactory.add_NsCurrencyMap();         
        TestDataFactory.addRevRecoginationTemplate(); 
    }
    
    
}