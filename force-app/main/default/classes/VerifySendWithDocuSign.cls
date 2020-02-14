global class VerifySendWithDocuSign {

	webservice static Boolean verifyReuirements(Id oppId){
		Boolean primaryFlag = false;
		Boolean customerFlag = false;
		Boolean returnFlag = false;
		Opportunity opp = [select id, Approval_Status__c, Entity__c, Is_PearlMastered__c from Opportunity where Id = :oppId];
		if(opp.Approval_Status__c == 'Approved' || opp.Approval_Status__c == 'Not required' && opp.Is_PearlMastered__c == true && opp.Entity__c != null){
			list<Billing_Entity__c> meList = [select id, Entity_Status__c from Billing_Entity__c where Id = :opp.Entity__c and Entity_Status__c = 'Contracting Entity'];
			if(meList != null && meList.size() > 0){
				list<OpportunityContactRole> ocrList = [select ContactId, Role from OpportunityContactRole where OpportunityId = :oppId];
				if(ocrList != null && ocrList.size() > 0){
					for(OpportunityContactRole ocr : [select ContactId, Role from OpportunityContactRole where OpportunityId = :oppId]){
						if(ocr.Role == 'Primary signatory'){
							primaryFlag = true;
						}
						if(ocr.Role == 'Customer Signatory'){
							customerFlag = true;
						}
					}
				}
			}
		}
		if(primaryFlag == true && customerFlag == true){
			returnFlag = true;
		}
		return returnFlag;
	}
}