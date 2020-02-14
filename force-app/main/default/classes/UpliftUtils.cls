/**
 * @File Name          : UpliftUtils.cls
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 24/07/2019, 13:15:19
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    15/07/2019, 14:57:53   Peter Sabry                      Initial Version
 * 1.1    22/072018,             Gaetan Barbeu                    REQ-2994
**/
public with sharing class UpliftUtils{
    
    @testVisible
    private static List<SBQQ__Subscription__c> subscriptionsToUpdate = new List<SBQQ__Subscription__c>();
    
    @testVisible
    private static List<Quote_Line_Transaction_Tier__c> tiersToUpdate = new List<Quote_Line_Transaction_Tier__c>();
    
    //NACM Billing - CPI Uplift - ATG Model - Start
    public static void createUpliftFromContract(List<Contract> contractList) {
        
        if(contractList == null || contractList.isEmpty()) return;
        
        Set<Id> contractIds = new Set<Id>();
        for(Contract contr : contractList) {
            contractIds.add(contr.Id);
        }
        List<SBQQ__Subscription__c> allSubscriptions = new List<SBQQ__Subscription__c>([Select ID, Transactional__c, Minimum_Price__c, Uplift_Calc_Type__c, SBQQ__Contract__c, SO_Generation_Advance__c, SBQQ__BillingFrequency__c,
                    Uplift_Effective_Date__c, Net_Customer_Uplift__c, Interim_Uplift_Percentage__c, Fair_Value__c, SO_Amount__c, Uplift_Factor__c, Cumulative_CPI_Uplift_Factor__c, SBQQ__BillingType__c, CPI_Uplift_Review_Date__c, SBQQ__NetPrice__c, SBQQ__ProrateMultiplier__c,
                    Quote_Recurring_Price__c, Uplift_Application_Date__c, SBQQ__Contract__r.Uplift_Application_Date__c, SBQQ__Contract__r.Recurring_Fees_Index_Type__c, SBQQ__Contract__r.Hold_CPI_Uplift__c, SBQQ__Contract__r.Skip_Uplift__c, Exclude__c, SBQQ__Contract__r.Billing_Frequency__c, SBQQ__Contract__r.CPI_Uplift_Type__c
                    from SBQQ__Subscription__c where SBQQ__Contract__c in :contractIds and Billing_Status__c = 'Active billing' and Exclude__c = FALSE]);
        
        List<SBQQ__Subscription__c> subsToProcess = new List<SBQQ__Subscription__c>(); 
        for(SBQQ__Subscription__c subscription : allSubscriptions) {
            if(subscription.Uplift_Application_Date__c <= subscription.SBQQ__Contract__r.Uplift_Application_Date__c) {
                subsToProcess.add(subscription);
            }
        }
        
        List<SBQQ__Subscription__c> transactionalSubs = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> nonTransactionalSubs = new List<SBQQ__Subscription__c>();
        
        for(SBQQ__Subscription__c subscription : subsToProcess){
            if(subscription.Transactional__c){
                transactionalSubs.add(subscription);
                } else{
                nonTransactionalSubs.add(subscription);
                }
        }
         //G.B 22.07.2019 - Declare a database save point as there are sequential commits to the database
        Savepoint sp = Database.setSavepoint();
        try{
            processCPIUpliftForNonTransactionalSubs(nonTransactionalSubs);
            //G.B 22.07.2019
            processCPIUpliftForTransactionalSubs(transactionalSubs);
            performUpdate(tiersToUpdate);
            performUpdate(subscriptionsToUpdate);
        }catch(Exception e){
            Database.rollback(sp);
            throw (e);
        }        
    }
    
    @testVisible
    private static void processCPIUpliftForNonTransactionalSubs(List<SBQQ__Subscription__c> nonTransactionalSubs){
        Map<Id, SBQQ__Subscription__c> uplift_sub_map_interim = new Map<Id, SBQQ__Subscription__c>(); // map for interim
        Map<Id, SBQQ__Subscription__c> uplift_sub_map_std = new Map<Id, SBQQ__Subscription__c>(); // map for std
        Map<Id, SBQQ__Subscription__c> uplift_sub_map_pro = new Map<Id, SBQQ__Subscription__c>(); // map for prorata

        List<SBQQ__Subscription__c> interimSubsList = new List<SBQQ__Subscription__c>(); // list for interim
        List<SBQQ__Subscription__c> stdSubsList = new List<SBQQ__Subscription__c>(); // list for std
        List<SBQQ__Subscription__c> proSubsList = new List<SBQQ__Subscription__c>(); // list for prorata

        for(SBQQ__Subscription__c subscription : nonTransactionalSubs){
            if(UpliftProrataHandler.isEligibleForCPIUplift(subscription)){
                if(subscription != null && subscription.Uplift_Factor__c > 0){
                    if(subscription.Uplift_Calc_Type__c == 'Pro-Rata'){
                        if(subscription.SO_Amount__c != null){
                            subscription.SO_Amount__c = subscription.SO_Amount__c * subscription.Uplift_Factor__c ;//subscription.CPI_Uplift__r.NCU__c / 100; //*factor
                            //REQ-3531 Calculate CPI cumulative uplift factor
                            if(subscription.Cumulative_CPI_Uplift_Factor__c == null || subscription.Cumulative_CPI_Uplift_Factor__c == 0) {
                                subscription.Cumulative_CPI_Uplift_Factor__c = 1;
                            }
                            subscription.Cumulative_CPI_Uplift_Factor__c *= subscription.Uplift_Factor__c;
                        }
                        if(subscription.Fair_Value__c != null){
                            subscription.Fair_Value__c = subscription.Fair_Value__c * subscription.Uplift_Factor__c; //subscription.CPI_Uplift__r.NCU__c / 100;   //*factor
                        }
                        proSubsList.add(subscription); 
                    }else if(subscription.Uplift_Calc_Type__c == 'Interim'){
                        if(subscription.SBQQ__NetPrice__c != null && subscription.SBQQ__ProrateMultiplier__c > 0) {
                            subscription.SO_Amount__c = (subscription.SBQQ__NetPrice__c/subscription.SBQQ__ProrateMultiplier__c) * subscription.Uplift_Factor__c;
                            subscription.Fair_Value__c = subscription.SO_Amount__c; //Setting Fair Value to SO Amount - Pending Business confirmation
                            //REQ-3531 Calculate CPI cumulative uplift factor
                            if(subscription.Cumulative_CPI_Uplift_Factor__c == null || subscription.Cumulative_CPI_Uplift_Factor__c == 0) {
                                subscription.Cumulative_CPI_Uplift_Factor__c = 1;
                            }
                            subscription.Cumulative_CPI_Uplift_Factor__c *= subscription.Uplift_Factor__c;
                        }
                        interimSubsList.add(subscription);  
                    } else if(subscription.Uplift_Calc_Type__c == 'Full Year'){                        
                        subscription.SO_Amount__c = subscription.SO_Amount__c * subscription.Uplift_Factor__c ;//subscription.CPI_Uplift__r.NCU__c / 100; //*factor          
                        if(subscription.Fair_Value__c != null){
                            subscription.Fair_Value__c = subscription.Fair_Value__c * subscription.Uplift_Factor__c; //subscription.CPI_Uplift__r.NCU__c / 100;   //*factor
                        } 
                        //REQ-3531 Calculate CPI cumulative uplift factor
                        if(subscription.Cumulative_CPI_Uplift_Factor__c == null || subscription.Cumulative_CPI_Uplift_Factor__c == 0) {
                            subscription.Cumulative_CPI_Uplift_Factor__c = 1;
                        }
                        subscription.Cumulative_CPI_Uplift_Factor__c *= subscription.Uplift_Factor__c;
                        stdSubsList.add(subscription);  
                    }
                    //subscriptionsToUpdate.add(subscription);
                }
            } else{
                if(subscription.Exclude__c){
                    subscription.Exclude__c = false;
                    subscriptionsToUpdate.add(subscription);
                }
            }
        }
        
        // for prorata - calc
        if(proSubsList.size() > 0){
            UpliftProrataHandler.updateUpliftDatesForPro(proSubsList);
        }
        // for interim - calc
        if(interimSubsList.size() > 0){
            UpliftProrataHandler.updateUpliftDatesForInterim(interimSubsList);
        }
        // for std - calc
        if(stdSubsList.size() > 0){
            UpliftProrataHandler.updateUpliftDatesForStd(stdSubsList);
        }
        
    }
    //REQ-2994
    @testVisible
    private static void processCPIUpliftForTransactionalSubs(List<SBQQ__Subscription__c> transactionalSubs){
        Set<Id> subscriptionIds = new Set<Id>();
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c subscription : transactionalSubs){
            if(UpliftProrataHandler.isEligibleForCPIUplift(subscription)){
                subscriptionIds.add(subscription.Id);
            }
        }
        if(!subscriptionIds.isEmpty()){
            Map<Id, List<Quote_Line_Transaction_Tier__c>> subIdToTiers = new Map<Id, List<Quote_Line_Transaction_Tier__c>>();
            for(Quote_Line_Transaction_Tier__c tier : [select Id, 
                                                              Subscription__c, 
                                                              Unit_Price__c,
                                                              Price__c,
                                                              Start_Date__c,
                                                              Minimum_Price__c, 
                                                              Subscription__r.Uplift_Factor__c,
                                                              Subscription__r.Net_Customer_Uplift__c,
                                                              Subscription__r.Interim_Uplift_Percentage__c, 
                                                              Subscription__r.SBQQ__Contract__r.Additional_Increase__c 
                                                              FROM Quote_Line_Transaction_Tier__c WHERE 
                                                              Subscription__c IN :subscriptionIds]){
                if(!subIdToTiers.containsKey(tier.Subscription__c)){
                    subIdToTiers.put(tier.Subscription__c, new List<Quote_Line_Transaction_Tier__c>());
                }
                subIdToTiers.get(tier.Subscription__c).add(tier);
            }
            for(SBQQ__Subscription__c subscription : transactionalSubs){
                if(UpliftProrataHandler.isEligibleForCPIUplift(subscription)){
                    if(subIdToTiers.containsKey(subscription.Id)){
                        for(Quote_Line_Transaction_Tier__c tier : subIdToTiers.get(subscription.Id)){
                            if(tier.Start_Date__c < Date.today() && tier.Subscription__r.Uplift_Factor__c > 0 && tier.Unit_Price__c != null){
                                tier.Unit_Price__c = tier.Unit_Price__c * tier.Subscription__r.Uplift_Factor__c ;
                            }
                            tiersToUpdate.add(tier);   
                        }
                    }
                    //Minimun committed price. 
                    if(subscription.Minimum_Price__c != null && subscription.Uplift_Factor__c > 0){
                        subscription.Minimum_Price__c = subscription.Minimum_Price__c * subscription.Uplift_Factor__c;
                        subscriptionsToUpdate.add(subscription);
                    }
                } else if(subscription.Exclude__c){
                        subscription.Exclude__c = false;
                        subscriptionsToUpdate.add(subscription);
                }
            }
            UpliftProrataHandler.updateUpliftDatesForStd(transactionalSubs);

        }
    }      

    //NACM Billing - CPI Uplift - ATG Model - End
    public static void createUplift(List<Uplift__c> uplifts){
        
        if(uplifts == null || uplifts.isEmpty()) return;
        
        Set<Id> upliftIds = new Set<Id>();
        for(Uplift__c u : uplifts){
            upliftIds.add(u.Id);
        }
        
        uplifts = [select id, Exclude__c,Percentage__c, NCU__c,// status__c,
                   (select Id, SBQQ__Contract__c, SBQQ__Contract__r.Skip_Uplift__c, SBQQ__Quantity__c, Exclude__c, Billing_group__r.Next_SO_generation_Date__c, Billing_group__r.Next_Billing_Date__c,
                    SBQQ__NetPrice__c,Fair_Value__c , Transactional__c, CPI_Uplift__c,Expired_Subscription__c, CPI_Uplift__r.Id, CPI_Uplift__r.Exclude__c, Quote_recurring_price__c, SO_Generation_Advance__c, 
                    CPI_Uplift__r.NCU__c, CPI_Uplift__r.Percentage__c,CPI_Uplift__r.Uplift_Application_Date__c,CPI_Uplift__r.Uplift_Effective_Date__c, CPI_Uplift__r.Billing_Type__c,CPI_Uplift__r.Billing_Frequency__c,CPI_Uplift__r.Uplift_Factor__c, CPI_Uplift__r.Status__c from Subscriptions__r where Billing_Status__c = 'Active billing' and Expired_Subscription__c  = false and Exclude__c = false)
                   from Uplift__c where id in :upliftIds];
        
        List<SBQQ__Subscription__c> allSubscriptions = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> transactionalSubs = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> nonTransactionalSubs = new List<SBQQ__Subscription__c>();
        
        for(Uplift__c uplift : uplifts){
            if(!uplift.Exclude__c){
                allSubscriptions.addAll(uplift.Subscriptions__r);
            }
            if(uplift.Exclude__c){
                uplift.Exclude__c = false;
            }            
        }
        
        for(SBQQ__Subscription__c subscription : allSubscriptions){
            if(subscription.Transactional__c){
                transactionalSubs.add(subscription);
                } else{
                nonTransactionalSubs.add(subscription);
                }
        }
        
        processUpliftForNonTransactionalSubs(nonTransactionalSubs);
        processUpliftForTransactionalSubs(transactionalSubs);
        updateDates(allSubscriptions);
        
        performUpdate(tiersToUpdate);
        performUpdate(subscriptionsToUpdate);
        performUpdate(uplifts); // unchecked Exclude__c checkbox
        
    }
    
    @testVisible
    private static void processUpliftForNonTransactionalSubs(List<SBQQ__Subscription__c> nonTransactionalSubs){
        //Map<Id, SBQQ__Subscription__c> uplift_sub_map_interim = new Map<Id, SBQQ__Subscription__c>(); // map for interim
        //Map<Id, SBQQ__Subscription__c> uplift_sub_map_std = new Map<Id, SBQQ__Subscription__c>(); // map for std
        //Map<Id, SBQQ__Subscription__c> uplift_sub_map_pro = new Map<Id, SBQQ__Subscription__c>(); // map for prorata
        for(SBQQ__Subscription__c subscription : nonTransactionalSubs){
            if(UpliftProrataHandler.isEligibleForUplift(subscription)){
                if(subscription.CPI_Uplift__c != null && subscription.CPI_Uplift__r.Uplift_Factor__c > 0){
                    if(subscription.CPI_Uplift__r.Status__c == 'Pro-Rata'){
                        if(subscription.SBQQ__NetPrice__c != null){
                            subscription.SBQQ__NetPrice__c = subscription.SBQQ__NetPrice__c * subscription.CPI_Uplift__r.Uplift_Factor__c ;//subscription.CPI_Uplift__r.NCU__c / 100; //*factor          
                        }
                        if(subscription.Fair_Value__c != null){
                            subscription.Fair_Value__c = subscription.Fair_Value__c * subscription.CPI_Uplift__r.Uplift_Factor__c; //subscription.CPI_Uplift__r.NCU__c / 100;   //*factor
                        }
                        //uplift_sub_map_pro.put(subscription.CPI_Uplift__c, subscription); 
                    }else if(subscription.CPI_Uplift__r.Status__c == 'Interim'){
                        subscription.SBQQ__NetPrice__c =  subscription.Quote_Recurring_Price__c * subscription.CPI_Uplift__r.Uplift_Factor__c;  
                        //uplift_sub_map_interim.put(subscription.CPI_Uplift__c, subscription);  
                    } else if(subscription.CPI_Uplift__r.Status__c == 'Full Year'){                        
                        subscription.SBQQ__NetPrice__c = subscription.SBQQ__NetPrice__c * subscription.CPI_Uplift__r.Uplift_Factor__c ;//subscription.CPI_Uplift__r.NCU__c / 100; //*factor          
                        if(subscription.Fair_Value__c != null){
                            subscription.Fair_Value__c = subscription.Fair_Value__c * subscription.CPI_Uplift__r.Uplift_Factor__c; //subscription.CPI_Uplift__r.NCU__c / 100;   //*factor
                        } 
                        //uplift_sub_map_std.put(subscription.CPI_Uplift__c, subscription);  
                    }
                    subscriptionsToUpdate.add(subscription);
                }
            } else{
                if(subscription.Exclude__c){
                    subscription.Exclude__c = false;
                    subscriptionsToUpdate.add(subscription);
                }
            }
        }
        
    }
    
    @testVisible
    private static void processUpliftForTransactionalSubs(List<SBQQ__Subscription__c> transactionalSubs){
        Set<Id> subscriptionIds = new Set<Id>();
       // Map<Id, SBQQ__Subscription__c> uplift_Tran_sub_map_std = new Map<Id, SBQQ__Subscription__c>(); // map for std
        for(SBQQ__Subscription__c subscription : transactionalSubs){
            if(UpliftProrataHandler.isEligibleForUplift(subscription)){
                subscriptionIds.add(subscription.Id);
            }
        }
        
        Map<Id, List<Quote_Line_Transaction_Tier__c>> subIdToTiers = new Map<Id, List<Quote_Line_Transaction_Tier__c>>();
        for(Quote_Line_Transaction_Tier__c tier : [select id, Start_Date__c, Subscription__c, Unit_Price__c,Price__c,Minimum_Price__c, Subscription__r.CPI_Uplift__r.Uplift_Factor__c,Subscription__r.CPI_Uplift__r.NCU__c, End_Date__c, Subscription__r.Id, Subscription__r.CPI_Uplift__r.Percentage__c from Quote_Line_Transaction_Tier__c where Subscription__c in :subscriptionIds]){
            if(subIdToTiers.get(tier.Subscription__c) == null){
                subIdToTiers.put(tier.Subscription__c, new List<Quote_Line_Transaction_Tier__c>());
            }
            subIdToTiers.get(tier.Subscription__c).add(tier);
        }
        
        for(SBQQ__Subscription__c subscription : transactionalSubs){
            
            if(UpliftProrataHandler.isEligibleForUplift(subscription)){
                List<Quote_Line_Transaction_Tier__c> subTiers = subIdToTiers.get(subscription.Id) == null ? new List<Quote_Line_Transaction_Tier__c>() : subIdToTiers.get(subscription.Id);
                for(Quote_Line_Transaction_Tier__c tier : subTiers){
                    if(tier.Start_Date__c < Date.today()){
                        if(tier.Subscription__r.CPI_Uplift__r.Uplift_Factor__c > 0){
                            if(tier.Unit_Price__c != null){
                                tier.Unit_Price__c = tier.Unit_Price__c * tier.Subscription__r.CPI_Uplift__r.Uplift_Factor__c ;
                            }
                            if(tier.Price__c != null) {
                                tier.Price__c = tier.Price__c * tier.Subscription__r.CPI_Uplift__r.Uplift_Factor__c ;
                            }
                            if(tier.Minimum_Price__c != null){
                                tier.Minimum_Price__c = tier.Minimum_Price__c * tier.Subscription__r.CPI_Uplift__r.Uplift_Factor__c;  
                            }
                            
                        }
                        
                        tiersToUpdate.add(tier);
                    }
                    // for std - calc
                    
                }
            } else{
                if(subscription.Exclude__c){
                    subscription.Exclude__c = false;
                    subscriptionsToUpdate.add(subscription);
                }
            }  
        }
    }       


        // for prorata - calc
       @testVisible
    private static void updateDates(List<SBQQ__Subscription__c> allSubscriptions){
        Map<Id, SBQQ__Subscription__c> uplift_sub_map_interim = new Map<Id, SBQQ__Subscription__c>(); // map for interim
        Map<Id, SBQQ__Subscription__c> uplift_sub_map_std = new Map<Id, SBQQ__Subscription__c>(); // map for std
        Map<Id, SBQQ__Subscription__c> uplift_sub_map_pro = new Map<Id, SBQQ__Subscription__c>(); // map for prorata
        for(SBQQ__Subscription__c subscription : allSubscriptions){
            if(subscription.CPI_Uplift__r.Status__c == 'Interim'){
                uplift_sub_map_interim.put(subscription.CPI_Uplift__c, subscription);  
            }
            else if(subscription.CPI_Uplift__r.Status__c == 'Full Year'){ 
                uplift_sub_map_std.put(subscription.CPI_Uplift__c, subscription);
            }
            if(subscription.CPI_Uplift__r.Status__c == 'Pro-Rata'){
                uplift_sub_map_pro.put(subscription.CPI_Uplift__c, Subscription);
            }
            if(uplift_sub_map_pro.size() > 0){
                UpliftProrataHandler.updateUpliftDatesForPro(uplift_sub_map_pro);
            }
            // for interim - calc
            if(uplift_sub_map_interim.size() > 0){
                UpliftProrataHandler.updateUpliftDatesForInterim(uplift_sub_map_interim);
            }
            // for std - calc
            if(uplift_sub_map_std.size() > 0){
                UpliftProrataHandler.updateUpliftDatesForStd(uplift_sub_map_std);
            }
        }
        
     }
    @testVisible
    private static void performUpdate(List<sObject> recordsToUpdate){
        if(!recordsToUpdate.isEmpty()){
            update recordsToUpdate;            
        }
    }
    
}