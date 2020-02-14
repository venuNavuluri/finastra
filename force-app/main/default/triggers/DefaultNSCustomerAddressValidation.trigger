// Validation to check that there are not more than one bill to and one ship to address set as default

trigger DefaultNSCustomerAddressValidation on NS_Customer_Address__c (before Insert, before Update) {     
   if (Label.Disable_DefaultNSCustomerAddressValidation_Trigger != 'Disable'){  
            Set<Id> AcctBySubId = new Set<Id>();
            
            //Populate a set of account_ids to use in the SOQL query     
            for(NS_Customer_Address__c triggerCustAddress : Trigger.new)
              {
                AcctBySubId.add(triggerCustAddress.Acct_By_Sub__c);
              }
            
            // map of Account By Sub to the map of True and False (with count) of NS Customer Addresses
            Map<ID, Map<Boolean, Integer>> mapResults = new Map<ID, Map<Boolean, Integer>>();
            
            // Validating Bill To
            AggregateResult[] groupedResult =  [SELECT Acct_By_Sub__c, Default_Bill_To__c, Count(Id) countOfRecords FROM NS_Customer_Address__c WHERE Acct_By_Sub__c IN :AcctBySubId GROUP BY Acct_By_Sub__c, Default_Bill_To__c];
            
            for(AggregateResult ar : groupedResult) {
                if(!mapResults.containsKey((ID)ar.get('Acct_By_Sub__c'))) {
                  mapResults.put((ID)ar.get('Acct_By_Sub__c'), new Map<Boolean, Integer>());
                }
                mapResults.get((ID)ar.get('Acct_By_Sub__c')).put((Boolean)ar.get('Default_Bill_To__c'), (Integer)ar.get('countOfRecords'));
              }
            
            
            
            //Iterate through Bill_to records and generate an error for any that have a matching Account By Sub in the map
              for(NS_Customer_Address__c objService : trigger.new) {
                  if(mapResults.containsKey(objService.Acct_By_Sub__c)) {
                     if(mapResults.get(objService.Acct_By_Sub__c).containsKey(objService.Default_Bill_To__c)) {
                     
                     Boolean oldValue = false;
                     if(trigger.isUpdate)
                     oldValue  = trigger.oldmap.get(objService.Id).Default_Bill_To__c;
                     
                     if( objService.Default_Bill_To__c!=false && objService.Default_Bill_To__c != oldValue  && mapResults.get(objService.Acct_By_Sub__c).get(objService.Default_Bill_To__c) >= 1) {
                        objService.addError('Default bill to address already set');
                   
                      }
                    }
                  }
               }
               
            // Validating Ship To
             groupedResult =  [SELECT Acct_By_Sub__c, Default_Ship_To__c, Count(Id) countOfRecords FROM NS_Customer_Address__c WHERE Acct_By_Sub__c IN :AcctBySubId GROUP BY Acct_By_Sub__c, Default_Ship_To__c];
             mapResults = new Map<ID, Map<Boolean, Integer>>();
            for(AggregateResult ar : groupedResult) {
                if(!mapResults.containsKey((ID)ar.get('Acct_By_Sub__c'))) {
                  mapResults.put((ID)ar.get('Acct_By_Sub__c'), new Map<Boolean, Integer>());
                }
                mapResults.get((ID)ar.get('Acct_By_Sub__c')).put((Boolean)ar.get('Default_Ship_To__c'), (Integer)ar.get('countOfRecords'));
              }
            
            
            //Iterate through Ship_to records and generate an error for any that have a matching Account By Sub in the map
              for(NS_Customer_Address__c objService : trigger.new) {
                  if(mapResults.containsKey(objService.Acct_By_Sub__c)) {
                     if(mapResults.get(objService.Acct_By_Sub__c).containsKey(objService.Default_Ship_To__c)) {
                      Boolean oldValue = false;
                      if(trigger.isUpdate)
                      oldValue  = trigger.oldmap.get(objService.Id).Default_Ship_To__c;
                      
                      if(objService.Default_Ship_To__c!=false && objService.Default_Ship_To__c != oldValue  && mapResults.get(objService.Acct_By_Sub__c).get(objService.Default_Ship_To__c) >= 1) {
                        objService.addError('Default ship to address already set');
                        
                      }
                    }
                  }
               }  
               
             if(trigger.isUpdate)
             {
                     
               for(NS_Customer_Address__c objService : trigger.new)
               {
                  Boolean  oldShiptoValue  = trigger.oldmap.get(objService.Id).Default_Ship_To__c;
                  Boolean  oldBilltoValue  = trigger.oldmap.get(objService.Id).Default_Bill_To__c;
                  if( objService.Default_Ship_To__c != oldShiptoValue  || objService.Default_Bill_To__c != oldBilltoValue  )
                  objService.Synced_To_NS__c= false;
               }
             }  
               
               /*  if(!System.isBatch())
                {
                    Map<Id, NS_Customer_Address__c> nsAddressesToAcctBySubMapping =  new  Map<Id, NS_Customer_Address__c>([select Id,Default_Bill_To__c,Default_Ship_To__c , Acct_By_Sub__c from NS_Customer_Address__c  where Id in :Trigger.new]);
                    
                    for(ID NSCustoAddressID: nsAddressesToAcctBySubMapping.KeySet())
                    {
                        NS_Customer_Address__c triggerCustAddress = nsAddressesToAcctBySubMapping.get(NSCustoAddressID); // redundant get it from the trigger
                            
                        Map<Id, NS_Customer_Address__c> nsAddresses =  new Map<Id, NS_Customer_Address__c>();
                        nsAddresses.putAll([Select Id, Acct_By_Sub__c,Name, Address_1__c, Default_Bill_To__c,Default_Ship_To__c from NS_Customer_Address__c where Acct_By_Sub__c = :triggerCustAddress.Acct_By_Sub__c]);
            
                        for( Id key : nsAddresses.keySet())
                        {
                            NS_Customer_Address__c loopCustAddresses = nsAddresses.get(key);
                       
                            if(loopCustAddresses.Default_Bill_To__c  == true && triggerCustAddress.Id !=loopCustAddresses.Id && Trigger.newmap.get(triggerCustAddress.Id).Default_Bill_To__c!=false)
                            Trigger.newmap.get(triggerCustAddress.Id).addError('Default bill to address already set');
                                
                            if(loopCustAddresses.Default_Ship_To__c  == true && triggerCustAddress.Id !=loopCustAddresses.Id && Trigger.newmap.get(triggerCustAddress.Id).Default_Ship_To__c!=false)
                            Trigger.newmap.get(triggerCustAddress.Id).addError('Default ship to address already set');
            
                        }
                   }
                }
            }
            */ 
            }    
}