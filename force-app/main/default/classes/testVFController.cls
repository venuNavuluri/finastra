public class testVFController 
{
    public Apexpages.Standardcontroller c;
    public List<Deal_Approval__c> lstDA { get; private set; }
    public Map<ID,ID> mapDA_PIW { get; private set; }

    public testVFController(Apexpages.Standardcontroller controller)
    {
        c = controller;
        init();     
    }

    public testVFController()
    {
        init();     
    }
    
    
    public void init()
    {
        Set<Id> daIDs = new Set<Id>();
        mapDA_PIW = new Map<ID,ID>();
    
        List<ProcessInstanceWorkitem> lstPIW = [Select  p.ProcessInstance.TargetObjectId, p.ProcessInstance.Status, p.ProcessInstanceId,p.OriginalActorId, p.IsDeleted,p.Id, p.ActorId From ProcessInstanceWorkitem p Where p.ActorId =:Userinfo.getUserId() and    p.ProcessInstance.Status = 'Pending'];
            
                                                
        for(ProcessInstanceWorkitem piw : lstPIW)
        {
            Id targetObjId = piw.ProcessInstance.TargetObjectId;
        
            if(String.valueOf(targetObjId).startsWith('a0W'))
            {
                daIDs.add(piw.ProcessInstance.TargetObjectId);
                mapDA_PIW.put(piw.ProcessInstance.TargetObjectId, piw.Id);
            }
        }
        
        
        if(daIDs.size() > 0)
        {
            lstDA = [Select d.Opportunity__r.CloseDate,d.Opportunity__r.Name,d.Opportunity__c,d.Id,d.Approval_Ref__c,d.Approval_Reasons__c  From Deal_Approval__c d where d.Id in : daIDs];
            
        }
    }
    
    
    
    public Pagereference reassign()
    {
        String sDAId = ApexPages.CurrentPage().getParameters().get('daId');
        
        Id piwID = mapDA_PIW.get(sDAId);
        
        return new pagereference('/' + piwID + '/e?et=REASSIGN&retURL=%2Fhome%2Fhome.jsp'); 
    }


    public Pagereference approveReject()
    {
        String sDAId = ApexPages.CurrentPage().getParameters().get('daId');
        
        Id piwID = mapDA_PIW.get(sDAId);
        
        return new pagereference('/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + piwID); 
        
        
    }
    
}