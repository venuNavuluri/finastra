@isTest
private class test_CommunityServiceController {
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
        insert con;
        return con;
    }

    private static User getUser(Contact con) {
        //Profile p = [select Id from Profile where UserType = 'Standard' LIMIT 1];
        Profile standardProf = [select id from profile where name='Customer Community Banking User']; 
        String roleId = [select id from userrole where name = 'Erste Group Bank AG2 Customer Executive' LIMIT 1].Id;
        User su = new User(alias = 'comm', email='community@test.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = standardProf.Id, UserRoleId = roleId,
        timezonesidkey='Europe/London', username='community'+datetime.now().millisecond()+'@d.com', contactId=con.Id);

        //insert su;
        return su;
    }

    public static User systemUser(){
        //Get a standard user profile
        Profile p = [select Id from Profile where UserType = 'Standard' and PermissionsChatterOwnGroups =true LIMIT 1];
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
        u.userRoleId=[select id from userrole  where name like '%system admin%'][0].id;
        insert u;
        return u;      
    }

    @isTest static void test_method_one() {
        User u = systemUser();
         
        System.runAs (new user(ID = UserInfo.getUserID())) {

        Account acct = new Account();
        acct = getAccount();
        system.debug('VC: ' +acct);
        Contact con = getContact(acct);
        User su = getUser(con);
        
        CollaborationGroup  collab = new CollaborationGroup();
        collab.name = 'test group'+datetime.now().millisecond();
        collab.CollaborationType = 'Public';
        collab.ownerid = u.id;
        insert collab;

        Community_Homepage_CMS__c CMSContent = New Community_Homepage_CMS__c();
        CMSContent.Is_Lead_Feature__c = true;
        CMSContent.Active__c = true;
        CMSContent.Title__c = 'Test Lead Content article';
        CMSContent.Body_Copy__c = 'Test Lead Body copy';
        CMSContent.Page_to_Display__c = 'Services';
        insert CMSContent;

        Community_Feature_Hyperlink__c CMSHyperLinks = New Community_Feature_Hyperlink__c();
        CMSHyperLinks.Knowledge_Homepage_Feature__c = CMSContent.Id;
        CMSHyperLinks.Hyperlink_Text__c = 'this is the link text';
        CMSHyperLinks.URL__c = 'http://www.google.com';
        insert CMSHyperLinks;

        Community_Homepage_CMS__c CMSContent2 = New Community_Homepage_CMS__c();
        CMSContent2.Is_Lead_Feature__c = false;
        CMSContent2.Active__c = true;
        CMSContent2.Title__c = 'Test Content article';
        CMSContent2.Body_Copy__c = 'Test Body copy';
        CMSContent2.Page_to_Display__c = 'Services';
        insert CMSContent2;

        Community_Header_CTA__c CTA = New Community_Header_CTA__c();
        CTA.CTA_Help_Text__c = 'test';
        CTA.CTA_Text__c = 'test';
        CTA.CTA_URL__c = 'test';
        CTA.CTA_Page_To_Display__c='Services';
        insert CTA;
        
        

        Test.startTest();
        //System.runAs(su) { 
            community_MI_ServicesController cont = new community_MI_ServicesController();
            PageReference testPR = Page.community_MI_Services;
            Test.setCurrentPage(testPR);
            string returnStr;
            cont.JoinLeaveGroupCssClass = 'fa fa-check join';
            cont.JoinLeaveGroupName = 'test';

            returnStr = community_MI_ServicesController.joinLeaveGroup(collab.Id,'Join Group');

            
       // }
        Test.stopTest();
            }
    }
    
        
}