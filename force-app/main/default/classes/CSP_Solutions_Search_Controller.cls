public class CSP_Solutions_Search_Controller {        
    public List<SelectOption> LendingModules { get; private set; }
    public List<SelectOption> ProductFamilies { get; private set; }
    public List<SelectOption> Products { get; private set; }
    public List<SelectOption> TreasuryCapitalMarkets { get; private set; }
    public List<SelectOption> IssueTypes { get; private set; }
    public List<SelectOption> CoreBankingModules { get; private set; }
    
    public CSP_Solutions_Search_Controller(ArticleController controller) {
        this();
    }
    
    public CSP_Solutions_Search_Controller() {
        Init();
    }
            
    public List<Schema.DescribeDataCategoryGroupStructureResult> GetCategories(List<Schema.DescribeDataCategoryGroupResult> describeCategoryResult, string listType) {
        List<Schema.DataCategoryGroupSobjectTypePair> pairs = new List<Schema.DataCategoryGroupSobjectTypePair>();
                
        for(Schema.DescribeDataCategoryGroupResult s : describeCategoryResult) {
            if(s.getName() == listType) {
                Schema.DataCategoryGroupSobjectTypePair thisPair = new Schema.DataCategoryGroupSobjectTypePair();
                thisPair.sObject = s.getsObject();
                thisPair.dataCategoryGroupName = s.getName();
                pairs.add(thisPair);
            }
        }        
        
        return Schema.describeDataCategoryGroupStructures(pairs, false);   
    }
    
    public List<SelectOption> GetOptions(List<Schema.DescribeDataCategoryGroupStructureResult> categories) {
        List<SelectOption> options = new List<SelectOption>();
                
        for(Schema.DescribeDataCategoryGroupStructureResult category : categories) {
        	options.add(new SelectOption(category.getName(), TabValue + category.getLabel()));
            
            if(category.topCategories.size() > 0) {
                TabIndex++;
                options.addAll(GetOptions(category.topCategories));   
                TabIndex--;
            }
        }
        
        return options;
    }
    
    public List<SelectOption> GetOptions(List<DataCategory> categories) {        
        List<SelectOption> options = new List<SelectOption>();
        
        for(DataCategory category : categories) {
            options.add(new SelectOption(category.getName(), TabValue + category.getLabel()));
            
            if(category.childCategories.size() > 0) {
                TabIndex++;
                options.addAll(GetOptions(category.childCategories));                
                TabIndex--;
            }        
        }
        
        return options;
    }
    
    private Integer TabIndex = 0;
    private String TabValue {
        get {
            String tempTabValue = '';
            for(Integer i=0; i<TabIndex; i++) {
                tempTabValue += '&nbsp;';
            }
            
            return tempTabValue;
        }
    }
    
    private void Init() {
        List<Schema.DescribeDataCategoryGroupResult> describeCategoryResult = GetCategoryGroupResult('KnowledgeArticleVersion');
                
        Products = GetSelectOptionsForListType('Product', describeCategoryResult);
        LendingModules = GetSelectOptionsForListType('Lending_Modules', describeCategoryResult);
        ProductFamilies = GetSelectOptionsForListType('Product_Family', describeCategoryResult);
        TreasuryCapitalMarkets = GetSelectOptionsForListType('Treasury_and_Capital_Markets_Modules', describeCategoryResult);
        IssueTypes = GetSelectOptionsForListType('Issue_Type', describeCategoryResult);
        CoreBankingModules = GetSelectOptionsForListType('Module', describeCategoryResult);
    }
    
    private List<SelectOption> GetSelectOptionsForListType(String listType, List<Schema.DescribeDataCategoryGroupResult> describeCategoryResult) {
        List<Schema.DescribeDataCategoryGroupStructureResult> categories = GetCategories(describeCategoryResult, listType);
        return GetOptions(categories);
    }
    
    private List<Schema.DescribeDataCategoryGroupResult> GetCategoryGroupResult(String sObjectType) {
        List<String> objects = new List<String>();
        objects.add(sObjectType);
        
        return Schema.describeDataCategoryGroups(objects);        
    }
}