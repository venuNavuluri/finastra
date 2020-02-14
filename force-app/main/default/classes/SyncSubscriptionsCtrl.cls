public without sharing class SyncSubscriptionsCtrl 
{
    public class SyncSubscriptionData 
    {
        @AuraEnabled public Id recordId; //Billing Group or Contract record which is used to sync subscriptions
        @AuraEnabled public Boolean showError = false;  // if true then error message is shown
        @AuraEnabled public Boolean showSuccess = false;   //if true then success message is shown
        @AuraEnabled public Boolean showWarning = false;   // if true then warning message is shown
        @AuraEnabled public Boolean showConfirm = false;   //if true then confirmation message is shown     
        @AuraEnabled public String errorMessage = '';  // error message text
        @AuraEnabled public String successMessage = '';  //success message text
		@AuraEnabled public String warningMessage = ''; //warning message text
    }
    
    @AuraEnabled    
    public static SyncSubscriptionData execute(id recordId, string objectType)
    {
        SyncSubscriptionData ret = new SyncSubscriptionData();
        try
        {
            if(objectType == 'BillingGroup') {
                Set<Id> bgIds = new Set<Id>();
                bgIds.add(recordId);
            	
                SyncSubscriptionsHandler.SyncSubsFromBillingGroup(bgIds);    
                
                ret.successMessage = 'Subscriptions were synced successfully';
                ret.showSuccess = true;
                
            }
            else if (objectType == 'Contract') {
                Set<Id> contractIds = new Set<Id>();
                contractIds.add(recordId);
 				
                SyncSubscriptionsHandler.SyncSubsFromContract(contractIds);
                
                ret.successMessage = 'Subscriptions were synced successfully';
                ret.showSuccess = true;
            }
        }catch(Exception e)
        {	
            ret.showError = true;
            ret.errorMessage = e.getMessage();
            system.debug('SyncSubscriptionsCtrl error: '+ret.errorMessage+' '+e.getLineNumber());
            if(Test.isRunningTest()) // if the error was in unit test - let's raise the error
                throw (e);
        }
        return ret;
    }
    
    @AuraEnabled    
    public static SyncSubscriptionData getInfo(id recordId, string objectType)
    {
        SyncSubscriptionData ret = new SyncSubscriptionData();
        try
        {
            if(objectType == 'BillingGroup') {
            	//TODO: Validations
            
                ret.successMessage = 'Are you sure you want to sync all billing group related subscriptions?';
                ret.showConfirm = true;
            }
            else if (objectType == 'Contract') {
                //TODO: Validations
                
                ret.successMessage = 'Are you sure you want to sync all contract related subscriptions?';
                ret.showConfirm = true;
            }
        }catch(Exception e)
        {
            ret.showError = true;
            ret.errorMessage = e.getMessage();
            system.debug('SyncSubscriptionsCtrl error: '+ret.errorMessage+' '+e.getLineNumber());
            if(Test.isRunningTest()) // if the error was in unit test - let's raise the error
                throw (e);
        }
        return ret;
    }
}