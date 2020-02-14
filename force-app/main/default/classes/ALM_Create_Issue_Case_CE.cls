public class ALM_Create_Issue_Case_CE {

	// The Case being controlled
	public Case customerCase {get;private set;}
	
	public Boolean redirectIssueCase;
	
	// Constructor
	public ALM_Create_Issue_Case_CE (ApexPages.StandardController stdController) {
	    this.customerCase = (Case)stdController.getRecord();
	} // end constructor
		
	// Message indicating error/success conditions
	public String resultMessage {get; private set;}
	public String resultMessageValidFields {get; private set;}
	
	public PageReference createIssueCase() {
		this.redirectIssueCase = false;
		return createIssueCase(true);
	}
	
	public PageReference createIssueCaseNoSync() {
		this.redirectIssueCase = true;
		return createIssueCase(false);
	}
	
	// This method performs the validation and if this is successful, attempts to create the issue case.  Appropriate
	// page references (error or success) are returned. 
	private PageReference createIssueCase(Boolean pSync) {
		
		// Check that the Customer Case is properly selected before creating the Issue Case
		System.debug('Customer Case Id = ' + this.customerCase.Id);
		if (this.customerCase.Id == null) {
			this.resultMessage = 'The Customer case was not properly selected.  Return to the Customer Case and try again.';
			this.resultMessageValidFields = Label.Invalid_Values + ' Case Id';
			return null;
		} // end check for valid Customer Case Id
		
		// Check whether there is already an associated issue case
		System.debug('Issue case value = ' + this.customerCase.Issue_Case__c);
		if (this.customerCase.Issue_Case__c != null) {
			this.resultMessage = Label.already_issue_case;
			return null;
		} // end check for existing issue case
		
		// Query back all fields for creating the issue case.  Mandatory fields are defined in another sys param
		// that must be a subset of the total fields for moving over
		String caseMapFields = ALM_System_Parameters.getParam('Case_Map_Fields');
		
		// Query back these fields from SFDC
		String caseQuery = 'Select recordType.name, account.name, casenumber, priority, severity__c, ' + caseMapFields + ' From Case Where Id = \'' + this.customerCase.Id + '\' Limit 1';
		System.debug(caseQuery);
		SObject sourceCase = Database.query(caseQuery);
		System.debug(sourceCase);
		
		// Get the field names from the list in sys params into an array for processing.  These are those marked
		// as mandatory only
		String mandatoryFields = ALM_System_Parameters.getParam('Mandatory_Fields');
		List<String> sourceFields = mandatoryFields.split(',');

		// Get the map of case object fields
		Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Case.fields.getMap();

		// Loop through the fields.  If we find a null value (error condition) then set a flag.
		// Store the names and values for subsequent error display
		Boolean foundNull           = false;
		Boolean foundInvalidValue   = false; // AC - used to determine valid values for a given field
		String newPriority = '';
		
		for (String sourceField : sourceFields) { 
			
			// Get rid of spaces front and back.  The get does not do this for us.
			String trimSourceField = sourceField.trim();
			system.debug('ALM_Create_Issue_Case_CE.CreateIssueCase - 1 - trimSourceField : ' + trimSourceField + ' : ' + (String)sourceCase.get(trimSourceField));

			//As a special condition, derive the Severity from the Priority
			//if(trimSourceField == 'Severity__c' && (String)sourceCase.get('Severity__c') == '' && sourceCase.get('Priority') != null){
			//	String thisSeverity = CaseServices.getSeverityForPriority((String)sourceCase.get('Priority'));
			//	sourceCase.put(trimSourceField,thisSeverity);
			//}
			//system.debug('ALM_Create_Issue_Case_CE.CreateIssueCase - 2 - trimSourceField : ' + trimSourceField + ' : ' + (String)sourceCase.get(trimSourceField));

			if (sourceCase.get(trimSourceField) == null) { 
				foundNull = true;
				if (this.resultMessage == null) this.resultMessage = Label.null_fields;
				//if(trimSourceField == 'Severity__c'){
				//	this.resultMessage += 'Priority,';
				//}else{
					this.resultMessage += fieldMap.get(trimSourceField).getDescribe().getLabel() + ',';
				//}
			} // end null check if
			system.debug('ALM_Create_Issue_Case_CE.CreateIssueCase - 3 - trimSourceField : ' + trimSourceField + ' : ' + (String)sourceCase.get(trimSourceField));
			system.debug('ALM_Create_Issue_Case_CE.CreateIssueCase - 3 - resultMessage: ' + this.resultMessage);

            // AC 6/17/09 - added this section to validate for specific values in one of the fields
            //              use Valid_Values_<field name> system parameter to enable this for a field.
            
            String validValues = ALM_System_Parameters.getParam('Valid_Values_' + trimSourceField);		
		     
		    boolean foundValidValue=false;
	        if (validValues != null) { 
				for (String validValue : validValues.split(',')) {
				  if (validValue == (String)sourceCase.get(trimSourceField)) {
				  	foundValidValue = true;
				  }  	
				}
				if (!foundValidValue) {
				  if (this.resultMessageValidFields == null) this.resultMessageValidFields = Label.Invalid_Values;
				  this.resultMessageValidFields += ' - ' + fieldMap.get(trimSourceField).getDescribe().getLabel() + ' must be one of ' + validValues;
				}
		    } else {
			    foundValidValue = true;	
			}
			system.debug('ALM_Create_Issue_Case_CE.CreateIssueCase - 4 - trimSourceField : ' + trimSourceField + ' : ' + (String)sourceCase.get(trimSourceField));
			system.debug('ALM_Create_Issue_Case_CE.CreateIssueCase - 4 - resultMessage: ' + this.resultMessage);
			  
			if (!foundValidValue) {
			  	foundInvalidValue = true;
			}

            // END OF VALID VALUES SECTION 
		
		} // end loop through mandatory fields
		
		// If any field was null then display an error
		if (foundNull || foundInvalidValue) {
			if (this.resultMessage != null && this.resultMessage.endsWith(',')) this.resultMessage = this.resultMessage.substring(0,this.resultMessage.length() -1);
			return null;
		}
		
		// Need to add in the issue case record type
		List<RecordType> issueCaseRecTypes = [Select Id From RecordType Where SobjectType = 'Case' And Name = 'Issue' Limit 1];
		if (issueCaseRecTypes.size() == 0) {
			resultMessage = Label.no_issue_case_rec_type;
			return null;
		} // end record type exists check if
		
		// Attempt to create the Issue Case
		SObject issueCase = new Case();
		
		// Add in the record type
		issueCase.put('RecordTypeId',issueCaseRecTypes.get(0).Id);
		System.debug('Record type added' + issueCaseRecTypes.get(0).Id);
		
        Case sourceCaseAsCase = (Case)sourceCase;
		issueCase.put('Customer_Case_Record_Type__c', sourceCaseAsCase.recordType.name);

		// SS: 05-Nov-2009 - Adding Customer Case Account's Name to the Custom field on Issue Case
		issueCase.put('Customer_Name__c', sourceCaseAsCase.account.name);

		// JRB: 01-Dec-2010 - Adding Customer Case Number to the Custom field on Issue Case  (SDP# C3452)
		issueCase.put('Customer_Case_Number__c', sourceCaseAsCase.casenumber);

		// Loop through the fields required for issue case creation
		// and move them across
		List<String> copyFields = caseMapFields.split(',');
		for (String copyField : copyFields) {
			String trimCopyField = copyField.trim();
			System.debug('Adding field ' + trimCopyField);
			if (sourceCase.get(trimCopyField) != null) {
				issueCase.put(trimCopyField,sourceCase.get(trimCopyField));
				System.debug('Added field, value = ' + sourceCase.get(trimCopyField));
			} // end check null value if
			else {
				System.debug('Null value so not adding');
			} // end check null value else
		} // end loop through the fields for copying across
		
		//Get in the string of default field values (e.g a=val1,b=val2)
		String issueCaseDefaults = ALM_System_Parameters.getParam('Issue_Case_Defaults');
		List<String> nameValuePairs = issueCaseDefaults.split(',');
		
		// Loop through the name value pairs and set the values
		for (String nameValuePair : nameValuePairs){
			List<String> separate = nameValuePair.split('=');
			
			// For the sync param, include depending on our param
			if (separate.get(0) == 'CSFE_Sync_Result__c') {
				if (pSync) {
					issueCase.put(separate.get(0),separate.get(1));
				}
			}
			else {
				issueCase.put(separate.get(0),separate.get(1));
			}			
		} // end loop through the name value pairs

		// JRB 23-Aug-2012 - Set the Priority on the Case based on Severity (no longer using Priority on the customer case)
		String caseSeverity = sourceCaseAsCase.Severity__c;
		system.debug('ALM_Create_Issue_Case_CE.CreateIssueCase - 5 - orignial cust case severity = '+ caseSeverity);
		newPriority = CaseServices.getPriorityFromSeverity(caseSeverity);
		system.debug('ALM_Create_Issue_Case_CE.CreateIssueCase - 5 - using severity to get Priority = '+newPriority);
		issueCase.put('Priority',newPriority);
		issueCase.put('Severity__c', caseSeverity);

		System.debug('ALM_Create_Issue_Case_CE.CreateIssueCase - 6 - issue case = ' + issueCase);
		
		// Create the issue case
		Database.SaveResult insertResult;
		try {
			System.debug('Inserting issue case');
			insertResult = Database.insert(issueCase);
			System.debug('No error returned');
		} // end insert case try
		catch (Exception e) {
			this.resultMessage = Label.case_create_error + e.getMessage() + ' ' + insertResult.getErrors();
			System.debug('Exception message = ' + this.resultMessage);
			return null;
		} // end insert case catch
		
		// Link the current controlled customer case to this new issue case
		this.customerCase.Issue_Case__c = issueCase.Id;

		Database.SaveResult updateResult;
		try {
			updateResult = Database.update(this.customerCase);
		} // end update try
		catch (Exception e) {
			this.resultMessage = Label.case_update_error + e.getMessage() + ' ' + updateResult.getErrors();
			return null;		
		} // end update catch
		
		this.resultMessage = Label.successful_create;
		return null;
	} // end createIssueCase
	
	// ok action returns to the controlling case
	public PageReference ok() {
		if ((this.redirectIssueCase) && (this.customerCase.Issue_Case__c != null)) {
			//AC 8/6/09 - Saaspoint Ref:30 - go to edit mode once created
			//return new PageReference('/' + this.customerCase.Issue_Case__c + '/e?retURL=%2F' + this.customerCase.Issue_Case__c);
			//AC 8/7/09 - not required for Banking
			return new PageReference('/' + this.customerCase.Issue_Case__c );
		}
		if(this.CustomerCase.Id != null){
			return new PageReference('/' + this.customerCase.Id);
		}else{
			return new PageReference('/500/o');
		}
	} // end ok action
} // end ALM_Create_Issue_Case_CE