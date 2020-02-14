trigger UpdatePCS on Lead (after update) {

    // This trigger takes the campaign entered on a lead,
    // and maps it to the Primary Campaign Source field on the resulting opp.

if (trigger.old[0].isConverted == false && trigger.new[0].isConverted == true)

    if (Trigger.new[0].ConvertedOpportunityId != null) {
    
        Opportunity opp = [SELECT Id, CampaignId FROM Opportunity WHERE Id = :Trigger.new[0].ConvertedOpportunityId];
        //Opportunity opp = trigger.new[0].ConvertedOpportunity;
        opp.CampaignId = trigger.new[0].Primary_Campaign_Source__c;
        update opp;
        
        }
        
    }