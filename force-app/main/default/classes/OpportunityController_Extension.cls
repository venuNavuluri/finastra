public class OpportunityController_Extension {


  public Opportunity theOpp {get; set;}
  
   public OpportunityController_Extension(ApexPages.StandardController controller) {
  
        theOpp = [SELECT Id,Name
        FROM Opportunity WHERE Id =:controller.getRecord().Id limit 1];
}
}