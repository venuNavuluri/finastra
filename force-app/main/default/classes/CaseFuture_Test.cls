@isTest 
private class CaseFuture_Test {

 /* static testMethod void testCSFECommentary() {
    
    // Set up call count and client count tests by adding customer case and account to issue case
    Account a = new Account(name = 'TEST');
    insert a;
    
    // add a comment - a caseComment should be created for this
    Case ic = new Case(SFDC_CSFE_Commentary__c='Comment 1', accountID=a.id);
    insert ic;
    
    Case cc = new Case(issue_case__c = ic.id, accountID = a.id);
    insert cc;
    
    Set<ID> caseIDs = new Set<ID>();
    List<ID> caseIDsList = new List<ID>();
    caseIDs.add(ic.id);
    caseIDsList.add(ic.id);
    
    // Start and stop tests - the future methods will run on the stop test.
    Test.startTest();
 //     CaseFuture.addCommentaryToCaseComments(caseIDs);
 //     CaseFuture.caseCounts(caseIDs);
    CaseFuture.caseNotify(caseIDsList, new List<String>{'Priority'});

    Test.stopTest();
    
    // reread the issue case to check the results
    ic = [SELECT call_count__c, client_count__c FROM case WHERE id = :ic.id];
    
    // check that the call count/client count are correct
    System.assertEquals(1, ic.call_count__c);
    System.assertEquals(1, ic.client_count__c);
    
    // check that the caseComment for the issue case was created successfully;
    
    //CaseComment icComment = [SELECT id, commentBody FROM caseComment WHERE parentID = :ic.id LIMIT 1];
    //System.assertEquals('Comment 1', icComment.commentBody);
    
  } */

  static testMethod void testCSFECommentary_new() {
    
    // Set up call count and client count tests by adding customer case and account to issue case
    Account a = new Account(name = 'TEST');
    insert a;
    
    Integer j = 0;
    List<User> u1 = new List<User>();
    
    for(User u : [Select name, email from User limit 11])
    {
    u.email = 'mohit_bansal' + j + '@hcl.com';
    j++;
    u1.add(u);
    }
    
    System.debug('HCL list' + u1);
    update u1;

    //Group usergp = new Group(name='Group of Users', type='regular');
    //insert usergp;
    Group usergp = [select Id,OwnerId from Group limit 1];
    System.debug('HCL Ownerid value' + usergp.OwnerId);
    //System.debug('HCL Ownerid value' + usergp.type);
    //User utest = [Select id, name from User where id= :usergp.OwnerId limit 1];
    //System.debug('HCL Testing User value' + utest);
    
    
    
    List<GroupMember> gm1 = new List<GroupMember>();
    for(User u : u1)
    {
    GroupMember grpmem = new GroupMember(groupid = usergp.id, UserOrGroupId = u.id );
    gm1.add(grpmem);
    }
    //insert gm1;
        
    // add a comment - a caseComment should be created for this
    //Case ic = new Case(SFDC_CSFE_Commentary__c='Comment 1', accountID=a.id);
    //insert ic;
    
    List<Case> caseList = new List<Case>();
    List<Case> caseList1 = new List<Case>();
    Set<ID> caseIDs = new Set<ID>();
    List<ID> caseIDsList = new List<ID>();
    Integer i = 0;

    for(User u2 : u1)
    {   
        Case c = new Case(SFDC_CSFE_Commentary__c='Comment'+i , accountID=a.id, ownerId = u2.id);
        caseList.add(c);
        i++;
     }
    Case c = new Case(SFDC_CSFE_Commentary__c='Group Comment' , accountID=a.id ); //ownerId = usergp.ownerid
    caseList.add(c);
    insert caseList; 
    
    for(Case c2 : caseList)
    {
      caseIDs.add(c2.id);
      caseIDsList.add(c2.id);
    }
    
    for(Case c1 : caseList)
    {
        Case cc = new Case(issue_case__c = c1.id, accountID = a.id);    
        caseList1.add(cc);
    }
    insert caseList1; 
    
    List<String> change = new List<String>();
    for(i=0; i<12; i++)
    {
      change.add('Priority' + i);
    } 
     
    Test.startTest();
      CaseFuture.caseNotify(caseIDsList, change);
    Test.stopTest();
    
    
  }
  
   
}