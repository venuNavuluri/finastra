public class RUMContractAssetToAccount extends RUMContractAssetBillingAmounts
{
    
    public class RUOWContractAsset2Acct extends RUOWContractAsset
    {
        /*
        Method Name: getAmount_TP;
        Method Description: Implementing the new abstract method of RollUpChild;
        Input Parameter: Integer;
        Return Type: NULL;
        Methods called: NA
        Created By: Mihir Kumar;
    **/
        public override Decimal getAmount_TP(Integer i) {
            return null;
        }
        public RUOWContractAsset2Acct(Contract_Asset__c ca) { super(ca); }
        public override Id getParentId() { return TheCA.Account__c; }
    }
    
    public class RUOWAccount extends RollUpParent
    {
        public RUOWAccount(Account acct) { super(acct); }
    
        private Account TheAcct {
            get { return (Account)TheSObject; }
            set { TheSObject = value; }
        }
    
        public override string getCurrencyCode() { return TheAcct.CurrencyIsoCode; }
        public override Integer amountFieldCount() { return 2; }
        public override Decimal getRollUpAmount(Integer i) {
            if (i == 0) { return TheAcct.CY_Billing_Current_Amount__c; }
            else if (i == 1) { return TheAcct.CY_Billing_Previous_Amount__c; }
            return null;
        }
        /*
        Method Name: getRollUpAmount_TP;
        Method Description: Implementing the new abstract method of RollUpParent;
        Input Parameter: Integer;
        Return Type: NULL;
        Methods called: NA;
        Created By: Mihir Kumar;
    **/
        public override Decimal getRollUpAmount_TP(Integer i) {
            return null;
        }
        /*
        Method Name: setRollUpAmount_TP;
        Method Description: Implementing the new abstract method of RollUpParent;
        Input Parameter: Integer , Decimal;
        Return Type: Void;
        Methods called: NA;
        Created By: Mihir Kumar;
    **/
        public override void setRollUpAmount_TP(Integer i, Decimal amt) {

        }
        public override void setRollUpAmount(Integer i, Decimal amt) {
            if (i == 0) { TheAcct.CY_Billing_Current_Amount__c = amt; }
            else if (i == 1) { TheAcct.CY_Billing_Previous_Amount__c = amt; }
        }
    }
    
    public RUMContractAssetToAccount(List<Contract_Asset__c> triggerNew, Map<Id, Contract_Asset__c> oldMap)
    {
        super(triggerNew, oldMap);
    }

    protected override RollUpChild createRollUpChild(SObject ca)
    {
        return new RUOWContractAsset2Acct((Contract_Asset__c)ca);
    }

    public override map<id, RollUpParent> createParentIdToObjectMap(Set<Id> parentIds)
    {
        map<id, RollUpParent> parentIdToObjectMap = new map<id, RollUpParent>();
        for (Account acct : [
                select id, Name, CY_Billing_Current_Amount__c, CY_Billing_Previous_Amount__c, CurrencyIsoCode
                from Account
                where Id in :parentIds
        ]) {
            parentIdToObjectMap.put(acct.Id, new RUOWAccount(acct));
        }
        return parentIdToObjectMap;
    }
    
    public override map<id, RollUpChild> createChildIdToObjectMap(Set<Id> parentIds)
    {
        map<id, RollUpChild> childrenIdToObjectMap = new map<id, RollUpChild>();
        for (Contract_Asset__c conA : [
            select id, CA_CY_Billing_Current_Amount__c, CA_CY_Billing_Previous_Amount__c, CurrencyIsoCode,
            CA_Billing_Group__c, Account__c,
            CA_Billing_Status__c
            from Contract_Asset__c
            where Account__c in :parentIds
        ]) {
            if (conA.CA_Billing_Group__c != null) {
                childrenIdToObjectMap.put(conA.Id, createRollUpChild(conA));
            }
        }
        return childrenIdToObjectMap;
    }

    public override void updateParents(List<RollUpParent> parents)
    {
        List<Account> toUpdate = new List<Account>{};
        for (RollUpParent sow : parents) {
            toUpdate.add((Account)sow.TheSObject);
        }
        update toUpdate;
    }
}