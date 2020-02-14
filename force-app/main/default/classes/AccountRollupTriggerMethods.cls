public class AccountRollupTriggerMethods {
    
    
    public static void rollupValues(list<Account_Rollup__c> accountRollupList){
        
        set<id> accountIds = new set<id>();
        set<id> parentRollupIds = new set<id>();
        set<id> parentAccountRUPIds = new set<id>();
        list<Account_Rollup__c> parentAccountRollups = new list<Account_Rollup__c>();
        map<id, Account> accountMap;
        map<id, list<Account_Rollup__c>> accountRollupMap = new map<id, list<Account_Rollup__c>>();
        
        set<id> parentAccRollupIds = new set<id>();
        
        if(trigger.isBefore){
            system.debug('Test ===');
            for(Account_Rollup__c arp : accountRollupList){
                if(arp.Account__c != null){
                    accountIds.add(arp.Account__c);
                    arp.Number_of_contacts_attending_MF_Sol__c = 0;
                    arp.Number_of_active_product_sets__c = 0;
                    arp.Number_of_C_D_level_meetings__c = 0;
                    arp.Number_of_closed_won_opportunities__c = 0;
                    arp.Number_of_CVT_engagements__c = 0;
                    arp.Number_of_demos__c = 0;
                    arp.Number_of_MQLs_Generated__c = 0;
                    arp.Number_of_presales_client_meetings__c = 0;
                    arp.Number_of_Qualified_Contacts__c = 0;
                    arp.Number_of_SS1_opportunities_created__c = 0;
                    arp.Qualified_pipeline_USD__c = 0;
                    arp.Sum_of_closed_won_ILF_USD__c = 0;
                    arp.Sum_of_closed_won_Services_USD__c = 0;
                    arp.Sum_of_Invoices_outstanding_USD__c = 0;
                    arp.Sum_of_partner_co_sell_USD__c = 0;
                    arp.Sum_of_RLF_at_risk_USD__c = 0;
                    arp.Sum_Partner_originated_USD__c = 0;
                    //arp.Number_of_certified_partner_consultants__c = 'No';
                    arp.Number_of_certified_partner_consultants__c = 0;
                    arp.Business_outcomes_achieved__c = 50;
                    arp.Number_of_contacts_on_Misys_University__c = 0;
                    arp.Number_of_contacts_on_CABs_SAGs_and_UGs__c = 0;
                    arp.Number_of_products_they_act_as_reference__c = 0;
                    arp.Number_of_supported_reference_activities__c = 0;
                    arp.Unqualified_pipeline_USD__c = 0;
                    arp.Marketing_or_PR_endorsement_provided__c = 'No';
                    arp.Deviation_from_original_margin__c = 50;
                    arp.Deviation_from_intended_go_live__c = 50;
                    arp.Ave_resolution_time_for_support_request__c = 0;
                    arp.Aged_backlog_of_cases__c = 0;
                    arp.Open_defects_with_targeted_fix_date__c = 0;

                    //collect the parent Rollup Ids
                    if(arp.Type__c == 'Roll-Up Parent' || arp.Type__c == 'Roll-Up Group'){
                        parentAccRollupIds.add(arp.Id);
                    }	
                }
            }
            if(accountIds != null && accountIds.size() > 0){
                accountMap = new map<id, Account>([select id, Name, Ultimate_Parent__c, Customer_Group__c, Has_certified_consultants__c, 
                                Business_outcomes_achieved__c, Deviation_from_original_margin__c, Number_of_products_they_act_as_reference__c, 
                                Number_of_supported_reference_activities__c, Marketing_or_PR_endorsement_provided__c, Number_of_contacts_on_Misys_University__c,
                                Number_of_contacts_on_CABs_SAGs_and_UGs__c, Deviation_from_intended_go_live__c
                                from Account where id in :accountIds and (Type != 'Roll-Up Parent' and Type != 'Roll-Up Group')]);
            }
            for(Account_Rollup__c arp : accountRollupList){
                if(arp.Account__c != null){
                    if(accountMap != null && accountMap.size() > 0){
                        //Was commented earlier
                        //arp.Number_of_certified_partner_consultants__c = accountMap.get(arp.Account__c).Number_of_certified_partner_consultants__c;
                        if(accountMap.containsKey(arp.Account__c) && accountMap.get(arp.Account__c).Business_outcomes_achieved__c != null){
                            arp.Business_outcomes_achieved__c = accountMap.get(arp.Account__c).Business_outcomes_achieved__c;
                        }
                        if(accountMap.containsKey(arp.Account__c) && accountMap.get(arp.Account__c).Deviation_from_original_margin__c != null){
                            arp.Deviation_from_original_margin__c = accountMap.get(arp.Account__c).Deviation_from_original_margin__c;
                        }
                        if(accountMap.containsKey(arp.Account__c) && accountMap.get(arp.Account__c).Number_of_products_they_act_as_reference__c != null){
                            arp.Number_of_products_they_act_as_reference__c = accountMap.get(arp.Account__c).Number_of_products_they_act_as_reference__c;
                        }
                        if(accountMap.containsKey(arp.Account__c) && accountMap.get(arp.Account__c).Number_of_supported_reference_activities__c != null){
                            arp.Number_of_supported_reference_activities__c = accountMap.get(arp.Account__c).Number_of_supported_reference_activities__c;
                        }
                        if(accountMap.containsKey(arp.Account__c) && accountMap.get(arp.Account__c).Marketing_or_PR_endorsement_provided__c != null){
                            arp.Marketing_or_PR_endorsement_provided__c = accountMap.get(arp.Account__c).Marketing_or_PR_endorsement_provided__c;
                        }
                        if(accountMap.containsKey(arp.Account__c) && accountMap.get(arp.Account__c).Number_of_contacts_on_Misys_University__c != null){
                            arp.Number_of_contacts_on_Misys_University__c = accountMap.get(arp.Account__c).Number_of_contacts_on_Misys_University__c;
                        }
                        if(accountMap.containsKey(arp.Account__c) && accountMap.get(arp.Account__c).Number_of_contacts_on_CABs_SAGs_and_UGs__c != null){
                            arp.Number_of_contacts_on_CABs_SAGs_and_UGs__c = accountMap.get(arp.Account__c).Number_of_contacts_on_CABs_SAGs_and_UGs__c;
                        }
                        if(accountMap.containsKey(arp.Account__c) && accountMap.get(arp.Account__c).Deviation_from_intended_go_live__c != null){
                            arp.Deviation_from_intended_go_live__c = accountMap.get(arp.Account__c).Deviation_from_intended_go_live__c;
                        }
                        if(accountMap.containsKey(arp.Account__c)){
                            arp.Account_Id__c = accountMap.get(arp.Account__c).Id;
    
                            String strName = accountMap.get(arp.Account__c).Name;
                            if(strName.length() > 80){
                                strName = strName.substring(0, 79);
                            }
                            arp.Name = strName;
                            arp.Account__c = accountMap.get(arp.Account__c).Id;
                            arp.Customer_Group__c = accountMap.get(arp.Account__c).Customer_Group__c;
                            arp.Ultimate_Parent__c = accountMap.get(arp.Account__c).Ultimate_Parent__c;
                        }
                    }
                }
            }
    
            //populate the currency conversion rate map
            map<string, decimal> converstionRateMap = new map<string, decimal>();
            for(CurrencyType cType : [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE]){
                converstionRateMap.put(cType.ISOCode, cType.ConversionRate);
            }
            system.debug('converstionRateMap = ' + converstionRateMap);
            
            if(accountMap != null && accountMap.size() > 0){
                rollupContacts(accountMap, accountRollupList);
                rollupOpportunities(accountMap, accountRollupList);
                rollupOpportunitiesKPI2_2(accountMap, accountRollupList);
                rollupOpportunitiesKPI5_1(accountMap, accountRollupList);
                rollupProductSetKPI10_1(accountMap, accountRollupList);
                rollupOpportunitiesKPI2_3And3_3(accountMap, accountRollupList, converstionRateMap);
                rollupOpportunitiesKPI4_1And4_2And4_3(accountMap, accountRollupList, converstionRateMap);
                rollupOpportunities5_2And5_3(accountMap, accountRollupList, converstionRateMap);
                rollupAtRisk10_2(accountMap, accountRollupList, converstionRateMap);
                rollupTasksKPI2_1(accountMap, accountRollupList);
                rollupTasksKPI3_1And3_2(accountMap, accountRollupList);
                rollupInvoice10_3(accountMap, accountRollupList, converstionRateMap);
                rollupContacts8_3(accountMap, accountRollupList);
                rollupCases7_1(accountMap, accountRollupList);
                rollupCases7_2(accountMap, accountRollupList);
                rollupCases7_3(accountMap, accountRollupList);
            }

            //logic for rolling up to parent
            system.debug('parentAccRollupIds = ' + parentAccRollupIds);
            if(parentAccRollupIds != null && parentAccRollupIds.size() > 0){
                //accountRollupMap
                list<Account_Rollup__c> arpList;
                for(Account_Rollup__c accRollup : [select id, name, Ultimate_Parent_Account_Rollup__c, Number_of_Qualified_Contacts__c, Customer_Group_Account_Rollup__c, 
                                                    Number_of_MQLs_Generated__c, Number_of_C_D_level_meetings__c, Number_of_CVT_engagements__c, 
                                                    Number_of_SS1_opportunities_created__c, Number_of_presales_client_meetings__c, Number_of_demos__c, Qualified_pipeline_USD__c,
                                                    Sum_of_partner_co_sell_USD__c, Sum_Partner_originated_USD__c, Number_of_certified_partner_consultants__c,
                                                    Number_of_closed_won_opportunities__c, Sum_of_closed_won_ILF_USD__c, Sum_of_closed_won_Services_USD__c, Number_of_contacts_on_Misys_University__c,
                                                    Number_of_contacts_on_CABs_SAGs_and_UGs__c, Number_of_contacts_attending_MF_Sol__c, Number_of_products_they_act_as_reference__c,
                                                    Number_of_supported_reference_activities__c, Unqualified_pipeline_USD__c, Number_of_active_product_sets__c, Sum_of_RLF_at_risk_USD__c,
                                                    Sum_of_Invoices_outstanding_USD__c, Marketing_or_PR_endorsement_provided__c, Business_outcomes_achieved__c, Deviation_from_original_margin__c,
                                                    Deviation_from_intended_go_live__c, Ave_resolution_time_for_support_request__c, Aged_backlog_of_cases__c, Open_defects_with_targeted_fix_date__c
                                                    from Account_Rollup__c where Ultimate_Parent_Account_Rollup__c in : parentAccRollupIds or Customer_Group_Account_Rollup__c in : parentAccRollupIds]){
                    if(accRollup.Ultimate_Parent_Account_Rollup__c != null){
                        if(accountRollupMap.containsKey(accRollup.Ultimate_Parent_Account_Rollup__c)){
                            arpList = accountRollupMap.get(accRollup.Ultimate_Parent_Account_Rollup__c);
                            arpList.add(accRollup);
                        } else {
                            arpList = new list<Account_Rollup__c>();
                            arpList.add(accRollup);
                            accountRollupMap.put(accRollup.Ultimate_Parent_Account_Rollup__c, arpList);
                        }
                    }
                    if(accRollup.Customer_Group_Account_Rollup__c != null){
                        if(accountRollupMap.containsKey(accRollup.Customer_Group_Account_Rollup__c)){
                            arpList = accountRollupMap.get(accRollup.Customer_Group_Account_Rollup__c);
                            arpList.add(accRollup);
                        } else {
                            arpList = new list<Account_Rollup__c>();
                            arpList.add(accRollup);
                            accountRollupMap.put(accRollup.Customer_Group_Account_Rollup__c, arpList);
                        }
                    }
                }
                
                system.debug('accountRollupMap = ' + accountRollupMap);
                if(accountRollupMap != null && accountRollupMap.size() > 0){
                    for(Account_Rollup__c accRollUp : accountRollupList){
                        if(accountRollupMap.containsKey(accRollUp.Id)){
                            //Assigning 0 to the below values as the initial value was calculated twice.
                            accRollUp.Deviation_from_intended_go_live__c = 0;
                            accRollUp.Deviation_from_original_margin__c = 0;
                            accRollUp.Business_outcomes_achieved__c = 0;
                            //AK - I think there would be issue with the following fields as well, that's why assigned them to 0
                            accRollUp.Ave_resolution_time_for_support_request__c = 0;
                            accRollUp.Aged_backlog_of_cases__c = 0;
                            accRollUp.Open_defects_with_targeted_fix_date__c = 0;
                            for(Account_Rollup__c accountRollup : accountRollupMap.get(accRollUp.Id)){
                                if(accountRollup.Number_of_Qualified_Contacts__c != null){
                                    accRollUp.Number_of_Qualified_Contacts__c = accRollUp.Number_of_Qualified_Contacts__c + accountRollup.Number_of_Qualified_Contacts__c;
                                }
                                if(accountRollup.Number_of_MQLs_Generated__c != null){
                                    accRollUp.Number_of_MQLs_Generated__c = accRollUp.Number_of_MQLs_Generated__c + accountRollup.Number_of_MQLs_Generated__c;
                                }
                                if(accountRollup.Number_of_C_D_level_meetings__c != null){
                                    accRollUp.Number_of_C_D_level_meetings__c = accRollUp.Number_of_C_D_level_meetings__c + accountRollup.Number_of_C_D_level_meetings__c;
                                }
                                if(accountRollup.Number_of_CVT_engagements__c != null){
                                    accRollUp.Number_of_CVT_engagements__c = accRollUp.Number_of_CVT_engagements__c + accountRollup.Number_of_CVT_engagements__c;
                                }
                                if(accountRollup.Number_of_SS1_opportunities_created__c != null){
                                    accRollUp.Number_of_SS1_opportunities_created__c = accRollUp.Number_of_SS1_opportunities_created__c + accountRollup.Number_of_SS1_opportunities_created__c;
                                }
                                if(accountRollup.Number_of_presales_client_meetings__c != null){
                                    accRollUp.Number_of_presales_client_meetings__c = accRollUp.Number_of_presales_client_meetings__c + accountRollup.Number_of_presales_client_meetings__c;
                                }
                                if(accountRollup.Number_of_demos__c != null){
                                    accRollUp.Number_of_demos__c = accRollUp.Number_of_demos__c + accountRollup.Number_of_demos__c;
                                }
                                if(accountRollup.Qualified_pipeline_USD__c != null){
                                    accRollUp.Qualified_pipeline_USD__c = accRollUp.Qualified_pipeline_USD__c + accountRollup.Qualified_pipeline_USD__c;
                                }
                                if(accountRollup.Sum_of_partner_co_sell_USD__c != null){
                                    accRollUp.Sum_of_partner_co_sell_USD__c = accRollUp.Sum_of_partner_co_sell_USD__c + accountRollup.Sum_of_partner_co_sell_USD__c;
                                }
                                if(accountRollup.Sum_Partner_originated_USD__c != null){
                                    accRollUp.Sum_Partner_originated_USD__c = accRollUp.Sum_Partner_originated_USD__c + accountRollup.Sum_Partner_originated_USD__c;
                                }
                                //if(accountRollup.Number_of_certified_partner_consultants__c != null && accountRollup.Number_of_certified_partner_consultants__c == 'Yes'){
                                  //  accRollUp.Number_of_certified_partner_consultants__c = 'Yes';
                                //}
                                if(accountRollup.Number_of_certified_partner_consultants__c != null){
                                    accRollUp.Number_of_certified_partner_consultants__c = accRollUp.Number_of_certified_partner_consultants__c + accountRollup.Number_of_certified_partner_consultants__c;
                                }
                                if(accountRollup.Number_of_closed_won_opportunities__c != null){
                                    accRollUp.Number_of_closed_won_opportunities__c = accRollUp.Number_of_closed_won_opportunities__c + accountRollup.Number_of_closed_won_opportunities__c;
                                }
                                if(accountRollup.Sum_of_closed_won_ILF_USD__c != null){
                                    accRollUp.Sum_of_closed_won_ILF_USD__c = accRollUp.Sum_of_closed_won_ILF_USD__c + accountRollup.Sum_of_closed_won_ILF_USD__c;
                                }
                                if(accountRollup.Sum_of_closed_won_Services_USD__c != null){
                                    accRollUp.Sum_of_closed_won_Services_USD__c = accRollUp.Sum_of_closed_won_Services_USD__c + accountRollup.Sum_of_closed_won_Services_USD__c;
                                }
                                if(accountRollup.Number_of_contacts_on_Misys_University__c != null){
                                    accRollUp.Number_of_contacts_on_Misys_University__c = accRollUp.Number_of_contacts_on_Misys_University__c + accountRollup.Number_of_contacts_on_Misys_University__c;
                                }
                                if(accountRollup.Number_of_contacts_on_CABs_SAGs_and_UGs__c != null){
                                    accRollUp.Number_of_contacts_on_CABs_SAGs_and_UGs__c = accRollUp.Number_of_contacts_on_CABs_SAGs_and_UGs__c + accountRollup.Number_of_contacts_on_CABs_SAGs_and_UGs__c;
                                }
                                if(accountRollup.Number_of_contacts_attending_MF_Sol__c != null){
                                    accRollUp.Number_of_contacts_attending_MF_Sol__c = accRollUp.Number_of_contacts_attending_MF_Sol__c + accountRollup.Number_of_contacts_attending_MF_Sol__c;
                                }
                                if(accountRollup.Number_of_products_they_act_as_reference__c != null){
                                    accRollUp.Number_of_products_they_act_as_reference__c = accRollUp.Number_of_products_they_act_as_reference__c + accountRollup.Number_of_products_they_act_as_reference__c;
                                }
                                if(accountRollup.Number_of_supported_reference_activities__c != null){
                                    accRollUp.Number_of_supported_reference_activities__c = accRollUp.Number_of_supported_reference_activities__c + accountRollup.Number_of_supported_reference_activities__c;
                                }
                                if(accountRollup.Unqualified_pipeline_USD__c != null){
                                    accRollUp.Unqualified_pipeline_USD__c = accRollUp.Unqualified_pipeline_USD__c + accountRollup.Unqualified_pipeline_USD__c;
                                }
                                if(accountRollup.Number_of_active_product_sets__c != null){
                                    accRollUp.Number_of_active_product_sets__c = accRollUp.Number_of_active_product_sets__c + accountRollup.Number_of_active_product_sets__c;
                                }
                                if(accountRollup.Sum_of_RLF_at_risk_USD__c != null){
                                    accRollUp.Sum_of_RLF_at_risk_USD__c = accRollUp.Sum_of_RLF_at_risk_USD__c + accountRollup.Sum_of_RLF_at_risk_USD__c;
                                }
                                if(accountRollup.Sum_of_Invoices_outstanding_USD__c != null){
                                    accRollUp.Sum_of_Invoices_outstanding_USD__c = accRollUp.Sum_of_Invoices_outstanding_USD__c + accountRollup.Sum_of_Invoices_outstanding_USD__c;
                                }
                                if(accountRollup.Marketing_or_PR_endorsement_provided__c != null && accountRollup.Marketing_or_PR_endorsement_provided__c == 'Yes'){
                                    accRollUp.Marketing_or_PR_endorsement_provided__c = 'Yes';
                                }
                                if(accountRollup.Business_outcomes_achieved__c != null){
                                    accRollUp.Business_outcomes_achieved__c = accRollUp.Business_outcomes_achieved__c + accountRollup.Business_outcomes_achieved__c;
                                }
                                if(accountRollup.Deviation_from_original_margin__c != null){
                                    accRollUp.Deviation_from_original_margin__c = accRollUp.Deviation_from_original_margin__c + accountRollup.Deviation_from_original_margin__c;
                                }
                                if(accountRollup.Deviation_from_intended_go_live__c != null){
                                    accRollUp.Deviation_from_intended_go_live__c = accRollUp.Deviation_from_intended_go_live__c + accountRollup.Deviation_from_intended_go_live__c;
                                }
                                if(accountRollup.Ave_resolution_time_for_support_request__c != null){
                                    accRollUp.Ave_resolution_time_for_support_request__c = accRollUp.Ave_resolution_time_for_support_request__c + accountRollup.Ave_resolution_time_for_support_request__c;
                                }
                                if(accountRollup.Aged_backlog_of_cases__c != null){
                                    accRollUp.Aged_backlog_of_cases__c = accRollUp.Aged_backlog_of_cases__c + accountRollup.Aged_backlog_of_cases__c;
                                }
                                if(accountRollup.Open_defects_with_targeted_fix_date__c != null){
                                    accRollUp.Open_defects_with_targeted_fix_date__c = accRollUp.Open_defects_with_targeted_fix_date__c + accountRollup.Open_defects_with_targeted_fix_date__c;
                                }
                                
                                system.debug('accountRollup = ' + accountRollup);
                            }
                            //Additional logic for calculating the average
                            if(accountRollupMap.containsKey(accRollUp.Id)){
                                accRollup.Business_outcomes_achieved__c = accRollup.Business_outcomes_achieved__c / accountRollupMap.get(accRollUp.Id).size();
                                accRollup.Deviation_from_original_margin__c = accRollup.Deviation_from_original_margin__c / accountRollupMap.get(accRollUp.Id).size();
                                accRollup.Deviation_from_intended_go_live__c = accRollup.Deviation_from_intended_go_live__c / accountRollupMap.get(accRollUp.Id).size();
                                accRollup.Ave_resolution_time_for_support_request__c = Math.floor(accRollup.Ave_resolution_time_for_support_request__c / accountRollupMap.get(accRollUp.Id).size());
                                accRollup.Aged_backlog_of_cases__c = accRollup.Aged_backlog_of_cases__c / accountRollupMap.get(accRollUp.Id).size();
                                accRollup.Open_defects_with_targeted_fix_date__c = accRollup.Open_defects_with_targeted_fix_date__c / accountRollupMap.get(accRollUp.Id).size();
                            }
                        }
                    }
                }
            }
        }
        
        system.debug('parentAccountRollups = ' + parentAccountRollups);
        if(trigger.isAfter){
            for(Account_Rollup__c arp : accountRollupList){
                if(arp.Account__c != null){
                    if(arp.Customer_Group_Account_Rollup__c != null){
                        if(!parentAccountRUPIds.contains(arp.Customer_Group_Account_Rollup__c)){
                            parentAccountRUPIds.add(arp.Customer_Group_Account_Rollup__c);
                            parentAccountRollups.add(new Account_Rollup__c(Id = arp.Customer_Group_Account_Rollup__c));
                        }
                    }
                    if(arp.Ultimate_Parent_Account_Rollup__c != null){
                        if(!parentAccountRUPIds.contains(arp.Ultimate_Parent_Account_Rollup__c)){
                            parentAccountRUPIds.add(arp.Ultimate_Parent_Account_Rollup__c);
                            parentAccountRollups.add(new Account_Rollup__c(Id = arp.Ultimate_Parent_Account_Rollup__c));
                        }
                    }
                }
            }

            system.debug('parentAccountRollups 1 = ' + parentAccountRollups);
            if(parentAccountRollups != null && parentAccountRollups.size() > 0){
                update parentAccountRollups;
            }
        }
        
    }
    
    //for KPIs 1.1 and 1.2
    private static void rollupContacts(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList){
        map<id, list<Contact>> accIdContactMap = new map<id, list<Contact>>();
        map<id, list<Contact>> accIdContactMapMQLs = new map<id, list<Contact>>();
        list<Contact> contactList;
        list<Contact> contactListMqls;
        
        for(Contact contact : [select id, name, HasOptedOutOfEmail, AccountId, Status__c from contact where AccountId in : accountMap.keySet() and HasOptedOutOfEmail = false]){
            //Marketing Qualified Lead (MQL)
            if(accIdContactMap.containsKey(contact.AccountId)){
                contactList = accIdContactMap.get(contact.AccountId);
                contactList.add(contact);
            } else {
                contactList = new list<Contact>();
                contactList.add(contact);
                accIdContactMap.put(contact.AccountId, contactList);
            }

            //for MQLs
            if(contact.Status__c == 'Marketing Qualified Lead (MQL)' || contact.Status__c == 'Marketing Engaged Lead (MEL)'){
                if(accIdContactMapMQLs.containsKey(contact.AccountId)){
                    contactListMqls = accIdContactMapMQLs.get(contact.AccountId);
                    contactListMqls.add(contact);
                } else {
                    contactListMqls = new list<Contact>();
                    contactListMqls.add(contact);
                    accIdContactMapMQLs.put(contact.AccountId, contactListMqls);
                }
            } 
        }
        
        if(accIdContactMap != null && accIdContactMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdContactMap.containsKey(arup.Account__c)){
                        arup.Number_of_Qualified_Contacts__c = accIdContactMap.get(arup.Account__c).size();
                    } else {
                        arup.Number_of_Qualified_Contacts__c = 0;
                    }
                    if(accIdContactMapMQLs.containsKey(arup.Account__c)){
                        arup.Number_of_MQLs_Generated__c = accIdContactMapMQLs.get(arup.Account__c).size();
                    } else {
                        arup.Number_of_MQLs_Generated__c = 0;
                    }
                }
            }
        }
    }

    //for KPI 1.3
    private static void rollupOpportunities(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList){
        map<id, list<Opportunity>> accIdOppMap = new map<id, list<Opportunity>>();
        list<Opportunity> opportunityList;
        
        for(Opportunity opportunity : [select id, name, AccountId, StageName from Opportunity where AccountId in : accountMap.keySet() and (StageName = '1. Plan' or StageName = '2. Create' or StageName = '3. Qualify')]){
            if(accIdOppMap.containsKey(opportunity.AccountId)){
                opportunityList = accIdOppMap.get(opportunity.AccountId);
                opportunityList.add(opportunity);
            } else {
                opportunityList = new list<opportunity>();
                opportunityList.add(opportunity);
                accIdOppMap.put(opportunity.AccountId, opportunityList);
            }

        }
        
        if(accIdOppMap != null && accIdOppMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdOppMap.containsKey(arup.Account__c)){
                        arup.Number_of_SS1_opportunities_created__c = accIdOppMap.get(arup.Account__c).size();
                    } else {
                        arup.Number_of_SS1_opportunities_created__c = 0;
                    }
                }
            }
        }
    }

    //for KPI 2.2
    private static void rollupOpportunitiesKPI2_2(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList){
        map<id, list<Opportunity>> accIdOppMap = new map<id, list<Opportunity>>();
        list<Opportunity> opportunityList;
        date currentDate = Date.today();
        date dateYearAgo = currentDate.addDays(-365);
        
        for(Opportunity opportunity : [select id, name, AccountId, StageName, Which_CVT_offering_was_used__c from Opportunity where AccountId in : accountMap.keySet() and CreatedDate > :dateYearAgo and Which_CVT_offering_was_used__c != null]){
            if(accIdOppMap.containsKey(opportunity.AccountId)){
                opportunityList = accIdOppMap.get(opportunity.AccountId);
                opportunityList.add(opportunity);
            } else {
                opportunityList = new list<opportunity>();
                opportunityList.add(opportunity);
                accIdOppMap.put(opportunity.AccountId, opportunityList);
            }

        }
        
        if(accIdOppMap != null && accIdOppMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdOppMap.containsKey(arup.Account__c)){
                        arup.Number_of_CVT_engagements__c = accIdOppMap.get(arup.Account__c).size();
                    } else {
                        arup.Number_of_CVT_engagements__c = 0;
                    }
                }
            }
        }
    }

    //for KPI 5.1
    private static void rollupOpportunitiesKPI5_1(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList){
        map<id, list<Opportunity>> accIdOppMap = new map<id, list<Opportunity>>();
        list<Opportunity> opportunityList;
        date currentDate = Date.today();
        date dateYearAgo = currentDate.addDays(-365);
        
        for(Opportunity opportunity : [select id, name, AccountId, StageName from Opportunity where AccountId in : accountMap.keySet() and CloseDate > :dateYearAgo and StageName = 'Closed Won' and (ILF_Amount__c > 0 or PS_Amount__c > 0)]){
            if(accIdOppMap.containsKey(opportunity.AccountId)){
                opportunityList = accIdOppMap.get(opportunity.AccountId);
                opportunityList.add(opportunity);
            } else {
                opportunityList = new list<opportunity>();
                opportunityList.add(opportunity);
                accIdOppMap.put(opportunity.AccountId, opportunityList);
            }

        }
        
        if(accIdOppMap != null && accIdOppMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdOppMap.containsKey(arup.Account__c)){
                        arup.Number_of_closed_won_opportunities__c = accIdOppMap.get(arup.Account__c).size();
                    } else {
                        arup.Number_of_closed_won_opportunities__c = 0;
                    }
                }
            }
        }
    }

    //for KPI 10.1
    private static void rollupProductSetKPI10_1(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList){
        map<id, list<Entitlement__c>> accIdEntMap = new map<id, list<Entitlement__c>>();
        list<Entitlement__c> entitlementList;
        
        for(Entitlement__c entitlement : [select Product_Set__c, Product_Set__r.Account__c, Product_Set__r.Name, Account__c from Entitlement__c where System__r.Environment2__c = 'PROD' and Status__c = 'Active' and Product_Set__r.Account__c in :accountMap.keySet()]){
            
            if(accIdEntMap.containsKey(entitlement.Account__c)){
                entitlementList = accIdEntMap.get(entitlement.Account__c);
                entitlementList.add(entitlement);
            } else {
                entitlementList = new list<Entitlement__c>();
                entitlementList.add(entitlement);
                accIdEntMap.put(entitlement.Account__c, entitlementList);
            }

        }
        
        if(accIdEntMap != null && accIdEntMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdEntMap.containsKey(arup.Account__c)){
                        arup.Number_of_active_product_sets__c = accIdEntMap.get(arup.Account__c).size();
                    } else {
                        arup.Number_of_active_product_sets__c = 0;
                    }
                }
            }
        }
    }

    //for KPI 2.3 and 3.3
    private static void rollupOpportunitiesKPI2_3And3_3(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList, map<string, decimal> converstionRateMap){
        map<id, list<Opportunity>> accIdOppMap = new map<id, list<Opportunity>>();
        list<Opportunity> opportunityList;
        decimal unqualifiedPipelineUSD = 0;
        decimal qualifiedPipelineUSD = 0;
        
        for(Opportunity opportunity : [select id, name, AccountId, StageName, ILF_Amount__c, CurrencyIsoCode from Opportunity where AccountId in : accountMap.keySet() and (StageName = '1. Plan' or StageName = '2. Create' or StageName = '3. Qualify' or StageName = '4. Develop' or StageName = '5. Prove' or StageName = '6. Negotiate' or StageName = '7. Committed')]){
            if(accIdOppMap.containsKey(opportunity.AccountId)){
                opportunityList = accIdOppMap.get(opportunity.AccountId);
                opportunityList.add(opportunity);
            } else {
                opportunityList = new list<opportunity>();
                opportunityList.add(opportunity);
                accIdOppMap.put(opportunity.AccountId, opportunityList);
            }

        }
        
        if(accIdOppMap != null && accIdOppMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdOppMap.containsKey(arup.Account__c)){
                        for(Opportunity opp : accIdOppMap.get(arup.Account__c)){
                            decimal conversionRate = 1;
                            if(converstionRateMap.containsKey(opp.CurrencyISOCode)){
                                conversionRate = converstionRateMap.get(opp.CurrencyISOCode);
                            }
                            if(opp.ILF_Amount__c != null && opp.ILF_Amount__c != 0){
                                if(opp.StageName == '1. Plan' || opp.StageName == '2. Create' || opp.StageName == '3. Qualify'){
                                    unqualifiedPipelineUSD = unqualifiedPipelineUSD + opp.ILF_Amount__c / conversionRate;
                                } else if(opp.StageName == '4. Develop' || opp.StageName == '5. Prove' || opp.StageName == '6. Negotiate' || opp.StageName == '7. Committed'){
                                    qualifiedPipelineUSD = qualifiedPipelineUSD + opp.ILF_Amount__c / conversionRate;
                                }
                            }
                        }
                        arup.Unqualified_pipeline_USD__c = unqualifiedPipelineUSD;
                        arup.Qualified_pipeline_USD__c = qualifiedPipelineUSD;
                    }
                }
            }
        }
    }

    //for 5.2 and 5.3
    private static void rollupOpportunities5_2And5_3(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList, map<string, decimal> converstionRateMap){
        map<id, list<Opportunity>> accIdOppMap = new map<id, list<Opportunity>>();
        list<Opportunity> opportunityList;
        decimal sumClosedWonILFUSD = 0;
        decimal sumClosedWonServicesUSD = 0;
        date currentDate = Date.today();
        date dateYearAgo = currentDate.addDays(-365);
        
        for(Opportunity opportunity : [select id, name, AccountId, StageName, ILF_Amount__c, RLF_Amount__c, PS_Amount__c, CurrencyIsoCode, Opportunity_Partner__c, Partner_Originated__c, Opportunity_Partner__r.Has_certified_consultants__c from Opportunity where AccountId in : accountMap.keySet() and StageName = 'Closed Won' and CloseDate > :dateYearAgo ]){
            if(accIdOppMap.containsKey(opportunity.AccountId)){
                opportunityList = accIdOppMap.get(opportunity.AccountId);
                opportunityList.add(opportunity);
            } else {
                opportunityList = new list<opportunity>();
                opportunityList.add(opportunity);
                accIdOppMap.put(opportunity.AccountId, opportunityList);
            }

        }
        
        if(accIdOppMap != null && accIdOppMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdOppMap.containsKey(arup.Account__c)){
                        for(Opportunity opp : accIdOppMap.get(arup.Account__c)){
                            decimal conversionRate = 1;
                            if(converstionRateMap.containsKey(opp.CurrencyISOCode)){
                                conversionRate = converstionRateMap.get(opp.CurrencyISOCode);
                            }
                            if(opp.ILF_Amount__c != null && opp.ILF_Amount__c != 0){
                                sumClosedWonILFUSD = sumClosedWonILFUSD + opp.ILF_Amount__c / conversionRate;
                            }
                            if(opp.PS_Amount__c != null && opp.PS_Amount__c != 0){
                                sumClosedWonServicesUSD = sumClosedWonServicesUSD + opp.PS_Amount__c / conversionRate;
                            }
                        }
                        arup.Sum_of_closed_won_ILF_USD__c = sumClosedWonILFUSD;
                        arup.Sum_of_closed_won_Services_USD__c = sumClosedWonServicesUSD;
                    }
                }
            }
        }
    }
    
    
    //for KPI 4.1, 4.2, 4.3
    private static void rollupOpportunitiesKPI4_1And4_2And4_3(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList, map<string, decimal> converstionRateMap){
        map<id, list<Opportunity>> accIdOppMap = new map<id, list<Opportunity>>();
        list<Opportunity> opportunityList;
        decimal sumOfPartnerCoSellUSD = 0;
        decimal sumPartnerOriginatedUSD = 0;
        decimal sumPartnerClosedLostUSD = 0;
        decimal sumClosedWonILFUSD = 0;
        decimal sumClosedWonServicesUSD = 0;
        string hasCertifiedPartner = 'No';
        date currentDate = Date.today();
        date dateYearAgo = currentDate.addDays(-365);
        
        for(Opportunity opportunity : [select id, name, AccountId, StageName, ILF_Amount__c, RLF_Amount__c, PS_Amount__c, CurrencyIsoCode, Opportunity_Partner__c, Partner_Originated__c, Opportunity_Partner__r.Has_certified_consultants__c, CloseDate, CreatedDate 
                                       from Opportunity where AccountId in : accountMap.keySet() and 
                                       (StageName = 'Closed Won' or StageName = '1. Plan' or StageName = '2. Create' or StageName = '3. Qualify' or StageName = '4. Develop' or StageName = '5. Prove' or StageName = '6. Negotiate' or StageName = '7. Committed' or StageName = 'Closed Lost') 
                                       and (CreatedDate > :dateYearAgo or CloseDate > :dateYearAgo) ]){
            if(accIdOppMap.containsKey(opportunity.AccountId)){
                opportunityList = accIdOppMap.get(opportunity.AccountId);
                opportunityList.add(opportunity);
            } else {
                opportunityList = new list<opportunity>();
                opportunityList.add(opportunity);
                accIdOppMap.put(opportunity.AccountId, opportunityList);
            }

        }
        
        system.debug('accIdOppMap 4.3 = ' + accIdOppMap);
        if(accIdOppMap != null && accIdOppMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdOppMap.containsKey(arup.Account__c)){
                        for(Opportunity opp : accIdOppMap.get(arup.Account__c)){
                            decimal conversionRate = 1;
                            if(converstionRateMap.containsKey(opp.CurrencyISOCode)){
                                conversionRate = converstionRateMap.get(opp.CurrencyISOCode);
                            }
							//4.1, 4.2, 4.3                            
                            if(opp.ILF_Amount__c != null && opp.ILF_Amount__c != 0){
                                if(opp.Opportunity_Partner__c != null){
                                    if(opp.CreatedDate > dateYearAgo && (opp.StageName == '1. Plan' || opp.StageName == '2. Create' || opp.StageName == '3. Qualify' || opp.StageName == '4. Develop' || opp.StageName == '5. Prove' || opp.StageName == '6. Negotiate')){
                                        sumOfPartnerCoSellUSD = sumOfPartnerCoSellUSD + opp.ILF_Amount__c / conversionRate;
                                    } else if((opp.CreatedDate > dateYearAgo && opp.StageName == '7. Committed') || (opp.CloseDate > dateYearAgo && opp.StageName == 'Closed Won')){
                                        sumPartnerOriginatedUSD = sumPartnerOriginatedUSD + opp.ILF_Amount__c / conversionRate;
                                    } else if(opp.CloseDate > dateYearAgo && opp.StageName == 'Closed Lost'){
                                        sumPartnerClosedLostUSD = sumPartnerClosedLostUSD + opp.ILF_Amount__c / conversionRate;
                                    }
                                }
                            }
                            //4.1, 4.2, 4.3
                            if(opp.RLF_Amount__c != null && opp.RLF_Amount__c != 0){
                                if(opp.Opportunity_Partner__c != null){
                                    if(opp.CreatedDate > dateYearAgo && (opp.StageName == '1. Plan' || opp.StageName == '2. Create' || opp.StageName == '3. Qualify' || opp.StageName == '4. Develop' || opp.StageName == '5. Prove' || opp.StageName == '6. Negotiate')){
                                        sumOfPartnerCoSellUSD = sumOfPartnerCoSellUSD + opp.RLF_Amount__c / conversionRate;
                                    } else if((opp.CreatedDate > dateYearAgo && opp.StageName == '7. Committed') || (opp.CloseDate > dateYearAgo && opp.StageName == 'Closed Won')){
                                        sumPartnerOriginatedUSD = sumPartnerOriginatedUSD + opp.RLF_Amount__c / conversionRate;
                                    } else if(opp.CloseDate > dateYearAgo && opp.StageName == 'Closed Lost'){
                                        sumPartnerClosedLostUSD = sumPartnerClosedLostUSD + opp.RLF_Amount__c / conversionRate;
                                    }
                                }
                            }
                            //4.1, 4.2, 4.3
                            if(opp.PS_Amount__c != null && opp.PS_Amount__c != 0){
                                if(opp.Opportunity_Partner__c != null){
                                    sumOfPartnerCoSellUSD = sumOfPartnerCoSellUSD + opp.PS_Amount__c / conversionRate;
                                    if(opp.CreatedDate > dateYearAgo && (opp.StageName == '1. Plan' || opp.StageName == '2. Create' || opp.StageName == '3. Qualify' || opp.StageName == '4. Develop' || opp.StageName == '5. Prove' || opp.StageName == '6. Negotiate')){
                                        sumOfPartnerCoSellUSD = sumOfPartnerCoSellUSD + opp.PS_Amount__c / conversionRate;
                                    } else if((opp.CreatedDate > dateYearAgo && opp.StageName == '7. Committed') || (opp.CloseDate > dateYearAgo && opp.StageName == 'Closed Won')){
                                        sumPartnerOriginatedUSD = sumPartnerOriginatedUSD + opp.PS_Amount__c / conversionRate;
                                    } else if(opp.CloseDate > dateYearAgo && opp.StageName == 'Closed Lost'){
                                        sumPartnerClosedLostUSD = sumPartnerClosedLostUSD + opp.PS_Amount__c / conversionRate;
                                    }
                                }
                            }
                        }
                        arup.Sum_of_partner_co_sell_USD__c = sumOfPartnerCoSellUSD;
                        arup.Sum_Partner_originated_USD__c = sumPartnerOriginatedUSD;
                        arup.Number_of_certified_partner_consultants__c = sumPartnerClosedLostUSD;
                    }
                }
            }
        }
    }

    //for KPI 10.2
    private static void rollupAtRisk10_2(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList, map<string, decimal> converstionRateMap){
        map<id, list<At_Risk__c>> accIdAtRiskMap = new map<id, list<At_Risk__c>>();
        list<At_Risk__c> atRiskList;
        decimal sumOfRLFAtRiskUSD = 0;

        for(At_Risk__c atRisk : [select id, name, Account__c, Annual_maintenance__c, CurrencyIsoCode, Risk_Level__c from At_Risk__c where Account__c in : accountMap.keySet() and (Risk_Level__c = 'Low Risk' or Risk_Level__c = 'Medium Risk' or Risk_Level__c = 'High Risk')]){
            if(accIdAtRiskMap.containsKey(atRisk.Account__c)){
                atRiskList = accIdAtRiskMap.get(atRisk.Account__c);
                atRiskList.add(atRisk);
            } else {
                atRiskList = new list<At_Risk__c>();
                atRiskList.add(atRisk);
                accIdAtRiskMap.put(atRisk.Account__c, atRiskList);
            }
        }
        
        if(accIdAtRiskMap != null && accIdAtRiskMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdAtRiskMap.containsKey(arup.Account__c)){
                        for(At_Risk__c atr : accIdAtRiskMap.get(arup.Account__c)){
                            decimal conversionRate = 1;
                            if(converstionRateMap.containsKey(atr.CurrencyISOCode)){
                                conversionRate = converstionRateMap.get(atr.CurrencyISOCode);
                            }
                            if(atr.Annual_maintenance__c != null && atr.Annual_maintenance__c != 0){
                                sumOfRLFAtRiskUSD = sumOfRLFAtRiskUSD + atr.Annual_maintenance__c / conversionRate;
                            }
                        }
                        arup.Sum_of_RLF_at_risk_USD__c = sumOfRLFAtRiskUSD;
                    }
                }
            }
        }
    }
    //for KPI 2.1
    private static void rollupTasksKPI2_1(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList){
        map<id, list<Task>> accIdTaskMap = new map<id, list<Task>>();
        map<id, list<Event>> accIdEventMap = new map<id, list<Event>>();
        list<Task> taskList;
        list<Event> eventList;
        date currentDate = Date.today();
        date dateYearAgo = currentDate.addDays(-365);
 
        for(Task task : [select Id, WhoId, AccountId from Task where AccountId in : accountMap.keySet() and (Contact_Level__c = '1: C-level (CEO/COO/CIO etc.)' or Contact_Level__c = '2: Division head (CEO Wholesale/IT Director etc.)' or Contact_Level__c = '3: Head of Business Line') and Status = 'Completed' and Completed_Date__c > : dateYearAgo]){
                if(accIdTaskMap.containsKey(task.AccountId)){
                    taskList = accIdTaskMap.get(task.AccountId);
                    taskList.add(task);
                } else {
                    taskList = new list<Task>();
                    taskList.add(task);
                    accIdTaskMap.put(task.AccountId, taskList);
                }
            }
        
            for(Event event : [select Id, WhoId, AccountId from Event where AccountId in : accountMap.keySet() and (Contact_Level__c = '1: C-level (CEO/COO/CIO etc.)' or Contact_Level__c = '2: Division head (CEO Wholesale/IT Director etc.)' or Contact_Level__c = '3: Head of Business Line') and ActivityDate > : dateYearAgo]){
                if(accIdEventMap.containsKey(event.AccountId)){
                    eventList = accIdEventMap.get(event.AccountId);
                    eventList.add(event);
                } else {
                    eventList = new list<Event>();
                    eventList.add(event);
                    accIdEventMap.put(event.AccountId, eventList);
                }
            }
        system.debug('accIdTaskMap = ' + accIdTaskMap);
        system.debug('accIdEventMap = ' + accIdEventMap);

            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdTaskMap.containsKey(arup.Account__c)){
                        arup.Number_of_C_D_level_meetings__c = accIdTaskMap.get(arup.Account__c).size();
                        system.debug('accIdTaskMap size = ' + accIdTaskMap.get(arup.Account__c).size());
                    } else {
                        arup.Number_of_C_D_level_meetings__c = 0;
                    }
                    if(accIdEventMap.containsKey(arup.Account__c)){
                        if(arup.Number_of_C_D_level_meetings__c != null && arup.Number_of_C_D_level_meetings__c > 0){
                            arup.Number_of_C_D_level_meetings__c = arup.Number_of_C_D_level_meetings__c + accIdEventMap.get(arup.Account__c).size();
                            system.debug('accIdEventMap size = ' + accIdEventMap.get(arup.Account__c).size());
                        } else {
                            arup.Number_of_C_D_level_meetings__c = accIdEventMap.get(arup.Account__c).size();
                        }
                    }
                    
                }
            }
    }

    //for KPI 3.1 and 3.2
    private static void rollupTasksKPI3_1And3_2(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList){
        map<id, list<Task>> accIdTaskMap = new map<id, list<Task>>();
        map<id, list<Task>> accIdTaskMap1 = new map<id, list<Task>>();
        list<Task> taskList;
        list<Task> taskList1;
        date currentDate = Date.today();
        date dateYearAgo = currentDate.addDays(-365);
        
        for(Task task : [select Id, WhoId, AccountId, Sales_Role__c, Sales_Activity_Type__c from Task where AccountId in : accountMap.keySet() and Status = 'Completed' and Completed_Date__c > : dateYearAgo]){
            if(task.Sales_Role__c == 'GSC Sales'){
                if(accIdTaskMap.containsKey(task.AccountId)){
                    taskList = accIdTaskMap.get(task.AccountId);
                    taskList.add(task);
                } else {
                    taskList = new list<Task>();
                    taskList.add(task);
                    accIdTaskMap.put(task.AccountId, taskList);
                }
                
                if(task.Sales_Activity_Type__c == 'Customer Specific Demo' || task.Sales_Activity_Type__c == 'Generic Demo' || task.Sales_Activity_Type__c == 'Workshop/POC'){
                    if(accIdTaskMap1.containsKey(task.AccountId)){
                        taskList1 = accIdTaskMap1.get(task.AccountId);
                        taskList1.add(task);
                    } else {
                        taskList1 = new list<Task>();
                        taskList1.add(task);
                        accIdTaskMap1.put(task.AccountId, taskList1);
                    }
                }
            }
        }
        
        if(accIdTaskMap != null && accIdTaskMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdTaskMap.containsKey(arup.Account__c)){
                        arup.Number_of_presales_client_meetings__c = accIdTaskMap.get(arup.Account__c).size();
                    } else {
                        arup.Number_of_presales_client_meetings__c = 0;
                    }
                    //Number_of_demos__c
                    if(accIdTaskMap1.containsKey(arup.Account__c)){
                        arup.Number_of_demos__c = accIdTaskMap1.get(arup.Account__c).size();
                    } else {
                        arup.Number_of_demos__c = 0;
                    }
                }
            }
        }
    }

    //for KPI 10.3
    private static void rollupInvoice10_3(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList, map<string, decimal> converstionRateMap){
        map<id, list<NS_Invoice_Credit_Memo__c>> accIdInvoiceMap = new map<id, list<NS_Invoice_Credit_Memo__c>>();
        list<NS_Invoice_Credit_Memo__c> invoiceList;
        decimal sumOfInvoicesOutstandingUSD = 0;
        date currentDate = Date.today();
        
        for(NS_Invoice_Credit_Memo__c invoice : [select id, name, Total__c, CurrencyIsoCode, Status__c, Invoice_No__c, Due_Date__c, Customer__r.Account__c from NS_Invoice_Credit_Memo__c where Customer__r.Account__c in : accountMap.keySet() and (Status__c = 'Open' and Invoice_No__c != null and Due_Date__c < :currentDate)]){
            if(accIdInvoiceMap.containsKey(invoice.Customer__r.Account__c)){
                invoiceList = accIdInvoiceMap.get(invoice.Customer__r.Account__c);
                invoiceList.add(invoice);
            } else {
                invoiceList = new list<NS_Invoice_Credit_Memo__c>();
                invoiceList.add(invoice);
                accIdInvoiceMap.put(invoice.Customer__r.Account__c, invoiceList);
            }
        }
        
        if(accIdInvoiceMap != null && accIdInvoiceMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdInvoiceMap.containsKey(arup.Account__c)){
                        for(NS_Invoice_Credit_Memo__c inv : accIdInvoiceMap.get(arup.Account__c)){
                            decimal conversionRate = 1;
                            if(converstionRateMap.containsKey(inv.CurrencyISOCode)){
                                conversionRate = converstionRateMap.get(inv.CurrencyISOCode);
                            }
                            if(inv.Total__c != null && inv.Total__c != 0){
                                sumOfInvoicesOutstandingUSD = sumOfInvoicesOutstandingUSD + inv.Total__c / conversionRate;
                            }
                        }
                        arup.Sum_of_Invoices_outstanding_USD__c = sumOfInvoicesOutstandingUSD;
                    }
                }
            }
        }
    }

    //for KPI 8.3
    private static void rollupContacts8_3(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList){
        map<id, list<CampaignMember>> accIdCampMemMap = new map<id, list<CampaignMember>>();
        list<CampaignMember> campMemList;
        date currentDate = Date.today();
        date dateYearAgo = currentDate.addDays(-365);
        
        for(CampaignMember campMem : [select id, name, ContactId, CampaignId, Status, Contact.AccountId from CampaignMember where Contact.AccountId in : accountMap.keySet() and (Status like '%Attended%' or Status like '%Engaged%') and (Campaign.Type = 'Offline Event – Misys Hosted' or Campaign.Type = 'Offline Event - Misys Hosted' or Campaign.Type = 'Corporate Hospitality' or Campaign.Type = 'Open House' or Campaign.Type = 'Offline Event – 3rd Party' or Campaign.Type = 'Prospect Event' or Campaign.Type = 'Roadshow') and (Campaign.StartDate > : dateYearAgo or Campaign.CreatedDate > : dateYearAgo)]){
            if(accIdCampMemMap.containsKey(campMem.Contact.AccountId)){
                campMemList = accIdCampMemMap.get(campMem.Contact.AccountId);
                campMemList.add(campMem);
            } else {
                campMemList = new list<CampaignMember>();
                campMemList.add(campMem);
                accIdCampMemMap.put(campMem.Contact.AccountId, campMemList);
            }
        }
        
        if(accIdCampMemMap != null && accIdCampMemMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdCampMemMap.containsKey(arup.Account__c)){
                        arup.Number_of_contacts_attending_MF_Sol__c = accIdCampMemMap.get(arup.Account__c).size();
                    } else {
                        arup.Number_of_contacts_attending_MF_Sol__c = 0;
                    }
                }
            }
        }
    }

    //for KPI 7.1
    private static void rollupCases7_1(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList){
        map<id, list<Case>> accIdCaseMap = new map<id, list<Case>>();
        list<Case> caseList;
        decimal sumMisysSolutionTime = 0;
        date currentDate = Date.today();
        date dateYearAgo = currentDate.addDays(-365);
        
        for(Case case1 : [select id, SLA2_Normal_Working_Day_Hours__c, Time_Object__r.Misys_Solution_Time__c, Case.AccountId from Case where Case.AccountId in : accountMap.keySet() and Case_Category__c = 'Support Request' and (Status = 'Solution Provided' or Status = 'Closed') and (ClosedDate > :dateYearAgo or CreatedDate > :dateYearAgo) and (RecordType.name != 'ACE360' and RecordType.name != 'COM Escalation' and RecordType.name != 'Customer Feedback' and RecordType.name != 'Engineering (LM)' and RecordType.name != 'Engineering (Turaz)' and RecordType.name != 'Issue' and RecordType.name != 'Operations Service Request' and RecordType.name != 'Pre Booked Year End Support' and RecordType.name != 'Sales Operations Support Services' and RecordType.name != 'Surveys' and RecordType.name != 'Test Record Type' and RecordType.name != 'xxxALM Banking Test')]){
            if(accIdCaseMap.containsKey(case1.AccountId)){
                caseList = accIdCaseMap.get(case1.AccountId);
                caseList.add(case1);
            } else {
                caseList = new list<Case>();
                caseList.add(case1);
                accIdCaseMap.put(case1.AccountId, caseList);
            }
        }
        
        if(accIdCaseMap != null && accIdCaseMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdCaseMap.containsKey(arup.Account__c)){
                        for(Case case2 : accIdCaseMap.get(arup.Account__c)){
                            if(case2.SLA2_Normal_Working_Day_Hours__c != null && case2.Time_Object__r.Misys_Solution_Time__c != null){
                                sumMisysSolutionTime = sumMisysSolutionTime + Math.floor(case2.Time_Object__r.Misys_Solution_Time__c / (60*60*case2.SLA2_Normal_Working_Day_Hours__c));
                            }
                        }
                        arup.Ave_resolution_time_for_support_request__c = Math.floor(sumMisysSolutionTime / accIdCaseMap.get(arup.Account__c).size());
                    }
                }
            }
        }
    }

    //for KPI 7.2
    private static void rollupCases7_2(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList){
        map<id, list<Case>> accIdCaseMap = new map<id, list<Case>>();
        map<id, list<Case>> accIdCaseMap1 = new map<id, list<Case>>();
        list<Case> caseList;
        list<Case> caseList1;
        date currentDate = Date.today();
        date date120DaysAgo = currentDate.addDays(-120);
        
        for(Case case1 : [select id, Case.AccountId, CreatedDate from Case where Case.AccountId in : accountMap.keySet() and (Status != 'Solution Provided' and Status != 'Closed') and (RecordType.name != 'ACE360' and RecordType.name != 'COM Escalation' and RecordType.name != 'Customer Feedback' and RecordType.name != 'Engineering (LM)' and RecordType.name != 'Engineering (Turaz)' and RecordType.name != 'Issue' and RecordType.name != 'Operations Service Request' and RecordType.name != 'Pre Booked Year End Support' and RecordType.name != 'Sales Operations Support Services' and RecordType.name != 'Surveys' and RecordType.name != 'Test Record Type' and RecordType.name != 'xxxALM Banking Test')]){
            if(case1.CreatedDate <= date120DaysAgo){
                if(accIdCaseMap.containsKey(case1.AccountId)){
                    caseList = accIdCaseMap.get(case1.AccountId);
                    caseList.add(case1);
                } else {
                    caseList = new list<Case>();
                    caseList.add(case1);
                    accIdCaseMap.put(case1.AccountId, caseList);
                }
            } 
            if(accIdCaseMap1.containsKey(case1.AccountId)){
                caseList1 = accIdCaseMap1.get(case1.AccountId);
                caseList1.add(case1);
            } else {
                caseList1 = new list<Case>();
                caseList1.add(case1);
                accIdCaseMap1.put(case1.AccountId, caseList1);
            }
        }

        if(accIdCaseMap != null && accIdCaseMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdCaseMap.containsKey(arup.Account__c)){
                        decimal value1 = accIdCaseMap.get(arup.Account__c).size();
                        decimal value2 = accIdCaseMap1.get(arup.Account__c).size();
                        decimal value = value1 * 100 / value2;
                        arup.Aged_backlog_of_cases__c = value;
                    }
                }
            }
        }
    }

    //for KPI 7.3
    private static void rollupCases7_3(map<id, Account> accountMap, list<Account_Rollup__c> accountRollupList){
        map<id, list<Case>> accIdCaseMap = new map<id, list<Case>>();
        map<id, list<Case>> accIdCaseMap1 = new map<id, list<Case>>();
        list<Case> caseList;
        list<Case> caseList1;
        
        for(Case case1 : [select id, AccountId, Targeted_Fix_Date__c, Engineering_Target_Release_Qtr__c from Case where AccountId in : accountMap.keySet() and Case_Category__c = 'Defect' and (Status != 'Solution Provided' and Status != 'Closed') and (RecordType.name != 'ACE360' and RecordType.name != 'COM Escalation' and RecordType.name != 'Customer Feedback' and RecordType.name != 'Engineering (LM)' and RecordType.name != 'Engineering (Turaz)' and RecordType.name != 'Issue' and RecordType.name != 'Operations Service Request' and RecordType.name != 'Pre Booked Year End Support' and RecordType.name != 'Sales Operations Support Services' and RecordType.name != 'Surveys' and RecordType.name != 'Test Record Type' and RecordType.name != 'xxxALM Banking Test')]){
            if(case1.Targeted_Fix_Date__c == null && case1.Engineering_Target_Release_Qtr__c == null){
                if(accIdCaseMap.containsKey(case1.AccountId)){
                    caseList = accIdCaseMap.get(case1.AccountId);
                    caseList.add(case1);
                } else {
                    caseList = new list<Case>();
                    caseList.add(case1);
                    accIdCaseMap.put(case1.AccountId, caseList);
                }
            } 
            if(accIdCaseMap1.containsKey(case1.AccountId)){
                caseList1 = accIdCaseMap1.get(case1.AccountId);
                caseList1.add(case1);
            } else {
                caseList1 = new list<Case>();
                caseList1.add(case1);
                accIdCaseMap1.put(case1.AccountId, caseList1);
            }
        }
        if(accIdCaseMap != null && accIdCaseMap.size() > 0){
            for(Account_Rollup__c arup : accountRollupList){
                if(arup.Account__c != null){
                    if(accIdCaseMap.containsKey(arup.Account__c)){
                        decimal value1 = accIdCaseMap.get(arup.Account__c).size();
                        decimal value2 = accIdCaseMap1.get(arup.Account__c).size();
                        system.debug('value1 = ' + value1);
                        system.debug('value2 = ' + value2);
                        decimal value = value1 * 100 / value2;
                        arup.Open_defects_with_targeted_fix_date__c = value;
                    }
                }
            }
        }
    }
}