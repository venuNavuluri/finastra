public class WizAssetCreationProductController
{
    IWACMainController theMainController;
    OpportunityLineItem[] assetOLIs;
    OpportunityLineItem[] OLIs;
    Map<string, PickableProductSet> ProductSets;
    private Map<Id, List<Contract_Asset__c>> oliIdToContractAssetListMap;

    //AK - added the UnitPrice and Quantity in the select fields
    public WizAssetCreationProductController(IWACMainController parent)
    {
        theMainController = parent;
        assetOLIs = [
            select Id, Location__c,
                PriceBookEntry.Product2.Id,
                PriceBookEntry.Product2.Name,
                PriceBookEntry.Product2.Product_Set__c,
                PriceBookEntry.Product2.Vendor_BSch_Trigger__c,
                PriceBookEntry.Product2.Licence_Group_ELS__c,
                PriceBookEntry.Product2.Licence_Group_LoanIQ__c,
                PriceBookEntry.Product2.Licence_Group_No_Key__c,
                PriceBookEntry.Product2.Licence_Group_GMS__c,
                PriceBookEntry.Product2.Licence_Group_Sophis__c,
                PriceBookEntry.Product2.Licence_Group_ELS_KVAR__c,
                PriceBookEntry.Product2.Licence_Group_Summit__c,
                PriceBookEntry.Product2.Licence_Group_TopOffice__c,
                PriceBookEntry.Product2.Licence_Group_MGR__c,
                PriceBookEntry.Product2.NS_Create_3PP_Event__c,
                PriceBookEntry.Pricebook2.Name, OLI_3PP__c,
                Term_Begin_Date__c, Term_End_Date__c, RPA_Recurring_Value__c,
                Licence_Band__c, License_Metric__c, Licence_Metric_Quantity__c, ThirdParty_PO_Currency__c,Opp_Number__c,
                Annual_Maintenance__c, TotalPrice, Proposed_RLF__c, ThirdParty_Recurring_Costs_PO_Ccy__c,
                CurrencyISOCode, Pearl_Item__c, UnitPrice, Quantity, GA__c, RLF_Fair_Value__c, RLF_Discount_Premium__c 
            from OpportunityLineItem oli
            where OpportunityId = :theMainController.GetContractOpportunityId()
            // making sure that it is an item created with "new pricing"
            //AK - using the new field Is_RLF_Asset__c instead of IsAsset__c as from now on the new field will be populated are assetisable RLF products
            //and PriceBookEntry.Product2.IsAsset__c = true
            and PriceBookEntry.Product2.Is_RLF_Asset__c = true
            order by PriceBookEntry.Product2.Product_Set__c
        ];
        List<string> oliIds = new List<string>();
        for (OpportunityLineItem oli : assetOLIs) {
            if (oli.Pearl_Item__c == true && oli.PriceBookEntry.Pricebook2.Name == 'Misys') {
                getOLIs().add(oli);
                oliIds.add(oli.Id);
            }
        }
        oliIdToContractAssetListMap = buildOliIdToContractAssetListMap(oliIds);
    }

    private Map<Id, List<Contract_Asset__c>> buildOliIdToContractAssetListMap(List<string> oliIds)
    {
        Map<Id, List<Contract_Asset__c>> oliIdToContractAssetListMap = new Map<Id, List<Contract_Asset__c>>();
        List <Contract_Asset__c> casUnderOli;
        for (Contract_Asset__c existingCA : [
            select Id, OpportunityLineItem__c, Contract_Annual_Maintenance__c, Original_Fair_Value__c, Current_Fair_Value__c,
            X3PP_Recurring_Costs__c, Annual_Maintenance_for_NS__c, RPA_List_Value__c
            from Contract_Asset__c
            where OpportunityLineItem__c in :oliIds
        ]) {
            casUnderOli = oliIdToContractAssetListMap.get(existingCA.OpportunityLineItem__c);
            if (casUnderOli == null) {
                casUnderOli = new List<Contract_Asset__c>();
                oliIdToContractAssetListMap.put(existingCA.OpportunityLineItem__c, casUnderOli);
            }
            casUnderOli.add(existingCA);
        }
        return oliIdToContractAssetListMap;
    }

    private Double getSumContracted(OpportunityLineItem oli)
    {
        if (oli.Pearl_Item__c == true) {   // new pricing model: only RLF amount on the OLI
            //AK - commenting the below line as Annual Maintenance needs to be calculated based on the UnitPrice and Quantity 
            //return MathUtils.NVL(oli.Annual_Maintenance__c);
            
            //AK - This is the new requirement
            return MathUtils.NVL(oli.UnitPrice) * MathUtils.NVL(oli.Quantity);
        }
        else {  // old pricing model: RLF is included in the total price
            return MathUtils.NVL(oli.TotalPrice);
        }
    }
    
    //AK-added this for the 3pp
    private Double getSumContracted3pp(OpportunityLineItem oli)
    {
        return MathUtils.NVL(oli.ThirdParty_Recurring_Costs_PO_Ccy__c);
    }

    //AK-added this for the RLF Fair value
    private Double getSumContractedRlfFairValue(OpportunityLineItem oli)
    {
        return MathUtils.NVL(oli.RLF_Fair_Value__c);
    }

    //AK-added this for the RPA List
    private Double getSumContractedRpaList(OpportunityLineItem oli)
    {
        return MathUtils.NVL(oli.RPA_Recurring_Value__c);
    }

    private Double getSumAssetized(Id oliId)
    {
        Double sum = 0;
        if (!oliIdToContractAssetListMap.containsKey(oliId)) { return 0; }
        for (Contract_Asset__c coA : oliIdToContractAssetListMap.get(oliId)) {
            sum += MathUtils.nvl(coA.Contract_Annual_Maintenance__c);
        }
        return sum;
    }

    //AK-added this for the 3pp 
    private Double getSumAssetized3pp(Id oliId)
    {
        Double sum = 0;
        if (!oliIdToContractAssetListMap.containsKey(oliId)) { return 0; }
        for (Contract_Asset__c coA : oliIdToContractAssetListMap.get(oliId)) {
            sum += MathUtils.nvl(coA.X3PP_Recurring_Costs__c);
        }
        return sum;
    }

    //AK-added this for the Original fair value 
    private Double getSumAssetizedRlfOrgFairValue(Id oliId)
    {
        Double sum = 0;
        if (!oliIdToContractAssetListMap.containsKey(oliId)) { return 0; }
        for (Contract_Asset__c coA : oliIdToContractAssetListMap.get(oliId)) {
            sum += MathUtils.nvl(coA.Original_Fair_Value__c);
        }
        return sum;
    }

    //AK-added this for the Current fair value  
    private Double getSumAssetizedRlfCurFairValue(Id oliId)
    {
        Double sum = 0;
        if (!oliIdToContractAssetListMap.containsKey(oliId)) { return 0; }
        for (Contract_Asset__c coA : oliIdToContractAssetListMap.get(oliId)) {
            sum += MathUtils.nvl(coA.Current_Fair_Value__c);
        }
        return sum;
    }

    //AK-added this for the RPA list
    private Double getSumAssetizedRpaList(Id oliId)
    {
        Double sum = 0;
        if (!oliIdToContractAssetListMap.containsKey(oliId)) { return 0; }
        for (Contract_Asset__c coA : oliIdToContractAssetListMap.get(oliId)) {
            sum += MathUtils.nvl(coA.RPA_List_Value__c);
        }
        return sum;
    }

    public OpportunityLineItem[] getAssetOLIs() {
        if (assetOLIs == null) { assetOLIs = new OpportunityLineItem[]{}; }
        return assetOLIs;
    }
    
    public OpportunityLineItem[] getOLIs() {
        if (OLIs == null) { OLIs = new OpportunityLineItem[]{}; }
        return OLIs;
    }
    
    
    public PickableProductSet[] getProductSets()
    {
        Double sumContracted, sumAssetized, sumContracted3pp, SumContractedRlfFairValue, SumContractedRpaList;
        Double SumAssetized3pp, SumAssetizedRlfOrgFairValue, SumAssetizedRlfCurFairValue, SumAssetizedRpaList;
        boolean toAssetize;
        List<PickableProductSet> sortedList = new List<PickableProductSet>{};
        if (ProductSets == null) {
            ProductSets = new Map<string, PickableProductSet>();
            for (OpportunityLineItem oli : getOLIs()) {
                String psName = oli.PriceBookEntry.Product2.Product_Set__c;
                PickableProductSet parentProductSet = ProductSets.get(psName);
                if (parentProductSet == null) {
                    parentProductSet = new PickableProductSet(psName);
                    ProductSets.put(psName, parentProductSet);
                }
                sumContracted = getSumContracted(oli);
                sumAssetized = getSumAssetized(oli.Id);
                sumContracted3pp = getSumContracted3pp(oli);
                SumContractedRlfFairValue = getSumContractedRlfFairValue(oli);
                SumContractedRpaList = getSumContractedRpaList(oli);
                SumAssetized3pp = getSumAssetized3pp(oli.Id);
                SumAssetizedRlfOrgFairValue = getSumAssetizedRlfOrgFairValue(oli.Id);
                SumAssetizedRlfCurFairValue = getSumAssetizedRlfCurFairValue(oli.Id);
                SumAssetizedRpaList = getSumAssetizedRpaList(oli.Id);
                
                toAssetize = (sumAssetized != sumContracted);
                parentProductSet.AddOLI(
                    new PickableOLI(oli, toAssetize, sumAssetized, sumContracted, sumContracted3pp, SumContractedRlfFairValue, SumContractedRpaList,
                                    SumAssetized3pp, SumAssetizedRlfOrgFairValue, SumAssetizedRlfCurFairValue, SumAssetizedRpaList)
                );
                parentProductSet.Selected = parentProductSet.GetAreAllProductsSelected();
            }
        }
        List<String> keys = new List<String>();
        keys.addAll(ProductSets.keySet());
        keys.sort();
        for (string oneKey : keys) {
            sortedList.add(ProductSets.get(oneKey));
        }
        return sortedList;
    }
    
    public void UpdateOLIInfoFields(Double sumLoading)
    {
        Double assetizationBase;
        for (PickableProductSet productSet : getProductSets()) {
            productSet.Assetizing = 0;
            for (PickableOLI oli : productSet.Products) {
                if (oli.Selected) {
                    assetizationBase = MathUtils.NVL(
                        theMainController.AssetizeByRemainingAmount() ?
                        oli.GetRemainingBefore() : oli.SumContracted 
                    );
                    oli.Assetizing = assetizationBase * MathUtils.NVL(sumLoading)/100;
                    productSet.Assetizing += oli.Assetizing;
                }
            }
        }
    }

}