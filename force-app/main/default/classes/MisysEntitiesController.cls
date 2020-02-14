/*
	Created By: Abhinit Kohar
	Created Date: 15/11/2013
	Description: This is the controller class for Misys_Entities visualforce page used in the Misys Entities site.
*/
public class MisysEntitiesController {
   
   //This method returns all the Misys Legal entities.
   public Billing_Entity__c[] getMisysEntities() {
        return [
                select name, Entity_Status__c, Primary_signatory__r.name, Preferred_signatory_1__r.name, Preferred_signatory_2__r.name, Preferred_signatory_3__r.name, 
					Preferred_signatory_4__r.name, Second_signatory__r.name, Second_signatory_2__r.Name, Alternative_signatory_1__r.name, Alternative_signatory_2__r.name, 
					Alternative_signatory_3__r.name, Alternative_signatory_4__r.name, Country_of_Incorporation__c, Company_Number__c, BE_Misys_Address_Name__c, 
					BE_Misys_Address_1__c, BE_Misys_Address_2__c, BE_Misys_Address_3__c, BE_Misys_Address_4__c, BE_Misys_Address_City__c, BE_Misys_Address_Country__c, 
					Alternative_signatory_1_role__c, Alternative_signatory_2_role__c, Alternative_signatory_3_role__c, Misys_Entity_Legal_Name__c,
					Alternative_signatory_4_role__c, Preferred_signatory_1_role__c, Preferred_signatory_2_role__c, Preferred_signatory_3_role__c, 
					Preferred_signatory_4_role__c, Primary_signatory_role__c, Second_signatory_role__c, BE_Misys_Address_Zip_Postal_Code__c, Second_signatory_2_Role__c, 
            		Signing_Instructions__c, Previous_Entity_Name__c
					from Billing_Entity__c where Entity_Status__c = 'Contracting Entity'
                ];
    }
}