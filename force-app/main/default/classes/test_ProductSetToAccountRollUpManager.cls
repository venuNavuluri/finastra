@isTest
public with sharing class test_ProductSetToAccountRollUpManager {
	
	private static Account setUpAccount()
	{
		Account testAccount = TestUtility.sampleAccount();
		insert testAccount;
		return testAccount;
				
	} 
	
	private static Product_Set__c setUpProductSet(Id acctId)
	{
		Product_Set__c ps1 = TestUtility.sampleProductSet(acctId);
		ps1.Name = 'Almonde';
		insert ps1;
		system.debug('test_ProductSetToAccountRollUpManager ps1='+ps1);
		return ps1;
	}

	private static System__c setUpSystem(Id acctId)
	{
		System__c sys1 = TestUtility.sampleSystem(acctId);
		sys1.Environment2__c = 'PROD';
		insert sys1;
		system.debug('test_ProductSetToAccountRollUpManager sys1='+sys1);
		return sys1;		
	}	
	
	private static Entitlement__c setUpEntitlement(Id acctId, Id sysId, Id psId)
	{
		Entitlement__c ent1 = TestUtility.sampleEntitlement(acctId, sysId);
		ent1.Product_Set__c = psId;
		insert ent1;
		system.debug('test_ProductSetToAccountRollUpManager ent1='+ent1);
		return ent1;
	}
	
	public static testmethod void test1()
	{
		Test.startTest();
			Account testAccount = setUpAccount();
			Product_Set__c ps1 = setUpProductSet(testAccount.Id);
			//Due to no entitlement, assert that product and business group are still null
			Account resultAccount = [select Id, Family_Group__c from Account where Id = :testAccount.Id];
			System.assertEquals(null, resultAccount.Family_Group__c);
			system.debug('test_ProductSetToAccountRollUpManager resultAccount=' + resultAccount.Id + ' ' + resultAccount.Family_Group__c);
		Test.stopTest();
	}

	public static testmethod void test2()
	{
		Account testAccount = setUpAccount();
		Product_Set__c ps1 = setUpProductSet(testAccount.Id);
		//Due to no entitlement, assert that product and business group are still null
		Test.startTest();
			System__c sys1 = setUpSystem(testAccount.Id);
			Entitlement__c ent1 = setUpEntitlement(testAccount.Id, sys1.Id, ps1.Id);
			//Should have product and business group listing now
			Account resultAccount = [select Id, Family_Group__c from Account where Id = :testAccount.Id];
			system.debug('test_ProductSetToAccountRollUpManager resultAccount=' + resultAccount.Id + ' ' + resultAccount.Family_Group__c);
			System.assertEquals('Almonde', resultAccount.Family_Group__c);
		Test.stopTest();
	}

	public static testmethod void test3()
	{
		Account testAccount = setUpAccount();
		Product_Set__c ps1 = setUpProductSet(testAccount.Id);
		System__c sys1 = setUpSystem(testAccount.Id);
		Entitlement__c ent1 = setUpEntitlement(testAccount.Id, sys1.Id, ps1.Id);
		Test.startTest();
			sys1.Environment2__c = 'TEST';
			update sys1;
			
			Account result3Account = [select Id, Family_Group__c from Account where Id = :testAccount.Id];
			System.assertEquals(null, result3Account.Family_Group__c);
		Test.stopTest();
	}

	public static testmethod void test4()
	{
		Account testAccount = setUpAccount();
		Product_Set__c ps1 = setUpProductSet(testAccount.Id);
		System__c sys1 = setUpSystem(testAccount.Id);
		Entitlement__c ent1 = setUpEntitlement(testAccount.Id, sys1.Id, ps1.Id);

		sys1.Environment2__c = 'TEST';
		update sys1;
		Account result4Account = [select Id, Family_Group__c from Account where Id = :testAccount.Id];
		System.assertEquals(null, result4Account.Family_Group__c);
	
		Test.startTest();
			sys1.Environment2__c = 'PROD';
			update sys1;
			
			result4Account = [select Id, Family_Group__c from Account where Id = :testAccount.Id];
			System.assertEquals('Almonde', result4Account.Family_Group__c);
		Test.stopTest();
	}
	
	public static testmethod void test5()
	{
		Account testAccount = setUpAccount();
		Product_Set__c ps1 = setUpProductSet(testAccount.Id);
		System__c sys1 = setUpSystem(testAccount.Id);
		Entitlement__c ent1 = setUpEntitlement(testAccount.Id, sys1.Id, ps1.Id);

		sys1.Environment2__c = 'PROD';
		update sys1;
		Test.startTest();
			ent1.Status__c = 'Inactive';
			update ent1;
			
			Account result5Account = [select Id, Family_Group__c from Account where Id = :testAccount.Id];
			System.assertEquals(null, result5Account.Family_Group__c);
		Test.stopTest();
	}
	
	public static testmethod void test6()
	{
		Account testAccount = setUpAccount();
		Product_Set__c ps1 = setUpProductSet(testAccount.Id);
		System__c sys1 = setUpSystem(testAccount.Id);
		Entitlement__c ent1 = setUpEntitlement(testAccount.Id, sys1.Id, ps1.Id);

		sys1.Environment2__c = 'PROD';
		update sys1;
		Account result6Account = [select Id, Family_Group__c from Account where Id = :testAccount.Id];
		system.debug('test_ProductSetToAccountRollUpManager 0. result6Account=' + result6Account.Id + ' ' + result6Account.Family_Group__c);
		Test.startTest();
			ent1.Status__c = 'Active';
			update ent1;
			
			Product_Set__c ps2 = new Product_Set__c();
			ps2.Name = 'Kondor';
			ps2.Account__c = testAccount.Id;
			insert ps2;
			
			Entitlement__c ent2 = new Entitlement__c();
			ent2.Account__c = testAccount.Id;
			ent2.Status__c = 'Active';
			ent2.Product_Set__c = ps2.Id;
			ent2.system__c = sys1.Id;
			insert ent2;
			
			result6Account = [select Id, Family_Group__c from Account where Id = :testAccount.Id];
			system.debug('test_ProductSetToAccountRollUpManager 1. result6Account=' + result6Account.Id + ' ' + result6Account.Family_Group__c);
			System.assert(result6Account.Family_Group__c.contains('Kondor'));
			System.assert(result6Account.Family_Group__c.contains('Almonde'));
		Test.stopTest();
	}
	
	public static testmethod void test7()
	{
		Account testAccount = setUpAccount();
		Product_Set__c ps1 = setUpProductSet(testAccount.Id);
		System__c sys1 = setUpSystem(testAccount.Id);
		Entitlement__c ent1 = setUpEntitlement(testAccount.Id, sys1.Id, ps1.Id);

		ent1.Status__c = 'Active';
		update ent1;
		
		Product_Set__c ps2 = new Product_Set__c();
		ps2.Name = 'Kondor';
		ps2.Account__c = testAccount.Id;
		insert ps2;
		
		Entitlement__c ent2 = new Entitlement__c();
		ent2.Account__c = testAccount.Id;
		ent2.Status__c = 'Active';
		ent2.Product_Set__c = ps2.Id;
		ent2.system__c = sys1.Id;
		insert ent2;
		
		Test.startTest();
			delete ent2;
			
			Account result7Account = [select Id, Family_Group__c from Account where Id = :testAccount.Id];
			System.assertEquals('Almonde', result7Account.Family_Group__c);
			System.assert(!result7Account.Family_Group__c.contains('Kondor'));
		Test.stopTest();
	}
	
	public static testmethod void test8()
	{
		Account testAccount = setUpAccount();
		Product_Set__c ps1 = setUpProductSet(testAccount.Id);
		System__c sys1 = setUpSystem(testAccount.Id);
		Entitlement__c ent1 = setUpEntitlement(testAccount.Id, sys1.Id, ps1.Id);

		ent1.Status__c = 'Active';
		update ent1;
		
		Product_Set__c ps2 = new Product_Set__c();
		ps2.Name = 'Kondor';
		ps2.Account__c = testAccount.Id;
		insert ps2;
		
		Entitlement__c ent2 = new Entitlement__c();
		ent2.Account__c = testAccount.Id;
		ent2.Status__c = 'Active';
		ent2.Product_Set__c = ps2.Id;
		ent2.system__c = sys1.Id;
		insert ent2;
		
		delete ent2;
		Test.startTest();
			delete ps1;
			Account result8Account = [select Id, Family_Group__c from Account where Id = :testAccount.Id];
			System.assertEquals(null, result8Account.Family_Group__c);
		Test.stopTest();
	}
	
}