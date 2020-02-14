/*
 * @author Serhii Volynets sergey.volinets@weare4c.com
 * This is a controller class for Asset_Uplift and Asset_Uplift_Manual lightning components
 * Main methods:
 * start - queries contracts which need Asset Uplift execution
 * execute - executes asset uplift for list of found contract
 */
public without sharing class AssetUpliftCtrl 
{
    public class AssetUpliftData 
    {
        @AuraEnabled public Contract contr; //Contract record which isused to show values
        @AuraEnabled public id orderId; //generated Asset Uplift Sales Order id
        @AuraEnabled public Boolean showError = false;  // if true then error message is shown
        @AuraEnabled public Boolean showSuccess = false;   //if true then success message is shown
        @AuraEnabled public Boolean showWarning = false;   // if true then warning message is shown
        @AuraEnabled public Boolean showConfirm = false;   //if true then confirmation message is shown     
        @AuraEnabled public String errorMessage = '';  // error message text
        @AuraEnabled public String successMessage = '';  //success message text
		@AuraEnabled public String warningMessage = ''; //warning message text
        
    }
    
    /*
     * this method executes Asset Uplift  for specific contract
 	 * @Jira RBX-119
     * @param recordId -  id of the contract
	 * @param bManual - if it is true, then manual mode of Asset Uplift is executed
     * @return (AssetUpliftData) - the object which contains all data for asset uplift responce
     */
    @AuraEnabled    
    public static AssetUpliftData execute(id recordId,boolean bManual)
    {
        AssetUpliftData ret = new AssetUpliftData();
        try
        {
            set<id> sContractId = new set<id>();
            sContractId.add(recordId);
            //execute asset uplift
            Asset_Uplift.AssetUpliftReturn data = Asset_Uplift.execute(sContractId,bManual);
                 
            ret.contr=data.lContr[0];
            //if orders are created
            if(!data.lOrder.isEmpty())
            { //then show success message
                ret.orderId = data.lOrder[0].Id;   
                ret.successMessage = 'The Asset Uplift is completed!';
                ret.showSuccess = true;                
            }
            else
            {
                //if no orders created - show warning message
				ret.showWarning = true;
                ret.warningMessage = 'The Asset Uplift is not completed, since there is no positive Uplift for this contract.';
            }
        }catch(Exception e)
        {	
            //if there was an error in asset uplift - let's show the error
            ret.showError = true;
            ret.errorMessage = e.getMessage();
            system.debug('AssetUpliftCtrl error: '+ret.errorMessage+' '+e.getLineNumber());
            if(Test.isRunningTest()) // if the error was in unit test - let's raise the error
                throw (e);
        }
        return ret;
    }
  
        /*
     * this method is used to provide the information about asset uplift dates to a customer before the asset uplift is executed
 	 * @Jira RBX-119
     * @param recordId -  id of the contract
     * @return (AssetUpliftData) - the object which contains all data for asset uplift responce
     */
    @AuraEnabled    
    public static AssetUpliftData getInfo(id recordId)
    {
        AssetUpliftData ret = new AssetUpliftData();
        try
        {
            //query for contract
            list<contract> lCon = [select id, Next_Asset_Uplift_Date__c, Next_CPI_Uplift_Date__c from contract where id = :recordId];
            if(lCon.isEmpty())
                throw new CommonFunctions.CustomException( 'Can\'t find contract '+recordId);
            else
            {
                //populate the responce
                ret.contr= lCon[0];
                ret.successMessage = '';
                if(ret.contr.Next_Asset_Uplift_Date__c != null)
                    ret.successMessage += 'The next Asset Uplift Date is '+ ret.contr.Next_Asset_Uplift_Date__c.date().format()+'. ';
                if(ret.contr.Next_CPI_Uplift_Date__c != null)
                    ret.successMessage += 'The next CPI Uplift Date is '+ ret.contr.Next_CPI_Uplift_Date__c.format()+'. ';
                ret.successMessage +=' Continue?';
                ret.showConfirm = true;
            }
        }catch(Exception e)
        {
            //if there is an error - show the error
            ret.showError = true;
            ret.errorMessage = e.getMessage();
            system.debug('AssetUpliftCtrl error: '+ret.errorMessage+' '+e.getLineNumber());
            if(Test.isRunningTest()) // if the error was in unit test - let's raise the error
                throw (e);
        }
        return ret;
    }
}