@IsTest
private class ContactTriggerHandler_Test {

    @IsTest
    static void testInsertContactsWithSameName() {
        // GIVEN two Contacts with the same name, but otherwise distinct
        Contact c1 = new Contact(FirstName='A',LastName='B',Email='a1@test.test');
        Contact c2 = new Contact(FirstName='A',LastName='B',Email='a2@test.test');
        Contact[] contacts = new Contact[]{c1,c2};

        // WHEN inserting the Contacts
        Test.startTest();
        insert contacts;
        Test.stopTest();

        // THEN both Contacts will exist
        Contact[] newContacts = [SELECT FirstName, LastName, Email, IndividualId FROM Contact ORDER BY Email];
        System.assertEquals(2, newContacts.size());
        System.assertEquals('a1@test.test', newContacts[0].Email);
        System.assertEquals('a2@test.test', newContacts[1].Email);

        // AND two Individuals will be created with the same name but distinct Ids
        Individual[] newInds = [SELECT Id, FirstName, LastName FROM Individual];
        System.assertEquals(2, newInds.size());
        System.assertEquals('A', newInds[0].FirstName);
        System.assertEquals('B', newInds[0].LastName);
        System.assertEquals('A', newInds[1].FirstName);
        System.assertEquals('B', newInds[1].LastName);
        Set<Id> indIds = new Set<Id>();
        for (Individual ind : newInds) {
            indIds.add(ind.Id);
        }
        System.assertEquals(2, indIds.size());

        // AND the Contacts will be linked to the Individuals
        System.assertEquals(true, indIds.contains(newContacts[0].IndividualId));
        System.assertEquals(true, indIds.contains(newContacts[1].IndividualId));
        System.assertNotEquals(newContacts[0].IndividualId, newContacts[1].IndividualId);
    }

    @IsTest
    static void testInsertLeadsWithSameName() {
        // GIVEN two Leads with the same name, but otherwise distinct
        Lead l1 = new Lead(FirstName='A',LastName='B',Company='Fin1');
        Lead l2 = new Lead(FirstName='A',LastName='B',Company='Fin2');
        Lead[] leads = new Lead[]{l1,l2};

        // WHEN inserting the Leads
        Test.startTest();
        insert leads;
        Test.stopTest();

        // THEN both Leads will exist
        Lead[] newleads = [SELECT FirstName, LastName, Company, IndividualId FROM Lead ORDER BY Company];
        System.assertEquals(2, newLeads.size());
        System.assertEquals('Fin1', newleads[0].Company);
        System.assertEquals('Fin2', newleads[1].Company);

        // AND two Individuals will be created with the same name but distinct Ids
        Individual[] newInds = [SELECT Id, FirstName, LastName FROM Individual];
        System.assertEquals(2, newInds.size());
        System.assertEquals('A', newInds[0].FirstName);
        System.assertEquals('B', newInds[0].LastName);
        System.assertEquals('A', newInds[1].FirstName);
        System.assertEquals('B', newInds[1].LastName);
        Set<Id> indIds = new Set<Id>();
        for (Individual ind : newInds) {
            indIds.add(ind.Id);
        }
        System.assertEquals(2, indIds.size());

        // AND the Leads will be linked to the Individuals
        System.assertEquals(true, indIds.contains(newleads[0].IndividualId));
        System.assertEquals(true, indIds.contains(newleads[1].IndividualId));
        System.assertNotEquals(newleads[0].IndividualId, newleads[1].IndividualId);
    }

    @IsTest
    static void testUpdateConsentRecord() {
        // GIVEN a new Contacts record
        Contact con = new Contact(FirstName='A', LastName='B', Email='a1@test.test', Corp_E_Consent__c='Opt-in');
        insert con;

        con = [SELECT FirstName, LastName, Email, IndividualId,
                Corp_E_Consent__c, Corp_E_Consent_LU__c, Corp_E_Consent_NT__c, Corp_E_Consent_USR__c,
                Corp_P_Consent__c, Corp_P_Consent_LU__c, Corp_P_Consent_NT__c, Corp_P_Consent_USR__c,
                PrdSol_E_Consent__c, PrdSol_E_Consent_LU__c, PrdSol_E_Consent_NT__c, PrdSol_E_Consent_USR__c,
                PrdSol_P_Consent__c, PrdSol_P_Consent_LU__c, PrdSol_P_Consent_NT__c, PrdSol_P_Consent_USR__c,
                FinEv_E_Consent__c, FinEv_E_Consent_LU__c, FinEv_E_Consent_NT__c, FinFv_E_Consent_USR__c,
                FinEv_P_Consent__c, FinEv_P_Consent_LU__c, FinEv_P_Consent_NT__c, FinEv_P_Consent_USR__c,
                Ind_E_Consent__c, Ind_E_Consent_LU__c, Ind_E_Consent_NT__c, Ind_E_Consent_USR__c,
                Ind_P_Consent__c, Ind_P_Consent_LU__c, Ind_P_Consent_NT__c, Ind_P_Consent_USR__c,
                Rep_E_Consent__c, Rep_E_Consent_LU__c, Rep_E_Consent_NT__c, Rep_E_Consent_USR__c,
                Rep_P_Consent__c, Rep_P_Consent_LU__c, Rep_P_Consent_NT__c, Rep_P_Consent_USR__c
        FROM Contact WHERE Id = :con.Id];

        Contact[] conList = new Contact[]{ con };
        Map<Id, Contact> oldMap = new Map<Id, Contact>{ con.Id => new Contact() };
        Test.startTest();
        ContactTriggerHandler.updateConsentRecord(conList, oldMap);
        Test.stopTest();

    }

}