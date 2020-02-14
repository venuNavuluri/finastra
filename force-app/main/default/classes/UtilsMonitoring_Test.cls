@IsTest
private class UtilsMonitoring_Test {

    static Datetime PAST_START   = Datetime.now().addMinutes(-40);
    static Datetime PAST_END     = Datetime.now().addMinutes(-30);
    static Datetime FUTURE_START = Datetime.now().addMinutes(+30);
    static Datetime FUTURE_END   = Datetime.now().addMinutes(+40);

    @IsTest
    static void errorMessageClassSimple() {
        // GIVEN an error message
        String testMessage = 'Test Message 1';

        // WHEN we instantiate an ErrorMessage object
        Test.startTest();
        UtilsMonitoring.ErrorMessage em = new UtilsMonitoring.ErrorMessage(testMessage, null);
        Test.stopTest();

        // THEN the ErrorMessage attributes are populated accordingly
        System.assertEquals(testMessage, em.msg);
        System.assertEquals(null, em.additionalFields);
    }

    @IsTest
    static void errorMessageClass() {
        // GIVEN an error message
        String testMessage = 'Test Message 1';

        // AND some associated field values
        Map<String, Object> testFields = new Map<String, Object> {
                'field1' => 'Value1',
                'field2' => 123
        };

        // WHEN we instantiate an ErrorMessage object
        Test.startTest();
        UtilsMonitoring.ErrorMessage em = new UtilsMonitoring.ErrorMessage(testMessage, testFields);
        Test.stopTest();

        // THEN the ErrorMessage attributes are populated accordingly
        System.assertEquals(testMessage, em.msg);
        System.assertEquals(testFields.get('field1'), em.additionalFields.get('field1'));
        System.assertEquals(testFields.get('field2'), em.additionalFields.get('field2'));
    }

    @IsTest
    static void getMonitoringCoverageIsFalse() {
        // GIVEN no Monitoring Coverage settings
        // WHEN calling getMonitoringCoverage()
        // THEN result should be False
        Test.startTest();
        System.assertEquals(false, UtilsMonitoring.getMonitoringCoverage());
        Test.stopTest();
    }

    @IsTest
    static void getMonitoringCoverageIsTrueForOrg() {
        // GIVEN Monitoring Coverage is enabled for Org
        insert new MonitoringCoverage__c(SetupOwnerId=UserInfo.getOrganizationId(), Enable__c=true);

        // WHEN calling getMonitoringCoverage()
        // THEN result should be True
        Test.startTest();
        System.assertEquals(true, UtilsMonitoring.getMonitoringCoverage());
        Test.stopTest();
    }

    @IsTest
    static void getMonitoringCoverageIsTrueForProfile() {
        // GIVEN Monitoring Coverage is enabled for Profile
        insert new MonitoringCoverage__c(SetupOwnerId=UserInfo.getProfileId(), Enable__c=true);

        // WHEN calling getMonitoringCoverage()
        // THEN result should be True
        Test.startTest();
        System.assertEquals(true, UtilsMonitoring.getMonitoringCoverage());
        Test.stopTest();
    }

    @IsTest
    static void getMonitoringCoverageIsTrueForUser() {
        // GIVEN Monitoring Coverage is enabled for User
        insert new MonitoringCoverage__c(SetupOwnerId=UserInfo.getUserId(), Enable__c=true);

        // WHEN calling getMonitoringCoverage()
        // THEN result should be True
        Test.startTest();
        System.assertEquals(true, UtilsMonitoring.getMonitoringCoverage());
        Test.stopTest();
    }

    @IsTest
    static void getMonitoringCoverageIsFalseForAnotherProfile() {
        // GIVEN two users with different profiles
        User user1 = TestUtils.getStandardInternalUser('User1');
        User user2 = TestUtils.getAdminUser('User2');
        insert new List<User> { user1, user2 };

        // AND running as User 1
        System.runAs(user1) {

            // AND Monitoring Coverage is granted to User 2's profile
            insert new MonitoringCoverage__c(SetupOwnerId=user2.ProfileId, Enable__c=true);

            // WHEN calling getMonitoringCoverage()
            // THEN result should be False
            Test.startTest();
            System.assertEquals(false, UtilsMonitoring.getMonitoringCoverage());
            Test.stopTest();
        }

    }

    @IsTest
    static void setupMonitoringWithNoSettings() {
        // GIVEN there are no Monitoring settings
        // WHEN calling setupMonitoring()
        Test.startTest();
        UtilsMonitoring.setupMonitoring();
        Test.stopTest();

        // THEN monitorSet should be Null
        System.assertEquals(null, UtilsMonitoring.monitorSet);

        // AND saveMonitoringMessagesMap will be initialised
        System.assertNotEquals(null, UtilsMonitoring.saveMonitoringMessagesMap);
        System.assertEquals(0, UtilsMonitoring.saveMonitoringMessagesMap.size());
    }

    @IsTest
    static void setupMonitoringWithActiveSettings() {
        // GIVEN there are some Monitoring settings with active values
        insert new Monitoring__c( Name = 'Test1', Active__c = true );
        insert new Monitoring__c( Name = 'Test2', Active__c = true,
                Monitor_Datetime_From__c = PAST_START, Monitor_Datetime_To__c = FUTURE_END );

        // WHEN calling setupMonitoring()
        Test.startTest();
        UtilsMonitoring.setupMonitoring();
        Test.stopTest();

        // THEN monitorSet will contain all active settings
        System.assertEquals(2, UtilsMonitoring.monitorSet.size());

        // AND saveMonitoringMessagesMap will be initialised
        System.assertNotEquals(null, UtilsMonitoring.saveMonitoringMessagesMap);
        System.assertEquals(0, UtilsMonitoring.saveMonitoringMessagesMap.size());
    }

    @IsTest
    static void setupMonitoringWithInactiveSettings() {
        // GIVEN there are some Monitoring settings with inactive values
        insert new Monitoring__c( Name = 'Test1', Active__c = false );
        insert new Monitoring__c( Name = 'Test2', Active__c = true,
                Monitor_Datetime_From__c = PAST_START, Monitor_Datetime_To__c = PAST_END );
        insert new Monitoring__c( Name = 'Test3', Active__c = true,
                Monitor_Datetime_From__c = FUTURE_START, Monitor_Datetime_To__c = FUTURE_END );

        // WHEN calling setupMonitoring()
        Test.startTest();
        UtilsMonitoring.setupMonitoring();
        Test.stopTest();

        // THEN monitorSet will be empty
        System.assertEquals(0, UtilsMonitoring.monitorSet.size());

        // AND saveMonitoringMessagesMap will be initialised
        System.assertNotEquals(null, UtilsMonitoring.saveMonitoringMessagesMap);
        System.assertEquals(0, UtilsMonitoring.saveMonitoringMessagesMap.size());
    }

    @IsTest
    static void setupMonitoringWithMixedSettings() {
        // GIVEN there are some Monitoring settings with 2 active values
        insert new Monitoring__c( Name = 'Test1', Active__c = true );
        insert new Monitoring__c( Name = 'Test2', Active__c = true,
                Monitor_Datetime_From__c = PAST_START, Monitor_Datetime_To__c = FUTURE_END );

        // AND 3 inactive values
        insert new Monitoring__c( Name = 'Test3', Active__c = true,
                Monitor_Datetime_From__c = FUTURE_START, Monitor_Datetime_To__c = FUTURE_END );
        insert new Monitoring__c( Name = 'Test4', Active__c = false );
        insert new Monitoring__c( Name = 'Test5', Active__c = false,
                Monitor_Datetime_From__c = PAST_START, Monitor_Datetime_To__c = FUTURE_END );

        // WHEN calling setupMonitoring()
        Test.startTest();
        UtilsMonitoring.setupMonitoring();
        Test.stopTest();

        // THEN monitorSet will contain the correct settings
        System.assertEquals(2, UtilsMonitoring.monitorSet.size());
        System.assert(UtilsMonitoring.monitorSet.contains('Test1'));
        System.assert(UtilsMonitoring.monitorSet.contains('Test2'));

        // AND saveMonitoringMessagesMap will be initialised
        System.assertNotEquals(null, UtilsMonitoring.saveMonitoringMessagesMap);
        System.assertEquals(0, UtilsMonitoring.saveMonitoringMessagesMap.size());
    }

    @IsTest
    static void buildMonitoringMessageActiveSettings() {
        // GIVEN there are some Monitoring settings with active values
        insert new Monitoring__c( Name = 'Test1', Active__c = true );
        insert new Monitoring__c( Name = 'Test2', Active__c = true );
        insert new Monitoring__c( Name = 'Test3', Active__c = true );

        // AND monitoring has been set up
        UtilsMonitoring.setupMonitoring();

        // WHEN calling buildMonitoringMessage() multiple times with active types
        Test.startTest();
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test1', 'Message1.1', null);
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test2', 'Message2.1', null);
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test1', 'Message1.2', null);
        UtilsMonitoring.buildMonitoringMessage(UtilsMonitoring.class, 'Test3', 'Message3.1', null);
        Test.stopTest();

        // THEN the saveMonitoringMessagesMap should contain all the messages grouped accordingly
        System.assertEquals(2, UtilsMonitoring.saveMonitoringMessagesMap.size());

        Map<String, List<UtilsMonitoring.ErrorMessage>> accountClassMap = UtilsMonitoring.saveMonitoringMessagesMap.get(Account.class);
        System.assertEquals(2, accountClassMap.size()); // Test1 and Test2

        Map<String, List<UtilsMonitoring.ErrorMessage>> UtilsClassMap = UtilsMonitoring.saveMonitoringMessagesMap.get(UtilsMonitoring.class);
        System.assertEquals(1, UtilsClassMap.size()); // Test3

        List<UtilsMonitoring.ErrorMessage> test1Errors = accountClassMap.get('Test1');
        System.assertEquals(2, test1Errors.size());
        System.assert(test1Errors[0].msg == 'Message1.1');
        System.assert(test1Errors[1].msg == 'Message1.2');

        List<UtilsMonitoring.ErrorMessage> test2Errors = accountClassMap.get('Test2');
        System.assertEquals(1, test2Errors.size());
        System.assert(test2Errors[0].msg == 'Message2.1');

        List<UtilsMonitoring.ErrorMessage> test3Errors = UtilsClassMap.get('Test3');
        System.assertEquals(1, test3Errors.size());
        System.assert(test3Errors[0].msg == 'Message3.1');
    }

    @IsTest
    static void buildMonitoringMessageNullSource() {
        // GIVEN there are some Monitoring settings with active values
        insert new Monitoring__c( Name = 'Test1', Active__c = true );
        insert new Monitoring__c( Name = 'Test2', Active__c = true );

        // AND monitoring has been set up
        UtilsMonitoring.setupMonitoring();

        // WHEN calling buildMonitoringMessage() multiple times with Null source
        Test.startTest();
        UtilsMonitoring.buildMonitoringMessage(null, 'Test1', 'Message1.1', null);
        UtilsMonitoring.buildMonitoringMessage(null, 'Test2', 'Message2.1', null);
        Test.stopTest();

        // THEN the saveMonitoringMessagesMap should contain all the messages in the Null group
        System.assertEquals(1, UtilsMonitoring.saveMonitoringMessagesMap.size());

        Map<String, List<UtilsMonitoring.ErrorMessage>> accountClassMap = UtilsMonitoring.saveMonitoringMessagesMap.get(null);
        System.assertEquals(2, accountClassMap.size()); // Test1 and Test2

        List<UtilsMonitoring.ErrorMessage> test1Errors = accountClassMap.get('Test1');
        System.assertEquals(1, test1Errors.size());
        System.assert(test1Errors[0].msg == 'Message1.1');

        List<UtilsMonitoring.ErrorMessage> test2Errors = accountClassMap.get('Test2');
        System.assertEquals(1, test2Errors.size());
        System.assert(test2Errors[0].msg == 'Message2.1');
    }

    @IsTest
    static void buildMonitoringMessageInactiveSettings() {
        // GIVEN there are some Monitoring settings with active and inactive values
        insert new Monitoring__c( Name = 'Test1', Active__c = true );
        insert new Monitoring__c( Name = 'Test2', Active__c = false );

        // AND monitoring has been set up
        UtilsMonitoring.setupMonitoring();

        // WHEN calling buildMonitoringMessage() multiple times with inactive types
        Test.startTest();
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test2', 'Message2.1', null);
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test3', 'Message3.1', null);
        Test.stopTest();

        // THEN the saveMonitoringMessagesMap should contain none of the messages
        System.assertEquals(0, UtilsMonitoring.saveMonitoringMessagesMap.size());
    }

    @IsTest
    static void buildMonitoringMessageNoSettings() {
        // GIVEN there are No Monitoring settings
        // AND monitoring has been set up
        UtilsMonitoring.setupMonitoring();

        // WHEN calling buildMonitoringMessage() multiple times with inactive types
        Test.startTest();
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test2', 'Message2.1', null);
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test3', 'Message3.1', null);
        Test.stopTest();

        // THEN the saveMonitoringMessagesMap should contain none of the messages
        System.assertEquals(0, UtilsMonitoring.saveMonitoringMessagesMap.size());
    }

    @IsTest
    static void buildMonitoringMessageInactiveSettingsCoverageEnabled() {
        // GIVEN there are some Monitoring settings with active and inactive values
        insert new Monitoring__c( Name = 'Test1', Active__c = true );
        insert new Monitoring__c( Name = 'Test2', Active__c = false );

        // AND Monitoring Coverage is enabled for User
        insert new MonitoringCoverage__c(SetupOwnerId=UserInfo.getUserId(), Enable__c=true);

        // AND monitoring has been set up
        UtilsMonitoring.setupMonitoring();

        // WHEN calling buildMonitoringMessage() multiple times with inactive types
        Test.startTest();
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test2', 'Message2.1', null);
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test3', 'Message3.1', null);
        Test.stopTest();

        // THEN the saveMonitoringMessagesMap should contain all of the messages
        System.assertEquals(1, UtilsMonitoring.saveMonitoringMessagesMap.size());

        Map<String, List<UtilsMonitoring.ErrorMessage>> accountClassMap = UtilsMonitoring.saveMonitoringMessagesMap.get(Account.class);
        System.assertEquals(2, accountClassMap.size()); // Test2 and Test3

        List<UtilsMonitoring.ErrorMessage> test2Errors = accountClassMap.get('Test2');
        System.assertEquals(1, test2Errors.size());
        System.assert(test2Errors[0].msg == 'Message2.1');

        List<UtilsMonitoring.ErrorMessage> test3Errors = accountClassMap.get('Test3');
        System.assertEquals(1, test3Errors.size());
        System.assert(test3Errors[0].msg == 'Message3.1');
    }

    @IsTest
    static void saveMonitoringMessagesSaveAll() {
        // GIVEN there are some Monitoring settings with active values
        insert new Monitoring__c( Name = 'Test1', Active__c = true );
        insert new Monitoring__c( Name = 'Test2', Active__c = true );

        // AND monitoring has been set up
        UtilsMonitoring.setupMonitoring();

        // AND some monitoring messages have been added with additional fields
        Map<String, Object> additionalFields = new Map<String, Object> {
                'Optional_Field__c' => 'AdditionalData2.1'
        };

        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test1', 'Message1.1', null);
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test1', 'Message1.2', null);
        UtilsMonitoring.buildMonitoringMessage(UtilsMonitoring.class, 'Test2', 'Message2.1', additionalFields);

        // WHEN calling saveMonitoringMessages()
        Test.startTest();
        UtilsMonitoring.saveMonitoringMessages();
        Test.stopTest();

        // THEN the Debug Parent records will exist
        Debug_Parent__c[] dp = [SELECT Message_Type__c, Source__c FROM Debug_Parent__c ORDER BY Message_Type__c];
        System.assertEquals(2, dp.size());
        System.assertEquals('Test1', dp[0].Message_Type__c);
        System.assertEquals('Account', dp[0].Source__c);
        System.assertEquals('Test2', dp[1].Message_Type__c);
        System.assertEquals('UtilsMonitoring', dp[1].Source__c);

        // AND Debug Message records will exist
        Id parent1Id = dp[0].Id;
        Debug_Message__c[] test1msgs = [
                SELECT Message__c FROM Debug_Message__c WHERE Debug_Parent__c = :parent1Id
                ORDER BY Message__c
        ];
        System.assertEquals(2, test1msgs.size());
        System.assertEquals('Message1.1', test1msgs[0].Message__c);
        System.assertEquals('Message1.2', test1msgs[1].Message__c);

        Id parent2Id = dp[1].Id;
        Debug_Message__c[] test2msgs = [
                SELECT Message__c, Optional_Field__c FROM Debug_Message__c WHERE Debug_Parent__c = :parent2Id
                ORDER BY Message__c
        ];
        System.assertEquals(1, test2msgs.size());
        System.assertEquals('Message2.1', test2msgs[0].Message__c);
        System.assertEquals('AdditionalData2.1', test2msgs[0].Optional_Field__c);
    }

    @IsTest
    static void saveMonitoringMessagesSaveAnyProfile() {
        // GIVEN there are some Monitoring settings with active values
        insert new Monitoring__c( Name = 'Test1', Active__c = true );

        // AND we run as a Standard User
        User standardUser = TestUtils.getStandardInternalUser('std');
        System.runAs(standardUser) {
            // AND monitoring has been set up
            UtilsMonitoring.setupMonitoring();

            // AND some monitoring messages have been added
            UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test1', 'Message1.1', null);
            UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test1', 'Message1.2', null);

            // WHEN calling saveMonitoringMessages()
            Test.startTest();
            UtilsMonitoring.saveMonitoringMessages();
            Test.stopTest();
        }

        // THEN the Debug Parent records will exist
        Debug_Parent__c[] dp = [SELECT Message_Type__c, Source__c FROM Debug_Parent__c ORDER BY Message_Type__c];
        System.assertEquals(1, dp.size());
        System.assertEquals('Test1', dp[0].Message_Type__c);
        System.assertEquals('Account', dp[0].Source__c);

        // AND Debug Message records will exist
        Id parent1Id = dp[0].Id;
        Debug_Message__c[] dm = [
                SELECT Message__c FROM Debug_Message__c WHERE Debug_Parent__c = :parent1Id
                ORDER BY Message__c
        ];
        System.assertEquals(2, dm.size());
        System.assertEquals('Message1.1', dm[0].Message__c);
        System.assertEquals('Message1.2', dm[1].Message__c);
    }

    @IsTest
    static void saveMonitoringMessagesSaveNothing() {
        // GIVEN there are some Monitoring settings with active values
        insert new Monitoring__c( Name = 'Test1', Active__c = true );
        insert new Monitoring__c( Name = 'Test2', Active__c = true );

        // AND monitoring has been set up
        UtilsMonitoring.setupMonitoring();

        // BUT no monitoring messages have been built
        // WHEN calling saveMonitoringMessages()
        Test.startTest();
        UtilsMonitoring.saveMonitoringMessages();
        Test.stopTest();

        // THEN the no Debug Parent records will exist
        Debug_Parent__c[] dp = [SELECT Message_Type__c, Source__c FROM Debug_Parent__c];
        System.assertEquals(0, dp.size());

        // AND no Debug Message records will exist
        Debug_Message__c[] dm = [SELECT Message__c FROM Debug_Message__c];
        System.assertEquals(0, dm.size());
    }

    @IsTest
    static void saveMonitoringMessagesSaveOne() {
        // GIVEN there are some Monitoring settings with active values
        insert new Monitoring__c( Name = 'Test1', Active__c = true );
        insert new Monitoring__c( Name = 'Test2', Active__c = true );

        // AND monitoring has been set up
        UtilsMonitoring.setupMonitoring();

        // AND some monitoring messages have been added
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test1', 'Message1.1', null);
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test1', 'Message1.2', null);
        UtilsMonitoring.buildMonitoringMessage(UtilsMonitoring.class, 'Test2', 'Message2.1', null);

        // WHEN calling saveMonitoringMessages() to save messages from just one source object
        Test.startTest();
        UtilsMonitoring.saveMonitoringMessages(UtilsMonitoring.class);
        Test.stopTest();

        // THEN the Debug Parent records will exist
        Debug_Parent__c[] dp = [SELECT Message_Type__c, Source__c FROM Debug_Parent__c ORDER BY Message_Type__c];
        System.assertEquals(1, dp.size());
        System.assertEquals('Test2', dp[0].Message_Type__c);
        System.assertEquals('UtilsMonitoring', dp[0].Source__c);

        // AND Debug Message records will exist
        Id parent2Id = dp[0].Id;
        Debug_Message__c[] test2msgs = [SELECT Message__c FROM Debug_Message__c WHERE Debug_Parent__c = :parent2Id ORDER BY Message__c];
        System.assertEquals(1, test2msgs.size());
        System.assertEquals('Message2.1', test2msgs[0].Message__c);
    }

    @IsTest
    static void saveMonitoringMessagesSaveNull() {
        // GIVEN there are some Monitoring settings with active values
        insert new Monitoring__c( Name = 'Test1', Active__c = true );
        insert new Monitoring__c( Name = 'Test2', Active__c = true );

        // AND monitoring has been set up
        UtilsMonitoring.setupMonitoring();

        // AND some monitoring messages have been added with a Null source
        UtilsMonitoring.buildMonitoringMessage(null, 'Test1', 'Message1.1', null);
        UtilsMonitoring.buildMonitoringMessage(null, 'Test1', 'Message1.2', null);
        UtilsMonitoring.buildMonitoringMessage(UtilsMonitoring.class, 'Test2', 'Message2.1', null);

        // WHEN calling saveMonitoringMessages() to save messages from just one source object
        Test.startTest();
        UtilsMonitoring.saveMonitoringMessages(null);
        Test.stopTest();

        // THEN the Debug Parent records will exist
        Debug_Parent__c[] dp = [SELECT Message_Type__c, Source__c FROM Debug_Parent__c ORDER BY Message_Type__c];
        System.assertEquals(1, dp.size());
        System.assertEquals('Test1', dp[0].Message_Type__c);
        System.assertEquals(null, dp[0].Source__c);

        // AND Debug Message records will exist
        Id parentId = dp[0].Id;
        Debug_Message__c[] test1msgs = [SELECT Message__c FROM Debug_Message__c WHERE Debug_Parent__c = :parentId ORDER BY Message__c];
        System.assertEquals(2, test1msgs.size());
        System.assertEquals('Message1.1', test1msgs[0].Message__c);
        System.assertEquals('Message1.2', test1msgs[1].Message__c);
    }

    @IsTest
    static void saveMonitoringMessagesSaveAllPrivate() {
        // GIVEN there are some Monitoring settings with active values
        insert new Monitoring__c( Name = 'Test1', Active__c = true );
        insert new Monitoring__c( Name = 'Test2', Active__c = true );

        // AND monitoring has been set up
        UtilsMonitoring.setupMonitoring();

        // AND some monitoring messages have been added
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test1', 'Message1.1', null);
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test1', 'Message1.2', null);
        UtilsMonitoring.buildMonitoringMessage(UtilsMonitoring.class, 'Test2', 'Message2.1', null);

        // WHEN calling saveMonitoringMessages() to save messages with saveAll = true
        Test.startTest();
        Boolean saveAll = true;
        UtilsMonitoring.saveMonitoringMessages(UtilsMonitoring.class, saveAll);
        Test.stopTest();

        // THEN the Debug Parent records will exist
        Debug_Parent__c[] dp = [SELECT Message_Type__c FROM Debug_Parent__c ORDER BY Message_Type__c];
        System.assertEquals(2, dp.size());
        System.assertEquals('Test1', dp[0].Message_Type__c);
        System.assertEquals('Test2', dp[1].Message_Type__c);

        // AND all Debug Message records will exist
        Debug_Message__c[] dm = [SELECT Message__c, Debug_Parent__c FROM Debug_Message__c ORDER BY Message__c];
        System.assertEquals(3, dm.size());
        System.assertEquals('Message1.1', dm[0].Message__c);
        System.assertEquals('Message1.2', dm[1].Message__c);
        System.assertEquals('Message2.1', dm[2].Message__c);
    }

    @IsTest
    static void saveMonitoringMessagesExceedsMaxLength() {
        // GIVEN there are some Monitoring settings with active values
        insert new Monitoring__c( Name = 'Test Long', Active__c = true );

        // AND monitoring has been set up
        UtilsMonitoring.setupMonitoring();

        // WHEN adding a message that exceeds 255 character and saving
        Test.startTest();
        String veryLongMessage =
                        '....:....1....:....2....:....3....:....4....:....5....:....6....:....7....:....8....:....9....:....0' +
                        '....:....1....:....2....:....3....:....4....:....5....:....6....:....7....:....8....:....9....:....0' +
                        '....:....1....:....2....:....3....:....4....:....5....:....6....:....7....:....8....:....9....:....0';
        System.assert(veryLongMessage.length() > 255);
        UtilsMonitoring.buildMonitoringMessage(Contact.class, 'Test Long', veryLongMessage, null);
        UtilsMonitoring.saveMonitoringMessages(Contact.class);
        Test.stopTest();

        // THEN the Debug Parent record will exist
        Debug_Parent__c[] dp = [SELECT Message_Type__c FROM Debug_Parent__c ORDER BY Message_Type__c];
        System.assertEquals(1, dp.size());
        System.assertEquals('Test Long', dp[0].Message_Type__c);

        // AND the Debug Message record will exist
        Id parentId = dp[0].Id;
        Debug_Message__c[] dm = [SELECT Message__c FROM Debug_Message__c WHERE Debug_Parent__c = :parentId];
        System.assertEquals(1, dm.size());

        // AND the message has been truncated
        System.assertEquals(255, dm[0].Message__c.length());
        System.assertEquals(veryLongMessage.left(254), dm[0].Message__c.left(254));
    }

    @IsTest
    static void insertDebugRecordsPrivate() {
        // GIVEN some debug parent records in a map
        Map<Integer, Debug_Parent__c> newParents = new Map<Integer, Debug_Parent__c> {
                0 => new Debug_Parent__c(Message_Type__c = 'Parent1'),
                1 => new Debug_Parent__c(Message_Type__c = 'Parent2')
        };

        // AND some related debug messages in a map
        Map<Integer, Debug_Message__c[]> newMessages = new Map<Integer, Debug_Message__c[]> {
                0 => new Debug_Message__c[] {
                        new Debug_Message__c(Message__c = 'Message1.1')
                },
                1 => new Debug_Message__c[] {
                        new Debug_Message__c(Message__c = 'Message2.1'),
                        new Debug_Message__c(Message__c = 'Message2.2')
                }
        };

        // WHEN calling insertDebugRecords()
        Test.startTest();
        Boolean result = UtilsMonitoring.insertDebugRecords(newParents, newMessages);
        Test.stopTest();

        // THEN the result will be true
        System.assertEquals(true, result);

        // AND the debug parents will be saved
        Debug_Parent__c[] dp = [SELECT Message_Type__c FROM Debug_Parent__c ORDER BY Message_Type__c];
        System.assertEquals(2, dp.size());
        System.assertEquals('Parent1', dp[0].Message_Type__c);
        System.assertEquals('Parent2', dp[1].Message_Type__c);

        // AND the debug messages will be related accordingly
        Debug_Message__c[] dm = [SELECT Message__c, Debug_Parent__c FROM Debug_Message__c ORDER BY Message__c];
        System.assertEquals(3, dm.size());
        System.assertEquals('Message1.1', dm[0].Message__c);
        System.assertEquals(dp[0].Id, dm[0].Debug_Parent__c);
        System.assertEquals('Message2.1', dm[1].Message__c);
        System.assertEquals(dp[1].Id, dm[1].Debug_Parent__c);
        System.assertEquals('Message2.2', dm[2].Message__c);
        System.assertEquals(dp[1].Id, dm[2].Debug_Parent__c);
    }

    @IsTest
    static void saveMonitoringMessagesExceedsDMLStatements() {
        // GIVEN there are some Monitoring settings with active values
        insert new Monitoring__c( Name = 'Test1', Active__c = true );

        // AND monitoring has been set up
        UtilsMonitoring.setupMonitoring();

        // AND some monitoring messages have been added
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test1', 'Message1.1', null);
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test1', 'Message1.2', null);

        // WHEN calling saveMonitoringMessages() after DML Statement count is set to be exceeded
        Test.startTest();
        for (Integer i = 0; i<Limits.getLimitDmlStatements() - 1; i++) {
            insert new Debug_Parent__c(Message_Type__c = 'Dummy');
        }
        UtilsMonitoring.saveMonitoringMessages(UtilsMonitoring.class);
        Test.stopTest();

        // THEN no Debug Parents or Messages will have been added
        Debug_Parent__c[] dp = [SELECT Id FROM Debug_Parent__c WHERE Message_Type__c = 'Test1'];
        System.assertEquals(0, dp.size());
        Debug_Message__c[] dm = [SELECT Id FROM Debug_Message__c];
        System.assertEquals(0, dm.size());
    }

    @IsTest
    static void saveMonitoringMessagesExceedsDMLRows() {
        // GIVEN there are some Monitoring settings with active values
        insert new Monitoring__c( Name = 'Test1', Active__c = true );

        // AND monitoring has been set up
        UtilsMonitoring.setupMonitoring();

        // AND some monitoring messages have been added
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test1', 'Message1.1', null);
        UtilsMonitoring.buildMonitoringMessage(Account.class, 'Test1', 'Message1.2', null);

        // WHEN calling saveMonitoringMessages() after DML Row count is set to be exceeded
        Test.startTest();
        Debug_Parent__c[] dps = new Debug_Parent__c[]{};
        for (Integer i = 0; i<Limits.getLimitDmlRows(); i++) {
            dps.add(new Debug_Parent__c(Message_Type__c = 'Dummy'));
        }
        insert dps;
        UtilsMonitoring.saveMonitoringMessages(UtilsMonitoring.class);
        Test.stopTest();

        // THEN no Debug Parents or Messages will have been added
        Debug_Parent__c[] dp = [SELECT Id FROM Debug_Parent__c WHERE Message_Type__c = 'Test1'];
        System.assertEquals(0, dp.size());
        Debug_Message__c[] dm = [SELECT Id FROM Debug_Message__c];
        System.assertEquals(0, dm.size());
    }
}