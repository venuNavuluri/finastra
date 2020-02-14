/**
 * @File Name          : CommonUtils.cls
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 13/11/2019, 16:23:52
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    04/11/2019   Peter Sabry     Initial Version
**/
public with sharing class CommonUtils {
    public static Map<string, Id> getRecordTypesByObjectName(string objectAPIName) {
        List<RecordType> recordTypesList = new List<RecordType>([SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE sObjectType = :objectAPIName]);
        
        Map<string, Id> recordTypesMap = new Map<string, Id>();
        for (RecordType rt : recordTypesList) { 
            if (!recordTypesMap.containsKey(rt.developerName)) {
                recordTypesMap.put(rt.developerName, rt.Id);
            }
        }
        return recordTypesMap;
    }
    /**
    * @description Returns the first month of quarter that follows one year from the current date
        Q1: 1 June - 31 Aug
        Q2: 1 Sep - 30 Nov
        Q3: 1 Dec - 28/9 Feb
        Q4: 1 March - 31 May
    * @author Peter Sabry | 08/11/2019 
    * @param currentDate 
    * @return Next Quarter Start Date
    **/
    public static DateTime getNextFinancialYearQuarterStartDate(Date currentDate) {
        Integer currentMonth = currentDate.month();
        Integer targetMonth;
        Integer nextYear = currentDate.year() + 1;
        final integer TARGET_DAY = 1;
        if (currentMonth >= 6 && currentMonth <= 8) { //Q1 September next year
            targetMonth = 9;
        }
        else if (currentMonth >= 9 && currentMonth <= 11) { //Q2 December next year
            targetMonth = 12;
        }
        else if (currentMonth == 12) { //Q3 - March 2 years time
            targetMonth = 3;
            nextYear++;
        }
        else if (currentMonth <= 2) { //Q3 March next year
            targetMonth = 3;
        }
        else { //Q4 June next year
            targetMonth = 6;
        }
        return DateTime.newInstance(nextYear, targetMonth, TARGET_DAY);
    }
    /**
    * @description Returns the record Id of the queue 
    * @author Peter Sabry | 11/11/2019 
    * @param queueName 
    * @return Id 
    **/
    public static Id getQueueId(string queueName) {
        List<Group> queueList = new List<Group>([Select Id from Group where developerName = :queueName and Type = 'Queue']);
        if(queueList.size() > 0) {
            return queueList[0].Id;
        }
        return null; //Queue doesn't exist
    }
    
    /**
    * @description Returns the record Id of the Chatter Group 
    * @author Venu Navuluri | 14/11/2019 
    * @param chattergroup 
    * @return Id 
    **/
    public static Id getChatterGroupId(string groupName) {
        List<CollaborationGroup> groupList = new List<CollaborationGroup>([Select Id from CollaborationGroup where Name = :groupName]);
        Id chatterGroupID = null;
        if(groupList.size() > 0) {
            chatterGroupID = groupList[0].Id;
        }
        return chatterGroupID; 
    }
}