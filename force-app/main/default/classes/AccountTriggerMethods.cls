public class AccountTriggerMethods {

    private static Boolean executingFlag = false;

    //Method re-worked, original from banking (not suitable for mass update before changes)
    public static void SetAccountSharing(List<Account> updatedAccounts)
    {
        Set<ID> uniqueRoleIDs = new Set<ID>();
        Set<ID> uniqueAccIDs = new Set<ID>();

        for(Account updatedAccount : [Select id, Owner.Id, Owner.UserRoleId from Account Where Id in :updatedAccounts])
        {
            //system.debug('NNNNNN-------'+updatedAccount.Owner.UserRoleId);
            uniqueRoleIDs.add(updatedAccount.Owner.UserRoleId);
            uniqueAccIDs.add(updatedAccount.Id);
        }

        Map<ID,ID> accountToRole = new Map<ID,ID>();
        Set<ID> uniquePortalRoleIDs = new Set<ID>();
        
        //MIrfan@Appirio. 300413. included PortalRole in SOQL.
        Map<ID,String> mapPortalRole = new Map<ID,String>();
        
        
        system.debug('NNNNNN--1-----'+uniqueAccIDs+'----'+uniqueRoleIDs);
        try
        {
            List<UserRole> lUserRole = [select Id, PortalAccountId, ParentRoleId,PortalRole from UserRole where  PortalAccountId in :uniqueAccIDs and PortalType='CustomerPortal' and ParentRoleId in :uniqueRoleIDs];
            for(UserRole portalUserRole : lUserRole)
            {
                //system.debug('NNNNNN-2------'+portalUserRole);
                accountToRole.put(portalUserRole.PortalAccountId, portalUserRole.Id);
                uniquePortalRoleIDs.add(portalUserRole.Id);
                
                //MIrfan@Appirio. 300413. adding PortalRole to map.
                mapPortalRole.put(portalUserRole.PortalAccountId,portalUserRole.PortalRole);
            }
        }
        catch(Exception e)
        {
            System.debug('NNNNNN-3------'+e.getMessage());
        }

        Map<ID,ID> roleToGroup = new Map<ID,ID>();

        for(Group roleGroup : [select Id, RelatedId from Group where RelatedId in :uniquePortalRoleIDs AND Type = 'Role']){
            roleToGroup.put(roleGroup.RelatedId, roleGroup.Id);
        }

        //Build the list of current account shares to determine which ones to update
        Map<String,Id> mCurrentAcctShareIds = new Map<String,Id>();
        Map<Id,AccountShare> mCurrentAcctShareRecs = new Map<Id,AccountShare>();
        for(AccountShare AcctSh : [select Id, AccountId, UserOrGroupId, AccountAccessLevel, CaseAccessLevel, OpportunityAccessLevel from AccountShare where AccountId in :uniqueAccIDs]){
            mCurrentAcctShareIds.put(AcctSh.AccountId + '' + AcctSh.UserOrGroupId,AcctSh.Id);
            mCurrentAcctShareRecs.put(AcctSh.Id,AcctSh);
        }

        List<AccountShare> updAccountShares = new List<AccountShare>();
        List<AccountShare> newAccountShares = new List<AccountShare>();
        String strUniqueShare = '';

        for(Account updatedAccount : updatedAccounts){
            if(accountToRole.containsKey(updatedAccount.Id)){
                if(roleToGroup.containsKey(accountToRole.get(updatedAccount.Id))){
                    //Define a unique value so duplicate share records are not added to the list to insert 
                    strUniqueShare = updatedAccount.Id + ''+ roleToGroup.get(accountToRole.get(updatedAccount.Id));
                    System.debug('#########################strUniqueShare : ' + strUniqueShare );
                    System.debug('#########################mapPortalRole.get(updatedAccount.Id): ' + mapPortalRole.get(updatedAccount.Id));
                    //If the share already exists, update it.  Otherwise, insert it.
                    if(mCurrentAcctShareIds.keySet().contains(strUniqueShare)){
                        AccountShare accSh = mCurrentAcctShareRecs.get(mCurrentAcctShareIds.get(strUniqueShare));
                        accSh.AccountAccessLevel = 'Edit';
                        accSh.CaseAccessLevel = 'Edit';
                        accSh.OpportunityAccessLevel = 'None';
                        //MIrfan@Appirio. 300413. Contact Read permission for executive.
                        if(mapPortalRole.get(updatedAccount.Id)!=null && 
                            mapPortalRole.get(updatedAccount.Id).equalsIgnoreCase('Executive'))
                            {
                                accSh.ContactAccessLevel = 'Read';
                            }
                        updAccountShares.add(accSh);
                    }else{
                        AccountShare accSh = new AccountShare();
                        accSh.AccountId = updatedAccount.Id;    
                        accSh.AccountAccessLevel = 'Edit';
                        accSh.CaseAccessLevel = 'Edit';
                        accSh.OpportunityAccessLevel = 'None';
                        //MIrfan@Appirio. 300413. Contact Read permission for executive.
                        if(mapPortalRole.get(updatedAccount.Id)!=null && 
                            mapPortalRole.get(updatedAccount.Id).equalsIgnoreCase('Executive'))
                            {
                                accSh.ContactAccessLevel = 'Read';
                            }
                        accSh.UserOrGroupId = roleToGroup.get(accountToRole.get(updatedAccount.Id));
                        newAccountShares.add(accSh);
                    }
                }
            }
        }
        System.debug('updAccountShares : ' + updAccountShares);
        System.debug('newAccountShares : ' + newAccountShares);
        if(updAccountShares.size() > 0)
        {
            update updAccountShares;
        }
        if(newAccountShares.size() > 0)
        {
            insert newAccountShares;
        }
        
    }

    public static void AccountOwnerChangeAddSharing(Map<ID,Account> updatedAccounts, Map<ID,Account> oldAccounts){

        //When new owner for an account, sharing gets wiped, and so we need to add our accounts supported portal users back into the mix

       // List<Account> ownerUpdated = new List<Account>();
        set<id> ownerUpdated = new set<id>();
        //Get the list of accounts that HAS had an owner change
        for(Account updatedAccount : updatedAccounts.values()){
            if(updatedAccount.OwnerId != oldAccounts.get(updatedAccount.Id).OwnerId){
                //ownerUpdated.add(updatedAccount);
                ownerUpdated.add(updatedAccount.Id);
            }
        }
        
       
        system.debug(LoggingLevel.INFO, 'xxxxx 1 Attemping to process new sharing rules for accounts: ownerUpdated = '+ ownerUpdated);

        if(ownerUpdated.size() > 0){

            Set<ID> contactIds = new Set<ID>();
            Map<Id,List<Id>> mapAccCons = new Map<Id,List<Id>>();
            for(contact c:[select id,accountId from contact where accountId in :ownerUpdated])
            {
                contactIds.add(c.id);
                if(mapAccCons.containsKey(c.accountId))
                {
                    mapAccCons.get(c.AccountId).add(c.id);
                }
                else
                {
                    mapAccCons.put(c.AccountId,new List<Id>{c.id});
                }
            }
            system.debug(LoggingLevel.INFO, 'xxxxx 1-1 Added child contacts from accounts: contactIds = '+ contactIds);


            //Get a list of accounts supported that are effected
            List<Accounts_Supported__c> accountsSupported = [select a.Contact__c, a.Supported_Account__c from Accounts_Supported__c a where a.Supported_Account__c in :ownerUpdated];
system.debug(LoggingLevel.INFO, 'xxxx 2 Found accounts supported: '+ accountsSupported);

            for(Accounts_Supported__c accSupp : accountsSupported){
                contactIds.add(accSupp.Contact__c);
            }
            system.debug(LoggingLevel.INFO, 'xxxxx 2-2 Added contacts looked up on supported_account: now contactIds = '+ contactIds);


            Map<ID,ID> contactToUser = new Map<ID,ID>();
            Map<ID,STRING> contactToPortalRole = new Map<ID,STRING>();
            
            //Get the portal users who need to be re-added for account sharing
            for(User portalUser : [select Id,ContactId, User.UserRole.PortalRole from User where IsActive=true and ContactId in :contactIds]){
                contactToUser.put(portalUser.ContactId,portalUser.Id);
                contactToPortalRole.put(portalUser.ContactId,portalUser.UserRole.PortalRole);
            }

            system.debug(LoggingLevel.INFO, 'xxxxx 3-1 Found users with portal roles from those contacts: contactToUser= '+ contactToUser);

            List<AccountShare> insertAccountShares = new List<AccountShare>();

            //Create an AccountShare for each portal user on their associated accounts.
            for(Accounts_Supported__c accSupp : accountsSupported){
                if(contactToUser.containsKey(accSupp.Contact__c)){
                    AccountShare accountShare = new AccountShare();
                    accountShare.AccountId = accSupp.Supported_Account__c;
                    accountShare.AccountAccessLevel = 'Read';
                    
                    // PB(12/14/2009) When Executive Role add edit access on all the cases owned by the account
                    if (contactToPortalRole.get(accSupp.Contact__c) == 'Executive') {
                        accountShare.CaseAccessLevel = 'Edit';
                        //MIrfan@Appirio. 300413. Contact Read permission for executive.
                        accountShare.ContactAccessLevel = 'Read';
                    }
                    else { // Else, use default case sharing model.
                        accountShare.CaseAccessLevel = 'None';  
                    }   
                    accountShare.OpportunityAccessLevel = 'None';
                    accountShare.UserOrGroupId = contactToUser.get(accSupp.Contact__c);
                    insertAccountShares.add(accountShare);
                }
            }
            system.debug('xxxx 4-1: mapAccCons='+mapAccCons);
            //MIrfan@Appirio. 280513. Copy Sharing from Parent to Child Account when updated
            for(Id accId:ownerUpdated)
            {
                //contactIds.add(c.id);
                if(mapAccCons.get(accId)!=null) // Sanity check
                {
	                for(Id conId: mapAccCons.get(accId))
	                {
	                    if(contactToUser.containsKey(conId)){
	                        AccountShare accountShare = new AccountShare();
	                        accountShare.AccountId = accId;
	                        accountShare.AccountAccessLevel = 'Read';
	                        
	                        if (contactToPortalRole.get(conId) == 'Executive') {
	                            accountShare.CaseAccessLevel = 'Edit';
	                            accountShare.ContactAccessLevel = 'Read';
	                        }
	                        else { // Else, use default case sharing model.
	                            accountShare.CaseAccessLevel = 'None';  
	                        }   
	                        accountShare.OpportunityAccessLevel = 'None';
	                        accountShare.UserOrGroupId = contactToUser.get(conId);
	                        insertAccountShares.add(accountShare);
	                    }
	                }
                }

            }
            
            
            if(insertAccountShares.size() > 0){
                insert insertAccountShares;
            }
        }
    }
    public static void AccountOwnerChangeOpptyChild(List<String> lAccIds)
    {
        Map<ID,Opportunity> mOppIds = new Map<ID,Opportunity>([Select OwnerId,Id from Opportunity where AccountId in:lAccIds and isClosed = false]);    
        List<Com_Splits__c> OCom_SplitsListUpdate = new List<Com_Splits__c>();
        List<Com_Splits__c> OCom_SplitsList = [Select Id, Employee_Name__c,Opportunity__c from Com_Splits__c  WHERE Opportunity__c in: mOppIds.keySet() AND RecordType.Name = 'Direct Master Credit'];
        if(OCom_SplitsList.size() > 0)
        {
            for(Com_Splits__c split:OCom_SplitsList)
            {
                if(mOppIds.get(split.Opportunity__c) != null)
                {
                    Opportunity O = mOppIds.get(split.Opportunity__c);
                    if(split.Employee_Name__c != O.OwnerId)
                    {
                        split.Employee_Name__c = O.OwnerId;
                        OCom_SplitsListUpdate.add(split);
                    }
                }
            }
        }
        if(OCom_SplitsListUpdate.size() > 0)
            update OCom_SplitsListUpdate;
    }
    
    public static void UpdateCountryInfo(List<Account> lNewAccounts, Map<Id,Account> oldAccounts)
    {
		//populate the currency conversion rate map
		map<string, decimal> converstionRateMap = new map<string, decimal>();
		for(CurrencyType cType : [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE]){
			converstionRateMap.put(cType.ISOCode, cType.ConversionRate);
		}

    	
        //Loop through the accounts
        for(Account newAcc : lNewAccounts){
            //If the Account is being inserted or the Country value has been changed...
            //system.debug('Old Country='+oldAccounts.get(newAcc.Id).Country__c+', New Country='+newAcc.Country__c);
            if(oldAccounts == null || newAcc.Country__c != oldAccounts.get(newAcc.Id).Country__c || newAcc.Tickle_Me__c == true){
                //Look up the Sales Region for the updated Country in the Country__c custom setting
                Country__c countryData = new Country__c();
                if(newAcc.Country__c == '' || newAcc.Country__c == null){
                    countryData = null;
                }else{
                    countryData = Country__c.getValues(newAcc.Country__c);
                }
                system.debug('Country info from Custom Setting: '+countryData);
                //Set the Sales Region on the account
                if(countryData != null)
                    newAcc.Sales_Region__c = countryData.Sales_Region__c;
                else
                    newAcc.Sales_Region__c = null;
                system.debug('Value of newAcc.Sales_Region__c='+newAcc.Sales_Region__c);
            }
            //update to USD
			decimal conversionRate = 1;
			if(converstionRateMap.containsKey(newAcc.CurrencyISOCode)){
				conversionRate = converstionRateMap.get(newAcc.CurrencyISOCode);
			}
			//CY_Billing_Current_Amount__c to Annual_Renewal_Value_RLF_USD__c
			if(newAcc.CY_Billing_Current_Amount__c != null){
				newAcc.Annual_Renewal_Value_RLF_USD__c = newAcc.CY_Billing_Current_Amount__c / conversionRate;
			}
        }
    }
    
    //This method updates the related Acct By Sub records.
    public static void updateAcctBySub(map<id, Account> newMap, map<id, Account> oldMap){
    	list<Acct_By_Sub__c> absUpdateList = new list<Acct_By_Sub__c>();

    	for(Acct_By_Sub__c accBySub : [select id, Account__c from Acct_By_Sub__c where Account__c in : newMap.keySet()]){
    		if(newMap.get(accBySub.Account__c).CCRT_entry__c != oldMap.get(accBySub.Account__c).CCRT_entry__c || 
    			newMap.get(accBySub.Account__c).NS_Cash_Accounting__c != oldMap.get(accBySub.Account__c).NS_Cash_Accounting__c ||
    			newMap.get(accBySub.Account__c).NS_Credit_Limit__c != oldMap.get(accBySub.Account__c).NS_Credit_Limit__c || 
    			newMap.get(accBySub.Account__c).Fax != oldMap.get(accBySub.Account__c).Fax || 
    			newMap.get(accBySub.Account__c).Phone != oldMap.get(accBySub.Account__c).Phone || 
    			newMap.get(accBySub.Account__c).Website != oldMap.get(accBySub.Account__c).Website || 
    			newMap.get(accBySub.Account__c).NS_Registered_Company__c != oldMap.get(accBySub.Account__c).NS_Registered_Company__c || 
    			newMap.get(accBySub.Account__c).Is_Credit_Checked__c != oldMap.get(accBySub.Account__c).Is_Credit_Checked__c || 
    			newMap.get(accBySub.Account__c).NS_Currency__c != oldMap.get(accBySub.Account__c).NS_Currency__c || 
    			newMap.get(accBySub.Account__c).OwnerId != oldMap.get(accBySub.Account__c).OwnerId ||
    			newMap.get(accBySub.Account__c).NS_Local_Tax_Code__c != oldMap.get(accBySub.Account__c).NS_Local_Tax_Code__c ||
    			newMap.get(accBySub.Account__c).NS_Sun_Id__c != oldMap.get(accBySub.Account__c).NS_Sun_Id__c ||
    			newMap.get(accBySub.Account__c).NS_VAT_Reg_Number__c != oldMap.get(accBySub.Account__c).NS_VAT_Reg_Number__c ||
    			newMap.get(accBySub.Account__c).Credit_Controller__c != oldMap.get(accBySub.Account__c).Credit_Controller__c ||
    			newMap.get(accBySub.Account__c).AP_Access_URL__c != oldMap.get(accBySub.Account__c).AP_Access_URL__c ||
    			newMap.get(accBySub.Account__c).AP_Password__c != oldMap.get(accBySub.Account__c).AP_Password__c ||
    			newMap.get(accBySub.Account__c).Credit_Controller__c != oldMap.get(accBySub.Account__c).Credit_Controller__c ||
    			newMap.get(accBySub.Account__c).WHT_Usually_Applied__c != oldMap.get(accBySub.Account__c).WHT_Usually_Applied__c ||
    			newMap.get(accBySub.Account__c).Country_Risk_Rating__c != oldMap.get(accBySub.Account__c).Country_Risk_Rating__c ||
    			newMap.get(accBySub.Account__c).Customer_Risk_Rating__c != oldMap.get(accBySub.Account__c).Customer_Risk_Rating__c ||
    			newMap.get(accBySub.Account__c).Customer_Specific_Billing_Requirements__c != oldMap.get(accBySub.Account__c).Customer_Specific_Billing_Requirements__c ||
    			newMap.get(accBySub.Account__c).Misys_Customer_Advocate__c != oldMap.get(accBySub.Account__c).Misys_Customer_Advocate__c ||
    			newMap.get(accBySub.Account__c).Customer_AP_Contact__c != oldMap.get(accBySub.Account__c).Customer_AP_Contact__c ||
    			newMap.get(accBySub.Account__c).Customer_Invoice_Approval__c != oldMap.get(accBySub.Account__c).Customer_Invoice_Approval__c ||
    			newMap.get(accBySub.Account__c).GMS_Bic_Code__c != oldMap.get(accBySub.Account__c).GMS_Bic_Code__c ||
    			newMap.get(accBySub.Account__c).GMS_Billing_USCustomerId__c != oldMap.get(accBySub.Account__c).GMS_Billing_USCustomerId__c ||
    			newMap.get(accBySub.Account__c).Customer_Billing_CC_email__c != oldMap.get(accBySub.Account__c).Customer_Billing_CC_email__c ||
    			newMap.get(accBySub.Account__c).NS_Finance_Region__c != oldMap.get(accBySub.Account__c).NS_Finance_Region__c ||
    			newMap.get(accBySub.Account__c).NS_Status__c != oldMap.get(accBySub.Account__c).NS_Status__c ||
    			newMap.get(accBySub.Account__c).NS_Term__c != oldMap.get(accBySub.Account__c).NS_Term__c ||
    			newMap.get(accBySub.Account__c).NS_Invoice_Language__c != oldMap.get(accBySub.Account__c).NS_Invoice_Language__c ||
    			newMap.get(accBySub.Account__c).NS_Category__c != oldMap.get(accBySub.Account__c).NS_Category__c ||
    			newMap.get(accBySub.Account__c).PO_Required__c != oldMap.get(accBySub.Account__c).PO_Required__c ||
    			newMap.get(accBySub.Account__c).Late_Payment_Interest_Rate__c != oldMap.get(accBySub.Account__c).Late_Payment_Interest_Rate__c || 
    			newMap.get(accBySub.Account__c).NS_Customer_Specific_Billing_Other__c != oldMap.get(accBySub.Account__c).NS_Customer_Specific_Billing_Other__c ||
    			newMap.get(accBySub.Account__c).NS_Invoice_Printing_Profile__c != oldMap.get(accBySub.Account__c).NS_Invoice_Printing_Profile__c ||
    			newMap.get(accBySub.Account__c).Parent != oldMap.get(accBySub.Account__c).Parent){
    			accBySub.Synced_To_NS__c = false;
    			accBySub.Synced_To_Extra_NS__c = false;
    			absUpdateList.add(accBySub);
    		}
    	}
    	
    	if(absUpdateList != null && absUpdateList.size() > 0){
    		update absUpdateList;
    	}
    }
    
    //This method deletes the related Heath Indexes from the deleting Accounts.
    public static void deleteHealthIndex(list<Account> accList){
        list<Account_Rollup__c> accRollupList = [select id from Account_Rollup__c where Account__c in :accList];
        system.debug('deleteHealthIndex - accRollupList = ' + accRollupList);
        if(accRollupList != null && !accRollupList.isEmpty()){
            delete accRollupList;
        }
    }
}