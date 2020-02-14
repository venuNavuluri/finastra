global class RLFSO_Batch implements Database.Batchable<sObject>, Database.Stateful {
          
       global static String BillingGroupFields = SO_RevenueTypeGrouping.BillingGroupFields ;
       global static String SubcriptionFields = SO_RevenueTypeGrouping.SubcriptionFields ;
       global final String bgQuery;
       global List<Id> bgAllIdsList;
       global set<Billing_Group__c> bgErrList;
       global set<Billing_Group__c> bgSucsList;
   
   global RLFSO_Batch(){
                        bgQuery = '' + BillingGroupFields + ' WHERE Next_SO_generation_Date__c = TODAY And Hold_Billing__c  = false AND BG_Billing_Group_Active__c = true ' ;
                        bgAllIdsList = new List<Id>(); 
                        bgErrList = new set<Billing_Group__c>();
                        bgSucsList = new set<Billing_Group__c>();
    }
    
   global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(bgQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        set<Billing_Group__c> bgErrorsList = new set<Billing_Group__c>();
        set<Billing_Group__c> bgSuccessList = new set<Billing_Group__c>();
        string response; 
        boolean flag = false;
        Map<Id, Billing_Group__c> bgAllIds_map = new Map<Id, Billing_Group__c>();
        
        for(Billing_Group__c bg:(Billing_Group__c[]) Scope){
            bgAllIds_map.put(bg.Id, bg);
            bg.Transaction_Late__c = false;   
        }
        bgAllIdsList.addAll(bgAllIds_map.keySet()); 
        system.debug('all bg ids' +bgAllIdsList.size());
        
        Map<Id, Billing_Group__c> validBGIds = new Map<Id, Billing_Group__c>( [  SELECT 
                                                                              Id
                                                                            FROM 
                                                                              Billing_Group__c 
                                                                            WHERE 
                                                                              Id IN: bgAllIds_map.keySet() 
                                                                              AND Account_by_Sub__r.Synced_To_NS__c = true
                                                                              AND (NS_Customer_Address__r.Synced_To_NS__c = TRUE OR NS_Customer_Address__c != null)
                                                                              AND (NS_Customer_Ship_To_Address__r.Synced_To_NS__c = TRUE OR NS_Customer_Ship_To_Address__c != null)
                                                                              AND Account_by_Sub__r.Account__r.NS_Finance_Region__c != null ]);
        
        Map<Id,billing_group__c> bgUpdate = new Map<Id, billing_group__c>();
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map0 = new Map<Id, List<SBQQ__Subscription__c>>();
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        
        Date billDate = Date.today() ;
        Set<ID> bgIDs = validBGIds.keySet(); 
         List<SBQQ__Subscription__c> subQuery = Database.query(SubcriptionFields + ' where Billing_Group__c IN :bgIDs AND Next_SO_generation_Date__c <=: billDate AND Billing_Status__c = \'Active billing\' AND Expired_Subscription__c = false AND Sales_Order_Type__c =  \'RLF\'');
        system.debug('sub list' +subQuery.size());
          for(SBQQ__Subscription__c sub : subQuery){ 
            //if some of them is beam with Transactions_Not_Recieved__c, then mark Transaction_Late__c = true for it's billing group
            
            if(sub.Transactions_Not_Received__c  == true && sub.Transactional__c == true)
            {
                Billing_Group__c bg = bgAllIds_map.get(sub.Billing_Group__c);
                if(bg!=null)
                    bg.Transaction_Late__c = true;
            }
            //group subscriptions by billing groups
            if(bg_subList_Map0.get(sub.Billing_Group__c)!=null) {
                bg_subList_Map0.get(sub.Billing_Group__c).add(sub);
            } else {
                bg_subList_Map0.put(sub.Billing_Group__c,new List<SBQQ__Subscription__c>{sub});
            }
        }
        
        for(Id bgId: bgAllIds_map.keyset()){
			Billing_Group__c bg = bgAllIds_map.get(bgId);
            system.debug('printing Bg => subs => '+bg_subList_Map0.get(bgId));
            flag = false;
            response = '';
            // perform all required checks before RLF order generation
            if( !bg_subList_Map0.containsKey(bgId) || (bg_subList_Map0.containsKey(bgId) && bg_subList_Map0.get(bgId).size() == 0)){
                if(!bg.Account_by_Sub__r.Synced_To_NS__c){
                    response += 'Account By Sub is not in Netsuite, please check Acc By Sub details. \n';
                    flag = true;
                }
                if(!bg.NS_Customer_Address__r.Synced_To_NS__c || bg.NS_Customer_Address__c == null ){
                    response += 'NS Customer Address is empty or  not in Netsuite, please check NS Customer Address details.\n';
                    flag = true;
                }
                if(!bg.NS_Customer_Ship_To_Address__r.Synced_To_NS__c || bg.NS_Customer_Ship_To_Address__c == null){
                    response += 'NS Customer Ship to Address is empty or  not in Netsuite, please check NS Customer Address details.\n';  
                    flag = true;
                }
                if(bg.Account_by_Sub__r.Account__r.NS_Finance_Region__c == null){
                    response += 'NS Financial region is empty on this billing group.\n';  
                    flag = true;
                }
                if(!flag){
                    response += 'No Subscriptions found for this Billing Group.'; 
                    
                }
                bgErrorsList.add(new Billing_Group__c(Id = bgId, Recurring_Batch_Error_Logs__c = response));   
            }

            //if billing group does not have transaction not received subscriptions
            if(bg.Transaction_Late__c == false)        
            {
             	//then reset SO_On_Hold_Since__c flag
                bg.RLF_SO_On_Hold_Since__c = null;  
                
                bgUpdate.put(bg.id, new billing_group__c(Transaction_Late__c= false,RLF_SO_On_Hold_Since__c=null, Id = bg.Id));
                //and put this group to a map for RLF order generation
                if(bg_subList_Map0.containsKey(bgId))
                	bg_subList_Map.put(bgId, bg_subList_Map0.get(bgId));  
            }
            else
            {
                //if billing group has transaction not received subscriptions, then populate SO_On_Hold_Since__c date
                if(bg.RLF_SO_On_Hold_Since__c == null)
                    bg.RLF_SO_On_Hold_Since__c =     bg.Next_SO_generation_Date__c;   
                //and just put billing group for update (no RLF order generation)
                bgUpdate.put(bg.id, new billing_group__c(Transaction_Late__c= true,RLF_SO_On_Hold_Since__c=bg.RLF_SO_On_Hold_Since__c, Id = bg.Id));
            }        
        }
        
        Map < String, NS_Currency__c > nsCurrencyMap = SO_SalesOrderMapUtils.getNSCurrency_map();
        
        Map<Id, SBQQ__Subscription__c> bg_subMax_map = new Map<Id, SBQQ__Subscription__c>();
        for(String s: bg_subList_Map.keySet()){
            if(bg_subList_Map.get(s).size() > 0){
                bg_subMax_map.put(s, bg_subList_Map.get(s)[0]);
            }
        }
        
        // calcualte prorata
        List<SBQQ__Subscription__c> prorata_subList = RLF_SOCreation.calculateProrata(bg_subList_Map);  
        Set<SBQQ__Subscription__c> prorata_subSet =  new Set<SBQQ__Subscription__c>();
        if(prorata_subList.size() > 0) 
            prorata_subSet.addAll(prorata_subList);
        
        
         // Create Sales Order
        List<Sales_Order__c> soList = new List<Sales_Order__c>();
        Sales_Order__c RLFso;
        for(Id bgId: bg_subMax_map.keySet()){
            if(bg_subMax_map.get(bgId) != null){
                RLFso = RLF_SOCreation.addRLFSalesOrder(bgAllIds_map.get(bgId), nsCurrencyMap,bg_subMax_map.get(bgId)); 
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
                soiList.add(RLF_SOCreation.addRLFSalesOrderItem(sub, nsCurrencyMap, i, RLFso));
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
        
        Map<Id, String> bgNBDMap = RLF_SOCreation.updateNextBillingDate(bg_subList_Map);
         
        RLF_SOCreation.updateProrataCalculatedCheckBox(soiList); 
        
        
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
  
        if(!bgUpdate.isEmpty())
        {
            update bgUpdate.values();
        }
        
        
    } 
    
    global void finish(Database.BatchableContext BC) {
        
        system.debug(' error list => '+bgErrList);
        RLF_SOCreation.bgDatesUpdate(bgAllIdsList);
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'venu.navuluri@misys.com'}; 
        mail.setToAddresses(toAddresses);
       // mail.setToAddresses(System.Label.Billing_Report_Email_List.split(','));
        mail.setSubject('RLF Batch Job Process ' + a.Status);
        string htmlBody = '<p>The batch Apex job processed <b>' + a.TotalJobItems +'</b> batches with <b>'+ a.NumberOfErrors + '</b> failures.</p>';
        List<Billing_Group__c> successBgs = [SELECT Id, Name FROM Billing_Group__c WHERE  Id IN: bgSucsList];
        
        string errorTable = '<br /><br />Total number of Recusrring Sales Orders Created: <b>'+successBgs.size()+'</b><br /><br /><br /><table> <tr> <th>Billing Group</th> <th>Error</th> </tr>';
        string tRow = '';        
        
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