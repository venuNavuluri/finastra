public class CreateRLFCtrl {
	public class CreateRLFData 
    {
        @AuraEnabled public Id billingGroupId; //Billing Group record which isused to show values
        @AuraEnabled public Boolean showError = false;  // if true then error message is shown
        @AuraEnabled public Boolean showSuccess = false;   //if true then success message is shown
        @AuraEnabled public Boolean showWarning = false;   // if true then warning message is shown
        @AuraEnabled public Boolean showConfirm = false;   //if true then confirmation message is shown     
        @AuraEnabled public String errorMessage = '';  // error message text
        @AuraEnabled public String successMessage = '';  //success message text
		@AuraEnabled public String warningMessage = ''; //warning message text        
    }
    
    @AuraEnabled    
    public static CreateRLFData execute(id billingGroupId)
    {
        CreateRLFData ret = new CreateRLFData();
        try
        {
           // string Message = Initial_RLF_Buttons.createRLF(billingGroupId);
           string Message = RLFSO_Manual.manualRLF(billingGroupId);
            ret.billingGroupId = billingGroupId;
            if(Message.startsWith('Recurring SalesOrder Created Successfully')) { //Success Message from RLF_Utils.invoke method
                ret.successMessage = Message;
                ret.showSuccess = true;
            }
            else {
                ret.warningMessage = Message;
                ret.showWarning = true;
            }
			
        }catch(Exception e)
        {	
            ret.showError = true;
            ret.errorMessage = e.getMessage();
            system.debug('CreateRLFCtrl error: '+ret.errorMessage+' '+e.getLineNumber());
            if(Test.isRunningTest()) // if the error was in unit test - let's raise the error
                throw (e);
        }
        return ret;
    }
    
    @AuraEnabled    
    public static CreateRLFData getInfo(id billingGroupId)
    {
        CreateRLFData ret = new CreateRLFData();
        try
        {
            Billing_Group__c bg = [SELECT Id, Hold_Billing__c, Next_Billing_Date__c, Original_Contract_Expiry_Date__c, Next_SO_generation_Date__c,Account_by_Sub__r.Account__r.NS_Finance_Region__c,NS_Customer_Ship_To_Address__c,
                                   NS_Customer_Ship_To_Address__r.Synced_To_NS__c,
                                   NS_Customer_Address__c,
                                   NS_Customer_Address__r.Synced_To_NS__c, 
                                   Account_by_Sub__c,
                                   Account_by_Sub__r.Synced_To_NS__c
                                   FROM Billing_Group__c WHERE Id = :billingGroupId];
            ret.billingGroupId = billingGroupId;
            ret.warningMessage = '';
            if(bg.Hold_Billing__c) {
                ret.showWarning = true;
                ret.warningMessage += '- This Billing Group is on Hold, please check details.<br/>';
            }
             if(bg.Next_SO_generation_Date__c == null) {
                ret.showWarning = true;
                ret.warningMessage += '- You cannot create SO for this bg, please fill Next SO Generation Date.<br/>';
            }
             if(bg.Next_Billing_Date__c > bg.Original_Contract_Expiry_Date__c) {
                ret.showWarning = true;
                ret.warningMessage += '- Next billing date is greater than Contract Expiry Date, please check Next Billing Date and Contract Expiry Date.If nesessary please check RF Start Planned field on related contract record.<br/>';
            }
            if(bg.Account_by_Sub__c == null || !bg.Account_by_Sub__r.Synced_To_NS__c){
                ret.showWarning = true;
                ret.warningMessage += '- Account By Sub is not in Netsuite, please check Acc By Sub details.<br/>';
            }  
            if(bg.NS_Customer_Address__c == null || !bg.NS_Customer_Address__r.Synced_To_NS__c ){
                ret.showWarning = true;
                ret.warningMessage +=  '- NS Customer Address is empty or  not in Netsuite, please check NS Customer Address details.<br/>';
            } if(bg.NS_Customer_Ship_To_Address__c == null || !bg.NS_Customer_Ship_To_Address__r.Synced_To_NS__c ){
               ret.showWarning = true;
                ret.warningMessage +=  '- NS Customer Ship To Address is empty or  not in Netsuite, please check NS Customer Ship To Address details.<br/>';
            } if(bg.Account_by_Sub__r.Account__r.NS_Finance_Region__c == null){
                ret.showWarning = true;
                ret.warningMessage +=  '- Ns Financial region is empty on this billing group';
            } if(ret.warningMessage == '') {
                ret.successMessage += 'Are you sure you want to create recurring sales order manually?';
                ret.showConfirm = true;
            }
          //  ret.warningMessage += '</strong>';
            
        }catch(Exception e)
        {
            ret.showError = true;
            ret.errorMessage = e.getMessage();
            system.debug('CreateRLFCtrl error: '+ret.errorMessage+' '+e.getLineNumber());
            if(Test.isRunningTest()) // if the error was in unit test - let's raise the error
                throw (e);
        }
        return ret;
    }
}