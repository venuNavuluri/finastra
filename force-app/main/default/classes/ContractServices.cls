public class ContractServices {
	
	//Wrapper class for Result of retreiving or creating a new contract record
	public class ContractResult
	{
		public Contract ContractRec;
		public Boolean result;
		public String resultMessage;
		
		public ContractResult(){
			result = false;
			resultMessage = '';
		}
	}

	public static ContractResult getOppContractRecord(Opportunity opp)
	{
		ContractResult contResults = new ContractResult();
		List<Contract> contractRec = new List<Contract>();
		Contract oppContractRecord;
	
		//Determine if a contract record already exists for the given opportunity
		contractRec = [select Id from Contract where Misys_Opportunity__c = :opp.Id];
		
		//Get or create a contract record
		if(contractRec.size() == 0){
			//No contract record found, so we need to create it
			contResults = getNewOppContractRecord(opp);
		}else if(contractRec.size() > 1){
			//More than 1 contract record found.  User will need to manaully browse to the correct record and attach the contract file.
			contResults.ContractRec = null;
			contResults.result = false;
			contResults.resultMessage = Label.OppContractError_MultipleContracts;
		}else{
			contResults.ContractRec = contractRec[0];
			contResults.result = true;
			contResults.resultMessage = 'Successfully retrieved existing contract.';
		}
	
		return contResults;
	}

	public static ContractResult getNewOppContractRecord(Opportunity oppty)
	{
		//Boolean bSuccess;
		ContractResult cr = new ContractResult();
		Contract oppContract = new Contract();
		
		//Set the field values in the new Contract
		oppContract.Misys_Opportunity__c = oppty.Id;
		oppContract.AccountId = oppty.AccountId;
		
		//Attempt to insert the actual record.  Set the result values accordingly
		try
		{
			insert oppContract;
			cr.ContractRec = oppContract;
			cr.result = true;
			cr.resultMessage = 'Successfully created record';
		}
		catch(Exception e)
		{
			system.debug('ContractServices.getNewOppContractRecord - Error on Insert:'+e);
			cr.ContractRec = null;
			cr.result = false;
			cr.resultMessage = e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage();
		}
		
		return cr;
	}

}