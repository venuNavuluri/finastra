/* CaseModel class
*
* 11/15/2011 - Naushad Sunnivohra (Bluewolf)
* Model class for the Case object. 

* 5/Feb/2013 - David Jordan Appirio
* Added extra fields.
* Added Case_Category__c =DEFECT for customer case
*   
*/
public class CaseModel
{
    public CaseModel(Case c)
    {
        record = c;
    }
    public Case record {get; set;}
    public Boolean isCommitted{ get{return (record != null && record.Id != null);}}
    
    public List<CaseComment> caseComments {get; private set;}
    public List<Attachment> attachments {get; private set;}
    
    public Boolean isEscalateable
    {
        get
        {
            return (record.ParentID == null && 
                    record.Status != Constants.STATUS_CLOSED && 
                    record.Steps_to_Reproduce__c != null && 
                    record.Product_Set_Version__c != null && 
                    ((record.Product_Set_Module__c != null && record.Product_Set_Module_Version__c != null) || record.Product_Set_Module__c == null));
        }
    }
    
    public void getCaseComments()
    {
        caseComments = new List<CaseComment>();
        if(record.getSObjects('CaseComments') != null && record.getSObjects('CaseComments').size() > 0)
        {
             caseComments.addAll((List<CaseComment>)record.getSObjects('CaseComments'));
        }
        
    }

    public void getAttachments()
    {
        attachments = new List<Attachment>();
        try
        {
        attachments = [Select ID, Name from Attachment where ParentID =: record.id];
        }catch(Exception exc){}
        
    }
    
    public string getEngineeringProcess(string recTypeId)
    {
        string engrProcess;
        string engrRecTypeId;
        
        try{
            engrProcess = RecordType_Info__c.getValues(recTypeId).Engineering_Process__c;
        }catch(Exception e){
            //If not found, set a default of the final process that will be in place
            system.debug('CaseModel.getEngineeringProcess - engrProcess for rectypeId '+recTypeId+' failed to be retrieved from RecordType_Info Custom Setting.');
            engrProcess = 'JIRA';
        }
        
        if(engrProcess == 'LM JIRA'){
            engrRecTypeId = Constants__c.getValues('LM_ENGINEERING_CASE_RECORD_TYPE').Value__c;
        }
        else
        {   //engrProcess = JIRA
            engrRecTypeId = Constants__c.getValues('ENGINEERING_CASE_RECORD_TYPE').Value__c;
        }
        
        return engrRecTypeId;
    } 
    
    public Case getEscalatedEngineeringCase()
    {
        Case engineeringCase = new Case();
        
        //engineeringCase.RecordTypeId =                        Constants__c.getValues('ENGINEERING_CASE_RECORD_TYPE').Value__c;
        engineeringCase.RecordTypeId =                      getEngineeringProcess(record.RecordTypeId);
        engineeringCase.Status =                            Constants.STATUS_ESCALATED;
        engineeringCase.Sub_Status__c =                     Constants.SUB_STATUS_ESCALATED;
        
        //Adding the below line for the Request Id: 1184538
        engineeringCase.Case_Category__c =                  record.Case_Category__c;
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
        engineeringCase.Subject =                           '[ENGINEERING] '+record.Subject;
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
        
        
        String ownerQueueID = GenericServices.developmentQueueID;
        if(ownerQueueID != ''){
            engineeringCase.OwnerID = ownerQueueID;
        }else{
            engineeringCase.setOptions(GenericServices.defaultAssignmentDBOptions);
        }
    
        if(record.Project__c != null){
            engineeringCase.Project__c =            record.Project__c;
            engineeringCase.Originated_From__c =    'PS';
        }else{
            engineeringCase.Originated_From__c =    'CS';
        }
        
        try
        {
            User u = [Select Id, Name from User where Id=: record.OwnerID];
            if(u != null){
                engineeringCase.Assigned_To__c = u.Name;
                engineeringCase.Prior_Case_Owner__c = u.Name;
            }else{
                engineeringCase.Prior_Case_Owner__c = userinfo.getName();
            }
        }
        catch(Exception exc)
        {}
        
        return engineeringCase;
    }
    
    public String insertEscalatedengineeringCase(Case engCase, String additionalEscalatedCaseNotes)
    {
        if(engCase.Description == null) engCase.Description = '';
        
        if(additionalEscalatedCaseNotes != null && additionalEscalatedCaseNotes.length() > 0)
            engCase.Description += '\n\nAdditional Notes:\n\n'+additionalEscalatedCaseNotes;
        
        insert engCase;
        
        if(caseComments.size() > 0)
        {
            List<CaseComment> engineeringCaseComments = new List<CaseComment>();
                  
            for(CaseComment cc: (List<CaseComment>)CloningServices.cloneRecordsInBulk(caseComments, false))
            {
                cc.ParentID = engCase.id;
                engineeringCaseComments.add(cc);
            }
            
            insert engineeringCaseComments;
        }
        
        if(attachments.size() > 0)
        {
            List<Attachment> engineeringAttachments = new List<Attachment>();
            
            //Needs to be resolved
            for(Attachment att: (List<Attachment>)CloningServices.cloneRecordsInBulk(attachments, false))
            {
                att.ParentID = engCase.id;
                engineeringAttachments.add(att);
            }
            
            insert engineeringAttachments;
        }
        
        
        record.ParentId = engCase.id;
        record.Status = Constants.STATUS_ESCALATED;
        record.Sub_Status__c = Constants.SUB_STATUS_ESCALATED;
        
        //Commenting the below line for the request ID: 1184538 
        //record.Case_Category__c = Constants.DEFECT;
        update record;
        
        return engCase.id;
    }
    
}