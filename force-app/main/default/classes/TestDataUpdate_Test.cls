@IsTest
private class TestDataUpdate_Test {

    @IsTest
    static void updateAnyObjectSimple() {
        // GIVEN an existing SObject record
        Debug_Parent__c dp = new Debug_Parent__c(Message_Type__c = 'Existing', Source__c = 'Test');
        insert dp;
        dp.Message_Type__c = 'Updated';

        // WHEN performing the update using TestDataUpdate
        Test.startTest();
        TestDataUpdate tdu = new TestDataUpdate();
        SObject sObj = tdu.updateAnyObject(dp, null, null);
        Test.stopTest();

        // THEN the SObject record has been updated in the database
        Debug_Parent__c[] checkDp = [SELECT Id, Message_Type__c, Source__c FROM Debug_Parent__c];
        System.assertEquals(1, checkDp.size());
        System.assertEquals(sObj.Id, checkDp[0].Id);
        System.assertEquals('Updated', checkDp[0].Message_Type__c);
        System.assertEquals('Test', checkDp[0].Source__c);
    }

    @IsTest
    static void updateAnyObjectWithFieldUpdates() {
        // GIVEN an existing SObject record
        Debug_Parent__c dp = new Debug_Parent__c(Message_Type__c = 'Existing');
        insert dp;

        // AND there are some field changes to be made
        Map<String, Object> updateFields = new Map<String, Object> {
                'Message_Type__c' => 'New Value',
                'Source__c' => 'TestDataUpdate_Test'
        };

        // WHEN performing the update using TestDataUpdate
        Test.startTest();
        TestDataUpdate tdu = new TestDataUpdate();
        SObject sObj = tdu.updateAnyObject(dp, updateFields, null);
        Test.stopTest();

        // THEN the SObject record has been updated in the database
        Debug_Parent__c[] checkDp = [SELECT Id, Message_Type__c, Source__c FROM Debug_Parent__c];
        System.assertEquals(1, checkDp.size());
        System.assertEquals(sObj.Id, checkDp[0].Id);
        System.assertEquals(updateFields.get('Message_Type__c'), checkDp[0].Message_Type__c);
        System.assertEquals(updateFields.get('Source__c'), checkDp[0].Source__c);
    }

    @IsTest
    static void updateSingleAccountNoFieldUpdates() {
        // GIVEN an existing Account record with an update
        Account acc = new Account(Name = 'Existing');
        insert acc;
        acc.Name = 'Updated';

        // WHEN performing an update using TestDataUpdate without specifying any further updates
        Test.startTest();
        TestDataUpdate tdu = new TestDataUpdate();
        acc = tdu.updateAccount(acc, null, null);
        Test.stopTest();

        // THEN the account has been updated
        Account[] checkAccounts = [SELECT Id, Name FROM Account];
        System.assertEquals(1, checkAccounts.size());
        System.assertEquals(acc.Id, checkAccounts[0].Id);
        System.assertEquals('Updated', checkAccounts[0].Name);
    }

    @IsTest
    static void updateSingleAccountWithFieldUpdates() {
        // GIVEN an existing Account record
        Account acc = new Account(Name = 'Existing');
        insert acc;

        // AND there are some field changes to be made
        Map<String, Object> updateFields = new Map<String, Object> {
                'Name' => 'New Name',
                'AccountNumber' => 'NEW-12345'
        };

        // WHEN performing the update using TestDataUpdate
        Test.startTest();
        TestDataUpdate tdu = new TestDataUpdate();
        acc = tdu.updateAccount(acc, updateFields, null);
        Test.stopTest();

        // THEN the Account record has been updated
        System.assertEquals(updateFields.get('Name'), acc.Name);
        System.assertEquals(updateFields.get('AccountNumber'), acc.AccountNumber);

        // AND is committed to the database
        Account[] checkAccounts = [SELECT Id, Name, AccountNumber FROM Account];
        System.assertEquals(1, checkAccounts.size());
        System.assertEquals(acc.Id, checkAccounts[0].Id);
        System.assertEquals(updateFields.get('Name'), checkAccounts[0].Name);
        System.assertEquals(updateFields.get('AccountNumber'), checkAccounts[0].AccountNumber);
    }

    @IsTest
    static void updateSingleAccountNullAccount() {
        // GIVEN a null account
        Account nullAccount = null;

        // AND there are some field changes to be made
        Map<String, Object> updateFields = new Map<String, Object> {
                'Name' => 'New Name',
                'AccountNumber' => 'NEW-12345'
        };

        // WHEN performing the update using TestDataUpdate
        Test.startTest();
        Boolean exceptionOccurred = false;
        try {
            TestDataUpdate tdu = new TestDataUpdate();
            Account resultAcc = tdu.updateAccount(nullAccount, updateFields, null);
        }
        catch(UtilsDML.UtilsDMLException ex) {
            exceptionOccurred = true;
        }
        Test.stopTest();

        // THEN an exception will occur
        System.assertEquals(true, exceptionOccurred);

        // AND nothing is committed to the database
        Account[] checkAccounts = [SELECT Id FROM Account];
        System.assertEquals(0, checkAccounts.size());
    }

    @IsTest
    static void updateSingleAccountWithErrors() {
        // GIVEN an existing Account record
        Account acc = new Account(Name = 'Existing');
        insert acc;

        // AND there are some invalid field changes to be made
        Map<String, Object> updateFields = new Map<String, Object> {
                'Name' => null
        };

        // AND a list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN performing the update using TestDataUpdate
        Test.startTest();
        TestDataUpdate tdu = new TestDataUpdate();
        acc = tdu.updateAccount(acc, updateFields, dbErrors);
        Test.stopTest();

        // THEN the Account record has not been updated
        Account[] checkAccounts = [SELECT Id, Name FROM Account];
        System.assertEquals(1, checkAccounts.size());
        System.assertEquals(acc.Id, checkAccounts[0].Id);
        System.assertEquals('Existing', checkAccounts[0].Name);

        // AND the error list will include the error
        System.assertEquals(1, dbErrors.size());
        System.assertEquals(false, dbErrors[0].success);
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, dbErrors[0].errors[0].statusCode);
    }

    @IsTest
    static void updateSingleAccountWithSaveErrors() {
        // GIVEN an existing Account record
        Account acc = new Account(Name = 'Existing');
        insert acc;

        // AND there are some invalid field changes to be made
        Map<String, Object> updateFields = new Map<String, Object> {
                'Name' => null
        };

        // AND a list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // AND configured to save errors
        TestDataUpdate tdu = new TestDataUpdate();
        tdu.saveErrors = true;
        tdu.debugMessageType = 'Test Save Errors';

        // AND Monitoring is set up to record these messages
        insert new Monitoring__c( Name = tdu.debugMessageType, Active__c = true );

        // WHEN performing the update using TestDataUpdate
        Test.startTest();
        acc = tdu.updateAccount(acc, updateFields, dbErrors);
        Test.stopTest();

        // THEN the Account record has not been updated
        Account[] checkAccounts = [SELECT Id, Name FROM Account];
        System.assertEquals(1, checkAccounts.size());
        System.assertEquals(acc.Id, checkAccounts[0].Id);
        System.assertEquals('Existing', checkAccounts[0].Name);

        // AND the error is saved in a Debug Message
        Debug_Parent__c[] dp = [SELECT Id, Message_Type__c FROM Debug_Parent__c];
        System.assertEquals(1, dp.size());
        System.assertEquals(tdu.debugMessageType, dp[0].Message_Type__c);
        Id parentId = dp[0].Id;
        Debug_Message__c[] dm = [SELECT Id, Message__c FROM Debug_Message__c WHERE Debug_Parent__c = :parentId];
        System.assertEquals(1, dm.size());
        System.assertEquals(true, dm[0].Message__c.startsWith(String.valueOf(StatusCode.REQUIRED_FIELD_MISSING)));
    }

    @IsTest
    static void insertAndUpdateSingleAccount() {
        // GIVEN the TestDataJsonLibrary entry for an Account
        String accountJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_ACCOUNT);
        System.assert(String.isNotBlank(accountJson));

        // AND there are some initial field values
        Map<String, Object> insertFields = new Map<String, Object> {
                'AccountNumber' => 'IN-12345',
                'Budget__c' => 1000.00
        };

        // AND there are some field changes to be made
        Map<String, Object> updateFields = new Map<String, Object> {
                'AccountNumber' => 'UP-12345'
        };

        // WHEN performing and insert and update using TestDataUpdate
        Test.startTest();
        TestDataUpdate tdu = new TestDataUpdate();
        Account acc = tdu.insertAndUpdateAccount(insertFields, updateFields, null);
        Test.stopTest();

        // THEN the Account record has been updated
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(accountJson);
        System.assertEquals(libraryData.get('Name'), acc.Name);
        System.assertEquals(updateFields.get('AccountNumber'), acc.AccountNumber);
        System.assertEquals(insertFields.get('Budget__c'), acc.Budget__c);

        // AND is committed to the database
        Account[] checkAccounts = [SELECT Id, Name, AccountNumber, Budget__c FROM Account];
        System.assertEquals(1, checkAccounts.size());
        System.assertEquals(acc.Id, checkAccounts[0].Id);
        System.assertEquals(libraryData.get('Name'), checkAccounts[0].Name);
        System.assertEquals(updateFields.get('AccountNumber'), checkAccounts[0].AccountNumber);
        System.assertEquals(insertFields.get('Budget__c'), checkAccounts[0].Budget__c);
    }

    @IsTest
    static void insertAndUpdateSingleAccountWithInsertErrors() {
        // GIVEN an invalid insert fields
        Map<String, Object> insertFields = new Map<String, Object> { 'Name' => null };

        // AND valid update fields
        Map<String, Object> updateFields = new Map<String, Object> { 'AccountNumber' => 'ACC-123' };

        // AND a list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN performing and insert and update using TestDataUpdate
        Test.startTest();
        TestDataUpdate tdu = new TestDataUpdate();
        Account acc = tdu.insertAndUpdateAccount(insertFields, updateFields, dbErrors);
        Test.stopTest();

        // THEN the Account record will not exist
        Account[] checkAccounts = [SELECT Id, Name, AccountNumber FROM Account];
        System.assertEquals(0, checkAccounts.size());

        // AND the error list will include errors for both the insert and the update
        System.assertEquals(2, dbErrors.size());
        System.assertEquals(false, dbErrors[0].success);
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, dbErrors[0].errors[0].statusCode);
        System.assertEquals(false, dbErrors[1].success);
        System.assertEquals(StatusCode.MISSING_ARGUMENT, dbErrors[1].errors[0].statusCode);
    }

    @IsTest
    static void insertAndUpdateSingleAccountWithUpdateErrors() {
        // GIVEN a valid insert fields
        Map<String, Object> insertFields = new Map<String, Object> { 'AccountNumber' => 'ACC-123' };

        // AND invalid update fields
        Map<String, Object> updateFields = new Map<String, Object> { 'Name' => null };

        // AND a list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN performing and insert and update using TestDataUpdate
        Test.startTest();
        TestDataUpdate tdu = new TestDataUpdate();
        Account acc = tdu.insertAndUpdateAccount(insertFields, updateFields, dbErrors);
        Test.stopTest();

        // THEN the Account record will exist a inserted but without the invalid update
        Account[] checkAccounts = [SELECT Id, Name, AccountNumber FROM Account];
        System.assertEquals(1, checkAccounts.size());
        System.assertEquals(insertFields.get('AccountNumber'), checkAccounts[0].AccountNumber);
        System.assertNotEquals(null, checkAccounts[0].Name);

        // AND the error list will include errors for just the update
        System.assertEquals(1, dbErrors.size());
        System.assertEquals(false, dbErrors[0].success);
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, dbErrors[0].errors[0].statusCode);
    }

    @IsTest
    static void updateSingleOpportunityNoFields() {
        // GIVEN an existing Account record to update
        Opportunity opp = new Opportunity(Name = 'Opp - Existing', StageName = 'Suspect', CloseDate = System.today()+7);
        insert opp;
        opp.Name = 'Opp - Newname';

        // WHEN performing the update using TestDataUpdate
        Test.startTest();
            TestDataUpdate tdu = new TestDataUpdate();
            opp = tdu.updateOpportunity(opp, null, null);
        Test.stopTest();

        // THEN the Opportunity record has been updated
        Opportunity[] checkOpps = [SELECT Id, Name, StageName, CloseDate FROM Opportunity];
        System.assertEquals(1, checkOpps.size());
        System.assertEquals(opp.Id, checkOpps[0].Id);
        System.assertEquals('Opp - Newname', checkOpps[0].Name);
    }

    @IsTest
    static void updateSingleOpportunityWithFieldUpdates() {
        // GIVEN an existing Account record
        Opportunity opp = new Opportunity(Name = 'Opp - Existing', StageName = 'Suspect', CloseDate = System.today()+7);
        insert opp;

        // AND there are some field changes to be made
        Map<String, Object> updateFields = new Map<String, Object> {
                'StageName' => '1. Prospect',
                'Misys_Forecast__c' => 'Exempt'
        };

        // WHEN performing the update using TestDataUpdate
        Test.startTest();
        TestDataUpdate tdu = new TestDataUpdate();
        opp = tdu.updateOpportunity(opp, updateFields, null);
        Test.stopTest();

        // THEN the Opportunity record has been updated
        Opportunity[] checkOpps = [SELECT Id, Name, StageName, Misys_Forecast__c FROM Opportunity];
        System.assertEquals(1, checkOpps.size());
        System.assertEquals(opp.Id, checkOpps[0].Id);
        System.assertEquals('Opp - Existing', checkOpps[0].Name);
        System.assertEquals(updateFields.get('StageName'), checkOpps[0].StageName);
        System.assertEquals(updateFields.get('Misys_Forecast__c'), checkOpps[0].Misys_Forecast__c);
    }

    @IsTest
    static void updateSingleOpportunityWithErrors() {
        // GIVEN an existing Account record
        Opportunity opp = new Opportunity(Name = 'Opp - Existing', StageName = 'Suspect', CloseDate = System.today()+7);
        insert opp;

        // AND there are some invalid field changes to be made
        Map<String, Object> updateFields = new Map<String, Object> { 'Name' => null };

        // AND a list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN performing the update using TestDataUpdate
        Test.startTest();
        TestDataUpdate tdu = new TestDataUpdate();
        opp = tdu.updateOpportunity(opp, updateFields, dbErrors);
        Test.stopTest();

        // THEN the Opportunity record has not been updated
        Opportunity[] checkOpps = [SELECT Id, Name, StageName, CloseDate FROM Opportunity];
        System.assertEquals(1, checkOpps.size());
        System.assertEquals(opp.Id, checkOpps[0].Id);
        System.assertEquals('Opp - Existing', checkOpps[0].Name);

        // AND the error list will include errors for just the update
        System.assertEquals(1, dbErrors.size());
        System.assertEquals(false, dbErrors[0].success);
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, dbErrors[0].errors[0].statusCode);
    }

    @IsTest
    static void insertAndUpdateSingleOpportunity() {
        // GIVEN the TestDataJsonLibrary entry for an Opportunity
        String oppJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_OPPORTUNITY);
        System.assert(String.isNotBlank(oppJson));

        // AND there are some initial field values
        Map<String, Object> insertFields = new Map<String, Object> {
                'StageName' => '2. Create',
                'ContractID__c' => 'A-9876'
        };

        // AND there are some field changes to be made
        Map<String, Object> updateFields = new Map<String, Object> {
                'StageName' => '5. Prove'
        };

        // WHEN performing and insert and update using TestDataUpdate
        Test.startTest();
            TestDataUpdate tdu = new TestDataUpdate();
            Opportunity opp = tdu.insertAndUpdateOpportunity(insertFields, updateFields, null);
        Test.stopTest();

        // THEN the Opportunity has been updated in the database
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(oppJson);
        Opportunity[] checkOpps = [SELECT Id, Name, StageName, ContractID__c FROM Opportunity];
        System.assertEquals(1, checkOpps.size());
        System.assertEquals(opp.Id, checkOpps[0].Id);
        System.assertEquals(libraryData.get('Name'), checkOpps[0].Name);
        System.assertEquals(updateFields.get('StageName'), checkOpps[0].StageName);
        System.assertEquals(insertFields.get('ContractID__c'), checkOpps[0].ContractID__c);
    }

    @IsTest
    static void insertAndUpdateSingleOpportunityWithErrors() {
        // GIVEN an invalid field update to be made to a standard Opportunity
        Map<String, Object> updateFields = new Map<String, Object> { 'Name' => null };

        // AND a list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN performing and insert and update using TestDataUpdate
        Test.startTest();
        TestDataUpdate tdu = new TestDataUpdate();
        Opportunity opp = tdu.insertAndUpdateOpportunity(null, updateFields, dbErrors);
        Test.stopTest();

        // THEN the Opportunity has been created in the database
        String libraryOppJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_OPPORTUNITY);
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(libraryOppJson);
        Opportunity[] checkOpps = [SELECT Id, Name, StageName, ContractID__c FROM Opportunity];
        System.assertEquals(1, checkOpps.size());
        System.assertEquals(opp.Id, checkOpps[0].Id);
        System.assertEquals(libraryData.get('Name'), checkOpps[0].Name);
    }
}