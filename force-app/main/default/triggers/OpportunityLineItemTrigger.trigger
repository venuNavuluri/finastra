trigger OpportunityLineItemTrigger on OpportunityLineItem (before delete, before insert, before update, after update, after delete, after insert) {


    if(Trigger.IsDelete)
    {
        if(Trigger.isBefore)
        {
            //Prevent the deletion of line items that have been inserted via Pearl
            OpportunityLineItemServices.preventDeletePearlOLI(Trigger.old);

            //If a line item is deleted from a Change Request opportunity, it needs to be deleted from the parent opportunity as well.
            list<OpportunityLineItem> delOLIs = new list<OpportunityLineItem>();
            for(OpportunityLineItem o : trigger.old){
                if(o.opportunity.recordtypeid == Label.RecType_Opportunity_ChangeReq)
                {
                    delOLIs.add(o);
                }
            }
            //G.B update: pass trigger.old as parameter
            //OpportunityServices.deleteChangeOrderOLIsOnParentOpportunity(delOLIs);
            OpportunityServices.deleteChangeOrderOLIsOnParentOpportunity(trigger.old);

        }
    }



    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        //get the cost centers and create a map of internal Id and cost centre
        map<string, NS_Cost_Centre__c> costCentreMap = new map<string, NS_Cost_Centre__c>();
        
        for(NS_Cost_Centre__c costCentre :  [select id, NS_Cost_Centre_Internal_Id__c from NS_Cost_Centre__c where Is_Inactive__c = false]){
            costCentreMap.put(costCentre.NS_Cost_Centre_Internal_Id__c, costCentre);
        }
        for(OpportunityLineItem oppLineItem : trigger.new){
            if(oppLineItem.NS_Item_Cost_Centre_Override_Internal_Id__c != null && costCentreMap != null && costCentreMap.containsKey(oppLineItem.NS_Item_Cost_Centre_Override_Internal_Id__c)){
                oppLineItem.PS_Cost_Centre__c = costCentreMap.get(oppLineItem.NS_Item_Cost_Centre_Override_Internal_Id__c).Id;
            }            
        }     
        
    }



    // Subscription rollups
    if((Trigger.isAfter && trigger.isDelete) || (Trigger.isAfter && trigger.isInsert)  ||(Trigger.isAfter && trigger.isUpdate ) ){

        set<id> oppsExcludeFromVRSet = new set<id>();
        set<id> oppsRemoveSet = new set<id>();
        set<id> opplinesRemoveSet = new set<id>();
        Set<ID> oppIdSet = new Set<ID>();
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        List<OpportunityLineItem>  oliList;
        if(trigger.isDelete) {
            oliList = Trigger.old;
        }
        else {
            oliList = Trigger.new;
        }

        for(OpportunityLineItem oppLineItem : oliList )
        {
            oppIdSet.add(oppLineItem.OpportunityID);

            if (!(trigger.isDelete) && oppLineItem.Product2Id != null){
                //RBX-478
                oppsExcludeFromVRSet.add(oppLineItem.id);
            }
            else if (trigger.isDelete && oppLineItem.Product2Id != null){
                //RBX-478
                oppsRemoveSet.add(oppLineItem.OpportunityId);
                opplinesRemoveSet.add(oppLineItem.id);
            }
        }

        //allow GP products to be added even after an Opp is Pearl mastered RBX-477    
        //If a misys product is added and Exclude_from_VRs__c = true reset to false   
        if (trigger.isInsert){
            Map<id,OpportunityLineItem> gpOplines = new Map<id,OpportunityLineItem>([select id, OpportunityId, Opportunity.Exclude_from_VRs__c, Opportunity.Is_PearlMastered__c, Product2.GP_Product__c From OpportunityLineItem where Id In:trigger.new]);
            
            String prof = [Select Profile.Name From User where Id=:Userinfo.getUserId()].Profile.Name;
            set<id> updOppsSet = new set<id>();
            for(OpportunityLineItem oppLineItem : trigger.new){
                OpportunityLineItem oppline = gpOplines.get(oppLineItem.id);
                if (gpOplines.containskey(oppLineItem.id) && oppline.Opportunity.Is_PearlMastered__c && !oppline.Product2.GP_Product__c && !prof.contains('PS') && prof != 'System Administrator'){//a misys product
                    oppLineItem.addError('You cannot manually add misys products, please use Pearl to push your proposal to the Opportunity');
                }
                else if (gpOplines.containskey(oppLineItem.id) && !oppline.Opportunity.Is_PearlMastered__c && !oppline.Product2.GP_Product__c && oppline.Opportunity.Exclude_from_VRs__c){
                    updOppsSet.add(oppline.OpportunityId); //misys product added
                }
            }
            
            if (!updOppsSet.isempty()){
                //If a misys product is added and Exclude_from_VRs__c = true reset to false
                Opportunity[] updOpps = [Select Exclude_from_VRs__c From Opportunity where Id In:updOppsSet];
                for (Opportunity op : updOpps){
                    op.Exclude_from_VRs__c = false;
                }
                update updOpps;
            }
        }

        if (!oppsExcludeFromVRSet.isempty()){
            //RBX-478
            UtilInvocableMethods.processExcludeOppValidationRule(oppsExcludeFromVRSet);
        }

        if (!oppsRemoveSet.isempty()){
            //RBX-478
            UtilInvocableMethods.processIncludeOppValidationRule(oppsRemoveSet, opplinesRemoveSet, Trigger.old);
        }

        if(oppIdSet!=null && oppIdSet.size()>0)
        {
            oppToUpdate = OpportunityLineItemServices.getOppsWithRolledUpCommValues(oppIdSet);
            doSubRollUps(oppIdSet);
        }



        if(!oppToUpdate.isEmpty())
            update oppToUpdate;

    }




    if(trigger.isAfter && trigger.isUpdate){
        set<Id> obsIds = new set<Id>();
        for(OpportunityLineItem oppLineItem : trigger.new){
            if(oppLineItem.IsBGLlinked__c == true && trigger.oldMap.get(oppLineItem.Id).IsBGLlinked__c == false && oppLineItem.Opportunity_Billing_Schedule__c != null){
                obsIds.add(oppLineItem.Opportunity_Billing_Schedule__c);
            }
        }
        if(obsIds != null && obsIds.size() > 0){
            OpportunityLineItemServices.updateOBS(obsIds);
        }

    }

// WE will move this to a helper class once we refactor the other rollup code since we may do away with a  existing helper class(es) for rollup.
    // this should be refactored, so the dmls are not performed 3 times
    private void doSubRollUps(Set<ID> oppIdSet )
    {
        List<String> prod_fly_List = new List<String>{'SUB%','HOS%','CLD%'};
        Map<Id,Opportunity> oppMapToUpdate = new Map<Id,Opportunity>();

        for (String prod_fly :prod_fly_List )
        {
            Map<Id,Opportunity> oppMap = new Map<ID,opportunity>( [Select Id,tcv_hos__c,tcv_sub__c,tcv_cld__c,CommValue_HOS__c,CommValue_SUB__c,CommValue_CLD__c,currencyisocode  from opportunity where  Id in :oppIdSet ]);
            AggregateResult[] groupedResult = [select  opportunityid ,sum(Sold_Value__c) sumPriceSoldValue, sum(Commissionable_Value__c) sumPriceCommValue from opportunityLineItem where opportunityid in :oppIdSet and Prod_Fly__c like :prod_fly group by opportunityid ];
            Set<ID> optyIDSet =  oppMap.KeySet();

            Map<string,double> currencyCodeMap = new Map<string,double>();

            if(!groupedResult.isEmpty()) {
                List<currencytype > currencyCodeList = [SELECT isocode,conversionrate FROM currencytype];

                for (currencytype cc : currencyCodeList) {
                    currencyCodeMap.put(cc.isocode, cc.conversionrate);
                }
            }
            for(AggregateResult ar : groupedResult )
            {

                Decimal sumPriceSoldValue = 0;
                Decimal sumPriceCommValue = 0;

                if((Decimal)ar.get('sumPriceSoldValue')!=null)
                    sumPriceSoldValue = (Decimal)ar.get('sumPriceSoldValue');

                if((Decimal)ar.get('sumPriceCommValue')!=null)
                    sumPriceCommValue = (Decimal)ar.get('sumPriceCommValue');


                Opportunity opty = oppMap.get((ID)ar.get('opportunityid'));
                if(prod_fly == 'HOS%')
                {
                    if(oppMapToUpdate.get(opty.id)!=null)
                    {
                        oppMapToUpdate.get(opty.id).tcv_hos__c =  currencyCodeMap.get(opty.currencyisocode)*sumPriceSoldValue;

                        oppMapToUpdate.get(opty.id).CommValue_HOS__c = currencyCodeMap.get(opty.currencyisocode)*sumPriceCommValue;
                    }
                    else
                    {
                        opty.tcv_hos__c =  currencyCodeMap.get(opty.currencyisocode)*sumPriceSoldValue;
                        opty.CommValue_HOS__c = currencyCodeMap.get(opty.currencyisocode)*sumPriceCommValue;
                        oppMapToUpdate.put(opty.id,opty);
                    }
                }
                else if (prod_fly == 'SUB%')
                {
                    if(oppMapToUpdate.get(opty.id)!=null)
                    {
                        oppMapToUpdate.get(opty.id).tcv_sub__c =  currencyCodeMap.get(opty.currencyisocode)*sumPriceSoldValue;
                        oppMapToUpdate.get(opty.id).CommValue_SUB__c = currencyCodeMap.get(opty.currencyisocode)*sumPriceCommValue;
                    }
                    else
                    {
                        opty.tcv_sub__c =  currencyCodeMap.get(opty.currencyisocode)*sumPriceSoldValue;
                        opty.CommValue_SUB__c = currencyCodeMap.get(opty.currencyisocode)*sumPriceCommValue;
                        oppMapToUpdate.put(opty.id,opty);
                    }
                }
                else if (prod_fly == 'CLD%')
                {
                    if(oppMapToUpdate.get(opty.id)!=null)
                    {
                        oppMapToUpdate.get(opty.id).tcv_cld__c =  currencyCodeMap.get(opty.currencyisocode)*sumPriceSoldValue;
                        oppMapToUpdate.get(opty.id).CommValue_CLD__c = currencyCodeMap.get(opty.currencyisocode)*sumPriceCommValue;
                    }
                    else
                    {
                        opty.tcv_cld__c =  currencyCodeMap.get(opty.currencyisocode)*sumPriceSoldValue;
                        opty.CommValue_CLD__c = currencyCodeMap.get(opty.currencyisocode)*(sumPriceCommValue);
                        oppMapToUpdate.put(opty.id,opty);
                    }
                }

                // remove from oppMap
                optyIDSet.remove((ID)ar.get('opportunityid'));
            }
            //if no OLI has the given product family (HOs, SUB, CLD etc) then set the value to 0

            for(ID optyId: optyIDSet)
            {
                Opportunity opty = oppMap.get(optyId);

                if(prod_fly == 'HOS%')
                {
                    if(oppMapToUpdate.get(opty.id)!=null)
                    {
                        oppMapToUpdate.get(opty.id).tcv_hos__c =  0;
                        oppMapToUpdate.get(opty.id).CommValue_HOS__c = 0;
                    }
                    else
                    {
                        if(opty.tcv_hos__c != 0 || opty.CommValue_HOS__c != 0) {
                            opty.tcv_hos__c = 0;
                            opty.CommValue_HOS__c = 0;
                            oppMapToUpdate.put(opty.id, opty);
                        }
                    }
                }
                else if (prod_fly == 'SUB%')
                {
                    if(oppMapToUpdate.get(opty.id)!=null)
                    {
                        oppMapToUpdate.get(opty.id).tcv_sub__c =  0;
                        oppMapToUpdate.get(opty.id).CommValue_SUB__c = 0;
                    }
                    else
                    {
                        if(opty.tcv_sub__c != 0 || opty.CommValue_SUB__c != 0) {
                            opty.tcv_sub__c = 0;
                            opty.CommValue_SUB__c = 0;
                            oppMapToUpdate.put(opty.id, opty);
                        }
                    }
                }
                else if (prod_fly == 'CLD%')
                {


                    if(oppMapToUpdate.get(opty.id)!=null)
                    {
                        oppMapToUpdate.get(opty.id).tcv_cld__c =  0;
                        oppMapToUpdate.get(opty.id).CommValue_CLD__c = 0;
                    }
                    else
                    {
                        if(opty.tcv_cld__c != 0 || opty.CommValue_CLD__c != 0) {
                            opty.tcv_cld__c = 0;
                            opty.CommValue_CLD__c = 0;
                            oppMapToUpdate.put(opty.id, opty);
                        }
                    }
                }
            }

        } // prd fly for loop close
        update oppMapToUpdate.values();



    } // rollup close
}

// Test
// OpportunityLineItem oli = new OpportunityLineItem (OpportunityID = '0062000000kKHmc', Sold_Value__c=10, Commissionable_Value__c = 10,  PricebookEntryID= '01u2000000T9kKRAAZ' ,Quantity =1, TotalPrice = 1);