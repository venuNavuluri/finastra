@isTest(SeeAllData=false)
public class test_IntegrationLog_Product
{
    private static Integration_Log__c createProductIL()
    {
        Integration_Log__c ilProd = new Integration_Log__c();
        ilProd.GenString1__c = 'Test Name';
        ilProd.GenString2__c = 'Test Code';
        ilProd.GenString3__c = 'Test PF';
        ilProd.GenString4__c = 'Test SC';
        ilProd.GenString5__c = 'Bus Area';
        ilProd.GenString6__c = 'Bus Area Scope';
        ilProd.GenString7__c = 'Owner Cognos';
        ilProd.GenString8__c = 'Owner Sun';
        ilProd.GenString9__c = TestIntegrationLogUtils.GetNonStandardPricebookId();
        
        ilProd.GenString10__c = 'Test Prod Family';
        ilProd.GenString11__c = 'Test Product Set';
        ilProd.GenString12__c = 'Test Line of Business';
        Account acct = TestUtility.createAccount('Test Acct');
        CCRT__c ccrt = TestUtility.createCCRT(acct);
        Acct_By_Sub__c abs = TestIntegrationLogUtils.GetSampleAcctBySub(acct.Id);
        ilProd.GenString13__c = abs.Id;
      // ilProd.GenString13__c = 'tpvn';
        ilProd.GenString14__c = 'Test Item Name';
        ilProd.GenString15__c = 'Test Tax Schedule';
        ilProd.GenString16__c = 'cat1/subCat1/subCat2';
        ilProd.GenString17__c = 'Test Cost Centre';
        ilProd.GenString18__c = 'Test Income Account';
        ilProd.GenString19__c = 'Test Deferred Revenue Account';
        ilProd.GenString20__c = 'Test Accrued Income Account';
        ilProd.GenString21__c = 'Test Rev Rec Template';
        ilProd.GenString22__c = 'Test Expense Acct';
        ilProd.GenString23__c = 'Test Deferred Expense Acct';
        ilProd.GenString24__c = 'Test Product Dimension';
        ilProd.GenString25__c = 'Test Item Type';
        ilProd.GenString26__c = 'Test IPR Item Code';
        ilProd.GenString27__c = null;
        ilProd.GenString28__c = 'UPID';
        
        ilProd.NumField1__c = 1;
        ilProd.NumField2__c = 0;
        ilProd.NumField3__c = 1234;
        ilProd.NumField4__c = 3456;

        ilProd.NumField5__c = 1;
        ilProd.NumField7__c = 123;
        ilProd.NumField8__c = 456;
        ilProd.NumField9__c = 789;
        ilProd.NumField10__c = 1011;
        ilProd.NumField11__c = 1213;
        ilProd.NumField12__c = 1415;
        ilProd.NumField13__c = 1617;
        ilProd.NumField14__c = 1819;
        ilProd.NumField15__c = 2021;
        ilProd.NumField16__c = 2223;
        ilProd.NumField17__c = 2425;
        ilProd.NumField18__c = 1;
        ilProd.NumField19__c = 2829;
        ilProd.NumField20__c = 3031;
        ilProd.NumField21__c = 3233;
        ilProd.NumField22__c = 3435;

        ilProd.DateField1__c = DateTime.now();
        ilProd.DateField2__c = DateTime.newInstance(2014, 1, 25);
        ilProd.DateField3__c = DateTime.newInstance(2015, 2, 20);
        ilProd.LongString1__c = 'EUR;GBP';
        ilProd.LongString2__c = 'Test Long String Description for third party vendor blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah';
        ilProd.RecordTypeId = TestIntegrationLogUtils.GetIntLogProductRecTypeId();
        return ilProd;
    }
    
    private static void compareIntLogandProdRecords(Integration_Log__c ilProd, Product2 p)
    {
        //System.assertEquals(p.Description,ilProd.GenString1__c);
        System.assertEquals(p.ProductCode,ilProd.GenString2__c);
        System.assertEquals(p.Product_Family_Misys__c,ilProd.GenString3__c);
        System.assertEquals(p.Product_Codes_Sun__c,ilProd.GenString4__c);
        System.assertEquals(p.Business_Area__c,ilProd.GenString5__c);
        System.assertEquals(p.Business_Area_Scope__c,ilProd.GenString6__c);
        System.assertEquals(p.IPR_Owner_Cognos__c,ilProd.GenString7__c);
        System.assertEquals(p.IPR_Owner_Sun__c,ilProd.GenString8__c);
        System.assertEquals(p.Family, ilProd.GenString10__c);
        System.assertEquals(p.Product_Set__c, ilProd.GenString11__c);
        System.assertEquals(p.Line_of_Business__c, ilProd.GenString12__c);
     //   System.assertEquals(p.Acct_By_Sub__c, ilProd.GenString13__c);
     // System.assertEquals(p.NS_3PP_Vendor_Name__c, ilProd.GenString13__c);
        System.assertEquals(p.NS_Item_Name__c, ilProd.GenString14__c);
        System.assertEquals(p.NS_Tax_Schedule__c, ilProd.GenString15__c);
        System.assertEquals(p.NS_Item_Category__c, 'cat1');
        System.assertEquals(p.NS_Item_Sub_Category_1__c, 'subCat1');
        System.assertEquals(p.NS_Item_Sub_Category_2__c, 'subCat2');
        System.assertEquals(p.NS_Cost_Centre__c, ilProd.GenString17__c);
        System.assertEquals(p.NS_Income_Account__c, ilProd.GenString18__c);
        System.assertEquals(p.NS_Deferred_Revenue_Acct__c, ilProd.GenString19__c);
        System.assertEquals(p.NS_Accrued_Income_Acct__c, ilProd.GenString20__c);
        System.assertEquals(p.NS_Rev_Rec_Template__c, ilProd.GenString21__c);
        System.assertEquals(p.NS_Expense_Acct__c, ilProd.GenString22__c);
        System.assertEquals(p.NS_Deferred_Expense_Acct__c, ilProd.GenString23__c);
        System.assertEquals(p.NS_Product_Dimension__c, ilProd.GenString24__c);
        System.assertEquals(p.NS_Item_Type__c, ilProd.GenString25__c);
        System.assertEquals(p.NS_IPR_Item_Code__c, ilProd.GenString26__c);
        System.assertEquals(p.UPID__c, ilProd.GenString28__c);
        
        System.assert(p.IsActive);
        System.assertEquals(p.Payaway__c,false);
        System.assertEquals(p.Coral_ProdNo__c,ilProd.NumField3__c);
        System.assertEquals(p.Coral_PCID__c,ilProd.NumField4__c);
        
        //System.assertEquals(p.IsAsset__c, ilProd.NumField5__c == 1);
        System.assertEquals(p.NS_Item_Category_ID__c, ConversionUtils.IntToString(ilProd.NumField7__c));
        System.assertEquals(p.NS_Item_Sub_Category_1_ID__c, ConversionUtils.IntToString(ilProd.NumField8__c));
        System.assertEquals(p.NS_Item_Sub_Category_2_ID__c, ConversionUtils.IntToString(ilProd.NumField9__c));
        System.assertEquals(p.NS_Cost_Centre_ID__c, ConversionUtils.IntToString(ilProd.NumField10__c));
        System.assertEquals(p.NS_Income_Account_ID__c, ConversionUtils.IntToString(ilProd.NumField11__c));
        System.assertEquals(p.NS_Deferred_Revenue_Acct_ID__c, ConversionUtils.IntToString(ilProd.NumField12__c));
        System.assertEquals(p.NS_Accrued_Income_Acct_ID__c, ConversionUtils.IntToString(ilProd.NumField13__c));
        System.assertEquals(p.NS_Rev_Rec_Template_ID__c, ConversionUtils.IntToString(ilProd.NumField14__c));
        System.assertEquals(p.Display_Seq_Number__c, ConversionUtils.IntToString(ilProd.NumField15__c));
        System.assertEquals(p.NS_Expense_Acct_ID__c, ConversionUtils.IntToString(ilProd.NumField16__c));
        System.assertEquals(p.NS_Deferred_Expense_Acct_ID__c, ConversionUtils.IntToString(ilProd.NumField17__c));
        System.assert(p.GA__c);
        System.assertEquals(p.NS_Product_Dimension_ID__c, ConversionUtils.IntToString(ilProd.NumField19__c));
        System.assertEquals(p.NS_Item_Type_ID__c, ConversionUtils.IntToString(ilProd.NumField20__c));
        System.assertEquals(p.NS_IPR_Split_Percentage__c, ilProd.NumField22__c * 100);
        
        System.assertEquals(p.Date_Coral_Update__c, ilProd.DateField1__c);
        System.assertEquals(p.GA_Estimated_Date__c, ilProd.DateField2__c.date());
        System.assertEquals(p.GA_Avail_Date__c, ilProd.DateField3__c.date());
        System.assertEquals(p.Third_Party_Vendor_Description__c, ilProd.LongString2__c);
    }
    
    private static Integration_Log__c updateProductIL(Id prodIdToUpdate)
    {
        Integration_Log__c ilUpdate = new Integration_Log__c();
        ilUpdate.SFDC_Id__c = prodIdToUpdate;
        ilUpdate.GenString1__c = 'Changed Name';
        ilUpdate.GenString2__c = 'Test Code';
        ilUpdate.GenString3__c = 'Test PF';
        ilUpdate.GenString4__c = 'Test SC';
        ilUpdate.NumField1__c = 1;
        ilUpdate.NumField2__c = 0;
        ilUpdate.GenString5__c = 'Bus Area';
        ilUpdate.GenString6__c = 'Bus Area Scope';
        ilUpdate.GenString7__c = 'Owner Cognos';
        ilUpdate.GenString8__c = 'Owner Sun';
        ilUpdate.NumField3__c = 1234;
        ilUpdate.NumField4__c = 3456;
        ilUpdate.DateField1__c = DateTime.now();
        ilUpdate.LongString1__c = 'EUR;GBP';
        ilUpdate.RecordTypeId = TestIntegrationLogUtils.GetIntLogProductRecTypeId();
        return ilUpdate;
    }
    
    public static testmethod void testIntegration_PMPRODREC()
    {
        List<Integration_Log__c> testLogs = new List<Integration_Log__c>();
        
        //Run the process for the test
        Test.startTest();
        system.RunAs(TestIntegrationLogUtils.GetIntegrationUser()){
            // create product
            Integration_Log__c ilProd = createProductIL();
            insert ilProd;
            
            // verify success
            Integration_Log__c ilInserted = TestIntegrationLogUtils.QueryIL(ilProd.Id);
            System.debug(LoggingLevel.Error, '@@@ ilInserted: ' + ilInserted);
          //  System.assert(ilInserted.isSuccess__c);
          //System.assertEquals(ilInserted.Status__c,'Success');
            
            // query inserted product
            Product2 p = TestIntegrationLogUtils.QueryProdByName(ilProd.GenString1__c);

            // check that details match
            compareIntLogandProdRecords(ilProd, p);
            
            // try to update the product
            Integration_Log__c ilUpdate = updateProductIL(p.Id);
            insert ilUpdate;
            
            // verify success
            Integration_Log__c ilAfterUpdate = TestIntegrationLogUtils.QueryIL(ilUpdate.Id);
            System.assert(ilAfterUpdate.isSuccess__c);
            System.assertEquals(ilAfterUpdate.Status__c,'Success');
            
            // check that product got updated 
            p = TestIntegrationLogUtils.QueryProdById(p.Id);
            System.AssertEquals(p.Name, ilUpdate.GenString1__c);
            
        }
        Test.stopTest();
    }

}