trigger ALMExternalCountOffsetBeforeInsert on ALM_External_Count_Offset__c (before insert) {

  for (ALM_External_Count_Offset__c alm : Trigger.new) {
  	alm.External_Source_ID_Concatenated__c = alm.External_ID_Source__c + alm.External_ID__c;
  }

}