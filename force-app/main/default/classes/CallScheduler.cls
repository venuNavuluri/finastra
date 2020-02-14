public with sharing class CallScheduler
{
	public static void RunCaseMetricsJob()
	{
		System.schedule('Run Job 1 for Critical', '0 10 * * * ? *', new TimeObjectSchedulerCritical());
		System.schedule('Run Job 1 for not Critical', '0 15 * * * ? *', new TimeObjectSchedulerNotCritical());
		System.schedule('Run Job 2 for Critical', '0 20 * * * ? *', new TimeObjectSchedulerCritical());
		System.schedule('Run Job 3 for Critical', '0 30 * * * ? *', new TimeObjectSchedulerCritical());	 
		System.schedule('Run Job 4 for Critical', '0 40 * * * ? *', new TimeObjectSchedulerCritical());
		System.schedule('Run Job 2 for not Critical', '0 45 * * * ? *', new TimeObjectSchedulerNotCritical());
		System.schedule('Run Job 5 for Critical', '0 50 * * * ? *', new TimeObjectSchedulerCritical());
		System.schedule('Run Job 6 for Critical', '0 59 * * * ? *', new TimeObjectSchedulerCritical());
	}

	public static void RunDeadJobCleaner()
	{
		System.schedule('DeadJobCleaner', '0 0 * * * ?', new DeadJobCleaner());
	}

	public static void RunAttachmentNotifier()
	{
	 	//To schedule, run AttachmentTriggerMethods.RunAttachmentNotifier();  in the Developer Console.
	 
		AttachmentNotifyScheduler.Schedule('Attachment Notification (Portal)',integer.valueOf(Label.Case_Attachment_Notice_Interval));
		
		//System.schedule('Attachment Notification (Portal) 10', '0 10 * * * ? *', new AttachmentNotifyScheduler());
		//System.schedule('Attachment Notification (Portal) 25', '0 25 * * * ? *', new AttachmentNotifyScheduler());
		//System.schedule('Attachment Notification (Portal) 40', '0 40 * * * ? *', new AttachmentNotifyScheduler());
		//System.schedule('Attachment Notification (Portal) 55', '0 55 * * * ? *', new AttachmentNotifyScheduler());
	}
	  	
	/*
	public static testmethod void testCallScheduler()
	{
		//Stop the currently scheduled jobs
		for(CronTrigger ct : [SELECT Id from CronTrigger where State != 'DELETED']){
			try{
				System.abortJob(ct.Id);
			}catch (Exception e){
				System.debug('Caught error: '+e);
			}
		}
		
		//Test running the jobs
		RunCaseMetricsJob();
	}
	*/
}