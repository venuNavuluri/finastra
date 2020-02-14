@isTest
private class test_rollUpTrigger{
 
     static testmethod void test() {
             Account a = testUtils.getAccount('MS Account');
            insert a;
        
            System__c sys = TestUtils.getSystem(a, 'UT sys1');
            insert sys;
            
            Product2 p1 = TestUtils.getProduct('Loan IQ : Legacy Billing Summary');
            
            Billing_Entity__c be1 = TestAssetUtils.createBillingEntity();
            Billing_Group__c bg1 = TestAssetUtils.createBillingGroup(be1);
           // insert bg1;
                 
            Contract_Asset__c ast1 = TestUtils.getAsset(a, p1, sys);
            ast1.CA_Billing_Status__c='Active billing'; 
            ast1.Annual_Maintenance__c= 20; 
            ast1.CA_Billing_Group__c = bg1.id  ;
       
            ast1.product__c = p1.Id;
            insert ast1;
            
            String currentYear = Label.Current_Billing_Year_for_Annual_Maintenance_History;
            
            //assert the amh value for currentYear is 20
            NS_Annual_Maintenance_History__c amh = [Select id, Annual_Maintenance__c from NS_Annual_Maintenance_History__c where    Contract_Asset__c = :ast1.id and Calendar_Year__c = :currentYear]; 
            System.assertEquals(amh.Annual_Maintenance__c, 20);
            BG_Annual_Maintenance_Summary__c bgAMS = [Select id, BG_Annual_Maintenance_Total__c from BG_Annual_Maintenance_Summary__c where     Billing_Group__c = :bg1.id and Calendar_Year__c = :currentYear];
             System.assertEquals(bgAMS.BG_Annual_Maintenance_Total__c , 20);
            
            ast1.Annual_Maintenance__c= 200; 
            update ast1;
            
            
            //assert the amh value for currentYear is 200
            amh = [Select id, Annual_Maintenance__c from NS_Annual_Maintenance_History__c where    Contract_Asset__c = :ast1.id and Calendar_Year__c = :currentYear];  
            System.assertEquals(amh.Annual_Maintenance__c, 200);
            bgAMS = [Select id, BG_Annual_Maintenance_Total__c from BG_Annual_Maintenance_Summary__c where     Billing_Group__c = :bg1.id and Calendar_Year__c = :currentYear limit 1];
            System.assertEquals(bgAMS.BG_Annual_Maintenance_Total__c , 200);
            
            ast1.Currencyisocode = 'GBP'; 
            update ast1;
           // bgAMS = [Select id, BG_Annual_Maintenance_Total__c from BG_Annual_Maintenance_Summary__c where     Billing_Group__c = :bg1.id and Calendar_Year__c = :currentYear limit 1];
            //System.assertEquals(bgAMS.BG_Annual_Maintenance_Total__c , 200);
            
             
    }
}