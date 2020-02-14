@isTest
private class TestProductRebrandingRename{

    @testSetup
    private static void setup(){
        Account acc = new Account(name = 'test acc');
        insert acc;
        System__c sys = new System__c(Account__c = acc.Id);
        insert sys;
        Product_Set__c ps = TestUtility.sampleProductSet(acc.Id);
        ps.Name = 'test product set';
        insert ps;
        Entitlement__c ent = TestUtility.sampleEntitlement(acc.Id, sys.Id);
        ent.name = 'test ent';
        ent.Product_Set__c = ps.Id;
        insert ent;
        Product2 prod = TestUtility.sampleProduct();
        prod.Product_Set__c = 'test product set';
        insert prod;
        Client_Asset__c clientAsset = TestUtility.sampleClientAsset(ps.Id);
        clientAsset.Product__c = prod.Id;
        clientAsset.name = 'test client asset';
        insert clientAsset;
        Contract_Asset__c contractAsset = TestUtility.sampleContractAsset(clientAsset.Id, sys.Id, acc.Id);
        contractAsset.Product__c = prod.Id;
        contractAsset.name = 'test contract asset';
        insert contractAsset;
        NS_Revenue_Recognition_Template__c temp = new NS_Revenue_Recognition_Template__c(Name = 'POC');
        insert temp;
        Sales_Order__c so = TestUtility.sampleSalesOrder();
        insert so;
        sales_order_item__c soi = TestUtility.sampleSalesOrderItem(so.Id);
        soi.ns_item__c = prod.Id;
        soi.name = 'test soi';
        insert soi;
    }

    private static testMethod void testRenameProductSet(){

        ProductRebrandingRename.renameProductSet('test product set', 'Almonde');
        List<Product_Set__c> productSetList = [
                SELECT Id,Name,Account__r.name,CreatedDate,PR_Old_Product_Set_Name__c,PR_Rename_Done__c
                FROM Product_Set__c
        ];
        System.assertEquals(true, productSetList[0].PR_Rename_Done__c);
        System.assertEquals('Almonde', productSetList[0].name);

    }

    private static testMethod void testRenameSupportEntitlement(){

        ProductRebrandingRename.renameSupportEntitlement('test ent', 'Almonde', 'test product set');
        List<Entitlement__c> entitlementList = [SELECT Id,Name,CreatedDate,Account__r.name,Product_Set__r.name,
                PR_Old_Entitlement_Name__c,PR_Rename_Done__c FROM Entitlement__c];
        System.assertEquals(true, entitlementList[0].PR_Rename_Done__c);
        System.assertEquals('Almonde', entitlementList[0].name);

    }

    private static testMethod void testRenameClientAsset(){

        ProductRebrandingRename.renameClientAsset('test client asset', 'Almonde', 'test product set');
        List<Client_Asset__c> clientAssetList = [SELECT Id,Name,Account__r.name,CreatedDate,Product_Set__r.name,
                PR_Old_Client_Asset_Name__c,PR_Rename_Done__c FROM Client_Asset__c];
        System.assertEquals(true, clientAssetList[0].PR_Rename_Done__c);
        System.assertEquals('Almonde', clientAssetList[0].name);

    }

    private static testMethod void testRenameContractAsset(){

        ProductRebrandingRename.renameContractAsset('test contract asset', 'Almonde', 'test product set');
        List<Contract_Asset__c> contractAssetList = [SELECT Account__r.name,Contract__r.name,CreatedDate,Id,Name,
                Full_Asset_Name__c,Product_Set__c,PR_Old_Contract_Asset_Name__c,PR_Rename_Done__c
        FROM Contract_Asset__c];
        System.assertEquals(true, contractAssetList[0].PR_Rename_Done__c);
        System.assertEquals('Almonde', contractAssetList[0].name);

    }

    private static testMethod void testRenameSalesOrderItem(){

        ProductRebrandingRename.renameSalesOrderItem('test soi', 'Almonde', 'test product set');
        List<sales_order_item__c> salesOrderItemList = [select name, ID, description__c,PR_Old_Sales_Order_Item_Name__c,
                PR_Rename_Done__c from sales_order_item__c];
        System.assertEquals(true, salesOrderItemList[0].PR_Rename_Done__c);
        System.assertEquals('Almonde', salesOrderItemList[0].name);

    }

}