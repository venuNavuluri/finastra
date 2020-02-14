/**
 * @File Name          : SO_RevenueTypeGrouping.cls
 * @Description        : 
 * @Author             : venu.navuluri@finastra.com
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 31/07/2019, 11:19:32
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    15/05/2019, 16:52:40   venu.navuluri@finastra.com     Initial Version
**/
public class SO_RevenueTypeGrouping {
    
    
     public static String SubcriptionFields = 'SELECT Id, OwnerId, Name, CurrencyIsoCode, CreatedDate, Billing_group__c,  SBQQ__Account__c,SO_Amount__c,Opportunity_Billing_Schedule__c,Opportunity_Billing_Schedule__r.Name,SBQQ__Contract__r.SBQQ__Opportunity__r.Order_Number__c, ' +
                                             'Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode,Billing_Group__r.Account_by_Sub__r.Account__r.NS_Finance_Region__c,Billing_Group__r.BG_Misys_Billing_Entity__c,Sales_Order_Type__c,ProdType__c, ' +
                                             'SBQQ__Contract__r.Total_Rebate_Amount__c, SBQQ__Contract__r.Total_Rebate_Percent__c, ' +
                                             'SBQQ__Contract__r.SBQQ__Opportunity__r.StageName, SBQQ__Contract__r.SBQQ__Opportunity__r.CloseDate, SBQQ__Contract__r.SBQQ__Opportunity__r.ForecastCategoryName, SBQQ__Contract__r.SBQQ__Opportunity__r.Probability, ' +
                                             'SBQQ__Contract__r.SBQQ__Opportunity__r.PS_Forecast_Probability__c, SBQQ__Contract__r.CustomerSignedDate, Billing_Group__r.Account_by_Sub__c, SBQQ__Contract__r.SBQQ__Opportunity__r.PS_Top_Opportunity__c, ' +
                                             'Next_SO_generation_Date__c, Next_Billing_Date__c, Billing_Day__c, Billing_Month__c , SBQQ__BillingType__c ,Pro_Rata_Calculated__c,SO_Generation_Advance__c,Last_Prorata_required__c,Last_Prorata_Calculated__c, ' +
                                             'Prorata_Days__c, Transactions__c,Transactional__c,Transactions_Not_Received__c,RF_Start_Planned_Date__c,Asset_Name__c,BG_Next_Billing_Date__c,Expired_Subscription__c,Expiry_Date__c, ' +
        									 'Ship_From_Code__c, SBQQ__ListPrice__c, SBQQ__Product__r.NS_Rev_Rec_Template_ID__c, Billing_Group__r.CurrencyIsoCode, SBQQ__PartnerDiscount__c, SBQQ__Product__r.NS_Create_3PP_Event__c,Third_Party_Vendor__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Host_Processor__c, ' +
                                             'SBQQ__Product__c,SBQQ__Product__r.Name,SBQQ__Product__r.NS_Cost_Centre_ID__c,SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c,SBQQ__Product__r.NS_Product_Dimension_ID__c,SBQQ__Product__r.GA__c, SBQQ__Product__r.Payaway__c, ' +
                                             'SBQQ__Quantity__c,SBQQ__BillingFrequency__c, SBQQ__Bundle__c,SBQQ__NetPrice__c, SBQQ__ChargeType__c,  SBQQ__ContractNumber__c  from SBQQ__Subscription__c ';
    
    
     public static String BillingGroupFields = ' SELECT Id, Name, Recurring_Batch_Error_Logs__c, Original_Contract__r.Recurring_Fees_Start_Planned__c,Account_by_Sub__r.Account__r.NS_Finance_Region__c,NS_Customer_Address__r.Synced_To_NS__c,NS_Customer_Ship_To_Address__r.Synced_To_NS__c, ' +
                                               ' Account_by_Sub__r.Synced_To_NS__c, BG_Opportunity_Number_s_migration__c, Next_Billing_Date__c,Original_Contract__c, Account_by_Sub__r.Account__r.NS_Term__c,Account_by_Sub__r.Account__r.Credit_Controller__c,Original_Opportunity__r.Owner.FirstName, ' +
                                               ' Original_Opportunity__r.Owner.LastName,Original_Contract__r.Contract_Expiry_Date__c,Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, NS_CUstomer_Address__c,NS_Customer_Ship_To_Address__c, Original_Customer_Signed_Date__c, ' +
                                               ' BG_Contract_Date_migration__c, NS_Subscription_Start_Date__c, NS_Subscription_Start_Type__c, Original_Opportunity__r.Customer_PO__c,Original_Opportunity__r.CloseDate,Original_Contract__r.Memo__c,Account_by_Sub__r.Account__r.PO_Required__c, ' +
                                               ' Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate, Original_Contract__r.CustomerSignedDate,NS_Subscription_Option__c,NS_Billing_Mode__c, ' +
                                               ' NS_Termination_Method__c, Next_SO_generation_Date__c,Fixed_Billing_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c, NS_Specific_Invoice_Wording__c, Set_Tax_Combo_Override__c, Order_Sub_Type__c, BG_Client_Contracting_Name__c, ' +
                                               ' Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__c, Original_Opportunity__c, CurrencyIsoCode, Current_Sales_Order_Start_Date__c, NS_Subscription_Memo__c , BG_Misys_Billing_Entity__c, BG_Client_Bill_To__c , BG_Client_Ship_To__c, Transaction_Late__c,RLF_SO_On_Hold_Since__c, ' +
                                               ' BG_Billing_Group_Active__c, BG_Data_Status__c, Original_Contract_Expiry_Date__c , Original_Contract__r.ContractTerm FROM BIlling_GROUP__C ' ;

  
    public static Map<String, List<SBQQ__Subscription__c>> getILFsubs(Contract con){

        Map<String, List<SBQQ__Subscription__c>> ilf_subList_Map = new Map<String, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
       
         List<SBQQ__Subscription__c> subQuery = Database.query(SubcriptionFields + ' where SBQQ__Contract__c = \''+ con.Id +'\' AND Sales_Order_Type__c =  \'ILF\'');

            for(SBQQ__Subscription__c sub: subQuery){
                                                subList.add(sub);  
                                               String str = sub.Sales_Order_Type__c;    
                                               ilf_subList_Map.put(str, subList);
                                               system.debug('total ILF so size => ' + ilf_subList_Map);
                                            }

      system.debug('mark here ILF => '+ilf_subList_Map.values());
        
        for(String s: ilf_subList_Map.KeySet()){
            system.debug(' soType => '+s+' , size => '+ilf_subList_Map.get(s).size());
        }
        return ilf_subList_Map;
    }
    
    public static Map<String, List<SBQQ__Subscription__c>> getGSsubs(Contract con){

        Map<String, List<SBQQ__Subscription__c>> gs_subList_Map = new Map<String, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subList ;

          List<SBQQ__Subscription__c> subQuery = Database.query(SubcriptionFields + ' where SBQQ__Contract__c = \''+ con.Id +'\' AND Sales_Order_Type__c =  \'GS\'');

            for(SBQQ__Subscription__c sub: subQuery){
                                               subList = new List<SBQQ__Subscription__c>();
                                               if (gs_subList_Map.KeySet().contains('GS-' + sub.ProdType__c)) {
                                                    subList = gs_subList_Map.get('GS-' + sub.ProdType__c);                                                    
                                                }
                                                subList.add(sub);
                                                gs_subList_Map.put('GS-' + sub.ProdType__c, subList);
                                               system.debug('total PS Sales Order size => ' + gs_subList_Map);
                                            
                                            }

    system.debug('mark here PS => '+gs_subList_Map.keyset());
        
        for(String s: gs_subList_Map.KeySet()){
            
            system.debug(' soType => '+s+' , size => '+gs_subList_Map.get(s).size());
        }
        return gs_subList_Map;
    }
    
    public static Map<String, List<SBQQ__Subscription__c>> getRLFsubs(Contract con){

        Map<String, List<SBQQ__Subscription__c>> RLF_subList_Map = new Map<String, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
         Date billDate = Date.today() ;
          List<SBQQ__Subscription__c> subQuery = Database.query(SubcriptionFields + ' where SBQQ__Contract__c = \''+ con.Id +'\' AND Next_SO_generation_Date__c <=: billDate AND Sales_Order_Type__c =  \'RLF\'');

            for(SBQQ__Subscription__c sub: subQuery){
                                                subList.add(sub);  
                                               String str = sub.Sales_Order_Type__c ;    
                                               RLF_subList_Map.put(str, subList);
                                               system.debug('total rlf Sales Order size => ' + RLF_subList_Map);
                                            
                                            }

    system.debug('mark here RLF => '+RLF_subList_Map.values());
        
        for(String s: RLF_subList_Map.KeySet()){
            system.debug(' soType => '+s+' , size => '+RLF_subList_Map.get(s).size());
        }
        return RLF_subList_Map;
    } 
    
    public static Map<String, SBQQ__Subscription__c> getProjSubMap(Map<String, String> soType_subs_map){
        Map<String, SBQQ__Subscription__c> returnMap = new Map<String, SBQQ__Subscription__c>();
        set<String> setsubIds = new set<String>();
        setsubIds.addAll(soType_subs_map.Values());

        system.debug('obs_sub_map =>'+setsubIds);

        List<SBQQ__Subscription__c> subQuery = Database.query(SubcriptionFields + ' where Id IN : setsubIds ');

            for(SBQQ__Subscription__c sub: subQuery){
                returnMap.put(sub.Id, sub);
                system.debug('returnMap =>'+returnMap);
            }
        
        return returnMap;
    }
    
    public static Map<Id, List<SBQQ__Subscription__c>> getManualRLFsubs(Id billingId){

        Map<Id, List<SBQQ__Subscription__c>> RLF_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
         
          List<SBQQ__Subscription__c> subQuery = Database.query(SubcriptionFields + ' where Billing_Group__c = \''+ billingId +'\' AND BG_Next_Billing_Date__c = TRUE AND Expired_Subscription__c = false AND Sales_Order_Type__c =  \'RLF\'');

            for(SBQQ__Subscription__c sub: subQuery){
                                               subList.add(sub);  
                                               RLF_subList_Map.put(sub.Billing_Group__c, subList);
                                               system.debug('total rlf Sales Order size => ' + RLF_subList_Map);
                                            
                                            }

    system.debug('mark here RLF => '+RLF_subList_Map.values());
        
        for(String s: RLF_subList_Map.KeySet()){
            system.debug(' soType => '+s+' , size => '+RLF_subList_Map.get(s).size());
        }
        return RLF_subList_Map;
    } 
    
    public static Map<Id, Billing_Group__c> getmanualbg_map(Id billingId){ 
        
        Map<Id, Billing_Group__c> bg_map = new Map<Id, Billing_Group__c>();
        
        List <Billing_Group__c> bgQuery = Database.query(BillingGroupFields + ' where Id =: billingId ');
        
                    for(Billing_Group__c bg: bgQuery){ 
                                                        bg_map.put(bg.ID, bg);
                                                    }
       
        return bg_map;
        
    }
    
   
}