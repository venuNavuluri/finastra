/**
 * @File Name          : ILF_SOCreation.cls
 * @Description        : 
 * @Author             : venu.navuluri@finastra.com
 * @Group              : 
 * @Last Modified By   : venu.navuluri@finastra.com
 * @Last Modified On   : 04/06/2019, 17:19:11
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    20/05/2019, 15:09:25   venu.navuluri@finastra.com     Initial Version
**/
public with sharing class ILF_SOCreation {
    
    public static NS_Project__c addNSProject(SBQQ__Subscription__c s, Map<String, NS_Currency__c> nsCurrencyMap){
        NS_Project__c proj = new NS_Project__c();
        proj.Project_Name__c = s.SBQQ__Contract__r.SBQQ__Opportunity__r.Order_Number__c + ' - ' + s.Opportunity_Billing_Schedule__r.Name;
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
        proj.Project_Type__c = s.Sales_Order_Type__c;
        proj.OpenAir_Project_Stage__c = 'ILF Only';
        proj.NS_Project_Status__c = 'In Progress';
        proj.Project_Start_Date__c = s.SBQQ__Contract__r.CustomerSignedDate;
        proj.Customer__c = s.Billing_Group__r.Account_by_Sub__c;
        proj.Billing_Group__c = s.billing_group__c; 
        proj.Deferred_Account_Type__c = 'ILF';
        proj.NS_Cost_Centre_Internal_ID__c = s.SBQQ__Product__r.NS_Cost_Centre_ID__c != null ? s.SBQQ__Product__r.NS_Cost_Centre_ID__c : '61';   
        proj.Opportunity_Billing_Schedule__c = s.Opportunity_Billing_Schedule__c;
        proj.NS_Project_Product_Internal_Id__c = s.SBQQ__Product__r.NS_Product_Dimension_ID__c;
       /* if(nsProdMap.get(s.Inital_NS_Item__r.NS_Product_Dimension_ID__c) != null){
            proj.Project_Product__c = nsProdMap.get(s.Inital_NS_Item__r.NS_Product_Dimension_ID__c);
        }*/
        proj.NS_Deferred_Revenue_Account_Internal_Id__c = s.SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c;
        return proj;
    }

    public static NS_Project_Milestone__c addNSProjectMilestone(Opportunity_Billing_Schedule_Item__c obsItem, Id projId){
        NS_Project_Milestone__c projMilestone = new NS_Project_Milestone__c();
        if (obsItem.Narrative__c != null) {
            projMilestone.Name = obsItem.Narrative__c;
        } else {
            projMilestone.Name = obsItem.Name;
        }
        if (obsItem.Line_Estimated_Completion_Date__c == null) {
            projMilestone.Start_Date__c = obsItem.Opportunity_Billing_Schedule__r.Opportunity__r.CloseDate;
            projMilestone.Finish_No_Later_Than_Date__c = obsItem.Opportunity_Billing_Schedule__r.Opportunity__r.CloseDate;
        } else {
            projMilestone.Start_Date__c = obsItem.Line_Estimated_Completion_Date__c;
            projMilestone.Finish_No_Later_Than_Date__c = obsItem.Line_Estimated_Completion_Date__c;
        }
        projMilestone.Constraint_Type__c = 'Fixed Start';
        projMilestone.Status__c = 'In Progress';
        projMilestone.Drop_Dead_Date__c = obsItem.Line_Drop_Dead_Date__c;
        projMilestone.Sequence_Number__c = obsItem.Line_Milestone_Sequence__c;
        projMilestone.Milestone__c = true;
        projMilestone.Opportunity_Billing_Schedule_Item__c = obsItem.Id;       
        projMilestone.NS_Project__c = projId;
        projMilestone.CurrencyIsoCode = obsItem.Opportunity_Billing_Schedule__r.Opportunity__r.CurrencyIsoCode;
        return projMilestone;
    }
    
    public static NS_Customer_Billing_Schedule__c addNSCustomerBillingSchedule(NS_Project_Milestone__c projectMilestone){
        NS_Customer_Billing_Schedule__c cbs = new NS_Customer_Billing_Schedule__c();
        cbs.Name = projectMilestone.Opportunity_Billing_Schedule_Item__r.Opportunity_Billing_Schedule__r.Name + '-' + projectMilestone.NS_Project__r.Deferred_Account_Type__c;
        cbs.Project__c = projectMilestone.NS_Project__c;
        cbs.Line_Milestone__c = projectMilestone.Id;
        cbs.Line_Amount__c = projectMilestone.Opportunity_Billing_Schedule_Item__r.Line__c;
        cbs.Line_Milestone_Sequence__c = projectMilestone.Opportunity_Billing_Schedule_Item__r.Line_Milestone_Sequence__c;
        cbs.Opportunity_Billing_Schedule_Item__c = projectMilestone.Opportunity_Billing_Schedule_Item__c;
        cbs.CurrencyIsoCode = projectMilestone.Opportunity_Billing_Schedule_Item__r.CurrencyIsoCode;
        if (projectMilestone.Opportunity_Billing_Schedule_Item__r.Line_Estimated_Completion_Date__c == null) {
            cbs.Line_Estimated_Completion_Date__c = projectMilestone.Opportunity_Billing_Schedule_Item__r.Opportunity_Billing_Schedule__r.Opportunity__r.CloseDate;
        } else {
            cbs.Line_Estimated_Completion_Date__c = projectMilestone.Opportunity_Billing_Schedule_Item__r.Line_Estimated_Completion_Date__c;
        }
        cbs.Line_Drop_Dead_Date__c = projectMilestone.Opportunity_Billing_Schedule_Item__r.Line_Drop_Dead_Date__c;
        if (projectMilestone.Opportunity_Billing_Schedule_Item__r.Line_Amount_for_Milestone__c != null) {
            cbs.Line_Comment__c = projectMilestone.Opportunity_Billing_Schedule_Item__r.CurrencyIsoCode + ' ' + projectMilestone.Opportunity_Billing_Schedule_Item__r.Line_Amount_for_Milestone__c.format();
        }
        return  cbs;
    }

    public static Sales_Order__c addILFSalesOrder(Contract con, Billing_Group__c bg,  NS_Project__c proj, SBQQ__Subscription__c s, Map<String, NS_Currency__c> nsCurrencyMap){
        system.debug('proj id +> '+proj);
        Sales_order__c so = new Sales_Order__c();
        so.Billing_Group__c = bg.Id;
        so.order_type__c = 'ILF';
        so.NS_Form_Id__c = '126';
        so.CPQ_Billing__c = true;
        so.NS_Project__c = proj.Id;
        so.NS_Project_Number__c = proj.Name;
        so.NS_Cost_Centre_Internal_Id__c = proj.NS_Cost_Centre_Internal_ID__c;
        so.NS_Product_Analysis_Internal_Id__c = proj.NS_Project_Product_Internal_Id__c;
       // so.NS_Cost_Centre__c = proj.Project_Cost_Centre__c;
       // so.NS_Product__c = proj.Project_Product__c;
       // so.NS_Deferred_Revenue_Reclassification_Acc__c = nsAccMap.get(proj.NS_Deferred_Revenue_Account_Internal_Id__c).Id; 
      
        so.NS_Deferred_Rev_Rec_Acc_Internal_Id__c = proj.NS_Deferred_Revenue_Account_Internal_Id__c;
        so.Order_Sub_Type__c = proj.Deferred_Account_Type__c; 
        so.Bill_To_Customer__c = bg.Account_by_Sub__c;
        so.Opportunity__c = bg.Original_Opportunity__c;
        so.CurrencyIsoCode = bg.CurrencyIsoCode;
        so.Host_Processor__c = s.SBQQ__QuoteLine__r.SBQQ__Quote__r.Host_Processor__c;
        so.Reimburse_3rd_party_vendor_Internal_ID__c = 123;
        so.Total_Rebate_Amount__c = s.SBQQ__Contract__r.Total_Rebate_Amount__c;
        so.Total_Rebate_Percent__c = s.SBQQ__Contract__r.Total_Rebate_Percent__c;
        so.NS_Term__c = bg.Account_by_Sub__r.Account__r.NS_Term__c;
        so.SO_Credit_Controller__c = bg.Account_by_Sub__r.Account__r.Credit_Controller__c;
        if(nsCurrencyMap.get(bg.CurrencyIsoCode) != null){
            so.NS_Currency__c = nsCurrencyMap.get(bg.CurrencyIsoCode).Id;
        }
        so.Contract__c = con.id;
        so.NS_Rev_Rec_on_Commit__c = true;
        so.NS_AutoCalculate_VSOE_Allocation__c = true;
        so.Price_Level__c = 'Custom';
        so.Invoice_Credit_Body__c = 'ILF';
        so.Order_Status__c = 'Pending Approval';  
        //so.Order_Date__c = bg.Original_Opportunity__r.CloseDate;
        so.Order_Date__c = system.today();
        if(bg.Account_by_Sub__c != null){
            if(bg.Account_by_Sub__r.Account__c != null){
                so.PO_Required__c = bg.Account_by_Sub__r.Account__r.PO_Required__c;                                          
                so.NS_To_Be_Printed__c = bg.Account_by_Sub__r.Invoice_Delivery_Post__c;
                so.NS_To_Be_Emailed__c = bg.Account_by_Sub__r.Invoice_Delivery_Email__c;
            }
        }
        so.Transaction_is_VSOE_Bundle__c = true;
        so.Primary_Sales_Person__c = bg.Original_Opportunity__r.OwnerId;
       // so.Host_Processor__c = s.SBQQ__QuoteLine__r.SBQQ__Quote__r.Host_Processor__c;
        so.Contribution__c = 100; 
        if(bg.Original_Contract__c != null){
            so.Order_Start_Date__c = bg.Original_Contract__r.StartDate;
            so.Order_End_Date__c  = bg.Original_Contract__r.StartDate;
            so.NS_Contract_Date__c = bg.Original_Contract__r.CustomerSignedDate;
            if(bg.NS_Customer_Address__c != null && bg.NS_Customer_Ship_To_Address__c != null ){
                so.NS_Billing_Address__c = bg.NS_Customer_Address__c ;
                so.NS_Shipping_Address__c = bg.NS_Customer_Ship_To_Address__c;
            }
            so.Memo__c = bg.Original_Contract__r.Memo__c;     
        }
        return so;
    
    }
    
    public static Sales_Order_Item__c addILFSalesOrderItem(SBQQ__Subscription__c sub, Integer counter, Sales_Order__c so, Map<String, NS_Currency__c> nsCurrencyMap){
        
        Sales_Order_Item__c soi = new Sales_Order_Item__c();
        soi.Line__c = counter;
        soi.sales_order__c = so.Id;
        soi.Subscription__c = sub.id; 
        soi.Name = sub.SBQQ__Product__r.Name;
        soi.NS_Item__c = sub.SBQQ__Product__c;
        soi.Ship_From_Code__c = sub.Ship_From_Code__c; 
        soi.Non_GA__c = sub.SBQQ__Product__r.GA__c;
        soi.Authorized_Vendor__c = sub.Third_Party_Vendor__c;
        //soi.Tax_Code__c = sub.Initial_Sovos_Code__c;
        //soi.Internal_Costs__c = sub.Pearl_Internal_Cost__c;
       // soi.Software_Delivered__c = sub.Inital_NS_Item__r.NS_Default_Delivered__c;
        soi.Software_Delivered__c = true;
        soi.Quantity__c = sub.SBQQ__Quantity__c ;         
        if(sub.SBQQ__Quantity__c != null && sub.SBQQ__NetPrice__c != null && sub.SBQQ__Quantity__c > 0){
            soi.Rate__c = (sub.SBQQ__NetPrice__c / sub.SBQQ__Quantity__c).setScale(4); 
        } 
        soi.Amount__c =  sub.SBQQ__NetPrice__c; 
        soi.List_Value__c = sub.SBQQ__ListPrice__c;
       // soi.VSOE_Price__c = sub.ILF_Fair_Value__c;
       // soi.Fair_Value__c = sub.ILF_Fair_Value__c;
       // soi.VSOE_Allocation_Amount__c = sub.ILF_Fair_Value__c;
        soi.Rev_Rec_Start_Date__c = so.Order_Start_Date__c;
        soi.Rev_Rec_End_Date__c = so.Order_End_Date__c; 
       /* if(sub.ThirdParty_Costs_PO_Ccy__c != null) {
            soi.ThirdParty_Costs_PO_Ccy__c = sub.ThirdParty_Costs_PO_Ccy__c;
        }else{
            soi.ThirdParty_Costs_PO_Ccy__c = 0;
        }*/
        soi.Planned_Recurring_Billing_Start_Date__c = so.Order_Start_Date__c;
        soi.NS_Rev_Rec_Schedule_Internal_Id__c = sub.SBQQ__Product__r.NS_Rev_Rec_Template_ID__c; 
        //soi.Location__c = sub.Location__c;
       // soi.Licence_band__c = sub.Licence_Band__c;
        soi.CurrencyIsoCode = sub.Billing_Group__r.CurrencyIsoCode;
        soi.Description__c = soi.Name;
        soi.Discount__c = sub.SBQQ__PartnerDiscount__c ;
       // soi.ThirdParty_Recurring_Costs_PO_Ccy__c = sub.ThirdParty_Recurring_Costs_PO_Ccy__c;
        soi.Vendor_BSch_Trigger__c = 'Manual';
        soi.Create_3PP_Event__c = sub.SBQQ__Product__r.NS_Create_3PP_Event__c;
       /* if(sub.ThirdParty_PO_Currency__c  != null){
            soi.ThirdParty_PO_Currency__c = nsCurrencyMap.get(sub.ThirdParty_PO_Currency__c).Id;
        }*/
        //soi.X3PP_Discount__c = 0;
        //soi.Licence_Basis__c = sub.License_Metric__c;
        //if(sub.Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c != null && revScheduleMap.get(sub.Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c) != null) soi.Rev_Rec_Schedule__c = revScheduleMap.get(sub.Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c).Id;
        return  soi;
    }

    public static NS_Vendor_Billing_Schedule__c addVendorBillingScheule(Sales_Order__c so, Sales_Order_Item__c soItem, SBQQ__Subscription__c sub){
        NS_Vendor_Billing_Schedule__c vbs = new NS_Vendor_Billing_Schedule__c();
        
         // string name = so.NS_Project_Number__c + '-'+ sub.Inital_NS_Item__r.NS_3PP_Vendor_ID__c +'-'+ sub.Inital_NS_Item__r.UPID__c;
       string name = 'test';
        if(name != null) vbs.Name = name.replace('null', '');
        vbs.NS_Project__c = so.NS_Project__c;
        vbs.SOId_Plus_Line__c = soItem.Sales_Order__c + soItem.Line__c.format();
        vbs.SOI_Amount__c = soItem.ThirdParty_Costs_PO_Ccy__c;
        //vbs.CurrencyIsoCode = sub.ThirdParty_PO_Currency__c;
        vbs.Subscription_Id__c = sub.Id;
        return vbs;
    }
    
    public static void createVBSItem(NS_Vendor_Billing_Schedule__c[] vbsList, Id projectId) {
        List<Id> vbsIds = new List<Id>();
        Map < Id, NS_Vendor_Billing_Schedule__c > project_vbs_map = new Map < Id, NS_Vendor_Billing_Schedule__c > ();
        /*for (NS_Vendor_Billing_Schedule__c vbs: [SELECT Id, NS_Project__c, CurrencyIsoCode, SOI_Amount__c FROM NS_Vendor_Billing_Schedule__c WHERE Id IN: vbsList AND NS_Project__c != null]) {
            project_vbs_map.put(vbs.NS_Project__c, vbs);
            vbsIds.add(vbs.NS_Project__c);
        }*/
        List<NS_Project_Milestone__c> projMilestoneList = new List<NS_Project_Milestone__c>();
        projMilestoneList = [SELECT Id, NS_Project__c, Opportunity_Billing_Schedule_Item__r.Line__c FROM NS_Project_Milestone__c WHERE NS_Project__c =: projectId];
        List < NS_Vendor_Billing_Schedule_Line__c > vbsLineList = new list < NS_Vendor_Billing_Schedule_Line__c > ();
        for (NS_Vendor_Billing_Schedule__c vbs: [SELECT Id, NS_Project__c, CurrencyIsoCode, SOI_Amount__c FROM NS_Vendor_Billing_Schedule__c WHERE Id IN: vbsList AND NS_Project__c != null]) {
            for (NS_Project_Milestone__c pm: projMilestoneList) {
                //system.debug('quering running for Proj milestones');
                NS_Vendor_Billing_Schedule_Line__c vbsLine = new NS_Vendor_Billing_Schedule_Line__c();
                vbsLine.CurrencyIsoCode = vbs.CurrencyIsoCode;
                vbsLine.NS_Vendor_Billing_Schedule__c = vbs.id;
                vbsLine.NS_Project__c = vbs.NS_Project__c;
                vbsLine.NS_Project_Milestone__c = pm.id;
                vbsLine.Vendor_BSch_Trigger__c = 'On Payment';
                if (vbs.SOI_Amount__c != null && pm.Opportunity_Billing_Schedule_Item__r.Line__c != null) {
                    vbsLine.Amount__c = (Vbs.SOI_Amount__c * pm.Opportunity_Billing_Schedule_Item__r.Line__c) / 100;
                }
                vbsLineList.add(vbsLine);
            }
            
        }
        
        if (vbsLineList.size() > 0) {
            try {
                insert vbsLineList;
                system.debug('vbs item insered => ' + vbsLineList);
            }
            Catch(Exception Ex) {
                system.debug('vbs item failed => ' + ex.getMessage());
            }
        }
    }
    
}