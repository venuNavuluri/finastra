/* EscalateToEngineeringControllerExtension class
*
* 11/28/2011 - Naushad Sunnivohra (Bluewolf)
* Controller class for Escalate To Engineering Page
* 
* 7/30/12 - Jason Bennett (Misys)
* Copied directly from Turaz org to Misys org 
*
* 5/Feb/2013 - David Jordan Appirio
* Added extra fields
*
*/

public class EscalateToEngineeringContExt
{
    private Case c;
    public Case engineeringCase{get; private set;}
    public String additionalEscalatedCaseNotes {get; set;}
    
    public EscalateToEngineeringContExt(ApexPages.StandardController std)
    {
        Boolean bError = false;
        
        c = (Case)std.getRecord();
        
        //Check if the user is in a correct profile to Escalate to Engineering
        if(!Label.Case_Escalate_To_Engineering.contains(UserInfo.getProfileId())){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Case_User_Profile_Cannot_Escalate_To_Engineering));
            return;
        }
        
        cm = new CaseModel(c);
        
        if(!cm.isCommitted)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.You_can_only_escalate_a_committed_Case));
            return ;
        }
        
        //Needs to be resolved
        cm.record = [Select ID, CaseNumber, Subject, ParentID, Internal_Severity__c, Status, Product_Set_Text__c, System_Text__c, case_category__c,
             Product_Version__c, Client_Asset__c, Client_Asset_Text__c, Description, AccountID, ContactID, Support_Entitlement__c, 
             Contract_Asset__c, Contract_Asset__r.Name, Environment2__c, Database__c, Database_Version__c, Origin, Type, Severity__c,
             Replication_Steps__c, Account.Name, Contact.Name, Contact.Email, Contact.Phone, System__c, Product_Set__c, Product_Set_Module__c,
             Project__c, Priority, Closure_Resolution_Details__c, OwnerID, ProductID, Steps_to_Reproduce__c, Product_Set_Version__c, 
             Product_Set_Module_Version__c, Product_Set__r.Name, Client_Asset__r.Name, System__r.Name, Prior_Case_Owner__c, RecordTypeId,Customer_Case_Created_Date__c,CreatedDate,
             Self_Service_Product__c, Customer_Name__c,Hardware__c,Product_Module__c, Operating_System_Version__c, System_Status__c,
             (Select Id from CaseComments),
             (Select Id from Attachments)
             from Case where id=: c.id];
        
        
        if(!cm.isEscalateable)
        {
            if(cm.record.ParentId != null)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.Cases_with_existing_Parents_and_Closed_Cases_cannot_be_escalated));
            }
            if(cm.record.Steps_to_Reproduce__c == null)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Required field must be filled in: Steps to Reproduce'));
            }
            // Commented out by David Jordan Appirio 14th 2013 March on MC's instructions
            /*if(cm.record.Product_Set__c == null)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Required field must be filled in: Product Set'));
            }*/
            if(cm.record.Product_Set_Version__c == null)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Required field must be filled in: Product Set Version'));
            }    
            if(cm.record.Product_Set_Module__c != null && cm.record.Product_Set_Module_Version__c == null)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Required field must be filled in: Product Set Module Version'));
            }    
            return;
        }
        
        
        init();
        
    }
    public CaseModel cm {get; private set;}
    
    
    private void init()
    {
        additionalEscalatedCaseNotes = '';
        engineeringCase = cm.getEscalatedEngineeringCase();
        cm.getCaseComments();
        cm.getAttachments();
    }
    
    public PageReference createEscalatedCase()
    {
        SavePoint sp = Database.setSavePoint();
        try
        {
            String id = cm.insertEscalatedEngineeringCase(engineeringCase, additionalEscalatedCaseNotes);
            PageReference pr = new PageReference('/'+id);
            pr.setRedirect(true);
            return pr;
        }
        catch(DMLException dmle)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, System.label.General_Error_On_Case+': '+dmle));
            Database.rollBack(sp);
            init();
        }
        catch(Exception exc)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, System.label.General_Error_On_Case+': '+exc));
            Database.rollBack(sp);
            init();
        }
        return null;
    } 
    
    public PageReference backToCase()
    {
        //PageReference pr = new PageReference('/'+cm.record.id);
        PageReference pr = new PageReference('/'+c.id);
        return pr;
    }
}