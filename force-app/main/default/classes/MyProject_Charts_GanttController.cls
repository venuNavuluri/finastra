public with sharing class MyProject_Charts_GanttController {
	//Adapted from the Milestones PM AppExchange app created by Salesforce Labs (http://appexchange.salesforce.com/listingDetail?listingId=a0N30000003ItrEEAS)

	public string myTarget{get;set;}
	
	public String getProjectGanttJson(){
		
		List<Project_Milestone__c> milestones = [select Id, Name, Milestone__c, Start_Date__c, Target_Date__c, Percentage_Complete__c 
			from Project_Milestone__c where project__c = :myTarget order by Name];
		
		string ret = 'var ganttData'+myTarget+' =[{id: 1, name:"", series: [';
		
		Boolean addComma = false;
		for(Project_Milestone__c current : milestones){
			if(current.Start_Date__c != null && current.Target_Date__c != null){
				if(addComma){ret += ',';}
				
				string color='#2299bb';
				
				if(current.Percentage_Complete__c == 100){
					color='#333333';
				}else if (current.Target_Date__c < Date.today()){
					color='#ee3322';
				}else if(current.Start_Date__c > Date.today()){
					color='#666666';
				}
				
				ret += '{name: "' + current.Milestone__c + '", ' + 
					'start: new Date('+current.Start_Date__c.year()+','+(Integer.valueOf(current.Start_Date__c.month())-1)+','+current.Start_Date__c.day()+'), ' + 
					'end: new Date('+current.Target_Date__c.year()+','+(Integer.valueOf(current.Target_Date__c.month())-1)+','+current.Target_Date__c.day()+'),' + 
					'color: "' + color + '"}';
				addComma = true;
			}
		}
		
		ret += ']}];';
		
		return ret;
	}
	
	static testMethod void testProjectJson(){
		MyProject__c p1 = new MyProject__c(Name='TestProject1');
		insert p1;
		Project_Milestone__c pm1 = new Project_Milestone__c(Project__c=p1.Id,Milestone__c='Requirements',Start_Date__c=Date.today().addDays(-14),Target_Date__c=Date.today().addDays(14),Percentage_Complete__c=80);
		insert pm1;
		
		MyProject_Charts_GanttController clsCGC = new MyProject_Charts_GanttController();
		clsCGC.myTarget = p1.Id;
		
		string ret = clsCGC.getProjectGanttJson();
		
		system.assert(ret.indexOf('ganttData') > -1);
		system.assert(ret.indexOf(pm1.Milestone__c) > -1);
		
		pm1.Percentage_Complete__c = 100;
		update pm1;
		
		Project_Milestone__c pm2 = new Project_Milestone__c(Project__c=p1.Id,Milestone__c='Configuration',Start_Date__c=Date.today().addDays(-14),Target_Date__c=Date.today()-1,Percentage_Complete__c=80);
		insert pm2;
		
		Project_Milestone__c pm3 = new Project_Milestone__c(Project__c=p1.Id,Milestone__c='UAT',Start_Date__c=Date.today()+1,Target_Date__c=Date.today().addDays(14),Percentage_Complete__c=80);
		insert pm3;
		
		ret = clsCGC.getProjectGanttJson();
		
		system.assert(ret.indexOf('333333') > -1);
		system.assert(ret.indexOf('ee3322') > -1);
		system.assert(ret.indexOf('666666') > -1);
	}
}