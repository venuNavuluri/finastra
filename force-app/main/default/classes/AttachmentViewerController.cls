public class AttachmentViewerController {

	//Currently, this page only loads attachments DIRECTLY related to the object it is called from.
	//For example, for an Account, it only shows attachments directly related to the Account and not ones related to a case or contact on the account	

	List<Attachment> listAttachments = new List<Attachment>();
	List<SelectOption> optionsFileTypes = new List<SelectOption>();
	List<SelectOption> optionsDateRanges = new List<SelectOption>();
	private String queryStr {get;set;}				//the soql without the order and limit
	public String strParentId {get; set;}
	public String strParentObject {get; set;}
	public String strParentName {get; set;}
	public String strParentNameField;
	public String selDateRange;
	public String selFileType;
	Boolean isLogged = true;

	public AttachmentViewerController()
	{
		strParentId = System.currentPageReference().getParameters().get('ParentId');
		findParentObjectInfo();
		system.debug('sObjectType based on Id: '+strParentObject);
		system.debug('sObject Name Field based on Id: '+strParentName);
		String sSOQL = 'select ' + strParentNameField + ' from ' + strParentObject + ' where Id = \'' + strParentId + '\' LIMIT 1';
		try{
			sObject parentRec = Database.query(sSOQL);
			Object parentRecNameValue = parentRec.get(strParentNameField);
			strParentName = parentRecNameValue + '';
		}catch (Exception e){
			system.debug('XXXXX Error in retrieving Parent record Name: '+e.getMessage());
			strParentName = strParentId;
		}
		selDateRange = 'All';
		selFileType = 'All';
		findAttachments();
		isLogged = false;
	}
	
	public List<Attachment> getListAttachments()
	{
		return listAttachments;
	}

    //****** Options for File Type filter list ******
    public List<SelectOption> getFileTypes() 
    {
    	if(optionsFileTypes.size() == 0){
        	optionsFileTypes.add(new SelectOption('All','All File Types'));
        	optionsFileTypes.add(new SelectOption('Excel','Excel'));
        	optionsFileTypes.add(new SelectOption('Image','Image'));
        	optionsFileTypes.add(new SelectOption('PDF','PDF'));
        	optionsFileTypes.add(new SelectOption('PowerPoint','PowerPoint'));
        	optionsFileTypes.add(new SelectOption('Text','Text'));
        	optionsFileTypes.add(new SelectOption('Word','Word'));
        	optionsFileTypes.add(new SelectOption('Zip','Zip (Compressed)'));
        	optionsFileTypes.add(new SelectOption('Other','Other (not in list)'));
    	}
        return optionsFileTypes;
    }
    
	//****** Options for Date Created filter list ******
	public List<SelectOption> getDateRangeOptions() 
	{
    	if(optionsDateRanges.size() == 0){
        	optionsDateRanges.add(new SelectOption('All','All'));
        	optionsDateRanges.add(new SelectOption('Last7Days','In Last 7 Days'));
        	optionsDateRanges.add(new SelectOption('Last30Days','In Last 30 Days'));
        	optionsDateRanges.add(new SelectOption('Over30Days','Over 30 Days Ago'));
        	optionsDateRanges.add(new SelectOption('Over90Days','Over 90 Days Ago'));
        	optionsDateRanges.add(new SelectOption('Over6Months','Over 6 Months Ago'));
        	optionsDateRanges.add(new SelectOption('Over12Months','Over 12 Months Ago'));
        }
        return optionsDateRanges;
    }

    public String getselDateRange(){
        return selDateRange;
    }
 
    public void setselDateRange(String selDateRange){
        this.selDateRange = selDateRange;
    }
       
    public String getselFileType(){
        return selFileType;
    }
                        
    public void setselFileType(String selFileType){
        this.selFileType = selFileType;
        System.debug('value fetched' + selFileType);
    }

	//Current sort direction - defaults to asc
  	public String sortDir {
    	get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
    	set;
  	}
 
  	//Current field to sort by - defaults to case number
  	public String sortField {
    	get  { if (sortField == null) {sortField = 'Name'; } return sortField;  }
    	set;
  	}

  	//Toggles the sorting of query from asc<-->desc
  	public void toggleSort() {
    	// simply toggle the direction
    	sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
    	// run the query again
    	runQuery();
  	}  
	
    public PageReference findAttachments()
    {         
        queryStr = 'select Id, CreatedDate, Name, BodyLength, OwnerId, LastModifiedDate, ContentType from Attachment where ParentId = :strParentId';

		//Build the date range criteria string
        if(selDateRange != 'All')
        {           
            if(selDateRange == 'Last7Days')
            {
            	queryStr += ' and CreatedDate = LAST_N_DAYS:7';
            }
            else if(selDateRange == 'Last30Days')
            {
            	queryStr += ' and CreatedDate = LAST_N_DAYS:30';
            }
            else if(selDateRange == 'Over30Days')
            {
            	queryStr += ' and CreatedDate < LAST_N_DAYS:30';
            }
            else if(selDateRange == 'Over90Days')
            {
            	queryStr += ' and CreatedDate < LAST_N_DAYS:90';
            }
            else if(selDateRange == 'Over6Months')
            {
            	queryStr += ' and CreatedDate < LAST_N_DAYS:180';
            }
            else if(selDateRange == 'Over12Months')
            {
            	queryStr += ' and CreatedDate < LAST_N_DAYS:365';
            }
        }
        
        //Build the file type criteria string
        if(selFileType != 'All')
        {
        	if(selFileType == 'Word')
        	{
        		queryStr += ' and (ContentType like \'%msword%\' or ContentType like \'%wordprocess%\' or ContentType like \'%rtf%\' or Name like \'%.doc%\')'; 
        	}
        	else if(selFileType == 'Excel')
        	{
        		queryStr += ' and (ContentType like \'%excel%\' or ContentType like \'%spreadsheet%\' or Name like \'%.xls%\')';
        	}
        	else if(selFileType == 'PowerPoint')
        	{
        		queryStr += ' and (ContentType like \'%powerpoint%\' or ContentType like \'%presentation%\' or Name like \'%.ppt%\')';
        	}
        	else if(selFileType == 'Image')
        	{
        		queryStr += ' and (ContentType like \'%image%\')';
        	}
        	else if(selFileType == 'PDF')
        	{
        		queryStr += ' and (ContentType like \'%PDF%\' or Name like \'%.pdf%\')';
        	}
        	else if(selFileType == 'Text')
        	{
        		queryStr += ' and (ContentType like \'%text%\' or ContentType like \'%csv%\' or Name like \'%.txt%\' or Name like \'%.csv%\')';
        	}
        	else if(selFileType == 'Zip')
        	{
        		queryStr += ' and (ContentType like \'%zip%\' or ContentType like \'%-rar%\' or ContentType like \'%-tar%\' or Name like \'%.zip%\'  or Name like \'%.rar%\' or Name like \'%.tar%\')';
        	}
        	else 
        	{
        		//Select any other value in ContentType that is blank or not covered above
        		//queryStr += ' and (ContentType = null or (NOT(' +
        		queryStr += ' and ((NOT(' +
        			'ContentType like \'%msword%\' or ContentType like \'%wordprocess%\' or ContentType like \'%rtf%\' or Name like \'%.doc%\' or ' +	//Word
        			'ContentType like \'%excel%\' or ContentType like \'%spreadsheet%\' or Name like \'%.xls%\' or ' +									//Excel
        			'ContentType like \'%powerpoint%\' or ContentType like \'%presentation%\' or Name like \'%.ppt%\' or ' +							//PowerPoint
        			'ContentType like \'%image%\' or ' +																								//Image
        			'ContentType like \'%PDF%\' or Name like \'%.pdf%\' or ' + 																			//PDF
        			'ContentType like \'%text%\' or ContentType like \'%csv%\' or Name like \'%.txt%\' or Name like \'%.csv%\' or ' +					//Text
        			'ContentType like \'%zip%\' or ContentType like \'%-rar%\' or ContentType like \'%-tar%\' or Name like \'%.zip%\' or Name like \'%.rar%\' or Name like \'%.tar%\'' +	//Zip
        			')))';
        	}
        }
        
       	runQuery();        
        return null;
    }	
    
    //Runs the query to get the total record counts
  	public void runQuery() {
        system.debug('runQuery queryStr---------->'+queryStr);
    	try {
      		listAttachments = Database.query(queryStr + ' order by ' + sortField + ' ' + sortDir + ' nulls last');
    	} catch (Exception e) {
      		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Search resulted in an error.  Please contact customer support.'));
      		system.debug('Error logged:  '+ e.getMessage());
    	}
        System.debug('list of records' + listAttachments);  
        
        //add a log record to the ProcessLog
        logRun();
  	}
  	
  	public void findParentObjectInfo()
  	{
  		//Code based on example in http://corycowgill.blogspot.com/2011/01/building-dynamic-soql-select-all-query.html 
  		
  		//Retrieve all sObject describe results
  		Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
  		
  		List<Schema.SObjectType> sobjects = schemaMap.values();
        Schema.DescribeSObjectResult objDescribe;
        String objectName = '';
        String objectNameField = '';
        for(Schema.SObjectType objType : sobjects)
        {
            if(objectName == '')
            {
            	objDescribe = objType.getDescribe();
            	String sobjectPrefix = objDescribe.getKeyPrefix();
            	if(strParentId != null && sobjectPrefix != null && strParentId.startsWith(sobjectPrefix))
            	{
	                objectName = objDescribe.getLocalName();
	                Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
	                for(Schema.SObjectField sof : fieldMap.values())
	                {
	                    system.debug('objectNameField = '+objectNameField);
	                    if(objectNameField == '')
	                    {
	                    	Schema.DescribeFieldResult f = sof.getDescribe();
	                    	if(f.isNameField())
	                    		objectNameField = f.getName();
	                    }
	                }           
            	}
            }
        }
        strParentObject = objectName;
        strParentNameField = objectNameField;
  	}

	public void logRun()
	{
        //Log the use of this function to the Process Logs table for tracking
        if(!isLogged){
        	try{
   				CommonFunctions.addProcessLog('Attachment', 'Attachment Viewer', 'Visualforce');
   				isLogged = true;
   			}catch(Exception e){
   				System.debug('Error adding Process Log: '+e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
   			}
        }
	}
}