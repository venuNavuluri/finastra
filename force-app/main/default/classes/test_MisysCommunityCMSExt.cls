@isTest
private class test_MisysCommunityCMSExt {
	
	@isTest static void test_method_one() {
		// Implement test code
		 pageReference pr= Page.MisysCommunityCMS;
		 Community_Homepage_CMS__c cms_content = New Community_Homepage_CMS__c();
	     ApexPages.StandardController sc = new ApexPages.standardController(cms_content);
	     MisysCommunityCMS_Extension caseView = New MisysCommunityCMS_Extension(sc);

	     cms_content.Title__c = 'test';
	     cms_content.Body_Copy__c = 'test';
	     cms_content.Page_to_Display__c = 'test';
         
	     Attachment myfile = new Attachment();
	     caseView.getmyfile();
	     caseView.url = 'test';
	     caseView.Save();
        
        cms_content.Active__c = true;
        update cms_content;
	}
	
		
}