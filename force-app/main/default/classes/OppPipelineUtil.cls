/*
Author: Ramesh Thulasi
Descriptiton:   Pipeline project utilities & constants. 
*/
public class OppPipelineUtil {
    public static final String PIPELINE_DEFFERED_NAME = 'Pipeline';
    public static final String PIPELINE_PROJECT_NOTIFY_DEAL_CAPTAIN_TEMPLATE = 'Pipeline_Project_Notify_Deal_Captain_Template';
    public static final String PIPELINE_PROJECT_NOTIFY_GS_TEMPLATE =  'Pipeline_Project_Notify_GS_Template';
    public static final String PIPELINE_PROJECT_CREATED_TEMPLATE = 'Pipeline_Project_Created_Template';
    public static final String PIPELINE_PROJECT_CUSTOMER_MISMATCH_TEMPLATE = 'Pipeline_Project_Customer_Mismatch_Template';
    
    public static final Map<String,ID> pipelineTemplateMap = new Map<String,ID>();
    static {
        for (EmailTemplate template: [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName=:PIPELINE_PROJECT_NOTIFY_DEAL_CAPTAIN_TEMPLATE or DeveloperName  =: PIPELINE_PROJECT_NOTIFY_GS_TEMPLATE or DeveloperName  =: PIPELINE_PROJECT_CREATED_TEMPLATE or DeveloperName  =: PIPELINE_PROJECT_CUSTOMER_MISMATCH_TEMPLATE]) {
            pipelineTemplateMap.put(template.DeveloperName, template.id);
        }
    }
    public static final String OPP_FIELD_ID = 'CF00N0J00000A5xbL';
    public static final String OPP_LINK_FIELD_ID = OPP_FIELD_ID + '_lkid';
    public static final String DEFERRED_ACCOUNT_TYPE_FIELD_ID = '00N20000007GMU4';
    public static final String TRICKLE_OPPORTUNITY_DATA_FIELD_ID = '00N0J00000A5xbG';
    public static final Id licensesWithOrWithoutPSRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Licenses with/without PS').getRecordTypeId();
    public static final Id changeOrderRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Change Order').getRecordTypeId();
    public static final Id psOnlyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PS Only').getRecordTypeId();

    public static final OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply.notifications@misys.com'];
	public static final String GS_MAIL_BOX=Label.GS_Operations_Email;//'psops.support@misys.com';
    public static void sendEmail( String emailId, ID whatId, String templateName ) {
        ID tmplateId = pipelineTemplateMap.get(templateName);
        if(tmplateId==null) {
            System.debug(LoggingLevel.ERROR, 'Email template not definded: ' + templateName);
            return;
        }
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        Contact c = new Contact();
        c.lastName='Test';
        c.email=emailId;
        insert c;
        emailMsg.setWhatId(whatId);
        emailMsg.setTargetObjectId(c.id);
        if(!owea.isEmpty()) {
            emailMsg.setOrgWideEmailAddressId(owea.get(0).id);
        }
        emailMsg.setTemplateId(tmplateId);
        emailMsg.optOutPolicy='FILTER';
        Messaging.SingleEmailMessage[] emailMsgs =   new List<Messaging.SingleEmailMessage> {emailMsg};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMsgs);
        if (results[0].success)  {
            System.debug('RTDebug The email was sent successfully.');
        } else {
            System.debug('RTDebug The email failed to send: ' + results[0].errors[0].message);
        }
        delete c;
    }
   

}