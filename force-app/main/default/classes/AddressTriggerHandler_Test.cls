/**
 * @File Name          : AddressTriggerHandler_Test.cls
 * @Description        : Test class for all Address Trigger Handler methods
 * @Author             : Aakanksha Sharma
 * @Group              :
 * @Last Modified By   : Aakanksha Sharma
 * @Last Modified On   : 31/01/2020, 13:26:50
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    28/01/2020   Aakanksha Sharma     Initial Version
 **/
@istest
public with sharing class AddressTriggerHandler_Test {
  public static final String TEST_STREET = 'Test Street';
  /**
   * @description Account OOTB Billing and Shipping fields should get updated
   * @author Aakanksha Sharma | 31/01/2020
   * @return testMethod
   **/
  public static testMethod void updatePrimaryAccounts_PositiveSingleTest1() {
    Account acc = TestDataFactory.createAccounts(1, true)[0];
    Address__c addr = TestDataFactory.createAccountAddresses(
      acc.ID,
      1,
      true
    )[0];
    acc.Primary_Bill_To__c = addr.id;
    acc.Primary_Ship_To__c = addr.id;
    update acc;
    // Perform test
    Test.startTest();
    addr.Street_Name__c = TEST_STREET;
    update addr;
    Test.stopTest();

    List<Account> updatedAcc = new List<Account>(
      [SELECT id, BillingStreet, ShippingStreet FROM Account WHERE id = :acc.id]
    );

    System.assertEquals(TEST_STREET, updatedAcc[0].ShippingStreet);
    System.assertEquals(TEST_STREET, updatedAcc[0].BillingStreet);
  }

  /**
   * @description Account OOTB Billing fields should get updated
   * @author Aakanksha Sharma | 31/01/2020
   * @return testMethod
   **/
  public static testMethod void updatePrimaryAccounts_PositiveSingleTest2() {
    Account acc = TestDataFactory.createAccounts(1, true)[0];
    Address__c addr = TestDataFactory.createAccountAddresses(
      acc.ID,
      1,
      true
    )[0];
    Address__c addr1 = TestDataFactory.createAccountAddresses(
      acc.ID,
      1,
      true
    )[0];
    acc.Primary_Bill_To__c = addr.id;
    acc.Primary_Ship_To__c = addr1.id;
    update acc;
    // Perform test
    Test.startTest();
    addr.Street_Name__c = TEST_STREET;
    update addr;
    Test.stopTest();

    List<Account> updatedAcc = new List<Account>(
      [SELECT id, BillingStreet, ShippingStreet FROM Account WHERE id = :acc.id]
    );

    System.assertEquals(addr1.Street_Name__c, updatedAcc[0].ShippingStreet);
    System.assertEquals(TEST_STREET, updatedAcc[0].BillingStreet);
  }
  /**
   * @description Account OOTB Shipping fields should get updated
   * @author Aakanksha Sharma | 31/01/2020
   * @return testMethod
   **/
  public static testMethod void updatePrimaryAccounts_PositiveSingleTest3() {
    Account acc = TestDataFactory.createAccounts(1, true)[0];
    Address__c addr = TestDataFactory.createAccountAddresses(
      acc.ID,
      1,
      true
    )[0];
    Address__c addr1 = TestDataFactory.createAccountAddresses(
      acc.ID,
      1,
      true
    )[0];
    acc.Primary_Bill_To__c = addr.id;
    acc.Primary_Ship_To__c = addr1.id;
    update acc;
    // Perform test
    Test.startTest();
    addr1.Street_Name__c = TEST_STREET;
    update addr1;
    Test.stopTest();

    List<Account> updatedAcc = new List<Account>(
      [SELECT id, BillingStreet, ShippingStreet FROM Account WHERE id = :acc.id]
    );

    System.assertEquals(addr.Street_Name__c, updatedAcc[0].BillingStreet);
    System.assertEquals(TEST_STREET, updatedAcc[0].ShippingStreet);
  }

  /**
   * @description Account OOTB Billing and Shipping fields should get updated
   * @author Aakanksha Sharma | 31/01/2020
   * @return testMethod
   **/
  public static testMethod void updatePrimaryAccounts_PositiveSingleTest4() {
    Account acc = TestDataFactory.createAccounts(1, true)[0];
    Address__c addr = TestDataFactory.createAccountAddresses(
      acc.ID,
      1,
      true
    )[0];
    Address__c addr1 = TestDataFactory.createAccountAddresses(
      acc.ID,
      1,
      true
    )[0];
    acc.Primary_Bill_To__c = addr.id;
    acc.Primary_Ship_To__c = addr1.id;
    update acc;
    List<Address__c> addrList = new List<Address__c>();
    // Perform test
    Test.startTest();
    addr1.Street_Name__c = TEST_STREET;
    addrList.add(addr1);
    addr.Street_Name__c = TEST_STREET;
    addrList.add(addr);
    update addrList;
    Test.stopTest();

    List<Account> updatedAcc = new List<Account>(
      [SELECT id, BillingStreet, ShippingStreet FROM Account WHERE id = :acc.id]
    );

    System.assertEquals(TEST_STREET, updatedAcc[0].BillingStreet);
    System.assertEquals(TEST_STREET, updatedAcc[0].ShippingStreet);
  }
  /**
   * @description Method to test if OOTB address fields on bulk accounts are updated correctly, on updating Bulk Addresses
   * @author Aakanksha Sharma | 28/01/2020
   * @return testMethod
   **/
  public static testMethod void updatePrimaryAccounts_BulkifiedTest() {
    List<Account> accList = TestDataFactory.createAccounts(
      TestDataFactory.BULK_TEST_RECORD_COUNT,
      true
    );
    List<Address__c> addrList = new List<Address__c>();
    Map<Id, Id> accAddrMap = new Map<Id, Id>();
    List<Account> accToUpdate = new List<Account>();
    List<Address__c> addrToUpdate = new List<Address__c>();
    for (Account acc : accList) {
      Address__c addr = TestDataFactory.createAccountAddresses(
        acc.ID,
        1,
        false
      )[0];
      addrList.add(addr);
    }

    insert addrList;

    for (Address__c addr : [SELECT Id, Account__c FROM Address__c]) {
      accAddrMap.put(addr.Account__c, addr.Id);
    }
    for (Account acc : accList) {
      acc.Primary_Bill_To__c = accAddrMap.get(acc.Id);
      acc.Primary_Ship_To__c = accAddrMap.get(acc.Id);
      accToUpdate.add(acc);
    }
    update accToUpdate;
    Test.startTest();
    for (Address__c addr : addrList) {
      addr.Street_Name__c = TEST_STREET;
      addrToUpdate.add(addr);
    }
    update addrToUpdate;
    Test.stopTest();
    System.assertEquals(
      TestDataFactory.BULK_TEST_RECORD_COUNT,
      [
        SELECT COUNT()
        FROM Account
        WHERE ShippingStreet = :TEST_STREET AND BillingStreet = :TEST_STREET
      ]
    );
  }
}
