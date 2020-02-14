global class RecurringSalesOrder_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    global final String Query;
    global Map<Id, String> bg_response_map;
    global List<Id> bgIdList;
    global set<Billing_Group__c> bgErrList;
    global set<Billing_Group__c> bgSucsList;
    
    global RecurringSalesOrder_Batch(){
        query = 'SELECT Id, Name, Recurring_Batch_Error_Logs__c,  Original_Contract__r.Recurring_Fees_Start_Planned__c,Account_by_Sub__r.Account__r.NS_Finance_Region__c,NS_Customer_Address__r.Synced_To_NS__c,NS_Customer_Ship_To_Address__r.Synced_To_NS__c,Account_by_Sub__r.Synced_To_NS__c, BG_Opportunity_Number_s_migration__c, Next_Billing_Date__c,Original_Contract__c, Account_by_Sub__r.Account__r.NS_Term__c,Account_by_Sub__r.Account__r.Credit_Controller__c,Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName,Original_Contract__r.Contract_Expiry_Date__c,Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, NS_CUstomer_Address__c,NS_Customer_Ship_To_Address__c, Original_Customer_Signed_Date__c, BG_Contract_Date_migration__c, NS_Subscription_Start_Date__c, NS_Subscription_Start_Type__c, Original_Opportunity__r.Customer_PO__c,Original_Opportunity__r.CloseDate,Original_Contract__r.Memo__c,Account_by_Sub__r.Account__r.PO_Required__c, Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate, Original_Contract__r.CustomerSignedDate,NS_Subscription_Option__c,NS_Billing_Mode__c, NS_Termination_Method__c, Next_SO_generation_Date__c,Fixed_Billing_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c, NS_Specific_Invoice_Wording__c, Set_Tax_Combo_Override__c, Order_Sub_Type__c, BG_Client_Contracting_Name__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__c, Original_Opportunity__c, CurrencyIsoCode, Current_Sales_Order_Start_Date__c, NS_Subscription_Memo__c , BG_Misys_Billing_Entity__c, BG_Client_Bill_To__c , BG_Client_Ship_To__c, BG_Billing_Group_Active__c, BG_Data_Status__c, Original_Contract_Expiry_Date__c , Original_Contract__r.ContractTerm FROM BIlling_GROUP__C WHERE Next_SO_generation_Date__c <= TODAY And  Hold_Billing__c  = false AND BG_Billing_Group_Active__c = true ';  //Id =  \'a160E000000faaY\' ';    
        bgIdList = new List<Id>(); 
        bgErrList = new set<Billing_Group__c>();
        bgSucsList = new set<Billing_Group__c>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) { 
        set<Billing_Group__c> bgErrorsList = new set<Billing_Group__c>();
        set<Billing_Group__c> bgSuccessList = new set<Billing_Group__c>();
        string response; 
        boolean flag = false;
        Map<Id, Billing_Group__c> bg_map = new Map<Id, Billing_Group__c>();
        Map<date, Billing_Group__c> bg_nsd = new Map<date, Billing_Group__c>();
        
        for(Billing_Group__c bg:(Billing_Group__c[]) Scope){
            bg_map.put(bg.Id, bg);
            bg_nsd.put(bg.Next_SO_generation_Date__c, bg);   
        }
        
        bgIdList.addAll(bg_map.keySet()); 
        system.debug('all bg ids' +bgIdList.size());
        // system.debug('test' +bgErrorsList.size());
        
        Map<Id, Billing_Group__c> bgMap = new Map<Id, Billing_Group__c>( [  SELECT 
                                                                              Id
                                                                            FROM 
                                                                              Billing_Group__c 
                                                                            WHERE 
                                                                              Id IN: bg_map.keySet() 
                                                                              AND Account_by_Sub__r.Synced_To_NS__c = true
                                                                              AND (NS_Customer_Address__r.Synced_To_NS__c = TRUE OR NS_Customer_Address__c != null)
                                                                              AND (NS_Customer_Ship_To_Address__r.Synced_To_NS__c = TRUE OR NS_Customer_Ship_To_Address__c != null)
                                                                              AND Account_by_Sub__r.Account__r.NS_Finance_Region__c != null ]);
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
         for(SBQQ__Subscription__c sub: [ SELECT
                                            Billing_Group__c,
                                            Billing_Day__c, 
                                            Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode, 
                                            Billing_Group__r.CurrencyIsoCode,
                                            Billing_Month__c, 
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
                                            Recurring_Sovos_Code__c,
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
                                            Transactional__c ,
                                            Transactions__c ,
                                            unrecoverable_costs__c, 
                                            X3PP_Currency__c, 
                                            X3PP_Discount__c
                                          FROM
                                            SBQQ__Subscription__c 
                                          WHERE 
                                            Recurring_Sales_Order_Type__c LIKE 'RLF%'
                                            AND Next_SO_generation_Date__c IN: bg_nsd.keySet()
                                            AND Billing_Status__c = 'Active billing'
                                            AND Expired_Subscription__c = false
                                            AND Recurring_NS_Item__c != null
                                            AND Next_Billing_Date__c != null
                                            AND Billing_Group__c in : bgMap.keySet()
                                          ORDER BY 
                                            Recurring_Sales_Order_Type__c ]){
                                    if(bg_subList_Map.get(sub.Billing_Group__c)!=null) {
                                        bg_subList_Map.get(sub.Billing_Group__c).add(sub);
                                    } else {
                                        bg_subList_Map.put(sub.Billing_Group__c,new List<SBQQ__Subscription__c>{sub});
                                    }
                                  }
        
        system.debug('bg subs map => '+bg_subList_Map.size());
        
        // Error1: add BGs with no subs to Log Error
        
        for(Id bgId: bg_map.keyset()){
            system.debug('printing Bg => subs => '+bg_subList_Map.get(bgId));
            flag = false;
            response = '';
            if( !bg_subList_Map.containsKey(bgId) || (bg_subList_Map.containsKey(bgId) && bg_subList_Map.get(bgId).size() == 0)){
                if(!bg_map.get(bgId).Account_by_Sub__r.Synced_To_NS__c){
                    response += 'Account By Sub is not in Netsuite, please check Acc By Sub details. \n';
                    flag = true;
                }
                if(!bg_map.get(bgId).NS_Customer_Address__r.Synced_To_NS__c || bg_map.get(bgId).NS_Customer_Address__c == null ){
                    response += 'NS Customer Address is empty or  not in Netsuite, please check NS Customer Address details.\n';
                    flag = true;
                }
                if(!bg_map.get(bgId).NS_Customer_Ship_To_Address__r.Synced_To_NS__c || bg_map.get(bgId).NS_Customer_Ship_To_Address__c == null){
                    response += 'NS Customer Ship to Address is empty or  not in Netsuite, please check NS Customer Address details.\n';  
                    flag = true;
                }
                if(bg_map.get(bgId).Account_by_Sub__r.Account__r.NS_Finance_Region__c == null){
                    response += 'NS Financial region is empty on this billing group.\n';  
                    flag = true;
                }
                if(!flag){
                    response += 'No Subscriptions found for this Billing Group.'; 
                    
                }
                bgErrorsList.add(new Billing_Group__c(Id = bgId, Recurring_Batch_Error_Logs__c = response));   
            }
            
        }
        
        system.debug('bgErrorsList => '+bgErrorsList); 
        
        // INIT Maps
        Map < String, String > nsProductMap = SO_SalesOrderMapUtils.getNSProduct_map();
        Map < String, NS_Cost_Centre__c > nsCostCenterMap = SO_SalesOrderMapUtils.getNSCostCenter_map();
        Map < String, NS_Currency__c > nsCurrencyMap = SO_SalesOrderMapUtils.getNSCurrency_map();
        Map<String, NS_Revenue_Recognition_Template__c> revRecScheduleMap = SO_SalesOrderMapUtils.getRevScheduleMap();
        
        // finding max sub - with out query
        
        Double tempMax = 0;
        
        Map<Id, SBQQ__Subscription__c> bg_subMax_map = new Map<Id, SBQQ__Subscription__c>();
        for(String s: bg_subList_Map.keySet()){
            /*
            SBQQ__Subscription__c subMax = new SBQQ__Subscription__c();   
            
            for(SBQQ__Subscription__c sub: bg_subList_Map.get(s)){
            if (sub.SBQQ__NetPrice__c == null) sub.SBQQ__NetPrice__c = 0;
            if(sub.SBQQ__NetPrice__c > subMax.SBQQ__NetPrice__c){
            subMax = sub; 
            }
            tempMax = sub.SBQQ__NetPrice__c;
            system.debug('max net price' +tempMax);
            }
            */
            
            if(bg_subList_Map.get(s).size() > 0){
                bg_subMax_map.put(s, bg_subList_Map.get(s)[0]);
            }
            
        } 
        
        system.debug('bg sub max map => '+bg_subMax_map);
        // calcualte prorata
        List<SBQQ__Subscription__c> prorata_subList = RLFPackage_ListInit.calculateProrata(bg_subList_Map);  
        Set<SBQQ__Subscription__c> prorata_subSet =  new Set<SBQQ__Subscription__c>();
        if(prorata_subList.size() > 0) 
            prorata_subSet.addAll(prorata_subList);
        
        // Create Sales Order
        List<Sales_Order__c> soList = new List<Sales_Order__c>();
        Sales_Order__c RLFso;
        for(Id bgId: bg_subMax_map.keySet()){
            if(bg_subMax_map.get(bgId) != null){
                RLFso = RLFPackage_ListInit.addRLFSalesOrder(bg_map.get(bgId), nsCurrencyMap, nsProductMap, nsCostCenterMap,'RLF', bg_subMax_map.get(bgId));    
                RLFso.Ready_For_Export_To_NS__c = true;
                soList.add(RLFso); 
            } else {
                bgErrorsList.add(new Billing_Group__c(Id = bgId, Recurring_Batch_Error_Logs__c = 'Unable to Create Sales Order. Error => SubMax cannot be retrieved'));
            }
        }
        
        if(soList.size() > 0){                
            Database.SaveResult[] srList = Database.insert(soList, false);
            Integer i = 0;
            // looping over solist
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {                    
                    System.debug('Successfully inserted. Sales Order ID: ' + sr.getId());
                }
                else {                   
                    for(Database.Error err : sr.getErrors()) {
                        //System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Sales Order fields that affected this error: ' + err.getFields());
                        bgErrorsList.add(new Billing_Group__c(Id = soList[i].Billing_Group__c, Recurring_Batch_Error_Logs__c = 'Unable to Create Sales Order. Error => '+err.getMessage()));
                    }
                }
                i++;
            }
            
        }
        system.debug('success bg' +soList.size());
        
        Map<Id, Sales_Order__c> bg_so_map = new Map<Id, Sales_Order__c>();
        Map<Id, Id> so_bg_map = new Map<Id, Id>();
        for(Sales_Order__c so: [SELECT Id, Billing_Group__c, Sub_Group_Type__c,Order_Start_Date__c, Order_End_Date__c FROM Sales_Order__c WHERE Id IN: soList]){
            //type_so_map.put(so.Sub_Group_Type__c, so);
            bg_so_map.put(so.Billing_Group__c, so);
            so_bg_map.put(so.Id, so.Billing_Group__c);
        }
        
        // Create Sales Order Items
        List<Sales_Order_Item__c> soiList = new List<Sales_Order_Item__c>();
        Map<String, Sales_Order__c> tempType_so_map = new Map<String, Sales_Order__c>();
        Integer i = 1;
        for(Id bgId: bg_so_Map.keySet()){
            i = 1;
            //tempType_so_map = ;
            for(SBQQ__Subscription__c sub: bg_subList_Map.get(bgId)){
                system.debug('Adding RLF Item => '+sub);
                soiList.add(RLFPackage_ListInit.addRLFSalesOrderItem(sub, nsCurrencyMap, revRecScheduleMap, i, bg_so_map.get(bgId)));
            }
            
        }   
        if(soiList.size() > 0){
            Database.SaveResult[] srList = Database.insert(soiList, false);
            
            // looping over solist
            Integer counter = 0;
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {                    
                    System.debug('Successfully inserted. Sales Order Item IDs: ' + sr.getId());
                }
                else {                      
                    for(Database.Error err : sr.getErrors()) {
                        //System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        bgErrorsList.add(new Billing_Group__c(Id = so_bg_map.get(soiList[counter].Sales_order__c), Recurring_Batch_Error_Logs__c = 'Unable to Create Sales Order Items. Error => '+err.getMessage()));
                        
                    }
                }
                counter++;                
            }
        }     
        // update next billing date
        /* // Future purposr
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Sucs_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        for(sales_Order__c so: soList){
        bg_subList_Sucs_Map.put(so.Billing_group__c, bg_subList_Map.get(so.Billing_group__c));
        }
        */
        Map<Id, String> bgNBDMap = RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, prorata_subSet);
        
        // Update prorata days 
        List<SBQQ__Subscription__c> subs1 = new List<SBQQ__Subscription__c>();
        
        for(Id ii: bg_subList_Map.keySet()){
            subs1.addAll(bg_subList_Map.get(ii));
        }
        RLFPackage_ListInit.zeroProrataDays(subs1); 
        
        
        for(sales_Order__c so: soList){
            bgSuccessList.add(new Billing_Group__c(Id = so.Billing_group__c, Recurring_Batch_Error_Logs__c = null));
        }
        if(bgSuccessList.size() > 0){
            system.debug('success list' +bgSuccessList.size()); 
            try{
                bgSucsList.addAll(bgSuccessList);
                update new list<Billing_Group__c>(bgSucsList);
            } Catch(Exception Ex){
                system.debug('Failed to update bgErrorsList; Reason => '+ex.getMessage());
            }
        }
        
        if(bgErrorsLIst.size() > 0) {
            system.debug('updated errors logs' +bgErrorsLIst.size());
            try{
                update new list<Billing_Group__c>(bgErrorsList);
                bgErrList.addAll(bgErrorsList);
            } Catch(Exception Ex){
                system.debug('Failed to update bgErrorsList; Reason => '+ex.getMessage());
            }
        }
        
    }    
    
    global void finish(Database.BatchableContext BC) {        
        system.debug(' error list => '+bgErrList);
        RLF_Utils.bgDatesUpdate(bgIdList);
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[] {'venu.navuluri@misys.com'}; 
        
        mail.setToAddresses(System.Label.Billing_Report_Email_List.split(','));
        mail.setSubject('RLF Batch Job Process ' + a.Status);
        string htmlBody = '<p>The batch Apex job processed <b>' + a.TotalJobItems +'</b> batches with <b>'+ a.NumberOfErrors + '</b> failures.</p>';
        List<Billing_Group__c> successBgs = [SELECT Id, Name FROM Billing_Group__c WHERE  Id IN: bgSucsList];
        
        string errorTable = '<br /><br />Total number of Recusrring Sales Orders Created: <b>'+successBgs.size()+'</b><br /><br /><br /><table> <tr> <th>Billing Group</th> <th>Error</th> </tr>';
        string tRow = '';        
        
        /*for(Billing_Group__c bg: successBgs){
        tRow = '<tr style="font-weight: bold; color: green;">';
        tRow += '<td><a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+bg.Id+'">'+bg.Name+'</td><td>Success</td>';
        tRow += '</tr>';
        errorTable += tRow;  
        }*/
        
        for(Billing_Group__c bg: [SELECT Id, Name, Recurring_Batch_Error_Logs__c FROM Billing_Group__c WHERE Id IN: bgErrList]){
            tRow = '<tr style="font-weight: bold; color: red;">';
            tRow += '<td><a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+bg.Id+'">'+bg.Name+'</td><td>'+bg.Recurring_Batch_Error_Logs__c+'</td>';
            tRow += '</tr>';            
            errorTable += tRow;
        }
        errorTable += '</table>';        
        mail.setHtmlBody(htmlBody + errorTable); 
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }  
}