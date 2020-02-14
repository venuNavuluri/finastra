public with sharing class Account_Planning_Summ_Controller {

    public boolean editbutton{get;set;}
    public boolean savebutton{get;set;}
    public Account acct {get; set;}
    public Id recId {get; set;}
    //public Profile profName {get; set;}
    
    public Boolean refreshPage {get; set;}
    /*public String TodayDate {get
                                {
                                    DateTime d = Date.Today() ;
                                    String dateStr =  d.format('dd/MM/yyyy') ;
                                    return dateStr;
                                }
                                 set;}*/
       
    public List<String> lobs = new List<String>{'Core Banking','Digital Channels','Enterprise Risk','Lending','Treasury and Capital Markets BO','Treasury and Capital Markets FO','Asset Management','Hedge Funds','Trade Finance','Payment and Messaging'};
    

    public Account_Planning_Summ_Controller(ApexPages.StandardController controller) {
        refreshPage = False;
        recId = ApexPages.currentPage().getParameters().get('Id');
        acct = [Select Core_Banking_Grade__c, Account_Planning_Status_CB__c, Review_In_CB__c, Comments_CB__c, Commentary_CB__c,
                Digital_Channel_Grade__c, Account_Planning_Status_DC__c, Review_In_DC__c, Comments_DC__c, Commentary_DC__c,
                Enterprise_Risk_Grade__c, Account_Planning_Status_ER__c, Review_In_ER__c, Comments_ER__c, Commentary_ER__c,
                Lending_Grade__c, Account_Planning_Status_Lending__c, Review_In_Lending__c, Comments_Lending__c, Commentary_Lending__c,
                Capital_Markets_Grade__c, Account_Planning_Status_CMBO__c, Review_In_CMBO__c, Comments_CMBO__c, Commentary_CMBO__c,
                Asset_Management_Grade__c, Account_Planning_Status_AM__c, Review_In_AM__c, Comments_AM__c, Commentary_AM__c,
                Hedge_Fund_Grade__c, Account_Planning_Status_HF__c, Review_In_HF__c, Comments_HF__c, Commentary_HF__c,
                Trade_Finance_Grade__c, Account_Planning_Status_TF__c, Review_In_TF__c, Comments_TF__c, Commentary_TF__c,
                Payments_Messaging_Grade__c, Account_Planning_Status_PM__c, Review_In_PM__c, Comments_PM__c, Commentary_PM__c,
                modifiedDetail__c
            from Account where Id =:recId];
        editbutton = True;
        savebutton = False;
    }

    public PageReference cancel() {
        editbutton = True;
        savebutton = False;
        refreshPage = True;
        return null;
    }

    public PageReference edit() {
        editbutton = False;
        savebutton = True;
        //refreshPage = True;
        return null;
    }
    
    public PageReference save() {
        if(((acct.Account_Planning_Status_CB__c=='No Go - Investigated')&&(String.isBlank(acct.Comments_CB__c)))||
    ((acct.Account_Planning_Status_CB__c=='Investigating')&&(acct.Review_In_CB__c==null))||
    ((acct.Account_Planning_Status_DC__c=='No Go - Investigated')&&(String.isBlank(acct.Comments_DC__c)))||
    ((acct.Account_Planning_Status_DC__c=='Investigating')&&(acct.Review_In_DC__c==null))||
    ((acct.Account_Planning_Status_AM__c=='No Go - Investigated')&&(String.isBlank(acct.Comments_AM__c)))||
    ((acct.Account_Planning_Status_AM__c=='Investigating')&&(acct.Review_In_AM__c==null))||
    ((acct.Account_Planning_Status_HF__c=='No Go - Investigated')&&(String.isBlank(acct.Comments_HF__c)))||
    ((acct.Account_Planning_Status_HF__c=='Investigating')&&(acct.Review_In_HF__c==null))||
    ((acct.Account_Planning_Status_TF__c=='No Go - Investigated')&&(String.isBlank(acct.Comments_TF__c)))||
    ((acct.Account_Planning_Status_TF__c=='Investigating')&&(acct.Review_In_TF__c==null))||
    ((acct.Account_Planning_Status_PM__c=='No Go - Investigated')&&(String.isBlank(acct.Comments_PM__c)))||
    ((acct.Account_Planning_Status_PM__c=='Investigating')&&(acct.Review_In_PM__c==null))||
    ((acct.Account_Planning_Status_Lending__c=='No Go - Investigated')&&(String.isBlank(acct.Comments_Lending__c)))||
    ((acct.Account_Planning_Status_Lending__c=='Investigating')&&(acct.Review_In_Lending__c==null))||
    ((acct.Account_Planning_Status_ER__c=='No Go - Investigated')&&(String.isBlank(acct.Comments_ER__c)))||
    ((acct.Account_Planning_Status_ER__c=='Investigating')&&(acct.Review_In_ER__c==null))||
    ((acct.Account_Planning_Status_CMBO__c=='No Go - Investigated')&&(String.isBlank(acct.Comments_CMBO__c)))||
    ((acct.Account_Planning_Status_CMBO__c=='Investigating')&&(acct.Review_In_CMBO__c==null)))
        {
            if((acct.Account_Planning_Status_CB__c=='Investigating')&&(acct.Review_In_CB__c==null))
            {
                ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Review In" Field is mandatory for Core Banking');
                ApexPages.addMessage(msg1);
            }
            if((acct.Account_Planning_Status_DC__c=='Investigating')&&(acct.Review_In_DC__c==null))
            {
                ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Review In" Field is mandatory for Digital Channels');
                ApexPages.addMessage(msg2);
            }
            if((acct.Account_Planning_Status_AM__c=='Investigating')&&(acct.Review_In_AM__c==null))
            {
                ApexPages.Message msg3 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Review In" Field is mandatory for Asset Management');
                ApexPages.addMessage(msg3);
            }
            if((acct.Account_Planning_Status_HF__c=='Investigating')&&(acct.Review_In_HF__c==null))
            {
                ApexPages.Message msg4 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Review In" Field is mandatory for Hedge Funds');
                ApexPages.addMessage(msg4);
            }
            if((acct.Account_Planning_Status_TF__c=='Investigating')&&(acct.Review_In_TF__c==null))
            {
                ApexPages.Message msg5 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Review In" Field is mandatory for Trade Finance');
                ApexPages.addMessage(msg5);
            }
            if((acct.Account_Planning_Status_PM__c=='Investigating')&&(acct.Review_In_PM__c==null))
            {
                ApexPages.Message msg6 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Review In" Field is mandatory for Payment and Messaging');
                ApexPages.addMessage(msg6);
            }
            if((acct.Account_Planning_Status_Lending__c=='Investigating')&&(acct.Review_In_Lending__c==null))
            {
                ApexPages.Message msg7 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Review In" Field is mandatory for Lending');
                ApexPages.addMessage(msg7);
            }
            if((acct.Account_Planning_Status_ER__c=='Investigating')&&(acct.Review_In_ER__c==null))
            {
                ApexPages.Message msg8 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Review In" Field is mandatory for Enterprise Risk');
                ApexPages.addMessage(msg8);
            }
            if((acct.Account_Planning_Status_CMBO__c=='Investigating')&&(acct.Review_In_CMBO__c==null))
            {
                ApexPages.Message msg9 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Review In" Field is mandatory for Treasury and Capital Markets BO');
                ApexPages.addMessage(msg9);
            }
            if((acct.Account_Planning_Status_CB__c=='No Go - Investigated')&&(acct.Comments_CB__c==null))
            {
                ApexPages.Message msg11 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Comments" Field is mandatory for Core Banking');
                ApexPages.addMessage(msg11);
            }
            if((acct.Account_Planning_Status_DC__c=='No Go - Investigated')&&(acct.Comments_DC__c==null))
            {
                ApexPages.Message msg12 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Comments" Field is mandatory for Digital Channels');
                ApexPages.addMessage(msg12);
            }
            if((acct.Account_Planning_Status_AM__c=='No Go - Investigated')&&(acct.Comments_AM__c==null))
            {
                ApexPages.Message msg13 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Comments" Field is mandatory for Asset Management');
                ApexPages.addMessage(msg13);
            }
            if((acct.Account_Planning_Status_HF__c=='No Go - Investigated')&&(acct.Comments_HF__c==null))
            {
                ApexPages.Message msg14 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Comments" Field is mandatory for Hedge Funds');
                ApexPages.addMessage(msg14);
            }
            if((acct.Account_Planning_Status_TF__c=='No Go - Investigated')&&(acct.Comments_TF__c==null))
            {
                ApexPages.Message msg15 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Comments" Field is mandatory for Trade Finance');
                ApexPages.addMessage(msg15);
            }
            if((acct.Account_Planning_Status_PM__c=='No Go - Investigated')&&(acct.Comments_PM__c==null))
            {
                ApexPages.Message msg16 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Comments" Field is mandatory for Payment and Messaging');
                ApexPages.addMessage(msg16);
            }
            if((acct.Account_Planning_Status_Lending__c=='No Go - Investigated')&&(acct.Comments_Lending__c==null))
            {
                ApexPages.Message msg17 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Comments" Field is mandatory for Lending');
                ApexPages.addMessage(msg17);
            }
            if((acct.Account_Planning_Status_ER__c=='No Go - Investigated')&&(acct.Comments_ER__c==null))
            {
                ApexPages.Message msg18 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Comments" Field is mandatory for Enterprise Risk');
                ApexPages.addMessage(msg18);
            }
            if((acct.Account_Planning_Status_CMBO__c=='No Go - Investigated')&&(acct.Comments_CMBO__c==null))
            {
                ApexPages.Message msg19 = new ApexPages.Message(ApexPages.Severity.ERROR, '"Comments" Field is mandatory for Treasury and Capital Markets BO');
                ApexPages.addMessage(msg19);
            }
                            
        }
        else
        {    
            update acct;
            refreshPage = True;
            editbutton = True;
            savebutton = False;
        }
        
        return null;
    }
}