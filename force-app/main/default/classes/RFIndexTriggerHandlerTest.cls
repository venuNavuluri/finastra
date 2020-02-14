/**
 * @File Name          : RFIndexTriggerHandlerTest.cls
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 24/07/2019, 11:37:05
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    24/07/2019, 10:59:51   Peter Sabry     Initial Version
**/
@IsTest
public with sharing class RFIndexTriggerHandlerTest {
    private static testmethod void testUpliftFactorCalculationOldModel(){
        RF_Index__c recIndex = new RF_Index__c();
        recIndex.RF_Index_Rate__c = 1.4; 
        insert recIndex;

        RF_Index__c standardIndex = new RF_Index__c();
        standardIndex.Name = 'Standard Index';
        standardIndex.RF_Index_Rate__c = 1; 
        insert standardIndex;
        
        Uplift__c upl = new Uplift__c();
        upl.Uplift_Application_Date__c  = Date.today();
        upl.Hold_Billing__c = false;
        upl.Active__c = true;
        upl.Billing_Type__c = 'Advance';
        upl.Uplift_Advance__c = 61;
        upl.Status__c = 'Pro-Rata';
        upl.Start_Date__c = system.today().toStartOfMonth().addmonths(-3);
        upl.CA_Recurring_Fees_Index_Type__c = 'FIX';
        upl.Billing_Frequency__c = 'Annual';
        upl.Exclude__c = false;
        upl.Uplift_Effective_Date__c = system.today();
        upl.CA_Recurring_Fees_Index__c = standardIndex.Id;
        upl.Base_Index__c = recIndex.Id; 
        insert upl;

        List<Uplift__c> uplifts = [Select Id, uplift_factor__c, Status__c, Start_Date__c, Uplift_Effective_Date__c, Billing_Frequency__c, IUP__c, NCU__c from Uplift__c where Id = :upl.Id];
        uplifts = UpliftProrataHandler.calcualteUpliftFactor(uplifts);
        update uplifts;
        
        test.startTest();
        
        Uplift__c up1 = [select id, uplift_factor__c from Uplift__c limit 1];
        system.assertEquals(1.014000, up1.uplift_factor__c, 'Uplift Factor should be 1.014000');

        recIndex.RF_Index_Rate__c = 1.5;
        update recIndex;

        test.stopTest();

        up1 = [select id, uplift_factor__c from Uplift__c limit 1];
        system.assertEquals(1.015000, up1.uplift_factor__c, 'Uplift Factor should be 1.015000');
    }
    private static testmethod void testUpliftFactorCalculationNewModel(){
        RF_Index__c recIndex = new RF_Index__c();
        recIndex.RF_Index_Rate__c = 1.4; 
        insert recIndex;

        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = new Contract(Uplift_Calc_Type__c = 'Pro-Rata', CPI_Uplift_Type__c='Calendar', Billing_Frequency__c = 'Monthly', AccountId = account.Id, CPI__c = recIndex.Id, ATG_Model__c = true,
                                            Recurring_Fees_Index_Type__c = 'CAP', Hold_CPI_Uplift__c = false, Active__c = true, Uplift_Application_Date__c  = Date.today());
        insert contr;
        
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Uplift_Calc_Type__c = 'Pro-Rata', SO_Generation_Advance__c=60, Varied_Licence__c = true,SBQQ__Contract__c = contr.id, Uplift_Application_Date__c  = Date.today(),
                Transactions__c = 2, Sold_Value__c = 50, SBQQ__NetPrice__c = 100, Exclude__c = false, CPI_Uplift_Review_Date__c = system.today().toStartOfMonth().addmonths(-3), SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', Uplift_Effective_Date__c  = Date.today());
        
        insert sub;

        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id, Uplift_Factor__c, CPI_Uplift_Review_Date__c, Net_Customer_Uplift__c, Interim_Uplift_Percentage__c, SO_Generation_Advance__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c, Uplift_Application_Date__c, SBQQ__Contract__r.CPI_Uplift_Type__c, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c]);
		
        test.startTest();
        
        SBQQ__Subscription__c s1 = [select id, uplift_factor__c from SBQQ__Subscription__c limit 1];
        system.assertEquals(1.014000, s1.uplift_factor__c, 'Uplift Factor should be 1.014000');

        recIndex.RF_Index_Rate__c = 1.5;
        update recIndex;

        test.stopTest();

        s1 = [select id, uplift_factor__c from SBQQ__Subscription__c limit 1];
        system.assertEquals(1.015000, s1.uplift_factor__c, 'Uplift Factor should be 1.015000');
    }
}