/*  @author Serhii Volynets sergey.volinets@weare4c.com
 * @Jira: RBX-381
 * before update or insert account__c field is updated and some decimal fields are calculated
 * after update or insert the Account.FDIC_NCUA_Data__c field is populated
 * */
trigger FDIC_Trigger on FDIC_NCUA_Data__c (before insert,before update, after insert, after update) 
{
	//after update or insert the Account.FDIC_NCUA_Data__c field is populated
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
    {
        if(Trigger.isInsert)
        	FDIC.updateFDIC(Trigger.new,null);
        else
            FDIC.updateFDIC(Trigger.new,Trigger.oldMap);            
    }
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        //before update or insert account__c field is updated and some decimal fields are calculated
        if(Trigger.isInsert)
            FDIC.beforeUpdateFDIC(Trigger.new,null);
        else
            FDIC.beforeUpdateFDIC(Trigger.new,Trigger.oldMap);  
    }
}