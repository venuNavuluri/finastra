public class OpportunityWinLossReport_CE {

	// The current opportunity
	public Opportunity opp {get;set;}
	public String TeamList {get;set;}
	
	//Constructor
	public OpportunityWinLossReport_CE (ApexPages.Standardcontroller stdController){
		string tempList = '';
		this.opp = (Opportunity)stdController.getRecord();
		
		for(OpportunityTeamMember m : [SELECT o.Id, o.User.Name FROM OpportunityTeamMember o WHERE o.OpportunityId = :opp.Id]){
			tempList += ', ' + m.User.Name;
		}
		system.debug('XXXXXXXXXX Opportunity Team List: '+tempList);
		TeamList = tempList;
	}
}