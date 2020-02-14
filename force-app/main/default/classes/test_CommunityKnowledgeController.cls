@isTest (SeeAllData=true)
private class test_CommunityKnowledgeController {
	
	@isTest static void test_method_one() {

		pageReference pageRef = Page.community_MI_Knowledge; 
		community_KnowledgeController vfs = new community_KnowledgeController();
	    vfs.ResetAll();
	    vfs.getcategoryKeywordCustom();
	    vfs.refreshSearchResult();
	    vfs.getPrevRequired();
	    vfs.getNextRequired();
	    vfs.getCurrentPageNumber();
	    vfs.next();
	    vfs.previous();
	    vfs.IssueCat = 'Equation';
	    vfs.getcategoryKeywordCustom();
	    vfs.moduleCat = 'All';
	    vfs.getcategoryKeywordCustom();
	    vfs.LeadCat = 'datanet';
	    vfs.getcategoryKeywordCustom();    
	    vfs.ProductCat = 'All';
	    vfs.getcategoryKeywordCustom(); 
	    vfs.TreasuryCat = 'All';
	    vfs.getcategoryKeywordCustom();  
	    vfs.IssueCat = 'Equation';
	    vfs.searchString = 'test';
	    vfs.getcategoryKeywordCustom();
	    vfs.getfirstPage();
	    vfs.getlastRequired();
	    vfs.first();
	    vfs.Last();     
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}