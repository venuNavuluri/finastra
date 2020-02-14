/**
 * @File Name          : AccountTriggerHandler.cls
 * @Description        : Trigger Handler Class for Account object
 * @Author             : Aakanksha Sharma
 * @Group              : 
 * @Last Modified By   : Aakanksha Sharma
 * @Last Modified On   : 28/01/2020, 12:12:15
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    27/01/2020   Aakanksha Sharma     Initial Version
**/
public with sharing class AccountTriggerHandler extends TriggerHandler  {
    protected override void beforeUpdate() {
        List<Account> newAcc = (List<Account>) Trigger.new;
        Map<Id, Account> oldAccMap = (Map<Id, Account>) Trigger.oldMap;
        updateAddressFields(newAcc, oldAccMap);       
    }
    /**
    * @description RUBX-1672 : This method update OOTB Billing and Shipping Address fields
    * @author Aakanksha Sharma | 28/01/2020 
    * @param accList 
    * @param oldAccMap 
    * @return void 
    **/
    private void updateAddressFields(
        List<Account> accList,
        Map<Id, Account> oldAccMap
    ) {
        Set<ID> address_Ids = new Set<Id>();
        List<Account> accToUpdate = new List<Account>();
        for (Account acc : accList) {
            Account oldAcc = oldAccMap.get(acc.Id);
            if (( acc.Primary_Bill_To__c != oldAcc.Primary_Bill_To__c) || 
                ( acc.Primary_Ship_To__c != oldAcc.Primary_Ship_To__c)
                )
                {
                    address_Ids.add(acc.Primary_Bill_To__c);
                    address_Ids.add(acc.Primary_Ship_To__c);
                    accToUpdate.add(acc);
                }       
        }
        Map<Id, Address__c> addInfoMap = new Map<Id, Address__c>(
        [
        SELECT ID, City__c, Country__c, State_Province__c, Street_Name__c, Zip_Postal_Code__c
        FROM Address__c
        WHERE id IN :address_Ids
        ]);
        
        for(Account acc : accToUpdate)
        {
            Account oldAcc = oldAccMap.get(acc.Id);
            if (acc.Primary_Bill_To__c != null && acc.Primary_Bill_To__c != oldAcc.Primary_Bill_To__c){
                Address__c addr = addInfoMap.get(acc.Primary_Bill_To__c);
                acc.BillingStreet = addr.Street_Name__c;
                acc.BillingCity = addr.City__c;
                acc.BillingState = addr.State_Province__c;
                acc.BillingPostalCode = addr.Zip_Postal_Code__c;
                acc.BillingCountry = addr.Country__c;
            }
            else if(acc.Primary_Bill_To__c == null)
            {
                acc.BillingStreet = null;
                acc.BillingCity = null;
                acc.BillingState = null;
                acc.BillingPostalCode = null;
                acc.BillingCountry = null;              
            }
            if (acc.Primary_Ship_To__c != null && acc.Primary_Ship_To__c != oldAcc.Primary_Ship_To__c){
                Address__c addr = addInfoMap.get(acc.Primary_Ship_To__c);
                acc.ShippingStreet = addr.Street_Name__c;
                acc.ShippingCity = addr.City__c;
                acc.ShippingState = addr.State_Province__c;
                acc.ShippingPostalCode = addr.Zip_Postal_Code__c;
                acc.ShippingCountry = addr.Country__c;
            }
            else if(acc.Primary_Ship_To__c == null)
            {
                acc.ShippingStreet = null;
                acc.ShippingCity = null;
                acc.ShippingState = null;
                acc.ShippingPostalCode = null;
                acc.ShippingCountry = null;             
            }
            
        }
        
    }
    
}