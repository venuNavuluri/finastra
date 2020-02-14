public class IntegrationLogUtils
{

	//Method to remove duplicates from a list of Integration logs. It uses the field External Id
	//to sort the list, and SFDC Id to identify a duplicate. It assumed that higher external id
	//values are later updates, and previous updates can be discarded.
	public static List<Integration_Log__c> removeDuplicates(List<Integration_Log__c> intLogs){
		Map<String, Integration_Log__c> extIdToIntLogMap = new Map<String, Integration_Log__c>();
		
		for(Integration_Log__c intLog: intLogs){
			extIdToIntLogMap.put(intLog.External_Id__c, intLog);
		}
		
		List<String> orderedList = new List<String>();
		orderedList.addAll(extIdToIntLogMap.keySet());
		orderedList.sort();
		
		List<Integration_Log__c> deDuplicatedIntLogs = new List<Integration_Log__c>();
		List<Integration_Log__c> duplicateIntLogs = new List<Integration_Log__c>();
		Set<String> uniqueSFDCIds = new Set<String>();
		
		//As we are sorted in ascending order, start at the end for the most recent updates
		for(Integer i = (orderedList.size() - 1); i >= 0; i--){
			Integration_Log__c il = extIdToIntLogMap.get(orderedList[i]);
			if(!uniqueSFDCIds.contains(il.SFDC_Id__c)){
				uniqueSFDCIds.add(il.SFDC_Id__c);
				deDuplicatedIntLogs.add(il);
			}
			else {
				il.Message__c = 'Duplicate; not processed.';
			}
		}
		return deDuplicatedIntLogs;
	}
	

	public static void updateSaveResults(Database.SaveResult[] results, List<sObject> updatedRecs, map<Id,List<Integration_Log__c>> mapRecToLogs)
	{
		if(results != null)
		{
			system.debug('results list: '+results);
			system.debug('updatedRecs: '+updatedRecs);
			system.debug('mapRecToLogs: '+mapRecToLogs);
			for(Integer x = 0; x <= updatedRecs.size()-1; x++)
			{
				system.debug('updatedRecs['+x+']: '+updatedRecs[x]);
				system.debug('results['+x+']: '+results[x]);
				//system.debug('mapRecToLogIds.get(updatedRecs['+x+'].Id).isSuccess__c: '+mapRecordToLog.get(updatedRecs[x].Id).isSuccess__c);
				for(Integration_Log__c intLog : mapRecToLogs.get(updatedRecs[x].Id))
				{
					intLog.isSuccess__c = results[x].isSuccess();
					//AK - added this to update the received time on the PPOPPLINEH records
					if(intLog.RecordTypeId == Label.Integration_RecTypeId_PPOPPLINEH){
						intLog.ReceivedTime__c = DateTime.now();
					}
					if(!results[x].isSuccess())
					{
						String msg = 'Error occurred when verifying the record saved properly.';
						intLog.Message__c = msg + '  ' + results[x].getErrors()[0].getStatusCode()+' - '+results[x].getErrors()[0].getFields()+' - '+results[x].getErrors()[0].getMessage();
						intLog.Status__c = 'Failed';
					}
						
				}
			}
		}		
	}

	public static void setErrorOnILRecord(Integration_Log__c intLog, string error)
	{
		//If the product was not inserted successfully, log the error on the Int Log record
		intLog.isSuccess__c = false;
		intLog.Status__c = 'Failed';
		intLog.Message__c = error;
	}
	
	public static void setErrorOnILRecord(Integration_Log__c intLog, Database.Error[] errors)
	{
		string msg = '';
		for(Database.Error dbError : errors){
			if (dbError != null && dbError.getMessage() != null && dbError.getMessage() != '') {
				msg += dbError.getMessage() + ', ';
			}
		}
		setErrorOnILRecord(intLog, msg);
	}
	
	//Method to create a datetime from a string concatentaion of User + Proposal + Date and Time
	//DateTime will be used to figure out which IL's are the latest
	public static DateTime interpretUpdateDateConcat(String oppLineConcat){
		if (oppLineConcat == null || oppLineConcat == '') { return null; }
		String[] ss = oppLineConcat.split('-');
		String fullDateTime = ss[1];
		String[] fullDTSplit = fullDateTime.split(' ');
		String[] dateSplit = fullDTSplit[0].split('/');
		String[] timeSplit = fullDTSplit[1].split(':');
		DateTime updateDate = DateTime.newInstance(Integer.valueOf(dateSplit[2]), Integer.valueOf(dateSplit[1]), Integer.valueOf(dateSplit[0]), Integer.valueOf(timeSplit[0]), Integer.valueOf(timeSplit[1]), Integer.valueOf(timeSplit[2]));
		return updateDate;
	}
	
	public static void markILsWithErr(IntLogRecord[] ILs, string str)
	{
		if (ILS == null) { return; }
		for (IntLogRecord intLog : ILs) {
			intLog.setError(str);
		}
	}
	
	public static void markILsWithErr(IntLogRecord[] ILs, Exception e)
	{
		markILsWithErr(ILs, e.getMessage() + ' at ' + e.getStackTraceString());
	}
	
	public static void DiscardIntLogList(Id oppId, Map<Id, IntLogRecord[]> oppIdToIntLogListMap)
	{
		IntLogRecord[] ilList = oppIdToIntLogListMap.get(oppId);
		for (IntLogRecord il : ilList) {
			il.setError('Not used - outdated.');
		}
		oppIdToIntLogListMap.remove(oppId);
	}
	
}