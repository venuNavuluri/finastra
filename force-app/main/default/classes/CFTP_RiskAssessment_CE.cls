public with sharing class CFTP_RiskAssessment_CE {
	
	public boolean isLocked {get;set;}
	public boolean isComplete {get; set;}
	public string CloseButtonCaption {get;set;}
	public string renderMode {get; set;}
	public integer TotalRiskScore;
	public integer CPITerritoryHighValue;
	public integer CPITerritoryMedValue;
	public integer CPITerritoryLowValue;
	public integer CPICountryHighValue;
	public integer CPICountryMedValue;
	public integer CPICountryLowValue;
	public integer SalesAgentApptValue;
	public integer SalesCommOver30Value;
	public string RiskLevel;
	public string NewRiskLevel;
	public Partner_Approvals_Renewals__c cftp; 
	public integer CPITerritoryScore = 0;
	public integer CPICountryScore = 0;
	public List<selectOption> CPITerrScores {get; set;}
	public List<selectOption> CPICntryScores {get; set;}
	public integer constHigh {get;set;}
	public integer constMed {get;set;}
	public integer constLow {get;set;}
	public String completeDate {get; set;}
	public String todayDate;
	
	//Constant definitions
	public static final integer cHigh = 100;
	public static final integer cMed = 50;
	public static final integer cLow = 25;
	
	//Constructor
	public CFTP_RiskAssessment_CE(ApexPages.StandardController stdController){
		//Get the current record
		cftp = (Partner_Approvals_Renewals__c)stdController.getRecord();
		system.debug('cftp= '+cftp);
		
		//Determine if the form should be locked from edits when viewed.
		//if(cftp.Regional_Sales_Director_Approval_Status__c == 'APPROVED' || cftp.Reg_Services_Director_Approval_Status__c == 'APPROVED'
		//	|| cftp.Regional_Sales_Director_Approval_Status__c == 'Pending' || cftp.Reg_Services_Director_Approval_Status__c == 'Pending')
		//{
		//	isLocked = true;
		//}else{
		//	isLocked = false;
		//}
		
		//Determine if the current user has access to edit and submit the form.
		Schema.DescribeFieldResult dfr = Partner_Approvals_Renewals__c.Risk_Assessment_Completed_Date__c.getDescribe();
		Boolean userHasAccess = dfr.isUpdateable();
		system.debug(' Risk Assessment is updateable: '+userHasAccess);
		
		//Determine if the form has been marked as complete.  If so, the form is also locked and no further changes can be made.
		system.debug('RA complete: '+cftp.Risk_Assessment_Completed_Date__c);
		if(cftp.Risk_Assessment_Completed_Date__c != null)
		{			
			isComplete = true;
			isLocked = true;
		}else{
			isComplete = false;
			//If the current user does not have access to update or submit the form, show the locked version at all times
			if(userHasAccess)
			{
				isLocked = false;
			}
			else
			{
				isLocked = true;
			}
		}
		
		if(ApexPages.currentPage().getParameters().get('p') != null) {
      		renderMode = 'pdf';
      		//Optionally, open the attachment instead of the screen form.  To do this, we would have to store the attachment Id on the main record.
      		//URL to open the attachment is below
      		//https://c.cs4.content.force.com/servlet/servlet.FileDownload?file=00PP0000000Xe5o
    	} else {
      		renderMode = null;
      		//asPDF = false;
    	}
    	
    	constHigh = cHigh;
    	constMed = cMed;
    	constLow = cLow;
    
    	buildCPITerrScores();
    	buildCPICntryScores();
	}
	
	public Boolean getIsLocked()
	{
		return isLocked;
	}
	
	public integer getCPITerritoryScore()
	{
		CPITerritoryScore = Integer.valueOf(cftp.CPI_Territory_Score__c);
		if(CPITerritoryScore == null)
			CPITerritoryScore = 0; 
		return CPITerritoryScore;
	}
	
	public void setCPITerritoryScore(integer i)
	{
		cftp.CPI_Territory_Score__c = i;
		CPITerritoryScore = i; 
	}
	
	public void buildCPITerrScores()
	{	
		CPITerrScores = new List<selectOption>();
		CPITerrScores.add(new SelectOption(String.valueOf(cHigh),''));
		CPITerrScores.add(new SelectOption(String.valueOf(cMed),''));
		CPITerrScores.add(new SelectOption(String.valueOf(cLow),''));
	}
	
	public integer getCPICountryScore()
	{
		CPICountryScore = Integer.valueOf(cftp.CPI_Country_Score__c);
		if(CPICountryScore == null)
			CPICountryScore = 0; 
		return CPICountryScore;
	}
	
	public void setCPICountryScore(integer i)
	{
		cftp.CPI_Country_Score__c = i;
		CPICountryScore = i; 
	}
	
	public void buildCPICntryScores()
	{	
		CPICntryScores = new List<selectOption>();
		CPICntryScores.add(new SelectOption(String.valueOf(cHigh),''));
		CPICntryScores.add(new SelectOption(String.valueOf(cMed),''));
		CPICntryScores.add(new SelectOption(String.valueOf(cLow),''));
	}
	
	public Integer getCPITerritoryHighValue()
	{
		integer i = 0;
		//if(cftp.CPI_Territory_100__c == true)
		system.debug('CPICountryScore='+CPICountryScore);
		if(CPITerritoryScore == cHigh)
			i = cHigh;
		system.debug('CPITerritoryHighValue='+i);
		return i;
	}

	public Integer getCPITerritoryMedValue()
	{
		integer i = 0;
		//if(cftp.CPI_Territory_50__c == true)
		system.debug('CPICountryScore='+CPICountryScore);
		if(CPITerritoryScore == cMed)
			i = cMed;
		system.debug('CPITerritoryMedValue='+i);
		return i;
	}
	
	public Integer getCPITerritoryLowValue()
	{
		integer i = 0;
		//if(cftp.CPI_Territory_25__c == true)
		system.debug('CPICountryScore='+CPICountryScore);
		if(CPITerritoryScore == cLow)
			i = cLow;
		system.debug('CPITerritoryLowValue='+i);			
		return i;
	}

	public Integer getCPICountryHighValue()
	{
		integer i = 0;
		//if(cftp.CPI_Country_100__c == true)
		system.debug('CPICountryScore='+CPICountryScore);
		if(CPICountryScore == cHigh)
			i = cHigh;
		system.debug('CPICountryHighValue='+i);	
		return i;
	}
	
	public Integer getCPICountryMedValue()
	{
		integer i = 0;
		//if(cftp.CPI_Country_50__c == true)
		system.debug('CPICountryScore='+CPICountryScore);
		if(CPICountryScore == cMed)
			i = cMed;
		system.debug('CPICountryMedValue='+i);	
		return i;
	}
	
	public Integer getCPICountryLowValue()
	{
		integer i = 0;
		//if(cftp.CPI_Country_25__c == true)
		system.debug('CPICountryScore='+CPICountryScore);
		if(CPICountryScore == cLow)
			i = cLow;
		system.debug('CPICountryLowValue='+i);	
		return i;
	}

	public Integer getSalesAgentApptValue()
	{
		integer i = 0;
		if(cftp.Appt_is_as_Sales_Agent__c == true)
			i = cMed;
		return i;
	}

	public Integer getSalesCommOver30Value()
	{
		integer i = 0;
		if(cftp.Sales_Agent_Comm_High__c == true)
			i = cHigh;
		return i;
	}
	
	public Integer getTotalRiskScore()
	{
		integer iTotalScore = 0;
		integer iTerritoryScore = 0;
		integer iCountryScore = 0;
		integer iAgentScore = 0;
		integer iCommScore = 0;
		
		//Territory CPI
		//iTerritoryScore = math.max(getCPITerritoryHighValue(),getCPITerritoryMedValue());
		iTerritoryScore = getCPITerritoryScore();
		//if(iTerritoryScore == 0)
		//	iTerritoryScore = cLow;
		system.debug('iTerritoryScore = '+iTerritoryScore);
		
		//Country CPI
		//iCountryScore = math.max(getCPICountryHighValue(),getCPICountryMedValue());
		iCountryScore = getCPICountryScore();
		//if(iCountryScore == 0)
		//	iCountryScore = cLow;
		system.debug('iCountryScore = '+iCountryScore);
		
		//Appointment as Sales Agent
		iAgentScore = getSalesAgentApptValue();
		system.debug('iAgentScore = '+iAgentScore);
		
		//Commission over 30%
		iCommScore = getSalesCommOver30Value();
		system.debug('iCommScore = '+iCommScore);
		
		iTotalScore = iTerritoryScore + iCountryScore + iAgentScore + iCommScore;
		system.debug('iTotalScore = '+iTotalScore);
		
		return iTotalScore;
	}
	
	public string getRiskLevel()
	{
		string strLevel = null;
		integer iTotalRiskScore = 0;
		
		iTotalRiskScore = getTotalRiskScore();
		
		if(iTotalRiskScore > 150)
			strLevel = 'Elevated';
		else if(iTotalRiskScore > 99)
			strLevel = 'Standard';
		else if(iTotalRiskScore > 0)
			strLevel = 'Low';
			
		return strLevel;
	}
	
	public string getCheckboxTerritory100() 
	{
		string path = getCheckboxImage(getCPITerritoryScore() == cHigh);
		return path;
	}

	public string getCheckboxTerritory50() 
	{
		string path = getCheckboxImage(getCPITerritoryScore() == cMed);
		return path;
	}
	
	public string getCheckboxTerritory25() 
	{
		string path = getCheckboxImage(getCPITerritoryScore() == cLow);
		return path;
	}
	
	public string getCheckboxCountry100() 
	{
		string path = getCheckboxImage(getCPICountryScore() == cHigh);
		return path;
	}
	
	public string getCheckboxCountry50() 
	{
		string path = getCheckboxImage(getCPICountryScore() == cMed);
		return path;
	}
	
	public string getCheckboxCountry25() 
	{
		string path = getCheckboxImage(getCPICountryScore() == cLow);
		return path;
	}
	
	public string getCheckboxApptAsAgent() 
	{
		string path = getCheckboxImage(cftp.Appt_is_as_Sales_Agent__c);
		return path;
	}
	
	public string getCheckboxSalesAgentComm() 
	{
		string path = getCheckboxImage(cftp.Sales_Agent_Comm_High__c);
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
		system.debug('Checkbox image path: '+imagePath);
		return imagePath;
	} 

	public string getUserFullname()
	{
		return Userinfo.getName();
	}	
	
	public String getTodayDate()
	{
		Date dt = Date.today();
		return dt.format();
	}
	
	public Boolean validateForm()
	{
		//Verify the required fields have valid values
		Boolean isValid = true;
		integer iTerritoryScore = 0;
		integer iCountryScore = 0;
		
		iTerritoryScore = getCPITerritoryScore();
		iCountryScore = getCPICountryScore();
		
		if(iTerritoryScore == 0 || iTerritoryScore == null)
		{	
			isValid = false;
			String errorTerritory = 'A CPI score must be selected for the Territory.';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorTerritory));
		}
		
		if(iCountryScore == 0 || iCountryScore == null)
		{	
			isValid = false;
			String errorCountry = 'A CPI score must be selected for the Country.';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorCountry));
		}
		
		return isValid;
	}	
	
	public List<String> ApprovalFieldValidation()
	{
		Boolean isValidated = true;
		List<String> invalidFields = new List<String>();
		
		//Validate the fields required for approval submission are filled in
		if(cftp.RecordTypeId == Label.RecType_CFTP_JointDeliveryAppt || 
			cftp.RecordTypeId == Label.RecType_CFTP_ResellerDistrAppt || 
			cftp.RecordTypeId == Label.RecType_CFTP_SalesAgentAppt)
		{
			//The fields below only need validation for a Partner Appointment, not a Renewal
			if(cftp.Partner_Selection_Form_completed__c == false)
			{
				invalidFields.add('Sales Territory & Planning Tool');
				isValidated = false;
			}
			if(cftp.Completed_Uploaded_Date__c == null)
			{
				invalidFields.add('Completed / Uploaded Date');
				isValidated = false;
			}	
		}
		
		if(cftp.Contract_Term__c == null)
		{
			invalidFields.add('Contract Term');
			isValidated = false;
		}
		if(cftp.Proposed_Commission__c == null)
		{
			invalidFields.add('Proposed Commission');
			isValidated = false;
		}
		if(cftp.Solution_Coverage__c == null)
		{
			invalidFields.add('Solution Coverage');
			isValidated = false;
		}
		if(cftp.Exclusive_or_not__c == null)
		{
			invalidFields.add('Exclusive or not');
			isValidated = false;
		}
		if(cftp.Risk_Assessment_Completed_Date__c == null)
		{
			invalidFields.add('Risk Assessment Completed Date');
			isValidated = false;
		}
		return invalidFields;
	}
	
	public Boolean submitApproval()
	{
		Boolean success = false;
		
		//Create the Approval Request to be submitted
		Approval.ProcessSubmitRequest approvalreq = new Approval.ProcessSubmitRequest();
		approvalreq.setObjectId(cftp.Id);
		approvalreq.setComments('Submitted for Approval by '+ getUserFullName() +' (Risk Assessment Form)');
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
			CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),'Error Submitting Approval request ','CFTP_RiskAssessment_CE.submitApproval()',ce);			
		}
			
		return success;
	}
	
	public PageReference completeForm()
	{
		PageReference a;
		//Boolean submitApproval = true;
		Boolean submitSuccess;
		List<String> listRequiredFieldsMissing = new List<String>();
		//Verify the form contents
		if(validateForm() == false)
		{
			a = null;
		}
		else
		{
			//Update the completion date for the form 
			cftp.Risk_Assessment_Completed_Date__c = date.today();
			completeDate = cftp.Risk_Assessment_Completed_Date__c.format();
			
			//Update the Level of Risk on the Partner Approval recrod
			cftp.Level_of_Risk__c = getRiskLevel();
			
			//Verify the fields required for the approval submission have values
			listRequiredFieldsMissing = ApprovalFieldValidation();
			if(listRequiredFieldsMissing.size() > 0)
			{
				//Alert the user of the missing information
				String msg = Label.CFTP_NotReadyForApprovalSubmission + listRequiredFieldsMissing;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
				
				//Clear the fields that indicate a complete form so this remains available to submit 
				cftp.Risk_Assessment_Completed_Date__c = null;
				cftp.Level_of_Risk__c = null;
			}
			else 
			{
				//Save the form changes and updates to the CFTP record			
				a = saveThisForm();
			}
			
			//Submit the record for Approval
			if(a != null)
			{	
				submitSuccess = submitApproval();
			}
		}
		if(submitSuccess == false && !Test.isRunningTest())
		{
			a = null;
		}
		return a;
	}
	
	public PageReference saveThisForm()
	{
		Boolean bContinue = true;
		
		//Save the changes
		try {
			update cftp;
		}catch (Exception e){
			bContinue = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
      		system.debug('Error logged:  '+ e.getMessage());
      		return null;
		}
		
		//Save form as PDF and attach to record if the save was successful
		if(bContinue)
		{
			//Set the parameter for the page so it renders properly as a PDF
			//PageReference thisPage = new PageReference('/apex/CFTP_RiskAssessmentForm?p=pdf&compdate='+completeDate);
			PageReference thisPage = Page.CFTP_RiskAssessmentForm;
			thisPage.getParameters().put('p', 'pdf');
			thisPage.getParameters().put('compdate', completeDate);
			
			String attachId = null;
			String attName = 'RiskAssessment_'+cftp.Account__r.Name+'_'+Date.today().year()+'-'+Date.today().month()+'-'+Date.today().day();
			system.debug('Attachment name to insert='+attName);
			
			try
			{
				attachId = AttachmentTriggerMethods.attachAsPDF(thisPage, cftp.Id, cftp.Id, attName);
			}
			catch(Exception e)
			{
				system.debug('Error creating PDF attachment - '+e);
			}
		}
		
		PageReference p = backToRecord();
		return p;
	}
	
	public PageReference backToRecord()
	{
		PageReference p = New PageReference('/'+cftp.Id);
		return p;
	}
	
			//Check criteria for Regional Services & Sales Director Approval Submission flags
			//if(cftp.Contract_Term__c != null
			//	&& cftp.Proposed_Commission__c != null
			//	&& cftp.Solution_Coverage__c != null
			//	&& cftp.Exclusive_or_not__c != null
			//	&& cftp.Risk_Assessment_Completed_Date__c != null)
			//{
			//	if(cftp.RecordTypeId == Label.RecType_CFTP_JointDeliveryAppt 
			//		|| cftp.RecordTypeId == Label.RecType_CFTP_JointDeliveryRnwl)
			//	{
			//		cftp.Regional_Services_Director_Approval__c = true;
			//	}
			//	else if(cftp.RecordTypeId == Label.RecType_CFTP_ResellerDistrAppt
			//		|| cftp.RecordTypeId == Label.RecType_CFTP_ResellerDistrRnwl
			//		|| cftp.RecordTypeId == Label.RecType_CFTP_SalesAgentAppt
			//		|| cftp.RecordTypeId == Label.RecType_CFTP_SalesAgentRnwl)
			//	{
			//		cftp.Regional_Sales_Director_Approval__c = true;
			//	}
			//}	
}