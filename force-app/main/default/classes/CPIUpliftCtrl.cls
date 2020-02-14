public without sharing class CPIUpliftCtrl 
{
    public class CPIUpliftData 
    {
        @AuraEnabled public Contract contr; //Contract record which isused to show values
        @AuraEnabled public Boolean showError = false;  // if true then error message is shown
        @AuraEnabled public Boolean showSuccess = false;   //if true then success message is shown
        @AuraEnabled public Boolean showWarning = false;   // if true then warning message is shown
        @AuraEnabled public Boolean showConfirm = false;   //if true then confirmation message is shown     
        @AuraEnabled public String errorMessage = '';  // error message text
        @AuraEnabled public String successMessage = '';  //success message text
		@AuraEnabled public String warningMessage = ''; //warning message text        
    }
    
    @AuraEnabled    
    public static CPIUpliftData execute(id contractId)
    {
        CPIUpliftData ret = new CPIUpliftData();
        try
        {
            Contract contr = [SELECT Id, Status, Uplift_Application_Date__c FROM Contract WHERE Id = :contractId];
            List<Contract> contractList = new List<Contract>();
            contractList.add(contr);
            UpliftUtils.createUpliftFromContract(contractList);
            ret.contr = contr;
            
            ret.successMessage = 'Uplift Processing Completed';
            ret.showSuccess = true;
			
        }catch(Exception e)
        {	
            ret.showError = true;
            ret.errorMessage = e.getMessage();
            system.debug('CPIUpliftCtrl error: '+ret.errorMessage+' '+e.getLineNumber());
            if(Test.isRunningTest()) // if the error was in unit test - let's raise the error
                throw (e);
        }
        return ret;
    }
    
    @AuraEnabled    
    public static CPIUpliftData getInfo(id recordId)
    {
        CPIUpliftData ret = new CPIUpliftData();
        try
        {
            Contract contr = [SELECT Id, Active__c, Next_Asset_Uplift_Date__c, Uplift_Application_Date__c FROM Contract WHERE Id = :recordId];
            ret.contr = contr;
            if(!contr.Active__c) {
                ret.showWarning = true;
                ret.warningMessage = 'This contract is not active, please check all the details';
            }
            else if(contr.Uplift_Application_Date__c == null) {
                ret.showWarning = true;
                ret.warningMessage = 'Please enter Uplift Application Date';
            }
            else if(contr.Next_Asset_Uplift_Date__c < contr.Uplift_Application_Date__c && contr.Uplift_Application_Date__c.Year() == contr.Next_Asset_Uplift_Date__c.Year() ) {
                ret.showWarning = true;
                ret.warningMessage = 'You cannot apply CPI Uplift because there is an earlier Asset Uplift on this contract.';
            }
            else {
                ret.successMessage = 'Are you sure you want to process this Uplift?';
                ret.showConfirm = true;
            }
        }catch(Exception e)
        {
            ret.showError = true;
            ret.errorMessage = e.getMessage();
            system.debug('CPIUpliftCtrl error: '+ret.errorMessage+' '+e.getLineNumber());
            if(Test.isRunningTest()) // if the error was in unit test - let's raise the error
                throw (e);
        }
        return ret;
    }
}