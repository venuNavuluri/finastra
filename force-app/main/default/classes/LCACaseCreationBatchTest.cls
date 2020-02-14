/**
 * @File Name          : LCACaseCreationBatchTest.cls
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 13/11/2019, 14:34:43
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    13/11/2019   Peter Sabry     Initial Version
**/
@isTest
public with sharing class LCACaseCreationBatchTest {
    public static final string ASSERT_MSG_LCA_CASE_CREATED = 'An LCA Case should be created for each asset.';
    /**
    * @description Positive single test - batch job creates a new LCA Case for assets that have a review date in the batch creation window
    * @author Peter Sabry | 13/11/2019 
    * @return testMethod 
    **/
    public static testMethod void createLCACaseBatch_PositiveTest() {
        Account[] accts = TestDataFactory.createAccounts(1, true);
        Contact[] conts = TestDataFactory.createContacts(accts[0].Id, 1, true);
        Product2 product = TestDataFactory.createProduct('Test Product', true);

        Asset[] assets = TestDataFactory.createAssets(accts[0].Id, conts[0].Id, product.Id, null, 10, true); //Create 10 Assets
        for(Asset newAsset : assets) {
            newAsset.Review_Date__c = date.today().addDays(Constants.LCA_DAYS_TO_CREATE_CASE);
        }
        update assets;

        // Perform test
        Test.startTest();

        //Run batch
        LCACaseCreationBatch batchObject = new LCACaseCreationBatch();
        Id batchId = Database.executeBatch(batchObject);
            
        Test.stopTest();
        
        //Verify results
        system.assert(batchId != null, 'Batch job should run');
        List<Case> casesList = new List<Case>([Select Id from Case where AssetId in :assets]);
        system.assertEquals(casesList.size(), assets.size(), ASSERT_MSG_LCA_CASE_CREATED);
    }
    /**
    * @description Negative test - batch job shouldn't create a new LCA Case for assets that don't have a review date in the batch creation window
    * @author Peter Sabry | 13/11/2019 
    * @return testMethod 
    **/
    public static testMethod void createLCACaseBatch_NegativeTest() {

        Account[] accts = TestDataFactory.createAccounts(1, true);
        Contact[] conts = TestDataFactory.createContacts(accts[0].Id, 1, true);
        Product2 product = TestDataFactory.createProduct('Test Product', true);

        Asset[] assets = TestDataFactory.createAssets(accts[0].Id, conts[0].Id, product.Id, null, 1, true);
        assets[0].Review_Date__c = date.today().addDays(Constants.LCA_DAYS_TO_CREATE_CASE).addDays(1); //Review date outside of the case creation window
        update assets;

        // Perform test
        Test.startTest();

        //Run batch
        LCACaseCreationBatch batchObject = new LCACaseCreationBatch();
        Id batchId = Database.executeBatch(batchObject);
            
        Test.stopTest();
        
        //Verify results
        system.assert(batchId != null, 'Batch job should run');
        List<Case> casesList = new List<Case>([Select Id from Case where AssetId in :assets]);
        system.assertEquals(casesList.size(), 0, 'No cases should be created.');
    }
}
