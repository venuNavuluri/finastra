public class ProductOrderUtils
{
    Integer currentYear = System.Today().year()+1;
    String oppName = String.valueOf(currentYear +' '+ 'Annual Increase');


    Map<String,List<Billing_Group__c>> mp_DuplicateBG_AccountbySub = new Map<String,List<Billing_Group__c>>();
    List<Purchase_Order__c> purchaseOrders = new List<Purchase_Order__c>();
    Set<Id> billingGroupSetId = new Set<Id>();
    Map<String,List<Contract_Asset__c>> mp_ListContractAsset = new Map<String,List<Contract_Asset__c>>();
    List<Contract_Asset__c> contractAssetToPOList = new List<Contract_Asset__c>();
    List<Purchase_Order__c> purchaseOrdersToUpdate;
    Map<Id,opportunity> mapAccountOpportunity = new Map<Id,Opportunity>();


    // NG all methods except that one should be private, as we're not calling them from outside
    //Shruthi - Done
    public void createPurchaseOrders(Set<Id> accountIdSet)
    {
        // NG from performance point of view let's put an account condition first, as it will be faster than filtering the name with '%'
        // so we will check smaller set of records for the name
        //Shruthi - Done
        
        for(Opportunity oppRecord : [Select Id,Name,AccountId from Opportunity where AccountId IN :accountIdSet and Name like:'%' +oppName+ '%'])
        
        {
            mapAccountOpportunity.put(oppRecord.AccountId,oppRecord);
        }

        List<Acct_By_Sub__c> accountBySUBRecordList = new List<Acct_By_Sub__c>([Select Id, (Select Id,NS_Currency__c,
                    BG_Client_Contracting_Name__c, BG_Misys_Billing_Entity__c,Account_by_Sub__c,
                    Account_by_Sub__r.Account__c,BG_Billing_Group_Active__c
                    from Billing_Groups__r where BG_Billing_Group_Active__c = true)
                from Acct_By_Sub__c where Account__c IN:accountIdSet]);
        

        if(accountBySUBRecordList!=null && accountBySUBRecordList.size()>0)
        {
            purchaseOrdersToUpdate = getPurchaseOrders(accountBySUBRecordList);
        }

        
        // NG added the line below, because no need to query billing group if there are no purchase orders to update
        if(purchaseOrdersToUpdate == null || purchaseOrdersToUpdate.isEmpty()) return;

        for(Billing_Group__c BillingGroupRecd : [Select Id,Account_by_Sub__c,Account_by_Sub__r.Account__c,(Select Id,Name,System__c,
                Annual_Maintenance__c,Contract_Annual_Maintenance__c,
                CA_Billing_Status__c,NS_Subscription_Item_Start_Trigger__c,
                NS_Subscription__c,X3PP_Recurring_Costs__c,X3PP_Legacy_Coral_Sales_Ref__c,
                X3PP_Asset_Location__c,Account__c,CA_Billing_Group__c,
                Purchase_Order_Request__c from Contract_Assets__r where CA_Billing_Status__c='Active billing')
            from Billing_Group__c where Id IN :BillingGroupSetId])
 
        {
            mp_ListContractAsset.put(String.valueOf(BillingGroupRecd.Id),BillingGroupRecd.Contract_Assets__r);

        }


        Savepoint sp = Database.setSavepoint();
        try{

            if(purchaseOrdersToUpdate!=null && purchaseOrdersToUpdate.size()>0)
            {
                upsert purchaseOrdersToUpdate Composite_Key__c;

                List<Contract_Asset__c> contractAssets = getcontractAssets(purchaseOrdersToUpdate);

                if(contractAssets!=null && contractAssets.size()>0)
                {
                    update contractAssets;
                }
            }
        }catch(Exception e){

            Database.rollback(sp);
            system.debug('Exception occured: '+e);
            throw new ProductOrderException('Error while upserting purchase orders and contract assets: '+e.getMessage());

        }

    }

    // NG can we name it getPurchaseOrdersForAccounts, so it's not confusing with two getPurchaseOrders method?
    //Shruthi - i think its only one getPurchaseOrders
    private List<Purchase_Order__c> getPurchaseOrders(List<Acct_By_Sub__c> accountBySUBRecords)
    {

        for(Acct_By_Sub__c acctbySubRecd : accountBySUBRecords)
        {

            for(Billing_Group__c billingGroup : acctbySubRecd.Billing_Groups__r)
            {
                // Shruthi : - accountBySubKey denotes concatenated string (Account + MiscEntity + Ns Currency)
                String accountBySubKey = billingGroup.Account_by_Sub__r.Account__c+''+ billingGroup.BG_Misys_Billing_Entity__c +''+ billingGroup.NS_Currency__c;

                if(mp_DuplicateBG_AccountbySub.containsKey(accountBySubKey))
                {

                    List<Billing_Group__c> billingGroupListacctbySub = mp_DuplicateBG_AccountbySub.get(accountBySubKey);
                    billingGroupListacctbySub.add(billingGroup);
                    mp_DuplicateBG_AccountbySub.put(accountBySubKey,billingGroupListacctbySub);
                }

                else {
                    mp_DuplicateBG_AccountbySub.put(accountBySubKey, new List<Billing_Group__c>{billingGroup});
                }

            }
        }


        if(mp_DuplicateBG_AccountbySub!=null && mp_DuplicateBG_AccountbySub.values()!=null)
        {

            /* Shruthi : - Below are meaning of each attribute
               a. mp_DuplicateBG_AccountbySub : Map to contain key as "Billing Group Account" + "Misc Billing Entity" + "NS Currency" and 
                  value as List<Billing Group>.

               b. billingGroupKey : Concatenated String - Billing Group Account" + "Misc Billing Entity" + "NS Currency"
           */

            for(String billingGroupKey : mp_DuplicateBG_AccountbySub.keyset())
            {
                // Shruthi : billingGroupsForAccount stores the list of billing groups on basis of common key : Account,Misc Entity and NS Currency
                List<Billing_Group__c> billingGroupsForAccount = mp_DuplicateBG_AccountbySub.get(billingGroupKey);

                Purchase_Order__c PO_Order = createPurchaseOrder(billingGroupsForAccount);

                if(PO_Order!=null)
                {
                    purchaseOrders.add(PO_Order);
                }

            }
        }

        if(purchaseOrders!=null && purchaseOrders.size()>0)
        {
            return purchaseOrders;
        }

        return null;
    }

    // NG can we rename BGList_DuplaccountbySUB to billingGroupsForAccount or just billingGroups?
    // good rule of thumbs of naming variables is that they should be easy to say out loud and say what the value inside means
    // Shruthi - Can i mention that BGList_DuplaccountbySUB - Billing Group Duplicate Account By Sub, i felt its easy to refer
    
    private Purchase_Order__c createPurchaseOrder(List<Billing_Group__c> BGList_DuplaccountbySUB)
    {

        if(BGList_DuplaccountbySUB!=null && BGList_DuplaccountbySUB.size()>1)
        {
            Set<Id> BillingGroupSetId1 = new Set<Id>();
            for(Billing_Group__c bg : BGList_DuplaccountbySUB)
            {

                billingGroupSetId.add(bg.id);
                BillingGroupSetId1.add(bg.id);

            }

            Purchase_Order__c PO_Order1 = new Purchase_Order__c();
            PO_Order1.Account__c = BGList_DuplaccountbySUB[0] .Account_by_Sub__r.Account__c;
            PO_Order1.Misys_Entity__c = BGList_DuplaccountbySUB[0].BG_Misys_Billing_Entity__c;
            // PO_Order1.Billing_Group_Id__c = String.valueOf(BillingGroupbyAccountSub[0].id);
            PO_Order1.Purchase_Order_Revenue_Type__c = 'RLF';
            PO_Order1.Purchase_Order_Source__c = 'PO Created By Automation';

            for(Id BGID1 : BillingGroupSetId1){
                if(PO_Order1.Billing_Group_Id__c==null)
                    PO_Order1.Billing_Group_Id__c = '';

                PO_Order1.Billing_Group_Id__c += BGID1 + ',';
            }
            PO_Order1.Composite_Key__c = String.valueOf(PO_Order1.Billing_Group_Id__c);

            if(mapAccountOpportunity!=null && mapAccountOpportunity.containsKey(PO_Order1.Account__c))
                PO_Order1.MS_Opportunity__c = mapAccountOpportunity.get(PO_Order1.Account__c).id;

            return PO_Order1;

        }

        else if(BGList_DuplaccountbySUB!=null && BGList_DuplaccountbySUB.size()==1)
        {

            billingGroupSetId.add(BGList_DuplaccountbySUB[0].id);
            Purchase_Order__c PO_Order2 = new Purchase_Order__c();
            PO_Order2.Account__c = BGList_DuplaccountbySUB[0].Account_by_Sub__r.Account__c;
            PO_Order2.Misys_Entity__c = BGList_DuplaccountbySUB[0].BG_Misys_Billing_Entity__c;
            PO_Order2.Billing_Group_Id__c = String.valueOf(BGList_DuplaccountbySUB[0].id);
            PO_Order2.Purchase_Order_Revenue_Type__c = 'RLF';
            PO_Order2.Purchase_Order_Source__c = 'PO Created By Automation';

            if(mapAccountOpportunity!=null && mapAccountOpportunity.containsKey(PO_Order2.Account__c)){

                PO_Order2.MS_Opportunity__c = mapAccountOpportunity.get(PO_Order2.Account__c).id;
                PO_Order2.Composite_Key__c = BGList_DuplaccountbySUB[0].Account_by_Sub__r.Account__c +'-'+ mapAccountOpportunity.get(PO_Order2.Account__c).id +'-'+ String.valueOf(PO_Order2.Billing_Group_Id__c);
            }

            else {
                PO_Order2.Composite_Key__c = BGList_DuplaccountbySUB[0].Account_by_Sub__r.Account__c + '-' + String.valueOf(PO_Order2.Billing_Group_Id__c);
            }

            return PO_Order2;
        }

        return null;
    }


    private List<Contract_Asset__c> getContractAssets(List<Purchase_Order__c> purchaseOrders)
    {

        for(Purchase_Order__c PO_Create : purchaseOrders)
        {
            if(String.valueOf(PO_Create.Billing_Group_Id__c).contains(','))
            {
                List<String> currentBillingGroupIds = PO_Create.Billing_Group_Id__c.split(',');

                for(String bgId : currentBillingGroupIds)
                {
                    if(mp_ListContractAsset!=null && mp_ListContractAsset.containsKey(bgId))
                    {

                        for(Contract_Asset__c contractAsset_Record : mp_ListContractAsset.get(bgId))
                        {
                            contractAsset_Record.Purchase_Order_Request__c = PO_Create.Id;
                            contractAssetToPOList.add(contractAsset_Record);
                        }
                    }
                }

            }

            else
            {
                if(mp_ListContractAsset!=null && mp_ListContractAsset.containsKey(PO_Create.Billing_Group_Id__c))
                {

                    for(Contract_Asset__c contractAsset_Record : mp_ListContractAsset.get(PO_Create.Billing_Group_Id__c))
                    {

                        contractAsset_Record.Purchase_Order_Request__c = PO_Create.Id;
                        contractAssetToPOList.add(contractAsset_Record);
                    }
                }
            }
        }

        if(contractAssetToPOList!=null && contractAssetToPOList.size()>0)
        {
            return contractAssetToPOList;
        }

        return null;

    }

    class ProductOrderException extends Exception{}
}