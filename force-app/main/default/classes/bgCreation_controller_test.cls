@isTest
public class bgCreation_controller_test {
    
    @testSetup static void setup() {
        Account acc = TestDataFactory.createAccount('Test Account'); 
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        Contract con = TestDataFactory.createContract(acc, opp);
    }
    public static testMethod void test_Success(){
        Contract con = [SELECT Id, BG_Created__c, Billing_Group_Entity__c, Billing_Group_Entity__r.Synced_To_NS__c, NS_Customer_Address__c FROM Contract];
        Acct_By_Sub__c  bge = new Acct_By_Sub__c (Name = 'test', Synced_To_NS__c = false, Account__c = [SELECT Id FROM Account LIMIT 1].Id);
        insert bge;
        con.Billing_Group_Entity__c = bge.Id;
        con.BG_Created__c = true;
        con.Recurring_Fees_Start_Planned__c = null;
        NS_Customer_Address__c cusAdd = new NS_Customer_Address__c(Synced_To_NS__c = false);
        insert cusAdd;
        con.NS_Customer_Address__c = cusAdd.Id;
        update con;
        bgCreation_controller t = new bgCreation_controller(new ApexPages.StandardController(con)); 
        System.assertEquals(null, t.errorMsg, 'Should be null');
        System.assertEquals(null, t.successMsg, 'Should be null');
        Test.startTest();
            t.pageAction();
        Test.stopTest();
        System.assertNotEquals(null, t.successMsg, 'Should NOT be null');
        System.assertEquals(null, t.errorMsg, 'Should be null');
    }
    public static testMethod void test_Failure(){
        Contract con = [SELECT Id, BG_Created__c, Billing_Group_Entity__c, Billing_Group_Entity__r.Synced_To_NS__c, NS_Customer_Address__c FROM Contract];
        Acct_By_Sub__c  bge = new Acct_By_Sub__c (Name = 'test', Synced_To_NS__c = false, Account__c = [SELECT Id FROM Account LIMIT 1].Id);
        insert bge;
        con.Billing_Group_Entity__c = bge.Id;
        con.Recurring_Fees_Start_Planned__c = null;
        NS_Customer_Address__c cusAdd = new NS_Customer_Address__c(Synced_To_NS__c = false);
        insert cusAdd;
        con.NS_Customer_Address__c = cusAdd.Id;
        update con;
        bgCreation_controller t = new bgCreation_controller(new ApexPages.StandardController(con)); 
        System.assertEquals(null, t.errorMsg, 'Should be null');
        System.assertEquals(null, t.successMsg, 'Should be null');
        Test.startTest();
            t.pageAction();
        Test.stopTest();
        System.assertEquals(null, t.successMsg, 'Should be null');
        System.assertNotEquals(null, t.errorMsg, 'Should NOT be null');
    }
    public static testMethod void test_Exception(){
        Test.startTest();
            try {
                bgCreation_controller t = new bgCreation_controller(new ApexPages.StandardController(null)); 
            }catch(Exception e){
                System.assert(true, 'Should throw exception');
            }
        Test.stopTest();
    }
}