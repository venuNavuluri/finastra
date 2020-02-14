@isTest
private class DataCategoryInfoTestClass {

 static testMethod void validateDataCategoryInfoObject() {
  DataCategoryInfo dataCategoryInfo = new DataCategoryInfo('Products__c', 'Products__c', 'Products');
  System.assertEquals('Products__c',dataCategoryInfo.getName());
  System.assertEquals('Products__c',dataCategoryInfo.getLabel());
  System.assertEquals('Products',dataCategoryInfo.getDisplayName());
 }
}