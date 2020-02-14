/**


REQ-2872 - G.B 20.05.2019


**/



public class ContractRLFHolidayController {

//Retrieve all RLF subscription types
    @AuraEnabled(cacheable=true)
    public static List<String> getRLFsubscriptionTypes(String contractId){
        List <SBQQ__Subscription__c> susbcriptionList = getSubscriptions(contractId);
        Set <String> rLFTypeSubsOptions = new Set <String>();
        for(SBQQ__Subscription__c sub:susbcriptionList){
            if(sub.SBQQ__Product__r.Product_Set__c != null)
                rLFTypeSubsOptions.add(sub.SBQQ__Product__r.Product_Set__c);
        }
        List<String> returnOptValues = new List<String>();
        returnOptValues.addAll(rLFTypeSubsOptions);
        return returnOptValues;
    }


    //Retrieve all related subscriptions 
    @AuraEnabled(cacheable=true)
    public static List <SBQQ__Subscription__c> getSubscriptions(String contractId){
        Map <Id,SBQQ__Subscription__c> subsMap = new Map <Id,SBQQ__Subscription__c>([SELECT Id, 
                                                                                            Name,
                                                                                            SBQQ__ProductName__c,
                                                                                            CPI_Uplift_Review_Date__c,
                                                                                            SBQQ__Product__r.Product_Set__c,
                                                                                            SBQQ__Contract__c, 
                                                                                            ProdType__c,
                                                                                            RF_Start_Planned_Date__c, 
                                                                                            Next_Billing_Date__c,
                                                                                            SBQQ__BillingType__c,
                                                                                            Next_SO_generation_Date__c, 
                                                                                            Billing_Group__c,
                                                                                            SO_Generation_Advance__c,
                                                                                            SBQQ__Contract__r.Recurring_Fees_Start_Planned__c
                                                                                            FROM SBQQ__Subscription__c 
                                                                                            WHERE SBQQ__Contract__c =:contractId
                                                                                            AND Sales_Order_Type__c = 'RLF'
                                                                                            ORDER BY RF_Start_Planned_Date__c desc]);


        return subsMap.values();
        
    }
    //Need to pass the entire list of subscription and not the searchlist
    @AuraEnabled
    public static void saveSubscriptions(List <SBQQ__Subscription__c> subscriptionsToSaveList){
        List<Id> bilingGroupIds = new List<Id>();
        Map<Id, SBQQ__Subscription__c> subscriptionsToSaveMap = new Map<Id, SBQQ__Subscription__c>();
        //Inline datable editing only contains the updated fields.
        try{
            if(!subscriptionsToSaveList.isEmpty()){
                for(SBQQ__Subscription__c subToSave: subscriptionsToSaveList){
                
                    if(subToSave.RF_Start_Planned_Date__c != null){
                        //Set next billing day
                        subToSave.Next_Billing_Date__c = subToSave.RF_Start_Planned_Date__c;
                        Integer sOGenerationAdvance = 0;
                        if(subToSave.SBQQ__BillingType__c == 'Advance'){
                            sOGenerationAdvance = subToSave.SO_Generation_Advance__c != null? (Integer)(-1 * subToSave.SO_Generation_Advance__c):0;
                        } else if(subToSave.SBQQ__BillingType__c == 'Arrears'){
                            sOGenerationAdvance = subToSave.SO_Generation_Advance__c != null? (Integer) subToSave.SO_Generation_Advance__c:0;
                        }
                        //Set the Next So generation date based on billing type and SO Generation Advance 
                        subToSave.Next_SO_generation_Date__c =  (subToSave.Next_Billing_Date__c.addDays(sOGenerationAdvance) < System.today())?
                                                                System.today().addDays(1) : subToSave.Next_Billing_Date__c.addDays(sOGenerationAdvance);
                        //Billing group dates will need to be recalculated 
                        if(subToSave.Billing_Group__c != null)
                            bilingGroupIds.add(subToSave.Billing_Group__c);
                    } 
                    //Add in a map the list of subscription records that need to be saved
                    subscriptionsToSaveMap.put(subToSave.Id,subToSave);
                }
                //save subcriptions that have been updated
                update subscriptionsToSaveMap.values();
                //Get earliest billing group dates
                Map<Id, List<Date>> bgIdBillingDatesMap = getEarliestBGDates(bilingGroupIds);
                //Update related billing groups
                updateBGBillingDates(bgIdBillingDatesMap);
            }else{
                AuraHandledException auraException = new AuraHandledException('No subscriptions to save. Please select at least one subscription and enter a date.');
                auraException.setMessage('No subscriptions to save. Please select at least one subscription and enter a date.');
                throw auraException;
            }
        }catch(DmlException e){
            String errorMessage = '';
            //Retrieve error messages
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorMessage += (subscriptionsToSaveMap.containsKey(e.getDmlId(i))?subscriptionsToSaveMap.get(e.getDmlId(i)).Name+' : ' : '') + e.getDmlMessage(i);   
            }
            AuraHandledException auraException = new AuraHandledException(errorMessage);
            auraException.setMessage(errorMessage);
            throw auraException;
        }catch(Exception e){
            AuraHandledException auraException = new AuraHandledException(e.getMessage());
            auraException.setMessage(e.getMessage());
            throw auraException;
        }
    }

    private static void updateBGBillingDates (Map<Id, List<Date>> bgIdBillingDatesMap){
        Map<Id,Billing_Group__c> updateBGsMap = new Map<Id,Billing_Group__c>();
        Date earliestBGNextBillingDate;
        Date earliestBGNextSOGenerationDate;
        for(Id bgId:bgIdBillingDatesMap.keySet()){
            //First value is the earliest next billing date
            earliestBGNextBillingDate = bgIdBillingDatesMap.get(bgId)[0];
            //Second value is the earliest next SO generation date
            earliestBGNextSOGenerationDate = bgIdBillingDatesMap.get(bgId)[1];
            //Only update the field with a new value
            if(earliestBGNextSOGenerationDate != null || earliestBGNextBillingDate != null){
                Billing_Group__c bg = new  Billing_Group__c(Id = bgId);
                if(earliestBGNextBillingDate != null)
                    bg.Next_Billing_Date__c = earliestBGNextBillingDate;
                if(earliestBGNextSOGenerationDate != null)
                    bg.Next_SO_generation_Date__c = earliestBGNextSOGenerationDate;
               
                updateBGsMap.put(bg.Id,bg);
            }
        }
        if(!updateBGsMap.isEmpty())
            update updateBGsMap.values();
    }

    private static Map<Id, List<Date>> getEarliestBGDates (List<Id> bilingGroupIds){
        Date earliestBGNextBillingDate;
        Date earliestBGNextSOGenerationDate;
        Map<Id, List<Date>> bgIdBillingDatesMap = new Map<Id, List<Date>>();
        for(SBQQ__Subscription__c sub: [SELECT Id,
                                               Next_billing_Date__c,
                                               Next_SO_generation_Date__c,
                                               Billing_Group__c
                                               FROM SBQQ__Subscription__c
                                               WHERE Billing_Group__c IN:bilingGroupIds
                                               AND (Next_billing_Date__c !=null OR
                                                    Next_SO_generation_Date__c !=null) ]){
            //Group dates by billing group ids
            if(bgIdBillingDatesMap.containsKey(sub.Billing_Group__c)){
                earliestBGNextBillingDate = bgIdBillingDatesMap.get(sub.Billing_Group__c)[0];
                earliestBGNextSOGenerationDate = bgIdBillingDatesMap.get(sub.Billing_Group__c)[1];
            }else{
                //Init date variables
                earliestBGNextBillingDate = sub.Next_billing_Date__c;
                earliestBGNextSOGenerationDate = sub.Next_SO_generation_Date__c;
            }
            //Capture the earliest next billing date
            earliestBGNextBillingDate = (sub.Next_billing_Date__c != null && sub.Next_billing_Date__c < earliestBGNextBillingDate )?
                                        sub.Next_billing_Date__c:earliestBGNextBillingDate;
            //Capture the earliest next SO generation date
            earliestBGNextSOGenerationDate = (sub.Next_SO_generation_Date__c != null && sub.Next_SO_generation_Date__c < earliestBGNextSOGenerationDate )?
                                                sub.Next_SO_generation_Date__c:earliestBGNextSOGenerationDate;

            bgIdBillingDatesMap.put(sub.Billing_Group__c,new List<Date>{earliestBGNextBillingDate, earliestBGNextSOGenerationDate});
        }
        return bgIdBillingDatesMap;
    }

}