public class RUMBillingGroupToBillingEntity extends RollUpManager
{
    public class RUOWBillingGroup extends RollUpChild
    {
        public RUOWBillingGroup(Billing_Group__c bg) { super(bg); }
    
        private Billing_Group__c TheBG {
            get { return (Billing_Group__c)TheSObject; }
            set { TheSObject = value; }
        }
    
        public override Id getParentId() { return TheBG.BG_Misys_Billing_Entity__c; }
        public override string getCurrencyCode() { return TheBG.CurrencyIsoCode; }
        public override Integer amountFieldCount() { return 2; }
        public override Decimal getAmount(Integer i) {
            if (i == 0) { return TheBG.CY_Billing_Current_Amount__c; }
            else if (i == 1) { return TheBG.CY_Billing_Previous_Amount__c; }
            return null;
        }
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
        
    }

    public class RUOWBillingEntity extends RollUpParent
    {
        public RUOWBillingEntity(Billing_Entity__c be) { super(be); }
    
        private Billing_Entity__c TheBE {
            get { return (Billing_Entity__c)TheSObject; }
            set { TheSObject = value; }
        }
    
        public override string getCurrencyCode() { return TheBE.CurrencyIsoCode; }
        public override Integer amountFieldCount() { return 2; }
        public override Decimal getRollUpAmount(Integer i) {
            if (i == 0) { return TheBE.CY_Billing_Current_Amount__c; }
            else if (i == 1) { return TheBE.CY_Billing_Previous_Amount__c; }
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
            if (i == 0)  { TheBE.CY_Billing_Current_Amount__c = amt; }
            else if (i == 1) { TheBE.CY_Billing_Previous_Amount__c = amt;}
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
    
    protected override RollUpChild createRollUpChild(SObject bg)
    {
        return new RUOWBillingGroup((Billing_Group__c)bg);
    }

    public RUMBillingGroupToBillingEntity(List<Billing_Group__c> triggerList, Map<Id, Billing_Group__c> oldMap)
    {
        List<RollUpChild> theChildren = new List<RollUpChild>();
        Map<Id, RollUpChild> theOldMap = new Map<Id, RollUpChild>();
        for (Billing_Group__c ca : triggerList) {
            theChildren.add(createRollUpChild(ca));
            if (oldMap != null) { theOldMap.put(ca.Id, createRollUpChild(oldMap.get(ca.Id))); }
        }
        SetParentIds(theChildren, theOldMap);   
    }

    public override map<id, RollUpParent> createParentIdToObjectMap(Set<Id> parentIds)
    {
        map<id, RollUpParent> parentIdToObjectMap = new map<id, RollUpParent>();
        for (Billing_Entity__c billE : [
                select id, Name, CY_Billing_Current_Amount__c, CY_Billing_Previous_Amount__c, CurrencyIsoCode
                from Billing_Entity__c
                where Id in :parentIds
        ]) {
            parentIdToObjectMap.put(billE.Id, new RUOWBillingEntity(billE));
        }
        return parentIdToObjectMap;
    }
    
    public override map<id, RollUpChild> createChildIdToObjectMap(Set<Id> parentIds)
    {
        map<id, RollUpChild> childrenIdToObjectMap = new map<id, RollUpChild>();
        for (Billing_Group__c bg : [
            select id, name, CY_Billing_Current_Amount__c, CY_Billing_Previous_Amount__c, CurrencyIsoCode,
            BG_Misys_Billing_Entity__c
            from Billing_Group__c
            where BG_Misys_Billing_Entity__c in :parentIds
        ]) {
            childrenIdToObjectMap.put(bg.Id, createRollUpChild(bg));
        }
        return childrenIdToObjectMap;
    }

    public override void updateParents(List<RollUpParent> parents)
    {
        List<Billing_Entity__c> toUpdate = new List<Billing_Entity__c>{};
        for (RollUpParent sow : parents) {
            toUpdate.add((Billing_Entity__c)sow.TheSObject);
        }
        update toUpdate;
    }

}