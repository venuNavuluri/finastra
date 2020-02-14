@isTest
public class test_CCRTAccountRefManager
{
	private static final Integer batchSize = 100;
	private static Account[] acctsInsert;
	private static Account[] acctsUpdate;
	
	public static testmethod void blankAccountInsertCCRTTest()
	{
		CCRT__c ccrt = TestUtility.sampleCCRT();
		ccrt.Client_Site_Number__c = '0000001';
		ccrt.Account__c = null;
		insert ccrt;
	}
	
	public static testmethod void loadTest()
	{
		setUpAccounts();
		Test.startTest();
			CCRT__c[] ccrts = insertCCRTs();
			updateCCRTs(ccrts);
			ccrts = [select Id from CCRT__c where Id in :ccrts];
			deleteCCRTs(ccrts);
		Test.stopTest(); 
	}
	
	private static void setUpAccounts()
	{
		acctsInsert = new Account[]{};
		acctsUpdate = new Account[]{};
		for (Integer i = 0; i < batchSize; i++) { // accts for the insert test
			acctsInsert.add(TestUtility.sampleAccount());
		}
		for (Integer i = 0; i < batchSize; i++) { // accts for the update test
			acctsUpdate.add(TestUtility.sampleAccount());
		}
		insert acctsInsert;
		insert acctsUpdate;
	}
	
	private static void deleteCCRTs(CCRT__c[] ccrts)
	{
		delete ccrts;

		acctsUpdate = [select Id, CCRT_Entry__c from Account where id in :acctsUpdate];
		for (Integer i = 0; i < batchSize; i++) {
			System.assertEquals(null, acctsUpdate[i].CCRT_Entry__c);
		}
	}
	
	private static void updateCCRTs(CCRT__c[] ccrts)
	{
		for (Integer i = 0; i < batchSize; i++) {
			ccrts[i].Account__c = acctsUpdate[i].Id;
		}
		update ccrts;

		acctsInsert = [select Id, CCRT_Entry__c from Account where id in :acctsInsert];
		acctsUpdate = [select Id, CCRT_Entry__c from Account where id in :acctsUpdate];
		for (Integer i = 0; i < batchSize; i++) {
			System.assertEquals(null, acctsInsert[i].CCRT_Entry__c);
			System.assertEquals(ccrts[i].Id, acctsUpdate[i].CCRT_Entry__c);
		}
	}
	
	private static CCRT__c[] insertCCRTs()
	{
		CCRT__c ccrt;
		CCRT__c[] ccrts = new CCRT__c[]{};
		for (Integer i = 0; i < batchSize; i++) {
			ccrt = TestUtility.sampleCCRT();
			ccrt.Client_Site_Number__c = al.StringUtils.leftPad(String.valueOf(i), 7, '0');
			ccrt.Account__c = acctsInsert[i].Id;
			ccrts.add(ccrt);
		}
		insert ccrts;
		
		acctsInsert = [select Id, CCRT_Entry__c from Account where id in :acctsInsert];
		for (Integer i = 0; i < batchSize; i++) {
			System.assertEquals(ccrts[i].Id, acctsInsert[i].CCRT_Entry__c);
		}
		return ccrts;
	}
}