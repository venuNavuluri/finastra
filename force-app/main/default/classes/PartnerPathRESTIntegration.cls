public class  PartnerPathRESTIntegration {
    public static String ENDPOINT = PartnerPathUtility.getEndPoint();
    public static String TOKEN = PartnerPathUtility.getToken();
    public static String PP_DEAL_API='deals/';
    public static String LEADSTATUS_OPP_IN_SFDC='Opportunity already in SFDC';
    public static String LEADSTATUS_NOT_A_LEAD='Not a Lead';
        
    /*
    Method: sendLeadDetailsToPartnerPathOnUpdate
    Description: This method is called from the LeadTigger when the Partner Lead status is updated. 
                 This method makes an HTTP callout to partnerpath Deal API to update the lead status in partnerpath.
                 It is an asynchronous method.
    Parameters: Lead Id list
    Return: Void
    */
    @future (callout=true)
    public static void sendLeadDetailsToPartnerPathOnUpdate(list<Id> newLeadsIdsList){
        System.Debug('PartnerPathRESTIntegration :: sendLeadDetailsToPartnerPathOnUpdate() :: EndpointUrl is -->>' + ENDPOINT);
        System.Debug('PartnerPathRESTIntegration :: sendLeadDetailsToPartnerPathOnUpdate() :: Token is -->>' + TOKEN);
        List<Lead> newLeadsList = [Select id, name, status, Partnerpath_ID__c,Opportunity__c,PartnerPath_Response__c,Opportunity__r.Order_Number__c,Reason_for_Rejection__c  From Lead where id in :newLeadsIdsList];
        String partnerPathId;
        String leadJsonBody;
        for(Lead leadObj : newLeadsList){
            //To get the partnetpath Id of the Lead;
            partnerPathId= leadObj.PartnerPath_ID__c;
            //To generate the JSON string for the http request
            leadJsonBody= getLeadJsonStringOnLeadUpdate(leadObj);
            //To generate the Http request
            HttpRequest httpReq = getHttpRequest(leadJsonBody,partnerPathId,PP_DEAL_API);
            HttpResponse httpResp = new HttpResponse();
            Http http = new Http();
              try {
                    //To send the Http request to partnerpath
                    httpResp = http.send(httpReq);
                    leadObj.PartnerPath_Response__c='Http Status Code : ' + httpResp.getStatusCode() + '\n';
                    System.debug('PartnerPathRESTIntegration :: sendLeadDetailsToPartnerPathOnUpdate() ::  Http Response Status code -->> ' + httpResp.getStatusCode());
                    System.debug('PartnerPathRESTIntegration :: sendLeadDetailsToPartnerPathOnUpdate() ::  Http Response Status -->> ' + httpResp.getStatus());
                    System.debug('PartnerPathRESTIntegration :: sendLeadDetailsToPartnerPathOnUpdate() ::  Http Response body after REST call -->> ' + httpResp.getBody());
                    
                    //To parse the Json response received from partnerpath and set the hhtp status code and message on lead.PartnerPath_Response__c field
                    JSONParser parser = JSON.createParser(httpResp.getBody());
                    // Advance to the next token.
                    while (parser.nextToken() != null) {
                       if(parser.getText().equals('message')){
                           System.debug('PartnerPathRESTIntegration :: sendLeadDetailsToPartnerPathOnUpdate() :: Current token name : ' + parser.getText());
                           leadObj.PartnerPath_Response__c += parser.getText() + ' : ';
                           parser.nextToken();
                           System.debug('PartnerPathRESTIntegration :: sendLeadDetailsToPartnerPathOnUpdate() :: Current token Value : ' + parser.getText());
                           leadObj.PartnerPath_Response__c += parser.getText();
                           break;
                       }
                        
                    }
                } catch (System.CalloutException excp) {
                    System.debug('PartnerPathRESTIntegration :: sendLeadDetailsToPartnerPathOnUpdate() :: Callout error on lead updation ==>> ' + excp);
                    System.debug('PartnerPathRESTIntegration :: sendLeadDetailsToPartnerPathOnUpdate() :: Error response body on lead updation ==>> '+ httpResp.toString());
                }
          }
          //To update the leads with the Http response from partnerpath
          Update newLeadsList;
    }
    
    public static String getLeadJsonStringOnLeadUpdate(Lead leadObj){
        Account partnerAccount;
        String leadJsonString = null;
        Map<String,String> leadDealMap = new Map<String,String>();
        if(null!=leadObj){
            // Create a JSON generator object
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('deal');
            gen.writeStartObject();
            gen.writeStringField('lead_name',leadObj.Name);
            if(leadObj.status.Equals(LEADSTATUS_OPP_IN_SFDC) && null!=leadObj.Opportunity__c){
                 gen.writeStringField('opportunity_sfdc_id',string.valueof(leadObj.Opportunity__c));
                 gen.writeStringField('tenant_deal_number',leadObj.Opportunity__r.Order_Number__c);
            }
            if(leadObj.status.Equals(LEADSTATUS_NOT_A_LEAD)){
                 gen.writeStringField('decline_comment',leadObj.Reason_for_Rejection__c);
            }
            gen.writeStringField('workflow_status',leadObj.status);
            gen.writeEndObject();
            gen.writeEndObject();
            // create a string from the JSON generator
            leadJsonString = gen.getAsString();
            System.Debug('PartnerPathRESTIntegration :: getLeadJsonStringOnLeadUpdate() :: Lead Json string is -->>' + leadJsonString);
        }
        return leadJsonString;
    }
    
    /*
    Method: sendOppDetailsToPartnerPathOnOppCreate
    Description: This method is called from the PartnerPathDealUpdateTrigger when the Partner Opportunity is created(when partner lead is converted into opp). 
                 This method makes an HTTP callout to partnerpath Deal API to update the opportunity status in partnerpath.
                 It is an asynchronous method.
    Parameters: Opportunity Id list
    Return: Void
    */
    @future (callout=true)
    public static void sendOppDetailsToPartnerPathOnOppCreate(list<Id> newOppsIdsList){
        System.Debug('PartnerPathRESTIntegration :: sendOppDetailsToPartnerPathOnOppCreation() :: EndpointUrl is -->>' + ENDPOINT);
        System.Debug('PartnerPathRESTIntegration :: sendOppDetailsToPartnerPathOnOppCreation() :: Token is -->>' + TOKEN);
        List<Opportunity> newOppsList = [Select id, name,account.name,StageName,ForecastCategoryName, probability, Order_Number__c, PartnerPath_ID__c,CloseDate,Opportunity_Partner__c,Partner_Role_s__c,Partner_Originated__c, 
                                         Owner.name From Opportunity where id in :newOppsIdsList];
        String partnerPathId;
        String oppJsonBody;
        for(Opportunity opp : newOppsList){
            //To get the partnetpath Id of the opportunity;
            partnerPathId= opp.PartnerPath_ID__c;
            //To generate the JSON string for the http request
            oppJsonBody= getOppJsonStringOnOppCreate(opp);
            //To generate the Http request
            HttpRequest httpReq = getHttpRequest(oppJsonBody,partnerPathId,PP_DEAL_API);
            HttpResponse httpResp = new HttpResponse();
            Http http = new Http();
              try {
                    //To send the Http request to partnerpath
                    httpResp = http.send(httpReq);
                    System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPartnerPathOnOppCreation() ::  Http Response Status code -->> ' + httpResp.getStatusCode());
                    System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPartnerPathOnOppCreation() ::  Http Response Status -->> ' + httpResp.getStatus());
                    System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPartnerPathOnOppCreation() ::  Http Response after REST call -->> ' + httpResp.getBody());
                    //To parse the Json response received from partnerpath and set the hhtp status code and message on opp.PartnerPath_Response__c field
                    JSONParser parser = JSON.createParser(httpResp.getBody());
                    // Advance to the next token.
                    while (parser.nextToken() != null) {
                       if(parser.getText().equals('message')){
                           System.debug('PartnerPathRESTIntegration :: sendLeadDetailsToPartnerPathOnUpdate() :: Current token name : ' + parser.getText());
                           parser.nextToken();
                           System.debug('PartnerPathRESTIntegration :: sendLeadDetailsToPartnerPathOnUpdate() :: Current token Value : ' + parser.getText());
                           break;
                       }
                    }
                } catch (System.CalloutException excp) {
                    System.debug('PartnerPathRESTIntegration :: sendLeadDetailsToPartnerPathOnUpdate() :: Callout error on opp creation ==>> ' + excp);
                    System.debug('PartnerPathRESTIntegration :: sendLeadDetailsToPartnerPathOnUpdate() :: Error response body on opp creation ==>> '+ httpResp.toString());
                }
          }
    }
    
    public static String getOppJsonStringOnOppCreate(Opportunity oppObj){
        Account partnerAccount;
        String oppJsonString = null;
        Map<String,String> oppDealMap = new Map<String,String>();

        if(null!=oppObj){
            DateTime close_date = DateTime.newInstance(oppObj.CloseDate.year(), oppObj.CloseDate.month(), oppObj.CloseDate.day());
            String oppCloseDate = close_date.format('yyyy-MM-dd');
            Id oppPartnerId= oppObj.Opportunity_Partner__c;
            String oppPartner;
            if(null!= oppPartnerId){
                partnerAccount = [SELECT name, id from Account where id = :oppPartnerId];
                if(null!=partnerAccount){
                oppPartner =partnerAccount.name;
               }
            }
            // Create a JSON generator object
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('deal');
            gen.writeStartObject();
            gen.writeStringField('lead_name',oppObj.Name);
            gen.writeStringField('opportunity_sfdc_id',string.valueof(oppObj.id));
            if(null!=oppObj.Owner)
            	gen.writeStringField('prospect_company_name',oppObj.Account.Name);
            if(null!=oppObj.Account)
            	gen.writeStringField('custom_misys_owner_i_d',oppObj.Owner.name);
            gen.writeStringField('tenant_deal_number',oppObj.Order_Number__c);
            gen.writeStringField('custom_misys_forecast_category_name',String.valueOf(oppObj.ForecastCategoryName));
            gen.writeStringField('sales_stage',String.valueOf(oppObj.StageName));
            gen.writeStringField('close_probability',string.valueof(oppObj.Probability));
            gen.writeStringField('estimated_close_date',oppCloseDate);
            if(null!=oppObj.Partner_Originated__c)
                 gen.writeStringField('custom_misys_partner_originated',String.valueOf(oppObj.Partner_Originated__c));
           //To send the workflow status only on opportunity creation and not on opp udation to Partnerpath
            gen.writeStringField('workflow_status','Request to Convert');
            if(null!=oppPartner){
                 gen.writeFieldName('Company');
                 gen.writeStartObject();
                 gen.writeStringField('name', oppPartner);
                 gen.writeEndObject();
            }
            if(null!=oppObj.Partner_Role_s__c)
                 gen.writeStringField('custom_misys_partner_role',oppObj.Partner_Role_s__c);
            gen.writeEndObject();
            gen.writeEndObject();
            // create a string from the JSON generator
            oppJsonString = gen.getAsString();
            System.Debug('PartnerPathRESTIntegration :: getOppJsonStringOnOppCreation() :: Opp Json string is -->>' + oppJsonString);
        }
        return oppJsonString;
    }
    
     /*
    Method: sendOppDetailsToPartnerPathOnOppUpdate
    Description: This method is called from the PartnerPathDealUpdateTrigger when the Partner Opportunity is updated. 
                 This method makes an HTTP callout to partnerpath Deal API to update the opportunity status in partnerpath.
                 It is an asynchronous method. This method will be called each time a partner opp is updated to send the below  fields to PP.
    Parameters: Opportunity Id list
    Return: Void
    */
    @future (callout=true)
    public static void sendOppDetailsToPartnerPathOnOppUpdate(list<Id> newOppsIdsList){
        System.Debug('PartnerPathRESTIntegration :: sendOppDetailsToPartnerPathOnOppUpdate() :: EndpointUrl is -->>' + ENDPOINT);
        System.Debug('PartnerPathRESTIntegration :: sendOppDetailsToPartnerPathOnOppUpdate() :: Token is -->>' + TOKEN);
        List<Opportunity> newOppsList = [Select id, name,account.name,StageName,ForecastCategoryName, probability, Order_Number__c, PartnerPath_ID__c,CloseDate,Sales_Region_FY07__c,MainProduct__c,
                        Pricing_Country__c,Opportunity_Partner__c,Partner_Role_s__c,Partner_Originated__c,Partner_Advisory_Manager_Comment__c, NextStep, Next_Step_Due_Date__c, Owner.name,Proposed_Solution__c,
                        Why_Misys_Unique_Selling_Point__c, SDA_3_Vision_Roadmap__c, Why_do_something__c, Installed_Supplier__c,MainCompetitor__c,Other_Competition__c,Competitive_Differentiators__c,Key_Dependencies__c,
                        ARIS_product_included__c,MAPS_product_included__c From Opportunity where id in :newOppsIdsList];
                        
        String partnerPathId;
        String oppJsonBody;
        for(Opportunity opp : newOppsList){
            //To get the partnetpath Id of the opportunity;
            partnerPathId= opp.PartnerPath_ID__c;
            //To generate the JSON string for the http request
            oppJsonBody=getOppJsonStringOnOppUpdate(opp);
            //To get the Http request
            HttpRequest httpReq = getHttpRequest(oppJsonBody,partnerPathId,PP_DEAL_API);
            HttpResponse httpResp = new HttpResponse();
            Http http = new Http();
              try {
                    //To send the Http request to partnerpath after opportunity creation (when lead is converted to opportunity)
                    httpResp = http.send(httpReq);
                    System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPartnerPathOnOppUpdate() ::  Http Response Status code -->> ' + httpResp.getStatusCode());
                    System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPartnerPathOnOppUpdate() ::  Http Response Status -->> ' + httpResp.getStatus());
                    System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPartnerPathOnOppUpdate() ::  Http Response after REST call -->> ' + httpResp.getBody());
                    //To parse the Json response received from partnerpath and set the hhtp status code and message on opp.PartnerPath_Response__c field
                    JSONParser parser = JSON.createParser(httpResp.getBody());
                    // Advance to the next token.
                    while (parser.nextToken() != null) {
                       if(parser.getText().equals('message')){
                           System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPartnerPathOnOppUpdate() :: Current token name : ' + parser.getText());
                           parser.nextToken();
                           System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPartnerPathOnOppUpdate() :: Current token Value : ' + parser.getText());
                           break;
                       }
                    }
                } catch (System.CalloutException excp) {
                    System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPartnerPathOnOppUpdate() :: Callout error on opp updation ==>> ' + excp);
                    System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPartnerPathOnOppUpdate() :: Error response body on opp updation==>> '+ httpResp.toString());
                }
          }
         
    }
    
     /*
    Method: sendOppDetailsToPPSync
    Description: This method is called from the PartnerPathDealUpdateTrigger when the trigger is being called from a scheduled Batch job or 
				 another future method.This method makes an HTTP callout to partnerpath Deal API to update the opportunity status in partnerpath.
				 This is a synchronous call, made to PP when opportunity update is invoked from batch apex.
    Parameters: Opportunity obj list
    Return: Void
    */
    public static void sendOppDetailsToPPSync(list<Opportunity> newOppsList){
        System.Debug('PartnerPathRESTIntegration :: sendOppDetailsToPPSync() :: EndpointUrl is -->>' + ENDPOINT);
        System.Debug('PartnerPathRESTIntegration :: sendOppDetailsToPPSync() :: Token is -->>' + TOKEN);
	    String partnerPathId;
        String oppJsonBody;
        for(Opportunity opp : newOppsList){
            //To get the partnetpath Id of the opportunity;
            partnerPathId= opp.PartnerPath_ID__c;
            //To generate the JSON string for the http request
            oppJsonBody=getOppJsonStringOnOppUpdate(opp);
            //To get the Http request
            HttpRequest httpReq = getHttpRequest(oppJsonBody,partnerPathId,PP_DEAL_API);
            HttpResponse httpResp = new HttpResponse();
            Http http = new Http();
              try {
                    //To send the Http request to partnerpath after opportunity creation (when lead is converted to opportunity)
                    httpResp = http.send(httpReq);
                    System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPPSync() ::  Http Response Status code -->> ' + httpResp.getStatusCode());
                    System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPPSync() ::  Http Response Status -->> ' + httpResp.getStatus());
                    System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPPSync() ::  Http Response after REST call -->> ' + httpResp.getBody());
                  /*  //To parse the Json response received from partnerpath and set the hhtp status code and message on opp.PartnerPath_Response__c field
                    JSONParser parser = JSON.createParser(httpResp.getBody());
                    // Advance to the next token.
                    while (parser.nextToken() != null) {
                       if(parser.getText().equals('message')){
                           System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPPSync() :: Current token name : ' + parser.getText());
                           parser.nextToken();
                           System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPPSync() :: Current token Value : ' + parser.getText());
                           break;
                       }
                    }*/
                } catch (System.CalloutException excp) {
                    System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPPSync() :: Callout error on opp updation ==>> ' + excp);
                    System.debug('PartnerPathRESTIntegration :: sendOppDetailsToPPSync() :: Error response body on opp updation==>> '+ httpResp.toString());
                }
          }
         
    }
        
    public static String getOppJsonStringOnOppUpdate(Opportunity oppObj){
        Account partnerAccount;
        String oppJsonString = null;
        Map<String,String> oppDealMap = new Map<String,String>();

        if(null!=oppObj){
            String nextStepDueDate = null;
            DateTime close_date = DateTime.newInstance(oppObj.CloseDate.year(), oppObj.CloseDate.month(), oppObj.CloseDate.day());
            String oppCloseDate = close_date.format('yyyy-MM-dd');
            if(null!=oppObj.Next_Step_Due_Date__c){
                    DateTime next_Step_Due_Date = DateTime.newInstance(oppObj.Next_Step_Due_Date__c.year(), oppObj.Next_Step_Due_Date__c.month(), oppObj.Next_Step_Due_Date__c.day());
                    nextStepDueDate = next_Step_Due_Date.format('yyyy-MM-dd');
            }
            Id oppPartnerId= oppObj.Opportunity_Partner__c;
            String oppPartner;
            if(null!= oppPartnerId){
                partnerAccount = [SELECT name, id from Account where id = :oppPartnerId];
                if(null!=partnerAccount){
                oppPartner =partnerAccount.name;
               }
            }
            // Create a JSON generator object
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('deal');
            gen.writeStartObject();
            gen.writeStringField('lead_name',oppObj.Name);
            gen.writeStringField('opportunity_sfdc_id',string.valueof(oppObj.id));
            if(null!=oppObj.Account)
            	gen.writeStringField('prospect_company_name',oppObj.Account.Name);
            if(null!=oppObj.Owner)
            	gen.writeStringField('custom_misys_owner_i_d',oppObj.Owner.name);
            gen.writeStringField('tenant_deal_number',oppObj.Order_Number__c);
            gen.writeStringField('custom_misys_forecast_category_name',String.valueOf(oppObj.ForecastCategoryName));
            gen.writeStringField('sales_stage',String.valueOf(oppObj.StageName));
            gen.writeStringField('close_probability',string.valueof(oppObj.Probability));
            gen.writeStringField('estimated_close_date',oppCloseDate);
            if(null!=oppObj.Partner_Originated__c)
            gen.writeStringField('custom_misys_partner_originated',String.valueOf(oppObj.Partner_Originated__c));
            if(null!=oppObj.Sales_Region_FY07__c)
                 gen.writeStringField('custom_misys_sales_region_fy07',oppObj.Sales_Region_FY07__c);
            if(null!=oppObj.MainProduct__c)
                gen.writeStringField('custom_misys_main_product',oppObj.MainProduct__c);
            if(null!=oppObj.Pricing_Country__c)
                gen.writeStringField('custom_misys_pricing_country',oppObj.Pricing_Country__c);
            if(null!=oppObj.Partner_Role_s__c)
                 gen.writeStringField('custom_misys_partner_role',oppObj.Partner_Role_s__c);
            if(null!=oppObj.Partner_Advisory_Manager_Comment__c)
                gen.writeStringField('custom_misys_partner_advisory_manager_comment',oppObj.Partner_Advisory_Manager_Comment__c);
            if(null!=oppObj.NextStep)
                gen.writeStringField('custom_misys_next_step',oppObj.NextStep);
            if(null!=nextStepDueDate)
                gen.writeStringField('custom_misys_next_step_due_date',nextStepDueDate);
            if(null!=oppObj.Proposed_Solution__c)
                gen.writeStringField('custom_misys_proposed_solution',oppObj.Proposed_Solution__c);
            if(null!=oppObj.Why_Misys_Unique_Selling_Point__c)
                gen.writeStringField('custom_misys_unique_selling_point',oppObj.Why_Misys_Unique_Selling_Point__c);
            if(null!=oppObj.SDA_3_Vision_Roadmap__c)
                gen.writeStringField('custom_misys_sda_3_vision_roadmap',oppObj.SDA_3_Vision_Roadmap__c);
            if(null!=oppObj.Why_do_something__c)
                gen.writeStringField('custom_misys_why_do_something',oppObj.Why_do_something__c);
            if(null!=oppObj.Installed_Supplier__c)
                gen.writeStringField('custom_misys_installed_supplier',oppObj.Installed_Supplier__c);
            if(null!=oppObj.MainCompetitor__c)
                gen.writeStringField('custom_misys_main_competitor',oppObj.MainCompetitor__c);
            if(null!=oppObj.Other_Competition__c)
                gen.writeStringField('custom_misys_other_competition',oppObj.Other_Competition__c);
            if(null!=oppObj.Competitive_Differentiators__c)
                gen.writeStringField('custom_misys_competitive_differentiators',oppObj.Competitive_Differentiators__c);
            if(null!=oppObj.Key_Dependencies__c)
                gen.writeStringField('custom_misys_key_dependencies',oppObj.Key_Dependencies__c);
            if(null!=oppObj.ARIS_product_included__c)
                 gen.writeStringField('custom_misys_aris_product_included',String.valueOf(oppObj.ARIS_product_included__c));
            if(null!=oppObj.MAPS_product_included__c)
                gen.writeStringField('custom_misys_maps_product_included',String.valueOf(oppObj.MAPS_product_included__c));
            if(null!=oppPartner){
                 gen.writeFieldName('Company');
                 gen.writeStartObject();
                 gen.writeStringField('name', oppPartner);
                 gen.writeEndObject();
            }
            gen.writeEndObject();
            gen.writeEndObject();
            // create a string from the JSON generator
            oppJsonString = gen.getAsString();
        }
        
        return oppJsonString;
    }
    
    public static HttpRequest getHttpRequest(String oppJsonString, String partnerPathId, String ppApi){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT+ppApi+partnerPathId);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('X-API-Version', '1');
        req.setHeader('Authorization', 'Token access_token=' + TOKEN);
        req.setBody(oppJsonString);
        req.setCompressed(false);
        System.debug('PartnerPathRESTIntegration :: getHttpRequest() :: Http request is -->> ' + req);
        System.debug('PartnerPathRESTIntegration :: getHttpRequest() :: JSON Body is -->> ' + req.getBody());
        
        return req;
    }
    
}