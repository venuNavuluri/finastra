public class MyProjectTriggerMethods 
{
	public static void createDefaultMilestones(Map<ID,MyProject__c> mapMyProject)
	{
		List<Project_Milestone__c> lstProjectMilestones = new List<Project_Milestone__c>();
		
		if(!mapMyProject.isEmpty())
		{
			for(MyProject__c mp : mapMyProject.values())
			{
				// Requirements
				Project_Milestone__c req = new Project_Milestone__c();
				req.Milestone__c = 'Requirements';
				req.Status__c = 'Green';
				req.Project__c = mp.Id;
				lstProjectMilestones.add(req);

				// Configuration
				Project_Milestone__c conf = new Project_Milestone__c();
				conf.Milestone__c = 'Configuration';
				conf.Status__c = 'Green';
				conf.Project__c = mp.Id;
				lstProjectMilestones.add(conf);

				// Custom Development
				Project_Milestone__c cr = new Project_Milestone__c();
				cr.Milestone__c = 'Custom Development';
				cr.Status__c = 'Green';
				cr.Project__c = mp.Id;
				lstProjectMilestones.add(cr);

				// Integration
				Project_Milestone__c intg = new Project_Milestone__c();
				intg.Milestone__c = 'Integration';
				intg.Status__c = 'Green';
				intg.Project__c = mp.Id;
				lstProjectMilestones.add(intg);

				// Data Migration & Cleansing
				Project_Milestone__c dmc = new Project_Milestone__c();
				dmc.Milestone__c = 'Data Migration & Cleansing';
				dmc.Status__c = 'Green';
				dmc.Project__c = mp.Id;
				lstProjectMilestones.add(dmc);

				// UAT
				Project_Milestone__c uat = new Project_Milestone__c();
				uat.Milestone__c = 'UAT';
				uat.Status__c = 'Green';
				uat.Project__c = mp.Id;
				lstProjectMilestones.add(uat);

				// Training & Communication
				Project_Milestone__c tc = new Project_Milestone__c();
				tc.Milestone__c = 'Training & Communication';
				tc.Status__c = 'Green';
				tc.Project__c = mp.Id;
				lstProjectMilestones.add(tc);

				// Go Live
				Project_Milestone__c gl = new Project_Milestone__c();
				gl.Milestone__c = 'Go Live';
				gl.Status__c = 'Green';
				gl.Project__c = mp.Id;
				lstProjectMilestones.add(gl);
			}
			
			if(lstProjectMilestones.size() > 0)
			{
				insert lstProjectMilestones;
			}
		}
	}
	
	public static testmethod void testCreateDefaultMilestones()
	{
		MyProject__c project = new MyProject__c();
		insert project;
		
	}
}