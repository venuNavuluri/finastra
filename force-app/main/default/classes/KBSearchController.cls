public with sharing class KBSearchController {
	
	static final integer numCategoryLevels = integer.valueOf(Label.KBSearch_CategoryLevels);
	static final Id baseCategoryId = null;  
	
	public string searchANY {get; set;}
	public string searchALL {get; set;}
	public string searchPHRASE {get; set;}
	public string searchNOT {get; set;}

	public list<ArticleTypes> lArticleTypes { get; set; }
	set<Id> selectedArticleTypes = new set<Id>();
	set<Id> UNselectedArticleTypes = new set<Id>();
	list<CategoryList> lCategories;
	string selectedCategoryId;

	list<Id> lBaseCategories;
	map<Id,set<Id>> mapCategoryParentToChildren;
	map<Id,RecordType> mapArticleType;
	public SessionInfo sessionInfo;
	map<Id,CategoryNode> mapCategoryNode;
	
	public Boolean enableSearchFields {get; set;}
	public Boolean showResults {get; set;}
	public Boolean showFilters {get; set;} 
	public Boolean isLogged = false;
	public Boolean searchTextBlank = false;

	public string defaultSelectList {
		get {return '(Select Parent Category)';}
		set;
	}
	
	/******************************* Wrapper Classes **************************************/
	
	//Wrapper class for Article Type Filters
	public class ArticleTypes {
		public String Item {get; set;}
		public Id ItemId {get; set;}
		public Boolean Selected {get; set;}
		
		public ArticleTypes(){
			selected = false;
		}
	}
	
	//Wrapper class for Category filters
	public class CategoryList {
		public String itemLabel {get; set;}
		public Id itemId {get; set;}
		//public string itemName {get; set;}
		public boolean showSelectList {get; set;}
		public integer level {get; set;}
		//public string indent {get; set;}
		public list<SelectOption> choices {get; set;}
	}

	/******************************** End Wrapper Classes **********************************/


	public KBSearchController(){
		
		//Display all screen panels
		enableSearchFields = true;
		showFilters = true;
		showResults = false;
		//includeArchived = false;
		
        sessionInfo = new SessionInfo();
        lArticleTypes = new list<ArticleTypes>();
        //listSearchResults = new list<Solution>();
 
        //Get the solution article type info
        mapArticleType = new map<Id,RecordType>([select Id, Name from RecordType where sObjectType = 'Solution' and isActive = true]);
        
        //Get the Category info
        buildCategoryMaps();
        //mapCategorySelectOptions = new map<integer,CategoryList>();
        lCategories = new CategoryList[numCategoryLevels+1];
        system.debug('KBSearchController. - lCategories : '+lCategories);
        
        //Set the initial filter values
        initFilters();
	}	
	
	public KBSearchController(list<string> searchCriteria, list<string> articleNames, list<string> articleSelects, list<string> catIds)
	{
		//Instantiation method used with Javascript Remoting.  This sets up all the necessary data so it can be accessed as needed.
		
		//Set Search Criteria
		searchALL = searchCriteria[0];
		searchANY = searchCriteria[1];
		searchPHRASE = searchCriteria[2];
		searchNOT = searchCriteria[3];
		
		//Set Article Types
		lArticleTypes = new list<ArticleTypes>();
		system.debug('KBSearchController.assignArticleTypes - articleNames: '+articleNames);
		system.debug('KBSearchController.assignArticleTypes - articleSelects: '+articleSelects);
		
		//Retrieve the Ids for the records
		list<RecordType> rts = [select Id,Name from RecordType where sObjectType='Solution' and Name in :articleNames];
		
		for(integer x=0;x<articleNames.size();x++)
		{	
			ArticleTypes a = new ArticleTypes();
			a.Item = articleNames[x];
			a.Selected = articleSelects[x] == 'true';
			for(RecordType r : rts){
				if(r.Name == a.Item){		//Update the record type id since this was not part of the data structure on the main form
					a.itemId = r.Id;
				}
			}
			lArticleTypes.add(a);
		}
		system.debug('KBSearchController.assignArticleTypes - lArticleTypes: '+lArticleTypes);
		
		//Set Categories
		string selection = null;
		system.debug('KBSearchController.assignCategories - catIds: '+catIds);
		//result is that the lowest level category id will be set as the selected id
		if(catIds.size() >0 )
		{
			for(string i : catIds)
			{
				try{
					if(i == null || i == ''){
						break;
					}else{
						selection = i;
					}
				}catch(Exception e){
					selection = null;
					break;
				}
			}
		}else{
			selection = null;
		}
		
		if(selection != null && selection.length()==18){
			selectedCategoryId = selection.left(15);
		}
		system.debug('KBSearchController.assignCategories - selectedCategoryId: '+selectedCategoryId);	
	}
	
	@RemoteAction public static string runSearchCases(list<string> searchCriteria, list<string> articleNames, list<string> articleSelects, list<string> catIds)
	{
		string strResult;
		
		//Initialize the controller with all necessary data
		KBSearchController kb = new KBSearchController(searchCriteria,articleNames,articleSelects,catIds);
		
		//Get the url for the search results window, in string format
		strResult = kb.SearchCases2();
		
		return strResult;
	}
	
	public string SearchCases2()
	{
		boolean noErrors = true;
		//pgSearchResult = null;
		string pgURL;
		
		//Build the list of selected and unselected article/record types 
		getArticleTypeSelections();
		
		//Get the text to be used as search criteria
		string searchSolutionText = getSearchText();
		
		//Verify search criteria variables contain some data
		if((searchALL == null || searchALL == '') && (searchANY == null || searchANY == '') && (searchPHRASE == null || searchPHRASE == '') && (searchNOT == null || searchNOT == '')){
			searchSolutionText = null;
			noErrors = false;
		}
		
		//Verify at least one article type has been selected
		if(selectedArticleTypes.size() == 0){
			noErrors = false;
		}
		
		if(noErrors)
		{					
			pgURL = Label.KBSearch_URL;
			
			pgURL = pgURL + '?t=4';
			pgURL = pgURL + ';searchtype=C';
			
			if(searchSolutionText != null){
				pgURL = pgURL + ';search=' + searchSolutionText;
			}
			
			string catId = selectedCategoryId;
			if(catId != null){
				pgURL = pgURL + ';cid=' + catId;
			}
			
			pgURL = pgURL + ';go=Find+Solution';
			
			system.debug('KBSearchController.SearchCases2 - pgURL : '+pgURL);
			
			
			//Log the use of this function to the Process Logs table for tracking
	        if(!isLogged){
	        	try{
	   				CommonFunctions.addProcessLog('Solution', 'KBase Custom Search', 'Visualforce');
	   				isLogged = true;
	   			}catch(Exception e){
	   				System.debug('Error adding Process Log: '+e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
	   			}
	        }
		}
		
		return pgURL;
	}

	public PageReference validateForm()
	{
		//Build the list of selected and unselected article/record types 
		getArticleTypeSelections();
		
		//Get the text to be used as search criteria
		string searchSolutionText = getSearchText();
		
		boolean hasError = false;
		
		//Check for missing search critiera
		if(searchTextBlank){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Please enter text in at least one of the search boxes.'));
			hasError = true;
		}
		
		//Check that at least one Article Type is selected
		if(selectedArticleTypes.size() == 0){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Please select at least one Article Type to include.'));
			hasError = true;
		}
		
		//If no error above, some other error has occurred...
		//if(hasError == false){
		//	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'An error occurred while processing search results.  Please try again or contact your administrator if the problem persists.'));
		//}
		
		return null;
	}
	
	public PageReference ClearSearch()
	{
		searchALL = '';
		searchANY = '';
		searchPHRASE = '';
		searchNOT = '';
		
		enableSearchFields = true;
		showFilters = true;
		showResults = false;
		
		return null;
	}
	
	public PageReference ResetFilters()
	{
	    initFilters();
    
		return null;
	}

	public void initFilters()
	{
		//Build the initial article type list
       lArticleTypes = buildArticleTypes();
        system.debug('KBSearchController.KBSearchController lArticleTypes : '+lArticleTypes);
        
        //Build the initial category choice list
        buildCategorySelectLists(baseCategoryId,1);
	}
	
	public void getArticleTypeSelections()
	{
		//Build the lists of selected and un-selected article types for the search filters
		selectedArticleTypes.clear();
		UNselectedArticleTypes.clear();
		
		for(ArticleTypes atx : lArticleTypes)
		{
			if(atx.selected){
				selectedArticleTypes.add(atx.ItemId);
			}else{
				UNselectedArticleTypes.add(atx.ItemId);
			}
		}
		system.debug('KBSearchController.getArticleTypeSelections - selectedArticleTypes: '+selectedArticleTypes);
		system.debug('KBSearchController.getArticleTypeSelections - UNselectedArticleTypes: '+UNselectedArticleTypes);
	}
	
	public list<ArticleTypes> buildArticleTypes()
	{
		list<ArticleTypes> artTypes = new list<ArticleTypes>();
		
		//Create an ArticleType wrapper for each solution RecordType
		for(RecordType rtSolution : mapArticleType.values())
		{
			ArticleTypes a = new ArticleTypes();
			a.item = rtSolution.Name;
			a.itemId = rtSolution.Id;
			artTypes.add(a);
		}
		system.debug('KBSearchController.buildArticleTypes - artTypes: '+artTypes);
		
		return artTypes;		
	}
	
	public list<CategoryList> getlCategories()
	{
		return lCategories;
	}
	
	public void setlCategories(list<CategoryList> cl)
	{
		lCategories = cl;
	}
		
	public void buildCategoryMaps()
	{	
		lBaseCategories = new list<Id>();
		mapCategoryParentToChildren = new map<Id,set<Id>>();
		mapCategoryNode = new map<Id,CategoryNode>();
		
		//Build the maps for Category Parents and Child records
		for(CategoryNode c : [select Id, ParentId, MasterLabel from CategoryNode])
		{
			mapCategoryNode.put(c.Id,c);
			
			//Map of Parent to Child categories
			if(c.ParentId != null){
				if(mapCategoryParentToChildren.keySet().contains(c.ParentId)){
					mapCategoryParentToChildren.get(c.ParentId).add(c.Id);
				}else{
					mapCategoryParentToChildren.put(c.ParentId,new set<Id>{c.Id});
				}
			}else{
				lBaseCategories.add(c.Id);
			}
		}
		system.debug('KBSearchController.buildCategoryFiltersList - mapCategoryParentToChildren: '+mapCategoryParentToChildren);
	}
	
	public void buildCategorySelectLists(Id parentId, integer iLevel)
	{
		//Rebuilds the given level based on the given parentId, and clears option lists below
		system.debug('KBSearchController.buildCategorySelectLists - mapCategoryParentToChildren.get(parentId): '+mapCategoryParentToChildren.get(parentId));
		if(iLevel <= numCategoryLevels)
		{
			//Get the options at the given level, if it exists.  If not, create the level
			CategoryList clx;
			if(lCategories.get(iLevel) != null)
			{
				clx = lCategories.get(iLevel);
			}else{
				clx = new CategoryList();
			}
			clx.itemLabel = 'Level ' + iLevel;
			clx.itemId = null;
			clx.level = iLevel;
			clx.showSelectList = true;
			clx.choices = new list<SelectOption>();
			clx.choices.add(new SelectOption('','(All Subcategories)'));
			set<Id> sChildIds = new set<Id>();
			if(iLevel == 1){
				sChildIds.addAll(lBaseCategories);
			}else{
				sChildIds = mapCategoryParentToChildren.get(parentId);
			}
			if(sChildIds != null){
				for(Id cnx : sChildIds)
				{
					clx.choices.add(new SelectOption(cnx,mapCategoryNode.get(cnx).MasterLabel));
				}
			}
			lCategories.set(iLevel,clx);
			system.debug('KBSearchController.buildCategorySelectLists - lCategories.get(iLevel): '+lCategories.get(iLevel));
			
			//Rebuild or add the child Category levels as blank placeholders
			for(integer x = iLevel+1; x <= numCategoryLevels; x++)
			{
				CategoryList clNew = new CategoryList();
				clNew.itemLabel = 'Level '+ x;
				clNew.itemId = null;
				clNew.level = x;
				clNew.showSelectList = false;
				clNew.choices = new list<SelectOption>();
				lCategories.set(x,clNew);
			}
			system.debug('KBSearchController.buildCategorySelectLists - lCategories: '+lCategories);
		}	
	}
	
	public PageReference selectSubCategoryFilter()
	{
		string sLevel = ApexPages.currentPage().getParameters().get('iLevel');
		integer iLevel = integer.valueOf(sLevel);
		
		Id idCategoryId = this.lCategories.get(iLevel).itemId;
		system.debug('KBSearchController.selectSubCategoryFilter - idCategoryId: '+idCategoryId);
		
		system.debug('KBSearchController.selectSubCategoryFilter - iLevel: '+iLevel);
		
		//Rebuild the child category level and below
		if(idCategoryId == null){
			//If null, rebuild this level
			buildCategorySelectLists(idCategoryId,iLevel);
		}else{
			//If not null, rebuild the next level
			buildCategorySelectLists(idCategoryId,iLevel+1);
		}
		
		//Update the flag to indicate the Category changed
		//bCategoriesChanged = true;
		
		return null;
	}

	public String getSearchText()
	{	
		system.debug('Criteria fields: '+searchALL+' '+searchANY+' '+searchPHRASE+' '+searchNOT);
		
		string searchText = '';
		string allText;
		string anyText;
		string phraseText;
		string notText;
		string articleTypeText;
		boolean bAllText = false;
		boolean bAnyText = false;
		boolean bPhraseText = false;
		boolean bNotText = false;
		
		//Prepare the Text for the ALL search
		allText = getSearchAllString();
		system.debug('KBSearchController.getSearchText - searchALL: '+searchALL);
		system.debug('KBSearchController.getSearchText - allText: '+allText);
		
		//Prepare the Text for the ANY search
		anyText = getSearchAnyString();
		system.debug('KBSearchController.getSearchText - anyText: '+anyText);
		
		//Prepare the Text for the PHRASE search
		phraseText = getSearchPhraseString();
		system.debug('KBSearchController.getSearchText - phraseText: '+phraseText);
		
		//Prepare the Text for the NOT search
		notText = getSearchNotString();
		system.debug('KBSearchController.getSearchText - notText: '+notText);
		
		//Prepare the Text for the RecordType search
		articleTypeText = getExcludedArticleTypes();
		system.debug('KBSearchController.getSearchText - articleTypeText: '+articleTypeText);
		
		//Build the search string
		if(allText != null){
			bAllText = true;
			searchText = '(' + allText + ')';
		}
		if(anyText != null){
			if(bAllText == true){
				searchText = searchText + '+AND+';
			}
			bAnyText = true;
			searchText = searchText + '(' + anyText + ')';
		}
		if(phraseText != null){
			if(bAllText == true || bAnyText == true){
				searchText = searchText + '+AND+';
			}
			bPhraseText = true;
			searchText = searchText + '%22' + phraseText + '%22';
		}
		if(notText != null){
			if(bAllText == true || bAnyText == true || bPhraseText == true){
				searchText = searchText + '+AND+';
			}
			bNotText = true;
			searchText = searchText + '' + notText + '';
		}
		
		//Add the criteria to exclude unselected article/record types
		if(articleTypeText != null){
			if(bAllText == true || bAnyText == true || bPhraseText == true || bNotText == true){
				searchText = searchText + '+AND+';
				searchTextBlank = false;
			}else{
				searchTextBlank = true;
			}
			searchText = searchText + '' + articleTypeText + '';
		}
		
		searchText = searchText + '';
		system.debug('KBSearchController.getSearchText - searchText: ' + searchText);
		
		return searchText;
	}
	
	public string getSearchAllString()
	{
		string AllString = null;
		if(searchALL != null && searchALL != ''){
			AllString = '';
			if(searchALL.contains(' ')){
				List<String> allWords = searchALL.split(' ');
				for(string s1 : allWords){
					AllString = AllString + s1 + '+AND+';
				}
				AllString = AllString.left(AllString.length()-5);
			}else{
				AllString = searchALL;
			}
			AllString = AllString + '';
		}
		return AllString;
	}
	
	public string getSearchAnyString()
	{
		string AnyString = null;
		if(searchANY != null && searchANY != ''){
			AnyString = '';
			if(searchANY.contains(' ')){
				List<String> anyWords = searchANY.split(' ');
				for(string s2 : anyWords){
					AnyString = AnyString + s2 + '+OR+';
				}
				AnyString = AnyString.left(AnyString.length()-4);
			}else{
				AnyString = searchANY;
			}
			AnyString = AnyString + '';
		}
		return AnyString;
	}
	
	public string getSearchPhraseString()
	{
		string PhraseString = null;
		if(searchPHRASE != null && searchPHRASE != ''){
			PhraseString = '';
			if(searchPHRASE.contains(' ')){
				List<String> phraseWords = searchPHRASE.split(' ');
				for(string s1 : phraseWords){
					phraseString = phraseString + s1 + '+';
				}
				phraseString = phraseString.left(phraseString.length()-1);
			}else{
				phraseString = searchPHRASE;
			}
		}
		return PhraseString;
	}
	
	public string getSearchNotString()
	{
		string NotString = null;
		if(searchNOT != null && searchNOT != ''){
			NotString = '';
			if(searchNOT.contains(' ')){
				List<String> notWords = searchNOT.split(' ');
				for(string s1 : notWords){
					NotString = NotString + s1 + '+AND+NOT+';
				}
				NotString = NotString.left(NotString.length()-9);
				NotString = NotString.right(NotString.length()-4);
			}else{
				NotString = searchNOT;
			}
			NotString = 'NOT+' + NotString;
		}
		return NotString;
	}
	
	public string getExcludedArticleTypes()
	{
		string Exclusions = null;
		string strId;
		if(UNselectedArticleTypes.size() > 0){
			Exclusions = '';
			for(Id e : UNselectedArticleTypes){
				strId = e;
				Exclusions = Exclusions + e + '+OR+';
			}
			Exclusions = Exclusions.left(Exclusions.length()-4);
			Exclusions = 'NOT+(' + Exclusions + ')';
		}
		return Exclusions;
	}

	
	/******************* Previous versions of the code - not used now *********************************************************************/
	

	//public string whereClause;
	//public string whereArticleStatus;
	//public boolean includeArchived {get; set;}
	//transient public list<Solution> listSearchResults {get; set;}	
	//set<Id> includedCategoryIds = new set<Id>();
	//set<Id> sFullCategoryIds = new set<Id>();
	//map<Id,set<Id>> mapCatIdToParentIds = new map<Id,set<Id>>();
	//map<Id,String> mapResultArticleTypes = new map<Id,String>();
	//map<Id,list<Id>> mapCategoryChildToParents;
	//map<integer,CategoryList> mapCategorySelectOptions;
	//string queryType;

	//public boolean bArticleTypesChanged = false;
	//public boolean bCategoriesChanged = false;
	//public boolean bOrderChanged = false;
	//public integer resultSize = 0;
	//public string pg1 {get;set;}
	
	//public boolean isValid {get;set;}
	//public PageReference pgNull {get;set;}

	//public map<Id,SearchResult> wrSearchResults = new map<Id,SearchResult>();
	//public list<Solution> filteredSearchResults = new list<Solution>();
	//public list<Solution> filteredResults;
	//list<ArticleTypes> lArticleTypes = new list<ArticleTypes>();		
	//Integer DEFAULT_NUMBER_OF_RECORDS_PER_PAGE = 1;
	//public PageManager objPageManager {get;set;}
	//public string whereArticleType;
	//public List<SelectOption> slSubCategories {get; set;}
	//public String selectedCategoryId {get; set;}
	
	//public long fullResultCount	{
	//	//get {return fullSearchResults.size();}
	//	get; //{return listSearchResults.size();}
	//	set;
	//}
	
	//Wrapper class for Search Results
	//public class SearchResult {
	//	public String articleType {get; set;}
	//	public Id articleTypeId {get; set;}
	//	public Set<Id> categoryIds {get; set;}
	//	public Solution solutionRec {get; set;}
	//}
	
	//private string returnURL;
	
	
	//public PageReference pgSearchResult {get; set;}
		//get {return SearchCases();}
		//private set;
		//}
		
	
	/*
	public PageReference SearchCases()
	{
		//list<ArticleTypes> lArticleTypes = new list<ArticleTypes>();
		
		//objPageManager.page = 0;
		//queryType = 'Initial';
		
		//pg1 = new PageReference('https://cs13.salesforce.com/ui/solution/SolutionSearchPage?searchtype=C&search=print+server+selection&go=Find+Solution');
		//pg1.setRedirect(true);
		//return null;
		
		boolean noErrors = true;
		pgSearchResult = null;
		
		//call function to get specific search text from search criteria
		string searchSolutionText = getSearchText();
		system.debug('KBSearchController.SearchCases searchSolutionText : '+searchSolutionText);
		//string searchSolutionText = '1';
		if((searchALL == null || searchALL == '') && (searchANY == null || searchANY == '') && (searchPHRASE == null || searchPHRASE == '') && (searchNOT == null || searchNOT == '')){
			searchSolutionText = null;
		}
				
		//selectedArticleTypes = getArticleTypeSelections();
		getArticleTypeSelections();
		
		if(searchSolutionText == '' || searchSolutionText == null){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Please enter text in at least one of the search boxes.'));
			noErrors = false;
			pgSearchResult = null;
		}
		
		if(selectedArticleTypes.size() == 0){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Please select at least one Article Type to include.'));
			noErrors = false;
			pgSearchResult = null;
		}
		
		if(noErrors)
		{			
			
			////Clear the current list and then run the search
			//listSearchResults = new list<Solution>();
			//listSearchResults = getSearchResults();
			//system.debug('KBSearchController.SearchCases listSearchResults : '+listSearchResults);
			//
			////Set the Filters section visible. This will refresh the data from the search results before diplaying it
			//showFilters = true;
			//showResults = true;
			
			string pgURL = '/ui/solution/SolutionSearchPage?searchtype=C&search='+searchSolutionText+'&go=Find+Solution';
			pgSearchResult = new PageReference(pgURL);
			pgSearchResult.setredirect(true);
			//pg1 = pgURL;
			system.debug('pgSearchResult:'+pgSearchResult);
			
			//return null;
			//pg1 = pgURL;

			
			//Log the use of this function to the Process Logs table for tracking
	        if(!isLogged){
	        	try{
	   				CommonFunctions.addProcessLog('Solution', 'KBase Custom Search', 'Visualforce');
	   				isLogged = true;
	   			}catch(Exception e){
	   				System.debug('Error adding Process Log: '+e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
	   			}
	        }
		}
		//for(string s : ApexPages.currentPage().getHeaders().keySet()){
		//	system.debug('Page Headers: '+s+','+ApexPAges.currentPage().getParameters());	
		//}
		
		//return null;
		return pgSearchResult;
	}  
	*/
	
	/*
	public String getSearchText()
	{
		//build SOSL criteria based on search criteria
		
		system.debug('Criteria fields: '+searchALL+' '+searchANY+' '+searchPHRASE+' '+searchNOT);
		
		string searchText = '';
		string allText;
		string anyText;
		string phraseText;
		string notText;
		string articleTypeText;
		boolean bAllText = false;
		boolean bAnyText = false;
		boolean bPhraseText = false;
		boolean bNotText = false;
		
		//Prepare the Text for the ALL search
		allText = getSearchAllString();
		system.debug('KBSearchController.getSearchText - searchALL: '+searchALL);
		system.debug('KBSearchController.getSearchText - allText: '+allText);
		
		//Prepare the Text for the ANY search
		anyText = getSearchAnyString();
		system.debug('KBSearchController.getSearchText - anyText: '+anyText);
		
		//Prepare the Text for the PHRASE search
		phraseText = getSearchPhraseString();
		system.debug('KBSearchController.getSearchText - phraseText: '+phraseText);
		
		//Prepare the Text for the NOT search
		notText = getSearchNotString();
		system.debug('KBSearchController.getSearchText - notText: '+notText);
		
		//Prepare the Text for the RecordType search
		articleTypeText = getExcludedArticleTypes();
		system.debug('KBSearchController.getSearchText - articleTypeText: '+articleTypeText);
		
		//Build the search string
		if(allText != null){
			bAllText = true;
			searchText = '(' + allText + ')';
			//searchText = '' + allText + '';
		}
		if(anyText != null){
			if(bAllText == true){
				//searchText = searchText + ' AND ';
				searchText = searchText + '+AND+';
			}
			bAnyText = true;
			searchText = searchText + '(' + anyText + ')';
			//searchText = searchText + '' + anyText + '';
		}
		if(phraseText != null){
			if(bAllText == true || bAnyText == true){
				//searchText = searchText + ' AND ';
				searchText = searchText + '+AND+';
			}
			bPhraseText = true;
			searchText = searchText + '%22' + phraseText + '%22';
			//searchText = searchText + '(' + phraseText + ')';
		}
		if(notText != null){
			if(bAllText == true || bAnyText == true || bPhraseText == true){
				//searchText = searchText + ' AND ';
				searchText = searchText + '+AND+';
			}
			bNotText = true;
			//searchText = searchText + '(' + notText + ')';
			searchText = searchText + '' + notText + '';
		}
		
		//Add the criteria to exclude unselected article/record types
		if(articleTypeText != null){
			if(bAllText == true || bAnyText == true || bPhraseText == true || bNotText == true){
				searchText = searchText + '+AND+';
			}
			searchText = searchText + '' + articleTypeText + '';
		}
		
		searchText = searchText + '';
		system.debug('KBSearchController.getSearchText - searchText: ' + searchText);
		
		//SOSL searchText example - '(John AND Ben AND Sue) AND (Beth OR Joe OR Frank) AND "Mary and Joseph" AND NOT Doug AND NOT Fred'
		//vs
		//SOQL searchText example - WHERE (SearchText__c LIKE '%John%' AND SearchText__c LIKE '%Ben%' AND SearchText__c LIKE '%Sue%')
		//								AND (SearchText__c LIKE '%Beth%' OR SearchText__c LIKE '%Joe%' OR SearchText__c LIKE '%Frank%')
		//								AND (SearchText__c LIKE '%Mary and Joseph%')
		//								AND ((NOT SearchText__c LIKE '%Doug%') AND (NOT SearchText__c like '%Fred%')
		
		// Exceptions
		//- phrase includes 'and' or 'or' --> enclose in quotes
		//	(can always enclose phrase in quotes)
		//- escape characters --> use a \ before the character
		//	characters & | ! ( ) { } [ ] ^ " ~ * ? : \ ' + -
		//
		
		return searchText;
	}
	*/	
	
	/*
	public list<Solution> getListSearchResults()
	{
		listSearchResults = getSearchResults(getSearchText());
		
		wrSearchResults = wrapSearchResults(listSearchResults);
		
		return listSearchResults;
	}
	*/


	/*
	public string getWhereArticleStatus()
	{
		string articleStat = '';
			
		//Determine what to show based on if user is logged into the portal
		if(sessioninfo.InPortal){
			articleStat = 'isPublished = true';
		}else{
			articleStat = 'isReviewed = true';
		}
		
		return articleStat;
	}
	*/
	
	/*
	public string getWhereArticleTypes(set<Id> articleTypes1)
	{		
		string w = '';
		
		// -------- ArticleTypes --------
		//Get the list of excluded Article Types so the SOSL can be re-run with the WHERE clause
		if(!articleTypes1.isEmpty()){
			w = w + ' RecordTypeId in (';
			string recTypeIds = '';
			
			for(Id st : articleTypes1)
			{
				recTypeIds = recTypeIds + '\'' + st + '\',';
			}
			recTypeIds = recTypeIds.left(recTypeIds.length()-1);
			w = w + recTypeIds + ')';
		}
		system.debug('KBSearchController.getWhereClause - articleTypes1: '+articleTypes1);
		system.debug('KBSearchController.getWhereClause - w: '+w);
		
		return w;			
	}
	*/
		
	/*
	public map<Id,SearchResult> wrapSearchResults(list<Solution> searchResult)
	{
		//Build a map of the full solution results records in a wrapper that includes the article type and full Solution record
		map<Id,SearchResult> mapWrapResults = new map<Id,SearchResult>();
		for(Solution sol : searchResult)
		//for(Solution sol : soqlResults)
		{
			SearchResult sr = new SearchResult();
			sr.articleType = sol.recordtype.name;
			sr.articleTypeId = sol.recordTypeId;
			sr.categoryIds = new set<Id>();
			sr.solutionRec = sol;
			mapWrapResults.put(sol.Id,sr);
		}
		
		return mapWrapResults;
	}	
	*/
	

	/*
	public list<Solution> runSearch(string textToSearch, set<Id> excludeIds)
	{
		list<Solution> results = new list<Solution>();
		
		whereClause = 'WHERE ' + getWhereArticleStatus();
		
		string wc = getWhereArticleTypes(selectedArticleTypes); 

		if(wc != '' && wc != null){
			whereClause = whereClause + ' AND ' + wc; 
		}
		if(excludeIds.size() > 0){
			whereClause = whereClause + ' AND Id NOT IN :excludeIds';
		}
		
		string resultQuery = 'FIND :textToSearch RETURNING Solution(Id, SolutionNumber, SolutionName, Status, Product__c, Product_Version__c, RecordType.Name, RecordTypeId, CreatedBy.Name, CreatedDate, LastModifiedDate, TimesUsed ' + whereClause + ' ORDER BY ' + sortField + ' ' + sortDir + ' nulls last)'; 
		system.debug('KBSearchController.runSearch - resultQuery: '+resultQuery);
		
		list<list<sObject>> results1 = Search.query(resultQuery);
		results = results1[0];
		
		return results;
	}
	*/
	
	/*
	public list<Solution> runSearchSOQL()
	{
		list<Solution> results = new list<Solution>();
		
		string selectfields = 'Id, SolutionNumber, SolutionName, SolutionNote, Status, Product__c, Product_Version__c, RecordType.Name, RecordTypeId, CreatedBy.Name, CreatedDate, LastModifiedDate, TimesUsed';
		
		whereClause = 'WHERE ' + getWhereArticleStatus();
		
		string wc = getWhereArticleTypes(selectedArticleTypes);
		
		if(wc != '' && wc != null){
			whereClause = whereClause + ' AND ' + wc;
		}
		
		//Categories
		string wcCategories = getWhereCategories();
		if(wcCategories != '' && wcCategories != null){
			whereClause = whereClause + ' AND ' + wcCategories;
		}
		 
		if(includeArchived == false){
			whereClause = whereClause + ' AND (NOT Product__c like \'%ARCHIVED\')';
		}
		 
		string resultQuery = 'SELECT ' + selectfields + ' FROM Solution ' + WhereClause + ' ORDER BY ' + sortField + ' ' + sortDir + ' nulls last';
		system.debug('KBSearchController.runSearchSOQL - resultQuery: '+resultQuery);
		
		//list<Solution> results2 = Database.query(resultQuery);
		//system.debug('KBSearchController.runSearchSOQL - results2.size: '+results2.size());

		//Loop through the results and check if the record contains the search criteria
		list<Solution> foundResults = new list<Solution>();
		//for(Solution s1 : soqlResults)
		for(Solution s1 : Database.query(resultQuery))
		{
			string searchMe = s1.SolutionName + ';' + s1.solutionNote + ';';
			if(containsSearchCriteria(searchMe)){
				foundResults.add(s1);
			}
			//system.debug('limit check: results='+foundResults.size()+', statements='+Limits.getScriptStatements()+', script statement percent used='+(Limits.getScriptStatements()*100)/Limits.getLimitScriptStatements());
			if(foundResults.size() >= 500 || ((Limits.getScriptStatements()*100)/Limits.getLimitScriptStatements() > 90)){
				break;
			}
		}
		system.debug('KBSearchController.getSearchResults - 1 - foundResults.size: '+foundResults.size());
		
		return foundResults;
	}
	*/

	/*
	//public list<Solution> getSearchResults(String textSearch)
	public list<Solution> getSearchResults()
	{
		set<Id> searchResultIds = new set<Id>();
		
		//Run the search and return the full results
		//list<Solution> soslResults = runSearch(textSearch,searchResultIds);
		//system.debug('KBSearchController.getSearchResults - 1 - soslResults.size: '+soslResults.size()); 
		
		//Run the SOQL query and return the full results
		list<Solution> soqlResults = runSearchSOQL();
		system.debug('KBSearchController.getSearchResults - 1 - soqlResults.size: '+soqlResults.size());
		
		//Check if more results need to be pulled. If result size is exactly 200, then more can probably be pulled.  SOSL limit is 200 records.
		//if(soslResults.size() == 200)
		//	//Get the result Solution Ids into a set
		//	for(Solution s : soslResults){
		//		searchResultIds.add(s.Id);
		//	}
			
		//	//Re-run the search with the same criteria, but exclude the solutions already found.
		//	soslResults.addAll(runSearch(textSearch,searchResultIds));
		//	//Add the new result Solution Ids into the set
		//	for(Solution s : soslResults){
		//		searchResultIds.add(s.Id);
		//	}
		//	system.debug('KBSearchController.getSearchResults - 2 - soslResults.size: '+soslResults.size());
		//	
		//	if(soslResults.size() == 400){
			//if(soslResults.size() == 500){
		//if(soqlResults.size() >= 500)
		//{
		//	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'A large number of results have been returned.  Use the Filters to narrow your search results.'));
		//}
		
		resultSize = soqlResults.size();
		
		if(soqlResults.size() >= 500)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'A large number of results have been returned.  Use the Filters to narrow your search results.'));
		}
		
		//return soslResults;
		return soqlResults;
	}
	*/
	
	
	/*
	public string getWhereCategories()
	{
		//Returns a list of CategoryIds which are children of the lowest selected parent category
		set<Id> childCategoryIDs = new set<Id>();
		string w = '';
		
		//Get the lowest selected parent category
		Id selectedParentId;
		
		integer x = 1;
		system.debug('check Id: '+lCategories.get(x).itemId);
		while (lCategories.get(x).itemId != null && x <= numCategoryLevels)
		{
			selectedParentId = lCategories.get(x).itemId;
			x++;
		}
		
		if(selectedParentId != null){
			childCategoryIds.addAll(mapCategoryParentToChildren.get(selectedParentId));
			childCategoryIds.add(selectedParentId);	
		} 
		system.debug('KBSearchController.getWhereCategories - selectedParentId: '+selectedParentId);
		system.debug('KBSearchController.getWhereCategories - childCategoryIds: '+childCategoryIds);
		
		//Build the string  with the condition and list of Ids
		if(!childCategoryIds.isEmpty()){
			//example clause:  id in (select relatedsobjectid from categorydata where categorynodeid in ('02n2000000000bDAAQ'))
			w = w + ' id in (select relatedsobjectid from categorydata where categorynodeid in (';
			string catIds = '';
			for(Id st : childCategoryIds)
			{
				catIds = catIds + '\'' + st + '\',';
			}
			catIds = catIds.left(catIds.length()-1);
			w = w + catIds + '))';
		}
		system.debug('KBSearchController.getWhereCategories - w: '+w);
		
		return w;
	}
	*/

	/*
	public boolean containsSearchCriteria(string searchString)
	{
		//Used with SOQL search functionality
		
		//determine if the criteria box has a value to be searched
		//boolean ALLsearch = searchALL != null && searchALL.trim() != '';
		//boolean ANYsearch = searchANY != null && searchANY.trim() != '';
		//boolean PHRASEsearch = searchPHRASE != null && searchPHRASE.trim() != '';
		//boolean NOTsearch = searchNOT != null && searchNOT.trim() != '';
		
		//if the criteria box was blank, mark it as true since there was no search term.  Otherwise, set to false so the code logic will check
		boolean foundALL = false;
		boolean foundANY = false;
		boolean foundPHRASE = false;
		boolean foundNOT = false;
		
		//If the ALL search criteria is not blank...
		if(searchALL != null && searchALL.trim() != '')
		{
			//If the ALL search criteria contains a space, split it into the individual words
			if(searchALL.contains(' ')){
				list<String> allWords = searchALL.split(' ');
				for(integer x1 = 0; x1 <= allWords.size()-1;x1++){
					foundALL = foundALL && searchString.contains(allWords[x1]);
				}
			}else{
				//If there was no space, there is only one term, so search the string for that one
				foundALL = searchString.contains(searchALL);
			}
		}else{
			foundALL = true;
		}
		system.debug('KBSearchController.containsSearchCriteria - foundALL : '+foundALL);
		
		//If the ANY search criteria is not blank...
		if(searchANY != null && searchANY.trim() != '')
		{
			//If the ANY search criteria contains a space, split it into the individual words
			if(searchANY.contains(' ')){
				List<String> anyWords = searchANY.split(' ');
				//Loop through and check that at least one of the words are included in the string to be searched. 
				for(integer x1 = 0; x1 <= anyWords.size()-1;x1++){
					foundANY = foundANY || searchString.contains(anyWords[x1]);
				}
			}else{
				//If there was no space, there is only one term, so search the string for that one
				foundANY = searchString.contains(searchANY);
			}
		}else{
			foundANY = true;
		}
		system.debug('KBSearchController.containsSearchCriteria - foundANY : '+foundANY);
		
		//If the PHRASE search criteria is not blank...
		if(searchPHRASE != null && searchPHRASE.trim() != '')
		{
			//If the PHRASE is included in the search string, the solution record should be included
			foundPHRASE = searchString.contains(searchPHRASE);
		}else{
			foundPHRASE = true;
		}
		system.debug('KBSearchController.containsSearchCriteria - foundPHRASE : '+foundPHRASE);
		
		//If the NOT search criteria is not blank...
		if(searchNOT != null && searchNOT.trim() != '')
		{
			//If the NOT search criteria contains a space, split it into the individual words
			if(searchNOT.contains(' ')){
				foundNOT = true;
				List<String> notWords = searchNOT.split(' ');
				//Loop through and check that all the words are not included in the string to be searched. 
				for(integer x1 = 0; x1 <= notWords.size()-1;x1++){
					foundNOT = foundNOT && searchString.contains(notWords[x1]);
				}
			}else{
				//If there was no space, there is only one term, so search the string for that one
				foundNOT = searchString.contains(searchNOT);
			}
		}else{
			foundNOT = true;
		}
		system.debug('KBSearchController.containsSearchCriteria - foundNOT : '+foundNOT);
		
		boolean keepRecord = foundALL && foundANY && foundPHRASE && foundNOT; 
		return keepRecord;
	}
	*/
	
	/*
	public void filterSearchResults()
	{
		listSearchResults.clear();
		//listSearchResults = getSearchResults(getSearchText());
		listSearchResults = getSearchResults();
		system.debug('KBSearchController.filterSearchResults listSearchResults : '+listSearchResults);
		//fullResultCount = listSearchResults.size();
	}
	*/	
	
	/*
	public list<ArticleTypes> getlArticleTypes(){
		system.debug('lArticleTypes:'+lArticleTypes);
		return lArticleTypes;
	}
	*/
	
	/*
	public void setlArticleTypes(list<ArticleTypes> a){
		system.debug('setlArticleTypes: '+a);
		lArticleTypes = a;
	}
	*/
	
	/*
	public PageReference selectArticleType()
	{
		//Update the list of included Article Types
		includedArticleTypes.clear();
		for(ArticleTypes atx : lArticleTypes)
		{
			if(atx.selected){
				includedArticleTypes.add(atx.ItemId);
			}
		}
		system.debug('KBSearchController.getlArticleTypes - 1 - includedArticleTypes: '+includedArticleTypes);
		
		//Update the flag to indicate the selected ArticleTypes have changed
		bArticleTypesChanged = true;
		
		//filterSearchResults();
		
		return null; 
	}
	*/
	
	/*
	public CategoryList buildSubCategoryList(Id parentId)
	{
		//Build the subcategory list.  If parentId is null, just build a 
		
		list<SelectOption> subCategoryChoices = new list<SelectOption>();
		subCategoryChoices.add(new SelectOption('','(All Subcategories)'));
		
		//get the list of sub categories for the given parent id
		for(CategoryNode cn : mapCategoryNode.values())
		{
			if(cn.ParentId == parentId){
				subCategoryChoices.add(new SelectOption(cn.Id,cn.MasterLabel));
			}
		}
		//for(CategoryNode cn : [select Id, MasterLabel, ParentId from CategoryNode where ParentId = :parentId])
		//{
		//	subCategoryChoices.add(new SelectOption(cn.Id,cn.MasterLabel));
		//}
		//subCategoryChoices.sort();
		system.debug('KBSearchController.buiildSubCategoryList - subCategoryChoices: '+subCategoryChoices);
		
					CategoryList clx = new CategoryList();
			clx.itemLabel = 'Level '+ x;
			clx.itemId = null;
			clx.level = x;
			clx.showSelectList = false;
			clx.choices = new list<SelectOption>();
			mapCategorySelectOptions.put(x,clx);
		}
		
		return subCategoryChoices;
	}
	*/
	
	/*
	public String categoryIndent(Integer iLevel)
	{
		system.debug('KBSearchController.categoryIndent - iLevel: '+iLevel);
		String indent = '';
		if(iLevel == 1)
		{
			indent = '';
		}
		else if(iLevel == 2)
		{
			indent = sIndention;
		}
		else
		{
			for(integer x = 1; x <= iLevel - 2; x++){
				//indent = indent + '&#32;&#32;';
			}
			indent = indent + sIndention;
		}
			
		return indent;
	}
	*/

	/*
	public set<Id> getParentId(map<Id,CategoryNode> mapCat, Id childId)
	{
		Id ParentId;
		set<Id> setIds = new set<Id>();
		
		if(childId == null){
			return setIds;
		}
		else
		{
			ParentId = mapCat.get(childId).ParentId;
			setIds.add(getParentId(mapCat,ParentId));
		}
		sytem.debug('KBSearchController.getParentId - setIds:'+setIds);
		return setIds;
	}
	*/
	
	/*
	public set<Id> getChildIds(set<Id> parentIds)
	{
		//Builds a list of all child Ids under the parent category.  Currently, the result does not include the original parent id
		set<Id> childIds = new set<Id>();
		
		if(parentIds.isEmpty()){
			return childIds;
		}
		else
		{
			for(CategoryNode cn : mapCategoryNode.values())
			{
				
			}
			// -->> May want to replace this with a map so don't hit a limit on number of SOQL statements
			for(CategoryNode cn : [select Id from CategoryNode where ParentId in :parentIds])
			{
				childIds.add(cn.Id);
			}
			
			childIds.addAll(getChildIds(childIds));
			
			//childIds.addAll(parentIds);
			system.debug('KBSearchController.getchildIds - childIds:'+childIds);
			
			return childIds;
		}
	}
	*/
	
	/*
	public boolean getIncludeALL(string searchString)
	{
		boolean ALLinclude = true;
		
		//If the ALL search criteria is not blank...
		//if(searchALL != null && searchALL != ''){
			//If the ALL search criteria contains a space, split it into the individual words
			if(searchALL.contains(' ')){
				List<String> allWords = searchALL.split(' ');
				//Loop through and check that all words are included in the string to be searched.  If not found, the loop exits
				for(integer x1 = 0; x1 <= allWords.size() && ALLinclude == true;x1++){
					if(!searchString.contains(allWords[x1])){
						ALLinclude = false;
					}
				}
			}else{
				//If there was no space, there is only one term, so search the string for that one
				if(!searchString.contains(searchALL)){
					ALLinclude = false;
				}
			}
		//}
		return ALLinclude;
	}
	
	public boolean getIncludeANY(string searchString)
	{
		boolean ANYinclude = false;
		
		//If the ANY search criteria is not blank...
		//if(searchANY != null && searchANY != ''){
			//ANYinclude = false;
			//If the ANY search criteria contains a space, split it into the individual words
			if(searchANY.contains(' ')){
				List<String> anyWords = searchANY.split(' ');
				//Loop through and check that at least one of the words are included in the string to be searched. 
				for(integer x1 = 0; x1 <= anyWords.size() && ANYinclude == false;x1++){
					if(searchString.contains(anyWords[x1])){
						ANYinclude = true;
					}
				}
			}else{
				//If there was no space, there is only one term, so search the string for that one
				if(searchString.contains(searchANY)){
					ANYinclude = true;
				}
			}
		//}
		return ANYinclude;
	}

	public boolean getIncludePHRASE(string searchString)
	{
		boolean PHRASEinclude = true;
		
		//If the PHRASE search criteria is not blank...
		//if(searchPHRASE != null && searchPHRASE != ''){
			//If the PHRASE is included in the search string, the solution record should be included
			if(searchString.contains(searchPHRASE)){
					PHRASEinclude = true;
			}
		//}
		return PHRASEinclude;
	}

	public boolean getIncludeNOT(string searchString)
	{
		boolean NOTinclude = true;
		
		//If the NOT search criteria is not blank...
		//if(searchNOT != null && searchNOT != ''){
			//If the NOT search criteria contains a space, split it into the individual words
			if(searchNOT.contains(' ')){
				List<String> notWords = searchNOT.split(' ');
				//Loop through and check that all the words are not included in the string to be searched. 
				for(integer x1 = 0; x1 <= notWords.size() && NOTinclude == true;x1++){
					if(searchString.contains(notWords[x1])){
						NOTinclude = false;
					}
				}
			}else{
				//If there was no space, there is only one term, so search the string for that one
				if(searchString.contains(searchNOT)){
					NOTinclude = false;
				}
			}
		//}
		return NOTinclude;		
	}	
	*/

	/*  TESTING
	public map<Id,SearchResult> testGetSolutionResult(string textSearch)
	{
		map<Id,SearchResult> testMap = new map<Id,SearchResult>();
		
		string urlTest = 'http://cs13.salesforce.com/ui/solution/SolutionSearchPage?t=4&searchtype=C&search=' + textSearch + '&cid=000000000000000&go=Find+Solution';
		PageReference pr = new PageReference(urlTest);
		
		system.debug('PR Content: '+pr.getContent().toString());
		
		return testMap;
	}
	*/  	


	/*
	public list<Solution> getSearchResults(String typeSearch, String textSearch)
	{
		/*  typeSearch
			'Initial' 		= first run of the search or first run after updated search critieria
			'ArticleType' 	= apply the updated Article Type filter
			'Category' 		= apply the updated Category filter 
		*//*
		
		list<Solution> searchResult = new list<Solution>();
		string strSOQL = '';
		string whereString = '';
		mapResultArticleTypes.clear(); 
		
		string soqlResultFields = 'Id,SolutionNumber,SolutionName,SolutionNote,Status,Product__c,Product_Version__c,RecordType.Name,RecordTypeId,CreatedBy.Name,CreatedDate,LastModifiedDate,TimesUsed';
		if(sessionInfo.InPortal == false){
			soqlResultFields = soqlResultFields + ',Technical_Info__c';
		}
		
		//If Initial or ArticleType search, build the criteria for the query
		if(typeSearch == 'Initial' || typeSearch == 'ArticleType')
		{
			string reviewStatus = getWhereArticleStatus();
			whereString = reviewStatus;
			if(textSearch != ''){
				whereString = whereString + ' AND ' + textSearch;
			}
		}
		
		//If ArticleType search, also add a search criteria for the recordtype 
		if(typeSearch == 'ArticleType')
		{
			
		}
		
		//Determine which type of search to run
		//if(typeSearch == 'Initial')
		//{
			//1) On initial search, Run search using SOQL by checking Title line for keywords where isReviewed/isPublised order by TimesUsed, limit 2500
			strSOQL = 'SELECT ' + soqlResultFields + ' FROM Solution WHERE ' + whereString + ' ORDER BY TimesUsed desc LIMIT 2500';
			system.debug('KBSearchController.getSearchResults - strSOQL (Initial):' + strSOQL);
			
			//2) Loop through these records and check long text fields.  First 50 (or page size) will be shown on page 1.  Others available on next pages.
  			//	--> Write this one so it can be called later as well
  			boolean blankALL = (searchALL == null || searchALL == '');
			boolean blankANY = (searchANY == null || searchANY == '');
			boolean blankPHRASE = (searchPHRASE == null || searchPHRASE == '');
			boolean blankNOT = (searchNOT == null || searchNOT == '');
			
			//Loop through the query results and apply the search criteria.  This is necessary because the long text area fields cannot be filtered in a SOQL query	
  			for(Solution sln : Database.query(strSOQL))
  			{
				string allFields = textSearch + ',' + sln.SolutionNote + ',' + sln.SolutionNumber;
				if(sessionInfo.InPortal == false){
					allFields = allFields + ',' + 'Technical_Info__c';
				}
					
				//Check the ALL fields criteria.  All given terms must be found for the solution record to be included
				boolean includeALL = blankALL;  //Automatically mark as included if criteria section is blank
				if(blankALL == false){
					includeALL = getIncludeALL(allFields);
				}
					
				//Check the OR fields critiera.  If one of the given terms is found in the string, then the solution record is included
				boolean includeANY = blankANY;	//Automatically mark as included if criteria section is blank
				if(blankANY == false){
					includeANY = getIncludeANY(allFields);
				}
					
				//Check the PHRASE fields criteria.  If the given phrase is found in its entirity, then the solution record is included
				boolean includePHRASE = blankPHRASE;  //Automatically mark as included if criteria section is blank
				if(blankPHRASE == false){
					includePHRASE = getIncludePHRASE(allFields);
				}
					
				//Check the NOT fields criteria.  None of the given terms should appear in the string for the solution record to be included
				boolean includeNOT = blankNOT;	//Automatically mark as included if criteria section is blank
				if(blankNOT == false){
					includeNOT = getIncludeNOT(allFields);
				}
				
				//Check if all criteria have been met.  If so, include the solution record
				if(includeALL == true && includeANY == true && includePHRASE == true && includeNOT == true){
					searchResult.add(sln);
					mapResultArticleTypes.put(sln.RecordTypeId,sln.RecordType.Name);
				}
			}
			system.debug('KBSearchController.getFullSearchResults - searchResult count: '+searchResult.size());
  		//}
  		//else if(typeSearch == 'ArticleType')
  		//{
  				
		//}

							
		//List the fields to include in the full search results, which will then be filtered
		//string soqlFieldList = 'Id, SolutionNumber, SolutionName, Status, Product__c, Product_Version__c, RecordType.Name, CreatedBy.Name, CreatedDate, LastModifiedDate, TimesUsed';
		
		//string soqlQuery = 'SELECT ' + soqlFieldList + ' FROM Solution WHERE Id in :solutionIds';
		
		//list<Solution> soqlResults = Database.query(soqlQuery);
		
		
		//Build a map of the full solution results records in a wrapper that includes the article type and full Solution record
		//map<Id,SearchResult> fullResults = new map<Id,SearchResult>();
		//for(Solution sol : searchResult)
		//for(Solution sol : soqlResults)
		//{
		//	SearchResult sr = new SearchResult();
		//	sr.articleType = sol.recordtype.name;
		//	sr.articleTypeId = sol.recordTypeId;
		//	sr.categoryIds = new set<Id>();
		//	sr.solutionRec = sol;
		//	fullResults.put(sol.Id,sr);
		//}
		
		//Next, query for the related Categories and add those to the wrapper to a set for the related solution id
		//for(CategoryData cd : [select Id, CategoryNodeId, RelatedSObjectId from CategoryData where RelatedSObjectId in :fullResults.keySet()])
		//{
		//	fullResults.get(cd.RelatedSObjectId).categoryIds.add(cd.CategoryNodeId);
		//}
		//system.debug('KBSearchController.getFullSearchResults - fullResults: '+fullResults);
		
		//Build out the list of Category Ids to include all Parent Ids
		//fullResults = buildCatHierarchy(fullResults);
		
		
		//Build the ArticleTypes set for display
		//lArticleTypes = buildArticleTypes(mapArticleTypesInResults);
		
		return searchResult;
	}
	*/
  	
	/*
	public string getWhereCategories()
	{
		//Build a string of solution Ids that should be excluded
		string w = '';
		
		for(SearchResult sResult : mapFullResults)
		{
			
		}
	}
	*/  	
  	
  	/* Original Search screen VF code

	
	/*
	public map<Id,SearchResult> buildCatHierarchy(map<Id,SearchResult> mapFullResults)
	{
		map<Id,set<Id>> mapCatParents = new map<Id,set<Id>>();
		sFullCategoryIds.clear();
		
		//Query for the related Categories.  
		for(CategoryData cd : [select Id, CategoryNodeId, RelatedSObjectId from CategoryData where RelatedSObjectId in :mapFullResults.keySet()])
		{
			Id catId = cd.CategoryNodeId;
			
			//Add the related CategoryIds to the wrapper to a set for the related solution id
			mapFullResults.get(cd.RelatedSObjectId).categoryIds.add(catId);
			
			//Build the list of unique CategoryIds 
			sFullCategoryIds.add(catId);
			
			//Add each unique CategoryId to the map with a blank list of ParentIds
			if(!mapCatParents.keySet().contains(catId)){
				mapCatParents.put(catId,new set<Id>());
			}
		}
		system.debug('KBSearchController.getFullSearchResults - fullResults: '+mapFullResults);
		system.debug('KBSearchController.getFullSearchResults - sFullCategoryIds: '+sFullCategoryIds);
		system.debug('KBSearchController.getFullSearchResults - 1 - mapCatParents: '+mapCatParents);		
		
		//Loop through the full search results and get the unique list of categories
		//for(SearchResult s : mapFullResults.values())
		//{
		//	sFullCategoryIds.addAll(s.categoryIds);
		//}
		//system.debug('KBSearchController.buildCatHierarchy - sFullCategoryIds: '+sFullCategoryIds);
		
		//Add each CategoryId to the map with a blank list of ParentIds
		//for(Id iCat : sFullCategoryIds)
		//{
		//	mapCatParents.put(iCat,new set<Id>());
		//}
		//system.debug('KBSearchController.buildCatHierarchy - 1 - mapCatParents: '+mapCatParents);
		
		//Get the full set of Solution Categories into a map with ParentIds
		map<Id,CategoryNode> solnCategoryParents = new map<Id,CategoryNode>([select Id, ParentId, MasterLabel from CategoryNode]);
		
		//Loop through until there are no more ParentIds to add for each map item
		for(Id i : mapCatParents.keySet())
		{
			Id baseId = i;
			Id childId = i;

			while (solnCategoryParents.get(childId).ParentId != null) {
				//system.debug('childId:'+childId);
				//system.debug('solnCategoryParents.get(childId):'+solnCategoryParents.get(childId));
				//system.debug('mapCatParents.get(baseId):'+mapCatParents.get(baseId));
				mapCatParents.get(baseId).add(solnCategoryParents.get(childId).ParentId);
				childId = solnCategoryParents.get(childId).ParentId;
			}
		}
		system.debug('KBSearchController.buildCatHierarchy - 2 - mapCatParents: '+mapCatParents);
		
		//Loop back through the set of SearchResults and add in the additional CategoryIds
		for(SearchResult sr1 : mapFullResults.values())
		{
			set<Id> addParentIds = new set<Id>();
			for(Id catId : sr1.CategoryIds)
			{
				addParentIds.addAll(mapCatParents.get(catId));
			}
			sr1.CategoryIds.addAll(addParentIds);
			system.debug('KBSearchController.buildCatHierarchy - sr1.categoryIds: '+sr1.CategoryIds);
		}
		system.debug('KBSearchController.buildCatHierarchy - mapFullResults: '+mapFullResults);
		
		//return mapCatParents;
		return mapFullResults;	
	}
	*/
	/*
	public List<Solution> filterSearchResults(Set<Id> aTypes, Set<Id> catIds)
	{
		//The result of this module is used as the source of the results datagrid 
		
		List<Solution> filteredList = new List<Solution>();
		
		//whereClause = getWhereClause(aTypes);
		
		//If both sets of filters are empty, then we include all search results since there is no filter
		if(aTypes.isEmpty() && catIds.isEmpty())
		{
			//for(SearchResult fsr : fullSearchResults.values())
			for(SearchResult fsr : wrSearchResults.values())
			{
				filteredList.add(fsr.solutionRec);
			}
		}
		else  //Otherwise, only add solutions to the filtered list that meet the filter criteria or the individual filter is empty
		{
			string articleStat;
			
			//Update the query search string
			//string querySearch = getSearchText() + excludedArticleTypes;
			//system.debug('KBSearchController.getFilteredSearchResults - querySearch: '+querySearch);
			
			//Re-run the search query to get fresh results
			//fullSearchResults = getFullSearchResults(getSearchText());
			//listSearchResults = getSearchResults('ArticleType',getSearchText());
			listSearchResults = getSearchResults(getSearchText());
			/* need to update numbering for paging *//*
			
			// -------- Categories --------
			//for(SearchResult fsr : fullSearchResults.values())
			for(SearchResult fsr : wrSearchResults.values())
			{
				//if((aTypes.isEmpty() || aTypes.contains(fsr.articleType)) && (catIds.isEmpty() || fsr.categoryIds.containsAll(catIds)))
				if(catIds.isEmpty() || fsr.categoryIds.containsAll(catIds))
				{
					filteredList.add(fsr.solutionRec);
				}
			}
		}
		system.debug('KBSearchController.getFilteredSearchResults - filteredList: '+filteredList);
		
		return filteredList;
	}
	
	public list<Solution> getFilteredSearchResults()
	{
		//Determine which ArticleTypes are selected and should be included in the results
		system.debug('KBSearchController.getFilteredSearchResults - 1 - lArticleTypes: '+lArticleTypes);
		
		//If one of the filter selections has changed, re-apply the filters and get the new list of results.  Otherwise, return the current set of filtered results
		if(bArticleTypesChanged == true || bCategoriesChanged == true || bOrderChanged == true)
		{
			bArticleTypesChanged = false;
			bCategoriesChanged = false;
			bOrderChanged = false;
			
			//Apply the filters to the full set of results
			filteredSearchResults.clear();
			filteredSearchResults = filterSearchResults(includedArticleTypes,includedCategoryIds);
		}
		
		system.debug('KBSearchController.getFilteredSearchResults - filteredResultCount: '+filteredResultCount);
		
		return filteredSearchResults;
	}
	*/
	
	/*
	public list<ArticleTypes> buildArticleTypes()
	{
		//map<Id,String> mapTypes = new map<Id,String>();
		list<ArticleTypes> artTypes = new list<ArticleTypes>();
		
		////Loop through the list of articles in the search results
		//for(SearchResult s : fullSearchResults.values())
		//{
		//	//Add each unique record type to the map
		//	mapTypes.put(s.articleTypeId,s.articleType);
		//}
		system.debug('KBSearchController.buildArticleTypes - mapResultArticleTypes: '+mapResultArticleTypes);
		
		//Add each item in the map of record types to the list of article types
		for(Id aTypeId : mapResultArticleTypes.keySet())
		{
			ArticleTypes a = new ArticleTypes();
			a.item = mapResultArticleTypes.get(aTypeId);
			a.itemId = aTypeId;
			artTypes.add(a);
		}
		system.debug('KBSearchController.buildArticleTypes - artTypes: '+artTypes);
		
		return artTypes;		
	}
	*/	
	
	/* Page Manager for results
	//Current sort direction - defaults to asc
  	public String sortDir {
    	get  { if (sortDir == null) {  sortDir = 'desc'; } return sortDir;  }
    	set;
  	}
 
  	//Current field to sort by - defaults to solution number
  	public String sortField {
    	get  { if (sortField == null) {sortField = 'LastModifiedDate'; } return sortField;  }
    	set;
  	}	
	
	//Toggles the sorting of query from asc<-->desc
  	public void toggleSort() {
    	bOrderChanged = true;
    	// simply toggle the direction
    	sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
    	// run the query again
    	SearchCases();
  	}
  	*/	
	
	
	/*
  	
  			<apex:outputPanel id="searchPanel" layout="none">
			<!-- <div id="form_filter" style="width:30%;float:left;"> -->
			<apex:outputPanel id="form_criteria" style="width:40%;float:left;" >
				
				<apex:pageBlock tabStyle="Case" title="Specify Search Criteria" id="searchBlock">
					
						<table cellpadding="0" cellspacing="0" border="0" height="230">
							<!-- <tr>
								<td><strong>Search Criteria:</strong></td>
							</tr> -->
							<tr>
								<td colspan="2">To search all articles in the Knowledge Base, enter your search terms in the fields below and click Search.</td>
							</tr>
							<tr>
								<td><br/></td>
							</tr>
		    				<tr>
			        			<td><strong>ALL</strong> of these words:<br/><font size="-2">(An 'AND' search with less results) &nbsp; &nbsp;<br/><br/></font></td>
			        			<td><input type="text" name="searchall" id="searchall" size="25" value="" /><br/></td>
		    				</tr>	
		    				<tr>
		        				<td><strong>ANY</strong> of these words:<br/><font size="-2">(An 'OR' search with more results) &nbsp; &nbsp;<br/><br/></font></td>
								<td><input type="text" name="searchany" id="searchany" size="25" value="" /></td>
		    				</tr>
		    				<tr>
		        				<td>This <strong>exact phrase</strong>:<br/><font size="-2">(All these words in this order) &nbsp; &nbsp;<br/><br/></font></td>
		        				<td><input type="text" name="searchphr" id="searchphr" size="25" value="" /></td>
			    			</tr>
			    			<tr>
			        			<td><strong>None</strong> of these words:<br/><font size="-2">(A 'NOT' search excluding these words) &nbsp; &nbsp;<br/><br/></font></td>
			        			<td><input type="text" name="searchnot" id="searchnot" size="25" value="" /></td>
			    			</tr>
						</table>
			</apex:pageBlock>
			
			</apex:outputPanel>
			<!-- </div> -->
			<!-- <apex:outputPanel id="form_spacer" style="width:5%;float:left;" > -->
			<!-- </apex:outputPanel> -->
			<apex:outputPanel id="form_filters" style="width:60%;float:left;" >
			<!-- <div id="form_filter" style="width:60%; float:left;"> -->
				<apex:pageBlock tabStyle="Case" title="Filter Your Results" id="filterBlock" >
					<table width="100%" height="230">
					<tr>
					<td width="30%">
						<table cellpadding="0" cellspacing="0" border="0" >
							<!-- <tr>
			    				<strong>Filter Your Results:</strong>
			    			</tr> -->
			    			<tr>
			    				<td>Use the Article Type and Category filters below to refine your search</td>
			    			</tr>
			    			<tr>
			    				<td><br/></td>
			    			</tr>
			    			<tr>
				        		<td>FAQ</td>
				        		<td><input type="checkbox"></input></td>
							</tr>
			    			<tr>	        		
					            <td>Download</td>
				        		<td><input type="checkbox" ></input></td>
				        	</tr>
			    			<tr>
				        		<td>Documentation</td>
				        		<td><input type="checkbox" ></input></td>
				        	</tr>
			    			<tr>
				        		<td>How To</td>
				        		<td><input type="checkbox" ></input></td>
					        </tr>
					        <tr>
					        	<td><br/></td>
					        </tr>
			    	    </table>
	    	    	</td>
					<td width="5%">
					</td>
					<td width="30%">
						<table cellpadding="0" cellspacing="0" border="0" >
							<tr>
			    				<td><br/></td>
			    			</tr>
			    			<tr>   
					            <td>Search Category 1 &nbsp; &nbsp; &nbsp;</td>
					            <td><input type="text" id="inputCat1" size="25" value="" /></td>
					        </tr>
			    			<tr>
					            <td>Search Category 2 &nbsp; &nbsp; &nbsp;</td>
					            <td><input type="text" id="inputCat2" size="25" value="" /></td>
					        </tr>
			    			<tr>    
					            <td>Search Category 3 &nbsp; &nbsp; &nbsp;</td>
					            <td><input type="text" id="inputCat3" size="25" value="" /></td>
					        </tr>
			    			<tr>            
					            <td></td>
					        </tr>
			    			<tr>
					            <td><center>Clear Filters</center></td>
			    			</tr>			    			
			    		</table>
			    	</td>
				</tr>
			</table>
				</apex:pageBlock>
			<!-- </div> -->
			</apex:outputPanel>	
		</apex:outputPanel>
		
	*/  
	
	/* VF Page original javascript
	
	<script language="JavaScript">
function executesearch() {
    var search = "";
    var searchall = document.searchform.searchall.value;
    var searchany = document.searchform.searchany.value;
    var searchphr = document.searchform.searchphr.value;
    var searchnot = document.searchform.searchnot.value;
    if (searchall != "") {
        search = searchall.replace(/ /g,"%20AND%20");
    }
    if (searchany != "") {
        searchany = searchany.replace(/ /g,"%20OR%20");
        if (searchall != "" || searchphr != "") searchany = "(" + searchany + ")";
        if (search != "") search = search + "%20AND%20";
        search = search + searchany;
    }
    if (searchphr != "") {
        searchphr = searchphr.replace(/"/g,"");
        if (search != "") search = search + "%20AND%20";
        search = search + "%22" + searchphr + "%22";
    }
    if (searchnot != "") {
        searchnot = searchnot.replace(/ /g,"%20OR%20");
        if (search != "") search = search + "%20AND%20";
        search = search + "NOT%20(" + searchnot + ")";
    }
    window.open("/knowledge/knowledgeHome.apexp?search="+search);
}
</script>

	*/
}