/**
 * @File Name          : AssetTriggerHandlerTest.cls
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 13/11/2019, 11:51:23
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    07/11/2019   Peter Sabry     Initial Version
**/
@isTest
public with sharing class AssetTriggerHandlerTest {
    public static testMethod void setAssetNextReviewDate_PositiveSingleTest() {
        
        final Date CONTRACT_START_DATE = date.newInstance(2019, 7, 1);
        final Date EXPECTED_REVIEW_DATE = date.newInstance(2020, 9, 1);

        Account[] accts = TestDataFactory.createAccounts(1, true);
        Contact[] conts = TestDataFactory.createContacts(accts[0].Id, 1, true);
        Product2 product = TestDataFactory.createProduct('Test Product', true);

        contract contract = TestDataFactory.createContract(accts[0].Id, CONTRACT_START_DATE, true);
        SBQQ__Subscription__c subs = TestDataFactory.createSubscription(accts[0].Id, contract.Id, product.Id, true);

        // Perform test
        Test.startTest();
        
        Asset[] assets = TestDataFactory.createAssets(accts[0].Id, conts[0].Id, product.Id, subs.Id, 1, true);
        assets = [Select Id, Review_Date__c from Asset];
        Test.stopTest();

        //Verify results
        System.assertEquals(assets[0].Review_Date__c, EXPECTED_REVIEW_DATE, 'Review Date should be set to 1/9/2020');
    }
    
    public static testMethod void setAssetNextReviewDate_NegativeTest() {

        Account[] accts = TestDataFactory.createAccounts(1, true);
        Contact[] conts = TestDataFactory.createContacts(accts[0].Id, 1, true);
        Product2 product = TestDataFactory.createProduct('Test Product', true);
        
        // Perform test
        Test.startTest();
        
        Asset[] assets = TestDataFactory.createAssets(accts[0].Id, conts[0].Id, product.Id, null, 1, true);
        assets = [Select Id, Review_Date__c from Asset];
        Test.stopTest();

        //Verify results
        System.assertEquals(assets[0].Review_Date__c, null, 'Review Date is not set');
    }
    public static testMethod void setAssetNextReviewDate_BulkifiedTest() {
        
        final Date CONTRACT_START_DATE = date.newInstance(2019, 7, 1);
        final Date EXPECTED_REVIEW_DATE = date.newInstance(2020, 9, 1);

        Account[] accts = TestDataFactory.createAccounts(1, true);
        Contact[] conts = TestDataFactory.createContacts(accts[0].Id, 1, true);
        Product2 product = TestDataFactory.createProduct('Test Product', true);

        contract contract = TestDataFactory.createContract(accts[0].Id, CONTRACT_START_DATE, true);
        SBQQ__Subscription__c subs = TestDataFactory.createSubscription(accts[0].Id, contract.Id, product.Id, true);

        // Perform test
        Test.startTest();
        
        Asset[] assets = TestDataFactory.createAssets(accts[0].Id, conts[0].Id, product.Id, subs.Id, 10, true); //Create 10 assets
        assets = [Select Id, Review_Date__c from Asset];
        Test.stopTest();

        //Verify results
        for(Asset newAsset : assets) {
            System.assertEquals(newAsset.Review_Date__c, EXPECTED_REVIEW_DATE, 'Review Date should be set to 1/9/2020');
        }
    }
}