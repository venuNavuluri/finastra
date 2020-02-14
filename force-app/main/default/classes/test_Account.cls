@isTest
private class test_Account {
  
    
    public static testmethod void testSetAccountSharing()
    {
        UserRole portalRole = [Select Id From UserRole Where Name = 'CEO' Limit 1];

        //User runUser = [select Id from User where Profile.Name = 'System Administrator' and UserRoleId =: portalRole.Id and  isActive = true LIMIT 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        
        User runUser = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'testSetAccountSharing.finastra@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert runUser;
        //**** Set up the test data ****//
        //Insert a test account
        Account testAcc;
        Contact contact1;
        System.runAs(runUser){
            testAcc = TestUtility.sampleAccount();
            insert testAcc;
            
            //insert contact on account to be a portal contact
            contact1 = TestUtility.sampleContact();
            contact1.accountid = testAcc.Id;
            contact1.FirstName = 'First';
            contact1.email = 'testtest@foo.bar.co';
            insert contact1;
        }
        
        //**** Run the test ****//
        Test.startTest();
            //Insert a test customer portal user - this will update the account and trigger the SetAccountSharing method to run
            User testCPUser = TestUtility.sampleCustPortalUser(contact1);
            insert testCPUser; 
        Test.stopTest();
         
        //**** Verify the test results ****//
        Account acc = [select Id, Owner.UserRoleId from Account where Id = :testAcc.Id limit 1];
        List<UserRole> lPortalRoles = [select Id from UserRole where PortalAccountId = :testAcc.Id and PortalType='CustomerPortal' and ParentRoleId = :acc.Owner.UserRoleId];
        /*To Do - PortalAccountId is not set so AccountTriggerMethods.SetAccountSharing() doesnt set AccountShare
         
         Group RoleGroup = [select Id from Group where RelatedId in :lPortalRoles and Type = 'Role' limit 1];
        List<AccountShare> AccSh = [select Id from AccountShare where AccountId = :testAcc.Id and UserOrGroupId = :RoleGroup.Id];
        system.assert(AccSh.size() >= 1);
        */
    }

    public static testmethod void testUpdateCountryInfo()
    {
        Country__c cntry =  new Country__c(Name='United Kingdom',ExternalId__c='United Kingdom',Code__c='GB',Full_Name__c='UNITED KINGDOM',Region__c='Europe',Sales_Region__c='NEUR',Used__c=true);
        insert cntry;
        Account testAcc = TestUtility.sampleAccount();  
        testAcc.Country__c = 'United Kingdom';
        insert testAcc;
        Account testAccResult1 = [select Id, Country__c, Sales_Region__c from Account where Id = :testAcc.Id Limit 1];
        system.debug('Sales Region = '+testAccResult1.Sales_Region__c);
        system.assertEquals(testAccResult1.Sales_Region__c,'NEUR');
        
        testAcc.Country__c = null;
        update testAcc;
        Account testAccResult2 = [select Id, Country__c, Sales_Region__c from Account where Id = :testAcc.Id Limit 1];
        system.debug('Sales Region = '+testAccResult2.Sales_Region__c);
        system.assertEquals(testAccResult2.Sales_Region__c,null);
    }   

   private static testmethod void testAccountOwnerChangeAddSharing_new()
   {
        //**** Set up the test data ****//
        
       UserRole ur = new UserRole(Name = 'CEO');
       insert ur;
       
       UserRole exUr = [select Id from UserRole where PortalType='CustomerPortal' limit 1];//new UserRole(Name = 'Executive');
       //insert exUr;
       
       User adminUser = TestUtils.getAdminUser('admin');
       adminUser.UserRoleId = ur.Id;
       
       System.runAs(adminUser){
       
            Account newAcc = TestUtility.sampleAccount();
            newAcc.Name = 'test acc';
            newAcc.Site = 'hdhd';
            insert newAcc;
            Account newAcc2 = TestUtility.sampleAccount();
            newAcc2.Name = 'test acc 2';
            insert newAcc2;
        /*  
            testCont.email = 'testtest@foo.bar.co';     
            insert testCont;
            Contact testCont2 = TestUtility.sampleContact();
            testCont2.AccountId = newAcc2.Id;
            testCont2.LastName = 'heheh2';
            testCont2.FirstName = 'First2';
            testCont2.email = 'test2test2@foo.bar.co';      
            insert testCont2;           
    */
        // Find an active portal user -> related contact -> account they work for -> the ownerId of that account && isActive
        //user testUser = [select id, usertype, contactId, contact.AccountId, contact.account.ownerId from user where userType = 'PowerCustomerSuccess' and isactive=true and contactId!=null and contact.account.owner.isActive=true limit 1]
        
        Contact portalContact1 = TestUtils.getContact(newAcc, 'PortalContact1');
        insert portalContact1;
       
        User testUser = TestUtils.getCustomerPortalUser('test.portal1@gmail.com', portalContact1);
        testUser.ProfileId = [select id from Profile where Name = 'Customer Community Banking User'].Id;
   //     testUser.UserRoleId = exUr.Id;
        testUser.Alias = 'por1user';
        testUser.email ='test@gmail.com'; 
        testUser.portalRole = 'Executive';
        insert testUser;
       
        // DJ 6/6/2013. This is not best practice as it assumes that such a user exists, but
        // since we can't mix DML we can't create a user in advance
        
        // We're going to change the ownership to this user
        //user otherUser = [select id from user where UserType='Standard' and id!=:testUser.id and userRoleId!=null limit 1];
        
        
       
        User otherUser = TestUtils.getStandardInternalUser('stduser');
        otherUser.UserRoleId = ur.Id;
        insert otherUser;
                
        Contact testCont = TestUtility.sampleContact();
        testCont.AccountId = testUser.contact.AccountId;
        testCont.LastName = 'heheh';
        testCont.FirstName = 'First';
        testCont.email = 'testtest@foo.bar.co'; 
        insert testCont;
       
        ID testUserAccountId = [select Id, contact.AccountId from User where Id =: testUser.Id].contact.AccountId;
        
        account testAcc = [select id, name, site from account where id = :testUserAccountId];
        
        Accounts_Supported__c accSupp = TestUtility.sampleAccountsSupported(testCont, newAcc);
        insert accSupp; 
    
        Date myDate = date.newinstance(2010, 11, 17);
        Date myDate1 = date.newinstance(2012, 05, 27);
        Opportunity o1 = TestUtility.sampleOpportunity();
        o1.StageName = 'Agree';
        o1.AccountId = testAcc.Id;
        o1.CloseDate = myDate;
        insert o1;
        o1.CloseDate = myDate1;
        update o1;
       
        RecordType rec = [Select id, name from RecordType where name = 'Direct Master Credit' limit 1];
        System.debug('Value of Recordtype' + rec);
        Com_Splits__c com1 = new Com_Splits__c(Opportunity__c = o1.Id, RecordTypeId = rec.id); 
        insert com1;
        
        //Get the number of shares on the account before the ownership change
        //List<AccountShare> beforeAccShares = [select Id from AccountShare where AccountId = :newAcc.Id];
        
        
        //**** Run the test ****//
        Test.startTest();
            testAcc.Ownerid = otherUser.Id; //OwnerId is a full SFDC user
            update testAcc;
        Test.stopTest();
        
        //**** Verify the results ****//
        
        //Get the number of shares after the ownership change.  This should be the same as the before count.
        List<AccountShare> afterAccShares = [select Id from AccountShare where AccountId = :testAcc.Id];
        //System.assertEquals(beforeAccShares.size(),afterAccShares.size());
        System.assert(afterAccShares.size()>0);
       }
     }
     
     private static testmethod void testProjectInformation()
     {
        //Set up the data for the test
        Account a = TestUtility.sampleAccount();
        insert a;
        
        Project_Information__c p = TestUtility.sampleProjectInformation(a);
        p.Name = 'PRJNONE';
        insert p;
        
        String err = '';
        
        //Perform the test
        Test.startTest();
        try{
            delete p;
        }catch(Exception e){
            err = e.getMessage();
        }
        Test.stopTest();
        
        //Verify the expected results
        System.Assert(err.contains(Label.Project_Information_NONE_error));
     }

     private static testmethod void testDeleteHealthIndex()
     {
        //Set up the data for the test
        Account a = TestUtility.sampleAccount();
        insert a;
        Account_Rollup__c arpParent = new Account_Rollup__c(Name = 'Test', Account__c = a.Id);
        insert arpParent;
        delete a;
     }
}