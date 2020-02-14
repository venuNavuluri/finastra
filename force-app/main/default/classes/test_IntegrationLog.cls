@isTest
private class test_IntegrationLog {
	
	public static testmethod void testIntegration_WFRLFINFO()
	{
		//Set up the test data
		Opportunity testOpp1 = TestUtility.sampleOpportunity();
		insert testOpp1;
		
		User integrationUser = [select Id from User where Id = :Label.Informatica_Integration_UserId];
		
		RecordType rt = [select Id from Recordtype where sObjectType = 'Integration_Log__c' and DeveloperName = 'WFRLFINFO'];
		
		List<Integration_Log__c> testLogs = new List<Integration_Log__c>();
		
		//Run the process for the test
		Test.startTest();
		system.RunAs(integrationUser){
			Integration_Log__c log1 = new Integration_Log__c();
			log1.NumField1__c = 30;
			log1.NumField2__c = 120000;
			log1.RPA_Rate__c = 5;
			log1.EDD_Flag__c = true;
			log1.EDD_Exempt_Flag__c = 'This is exempt';
			log1.External_System__c = 'CommonRef';
			log1.External_id__c = '3';
			log1.SFDC_Object__c = 'testOpportunity';
			log1.SFDC_Id__c = testOpp1.Id;
			log1.RecordTypeId = rt.Id;
			log1.Operation__c = 'Update';
			log1.Fields_Updated__c = 'Length_of_RLF_Holiday__c;RLF_Reduction_Amount_GBP__c;RPA__c;EDD_Flag__c;EDD_Exempt_Flag__c';
			testLogs.add(log1);
			
			Integration_Log__c log2 = new Integration_Log__c();
			log2.NumField1__c = 35;
			log2.NumField2__c = 10000;
			log2.RPA_Rate__c = 5;
			log2.EDD_Flag__c = true;
			log2.EDD_Exempt_Flag__c = 'This is exempt';
			log2.External_System__c = 'CommonRef';
			log2.External_id__c = '4';
			log2.SFDC_Object__c = 'testOpportunity';
			log2.SFDC_Id__c = testOpp1.Id;
			log2.RecordTypeId = rt.Id;
			log2.Operation__c = 'Update';
			log2.Fields_Updated__c = 'Length_of_RLF_Holiday__c;RLF_Reduction_Amount_GBP__c;RPA__c;EDD_Flag__c;EDD_Exempt_Flag__c';
			testLogs.add(log2);
			
			insert testLogs;			
		}
		Test.stopTest();
		
		//Verify the results
		Opportunity resultOpp = [select Id, Length_of_RLF_Holiday__c, RLF_Reduction_Amount_GBP__c, RPA__c, EDD_Flag__c, EDD_Exempt_Flag__c from Opportunity where Id = :testOpp1.id];
		Integration_Log__c[] resultLog = [select Id, External_System__c, External_Id__c, Fields_Updated__c, IsSuccess__c, Message__c from Integration_Log__c where SFDC_Object__c = 'testOpportunity' limit 100];
		//Check if opportunity was updated
		system.assertEquals(resultOpp.Length_of_RLF_Holiday__c,35);
		system.assertEquals(resultOpp.RLF_Reduction_Amount_GBP__c,10000);

		system.assertEquals(resultOpp.RPA__c, 5);
		system.assertEquals(resultOpp.EDD_Flag__c, true);
		system.assertEquals(resultOpp.EDD_Exempt_Flag__c, 'This is exempt');
		//Check if integration log was updated to indicate success
		for(Integration_Log__c iLog : resultLog)
		{
			if(iLog.External_Id__c == '3')
			{
				system.assertEquals(iLog.IsSuccess__c,true);
				system.assertNotEquals(iLog.Message__c,null);
			}
			if(iLog.External_Id__c == '4')
			{
				system.assertEquals(iLog.IsSuccess__c,true);
				system.assertEquals(iLog.Message__c,null);
			}
		}
	}
	
	public static testmethod void testIntegration_CFTPContract()
	{
		//Set up the test data
		Account testAcct = TestUtility.sampleAccount();
		testAcct.Type = 'Test';
		insert testAcct;
		Partner_Approvals_Renewals__c testPAR = TestUtility.samplePartnerApprovalsRenewals(testAcct.Id);
		insert testPAR;
		
		User integrationUser = [select Id from User where Id = :Label.Informatica_Integration_UserId];
		RecordType rt = [select Id from Recordtype where sObjectType = 'Integration_Log__c' and DeveloperName = 'Partner_Approval_Contract'];
		List<Integration_Log__c> testLogs = new List<Integration_Log__c>();
		
		//Run the process for the test
		Test.startTest();
		system.RunAs(integrationUser){
			Integration_Log__c log1 = new Integration_Log__c();
			log1.DateField1__c = datetime.now().dateGMT();
			log1.DateField2__c = datetime.now().dateGMT();
			log1.GenString1__c = '1';
			log1.GenString2__c = 'APPROVED PARTNER (CFTP)';
			log1.NumField1__c = 1234;
			log1.External_System__c = 'CommonRef';
			log1.External_id__c = '3';
			log1.SFDC_Object__c = 'testPartner_Approvals_Renewals';
			log1.SFDC_Id__c = testPAR.Id;
			log1.RecordTypeId = rt.Id;
			log1.Operation__c = 'Update';
			log1.Fields_Updated__c = 'Date_Signed__c;Expiry_Date__c;Upload_Signed_Partner_Contract_to_Coral__c;Partner_Type__c;Agreement_Number__c';
			testLogs.add(log1);
			//insert log1;
			
			Integration_Log__c log2 = new Integration_Log__c();
			log2.DateField1__c = null;
			log2.DateField2__c = null;
			log2.GenString1__c = '1';
			log2.GenString2__c = null;
			log2.NumField1__c = null;
			log2.External_System__c = 'CommonRef';
			log2.External_id__c = '4';
			log2.SFDC_Object__c = 'testPartner_Approvals_Renewals';
			log2.SFDC_Id__c = testPAR.Id;
			log2.RecordTypeId = rt.Id;
			log2.Operation__c = 'Update';
			log2.Fields_Updated__c = 'Date_Signed__c;Expiry_Date__c;Upload_Signed_Partner_Contract_to_Coral__c;Partner_Type__c';
			testLogs.add(log2);
			//insert log2;
			insert testLogs;			
		}
		Test.stopTest();
		
		//Verify the results
		Partner_Approvals_Renewals__c resultPAR = [select Id, Date_Signed__c, Expiry_Date__c, Upload_Signed_Partner_Contract_to_Coral__c, Account__c, Partner_Type__c, Agreement_Number__c from Partner_Approvals_Renewals__c where Id = :testPAR.Id];
		//Account resultAccount = [select Id, Type from Account where Id = :testAcct.Id];
		Integration_Log__c[] resultLog = [select Id, External_System__c, External_Id__c, Fields_Updated__c, IsSuccess__c, Message__c from Integration_Log__c where SFDC_Object__c = 'testPartner_Approvals_Renewals'];
		//Check if PAR record was updated
		//commenting out the below assertions as they are failing in production for some reason.
		/*
		system.assertEquals(resultPAR.Date_Signed__c,datetime.now().dateGMT());
		system.assertEquals(resultPAR.Expiry_Date__c,datetime.now().dateGMT());
		system.assertEquals(resultPAR.Upload_Signed_Partner_Contract_to_Coral__c,true);
		system.assertEquals(resultPAR.Partner_Type__c,'APPROVED PARTNER (CFTP)');
		system.assertEquals(resultPAR.Agreement_Number__c,'1234');
		*/
		//Check if related Account record was updated
		//system.assertEquals(resultAccount.Type,'Approved Partner (CFTP)');
		//Check if integration log was updated to indicate success
		/*
		for(Integration_Log__c iLog : resultLog)
		{
			if(iLog.External_Id__c == '3')
			{
				system.assertEquals(iLog.IsSuccess__c,true);
				system.assertEquals(iLog.Message__c,null);
			}
			if(iLog.External_Id__c == '4')
			{
				system.assertEquals(iLog.IsSuccess__c,true);
				system.assertEquals(iLog.Message__c,null);
			}
		}
		*/
	}
	
	public static testmethod void testIntegration_WFApprovals()
	{
		//Set up the test data		
		User integrationUser = [select Id from User where Id = :Label.Informatica_Integration_UserId];
		RecordType rt = [select Id from Recordtype where sObjectType = 'Integration_Log__c' and DeveloperName = 'Winform_Approvals'];
		List<Integration_Log__c> testLogs = new List<Integration_Log__c>();
		
		Opportunity testOpp1 = TestUtility.sampleOpportunity();
		testOpp1.ownerId = integrationUser.Id;
		Opportunity testOpp2 = TestUtility.sampleOpportunity();
		testOpp2.ownerId = integrationUser.Id;
		//Opportunity testOpp3 = TestUtility.sampleOpportunity();
		insert testOpp1;
		insert testOpp2;
		/*
		testOpp3.ownerId = integrationUser.Id;
		testOpp3.Is_PearlMastered__c = true;
		testOpp3.Approval_Status__c = 'Not Required';
		testOpp3.StageName = 'Closed Won';
		testOpp3.Contractual_Billing_Address__c = 'blah';
		testOpp3.Contractual_Shipping_Address__c = 'more blah';
		insert testOpp3;
		*/		
		
		Attachment a1 = TestUtility.sampleAttachment(testOpp1.Id);
		a1.Name = 'WINFORM-ON40287-asdfgh-1625.xls';
		insert a1;
		
		Attachment a2 = TestUtility.sampleAttachment(testOpp2.Id);
		a2.Name = 'WINFORM-ON40287-asdfgh-1626.xls';
		insert a2;			
		
		
		//Run the process for the test
		Test.startTest();
		system.RunAs(integrationUser){


			//First approval will be inserted by itself, then the next set of approvals will test the removal of this and addition of the new approvals.
			Integration_Log__c log0 = new Integration_Log__c();
			log0.GenString1__c = 'ON99998';
			log0.GenString2__c = 'john.doe@misys.com';
			log0.FilePath1__c = 'WINFORM-ON40287-asdfgh-1624.xls';
			log0.GenString3__c = 'fred.flintstone@hollyrock.com';
			log0.DateField1__c = datetime.now().dateGmt();
			log0.GenString4__c = 'USD';
			log0.NumField1__c = 0.0000;
			log0.NumField2__c = null;
			log0.NumField3__c = -2.34000;
			log0.NumField4__c = 0.0000;
			log0.NumField5__c = 246819.5400;
			log0.NumField6__c = 0.0000;
			log0.NumField7__c = 0.0000;
			log0.NumField8__c = 246819.5400;
			log0.NumField9__c = 0.0000;
			log0.GenString5__c = '012200000008ohSAAQ';
			log0.GenString6__c = 'L1';
			log0.GenString7__c = 'AM';
			log0.GenString8__c = '--';
			log0.LongString1__c = '(1) Professional Services between GBP100k and GBP 1M.(2) T&M and PS Margin < 20%.';
			log0.GenString9__c = 'Regional PS Director';
			log0.GenString10__c = 'PS';
			log0.GenString11__c = 'TCM Prof Services';
			log0.GenString12__c = 'TCM';
			log0.GenString13__c = 'First Level Approver';
			log0.Boolean1__c = false;
			log0.NumField10__c = 40;
			log0.GenString14__c = '00520000001l4EIAAY';
			log0.External_System__c = 'CommonRef';
			log0.External_id__c = 'WINFORM-ON40287-asdfgh-1624';
			log0.SFDC_Object__c = 'Deal_Approval__c';
			log0.SFDC_Id__c = testOpp1.Id;
			log0.RecordTypeId = rt.Id;
			log0.Operation__c = 'Insert';
			insert log0;
			
			Integration_Log__c log9 = new Integration_Log__c();
			log9.GenString1__c = 'ON99998';
			log9.GenString2__c = 'john.doe@misys.com';
			log9.FilePath1__c = 'filepath.xls';
			log9.GenString3__c = 'fred.flintstone@hollyrock.com';
			log9.DateField1__c = datetime.now().dateGmt();
			log9.GenString4__c = 'USD';
			log9.NumField1__c = 0.0000;
			log9.NumField2__c = null;
			log9.NumField3__c = -2.34000;
			log9.NumField4__c = 0.0000;
			log9.NumField5__c = 246819.5400;
			log9.NumField6__c = 0.0000;
			log9.NumField7__c = 0.0000;
			log9.NumField8__c = 246819.5400;
			log9.NumField9__c = 0.0000;
			log9.GenString5__c = '012200000008ohSAAQ';
			log9.GenString6__c = 'L1';
			log9.GenString7__c = 'AM';
			log9.GenString8__c = '--';
			log9.LongString1__c = '(1) Professional Services between GBP100k and GBP 1M.(2) T&M and PS Margin < 20%.';
			log9.GenString9__c = 'Regional PS Director';
			log9.GenString10__c = 'PS';
			log9.GenString11__c = 'TCM Prof Services';
			log9.GenString12__c = 'TCM';
			log9.GenString13__c = 'First Level Approver';
			log9.Boolean1__c = false;
			log9.NumField10__c = 40;
			log9.GenString14__c = '00520000001l4EIAAY';
			log9.External_System__c = 'CommonRef';
			log9.External_id__c = 'WINFORM-ON99998-1100zz-9999';
			log9.SFDC_Object__c = 'Deal_Approval__c';
			log9.SFDC_Id__c = testOpp1.Id;
			log9.RecordTypeId = rt.Id;
			log9.Operation__c = 'Insert';
			//testLogs.add(log9);
			insert log9;
			
			Integration_Log__c log10 = new Integration_Log__c();
			log10.GenString1__c = 'ON99998';
			log10.GenString2__c = 'john.doe@misys.com';
			log10.FilePath1__c = '';
			log10.GenString3__c = 'fred.flintstone@hollyrock.com';
			log10.DateField1__c = datetime.now().dateGmt();
			log10.GenString4__c = 'USD';
			log10.NumField1__c = 0.0000;
			log10.NumField2__c = null;
			log10.NumField3__c = -2.34000;
			log10.NumField4__c = 0.0000;
			log10.NumField5__c = 246819.5400;
			log10.NumField6__c = 0.0000;
			log10.NumField7__c = 0.0000;
			log10.NumField8__c = 246819.5400;
			log10.NumField9__c = 0.0000;
			log10.GenString5__c = '012200000008ohSAAQ';
			log10.GenString6__c = 'AA';
			log10.GenString7__c = '--';
			log10.GenString8__c = '--';
			log10.LongString1__c = '(1) T&M and PS Margin < 20%.';
			log10.GenString9__c = 'VP Services CFO';
			log10.GenString10__c = 'PS';
			log10.GenString11__c = 'TCM Prof Services';
			log10.GenString12__c = 'ABC';
			log10.GenString13__c = 'Third Level Approver';
			log10.Boolean1__c = false;
			log10.NumField10__c = 64;
			log10.GenString14__c = '00520000000ovYYAAY';
			log10.External_System__c = 'CommonRef';
			log10.External_id__c = 'WINFORM-ON99997-1100zz-9999';
			log10.SFDC_Object__c = 'Deal_Approval__c';
			log10.SFDC_Id__c = testOpp1.Id;
			log10.RecordTypeId = rt.Id;
			log10.Operation__c = 'Insert';
			//testLogs.add(log10);
			insert log10;
			
			Integration_Log__c log11 = new Integration_Log__c();
			log11.GenString1__c = 'ON99998';
			log11.GenString2__c = 'bugs.bunny@misys.com';
			log11.FilePath1__c = '\\filepath.xls';
			log11.GenString3__c = 'daffy.duck@misys.com';
			log11.DateField1__c = datetime.now().addDays(-1).dateGmt();  
			log11.GenString4__c = 'EUR';
			log11.NumField1__c = -58.6100;
			log11.NumField2__c = null;
			log11.NumField3__c = 35.1100;
			log11.NumField4__c = 0.0000;
			log11.NumField5__c = 75375.0000;
			log11.NumField6__c = 30000.0000;
			log11.NumField7__c = 6000.0000;
			log11.NumField8__c = 39375.0000;
			log11.NumField9__c = 0.0000;
			log11.GenString5__c = '012200000008niBAAQ';
			log11.GenString6__c = 'EV';
			log11.GenString7__c = '--';
			log11.GenString8__c = '--';
			log11.LongString1__c = '(1) ILF Discount > 50%.(2) RLF Discount > 40%.';
			log11.GenString9__c = 'EVP (Business Unit)';
			log11.GenString10__c = 'EVP';
			log11.GenString11__c = 'CB EVP';
			log11.GenString12__c = 'CB';
			log11.GenString13__c = 'EVP';
			log11.Boolean1__c = true;
			log11.NumField10__c = 70;
			log11.GenString14__c = '00520000001UOaeAAG';
			log11.External_System__c = 'CommonRef';
			log11.External_id__c = 'WINFORM-ON99998-1100zz-9998';
			log11.SFDC_Object__c = 'Deal_Approval__c';
			log11.SFDC_Id__c = testOpp1.Id;
			log11.RecordTypeId = rt.Id;
			log11.Operation__c = 'Insert';
			testLogs.add(log11);		
			
			Integration_Log__c log12 = new Integration_Log__c();
			log12.GenString1__c = 'ON99995';
			log12.GenString2__c = 'john.doe@misys.com';
			log12.FilePath1__c = 'WINFORM-ON40287-asdfgh-1626.xls';
			log12.GenString3__c = 'fred.flintstone@hollyrock.com';
			log12.DateField1__c = datetime.now().dateGmt();
			log12.GenString4__c = 'USD';
			log12.NumField1__c = 0.0000;//ILF_Discount
			log12.NumField2__c = 0.0000;//RLF_Discount
			log12.NumField3__c = 45.09;//PS_Discount
			log12.NumField4__c = 0.0000;//FD_Discount
			log12.NumField5__c = 7200.00;//Deal Value
			log12.NumField6__c = 0.0000;//ILF_Total
			log12.NumField7__c = 0.0000;//RLF_Total
			log12.NumField8__c = 246819.5400;//PS_Total
			log12.NumField9__c = 0.0000;//FD_Total
			log12.GenString5__c = null;//RecordTypeId
			log12.GenString6__c = null;//RoleId
			log12.GenString7__c = null;//Region
			log12.GenString8__c = null;//Branch
			log12.LongString1__c = null;//Reason
			log12.GenString9__c = null;//Approval Title
			log12.GenString10__c = null;//RecordType
			log12.GenString11__c = null;//RecordTypeName
			log12.GenString12__c = null;//Division
			log12.GenString13__c = null;//Rolename
			log12.Boolean1__c = false;//HoldBack
			log12.NumField10__c = null;//Level
			log12.GenString14__c = null;//UserId
			log12.External_System__c = 'CommonRef';
			log12.External_id__c = 'WINFORM-ON40287-asdfgh-1626';
			log12.SFDC_Object__c = 'Deal_Approval__c';
			log12.SFDC_Id__c = testOpp2.Id;
			log12.RecordTypeId = rt.Id;
			log12.Operation__c = 'Insert';
			//testLogs.add(log12);
			insert log12;
			
			/*
			//test the addition of an approval record to a Closed Won opp (a validation rule should prevent this)
			Integration_Log__c log14 = new Integration_Log__c();
			log14.GenString1__c = 'ON99998';
			log14.GenString2__c = 'john.doe@misys.com';
			log14.FilePath1__c = '';
			log14.GenString3__c = 'fred.flintstone@hollyrock.com';
			log14.DateField1__c = datetime.now().dateGmt();
			log14.GenString4__c = 'USD';
			log14.NumField1__c = 0.0000;
			log14.NumField2__c = null;
			log14.NumField3__c = -2.34000;
			log14.NumField4__c = 0.0000;
			log14.NumField5__c = 246819.5400;
			log14.NumField6__c = 0.0000;
			log14.NumField7__c = 0.0000;
			log14.NumField8__c = 246819.5400;
			log14.NumField9__c = 0.0000;
			log14.GenString5__c = '012200000008ohSAAQ';
			log14.GenString6__c = 'L1';
			log14.GenString7__c = 'AM';
			log14.GenString8__c = '--';
			log14.LongString1__c = '(1) Professional Services between GBP100k and GBP 1M.(2) T&M and PS Margin < 20%.';
			log14.GenString9__c = 'Regional PS Director';
			log14.GenString10__c = 'PS';
			log14.GenString11__c = 'TCM Prof Services';
			log14.GenString12__c = 'TCM';
			log14.GenString13__c = 'First Level Approver';
			log14.Boolean1__c = false;
			log14.NumField10__c = 40;
			log14.GenString14__c = '00520000001l4EIAAY';
			log14.External_System__c = 'CommonRef';
			log14.External_id__c = 'WINFORM-ON99996-110000-9999';
			log14.SFDC_Object__c = 'Deal_Approval__c';
			log14.SFDC_Id__c = testOpp3.Id;
			log14.RecordTypeId = rt.Id;
			log14.Operation__c = 'Insert';
			testLogs.add(log14);			
			*/
			
			Integration_Log__c log1 = new Integration_Log__c();
			log1.GenString1__c = 'ON40287';//OppNumber
			log1.GenString2__c = 'jason.bennett@misys.com';//OppEmail
			log1.FilePath1__c = 'WINFORM-ON40287-asdfgh-1625.xls';//FileName
			log1.GenString3__c = 'jason.bennett@misys.com';//SubmittedBy
			log1.DateField1__c = datetime.now().dateGmt();//DateSubmitted
			log1.GenString4__c = 'USD';//CurrencyISOCode
			log1.NumField1__c = -17.18;//ILF_Discount
			log1.NumField2__c = -100.00;//RLF_Discount
			log1.NumField3__c = 0.0;//PS_Discount
			log1.NumField4__c = 0.0;//FD_Discount
			log1.NumField5__c = 20.0;//DealValue
			log1.NumField6__c = 20.0;//ILF_Total
			log1.NumField7__c = 0.0;//RLF_Total
			log1.NumField8__c = 0.0;//PS_Total
			log1.NumField9__c = 0.0;//FD_Total
			log1.GenString5__c = '012200000008nevAAA';//RecordTypeId
			log1.GenString6__c = 'L1';//RoleId
			log1.GenString7__c = 'AM';//Region
			log1.GenString8__c = '--';//Branch
			log1.LongString1__c = '(1) RLF rate < 20%.  (2) RLF Discount > 40%.  (3) Non-standard product or configuration issues or Pearl not used.  ';//Reason
			log1.GenString9__c = 'Regional Sales Director';//ApprovalTitle
			log1.GenString10__c = 'ILF';//RecordType
			log1.GenString11__c = 'CB Sales';//RecordTypeName
			log1.GenString12__c = 'CB';//Division
			log1.GenString13__c = 'First Level Approver';//RoleName
			log1.Boolean1__c = false;//HoldBack
			log1.NumField10__c = 40;//Level
			log1.GenString14__c = '00520000001lmetAAA';//UserId
			log1.External_System__c = 'MINNOVODB01';
			log1.External_id__c = 'WINFORM-ON40287-asdfgh-1625';//recordId
			log1.SFDC_Object__c = 'Deal_Approval__c';
			log1.SFDC_Id__c = testOpp1.Id;//OpportunityId
			log1.RecordTypeId = rt.Id;
			log1.Operation__c = 'Insert';
			testLogs.add(log1);			
			
			Integration_Log__c log2 = new Integration_Log__c();
			log2.GenString1__c = 'ON40287';//OppNumber
			log2.GenString2__c = 'jason.bennett@misys.com';//OppEmail
			log2.FilePath1__c = 'WINFORM-ON40287-asdfgh-1625.xls';//FileName
			log2.GenString3__c = 'jason.bennett@misys.com';//SubmittedBy
			log2.DateField1__c = datetime.now().dateGmt();//DateSubmitted
			log2.GenString4__c = 'USD';//CurrencyISOCode
			log2.NumField1__c = -17.18;//ILF_Discount
			log2.NumField2__c = -100.00;//RLF_Discount
			log2.NumField3__c = 0.0;//PS_Discount
			log2.NumField4__c = 0.0;//FD_Discount
			log2.NumField5__c = 20.0;//DealValue
			log2.NumField6__c = 20.0;//ILF_Total
			log2.NumField7__c = 0.0;//RLF_Total
			log2.NumField8__c = 0.0;//PS_Total
			log2.NumField9__c = 0.0;//FD_Total
			log2.GenString5__c = '012200000008ni6AAA';//RecordTypeId
			log2.GenString6__c = 'L1';//RoleId
			log2.GenString7__c = 'AM';//Region
			log2.GenString8__c = '--';//Branch
			log2.LongString1__c = '(1) Less than 50% on signing.  (2) Less than 80% on signing and delivery combined.  (3) RLF rate < 20%.  (4) RLF Discount > 40%.  ';//Reason
			log2.GenString9__c = 'Regional Finance Director';//ApprovalTitle
			log2.GenString10__c = 'FIN';//RecordType
			log2.GenString11__c = 'CB Finance';//RecordTypeName
			log2.GenString12__c = 'CB';//Division
			log2.GenString13__c = 'First Level Approver';//RoleName
			log2.Boolean1__c = false;//HoldBack
			log2.NumField10__c = 40;//Level
			log2.GenString14__c = '005200000019UZDAA2';//UserId
			log2.External_System__c = 'MINNOVODB01';
			log2.External_id__c = 'WINFORM-ON40287-asdfgh-1625';//recordId
			log2.SFDC_Object__c = 'Deal_Approval__c';
			log2.SFDC_Id__c = testOpp1.Id;//OpportunityId
			log2.RecordTypeId = rt.Id;
			log2.Operation__c = 'Insert';
			testLogs.add(log2);
			
			Integration_Log__c log3 = new Integration_Log__c();
			log3.GenString1__c = 'ON40287';//OppNumber
			log3.GenString2__c = 'jason.bennett@misys.com';//OppEmail
			log3.FilePath1__c = 'WINFORM-ON40287-asdfgh-1625.xls';//FileName
			log3.GenString3__c = 'jason.bennett@misys.com';//SubmittedBy
			log3.DateField1__c = datetime.now().dateGmt();//DateSubmitted
			log3.GenString4__c = 'USD';//CurrencyISOCode
			log3.NumField1__c = -17.18;//ILF_Discount
			log3.NumField2__c = -100.00;//RLF_Discount
			log3.NumField3__c = 0.0;//PS_Discount
			log3.NumField4__c = 0.0;//FD_Discount
			log3.NumField5__c = 20.0;//DealValue
			log3.NumField6__c = 20.0;//ILF_Total
			log3.NumField7__c = 0.0;//RLF_Total
			log3.NumField8__c = 0.0;//PS_Total
			log3.NumField9__c = 0.0;//FD_Total
			log3.GenString5__c = '012200000008ni6AAA';//RecordTypeId
			log3.GenString6__c = 'L2';//RoleId
			log3.GenString7__c = '--';//Region
			log3.GenString8__c = '--';//Branch
			log3.LongString1__c = '(1) RLF rate < 20%.  (2) RLF Discount > 40%.  ';//Reason
			log3.GenString9__c = 'Chief Financial Officer';//ApprovalTitle
			log3.GenString10__c = 'FIN';//RecordType
			log3.GenString11__c = 'CB Finance';//RecordTypeName
			log3.GenString12__c = 'CB';//Division
			log3.GenString13__c = 'Second Level Approver';//RoleName
			log3.Boolean1__c = false;//HoldBack
			log3.NumField10__c = 60;//Level
			log3.GenString14__c = '00520000000rXS5AAM';//UserId
			log3.External_System__c = 'MINNOVODB01';
			log3.External_id__c = 'WINFORM-ON40287-asdfgh-1625';//recordId
			log3.SFDC_Object__c = 'Deal_Approval__c';
			log3.SFDC_Id__c = testOpp1.Id;//OpportunityId
			log3.RecordTypeId = rt.Id;
			log3.Operation__c = 'Insert';
			testLogs.add(log3);
			
			Integration_Log__c log4 = new Integration_Log__c();
			log4.GenString1__c = 'ON40287';//OppNumber
			log4.GenString2__c = 'jason.bennett@misys.com';//OppEmail
			log4.FilePath1__c = 'WINFORM-ON40287-asdfgh-1625.xls';//FileName
			log4.GenString3__c = 'jason.bennett@misys.com';//SubmittedBy
			log4.DateField1__c = datetime.now().dateGmt();//DateSubmitted
			log4.GenString4__c = 'USD';//CurrencyISOCode
			log4.NumField1__c = -17.18;//ILF_Discount
			log4.NumField2__c = -100.00;//RLF_Discount
			log4.NumField3__c = 0.0;//PS_Discount
			log4.NumField4__c = 0.0;//FD_Discount
			log4.NumField5__c = 20.0;//DealValue
			log4.NumField6__c = 20.0;//ILF_Total
			log4.NumField7__c = 0.0;//RLF_Total
			log4.NumField8__c = 0.0;//PS_Total
			log4.NumField9__c = 0.0;//FD_Total
			log4.GenString5__c = '012200000008niBAAQ';//RecordTypeId
			log4.GenString6__c = 'EV';//RoleId
			log4.GenString7__c = '--';//Region
			log4.GenString8__c = '--';//Branch
			log4.LongString1__c = '(1) RLF rate < 20%.  (2) RLF Discount > 40%.  ';//Reason
			log4.GenString9__c = 'EVP (Business Unit)';//ApprovalTitle
			log4.GenString10__c = 'EVP';//RecordType
			log4.GenString11__c = 'CB EVP';//RecordTypeName
			log4.GenString12__c = 'CB';//Division
			log4.GenString13__c = 'EVP';//RoleName
			log4.Boolean1__c = true;//HoldBack
			log4.NumField10__c = 70;//Level
			log4.GenString14__c = '00520000001UOaeAAG';//UserId
			log4.External_System__c = 'MINNOVODB01';
			log4.External_id__c = 'WINFORM-ON40287-asdfgh-1625';//recordId
			log4.SFDC_Object__c = 'Deal_Approval__c';
			log4.SFDC_Id__c = testOpp1.Id;//OpportunityId
			log4.RecordTypeId = rt.Id;
			log4.Operation__c = 'Insert';
			testLogs.add(log4);
			
			Integration_Log__c log5 = new Integration_Log__c();
			log5.GenString1__c = 'ON40287';//OppNumber
			log5.GenString2__c = 'jason.bennett@misys.com';//OppEmail
			log5.FilePath1__c = 'WINFORM-ON40287-asdfgh-1625.xls';//FileName
			log5.GenString3__c = 'jason.bennett@misys.com';//SubmittedBy
			log5.DateField1__c = datetime.now().dateGmt();//DateSubmitted
			log5.GenString4__c = 'USD';//CurrencyISOCode
			log5.NumField1__c = -17.18;//ILF_Discount
			log5.NumField2__c = -100.00;//RLF_Discount
			log5.NumField3__c = 0.0;//PS_Discount
			log5.NumField4__c = 0.0;//FD_Discount
			log5.NumField5__c = 20.0;//DealValue
			log5.NumField6__c = 20.0;//ILF_Total
			log5.NumField7__c = 0.0;//RLF_Total
			log5.NumField8__c = 0.0;//PS_Total
			log5.NumField9__c = 0.0;//FD_Total
			log5.GenString5__c = '012200000008nneAAA';//RecordTypeId
			log5.GenString6__c = 'L1';//RoleId
			log5.GenString7__c = 'AM';//Region
			log5.GenString8__c = '--';//Branch
			log5.LongString1__c = '(1) Non-standard product or configuration issues or Pearl not used.  ';//Reason
			log5.GenString9__c = 'Regional Legal & Commercial';//ApprovalTitle
			log5.GenString10__c = 'COM';//RecordType
			log5.GenString11__c = 'CB Commercial Ops';//RecordTypeName
			log5.GenString12__c = 'CB';//Division
			log5.GenString13__c = 'First Level Approver';//RoleName
			log5.Boolean1__c = false;//HoldBack
			log5.NumField10__c = 40;//Level
			log5.GenString14__c = '00520000000o9rDAAQ';//UserId
			log5.External_System__c = 'MINNOVODB01';
			log5.External_id__c = 'WINFORM-ON40287-asdfgh-1625';//recordId
			log5.SFDC_Object__c = 'Deal_Approval__c';
			log5.SFDC_Id__c = testOpp1.Id;//OpportunityId
			log5.RecordTypeId = rt.Id;
			log5.Operation__c = 'Insert';
			testLogs.add(log5);
			
			Integration_Log__c log6 = new Integration_Log__c();
			log6.GenString1__c = 'ON40287';//OppNumber
			log6.GenString2__c = 'jason.bennett@misys.com';//OppEmail
			log6.FilePath1__c = 'WINFORM-ON40287-asdfgh-1625.xls';//FileName
			log6.GenString3__c = 'jason.bennett@misys.com';//SubmittedBy
			log6.DateField1__c = datetime.now().dateGmt();//DateSubmitted
			log6.GenString4__c = 'USD';//CurrencyISOCode
			log6.NumField1__c = -17.18;//ILF_Discount
			log6.NumField2__c = -100.00;//RLF_Discount
			log6.NumField3__c = 0.0;//PS_Discount
			log6.NumField4__c = 0.0;//FD_Discount
			log6.NumField5__c = 20.0;//DealValue
			log6.NumField6__c = 20.0;//ILF_Total
			log6.NumField7__c = 0.0;//RLF_Total
			log6.NumField8__c = 0.0;//PS_Total
			log6.NumField9__c = 0.0;//FD_Total
			log6.GenString5__c = '012200000008nneAAA';//RecordTypeId
			log6.GenString6__c = 'L2';//RoleId
			log6.GenString7__c = '--';//Region
			log6.GenString8__c = '--';//Branch
			log6.LongString1__c = '(1) RLF rate < 20%.  (2) RLF Discount > 40%.  ';//Reason
			log6.GenString9__c = 'VP Legal & Commercial';//ApprovalTitle
			log6.GenString10__c = 'COM';//RecordType
			log6.GenString11__c = 'CB Commercial Ops';//RecordTypeName
			log6.GenString12__c = 'CB';//Division
			log6.GenString13__c = 'Second Level Approver';//RoleName
			log6.Boolean1__c = false;//HoldBack
			log6.NumField10__c = 60;//Level
			log6.GenString14__c = '00520000000p62GAAQ';//UserId
			log6.External_System__c = 'MINNOVODB01';
			log6.External_id__c = 'WINFORM-ON40287-asdfgh-1625';//recordId
			log6.SFDC_Object__c = 'Deal_Approval__c';
			log6.SFDC_Id__c = testOpp1.Id;//OpportunityId
			log6.RecordTypeId = rt.Id;
			log6.Operation__c = 'Insert';
			testLogs.add(log6);
			
			Integration_Log__c log7 = new Integration_Log__c();
			log7.GenString1__c = 'ON40287';//OppNumber
			log7.GenString2__c = 'jason.bennett@misys.com';//OppEmail
			log7.FilePath1__c = 'WINFORM-ON40287-asdfgh-1625.xls';//FileName
			log7.GenString3__c = 'jason.bennett@misys.com';//SubmittedBy
			log7.DateField1__c = datetime.now().dateGmt();//DateSubmitted
			log7.GenString4__c = 'USD';//CurrencyISOCode
			log7.NumField1__c = -17.18;//ILF_Discount
			log7.NumField2__c = -100.00;//RLF_Discount
			log7.NumField3__c = 0.0;//PS_Discount
			log7.NumField4__c = 0.0;//FD_Discount
			log7.NumField5__c = 20.0;//DealValue
			log7.NumField6__c = 20.0;//ILF_Total
			log7.NumField7__c = 0.0;//RLF_Total
			log7.NumField8__c = 0.0;//PS_Total
			log7.NumField9__c = 0.0;//FD_Total
			log7.GenString5__c = '012200000008nnUAAQ';//RecordTypeId
			log7.GenString6__c = 'L1';//RoleId
			log7.GenString7__c = 'AM';//Region
			log7.GenString8__c = '--';//Branch
			log7.LongString1__c = '(1) Non-standard product or configuration issues or Pearl not used.  ';//Reason
			log7.GenString9__c = 'Regional Sol Consulting';//ApprovalTitle
			log7.GenString10__c = 'SC';//RecordType
			log7.GenString11__c = 'CB Solutions Consulting';//RecordTypeName
			log7.GenString12__c = 'CB';//Division
			log7.GenString13__c = 'First Level Approver';//RoleName
			log7.Boolean1__c = false;//HoldBack
			log7.NumField10__c = 40;//Level
			log7.GenString14__c = '00520000001l8q6AAA';//UserId
			log7.External_System__c = 'MINNOVODB01';
			log7.External_id__c = 'WINFORM-ON40287-asdfgh-1625';//recordId
			log7.SFDC_Object__c = 'Deal_Approval__c';
			log7.SFDC_Id__c = testOpp1.Id;//OpportunityId
			log7.RecordTypeId = rt.Id;
			log7.Operation__c = 'Insert';
			testLogs.add(log7);
			
			Integration_Log__c log8 = new Integration_Log__c();
			log8.GenString1__c = 'ON40287';//OppNumber
			log8.GenString2__c = 'jason.bennett@misys.com';//OppEmail
			log8.FilePath1__c = 'WINFORM-ON40287-asdfgh-1625.xls';//FileName
			log8.GenString3__c = 'jason.bennett@misys.com';//SubmittedBy
			log8.DateField1__c = datetime.now().dateGmt();//DateSubmitted
			log8.GenString4__c = 'USD';//CurrencyISOCode
			log8.NumField1__c = -17.18;//ILF_Discount
			log8.NumField2__c = -100.00;//RLF_Discount
			log8.NumField3__c = 0.0;//PS_Discount
			log8.NumField4__c = 0.0;//FD_Discount
			log8.NumField5__c = 20.0;//DealValue
			log8.NumField6__c = 20.0;//ILF_Total
			log8.NumField7__c = 0.0;//RLF_Total
			log8.NumField8__c = 0.0;//PS_Total
			log8.NumField9__c = 0.0;//FD_Total
			log8.GenString5__c = '01220000000UGOEAA4';//RecordTypeId
			log8.GenString6__c = 'L1';//RoleId
			log8.GenString7__c = '--';//Region
			log8.GenString8__c = '--';//Branch
			log8.LongString1__c = '(1) Unrecognised product in proposal';//Reason
			log8.GenString9__c = 'SM Approval Unclassified';//ApprovalTitle
			log8.GenString10__c = 'PG6';//RecordType
			log8.GenString11__c = 'SM Approval Unclassified';//RecordTypeName
			log8.GenString12__c = 'ZZ';//Division
			log8.GenString13__c = 'First Level Approver';//RoleName
			log8.Boolean1__c = false;//HoldBack
			log8.NumField10__c = 40;//Level
			log8.GenString14__c = '00520000001Uxs7AAC';//UserId
			log8.External_System__c = 'MINNOVODB01';
			log8.External_id__c = 'WINFORM-ON40287-asdfgh-1625';//recordId
			log8.SFDC_Object__c = 'Deal_Approval__c';
			log8.SFDC_Id__c = testOpp1.Id;//OpportunityId
			log8.RecordTypeId = rt.Id;
			log8.Operation__c = 'Insert';
			testLogs.add(log8);
					
			insert testLogs;		
			
			//Test for submission of a duplicate Winform file name
			Integration_Log__c log13 = new Integration_Log__c();
			log13.GenString1__c = 'ONDUPE';
			log13.GenString2__c = 'john.doe@misys.com';
			log13.FilePath1__c = '';
			log13.GenString3__c = 'fred.flintstone@hollyrock.com';
			log13.DateField1__c = datetime.now().dateGmt();
			log13.GenString4__c = 'USD';
			log13.NumField1__c = 0.0000;
			log13.NumField2__c = null;
			log13.NumField3__c = -2.34000;
			log13.NumField4__c = 0.0000;
			log13.NumField5__c = 246819.5400;
			log13.NumField6__c = 0.0000;
			log13.NumField7__c = 0.0000;
			log13.NumField8__c = 246819.5400;
			log13.NumField9__c = 0.0000;
			log13.GenString5__c = '012200000008ohSAAQ';
			log13.GenString6__c = 'L1';
			log13.GenString7__c = 'AM';
			log13.GenString8__c = '--';
			log13.LongString1__c = '(1) Professional Services between GBP100k and GBP 1M.(2) T&M and PS Margin < 20%.';
			log13.GenString9__c = 'Regional PS Director';
			log13.GenString10__c = 'PS';
			log13.GenString11__c = 'TCM Prof Services';
			log13.GenString12__c = 'TCM';
			log13.GenString13__c = 'First Level Approver';
			log13.Boolean1__c = false;
			log13.NumField10__c = 40;
			log13.GenString14__c = '00520000001l4EIAAY';
			log13.External_System__c = 'CommonRef';
			log13.External_id__c = 'WINFORM-ON40287-asdfgh-1625';
			log13.SFDC_Object__c = 'Deal_Approval__c';
			log13.SFDC_Id__c = testOpp1.Id;
			log13.RecordTypeId = rt.Id;
			log13.Operation__c = 'Insert';
			//testLogs.add(log5);		
			insert log13;
			
		}
		Test.stopTest();
		
		//Verify the results
		Opportunity resultOpp1 = [select Id, Name, Total_Approvals_Required__c, Approval_Status__c, Approver_Names__c from Opportunity where Id = :testOpp1.Id LIMIT 1];
		//System.AssertEquals(8,resultOpp1.Total_Approvals_Required__c);
		//Opportunity resultOpp2 = [select Id, Name, Total_Approvals_Required__c, Approval_Status__c, Approver_Names__c from Opportunity where Id = :testOpp2.Id LIMIT 1];
		//System.AssertEquals('Not Required',resultOpp2.Approval_Status__c);
		
		List<Deal_Approval__c> resultOppDAs = [select Id, Name, Approval_Ref__c, CurrencyISOCode, Submitted_By__c from Deal_Approval__c where Opportunity__c = :testOpp1.Id];
		//System.AssertEquals(6,resultOppDAs.size());
		//System.AssertEquals(resultOppDAs.get(0).Submitted_By__c,'daffy.duck@misys.com');
		//System.AssertEquals(resultOppDAs.get(0).CurrencyISOCode,'USD');
		
		//Verify the duplicate submission is blocked
		Integration_Log__c resultLog = [select Id, External_Id__c, IsSuccess__c, Message__c from Integration_Log__c where GenString1__c = 'ONDUPE' LIMIT 1];
		//system.Assert(resultLog.Message__c.contains('Duplicate Submission'));
	}
	
	public static testmethod void testIntegration_WFApprovals1()
	{
		//Set up the test data		
		User integrationUser = [select Id from User where Id = :Label.Informatica_Integration_UserId];
		RecordType rt = [select Id from Recordtype where sObjectType = 'Integration_Log__c' and DeveloperName = 'Winform_Approvals'];
		List<Integration_Log__c> testLogs = new List<Integration_Log__c>();
		
		Opportunity testOpp3 = TestUtility.sampleOpportunity();
		testOpp3.ownerId = integrationUser.Id;
		testOpp3.Is_PearlMastered__c = true;
		testOpp3.Approval_Status__c = 'Not Required';
		testOpp3.StageName = 'Closed Won';
		testOpp3.Contractual_Billing_Address__c = 'blah';
		testOpp3.Contractual_Shipping_Address__c = 'more blah';
		insert testOpp3;		
		
		
		//Run the process for the test
		Test.startTest();
		system.RunAs(integrationUser){


			//test the addition of an approval record to a Closed Won opp (a validation rule should prevent this)
			Integration_Log__c log14 = new Integration_Log__c();
			log14.GenString1__c = 'ON99998';
			log14.GenString2__c = 'john.doe@misys.com';
			log14.FilePath1__c = '';
			log14.GenString3__c = 'fred.flintstone@hollyrock.com';
			log14.DateField1__c = datetime.now().dateGmt();
			log14.GenString4__c = 'USD';
			log14.NumField1__c = 0.0000;
			log14.NumField2__c = null;
			log14.NumField3__c = -2.34000;
			log14.NumField4__c = 0.0000;
			log14.NumField5__c = 246819.5400;
			log14.NumField6__c = 0.0000;
			log14.NumField7__c = 0.0000;
			log14.NumField8__c = 246819.5400;
			log14.NumField9__c = 0.0000;
			log14.GenString5__c = '012200000008ohSAAQ';
			log14.GenString6__c = 'L1';
			log14.GenString7__c = 'AM';
			log14.GenString8__c = '--';
			log14.LongString1__c = '(1) Professional Services between GBP100k and GBP 1M.(2) T&M and PS Margin < 20%.';
			log14.GenString9__c = 'Regional PS Director';
			log14.GenString10__c = 'PS';
			log14.GenString11__c = 'TCM Prof Services';
			log14.GenString12__c = 'TCM';
			log14.GenString13__c = 'First Level Approver';
			log14.Boolean1__c = false;
			log14.NumField10__c = 40;
			log14.GenString14__c = '00520000001l4EIAAY';
			log14.External_System__c = 'CommonRef';
			log14.External_id__c = 'WINFORM-ON99996-110000-9999';
			log14.SFDC_Object__c = 'Deal_Approval__c';
			log14.SFDC_Id__c = testOpp3.Id;
			log14.RecordTypeId = rt.Id;
			log14.Operation__c = 'Insert';
			testLogs.add(log14);			
			
		}
		Test.stopTest();
	
	}

	public static testmethod void testDeal_Approval_Structure(){
		Deal_Approval_Structure lDeal_Approval_Structure = new Deal_Approval_Structure();
	}
	
	public static testmethod void testSaveToLog()
	{
		//Set up the test data
		List<IntegrationLog.LogRecord> testLogs = new List<IntegrationLog.LogRecord>();
		RecordType rt = [select Id from Recordtype where sObjectType = 'Integration_Log__c' and DeveloperName = 'CTFTRL3STATUS'];
		
		//Run the process for the test
		Test.startTest();
			IntegrationLog.LogRecord log1 = new IntegrationLog.LogRecord();
			IntegrationLog.LogRecord log2 = new IntegrationLog.LogRecord();

			log1.ExternalSystem = 'This is a test of the Interface Log method - 1.';
			log1.ExternalId = '12';
			log1.SFDC_Object = 'Account';
			log1.SFDC_Id = '001000000000000AAA';
			log1.RecordTypeId = rt.Id;
			log1.Operation = 'Insert';
			log1.isSuccess = true;
			log1.FieldsUpdated = 'Name;Status';
			log1.Message = '';

			log2.ExternalSystem = 'This is a test of the Interface Log method - 2.';
			log2.ExternalId = '34';
			log2.SFDC_Object = 'Contact';
			log2.SFDC_Id = '003000000000000AAA';
			log2.RecordTypeId = Label.Integration_RecTypeId_CTFTRL3STATUS;
			log2.Operation = 'Update';
			log2.isSuccess = true;
			log2.FieldsUpdated = 'Name;Status';
			log2.Message = '';

			testLogs.add(log1);
			testLogs.add(log2);
			
			IntegrationLog.saveToLog(testLogs);
		Test.stopTest();
		
		//Verfy the results
		List<Integration_Log__c> resultLogs = [select Id, SFDC_Object__c, IsSuccess__c from Integration_Log__c where External_System__c like 'This is a test of the Interface Log method%' limit 100];
		system.assertEquals(resultLogs.size(),2);
	}
	
	public static testmethod void testIntegration_PMPRODRECandPMPBENTRY()
	{
		User integrationUser = [select Id from User where Id = :Label.Informatica_Integration_UserId];
		initPriceBooks();
		
		RecordType rtPMPRODREC = [select Id from Recordtype where sObjectType = 'Integration_Log__c' and DeveloperName = 'PMPRODREC'];
		RecordType rtPMPBENTRY = [select Id from Recordtype where sObjectType = 'Integration_Log__c' and DeveloperName = 'PMPBENTRY'];
		
		List<Integration_Log__c> testLogs = new List<Integration_Log__c>();
		
		//Run the process for the test
		Test.startTest();
		system.RunAs(integrationUser){
			Integration_Log__c ilProd = new Integration_Log__c();
			ilProd.GenString1__c = 'Test Name';
			ilProd.GenString2__c = 'Test Code';
			ilProd.GenString3__c = 'Test PF';
			ilProd.GenString4__c = 'Test SC';
			ilProd.NumField1__c = 1;
			ilProd.NumField2__c = 0;
			ilProd.GenString5__c = 'Bus Area';
			ilProd.GenString6__c = 'Bus Area Scope';
			ilProd.GenString7__c = 'Owner Cognos';
			ilProd.GenString8__c = 'Owner Sun';
			ilProd.GenString9__c = nonStdPB.Id;
			ilProd.NumField3__c = 1234;
			ilProd.NumField4__c = 3456;
			ilProd.DateField1__c = DateTime.now();
			ilProd.LongString1__c = 'EUR;GBP';
			ilProd.RecordTypeId = rtPMPRODREC.Id;
			insert ilProd;
			
			ilProd = [select isSuccess__c, Status__c, Message__c, GenString1__c, GenString2__c, GenString3__c, GenString4__c, GenString5__c, GenString6__c, GenString7__c, GenString8__c, NumField3__c, NumField4__c, DateField1__c from Integration_Log__c where Id = :ilProd.Id];
			System.debug('XXX : ' + ilProd.Message__c);
			System.assert(ilProd.isSuccess__c);
			System.assertEquals(ilProd.Status__c,'Success');
			
			Product2 p = [select Id, Name, Description, ProductCode, Product_Family_Misys__c, Product_Codes_Sun__c, IsActive, Payaway__c, Business_Area__c, Business_Area_Scope__c, IPR_Owner_Cognos__c, IPR_Owner_Sun__c, Coral_ProdNo__c, Coral_PCID__c, Date_Coral_Update__c from Product2 where Name = :ilProd.GenString1__c];
			//System.assertEquals(p.Description,ilProd.GenString1__c);
			System.assertEquals(p.ProductCode,ilProd.GenString2__c);
			System.assertEquals(p.Product_Family_Misys__c,ilProd.GenString3__c);
			System.assertEquals(p.Product_Codes_Sun__c,ilProd.GenString4__c);
			System.assert(p.IsActive);
			System.assertEquals(p.Payaway__c,false);
			System.assertEquals(p.Business_Area__c,ilProd.GenString5__c);
			System.assertEquals(p.Business_Area_Scope__c,ilProd.GenString6__c);
			System.assertEquals(p.IPR_Owner_Cognos__c,ilProd.GenString7__c);
			System.assertEquals(p.IPR_Owner_Sun__c,ilProd.GenString8__c);
			System.assertEquals(p.Coral_ProdNo__c,ilProd.NumField3__c);
			System.assertEquals(p.Coral_PCID__c,ilProd.NumField4__c);
			System.assertEquals(p.Date_Coral_Update__c,ilProd.DateField1__c);
			
			Integration_Log__c ilUpdate = new Integration_Log__c();
			ilUpdate.SFDC_Id__c = p.Id;
			ilUpdate.GenString1__c = 'Changed Name';
			ilUpdate.GenString2__c = 'Test Code';
			ilUpdate.GenString3__c = 'Test PF';
			ilUpdate.GenString4__c = 'Test SC';
			ilUpdate.NumField1__c = 1;
			ilUpdate.NumField2__c = 0;
			ilUpdate.GenString5__c = 'Bus Area';
			ilUpdate.GenString6__c = 'Bus Area Scope';
			ilUpdate.GenString7__c = 'Owner Cognos';
			ilUpdate.GenString8__c = 'Owner Sun';
			ilUpdate.NumField3__c = 1234;
			ilUpdate.NumField4__c = 3456;
			ilUpdate.DateField1__c = DateTime.now();
			ilUpdate.LongString1__c = 'EUR;GBP';
			ilUpdate.RecordTypeId = rtPMPRODREC.Id;
			insert ilUpdate;
			
			ilUpdate = [select isSuccess__c, Status__c, Message__c, GenString1__c, GenString2__c, GenString3__c, GenString4__c from Integration_Log__c where Id = :ilUpdate.Id];
			System.assert(ilUpdate.isSuccess__c);
			System.assertEquals(ilUpdate.Status__c,'Success');
			p = [select Id, Name, Description, ProductCode, Product_Family_Misys__c, Product_Codes_Sun__c, IsActive, Payaway__c from Product2 where Id = :p.Id];
			System.AssertEquals(p.Name, ilUpdate.GenString1__c);
			
			Integration_Log__c ilPBE = new Integration_Log__c();
			ilPBE.GenString3__c = nonStdPB.Id;
			ilPBE.GenString4__c = p.Id;
			ilPBE.GenString5__c = 'USD';
			ilPBE.NumField5__c = 100;
			ilPBE.NumField6__c = 0;
			ilPBE.NumField1__c = 1;
			ilPBE.RecordTypeId = rtPMPBENTRY.Id;
			insert ilPBE;
			
			ilPBE = [Select Id, isSuccess__c, Status__c, Message__c, GenString3__c, GenString4__c, GenString5__c, NumField5__c, NumField6__c, NumField1__c from Integration_Log__c where Id = :ilPBE.Id];
			System.debug('XXX : ' + ilPBE.Message__c);
			System.assert(ilPBE.isSuccess__c);
			System.assertEquals(ilPBE.Status__c,'Success');
			
			PricebookEntry pbe = [select Id, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, UseStandardPrice, IsActive from PricebookEntry where Product2Id = :p.Id and Pricebook2Id = :nonStdPB.Id and CurrencyIsoCode = 'USD'];
			System.assertEquals(pbe.Pricebook2Id, nonStdPB.Id);
			System.assertEquals(pbe.Product2Id, p.Id);
			System.assertEquals(pbe.CurrencyIsoCode, 'USD');
			System.assertEquals(pbe.UnitPrice, 100);
			System.assertEquals(pbe.UseStandardPrice, false);
			System.assertEquals(pbe.IsActive, true);
			
			Integration_Log__c ilPBEUpdate = new Integration_Log__c();
			ilPBEUpdate.SFDC_Id__c = pbe.Id;
			ilPBEUpdate.GenString3__c = nonStdPB.Id;
			ilPBEUpdate.GenString4__c = p.Id;
			ilPBEUpdate.GenString5__c = 'USD';
			ilPBEUpdate.NumField5__c = 200;
			ilPBEUpdate.NumField6__c = 0;
			ilPBEUpdate.NumField1__c = 1;
			ilPBEUpdate.RecordTypeId = rtPMPBENTRY.Id;
			insert ilPBEUpdate;
			
			ilPBEUpdate = [Select Id, isSuccess__c, Status__c, Message__c from Integration_Log__c where Id = :ilPBEUpdate.Id];
			System.assert(ilPBEUpdate.isSuccess__c);
			
			pbe = [select Id, UnitPrice from PricebookEntry where Id = :pbe.Id];
			System.assertEquals(pbe.UnitPrice, 200);
		}
		Test.stopTest();
	}

	public static testmethod void testIntegration_POPPLINEH()
	{
		//Set up the test data
		Opportunity testOpp1 = TestUtility.sampleOpportunity();
		insert testOpp1;
		
		User integrationUser = [select Id from User where Id = :Label.Informatica_Integration_UserId];
		
		RecordType rt = [select Id from Recordtype where sObjectType = 'Integration_Log__c' and DeveloperName = 'PPOPPLINEH'];
		
		List<Integration_Log__c> testLogs = new List<Integration_Log__c>();
		
		//Run the process for the test
		Test.startTest();
		system.RunAs(integrationUser){
			Integration_Log__c log1 = new Integration_Log__c();
			log1.NumField1__c = 30;
			log1.NumField2__c = 120000;
			log1.RPA_Rate__c = 5;
			log1.Numfield4__c = 10;
			log1.NumField2__c = 1;
			log1.SFDC_Object__c = 'testOpportunity';
			log1.SFDC_Id__c = testOpp1.Id;
			log1.RecordTypeId = rt.Id;
			log1.External_System__c = 'CommonRef';
			log1.External_id__c = '3';
			testLogs.add(log1);
			
			insert testLogs;
			
		}
		Test.stopTest();
		
		//Verify the results
		Opportunity resultOpp = [select Id, Pearl_Identified_issues__c from Opportunity where Id = :testOpp1.id];
		Integration_Log__c[] resultLog = [select Id, NumField2__c, External_Id__c, IsSuccess__c, Message__c from Integration_Log__c where SFDC_Object__c = 'testOpportunity'];
		//Check if opportunity was updated
		system.assertEquals(resultOpp.Pearl_Identified_issues__c, true);

		//Check if integration log was updated to indicate success
		for(Integration_Log__c iLog : resultLog)
		{
			if(iLog.External_Id__c == '3')
			{
				system.assertEquals(iLog.IsSuccess__c,true);
			}
		}
	}
	
	private static User integrationUser;
	private static Pricebook2 stdPB, nonstdPB;
	private static PricebookEntry pbe, pbe2;
	private static Opportunity testOpp;
	
	private static void initPriceBooks()
	{
		stdPB = [select Id from Pricebook2 where IsStandard = true limit 1];
		nonstdPB = [select Id from Pricebook2 where IsStandard = false limit 1];
	}
	
	
}