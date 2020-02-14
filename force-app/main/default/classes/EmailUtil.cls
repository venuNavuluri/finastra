/*
*********** Sending a Single Message ***********
Here's how you could compose a single email and send it immediately:

List<String> toAddresses = new List<String> {'john.doe@acme.org'};
String replyToAddress = 'john.duh@acme.org';

emailUtil.to(toAddresses)
	.plainTextBody('Bilbo Bagginses has stolen our Preciousssss!!')
	.senderDisplayName('Gollum Gollum')
	.replyTo(replyToAddress)
	.sendEmail();


*********** Sending Bulk Mail in a Trigger ***********
Here's a pseudo-code example of the bulk send inside a trigger:

trigger onContact on Contact (after insert) {
	for (Contact c : Trigger.new) {
		if (meets_criteria_for_send_email(c)) {
			EmailUtil.to(new String[]{'test@spam.com'})
				.stashForBulk();
		}
	}
	EmailUtil.sendBulkEmail();
}

*/
public class EmailUtil {

    private String subject = '';
    private String htmlBody = '';
    private String plainTextBody = '';
    private Boolean useSignature = false;
    private Boolean SaveAsActivity = false;
    private List<Messaging.EmailFileAttachment> fileAttachments = null;
    // Default replyTo is current user's email address
    // using a static to save this result across multiple email constructions.
    private static User currentUser {
        get {
            if (currentUser == null)
                currentUser = [Select email from User where username = :UserInfo.getUserName() limit 1];
            return currentUser;
        } set;
    }
    private String replyTo = currentUser.email;
    private String senderDisplayName = UserInfo.getFirstName()+' '+UserInfo.getLastName();

    private Id templateId;
    private Id whatId;
    private Id orgWideId;

    private final Id targetObjectId; // Contact, Lead, or User.
    private final List<String> toAddresses;

    // Used to temporarily hold the email during the build command
    private Messaging.SingleEmailMessage singleEmailMessage;


    public static EmailUtil to(List<String> addresses) {
        return new EmailUtil(addresses);
    }

    public static EmailUtil to(Id target) {
        return new EmailUtil(target);
    }

    public EmailUtil saveAsActivity(Boolean val) {
        saveAsActivity = val;
        return this;
    }

    public EmailUtil senderDisplayName(String val) {
        senderDisplayName = val;
        return this;
    }

    public EmailUtil subject(String val) {
        subject = val;
        return this;
    }

    public EmailUtil htmlBody(String val) {
        htmlBody = val;
        return this;
    }

    public EmailUtil templateId(Id an_id) {
        templateId = an_id;
        return this;
    }

    public EmailUtil whatId (Id an_id) {
        whatId = an_id;
        return this;
    }

    public EmailUtil orgWideId (Id an_id) {
        orgWideId = an_id;
        return this;
    }

    public EmailUtil useSignature(Boolean bool) {
        useSignature = bool;
        return this;
    }

    public EmailUtil replyTo(String val) {
        replyTo = val;
        return this;
    }

    public EmailUtil plainTextBody(String val) {
        plainTextBody = val;
        return this;
    }

    public EmailUtil fileAttachments(List<Messaging.Emailfileattachment> val) {
        fileAttachments = val;
        return this;
    }

    public void sendEmail() {
        build();
        last_sendEmail_result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { singleEmailMessage });
    }
    public void stashForBulk() {
        build();
        bulk_stash.add(singleEmailMessage);
    }

    public static void sendBulkEmail() {
        // send emails in bulk_stash, empty it.
        last_sendEmail_result = Messaging.sendEmail(bulk_stash);
        bulk_stash.clear();
    }

    public static Boolean hasEmailsToSend() {
        return bulk_stash.size() != 0 ? true : false;
    }

    // static method for holding email results, for testing purposes
    public static Messaging.SendEmailResult[] last_sendEmail_result {get; private set;}


    // private constructors, force you to use the static chain methods.
    private EmailUtil(List<String> addresses) {
        this.toAddresses = addresses;
    }

    private EmailUtil(Id target) {
        this.targetObjectId = target;
    }

    // build method, constructs a single email message.
    // this method is private and is called from sendEmail() or stashForBulk()
    private EmailUtil build() {
        singleEmailMessage = new Messaging.SingleEmailMessage();
        singleEmailMessage.setTargetObjectId(this.targetObjectId);
        singleEmailMessage.setWhatId(this.whatId);
        singleEmailMessage.setToAddresses(this.toAddresses);
        if(this.orgWideId != null){
            singleEmailMessage.setOrgWideEmailAddressId(this.orgWideId);
        }else{
            singleEmailMessage.setSenderDisplayName(this.senderDisplayName);
        }
        singleEmailMessage.setUseSignature(this.useSignature);
        singleEmailMessage.setReplyTo(this.replyTo);
        singleEmailMessage.setFileAttachments(this.fileAttachments);
        singleEmailMessage.setSaveAsActivity(this.saveasactivity);
        // use template if one exists, else use html and plain text body
        if (this.templateId == null) {
            singleEmailMessage.setHtmlBody(this.htmlBody);
            singleEmailMessage.setPlainTextBody(this.plainTextBody);
            singleEmailMessage.setSubject(this.subject);
        } else {
            singleEmailMessage.setTemplateId(this.templateId);
        }
        return this;
    }

    private static Messaging.SingleEmailMessage[] bulk_stash {
        get {
            if (bulk_stash == null)
                bulk_stash = new Messaging.SingleEmailMessage[]{};
            return bulk_stash;
        } private set;
    }
}