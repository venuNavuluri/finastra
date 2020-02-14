/**
 * @File Name          : billingScheduleControllerTest.cls
 * @Description        :
 * @Author             : venu.navuluri@finastra.com
 * @Group              :
 * @Last Modified By   : venu.navuluri@finastra.com
 * @Last Modified On   : 05/02/2020, 12:46:55
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    1/27/2020   venu.navuluri@finastra.com     Initial Version
 **/
@isTest
private with sharing class billingScheduleControllerTest {
  private static final string ILF = 'ILF';
  private static final string FEILD_MISSING = 'Reguired Field missing';
  private static final string EXCEPTION_MESSAGE = 'Exception message triggered';
  private static final string Standard = 'Standard';
  private static final string BILLING_TERM = 'Billing Term - 1';

  /**
   * @description test data setup
   * @author Venu Navuluri | 27/01/2020
   * @return Quote
   **/
  private static SBQQ__Quote__c createQuote() {
    List<Opportunity> opps = TestDataFactory.CreateOpportunities(1, 200, true);
    SBQQ__Quote__c Quote = TestDataFactory.createSBQQuote(opps[0], false, true);
    return Quote;
  }
  /**
   * @description test method to return custom metadata records
   * @author Venu Navuluri | 27/01/2020
   * @return Quote
   **/
  private static testMethod void getILFStandardTermsTest() {
    test.startTest();
    List<Standard_Billing_Schedule__mdt> standardSchedules = [
      SELECT
        Id,
        DeveloperName,
        MasterLabel,
        Language,
        NamespacePrefix,
        Label,
        QualifiedApiName,
        Milestone_Name__c,
        Percentage__c
      FROM Standard_Billing_Schedule__mdt
    ];
    System.assertEquals(true, standardSchedules.size() > 0);
    billingScheduleController bs = new billingScheduleController();
    billingScheduleController.getILFStandardTerms(ILF);
    test.stoptest();
  }
  /**
   * @description test method to return billing schedule items for quote
   * @author Venu Navuluri | 27/01/2020
   * @return Quote
   **/
  private static testMethod void getExistingILFStandardTermsTest() {
    SBQQ__Quote__c Quote = createQuote();
    List<Billing_Schedule_Item__c> billingSchedules = new List<Billing_Schedule_Item__c>();
    Billing_Schedule__c bs = TestDataFactory.createBillingSchedule(
      true,
      Quote.Id,
      ILF
    );
    for (Integer count = 0; count < 50; count++) {
      billingSchedules.add(
        new Billing_Schedule_Item__c(
          Name = 'test' + count,
          Billing_Schedule__c = bs.id,
          Percentage__c = 100
        )
      );
    }
    insert billingSchedules;
    List<Billing_Schedule_Item__c> itemRecords;
    Test.startTest();
    itemRecords = billingScheduleController.getExistingILFStandardTerms(
      Quote.id
    );
    Test.StopTest();
    System.assertEquals(50, itemRecords.size());
  }
  /**
   * @description Positive test method to update Quote and Quote Lines
   * @author Venu Navuluri | 27/01/2020
   * @return Quote
   **/
  private static testMethod void updateQuote_QuoteLine_PositiveTest() {
    SBQQ__Quote__c Quote = createQuote();
    Billing_Schedule__c bs = TestDataFactory.createBillingSchedule(
      true,
      Quote.Id,
      ILF
    );

    Product2 prod = TestDataFactory.createProduct(ILF, true);
    List<SBQQ__QuoteLine__c> quoteLinesList = TestDataFactory.createSBQQuoteLines(
      10,
      Quote.Id,
      prod.Id,
      ILF,
      true
    );

    Test.startTest();
    billingScheduleController.updateQuote_QuoteLine(Quote.Id, bs.id, Standard);
    Test.StopTest();

    System.assertEquals(
      Standard,
      [
        SELECT Id, License_Billing_Terms__c
        FROM SBQQ__Quote__c
        WHERE Id = :Quote.Id
      ]
      .License_Billing_Terms__c
    );

    System.assertEquals(
      bs.id,
      [
        SELECT Id, Billing_Schedule__c
        FROM SBQQ__QuoteLine__c
        WHERE Id = :quoteLinesList[0].Id
      ]
      .Billing_Schedule__c
    );
  }
  /**
   * @description Negative test method to update Quote and Quote Lines
   * @author Venu Navuluri | 27/01/2020
   * @return Quote
   **/
  private static testMethod void updateQuote_QuoteLine_NegativeTest() {
    Test.startTest();
    try {
      billingScheduleController.updateQuote_QuoteLine(null, null, Standard);
    } catch (Exception ex) {
    }
    Test.StopTest();
  }
  /**
   * * @description: Unit test method for generateBillingScheduleItems method
   * @author venu.navuluri@finastra.com | 05/02/2020
   * @return testMethod
   **/
  private static testMethod void generateBillingScheduleItems_PositiveTest() {
    SBQQ__Quote__c Quote = createQuote();

    Product2 prod = TestDataFactory.createProduct(ILF, true);
    List<SBQQ__QuoteLine__c> quoteLinesList = TestDataFactory.createSBQQuoteLines(
      10,
      Quote.Id,
      prod.Id,
      ILF,
      true
    );

    CustomWrapper.InnerWrapper wrap1 = new CustomWrapper.InnerWrapper();
    wrap1.Name = Standard;
    wrap1.Percentage = 50;

    CustomWrapper.InnerWrapper wrap2 = new CustomWrapper.InnerWrapper();
    wrap2.Name = Standard;
    wrap2.Percentage = 50;

    List<CustomWrapper.InnerWrapper> itemList = new List<CustomWrapper.InnerWrapper>{
      wrap1,
      wrap2
    };
    CustomWrapper cw = new CustomWrapper();
    cw.itemList = itemList;

    string bSch;
    Test.startTest();
    bSch = billingScheduleController.generateBillingScheduleItems(
      cw,
      Quote.id,
      null,
      Standard
    );
    Test.StopTest();

    System.assertEquals(bSch, [SELECT id FROM Billing_Schedule__c LIMIT 1].Id);
  }

  /**
   * @description: Negative test method for generateBillingScheduleItems method
   * @author venu.navuluri@finastra.com | 05/02/2020
   * @return testMethod
   **/
  private static testMethod void generateBillingScheduleItems_NegativeTest1() {
    SBQQ__Quote__c Quote = createQuote();

    Product2 prod = TestDataFactory.createProduct(ILF, true);
    List<SBQQ__QuoteLine__c> quoteLinesList = TestDataFactory.createSBQQuoteLines(
      10,
      Quote.Id,
      prod.Id,
      ILF,
      true
    );
    CustomWrapper.InnerWrapper wrap1 = new CustomWrapper.InnerWrapper();
    wrap1.Name = Standard;
    wrap1.Percentage = 50;

    CustomWrapper.InnerWrapper wrap2 = new CustomWrapper.InnerWrapper();
    wrap2.Name = Standard;

    List<CustomWrapper.InnerWrapper> itemList = new List<CustomWrapper.InnerWrapper>{
      wrap1,
      wrap2
    };
    CustomWrapper cw = new CustomWrapper();
    cw.itemList = itemList;
    string bSch;
    Test.startTest();
    bSch = billingScheduleController.generateBillingScheduleItems(
      cw,
      Quote.id,
      null,
      Standard
    );
    Test.StopTest();
    System.assertEquals(0, [SELECT COUNT() FROM Billing_Schedule__c]);
  }
  /**
   * @description: Negative test method to cover test coverage
   * @author venu.navuluri@finastra.com | 05/02/2020
   * @return testMethod
   **/
  private static testMethod void generateBillingScheduleItems_NegativeTest2() {
    CustomWrapper.InnerWrapper wrap1 = new CustomWrapper.InnerWrapper();
    wrap1.Name = Standard;
    wrap1.Percentage = 50;

    CustomWrapper.InnerWrapper wrap2 = new CustomWrapper.InnerWrapper();
    wrap2.Name = Standard;

    List<CustomWrapper.InnerWrapper> itemList = new List<CustomWrapper.InnerWrapper>{
      wrap1,
      wrap2
    };
    CustomWrapper cw = new CustomWrapper();
    cw.itemList = itemList;
    string bSch;
    Test.startTest();
    bSch = billingScheduleController.generateBillingScheduleItems(
      cw,
      null,
      null,
      Standard
    );
    Test.StopTest();
    System.assertEquals(0, [SELECT COUNT() FROM Billing_Schedule__c]);
  }
}
