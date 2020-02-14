@isTest
private class ALM_Create_Issue_Case_CE_Test {
/*
  private static testMethod void ALM_Create_Issue_Case_CE_Test1_Mandatory_Fields() {

      // Delete and recreate system parameters to ensure that this test method always behaves as expected, regardless of underlying environment settings
	  PrepareSystemParameters();

      // Create a customer case to test
      Case cc = new Case();
      cc.case_category__c = 'Defect';
      insert cc;
     	
      Test.setCurrentPage(Page.ALM_Create_Issue_Case_No_Sync);
      ALM_Create_Issue_Case_CE controller = new ALM_Create_Issue_Case_CE(new ApexPages.StandardController(cc));

      // repl steps are mandatory, so should not get Case Created Successfully message
      PageReference p = controller.createIssueCaseNoSync();
      System.assertEquals(null, p);        	
  	  System.assertNotEquals(Label.successful_create ,controller.resultMessage);
  	  System.assertEquals(null, controller.resultMessageValidFields);
  	   	  
  	  cc.replication_steps__c = 'TEST REPL STEPS';
  	  update cc;
  	  
  	  // repl steps now added to cc, so should be successful
      controller = new ALM_Create_Issue_Case_CE(new ApexPages.StandardController(cc));
      p = controller.createIssueCase();
      System.assertEquals(null, p);        	
  	  System.assertEquals(Label.successful_create ,controller.resultMessage);
  	  System.assertEquals(null, controller.resultMessageValidFields);  	  

      // if successful, then should redirect to customer case as we did a 'sync'
      PageReference p2 = controller.ok();
      System.assert(p2.getURL().indexOf(cc.id) > -1);

  } */

  private static testMethod void ALM_Create_Issue_Case_CE_Test2_Valid_Values() {

      // Delete and recreate system parameters to ensure that this test method always behaves as expected, regardless of underlying environment settings
	  PrepareSystemParameters();

      // Create a customer case to test with invalid case category value
      Case cc = new Case(case_category__c = 'INVALID CASE CATEGORY', Severity__c = '2 - High', Replication_steps__c = 'TEST REPL STEPS');
      insert cc;
     	
      Test.setCurrentPage(Page.ALM_Create_Issue_Case_No_Sync);
      ALM_Create_Issue_Case_CE controller = new ALM_Create_Issue_Case_CE(new ApexPages.StandardController(cc));
  
      controller = new ALM_Create_Issue_Case_CE(new ApexPages.StandardController(cc));
      PageReference p = controller.createIssueCaseNoSync();
      System.assertEquals(null, p);        	
	  system.debug('cust case:' + cc);
	  system.debug('resultMessageValidFields: '+controller.resultMessageValidFields);
  	  System.assertNotEquals(null, controller.resultMessageValidFields);  	  

      // now set CC to have valid value and should be successful
      cc.case_category__c = 'Defect';
      update cc;
      
      controller = new ALM_Create_Issue_Case_CE(new ApexPages.StandardController(cc));
      p = controller.createIssueCaseNoSync();
      System.assertEquals(null, p);        	
  	  System.assertEquals(Label.successful_create ,controller.resultMessage);
  	  System.assertEquals(null, controller.resultMessageValidFields);  	  

      // if successful, read back the customer case's issue case
      cc = [SELECT issue_Case__c FROM case WHERE id = :cc.id];
      System.assertNotEquals(null, cc.issue_Case__c);
      
      // Verify the issue case has correct values
      Case ic = [SELECT Id, Priority from Case where id = :cc.issue_Case__c];
      system.assertEquals('High',ic.Priority);
      
      PageReference p2 = controller.ok();
      System.assert(p2.getURL().indexOf(cc.issue_case__c) > -1);
      
      // Check what happens with an existing issue case - should be unsuccessful
      controller = new ALM_Create_Issue_Case_CE(new ApexPages.StandardController(cc));
      p = controller.createIssueCase();
      System.assertEquals(null, p );
      System.assertEquals(Label.already_issue_case, controller.resultMessage);
      
  }  
  
  public static void PrepareSystemParameters()
  {
      // Delete and recreate system parameters to ensure that this test method always behaves as expected, regardless of underlying environment settings

      List<System_Parameter__c> almParams = [SELECT id FROM System_Parameter__c];
      delete almParams;
      
      List<System_Parameter__c> newALMParams = new List<System_Parameter__c>();
      System_Parameter__c alm1 = new System_Parameter__c(name='CURRENT_SYSTEM', value__c='Banking', applicable_Server__c = 'All');
      //insert alm1;
      newALMParams.add(alm1);

      System_Parameter__c alm2 = new System_Parameter__c(name='Case_Map_Fields', value__c='Subject,Replication_steps__c,Case_Category__c', applicable_Server__c = 'Banking');
      //insert alm2;
      newALMParams.add(alm2);

      System_Parameter__c alm3 = new System_Parameter__c(name='Mandatory_Fields', value__c='Replication_steps__c,Case_Category__c,Severity__c', applicable_Server__c = 'Banking');
      //insert alm3;
      newALMParams.add(alm3);
      
      System_Parameter__c alm5 = new System_Parameter__c(name='Issue_Case_Defaults', value__c='Subject=The Subject', applicable_Server__c = 'Banking');
      //insert alm5;
      newALMParams.add(alm5);

	  System_Parameter__c alm6 = new System_Parameter__c(name='Valid_Values_Case_Category__c', value__c='Defect', applicable_Server__c = 'Banking');
      //insert alm6;
      newALMParams.add(alm6);

	  System_Parameter__c alm7 = new System_Parameter__c(name='Valid_Values_Status', value__c='In Progress', applicable_Server__c = 'Banking');
      //insert alm7;
      newALMParams.add(alm7);
      
      System_Parameter__c alm8 = new System_Parameter__c(name='Valid_Values_Sub-Status', value__c='Development', applicable_Server__c = 'Banking');
      //insert alm8;
      newALMParams.add(alm8);

	  System_Parameter__c alm9 = new System_Parameter__c(name='Valid_Values_Self_Service_Product__c', 
	  	value__c='ALM Banking Test A,ALM Banking Test B,ALM Banking Test C,BM+,Misys Trade Portal,MCR (Midas Credit Risk),' +
	  	'Misys Trader,Loan Manager,ToF,Equation,EBA,Global Cash Pooling,Midas,Midas Plus,MHUBi,IFM (Integrated Financial Management),'+
	  	'Trade Innovation,TI PLUS,Meridian,Meridian Replication,Misys Payment Manager,Misys Message Manager,BM - LAN,BM - LAN BPW,' +
	  	'BM - LAN - FONTIS,BM - LAN - TPP - CityDealer,BM - LAN - TPP - Datastore,BM - LAN - TPP - IBSnet,BM - LAN - TPP - MyEureka,' +
	  	'BM - LAN - TPP - NRS,BM - LAN - TPP - SigCap,BM - LAN - TPP - Testkey,Summit,Loan IQ,DataNet,Trader Desktop,Eagleye,Risk IQ,' + 
	  	'Opics Risk,Risk Vision,CMS,Misys Loan Coordinator,Almonde,Misys Incentives and Rebates,Misys Environment Registry System,' +
	  	'Misys Environmental Trading Platform,Misys Connect Portal,MBI,Bankfusion UB Application,Misys Cash Portal,Opics,Tropics', 
	  	applicable_Server__c = 'Banking');
	  //insert alm9;
	  newALMParams.add(alm9);
	  
	  insert newALMParams;  	
  }

}