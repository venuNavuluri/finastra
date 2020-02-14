public with sharing class QuoteExtController {

    private Id quoteId;
    
    public QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
    }
    
    public PageReference onSubmit() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
        }
        
        PageReference pr = new PageReference('/' + quoteId);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference onRecall() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
        }
        PageReference pr = new PageReference('/' + quoteId);
        pr.setRedirect(true);
        return pr;
    }



}