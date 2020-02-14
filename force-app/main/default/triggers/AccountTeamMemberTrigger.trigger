/**
 * @File Name          : AccountTeamMemberTrigger.cls
 * @Description        :
 * @Author             : Sujith Maruthingal
 * @Group              :
 * @Last Modified By   : Sujith Maruthingal
 * @Last Modified On   : 17/12/2019, 15:30:09
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    17/12/2019   Sujith Maruthingal     Initial Version
 **/
  trigger AccountTeamMemberTrigger on AccountTeamMember(before insert,before update,before delete,after insert,after update,after delete,after undelete) {
  new AccountTeamMemberTriggerHandler().run();
}