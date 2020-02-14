public class OpportunityDealApprovals {
	/*
    Name        :   OpportunityDealApprovals
    
    Purpose     :   This controller is for Opportunity_Deal_Approvals VF page. The class retrieves all deals  
                    for the given opportunity. All the approvers for each deals gets retrieved from process objects.
                    And then processed to display (kind of flat view) on deal row. The Opportunity_Deal_Approvals VF page 
                    is used as a section on Opportunity page layouts. 
                    The details of the requirement can be obtained at https://emea.salesforce.com/01520000000iu6K

    Special Considerations: None 
    
    Parameters  :   N/A
                    
    Invoked From    : Opportunity_Deal_Approvals VF page   

    Triggering Condition:   N/A

    Returns     :   
                        
    Notes       :   None    
                        
    Modification Log
    
    User            Date                Description
    --------------      ----------          --------------------------------------------------------------
    Prashant Bhure     	05/01/2009          Created - Initial version - To display the opportunity deals and 
    										associated approvers on Opportunity layouts.
    */
   
    public final Opportunity OppObj;
	public List<Deal_Approval__c> iDA_List { get; set; }
	public List<ProcessInstanceWorkitem> iPending_Approvers {get; set;}
	public List<ProcessInstanceStep> iApproved_Approvers {get; set;}
	public List<Deal_Approval_Structure> OppDAList{get;set;} 
	String isOppName{get; set;}

  public OpportunityDealApprovals(ApexPages.StandardController controller) {
		this.OppObj = (Opportunity)controller.getRecord();
		System.debug('PB: in OpportunityExtensions');		
    }
    
    public Deal_Approval_Structure [] getOppDealApprovals() {
    //public ProcessInstanceStep [] getOppDealApprovals() {
    	INTEGER li_deal_counter = 0;
    	INTEGER li_approver_counter = 1;
    	
    	INTEGER deal_count = [SELECT COUNT() FROM Deal_Approval__c d2 WHERE d2.Opportunity__r.id = :OppObj.id];
    	System.debug('value of deal_count' + deal_count);
    	IF (deal_count > 0){ //Get in the processsing only when opp has any deals; Otherwise, it throws a system exception that no deals found for sObject assignment. 

	    	/* iDA_List holds all the deals for an opportunity */
	    	iDA_List = 	[	SELECT d.id, d.Approval_Status__c,  d.Approval_Reasons__c, d.Name, d.Date_Diff__c, d.Approval_Ref__c, d.date_Submitted__c
							FROM Deal_Approval__c d
							WHERE d.Opportunity__r.Id = :OppObj.id
							//WHERE d.Opportunity__r.Name = 'AFG - Midas Plus Upgrade PS'
							ORDER BY d.id DESC];
				
		System.debug('value of iDA_List' + iDA_List);				
		
			/* For each Deal Approvals get the Pending and Approved processes separately as they are stored in separate sources and you can't use UNION in SOQL */		
			iPending_Approvers = [	SELECT p.Id, p.ActorId, p.ProcessInstanceId, p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId
								FROM ProcessInstanceWorkitem p
								WHERE p.ProcessInstance.TargetObjectId IN :iDA_List //= 'a0W20000000Aami'	];
								ORDER BY p.ProcessInstance.TargetObjectId DESC, p.CreatedDate ];
		
		System.debug('value of iPending_Approvers' + iPending_Approvers);		
		
 			iApproved_Approvers = [	SELECT p.ActorId, p.CreatedDate, p.Id, p.stepstatus, p.ProcessInstance.TargetObjectId 
								FROM ProcessInstanceStep p
								WHERE p.ProcessInstance.TargetObjectId IN :iDA_List // = 'a0W20000000Aami'
								AND p.StepStatus NOT IN ('Started', 'Reassigned') //Filter out any records for Deal Submit and Reassignment
								ORDER BY p.ProcessInstance.TargetObjectId DESC, p.CreatedDate ];
									
		System.debug('value of iApproved_Approvers' + iApproved_Approvers);
			
			OppDAList = new Deal_Approval_Structure[11];
			/* Finally combine all the above resultsets in the required format. Make sure the Pending and Approved approvers are limited to total 4. */ 
			FOR (Deal_Approval__c lda_obj : iDA_List) {
				Deal_Approval_Structure lOppDAList = new Deal_Approval_Structure();
				ProcessInstanceStep lFirstApprover = new ProcessInstanceStep ();
				ProcessInstanceStep lSecondApprover = new ProcessInstanceStep ();
				ProcessInstanceStep lThirdApprover = new ProcessInstanceStep ();
				ProcessInstanceStep lFourthApprover = new ProcessInstanceStep ();
				System.debug('PB: li_deal_counter: ' + li_deal_counter + ', lda_obj.Name: ' + lda_obj.Name);
				
				// Populate all the Approved approvers first			
				For (ProcessInstanceStep lapproved_approver_obj : iApproved_Approvers){
					//If approver's deal matches with the processing deal and all four approvers aren't populated for the deal, populate appropriate approver.
					IF (lda_obj.Id == lapproved_approver_obj.ProcessInstance.TargetObjectId && li_approver_counter <= 4){
						System.debug('PB: li_approver_counter: ' + li_approver_counter + ', lapproved_approver_obj.ActorId: ' + lapproved_approver_obj.ActorId);
						IF (li_approver_counter == 1) { // First Approver for the deal
							lFirstApprover.ActorId = lapproved_approver_obj.ActorId;
							lFirstApprover.StepStatus = lapproved_approver_obj.StepStatus;
						}
						ELSE IF (li_approver_counter == 2) { // Second Approver for the deal
							lSecondApprover.ActorId = lapproved_approver_obj.ActorId;
							lSecondApprover.StepStatus = lapproved_approver_obj.StepStatus;
						}
						ELSE IF (li_approver_counter == 3) { // Third Approver for the deal
							lThirdApprover.ActorId = lapproved_approver_obj.ActorId;
							lThirdApprover.StepStatus = lapproved_approver_obj.StepStatus;
						}
						ELSE IF (li_approver_counter == 4) { // Fourth Approver for the deal
							lFourthApprover.ActorId = lapproved_approver_obj.ActorId;
							lFourthApprover.StepStatus = lapproved_approver_obj.StepStatus;
						}						
						li_approver_counter ++; //Increment the counter so the next approver be populated in the next iteration.							
					}
				}
	
				// Now all the Pending approvers 			
				For (ProcessInstanceWorkitem lpending_approver_obj : iPending_Approvers){
					//If approver's deal matches with the processing deal and all four approvers aren't populated for the deal, populate appropriate approver.
					IF (lda_obj.Id == lpending_approver_obj.ProcessInstance.TargetObjectId && li_approver_counter <= 4){
						System.debug('PB: li_approver_counter: ' + li_approver_counter + ', lpending_approver_obj.ActorId: ' + lpending_approver_obj.ActorId);
						IF (li_approver_counter == 1) { // First Approver for the deal
							lFirstApprover.ActorId = lpending_approver_obj.ActorId;
							lFirstApprover.StepStatus = lpending_approver_obj.ProcessInstance.Status;
						}
						ELSE IF (li_approver_counter == 2) { // Second Approver for the deal
							lSecondApprover.ActorId = lpending_approver_obj.ActorId;
							lSecondApprover.StepStatus = lpending_approver_obj.ProcessInstance.Status;
						}
						ELSE IF (li_approver_counter == 3) { // Third Approver for the deal
							lThirdApprover.ActorId = lpending_approver_obj.ActorId;
							lThirdApprover.StepStatus = lpending_approver_obj.ProcessInstance.Status;
						}
						ELSE IF (li_approver_counter == 4) { // Fourth Approver for the deal
							lFourthApprover.ActorId = lpending_approver_obj.ActorId;
							lFourthApprover.StepStatus = lpending_approver_obj.ProcessInstance.Status;
						}						
						li_approver_counter ++; //Increment the counter so the next approver be populated in the next iteration.							
					}
				}			
				lOppDAList.iobj_DA = lda_obj;
				lOppDAList.iProcessInstanceStep_FirstAppr = lFirstApprover;
				lOppDAList.iProcessInstanceStep_SecondAppr = lSecondApprover;
				lOppDAList.iProcessInstanceStep_ThirdAppr = lThirdApprover;
				lOppDAList.iProcessInstanceStep_FourthAppr = lFourthApprover;
				
				OppDAList.Add(li_deal_counter, lOppDAList);
				li_deal_counter ++; 
				li_approver_counter = 1; //Reset back to 1
			}	
		}	
    	return OppDAList;    	
	}
	    
    PUBLIC Pagereference Edit()
	{
		String lsDAId = ApexPages.CurrentPage().getParameters().get('daId');	
		RETURN new pagereference('/' + lsDAId + '/e?retURL=/' +  this.OppObj.id);	
	}
	
	PUBLIC Pagereference Del()
	{
		String lsDAId = ApexPages.CurrentPage().getParameters().get('daId');
		RETURN new pagereference('/setup/own/deleteredirect.jsp?id='+ this.OppObj.id + '&delID=' + lsDAId + '&retURL=/' + this.OppObj.id + '&_CONFIRMATIONTOKEN=' ); 	
	}
	
	PUBLIC Pagereference newDeal()
	{
		String lsDAId = ApexPages.CurrentPage().getParameters().get('daId');	
		RETURN new pagereference('/setup/ui/recordtypeselect.jsp?ent=01I200000004u0f&retURL=/'+ this.OppObj.id + '&save_new_url=%2Fa0W%2Fe%3FCF00N20000001IqhB%3D' + this.OppObj.Name + '&retURL=/'  + this.OppObj.id ); 	
	}	
			
}