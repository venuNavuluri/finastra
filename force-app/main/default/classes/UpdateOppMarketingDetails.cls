/*
    Developer:Komal Karnwat
    Description: SD Req 1442818-
                 To Update the 'Marketing Involved Program' field on an opportunity with the 'Marketing Involved Program' field value on Contact linked to It.
                 This should be done when below conditions is satisfied:
                     1. On Updation of opportunity if a new contact role is added to the opportunity. 
                 This functionality is used for tracking Marketing Generated and Influenced Opportunities through Marketo.
                 This Apex class will be schedule to run once a day and update the opportunities with the above criteria
*/

global class UpdateOppMarketingDetails implements Schedulable{
   
/*   

*********** To Execute in Anonymous Window once, inorder to schedule the Apex Job ********************************

UpdateOppMarketingDetails updateOppMarketingDetails = new UpdateOppMarketingDetails();
// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
String sch = '0 0 23 * * ?';
String jobID = System.schedule('UpdateOpp_MarketingDetails', sch, updateOppMarketingDetails);
system.debug('Apex Scheduled Job Id is --->' + jobID);
*/

    global void execute(SchedulableContext ctx){

        Set<Id> OppIdSet = new Set<Id>();
        Set<Id> ConIdSet = new Set<Id>();
        Map<Id, Opportunity> oppToUpdateMap = new Map<Id, Opportunity>();
        //To fetch the OpportunityContactRole created daily
        List<OpportunityContactRole> oppConRoleList = [SELECT Id,OpportunityId,contactId,CreatedDate,isPrimary FROM OpportunityContactRole where CreatedDate = TODAY order by CreatedDate desc];
        For(OpportunityContactRole oppconObj : oppConRoleList){
            OppIdSet.add(oppconObj.OpportunityId);
            ConIdSet.add(oppconObj.contactId);
        }
        //To fetch the Opportunities & Contacts based on OpportunityContactRoles
        Map<Id, Opportunity> oppIdToOppMap = new Map<Id, Opportunity>([SELECT Id,name,Marketing_Involved_Program__c,Marketing_Involved_Date__c,CreatedDate FROM Opportunity WHERE ID In :OppIdSet]);
        Map<Id, Contact> conIdToConMap = new Map<Id, Contact>([SELECT Id,MQL_Program__c,Marketing_Involved_Program__c,CreatedDate FROM Contact WHERE Id in :ConIdSet]);

        For(OpportunityContactRole obj : oppConRoleList){
            Opportunity opp = oppIdToOppMap.get(obj.OpportunityId);
            //To check if Opp is either created from Contact or Lead OR a contact is later added to it
            if(opp.CreatedDate.isSameDay(obj.CreatedDate) && (opp.CreatedDate.hour() == obj.CreatedDate.hour()) && (opp.CreatedDate.minute() == obj.CreatedDate.minute())){
                system.debug('updateOppMarketingInvolvedProgram: Opportunity is either created from Contact or Lead, copy the MQL program details');
                if(!String.isEmpty(conIdToConMap.get(obj.contactId).MQL_Program__c)){
                    system.debug('updateOppMarketingInvolvedProgram: Update Opportunity with the marketing  generated details on contact');
                    opp.Marketing_Generated_Program__c = conIdToConMap.get(obj.contactId).MQL_Program__c;
                    opp.Marketing_Generated_Date__c = obj.CreatedDate.Date();
                    oppToUpdateMap.put(opp.Id, opp);
                }if(!String.isEmpty(conIdToConMap.get(obj.contactId).Marketing_Involved_Program__c)){
                    opp.Marketing_Involved_Program__c = conIdToConMap.get(obj.contactId).Marketing_Involved_Program__c;
                    opp.Marketing_Involved_Date__c = obj.CreatedDate.Date();
                    oppToUpdateMap.put(opp.Id, opp);
                }
            } else{
                if(!String.isEmpty(conIdToConMap.get(obj.contactId).Marketing_Involved_Program__c)){
                    if(null == oppToUpdateMap.get(opp.Id)){
                        system.debug('updateOppMarketingInvolvedProgram: Update Opportunity with the marketing involved program details on contact');
                        opp.Marketing_Involved_Program__c = conIdToConMap.get(obj.contactId).Marketing_Involved_Program__c;
                        opp.Marketing_Involved_Date__c = obj.CreatedDate.Date();
                        oppToUpdateMap.put(opp.Id, opp);
                    }
                    //To replace the contact details with primary contact details if Opp has multiple contactRoles
                    else if(null != oppToUpdateMap.get(opp.Id) && obj.isPrimary){
                        system.debug('updateOppMarketingInvolvedProgram: To replace the contact details with primary contact details if Opp has multiple contactRoles');
                        opp.Marketing_Involved_Program__c = conIdToConMap.get(obj.contactId).Marketing_Involved_Program__c;
                        opp.Marketing_Involved_Date__c = obj.CreatedDate.Date();
                        oppToUpdateMap.put(opp.Id, opp);
                    }

                }

            }
        }

        if(oppToUpdateMap.size() > 0){
            saveWithErrorHandling(oppToUpdateMap.values());
        }
    }

    private void saveWithErrorHandling(List<Opportunity> oppsToUpdate){
        String message = '';
        Database.SaveResult[] resultsRecs = Database.update(oppsToUpdate, false);

        for(Integer i = 0; i < resultsRecs.size(); i++){
            Database.SaveResult s = resultsRecs[i];
            Opportunity originalOpportunity = oppsToUpdate[i];
            if(!s.isSuccess()){
                for(Database.Error err : s.getErrors()){
                    message += 'Update of the opportunity ' + originalOpportunity.Id +' - '+ originalOpportunity.Name + ' failed: \n' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
                }
            }
        }
        system.debug('==> message: '+message);
        sendNotification(message);
    }

    private void sendNotification(String message){
        Opportunity_Settings__c cs = Opportunity_Settings__c.getValues('default_config');
        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where Address = 'noreply.notifications@misys.com' limit 1];
        List<String> emails = new List<String>();
        if(cs != null && cs.Notification_Email__c != null){
            emails.addAll(cs.Notification_Email__c.split(','));
        }
        if(emails.isEmpty()){
            emails.add('Maria.Moriarty@misys.com');
        }
        if(message != '' && !Test.isRunningTest()){
            EmailUtil.to(emails)
                    .subject('Opportunity update errors from MarketingDetails job')
                    .plainTextBody(message)
                    .orgWideId(owa.Id)
                    .sendEmail();
        }
    }
}