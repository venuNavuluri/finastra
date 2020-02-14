@isTest
public class tasksearchtestclass{
     Static testmethod void tasksearchcontrollertest(){   
   Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];   
     User u=[SELECT Id,name FROM user WHERE profileid=:p.id LIMIT 1]; 
      //To take care of trigger and setting up initial values.     
    
         Task ta = new task();
    //ta.ownerid=u.id;
    ta.ownerid = userinfo.getuserId();
    ta.Sales_Role__c='Sales Exec';
    ta.Sales_Activity_Type__c='Client Communications - Call';
         ta.Sales_Activity_Type__c='Client Communications - Meeting';
         ta.Sales_Activity_Type__c='Internal';
    ta.Activity_Type__c='Introductory Call / GTM';
    ta.ActivityDate=date.parse('02/01/2014');
    ta.Completed_Date__c=date.parse('30/01/2014');
    ta.Task_Score__c=10.90;
        ta.status='Completed';
    insert ta;          
         // these updates to take care of trigger if else conditions.         
         ta.Activity_Type__c='Lead / MQL follow up';         
         update ta;         
         ta.Activity_Type__c='Opportunity Progression';
         update ta;
         ta.Activity_Type__c='Demo or Presentation';
         update ta;
         ta.Activity_Type__c='Negotiation / Opportunity Close';         
         update ta;         
         ta.Activity_Type__c='Relationship (SAG, NPS)';
         update ta;
         ta.Activity_Type__c='Support issue / CS related';
         update ta;
         ta.Activity_Type__c='Project / PS related';         
         update ta;         
         ta.Activity_Type__c='Collections / Maintenance Sweep';
         update ta;
         ta.Activity_Type__c='Misys Connect Nomination / Presentation follow up';
         update ta;
         ta.Activity_Type__c='Introductory Call / GTM';
         update ta;
         ta.Activity_Type__c='Partner Development';
         update ta;
         ta.Activity_Type__c='Sales Training';
         update ta;
         ta.Activity_Type__c='Marketing Event';
         update ta;
       //ApexPages.currentPage().getParameters().put('lc',objLeadCenter.id);
        ApexPages.StandardController stdTask = new ApexPages.StandardController(ta);
        tasksearchcontroller objtaskController = new tasksearchcontroller(stdTask);  
        objtaskController.fromDate = date.parse('01/01/2014');
        objtaskController.toDate = date.parse('30/01/2014');
        /*isttasksearchcontroller objecttaskController = new isttasksearchcontroller(stdTask); 
        objecttaskController.fromDate = date.parse('01/01/2014');
        objecttaskController.toDate = date.parse('30/01/2014');*/
 /*       
        system.debug('test = ' + [select id,owner.name,Sales_Role__c,Sales_Activity_Type__c,Activity_Type__c,Purpose__c,Status,ActivityDate,Completed_Date__c,Task_Score_Percentage__c,Task_Score__c 
from Task where ownerId = :userinfo.getuserId() AND  ActivityDate >=:date.parse('01/01/2014') AND ActivityDate <=: date.parse('30/01/2014')]);

        system.debug('test1 = ' + [select id,owner.name,Sales_Role__c,Sales_Activity_Type__c,Activity_Type__c,Purpose__c,Status,ActivityDate,Completed_Date__c,Task_Score_Percentage__c,Task_Score__c 
from Task where Id = :ta.Id]);
*/       
         objtaskController.executeSearch();        
         objtaskController.clear();
         objtaskController.refresh();
         
         /*objecttaskController.executeSearch();        
         objecttaskController.clear();
         objecttaskController.refresh(); */ 
    }
}