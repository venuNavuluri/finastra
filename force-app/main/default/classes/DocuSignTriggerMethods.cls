/*
	Created By: Abhini Kohar
	Created Date: 14/11/2013
	Description: This is the helper class for DocuSignTrigger.
*/
public with sharing class DocuSignTriggerMethods {
	
	//This method creates the Contract record if the docusign status is Completed. It updates the opportunity to Closed Won and
	//sets the Client_Signed_contract_attached__c flag to true. Picks up the signed contract document from DocuSign Status object record 
	//and attaches it to newly created Contract record.
	public static void createContract(map<Id, dsfs__DocuSign_Status__c> newDSMap, map<Id, dsfs__DocuSign_Status__c> oldDSMap){
		
		list<Contract> contractList = new list<Contract>();
		list<Opportunity> updateOppList = new list<Opportunity>();
        list<Attachment> newAttachments = new list<Attachment>();
        id maintenanceRenwelRecordTypeId = '01220000000UYrG';
        set<id> oppIds = new set<id>();
		
		for(dsfs__DocuSign_Status__c ds : newDSMap.values()) {
			if(ds.dsfs__Envelope_Status__c == 'Completed' && ds.dsfs__Envelope_Status__c != oldDSMap.get(ds.Id).dsfs__Envelope_Status__c){
				if(ds.dsfs__Opportunity__c != null){
					oppIds.add(ds.dsfs__Opportunity__c);
				}
			}
		}
		map<id, Opportunity> oppMap = new map<id, Opportunity>([select id, recordtypeid from Opportunity where id in : oppIds]);

		for(dsfs__DocuSign_Status__c ds : newDSMap.values()) {
			if(ds.dsfs__Envelope_Status__c == 'Completed' && ds.dsfs__Envelope_Status__c != oldDSMap.get(ds.Id).dsfs__Envelope_Status__c){
				if(ds.dsfs__Opportunity__c != null && ds.dsfs__Company__c != null && oppMap != null && oppMap.containsKey(ds.dsfs__Opportunity__c) && oppMap.get(ds.dsfs__Opportunity__c).recordTypeId != maintenanceRenwelRecordTypeId){
					contractList.add(new Contract(Misys_Opportunity__c = ds.dsfs__Opportunity__c, AccountId = ds.dsfs__Company__c, DocuSignId__c = ds.Id, Misys_Entity__c = ds.Misys_Entity_Id__c));
				}
			}
		}
		system.debug('contractList = ' + contractList);
		
		if(contractList != null && contractList.size() > 0){
			insert contractList;
			for(Contract con : contractList){
				updateOppList.add(new Opportunity(Id = con.Misys_Opportunity__c, Client_Signed_contract_attached__c = true, StageName = 'Closed Won'));
				newDSMap.get(con.DocuSignId__c).dsfs__Contract__c = con.Id;
			}
			system.debug('newDSMap = ' + newDSMap);
			system.debug('updateOppList = ' + updateOppList);
			
			if(updateOppList != null && updateOppList.size() > 0){
				update updateOppList;
			}
            for(Attachment att : [select id, parentid, Name, Body from attachment where parentid in :newDSMap.keySet()]){
                if(newDSMap.containsKey(att.ParentId) && newDSMap.get(att.ParentId).dsfs__Contract__c != null){
	                newAttachments.add(new Attachment(parentid = newDSMap.get(att.ParentId).dsfs__Contract__c, Name = att.Name, Body = att.Body));
                }
            }
            system.debug('newAttachments = ' + newAttachments);
            if(newAttachments != null && newAttachments.size() > 0){
                insert newAttachments; 
            }
		}
	}
}