@isTest
private class Opportunity_Deal_Approvals_test {

    static testMethod void Opportunity_Deal_Approvals_testMethod() {
    
    Account acc = new Account(name='account1');
    insert acc;   
       
    //Opportunity opp = [Select name,id From Opportunity  limit 1];
    //opp.AccountId = acc.Id;
    //opp.Approval_Status__c = null;
    //update opp;
    Opportunity opp = new Opportunity(name='test - opp', accountId= acc.id, StageName='Suspect',currencyISOCode='GBP',CloseDate=date.today());
    insert opp;
 
    Deal_Approval__c dealApp = new Deal_Approval__c(name = 'DealRecord1', Opportunity__c = opp.Id, Approval_Ref__c= 'test');
    insert dealApp;
    
    Deal_Approval__c dealApp1 = new Deal_Approval__c(name = 'DealRecord2', Opportunity__c = opp.Id, Approval_Ref__c= 'test1');
    insert dealApp1;
    
   // dealApp1.name = 'DealRecord22';
   // update dealApp1;
    
    //ProcessInstance p1 = new ProcessInstance(Status='Approved', TargetObjectId = dealApp.Id);
    //insert p1;
    //ProcessInstance p1 = [Select TargetObjectId,Id,Status from ProcessInstance limit 1];
   
   
   // Deal_Approval__c dealApp2 = [Select id, name, Opportunity__c from Deal_Approval__c where id= :p1.TargetObjectId];
   // Deal_Approval__c dealApp2 = new Deal_Approval__c(name = 'DealRecord1', Opportunity__c = opp.Id, Approval_Ref__c= 'test',TargetObjectId__r = :p1.TargetObjectId);
   // insert dealApp;
    
  //  Opportunity o1 = [Select id, name from Opportunity where id= :dealApp2.Opportunity__c];
    
    
    //ProcessInstanceWorkitem proInsWork = new ProcessInstanceWorkitem(ProcessInstanceId = p1.Id); 
    //insert proInsWork;
  
    //ProcessInstanceWorkitem proInsWork= [Select p.id, p.ProcessInstance.TargetObjectId from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =:p1.id limit 1];
    //proInsWork.ProcessInstance.TargetObjectId = dealApp.Id;
    //update proInsWork;
  
   // ProcessInstanceStep proInsStep=  [Select id ,StepStatus from ProcessInstanceStep limit 1];
   // proInsStep.StepStatus ='Approved'; 
   // update proInsStep;
    
    ApexPages.StandardController cont = new ApexPages.StandardController(opp);
    OpportunityDealApprovals oppdeal = new OpportunityDealApprovals(cont);
    oppdeal.getOppDealApprovals();
    oppdeal.Edit();
    oppdeal.Del();
    oppdeal.newDeal();
    }
}