public with sharing class AssetMaintenance_AssetUtils
{
    public enum AssetizingBase { CONTRACTED, REMAINING }
    
    private static final string CORPORATE_CURRENCY = FinanceUtils.GetCorporateCurrency();
    
    private static Map<string, Contract_Asset__c> queryExistingContractAssets(
        Contract contract,
        Map<string, Client_Asset__c> clientAssetMap,
        Set<PickableEnvironment> environments,
        Set<Id> oliIds
    ) {
        Set<string> environmentNames = new Set<string>();
        for (PickableEnvironment env : environments) { environmentNames.add(env.Name); }
        string key;
        Map<string, Contract_Asset__c> exContractAssetMap = new Map<string, Contract_Asset__c>();
        Contract_Asset__c[] existingContractAssets = [
            select Id, Name, Account__c, Environment2__c, Client_Asset__c,
                Contract_Annual_Maintenance__c, Annual_Maintenance__c, Original_Fair_Value__c, Current_Fair_Value__c, X3PP_Recurring_Costs__c,
                Annual_Maintenance_for_NS__c, RPA_List_Value__c,
                System__c, System__r.Name,
                Client_Asset__r.Product__r.Product_Set__c,
                Client_Asset__r.Product__r.Licence_Group_ELS__c,
                Client_Asset__r.Product__r.Licence_Group_LoanIQ__c,
                Client_Asset__r.Product__r.Licence_Group_No_Key__c,
                Client_Asset__r.Product__r.Licence_Group_GMS__c,
                Client_Asset__r.Product__r.Licence_Group_Sophis__c,
                Client_Asset__r.Product__r.Licence_Group_ELS_KVAR__c,
                Client_Asset__r.Product__r.Licence_Group_Summit__c,
                Client_Asset__r.Product__r.Licence_Group_TopOffice__c,
                Client_Asset__r.Product__r.Licence_Group_MGR__c,
                OpportunityLineItem__c
            from Contract_Asset__c
            where Client_Asset__c in :clientAssetMap.values()
            and Environment2__c in :environmentNames
            and Contract__c = :contract.Id
            and OpportunityLineItem__c in :oliIds
        ];
        string customPostfix, envName;
        for (Contract_Asset__c exCA : existingContractAssets) {
            customPostfix = MisysStringUtils.GetCustomPostfix(exCA.System__r.Name);
            envName = MisysStringUtils.GetEnvironmentName(exCA.System__r.Name);
            for (PickableEnvironment env : environments) {
                if (env.Name == envName && env.SystemPostfix == customPostfix) {
                    // <account Id>#<product set name>#<licence group name>#<environment name>#<oli ID> -> Contract Asset
                    key = MisysStringUtils.GetContractAssetKey(
                        exCA.Account__c,
                        exCA.Client_Asset__r.Product__r.Product_Set__c,
                        MisysStringUtils.GetLicenceGroup(exCA.Client_Asset__r.Product__r),
                        exCA.Environment2__c,
                        exCA.OpportunityLineItem__c
                    );
                    exContractAssetMap.put(key, exCA);
                }
            }
        }
        return exContractAssetMap;
    }
    
    public static  Map<string, Contract_Asset__c> createContractAssets(
        Contract contract,
        Set<Id> AssetLocations,
        Set<PickableEnvironment> environments,
        Map<string, Client_Asset__c> clientAssetMap,
        Map<string, System__c> systemMap,
        PickableOLI[] olis,
        Map<string, WACAccountWithSystem> loadingMap,
        AssetizingBase baseIndicator
    ) {
        Set<Id> oliIds = new Set<Id>();
        for (PickableOLI oneOLI : olis) { oliIds.add(oneOLI.TheOLI.Id); }
        // <account Id>#<product set name>#<licence group name>#<environment name>#<oli ID> -> Contract Asset
        Map<string, Contract_Asset__c> exContractAssetMap =
            queryExistingContractAssets(contract, clientAssetMap, environments, oliIds);
        Contract_Asset__c coA;
        string assetName, productSetName, licenceGroup, contractAssetKey, envName;
        
        for (Id assetLocationAcctId : AssetLocations) {
            for (PickableEnvironment env : environments) {
                for(PickableOLI oli : olis) {
                    assetName = oli.TheOLI.PriceBookEntry.Product2.Name;
                    productSetName = oli.TheOLI.PriceBookEntry.Product2.Product_Set__c;
                    licenceGroup = MisysStringUtils.GetLicenceGroup(oli.TheOLI.PriceBookEntry.Product2);
                    envName = MisysStringUtils.GetPostfixedEnvironmentName(env.Name, env.SystemPostfix);
                    contractAssetKey = MisysStringUtils.GetContractAssetKey(
                        assetLocationAcctId, productSetName, licenceGroup, envName, oli.TheOLI.Id
                    );
                    System__c sys = systemMap.get(MisysStringUtils.GetSystemKey(assetLocationAcctId, envName, licenceGroup));
                    if (!exContractAssetMap.containsKey(contractAssetKey)) {
                        coA = createNewContractAssetInstance(
                            assetName, productSetName,
                            assetLocationAcctId,
                            oli.TheOLI,
                            contract,
                            clientAssetMap,
                            sys
                        );
                        exContractAssetMap.put(contractAssetKey, coA);
                    }
                    allocateAmount(oli, contractAssetKey, exContractAssetMap, loadingMap, baseIndicator, sys);
                }
            }
        }
        upsert exContractAssetMap.values();
        
        //AK- update the olis for ISRLFAssetised flag
        set<id> oliIdSet = new set<id>();
        list<OpportunityLineItem> updateOliList = new list<OpportunityLineItem>();
        for(Contract_Asset__c conAsset : exContractAssetMap.values()){
            if(conAsset.OpportunityLineItem__c != null && !oliIdSet.contains(conAsset.OpportunityLineItem__c)){
                oliIdSet.add(conAsset.OpportunityLineItem__c);
                updateOliList.add(new OpportunityLineItem(Id = conAsset.OpportunityLineItem__c, IsRLFAssetised__c = true));
            }
        }
        
        if(updateOliList != null && updateOliList.size() > 0){
            update updateOliList;
        }
        
        return exContractAssetMap;
    }
    
    private static void allocateAmount(
        PickableOLI oli,
        string contractAssetKey,
        Map<string, Contract_Asset__c> exContractAssetMap,
        Map<string, WACAccountWithSystem> loadingMap,
        AssetizingBase baseIndicator,
        System__c sys
    ) {
        system.debug('allocateAmount - oli = ' + oli);
        //system.debug('allocateAmount - contractAssetKey = ' + contractAssetKey);
        //system.debug('allocateAmount - exContractAssetMap = ' + exContractAssetMap);
        //system.debug('allocateAmount - loadingMap = ' + loadingMap);
        system.debug('allocateAmount - baseIndicator = ' + baseIndicator);
        //system.debug('allocateAmount - sys = ' + sys);
        Contract_Asset__c coA = exContractAssetMap.get(contractAssetKey);
        //system.debug('allocateAmount - coA = ' + coA);
        Double loading = 0;
        WACAccountWithSystem loadingItem =
            loadingMap.get(coA.Account__c + '#' + sys.Environment2__c);
        system.debug('allocateAmount - loadingItem = ' + loadingItem);
        if (loadingItem != null) {
            loading = MathUtils.NVL(loadingItem.LoadingPercentage)/100;
        }
        system.debug('allocateAmount - loading = ' + loading);
        system.debug('allocateAmount - coA.Contract_Annual_Maintenance__c = ' + coA.Contract_Annual_Maintenance__c);
        coA.Contract_Annual_Maintenance__c =
            MathUtils.NVL(coA.Contract_Annual_Maintenance__c) + loading * getSumAssetizing(oli, baseIndicator);
        system.debug('allocateAmount - coA.Annual_Maintenance__c = ' + coA.Annual_Maintenance__c);
        coA.Annual_Maintenance__c =
            MathUtils.NVL(coA.Annual_Maintenance__c) + loading * getSumAssetizing(oli, baseIndicator); // TODO: this will be CPI'd year by year

        //Ak - new fields
        system.debug('allocateAmount - coA.Annual_Maintenance_for_NS__c = ' + coA.Annual_Maintenance_for_NS__c);
       
       /*As per Sue's Request - Maintenance Sweep Invoice Timings v4 - 26/10/2016
       / coA.Annual_Maintenance_for_NS__c =
            MathUtils.NVL(coA.Annual_Maintenance_for_NS__c) + loading * getSumAssetizing(oli, baseIndicator);*/
        
        system.debug('allocateAmount - coA.Original_Fair_Value__c = ' + coA.Original_Fair_Value__c);
        coA.Original_Fair_Value__c =
            MathUtils.NVL(coA.Original_Fair_Value__c) + loading * getSumContractedRlfOrgFairValue(oli, baseIndicator);
        
        system.debug('allocateAmount - coA.Current_Fair_Value__c = ' + coA.Current_Fair_Value__c);
        coA.Current_Fair_Value__c =
            MathUtils.NVL(coA.Current_Fair_Value__c) + loading * getSumContractedRlfCurFairValue(oli, baseIndicator);
        
        system.debug('allocateAmount - coA.X3PP_Recurring_Costs__c = ' + coA.X3PP_Recurring_Costs__c);
        coA.X3PP_Recurring_Costs__c =
            MathUtils.NVL(coA.X3PP_Recurring_Costs__c) + loading * getSumAssetizing3pp(oli, baseIndicator);
        
        system.debug('allocateAmount - coA.RPA_List_Value__c = ' + coA.RPA_List_Value__c);
        coA.RPA_List_Value__c =
            MathUtils.NVL(coA.RPA_List_Value__c) + loading * getSumContractedRpaList(oli, baseIndicator);


        System.debug('Contract Asset amount-allocation... Loading: ' + loading);
        System.debug('OLI Name: ' + oli.getName() + '. Amount: ' + oli.SumContracted);
        System.debug('CA Name: ' + coA.Name + '. Amount: ' + coA.Contract_Annual_Maintenance__c);
    }
    
    private static Contract_Asset__c createNewContractAssetInstance(
        string assetName, string productSetName,
        Id assetLocationAcctId,
        OpportunityLineItem oli,
        Contract contract,
        Map<string, Client_Asset__c> clientAssetMap,
        System__c sys
    ) {
        Client_Asset__c parentClientAsset = clientAssetMap.get(
            MisysStringUtils.GetClientAssetKey(assetLocationAcctId, productSetName, oli.PriceBookEntry.Product2.Id)
        );
        if(assetName != null && assetName.length() > 80){
            assetName = assetName.subString(0, 79);
        }
        
            String assetLocation = '';
        String oppNumber = '';
        
        if (oli.OLI_3PP__c == true) {
        assetLocation = oli.Location__c;
        oppNumber = oli.Opp_Number__c;
        }
        
        Contract_Asset__c coA = new Contract_Asset__c(
            Name = assetName,
            Account__c = assetLocationAcctId,
            Client_Asset__c = parentClientAsset.Id,
            System__c = sys.Id,
            License_Status__c = 'Active',
            Licence_Status_Date__c = contract.StartDate,
            //xxxContract_RLF_Review_Date__c = contract.RLF_Earliest_Review_Date__c,  // xxxContract_RLF_Review_Date__c 
            Contract__c = contract.Id,
            Licence_Band__c = oli.Licence_Band__c,
            License_Metric__c = oli.License_Metric__c,
            Quantity__c = oli.Licence_Metric_Quantity__c,
            CurrencyISOCode = oli.CurrencyISOCode,
            OpportunityLineItem__c = oli.Id,
            Term_Begin_Date__c = contract.StartDate,
            Term_End_Date__c = contract.Contract_Expiry_Date__c,
            CA_Recurring_Fees_percent__c = contract.Recurring_Fees_percent__c,
            CA_Recurring_Fees_Earliest_Review_Date__c = contract.RLF_Earliest_review_Date__c,
            //xxxCA_Recurring_Fees_Increase_CAP_Exp_Date__c = contract.xxxAnnual_Maintenance_Increase_CAP_Exp_Date__c,   // xxx-ed the contract field 
            CA_Recurring_Fees_Index__c = contract.Recurring_Fees_Index__c,
            CA_Recurring_Fees_Index_Type__c = contract.Recurring_Fees_Index_Type__c,
            CA_Recurring_Fees_Rate_Increase_Max__c = contract.Rate_Increase_Cap_Value__c,
            CA_Recurring_Fees_Rate_Increase_Min__c = contract.Rate_Increase_Floor__c, 
            CA_Recurring_Fees_Review_Month__c = contract.Recurring_Fees_Review_Month__c,
            CA_Billing_Status__c = 'Billing to be set up',
//          Bill_To_Ship_To__c = TODO: add a wizard page to pick a Bill_To_Ship_to record
            Asset_Source__c = 'Asset Wizard 3.0',
            Maintenance_Status__c = 'On Maintenance',
            Maintenance_Status_Date__c = contract.StartDate,
            Usage_Status__c = 'Not Yet Implemented',
            //AK-new fields
            Asset_Product_GA__c = oli.GA__c,
            //Original_Fair_Value__c = oli.RLF_Fair_Value__c,
            //Current_Fair_Value__c = oli.RLF_Fair_Value__c,
            RLF_Discount_Premium__c = oli.RLF_Discount_Premium__c,
            //X3PP_Recurring_Costs__c = oli.ThirdParty_Recurring_Costs_PO_Ccy__c,
            X3PP_Currency__c = oli.ThirdParty_PO_Currency__c,
            //Annual_Maintenance_for_NS__c = oli.TotalPrice,
            //RPA_List_Value__c = oli.RPA_Recurring_Value__c,
            Product__c = oli.PriceBookEntry.Product2.Id,
            Vendor_BSch_Trigger__c = oli.PriceBookEntry.Product2.Vendor_BSch_Trigger__c,
           // SD 1515088 - //AM - Requested by Sue as part of FRD 14 phase 2
            X3PP_Asset_Location__c = assetLocation ,
            X3PP_Legacy_Coral_Sales_Ref__c = oppNumber 
            
        );
        return coA;
    } 
    
    private static Double getSumAssetizing(PickableOLI oli, AssetizingBase amount)
    {
        if (amount == AssetizingBase.CONTRACTED) {
            system.debug('getSumAssetizing - oli.SumContracted ' + oli.SumContracted); 
            return oli.SumContracted; 
        }
        else if (amount == AssetizingBase.REMAINING) { 
            system.debug('getSumAssetizing - oli.GetRemainingBefore ' + oli.GetRemainingBefore()); 
            return oli.GetRemainingBefore(); 
        }
        else return 0;
    }

    //AK- added this for 3pp    
    private static Double getSumAssetizing3pp(PickableOLI oli, AssetizingBase amount)
    {
        if (amount == AssetizingBase.CONTRACTED) {
            system.debug('getSumAssetizing - oli.SumContracted3pp ' + oli.SumContracted3pp); 
            return oli.SumContracted3pp; 
        }
        else if (amount == AssetizingBase.REMAINING) { 
            system.debug('getSumAssetizing - oli.GetRemainingBefore3pp ' + oli.GetRemainingBefore3pp()); 
            return oli.GetRemainingBefore3pp(); 
        }
        else return 0;
    }


    //AK- added this for RLF original fair value    
    private static Double getSumContractedRlfOrgFairValue(PickableOLI oli, AssetizingBase amount)
    {
        if (amount == AssetizingBase.CONTRACTED) {
            system.debug('getSumAssetizing - oli.SumContractedRlfFairValue ' + oli.SumContractedRlfFairValue); 
            return oli.SumContractedRlfFairValue; 
        }
        else if (amount == AssetizingBase.REMAINING) { 
            system.debug('getSumAssetizing - oli.GetRemainingBeforeRlfOrgFairValue ' + oli.GetRemainingBeforeRlfOrgFairValue()); 
            return oli.GetRemainingBeforeRlfOrgFairValue(); 
        }
        else return 0;
    }

    //AK- added this for RLF current fair value 
    private static Double getSumContractedRlfCurFairValue(PickableOLI oli, AssetizingBase amount)
    {
        if (amount == AssetizingBase.CONTRACTED) {
            system.debug('getSumAssetizing - oli.SumContractedRlfFairValue ' + oli.SumContractedRlfFairValue); 
            return oli.SumContractedRlfFairValue; 
        }
        else if (amount == AssetizingBase.REMAINING) { 
            system.debug('getSumAssetizing - oli.GetRemainingBeforeRlfCurFairValue ' + oli.GetRemainingBeforeRlfCurFairValue()); 
            return oli.GetRemainingBeforeRlfCurFairValue(); 
        }
        else return 0;
    }

    //AK- added this for RPA list   
    private static Double getSumContractedRpaList(PickableOLI oli, AssetizingBase amount)
    {
        if (amount == AssetizingBase.CONTRACTED) {
            system.debug('getSumAssetizing - oli.SumContractedRpaList ' + oli.SumContractedRpaList); 
            return oli.SumContractedRpaList; 
        }
        else if (amount == AssetizingBase.REMAINING) { 
            system.debug('getSumAssetizing - oli.GetRemainingBeforeRpaList ' + oli.GetRemainingBeforeRpaList()); 
            return oli.GetRemainingBeforeRpaList(); 
        }
        else return 0;
    }

    private static Map<string, Client_Asset__c> queryExistingClientAssets(
        Set<Id> AssetLocations, Set<string> productSetNames, Set<Id> productIds, List<Product_Set__c> productSets)
    {
        Map<string, Client_Asset__c> exClientAssetMap = new Map<string, Client_Asset__c>();
        Client_Asset__c[] existingClientAssets = [
            select Id, Name, Account__c, Product_Set__c, Product_Set__r.Name, Product__c
            from Client_Asset__c
            where Product__c in :productIds
            and Account__c in :AssetLocations
            and Product_Set__r.Name in :productSetNames
            and Product_Set__c in :productSets
        ];
        for (Client_Asset__c exCA : existingClientAssets) {
            exClientAssetMap.put(
                MisysStringUtils.GetClientAssetKey(exCA.Account__c, exCA.Product_Set__r.Name, exCA.Product__c),
                exCA
            );
        }
        return exClientAssetMap;
    }
    
    public static Map<string, Client_Asset__c> createClientAssets(
        Set<string> productSetNames,
        PickableOLI[] OLIs,
        Map<string, Product_Set__c> productSetMap,
        Set<Id> AssetLocations,
        List<Product_Set__c> productSets)
    {
        Set<Id> productIds = new Set<Id>();
        for (PickableOLI oli : OLIs) {
            productIds.add(oli.TheOLI.PriceBookEntry.Product2.Id);
        }
        
        // <account Id>#<product set name>#<oli ID> -> Client Asset
        Map<string, Client_Asset__c> exClientAssetMap = queryExistingClientAssets(
            AssetLocations, productSetNames, productIds, productSets
        );
        Client_Asset__c clA;
        Product_Set__c prodSet;
        string productSetName, assetName, clientAssetKey;
        
        List<Client_Asset__c> clientAssetInsertList = new List<Client_Asset__c>();
        for (Id assetLocationAcctId : AssetLocations) {
            for(PickableOLI oli : OLIs) {
                productSetName = oli.TheOLI.PriceBookEntry.Product2.Product_Set__c;
                assetName = MisysStringUtils.truncate(oli.TheOLI.PriceBookEntry.Product2.Name, 80);
                clientAssetKey =
                    MisysStringUtils.GetClientAssetKey(assetLocationAcctId, productSetName, oli.TheOLI.PriceBookEntry.Product2.Id);
                if (!exClientAssetMap.containsKey(clientAssetKey)) {
                    prodSet = productSetMap.get(MisysStringUtils.GetProductSetKey(assetLocationAcctId, productSetName));
                    clA = new Client_Asset__c(
                        Name = assetName,
                        Account__c = assetLocationAcctId,
                        Product_Set__c = prodSet.Id,
                        Product__c = oli.TheOLI.PriceBookEntry.Product2.Id,
                        CurrencyISOCode = CORPORATE_CURRENCY
                    );
                    exClientAssetMap.put(clientAssetKey, clA);
                    clientAssetInsertList.add(clA);
                }
            }
        }
        insert clientAssetInsertList;
        return exClientAssetMap;
    }
    
}