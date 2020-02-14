trigger LeadTrigger on Lead (before insert, before update, after update, after insert) {
    
    Map<ID,Lead> oppIdToLeadMap;
    Opportunity opp;
    
    if(Trigger.isAFter && Trigger.isInsert) {
        
        ContactTriggerHandler.createIndividual(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isInsert)
    {
        LeadTriggerMethods.UpdateCountryInfo(Trigger.new, null);
    }   
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        LeadTriggerMethods.UpdateCountryInfo(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isBefore )
    {
        LeadTriggerMethods.updateTopScoringNurture(Trigger.new);
    }
     /*
    KK: SD Req 1442818
    Description: To check if the Trigger is After Update and call the updateOppMarketingGeneratedProgram
                 method to update the marketing related fields on new Opp created from converted list

    */
    if(Trigger.isAfter && Trigger.isUpdate){
        LeadTriggerHandler.createCurrentConsent(Trigger.new, Trigger.oldMap);
        LeadTriggerMethods.updateOppMarketingGeneratedProgram(system.Trigger.new);
        //KK: PartnerPath Integration - To send the update to partner path on Partner Lead status change
        List<Id> partnerPathLeadIdList = new List<Id>();
        for(Lead leadObject : system.Trigger.new){
            //To send update to PP only if the partnerpath lead status changes
            if(leadObject.RecordTypeId == IdManager.Lead_PartnerLeadRecTypeId && !String.isEmpty(leadObject.PartnerPath_ID__c)
                && leadObject.Status!=Trigger.oldmap.get(leadObject.id).status){
                partnerPathLeadIdList.add(leadObject.Id);
            }
        }
        if(partnerPathLeadIdList.size()>0){
            system.debug('LeadTrigger :: call the partnerpath deal update api');
            PartnerPathRESTIntegration.sendLeadDetailsToPartnerPathOnUpdate(partnerPathLeadIdList);
        }
        
    }
            

    //The Tickle Me field is used to trigger updates that would otherwise only run under certain conditions.  This sets the field back to False once the items are triggered.
    for(Lead Lead1 : Trigger.new)
    {
        if(Lead1.Tickle_Me__c == true)
        {
            system.debug('Tickled Lead: '+Lead1.Id + ' ' + Lead1.Name);
            Lead1.Tickle_Me__c = false;
        }
    }   
    
}