/**
 * @File Name          : billingScheduleController.cls
 * @Description        :
 * @Author             : venu.navuluri@finastra.com
 * @Group              :
 * @Last Modified By   : venu.navuluri@finastra.com
 * @Last Modified On   : 06/02/2020, 12:24:25
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    09/12/2019   venu.navuluri@finastra.com     Initial Version
 **/
public with sharing class billingScheduleController {
  private static final String SEARCH_TERM = '%' + Constants.ILF + '%';

  /**
   * @description RUBX-3681 generating billing schedule record and child records, then update quote and ILF quotelines.
   * @author venu.navuluri@finastra.com | 2/4/2020
   * @param wrapper
   * @param quoteId
   * @param billingTerm
   * @param selectedLicenseSchedule
   * @return String
   **/
  @AuraEnabled
  public static String generateBillingScheduleItems(
    CustomWrapper wrapper,
    String quoteId,
    String billingTerm,
    String selectedLicenseSchedule
  ) {
    String result, eMsg;
    Boolean isBillingScheduleCreated = false;
    Boolean isBillingScheduleItemsCreated = false;
    savepoint sp = Database.setSavepoint();
    Billing_Schedule__c obs = new Billing_Schedule__c(
      ProdType__c = Constants.ILF,
      Quote__c = quoteId
    );
    try {
      insert obs;
      isBillingScheduleCreated = true;
      result = obs.Id;
    } catch (Exception ex) {
      eMsg =
        'Error at line # ' +
        ex.getLineNumber() +
        ' cause => ' +
        ex.getMessage() +
        ' class name ' +
        ex.getStackTraceString();
      Database.rollback(sp);
      return eMsg;
    }

    if (isBillingScheduleCreated) {
      List<Billing_Schedule_Item__c> newItems = new List<Billing_Schedule_Item__c>();

      for (Integer i = 0; i < Wrapper.itemList.size(); i++) {
        Billing_Schedule_Item__c bsItem = new Billing_Schedule_Item__c(
          Billing_Schedule__c = obs.id,
          Name = Wrapper.itemList[i].Name,
          Percentage__c = Wrapper.itemList[i].Percentage
        );
        newItems.add(bsItem);
      }

      if (!newItems.isEmpty()) {
        try {
          insert newItems;
          isBillingScheduleItemsCreated = true;
        } catch (Exception ex) {
          eMsg =
            'Error at line # ' +
            ex.getLineNumber() +
            ' cause => ' +
            ex.getMessage() +
            ' class name ' +
            ex.getStackTraceString();
          Database.rollback(sp);
          return eMsg;
        }
      }
    }

    if (isBillingScheduleItemsCreated) {
      try {
        updateQuote_QuoteLine(quoteId, obs.id, selectedLicenseSchedule);
      } catch (Exception ex) {
        eMsg =
          'Error at line # ' +
          ex.getLineNumber() +
          ' cause => ' +
          ex.getMessage() +
          ' class name ' +
          ex.getStackTraceString();
        Database.rollback(sp);
        return eMsg;
      }
    }
    return result;
  }

  /**
   * @description RUBX-3681 returns standard custom metadata
   * @author Venu Navuluri | 25/01/2020
   * @param billingTerm
   * @return List<Standard_Billing_Schedule__mdt>
   **/
  @AuraEnabled(cacheable=true)
  public static List<Standard_Billing_Schedule__mdt> getILFStandardTerms(
    String billingTerm
  ) {
    return [
      SELECT Milestone_Name__c, Percentage__c
      FROM Standard_Billing_Schedule__mdt
      WHERE Billing_Term__c = :billingTerm AND ProdType__c = :Constants.ILF
    ];
  }
  /**
   * @description RUBX-3681 returns existing billing schedule items
   * @author Venu Navuluri | 25/01/2020
   * @param quoteId
   * @return List<Billing_Schedule_Item__c>
   **/
  @AuraEnabled(cacheable=true)
  public static List<Billing_Schedule_Item__c> getExistingILFStandardTerms(
    Id quoteId
  ) {
    return [
      SELECT Name, Percentage__c
      FROM Billing_Schedule_Item__c
      WHERE
        Billing_Schedule__r.Quote__c = :quoteId
        AND Billing_Schedule__r.ProdType__c = :Constants.ILF
    ];
  }
  /**
   * @description RUBX-3681 updated Quote and assign billing schedule id to all related quote lines
   * @author Venu Navuluri | 25/01/2020
   * @param quoteId, bsId
   * @return void
   **/
  @AuraEnabled
  public static void updateQuote_QuoteLine(
    Id quoteId,
    Id bsId,
    String selectedLicenseSchedule
  ) {
    //selectedLicenseSchedule
    SBQQ__Quote__c uQuote = new SBQQ__Quote__c(
      Id = quoteId,
      License_Billing_Terms__c = selectedLicenseSchedule
    );

    try {
      update uQuote;
    } catch (Exception e) {
      AuraHandledException auraException = new AuraHandledException(
        e.getMessage()
      );
      auraException.setMessage(e.getMessage());
      throw auraException;
    }
    SBQQ__QuoteLine__c[] qLine_list = [
      SELECT Id, ProdType__c, Billing_Schedule__c
      FROM SBQQ__QuoteLine__c
      WHERE SBQQ__quote__c = :quoteId AND ProdType__c LIKE :SEARCH_TERM
      FOR UPDATE
    ];
    List<SBQQ__QuoteLine__c> updatedList = new List<SBQQ__QuoteLine__c>();
    for (SBQQ__QuoteLine__c ql : qLine_list) {
      updatedList.add(
        new SBQQ__QuoteLine__c(Id = ql.Id, Billing_Schedule__c = bsId)
      );
    }
    if (updatedList.size() > 0) {
      try {
        update updatedList;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
  }
}
