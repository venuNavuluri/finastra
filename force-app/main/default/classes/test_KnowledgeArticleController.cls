@isTest(SeeAllData=true)
private class test_KnowledgeArticleController {
  private static Account testAccount1 = TestUtility.sampleAccount();
    private static Account testAccount2 = TestUtility.sampleAccount();
    private static Contact testContact1  = TestUtility.sampleContact(); 
    private static User testUser = TestUtility.sampleUser();
    private static System__c testSystem1 = new System__c();
    private static CCRT__c testCCRT1   = new CCRT__c();        
    private static Product_Set__c testPS1 = new Product_Set__c(); 
    private static Entitlement__c testEnt1 = new Entitlement__c(); 
    
    //No Contract Assets for this test      
    private static RecordType rt  = [select Id from RecordType where sObjectType = 'Case' LIMIT 1]; 
    private static List<Constants__c> custSettings = new List<Constants__c>();

   @isTest static void createTestData(){

      insert testAccount1;
      testAccount2.Name = 'Test Account2';
      insert testAccount2;
      
      //Contact testContact1 = TestUtility.sampleContact();
      testContact1.AccountId = testAccount1.Id;
      testContact1.Inactive_Contact__c = false;
      insert testContact1;

     // testUser.ContactId = testContact1.id;
      //insert testUser;
      
      //System__c testSystem1 = new System__c();
      testSystem1.Account__c = testAccount1.Id;
      testSystem1.Environment2__c = 'PROD';
      testSystem1.Name = 'TS1';
      insert testSystem1;
      
      //CCRT__c testCCRT1 = new CCRT__c();
      testCCRT1.Account__c = testAccount1.Id;
      testCCRT1.Client_Site_Number__c = 'A123456';
      insert testCCRT1;
      
      //Product_Set__c testPS1 = new Product_Set__c();
      testPS1.Account__c = testAccount1.Id;
      testPS1.Business_Group__c = 'BG1';
      testPS1.Production__c = true;
      insert testPS1;
      
      //Entitlement__c testEnt1 = new Entitlement__c();
      testEnt1.Account__c = testAccount1.Id;
      testEnt1.Product_Set__c = testPS1.Id;
      testEnt1.System__c = testSystem1.Id;
      testEnt1.Status__c = 'Active';
      insert testEnt1;

      custSettings.add(new Constants__c(Name='DEFAULT_INTERNAL_SEVERITY', ExternalId__c='DEFAULT_INTERNAL_SEVERITY', Value__c='3'));
      custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN', ExternalId__c='DEFAULT_ORIGIN', Value__c='Email'));
      custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN_PORTAL', ExternalId__c='DEFAULT_ORIGIN_PORTAL', Value__c='Web'));
      custSettings.add(new Constants__c(Name='DEFAULT_URGENCY', ExternalId__c='DEFAULT_URGENCY', Value__c='3'));
      custSettings.add(new Constants__c(Name='DEFAULT_SEVERITY', ExternalId__c='DEFAULT_SEVERITY', Value__c='Medium'));
      custSettings.add(new Constants__c(Name='DEFAULT_STATUS', ExternalId__c='DEFAULT_STATUS', Value__c='New'));
      custSettings.add(new Constants__c(Name='DEFAULT_TYPE', ExternalId__c='DEFAULT_TYPE', Value__c='Technical'));
      custSettings.add(new Constants__c(Name='DUMMY PRODUCT SET ID', ExternalId__c='DUMMY PRODUCT SET ID', Value__c=testPS1.Id));
      custSettings.add(new Constants__c(Name='DEFAULT_CASE_RECORDTYPE_ID', ExternalId__c='DEFAULT_CASE_RECORDTYPE_ID', Value__c=rt.Id));
      //insert custSettings;
    }
  
  @isTest static void test_method_documentation() {
    User adminUser = TestUtils.getAdminUser('admin');
        adminUser.UserPermissionsKnowledgeUser = true;
        Documentation__kav a;
        
        System.runAs(adminUser){
           //create the kav instance
            a = new   Documentation__kav(
                    Additional_Product_Component__c = 'test apex',
                    Title = 'test',
                    UrlName = 'test67876478643786348'
            );
    
            insert a;
            //retrieve master article Id created on FAQ__kav record insertion
            //in order to get the KnowledgeArticleId
            a = [SELECT KnowledgeArticleId FROM Documentation__kav WHERE Id = :a.Id];
             //publish it
            KbManagement.PublishingService.publishArticle(a.KnowledgeArticleId, true);
        }
        Test.startTest();
          createTestData();
          pageReference pageRef = Page.community_KnowledgeArticle; 
      
      pageRef.getParameters().put('id',a.KnowledgeArticleId);
      Test.setCurrentPage(pageRef);
      community_KnowledgeArticleController kac = new community_KnowledgeArticleController();
        test.stopTest();
  }
  
  @isTest static void test_method_troubleshooting() {
    User adminUser = TestUtils.getAdminUser('admin');
    Troubleshooting__kav a;
        adminUser.UserPermissionsKnowledgeUser = true;
        
        System.runAs(adminUser){
           //create the kav instance
             a = new   Troubleshooting__kav(
                    Additional_Product_Component__c = 'test apex',
                    Title = 'test',
                    UrlName = 'test67876478643786348'
            );
    
            insert a;
            //retrieve master article Id created on FAQ__kav record insertion
            //in order to get the KnowledgeArticleId
            a = [SELECT KnowledgeArticleId FROM Troubleshooting__kav WHERE Id = :a.Id];
             //publish it
            KbManagement.PublishingService.publishArticle(a.KnowledgeArticleId, true);
       // }
        
        //System.runAs(testUSer){
          createTestData();
          System.debug('@@@@@KA' + a.KnowledgeArticleId);
          
          
      Test.startTest();
      
          pageReference pageRef = Page.community_KnowledgeArticle; 
      pageRef.getParameters().put('id',a.KnowledgeArticleId);
      Test.setCurrentPage(pageRef);
      community_KnowledgeArticleController kac = new community_KnowledgeArticleController();
      kac.getItems();
      kac.getRatings();
      kac.SaveUserViews();
      kac.strRating = '4';
      kac.submit();
    //    }
          
          test.stopTest();
        }
  }
  
}