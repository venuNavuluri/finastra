@isTest 
private class test_communityMiHome {

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
        custSettings.add(new Constants__c(Name='CommunityURL', ExternalId__c='CommunityURL', Value__c='https://partialtes-misyslive.cs17.force.com/SupportCommunity/'));
        //insert custSettings;
        
        return custSettings;
    }
    
        public static Entitlement__c sampleEntitlement(Id accountId, Id systemId){
            Entitlement__c ent = new Entitlement__c();
            ent.Account__c = accountId;
            ent.System__c = systemId;
            ent.Status__c = 'Active';
            return ent;
        }
    
    
     private static Map<String,RecordType> getRecordTypeId() {
        // Create test data (a new Account and contact)
        Map<String,RecordType> recordTypesByName = new Map<String,RecordType>();
        for (List<RecordType> recordTypes :  [SELECT Id, Name FROM RecordType]){
           for (RecordType recordType : recordTypes){
               recordTypesByName.put(recordType.Name, recordType);
           }
        }
        return recordTypesByName;
    }
    private static Account getAccount() {
        Map<String,RecordType> recordTypesByName = getRecordTypeId();
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.recordTypeId = recordTypesByName.get('Finastra Customer').Id;
        acct.Region__c = 'Europe';
        acct.site = 'test site';
        acct.type = 'Customer';
        acct.Country__c = 'United Kingdom';
        insert acct;

        return acct;
    }

    private static contact getContact(Account acct) {
        Map<String,RecordType> recordTypesByName = getRecordTypeId();
        Contact con = New Contact();
        con.Lastname = 'Testing';
        con.RecordTypeId = recordTypesByName.get('Customer Portal').Id;
        con.AccountId = acct.Id;
        con.email = 'community@test.com';
        con.contact_type__c = 'Customer';
        con.Inactive_Contact__c = false;
        insert con;
        return con;
    }


    private static User getUser(Contact con) {
        //Profile standardProf = [select Id from Profile where UserType = 'Standard' LIMIT 1];
        Profile standardProf = [select id from profile where name='Customer Community Banking User']; 
        String roleId = [select id from userrole where name = 'Erste Group Bank AG2 Customer Executive' LIMIT 1].Id;
        system.debug('@@@@@@@@@@@@role id:' + roleId);
        User su = new User(alias = 'comm', email='community@test.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = standardProf.Id, 
        timezonesidkey='Europe/London', username='dummy'+datetime.now().millisecond()+'@d.com', contactId=con.Id);

        insert su;
        return su;
    }

    private static Product_Set__c setUpProductSet(Id acctId, Id pvmId, Id uId)
    {
        Product_Set__c ps1 = TestUtility.sampleProductSet(acctId);
        ps1.Name = 'Almonde';
        ps1.Product_Version_Master__c = pvmId;
        ps1.Customer_Advocate__c = uId;
        insert ps1;
        system.debug('test_ProductSetToAccountRollUpManager ps1='+ps1);
        system.debug('#####support date:' + ps1.Standard_Support__c);
        return ps1;
    }

    private static Product_version_Master__c setUpProductVersionMaster()
    {
        Product_version_Master__c pvm = New Product_version_Master__c();
        pvm.name = 'test';
        pvm.Product_Family__c = 'Fusion Banking';
        pvm.Standard_Support__c = 'Oct-07';
        date supportDate = date.newinstance(2016, 5, 17);
        pvm.Standard_Support_Date__c = supportDate.addMonths(6);
        pvm.Sustaining_Support_Date__c = supportDate.addMonths(16);
        pvm.Technical_Support_Date__c = supportDate.addMonths(26);
        insert pvm;
        return pvm;
    }

    private static System__c setUpSystem(Id acctId)
    {
        System__c sys1 = TestUtility.sampleSystem(acctId);
        sys1.Environment2__c = 'PROD';
        insert sys1;
        system.debug('test_ProductSetToAccountRollUpManager sys1='+sys1);
        return sys1;        
    }   
    
    private static Entitlement__c setUpEntitlement(Id acctId, Id sysId, Id psId)
    {
        Entitlement__c ent1 = sampleEntitlement(acctId, sysId);
        ent1.Product_Set__c = psId;
        insert ent1;
        system.debug('test_ProductSetToAccountRollUpManager ent1='+ent1);
        return ent1;
    }
    public static User systemUser(){
        //Get a standard user profile
        Profile p = [select Id from Profile where UserType = 'Standard' LIMIT 1];
        //Create the User and set defaults
        User u = new User();
        u.LastName = 'Dummy';
        u.Alias = 'ddum1234';
        u.Email = 'dummy@d.com';
        u.Username = 'testCommunityMiHome.finastra@test.com';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey = 'America/Panama';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';
        //insert u; /* doesn't need to be inserted to be used, but will cause mixed DML error */
        return u;      
    }
    
    @isTest 
    static void test_method_one() {

        User u = systemUser();

        List<Constants__c> custSettings = loadConstants();
        insert custSettings;

        Account acct = getAccount();

        Contact con = getContact(acct);

        User su = getUser(con);

        Product_version_Master__c pvm1 = setUpProductVersionMaster();
        Product_Set__c ps1 = setUpProductSet(acct.Id, pvm1.Id, u.Id);
        //ps1.Customer_Advocate__c = u.Id;
        //update ps1;

        Community_Homepage_CMS__c CMSContent = New Community_Homepage_CMS__c();
        CMSContent.Is_Lead_Feature__c = true;
        CMSContent.Active__c = true;
        CMSContent.Title__c = 'Test Lead Content article';
        CMSContent.Body_Copy__c = 'Test Lead Body copy';
        CMSContent.Page_to_Display__c = 'Home';
        insert CMSContent;

        Community_Feature_Hyperlink__c CMSHyperLinks = New Community_Feature_Hyperlink__c();
        CMSHyperLinks.Knowledge_Homepage_Feature__c = CMSContent.Id;
        CMSHyperLinks.Hyperlink_Text__c = 'this is the link text';
        CMSHyperLinks.URL__c = 'http://www.google.com';
        insert CMSHyperLinks;

        Community_Header_CTA__c CTA = New Community_Header_CTA__c();
        CTA.CTA_Help_Text__c = 'test';
        CTA.CTA_Text__c = 'test';
        CTA.CTA_URL__c = 'test';
        CTA.CTA_Page_To_Display__c='Home';
        insert CTA;

        Test.startTest();
                
        System.runAs(su) { 
            
            PageReference testPR = Page.community_MI_Home;
            Test.setCurrentPage(testPR);
            community_MI_HomeController cont = New community_MI_HomeController();
            cont.disclaimerCheck();
            testPR.getParameters().put('myParam', ps1.Id+'-Technical Support');
            cont.serviceCheck();
        }
    }
    
    
    
}