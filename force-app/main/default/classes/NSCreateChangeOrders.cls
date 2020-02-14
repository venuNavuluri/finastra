/*
    Created By: Abhinit Kohar
    Created Date: 04/11/2014
    Description: This class is getting invoked from the Create Change Order button on NS Subscription and Create Change Orders link from the sidebar.
    This will create the Change Orders and Change Order Items based on the Contract Assets associated with the NS Subscriptions.
    This will update the "2015 Uplift in Progress" flag on Contract Asset to True.
    
    This is tested from the Test_NSCreateChangeOrders class
*/
global class NSCreateChangeOrders {

  
   
   private static String convertStrToDateFormat (String Dt)
   { 
    String[] str = dt.split(' ');
    String[] dts = str[0].split('/');
    String myDate = Integer.valueOf(dts[2])+'-'+ Integer.valueOf(dts[1])+'-'+ Integer.valueOf(dts[0]);
    return myDate;
   }
   
    //This method is for creating a single Change Order for a Subscription. Change Order can only be created for the Subscription which has the Status = Open and is not inactive.
    //This method gets invoked from Create Change Order button on NS Subscription
    webservice static String createSingleChangeOrder(Id subId) {
        String response = 'Change Order created successfully';
        
        NS_Subscriptions__c sub = [select name, Status__c, Inactive__c, NS_Subscription_Internal_Id__c from NS_Subscriptions__c where id = :subId];
        if(sub.Status__c != 'Open' || sub.Inactive__c == true) {
            response = 'Change Order can not be created for this Subscription. \n\n Please check that the Status of Subscription should be Open and Subscription should not be inactive.';
        } else {
            list<Contract_Asset__c> contractAssetList = [select id, name, NS_Subscription__c, NS_Uplift_Start_Date__c, NS_Uplift_Final__c, NS_Uplift_Effective_Date__c 
                                                        from Contract_Asset__c 
                                                        where NS_Subscription__c = :subId and Apply_2015_Uplift__c = true and X2015_Uplift_HOLD__c = false 
                                                        and X2015_Uplift_Applied__c = false and X2015_Uplift_in_Progress__c = false];
                                                        
            if(contractAssetList == null || contractAssetList.size() == 0){
                response = 'There are no associated Contract Assets for creating the uplift Change Order';
            } else {
                SavePoint sp = Database.setSavePoint();
                Date nsUpliftEffectiveDate = Date.today();
                if(contractAssetList[0].NS_Uplift_Effective_Date__c != null) {
                    nsUpliftEffectiveDate = contractAssetList[0].NS_Uplift_Effective_Date__c;
                }
                NS_RLF_Change_Order__c changeOrder = new NS_RLF_Change_Order__c(NS_Subscription__c = subId, Change_Order_Effective_Date__c = nsUpliftEffectiveDate, 
                                                                                New_Advance_Billing_Date_on_Subscription__c = Date.today(), Set_Advance_Billing_Date_after_uplift__c = true,
                                                                                Ready_for_Approval__c = true);
                insert changeOrder;
                
                list<NS_RLF_Change_Order_Item__c> changeOrderItemList = new list<NS_RLF_Change_Order_Item__c>();
                list<Contract_Asset__c> updateConAssetList = new list<Contract_Asset__c>();
                for(Contract_Asset__c conAsset : contractAssetList){
                    if(nsUpliftEffectiveDate < Date.today() && nsUpliftEffectiveDate != conAsset.NS_Uplift_Start_Date__c){
                        Database.rollback(sp);
                        return response = 'Change Order not created: If the Contract Asset NS Uplift Effective Date is OLDER than TODAY, the NS Uplift Start Date MUST be the same date';
                    } else if (nsUpliftEffectiveDate >= Date.today() && conAsset.NS_Uplift_Start_Date__c < nsUpliftEffectiveDate){
                        Database.rollback(sp);
                        return response = 'Change Order not created: If the Contract Asset NS Uplift Effective Date is TODAY or LATER than TODAY, the NS Uplift Start Date MUST be the same date or LATER';
                    } else {
                        changeOrderItemList.add(new NS_RLF_Change_Order_Item__c(NS_RLF_Change_Order__c = changeOrder.Id, Originating_NS_Subscription__c = conAsset.NS_Subscription__c,
                                                                                Change_Order_Item_Start_Date__c = conAsset.NS_Uplift_Start_Date__c, NS__c = conAsset.NS_Uplift_Final__c,
                                                                                Contract_Asset__c = conAsset.Id));
                        conAsset.X2015_Uplift_in_Progress__c = true;
                        updateConAssetList.add(conAsset);
                    }
                    
                }
                if(changeOrderItemList.size() > 0){
                    insert changeOrderItemList;
                    update updateConAssetList;
                }
            }
        }
        
        return response;
    }
    
    //This method is from creating multiple Change Orders. Change Orders can only be created for the Subscriptions which has the Status = Open and is not inactive.
    //This method gets invoked from Create Change Orders link in the sidebar of the Home page layout. The name of the home page component is Subscription Change Orders.
    webservice static String createChangeOrders() {
        String response = 'Change Orders created successfully';
        map<Id, list<Contract_Asset__c>> subConAssetListMap = new map<Id, list<Contract_Asset__c>>();
        list<Contract_Asset__c> conAssetList;
        list<Contract_Asset__c> contractAssetList = new list<Contract_Asset__c>();
        set<Id> changeOrderIds = new set<Id>();
        String currentYear = String.valueof(System.now().year());
        list<NS_RLF_Change_Order__c> changeOrderList = new list<NS_RLF_Change_Order__c>();
        list<NS_RLF_Change_Order_Item__c> changeOrderItemList = new list<NS_RLF_Change_Order_Item__c>();
        map<Id, NS_RLF_Change_Order__c> subChangeOrderMap = new map<Id, NS_RLF_Change_Order__c>();
        
//      for(Contract_Asset__c conAsset : [select id, name, NS_Subscription__c, NS_Uplift_Start_Date__c, NS_Uplift_Final__c from Contract_Asset__c 
//                                                      where Apply_2015_Uplift__c = true and X2015_Uplift_HOLD__c = false 
//                                                      and X2015_Uplift_Applied__c = false and X2015_Uplift_in_Progress__c = false]){
        for(Contract_Asset__c conAsset : [select id, name, NS_Subscription__c, NS_Uplift_Start_Date__c, NS_Uplift_Final__c, NS_Uplift_Effective_Date__c from Contract_Asset__c 
                                                        where CO_Batch_Create__c = true and CO_Batch_Create_Complete__c = false]){
            if(conAsset.NS_Subscription__c != null){
                contractAssetList.add(conAsset);
                if(subConAssetListMap.containsKey(conAsset.NS_Subscription__c)){
                    conAssetList = subConAssetListMap.get(conAsset.NS_Subscription__c);
                    conAssetList.add(conAsset);
                } else {
                    conAssetList = new list<Contract_Asset__c>();
                    conAssetList.add(conAsset);
                    subConAssetListMap.put(conAsset.NS_Subscription__c, conAssetList);
                   
                     Date nsUpliftEffectiveDate = Date.today();
                     if(conAsset.NS_Uplift_Effective_Date__c != null) {
                        nsUpliftEffectiveDate = conAsset.NS_Uplift_Effective_Date__c;
                }
                    
                    changeOrderList.add(new NS_RLF_Change_Order__c(NS_Subscription__c = conAsset.NS_Subscription__c, Change_Order_Effective_Date__c = nsUpliftEffectiveDate /*Date.today()*/, 
                                                                                New_Advance_Billing_Date_on_Subscription__c = Date.today(), Set_Advance_Billing_Date_after_uplift__c = true,
                                                                                Ready_for_Approval__c = true, Uplift_Year__c = currentYear /*'2017'*/,Batch_created__c=true));
                }
            }   
        }
        
        if(changeOrderList != null && changeOrderList.size() > 0){
            insert changeOrderList;
            for(NS_RLF_Change_Order__c changeOrder : changeOrderList){
                changeOrderIds.add(changeOrder.Id);
            }
        }
        
        if(changeOrderIds != null && changeOrderIds.size() > 0){
            for(NS_RLF_Change_Order__c changeOrd : [select id, name, NS_Subscription__c from NS_RLF_Change_Order__c where id in : changeOrderIds]){
                subChangeOrderMap.put(changeOrd.NS_Subscription__c, changeOrd);
            }
        }
        
        for(Contract_Asset__c contractAsset : contractAssetList){
            changeOrderItemList.add(new NS_RLF_Change_Order_Item__c(NS_RLF_Change_Order__c = subChangeOrderMap.get(contractAsset.NS_Subscription__c).Id, Originating_NS_Subscription__c = contractAsset.NS_Subscription__c,
                                                                            Change_Order_Item_Start_Date__c = contractAsset.NS_Uplift_Start_Date__c, NS__c = contractAsset.NS_Uplift_Final__c,
                                                                            Contract_Asset__c = contractAsset.Id,  /*Apply_2016_Uplift__c = true*/Apply_2017_Uplift__c = true));
       
            contractAsset.CO_Batch_Create_Complete__c = true;
        }
        
        if(changeOrderItemList != null && changeOrderItemList.size() > 0){
            insert changeOrderItemList;
        }
        
        if(contractAssetList.size()>0)
             update contractAssetList;
        
        //Call the batch class to update the Contract Assets
        //Database.executeBatch(new UpdateContractAssetBatch(), 5); // Can't use the batch process to update the contract assets because a future method is being invoked from the contract asset trigger.
        return response;
    }

    /*Change Order Creation - Latest Method*/
    //This method is for creating a single Change Order for a Subscription. Change Order can only be created for the Subscription which has the Status = Open and is not inactive.
    //This method gets invoked from Create Change Order button on NS Subscription
    webservice static String createSingleChangeOrderNew(Id subId, String year, String subUpliftYear, String subUpliftEffectiveDate_strVal, String subUpliftStartDate_strVal) {
      
      String response = 'Change Order created successfully';
      
      if(year =='Generic' && subUpliftStartDate_strVal == '' )
      return 'Please fill in the uplift start date before continuing';
       
      Date subUpliftEffectiveDate;
      if(subUpliftEffectiveDate_strVal!='')
      subUpliftEffectiveDate = Date.valueOf(convertStrToDateFormat(subUpliftEffectiveDate_strVal));
      
      Date subUpliftStartDate;
      if(subUpliftStartDate_strVal!='')
      subUpliftStartDate = Date.valueOf(convertStrToDateFormat(subUpliftStartDate_strVal));
      
        //AM add validation to check that subUpliftYear is not null 
       
      /* have to check that in case of Generic the subUpliftYear and subUpliftEffectiveDate is not null
       if( year == 'Generic' && subUpliftEffectiveDate==''){
                            Start date cannot be null';
                        }*/
        
        NS_Subscriptions__c sub = [select name, Status__c, Inactive__c, NS_Subscription_Internal_Id__c, uplift_year__c, NS_Uplift_Effective_Date__c,NS_Uplift_Start_Date__c from NS_Subscriptions__c where id = :subId];
        
       
        
        if(sub.Status__c != 'Open' || sub.Inactive__c == true) {
            response = 'Change Order can not be created for this Subscription. \n\n Please check that the Status of Subscription should be Open and Subscription should not be inactive.';
        } else {
            set<Id> contractAssetIds = new set<Id>();
            for(NS_Subscription_Item__c subItem : [select id, Contract_Asset__c from NS_Subscription_Item__c where Subscription__c = :subId and Contract_Asset__c != null]){
                contractAssetIds.add(subItem.Contract_Asset__c);
            }
            if(contractAssetIds != null && contractAssetIds.size() > 0){
                list<Contract_Asset__c> contractAssetList;
                if(year == '2015'){
                    contractAssetList = [select id, name, NS_Subscription__c, NS_Uplift_Start_Date__c, NS_Uplift_Final__c, NS_Uplift_Effective_Date__c 
                                                                from Contract_Asset__c 
                                                                where id in :contractAssetIds and Apply_2015_Uplift__c = true and X2015_Uplift_HOLD__c = false 
                                                                and X2015_Uplift_Applied__c = false and Uplift_in_Progress__c = false and CA_Billing_Status__c = 'Active billing'];
                } else if(year == '2016'){
                    contractAssetList = [select id, name, NS_Subscription__c, NS_Uplift_Start_Date__c, NS_Uplift_Final__c, NS_Uplift_Effective_Date__c 
                                                                from Contract_Asset__c 
                                                                where id in :contractAssetIds and Apply_2016_Uplift__c = true and X2016_Uplift_HOLD__c = false 
                                                                and X2016_Uplift_Applied__c = false and Uplift_in_Progress__c = false and CA_Billing_Status__c = 'Active billing'];
                } else if(year == '2017'){
                    contractAssetList = [select id, name, NS_Subscription__c, NS_Uplift_Start_Date__c, NS_Uplift_Final__c, NS_Uplift_Effective_Date__c 
                                                                from Contract_Asset__c 
                                                                where id in :contractAssetIds and Apply_2017_Uplift__c = true and X2017_Uplift_HOLD__c = false 
                                                                and X2017_Uplift_Applied__c = false and Uplift_in_Progress__c = false and CA_Billing_Status__c = 'Active billing'];
                }
                else if(year == 'Generic'){
                    contractAssetList = [select id, name, NS_Subscription__c, NS_Uplift_Start_Date__c, NS_Uplift_Final__c, NS_Uplift_Effective_Date__c
                                                                from Contract_Asset__c 
                                                                where id in :contractAssetIds /*and Apply_2017_Uplift__c = true and X2017_Uplift_HOLD__c = false 
                                                                and X2017_Uplift_Applied__c = false and Uplift_in_Progress__c = false*/ and CA_Billing_Status__c = 'Active billing'];
                                                                
                }
                 else if(year == 'ad-hoc'){
                    contractAssetList = [select id, name, NS_Subscription__c, NS_Uplift_Start_Date__c, NS_Uplift_Final__c, NS_Uplift_Effective_Date__c 
                                                                from Contract_Asset__c 
                                                                where id in :contractAssetIds and Apply_Ad_Hoc_Uplift__c = true and Uplift_Hold__c = false 
                                                                and Uplift_Ad_Hoc_Applied__c = false and Uplift_in_Progress__c = false and CA_Billing_Status__c = 'Active billing'];
                } else {
                    response = 'Change Order can not be created as the year is not valid. Change Order can only be created for 2015, 2016, 2017 and ad-hoc';
                }
                //ad-hoc                                    
                if(contractAssetList == null || contractAssetList.size() == 0){
                    response = 'There are no associated Contract Assets for creating the uplift Change Order';
                } else {
                    SavePoint sp = Database.setSavePoint();
                    Date nsUpliftEffectiveDate = Date.today();
                    if(year == 'Generic'){
                    if(subUpliftEffectiveDate !=null)
                     nsUpliftEffectiveDate = subUpliftEffectiveDate;
                     else
                     nsUpliftEffectiveDate  = Date.today();
                    }
                    else if(contractAssetList[0].NS_Uplift_Effective_Date__c != null) {
                        nsUpliftEffectiveDate = contractAssetList[0].NS_Uplift_Effective_Date__c;
                    }
                    //AM Logic to check that this is a Generic CO
                    Boolean isGenericCO = false;
                    if(year == 'Generic')
                    isGenericCO = true;
                    
                    //AM - code added to apply generic year
                    String coYear ='';
                        if(subUpliftYear =='')
                            coYear = year;
                        else 
                            coYear = subUpliftYear;
                            
                        if(coYear == 'Generic')
                        coYear = '0000'; //string.valueOf(Date.today().year());
                            
                    
                    NS_RLF_Change_Order__c changeOrder = new NS_RLF_Change_Order__c(NS_Subscription__c = subId, Change_Order_Effective_Date__c = nsUpliftEffectiveDate, 
                                                                                    New_Advance_Billing_Date_on_Subscription__c = Date.today(), Set_Advance_Billing_Date_after_uplift__c = true,
                                                                                    Ready_for_Approval__c = true, Uplift_Year__c = coYear , Generically_Created__c = isGenericCO);
                    insert changeOrder;
                    
                    list<NS_RLF_Change_Order_Item__c> changeOrderItemList = new list<NS_RLF_Change_Order_Item__c>();
                    list<Contract_Asset__c> updateConAssetList = new list<Contract_Asset__c>();
                    for(Contract_Asset__c conAsset : contractAssetList){
                        if(nsUpliftEffectiveDate < Date.today() && nsUpliftEffectiveDate != conAsset.NS_Uplift_Start_Date__c && year != 'Generic'){
                            Database.rollback(sp);
                            return response = 'Change Order not created: If the Contract Asset NS Uplift Effective Date is OLDER than TODAY, the NS Uplift Start Date MUST be the same date';
                        } else if (nsUpliftEffectiveDate >= Date.today() && conAsset.NS_Uplift_Start_Date__c < nsUpliftEffectiveDate && year != 'Generic'){
                            Database.rollback(sp);
                            return response = 'Change Order not created: If the Contract Asset NS Uplift Effective Date is TODAY or LATER than TODAY, the NS Uplift Start Date MUST be the same date or LATER';
                        }
                        
                         else if(nsUpliftEffectiveDate < Date.today() && nsUpliftEffectiveDate != subUpliftStartDate   && year == 'Generic'){
                            Database.rollback(sp);
                            return response = 'Generic Co Error - Change Order not created: If the NS Uplift Effective Date is OLDER than TODAY, the NS Uplift Start Date MUST be the same date';
                        } else if (nsUpliftEffectiveDate >= Date.today() && subUpliftStartDate   < nsUpliftEffectiveDate && year == 'Generic'){
                            Database.rollback(sp);
                            return response = 'Generic CO Error - Change Order not created: If the NS Uplift Effective Date is TODAY or LATER than TODAY, the NS Uplift Start Date MUST be the same date or LATER';
                        } 
                        
                        
                         else {
                            if(year == '2015'){
                                changeOrderItemList.add(new NS_RLF_Change_Order_Item__c(NS_RLF_Change_Order__c = changeOrder.Id, Originating_NS_Subscription__c = conAsset.NS_Subscription__c,
                                                                                        Change_Order_Item_Start_Date__c = conAsset.NS_Uplift_Start_Date__c, NS__c = conAsset.NS_Uplift_Final__c,
                                                                                        Contract_Asset__c = conAsset.Id, Apply_2015_Uplift__c = true));
                            } else if(year == '2016'){
                                changeOrderItemList.add(new NS_RLF_Change_Order_Item__c(NS_RLF_Change_Order__c = changeOrder.Id, Originating_NS_Subscription__c = conAsset.NS_Subscription__c,
                                                                                        Change_Order_Item_Start_Date__c = conAsset.NS_Uplift_Start_Date__c, NS__c = conAsset.NS_Uplift_Final__c,
                                                                                        Contract_Asset__c = conAsset.Id, Apply_2016_Uplift__c = true));
                            } else if(year == 'ad-hoc'){
                                changeOrderItemList.add(new NS_RLF_Change_Order_Item__c(NS_RLF_Change_Order__c = changeOrder.Id, Originating_NS_Subscription__c = conAsset.NS_Subscription__c,
                                                                                        Change_Order_Item_Start_Date__c = conAsset.NS_Uplift_Start_Date__c, NS__c = conAsset.NS_Uplift_Final__c,
                                                                                        Contract_Asset__c = conAsset.Id, Apply_AdHoc_Uplift__c = true));
                            }
                            else if(year == 'Generic'){
                                changeOrderItemList.add(new NS_RLF_Change_Order_Item__c(NS_RLF_Change_Order__c = changeOrder.Id, Originating_NS_Subscription__c = conAsset.NS_Subscription__c,
                                                                                        Change_Order_Item_Start_Date__c =   subUpliftStartDate  /*conAsset.NS_Uplift_Start_Date__c*/, NS__c = conAsset.NS_Uplift_Final__c,
                                                                                        Contract_Asset__c = conAsset.Id/*, Apply_Uplift__c = true*/));
                            }
                            
                            
                            else if(year == '2017'){
                                changeOrderItemList.add(new NS_RLF_Change_Order_Item__c(NS_RLF_Change_Order__c = changeOrder.Id, Originating_NS_Subscription__c = conAsset.NS_Subscription__c,
                                                                                        Change_Order_Item_Start_Date__c = conAsset.NS_Uplift_Start_Date__c, NS__c = conAsset.NS_Uplift_Final__c,
                                                                                        Contract_Asset__c = conAsset.Id, Apply_2017_Uplift__c = true));
                            }
                            //TODO - set the flag for 2017
                            if(year != 'Generic')
                            //conAsset.X2015_Uplift_in_Progress__c = true;
                            conAsset.Uplift_in_Progress__c = true;
                            updateConAssetList.add(conAsset);
                        }
                        
                    }
                    if(changeOrderItemList.size() > 0){
                        insert changeOrderItemList;
                        update updateConAssetList;
                    }
                }
            }
        }
        
        return response;
    }
}