global with sharing Class Initial_RLF_Buttons { 
     
    WebService static String Sync2NS(Id soId){
        String response; 
        Sales_Order__c so = [SELECT Id, Ready_For_Export_To_NS__c, NS_Project__c, NS_Billing_Address__r.Synced_To_NS__c, NS_Shipping_Address__r.Synced_To_NS__c, NS_Shipping_Address__c, NS_Billing_Address__c  FROM Sales_Order__c WHERE Id =: soId];
        if(so.NS_Billing_Address__c == null || so.NS_Shipping_Address__c == null){
            response = 'NS Billing Address / NS Shipping Address is blank.\nPlease fill NS Billing Address / NS Shipping Address and click the button again.';
            
        }else if(so.NS_Billing_Address__r.Synced_To_NS__c == false){
            response = 'NS Billing Address is not in Netsuite, please check the details';
        }else if(so.NS_Shipping_Address__r.Synced_To_NS__c == false){
            response = 'NS Shipping Address is not in Netsuite, please check the details';
        } else{
            so.Ready_For_Export_To_NS__c = true;        
            try{
                update so;
                if(so.NS_Project__c != null){
                    update new NS_Project__c(Id = so.NS_Project__c, Sales_Order_Ready__c  = true);
                }
                response = 'Pushed Successfully!';
            } Catch (Exception Ex){ return 'Error: '+Ex.getMessage();}
            
        }
        return response;
        
    }
    
    Webservice static void invokeUplitUtils(Id upliftId){
        List<Id> upliftIds = new List<Id>();
        upliftIds.add(upliftId);
        UpliftUtils.createUplift([SELECT Id FROM Uplift__c WHERE Id IN: upliftIds ]);
    }
    
    
    
    Webservice static String createRLF(Id billingId){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        String result = '';
     /*   Map<Id, Billing_Group__c> bg_map = new Map<Id, Billing_Group__c>([SELECT
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
                                  Id  = : billingId]);*/
        
        Map<Id, Billing_Group__c> bg_map = SO_SalesOrderMapUtils.getbg_map(billingId);
        
        system.debug('RTDebug bg_map => '+bg_map.values());
        
        for(Billing_Group__c bg: bg_map.values()){
            
            result = '';
            if(bg.Account_by_Sub__c == null || !bg.Account_by_Sub__r.Synced_To_NS__c)  result += 'Account By Sub is not in Netsuite, please check Acc By Sub details. \n\n';
            if(bg.NS_Customer_Address__c == null || !bg.NS_Customer_Address__r.Synced_To_NS__c ) result +=  'NS Customer Address is empty or  not in Netsuite, please check NS Customer Address details. \n\n';
            if(bg.NS_Customer_Ship_To_Address__c == null || !bg.NS_Customer_Ship_To_Address__r.Synced_To_NS__c ) result +=  'NS Customer Ship To Address is empty or  not in Netsuite, please check NS Customer Ship To Address details. \n\n';
            if(bg.Account_by_Sub__r.Account__r.NS_Finance_Region__c == null) result +=   'Ns Financial region is empty on this billing group';
        }
        system.debug('result => '+result);
        
        if(result != '') {
          return result; 
        } 
        
         for(SBQQ__Subscription__c sub: [ SELECT
                                   Id, 
                                   Billing_Group__c,
                                   Billing_Day__c, 
                                   Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode,
                                   Billing_Group__r.CurrencyIsoCode, 
                                   Billing_Month__c,
                                   BG_Next_Billing_Date__c, 
                                   Comm_Man_Price__c, 
                                   Contractor_Hours_Total__c, 
                                   Discount_premium__c, 
                                   Expiry_Date__c, 
                                   Fair_Value__c, 
                                   Fair_Value_Adjustment__c, 
                                   Initial_Sales_Order_Type__c, 
                                   Internal_Costs__c, 
                                   Last_Prorata_Calculated__c, 
                                   Last_Prorata_required__c, 
                                   Licence_Band__c, 
                                   License_Metric__c, 
                                   LineItem_Process_Type__c, 
                                   List_Per_Diem_Value__c, 
                                   Location__c, 
                                   Next_Billing_Date__c, 
                                   Next_SO_generation_Date__c, 
                                   NonBillable_Hours_Total__c, 
                                   NS_Deferred_Revenue_Acct_ID__c, 
                                   Opportunity_Billing_Schedule__c, 
                                   Pearl_Internal_Cost__c, 
                                   Pro_Rata_Calculated__c, 
                                   Prorata_Days__c, 
                                   Recurring_NS_Item__c, 
                                   Recurring_NS_Item__r.GA__c, 
                                   Recurring_NS_Item__r.NS_Cost_Centre_ID__c, 
                                   Recurring_NS_Item__r.NS_Default_Delivered__c, 
                                   Recurring_NS_Item__r.NS_Form_ID__c, 
                                   Recurring_NS_Item__r.NS_Product_Dimension_ID__c, 
                                   Recurring_NS_Item__r.NS_Rev_Rec_Template_ID__c, 
                                   Recurring_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c, 
                                   Recurring_Sales_Order_Type__c, 
                                   Reimbursable_Costs_Estimate__c, 
                                   Reimbursable_Costs_Recovery_Value__c, 
                                   RF_Start_Planned__c, 
                                   RF_Start_Planned_Date__c,
                                   Recurring_Sovos_Code__c,
                                   SBQQ__BillingFrequency__c, 
                                   SBQQ__BillingType__c, 
                                   SBQQ__ListPrice__c, 
                                   SBQQ__NetPrice__c, 
                                   SBQQ__PartnerDiscount__c, 
                                   SBQQ__Product__c, 
                                   SBQQ__Product__r.GA__c, 
                                   SBQQ__Product__r.Name, 
                                   SBQQ__Product__r.NS_3PP_Vendor_ID__c, 
                                   SBQQ__Product__r.NS_Create_3PP_Event__c, 
                                   SBQQ__Product__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c, 
                                   SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c, 
                                   SBQQ__Product__r.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c, 
                                   SBQQ__Product__r.NS_Rev_Rec_Template_ID__c, 
                                   SBQQ__Product__r.Payaway__c, 
                                   SBQQ__Product__r.UPID__c, 
                                   SBQQ__Quantity__c, 
                                   SBQQ__StartDate__c, 
                                   SBQQ__EndDate__c, 
                                   SBQQ__UnitCost__c, 
                                   SO_Generation_Advance__c, 
                                   Sold_Per_Diem_Value__c, 
                                   Sold_Value__c, 
                                   Ship_From_Code__c,
                                   ThirdParty_Contractor_Cost_Sold_Ccy__c, 
                                   ThirdParty_Costs_PO_Ccy__c, 
                                   ThirdParty_Costs_Sold_Ccy__c, 
                                   ThirdParty_PO_Currency__c, 
                                   ThirdParty_Recurring_Costs_PO_Ccy__c, 
                                   Total_Chargeable_Hours__c, 
                                   Travel_Hours_Total__c, 
                                   Transactional__c, 
                                   Transactions__c, 
                                   unrecoverable_costs__c, 
                                   X3PP_Currency__c, 
                                   X3PP_Discount__c
                                   FROM
                                   SBQQ__Subscription__c
                                   WHERE
                                   Recurring_Sales_Order_Type__c  LIKE 'RLF%'  
                                   AND  Recurring_NS_Item__c != null  
                                   AND Next_Billing_Date__c != null
                                   AND BG_Next_Billing_Date__c = TRUE
                                   AND Expired_Subscription__c = false
                                   AND Billing_Status__c = 'Active billing'
                                    AND Billing_Group__c in : bg_map.keySet()
                                   ORDER BY
                                   Recurring_Sales_Order_Type__c
                                             ] ){
                    if(bg_subList_Map.get(sub.Billing_Group__c)!=null) {
                        bg_subList_Map.get(sub.Billing_Group__c).add(sub);
                    } else {
                        bg_subList_Map.put(sub.Billing_Group__c,new List<SBQQ__Subscription__c>{sub});
                    }
        }
        
        system.debug('RTDebug bg subs map => '+bg_subList_Map.values());  
        if(!bg_subList_Map.values().isEmpty()){
            return RLF_Utils.invoke(bg_subList_Map, bg_map.get(billingId));
        } else {
            return  'Billing Group has no matching subscriptions, Please check Subscriptions Billing Status, Next SO Generation Date, Expiry Date, Recurring NS Item';
        }
        
    }
    
    
    
}