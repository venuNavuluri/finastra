@isTest
private class CustomMetaDataUtils_Test{    
    @isTest static void test_getSoAdvDayRecord1(){
        test.startTest();
        List<SO_Advance_Day__mdt> so_advance_day_mdt_Obj  =  [SELECT Id,DeveloperName,MasterLabel,Language,NamespacePrefix,Label,QualifiedApiName,No_of_Advance_Days__c,No_of_Arrears_Days__c from SO_Advance_Day__mdt];
        System.assertEquals(true,so_advance_day_mdt_Obj.size()>0);
        CustomMetaDataUtils obj01 = new CustomMetaDataUtils();
        CustomMetaDataUtils.getSoAdvDayRecord();
        test.stoptest();
    }
    @isTest static void test_getSoAdvDayRecord2(){
        test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
        List<SO_Advance_Day__mdt> so_advance_day_mdt_Obj  =  [SELECT Id,DeveloperName,MasterLabel,Language,NamespacePrefix,Label,QualifiedApiName,No_of_Advance_Days__c,No_of_Arrears_Days__c from SO_Advance_Day__mdt];
        System.assertEquals(true,so_advance_day_mdt_Obj.size()>0);
        CustomMetaDataUtils obj01 = new CustomMetaDataUtils();
        CustomMetaDataUtils.getSoAdvDayRecord();
        }
        test.stoptest();
    }
}