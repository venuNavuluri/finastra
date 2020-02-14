public class TaskTriggerHelper
{
    private final static string CASE_OBJECT_PREFIX = '500';
    private final static string CONTACT_OBJECT_PREFIX = '003';
    private final static string LEAD_OBJECT_PREFIX = '00Q';
    private final static string MQL_RECYCLE_STATUS = 'Recycle';
    private final static string SAL_TASK_STATUS = 'Sales Accepted Lead (SAL)';

    private final static string MCL_STATUS = 'Marketing Captured Lead (MCL)';
    private final static string MEL_STATUS = 'Marketing Engaged Lead (MEL)';
    private final static string MQL_STATUS = 'Marketing Qualified Lead (MQL)';
   

    private final static string SQL_STATUS = 'Sales Qualified Lead (SQL)';
    private final static string SQO_STATUS = 'Sales Qualified Opportunity (SQO)';
    private final static string CUSTOMER_STATUS = 'Customer';
    private final static string IN_PROGRESS_STATUS = 'In Progress';
    private final static string NOT_STARTED_STATUS = 'Not Started';
    private final static string COMPLETED_STATUS = 'Completed';
    private final static string MARKETING_FOLLOWUP_TASK_ID = IdManager.MarketingFollowUpRecTypeId;
    private final static string SALES_TASK_RECORDT_TYPE_ID = IdManager.salesTaskRecTypeId;
        
    public static void Process(Task[] triggerNew, Map<id, Task> triggerOldMap)
    {
        Map<string, string> leadQORs = new Map<string, string>();
        Map<string, string> contactQORs = new Map<string, string>();
        Map<string, string> leadStatuses = new Map<string, string>();
        Map<string, string> contactStatuses = new Map<string, string>();
        Task[] taskCaseSurveyEmails = new Task[]{};
        
        set<Id> leadIds = new set<Id>();
        Map<Id, Lead> leadMap;
        set<Id> contactIds = new set<Id>();
        Map<Id, Contact> contactMap;

        // populate the collections:
        categoriseTasks(triggerNew, triggerOldMap, leadIds, contactIds, taskCaseSurveyEmails);

        if(leadIds != null && leadIds.size() > 0){
            leadMap = new Map<Id, Lead>([select Id, Qualified_Out_Reason__c, Status from Lead where Id in :leadIds]);
        }
        if(contactIds != null && contactIds.size() > 0){
            contactMap = new Map<Id, Contact>([select Id, Qualify_Out_Reson__c, Status__c, Contact_Level__c, Product__c from Contact where Id in :contactIds]);
        }
        verifyTaskStatus(leadMap, contactMap, triggerNew, triggerOldMap, leadQORs, leadStatuses, contactQORs, contactStatuses);
        // process the collections:
        system.debug('taskCaseSurveyEmails list: '+taskCaseSurveyEmails);
        if(trigger.isAfter){
            doCaseTasks(taskCaseSurveyEmails);
            doContacts(contactQORs, contactStatuses);
            doLeads(leadQORs, leadStatuses);
        }
    }

    private static void doContacts(Map<string, string> contactQORs, Map<string, string> contactStatuses)
    {
        Contact[] contacts = [select Id, Qualify_Out_Reson__c, Status__c from Contact where Id in :contactQORs.keySet()];
        if (contacts != null) {
            for (Contact c : contacts) {
                c.Qualify_Out_Reson__c = contactQORs.get(c.Id);
                c.Status__c = contactStatuses.get(c.Id);
            }
            update contacts;
        }
    }
    
    private static void doLeads(Map<string, string> leadQORs, Map<string, string> leadStatuses)
    {
        Lead[] leads = [select Id, Qualified_Out_Reason__c, Status from Lead where Id in :leadQORs.keySet()];
        if (leads != null) {
            for (Lead l : leads) {
                l.Qualified_Out_Reason__c = leadQORs.get(l.Id);
                l.Status = leadStatuses.get(l.Id);
            }
            update leads;
        }
    }
    
    private static void verifyTaskStatus(Map<Id, Lead> leadMap, Map<Id, Contact> contactMap, Task[] triggerNew, Map<id, Task> triggerOldMap, 
        Map<string, string> leadQORs, Map<string, string> leadStatuses, Map<string, string> contactQORs, Map<string, string> contactStatuses){
        for (Task t : triggerNew) {
            if(trigger.isAfter){
                if (t.RecordTypeId == MARKETING_FOLLOWUP_TASK_ID && al.StringUtils.isNotEmpty(t.WhoId) && String.valueOf(t.WhoId).startswith(LEAD_OBJECT_PREFIX)) {  // Lead
                    Lead lead;
                    if(leadMap != null && leadMap.containsKey(t.WhoId)){
                        lead = leadMap.get(t.WhoId);
                    }
                    
                    if(lead != null && (lead.status == MCL_STATUS || lead.status == MEL_STATUS || lead.status == MQL_STATUS) && (t.Status == COMPLETED_STATUS)){
                        t.addError('Task can not be closed with the status of Completed. The task status can either be Recyle or Sales Accepted Lead (SAL)');
                    } else if (lead != null && (lead.status == MQL_RECYCLE_STATUS || lead.status == SAL_TASK_STATUS || lead.status == SQL_STATUS
                                || lead.status == SQO_STATUS || lead.status == CUSTOMER_STATUS) 
                                && (t.Status == MQL_RECYCLE_STATUS || t.Status == SAL_TASK_STATUS) ){
                        t.addError('Task can only be closed with the status of Completed.');
                    } else if (toBeProcessed(t, triggerOldMap)) {
                        leadQORs.put(t.WhoId, t.Qualify_Out_Reason__c);
                        leadStatuses.put(t.WhoId, t.Status);
                    }
                } else if (t.RecordTypeId == MARKETING_FOLLOWUP_TASK_ID && al.StringUtils.isNotEmpty(t.WhoId) && String.valueOf(t.WhoId).startswith(CONTACT_OBJECT_PREFIX)) {  // Contact
                    Contact contact;
                    if(contactMap != null && contactMap.containsKey(t.WhoId)){
                        contact = contactMap.get(t.WhoId);
                    }
                    if(contact != null && (contact.Status__c == MCL_STATUS || contact.Status__c == MEL_STATUS || contact.Status__c == MQL_STATUS) && (t.Status == COMPLETED_STATUS)){
                        t.addError('Task can not be closed with the status of Completed. The task status can either be Recyle or Sales Accepted Lead (SAL)');
                    } else if (contact != null && (contact.Status__c == MQL_RECYCLE_STATUS || contact.Status__c == SAL_TASK_STATUS || contact.Status__c == SQL_STATUS
                                || contact.Status__c == SQO_STATUS || contact.Status__c == CUSTOMER_STATUS) 
                                && (t.Status == MQL_RECYCLE_STATUS || t.Status == SAL_TASK_STATUS)){
                        t.addError('Task can only be closed with the status of Completed.');
                    } else if (toBeProcessed(t, triggerOldMap)) {
                        contactQORs.put(t.WhoId, t.Qualify_Out_Reason__c);
                        contactStatuses.put(t.WhoId, t.Status);
                    }
                }
            }
            //This is for getting the value from Contact and putting them in task. 
            else if (trigger.isInsert && trigger.isBefore && t.RecordTypeId == SALES_TASK_RECORDT_TYPE_ID && al.StringUtils.isNotEmpty(t.WhoId) && String.valueOf(t.WhoId).startswith(CONTACT_OBJECT_PREFIX)) {  // Contact
                Contact contact;
                if(contactMap != null && contactMap.containsKey(t.WhoId)){
                    contact = contactMap.get(t.WhoId);
                    if(contact.Contact_Level__c != null){
                        t.Contact_Level__c = contact.Contact_Level__c;
                    }
                    if(contact.Product__c != null){
                        t.Product__c = contact.Product__c;
                    }
                }
            }
        }
    }
    
    private static void categoriseTasks(
        Task[] triggerNew,
        Map<id, Task> triggerOldMap,
        set<Id> leadIds,
        set<Id> contactIds,
        Task[] taskCaseSurveyEmails)
    {
        for (Task t : triggerNew) {
            if (al.StringUtils.isNotEmpty(t.WhatId) && String.valueOf(t.WhatId).startswith(CASE_OBJECT_PREFIX) &&   // Case
                trigger.isInsert)
            {
                if (t.Description != null && t.Description.contains(Label.Case_Survey_Date_Code)) {
                    taskCaseSurveyEmails.add(t);
                }
            }
            if (al.StringUtils.isNotEmpty(t.WhoId) && String.valueOf(t.WhoId).startswith(CONTACT_OBJECT_PREFIX)) {  // Contact
                contactIds.add(t.WhoId);
            }
            else if (al.StringUtils.isNotEmpty(t.WhoId) && String.valueOf(t.WhoId).startswith(LEAD_OBJECT_PREFIX)) {  // Lead
                leadIds.add(t.WhoId);
            }
        }
    }
    
    private static boolean toBeProcessed(Task t, Map<id, Task> triggerOldMap)
    {
        boolean retVal = (
            t.RecordTypeId == IdManager.MarketingFollowUpRecTypeId &&
            (t.Status == MQL_RECYCLE_STATUS || t.Status == SAL_TASK_STATUS)
        );
        if (triggerOldMap != null) {    // update trigger
            Task tOld = triggerOldMap.get(t.Id);
            retVal = (retVal && tOld != null && t.Status != tOld.Status);
        }
        return retVal;
    }
    
    private static void doCaseTasks(Task[] taskCaseSurveyEmails)
    {
        //If any Tasks were found specific to the Case Survey email, call a method to update the Last Survey Date field on the Case
        if(taskCaseSurveyEmails.size()>0)
        {
            //call method to check email
            system.debug('Found Case Tasks!!');
            TaskTriggerMethods.updateCaseSurveyDate(taskCaseSurveyEmails);
        }
    }
    
    //KK: SD Ticket-1468075 : Method added for the MQL task processing requirement. 
    public static void processMarketingMQLTasks(List<Task> mqlTskList){
        List<Task> mqlTaskList=[select id,whoid,Status_Reason__c,Task_Progress_Action__c,status FROM Task where id in :mqlTskList];
        List<Contact> contactList= new List<Contact>();
        Map<Id,Contact> mp_Cont = new Map<Id,Contact>();
        List<Lead> leadList = new List<Lead>();
        List<ID> leadIdList = new List<ID>();
        List<ID> contactIdList= new List<ID>();
        Map<Id,Contact> contactMap = new map<Id,Contact>();
        Map<Id,Lead> leadMap= new map<Id,Lead>();
        String taskProgressAction;
        Id taskWhoId;
        String taskStatusReason;
        List<Task> taskUpdateList = new List<Task>();
        List<Contact> contactsToCampaignList = new List<Contact>();
        List<Lead> leadsToCampaignList = new List<Lead>();
          
                //To separate the contacts and leads linked to the tasks
                for(Task tsk: mqlTaskList){
                     if(tsk.WhoId!=null && (tsk.WhoId.getSobjectType() == Schema.Lead.sObjectType)){
                        leadIdList.add(tsk.WhoId);
                        system.debug('TaskTriggerHelper :: processMarketingMQLTasks :: WhoId is a Lead');
                    }else if(tsk.WhoId!=null && (tsk.WhoId.getSobjectType() == Schema.Contact.sObjectType)){
                        system.debug('TaskTriggerHelper :: processMarketingMQLTasks :: WhoId is a Contact');
                        contactIdList.add(tsk.WhoId);
                    }
                }
                //To fetch the corresponding Lead records into the LeadToIdMap
                if(leadIdList.size()>0){
                   leadMap= new Map<Id,Lead>([SELECT id,Status,Status_Reason__c,Qualified_Out_Reason__c FROM Lead where id in :leadIdList]);
                 // system.debug('TaskTriggerHelper :: processMarketingMQLTasks :: leadMap size --->>' +leadMap.size());
                }
                //To fetch corresponding Contact records into the ContactToIdMap
                if(contactIdList.size()>0){
                    contactMap= new Map<Id,Contact>([SELECT id,Status__c,Status_Reason__c,Qualify_Out_Reson__c FROM Contact where id in :contactIdList]);
                 //   system.debug('TaskTriggerHelper :: processMarketingMQLTasks :: contactMap size --->>' +contactMap.size());
                }
                //To iterate on the task list for processing, based on the 'Task Progress Action' and 'Task Status'
                for(Task taskObj : mqlTaskList){
                    Task tkObj =taskObj.clone(true,true,true,true);
                    taskProgressAction= tkObj.Task_Progress_Action__c;
                    taskWhoId= tkObj.WhoId;
                    taskStatusReason= tkObj.Status_Reason__c; 
                    Lead leadToBeUpdated =null;
                    Contact contactToBeUpdated=null;
                    if(null!=taskWhoId){
                        //To identify whether a Lead or a contact is linked to this task
                        if(leadMap.containsKey(taskWhoId)){
                              leadToBeUpdated= leadMap.get(taskWhoId);
                              tkObj.Lead__c=taskWhoId;
                           //    system.debug('TaskTriggerHelper :: processMarketingMQLTasks :: Lead__c Id is --->>' + tkObj.Lead__c);
                        }else{
                              contactToBeUpdated=contactMap.get(taskWhoId);
                              tkObj.Contact__c=taskWhoId;
                           //   system.debug('TaskTriggerHelper :: processMarketingMQLTasks :: Contact__c Id is --->>' +tkObj.Contact__c);
                        }
                        //If the Task.Status_Reason__c is not empty then copy it to the corresponding Lead/Contact linked to this task    
                        if(!String.isBlank(taskStatusReason)){
                            if(null!=leadToBeUpdated){
                                 leadToBeUpdated.Status_Reason__c=taskStatusReason;
                            }else{
                                 contactToBeUpdated.Status_Reason__c=taskStatusReason;
                            }
                        }
                        //If Task.Task_Progress_Action__c is EMPTY and Task.Status is 'In Progress' then set the Lead/Contact status to 'SAL'
                        if(String.isBlank(taskProgressAction) && tkObj.Status.equals('In Progress')){
                            if(null!=leadToBeUpdated){
                                leadToBeUpdated.Status=Constants.LEAD_CONTACT_STATUS_SAL;
                            }else{
                                contactToBeUpdated.Status__c=Constants.LEAD_CONTACT_STATUS_SAL;
                            }
                        }
                        //Task progress Action is not EMPTY, then process the task as per below conditions
                        else if(!String.isBlank(taskProgressAction)){
                           //When 'Task Progress Action' is set to 'Invalid MQL'
                           if(taskProgressAction.equals(Constants.TASKPROGACT_INVALID_MQL)) {
                                 if(null!=leadToBeUpdated){
                                        leadToBeUpdated.Status=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                        leadToBeUpdated.Qualified_Out_Reason__c=Constants.TASKPROGACT_INVALID_MQL;
                                 }else{
                                        contactToBeUpdated.Status__c=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                        contactToBeUpdated.Qualify_Out_Reson__c=Constants.TASKPROGACT_INVALID_MQL;
                                 }
                                 tkObj.Status=Constants.TASK_STATUS_COMPLETED;
                           }
                           //When 'Task Progress Action' is set to 'Sanctioned Country/Region'
                           else if(taskProgressAction.equals(Constants.TASKPROGACT_SANCTIONED_COUNTRY_REG)) {
                                 if(null!=leadToBeUpdated){
                                        leadToBeUpdated.Status=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                        leadToBeUpdated.Qualified_Out_Reason__c=Constants.TASKPROGACT_SANCTIONED_COUNTRY_REG;
                                 }else{
                                        contactToBeUpdated.Status__c=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                        contactToBeUpdated.Qualify_Out_Reson__c=Constants.TASKPROGACT_SANCTIONED_COUNTRY_REG;
                                 }
                                 tkObj.Status=Constants.TASK_STATUS_COMPLETED;
                           }
                           //When 'Task Progress Action' is set to 'Details Too Generic'
                           else if(taskProgressAction.equals(Constants.TASKPROGACT_DETAILS_TOO_GENERIC)) {
                                 if(null!=leadToBeUpdated){
                                         leadToBeUpdated.Status=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                         leadToBeUpdated.Qualified_Out_Reason__c=Constants.TASKPROGACT_DETAILS_TOO_GENERIC;
                                 }else{
                                        contactToBeUpdated.Status__c=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                        contactToBeUpdated.Qualify_Out_Reson__c=Constants.TASKPROGACT_DETAILS_TOO_GENERIC;
                                 }
                                 tkObj.Status=Constants.TASK_STATUS_COMPLETED;
                           }
                           //When 'Task Progress Action' is set to 'Unresponsive'
                           else if(taskProgressAction.equals(Constants.TASKPROGACT_UNRESPONSIVE)) {
                                 if(null!=leadToBeUpdated){
                                         leadToBeUpdated.Status=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                         leadToBeUpdated.Qualified_Out_Reason__c=Constants.TASKPROGACT_UNRESPONSIVE;
                                 }else{
                                        contactToBeUpdated.Status__c=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                        contactToBeUpdated.Qualify_Out_Reson__c=Constants.TASKPROGACT_UNRESPONSIVE;
                                 }
                                 tkObj.Status=Constants.TASK_STATUS_COMPLETED;
                           }
                           //When 'Task Progress Action' is set to 'Currently in Competitive Contract'
                           else if(taskProgressAction.equals(Constants.TASKPROGACT_COMPETITIVE_CONTRACT)) {
                                 if(null!=leadToBeUpdated){
                                         leadToBeUpdated.Status=Constants.LEAD_CONTACT_STATUS_SAL;
                                         leadToBeUpdated.Status_Reason__c=Constants.TASKPROGACT_COMPETITIVE_CONTRACT;
                                         leadsToCampaignList.add(leadToBeUpdated);
                                 }else{
                                        contactToBeUpdated.Status__c=Constants.LEAD_CONTACT_STATUS_SAL;
                                        contactToBeUpdated.Status_Reason__c=Constants.TASKPROGACT_COMPETITIVE_CONTRACT;
                                        contactsToCampaignList.add(contactToBeUpdated);
                                 }
                                 tkObj.Status=Constants.TASK_STATUS_COMPLETED;
                           }
                           //When 'Task Progress Action' is set to 'Not an appropriate contact'
                           else if(taskProgressAction.equals(Constants.TASKPROGACT_INAPPROPRIATE_CONTACT)) {
                                 if(null!=leadToBeUpdated){
                                         leadToBeUpdated.Status=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                         leadToBeUpdated.Qualified_Out_Reason__c=Constants.TASKPROGACT_INAPPROPRIATE_CONTACT;
                                 }else{
                                        contactToBeUpdated.Status__c=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                        contactToBeUpdated.Qualify_Out_Reson__c=Constants.TASKPROGACT_INAPPROPRIATE_CONTACT;
                                 }
                                 tkObj.Status=Constants.TASK_STATUS_COMPLETED;
                           }
                           //When 'Task Progress Action' is set to 'No current need'
                           else if(taskProgressAction.equals(Constants.TASKPROGACT_NO_CURRENT_NEED)) {
                                 if(null!=leadToBeUpdated){
                                         leadToBeUpdated.Status=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                         leadToBeUpdated.Qualified_Out_Reason__c=Constants.TASKPROGACT_NO_CURRENT_NEED;
                                 }else{
                                        contactToBeUpdated.Status__c=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                        contactToBeUpdated.Qualify_Out_Reson__c=Constants.TASKPROGACT_NO_CURRENT_NEED;
                                 }
                                 tkObj.Status=Constants.TASK_STATUS_COMPLETED;
                           }
                           //When 'Task Progress Action' is set to 'Interested for research'
                           else if(taskProgressAction.equals(Constants.TASKPROGACT_INTERESTED_FOR_RESEARCH)) {
                                 if(null!=leadToBeUpdated){
                                         leadToBeUpdated.Status=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                         leadToBeUpdated.Qualified_Out_Reason__c=Constants.TASKPROGACT_INTERESTED_FOR_RESEARCH;
                                 }else{
                                        contactToBeUpdated.Status__c=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                        contactToBeUpdated.Qualify_Out_Reson__c=Constants.TASKPROGACT_INTERESTED_FOR_RESEARCH;
                                 }
                                 tkObj.Status=Constants.TASK_STATUS_COMPLETED;
                           }
                           //When 'Task Progress Action' is set to 'Misys Solution Not Suitable'
                           else if(taskProgressAction.equals(Constants.TASKPROGACT_SOLN_NOT_SUITABLE)) {
                                 if(null!=leadToBeUpdated){
                                         leadToBeUpdated.Status=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                         leadToBeUpdated.Qualified_Out_Reason__c=Constants.TASKPROGACT_SOLN_NOT_SUITABLE;
                                 }else{
                                        contactToBeUpdated.Status__c=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                        contactToBeUpdated.Qualify_Out_Reson__c=Constants.TASKPROGACT_SOLN_NOT_SUITABLE;
                                 }
                                 tkObj.Status=Constants.TASK_STATUS_COMPLETED;
                           }
                            //When 'Task Progress Action' is set to 'Opportunity Created'
                           else if(taskProgressAction.equals(Constants.TASKPROGACT_OPPORTUNITY_CREATED)) {
                                 tkObj.Status=Constants.TASK_STATUS_COMPLETED;
                           }
                            //When 'Task Progress Action' is set to 'Competitor'
                           else if(taskProgressAction.equals(Constants.TASKPROGACT_COMPETITOR)) {
                                 if(null!=leadToBeUpdated){
                                         leadToBeUpdated.Status=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                         leadToBeUpdated.Qualified_Out_Reason__c=Constants.TASKPROGACT_COMPETITOR;
                                 }else{
                                        contactToBeUpdated.Status__c=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                        contactToBeUpdated.Qualify_Out_Reson__c=Constants.TASKPROGACT_COMPETITOR;
                                 }
                                 tkObj.Status=Constants.TASK_STATUS_COMPLETED;
                           }
                            //When 'Task Progress Action' is set to 'Strategic Account'
                           else if(taskProgressAction.equals(Constants.TASKPROGACT_STRATEGIC_ACCOUNT)) {
                                 if(null!=leadToBeUpdated){
                                         leadToBeUpdated.Status=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                         leadToBeUpdated.Qualified_Out_Reason__c=Constants.TASKPROGACT_STRATEGIC_ACCOUNT;
                                 }else{
                                        contactToBeUpdated.Status__c=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                        contactToBeUpdated.Qualify_Out_Reson__c=Constants.TASKPROGACT_STRATEGIC_ACCOUNT;
                                 }
                                 tkObj.Status=Constants.TASK_STATUS_COMPLETED;
                           }
                            //When 'Task Progress Action' is set to 'Consultant/Technology Provider'
                           else if(taskProgressAction.equals(Constants.TASKPROGACT_CONSULTANT_TECH_PROVIDER)) {
                                 if(null!=leadToBeUpdated){
                                         leadToBeUpdated.Status=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                         leadToBeUpdated.Qualified_Out_Reason__c=Constants.TASKPROGACT_CONSULTANT_TECH_PROVIDER;
                                 }else{
                                        contactToBeUpdated.Status__c=Constants.LEAD_CONTACT_STATUS_RECYCLE;
                                        contactToBeUpdated.Qualify_Out_Reson__c=Constants.TASKPROGACT_CONSULTANT_TECH_PROVIDER;
                                 }
                                 tkObj.Status=Constants.TASK_STATUS_COMPLETED;
                           }
                            //When 'Task Progress Action' is set to 'Existing Opportunity'
                           else if(taskProgressAction.equals(Constants.TASKPROGACT_EXISTING_OPPORTUNITY)) {
                                if(null!=leadToBeUpdated){
                                         leadToBeUpdated.Status=Constants.LEAD_CONTACT_STATUS_SAL;
                                 }else{
                                        contactToBeUpdated.Status__c=Constants.LEAD_CONTACT_STATUS_SAL;
                                 }
                                 tkObj.Status=Constants.TASK_STATUS_COMPLETED;
                           }
                        }
                     //To add the Lead/contact to the list inorder to update the record
                     if(null!=leadToBeUpdated){
                         leadList.add(leadToBeUpdated);
                     }else{
                         mp_Cont.put(contactToBeUpdated.id,contactToBeUpdated);
                         contactList.add(contactToBeUpdated);
                     }
                     //To add the task to taskUpdateList inorder to update the record
                     taskUpdateList.add(tkObj);
                    }
                }
                 
                //To update the relevant MQL Tasks and their linked Lead/Contact records
                if(leadList.size()>0){
                    update leadList;
                }
                
                if(mp_Cont!=null && mp_Cont.values()!=null)
                  update mp_Cont.values();
             
             /*   if(contactList.size()>0)
                    update contactList;
             */
                
                //To Add the Lead/ contact to the Marketing MQL Campaign if the Task Progress Action is 'Currently in Competitive Contract'
                if(leadsToCampaignList.size()>0 || contactsToCampaignList.size()>0){
                     addContactOrLeadToMarketingCampaign(leadsToCampaignList,contactsToCampaignList);
                 }
                //To Update the task list
                if(taskUpdateList.size()>0){
                    update taskUpdateList;
                }
                  
    }
    
    public static void addContactOrLeadToMarketingCampaign(List<Lead> leadsToCampaignList, List<Contact>contactsToCampaignList){
       // String campaignName = Constants.MQL_MARKETING_CAMPAIGN_NAME;
        List<CampaignMember> campMemberList = new List<CampaignMember>(); 
       //To Fetch the specific Marketing MQL campaign 'Develop and Nurture'
        List<Campaign> camp = [SELECT Id,Name FROM Campaign WHERE Name Like :Label.Marketing_MQL_Nurture_Campaign AND IsActive=true limit 1];
        if(!camp.isEmpty()){
            ID campaignId=camp[0].id;
            //To fetch the Contacts present under the above campaign
            Map<Id, CampaignMember> LeadIdToCampaignMemberMap = new Map<Id, CampaignMember>([SELECT LeadId FROM CampaignMember WHERE campaignid= :campaignId]);
            //To fetch the Leads present under the above campaign
            Map<Id, CampaignMember> ContactIdToCampaignMap = new Map<Id, CampaignMember>([SELECT ContactId FROM CampaignMember WHERE campaignid= :campaignId]);
            //To add Contact as a campaign member
            for(Contact conObj :contactsToCampaignList){
                if(ContactIdToCampaignMap.containsKey(conObj.id)){
                    continue;
                }else{
                    CampaignMember campMember= new CampaignMember(CampaignId=camp[0].id,ContactId = conObj.Id,status =Label.Marketing_MQL_Nurture_Campaign_Member_Status); 
                    campMemberList.add(campMember);
                }
                
            }
            //To add Lead as a campaign member
            for(Lead leadObj :leadsToCampaignList){
                if(LeadIdToCampaignMemberMap.containsKey(leadObj.id)){
                    continue;
                }else{
                    CampaignMember campMember= new CampaignMember(CampaignId=camp[0].id,LeadId = leadObj.Id,status = Label.Marketing_MQL_Nurture_Campaign_Member_Status); 
                    campMemberList.add(campMember);
                }
                
            }
        }
        //To create the new campaign members
        if(campMemberList.size()>0){
             try {
                    Database.insert(campMemberList);
                 }catch (Exception ex) {
                    System.Debug('Insert failed ' + ex);
                 }
        }
        
    }
}