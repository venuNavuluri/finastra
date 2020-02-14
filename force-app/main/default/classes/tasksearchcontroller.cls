public class tasksearchcontroller
{
  public boolean searched{get;set;}
  public user currentuser{get;set;}
  public string Owner{get;set;}//I would like to use this name in vf,asking user input text
  public Date fromActivityDate{get;set;}
  public Date toActivityDate{get;set;}  
  public Date fromDate {get;set;}
  public Date toDate {get;set;}
  public Task t1 {get;set;}
  public Contact c1 {get;set;}
  public Lead l1 {get;set;}
  public Double TotalScore {get;set;}
  public Integer ABCTotal {get;set;}
  public Integer ABC {get;set;}
  public Integer AV {get;set;}
  public Decimal ccscore {get;set;}
  public Integer CScore {get;set;}
  public Decimal lcscore {get;set;}
  public Integer LScore {get;set;}
  public Decimal ISTScore {get;set;}
  public Integer CNScore {get;set;}
  public Integer LNScore {get;set;}
  public Integer ITScore {get;set;}
  public Integer Contactscreated {get;set;}  
  public Integer Salesexec {get;set;}
  public Integer Insidesales {get;set;}
  public Integer Playermanager {get;set;}
  public Integer GSSSales {get;set;}
  public Integer GSSSwat {get;set;}  
  public List<Task> activities{get;set;}  
  public List<Contact> contacts{get;set;}  
  public List<Lead> leads{get;set;}
    public PageReference refresh () {
                return null;
                }            
public tasksearchcontroller(ApexPages.StandardController controller)
{
    t1=new Task();  
    initial_values();  
c1=new Contact();  
l1=new Lead();           
currentuser=new User();
     currentuser=[Select Id,Name,Email,CommunityNickname from User where Id=:userinfo.getuserId()];
}
public void initial_values()
{
    TotalScore=0.0;
    CScore =0;
    LScore =0;  
    ABC = 0;
    ccscore=0.0;
    lcscore =0.0;
    ABCTotal =0;
    ITScore =0;
    LNScore=0;
    CNScore=0;
    Contactscreated=0;       
    Salesexec=0;
    Insidesales=0;
    Playermanager=0;
    GSSSales=0;
    GSSSwat=0;
}
public PageReference executeSearch()
{
    initial_values();
    searched=true;
if(t1.Activity_Start_Date__c !=null && t1.Activity_End_Date__c!=NULL)
{     
     fromDate = t1.Activity_Start_Date__c;
     toDate = t1.Activity_End_Date__c;
}      
activities=[select id,owner.name,Sales_Role__c,Sales_Activity_Type__c,Activity_Type__c,Purpose__c,Status,ActivityDate,Completed_Date__c,Task_Score_Percentage__c,Task_Score__c 
from Task where owner.name  LIKE :currentuser.Name AND  ActivityDate >=:fromDate AND ActivityDate <=: toDate];
    if(activities.size()!=0) 
    {
        AggregateResult[] results = [ SELECT owner.name, Sum(Task_Score__c) Total FROM Task  where owner.name=:activities[0].owner.name and ActivityDate >=:fromDate AND ActivityDate <=: toDate  GROUP BY owner.name];
        if(results.size()!=0)
                {
            for (AggregateResult ar : results) 
           
            {                      
                TotalScore =Double.valueof(ar.get('Total')); 
                if(TotalScore ==null){
                     TotalScore =0;           
                }                     
                ABCTotal =(TotalScore *100).intValue();
                ABC = ABCTotal;
                if(ABC>100)
                {
                ABC=100;
                }
                else                
                ABC=ABC;
                Salesexec=(ABC);
                Insidesales=(ABC);
                Playermanager=(ABC);
                GSSSales=(ABC);
                GSSSwat=(ABC);             
            }
        }
    }
contacts=[select id,owner.name from Contact where owner.name  LIKE :currentuser.Name]; 
        AggregateResult[] ccreated = [SELECT owner.name, COUNT(CreatedByID) CN FROM Contact WHERE owner.name =:currentuser.Name AND CreatedDate >=:fromDate AND CreatedDate <=:toDate GROUP BY owner.name];
        if(ccreated.size()!=0)
        {
            for (AggregateResult cc : ccreated)
            {
                CNScore =Integer.valueof(cc.get('CN'));
                ccscore = (CNScore*0.5);
                CScore = ccscore.intValue();
            } 
        }   
leads=[select id,owner.name from Lead where owner.name  LIKE :currentuser.Name]; 
      AggregateResult[] lcreated = [SELECT owner.name, COUNT(Status) LN FROM Lead WHERE owner.name =:currentuser.Name AND ConvertedDate >=:fromDate AND ConvertedDate <=:toDate  GROUP BY owner.name];
          if(lcreated.size()!=0)
        {    
            for (AggregateResult lc : lcreated)
            {
                LNScore =Integer.valueof(lc.get('LN'));
                lcscore = (LNScore*0.5);
                LScore = lcscore.intValue();
            }
        }
        ISTScore = (ABCTotal+ccscore+lcscore);
        ITScore = ISTScore.intValue();
        if(ITScore>100)
        {
        ITScore=100;
        }
        
        else
        {
        ITScore=ITScore;
        }
Contactscreated=(CNScore+LNScore);
return null;
}
public pagereference Clear()
{
    activities = null;
    fromActivityDate = null;
    toActivityDate = null;
    /*ABC = null;
        

    ITScore = null;
    CScore = null;
    LScore = null;
      
    Salesexec = null;
    Contactscreated = 0;
    Playermanager = null;
    GSSSales = null;
    GSSSwat = null;*/
    initial_values();
    t1.Activity_Start_Date__c = null;
    t1.Activity_End_Date__c = null;
  return page.ABC_Attainment;
 }
}