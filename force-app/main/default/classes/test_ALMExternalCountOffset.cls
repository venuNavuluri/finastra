/**
 * Created by Nina Gronowska on 15/09/2017.
 */

@isTest
private class test_ALMExternalCountOffset{

    @isTest
    public static void shouldUpdateExternalId(){
        ALM_External_Count_Offset__c offsetRecord = new ALM_External_Count_Offset__c();
        offsetRecord.External_ID_Source__c = 'ABC';
        offsetRecord.External_ID__c = '123';
        insert offsetRecord;
        ALM_External_Count_Offset__c result = [select id, External_Source_ID_Concatenated__c from ALM_External_Count_Offset__c where id = :offsetRecord.Id];
        system.assertEquals('ABC123',result.External_Source_ID_Concatenated__c);
    }
}