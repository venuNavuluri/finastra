public class IntegrationLog_CFTP
{

	public static void processCFTPContract(List<Integration_Log__c> IntLogCFTPContract, Set<Id> idsCFTPContract)
	{	
		map<Id,Partner_Approvals_Renewals__c> recsToBeUpdated = new map<Id,Partner_Approvals_Renewals__c>([select Id, Account__c, Date_Signed__c, Expiry_Date__c, Upload_Signed_Partner_Contract_to_Coral__c, Partner_Type__c, Agreement_Number__c from Partner_Approvals_Renewals__c where Id in :idsCFTPContract]);
		if(recsToBeUpdated.keySet().size() > 0)
		{
			List<Partner_Approvals_Renewals__c> updatedRecs = new List<Partner_Approvals_Renewals__c>();
			Partner_Approvals_Renewals__c iRec;
			map<Id,List<Integration_Log__c>> mapRecIdToLogList = new map<Id,List<Integration_Log__c>>();
			
			//loop through list and apply the changes from the latest log for the record
			for(Integration_Log__c intLog : IntLogCFTPContract)
			{
				iRec = recsToBeUpdated.get(intLog.SFDC_Id__c);
				system.debug('JRB DateField1:'+intLog.DateField1__c);
				system.debug('JRB DateField2:'+intLog.DateField2__c);
				
				// --Date Signed--
				if(intLog.DateField1__c != null)
					iRec.Date_Signed__c = intLog.DateField1__c.dateGMT();
					
				// --Expiry Date--
				if(intLog.DateField2__c != null)
					iRec.Expiry_Date__c = intLog.DateField2__c.dateGMT();
					
				// --Upload Signed Partner Contract To Coral--
				if(intLog.GenString1__c == '1')
				{
					iRec.Upload_Signed_Partner_Contract_to_Coral__c = true;
				}else if(intLog.GenString1__c == '0'){
					iRec.Upload_Signed_Partner_Contract_to_Coral__c = false;
				}
				
				// --Partner Type--
				if(intLog.GenString2__c != null)
					iRec.Partner_Type__c = intLog.GenString2__c;
					
				// --Coral Agreement Number--
				if(intLog.NumField1__c != null)
					iRec.Agreement_Number__c = String.valueOf(intLog.NumField1__c.intValue());
				
				if(mapRecIdToLogList.keySet().contains(iRec.Id))
				{
					mapRecIdToLogList.get(iRec.Id).add(intLog);
				}else{
					mapRecIdToLogList.put(iRec.Id,new List<Integration_Log__c>{intLog});
				}
			}
			system.debug('mapRecIdToLogList:'+mapRecIdToLogList);
			
			//Save the results and update success flag
			try
			{
				Database.SaveResult[] resultsRecs = Database.update(recsToBeUpdated.values(),false);
				IntegrationLogUtils.updateSaveResults(resultsRecs,recsToBeUpdated.values(),mapRecIdToLogList);
			}
			catch(Exception e)
			{
				System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
			}
		}
	}

}