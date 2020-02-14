@isTest
private class test_Opportunity_Extension {

static testmethod void testOptyExt(){
       
    Opportunity opp = TestUtility.sampleOpportunity();
    insert opp;
    
    ApexPages.StandardController sc = new ApexPages.StandardController(opp);
    PageReference pageRef = Page.NS_Project_Opportunity_New_Button;
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('Id', String.valueOf(opp.Id));
    
    OpportunityController_Extension testOpp = new OpportunityController_Extension(sc);
 
      }
      
}