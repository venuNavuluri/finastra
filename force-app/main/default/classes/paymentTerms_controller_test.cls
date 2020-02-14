@isTest
public class paymentTerms_controller_test {
    
    static testMethod void getLicenseItems() {
        
        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Opportunity opp = new Opportunity(Name = 'uplift test opp', StageName = 'Suspect', CloseDate = Date.today());
        insert opp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = account.Id, SBQQ__Opportunity2__c = opp.Id);
        insert quote;
        
        Opportunity_Billing_Schedule__c obs = new Opportunity_Billing_Schedule__c();
        obs.CurrencyIsoCode = 'USD';
        obs.Opportunity__c = opp.Id;
        obs.Processing_Type__c = 'SVFP';
        obs.Subscription_Option__c = 'New Subscription';
        obs.IsBGProcessed__c = false;
        obs.Quote__c =quote.Id;
        insert obs;
        
        Opportunity_Billing_Schedule_Item__c obs_item = new Opportunity_Billing_Schedule_Item__c();
        obs_item.Name = 'Test';
        obs_item.CurrencyIsoCode = 'USD';
        obs_item.Opportunity_Billing_Schedule__c = obs.Id;
        obs_item.Line__c = 35;
        obs_item.Public__c = false;
        obs_item.Synced_To_NS__c = false;
        insert obs_item;
        
        paymentTerms_controller.getLicenseItems(quote.Id);
        paymentTerms_controller.getServiceItems(quote.Id);
        paymentTerms_controller.deleteOBSItems(new Opportunity_Billing_Schedule_Item__c[]{obs_item});
        paymentTerms_controller.saveOBSItems(new Opportunity_Billing_Schedule_Item__c[]{obs_item}, obs.Id, 'Standard', quote.Id, false);
    }
    
}