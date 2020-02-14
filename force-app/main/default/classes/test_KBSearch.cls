@isTest
private class test_KBSearch {
	
	static testmethod void test_SolutionSearch()
	{
		//Setup test data
		RecordType rt1 = [select Id, Name from RecordType where sObjectType = 'Solution' LIMIT 1];
		RecordType rt2 = [select Id, Name from RecordType where sObjectType = 'Solution' and (Not Id = :rt1.Id) LIMIT 1];
		
		Solution slnSolution = TestUtility.sampleSolution();
		slnSolution.Status = 'Approved';
		slnSolution.RecordTypeId = rt1.Id;
		slnSolution.SolutionNote = 'Test Solution Note for test class solution 1.';
		
		Solution slnFAQ = TestUtility.sampleSolution();
		slnFAQ.Status = 'Approved';
		slnFAQ.RecordTypeId = rt2.Id;
		slnFAQ.SolutionNote = 'Test Solution Note for test class solution 2 with additional words.';
		
		//Run the test
		Test.startTest();
			
			insert slnSolution;
			insert slnFAQ;
			
			KBSearchController kbc = new KBSearchController();
			
			//Simulate nothing being entered for search criteria and no article types being selected
			list<String> searchCriteria = new list<String>();
			searchCriteria.add('');		//searchALL
			searchCriteria.add('');		//searchANY
			searchCriteria.add('');		//searchPHRASE
			searchCriteria.add('');		//searchNOT
			
			list<String> articleNames = new list<string>();
			list<String> articleSelects = new list<string>();
			list<String> catIds = new list<string>();
			
			string result1 = KBSearchController.runSearchCases(searchCriteria, articleNames, articleSelects, catIds);
			list<ApexPages.Message> pg1Messages = ApexPages.getMessages();
			
			//Simiulate a successful search that returns the two test records
			searchCriteria.clear();
			searchCriteria.add('Solution class');		//searchALL
			searchCriteria.add('');						//searchANY
			searchCriteria.add('');						//searchPHRASE
			searchCriteria.add('');						//searchNOT
			
			articleNames.clear();
			articleSelects.clear();
			for(integer x = 0; x < kbc.lArticleTypes.size();x++){
				articleNames.add(kbc.lArticleTypes.get(x).itemId);
				articleSelects.add('true');
			}
			
			string result2 = KBSearchController.runSearchCases(searchCriteria, articleNames, articleSelects, catIds);
			//PageReference pg2 = kbc.SearchCases();
			//integer searchResultsSize = kbc.resultSize;
			//list<Solution> searchResults = kbc.listSearchResults;
			
			PageReference pg3 = kbc.ResetFilters();
			
			PageReference pg4 = kbc.ClearSearch();
			
			//PageReference pg5 = kbc.ChangeSearch();
			
		Test.stopTest();
		
		//Verify the results
		system.assertEquals(null,result1);
		system.assert(result2.contains('ui/solution/SolutionSearchPage'));
	}

}