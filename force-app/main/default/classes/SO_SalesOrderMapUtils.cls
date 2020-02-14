public class SO_SalesOrderMapUtils {     
    
    public static Map<String, NS_Currency__c> getNSCurrency_map(){ // one time call
        Map<String, NS_Currency__c> mRecords = new Map<String, NS_Currency__c>();        
        for(NS_Currency__c ns: [select id, Name, NS_Currency_Internal_Id__c, IsZeroDecimal__c from NS_Currency__c]){
            mRecords.put(ns.Name, ns);
        }
        return mRecords;
    }        
    
    public static Map<String, String> getNSProduct_map(){
        Map<String, String> mRecords = new Map<String, String>();        
        for(NS_Product__c ns: [SELECT Id, NS_Product_Internal_Id__c from NS_Product__c where NS_Product_Internal_Id__c != null]){
            mRecords.put(ns.NS_Product_Internal_Id__c, ns.Id);
        }
        return mRecords;
    }
    
    /*public static Map<Id, NS_Item__c> getNS_ItemMap(){
        Map<Id, NS_Item__c> mRecords = new Map<Id, NS_Item__c>();        
        for(NS_Item__c ns: [SELECT Id, Product__c FROM NS_Item__c WHERE Product__c != null]){
            mRecords.put(ns.Id, ns);
        }
        return mRecords;
    }*/
    
    public static Map<Date, NS_Fixed_Billing_Date__c> getFixedBillingDate_map(){ // one time call
        Map<Date, NS_Fixed_Billing_Date__c> mRecords = new Map<Date, NS_Fixed_Billing_Date__c>();  
        for(NS_Fixed_Billing_Date__c fbd: [select id, name, NS_Internal_Id__c, Date__c from NS_Fixed_Billing_Date__c where Date__c != null]){
            mRecords.put(fbd.Date__c, fbd);
        }
        return mRecords;
    }
    
    public static Map<String, NS_Cost_Centre__c> getNSCostCenter_map(){
        Map<String, NS_Cost_Centre__c> mRecords = new Map<String, NS_Cost_Centre__c>(); 
        for(NS_Cost_Centre__c cc : [select id, NS_Cost_Centre_Internal_Id__c from NS_Cost_Centre__c where NS_Cost_Centre_Internal_Id__c != null]){
            mRecords.put(cc.NS_Cost_Centre_Internal_Id__c, cc);
        }
        return mRecords;
    }
    
    /*public static Map<Id, Opportunity_Billing_Schedule__c> getBillingScheduleMap(){
        return new map<id, Opportunity_Billing_Schedule__c>([select id, name, Key__c,Subscription_Start_Type__c, Subscription_Option__c, Fixed_Billing_Date__c, Planned_Recurring_Billing_Start_Date__c, RLF_Start_Trigger__c from Opportunity_Billing_Schedule__c]);
    } */
    
    public static map<String, NS_Revenue_Recognition_Template__c> getRevScheduleMap(){        
        Map<String, NS_Revenue_Recognition_Template__c> revRecScheduleMap = new Map<String, NS_Revenue_Recognition_Template__c>();
        for(NS_Revenue_Recognition_Template__c revRecS : [select id, name, NS_Internal_Id__c from NS_Revenue_Recognition_Template__c where NS_Internal_Id__c != null]){
            revRecScheduleMap.put(revRecS.NS_Internal_Id__c, revRecS);
        }
        return revRecScheduleMap;
    }    
    
    //populate the map of NS OpenAire Revenue Rules
    public static map<String, NS_OpenAir_Revenue_Rules__c> getIntIdOARevRuleMap(){
        map<String, NS_OpenAir_Revenue_Rules__c> internalIdOARevenueRuleMap = new map<String, NS_OpenAir_Revenue_Rules__c>();
        for(NS_OpenAir_Revenue_Rules__c oaRevenueRule : [select id, name, NS_Internal_Id__c from NS_OpenAir_Revenue_Rules__c]){
            internalIdOARevenueRuleMap.put(oaRevenueRule.NS_Internal_Id__c, oaRevenueRule);            
        }
        return internalIdOARevenueRuleMap;
    }
    
    ////populate the map of NS OpenAire Billing Rules
    public static map<String, NS_List_Table__c> getIntIdOABillingRuleMap(){
        map<String, NS_List_Table__c> internalIdOABillingRuleMap = new map<String, NS_List_Table__c>();
        for(NS_List_Table__c oaBillingRule : [select id, name, NS_Internal_Id__c from NS_List_Table__c where NS_List_Name__c = 'OpenAirBillingRules']){
            internalIdOABillingRuleMap.put(oaBillingRule.NS_Internal_Id__c, oaBillingRule);
        }
        return internalIdOABillingRuleMap;
    }
   
    public static Map<String, Product2> getUPID(){
        
        set<String> upidSet = new set<String>();
        
        //Get T&E Customer Settings values
        list<T_And_E_Items__c> tAndEList = T_And_E_Items__c.getall().values();
        for(T_And_E_Items__c te : tAndEList){
            upidSet.add(te.UPID__c);
        }
        
        //get the Products
        map<String, Product2> upidProductMap = new map<String, Product2>();
        
             for(Product2 prod : [select id, Name, UPID__c from Product2 where UPID__c in :upidSet]){
                upidProductMap.put(prod.UPID__c, prod);
            }
            return upidProductMap;
        
           
        }
    
    
    // populate NS Account Map
    public static Map<String, NS_Account__c> getNsAccMap(){
        Map<String, NS_Account__c> retMap = new Map<String, NS_Account__c>();
        for(NS_Account__c acc: [SELECT Id, NS_Account_Internal_Id__c FROM NS_Account__c WHERE NS_Account_Internal_Id__c != null]){
            retMap.put(acc.NS_Account_Internal_Id__c, acc);
        }        
        return retMap;
    }
    
    public static Map<Id, Billing_Group__c> getbg_map(Id billingId){
        
        Map<Id, Billing_Group__c> bg_map = new Map<Id, Billing_Group__c>([SELECT
                                  Id, 
                                  name, 
                                  Original_Contract__c, 
                                  Account_by_Sub__r.Account__r.NS_Term__c, 
                                  Account_by_Sub__r.Account__r.Credit_Controller__c, 
                                  Account_by_Sub__r.Synced_To_NS__c,
                                  Original_Opportunity__r.Owner.FirstName, 
                                  Original_Opportunity__r.Owner.LastName, 
                                  Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, 
                                  Customer_PO_Number__c, 
                                  NS_Customer_Address__c, 
                                  NS_Customer_Ship_To_Address__c, 
                                  Original_Customer_Signed_Date__c, 
                                  BG_Contract_Date_migration__c, 
                                  NS_Subscription_Start_Date__c, 
                                  NS_Subscription_Start_Type__c, 
                                  Original_Opportunity__r.Customer_PO__c, 
                                  Original_Opportunity__r.CloseDate, 
                                  Original_Contract__r.Memo__c, 
                                  Account_by_Sub__r.Account__r.PO_Required__c, 
                                  Account_by_Sub__r.Invoice_Delivery_Post__c, 
                                  Account_by_Sub__r.Invoice_Delivery_Email__c, 
                                  Original_Opportunity__r.OwnerId, 
                                  Original_Contract__r.StartDate, 
                                  Original_Contract__r.CustomerSignedDate, 
                                  NS_Subscription_Option__c, 
                                  NS_Billing_Mode__c, 
                                  NS_Customer_Address__r.Synced_To_NS__c,
                                  NS_Customer_Ship_To_Address__r.Synced_To_NS__c,
                                  Account_by_Sub__r.Account__r.NS_Finance_Region__c,
                                  NS_Termination_Method__c, 
                                  Fixed_Billing_Date__c, 
                                  Reset_Next_Bill_Date__c, 
                                  BG_Next_Invoice_Due_Date__c, 
                                  NS_Specific_Invoice_Wording__c, 
                                  Set_Tax_Combo_Override__c, 
                                  Order_Sub_Type__c, 
                                  Original_Contract__r.ContractTerm, 
                                  Next_Billing_Date__c, 
                                  Next_SO_generation_Date__c, 
                                  Original_Contract__r.Contract_Expiry_Date__c, 
                                  BG_Client_Contracting_Name__c, 
                                  Original_Opportunity__r.CurrencyIsoCode, 
                                  Original_Contract__r.Recurring_Fees_Start_Planned__c,
                                  Account_by_Sub__c, 
                                  Original_Opportunity__c, 
                                  CurrencyIsoCode, 
                                  Current_Sales_Order_Start_Date__c, 
                                  NS_Subscription_Memo__c, 
                                  BG_Misys_Billing_Entity__c, 
                                  BG_Client_Bill_To__c, 
                                  BG_Client_Ship_To__c, 
                                  BG_Billing_Group_Active__c, 
                                  BG_Data_Status__c, 
                                  Original_Contract_Expiry_Date__c
                                  FROM
                                  Billing_Group__c
                                  WHERE
                                  Id  = : billingId]);
        system.debug('RTDebug bg_map => '+bg_map.values());
        
        return bg_map;
    }
    
    
    public static Integer getMonth(string month){  
        Integer intMonth = 0;
        if(month == 'January'){
            intMonth = 1;
        } else if(month == 'February'){
            intMonth = 2;
        } else if(month == 'March'){
            intMonth = 3;
        } else if(month == 'April'){
            intMonth = 4;
        } else if(month == 'May'){
            intMonth = 5;
        } else if(month == 'June'){
            intMonth = 6;
        } else if(month == 'July'){
            intMonth = 7;
        } else if(month == 'August'){
            intMonth = 8;
        } else if(month == 'September'){
            intMonth = 9;
        } else if(month == 'October'){
            intMonth = 10;
        } else if(month == 'November'){
            intMonth = 11;
        } else if(month == 'December'){
            intMonth = 12;
        }
        return intMonth;
    }
}