/*
Author: Ramesh Thulasi
Descriptiton:   Inline visualforce controller for pipeline project. 
                For details please refer to https://almtools/confluence/display/GBA/Pipeline+Project+Creation
Created on: 27-2-2018
*/

public class OpportunityPipelinesExt {
    @TestVisible
    private final Opportunity opp;
    public Boolean psDisable { get; private set; }
    public Boolean plDisable { get; private set; }
    public List<NS_Project__c> nsProjs { get; private set; }
    public Boolean hasNsProjs { get { 
                                    return (nsProjs==null||nsProjs.size()<=0)?false:true;
                                 } private set; }
    public OpportunityPipelinesExt(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()){
            stdController.addFields(new List<String>{'Name','PS_Stage__c','StageName','PS_Risk_Category__c'});
        }
        opp = (Opportunity)stdController.getRecord();
        System.debug('RTDebug opp.PS_Stage__c ' + opp.PS_Stage__c);
        System.debug('RTDebug opp.StageName ' + opp.StageName);
        nsProjs = [select name, Project_Product__c from NS_Project__c where Opportunity__c  =: opp.id];
        Integer psProjCount = [select Count() from NS_Project__c where Opportunity__c  =: opp.id and Deferred_Account_Type__c='PS'];
        Integer plProjCount = [select Count() from NS_Project__c where Opportunity__c  =: opp.id and Deferred_Account_Type__c=:OppPipelineUtil.PIPELINE_DEFFERED_NAME];
        System.debug('RTDebug psProjCount ' + psProjCount);
        System.debug('RTDebug plProjCount ' + plProjCount);
        plDisable = true;
        if( psProjCount<=0 
            && (OppPipelineUtil.licensesWithOrWithoutPSRecordTypeId == opp.RecordTypeId || OppPipelineUtil.changeOrderRecordTypeId == opp.RecordTypeId || OppPipelineUtil.psOnlyRecordTypeId == opp.RecordTypeId ) 
            && ('4. Refine'==opp.PS_Stage__c || '5. Approve'==opp.PS_Stage__c || '6. Negotiate'==opp.PS_Stage__c || 'Closed Won' == opp.PS_Stage__c || 'Closed Qualified Out' == opp.PS_Stage__c || 'Closed Lost' == opp.PS_Stage__c) 
            && null!=opp.PS_Stage__c 
            && '1. Engage'!=opp.PS_Stage__c
            && null!=opp.PS_Risk_Category__c ){
            plDisable = false;
        }
        psDisable = true;
        if( plProjCount<=0 ){
            psDisable = false;
        }
    }
    public PageReference createGSCProject() {
        PageReference pRef = new PageReference('/' + NS_Project__c.SObjectType.getDescribe().getKeyPrefix() + '/e');
        Map<String, String> paramMap = buildParamValues(pRef.getParameters());
        paramMap.put(OppPipelineUtil.DEFERRED_ACCOUNT_TYPE_FIELD_ID, 'GSC');
        return pRef;
    }
    public PageReference createPSProject() {
        PageReference pRef = new PageReference('/' + NS_Project__c.SObjectType.getDescribe().getKeyPrefix() + '/e');
        Map<String, String> paramMap = buildParamValues(pRef.getParameters());
        paramMap.put(OppPipelineUtil.DEFERRED_ACCOUNT_TYPE_FIELD_ID, 'PS');
        return pRef;
    }
    public PageReference createPLProject() {
        PageReference pRef = new PageReference('/' + NS_Project__c.SObjectType.getDescribe().getKeyPrefix() + '/e');
        Map<String, String> paramMap = buildParamValues(pRef.getParameters());
        paramMap.put(OppPipelineUtil.DEFERRED_ACCOUNT_TYPE_FIELD_ID, OppPipelineUtil.PIPELINE_DEFFERED_NAME);
        return pRef;
    }
    public pageReference newNSProject(){  
        PageReference pRef = new PageReference('/'+NS_Project__c.SObjectType.getDescribe().getKeyPrefix()+'/e');  
        Map<String, String> paramMap = pRef.getParameters();
        paramMap.put('retURL', opp.id);
        return pRef; 
    } 
    public pageReference editNSProject(){  
        String nsProjId = Apexpages.currentpage().getParameters().get('nsProjId');  
        PageReference pRef = new PageReference('/'+ nsProjId +'/e');  
        Map<String, String> paramMap = pRef.getParameters();
        paramMap.put('retURL', opp.id);
        return pRef;  
    }
    public pageReference deleteNSProject(){  
        String nsProjId = Apexpages.currentpage().getParameters().get('nsProjId');  
        NS_Project__c nsProj = [SELECT Id FROM NS_Project__c WHERE id = : nsProjId LIMIT 1]; 
        delete nsProj; 
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm(); 
        PageReference pRef = new PageReference('/'+opp.id); 
        return pRef;  
    }
    private Map<String, String> buildParamValues( Map<String, String> paramMap ) {
        paramMap.put(OppPipelineUtil.TRICKLE_OPPORTUNITY_DATA_FIELD_ID, '1');
        paramMap.put(OppPipelineUtil.OPP_FIELD_ID, opp.Name);
        paramMap.put(OppPipelineUtil.OPP_FIELD_ID+'_lkid', opp.Id);
        paramMap.put('nooverride', '1');
        paramMap.put('cancelURL', '/'+opp.Id);
        return paramMap;
    }      
}