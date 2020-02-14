/**
 * @File Name          : SO_SOCreationHelper.cls
 * @Description        : 
 * @Author             : venu.navuluri@finastra.com
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 31/07/2019, 11:18:01
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    22/05/2019, 17:05:26   venu.navuluri@finastra.com     Initial Version
**/
public with sharing class SO_SOCreationHelper {

    public static Sales_Order__c[] createSalesOrder(Contract con, Billing_Group__c bg, Map <String, Integer> soType_counter_Map, Map < String, NS_Project__c > soType_proj_map, Map < String, NS_Currency__c > nsCurrencyMap, Map <String, SBQQ__Subscription__c > maxSub_map, Map<String, String> soType_sub_max) {
        List < Sales_Order__c > soList = new List < Sales_Order__c > ();
        system.debug('mark here =>' + soType_proj_map);
        system.debug('mark here =>' + soType_counter_Map.keySet());
        system.debug('mark here =>' + soType_proj_map.keySet());
        boolean isILFCreated = false;
        
        for (String s: soType_counter_Map.keySet()) {
            system.debug('mark here =>' + soType_proj_map.get(s));
            
            if(soType_counter_Map.get(s) > 0){
                if (s.contains('ILF') && !isILFCreated) {
                    soList.add(ILF_SOCreation.addILFSalesOrder(con, bg, soType_proj_map.get(s),maxSub_map.get(soType_sub_max.get(s)), nsCurrencyMap));
                    isILFCreated = true;
                } else if (s.contains('GS')) {
                    soList.add(PS_SOCreation.addPSSalesOrder(con, bg, soType_proj_map.get(s),maxSub_map.get(soType_sub_max.get(s)), nsCurrencyMap));
                }
            }
        }
        system.debug('SO creation list =>' + soList.size());
        if (soList.size() > 0) {
            insert soList;
        }
        
        
        return soList;
    
    }
    
    public static void updateCustomerBillingSchedule(Sales_Order__c[] soList) {
        Map < Id, Id > proj_so_map = new Map < Id, Id > ();
        for (Sales_Order__c so: [SELECT Id, BIlling_GROUP__C, NS_Project__c FROM Sales_Order__c WHERE Id IN: soList]) {
            proj_so_map.put(so.NS_Project__c, so.Id);
        }
        
        List < NS_Customer_Billing_Schedule__c > cbsList = new List < NS_Customer_Billing_Schedule__c > ();
        
        for (NS_Customer_Billing_Schedule__c bs: [select Id, Sales_Order__c, Project__C from NS_Customer_Billing_Schedule__c where Project__c in: proj_so_map.keySet()]) {
            bs.Sales_Order__c = proj_so_map.get(bs.Project__c);
            cbsList.add(bs);
        }
        
        if (cbsList.size() > 0) {
            try {
                update cbsList;
                //tempResponse += '=>Customer Billing Schdule - updated with ILF SalesOrder \n';
            }
            Catch(Exception Ex) {
                //tempResponse += '=>Customer Billing Schdule - Failed to link with ILF SalesOrder - ' + Ex.getMessage() + '\n';
            }
        }
    
    }
    
    public static void createSalesOrderItems(Sales_Order__c[] soList, Map < String, List < SBQQ__Subscription__c >> soType_subs_map, Map < String, NS_Currency__c > nsCurrencyMap, Map<string, string> proj_so_map) {
        List < Sales_Order_Item__c > itemsList = new List < Sales_Order_Item__c > ();
        system.debug('so sub gropu type => ' +soType_subs_map.values());
        // SO Items Creation for Only ILF
        Sales_Order__c ILF_SO = new Sales_Order__c();
        
        for (Sales_Order__c so: soList) {
            system.debug('so sub gropu type => ' + so.Order_Type__c);
            if (so.Order_Type__c.contains('ILF')) {
                ILF_SO = so;
            }
        }
        List < SBQQ__Subscription__c > sub_allList = new List < SBQQ__Subscription__c > ();
        Set < NS_Vendor_Billing_Schedule__c > vbsList = new Set < NS_Vendor_Billing_Schedule__c > ();
        for (String s: soType_subs_map.keySet()) {
            if (s.contains('ILF')) {
                sub_allList.addAll(soType_subs_map.get(s));
            }
        }
        Sales_Order_Item__c soiItem = new Sales_Order_Item__c();
        Integer i = 1;
        for (SBQQ__Subscription__c sub: sub_allList) {
            if (sub.ProdType__c.contains('ILF')) {
                system.debug('calling ILF so Item --');
                soiItem = ILF_SOCreation.addILFSalesOrderItem(sub, i, ILF_SO, nsCurrencyMap);
                itemsList.add(soiItem);
                i++;
                if (sub.SBQQ__Product__r.Payaway__c) {
                    system.debug('Adding VBS =>' + soiItem);
                    vbsList.add(ILF_SOCreation.addVendorBillingScheule(ILF_SO, soiItem, sub));
                }
                
            }
        }
        
        // SO Items creation for only PS
        for (Sales_Order__c so: soList) {
            if(so.Order_Type__c.contains('PS')){
                i = 1;
                for(SBQQ__Subscription__c sub: soType_subs_map.get(proj_so_map.get(so.NS_Project__c))){
                    system.debug(proj_so_map.get(so.NS_Project__c)+' am giving my sub to PS SO items => '+sub.Opportunity_Billing_Schedule__c);
                    itemsList.addAll(PS_SOCreation.addPSSalesOrderItem(sub, i, so/*, revScheduleMap, internalIdOARevenueRuleMap, internalIdOABillingRuleMap*/));
                    i++;
                }
            }
        }
        
        if (itemsList.size() > 0) {
            try{
                insert itemsList;
            } Catch (Exception Ex){
                system.debug('error inserting items list => '+itemsList);
            }
        }
        
        if (vbsList.size() > 0) {
            try {
                List < NS_Vendor_Billing_Schedule__c > vbsList_list = new List < NS_Vendor_Billing_Schedule__c > ();
                vbsList_list.addAll(vbsLIst);
                insert vbsList_list;
                system.debug('insert vbs =>' + vbsList);
                //tempResponse += '=> Success! Vendor Billing schedule Created \n';
                ILF_SOCreation.createVBSItem(vbsList_list, ILF_SO.NS_Project__C);
                
                // update so
                Map < Id, Id > sub_vbsId_Map = new Map < Id, Id > ();
                Map < Id, Id > sub_proj_Map = new Map < Id, Id > ();
                for (NS_Vendor_Billing_Schedule__c vbs: vbsList_list) {
                    sub_vbsId_Map.put(vbs.Subscription_Id__c, vbs.Id);
                    sub_proj_Map.put(vbs.Subscription_Id__c, vbs.NS_Project__c);
                }
                
                system.debug('sub vbs mapping =>' + sub_vbsId_Map);
                List < Sales_Order_Item__c > soi_list = new List < Sales_Order_Item__c > ();
                for (Sales_Order_Item__c soi: [SELECT Id, Name, Subscription__c, NS_Vendor_Billing_Schedule__c, Sales_Order__r.NS_Project__c FROM Sales_Order_Item__c WHERE Subscription__c IN: sub_vbsId_Map.keySet()]) {
                    if (sub_proj_Map.get(soi.Subscription__c) == soi.Sales_Order__r.NS_Project__c) {
                        soi.NS_Vendor_Billing_Schedule__c = sub_vbsId_Map.get(soi.Subscription__c);
                        soi_list.add(soi);
                        system.debug('added soi list of ' + soi.Id + ' =>' + sub_vbsId_Map.get(soi.Subscription__c));
                    }
                }
                
                update soi_list;
            }
            Catch(Exception Ex) {
                system.debug('vbs error here => ' + ex.getMessage());
                system.debug('vbs error here => ' + ex.getlineNumber());
                //tempResponse += '=> Error! Vendor Billing schedule insertion failed' + Ex.getMessage() + '\n';
            }
        }
    }
}