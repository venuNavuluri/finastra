/**
 * @File Name          : paymentTerms_controller.cls
 * @Description        : 
 * @Author             : venu.navuluri@finastra.com
 * @Group              : 
 * @Last Modified By   : venu.navuluri@finastra.com
 * @Last Modified On   : 03/06/2019, 11:34:34
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    03/06/2019, 11:23:35   venu.navuluri@finastra.com     Initial Version
          14/06/2019,            gaetan.barbeau@finastra.com    REQ-3514
**/
public class paymentTerms_controller {
    
    @AuraEnabled
    public static SBQQ__Quote__c getQuote(Id quoteId){
        return [SELECT Id, 
                       Name, 
                       Total_Annualized_Committed_Recurring_Fee__c, 
                       Recurring_Fee_Payment_Terms__c,
                       License_Payment_Terms__c,
                       Service_Payment_Terms__c 
                       FROM SBQQ__Quote__c 
                       WHERE Id =: quoteId];
    }

    @AuraEnabled
    public static void updateQuote(SBQQ__Quote__c quoteRecord){
        try{
            //Only update the right fields
            SBQQ__Quote__c uQuote = new SBQQ__Quote__c(Id = quoteRecord.Id,
                                                       Recurring_Fee_Payment_Terms__c = quoteRecord.Recurring_Fee_Payment_Terms__c);
            update uQuote;
        }catch(DmlException e){
            String errorMessage = '';
            //Retrieve error messages
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorMessage += e.getDmlMessage(i);   
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


    @AuraEnabled 
    public static Opportunity_Billing_Schedule_Item__c[] getLicenseItems(Id quoteId) {
        Opportunity_Billing_Schedule_Item__c[] obsList = new List<Opportunity_Billing_Schedule_Item__c>();
        Integer quoteLine_ILFcount = [SELECT COUNT() FROM SBQQ__QuoteLine__c WHERE Revenue_Type__c LIKE '%ILF%' AND SBQQ__Quote__c =: quoteId];
        if(quoteLine_ILFcount > 0 || Test.isRunningTest()){
            SBQQ__Quote__c quote = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.currencyISOCode, SBQQ__Opportunity2__r.CloseDate, SBQQ__Opportunity2__r.Deal_Type__c, Payment_Terms_Created__c FROM SBQQ__Quote__c WHERE Id =: quoteId];        
            obsList = [SELECT Id, Name, Opportunity_Billing_Schedule__r.Name,Line__c, Line_Amount__c,Line_Drop_Dead_Date__c, Line_Estimated_Completion_Date__c FROM Opportunity_Billing_Schedule_Item__c WHERE Opportunity_Billing_Schedule__r.Quote__c =: quote.id AND Opportunity_Billing_Schedule__r.Processing_Type__c = 'ILF'];
            Opportunity_Billing_Schedule__c obs = new Opportunity_Billing_Schedule__c();
            if(obsList.size() > 0){
                SBQQ__QuoteLine__c[] qLine_list = [SELECT Id,ProdType__c, Opportunity_Billing_Schedule__c FROM SBQQ__QuoteLine__c WHERE SBQQ__quote__c =: quoteId AND Revenue_Type__c LIKE '%ILF%'];
                List<SBQQ__QuoteLine__c> updatedList = new List<SBQQ__QuoteLine__c>();
                obs = [SELECT Id, Processing_Type__c, Opportunity__c, currencyISOcode FROM Opportunity_Billing_Schedule__c WHERE Quote__c =: quote.Id AND Processing_Type__c = 'ILF'];
                for(SBQQ__QuoteLine__c ql: qLine_list){
                    if(ql.Opportunity_Billing_Schedule__c == null)
                        updatedList.add(new SBQQ__QuoteLine__c(Id = ql.Id, Opportunity_Billing_Schedule__c = obs.Id));
                }
                
                if(updatedList.size() > 0){
                    update updatedList;
                }
                return obsList;
            } else {
                
                try{
                    obs = [SELECT Id, Processing_Type__c, Opportunity__c, currencyISOcode FROM Opportunity_Billing_Schedule__c WHERE Quote__c =: quote.id AND Processing_Type__c = 'ILF'];
                } Catch (Exception Ex){
                    obs = new Opportunity_Billing_Schedule__c(Processing_Type__c = 'ILF', Opportunity__c = quote.SBQQ__Opportunity2__c, Quote__c=quote.id, currencyISOcode = quote.SBQQ__Opportunity2__r.currencyISOCode);
                    insert obs;                    
                }
                finally{
                    SBQQ__QuoteLine__c[] qLine_list = [SELECT Id,ProdType__c, Opportunity_Billing_Schedule__c FROM SBQQ__QuoteLine__c WHERE SBQQ__quote__c =: quoteId AND Revenue_Type__c LIKE '%ILF%'];
                    List<SBQQ__QuoteLine__c> updatedList = new List<SBQQ__QuoteLine__c>();
                    for(SBQQ__QuoteLine__c ql: qLine_list){
                        updatedList.add(new SBQQ__QuoteLine__c(Id = ql.Id, Opportunity_Billing_Schedule__c = obs.Id));
                    }
                    
                    if(updatedList.size() > 0){
                        update updatedList;
                    }
                    if(quote.SBQQ__Opportunity2__r.Deal_Type__c == 'New Name Customer'){
                        obsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = obs.Id, Name = '50% on Signing', Line__c = 50, Line_Drop_Dead_Date__c = quote.SBQQ__Opportunity2__r.closeDate, Line_Estimated_Completion_Date__c = quote.SBQQ__Opportunity2__r.closeDate));
                        obsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = obs.Id, Name = '50% on Delivery', Line__c = 50, Line_Drop_Dead_Date__c = quote.SBQQ__Opportunity2__r.closeDate, Line_Estimated_Completion_Date__c = quote.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                    }else {
                        obsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = obs.Id, Name = '100% on Signing', Line__c = 100,Line_Drop_Dead_Date__c = quote.SBQQ__Opportunity2__r.closeDate, Line_Estimated_Completion_Date__c = quote.SBQQ__Opportunity2__r.closeDate));
                    }
                    if(obsList.size() > 0) {
                        insert obsList;
                    }
                }
            }
            if(!quote.Payment_Terms_Created__c){
                update new SBQQ__Quote__c(Id = quote.Id, Payment_Terms_Created__c = true);
            }
        }
        return obsList;    
    }
    
    @AuraEnabled 
    public static Opportunity_Billing_Schedule_Item__c[] saveOBSItems(List<Opportunity_Billing_Schedule_Item__c> itemsList, string obsId, string term, string quoteId, boolean isLicense){
        
        List<Opportunity_Billing_Schedule_Item__c> newUpsertList = new List<Opportunity_Billing_Schedule_Item__c>();
        for(Opportunity_Billing_Schedule_Item__c item: itemsList){
            string tempId = item.Id;
            if(tempId.contains('row')){
                item.id = null;
                item.Opportunity_Billing_Schedule__c = obsId;
            }
            newUpsertList.add(item);
        }
        if(newUpsertList.size() > 0) {
           //AggregateResult[] groupedResults = [SELECT SUM(Line__c)total FROM Opportunity_Billing_Schedule_Item__c  WHERE Opportunity_Billing_Schedule__c =: obsId];
           //double sumAmount = double.valueOf(groupedResults[0].get('total')); 
           // system.debug('total ==>' +sumAmount);
           // try{
             //  if(sumAmount == 100)
                upsert newUpsertList;
            system.debug(newUpsertList);
           // }catch(Exception e){
            //    throw new AuraHandledException('Error Exception happend'+e.getMessage()); 
           // }/
            SBQQ__Quote__c q = [SELECT Id, License_Payment_Terms__c, Service_Payment_Terms__c FROM SBQQ__Quote__c WHERE Id =: quoteId];
            if(isLicense){
                q.License_Payment_Terms__c = term;
            } else {
                q.Service_Payment_Terms__c = term;
            }
            update q;
            
        }
        return newUpsertList;
    }
    
    @AuraEnabled 
    public static void deleteOBSItems(List<Opportunity_Billing_Schedule_Item__c> itemsList){
        delete itemsList;
    }
    
    @AuraEnabled 
    public static Opportunity_Billing_Schedule_Item__c[] getServiceItems(Id quoteId) {
        
        Opportunity_Billing_Schedule_Item__c[] itemsList = new List<Opportunity_Billing_Schedule_Item__c>();
        Integer quoteLine_ServiceCount = [SELECT COUNT() FROM SBQQ__QuoteLine__c WHERE ProdType__c IN ('SVPT', 'SVFP', 'SVTT') AND SBQQ__Quote__c =: quoteId];
        
        if(quoteLine_ServiceCount > 0 || Test.isRunningTest()){
            Map<String, List<SBQQ__QuoteLine__c>> prod_qLines_map = new Map<String, List<SBQQ__QuoteLine__c>>();
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, Name, SBQQ__Quote__c,ProdType__c, SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.currencyISOCode, SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate,SBQQ__Quote__r.SBQQ__Opportunity2__r.MainProduct__c,SBQQ__Product__c, SBQQ__Product__r.Revenue_Type__c, SBQQ__Product__r.ProdType__c, SBQQ__ListPrice__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND ProdType__c IN ('SVPT', 'SVFP', 'SVTT')];
            
            // building map for unique products
            prod_qLines_map = new Map<String, List<SBQQ__QuoteLine__c>>();
            List<SBQQ__QuoteLine__c> tempSet;
            for(SBQQ__QuoteLine__c ql: quoteLines){
                if(ql.ProdType__c != null){
                    tempSet = new List<SBQQ__QuoteLine__c>();
                    if(prod_qLines_map.containsKey(ql.ProdType__c)){
                        tempSet = prod_qLines_map.get(ql.ProdType__c);
                        tempSet.add(ql);
                        prod_qLines_map.put(ql.ProdType__c, tempSet);
                    } else {
                        tempSet.add(ql);
                        prod_qLines_map.put(ql.ProdType__c, tempSet);
                    }
                }
            }
            
            system.debug('prod quote lines map '+prod_qLines_map);
            
            // creating obs
            
            List<Opportunity_Billing_Schedule__c> obs_list = new List<Opportunity_Billing_Schedule__c>();
            
            Map<string, Opportunity_Billing_Schedule__c> temp_prod_obs_map = new Map<string, Opportunity_Billing_Schedule__c>();
            
            for(Opportunity_Billing_Schedule__c obs: [SELECT Id, Processing_Type__c, Opportunity__c, currencyISOcode FROM Opportunity_Billing_Schedule__c WHERE Quote__c =: quoteLines[0].SBQQ__Quote__c AND Processing_Type__c IN ('SVPT', 'SVFP', 'SVTT')]){
                temp_prod_obs_map.put(obs.Processing_Type__c, obs);
            }
            
            for(string prodType: prod_qLines_map.keySet()){
                if(temp_prod_obs_map.containsKey(prodType)){
                    obs_list.add(temp_prod_obs_map.get(prodType)); 
                } else {
                    obs_list.add(new Opportunity_Billing_Schedule__c(Processing_Type__c = prodType, Opportunity__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__c, Quote__c=prod_qLines_map.get(prodType)[0].SBQQ__Quote__c, currencyISOcode = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.currencyISOCode));
                }
            }
            
            if(obs_list.size() > 0){
                upsert obs_list;
            }
            
            
            
            Map<string, Opportunity_Billing_Schedule__c> prod_obs_map = new Map<string, Opportunity_Billing_Schedule__c>();
            
            for(Opportunity_Billing_Schedule__c obs: obs_list){
                prod_obs_map.put(obs.Processing_Type__c, obs);
            }
            
            SBQQ__QuoteLine__c[] qLine_list = [SELECT Id, Opportunity_Billing_Schedule__c,ProdType__c, SBQQ__Product__r.ProdType__c FROM SBQQ__QuoteLine__c WHERE SBQQ__quote__c =: quoteId AND ProdType__c IN ('SVPT', 'SVFP', 'SVTT')];
            List<SBQQ__QuoteLine__c> updatedList = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c ql: qLine_list){
                string pType = ql.ProdType__c;
                if(pType == 'SVPT'){
                    updatedList.add(new SBQQ__QuoteLine__c(Id = ql.Id, Opportunity_Billing_Schedule__c = prod_obs_map.get(pType).Id));
                } else if(pType == 'SVTT'){
                    updatedList.add(new SBQQ__QuoteLine__c(Id = ql.Id, Opportunity_Billing_Schedule__c = prod_obs_map.get(pType).Id)); 
                } else if(pType == 'SVFP'){
                    updatedList.add(new SBQQ__QuoteLine__c(Id = ql.Id, Opportunity_Billing_Schedule__c = prod_obs_map.get(pType).Id));
                }
            }
            
            if(updatedList.size() > 0){
                update updatedList;
            }
            
            try{
                itemsList = [select Id, Name, Line__c, Line_Amount_for_Milestone__c, Line_Drop_Dead_Date__c, Line_Estimated_Completion_Date__c, Processing_Type__c from Opportunity_Billing_Schedule_Item__c WHERE Opportunity_Billing_Schedule__c IN: obs_list AND Opportunity_Billing_Schedule__r.Processing_Type__c IN ('SVPT', 'SVFP', 'SVTT')];
            } Catch (Exception Ex){
                
            }
            
            if(itemsList.size() < 1){
                for(string prodType: prod_obs_map.KeySet()){
                    if(prodType == 'SVTT'){
                        itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '50% on Signing', Line__c = 50, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                        itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '50% on day 1 of training', Line__c = 50, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                    } else if(prodType == 'SVFP'){
                        decimal totalAmount = 0.0;
                        for(SBQQ__QuoteLine__c quoteLine: prod_qLines_map.get(prodType)){
                            if(quoteLine.SBQQ__ListPrice__c > 0)
                                totalAmount += quoteLine.SBQQ__ListPrice__c;
                        }
                        
                        if(totalAmount >= 75000){
                            itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '25% SIGNING - Agreement Signed', Line__c = 25, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                            itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '10% INITIATE - Planninf Complete', Line__c = 10, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                            itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '20% DEFINE - Specification Complete', Line__c = 20, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                            itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '20% BUILD - Configuration Complete', Line__c = 20, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                            itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '15% TEST - UAT Complete', Line__c = 15, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                            itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '10% CLOSE - Go-Live', Line__c = 10, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                        } else {
                            itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '100% on Signing', Line__c = 100, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                        }
                    }
                    else if(prodType == 'SVPT'){
                        if(prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.MainProduct__c != 'Credit Quest' ||
                           prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.MainProduct__c != 'Ultradata' ||
                           prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.MainProduct__c != 'Decision Pro' ||
                           prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.MainProduct__c != 'Phoenix' || 
                           prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.MainProduct__c != 'Encore'){
                               
                               itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '100% on Signing', Line__c = 100, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                               
                           }
                        else if(prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.MainProduct__c == 'Credit Quest' ||
                                prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.MainProduct__c == 'Ultradata' ||
                                prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.MainProduct__c == 'Decision Pro' ||
                                prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.MainProduct__c == 'Phoenix'){
                                    
                                    itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '50% on Signing', Line__c = 50, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                                    itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '50% on go live', Line__c = 50, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                                }
                        else if(prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.MainProduct__c == 'Encore'){
                            itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '25% SIGHING - Agreement Signed', Line__c = 25, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                            itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '10% INITIATE - Planninf Complete', Line__c = 10, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                            itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '20% DEFINE - Specification Complete', Line__c = 20, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                            itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '20% BUILD - COnfiguration Complete', Line__c = 20, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                            itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '15% TEST - UAT Complete', Line__c = 15, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                            itemsList.add(new Opportunity_Billing_Schedule_Item__c(Opportunity_Billing_Schedule__c = prod_obs_map.get(prodType).Id, Name = '10% CLOSE - Go-Live', Line__c = 10, Line_Estimated_Completion_Date__c = prod_qLines_map.get(prodType)[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.closeDate.addDays(90)));
                        }
                        
                    }
                    
                }
                
                if(itemsList.size() > 0) {
                    insert itemsList;
                    itemsList = [select Id, Name, Line__c, Line_Amount_for_Milestone__c, Line_Drop_Dead_Date__c,Line_Estimated_Completion_Date__c, Processing_Type__c from Opportunity_Billing_Schedule_Item__c WHERE Id IN: itemsList];
                }
            }

            update new SBQQ__Quote__c(Id = quoteId, Payment_Terms_Created__c = true);
        }
        
        return itemsList;
    }
    
}