@isTest
private class test_Contact {

    static testmethod void test_ContactTriggerMethods()
    {
        //Set up test data
        //
        //Not preferable to use existing data.  However, there doesn't seem to be another way to insert both
        //  a contact (non-Setup object) and a user (Setup object) within a test method due to restrictions
        //  from Salesforce
        //
        //User testPortalUser = [select Id, ContactId, EMail, Name, FirstName, LastName, Title, Phone, Fax, Street, State, PostalCode, City, Country, MobilePhone from User where userType = 'PowerCustomerSuccess' and isActive = true LIMIT 1];
        
        User runUser = [select Id,userroleId  from User where Id = :userInfo.getUserId() LIMIT 1];
        
        Account testAcc = TestUtility.sampleAccount();
        insert testAcc;
                
        Contact testContact = TestUtility.sampleContact();
        testContact.MailingStreet = '123 Main Street';
        testContact.MailingCity = 'New York';
        testContact.MailingCountry = 'USA';
        testContact.AccountId = testAcc.Id;
        testContact.Title = '';
        insert testContact;
        
        User testPortalUser;
        System.runAs(runUser)
        {
            testPortalUser = TestUtility.sampleCustPortalUser(testContact);
            testPortalUser.IsActive = true;
           // testPortalUser.userroleId = '00e20000001VBGj';
            insert testPortalUser;
        }
        
        //Contact testContact = [select Id, FirstName, LastName, Email, Title, Phone, MobilePhone, Fax, MailingStreet, MailingState, MailingCity, MailingCountry, MailingPostalCode from Contact where Id = :testPortalUser.ContactId LIMIT 1];
        
        //Run the tests
        Test.startTest();
            testContact.MailingStreet = '42 Wallaby Way';
            testContact.MailingCity = 'Sydney';
            testContact.MailingCountry = 'Australia';
            testContact.Title = 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz';   //test String length
        
            update testContact;
        Test.stopTest();
        
        //Verify the results
        //User resultPortalUser = [select Id, FirstName, LastName, Street, City from User where Id = :testPortalUser.Id];
        //system.assertEquals('42 Wallaby Way',resultPortalUser.Street);
    }

 /*public static testmethod void testupdateTopSolution()
     {
    
        Contact testContact= TestUtility.sampleContact();   
        testContact.FusionInvest_Score__c= 1;
        testContact.FusionCorporate_Score__c = 1;
       // testLead.Area_of_interest__c = 'Corporate Treasury';
        insert testContact;
        Contact testContact1 = [select Id, FusionInvest_Score__c, FusionCorporate_Score__c, TopSolution__c from Contact where Id = :testContact.Id Limit 1];
        
        system.debug('FusionInvest Score = '+testContact1.FusionInvest_Score__c);
        system.assertEquals(testContact1.TopSolution__c ,'FusionCorporate');
        
        testContact.FusionCapital_Score__c= 1;
        testContact.FusionInvest_Score__c= 2;
        testContact.FusionRisk_Score__c= 4;
        update testContact;
        Contact testContact2 = [select Id, FusionInvest_Score__c, FusionCorporate_Score__c, TopSolution__c from Contact where Id = :testContact.Id Limit 1];
        system.debug('FusionInvest Score = '+testContact2.FusionInvest_Score__c);
        system.assertEquals(testContact2.TopSolution__c ,'FusionRisk');
    
    }*/

public static testmethod void testupdateTopNurtureScoring()
     {
    
        Contact testContact= TestUtility.sampleContact();   
        testContact.Nurture1_Score__c= 1;
        testContact.Nurture2_Score__c = 1;
       // testLead.Area_of_interest__c = 'Corporate Treasury';
        insert testContact;
        Contact testContact1 = [select Id, Nurture1_Score__c, Nurture2_Score__c,Nurture3_Score__c, TopSolution__c from Contact where Id = :testContact.Id Limit 1];
        
       // system.debug('FusionInvest Score = '+testContact1.FusionInvest_Score__c);
        system.assertEquals(testContact1.TopSolution__c ,'Nurture1');
        
        testContact.Nurture1_Score__c= 1;
        testContact.Nurture2_Score__c= 2;
        testContact.Nurture3_Score__c= 4;
        testContact.Nurture4_Score__c= 8;
        testContact.Nurture5_Score__c= 12;
        update testContact;
        Contact testContact2 = [select Id, Nurture1_Score__c, Nurture2_Score__c, TopSolution__c from Contact where Id = :testContact.Id Limit 1];
       // system.debug('FusionInvest Score = '+testContact2.FusionInvest_Score__c);
        system.assertEquals(testContact2.TopSolution__c ,'Nurture5');
    
    }

}