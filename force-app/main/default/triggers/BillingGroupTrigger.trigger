/**
 * @File Name          : BillingGroupTrigger.trigger
 * @Description        : 
 * @Author             : venu.navuluri@finastra.com
 * @Group              : 
 * @Last Modified By   : venu.navuluri@finastra.com
 * @Last Modified On   : 2/6/2019, 9:50:12 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    2/6/2019, 9:50:12 AM   venu.navuluri@finastra.com     Initial Version
**/
trigger BillingGroupTrigger on Billing_Group__c (after delete, after insert, after undelete, after update, before insert, before update)
{
    if(trigger.isAfter && ( trigger.isInsert || trigger.isUndelete || trigger.isUpdate)){            
        for(Billing_Group__c bg : trigger.new){
            if(!bg.Created_by_CPQ_process__c && bg.DM_Unique_Id__c == null && bg.Next_SO_generation_Date__c == null){
                RUMBillingGroupToBillingEntity rumBg2Be = new RUMBillingGroupToBillingEntity(trigger.isDelete ? trigger.old : trigger.new, trigger.oldMap);
                rumBg2Be.DoRollUp(); 
            }
        }
        
    }
    if(trigger.isAfter && trigger.isDelete){
        RUMBillingGroupToBillingEntity rumBg2Be = new RUMBillingGroupToBillingEntity(trigger.isDelete ? trigger.old : trigger.new, trigger.oldMap);
        rumBg2Be.DoRollUp(); 
    }
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        if(trigger.isInsert){
            BillingGroupTriggerMethods.updateCustomerAddress(trigger.new);                
        }
        if(trigger.isUpdate){             
            set<Billing_Group__c> bgList = new set<Billing_Group__c>();
            for(Billing_Group__c bg : trigger.new){
                if(bg.BG_Client_Ship_To__c != trigger.oldMap.get(bg.Id).BG_Client_Ship_To__c){
                    bgList.add(bg);
                }
                if(bg.BG_Client_Bill_To__c != trigger.oldMap.get(bg.Id).BG_Client_Ship_To__c){
                    bgList.add(bg);
                }
            }
            if(bgList != null && bgList.size() > 0){
                BillingGroupTriggerMethods.updateCustomerAddress(new list<Billing_Group__c>(bgList));
            }            
        }
    }   
}