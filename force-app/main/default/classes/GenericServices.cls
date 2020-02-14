/* GenericServices class
*
* 11/03/2011 - Naushad Sunnivohra (Bluewolf)
* Generic static methods
*   
*/
public with sharing class GenericServices
{
    public static Boolean isNullOrEmpty(String rawInputString)
    {
        return (rawInputString == null || rawInputString.trim().length() == 0);
    }
    
    public static String developmentQueueID
    {
        get
        {
            try
            {
                return [Select ID from Group where Type =: Constants.QUEUE_TYPE 
                            and Name =: Constants.DEVELOPMENT_QUEUE_NAME limit 1].id;
            }
            catch(Exception e)
            {
                return '';
            }
        }
    }
    
    public static Set<String> caseCloseStatuses
    {
        get
        {
            if(caseCloseStatuses == null)
            {
                caseCloseStatuses = new Set<String>();
                caseCloseStatuses.add(Constants.STATUS_CLOSED);
                caseCloseStatuses.add(Constants.STATUS_FIXED);
            }
            return caseCloseStatuses;
        }
        private set;
    }
    
    public static Database.DMLOptions defaultAssignmentDBOptions
    {
        get
        {
            if(defaultAssignmentDBOptions == null)
            {
                defaultAssignmentDBOptions = new Database.DMLOptions();
                defaultAssignmentDBOptions.assignmentRuleHeader.useDefaultRule = true;
            }
            return defaultAssignmentDBOptions;
        }
        private set;
    }
    
    public static Boolean getBooleanQueryStringValue(string qs)
    {
        if(!IsNullOrEmpty(qs))
        {
            String queryString = ApexPages.currentPage().getParameters().get(qs);
            if(!isNullOrEmpty(queryString))
            {
                try
                {
                    return Boolean.valueOf(queryString);
                }
                catch(Exception exc)
                {
                    return false;
                }
            }
        }
        return false;
    }
    
        
    public static Map<String, RecordType> getRecordTypesNameMapBySObject(String sObjectName)
    {
        Map<String, RecordType> recordTypesNameMap = new Map<String, RecordType>();
        if(!isNullOrEmpty(sObjectName))
        {
            for(RecordType rt: [Select Id, Name from RecordType where sObjectType =: sObjectName ])
                recordTypesNameMap.put(rt.Name, rt);
        }
        return recordTypesNameMap;
    }
    
    public static Set<String> validAssetUpdateOpptyOrderTypes
    {
        get
        {
            if(validAssetUpdateOpptyOrderTypes == null) 
            {
                validAssetUpdateOpptyOrderTypes = new Set<String>();
                validAssetUpdateOpptyOrderTypes.add(Constants.ORDER_TYPE_UPGRADE);
                validAssetUpdateOpptyOrderTypes.add(Constants.ORDER_TYPE_ADD_ON);
                validAssetUpdateOpptyOrderTypes.add(Constants.ORDER_TYPE_RENEWAL);
                
            }
            return validAssetUpdateOpptyOrderTypes;
        }
        private set;
    }
    
    public static String getGeneralSettingValueForKey(String key)
    {
    	String value = '';
    	
/* DW Commented Out: General Settings Don't exist in org
    	if(key != null && General_Settings__c.getAll().containsKey(key))
    		value = General_Settings__c.getAll().get(key).Value__c;
*/
    	return value;
    }
    
    /*
    public static Database.DMLOptions defaultAutoResponseEmailOption
    {
        get
        {
            if(defaultAutoResponseEmailOption == null)
            {
                defaultAutoResponseEmailOption = new Database.DMLOptions();
                defaultAutoResponseEmailOption.EmailHeader.triggerAutoResponseEmail = true;
            }
            return defaultAutoResponseEmailOption;
        }
        private set;
    } */   
}