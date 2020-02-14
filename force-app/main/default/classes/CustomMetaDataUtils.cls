public class CustomMetaDataUtils {
	
    public static SO_Advance_Day__mdt getSoAdvDayRecord(){
        list<SO_Advance_Day__mdt> soDay = [SELECT Id, DeveloperName, No_of_Advance_Days__c, No_of_Arrears_Days__c, Label, QualifiedApiName, Language FROM SO_Advance_Day__mdt limit 1];
        If(soDay.isEmpty()) return null;
        else return soDay[0];        
    }
}