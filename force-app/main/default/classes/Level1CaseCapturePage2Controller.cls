public class Level1CaseCapturePage2Controller {
	
	public Case newCase {get; set;}
	public Contact chosenContact {get; set;}
	public Account chosenAccount {get; set;}
	public CaseComment caseComment {get; set;}
	public Boolean useDefaultAssignmentRules {get; set;}
	public SessionInfo CurrentSessionInfo {get; set;}
	//public String callingPicklist {get; set;}
	public Boolean displayValidationMessage {get; set;}
	public String validationMessage {get; set;}
	public String productSetChosen {get; set;}
	public String caseTypeChosen {get; set;}
	public Boolean displayGeneralMessage {get; set;}
	public String generalMessage {get; set;}
	public Boolean sendEmailToContact {get; set;}
	public String entitlementName {get; set;}
	public Boolean isGeneralEntitlement {get; set;}
	public Boolean isGeneralProductSet {get; set;}
	public String supportAlert {get; set;}
	public Boolean hasSupportAlert {get; set;}
	
	public List<SelectOption> systemsDDV {get; set;}
	public List<SelectOption> productSetsDDV {get; set;}
	public List<SelectOption> assetsDDV {get; set;}
	public List<SelectOption> projectDDV {get; set;}
	//public List<SelectOption> componentDDV {get; set;}
	public List<SelectOption> caseTypeDDV {get; set;}
	
	//private Map<Id, Contract_Asset__c> assetIdToContractAssetMap {get; set;}
	public Map<String, List<Product_Set__c>> productSetNameToProductSetMap {get; set;}
	public Map<String, Id> psNameSysIdToPSId {get; set;}
	public Map<Id, String> systemIdToEnvironmentDevName {get; set;}
	public Map<String, Set<Id>> psNameToPSIdsMap {get; set;}
	public Map<Id,String> projectIdToCode {get;set;}
	public Boolean isGeneralSystem {get; set;}
	public string systemname {get; set;}
	private string caseRecordTypeName = '';
	
	//private String firstChoice {get; set;}
	private Map<String, Constants__c> generalSettings {get; set;}
	private Map<String, ProductSetToRecordTypeId__c> rtMap {get; set;}
	private ProductSetToRecordTypeId__c psSettings {get; set;}

	/** Constructor **/
	public Level1CaseCapturePage2Controller(){
		//Reuse the existing SessionInfo class
		CurrentSessionInfo = new SessionInfo();
		
		displayValidationMessage = false;
		validationMessage = '';
		displayGeneralMessage = false;
		sendEmailToContact = false;
		isGeneralEntitlement = false;
		isGeneralSystem = false;
		isGeneralProductSet = false;
		
		//Get Custom Settings data 
		generalSettings = Constants__c.getAll();
		System.debug('XXX Level1CaseCapturePage2Controller: Level1CaseCapturePage2Controller: General Settings: ' + generalSettings);
		rtMap = ProductSetToRecordTypeId__c.getAll();
		System.debug('XXX Level1CaseCapturePage2Controller: Level1CaseCapturePage2Controller: rtMap: ' + rtMap);
		
		//Initialise the Case with default values
		newCase = new Case();
		newCase.Status = generalSettings.get('DEFAULT_STATUS').Value__c;
		if(CurrentSessionInfo.InPortal){
			newCase.Origin = generalSettings.get('DEFAULT_ORIGIN_PORTAL').Value__c;
			useDefaultAssignmentRules = true;
			newCase.Case_related_to_live_project__c = 'Yes';
		}else{
			newCase.Type = generalSettings.get('DEFAULT_TYPE').Value__c;
			newCase.Origin = generalSettings.get('DEFAULT_ORIGIN').Value__c;
            useDefaultAssignmentRules = false;
		}
		newCase.Severity__c = generalSettings.get('DEFAULT_SEVERITY').Value__c;
		newCase.Internal_Severity__c = generalSettings.get('DEFAULT_INTERNAL_SEVERITY').Value__c;
		newCase.Urgency__c = generalSettings.get('DEFAULT_URGENCY').Value__c;
		newCase.RecordTypeId = generalSettings.get('DEFAULT_CASE_RECORDTYPE_ID').Value__c;
		
		//Case comment will be used to capture input into the comments area
		caseComment = new CaseComment();
		
		//The page "Level1_Case_CaptureV2" will pass through a selected contact and account via the url
		//Retrieve these values and the records associated to them.
		if(ApexPages.currentPage().getParameters().get('contactid') != null){
			newCase.ContactId = ApexPages.currentPage().getParameters().get('contactid');
			chosenContact = [select Id, Name from Contact where Id = :newCase.ContactId];
		}
		
		if(ApexPages.currentPage().getParameters().get('accountid') != null){
			newCase.AccountId = ApexPages.currentPage().getParameters().get('accountid');
			chosenAccount = [select Id, Name, Type from Account where Id = :newCase.AccountId];
			
			populateProductSet();
			
			//populate the Project list if not being logged from the portal
			if(!CurrentSessionInfo.InPortal){
				populateProjectInformation();
			}
		}
		
		caseTypeDDV = new List<SelectOption>();
		caseTypeDDV.add(new SelectOption('Support', 'Customer Support'));
		caseTypeDDV.add(new SelectOption('Project', 'Project'));
	}

	
	/************************************************************ CONTROLLER PROPERTIES ******************************************/
	
	public Boolean showTypeField
	{
		get {
			return (isCaseTypeProject || CurrentSessionInfo.InPortal) && !IsINDCase;
		}
		private set;
	}
	
	public Boolean isCaseTypeProject{
      get{
        if(caseTypeChosen == 'Project'){
          isCaseTypeProject = true;
        }else{
        	isCaseTypeProject = false;
        }
        return isCaseTypeProject;
      }
      
      private set;
    }
    
    public Boolean IsINDCase
    {
    	get { return newCase.RecordTypeId == Label.RecTypeId_Case_IND; }
    	private set;
    }
    
    public Boolean showSystemStatusField
    {
   		// JoeT - SRR-1038687
    	get { return !isGeneralProductSet && !IsINDCase; }
    	private set;
    }
    
    public Boolean showProductFields{
    	get{
    		//  JRB - As of 5 Sept, Turaz product sets should be available on the portal, so always show these fields.
    		////Hide for Kondor cases
    		//if((caseRecordTypeName != null && caseRecordTypeName.contains('Kondor')) || isGeneralProductSet){
    		system.debug('Level1CaseCapturePage2Controller.showProductFields - psSettings = '+psSettings);
    		if((psSettings != null && psSettings.Category__c == 'Turaz') ||
    			isGeneralProductSet ||
    			IsINDCase
    		) {
    			showProductFields = false;
    		//Show for others
    		}
    		else {
    			showProductFields = true;
    		}
    		//showProductFields = true;
    		return showProductFields;
    	}
    	private set;
    }
    
    public Boolean requireProductFields{
    	get{
    		//  JRB - As of 5 Sept, Turaz product sets should be available on the portal, so always show these fields.
    		//Not required for Kondor cases
    		//if(caseRecordTypeName != null && caseRecordTypeName.contains('Kondor')){
    		system.debug('Level1CaseCapturePage2Controller.requireProductSet - psSettings = '+psSettings);
			if (psSettings != null && psSettings.Category__c == 'Turaz') {    			
    			requireProductFields = false;
    		}
    		else if (IsINDCase){
    			requireProductFields = false;
    		}
    		else if (productSetChosen != null && productSetChosen != '' && !isGeneralProductSet && psSettings != null){
    			requireProductFields = true;
    		}
    		else {
    			requireProductFields = false;
    		}
    		return requireProductFields;
    	}
    	private set;
    }
	
	public Boolean showSophisFields{
    	get{
    		//  JRB - Determine if this is a Sophis client, in which case the fields should be shown
    		system.debug('Level1CaseCapturePage2Controller.showSophisFields - psSettings = '+psSettings);
    		if((psSettings != null && psSettings.Category__c == 'Sophis')){
    			showSophisFields = true;
    		}else{
    			//Hide for non-Sophis cases
    			showSophisFields = false;
    		}
    		//showProductFields = true;
    		return showSophisFields;
    	}
    	private set;
    }	
	
	/*
	private Set<Id> getAssetLocationAccountIds(Id ccrtId)
	{
		Set<Id> acctIds = new Set<Id>();
		for (Location_of_Use__c lou : [select Contract_Asset__r.Account__c from Location_of_Use__c where CCRT__c = :ccrtId])
		{
			acctIds.add(lou.Contract_Asset__r.Account__c);
		}
		return acctIds;
	}
	*/
	
	/************************************************************** POPULATE DROP-DOWN LISTS ******************************************/
	
	//Product Set is the first field to get populated with values, and as such it controls all the other drop
	//down fields on the form.
	//When called we have the Account chosen, so we retrieve the Product Sets that apply by:
	// - Retrieving CCRT record associated with the account
	// - Retrieving the Location of Use records associated with the CCRT record
	// - Retrieving the Contract Assets associated with the Location of Use records
	// - Retrieving the Client Asset records associated with the Contract Assets
	// - Finally retrieving the Product Set records associated with the Client Assets.
	//By structuring the queries correctly however, we have streamlined those steps below
	//Finally, if it happens that the Account does not have a Product Set to log the case against (in the
	//scenario where it hasn't been entered into SFDC yet), then there is a "Dummy" record to log against
	//which at least allows the case to be entered. 
	//Note that a Product Set has a many to many relationship with System, so it is only when System is chosen
	//that we know which product set is actually chosen (via entitlement)
	public void populateProductSet(){
		productSetNameToProductSetMap = new Map<String, List<Product_Set__c>>();
		 
		productSetsDDV = new List<SelectOption>();
		productSetsDDV.add(new SelectOption('', 'Please Select'));
		
		displayGeneralMessage = false;
		isGeneralProductSet = false;
		isGeneralSystem = false;
		isGeneralEntitlement = false;
		
		system.debug('Level1CaseCapturePage2Controller.populateProductSet - newCase.AccountId: '+newCase.AccountId);
		system.debug('Level1CaseCapturePage2Controller.populateProductSet - newCase.ContactId: '+newCase.ContactId);
		
		Set<Id> acctIds = new Set<Id>{newCase.AccountId};
		/*
		if (chosenAccount != null &&
			chosenAccount.Type == 'Support Location Only' &&
			chosenAccount.Account_Asset_Location__c != null
		) {
			acctIds.add(chosenAccount.Account_Asset_Location__c);
		}
		*/
		
		//Get a list of "Locations of Use" linked to the Account
		Set<Id> caIds = new Set<Id>();
		for(Location_of_Use__c lou : [
			Select Id, Contract_Asset__c, CCRT__r.Id, CCRT__r.Account__c
			from Location_of_Use__c
			where CCRT__r.Account__c in :acctIds
		]) {
			caIds.add(lou.Contract_Asset__c);
		}
		system.debug('Level1CaseCapturePage2Controller.populateProductSet - Loc Of Use caIds: '+caIds);
		
		//Set to make sure we only have singular Product Sets, rather than duplicates
		psNameToPSIdsMap = new Map<String, Set<Id>>();

		//Get a list of Contract Assets based on the ones linked to this account via Locations of Use or directly related to the account
		//AK 980801 - Added the where clause and Client_Asset__r.Product_Set__r.Support_Entitlement_Count__c > 0 
		//so that the contract assest which have the associated Product Sets with 1 or more active Entitlements are show to the user.
		for (Contract_Asset__c ca : [
			select Id, Client_Asset__r.Product_Set__r.Id, Client_Asset__r.Product_Set__r.Name
			from Contract_Asset__c 
			where (Id in :caIds or Account__c = :newCase.AccountId) and Client_Asset__r.Product_Set__r.Id <> null 
			and Client_Asset__r.Product_Set__r.Support_Entitlement_Count__c > 0
		]) {
			if(psNameToPSIdsMap.containsKey(ca.Client_Asset__r.Product_Set__r.Name)){
				if(!psNameToPSIdsMap.get(ca.Client_Asset__r.Product_Set__r.Name).contains(ca.Client_Asset__r.Product_Set__r.Id)){
					psNameToPSIdsMap.get(ca.Client_Asset__r.Product_Set__r.Name).add(ca.Client_Asset__r.Product_Set__r.Id);
					productSetNameToProductSetMap.get(ca.Client_Asset__r.Product_Set__r.Name).add(ca.Client_Asset__r.Product_Set__r);
				}
			}
			else {
				psNameToPSIdsMap.put(ca.Client_Asset__r.Product_Set__r.Name, new Set<ID>{ca.Client_Asset__r.Product_Set__r.Id});
				productSetNameToProductSetMap.put(ca.Client_Asset__r.Product_Set__r.Name, new List<Product_Set__c>{ca.Client_Asset__r.Product_Set__r});
				//productSetsDDV.add(new SelectOption(ca.Client_Asset__r.Product_Set__r.Name, ca.Client_Asset__r.Product_Set__r.Name));
				
				//Add the Product Set to the list, excluding any that should not appear in the portal
				//if not in portal OR in portal and product_set_r.name not in ExclusionList, then add to the DDV list  
				if(CurrentSessionInfo.InPortal == false || 
					(CurrentSessionInfo.InPortal == true && 
					(rtMap.get(ca.Client_Asset__r.Product_Set__r.Name) == null || 
					rtMap.get(ca.Client_Asset__r.Product_Set__r.Name).Exclude_In_Portal__c == false))) {
						productSetsDDV.add(new SelectOption(ca.Client_Asset__r.Product_Set__r.Name, ca.Client_Asset__r.Product_Set__r.Name));
				}
			}
		}
		
		system.debug('Level1CaseCapturePage2Controller.populateProductSet - psNameToPSIdsMap: ' + psNameToPSIdsMap);
		system.debug('Level1CaseCapturePage2Controller.populateProductSet - productSetNameToProductSetMap: ' + productSetNameToProductSetMap);
		system.debug('Level1CaseCapturePage2Controller.populateProductSet - productSetsDDV: ' + productSetsDDV);

		if(productSetsDDV.size() == 1){
			productSetsDDV.remove(0);
			Product_Set__c dummyPS = [Select Id, Name from Product_Set__c where Id = :generalSettings.get('DUMMY PRODUCT SET ID').Value__c];
			productSetNameToProductSetMap.put(dummyPS.Name, new List<Product_Set__c>{dummyPS});
			productSetsDDV.add(new SelectOption(dummyPS.Name, dummyPS.Name));
			productSetChosen = dummyPS.Name;
			displayGeneralMessage = true;
			generalMessage = Label.LAC_Generic_PS_Message;
			isGeneralProductSet = true;
			productSetSelected();
		}else if(productSetsDDV.size() == 2){
			productSetsDDV.remove(0);
			productSetChosen = productSetsDDV[0].getValue();
			productSetSelected();
		}
		system.debug('Level1CaseCapturePage2Controller.populateProductSet - productSetChosen: '+productSetChosen);
		system.debug('Level1CaseCapturePage2Controller.populateProductSet - displayGeneralMessage: '+displayGeneralMessage);
		system.debug('Level1CaseCapturePage2Controller.populateProductSet - isGeneralProductSet: '+isGeneralProductSet);
	}
	
	//If there is a product set chosen (which there should always be when this method is called) then
	//a list of System records are retrieved using the Support Entitlement records as the bridge for this
	//many to many relationship. Duplicate values (where 2 Support Entitlements link same system and product set)
	//are ignored and the first value is displayed only.
	//We also populate a map of System to Environment so that this can be used when populating Assets drop down
	public void populateSystems(){
		displayGeneralMessage = false;
		isGeneralSystem = false;
		systemsDDV = new List<SelectOption>();
		systemsDDV.add(new SelectOption('', 'Please Select'));
		
		psNameSysIdToPSId = new Map<String, Id>();
		systemIdToEnvironmentDevName = new Map<Id, string>();
		
		System.debug('Level1CaseCapturePage2Controller.populateSystems - productSetChosen : ' + productSetChosen);
		System.debug('Level1CaseCapturePage2Controller.populateSystems - productSetNameToProductSetMap : ' + productSetNameToProductSetMap);
		
		if(productSetChosen != null && productSetChosen != ''){
			Set<Id> productSetIds = new Set<Id>();
			for(Product_Set__c ps : productSetNameToProductSetMap.get(productSetChosen)){
				if(ps != null){
					productSetIds.add(ps.Id);
				}
			}
			System.debug('Level1CaseCapturePage2Controller.populateSystems - productSetIds : ' + productSetIds);
			
			Set<Id> systemIds = new Set<Id>();
			//AK 980801 - Added the where clause Status__c = 'Active' so that only Active Entitlements are show to the user.
			for(Entitlement__c entitlement : [select Id, System__c, Product_Set__c, Product_Set__r.Name from Entitlement__c where Product_Set__c in :productSetIds and Status__c = 'Active']){
				systemIds.add(entitlement.System__c);
				if(!psNameSysIdToPSId.containsKey(entitlement.Product_Set__r.Name + entitlement.System__c)){
					psNameSysIdToPSId.put(entitlement.Product_Set__r.Name + entitlement.System__c, entitlement.Product_Set__c);
				}
			}
			
			for(System__c sys : [select Id, Name, Environment2__c from System__c where Id in :systemIds]){
				systemsDDV.add(new SelectOption(sys.Id, sys.Name));
				systemIdToEnvironmentDevName.put(sys.Id, sys.Environment2__c);
			}
		}
		system.debug('Level1CaseCapturePage2Controller.populateSystems - psNameSysIdToPSId: '+psNameSysIdToPSId);
		system.debug('Level1CaseCapturePage2Controller.populateSystems - systemsDDV: '+systemsDDV);
		system.debug('Level1CaseCapturePage2Controller.populateSystems - systemIdToEnvironmentDevName: '+systemIdToEnvironmentDevName);
		
		if(systemsDDV.size() == 1){
			systemsDDV.remove(0);
			//JRB System__c dummySystem = [select Id, Name, Environment__c from System__c where Id = :generalSettings.get('DUMMY SYSTEM ID').Value__c];
			//JRB  systemsDDV.add(new SelectOption(dummySystem.Id, dummySystem.Name));
			systemsDDV.add(new SelectOption('General System','General System'));
			//JRB newCase.System__c = dummySystem.Id;
			isGeneralSystem = true;
			systemname = 'General System';
			systemSelected();
			displayGeneralMessage = true;
			generalMessage = Label.LAC_Generic_System_Message;
		}else if(systemsDDV.size() == 2){
			systemsDDV.remove(0);
			newCase.System__c = systemsDDV[0].getValue();
			isGeneralSystem = false;
			//callingPicklist = 'system';
			//systemOrProductSetSelected();
			systemSelected();
		}
		system.debug('Level1CaseCapturePage2Controller.populateSystems -isGeneralSystem: '+isGeneralSystem);
	}
	
	//Retrieve Active entitlements linked to the Product Set and System that have been chosen.
	//If no entitlement is retured, then use the "General" entitlement to allow the Case to be saved.
	public void populateEntitlements(){
		
		newCase.Support_Entitlement__c = null;
		
		for(Entitlement__c ent : [Select Id, Name/*, Support_Alerts__c*/ from Entitlement__c where Status__c = 'Active' and Product_Set__c = :newCase.Product_Set__c and System__c = :newCase.System__c]){
			newCase.Support_Entitlement__c = ent.Id;
			entitlementName = ent.Name;
			isGeneralEntitlement = false;
			/*
			if(ent.Support_Alerts__c == null || ent.Support_Alerts__c == '')
			{
				supportAlert = null;
				hasSupportAlert = false;
			}else{
				supportAlert = ent.Support_Alerts__c;
				hasSupportAlert = true;
			}
			*/
			break;
		}
		
		if(newCase.Support_Entitlement__c == null){
			//If there are no entitlements for the customer, then we allow them to log the case under the general entitlements section
			//Entitlement__c dummyEnt = [Select Id, Name from Entitlement__c where Id = :generalSettings.get('DUMMY_ENTITLEMENT_ID').Value__c];
			//newCase.Support_Entitlement__c = dummyEnt.Id;
			//entitlementName = dummyEnt.Name;
			entitlementName = 'NO Service Entitlement';
			isGeneralEntitlement = true;
		}
	}

	//Retrieve all assets where the Asset is linked to the Product Set that is chosen, and the Asset
	//Environment field matches with the Environment field on the System record chosen.
	public void populateAssets(){
		
		assetsDDV = new List<SelectOption>();
		assetsDDV.add(new SelectOption('', 'Please Select'));
		
		if(!isGeneralSystem){
			System.debug('XXX Level1CaseCapturePage2Controller: populateAssets: system: ' + newCase.System__c);
			System.debug('XXX Level1CaseCapturePage2Controller: populateAssets: environment: ' + systemIdToEnvironmentDevName.get(newCase.System__c));
			System.debug('XXX Level1CaseCapturePage2Controller: populateAssets: product set: ' + newCase.Product_Set__c);
			
			Set<Id> uniqueAssetIds = new Set<Id>();
			for (Contract_Asset__c conA : [
				select Client_Asset__c, Client_Asset__r.Name from Contract_Asset__c
				where Client_Asset__r.Product_Set__c = :newCase.Product_Set__c
				and Environment2__c != null
				and Environment2__c = :systemIdToEnvironmentDevName.get(newCase.System__c)
			]) {
				if (!uniqueAssetIds.contains(conA.Client_Asset__c)) {
					uniqueAssetIds.add(conA.Client_Asset__c);
					assetsDDV.add(new SelectOption(conA.Client_Asset__c, conA.Client_Asset__r.Name));
				}
			}
		}
		
		if(assetsDDV.size() == 1){
			assetsDDV = null;
		}else if(assetsDDV.size() == 2){
			assetsDDV.remove(0);
		}
	}

	private void populateProjectInformation(){
		
		projectDDV = new List<SelectOption>();
		projectDDV.add(new SelectOption('', 'Please Select'));
		projectIdToCode = new Map<Id,String>();
		
		//Get a full list of Project Information records associated with the Account
		//for(Project_Information__c pi : [select Id, Name from Project_Information__c where Account__c = :newCase.AccountId]){
		for(Project__c pi : [select Id, Name, Project_Code__c from Project__c where Account__c = :newCase.AccountId]){
			projectDDV.add(new SelectOption(pi.Id, pi.Name));
			projectIdToCode.put(pi.Id,pi.Project_Code__c);
		}
		
		if(projectDDV.size() == 1){
			projectDDV = null;
		}else if(projectDDV.size() == 2){
			newCase.Project__c = null;
		}else{
			//newCase.Project_Name__c = null;
			newCase.Project__c = null;
		}
	}
	
	/***************************************************** SELECTION ****************************************************/
	
	public void productSetSelected(){
		//Remove data relating to any previous choice
		newCase.Product_Set__c = null;
		
		newCase.Product_Set_Text__c = null;
		newCase.System__c = null;
		newCase.Client_Asset__c = null;
		newCase.Support_Entitlement__c = null;
		systemsDDV = null;
		assetsDDV = null;
		
		supportAlert = null;
		hasSupportAlert = false;
		
		//Set the record type Id if possible from the custom settings.
		psSettings = new ProductSetToRecordTypeId__c();
		if(productSetChosen != null && productSetChosen != ''){
			if(rtMap.get(productSetChosen.toUpperCase()) != null){
				psSettings = rtMap.get(productSetChosen.toUpperCase());
				//newCase.RecordTypeId = rtMap.get(productSetChosen.toUpperCase()).Record_Type_Id__c;
				//caseRecordTypeName = rtMap.get(productSetChosen.toUpperCase()).Recordtype_Name__c;
				newCase.RecordTypeId = psSettings.Record_Type_Id__c;
			}else{
				newCase.RecordTypeId = generalSettings.get('DEFAULT_CASE_RECORDTYPE_ID').Value__c;
			}
		}
		system.debug('Level1CaseCapturePage2Controller.productSetChosen - psSettings : '+psSettings);
	       	
		//Re-populate systems
		if(productSetChosen != null && productSetChosen != '' && productSetChosen != 'Please Select'){
			populateSystems();
		}
	}
	
	public void systemSelected(){
		//Now we have a System and Product Set Name, so the Id of the Product Set can be set
		if(psNameSysIdToPSId.containsKey(productSetChosen + newCase.System__c)){
			newCase.Product_Set__c = psNameSysIdToPSId.get(productSetChosen + newCase.System__c);
		}else{
			if(psNameToPSIdsMap.containsKey(productSetChosen)){
				List<Id> psIds = new List<Id>();
				psIds.addAll(psNameToPSIdsMap.get(productSetChosen));
				newCase.Product_Set__c = psIds[0];
			}else{
				newCase.Product_Set__c = null;
			}
		}
		newCase.Product_Set_Text__c = productSetChosen;
		
		populateAssets();
		populateEntitlements();
	}
	
	/***********************************************************  SAVE **********************************************************************/
	
	//Custom validation logic
	public boolean validate(){
		boolean returnValue = true;

		validationMessage = '<ul>';
		
		if(newCase.Product_Set__c == null && !isGeneralProductSet){
			returnValue = false;
			validationMessage = validationMessage + '<li>Product Set must be filled in</li>';
		}
		
		if(newCase.System__c == null && !isCaseTypeProject && !isGeneralSystem){
			returnValue = false;
			validationMessage = validationMessage + '<li>System must be filled in</li>';
		}
		
		//if(entitlementsDDV != null && newCase.Misys_Entitlement__c == null && !isCaseTypeProject){
		if(newCase.Support_Entitlement__c == null && !isCaseTypeProject && !isGeneralEntitlement){
			returnValue = false;
			validationMessage = validationMessage + '<li>Entitlement must be filled in</li>';
		}
		
		if(newCase.Severity__c == null){
			returnValue = false;
			validationMessage = validationMessage + '<li>Severity must be filled in</li>';
		}
		
		if(!CurrentSessionInfo.InPortal && newCase.Internal_Severity__c == null){
			returnValue = false;
			validationMessage = validationMessage + '<li>Internal Severity must be filled in</li>';
		}
		
		if(!CurrentSessionInfo.InPortal && newCase.Urgency__c == null){
			returnValue = false;
			validationMessage = validationMessage + '<li>Urgency must be filled in</li>';
		}
		
		if(newCase.Subject == null || newCase.Subject == '' || newCase.Subject.trim() == ''){
			returnValue = false;
			validationMessage = validationMessage + '<li>Subject must be filled in</li>';
		}
		
		if(newCase.Description == null || newCase.Description == '' || newCase.Description.trim() == ''){
			returnValue = false;
			validationMessage = validationMessage + '<li>Description must be filled in</li>';
		}
		
		if(!CurrentSessionInfo.InPortal && newCase.Time_spent_on_issue__c == null && !isCaseTypeProject){
			returnValue = false;
			validationMessage = validationMessage + '<li>Time Spent on Issue must be filled in</li>';
		}
		
		//Product
		if(requireProductFields && newCase.Self_Service_Product__c == null && !isCaseTypeProject){
			returnValue = false;
			validationMessage = validationMessage + '<li>Product must be filled in</li>';
		}
		
		//Product Version
		if(requireProductFields && newCase.Product_Version__c == null && !isCaseTypeProject){
			returnValue = false;
			validationMessage = validationMessage + '<li>Product Version must be filled in</li>';
		}
		
		//System Status
		if(requireProductFields && newCase.System_Status__c == null && !isCaseTypeProject){
			returnValue = false;
			validationMessage = validationMessage + '<li>System Status must be filled in</li>';
		}
		
		//Sophis Category
		if(showSophisFields && newCase.Misys_Sophis_Category__c == null && !isCaseTypeProject){
			returnValue = false;
			validationMessage = validationMessage + '<li>Misys Sophis Category must be filled in</li>';
		}
		
		validationMessage = validationMessage + '</ul>';
		displayValidationMessage = !returnValue;
		//setdisplayValidationMessage(!returnValue);
		
		return returnValue;
	}	
	
	//Save and redirect to the new Case page if successful
	public PageReference SaveOnly(){
		SavePoint sp = Database.setSavePoint();
        try
        {
        	if(saveNewCase()){
        		PageReference pr = new Pagereference('/' + newCase.Id);
        		return pr;
        	}else{
        		return null;
        	}
        }
        catch(DMLException dmle)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'There has been an error: '+dmle));
            Database.rollBack(sp);
            return null;
        }
        catch(Exception exc)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'There has been an error: '+exc));
            Database.rollBack(sp);
            return null;
        }
	}
	
	//Save and redirect to standard attach screen if successful
	public PageReference SaveAndAttach(){
		PageReference pr = SaveOnly();
		if(pr != null){
			return new PageReference('/p/attach/NoteAttach?pid='+newCase.Id+'&parentname=&retURL=%2F'+newCase.Id);
		}else{
			return null;
		}
	}
	
	public PageReference Cancel(){
		if(ApexPages.currentPage().getParameters().get('retURL') != null){
			return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
		}else{
			return new PageReference('/home/home.jsp');
		}
	}
	
	//The logic for actually saving the case. First validate that all the required information is present (note
	//that we don't rely on SFDC enforcing the required fields).
	//Next try to apply a record type based on the Product Set
	//If the user has chosen to use the assignment rules (by default in portal), then set this during the save
	//Finally, if the entitlement that this Case is being saved with is the "Dummy" one, then set a flag to 
	//reflect this.
	//We allow errors to roll up to the calling method, where they are handled.
	public boolean saveNewCase(){
		boolean returnValue = false;
		
		system.debug('Level1CaseCapturePage2Controller.saveNewCase - 1');
        if(validate()){
	       	//Set the record type Id if possible from the custom settings.
	    	if(rtMap.get(productSetChosen.toUpperCase()) != null){
	    	system.debug('Level1CaseCapturePage2Controller.saveNewCase - case to save (1) : '+newCase);
	    	//if(psSettings != null){
	       		newCase.RecordTypeId = rtMap.get(productSetChosen.toUpperCase()).Record_Type_Id__c;
	       		caseRecordTypeName = rtMap.get(productSetChosen.toUpperCase()).Recordtype_Name__c;
	       		//newCase.RecordTypeId = psSettings.Record_Type_Id__c;
	       	}else{
	       		newCase.RecordTypeId = generalSettings.get('DEFAULT_CASE_RECORDTYPE_ID').Value__c;
	       	}
	       	system.debug('Level1CaseCapturePage2Controller.saveNewCase - case to save (2) : '+newCase);
	       	
	       	system.debug('Level1CaseCapturePage2Controller.saveNewCase - 2');
	       	//Set the text values for Product Set, System and Asset
	       	newCase.Product_Set_Text__c = productSetChosen;
	       	
	       	System.debug('XXX Level1CaseCapturePage2Controller: savenewCase: System Id: ' + newCase.System__c);
	       	system.debug('Level1CaseCapturePage2Controller.saveNewCase - case to save (3) : '+newCase);
	       	
	       	system.debug('Level1CaseCapturePage2Controller.saveNewCase - 3');
	       	if(newCase.Client_Asset__c != null && assetsDDV != null){
		       	system.debug('Level1CaseCapturePage2Controller.saveNewCase - assetsDDV : '+ assetsDDV);
		       	for(SelectOption assetDDV : assetsDDV){
		       		system.debug('Level1CaseCapturePage2Controller.saveNewCase - assetDDV(label,value) : '+ assetDDV.getValue() + ',' + assetDDV.getLabel());
		       		if(assetDDV.getValue() != '' && assetDDV.getValue() == newCase.Client_Asset__c){
		       			newCase.Client_Asset_Text__c = assetDDV.getLabel();
		       			break;
		       		}
		       	}
	       	}
	       	system.debug('Level1CaseCapturePage2Controller.saveNewCase - case to save (4) : '+newCase);
	       	
	       	Database.DMLOptions dmlOpt = new Database.DMLOptions();
	       	if(useDefaultAssignmentRules || CurrentSessionInfo.InPortal){
	       	//if(useDefaultAssignmentRules){
                dmlOpt.assignmentRuleHeader.useDefaultRule = true;
                dmlOpt.EmailHeader.triggerUserEmail = true;
	       	}
	       	system.debug('Level1CaseCapturePage2Controller.saveNewCase - dmlOpt.assignmentRuleHeader.useDefaultRule:'+dmlOpt.assignmentRuleHeader.useDefaultRule);
	       	
	       	if(sendEmailToContact || CurrentSessionInfo.InPortal){
	       		dmlOpt.EmailHeader.triggerOtherEmail = true;
	       	}
	       	newCase.setOptions(dmlOpt);
	       	
	       	//Update the Project Code to the case
	       	if(newCase.Project__c != null && projectIdToCode.containsKey(newCase.Project__c)){
	       		newCase.Project_Code__c = projectIdToCode.get(newCase.Project__c);
	       	}
	       	
	       	//Check to see if the case is logged against the dummy entitlement (no entitlement, needs triage)
	       	//if(newCase.Support_Entitlement__c == generalSettings.get('DUMMY_ENTITLEMENT_ID').Value__c){
	       	if(isGeneralEntitlement){
	       		newCase.Logged_Without_Entitlement__c = true;
	       	}
	        	
        	system.debug('Level1CaseCapturePage2Controller.saveNewCase - case to save (5) : '+newCase);
        	insert newCase;
        	
        	if(caseComment.CommentBody != null){
        		caseComment.ParentId = newCase.Id;
        		insert caseComment;
        	}
        	returnValue = true;
        }
        return returnValue;
	}
}