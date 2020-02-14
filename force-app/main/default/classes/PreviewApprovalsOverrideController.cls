/**
* @File Name          : PreviewApprovalsOverrideController.cls
* @Description        : Overrride of the standard Preview Approvals page from Advanced Approvals
* @Author             : Dan Meseroll
* @Group              : ATG
* @Last Modified By   : Dan Meseroll
* @Last Modified On   : 1/22/2020, 12:00:00 PM
* @Modification Log   : 
* Ver       Date            Author      		    Modification        JIRA Ticket
* 1.0       1/22/2020       Dan Meseroll            Initial Version     RUBX-107
**/
public with sharing class PreviewApprovalsOverrideController {
    
    private SBQQ__Quote__c sbQuote;
    
    public SBAA__Approval__c[] approvals {
        get {
            if (approvals == null) {
                approvals = SBAA.ApprovalAPI.preview(sbQuote.Id, SBAA__Approval__c.Quote__c);
            }
            return approvals;
        } 
        set;
    }
    
    public PreviewApprovalsOverrideController(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()) {
            stdController.addFields(new List<String> {'SBQQ__Primary__c'});
        }
        this.sbQuote = (SBQQ__Quote__c)stdController.getRecord();
    }

    public PageReference onSubmit() {
        if (sbQuote != null) {
            //Don't allow non-Primary quotes to be submitted for Approval.
            if ((sbQuote.SBQQ__Primary__c == null) || (sbQuote.SBQQ__Primary__c == false)) {
                ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Only_Primary_Quotes);
                ApexPages.addMessage(message);
                return null;
            }
            SBAA.ApprovalAPI.submit(sbQuote.Id, SBAA__Approval__c.Quote__c);
        }
        
        PageReference pr = new PageReference('/' + sbQuote.Id);
        pr.setRedirect(true);
        return pr;
    }

    public PageReference onCancel() {
        PageReference pr = new PageReference('/' + sbQuote.Id);
        pr.setRedirect(true);
        return pr;
    }
}