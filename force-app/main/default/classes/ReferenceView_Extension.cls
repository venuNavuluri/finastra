public class ReferenceView_Extension {

    public Id opportunityId { get; set; }
    
    public PageReference redirectPage { get; set; }

    public ReferenceView_Extension(ApexPages.StandardSetController controller) {
        opportunityId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public PageReference redirectAddSalesWin() {
        Id contactId;
        List<OpportunityContactRole> ocr = [SELECT ContactId FROM OpportunityContactRole WHERE IsPrimary = True AND OpportunityId = :opportunityId];
        if (!ocr.isEmpty()) {
            contactId = ocr[0].ContactId;
        }
        redirectPage = Page.roi__ReferenceView;
        redirectPage.getParameters().put('page', 'SalesWinAdd');
        if (opportunityId != null)
            redirectPage.getParameters().put('oid', opportunityId);
        if (contactId != null)
            redirectPage.getParameters().put('cid', contactId);
        redirectPage.setRedirect(true);
        return redirectPage; // force a redirect -- or return null and prompt user with the link
    }

    public PageReference redirectRaiseRequest() {
        redirectPage = Page.roi__ReferenceView;
        redirectPage.getParameters().put('page', 'Requests');
        if (opportunityId != null)
            redirectPage.getParameters().put('oid', opportunityId);
        redirectPage.setRedirect(true);
        return redirectPage; // force a redirect -- or return null and prompt user with the link
    }
}