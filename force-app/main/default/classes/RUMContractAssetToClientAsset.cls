public class RUMContractAssetToClientAsset extends RUMContractAssetBase
{
    public class RUOWContractAsset extends RollUpChild
    {
        public RUOWContractAsset(Contract_Asset__c ca) { super(ca); }
    
        private Contract_Asset__c TheCA {
            get { return (Contract_Asset__c)TheSObject; }
            set { TheSObject = value; }
        }
    
        public override Id getParentId() { return TheCA.Client_Asset__c; }
        public override string getCurrencyCode() { return TheCA.CurrencyIsoCode; }
        public override Decimal getAmount(Integer i) {
            if (i == 0) { return TheCA.Contract_Annual_Maintenance__c; }
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

    public class RUOWClientAsset extends RollUpParent
    {
        public RUOWClientAsset(Client_Asset__c ca) { super(ca); }
    
        private Client_Asset__c TheCA {
            get { return (Client_Asset__c)TheSObject; }
            set { TheSObject = value; }
        }
    
        public override string getCurrencyCode() { return TheCA.CurrencyIsoCode; }
        public override Decimal getRollUpAmount(Integer i) {
            if (i == 0) { return TheCA.Total_RLF_Maintenance__c; }
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
            if (i == 0) { TheCA.Total_RLF_Maintenance__c = amt; }
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
    
    protected override RollUpChild createRollUpChild(SObject ca)
    {
        return new RUOWContractAsset((Contract_Asset__c)ca);
    }

    public RUMContractAssetToClientAsset(List<Contract_Asset__c> triggerList, Map<Id, Contract_Asset__c> oldMap)
    {
        super(triggerlist, oldMap);
    }

    public override map<id, RollUpParent> createParentIdToObjectMap(Set<Id> parentIds)
    {
        map<id, RollUpParent> parentIdToObjectMap = new map<id, RollUpParent>();
        for (Client_Asset__c cliA : [
                select id, Name, Total_RLF_Maintenance__c, CurrencyIsoCode
                from Client_Asset__c
                where Id in :parentIds
        ]) {
            parentIdToObjectMap.put(cliA.Id, new RUOWClientAsset(cliA));
        }
        return parentIdToObjectMap;
    }
    
    public override map<id, RollUpChild> createChildIdToObjectMap(Set<Id> parentIds)
    {
        map<id, RollUpChild> childrenIdToObjectMap = new map<id, RollUpChild>();
        for (Contract_Asset__c conA : [
            select id, name, Contract_Annual_Maintenance__c, Client_Asset__c, CurrencyIsoCode
            from Contract_Asset__c
            where Client_Asset__c in :parentIds
        ]) {
            childrenIdToObjectMap.put(conA.Id, createRollUpChild(conA));
        }
        return childrenIdToObjectMap;
    }

    public override void updateParents(List<RollUpParent> parents)
    {
        List<Client_Asset__c> toUpdate = new List<Client_Asset__c>{};
        for (RollUpParent sow : parents) {
            toUpdate.add((Client_Asset__c)sow.TheSObject);
        }
        update toUpdate;
    }

}