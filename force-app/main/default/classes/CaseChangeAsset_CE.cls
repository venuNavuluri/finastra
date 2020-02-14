public class CaseChangeAsset_CE {

	public Case customerCase {get; set;}
	public Contact chosenContact {get; set;}
	public Account chosenAccount {get; set;}
	public Level1CaseCapturePage2Controller LAC {get; set;}
	public SessionInfo CurrentSessionInfo {get; set;}
	
	//public String generalMessage {get; set;}
	public String productSetChosen {get; set;}
	public String systemChosen {get; set;}
	public String entitlementName {get; set;}
	public String supportAlert {get; set;}
	public String systemName {get; set;}
	public String originalProductSet {get; set;}
	public String originalEntitlement {get; set;}
	public String originalSystem {get; set;}
	public String originalClientAsset {get; set;}
	public String validationMessage {get; set;}
	
	public List<SelectOption> systemsDDV {get; set;}
	public List<SelectOption> productSetsDDV {get; set;}
	public List<SelectOption> assetsDDV {get; set;}
	
	//public Map<String, List<Product_Set__c>> productSetNameToProductSetMap {get; set;}
	//public Map<String, Set<Id>> psNameToPSIdsMap {get; set;}
	//public Map<String, Id> psNameSysIdToPSId {get; set;}
	//public Map<Id, String> systemIdToEnvironment {get; set;}

	public Boolean origUpdated = false;
	public Boolean hasSupportAlert {get; set;}
	public Boolean displayGeneralMessage {get; set;}
	public Boolean isGeneralEntitlement {get; set;}
	public Boolean isGeneralProductSet {get; set;}
	public Boolean isGeneralSystem {get; set;}
	public Boolean isCaseTypeProject {get; set;}
	public Boolean displayValidationMessage {get; set;}

	//Constructor
	public CaseChangeAsset_CE (ApexPages.StandardController stdController){
		customerCase = (Case)stdController.getRecord();
		
		chosenAccount = null;
		if(customerCase.AccountId != null){
			chosenAccount = [select Id, Type, Name, Account_Asset_Location__c from Account where Id = :customerCase.AccountId];
		}
		
		chosenContact = null;
		if(customerCase.ContactId != null){
			chosenContact = [select Id, Name from Contact where Id = :customerCase.ContactId];
		}
		
		//Set original values to diplay
		setOriginalValues();
		
		//Clear out current values
		customerCase.Product_Set__c = null;
		customerCase.Product_Set_Text__c = null;
		customerCase.Support_Entitlement__c = null;
		customerCase.System__c = null;
		customerCase.System_Text__c = null;
		customerCase.Client_Asset__c = null;
		customerCase.Client_Asset_Text__c = null;
		
		//Call the method to populate the drop-down lists
		populateProductSetValues();
	}

    public String generalMessage {
    	get{
    		if(LAC.isGeneralProductSet)
    		{
    			generalMessage = Label.LAC_Generic_PS_Message;
    		}else if(LAC.isGeneralSystem)
    		{
    			generalMessage = Label.LAC_Generic_System_Message;
    		}else{
    			generalMessage = '';
    		}
    		system.debug('CaseChangeAsset_CE.generalMessage = '+generalMessage);
    		return generalMessage;
    	}
    	private set;
    }
	
	
	public Boolean showProductSetVersion {
		get{
			showProductSetVersion = false;
			if(productSetChosen != null){
				if(ProductSetToRecordTypeId__c.getValues(productSetChosen.toUpperCase()) != null){
					if(ProductSetToRecordTypeId__c.getValues(productSetChosen.toUpperCase()).Category__c == 'Turaz'){
						showProductSetVersion = true;
					}
				}
			}
			return showProductSetVersion;
		}
		private set;
	}
	
	public void setOriginalValues()
	{
		if(origUpdated == false){
			originalProductSet = customerCase.Product_Set__r.Name;
			originalEntitlement = customerCase.Support_Entitlement__r.Name;
			originalSystem = customerCase.System__r.Name;
			originalClientAsset = customerCase.Client_Asset__r.Name;
			origUpdated = true;
		}
	}
	
	public Level1CaseCapturePage2Controller getLAC()
	{
		//Instantiate the related Log A Case class and set values
		Level1CaseCapturePage2Controller iLAC = new Level1CaseCapturePage2Controller();
		iLAC.newCase = customerCase;
		iLAC.chosenAccount = chosenAccount;
		iLAC.chosenContact = chosenContact;
		
		return iLAC;
	}
	
	private void setLAC(){}

	public void populateProductSetValues(){
		
		LAC = getLAC();
		LAC.populateProductSet();
		
		productSetsDDV = LAC.productSetsDDV;
		systemsDDV = LAC.systemsDDV;
		assetsDDV = LAC.assetsDDV;
		
		system.debug('CaseChangeAsset_CE.populateProductSetValues - productSetsDDV: '+productSetsDDV);
		system.debug('CaseChangeAsset_CE.populateProductSetValues - systemsDDV: '+systemsDDV);
		system.debug('CaseChangeAsset_CE.populateProductSetValues - assetsDDV: '+assetsDDV);
		
		productSetChosen = LAC.productSetChosen;
		system.debug('CaseChangeAsset_CE.populateProductSetValues - productSetChosen: '+productSetChosen);
		
		displayGeneralMessage = LAC.displayGeneralMessage;
		isGeneralProductSet = LAC.isGeneralProductSet;
		isGeneralSystem = LAC.isGeneralSystem;
		isGeneralEntitlement = LAC.isGeneralEntitlement;
		
	}

	public void productSetSelected(){
		
		//Set the value for the LAC process
		LAC.productSetChosen = productSetChosen;
		
		LAC.productSetSelected();
		productSetChosen = LAC.productSetChosen;
		system.debug('CaseChangeAsset_CE.productSetSelected - productSetChosen: '+productSetChosen);
		
		//Update the drop-down lists for the VF page
		systemsDDV = LAC.systemsDDV;
		assetsDDV = LAC.assetsDDV;
		system.debug('CaseChangeAsset_CE.productSetSelected - systemsDDV: '+systemsDDV);
		system.debug('CaseChangeAsset_CE.productSetSelected - assetsDDV: '+assetsDDV);
		
		customerCase.Product_Set__c = LAC.newCase.Product_Set__c;
		customerCase.Support_Entitlement__c = LAC.newCase.Support_Entitlement__c;
		hasSupportAlert = LAC.hasSupportAlert;
		supportAlert = LAC.supportAlert;
		productSetChosen = LAC.productSetChosen;
		displayGeneralMessage = LAC.displayGeneralMessage;
		generalMessage = LAC.generalMessage;
		isGeneralProductSet = LAC.isGeneralProductSet;
		isGeneralSystem = LAC.isGeneralSystem;
		isGeneralEntitlement = LAC.isGeneralEntitlement;	
		systemChosen = LAC.newCase.System__c;
		systemName = LAC.systemname;
		customerCase.System__c = LAC.newCase.System__c;
		system.debug('CaseChangeAsset_CE.productSetSelected - generalMessage = '+generalMessage);
	}

	public void systemSelected() {
		
		customerCase.Client_Asset__c = null;
		
		LAC.newCase.System__c = systemChosen;
		LAC.systemSelected();
		
		assetsDDV = LAC.assetsDDV;
		system.debug('CaseChangeAsset_CE.systemSelected - assetsDDV: '+assetsDDV);
		
		customerCase.Product_Set__c = LAC.newCase.Product_Set__c;
		customerCase.Support_Entitlement__c = LAC.newCase.Support_Entitlement__c;
		productSetChosen = LAC.productSetChosen;
		systemChosen = LAC.newCase.System__c;
		displayGeneralMessage = LAC.displayGeneralMessage;
		generalMessage = LAC.generalMessage;
		isGeneralProductSet = LAC.isGeneralProductSet;
		isGeneralSystem = LAC.isGeneralSystem;
		isGeneralEntitlement = LAC.isGeneralEntitlement;		
		systemName = LAC.systemname;
		customerCase.System__c = LAC.newCase.System__c;
		systemChosen = LAC.newCase.System__c;
		system.debug('CaseChangeAsset_CE.systemSelected - systemChosen: '+systemChosen);
		system.debug('CaseChangeAsset_CE.systemSelected - generalMessage = '+generalMessage);
	}
	
	public Boolean validate()
	{
		Boolean returnValue = true;
		
		validationMessage = '<ul>';
		
		if(customerCase.Product_Set__c == null && !isGeneralProductSet){
			returnValue = false;
			validationMessage = validationMessage + '<li>Product Set must be filled in</li>';
		}
		
		if(customerCase.System__c == null && !isGeneralSystem){
			returnValue = false;
			validationMessage = validationMessage + '<li>System must be filled in</li>';
		}
		
		validationMessage = validationMessage + '</ul>';
		displayValidationMessage = !returnValue;
		system.debug('CaseChangeAsset_CE.validate - validationMessage: '+validationMessage);
		
		return returnValue;
	}
	
	//Save and return to the main Case page if successful
	public pageReference saveChange() 
	{	
		PageReference p = null;
		
		//customerCase.System__c = systemChosen;
		
		SavePoint sp = Database.setSavepoint();
		try
		{
			if(saveNewCase()){
				p = new PageReference('/' + customerCase.Id);
				return p;
			}else{
				return null;
			}
		}
		catch(DMLException dmle)
		{
			ApexPages.addMessage(new ApexPages.message(APexPages.severity.FATAL, 'Error saving changes: '+dmle));
			Database.rollback(sp);
			return null;
		}
		catch(Exception exc)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, 'Error saving changes: '+exc));
			Database.rollback(sp);
			return null;
		}
	}

	//The logic for actually saving the case. 
	public Boolean saveNewCase()
	{
		Boolean returnValue = false;
				
		system.debug('CaseChangeAsset_CE.saveNewCase - 1');
		if(validate())
		{
			//Set the Product Set and Product Set Text
			system.debug('CaseChangeAsset_CE.saveNewCase - customerCase.Product_Set__c: '+customerCase.Product_Set__c);
			customerCase.Product_Set_Text__c = productSetChosen;
			system.debug('CaseChangeAsset_CE.saveNewCase - customerCase.Product_Set_Text__c: '+customerCase.Product_Set_Text__c);
			
			//Set the System and System Text
			system.debug('CaseChangeAsset_CE.saveNewCase - customerCase.System__c: '+customerCase.System__c);
			customerCase.System_Text__c = customerCase.System__r.Name;
			//customerCase.System_Text__c = systemChosen;
			system.debug('CaseChangeAsset_CE.saveNewCase - customerCase.System_Text__c: '+customerCase.System_Text__c);
			
			//Set the Support Entitlement
			system.debug('CaseChangeAsset_CE.saveNewCase - customerCase.Support_Entitlement__c: '+customerCase.Support_Entitlement__c);
			
			//Set the Client Asset and Client Asset Text
			if(customerCase.Client_Asset__c != null){
				system.debug('CaseChangeAsset_CE.saveNewCase - customerCase.Client_Asset__c: '+customerCase.Client_Asset__c);
				if(assetsDDV != null){
		       		system.debug('CaseChangeAsset_CE.saveNewCase - assetsDDV : '+ assetsDDV);
		       		for(SelectOption assetDDV : assetsDDV){
		       			system.debug('CaseChangeAsset_CE.saveNewCase - assetDDV(label,value) : '+ assetDDV.getValue() + ',' + assetDDV.getLabel());
		       			if(assetDDV.getValue() != '' && assetDDV.getValue() == customerCase.Client_Asset__c){
		       				customerCase.Client_Asset_Text__c = assetDDV.getLabel();
		       				break;
		       			}
		       		}
		       	}
	       	}
			system.debug('CaseChangeAsset_CE.saveNewCase - customerCase.Client_Asset_Text__c: '+customerCase.Client_Asset_Text__c);
			
			//Set the RecordTypeId
			if(ProductSetToRecordTypeId__c.getValues(productSetChosen.toUpperCase()) != null)
			{
				customerCase.RecordTypeId = ProductSetToRecordTypeId__c.getValues(productSetChosen.toUpperCase()).Record_Type_Id__c;
			}else{
				customerCase.RecordTypeId = Constants__c.getValues('DEFAULT_CASE_RECORDTYPE_ID').Value__c;
			}
			system.debug('CaseChangeAsset_CE.saveNewCase - customerCase.RecordTypeId: '+customerCase.RecordTypeId);
			
			//Check to see if the case is logged against the dummy entitlement (no entitlement, needs triage)
	       	if(isGeneralEntitlement){
	       		customerCase.Logged_Without_Entitlement__c = true;
	       	}
	       	
	       	system.debug('CaseChangeAsset_CE.saveNewCase - customerCase: '+customerCase);
	       	
	       	update customerCase;
	       	
	       	returnValue = true;
		}
		return returnValue;
	}

}