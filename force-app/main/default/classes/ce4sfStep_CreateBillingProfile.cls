global class ce4sfStep_CreateBillingProfile implements ce4sf20_001.IAeAutomatedStepService {

    // keep a static copy of the service description as this will not change     
    private static ce4sf20_001.AeServiceDescription sDescription;
    static {
       sDescription = new ce4sf20_001.AeServiceDescription();
       // namespace for this class
       sDescription.namespaceQualifier = ce4sf20_001.AeServiceDescription.getNamespacePrefixForClass('ce4sfStep_CreateBillingProfile');
       // name of this class
       sDescription.name = 'ce4sfStep_CreateBillingProfile';
       // service name displayed to users
       sDescription.displayName = 'Create Billing Profile';
       // description of service displayed to users
       sDescription.description = 'CreateBillingProfile web service that can be called from sales guides';
       
       // add input parameters
       sDescription.addInputParameterDesc('opportunityId', 'id', false);
       sDescription.addInputParameterDesc('acctBySubId', 'id', false);
       sDescription.addInputParameterDesc('contractId', 'id', false);
       sDescription.addInputParameterDesc('billToId', 'id', false);
       sDescription.addInputParameterDesc('shipToId', 'id', false);
       sDescription.addInputParameterDesc('obsId', 'id', false);
       
       // Add output parameters
       sDescription.addOutputParameterDesc('responseBack', 'string');
    }

    // Runtime service invocation    
    global ce4sf20_001.AeServiceResponse invoke(ce4sf20_001.AeServiceRequest aRequest) {
       
       // get a map of name/value pairs from request
       Map<String,Object> params = aRequest.getTypedParameterMap(sDescription.getInputParameterMap());
       // get all parameters as their native Apex types
       Id opportunityId = (Id) params.get('opportunityId');
       Id acctBySubId = (Id) params.get('acctBySubId');
       Id contractId = (Id) params.get('contractId');
       Id billToId = (Id) params.get('billToId');
       Id shipToId = (Id) params.get('shipToId');
       Id obsId = (Id) params.get('obsId');
       
       // create a response
       ce4sf20_001.AeServiceResponse response = new ce4sf20_001.AeServiceResponse();
       if(opportunityId == null || acctBySubId == null || billToId == null || shipToId == null || contractId == null || obsId == null){
            response.addErrorInfo('Invalid request. Input values are missing in request.'); 
           	return response;
       } else {
            boolean flag = false;
            String errMassage;
            System.Savepoint sp1 = Database.setSavepoint();

       		try {
       			flag = createBillingProfile(opportunityId, acctBySubId, contractId, billToId, shipToId, obsId);
            } catch(Exception ex) {
                system.debug('exception = ' + ex.getStackTraceString());
                system.debug('exception 1 = ' + ex);
                errMassage = ex.getMessage();
                system.debug('errMassage = ' + errMassage);
                flag = false;
                Database.rollback(sp1);
            }
            if(flag == true){
                response.addParameter('responseBack', 'Billing Profile created successfully');
            } else {
                system.debug('errMassage1 = ' + errMassage);
                response.addParameter('responseBack', 'Billing Profile could not be created due to some errors - ' + errMassage);
            }
       }
       system.debug('response = ' + response);
       return response;
    }

    // Returns service metadata for inclusion in guide designer
    global ce4sf20_001.AeServiceDescription describe() {
       return sDescription;
    }

    private boolean createBillingProfile(Id opportunityId, Id acctBySubId, Id contractId, id billToId, id shipToId, Id obsId){
    	
        Opportunity opportunity = [select id, name, Order_Number__c, StageName, CloseDate, ForecastCategoryName, Customer_PO__c, 
                                    Order_Type__c, PS_FC_Start_Date2__c, OA_Project_Director__c, OA_Project_Manager__c, OwnerId,
                                    Project_Template__c, CurrencyIsoCode, Probability, PS_Forecast_Probability__c, PS_Top_Opportunity__c 
                                    from Opportunity where id = :opportunityId];
        Acct_By_Sub__c acctBySub = [select id, name, Misys_Entity__c, Account__r.NS_Finance_Region__c, Account__r.NS_Currency__c, Account__r.NS_Term__c, 
                                     Account__r.PO_Required__c, Invoice_Delivery_Post__c, Invoice_Delivery_Email__c, NS_Export_to_Openair__c,
                                     Account__r.Credit_Controller__c, NS_Invoice_Translation__c, NS_Invoice_Translation_Language__c,
                                     NS_Invoice_Translation_Language_Code__c
                                    from Acct_By_Sub__c where id = :acctBySubId];
        Contract contract = [select id, StartDate, CustomerSignedDate, Sales_Order_Type__c, Memo__c, AccountId, Contract_Expiry_Date__c 
        						from Contract where Id = :contractId];
        NS_Currency__c nsCurrency = [select id, Name, NS_Currency_Internal_Id__c from NS_Currency__c where Name = :opportunity.CurrencyIsoCode];

		Opportunity_Billing_Schedule__c obs = [select id, name, Key__c, Subscription_Start_Type__c, Subscription_Option__c, Fixed_Billing_Date__c, 
                        Planned_Recurring_Billing_Start_Date__c, RLF_Start_Trigger__c, NS_Subscription_Start_Date__c, Billing_Mode__c,
                        Subscription_Termination_Method__c, Subscription_Term__c, NS_Subscription_Notice_Period__c, NS_Subscription_Minimum_Term__c,
                        NS_Subscription_Co_term__c, Rating_Frequency__c, Billing_Frequency__c, Billing_Method__c 
                        from Opportunity_Billing_Schedule__c where id = :obsId];
                        
        list<NS_Charge_Type__c> chargeType = [select id from NS_Charge_Type__c where Name = 'Recurring Service'];
                        
        system.debug('opportunity = ' + opportunity);
        system.debug('acctBySub = ' + acctBySub);
        system.debug('nsCurrency = ' + nsCurrency);
        system.debug('contract = ' + contract);
        
        Billing_Group__c billingGroup = new Billing_Group__c();
        billingGroup.BG_Client_Contracting_Name__c = contract.AccountId;
        billingGroup.Account_by_Sub__c = acctBySubId;
        billingGroup.Original_Opportunity__c = opportunityId;
        billingGroup.CurrencyIsoCode = opportunity.CurrencyIsoCode;
        billingGroup.Original_Contract__c = contractId;
        billingGroup.Current_Sales_Order_Start_Date__c = contract.StartDate;
        billingGroup.NS_Subscription_Start_Date__c = obs.NS_Subscription_Start_Date__c;
        billingGroup.NS_Subscription_Memo__c = contract.Memo__c;
        billingGroup.NS_Subscription_Start_Type__c = obs.Subscription_Start_Type__c;
        billingGroup.NS_Subscription_Option__c = obs.Subscription_Option__c;
        billingGroup.NS_Billing_Mode__c = obs.Billing_Mode__c;
        billingGroup.NS_Termination_Method__c = obs.Subscription_Termination_Method__c;
        billingGroup.Fixed_Billing_Date__c = obs.Fixed_Billing_Date__c;
        billingGroup.NS_Subscription_Term__c = obs.Subscription_Term__c;
        billingGroup.NS_Subscription_Notice_Period__c = obs.NS_Subscription_Notice_Period__c;
        billingGroup.NS_Subscription_Minimum_Term__c = obs.NS_Subscription_Minimum_Term__c;
        billingGroup.NS_Subscription_Co_term__c = obs.NS_Subscription_Co_term__c;
        billingGroup.NS_Rating_Frequency_Billing_Period__c = obs.Rating_Frequency__c;
        billingGroup.NS_Billing_Frequency__c = obs.Billing_Frequency__c;
        billingGroup.NS_Subscription_Billing_Method__c = obs.Billing_Method__c;
        billingGroup.BG_Misys_Billing_Entity__c = acctBySub.Misys_Entity__c;
        billingGroup.BG_Client_Bill_To__c = billToId;
        billingGroup.BG_Client_Ship_To__c = shipToId;
        billingGroup.BG_Billing_Group_Active__c = true;
        billingGroup.BG_Data_Status__c = 'BGWiz Created';
        billingGroup.Original_Contract_Expiry_Date__c = contract.Contract_Expiry_Date__c;
        if(chargeType != null && chargeType.size() > 0){
        	billingGroup.NS_Subscription_Charge_Type__c = chargeType[0].Id;
        }
        
        insert billingGroup;
        
        /*
        string startType = 'On Particular Date';
        if(obs.Subscription_Start_Type__c == 'on start date'){
        	startType = 'Immediate';
        }
        */
        string startType = obs.RLF_Start_Trigger__c;
        list<BGCA_Junction__c> bgcaList = new list<BGCA_Junction__c>();
        for(Contract_Asset__c ca : [select id, OpportunityLineItem__c from Contract_Asset__c where Contract__c = :contractId]){
        	bgcaList.add(new BGCA_Junction__c(Billing_Group__c = billingGroup.Id, Contract_Asset__c = ca.Id, OpportunityLineItem__c = ca.OpportunityLineItem__c,
        					Asset_Maintenance_Status__c = 'On Maintenance', CA_Billing_Status__c = 'Active billing', 
        					NS_Subscription_Item_Start_Type__c = startType, Contract_Asset_Status__c = 'Validated'));
        }
        
        system.debug('bgcaList = ' + bgcaList);
        if(bgcaList != null && bgcaList.size() > 0){
        	insert bgcaList;
        }
        
    	return true;
    }
}
/*

       ce4sf20_001.AeServiceRequest request = new ce4sf20_001.AeServiceRequest();
       request.objectId = '123456789';
       request.objectType = 'TestObject';
       request.addParameter('opportunityId', '0062000000ZiRVg');
       request.addParameter('acctBySubId', 'a2520000000QWzn');
       request.addParameter('contractId', '80020000005RJi9');
       request.addParameter('billToId', 'a3720000000H1S4');
       request.addParameter('shipToId', 'a3720000000H1S4');
       request.addParameter('obsId', 'a3J20000000LV6u');
    
       // invoke the service
       ce4sf20_001.IAeAutomatedStepService service = new ce4sfStep_CreateBillingProfile();
       ce4sf20_001.AeServiceResponse response = service.invoke(request);
       system.debug('response = ' + response);

*/