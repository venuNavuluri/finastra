@isTest
public class test_community_CaseListingController {

    private static User getUser(Contact con) {
        Profile standardProf = [select Id from Profile where UserType = 'Standard' LIMIT 1];
        String roleId = [select id from userrole where name = 'Erste Group Bank AG2 Customer Executive' LIMIT 1].Id;
        User su = new User(alias = 'comm', email='community2b@test.com', 
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                           localesidkey='en_US', profileid = standardProf.Id, 
                           timezonesidkey='Europe/London', username='community@test.com', contactId=con.Id);
        
        insert su;
        return su;
    }
    
    public class cHistories {
        Public String createdDate {get;set;}
        Public String createdBy{get;set;}
        Public String action {get;set;}
        Public String fieldName{get;set;}
        Public String oldValue {get;set;}
        Public String newValue {get;set;}
    }

    @isTest static void test_method_one() {
        // Implement test code
        Map<String,RecordType> recordTypesByName = new Map<String,RecordType>();
        for (List<RecordType> recordTypes :  [SELECT Id, Name FROM RecordType]){
           for (RecordType recordType : recordTypes){
               recordTypesByName.put(recordType.Name, recordType);
           }
        }
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.recordTypeId = recordTypesByName.get('Finastra Customer').Id;
        acct.Region__c = 'Europe';
        acct.site = 'test site';
        acct.type = 'Customer';
        acct.Country__c = 'United Kingdom';
        insert acct;
        
        Contact con = New Contact();
        con.Lastname = 'Testing';
        con.RecordTypeId = recordTypesByName.get('Customer Portal').Id;
        con.AccountId = acct.Id;
        con.email = 'community@test.com';
        insert con;
       
        Profile standardProf = [select id from profile where name='Customer Community BANKING User']; 
        String roleId = [select id from userrole where name = 'Erste Group Bank AG2 Customer Executive' LIMIT 1].Id;
        
        User su = new User(alias = 'comm', email='community@test.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = standardProf.Id, 
        timezonesidkey='Europe/London', username='community@test.com', contactId=con.Id);
        insert su;
  
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
        insert u;
          

        //User u = TestUtils.getStandardInternalUser('testUT_1');
        //insert u;
        // User su = getUser(con);
        
        System__c sys = TestUtility.createSystem(acct);
        Case cs = TestUtils.getCase(acct, con);
        cs.recordtypeId = recordTypesByName.get('Almonde').Id;
        insert cs;

        
        CaseComment cc = TestUtils.getCaseComment(cs);
        insert cc;

        Attachment att = TestUtils.getAttachment(cs.Id);
        insert att;

        //set up cases for various recordtypes
        List<Case> cases = new List<Case>();

        Case csKondor = TestUtils.getCase(acct, con);
        csKondor.recordtypeId = recordTypesByName.get('Kondor').Id;
        //csKondor.ownerId = u.Id;
        cases.add(csKondor);
        
        Case csDigital = TestUtils.getCase(acct, con);
        csDigital.recordtypeId = recordTypesByName.get('Digital Channels').Id;
        //csDigital.ownerId = u.Id;
        cases.add(csDigital);
        
        Case csFusion = TestUtils.getCase(acct, con);
        csFusion.recordtypeId = recordTypesByName.get('FusionBanking (Lending)').Id;
        //csFusion.ownerId = u.Id;
        cases.add(csFusion);
        
        Case csSophis = TestUtils.getCase(acct, con);
        csSophis.recordtypeId = recordTypesByName.get('Misys Sophis').Id;
        //csSophis.ownerId = u.Id;
        cases.add(csSophis);

        Case csPremium = TestUtils.getCase(acct, con);
        csPremium.recordtypeId = recordTypesByName.get('Premium Support Services').Id;
        //csPremium.ownerId = u.Id;
        cases.add(csPremium);

        insert cases;
/*
          
        cs.System_Status__c = 'test';
        cs.Self_Service_Product__c = 'Bankmaster';
        cs.Product_Version__c = '4.14.14';
        cs.Type = 'Problem';
        cs.Case_Category__c = 'Defect';
        cs.Triage_Status__c = 'In Triage';
        cs.Triage_By__c = u.Id;
        cs.Workaround_Provided__c = 'No';
        cs.Severity__c = 'High';
        cs.Subject = 'testing';
        cs.Case_Comment_Last_Updated__c = system.now();
        cs.Sub_Status__c = 'Development';
        cs.Status = 'Assigned';
        update cs;
     */   
        CaseHistory ch = New CaseHistory();
        ch.field = 'Self_Service_Product__c';
        ch.CaseId = cs.Id;
        insert ch;
        
        CaseHistory ch1 = New CaseHistory();
        ch1.field = 'System_Status__c';
        ch1.CaseId = cs.Id;
        insert ch1;
        
        CaseHistory ch2 = New CaseHistory();
        ch2.field = 'Product_Version__c';
        ch2.CaseId = cs.Id;
        insert ch2;
        
        CaseHistory ch3 = New CaseHistory();
        ch3.field = 'Type';
        ch3.CaseId = cs.Id;
        insert ch3;
        
        CaseHistory ch4 = New CaseHistory();
        ch4.field = 'Triage_Status__c';
        ch4.CaseId = cs.Id;
        insert ch4;
        
        CaseHistory ch5 = New CaseHistory();
        ch5.field = 'Severity__c';
        ch5.CaseId = cs.Id;
        insert ch5;
        
        CaseHistory ch6 = New CaseHistory();
        ch6.field = 'Sub_Status__c';
        ch6.CaseId = cs.Id;
        insert ch6;
        
        CaseHistory ch7 = New CaseHistory();
        ch7.field = 'Case_Category__c';
        ch7.CaseId = cs.Id;
        insert ch7;
        
        CaseHistory ch8 = New CaseHistory();
        ch8.field = 'Status';
        ch8.CaseId = cs.Id;
        insert ch8;
        
        CaseHistory ch9 = New CaseHistory();
        ch9.field = 'Subject';
        ch9.CaseId = cs.Id;
        insert ch9;
        
        CaseHistory ch10 = New CaseHistory();
        ch10.field = 'Workaround_Provided__c';
        ch10.CaseId = cs.Id;
        insert ch10;
        
        CaseHistory ch11 = New CaseHistory();
        ch11.field = 'Case_Comment_Last_Updated__c';
        ch11.CaseId = cs.Id;
        insert ch11;
       
        //su.UserRoleId = roleId;
        //update su;
        //TestUtility oUtil = TestUtility.getInstance();
        //oUtil.isTestRunning = true;
        Test.startTest();
        System.runAs(su) { 
            System.debug('Current User: ' + UserInfo.getUserName());
            pageReference pageRef = Page.Community_CaseListing;
            community_CaseListingController controller = New community_CaseListingController();
            //controller.previous();
            //controller.next();
            //controller.last();
            //controller.First();
            controller.selectedCaseOption = 'Closed';
            controller.GetCases();
            controller.Filter();
            
            pageReference pageRef2 = Page.Community_CaseListing;
            community_CaseListingController controller2 = New community_CaseListingController();
            controller2.selectedCaseOption = 'MyOpen';
            controller2.RoleName = 'Erste Group Bank AG2 Customer Executive';
            controller2.GetCases();
            
            pageReference pageRef3 = Page.Community_CaseListing;
            community_CaseListingController controller3 = New community_CaseListingController();
            controller3.selectedCaseOption = 'AllOpen';
            controller3.RoleName = 'Erste Group Bank AG2 Customer Executive';
            controller3.GetCases();
            
            pageReference pageRef4 = Page.Community_CaseListing;
            community_CaseListingController controller4 = New community_CaseListingController();
            controller4.selectedCaseOption = 'AllClosed';
            controller4.RoleName = 'Erste Group Bank AG2 Customer Executive';
            controller4.GetCases();
            
            pageReference pageRef5 = Page.Community_CaseListing;
            community_CaseListingController controller5 = New community_CaseListingController();
            controller5.selectedCaseOption = 'MyClosed';
            controller5.RoleName = 'Erste Group Bank AG2 Customer Executive';
            controller5.GetCases();

            pageReference printPageRef = Page.community_CaseListingPrintPage;
            community_CaseListingController printController = New community_CaseListingController();
            

            pageReference pageDetailsKondor = Page.community_CaseDetails;
            System.debug('Case Id: ' + csKondor.Id);
            ApexPages.StandardController scKondor = new ApexPages.standardController(csKondor);
            Community_CaseViewExtension conDetailsKondor = New Community_CaseViewExtension(scKondor);

            pageReference pageDetailsDC = Page.community_CaseDetails;
            ApexPages.StandardController scDigital = new ApexPages.standardController(csDigital);
            Community_CaseViewExtension conDetailsDC = New Community_CaseViewExtension(scDigital);
           
            
   
            pageReference pageDetailsSophis = Page.community_CaseDetails;
            ApexPages.StandardController scSophis = new ApexPages.standardController(csSophis);
            Community_CaseViewExtension conDetailsSophis = New Community_CaseViewExtension(scSophis);

            pageReference pageDetailsFusion = Page.community_CaseDetails;
            ApexPages.StandardController scFusion = new ApexPages.standardController(csFusion);
            Community_CaseViewExtension conDetailsFusion = New Community_CaseViewExtension(scFusion);

            pageReference pageDetailsAll = Page.community_CaseDetails;
            System.debug('Case Id: ' + cs.Id);
            ApexPages.StandardController sc = new ApexPages.standardController(cs);
            Community_CaseViewExtension conDetailsAll = New Community_CaseViewExtension(sc);
            conDetailsAll.FindArticle();
            conDetailsAll.AddComment();
            conDetailsAll.AttachFile();
            conDetailsAll.save();
            conDetailsAll.edit();
            conDetailsAll.cancel();
                    
            pageReference pageAttachment = Page.community_ViewAttachment;
            ApexPages.currentPage().getParameters().put('AttId',att.Id);
            community_ViewAttachmentController attachmentController = New community_ViewAttachmentController();
            
            formatDateTimeController comp = new formatDateTimeController();
            comp.dateTimeValue = datetime.Now();
            System.assertEquals(comp.getTimeZoneValue(), datetime.Now().format('yyyy/MM/dd HH:mm'));
            
        }
        
        Test.stopTest();
        }
    
    
    
}