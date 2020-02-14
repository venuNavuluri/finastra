public class CFTP_PDFform_CE {

	public static Partner_Approvals_Renewals__c cftp;
	public string SelectedForm = null;
	public string FormName = null;
	
	//Constructor
	public CFTP_PDFform_CE(ApexPages.StandardController stdController)
	{
		//Get the current record
		cftp = (Partner_Approvals_Renewals__c)stdController.getRecord();
		system.debug('cftp= '+cftp);
		
		//SelectedForm = null;
		system.debug('page parameters= '+ApexPages.currentPage().getParameters());
		SelectedForm = ApexPages.currentPage().getParameters().get('form');
	}	
	
	public PageReference getPageRef()
	{
		PageReference page;
		
		if(SelectedForm == 'RA') {
			page = new PageReference('/apex/CFTP_RiskAssessmentForm');
			FormName = 'RiskAssessment';
		}else if (SelectedForm == 'ISQ') {
			page = new PageReference('/apex/CFTP_Questionnaire');
			FormName = 'InternalSalesQuestionnaire';
		}else if (SelectedForm == 'COC') {
			page = new PageReference('/apex/CFTP_Checklist');
			FormName = 'CommOpsChecklist';
		}else
			page = null;
		
		system.debug('PageRef returned: '+page);	
		return page;
	}
	
	public PageReference createPDF() 
	{
		PageReference pageToPDF = getPageRef();
		
		if(pageToPDF != null)
		{
			pageToPDF.getParameters().put('id',cftp.Id);
			pageToPDF.getParameters().put('p','pdf');
			system.debug('Page to PDF URL:'+pageToPDF.getURL());
		}

		String attachId = null;
		//
		//
		//  FIX NAME below
		//
		//
		String attName = FormName+'_'+cftp.Account__r.Name+'_'+Date.today().year()+'-'+Date.today().month()+'-'+Date.today().day()+'.pdf';
		system.debug('Attachment name to insert='+attName);
		
		Attachment pdfAttach = new Attachment();
		pdfAttach.Name = attName;
		pdfAttach.ContentType = 'application/pdf';
		system.debug('thisPage2: '+pageToPDF.getUrl());
		Blob body;
		if (Test.IsRunningTest()) {
			body = Blob.toPdf('UNIT TEST');
		}
		else {
			body = pageToPDF.getContentAsPDF();
		}
		pdfAttach.Body = body;
		pdfAttach.ParentId = cftp.Id;
		
		try
		{
			//attachId = AttachmentTriggerMethods.attachAsPDF(thisPage, cftp.Id, cftp.Id, attName);
			insert pdfAttach;
		}
		catch(Exception e)
		{
			system.debug('Error creating PDF attachment - '+e);
			CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'), 'Error creating PDF attachment for CFTP ('+attName+')', 'PartnerApprovalsRenewalsMethods', e);
		}
		
		PageReference p = backToRecord();
		system.debug('end createPDF p='+p);
		return p;
	}	
	
	public PageReference backToRecord()
	{
		PageReference p = New PageReference('/'+cftp.Id);
		//if(pdfCreated)
		//	p.getParameters().put('cpdf','true');
		return p;
	}		
}