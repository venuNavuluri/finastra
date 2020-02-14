public class EscalationUtils
{
    
    public static Case QueryCustomerCase(Id customerCaseId)
    {
     //[SC] Added the parameters Business_Problem__c, Required_Functionality__c, Assumptions_and_Constraints__c, Additional_Details__c, in the query
     //for SD Request#1314764 
        return [
            Select
                ID, CaseNumber, Subject, ParentID, Internal_Severity__c, Status, Product_Set_Text__c, System_Text__c,
                Product_Version__c, Case_Category__c , Client_Asset__c, Client_Asset_Text__c, Description, AccountID, ContactID, Support_Entitlement__c, 
                Contract_Asset__c, Contract_Asset__r.Name, Environment2__c, Database__c, Database_Version__c, Origin, Type, Severity__c,
                Replication_Steps__c, Account.Name, Contact.Name, Contact.Email, Contact.Phone, System__c, Product_Set__c, Product_Set_Module__c,
                Project__c, Priority, Closure_Resolution_Details__c, OwnerID, ProductID, Steps_to_Reproduce__c, Product_Set_Version__c, 
                Product_Set_Module_Version__c, Product_Set__r.Name, Client_Asset__r.Name, System__r.Name, Prior_Case_Owner__c, RecordTypeId,
                Customer_Case_Created_Date__c,CreatedDate,
                Self_Service_Product__c, Customer_Name__c,Hardware__c,Product_Module__c, Operating_System_Version__c, System_Status__c, EscalateTo__c, 
                Business_Problem__c, Required_Functionality__c, Assumptions_and_Constraints__c, Additional_Details__c,
                CS_Re_open_Count__c,Customer_Re_open_Count__c,PS_Re_open_Count__c,ESG_Re_open_Count__c,Defect_Reopen_Date__c,NonDefect_Reopen_Date__c,NonDefect_Total_Reopen_Count__c,Case_Re_opened_By__c,Reason_Case_Reopened__c,
                (Select Id from CaseComments),
                (Select Id from Attachments)
            from Case
            where id=: customerCaseId
        ];
    }
    
    public static String CreateAndInsertEscalatedCase(Case customerCase, String additionalEscalatedCaseNotes, Integer minutesSpent)
    {
        Case engCase = createEscalatedEngineeringCase(customerCase, additionalEscalatedCaseNotes, minutesSpent);
        insert engCase;
        
        //The IF condition below added for SRR 1269381
        system.debug('----condition check----'+customerCase.RecordTypeId!=RecotypeId('Misys Sophis'));
        if(customerCase.RecordTypeId!=RecotypeId('Misys Sophis'))
        {
            List<CaseComment> engineeringCaseComments = createCaseComments(customerCase, engCase.Id);
            if (engineeringCaseComments.size() > 0) { insert engineeringCaseComments; }
        }
        
        List<Attachment> engineeringAttachments = createAttachments(customerCase, engCase.Id);
        system.debug('@@@ user to insert:' + userinfo.getName());
        if (engineeringAttachments.size() > 0) { insert engineeringAttachments; }
        
        //updateAndSaveCustomerCase(customerCase, engCase.Id);
        updateAndSaveCustomerCase(customerCase, engCase);
        
        return engCase.id;
    }
    
    //Takes RecordTypeName as parameter and returns the ID of the same. Created for SRR 1269381
    public static String RecotypeId(String recordtypename)
    {
        List<RecordType_Info__c> recID=[Select Id from RecordType_Info__c where Name_of_record_type__c = :recordtypename limit 1];
        system.debug('----Data received for Record type----'+recordtypename);
        system.debug('----Data being sent back----'+recID[0].Id);
        return recID[0].Id;
    }

    private static Case createEscalatedEngineeringCase(Case record, String additionalEscalatedCaseNotes, Integer minutesSpent)
    {
        Case engineeringCase = new Case();
        
        engineeringCase.RecordTypeId =                      getEngineeringProcess(record.RecordTypeId);
        engineeringCase.Status =                            Constants.STATUS_ESCALATED;
        engineeringCase.Sub_Status__c =                     Constants.SUB_STATUS_ESCALATED;
//      engineeringCase.Sub_Status__c =                     Constants.SUB_STATUS_ESCALATED_TO_GSC;
        
        engineeringCase.Case_Category__c =                  record.Case_Category__c;
        engineeringCase.EscalateTo__c =                     record.EscalateTo__c;
        engineeringCase.Origin =                            record.Origin;
        engineeringCase.Type =                              record.Type;
        engineeringCase.Internal_Severity__c =              record.Internal_Severity__c;
        engineeringCase.Severity__c =                       record.Severity__c;
        engineeringCase.Priority =                          record.Priority;
        engineeringCase.Account_Eng__c =                    record.AccountId;
        engineeringCase.Contact_Name__c =                   record.Contact.Name;
        engineeringCase.Contact_Phone__c =                  record.Contact.Phone;
        engineeringCase.Contact_Email__c =                  record.Contact.Email;
        engineeringCase.Support_Entitlement__c =            record.Support_Entitlement__c;
        engineeringCase.System__c =                         record.System__c;
        engineeringCase.System_Text__c =                    record.System__r.Name;
        engineeringCase.Contract_Asset__c =                 record.Contract_Asset__c;
        engineeringCase.Product_Set__c =                    record.Product_Set__c;
        engineeringCase.Product_Set_Text__c =               record.Product_Set__r.Name;
        engineeringCase.Client_Asset__c =                   record.Client_Asset__c;
        engineeringCase.Client_Asset_Text__c =              record.Client_Asset__r.Name;
        engineeringCase.ProductID =                         record.ProductId; 
        engineeringCase.Product_Set_Version__c =            record.Product_Set_Version__c;
        engineeringCase.Product_Set_Module__c =             record.Product_Set_Module__c;
        engineeringCase.Product_Set_Module_Version__c =     record.Product_Set_Module_Version__c;
        engineeringCase.Steps_to_Reproduce__c =             record.Steps_to_Reproduce__c;
        engineeringCase.Closure_Resolution_Details__c =     record.Closure_Resolution_Details__c;
        engineeringCase.CS_Re_open_Count__c =               record.CS_Re_open_Count__c;
        engineeringCase.Customer_Re_open_Count__c=          record.Customer_Re_open_Count__c;
        engineeringCase.ESG_Re_open_Count__c=               record.ESG_Re_open_Count__c;
        engineeringCase.PS_Re_open_Count__c=                record.PS_Re_open_Count__c;
        engineeringCase.Defect_Reopen_Date__c=              record.Defect_Reopen_Date__c;
        engineeringCase.NonDefect_Reopen_Date__c=           record.NonDefect_Reopen_Date__c;
        engineeringCase.NonDefect_Total_Reopen_Count__c=    record.NonDefect_Total_Reopen_Count__c;
        engineeringCase.Case_Re_opened_By__c=               record.Case_Re_opened_By__c;
        engineeringCase.Reason_Case_Reopened__c=            record.Reason_Case_Reopened__c;
        
        
        String prefix = '';
        if (record.EscalateTo__c == 'Engineering') { prefix = '[ENGINEERING] '; }
        else if (record.EscalateTo__c == 'GSC') { prefix = '[GSC] '; }
        else if (record.EscalateTo__c == 'Product Management') { prefix = '[PM] '; }
        
        //AK - Changed this for removing the [ENGINEERING] from the Subject for "Misys Sophis"
        String nameOfRecType = RecordType_Info__c.getValues(record.RecordTypeId).Name_of_record_type__c;
        if('Misys Sophis' == nameOfRecType){
            prefix = '';
        }
        engineeringCase.Subject =                           prefix + record.Subject;
        
        engineeringCase.Description =                       record.Description;
        engineeringCase.Customer_Case_Number__c =           record.CaseNumber;
        engineeringCase.Customer_Case_Created_Date__c =     record.CreatedDate;
        engineeringCase.Customer_Name__c    =               record.Account.Name;
        engineeringCase.Self_Service_Product__c =           record.Self_Service_Product__c;
        engineeringCase.Product_Version__c =                record.Product_Version__c;
        engineeringCase.Hardware__c =                       record.Hardware__c;
        engineeringCase.Product_Module__c =                 record.Product_Module__c;
        engineeringCase.Operating_System_Version__c =       record.Operating_System_Version__c;
        engineeringCase.Database__c =                       record.Database__c;
        engineeringCase.System_Status__c =                  record.System_Status__c;
        engineeringCase.Time_spent_on_issue__c =            minutesSpent;
        
        //New 4 fields added by Subhendu for SD Request#1314764 
        engineeringCase.Business_Problem__c =               record.Business_Problem__c;
        engineeringCase.Required_Functionality__c =         record.Required_Functionality__c;
        engineeringCase.Assumptions_and_Constraints__c =    record.Assumptions_and_Constraints__c;
        engineeringCase.Additional_Details__c =             record.Additional_Details__c;
        
        System.debug('Business_Problem__c: '+record.Business_Problem__c);
        System.debug('Required_Functionality__c: '+record.Required_Functionality__c);
        System.debug('Assumptions_and_Constraints__c: '+record.Assumptions_and_Constraints__c);
        System.debug('Additional_Details__c: '+record.Additional_Details__c);
        
        setTarget(engineeringCase);
        setOrigin(engineeringCase, record.Project__c);
        setOwnership(engineeringCase, record.OwnerID);
        setDescription(engineeringCase, additionalEscalatedCaseNotes);
        
        return engineeringCase;
    }

    private static string getEngineeringProcess(string recTypeId)
    {
        string engrProcess;
        string engrRecTypeId;
        
        try {
            engrProcess = RecordType_Info__c.getValues(recTypeId).Engineering_Process__c;
        }
        catch(Exception e) {
            //If not found, set a default of the final process that will be in place
            system.debug('CaseModel.getEngineeringProcess - engrProcess for rectypeId '+recTypeId+' failed to be retrieved from RecordType_Info Custom Setting.');
            engrProcess = 'JIRA';
        }
        
        if (engrProcess == 'LM JIRA') {
            engrRecTypeId = Constants__c.getValues('LM_ENGINEERING_CASE_RECORD_TYPE').Value__c;
        }
        else {  //engrProcess = JIRA
            engrRecTypeId = Constants__c.getValues('ENGINEERING_CASE_RECORD_TYPE').Value__c;
    }
        
        return engrRecTypeId;
    } 

    private static void setTarget(Case engineeringCase)
    {
        String ownerQueueID = GenericServices.developmentQueueID;
        if (ownerQueueID != '') {
            engineeringCase.OwnerID = ownerQueueID;
        }
        else {
            engineeringCase.setOptions(GenericServices.defaultAssignmentDBOptions);
        }
    }
    
    private static void setOrigin(Case engineeringCase, Id projectId)
    {
        if (projectId != null) {
            engineeringCase.Project__c = projectId;
            engineeringCase.Originated_From__c =    'PS';
        }
        else {
            engineeringCase.Originated_From__c =    'CS';
        }
    }
    
    private static void setOwnership(Case engineeringCase, Id ownerId)
    {
        User[] u = [Select Id, Name from User where Id=: ownerId];
        
        if (u != null && u.size() > 0) {
            system.debug('@@@ user:' + u[0].Id);
            engineeringCase.Assigned_To__c = u[0].Name;
            engineeringCase.Prior_Case_Owner__c = u[0].Name;
        }
        else {
            engineeringCase.Prior_Case_Owner__c = userinfo.getName();
            system.debug('@@@ user:' + userinfo.getName());
        }
    }
    
    private static void setDescription(Case engCase, string additionalEscalatedCaseNotes)
    {
        if (engCase.Description == null) { engCase.Description = ''; }
        
        if (additionalEscalatedCaseNotes != null && additionalEscalatedCaseNotes.length() > 0) {
            engCase.Description += '\n\nAdditional Notes:\n\n'+additionalEscalatedCaseNotes;
        }
    }
    
    private static List<CaseComment> createCaseComments(Case customerCase, Id engCaseId)
    {
        List<CaseComment> engineeringCaseComments = new List<CaseComment>();
        //List<CaseComment> customerCaseComments = customerCase.getSObjects('CaseComments');
        List<CaseComment> customerCaseComments=[SELECT CommentBody,ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Id,IsDeleted,IsPublished,LastModifiedById,LastModifiedDate,ParentId,SystemModstamp FROM CaseComment WHERE ParentId=:customerCase.id];

        if(customerCaseComments!= null && customerCaseComments.size() > 0) {
            List<CaseComment> caseComments = (List<CaseComment>)CloningServices.cloneRecordsInBulk(customerCaseComments, false);
            system.debug('Size of casecomments list on Engineering case -->>' + caseComments.size());
            for(CaseComment cc: caseComments) {
                system.debug('----Copying the CaseComments----');
                cc.ParentID = engCaseId;
                engineeringCaseComments.add(cc);
            }
        }
        return engineeringCaseComments;
    }

    private static List<Attachment> createAttachments(Case customerCase, Id engCaseId)
    {
        //AK - added the OwnerId in the soql so that it can be set on the Attachment on the Engineering case attachment.
        List<Attachment> attachments = [Select ID, Name, OwnerId from Attachment where ParentID =: customerCase.id];
        List<Attachment> engineeringAttachments = new List<Attachment>();
        if (attachments.size() > 0) {
            
            //Needs to be resolved
            //AK - Commented the below to get rid of the Apex heap size
            /*
            for(Attachment att: (List<Attachment>)CloningServices.cloneRecordsInBulk(attachments, false)) {
                //system.debug('att = ' + att);
                //AK - commented the below so that the Original owner of the Attachment is set as the Owner of the attachment on the Engineering case
                //att.OwnerId = UserInfo.getUserId();
                att.ParentID = engCaseId;
                engineeringAttachments.add(att);
            }
            */
            //AK - Introduced the below for the above functionality
            for(Attachment att: [SELECT Id, ParentId, Name, ContentType, Body, OwnerId, Description, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById FROM Attachment WHERE ParentID =: customerCase.id]) {
                engineeringAttachments.add(new Attachment(Name = att.Name, ContentType = att.ContentType, Body = att.Body, ParentId = engCaseId, OwnerId = att.OwnerId, 
                Description = att.Description , CreatedById = att.CreatedById , CreatedDate = att.CreatedDate, LastModifiedDate = att.LastModifiedDate, 
                LastModifiedById = att.LastModifiedById));
            }
            
        }
        return engineeringAttachments;
    } 
    
    
    private static void updateAndSaveCustomerCase(Case customerCase, Id engCaseId)
    {
        customerCase.ParentId = engCaseId;
        customerCase.Status = Constants.STATUS_ESCALATED;
        customerCase.Sub_Status__c = Constants.SUB_STATUS_ESCALATED;
        customerCase.Case_Category__c = Constants.DEFECT;
        update customerCase;
    }   
    
    private static void updateAndSaveCustomerCase(Case customerCase, Case engCase)
    {
        customerCase.ParentId = engCase.Id;
        customerCase.Status = Constants.STATUS_ESCALATED;
        customerCase.Sub_Status__c = Constants.SUB_STATUS_ESCALATED;
        if(customerCase.EscalateTo__c=='MSDC')
            customerCase.Sub_Status__c = customerCase.EscalateTo__c;
        
        //condition put for SRR 1267287
        if(customerCase.Case_Category__c!='Enhancement Request')
            customerCase.Case_Category__c = Constants.DEFECT;
        update customerCase;
    }   
   
}