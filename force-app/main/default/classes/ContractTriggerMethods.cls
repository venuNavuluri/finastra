/*
Created By: Abhinit Kohar
Created Date: 11/12/2013
Description: This is the support class containing the methods used in the ContractTrigger trigger. 

CH01 - New methos is added by Venu // 13/09/17
New method will create billing group record based on contract status

29/04/2019 - Irving - REQ-2872 Check made to exclude these sub lines for RLF

*/
public class ContractTriggerMethods {
    
    //This method converts the Services Amount Variance into the USD using the dated exchange rates and populates 
    //the Services Amount Variance USD field.
    
    public static void updateServiceAmountVarianceUSD(list<Contract> contractList){
        Map<string, List<DatedConversionRate>> exchRateCache = FinanceUtils.GetExchRateCache();
        for(Contract con : contractList){
            if(con.Services_Amount_Variance__c != null && con.Services_Amount_Variance__c > 0){
                if (con.Opportunity_Close_Date__c == null) {
                    throw new CommonFunctions.CustomException('Please assign a closed opportunity to the contract: ' + con.ContractNumber);
                }
                con.Services_Amount_Variance_USD__c = FinanceUtils.ExchangeCurrency(con.CurrencyIsoCode, 'USD', (Double)con.Services_Amount_Variance__c, con.Opportunity_Close_Date__c, exchRateCache);
            } else {
                con.Services_Amount_Variance_USD__c = 0;
            }
        }
        
    }
    
    public static void updateNSCustomerAddress(list<Contract> conList){
        set<Id> billToShipToIds = new set<Id>();
        set<Id> accBySubIds = new set<Id>();
        system.debug('invoked by trigger => '+conList);
        for(Contract con : conList){
            if(con.Ship_To__c  != null){
                billToShipToIds.add(con.Ship_To__c );
            }
            if(con.Bill_To__c  != null){
                billToShipToIds.add(con.Bill_To__c);
            }
            if(con.Billing_Group_Entity__c  != null){
                accBySubIds.add(con.Billing_Group_Entity__c );
            }
            //con.addError('invoked');
        }
        system.debug('billToShipToIds = ' + billToShipToIds);
        system.debug('accBySubIds = ' + accBySubIds);
        
        map<Id, list<NS_Customer_Address__c>> btNCAMap = new map<Id, list<NS_Customer_Address__c>>();
        list<NS_Customer_Address__c> ncaList;
        for(NS_Customer_Address__c nca : [select id, Bill_To_Ship_To__c, Acct_By_Sub__c from NS_Customer_Address__c where Bill_To_Ship_To__c in :billToShipToIds and Acct_By_Sub__c in :accBySubIds]){
            if(btNCAMap.containsKey(nca.Bill_To_Ship_To__c)){
                ncaList = btNCAMap.get(nca.Bill_To_Ship_To__c);
                ncaList.add(nca);
            } else {
                ncaList = new list<NS_Customer_Address__c>();
                ncaList.add(nca);
                btNCAMap.put(nca.Bill_To_Ship_To__c, ncaList);
            }
        }
        system.debug('btNCAMap = ' + btNCAMap);
        for(Contract con1 : conList){
            if(con1.Ship_To__c  != null){
                if(btNCAMap.containsKey(con1.Ship_To__c )){
                    for(NS_Customer_Address__c custAdd : btNCAMap.get(con1.Ship_To__c )){
                        if(custAdd.Acct_By_Sub__c == con1.Billing_Group_Entity__c ){
                            con1.NS_Customer_Ship_To_Address__c = custAdd.Id;
                            break;
                        }
                    }
                }
            } else {
                con1.NS_Customer_Ship_To_Address__c = null;
            }
            if(con1.Bill_To__c  != null){
                if(btNCAMap.containsKey(con1.Bill_To__c )){
                    for(NS_Customer_Address__c custAdd : btNCAMap.get(con1.Bill_To__c )){
                        if(custAdd.Acct_By_Sub__c == con1.Billing_Group_Entity__c){
                            con1.NS_Customer_Address__c = custAdd.Id;
                            break;
                        }
                    }
                }
            } else {
                con1.NS_Customer_Address__c = null;
            }
        }
        
    }
    
    public static void beforeUpdate(Map<Id, Contract> newContracts, Map<Id, Contract> oldContracts){
        // Peter Sabry - NACM Billing - 12/6/2019: Trigger Before Update Functionality replaced by Sync Subscriptions button on contract.
        /*Map<Id, Billing_Group__c> bgMap = new Map<Id, Billing_Group__c>();
        Map<Id, SBQQ__Subscription__c> subsMap = new Map<Id, SBQQ__Subscription__c>();
        
        //Passing BG and Subs to methods as reference to prevent updating the same records more than once in the same trigger execution
        updateFixedDayMontth_RLFGoLiveDate(newContracts, oldContracts, bgMap, subsMap); 
        
        if(subsMap.size() > 0){
            update subsMap.values();
        }
        if(bgMap.size() > 0){
            update bgMap.values();
        }*/
    }
    
    public static void updateFixedDayMontth_RLFGoLiveDate(Map<Id, Contract> newContracts, Map<Id, Contract> oldContracts, Map<Id, Billing_Group__c> bgMap, Map<Id, SBQQ__Subscription__c> subsMap){
        system.debug('//In updateFixedDayMontth_RLFGoLiveDate fn');
        
        Map<Id, Contract> contractMap = new Map<Id, Contract>();
        
        for(Contract con: newContracts.values()){
            if(con.Fixed_Billing_Day__c != oldContracts.get(con.Id).Fixed_Billing_Day__c /*&& oldContracts.get(con.Id).Fixed_Billing_Day__c != null*/){
                contractMap.put(con.Id, con);
            }
            if(con.Fixed_Billing_Month__c != oldContracts.get(con.Id).Fixed_Billing_Month__c /*&& oldContracts.get(con.Id).Fixed_Billing_Month__c != null*/){
                contractMap.put(con.Id, con);
            }
            if(con.Billing_Frequency__c != oldContracts.get(con.Id).Billing_Frequency__c /*&& oldContracts.get(con.Id).Fixed_Billing_Month__c != null*/){
                contractMap.put(con.Id, con);
            }
            if(con.Recurring_Fees_Start_Planned__c != oldContracts.get(con.Id).Recurring_Fees_Start_Planned__c){
                contractMap.put(con.Id, con);
            }
        }
        
        if(contractMap.size() > 0){
            List<SBQQ__Subscription__c> subsList = new List<SBQQ__Subscription__c>();
            List<SBQQ__Subscription__c> planList = new List<SBQQ__Subscription__c>();
            
            for(SBQQ__Subscription__c sub: [SELECT Billing_day__c,SBQQ__BillingType__c, Next_Billing_Date__c,Next_SO_generation_Date__c ,SBQQ__BillingFrequency__c ,SO_Generation_Advance__c , Billing_month__c,SBQQ__Contract__c, Billing_Group__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: contractMap.keySet()]){
                if(contractMap.get(sub.SBQQ__Contract__c).Fixed_Billing_Day__c != null){
                    sub.Billing_Day__c = contractMap.get(sub.SBQQ__Contract__c).Fixed_Billing_Day__c;
                }
                if(contractMap.get(sub.SBQQ__Contract__c).Fixed_Billing_Month__c != null){
                    if(sub.SBQQ__BillingFrequency__c != 'Monthly' || sub.SBQQ__BillingFrequency__c != 'One Off')
                        sub.Billing_Month__c = contractMap.get(sub.SBQQ__Contract__c).Fixed_Billing_Month__c;
                }
                
                if(contractMap.get(sub.SBQQ__Contract__c).Recurring_Fees_Start_Planned__c != null /*&& contractMap.get(sub.SBQQ__Contract__c).BG_Created__c == true*/){
                    //                    //Check made to exclude these sub lines for RLF as part of REQ-2872
                    sub.RF_Start_Planned_Date__c = contractMap.get(sub.SBQQ__Contract__c).Recurring_Fees_Start_Planned__c;
                    //                    if(sub.Revenue_Type__c != 'On Premise RLF' || (sub.Revenue_Type__c == 'On Premise RLF' && contractMap.get(sub.SBQQ__Contract__c).Updated_RLF_Holiday_Lines__c == false)){
                    sub.Next_Billing_Date__c = contractMap.get(sub.SBQQ__Contract__c).Recurring_Fees_Start_Planned__c;                                        
                    //                        system.debug('//RLF sub lines touched on ContractTriggerMethods update trigger, sub.BilingType = '+sub.SBQQ__BillingType__c);
                    
                    if(sub.SBQQ__BillingType__c == 'Advance'){
                        sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c.addDays(-(Integer) sub.SO_Generation_Advance__c);
                        system.debug('came  here to advance '+sub.SO_Generation_Advance__c);
                    } else if(sub.SBQQ__BillingType__c == 'Arrears'){
                        sub.Next_SO_generation_Date__c = sub.Next_Billing_Date__c.addDays((Integer) sub.SO_Generation_Advance__c);
                    } if(sub.Next_SO_generation_Date__c < System.today()) {
                        sub.Next_SO_generation_Date__c = System.today().addDays(1);
                    }                 
                    //                    }    
                    planList.add(sub);
                }
                if(subsMap.containsKey(sub.Id)) {
                    SBQQ__Subscription__c existingSub = subsMap.get(sub.Id);
                    existingSub.Billing_Day__c = sub.Billing_Day__c;
                    existingSub.Billing_Month__c = sub.Billing_Month__c;
                    existingSub.Next_SO_generation_Date__c = sub.Next_SO_generation_Date__c;
                    existingSub.Next_Billing_Date__c = sub.Next_Billing_Date__c;
                    subsMap.put(sub.Id, existingSub);
                }
                else {
                    subsMap.put(sub.Id, sub);
                }
            }
            // update billing date
            Map<Id, List<Date>> bg_dates_map = SO_SubscriptionsGrouping.sortBillingDates(planList);
            List<Billing_Group__c> bgList = new List<Billing_Group__c>();
            for(Billing_Group__c bg: [SELECT Id, Next_Billing_Date__c, Next_SO_Generation_Date__c FROM Billing_Group__c WHERE Id IN: bg_dates_map.keySet()]){
                bg.Next_Billing_Date__c = bg_dates_map.get(bg.Id)[0];
                bg.Next_SO_Generation_Date__c = bg_dates_map.get(bg.Id)[1];
                if(bgMap.containsKey(bg.Id)) {
                    Billing_Group__c existingBg = bgMap.get(bg.Id);
                    existingBg.Next_Billing_Date__c = bg.Next_Billing_Date__c;
                    existingBg.Next_SO_Generation_Date__c = bg.Next_SO_Generation_Date__c;
                    bgMap.put(bg.Id, existingBg);
                }
                else {
                    bgMap.put(bg.Id, bg);
                }
            }
            // update billing date
            //updateBillingDate(planList);
        }
    }
    
    public static void updateBillingDate(List<SBQQ__Subscription__c> planList) {
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
    }
}