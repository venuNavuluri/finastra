/**
 * @File Name          : RFIndexTrigger.trigger
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 22/07/2019, 15:35:29
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    22/07/2019, 15:35:29   Peter Sabry     Initial Version
**/
trigger RFIndexTrigger on RF_Index__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    new RFIndexTriggerHandler().run();
}