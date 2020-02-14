/*
    Created By: Abhinit Kohar
    Created Date: 21/01/2014
    Description: This class holds the support methods for AccBySubTrigger trigger.
*/
public class AccBySubTriggerMethods {
    
    private static final String RollUp = 'Roll-Up';//'Misys Customer';Roll-up
    
    //This method populates the AcctBySub fields with the corresponding values from the Attached Account and Misys Entity.
    public static void populateAccBySub(map<id, Acct_By_Sub__c> oldMap, map<id, Acct_By_Sub__c> newMap, list<Acct_By_Sub__c> newList){
        map<String, id> accBySubAccountIdMap = new map<String, id>();
        map<id, id> accBySubIdAccountIdMap = new map<id, id>();
        map<String, id> accBySubBEIdMap = new map<String, id>();
        map<id, id> accountIdParentAccountIdMap = new map<id, id>();
        map<id, id> parentAcctIdParentAccBySubIdMap = new map<id, id>();
        map<id, Acct_By_Sub__c> rollUpAcctIdAccBySub = new map<id, Acct_By_Sub__c>();
        
        map<id, id> contactIdAccBySubIdMap = new map<id, id>();
        
        //This list holds the acc by sub ids where the account id has been updated. 
        list<id> accBySubList = new list<id>();
        set<id> rollUpAccountIds = new set<id>();

        integer i = 0;
        for(Acct_By_Sub__c accBySub : newList){
            if(accBySub.Account__c != null){
                if(trigger.isBefore){
                    accBySub.Name = accBySub.Name + i++;
                }
                accBySubAccountIdMap.put(accBySub.Name, accBySub.Account__c);
            }
            if(trigger.isBefore && trigger.isInsert){
                accBySub.Synced_To_NS__c = false;
            }
            if((trigger.isBefore && trigger.isUpdate && accBySub.Account__c != null) || (trigger.isAfter && trigger.isInsert && accBySub.Account__c != null) ){
                accBySubIdAccountIdMap.put(accBySub.Id, accBySub.Account__c);
            } 
            if(accBySub.Misys_Entity__c != null){
                accBySubBEIdMap.put(accBySub.Name, accBySub.Misys_Entity__c);
            }
        }
        system.debug('AccBySubTriggerMethods 1 = ' + accBySubAccountIdMap);
        system.debug('AccBySubTriggerMethods 1-1 = ' + accBySubIdAccountIdMap);
        system.debug('AccBySubTriggerMethods 2 = ' + accBySubBEIdMap);
        
        map<id, Account> accountMap = new map<id, Account>([select id, NS_Cash_Accounting__c, NS_Credit_Limit__c, Fax,  
                        Phone, Website, NS_Registered_Company__c, Is_Credit_Checked__c, CCRT_entry__r.Client_Name_in_normal_use__c, 
                        CCRT_entry__r.Client_Location__c, CCRT_entry__r.Client_Site_Number__c,   
                        CCRT_entry__r.NS_Inactive__c, NS_Finance_Region__r.NS_Finance_Region_Internal_Id__c,
                        NS_Category__r.NS_Category_Internal_Id__c, NS_Status__r.NS_Status_Internal_Id__c, 
                        NS_Term__r.NS_Term_Internal_Id__c, NS_Invoice_Language__r.Schema_Enumeration__c, ParentId, 
                        RecordType.Name, Type, Invoice_Delivery_Email__c, Invoice_Delivery_Post__c, NS_Currency__r.NS_Currency_Internal_Id__c, 
                        NS_Invoice_Translation__c, NS_Invoice_Translation_Language__c, NS_Export_to_Openair__c, NS_Local_Tax_Code__c, 
                        NS_Sun_Id__c, NS_VAT_Reg_Number__c, Invoice_Delivery_Customer_AP_Upload__c, Invoice_Delivery_Courier__c,
                        Credit_Controller__r.NS_Employee_Internal_Id__c, AP_Access_URL__c, AP_User_Name__c, AP_Password__c, Country_Risk_Rating__c, 
                        WHT_Usually_Applied__c, Customer_Specific_Billing_Requirements__c, Misys_Customer_Advocate__r.NS_Employee_Internal_Id__c, 
                        Customer_Invoice_Approval__c, Customer_AP_Contact__c, GMS_Bic_Code__c, GMS_Billing_USCustomerId__c,
                        Customer_Invoice_Approval__r.NS_Internal_Id__c, Customer_AP_Contact__r.NS_Internal_Id__c,
                        Customer_Invoice_Approval__r.NS_Primary_Account__c, Customer_AP_Contact__r.NS_Primary_Account__c,
                        Customer_Billing_CC_email__c, Customer_Risk_Rating__c, Customer_Group__c, Ultimate_Parent__c, PO_Required__c, 
                        Late_Payment_Interest_Rate__c, NS_Customer_Specific_Billing_Other__c, Owner.NS_Employee_Internal_Id__c, 
                        NS_Invoice_Printing_Profile__r.NS_Invoice_Printing_Profile_Internal_Id__c
                        from account where id in :accBySubAccountIdMap.values()]);
        
        system.debug('AccBySubTriggerMethods 3 = ' + accountMap);
        
        map<id, Billing_Entity__c> beMap = new map<id, Billing_Entity__c>([select id, NS_Subsidiary_InternalId__c, Name 
                        from Billing_Entity__c where id in :accBySubBEIdMap.values()]);
        
        system.debug('AccBySubTriggerMethods 4 = ' + beMap);

        //create the mapping between AccountId and Parent AccountId to populate the Parent
        for(Account account : accountMap.values()){
            /*
            if(account.ParentId != null){
                accountIdParentAccountIdMap.put(account.Id, account.ParentId);
            }
            */
            if(account.RecordType.Name == RollUp && account.Type == 'Roll-Up Group' && account.Ultimate_Parent__c != null){
                accountIdParentAccountIdMap.put(account.Id, account.Ultimate_Parent__c);
            } else if(account.RecordType.Name != RollUp && account.Customer_Group__c != null){
                accountIdParentAccountIdMap.put(account.Id, account.Customer_Group__c);
            }
            //Account with the record Type of Roll-up are the parent account records, which can only have one corresponding Acct By Sub.
            //get the roll up account ids.
            if(account.RecordType.Name == RollUp){
                rollUpAccountIds.add(account.Id);
            }
            
        }
        
        //get the Acct By Subs related to the roll up accounts and populate the map
        if(rollUpAccountIds != null && rollUpAccountIds.size() > 0){
            for(Acct_By_Sub__c accBySub : [select id, Name, Account__c from Acct_By_Sub__c where Account__c in : rollUpAccountIds]){
                rollUpAcctIdAccBySub.put(accBySub.Account__c, accBySub);
            }
        }
        
        if(accountIdParentAccountIdMap != null && accountIdParentAccountIdMap.size() > 0){
            //populate the parentAcctIdParentAccBySubIdMap
            for(Acct_By_Sub__c accBySub : [select id, Account__c from Acct_By_Sub__c where Account__c in : accountIdParentAccountIdMap.values()]){
                parentAcctIdParentAccBySubIdMap.put(accBySub.Account__c, accBySub.Id); //One roll up account can only have one acct by sub 
            }
        }
        system.debug('accountIdParentAccountIdMap = ' + accountIdParentAccountIdMap);
        system.debug('parentAcctIdParentAccBySubIdMap = ' + parentAcctIdParentAccBySubIdMap);
        //populate Country Risk Rating and customer risk rating map for getting the internal ids
        map<string, string> listTableMap = new map<string, string>();
        for(NS_List_Table__c listTable : [select id, name, NS_Internal_Id__c, NS_List_Name__c from NS_List_Table__c where NS_List_Name__c = 'CustomerRiskRating' or NS_List_Name__c = 'CountryRiskRating']){
            if(listTable.NS_List_Name__c == 'CustomerRiskRating'){
                listTableMap.put(listTable.name + 'CustomerRiskRating', listTable.NS_Internal_Id__c);
            } else if(listTable.NS_List_Name__c == 'CountryRiskRating'){
                listTableMap.put(listTable.name + 'CountryRiskRating', listTable.NS_Internal_Id__c);
            }
        }
        
        //populate language map for getting the language code
        map<string, string> langMap = new map<string, string>();
        for(NS_Language__c language : [select id, name, Schema_Enumeration__c, NS_Language_Internal_Id__c from NS_Language__c where Active__c = 'Yes']){
            langMap.put(language.Name, language.NS_Language_Internal_Id__c);
        }
        
        system.debug('rollUpAcctIdAccBySub = ' + rollUpAcctIdAccBySub);
        for(Acct_By_Sub__c accBySub : newList){
            if(trigger.isInsert && trigger.isBefore && rollUpAcctIdAccBySub.containsKey(accBySub.Account__c)){
                accBySub.addError('Roll up account can only have one corresponding Acct By Sub. Following Acct By Sub already exist for this Account: ' + rollUpAcctIdAccBySub.get(accBySub.Account__c).Name);
            }
            Account account = accountMap.get(accBySubAccountIdMap.get(accBySub.Name));
            Billing_Entity__c billingEntity = beMap.get(accBySubBEIdMap.get(accBySub.Name));
            Id parentAccBySubId;
            if(trigger.isBefore){
                if(accountIdParentAccountIdMap != null && accountIdParentAccountIdMap.size() > 0 && accountIdParentAccountIdMap.containsKey(account.Id)){
                    if(parentAcctIdParentAccBySubIdMap != null && parentAcctIdParentAccBySubIdMap.containsKey(accountIdParentAccountIdMap.get(account.Id))){
                        parentAccBySubId = parentAcctIdParentAccBySubIdMap.get(accountIdParentAccountIdMap.get(account.Id));
                    }
                }
            }
            if(trigger.isInsert && trigger.isAfter){
                system.debug('Account = ' + account);
                if(account.Customer_AP_Contact__c != null && account.Customer_AP_Contact__r.NS_Primary_Account__c == null){
                    contactIdAccBySubIdMap.put(account.Customer_AP_Contact__c, accBySub.Id);
                }
                if(account.Customer_Invoice_Approval__c != null && account.Customer_Invoice_Approval__r.NS_Primary_Account__c == null){
                    contactIdAccBySubIdMap.put(account.Customer_Invoice_Approval__c, accBySub.Id);
                }
            }
            if(trigger.isInsert && trigger.isBefore){
                setAccBySubFields(accBySub, account, billingEntity, parentAccBySubId, listTableMap, langMap);
            } else if(trigger.isUpdate){
                if(oldMap.get(accBySub.Id).Account__c != newMap.get(accBySub.Id).Account__c || 
                    oldMap.get(accBySub.Id).Misys_Entity__c != newMap.get(accBySub.Id).Misys_Entity__c ||
                    oldMap.get(accBySub.Id).Invoice_Delivery_Post__c != newMap.get(accBySub.Id).Invoice_Delivery_Post__c ||
                    oldMap.get(accBySub.Id).Invoice_Delivery_Email__c != newMap.get(accBySub.Id).Invoice_Delivery_Email__c ||
                    oldMap.get(accBySub.Id).Invoice_Delivery_Courier__c != newMap.get(accBySub.Id).Invoice_Delivery_Courier__c ||
                    oldMap.get(accBySub.Id).Invoice_Delivery_Customer_AP_Upload__c != newMap.get(accBySub.Id).Invoice_Delivery_Customer_AP_Upload__c ||
                    oldMap.get(accBySub.Id).NS_Invoice_Translation__c != newMap.get(accBySub.Id).NS_Invoice_Translation__c ||
                    oldMap.get(accBySub.Id).NS_Export_to_Openair__c != newMap.get(accBySub.Id).NS_Export_to_Openair__c ||
                    oldMap.get(accBySub.Id).NS_Invoice_Translation_Language__c != newMap.get(accBySub.Id).NS_Invoice_Translation_Language__c ||
                    oldMap.get(accBySub.Id).NS_Inactive__c != newMap.get(accBySub.Id).NS_Inactive__c ||
                    oldMap.get(accBySub.Id).Override_Template__c != newMap.get(accBySub.Id).Override_Template__c){
                        
                        accBySub.Synced_To_NS__c = false;
                        accBySub.Synced_To_Extra_NS__c = false;
                    
                }
                if(oldMap.get(accBySub.Id).Account__c != newMap.get(accBySub.Id).Account__c){
                    accBySubList.add(accBySub.Id);
                }
                setAccBySubFields(accBySub, account, billingEntity, parentAccBySubId, listTableMap, langMap);
                //populate the contactIdAccBySubIdMap to update the contacts with the Acc By Sub
                if(account.Customer_AP_Contact__c != null && account.Customer_AP_Contact__r.NS_Primary_Account__c == null){
                    contactIdAccBySubIdMap.put(account.Customer_AP_Contact__c, accBySub.Id);
                }
                if(account.Customer_Invoice_Approval__c != null && account.Customer_Invoice_Approval__r.NS_Primary_Account__c == null){
                    contactIdAccBySubIdMap.put(account.Customer_Invoice_Approval__c, accBySub.Id);
                }
            }
            
        }
        system.debug('contactIdAccBySubIdMap = ' + contactIdAccBySubIdMap);
        if(trigger.isInsert && trigger.isAfter){
            //create the customer addresses taking them from the associated Bill To/Installations.
            system.debug('AccBySubTriggerMethods 5 = ' + accBySubAccountIdMap);
            createCustomerAddress(accBySubIdAccountIdMap, contactIdAccBySubIdMap);
        } else if(trigger.isUpdate && accBySubList != null && accBySubList.size() > 0){
            system.debug('AccBySubTriggerMethods 5-1 = ' + accBySubIdAccountIdMap);
            //delete the existing Customer Addresses if the Account id is updated.
            //also, delete the NS Customer Contacts
            deleteCustomerAddress(accBySubList);
            //create the new customer addresses for the associated account.
            createCustomerAddress(accBySubIdAccountIdMap, contactIdAccBySubIdMap);
        } else if(contactIdAccBySubIdMap != null && contactIdAccBySubIdMap.size() > 0){
            //update the contacts with the Acct By Sub
            list<Contact> updateContactList = new list<Contact>();
            for(Id contactId : contactIdAccBySubIdMap.keySet()){
                updateContactList.add(new Contact(Id = contactId, NS_Primary_Account__c = contactIdAccBySubIdMap.get(contactId)));
            }
            if(updateContactList != null && updateContactList.size() > 0){
                update updateContactList;
            }
        }
    }
    
    //This method sets the values in the AcctBySub fields based on the Account and Billing entity passed.
    private static void setAccBySubFields(Acct_By_Sub__c accBySub, Account account, Billing_Entity__c billingEntity, Id parentAccBySubId, map<string, string> listTableMap, map<string, string> langMap){
        if(account != null){
            //Set the account fields
            //setAccountFields(accBySub, account);
            accBySub.NS_Cash_Accounting__c = account.NS_Cash_Accounting__c;
            accBySub.NS_Credit_Limit__c = account.NS_Credit_Limit__c;
            accBySub.NS_Fax__c = account.Fax;
            accBySub.NS_Phone__c = account.Phone;
            if(account.Website != null){
                String webAddress = account.Website;
                if(!webAddress.startsWith('http://') && !webAddress.startsWith('https://')){
                    webAddress = 'http://' + webAddress;
                    if(webAddress.length() > 100){
                        webAddress = webAddress.substring(0, 99);
                    }
                    accBySub.NS_Web_Address__c = webAddress;
                } else {
                    if(webAddress.length() > 100){
                        webAddress = webAddress.substring(0, 99);
                    }
                    accBySub.NS_Web_Address__c = webAddress;
                }
            }
            accBySub.NS_Registered_Company__c = account.NS_Registered_Company__c;
            accBySub.Is_Credit_Checked__c = account.Is_Credit_Checked__c;
            String companyName = null;
            String clientName = null;
            String subCode = null;
            String clientLocation = null;
            if(account.CCRT_entry__r.Client_Name_in_normal_use__c != null){
                clientName = account.CCRT_entry__r.Client_Name_in_normal_use__c;
                if(clientName.length() > 35){
                    clientName = clientName.substring(0, 35);
                }
            }
            if(account.CCRT_entry__r.Client_Location__c != null){
                clientLocation = account.CCRT_entry__r.Client_Location__c;
                if(clientLocation.length() > 35){
                    clientLocation = clientLocation.substring(0, 35);
                }
            }
            if(billingEntity != null){
                subCode = billingEntity.Name;
            }
            accBySub.NS_Company_Name__c = clientName + '-' + subCode + '/' + clientLocation;
            accBySub.Name = clientName + '-' + subCode + '/' + clientLocation;
            accBySub.NS_CSN__c = account.CCRT_entry__r.Client_Site_Number__c;
            accBySub.NS_Customer_Id__c = account.CCRT_entry__r.Client_Site_Number__c;
          /*  If(accBySub.Account_Transferred__c == false)
            {
            
            }
            */
            
            accBySub.NS_Legal_Name__c = account.CCRT_entry__r.Client_Name_in_normal_use__c;
            accBySub.NS_Local_Tax_Code__c = account.NS_Local_Tax_Code__c;
            accBySub.NS_Sun_Id__c = account.NS_Sun_Id__c;
            accBySub.NS_VAT_Reg_Number__c = account.NS_VAT_Reg_Number__c;
            accBySub.NS_Finance_Region_Internal_Id__c = account.NS_Finance_Region__r.NS_Finance_Region_Internal_Id__c;
            accBySub.NS_Category_Internal_Id__c = account.NS_Category__r.NS_Category_Internal_Id__c;
            accBySub.NS_Status_Internal_Id__c = account.NS_Status__r.NS_Status_Internal_Id__c;
            accBySub.NS_Terms_Internal_Id__c = account.NS_Term__r.NS_Term_Internal_Id__c;
            accBySub.NS_Invoice_Language__c = account.NS_Invoice_Language__r.Schema_Enumeration__c;
            accBySub.NS_Credit_Controller_Internal_Id__c = account.Credit_Controller__r.NS_Employee_Internal_Id__c;
            accBySub.Parent__c = parentAccBySubId;
            if(accBySub.NS_Internal_Id__c == null || accBySub.NS_Internal_Id__c == ''){
                accBySub.NS_Primary_Currency_Internal_Id__c = account.NS_Currency__r.NS_Currency_Internal_Id__c;
            }
            if(trigger.isInsert){
                accBySub.NS_Export_to_Openair__c = account.NS_Export_to_Openair__c;
                accBySub.Invoice_Delivery_Post__c = account.Invoice_Delivery_Post__c;
                accBySub.Invoice_Delivery_Email__c = account.Invoice_Delivery_Email__c;
                accBySub.Invoice_Delivery_Courier__c = account.Invoice_Delivery_Courier__c;
                accBySub.Invoice_Delivery_Customer_AP_Upload__c = account.Invoice_Delivery_Customer_AP_Upload__c;
                accBySub.NS_Invoice_Translation__c = account.NS_Invoice_Translation__c;
                accBySub.NS_Invoice_Translation_Language__c = account.NS_Invoice_Translation_Language__c;
                accBySub.NS_Inactive__c = account.CCRT_entry__r.NS_Inactive__c;
            }
            
            //Need to work on that based on the Internal Ids we get from NS.
            string transLang = accBySub.NS_Invoice_Translation_Language__c;
            if(transLang != null && (transLang == 'Spanish – Mexico' || transLang == 'Spanish - Colombia')){
                transLang = 'Spanish (Latin America)';
            }
            if(transLang != null && langMap.containsKey(transLang)){
                accBySub.NS_Invoice_Translation_Language_Code__c = langMap.get(transLang);
            } else if(transLang == null){
                accBySub.NS_Invoice_Translation_Language_Code__c = null;
            }
            
            //accBySub.AP_Access_URL__c = account.AP_Access_URL__c;
            if(account.AP_Access_URL__c != null){
                String apAccessURL = account.AP_Access_URL__c;
                if(!apAccessURL.startsWith('http://') && !apAccessURL.startsWith('https://')){
                    apAccessURL = 'http://' + apAccessURL;
                    if(apAccessURL.length() > 100){
                        apAccessURL = apAccessURL.substring(0, 99);
                    }
                    accBySub.AP_Access_URL__c = apAccessURL;
                } else {
                    if(apAccessURL.length() > 100){
                        apAccessURL = apAccessURL.substring(0, 99);
                    }
                    accBySub.AP_Access_URL__c = apAccessURL;
                }
            }

            accBySub.AP_User_Name__c = account.AP_User_Name__c;
            accBySub.AP_Password__c = account.AP_Password__c;
            accBySub.WHT_Usually_Applied__c = account.WHT_Usually_Applied__c;
            accBySub.Country_Risk_Rating__c = account.Country_Risk_Rating__c;
            if(accBySub.Country_Risk_Rating__c != null && listTableMap.containsKey(accBySub.Country_Risk_Rating__c + 'CountryRiskRating')){
                accBySub.Country_Risk_Rating_Internal_Id__c = listTableMap.get(accBySub.Country_Risk_Rating__c + 'CountryRiskRating');
            } else {
                accBySub.Country_Risk_Rating_Internal_Id__c = null;
            }
            accBySub.Customer_Risk_Rating__c = account.Customer_Risk_Rating__c;
            if(accBySub.Customer_Risk_Rating__c != null && listTableMap.containsKey(accBySub.Customer_Risk_Rating__c + 'CustomerRiskRating')){
                accBySub.Customer_Risk_Rating_Internal_Id__c = listTableMap.get(accBySub.Customer_Risk_Rating__c + 'CustomerRiskRating');
            } else {
                accBySub.Customer_Risk_Rating_Internal_Id__c = null;
            }
            accBySub.Customer_Specific_Billing_Requirements__c = account.Customer_Specific_Billing_Requirements__c;
            accBySub.Misys_Customer_Advocate_Internal_Id__c = account.Misys_Customer_Advocate__r.NS_Employee_Internal_Id__c;
            accBySub.Customer_AP_Contact__c = account.Customer_AP_Contact__c;
            accBySub.Customer_Invoice_Approval__c = account.Customer_Invoice_Approval__c;
            if(accBySub.Customer_AP_Contact__c != null){
                accBySub.NS_Customer_AP_Contact_Internal_Id__c = account.Customer_AP_Contact__r.NS_Internal_Id__c;
            } else {
                accBySub.NS_Customer_AP_Contact_Internal_Id__c = null;
            }
            if(accBySub.Customer_Invoice_Approval__c != null){
                accBySub.NS_Customer_Invoice_Approval_Internal_Id__c = account.Customer_Invoice_Approval__r.NS_Internal_Id__c;
            } else {
                accBySub.NS_Customer_Invoice_Approval_Internal_Id__c = null;
            }
            accBySub.GMS_Billing_USCustomerId__c = account.GMS_Billing_USCustomerId__c;
            accBySub.GMS_Bic_Code__c = account.GMS_Bic_Code__c;
            accBySub.Customer_Billing_CC_email__c = account.Customer_Billing_CC_email__c;
            accBySub.Late_Payment_Interest_Rate__c = account.Late_Payment_Interest_Rate__c;
            accBySub.PO_Required__c = account.PO_Required__c;
            accBySub.NS_Customer_Specific_Billing_Other__c = account.NS_Customer_Specific_Billing_Other__c;
            
            //code Request ID :##1486132##
            if(accBySub.Override_Template__c!=true)
            accBySub.NS_Invoice_Printing_Profile_Internal_Id__c = account.NS_Invoice_Printing_Profile__r.NS_Invoice_Printing_Profile_Internal_Id__c;
            
            accBySub.NS_SalesRep_InternalId__c = account.Owner.NS_Employee_Internal_Id__c;
        }
        
        if(billingEntity != null && account != null){
            //Set the billing entity fields
            accBySub.NS_Subsidiary_InternalId__c = billingEntity.NS_Subsidiary_InternalId__c;
            accBySub.NS_Customer_Id__c = account.CCRT_entry__r.Client_Site_Number__c + '-' + billingEntity.Name;
        }
    }
    
    //This method creates the Customer Address based on the associated Bill To/Installation records on the Account.
    //This method also creates the NS Customer Contacts and updates the Contacts.
    private static void createCustomerAddress(map<id, id> accBySubAccountIdMap, map<id, Id> contactIdAccBySubIdMap){
        system.debug('AccBySubTriggerMethods 6 = ' + accBySubAccountIdMap);
        map<id, list<Bill_To_Ship_To__c>> accIdBillToShipToMap = new map<id, list<Bill_To_Ship_To__c>>();
        list<Bill_To_Ship_To__c> billToShipToList;// = new list<Bill_To_Ship_To__c>();
        list<NS_Customer_Address__c> customerAddList = new list<NS_Customer_Address__c>();
        set<Id> contactIds = new set<Id>();
        list<NS_Customer_Contact__c> nsCusConList = new list<NS_Customer_Contact__c>();
        
        for(Bill_To_Ship_To__c btst : [select id, Bill_To_Street_1__c, Bill_To_Street_2__c, Bill_To_Street_3__c, Bill_To_Name__c, Bill_To_Attention__c, 
                                        Bill_To_City__c, NS_Country__c, NS_Country__r.Schema_Enumeration__c, Default_Billing__c, 
                                        Default_Shipping__c, Bill_To_Zip_Postal_Code__c, Bill_To_State_Province__c, Account__c, 
                                        Bill_to_Contact__c, Bill_to_Contact__r.NS_Internal_Id__c, Bill_to_Contact__r.NS_Primary_Account__c 
                                        from Bill_To_Ship_To__c where Account__c in : accBySubAccountIdMap.values()]){
            
            if(accIdBillToShipToMap.containsKey(btst.Account__c)) {
                billToShipToList = accIdBillToShipToMap.get(btst.Account__c);
                billToShipToList.add(btst);
            } else {
                billToShipToList = new list<Bill_To_Ship_To__c>();
                billToShipToList.add(btst);
                accIdBillToShipToMap.put(btst.Account__c, billToShipToList);
            }
        }
        system.debug('AccBySubTriggerMethods 7 = ' + accIdBillToShipToMap);
        
        for(Id accBySubId : accBySubAccountIdMap.keySet()){
            system.debug('AccBySubTriggerMethods 8 = ' + accBySubId);
            if(accIdBillToShipToMap != null && accIdBillToShipToMap.containsKey(accBySubAccountIdMap.get(accBySubId))){
                for(Bill_To_Ship_To__c btst : accIdBillToShipToMap.get(accBySubAccountIdMap.get(accBySubId))){
                    system.debug('AccBySubTriggerMethods 9 = ' + btst);
                    NS_Customer_Address__c customerAdd = new NS_Customer_Address__c();
                    customerAdd.Acct_By_Sub__c = accBySubId;
                    customerAdd.Bill_To_Ship_To__c = btst.Id;
                    customerAdd.Address_1__c = btst.Bill_To_Street_1__c;
                    customerAdd.Address_2__c = btst.Bill_To_Street_2__c;
                    customerAdd.Address_3__c = btst.Bill_To_Street_3__c;
                    customerAdd.Addressee__c = btst.Bill_To_Name__c;
                    customerAdd.Attention__c = btst.Bill_To_Attention__c;
                    customerAdd.City__c = btst.Bill_To_City__c;
                    customerAdd.NS_Country__c = btst.NS_Country__c;
                    customerAdd.Default_Bill_To__c = btst.Default_Billing__c;
                    customerAdd.Default_Ship_To__c = btst.Default_Shipping__c;
                    customerAdd.Postal_Zip_Code__c = btst.Bill_To_Zip_Postal_Code__c;
                    customerAdd.County_State_Province__c = btst.Bill_To_State_Province__c;
                    customerAdd.Billing_Contact__c = btst.Bill_to_Contact__c;
                    customerAddList.add(customerAdd);

                    if(btst.Bill_to_Contact__c != null){
                        if(!contactIds.contains(btst.Bill_to_Contact__c)){
                            contactIds.add(btst.Bill_to_Contact__c);
                            NS_Customer_Contact__c customerContact = new NS_Customer_Contact__c();
                            customerContact.Contact__c = btst.Bill_to_Contact__c;
                            customerContact.Acct_By_Sub__c = accBySubId;
                            customerContact.Synced_To_NS__c = false;
                            nsCusConList.add(customerContact);
                        }
                        if(btst.Bill_to_Contact__r.NS_Primary_Account__c == null){
                            contactIdAccBySubIdMap.put(btst.Bill_to_Contact__c, accBySubId);
                        }
                    }
                }
            }
        }
        
        if(customerAddList != null && customerAddList.size() > 0){
            system.debug('AccBySubTriggerMethods 10 = ' + customerAddList);
            insert customerAddList;
        }
        //update the contacts with the Acct By Sub
        list<Contact> contactList = new list<Contact>();
        if(contactIdAccBySubIdMap != null && contactIdAccBySubIdMap.size() > 0){
            for(Id contactId : contactIdAccBySubIdMap.keySet()){
                contactList.add(new Contact(Id = contactId, NS_Primary_Account__c = contactIdAccBySubIdMap.get(contactId)));
            }
            if(contactList != null && contactList.size() > 0){
                update contactList;
            }
        }
        //create the NS Customer Cotacts
        if(nsCusConList != null && nsCusConList.size() > 0){
            insert nsCusConList;
        }
    }
    
    //This method deletes the existing Customer Addresses associated with the AcctBySub.
    private static void deleteCustomerAddress(list<id> accBySubList){
        list<NS_Customer_Address__c> customerAddList = [select id from NS_Customer_Address__c where Acct_By_Sub__c in : accBySubList];
        if(customerAddList != null && customerAddList.size() > 0){
            delete customerAddList;
        }

        list<NS_Customer_Contact__c> customerConList = [select id from NS_Customer_Contact__c where Acct_By_Sub__c in : accBySubList];
        if(customerConList != null && customerConList.size() > 0){
            delete customerConList;
        }
    }
}