@isTest
private with sharing class CaseStatusMapping_Test {

    private static testmethod void testCaseStatusMappings()
    {
        Map<String,Case_Status_Mapping__c> mapCSM = CaseStatusMapping.getCaseStatusMappings();
    }

}