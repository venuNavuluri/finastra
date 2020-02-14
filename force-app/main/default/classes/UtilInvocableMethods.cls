public with sharing class UtilInvocableMethods {

  public static void processExcludeOppValidationRule(set<Id> oppLineIds) {
    //RBX-478 inserting or updating trigger
    try{
        OpportunityLineItem [] newOppLines = [Select Product2.GP_Product__c,OpportunityId,Pearl_Item__c From OpportunityLineItem where Id In :oppLineIds];
        system.debug('## newOppLines ' + newOppLines);
        set<id> opGPSet = new set<id>();
        set<id> opMSet = new set<id>();
        set<id> opAllSet = new set<id>();
        for (OpportunityLineItem oppline : newOppLines){
            if (oppline.Product2 != null){
                //GP Products
                if (oppline.Product2.GP_Product__c){
                    opGPSet.add(oppline.Opportunityid);
                }
                else if (!oppline.Product2.GP_Product__c && oppline.Pearl_Item__c){
                    //Misys Products
                    opMSet.add(oppline.Opportunityid);
                }
            }
        }
        
        opAllSet.addall(opGPSet);
        opAllSet.addall(opMSet);
        system.debug('## opGPSet ' + opGPSet);
        Opportunity [] opps = [Select Exclude_from_VRs__c From Opportunity where Id In :opAllSet];
        set<id> otherMisysOppLinesSet = new set<id>();
        set<id> otherGPOppLinesSet = new set<id>();

        if (!opGPSet.isempty()){
            //other misys products than those products being deleted
            OpportunityLineItem [] otherMisysOppLines = [Select OpportunityId, Opportunity.Is_PearlMastered__c From OpportunityLineItem where Opportunityid In :opGPSet and Product2.GP_Product__c=false and (Not (Id In :oppLineIds))];
            for (OpportunityLineItem oppline : otherMisysOppLines){
                if (!oppline.Opportunity.Is_PearlMastered__c) otherMisysOppLinesSet.add(oppline.Opportunityid);
            } 
        }

        if (!opMSet.isempty()){
            //other gp products than those products being deleted
            OpportunityLineItem [] otherGPOppLines = [Select OpportunityId From OpportunityLineItem where Opportunityid In :opMSet and Product2.GP_Product__c=true and (Not (Id In :oppLineIds))];
            for (OpportunityLineItem oppline : otherGPOppLines){
                otherGPOppLinesSet.add(oppline.Opportunityid);
            } 
        }

        system.debug('## opps' + opps);
        if (!opps.isempty()){
            for (Opportunity o : opps){
                if (opGPSet.contains(o.id)){
                    if (!otherMisysOppLinesSet.contains(o.id)) 
                        o.Exclude_from_VRs__c = true;
                    else
                        o.Exclude_from_VRs__c = false;
                }
                if (opMSet.contains(o.id)){
                    if (!otherGPOppLinesSet.contains(o.id)) 
                        o.Exclude_from_VRs__c = false;
                    else
                        o.Exclude_from_VRs__c = true;
                }
            }
            Database.update(opps,false);
        }
      }
      catch(Exception ex){}
  }

  public static void processIncludeOppValidationRule(set<Id> oppIds, set<Id> oppLineIds, OpportunityLineItem [] delLines) {
    //RBX-478 Deleting trigger
    //GP OpportunityLineItem that have not been deleted
        Set<ID> opAllSet = new Set<ID>();
          for (OpportunityLineItem oppline : delLines){
                  opAllSet.add(oppline.Opportunityid);
    }

    OpportunityLineItem [] currentOppLines = [Select Product2.GP_Product__c,OpportunityId From OpportunityLineItem where OpportunityId In :oppIds and  (Not(Id In :oppLineIds)) ];

    Set<ID> oppIdGPSet = new Set<ID>();
    Set<ID> oppIdMSet = new Set<ID>();
    if (!currentOppLines.isempty()){
        for (OpportunityLineItem oppline : currentOppLines){
            if (oppline.Product2.GP_Product__c){
                oppIdGPSet.add(oppline.Opportunityid);
            }
            else{
                oppIdMSet.add(oppline.Opportunityid);
            }    
        }

        Opportunity[] opps = [Select Exclude_from_VRs__c from Opportunity where Id In:opAllSet];
        if (!oppIdGPSet.isempty()){
            for (Opportunity o : opps)
                if (oppIdGPSet.contains(o.id)) o.Exclude_from_VRs__c = true;
        }

        if (!oppIdMSet.isempty()){
            for (Opportunity o : opps)
                if (oppIdMSet.contains(o.id)) o.Exclude_from_VRs__c = false;
        }

        update opps;
    }
    else{
        //there are no other GP products for these opps and so Exclude_from_VRs__c should be false for all these opps
        Set<ID> opAllSet2 = new Set<ID>();
          for (OpportunityLineItem oppline : delLines){
              opAllSet2.add(oppline.Opportunityid);
          }
        
        if (!opAllSet.isempty()){
            //only need to set Exclude_from_VRs__c if it is currently true
            Opportunity[] opps = [Select Exclude_from_VRs__c from Opportunity where Id In:opAllSet2 and Exclude_from_VRs__c=true];
            for (Opportunity misysOpps : opps)
                misysOpps.Exclude_from_VRs__c = false;
            
            update opps;
        }
      }
  }
}