global class ContractUpliftCalculationBatch implements Database.Batchable<sObject>, Database.Stateful{

    global List<Contract> contrScssList;
    global List<Contract> contrErrList;
    global ContractUpliftCalculationBatch(){
        contrScssList = new List<Contract>();
        contrErrList = new List<Contract>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT ID, ContractNumber, Batch_Error_Logs__c FROM Contract '+
                'WHERE Uplift_Application_Date__c <= TODAY AND Hold_CPI_Uplift__c = FALSE AND No_CPI_Uplift__c = FALSE AND Active__c = TRUE';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contract> scope){
        try {
            UpliftUtils.createUpliftFromContract(scope);
            for(Contract contr : scope) {
            	contr.Batch_Error_Logs__c = '';  
            }
            contrScssList.addAll(scope);
        }
        catch (Exception ex) {
            for(Contract contr : scope) {
            	contr.Batch_Error_Logs__c = 'Error thrown in CPI Uplift Batch: ' + ex.getMessage() + ', Stack Trace: ' + ex.getStackTraceString();  
            }
            contrErrList.addAll(scope);
        }
        update scope;
    }    

    global void finish(Database.BatchableContext BC){
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
        mail.setSubject('CPI Uplift Batch Job Process ' + a.Status);
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
}