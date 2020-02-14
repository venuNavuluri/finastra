/*
	Created By: Abhinit Kohar
	Creatd Date: 23/06/2014
	Description: This class implements a Web Service that can be invoked as an Automated Step from Salesguide.
	This class returns the unprocessed Sales Order Types for an opportunity. 
	The interface supports two operations
		describe : returns service metadata for inclusion as a service step in the guide designer
		invoke : implements the service call at runtime
*/
global class ce4sfStep_GetPendingSalesOrderType implements ce4sf20_001.IAeAutomatedStepService {
	
    // keep a static copy of the service description as this will not change     
    private static ce4sf20_001.AeServiceDescription sDescription;
    static {
       sDescription = new ce4sf20_001.AeServiceDescription();
       // namespace for this class
       sDescription.namespaceQualifier = ce4sf20_001.AeServiceDescription.getNamespacePrefixForClass('ce4sfStep_GetPendingSalesOrderType');
       // name of this class
       sDescription.name = 'ce4sfStep_GetPendingSalesOrderType';
       // service name displayed to users
       sDescription.displayName = 'Get Pending Sales Order Type';
       // description of service displayed to users
       sDescription.description = 'GetPendingSalesOrderType web service that can be called from sales guides';
       
       // add input parameters
       sDescription.addInputParameterDesc('opportunityId', 'id', false);
       
       // Add output parameters
       sDescription.addOutputParameterDesc('salesOrderTypes', 'string');
    }

    // Runtime service invocation    
    global ce4sf20_001.AeServiceResponse invoke(ce4sf20_001.AeServiceRequest aRequest) {
       
       // get a map of name/value pairs from request
       Map<String,Object> params = aRequest.getTypedParameterMap(sDescription.getInputParameterMap());
       // get all parameters as their native Apex types
       Id opportunityId = (Id) params.get('opportunityId');
       
       // create a response
       ce4sf20_001.AeServiceResponse response = new ce4sf20_001.AeServiceResponse();
       if(opportunityId == null){
       		response.addErrorInfo('Invalid request. Opportunity Id is missing in request.');	
           return response;
       } else {
       		String salesOrderTypes;
       		String errMassage;
       		set<String> salesOrderTypeSet = new set<String>();
       		System.Savepoint sp1 = Database.setSavepoint();
       		try {
		    	system.debug('opportunityId = ' + opportunityId);

				for(OpportunityLineItem oli : [Select Id, SO_Grouping__c From OpportunityLineItem where OpportunityId = :opportunityId and Processed__c = false]){
					if(oli.SO_Grouping__c.split('-').size() >= 2 ){
						String soType = oli.SO_Grouping__c.split('-')[0] + '-' + oli.SO_Grouping__c.split('-')[1];
						if(!salesOrderTypeSet.contains(soType)){
							salesOrderTypeSet.add(oli.SO_Grouping__c.split('-')[0] + '-' + oli.SO_Grouping__c.split('-')[1]);
							if(salesOrderTypes == null || salesOrderTypes == ''){
								salesOrderTypes = soType + ';';
							} else {
								salesOrderTypes = salesOrderTypes + soType + ';';
							}
						}
					}
	    		}
	    		response.addParameter('salesOrderTypes', salesOrderTypes);
       		} catch(Exception ex) {
       			system.debug('exception 1 = ' + ex);
       			errMassage = ex.getMessage();
       			system.debug('errMassage = ' + errMassage);
       			response.addErrorInfo('Request could not be completed due to the following error - ' + errMassage);
       			Database.rollback(sp1);
       		}
       }
       system.debug('response = ' + response);
       return response;
    }
    
    // Returns service metadata for inclusion in guide designer
    global ce4sf20_001.AeServiceDescription describe() {
       return sDescription;
    }
}