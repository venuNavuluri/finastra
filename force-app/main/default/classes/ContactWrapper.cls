public class ContactWrapper {
	/* Prash(08/11/2009)	:	
	Copied and modified from HC instance 
	*/
	public Boolean Selected{get; set;}
	public Contact contact{get; set;}
	public Account account{get; set;}
	//public List<Customer_Product_Info__c> customerProductInfo{get; set;}
	public Boolean ShowAIX{get; set;}
	public Boolean ShowDell{get; set;}
	public Boolean ShowIBM{get; set;}
	public Boolean ShowCAlliance{get; set;}
	public Boolean ShowCCorporate{get; set;}
	public Boolean ShowCPremier{get; set;}
	public Boolean ShowCStrategic{get; set;}
	public Boolean SendEmail{get; set;}
	public Boolean ShowAllScripts{get; set;}
	public Boolean ShowPPEligible {get; set;}
	public Boolean ShowPPClient {get; set;}
	public Boolean ShowPPTraining {get; set;}
	public Boolean ShowMMWOnDemand {get; set;}
	public Boolean ShowMMWOnPremise {get; set;}
	public Boolean ShowMyWaySilver {get; set;}
	public Boolean ShowMyWayGold {get; set;}
	public Boolean ShowMyWayPlatinum {get; set;}
	public Boolean ShowAssure {get; set;}
	public Boolean ShowSafeguard {get; set;}	
	public Boolean ShowPremier {get; set;}

	//
	//David Walshe 3/12
	//Added this constructor for EOS searches
	//
	public ContactWrapper(Account account){
		this.contact = new Contact();
		this.account = account;
///		this.customerProductInfo = new List<Customer_Product_Info__c>();
		ShowAIX = false;
		ShowDell = false;
		ShowIBM = false;
		ShowCAlliance = false;
		ShowCCorporate = false;
		ShowCPremier = false;
		ShowCStrategic = false;
		ShowAllScripts = false;
		ShowPPEligible = false;
		ShowPPClient = false;
		ShowPPTraining = false;
		ShowMMWOnDemand = false;
		ShowMMWOnPremise = false;
		ShowMyWaySilver = false;
		ShowMyWayGold = false;
		ShowMyWayPlatinum = false;
		ShowAssure = false;
		ShowSafeguard = false;
		ShowPremier = false;		
		SendEmail = false;
	}

	public ContactWrapper(Id accountID){
		this.contact = new Contact();
		//,Head_Client__c
		this.account = [Select AccountNumber,Name from Account where Id= :accountID];
///		this.customerProductInfo = new List<Customer_Product_Info__c>();
		ShowAIX = false;
		ShowDell = false;
		ShowIBM = false;
		ShowCAlliance = false;
		ShowCCorporate = false;
		ShowCPremier = false;
		ShowCStrategic = false;
		ShowAllScripts = false;
		ShowPPEligible = false;
		ShowPPClient = false;
		ShowPPTraining = false;
		ShowMMWOnDemand = false;
		ShowMMWOnPremise = false;
		ShowMyWaySilver = false;
		ShowMyWayGold = false;
		ShowMyWayPlatinum = false;
		ShowAssure = false;
		ShowSafeguard = false;
		ShowPremier = false;		
		SendEmail = false;
	}

	public ContactWrapper(Contact contact, Account account){
		this.contact = contact;
		this.account = account;
///		this.customerProductInfo = new List<Customer_Product_Info__c>();
		ShowAIX = false;
		ShowDell = false;
		ShowIBM = false;
		ShowCAlliance = false;
		ShowCCorporate = false;
		ShowCPremier = false;
		ShowCStrategic = false;
		ShowAllScripts = false;
		ShowPPEligible = false;
		ShowPPClient = false;
		ShowPPTraining = false;
		ShowMMWOnDemand = false;
		ShowMMWOnPremise = false;
		ShowMyWaySilver = false;
		ShowMyWayGold = false;
		ShowMyWayPlatinum = false;
		ShowSafeguard = false;
		ShowPremier = false;
		if(contact.Email == null || contact.Email == ''){
			SendEmail = false;
		}else{
			SendEmail = true;
		}
	}

	public ContactWrapper(Id contactID, Id accountID){
System.debug('XXXXXX: contID:' + contactID + ', accID:' + accountID);
		this.contact = [Select Name, Phone, Email, AccountId from Contact where Id= :contactID];
		//,Head_Client__c
		this.account = [Select AccountNumber,Name from Account where Id= :accountID];
///		this.customerProductInfo = new List<Customer_Product_Info__c>();
		ShowAIX = false;
		ShowDell = false;
		ShowIBM = false;
		ShowCAlliance = false;
		ShowCCorporate = false;
		ShowCPremier = false;
		ShowCStrategic = false;
		ShowAllScripts = false;
		ShowPPEligible = false;
		ShowPPClient = false;
		ShowPPTraining = false;
		ShowMMWOnDemand = false;
		ShowMMWOnPremise = false;
		ShowMyWaySilver = false;
		ShowMyWayGold = false;
		ShowMyWayPlatinum = false;
		ShowAssure = false;
		ShowSafeguard = false;
		ShowPremier = false;
		if(contact.Email == null || contact.Email == ''){
			SendEmail = false;
		}else{
			SendEmail = true;
		}
	}

	public ContactWrapper(Boolean isTrigger, Id contactID, Id accountID){
		this.contact = [Select Name,AccountId from Contact where Id= :contactID];
		//,Hardware_Maintenance_Status__c,Head_Client__c, Assure__c, Safeguard__c, Premier_Account__c
		this.account = [Select Name,AccountNumber from Account where Id= :accountID];
	}

	public void getFullDetails(){
		//, Head_Client__c, Account_Watch__c, HIPAA_BA_Agreement__c, Allscripts_Account_No__c, MyWay_Client_Type__c,MyWay_Support_Level__c,Payerpath_Client__c, PayerPath_Eligibility__c, Partner_Program_Level__c, Enterprise_Account__c, Support_Transition_Client__c, Support_Hold__c, Client_Type__c, Beta_Client__c, Community_Client__c, Engineering_Branch__c, IBM_Code__c, Legacy_Acct_ID__c, Misys_Secure_Link_Client__c, Product_Family__c, Sub_Account_No__c, Tapeless_Backup__c, Tapeless_Offsite__c, Server_Type__c, STAR_Account__c, Software_Maintenance_Status__c, Hardware_Maintenance_Status__c, Assure__c, Safeguard__c, Premier_Account__c
		account = [Select Id, Name, AccountNumber from Account where Id = :account.Id];
		//customerCodeInfo = [Select c.Account__c, c.Beta_Client__c, c.Client_Type__c, c.Community_Client__c, c.Engineering_Branch__c, c.IBM_Code__c, c.Internal_ID__c, c.Legacy_Acct_ID__c, c.Maintenance_Hardware__c, c.Maintenance_Hold__c, c.Maintenance_Software__c, c.Misys_Secure_Link_Client__c, c.Name, c.Payerpath__c, c.Product_Family__c, c.Sales_Dev_Rep__c, c.Software_Distribution__c, c.Strategic_Account__c, c.Sub_Account_No__c, c.Support_Hold__c, c.System_Type__c, c.Tapeless_Backup__c, c.Tapeless_Offsite__c from Customer_Code_Info__c c where c.Id = :customerCodeInfo.Id];
		
		// AC 8/Jul/09 Limit to 1000 - collection can't handle any more.
		///customerProductInfo = [Select c.Install_Date__c, c.Licence_Count__c, c.Name, c.Product_Family__c from Customer_Product_Info__c c where c.Account__c = :account.Id LIMIT 1000];

		/*
		if(account.Server_Type__c == 'AIX'){
			ShowAIX = true;
		}else if(account.Server_Type__c == 'Windows - Dell'){
			ShowDell = true;
		}else if(account.Server_Type__c == 'Windows - IBM X Series'){
			ShowIBM = true;
		}

		if(account.Partner_Program_Level__c == 'Alliance'){
			ShowCAlliance = true;
		}else if(account.Partner_Program_Level__c == 'Corporate'){
			ShowCCorporate = true;
		}else if(account.Partner_Program_Level__c == 'Premier'){
			ShowCPremier = true;
		}else if(account.Partner_Program_Level__c == 'Strategic'){
			ShowCStrategic = true;
		}

		if(account.Allscripts_Account_No__c != null){
			ShowAllScripts = true;
		}

		if(account.PayerPath_Eligibility__c == true){
			ShowPPEligible = true;
		}

		if(account.Payerpath_Client__c == 'Payerpath Client'){
			ShowPPClient = true;
		}else if(account.Payerpath_Client__c == 'Payerpath Training'){
			ShowPPTraining = true;
		}

		if(account.MyWay_Client_Type__c == 'On Demand - Misys' || account.MyWay_Client_Type__c == 'On Demand - Channel Partner' || account.MyWay_Client_Type__c == 'ASP - PRO EHR and/or PM'){
			ShowMMWOnDemand = true;
		}else if(account.MyWay_Client_Type__c == 'On Premise'){
			ShowMMWOnPremise = true;
		}

		if(account.MyWay_Support_Level__c == 'Silver'){
			ShowMyWaySilver = true;
		}else if(account.MyWay_Support_Level__c == 'Gold'){
			ShowMyWayGold = true;
		}else if(account.MyWay_Support_Level__c == 'Platinum'){
			ShowMyWayPlatinum = true;
		}
		
		if(account.Assure__c != null){
			ShowAssure = true;
		}
		
		if(account.Safeguard__c == true){
			ShowSafeguard = true;
		}
		if(account.Premier_Account__c == true){
			ShowPremier = true;
		}
		*/
	}

/*
	public Boolean CheckForSupportHolds(){
		return account.Support_Hold__c;
	}
*/

     public static List<ContactWrapper> SortItems(List<ContactWrapper> items){
		List<String> accountNumbers = new List<String>();
		List<String> contactNames = new List<String>();
		Map<String,ContactWrapper> cwMap = new Map<String,ContactWrapper>();
		List<String> sortKeys = new List<String>();

		Integer count = 0;

		for(ContactWrapper cw : items){
			if(cw.account != null){
				cwMap.put(cw.account.AccountNumber + ' ' + cw.contact.Name + ' ' + count,cw);
				sortKeys.add(cw.account.AccountNumber + ' ' + cw.contact.Name + ' ' + count++);
			}
		}

		sortKeys.sort();

		List<ContactWrapper> returnItems = new List<ContactWrapper>();

		for(String key : sortKeys){
			returnItems.add(cwMap.get(key));
		}

		return returnItems;
	}


	/*public static List<ContactWrapper> SortItems(List<ContactWrapper> items){
		List<String> accountNumbers = new List<String>();
		List<String> contactNames = new List<String>();
		Map<String,ContactWrapper> cwMap = new Map<String,ContactWrapper>();


		for(ContactWrapper cw : items){
			cwMap.put(cw.account.AccountNumber + cw.contact.Name,cw);

			Boolean containedAlready = false;
			for(String an : accountNumbers){
				if(an == cw.account.AccountNumber){
					containedAlready = true;
					break;
				}
			}
			if(!containedAlready)
				accountNumbers.add(cw.account.AccountNumber);

			Boolean containedAlreadyContact = false;
			for(String cn : contactNames){
				if(cn == cw.contact.Name){
					containedAlreadyContact = true;
					break;
				}
			}
			if(!containedAlreadyContact)
				contactNames.add(cw.contact.Name);
		}
		accountNumbers.sort();
		contactNames.sort();

		List<ContactWrapper> returnItems = new List<ContactWrapper>();

		for(String an : accountNumbers){
			for(String cn : contactNames){
				//for(ContactWrapper cw : items){
					//if(cw.account.AccountNumber == an && cw.contact.Name == cn){
					//	returnItems.add(cw);
					//}
				//}
				if(cwMap.containsKey(an + cn)){
					returnItems.add(cwMap.get(an + cn));
				}
			}
		}
		return returnItems;
	}*/

  // AC 9/4/09 - test methods moved to separate class
}