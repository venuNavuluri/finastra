public with sharing class OppContractCreateAttach_CE {

	private Opportunity opp;
	private Contract cont;
	
	public OppContractCreateAttach_CE(ApexPages.StandardController sc)
	{
		Boolean bError = false;
		
		opp = (Opportunity)sc.getRecord();
	}
	
	public PageReference CreateAttachContract()
	{
		PageReference pr;
		ContractServices.ContractResult contResult = new ContractServices.ContractResult();
		
		//Get the contract record.  This creates a new record if it doesn't already exists or returns the existing record.
		contResult = ContractServices.getOppContractRecord(opp);
		system.debug('OppContractCreateAttach.CreateAttachContract contResult:'+contResult);
		
		//If a valid record was returned, prepare the redirect URL for the file attachment.  If not, display an error message
		if(contResult.result == true){
			cont = ContResult.ContractRec;
			pr = getAttachURL();
		}else{
			cont = null;
			//Add error message
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL,'An error occurred in processing: '+ContResult.resultMessage));
			//include link to go back to opportunity
			pr = null;
		}
		system.debug('OppContractCreateAttach.CreateAttachContract pr:'+pr);
		
		return pr;
	}
	
	public PageReference getAttachURL()
	{	
		//Example URL for contract file attachment page
		//https://cs13.salesforce.com/p/attach/NoteAttach?pid=800W00000005nQg&parentname=00016977&retURL=%2F800W00000005nQg
		
		Contract c = [select Id, Name, ContractNumber from Contract where Id = :cont.Id LIMIT 1];
		
		PageReference p = new PageReference('/p/attach/NoteAttach?pid='+c.Id+'&parentname='+c.ContractNumber+'&retURL=%2F'+c.Id+'');
		
		return p;
	}

}