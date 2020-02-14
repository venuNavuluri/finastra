@isTest
public class test_CustomerCaseSynchTrigger
{
	public static testmethod void doTest()
	{
		Case testParent = TestUtility.sampleCase();
		testParent.RecordTypeId = CustomerCaseSynchManager.ENGINEERING_LM_RECORD_TYPE;
		insert testParent;
		Case testChild = TestUtility.sampleIssueCase();
		testChild.ParentId = testParent.Id;
		insert testChild;
		
		testParent.Resolution_Type__c = CustomerCaseSynchManager.NOT_A_DEFECT_FIX_TYPE;
		update testParent;
		
		testChild = queryCase(testChild.Id);
		System.assertEquals(CustomerCaseSynchManager.SUPPORT_REQ_CASE_CAT , testChild.Case_Category__c);
		testParent = queryCase(testParent.Id);
		System.assertEquals(CustomerCaseSynchManager.SUPPORT_REQ_CASE_CAT , testParent.Case_Category__c);

		testParent.Resolution_Type__c = CustomerCaseSynchManager.ENHANCEMENT_FIX_TYPE;
		update testParent;

		testChild = queryCase(testChild.Id);
		System.assertEquals(CustomerCaseSynchManager.ENHANCEMENT_CASE_CAT , testChild.Case_Category__c);
		testParent = queryCase(testParent.Id);
		System.assertEquals(CustomerCaseSynchManager.ENHANCEMENT_CASE_CAT , testParent.Case_Category__c);
	}
	
	private static Case queryCase(Id caseId)
	{
		return [select Id, Case_Category__c from Case where Id = :caseId];
	}

}