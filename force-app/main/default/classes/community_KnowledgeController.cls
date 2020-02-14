public with sharing class community_KnowledgeController {

    public List<Community_Homepage_CMS__c> KnowledgeCMSContent {get; set;}
    public List<Community_Feature_Hyperlink__c> LeadContentLinks {get; set;}
    public Map<Id,Community_Feature_Hyperlink__c> contentLinks {get; set;}
    map<Id,RecordType> mapArticleType;
    public List<KnowledgeWrapper> KnowledgeArticles {get; set;}
    public List<KnowledgeWrapper> KnowledgeArticleRatings {get; set;}
    private KnowledgeWrapper KnowledgeObject;
    private KnowledgeWrapper KnowledgeRatings;
    public string GAUserId {get;set;}

    //Page Size
     private Static Final Integer PAGE_NUMBER = 10;
     public Map<String,integer> mapArticleRating {get;set;}
     public List<KnowledgeArticleVoteStat> lstKnowVotes{get;set;}
     public List<KnowledgeArticleVersion> articleList = new list<KnowledgeArticleVersion>();
     public String moduleCat{get;set;}
     public String IssueCat{get;set;}
     public String LeadCat{get;set;}
     public String ProductCat{get;set;}
     public String TreasuryCat{get;set;} 
     public string backLink{get;set;}
     public boolean showIntialLabel{get;set;}
     public integer noOfRecords{get;set;}
     //Search String used in ArticleList tag
     public String searchstring { get; set; }
     public String articleTypePick{get;set;}

     //Is new List reqd 
     private boolean isRefRequired = true;
     //Exclude filter criteria for UI only
     private static final String EXCLUDE_CRITERIA_FILTER  = 'All';
     
     //Keeps track of current page & max size of article list
     Integer currentPage = 1;
     Integer maxSize = 1;
     
     //Returns array of Category Groups
     public DataCategoryGroupInfo[] getDataCategoryGroupInfo() {
      return DataCategoryUtil.getInstance().getAllCategoryGroups();
     }

    public community_KnowledgeController() {
        GAUserId = UserInfo.getUserId();
        showIntialLabel = true;
        String qryString = 'SELECT Id, title, UrlName, KnowledgeArticleId,LastPublishedDate,LastModifiedById FROM KnowledgeArticleVersion WHERE ValidationStatus = \'Approved For Customers\' AND (PublishStatus = \'online\' and Language = \'en_US\') limit 100'; 
        getDescribeDataCategoryGroupStructureResults();
        ResetAll();
        articleList= Database.query(qryString);   
        maxSize = articleList.size();

        generateArticleScore(articleList);
        refreshSearchResult();   

        mapArticleType = new map<Id,RecordType>([select Id, Name from RecordType where sObjectType = 'Solution' and isActive = true]);
        

        //pull out the top 5 viewed and voted articles
        Map<Id,Decimal> ViewStatMap = New Map<Id, Decimal>();
        for (List<knowledgeArticleViewStat> kavStats : [SELECT parentId,normalizedScore from knowledgeArticleViewStat where  channel='AllChannels' order by normalizedScore desc LIMIT 5]) {
            for(knowledgeArticleViewStat kavStat : kavStats) {
                ViewStatMap.put(kavStat.parentId, kavStat.normalizedScore);
            }
        }
            
        Set<ID> ids = new Set<ID>();
        ids = ViewStatMap.keySet();
        KnowledgeArticles = New List<KnowledgeWrapper>();
                
        for(List<knowledgeArticleVersion> KAV : [SELECT Title,id,knowledgearticleId,articletype,lastpublisheddate,articlenumber,URLName FROM knowledgeArticleVersion WHERE PublishStatus = 'Online' AND ValidationStatus = 'Approved For Customers' AND  Language = 'en_US' AND knowledgearticleId In : ids]) {
            for(knowledgeArticleVersion knowledgeArticle : KAV){
                KnowledgeObject = New KnowledgeWrapper();
                KnowledgeObject.ArticleId = knowledgeArticle.knowledgearticleId;
                KnowledgeObject.ArticleViews = ViewStatMap.get(knowledgeArticle.knowledgearticleId);
                KnowledgeObject.LastPublishedDate = knowledgeArticle.lastpublisheddate;
                KnowledgeObject.Title = knowledgeArticle.Title;
                KnowledgeObject.ArticleNumber = knowledgeArticle.articlenumber;
                KnowledgeObject.ArticleType = knowledgeArticle.articletype;
                KnowledgeObject.ArticleURL = knowledgeArticle.knowledgearticleId;
                KnowledgeArticles.Add(KnowledgeObject);
            }
            
        }
        KnowledgeWrapper.sortBy = KnowledgeWrapper.SORT_BY.byViews;
        KnowledgeArticles.sort();
        
        Map<Id,Decimal> VoteStatMap = New Map<Id, Decimal>();
        
        for (List<knowledgeArticleVoteStat> kavRatings : [SELECT parentId,normalizedScore from knowledgeArticleVoteStat where channel='AllChannels'  order by normalizedScore desc LIMIT 5]) {
            for(knowledgeArticleVoteStat kavRating : kavRatings) {
                VoteStatMap.put(kavRating.parentId, kavRating.normalizedScore);
            }
        }
        
        Set<ID> RatingIds = new Set<ID>();
        RatingIds = VoteStatMap.keySet();
        KnowledgeArticleRatings = New List<KnowledgeWrapper>();
                
        for(List<knowledgeArticleVersion> KARating : [SELECT Title,id,knowledgearticleId,articletype,lastpublisheddate,articlenumber,URLName FROM knowledgeArticleVersion WHERE ValidationStatus = 'Approved For Customers' AND PublishStatus = 'Online' AND  Language = 'en_US' AND knowledgearticleId In : RatingIds]) {
            for(knowledgeArticleVersion knowledgeArticle : KARating){
                KnowledgeObject = New KnowledgeWrapper();
                KnowledgeObject.ArticleId = knowledgeArticle.knowledgearticleId;
                KnowledgeObject.ArticleRating = VoteStatMap.get(knowledgeArticle.knowledgearticleId);
                KnowledgeObject.LastPublishedDate = knowledgeArticle.lastpublisheddate;
                KnowledgeObject.Title = knowledgeArticle.Title;
                KnowledgeObject.ArticleNumber = knowledgeArticle.articlenumber;
                KnowledgeObject.ArticleType = knowledgeArticle.articletype;
                KnowledgeObject.ArticleURL = knowledgeArticle.knowledgearticleId;
                KnowledgeArticleRatings.Add(KnowledgeObject);
            }
            
        }
        KnowledgeWrapper.sortBy = KnowledgeWrapper.SORT_BY.byRating;
        KnowledgeArticleRatings.sort();
    }

  public void generateArticleScore(List<KnowledgeArticleVersion> lstArticles){
        Set<id> setKnowledgeId = new Set<id>();
        Map<id,id> mapTempData = new Map<id,id>();
        mapArticleRating = new Map<string,integer>();
        lstKnowVotes = new List<KnowledgeArticleVoteStat>();
        for(KnowledgeArticleVersion knwA :lstArticles){
             setKnowledgeId.add(knwA.KnowledgeArticleId);
         }
        lstKnowVotes = [select id, NormalizedScore , ParentId from KnowledgeArticleVoteStat where ParentId in : setKnowledgeId limit 50000];
        for(KnowledgeArticleVoteStat knwV:lstKnowVotes){
            if(mapArticleRating.get(string.valueOf(knwV.ParentId).subString(0,15)) == null){
                        mapArticleRating.put(string.valueOf(knwV.ParentId).subString(0,15),integer.valueOF(knwV.NormalizedScore));
            }else{
                    if(mapArticleRating.get(string.valueOf(knwV.ParentId).subString(0,15)) < integer.valueOF(knwV.NormalizedScore)){
                        mapArticleRating.put(string.valueOf(knwV.ParentId).subString(0,15),integer.valueOF(knwV.NormalizedScore));
                    }
            }
        }

        lstKnowVotes.clear();
        
     }
     // Action call when the new list needs to be fetched
     public PageReference refreshSearchResult() {
      maxSize = currentPage = 1;
      return null;
     }

     // Returns whether we need to see previous button or not
     public boolean getPrevRequired() {
      return currentPage > 1;
     }

    // Returns whether we need to see next button or not
         public boolean getNextRequired() {
      return currentPage * PAGE_NUMBER < maxSize;
     }
     // First Page
        public Boolean getfirstPage(){
            return currentPage > 1;
        }
    
     // Last Page
    public boolean getlastRequired() {
      return currentPage * PAGE_NUMBER < maxSize;
     }   
      
    //Returns current page number 
     public Decimal getCurrentPageNumber() {
      return this.currentPage;
      }

    //action for next click
     public PageReference next() {
      if(maxSize > this.currentPage * PAGE_NUMBER) {
       this.currentPage = this.currentPage + 1;
      }
       return null;
     } 
     // First Page button ACt
     public PageReference first(){
         this.currentPage =  1;
         return null;
     }
     // Last Page button ACt
     public PageReference Last(){
         this.currentPage =  (maxSize / PAGE_NUMBER) + 1;
         return null;
     }   
     
    //action for previous click
     public PageReference previous() {        
      if(this.currentPage > 1)
       this.currentPage = this.currentPage - 1;
      return null;
     }
     
     //
        public List<selectOption> getArticleTypes() {
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('','No Filter'));   
        options.add(new selectOption('Troubleshooting__kav','Troubleshooting'));   
        options.add(new selectOption('Documentation__kav','Documentation'));       
        return options;
        }
        
        public List<SelectOption> lstModuleOptions {get;set;}
        public List<SelectOption> lstIssueTypeOptions {get;set;}
        public List<SelectOption> lstLeadModuleOptions {get;set;}
        public List<SelectOption> lstProductOptions {get;set;}
        public List<SelectOption> lstTresuaryOptions {get;set;}

        
        public String city{get;set;}
        public String moduleName{get;set;}


        public List<DescribeDataCategoryGroupStructureResult> 
        getDescribeDataCategoryGroupStructureResults(){
          List<DescribeDataCategoryGroupResult> describeCategoryResult;
          List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
         lstModuleOptions = new List<SelectOption> (); 
         lstModuleOptions.add(new SelectOption('NoFilter','No Filter'));
         lstIssueTypeOptions = new List<SelectOption> (); 
         lstIssueTypeOptions.add(new SelectOption('NoFilter','No Filter'));
         lstLeadModuleOptions = new List<SelectOption> ();
         lstLeadModuleOptions.add(new SelectOption('NoFilter','No Filter'));
         lstProductOptions = new List<SelectOption>  ();
         lstProductOptions.add(new SelectOption('NoFilter','No Filter'));
         lstTresuaryOptions = new List<SelectOption>  ();
         lstTresuaryOptions.add(new SelectOption('NoFilter','No Filter'));      
          try {
             //Making the call to the describeDataCategoryGroups to
             //get the list of category groups associated
             List<String> objType = new List<String>();
             objType.add('KnowledgeArticleVersion');
             describeCategoryResult = Schema.describeDataCategoryGroups(objType);
             
             //Creating a list of pair objects to use as a parameter
             //for the describe call
             List<DataCategoryGroupSobjectTypePair> pairs = 
                new List<DataCategoryGroupSobjectTypePair>();
             
             //Looping throught the first describe result to create
             //the list of pairs for the second describe call
             for(DescribeDataCategoryGroupResult singleResult : 
             describeCategoryResult){
                DataCategoryGroupSobjectTypePair p =
                   new DataCategoryGroupSobjectTypePair();
                p.setSobject(singleResult.getSobject());
                p.setDataCategoryGroupName(singleResult.getName());
                pairs.add(p);
             }
             
             //describeDataCategoryGroupStructures()
             describeCategoryStructureResult = 
                Schema.describeDataCategoryGroupStructures(pairs, false);

             //Getting data from the result
             for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
                //Get name of the associated Sobject
                singleResult.getSobject();

                //Get the name of the data category group
                singleResult.getName();

                //Get the name of the data category group
                singleResult.getLabel();

                //Get the description of the data category group
                singleResult.getDescription();
                    //Get the top level categories
                DataCategory [] toplevelCategories = 
                   singleResult.getTopCategories();
                
                //Recursively get all the categories
                List<DataCategory> allCategories = 
                   getAllCategories(toplevelCategories);

                //take out 'All' category from allcategories for better processing
                List<DataCategory> categoryToIterate = new List<DataCategory>();

                for(DataCategory category: allCategories){
                   if(category.getName().equalsIgnoreCase('All')){
                      categoryToIterate.add(category);
                   }
                }
                
                displayCategories(categoryToIterate, '',singleResult.getName());            



                
             }
          } catch (Exception e){
          }
          return describeCategoryStructureResult;
        }

        private void displayCategories(List<DataCategory> allCategories, String parentName,String moduleType){
         for(DataCategory category : allCategories) {

            if(moduleType == 'Module'){
                if(lstModuleOptions == null || lstModuleOptions.isEmpty()){
                    lstModuleOptions = new List<SelectOption>();
                    lstModuleOptions.add(new SelectOption(category.getName(),category.getLabel()));

                }else{
                                lstModuleOptions.add(new SelectOption(category.getName(),category.getLabel()));

                }
            }
            if(moduleType == 'Issue_Type'){
                if(lstIssueTypeOptions == null || lstIssueTypeOptions.isEmpty()){
                lstIssueTypeOptions  = new List<SelectOption>();    
                lstIssueTypeOptions.add(new SelectOption(category.getName(),category.getLabel()));              
                }else{
                lstIssueTypeOptions.add(new SelectOption(category.getName(),category.getLabel()));              
                }
            }
            if(moduleType == 'Lending_Modules'){
                if(lstLeadModuleOptions == null || lstLeadModuleOptions.isEmpty()){
                    lstLeadModuleOptions = new List<SelectOption>();    
                    lstLeadModuleOptions.add(new SelectOption(category.getName(),category.getLabel()));
                }else{
                    lstLeadModuleOptions.add(new SelectOption(category.getName(),category.getLabel()));
                    
                }
            }
            if(moduleType == 'Product'){
                if(lstProductOptions == null || lstProductOptions.isEmpty()){
                lstProductOptions= new List<SelectOption>();
                lstProductOptions.add(new SelectOption(category.getName(),category.getLabel()));                
                }else{
                lstProductOptions.add(new SelectOption(category.getName(),category.getLabel()));                
                }
            }
            if(moduleType == 'Treasury_and_Capital_Markets_Modules'){
                if(lstTresuaryOptions == null || lstTresuaryOptions.isEmpty()){
                lstTresuaryOptions =  new List<SelectOption>();
                lstTresuaryOptions.add(new SelectOption(category.getName(),category.getLabel()));               
                }else{
                lstTresuaryOptions.add(new SelectOption(category.getName(),category.getLabel()));               
                }
            }           
               System.debug(category.getName() +' 777777777777777777777- '+ parentName);

           DataCategory[] childs = category.getChildCategories();
           if(!childs.isEmpty()){
             displayCategories(childs, category.getName(),moduleType);
           }
           
         }
        }

     public String getcategoryKeywordCustom(){
        String cat = '';    
        String categoryFilter = '';
        String articleFilter = '';
        String limitData = '';
        
        if(Test.isRunningTest()){
            limitData = 'limit 100';
        }else{
            limitData = 'limit 50000';
        }

            if(moduleCat != null && moduleCat != 'NoFilter'){
                cat= 'Module:'+moduleCat;
                categoryFilter = 'Module__c ABOVE_OR_BELOW ' + moduleCat  +'__c';
        }
        if(IssueCat != null && IssueCat != 'NoFilter'){
            if(cat != null && cat != ''){
                cat= cat+ ',Issue_Type:'+IssueCat;
                categoryFilter = categoryFilter + ' AND Issue_Type__c ABOVE_OR_BELOW ' + IssueCat +'__c';
            }else{
                cat= 'Issue_Type:'+IssueCat;
                categoryFilter = 'Issue_Type__c ABOVE_OR_BELOW ' + IssueCat  +'__c';
            }
                
        }
        if(LeadCat != null && LeadCat != 'NoFilter'){
            if(cat != null && cat != ''){
                cat= cat+ ',Lending_Modules:'+LeadCat;
                categoryFilter = categoryFilter + ' AND Lending_Modules__c ABOVE_OR_BELOW ' + leadCat +'__c';           
            }else{
                cat= 'Lending_Modules:'+LeadCat;
                categoryFilter = 'Lending_Modules__c ABOVE_OR_BELOW ' + leadCat  +'__c';
            }
        }
        if(ProductCat != null && ProductCat != 'NoFilter'){
            if(cat != null && cat != ''){
                cat= cat+ ',Product:'+ProductCat;
                categoryFilter = categoryFilter + ' AND Product__c ABOVE_OR_BELOW ' + ProductCat +'__c';            
            }else{
                cat= 'Product:'+ProductCat;
                categoryFilter = 'Product__c ABOVE_OR_BELOW ' + ProductCat  +'__c';            
            }
        }
        if(TreasuryCat != null && TreasuryCat != 'NoFilter'){
            if(cat != null && cat != ''){
                cat= cat+ ',Treasury_and_Capital_Markets_Modules:'+TreasuryCat;
                categoryFilter = categoryFilter + ' AND Treasury_and_Capital_Markets_Modules__c ABOVE_OR_BELOW ' + TreasuryCat +'__c';          
            }else{
                cat= 'Treasury_and_Capital_Markets_Modules:'+TreasuryCat;
                categoryFilter = 'Treasury_and_Capital_Markets_Modules__c ABOVE_OR_BELOW ' + TreasuryCat  +'__c';           
            }
        }
        if(articleTypePick != null && articleTypePick != ''){
                articleFilter = ' and articleType =  \''+String.escapeSingleQuotes(articleTypePick)+'\'';
        }else{          
             articleFilter = ''; 
        }
    try {
       if(categoryFilter.length()>0) {
        if(searchString != null && searchString.length() >0 ) {
        String searchquery = 'FIND \'' + searchString + '*\'IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, title, UrlName, LastPublishedDate,LastModifiedById, KnowledgeArticleId, ArticleNumber where ValidationStatus = \'Approved For Customers\' AND PublishStatus =\'online\' and Language = \'en_US\') WITH DATA CATEGORY '+categoryFilter + ' limit 2000';
        if(articleFilter != null && articleFilter != ''){
        searchquery = 'FIND \'' + searchString + '*\'IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, title, UrlName, LastPublishedDate,LastModifiedById, KnowledgeArticleId, ArticleNumber where ValidationStatus = \'Approved For Customers\' AND PublishStatus =\'online\' and Language = \'en_US\' '+articleFilter+') WITH DATA CATEGORY '+categoryFilter + ' Limit 2000';            
        }
         List<List<SObject>>searchList = search.query(searchquery);
         articleList = (List<KnowledgeArticleVersion>)searchList[0];
         generateArticleScore(articleList);
         maxSize = articleList.size() ;
         noOfRecords = maxSize;
        } else {
        String qryString = 'SELECT Id, title, UrlName, KnowledgeArticleId,LastPublishedDate,LastModifiedById FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'en_US\') WITH DATA CATEGORY '+categoryFilter + ' '+limitData ;
        if(articleFilter != null && articleFilter != ''){
         qryString = 'SELECT Id, title, UrlName, KnowledgeArticleId,LastPublishedDate,LastModifiedById FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'en_US\' '+articleFilter+') WITH DATA CATEGORY '+categoryFilter + '  '+limitData ;     
         }
        articleList= Database.query(qryString);
         generateArticleScore(articleList);  
         maxSize = articleList.size() ;
         noOfRecords = maxSize;
         articleList.clear();
        }
       }  else if(searchString != null && searchString.length() >0 ){
        String searchquery = 'FIND \'' + searchString + '*\'IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, title, UrlName, LastPublishedDate,LastModifiedById where ValidationStatus = \'Approved For Customers\' AND PublishStatus =\'online\' and Language = \'en_US\') limit 2000';
        if(articleFilter != null && articleFilter != ''){
         searchquery = 'FIND \'' + searchString + '*\'IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, title, UrlName, LastPublishedDate,LastModifiedById where ValidationStatus = \'Approved For Customers\' AND PublishStatus =\'online\' and Language = \'en_US\' '+articleFilter+')  limit 2000';
        }
        List<List<SObject>>searchList = search.query(searchquery);
         List<KnowledgeArticleVersion> articleList = (List<KnowledgeArticleVersion>)searchList[0];
         maxSize = articleList.size() ;
        noOfRecords = maxSize;       
         articleList.clear();
        }else {
       String qryString = 'SELECT Id, title, UrlName, KnowledgeArticleId, LastPublishedDate,LastModifiedById FROM KnowledgeArticleVersion WHERE ValidationStatus = \'Approved For Customers\' AND (PublishStatus = \'online\' and Language = \'en_US\')  '+limitData;
        if(articleFilter != null && articleFilter != ''){
        qryString = 'SELECT Id, title, UrlName, KnowledgeArticleId, LastPublishedDate,LastModifiedById FROM KnowledgeArticleVersion WHERE ValidationStatus = \'Approved For Customers\' AND (PublishStatus = \'online\' and Language = \'en_US\''+articleFilter+') '+limitData;
        }
       articleList= Database.query(qryString);
         generateArticleScore(articleList);  
         maxSize = articleList.size() ;
         noOfRecords = maxSize;
         articleList.clear();

       }        
       } catch(Exception e) {
        Apexpages.addmessages( e );
      } 
        if(cat == '' && (searchString != null || searchString != '')){
           //cat = 'Issue_Type:Equation';
        }else if(cat == '' )
        {
            cat = 'Issue_Type:Equation';
              String qryString = 'SELECT Id, title, UrlName, KnowledgeArticleId,LastPublishedDate,LastModifiedById FROM KnowledgeArticleVersion WHERE ValidationStatus = \'Approved For Customers\' AND (PublishStatus = \'online\' and Language = \'en_US\')  WITH DATA CATEGORY Issue_Type__c below Equation__c'; 
        articleList= Database.query(qryString);   
         maxSize = articleList.size() ;     
        noOfRecords = maxSize;       
        generateArticleScore(articleList);
        }
        system.debug('***********************************'+cat);
        if((cat != '' || searchString != '')){
            showIntialLabel = false;
        }else{
            showIntialLabel = true;
        }
        return cat;
        }
        
        public void ResetAll(){
            moduleCat = 'NoFilter';
            IssueCat  = 'NoFilter';
            leadCat = 'NoFilter';
            ProductCat = 'NoFilter';
            TreasuryCat = 'NoFilter';
            searchString = '';
            articleTypePick = '';
        }
        private DataCategory[] getAllCategories(DataCategory [] categories){
          if(categories.isEmpty()){
             return new DataCategory[]{};
          } else {
             DataCategory [] categoriesClone = categories.clone();
             DataCategory category = categoriesClone[0];
             DataCategory[] allCategories = new DataCategory[]{category};
             categoriesClone.remove(0);
             categoriesClone.addAll(category.getChildCategories());
             allCategories.addAll(getAllCategories(categoriesClone));
             return allCategories;
          }
        }    
}