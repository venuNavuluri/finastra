@isTest
private with sharing class CaseTriggerMethods_Test{

    ///////////////////////////////////////////////////////////////////
    // testCreateCaseCommentForCommentary
    ///////////////////////////////////////////////////////////////////
    /* // integration user inactive - not used anymore
  static testMethod void testCreateCaseCommentForCommentary()
  {
    DontCallFutureMethodFromTestMethod.setIsTestMethod();
    Case ic = new Case(SFDC_CSFE_Commentary__c = 'Test Commentary 1');
    insert ic;
    SFDC_CSFE_Controller.CSFECommentaryRunning = false;

    ic.sfdc_csfe_commentary__c = 'Test Commentary 2';
        
    User u = [SELECT id, firstname, lastname FROM user WHERE id = :label.ALM_Integration_User_ID];
    System.runAs(u) {
      Test.startTest();
      update ic;
      Test.stopTest();
    }
    
    ic = [SELECT sfdc_csfe_commentary__c FROM case WHERE id = :ic.id];
    System.assertEquals(null, ic.sfdc_csfe_commentary__c );
    
    List<CaseComment> ccList = [SELECT CommentBody FROM caseComment WHERE parentID = :ic.id];
    System.assertEquals(2, ccList.size());
    //System.assertEquals('Test Commentary 1', ccList[0].commentBody);
    //System.assertEquals('Test Commentary 2', ccList[1].commentBody);
    
   }
*/
    static void doNothing(){

    }

    ///////////////////////////////////////////////////////////////////
    // testCreateCaseCommentForCommentaryInsert
    ///////////////////////////////////////////////////////////////////
  /* // integration user inactive - not used anymore
  static testMethod void testCreateCaseCommentForCommentaryInsert()
  {
    DontCallFutureMethodFromTestMethod.setIsTestMethod();
    Case ic = new Case(SFDC_CSFE_Commentary__c = 'Test Commentary 1');
    SFDC_CSFE_Controller.CSFECommentaryRunning = false;

    User u = [SELECT id, firstname, lastname FROM user WHERE id = :label.ALM_Integration_User_ID];
    System.runAs(u) {
      Test.startTest();
      doNothing(); // enforces the correct context on startTest, otherwise standard trigger context used (no good for the @future methods called on the stopTest)
      insert ic;
      SFDC_CSFE_Controller.CSFECommentaryRunning = false;
      Test.stopTest();
    }
    
    ic = [SELECT sfdc_csfe_commentary__c FROM case WHERE id = :ic.id];
    System.assertEquals(null, ic.sfdc_csfe_commentary__c );
    
    List<CaseComment> ccList = [SELECT CommentBody FROM caseComment WHERE parentID = :ic.id];
    System.assertEquals(1, ccList.size());
    System.assertEquals('Test Commentary 1', ccList[0].commentBody);
    
   }
*/

    ///////////////////////////////////////////////////////////////////
    // testALMFieldUpdates
    ///////////////////////////////////////////////////////////////////
  /* // integration user inactive - not used anymore
    static testMethod void testALMFieldUpdates() {
    DontCallFutureMethodFromTestMethod.setIsTestMethod();
      Case ic = new Case(CSFE_Sync_Result__c='TEST', CSFE_Priority_Severity__c = 'PRSEV1', CSFE_Product__c='PR1', CSFE_Product_Version__c='PV1');

      // Run as the integration user
      User u = [SELECT id, firstname, lastname FROM user WHERE id = :label.ALM_Integration_User_ID];
      System.runAs(u) {
        insert ic;
      }
      ic = [SELECT priority, severity__c, self_service_product__c, product_version__c, created_by_name__c, CSFE_Transaction_Type__c FROM case WHERE id = :ic.id];

      // Test that the real fields are updated correctly on insert from CSFE
      System.assertEquals('PRSEV1',                       ic.priority);      
      System.assertEquals('PR1',                          ic.self_service_product__c);
      System.assertEquals('PV1',                          ic.product_version__c);
      System.assertEquals(u.firstname + ' ' + u.lastname, ic.created_by_name__c);      
      System.assertEquals('Insert',                       ic.CSFE_Transaction_Type__c);
                
      // Test that the CSFE fields are updated correctly on update 
      ic.priority         = 'PRSEV2';			//JRB Comment out this line after go-live
      ic.severity__c         = 'PRSEV2';
      ic.self_service_product__c = 'PR2';
      ic.product_version__c = 'PV2';
      
      SFDC_CSFE_Controller.CSFEtransactionUpdateRunning = false;
      update ic;
      
      ic = [SELECT CSFE_Priority_Severity__c, CSFE_Product__c, CSFE_Product_Version__c, CSFE_Transaction_Type__c FROM case WHERE id = :ic.id];

      System.assertEquals('PRSEV2',                       ic.CSFE_Priority_Severity__c);      
      System.assertEquals('PR2',                          ic.CSFE_Product__c);
      System.assertEquals('PV2',                          ic.CSFE_Product_Version__c);
      System.assertEquals('Update',                       ic.CSFE_Transaction_Type__c);
        
      // Test that the Real fields are updated on UPDATE
      ic.CSFE_Priority_Severity__c         = 'PRSEV3';
      ic.CSFE_Product__c                   = 'PR3';
      ic.CSFE_Product_Version__c           = 'PV3';
      
      SFDC_CSFE_Controller.CSFEtransactionUpdateRunning = false;
      update ic;
      
      ic = [SELECT priority, self_service_product__c, product_version__c, CSFE_Transaction_Type__c FROM case WHERE id = :ic.id];

      System.assertEquals('PRSEV3',                       ic.priority);      
      System.assertEquals('PR3',                          ic.self_service_product__c);
      System.assertEquals('PV3',                          ic.product_version__c);
      System.assertEquals('Update',                       ic.CSFE_Transaction_Type__c);

      SFDC_CSFE_Controller.CSFEtransactionUpdateRunning = false;
      ic = new Case(CSFE_Sync_Result__c='TEST', severity__c = 'PRSEV4', priority = 'PRSEV4', self_service_product__c = 'PR4', product_version__c = 'PV4');
      insert ic;

      ic = [SELECT CSFE_Priority_Severity__c, CSFE_Product__c, CSFE_Product_Version__c,CSFE_Transaction_Type__c FROM case WHERE id = :ic.id];

      System.assertEquals('PRSEV4',                       ic.CSFE_Priority_Severity__c);      
      System.assertEquals('PR4',                          ic.CSFE_Product__c);
      System.assertEquals('PV4',                          ic.CSFE_Product_Version__c);
      System.assertEquals('Insert',                       ic.CSFE_Transaction_Type__c);
        
    }
*/

    static testMethod void testALMCustomerCaseLinkageSFDC(){
        DontCallFutureMethodFromTestMethod.setIsTestMethod();
        List<Case> listOfCustomerCases = new List<Case>();
        Integer batchSize = 50;

        for(Integer i = 0; i < batchSize; i++){
            listOfCustomerCases.add(new Case(subject = 'TESTFORTESTMETHOD2009'));
        }
        insert listOfCustomerCases;

        Map<String, ID> caseNumberToID = new Map<String, ID>();
        listOfCustomerCases = [SELECT id, caseNumber FROM case WHERE subject = 'TESTFORTESTMETHOD2009' AND createdDate = TODAY];
        System.assertEquals(batchSize, listOfCustomerCases.size());

        for(Case c : listOfCustomerCases){
            SYSTEM.DEBUG('AC 10/27 ' + c.caseNumber.trim() + ' ' + c.id);
            caseNumberToID.put(c.caseNumber.trim(), c.id);
        }

        List<ALM_External_Customer_Case__c> almList = new List<ALM_External_Customer_Case__c>();
        for(Integer i = 0; i < 10; i++){
            almList.add(new ALM_External_Customer_Case__c(external_id_source__c = 'GEM', internal_customer_case_id__c = listOfCustomerCases[i].caseNumber));
        }
        for(Integer i = 10; i < 20; i++){
            almList.add(new ALM_External_Customer_Case__c(external_id_source__c = 'SIN', internal_customer_case_id__c = listOfCustomerCases[i].caseNumber));
        }
        for(Integer i = 20; i < 30; i++){
            almList.add(new ALM_External_Customer_Case__c(external_id_source__c = 'QNT', internal_customer_case_id__c = listOfCustomerCases[i].caseNumber));
        }
        for(Integer i = 30; i < 40; i++){
            almList.add(new ALM_External_Customer_Case__c(external_id_source__c = 'BUG', internal_customer_case_id__c = listOfCustomerCases[i].caseNumber));
        }
        for(Integer i = 40; i < batchSize; i++){
            almList.add(new ALM_External_Customer_Case__c(external_id_source__c = 'SFD', internal_customer_case_id__c = listOfCustomerCases[i].caseNumber));
        }

        Map<Id, Case> cases = new Map<Id, Case>();

        Case c = [SELECT id, GEMS_Number__c FROM case limit 1];
        c.GEMS_Number__c = almList[0].internal_customer_case_ID__c;
        cases.put(c.Id, c);

        Case c2 = [SELECT id, Bugzilla_Reference__c FROM case limit 1];
        c2.Bugzilla_Reference__c = almList[30].internal_customer_case_ID__c;
        cases.put(c2.Id, c2);

        Case c3 = [SELECT id, Quintus_Id__c FROM case limit 1];
        c3.Quintus_Id__c = almList[20].internal_customer_case_ID__c;
        cases.put(c3.Id, c3);

        update cases.values();
        //  Case c1 = [SELECT id, SINS_Number1__c FROM case limit 1];
        //  c1.SINS_Number1__c  = almList[10].internal_customer_case_ID__c;
        //  update c1;

        insert almList;
        almList = [SELECT id, internal_customer_case_id__c, customer_case__c FROM alm_external_customer_case__c
            WHERE external_id_source__c = 'SFD' AND createdDate = TODAY AND createdByID = :userInfo.getUserID()
            ORDER BY createdDate DESC LIMIT 50];

        for(ALM_External_Customer_Case__c alm : almList){
            String caseID = caseNumberToID.get(alm.internal_customer_case_id__c.trim());
            System.assertNotEquals(null, caseID);
            System.assertNotEquals(null, alm.customer_case__c);
            System.assertEquals(alm.customer_case__c, caseID);
        }

    }


    ///////////////////////////////////////////////////////////////////
    // testOffsetsOnly
    ///////////////////////////////////////////////////////////////////
  /* // integration user inactive - not used anymore
    static testMethod void testOffsetsOnly() {
    DontCallFutureMethodFromTestMethod.setIsTestMethod();
      Integer batchSize = 5;
      List<ALM_External_Count_Offset__c> almList  = new List<ALM_External_Count_Offset__c>();
      List<Case>                         caseList = new List<Case>();
      
      for (Integer i = 0; i<batchSize ; i++) {
        ALM_External_Count_Offset__c alm = new ALM_External_Count_Offset__c(external_id__c         = 'ABCTEST' + i, 
                                                                            external_id_source__c  = 'ABC', 
                                                                            client_count_offset__c = 1000 + i, 
                                                                            call_count_offset__c   = 2000 + i);
        almList.add(alm);
        
        Case c = new Case(recordTypeID = label.issue_case_id, external_id__c = 'ABCTEST' + i, external_id_source__c = 'ABC');
        caseList.add(c); 
      }
      insert almList;
      
      User u = [SELECT id FROM user WHERE id = :label.ALM_Integration_User_ID];
      System.runAs(u) {
        
        Test.startTest();
        insert caseList;
        Test.stopTest();
        
        Integer counter = 0;      
        for (Case loopCase : [SELECT id, caseNumber, customer_count_offset__c, case_count_offset__c FROM case WHERE external_id_source__c = 'ABC' AND external_id__c LIKE 'ABCTEST%' AND createdDate = TODAY ORDER BY caseNumber ASC]) {
          System.assertEquals(loopCase.customer_count_offset__c,   1000+counter);   
          System.assertEquals(loopCase.case_count_offset__c,     2000+counter);     
          counter++;
        }      
              
      }
        
    }
*/
	/*  DUPLICATED test - run now in testCaseInsertAndResponse 
    public static testmethod void testCreateTimeObjectForNewCase()
    {
        DontCallFutureMethodFromTestMethod.setIsTestMethod();
        System.debug('in testCreateTimeObjectForNewCase');
        
        RecordType rt = [select Id, Name from RecordType where Name = 'Test Record Type'];
        
        Account acc = [Select a.Site, a.Name From Account a where Site='London' and Name='Marbella Bankcorp' limit 1];
        
        Case testCase = new Case(Subject='A subject', AccountId=acc.Id, RecordTypeId=rt.Id);
        insert testCase;
        
        System.debug('testCase : ' + testCase);
    }*/

	/*
	public static testmethod void testAfterCaseInsert()
	{
        //Tests:  CreateTimeObjectForNewCase, UpdateTimeObjectOnNewCase, and SetCaseOutOfHoursFlag
        
        DontCallFutureMethodFromTestMethod.setIsTestMethod();
        System.debug('in testAfterCaseInsert');
        
		//Set up the test data
		Account testAcct = TestUtility.sampleAccount();
		insert testAcct;
		SLA__c testSLA = TestUtility.sampleSLA();
		insert testSLA;
		Business_Hours_In_Use__c testBHIU = TestUtility.sampleBHIU(testSLA.Id);
		testBHIU.Account__c = testAcct.Id;
		insert testBHIU;
		RecordType rtCase = [select Id, Name from RecordType where Name = 'Test Record Type'];
		Case testCase = TestUtility.sampleCase();
		testCase.RecordTypeId = rtCase.Id;
		testCase.AccountId = testAcct.Id;
		
		//Run the test actions
		Test.StartTest();
		insert testCase;
		Test.StopTest();
		Time_Object__c testTO = [select Id, Out_Of_Hours__c from Time_Object__c where Case__c = :testCase.Id];		
		
		//Verify the results
		System.assert(testTO.Id != null);
		system.debug('Time Object Logged Out of Hours flag='+testTO.Out_Of_Hours__c);
	}
	*/

    public static testmethod void testCaseCalculations(){
        DontCallFutureMethodFromTestMethod.setIsTestMethod();
        RecordType issueRecordType = [select Id, Name from RecordType where Name = 'Issue'];

        //Account acc = [Select a.Site, a.Name From Account a where Site='London' and Name='Marbella Bankcorp' limit 1];
        Account acc = TestUtility.sampleAccount();
        acc.Type = 'Customer';
        acc.SLA_Type__c = 'Standard';
        insert acc;

        //Case testCase = new Case(Subject='A subject', Description='description A', SFDC_CSFE_Commentary__c='commentary A', Replication_Steps__c='rep A', Status='L1 – Awaiting Analysis', RecordTypeId=issueRecordType.Id, AccountId=acc.Id, Priority='Critical');
        Case testCase = TestUtility.sampleCase();
        testCase.Subject = 'A subject';
        testCase.Description = 'description A';
        testCase.SFDC_CSFE_Commentary__c = 'commentary A';
        testCase.Replication_Steps__c = 'rep A';
        testCase.Status = 'L1 - Awaiting Analysis';
        testCase.RecordTypeId = issueRecordType.Id;
        testCase.AccountId = acc.Id;
        testCase.Priority = 'Critical';
        insert testCase;

        System.debug('testCase : ' + testCase);

        testCase.Status = 'Client Testing';
        testCase.Subject = 'B subject';
        testCase.Description = 'description B';
        testCase.SFDC_CSFE_Commentary__c = 'commentary B';
        testCase.Replication_Steps__c = 'rep B';
        //testCase.Date_Time_Responded__c = Datetime.now();


        update testCase;

        testCase.Priority = 'High';
        update testCase;

        testCase.Priority = 'Medium';
        update testCase;

        testCase.Priority = 'Low';
        update testCase;

    }

    public static testmethod void testCaseCalculationsWithAccountChange(){
        DontCallFutureMethodFromTestMethod.setIsTestMethod();
        RecordType issueRecordType = [select Id, Name from RecordType where Name = 'Issue'];

        //Account acc = [Select a.Site, a.Name From Account a where Site='London' and Name='Marbella Bankcorp' limit 1];
        Account acc = TestUtility.sampleAccount();
        acc.Type = 'Customer';
        acc.SLA_Type__c = 'Standard';
        insert acc;

        //Case testCase = new Case(Subject='A subject', Description='description A', SFDC_CSFE_Commentary__c='commentary A', Replication_Steps__c='rep A', Status='L1 – Awaiting Analysis', RecordTypeId=issueRecordType.Id, AccountId=acc.Id, Priority='Critical');
        Case testCase = TestUtility.sampleCase();
        testCase.Subject = 'A subject';
        testCase.Description = 'description A';
        testCase.SFDC_CSFE_Commentary__c = 'commentary A';
        testCase.Replication_Steps__c = 'rep A';
        testCase.Status = 'L1 - Awaiting Analysis';
        testCase.RecordTypeId = issueRecordType.Id;
        testCase.AccountId = acc.Id;
        testCase.Priority = 'Critical';
        insert testCase;

        System.debug('testCase : ' + testCase);

        testCase.Status = 'Client Testing';
        testCase.Subject = 'B subject';
        testCase.Description = 'description B';
        testCase.SFDC_CSFE_Commentary__c = 'commentary B';
        testCase.Replication_Steps__c = 'rep B';

        //Account newAcc = [Select a.Site, a.Name From Account a where Site='Paris' and Name='Marbella Bankcorp' limit 1];
        Account newAcc = [Select a.Site, a.Name From Account a limit 1];
        testCase.AccountId = newAcc.Id;
        update testCase;
    }

    public static testmethod void testCaseInsertAndResponse(){
        DontCallFutureMethodFromTestMethod.setIsTestMethod();
        System.debug('in testCaseInsertAndResponse');

        //Set up the test data
        //RecordType rt = [select Id, Name from RecordType where Name = 'Test Record Type'];
        RecordType rt = [select Id, Name from RecordType where SObjectType = 'Case' and isActive = true LIMIT 1];
        Account acc = TestUtility.sampleAccount();
        insert acc;
        SLA__c testSLA = TestUtility.sampleSLA();
        insert testSLA;
        Business_Hours_In_Use__c testBHIU = TestUtility.sampleBHIU(testSLA.Id);
        testBHIU.Account__c = acc.Id;
        insert testBHIU;
        Contact con = TestUtility.sampleContact();
        con.AccountId = acc.Id;
        insert con;
        //Account acc = [Select a.Site, a.Name From Account a where Site='London' and Name='Marbella Bankcorp' limit 1];
        //Contact con = [Select Id, AccountId from Contact where AccountId =:acc.Id limit 1];
        Case testCase = TestUtility.sampleCase();
        testCase.Subject = 'A subject';
        testCase.AccountId = acc.Id;
        testCase.ContactId = con.Id;
        testCase.RecordTypeId = rt.Id;
        //Case testCase = new Case(Subject='A subject', ContactId=con.Id, RecordTypeId=rt.Id);

        //Run the tests
        Test.startTest();
        insert testCase;
        //Set a response time
        testCase.Date_Time_Responded__c = DateTime.now();
        update testCase;
        List<Time_Object__c> t = [Select Case__r.Date_Time_Responded__c, Case__r.Subject, t.SLA2_Response_Timestamp__c, t.Response_Time__c, t.Date_Time_Responded__c, t.PSP2_Date_Time_Responded__c from Time_Object__c t where Case__c = :testCase.Id];
        Test.stopTest();

        //Verify the results
        if(t.size() > 0){
            System.debug('t : ' + t);
            System.debug('t.get(0).Case__r.Date_Time_Responded__c : ' + t.get(0).Case__r.Date_Time_Responded__c);
            System.debug('t.get(0).Response_Time__c : ' + t.get(0).Response_Time__c);
        }
        system.assert(t.size() > 0);
        system.assert(t.get(0).Case__r.Date_Time_Responded__c != null);
        //system.assert(t.get(0).Response_Time__c != null);
    }

	/*
    public static testmethod void testCreateTimeObjectForNewCase()
    {
        System.debug('in testCreateTimeObjectForNewCase');
        
        RecordType rt = [select Id, Name from RecordType where Name = 'Test Record Type'];
        
        Account acc = [Select a.Site, a.Name From Account a where Site='London' and Name='Marbella Bankcorp' limit 1];
        
        Case testCase = new Case(Subject='A subject', AccountId=acc.Id, RecordTypeId=rt.Id);
        insert testCase;
        
        System.debug('testCase : ' + testCase);
    }

    public static testmethod void testCaseCalculations()
    {
        RecordType issueRecordType = [select Id, Name from RecordType where Name = 'Issue'];
        
        Account acc = [Select a.Site, a.Name From Account a where Site='London' and Name='Marbella Bankcorp' limit 1];
        
        Case testCase = new Case(Subject='A subject', Description='description A', SFDC_CSFE_Commentary__c='commentary A', Replication_Steps__c='rep A', Status='L1 – Awaiting Analysis', RecordTypeId=issueRecordType.Id, AccountId=acc.Id, Priority='Critical');
        insert testCase;
        
        System.debug('testCase : ' + testCase);
        
        testCase.Status = 'Client Testing';
        testCase.Subject = 'B subject';
        testCase.Description = 'description B';
        testCase.SFDC_CSFE_Commentary__c='commentary B';
        testCase.Replication_Steps__c='rep B';
        //testCase.Date_Time_Responded__c = Datetime.now();
        
        
        update testCase;
        
        testCase.Priority = 'High';
        update testCase;
        
        testCase.Priority = 'Medium';
        update testCase;
        
        testCase.Priority = 'Low';
        update testCase;
         
    }
    
    public static testmethod void testCaseCalculationsWithAccountChange()
    {
        RecordType issueRecordType = [select Id, Name from RecordType where Name = 'Issue'];
        
        Account acc = [Select a.Site, a.Name From Account a where Site='London' and Name='Marbella Bankcorp' limit 1];
        
        Case testCase = new Case(Subject='A subject', Description='description A', SFDC_CSFE_Commentary__c='commentary A', Replication_Steps__c='rep A', Status='L1 - Awaiting Analysis', RecordTypeId=issueRecordType.Id, AccountId=acc.Id, Priority='Critical');
        insert testCase;
        
        System.debug('testCase : ' + testCase);
        
        testCase.Status = 'Client Testing';
        testCase.Subject = 'B subject';
        testCase.Description = 'description B';
        testCase.SFDC_CSFE_Commentary__c='commentary B';
        testCase.Replication_Steps__c='rep B';
        
        Account newAcc = [Select a.Site, a.Name From Account a where Site='Barcelona' and Name='Marbella Bankcorp' limit 1];
        testCase.AccountId = newAcc.Id;
        update testCase;
    }

    public static testmethod void test1()
    {
        System.debug('in test1');
        
        RecordType rt = [select Id, Name from RecordType where Name = 'Test Record Type'];
        
        Account acc = [Select a.Site, a.Name From Account a where Site='London' and Name='Marbella Bankcorp' limit 1];
        Contact con = [Select Id, AccountId from Contact where AccountId =:acc.Id limit 1];
        
        Case testCase = new Case(Subject='A subject', ContactId=con.Id, RecordTypeId=rt.Id);
        insert testCase;
        
        testCase.Date_Time_Responded__c = DateTime.now();
        update testCase;
        
        System.debug('values of Workaround_Provided' + testCase.Workaround_Provided__c + testCase.Status +testCase.Sub_Status__c);
        
        List<Time_Object__c> t = [Select Case__r.Date_Time_Responded__c, Case__r.Subject, t.SLA2_Response_Timestamp__c, t.Response_Time__c, t.Date_Time_Responded__c, t.PSP2_Date_Time_Responded__c from Time_Object__c t where Case__c =:testCase.Id];

        if(t.size() > 0)
        {
            System.debug('t : ' + t);
            System.debug('t.get(0).Case__r.Date_Time_Responded__c : ' + t.get(0).Case__r.Date_Time_Responded__c);
            System.debug('t.get(0).Response_Time__c : ' + t.get(0).Response_Time__c);
        }
        //testCase.Workaround_Time_Stamp__c = DateTime.now();
        
        testCase.Workaround_Provided__c = 'No';
        testCase.Status  = 'L2 - Under Analysis';
        testCase.Sub_Status__c = 'ABC';
        testCase.Priority = 'Critical';
        testCase.Reason = 'Consultancy Provided';
        update testCase;
        testCase.Status = 'Closed';
        update testCase;
        List<Case> lCase = [Select CaseNumber, OwnerId, CSFE_Parent_Status__c,	Case_Category__c, SFDC_CSFE_Commentary__c, Replication_Steps__c, Self_Service_Product__c, Product_Module__c, Priority, Product_Version__c, Description, Subject, Resolution_Type__c, Resolution_Details__c from Case limit 2];
        CaseTriggerMethods.ChangedIssueCase(lCase[0],lCase[1]);
    }
	*/

}