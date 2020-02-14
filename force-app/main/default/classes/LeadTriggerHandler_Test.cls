/**
* @File Name          : LeadTriggerHandler_Test.cls
* @Description        : 
* @Author             : prity.sangwan@finastra.com
* @Group              : 
* @Last Modified By   : Prity Sangwan
* @Last Modified On   : 04/12/2019, 12:26:01
* @Modification Log   : 
* Ver       Date            Author                  Modification
* 1.0    04/12/2019   prity.sangwan@finastra.com     Initial Version
**/
@isTest
public with sharing class LeadTriggerHandler_Test {
    private static final map<String,Profile> PROFILE_MAP=TestDataFactory.getProfileMap();
/**
* @description Positive test on chatter post when lead is converted
* @author Prity Sangwan | 02/12/2019 
* @return testMethod 
**/   
    //caused by: System.UnsupportedOperationException: 
    //ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true) recommended by salesforce.
    @IsTest(SeeAllData=true)
    static void notifySalesWhenLeadConverted_PositiveSingleTest() {
        List<Lead> leads = TestDataFactory.createLeads(1,true); 
        List<User> userList=TestDataFactory.createUserList(true);
        User bdrUser=[Select id,Profile.Name from User where ProfileId=:(PROFILE_MAP.get(Constants.BDR_USR_PROFILE).Id) and LastName='TestUser']; 
     
        // Perform test
         leads[0].Status = Constants.LEAD_STATUS_NEW;
         leads[0].OwnerId =bdrUser.Id ;
         Test.startTest();
         update leads; 
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leads[0].id);
        lc.setOpportunityName(TestDataFactory.OPP_NAME);
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Test.stopTest();  
        
        Database.LeadConvertResult lcr = Database.ConvertLead(lc);
        System.assert(lcr.isSuccess());
        
        List<FeedItem > FeedItem = [SELECT Id,ParentId,Body FROM FeedItem Where ParentId=:bdrUser.Id];
        System.assertEquals(1, FeedItem.size());
    }
    /**
* @description No chatter post
* @author Prity Sangwan | 02/12/2019 
* @return testMethod 
**/    
    @isTest(SeeAllData=true)
    static void notifySalesWhenLeadConverted_NegativeTest() {
        List<Lead> leads = TestDataFactory.CreateLeads(1,true);
        List<User> userList=TestDataFactory.createUserList(true);
        User bdrUser=[Select id,Profile.Name from User where ProfileId=:(PROFILE_MAP.get(Constants.BDR_USR_PROFILE).Id) and LastName='TestUser'];
        
        List<Bypass_Validations__c> valCusSettings = new List<Bypass_Validations__c>();
        valCusSettings.add(new Bypass_Validations__c(SetupOwnerId=UserInfo.getUserId(), Disable__c=true));
        insert valCusSettings;
        
        List<Lead> updatedLeads = new List<Lead>();
        // Perform test
        Test.startTest(); 
        for(Lead leadsToUpdate: leads){
            leadsToUpdate.Status = Constants.LEAD_STATUS_QUALIFIED;
            updatedLeads.add(leadsToUpdate);
        }
        if(!updatedleads.isEmpty()){
            update updatedLeads;
        }
        Test.stopTest();
        
        List<FeedItem > FeedItem = [SELECT Id,ParentId FROM FeedItem where  ParentId=:bdrUser.Id];
        System.assertEquals(0, FeedItem.size());

    }
  }
