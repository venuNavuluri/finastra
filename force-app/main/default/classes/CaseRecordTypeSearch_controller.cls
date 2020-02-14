public with sharing class CaseRecordTypeSearch_controller {
    
	Boolean CheckSection=False;
  	private String queryStr {get;set;}				//the soql without the order and limit
  	//public List<Case> lSearchResult {get;set;}		//the collection of cases to display	
	List<Case> lSearchResult = new List<Case>(); 
	//Boolean isDetail = false;
	List<Case> data = new List<Case>();
	Integer DEFAULT_NUMBER_OF_RECORDS_PER_PAGE = 1;
	public PageManager objPageManager {get;set;}
	List<RecordType> lRecType = new List<RecordType>();
  	public String valueSel;
  	public String cStatus; 
  	public Id CurrentUserContactId;
  	List<SelectOption> optionsRecValues = new List<SelectOption>();
  	List<SelectOption> optionsItems = new List<SelectOption>();
  	Boolean isLogged = false;
  	   
    public List<SelectOption> getRecValues() {
    	if(optionsRecValues.size() == 0){
    		//List<SelectOption> optionsRecValues = new List<SelectOption>();
        	Set<String> sCaseRectype = new Set<String>();
        	sCaseRectype.addAll(Label.CaseRecordTypeSearch_RecTypeExclusions.split(','));
        	lRecType = [Select SobjectType, Name, IsActive From RecordType r where SobjectType = 'Case' AND IsActive= True AND Name NOT IN :sCaseRectype order by Name];  
        	optionsRecValues.add(new SelectOption('All','All Products'));
        	for(RecordType r1 : lRecType)
        	{
        		optionsRecValues.add(new SelectOption(r1.name,r1.name));
        	}  
    	}
        return optionsRecValues;
    }

    public List<SelectOption> getItems() {
        if(optionsItems.size() == 0){
        	//List<SelectOption> optionsItems = new List<SelectOption>();
        	optionsItems.add(new SelectOption('None','All Cases'));
        	optionsItems.add(new SelectOption('All Open Cases','All Open Cases'));
        	optionsItems.add(new SelectOption('All Closed Cases','All Closed Cases'));
      		//  options.add(new SelectOption('All Cases','All Cases'));
        	optionsItems.add(new SelectOption('All My Cases','All My Cases'));
        	optionsItems.add(new SelectOption('My Open Cases','My Open Cases'));
        	optionsItems.add(new SelectOption('My Closed Cases','My Closed Cases'));
        }
        return optionsItems;
    }
     
    public String getcStatus(){
        return cStatus;
    }
 
    public void setcStatus(String cStatus){
        this.cStatus = cStatus;
    }
       
    public String getvalueSel(){
        return valueSel;
    }
                        
    public void setvalueSel(String valueSel){
        this.valueSel = valueSel;
        System.debug('value fetched' + valueSel);
    }
 
	//Current sort direction - defaults to asc
  	public String sortDir {
    	get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
    	set;
  	}
 
  	//Current field to sort by - defaults to case number
  	public String sortField {
    	get  { if (sortField == null) {sortField = 'casenumber'; } return sortField;  }
    	set;
  	}
    
    public CaseRecordTypeSearch_controller()
    {
        DEFAULT_NUMBER_OF_RECORDS_PER_PAGE = Integer.valueOf(Label.CaseRecordTypeSearch_const);
        objPageManager = new PageManager(DEFAULT_NUMBER_OF_RECORDS_PER_PAGE);
        cStatus = 'None';
        CurrentUserContactId = getCurrentUserContactId();       
    }
    
    public Boolean getCheckSection() 
    {   
        return CheckSection;
    }
    public void setCheckSection(Boolean s)
    {
        CheckSection = s;
    }        
    
    public Id getCurrentUserContactId()
    {
    	Id contactId;
    	User u = [select Id, ContactId from User where Id = :Userinfo.getUserid() Limit 1];
    	contactId = u.ContactId;
    	return contactId;
    }
    
    //Runs the query to get the data for the records on the current page
    public List<Case> getSearchRecords() 
    {
        Set<Id> sCasesOnPage = new Set<Id>();
   
        for(integer i = objPageManager.startIndex; i < objPageManager.endIndex && i < lSearchResult.size(); i++)
        {               
           sCasesOnPage.add(lSearchResult[i].Id);
        }       
        System.debug('>>>>>>>>>>>>>sCasesOnPage Ids: ' + sCasesOnPage);
        
        data = new List<Case>();
        String fullQueryString = 'Select RecordTypeId, Self_Service_Product__c, Client_Reference__c, Status, Account.Name, '
                    + 'System_ID__c, Subject, Priority, CreatedDate, Id, CaseNumber, Contact.Name, Account.Site ' 
                    + 'From Case where Id in :sCasesOnPage order by ' + sortField + ' ' + sortDir + ' nulls last';
        data = Database.query(fullQueryString);	
        System.debug('>>>>>>>>>>>>>Data List Value' + data);
        return data;
    }

  	//Runs the query to get the total record counts
  	public void runQuery() {
        system.debug('Nitin---------->'+queryStr);
    	try {
      		lSearchResult = Database.query(queryStr + ' order by ' + sortField + ' ' + sortDir + ' nulls last');
    	} catch (Exception e) {
      		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Search resulted in an error: ' + e.getMessage()));
      		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Search resulted in an error.  Please contact customer support.'));
      		system.debug('Error logged:  '+ e.getMessage());
    	}
        System.debug('list of records' + lSearchResult);     
        objPageManager.page = 0;         
        if(lSearchResult.size() < 1)
            objPageManager.numberOfRows = lSearchResult.size();
        else
            objPageManager.numberOfRows = lSearchResult.size();
        
        //Log the use of this function to the Process Logs table for tracking
        if(!isLogged){
        	try{
   				CommonFunctions.addProcessLog('Case', 'Portal Case Record Type Search', 'Visualforce');
   				isLogged = true;
   			}catch(Exception e){
   				System.debug('Error adding Process Log: '+e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
   			}
        }
  	}
    
    public PageReference find1()
    { 
        String recIds=''; 
        String CaseIds='';    
        CheckSection = true;
        Id userid =Userinfo.getUserid();  //'005200000018bNM';
        
        if(valueSel != 'All')
        {
        recIds+='\''+ [Select id from RecordType where SobjectType='Case' and Name =: valueSel].Id +'\'';
        }
        else if(valueSel == 'All')
        {
           for(RecordType rt : lRecType)
               recIds+='\''+rt.id+'\' ,';
           recIds=recIds.substring(0,recIds.length()-1); 
        }
        
        queryStr = 'Select Id From Case ';

        if(cStatus == 'All Closed Cases')
        {           
            queryStr += 'where RecordTypeId IN (' + recIds + ') AND IsClosed = True';
        }
        else if(cStatus == 'All Open Cases')
        {
            queryStr += 'where RecordTypeId IN (' + recIds+ ')  AND IsClosed = False ';
        }
        else if(cStatus == 'None')
        {
            queryStr += 'where RecordTypeId IN (' + recIds+ ')';
        }
        else if(cStatus == 'My Closed Cases')
        {
            queryStr += 'where RecordTypeId IN (' + recIds+ ') AND IsClosed= True AND ContactId=\'' + CurrentUserContactId + '\'';
        }
        else if(cStatus == 'My Open Cases')
        {
            queryStr += 'where RecordTypeId IN (' + recIds+ ') AND IsClosed= False AND ContactId=\'' + CurrentUserContactId + '\'';
        }
        else if(cStatus == 'All My Cases')
        {
            queryStr += 'where RecordTypeId IN (' + recIds + ') AND ContactId=\'' + CurrentUserContactId + '\'';
        }

       	runQuery();        
        return null;
    }
    
  	//Toggles the sorting of query from asc<-->desc
  	public void toggleSort() {
    	// simply toggle the direction
    	sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
    	// run the query again
    	runQuery();
  	}    
                 
}