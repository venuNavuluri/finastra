/**
* @File Name          : LeadTriggerHandler.cls
* @Description        : Lead Trigger Handler
* @Author             : Prity Sangwan
* @Group              : 
* @Last Modified By   : Prity Sangwan
* @Last Modified On   : 20/11/2019, 13:39:47
* @Modification Log   : 
* Ver       Date            Author              Modification
* 1.0    04/11/2019   Prity Sangwan     Initial Version
**/
public with sharing class LeadTriggerHandler extends TriggerHandler {
    
    protected override void afterUpdate() {
        Map<Id,Lead> newMap = (Map<Id,Lead>) Trigger.newMap;
        Map<Id,Lead> oldMap = (Map<Id,Lead>) Trigger.oldMap;
        
        //notify BDR/Sales upon lead conversion
        notifySalesWhenLeadConverted(newMap, oldMap);
    }

 /**
* @description RUBX-498 - BDR/Sales Users to be notified when a lead is converted
* @author Prity Sangwan| 02/12/2019 
* @param newList 
* @param oldMap 
* @return void 
**/   
    private void notifySalesWhenLeadConverted(Map<Id,Lead> newMap, Map<Id,Lead> oldMap) {

        Set<Id> convertedAccountIds = new Set<Id>();
        Set<Id> convertedContactIds = new Set<Id>();
        String chatterPost = System.Label.Notify_Sales_BDR_Lead_Converted;
        String chatterPostContact = System.Label.Lead_Converted_Contact;
        String chatterPostOpportunity = System.Label.Lead_Converted_Opportunity;
       
        Map<Id,Lead> leadMap = new Map<Id,Lead>([select Id, OwnerId,ConvertedAccountId,convertedcontactId,convertedOpportunityId from lead where Id IN :newMap.keyset()  and IsConverted = true   ]);
 
        for(Lead convertLead : newMap.values()) { 
            if(convertLead.status != oldMap.get(convertLead.Id).status && convertLead.IsConverted){
                if(convertLead.ConvertedOpportunityId != null){
                ConnectApiHelper.postFeedItemWithRichText(
                       Network.getNetworkId(), //community Id where to post, or "internal", or null
                       convertLead.OwnerId, //this is the record where the post will appear
                   '{' + convertLead.OwnerId + '}' +' '+ '<b>'+ chatterPost +'</b> '+'{'+ 'record:'+ convertLead.convertedaccountId + '}' +' '+'<p>'+'<b>'+ chatterPostContact +'</b>'+' '+'{'+ 'record:'+ convertLead.convertedcontactId + '}'+' '+'<b>'+ chatterPostOpportunity +'</b>'+' '+'{'+ 'record:'+ convertLead.convertedOpportunityId + '}'+'</p>' );
                  }
                else{
                    
                    ConnectApiHelper.postFeedItemWithRichText(
                       Network.getNetworkId(), //community Id where to post, or "internal", or null
                       convertLead.OwnerId, //this is the record where the post will appear
                   '{' + convertLead.OwnerId + '}' +' '+ '<b>'+ chatterPost +'</b> '+'{'+ 'record:'+ convertLead.convertedaccountId + '}' +' '+'<p>'+'<b>'+ chatterPostContact +'</b>'+' '+'{'+ 'record:'+ convertLead.convertedcontactId + '}'+'</p>' );
                  } 
                }
            }
        }
     }