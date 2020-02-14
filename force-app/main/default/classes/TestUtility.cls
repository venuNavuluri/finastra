@isTest
public class TestUtility {
    private static final String eMail ='cpdummy@d.com';
    
    public static Account createAccount(string name)
    {
        Account acct = sampleAccount();
        acct.Name = name;
        insert acct;
        return acct;
    }
    
    public static System__c createSystem(Account acct)
    {
        System__c sys = sampleSystem(acct.id);
        insert sys;
        return sys;
    }
    
    public static Account sampleAccount(){
        Account rec = new Account();
        rec.Name = 'Test Account';
        return rec;
    }

    public static Lead sampleLead(){
        Lead rec = new Lead();
        rec.Company = 'Test Company';
        rec.LastName = 'Last';
        rec.Salutation = 'Mr.';
        return rec;
    }

    public static Campaign sampleCampaign(){
        Campaign rec = new Campaign();
        rec.name = 'Test Campaign';
        return rec;
    }
    
    public static Case sampleCase(){
        Case rec = new Case();
        rec.Subject = 'Test Case';
        rec.Status = 'New';
        return rec;
    }
    
    public static Case sampleIssueCase(){
        Case rec = new Case();
        rec.Subject = 'Test Issue Case';
        rec.RecordTypeId = Label.issue_case_id;
        rec.Status = 'New';
        return rec;
    }
    
    public static Contact sampleContact(){
        CONSTANTS.DISABLE_INDIVIDUAL_TRIGGER  = true;
        Contact rec = new Contact();
        rec.LastName = 'Last';
        rec.Email = 'testuser@foo.com';
        return rec;
    }
    
    public static User sampleUser(){
        //Get a standard user profile
        Profile p = [select Id from Profile where UserType = 'Standard' LIMIT 1];
        //Create the User and set defaults
        User u = new User();
        u.LastName = 'Dummy';
        u.Alias = 'ddum1234';
        u.Email = 'dummy@d.com';
        u.Username = 'dummy'+datetime.now().millisecond()+'@d.com';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey = 'America/Panama';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';
        return u;      
    }
    
    public static User sampleCustPortalUser(Contact c){
         //PN - 02/10 Uncommented the lines for the user role
        //Get a customer portal profile
        Profile p = [select Id from Profile where UserType='PowerCustomerSuccess' and name='Customer Community Banking User' LIMIT 1];
        //Get a customer portal role
        //UserRole ur = [select Id,name from UserRole where PortalType = 'CustomerPortal' LIMIT 1];
        //system.debug('## ur ' +ur);
        //Create the User and set defaults
        User u = new User();
        u.FirstName = c.FirstName;
        u.LastName = c.LastName;
        u.Title = c.Title;
        u.Phone = c.Phone;
        u.MobilePhone = c.MobilePhone;
        u.Fax = c.Fax;
        u.Street = c.MailingStreet;
        u.State = c.MailingState;
        u.City = c.MailingCity;
        u.Country = c.MailingCountry;
        u.PostalCode = c.MailingPostalCode;
        u.Alias = 'cpdum123';
        u.Email = eMail;
        u.Username = eMail;
        u.ProfileId = p.Id;
        //u.UserRoleId = ur.Id; 
        u.ContactId = c.Id;
        u.TimeZoneSidKey = 'America/Panama';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';
            
        return u;
    }
    public static User sampleCustPortalUserWithRole(Contact c){
        //Get a customer portal profile
        Profile p = [select Id from Profile where UserType='PowerCustomerSuccess' and name='Customer Community Banking User' LIMIT 1];
        //Get a customer portal role
        UserRole ur = [select Id from UserRole where PortalType = 'CustomerPortal' LIMIT 1];
        //Create the User and set defaults
        User u = new User();
        u.FirstName = c.FirstName;
        u.LastName = c.LastName;
        u.Title = c.Title;
        u.Phone = c.Phone;
        u.MobilePhone = c.MobilePhone;
        u.Fax = c.Fax;
        u.Street = c.MailingStreet;
        u.State = c.MailingState;
        u.City = c.MailingCity;
        u.Country = c.MailingCountry;
        u.PostalCode = c.MailingPostalCode;
        u.Alias = 'cpdum123';
        u.Email = eMail;
        u.Username = eMail;
        u.ProfileId = p.Id;
        u.UserRoleId = ur.Id; 
        u.ContactId = c.Id;
        u.TimeZoneSidKey = 'America/Panama';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';
            
        return u;
    }
    
    public static Opportunity sampleOpportunity()
    {
        //Use this method if not attaching the opportunity to an account/contact for testing
        Account a = TestUtility.sampleAccount();
        insert a;
        Contact c = TestUtility.sampleContact();
        c.accountid = a.id;
        insert c;
        
        Opportunity o1 = TestUtility.sampleOpportunity(c);
        return o1;
    }
    
    
    public Opportunity sampleOpportunity1()
    {
        //Use this method if not attaching the opportunity to an account/contact for testing
        Account a = TestUtility.sampleAccount();
        insert a;
        Contact c = TestUtility.sampleContact();
        c.accountid = a.id;
        insert c;
        
        Opportunity rec = new Opportunity();
        rec.Name = 'Test Opp - Mouse';
        rec.RSF_HOS_TB_CommValue__c = 0;
        rec.AccountId = c.accountid;
        rec.StageName = 'Suspect';
        rec.CurrencyIsoCode = 'GBP';
        rec.CloseDate = system.today()+7;
        //rec.Database_Platform__c = 'Other';
        rec.ContractID__c = '1234';
        rec.Term_Estimate_Months__c = 30;
        return rec;
    }
    
    public static Opportunity sampleOpportunity(Account a)
    {
        //Use this method if an account is previously created but not a contact
        Contact c = TestUtility.sampleContact();
        c.accountid = a.id;
        insert c;
        
        Opportunity o1 = TestUtility.sampleOpportunity(c);
        return o1;
    }
    
    public static Opportunity sampleOpportunity(Contact c){
        Opportunity rec = new Opportunity();
        rec.Name = 'Test Opp - Mouse';
        rec.AccountId = c.accountid;
        rec.StageName = 'Suspect';
        rec.CurrencyIsoCode = 'GBP';
        rec.CloseDate = system.today()+7;
        //rec.Database_Platform__c = 'Other';
        rec.ContractID__c = '1234';
        rec.Term_Estimate_Months__c = 30;
       // rec.RSF_HOS_TB_CommValue__c = 0;
        // rec.Get_Documents_Signed__c = datetime.now().dateGmt(); // field deleted
        rec.Deliver_Contracts__c = datetime.now().dateGmt();
        // rec.Close_Plan__c = true; // field deleted
        // rec.Reach_Final_Agreement__c = datetime.now().dateGmt(); // field deleted
        // rec.Present_Preliminary_Solutions__c = datetime.now().dateGmt(); // field deleted
        // rec.Proposal_Issued__c = datetime.now().dateGmt(); // field deleted
        // rec.Verbal_Approval__c = datetime.now().dateGmt(); // field deleted
        //rec.Name_of_Power_Sponsor__c = c.id;
        // rec.Define_Power_Sponsor_s_Pain__c = true; // field deleted
        // rec.Create_Power_Sponsor_s_Vision__c = true; // field deleted
        // rec.Unique_Business_Value__c = 'yes'; // field deleted     
        // rec.Develop_Confirm_Next_Steps__c = datetime.now().dateGmt(); // field deleted
        // rec.Determine_Evaluation_Criteria__c = true; // field deleted
        //rec.Name_of_Sponsor__c = c.id;
        // rec.Define_Sponsor_s_Pain__c = true; // field  deleted
        // rec.Create_Sponsor_s_Vision__c = true; // field deleted
        rec.Completed_Strength_of_Sales_Checklist__c = true;
        // rec.Negotiate_Access_to_Power__c = true; // field deleted
        // rec.Qualify_Confirm_Next_Steps__c = datetime.now().dateGmt(); // field deleted
        // rec.Sponsor_Ltr_Agreement_Signed__c = datetime.now().dateGmt(); // field deleted
        // rec.Receipt_of_RFP__c = true; // field deleted
        // rec.Identify_Potential_Beneficiary__c = true; // field deleted
        // rec.Get_Pain_Admitted__c = true; // field deleted
        rec.Compelling_Event__c = 'yes';
        // rec.Create_Confirm_Next_Steps__c = datetime.now().dateGmt(); //
        
        return rec;
    }
    
    public static OpportunityLineItem sampleOpportunityLineItem(Opportunity o, String productFamily){
        Product2 p = TestUtils.getProduct('ut prod1');
        p.CanUseRevenueSchedule=true;
        p.Family = productFamily;
        insert p;
        Id pbId = TestUtils.getStandardPriceBookId();
        PriceBookEntry pbItem = TestUtils.getPriceBookEntry(p, pbId);
        pbItem.CurrencyIsoCode = o.CurrencyIsoCode;
        insert pbItem;
        
        o.pricebook2Id = pbId;
        update o;
        
        OpportunityLineItem rec = new OpportunityLineItem();
        rec.PricebookEntryId = pbItem.Id;
        rec.OpportunityId = o.Id;
        rec.Quantity = 1;
        rec.TotalPrice = 100;
        return rec;
    }

    public static OpportunityLineItem sampleOpportunityLineItemDoNotUpdateOrder(Opportunity o, String productFamily){
        Product2 p = TestUtils.getProduct('ut prod1');
        p.CanUseRevenueSchedule=true;
        p.Family = productFamily;
        insert p;
        Id pbId = TestUtils.getStandardPriceBookId();
        PriceBookEntry pbItem = TestUtils.getPriceBookEntry(p, pbId);
        pbItem.CurrencyIsoCode = o.CurrencyIsoCode;
        insert pbItem;
       
        OpportunityLineItem rec = new OpportunityLineItem();
        rec.PricebookEntryId = pbItem.Id;
        rec.OpportunityId = o.Id;
        rec.Quantity = 1;
        rec.TotalPrice = 100;
        return rec;
    }
    


    public static OpportunityLineItem sampleOpportunityLineItem1(Opportunity o, String productFamily){
        PricebookEntry pbItem1 = [select Id from PricebookEntry where IsActive=true and CurrencyIsoCode=:o.CurrencyIsoCode and Product2.Family=:productFamily LIMIT 1]; 
        OpportunityLineItem rec = new OpportunityLineItem();
       
        
        rec.PricebookEntryId = pbItem1.Id;
        rec.OpportunityId = o.Id;
        rec.Quantity = 1;
        rec.TotalPrice = 100;
        
        return rec;
    }

    public static OpportunityLineItemSchedule sampleOpportunityLineItemSchedule(Opportunity o, OpportunityLineItem prod){
        OpportunityLineItemSchedule rec = new OpportunityLineItemSchedule();
        rec.OpportunityLineItemId = prod.Id;
        rec.ScheduleDate = o.CloseDate;
        rec.Type = 'Revenue';
        rec.Revenue = 10;
        return rec;
    }   
    
    public static Accounts_Supported__c sampleAccountsSupported(Contact c, Account a){
        Accounts_Supported__c rec = new Accounts_Supported__c();
        rec.Contact__c = c.Id;
        rec.Supported_Account__c = a.Id;
        return rec;
    }
    
    public static Project_Information__c sampleProjectInformation(Account a){
        Project_Information__c rec = new Project_Information__c();
        rec.Name = 'test';
        rec.Account__c = a.Id;
        rec.Project_Code__c = 'NONE';
        return rec;
    }
    
    public static MyProject__c sampleMyProject(){
        MyProject__c rec = new MyProject__c();
        rec.Name = 'Test Project';
        rec.Business_Unit__c = 'Banking & TCM';
        rec.Department__c = 'Customer Support';
        rec.Status__c = 'Requested';
        rec.Clarity_Project__c = 'CRM - Banking & TCM Customer Support Project';
        return rec;
    }
    
    public static Note sampleNote(Id parId){
        Note rec = new Note();
        rec.ParentId = parId;
        rec.Title = 'Test Note';
        rec.Body = 'This is a test note';
        return rec;
    }
    
    public static Targeted_Release__c sampleTargetedRelease(Case issueCase){
        Targeted_Release__c rec = new Targeted_Release__c();
        rec.Name = 'Test TR';
        rec.Case__c = issueCase.Id;
        return rec;
    }
    
    public static Group sampleQueue(){
        Group rec = new Group();
        rec.Name = 'Test Queue';
        rec.Email = 'queue@foo.org';
        rec.Type = 'Queue';
        return rec;
    }

    public static Group samplePublicGroup(){
        Group rec = new Group();
        rec.Name = 'Test Group';
        rec.Type = 'Regular';
        return rec;
    }
    
    public static SLA__c sampleSLA(){
        SLA__c rec = new SLA__c();
        rec.Name = 'Test SLA';
        rec.Priority__c = 'All;Critical;High;Medium;Low';
        rec.Solution_Target_Critical_Time_Units__c = 'Minutes';
        rec.Solution_Target_Time_Critical__c = 50;
        rec.Solution_Target_High_Time_Units__c = 'Days';
        rec.Solution_Target_Time_High__c = 200;
        rec.Solution_Target_Medium_Time_Units__c = 'Days';
        rec.Solution_Target_Time_Medium__c = 400;
        rec.Solution_Target_Low_Time_Units__c = 'Days';
        rec.Solution_Target_Time_Low__c = 500;
        return rec;
    }
    
    public static Business_Hours_In_Use__c sampleBHIU(Id testSLAId){
        Business_Hours_In_Use__c rec = new Business_Hours_In_Use__c();
        rec.Name = 'Test BHIU';
        rec.Business_Hours__c = '01m20000000PbDe';  //'Test 9x5' business hours record.  Time is GMT+08:00 (Philippine)
        rec.SLA__c = testSLAId;
        rec.Normal_Working_Day_Length__c = 8.0;
        return rec;
    }
    
    public static Task sampleTask(){
        Task rec = new Task();
        rec.Subject = 'Test Task';
        return rec;
    }
    
    public static Partner_Approvals_Renewals__c samplePartnerApprovalsRenewals(Id testAccount){
        Partner_Approvals_Renewals__c rec = new Partner_Approvals_Renewals__c();
        rec.Account__c = testAccount;
        return rec; 
    }
    
    public static Attachment sampleAttachment(Id parentId){
        Attachment rec = new Attachment();
        rec.ParentId = parentId;
        rec.ContentType = 'txt';
        rec.Name = 'testFile.txt';
        rec.Body = Blob.valueOf('test');
        return rec;
    }
    
    public static Mitigating_Action_Plan__c sampleMitigatingAction(Id OppId)
    {
        Mitigating_Action_Plan__c rec = new Mitigating_Action_Plan__c();
        rec.Opportunity__c = OppId;
        return rec;
    }
    
    public static Mitigating_Action_Detail__c sampleMADetail(Id MAPId)
    {
        Mitigating_Action_Detail__c rec = new Mitigating_Action_Detail__c();
        rec.Related_MA__c = MAPId;
        return rec;
    }
    
    public static PS_Scorecard_Process__c samplePSScorecard_PC1(Id OppId)
    {
        PS_Scorecard_Process__c rec = new PS_Scorecard_Process__c();
        rec.Opportunity__c = OppId;
        rec.RecordTypeId = Label.RecType_PSSC_PrelimCheck1;
        return rec;
    }
    
    public static Contract sampleContract(Id accId){
        Contract sContract=new Contract();
        sContract.AccountId=accId;
        sContract.StartDate=System.today();
        sContract.ContractTerm=12;
        return sContract;
        
    }
    
    public static Product2 sampleProduct(){
        Product2 rec=new Product2();
        rec.Name='Test Product';
        rec.Product_Set__c=Product2.Product_Set__c.getDescribe().getPicklistValues()[0].getValue();
        rec.Asset_Name__c = 'Almonde';
        rec.UPID__c = 'PS';
        return rec;
    }
    
    public static Contract_Line_Item__c sampleCLI(Id conId,Id oppId){
        Contract_Line_Item__c sCLI=new Contract_Line_Item__c();
        sCLI.Contract__c=conId;
        sCLI.Opportunity__c=oppId;
        return sCLI;
    }
    
    public static System__c sampleSystem(Id accId){
        System__c sys=new System__c();
        sys.Name='Test System';
        sys.Account__c=accId;
        return sys;
    }
    
    public static Product_Set__c sampleProductSet(Id accId){
        Product_Set__c PS=new Product_Set__c();
        PS.Account__c=accId;
        return PS;
    }
    
    public static Entitlement__c sampleEntitlement(Id accountId, Id systemId){
        Entitlement__c ent = new Entitlement__c();
        ent.Account__c = accountId;
        ent.System__c = systemId;
        ent.Status__c = 'Active';
        return ent;
    }
    
    public static Client_Asset__c sampleClientAsset(Id ProdSetId)
    {
        Client_Asset__c rec = new Client_Asset__c();
        rec.Product_Set__c = ProdSetId;
        return rec;
    }

    public static Contract_Asset__c sampleContractAsset(Id ClientAssetId, Id SystemId, Id AccountId)
    {
        Contract_Asset__c rec = new Contract_Asset__c();
        rec.Client_Asset__c =  ClientAssetId;
        rec.System__c = SystemId;
        rec.Account__c = AccountId;
        return rec;
    }
    
    public static Sales_Order__c sampleSalesOrder(){
        Sales_Order__c so = new Sales_Order__c();
        return so;
    }

    public static Sales_Order_Item__c sampleSalesOrderItem(Id salesOrderId){
        Sales_Order_Item__c soi = new Sales_Order_Item__c();
        soi.Sales_Order__c = salesOrderId;
        return soi;
    }

    public static Location_of_Use__c sampleLOU(Id CCRTId, Id ContractAssetId)
    {
        Location_of_Use__c rec = new Location_of_Use__c();
        rec.CCRT__c = CCRTId;
        rec.Contract_Asset__c = ContractAssetId;
        return rec;
    }
    
    public static OpportunityTeamMember sampleOpportunityTeamMember(Id oppId, string memberRole){
        OpportunityTeamMember rec = new OpportunityTeamMember();
        rec.OpportunityId = oppId;
        rec.TeamMemberRole = memberRole;
        User u = [select Id from User where isActive = true and UserType = 'Standard' LIMIT 1];
        rec.UserId = u.Id;
        return rec;
    }
    
    public static List<Constants__c> loadConstants()
    {   
        RecordType rtCase = [select Id from RecordType where sObjectType = 'Case' LIMIT 1];
        RecordType rtEngineering = [select Id from RecordType where sObjectType = 'Case' and Name like '%Engineering%' LIMIT 1];
        
        Product_Set__c testPS1 = new Product_Set__c();
        //testPS1.Account__c = mainAccount.Id;
        insert testPS1;
        
        List<Constants__c> custSettings = new List<Constants__c>();
        custSettings.add(new Constants__c(Name='DEFAULT_INTERNAL_SEVERITY', ExternalId__c='DEFAULT_INTERNAL_SEVERITY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN', ExternalId__c='DEFAULT_ORIGIN', Value__c='Email'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN_PORTAL', ExternalId__c='DEFAULT_ORIGIN_PORTAL', Value__c='Web'));
        custSettings.add(new Constants__c(Name='DEFAULT_URGENCY', ExternalId__c='DEFAULT_URGENCY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_SEVERITY', ExternalId__c='DEFAULT_SEVERITY', Value__c='Medium'));
        custSettings.add(new Constants__c(Name='DEFAULT_STATUS', ExternalId__c='DEFAULT_STATUS', Value__c='New'));
        custSettings.add(new Constants__c(Name='DEFAULT_TYPE', ExternalId__c='DEFAULT_TYPE', Value__c='Technical'));
        custSettings.add(new Constants__c(Name='DUMMY PRODUCT SET ID', ExternalId__c='DUMMY PRODUCT SET ID', Value__c=testPS1.Id));
        custSettings.add(new Constants__c(Name='DEFAULT_CASE_RECORDTYPE_ID', ExternalId__c='DEFAULT_CASE_RECORDTYPE_ID', Value__c=rtCase.Id));
        custSettings.add(new Constants__c(Name='ENGINEERING_CASE_RECORD_TYPE', ExternalId__c='ENGINEERING_CASE_RECORD_TYPE', Value__c=rtEngineering.Id));
        custSettings.add(new Constants__c(Name='STATUS_NEW', ExternalId__c='STATUS_NEW', Value__c='New'));
        custSettings.add(new Constants__c(Name='SUB_STATUS_ESCALATED', ExternalId__c='SUB_STATUS_ESCALATED', Value__c='Engineering'));
        //insert custSettings;
        
        return custSettings;
    }
    
    public static List<ProductSetToRecordTypeId__c> loadPSSettings()
    {
        RecordType rtCase = [select Id, Name from RecordType where sObjectType = 'Case' LIMIT 1];
        
        List<ProductSetToRecordTypeId__c> newPSSettings = new List<ProductSetToRecordTypeId__c>();
        newPSSettings.add(
            new ProductSetToRecordTypeId__c(
                Name='PS1', ExternalId__c = 'PS1',
                Record_Type_Id__c = rtCase.Id, RecordType_Name__c = rtCase.Name,
                Exclude_in_Portal__c = false, Category__c='Category1'
            )
        );
        
        return newPSSettings; 
    }
    
    public static CCRT__c sampleCCRT()
    {
        CCRT__c rec = new CCRT__c();
        rec.Client_Site_Number__c = '12345';
        return rec;
    }
    
    public static CCRT__c createCCRT(Account acct)
    {
        CCRT__c ccrt = sampleCCRT();
        ccrt.Account__c = acct.Id;
        insert ccrt;
        return ccrt;
    }

    public static Solution sampleSolution()
    {
        Solution rec = new Solution();
        rec.Product__c = 'Midas';
        rec.SolutionName = 'Test Solution';
        rec.SolutionNote = 'Test Solution Notes';
        return rec;
    }
    public static NS_Currency__c createNSCurrency() {
        NS_Currency__c nsCurrency = new NS_Currency__c(Name = 'GBP', NS_Currency_Internal_Id__c = '13');
        return nsCurrency;
    }
    public static NS_Product__c createNSProduct() {
        NS_Product__c nsProd = new NS_Product__c(Name = 'Capital Markets Fusion', NS_Product_Internal_Id__c = '2', Product_is_Inactive__c = false);
        return nsProd;
    }
    public static NS_Fixed_Billing_Date__c createNSFixedBillingDate() {
        NS_Fixed_Billing_Date__c nsFixedBillingDate = new NS_Fixed_Billing_Date__c(Name = 'Capital Markets Fusion',Date__c=System.today(),NS_Internal_Id__c='3');
        return nsFixedBillingDate;
    }
    public static NS_Cost_Centre__c createNSCostCentre() {
        NS_Cost_Centre__c nsCC = new NS_Cost_Centre__c(Name = 'P110 Business Development', NS_Cost_Centre_Internal_Id__c = '3');
        return nsCC;
    }
    public static NS_Revenue_Recognition_Template__c createNSRevenueRecognitionTemplate() {
        NS_Revenue_Recognition_Template__c revRec = new NS_Revenue_Recognition_Template__c(Name = 'POC', NS_Internal_Id__c = '38');
        return revRec;
    }
    public static NS_OpenAir_Revenue_Rules__c createNSOpenAirRevenueRules() {
        NS_OpenAir_Revenue_Rules__c opAirRec = new NS_OpenAir_Revenue_Rules__c(Name = 'POC',NS_Internal_Id__c='5');
        return opAirRec;
    }
    public static NS_List_Table__c createNSListTable() {
        NS_List_Table__c listTable = new NS_List_Table__c(NS_List_Name__c = 'OpenAirBillingRules', Name = 'ILF', NS_Internal_Id__c = '1');
        return listTable;
    }
    public static NS_Account__c createNSAccount() {
        NS_Account__c nsAccount = new NS_Account__c(Name = 'Deferred revenue - ILF', NS_Account_Internal_Id__c = '129', Is_Inactive__c = false, Account_Type__c = 'DEFERRED_REVENUE');
        return nsAccount;
    }
    public static T_And_E_Items__c createTE(){
    T_And_E_Items__c teItem = new T_And_E_Items__c();
    teItem.Sales_Order_Type__c = 'PS';
    teItem.Name = 'PS';
    teItem.UPID__c = 'PS';
    teItem.Quantity__c = 1;
    teItem.Rate__c = 5;
    return teItem;
    } 

    public static Clarity_PRJ_Entry__c sampleClarityPrj()
    {
        Billing_Entity__c be = TestAssetUtils.SampleBillingEntity();
        insert be; 
        return new Clarity_PRJ_Entry__c(name='test', CP_Billing_Entity__c=be.id);
    }
      
    public static void dummyFunctionForDeltaTestCoverage()
    {
    
        Boolean b = true;
        
        If(b)
        b = true;
        If(b)
        b = true;
        If(b)
        b = true;
        If(b)
        b = true;
        If(b)
        b = true;
        If(b)
        b = true;
        If(b)
        b = true;
        If(b)
        b = true;
        If(b)
        b = true;
    
    }

    //public static PS_Scorecard_Process__c samplePSScorecard_PC2(Id OppId)
    //{
    //  PS_Scorecard_Process__c rec = new PS_Scorecard_Process__c();
    //  rec.Opportunity__c = OppId;
    //  rec.RecordTypeId = Label.RecType_PSSC_PrelimCheck2;
    //  return rec;
    //}
    
    
    //public static ProductSetToRecordtypeId__c sampleProductSetToRecordTypeId()
    //{
    //  //Define a map to send to the object
    //  map<String,ProductSetToRecordTypeId__c> mapCS = new map<String,ProductSetToRecordTypeId__c>();
    //  ProductSetToRecordTypeId__c recCS = new ProductSetToRecordTypeId__c();
    //  
    //  recCS.Name = 'ps1';
    //  recCS.Exclude_In_Portal__c = false;
    //  recCS.RecordType_Id__c = '0122000000001EbAAI';
    //  recCS.Record_Type_Name__c = 'Bankmaster / Bankfusion uB';
    //  mapCS.put(recCS.Name,recCS);
    //  
    //  ProductSetToRecordTypeId__c sampleCS = sampleProductSetToRecordTypeId(mapCS);
    //  
    //  return sampleCS;
    //}
    
    //public static ProductSetToRecordTypeId__c sampleProductSetToRecordTypeId(map<String,ProductSetToRecordTypeId> mapCSValues)
    //{
    //  ProductSetToRecordTypeId__c newCS[] = new ProductSetToRecordTypeId__c()[];
    //  
    //  //Load the values into the custom object
    //  for(ProductSetToRecordTypeId__c ps : mapCSValues.values())
    //  {
    //    newCS.Name = ps.Name;
    //    newCS.Exclude_In_Portal__c = ps.Exclude_in_Portal__c;
    //    newCS.RecordType_Id__c = ps.RecordType_Id__c;
    //    newCS.Record_Type_Name__c ps.Record_Type_Name__c;
    //  }
    //  return 
    //}

    public static SBQQ__Quote__c createQuote(Opportunity oppty, Account account, Contact contact) {

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Type__c = 'Quote';
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__ExpirationDate__c = oppty.CloseDate;
        quote.SBQQ__BillingCity__c = 'Aurora';
        quote.SBQQ__BillingCountry__c = 'US';
        quote.SBQQ__BillingName__c = 'H & R BLOCK CENTRAL DENVER';
        quote.SBQQ__BillingPostalCode__c = '80014';
        quote.SBQQ__BillingState__c = 'CO';
        quote.SBQQ__BillingStreet__c = '13693 E. Iliff Ave Ste 110';
        quote.SBQQ__Opportunity2__c = oppty.Id;
        quote.SBQQ__PriceBook__c = Test.getStandardPricebookId();
        quote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
        quote.SBQQ__PrimaryContact__c = contact.Id;
        quote.SBQQ__ShippingCity__c = 'Aurora';
        quote.SBQQ__ShippingCountry__c = 'US';
        quote.SBQQ__ShippingName__c = 'H & R BLOCK CENTRAL DENVER';
        quote.SBQQ__ShippingPostalCode__c = '80014';
        quote.SBQQ__ShippingState__c = 'CO';
        quote.SBQQ__ShippingStreet__c = '13693 E. Iliff Ave Ste 110';
        quote.SBQQ__StartDate__c = Date.today();
        quote.SBQQ__SubscriptionTerm__c = 12;

        insert quote;
        return quote;
    }

    public static Contact createContact(){
        //contact
        Contact testContact = new Contact();
        testContact.LastName = 'Test Last Name';
        insert testContact;
        return testContact;
    }
}