@isTest
private with sharing class AccountsSupportedTriggerMethods_Test {

    static testmethod void testAddPortalSharingForContactUser(){
    
        Account newAcc =  TestUtils.getAccount('tests acc');
        newAcc.Site = 'Parent';
        insert newAcc;
        
        Account childAcc = TestUtils.getAccount('tests ch');
        childAcc.Site = 'Child';
        insert childAcc;
        
        Contact portalContact1 = TestUtils.getContact(newAcc, 'PortalContac1t');
        insert portalContact1;
            
        User u1 = TestUtils.getCustomerPortalUser('test.portal1@gmail.com', portalContact1);
        u1.Alias = 'por1user';
        u1.email='test@gmail.com';            
        insert u1;
        
        Contact portalContact2 = TestUtils.getContact(newAcc, 'PortalContac2');
        insert portalContact2;
        
        User u2 = TestUtils.getCustomerPortalUser('test2.portal12@gmail.com', portalContact2);
        u2.Alias = 'por2user';
        u2.email='test@gmail.com';
        insert u2;
        
        Test.startTest();
                
        List<Accounts_Supported__c> lsupp = new List<Accounts_Supported__c>();
        Accounts_Supported__c asupp = new Accounts_Supported__c(Contact__c=portalContact1.Id, Supported_Account__c=childAcc.Id);
        lsupp.add(asupp);
        
        Accounts_Supported__c asupp1 = new Accounts_Supported__c(Contact__c=portalContact2.Id, Supported_Account__c=childAcc.Id);
        lsupp.add(asupp1);
        insert lsupp; 
        
        asupp.name='testing';       
        update asupp;
     
        Test.stoptest();
    }

}