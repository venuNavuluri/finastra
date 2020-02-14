/**
 * @File Name          : AddressTrigger.trigger
 * @Description        : Trigger for Address Object
 * @Author             : Aakanksha Sharma
 * @Group              :
 * @Last Modified By   : Aakanksha Sharma
 * @Last Modified On   : 31/01/2020, 09:26:04
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    31/01/2020   Aakanksha Sharma     Initial Version
 **/
trigger AddressTrigger on Address__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  new AddressTriggerHandler().run();
}