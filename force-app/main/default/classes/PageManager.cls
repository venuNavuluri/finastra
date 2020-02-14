public class PageManager
{
    
    /********** Constatns **********/
    // Default value for numberOfRowsPerPage
    private static final integer DEFAULT_NUMBER_OF_ROWS_PER_PAGE = 10;
    
    /********** Public Properties / Variables **********/
    // Number of rows to display per page (provided by the constructor or default value)
    public integer numberOfRowsPerPage {get;set;}
    // Page Number (0-based index (display is 1-based))
    public integer page {get;set;}
    // a list of Page Numbers (1-based index as displayed). Updated when numberOfRows is set
    public List<integer> pageList {get;set;}
    // the number of the entire rows. Once this is set, this can calculate pageList and start/endIndex
    public integer numberOfRows {get; 
        set{
            numberOfRows = value;
            integer nop = 0;
            if(numberOfRowsPerPage > 0){
               nop = (Math.ceil(
                    decimal.valueOf(value).doubleValue() 
                        / decimal.valueOf(numberOfRowsPerPage).doubleValue())).intValue();
            }
            pageList.clear();
            for(integer i=1;i<=nop;i++) pageList.add(i);
            // Added by S.Sakoda
            // Even there is no record, it should show Page 1.
            if(pageList.size() == 0) pageList.add(1);
            //page = 0;
        }
    }
    // The array index in the entire rows for the first row in the page (included)
    public integer startIndex {
        get {
            return page * numberOfRowsPerPage;
        }
    }
    // The array index in the entire rows for the last row in the page (excluded),
    // which means that this index is not included in the page
    // (this will be for the first row of the next page)
    public integer endIndex {
        
        get {
            System.debug('numberOfRows =' + numberOfRows);
            System.debug('numberOfRowsPerPage =' + numberOfRowsPerPage);
            return Math.min(numberOfRows, (page+1)*numberOfRowsPerPage);
        }
    }

    // In case that the component needs a picklist for pageList
    public List<SelectOption> pageOptions {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for(integer i=0;i<pageList.size();i++) options.add(new SelectOption(''+(pageList[i]-1), ''+(pageList[i])));
            return options;
        }
    }    

    /********** Constructors **********/

   
    public PageManager(){
        init();
    }

   
    public PageManager(integer numberOfRowsPerPage){
        init();
        this.numberOfRowsPerPage = numberOfRowsPerPage;
    }    
    /********** Private Methods  **********/   
    private void init(){
        page = 0;
        pageList = new List<integer>();
        this.numberOfRowsPerPage = DEFAULT_NUMBER_OF_ROWS_PER_PAGE;
        this.numberOfRows = 0;
    }    
}