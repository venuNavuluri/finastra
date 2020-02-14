public class IntLogRecord_OLI extends IntLogRecord
{
    /* IProposalItem implementation */
    override public string getProcessingType() { return theRecord.GenString11__c; }
    override public integer getProposalIDNum() { return (integer)theRecord.NumField30__c; }

    /* IntLogRecord implementation*/
//  override public SObject createSObject() { return createOLI(); }
    override public ProposalLineItem createPLI()    { 
		OpportunityLineItem oppLineItem = createOLI();
    	return new ProposalLineItem_OLI(oppLineItem);
    }
    override public boolean hasValidPriceBookEntryId()
    {
        //Check that the PBE Id in the IL is non-null and a valid SFDC Id
        boolean validPBEId = true;
        if(theRecord.GenString2__c == null){
            validPBEId = false;
        }else{
            try{
                Id pbeId = theRecord.GenString2__c;
            }catch(Exception pbe){
                validPBEId = false;
            }
        }
        return validPBEId;
    }
    override public Id getPBEid() { return theRecord.GenString2__c; }
    override public string getCurrencyCode() { return theRecord.GenString3__c; }
    
    public IntLogRecord_OLI(Integration_Log__c il)
    {
        super(il);
    }

    
    public OpportunityLineItem createOLI()
    {
        Integration_Log__c intLog = theRecord;
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = intLog.SFDC_Id__c;
        oli.PPOPPLINE_Concat__c = intLog.GenString1__c;
        oli.PricebookEntryId = getPBEid();
        oli.Licence_Band__c = intLog.GenString6__c;
        oli.Location__c = intLog.GenString7__c;
        oli.License_Metric__c = intLog.GenString8__c;
        oli.ProductSet_Process_Type__c = intLog.GenString10__c;
        oli.LineItem_Process_Type__c = intLog.GenString11__c;
        oli.Asset_Name__c = intLog.GenString12__c;
        oli.ThirdParty_PO_Currency__c = intLog.GenString13__c;
        oli.LineItem_Type__c = intLog.GenString14__c;
        oli.Fair_Value_Adjustment_Item__c = (intLog.GenString14__c == 'C');
        oli.Pricing_Scheme__c = intLog.GenString15__c;
        if (intLog.GenString16__c != null) {
            if (intLog.GenString16__c.toUpperCase() == 'Y') { oli.Pearl_Item__c = true; }
            else if (intLog.GenString16__c.toUpperCase() == 'N') { oli.Pearl_Item__c = false; }
        }
        oli.NS_Order_Form_Type__c = intLog.GenString17__c;
        oli.Product_Release__c = intLog.GenString19__c;
        
        oli.UnitPrice = intLog.NumField1__c;        //ILF Fair Value
        oli.Fair_Value__c = intLog.NumField2__c; 
        oli.Proposed_RLF__c = intLog.NumField3__c;
        oli.Annual_Maintenance__c = intLog.NumField3__c;  //RLF Fair Value
        oli.RLF_Fair_Value__c = intLog.NumField4__c;
        oli.Comm_Man_Price__c = intLog.NumField5__c;
        oli.Discount_Premium__c = intLog.NumField6__c;
        oli.RLF_Discount_Premium__c = intLog.NumField7__c;
        oli.Standard_RLF__c = intLog.NumField8__c;
        oli.ILF_Fair_Value__c = intLog.NumField9__c;
        oli.Sold_Value__c = intLog.NumField10__c;
        oli.RPA_Value__c = intLog.NumField11__c;
        oli.RPA_Recurring_Value__c = intLog.NumField12__c;
        oli.Internal_Costs__c = intLog.NumField13__c;
        oli.ThirdParty_Costs_Sold_Ccy__c = intLog.NumField14__c;
        oli.ThirdParty_Recurring_Costs_Sold_Ccy__c = intLog.NumField15__c;
        oli.ThirdParty_Costs_PO_Ccy__c = intLog.NumField16__c;
        oli.ThirdParty_Recurring_Costs_PO_Ccy__c = intLog.NumField17__c;
        oli.Licence_Band_Incremented__c = intLog.NumField18__c;
        oli.RF_Waiver_Months__c = intLog.NumField19__c;
        oli.Unrecoverable_Costs__c = intLog.NumField20__c;
        oli.Sold_Per_Diem_Value__c = intLog.NumField21__c;
        oli.List_Per_Diem_Value__c = intLog.NumField22__c;
        oli.Travel_Hours_Total__c = intLog.NumField23__c;
        oli.NonBillable_Hours_Total__c = intLog.NumField24__c;
        oli.Contractor_Hours_Total__c = intLog.NumField25__c;
        oli.ThirdParty_Contractor_Cost_Sold_Ccy__c = intLog.NumField26__c;
        oli.Reimbursable_Costs_Estimate__c = intLog.NumField27__c;
        oli.Reimbursable_Costs_Recovery_Value__c = intLog.NumField28__c;
        oli.NS_Deferred_Revenue_Acct_ID__c = intLog.NumField29__c;
        oli.Pearl_ProposalNo__c = (Integer)intLog.NumField30__c;
        oli.GA__c = ConversionUtils.NumFieldToBool(intLog.NumField31__c);
        oli.Quantity = (intLog.NumField32__c == null || intLog.NumField32__c == 0 ? 1 : intLog.NumField32__c);
        oli.Fair_Value_Adjustment__c = intLog.NumField33__c;
        oli.Total_Chargeable_Hours__c = intLog.NumField34__c;
        oli.Integration_Version__c = '4.0';
        if(intLog.NumField36__c != null){
        	oli.NS_Item_Cost_Centre_Override_Internal_Id__c = intLog.NumField36__c.intValue().format();
        }
        if(intLog.NumField37__c != null){
        	oli.Commissionable_Value__c = intLog.NumField37__c;
        }
        return oli;
    }

}