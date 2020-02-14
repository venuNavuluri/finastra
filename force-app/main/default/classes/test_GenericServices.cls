@isTest
class test_GenericServices 
{
	static testMethod void testIsNullOrEmpty_ReturnsBoolean()
    {
        System.assert(GenericServices.isNullOrEmpty(null));
        System.assert(GenericServices.isNullOrEmpty(''));
        System.assert(!GenericServices.isNullOrEmpty('hello'));
    }
    //static testMethod void testDevelopmentQueueID_returnsString()
    //{
    //    //the property returns an empty string if no group already exisst
    //    System.assertEquals([Select ID from Group where Type =: Constants.QUEUE_TYPE 
    //                        and Name =: Constants.DEVELOPMENT_QUEUE_NAME limit 1].id, 
    //                        GenericServices.developmentQueueID);
    //}
    static testMethod void testDefaultAssignmentDBOptions()
    {
        Database.DMLOptions options = GenericServices.defaultAssignmentDBOptions;
        System.assertEquals(options.assignmentRuleHeader.useDefaultRule, true);
    }
    static testMethod void testGetBooleanQueryStringValue()
    {
        ApexPages.currentPage().getParameters().put('param', '');
        System.assertEquals(false, GenericServices.getBooleanQueryStringValue('param') );
        ApexPages.currentPage().getParameters().put('param', 'garbage');
        System.assertEquals(false, GenericServices.getBooleanQueryStringValue('param') );
        ApexPages.currentPage().getParameters().put('param', 'false');
        System.assertEquals(false, GenericServices.getBooleanQueryStringValue('param') );
        ApexPages.currentPage().getParameters().put('param', 'true');
        System.assertEquals(true, GenericServices.getBooleanQueryStringValue('param') );
    }
    static testMethod void testCaseCloseStatuses()
    {
        Set<String> caseCloseStatuses = GenericServices.caseCloseStatuses;
        System.assertEquals(2, caseCloseStatuses.size());
        System.assertEquals(true, caseCloseStatuses.contains(Constants.STATUS_CLOSED));
        System.assertEquals(true, caseCloseStatuses.contains(Constants.STATUS_FIXED));
    }
    static testMethod void testValidAssetUpdateOpptyOrderTypes()
    {
        Set<String> validAssetUpdateOpptyOrderTypes = GenericServices.validAssetUpdateOpptyOrderTypes;
        System.assertEquals(3, validAssetUpdateOpptyOrderTypes.size());
        System.assertEquals(true, validAssetUpdateOpptyOrderTypes.contains(Constants.ORDER_TYPE_UPGRADE));
        System.assertEquals(true, validAssetUpdateOpptyOrderTypes.contains(Constants.ORDER_TYPE_ADD_ON));
        System.assertEquals(true, validAssetUpdateOpptyOrderTypes.contains(Constants.ORDER_TYPE_RENEWAL));
    }
    static testMethod void testGetRecordTypesNameMapBySObject()
    {
        Map<String, RecordType> recordTypesMap = GenericServices.getRecordTypesNameMapBySObject('someSObjectThatDoesntExist');
        System.assertEquals(recordTypesMap.size(), 0);
        
        recordTypesMap = GenericServices.getRecordTypesNameMapBySObject('Case');
        Set<String> rTypes = new Set<String>();
        for(RecordType rt: [Select id, Name from RecordType where SObjectType =: 'Case'])
            System.assertEquals(true, recordTypesMap.keySet().contains(rt.name));
    }
    //static testMethod void testGetGenerelSettingsValueForKey()
    //{
    //	String key1 = 'key1'+Date.Today();
    //	//delete all GS data
    //	delete [Select ID from General_Settings__c];
    //	System.assertEquals('', GenericServices.getGeneralSettingValueForKey(key1));
    //	
    //	//create 1 test data
    //	General_Settings__c gs = new General_Settings__c();
    //	gs.Name = key1;
    //	gs.Value__c = 'value1';
    //	insert gs;
    // 
    //	System.assertEquals(gs.Value__c, GenericServices.getGeneralSettingValueForKey(gs.Name));
    //	System.assertEquals('', GenericServices.getGeneralSettingValueForKey('key2'+Date.Today()));
    //}
}