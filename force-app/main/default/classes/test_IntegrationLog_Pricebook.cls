@isTest(SeeAllData=true)
public class test_IntegrationLog_Pricebook
{
    private static Pricebook2 nonstdPB;
    private static PricebookEntry queryPBE(Id prodId)
    {
        PricebookEntry pbe = [
            select Id, Pricebook2Id, Product2Id,
                CurrencyIsoCode, UnitPrice, UseStandardPrice,
                IsActive
            from PricebookEntry
            where Product2Id = :prodId
            and Pricebook2Id = :GetNonStandardPricebookId()
            and CurrencyIsoCode = 'USD'
        ];
        return pbe;
    }
    
    private static Integration_Log__c queryPBEIntLog(Id pbeId)
    {   
        Integration_Log__c pbeIL = [
            Select Id, isSuccess__c, Status__c, Message__c,
                GenString3__c, GenString4__c, GenString5__c,
                NumField5__c, NumField6__c, NumField1__c
            from Integration_Log__c where Id = :pbeId
        ];
        return pbeIL;
    }
    
    private static Integration_Log__c createPBEIntLog(Id prodId)
    {
        Integration_Log__c ilPBE = new Integration_Log__c();
        ilPBE.GenString3__c = GetNonStandardPricebookId();
        ilPBE.GenString4__c = prodId;
        ilPBE.GenString5__c = 'USD';
        ilPBE.NumField5__c = 100;
        ilPBE.NumField6__c = 0;
        ilPBE.NumField1__c = 1;
        ilPBE.isSuccess__c=true;
        ilPBE.Status__c='Success';
        ilPBE.RecordTypeId = TestIntegrationLogUtils.GetIntLogPricebookRecTypeId();
        return ilPBE;
    }
    
    private static Integration_Log__c updatePBEIntLog(Id pbeId, Id prodId)
    {
        Integration_Log__c ilPBEUpdate = new Integration_Log__c();
        ilPBEUpdate.SFDC_Id__c = pbeId;
        ilPBEUpdate.GenString3__c = GetNonStandardPricebookId();
        ilPBEUpdate.GenString4__c = prodId;
        ilPBEUpdate.GenString5__c = 'USD';
        ilPBEUpdate.NumField5__c = 200;
        ilPBEUpdate.NumField6__c = 0;
        ilPBEUpdate.NumField1__c = 1;
        ilPBEUpdate.RecordTypeId = TestIntegrationLogUtils.GetIntLogPricebookRecTypeId();
        return ilPBEUpdate;
    }
    
    private static void validatePBE(PricebookEntry pbe, Id prodId)
    {
        System.assertEquals(pbe.Pricebook2Id,GetNonStandardPricebookId());
        System.assertEquals(pbe.Product2Id, prodId);
        System.assertEquals(pbe.CurrencyIsoCode, 'USD');
        System.assertEquals(pbe.UnitPrice, 100);
        System.assertEquals(pbe.UseStandardPrice, false);
        System.assertEquals(pbe.IsActive, true);
    }
    
    public static testmethod void testIntegration_PMPBENTRY()
    {
        
        Test.startTest();
            system.RunAs(TestIntegrationLogUtils.GetIntegrationUser()){
            Product2 p = TestUtility.sampleProduct();
            insert p;
                Integration_Log__c ilPBE = createPBEIntLog(p.Id);
                insert ilPBE;
                   
                ilPBE = queryPBEIntLog(ilPBE.Id);
                System.debug('XXX : ' + ilPBE.Message__c);
                System.debug('XXX ilPBE.isSuccess__c -->>: ' + ilPBE.isSuccess__c);
                System.debug('XXX ilPBE.ilPBE.Status__c-->>: ' + ilPBE.Status__c);
//                System.assert(ilPBE.isSuccess__c);
//                System.assertEquals(ilPBE.Status__c,'Success');
                
                PricebookEntry pbe = queryPBE(p.Id);
                validatePBE(pbe, p.Id);
    
                Integration_Log__c ilPBEUpdate = updatePBEIntLog(pbe.Id, p.Id);
                insert ilPBEUpdate;
                
                ilPBEUpdate = [Select Id, isSuccess__c, Status__c, Message__c from Integration_Log__c where Id = :ilPBEUpdate.Id];
                System.debug('XXX ilPBEUpdate isSuccess -->> : ' + ilPBEUpdate.isSuccess__c);
          //      System.assert(ilPBEUpdate.isSuccess__c);
                
                pbe = [select Id, UnitPrice from PricebookEntry where Id = :pbe.Id];
                System.assertEquals(pbe.UnitPrice, 200);
            }
        Test.stopTest();
    }

    public static Id GetNonStandardPricebookId()
    {
        if (nonstdPB == null) {
            List<Pricebook2> nonstdPBId = [select Id from Pricebook2 where IsStandard = false limit 1];
            nonstdPB=nonstdPBId[0];
            //nonstdPB = new Pricebook2(Name = 'Test');
            //insert nonstdPB;
        }
        return nonstdPB.Id;
    }
}