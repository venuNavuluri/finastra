/*
	Created By: Abhinit Kohar
	Created Date: 30-09-2014
	Description: This is the helper class for NSRlfChangeOrderTrigger
*/
public class NSRlfChangeOrderMethods {
	
	//This method manages the NS Push Token on  NS RLF Change Order
	public static void updateNSPushToken(map<id, NS_RLF_Change_Order__c> oldMap, map<id, NS_RLF_Change_Order__c> newMap, list<NS_RLF_Change_Order__c> newList){
        map<Id, NS_RLF_Change_Order__c> coMap = new map<Id, NS_RLF_Change_Order__c>();
        map<Id, NS_RLF_Change_Order__c> coMap1 = new map<Id, NS_RLF_Change_Order__c>();

		Integer i = 0;
		for(NS_RLF_Change_Order__c changeOrder : newList){
            if(trigger.isBefore && trigger.isInsert){
                changeOrder.Pushed_to_NS__c = false;
                changeOrder.NS_Push_Token__c = false;
            }
            //this is for setting up the NS Push token
            if(trigger.isBefore && trigger.isUpdate && 
            		changeOrder.Ready_For_Export_To_NS__c == true && 
            		oldMap.get(changeOrder.Id).Ready_For_Export_To_NS__c == false &&
            		changeOrder.NS_Push_Token__c == false && changeOrder.Pushed_to_NS__c == false){
            	if(i == 0){
	                changeOrder.NS_Push_Token__c = true;
	                i++;
            	}		
            }
            if(trigger.isBefore && trigger.isUpdate && 
            		changeOrder.Ready_For_Export_To_NS__c == true && 
            		oldMap.get(changeOrder.Id).NS_Push_Token__c == false &&
            		changeOrder.NS_Push_Token__c == true){
            			
                coMap.put(changeOrder.Id, changeOrder);
            }
		}
        //this is for setting up the NS Push token
        if(trigger.isBefore && trigger.isUpdate && coMap != null && coMap.size() > 0){
        	list<NS_RLF_Change_Order__c> coList = [select id from NS_RLF_Change_Order__c where NS_Push_Token__c = true and id not in : coMap.keySet() limit 1];
        	if(coList != null && coList.size() > 0){
        		//coMap.values()[0].addError('There can only be one RLF Sales Order with NS Push Token as true');
        		for(NS_RLF_Change_Order__c co : coMap.values()){
        			co.NS_Push_Token__c = false;
        		}
        	}
        	system.debug('coMap = ' + coMap);
        }


        for(NS_RLF_Change_Order__c changeOrder1 : newList){
            if(trigger.isAfter && trigger.isUpdate && 
            		changeOrder1.Pushed_to_NS__c == true && oldMap.get(changeOrder1.Id).Pushed_to_NS__c == false &&
            		changeOrder1.NS_Push_Token__c == false){
            			
                coMap1.put(changeOrder1.Id, changeOrder1);
            }
        }

        //pass the NS Push Token to the next RLF Sales Order
        if(trigger.isAfter && trigger.isUpdate && coMap1 != null && coMap1.size() > 0){
        	list<NS_RLF_Change_Order__c> coList1 = [select id, NS_Push_Token__c from NS_RLF_Change_Order__c where NS_Push_Token__c = false 
        										and id not in : coMap1.keySet() and Ready_For_Export_To_NS__c = true and Pushed_to_NS__c = false limit 1];
        	system.debug('coMap1 = ' + coMap1);
        	system.debug('coList1 = ' + coList1);
        	if(coList1 != null && coList1.size() > 0){
        		coList1[0].NS_Push_Token__c = true;
        		update coList1[0];
        	}
        }
	}

}