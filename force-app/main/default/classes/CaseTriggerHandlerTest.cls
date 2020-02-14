/**
* @File Name          : CaseTriggerHandlerTest.cls
* @Description        : 
* @Author             : venu.navuluri@finastra.com
* @Group              : 
* @Last Modified By   : Peter Sabry
* @Last Modified On   : 19/11/2019, 12:26:01
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    05/11/2019   venu.navuluri@finastra.com     Initial Version
**/
@isTest
public with sharing class CaseTriggerHandlerTest {
    public static final string ASSERT_MSG_ASSET_REVIEW_DATE = 'Asset review date is recalculated using case close date.';
    public static final string AUDIT_RESULT_SUMMARY = 'This is audit result summary for unit test';
    /**
* @description Set Asset Next Review date when the case is closed
* @author Peter Sabry | 13/11/2019 
* @return testMethod 
**/
    public static testMethod void setAssetNextReviewDate_PositiveSingleTest() {
        
        Account[] accts = TestDataFactory.createAccounts(1, true);
        Contact[] conts = TestDataFactory.createContacts(accts[0].Id, 1, true);
        Product2 product = TestDataFactory.createProduct('Test Product', true);
        
        Asset[] assets = TestDataFactory.createAssets(accts[0].Id, conts[0].Id, product.Id, null, 1, true);
        
        Case LCACase = TestDataFactory.CreateLCACase(accts[0].Id, assets[0].Id, true);
        
        // Perform test
        Test.startTest();
        
        LCACase.Status = Constants.CASE_STATUS_CLOSED;
        update LCACase;
        
        Test.stopTest();
        
        assets = [Select Id, Review_Date__c from Asset];
        
        //Verify results
        System.assertEquals(assets[0].Review_Date__c, CommonUtils.getNextFinancialYearQuarterStartDate(date.today()), ASSERT_MSG_ASSET_REVIEW_DATE);
    }
    /**
* @description Asset Review Date shouldn't change if the case is not linked to an asset
* @author Peter Sabry | 13/11/2019 
* @return testMethod 
**/
    public static testMethod void setAssetNextReviewDate_NegativeTest() {
        
        Account[] accts = TestDataFactory.createAccounts(1, true);
        Contact[] conts = TestDataFactory.createContacts(accts[0].Id, 1, true);
        Product2 product = TestDataFactory.createProduct('Test Product', true);
        
        Asset[] assets = TestDataFactory.createAssets(accts[0].Id, conts[0].Id, product.Id, null, 1, true);
        
        Case LCACase = TestDataFactory.CreateLCACase(accts[0].Id, null, true); //Case not linked to an asset
        
        // Perform test
        Test.startTest();
        
        LCACase.Status = Constants.CASE_STATUS_CLOSED;
        update LCACase;
        
        Test.stopTest();
        
        assets = [Select Id, Review_Date__c from Asset];
        
        //Verify results
        System.assertEquals(assets[0].Review_Date__c, null, 'Review Date is not set');
    }
    /**
* @description Bulkified Positive test
* @author Peter Sabry | 13/11/2019 
* @return testMethod 
**/
    public static testMethod void setAssetNextReviewDate_BulkifiedTest() {
        
        Account[] accts = TestDataFactory.createAccounts(1, true);
        Contact[] conts = TestDataFactory.createContacts(accts[0].Id, 1, true);
        Product2 product = TestDataFactory.createProduct('Test Product', true);
        
        Asset[] assets = TestDataFactory.createAssets(accts[0].Id, conts[0].Id, product.Id, null, 10, true);
        
        List<Case> cases = new List<Case>();
        for(Asset newAsset : assets) {
            cases.add(TestDataFactory.CreateLCACase(accts[0].Id, newAsset.Id, false));
        }
        insert cases;
        
        // Perform test
        Test.startTest();
        for(Case lcaCase : cases) {
            LCACase.Status = Constants.CASE_STATUS_CLOSED;
        }
        update cases;
        
        Test.stopTest();
        
        assets = [Select Id, Review_Date__c from Asset];
        
        //Verify results
        for(Asset newAsset : assets) {
            System.assertEquals(newAsset.Review_Date__c, CommonUtils.getNextFinancialYearQuarterStartDate(date.today()), ASSERT_MSG_ASSET_REVIEW_DATE);
        }
    }
/**
* @description positive test for approval process trigger
* @author Venu Navuluri | 13/11/2019 
* @return testMethod 
**/   
    public static testMethod void submitApprovalforLCADeselection_PositiveSingleTest() {
        
        Case[] cases = TestDataFactory.CreateCases(1,1,true);
        // Perform test
        Test.startTest();
        cases[0].Status = Constants.CASE_STATUS_DESELECTION_APPROVAL;
        cases[0].Audit_Result_Summary__c = AUDIT_RESULT_SUMMARY;
        update cases; 
        Test.stopTest();  
        
        //Verify results
        list<processInstance> processInstances = [select Id, Status from ProcessInstance where TargetObjectId = :cases[0].id];
        System.assertEquals(processInstances.size(),1);
    }
/**
* @description Approval process won't trigger status otherthan Awaiting deselection approval
* @author Venu Navuluri | 13/11/2019 
* @return testMethod 
**/    
    public static testMethod void submitApprovalforLCADeselection_NegativeTest() {
        List<Bypass_Validations__c> valCusSettings = new List<Bypass_Validations__c>();
        valCusSettings.add(new Bypass_Validations__c(SetupOwnerId=UserInfo.getUserId(), Disable__c=true));
        insert valCusSettings;
        
        Case[] cases = TestDataFactory.CreateCases(1,2,true);
        List<Case> updatedCases = new List<Case>();
        // Perform test
        Test.startTest();
        for(Case casesToUpdate: cases){
            casesToUpdate.Status = Constants.CASE_STATUS_AUDITED;
            casesToUpdate.Audit_Result_Summary__c = AUDIT_RESULT_SUMMARY;
            updatedCases.add(casesToUpdate);
        }
        if(!updatedCases.isEmpty())
            update updatedCases;
        Test.stopTest();
        
        //Verify results
        list<processInstance> processInstances = [select Id, Status from ProcessInstance where TargetObjectId = :cases[0].id];
        System.assertEquals(processInstances.size(),0);
    }
 /**
* @description Positive test on chatter post when clien complaint
* @author Peter Sabry | 13/11/2019 
* @return testMethod 
**/   
    //caused by: System.UnsupportedOperationException: 
    //ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true) recommended by salesforce.
    @isTest(SeeAllData=true)
    static void notifySalesWhenCompliant_PositiveSingleTest() {
        Case[] cases = TestDataFactory.CreateCases(1,1,true);
        List<Bypass_Validations__c> valCusSettings = new List<Bypass_Validations__c>();
        valCusSettings.add(new Bypass_Validations__c(SetupOwnerId=UserInfo.getUserId(), Disable__c=true));
        insert valCusSettings;
        
        // Perform test
        Test.startTest();
        cases[0].Status = Constants.CASE_STATUS_AUDITED;
        cases[0].Audit_Result_Summary__c = AUDIT_RESULT_SUMMARY;
        cases[0].Compliance_Sub_Status__c = Constants.COMPLIANCE_SUB_STATUS_COMPLIANT;
        update cases; 
        Test.stopTest(); 
        
        List<FeedItem > FeedItem = [SELECT Id,ParentId FROM FeedItem Where ParentId=: cases[0].Id];
        System.assertEquals(1, FeedItem.size());

    }
/**
* @description No chatter post
* @author Peter Sabry | 13/11/2019 
* @return testMethod 
**/    
    @isTest(SeeAllData=true)
    static void notifySalesWhenCompliant_NegativeTest() {
        Case[] cases = TestDataFactory.CreateCases(1,1,true);
        List<Bypass_Validations__c> valCusSettings = new List<Bypass_Validations__c>();
        valCusSettings.add(new Bypass_Validations__c(SetupOwnerId=UserInfo.getUserId(), Disable__c=true));
        insert valCusSettings;
        List<Case> updatedCases = new List<Case>();
        // Perform test
        Test.startTest(); 
        for(Case casesToUpdate: cases){
            casesToUpdate.Status = Constants.CASE_STATUS_AUDITED;
            casesToUpdate.Audit_Result_Summary__c = AUDIT_RESULT_SUMMARY;
            casesToUpdate.Compliance_Sub_Status__c = null;
            updatedCases.add(casesToUpdate);
        }
        if(!updatedCases.isEmpty())
            update updatedCases;
        Test.stopTest();
        
        List<FeedItem > FeedItem = [SELECT Id,ParentId FROM FeedItem where  ParentId IN :updatedCases];
        System.assertEquals(0, FeedItem.size());

    }
}