public class BillingGroupTriggerMethods {
	
	public static void updateCustomerAddress(list<Billing_Group__c> bgList){
		set<Id> billToShipToIds = new set<Id>();
		set<Id> accBySubIds = new set<Id>();
		
		for(Billing_Group__c bg : bgList){
			if(bg.BG_Client_Ship_To__c != null){
				billToShipToIds.add(bg.BG_Client_Ship_To__c);
			}
			if(bg.BG_Client_Bill_To__c != null){
				billToShipToIds.add(bg.BG_Client_Bill_To__c);
			}
			if(bg.Account_by_Sub__c != null){
				accBySubIds.add(bg.Account_by_Sub__c);
			}
		}
		system.debug('billToShipToIds = ' + billToShipToIds);
		system.debug('accBySubIds = ' + accBySubIds);
		
		map<Id, list<NS_Customer_Address__c>> btNCAMap = new map<Id, list<NS_Customer_Address__c>>();
		list<NS_Customer_Address__c> ncaList;
		for(NS_Customer_Address__c nca : [select id, Bill_To_Ship_To__c, Acct_By_Sub__c from NS_Customer_Address__c where Bill_To_Ship_To__c in :billToShipToIds and Acct_By_Sub__c in :accBySubIds]){
			if(btNCAMap.containsKey(nca.Bill_To_Ship_To__c)){
				ncaList = btNCAMap.get(nca.Bill_To_Ship_To__c);
				ncaList.add(nca);
			} else {
				ncaList = new list<NS_Customer_Address__c>();
				ncaList.add(nca);
				btNCAMap.put(nca.Bill_To_Ship_To__c, ncaList);
			}
		}
		system.debug('btNCAMap = ' + btNCAMap);
		for(Billing_Group__c bg1 : bgList){
			if(bg1.BG_Client_Ship_To__c != null){
				if(btNCAMap.containsKey(bg1.BG_Client_Ship_To__c)){
					for(NS_Customer_Address__c custAdd : btNCAMap.get(bg1.BG_Client_Ship_To__c)){
						if(custAdd.Acct_By_Sub__c == bg1.Account_by_Sub__c){
							bg1.NS_Customer_Ship_To_Address__c = custAdd.Id;
							break;
						}
					}
				}
			} else {
				bg1.NS_Customer_Ship_To_Address__c = null;
			}
			if(bg1.BG_Client_Bill_To__c != null){
				if(btNCAMap.containsKey(bg1.BG_Client_Bill_To__c)){
					for(NS_Customer_Address__c custAdd : btNCAMap.get(bg1.BG_Client_Bill_To__c)){
						if(custAdd.Acct_By_Sub__c == bg1.Account_by_Sub__c){
							bg1.NS_Customer_Address__c = custAdd.Id;
							break;
						}
					}
				}
			} else {
				bg1.NS_Customer_Address__c = null;
			}
		}
		
	}
}