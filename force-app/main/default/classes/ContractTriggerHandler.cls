/**
 * Handler class for the OpportunityTrigger
 */

public with sharing class ContractTriggerHandler extends TriggerHandler {

    protected override void beforeInsert() {
        System.debug('Before Insert ContractTriggerHandler Begins');
        
        Set<Id> opportunityIds = new Set<Id>();
        for (Contract c : (List<Contract>) Trigger.new) {
            if (c.SBQQ__Opportunity__c != null) {
            	opportunityIds.add(c.SBQQ__Opportunity__c);
            }
        }
        
        Map<Id, Id> oppIdQuoteIdMap = new Map<Id, Id>();
        if (opportunityIds != null && opportunityIds.size() > 0) {
            for (Opportunity opp : [select Id, SBQQ__PrimaryQuote__c from Opportunity where Id in :opportunityIds]) {
                if (opp.SBQQ__PrimaryQuote__c != null) {
                    oppIdQuoteIdMap.put(opp.Id, opp.SBQQ__PrimaryQuote__c);
                }
            }
        }
		
        Map<Id, SBQQ__Quote__c> quoteIdQuoteMap = new Map<Id, SBQQ__Quote__c>();
        if (oppIdQuoteIdMap.values().size() > 0) {
        	for (SBQQ__Quote__c quote : [select Id, Standard_Index__c, Additional_Increase__c, CPI__c, CPI_Index_Type__c, Maximum_Rate__c, Minimum_Rate__c, No_CPI__c, Use_Existing_CPI__c, Apply_Standard_CPI__c from SBQQ__Quote__c where Id in :oppIdQuoteIdMap.values()]) {
                quoteIdQuoteMap.put(quote.id, quote);
            }    
        }
        
		//Populate the CPI fields from the primary quote.
        for (Contract c : (List<Contract>) Trigger.new) {
            if (c.SBQQ__Opportunity__c != null) {
                if (oppIdQuoteIdMap.containsKey(c.SBQQ__Opportunity__c)) {
                    Id quoteId = oppIdQuoteIdMap.get(c.SBQQ__Opportunity__c);
                    if (quoteIdQuoteMap.containsKey(quoteId)) {
                        SBQQ__Quote__c dataQuote = quoteIdQuoteMap.Get(quoteId);
                         if (String.isBlank(dataQuote.Standard_Index__c) == false) {
                            c.Standard_Index__c = dataQuote.Standard_Index__c;
                        }
                   
                        if (String.isBlank(dataQuote.CPI__c) == false) {
                            c.CPI__c = dataQuote.CPI__c;
                        }
                        if (String.isBlank(dataQuote.CPI_Index_Type__c) == false) {
                            c.CPI_Index_Type__c = dataQuote.CPI_Index_Type__c;
                        }
                        //These 3 fields can now be blank, the default value was removed.
                        c.Additional_Increase__c = dataQuote.Additional_Increase__c;
                        c.Maximum_Rate__c  = dataQuote.Maximum_Rate__c ;
                        c.Minimum_Rate__c  = dataQuote.Minimum_Rate__c ;
                        
                        c.No_CPI__c = dataQuote.No_CPI__c;
                        c.Use_Existing_CPI__c = dataQuote.Use_Existing_CPI__c;
                        c.Apply_Standard_CPI__c = dataQuote.Apply_Standard_CPI__c;
                    }
                }
            }
        }
        System.debug('Before Insert ContractTriggerHandler finished');
    }
}