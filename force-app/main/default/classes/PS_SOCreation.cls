public class PS_SOCreation {
    
    public static NS_Project__c addNSProject(SBQQ__Subscription__c s, Map<String, NS_Currency__c> nsCurrencyMap){
        
        NS_Project__c proj;
         
                proj = new NS_Project__c();
                proj.Project_Name__c = s.SBQQ__Contract__r.SBQQ__Opportunity__r.Order_Number__c + ' - ' + s.ProdType__c;
                if(nsCurrencyMap.get(s.Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode) != null){
                    proj.NS_Primary_Currency__c = nsCurrencyMap.get(s.Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode).Id; 
                }
                proj.CurrencyIsoCode = s.Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode;
                proj.Project_Region__c = s.Billing_Group__r.Account_by_Sub__r.Account__r.NS_Finance_Region__c;
                proj.Subsidiary__c = s.Billing_Group__r.BG_Misys_Billing_Entity__c;
                proj.Opportunity_Number__c = s.SBQQ__Contract__r.SBQQ__Opportunity__r.Order_Number__c;
                proj.SFDC_Opportunity_Stage__c = s.SBQQ__Contract__r.SBQQ__Opportunity__r.StageName;
                proj.SFDC_Opportunity_Close_date__c = s.SBQQ__Contract__r.SBQQ__Opportunity__r.CloseDate;
                proj.SFDC_Opportunity_Category__c = s.SBQQ__Contract__r.SBQQ__Opportunity__r.ForecastCategoryName;
                proj.SFDC_Opportunity_Probability__c = s.SBQQ__Contract__r.SBQQ__Opportunity__r.Probability;
                proj.PS_Top_Opportunity__c = s.SBQQ__Contract__r.SBQQ__Opportunity__r.PS_Top_Opportunity__c;
                proj.PS_Forecast_Probability__c = s.SBQQ__Contract__r.SBQQ__Opportunity__r.PS_Forecast_Probability__c;
                proj.Project_Type__c = 'GS-' + s.ProdType__c;
                proj.OpenAir_Project_Stage__c = 'Pending - PM';
                proj.NS_Project_Status__c = 'In Progress';
                proj.Project_Start_Date__c = s.SBQQ__Contract__r.CustomerSignedDate;
                proj.Customer__c = s.Billing_Group__r.Account_by_Sub__c;
                proj.Billing_Group__c = s.billing_group__c; 
                proj.Export_to_OpenAir__c = true;
                //proj.Project_Owner__c = s.Billing_Group__r.Original_Opportunity__r.OA_Project_Manager__c; // New
                //proj.Project_Director__c = s.Billing_Group__r.Original_Opportunity__r.OA_Project_Director__c; // new
                //proj.Project_Start_Date__c = s.Billing_Group__r.Original_Opportunity__r.PS_FC_Start_Date2__c; // Different
                //proj.OA_Project_Template__c = s.Billing_Group__r.Original_Opportunity__r.Project_Template__c; // New
                proj.NS_Project_Status__c = 'In Progress';
                //proj.PS_Practice_Name__c = s.Billing_Group__r.Original_Opportunity__r.PS_Practice_Name__c; // New
                //proj.PS_Practice_Unique_Code__c = s.Billing_Group__r.Original_Opportunity__r.PS_Practice_Unique_Code__c; //New
                //proj.NS_Project_Service_Type__c = s.Billing_Group__r.Original_Opportunity__r.NS_Project_Service_Type__c;  //New
                proj.NS_Cost_Centre_Internal_ID__c = s.SBQQ__Product__r.NS_Cost_Centre_ID__c != null ? s.SBQQ__Product__r.NS_Cost_Centre_ID__c : '61';   
                proj.Opportunity_Billing_Schedule__c = s.Opportunity_Billing_Schedule__c;
                proj.NS_Project_Product_Internal_Id__c = s.SBQQ__Product__r.NS_Product_Dimension_ID__c; 
                proj.Deferred_Account_Type__c = s.ProdType__c;
                proj.NS_Deferred_Revenue_Account_Internal_Id__c = s.SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c;
       
        system.debug('returning ps fron ns project crteation => '+proj);
        return proj;
    }
    
    public static Sales_Order__c addPSSalesOrder(Contract con, Billing_Group__c bg,  NS_Project__c proj, SBQQ__Subscription__c s, Map<String, NS_Currency__c> nsCurrencyMap){
        system.debug(' PS proj id +> '+proj);
        Sales_order__c so = new Sales_Order__c();
        so.Billing_Group__c = bg.Id;
        so.order_type__c = 'PS';
        so.NS_Form_Id__c = '125';
        so.CPQ_Billing__c = true;
        so.Sub_Group_Type__c = s.ProdType__C;
        so.NS_Project__c = proj.Id;
        so.NS_Project_Number__c = proj.Name;
        so.Host_Processor__c = s.SBQQ__QuoteLine__r.SBQQ__Quote__r.Host_Processor__c;
        so.NS_Cost_Centre_Internal_Id__c = proj.NS_Cost_Centre_Internal_ID__c;
        so.NS_Product_Analysis_Internal_Id__c = proj.NS_Project_Product_Internal_Id__c;
        so.NS_Deferred_Rev_Rec_Acc_Internal_Id__c = proj.NS_Deferred_Revenue_Account_Internal_Id__c;
        //if(proj.NS_Deferred_Revenue_Account_Internal_Id__c != null)
        //so.NS_Deferred_Revenue_Reclassification_Acc__c = NsAccountMap.get(Proj.NS_Deferred_Revenue_Account_Internal_Id__c).Id;
        so.Order_Sub_Type__c = proj.Deferred_Account_Type__c; 
        so.Bill_To_Customer__c = bg.Account_by_Sub__c;
        so.Opportunity__c = bg.Original_Opportunity__c;
        so.CurrencyIsoCode = bg.CurrencyIsoCode;                                     
        so.NS_Term__c = bg.Account_by_Sub__r.Account__r.NS_Term__c;
        so.SO_Credit_Controller__c = bg.Account_by_Sub__r.Account__r.Credit_Controller__c;
        if(nsCurrencyMap.get(bg.CurrencyIsoCode) != null){
            so.NS_Currency__c = nsCurrencyMap.get(bg.CurrencyIsoCode).Id;
        }
        so.Contract__c = con.id;
        so.NS_Rev_Rec_on_Commit__c = true;
        so.NS_AutoCalculate_VSOE_Allocation__c = true;
        so.Price_Level__c = 'Custom';
        so.Invoice_Credit_Body__c = 'PS';
        so.Order_Status__c = 'Pending Approval';
        so.Customer_PO_Number__c = bg.Original_Opportunity__r.Customer_PO__c;
        //so.Order_Date__c = bg.Original_Opportunity__r.CloseDate;
        so.Order_Date__c = system.today();
        so.Order_Type__c = 'PS';
        if(bg.Account_by_Sub__c != null){
            if(bg.Account_by_Sub__r.Account__c != null){
                so.PO_Required__c = bg.Account_by_Sub__r.Account__r.PO_Required__c;                                          
                so.NS_To_Be_Printed__c = bg.Account_by_Sub__r.Invoice_Delivery_Post__c;
                so.NS_To_Be_Emailed__c = bg.Account_by_Sub__r.Invoice_Delivery_Email__c;
            }
        }
        so.Transaction_is_VSOE_Bundle__c = true;
        so.Primary_Sales_Person__c = bg.Original_Opportunity__r.OwnerId;
        so.Contribution__c = 100;    
        so.PS_Practice_Name__c = Proj.PS_Practice_Name__c;
        so.PS_Practice_Unique_Code__c = Proj.PS_Practice_Unique_Code__c;
        if(bg.Original_Contract__c != null){
            so.Order_Start_Date__c = bg.Original_Contract__r.StartDate;
            so.Order_End_Date__c  = bg.Original_Contract__r.StartDate;
            
            so.NS_Contract_Date__c = bg.Original_Contract__r.CustomerSignedDate;
            if(bg.NS_Customer_Address__c != null && bg.NS_Customer_Ship_To_Address__c != null ){
                so.NS_Billing_Address__c = bg.NS_Customer_Address__c ; so.NS_Shipping_Address__c = bg.NS_Customer_Ship_To_Address__c;
            }
            so.Memo__c = bg.Original_Contract__r.Memo__c;     
        }
        return so;
    
    }

    public static Sales_Order_Item__c[] addPSSalesOrderItem(SBQQ__Subscription__c sub, Integer counter, Sales_Order__c So /*, map<String, NS_Revenue_Recognition_Template__c> revScheduleMap, map<String, NS_OpenAir_Revenue_Rules__c> internalIdOARevenueRuleMap,map<String, NS_List_Table__c> internalIdOABillingRuleMap*/){       
        
       List<Sales_Order_Item__c> soItemList = new List<Sales_Order_Item__c>();
        Sales_Order_Item__c soItem;
        
       /* if((sub.LineItem_Process_Type__c == 'SVFP' || sub.LineItem_Process_Type__c == 'SVFO' ||  sub.LineItem_Process_Type__c == 'SVF*'  || sub.LineItem_Process_Type__c == 'DVF2' || sub.LineItem_Process_Type__c == 'SVFF' || sub.LineItem_Process_Type__c == 'SPFP') 
           && sub.Opportunity_Billing_Schedule__c != null ){
               for(Opportunity_Billing_Schedule_Item__c oppBSI : [SELECT Id, Name, Narrative__c, Line__c FROM Opportunity_Billing_Schedule_Item__c WHERE Opportunity_Billing_Schedule__c =: sub.Opportunity_Billing_Schedule__c]){
                   
                   soItem = new Sales_Order_Item__c();
                   soItem.CurrencyIsoCode = sub.Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode;
                   soItem.Line__c = counter;
                   soItem.Sales_Order__c = so.Id;
                   soItem.Ship_From_Code__c = sub.Ship_From_Code__c; 
                   soItem.Subscription__c = sub.id; 
                   if(oppBSI.Narrative__c != null){
                       soItem.Name = oppBSI.Narrative__c;
                   } else {
                       soItem.Name = oppBSI.Name;
                   }  
                   if(so.NS_Cost_Centre__c != null)
                       soItem.PS_Cost_Centre__c = so.NS_Cost_Centre__c;
                   soItem.NS_Item__c = sub.SBQQ__Product__r.Id;
                   soItem.Initial_NS_Item__c = sub.Inital_NS_Item__c;
                   soItem.Non_GA__c = sub.Inital_NS_Item__r.GA__c;
                   // soItem.Software_Delivered__c = sub.Inital_NS_Item__r.NS_Default_Delivered__c;
                   soItem.Software_Delivered__c = true;
                   soItem.Quantity__c = sub.SBQQ__Quantity__c;
                   soItem.Discount__c = sub.Discount_Premium__c;
                   soItem.Fair_Value_Adjustment__c = sub.Fair_Value_Adjustment__c;
                   soItem.Rev_Rec_Start_Date__c = so.Order_Date__c;
                   soItem.Rev_Rec_End_Date__c = so.Order_Date__c;
                   soItem.Tax_Code__c = sub.Initial_Sovos_Code__c;
                   soItem.NS_Rev_Rec_Schedule_Internal_Id__c = sub.Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c; 
                   if(sub.ThirdParty_Costs_PO_Ccy__c != null) {
                       soitem.ThirdParty_Costs_PO_Ccy__c = sub.ThirdParty_Costs_PO_Ccy__c;
                   }else{
                       soitem.ThirdParty_Costs_PO_Ccy__c = 0;
                   }
                   if(sub.Sold_Value__c != null && oppBSI.Line__c != null){
                       soItem.Amount__c = (sub.Sold_Value__c * oppBSI.Line__c) / 100;
                       soItem.Rate__c = (sub.Sold_Value__c * oppBSI.Line__c) / 100;
                   }
                   if(sub.Fair_Value__c != null && oppBSI.Line__c != null){
                       soItem.VSOE_Price__c = (sub.Fair_Value__c * oppBSI.Line__c) / 100;
                       soItem.VSOE_Allocation_Amount__c = (sub.Fair_Value__c * oppBSI.Line__c) / 100;
                   }
                   if(sub.Reimbursable_Costs_Recovery_Value__c != null && oppBSI.Line__c != null){
                       soItem.Reimbursable_Costs_Recovery_Value__c = (sub.Reimbursable_Costs_Recovery_Value__c * oppBSI.Line__c) / 100;
                   }
                   if(sub.Reimbursable_Costs_Estimate__c != null && oppBSI.Line__c != null){
                       soItem.Reimbursable_Costs_Estimate__c = (sub.Reimbursable_Costs_Estimate__c * oppBSI.Line__c) / 100;
                   }
                   if(sub.ThirdParty_Contractor_Cost_Sold_Ccy__c != null && oppBSI.Line__c != null){
                       soItem.Third_Party_Contractor_Cost_deal_ccy__c = (sub.ThirdParty_Contractor_Cost_Sold_Ccy__c * oppBSI.Line__c) / 100;
                   }
                   if(sub.ThirdParty_Costs_Sold_Ccy__c != null && oppBSI.Line__c != null){
                       soItem.Third_Party_Costs_deal_currency__c = (sub.ThirdParty_Costs_Sold_Ccy__c * oppBSI.Line__c) / 100;
                   }
                   if(sub.Unrecoverable_Costs__c != null && oppBSI.Line__c != null){
                       soItem.Unrecoverable_Costs__c = (sub.Unrecoverable_Costs__c * oppBSI.Line__c) / 100;
                   }
                   if(sub.Internal_Costs__c != null && oppBSI.Line__c != null){
                       soItem.Internal_Costs__c = (sub.Internal_Costs__c * oppBSI.Line__c) / 100;
                   }
                   if(sub.Comm_Man_Price__c != null && oppBSI.Line__c != null){
                       soItem.List_Value__c = (sub.Comm_Man_Price__c * oppBSI.Line__c) / 100;
                   }
                   if(sub.Fair_Value__c != null && oppBSI.Line__c != null){
                       soItem.Fair_Value__c = (sub.Fair_Value__c * oppBSI.Line__c) / 100;
                   }
                   if(sub.SBQQ__UnitCost__c != null && oppBSI.Line__c != null){
                       soItem.Sales_Price__c = (sub.SBQQ__UnitCost__c * oppBSI.Line__c) / 100;
                   }
                   if(sub.Contractor_Hours_Total__c != null && oppBSI.Line__c != null){
                       soItem.Total_Number_Of_Contractor_Hours__c = (sub.Contractor_Hours_Total__c * oppBSI.Line__c) / 100;
                   }
                   if(sub.NonBillable_Hours_Total__c != null && oppBSI.Line__c != null){
                       soItem.Total_Number_Of_Non_Billable_Hours__c = (sub.NonBillable_Hours_Total__c * oppBSI.Line__c) / 100;
                   }
                   if(sub.Travel_Hours_Total__c != null && oppBSI.Line__c != null){
                       soItem.Total_Number_Of_Travel_Hours__c = (sub.Travel_Hours_Total__c * oppBSI.Line__c) / 100;
                   }
                   if(sub.Total_Chargeable_Hours__c != null && oppBSI.Line__c != null){
                       soItem.Total_Chargeable_Hours__c = (sub.Total_Chargeable_Hours__c * oppBSI.Line__c) / 100;
                       soItem.Total_Billable_Hours__c = (sub.Total_Chargeable_Hours__c * oppBSI.Line__c) / 100;
                   }
                   soItem.Per_Diem_List_Value__c = sub.List_Per_Diem_Value__c;
                   soItem.Per_Diem_Contracted_Value__c = sub.Sold_Per_Diem_Value__c;
                   if(oppBSI.Narrative__c != null){
                       soItem.Description__c = oppBSI.Narrative__c;
                   } else {
                       soItem.Description__c = oppBSI.Name;
                   }
                   if(sub.SBQQ__Product__r.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c != null && internalIdOARevenueRuleMap.containsKey(sub.SBQQ__Product__r.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c)){
                       soItem.OpenAir_Rev_Rec_Rule__c = internalIdOARevenueRuleMap.get(sub.SBQQ__Product__r.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c).Id;
                   }
                   if(sub.Inital_NS_Item__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c != null && internalIdOABillingRuleMap.containsKey(sub.SBQQ__Product__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c)){
                       soItem.OpenAir_Billing_Rule__c = internalIdOABillingRuleMap.get(sub.Inital_NS_Item__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c).Id;
                   }
                   if(sub.Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c != null && sub.Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c != null) {   
                       //system.debug('sub init item => '+sub.Inital_NS_Item__c);
                       soItem.Rev_Rec_Schedule__c = revScheduleMap.get(sub.Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c).Id;
                   }
                   soItem.Per_Diem_List_Value__c = sub.List_Per_Diem_Value__c;
                   soItemList.add(soItem);
               } 
           } */
        
         if((sub.ProdType__c == 'SVTM' || sub.ProdType__c == 'SVPT' ||  sub.ProdType__c == 'SVTT') 
               ){
                   soItem = new Sales_Order_Item__c();
                   soItem.CurrencyIsoCode = sub.Billing_Group__r.CurrencyIsoCode;
                   soItem.Line__c = counter;
                  // soItem.Initial_NS_Item__c = sub.Inital_NS_Item__c;
                   soItem.Subscription__c = sub.id; 
                   soItem.sales_order__c = so.Id; 
                  // if(so.NS_Cost_Centre__c != null)
                    //   soItem.PS_Cost_Centre__c = so.NS_Cost_Centre__c;
                   soItem.Name = sub.SBQQ__Product__r.Name;
       			   soItem.NS_Item__c = sub.SBQQ__Product__c;
                   soItem.Ship_From_Code__c = sub.Ship_From_Code__c; 
                   soItem.Non_GA__c = sub.SBQQ__Product__r.GA__c;
                   soItem.Authorized_Vendor__c = sub.Third_Party_Vendor__c;
                   soItem.Software_Delivered__c = true;
                   soItem.Quantity__c = sub.SBQQ__Quantity__c ;
                   soItem.Amount__c =  sub.SBQQ__NetPrice__c; 
                   soItem.List_Value__c = sub.SBQQ__ListPrice__c;
                   soItem.Ship_From_Code__c = sub.Ship_From_Code__c; 
                   if(sub.SBQQ__Quantity__c != null && sub.SBQQ__Quantity__c >0)
                   soItem.Rate__c = sub.SBQQ__NetPrice__c/sub.SBQQ__Quantity__c;
                   soItem.Rev_Rec_Start_Date__c = so.Order_Start_Date__c;
                   soItem.Rev_Rec_End_Date__c = so.Order_End_Date__c;
                   //soItem.VSOE_Price__c = sub.Fair_Value__c;
                   //soItem.VSOE_Allocation_Amount__c = sub.Fair_Value__c;
                   //soItem.Reimbursable_Costs_Recovery_Value__c = sub.Reimbursable_Costs_Recovery_Value__c;
                   //soItem.Reimbursable_Costs_Estimate__c = sub.Reimbursable_Costs_Estimate__c;
                   //soItem.Third_Party_Contractor_Cost_deal_ccy__c = sub.ThirdParty_Contractor_Cost_Sold_Ccy__c;
                   //soItem.Third_Party_Costs_deal_currency__c = sub.ThirdParty_Costs_Sold_Ccy__c;
                   //soItem.Per_Diem_List_Value__c = sub.List_Per_Diem_Value__c;
                   //soItem.Per_Diem_Contracted_Value__c = sub.Sold_Per_Diem_Value__c;
                   //soItem.Unrecoverable_Costs__c = soItem.Unrecoverable_Costs__c;
                   //soItem.Internal_Costs__c = sub.Internal_Costs__c;
                   //soItem.List_Value__c = sub.Comm_Man_Price__c;
                   //soItem.Fair_Value__c = sub.Fair_Value__c;
                   //soItem.Sales_Price__c = sub.SBQQ__UnitCost__c;
                   //soItem.Total_Number_Of_Contractor_Hours__c = sub.Contractor_Hours_Total__c;
                   //soItem.Total_Number_Of_Non_Billable_Hours__c = sub.NonBillable_Hours_Total__c;
                   //soItem.Total_Number_Of_Travel_Hours__c = sub.Travel_Hours_Total__c;
                   soItem.Description__c = sub.SBQQ__Product__r.Name;
                   //soItem.Discount__c = sub.Discount_Premium__c;
                   //soItem.Fair_Value_Adjustment__c = sub.Fair_Value_Adjustment__c;
                   //soItem.Total_Chargeable_Hours__c = sub.Total_Chargeable_Hours__c;   
                   soItemList.add(soItem);
               }
     /*   //Get T&E Customer Settings values
        list<T_And_E_Items__c> tAndEList = T_And_E_Items__c.getall().values();
        
        for(T_And_E_Items__c teItem : tAndEList){
            system.debug('so type' +so.NS_Project__r.Deferred_Account_Type__c);
            system.debug('tel type' +teItem.Sales_Order_Type__c);
             if((so.Order_Sub_Type__c == 'PS' && teItem.Sales_Order_Type__c == 'PS')
                            || (so.Order_Sub_Type__c == 'PSS' && teItem.Sales_Order_Type__c == 'PSS')
                            || (so.Order_Sub_Type__c == 'FED' && teItem.Sales_Order_Type__c == 'FED')
                            || (so.Order_Sub_Type__c == 'AC' && teItem.Sales_Order_Type__c == 'AC')
                            ){
                            soItem = new Sales_Order_Item__c();
                            soItem.CurrencyIsoCode = so.CurrencyIsoCode;
                            soItem.Line__c = counter;
                            soItem.sales_order__c = so.Id; 
                            soItem.Name = teItem.Name;
                            soItem.Description__c = teItem.Name;
                            soItem.PS_Cost_Centre__c = so.NS_Project__r.Project_Cost_Centre__c;
                            
                            if(prod2UPID.containsKey(teItem.UPID__c)){
                                soItem.NS_Item__c = prod2UPID.get(teItem.UPID__c).Id;
                            }
                            soItem.Quantity__c = teItem.Quantity__c;
                            soItem.Rate__c = teItem.Rate__c;
                            soItem.Amount__c = teItem.Quantity__c * teItem.Rate__c;
                            if(revScheduleMap.containsKey(teItem.Rev_Rec_Schedule_Internal_Id__c)){
                                soItem.Rev_Rec_Schedule__c = revScheduleMap.get(teItem.Rev_Rec_Schedule_Internal_Id__c).Id;
                            }
                            if(internalIdOARevenueRuleMap.containsKey(teItem.OA_Rev_Rec_Rule_Internal_Id__c)){
                                soItem.OpenAir_Rev_Rec_Rule__c = internalIdOARevenueRuleMap.get(teItem.OA_Rev_Rec_Rule_Internal_Id__c).Id;
                            }
                            if(internalIdOABillingRuleMap.containsKey(teItem.OA_Billing_Rule_Internal_Id__c)){
                                soItem.OpenAir_Billing_Rule__c = internalIdOABillingRuleMap.get(teItem.OA_Billing_Rule_Internal_Id__c).Id;
                            }
                            soItemList.add(soItem);
                        
                    }
        }*/
        
        return  soItemList;
    }
    
}