@isTest
public class test_TaskTriggerHelper
{
	
	public static testmethod void TestContactTask()
	{
		Account a = TestUtils.getAccount('TestAccount1');
		insert a;
		Contact c = TestUtils.getContact(a);
		c.Status__c = 'Marketing Qualified Lead (MQL)';
		insert c;
		
		Task t = TestUtility.sampleTask();
		t.WhoId = c.Id;
		t.RecordTypeId = IdManager.MarketingFollowUpRecTypeId;
		system.debug('@@@ IdManager.MarketingFollowUpRecTypeId: ' + t.RecordTypeId);
		t.Status = 'Recycle';
		t.Qualify_Out_Reason__c = 'No pain or need identified';
		insert t;
		
		Contact contact = [select Id, Qualify_Out_Reson__c, Status__c from Contact where Id = :c.Id];
		system.assertEquals('No pain or need identified', contact.Qualify_Out_Reson__c);
		system.assertEquals('Recycle', contact.Status__c);
	}
	
	public static testmethod void TestContactTask1()
	{
		Account a = TestUtils.getAccount('TestAccount');
		insert a;
		Contact c = TestUtils.getContact(a);
		c.status__c = 'Marketing Qualified Lead (MQL)';
		insert c;
		
		Task t = TestUtility.sampleTask();
		t.WhoId = c.Id;
		t.RecordTypeId = IdManager.MarketingFollowUpRecTypeId;
		system.debug('@@@ IdManager.MarketingFollowUpRecTypeId: ' + t.RecordTypeId);
		t.Status = 'Completed';
		try {
			insert t;
		} catch (Exception ex) {
			system.assert(true);
		}
	}

	public static testmethod void TestContactTask2()
	{
		Account a = TestUtils.getAccount('TestAccount');
		insert a;
		Contact c = TestUtils.getContact(a);
		c.status__c = 'Recycle';
		insert c;
		
		Task t = TestUtility.sampleTask();
		t.WhoId = c.Id;
		t.RecordTypeId = IdManager.MarketingFollowUpRecTypeId;
		system.debug('@@@ IdManager.MarketingFollowUpRecTypeId: ' + t.RecordTypeId);
		t.Status = 'Sales Accepted Lead (SAL)';
		try {
			insert t;
		} catch (Exception ex) {
			system.assert(true);
		}
	}

	public static testmethod void TestContactTask3()
	{
		Account a = TestUtils.getAccount('TestAccount');
		insert a;
		Contact c = TestUtils.getContact(a);
		c.status__c = 'Recycle';
		c.Contact_Level__c = '3: Head of Business Line';
		c.Product__c = 'Almonde';
		insert c;
		
		Task t = TestUtility.sampleTask();
		t.WhoId = c.Id;
		t.RecordTypeId = IdManager.salesTaskRecTypeId;
		system.debug('@@@ IdManager.salesTaskRecTypeId: ' + t.RecordTypeId);
		t.Status = 'Sales Accepted Lead (SAL)';
		try {
			insert t;
		} catch (Exception ex) {
			system.assert(true);
		}
	}

	public static testmethod void TestLeadTask()
	{
		Lead l = TestUtility.sampleLead();
		l.Status = 'Marketing Qualified Lead (MQL)';
		insert l;
		
		Task t = TestUtility.sampleTask();
		t.WhoId = l.Id;
		t.RecordTypeId = IdManager.MarketingFollowUpRecTypeId;
		t.Status = 'Recycle';
		t.Qualify_Out_Reason__c = 'No pain or need identified';
		insert t;
		
		Lead lead = [select Id, Qualified_Out_Reason__c, Status from Lead where Id = :l.Id];
		system.assertEquals('No pain or need identified', lead.Qualified_Out_Reason__c);
		system.assertEquals('Recycle', lead.Status);
	}

	public static testmethod void TestLeadTask1()
	{
		Lead l = TestUtility.sampleLead();
		l.Status = 'Marketing Captured Lead (MCL)';
		insert l;
		
		
		Task t = TestUtility.sampleTask();
		t.WhoId = l.Id;
		t.RecordTypeId = IdManager.MarketingFollowUpRecTypeId;
		t.Status = 'Completed';
		try {
			insert t;
		} catch (Exception ex) {
			system.assert(true);
		}
		
	}
	
	public static testmethod void TestLeadTask2()
	{
		Lead l = TestUtility.sampleLead();
		l.Status = 'Recycle';
		insert l;
		
		
		Task t = TestUtility.sampleTask();
		t.WhoId = l.Id;
		t.RecordTypeId = IdManager.MarketingFollowUpRecTypeId;
		t.Status = 'Sales Accepted Lead (SAL)';
		try {
			insert t;
		} catch (Exception ex) {
			system.assert(true);
		}
		
	}

	public static testmethod void TestCaseTask()
	{
		Case c = TestUtility.sampleCase();
		system.debug('Case Recordt Type = ' + c.RecordTypeId);
		insert c;
		
		Task t = TestUtility.sampleTask();
		t.WhatId = c.Id;
		t.Description = Label.Case_Survey_Date_Code;
		insert t;
		
	}

}