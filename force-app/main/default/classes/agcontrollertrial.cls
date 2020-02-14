public class agcontrollertrial
{
    public boolean searched {get;set;}
    public string NameAcc{get;set;}
    public String currentRecordId{get;set;}
    public String parameterValue {get;set;}
    public Account a1 {get;set;}
    public Task t1 {get;set;}
    public Event e1 {get;set;}
    public Case c1 {get;set;}
    public Opportunity o1 {get;set;}
    public AccountTeamMember tm1 {get;set;}
    public At_Risk__c r1 {get;set;}
    public Acct_Profile__c cap1 {get;set;}
    public roi__Reference_Nomination__c n1{get;set;}
    public List <Account> accounts{get;set;}
    public List <Task> activities{get;set;}
    public List <Event> events{get;set;}
    public List <Case> cases{get;set;}
    public List <Opportunity> opportunities{get;set;}
    public List <AccountTeamMember> atmembers {get;set;}
    public List <At_Risk__c> AtRisks{get;set;}
    public List <Acct_Profile__c> capi{get;set;}
    public List <roi__Reference_Nomination__c> roi{get;set;}
    public Date fromActivityDate{get;set;}
    public Date toActivityDate{get;set;}  
    public Date fromDate {get;set;}
    public Date toDate {get;set;}
    public Date fDate {get;set;}
    public Date tDate {get;set;}  
    public string getDBHtml {get;set;}
    
    public PageReference refresh() {
         return null;
    }
    public agcontrollertrial (ApexPages.StandardController controller)
    {
            a1=new Account();
            t1=new Task();
            c1=new Case();
            o1=new Opportunity();
            r1=new At_Risk__c();
            cap1=new Acct_Profile__c();
            e1=new Event();
            n1=new roi__Reference_Nomination__c ();
    
            tm1=new AccountTeamMember();
            //a.Id= ApexPages.CurrentPage().getparameters().get('id');
            currentRecordId= ApexPages.CurrentPage().getparameters().get('id');
            
            a1 =[select id,Name,Owner.Name,Type,Account_18chr_Id__c,Account_Governance_Profile__c,Sales_Region__c,SAG_Owner1__c,
             Executive_Sponsor__c,GMS_Customer_Support_Owner__c,Misys_Customer_Advocate__c,Misys_Connect_Score__c,Reference_Client__c,
             Annual_Renewal_Value_RLF_USD__c, ILF_Closed_Current_FY__c,ILF_Pipeline__c,Services_Closed_Current_FY__c,Services_Pipeline__c,
             Survey_Wave_1__c,Survey_Wave_2__c,Survey_Wave_3__c,Survey_Score_1__c,Survey_Score_2__c,Survey_Score_3__c 
             from Account where Id =: currentRecordId];
             
    }


    public PageReference search()
    {
    
    //searched=true;
    //String searchSTr='%'+NameAcc+'%';
  
 
        atmembers =[select UserId,TeamMemberRole,AccountId from AccountTeamMember where AccountId =: a1.Id];
        opportunities=[select id,Name,Account.Name,CloseDate,StageName,Type,Owner.Name,Misys_Forecast__c,Total_In_QTR_ILF_Revenue__c,Total_ILF_In_Qtr__c,RecordType.Name from Opportunity where Account.Name LIKE: a1.Name AND CloseDate >= LAST_YEAR AND  RecordType.Name ='Licenses with/without PS'];
        if(t1.Activity_Start_Date__c !=null && t1.Activity_End_Date__c!=NULL)
        {     
             fromDate = t1.Activity_Start_Date__c;
             toDate = t1.Activity_End_Date__c;
        }      
        activities=[select id,owner.name,Sales_Role__c,What.Name,Sales_Activity_Type__c,Activity_Type__c,Purpose__c,Status,ActivityDate,Completed_Date__c,Task_Score_Percentage__c,Task_Score__c from Task where What.Name LIKE : a1.Name AND  Sales_Role__c =: 'Account Governance'AND  ActivityDate >=:fromDate AND ActivityDate <=: toDate];
        if(e1.Activity_Start_Date__c !=null && e1.Activity_End_Date__c!=NULL)
        {     
             fDate = e1.Activity_Start_Date__c;
             tDate = e1.Activity_End_Date__c;
        }      
        
        
        events=[select id,owner.name,Subject,What.Name,Type,Who.Name,Location,StartDateTime,EndDateTime,CurrencyIsoCode,IsAllDayEvent from Event where What.Id = : a1.Id AND Sales_Role__c=: 'Account Governance'AND  StartDateTime >=:fDate AND EndDateTime <=: tDate];
        cases=[select id,owner.name,Contact.Name,Account.Name,Subject,CaseNumber,Status,Case_Age_Days__c from Case where Account.Id = : a1.Id AND  Status !='Closed'];
        capi=[select id,Name,Account__r.Name,Account_Level_Grade__c,Company_Score_Overall__c,Product_Level_Fit_Score_Overall__c,Industry__c from Acct_Profile__c where Account__r.Name LIKE: a1.Name];
        AtRisks=[select id,Account__r.Name,Name,CreatedBy.Name,Products_At_Risk__c,Revenue_at_risk_date__c,Risk_Level__c,Risk_Code__c,Description__c,Review_Classification__c,CurrencyIsoCode from At_Risk__c where Account__r.Name LIKE : a1.Name];
        roi=[select roi__Account__c,Name,CreatedBy.Name,roi__Attention_Required__c,roi__Contact__c,roi__Adjudication_Date__c,roi__Need_More_Information__c,roi__Reject_Reason__c,roi__Adjudication_Status__c,roi__Submitted_By__c,roi__Submitter__c,roi__SubmitterNonSFDC__c from roi__Reference_Nomination__c where roi__Account__c =: a1.Name];
        parameterValue = ApexPages.CurrentPage().getparameters().get('nameParam');
        
        
        return null;
    }

    /*public string getDBHtml (){
         PageReference dbPage = new PageReference('<ahref="https://cs17.salesforce.com/01Z20000000hYj7"');
         target='_blank';{'https://cs17.salesforce.com/01Z20000000hYj7' ;
         Blob pageBlob = dbPage.getContent();
         return pageBlob.toString();
         
    }
    */
    public PageReference Clear()
    {
        accounts = null;
        opportunities = null;
        activities = null;
        cases = null;
        events = null;
        capi = null;
        AtRisks = null;
        roi = null;
        atmembers = null;
        fromDate = null;
        toDate = null;
        fDate = null;
        tDate = null;
    
        return page.Account_Governance;
    }
}