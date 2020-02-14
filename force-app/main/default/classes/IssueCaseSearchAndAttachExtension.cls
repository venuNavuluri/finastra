public with sharing class IssueCaseSearchAndAttachExtension {
    /////////////////////////////////////////////////////
    // Saaspoint 10/Aug/2009
    //
    // ALM Project. Controller Extension class for IssueCaseSearchAndAttach page
    //
    // Modification History:
    // who    mm/dd/yyyy     description
    //
    /////////////////////////////////////////////////////
          
	// The Case being controlled
	public Case customerCase              {get;private set;}
	
	// Search criteria fields
	public Case   issueCaseCriteria       {get; set;}	
	public String issueCaseKeyword        {get; set;}
	public String issueCaseNumber         {get; set;}
	
	// List of Issue Cases returned
	public List<CaseWrapper> allissueCases {get; set;}
	
	public String query                   {get; set;}
	public Boolean noResultsFound         {get; set;} {noResultsFound=false;}
	public Boolean displayResults         {get; set;} {displayResults=false;}
	public Boolean alreadyAttached        {get; set;} {alreadyAttached=false;}
	
	public Boolean showOverrideButton	  {get; set;} {showOverrideButton=true;}
	public Boolean showAttachButton		  {get; set;} {showAttachButton=true;}
	
	// Constructor - get the customer case and issue case ID
	public IssueCaseSearchAndAttachExtension (ApexPages.StandardController stdController) {
	    
	    this.customerCase       = (Case)stdController.getRecord();
	    
	    try {
	      this.customerCase       = [SELECT id, issue_case__c, CC_TR_Status__c,Linked_TR__c, TR_Client_Specific__c  FROM case WHERE id = :this.customerCase.id];
	    } catch (QueryException e) {
		  //Since no case is found, disable the ability to attach the Issue case to the customer case. 
	      showAttachButton = false;
	    }
	    
	    this.issueCaseCriteria  = new Case();
	    alreadyAttached         = this.customerCase.issue_case__c != null;
	    
	    if(alreadyAttached && this.customerCase.Linked_TR__c != null)  //((this.customerCase.CC_TR_Status__c != 'Closed' || this.customerCase.Linked_TR__c != '') && this.customerCase.TR_Client_Specific__c != ''))
	    	showOverrideButton = false;
	
	}
  
    public PageReference doOverride() {
      alreadyAttached = false;
      return null;	
    }
  
    public PageReference doCancel() {
      return goOriginalCase();
    }
    
    private PageReference goOriginalCase() {
       String strPage;
       if(customerCase.id == null){
          //Main Case page
          strPage = '500';
       }else{
       	  strPage = customerCase.id;
       }
       return new PageReference('/' + strPage);    	
    }
    
    public PageReference doSearch() {

      // Builds a search using either SOQL or SOSL depending on whether a keyword is included
        
        noResultsFound          = false;
        displayResults          = false;
	    this.allIssueCases      = new List<CaseWrapper>();
	    
        String selectList       = ' id, caseNumber, subject, status, self_service_Product__c, case_category__c, createdDate, owner.name, ownerid, csfe_parent_status__c, product_version__c, client_count__c, call_count__c ';
        String whereClause      = ' recordTypeID = \'' + label.issue_case_id + '\' ';
        String orderBy          = ' caseNumber ASC ';
        
        if (issueCaseNumber != null && issueCaseNumber != '') {
          whereClause += ' AND caseNumber LIKE \'%' + issueCaseNumber + '%\' ';	
        }
            	
        if (issueCaseCriteria.Status != null && issueCaseCriteria.Status != '') {
          whereClause += ' AND status = \'' + issueCaseCriteria.status + '\' ';	
        }    	
        
        if (issueCaseCriteria.self_service_Product__c != null && issueCaseCriteria.self_service_Product__c != '') {
          whereClause += ' AND self_service_Product__c = \'' + issueCaseCriteria.self_service_Product__c + '\' ';	
        }    	

        if (issueCaseCriteria.case_category__c != null && issueCaseCriteria.case_category__c != '') {
          whereClause += ' AND case_category__c = \'' + issueCaseCriteria.case_category__c + '\' ';	
        }    	

        List<Case> casesFound;
        
        if (issueCaseKeyword != null && issueCaseKeyword != '') {
          query = 'FIND \'' + issueCaseKeyword.replaceAll('[^a-zA-Z0-9 ]','*') + '\' IN ALL FIELDS RETURNING Case(' + selectList + ' WHERE ' + whereClause + ' ORDER BY ' + orderBy + ' )'; 
          List<List<SObject>>searchList = search.query(query);      
          casesFound = (List<Case>)searchList[0];
        } else {
          // Collection cannot handle any more so limit to 1000	  
          query = ' SELECT ' + selectList + ' FROM case WHERE ' + whereClause + ' ORDER BY ' + orderBy + ' LIMIT 750 '; 
          casesFound = Database.query(query);
        }

        // EXECUTE THE QUERY

        for (Case c : casesFound) {
        	allIssueCases.add(new CaseWrapper(c));
        	displayResults = true;
        }
        if (allIssueCases.size() == 1) {
            allIssueCases[0].selected = true;	
        }
        noResultsFound = !displayResults;
      
        return null;
    
    }  

    // Handles attaching the Issue Case to the Customer Case
    public pageReference doAttach() {
      ID issueCaseID = null;
      Integer iCount = 0;
      for (CaseWrapper c : allIssueCases) {
      	if (c.selected) {
      	  issueCaseID = c.internalCase.id;
      	  iCount++;	
      	}
      }
      //JRB: Added error handling to be sure one and only one case is selected to attach
      if(issueCaseID == null || iCount > 1){
      	ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid selection - please select one Issue case to attach.');
		ApexPages.addMessage(errMsg);
		return null;
      }else{
      	customerCase.Issue_Case__c = issueCaseID;
      	update customerCase;
      	return goOriginalCase();
      }
    }

    /////////////////////////////////////////////////////////////////////////////
    // PICKLIST SECTION
    // It is not currently possible to filter the picklist based on record type
    //
    //
    /////////////////////////////////////////////////////////////////////////////
    
    public List<SelectOption> getIssueCaseProducts() {

    	List<SelectOption> options = new List<SelectOption>();
    	String showAll = Label.show_all; 
        options.add(new SelectOption('', showAll));

//        At this time, cannot read picklist values based on Issue record type, so we will read the values from a system parameter
//        Schema.DescribeFieldResult f = Case.Select_a_Product__c.getDescribe();
//        for(Schema.Picklistentry plValue : f.getPicklistValues()) {

        String issueProducts = ALM_System_Parameters.getParam('Picklist_Self_Service_Product__c');
        if (issueProducts != null) {
          for (String oneProduct : issueProducts.split(',')) {	
            options.add(new SelectOption(oneProduct.trim(), oneProduct.trim()) );
          }
        }
        
        return options;
    }

    public List<SelectOption> getIssueCaseStatus() {

    	List<SelectOption> options = new List<SelectOption>();
    	String showAll = Label.show_all;
        options.add(new SelectOption('', showAll));

//        At this time, cannot read picklist values based on Issue record type, so we will read the values from a system parameter
//        Schema.DescribeFieldResult f = Case.Status.getDescribe();
//        for(Schema.Picklistentry plValue : f.getPicklistValues()) {

        String issueStatuses = ALM_System_Parameters.getParam('Picklist_Status');
        if (issueStatuses != null) {
          for (String oneStatus : issueStatuses.split(',')) {	
            options.add(new SelectOption(oneStatus.trim(), oneStatus.trim()) );
          }
        }
        return options;
    }

    public List<SelectOption> getIssueCaseCategories() {
    	
    	List<SelectOption> options = new List<SelectOption>();
    	String showAll = Label.show_all;
        options.add(new SelectOption('', showAll));

        String issueStatuses = ALM_System_Parameters.getParam('Picklist_Case_Category__c');
        if (issueStatuses != null) {
          for (String oneStatus : issueStatuses.split(',')) {	
            options.add(new SelectOption(oneStatus.trim(), oneStatus.trim()) );
          }
        }
        return options;

    }

}