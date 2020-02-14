@isTest
private class EmailToCaseMisys_Test{

    // The following test methods provide adequate code coverage for the EmailToCaseMisys email class.
    // testEmailToCaseMisys_ThreadID    : Check if the service can found a case by Thread ID
    // testEmailToCaseMisys_CaseNumber  : Check if the service can found a case by Thread ID
    // testEmailToCaseMisys_Subject     : Check if the service can found a case by Thread ID
    static testMethod void testEmailToCaseMisys_ThreadID(){
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // Test with a subject that contains a "Thread ID"
        email.subject = 'ref:_00DW075gMK._500W02Yh0s:ref';
        env.fromAddress = 'asim.maqbool@misys.com';

        // Call the class and test it with the data in the testMethod.
        EmailToCaseMisys e2CObj = new EmailToCaseMisys();
        e2CObj.handleInboundEmail(email, env);
    }

    static testMethod void testEmailToCaseMisys_CaseNumber(){
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();


        // Test with a subject that contains a "case number"
        email.subject = '00894759';
        env.fromAddress = 'asim.maqbool@misys.com';

        // Call the class and test it with the data in the testMethod.
        EmailToCaseMisys e2CObj = new EmailToCaseMisys();
        e2CObj.handleInboundEmail(email, env);


    }
    @isTest(seeAllData=true)
    static void testCaseEmailInBoundUtilities(){

        Case c = new Case(SFDC_CSFE_Commentary__c = 'Test Commentary 1');
        insert c;
        CaseEmailInBoundUtilities ceb = new CaseEmailInBoundUtilities();
        ceb.supportEmail = 'sophis.support';
        ceb.supportEmail = 'sophis.support';
        Messaging.InboundEmail inboundEmail_testclass = new Messaging.InboundEmail();
        inboundEmail_testclass.subject = 'test class';
        //inboundEmail_testclass.textAttachments.add( 'test class');

        //toAddresses
        ceb.inboundEmail = new Messaging.InboundEmail();
        ceb.inboundEmail.toAddresses = new List<String>();
        ceb.inboundEmail.toAddresses.add('sophis.support@misys.com');
        //cc Addresses
        ceb.processInboundEmail(ceb.inboundEmail);
        ceb.inboundEmail.ccAddresses = new List<String>();
        ceb.inboundEmail.ccAddresses.add('kondor.support@misys.com');


        ceb.inboundEmail.FromAddress = 'asim.maqbool@misys.com';
        //  ceb.inboundEmail=inboundEmail_testclass;
        ceb.GetAccountContact();
        //  email.toAddresses.add('asim.maqbool@misys.com');
        ceb.createEmailMessage(c, ceb.inboundEmail);
        ceb.GetRecordType();
        ceb.CreateCase();

        Account anyAccount = TestUtility.createAccount('Test account');
        //insert anyAccount;
        Contact nonMisysContact = new Contact(LastName = 'test contact', email = 'a@b.com', Alternative_Email__c = 'c@d.com', Inactive_Contact__c = false);
        nonMisysContact.AccountId = anyAccount.Id;
        insert nonMisysContact;
        ceb.inboundEmail.FromAddress = 'a@b.com';
        //  ceb.inboundEmail=inboundEmail_testclass;
        ceb.GetAccountContact();
    }

    static testMethod void testEmailToCaseMisys_Attachment(){
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

        // Test with a subject that contains a "case number"
        email.subject = 'SFDC_E2C Test 3';
        env.fromAddress = 'asim.maqbool@misys.com';

        // set the body of the attachment
        inAtt.body = blob.valueOf('test');
        inAtt.fileName = 'my attachment name';
        inAtt.mimeTypeSubType = 'plain/txt';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[]{
                inAtt
        };

        // Call the class and test it with the data in the testMethod.
        EmailToCaseMisys e2CObj = new EmailToCaseMisys();
        e2CObj.handleInboundEmail(email, env);

    }

    static testmethod void testExtractAddress(){
        system.debug('testExtractAddress ');

        String expected = 'asim.maqbooll@misys.com';
        String target = 'Asim Maqbool <' + expected + '>';
        CaseEmailInBoundUtilities prutil = new CaseEmailInBoundUtilities();
        String results = prutil.extractAddress(target);
        System.assertEquals(expected, results);

        target = 'Asim Maqbool <asim.maqbool@misys.com>';
        expected = 'asim.maqbool@misys.com';

        results = prutil.extractAddress(target);
        System.assertEquals(expected, results);
    }
}