/**
 * @File Name          : SubscriptionTriggerHandler.cls
 * @Description        : Class will hold all code business logic for susbcription trigger. 
                         Without sharing as security model is still not properly defined.
 * @Author             : Gaetan Barbeu
 * @Group              : 
 * @Last Modified By   : Gaetan Barbeu
 * @Last Modified On   : 23.07.2019
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0         10.07.2019               Gaetan Barbeu             Initial Version - Implement trigger pattern REQ-3532/REQ-3530
                                                                                   All SubscriptionTriggerMethods methods/varibales have been copied over
 * 1.1         23.07.2019               Gaetan Barbeu             REQ-2995 -  Beam Amount to bill calculation on transaction count                                                                                   
 * 
**/
public without sharing class SubscriptionTriggerHandler extends TriggerHandler {
    

    @testVisible
    private static Map<Id, Decimal> subscriptionIds = new Map<Id, Decimal>();

    protected override void beforeInsert(){
        assignSOadvDaysToSubs(Trigger.new, null, TRUE);
        soAmountUpdate(Trigger.new, null);
        // calcuating uplift factor
        UpliftProrataHandler.calcualteUpliftFactorForSubs(trigger.New);
    } 
    protected override void beforeUpdate(){
        calculateNetPrice(Trigger.newMap, Trigger.oldMap);            
        assignSOadvDaysToSubs(Trigger.new, Trigger.old, false); 
        soAmountUpdate(Trigger.new, (Map<Id,SBQQ__Subscription__c>)Trigger.oldMap);
        // calcuating uplift factor
        UpliftProrataHandler.calcualteUpliftFactorForSubs(trigger.New); 
    } 
    protected override void beforeDelete(){} 
    
    protected override void afterInsert(){
        setTransactionalQLTT(Trigger.new);
    } 
    protected override void afterUpdate(){
        updateContractApplicationDate(Trigger.new, (Map<Id,SBQQ__Subscription__c>)Trigger.oldMap);
    } 
    protected override void afterDelete(){} 
    
    protected override void afterUndelete(){} 

    /***************** 
    * Method Name: manageTransactionalBilling
    * Parameters: List<SBQQ__Subscription__c>
    * Return Type: void 
    * Description: REQ-3532/REQ-3530 - Create new QLTT records based on Discount tiers.
    *******************/
    
    private void setTransactionalQLTT(List<SBQQ__Subscription__c> newSubsList){
        List<Quote_Line_Transaction_Tier__c> qlttList = new List<Quote_Line_Transaction_Tier__c>();
        Map<Id,Set<SBQQ__Subscription__c>> discSchIdSubMap = new Map<Id,Set<SBQQ__Subscription__c>>();
        for(SBQQ__Subscription__c sub:newSubsList){
            //Single Tier Process
            if(sub.Transactional__c && sub.SBQQ__DiscountSchedule__c == null){
                //Insert new QLTT
                qlttList.add(new Quote_Line_Transaction_Tier__c(Subscription__c = sub.Id,
                                                                Unit_Price__c = sub.SBQQ__NetPrice__c,
                                                                Start_Date__c = sub.SBQQ__StartDate__c,
                                                                End_Date__c = sub.SBQQ__EndDate__c,
                                                                Lower_Bound__c = 0));
            //Multi-Tier Process
            }else if(sub.Transactional__c && sub.SBQQ__DiscountSchedule__c != null){
                
                if(!discSchIdSubMap.containsKey(sub.SBQQ__DiscountSchedule__c)){
                    discSchIdSubMap.put(sub.SBQQ__DiscountSchedule__c,new Set<SBQQ__Subscription__c>());
                }
                discSchIdSubMap.get(sub.SBQQ__DiscountSchedule__c).add(sub);
            }
        }
        if(!discSchIdSubMap.isEmpty()){
            for(SBQQ__DiscountTier__c discTier :[SELECT Id,
                                                        SBQQ__UpperBound__c, 
                                                        SBQQ__LowerBound__c,
                                                        SBQQ__Price__c,
                                                        Unit_Price__c,
                                                        SBQQ__Schedule__c
                                                        FROM SBQQ__DiscountTier__c
                                                        WHERE SBQQ__Schedule__c IN:discSchIdSubMap.keySet()]){
                //Need to insert QLTT for each discount tier for a given subscription                                            
                for(SBQQ__Subscription__c sub:discSchIdSubMap.get(discTier.SBQQ__Schedule__c)){
                    //Insert new QLTT
                    Quote_Line_Transaction_Tier__c qltt = new Quote_Line_Transaction_Tier__c(Subscription__c = sub.Id,
                                                                                            Unit_Price__c = discTier.Unit_Price__c,
                                                                                            Start_Date__c = sub.SBQQ__StartDate__c,
                                                                                            End_Date__c = sub.SBQQ__EndDate__c,
                                                                                            Discount_Tier__c = discTier.Id,
                                                                                            Lower_Bound__c = discTier.SBQQ__LowerBound__c,
                                                                                            Upper_Bound__c = discTier.SBQQ__UpperBound__c);
                    qlttList.add(qltt);
                }
            }
        }
        // Insert Quote Line Transaction Tier records
        if(!qlttList.isEmpty())
            insert qlttList;
    }

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
        Map<Id, SBQQ__Subscription__c> eligibleSubscriptions = getSubscriptionsWithTransactionsChange((List<SBQQ__Subscription__c>) newMap.values(), (Map<Id, SBQQ__Subscription__c>) oldMap);
        if(eligibleSubscriptions.isEmpty()) return;
        Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>> subscriptionsWithTiers = fetchSubscriptionsWithTiers(eligibleSubscriptions);
        processSubscriptionsForNetPrice(subscriptionsWithTiers);
    }
    
    //G.B REQ-2995 25.07.2017 - Include Beam business logic
    @testVisible
    private static void processSubscriptionsForNetPrice(Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>> subscriptionsWithTiers){
        for(SBQQ__Subscription__c subscription : subscriptionsWithTiers.keySet()){
            //G.B 25.07.2019 REQ-2995
            Decimal minCommittedPrice = subscription.Minimum_Price__c!= null? subscription.Minimum_Price__c:0;
            Decimal slabSoAmount = 0.00;
            for(Quote_Line_Transaction_Tier__c tier : subscriptionsWithTiers.get(subscription)){
                //G.B 25.07.2019 REQ-2995 - include NACM Transactional Beam
                if(subscription.Beam__c && subscription.Transactional__c && subscription.Transactions__c!= null && tier.Unit_Price__c != null){
                    
                    //Single Tier or Range Tier - Minimum committed price or transaction count * Unit Price
                    if(isCorrectTier(subscription, tier) && (subscription.SBQQ__DiscountScheduleType__c == null || subscription.SBQQ__DiscountScheduleType__c == 'Range')){
                        subscription.SO_Amount__c = ((subscription.Transactions__c * tier.Unit_Price__c) > minCommittedPrice)
                                                     ?(subscription.Transactions__c * tier.Unit_Price__c): minCommittedPrice;
                    
                    //Slab Tier - cummilitive (transaction count * Unit Price)
                    }else if(subscription.SBQQ__DiscountScheduleType__c == 'Slab'){
                        Decimal slabPrice = 0;
                        //Transaction count is above Upper Bound
                        if(subscription.Transactions__c >  tier.Upper_Bound__c){
                            slabPrice = (tier.Upper_Bound__c +1  - tier.Lower_Bound__c )* tier.Unit_Price__c;
                        }//Transaction count is below Upper Bound and above Lower Bound 
                        if(subscription.Transactions__c <= tier.Upper_Bound__c && subscription.Transactions__c >= tier.Lower_Bound__c)
                            slabPrice =  (subscription.Transactions__c + 1 - tier.Lower_Bound__c) * tier.Unit_Price__c;
                        slabSoAmount += (tier.Start_Date__c < Date.today() && (tier.End_Date__c > Date.today() || tier.End_Date__c == null))? slabPrice:0;
                    }
                }
                //G.B 25.07.2019 REQ-2995 - seperate business logic for GP
                else if(isCorrectTier(subscription, tier)){
                    if(subscription.Varied_Licence__c){
                        calculateFee(subscription, tier);
                    } else{
                        if(tier.price__c != null){
                            setNetPriceForTierPrice(subscription, tier);
                        } else{
                            setNetPriceForNullTierPrice(subscription, tier);
                        }
                    }
                }
            }
            //G.B 25.07.2019 REQ-2995 - Minimum committed price or cummilitive (transaction count * Unit Price)
            if(subscription.Beam__c && subscription.Transactional__c && subscription.Transactions__c!= null && subscription.SBQQ__DiscountScheduleType__c == 'Slab'){
               subscription.SO_Amount__c =  slabSoAmount > minCommittedPrice? slabSoAmount :minCommittedPrice;
            }   
        }
    }
    
    @testVisible
    private static Map<Id, SBQQ__Subscription__c> getSubscriptionsWithTransactionsChange(List<SBQQ__Subscription__c> newList, Map<Id, SBQQ__Subscription__c> oldMap){
        Map<Id, SBQQ__Subscription__c> changedSubscriptions = new Map<Id, SBQQ__Subscription__c>();
        SBQQ__Subscription__c oldSubscription;
        for(SBQQ__Subscription__c subscription : newList){
            oldSubscription = oldMap.get(subscription.Id);
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
            select Id, Start_Date__c, End_Date__c, Lower_Bound__c, Upper_Bound__c, Minimum_Price__c, Unit_Price__c, Slab_Price__c,Price__c, Subscription__c, Licence_Fees__c
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
        boolean result;
        result = tier.Start_Date__c < Date.today()
            && (tier.End_Date__c > Date.today() || tier.End_Date__c == null)
            && tier.Lower_Bound__c <= subscription.Transactions__c
            && (tier.Upper_Bound__c >= subscription.Transactions__c || tier.Upper_Bound__c == null);
        return result;
    }
    
    @testVisible
    private static void setNetPriceForTierPrice(SBQQ__Subscription__c subscription, Quote_Line_Transaction_Tier__c tier){
        // TODO: check for nullability for some of these fields used in the calcs
        if(subscription.Transactions__c != null && tier.Lower_Bound__c != null && tier.Price__c != null &&  tier.Unit_Price__c != null)
            
            if(tier.Lower_Bound__c == 0){
                subscription.SBQQ__NetPrice__c = tier.Unit_Price__c * (subscription.Transactions__c - tier.Lower_Bound__c) + tier.Price__c;
            }else{
                Decimal totalTransactions = (subscription.Transactions__c - tier.Lower_Bound__c) + 1;
                subscription.SBQQ__NetPrice__c = tier.Unit_Price__c * totalTransactions + tier.Price__c;
            }
        
        subscription.Fair_Value__c = subscription.SBQQ__NetPrice__c; 
    }
    
    @testVisible
    private static void setNetPriceForNullTierPrice(SBQQ__Subscription__c subscription, Quote_Line_Transaction_Tier__c tier){
        // TODO: check for nullability for some of these fields used in the calcs
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
    }
   
    //REQ-2916 G.B
    public static void soAmountUpdate(List<SBQQ__Subscription__c> newSubs, Map<Id,SBQQ__Subscription__c> oldMap){
        for(SBQQ__Subscription__c sub: newSubs){
            //Record being inserted or Net Price being updated
            if(sub.SBQQ__NetPrice__c != null && sub.SBQQ__ProrateMultiplier__c != null && sub.Sales_Order_Type__c == 'RLF'
              && ( oldMap == null 
                  || (oldMap != null && (  (sub.SBQQ__NetPrice__c != oldMap.get(sub.Id).SBQQ__NetPrice__c)
                                         ||(sub.SBQQ__ProrateMultiplier__c != oldMap.get(sub.Id).SBQQ__ProrateMultiplier__c)
                                        )
                     )
                 )
               ){
                //Set SO amount  - RLF NACM 
                sub.SO_Amount__c = sub.SBQQ__NetPrice__c / sub.SBQQ__ProrateMultiplier__c;
            }else if (sub.SBQQ__NetPrice__c != null && (sub.Sales_Order_Type__c == 'ILF' || sub.Sales_Order_Type__c == '') 
                      && (oldMap == null  
                          || (oldMap != null && (sub.SBQQ__NetPrice__c != oldMap.get(sub.Id).SBQQ__NetPrice__c))) ){
                 //Set SO amount  - ILF NACM or GP
                 sub.SO_Amount__c = sub.SBQQ__NetPrice__c;
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
         for(SBQQ__Subscription__c sub: [Select Id, SBQQ__Contract__c, Uplift_Application_Date__c from SBQQ__Subscription__c where SBQQ__Contract__c in :contrSet and Exclude__c = FALSE]){
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