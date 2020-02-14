public with sharing class newAcctBySubForAccount_Extension{

    public Account accountRecord { get; set; }
    
    public String errorMessage { get; set; }
    
    public newAcctBySubForAccount_Extension(ApexPages.StandardSetController controller) {
        Id accountId = ApexPages.currentPage().getParameters().get('id');
        accountRecord = [SELECT Id, Name, CCRT_entry__c FROM Account WHERE Id = :accountId];
    }
    
    public PageReference checkCCRT() {
        if (String.isBlank(accountRecord.CCRT_entry__c))
            errorMessage = label.NewAcctBySubMustHaveCCRTAttached_Error;
        else if (!Schema.sObjectType.Acct_By_Sub__c.isCreateable())
            errorMessage = label.NewAcctBySubPermission_Error;
            
        if (errorMessage != null)
        
            // no redirect - show error message
            return null;
        else
        
            // redirect to AcctBySub edit page
            return new PageReference('/a25/e?retURL=%2F' + accountRecord.Id 
                + '&Name=' + accountRecord.Name.escapeJava() + 
                + '&CF00N20000004eMxh=' + accountRecord.Name.escapeJava() + 
                + '&CF00N20000004eMxh_lkid=' + accountRecord.Id);
    }
}