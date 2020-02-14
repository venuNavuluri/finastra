global class CreateRLFPackageBatch  implements Database.Batchable<sObject> {
	
	global string query;
	
	global CreateRLFPackageBatch(){
		query = 'select id, Name, Original_Opportunity__c, Original_Opportunity__r.CurrencyIsoCode, Original_Opportunity__r.Customer_PO__c,'+ 
	    'Original_Opportunity__r.CloseDate, Original_Opportunity__r.OwnerId, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Original_Opportunity__r.Owner.FirstName,'+ 
	    'Original_Opportunity__r.Owner.LastName, Original_Contract__c, Original_Contract__r.CustomerSignedDate, Original_Contract__r.StartDate,'+ 
	    'Original_Contract__r.Memo__c, Account_by_Sub__c, Account_by_Sub__r.name, Account_by_Sub__r.Misys_Entity__c, Account_by_Sub__r.Account__r.NS_Finance_Region__c,'+ 
	    'Account_by_Sub__r.Account__r.NS_Currency__c, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.PO_Required__c,'+ 
	    'Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c, Account_by_Sub__r.NS_Export_to_Openair__c,'+ 
	    'Account_by_Sub__r.Account__r.Credit_Controller__c, Account_by_Sub__r.NS_Invoice_Translation__c, Account_by_Sub__r.NS_Invoice_Translation_Language__c,'+
        'Account_by_Sub__r.NS_Invoice_Translation_Language_Code__c, CurrencyIsoCode,  NS_Customer_Address__c, NS_Customer_Ship_To_Address__c,'+
        'Original_Customer_Signed_Date__c, Current_Sales_Order_Start_Date__c, NS_Subscription_Start_Date__c, NS_Subscription_Memo__c, NS_Subscription_Start_Type__c,'+
        'NS_Subscription_Option__c, NS_Billing_Mode__c, NS_Termination_Method__c, Fixed_Billing_Date__c, Subscription_Plan_Base_Key__c,'+
        'Reset_Next_Bill_Date__c, BG_Next_Invoice_Due_Date__c, NS_Specific_Invoice_Wording__c, Set_Tax_Combo_Override__c, BG_Opportunity_Number_s_migration__c,'+
        'BG_Contract_Date_migration__c, Order_Sub_Type__c'+
        ' from Billing_Group__c where RLF_Batch_Create__c = true and RLF_Batch_Create_Complete__c = false and Reseed_RLF_Package_Created__c = false';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){

	   return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		
		List<Billing_Group__c> bgList = (List<Billing_Group__c>)scope;
		
		if(!bgList.isEmpty()){
			//This is assumed that the batch size coming in will always be 1.
			GlobalVar.bInFuture = true;
			CreateRLFPackage.createRLFPackages(bgList[0].Id);
		}	
	}
	
	global void finish(Database.BatchableContext BC){
		
	}

}