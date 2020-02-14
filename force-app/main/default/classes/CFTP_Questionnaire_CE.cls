public with sharing class CFTP_Questionnaire_CE {
	
	public Boolean isLocked {get; set;}
	public String renderMode {get; set;}
	public String pageMode {get; set;}
	public Boolean QuestionnaireCompleted;
	public Date QuestionnaireDate;
	public string saveOption = '';
	public Partner_Approvals_Renewals__c cftp {get; set;}
	
	//Constructor
	public CFTP_Questionnaire_CE(ApexPages.StandardController stdController){
		//Get the current record
		cftp = (Partner_Approvals_Renewals__c)stdController.getRecord();
		system.debug('cftp= '+cftp);
		
		if(cftp.Internal_Sales_Agency_Completed_Date__c == null)
			cftp.Internal_Sales_Agency_Completed_Date__c = date.today();
		
		//Determine if the current user has access to edit and submit the form. 
		Schema.DescribeFieldResult dfr = Partner_Approvals_Renewals__c.Internal_Sales_Agency_Form_completed__c.getDescribe();
		Boolean userHasAccess = dfr.isUpdateable();
		system.debug('Questionnaire form is updateable: '+userHasAccess);
		
		//Determine if the form should be locked.  If previously entered and submitted for approval, it should be locked from edits 
		if(cftp.Internal_Sales_Agency_Form_completed__c)
		{
			isLocked = true;
			
			//Only allow renderAs PDF when the form is locked
			if(ApexPages.currentPage().getParameters().get('p') != null) {
      			renderMode = 'pdf';
      		} else {
      			renderMode = null;
			}
		}else{
			//If the current user does not have access to update or submit the form, show the locked version at all times
			if(userHasAccess)
			{
				isLocked = false;
			}
			else
			{
				isLocked = true;
			}
			renderMode = null;
		}
	}
	
	public boolean getRequireExplanation()
	{
		if(cftp.Can_you_verify_CFTP_has_no_ties__c == 'No Ties' || cftp.Can_you_verify_CFTP_has_no_ties__c == null)
			return false;
		else
			return true;
	}
	
	public string getUserFullname()
	{
		return Userinfo.getName();
	}
	
	public boolean getIsStepAllowed()
	{
		boolean b = false;
		/*
		if(cftp.Regional_Sales_Director_Approval_Status__c == 'APPROVED' || 
			cftp.Reg_Services_Director_Approval_Status__c == 'APPROVED' || 
			(cftp.Level_of_Risk__c == 'Low' && cftp.Risk_Assessment_Completed_Date__c != null))
		{
			b = true;
		}
		*/
		if(cftp.Level_of_Risk__c != null && cftp.Risk_Assessment_Completed_Date__c != null)
		{
			b = true;
		}
		system.debug('In getIsStepAllowed, b='+b);
		return b;
	}
	
	public boolean getFormAllowed()
	{
		return getIsStepAllowed();
	}
	
	public string getButtonTip()
	{
		string tip;
		if(getIsStepAllowed() == true)
		{
			tip = 'Open the Internal Questionnaire';
		}else{
			tip = 'Available after step 3 is Approved or when Level of Risk is "Low"';
		}
		return tip;
	}

	/*
	public boolean getServicesSectionComplete() 
	{
		boolean isSectionComplete = false;
	
		//All fields in the Services checklist item (#5) must have a value for this section to be complete.	
		if(cftp.Will_CFTP_Assist_with_Visas_and_Permits__c != null &&
			cftp.Will_CFTP_Facilitate_Requested_Meetings__c != null && 
			cftp.Will_CFTP_Provide_Bid_Bonds_Guarantees__c != null && 
			cftp.Will_CFTP_Identify_Prospective_Clients__c != null && 
			cftp.Will_CFTP_Provide_Resources_to_Assist__c != null && 
			cftp.Will_CFTP_Advise_on_Local_Customs__c != null && 
			cftp.Will_CFTP_Facilitate_Local_Support_Svcs__c != null && 
			cftp.Will_CFTP_Provide_Other_Services__c != null)
			{
				isSectionComplete = true;
			} else {
				isSectionComplete = false;
			}
		
		system.debug('isSectionComplete: '+isSectionComplete);
		return isSectionComplete;
	}
	*/

	public string getCheckboxImageA() 
	{
		string path = getCheckboxImage(cftp.Will_CFTP_Assist_with_Visas_and_Permits__c);
		return path;
	}

	public string getCheckboxImageB() 
	{
		string path = getCheckboxImage(cftp.Will_CFTP_Facilitate_Requested_Meetings__c);
		return path;
	}
	
	public string getCheckboxImageC() 
	{
		string path = getCheckboxImage(cftp.Will_CFTP_Provide_Bid_Bonds_Guarantees__c);
		return path;
	}
	
	public string getCheckboxImageD() 
	{
		string path = getCheckboxImage(cftp.Will_CFTP_Identify_Prospective_Clients__c);
		return path;
	}
	
	public string getCheckboxImageE() 
	{
		string path = getCheckboxImage(cftp.Will_CFTP_Provide_Resources_to_Assist__c);
		return path;
	}
	
	public string getCheckboxImageF() 
	{
		string path = getCheckboxImage(cftp.Will_CFTP_Advise_on_Local_Customs__c);
		return path;
	}
	
	public string getCheckboxImageG() 
	{
		string path = getCheckboxImage(cftp.Will_CFTP_Facilitate_Local_Support_Svcs__c);
		return path;
	}
	
	public string getCheckboxImageH() 
	{
		string path = getCheckboxImage(cftp.Will_CFTP_Provide_Other_Services__c);
		return path;
	}		
		
	public string getCheckboxImage(boolean isChecked) 
	{
		string imagePath;
		if(isChecked)
		{
			imagePath = '/img/checkbox_checked.gif';
		} else {
			imagePath = '/img/checkbox_unchecked.gif';
		}
		return imagePath;
	}		

	
	/*
	public boolean verifySignature()
	{
		//The Questionnaire Signature field must equal the current user's name as it is listed in Salesforce to be valid.
		String currentUser = Userinfo.getName();
		String signedName = cftp.Questionnaire_Signature__c;
		system.debug('Current user name / Signed Name: '+currentUser+' / '+signedName);
		
		if(signedName == currentUser)
			return true;
		else
			return false;
	}
	*/

	public boolean getIsQuestionnaireComplete() 
	{
		boolean isComplete = false;
		
		system.debug('getIsQuestionnaireComplete - How did you first hear about the proposed CFTP: '+cftp.How_first_hear_about_proposed_CFTP__c);
		
		//All items must be completed for the Checklist to be considered 'complete'
		if(cftp.How_first_hear_about_proposed_CFTP__c != null && 
			cftp.Can_you_verify_CFTP_has_no_ties__c != null &&
			((getRequireExplanation() == true && cftp.Explain_why_unable_to_verify_no_ties__c != null && cftp.Explain_why_unable_to_verify_no_ties__c != '') || getRequireExplanation() == false) &&
			cftp.Verify_Questionnaire__c != null &&
			cftp.Internal_Sales_Agency_Completed_Date__c != null)
			{
				isComplete = true;
			} else {
				isComplete = false;
			}
				
		system.debug('isComplete: '+isComplete);
		return isComplete;
	}

	public PageReference saveChanges()
	{
		saveOption = 'saveChanges';
		
		PageReference p = saveThisForm();
		return p;
	}
	
	public PageReference saveComplete()
	{
		saveOption = 'saveComplete';
		
		PageReference p = saveThisForm();
		return p;
	}

	public PageReference saveThisForm()
	{
		Boolean bContinue = true;
		Boolean submitSuccess;
		List<String> listRequiredFieldsMissing = new List<String>(); 
		
		//If the user chose to Save the form as Completed, verify all the items are complete.  If not, warn the user.
		if(saveOption == 'saveComplete')
		{
			if(!getIsQuestionnaireComplete())
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.CFTP_QuestionnaireError_Incomplete));
				return null;
			}	
			//Update the field on the Partner Approval record
			cftp.Internal_Sales_Agency_Form_completed__c = true;

		system.debug('cftp 1 = ' + cftp);
		system.debug('cftp.Partner_Role__c = ' + cftp.Partner_Role__c);
		system.debug('cftp.Level_of_Risk__c = ' + cftp.Level_of_Risk__c);
		system.debug('cftp.Partner_Selection_Form_completed__c = ' + cftp.Partner_Selection_Form_completed__c);

			//Verify the fields required for the approval submission have values
			listRequiredFieldsMissing = approvalFieldValidation();
			if(listRequiredFieldsMissing.size() > 0)
			{
				//Alert the user of the missing information
				String msg = Label.CFTP_NotReadyForApprovalSubmission + listRequiredFieldsMissing;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
				
				//Clear the fields that indicate a complete form so this remains available to submit 
				cftp.Internal_Sales_Agency_Form_completed__c = false;
				cftp.Internal_Sales_Agency_Completed_Date__c = null;
				
				bContinue = false;
			}
		}
		else
		{
			//Clear the fields that indicate completion if not marking as complete
			cftp.Internal_Sales_Agency_Completed_Date__c = null;
		}

		//If prior steps failed, stop here and return
		if(bContinue == false)
		{
			return null;
		}
		
		try {
			update cftp;
			//database.Saveresult result = database.update(cftp);
		}catch (Exception e){
			bContinue = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
      		system.debug('Error logged:  '+ e.getMessage());
      		return null;
		}
		
		//Save form as PDF and attach to record if the save was successful
		PageReference p = new PageReference('/apex/CFTP_PDFform');
		p.getParameters().put('id',cftp.Id);
		p.getParameters().put('form','ISQ');

		if(saveOption == 'saveComplete')
		{ 
			saveOption = '';
			//Try to submit the record for approval
			submitSuccess = submitApproval();
			if(submitSuccess == false && !Test.isRunningTest()) {
				p = null;
			}
			return p;
		}
		else if(saveOption == 'saveChanges')
		{
			saveOption = '';
			return p;			
		} 
		else {
			saveOption = '';
			return  backToRecord();
		}

		return p;
	}	
	
	public PageReference backToRecord()
	{
		PageReference p = New PageReference('/'+cftp.Id);
		return p;
	}	
	
	private List<String> approvalFieldValidation()
	{
		Boolean isValidated = true;
		List<String> invalidFields = new List<String>();
		system.debug('cftp = ' + cftp);
		system.debug('cftp.Partner_Role__c = ' + cftp.Partner_Role__c);
		system.debug('cftp.Level_of_Risk__c = ' + cftp.Level_of_Risk__c);
		system.debug('cftp.Partner_Selection_Form_completed__c = ' + cftp.Partner_Selection_Form_completed__c);
		
		//Validate the fields required for approval submission are filled in
		if(cftp.RecordTypeId == Label.RecType_CFTP_ResellerDistrRnwl
			|| cftp.RecordTypeId == Label.RecType_CFTP_JointDeliveryRnwl
			|| cftp.RecordTypeId == Label.RecType_CFTP_SalesAgentRnwl)
		{
			//Check that Partner Role is not null
			if(cftp.Partner_Role__c == null)
			{
				invalidFields.add('Partner Role');
				isValidated = false;
			}	
			//Check that Level of Risk is not null
			if(cftp.Level_of_Risk__c == null)
			{
				invalidFields.add('Level of Risk');
				isValidated = false;
			}	
		}
		else
		{
			//Check that Partner Role is not null
			if(cftp.Partner_Role__c == null)
			{
				invalidFields.add('Partner Role');
				isValidated = false;
			}	
			//Check that Level of Risk is not null
			if(cftp.Level_of_Risk__c == null)
			{
				invalidFields.add('Level of Risk');
				isValidated = false;
			}	
			//Check that Sales Territory & Planning Tool is true
			if(cftp.Partner_Selection_Form_completed__c == false && cftp.RecordTypeId != Label.RecType_CFTP_OneOffPCA)
			{
				invalidFields.add('Sales Territory & Planning Tool');
				isValidated = false;
			}	
		}
		return invalidFields;
	}

	private Boolean submitApproval()
	{
		Boolean success = false;
		
		//Create the Approval Request to be submitted
		Approval.ProcessSubmitRequest approvalreq = new Approval.ProcessSubmitRequest();
		approvalreq.setObjectId(cftp.Id);
		approvalreq.setComments('Submitted for Approval by '+ getUserFullName() +' (Internal Questionnaire Form)');
		system.debug('prepared Approval Request: '+approvalreq);
		
		//Submit the Approval Request
		try{
			Approval.ProcessResult result = Approval.process(approvalreq);
			system.debug('Approval Request result: '+result);
			success = true;
		}
		catch(Exception e)
		{
			String errorMsg = 'Automated submission for approval failed.  Error: '+e;
			String infoMsg = 'You will need to click the Submit for Approval button on the main screen.';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, infoMsg));
			CommonFunctions.CustomException ce = new CommonFunctions.CustomException('Id='+cftp.Id+'. Exception: '+errorMsg);
			CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),'Error Submitting Approval request ','CFTP_Questionnaire_CE.submitApproval()',ce);			
		}
			
		return success;
	}
}