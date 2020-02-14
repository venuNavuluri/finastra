/*
* Update by Tim 06.08.17
*
* Note: AutoRenewContracts batchable removed
*
* 06.08.17 : Ed Harrold : Deploy updated schedulable code removing batch method
* 07.14.17 : Ed Harrold : Debugging due to huge number of scheduled jobs - found over 9,0000
*                         in the system
* 07.15.17 : Ed Harrold : Update to handle apparent overrun of scheduled tasks and failed renewals
*                         extending to 60 seconds or longer
* 08.18.17 : Ed Harrold : Added abort job and debug output for troubleshooting contracts that don't renew
* 08.19.17 : Ed Harrold : Add code coverage of exception path
* 06.07.19 : Dan Meseroll : Added to Finastra project and updated logic to get the contracts we want.
*/
global without sharing class AutoRenewContractSchedulable implements Schedulable {

    static Final Integer SECONDSTONEXTSCHEDULE = 60;

    global void execute(SchedulableContext sc) {
        Date dt = System.Today();
        System.debug('AutoRenewContractSchedulable: '+dt);
		boolean renewForecast = false;
        boolean renewQuoted = false;
        //If we are updating renewal quoted, it will automatically update renewal forecast
        boolean updatingQuoted = false;
        string perp = 'Perpetual';

        List<Database.SaveResult> updateResult;
        //SBQQ__RenewalForecast__c, Renewal_Creation_Date__c, Renewal_Quote_Creation_Date__c, SBQQ__RenewalQuoted__c, Auto_Renewal__c
        String query = 'SELECT Id, Renewal_Creation_Date__c, Renewal_Quote_Creation_Date__c, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c FROM Contract WHERE (Renewal_Type__c != null AND Renewal_Type__c != :perp) AND Failed_Auto_Renew__c = false AND ((SBQQ__RenewalForecast__c = false AND Renewal_Creation_Date__c <=: dt) OR (SBQQ__RenewalQuoted__c = false AND Renewal_Quote_Creation_Date__c <=: dt)) ORDER BY ContractNumber LIMIT 1';
        List<Contract> scope = database.query(query);
        System.debug('AutoRenewContractSchedulable: Items to schedule count: '+scope.size());
        //There can be only one!  LIMIT 1 on query  
        for(Integer i=0; i<scope.size(); i++) {
            renewForecast = scope[i].SBQQ__RenewalForecast__c;
            renewQuoted  = scope[i].SBQQ__RenewalQuoted__c;
            if (scope[i].Renewal_Quote_Creation_Date__c <= dt) {
                updatingQuoted = true;
            	scope[i].SBQQ__RenewalQuoted__c = true;
            	System.debug('AutoRenewContractSchedulable: set SBQQ__RenewalQuoted__c true');
            }
            if (scope[i].Renewal_Creation_Date__c <= dt) {
            	scope[i].SBQQ__RenewalForecast__c = true;
            	System.debug('AutoRenewContractSchedulable: set SBQQ__RenewalForecast__c true');
            }
        }
        try {
            if (scope.size() > 0) {
                System.debug('AutoRenewContractSchedulable: updating: '+ scope);
                update scope;
            }
            //added for code coverage of exception path
            //if (Test.isRunningTest()){
            //    throw new autorenewException();
            //}
        } catch (exception e) {
            System.debug('AutoRenewContractSchedulable: 1st Exception on update scope: line: '+e.getLineNumber()+' message:'+e.getMessage());
            try {
                if (updatingQuoted = true) {
                	scope[0].SBQQ__RenewalQuoted__c = false;
                	scope[0].SBQQ__RenewalForecast__c = renewForecast;
				} else {
                	scope[0].SBQQ__RenewalForecast__c = false;
                }
                scope[0].Failed_Auto_Renew__c = true;
                string exceptionText = 'AutoRenewContractSchedulable: 1st Exception on update scope: line: '+ e.getLineNumber()+' message:'+ e.getMessage();
                if (exceptionText.length() >= 255)
                {
                    exceptionText = exceptionText.substring(0,255);
                }
                scope[0].Failed_Auto_Renew_Message__c = exceptionText;
                update scope;
            } catch(exception e1) {
                System.debug('AutoRenewContractSchedulable: 2nd Exception on update scope: line: '+e1.getLineNumber()+' message:'+e1.getMessage());
            }
        }

        //any remaining items?
        List<Contract> cList = database.query(query);
        // move items out for unit testing
        DateTime future = system.now().addSeconds(SECONDSTONEXTSCHEDULE);
        Integer year = future.year();
        Integer month = future.month();
        Integer day = future.day();
        Integer hour = future.hour();
        Integer minute = future.minute();
        Integer second = future.second();
        String strJobName = 'AutoRenew-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        if(!cList.isEmpty()) {
            System.debug('AutoRenewContractSchedulable: Items to schedule count: '+cList.size());
            System.schedule(strJobName, strSchedule, new AutoRenewContractSchedulable());
        }
        System.abortJob(sc.getTriggerId());
    }
    //added for code coverage of exception path
    public class autorenewException extends Exception {}
}