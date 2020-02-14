public with sharing class CFTP_Checklist_CE {

	public Partner_Approvals_Renewals__c cftp; 
	public Boolean isLocked {get; set;}
	public String renderMode {get; set;}
	
	public string saveOption = '';
	
	//Constructor
	public CFTP_Checklist_CE(ApexPages.StandardController stdController){
		//Get the current record
		cftp = (Partner_Approvals_Renewals__c)stdController.getRecord();
		system.debug('cftp= '+cftp);
		
		//Determine if the current user has access to edit and submit the form.
		Schema.DescribeFieldResult dfr = Partner_Approvals_Renewals__c.CommOps_checklist_completed__c.getDescribe();
		Boolean userHasAccess = dfr.isUpdateable();
		system.debug('Comm Ops Checklist is updateable: '+userHasAccess);
		
		//Determine if the form should be locked.  If previously entered and submitted for approval, it should be locked from edits 
		if(cftp.CommOps_checklist_completed__c)
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

	private boolean getIsStepAllowed()
	{
		boolean b = false;
		if(cftp.External_Agent_Letter_Signed__c == true && 
			cftp.External_Agency_Letter_Uploaded_Date__c != null &&
			(cftp.Internal_Sales_Agency_Form_completed__c == true || cftp.Level_of_Risk__c == 'Low') &&
			cftp.Risk_Assessment_Completed_Date__c != null)
		{
			b = true;
		}else{
			b = false;
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
			tip = 'Open the CommOps Checklist';
		}else{
			tip = 'Available after step 5 is completed';
		}
		return tip;
	}

	private boolean getIsChecklistComplete() 
	{
		boolean isComplete = false;
		
		system.debug('getIsCheckListComplete - Names of Partners/Directors provided: '+cftp.Names_of_Partners_Directors_Provided__c);
		
		//All items must be completed for the Checklist to be considered 'complete'
		if(cftp.Names_of_Partners_Directors_Provided__c != null && 
			cftp.Company_Registration_Docs_Provided__c != null &&
			cftp.References_Provided_and_Checked__c != null &&
			cftp.Check_with_Lawyer_on_Addtl_Requirements__c != null &&
			cftp.Questionnaire_for_CFTP_Completed__c != null &&
			cftp.Form_Attached_to_Partner_Letter_Complete__c != null &&
			cftp.Lexis_Check__c != null)
			{
				isComplete = true;
			} else {
				isComplete = false;
			}
				
		system.debug('isComplete: '+isComplete);
		return isComplete;
	}

	public string getUserFullname()
	{
		return Userinfo.getName();
	}

	private List<String> approvalFieldValidation()
	{
		Boolean isValidated = true;
		List<String> invalidFields = new List<String>();
		
		//Validate the fields required for approval submission are filled in
		if(cftp.RecordTypeId == Label.RecType_CFTP_ResellerDistrAppt
			|| cftp.RecordTypeId == Label.RecType_CFTP_ResellerDistrRnwl
			|| cftp.RecordTypeId == Label.RecType_CFTP_SalesAgentAppt
			|| cftp.RecordTypeId == Label.RecType_CFTP_SalesAgentRnwl)
		{
			//Check that Sales Director Approval has occurred
			if(cftp.Regional_Sales_Director_Approval_Status__c == null || cftp.Regional_Sales_Director_Approval_Status__c.toUpperCase() != 'APPROVED')
			{
				invalidFields.add('Regional Sales Director Approval Status');
				isValidated = false;
			}	
		}
		else
		if(cftp.RecordTypeId == Label.RecType_CFTP_JointDeliveryAppt 
			|| cftp.RecordTypeId == Label.RecType_CFTP_JointDeliveryRnwl)
		{
			//Check that Services Director Approval has occurred
			if(cftp.Reg_Services_Director_Approval_Status__c == null || cftp.Reg_Services_Director_Approval_Status__c.toUpperCase() != 'APPROVED')
			{
				invalidFields.add('Reg. Services Director Approval Status');
				isValidated = false;
			}
		}
		if(cftp.External_Agency_Letter_Uploaded_Date__c == null)
		{
			invalidFields.add('External Agency Letter Uploaded Date');
			isValidated = false;
		}
		if(cftp.Due_dilligence_completed_date__c == null)
		{
			invalidFields.add('Due Dilligence Completed Date');
			isValidated = false;
		}
		if(cftp.Lexis_Check__c == null)
		{
			invalidFields.add('Lexis Check');
			isValidated = false;
		}
		system.debug('Internal Sales Agency Completed Date: '+cftp.Internal_Sales_Agency_Completed_Date__c);
		system.debug('Level of Risk: '+cftp.Level_of_Risk__c);
		if(cftp.Internal_Sales_Agency_Completed_Date__c == null && cftp.Level_of_Risk__c != 'Low')
		{
			invalidFields.add('Internal Questionnaire Completed Date');
			isValidated = false;
		}
		if(cftp.Management_Approval_Status__c != null)
		{
			if(cftp.Management_Approval_Status__c.toUpperCase() == 'APPROVED')
			{
				invalidFields.add('Management Approval Status');
				isValidated = false;
			}
		}
		if(cftp.Final_Approval_Status__c != null)
		{
			if(cftp.Final_Approval_Status__c.toUpperCase() == 'REJECTED')
			{
				invalidFields.add('Final Approval Status');
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
		approvalreq.setComments('Submitted for Approval by '+ getUserFullName() +' (CommOps Checklist Form)');
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
			CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),'Error Submitting Approval request ','CFTP_Checklist_CE.submitApproval()',ce);			
		}
			
		return success;
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
		Boolean bFormComplete = false;
		Boolean submitSuccess;
		List<String> listRequiredFieldsMissing = new List<String>(); 
		
		if (cftp.Lexis_Check__c != null && cftp.Lexis_Check_Completed_Date__c == null) {
			cftp.Lexis_Check_Completed_Date__c = Date.today();
			if(getIsChecklistComplete()) {
				//Update the field on the Partner Approval record
				cftp.CommOps_Checklist_completed__c = true;
				cftp.Due_dilligence_completed_date__c = Date.today();
			}
		}
		
		//If the user chose to Save the form as Completed, verify all the items are complete.  If not, warn the user.
		if(saveOption == 'saveComplete')
		{
			if(!getIsChecklistComplete())
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.CFTP_ChecklistError_Incomplete));
				return null;
			}
			bFormComplete = true;
			
			//Verify the fields required for the approval submission have values
			listRequiredFieldsMissing = approvalFieldValidation();
			if(listRequiredFieldsMissing.size() > 0)
			{
				//Alert the user of the missing information
				String msg = Label.CFTP_NotReadyForApprovalSubmission + listRequiredFieldsMissing;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
				
				//Clear the fields that indicate a complete form so this remains available to submit 
				cftp.CommOps_Checklist_completed__c = false;
				cftp.Due_dilligence_completed_date__c = null;
				bFormComplete = false;
				
				bContinue = false;
			}
		}
		
		//If prior steps failed, stop here and return
		if(bContinue == false)
		{
			return null;
		}
		
		try {
			update cftp;
		}catch (Exception e){
			bContinue = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
	     		system.debug('Error logged:  '+ e.getMessage());
	     		return null;
		}
		
		
		PageReference p = getSavePdfPage(cftp.Id);
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

	}	
	
	public PageReference getSavePdfPage(string cftpId)
	{
		PageReference p = new PageReference('/apex/CFTP_PDFform');
		p.getParameters().put('id',cftpId);
		p.getParameters().put('form','COC');
		return p;
	}
	
	public PageReference backToRecord()
	{
		PageReference p = New PageReference('/'+cftp.Id);
		return p;
	}	
}