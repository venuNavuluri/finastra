public class NewAccountSupportedController
{

	public Accounts_Supported__c accountSupported{get; set;}
 
	public NewAccountSupportedController(ApexPages.StandardController stdController){
		accountSupported = new Accounts_Supported__c();
		System.Debug('PB: ApexPages.currentPage().getParameters().get(CF00N200000029p5q_lkid):'+ ApexPages.currentPage().getParameters().get('CF00N200000029p5q_lkid'));
		if(ApexPages.currentPage().getParameters().get('CF00N200000029p5q_lkid') != null){
			//accountSupported.Contact__c = ApexPages.currentPage().getParameters().get('CF00NR0000000XiCd_lkid');
			accountSupported.Contact__c = ApexPages.currentPage().getParameters().get('CF00N200000029p5q_lkid');
			System.Debug('PB: IN ApexPages.currentPage().getParameters().get(CF00N200000029p5q_lkid)');
		}
		System.Debug('PB: OUT ApexPages.currentPage().getParameters().get(CF00N200000029p5q_lkid)');
	}

	public PageReference save()
	{
		INTEGER li_Account_Supported_count = 0;
		if(accountSupported.Contact__c != null && accountSupported.Supported_Account__c != null)
			li_Account_Supported_count = [SELECT COUNT() FROM Accounts_Supported__c WHERE Contact__c = :accountSupported.Contact__c  AND Supported_Account__c = :accountSupported.Supported_Account__c];
		if(li_Account_Supported_count > 0)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'------- Duplicate record.  The Accounts Supported relationship being added already exists.');
			ApexPages.addMessage(msg);
			return null;
		}
		setASName();
		insert accountSupported;
		return new PageReference('/' + accountSupported.Id);
	}

	public PageReference saveAndNew()
	{
		INTEGER li_Account_Supported_count = 0;
		if(accountSupported.Contact__c != null && accountSupported.Supported_Account__c != null)
			li_Account_Supported_count = [SELECT COUNT() FROM Accounts_Supported__c WHERE Contact__c = :accountSupported.Contact__c  AND Supported_Account__c = :accountSupported.Supported_Account__c];
		if(li_Account_Supported_count > 0)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'------- Duplicate record.  The Accounts Supported relationship being added already exists.');
			ApexPages.addMessage(msg);
			return null;
		}
		setASName();
		insert accountSupported;
		
		// AC 10/Jul/09 - use Page syntax to build page reference - as per Salesforce recommendation
		PageReference p = Page.Auto_Forward; 
		//p.getParameters().put('CF00NR0000000XiCd_lkid', accountSupported.Contact__c);
		p.getParameters().put('CF00N200000029p5q_lkid', accountSupported.Contact__c);
        return p;
		
	}

	private void setASName(){
		Account account = [Select ID, CSN__c from Account where Id = :accountSupported.Supported_Account__c LIMIT 1];
		IF (account.CSN__c == null || account.CSN__c == '') {
			accountSupported.Name = account.ID;			
		}
		ELSE {
			accountSupported.Name = account.CSN__c;
		}
		

	}

}