public class InlineCaseAttributesController {
    public Boolean ShowAccountAtRisk{get; set;}
    public Boolean ShowSupporthold{get; set;}
    //public Boolean ShowGlobalAccount{get; set;}
    //public Boolean ShowMajorAccount{get; set;}
    public Boolean ShowStrategicAccount{get; set;}
    public Boolean ShowEndofLife{get; set;}
    public Case MoreCase{get; set;}
    public Boolean ShowActiveCustomer{get;set;}
    public Boolean ShowExCustomer{get;set;}
    public Boolean ShowObsoleteCustomer{get;set;}    
    public Boolean ShowJIRAcase {get; set;}
    public Boolean AuthorisedtoAccessLiveSystems{get;set;}
    public Boolean ShowExtendedSupportInPlace{get;set;}
    public boolean ShowProductonTechnicalSupport{get;set;}

    public InlineCaseAttributesController(ApexPages.StandardController stdController) {

        Case ViewingCase = (Case)stdController.getRecord();
        MoreCase = [Select c.Account.Special_Support__c, 
                           c.AccountId, 
                           c.Account.Account_Watch__c, 
                           c.Account.Debtor_Account__c, 
                           c.Account.Tier__c,
                           c.Account.Type,
                           c.Account.Authorised_to_Access_Live_Systems__c,
                           c.RecordTypeId,
                           c.JIRA_ID__c,
                           c.Product_Set__c,
                           c.Product_Set__r.Extended_Support_in_Place__c,
                           c.Product_Set__r.Type_of_Support__c
                           from Case c where Id= :ViewingCase.Id];

        if(MoreCase != null)
        {
            ShowAccountAtRisk= false;
            ShowSupporthold=false;
            //ShowGlobalAccount=false;
            //ShowMajorAccount=false;
            ShowStrategicAccount=false;
            ShowEndofLife=false;
            ShowActiveCustomer=false;
            ShowExCustomer=false;
            ShowObsoleteCustomer=false;
            ShowJIRAcase = false;
            AuthorisedtoAccessLiveSystems = false; 
            ShowExtendedSupportInPlace = false; 
            ShowProductonTechnicalSupport = false;   
    
            if(MoreCase.Account.Account_Watch__c == True){
                ShowAccountAtRisk = true;
            }
            
            if(MoreCase.Account.Debtor_Account__c == True){
                ShowSupporthold = true;
            }
            
            //if(MoreCase.Account.Tier__c=='Global'){
            //    ShowGlobalAccount = true;
            //}
            
            //if(MoreCase.Account.Tier__c=='Major'){
            //    ShowMajorAccount = true;
            //}
            if(MoreCase.Account.Tier__c=='Strategic'){
                ShowStrategicAccount = true;
            }
            
            if(MoreCase.Account.Special_Support__c == True){
                ShowEndofLife= true;
            }
            
             
        
            
            
            if(MoreCase.Account.Type != null && MoreCase.Account.Type != '')
            {
                if(MoreCase.Account.Type.contains('Obsolete')){
                    ShowObsoleteCustomer = true;
                }else if(MoreCase.Account.Type.Contains('Ex-Customer')){
                    ShowExCustomer = true;
                }else if(MoreCase.Account.Type.Contains('Customer')){
                    ShowActiveCustomer = true;
                }   
            }

         if(MoreCase.Product_Set__r.Extended_Support_in_Place__c != null && MoreCase.Product_Set__r.Extended_Support_in_Place__c != ''){
            string str = MoreCase.Product_Set__r.Extended_Support_in_Place__c;
            if(str.Contains('Yes')){
                    ShowExtendedSupportInPlace = true;
            }
            }
            
         if(MoreCase.Product_Set__r.Type_of_Support__c != null && MoreCase.Product_Set__r.Type_of_Support__c != ''){
            string str = MoreCase.Product_Set__r.Type_of_Support__c;
            if(str.Contains('Technical Support')){
                    ShowProductonTechnicalSupport = true;
            }
            }

            if(MoreCase.Account.Authorised_to_Access_Live_Systems__c == true){
                AuthorisedtoAccessLiveSystems = true;
            }
               

            
            //If the case has been escalated to Engineering and has an ID from JIRA...
            if(MoreCase.RecordTypeId == Constants__c.getValues('ENGINEERING_CASE_RECORD_TYPE').Value__c
                && MoreCase.JIRA_ID__c != '' && MoreCase.JIRA_ID__c != null){
                    ShowJIRAcase = true;
            }

        }
    }

// test class = test_Attributes
}