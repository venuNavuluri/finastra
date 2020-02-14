public with sharing class Market_Opp_SummaryController {

    public Boolean savebutton{get; set;}
    public Boolean editbutton{get; set;}
    public Market_Opp_SummaryController(ApexPages.StandardController controller) {
        recId = ApexPages.currentPage().getParameters().get('Id');
        setup();
        refreshPage = False;
        savebutton = False;
        editbutton = True;
    }

     /*public Market_Opp_SummaryController() {
        recId = ApexPages.currentPage().getParameters().get('Id');
        setup();
        refreshPage = False;
        savebutton = False;
        editbutton = True;
    }*/
    
    public Acct_Profile__c acctpro {get; set;}
    public Id recId {get; set;}
    public Boolean refreshPage {get; set;}
    
    
    public void setup()
    {
        acctpro = [Select Unconstraint_Market_Value_CB__c, Upsell_Value_CB__c, Xsell_Value_CB__c,
                    Suggested_Solution_CB__c, Regional_UpSell_CB__c, Regional_XSell_CB__c,
                    Unconstraint_Market_Value_AM__c, Upsell_Value_AM__c, Xsell_Value_AM__c,
                    Suggested_Solution_AM__c, Regional_UpSell_AM__c, Regional_XSell_AM__c,
                    Unconstraint_Market_Value_DC__c, Upsell_Value_DC__c, Xsell_Value_DC__c,
                    Suggested_Solution_DC__c, Regional_UpSell_DC__c, Regional_XSell_DC__c,
                    Unconstraint_Market_Value_ER__c, Upsell_Value_ER__c, Xsell_Value_ER__c,
                    Suggested_Solution_ER__c, Regional_UpSell_ER__c, Regional_XSell_ER__c,
                    Unconstraint_Market_Value_HF__c, Upsell_Value_HF__c, Xsell_Value_HF__c,
                    Suggested_Solution_HF__c, Regional_UpSell_HF__c, Regional_XSell_HF__c,
                    Unconstraint_Market_Value_CM__c, Upsell_Value_CM__c, Xsell_Value_CM__c,
                    Suggested_Solution_CM__c, Regional_UpSell_CM__c, Regional_XSell_CM__c,
                    Unconstraint_Market_Value_PM__c, Upsell_Value_PM__c, Xsell_Value_PM__c,
                    Suggested_Solution_PM__c, Regional_UpSell_PM__c, Regional_XSell_PM__c,
                    Unconstraint_Market_Value_TF__c, Upsell_Value_TF__c, Xsell_Value_TF__c,
                    Suggested_Solution_TF__c, Regional_UpSell_TF__c, Regional_XSell_TF__c,
                    Unconstraint_Market_Value_Lending__c, Upsell_Value_Lending__c, Xsell_Value_Lending__c,
                    Suggested_Solution_Lending__c, Regional_UpSell_Lending__c, Regional_XSell_Lending__c,
                    Market_opp_CB_commentary__c,Market_opp_CC_commentary__c,Market_opp_DC_commentary__c,Market_opp_ER_commentary__c,Market_opp_IM_commentary__c,Market_opp_LEND_commentary__c,
                    Market_opp_PM_commentary__c,Market_opp_TCM_commentary__c,Market_opp_TF_commentary__c
                    from Acct_Profile__c where Id =:recId];
    }
    
    public pagereference save()
    {
        Update acctpro;
        refreshPage = True;
        savebutton = False;
        editbutton = True;
        return null;
    }
    
    public pagereference cancel()
    {
        refreshPage = False;
        savebutton = False;
        editbutton = True;
        return null;
    }
    
    public pagereference edit()
    {
        refreshPage = False;
        savebutton = True;
        editbutton = False;
        return null;
    }
}