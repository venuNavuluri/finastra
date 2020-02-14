public class IntegrationLog {
	
	public class LogRecord{
		public String ExternalSystem;
		public String ExternalId;
		public String SFDC_Object;
		public String SFDC_Id;		
		public String RecordTypeId;
		public String Operation;
		public Boolean isSuccess;
		public String FieldsUpdated;
		public String Message;
	}	
	
	//This sets an integration to run in a test mode where actual users are replaced by test users
	//  Not all integartions are set to run this yet.  Only those listed below are for now.
	//		Winform
	public static boolean isTestMode = false; 
	public static string testApproverId = '00520000000orqkAAA';  //Jason's production Id
	
	public static void ProcessIntegrations(List<Integration_Log__c> newLogs){
		
		List<Integration_Log__c> logsWFRLFINFO = new List<Integration_Log__c>();
		List<Integration_Log__c> logsCFTPContract = new List<Integration_Log__c>();
		List<Integration_Log__c> logsWFApprovals = new List<Integration_Log__c>();
		List<Integration_Log__c> logsPMPRODREC = new List<Integration_Log__c>();
		List<Integration_Log__c> logsPMPRODGAS = new List<Integration_Log__c>();
		List<Integration_Log__c> logsPMPBENTRY = new List<Integration_Log__c>();
		Set<Id> idsWFRLFINFO = new Set<Id>();
		Set<Id> idsCFTPContract = new Set<Id>();
		Set<Id> idsWFApprovals = new Set<Id>();
		Set<Id> idsPMPRODREC = new Set<Id>();
		Set<Id> idsPMPRODGAS = new Set<Id>();
		Set<Id> idsPMPBENTRY = new Set<Id>();
		Set<Id> daRecordTypeIds = new Set<Id>();
		
		//loop through records to find what needs to be updated
		for(Integration_Log__c iLog : newLogs)
		{
			//RLF Reductions - Opportunity or PPOPPLINEH Opportunity - AK Added the PPOPPLINEH to it
			if(iLog.RecordTypeId == Label.Integration_RecTypeId_WFRLFINFO || iLog.RecordTypeId == Label.Integration_RecTypeId_PPOPPLINEH)
			{
				logsWFRLFINFO.add(iLog);
				idsWFRLFINFO.add(iLog.SFDC_Id__c);
			}
			//Customer Facing Third-Party (Partner) Approval Contracts
			else if(iLog.RecordTypeId == Label.Integration_RecTypeId_CFTPContract)
			{
				logsCFTPContract.add(iLog);
				idsCFTPContract.add(iLog.SFDC_Id__c);
			}
			//Customer Facing Third-Party (Partner) Approval Contracts
			else if(iLog.RecordTypeId == Label.Integration_RecTypeId_WFApprovals)
			{
				logsWFApprovals.add(iLog);
				idsWFApprovals.add(iLog.SFDC_Id__c);
				if(iLog.GenString5__c != null){
					daRecordTypeIds.add(iLog.GenString5__c);
				}
			}
			//DW 10/07
			//Coral Products
			else if(iLog.RecordTypeId == Label.Integration_RecTypeId_PMPRODREC){
				logsPMPRODREC.add(iLog);
				idsPMPRODREC.add(iLog.SFDC_Id__c);
			}
			else if(iLog.RecordTypeId == Label.Integration_RecTypeId_PMPRODGAS){
				logsPMPRODGAS.add(iLog);
				idsPMPRODGAS.add(iLog.SFDC_Id__c);
			}
			//DW 10/07
			//Coral Pricebook Entry
			else if(iLog.RecordTypeId == Label.Integration_RecTypeId_PMPBENTRY){
				logsPMPBENTRY.add(iLog);
				idsPMPBENTRY.add(iLog.SFDC_Id__c);
			}
			//else if(xxx)
			//{
			//}
			else
			{
				system.debug('Integration Process (RecordTypeId) not identified.  Log='+iLog);
			}
		}
		
		//If logs were found for the WFRLFINFO integration, process the logs
		if(logsWFRLFINFO.size() > 0){
			IntegrationLog_Opportunity.processWFRLFINFO(logsWFRLFINFO, idsWFRLFINFO);
		}
		
		//If logs were found for the CFTPContract integration, process the logs
		if(logsCFTPContract.size() > 0){
			IntegrationLog_CFTP.processCFTPContract(logsCFTPContract,idsCFTPContract);
		}
		
		//If logs were found for the Winform Approvals integration, process the logs
		if(logsWFApprovals.size() > 0){
			//IntegrationLog_WinformApproval.processWFApprovals(logsWFApprovals,idsWFApprovals);
			IntegrationLog_WinformApproval.processWFApprovals(logsWFApprovals,idsWFApprovals,daRecordTypeIds);
		}
		
		if(logsPMPRODREC.size() > 0){
			IntegrationLog_Product.processPMPRODREC(logsPMPRODREC, idsPMPRODREC);
		}
		
		if(logsPMPRODGAS.size() > 0){
			IntegrationLog_Product.processPMPRODREC(logsPMPRODGAS, idsPMPRODGAS);
		}
		
		if(logsPMPBENTRY.size() > 0){
			IntegrationLog_Pricebook.processPMPBENTRY(logsPMPBENTRY, idsPMPBENTRY);
		}
		
		//if List2 >0
			//call method to process
	}

	public static void saveToLog(List<LogRecord> lLogs){
		
		List<Integration_Log__c> logsToInsert = new List<Integration_Log__c>();
		for(LogRecord log:lLogs){
			Integration_Log__c lr = new Integration_Log__c();
			lr.External_System__c = log.ExternalSystem;
			lr.External_Id__c = log.ExternalId;
			lr.SFDC_Object__c = log.SFDC_Object;
			lr.SFDC_Id__c = log.SFDC_Id;
			lr.RecordTypeId = log.RecordTypeId;
			lr.Operation__c = log.Operation;
			lr.isSuccess__c = log.isSuccess;
			lr.Fields_Updated__c = log.FieldsUpdated;
			lr.Message__c = log.Message;
			logsToInsert.add(lr);
		}
		system.debug('JRB....  Records to insert: '+logsToInsert);
		system.debug('JRB....  User='+UserInfo.getUserName()+', UserProfile='+UserInfo.getProfileId());
		insert logsToInsert;
	}
	
}