/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class MyDealApprovals_test{

    static testMethod void testmethod_MyDealApprovals(){

        Id rtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Partnership Agreement').getRecordTypeId();
        // we want to trigger Partner Team Approval process
        Opportunity opp = new Opportunity(Name = 'opp', StageName = 'Prospecting', CloseDate = Date.today(), recordtypeId = rtId, amount = 5000,No_software_included_in_agreement__c = true);
        insert opp;

        if([select count() from ProcessInstance where targetobjectid = :opp.id] < 1){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[]{
                    UserInfo.getUserId()
            });
            req.setObjectId(opp.Id);

            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);

        }

        ProcessInstanceWorkitem p1 = [Select p.ProcessInstance.TargetObjectId, p.ProcessInstance.Status,p.ProcessInstanceId,p.OriginalActorId, p.IsDeleted,p.Id, p.ActorId From ProcessInstanceWorkitem p Where p.ProcessInstance.Status = 'Pending' limit 1];
        p1.ActorId = Userinfo.getUserId();
        update p1;

        MyDealApprovals tvfc = new MyDealApprovals();

        Apexpages.Standardcontroller c;

        MyDealApprovals tvfc1 = new MyDealApprovals(c);

        //      Deal_Approval__c da = [Select d.Opportunity__r.CloseDate, d.Opportunity__r.Name, d.Opportunity__c, d.Id, d.Approval_Ref__c, d.Approval_Reasons__c From Deal_Approval__c d limit 1];

        tvfc.reassign();
        tvfc.approveReject();

    }
}