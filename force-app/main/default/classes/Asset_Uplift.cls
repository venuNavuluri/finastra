/*  @author Serhii Volynets sergey.volinets@weare4c.com
 * @Jira RBX-119
 * This module provides Asset Uplift Order generation functionality
 * Main methods:
 * execute(set<id> sContractId) - executes Asset Uplift for set of contract ID's
 * createOrders(map<id,List<SBQQ__Subscription__c>>mBgSubs) - creates Asset Uplift orders for specific subscriptions grouped by Billing Groups
 * addILFSalesOrderItem (SBQQ__Subscription__c sub, Integer counter, Sales_Order__c so, ) - creates Asset Uplift order item record for subscription
 */
public class Asset_Uplift {
    /* this class is used to pass return parameters into lightning component
     * @return  lContr- list of modified contracts
     * @return lOrder - list of created orders
     */
    public class AssetUpliftReturn {
        public list < Contract > lContr;
        public list < Sales_Order__c > lOrder;
    }
    /*
     * this method returns the asset size based on Asset Uplift Source
     * @Jira RBX-119
     * @param rec -  FDIC_NCUA_Data__c record
     * @param sSource - the string which represents the asset Uplift Source
     * @return (decimal) - asset size
     * TODO: instead of using hardcoded values, use pick list values
     */
    public static decimal getSize(FDIC_NCUA_Data__c rec, string sSource) {

        if (sSource == 'NCUA Total Assets') {
            return rec.NCUA_Total_Assets__c;
        }
        if (sSource == 'Loans and Leases') {
            return rec.Loans_and_Leases__c;
        }
        if (sSource == 'Loans and Leases minus Family Residentia') {
            return rec.Loans_and_Leases_minus_Family_Residentia__c;
        }
        if (sSource == 'Consumer and Commercial Loans') {
            return rec.Consumer_and_Commercial_Loans__c;
        }
        if (sSource == 'Commercial Loans') {
            return rec.Commercial_Loans__c;
        }
        if (sSource == 'Total Deposits') {
            return rec.Total_Deposits__c;
        }
        if (sSource == 'Member Business Loans') {
            return rec.Member_Business_Loans__c;
        }
        if (sSource == 'Manual') {
            return null; // Manual
        }
        //     if(sSource == 'FDIC Total Assets')
        return rec.Total_Assets__c;
    }
    /*
     * this method executes Asset Uplift order generation for specific contract
     * @Jira RBX-119
     * @param sContractId -  the set of contract id's
     * @return (AssetUpliftReturn) - contract record and order record
     */
    public static AssetUpliftReturn execute(set < id > sContractId) {
        return execute(sContractId, false);
    }
    /*
     * this method executes Asset Uplift order generation for specific contract
     * @Jira RBX-119
     * @param sContractId -  the set of contract id's
     * @param bManual - if it is true, then manual mode of Asset Uplift is executed
     * @return (AssetUpliftReturn) - contract record and order record
     */
    public static AssetUpliftReturn execute(set < id > sContractId, boolean bManual) {
        AssetUpliftReturn ret = new AssetUpliftReturn();
        // query on contracts which require asset uplift
        ret.lContr = [
            Select id, name, Account.FDIC_NCUA_Data__r.Id //SEV: 1563
            , Account.FDIC_NCUA_Data__r.Total_Assets__c, Account.FDIC_NCUA_Data__r.NCUA_Total_Assets__c, Account.FDIC_NCUA_Data__r.Loans_and_Leases__c, Account.FDIC_NCUA_Data__r.Loans_and_Leases_minus_Family_Residentia__c, Account.FDIC_NCUA_Data__r.Consumer_and_Commercial_Loans__c, Account.FDIC_NCUA_Data__r.Commercial_Loans__c, Account.FDIC_NCUA_Data__r.Total_Deposits__c, Account.FDIC_NCUA_Data__r.Member_Business_Loans__c, Account.Name, AccountId, Next_Asset_Uplift_Date__c
            ,Next_CPI_Uplift_Date__c
            ,Asset_Size__c
            ,Asset_Uplift_Source__c
            ,Manual_Asset_Size__c
            ,Manual_Uplift__c
            ,New_Asset_Size__c
            , (Select Id,
                SBQQ__Contract__r.Asset_Size__c,
                SBQQ__Contract__r.Asset_Uplift_Source__c,
                SBQQ__Contract__r.Manual_Asset_Size__c,
                SBQQ__Contract__r.Manual_Uplift__c,
                SBQQ__Contract__r.New_Asset_Size__c,
                Uplift_Multiplier__c,
                RLF_Uplift_Multiplier_Percent__c,
                Billing_Group__c,
                Billing_Method__c,
                Billing_Day__c,
                Billing_Month__c,
                Billing_Group__r.Account_by_Sub__c,
                Billing_Group__r.Account_by_Sub__r.Account__r.NS_Finance_Region__c,
                Billing_Group__r.Account_by_Sub__r.Misys_Entity__c,
                Billing_Group__r.CurrencyIsoCode,
                Billing_Group__r.Original_Contract__r.CustomerSignedDate,
                Billing_Group__r.Original_Opportunity__c,
                Billing_Group__r.Original_Opportunity__r.CloseDate,
                Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode,
                Billing_Group__r.Original_Opportunity__r.StageName,
                Discount_Premium__c,
                Expiry_Date__c,
                Fair_Value__c,
                Initial_Sovos_Code__c,
                Licence_Band__c,
                License_Metric__c,
                Name,
                Next_SO_generation_Date__c,
                SBQQ__BillingType__c,
                SBQQ__NetPrice__c,
                SBQQ__ListPrice__c,
                SBQQ__Product__c,
                SBQQ__Product__r.Name,
                SBQQ__Product__r.NS_Cost_Centre_ID__c,
                SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c,
                SBQQ__Product__r.NS_Product_Dimension_ID__c,
                SBQQ__Product__r.NS_Rev_Rec_Template__c,
                SBQQ__Product__r.NS_Rev_Rec_Template_ID__c,
                SBQQ__Quantity__c,
                SBQQ__StartDate__c,
                Ship_From_Code__c
                 From SBQQ__Subscriptions__r where Asset_Uplift__c = true and SBQQ__Contract__r.Manual_Uplift__c =: bManual and Sales_Order_Type__c = 'ILF'
            )
            From Contract
            where id in: sContractId
            //  and Account.FDIC_NCUA_Data__r.Total_Assets__c <> null
            //  and Assets_Growth__c >0
        ];
        //collecting account's FDIC records these contracts belong to
        map < id, FDIC_NCUA_Data__c > mF = new map < id, FDIC_NCUA_Data__c > ();
        for (contract con: ret.lContr) {
            mF.put(con.AccountId, null); //preparing the keySet of account id
        }
        //quering FDIC records for given account id's
        list < FDIC_NCUA_Data__c > lf = [
            select id,
            Total_Assets__c,
            NCUA_Total_Assets__c,
            Loans_and_Leases__c,
            Loans_and_Leases_minus_Family_Residentia__c,
            Consumer_and_Commercial_Loans__c,
            Commercial_Loans__c,
            Total_Deposits__c,
            Member_Business_Loans__c,
            account__c
            from FDIC_NCUA_Data__c
            order by Year__c desc, Quarter__c desc, Report_Date__c desc
            limit 10000
        ];
        // populating the map of [account id: FDIC record]
        for (FDIC_NCUA_Data__c f: lf) {
            FDIC_NCUA_Data__c f0 = mF.get(f.account__c);
            if (f0 == null) {
                mF.put(f.Account__c, f);
            }
        }

        map < id, decimal > mContrAssetSize = new map < id, decimal > ();
        map < id, Sales_Order__C > mOrder = new map < id, Sales_Order__C > ();
        map < id, SBQQ__Subscription__c > mSubsUpdate = new map < id, SBQQ__Subscription__c > ();
        map < id, list < SBQQ__Subscription__c >> mBgSubs = new map < id, list < SBQQ__Subscription__c >> ();
        list < contract > lupdate = new list < contract > ();
        //Navigate on contracts
        for (Contract contr: ret.lContr) {
            FDIC_NCUA_Data__c fdic; //retrieve the fdic record for specific contract
            if (contr.Account.FDIC_NCUA_Data__r.Id != null) //SEV: 1563
            {
                fdic = contr.Account.FDIC_NCUA_Data__r;
            } else {
                fdic = mF.get(contr.AccountId);
            }
            if (contr.Asset_Size__c == null) {
                throw new CommonFunctions.CustomException('Please populate Asset Size for contract: ' + contr.name);
            }
            decimal dSize;
            //if the uplift is manual, then use Manual_Asset_Size__c as actual asset size
            if (contr.Manual_Uplift__c == true) {
                dSize = contr.Manual_Asset_Size__c;
                if (dSize == null){
                    throw new CommonFunctions.CustomException('Please specify Manual Asset Size for contract: ' + contr.name);
                }
            }
            // if the uplift is automatic, then use FDIC data as a source as actual asset size
            else {
                if (fdic == null) //SEV: 1563 
                {
                    throw new CommonFunctions.CustomException('FDIC record can\'t be found for account ' + contr.Account.Name);
                }
                dSize = getSize(fdic, contr.Asset_Uplift_Source__c);
            }
            
            if (dsize != null) {
                if (contr.Asset_Size__c < dSize) // if there is asset uplift for this subscription then put them into map mBgSubs for futher procedure
                {
                    mContrAssetSize.put(contr.Id, dSize);
                    contr.New_Asset_Size__c = dSize;
                    list < SBQQ__Subscription__c > lSubs = contr.SBQQ__Subscriptions__r;
                    for (SBQQ__Subscription__c subs: lSubs) {
                        id bgid = subs.Billing_Group__c;
                        if (bgid == null) {
                            throw new CommonFunctions.CustomException('Billing Group is not populated for contract: ' + contr.name + ', subscription: ' + subs.name);
                        }
                        list < SBQQ__Subscription__c > lCurSubs = mBgSubs.get(bgid);
                        if (lCurSubs == null) {
                            lCurSubs = new list < SBQQ__Subscription__c > ();
                            mBgSubs.put(bgid, lCurSubs);
                        }
                        lCurSubs.add(subs);
                        mSubsUpdate.put(subs.id, subs);
                    }    
                } 
            }
        }

        //if there are subscription records with asset uplift, then create orders for them
        ret.lOrder = createOrders(mBgSubs, mContrAssetSize);
        update mSubsUpdate.values();
        update ret.lContr;
        
        return ret;
    }


    /*
     * this method creates Asset Uplift orders for specific subscriptions grouped by Billing Groups
     * @Jira RBX-119
     * @param sContractId -  subscriptions grouped by Billing Groups
     * @return list of Sales_Order__c objects
     */
    public static list < Sales_Order__c > createOrders(map < id, List < SBQQ__Subscription__c >> mBgSubs, map < id, decimal > mContrAssetSize) {
        //query for billing groups which have asset uplift subscriptions
        list < Billing_Group__c > lbg = [SELECT
            Id,
            Name,
            Original_Contract__c,
            Account_by_Sub__r.Account__r.NS_Term__c,
            Account_by_Sub__r.Account__r.Credit_Controller__c,
            Original_Opportunity__r.Owner.FirstName,
            Original_Opportunity__r.Owner.LastName,
            Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c,
            Customer_PO_Number__c,
            NS_CUstomer_Address__c,
            NS_Customer_Ship_To_Address__c,
            Original_Customer_Signed_Date__c,
            BG_Contract_Date_migration__c,
            Original_Opportunity__r.Customer_PO__c,
            Original_Opportunity__r.CloseDate,
            Original_Contract__r.Memo__c,
            Original_Contract__r.Asset_Size__c,
            Account_by_Sub__r.Account__r.PO_Required__c,
            Account_by_Sub__r.Invoice_Delivery_Post__c,
            Account_by_Sub__r.Invoice_Delivery_Email__c,
            Original_Opportunity__r.OwnerId,
            Original_Contract__r.StartDate,
            Original_Contract__r.CustomerSignedDate,
            Fixed_Billing_Date__c,
            Reset_Next_Bill_Date__c,
            BG_Next_Invoice_Due_Date__c,
            Set_Tax_Combo_Override__c,
            Order_Sub_Type__c,
            Original_Contract__r.ContractTerm,
            Original_Contract__r.Contract_Expiry_Date__c,
            Next_Billing_Date__c, BG_Client_Contracting_Name__c,
            Original_Opportunity__r.CurrencyIsoCode,
            Account_by_Sub__c,
            Original_Opportunity__c,
            CurrencyIsoCode,
            Current_Sales_Order_Start_Date__c,
            BG_Misys_Billing_Entity__c,
            BG_Client_Bill_To__c,
            BG_Client_Ship_To__c,
            BG_Billing_Group_Active__c,
            Original_Contract_Expiry_Date__c
            FROM
            Billing_Group__c WHERE id =: mBgSubs.keyset()
        ];
        map < string, Billing_Group__c > mbg = new map < string, Billing_Group__c > ();

        for (Billing_Group__c bg: lbg) {
            mbg.put(bg.id, bg);
        }

        Map < String, NS_Currency__c > nsCurrencyMap = SO_SalesOrderMapUtils.getNSCurrency_map();
        map < string, Sales_Order__c > mOrder = new map < string, Sales_Order__c > ();
        List < Sales_Order__c > soList = new List < Sales_Order__c > ();

        //navigate on billing groups
        for (string bgid: mbg.keySet()) {
            Billing_Group__c bg = mbg.get(bgid);

            SBQQ__Subscription__c maxSub = new SBQQ__Subscription__c();
            list < SBQQ__Subscription__c > tempList = mBgSubs.get(bgid);
            if (tempList == null) {
                continue;
            }
            Double tempMax = 0.0;
            //determine subscriptions with the biggest Solv_Value__c as a main subscription (needed for NS)
            for (SBQQ__Subscription__c sub: tempList) {
                if (sub.SBQQ__NetPrice__c >= tempMax) {
                    maxSub = sub;
                    tempMax = sub.SBQQ__NetPrice__c;
                }
            }
            Sales_Order__c ord = new sales_Order__c();
            ord.Billing_Group__c = bg.Id;
            ord.Opportunity__c = bg.Original_Opportunity__c;
            ord.Contract__c = bg.Original_Contract__c;
            ord.order_type__c = 'ILF';
            ord.NS_Form_Id__c = '126';
            ord.CPQ_Billing__c = true;
            ord.Asset_Uplift_Flag__c = true;
            ord.Bill_To_Customer__c = bg.Account_by_Sub__c;
            ord.Memo__c = 'Lending Uplift Fee';
            ord.Document_Memo__c = 'Lending Uplift Fee';
            ord.Main_Product__c = maxsub.SBQQ__Product__c;
            ord.NS_Currency__c = nsCurrencyMap.get(bg.CurrencyIsoCode).Id;
            ord.NS_Cost_Centre_Internal_Id__c = maxsub.SBQQ__Product__r.NS_Cost_Centre_ID__c;
            ord.NS_Product_Analysis_Internal_Id__c = maxsub.SBQQ__Product__r.NS_Product_Dimension_ID__c;
            ord.NS_Deferred_Rev_Rec_Acc_Internal_Id__c = maxsub.SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c;
            ord.Order_Status__c = 'Pending Approval';
            ord.NS_Term__c = bg.Account_by_Sub__r.Account__r.NS_Term__c;
            ord.SO_Credit_Controller__c = bg.Account_by_Sub__r.Account__r.Credit_Controller__c;
            ord.Invoice_Credit_Body__c = 'ILF';
            ord.Order_Start_Date__c = bg.Original_Contract__r.StartDate;
            ord.Order_End_Date__c = bg.Original_Contract__r.StartDate;
            ord.NS_Contract_Date__c = bg.Original_Contract__r.StartDate;
            if(mContrAssetSize.containsKey(bg.Original_Contract__c)) {
            	ord.Asset_Size_Difference__c = mContrAssetSize.get(bg.Original_Contract__c) - bg.Original_Contract__r.Asset_Size__c;
            }
            mOrder.put(bgid, ord);
        }
        
        Savepoint sp = Database.setSavepoint();
        try {
            insert mOrder.values(); //insert sales orders

            map < String, NS_Revenue_Recognition_Template__c > revRecScheduleMap = SO_SalesOrderMapUtils.getRevScheduleMap();
            List < Sales_Order_Item__c > itemsList = new List < Sales_Order_Item__c > ();
            //navigate on billing groups       
            for (string bgid: mbg.keySet()) {
                list < SBQQ__Subscription__c > tempList = mBgSubs.get(bgid);
                if (tempList == null) {
                    continue;
                }
                Sales_Order__c order = mOrder.get(bgid);

                // SO Items creation
                Sales_Order_Item__c soiItem = null;
                Integer i = 1;
                //navigate on billing group's subscriptions
                for (SBQQ__Subscription__c sub: tempList) {
                    //add sales order items for each subscription
                    soiItem = addILFSalesOrderItem(sub, i, order, revRecScheduleMap, mContrAssetSize);
                    itemsList.add(soiItem);
                    i++;
                }
            }
            if (itemsList.size() > 0) {
                insert itemsList; // insert sales order items
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            System.debug('Exception thrown in Asset_Uplift class :' + ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' + ex.getStackTraceString());
            Throw ex;
        }
        return mOrder.values();
    }
    /*
     * this method creates Asset Uplift order item record
     * @Jira RBX-119
     * @param sub -  SBQQ__Subscription__c record
     * @param counter - integer counter of order items
     * @param so - parent Sales Order record
     * @param revScheduleMap - map of NS_Revenue_Recognition_Template__c records
     * @param nsCurrencyMap - map of NS_Currency__c records
     * @return Sales_Order_Item__c record
     */
    public static Sales_Order_Item__c addILFSalesOrderItem
        (
            SBQQ__Subscription__c sub,
            Integer counter,
            Sales_Order__c so,
            Map < String, NS_Revenue_Recognition_Template__c > revScheduleMap,
            map < id, decimal > mContrAssetSize
        ) {
            Sales_Order_Item__c soi = new Sales_Order_Item__c();
            soi.Line__c = counter;
            soi.sales_order__c = so.Id;
            soi.Subscription__c = sub.id;
            soi.Name = sub.SBQQ__Product__r.Name;
            soi.NS_Item__c = sub.SBQQ__Product__c;
            soi.Ship_From_Code__c = sub.Ship_From_Code__c;
            soi.Tax_Code__c = sub.Initial_Sovos_Code__c;
            soi.Software_Delivered__c = true;
            soi.Quantity__c = sub.SBQQ__Quantity__c;
            soi.Subscription__c = sub.id;
            if(mContrAssetSize.containsKey(sub.SBQQ__Contract__c)) {
                Decimal newAssetSize = mContrAssetSize.get(sub.SBQQ__Contract__c);
                Decimal upliftAmount = (newAssetSize - sub.SBQQ__Contract__r.Asset_Size__c) * sub.Uplift_Multiplier__c;
                if (sub.SBQQ__Quantity__c != null && sub.SBQQ__Quantity__c > 0) {
                    soi.Rate__c = (upliftAmount / sub.SBQQ__Quantity__c).setScale(4);
                }
                soi.Amount__c = upliftAmount;
                soi.List_Value__c = upliftAmount;
            }
            soi.Rev_Rec_Start_Date__c = so.Order_Start_Date__c;
            soi.Rev_Rec_End_Date__c = so.Order_End_Date__c;
            soi.Planned_Recurring_Billing_Start_Date__c = so.Order_Start_Date__c;
            soi.NS_Rev_Rec_Schedule_Internal_Id__c = sub.SBQQ__Product__r.NS_Rev_Rec_Template_ID__c;
            soi.License_Metric__c = sub.License_Metric__c;
            soi.CurrencyIsoCode = sub.Billing_Group__r.CurrencyIsoCode;
            soi.Description__c = soi.Name;
            soi.Licence_Basis__c = sub.Licence_Band__c;
            if (sub.SBQQ__Product__r.NS_Rev_Rec_Template_ID__c != null && revScheduleMap.get(sub.SBQQ__Product__r.NS_Rev_Rec_Template_ID__c) != null) {
                soi.Rev_Rec_Schedule__c = revScheduleMap.get(sub.SBQQ__Product__r.NS_Rev_Rec_Template_ID__c).Id;
            }
            return soi;
        }
}