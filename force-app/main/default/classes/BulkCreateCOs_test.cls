@isTest
public class BulkCreateCOs_test {
    @istest static void unitTest(){
        //Creating Account
        Account testAcc = TestUtility.sampleAccount();
        insert testAcc;
        
        // inserting system
        System__c sys1 = TestUtility.sampleSystem(testAcc.Id);
		sys1.Environment2__c = 'PROD';
		insert sys1;
        
        // Creating Subscriptions
        NS_Subscriptions__c sub = new NS_Subscriptions__c();
        insert sub;
        
        // Creating contract Assets
        Contract_Asset__c ast = new Contract_Asset__c(NS_Subscription__c = sub.Id, Account__c = testAcc.Id, system__c = sys1.Id);
        insert ast;
        
        // invoking std set controller
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id, Name FROM NS_Subscriptions__c]));  
        setCon.setSelected([SELECT Id, OwnerId FROM NS_Subscriptions__c]); // this method gives selected records          
        BulkCreateCOs bc = new BulkCreateCOs(setCon);
        bc.createChangeOrder();
        bc.redirectListView();
    }
}