public with sharing class community_SearchResultsController {
	private List<Case> Cases = New List<Case>();
	public string GAUserId {get;set;}
    public string searchText {get;set;}
    public string searchOptions {get;set;}
    private String currentId ;
    private Map<Id,RecordType> mapRecordTypeName;
    public String RoleName {get;set;}
    private String accountId;
    private Set<String> excludedRTId {get; set;}
	public boolean showCloseDate {get;set;}
	private string searchStr {get;set;}
    private string searchType {get;set;}

	public community_SearchResultsController() {
		searchStr = ApexPages.currentPage().getParameters().get('sbstr');
        searchType = ApexPages.currentPage().getParameters().get('s');
		GAUserId = UserInfo.getUserId();
        showCloseDate = false;
        mapRecordTypeName = New Map<Id,RecordType>([select Id, Name from RecordType where sObjectType = 'Case' and isActive = true]);

        List<User> currentUser = [SELECT contactId, userroleId, AccountId From User where Id = :UserInfo.getUserId() ];
        currentId = currentUser[0].ContactId;
        if(RoleName != '') {
            RoleName = [SELECT Name FROM userrole where Id =: currentUser[0].UserRoleId].Name;
        }
        accountId = currentUser[0].AccountId;
        //currentId = '0032000001JID5D';
        system.debug('@@@@@@@@Acct:'+accountId);
        
        excludedRTId = New Set<String>();
        List<RecordType> excludedRecordTypes = New List<RecordType>();
        excludedRecordTypes = [select id from recordtype WHERE sobjecttype = 'case' and isActive = true AND (name = 'Sales Operations Support Services' OR Name='Surveys' OR name='Customer Feedback' OR Name='ACE360' or name='COM Escalation' or name ='Operations Service Request' or name = 'Project Cases')];
        for(RecordType excludedIds : excludedRecordTypes ) {
            excludedRTId.add(excludedIds.Id);
        }
	}

	public List<Case> GetCases() {
        if(searchType == 'cases') {
            List < List < sObject >> searchList;
            String wildcard = '*';
            String SearchQuery = 'FIND\' ' + string.escapeSingleQuotes(searchStr) + wildcard + '\' RETURNING Case (Id,Account_Name__c, AccountId, ContactId, CaseNumber, Status, Subject, Priority, Severity__c, ClosedDate, RecordTypeName__c, Your_Account_Site__c, Your_Contact_Name__c, Sub_Status__c, CreatedDate, RecordTypeId,Client_Reference__c,System_Status__c WHERE IsVisibleInSelfService = true AND RecordTypeId NOT IN : excludedRTId ORDER BY CaseNumber DESC LIMIT 600)';

            searchList = search.query(SearchQuery);
            Cases = searchList[0];
            

        } else if (searchType == 'comments') {
            List < List < sObject >> searchList;
            String wildcard = '*';
            String SearchQuery = 'FIND\' ' + string.escapeSingleQuotes(searchStr) + wildcard + '\' RETURNING CaseComment (CommentBody, ParentId) ';

            searchList = search.query(SearchQuery);
            List<CaseComment> comment = searchList[0];
            Map<Id, string> commentMap = New Map<Id, String>();
            for(CaseComment c : comment) {
                commentMap.put(c.ParentId, c.CommentBody);
            }
            Set<ID> caseIds = new Set<ID>();
            caseIds = commentMap.keySet();
            system.debug('@@@@@@@@ids:'+caseIds);
            if(RoleName.contains('Executive')){
                Cases = [SELECT Id,Account_Name__c, AccountId, ContactId, CaseNumber, Status, Subject, Priority, Severity__c, ClosedDate, RecordTypeName__c, 
                Your_Account_Site__c, Your_Contact_Name__c, Sub_Status__c, CreatedDate, RecordTypeId,Client_Reference__c,System_Status__c
                FROM Case WHERE Id In :caseIds  AND IsVisibleInSelfService = true AND RecordTypeId NOT IN : excludedRTId  LIMIT 600];
            } else {
                Cases = [SELECT Id,Account_Name__c, AccountId, ContactId, CaseNumber, Status, Subject, Priority, Severity__c, ClosedDate, RecordTypeName__c, 
                Your_Account_Site__c, Your_Contact_Name__c, Sub_Status__c, CreatedDate, RecordTypeId,Client_Reference__c,System_Status__c
                FROM Case WHERE ContactId =: currentId AND Id In :caseIds  AND IsVisibleInSelfService = true AND RecordTypeId NOT IN : excludedRTId  LIMIT 600];
            }
            

        } else if  (searchType == 'attachments'){
            List < List < sObject >> searchList;
            String wildcard = '*';
            String SearchQuery = 'FIND\' ' + string.escapeSingleQuotes(searchStr) + wildcard + '\' RETURNING Attachment (Name, ParentId) ';

            searchList = search.query(SearchQuery);
            List<Attachment> attachment = searchList[0];
            Map<Id, string> attachmentMap = New Map<Id, String>();
            for(Attachment a : attachment) {
                attachmentMap.put(a.ParentId, a.Name);
            }
            Set<ID> attachmentIds = new Set<ID>();
            attachmentIds = attachmentMap.keySet();
            system.debug('@@@@@@@@ids:'+attachmentIds);
            if(RoleName.contains('Executive')){
                Cases = [SELECT Id,Account_Name__c, AccountId, ContactId, CaseNumber, Status, Subject, Priority, Severity__c, ClosedDate, RecordTypeName__c, 
                Your_Account_Site__c, Your_Contact_Name__c, Sub_Status__c, CreatedDate, RecordTypeId,Client_Reference__c,System_Status__c
                FROM Case WHERE Id In :attachmentIds  AND IsVisibleInSelfService = true AND RecordTypeId NOT IN : excludedRTId  LIMIT 600];
            } else {
                Cases = [SELECT Id,Account_Name__c, AccountId, ContactId, CaseNumber, Status, Subject, Priority, Severity__c, ClosedDate, RecordTypeName__c, 
                Your_Account_Site__c, Your_Contact_Name__c, Sub_Status__c, CreatedDate, RecordTypeId,Client_Reference__c,System_Status__c
                FROM Case WHERE ContactId =: currentId AND Id In :attachmentIds  AND IsVisibleInSelfService = true AND RecordTypeId NOT IN : excludedRTId  LIMIT 600];
            }
            
        } else {
            cases = null;
        }

		if(Cases != null){
                return Cases;
            }
            else{
                return null;
            }
	}

    public Pagereference search() {
        searchStr = searchText;
        searchType = searchOptions;
        return null;
    }

    public List<SelectOption> getItems() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('cases','Cases'));
            options.add(new SelectOption('comments','Comments'));
            options.add(new SelectOption('attachments','Attachments'));
            return options;
        }

}