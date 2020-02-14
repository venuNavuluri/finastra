public class InlineAccountAttributesController {

    public Boolean ShowAccountAtRisk{get; set;}
    public Boolean ShowSupporthold{get; set;}
    //public Boolean ShowGlobalAccount{get; set;}
    //public Boolean ShowMajorAccount{get; set;}
    public Boolean ShowStrategicAccount{get; set;}
	public Boolean ShowEndofLife{get; set;}
	public Boolean ShowActiveCustomer{get;set;}
	public Boolean ShowExCustomer{get;set;}
	public Boolean ShowObsoleteCustomer{get;set;}
	public Boolean AuthorisedtoAccessLiveSystems{get;set;}
	

    public InlineAccountAttributesController(ApexPages.StandardController stdController) {

        Account ViewingAccount = (Account)stdController.getRecord();
		System.debug('xxxx: ' + ViewingAccount.Id);
        Account MoreAccount = [select Account_Watch__c,Debtor_Account__c,Tier__c, Special_Support__c, Type, Authorised_to_Access_Live_Systems__c from Account where Id= :ViewingAccount.Id];

        ShowAccountAtRisk= false;
        ShowSupporthold=false;
        //ShowGlobalAccount=false;
        //ShowMajorAccount=false;
	    ShowStrategicAccount=false;
    	ShowEndofLife=false;
		ShowActiveCustomer=false;
		ShowExCustomer=false;
		ShowObsoleteCustomer=false;
		AuthorisedtoAccessLiveSystems = false;        

        if(MoreAccount.Account_Watch__c == True){
            ShowAccountAtRisk= true;
        }
        
        if(MoreAccount.Debtor_Account__c == True){
            ShowSupporthold= true;
        }
        //  if(MoreAccount.Tier__c == 'Global'){
        //    ShowGlobalAccount= true;
        //}
        //if(MoreAccount.Tier__c == 'Major'){
        //    ShowMajorAccount= true;
        //}
    	if(MoreAccount.Tier__c == 'Strategic'){
            ShowStrategicAccount= true;
        }
		if(MoreAccount.Special_Support__c == True){
            ShowEndofLife= true;
        }
        
        if(MoreAccount.Type != null && MoreAccount.Type != '')
        {
	        if(MoreAccount.Type.contains('Obsolete')){
	        	ShowObsoleteCustomer = true;
	        }else if(MoreAccount.Type.Contains('Ex-Customer')){
	        	ShowExCustomer = true;
	        }else if(MoreAccount.Type.Contains('Customer')){
	        	ShowActiveCustomer = true;
	        }
        }
        if(MoreAccount.Authorised_to_Access_Live_Systems__c == true){
        	AuthorisedtoAccessLiveSystems = true;
        }
        
    }
    // AC 9/4/09 - moved test methods to separate class
}