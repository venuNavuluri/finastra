/**
 * Created by Nina Gronowska on 28/09/2017.
 */
@isTest
private class NSProjectMilestoneTriggerMethods_Test{

    @isTest
    private static void shouldUpdateSyncFlag(){

        NS_Product__c product = new NS_Product__c(name = 'test_prod');
        insert product;

        NS_Project__c project = new NS_Project__c(Project_Product__c = product.id, Project_Name__c = 'Test Proj',
                Deferred_Account_Type__c ='PS', OpenAir_Project_Stage__c = 'Pipeline',
                SFDC_Opportunity_Category__c = 'Omitted', OA_Project_Template__c = 'TEMPLATE - Pre-Sales Project',
                Project_Category__c = 'Training');
        insert project;


        NS_Project_Milestone__c milestone = new NS_Project_Milestone__c();
        milestone.Status__c = 'Not Started';
        milestone.Synced_To_NS__c = true;
        milestone.NS_Project__c = project.Id;
        insert milestone;

        NS_Project_Milestone__c result = [select Synced_To_NS__c from NS_Project_Milestone__c where id = :milestone.Id];
        system.assertEquals(true, result.Synced_To_NS__c);

        milestone.Status__c = '	In Progress';
        update milestone;

        result = [select Synced_To_NS__c from NS_Project_Milestone__c where id = :milestone.Id];
        system.assertEquals(false, result.Synced_To_NS__c, 'Synced_To_NS__c flag should be updated by the trigger');
    }
}