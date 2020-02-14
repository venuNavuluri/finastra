/**
 * @File Name          : AccountTriggerHandler_Test.cls
 * @Description        : Test class for all Account Trigger Handler methods
 * @Author             : Aakanksha Sharma
 * @Group              :
 * @Last Modified By   : Aakanksha Sharma
 * @Last Modified On   : 28/01/2020, 18:21:50
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    28/01/2020   Aakanksha Sharma     Initial Version
 **/
@istest
public with sharing class AccountTriggerHandler_Test {
  /**
   * @description Method to test if OOTB address fields are updated based on Address lookup fields on Account
   * @author Aakanksha Sharma | 28/01/2020
   * @return testMethod
   **/
  public static testMethod void updateAddressFields_PositiveSingleTest() {
    Account acc = TestDataFactory.createAccounts(1, true)[0];
    Address__c addr = TestDataFactory.createAccountAddresses(
      acc.ID,
      1,
      true
    )[0];
    // Perform test
    Test.startTest();
    acc.Primary_Bill_To__c = addr.id;
    acc.Primary_Ship_To__c = addr.id;
    update acc;
    Test.stopTest();

    List<Account> insertedAcc = new List<Account>(
      [
        SELECT
          id,
          BillingCity,
          BillingState,
          BillingPostalCode,
          BillingCountry,
          ShippingCity,
          ShippingState,
          ShippingPostalCode,
          ShippingCountry
        FROM Account
        WHERE id = :acc.id
      ]
    );

    System.assertEquals(insertedAcc[0].BillingCity, addr.City__c);
    System.assertEquals(insertedAcc[0].BillingState, addr.State_Province__c);
    System.assertEquals(
      insertedAcc[0].BillingPostalCode,
      addr.Zip_Postal_Code__c
    );
    System.assertEquals(insertedAcc[0].BillingCountry, addr.Country__c);
    System.assertEquals(insertedAcc[0].ShippingCity, addr.City__c);
    System.assertEquals(insertedAcc[0].ShippingState, addr.State_Province__c);
    System.assertEquals(
      insertedAcc[0].ShippingPostalCode,
      addr.Zip_Postal_Code__c
    );
    System.assertEquals(insertedAcc[0].ShippingCountry, addr.Country__c);
  }
  /**
   * @description Method to test if OOTB address fields on bulk accounts are updated correctly
   * @author Aakanksha Sharma | 28/01/2020
   * @return testMethod
   **/
  public static testMethod void updateAddressFields_BulkifiedTest() {
    List<Account> accList = TestDataFactory.createAccounts(
      TestDataFactory.BULK_TEST_RECORD_COUNT,
      true
    );
    List<Address__c> addrList = new List<Address__c>();
    Map<Id, Id> accAddrMap = new Map<Id, Id>();
    List<Account> accToUpdate = new List<Account>();

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
    Test.startTest();
    for (Account acc : accList) {
      acc.Primary_Bill_To__c = accAddrMap.get(acc.Id);
      acc.Primary_Ship_To__c = accAddrMap.get(acc.Id);
      accToUpdate.add(acc);
    }
    update accToUpdate;
    Test.stopTest();
    System.assertEquals(
      TestDataFactory.BULK_TEST_RECORD_COUNT,
      [
        SELECT COUNT()
        FROM Account
        WHERE ShippingCountry != null AND BillingCountry != null
      ]
    );
  }
}
