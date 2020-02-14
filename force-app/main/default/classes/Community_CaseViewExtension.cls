public class Community_CaseViewExtension {
    
    public Case theCase {get; set;}
    
    public Boolean showKondor {get; set;}
    public Boolean showAllProducts {get; set;}
    public Boolean showDigitalChannels {get; set;}
    public Boolean showSophis {get; set;}
    public Boolean showKondorAdditional {get; set;}
    public Boolean showKondorJira {get; set;}
    public Boolean showAllProductsAdditional {get; set;}
    public Boolean showFusion {get; set;}
    public Boolean showPriority {get; set;}
    // MR 15-07-2015 - additions to facilitate Premium Support Services record type
	public Boolean showPremiumSupport {get; set;}    
    // end of 15-07-2015 additions
    public Group caseGroup {get; set;}
    public User caseOwner {get; set;}
    public boolean showGroup {get; set;}
    public boolean showUser {get; set;}
    public string systemName {get; set;}
    public User triageName {get;set;}
    public string dateTimeValue { get; set; }
    public string closedDateTimeValue {get; set;}
    public integer offset {get;set;}
    public string caseDescription {get;set;}
    //public List<Attachment> caseAttachment {get; set;}
    public List<KnowledgeWrapper> KnowledgeArticles {get; set;}
    public List<CaseCommentsWrapper> caseComments {get; set;}
    public List<AttachmentWrapper> caseAttachment {get; set;}
    public List<CaseHistoryWrapper> caseHistory {get;set;}
    //public List<Case_Event__c> caseEvents { get; set; }
    //public Contact thisContact {get; set;}
    //public Account thisAccount {get; set;}
    private KnowledgeWrapper KnowledgeObject;
    private boolean isEdit = false;


    public Community_CaseViewExtension(ApexPages.StandardController controller) {
		// MR 15-07-2015 - additional fields to facilitate Premium Support Services record type
        theCase = [SELECT AccountId, ContactId, CaseNumber, Status, Reason, Subject, Priority, Severity__c, ClosedDate, OwnerId, Client_Reference__c, System_Status__c, Product_Set__c,
        Product_set_Module__c, Product_Set_Text__c, RecordTypeName__c, Your_Account_Site__c, Your_Contact_Name__c, Sub_Status__c, CreatedDate,Account_Name__c, Self_Service_Product__c,
        System__c, description, Operating_System_Version__c, Program_Name__c, Program_Version__c, Hardware__c, Origin, Case_Category__c, Your_Contact_Phone__c, Delivery_Reference__c,
        Customer_Delivery_Date__c, Product_Version__c, Your_Contact_Email__c, Database__c, Database_Version__c, System_Id__c, Patch_Level__c, Cross_Reference__c,Change_Reference__c,
        Committed_Delivery_Date__c, IND_Migrated_Case__c, IND_Component__c, IND_Legacy_ID__c, IND_Environment__c, IND_Project_Name__c, Product_Module__c, PS_Project__c, PS_Project_Name__c,
        MD_Man_Day__c, Misys_Sophis_Category__c, Released_In_Version__c, Misys_Sophis_Sub_Category__c, Field_4__c, JIRA_ID_Sophis_only__c, TTP_ID__c, Userdesk_ID__c, CCS_Migrated_Case__c,
        Mantis_Legacy_ID__c, JIRA_ID__c, JIRA_ID_2__c, JIRA_ID_3__c, Engineering_Target_Release_Qtr__c, Engineering_Target_Release__c, JIRA_ID_2_Target_Release_Date__c, JIRA_ID_2_Target_Release_Version__c,
        JIRA_ID_3_Target_Release_Date__c, JIRA_ID_3_Target_Release_Version__c, Case_Closure_Reason__c, Closure_Resolution_Details__c, Product_Set_Module_Version__c, Product_Set_Version__c, 
        Legacy_Turaz_Product_Set_temp__c, RecordTypeId, createdbyId, Billing_Address__c, Billing_Currency__c, Type_of_Request__c, Service_Request_Items__c, Specify_type_of_service_needed__c,
        Service_Start_Date__c, Service_End_Date__c, Service_Start_Time__c, Service_End_Time__c, Location_Time_zone_where_support_req__c, Booked_Support_Product_s__c, Operating_System_Name_Version__c,
        Database_Name_Version__c, LastModifiedById, Case_Last_Updated__c, SuppliedEmail, RecordType.Name, Owner.Name, Created_By_Name__c, Type, your_account_name__c, Related_Case__r.CaseNumber,
        Reproduced__c, First_Occurrence__c, Details_when_error_occurred_reproduced__c, Related_Case__c, Actions_done_to_do_workaround_or_resolve__c, Did_you_find_KB_articles_helpful__c,
        Product_document_used_for_analysis__c, Other_resources_used_for_analysis__c, Number_of_users_affected__c,System_changes_that_may_impact_analysis__c, Project_ID_from_Portal__c ,
        Workaround_Provided__c, Triage_By__c, Triage_Status__c, Regression__c
        FROM Case WHERE Id =:controller.getRecord().Id limit 1];

        //set the case time to the user locale settings
        //date dateValue = thecase.CreatedDate.date();
        //Time timeValue = theCase.CreatedDate.time();
        //User currentUser = [Select TimeZoneSidKey from User where id =: thecase.createdbyId];
        //Timezone tz = Timezone.getTimeZone(currentUser.TimeZoneSidKey);
        //datetime dtpre = datetime.newInstance(dateValue,timeValue);
        //dateTimeValue = dtpre;
        //offset = tz.getOffset(dtpre);
        dateTimeValue = thecase.CreatedDate.format();
        try {
            closedDateTimeValue = theCase.ClosedDate.format();
        } catch (Exception e) {
            closedDateTimeValue ='';
        }
        
        caseDescription = lineBreaks(theCase.description);

        showKondor = false;
        showDigitalChannels = false;
        showAllProducts = false;
        showSophis = false;
        showAllProductsAdditional = false;
        showFusion = false;
        showKondorJira = false;
        showPriority = false;
        // MR 15-07-2015 - additions to facilitate Premium Support Services record type
        showPremiumSupport = false;

        //grab all record types for case object
        Map<String,RecordType> caseRecordTypesByName = new Map<String,RecordType>();
        for (List<RecordType> recordTypes :  [SELECT Id, Name FROM RecordType WHERE sobjecttype = 'case' and isActive = true]){
           for (RecordType recordType : recordTypes){
               caseRecordTypesByName.put(recordType.Name, recordType);
           }
        }

        if (theCase.RecordTypeId == caseRecordTypesByName.get('Kondor').Id) {
            showKondor = true;
            showKondorJira = true;
            showKondorAdditional = true;
            showAllProducts = false;
            showAllProductsAdditional = false;
            showSophis = false;
            showDigitalChannels = false;
            showFusion = false;
        } else if(theCase.RecordTypeId == caseRecordTypesByName.get('Digital Channels').Id) {
            showKondor = false;
            showKondorJira = false;
            showKondorAdditional = false;
            showAllProducts = true;
            showAllProductsAdditional = false;
            showSophis = false;
            showDigitalChannels = true;
            showFusion = false;
        } else if(theCase.RecordTypeId == caseRecordTypesByName.get('Misys Sophis').Id) {
            showKondor = false;
            showKondorJira = false;
            showKondorAdditional = false;
            showAllProducts = true;
            showAllProductsAdditional = false;
            showSophis = true;
            showDigitalChannels = false;
            showFusion = false;
        } else if(theCase.RecordTypeId == caseRecordTypesByName.get('FusionBanking (Lending)').Id) {
            showKondor = false;
            showKondorJira = false;
            showKondorAdditional = false;
            showAllProducts = true;
            showAllProductsAdditional = false;
            showSophis = false;
            showDigitalChannels = false;
            showFusion = true;
        // MR 15-07-2015 - additions to facilitate Premium Support Services record type
        } else if(theCase.RecordTypeId == caseRecordTypesByName.get('Premium Support Services').Id) {
        	showKondor = false;
            showKondorJira = false;
            showKondorAdditional = false;
            showAllProducts = false;
            showAllProductsAdditional = false;
            showSophis = false;
            showDigitalChannels = false;
            showFusion = false;
            showPremiumSupport = true;
        // end of 15-07-2015 additions
        } else {
            showAllProducts = true;
            showAllProductsAdditional = true;
            showPriority = true;
            showKondor = false;
            showKondorJira = false;
            showKondorAdditional = false;
            showSophis = false;
            showDigitalChannels = false;
            showFusion = false;
        }
        
        system.debug('Debug owner Id: ' + theCase.OwnerId);
        showGroup = true;
        showUser = false;
        try {
            caseGroup = [SELECT Name FROM Group WHERE Type = 'Queue' AND Id =: theCase.OwnerId];
        } catch (Exception e) {
            system.debug(e);
            showGroup = false;
            showUser = true;
            
        }

        try {
               caseOwner = [SELECT firstname, lastname FROM User WHERE Id =: theCase.OwnerId];
            } catch (Exception e) {
                caseOwner = null;
            }

        try {
            systemName = [SELECT name from system__c where id=: theCase.system__c ].Name;
        } catch (Exception ex) {
            systemName = ' ';
        }
        
        try {
            triageName = [SELECT firstname, lastname FROM user WHERE id=: theCase.Triage_By__c];
        } catch (Exception e) {
            triageName = null;
        }
        
        //thisContact = [SELECT ]
        
        caseComments = New List<CaseCommentsWrapper>();
        List<CaseComment> tmpComments = New List<CaseComment>();
        tmpComments = [Select LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, CreatedDate, CreatedBy.Id, CreatedBy.Name, CommentBody 
        From CaseComment c where ParentId =: theCase.Id AND IsPublished=true ORDER By createdDate DESC];
        for(CaseComment c: tmpComments) {
            //for(CaseComment comment: c) {
                CaseCommentsWrapper wrapperObject = New CaseCommentsWrapper();
                wrapperObject.commentBody = c.CommentBody;
                wrapperObject.createdByName = c.CreatedBy.Name;
                wrapperObject.createdDate = c.Createddate;
                caseComments.add(wrapperObject);
            //}
        }

        Set<String> allUsers = new Set<String>();

        List<Attachment> caseAttachments = New List<Attachment>();
        caseAttachments = [SELECT Id, Name, LastModifiedById, LastModifiedDate, CreatedById, BodyLength  FROM Attachment WHERE ParentId = :theCase.Id ORDER BY LastModifiedDate DESC];
        for(Attachment att: caseAttachments) {
            allUsers.add(att.CreatedById);
        }

        List<User> potentialUsers = [SELECT Id, Name FROM User WHERE Id IN :allUsers];

        Map<String, User> nameToUserMap = new Map<String, User>();
        for (User u : potentialUsers) {
            nameToUserMap.put(u.Id, u);
        }

        caseAttachment = New List<AttachmentWrapper>();
        for(Attachment att: caseAttachments) {
            User creator = nameToUserMap.get(att.createdbyId);
            AttachmentWrapper a = New AttachmentWrapper();
            a.AttachmentId = att.Id;
            a.AttachmentName = att.Name;
            a.LastModifiedDate = att.LastModifiedDate;
            a.BodyLength = att.BodyLength;
            if (creator != null) {
                a.CreatedByName = creator.Name;
            }
            
            caseAttachment.add(a);
        }

        // Case Events
        //caseEvents = [select Id, Summary__c, Owner.Name, Event_Date__c from Case_Event__c where Case__c = :theCase.Id and Public__c = true];
        
        Set<String> allArticles = New Set<String>();
        List<CaseArticle> articles = New List<CaseArticle>();
        articles = [SELECT knowledgeArticleId FROM CaseArticle WHERE CaseId = :theCase.Id];
        for(CaseArticle a: articles) {
            allArticles.add(a.KnowledgeArticleId);
        }
        KnowledgeArticles = New List<KnowledgeWrapper>();
        
        List<KnowledgeArticleVersion> articleVersion = New List<KnowledgeArticleVersion>();
        articleVersion = [SELECT Title,id,knowledgearticleId,Summary,lastpublisheddate,articlenumber,URLName FROM knowledgeArticleVersion WHERE PublishStatus = 'Online' AND  KnowledgearticleId IN : allArticles];
     
                for(KnowledgeArticleVersion article : articleVersion){
                    KnowledgeObject = New KnowledgeWrapper();
                    KnowledgeObject.ArticleId = article.knowledgearticleId;
                    KnowledgeObject.Summary = article.summary;
                    KnowledgeObject.LastPublishedDate = article.lastpublisheddate;
                    KnowledgeObject.Title = article.Title;
                    KnowledgeObject.ArticleNumber = article.articlenumber;
                    KnowledgeObject.ArticleURL = '/apex/community_KnowledgeArticle?Id=' + article.knowledgearticleId;
                    KnowledgeArticles.Add(KnowledgeObject);
                } 
       
       Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Case.fields.getMap();
       caseHistory = New List<CaseHistoryWrapper>();
       //TestUtility oUtil = TestUtility.getInstance();
       //List<CaseHistory> history = New List<CaseHistory>();
       //if(oUtil.isTestRunning) {
       //     history = [SELECT createdBy.Name, createdDate, Field, oldValue, NewValue FROM CaseHistory ORDER BY createdDate DESC LIMIT 500];
      //  } else {
      // 		history = [SELECT createdBy.Name, createdDate, Field, oldValue, NewValue FROM CaseHistory WHERE caseId = : theCase.Id ORDER BY createdDate DESC];
                   
       // }
        
       for(List<CaseHistory> history : [SELECT createdBy.Name, createdDate, Field, oldValue, NewValue FROM CaseHistory WHERE caseId = : theCase.Id ORDER BY createdDate DESC]) {
            system.debug('@@@ history ' + history);
            for(CaseHistory h : history) {
                CaseHistoryWrapper chw = New CaseHistoryWrapper();
                if(h.Field == 'System_Status__c') {
                    chw.fieldName = 'Case Status';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                    chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    caseHistory.add(chw);
                }
                else if(h.Field == 'Self_Service_Product__c') {
                    chw.fieldName = 'Product';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                    chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    caseHistory.add(chw);
                }
                else if (h.Field == 'Product_Version__c') {
                    chw.fieldName = 'Product Version';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                    chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    caseHistory.add(chw);
                }
                else if (h.field == 'Type') {
                    chw.fieldName = 'Type';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                    chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    caseHistory.add(chw);
                }
                else if (h.field == 'Customer_Delivery_Date__c') {
                    chw.fieldName = 'Customer Delivery Date';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                    chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    caseHistory.add(chw);
                }
                else if (h.field == 'Case_Category__c') {
                    chw.fieldName = 'Case Category';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                    chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    caseHistory.add(chw);
                }
                else if (h.field == 'Triage_Status__c') {
                    chw.fieldName = 'Triage Status';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                    chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    caseHistory.add(chw);
                }
                else if (h.field == 'Triage_By__c') {
                    chw.fieldName = 'Triage Owner';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                    chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    if (String.valueOf(h.newValue) != null) {
	                    String myIdPrefix = String.valueOf(h.newValue).substring(0,3);
    	                if(myIdPrefix!='005') {
        	                caseHistory.add(chw);
            	        }
                    }
                }
                else if (h.field == 'Workaround_Provided__c ') {
                    chw.fieldName = 'Workaround Provided';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                    chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    caseHistory.add(chw);
                }
                else if (h.field == 'Severity__c') {
                    chw.fieldName = 'Severity';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                   chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    caseHistory.add(chw);
                }
                else if (h.field == 'created') {
                    chw.fieldName = 'Date/time Opened';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                    chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    caseHistory.add(chw);
                }
                else if (h.field == 'ClosedDate') {
                    chw.fieldName = 'Date/time Closed';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                    chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    caseHistory.add(chw);
                }
                else if(h.field == 'Subject') {
                    chw.fieldName = 'Subject';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                    chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    caseHistory.add(chw);
                }
                else if(h.field =='Case_Last_Updated__c') {
                   // chw.fieldName = 'Case Last Updated';
                   // chw.createdBy = h.createdBy.Name;
                   // chw.createdDate = h.createdDate;
                   // chw.oldValue = string.valueOf(h.oldValue);
                   // chw.newValue =  string.valueOf(h.newValue);
                   // caseHistory.add(chw);
                }
                else if(h.field =='Sub_Status__c') {
                    chw.fieldName = 'Sub Status';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                    chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    caseHistory.add(chw);
                }
                else if(h.field =='Status') {
                    chw.fieldName = 'Status';
                    chw.createdBy = h.createdBy.Name;
                    chw.createdDate = h.createdDate;
                    chw.oldValue = string.valueOf(h.oldValue);
                    chw.newValue =  string.valueOf(h.newValue);
                    caseHistory.add(chw);
                }
            }
           
       		}
    }
   

    public PageReference FindArticle() {
        PageReference pageRef = new PageReference('/_ui/knowledge/ui/KnowledgeHome?id=' + theCase.Id  + '&objectType=Article');
       // PageReference pageRef = new PageReference('/apex/community_MI_Knowledge?sfdc.tabName=01r20000000QijY');
        return pageRef;
    }

    public PageReference AddComment() {
        PageReference pageRef = new PageReference('/00a/e?parent_id=' + theCase.Id  + '&retURL=%2FSupportCommunity/'+ theCase.Id );
        return pageRef;
    }

    public PageReference AttachFile() {

        PageReference pageRef = new PageReference('/p/attach/NoteAttach?pid=' + theCase.Id  + '&parentname=' + theCase.CaseNumber +'&retURL=%2FSupportCommunity/'+ theCase.Id);
        return pageRef;
    }
    
    public PageReference AddCaseEvent() {
        PageReference pageRef = new PageReference('/apex/CaseEvent?caseId=' + theCase.Id);
        return pageRef;
    }
    
    // MR 15-07-2015 - additions to facilitate Premium Support Services record type
   /* public static List<schema.fieldsetmember> getFields(String objectName, String fieldSetName) {  
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();            
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);        
        return fieldSetObj.getFields(); 
	} */

    public Boolean getIsEdit() {
        return isEdit;
    }
    
    public void edit() {
        isEdit=true;
    }    

    public void cancel() {
        isEdit=false;
        
    }
    
     public void save() {
               
        try {
            
            if (theCase != null) { 
                update theCase;
            }
            isEdit = false;
            
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }
    
    private string lineBreaks(string inText)
    {
       if (inText == null)
           return '';
       else {
            return inText.replaceAll('<','(').replaceAll('>',')').replaceAll('\n','<br/>');
       }

           
    }
    
    public class CaseHistoryWrapper {
        public string fieldName {get;set;}
        public datetime createdDate {get;set;}
        public string createdBy {get;set;}
        public string oldValue {get;set;}
        public string newValue {get;set;}

        public CaseHistoryWrapper() {

        }

    }
}