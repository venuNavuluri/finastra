trigger ContractAssetTrigger on Contract_Asset__c (after insert, after update, after delete)
{
    List<Contract_Asset__c> param = trigger.isDelete ? trigger.old : trigger.new;

  /*     RUMContractAssetToClientAsset ruCa2ClA = new RUMContractAssetToClientAsset(param, trigger.oldMap);
    ruCa2ClA.DoRollUp();
    
    RUMContractAssetToAccount rumCa2Acct = new RUMContractAssetToAccount(param, trigger.oldMap);
    rumCa2Acct.DoRollUp();
    
    RUMContractAssetToBillingGroup rumCa2Bg = new RUMContractAssetToBillingGroup(param, trigger.oldMap);
    rumCa2Bg.DoRollUp();

    //AK - adding below logic so that roll up only happens if the relevant field values are modified and there is need for the roll up  
    if(trigger.isUpdate){
        param = new list<Contract_Asset__c>();
        for(Contract_Asset__c ca : trigger.new){
            if(ca.CA_CY_Billing_Current_Amount__c != trigger.oldMap.get(ca.Id).CA_CY_Billing_Current_Amount__c || 
                ca.CA_CY_Billing_Previous_Amount__c != trigger.oldMap.get(ca.Id).CA_CY_Billing_Previous_Amount__c){
                
                param.add(ca);
            }
        }
        if(param != null && param.size() > 0){
            system.debug('param = ' + param);
            RUMContractAssetToProduct rumCa2Prod = new RUMContractAssetToProduct(param, trigger.oldMap);
            rumCa2Prod.DoRollUp();
        }
    } else {
        RUMContractAssetToProduct rumCa2Prod = new RUMContractAssetToProduct(param, trigger.oldMap);
        rumCa2Prod.DoRollUp();
    } */
}