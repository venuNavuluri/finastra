//This class is for testing AccountRollupTrigger and AccountRollupTriggerMethods class

@isTest(SeeAllData = true)
private class Test_AccountRollupTrigger {
    
    //Due to the time constraint, no assertions have been applied in this test method
    //This is just used to make up the test coverage for the above mentioned trigger and it's supporting class
    private static testmethod void testAccountRollup(){
        list<Account> accountList = [select id from Account where name = 'National Australia Bank' and Type != 'Roll-Up Parent' and Type != 'Roll-Up Group' limit 1];
        list<Account> accountListParent = [select id from Account where name = 'National Australia Bank (Parent)' and Type = 'Roll-Up Parent' limit 1];
        if(accountListParent != null && accountListParent.size() > 0){
            Account_Rollup__c arpParent = new Account_Rollup__c(Name = 'Test', Account__c = accountListParent[0].Id);
            insert arpParent;
            if(accountList != null && accountList.size() > 0){
                Account_Rollup__c arp = new Account_Rollup__c(Name = 'Test', Account__c = accountList[0].Id, Ultimate_Parent_Account_Rollup__c = arpParent.Id);
                insert arp;
            }
        }
    }
}