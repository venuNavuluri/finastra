public with sharing class ArticleController {	
    public Boolean hasMoreValues { get; set; }
    
    public String SearchString { get; private set; }
    public String ArticleTypeFilter { get; private set; }
    public String CategoryFilter { get; private set; }
         
	public Integer PageNumber { get; private set; }
    public Integer PageSize { get; private set; }

    public Boolean HasMore { get; }
    
    private Integer maxSize  = 0;

	public ArticleController() {	
		SearchString = ApexPages.currentPage().getParameters().get('search');
        ArticleTypeFilter = ApexPages.currentPage().getParameters().get('articleTypes');
        CategoryFilter = ApexPages.currentPage().getParameters().get('category'); 
               
        PageNumber = TryParseToInteger(ApexPages.currentPage().getParameters().get('pageNumber'));
        PageSize = 15;
	}
    
    
    
    public Boolean RenderPreviousButton {
        get {
            return PageNumber > 1;
        }
    }
 
    public PageReference Previous() {
        PageReference pr = ApexPages.currentPage();
        pr.getParameters().put('pageNumber', String.valueOf(PageNumber--));
        return pr;
    }

    public PageReference Next() {
        PageReference pr = ApexPages.currentPage();
        pr.getParameters().put('pageNumber', String.valueOf(PageNumber++));
        return pr;
    }

	private Integer TryParseToInteger(string s) {
		Integer parseInt;
		try {
			parseInt = Integer.valueOf(s);
		} catch(Exception ex) {
			parseInt = 1;
		}
		
		return parseInt;
    }
}