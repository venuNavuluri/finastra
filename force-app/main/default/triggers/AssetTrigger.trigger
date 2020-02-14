/**
 * @File Name          : AssetTrigger.trigger
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 04/11/2019, 14:48:13
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    04/11/2019   Peter Sabry     Initial Version
**/
trigger AssetTrigger on Asset (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new AssetTriggerHandler().run();
}