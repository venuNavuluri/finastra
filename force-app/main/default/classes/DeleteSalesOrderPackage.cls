/*
    Created By: Abhinit Kohar
    Created Date: 10/06/2014
    Description: This class is getting invoked from the Delete Sales Orders button on the Contract.
    This will delete all the sales orders, ns projects, ns customer billing schedules which are not yet syced with NS.
    This will update the Processed flag on Opportunity Line Items to false.
    
    This is tested from the Test_ce4sfStep_CreateILFPackage class
*/
global class DeleteSalesOrderPackage {

    webservice static String deletePackage(Id conId){
        String response = '';
        set<String> soTypeSet = new set<String>();
        set<id> soIds = new set<id>();
        set<id> projIds = new set<id>();
        
        try {
            Contract contract = [select id, Misys_opportunity__c from Contract where id = :conId];
            //get all the Sales Orders associated with this conract which have not synced to NS
            list<Sales_Order__c> soList = new list<Sales_Order__c>();
            soList = [select id, name, Order_Sub_Type__c, NS_Project__c from Sales_Order__c where Contract__c = :conId and NS_Sales_Order_Internal_Id__c = null];
            
            if(soList != null && soList.size() > 0){
                for(Sales_Order__c so : soList){
                    soTypeSet.add(so.Order_Sub_Type__c);
                    soIds.add(so.Id);
                    projIds.add(so.NS_Project__c);
                }
                delete soList;
            } else {
                return response = 'No Sales Orders on this Contract are available for delete';
            }
            
            //get all NS Customer Billig Schedules associated with the Projects
            if(projIds != null && projIds.size() > 0){
                list<NS_Customer_Billing_Schedule__c> cbsList = [select id, name from NS_Customer_Billing_Schedule__c where Project__c in :projIds];
                list<NS_Project__c> projList = [select id, name from NS_Project__c where id in :projIds];
                list<NS_Vendor_Billing_Schedule__c> vbsList = [select id, name from NS_Vendor_Billing_Schedule__c where NS_Project__c in :projIds ];

                if(cbsList != null && cbsList.size() > 0){
                    delete cbsList;
                }
                if(vbsList != null && vbsList.size() > 0){
                    delete vbsList;
                }
                if(projList != null && projList.size() > 0){
                    delete projList;
                }
                
            }
            if(contract.Misys_Opportunity__c != null){
                list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
                for(OpportunityLineItem oli : [Select Id, OpportunityId, SO_Grouping__c, Processed__c 
                    From OpportunityLineItem where Processed__c = true and OpportunityId = :contract.Misys_Opportunity__c]){
                        
                    if(oli.SO_Grouping__c.split('-').size() >= 2 && soTypeSet != null && soTypeSet.contains(oli.SO_Grouping__c.split('-')[1])){
                        oli.Processed__c = false;
                        oliList.add(oli);
                    }
                }
                if(oliList != null && oliList.size() > 0){
                    update oliList;
                }
            }
            
            response = 'Sales Orders Deleted Successfully';
        } catch(Exception ex) {
            response = 'Error Occured while deleting the package - ' + ex;
        }
        
        return response;
    }
}