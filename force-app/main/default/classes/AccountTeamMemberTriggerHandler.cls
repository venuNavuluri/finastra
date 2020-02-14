/**
* @File Name          : AccountTeamMemberTriggerHandler.cls
* @Description        :
* @Author             : Sujith Maruthingal
* @Group              :
* @Last Modified By   : Sujith Maruthingal
* @Last Modified On   : 10/01/2020, 16:53:33
* @Modification Log   :
* Ver       Date            Author      		    Modification
* 1.0    17/12/2019   Sujith Maruthingal     Initial Version
**/
public with sharing class AccountTeamMemberTriggerHandler extends TriggerHandler {
    
    protected override void afterInsert() 
    {
        List<AccountTeamMember> accountTeamMembers = (List<AccountTeamMember>) Trigger.new;
        updateAccountTeamMembers(accountTeamMembers);
        
    }
    
    protected override void afterUpdate() {
        List<AccountTeamMember> accountTeamMembers = (List<AccountTeamMember>) Trigger.new;
        updateAccountTeamMembers(accountTeamMembers);
    }
    
    /**
    * @description updateAccountTeamMember handler is used to restrict the Opportunity/Account access from Read/Write to Account owned. 
    * @author Sujith Maruthingal | 20/12/2019 
    * @param accTeamListUpdate 
    * @return void 
    **/
    private void updateAccountTeamMembers(List<AccountTeamMember> accTeamListUpdate) {
        for (AccountTeamMember accTeamMember : accTeamListUpdate) {
            if (accTeamMember.AccountAccessLevel == Constants.EDIT_ONLY || accTeamMember.OpportunityAccessLevel == Constants.EDIT_ONLY) {
                accTeamMember.addError(Constants.ACC_TEAM_MEMBER_ERROR_MSG);
            }
        }
    }
}