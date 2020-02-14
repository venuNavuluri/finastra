/*
	Created By: Abhinit Kohar
	Created Date: 28/01/2014
	Description: This class holds the support methods for BillToShipToTrigger trigger.
*/
public class BillToShipToTriggerMethods {

    //This method updates the related NS Customer Addresses.
    public static void updateNSCustomerAddress(map<id, Bill_To_Ship_To__c> newMap, map<id, Bill_To_Ship_To__c> oldMap){
    	list<NS_Customer_Address__c> cusAddUpdateList = new list<NS_Customer_Address__c>();

    	for(NS_Customer_Address__c customerAddress : [select id, Address_1__c, Address_2__c, Address_3__c, Bill_To_Ship_To__c, Addressee__c, 
    								Attention__c, City__c, NS_Country__c, Default_Bill_To__c, Default_Ship_To__c, Postal_Zip_Code__c, 
    								County_State_Province__c, Billing_Contact__c
    								from NS_Customer_Address__c where Bill_To_Ship_To__c in : newMap.keySet()]){
    		boolean flag = false;
    		if(newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Street_1__c != oldMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Street_1__c){
    			flag = true;
    			customerAddress.Address_1__c = newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Street_1__c;
    		}
    		if(newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Street_2__c != oldMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Street_2__c){
    			flag = true;
    			customerAddress.Address_2__c = newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Street_2__c;
    		}
    		if(newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Street_3__c != oldMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Street_3__c){
    			flag = true;
    			customerAddress.Address_3__c = newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Street_3__c;
    		}
    		if(newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Name__c != oldMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Name__c){
    			flag = true;
    			customerAddress.Addressee__c = newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Name__c;
    		}
    		if(newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Attention__c != oldMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Attention__c){
    			flag = true;
    			customerAddress.Attention__c = newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Attention__c;
    		}
    		if(newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_City__c != oldMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_City__c){
    			flag = true;
    			customerAddress.City__c = newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_City__c;
    		}
    		if(newMap.get(customerAddress.Bill_To_Ship_To__c).NS_Country__c != oldMap.get(customerAddress.Bill_To_Ship_To__c).NS_Country__c){
    			flag = true;
    			customerAddress.NS_Country__c = newMap.get(customerAddress.Bill_To_Ship_To__c).NS_Country__c;
    		}
    		if(newMap.get(customerAddress.Bill_To_Ship_To__c).Default_Billing__c != oldMap.get(customerAddress.Bill_To_Ship_To__c).Default_Billing__c){
    			flag = true;
    			customerAddress.Default_Bill_To__c = newMap.get(customerAddress.Bill_To_Ship_To__c).Default_Billing__c;
    		}
    		if(newMap.get(customerAddress.Bill_To_Ship_To__c).Default_Shipping__c != oldMap.get(customerAddress.Bill_To_Ship_To__c).Default_Shipping__c){
    			flag = true;
    			customerAddress.Default_Ship_To__c = newMap.get(customerAddress.Bill_To_Ship_To__c).Default_Shipping__c;
    		}
    		if(newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Zip_Postal_Code__c != oldMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Zip_Postal_Code__c){
    			flag = true;
    			customerAddress.Postal_Zip_Code__c = newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_Zip_Postal_Code__c;
    		}
    		if(newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_State_Province__c != oldMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_State_Province__c){
    			flag = true;
    			customerAddress.County_State_Province__c = newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_To_State_Province__c;
    		}
    		if(newMap.get(customerAddress.Bill_To_Ship_To__c).Phone__c != oldMap.get(customerAddress.Bill_To_Ship_To__c).Phone__c){
    			flag = true;
    			customerAddress.Phone__c = newMap.get(customerAddress.Bill_To_Ship_To__c).Phone__c;
    		}
    		if(newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_to_Contact__c != oldMap.get(customerAddress.Bill_To_Ship_To__c).Bill_to_Contact__c){
    			flag = true;
    			customerAddress.Billing_Contact__c = newMap.get(customerAddress.Bill_To_Ship_To__c).Bill_to_Contact__c;
    		}
    		
    		if(flag == true){
    			customerAddress.Synced_To_NS__c = false;
    			customerAddress.Synced_To_Extra_NS__c = false;
    			cusAddUpdateList.add(customerAddress);
    		}
    	}
    	
    	if(cusAddUpdateList != null && cusAddUpdateList.size() > 0){
    		system.debug('cusAddUpdateList = ' + cusAddUpdateList);
    		update cusAddUpdateList;
    	}
    }

    //This method deletes the related NS Customer Addresses.
    public static void delteNSCustomerAddress(map<id, Bill_To_Ship_To__c> oldMap){
    	system.debug('delteNSCustomerAddress 1 = ' + oldMap);
    	list<NS_Customer_Address__c> cusAddDeleteList = [select id from NS_Customer_Address__c where Bill_To_Ship_To__c in : oldMap.keySet()];
		system.debug('delteNSCustomerAddress 2 = ' + cusAddDeleteList);
    	if(cusAddDeleteList != null && cusAddDeleteList.size() > 0){
    		delete cusAddDeleteList;
    	}
    }

    //This method creates the related NS Customer Addresses if the newly created Bill To/Installation's account is associated with Acct By Subs.
    public static void createNSCustomerAddress(map<id, Bill_To_Ship_To__c> newMap){
		map<id, list<Bill_To_Ship_To__c>> accIdBillToShipToMap = new map<id, list<Bill_To_Ship_To__c>>();
		list<Bill_To_Ship_To__c> billToShipToList;
		list<NS_Customer_Address__c> customerAddList = new list<NS_Customer_Address__c>();
		set<id> accountIds = new set<id>();
		map<id, id> accBySubAccountIdMap = new map<id, id>();
		
		for(Bill_To_Ship_To__c btst : newMap.values()){
			if(btst.Account__c != null){
				accountIds.add(btst.Account__c);
			}
			if(accIdBillToShipToMap.containsKey(btst.Account__c)) {
				billToShipToList = accIdBillToShipToMap.get(btst.Account__c);
				billToShipToList.add(btst);
			} else {
				billToShipToList = new list<Bill_To_Ship_To__c>();
				billToShipToList.add(btst);
				accIdBillToShipToMap.put(btst.Account__c, billToShipToList);
			}
		}
		
		if(accountIds != null && accountIds.size() > 0){
			for(Acct_By_Sub__c accBySub : [select id, Account__c from Acct_By_Sub__c where Account__c in : accountIds]){
				accBySubAccountIdMap.put(accBySub.Id, accBySub.Account__c);
			}
		}
		
		for(Id accBySubId : accBySubAccountIdMap.keySet()){
			system.debug('AccBySubTriggerMethods 8 = ' + accBySubId);
			if(accIdBillToShipToMap != null && accIdBillToShipToMap.containsKey(accBySubAccountIdMap.get(accBySubId))){
				for(Bill_To_Ship_To__c btst : accIdBillToShipToMap.get(accBySubAccountIdMap.get(accBySubId))){
					system.debug('AccBySubTriggerMethods 9 = ' + btst);
					NS_Customer_Address__c customerAdd = new NS_Customer_Address__c();
					customerAdd.Acct_By_Sub__c = accBySubId;
					customerAdd.Bill_To_Ship_To__c = btst.Id;
					customerAdd.Address_1__c = btst.Bill_To_Street_1__c;
					customerAdd.Address_2__c = btst.Bill_To_Street_2__c;
					customerAdd.Address_3__c = btst.Bill_To_Street_3__c;
					customerAdd.Addressee__c = btst.Bill_To_Name__c;
					customerAdd.Attention__c = btst.Bill_To_Attention__c;
					customerAdd.City__c = btst.Bill_To_City__c;
					customerAdd.NS_Country__c = btst.NS_Country__c;
					customerAdd.Default_Bill_To__c = btst.Default_Billing__c;
					customerAdd.Default_Ship_To__c = btst.Default_Shipping__c;
					customerAdd.Postal_Zip_Code__c = btst.Bill_To_Zip_Postal_Code__c;
					customerAdd.County_State_Province__c = btst.Bill_To_State_Province__c;
					customerAdd.Phone__c = btst.Phone__c;
					customerAddList.add(customerAdd);
				}
			}
		}
		
		if(customerAddList != null && customerAddList.size() > 0){
			system.debug('AccBySubTriggerMethods 10 = ' + customerAddList);
			insert customerAddList;
		}
    }
}