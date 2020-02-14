@isTest
private with sharing class UserTriggerMethods_Test{

    public static testMethod User createTestPortalUser(){
        User runUser = [select Id from User where Id != :userInfo.getUserId() and userType = 'Standard' and UserRoleId != null and isActive = true LIMIT 1];
        //User runUser = TestUtility.sampleUser();
        Account a;
        Contact c;
        User testUser;
        System.runAs(runUser){
            a = TestUtility.sampleAccount();
            a.ownerId = runUser.Id;
            insert a;
            c = TestUtility.sampleContact();
            c.AccountId = a.Id;
            insert c;

        }
        testUser = TestUtility.sampleCustPortalUser(c);
        insert testUser;
        
        return testUser;
    }
    
    /*  ERRORS with MIXED DML OPERATION - Need to refactor later
    public static testmethod void testUserUpdateToContact()
    {
        //User testUser = [Select c.Id,c.contactId,c.Name from User c  where c.Name = 'Common Portal (Kim)' and contactid!=null];
        User testUser = createTestPortalUser();
        testUser.Email='test@test.com';
        testUser.Phone='123123';
        
        Test.startTest();
            update testUser;

            testUser.IsActive = false;
            update testUser;
        Test.stopTest();
    }    
    */

    //ERRORS with MIXED DML OPERATION - Need to refactor later
    public static testmethod void testUserUpdateToContact_Map(){
        //User testUser = [Select c.Id,c.contactId,c.Name from User c  where c.Name = 'Common Portal (Kim)' and contactid!=null];
        User testUser = createTestPortalUser();
        User testAdmin = [SELECT Id, name, IsActive FROM User WHERE profile.name = 'System Administrator' and name != '' and isactive = true LIMIT 1];
        testUser.Email = 'test@test.com';
        testUser.Phone = '123123';
        Test.startTest();
        system.runas(testAdmin){
            update testUser;
        }
        Map<ID, User> mapUser = new Map<ID, User>([Select c.Id, c.contactId, c.Name, c.LastName, c.Email, c.FirstName, c.Title, c.Phone, c.Fax, c.Street, c.State, c.PostalCode, c.City, c.Country, c.MobilePhone from User c where c.Name like '%Kim%' and contactid != null]);

        UserTriggerMethods.UserUpdateToContact(mapUser, mapUser);
        Test.stopTest();
    }

    
    
    /*  ERRORS with MIXED DML OPERATION - Need to refactor later
    public static testmethod void testUpdateUserContactLicenseFlag_Map()
    {
        //User testUser = [Select c.Id, c.ProfileId, c.IsActive, c.contactId, c.Name, c.LastName, c.Email, c.FirstName, c.Title, c.Phone, c.Fax, c.Street, c.State, c.PostalCode, c.City, c.Country, c.MobilePhone from User c  where c.Name = 'Common Portal (Kim)' and contactid!=null];
        User testUser = createTestPortalUser();
        Contact cont = [Select id,Has_Portal_User__c, Accountid from Contact where id= :testUser.Contactid ];
        System.debug('value of ' + cont);
        cont.Has_Portal_User__c = false;
        update cont;      
        
        Map<ID, User> mapUser = new Map<ID, User>([Select c.Id, c.ProfileId, c.IsActive, c.contactId, c.Name, c.LastName, c.Email, c.FirstName, c.Title, c.Phone, c.Fax, c.Street, c.State, c.PostalCode, c.City, c.Country, c.MobilePhone from User c  where c.Name = 'Common Portal (Kim)' and contactid!=null]);
        for(Id CurrID : mapUser.keyset())
            mapUser.get(CurrID).IsActive = false;
        System.debug('value of status' + mapUser);
        Update mapUser.values();
        
        Map<ID, User> mapUser1 = new Map<ID, User>([Select c.Id, c.ProfileId, c.IsActive, c.contactId, c.Name, c.LastName, c.Email, c.FirstName, c.Title, c.Phone, c.Fax, c.Street, c.State, c.PostalCode, c.City, c.Country, c.MobilePhone from User c  where c.Name = 'Common Portal (Kim)' and contactid!=null]);
        for(Id CurrID : mapUser1.keyset())
            mapUser1.get(CurrID).IsActive = true;
        System.debug('value of status' + mapUser1);
        Update  mapUser1.values();
        
        UserTriggerMethods.UpdateUserContactLicenseFlag(mapUser, mapUser1);
        UserTriggerMethods.UpdateUserContactLicenseFlag(mapUser1, mapUser);
        
    }
    */

    public static testmethod void testPortalUserCreated(){
//User testUser = [Select c.Id,c.contactId,c.Name from User c  where c.Name = 'Common Portal (Kim)' and contactid!=null];
        User testUser = createTestPortalUser();

        List<User> testUsers = new List<User>();
        testUsers.add(testUser);
        UserTriggerMethods.PortalUserCreated(testUsers);
    }

    public static testMethod void validateContactTrigger(){
//Contact myContact = [select Id, email, name, Title, FirstName, LastName, phone, Fax, MobilePhone, MailingStreet, MailingState, MailingCity, MailingCountry, MailingPostalCode from Contact where Name = 'Common Portal (Kim)'];
        Contact myContact = TestUtility.sampleContact();
        insert myContact;
        myContact.email = 'updatedemail@testing.org';
        myContact.Title = 'title';
        myContact.FirstName = 'firstname';
        myContact.LastName = 'lastname';
        myContact.phone = '123';
        myContact.Fax = '456';
        myContact.MobilePhone = '789';
        myContact.MailingStreet = 'abc';
        myContact.MailingState = 'def';
        myContact.MailingCity = 'ghi';
        myContact.MailingCountry = 'jkl';
        myContact.MailingPostalCode = 'xyz';

        update myContact;
    }

}