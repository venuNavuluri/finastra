public class EscalateCaseCtrl
{
	CaseModel2 customerCase;
	public CaseModel2 cm {
		get { return customerCase; }
		private set { customerCase = value; }
	}
	public String AdditionalEscalatedCaseNotes { get; set; }
	public Integer TimeSpentOnIssue { get; set; }

	public EscalateCaseCtrl()
	{
		Id customerCaseId = ApexPages.currentPage().getParameters().get('Id');
		cm = new CaseModel2(customerCaseId);
		checkForErrors();
	}
	
	private boolean checkForErrors()
	{
		//Check if the user is in a correct profile to Escalate to Engineering
		if (!Label.Case_Escalate_To_Engineering.contains(UserInfo.getProfileId())){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Case_User_Profile_Cannot_Escalate_To_Engineering));
			return true;
		}
		if (cm.HasParent() || cm.IsClosed()) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.Cases_with_existing_Parents_and_Closed_Cases_cannot_be_escalated));
			return true;
		}
		if (!cm.StepsToReproduceProvided()) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Required field must be filled in: Steps to Reproduce'));
			return true;
		}
		if (!cm.ProductSetVersionProvided()) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Required field must be filled in: Product Set Version'));
			return true;
		}
		if (!cm.ProductSetModuleVersionProvided()) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Required field must be filled in: Product Set Module Version'));
			return true;
		}
		return false;	 
	}

	public PageReference BackToCase()
	{
		PageReference pr = new PageReference('/'+ cm.getTheCase().id);
		pr.setRedirect(true);
		return pr;
	}

	public PageReference Escalate()
	{
		PageReference pr = Page.EscalatedCaseEdit;
		return pr;
	}
	
	public PageReference CreateEscalatedCase()
	{
//		throw new CommonFunctions.CustomException('Time spent on Case (minutes): You must enter a value: ' + TimeSpentOnIssue);
		SavePoint sp = Database.setSavePoint();
		try
		{
			String id = EscalationUtils.CreateAndInsertEscalatedCase(customerCase.GetTheCase(), AdditionalEscalatedCaseNotes, TimeSpentOnIssue);
			PageReference pr = new PageReference('/'+id);
			system.debug('@@@ escalated case id: ' + id);
			pr.setRedirect(true);
			return pr;
		}
		catch(Exception exc)
		{
			system.debug('@@@ exc: ' + exc);
			system.debug('@@@ stack: ' + exc.getStackTraceString());
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, System.label.General_Error_On_Case+': '+exc));
			Database.rollBack(sp);
			return null;
		}
	}
}