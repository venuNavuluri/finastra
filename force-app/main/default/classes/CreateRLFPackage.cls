/*
    Created By: Abhinit Kohar
    Creatd Date: 16/04/2015
    Description: This class will be invoked from the Billing Groups and will create the RLF Sales Orders and Sales Order Items
    from Billing Groups and associated Contract Assets.
*/
global class CreateRLFPackage {

    webservice static void callCreateRLFPackageBatch(){
        Database.executeBatch(new CreateRLFPackageBatch(), 1);
    }

    public static void createRLFPackages(Id bgId){
        createSalesOrder(bgId, 'Batch');
    }
    //This method is for creating the Sales Order and Sales Order Items from the Billing Group and associated Contract Assets
    //This is called from a custom button on Billing Group
    webservice static String createSalesOrder(Id bgId, String packageTobeCreated){
        
        String retString = 'RLF Package Created Successfully';
        System.Savepoint sp1 = Database.setSavepoint();
        
        Billing_Group__c billingGroup = getBillingGroup(bgId);
        
        NS_Currency__c nsCurrency = [select id, Name, NS_Currency_Internal_Id__c, IsZeroDecimal__c from NS_Currency__c where Name = :billingGroup.CurrencyIsoCode];
        map<String, NS_Account__c> defAccMap = new map<String, NS_Account__c>();

        system.debug('nsCurrency = ' + nsCurrency);
        
        set<string> nsProductInternalIds = new set<string>();
        set<String> subPlanKeys = new set<String>();
        set<String> thirdPartyCurrencyNames = new set<String>();
        //list<Contract_Asset__c> caList = new list<Contract_Asset__c>();
        list<Contract_Asset__c> caList = getContractAssets(bgId);
        set<string> nsCostCentreInternalIds = new set<string>();
        map<string, NS_Cost_Centre__c> nsCostCentreIntIdMap = new map<string, NS_Cost_Centre__c>();
        
        if(caList == null || (caList != null && caList.size() == 0)){
            if(packageTobeCreated != 'Batch'){
                return retString = 'Could not create package as there are either no contract assets or their CA Billing Status is not Active Billing';
            } else if(packageTobeCreated == 'Batch'){
                billingGroup.RLF_Batch_Create_Failed__c = true;
                billingGroup.RLF_Batch_Create_Failure_Reason__c = 'Could not create package as there are either no contract assets or their CA Billing Status is not Active Billing';
                update billingGroup;
                return retString = 'Could not create package as there are either no contract assets or their CA Billing Status is not Active Billing';
            }
        }
        
        if(caList != null && caList.size() > 0){
            Boolean currencyMismatch = false;
            for(Contract_Asset__c ca : caList){
                //caList.add(ca);
                if(ca.Product__r.NS_Product_Dimension_ID__c != null){
                    nsProductInternalIds.add(ca.Product__r.NS_Product_Dimension_ID__c);   
                }
                if(ca.NS_Subscription_Plan_Key__c != null){
                    subPlanKeys.add(ca.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c);
                }
                if(ca.X3PP_Currency__c != null){
                    thirdPartyCurrencyNames.add(ca.X3PP_Currency__c);
                }
                if(ca.CurrencyIsoCode != billingGroup.CurrencyIsoCode){
                    currencyMismatch = true;
                }
                if(ca.Product__r.NS_Cost_Centre_ID__c != null){
                    nsCostCentreInternalIds.add(ca.Product__r.NS_Cost_Centre_ID__c);
                }
            }
            
            if(nsCostCentreInternalIds != null && nsCostCentreInternalIds.size() > 0){
                for(NS_Cost_Centre__c nsCC : [select id, NS_Cost_Centre_Internal_Id__c from NS_Cost_Centre__c where NS_Cost_Centre_Internal_Id__c in :nsCostCentreInternalIds]){
                    nsCostCentreIntIdMap.put(nsCC.NS_Cost_Centre_Internal_Id__c, nsCC);
                }
            }
            
            if(currencyMismatch == true && packageTobeCreated != 'Batch'){
                return retString = 'Could not create package as there is a mismatch of currency between Billing Group and Contract Assets';
            } else if(currencyMismatch == true && packageTobeCreated == 'Batch'){
                billingGroup.RLF_Batch_Create_Failed__c = true;
                billingGroup.RLF_Batch_Create_Failure_Reason__c = 'Could not create package as there is a mismatch of currency between Billing Group and Contract Assets';
                update billingGroup;
                return retString = 'Could not create package as there is a mismatch of currency between Billing Group and Contract Assets';
            }
        }

        system.debug('caList = ' + caList);
        system.debug('nsProductInternalIds = ' + nsProductInternalIds);

        system.debug('subPlanKeys = ' + subPlanKeys);
        system.debug('thirdPartyCurrencyNames = ' + thirdPartyCurrencyNames);
        system.debug('nsCostCentreInternalIds = ' + nsCostCentreInternalIds);
        system.debug('nsCostCentreIntIdMap = ' + nsCostCentreIntIdMap);
        
        map<String, NS_Currency__c> nsCurrencyMap = new map<String, NS_Currency__c>();
        for(NS_Currency__c nsCurrency1 : [select id, Name, NS_Currency_Internal_Id__c, IsZeroDecimal__c from NS_Currency__c where Name in :thirdPartyCurrencyNames]){
            nsCurrencyMap.put(nsCurrency1.Name, nsCurrency1);
        }
        
        map<string, id> nsProdIntIdMap = new map<string, id>();
        
        if(nsProductInternalIds != null && nsProductInternalIds.size() > 0){
            for(NS_Product__c nsProduct : [select id, NS_Product_Internal_Id__c from NS_Product__c where NS_Product_Internal_Id__c in : nsProductInternalIds]){
                nsProdIntIdMap.put(nsProduct.NS_Product_Internal_Id__c, nsProduct.Id);
            }
        }
        system.debug('nsProdIntIdMap = ' + nsProdIntIdMap);
        
         map<String, NS_Subscription_Plan_Item__c> subPlanKeySubPlanItemMap = getSubPlanItemMap(subPlanKeys);


        list<Sales_Order__c> soList = new list<Sales_Order__c>();
        
        Sales_Order__c salesOrder = new Sales_Order__c();
        salesOrder.NS_Form_Id__c = '124';
        //salesOrder.OBSId__c = obs.Id;
        //salesOrder.RF_Review_Month__c = billingGroup.RF_Review_Month__c;
        salesOrder.Billing_Group__c = billingGroup.Id;
        salesOrder.SFDC_Billing_Group__c = billingGroup.Name;
        salesOrder.Bill_To_Customer__c = billingGroup.Account_by_Sub__c;
        //Opportunity_Number_text__c
        if(billingGroup.Original_Opportunity__c != null){
            system.debug('billingGroup.Original_Opportunity__c = ' + billingGroup.Original_Opportunity__c);
            salesOrder.Opportunity__c = billingGroup.Original_Opportunity__c;
            salesOrder.Opportunity_Owner__c = billingGroup.Original_Opportunity__r.Owner.FirstName + ' ' + billingGroup.Original_Opportunity__r.Owner.LastName;
        } else if(billingGroup.BG_Opportunity_Number_s_migration__c != null){
            system.debug('billingGroup.BG_Opportunity_Number_s_migration__c inside else if = ' + billingGroup.BG_Opportunity_Number_s_migration__c);
            salesOrder.Opportunity_Number_text__c = billingGroup.BG_Opportunity_Number_s_migration__c;
        }
        system.debug('billingGroup.BG_Opportunity_Number_s_migration__c = ' + billingGroup.BG_Opportunity_Number_s_migration__c);
        salesOrder.Opportunity_Owner_NS_Id__c = billingGroup.Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c;
        salesOrder.CurrencyIsoCode = billingGroup.CurrencyIsoCode;
        salesOrder.NS_Term__c = billingGroup.Account_by_Sub__r.Account__r.NS_Term__c;
        salesOrder.SO_Credit_Controller__c = billingGroup.Account_by_Sub__r.Account__r.Credit_Controller__c;
        salesOrder.NS_Currency__c = nsCurrency.Id;
        salesOrder.Contract__c = billingGroup.Original_Contract__c;
        salesOrder.NS_Rev_Rec_on_Commit__c = false;
        salesOrder.NS_AutoCalculate_VSOE_Allocation__c = false;
        salesOrder.Invoice_Credit_Body__c = 'RLF';
        salesOrder.Order_Status__c = 'Pending Approval';
        salesOrder.Customer_PO_Number__c = billingGroup.Customer_PO_Number__c;
        salesOrder.Order_Date__c = billingGroup.Original_Opportunity__r.CloseDate;
        salesOrder.Order_Type__c = 'RLF';
        salesOrder.PO_Required__c = billingGroup.Account_by_Sub__r.Account__r.PO_Required__c;
        salesOrder.Transaction_is_VSOE_Bundle__c = false;
        salesOrder.Primary_Sales_Person__c = billingGroup.Original_Opportunity__r.OwnerId;
        salesOrder.Contribution__c = 100;
        salesOrder.NS_To_Be_Printed__c = billingGroup.Account_by_Sub__r.Invoice_Delivery_Post__c;
        salesOrder.NS_To_Be_Emailed__c = billingGroup.Account_by_Sub__r.Invoice_Delivery_Email__c;
        salesOrder.NS_Billing_Address__c = billingGroup.NS_Customer_Address__c;
        salesOrder.NS_Shipping_Address__c = billingGroup.NS_Customer_Ship_To_Address__c;
        if(billingGroup.Original_Customer_Signed_Date__c != null){
            salesOrder.NS_Contract_Date__c = billingGroup.Original_Customer_Signed_Date__c;
        } else if(billingGroup.Current_Sales_Order_Start_Date__c != null){
            salesOrder.NS_Contract_Date__c = billingGroup.Current_Sales_Order_Start_Date__c;
        } else {
            salesOrder.NS_Contract_Date__c = billingGroup.BG_Contract_Date_migration__c;
        }
        salesOrder.Order_Start_Date__c = billingGroup.Current_Sales_Order_Start_Date__c;
        salesOrder.Subscription_Start_Date__c = billingGroup.NS_Subscription_Start_Date__c;
        salesOrder.Order_End_Date__c = billingGroup.Current_Sales_Order_Start_Date__c;
        salesOrder.Memo__c = billingGroup.NS_Subscription_Memo__c;
        salesOrder.Subscription_Start_Type__c = billingGroup.NS_Subscription_Start_Type__c;
        salesOrder.Subscription_Option__c = billingGroup.NS_Subscription_Option__c;
        salesOrder.Sales_Role__c = 'Sales Rep';
        salesOrder.Fixed_price_associatd_with_this_contract__c = 'No';
        salesOrder.Subsription_Status__c = 'Open';
        salesOrder.Billing_Mode__c = billingGroup.NS_Billing_Mode__c;
        salesOrder.Subscription_Termination_Method__c = billingGroup.NS_Termination_Method__c;
        salesOrder.Time_Zone__c = '1';
        salesOrder.Fixed_Billing_Date__c = billingGroup.Fixed_Billing_Date__c;
        salesOrder.Reset_Next_Bill_Date__c = billingGroup.Reset_Next_Bill_Date__c;
        salesOrder.BG_Next_Invoice_Due_Date__c = billingGroup.BG_Next_Invoice_Due_Date__c;
        salesOrder.Document_Memo__c = billingGroup.NS_Specific_Invoice_Wording__c;
        salesOrder.RLF_Tax_Combo_Check__c = billingGroup.Set_Tax_Combo_Override__c;
        salesOrder.Order_Sub_Type__c = billingGroup.Order_Sub_Type__c;
        
        if(billingGroup.Fixed_Billing_Date__c != null){
            list<NS_Fixed_Billing_Date__c> fbdList = [select id, name, NS_Internal_Id__c, Date__c from NS_Fixed_Billing_Date__c where Date__c = : billingGroup.Fixed_Billing_Date__c];
            if(fbdList != null && fbdList.size() > 0){
                salesOrder.NS_Fixed_Billing_Date__c = fbdList[0].id;
                salesOrder.NS_Fixed_Billing_Date_Internal_Id__c = fbdList[0].NS_Internal_Id__c;
            }
        }
        salesOrder.Transaction_Type__c = 'Invoice';
        if(caList != null && caList.size() > 0){
            Double fairValue = 0.00;
            String projProdInternalId = null;
            string nsCostCentreIntId = null;
            for(Contract_Asset__c contractAsset : caList){
                if(fairValue < contractAsset.Current_Fair_Value__c){
                    fairValue = contractAsset.Current_Fair_Value__c;
                    projProdInternalId = contractAsset.Product__r.NS_Product_Dimension_ID__c;
                    nsCostCentreIntId = contractAsset.Product__r.NS_Cost_Centre_ID__c;
                    system.debug('projProdInternalId = ' + projProdInternalId);
                    system.debug('nsCostCentreIntId = ' + nsCostCentreIntId);
                } else if(fairValue == contractAsset.Current_Fair_Value__c){
                    if(projProdInternalId == null){
                        projProdInternalId = contractAsset.Product__r.NS_Product_Dimension_ID__c;
                    }
                    if(nsCostCentreIntId == null){
                        nsCostCentreIntId = contractAsset.Product__r.NS_Cost_Centre_ID__c;
                    }
                    system.debug('projProdInternalId for zero value = ' + projProdInternalId);
                    system.debug('nsCostCentreIntId for zero value = ' + nsCostCentreIntId);
                }
            }
            if(projProdInternalId != null && nsProdIntIdMap != null && nsProdIntIdMap.containsKey(projProdInternalId)){
                salesOrder.NS_Product__c = nsProdIntIdMap.get(projProdInternalId);
            }
            if(nsCostCentreIntId != null && nsCostCentreIntIdMap != null && nsCostCentreIntIdMap.containsKey(nsCostCentreIntId)){
                salesOrder.NS_Cost_Centre__c = nsCostCentreIntIdMap.get(nsCostCentreIntId).Id;
            }
        }
        try {
            insert salesOrder;
        } catch(Exception ex){
            retString = 'Some error occured while creating the RLF Package';
            Database.rollback(sp1);
            billingGroup.RLF_Batch_Create_Failed__c = true;
            billingGroup.RLF_Batch_Create_Failure_Reason__c = 'Following error occured while creating the Sales Order - ' + ex;
            update billingGroup;
            return retString;
            //throw ex;
        }
        
        
        //Create Sales Order Items for RLF
        if(caList != null && caList.size() > 0){
            Sales_Order_Item__c soItem;
            list<Sales_Order_Item__c> soiList = new list<Sales_Order_Item__c>();
            list<Sales_Order_Item__c> newSOIList = new list<Sales_Order_Item__c>();
            Integer i = 1;
            Boolean planError = false;
            for(Contract_Asset__c contractAsset : caList){
                soItem = new Sales_Order_Item__c();
                soItem.Line__c = i++;
                soItem.Sales_Order__c = salesOrder.Id;
                soItem.Contract_Asset__c = contractAsset.Id;
                soItem.Name = contractAsset.Name;
                soItem.NS_Item__c = contractAsset.Product__c;
                soItem.Non_GA__c = contractAsset.Asset_Product_GA__c;
                soItem.Software_Delivered__c = contractAsset.NS_SOI_Software_Delivered__c;
                soItem.Quantity__c = contractAsset.Sold_Quantity__c;
                //soItem.Amount__c = contractAsset.Annual_Maintenance_for_NS__c;
                //soItem.Rate__c = contractAsset.Annual_Maintenance_for_NS__c;
                soItem.Amount__c = contractAsset.Final_RLF_Amount_for_NS__c;
                soItem.Rate__c = contractAsset.Final_RLF_Amount_for_NS__c;
                //FRD 14 (Phase 2)
                soItem.CA_RF_Earliest_Review_Date__c = 	contractAsset.CA_Recurring_Fees_Earliest_Review_Date__c;
                //check for zero decimal currency and contractAsset.Final_RLF_Amount_for_NS__c does not have decimal
                if(nsCurrency.IsZeroDecimal__c == true && soItem.Rate__c != null){
                    string rateString = soItem.Rate__c.format();
                    if(rateString.indexOf('.') > 0 && Decimal.valueOf(rateString.substring(rateString.indexOf('.')+1)) > 0){
                        Database.rollback(sp1);
                        billingGroup.RLF_Batch_Create_Failed__c = true;
                        billingGroup.RLF_Batch_Create_Failure_Reason__c = 'Could not create package as the currency is Zero decimal and rate ' + soItem.Rate__c + ' has got decimals in it';
                        //using the planError flag instead of introducing a new one
                        planError = true;
                        if(packageTobeCreated != 'Batch'){
                            return retString = 'Could not create package as the currency is Zero decimal and rate ' + soItem.Rate__c + ' has got decimals in it';
                        }
                    } else if(billingGroup.NS_Billing_Frequency__r.Invoices_per_year__c != null){
                        if(Math.mod(soItem.Rate__c.intValue(), billingGroup.NS_Billing_Frequency__r.Invoices_per_year__c.intValue()) > 0){
                            Database.rollback(sp1);
                            billingGroup.RLF_Batch_Create_Failed__c = true;
                            billingGroup.RLF_Batch_Create_Failure_Reason__c = 'Could not create package as the currency is Zero decimal and rate ' + soItem.Rate__c + ' is not fully divisible by Invoices per year ' + billingGroup.NS_Billing_Frequency__r.Invoices_per_year__c.intValue();
                            //using the planError flag instead of introducing a new one
                            planError = true;
                            if(packageTobeCreated != 'Batch'){
                                return retString = 'Could not create package as the currency is Zero decimal and rate ' + soItem.Rate__c + ' is not fully divisible by Invoices per year ' + billingGroup.NS_Billing_Frequency__r.Invoices_per_year__c.intValue();
                            }
                        }
                    }
                }
                soItem.Rev_Rec_Start_Date__c = billingGroup.Current_Sales_Order_Start_Date__c;
                soItem.Planned_Recurring_Billing_Start_Date__c = billingGroup.Current_Sales_Order_Start_Date__c;
                soItem.VSOE_Price__c = contractAsset.Current_Fair_Value__c;
                soItem.CurrencyIsoCode = billingGroup.CurrencyIsoCode;
                soItem.Description__c = contractAsset.Name;
                soItem.Discount__c = contractAsset.RLF_Discount_Premium__c;
                soItem.ThirdParty_Recurring_Costs_PO_Ccy__c = contractAsset.X3PP_Recurring_Costs__c;
                if(nsCurrencyMap.containsKey(contractAsset.X3PP_Currency__c)){
                    soItem.ThirdParty_PO_Currency__c = nsCurrencyMap.get(contractAsset.X3PP_Currency__c).Id;
                }
                soItem.Vendor_BSch_Trigger__c = contractAsset.Vendor_BSch_Trigger__c;//'Manual';
                soItem.Create_3PP_Event__c = contractAsset.Product__r.NS_Create_3PP_Event__c;
                soItem.X3PP_Discount__c = contractAsset.X3PP_Discount__c;
                soItem.Licence_Basis__c = contractAsset.Licence_Band__c;
                soItem.Rec_Billing_Start_Trigger__c = contractAsset.NS_Subscription_Item_Start_Trigger__c;
                if(soItem.Rec_Billing_Start_Trigger__c == 'Immediate'){
                    soItem.Start_Type__c = 'Immediate';
                } else {
                    soItem.Start_Type__c = 'Suspended';
                }
                if(subPlanKeySubPlanItemMap.containsKey(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c) && 
                    subPlanKeySubPlanItemMap.get(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c).NS_Subscription_Plan__r.Status__c == 'Available' && 
                    subPlanKeySubPlanItemMap.get(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c).NS_Subscription_Plan__r.Inactive_in_SFDC__c == false){
                        
                    soItem.NS_Subscription_Plan_Item__c = subPlanKeySubPlanItemMap.get(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c).Id;
                    soItem.NS_Subscription_Plan__c = subPlanKeySubPlanItemMap.get(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c).NS_Subscription_Plan__c;
                    
                } else if(subPlanKeySubPlanItemMap.containsKey(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c) && 
                    subPlanKeySubPlanItemMap.get(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c).NS_Subscription_Plan__r.Status__c != 'Available' && 
                    subPlanKeySubPlanItemMap.get(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c).NS_Subscription_Plan__r.Inactive_in_SFDC__c == false){
                        
                    Database.rollback(sp1);
                    billingGroup.RLF_Batch_Create_Failed__c = true;
                    billingGroup.RLF_Batch_Create_Failure_Reason__c = 'Could not create package as there is a matching subscription plan but the status is ' + subPlanKeySubPlanItemMap.get(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c).NS_Subscription_Plan__r.Status__c;
                    planError = true;
                    if(packageTobeCreated != 'Batch'){
                        return retString = 'Could not create package as there is a matching subscription plan but the status is ' + subPlanKeySubPlanItemMap.get(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c).NS_Subscription_Plan__r.Status__c;
                    }
                    
                } else {
                    Database.rollback(sp1);
                    billingGroup.RLF_Batch_Create_Failed__c = true;
                    billingGroup.RLF_Batch_Create_Failure_Reason__c = 'Could not create package as one or more subscription plans are not available for this billing profile';
                    planError = true;
                    if(packageTobeCreated != 'Batch'){
                        return retString = 'Could not create package as one or more subscription plans are not available for this billing profile';
                    }
                }
                
                if(planError == false){
                    newSOIList.add(soItem);
                }
            }
            if(planError == false && newSOIList != null && newSOIList.size() > 0){
                soiList.addAll(newSOIList);
                if(packageTobeCreated == 'Batch'){
                    billingGroup.RLF_Batch_Create_Complete__c = true;
                }
            }
            if(soiList != null && soiList.size() > 0){
                try {
                    insert soiList;
                    
                } catch(Exception ex){
                    retString = 'Some error occured while creating the RLF Package';
                    Database.rollback(sp1);
                    billingGroup.RLF_Batch_Create_Complete__c = false;
                    billingGroup.RLF_Batch_Create_Failed__c = true;
                    billingGroup.RLF_Batch_Create_Failure_Reason__c = 'Following error occured while creating the Sales Order Items - ' + ex;
                    //throw ex;
                }
            }
            if(packageTobeCreated != null && packageTobeCreated == 'Initial'){
                billingGroup.Initial_RLF_Package_Created__c = true;
            } else if(packageTobeCreated != null && packageTobeCreated == 'Reseed'){
                billingGroup.Reseed_RLF_Package_Created__c = true;
            }
            update billingGroup;
        }
        //End Create Sales Order Items for RLF
        return retString;
    }
    
    //This method is for checking the availability of the Subscription Plans based on the Subscription Plan Key
    //This is called from a custom button on Billing Group
    webservice static String checkPlanAvailability(Id bgId){
        string retString = '';
        Billing_Group__c billingGroup = getBillingGroup(bgId);
        set<String> subPlanKeys = new set<String>();
        
        list<Contract_Asset__c> caList = getContractAssets(bgId);

        if(caList == null || caList.size() == 0){
            return 'There are no Active Billing contract assets for this Billing Group';
        } else if(caList != null || caList.size() > 0){
            for(Contract_Asset__c ca : caList){
                //caList.add(ca);
                if(ca.NS_Subscription_Plan_Key__c != null){
                    subPlanKeys.add(ca.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c);
                }
            }
        }
        system.debug('caList = ' + caList);
        system.debug('subPlanKeys = ' + subPlanKeys);

        map<String, NS_Subscription_Plan_Item__c> subPlanKeySubPlanItemMap = getSubPlanItemMap(subPlanKeys);
        
        for(Contract_Asset__c contractAsset : caList){
            if(subPlanKeySubPlanItemMap.containsKey(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c) && 
                subPlanKeySubPlanItemMap.get(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c).NS_Subscription_Plan__r.Status__c == 'Available' && 
                subPlanKeySubPlanItemMap.get(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c).NS_Subscription_Plan__r.Inactive_in_SFDC__c == false){
                    
                retString = 'Matching Subscription Plans are available';
                    
            } else if(subPlanKeySubPlanItemMap.containsKey(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c) && 
                subPlanKeySubPlanItemMap.get(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c).NS_Subscription_Plan__r.Status__c != 'Available' && 
                subPlanKeySubPlanItemMap.get(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c).NS_Subscription_Plan__r.Inactive_in_SFDC__c == false){
                    
                 return retString = 'There is a matching subscription plan but the status is ' + subPlanKeySubPlanItemMap.get(contractAsset.NS_Subscription_Plan_Key__c + billingGroup.Subscription_Plan_Base_Key__c).NS_Subscription_Plan__r.Status__c;
                
            } else {
                return retString = 'One or more subscription plans are not available for this billing profile';
            }
        }
        return retString;
    }
    
    webservice static list<String> checkZeroDecimalCurrency(Id bgId){
        boolean flag = false;
        list<string> retList = new list<string>();
        Billing_Group__c billingGroup = getBillingGroup(bgId);
        NS_Currency__c nsCurrency = [select id, Name, NS_Currency_Internal_Id__c, IsZeroDecimal__c from NS_Currency__c where Name = :billingGroup.CurrencyIsoCode];

        system.debug('nsCurrency = ' + nsCurrency);
        
        list<Contract_Asset__c> caList = getContractAssets(bgId);
        
        for(Contract_Asset__c contractAsset : caList){
            //check for zero decimal currency and contractAsset.Final_RLF_Amount_for_NS__c does not have decimal
            if(nsCurrency.IsZeroDecimal__c == true && contractAsset.Final_RLF_Amount_for_NS__c != null){
                string rateString = contractAsset.Final_RLF_Amount_for_NS__c.format();
                if(rateString.indexOf('.') > 0 && Decimal.valueOf(rateString.substring(rateString.indexOf('.')+1)) > 0){
                    //retList.add('Could not create package as the currency is Zero decimal and rate ' + contractAsset.Final_RLF_Amount_for_NS__c + ' has got decimals in it');
                    retList.add(contractAsset.name + ' - Please round the annual maintenance amount for Contract Asset ('+contractAsset.name+') to have ZERO decimals on assets..(annual amount not .00)');
                    flag = true;
                } else if(billingGroup.NS_Billing_Frequency__r.Invoices_per_year__c != null){
                    if(Math.mod(contractAsset.Final_RLF_Amount_for_NS__c.intValue(), billingGroup.NS_Billing_Frequency__r.Invoices_per_year__c.intValue()) > 0){
                        //retList.add('Could not create package as the currency is Zero decimal and rate ' + contractAsset.Final_RLF_Amount_for_NS__c + ' is not fully divisible by Invoices per year ' + billingGroup.NS_Billing_Frequency__r.Invoices_per_year__c.intValue());
                        retList.add('Please adjust the annual maintenance for Contract Asset ('+contractAsset.name+') to have ZERO decimals on assets for each invoice (rate amount for invoice not .00)');
                        flag = true;
                    }
                }
            }
        }
        if(flag == false){
            retList.add('There are no currency errors');
        }
        
        return retList;
    }
    
    //This method returns the Billing Group
    private static Billing_Group__c getBillingGroup(Id bgId){
        Billing_Group__c billingGroup = [select id, Name, Original_Opportunity__c, Original_Opportunity__r.CurrencyIsoCode, Original_Opportunity__r.Customer_PO__c, 
        Original_Opportunity__r.CloseDate, Original_Opportunity__r.OwnerId, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Original_Opportunity__r.Owner.FirstName, 
        Original_Opportunity__r.Owner.LastName, Original_Contract__c, Original_Contract__r.CustomerSignedDate, Original_Contract__r.StartDate, 
        Original_Contract__r.Memo__c, Account_by_Sub__c, Account_by_Sub__r.name, Account_by_Sub__r.Misys_Entity__c, Account_by_Sub__r.Account__r.NS_Finance_Region__c, 
        Account_by_Sub__r.Account__r.NS_Currency__c, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.PO_Required__c, 
        Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c, Account_by_Sub__r.NS_Export_to_Openair__c, 
        Account_by_Sub__r.Account__r.Credit_Controller__c, Account_by_Sub__r.NS_Invoice_Translation__c, Account_by_Sub__r.NS_Invoice_Translation_Language__c,
        Account_by_Sub__r.NS_Invoice_Translation_Language_Code__c, CurrencyIsoCode, Customer_PO_Number__c, NS_Customer_Address__c, NS_Customer_Ship_To_Address__c,
        Original_Customer_Signed_Date__c, Current_Sales_Order_Start_Date__c, NS_Subscription_Start_Date__c, NS_Subscription_Memo__c, NS_Subscription_Start_Type__c,
        NS_Subscription_Option__c, NS_Billing_Mode__c, NS_Termination_Method__c, Fixed_Billing_Date__c, Subscription_Plan_Base_Key__c,
        Reset_Next_Bill_Date__c, BG_Next_Invoice_Due_Date__c, NS_Specific_Invoice_Wording__c, Set_Tax_Combo_Override__c, BG_Opportunity_Number_s_migration__c,
        BG_Contract_Date_migration__c, Order_Sub_Type__c, NS_Billing_Frequency__r.Invoices_per_year__c
        //BG_Contract_Date_migration__c, Order_Sub_Type__c, RF_Review_Month__c 
        from Billing_Group__c where id = :bgId];
        
        system.debug('billingGroup = ' + billingGroup);
        return billingGroup;
    }
    
    //This method returns the list of contract assets based on the passed in billing group id
    private static list<Contract_Asset__c> getContractAssets(Id bgId){
        return [select id, Name, Asset_Product_GA__c, NS_SOI_Software_Delivered__c, Annual_Maintenance_for_NS__c, Sold_Quantity__c, RLF_Discount_Premium__c, 
                                    Product__c, Product__r.NS_Product_Dimension_ID__c, Product__r.NS_Cost_Centre__c, Product__r.NS_Cost_Centre_ID__c, 
                                    Current_Fair_Value__c, X3PP_Recurring_Costs__c, X3PP_Currency__c, Vendor_BSch_Trigger__c, Product__r.NS_Create_3PP_Event__c, 
                                    X3PP_Discount__c, Licence_Band__c, NS_Subscription_Plan_Key__c, NS_Subscription_Item_Start_Trigger__c, CurrencyIsoCode,
                                    Final_RLF_Amount_for_NS__c, CA_Recurring_Fees_Earliest_Review_Date__c
                                    from Contract_Asset__c where CA_Billing_Group__c = :bgId and CA_Billing_Status__c = 'Active billing'];
    }

    //This method returns the map of the Subscription plan items based on the subscription plan keys
    private static map<String, NS_Subscription_Plan_Item__c> getSubPlanItemMap(set<String> subPlanKeys){
        map<String, NS_Subscription_Plan_Item__c> subPlanKeySubPlanItemMap = new map<String, NS_Subscription_Plan_Item__c>();
        if(subPlanKeys != null && subPlanKeys.size() > 0){
            for(NS_Subscription_Plan_Item__c subPlanItem : [select id, name, NS_Subscription_Plan__c, NS_Subscription_Plan_Key__c, NS_Subscription_Plan__r.Status__c,
                                                            NS_Subscription_Plan__r.Inactive_in_SFDC__c 
                                                            from NS_Subscription_Plan_Item__c where NS_Subscription_Plan_Key__c in : subPlanKeys]){
                subPlanKeySubPlanItemMap.put(subPlanItem.NS_Subscription_Plan_Key__c, subPlanItem);
            }
        }
        system.debug('subPlanKeySubPlanItemMap = ' + subPlanKeySubPlanItemMap);
        return subPlanKeySubPlanItemMap;
    }

    //This method is for checking the availability of the Subscription Plans based on the Subscription Plan Key
    //This is called from a custom button on OBS
    webservice static String checkPlanAvailabilityFromOBS(Id obsId){
        string retString = '';
        set<String> subPlanKeys = new set<String>();
        
        list<OpportunityLineItem> oliList = getOLIs(obsId);

        if(oliList == null || oliList.size() == 0){
            return 'There are no OLIs for this OBS';
        } else if(oliList != null || oliList.size() > 0){
            for(OpportunityLineItem oli : oliList){
                //caList.add(ca);
                if(oli.Subscription_Plan_Key__c != null){
                    subPlanKeys.add(oli.Subscription_Plan_Key__c);
                }
            }
        }
        system.debug('oliList = ' + oliList);
        system.debug('subPlanKeys = ' + subPlanKeys);

        map<String, NS_Subscription_Plan_Item__c> subPlanKeySubPlanItemMap = getSubPlanItemMap(subPlanKeys);
        
        for(OpportunityLineItem oli : oliList){
            if(subPlanKeySubPlanItemMap.containsKey(oli.Subscription_Plan_Key__c) && 
                subPlanKeySubPlanItemMap.get(oli.Subscription_Plan_Key__c).NS_Subscription_Plan__r.Status__c == 'Available' && 
                subPlanKeySubPlanItemMap.get(oli.Subscription_Plan_Key__c).NS_Subscription_Plan__r.Inactive_in_SFDC__c == false){
                retString = 'Matching Subscription Plans are available';    
            } else if(subPlanKeySubPlanItemMap.containsKey(oli.Subscription_Plan_Key__c) && 
                subPlanKeySubPlanItemMap.get(oli.Subscription_Plan_Key__c).NS_Subscription_Plan__r.Status__c != 'Available' && 
                subPlanKeySubPlanItemMap.get(oli.Subscription_Plan_Key__c).NS_Subscription_Plan__r.Inactive_in_SFDC__c == false){
                retString = 'There is a matching subscription plan but the status is ' + subPlanKeySubPlanItemMap.get(oli.Subscription_Plan_Key__c).NS_Subscription_Plan__r.Status__c;
            } else {
                retString = 'One or more subscription plans are not available for this OBS';
            }
        }
        return retString;
    }

    //This method returns the list of OLIs based on the passed in Obs id
    private static list<OpportunityLineItem> getOLIs(Id obsId){
        return [Select Id,PricebookEntry.Product2.UPID__c, Subscription_Plan_Key__c from OpportunityLineItem where Opportunity_Billing_Schedule__c = :obsId];
    }
}