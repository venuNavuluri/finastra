public class OpportunityLineItemServices {
    

    public static void preventDeletePearlOLI(List<OpportunityLineItem> lOppLineItems)
    {
        //Prevent a user from deleting an opportunity line item if originally from Pearl
        system.debug('OLIServices.preventDeletePearlOLI - lOppLineItems:'+lOppLineItems);
        
        //Get the current user and check if in the public group for line item edit ability
        Id currentUserId = UserInfo.getUserId();
        //Id groupId = Label.OppLineItemEditGroup;
        
        Set<Id> oliEditAccess = new Set<id>();
        if(Label.OppLineItemEditGroup != null && Label.OppLineItemEditGroup !=''){
            oliEditAccess = CommonFunctions.getUsersFromGroup(Label.OppLineItemEditGroup);
        }
        system.debug('OLIServices.preventDeletePearlOLI - oliEditAccess Group members:'+oliEditAccess);
        
        //If the current user is not in the group and should not have access, continue and block the delete
        //if(oliEditAccess.size() > 0 && !oliEditAccess.contains(currentUserId))
        if(!oliEditAccess.contains(currentUserId) && GlobalVar.bSystemAllowOppLineItemDelete == false)
        {
            //Get a list of the Opp line items that originated from Pearl
            List<OpportunityLineItem> oliPearl = new List<OpportunityLineItem>();       
            for(OpportunityLineItem o : lOppLineItems)
            {
                //if(o.PPOPPLINE_Concat__c != null && o.PPOPPLINE_Concat__c != '')
                if(o.Pearl_Item__c == true)
                {
                    oliPearl.add(o);
                    system.debug('OLIServices.preventDeletePearlOLI - added line item '+o);
                }               
            }
            
            for(OpportunityLineItem oPearl : oliPearl)
            {
                oPearl.addError(Label.OppLineItemEdit_PreventDelete_Message);
            }
        }
    } 

    public static void updateOBS(set<Id> obsIds){
        map<id, list<OpportunityLineItem>> obsIdOlisMap = new map<id, list<OpportunityLineItem>>();
        list<OpportunityLineItem> oliList;
        list<Opportunity_Billing_Schedule__c> obsUpdateList = new list<Opportunity_Billing_Schedule__c>();
        for(OpportunityLineItem oli : [select id, Opportunity_Billing_Schedule__c, IsBGLlinked__c, IsRLFAssetised__c 
                                        from OpportunityLineItem where Opportunity_Billing_Schedule__c in :obsIds]){
                                            
            if(obsIdOlisMap.containsKey(oli.Opportunity_Billing_Schedule__c)){
                oliList = obsIdOlisMap.get(oli.Opportunity_Billing_Schedule__c);
                oliList.add(oli);
            } else {
                oliList = new list<OpportunityLineItem>();
                oliList.add(oli);
                obsIdOlisMap.put(oli.Opportunity_Billing_Schedule__c, oliList);
            }
        }
        system.debug('obsIdOlisMap = ' + obsIdOlisMap);
        
        for(Id obsId : obsIds){
            if(obsIdOlisMap.containsKey(obsId)){
                integer i = 0;
                list<OpportunityLineItem> oppLineItemList = obsIdOlisMap.get(obsId);
                if(oppLineItemList != null && oppLineItemList.size() > 0){
                    integer listSize = oppLineItemList.size();
                    for(OpportunityLineItem oppLineItem : oppLineItemList){
                        if(oppLineItem.IsBGLlinked__c == true && oppLineItem.IsRLFAssetised__c == true){
                            i++;
                        }
                    }
                    system.debug('i = ' + i);
                    system.debug('listSize = ' + listSize);
                    if(i == listSize){
                        obsUpdateList.add(new Opportunity_Billing_Schedule__c(Id = obsId, IsBGProcessed__c = true));
                    }
                }
            }
        }
        
        if(obsUpdateList != null && obsUpdateList.size() > 0){
            system.debug('obsUpdateList + ' + obsUpdateList);
            update obsUpdateList;
        }
    }
    
    
    
    public static List<Opportunity> getOppsWithRolledUpCommValues(Set<Id> oppSetId){
        system.debug('======> getOppsWithRolledUpCommValues oppSetId:'+oppSetId);
        boolean isChanged = false;
        List<Opportunity> changedOpps = new List<Opportunity>();
        Map<Id,Opportunity> map_Opportunity = new Map<Id,Opportunity>([Select Id,RSF_HOS_IM_CommValue__c,RSF_CLD_CB_CommValue__c,RSF_CLD_CL_CommValue__c,
                                                                   RSF_CLD_CM_CommValue__c,RSF_CLD_ER_CommValue__c,RSF_CLD_IM_CommValue__c,RSF_CLD_TB_CommValue__c,
                                                                   RSF_HOS_CB_CommValue__c,RSF_HOS_CL_CommValue__c,RSF_HOS_CM_CommValue__c,RSF_HOS_TB_CommValue__c,
                                                                   RSF_HOS_ER_CommValue__c,RSF_SUB_CB_CommValue__c,RSF_SUB_CL_CommValue__c,RSF_SUB_CM_CommValue__c,RSF_SUB_ER_CommValue__c,
                                                                   RSF_SUB_IM_CommValue__c,RSF_SUB_TB_CommValue__c,(Select Id,Product_Family__c,Custom_Commision_Value__c from OpportunityLineItems) 
                                                                   from Opportunity where Id IN:oppSetId]);
                                                                   
        if(map_Opportunity!=null && map_Opportunity.values()!=null){
            for(Opportunity oppRecord : map_Opportunity.values()) {

                Double CommValueHOSTB = 0;
                Double CommValueHOSIM = 0;
                Double CommValueCLDCB = 0;
                Double CommValueCLDCM = 0;
                Double CommValueCLDER = 0;
                Double CommValueCLDIM = 0;
                Double CommValueCLDTB = 0;
                Double CommValueCLDCL = 0;
                Double CommValueHOSCB = 0;
                Double CommValueHOSCL = 0;
                Double CommValueHOSCM = 0;
                Double CommValueHOSER = 0;
                Double CommValueSUBCB = 0;
                Double CommValueSUBCL = 0;
                Double CommValueSUBCM = 0;
                Double CommValueSUBER = 0;
                Double CommValueSUBIM = 0;
                Double CommValueSUBTB = 0;

                if (oppRecord != null && oppRecord.OpportunityLineItems != null) {

                    for (OpportunityLineItem oppLineItem : oppRecord.OpportunityLineItems) {
                        if (oppLineItem.Product_Family__c == 'HOS (TB)') {
                            CommValueHOSTB += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'HOS (IM)') {
                            CommValueHOSIM += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'CLD (CB)') {
                            CommValueCLDCB += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'CLD (CL)') {
                            CommValueCLDCL += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'CLD (CM)') {
                            CommValueCLDCM += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'CLD (ER)') {
                            CommValueCLDER += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'CLD (IM)') {
                            CommValueCLDIM += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'CLD (TB)') {
                            CommValueCLDTB += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'HOS (CB)') {
                            CommValueHOSCB += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'HOS (CL)') {
                            CommValueHOSCL += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'HOS (CM)') {
                            CommValueHOSCM += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'HOS (ER)') {
                            CommValueHOSER += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'SUB (CB)') {
                            CommValueSUBCB += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'SUB (CL)') {
                            CommValueSUBCL += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'SUB (CM)') {
                            CommValueSUBCM += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'SUB (ER)') {
                            CommValueSUBER += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'SUB (IM)') {
                            CommValueSUBIM += oppLineItem.Custom_Commision_Value__c;
                        }
                        if (oppLineItem.Product_Family__c == 'SUB (TB)') {
                            CommValueSUBTB += oppLineItem.Custom_Commision_Value__c;
                        }
                    }

                    if (oppRecord.RSF_HOS_TB_CommValue__c != CommValueHOSTB) {
                        oppRecord.RSF_HOS_TB_CommValue__c = CommValueHOSTB;
                        isChanged = true;
                    }
                    if (oppRecord.RSF_HOS_IM_CommValue__c != CommValueHOSIM) {
                        oppRecord.RSF_HOS_IM_CommValue__c = CommValueHOSIM;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_CLD_CB_CommValue__c != CommValueCLDCB) {
                        oppRecord.RSF_CLD_CB_CommValue__c = CommValueCLDCB;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_CLD_CL_CommValue__c != CommValueCLDCL) {
                        oppRecord.RSF_CLD_CL_CommValue__c = CommValueCLDCL;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_CLD_CM_CommValue__c != CommValueCLDCM) {
                        oppRecord.RSF_CLD_CM_CommValue__c = CommValueCLDCM;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_CLD_ER_CommValue__c != CommValueCLDER) {
                        oppRecord.RSF_CLD_ER_CommValue__c = CommValueCLDER;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_CLD_IM_CommValue__c != CommValueCLDIM) {
                        oppRecord.RSF_CLD_IM_CommValue__c = CommValueCLDIM;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_CLD_TB_CommValue__c != CommValueCLDTB) {
                        oppRecord.RSF_CLD_TB_CommValue__c = CommValueCLDTB;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_HOS_CB_CommValue__c != CommValueHOSCB) {
                        oppRecord.RSF_HOS_CB_CommValue__c = CommValueHOSCB;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_HOS_CL_CommValue__c != CommValueHOSCL) {
                        oppRecord.RSF_HOS_CL_CommValue__c = CommValueHOSCL;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_HOS_CM_CommValue__c != CommValueHOSCM) {
                        oppRecord.RSF_HOS_CM_CommValue__c = CommValueHOSCM;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_HOS_ER_CommValue__c != CommValueHOSER) {
                        oppRecord.RSF_HOS_ER_CommValue__c = CommValueHOSER;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_SUB_CB_CommValue__c != CommValueSUBCB) {
                        oppRecord.RSF_SUB_CB_CommValue__c = CommValueSUBCB;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_SUB_CL_CommValue__c != CommValueSUBCL) {
                        oppRecord.RSF_SUB_CL_CommValue__c = CommValueSUBCL;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_SUB_CM_CommValue__c != CommValueSUBCM) {
                        oppRecord.RSF_SUB_CM_CommValue__c = CommValueSUBCM;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_SUB_ER_CommValue__c != CommValueSUBER) {
                        oppRecord.RSF_SUB_ER_CommValue__c = CommValueSUBER;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_SUB_IM_CommValue__c != CommValueSUBIM) {
                        oppRecord.RSF_SUB_IM_CommValue__c = CommValueSUBIM;
                        isChanged = true;
                    }

                    if (oppRecord.RSF_SUB_TB_CommValue__c != CommValueSUBTB) {
                        oppRecord.RSF_SUB_TB_CommValue__c = CommValueSUBTB;
                        isChanged = true;
                    }
					system.debug('======> getOppsWithRolledUpCommValues isChanged:'+isChanged);
                    if (isChanged){
                        changedOpps.add(oppRecord);
                    }
                }
            }
        }
        system.debug('======> getOppsWithRolledUpCommValues changedOpps:'+changedOpps);
        return changedOpps;
    }

}