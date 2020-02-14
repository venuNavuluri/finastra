/**
 * @File Name          : AccountTrigger.trigger
 * @Description        : 
 * @Author             : Aakanksha Sharma
 * @Group              : 
 * @Last Modified By   : Aakanksha Sharma
 * @Last Modified On   : 28/01/2020, 00:35:09
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    27/01/2020   Aakanksha Sharma     Initial Version
**/
trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete)  {
    new AccountTriggerHandler().run();
}