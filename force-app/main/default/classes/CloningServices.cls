/* CloningServices class
*
* 7/11/2011 - Naushad Sunnivohra (Bluewolf)
* Services class for the static level Cloning methods
*   
*/
public with sharing class CloningServices
{
    public static SObject cloneRecord(SObject recordToClone, Boolean copyId)
    {
        SObject clonedSObject = null;
        
        if(recordToClone != null && recordToClone.Id != null)
        {
            //get object and field describe info
            Map<String, Schema.SObjectField> fieldMap = recordToClone.getsObjectType().getDescribe().fields.getMap(); 
            
            List<String> fieldList = getFieldList(fieldMap, true);
            String fieldNames = getFieldNamesFromList(fieldList);
            
            String queryString = 'SELECT ' + fieldNames + ' FROM ' + recordToClone.getsObjectType().getDescribe().getName() + ' WHERE Id=\'' + recordToClone.Id + '\'';
            System.debug('Query in CloningServices.cloneRecord: [' + queryString + ']');
            
            List<SObject> clonedSObjects = Database.query(queryString);
            
            if(clonedSObjects != null && !clonedSObjects.isEmpty())
                clonedSObject = clonedSObjects.get(0);
                
            if(clonedSObject != null)
                clonedSObject = clonedSObject.clone(copyId, true);
        }
                       
        return clonedSObject;
    }

    public static List<SObject> cloneRecordsInBulk(List<SObject> recordsToClone, Boolean copyId)
    {
        List<SObject> clonedSObjects = null;
        
        if(recordsToClone != null && !recordsToClone.isEmpty())
        {            
            //get object and field describe info
            Map<String, Schema.SObjectField> fieldMap = recordsToClone.getsObjectType().getDescribe().fields.getMap(); 
            
            List<String> fieldList = getFieldList(fieldMap, true);
            String fieldNames = getFieldNamesFromList(fieldList);
            
            String queryString = 'SELECT ' + fieldNames + ' FROM ' + recordsToClone.getsObjectType().getDescribe().getName() + ' WHERE Id IN (' + getSetOfIdsString(recordsToClone) + ')';
            System.debug('Query in CloningServices.cloneRecordsInBulk: [' + queryString + ']');
            
            clonedSObjects = Database.query(queryString);
            
            if(clonedSObjects != null && !clonedSObjects.isEmpty())
                clonedSObjects = clonedSObjects.deepClone(copyId);
        }
                       
        return clonedSObjects;
    }
    
    public static List<String> getFieldList(Map<String,Schema.SObjectField> fieldMap, Boolean selectAllFields)
    {
        List<String> fieldList = new List<String>();
        
        //build dynamic list of fieldnames
        for (String fieldKey : fieldMap.keySet()) {
            Schema.SObjectField fsObj = fieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            String fieldName = f.getName();
            
            if (selectAllFields) {
                fieldList.add(fieldName);
            } else {
                if (f.getName()=='Id' || f.isNameField() || f.isCustom()) {
                    fieldList.add(fieldName);
                }
            }
        }
        
        return fieldList;
    }
    
    static String getFieldNamesFromList(List<String> fieldList) {
        String fieldNames = '';
        for (String field : fieldList) {
            if (fieldNames.length()>0) {
                fieldNames += ',';
            }
            fieldNames += field;
        }
                
        return fieldNames;
    }
    
    static String getSetOfIdsString(List<SObject> SObjects)
    {
        String setOfIdsString = '';
        
        for(SObject record : SObjects)
        {
            if(record.Id != null)
            {
                if (setOfIdsString.length()>0)
                    setOfIdsString += ',';
               
               setOfIdsString += '\'' + record.Id + '\'';
            }
        }
        return setOfIdsString;
    }
}