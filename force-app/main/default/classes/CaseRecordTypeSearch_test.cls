@isTest
private class CaseRecordTypeSearch_test
{
    private static testmethod void CaseRecordTypeSearch_testmethod3()
    {
	    CaseRecordTypeSearch_controller cst = new CaseRecordTypeSearch_controller();
	    List<SelectOption> rc = cst.getRecValues();
	    List<SelectOption> gt = cst.getItems();
	    Boolean CheckSection = cst.getCheckSection();
	    cst.setCheckSection(false);
	    String cStatus = cst.getcStatus();
	    String valueSel = cst.getvalueSel();
	    Set<Id> sCases = new Set<Id>();
	    Set<String> sCaseRectype = new Set<String>();
        sCaseRectype.addAll(Label.CaseRecordTypeSearch_RecTypeExclusions.split(','));
	    RecordType rt1 = [select Id, Name from RecordType where sObjectType = 'Case' and isActive = true AND Name NOT IN :sCaseRectype LIMIT 1];
	    RecordType rt2 = [select Id, Name from RecordType where sObjectType = 'Case' and isActive = true AND Name NOT IN :sCaseRectype and Id != :rt1.Id LIMIT 1];
	    
	    //insert customer account
	    Account testAccount = TestUtility.sampleAccount();
	    insert testAccount;
	    system.debug('1111111111111111111111111111');
	    
	    //insert contact on account to be a portal contact
	    Contact contact1 = TestUtility.sampleContact();
	    contact1.accountid = testAccount.Id;
	    contact1.FirstName = 'First';
	    contact1.email = 'testtest@foo.bar.co';
	    insert contact1;
	    system.debug('2222222222222222222222222222222');
	    
	    User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
	    User testCPUser;
	   
		//Insert a test customer portal user
		System.RunAs(thisUser)
		{
			testCPUser = TestUtility.sampleCustPortalUser(contact1);
			insert testCPUser;
			system.debug('3333333333333333333333333333333333');
		}
	    
	    system.runAs(testCPUser){
		    Case testCase1 = TestUtility.sampleCase();
		    //testCase1.RecordTypeId = '012200000000D47';  //Almonde
		    testCase1.RecordTypeId = rt1.Id;
		    testCase1.AccountId = testAccount.Id;
		    insert testCase1;
		    system.debug('444444444444444444444444444444444444');
		    
		    Case testCase2 = TestUtility.sampleCase();
		    //testCase2.RecordTypeId = '012200000008q42';  //MLC
		    testCase2.RecordTypeId = rt2.Id;
		    testCase2.AccountId = testAccount.Id;
		    testCase2.contactid = contact1.id;
		    insert testCase2;
		    system.debug('555555555555555555555555555555555555');
	    
		    //Test search for all visible cases
		    cst.setValueSel('All');
		    cst.setcStatus('None');
		    PageReference pg = cst.find1();
		    List<Case> clist = cst.getSearchRecords();
		    //Set sort field and direction, then run the new sort and get the results
		    cst.sortField = 'CreatedDate';
		    cst.sortDir = 'asc';
		    cst.toggleSort();
		    clist = cst.getSearchRecords();
		    //Verify the two test cases are included in the results
		    system.debug('cList size = '+clist.size());
		    sCases = new Set<Id>();
		    for(Case c : clist)
		    {
		    	sCases.add(c.Id);
		    }
		    system.assert(sCases.contains(testCase1.Id));
		    system.assert(sCases.contains(testCase2.Id));
		    system.debug('66666666666666666666666666666666666');
		    
		    //Test search for all cases with record type = 'Almonde' 
		    cst.setValueSel(rt1.Name);
		    cst.setcStatus('None');
		    pg = cst.find1();
		    clist = cst.getSearchRecords();
		    //Set sort field and direction, then run the new sort and get the results
		    cst.sortField = 'CreatedDate';
		    cst.sortDir = 'asc';
		    cst.toggleSort();
		    clist = cst.getSearchRecords();
		    //Verify the test case for Almonde is returned in the results
		    system.debug('cList size = '+clist.size());
		    sCases = new Set<Id>();
		    for(Case c : clist)
		    {
		    	sCases.add(c.Id);
		    }    
		    system.assert(sCases.contains(testCase1.Id));
		    
		    cst.setcStatus('All Closed Cases');
		    pg = cst.find1();
		    clist = cst.getSearchRecords();
		    
		    cst.setcStatus('All Open Cases');
		    pg = cst.find1();
		    clist = cst.getSearchRecords();
		
		    cst.setcStatus('All My Cases');
		    pg = cst.find1();
		    clist = cst.getSearchRecords();
		
		    cst.setcStatus('My Closed Cases');
		    pg = cst.find1();
		    clist = cst.getSearchRecords();
		    
		    cst.setcStatus('My Open Cases');
		    pg = cst.find1();
		    clist = cst.getSearchRecords();
		     
		    cst.setValueSel(rt2.Name);
		    cst.setcStatus('My Open Cases');
		    pg = cst.find1();
		    clist = cst.getSearchRecords();
	    }
    }
}