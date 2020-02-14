/**
 * @File Name          : SubscriptionTriggerMethods.cls
 * @Description        : 
 * @Author             : venu.navuluri@finastra.com
 * @Group              : 
 * @Last Modified By   : venu.navuluri@finastra.com
 * @Last Modified On   : 04/06/2019, 10:58:55
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    04/06/2019, 10:58:55   venu.navuluri@finastra.com     Initial Version
 * 1.1    10/06/2019,            Gaetan Barbeu                  REQ-2916 - Update soAmountUpdate()
**/
public class SubscriptionTriggerMethods{
    
    @testVisible
    private static Map<Id, Decimal> subscriptionIds = new Map<Id, Decimal>();
    
    public static void assignSOadvDaysToSubs(List<SBQQ__Subscription__c> newSubsMap, List<SBQQ__Subscription__c> oldSubsMap, boolean isInsert){
        SO_Advance_Day__mdt soAdvRecord = CustomMetaDataUtils.getSoAdvDayRecord();  
        if(soAdvRecord == null)
            return;
        system.debug('size of trig list =>'+newSubsMap);
        for(SBQQ__Subscription__c sub: newSubsMap){
            if((sub.SO_Generation_Advance__c == null)){
                if(sub.SBQQ__BillingType__c == 'Advance'){
                    sub.SO_Generation_Advance__c = soAdvRecord.No_of_Advance_Days__c;
                } else if(sub.SBQQ__BillingType__c == 'Arrears'){
                    sub.SO_Generation_Advance__c = soAdvRecord.No_of_Arrears_Days__c;                        
                }
            }
        }
    }
    
    public static void calculateNetPrice(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        system.debug('==> SubscriptionTriggerMethods calculateNetPrice begin');
        Map<Id, SBQQ__Subscription__c> eligibleSubscriptions = getSubscriptionsWithTransactionsChange((List<SBQQ__Subscription__c>) newMap.values(), (Map<Id, SBQQ__Subscription__c>) oldMap);
        if(eligibleSubscriptions.isEmpty()) return;
        Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>> subscriptionsWithTiers = fetchSubscriptionsWithTiers(eligibleSubscriptions);
        processSubscriptionsForNetPrice(subscriptionsWithTiers);
        system.debug('==> SubscriptionTriggerMethods calculateNetPrice subscriptionIds: ' + subscriptionIds);
        system.debug('==> SubscriptionTriggerMethods calculateNetPrice eligibleSubscriptions: ' + eligibleSubscriptions);
    }
    
    @testVisible
    private static void processSubscriptionsForNetPrice(Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>> subscriptionsWithTiers){
        system.debug('==> SubscriptionTriggerMethods processSubscriptionsForNetPrice begin');
        for(SBQQ__Subscription__c subscription : subscriptionsWithTiers.keySet()){
            for(Quote_Line_Transaction_Tier__c tier : subscriptionsWithTiers.get(subscription)){
                system.debug('tier = '+tier);
                if(isCorrectTier(subscription, tier)){
                    system.debug('tier 1 ');
                    if(subscription.Varied_Licence__c){
                        calculateFee(subscription, tier);
                    } else{
                        system.debug('tier 2 ');
                        if(tier.price__c != null){
                            setNetPriceForTierPrice(subscription, tier);
                        } else{
                            setNetPriceForNullTierPrice(subscription, tier);
                        }
                    }
                }
            }
        }
        system.debug('==> SubscriptionTriggerMethods processSubscriptionsForNetPrice end');
    }
    
    @testVisible
    private static Map<Id, SBQQ__Subscription__c> getSubscriptionsWithTransactionsChange(List<SBQQ__Subscription__c> newList, Map<Id, SBQQ__Subscription__c> oldMap){
        system.debug('==> SubscriptionTriggerMethods getSubscriptionsWithTransactionsChange begin');
        Map<Id, SBQQ__Subscription__c> changedSubscriptions = new Map<Id, SBQQ__Subscription__c>();
        SBQQ__Subscription__c oldSubscription;
        for(SBQQ__Subscription__c subscription : newList){
            //system.debug(loggingLevel.ERROR,'==> SubscriptionTriggerMethods calculateNetPrice subscription: '+subscription);
            oldSubscription = oldMap.get(subscription.Id);
            //system.debug(loggingLevel.ERROR,'==> SubscriptionTriggerMethods calculateNetPrice oldSubscription: '+oldSubscription);
            if(subscription.Transactions__c != oldSubscription.Transactions__c){
                changedSubscriptions.put(subscription.Id, subscription);
            }
        }
        return changedSubscriptions;
    }
    
    @testVisible
    private static Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>> fetchSubscriptionsWithTiers(Map<Id, SBQQ__Subscription__c> subscriptions){
        Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>> subscriptionsWithTiers = new Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>>();
        List<Quote_Line_Transaction_Tier__c> tiers = [
            select Id, Start_Date__c, End_Date__c, Lower_Bound__c, Upper_Bound__c, Minimum_Price__c, Unit_Price__c, Price__c, Subscription__c, Licence_Fees__c
            from Quote_Line_Transaction_Tier__c
            where Subscription__c in :subscriptions.keySet()
        ];
        for(Quote_Line_Transaction_Tier__c tier : tiers){
            SBQQ__Subscription__c subscription = subscriptions.get(tier.Subscription__c);
            if(subscriptionsWithTiers.get(subscription) == null){
                subscriptionsWithTiers.put(subscription, new List<Quote_Line_Transaction_Tier__c>());
            }
            subscriptionsWithTiers.get(subscription).add(tier);
        }
        return subscriptionsWithTiers;
    }
    
    @testVisible
    private static boolean isCorrectTier(SBQQ__Subscription__c subscription, Quote_Line_Transaction_Tier__c tier){
        system.debug(loggingLevel.ERROR,'==> SubscriptionTriggerMethods isCorrectTier: ' + tier);
        boolean result;
        result = tier.Start_Date__c < Date.today()
            && (tier.End_Date__c > Date.today() || tier.End_Date__c == null)
            && tier.Lower_Bound__c <= subscription.Transactions__c
            && (tier.Upper_Bound__c >= subscription.Transactions__c || tier.Upper_Bound__c == null);
        system.debug(loggingLevel.ERROR,'==> SubscriptionTriggerMethods isCorrectTier: ' + result);
        return result;
    }
    
    @testVisible
    private static void setNetPriceForTierPrice(SBQQ__Subscription__c subscription, Quote_Line_Transaction_Tier__c tier){
        // TODO: check for nullability for some of these fields used in the calcs
        system.debug('tier = '+tier);
        if(subscription.Transactions__c != null && tier.Lower_Bound__c != null && tier.Price__c != null &&  tier.Unit_Price__c != null)
            
            if(tier.Lower_Bound__c == 0){
                subscription.SBQQ__NetPrice__c = tier.Unit_Price__c * (subscription.Transactions__c - tier.Lower_Bound__c) + tier.Price__c;
            }else{
                Decimal totalTransactions = (subscription.Transactions__c - tier.Lower_Bound__c) + 1;
                subscription.SBQQ__NetPrice__c = tier.Unit_Price__c * totalTransactions + tier.Price__c;
            }
        
        subscription.Fair_Value__c = subscription.SBQQ__NetPrice__c; 
        system.debug('==> SubscriptionTriggerMethods setNetPriceForTierPrice SBQQ__NetPrice__c: ' + subscription.SBQQ__NetPrice__c);
    }
    
    @testVisible
    private static void setNetPriceForNullTierPrice(SBQQ__Subscription__c subscription, Quote_Line_Transaction_Tier__c tier){
        // TODO: check for nullability for some of these fields used in the calcs
        system.debug('tier = '+tier);
        if(tier.Minimum_Price__c == null) tier.Minimum_Price__c = 0;
        if(subscription.Transactions__c != null && tier.Unit_Price__c != null){
            Decimal totalPrice = tier.Unit_Price__c * subscription.Transactions__c;
            if(totalPrice > tier.Minimum_Price__c){
                subscription.SBQQ__NetPrice__c = totalPrice;
            } else{
                subscription.SBQQ__NetPrice__c = tier.Minimum_Price__c;
            }
            subscription.Fair_Value__c = subscription.SBQQ__NetPrice__c;
        }
        
        system.debug('==> SubscriptionTriggerMethods setNetPriceForNullTierPrice SBQQ__NetPrice__c: ' + subscription.SBQQ__NetPrice__c);
    }
    
    @testVisible
    private static void calculateFee(SBQQ__Subscription__c subscription, Quote_Line_Transaction_Tier__c tier){
        // TODO: check for nullability for some of these fields used in the calcs
        
        Decimal calculatedFee, difference;
        if(subscription.Transactions__c != null && tier.Licence_Fees__c != null){
            calculatedFee = subscription.Transactions__c * tier.Licence_Fees__c;  
            subscription.Sold_Value__c = calculatedFee;
        }
        if(subscription.Sold_Value__c != null){
            difference = calculatedFee - subscription.Sold_Value__c;
            if(difference != 0){
                subscriptionIds.put(subscription.Id, difference);
            }
            subscription.SBQQ__NetPrice__c = subscription.SBQQ__NetPrice__c + (difference * 0.2);
            subscription.Fair_Value__c = subscription.SBQQ__NetPrice__c;            
        }
        
        system.debug(loggingLevel.ERROR,'==> SubscriptionTriggerMethods calculateFee SBQQ__NetPrice__c: ' + subscription.SBQQ__NetPrice__c);
    }
   
    //REQ-2916 G.B
    public static void soAmountUpdate(List<SBQQ__Subscription__c> newSubs, Map<Id,SBQQ__Subscription__c> oldMap){
        for(SBQQ__Subscription__c sub: newSubs){
            //Record being inserted or Net Price being updated
            if(sub.SBQQ__NetPrice__c != null && sub.SBQQ__ProrateMultiplier__c != null
              && ( oldMap == null 
                  || (oldMap != null && (  (sub.SBQQ__NetPrice__c != oldMap.get(sub.Id).SBQQ__NetPrice__c)
                                         ||(sub.SBQQ__ProrateMultiplier__c != oldMap.get(sub.Id).SBQQ__ProrateMultiplier__c)
                                        )
                     )
                 )
               ){
                //Set SO amount   
                sub.SO_Amount__c = sub.SBQQ__NetPrice__c / sub.SBQQ__ProrateMultiplier__c;
            }
        }
    }
    
    public static void updateContractApplicationDate(List<SBQQ__Subscription__c> newList, Map<Id, SBQQ__Subscription__c> oldMap){
        List<SBQQ__Subscription__c> appDateSubList = new List<SBQQ__Subscription__c>();
        
        Map<Id, Contract> contrMap = new Map<Id, Contract>();
        for(SBQQ__Subscription__c sub : newList) {
            if(sub.Uplift_Application_Date__c != oldMap.get(sub.Id).Uplift_Application_Date__c && sub.Uplift_Application_Date__c != null ) {
                appDateSubList.add(sub);
            }
        }
        if(appDateSubList.size() > 0) {
            //calculate and update Contract earliest application date accross all contracts
            Map<Id, Date> contr_dates_map = sortApplicationDates(appDateSubList);
            List<Contract> contrList = new List<Contract>();
            for(Contract contr: [SELECT Id, Uplift_Application_Date__c FROM Contract WHERE Id IN: contr_dates_map.keySet()]){
                contr.Uplift_Application_Date__c = contr_dates_map.get(contr.Id);
                if(contrMap.containsKey(contr.Id)) {
                    Contract existingContr = contrMap.get(contr.Id);
                    existingContr.Uplift_Application_Date__c = contr.Uplift_Application_Date__c;
                    contrMap.put(contr.Id, existingContr);
                }
                else {
                    contrMap.put(contr.Id, contr);
                }
            }
            if(contrMap.size() > 0){
                update contrMap.values();
            }
        }
    }
    
    public static Map<Id, Date> sortApplicationDates(SBQQ__Subscription__c[] subs){
        Set<Id> contrSet = new Set<Id>();
        for(SBQQ__Subscription__c sub: subs){
            if(!string.isEmpty(sub.SBQQ__Contract__c)) {
                contrSet.add(sub.SBQQ__Contract__c);
            }
        }
        Map<Id, List<SBQQ__Subscription__c>> contr_subs_map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> tempList;
        for(SBQQ__Subscription__c sub: [Select Id, SBQQ__Contract__c, Uplift_Application_Date__c from SBQQ__Subscription__c where SBQQ__Contract__c in :contrSet]){
            tempList = new List<SBQQ__Subscription__c>();
            if(contr_subs_map.get(sub.SBQQ__Contract__c) != null){
                tempList = contr_subs_map.get(sub.SBQQ__Contract__c);
            } 
            tempList.add(sub);
            contr_subs_map.put(sub.SBQQ__Contract__c, tempList);            
        }
        return sortAdSubs(contr_subs_map);
    }
    
    @TestVisible private static Map<Id, Date> sortAdSubs(Map<Id, List<SBQQ__Subscription__c>> contr_subs_map){
        
        Map<Id, Date> returnMap = new Map<Id, Date>();
        Date earliestApplicationDate;
        for(Id contrId: contr_subs_map.keySet()){
            // init date
            earliestApplicationDate = Date.newInstance(9999, 12, 31);
            for(SBQQ__Subscription__c sub: contr_subs_map.get(contrId)){
                if (sub.Uplift_Application_Date__c < earliestApplicationDate) {
                    earliestApplicationDate = sub.Uplift_Application_Date__c;
                }
            }
            returnMap.put(contrId, earliestApplicationDate);
        }  
        
        return returnMap;
    }
}