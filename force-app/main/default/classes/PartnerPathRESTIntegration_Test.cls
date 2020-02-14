@isTest(SeeAllData=true)
private class PartnerPathRESTIntegration_Test {

/*
Method: testPartnerPathUtility
Description: This is the method to test the partnerpath utility class i.e partnerpath configuration 
Parameters: None
Return: Void
*/
static testmethod void testPartnerPathUtility(){
        // To get the partnerpath endpoint
        String endpoint = PartnerPathUtility.getEndPoint();
        // To get the partnerpath token
        String token = PartnerPathUtility.getToken();
        System.assertNotEquals(null, endpoint);
        System.assertNotEquals(null, token);
}

/*
Method: testSendLeadDetailsToPartnerPathOnUpdate
Description: This is the method to test the partnerpath REST API call on Partner Lead Status Updation
Parameters: None
Return: Void
*/
static testmethod void testSendLeadDetailsToPartnerPathOnUpdate(){
         Lead testLead =  TestUtility.sampleLead();
         testLead.status = 'Partner Captured Lead (PCL)';
         testLead.Area_of_interest__c='FusionBanking (Core Banking)';
         testLead.PartnerPath_ID__c='1';
         testLead.RecordTypeId = IdManager.Lead_PartnerLeadRecTypeId;
         testLead.Contact_Level__c='5: User';
         //To create a partner lead
         insert testLead;
         // Call Test.startTest before performing callout but after setting test data.
         Test.startTest();
             Lead leadObj = [select id, status from Lead where id = : testLead.id limit 1];
             // Set mock callout class to get the fake http response
             Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_Test());
             // To change the lead status
             leadObj.status='Request to Convert';
             // update lead will cause the lead trigger to make an http callout to partnerpath.
             update leadObj;
         Test.stopTest();

}

/*
Method: testSendOppDetailsToPartnerPathOnOppCreateUpdate
Description: This is the method to test the partnerpath REST API call on Partner Opportunity Creation and also on updation.s
Parameters: None
Return: Void
*/    
static testmethod void testSendOppDetailsToPartnerPathOnOppCreateUpdate(){
         Opportunity testOpp =  TestUtility.sampleOpportunity();
         Account partnerAccount = TestUtility.sampleAccount();
         partnerAccount.type='Prospective Partner';
         insert partnerAccount;
         
         testOpp.PartnerPath_ID__c='1';
         testOpp.RecordTypeId = IdManager.OPP_LicensesWithWithoutPSRecTypeId;
         testOpp.Probability=0;
         testOpp.CloseDate=system.TODAY();
         testOpp.Partner_Originated__c='Yes';
         testOpp.Partner_Role_s__c='Reseller';
         testOpp.Opportunity_Partner__c=partnerAccount.id;
         // Call Test.startTest before performing callout but after setting test data.
         Test.startTest();
             // Set mock callout class to get the fake http response
             Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_Test());
             //To create a partner opportunity
             insert testOpp;

           //To fetch the opportunity and update the opp details to be send to partnerpath
            Opportunity oppUpdateObj = [Select id, name,account.name,StageName,ForecastCategoryName, probability, Order_Number__c, PartnerPath_ID__c,CloseDate,Sales_Region_FY07__c,MainProduct__c,
                        Pricing_Country__c,Opportunity_Partner__c,Partner_Role_s__c,Partner_Originated__c,Partner_Advisory_Manager_Comment__c, NextStep, Next_Step_Due_Date__c, Owner.name,Proposed_Solution__c,
                        Why_Misys_Unique_Selling_Point__c, SDA_3_Vision_Roadmap__c, Why_do_something__c, Installed_Supplier__c,MainCompetitor__c,Other_Competition__c,Competitive_Differentiators__c,Key_Dependencies__c,
                        ARIS_product_included__c,MAPS_product_included__c From Opportunity where id =: testOpp.id limit 1];
            //To update the fields on opportunity and send the update to PartnerPath
            oppUpdateObj.Sales_Region_FY07__c='Test PP Sales region';
            oppUpdateObj.MainProduct__c='BankFusion Equation';
            oppUpdateObj.Pricing_Country__c='Belgium';
            oppUpdateObj.Partner_Advisory_Manager_Comment__c='Test PP manager comment';
            oppUpdateObj.NextStep='Test PP next step';
            oppUpdateObj.Next_Step_Due_Date__c=System.TODAY();
            oppUpdateObj.Proposed_Solution__c='Test Partnerpath SDA 1 field';
            oppUpdateObj.Why_Misys_Unique_Selling_Point__c	='Test Partnerpath SDA #2 field';
            oppUpdateObj.SDA_3_Vision_Roadmap__c='Test Partnerpath SDA #3 field';
            oppUpdateObj.Why_do_something__c='Test Partnerpath summery of pain';
            oppUpdateObj.Challenger_Overview__c	='Test Partnerpath challenege overview';
            oppUpdateObj.Installed_Supplier__c='Asseco SEE';
            oppUpdateObj.MainCompetitor__c	='Microlink Systems';
            oppUpdateObj.Other_Competition__c='Advent Software; Algorithmics';
            oppUpdateObj.Competitive_Differentiators__c='Test Partnerpath competitive diff field';
            oppUpdateObj.Key_Dependencies__c ='Test Partnerpath key dependencies field';
            oppUpdateObj.ARIS_product_included__c =True;
            oppUpdateObj.MAPS_product_included__c =True;
             // Set mock callout class to get the fake http response
             Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_Test());
             //To create a partner opportunity
             update oppUpdateObj;
          Test.stopTest();
}

/*
Method: testsendOppDetailsToPPSync
Description: This is the method to test the partnerpath REST API synchronous call 
Parameters: None
Return: Void
*/    
static testmethod void testsendOppDetailsToPPSync(){
         Opportunity testOpp =  TestUtility.sampleOpportunity();
         Account partnerAccount = TestUtility.sampleAccount();
         partnerAccount.type='Prospective Partner';
         insert partnerAccount;
         
         testOpp.PartnerPath_ID__c='1';
         testOpp.RecordTypeId = IdManager.OPP_LicensesWithWithoutPSRecTypeId;
         testOpp.Probability=0;
         testOpp.CloseDate=system.TODAY();
         testOpp.Partner_Originated__c='Yes';
         testOpp.Partner_Role_s__c='Reseller';
         testOpp.Opportunity_Partner__c=partnerAccount.id;
         // Call Test.startTest before performing callout but after setting test data.
         Test.startTest();
             // Set mock callout class to get the fake http response
             Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_Test());
             //To create a partner opportunity
             insert testOpp;

           //To fetch the opportunity and update the opp details to be send to partnerpath
            List<Opportunity> oppUpdateObjList = [Select id, name,account.name,StageName,ForecastCategoryName, probability, Order_Number__c, PartnerPath_ID__c,CloseDate,Sales_Region_FY07__c,MainProduct__c,
                        Pricing_Country__c,Opportunity_Partner__c,Partner_Role_s__c,Partner_Originated__c,Partner_Advisory_Manager_Comment__c, NextStep, Next_Step_Due_Date__c, Owner.name,Proposed_Solution__c,
                        Why_Misys_Unique_Selling_Point__c, SDA_3_Vision_Roadmap__c, Why_do_something__c, Installed_Supplier__c,MainCompetitor__c,Other_Competition__c,Competitive_Differentiators__c,Key_Dependencies__c,
                        ARIS_product_included__c,MAPS_product_included__c From Opportunity where id =: testOpp.id limit 1];
            // Set mock callout class to get the fake http response
             Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_Test());
    		// To call the sync method
    		 PartnerPathRESTIntegration.sendOppDetailsToPPSync(oppUpdateObjList);

          Test.stopTest();
	}
}