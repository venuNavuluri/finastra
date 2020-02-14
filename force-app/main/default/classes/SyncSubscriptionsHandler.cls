/**
 * @File Name          : SyncSubscriptionsHandler.cls
 * @Description        : 
 * @Author             : venu.navuluri@finastra.com
 * @Group              : 
 * @Last Modified By   : venu.navuluri@finastra.com
 * @Last Modified On   : 04/06/2019, 10:58:54
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    04/06/2019, 10:58:54   venu.navuluri@finastra.com     Initial Version
**/
public class SyncSubscriptionsHandler {
    public static void SyncSubsFromContract(Set<Id> contractIds) {
        Map<Id,SBQQ__Subscription__c> subscriptionsMap = new Map<Id,SBQQ__Subscription__c>();
        
        List<SBQQ__Subscription__c> subscriptionsList = new List<SBQQ__Subscription__c>(
            [SELECT Id, 
             SBQQ__Contract__c,
             SBQQ__Contract__r.Fixed_Billing_Day__c, 
             SBQQ__Contract__r.Fixed_Billing_Month__c, 
             SBQQ__Contract__r.Billing_Frequency__c, 
             SBQQ__Contract__r.Billing_Advance_Days__c, 
             SBQQ__Contract__r.Billing_Arrears_Days__c,
             Billing_Day__c, 
             Billing_Month__c, 
             SBQQ__BillingFrequency__c, 
             SBQQ__BillingType__c,
             SO_Generation_Advance__c,
             Contract_Term_In_Months__c,
             SBQQ__NetPrice__c,
             SO_Amount__c,
             /*CPI Uplift Fields */
             SBQQ__Contract__r.Uplift_Calc_Type__c,
             SBQQ__Contract__r.Uplift_Application_Date__c,
             SBQQ__Contract__r.Uplift_Annual_Effective_Date__c,
             SBQQ__Contract__r.RLF_Earliest_review_Date__c,
             Uplift_Calc_Type__c,
             Uplift_Effective_Date__c,
             Uplift_Application_Date__c,
             CPI_Uplift_Review_Date__c,
             /*RLFGoLiveDate Fields - Moved From ContractTriggerMethods*/
             SBQQ__Contract__r.Recurring_Fees_Start_Planned__c,
             Next_Billing_Date__c,
             Next_SO_generation_Date__c ,
             Billing_Group__c
             FROM SBQQ__Subscription__c 
             WHERE SBQQ__Contract__c in :contractIds 
             AND Sales_Order_Type__c = 'RLF']
        );
        
        //Subscriptions List to update Billing Group Plan Date - Moved From ContractTriggerMethods
        List<SBQQ__Subscription__c> planList = new List<SBQQ__Subscription__c>();
        
        for(SBQQ__Subscription__c sub : subscriptionsList) {
            SBQQ__Subscription__c subToUpdate = new SBQQ__Subscription__c(Id = sub.Id, Billing_Group__c = sub.Billing_Group__c);
                
            if(sub.SBQQ__Contract__r.Fixed_Billing_Day__c != null) {
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.Billing_Day__c = sub.SBQQ__Contract__r.Fixed_Billing_Day__c;
                subscriptionsMap.put(subToUpdate.Id, subToUpdate);
            }
            if(!string.isEmpty(sub.SBQQ__Contract__r.Fixed_Billing_Month__c)) {
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.Billing_Month__c = sub.SBQQ__Contract__r.Fixed_Billing_Month__c;
                subscriptionsMap.put(subToUpdate.Id, subToUpdate);
            }
            if(!string.isEmpty(sub.SBQQ__Contract__r.Billing_Frequency__c)) {
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.SBQQ__BillingFrequency__c = sub.SBQQ__Contract__r.Billing_Frequency__c;
                
                decimal contractTermInMonths = (sub.Contract_Term_In_Months__c != null) ? sub.Contract_Term_In_Months__c : 12; //If Terms is empty, then use default value of 12 
                decimal netPrice = (sub.SBQQ__NetPrice__c != null) ? sub.SBQQ__NetPrice__c : 0; //If Net Price is empty, then use default value of 0 
                decimal netPricePerTerm = netPrice / contractTermInMonths; //Net Price per month
                 
                subToUpdate.SO_Amount__c = calculateSOAmount(sub.SBQQ__Contract__r.Billing_Frequency__c, netPricePerTerm);
                
                subscriptionsMap.put(subToUpdate.Id, subToUpdate);
            }
            
            if(sub.SBQQ__BillingType__c == 'Advance' && sub.SBQQ__Contract__r.Billing_Advance_Days__c != null) {
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.SO_Generation_Advance__c = sub.SBQQ__Contract__r.Billing_Advance_Days__c;
                subscriptionsMap.put(subToUpdate.Id, subToUpdate);
            }
            else if(sub.SBQQ__BillingType__c == 'Arrears' && sub.SBQQ__Contract__r.Billing_Arrears_Days__c != null) {
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.SO_Generation_Advance__c = sub.SBQQ__Contract__r.Billing_Arrears_Days__c;
                subscriptionsMap.put(subToUpdate.Id, subToUpdate);
            }
            
            //CPI Uplift Fields
            if(!string.isEmpty(sub.SBQQ__Contract__r.Uplift_Calc_Type__c)){
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.Uplift_Calc_Type__c = sub.SBQQ__Contract__r.Uplift_Calc_Type__c;
                subscriptionsMap.put(subToUpdate.Id, subToUpdate);
            }
            if(sub.SBQQ__Contract__r.Uplift_Annual_Effective_Date__c != null){
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.Uplift_Effective_Date__c = sub.SBQQ__Contract__r.Uplift_Annual_Effective_Date__c;
                subscriptionsMap.put(subToUpdate.Id, subToUpdate);
            }
            if(sub.SBQQ__Contract__r.Uplift_Application_Date__c != null){
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.Uplift_Application_Date__c = sub.SBQQ__Contract__r.Uplift_Application_Date__c;
                subscriptionsMap.put(subToUpdate.Id, subToUpdate);
            }
            if(sub.SBQQ__Contract__r.RLF_Earliest_review_Date__c != null){
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.CPI_Uplift_Review_Date__c = sub.SBQQ__Contract__r.RLF_Earliest_review_Date__c;
                subscriptionsMap.put(subToUpdate.Id, subToUpdate);
            }
            
            //RLFGoLiveDate Fields - Moved From ContractTriggerMethods
            if(sub.SBQQ__Contract__r.Recurring_Fees_Start_Planned__c != null){
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.RF_Start_Planned_Date__c = sub.SBQQ__Contract__r.Recurring_Fees_Start_Planned__c;
                subToUpdate.Next_Billing_Date__c = sub.SBQQ__Contract__r.Recurring_Fees_Start_Planned__c;                 
                
                decimal generationAdvanceDays = sub.SO_Generation_Advance__c;
                if(subToUpdate.SO_Generation_Advance__c != null) {
                    generationAdvanceDays = subToUpdate.SO_Generation_Advance__c; //Use updated Value
                }
                
                if(sub.SBQQ__BillingType__c == 'Advance'){
                    subToUpdate.Next_SO_generation_Date__c = subToUpdate.Next_Billing_Date__c.addDays(-(Integer) generationAdvanceDays);
                } else if(sub.SBQQ__BillingType__c == 'Arrears'){
                    subToUpdate.Next_SO_generation_Date__c = subToUpdate.Next_Billing_Date__c.addDays((Integer) generationAdvanceDays);
                } if(sub.Next_SO_generation_Date__c < System.today()) {
                    subToUpdate.Next_SO_generation_Date__c = System.today().addDays(1);
                }
                planList.add(subToUpdate);
            }
        }
        // Update Next_Billing_Date__c, Next_SO_Generation_Date__c on billing group - Moved From ContractTriggerMethods
        Map<Id, List<Date>> bg_dates_map = SO_SubscriptionsGrouping.sortBillingDates(planList);
        List<Billing_Group__c> bgList = new List<Billing_Group__c>(); 
        for(Billing_Group__c bg: [SELECT Id, Next_Billing_Date__c, Next_SO_Generation_Date__c FROM Billing_Group__c WHERE Id IN: bg_dates_map.keySet()]){
            bg.Next_Billing_Date__c = bg_dates_map.get(bg.Id)[0];
            bg.Next_SO_Generation_Date__c = bg_dates_map.get(bg.Id)[1];
            bgList.add(bg);
        }        
        if(bgList.size() > 0){
            update bgList;
        }
        
        if(!subscriptionsMap.isEmpty()) {
            update subscriptionsMap.values();
        }
    }

    public static void SyncSubsFromBillingGroup(Set<Id> bgIds) {
        //Query Billing Group Subs
        Map<Id,SBQQ__Subscription__c> subscriptionsMap = new Map<Id,SBQQ__Subscription__c>();
        
        //Set Subs fields to contract fields
        for(SBQQ__Subscription__c sub : [ Select Id,
                                        Billing_Day__c,
                                        Billing_Month__c,
                                        Next_Billing_Date__c,
                                        SBQQ__BillingType__c,
                                        SBQQ__BillingFrequency__c,
                                        SO_Generation_Advance__c,
                                        Next_SO_generation_Date__c,
                                        Contract_Term_In_Months__c,
                                        SBQQ__NetPrice__c,
                                        SO_Amount__c,
                                        Billing_Group__r.Billing_Day__c,
                                        Billing_Group__r.Billing_Frequency__c,
                                        Billing_Group__r.Billing_Month__c,
                                        Billing_Group__r.Next_Billing_Date__c,
                                        Billing_Group__r.Billing_Type__c,
                                        Billing_Group__r.SO_Advance_Date__c,
                                        Billing_Group__r.Next_SO_generation_Date__c
                                        FROM SBQQ__Subscription__c 
                                        WHERE Billing_Group__c IN:bgIds
                                        AND Sales_Order_Type__c = 'RLF']) {
                                            
            SBQQ__Subscription__c subToUpdate = new SBQQ__Subscription__c(Id = sub.Id);
            //Set subscription values
            if(sub.Billing_Group__r.Billing_Day__c != null) {
                subToUpdate.Billing_Day__c = sub.Billing_Group__r.Billing_Day__c;
                subscriptionsMap.put(subToUpdate.Id,subToUpdate);
            }
            if(sub.Billing_Group__r.Billing_Month__c != null) {
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate; 
                subToUpdate.Billing_Month__c = sub.Billing_Group__r.Billing_Month__c;
                subscriptionsMap.put(subToUpdate.Id,subToUpdate);
            }
            if(sub.Billing_Group__r.Next_Billing_Date__c != null) {
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.Next_Billing_Date__c = sub.Billing_Group__r.Next_Billing_Date__c;
                subscriptionsMap.put(subToUpdate.Id,subToUpdate);
            }
            if(sub.Billing_Group__r.Billing_Type__c != null) {
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.SBQQ__BillingType__c = sub.Billing_Group__r.Billing_Type__c;
                subscriptionsMap.put(subToUpdate.Id,subToUpdate);
            }
            if(sub.Billing_Group__r.Next_SO_generation_Date__c != null) {
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.Next_SO_generation_Date__c = sub.Billing_Group__r.Next_SO_generation_Date__c;
                subscriptionsMap.put(subToUpdate.Id,subToUpdate);  
            }
            if(sub.Billing_Group__r.SO_Advance_Date__c != null) {
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.SO_Generation_Advance__c = sub.Billing_Group__r.SO_Advance_Date__c;
                subscriptionsMap.put(subToUpdate.Id,subToUpdate);  
            }
            if(sub.Billing_Group__r.Billing_Frequency__c != null) {
                subToUpdate = subscriptionsMap.containsKey(sub.Id)? subscriptionsMap.get(sub.Id):subToUpdate;
                subToUpdate.SBQQ__BillingFrequency__c = sub.Billing_Group__r.Billing_Frequency__c;
                
                decimal contractTermInMonths = (sub.Contract_Term_In_Months__c != null) ? sub.Contract_Term_In_Months__c : 12; //If Terms is empty, then use default value of 12 
                decimal netPricePerTerm = sub.SBQQ__NetPrice__c / contractTermInMonths; //Net Price per month
                
                subToUpdate.SO_Amount__c = calculateSOAmount(sub.Billing_Group__r.Billing_Frequency__c, netPricePerTerm);
                
                subscriptionsMap.put(subToUpdate.Id,subToUpdate);
            }
        }
        if(!subscriptionsMap.isEmpty()) {
            update subscriptionsMap.values();
        }
    }

    //Recalculate SO Amount based on Billing Frequency
    public static decimal calculateSOAmount(string billingFrequency, decimal netPricePerTerm) {
        switch on billingFrequency {
            when 'Monthly' {
                return netPricePerTerm;
            }   
            when 'Quarterly' { // Every 3 months
                return netPricePerTerm * 3;
            }
            when 'Semiannual' { // Every 6 months
                return netPricePerTerm * 6;
            }
            when 'Annual' {  // Every 1 year
                return netPricePerTerm * 12;
            }
            when 'Biennial' { // Every 2 years
                return netPricePerTerm * 24;
            }
            when 'Triennial' { // Every 3 years
                return netPricePerTerm * 36;
            }
            when 'Quinquennial' { // Every 5 years
                return netPricePerTerm * 60;
            }
        }

        return netPricePerTerm;
    }
}