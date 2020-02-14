@isTest
private class Test_MaintenanceSweep {

    static testmethod void test() {

        Account a = testUtils.getAccount('MS Account');
        insert a;
    
        System__c sys = TestUtils.getSystem(a, 'UT sys1');
        insert sys;
        
        Product2 p1 = TestUtils.getProduct('Loan IQ : Legacy Billing Summary');
        
        RF_Index__c ri = new RF_Index__c(name = 'Misys Standard Rate');
        insert ri;
        
         Billing_Entity__c billE = TestAssetUtils.SampleBillingEntity();
        insert billE;
       
        Billing_Group__c billGr = TestAssetUtils.SampleBillingGroup(billE);
        billGr.BG_Client_Contracting_Name__c= a.id;
        insert billGr;
        
        Contract_Asset__c ast1 = TestUtils.getAsset(a, p1, sys);
        ast1.CA_Billing_Status__c='Active billing'; 
        ast1.CA_Recurring_Fees_Earliest_Review_Date__c = Date.newInstance((System.Now().year()+1), 01 , 01);
        ast1.CA_Recurring_Fees_Review_Month__c = 'Jan';
        ast1.CA_Recurring_Fees_Index__c = ri.Id;
        ast1.product__c = p1.Id;
        ast1.CA_Billing_Group__c = billGr.Id;
        insert ast1;
        
       
        
       
        
        Opportunity o = testUtils.getOpportunity(a,'MS Opportunity');
        o.Maintenance_Sweep_Status__c = 'Auto Created';
        insert o;
   
        MS_Limits__c  msLimit = new MS_Limits__c();
        msLimit.Name ='MS Default Limits';
        msLimit.Limit_Accounts_for_Opty_Creation__c =10;
        msLimit.Limit_Accounts_for_Actual_OLI__c =10;
        msLimit.Limit_Accounts_for_Dump_OLI__c =10;
        msLimit.MS_Standard_Amount_Roll_Up__c = 10;
        insert msLimit;
    
        Legacy_Product_Mapping__c lpm= new Legacy_Product_Mapping__c();
        lpm.Current_Product__c='Risk Vision : RLF/Maintenance/Subscription Summary';
        lpm.Legacy_Product__c='RISK IQ : Legacy Billing Summary';
        insert lpm;
        
        MS_Opportunities_Validation_Records__c[] optyPreValidation = [Select Id from MS_Opportunities_Validation_Records__c limit 2];
        System.assert(optyPreValidation.size()==0);
       
        MS_Opportunities_LI_Validation_Record__c[] optyLIPreValidation = [Select Id,Add_to_Standard_Increase_Amount__c from MS_Opportunities_LI_Validation_Record__c limit 2];
        System.assert(optyLIPreValidation.size()==0);

        Test.startTest();
       
         MaintenanceSweep.generateMSweepOpportunities(false);
         MaintenanceSweep.generateMSweepOpportunitiesLineItems(false);
         MaintenanceSweep.generateMSweepOpportunities(true);
         MaintenanceSweep.generateMSweepOpportunitiesLineItems(true);
         MaintenanceSweep.doStandardAmountRollUpForMSOpportunities();
         MaintenanceSweep.setLetterTypeValueonMSOpty();
         MaintenanceSweep.setStringToDateFormat('1/1/2012');
          MaintenanceSweep.identifyDuplicateMSLIs();
       
        Test.stopTest(); 
       
        optyPreValidation = [Select Id from MS_Opportunities_Validation_Records__c limit 2];
        System.assert(optyPreValidation.size()==1);
       
        optyLIPreValidation = [Select Id,Add_to_Standard_Increase_Amount__c from MS_Opportunities_LI_Validation_Record__c limit 2];
        System.assert(optyLIPreValidation.size()==1);
        System.assert(optyLIPreValidation[0].Add_to_Standard_Increase_Amount__c == true);
}
}