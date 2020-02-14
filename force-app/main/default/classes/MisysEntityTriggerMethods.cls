public with sharing class MisysEntityTriggerMethods {
	
	static final String PRIMARY_SIGNATORY = 'Primary signatory';
	static final String PREFERRED_SIGNATORY_1 = 'Preferred signatory 1';
	static final String PREFERRED_SIGNATORY_2 = 'Preferred signatory 2';
	static final String PREFERRED_SIGNATORY_3 = 'Preferred signatory 3';
	static final String PREFERRED_SIGNATORY_4 = 'Preferred signatory 4';
	static final String SECOND_SIGNATORY = 'Second signatory';
	static final String SECOND_SIGNATORY_2 = 'Second signatory 2';
	static final String ALTERNATIVE_SIGNATORY_1 = 'Alternative signatory - 1';
	static final String ALTERNATIVE_SIGNATORY_2 = 'Alternative signatory - 2';
	static final String ALTERNATIVE_SIGNATORY_3 = 'Alternative signatory - 3';
	static final String ALTERNATIVE_SIGNATORY_4 = 'Alternative signatory - 4';
	
	public static void updateContactRoles(map<Id, Billing_Entity__c> newEntityMap, map<Id, Billing_Entity__c> oldEntityMap){
		
		map<Id, list<Id>> meOppIdMap = new map<Id, list<Id>>();
		for(Opportunity opp : [Select id, Entity__c from Opportunity where Entity__c in :newEntityMap.keySet()]){
			if(!meOppIdMap.containsKey(opp.Entity__c)){
				list<id> oppList = new list<id>();
				oppList.add(opp.Id);
				meOppIdMap.put(opp.Entity__c, oppList);
			} else {
				meOppIdMap.get(opp.Entity__c).add(opp.Id);
			}
		}
		system.debug('meOppIdMap = ' + meOppIdMap);


		set<Id> oldContactIds = new set<Id>();
		list<OpportunityContactRole> newOCRList = new list<OpportunityContactRole>();
		
		for(Billing_Entity__c me : newEntityMap.values()){
			if(me.Primary_signatory__c != oldEntityMap.get(me.Id).Primary_signatory__c){
				if(me.Primary_signatory__c != null && meOppIdMap.containsKey(me.Id)){
					for(Id oppId : meOppIdMap.get(me.Id)){
						newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = me.Primary_signatory__c, Role = PRIMARY_SIGNATORY));
					}
				}
				if(oldEntityMap.get(me.Id).Primary_signatory__c != null && meOppIdMap.containsKey(me.Id)){
					oldContactIds.add(oldEntityMap.get(me.Id).Primary_signatory__c);
				}
			}
			if(me.Preferred_signatory_1__c != oldEntityMap.get(me.Id).Preferred_signatory_1__c){
				if(me.Preferred_signatory_1__c != null && meOppIdMap.containsKey(me.Id)){
					for(Id oppId : meOppIdMap.get(me.Id)){
						newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = me.Preferred_signatory_1__c, Role = PREFERRED_SIGNATORY_1));
					}
				}
				if(oldEntityMap.get(me.Id).Preferred_signatory_1__c != null && meOppIdMap.containsKey(me.Id)){
					oldContactIds.add(oldEntityMap.get(me.Id).Preferred_signatory_1__c);
				}
			}
			if(me.Preferred_signatory_2__c != oldEntityMap.get(me.Id).Preferred_signatory_2__c){
				if(me.Preferred_signatory_2__c != null && meOppIdMap.containsKey(me.Id)){
					for(Id oppId : meOppIdMap.get(me.Id)){
						newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = me.Preferred_signatory_2__c, Role = PREFERRED_SIGNATORY_2));
					}
				}
				if(oldEntityMap.get(me.Id).Preferred_signatory_2__c != null && meOppIdMap.containsKey(me.Id)){
					oldContactIds.add(oldEntityMap.get(me.Id).Preferred_signatory_2__c);
				}
			}
			if(me.Preferred_signatory_3__c != oldEntityMap.get(me.Id).Preferred_signatory_3__c){
				if(me.Preferred_signatory_3__c != null && meOppIdMap.containsKey(me.Id)){
					for(Id oppId : meOppIdMap.get(me.Id)){
						newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = me.Preferred_signatory_3__c, Role = PREFERRED_SIGNATORY_3));
					}
				}
				if(oldEntityMap.get(me.Id).Preferred_signatory_3__c != null && meOppIdMap.containsKey(me.Id)){
					oldContactIds.add(oldEntityMap.get(me.Id).Preferred_signatory_3__c);
				}
			}
			if(me.Preferred_signatory_4__c != oldEntityMap.get(me.Id).Preferred_signatory_4__c){
				if(me.Preferred_signatory_4__c != null && meOppIdMap.containsKey(me.Id)){
					for(Id oppId : meOppIdMap.get(me.Id)){
						newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = me.Preferred_signatory_4__c, Role = PREFERRED_SIGNATORY_4));
					}
				}
				if(oldEntityMap.get(me.Id).Preferred_signatory_4__c != null && meOppIdMap.containsKey(me.Id)){
					oldContactIds.add(oldEntityMap.get(me.Id).Preferred_signatory_4__c);
				}
			}
			if(me.Second_signatory__c != oldEntityMap.get(me.Id).Second_signatory__c){
				if(me.Second_signatory__c != null && meOppIdMap.containsKey(me.Id)){
					for(Id oppId : meOppIdMap.get(me.Id)){
						newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = me.Second_signatory__c, Role = SECOND_SIGNATORY));
					}
				}
				if(oldEntityMap.get(me.Id).Second_signatory__c != null && meOppIdMap.containsKey(me.Id)){
					oldContactIds.add(oldEntityMap.get(me.Id).Second_signatory__c);
				}
			}
			if(me.Second_signatory_2__c != oldEntityMap.get(me.Id).Second_signatory_2__c){
				if(me.Second_signatory_2__c != null && meOppIdMap.containsKey(me.Id)){
					for(Id oppId : meOppIdMap.get(me.Id)){
						newOCRList.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = me.Second_signatory_2__c, Role = SECOND_SIGNATORY_2));
					}
				}
				if(oldEntityMap.get(me.Id).Second_signatory_2__c != null && meOppIdMap.containsKey(me.Id)){
					oldContactIds.add(oldEntityMap.get(me.Id).Second_signatory_2__c);
				}
			}
		}
		system.debug('oldContactIds = ' + oldContactIds);
		system.debug('meOppIdMap = ' + meOppIdMap);
		if(oldContactIds != null && oldContactIds.size() > 0 && meOppIdMap != null && meOppIdMap.size() > 0){
			set<Id> oppIds = new set<Id>();
			for(list<Id> oppIdList : meOppIdMap.values()){
				oppIds.addAll(oppIdList);
			}
			list<OpportunityContactRole> oldOCRList = [select id, ContactId, OpportunityId, Role from OpportunityContactRole where ContactId in :oldContactIds and OpportunityId in :oppIds];
			system.debug('oldOCRList = ' + oldOCRList);
			if(oldOCRList != null && oldOCRList.size() > 0){
				delete oldOCRList;
			}
		}
		system.debug('newOCRList = ' + newOCRList);
		if(newOCRList != null && newOCRList.size() > 0){
			insert newOCRList;
		}

	}

}