@isTest
private class ContactTriggerMethodsTest {

    private static testMethod void TestUpdateOppMarketingInvolvedProgram() {
        //To create test Account 
        Account testAccount1 = TestUtility.sampleAccount();
        insert testAccount1;
        //To create test contact
        Contact testContact1 = TestUtility.sampleContact();
        testContact1.AccountId = testAccount1.Id;
        testContact1.Inactive_Contact__c = false;
        testContact1.Marketing_Involved_Program__c='Test Update Opp Marketing Involved Program on Contact Updation 1';
        insert testContact1;
         //To create test opportunity 1
        Opportunity testOpp1= TestUtility.sampleOpportunity(testContact1);
        testOpp1.Marketing_Involved_Program__c='Test Update Opp Marketing Involved Program on Contact Updation 1';
        testOpp1.stageName='2. Create';
        Database.SaveResult srOpp1 = Database.insert(testOpp1, true);
        System.assert(srOpp1.isSuccess());
          //To create test opportunity 2
        Opportunity testOpp2= TestUtility.sampleOpportunity(testContact1);
        testOpp2.Marketing_Involved_Program__c='Test Update Opp Marketing Involved Program on Contact Updation 2';
        testOpp2.stageName='4. Develop';
        Database.SaveResult srOpp2 = Database.insert(testOpp2, true);
        System.assert(srOpp2.isSuccess());
        //To add the contact to opportunities as contact Role
        List<OpportunityContactRole> oppConList = new List<OpportunityContactRole>();
        OpportunityContactRole testOppRoleCon1=(new OpportunityContactRole (ContactId=testContact1.Id, OpportunityId=testOpp1.Id, Role='Decision Maker',IsPrimary=TRUE));
         oppConList.add(testOppRoleCon1);
        OpportunityContactRole testOppRoleCon2=(new OpportunityContactRole (ContactId=testContact1.Id, OpportunityId=testOpp2.Id, Role='Decision Maker',IsPrimary=TRUE));
        oppConList.add(testOppRoleCon2);
        insert oppConList;
        //To update the Marketing involved details on the contact
        Contact contactToUpdate=[select id,Marketing_Involved_Program__c,Corp_E_Consent__c, Corp_P_Consent__c, FinEv_E_Consent__c,FinEv_P_Consent__c,
                                  Ind_E_Consent__c, Ind_P_Consent__c, PrdSol_E_Consent__c, PrdSol_P_Consent__c, Rep_E_Consent__c, Rep_P_Consent__c, IndividualId        
                                 from Contact where id=:testContact1.Id limit 1];
        contactToUpdate.Marketing_Involved_Program__c='Update the Marketing Involved Program on Contact';
        update contactToUpdate;
        
        contactToUpdate.Corp_E_Consent__c = 'Opt-in';
        contactToUpdate.Corp_P_Consent__c = 'Opt-out';
        update contactToUpdate;
 
        contactToUpdate.FinEv_E_Consent__c = 'Opt-out';
        contactToUpdate.FinEv_P_Consent__c = 'Opt-in';
        update contactToUpdate;
        
        
        contactToUpdate.Ind_E_Consent__c = 'Opt-in';
        contactToUpdate.Ind_P_Consent__c = 'Opt-in';
        update contactToUpdate;
        
        contactToUpdate.PrdSol_E_Consent__c = 'Opt-in';
        contactToUpdate.PrdSol_P_Consent__c = 'Opt-out';
        update contactToUpdate;
        
        
        contactToUpdate.Rep_E_Consent__c = 'Opt-in';
        contactToUpdate.Rep_P_Consent__c = 'Opt-in';
        update contactToUpdate;
        
        List<Current_Consent__c> ccList = [select Individual__c, Communication_Type__c, Email_Consent__c, Email_Consent_Last_Modified__c, Email_Consent_Notes__c, Email_Consent_Updated_By_User__c,
                                                  Phone_Consent__c, Phone_Consent_Last_Modified__c, Phone_Consent_Notes__c, Phone_Consent_Updated_By_User__c 
                                                  from Current_Consent__c
                                                  where Individual__c =: contactToUpdate.IndividualId];
        
        
                                               
        //To check the result, i.e Marketing involved details on corresponding open opportunities is also updated
        List<Opportunity> updatedOppList = [select id,Marketing_Involved_Program__c from Opportunity where id in (:testOpp1.Id, :testOpp2.Id)];
        for(Opportunity oppObj: updatedOppList){
            System.assertEquals('Update the Marketing Involved Program on Contact', oppObj.Marketing_Involved_Program__c);
        }
       
    }

}