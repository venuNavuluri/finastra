/**
 * @File Name          : LeadTrigger.trigger
 * @Description        : 
 * @Author             : Prity Sangwan
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 04/12/2019, 18:56:14
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    02/12/2019   Prity Sangwan     Initial Version
**/
trigger LeadTrigger on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new LeadTriggerHandler().run();
}