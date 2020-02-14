/*
Author: Ramesh Thulasi
Descriptiton: OpportunityPipelinesExt tests
Created on: 27-2-2018
*/
@isTest
private class OpportunityPipelinesExt_Test {
    @testSetup 
    static void dataSetup() {
    	Opportunity testOpp = TestUtility.sampleOpportunity();
        insert testOpp;
    }
    private static testMethod void  test_PSButton_Disable() {
    	Opportunity testOpp = [select id,Name,PS_Stage__c,StageName,RecordTypeId from Opportunity limit 1];
    	System.assertNotEquals(null,testOpp);

		NS_Project__c nsProj = TestDataFactory.createNSProject(false);
    	nsProj.Deferred_Account_Type__c =OppPipelineUtil.PIPELINE_DEFFERED_NAME;
        nsProj.Opportunity__c = testOpp.Id;
    	insert nsProj;

    	PageReference  pRef = Page.OppPipelinesInline;
    	pRef.getParameters().put('id',testOpp.id);
    	Test.setCurrentPage(pref);
    	ApexPages.StandardController stdOpp = new ApexPages.StandardController(testOpp);
        OpportunityPipelinesExt oppPipelinesExt = new OpportunityPipelinesExt(stdOpp);

        System.assertEquals(true,oppPipelinesExt.psDisable,'New PS Project button should be disabled if Opportunity has 1 or more Pipeline project(s)');
    }
     private static testMethod void  test_PLButton_Disable() {
    	Opportunity testOpp = [select id,Name,PS_Stage__c,StageName,RecordTypeId from Opportunity limit 1];
    	System.assertNotEquals(null,testOpp);
		NS_Project__c nsProj = TestDataFactory.createNSProject(false);
    	nsProj.Deferred_Account_Type__c ='PS';
        nsProj.Opportunity__c = testOpp.Id;
    	insert nsProj;

    	PageReference  pRef = Page.OppPipelinesInline;
    	pRef.getParameters().put('id',testOpp.id);
    	Test.setCurrentPage(pref);
    	ApexPages.StandardController stdOpp = new ApexPages.StandardController(testOpp);
        OpportunityPipelinesExt oppPipelinesExt = new OpportunityPipelinesExt(stdOpp);

        System.assertEquals(true,oppPipelinesExt.plDisable,'New PL Project button should be disabled if Opportunity has 1 or more PS project(s)');
    }
    private static testMethod void  test_PSButton_Enable_PLButton_Enable() {
    	//Opportunity testOpp = [select id,Name,PS_Stage__c,StageName,RecordTypeId from Opportunity limit 1];
    	Opportunity testOpp = [select id,Name,PS_Stage__c,RecordTypeId from Opportunity limit 1];
    	System.assertNotEquals(null,testOpp);
    	testOpp.RecordTypeId = [Select Id from RecordType where Name='Licenses with/without PS' limit 1].id;
    	//testOpp.StageName='4. Develop';
    	testOpp.PS_Stage__c='4. Refine';
		//testOpp.PS_Stage__c='2. Check';
        testOpp.PS_Risk_Category__c='High';
		update testOpp;
    	PageReference  pRef = Page.OppPipelinesInline;
    	pRef.getParameters().put('id',testOpp.id);
    	Test.setCurrentPage(pref);
    	ApexPages.StandardController stdOpp = new ApexPages.StandardController(testOpp);
        OpportunityPipelinesExt oppPipelinesExt = new OpportunityPipelinesExt(stdOpp);

        System.assertEquals(false,oppPipelinesExt.plDisable,'New Pipeline Project button should be enabled if Opportunity has 0 NS project and opp record type is \'Licenses with/without PS\' == rt.Name and opp PS_Stage__c is \'4. Refine\' and above');
        System.assertEquals(false,oppPipelinesExt.psDisable,'New Pipeline Project button should be enabled if Opportunity has 0 NL project');

    }
    private static OpportunityPipelinesExt setUpController() {
		Opportunity testOpp = [select id,Name,PS_Stage__c,StageName,RecordTypeId from Opportunity limit 1];
    	System.assertNotEquals(null,testOpp);
    	PageReference  pRef = Page.OppPipelinesInline;
    	pRef.getParameters().put('id',testOpp.id);
    	Test.setCurrentPage(pref);
    	ApexPages.StandardController stdOpp = new ApexPages.StandardController(testOpp);
        
        OpportunityPipelinesExt oppPipelinesExt = new OpportunityPipelinesExt(stdOpp);
        return oppPipelinesExt;
    }
    private static testMethod void testCreateGSCProject() {
    	OpportunityPipelinesExt oppPipelinesExt = setUpController();
    	PageReference pRef = oppPipelinesExt.createGSCProject();

		System.assert(pRef.getUrl().startsWith('/'+NS_Project__c.SObjectType.getDescribe().getKeyPrefix() + '/e'));

    	Map<String,String> paramMap = pRef.getParameters();
    	// url-hacking to prepopulate values on GSC project creation 
    	System.assertEquals('GSC',paramMap.get(OppPipelineUtil.DEFERRED_ACCOUNT_TYPE_FIELD_ID),'Set PS Project\'s \'Deferred Account Type\' field to GSC');
    	System.assertEquals(oppPipelinesExt.opp.Name,paramMap.get(OppPipelineUtil.OPP_FIELD_ID),'Set PS Project\'s \'Opportunity\'');
    	System.assertEquals(oppPipelinesExt.opp.id,paramMap.get(OppPipelineUtil.OPP_LINK_FIELD_ID),'Set PS Project\'s \'Opportunity\'');
    	System.assertEquals('/'+oppPipelinesExt.opp.id,paramMap.get('cancelURL'),'Set Cancel url');
    	System.assertEquals('1',paramMap.get('nooverride'));
    	System.assertEquals('1',paramMap.get(OppPipelineUtil.TRICKLE_OPPORTUNITY_DATA_FIELD_ID),'Set PS Project\'s \'Trickle Opportunity Data\' field to true');
    }
    private static testMethod void testCreatePSProject() {
    	OpportunityPipelinesExt oppPipelinesExt = setUpController();
    	PageReference pRef = oppPipelinesExt.createPSProject();

		System.assert(pRef.getUrl().startsWith('/'+NS_Project__c.SObjectType.getDescribe().getKeyPrefix() + '/e'));

    	Map<String,String> paramMap = pRef.getParameters();
    	// url-hacking to prepopulate values on PS project creation 
    	System.assertEquals('PS',paramMap.get(OppPipelineUtil.DEFERRED_ACCOUNT_TYPE_FIELD_ID),'Set PS Project\'s \'Deferred Account Type\' field to PS');
    	System.assertEquals(oppPipelinesExt.opp.Name,paramMap.get(OppPipelineUtil.OPP_FIELD_ID),'Set PS Project\'s \'Opportunity\'');
    	System.assertEquals(oppPipelinesExt.opp.id,paramMap.get(OppPipelineUtil.OPP_LINK_FIELD_ID),'Set PS Project\'s \'Opportunity\'');
    	System.assertEquals('/'+oppPipelinesExt.opp.id,paramMap.get('cancelURL'),'Set Cancel url');
    	System.assertEquals('1',paramMap.get('nooverride'));
    	System.assertEquals('1',paramMap.get(OppPipelineUtil.TRICKLE_OPPORTUNITY_DATA_FIELD_ID),'Set PS Project\'s \'Trickle Opportunity Data\' field to true');
    }
    private static testMethod void testCreatePLProject() {
    	OpportunityPipelinesExt oppPipelinesExt = setUpController();
    	PageReference pRef = oppPipelinesExt.createPLProject();

		System.assert(pRef.getUrl().startsWith('/'+NS_Project__c.SObjectType.getDescribe().getKeyPrefix() + '/e'));

    	Map<String,String> paramMap = pRef.getParameters();
    	// url-hacking to prepopulate values on PL project creation 
    	System.assertEquals(OppPipelineUtil.PIPELINE_DEFFERED_NAME,paramMap.get(OppPipelineUtil.DEFERRED_ACCOUNT_TYPE_FIELD_ID),'Set PS Project\'s \'Deferred Account Type\' field to PL');
    	System.assertEquals(oppPipelinesExt.opp.Name,paramMap.get(OppPipelineUtil.OPP_FIELD_ID),'Set PS Project\'s \'Opportunity\'');
    	System.assertEquals(oppPipelinesExt.opp.id,paramMap.get(OppPipelineUtil.OPP_LINK_FIELD_ID),'Set PS Project\'s \'Opportunity\'');
    	System.assertEquals('/'+oppPipelinesExt.opp.id,paramMap.get('cancelURL'),'Set Cancel url');
    	System.assertEquals('1',paramMap.get('nooverride'));
    	System.assertEquals('1',paramMap.get(OppPipelineUtil.TRICKLE_OPPORTUNITY_DATA_FIELD_ID),'Set PS Project\'s \'Trickle Opportunity Data\' field to true');
    }
    private static testMethod  void testNewNSProject() {
    	OpportunityPipelinesExt oppPipelinesExt = setUpController();
    	PageReference pRef = oppPipelinesExt.newNSProject();
		System.assert(pRef.getUrl().startsWith('/'+NS_Project__c.SObjectType.getDescribe().getKeyPrefix() + '/e'));
    	Map<String,String> paramMap = pRef.getParameters();
    	System.assertEquals(oppPipelinesExt.opp.id,paramMap.get('retURL'),'Set Return url');
    }
    private static testMethod void testEditNSProject() {
		Opportunity testOpp = [select id,Name,PS_Stage__c,StageName,RecordTypeId from Opportunity limit 1];
    	NS_Project__c nsProj = TestDataFactory.createNSProject(false);
    	nsProj.Deferred_Account_Type__c ='PS';
        nsProj.Opportunity__c = testOpp.Id;
    	insert nsProj;
    	OpportunityPipelinesExt oppPipelinesExt = setUpController();
    	ApexPages.currentPage().getParameters().put('nsProjId', nsProj.id);
    	PageReference pRef = oppPipelinesExt.editNSProject();
    	System.assert(pRef.getUrl().startsWith('/'+nsProj.id + '/e'));
    	Map<String,String> paramMap = pRef.getParameters();
    	System.assertEquals(oppPipelinesExt.opp.id,paramMap.get('retURL'),'Set Return url');
    }
    private static testMethod void testDeleteNSProject() {
		Opportunity testOpp = [select id,Name,PS_Stage__c,StageName,RecordTypeId from Opportunity limit 1];
    	NS_Project__c nsProj = TestDataFactory.createNSProject(false);
    	nsProj.Deferred_Account_Type__c ='PS';
        nsProj.Opportunity__c = testOpp.Id;
    	insert nsProj;
    	OpportunityPipelinesExt oppPipelinesExt = setUpController();
    	ApexPages.currentPage().getParameters().put('nsProjId', nsProj.id);
    	PageReference pRef = oppPipelinesExt.deleteNSProject();
    	System.assertEquals(0,[select count() from NS_Project__c ],'NS Project should have been deleted');
    }

}