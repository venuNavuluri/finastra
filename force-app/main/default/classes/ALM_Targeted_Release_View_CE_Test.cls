@isTest
private with sharing class ALM_Targeted_Release_View_CE_Test {

	private static testMethod void test() {

		//Set up the test data
		Case ic = TestUtility.sampleIssueCase();
		insert ic;
      
      	Targeted_Release__c tr = new Targeted_Release__c(name='Test 1',case__c=ic.id);
      	insert tr;
      
      	Targeted_Release__c tr2 = new Targeted_Release__c(name='Test 1',case__c=ic.id);
      	insert tr2;

      	Case cc = new Case(issue_case__c = ic.id, targeted_release_lookup__c = tr2.id);
      	insert cc;
      
      	tr2.customer_case__c = cc.id;
      	update tr2;
      
      	//Perform the test by updating data
      	Test.startTest();
      	Test.setCurrentPage(Page.ALM_Targeted_Release_View);
      	ALM_Targeted_Release_View_CE controller = new ALM_Targeted_Release_View_CE(new ApexPages.StandardController(cc));
  
      	//System.assertEquals(3, controller.targetedReleases.size());
     
      	controller.targetedReleases[0].selected = false;
      	controller.targetedReleases[1].selected = true;
      
      	PageReference p = controller.enableSave();
      	p = controller.doSave();
      	Test.stopTest();
      
      	//Verify the results
      	// Did the customer case get updated with the correct targeted release?
      	//cc = [SELECT targeted_release_lookup__c FROM case WHERE id = :cc.id];
      	System.assertEquals(tr2.id, cc.targeted_release_lookup__c);      
	      
    	p = controller.doCancel();
        
  	}

}