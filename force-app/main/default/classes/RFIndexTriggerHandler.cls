/**
 * @File Name          : RFIndexTriggerHandler.cls
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 22/07/2019, 17:24:47
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    22/07/2019, 15:35:47   Peter Sabry     Initial Version
**/
public without sharing class RFIndexTriggerHandler extends TriggerHandler {
    protected override void afterUpdate(){
        updateCPIUpliftFactor(Trigger.new, (Map<Id,RF_Index__c>)Trigger.oldMap);
    } 

    private void updateCPIUpliftFactor(List<RF_Index__c> newList, Map<Id, RF_Index__c> oldMap) {
        Set<Id> cpisWithChangedRates = new Set<Id>();
        for(RF_Index__c cpi : newList) {
            if(cpi.RF_Index_Rate__c != oldMap.get(cpi.Id).RF_Index_Rate__c) {
                cpisWithChangedRates.add(cpi.Id);
            }
        }
        //Old Model : query CPI Uplift records that have CPI lookup to this CPI record -> recalculate Uplift Factor
        List<Uplift__c> cpiUpliftList = new List<Uplift__c>([SELECT Id, Base_Index__c, Status__c, Uplift_Factor__c, Uplift_Effective_Date__c, 
                        Start_Date__c, Billing_Frequency__c, NCU__c, IUP__c FROM Uplift__c WHERE Base_Index__c in :cpisWithChangedRates]);
        if(cpiUpliftList.size() > 0) {
            UpliftProrataHandler.calcualteUpliftFactor(cpiUpliftList);
            update cpiUpliftList;
        }

        //New Model : query subscription records whose contracts have a CPI lookup to this CPI record -> recalculate Uplift Factor
        List<SBQQ__Subscription__c> subscriptionsList = new List<SBQQ__Subscription__c>([SELECT Id, Uplift_Calc_Type__c, CPI_Uplift_Review_Date__c, 
                        Uplift_Effective_Date__c, SBQQ__BillingFrequency__c, Net_Customer_Uplift__c, Uplift_Factor__c, Interim_Uplift_Percentage__c 
                        FROM SBQQ__Subscription__c WHERE SBQQ__Contract__r.CPI__c in :cpisWithChangedRates AND SBQQ__Contract__r.ATG_Model__c = true]);
        
        if(subscriptionsList.size() > 0) {
            subscriptionsList = UpliftProrataHandler.calcualteUpliftFactorForSubs(subscriptionsList);
            update subscriptionsList;
        }
    }
}