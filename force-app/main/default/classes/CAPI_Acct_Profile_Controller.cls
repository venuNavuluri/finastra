public with sharing class CAPI_Acct_Profile_Controller {

    public Boolean savebutton{get; set;}
    public Boolean editbutton{get; set;}
    public Acct_Profile__c acctpro {get; set;}
    public pagereference acctProfilePage {get; set;}
    
    public CAPI_Acct_Profile_Controller(ApexPages.StandardController controller) {
      
        savebutton = False;
        editbutton = True;
        acctpro = (Acct_Profile__c)controller.getRecord();
        acctProfilePage = ApexPages.currentPage();
    }

    public pagereference save()
    {
        Update acctpro;
        savebutton = False;
        editbutton = True;
        return null;
    }
    
    public pagereference cancel()
    {
        savebutton = False;
        editbutton = True;
        return acctProfilePage;
    }
    
    public pagereference edit()
    {
        savebutton = True;
        editbutton = False;
        return null;
    }
}