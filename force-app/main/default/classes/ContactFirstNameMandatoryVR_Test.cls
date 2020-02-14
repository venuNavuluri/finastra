/**
 * @File Name          : ContactFirstNameMandatoryVR_Test.cls
 * @Description        : Test Class for Contact object Validation Rules 
 * @Author             : Sujith Maruthingal
 * @Group              : Sales/Pipeline
 * @Last Modified By   : Sujith Maruthingal
 * @Last Modified On   : 27/11/2019, 13:14:04
 * @Modification Log   : 
 * Ver       Date            Author      		   Modification
 * 1.0    26/11/2019   Sujith Maruthingal     Initial Version
**/


@isTest 
private class ContactFirstNameMandatoryVR_Test {
    private static final map<String,Profile> PROFILEMAP =TestDataFactory.getProfileMap();
    private static final String FIRSTNAME_CONTACT_ERROR_MSG = 'Contact First Name is Mandatory.';
    
    @testSetup static void setup() {
        // init Bypass validation custom property
        List<Bypass_Validations__c> valCusSettings = new List<Bypass_Validations__c>();
        
        List<User> userList=TestDataFactory.createUserList(true);
        User adminUser=[Select id,Profile.Name from User where ProfileId =:(PROFILEMAP.get(Constants.SYS_ADMIN_PROFILE).Id) and LastName='TestUser']; 
        // set custom property for admin user
        System.runAs(adminUser) {
            // flag defaults to false means validation rules are NOT bypassed 
            valCusSettings.add(new Bypass_Validations__c(SetupOwnerId=adminUser.id, Disable__c=false));
            insert valCusSettings;
        }                
    }
    

    /**
    * @description :Validation rule will not fired by passing Valid First Name
    * @author Sujith Maruthingal | 26/11/2019 
    * @return testMethod 
    **/
    private static testMethod void test_ContactFirstNameMandatory_NegativeTest() {
        User adminUser=[Select id,Profile.Name from User where ProfileId =:(PROFILEMAP.get(Constants.SYS_ADMIN_PROFILE).Id) and LastName='TestUser']; 
        System.runAs(adminUser){
            List<Account> acc=TestDataFactory.createAccounts(1,true);
            List<Contact> cont =TestDataFactory.createContacts(acc[0].Id,1,true); 
                Test.startTest();
                Map<Integer,String> errorMap = TestDataFactory.getErrorMap(cont);
                Test.stopTest();
                Boolean flag = false;
                for(String val: errorMap.values()) {
                    flag = val.startswith(FIRSTNAME_CONTACT_ERROR_MSG);
                    if(flag) {
                        break;
                    }
                }
            System.assertEquals(false,flag,CONSTANTS.DMLEXC_WITHOUT_VALIDATION_ERR_MSG);
            
        }
      
    }
  
        /**
        * @description :Validation rule will be fired by passing First Name as Null
        * @author Sujith Maruthingal | 26/11/2019 
        * @return testMethod 
        **/
        private static testMethod void test_ContactFirstNameMandatory_PositiveTest() {
        User adminUser=[Select id,Profile.Name from User where ProfileId =:(PROFILEMAP.get(Constants.SYS_ADMIN_PROFILE).Id) and LastName='TestUser']; 
             System.runAs(adminUser){
             List<Account> acc=TestDataFactory.createAccounts(1,true);
            List<Contact> cont =TestDataFactory.createContacts(acc[0].Id,1,true);
            Test.startTest();
            cont[0].Firstname=null;
            Map<Integer,String> errorMap = TestDataFactory.getErrorMap(cont);
            Test.stopTest();
            Boolean flag = false;
            for(String val: errorMap.values()) {
                flag = val.startswith(FIRSTNAME_CONTACT_ERROR_MSG);
                if(flag) {
                    break;
                }
            }
            System.assertEquals(true,flag,CONSTANTS.DMLEXC_WITH_VALIDATION_ERR_MSG);
        } 
    }
     
    /**
    * @description :Bypass test case for ContactFirstNameMandatory Validation Rule
    * @author Sujith Maruthingal | 26/11/2019 
    * @return testMethod 
    **/
    private static testMethod void test_ContactFirstNameMandatory_BypassTest() {
        User adminUser=[Select id,Profile.Name from User where ProfileId=:(profileMap.get(Constants.SYS_ADMIN_PROFILE).Id) and LastName='TestUser']; 
        // set the custom property flag to 'true'
        Bypass_Validations__c cusSetting = [select id from Bypass_Validations__c where SetupOwnerId=:adminUser.id];
        cusSetting.Disable__c = true;
        update cusSetting;
        System.runAs(adminUser){
            List<Account> acc=TestDataFactory.createAccounts(1,true);
            List<Contact> cont =TestDataFactory.createContacts(acc[0].Id,1,true);           
                Test.startTest();
                Map<Integer,String> errorMap = TestDataFactory.getErrorMap(cont);
                Test.stopTest();
                Boolean flag = false;
                for(String val: errorMap.values()) {
                    flag = val.startswith(FIRSTNAME_CONTACT_ERROR_MSG);
                    if(flag) {
                        break;
                    }
                }
                // Record should be inserted
                System.assertEquals(false,flag,CONSTANTS.BYPASS_ERROR_MSG);
             
        }
    }
}
