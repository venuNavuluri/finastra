public class MyDealApprovals {

        /*
    Name        :   MyDealApprovals
    
    Purpose     :   This controller is for MyDealApprovals VF page. The class retrieves all the Pending deals  
                    for the logged in opportunity. The MyDealApprovals VF page is used as a homepage component.  
                    The details of the requirement can be obtained at https://emea.salesforce.com/01520000000iu6K

    Special Considerations: None 
    
    Parameters  :   N/A
                    
    Invoked From    : MyDealApprovals VF page   

    Triggering Condition:   N/A

    Returns     :   
                        
    Notes       :   None    
                        
    Modification Log
    
    User                                Date                Description
    --------------                              ----------          --------------------------------------------------------------
    Kim Jansen/Salman Sheikh            05/01/2009          Created - Initial version - To display pending deal approvals for 
                                                                                                        the user on the home page.
    */
        
        public Apexpages.Standardcontroller c;
        public List<Deal_Approval__c> lstDA { get; private set; }
        public Map<ID,ID> mapDA_PIW { get; private set; }

        public MyDealApprovals(Apexpages.Standardcontroller controller)
        {
                c = controller;
                init();         
        }

        public MyDealApprovals()
        {
                init();         
        }
        
                public void init()
        {
                Set<Id> daIDs = new Set<Id>();
                mapDA_PIW = new Map<ID,ID>();
        
                List<ProcessInstanceWorkitem> lstPIW = [
                                                                                                        Select 
                                                                                                                        p.ProcessInstance.TargetObjectId, 
                                                                                                                        p.ProcessInstance.Status,
                                                                                                                        p.ProcessInstanceId, 
                                                                                                                        p.OriginalActorId, 
                                                                                                                        p.IsDeleted, 
                                                                                                                        p.Id, 
                                                                                                                        p.ActorId
                                                                                                        From 
                                                                                                                        ProcessInstanceWorkitem p
                                                                                                        
                                                                                                        Where
                                                                                                                        p.ActorId =:Userinfo.getUserId()
                                                                                                        and             p.ProcessInstance.Status = 'Pending'
                                                                                                ];
                        
                                                                                                
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
                        lstDA = [
                                                                Select 
                                                                                d.Opportunity__r.CloseDate, 
                                                                                d.Opportunity__r.Name, 
                                                                                d.Opportunity__c, 
                                                                                d.Id, 
                                                                                d.Opportunity__r.Order_Number__c,
                                                                                d.Date_Diff__c
                                                                From 
                                                                                Deal_Approval__c d
                                                                where 
                                                                                d.Id in : daIDs
                                                        ];
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