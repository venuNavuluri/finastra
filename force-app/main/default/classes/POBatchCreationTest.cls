@isTest
public class POBatchCreationTest{

    static testMethod void createAndTestRecords(){

        /*************Account Record Creation****************************************/

        Account accountRecord = new Account();
        accountRecord.PO_Required__c = true;
        accountRecord.Purchase_Order_Type__c = 'Required for Invoice';
        accountRecord.Name = generateString(5);

        insert accountRecord;

        /**************Opportunity Record Creation************************************/

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Name = String.valueOf(system.today().year() + 1 + ' ' + 'Annual Increase');
        opportunityRecord.AccountId = accountRecord.Id;
        OpportunityRecord.StageName = 'Prospecting';
        OpportunityRecord.CloseDate = system.today();

        insert OpportunityRecord;

        system.assertEquals(OpportunityRecord.AccountId,accountRecord.Id);      // Assertion to check Opportunity Association with account


        /*****************System Record Creation******************************************/
        System__c systemRecd = new System__c();
        systemRecd.Account__c = accountRecord.id;

        insert systemRecd;

        /*******************AccountBySub Record Creation**********************************/
        Acct_By_Sub__c accountbySub = new Acct_By_Sub__c();
        accountbySub.Account__c = accountRecord.Id;
        accountbySub.Name = generateString(5);
        accountbySub.NS_Internal_Id__c = 'Test';

        insert accountbySub;

        /*********************Billing Entity Record Creation******************************/
        Billing_Entity__c billingEntity = new Billing_Entity__c();
        billingEntity.name = generateString(4);
        insert billingEntity;

        Billing_Entity__c billingEntity1 = new Billing_Entity__c();
        billingEntity1.name = generateString(5);
        insert billingEntity1;

        /***********************Billing Group Records Creation****************************/
        List<Billing_Group__c> billList =new List<Billing_Group__c>();
        for(Integer i = 0 ; i<=2 ;i++)
        {
            Billing_Group__c BG1 = new Billing_Group__c();
            BG1.BG_Client_Contracting_Name__c = accountRecord.Id;
            BG1.Account_by_Sub__c = accountbySub.id;
            BG1.BG_Misys_Billing_Entity__c = billingEntity.id;
            BG1.BG_Billing_Group_Active__c = true;
            billList.add(BG1);
        }
        insert billList;

        system.assertEquals(billList.size(),3);                    // Assertion to validate size of billing group been craeted


        /************************Billing Group Record Create with different Billing Entity**************/
        Billing_Group__c BG2 = new Billing_Group__c();
        BG2.BG_Client_Contracting_Name__c = accountRecord.Id;
        BG2.Account_by_Sub__c = accountbySub.id;
        BG2.BG_Misys_Billing_Entity__c = billingEntity1.id;
        BG2.BG_Billing_Group_Active__c = true;
        insert BG2;


        /************************Contract Asset Record Creation***************************************/
        Contract_Asset__c contractAsset = new Contract_Asset__c();
        contractAsset.name =generateString(5);
        contractAsset.Account__c = accountRecord.Id;
        contractAsset.System__c = systemRecd.id;
        contractAsset.CA_Billing_Status__c = 'Active billing';
        contractAsset.CA_Billing_Group__c = billList[0].id;


        insert contractAsset;

        Contract_Asset__c contractAsset1 = new Contract_Asset__c();
        contractAsset1.name =generateString(4);
        contractAsset1.Account__c = accountRecord.Id;
        contractAsset1.System__c = systemRecd.id;
        contractAsset1.CA_Billing_Status__c = 'Active billing';
        contractAsset1.CA_Billing_Group__c = BG2.id;


        insert contractAsset1;               // Insertion of Records End here



        /************************Setup Test **********************************************************/

        Test.startTest();


        /***********************Call Schedule Class**************************************************/
        POCreationBatchScheduled POSchedule = new POCreationBatchScheduled();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Territory Check', sch, POSchedule);

        /**********************Call Batch Class****************************************************/
        POCreationBatch POBatch = new POCreationBatch();
        Database.executeBatch(POBatch);

        Test.stopTest();       // End Setup Test

        // Testing If purchase Order create or Not related to Account
        List<Purchase_Order__c> purchaseOrderList = new List<Purchase_Order__c>([Select Id,Billing_Group_Id__c,Account__c from Purchase_Order__c
        where Account__c =:accountRecord.Id ORDER BY CreatedDate ASC]);


        system.assertEquals(purchaseOrderList.size(),2);                 // Assertion to validate the size of purchase order
        String BillingGroupId = String.valueOf(billList[0].Id) +','+  String.valueOf(billList[1].Id) +','+ String.valueOf(billList[2].Id) +',';


        /**********************************Assertion to validate the billing group Id for purchase order***********************/

        // NG purchaseOrderList may be retrieved in random order, so it might be useful to add 'order by'
        // to the query, otherwise assertions below might not work randomly

        system.assertEquals(purchaseOrderList[0].Billing_Group_Id__c,BillingGroupId);
        system.assertEquals(purchaseOrderList[1].Billing_Group_Id__c,String.ValueOf(BG2.id));
        
        List<Contract_Asset__c> contractAssetList = new List<Contract_Asset__c>([Select Id,Purchase_Order_Request__c from Contract_Asset__c where Purchase_Order_Request__c IN:purchaseOrderList ORDER BY CreatedDate ASC]);
        
         // NG the same remark as above
        system.assertEquals(contractAssetList[0].Purchase_Order_Request__c,purchaseOrderList[0].Id);
        system.assertEquals(contractAssetList[1].Purchase_Order_Request__c,purchaseOrderList[1].Id);

    }

    /*******************************Randon String Generator***************************************/
    public static String generateString(Integer len){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while(randStr.length() < len){
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }






}