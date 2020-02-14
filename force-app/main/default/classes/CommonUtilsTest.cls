/**
 * @File Name          : CommonUtilsTest.cls
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 13/11/2019, 16:31:23
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    13/11/2019   Peter Sabry     Initial Version
**/
@isTest
public with sharing class CommonUtilsTest {

    public static final String CHATTER_TEST_GROUP = 'Chatter Test Group';

    /**
    * @description Test getNextFinancialYearQuarterStartDate method
    * @author Peter Sabry | 13/11/2019 
    * @return testMethod 
    **/
    public static testMethod void getNextFinancialYearQuarterStartDate_PositiveTest() {
        // Perform test
        Test.startTest();

        DateTime q1Date = CommonUtils.getNextFinancialYearQuarterStartDate(DateTime.newInstance(2019, 7, 1).date());
        DateTime q2Date = CommonUtils.getNextFinancialYearQuarterStartDate(DateTime.newInstance(2019, 10, 1).date());
        DateTime q3Date = CommonUtils.getNextFinancialYearQuarterStartDate(DateTime.newInstance(2020, 1, 1).date());
        DateTime q4Date = CommonUtils.getNextFinancialYearQuarterStartDate(DateTime.newInstance(2020, 4, 1).date());

        Test.stopTest();
        
        //Verify results
        system.assertEquals(q1Date, DateTime.newInstance(2020, 9, 1), 'Date should be 1/9/2020');
        system.assertEquals(q2Date, DateTime.newInstance(2020, 12, 1), 'Date should be 1/12/2020');
        system.assertEquals(q3Date, DateTime.newInstance(2021, 3, 1), 'Date should be 1/3/2021');
        system.assertEquals(q4Date, DateTime.newInstance(2021, 6, 1), 'Date should be 1/6/2021');
    }
    /**
    * @description Test getQueueId method
    * @author Peter Sabry | 13/11/2019 
    * @return testMethod 
    **/
    public static testMethod void getQueueId_PositiveTest() {
        Test.startTest();

        Id lcaTeamQueueId = CommonUtils.getQueueId(Constants.LCA_TEAM_QUEUE_NAME);
        
        Test.stopTest();

        //Verify results
        system.assertnotEquals(lcaTeamQueueId, null, 'Queue Id is not null');
    }
    /**
    * @description Test getRecordTypesByObjectName method
    * @author Peter Sabry | 13/11/2019 
    * @return testMethod 
    **/
    public static testMethod void getRecordTypesByObjectName_PositiveTest() {
        Test.startTest();

        Map<string, Id> caseRecordTypes = CommonUtils.getRecordTypesByObjectName('Case');
        
        Test.stopTest();

        //Verify results
        system.assert(caseRecordTypes.size() > 0, 'Case record types are more than 0.');
    }//
    /**
    * @description Test getQueueId method
    * @author Venu Navuluri | 14/11/2019 
    * @return testMethod 
    **/
    public static testMethod void getChatterGroupId_PositiveTest() {
        TestDataFactory.createCollaborationGroup(CHATTER_TEST_GROUP);
        Test.startTest();

        Id chatterTestGroupID = CommonUtils.getChatterGroupId(CHATTER_TEST_GROUP);
        
        Test.stopTest();

        //Verify results
        system.assertnotEquals(chatterTestGroupID, null, 'Group Id is not null');
    }
}