/**
 * @File Name          : BillingGroupCreation.cls
 * @Description        : 
 * @Author             : venu.navuluri@finastra.com
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 25/07/2019, 10:37:58
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    06/06/2019, 11:23:26   venu.navuluri@finastra.com     Initial Version
**/
global class BillingGroupCreation {

    webservice static String BillingGroupCreation(Id ConId) {
        String response = '<ul class="slds-has-dividers_bottom-space">';

        boolean isvalidated;

        Contract Con = [SELECT Id, Billing_Group_Entity__c, Billing_Currency__c, CPI__c, CA_Recurring_Fees_Index__c, Uplift_Calc_Type__c, CPI_Uplift_Type__c, Recurring_Fees_Index_Type__c, Uplift_Annual_Effective_Date__c, Uplift_Application_Date__c, RLF_Earliest_review_Date__c, Contract_Status__c, Fixed_Billing_Day__c, NS_Customer_Address__c, NS_Customer_Ship_To_Address__c, CurrencyIsoCode, NS_Customer_Address__r.Synced_To_NS__c, NS_Customer_Ship_To_Address__r.Synced_To_NS__c, Reccuring_Payment_Holiday__c, Misys_Opportunity__c, SBQQ__Opportunity__c, Misys_Entity__r.BE_Active__c, Billing_Group_Entity__r.Synced_To_NS__c, Recurring_Fees_Start_Planned__c, SBQQ__Opportunity__r.StageName, Misys_Opportunity__r.StageName, AccountId, Bill_To__c, Opportunity_Currency_Code__c, StartDate, Memo__c, Contract_Expiry_Date__c, Ship_To__c, Misys_Entity__c, BG_Created__c FROM Contract WHERE id =: ConId];
       
        list < NS_Trading_Currency__c > conCurrency = [select id, NS_Currency__r.Name, Acct_By_Sub__c, NS_Currency__c from NS_Trading_Currency__c where(NS_Currency__r.Name =: con.CurrencyIsoCode OR NS_Currency__r.Name =: con.Billing_Currency__c) and Acct_By_Sub__c =: con.Billing_Group_Entity__c limit 1];

        if (con.BG_Created__c) {
            response = '<li class="slds-item">Billing Group already created for this Contract.\n';
        }

        if (Con.Bill_To__c == null || Con.Ship_To__c == null || Con.Misys_Entity__c == null || Con.Billing_Group_Entity__c == null || con.Contract_Status__c != 'CAT Logging Complete' || Con.SBQQ__Opportunity__c == null || con.Billing_Group_Entity__r.Synced_To_NS__c == false || Con.Billing_Group_Entity__c != null || (con.Billing_Group_Entity__r.Synced_To_NS__c == false && Con.Billing_Group_Entity__c != null) || (con.Misys_Entity__r.BE_Active__c == false && Con.Misys_Entity__c != null) || con.NS_Customer_Address__c == null || con.NS_Customer_Ship_To_Address__c == null || con.Recurring_Fees_Start_Planned__c == null || con.Fixed_Billing_Day__c == null || (con.NS_Customer_Address__r.Synced_To_NS__c == false && con.NS_Customer_Address__c != null) || (con.NS_Customer_Ship_To_Address__r.Synced_To_NS__c == false && con.NS_Customer_Ship_To_Address__c != null) || !con.BG_Created__c || conCurrency.isEmpty()) {
            if (Con.SBQQ__Opportunity__r.StageName != 'Closed Won' || Con.SBQQ__Opportunity__c == null) {
                response += '<li class="slds-item">Billing Group can not be created for this Contract. <b>Opportunity</b> need to be closed won. \n';
            }
            if (conCurrency.isEmpty()) {
                response += '<li class="slds-item">NS Trading currency is empty on Acc by sub.\n';
            }
            if (con.Billing_Group_Entity__r.Synced_To_NS__c == false && Con.Billing_Group_Entity__c != null) {
                response += '<li class="slds-item"><b>Account By Sub</b> is not in Netsuite, please check Acc By Sub details. \n';
            }
            if (con.Recurring_Fees_Index_Type__c != Constants.RF_INDEX_TYPE_NO_INCREASE && (con.CPI__c == null ||  con.Uplift_Calc_Type__c == null || con.CPI_Uplift_Type__c == null || con.Recurring_Fees_Index_Type__c == null ||
                    con.Uplift_Annual_Effective_Date__c == null || con.Uplift_Application_Date__c == null || con.RLF_Earliest_review_Date__c == null)) {
                response += '<li class="slds-item"><b>CPI Uplift</b> - Please provide all necessary CPI uplift information \n';
            }
            if (con.Misys_Entity__r.BE_Active__c == false && Con.Misys_Entity__c != null) {
                response += '<li class="slds-item"><b>Contracting entity</b> is not active, Please check the details. \n';
            }
            if (Con.Bill_To__c == null || Con.Ship_To__c == null || Con.Misys_Entity__c == null || Con.Billing_Group_Entity__c == null) {
                response += '<li class="slds-item">Please fill <b>Account By Sub, BIll To, Ship To</b> and <b>Finastra Entity</b> information.\n';
            }
            if (con.NS_Customer_Address__c == null || con.NS_Customer_Ship_To_Address__c == null) {
                response += '<li  class="slds-item"><b>NS Customer Address</b> or <b>NS Customer Ship To Address</b> is empty. \n';
            }
            if ((con.NS_Customer_Address__r.Synced_To_NS__c == false && con.NS_Customer_Address__c != null) || (con.NS_Customer_Ship_To_Address__r.Synced_To_NS__c == false && con.NS_Customer_Ship_To_Address__c != null)) {
                response += '<li class="slds-item"><b>NS Customer Address</b> or <b>NS Customer Ship To Address</b> is not in NS, please check the details. \n';
            }
            if (con.Recurring_Fees_Start_Planned__c == null) {
                response += '<li class="slds-item"><b>RF Start Planned</b> is mandatory, please enter recurring period start date. \n';
            }
            if (con.Fixed_Billing_Day__c == null) {
                response += '<li class="slds-item"><b>Fixed Billing Day</b> is mandatory, if it is not a monthly billing Fixed Billing Month also Mandatory. \n';

            }
            if (con.Contract_Status__c != 'CAT Logging Complete') {
                response += '<li  class="slds-item">We can create Billing Group and Sales Orders only at <b>CAT Logging Complete stage</b>. \n';
                response += '</ul>';
            }
            //if(!con.BG_Created__c && !response.contains('<li'))  response = SO_ExecuteProcess.createWithContract(con);   
            if (!con.BG_Created__c && !response.contains('<li')) response = SO_CreationProcess.createBGFromContract(con);
        }

        return response;
    }

}