@isTest(seeAllData=true)
private class test_OpportunityLineItemServices {

    public static testmethod void test_PreventDeletePearlOLI()
    {
        //Set up test data
        //
        
        //Add a public group
        //Group testGroup = TestUtility.samplePublicGroup();
        //insert testGroup;
        
        //Set the label to the new group id
        //Label.OppLineItemEditGroup = testGroup.Id;
        
        //Get the public group members
        //  --->>>  Need to write this so it is not dependent on system data
        
        User testUser = TestUtility.sampleUser();
        insert testUser;
        
        Opportunity opp = TestUtility.sampleOpportunity();
        opp.ownerId = testUser.Id;
        opp.CurrencyIsoCode='USD';
        insert opp;
        
        OpportunityLineItem oli1 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli1.Pearl_Item__c = true;
        insert oli1;
        
        OpportunityLineItem oli2 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli1.Pearl_Item__c = false;
        insert oli2;
        
        String result1 = null;
        String result2 = null;
        
        //Run the test
        Test.startTest();
            System.runAs(testUser)
            {
                system.debug('Start test: test_PreventDeletePearlOLI');
                try{
                    delete oli1;
                }catch(Exception e1){
                    system.debug('Delete Pearl item result:'+e1);
                    result1 = e1.getTypeName() + ' - ' + e1.getCause() + ': ' + e1.getMessage();
                    //Exception should look similar to:  System.DmlException: Delete failed. First exception on row 0 with id 00kW0000003JaYZIA0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Cannot delete line item - Items added by the Pearl interface cannot be edited or deleted.  The item should be updated in Pearl as needed.: []
                }
                try{
                    delete oli2;
                }catch(Exception e2){
                    system.debug('Delete non-Pearl item result:'+e2);
                    result2 = e2.getTypeName() + ' - ' + e2.getCause() + ': ' + e2.getMessage();
                }
                system.debug('End test: test_PreventDeletePearlOLI');
            }
        Test.stopTest();
        
        //Verify the results
        //system.assert(result1.contains('Delete failed'));
        system.assertEquals(null,result2);
    }

    public static testmethod void test_IsBGProcessedOBS()
    {
        User testUser = TestUtility.sampleUser();
        insert testUser;
        
        Opportunity opp = TestUtility.sampleOpportunity();
        opp.ownerId = testUser.Id;
        opp.CurrencyIsoCode='USD';
        insert opp;

        Opportunity_Billing_Schedule__c obs = new Opportunity_Billing_Schedule__c(Opportunity__c = opp.Id, Processing_Type__c = 'RLF');
        insert obs;
        
        OpportunityLineItem oli1 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli1.Pearl_Item__c = true;
        oli1.IsRLFAssetised__c = true;
        oli1.Opportunity_Billing_Schedule__c = obs.Id;
        
        insert oli1;
        
        OpportunityLineItem oli2 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli2.Pearl_Item__c = false;
        oli2.IsRLFAssetised__c = true;
        oli2.Opportunity_Billing_Schedule__c = obs.Id;
        
        insert oli2;
        
        String result1 = null;
        String result2 = null;
        
        //Run the test
        Test.startTest();
        list<OpportunityLineItem> updateOlis = new list<OpportunityLineItem>();
        System.runAs(testUser)
        {
            oli1.IsBGLlinked__c = true;
            oli2.IsBGLlinked__c = true;
            updateOlis.add(oli1);
            updateOlis.add(oli2);
            
            update updateOlis;
        }
        Test.stopTest();
        
    }
    


    public static testMethod void shouldGetOppsWithRolledUpCommValues(){

        User testUser = TestUtility.sampleUser();
        insert testUser;
        List<OpportunityLineItem> oppListToInsert = new List<OpportunityLineItem>();
        
       
        
        Opportunity opp = TestUtility.sampleOpportunity();
   
      
        opp.ownerId = testUser.Id;
        opp.CurrencyIsoCode='USD';
        opp.Rollup_Calculate_Batch_Hold__c = true;
        insert opp;

        


       // opp.Term_Estimate_Months__c = 65;
      //  update opp;
        
       // opp.Term_Estimate_Months__c = 50;
        //update opp;
    
        OpportunityLineItem oli1 = TestUtility.sampleOpportunityLineItem1(opp, 'CLD (TB)');
        oli1.Pearl_Item__c = true;
        oli1.Commissionable_Value__c = 2;
        oli1.Sold_Value__c = 4;
        oppListToInsert.add(oli1);

        OpportunityLineItem oli2 = TestUtility.sampleOpportunityLineItem1(opp, 'SUB (CB)');
        oli2.Pearl_Item__c = true;
        oli2.Commissionable_Value__c = 0;
        oli2.Sold_Value__c = 4;
        oppListToInsert.add(oli2);

        OpportunityLineItem oli3 = TestUtility.sampleOpportunityLineItem1(opp, 'HOS (CB)');
        oli3.Pearl_Item__c = true;
        oli3.Commissionable_Value__c = 0;
        oli3.Sold_Value__c = 14;
        oppListToInsert.add(oli3);

        OpportunityLineItem oli4 = TestUtility.sampleOpportunityLineItem1(opp, 'HOS (TB)');
        oli4.Pearl_Item__c = true;
        oli4.Commissionable_Value__c = 2;
        oli4.Sold_Value__c = 4;
        oppListToInsert.add(oli4);

        OpportunityLineItem oli5 = TestUtility.sampleOpportunityLineItem1(opp, 'HOS (IM)');
        oli5.Pearl_Item__c = true;
        oli5.Commissionable_Value__c = 2;
        oli5.Sold_Value__c = 4;
        oppListToInsert.add(oli5);

        OpportunityLineItem oli6 = TestUtility.sampleOpportunityLineItem1(opp, 'CLD (CB)');
        oli6.Pearl_Item__c = true;
        oli6.Commissionable_Value__c = 2;
        oli6.Sold_Value__c = 2.2;
        oppListToInsert.add(oli6);
    
        OpportunityLineItem oli7 = TestUtility.sampleOpportunityLineItem1(opp, 'CLD (CL)');
        oli7.Pearl_Item__c = true;
        oli7.Commissionable_Value__c = 0;
        oli7.Sold_Value__c = 2.2;
        oppListToInsert.add(oli7);
    
        OpportunityLineItem oli8 = TestUtility.sampleOpportunityLineItem1(opp, 'CLD (CM)');
        oli8.Pearl_Item__c = true;
        oli8.Commissionable_Value__c = 0;
        oli8.Sold_Value__c = 2.2;
        oppListToInsert.add(oli8);
    
        Test.StartTest();
        insert oppListToInsert;
        Test.StopTest();
        
        Opportunity resultOpp = [select id,RSF_HOS_TB_CommValue__c,RSF_SUB_CB_CommValue__c,RSF_CLD_TB_CommValue__c,RSF_HOS_CB_CommValue__c,
                                 RSF_HOS_IM_CommValue__c,RSF_CLD_CB_CommValue__c,RSF_CLD_CL_CommValue__c,RSF_CLD_CM_CommValue__c
                                 from opportunity where id = :opp.Id];
    
      system.assertEquals(resultOpp.RSF_HOS_TB_CommValue__c,oli4.Commissionable_Value__c);
        system.assertEquals(resultOpp.RSF_SUB_CB_CommValue__c,oli2.TotalPrice *1);
        system.assertEquals(resultOpp.RSF_CLD_TB_CommValue__c,oli1.Commissionable_Value__c);
        system.assertEquals(resultOpp.RSF_HOS_CB_CommValue__c,oli3.TotalPrice * 1);
        system.assertEquals(resultOpp.RSF_HOS_IM_CommValue__c,oli5.Commissionable_Value__c);
        system.assertEquals(resultOpp.RSF_CLD_CB_CommValue__c,oli6.Commissionable_Value__c);
        system.assertEquals(resultOpp.RSF_CLD_CL_CommValue__c,oli7.TotalPrice * 1);
        system.assertEquals(resultOpp.RSF_CLD_CM_CommValue__c,oli8.TotalPrice * 1);
        
        opp.Term_Estimate_Months__c = 50;
        update opp;

        OpportunityLineItem oli = [Select Id,OpportunityId,Custom_Commision_Value__c,TotalPrice from OpportunityLineItem where Id=:oli3.id];
        system.assertEquals(oli.Custom_Commision_Value__c,oli.TotalPrice * 2);

        Opportunity opp1 = [Select Id,RSF_HOS_CB_CommValue__c from Opportunity where Id=:oli.OpportunityId];
       // system.assertEquals(opp1.RSF_HOS_CB_CommValue__c,oli.TotalPrice * 2);
       

    }
    
 
    
   
}