global class IntegrationLog_Proposal_Consumer implements Schedulable
{
	public static final ProposalConsumerSettings__c proposalConsumerSettings = ProposalConsumerSettings__c.getOrgDefaults();

	public static void Schedule()
	{
		Schedule(integer.valueOf(proposalConsumerSettings.Schedule_Delay__c) * 60);
	}
	
	public static void Schedule(integer secondsToWait)
	{
		BatchingUtils.ScheduleXSecondsLater(
			new IntegrationLog_Proposal_Consumer(),
			'IntegrationLog_Proposal_Consumer',
			secondsToWait
		);
	}
	
	// hook for the scheduler (Schedulable implementation)
	global void execute(SchedulableContext scMain)
	{
		try {
			if (BatchingUtils.MaxNumberOfBatchApexJobsRunning()) {
				BatchingUtils.ScheduleXSecondsLater(this, 'IntegrationLog_Proposal_Consumer', 30);
				return;
			}
			IntegrationLog_Proposal_BatchJob3 theJob = new IntegrationLog_Proposal_BatchJob3();
			theJob.JobName = 'IntegrationLog_Proposal_Consumer';
			ID idBatch = Database.executeBatch(theJob);
		}
		catch (Exception e) {
			System.debug(LoggingLevel.Error, 'Error in IntegrationLog_Proposal_Consumer: ' + e.getMessage());
			System.debug(LoggingLevel.Error, 'at ' + e.getStackTraceString());
		}
	}
	
}