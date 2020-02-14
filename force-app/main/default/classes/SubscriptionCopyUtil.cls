public class SubscriptionCopyUtil {
    public static List<SBQQ__Subscription__c> copyFieldValuesFromSovosTax(List<SBQQ__Subscription__c> subsToUpdate) {
        List<Schema.FieldSetMember> copyFields = getFieldSet('Copy_Fields');
        List<Schema.FieldSetMember> queryFieldSet = getFieldSet('Query_Field_Set');
        Map<String, Sovos_Tax_Determination__c> sovosTaxMap = getSovosTaxMap(copyFields, queryFieldSet);
        string key = '';
        for(SBQQ__Subscription__c sub : subsToUpdate) {
            key = '';
            for(Schema.FieldSetMember f : queryFieldSet) {
                key += sub.get(f.getFieldPath());
            }
            if(sovosTaxMap.get(key) != null) {
                for(Schema.FieldSetMember f : copyFields) {
                    sub.put(f.getFieldPath(), sovosTaxMap.get(key).get(f.getFieldPath()));
                }
            }
        }
        if(!subsToUpdate.isEmpty()) {
            return subsToUpdate;
        }
        return null;
    }
    
    private static List<Schema.FieldSetMember> getFieldSet(String fieldSetName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('SBQQ__Subscription__c');
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();
    }
    private static Map<String, Sovos_Tax_Determination__c> getSovosTaxMap(List<Schema.FieldSetMember> copyFields, List<Schema.FieldSetMember> queryFields){
        Map<String, Sovos_Tax_Determination__c> sTaxMap = new Map<String, Sovos_Tax_Determination__c>();
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : copyFields) {
            query += f.getFieldPath() + ', ';
        }
        for(Schema.FieldSetMember f : queryFields) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id FROM Sovos_Tax_Determination__c';
        
        List<Sovos_Tax_Determination__c> sTaxs = Database.query(query);
        
        String key='';
        for(Sovos_Tax_Determination__c sTax : sTaxs) {
            key='';
            for(Schema.FieldSetMember f : queryFields) {
                key += sTax.get(f.getFieldPath());
            }
            sTaxMap.put(key,sTax);
        }
        return sTaxMap;
    }    
}