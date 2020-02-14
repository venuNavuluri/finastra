/**
 * @File Name          : AddressTriggerHandler.cls
 * @Description        : Handler class for Address Trigger
 * @Author             : Aakanksha Sharma
 * @Group              :
 * @Last Modified By   : Aakanksha Sharma
 * @Last Modified On   : 31/01/2020, 12:30:48
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    31/01/2020   Aakanksha Sharma     Initial Version
 **/
public with sharing class AddressTriggerHandler extends TriggerHandler {
  protected override void afterUpdate() {
    Map<Id, Address__c> newAddrMap = (Map<Id, Address__c>) Trigger.newMap;
    Map<Id, Address__c> oldAddrMap = (Map<Id, Address__c>) Trigger.oldMap;
    updatePrimaryAccounts(newAddrMap, oldAddrMap);
  }
  /**
   * @description RUBX-3978 : When Address is modified, it should update OOTB address fields on Account where it is marked as primary
   * @author Aakanksha Sharma | 31/01/2020
   * @param newAddrMap
   * @param oldAddrMap
   * @return void
   **/
  private void updatePrimaryAccounts(
    Map<Id, Address__c> newAddrMap,
    Map<Id, Address__c> oldAddrMap
  ) {
    Set<Id> addrIds = new Set<Id>();
    List<Account> updatedAccounts = new List<Account>();
    for (Address__c addr : newAddrMap.values()) {
      Address__c oldAddr = oldAddrMap.get(addr.Id);
      if (
        (addr.City__c != oldAddr.City__c ||
        addr.State_Province__c != oldAddr.State_Province__c ||
        addr.Street_Name__c != oldAddr.Street_Name__c ||
        addr.Zip_Postal_Code__c != oldAddr.Zip_Postal_Code__c ||
        addr.Country__c != oldAddr.Country__c) && addr.Account__c != null
      ) {
        addrIds.add(addr.Id);
      }
    }
    if (!addrIds.isEmpty()) {
      List<Account> affectedAccounts = new List<Account>(
        [
          SELECT
            Id,
            BillingStreet,
            BillingCity,
            BillingState,
            BillingPostalCode,
            BillingCountry,
            Primary_Bill_To__c,
            ShippingStreet,
            ShippingCity,
            ShippingState,
            ShippingPostalCode,
            ShippingCountry,
            Primary_Ship_To__c
          FROM Account
          WHERE Primary_Bill_To__c IN :addrIds OR Primary_Ship_To__c IN :addrIds
        ]
      );
      if (!affectedAccounts.isEmpty()) {
        for (Account acc : affectedAccounts) {
          if (
            acc.Primary_Bill_To__c == acc.Primary_Ship_To__c &&
            newAddrMap.containsKey(acc.Primary_Bill_To__c)
          ) {
            Address__c newAddr = newAddrMap.get(acc.Primary_Bill_To__c);
            acc.BillingStreet = newAddr.Street_Name__c;
            acc.BillingCity = newAddr.City__c;
            acc.BillingState = newAddr.State_Province__c;
            acc.BillingPostalCode = newAddr.Zip_Postal_Code__c;
            acc.BillingCountry = newAddr.Country__c;
            acc.ShippingStreet = newAddr.Street_Name__c;
            acc.ShippingCity = newAddr.City__c;
            acc.ShippingState = newAddr.State_Province__c;
            acc.ShippingPostalCode = newAddr.Zip_Postal_Code__c;
            acc.ShippingCountry = newAddr.Country__c;
            updatedAccounts.add(acc);
          } else if (acc.Primary_Bill_To__c != acc.Primary_Ship_To__c) {
            if (
              newAddrMap.containsKey(acc.Primary_Bill_To__c) &&
              !newAddrMap.containsKey(acc.Primary_Ship_To__c)
            ) {
              Address__c newAddr = newAddrMap.get(acc.Primary_Bill_To__c);
              acc.BillingStreet = newAddr.Street_Name__c;
              acc.BillingCity = newAddr.City__c;
              acc.BillingState = newAddr.State_Province__c;
              acc.BillingPostalCode = newAddr.Zip_Postal_Code__c;
              acc.BillingCountry = newAddr.Country__c;
              updatedAccounts.add(acc);
            } else if (
              !newAddrMap.containsKey(acc.Primary_Bill_To__c) &&
              newAddrMap.containsKey(acc.Primary_Ship_To__c)
            ) {
              Address__c newAddr = newAddrMap.get(acc.Primary_Ship_To__c);
              acc.ShippingStreet = newAddr.Street_Name__c;
              acc.ShippingCity = newAddr.City__c;
              acc.ShippingState = newAddr.State_Province__c;
              acc.ShippingPostalCode = newAddr.Zip_Postal_Code__c;
              acc.ShippingCountry = newAddr.Country__c;
              updatedAccounts.add(acc);
            } else if (
              newAddrMap.containsKey(acc.Primary_Bill_To__c) &&
              newAddrMap.containsKey(acc.Primary_Ship_To__c)
            ) {
              Address__c newBillAddr = newAddrMap.get(acc.Primary_Bill_To__c);
              Address__c newShipAddr = newAddrMap.get(acc.Primary_Ship_To__c);
              acc.ShippingStreet = newShipAddr.Street_Name__c;
              acc.ShippingCity = newShipAddr.City__c;
              acc.ShippingState = newShipAddr.State_Province__c;
              acc.ShippingPostalCode = newShipAddr.Zip_Postal_Code__c;
              acc.ShippingCountry = newShipAddr.Country__c;
              acc.BillingStreet = newBillAddr.Street_Name__c;
              acc.BillingCity = newBillAddr.City__c;
              acc.BillingState = newBillAddr.State_Province__c;
              acc.BillingPostalCode = newBillAddr.Zip_Postal_Code__c;
              acc.BillingCountry = newBillAddr.Country__c;
              updatedAccounts.add(acc);
            }
          }
        }

        Database.update(updatedAccounts, true);
      }
    }
  }
}
