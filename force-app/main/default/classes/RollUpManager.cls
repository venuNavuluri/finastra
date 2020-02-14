public abstract class RollUpManager
{
    public abstract class RollUpObjectWrapper
    {
        public SObject TheSObject { get; set; }
        public abstract string getCurrencyCode();
        public virtual Integer amountFieldCount() { return 1; }
        public RollUpObjectWrapper(SObject obj) { TheSObject = obj; }
    }

    public abstract class RollUpChild extends RollUpObjectWrapper
    {
        public abstract Id getParentId();
        public abstract Decimal getAmount(Integer i);
        public abstract Decimal getAmount_TP(Integer i);
        public virtual boolean includeInRollUp() { return true; }
        public virtual boolean isActive() { return true; }      
        
        public RollUpChild(SObject obj) { super(obj); }
    }
    
    public abstract class RollUpParent extends RollUpObjectWrapper
    {
        public abstract Decimal getRollUpAmount(Integer i);
        public abstract Decimal getRollUpAmount_TP(Integer i);
        public abstract void setRollUpAmount(Integer i, Decimal amt);
        public abstract void setRollUpAmount_TP(Integer i, Decimal amt);

        public RollUpParent(SObject obj) { super(obj); }
    }
    
    protected Set<Id> ParentIdSet { get; set; }
    public abstract map<id, RollUpParent> createParentIdToObjectMap(Set<Id> parentIds);
    public abstract map<id, RollUpChild> createChildIdToObjectMap(Set<Id> parentIds);
    protected abstract RollUpChild createRollUpChild(SObject ch);
    protected abstract void updateParents(List<RollUpParent> parents);
    
    protected void SetParentIds(List<RollUpChild> children, Map<Id, RollUpChild> oldMap)
    {
        Set<Id> parentIds = new Set<Id>{};
        for (RollUpChild ruc : children) {
            if (ruc.getParentId() != null) {
                parentIds.add(ruc.getParentId());
            }
            if (oldMap.size() != 0 && oldMap.get(ruc.TheSObject.Id).getParentId() != null) {
                parentIds.add(oldMap.get(ruc.TheSObject.Id).getParentId());
            }
        }
        ParentIdSet = parentIds;
    }

    private map<String, List<RollUpChild>> buildParentIdToChildrenListMap(map<id, RollUpChild> childrenIdToObjectMap)
    {
        map<String, List<RollUpChild>> parentIdToChildrenListMap = new map<String, List<RollUpChild>>();

        for (RollUpChild child : childrenIdToObjectMap.values()) {
            if (parentIdToChildrenListMap.get(child.getParentId()) == null) {
                parentIdToChildrenListMap.put(child.getParentId(), new List<RollUpChild>());
            }
            parentIdToChildrenListMap.get(child.getParentId()).add(child);
        }
        
        return parentIdToChildrenListMap;
    }
    
    private void aggregateForOneParent(
        String parentId,
        map<id, RollUpParent> parentIdToObjectMap,
        map<String, List<RollUpChild>> parentIdToChildrenListMap,
        map<String, Double> currRateMap,
        List<RollUpParent> parentsToUpdate)
    {
        RollUpParent parent = parentIdToObjectMap.get(parentId);
        List<RollUpChild> children = parentIdToChildrenListMap.get(parentId);
        if (parent != null) {
            //Calling method related to Roll-Up of Fair Value
            Aggregate(parent, children, currRateMap);
            Aggregate_TP(parent, children, currRateMap);                
        }

        parentsToUpdate.add(parent);
    }
    
    public static void Aggregate(
        RollUpParent parent,
        List<RollUpChild> children,
        map<String, Double> currRateMap) 
    {
        Decimal[] amt = new Decimal[]{};
        for (Integer i = 0; i < parent.amountFieldCount(); i++) {
            amt.add(0.0);
        }
        
        if (children != null) {
            for(RollUpChild child : children) {
                if (child.includeInRollUp() && child.isActive()) {
                    increaseAmountsByChildValues(child, currRateMap, amt);
                }
            }
        }
        
        setRollUpAmountsInParent(parent, currRateMap, amt);
    }
    
    /*
        Method Name: Aggregate_TP;
        Method Description: Roll-Up of Total price of Opportunity Products in an Opportunity;
        Input Parameter: RollUpParent , List<RollUpChild> , map<String, Double>;
        Return Type: Void;
        Methods called: amountFieldCount() , increaseAmountsByChildValues_TP(RollUpChild,map<String, Double>,Decimal[]) ,
                        setRollUpAmountsInParent_TP(RollUpParent,map<String, Double>,Decimal[]);
        Created By: Mihir Kumar;
    **/
    
    public static void Aggregate_TP(
        RollUpParent parent,
        List<RollUpChild> children,
        map<String, Double> currRateMap) 
    {
        Decimal[] amt1 = new Decimal[]{};
        for (Integer i = 0; i < parent.amountFieldCount(); i++) {
            amt1.add(0.0);
        }
        
        if (children != null) {
            for(RollUpChild child : children) {
                if (child.includeInRollUp() && child.isActive()) {
                    increaseAmountsByChildValues_TP(child, currRateMap, amt1);
                }
            }
        }
        
        setRollUpAmountsInParent_TP(parent, currRateMap, amt1);
    }
    
    private static void increaseAmountsByChildValues(RollUpChild child, map<String, Double> currRateMap, Decimal[] amt)
    {
        if (child.getCurrencyCode() == FinanceUtils.GetCorporateCurrency()) {
            for (Integer i = 0; i < child.amountFieldCount(); i++) {
                amt[i] += MathUtils.NVL(child.getAmount(i));
            }
        }
        else {
            Double rate = currRateMap.get(child.getCurrencyCode());
            for (Integer i = 0; i < child.amountFieldCount(); i++) {
                amt[i] += (MathUtils.NVL(child.getAmount(i)) / rate);
            }
        }
    }
    
    /*
        Method Name: increaseAmountsByChildValues_TP;
        Method Description: Getting Total Value from Opportunity Product and adding them to Amount;
        Input Parameter: RollUpParent , map<String, Double> , Decimal[];
        Return Type: Void;
        Methods called: getAmount_TP(Integer) , amountFieldCount();
        Created By: Mihir Kumar;
    **/
    
    private static void increaseAmountsByChildValues_TP(RollUpChild child, map<String, Double> currRateMap, Decimal[] amt1)
    {
        if (child.getCurrencyCode() == FinanceUtils.GetCorporateCurrency()) {
            for (Integer i = 0; i < child.amountFieldCount(); i++) {
                amt1[i] += MathUtils.NVL(child.getAmount_TP(i));
            }
        }
        else {
            Double rate = currRateMap.get(child.getCurrencyCode());
            for (Integer i = 0; i < child.amountFieldCount(); i++) {
                amt1[i] += (MathUtils.NVL(child.getAmount_TP(i)) / rate);
            }
        }
    }
    
    private static void setRollUpAmountsInParent(
        RollUpParent parent,
        map<String, Double> currRateMap,
        Decimal[] amt)
    {
        if (parent.getCurrencyCode() == FinanceUtils.GetCorporateCurrency()) {
            for (Integer i = 0; i < parent.amountFieldCount(); i++) {
                parent.setRollUpAmount(i, amt[i]);
            }
        }
        else {
            Double rate = currRateMap.get(parent.getCurrencyCode());
            for (Integer i = 0; i < parent.amountFieldCount(); i++) {
                parent.setRollUpAmount(i, amt[i] * rate);
            }
        }
    }
    
    /*
        Method Name: setRollUpAmountsInParent_TP;
        Method Description: Setting Roll-Up amount of Total Price depending on the currency rate in Parent(Opportunity) 
                            by calling setRollUpAmount_TP;
        Input Parameter: RollUpParent , map<String, Double> , Decimal[];
        Return Type: Void;
        Methods Called: setRollUpAmount_TP(Integer,Decimal) , amountFieldCount();
        Created By: Mihir Kumar;
    **/
    
    private static void setRollUpAmountsInParent_TP(
        RollUpParent parent,
        map<String, Double> currRateMap,
        Decimal[] amt1)
    {
        if (parent.getCurrencyCode() == FinanceUtils.GetCorporateCurrency()) {
            for (Integer i = 0; i < parent.amountFieldCount(); i++) {
                parent.setRollUpAmount_TP(i, amt1[i]);
            }
        }
        else {
            Double rate = currRateMap.get(parent.getCurrencyCode());
            for (Integer i = 0; i < parent.amountFieldCount(); i++) {
                parent.setRollUpAmount_TP(i, amt1[i] * rate);
            }
        }
    }
    
    public void DoRollUp()
    {
        if (ParentIdSet == null || ParentIdSet.size() == 0) {
            return;
        }

        List<RollUpParent> parentsToUpdate = new List<RollUpParent>();
        map<id, RollUpParent> parentIdToObjectMap = createParentIdToObjectMap(ParentIdSet);
        map<id, RollUpChild> childrenIdToObjectMap = createChildIdToObjectMap(ParentIdSet);
        map<String, List<RollUpChild>> parentIdToChildrenListMap = buildParentIdToChildrenListMap(childrenIdToObjectMap);
        
        map<String, Double> currRateMap = FinanceUtils.GetCurrencyRateMap();
        for (String parentId : ParentIdSet) {
        	//AK - added the code to remove the rollup processing. If the Rollup_Calculate_Batch_Hold__c is false on Opp then that will be ignored.
        	RollUpObjectWrapper row = (RollUpObjectWrapper) parentIdToObjectMap.get(parentId);
        	if(row.TheSObject instanceof Opportunity){
	        	Opportunity oppToProcess = (Opportunity)row.TheSObject;
	        	system.debug('oppToProcess = ' + oppToProcess);
	        	system.debug('oppToProcessRollup_Calculate_Batch_Hold__c = ' + oppToProcess.Rollup_Calculate_Batch_Hold__c);
	        	if(oppToProcess.Rollup_Calculate_Batch_Hold__c == false){
		            aggregateForOneParent(parentId, parentIdToObjectMap, parentIdToChildrenListMap, currRateMap, parentsToUpdate);
	        	}
        	} else {
	            aggregateForOneParent(parentId, parentIdToObjectMap, parentIdToChildrenListMap, currRateMap, parentsToUpdate);
        	}
        }
                    
        if (parentsToUpdate.size() > 0) {
            updateParents(parentsToUpdate);
        }
    }
}