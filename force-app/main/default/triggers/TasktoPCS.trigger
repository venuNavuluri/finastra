trigger TasktoPCS on Task (before update) {

    // This trigger checks the 'Was this opp generated from a GTM'
    // question on open opp task (if the PCS was not filled in at opp 
    // creation), and if 'YES', maps the Campaign entered on the task 
    // to the PCS field on the opp. If 'NO', maps NULL Campaign to PCS.

    if (trigger.new[0].Was_this_Opp_generated_from_a_GTM__c == 'Yes') {
    
        //get the id of the opp, pass the value of GTM lookup on task to PCS on opp
        list<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Id =: trigger.old[0].WhatId];
        Opportunity opp;
        if(oppList != null && oppList.size() > 0){
            opp = oppList[0];
            opp.CampaignId = trigger.new[0].GTM_Campaign__c;
            update opp;
        }
        trigger.new[0].Status = 'Completed';
    }
        
    if (trigger.new[0].Was_this_Opp_generated_from_a_GTM__c == 'No') {
        list<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Id =: trigger.old[0].WhatId];
        list<Campaign> campList = [SELECT Id FROM Campaign WHERE Name =: 'NULL GTM Campaign'];
        Campaign camp;
        if(campList != null && campList.size() > 0){
            camp = campList[0];
        }
        Opportunity opp;
        if(oppList != null && oppList.size() > 0){
            opp = oppList[0];
            if(camp != null){
                opp.CampaignId = camp.Id;
                update opp;
            }
        }
        if(camp != null){
            trigger.new[0].GTM_Campaign__c = camp.Id;
        }
        trigger.new[0].Status = 'Completed';
    }
}