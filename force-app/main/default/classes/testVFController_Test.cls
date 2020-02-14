/**
 * Created by Nina Gronowska on 05/10/2017.
 */

@IsTest
private class testVFController_Test{

    static testmethod void testmethod_VFController()
    {
       /* Id rtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Partnership Agreement').getRecordTypeId();
        // we want to trigger Partner Team Approval process
        Opportunity opp = new Opportunity(Name='opp',StageName = 'Prospecting', CloseDate = Date.today(), recordtypeId = rtId,  amount = 5000,
                Partnership_Agreement_Approval_Status__c = 'Pending');
        insert opp;

        if([select count() from ProcessInstance where targetobjectid=:opp.id] < 1)
        {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(opp.Id);

            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);

        }

        ProcessInstanceWorkitem p1 = [Select p.ProcessInstance.TargetObjectId, p.ProcessInstance.Status,p.ProcessInstanceId,p.OriginalActorId, p.IsDeleted,p.Id, p.ActorId From ProcessInstanceWorkitem p Where  p.ProcessInstance.Status = 'Pending' limit 1];
        p1.ActorId = Userinfo.getUserId();
        update p1;

        testVFController tvfc = new testVFController();

        Apexpages.Standardcontroller c;

        testVFController tvfc1 = new testVFController(c);

  //      Deal_Approval__c da = [Select d.Opportunity__r.CloseDate, d.Opportunity__r.Name, d.Opportunity__c, d.Id, d.Approval_Ref__c, d.Approval_Reasons__c From Deal_Approval__c d limit 1];

        tvfc.reassign();
        tvfc.approveReject();*/
    }
}