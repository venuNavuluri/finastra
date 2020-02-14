/*
    Created By: Abhinit Kohar
    Created Date: 18/03/2014
    Description: This class holds the support methods for SalesOrderTrigger trigger.
*/
public class SalesOrderTriggerMethods {

    //This method populates the internal ids of AccBySub, Project, NS Account, NS Currency, NS Cost Centre, NS Product, Order Type, NS Term,
    //NS Finance Region and NS Cash Accounting, SO Credit Controller, NS Billing Address and NS Shipping Address.
    public static void populateSalesOrder(map<id, Sales_Order__c> oldMap, map<id, Sales_Order__c> newMap, list<Sales_Order__c> newList){
        set<Id> accBySubIds = new set<Id>();
        set<Id> projectIds = new set<Id>();
        //set<Id> nsAccountIds = new set<Id>();
        set<string> nsAccountInternalIds = new set<string>();
        set<Id> nsCurrencyIds = new set<Id>();
        set<Id> nsCostCentreIds = new set<Id>();
        set<Id> nsProductIds = new set<Id>();
        set<Id> nsCustomerAddressIds = new set<Id>();
        set<Id> salesOrderIds = new set<Id>();
        map<Id, Sales_Order__c> soMap = new map<Id, Sales_Order__c>();
        map<Id, Sales_Order__c> soMap1 = new map<Id, Sales_Order__c>();
        Integer i = 0;
        for(Sales_Order__c salesOrder : newList){
            if(trigger.isBefore && trigger.isInsert){
                salesOrder.Synced_To_NS__c = false;
                salesOrder.NS_Push_Token__c = false;
            }
            //this is for setting up the NS Push token
            if(trigger.isBefore && trigger.isUpdate && 
                    salesOrder.Order_Type__c == 'RLF' && salesOrder.Ready_For_Export_To_NS__c == true && 
                    oldMap.get(salesOrder.Id).Ready_For_Export_To_NS__c == false &&
                    salesOrder.NS_Push_Token__c == false && salesOrder.Synced_To_NS__c == false){
                        
                if(i == 0){
                    //salesOrder.NS_Push_Token__c = true;
                    i++;
                }
            }
            if(trigger.isBefore && trigger.isUpdate && 
                    salesOrder.Order_Type__c == 'RLF' && salesOrder.Ready_For_Export_To_NS__c == true && 
                    oldMap.get(salesOrder.Id).NS_Push_Token__c == false &&
                    salesOrder.NS_Push_Token__c == true){
                        
                soMap.put(salesOrder.Id, salesOrder);
            }
            if(salesOrder.Bill_To_Customer__c != null){
                accBySubIds.add(salesOrder.Bill_To_Customer__c);
            }
            if(salesOrder.Primary_Partner__c != null){
                accBySubIds.add(salesOrder.Primary_Partner__c);
            }
            if(salesOrder.NS_Project__c != null){
                projectIds.add(salesOrder.NS_Project__c);
            }
            //if(salesOrder.NS_Deferred_Revenue_Reclassification_Acc__c != null){
              //  nsAccountIds.add(salesOrder.NS_Deferred_Revenue_Reclassification_Acc__c);
            //}
            if(salesOrder.NS_Deferred_Rev_Rec_Acc_Internal_Id__c != null){
                nsAccountInternalIds.add(salesOrder.NS_Deferred_Rev_Rec_Acc_Internal_Id__c);
            }
            
            if(salesOrder.NS_Currency__c != null){
                nsCurrencyIds.add(salesOrder.NS_Currency__c);
            }
            if(salesOrder.NS_Cost_Centre__c != null){
                nsCostCentreIds.add(salesOrder.NS_Cost_Centre__c);
            }
            if(salesOrder.NS_Product__c != null){
                nsProductIds.add(salesOrder.NS_Product__c);
            }
            if(salesOrder.NS_Billing_Address__c != null){
                nsCustomerAddressIds.add(salesOrder.NS_Billing_Address__c);
            }
            if(salesOrder.NS_Shipping_Address__c != null){
                nsCustomerAddressIds.add(salesOrder.NS_Shipping_Address__c);
            }
        }
        //this is for setting up the NS Push token
        if(trigger.isBefore && trigger.isUpdate && soMap != null && soMap.size() > 0){
            list<Sales_Order__c> soList = [select id from Sales_Order__c where Order_Type__c = 'RLF' and NS_Push_Token__c = true and id not in : soMap.keySet() limit 1];
            if(soList != null && soList.size() > 0){
                //soMap.values()[0].addError('There can only be one RLF Sales Order with NS Push Token as true');
                for(Sales_Order__c so : soMap.values()){
                    so.NS_Push_Token__c = false;
                }
            }
        }
        map<Id, Acct_By_Sub__c> actBySubMap = new map<Id, Acct_By_Sub__c>([select id, NS_Internal_Id__c, NS_Terms_Internal_Id__c, 
                        NS_Finance_Region_Internal_Id__c, Account__r.NS_Term__c, Account__r.NS_Finance_Region__c, NS_Cash_Accounting__c,  
                        Account__r.Credit_Controller__c from Acct_By_Sub__c where id in :accBySubIds ]);

        /*
        map<Id, NS_Account__c> nsAccountMap;
        if(nsAccountIds != null && nsAccountIds.size() > 0){
            nsAccountMap = new map<Id, NS_Account__c>([select id, NS_Account_Internal_Id__c from NS_Account__c 
                                                                            where id in :nsAccountIds ]);
        }
        */
        map<string, NS_Account__c> nsAccountMap = new map<string, NS_Account__c>();
        if(nsAccountInternalIds != null && nsAccountInternalIds.size() > 0){
            for(NS_Account__c nsAcc : [select id, NS_Account_Internal_Id__c from NS_Account__c 
                                                                            where NS_Account_Internal_Id__c in :nsAccountInternalIds ]){
                nsAccountMap.put(nsAcc.NS_Account_Internal_Id__c, nsAcc);
            }
        }
        
        map<Id, NS_Currency__c> nsCurrencyMap;
        if(nsCurrencyIds != null && nsCurrencyIds.size() > 0){
            nsCurrencyMap = new map<Id, NS_Currency__c>([select id, NS_Currency_Internal_Id__c from NS_Currency__c 
                                                                            where id in :nsCurrencyIds ]);
        }
        
        map<Id, NS_Cost_Centre__c> nsCostCentreMap;
        if(nsCostCentreIds != null && nsCostCentreIds.size() > 0){
            nsCostCentreMap = new map<Id, NS_Cost_Centre__c>([select id, NS_Cost_Centre_Internal_Id__c from NS_Cost_Centre__c 
                                                                            where id in :nsCostCentreIds ]);
        }

        map<Id, NS_Product__c> nsProductMap;
        if(nsProductIds != null && nsProductIds.size() > 0){
            nsProductMap = new map<Id, NS_Product__c>([select id, NS_Product_Internal_Id__c from NS_Product__c 
                                                                            where id in :nsProductIds ]);
        }

        map<Id, NS_Customer_Address__c> nsCustomerAddressMap;
        if(nsCustomerAddressIds != null && nsCustomerAddressIds.size() > 0){
            nsCustomerAddressMap = new map<Id, NS_Customer_Address__c>([select id, NS_Customer_Address_Internal_Id__c, Attention__c, 
                                                    Addressee__c, Address_1__c, Address_2__c, Address_3__c, City__c, 
                                                    County_State_Province__c, Postal_Zip_Code__c, NS_Country__c, Phone__c,
                                                    Billing_Contact_Email__c, Billing_Contact__c, Billing_Contact__r.NS_Internal_Id__c
                                                    from NS_Customer_Address__c 
                                                                            where id in :nsCustomerAddressIds ]);
        }
        
        NS_Revenue_Recognition_Template__c revRecType = [select id, name from NS_Revenue_Recognition_Template__c where Name = 'POC' limit 1];

        //populate Country Risk Rating and customer risk rating map for getting the internal ids
        map<string, string> listTableMap = new map<string, string>();
        for(NS_List_Table__c listTable : [select id, name, NS_Internal_Id__c, NS_List_Name__c from NS_List_Table__c where NS_List_Name__c = 'TransactionCategory' 
                                            or NS_List_Name__c = 'SalesRole' or NS_List_Name__c = 'InvoiceCreditBody' or NS_List_Name__c = 'PSPracticeName']){
            if(listTable.NS_List_Name__c == 'TransactionCategory'){
                listTableMap.put(listTable.name + 'TransactionCategory', listTable.NS_Internal_Id__c);
            } else if(listTable.NS_List_Name__c == 'SalesRole'){
                listTableMap.put(listTable.name + 'SalesRole', listTable.NS_Internal_Id__c);
            } else if(listTable.NS_List_Name__c == 'InvoiceCreditBody'){
                listTableMap.put(listTable.name + 'InvoiceCreditBody', listTable.NS_Internal_Id__c);
            } else if(listTable.NS_List_Name__c == 'PSPracticeName'){
                listTableMap.put(listTable.name + 'PSPracticeName', listTable.NS_Internal_Id__c);
            }
        }

        for(Sales_Order__c salesOrder : newList){
            if(salesOrder.Bill_To_Customer__c != null && actBySubMap!= null && actBySubMap.containsKey(salesOrder.Bill_To_Customer__c)){
                if(trigger.isInsert || (trigger.isUpdate && newMap.get(salesOrder.Id).Bill_To_Customer__c != oldMap.get(salesOrder.Id).Bill_To_Customer__c)){
                    salesOrder.NS_Term__c = actBySubMap.get(salesOrder.Bill_To_Customer__c).Account__r.NS_Term__c;
                    salesOrder.NS_Term_Internal_Id__c = actBySubMap.get(salesOrder.Bill_To_Customer__c).NS_Terms_Internal_Id__c;
                    salesOrder.NS_Finance_Region__c = actBySubMap.get(salesOrder.Bill_To_Customer__c).Account__r.NS_Finance_Region__c;
                    salesOrder.NS_Finance_Region_Internal_Id__c = actBySubMap.get(salesOrder.Bill_To_Customer__c).NS_Finance_Region_Internal_Id__c;
                    salesOrder.NS_Cash_Accounting__c = actBySubMap.get(salesOrder.Bill_To_Customer__c).NS_Cash_Accounting__c;
                    salesOrder.SO_Credit_Controller__c = actBySubMap.get(salesOrder.Bill_To_Customer__c).Account__r.Credit_Controller__c;
                }
            }
            if(salesOrder.Primary_Partner__c != null && actBySubMap!= null && actBySubMap.containsKey(salesOrder.Primary_Partner__c)){
                salesOrder.Primary_Partner_Internal_Id__c = actBySubMap.get(salesOrder.Primary_Partner__c).NS_Internal_Id__c;
            } else {
                salesOrder.Primary_Partner_Internal_Id__c = null;
            }
            if(salesOrder.NS_Deferred_Rev_Rec_Acc_Internal_Id__c != null && nsAccountMap!= null && nsAccountMap.containsKey(salesOrder.NS_Deferred_Rev_Rec_Acc_Internal_Id__c)){
                salesOrder.NS_Deferred_Revenue_Reclassification_Acc__c = nsAccountMap.get(salesOrder.NS_Deferred_Rev_Rec_Acc_Internal_Id__c).Id;
            } else {
                salesOrder.NS_Deferred_Revenue_Reclassification_Acc__c = null;
            }
            if(salesOrder.NS_Currency__c != null && nsCurrencyMap!= null && nsCurrencyMap.containsKey(salesOrder.NS_Currency__c)){
                salesOrder.NS_Currency_Internal_Id__c = nsCurrencyMap.get(salesOrder.NS_Currency__c).NS_Currency_Internal_Id__c;
            } else {
                salesOrder.NS_Currency_Internal_Id__c = null;
            }
            if(salesOrder.NS_Cost_Centre__c != null && nsCostCentreMap!= null && nsCostCentreMap.containsKey(salesOrder.NS_Cost_Centre__c)){
                salesOrder.NS_Cost_Centre_Internal_Id__c = nsCostCentreMap.get(salesOrder.NS_Cost_Centre__c).NS_Cost_Centre_Internal_Id__c;
            } else {
                salesOrder.NS_Cost_Centre_Internal_Id__c = null;
            }
            if(salesOrder.NS_Product__c != null && nsProductMap!= null && nsProductMap.containsKey(salesOrder.NS_Product__c)){
                salesOrder.NS_Product_Analysis_Internal_Id__c = nsProductMap.get(salesOrder.NS_Product__c).NS_Product_Internal_Id__c;
            } else {
                salesOrder.NS_Product_Analysis_Internal_Id__c = null;
            }
            if(salesOrder.NS_Billing_Address__c != null && nsCustomerAddressMap!= null && nsCustomerAddressMap.containsKey(salesOrder.NS_Billing_Address__c)){
                salesOrder.NS_Billing_Contact__c = nsCustomerAddressMap.get(salesOrder.NS_Billing_Address__c).Billing_Contact__c;
                salesOrder.NS_Billing_Contact_Internal_Id__c = nsCustomerAddressMap.get(salesOrder.NS_Billing_Address__c).Billing_Contact__r.NS_Internal_Id__c;
            } else {
                salesOrder.NS_Billing_Contact__c = null;
                salesOrder.NS_Billing_Contact_Internal_Id__c = null;
            }
            if(salesOrder.Order_Type__c != null && listTableMap.containsKey(salesOrder.Order_Type__c + 'TransactionCategory')){
                salesOrder.Order_Type_Internal_Id__c = listTableMap.get(salesOrder.Order_Type__c + 'TransactionCategory');
            } else {
                salesOrder.Order_Type_Internal_Id__c = null;
            }
            if(salesOrder.Sales_Role__c != null && listTableMap.containsKey(salesOrder.Sales_Role__c + 'SalesRole')){
                salesOrder.Sales_Role_Internal_Id__c = listTableMap.get(salesOrder.Sales_Role__c + 'SalesRole');
            } else {
                salesOrder.Sales_Role_Internal_Id__c = null;
            }
            if(salesOrder.Invoice_Credit_Body__c != null && listTableMap.containsKey(salesOrder.Invoice_Credit_Body__c + 'InvoiceCreditBody')){
                system.debug('Invoice_Credit_Body__c = ' + salesOrder.Invoice_Credit_Body__c);
                salesOrder.Invoice_Credit_Body_Internal_Id__c = listTableMap.get(salesOrder.Invoice_Credit_Body__c + 'InvoiceCreditBody');
            } else {
                salesOrder.Invoice_Credit_Body_Internal_Id__c = null;
            }
            if(salesOrder.PS_Practice_Name__c != null && listTableMap.containsKey(salesOrder.PS_Practice_Name__c + 'PSPracticeName')){
                system.debug('PS_Practice_Name__c = ' + salesOrder.PS_Practice_Name__c);
                salesOrder.PS_Practice_Name_Internal_Id__c = listTableMap.get(salesOrder.PS_Practice_Name__c + 'PSPracticeName');
            } else {
                salesOrder.PS_Practice_Name_Internal_Id__c = null;
            }
            //Setup taxation address
            if(salesOrder.Subsidiary_Country__c == salesOrder.NS_Bill_Country__c && salesOrder.Subsidiary_Country__c == salesOrder.NS_Ship_Country__c){
                salesOrder.NS_Taxation_Address__c = salesOrder.NS_Shipping_Address__c;
            } else if(salesOrder.Subsidiary_Country_Tax_on_Bill_to__c == true && salesOrder.Subsidiary_Country_Tax_on_POS__c == true){
                salesOrder.NS_Taxation_Address__c = salesOrder.NS_Shipping_Address__c;
            } else if(salesOrder.Subsidiary_Country_Tax_on_POS__c == true){
                salesOrder.NS_Taxation_Address__c = salesOrder.NS_Shipping_Address__c;
            } else if(salesOrder.Subsidiary_Country_Tax_on_Bill_to__c == true){
                salesOrder.NS_Taxation_Address__c = salesOrder.NS_Billing_Address__c;
            } else if(salesOrder.Subsidiary_Country_Tax_on_Bill_to__c == false && salesOrder.Subsidiary_Country_Tax_on_POS__c == false){
                salesOrder.NS_Taxation_Address__c = salesOrder.NS_Shipping_Address__c;
            }
            //Get the sales order ids for updating the related Sales Order Items with the ILF Rev Rec Type
            if(trigger.isUpdate && newMap.get(salesOrder.Id).Order_Type__c == 'ILF' && 
                newMap.get(salesOrder.Id).ILF_Rev_Rec_Type__c == 'POC' && 
                newMap.get(salesOrder.Id).ILF_Rev_Rec_Type__c != oldMap.get(salesOrder.Id).ILF_Rev_Rec_Type__c){
                
                salesOrderIds.add(salesOrder.Id);
            }
        }
        
        //update the SO Items with the POC Rev Rec Schedule
        if(trigger.isUpdate && salesOrderIds != null && salesOrderIds.size() > 0){
            list<Sales_Order_Item__c> soItems = new list<Sales_Order_Item__c>();
            for(Sales_Order_Item__c soItem : [select name, Rev_Rec_Schedule__c from Sales_Order_Item__c where Sales_Order__c in :salesOrderIds]){
                soItem.Rev_Rec_Schedule__c = revRecType.Id; 
                soItems.add(soItem);
            }
            if(soItems != null && soItems.size() > 0){
                update soItems;
            }
        }
    }
    
    //This method is for updating the "Has Sales Order" flag on the opportunity.
    //If there is a sales order on the opportunity then this flag should be checked
    //if all the sales orders are deleted from the opportunity then this flag should be unchecked
    public static void updateOpportunity(map<id, Sales_Order__c> oldMap, map<id, Sales_Order__c> newMap, list<Sales_Order__c> newList){
        
        if(trigger.isInsert){
            set<Id> oppIds = new set<Id>();
            for(Sales_Order__c salesOrder : newList){
                if(salesOrder.Opportunity__c != null && !salesOrder.CPQ_Billing__c){ // Venu Added - additional comparition added to bypass new CPQ SOs
                    oppIds.add(salesOrder.Opportunity__c);
                }
            }
            if(oppIds != null && oppIds.size() > 0){
                list<Opportunity> oppList = new list<Opportunity>();
                for(Opportunity opp : [select Id, Has_Sales_Orders__c from Opportunity where id in :oppIds and Has_Sales_Orders__c = false]){
                    opp.Has_Sales_Orders__c = true;
                    oppList.add(opp);
                }
                if(oppList != null && oppList.size() > 0){
                    update oppList;
                }
            }
        }
        if(trigger.isDelete){
            set<Id> oppIds = new set<Id>();
            for(Sales_Order__c salesOrder : oldMap.values()){
                if(salesOrder.Opportunity__c != null){
                    oppIds.add(salesOrder.Opportunity__c);
                }
            }
            if(oppIds != null && oppIds.size() > 0){
                for(Sales_Order__c so : [select Id, Opportunity__c from Sales_Order__c where Opportunity__c in : oppIds]){
                    if(oppIds.contains(so.Opportunity__c)){
                        oppIds.remove(so.Opportunity__c);
                    }
                }
            }
            if(oppIds != null && oppIds.size() > 0){
                list<Opportunity> oppList = new list<Opportunity>();
                for(Id oppId : oppIds){
                    Opportunity opportunity = new Opportunity(Id = oppId, Has_Sales_Orders__c = false);
                    oppList.add(opportunity);
                }
                if(oppList != null && oppList.size() > 0){
                    update oppList;
                }
            }
        }
        
    }
    
    /*
    //This method is not more used. The token is set via the Informatica jobs.
    public static void updateNSPushToken(map<id, Sales_Order__c> oldMap, map<id, Sales_Order__c> newMap, list<Sales_Order__c> newList){
        map<Id, Sales_Order__c> soMap1 = new map<Id, Sales_Order__c>();
        for(Sales_Order__c salesOrder : newList){
            if(trigger.isAfter && trigger.isUpdate && 
                    salesOrder.Order_Type__c == 'RLF' &&  
                    salesOrder.Synced_To_NS__c == true && oldMap.get(salesOrder.Id).Synced_To_NS__c == false &&
                    salesOrder.NS_Push_Token__c == false){
                        
                soMap1.put(salesOrder.Id, salesOrder);
            }
        }

        //pass the NS Push Token to the next RLF Sales Order
        if(trigger.isAfter && trigger.isUpdate && soMap1 != null && soMap1.size() > 0){
            list<Sales_Order__c> soList1 = [select id, NS_Push_Token__c from Sales_Order__c where Order_Type__c = 'RLF' and NS_Push_Token__c = false 
                                                and id not in : soMap1.keySet() and Ready_For_Export_To_NS__c = true and Synced_To_NS__c = false 
                                                and Failed_Integration__c = false limit 1];
            system.debug('soMap1 = ' + soMap1);
            system.debug('soList1 = ' + soList1);
            if(soList1 != null && soList1.size() > 0){
                soList1[0].NS_Push_Token__c = true;
                update soList1[0];
            }
        }
    }
    */
    
    
/*
 * @author Serhii Volynets sergey.volinets@weare4c.com
 * this method updates Subscritpion.Asset Size, Net Price when Asset Uplift Sales Order Status goes from Pending Fulfilment to Pending Approval
 * @param lnew - list of sales_order__c records before the update, corresponds to Trigger.new variable of sales_order__c trigger
 * @param mold - map of sales_order__c records after the updarte or null, corresponds to Trigger.oldMap variable 
 * */
    public static void applyNewILFSubsAssetSizeOnSubmit(list<sales_order__c> lnew, map<id,sales_order__c> mOld )
    {      //SEV: Asset Uplift, when the order is approved, we have to take all ILF asset uplift subscriptions, and update ILF Asset Size   
        set<id>sApprovedOrderId = new set<id>();
        set<id>sContractId = new set<id>();
        for(sales_order__c ord: lnew)
        {
            //if sales order status was changed from 'Pending Approval' to 'Pending Fulfilment'           
            if(ord.Order_Status__c == 'Pending Fulfilment' && mOld != null && mOld.get(ord.id).Order_Status__c == 'Pending Approval') {
                sApprovedOrderId.add(ord.id); // add this sales order to procedure
                sContractId.add(ord.Contract__c);
            }
        }
        //query RLF subs of SO contract of type asset uplift (same query from Asset_Uplift class)
        List<Contract> lContracts = [
            Select id, name, Account.FDIC_NCUA_Data__r.Id
            , Account.FDIC_NCUA_Data__r.Total_Assets__c, Account.FDIC_NCUA_Data__r.NCUA_Total_Assets__c, Account.FDIC_NCUA_Data__r.Loans_and_Leases__c, Account.FDIC_NCUA_Data__r.Loans_and_Leases_minus_Family_Residentia__c, Account.FDIC_NCUA_Data__r.Consumer_and_Commercial_Loans__c, Account.FDIC_NCUA_Data__r.Commercial_Loans__c, Account.FDIC_NCUA_Data__r.Total_Deposits__c, Account.FDIC_NCUA_Data__r.Member_Business_Loans__c, Account.Name, AccountId, Next_Asset_Uplift_Date__c
            ,Next_CPI_Uplift_Date__c
            ,Asset_Size__c
            ,Asset_Uplift_Source__c
            ,Manual_Asset_Size__c
            ,Manual_Uplift__c
            ,New_Asset_Size__c
            , (Select Id,
                SBQQ__Contract__r.Asset_Size__c,
                SBQQ__Contract__r.Asset_Uplift_Source__c,
                SBQQ__Contract__r.Manual_Asset_Size__c,
                SBQQ__Contract__r.Manual_Uplift__c,
                SBQQ__Contract__r.New_Asset_Size__c,
                Uplift_Multiplier__c,
                RLF_Uplift_Multiplier_Percent__c,
                Billing_Group__c,
                Billing_Method__c,
                Fair_Value__c,
                Name,
                Next_SO_generation_Date__c,
                SBQQ__BillingType__c,
                SBQQ__NetPrice__c,
                SO_Amount__c,
                SBQQ__Quantity__c,
               	Sales_Order_Type__c
                From SBQQ__Subscriptions__r where Asset_Uplift__c = true and Sales_Order_Type__c = 'RLF'
            )
            From Contract
            where id in: sContractId
        ];

        map <id,SBQQ__Subscription__c> mSubs = new map<id,SBQQ__Subscription__c>();
        for(Contract contr : lContracts) {
            //Update contract Asset Size to New Asset Size if not manual and to Manual Asset size if manual
            decimal newAssetSize;
            if(contr.Manual_Uplift__c) {
                newAssetSize = contr.Manual_Asset_Size__c;
            }
            else {
                newAssetSize = contr.New_Asset_Size__c;
            }
            
            decimal assetIncrease = newAssetSize - contr.Asset_Size__c; // determine the asset increase as a difference between new and old values
            contr.Asset_Size__c = newAssetSize;
            
            //Update Contract Last Asset Uplift Date
            contr.Last_Asset_Uplift_Date__c = Date.Today();
            
            List<SBQQ__Subscription__c> lRLFSubs = contr.SBQQ__Subscriptions__r;
            //REQ-2945 - Split Uplift accross RLF Lines
            if(lRLFSubs.size() > 0) {
                for(SBQQ__Subscription__c sub : lRLFSubs) {
                    //Uplift Multiplier and RLF Uplift Multiplier are populated through data migration to ensure the uplift is proportional to the subscription amount
                    decimal dAmount = assetIncrease * 
                        sub.Uplift_Multiplier__c *
                        sub.RLF_Uplift_Multiplier_Percent__c/100;
            
                    sub.SO_Amount__c = nvl(sub.SO_Amount__c) + dAmount; // increment SO_Amount__c on Asset Uplift amount
                    mSubs.put(sub.Id,sub);    
                }
            }
        }
        Savepoint sp = Database.setSavepoint();
        try {        
            update lContracts;
            update mSubs.values();
        } catch (Exception ex) {
            Database.rollback(sp);
            System.debug('Exception thrown in SalesOrderTriggerMethods class :' + ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' + ex.getStackTraceString());
            Throw ex;
        }
    }
 /*
 * @author Serhii Volynets sergey.volinets@weare4c.com
 * this method returns 0 if the input value is null, or input value
 * @param val - decimal value
 * @return  0 if the input value is null, or input value
 * */   
    public static decimal nvl(decimal val)
    {
        if(val == null)
            return 0;
        return val;
    }
}