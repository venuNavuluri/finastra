public class OpportunityTriggerMethods {

    static final String PRIMARY_SIGNATORY = 'Primary signatory';
    static final String PREFERRED_SIGNATORY_1 = 'Preferred signatory 1';
    static final String PREFERRED_SIGNATORY_2 = 'Preferred signatory 2';
    static final String PREFERRED_SIGNATORY_3 = 'Preferred signatory 3';
    static final String PREFERRED_SIGNATORY_4 = 'Preferred signatory 4';
    static final String SECOND_SIGNATORY = 'Second signatory';
    static final String SECOND_SIGNATORY_2 = 'Second signatory 2';
    static final String ALTERNATIVE_SIGNATORY_1 = 'Alternative signatory - 1';
    static final String ALTERNATIVE_SIGNATORY_2 = 'Alternative signatory - 2';
    static final String ALTERNATIVE_SIGNATORY_3 = 'Alternative signatory - 3';
    static final String ALTERNATIVE_SIGNATORY_4 = 'Alternative signatory - 4';
    public static boolean firstRun = true;
    public static boolean isExecuting = false;

    public static void UpdateOppLineItemSchedule(string sQuery, integer iNumMonths)
    {
        system.debug('JRB...........sQuery='+sQuery);
        system.debug('JRB...........iNumMonths='+iNumMonths);

        List<OpportunityLineItemSchedule> lOppLineItemSchedule = Database.query(sQuery);

        for(OpportunityLineItemSchedule olis : lOppLineItemSchedule)
        {
            olis.ScheduleDate = olis.ScheduleDate.addMonths(iNumMonths);
        }

        if(lOppLineItemSchedule.size()>0)
            update lOppLineItemSchedule;
    }


    public static void UpdateOppLineItems(List<Opportunity> updatedOpps, List<Opportunity> prevOpps)
    {

        /*
            Name        :   OpportunityAfterUpdate

            Purpose     :   The trigger contains business logic that's supposed to occur when opportunity gets updated.
                            This trigger will be fired on update of Opportunity record(s) Single or in batch.

            Parameters  :   N/A

            Invoked From    : Auto-triggered on Opportunity record update

            Triggering Condition:   1. Opportunity.CloseDate changed
                                    2. Opportuniy.Owner changed

            Returns     :   N/A

            Notes       :   1. The initial version of the trigger was to fulfil PS Forecasting requirements. The details of the requirements can be
                            obtained at https://emea.salesforce.com/015?fcf=00l200000012cfl
                                a. When the Month of modified CloseDate is the same, send an email;
                                b. When the Month of modified CloseDate is the different, update month of the schedule dates relatively.

                            2. When Opportunity Owner changes and have corresponding Quota Credit records, the employee name on it should be changed.


            Modification Log

            User                Date                Description
            --------------      ----------          --------------------------------------------------------------
            Prashant Bhure      05/21/2009          Created - Initial version - To meet PS Forecasting requirements.
            Prashant Bhure      05/22/3009          Modified to meet Quota Credit requirements.
            Prashant Bhure      07/09/2009          When PS Team member not assigned, send the email to regional teams.
            Prashant Bhure      07/13/2009          Added opp name and opp link to the email; Changed the email for MEA to Managers from Team.
            Jason Bennett       04/05/2011          Reformatted code for better readability
            Jason Bennett       04/05/2011          Modified code to call the update to OpportunityLineItems as an asynchronous (Future) process instead of Batch Apex (to avoid issues with limits)
            Jason Bennett       04/06/2011          Modified code detect if it is running in production or sandbox, and adjust email TO address accordingly
            Jason Bennett       06/16/2011          Added code to log updates made by an integration for RLF amounts
            Jason Bennett       09/19/2012          Moved the SendMail call outside the loop to prevent limit errors.  Also, moved the code out of the trigger and into this class.

            */


        string ls_email_conclusion = '<br><br> You may update the schedule.';
        string sPS = 'PS',sFD = 'FD';
        string currentUserEmail = '';
        if(!GlobalVar.IsProduction()){
            User u = [select Id, Email from User where id = :UserInfo.getUserId()];
            currentUserEmail = u.Email;
        }

        List<Messaging.SingleEmailMessage> MailsToSend = new List<Messaging.SingleEmailMessage>();
        for(Integer li_counter = 0; li_counter < updatedOpps.size(); li_counter++)
        {
            System.debug('PB: Get in only when CloseDate on Opportunity changed...');
            if(updatedOpps[li_counter].CloseDate != prevOpps[li_counter].CloseDate) {
                //************* PS FORECASTING - BEGIN *************
                System.debug('PB: Check if the Opp has PS/FD schedule.');
                // Define list variable for Schedules to be updated
                //opportunityLineItemSchedule[] OppScheduleList = [Select o.Id, o.ScheduleDate from OpportunityLineItemSchedule o  WHERE (OpportunityLineItem.OpportunityId = :updatedOpps[li_counter].Id) AND ((o.OpportunityLineItem.Prod_fly__c LIKE 'PS%') OR (o.OpportunityLineItem.Prod_fly__c LIKE 'FD%')) ORDER BY ScheduleDate];

                //If the month was changed on the Close Date, update the related Opportunity Line Items
                if((updatedOpps[li_counter].CloseDate.month() != prevOpps[li_counter].CloseDate.month()) || (updatedOpps[li_counter].CloseDate.year() != prevOpps[li_counter].CloseDate.year()))
                {
                    integer li_months_between = prevOpps[li_counter].CloseDate.monthsBetween(updatedOpps[li_counter].CloseDate);
                    string strQuery = 'Select o.Id, o.ScheduleDate from OpportunityLineItemSchedule o WHERE (OpportunityLineItem.OpportunityId = \'' + updatedOpps[li_counter].Id;
                    strQuery += '\') AND ((o.OpportunityLineItem.Prod_fly__c LIKE \'' + sPS + '%\') OR (o.OpportunityLineItem.Prod_fly__c LIKE \'' + sFD + '%\')) ORDER BY ScheduleDate';
                    //Removed call to method using Batch Apex
                    //UpdateOpptyScheduleInBatch obj = new UpdateOpptyScheduleInBatch(strQuery,li_months_between);
                    //database.executebatch(obj);
                    //OpportunityFuture.callFuture_UpdateOppLineItemSchedule(strQuery,li_months_between);
                    UpdateOppLineItemSchedule(strQuery,li_months_between);
                    ls_email_conclusion = '<br><br> The schedule has been updated.';
                }

                /*  JRB 03 Dec 12:  SDP 886481, 883878 - Disabled email notification.  These notifications seem to be no longer needed, as no one knows what they are for.
                **
                **
                // Get the PS Team members to email the change - Only 10 Emails can be used in SingleEmailList - There will never be more than 10 PS team members anyway...
                OpportunityTeamMember[] lTeamMemberList = [SELECT o.Id, o.User.Email FROM OpportunityTeamMember o WHERE o.OpportunityId = :updatedOpps[li_counter].Id AND o.TeamMemberRole = 'PS Rep' LIMIT 10];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {};
                // When there's no PS team member assigned to opp, use defaul email address for the Sales Region. They were provided by Amrit Lall. If any changes to the regions in future, contact her.
                // Updated Sales Regions 11-11-10 (JRB)
                if(lTeamMemberList.size() == 0 ){
                    //***** Before deploy change the PS email group to be used..
                    if(updatedOpps[li_counter].Sales_Region_FY07__c == 'APAC') {
                        if(GlobalVar.IsProduction() || Test.IsRunningTest()){
                            toAddresses.add('PS_APAC_Management@misys.com');
                        }else{
                            toAddresses.add(currentUserEmail);
                        }
                    }
                    //JRB 03 Dec 12: Commented out - email address no longer valid
                    //else if(updatedOpps[li_counter].Sales_Region_FY07__c == 'NEUR' || updatedOpps[li_counter].Sales_Region_FY07__c == 'SEUR') {
                    //    if(GlobalVar.IsProduction() || Test.IsRunningTest()){
                    //        toAddresses.add('PSBanking.europemanagers@misys.com');
                    //    }else{
                    //        toAddresses.add(currentUserEmail);
                    //    }
                    //}
                    else if(updatedOpps[li_counter].Sales_Region_FY07__c == 'ME' || updatedOpps[li_counter].Sales_Region_FY07__c == 'SSA' || updatedOpps[li_counter].Sales_Region_FY07__c == 'AFRICA' || updatedOpps[li_counter].Sales_Region_FY07__c == 'Middle East') {
                        if(GlobalVar.IsProduction() || Test.IsRunningTest()){
                            toAddresses.add('PSMEAManagers@misys.com');
                        }else{
                            toAddresses.add(currentUserEmail);
                        }
                    }
                    else if(updatedOpps[li_counter].Sales_Region_FY07__c == 'NAM' || updatedOpps[li_counter].Sales_Region_FY07__c == 'LAM' || updatedOpps[li_counter].Sales_Region_FY07__c == 'AMER' || updatedOpps[li_counter].Sales_Region_FY07__c == 'LATAM') {
                        if(GlobalVar.IsProduction() || Test.IsRunningTest()){
                            toAddresses.add('Susan.Collopy@misys.com');
                        }else{
                            toAddresses.add(currentUserEmail);
                        }
                    }
                    else{ // Default -- In case Sales Regions get changed in the future.....
                        if(GlobalVar.IsProduction() || Test.IsRunningTest()){
                            System.debug('PB: Default email...');
                            toAddresses.add('PSOperationsTeam@misys.com');
                        }else{
                            toAddresses.add(currentUserEmail);
                        }
                    }
                }else{
                    // Otherwise, loop through all the PS team members to form list of toAddress
                    for(Integer li_TeamMember_counter = 0; li_TeamMember_counter < lTeamMemberList.size(); li_TeamMember_counter++){
                        if(GlobalVar.IsProduction() || Test.IsRunningTest()){
                            System.debug('PB: Email Recipient - ' + lTeamMemberList[li_TeamMember_counter].User.Email);
                            toAddresses.add(lTeamMemberList[li_TeamMember_counter].User.Email);
                        }else{
                            toAddresses.add(currentUserEmail);
                        }
                    }
                }
                mail.setToAddresses(toAddresses);
                mail.setSubject('Notification: Opportunity Closed Date Updated');
                mail.setBccSender(false);
                mail.setUseSignature(false);
                string MsgBody='Hello,';

                MsgBody=MsgBody+'<br><br>This is an automatic email notification from Salesforce. <br><br>Following change(s) have been observed:<br>';
                MsgBody=MsgBody+ '<br>Opportunity Closed  Date changed from <b>' + prevOpps[li_counter].CloseDate.format() +' to ' + updatedOpps[li_counter].CloseDate.format() +'</b>';

                //MsgBody=MsgBody+ '<br>Account Name: <b>' + updatedOpps[li_counter].Account.Name  + '</b> <br/>';
                MsgBody=MsgBody+ '<br>Opportunity Name: <b>' + updatedOpps[li_counter].Name  + '</b> ';
                MsgBody=MsgBody+ '<br>Opportunity Number: <b>' + updatedOpps[li_counter].Order_Number__c  + '</b> <br/>';
                MsgBody=MsgBody+ ls_email_conclusion;

                //***** Before deploy change the URL to "https://emea.salesforce.com/" or find the way to use serverURL in Apex.
                //MsgBody=MsgBody+ '<br><br>https://cs4.salesforce.com/' + updatedOpps[li_counter].Id + '</br></br>';
                MsgBody=MsgBody+ '<br><br>https://emea.salesforce.com/' + updatedOpps[li_counter].Id + '</br></br>';

                mail.setHtmlBody(MsgBody);
                System.debug('PB: Send email...');

                //Add the mail to the list to be sent
                MailsToSend.add(mail);
                **
                **
                */
            }
        }
        /*  JRB 03 Dec 12: Disabled email notification - see above
        **
        system.debug('OpportunityTriggerMethods.UpdateOppLineItems - MailsToSend.size = '+MailsToSend.size());
        try{
            Messaging.sendEmail(MailsToSend);
        }catch(Exception e) {
              system.debug('Error sending email: '+e);
        }
        **
        */
    }


    public static void UpdateQuotaCredits(List<Opportunity> updatedOpps, map<Id,Opportunity> prevOpps)
    {
        //Start building a map of Opp Ids to Com Splits
        map<Id,List<Com_Splits__c>> mapOppIdToComSplits = new map<Id,List<Com_Splits__c>>();
        //Set<Id> setUpdatedOppIds = new Set<Id>();
        for(Opportunity o1 : updatedOpps)
        {
            //setUpdatedOppIds.add(o1.Id);
            mapOppIdToComSplits.put(o1.Id,new List<Com_Splits__c>());
        }
        system.debug('OppTriggerMethods.UpdateQuotaCredits - 1.mapOppIdToComSplits: '+mapOppIdToComSplits);

        //Get a list of Com Splits for the current Opps
        //Com_Splits__c[] OCom_SplitsList = [Select Id, Employee_Name__c from Com_Splits__c  WHERE Opportunity__c in :setUpdatedOppIds AND RecordType.Name = 'Direct Master Credit'];
        for(Com_Splits__c cs : [Select Id, Employee_Name__c, Opportunity__c from Com_Splits__c  WHERE Opportunity__c in :mapOppIdToComSplits.keySet() AND RecordType.Name = 'Direct Master Credit'])
        {
            mapOppIdToComSplits.get(cs.Opportunity__c).add(cs);
        }
        system.debug('OppTriggerMethods.UpdateQuotaCredits - 2.mapOppIdToComSplits: '+mapOppIdToComSplits);

        //Build a map of Opp Ids to related Com Splits
        //map<Id,List<Com_Splits__c>> mapOppIdToComSplits = new map<Id,List<Com_Splits__c>>();
        //for(Id oppId : setUpdatedOppIds)
        //{
        //  List<Com_Splits__c> cSplits = newList
        //}

        //for(Integer li_counter = 0; li_counter < updatedOpps.size(); li_counter++)
        List<Com_Splits__c> csToUpdate = new List<Com_Splits__c>();
        for(Opportunity o : updatedOpps)
        {
            //if(updatedOpps[li_counter].OwnerId != prevOpps[li_counter].OwnerId && updatedOpps[li_counter].isClosed == false) {
            if(o.OwnerId != prevOpps.get(o.Id).OwnerId && o.isClosed == false) {
                /************* QUOTA CREDITS - BEGIN *************/
                System.debug('PB: the Opp Owner changed to ' + o.Owner);

                // Define list variable for employee names of the direct quotas to be updated
                //Com_Splits__c[] OCom_SplitsList = [Select Id, Employee_Name__c from Com_Splits__c  WHERE Opportunity__c = :updatedOpps[li_counter].Id AND RecordType.Name = 'Direct Master Credit'];

                // The following condition checks if there's any schedule records to be updated; otherwise, the subsequent statement would fail with there's no sObject for assignment.
                //if(OCom_SplitsList.size() > 0) {
                List<Com_Splits__c> listCS = mapOppIdToComSplits.get(o.Id);

                if(listCS.size() > 0)
                {
                    System.debug('PB: Opp has quota credit records..');

                    // Adjust month of the schedule date to whatever the difference is in changed Opp Close Date
                    //for(Integer li_OCom_Splits_counter = 0; li_OCom_Splits_counter < OCom_SplitsList.size(); li_OCom_Splits_counter++){
                    for(Integer li_OCom_Splits_counter = 0; li_OCom_Splits_counter < listCS.size(); li_OCom_Splits_counter++){
                        listCS[li_OCom_Splits_counter].Employee_Name__c = o.OwnerId;
                    }
                    csToUpdate.addAll(listCS);

                    System.debug('PB: Update the new owner on opp to Quota Credits ');
                    //update OCom_SplitsList;
                }
                /************* QUOTA CREDITS - END *************/
            }
        }
        update csToUpdate;
    }

    /*
    public static void UpdateIntegrationLog(Map<Id,Opportunity> mOpportunityNew, Map<Id,Opportunity> mOpportunityOld){
        List<IntegrationLog.LogRecord> intLogs = new List<IntegrationLog.LogRecord>();
        IntegrationLog.LogRecord iLog;

        /************** RLF-CommonRef Interface *******************//*
        String fieldsChanged;
        for(Opportunity opp : mOpportunityNew.values()){
            fieldsChanged = '';
            if(opp.Length_of_RLF_Holiday__c != mOpportunityOld.get(opp.Id).Length_of_RLF_Holiday__c){
                fieldsChanged += 'Length_of_RLF_Holiday__c;';
            }
            if(opp.RLF_Reduction_Amount_GBP__c != mOpportunityOld.get(opp.Id).RLF_Reduction_Amount_GBP__c){
                fieldsChanged += 'RLF_Reduction_Amount_GBP__c;';
            }
            if(fieldsChanged != ''){
                //Create the Integration Log entry
                iLog = new IntegrationLog.LogRecord();
                iLog.ExternalSystem = 'CommonRef';
                iLog.ExternalId = opp.Integration_Id_RLF__c;
                iLog.SFDC_Object = 'Opportunity';
                iLog.SFDC_Id = opp.Id;
                iLog.Process = 'RLF Holiday-Reduction Data';
                iLog.Operation = 'Update';
                iLog.isSuccess = true;
                iLog.FieldsUpdated = fieldsChanged;
                intLogs.add(iLog);
            }
        }
        /************** END RLF-CommonRef Interface *******************//*

        IntegrationLog.saveToLog(intLogs);
    }
    */

    /*
        This method is for creating and updating the contact roles on opportunity based on the Entity attached to it.
        It will pull out the Primary and Preferred signatories from the attached Entity and will create the contact roles.
    */
    public static void UpdateContactRoles(map<id, Opportunity> updatedOpps, map<Id, Opportunity> prevOpps){
        set<Id> misysEntityIds = new set<Id>();
        map<Id, Id> meOppIdMap = new map<Id, Id>();
        map<Id, Billing_Entity__c> misysEntityMap = new map<Id, Billing_Entity__c>();

        map<Id, Id> prevMeOppIdMap = new map<Id, Id>();
        map<Id, Billing_Entity__c> prevMisysEntityMap = new map<Id, Billing_Entity__c>();

        system.debug('UpdateContactRoles - updatedOpps - ' + updatedOpps);
        system.debug('UpdateContactRoles - prevOpps - ' + prevOpps);

        for(Opportunity opp : updatedOpps.values()){
            if(opp.Entity__c != null && prevOpps != null && prevOpps.size() > 0 && opp.Entity__c != prevOpps.get(opp.Id).Entity__c){
                misysEntityIds.add(opp.Entity__c);
                meOppIdMap.put(opp.Entity__c, opp.Id);

                if(prevOpps.get(opp.Id).Entity__c != null){
                    misysEntityIds.add(prevOpps.get(opp.Id).Entity__c);
                    prevMeOppIdMap.put(prevOpps.get(opp.Id).Entity__c, opp.Id);
                }
            } else if(opp.Entity__c == null && prevOpps != null && prevOpps.size() > 0 && prevOpps.get(opp.Id).Entity__c != null){
                misysEntityIds.add(prevOpps.get(opp.Id).Entity__c);
                prevMeOppIdMap.put(prevOpps.get(opp.Id).Entity__c, opp.Id);
            } else if(opp.Entity__c != null && prevOpps != null && prevOpps.size() == 0){
                misysEntityIds.add(opp.Entity__c);
                meOppIdMap.put(opp.Entity__c, opp.Id);
            }
        }
        system.debug('UpdateContactRoles - misysEntityIds - ' + misysEntityIds);
        system.debug('UpdateContactRoles - prevMeOppIdMap - ' + prevMeOppIdMap);
        system.debug('UpdateContactRoles - meOppIdMap - ' + meOppIdMap);

        if(misysEntityIds != null && misysEntityIds.size() > 0){
            for(Billing_Entity__c me : [select Primary_signatory__c, Preferred_signatory_1__c, Preferred_signatory_2__c,
                    Preferred_signatory_3__c, Preferred_signatory_4__c, Second_signatory__c, Second_Signatory_2__c,
                    Alternative_signatory_1__c, Alternative_signatory_2__c, Alternative_signatory_3__c, Alternative_signatory_4__c
            from Billing_Entity__c where id in :misysEntityIds and Entity_Status__c = 'Contracting Entity']){
                if(meOppIdMap.containsKey(me.Id)){
                    misysEntityMap.put(meOppIdMap.get(me.Id), me);
                } else if(prevMeOppIdMap.containsKey(me.Id)){
                    prevMisysEntityMap.put(prevMeOppIdMap.get(me.Id), me);
                }

            }
        }
        system.debug('UpdateContactRoles - misysEntityIds 1 - ' + misysEntityIds);
        system.debug('UpdateContactRoles - misysEntityMap 1 - ' + misysEntityMap);
        system.debug('UpdateContactRoles - prevMisysEntityMap 1 - ' + prevMisysEntityMap);
        //Create a list of contacts that needs to be deleted from the Contact Roles and delete the Contact Roles
        if(prevMisysEntityMap != null && prevMisysEntityMap.size() > 0){
            list<Id> prevContactIdList = new list<Id>();
            for(Billing_Entity__c mEntity : prevMisysEntityMap.values()){
                if(mEntity.Primary_signatory__c != null){
                    prevContactIdList.add(mEntity.Primary_signatory__c);
                }
                if(mEntity.Preferred_signatory_1__c != null){
                    prevContactIdList.add(mEntity.Preferred_signatory_1__c);
                }
                if(mEntity.Preferred_signatory_2__c != null){
                    prevContactIdList.add(mEntity.Preferred_signatory_2__c);
                }
                if(mEntity.Preferred_signatory_3__c != null){
                    prevContactIdList.add(mEntity.Preferred_signatory_3__c);
                }
                if(mEntity.Preferred_signatory_4__c != null){
                    prevContactIdList.add(mEntity.Preferred_signatory_4__c);
                }
                if(mEntity.Second_signatory__c != null){
                    prevContactIdList.add(mEntity.Second_signatory__c);
                }
                if(mEntity.Second_Signatory_2__c != null){
                    prevContactIdList.add(mEntity.Second_Signatory_2__c);
                }
                //AK - Commenting out the below code as Alternate Signatories are not required to be migrated into the Contact Roles.
                /*
                if(mEntity.Alternative_signatory_1__c != null){
                    prevContactIdList.add(mEntity.Alternative_signatory_1__c);
                }
                if(mEntity.Alternative_signatory_2__c != null){
                    prevContactIdList.add(mEntity.Alternative_signatory_2__c);
                }
                if(mEntity.Alternative_signatory_3__c != null){
                    prevContactIdList.add(mEntity.Alternative_signatory_3__c);
                }
                if(mEntity.Alternative_signatory_4__c != null){
                    prevContactIdList.add(mEntity.Alternative_signatory_4__c);
                }
                */
            }
            if(prevContactIdList != null && prevContactIdList.size() > 0){
                list<OpportunityContactRole> prevOCR = [select id, ContactId, OpportunityId, Role from OpportunityContactRole where ContactId in :prevContactIdList and OpportunityId in :prevMisysEntityMap.keySet()];
                if(prevOCR != null && prevOCR.size() > 0){
                    delete prevOCR;
                }
            }
        }

        //Create a list of contacts that needs to be added as the Contact Roles and create them
        if(misysEntityMap != null && misysEntityMap.size() > 0){
            list<OpportunityContactRole> newOCRList = new list<OpportunityContactRole>();
            for(Id oppId : misysEntityMap.keySet()){
                if(misysEntityMap.get(oppId).Primary_signatory__c != null){
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Primary_signatory__c, Role = PRIMARY_SIGNATORY));
                    system.debug('UpdateContactRoles - newOCRList 1 - ' + newOCRList);
                }
                if(misysEntityMap.get(oppId).Preferred_signatory_1__c != null){
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Preferred_signatory_1__c, Role = PREFERRED_SIGNATORY_1));
                    system.debug('UpdateContactRoles - newOCRList 2 - ' + newOCRList);
                }
                if(misysEntityMap.get(oppId).Preferred_signatory_2__c != null){
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Preferred_signatory_2__c, Role = PREFERRED_SIGNATORY_2));
                    system.debug('UpdateContactRoles - newOCRList 3 - ' + newOCRList);
                }
                if(misysEntityMap.get(oppId).Preferred_signatory_3__c != null){
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Preferred_signatory_3__c, Role = PREFERRED_SIGNATORY_3));
                    system.debug('UpdateContactRoles - newOCRList 4 - ' + newOCRList);
                }
                if(misysEntityMap.get(oppId).Preferred_signatory_4__c != null){
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Preferred_signatory_4__c, Role = PREFERRED_SIGNATORY_4));
                    system.debug('UpdateContactRoles - newOCRList 5 - ' + newOCRList);
                }
                if(misysEntityMap.get(oppId).Second_signatory__c != null){
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Second_signatory__c, Role = SECOND_SIGNATORY));
                    system.debug('UpdateContactRoles - newOCRList 6 - ' + newOCRList);
                }
                if(misysEntityMap.get(oppId).Second_Signatory_2__c != null){
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Second_Signatory_2__c, Role = SECOND_SIGNATORY_2));
                    system.debug('UpdateContactRoles - newOCRList 7 - ' + newOCRList);
                }
                //AK - Commenting out the below code as Alternate Signatories are not required to be migrated into the Contact Roles.
                /*
                if(misysEntityMap.get(oppId).Alternative_signatory_1__c != null){
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Alternative_signatory_1__c, Role = ALTERNATIVE_SIGNATORY_1));
                }
                if(misysEntityMap.get(oppId).Alternative_signatory_2__c != null){
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Alternative_signatory_2__c, Role = ALTERNATIVE_SIGNATORY_2));
                }
                if(misysEntityMap.get(oppId).Alternative_signatory_3__c != null){
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Alternative_signatory_3__c, Role = ALTERNATIVE_SIGNATORY_3));
                }
                if(misysEntityMap.get(oppId).Alternative_signatory_4__c != null){
                    newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = misysEntityMap.get(oppId).Alternative_signatory_4__c, Role = ALTERNATIVE_SIGNATORY_4));
                }
                */
            }
            if(newOCRList != null && newOCRList.size() > 0){
                system.debug('UpdateContactRoles - newOCRList 8 - ' + newOCRList);
                insert newOCRList;
            }
        }
    }

    //AK - Roll-up some fields from Opportunity to Account

    public static void rollupToAccount(list<Opportunity> oppList){
        //populate the currency conversion rate map
        map<string, decimal> converstionRateMap = new map<string, decimal>();
        for(CurrencyType cType : [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE]){
            converstionRateMap.put(cType.ISOCode, cType.ConversionRate);
        }
        system.debug('converstionRateMap = ' + converstionRateMap);
        set<Id> accountIds = new set<Id>();
        map<Id, list<Opportunity>> aacIdOppListMap = new map<Id, list<Opportunity>>();

        for(Opportunity opp : oppList){
            accountIds.add(opp.AccountId);
        }
        system.debug('accountIds = ' + accountIds);

        list<Opportunity> opportunityList;

        if(accountIds != null && accountIds.size() > 0){
            for(Opportunity opp : [select Id, name, ILF_Amount__c, PS_Amount__c, StageName, AccountId, CloseDate, CurrencyISOCode from Opportunity where AccountId in : accountIds]){
                if(aacIdOppListMap.containsKey(opp.AccountId)){
                    opportunityList = aacIdOppListMap.get(opp.AccountId);
                    opportunityList.add(opp);
                } else {
                    opportunityList = new list<Opportunity>();
                    opportunityList.add(opp);
                    aacIdOppListMap.put(opp.AccountId, opportunityList);
                }
            }
            system.debug('aacIdOppListMap = ' + aacIdOppListMap);

            //logic for rollup
            list<Account> updateAccountList = new list<Account>();
            for(Id accId : accountIds){
                decimal ilfClosedAmount = 0;
                decimal ilfPipelineAmount = 0;
                decimal servicesClosedAmount = 0;
                decimal servicesPipelineAmount = 0;

                if(aacIdOppListMap.containsKey(accId)){
                    Account account = new Account(Id = accId);
                    boolean flag = false;
                    for(Opportunity opp : aacIdOppListMap.get(accId)){
                        decimal conversionRate = 1;
                        if(converstionRateMap.containsKey(opp.CurrencyISOCode)){
                            conversionRate = converstionRateMap.get(opp.CurrencyISOCode);
                        }
                        if(opp.StageName == 'Closed Won' && isCurrentFY(opp.CloseDate) && opp.ILF_Amount__c != null && opp.ILF_Amount__c != 0){
                            ilfClosedAmount = ilfClosedAmount + opp.ILF_Amount__c / conversionRate;
                            flag = true;
                        }
                        if((opp.StageName == '1. Plan' || opp.StageName == '2. Create' || opp.StageName == '3. Qualify' || opp.StageName == '4. Develop' || opp.StageName == '5. Prove' || opp.StageName == '6. Negotiate' || opp.StageName == '7. Committed')
                                && opp.ILF_Amount__c != null && opp.ILF_Amount__c != 0){

                            ilfPipelineAmount = ilfPipelineAmount + opp.ILF_Amount__c / conversionRate;
                            flag = true;
                        }
                        if(opp.StageName == 'Closed Won' && isCurrentFY(opp.CloseDate) && opp.PS_Amount__c != null && opp.PS_Amount__c != 0){
                            servicesClosedAmount = servicesClosedAmount + opp.PS_Amount__c / conversionRate;
                            flag = true;
                        }
                        if((opp.StageName == '1. Plan' || opp.StageName == '2. Create' || opp.StageName == '3. Qualify' || opp.StageName == '4. Develop' || opp.StageName == '5. Prove' || opp.StageName == '6. Negotiate' || opp.StageName == '7. Committed')
                                && opp.PS_Amount__c != null && opp.PS_Amount__c != 0){

                            servicesPipelineAmount = servicesPipelineAmount + opp.PS_Amount__c / conversionRate;
                            flag = true;
                        }
                        /* KK: Service Desk Req 1441822 : added a check for closed lost and Closed Qualified Out opportunities.
                         No rollup should be done for above 4 fields of this type of opportunity */
                        if(opp.StageName == 'Closed Lost' || opp.StageName == 'Closed Qualified Out'){
                            flag = true;
                        }
                    }
                    account.ILF_Closed_Current_FY__c = ilfClosedAmount;
                    account.ILF_Pipeline__c = ilfPipelineAmount;
                    account.Services_Closed_Current_FY__c = servicesClosedAmount;
                    account.Services_Pipeline__c = servicesPipelineAmount;
                    if(flag == true){
                        updateAccountList.add(account);
                    }
                }
            }
            system.debug('updateAccountList = ' + updateAccountList);
            if(updateAccountList != null && updateAccountList.size() > 0){
                update updateAccountList;
            }
        }
    }

    private static boolean isCurrentFY(date closeDate){
        boolean currentFY = false;
        date currentDate = Date.today();
        Integer day = currentDate.day();
        Integer month = currentDate.month();
        Integer year = currentDate.year();
        date startDate;
        date endDate;

        if(month >= 6){
            startDate = Date.newInstance(year, 6, 1);
            endDate = Date.newInstance(year + 1, 5, 31);
        }
        if(month <= 5){
            startDate = Date.newInstance(year -1, 6, 1);
            endDate = Date.newInstance(year, 5, 31);
        }
        system.debug('startDate = ' + startDate);
        system.debug('endDate = ' + endDate);

        if(closeDate >= startDate && closeDate <= endDate){
            currentFY = true;
        }
        system.debug('currentFY = ' + currentFY);

        return currentFY;
    }

    /*
    KK: SD Req 1442818
    Method: updateOppMarketingGeneratedProgram
    Description: To Update the 'Marketing Generated Program' field on an opportunity with the 'MQL program' field value on Contact linked to It.
                 This method will be executed for below conditions:
                     1. On creation of opportunity if the contact role is linked to it.
                 This functionality is used for tracking Marketing Generated and Influenced Opportunities through Marketo.
    Parameters: Map of OppId to Opp , OpportunityContactRole List
    Return: Void

    public static void updateOppMarketingGeneratedProgram(Map<Id,Opportunity> oppIdToOppMap , List<OpportunityContactRole> oppConRoleList){
         if( OpportunityTriggerMethods.isExecuting ){
            // if was executed during the same context, to avoid recursion return
            return;
        }
        OpportunityTriggerMethods.isExecuting = true;

        List<Opportunity> oppsToUpdateList = new List<Opportunity>();
        Set<Id> contactSet = new Set<Id>();
        Opportunity opp,tempOpp;
        Contact con;
        //To fetch the contact ids from OpportunityContactRole
        For(OpportunityContactRole oppConobj: oppConRoleList){
            contactSet.add(oppConobj.contactId);
        }
        //To fetch the contact objects based on contact ids
        Map<Id,Contact> contactIdToContactMap =new Map<Id,Contact>([SELECT Id,MQL_Program__c FROM Contact where id in :contactSet]);

        //To check if the contact MQL program is not empty and update the marketing details on corresponding opportunity
        for(OpportunityContactRole obj : oppConRoleList){
            opp= oppIdToOppMap.get(obj.OpportunityId);
            con= contactIdToContactMap.get(obj.contactId);
            if(!String.isEmpty(con.MQL_Program__c)){
                //tempOpp = new Opportunity(Id=opp.Id,StageName=opp.StageName,Misys_Forecast__c=opp.Misys_Forecast__c);
                tempOpp = opp.Clone(true,true,true,true);
                tempOpp.Marketing_Generated_Program__c=con.MQL_Program__c;
                tempOpp.Marketing_Generated_Date__c=Date.today();
                oppsToUpdateList.add(tempOpp);
            }
        }
        //To Update the Opportunities
        if(oppsToUpdateList.size()>0){
    //      update oppsToUpdateList;
        }

    } */

    public static void getChangeOrderOLIsForDelete(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        //Check if the Opportunity recordtype is for Change Requests and if the updated Status is Closed and Lost
        map<Id, Opportunity> mapCRoppsClosedLost = new map<Id,Opportunity>();
        for(Opportunity o : newList){
            if(o.recordtypeid == Label.RecType_Opportunity_ChangeReq && o.Original_Opportunity__c != null){
                if(o.isClosed == true && o.isWon == false && (oldMap.get(o.Id).isClosed != true || oldMap.get(o.Id).isWon != false))
                       // && o.OLIs_Pushed_To_Parent__c
                {
                    //This is a Change Opportunity that has just been marked as Closed and Lost.  Any OLI's copied to the Parent opp now need to be removed.
                    mapCRoppsClosedLost.put(o.Id,o);
                }
            }
        }
        if(mapCRoppsClosedLost.keySet().size() > 0){
            OpportunityServices.getChangeOrderOLIsForDelete(mapCRoppsClosedLost);
        }
    }

    public static void createQuotaCredits(List<Opportunity> opportunities){

        List<Com_Splits__c> splits = new List<Com_Splits__c>();
        RecordType lQuotaRecordType = [SELECT Id FROM RecordType WHERE Name = 'Direct Master Credit' AND sObjectType = 'Com_Splits__c'];

        for(Opportunity opp : opportunities){
            Com_Splits__c lQuotaCredits = new Com_Splits__c();
            lQuotaCredits.Opportunity__c = opp.Id;
            lQuotaCredits.RecordTypeId = lQuotaRecordType.Id;
            lQuotaCredits.Employee_Name__c = opp.OwnerId;
            lQuotaCredits.CurrencyIsoCode = opp.CurrencyIsoCode;
            splits.add(lQuotaCredits);
        }
        insert splits;
    }
    public static List<Id> filterOpptyIdsForPartnerPath(List<Opportunity> opptys){
        List<Id> partnerPathOppList = new List<Id>();
        //To filter the partner opportunities based on partner path Id and the opp record type
        For(Opportunity oppObj: opptys){
            if(oppObj.RecordTypeId == IdManager.OPP_LicensesWithWithoutPSRecTypeId && !String.isEmpty(oppObj.PartnerPath_ID__c))
                partnerPathOppList.add(oppObj.Id);
        }
        return partnerPathOppList;
    }

    public static void handleBatchCall() {
        //To make a synchronous call to PartnerPath if the opportunity update is called from a Batch Apex.
        system.debug('PartnerPathDealUpdateTrigger :: Called from Batch Apex to update PartnerPath deal synchronously');
        /*This method is called when the pearl proposal is pushed to sfdc via Batch Apex.
          Currently this is commented as Opportunity and OLI coming from pearl are heavy and this is a synchronous callout
          to PartnerPath, due to which sfdc bach apex performance will be slowed down.
        */

        //PartnerPathRESTIntegration.sendOppDetailsToPPSync(trigger.new);
    }

    // makes the future call to the partnerpath REST APIs.
    public static void updateDealOnInsertCallout(List<Opportunity> opps){
        List<Id> partnerPathOppList = OpportunityTriggerMethods.filterOpptyIdsForPartnerPath(opps);
        if(!partnerPathOppList.isEmpty()) {
            if(System.isBatch() || System.isFuture()){
                OpportunityTriggerMethods.handleBatchCall();
            }else {
                system.debug('PartnerPathDealUpdateTrigger :: To call the update deal on opp creation');
                PartnerPathRESTIntegration.sendOppDetailsToPartnerPathOnOppCreate(partnerPathOppList);
            }
        }
    }
    // makes the future call to the partnerpath REST APIs.
    public static void updateDealOnUpdateCallout(List<Opportunity> opps){
        List<Id> partnerPathOppList = OpportunityTriggerMethods.filterOpptyIdsForPartnerPath(opps);
        if(!partnerPathOppList.isEmpty()) {
            if(System.isBatch() || System.isFuture()){
                OpportunityTriggerMethods.handleBatchCall();
            }else{
                system.debug('PartnerPathDealUpdateTrigger :: To call the update deal on opp updation');
                PartnerPathRESTIntegration.sendOppDetailsToPartnerPathOnOppUpdate(partnerPathOppList);
            }
        }
    }

    public static void getChangeOrderOLIsForDelete(List<Opportunity> oldList){
        Map<Id, Opportunity> mapCRopps = new Map<Id,Opportunity>();
        //Determine if the OLIs have been pushed to the Parent Opp for this Opp
        for(Opportunity o : oldList){
            /*if(o.OLIs_Pushed_To_Parent__c == true){
                mapCRopps.put(o.Id,o);
            }*/
        }
        if(!mapCRopps.isEmpty()) {
            OpportunityServices.getChangeOrderOLIsForDelete(mapCRopps);
        }
    }

    public static void updateOLIWhenTermMonthsChanged(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {

        Set<Id> setOppId = new Set<Id>();
        Map<Id,OpportunityLineItem> map_OppLineItem = new Map<Id,OpportunityLineItem>();

        for (opportunity opp : newList) {
            if (opp.Term_Estimate_Months__c != oldMap.get(opp.Id).Term_Estimate_Months__c) {
                setOppId.add(opp.id);
            }
        }

        if(!setOppId.isEmpty()) {
            List<OpportunityLineItem> oppLineItems = [Select Id,OpportunityId from OpportunityLineItem where OpportunityId IN:setOppId];
            // we're updating OLIs to trigger rollup for commission values
            if (!oppLineItems.isEmpty()) {
                update oppLineItems;
            }
        }
    }
    public static void notifyGSCentral( List<Opportunity> newList, Map<Id, Opportunity> oldMap ) {


        Map<ID,Opportunity> usrIdToOppMap = new Map<ID,Opportunity>();

        List<Opportunity> oppsToProcess = new List<Opportunity>();
        for(Opportunity opp: newList) {
            if( (OppPipelineUtil.licensesWithOrWithoutPSRecordTypeId == opp.RecordTypeId || OppPipelineUtil.psOnlyRecordTypeId == opp.RecordTypeId || OppPipelineUtil.changeOrderRecordTypeId == opp.RecordTypeId ) 
                        && '4. Develop'==opp.StageName 
                        && null!=opp.PS_Stage__c
                        && '1. Engage'!=opp.PS_Stage__c
                        && null!=opp.PS_Risk_Category__c ) {
                if(opp.Notify_GS__c && opp.Notify_GS__c!=oldMap.get(opp.id).Notify_GS__c) {
                    oppsToProcess.add(opp);

                    OppPipelineUtil.sendEmail(OppPipelineUtil.GS_MAIL_BOX,opp.ID,OppPipelineUtil.PIPELINE_PROJECT_NOTIFY_GS_TEMPLATE);
                }
                if(opp.Notify_GS__c && opp.PS_Deal_Captain__c != null && opp.PS_Deal_Captain__c!=oldMap.get(opp.id).PS_Deal_Captain__c) {
                    usrIdToOppMap.put(opp.PS_Deal_Captain__c,opp);
                }
            }
        }
        System.debug('RTDebug usrIdToOppMap ' + usrIdToOppMap);
        if(!usrIdToOppMap.isEmpty()) {
            List<User> usrs = [select email from User where id in :usrIdToOppMap.keySet()];
        System.debug('RTDebug usrs ' + usrs);
            for(User usr: usrs ) {
                OppPipelineUtil.sendEmail(usr.email,usrIdToOppMap.get(usr.id).ID,OppPipelineUtil.PIPELINE_PROJECT_NOTIFY_DEAL_CAPTAIN_TEMPLATE);
            }
        }
    }
        
   
 
}