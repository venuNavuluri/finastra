/**
 * @File Name          : SO_BillingGroupHelper.cls
 * @Description        : 
 * @Author             : venu.navuluri@finastra.com
 * @Group              : 
 * @Last Modified By   : venu.navuluri@finastra.com
 * @Last Modified On   : 15/05/2019, 17:22:41
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    15/05/2019, 17:22:41   venu.navuluri@finastra.com     Initial Version
**/
public class SO_BillingGroupHelper {
    
    public static Billing_Group__c BillingGroupCreation(Contract con){
        
        system.debug('Creating Billing Group -- started');
        Billing_Group__c bg = new Billing_Group__c();
        bg.BG_Client_Contracting_Name__c = con.AccountId;
        bg.Account_by_Sub__c = con.Billing_Group_Entity__c;
        bg.Original_Opportunity__c = con.Misys_Opportunity__c;
        bg.CurrencyIsoCode = con.Opportunity_Currency_Code__c;
        bg.Original_Contract__c = con.Id;
        bg.Current_Sales_Order_Start_Date__c = con.StartDate;
        bg.NS_Subscription_Memo__c = con.Memo__c;
        bg.BG_Misys_Billing_Entity__c = con.Misys_Entity__c;
        bg.BG_Client_Bill_To__c = con.Bill_To__c;
        bg.BG_Client_Ship_To__c = con.Ship_To__c;
        bg.BG_Billing_Group_Active__c = true;
        bg.Original_Contract_Expiry_Date__c = con.Contract_Expiry_Date__c;
        
        try {
            insert bg;
            //con.BG_Created__c = true;  
            con.BG_ID__c = bg.id;
            update con;
            
        } catch (Exception Ex) { 
            system.debug('Subscripiton update, Error Reason => ' +Ex.getLineNumber()+' '+eX.getStackTraceString()+' '+ Ex.getMessage());
            throw Ex;
        }
        
        return [SELECT Id, 
                        Name, 
                        Account_by_Sub__c, 
                        Original_Opportunity__c, 
                        Original_Opportunity__r.CurrencyIsoCode, 
                        Account_by_Sub__r.Account__r.NS_Term__c, 
                        Account_by_Sub__r.Account__r.Credit_Controller__c, 
                        CurrencyIsoCode, 
                        Original_Contract__c, 
                        Original_Opportunity__r.CloseDate, 
                        Account_by_Sub__r.Account__r.PO_Required__c, 
                        Account_by_Sub__r.Invoice_Delivery_Post__c, 
                        Account_by_Sub__r.Invoice_Delivery_Email__c, 
                        Original_Opportunity__r.OwnerId, 
                        Original_Contract__r.StartDate, 
                        Original_Contract__r.CustomerSignedDate,
                        Reset_Next_Bill_Date__c, 
                        Original_Contract__r.Memo__c,
                        NS_Billing_Mode__c,
                        NS_Termination_Method__c,
                        Current_Sales_Order_Start_Date__c,
                        Original_Opportunity__r.Customer_PO__c, 
                        Original_Opportunity__r.Owner.FirstName, 
                        Original_Opportunity__r.Owner.LastName,
                        Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c,
                        Set_Tax_Combo_Override__c,
                        Customer_PO_Number__c, 
                        Original_Customer_Signed_Date__c,
                        Created_by_CPQ_process__c, 
                        NS_Customer_Address__c, 
                        Last_Invoice_Date__c, 
                        BG_Next_Invoice_Due_Date__c,
                        NS_Customer_Ship_To_Address__c, 
                        Next_Billing_Date__c,
                        Order_Sub_Type__c, 
                        NS_Specific_Invoice_Wording__c,
                        Fixed_Billing_Date__c, 
                        Original_Contract__r.Contract_Expiry_Date__c, 
                        Original_Contract__r.Recurring_Fees_Start_Planned__c, 
                        Original_Contract__r.ContractTerm
                    FROM
                        Billing_Group__c
                WHERE Id =: bg.Id];
    }
    
    public static void addBGtoSubscriptions(Billing_Group__c bg){
        system.debug('Assigning Billing Group to subs -- started');
        //msgQueue += 'STEP 2 :- Link Subscriptions to newly added Billing Group \n';
        List <SBQQ__Subscription__c> subList = new List <SBQQ__Subscription__c> ();
        try {
            //Add Tax fields from Field Set to Subscriptions query
            Schema.SObjectType SObjectTypeObj = Schema.getGlobalDescribe().get('SBQQ__Subscription__c');
            Schema.FieldSet fieldSetObj = SObjectTypeObj.getDescribe().FieldSets.getMap().get('Query_Field_Set');
            List<Schema.FieldSetMember> queryFieldSet = fieldSetObj.getFields();
            string contractId = bg.Original_Contract__c;
            string subQuery = 'SELECT Id, Billing_Group__c, ';
            for(Schema.FieldSetMember f : queryFieldSet) {
                subQuery += f.getFieldPath() + ', ';
            }
            subQuery += ' Billing_Status__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c = :contractId ';
            List<SBQQ__Subscription__c> subs = database.query(subQuery);
            for (SBQQ__Subscription__c sub: subs) {
                sub.Billing_Group__c = bg.id;
                sub.Billing_Status__c = 'Active billing';
                subList.add(sub);                
            }
            system.debug('##Subscription CopySovosTax start');
            //set correct tax code to subs
            subList = SubscriptionCopyUtil.copyFieldValuesFromSovosTax(subList);   
            if (subList.size() > 0) {
                update subList;
                system.debug('+++ adding bg to subs => '+subList);
                //msgQueue += 'STEP 2 :- Success! Subscriptions updated \n';
            } else {
                //msgQueue += 'STEP 2 :- Warning! No Subscriptions found \n';
            }
        } catch (Exception Ex) { 
            system.debug('Subscripiton update, Error Reason => ' +Ex.getLineNumber()+' '+eX.getStackTraceString()+' '+ Ex.getMessage());
            throw Ex;
        }
    }
    
}