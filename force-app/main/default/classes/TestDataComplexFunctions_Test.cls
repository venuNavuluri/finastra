@IsTest
private class TestDataComplexFunctions_Test {

    @IsTest
    static void testInsertAccountAndContactSimple() {
        // GIVEN the TestDataComplexFunctions class
        TestDataComplexFunctions tdc = new TestDataComplexFunctions();

        // WHEN creating an Account and Contact with defaults
        Test.startTest();
        Account resultAccount = tdc.insertAccountAndContact(null, null);
        Test.stopTest();

        // THEN the resulting Account and Contact will be created
        Account[] accounts = [SELECT Id FROM Account];
        System.assertEquals(1, accounts.size());
        Id accountId = accounts[0].Id;
        Contact[] contacts = [SELECT Id FROM Contact WHERE AccountId = :accountId];
        System.assertEquals(1, contacts.size());
        Id contactId = contacts[0].Id;

        // AND these are available from the class
        System.assertEquals(accountId, resultAccount.Id);
        System.assertEquals(accountId, tdc.newAccount.Id);
        System.assertEquals(contactId, tdc.newContact.Id);
    }

    @IsTest
    static void testInsertAccountAndContactOverrideAccount() {
        // GIVEN the TestDataComplexFunctions class
        TestDataComplexFunctions tdc = new TestDataComplexFunctions();

        // AND Account field values are specified
        Map<System.Type, Map<String, Object>> fieldValues = new Map<System.Type, Map<String, Object>>{
                Account.class => new Map<String, Object>{ 'Name' => 'Override-Account' }
        };
        // WHEN creating an Account and Contact
        Test.startTest();
        Account resultAccount = tdc.insertAccountAndContact(fieldValues, null);
        Test.stopTest();

        // THEN the resulting Account and Contact will be created
        Account[] accounts = [SELECT Id, Name FROM Account];
        System.assertEquals(1, accounts.size());
        Id accountId = accounts[0].Id;
        Contact[] contacts = [SELECT Id FROM Contact WHERE AccountId = :accountId];
        System.assertEquals(1, contacts.size());

        // AND the Account field values will have been set
        System.assertEquals('Override-Account', accounts[0].Name);
    }

    @IsTest
    static void testInsertAccountAndContactOverrideContact() {
        // GIVEN the TestDataComplexFunctions class
        TestDataComplexFunctions tdc = new TestDataComplexFunctions();

        // AND Contact field values are specified
        Map<System.Type, Map<String, Object>> fieldValues = new Map<System.Type, Map<String, Object>>{
                Contact.class => new Map<String, Object>{ 'LastName' => 'Override-Contact' }
        };
        // WHEN creating an Account and Contact
        Test.startTest();
        Account resultAccount = tdc.insertAccountAndContact(fieldValues, null);
        Test.stopTest();

        // THEN the resulting Account and Contact will be created
        Account[] accounts = [SELECT Id FROM Account];
        System.assertEquals(1, accounts.size());
        Id accountId = accounts[0].Id;
        Contact[] contacts = [SELECT Id, LastName FROM Contact WHERE AccountId = :accountId];
        System.assertEquals(1, contacts.size());

        // AND the Contact field values will have been set
        System.assertEquals('Override-Contact', contacts[0].LastName);
    }

    @IsTest
    static void testInsertAccountAndContactOverrideBoth() {
        // GIVEN the TestDataComplexFunctions class
        TestDataComplexFunctions tdc = new TestDataComplexFunctions();

        // AND both Account and Contact field values are specified
        Map<System.Type, Map<String, Object>> fieldValues = new Map<System.Type, Map<String, Object>>{
                Account.class => new Map<String, Object>{ 'Name' => 'Override-Account' },
                Contact.class => new Map<String, Object>{ 'LastName' => 'Override-Contact' }
        };
        // WHEN creating an Account and Contact
        Test.startTest();
        Account resultAccount = tdc.insertAccountAndContact(fieldValues, null);
        Test.stopTest();

        // THEN the resulting Account and Contact will be created
        Account[] accounts = [SELECT Id, Name FROM Account];
        System.assertEquals(1, accounts.size());
        Id accountId = accounts[0].Id;
        Contact[] contacts = [SELECT Id, LastName FROM Contact WHERE AccountId = :accountId];
        System.assertEquals(1, contacts.size());

        // AND the Account field values will have been set
        System.assertEquals('Override-Account', accounts[0].Name);
        System.assertEquals('Override-Contact', contacts[0].LastName);
    }

}