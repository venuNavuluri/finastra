trigger OpportunityAfterInsert on Opportunity (after insert) {
/*
    Name        :   OpportunityAfterInsert
    
    Purpose     :   The trigger contains business logic that's supposed to occur when opportunity gets created.
                    This trigger will be fired on insert of Opportunity record(s) single or in batch.
                    
    Special Considerations: None 
    
    Parameters  :   N/A
                    
    Invoked From    : Auto-triggered on Opportunity record creation 

    Triggering Condition:   For all new opportunities

    Returns     :   N/A
                        
    Notes       :   1. The initial version of the trigger was to fulfil Quota Credits requirements. The details of the requirements can be 
                    obtained at XXXXXXXXXXXXXXXXX 
                        
    Modification Log
    
    User            Date                Description
    --------------      ----------          --------------------------------------------------------------
    Prashant Bhure      05/22/2009          Created - Initial version - To create related Quota Credit record.
    
    */
    if(Trigger.isInsert)
    {
        RecordType lQuotaRecordType = [SELECT Id FROM RecordType WHERE Name = 'Direct Master Credit' AND sObjectType = 'Com_Splits__c'];
        
        FOR (Integer li_counter = 0; li_counter < Trigger.new.size(); li_counter++){
            Com_Splits__c lQuotaCredits = new Com_Splits__c();
            lQuotaCredits.Opportunity__c = Trigger.new[li_counter].Id;
            lQuotaCredits.RecordTypeId = lQuotaRecordType.Id;
            lQuotaCredits.Employee_Name__c = Trigger.new[li_counter].OwnerId;
            lQuotaCredits.CurrencyIsoCode = Trigger.new[li_counter].CurrencyIsoCode;
                    
            INSERT  lQuotaCredits;
        }
        //This is to create the Contact Roles on Opportunity if the Misys Entity is attached to it.
        OpportunityTriggerMethods.UpdateContactRoles(trigger.newMap, new map<Id, Opportunity>());
    }
    /*
    else if(Trigger.isUpdate)
    { 
        Decimal OpptyAmt = 0,OldOpptyAmt = 0;
        Integer OpptyOrobablity = 0,OldOpptyOrobablity = 0;
            
        if(Trigger.new[0].Amount != null)
            OpptyAmt = Trigger.new[0].Amount;
        if(Trigger.new[0].Probability != null)
            OpptyOrobablity = Trigger.new[0].Probability;
        if(Trigger.oldmap.get(Trigger.new[0].Id).Amount != null)
            OldOpptyAmt = Trigger.oldmap.get(Trigger.new[0].Id).Amount;
        if(Trigger.oldmap.get(Trigger.new[0].Id).Probability != null)
            OldOpptyOrobablity = Trigger.oldmap.get(Trigger.new[0].Id).Probability;
        if(OldOpptyAmt >= 500000 && OpptyAmt != OldOpptyAmt && OpptyOrobablity >= 75 && OpptyOrobablity != OldOpptyOrobablity)
            
    }*/
}