/**
 * @File Name          : OpportunityTrigger.trigger
 * @Description        : OpportunityTrigger
 * @Author             : venu.navuluri@finastra.com
 * @Group              :
 * @Last Modified By   : venu.navuluri@finastra.com
 * @Last Modified On   : 04/11/2019, 14:59:48
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    01/11/2019   venu.navuluri@finastra.com     Initial Version
 **/
trigger OpportunityTrigger on Opportunity(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  new OpportunityTriggerHandler().run();
  new OpportunityTriggerHandlerWS().run();
}
