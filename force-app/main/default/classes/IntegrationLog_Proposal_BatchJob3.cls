global class IntegrationLog_Proposal_BatchJob3 implements Database.Batchable<sObject>
{
	public string JobName { get; set; }
	
	public static final ProposalConsumerSettings__c proposalConsumerSettings = ProposalConsumerSettings__c.getOrgDefaults();
	private static final string queryFields =
		'Id, ReceivedTime__c, ' + 
		'DateField1__c, DateField2__c, DateField3__c, ' +
		'GenString1__c, GenString2__c, GenString3__c, GenString4__c, GenString5__c, GenString6__c, GenString7__c, GenString8__c, GenString9__c, GenString10__c, ' +
		'GenString11__c, GenString12__c, GenString13__c, GenString14__c, GenString15__c, GenString16__c, GenString17__c, GenString18__c, GenString19__c, GenString20__c, ' +
		'GenString21__c, GenString22__c, GenString23__c, GenString24__c, GenString25__c, GenString26__c, GenString27__c, GenString28__c, GenString29__c, GenString30__c, ' +
		'NumField1__c, NumField2__c, NumField3__c, NumField4__c, NumField5__c, NumField6__c, NumField7__c, NumField8__c, NumField9__c, NumField10__c, ' +
		'NumField11__c, NumField12__c, NumField13__c, NumField14__c, NumField15__c, NumField16__c, NumField17__c, NumField18__c, NumField19__c, NumField20__c, ' +
		'NumField21__c, NumField22__c, NumField23__c, NumField24__c, NumField25__c, NumField26__c, NumField27__c, NumField28__c, NumField29__c, NumField30__c, ' +
		'NumField31__c, NumField32__c, NumField33__c, NumField34__c, NumField36__c, NumField37__c, ' + 
		'LongString1__c, LongString2__c, ' +
		'External_Id__c, RecordTypeId, SFDC_Id__c, SFDC_Object__c, isSuccess__c, Message__c, CurrencyISOCode ';
	private string getQueryCondition() {
		return
		'from Integration_Log__c ' +
		'where ReceivedTime__c = null ' +
		'and CreatedDate > ' + proposalConsumerSettings.Start_Time__c.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + ' ' +
		'and RecordTypeId in (\''+ Label.Integration_RecTypeId_PPOPPLINE + '\', \'' + Label.Integration_RecTypeId_PPOPPMILE + '\') ';
	}
	private string getOrderExpression() {
		return		
		'order by CreatedDate limit ' + integer.valueOf(proposalConsumerSettings.Batch_Size__c) + ' ';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		Integration_Log__c[] unprocessedILs = Database.Query('select Id, SFDC_Id__c ' + getQueryCondition() + getOrderExpression());
		Integration_Log__c[] usableILs = new Integration_Log__c[]{};
		Opportunity oppBeingProcessed = weedOutIntLogsAndPickAnOpportunity(unprocessedILs, usableILs);

		System.debug(LoggingLevel.Error, '@@@ IntegrationLog_Proposal_BatchJob3 start. ' + JobName);
		System.debug(LoggingLevel.Error, '@@@ JobName: ' + JobName);
		string query = 
			'select ' + queryFields + getQueryCondition() +
			'and SFDC_Id__c = \'' + (oppBeingProcessed == null ? 'blah' : oppBeingProcessed.Id) + '\' ' + getOrderExpression();
		System.debug(LoggingLevel.Error, '@@@ Query: ' + query);
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		System.debug(LoggingLevel.Error, '@@@ IntegrationLog_Proposal_BatchJob3.execute ' + JobName);
		System.debug(LoggingLevel.Error, '@@@ IntegrationLog_Proposal_BatchJob3 processing ' + scope.size() + ' records.');
		Integration_Log__c[] ils = new Integration_Log__c[]{};
		Opportunity oppBeingProcessed = weedOutIntLogsAndPickAnOpportunity(convertToIntLogArray(scope), ils);

		if (oppBeingProcessed != null) {
			//AK - added the below line to mark it as future job as it is running via the batch job and the account trigger is called internally.
			GlobalVar.bInFuture = true; 
			
			System.debug(LoggingLevel.Error, '@@@ IntegrationLog_Proposal_BatchJob3.execute opp ID: ' + oppBeingProcessed.Id);
			IntegrationLog_Proposal_SingleOppty.processPPOPPLINE_n_PPOPPMILE(oppBeingProcessed, ils);
			//PearlOliToSingleOppSimplifiedRollUpUtils.RollUp(oppBeingProcessed.Id);
		}
	}

	global void finish(Database.BatchableContext BC)
	{
		System.debug(LoggingLevel.Error, '@@@ IntegrationLog_Proposal_BatchJob3.finish ' + JobName);
		Integration_Log__c[] unprocessedILs = Database.Query('select Id, SFDC_Id__c ' + getQueryCondition() + getOrderExpression());
		if (unprocessedILs.size() == 0) {
			if (!Test.isRunningtest()) { IntegrationLog_Proposal_Consumer.Schedule(); }
		}
		else {
			IntegrationLog_Proposal_BatchJob3 theJob = new IntegrationLog_Proposal_BatchJob3();
			theJob.JobName = 'IntegrationLog_Proposal_Consumer';
			ID idBatch = Database.executeBatch(theJob);
		}
	}
	
	private Opportunity weedOutIntLogsAndPickAnOpportunity(/*in*/Integration_Log__c[] ils, /*out*/Integration_Log__c[] usableILs)
	{
		Set<Id> oppIds = new Set<Id>();
		for (Integration_Log__c il : ils) {	oppIds.add(il.SFDC_Id__c); }
		
		Map<Id, Opportunity> opps = IntegrationLog_ProposalSO_QueryUtils.QueryOppsAndBuildMap(oppIds);
		Opportunity theOpp;
		List<Integration_Log__c> intLogsWithInvalidOppId = new List<Integration_Log__c>{};
		for (Integration_Log__c il : ils) {
			if (!opps.containsKey(il.SFDC_Id__c)) {
				IntegrationLogUtils.SetErrorOnILRecord(il, 'Invalid opportunity ID: ' + il.SFDC_Id__c);
				il.ReceivedTime__c = DateTime.now();
				intLogsWithInvalidOppId.add(il);
			}
			else {
				if (theOpp == null) { theOpp = opps.get(il.SFDC_Id__c); }
				if (il.SFDC_Id__c == theOpp.Id) { usableILs.add(il); }
					
			}
		}
		if (intLogsWithInvalidOppId.size() > 0) {
			update intLogsWithInvalidOppId;
		}
		return theOpp;
	}
	
	private Integration_Log__c[] convertToIntLogArray(List<sObject> scope)
	{
		List<Integration_Log__c> intLogs = new List<Integration_Log__c>{};
		for (SObject obj : scope) {
			Integration_Log__c il = (Integration_Log__c)obj;
			intLogs.add(il);
		}
		return intLogs;
	}
	
}