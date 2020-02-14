trigger ALMExternalCustomerCaseBeforeInsert on ALM_External_Customer_Case__c (before insert) {

  for (ALM_External_Customer_Case__c alm : Trigger.new) {
  	alm.External_Source_ID_Concatenated__c = alm.External_ID_Source__c + alm.External_ID__c;
  }

  Set<String> GEMIDs    = new Set<String>();
  Set<String> SINIDs    = new Set<String>();
  Set<String> QNTIDs    = new Set<String>();
  Set<String> BUGIDs    = new Set<String>();
  Set<String> SFDIDs    = new Set<String>();

  for (ALM_External_Customer_Case__c alm : Trigger.new) {

    if (alm.internal_customer_case_ID__c != null) {

      if (alm.external_id_source__c == 'GEM') {
  		GEMIDs.add(alm.internal_customer_case_ID__c);
  	  } else if (alm.external_id_source__c == 'SIN') {
  		SINIDs.add(alm.internal_customer_case_ID__c);
  	  } else if (alm.external_id_source__c == 'QNT') {
  		QNTIDs.add(alm.internal_customer_case_ID__c);
  	  } else if (alm.external_id_source__c == 'BUG') {
  		BUGIDs.add(alm.internal_customer_case_ID__c);
  	  } else if (alm.external_id_source__c == 'SFD') {
  		SFDIDs.add(alm.internal_customer_case_ID__c);
  	  }
    }
  }
  
  Map<String, Case> mapOfCasesByGEM = new Map<String, Case>();
  Map<String, Case> mapOfCasesBySIN = new Map<String, Case>();
  Map<String, Case> mapOfCasesByQNT = new Map<String, Case>();
  Map<String, Case> mapOfCasesByBUG = new Map<String, Case>();
  Map<String, Case> mapOfCasesBySFD = new Map<String, Case>();

  if (GEMIDs.size() > 0) {
    for (Case c : [SELECT id, GEMS_Number__c FROM case WHERE GEMS_Number__c IN :GEMIDs]) {
  	   mapOfCasesByGEM.put(c.GEMS_Number__c, c);
    }  
  }
  
  if (SINIDs.size() > 0) {
    for (Case c : [SELECT id, SINS_Number1__c FROM case WHERE SINS_Number1__c IN :SINIDs]) {
  	   mapOfCasesBySIN.put(c.SINS_Number1__c, c);
    }  
  }
  
  if (QNTIDs.size() > 0) {
    for (Case c : [SELECT id, Quintus_Id__c FROM case WHERE Quintus_Id__c IN :QNTIDs]) {
  	   mapOfCasesByQNT.put(c.Quintus_Id__c, c);
    }  
  }
  
  if (BUGIDs.size() > 0) {
    for (Case c : [SELECT id, Bugzilla_Reference__c FROM case WHERE Bugzilla_Reference__c IN :BUGIDs]) {
  	   mapOfCasesByBUG.put(c.Bugzilla_Reference__c, c);
    }  
  }
  
  if (SFDIDs.size() > 0) {
    for (Case c : [SELECT id, caseNumber FROM case WHERE caseNumber IN :SFDIDs]) {
  	   mapOfCasesBySFD.put(c.caseNumber, c);
    }  
  }
  
  
  for (ALM_External_Customer_Case__c alm : Trigger.new) {
    Case c;
    if (alm.external_id_source__c == 'GEM') {
      c = mapOfCasesByGEM.get(alm.internal_customer_case_ID__c);
   	} else if (alm.external_id_source__c == 'SIN') {
      c = mapOfCasesBySIN.get(alm.internal_customer_case_ID__c);
  	} else if (alm.external_id_source__c == 'QNT') {
      c = mapOfCasesByQNT.get(alm.internal_customer_case_ID__c);
  	} else if (alm.external_id_source__c == 'BUG') {
      c = mapOfCasesByBUG.get(alm.internal_customer_case_ID__c);
  	} else if (alm.external_id_source__c == 'SFD') {
      c = mapOfCasesBySFD.get(alm.internal_customer_case_ID__c);
  	}

    if (c != null) {
    	alm.Customer_Case__c = c.id;
    }
  }  

}