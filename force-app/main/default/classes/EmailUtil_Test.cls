/**
 * Created by Nina Gronowska on 20/09/2017.
 */

@IsTest
private class EmailUtil_Test{

    private static testMethod void shouldStoreEmailResults() {
        // Given an email util that hasn't sent emails
        System.assertEquals(null, EmailUtil.last_sendEmail_result);

        try {
            // When you send an email
            EmailUtil.to(new String[]{'test@spam.com'}).sendEmail();
            
            // Then the email util should store the send result.
            System.assertNotEquals(null, EmailUtil.last_sendEmail_result);
            System.assertEquals(1, EmailUtil.last_sendEmail_result.size());
            for (Messaging.SendEmailResult ser : EmailUtil.last_sendEmail_result)
                System.assertEquals(true, ser.isSuccess());
        } catch (EmailException ee) {
            System.assert(ee.getMessage().contains('NO_MASS_MAIL_PERMISSION'), 'Exception is only allowed if Email Deliverability is not set to All Emails.');
        }
    }

    private static testMethod void shouldWorkWithTemplates() {
        // Given an email util that has not sent emails, and a template for emails
        System.assertEquals(null, EmailUtil.last_sendEmail_result);

        Folder test_template_folder =
        [Select Id from Folder Where Type = 'Email' And IsReadOnly = false Limit 1];

        EmailTemplate test_template = new EmailTemplate(
                Name = 'test email template', DeveloperName = 'test_template_uniqueasdfbahkls',
                TemplateType = 'text', isActive = true, Description = 'test template',
                Subject = 'test email', FolderId = test_template_folder.Id,
                Body = 'Hi {!Receiving_User.FirstName}, this is a test email to a user.'
        );
        insert test_template;

        // When an email is constructed & sent to the current user with that template
        EmailUtil.to(UserInfo.getUserId())
                .templateId(test_template.Id)
                .sendEmail();

        // Then it should be sent successfully
        System.assertEquals(1, EmailUtil.last_sendEmail_result.size());
        for (Messaging.SendEmailResult ser : EmailUtil.last_sendEmail_result)
            System.assertEquals(true, ser.isSuccess());
    }

    private static testMethod void shouldBulkStash() {
        // Given an EmailUtil that doesn't have emails to send.
        System.assertEquals(false, EmailUtil.hasEmailsToSend());

        // When you stash an email to send
        EmailUtil.to(new String[]{'test@spam.com'})
                .stashForBulk();

        // Then EmailUtil should have emails to send
        System.assertEquals(true, EmailUtil.hasEmailsToSend());
    }

    private static testMethod void shouldBulkSend() {
        // Given an Email util with  bulk email to send
        EmailUtil.to(new String[]{'test1@spam.com'}).stashForBulk();
        EmailUtil.to(new String[]{'test2@spam.com'}).stashForBulk();

        try {
            // When you send bulk
            EmailUtil.sendBulkEmail();
            
            // Then two emails should be sent successfully
            system.assertEquals(2, EmailUtil.last_sendEmail_result.size());
            for (Messaging.SendEmailResult ser : EmailUtil.last_sendEmail_result)
                System.assertEquals(true, ser.isSuccess());
        } catch (EmailException ee) {
            System.assert(ee.getMessage().contains('NO_MASS_MAIL_PERMISSION'), 'Exception is only allowed if Email Deliverability is not set to All Emails.');
        }
    }

    private static testMethod void shouldHandleEmptyBulkSend() {
        // Given an emailutil with no emails to send
        System.assertEquals(false, EmailUtil.hasEmailsToSend());

        try {
            // When you try and do a bulk send
            EmailUtil.sendBulkEmail();
        } catch (Exception e) {
            // then it shouldn't fail horribly.
            System.assert(false);
        }
    }

    private static testMethod void settersShouldNotThrowExceptions() {
        try {
            // When using all the setters
            EmailUtil.to(new String[]{UserInfo.getUserEmail()})
                    .saveAsActivity(false)
                    .senderDisplayName('test sender')
                    .subject('test email')
                    .htmlBody('this is html')
                    .useSignature(false)
                    .replyTo(UserInfo.getUserEmail())
                    .plainTextBody('this is plaintext')
                    .fileAttachments(null);
        } catch (Exception e) {
            // Then it should not throw an exception.
            system.assert(false);
        }
    }
}