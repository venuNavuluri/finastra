global class POCreationBatch implements Database.Batchable<sObject>
{

    global Database.QueryLocator start(Database.BatchableContext DBC)
    {
         return Database.getQueryLocator([Select Id,Name,Purchase_Order_Type__c from Account where Purchase_Order_Type__c='Required for Invoice']);

             
    }

    global void execute(Database.batchableContext bc,List<sObject> scope)
    {

        List<Account> accountList = (List<Account>)scope;
        Set<Id> accountIdSet = new Set<Id>();

       // for(Account accountRecord : accountList)
        //{
          //  accountIdSet.add(accountRecord.id);
        //}
        // NG to avoid explicitly putting sObject ids into a set in the loop, we can use construction like this:
        //Shruthi - Done
        accountIdSet = new Map<Id, Account>(accountList).keySet();
        // which makes code shorter -> easier to read


        ProductOrderUtils POU = new ProductOrderUtils();
        POU.createPurchaseOrders(accountIdSet);
    }

    // NG I'm still missing error handling here
    // There is no try catch block in the execute method, so if there is an error the whole batch will fail
    // and no-one will notice, unless someone will track logs in 'apex jobs' tab in setup
    // we could at least send an email to the business user from the finish method if there is an exception
    //Shruthi - This will be run only once in a year, so some one has to check the jobs and when it is completed, they should get the validation from Sales team(Pat)
    //it will be one day activity in a year where sales member and who runs this job should be involved

    global void finish(Database.batchableContext BC){}

}