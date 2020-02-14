@isTest
private class DataCategoryGroupInfoTestClass {

 static testMethod void validateDataCategoryGroupInfoObject(){
  DataCategoryInfo[] structure = new DataCategoryInfo[1];
  structure[0] = new DataCategoryInfo('Product','Product__c','Product__c');
  DataCategoryGroupInfo dataCategoryGroupInfo = new DataCategoryGroupInfo('Product','Product__c','Test DataCategoryInfoClass',structure);
  System.assertEquals('Product', dataCategoryGroupInfo.getName());
  System.assertEquals('Product__c', dataCategoryGroupInfo.getLabel());
  System.assertEquals('Test DataCategoryInfoClass', dataCategoryGroupInfo.getDescription());
  System.assertEquals(structure.size(),dataCategoryGroupInfo.getGroupStructure().size());
 }

}