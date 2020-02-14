public class RUMContractAssetToBillingGroup extends RUMContractAssetBillingAmounts
{
    public class RUOWContractAsset2Bg extends RUOWContractAsset
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
        public RUOWContractAsset2Bg(Contract_Asset__c ca) { super(ca); }
        public override Id getParentId() { return TheCA.CA_Billing_Group__c; }
    }
    
    public class RUOWBillingGroup extends RollUpParent
    {
        public RUOWBillingGroup(Billing_Group__c bg) { super(bg); }
    
        private Billing_Group__c TheBillGroup {
            get { return (Billing_Group__c)TheSObject; }
            set { TheSObject = value; }
        }
    
        public override string getCurrencyCode() { return TheBillGroup.CurrencyIsoCode; }
        public override Integer amountFieldCount() { return 2; }
        public override Decimal getRollUpAmount(Integer i) {
            if (i == 0) { return TheBillGroup.CY_Billing_Current_Amount__c; }
            else if (i == 1) { return TheBillGroup.CY_Billing_Previous_Amount__c; }
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
        public override void setRollUpAmount(Integer i, Decimal amt) {
            if (i == 0) { TheBillGroup.CY_Billing_Current_Amount__c = amt; }
            else if (i == 1) { TheBillGroup.CY_Billing_Previous_Amount__c = amt; }
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
    }
    
    public RUMContractAssetToBillingGroup(List<Contract_Asset__c> triggerNew, Map<Id, Contract_Asset__c> oldMap)
    {
        super(triggerNew, oldMap);
    }

    protected override RollUpChild createRollUpChild(SObject ca)
    {
        return new RUOWContractAsset2Bg((Contract_Asset__c)ca);
    }

    public override map<id, RollUpParent> createParentIdToObjectMap(Set<Id> parentIds)
    {
        map<id, RollUpParent> parentIdToObjectMap = new map<id, RollUpParent>();
        for (Billing_Group__c bg : [
                select id, CY_Billing_Current_Amount__c, CY_Billing_Previous_Amount__c, CurrencyIsoCode
                from Billing_Group__c
                where Id in :parentIds
        ]) {
            parentIdToObjectMap.put(bg.Id, new RUOWBillingGroup(bg));
        }
        return parentIdToObjectMap;
    }
    
    public override map<id, RollUpChild> createChildIdToObjectMap(Set<Id> parentIds)
    {
        map<id, RollUpChild> childrenIdToObjectMap = new map<id, RollUpChild>();
        for (Contract_Asset__c conA : [
            select id, CA_CY_Billing_Current_Amount__c, CA_CY_Billing_Previous_Amount__c, CurrencyIsoCode,
            CA_Billing_Group__c, /* this is the parent id */
            CA_Billing_Status__c
            from Contract_Asset__c
            where CA_Billing_Group__c in :parentIds
        ]) {
            if (conA.CA_Billing_Group__c != null) {
                childrenIdToObjectMap.put(conA.Id, createRollUpChild(conA));
            }
        }
        return childrenIdToObjectMap;
    }

    public override void updateParents(List<RollUpParent> parents)
    {
        List<Billing_Group__c> toUpdate = new List<Billing_Group__c>{};
        for (RollUpParent sow : parents) {
            toUpdate.add((Billing_Group__c)sow.TheSObject);
        }
        update toUpdate;
    }
}