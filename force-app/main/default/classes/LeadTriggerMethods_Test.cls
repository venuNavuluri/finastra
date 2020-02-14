@isTest
private class LeadTriggerMethods_Test {

    public static testmethod void testUpdateCountryInfo()
    {
        Lead testLead = TestUtility.sampleLead();   
        testLead.Lead_Country__c = 'United Kingdom';
        testLead.Area_of_interest__c = 'Corporate Treasury';
        insert testLead;
        Lead testLeadResult1 = [select Id, Lead_Country__c, Sales_Region__c from Lead where Id = :testLead.Id Limit 1];
        
        system.debug('Sales Region = '+testLeadResult1.Sales_Region__c);
      
        
        testLead.Lead_Country__c = null;
        update testLead;
        Lead testLeadResult2 = [select Id, Lead_Country__c, Sales_Region__c from Lead where Id = :testLead.Id Limit 1];
        system.debug('Sales Region = '+testLeadResult2.Sales_Region__c);
        system.assertEquals(testLeadResult2.Sales_Region__c,null);
        
    } 
    
     /*public static testmethod void testupdateTopSolution()
     {
    
        Lead testLead = TestUtility.sampleLead();   
        testLead.FusionInvest_Score__c= 1;
        testLead.FusionCorporate_Score__c = 1;
        testLead.Area_of_interest__c = 'Corporate Treasury';
        insert testLead;
        Lead testLeadResult1 = [select Id, FusionInvest_Score__c, FusionCorporate_Score__c, TopSolution__c from Lead where Id = :testLead.Id Limit 1];
        
        system.debug('FusionInvest Score = '+testLeadResult1.FusionInvest_Score__c);
        system.assertEquals(testLeadResult1.TopSolution__c ,'FusionCorporate');
        
        
        testLead.FusionInvest_Score__c= 2;
        update testLead;
        Lead testLeadResult2 = [select Id, FusionInvest_Score__c, FusionCorporate_Score__c, TopSolution__c from Lead where Id = :testLead.Id Limit 1];
        system.debug('FusionInvest Score = '+testLeadResult1.FusionInvest_Score__c);
        system.assertEquals(testLeadResult2.TopSolution__c ,'FusionInvest');
    
    }*/
    
    public static testmethod void testupdateTopNurtureScoring()
     {
    
        Lead testLead = TestUtility.sampleLead();   
        testLead.Nurture1_Score__c= 1;
        testLead.Nurture2_Score__c = 1;
        testLead.Area_of_interest__c = 'Corporate Treasury';
        insert testLead;
        Lead testLeadResult1 = [select Id, Nurture1_Score__c, Nurture2_Score__c, TopSolution__c,
                                Corp_E_Consent__c, Corp_P_Consent__c, FinEv_E_Consent__c,FinEv_P_Consent__c,
                                Ind_E_Consent__c, Ind_P_Consent__c, PrdSol_E_Consent__c, PrdSol_P_Consent__c, Rep_E_Consent__c, Rep_P_Consent__c, IndividualId   
                                from Lead where Id = :testLead.Id Limit 1];
        
       // system.debug('FusionInvest Score = '+testContact1.FusionInvest_Score__c);
        system.assertEquals(testLeadResult1.TopSolution__c ,'Nurture1');
        
        testLead.Nurture1_Score__c= 1;
        testLead.Nurture2_Score__c= 2;
        testLead.Nurture3_Score__c= 4;
        update testLead;
        
        testLead.Corp_E_Consent__c = 'Opt-in';
        testLead.Corp_P_Consent__c = 'Opt-out';
        update testLead;
        
        testLead.FinEv_E_Consent__c = 'Opt-out';
        testLead.FinEv_P_Consent__c = 'Opt-in';
        update testLead;
        
        
        testLead.Ind_E_Consent__c = 'Opt-in';
        testLead.Ind_P_Consent__c = 'Opt-in';
        update testLead;
        
        testLead.PrdSol_E_Consent__c = 'Opt-in';
        testLead.PrdSol_P_Consent__c = 'Opt-in';
        update testLead;
        
        
        testLead.Rep_E_Consent__c = 'Opt-in';
        testLead.Rep_P_Consent__c = 'Opt-in';
        update testLead;
     
         Lead testLeadResult2 = [select Id, Nurture1_Score__c, Nurture2_Score__c, TopSolution__c from Lead where Id = :testLead.Id Limit 1];
       // system.debug('FusionInvest Score = '+testContact2.FusionInvest_Score__c);
        system.assertEquals(testLeadResult2.TopSolution__c ,'Nurture3');
        
      
    }
    
     public static testmethod void testupdateOppMarketingGeneratedProgram()
     {
        Lead testLead = TestUtility.sampleLead();
        testLead.FirstName='Trigger1';
        testLead.LeadSource='Marketo';
        testLead.Area_of_interest__c = 'Corporate Treasury';
        testLead.MQL_Program__c= 'test update Opp Marketing Generated Program details';
        insert testLead;
        Lead testLeadResult1 = [select Id, MQL_Program__c, IsConverted, ConvertedOpportunityId from Lead where Id = :testLead.Id limit 1];
        testLead=testLeadResult1;
        system.assertEquals(testLead.MQL_Program__c ,'test update Opp Marketing Generated Program details');
     
       Database.LeadConvert leadConv = new database.LeadConvert();
       leadConv.setLeadId(testLead.Id);
       LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true and MasterLabel='Request to Convert' LIMIT 1];
       leadConv.setConvertedStatus(convertStatus.MasterLabel);
       Database.LeadConvertResult lcr = Database.convertLead(leadConv);
       // To check if Lead conversion was successful
       System.assert(lcr.isSuccess());
       
       Opportunity opp= [SELECT Id, Marketing_Generated_Program__c,Marketing_Generated_Date__c FROM Opportunity WHERE Id= :lcr.getOpportunityId() limit 1];
       system.assertEquals(opp.Marketing_Generated_Program__c ,'test update Opp Marketing Generated Program details');
     
    }

}