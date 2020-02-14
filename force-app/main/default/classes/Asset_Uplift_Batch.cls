/*
 * @author Serhii Volynets sergey.volinets@weare4c.com
 * This class runs/executes Asset Uplift jobs on recural basis
 * Main methods:
 * start - queries contracts which need Asset Uplift execution
 * execute - executes asset uplift for list of found contract
 */
global class Asset_Uplift_Batch implements Schedulable,Database.Batchable<sobject>, Database.Stateful  {
    /*
     * method queries for contracts which need asset uplift and returns query locator
     * */
    global List<Contract> contrScssList;
    global List<Contract> contrErrList;
    global Asset_Uplift_Batch(){
        contrScssList = new List<Contract>();
        contrErrList = new List<Contract>();
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        // query for contracts with Next_Asset_Uplift_Date__c in a past
        string expr = 'SELECT ID, ContractNumber, Batch_Error_Logs__c, Next_Asset_Uplift_Date__c FROM Contract where Next_Asset_Uplift_Date__c <=TODAY AND Active__c = TRUE';
        if(Test.isRunningTest())
            expr = expr +' LIMIT 1';
        
        return Database.getQueryLocator(expr);
    }
    /*
     * method executes Asset_Uplift for contracts which mach the criteria
     */  
    global void execute(Database.BatchableContext bc, list<sobject> lrec)
    {
        set<id> scontr= new set<id>();
        list<contract>lupdate = new list<contract>();
        for(sobject obj: lrec)
        {
			contract rec= (contract)obj;
            scontr.add(rec.id);
            //calculate  Next_Asset_Uplift_Date__c date
            while(rec.Next_Asset_Uplift_Date__c <Date.today())
                rec.Next_Asset_Uplift_Date__c = rec.Next_Asset_Uplift_Date__c.AddYears(1);
            
            rec.Batch_Error_Logs__c = '';
            lupdate.add(rec);
        }
        try {
            //Execute asset uplift
            Asset_Uplift.execute(scontr);
            contrScssList.addAll(lupdate);
        }
        catch (Exception ex) {
            for(Contract contr : lupdate) {
            	contr.Batch_Error_Logs__c = 'Error thrown in Asset Uplift Batch: ' + ex.getMessage() + ', Stack Trace: ' + ex.getStackTraceString();  
            }
            contrErrList.addAll(lupdate);
        }
        update lupdate; //update Next_Asset_Uplift_Date__c
    }
    global void finish(Database.BatchableContext bc)
    {
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, ExtendedStatus,
                TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob WHERE Id =
                :BC.getJobId()];
        if(a.JobItemsProcessed == 0) return;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(System.Label.Billing_Report_Email_List.split(','));
        mail.setSubject('Asset Uplift Batch Job Process ' + a.Status);
                        
        string htmlBody = '<p>The batch Apex job processed <b>' + a.TotalJobItems +'</b> batches with <b>'+ a.NumberOfErrors + '</b> failures.</p>' ;
        if(a.ExtendedStatus != null) {
            htmlBody += '<br /><br /><p>Error Status: ' + a.ExtendedStatus + '</p>';
        }
        string errorTable = '<br /><br />Total number of Records processed successfully: <b>'+contrScssList.size()+'</b><br />';
        
        if(contrErrList.size() > 0) {
            errorTable+='<br /><br /><table> <tr> <th>Contract</th> <th>Error</th> </tr>';
            string tRow = '';
            
            for(Contract contr: contrErrList){
                tRow = '<tr style="font-weight: bold; color: red;">';
                tRow += '<td><a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+contr.Id+'">'+contr.ContractNumber+'</td><td>'+contr.Batch_Error_Logs__c+'</td>';
                tRow += '</tr>';            
                errorTable += tRow;
            }
            errorTable += '</table>';    
        }
        mail.setHtmlBody(htmlBody + errorTable);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    global void execute(SchedulableContext sc){
        database.executeBatch(new Asset_Uplift_Batch(),1);
    } 
}