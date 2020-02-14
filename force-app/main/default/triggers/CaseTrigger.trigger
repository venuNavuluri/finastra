/**
 * @File Name          : CaseTrigger.trigger
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 04/11/2019, 15:11:00
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    04/11/2019   Peter Sabry     Initial Version
**/
trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new CaseTriggerHandler().run();
}