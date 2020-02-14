@IsTest
private class TestDataInsert_Test {

    @IsTest
    static void testInsertAnyObject() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND we have a Json definition of an object
        String testJson = '{"attributes":{"type":"Debug_Parent__c"},"Message_Type__c":"Test Message"}';

        // WHEN calling insertAnyObject()
        Test.startTest();
            SObject newSObj = tdi.insertAnyObject(testJson, null, null, Debug_Parent__c.class);
        Test.stopTest();

        // THEN the object will exist as per Json definition
        Map<String, Object> fieldValues = (Map<String, Object>) JSON.deserializeUntyped(testJson);
        Debug_Parent__c[] testObj = [SELECT Id, Message_Type__c FROM Debug_Parent__c];
        System.assertEquals(1, testObj.size());
        System.assertEquals(newSObj.Id, testObj[0].Id);
        System.assertEquals(fieldValues.get('Message_Type__c'), testObj[0].Message_Type__c);
    }

    @IsTest
    static void testInsertSingleAccount() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND the TestDataJsonLibrary entry for an Account
        String accountJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_ACCOUNT);
        System.assert(String.isNotBlank(accountJson));

        // WHEN using it to insert an account
        Test.startTest();
        Account newAccount = tdi.insertAccount(null, null);
        Test.stopTest();

        // THEN the account will exist as per Json from standard library
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(accountJson);
        Account[] checkAccounts = [SELECT Id, Name FROM Account];
        System.assertEquals(1, checkAccounts.size());
        System.assertEquals(newAccount.Id, checkAccounts[0].Id);
        System.assertEquals(libraryData.get('Name'), checkAccounts[0].Name);
    }

    @IsTest
    static void testInsertCustomAccount() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND the TestDataJsonLibrary has a Custom entry for an Account
        String accountJson = new TestDataJsonLibrary.Custom().jsonMap.get(Constants.TDF_CUSTOM_ACCOUNT);
        System.assert(String.isNotBlank(accountJson));

        // WHEN using it to insert a custom account
        Test.startTest();
        Account newAccount = tdi.insertAccount(Constants.TDF_CUSTOM_ACCOUNT, null, null);
        Test.stopTest();

        // THEN the account will exist as per Json from custom library
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(accountJson);
        Account[] checkAccounts = [SELECT Id, Name FROM Account];
        System.assertEquals(1, checkAccounts.size());
        System.assertEquals(newAccount.Id, checkAccounts[0].Id);
        System.assertEquals(libraryData.get('Name'), checkAccounts[0].Name);
    }

    @IsTest
    static void testInsertCustomAccountWithFieldValues() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND the TestDataJsonLibrary has a Custom entry for an Account
        String accountJson = new TestDataJsonLibrary.Custom().jsonMap.get(Constants.TDF_CUSTOM_ACCOUNT);
        System.assert(String.isNotBlank(accountJson));

        // WHEN using the tdi to insert a custom account with additional field values
        Test.startTest();
        Map<String, Object> setFields = new Map<String, Object>{
                'AccountNumber' => 'OVERRIDE-123'
        };
        Account newAccount = tdi.insertAccount(Constants.TDF_CUSTOM_ACCOUNT, setFields, null);
        Test.stopTest();

        // THEN the account will exist as per Json from standard library
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(accountJson);
        Account[] checkAccounts = [SELECT Id, Name, AccountNumber FROM Account];
        System.assertEquals(1, checkAccounts.size());
        System.assertEquals(newAccount.Id, checkAccounts[0].Id);
        System.assertEquals(libraryData.get('Name'), checkAccounts[0].Name);
        System.assertEquals(setFields.get('AccountNumber'), checkAccounts[0].AccountNumber);
    }

    @IsTest
    static void testInsertCustomAccountUnknownKey() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // WHEN using it to insert a custom account with an unknown key
        Test.startTest();
        Account newAccount = tdi.insertAccount('XXX-UNKNOWN-XXX', null, null);
        Test.stopTest();

        // THEN no account record will be created
        System.assertEquals(null, newAccount);
        Account[] checkAccounts = [SELECT Id, Name FROM Account];
        System.assertEquals(0, checkAccounts.size());
    }

    @IsTest
    static void testInsertSingleAccountWithFieldValues() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND the TestDataJsonLibrary entry for an Account
        String accountJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_ACCOUNT);
        System.assert(String.isNotBlank(accountJson));

        // WHEN using the tdi to insert an account with additional field values
        Test.startTest();
        Map<String, Object> setFields = new Map<String, Object>{
                'AccountNumber' => 'ACCOUNT-12345',
                'Type' => 'Customer',
                'Budget__c' => 1000.00,
                'Next_Audit_date__c' => System.today()+7
        };
        Account newAccount = tdi.insertAccount(setFields, null);
        Test.stopTest();

        // THEN the account will exist
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(accountJson);
        Account[] checkAccounts = [SELECT Id, Name, AccountNumber, Type, Budget__c, Next_Audit_date__c FROM Account];
        System.assertEquals(1, checkAccounts.size());
        System.assertEquals(newAccount.Id, checkAccounts[0].Id);
        System.assertEquals(libraryData.get('Name'), checkAccounts[0].Name);

        // AND the additional fields will be populated correctly
        System.assertEquals(setFields.get('AccountNumber'), checkAccounts[0].AccountNumber);
        System.assertEquals(setFields.get('Type'), checkAccounts[0].Type);
        System.assertEquals(setFields.get('Budget__c'), checkAccounts[0].Budget__c);
        System.assertEquals(setFields.get('Next_Audit_date__c'), checkAccounts[0].Next_Audit_date__c);
    }

    @IsTest
    static void testInsertSingleAccountWithJsonOverride() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND we override the Json data for an Account
        String alternativeJson = JSON.serialize(new Account(Name='Alternative',AccountNumber='ALT23456'));
        tdi.overrideJson.put(Account.class, alternativeJson);

        // WHEN using the tdi to insert an account
        Test.startTest();
        Account newAccount = tdi.insertAccount(null, null);
        Test.stopTest();

        // THEN the account will exist as per the overridden Json data
        Map<String, Object> overrideData = (Map<String, Object>) JSON.deserializeUntyped(alternativeJson);
        Account[] checkAccounts = [SELECT Id, Name, AccountNumber FROM Account];
        System.assertEquals(1, checkAccounts.size());
        System.assertEquals(newAccount.Id, checkAccounts[0].Id);
        System.assertEquals(overrideData.get('Name'), checkAccounts[0].Name);
        System.assertEquals(overrideData.get('AccountNumber'), checkAccounts[0].AccountNumber);
    }

    @IsTest
    static void testInsertSingleAccountInBulkMode() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND we enable bulk mode
        tdi.bulkModeOn = true;

        // WHEN using the tdi to insert an account
        Test.startTest();
        Account newAccount = tdi.insertAccount(null, null);
        Test.stopTest();

        // THEN the account object is returned as per Json from standard library
        String accountJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_ACCOUNT);
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(accountJson);
        System.assertEquals(libraryData.get('Name'), newAccount.Name);

        // BUT it does not exist in the database
        System.assertEquals(null, newAccount.Id);
        Account[] checkAccounts = [SELECT Id FROM Account];
        System.assertEquals(0, checkAccounts.size());
    }

    @IsTest
    static void testInsertSingleAccountWithErrors() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND a list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN using the tdi to insert an account with invalid fields
        Test.startTest();
        Map<String, Object> setFields = new Map<String, Object>{
                'Name' => null
        };
        Account newAccount = tdi.insertAccount(setFields, dbErrors);
        Test.stopTest();

        // THEN the account will not exist
        System.assertEquals(null, newAccount.Id);
        Account[] checkAccounts = [SELECT Id FROM Account];
        System.assertEquals(0, checkAccounts.size());

        // AND the error list will include the error
        System.assertEquals(1, dbErrors.size());
        System.assertEquals(false, dbErrors[0].success);
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, dbErrors[0].errors[0].statusCode);
    }

    @IsTest
    static void testInsertSingleAccountWithException() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN using the tdi to insert an account with invalid data types
        Test.startTest();
        Boolean exceptionOccurred = false;
        Account newAccount;
        try {
            Map<String, Object> setFields = new Map<String, Object>{
                    'Budget__c' => 'XYZ'
            };
            newAccount = tdi.insertAccount(setFields, dbErrors);
        }
        catch (Exception ex) {
            exceptionOccurred = true;
        }
        Test.stopTest();

        // THEN the account will not exist
        System.assertEquals(null, newAccount);
        Account[] checkAccounts = [SELECT Id FROM Account];
        System.assertEquals(0, checkAccounts.size());

        // AND an exception will have been raised
        System.assertEquals(true, exceptionOccurred);
    }

    @IsTest
    static void testInsertSingleContact() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND the TestDataJsonLibrary entry for a Contact
        String contactJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_CONTACT);
        System.assert(String.isNotBlank(contactJson));

        // WHEN using it to insert a contact
        Test.startTest();
        Contact newContact = tdi.insertContact(null, null);
        Test.stopTest();

        // THEN the contact will exist as per Json from standard library
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(contactJson);
        Contact[] checkContacts = [SELECT Id, LastName, Email FROM Contact];
        System.assertEquals(1, checkContacts.size());
        System.assertEquals(newContact.Id, checkContacts[0].Id);
        System.assertEquals(libraryData.get('LastName'), checkContacts[0].LastName);
        System.assertEquals(libraryData.get('Email'), checkContacts[0].Email);
    }

    @IsTest
    static void testInsertSingleContactWithFieldValues() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND the TestDataJsonLibrary entry for a Contact
        String contactJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_CONTACT);
        System.assert(String.isNotBlank(contactJson));

        // WHEN using the tdi to insert a contact with additional field values
        Test.startTest();
        Map<String, Object> setFields = new Map<String, Object>{
                'Birthdate' => Date.newInstance(1963,7,21),
                'HomePhone' => '+441234123456',
                'DoNotCall' => true
        };
        Contact newContact = tdi.insertContact(setFields, null);
        Test.stopTest();

        // THEN the contact will exist
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(contactJson);
        Contact[] checkContacts = [SELECT Id, LastName, Email, Birthdate, HomePhone, DoNotCall FROM Contact];
        System.assertEquals(1, checkContacts.size());
        System.assertEquals(newContact.Id, checkContacts[0].Id);
        System.assertEquals(libraryData.get('LastName'), checkContacts[0].LastName);
        System.assertEquals(libraryData.get('Email'), checkContacts[0].Email);

        // AND the additional fields will be populated correctly
        System.assertEquals(setFields.get('Birthdate'), checkContacts[0].Birthdate);
        System.assertEquals(setFields.get('HomePhone'), checkContacts[0].HomePhone);
        System.assertEquals(setFields.get('DoNotCall'), checkContacts[0].DoNotCall);
    }

    @IsTest
    static void testInsertSingleContactWithErrors() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND a list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN using the tdi to insert an account with invalid fields
        Test.startTest();
        Map<String, Object> setFields = new Map<String, Object>{
                'LastName' => null
        };
        Contact newContact = tdi.insertContact(setFields, dbErrors);
        Test.stopTest();

        // THEN the account will not exist
        System.assertEquals(null, newContact.Id);
        Contact[] checkContacts = [SELECT Id FROM Contact];
        System.assertEquals(0, checkContacts.size());

        // AND the error list will include the error
        System.assertEquals(1, dbErrors.size());
        System.assertEquals(false, dbErrors[0].success);
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, dbErrors[0].errors[0].statusCode);
    }

    @IsTest
    static void testInsertSingleContactWithSavedErrors() {
        // GIVEN the TestDataInsert class is configured to save errors
        TestDataInsert tdi = new TestDataInsert();
        tdi.saveErrors = true;
        tdi.debugMessageType = 'Saved Errors';

        // AND Monitoring is set up to record these messages
        insert new Monitoring__c( Name = tdi.debugMessageType, Active__c = true );

        // AND we have a list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN using the tdi to insert an account with invalid fields
        Test.startTest();
        Map<String, Object> setFields = new Map<String, Object>{
                'LastName' => null
        };
        Contact newContact = tdi.insertContact(setFields, dbErrors);
        Test.stopTest();

        // THEN the account will not exist
        System.assertEquals(null, newContact.Id);
        Contact[] checkContacts = [SELECT Id FROM Contact];
        System.assertEquals(0, checkContacts.size());

        // AND the error has been saved in a Debug Message
        Debug_Parent__c[] dp = [SELECT Id FROM Debug_Parent__c WHERE Message_Type__c = :tdi.debugMessageType];
        System.assertEquals(1, dp.size());
        Id parentId = dp[0].Id;
        Debug_Message__c[] dm = [SELECT Message__c FROM Debug_Message__c WHERE Debug_Parent__c = :parentId];
        System.assertEquals(1, dm.size());
        System.assertEquals(true, dm[0].Message__c.startsWith(String.valueOf(StatusCode.REQUIRED_FIELD_MISSING)));
    }

    @IsTest
    static void testInsertSingleContactWithJsonOverride() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND we override the Json data for a Contact
        Contact altContact = new Contact(LastName='Alternative',Department='Override');
        tdi.overrideJson.put(Contact.class, JSON.serialize(altContact));

        // WHEN using the tdi to insert a contact
        Test.startTest();
        Contact newContact = tdi.insertContact(null, null);
        Test.stopTest();

        // THEN the contact will exist as per the overridden Json data
        Contact[] checkContacts = [SELECT Id, LastName, Department FROM Contact];
        System.assertEquals(1, checkContacts.size());
        System.assertEquals(newContact.Id, checkContacts[0].Id);
        System.assertEquals(altContact.LastName, checkContacts[0].LastName);
        System.assertEquals(altContact.Department, checkContacts[0].Department);
    }

    @IsTest
    static void testInsertSingleOpportunitySimple() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND the TestDataJsonLibrary entry for an Opportunity
        String oppJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_OPPORTUNITY);
        System.assert(String.isNotBlank(oppJson));

        // WHEN using the tdi to insert an opportunity
        Test.startTest();
        Opportunity newOpp = tdi.insertOpportunity(null, null);
        Test.stopTest();

        // THEN the opportunity will exist
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(oppJson);
        Opportunity[] checkOpps = [SELECT Id, Name, StageName, ContractID__c FROM Opportunity];
        System.assertEquals(1, checkOpps.size());

        // AND the field values will be set as expected
        System.assertEquals(newOpp.Id, checkOpps[0].Id);
        System.assertEquals(libraryData.get('Name'), checkOpps[0].Name);
        System.assertEquals(libraryData.get('StageName'), checkOpps[0].StageName);
        System.assertEquals(libraryData.get('ContractID__c'), checkOpps[0].ContractID__c);
    }

    @IsTest
    static void testInsertSingleOpportunityWithFieldUpdates() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND the TestDataJsonLibrary entry for an Opportunity
        String oppJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_OPPORTUNITY);
        System.assert(String.isNotBlank(oppJson));

        // WHEN using the tdi to insert an opportunity with additional field values
        Test.startTest();
            Map<String, Object> setFields = new Map<String, Object>{
                    'Name' => 'Alt Opp - Name',
                    'Deal_Type__c' => 'New Name Customer'
            };
            Opportunity newOpp = tdi.insertOpportunity(setFields, null);
        Test.stopTest();

        // THEN the opportunity will exist
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(oppJson);
        Opportunity[] checkOpps = [SELECT Id, Name, Deal_Type__c, ContractID__c FROM Opportunity];
        System.assertEquals(1, checkOpps.size());

        // AND the field values will be set as expected
        System.assertEquals(newOpp.Id, checkOpps[0].Id);
        System.assertEquals(setFields.get('Name'), checkOpps[0].Name);
        System.assertEquals(setFields.get('Deal_Type__c'), checkOpps[0].Deal_Type__c);
        System.assertEquals(libraryData.get('ContractID__c'), checkOpps[0].ContractID__c);
    }

    @IsTest
    static void testInsertSingleOpportunityWithJsonOverride() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND we override the Json data for an Opportunity
        Opportunity altOpp = new Opportunity(
                Name = 'New - Alternative',
                StageName = '1. Plan',
                CloseDate = System.today()+14,
                ContractID__c = 'ALT-1234'
        );
        tdi.overrideJson.put(Opportunity.class, JSON.serialize(altOpp));

        // WHEN using the tdi to insert a contact
        Test.startTest();
        Opportunity newOpp = tdi.insertOpportunity(null, null);
        Test.stopTest();

        // THEN the contact will exist as per the overridden Json data
        Opportunity[] checkOpps = [SELECT Id, Name, StageName, CloseDate, ContractID__c FROM Opportunity];
        System.assertEquals(1, checkOpps.size());
        System.assertEquals(newOpp.Id, checkOpps[0].Id);
        System.assertEquals(altOpp.Name, checkOpps[0].Name);
        System.assertEquals(altOpp.StageName, checkOpps[0].StageName);
        System.assertEquals(altOpp.CloseDate, checkOpps[0].CloseDate);
        System.assertEquals(altOpp.ContractID__c, checkOpps[0].ContractID__c);
    }

    @IsTest
    static void testInsertSingleOpportunityWithErrors() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND a list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN using the tdi to insert an Opportunity with invalid fields
        Test.startTest();
        Map<String, Object> setFields = new Map<String, Object>{
                'Name' => null // invalid
        };
        Opportunity newOpp = tdi.insertOpportunity(setFields, dbErrors);
        Test.stopTest();

        // THEN the account will not exist
        System.assertEquals(null, newOpp.Id);

        // AND the error list will include the error
        System.assertEquals(1, dbErrors.size());
        System.assertEquals(false, dbErrors[0].success);
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, dbErrors[0].errors[0].statusCode);
    }

    @IsTest
    static void testInsertSingleLeadSimple() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND the TestDataJsonLibrary entry for a Lead
        String leadJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_LEAD);
        System.assert(String.isNotBlank(leadJson));

        // WHEN using the tdi to insert a lead
        Test.startTest();
        Lead newLead = tdi.insertLead(null, null);
        Test.stopTest();

        // THEN the lead will exist
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(leadJson);
        Lead[] checkLeads = [SELECT Id, Company, LastName, Salutation FROM Lead];
        System.assertEquals(1, checkLeads.size());

        // AND the field values will be set as expected
        System.assertEquals(newLead.Id, checkLeads[0].Id);
        System.assertEquals(libraryData.get('Company'), checkLeads[0].Company);
        System.assertEquals(libraryData.get('LastName'), checkLeads[0].LastName);
        System.assertEquals(libraryData.get('Salutation'), checkLeads[0].Salutation);
    }

    @IsTest
    static void testInsertSingleUserSimple() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND the TestDataJsonLibrary entry for a User
        String userJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_USER);
        System.assert(String.isNotBlank(userJson));

        // WHEN using the tdi to insert a user
        Test.startTest();
        User newUser = tdi.insertUser('Standard User', 'any', null, null);
        Test.stopTest();

        // THEN the user will exist
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(userJson);
        User[] checkUsers = [SELECT Id, Alias, Email, TimeZoneSidKey, Profile.Name FROM User WHERE Id = :newUser.Id];
        System.assertEquals(1, checkUsers.size());

        // AND the field values will be set as expected
        System.assertEquals(newUser.Id, checkUsers[0].Id);
        System.assertEquals('any', checkUsers[0].Alias);
        System.assertEquals('any.test@test.test', checkUsers[0].Email);
        System.assertEquals(libraryData.get('TimeZoneSidKey'), checkUsers[0].TimeZoneSidKey);
        System.assertEquals('Standard User', checkUsers[0].Profile.Name);
    }

    @IsTest
    static void testInsertSingleOLISimple() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND the TestDataJsonLibrary entry for an Opportunity Line Item
        String oliJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_OPP_LINE_ITEM);
        System.assert(String.isNotBlank(oliJson));

        // AND a Product and Pricebook exist
        String PRODUCT_FAMILY = 'FAM';
        Product2 testProduct = new Product2(Name = 'Test Product', Family = PRODUCT_FAMILY);
        insert testProduct;
        Id stdPbId = Test.getStandardPricebookId();
        PricebookEntry testPrice = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = testProduct.Id,
                UnitPrice = 100.00, CurrencyIsoCode = 'GBP', IsActive = true, UseStandardPrice = false);
        insert testPrice;

        // WHEN using the tdi to insert an Opportunity Line Item
        Test.startTest();
            Opportunity newOpp = tdi.insertOpportunity(null, null);
            OpportunityLineItem newOli = tdi.insertOpportunityLineItem(newOpp, PRODUCT_FAMILY, null, null);
        Test.stopTest();

        // THEN the product will exist
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(oliJson);
        OpportunityLineItem[] checkOlis = [SELECT Id, Quantity, TotalPrice FROM OpportunityLineItem];
        System.assertEquals(1, checkOlis.size());

        // AND the field values will be set as expected
        System.assertEquals(newOli.Id, checkOlis[0].Id);
        System.assertEquals(libraryData.get('Quantity'), checkOlis[0].Quantity);
        System.assertEquals(libraryData.get('TotalPrice'), checkOlis[0].TotalPrice);
    }

    @IsTest
    static void testInsertSingleProductSimple() {
        // GIVEN the TestDataInsert class
        TestDataInsert tdi = new TestDataInsert();

        // AND the TestDataJsonLibrary entry for a Product
        String prdJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_PRODUCT);
        System.assert(String.isNotBlank(prdJson));

        // WHEN using the tdi to insert a product
        Test.startTest();
        Product2 newProduct = tdi.insertProduct(null, null);
        Test.stopTest();

        // THEN the product will exist
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(prdJson);
        Product2[] checkProds = [SELECT Id, Name, Asset_Name__c, UPID__c FROM Product2];
        System.assertEquals(1, checkProds.size());

        // AND the field values will be set as expected
        System.assertEquals(newProduct.Id, checkProds[0].Id);
        System.assertEquals(libraryData.get('Name'), checkProds[0].Name);
        System.assertEquals(libraryData.get('Asset_Name__c'), checkProds[0].Asset_Name__c);
        System.assertEquals(libraryData.get('UPID__c'), checkProds[0].UPID__c);
    }

}