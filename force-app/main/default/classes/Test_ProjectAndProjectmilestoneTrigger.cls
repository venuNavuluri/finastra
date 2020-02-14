/*
    Created By: Abhinit Kohar
    Created Date: 14/03/2014
    Description: This is the test class for testing NSProjectTrigger, NSProjecTrigerMethods, NSProjectMilestoneTrigger and NSProjectMilestoneTriggerMethods
 */
@isTest
private class Test_ProjectAndProjectmilestoneTrigger {

    static testMethod void testTriggerBehaviour() {

        NS_Cost_Centre__c cc = new NS_Cost_Centre__c(name = 'A510 SFO - GSC', Is_Inactive__c = false);
        insert cc;

        list<NS_List_Table__c> tableList = new list<NS_List_Table__c>();
        NS_List_Table__c listTable1 = new NS_List_Table__c(NS_List_Name__c = 'OpenAirProjectStage', Name = 'Pipeline', NS_Internal_Id__c = '2');
        tableList.add(listTable1);
        NS_List_Table__c listTable2 = new NS_List_Table__c(NS_List_Name__c = 'SFDCOppForecastCategory', Name = 'Omitted', NS_Internal_Id__c = '2');
        tableList.add(listTable2);
        NS_List_Table__c listTable3 = new NS_List_Table__c(NS_List_Name__c = 'OpenAirProjectTemplate', Name = 'TEMPLATE - Pre-Sales Project', NS_Internal_Id__c = '2');
        tableList.add(listTable3);
        NS_List_Table__c listTable4 = new NS_List_Table__c(NS_List_Name__c = 'ProjectCategory', Name = 'Training', NS_Internal_Id__c = '2');
        tableList.add(listTable4);
        
        insert tableList;
        
        CCRT__c testCCRT = TestUtility.sampleCCRT();
        //testCCRT.Client_Site_Number__c = '12456';
        insert testCCRT;
        
        Account testAcc = TestUtility.sampleAccount();
        testAcc.CCRT_entry__c = testCCRT.Id;
        testAcc.NS_Cash_Accounting__c = true;
        //testAcc.NS_Currency__c = 'a3520000000HM0wAAG';
        insert testAcc;
        
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = testAcc.Id);
        insert btst;
        Bill_To_Ship_To__c btst2 = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 2', Default_Billing__c = false, Account__c = testAcc.Id);
        insert btst2;
        
        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '1');
        insert misysEntity;
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id);
        insert accBySub;
        
        Opportunity testOpp = TestUtility.sampleOpportunity();
        testOpp.AccountId = testAcc.Id;
        testOpp.PS_Cost_Centre__c = cc.id;
        insert testOpp ;

        NS_Product__c product = new NS_Product__c(name = 'test_prod');
        insert product;
        
		NS_Cost_Centre__c gscCostCentre = new NS_Cost_Centre__c(Name = 'A510 SFO - GSC', Include_Children__c = true);
        insert gscCostCentre;

        WAR_Project__c warProject = new  WAR_Project__c(WAR_days__c = 1,Misys_Cost__c = 1, Opportunity__c = testOpp.Id, WAR_Approval_Status__c = 'APPROVED',
                Request_Type__c = 'Initial Days', Initial_Finastra_Cost__c = 100.00);
        insert warProject;
       
        NS_Project__c project = new NS_Project__c(Project_Product__c = product.id, Project_Name__c = 'Test Proj',
                Deferred_Account_Type__c ='PS', Customer__c = accBySub.Id, OpenAir_Project_Stage__c = 'Pipeline',
                Opportunity__c = testOpp.Id, Trickle_Opportunity_Data__c = true,
                SFDC_Opportunity_Category__c = 'Omitted', OA_Project_Template__c = 'TEMPLATE - Pre-Sales Project', Project_Category__c = 'Training');
        //project.Opportunity__c = testOpp.Id,
        insert project;
        
          NS_Project__c gscProject = new NS_Project__c(Project_Product__c = product.id, Project_Name__c = 'Test Proj'
          ,Deferred_Account_Type__c ='GSC', Customer__c = accBySub.Id, OpenAir_Project_Stage__c = 'Pipeline',
                  Opportunity__c = testOpp.Id, Trickle_Opportunity_Data__c = true,
                  SFDC_Opportunity_Category__c = 'Omitted', OA_Project_Template__c = 'TEMPLATE - Pre-Sales Project', Project_Category__c = 'Training');
        //project.Opportunity__c = testOpp.Id,
        insert gscProject ;
        
        system.assertEquals('2', [select Project_Category_Internal_Id__c from NS_Project__c where id = :project.Id].Project_Category_Internal_Id__c);
        
        project.Project_Name__c = 'Update Project';
        update project;
        
     //   system.assertEquals('Update Project', [select Project_Name__c from NS_Project__c where id = :project.Id].Project_Name__c);
         
        
        NS_Project_Milestone__c projMilestone = new NS_Project_Milestone__c(Name = 'Test Milestone', NS_Project__c = project.Id, Start_Date__c = Date.today(), Status__c = 'In Progress');
        insert projMilestone;
        
        system.assertEquals(Date.today(), [select Start_Date__c from NS_Project_Milestone__c where id = :projMilestone.Id].Start_Date__c);
        system.assertEquals('In Progress', [select Status__c from NS_Project_Milestone__c where id = :projMilestone.Id].Status__c);
        
        projMilestone.Status__c = 'Completed';
        update projMilestone;
        
        system.assertEquals('Completed', [select Status__c from NS_Project_Milestone__c where id = :projMilestone.Id].Status__c);
    }
}