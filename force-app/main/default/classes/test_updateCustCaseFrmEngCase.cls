@isTest
public class test_updateCustCaseFrmEngCase {
   static testMethod void test_UpdateParentCase()
    {
        Case customerCase = testutility.sampleCase();
        Case engineeringCase = testutility.sampleCase();
        insert customerCase ;
        insert engineeringCase ;
        
        engineeringCase .parentid = customerCase.id;
        engineeringCase.Customer_Re_open_Count__c = 2;
        
        update EngineeringCase;
    }  
}