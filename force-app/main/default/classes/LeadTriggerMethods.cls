public class LeadTriggerMethods {

    public static void UpdateCountryInfo(List<Lead> lLeadNew, Map<Id,Lead> mLeadOld)
    {
        //Loop through the leads
        for(Lead newLead : lLeadNew){
            //If the Country value has been changed...
            //system.debug('Old Country='+mLeadOld.get(newLead.Id).Lead_Country__c+', New Country='+newLead.Lead_Country__c);
            if(mLeadOld == null || newLead.Lead_Country__c != mLeadOld.get(newLead.Id).Lead_Country__c || newLead.Tickle_Me__c == true){
                //Look up the Sales Region for the updated Country in the Country__c custom setting
                Country__c countryData = new Country__c();
                if(newLead.Lead_Country__c == '' || newLead.Lead_Country__c == null){
                    countryData = null;
                }else{
                    countryData = Country__c.getValues(newLead.Lead_Country__c);
                }
                system.debug('Country info from Custom Setting: '+countryData);
                //Set the Sales Region on the account
                if(countryData != null)
                    newLead.Sales_Region__c = countryData.Sales_Region__c;
                else
                    newLead.Sales_Region__c = null;
            }
        }
    }
    
   /* public static void updateTopSolution(List<Lead> lLeadNew)
    {
        String topSolution = 'FusionBanking';
        Decimal topScore;
        
        for(Lead newLead : lLeadNew){
        
            topScore  = Integer.valueOf(newLead.FusionBanking_Score__c);
           
            if(topScore == null)
            topScore = -999;
            
            if (Integer.valueOf(newLead.FusionCapital_Score__c) > topScore)
            {
                topSolution = 'FusionCapital';
                topScore = Integer.valueOf(newLead.FusionCapital_Score__c); 
            }
            if(Integer.valueOf(newLead.FusionCorporate_Score__c) > topScore){
                      topSolution = 'FusionCorporate';
                      topScore = Integer.valueOf(newLead.FusionCorporate_Score__c) ;
            }
            if(Integer.valueOf(newLead.FusionInvest_Score__c) > topScore){
                      topSolution = 'FusionInvest';
                      topScore = Integer.valueOf(newLead.FusionInvest_Score__c);
            }
            if(Integer.valueOf(newLead.FusionRisk_Score__c) > topScore){
                      topSolution = 'FusionRisk';
                      topScore = Integer.valueOf(newLead.FusionRisk_Score__c);
            }
            newLead.topSolution__c = topSolution ;
        
        }
    
    }*/
    
     public static void updateTopScoringNurture(List<Lead> lLeadNew)
    {
        String topSolution = '';
        Decimal topScore;
        
        for(Lead newLead : lLeadNew){
        
          //  topScore  = Integer.valueOf(newLead.Nurture1_Score__c);
           
         //   if(topScore == null)
            topScore = 0;
           
           if (Integer.valueOf(newLead.Nurture1_Score__c) > topScore)
            {
                topSolution = 'Nurture1';
                topScore = Integer.valueOf(newLead.Nurture1_Score__c); 
            }
             
            if (Integer.valueOf(newLead.Nurture2_Score__c) > topScore)
            {
                topSolution = 'Nurture2';
                topScore = Integer.valueOf(newLead.Nurture2_Score__c); 
            }
            if(Integer.valueOf(newLead.Nurture3_Score__c) > topScore){
                      topSolution = 'Nurture3';
                      topScore = Integer.valueOf(newLead.Nurture3_Score__c) ;
            }
            if(Integer.valueOf(newLead.Nurture4_Score__c) > topScore){
                      topSolution = 'Nurture4';
                      topScore = Integer.valueOf(newLead.Nurture4_Score__c);
            }
            if(Integer.valueOf(newLead.Nurture5_Score__c) > topScore){
                      topSolution = 'Nurture5';
                      topScore = Integer.valueOf(newLead.Nurture5_Score__c);
            }
            newLead.topSolution__c = topSolution ;
        
        }
    
    }
    
    /*
    KK: SD Req 1442818
    Method: updateOppMarketingGeneratedProgram
    Description: To Update the Marketing generated Program field on opportunity with the MQL Program value on Lead
                 when Lead is converted and new opportunity is created.This functionality is used for tracking 
                 Marketing Generated and Influenced Opportunities through Marketo.
    Parameters: List of Updated Leads
    Return: Void
    */
    public static void updateOppMarketingGeneratedProgram(List<Lead> newLeadList){
         Map<ID,Lead> oppIdToLeadMap= new  Map<ID,Lead>();
         List<Opportunity> oppsToUpdate;
         for(Lead leadObj: newLeadList) {
             //To check if the Lead is converted and new Opportunity is created at the same time
                if (leadObj.IsConverted && leadObj.ConvertedOpportunityId!=null ){
                    //If MQL program is present on Lead then same needs to be copied to the Newly created opp
                        if(String.isNotEmpty(leadObj.MQL_Program__c) || String.isNotEmpty(leadObj.Marketing_Involved_Program__c)){
                            oppIdToLeadMap.put(leadObj.ConvertedOpportunityId,leadObj);
                        }
                }   
        }
        //To fetch the opportunities to be updated
        if(oppIdToLeadMap.size()>0){
            oppsToUpdate = [SELECT Id, Marketing_Generated_Program__c,Marketing_Generated_Date__c FROM Opportunity WHERE Id in :oppIdToLeadMap.keySet()];
            //Update the Marketing generated Program field on opportunity with the MQL Program value on Lead
            for(Opportunity oppObj: oppsToUpdate){
                if(String.isNotEmpty(oppIdToLeadMap.get(oppObj.Id).MQL_Program__c) ){
                    oppObj.Marketing_Generated_Program__c=oppIdToLeadMap.get(oppObj.Id).MQL_Program__c;
                    oppObj.Marketing_Generated_Date__c=Date.today();
                }if(String.isNotEmpty(oppIdToLeadMap.get(oppObj.Id).Marketing_Involved_Program__c)){
                    oppObj.Marketing_Involved_Program__c=oppIdToLeadMap.get(oppObj.Id).Marketing_Involved_Program__c;
                    oppObj.Marketing_Involved_Date__c=Date.today();
                }
            }
            update oppsToUpdate ;               
        }
     
    }

}