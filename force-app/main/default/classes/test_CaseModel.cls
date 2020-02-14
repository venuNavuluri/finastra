@isTest (SeeAllData=TRUE)
private class test_CaseModel 
{
    static testMethod void testConstructor()
    {
        CaseModel cm = new CaseModel(null);
        System.assertEquals(cm.record, null);
        
        Account a = TestUtils.getAccount('ut Acc1');
        insert a;
        Case cs = TestUtils.getCase(a);
        insert cs;
        cm = new CaseModel(cs);
        System.assertEquals(cm.record.id, cs.id);
    }
    
    static testMethod void testIsEscalatable()
    {
        Account a = TestUtils.getAccount('ut Acc1');
        insert a;
        Case csParent = TestUtils.getCase(a);
        insert csParent;
        
        Case cs = TestUtils.getCase(a);
        cs.ParentID = csParent.id;
        cs.Status = Constants.STATUS_CLOSED;
        insert cs;
        CaseModel cm = new CaseModel(cs);
        System.assertEquals(false, cm.isEscalateable);
        
        cm.record.Status = 'New';
        update cm.record;
        System.assertEquals(false, cm.isEscalateable);
        
        cm.record.ParentID = null;
        cm.record.Status = 'Escalated to Engineering';
        //cm.record.Replication_Steps__c = 'steps';
        cm.record.Steps_to_Reproduce__c = 'steps';
        cm.record.Product_Set_Version__c = '1';
        cm.record.Product_Set_Module__c = '2';
        cm.record.Product_Set_Module_Version__c = '3';
        update cm.record;
        System.assertEquals(true, cm.isEscalateable);
    }
    
    static testMethod void testGetCaseComments()
    {
        Account a = TestUtils.getAccount('ut Acc1');
        insert a;
        Case cs = TestUtils.getCase(a);
        insert cs;
        CaseModel cm = new CaseModel(cs);
        System.assertEquals(null, cm.caseComments);
        
        cm.getCaseComments();
        System.assertEquals(0, cm.caseComments.size());
        
        CaseComment cc = TestUtils.getCaseComment(cs);
        insert cc;
        cs = [Select id, (Select id from CaseComments) from Case where id =: cs.id];
        cm = new CaseModel(cs);
        cm.getCaseComments();
        System.assertEquals(1, cm.caseComments.size());
    }
    
    static testMethod void testGetAttacments()
    {
        Account a = TestUtils.getAccount('ut Acc1');
        insert a;
        Case cs = TestUtils.getCase(a);
        insert cs;
        CaseModel cm = new CaseModel(cs);
        System.assertEquals(null, cm.attachments);
        
        cm.getAttachments();
        System.assertEquals(0, cm.attachments.size());
        
        Attachment att = TestUtils.getAttachment(cs.id);
        insert att;
        cm.getAttachments();
        System.assertEquals(1, cm.attachments.size());
    }
    
    static testMethod void  testGetEscalatedEngineeringCase()
    {
        Account a = TestUtils.getAccount('ut Acc1');
        insert a;
        Case cs = TestUtils.getCase(a);
        cs.Severity__c = 'sev 1';
        insert cs;
        CaseModel cm = new CaseModel(cs);
        
        
        
        Case engineeringCase = cm.getEscalatedEngineeringCase();
        //System.assertEquals(CaseServices.recordTypesNameMap.get(Constants.ENGINEERING_CASE_RECORD_TYPE).id, engineeringCase.recordTypeId);
        //System.assertEquals(Constants.STATUS_NEW, engineeringCase.Status);
        //System.assertEquals(Constants.STATUS_NEW,
        System.assertEquals(cs.Severity__c , engineeringCase.Severity__c);
        //System.assertEquals(GenericServices.developmentQueueID, engineeringCase.OwnerID);
        System.assertEquals('[ENGINEERING] '+cs.Subject, engineeringCase.Subject);
        
    }
    
    static testMethod void testInsertEscalatedEngineeringCase()
    {
        Account a = TestUtils.getAccount('ut Acc1');
        insert a;
        User testAdmin = [SELECT Id, name, IsActive FROM User WHERE profile.name = 'System Administrator' and name != '' and isactive = true LIMIT 1];
        User u;
        system.runAs(testAdmin){
            u = TestUtils.getStandardInternalUser('testUT_1');
            insert u;
        }

        Case cs = TestUtils.getCase(a);
        cs.Severity__c = 'sev 1';
        cs.Replication_Steps__c = 'some steps ';
        cs.OwnerId = u.id;
        insert cs;
        CaseComment cc = TestUtils.getCaseComment(cs);
        insert cc;
        Attachment att = TestUtils.getAttachment(cs.id);
        insert att;
        cs = [Select ID, CaseNumber, Subject, ParentID, Internal_Severity__c, Status, Product_Set_Text__c, System_Text__c, Case_Category__c,
             Product_Version__c, Client_Asset__c, Client_Asset_Text__c, Description, AccountID, ContactID, Support_Entitlement__c, 
             Contract_Asset__c, Contract_Asset__r.Name, /*Version__c,*/ Environment2__c, Database__c, Database_Version__c, Origin, Type, Severity__c,
             Replication_Steps__c, Account.Name, Contact.Name, Contact.Email, Contact.Phone, System__c, Product_Set__c, Product_Set_Module__c,
             Project__c, Priority, Closure_Resolution_Details__c, OwnerID, ProductID, Steps_to_Reproduce__c, Product_Set_Version__c, 
             Product_Set_Module_Version__c, Product_Set__r.Name, Client_Asset__r.Name, System__r.Name,  RecordTypeId,Customer_Case_Created_Date__c,CreatedDate,
             Self_Service_Product__c, Customer_Name__c,Hardware__c,Product_Module__c, Operating_System_Version__c, System_Status__c,
             (Select id from CaseComments) 
             from Case where id =: cs.id];
        CaseModel cm = new CaseModel(cs);
        cm.getCaseComments();
        cm.getAttachments();
        
        Case engineeringCase = cm.getEscalatedEngineeringCase();
        String engCaseid = cm.insertEscalatedEngineeringCase(engineeringCase, 'some notes');
        
        cm.record =  [Select ID, CaseNumber, Subject, ParentID, Severity__c, Internal_Severity__c, Status, Client_Asset__r.Name, 
             Description, AccountID, ContactID, EntitlementID, Support_Entitlement__c, Product_Set__c, System_Text__c,
             Client_Asset__c, /*Version__c,*/ Environment2__c, Database__c, Database_Version__c, Origin, Type, Priority, 
             Project__c, Replication_Steps__c, System__c, Contract_Asset__c, Product_Set_Text__c, Client_Asset_Text__c,
             Account.Name, Contact.Name, Contact.Email, Contact.Phone, Resolution_Type__c, Closure_Resolution_Details__c,
             OwnerID, Productid, (Select id, CommentBody from CaseComments) 
                     from Case where id =: cs.id];
                     
        cm.getCaseComments();
        
        engineeringCase = [Select ID, Description, CaseNumber, Subject, ParentID, Severity__c, Status, Environment2__c from Case where id =: engCaseid];
        CaseComment[] engCaseComments = [Select id, CommentBody from CaseComment where parentId =: cm.record.id];
        Attachment engCaseAtt = [Select id, Body, Name from Attachment where parentId =: cm.record.id limit 1];
        
        for (integer i = 0; i < cm.caseComments.size(); i++) {
            System.assertEquals(cm.caseComments[i].CommentBody, engCaseComments[i].CommentBody);
        }
        System.assertEquals(cm.attachments[0].Name, engCaseAtt.Name);
        System.assertEquals(cm.record.ParentID, engineeringCase.Id);
        System.assertEquals(cm.record.Environment2__c, engineeringCase.Environment2__c);
        System.assertEquals(Constants.STATUS_ESCALATED,  cm.record.Status);
        
        
    }
}