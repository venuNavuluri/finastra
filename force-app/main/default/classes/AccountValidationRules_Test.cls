/**
•	@file Name : AccountValidationRulesTest.cls
•	@description : Class to test validations rules on Account Obje
•	@author : Ramesh Thulasi
•	@last Modified By : Ramesh Thulasi
**/

@isTest 
private class AccountValidationRules_Test {
    private static final map<String,Profile> profileMap=TestDataFactory.getProfileMap();
    private static final String ONLY_SOSS_USERS_CAN_UPDATE_OWNER_ERROR_MSG='Only SOSS users can update Account Owner.';
    @testSetup static void setup() {
        // init Bypass validation custom property
        List<Bypass_Validations__c> valCusSettings = new List<Bypass_Validations__c>();
        
        List<User> userList=TestDataFactory.createUserList(true);
        User adminUser=TestDataFactory.getProfileUser(profileMap.get(Constants.SYS_ADMIN_PROFILE).Id); 
         User salesUser = TestDataFactory.getProfileUser(
            profileMap.get(Constants.SALES_USR_PROFILE).Id
        );
        // set custom property for admin user
        System.runAs(adminUser) {
            // flag defaults to false means validation rules are NOT bypassed 
            valCusSettings.add(new Bypass_Validations__c(SetupOwnerId=salesUser.id, Disable__c=false));
            insert valCusSettings;
        }                
    }

    /**
    * @description :  Test method to test 'Only_SOSS_Users_Can_Update_Owner' validation rule. Validation is fired when conditions are met.
    * @Rule Name: Only_SOSS_Users_Can_Update_Owner
    * @Rule Definition: 
        AND (
            NOT($Setup.Bypass_Validations__c.Disable__c), 
            $Profile.Name <> "SOSS User",
			$Profile.Name <> "System Administrator",
			ISCHANGED(OwnerId)
        )   
    * @autho : Ramesh Thulasi
    * @param : None
    * @return : None
    **/
    private static testMethod void test_OnlySOSSUsersCanUpdateOwner_PositiveTest() {
        User stdUser=TestDataFactory.getProfileUser(profileMap.get(Constants.STD_USR_PROFILE).Id); 
        User salesUser = TestDataFactory.getProfileUser(
            profileMap.get(Constants.SALES_USR_PROFILE).Id
        );
        System.runAs(salesUser){
            List<Account> accs = TestDataFactory.createAccounts(1, true);
            Account acc = accs.get(0);
            acc.OwnerId=stdUser.id;
            Test.startTest();
            Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(acc,ONLY_SOSS_USERS_CAN_UPDATE_OWNER_ERROR_MSG);
            Test.stopTest();
            System.assertEquals(true,containsValidationMsg,TestDataFactory.DML_VALIDATION_ERROR_MSG);
        } 
    }
    /**
    * @description :  Test method to test 'Only_SOSS_Users_Can_Update_Owner' validation rule. Validation is NOT fired when conditions are NOT met.
    * @Rule Name: Only_SOSS_Users_Can_Update_Owner
    * @Rule Definition: 
        AND (
            NOT($Setup.Bypass_Validations__c.Disable__c), 
            $Profile.Name <> "SOSS User",
			$Profile.Name <> "System Administrator",
			ISCHANGED(OwnerId)
        )   
    * @autho : Ramesh Thulasi
    * @param : None
    * @return : None
    **/
    private static testMethod void test_OnlySOSSUsersCanUpdateOwner_AdminUser_NegativeTest() {
        User stdUser=TestDataFactory.getProfileUser(profileMap.get(Constants.STD_USR_PROFILE).Id); 
        User adminUser=TestDataFactory.getProfileUser(profileMap.get(Constants.SYS_ADMIN_PROFILE).Id); 
        System.runAs(adminUser){
            List<Account> accs = TestDataFactory.createAccounts(1, true);
            Account acc = accs.get(0);
            acc.OwnerId=stdUser.id;
            Test.startTest();
            Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(acc,ONLY_SOSS_USERS_CAN_UPDATE_OWNER_ERROR_MSG);
            Test.stopTest();
            System.assertEquals(false,containsValidationMsg,TestDataFactory.NO_DML_VALIDATION_ERROR_MSG);
        } 
    }
    /**
    * @description :  Test method to test 'Only_SOSS_Users_Can_Update_Owner' validation rule. Validation is NOT fired when conditions are NOT met.
    * @Rule Name: Only_SOSS_Users_Can_Update_Owner
    * @Rule Definition: 
        AND (
            NOT($Setup.Bypass_Validations__c.Disable__c), 
            $Profile.Name <> "SOSS User",
			$Profile.Name <> "System Administrator",
			ISCHANGED(OwnerId)
        )   
    * @autho : Ramesh Thulasi
    * @param : None
    * @return : None
    **/
    private static testMethod void test_OnlySOSSUsersCanUpdateOwner_SOSSUser_NegativeTest() {
        User stdUser=TestDataFactory.getProfileUser(profileMap.get(Constants.STD_USR_PROFILE).Id); 
        User sossUser=TestDataFactory.getProfileUser(profileMap.get(Constants.SOSS_USR_PROFILE).Id); 
        System.runAs(sossUser){
            List<Account> accs = TestDataFactory.createAccounts(1, true);
            Account acc = accs.get(0);
            acc.OwnerId=stdUser.id;
            Test.startTest();
            Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(acc,ONLY_SOSS_USERS_CAN_UPDATE_OWNER_ERROR_MSG);
            Test.stopTest();
            System.assertEquals(false,containsValidationMsg,TestDataFactory.NO_DML_VALIDATION_ERROR_MSG);
        } 
    }
    /**
    * @description :  Test method to test validation bypass for user.  Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
    * @autho : Ramesh Thulasi
    * @param : None
    * @return : None
    **/
    private static testMethod void test_OnlySOSSUsersCanUpdateOwner_Bypass_PositiveTest() {
        User stdUser=TestDataFactory.getProfileUser(profileMap.get(Constants.STD_USR_PROFILE).Id); 
        User salesUser = TestDataFactory.getProfileUser(
            profileMap.get(Constants.SALES_USR_PROFILE).Id
        );
        TestDataFactory.setBypassValidationForUser(salesUser);
        System.runAs(salesUser){
            List<Account> accs = TestDataFactory.createAccounts(1, true);
            Account acc = accs.get(0);
            acc.OwnerId=stdUser.id;
            Test.startTest();
            Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(acc,ONLY_SOSS_USERS_CAN_UPDATE_OWNER_ERROR_MSG);
            Test.stopTest();
            // Record should be inserted
            System.assertEquals(false,containsValidationMsg ,TestDataFactory.BYPASS_VALIDATION_ERROR_MSG);
        } 
    }
    
}