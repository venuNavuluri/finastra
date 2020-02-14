public with sharing class community_CaseListingController {
    private List<Case> Cases = New List<Case>();
    public string selectedCaseOption 
        {get {
            if(selectedCaseOption == null) {
                selectedCaseOption = '';
            }
            return selectedCaseOption;
        } set;}
    public boolean showCloseDate {get;set;}
    public string GAUserId {get;set;}
    private String currentId ;
    private Map<Id,RecordType> mapRecordTypeName;
    public String RoleName {get;set;}
    private String accountId;
    private Set<String> excludedRTId {get; set;}
    
    public community_CaseListingController() {
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
        system.debug('@@@@@@@@@RoleName' + RoleName);
        if((selectedCaseOption =='' || selectedCaseOption == 'MyOpen') && (RoleName.contains('User')  || RoleName.contains('Executive'))) {
            showCloseDate = false;
            Cases = [SELECT Id,Account_Name__c, AccountId, ContactId, CaseNumber, Status, Subject, Priority, Severity__c, ClosedDate, RecordTypeName__c, 
                Your_Account_Site__c, Your_Contact_Name__c, Sub_Status__c, CreatedDate, RecordTypeId,Client_Reference__c,System_Status__c
                FROM Case WHERE ContactId =: currentId AND Status <> 'Closed' AND IsVisibleInSelfService = true AND RecordTypeId NOT IN : excludedRTId ORDER BY CaseNumber DESC LIMIT 500];
          
            } else if (selectedCaseOption == 'AllOpen' && RoleName.contains('Executive')){
                showCloseDate = false;
                Cases = [SELECT Id,Account_Name__c, AccountId, ContactId, CaseNumber, Status, Subject, Priority, Severity__c, ClosedDate, RecordTypeName__c, 
                Your_Account_Site__c, Your_Contact_Name__c, Sub_Status__c, CreatedDate, RecordTypeId,Client_Reference__c,System_Status__c
                FROM Case WHERE Status <> 'Closed' AND IsVisibleInSelfService = true AND RecordTypeId NOT IN : excludedRTId ORDER BY CaseNumber DESC LIMIT 500] ;
           
            } else if (selectedCaseOption == 'AllClosed' && RoleName.contains('Executive')) {
                showCloseDate=true;
                Cases = [SELECT Id,Account_Name__c, AccountId, ContactId, CaseNumber, Status, Subject, Priority, Severity__c, ClosedDate, RecordTypeName__c, 
                Your_Account_Site__c, Your_Contact_Name__c, Sub_Status__c, CreatedDate, RecordTypeId,Client_Reference__c,System_Status__c
                FROM Case WHERE  Status = 'Closed' AND IsVisibleInSelfService = true AND RecordTypeId NOT IN : excludedRTId ORDER BY ClosedDate DESC LIMIT 500] ;
           
            } else if (selectedCaseOption == 'MyClosed' && (RoleName.contains('User')  || RoleName.contains('Executive')) ){
                showCloseDate=true;
                Cases = [SELECT Id,Account_Name__c, AccountId, ContactId, CaseNumber, Status, Subject, Priority, Severity__c, ClosedDate, RecordTypeName__c, 
                Your_Account_Site__c, Your_Contact_Name__c, Sub_Status__c, CreatedDate, RecordTypeId,Client_Reference__c,System_Status__c
                FROM Case WHERE ContactId =: currentId AND Status = 'Closed' AND IsVisibleInSelfService = true AND RecordTypeId NOT IN : excludedRTId ORDER BY ClosedDate DESC LIMIT 500] ;   
            } /*else {
                showCloseDate=false;
                Cases = [SELECT Id,Account_Name__c, AccountId, ContactId, CaseNumber, Status, Subject, Priority, Severity__c, ClosedDate, RecordTypeName__c, 
                Your_Account_Site__c, Your_Contact_Name__c, Sub_Status__c, CreatedDate, RecordTypeId,Client_Reference__c,System_Status__c
                FROM Case WHERE ContactId =: currentId AND Status <> 'Closed' AND RecordTypeId NOT IN : excludedRTId ORDER BY ClosedDate DESC LIMIT 500] ;            
            } */

            if(Cases != null){
                return Cases;
            }
            else{
                return null;
            }
    }
    

        public PageReference Filter() {
            system.debug(selectedCaseOption);
            getCases();
            return Null;
        }
}