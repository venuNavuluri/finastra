public class BatchingUtils
{
	static final Integer MAX_BATCH_COUNT = 5;
	static final Integer SLEEP_BACK_PERIOD = 30; // in seconds

	public static boolean MaxNumberOfBatchApexJobsRunning()
	{
		Integer jobsCnt = [Select count() From AsyncApexJob Where JobType = 'BatchApex' and ( Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' )];
		return (jobsCnt > MAX_BATCH_COUNT - 1);
	}
	
	/*
	public static void RunASAP(SchedulableBatchJob job)
	{
		Integer jobsCnt = [Select count() From AsyncApexJob Where JobType = 'BatchApex' and ( Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' )];
		if (jobsCnt > MAX_BATCH_COUNT - 1) {
			// try again in a minute
			ScheduleXSecondsLater(job, SLEEP_BACK_PERIOD);
		}
		else {
			// execute
			job.DoJob();
		}
	}
	
	public static boolean IsJobScheduled(string className)
	{
		Id jobClassId = GetClassId(className);
		Integer jobsCnt = [
			Select count()
			From AsyncApexJob
			Where JobType = 'BatchApex'
			and ApexClassId = :jobClassId
			and ( Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' )
		];
		return jobsCnt > 0;
	}
	
	public static Id GetClassId(string className)
	{
		ApexClass batchClass = [select Id, Name from ApexClass where Name = :className];
		return batchClass.Id; 
	}
	*/

	public static void ScheduleXSecondsLater(Schedulable job, string jobName, integer x)
	{
		DateTime nextTime = XSecondsLater(x);
		System.schedule(jobName + ' ' + nextTime, CronExpression(nextTime), job);
	}

/*
	public static void ScheduleXSecondsLater(SchedulableBatchJob job, integer x)
	{
		ScheduleXSecondsLater(job, job.GetName(), x);
	}
*/

	public static DateTime XSecondsLater(Integer x)
	{
		return System.now().addSeconds(x);
	}
	
	public static String CronExpression(Datetime certainTime)
	{
		String chronExpression = '' + certainTime.second() + ' ' + certainTime.minute() + ' ' + certainTime.hour() + ' ' + certainTime.day() + ' ' + certainTime.month() + ' ? ' + certainTime.year();
		return chronExpression;
	}

}