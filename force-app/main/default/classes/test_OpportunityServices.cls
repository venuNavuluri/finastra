@isTest
class test_OpportunityServices 
{
    /*
    static testMethod void testRecordTypesNameMap()
    {
        Map<String, RecordType> recordTypesNameMap = OpportunityServices.recordTypesNameMap;
         for(RecordType rt: [Select Id, Name from RecordType where sObjectType = 'Opportunity' ])
             System.assertEquals(true, recordTypesNameMap.containsKey(rt.Name));
    }
    */
    
    /*
    static testMethod void testCopyChangeOrderOLIsToParentOppty()
    {
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        Contract cntr = TestUtils.getContract(a);
        insert cntr;
        Opportunity parentOppty = TestUtils.getOpportunity(a, 'parent UT 1');
        parentOppty.Legal_Review__c = '';
        insert parentOppty;
        Opportunity childOppty = TestUtils.getOpportunity(a, 'chlid UT1');
        childOppty.RecordTypeId = OpportunityServices.recordTypesNameMap.get(Constants.OPPORTUNITY_RECORD_TYPE_CHANGE_ORDER).id;
        childOppty.Original_Opportunity__c = parentOppty.id;
        childOppty.Contract__c = cntr.id;
        insert childOppty;
        OpportunityLineItem oli1 = TestUtils.getOLI(childOppty);
        insert oli1;
        OpportunityLineItem oli2 = TestUtils.getOLI(childOppty);
        insert oli2;
        System.assertEquals(0, [Select count() from OpportunityLineItem where OpportunityID =: parentOppty.id]);
        System.assertEquals(2, [Select count() from OpportunityLineItem where OpportunityID =: childOppty.id]);
        
        Test.startTest();
        childOppty.Finance_Review__c = Constants.FINANCE_REVIEW_APPROVED;
        OpportunityServices.isOpportunityTriggerRunning = false;
        update childOppty;
        Test.stopTest();
        
        System.assertEquals(2, [Select count() from OpportunityLineItem where OpportunityID =: parentOppty.id]);
        
    }
    */
    
    static testMethod void testCreateProjectFromOpportunity()
    {
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        //Opportunity oppty1 = TestUtils.getOpportunity(a, 'UT - oppty1');
        Opportunity oppty1 = TestUtility.sampleOpportunity(a);
        oppty1.name = 'UT - oppty1';
        insert oppty1;
        System.assertEquals(0, [Select id from Project__c where Account__c =: a.id and Opportunity__c =: oppty1.id].size());
        
        oppty1.SF_Project_Already_Created__c = true;
        update oppty1;
        oppty1.Pushed_to_OpenAir__c = true;
        oppty1.PS_Review__c = 'Approved';
        oppty1.StageName = '7. Committed';
        oppty1.Project_Template__c = '12345';
		oppty1.Is_PearlMastered__c = true;
        update oppty1;
        System.assertEquals(0, [Select id from Project__c where Account__c =: a.id and Opportunity__c =: oppty1.id].size());
        
        oppty1.Pushed_To_OpenAir__c = false;
        update oppty1;
        oppty1.SF_Project_Already_Created__c = false;
        update oppty1;
        oppty1.Pushed_to_OpenAir__c = true;
        update oppty1;
        System.assertEquals(1, [Select id from Project__c where Account__c =: a.id and Opportunity__c =: oppty1.id].size());  
    }
    
    /*
    static testMethod void testApproveOpptyForAssetCreation_Without_Quote_Group()
    {
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        
        Entitlement ent1 = new Entitlement();
        ent1.Name = 'ent 1';
        ent1.AccountID = a.id;
        ent1.StartDate = Date.Today();
        ent1.EndDate = Date.Today().addYears(2);
        insert ent1;
        
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_IN_REVIEW;
        oppty.RecordTypeID = OpportunityServices.recordTypesNameMap.get(Constants.OPPORTUNITY_RECORD_TYPE_STANDARD).id;
        oppty.Contract__c = ctrct.id;
        insert oppty;
        Product2 p1 = TestUtils.getProduct('ut prod1');
        insert p1;
        OpportunityLineItem oli1 = TestUtils.getOLI(oppty, p1);
        insert oli1;
               
        OpportunityServices.isOpportunityTriggerRunning = false;
        //asset creation should not be allowed becuase no quote groups are defined on OLIs
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_APPROVED;
        try
        {
        	update oppty;
        	System.assert(false);
        }
        catch(DMLException dmle)
        {
        	System.assert(dmle.getMessage().contains('Quote Group is required on all Opportunity Products for Asset/System creation'));
        }
        
        //verify that no assets exist under the Account
        System.assertEquals([Select count() from Troy_Asset__c where Account__c =: a.id], 0);
  
    }
    */
    
    /*
    static testMethod void testApproveOpptyForAssetCreation_NetNewProducts_Multiple_Entitlements_On_Account()
    {
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        //2 - multiple entitlements exist on Account
        Entitlement ent1 = new Entitlement();
        ent1.Name = 'ent 1';
        ent1.AccountID = a.id;
        ent1.StartDate = Date.Today();
        ent1.EndDate = Date.Today().addYears(2);
        insert ent1;
        
        Entitlement ent2 = new Entitlement();
        ent2.Name = 'ent 2';
        ent2.AccountID = a.id;
        ent2.StartDate = Date.Today();
        ent2.EndDate = Date.Today().addYears(2);
        insert ent2;
        
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_IN_REVIEW;
        oppty.RecordTypeID = OpportunityServices.recordTypesNameMap.get(Constants.OPPORTUNITY_RECORD_TYPE_STANDARD).id;
        oppty.Contract__c = ctrct.id;
        insert oppty;
        Quote_Group__c qp = TestUtils.getQuoteGroup(oppty);
        insert qp;
        Product2 p1 = TestUtils.getProduct('ut prod1');
        insert p1;
        OpportunityLineItem oli1 = TestUtils.getOLI(oppty, p1);
        oli1.Quote_Group__c = qp.id;
        insert oli1;
               
        OpportunityServices.isOpportunityTriggerRunning = false;
        //asset creation should not be allowed 
        try
        {
            oppty.Finance_Review__c = Constants.FINANCE_REVIEW_APPROVED;
            update oppty;
            System.assert(false);
        }
        catch(DMLException dmle)
        {
            System.assert(dmle.getMessage().contains('Account has multiple active entitlements. Please select an appropriate entitlement on Opportunity'));
        }   
    }
    */
    
    /*
    static testMethod void testApproveOpptyForAssetCreation_NetNewProducts_Multiple_Entitlements_On_Account_Inactive_Selected_On_Opportunity()
    {
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        //2 - multiple entitlements exist on Account but inactive is selected on Opportunity
        Entitlement ent1 = new Entitlement();
        ent1.Name = 'ent 1';
        ent1.AccountID = a.id;
        ent1.StartDate = Date.Today();
        ent1.EndDate = Date.Today().addYears(2);
        insert ent1;
        
        Entitlement ent2 = new Entitlement();
        ent2.Name = 'ent 2';
        ent2.AccountID = a.id;
        ent2.StartDate = Date.Today().addYears(-2);
        ent2.EndDate = Date.Today().addYears(-1);
        insert ent2;
        
        Entitlement ent3 = new Entitlement();
        ent3.Name = 'ent 3';
        ent3.AccountID = a.id;
        ent3.StartDate = Date.Today();
        ent3.EndDate = Date.Today().addYears(2);
        insert ent3;
        
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_IN_REVIEW;
        oppty.RecordTypeID = OpportunityServices.recordTypesNameMap.get(Constants.OPPORTUNITY_RECORD_TYPE_STANDARD).id;
        oppty.Contract__c = ctrct.id;
        oppty.Entitlement__c = ent2.id;
        insert oppty;
        Quote_Group__c qp = TestUtils.getQuoteGroup(oppty);
        insert qp;
        Product2 p1 = TestUtils.getProduct('ut prod1');
        insert p1;
        OpportunityLineItem oli1 = TestUtils.getOLI(oppty, p1);
        oli1.Quote_Group__c = qp.id;
        insert oli1;
        
        OpportunityServices.isOpportunityTriggerRunning = false;
        try
        {
            oppty.Finance_Review__c = Constants.FINANCE_REVIEW_APPROVED;
            update oppty;
            System.assert(false);
        }
        catch(DMLException dmle)
        {
            System.assert( dmle.getMessage().contains('An inactive entitlement is chosen on Opportunity. Please select an appropriate entitlement on Opportunity'));
        }
    }
    */
    
    /*
    static testMethod void testApproveOpptyForAssetCreation_NetNewProducts_No_Entitlements_OR_Systems_Exist_On_Account()
    {
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_IN_REVIEW;
        oppty.RecordTypeID = OpportunityServices.recordTypesNameMap.get(Constants.OPPORTUNITY_RECORD_TYPE_STANDARD).id;
        oppty.Contract__c = ctrct.id;
        insert oppty;
        Quote_Group__c qp = TestUtils.getQuoteGroup(oppty);
        insert qp;
        Product2 p1 = TestUtils.getProduct('ut prod1');
        insert p1;
        OpportunityLineItem oli1 = TestUtils.getOLI(oppty, p1);
        oli1.Quote_Group__c = qp.id;
        insert oli1;
        Product2 p2 = TestUtils.getProduct('ut prod2');
        insert p2;
        OpportunityLineItem oli2 = TestUtils.getOLI(oppty, p2);
        oli2.Quote_Group__c = qp.id;
        insert oli2;
        Set<ID> productIDs = new Set<ID>();
        productIDs.add(p1.id);
        productIDs.add(p2.id);
        
        OpportunityServices.isOpportunityTriggerRunning = false;
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_APPROVED;
        update oppty;
        
        List<System__c> createdSystems = [Select ID from System__c where Account__c =: a.id];
        System.assertEquals(1, createdSystems.size());
        
        List<Troy_Asset__c> createdAssets = [Select ID, Product__c, System__c from Troy_Asset__c where Account__c =: a.id];
        System.assertEquals(2, createdAssets.size());
        System.assertEquals(true, productIDs.contains(createdAssets[0].Product__c));
        System.assertEquals(true, productIDs.contains(createdAssets[1].Product__c));       
        
    }
    */
    
    /*
    static testMethod void testApproveOpptyForAssetCreation_NetNewProducts_Systems_And_Entitlements_Exist_On_Account()
    {
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        Entitlement ent = TestUtils.getEntitlement(a);
        ent.StartDate = Date.Today();
        ent.endDate = Date.Today().addDays(20);
        insert ent;
        System__c sys = TestUtils.getSystem(a, ent, 'UT sys1');
        insert sys;
        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_IN_REVIEW;
        oppty.RecordTypeID = OpportunityServices.recordTypesNameMap.get(Constants.OPPORTUNITY_RECORD_TYPE_STANDARD).id;
        oppty.Contract__c = ctrct.id;
        insert oppty;
        Quote_Group__c qp = TestUtils.getQuoteGroup(oppty);
        qp.System__c = sys.id;
        insert qp;
        Product2 p1 = TestUtils.getProduct('ut prod1');
        insert p1;
        OpportunityLineItem oli1 = TestUtils.getOLI(oppty, p1);
        oli1.Quote_Group__c = qp.id;
        insert oli1;
        Product2 p2 = TestUtils.getProduct('ut prod2');
        insert p2;
        OpportunityLineItem oli2 = TestUtils.getOLI(oppty, p2);
        oli2.Quote_Group__c = qp.id;
        insert oli2;
        Set<ID> productIDs = new Set<ID>();
        productIDs.add(p1.id);
        productIDs.add(p2.id);
        
        OpportunityServices.isOpportunityTriggerRunning = false;
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_APPROVED;
        update oppty;
        
        List<Troy_Asset__c> createdAssets = [Select ID, Product__c, System__c from Troy_Asset__c where Account__c =: a.id];
        System.assertEquals(2, createdAssets.size());
        System.assertEquals(true, productIDs.contains(createdAssets[0].Product__c));
        System.assertEquals(sys.id, createdAssets[0].System__c);
        System.assertEquals(true, productIDs.contains(createdAssets[1].Product__c));
        System.assertEquals(sys.id, createdAssets[1].System__c);
          
    }
    */
    
    /*
    static testMethod void testApproveOpptyForAssetCreation_NetNewProducts_Child_Quote_Systems_Exists_Under_Parent_Quote_System()
    {
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        Entitlement ent = TestUtils.getEntitlement(a);
        ent.StartDate = Date.Today();
        ent.endDate = Date.Today().addDays(20);
        insert ent;
        System__c sys1 = TestUtils.getSystem(a, ent, 'UT sys1');
        insert sys1;
        System__c sys2 = TestUtils.getSystem(a, ent, 'UT sys2');
        insert sys2;
        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_IN_REVIEW;
        oppty.RecordTypeID = OpportunityServices.recordTypesNameMap.get(Constants.OPPORTUNITY_RECORD_TYPE_STANDARD).id;
        oppty.Order_Type__c = Constants.ORDER_TYPE_NEW_PRODUCT ;
        oppty.Contract__c = ctrct.id;
        insert oppty;
        Quote_Group__c parentQG = TestUtils.getQuoteGroup(oppty);
        parentQG.System__c = sys1.id;
        insert parentQG;
        Quote_Group__c childQG = TestUtils.getQuoteGroup(oppty);
        childQG.Concurrent_Users__c = 20;
        childQG.System__c = sys2.id;
        insert childQG;
        Product2 p1 = TestUtils.getProduct('ut prod1');
        p1.Asset_Created_for_Product__c = true;
        insert p1;
        OpportunityLineItem oli1 = TestUtils.getOLI(oppty, p1);
        oli1.Quote_Group__c = parentQG.id;
        insert oli1;
        Product2 p2 = TestUtils.getProduct('ut prod2');
        p2.Asset_Created_for_Product__c = true;
        insert p2;
        OpportunityLineItem oli2 = TestUtils.getOLI(oppty, p2);
        oli2.Quote_Group__c = childQG.id;
        insert oli2;
        Set<ID> productIDs = new Set<ID>();
        productIDs.add(p1.id);
        productIDs.add(p2.id);
        
        OpportunityServices.isOpportunityTriggerRunning = false;
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_APPROVED;
        update oppty;
        
        List<Troy_Asset__c> createdAssets = [Select ID, Product__c, System__c from Troy_Asset__c where Account__c =: a.id];
        System.assertEquals(2, createdAssets.size());
        System.assertEquals(true, productIDs.contains(createdAssets[0].Product__c));
        System.assertEquals(true, productIDs.contains(createdAssets[1].Product__c));
    }
    */
    
    /*
    static testMethod void testApproveOpptyForAssetCreation_AddOn_Opportunity()
    {
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        Entitlement ent = TestUtils.getEntitlement(a);
        ent.StartDate = Date.Today();
        ent.endDate = Date.Today().addDays(20);
        insert ent;
        System__c sys = TestUtils.getSystem(a, ent, 'UT sys1');
        sys.Concurrent_Users__c = 10;
        insert sys;
        Additional_Environment__c ae = TestUtils.getAdditionalEnvironment(a, sys, 'ae1');
        ae.Concurrent_Users__c = 20;
        insert ae;
        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        
        Product2 p1 = TestUtils.getProduct('ut prod1');
        insert p1;
        Product2 p2 = TestUtils.getProduct('ut prod2');
        insert p2;
        
        Troy_Asset__c ast1 = TestUtils.getAsset(a, p1, sys);
        ast1.Previous_Annual_Maintenance__c = 100;
        ast1.Annual_Maintenance__c = 200;
        insert ast1;
        Troy_Asset__c ast2 = TestUtils.getAsset(a, p2, sys);
        ast2.Previous_Annual_Maintenance__c = 50;
        ast2.Annual_Maintenance__c = 75;
        insert ast2;
        Set<ID> assetIDs = new Set<ID>();
        assetIDs.add(ast1.id);
        assetIDs.add(ast2.id);
                
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_IN_REVIEW;
        oppty.RecordTypeID = OpportunityServices.recordTypesNameMap.get(Constants.OPPORTUNITY_RECORD_TYPE_STANDARD).id;
        oppty.Contract__c = ctrct.id;
        oppty.Order_Type__c = Constants.ORDER_TYPE_ADD_ON;
        insert oppty;
        Quote_Group__c parentQG = TestUtils.getQuoteGroup(oppty);
        parentQG.System__c = sys.id;
        parentQG.Concurrent_Users__c = 5;
        insert parentQG;
        Quote_Group__c childQG = TestUtils.getQuoteGroup(oppty);
        childQG.Production_Quote_System__c = parentQG.id;
        childQG.Concurrent_Users__c = 6;
        childQG.RecordTypeId = QuoteGroupServices.recordTypesNameMap.get(Constants.QUOTE_GROUP_RECORD_TYPE_ADDITIONAL).id;
        childQG.Additional_Environment__c = ae.id;
        insert childQG;
        
        OpportunityLineItem oli1 = TestUtils.getOLI(oppty, p1);
        oli1.Quote_Group__c = parentQG.id;
        oli1.Asset__c = ast1.id;
        oli1.Annual_Maintenance__c = 50;
        insert oli1;
        OpportunityLineItem oli2 = TestUtils.getOLI(oppty, p2);
        oli2.Quote_Group__c = parentQG.id;
        oli2.Asset__c = ast2.id;
        oli2.Annual_Maintenance__c = 60;
        insert oli2;
        
        OpportunityServices.isOpportunityTriggerRunning = false;
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_APPROVED;
        update oppty;
        
        Map<ID, Troy_Asset__c> assetMap = new Map<ID, Troy_Asset__c>([Select ID, Annual_Maintenance__c, Previous_Annual_Maintenance__c from Troy_Asset__c where id in: assetIDs]);
        System.assertEquals(200, assetMap.get(ast1.id).Previous_Annual_Maintenance__c);
        System.assertEquals(200+50, assetMap.get(ast1.id).Annual_Maintenance__c);
        
        System.assertEquals(75, assetMap.get(ast2.id).Previous_Annual_Maintenance__c);
        System.assertEquals(75+60, assetMap.get(ast2.id).Annual_Maintenance__c);
          
    }
    */
    
    /*    
    //Renewal and Upgrade code commented out in OpptyServices
    /*
    static testMethod void testApproveOpptyForAssetCreation_Renewal_Opportunity()
    {
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        Entitlement ent = TestUtils.getEntitlement(a);
        ent.StartDate = Date.Today();
        ent.endDate = Date.Today().addDays(20);
        insert ent;
        System__c sys = TestUtils.getSystem(a, ent, 'UT sys1');
        sys.Concurrent_Users__c = 10;
        insert sys;
        Additional_Environment__c ae = TestUtils.getAdditionalEnvironment(a, sys, 'ae1');
        ae.Concurrent_Users__c = 20;
        insert ae;
        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        
        Product2 p1 = TestUtils.getProduct('ut prod1');
        insert p1;
        Product2 p2 = TestUtils.getProduct('ut prod2');
        insert p2;
        
        Troy_Asset__c ast1 = TestUtils.getAsset(a, p1, sys);
        ast1.Previous_Annual_Maintenance__c = 100;
        ast1.Annual_Maintenance__c = 200;
        insert ast1;
        Troy_Asset__c ast2 = TestUtils.getAsset(a, p2, sys);
        ast2.Previous_Annual_Maintenance__c = 50;
        ast2.Annual_Maintenance__c = 75;
        insert ast2;
        Set<ID> assetIDs = new Set<ID>();
        assetIDs.add(ast1.id);
        assetIDs.add(ast2.id);
                
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_IN_REVIEW;
        oppty.RecordTypeID = OpportunityServices.recordTypesNameMap.get(Constants.OPPORTUNITY_RECORD_TYPE_STANDARD).id;
        oppty.Contract__c = ctrct.id;
        oppty.Order_Type__c = Constants.ORDER_TYPE_RENEWAL;
        oppty.Finance_Approved_Date__c = Date.Today();
        insert oppty;
        Quote_Group__c parentQG = TestUtils.getQuoteGroup(oppty);
        parentQG.System__c = sys.id;
        parentQG.Concurrent_Users__c = 5;
        insert parentQG;
        Quote_Group__c childQG = TestUtils.getQuoteGroup(oppty);
        childQG.Production_Quote_System__c = parentQG.id;
        childQG.Concurrent_Users__c = 6;
        childQG.RecordTypeId = QuoteGroupServices.recordTypesNameMap.get(Constants.QUOTE_GROUP_RECORD_TYPE_ADDITIONAL).id;
        childQG.Additional_Environment__c = ae.id;
        insert childQG;
        
        OpportunityLineItem oli1 = TestUtils.getOLI(oppty, p1);
        oli1.Quote_Group__c = parentQG.id;
        oli1.Asset__c = ast1.id;
        oli1.Annual_Maintenance__c = 50;
        oli1.License_Metric_Quantity__c = 5;
        oli1.Term_Begin_Date__c = Date.Today();
        oli1.Term_End_Date__c = Date.Today().addYears(1);
        insert oli1;
        OpportunityLineItem oli2 = TestUtils.getOLI(oppty, p2);
        oli2.Quote_Group__c = parentQG.id;
        oli2.Asset__c = ast2.id;
        oli2.Annual_Maintenance__c = 60;
        oli2.License_Metric_Quantity__c = 6;
        oli2.Term_Begin_Date__c = Date.Today();
        oli2.Term_End_Date__c = Date.Today().addYears(1);
        insert oli2;
        
        OpportunityServices.isOpportunityTriggerRunning = false;
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_APPROVED;
        update oppty;
        
        Map<ID, Troy_Asset__c> assetMap = new Map<ID, Troy_Asset__c>([Select ID, Annual_Maintenance__c, Previous_Annual_Maintenance__c, Term_Begin_Date__c, 
        																		Term_End_Date__c, Maintenance_Status__c
        																		from Troy_Asset__c where id in: assetIDs]);
        System.assertEquals(Constants.STATUS_ON_MAINTENANCE, assetMap.get(ast1.id).Maintenance_Status__c);
        System.assertEquals(Date.Today(), assetMap.get(ast1.id).Term_Begin_Date__c);
        System.assertEquals(Date.Today().addYears(1), assetMap.get(ast1.id).Term_End_Date__c);
        System.assertEquals(200, assetMap.get(ast1.id).Previous_Annual_Maintenance__c);
        System.assertEquals(50, assetMap.get(ast1.id).Annual_Maintenance__c);
        
        System.assertEquals(Constants.STATUS_ON_MAINTENANCE, assetMap.get(ast2.id).Maintenance_Status__c);
        System.assertEquals(Date.Today(), assetMap.get(ast2.id).Term_Begin_Date__c);
        System.assertEquals(Date.Today().addYears(1), assetMap.get(ast2.id).Term_End_Date__c);
        System.assertEquals(75, assetMap.get(ast2.id).Previous_Annual_Maintenance__c);
        System.assertEquals(60, assetMap.get(ast2.id).Annual_Maintenance__c);
        
        sys = [Select id, Concurrent_Users__c from System__c where id =: sys.id];
        System.assertEquals(5, sys.Concurrent_Users__c);
        //ae = [Select id, Concurrent_Users__c from Additional_Environment__c where id =: ae.id];
        //System.assertEquals(6, ae.Concurrent_Users__c);
    }
    */
    
    /*    
    static testMethod void testApproveOpptyForAssetCreation_Upgrade_Opportunity()
    {
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        Entitlement ent = TestUtils.getEntitlement(a);
        ent.StartDate = Date.Today();
        ent.endDate = Date.Today().addDays(20);
        insert ent;
        System__c sys = TestUtils.getSystem(a, ent, 'UT sys1');
        sys.Concurrent_Users__c = 10;
        insert sys;
        Additional_Environment__c ae = TestUtils.getAdditionalEnvironment(a, sys, 'ae1');
        ae.Concurrent_Users__c = 20;
        insert ae;
        Contract ctrct = TestUtils.getContract(a);
        insert ctrct;
        
        Product2 p1 = TestUtils.getProduct('ut prod1');
        insert p1;
        Product2 p2 = TestUtils.getProduct('ut prod2');
        insert p2;
        
        Troy_Asset__c ast1 = TestUtils.getAsset(a, p1, sys);
        ast1.Previous_Annual_Maintenance__c = 100;
        ast1.Annual_Maintenance__c = 200;
        insert ast1;
        Troy_Asset__c ast2 = TestUtils.getAsset(a, p2, sys);
        ast2.Previous_Annual_Maintenance__c = 50;
        ast2.Annual_Maintenance__c = 75;
        insert ast2;
        Set<ID> assetIDs = new Set<ID>();
        assetIDs.add(ast1.id);
        assetIDs.add(ast2.id);
                
        Opportunity oppty = TestUtils.getOpportunity(a, 'UT Oppty1');
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_IN_REVIEW;
        oppty.RecordTypeID = OpportunityServices.recordTypesNameMap.get(Constants.OPPORTUNITY_RECORD_TYPE_STANDARD).id;
        oppty.Contract__c = ctrct.id;
        oppty.Order_Type__c = Constants.ORDER_TYPE_UPGRADE;
        oppty.Finance_Approved_Date__c = Date.Today();
        insert oppty;
        Quote_Group__c parentQG = TestUtils.getQuoteGroup(oppty);
        parentQG.System__c = sys.id;
        parentQG.Concurrent_Users__c = 5;
        insert parentQG;
        Quote_Group__c childQG = TestUtils.getQuoteGroup(oppty);
        childQG.Production_Quote_System__c = parentQG.id;
        childQG.Concurrent_Users__c = 6;
        childQG.RecordTypeId = QuoteGroupServices.recordTypesNameMap.get(Constants.QUOTE_GROUP_RECORD_TYPE_ADDITIONAL).id;
        childQG.Additional_Environment__c = ae.id;
        insert childQG;
        
        OpportunityLineItem oli1 = TestUtils.getOLI(oppty, p1);
        oli1.Quote_Group__c = parentQG.id;
        oli1.Asset__c = ast1.id;
        oli1.Annual_Maintenance__c = 50;
        oli1.License_Metric_Quantity__c = 5;
        insert oli1;
        OpportunityLineItem oli2 = TestUtils.getOLI(oppty, p2);
        oli2.Quote_Group__c = parentQG.id;
        oli2.Asset__c = ast2.id;
        oli2.Annual_Maintenance__c = 60;
        oli2.License_Metric_Quantity__c = 6;
        insert oli2;
        
        OpportunityServices.isOpportunityTriggerRunning = false;
        oppty.Finance_Review__c = Constants.FINANCE_REVIEW_APPROVED;
        update oppty;
        
        Map<ID, Troy_Asset__c> assetMap = new Map<ID, Troy_Asset__c>([Select ID, Annual_Maintenance__c, Previous_Annual_Maintenance__c from Troy_Asset__c where id in: assetIDs]);
        System.assertEquals(200, assetMap.get(ast1.id).Previous_Annual_Maintenance__c);
        System.assertEquals(50, assetMap.get(ast1.id).Annual_Maintenance__c);
        
        System.assertEquals(75, assetMap.get(ast2.id).Previous_Annual_Maintenance__c);
        System.assertEquals(60, assetMap.get(ast2.id).Annual_Maintenance__c);
        
        sys = [Select id, Concurrent_Users__c from System__c where id =: sys.id];
        System.assertEquals(5, sys.Concurrent_Users__c);
        //ae = [Select id, Concurrent_Users__c from Additional_Environment__c where id =: ae.id];
        //System.assertEquals(6, ae.Concurrent_Users__c);
    }
    */
}