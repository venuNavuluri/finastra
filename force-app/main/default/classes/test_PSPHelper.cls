@isTest 
private class test_PSPHelper {

    static testmethod void testPSPHelper()
    {
        List<Case> lstCase = [select Id, SLA__c,Original_SLA__c from Case where Time_Object__c != null and IsClosed=false AND sla__r.name = 'NAB' ORDER BY createdDate DESC limit 10];
        
        if(lstCase.size() > 0)
        {
            PSPHelper pspHelper = new PSPHelper(lstCase);
            pspHelper.getGlobalBH();
            pspHelper.getBusinessHoursIds();
            pspHelper.getMapCSM();
            pspHelper.getMapCaseIdCaseHistory();
            pspHelper.getMapAccountSLA_BH();
            pspHelper.getMapBusinessHours();
            pspHelper.getMapSLA();
        }
    } 

}