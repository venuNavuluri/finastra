@isTest
private class TestTaskTriggerHelper_MQLTasks{

    @testSetup
    private static void setup(){
        Campaign camp = new Campaign(Name = Label.Marketing_MQL_Nurture_Campaign, IsActive = true);
        insert camp;
    }

    private static List<Task> createLeadTasks(){
        List<Lead> leadList = new List<Lead>();
        List<Task> taskList = new List<Task>();
        integer i;
        integer j;
        for(i = 0; i < 14; i++){
            Lead l = TestUtility.sampleLead();
            l.FirstName = 'First'+i;
            l.LastName = 'Last'+i;
            l.Status = 'Marketing Qualified Lead (MQL)';
            l.Area_of_interest__c = 'Capital Markets';
            if(i == 9){
                l.Status = 'Sales Accepted Lead (SAL)';
            }
            leadList.add(l);
        }
        insert leadList;
        for(j = 0; j < leadList.size(); j++){
            Task t = TestUtility.sampleTask();
            t.WhoId = leadList.get(j).Id;
            t.RecordTypeId = IdManager.MarketingFollowUpRecTypeId;
            t.subject = label.Marketing_MQL_Task_Subject;
            t.status = 'Not Started';
            taskList.add(t);
        }
        return taskList;
    }

    private static List<Task> createContactTasks(){
        List<Contact> contactList = new List<Contact>();
        List<Task> taskList = new List<Task>();
        integer i;
        integer j;
        for(i = 0; i < 14; i++){
            contact cs = TestUtility.sampleContact();
            cs.FirstName = 'First'+i;
            cs.LastName = 'Last'+i;
            cs.status__c = 'Marketing Qualified Lead (MQL)';
            if(i == 9){
                cs.status__c = 'Sales Accepted Lead (SAL)';
            }
            contactList.add(cs);
        }
        insert contactList;
        for(j = 0; j < contactList.size(); j++){
            Task t = TestUtility.sampleTask();
            t.WhoId = contactList.get(j).Id;
            t.RecordTypeId = IdManager.MarketingFollowUpRecTypeId;
            t.subject = label.Marketing_MQL_Task_Subject;
            t.status = 'Not Started';
            taskList.add(t);
        }
        return taskList;
    }

    public static testMethod void testLeadMQLTasks_Insert(){
        //To create the tasks linked to Leads and then insert them with different 'Task Progress Actions'
        List<Task> taskList = createLeadTasks();
        List<Id> LeadIds = new List<Id>();

        Task task0 = taskList.get(0);
        task0.Task_Progress_Action__c = Constants.TASKPROGACT_INVALID_MQL;
        task0.Status_Reason__c = 'Test MQL task 0 status reason';
        Task task1 = taskList.get(1);
        task1.Task_Progress_Action__c = Constants.TASKPROGACT_SANCTIONED_COUNTRY_REG;
        task1.Status_Reason__c = 'Test MQL task 1 status reason';
        Task task2 = taskList.get(2);
        task2.Task_Progress_Action__c = Constants.TASKPROGACT_DETAILS_TOO_GENERIC;
        task2.Status_Reason__c = 'Test MQL task 2 status reason';
        Task task3 = taskList.get(3);
        task3.Task_Progress_Action__c = Constants.TASKPROGACT_UNRESPONSIVE;
        task3.Status_Reason__c = 'Test MQL task 3 status reason';
        Task task4 = taskList.get(4);
        task4.Task_Progress_Action__c = Constants.TASKPROGACT_COMPETITIVE_CONTRACT;
        task4.Status_Reason__c = 'Test MQL task 4 status reason';
        Task task5 = taskList.get(5);
        task5.Task_Progress_Action__c = Constants.TASKPROGACT_INAPPROPRIATE_CONTACT;
        task5.Status_Reason__c = 'Test MQL task 5 status reason';
        Task task6 = taskList.get(6);
        task6.Task_Progress_Action__c = Constants.TASKPROGACT_NO_CURRENT_NEED;
        task6.Status_Reason__c = 'Test MQL task 6 status reason';
        Task task7 = taskList.get(7);
        task7.Task_Progress_Action__c = Constants.TASKPROGACT_INTERESTED_FOR_RESEARCH;
        task7.Status_Reason__c = 'Test MQL task 7 status reason';
        Task task8 = taskList.get(8);
        task8.Task_Progress_Action__c = Constants.TASKPROGACT_SOLN_NOT_SUITABLE;
        task8.Status_Reason__c = 'Test MQL task 8 status reason';
        Task task9 = taskList.get(9);
        task9.Task_Progress_Action__c = Constants.TASKPROGACT_OPPORTUNITY_CREATED;
        task9.Status_Reason__c = 'Test MQL task 9 status reason';
        Task task10 = taskList.get(10);
        task10.Task_Progress_Action__c = Constants.TASKPROGACT_COMPETITOR;
        task10.Status_Reason__c = 'Test MQL task 10 status reason';
        Task task11 = taskList.get(11);
        task11.Task_Progress_Action__c = Constants.TASKPROGACT_STRATEGIC_ACCOUNT;
        task11.Status_Reason__c = 'Test MQL task 11 status reason';
        Task task12 = taskList.get(12);
        task12.Task_Progress_Action__c = Constants.TASKPROGACT_CONSULTANT_TECH_PROVIDER;
        task12.Status_Reason__c = 'Test MQL task 12 status reason';
        Task task13 = taskList.get(13);
        task13.Task_Progress_Action__c = Constants.TASKPROGACT_EXISTING_OPPORTUNITY;
        task13.Status_Reason__c = 'Test MQL task 13 status reason';

        insert taskList;

        Map<Id, Task> taskMap = new map<Id, Task>([SELECT id, Task_Progress_Action__c, whoid, Status_Reason__c,status FROM Task where id in :taskList]);
        for(Task tk : taskMap.values()){
            LeadIds.add(tk.whoId);
        }
        Map<Id, Lead> leadMap = new map<Id, Lead>([SELECT id, Status, Status_Reason__c, Qualified_Out_Reason__c FROM Lead where id in :LeadIds]);

        //Task Progress Action = 'Invalid MQL'
        system.assertEquals(taskMap.get(task0.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(LeadMap.get(task0.WhoId).status, Constants.LEAD_CONTACT_STATUS_RECYCLE);
        system.assertEquals(LeadMap.get(task0.WhoId).Qualified_Out_Reason__c, Constants.TASKPROGACT_INVALID_MQL);
        system.assertEquals(LeadMap.get(task0.WhoId).Status_Reason__c, 'Test MQL task 0 status reason');
        //Task Progress Action = 'Sanctioned Country/Region'
        system.assertEquals(taskMap.get(task1.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(LeadMap.get(task1.WhoId).status, Constants.LEAD_CONTACT_STATUS_RECYCLE);
        system.assertNotEquals(LeadMap.get(task1.WhoId).Status_Reason__c, 'Test MQL task 1 status reason');
        system.assertEquals(LeadMap.get(task1.WhoId).Status_Reason__c, Constants.LEAD_CONTACT_STATUS_NOT_A_LEAD);
        //Task Progress Action = 'Details Too Generic'
        system.assertEquals(taskMap.get(task2.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(LeadMap.get(task2.WhoId).status, Constants.LEAD_CONTACT_STATUS_RECYCLE);
        system.assertEquals(LeadMap.get(task2.WhoId).Qualified_Out_Reason__c, Constants.TASKPROGACT_DETAILS_TOO_GENERIC);
        system.assertEquals(LeadMap.get(task2.WhoId).Status_Reason__c, 'Test MQL task 2 status reason');
        //Task Progress Action = 'Unresponsive'
        system.assertEquals(taskMap.get(task3.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(LeadMap.get(task3.WhoId).status, Constants.LEAD_CONTACT_STATUS_RECYCLE);
        system.assertEquals(LeadMap.get(task3.WhoId).Qualified_Out_Reason__c, Constants.TASKPROGACT_UNRESPONSIVE);
        system.assertEquals(LeadMap.get(task3.WhoId).Status_Reason__c, 'Test MQL task 3 status reason');
        //Task Progress Action = 'Currently in Competitive Contract'
        system.assertEquals(taskMap.get(task4.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(LeadMap.get(task4.WhoId).status, Constants.LEAD_CONTACT_STATUS_SAL);
        system.assertNotEquals(LeadMap.get(task4.WhoId).Status_Reason__c, 'Test MQL task 4 status reason');
        system.assertEquals(LeadMap.get(task4.WhoId).Status_Reason__c, Constants.TASKPROGACT_COMPETITIVE_CONTRACT);
        //Task Progress Action = 'Not an appropriate contact'
        system.assertEquals(taskMap.get(task5.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(LeadMap.get(task5.WhoId).status, Constants.LEAD_CONTACT_STATUS_RECYCLE);
        system.assertEquals(LeadMap.get(task5.WhoId).Qualified_Out_Reason__c, Constants.TASKPROGACT_INAPPROPRIATE_CONTACT);
        system.assertEquals(LeadMap.get(task5.WhoId).Status_Reason__c, 'Test MQL task 5 status reason');
        //Task Progress Action = 'No current need'
        system.assertEquals(taskMap.get(task6.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(LeadMap.get(task6.WhoId).status, Constants.LEAD_CONTACT_STATUS_RECYCLE);
        system.assertEquals(LeadMap.get(task6.WhoId).Qualified_Out_Reason__c, Constants.TASKPROGACT_NO_CURRENT_NEED);
        system.assertEquals(LeadMap.get(task6.WhoId).Status_Reason__c, 'Test MQL task 6 status reason');
        //Task Progress Action = 'Interested for research'
        system.assertEquals(taskMap.get(task7.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(LeadMap.get(task7.WhoId).status, Constants.LEAD_CONTACT_STATUS_RECYCLE);
        system.assertEquals(LeadMap.get(task7.WhoId).Qualified_Out_Reason__c, Constants.TASKPROGACT_INTERESTED_FOR_RESEARCH);
        system.assertEquals(LeadMap.get(task7.WhoId).Status_Reason__c, 'Test MQL task 7 status reason');
        //Task Progress Action = 'Misys Solution Not Suitable'
        system.assertEquals(Constants.TASK_STATUS_COMPLETED, taskMap.get(task8.Id).status);
        system.assertEquals(Constants.LEAD_CONTACT_STATUS_RECYCLE, LeadMap.get(task8.WhoId).status);
        system.assertEquals(Constants.TASKPROGACT_SOLN_NOT_SUITABLE, LeadMap.get(task8.WhoId).Qualified_Out_Reason__c);
        system.assertEquals('Test MQL task 8 status reason', LeadMap.get(task8.WhoId).Status_Reason__c);
        //Task Progress Action = 'Opportunity Created'
        system.assertEquals(Constants.TASK_STATUS_COMPLETED, taskMap.get(task9.Id).status);
        system.assertEquals('Test MQL task 9 status reason', LeadMap.get(task9.WhoId).Status_Reason__c);
        //Task Progress Action = 'Competitor'
        system.assertEquals(Constants.TASK_STATUS_COMPLETED, taskMap.get(task10.Id).status);
        system.assertEquals(Constants.LEAD_CONTACT_STATUS_RECYCLE, LeadMap.get(task10.WhoId).status);
        system.assertEquals(Constants.TASKPROGACT_COMPETITOR, LeadMap.get(task10.WhoId).Qualified_Out_Reason__c);
        system.assertEquals('Test MQL task 10 status reason', LeadMap.get(task10.WhoId).Status_Reason__c);
        //Task Progress Action = 'Strategic Account'
        system.assertEquals(Constants.TASK_STATUS_COMPLETED, taskMap.get(task11.Id).status);
        system.assertEquals(Constants.LEAD_CONTACT_STATUS_RECYCLE, LeadMap.get(task11.WhoId).status);
        system.assertEquals(Constants.TASKPROGACT_STRATEGIC_ACCOUNT, LeadMap.get(task11.WhoId).Qualified_Out_Reason__c);
        system.assertEquals('Test MQL task 11 status reason', LeadMap.get(task11.WhoId).Status_Reason__c);
        //Task Progress Action = 'Consultant/Technology Provider'
        system.assertEquals(Constants.TASK_STATUS_COMPLETED, taskMap.get(task12.Id).status);
        system.assertEquals(Constants.LEAD_CONTACT_STATUS_RECYCLE, LeadMap.get(task12.WhoId).status);
        system.assertEquals(Constants.TASKPROGACT_CONSULTANT_TECH_PROVIDER, LeadMap.get(task12.WhoId).Qualified_Out_Reason__c);
        system.assertEquals('Test MQL task 12 status reason', LeadMap.get(task12.WhoId).Status_Reason__c);
        //Task Progress Action = 'Existing Opportunity'
        system.assertEquals(Constants.TASK_STATUS_COMPLETED, taskMap.get(task13.Id).status);
        system.assertEquals(Constants.LEAD_CONTACT_STATUS_SAL, LeadMap.get(task13.WhoId).status);
        system.assertEquals('Test MQL task 13 status reason', LeadMap.get(task13.WhoId).Status_Reason__c);
    }

    public static testMethod void testContactMQLTasks_Insert(){
        //To create the tasks linked to Leads and then insert them with different 'Task Progress Actions'
        List<Task> taskList = createContactTasks();
        List<Id> ContactIds = new List<Id>();

        Task task0 = taskList.get(0);
        task0.Task_Progress_Action__c = Constants.TASKPROGACT_INVALID_MQL;
        task0.Status_Reason__c = 'Test MQL task 0 status reason';
        Task task1 = taskList.get(1);
        task1.Task_Progress_Action__c = Constants.TASKPROGACT_SANCTIONED_COUNTRY_REG;
        task1.Status_Reason__c = 'Test MQL task 1 status reason';
        Task task2 = taskList.get(2);
        task2.Task_Progress_Action__c = Constants.TASKPROGACT_DETAILS_TOO_GENERIC;
        task2.Status_Reason__c = 'Test MQL task 2 status reason';
        Task task3 = taskList.get(3);
        task3.Task_Progress_Action__c = Constants.TASKPROGACT_UNRESPONSIVE;
        task3.Status_Reason__c = 'Test MQL task 3 status reason';
        Task task4 = taskList.get(4);
        task4.Task_Progress_Action__c = Constants.TASKPROGACT_COMPETITIVE_CONTRACT;
        task4.Status_Reason__c = 'Test MQL task 4 status reason';
        Task task5 = taskList.get(5);
        task5.Task_Progress_Action__c = Constants.TASKPROGACT_INAPPROPRIATE_CONTACT;
        task5.Status_Reason__c = 'Test MQL task 5 status reason';
        Task task6 = taskList.get(6);
        task6.Task_Progress_Action__c = Constants.TASKPROGACT_NO_CURRENT_NEED;
        task6.Status_Reason__c = 'Test MQL task 6 status reason';
        Task task7 = taskList.get(7);
        task7.Task_Progress_Action__c = Constants.TASKPROGACT_INTERESTED_FOR_RESEARCH;
        task7.Status_Reason__c = 'Test MQL task 7 status reason';
        Task task8 = taskList.get(8);
        task8.Task_Progress_Action__c = Constants.TASKPROGACT_SOLN_NOT_SUITABLE;
        task8.Status_Reason__c = 'Test MQL task 8 status reason';
        Task task9 = taskList.get(9);
        task9.Task_Progress_Action__c = Constants.TASKPROGACT_OPPORTUNITY_CREATED;
        task9.Status_Reason__c = 'Test MQL task 9 status reason';
        Task task10 = taskList.get(10);
        task10.Task_Progress_Action__c = Constants.TASKPROGACT_COMPETITOR;
        task10.Status_Reason__c = 'Test MQL task 10 status reason';
        Task task11 = taskList.get(11);
        task11.Task_Progress_Action__c = Constants.TASKPROGACT_STRATEGIC_ACCOUNT;
        task11.Status_Reason__c = 'Test MQL task 11 status reason';
        Task task12 = taskList.get(12);
        task12.Task_Progress_Action__c = Constants.TASKPROGACT_CONSULTANT_TECH_PROVIDER;
        task12.Status_Reason__c = 'Test MQL task 12 status reason';
        Task task13 = taskList.get(13);
        task13.Task_Progress_Action__c = Constants.TASKPROGACT_EXISTING_OPPORTUNITY;
        task13.Status_Reason__c = 'Test MQL task 13 status reason';

        insert taskList;

        Map<Id, Task> taskMap = new map<Id, Task>([SELECT id, Task_Progress_Action__c, whoid, Status_Reason__c,status FROM Task where id in :taskList]);
        for(Task tk : taskMap.values()){
            ContactIds.add(tk.whoId);
        }
        Map<Id, Contact> ContactMap = new map<Id, Contact>([SELECT id, Status__c, Status_Reason__c, Qualify_Out_Reson__c FROM Contact where id in :ContactIds]);

        //Task Progress Action = 'Invalid MQL'
        system.assertEquals(taskMap.get(task0.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(ContactMap.get(task0.WhoId).status__c, Constants.LEAD_CONTACT_STATUS_RECYCLE);
        system.assertEquals(ContactMap.get(task0.WhoId).Qualify_Out_Reson__c, Constants.TASKPROGACT_INVALID_MQL);
        system.assertEquals(ContactMap.get(task0.WhoId).Status_Reason__c, 'Test MQL task 0 status reason');
        //Task Progress Action = 'Sanctioned Country/Region'
        system.assertEquals(taskMap.get(task1.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(ContactMap.get(task1.WhoId).status__c, Constants.LEAD_CONTACT_STATUS_RECYCLE);
        system.assertNotEquals(ContactMap.get(task1.WhoId).Status_Reason__c, 'Test MQL task 1 status reason');
        system.assertEquals(ContactMap.get(task1.WhoId).Status_Reason__c, Constants.LEAD_CONTACT_STATUS_NOT_A_LEAD);
        //Task Progress Action = 'Details Too Generic'
        system.assertEquals(taskMap.get(task2.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(ContactMap.get(task2.WhoId).status__c, Constants.LEAD_CONTACT_STATUS_RECYCLE);
        system.assertEquals(ContactMap.get(task2.WhoId).Qualify_Out_Reson__c, Constants.TASKPROGACT_DETAILS_TOO_GENERIC);
        system.assertEquals(ContactMap.get(task2.WhoId).Status_Reason__c, 'Test MQL task 2 status reason');
        //Task Progress Action = 'Unresponsive'
        system.assertEquals(taskMap.get(task3.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(ContactMap.get(task3.WhoId).status__c, Constants.LEAD_CONTACT_STATUS_RECYCLE);
        system.assertEquals(ContactMap.get(task3.WhoId).Qualify_Out_Reson__c, Constants.TASKPROGACT_UNRESPONSIVE);
        system.assertEquals(ContactMap.get(task3.WhoId).Status_Reason__c, 'Test MQL task 3 status reason');
        //Task Progress Action = 'Currently in Competitive Contract'
        system.assertEquals(taskMap.get(task4.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(ContactMap.get(task4.WhoId).status__c, Constants.LEAD_CONTACT_STATUS_SAL);
        system.assertNotEquals(ContactMap.get(task4.WhoId).Status_Reason__c, 'Test MQL task 4 status reason');
        system.assertEquals(ContactMap.get(task4.WhoId).Status_Reason__c, Constants.TASKPROGACT_COMPETITIVE_CONTRACT);
        //Task Progress Action = 'Not an appropriate contact'
        system.assertEquals(taskMap.get(task5.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(ContactMap.get(task5.WhoId).status__c, Constants.LEAD_CONTACT_STATUS_RECYCLE);
        system.assertEquals(ContactMap.get(task5.WhoId).Qualify_Out_Reson__c, Constants.TASKPROGACT_INAPPROPRIATE_CONTACT);
        system.assertEquals(ContactMap.get(task5.WhoId).Status_Reason__c, 'Test MQL task 5 status reason');
        //Task Progress Action = 'No current need'
        system.assertEquals(taskMap.get(task6.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(ContactMap.get(task6.WhoId).status__c, Constants.LEAD_CONTACT_STATUS_RECYCLE);
        system.assertEquals(ContactMap.get(task6.WhoId).Qualify_Out_Reson__c, Constants.TASKPROGACT_NO_CURRENT_NEED);
        system.assertEquals(ContactMap.get(task6.WhoId).Status_Reason__c, 'Test MQL task 6 status reason');
        //Task Progress Action = 'Interested for research'
        system.assertEquals(taskMap.get(task7.Id).status, Constants.TASK_STATUS_COMPLETED);
        system.assertEquals(ContactMap.get(task7.WhoId).status__c, Constants.LEAD_CONTACT_STATUS_RECYCLE);
        system.assertEquals(ContactMap.get(task7.WhoId).Qualify_Out_Reson__c, Constants.TASKPROGACT_INTERESTED_FOR_RESEARCH);
        system.assertEquals(ContactMap.get(task7.WhoId).Status_Reason__c, 'Test MQL task 7 status reason');
        //Task Progress Action = 'Misys Solution Not Suitable'
        system.assertEquals(Constants.TASK_STATUS_COMPLETED, taskMap.get(task8.Id).status);
        system.assertEquals(Constants.LEAD_CONTACT_STATUS_RECYCLE, ContactMap.get(task8.WhoId).status__c);
        system.assertEquals(Constants.TASKPROGACT_SOLN_NOT_SUITABLE, ContactMap.get(task8.WhoId).Qualify_Out_Reson__c);
        system.assertEquals('Test MQL task 8 status reason', ContactMap.get(task8.WhoId).Status_Reason__c);
        //Task Progress Action = 'Opportunity Created'
        system.assertEquals(Constants.TASK_STATUS_COMPLETED, taskMap.get(task9.Id).status);
        system.assertEquals('Test MQL task 9 status reason', ContactMap.get(task9.WhoId).Status_Reason__c);
        //Task Progress Action = 'Competitor'
        system.assertEquals(Constants.TASK_STATUS_COMPLETED, taskMap.get(task10.Id).status);
        system.assertEquals(Constants.LEAD_CONTACT_STATUS_RECYCLE, ContactMap.get(task10.WhoId).status__c);
        system.assertEquals(Constants.TASKPROGACT_COMPETITOR, ContactMap.get(task10.WhoId).Qualify_Out_Reson__c);
        system.assertEquals('Test MQL task 10 status reason', ContactMap.get(task10.WhoId).Status_Reason__c);
        //Task Progress Action = 'Strategic Account'
        system.assertEquals(Constants.TASK_STATUS_COMPLETED, taskMap.get(task11.Id).status);
        system.assertEquals(Constants.LEAD_CONTACT_STATUS_RECYCLE, ContactMap.get(task11.WhoId).status__c);
        system.assertEquals(Constants.TASKPROGACT_STRATEGIC_ACCOUNT, ContactMap.get(task11.WhoId).Qualify_Out_Reson__c);
        system.assertEquals('Test MQL task 11 status reason', ContactMap.get(task11.WhoId).Status_Reason__c);
        //Task Progress Action = 'Consultant/Technology Provider'
        system.assertEquals(Constants.TASK_STATUS_COMPLETED, taskMap.get(task12.Id).status);
        system.assertEquals(Constants.LEAD_CONTACT_STATUS_RECYCLE, ContactMap.get(task12.WhoId).status__c);
        system.assertEquals(Constants.TASKPROGACT_CONSULTANT_TECH_PROVIDER, ContactMap.get(task12.WhoId).Qualify_Out_Reson__c);
        system.assertEquals('Test MQL task 12 status reason', ContactMap.get(task12.WhoId).Status_Reason__c);
        //Task Progress Action = 'Existing Opportunity'
        system.assertEquals(Constants.TASK_STATUS_COMPLETED, taskMap.get(task13.Id).status);
        system.assertEquals(Constants.LEAD_CONTACT_STATUS_SAL, ContactMap.get(task13.WhoId).status__c);
        system.assertEquals('Test MQL task 13 status reason', ContactMap.get(task13.WhoId).Status_Reason__c);
    }
}