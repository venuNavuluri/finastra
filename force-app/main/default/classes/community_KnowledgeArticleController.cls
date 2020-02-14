public with sharing class community_KnowledgeArticleController {
    public string ArticleId {get;set;}
    public string ArticleTitle {get;set;}
    public string ArticleNumber {get;set;}
    public string ProductName {get;set;}
    public string GAUserId {get;set;}
    public KnowledgeArticleDetailsWrapper articleDetails {get;set;}
    public boolean showAdditionalProductVersion {get;set;}
    public boolean showAdditionalProductComponent {get;set;}
    public boolean showSymptom {get;set;}
    public boolean showResolution {get;set;}
    public boolean showDownload1 {get;set;}
    public boolean showDownload2 {get;set;}
    public boolean showDownload3 {get;set;}
    public boolean showDownload4 {get;set;}
    public boolean showDownload5 {get;set;}
    public string Comments {get;set;}
    public string strIssues {get;set;}
    public string strRating {get;set;}
    public Boolean initialised{get; set;}
    public Boolean showTroubleDownloads {get;set;}
    public Boolean showDocumentationDownloads {get;set;}

    public community_KnowledgeArticleController() {
        if(ApexPages.currentPage().getParameters().get('id') != '' && ApexPages.currentPage().getParameters().get('id') != null) {
            string urlvalue=Apexpages.currentPage().getUrl();
            showDocumentationDownloads = false;
            showTroubleDownloads = false;
            showDownload1 = false;
            showDownload2 = false;
            showDownload3 = false;
            showDownload4 = false;
            showDownload5 = false;
            showAdditionalProductVersion = true;
            showAdditionalProductComponent = true;
            showSymptom = false;
            showResolution = false;
            GAUserId = UserInfo.getUserId();
            articleDetails = New KnowledgeArticleDetailsWrapper();
            string articleType = '';
            ArticleID = ApexPages.currentPage().getParameters().get('id');
            if(ArticleID != '' && ArticleID !=null) {
                articleType = [SELECT ArticleType FROM KnowledgeArticleVersion WHERE  KnowledgeArticleId =: ArticleID AND (PublishStatus = 'online' and Language = 'en_US') limit 100].ArticleType;
            }
            if(articleType == 'Documentation__kav') {
                showDocumentationDownloads = true;
                    List<Documentation__kav> lstDocumentation = New List<Documentation__kav>([SELECT Id,title, description__c, product__c, product_version__c,attachment1__Name__s, attachment2__Name__s, attachment3__Name__s,
                                                                                                attachment4__Name__s, attachment5__Name__s, Attachment1__Body__s, Attachment2__Body__s, Attachment3__Body__s, Attachment4__Body__s,
                                                                                                Attachment5__Body__s, summary, versionNumber, ArticleNumber, product_Component__c, additional_product_component__c,
                                                                                                LastModifiedDate, Rolled_in_at__c, UrlName
                                                                                                FROM Documentation__kav WHERE KnowledgeArticleId=:ArticleID 
                                                                                               AND PublishStatus = 'online' AND Language = 'en_US']);
                    for(Documentation__kav docKav : lstDocumentation) {
                        system.debug('@@@@@@ '+ docKav.Title);
                        articleDetails.Id = docKav.Id;
                        articleDetails.URLName = docKav.URLName;
                        articleDetails.Title = docKav.Title;
                        ArticleTitle = docKav.Title;
                        articleDetails.versionNumber = docKav.versionNumber;
                        articleDetails.description = docKav.description__c;
                        articleDetails.LastModifiedDate = docKav.LastModifiedDate;
                        articleDetails.ArticleNumber = docKav.ArticleNumber;
                        ArticleNumber = docKav.ArticleNumber;
                        articleDetails.AdditionProductComponent = docKav.additional_product_component__c;
                        articleDetails.AdditionProductVersion = docKav.Rolled_in_at__c;
                        articleDetails.product = docKav.product__c;
                        ProductName = docKav.product__c;
                        articleDetails.ProductVersion = docKav.product_version__c;
                        articleDetails.ProductComponent = docKav.product_Component__c;
                        articleDetails.AttachmentName1 = docKav.attachment1__Name__s;
                        articleDetails.AttachmentName2 = docKav.attachment2__Name__s;
                        articleDetails.AttachmentName3 = docKav.attachment3__Name__s;
                        articleDetails.AttachmentName4 = docKav.attachment4__Name__s;
                        articleDetails.AttachmentName5 = docKav.attachment5__Name__s;
                        articleDetails.Attachment1 = docKav.attachment1__Body__s;
                        articleDetails.Attachment2 = docKav.attachment2__Body__s;
                        articleDetails.Attachment3 = docKav.attachment3__Body__s;
                        articleDetails.Attachment4 = docKav.attachment4__Body__s;
                        articleDetails.Attachment5 = docKav.attachment5__Body__s;
                    }

                } else {
                    showSymptom = true;
                    showResolution = true;
                    showTroubleDownloads = true;
                    List<Troubleshooting__kav> lstTroubleShooting = New List<Troubleshooting__kav>([SELECT title, description__c, product__c, product_version__c,attachment1__Name__s, attachment2__Name__s, attachment3__Name__s,
                                                                                                attachment4__Name__s, attachment5__Name__s, Attachment1__Body__s, Attachment2__Body__s, Attachment3__Body__s, Attachment4__Body__s,
                                                                                                Attachment5__Body__s, summary, versionNumber, ArticleNumber, product_Component__c, additional_product_component__c,
                                                                                                LastModifiedDate, Resolution__c, Rolled_in_at__c, symptom__c, urlName
                                                                                                FROM Troubleshooting__kav WHERE KnowledgeArticleId=:ArticleID 
                                                                                                AND PublishStatus = 'online' AND Language = 'en_US']);
                    for(Troubleshooting__kav TroubleKav : lstTroubleShooting) {
                        articleDetails.Id = TroubleKav.Id;
                        articleDetails.Title = TroubleKav.Title;
                        ArticleTitle = TroubleKav.Title;
                        articleDetails.UrlName = TroubleKav.URLName;
                        articleDetails.versionNumber = TroubleKav.versionNumber;
                        articleDetails.description = TroubleKav.description__c;
                        articleDetails.symptom = TroubleKav.symptom__c;
                        articleDetails.LastModifiedDate = TroubleKav.LastModifiedDate;
                        articleDetails.ArticleNumber = TroubleKav.ArticleNumber;
                        ArticleNumber = TroubleKav.ArticleNumber;
                        articleDetails.AdditionProductComponent = TroubleKav.additional_product_component__c;
                        articleDetails.AdditionProductVersion = TroubleKav.Rolled_in_at__c;
                        articleDetails.product = TroubleKav.product__c;
                        ProductName = TroubleKav.product__c;
                        articleDetails.ProductVersion = TroubleKav.product_version__c;
                        articleDetails.ProductComponent = TroubleKav.product_Component__c;
                        articleDetails.Resolution = TroubleKav.resolution__c;
                        articleDetails.AttachmentName1 = TroubleKav.attachment1__Name__s;
                        articleDetails.AttachmentName2 = TroubleKav.attachment2__Name__s;
                        articleDetails.AttachmentName3 = TroubleKav.attachment3__Name__s;
                        articleDetails.AttachmentName4 = TroubleKav.attachment4__Name__s;
                        articleDetails.AttachmentName5 = TroubleKav.attachment5__Name__s;
                        articleDetails.Attachment1 = TroubleKav.attachment1__Body__s;
                        articleDetails.Attachment2 = TroubleKav.attachment2__Body__s;
                        articleDetails.Attachment3 = TroubleKav.attachment3__Body__s;
                        articleDetails.Attachment4 = TroubleKav.attachment4__Body__s;
                        articleDetails.Attachment5 = TroubleKav.attachment5__Body__s;
                    }
                }
                //system.debug('@@@@@@ ' + articleDetails.Attachment1.size());
                system.debug('@@@@@@ ' + articleDetails.Attachment2);
                if (articleDetails.AdditionProductComponent =='' || articleDetails.AdditionProductComponent == null) {
                    showAdditionalProductComponent = false;
                }
                if (articleDetails.AdditionProductVersion =='' || articleDetails.AdditionProductVersion == null) {
                    showAdditionalProductVersion = false;
                }
                if (articleDetails.Attachment1 != null){
                    
                    showDownload1 = true;
                }
                if (articleDetails.Attachment2 != null){
                    showDownload2 = true;
                }
                if (articleDetails.Attachment3 != null){
                    showDownload3 = true;
                }
                if (articleDetails.Attachment4 != null){
                    showDownload4 = true;
                }
                if (articleDetails.Attachment5 != null){
                    showDownload5 = true;
                }
                system.debug('@@@@@@ ' + showDownload1);
                initialised=false;
        }
        

    }

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No')); return options;
    }

    public List<SelectOption> getRatings() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1','1'));
        options.add(new SelectOption('2','2'));
        options.add(new SelectOption('3','3'));
        options.add(new SelectOption('4','4')); return options;
    }


    public pageReference submit() {
        Date myDate = Date.today();
        //string ArticleTitle SELECT ArticleType FROM KnowledgeArticleVersion WHERE  KnowledgeArticleId =: ArticleID AND (PublishStatus = 'online' and Language = 'en_US') limit 100]
        User user;
        user = [SELECT contact.accountId From User where Id = :UserInfo.getUserId() LIMIT 1];

        CommunityArticleComment__c articleComment = New CommunityArticleComment__c();
        articleComment.Comment__c = comments;
        try{
                 articleComment.ArticleRating__c = Integer.valueOf(strRating);
            } catch (Exception e) {
                 articleComment.ArticleRating__c = 1;
            }
       
        articleComment.CommentDate__c = myDate;
        articleComment.KnowledgeArticleId__c = ArticleID;
        articleComment.KnowledgeArticleTitle__c = ArticleTitle;
        articleComment.account__c = user.contact.accountId;
        articleComment.ProductName__c = ProductName;
        if(strIssues == 'Yes') {
            articleComment.IssueResolved__c = true;
        } else {
            articleComment.IssueResolved__c = false;
        }
        
        articleComment.UserId__c = UserInfo.getUserId();
        articleComment.articleNumber__c = ArticleNumber;
        insert articleComment;

        PageReference pageRef = new PageReference('/apex/community_MI_Knowledge?sfdc.tabName=01r20000000QijY');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void SaveUserViews() {
        DateTime myDateTime = DateTime.now();
       CommunityArticleView__c articleViewObj = New CommunityArticleView__c();
       articleViewObj.ArticleProduct__c = articleDetails.Product;
       articleViewObj.ArticleTitle__c = articleDetails.title;
       articleViewObj.ArticleURLName__c = articleDetails.URLName;
       articleViewObj.DateTimeViewed__c  = myDateTime;
       articleViewObj.KnowledgeArticleId__c = articleDetails.Id;
       articleViewObj.UserId__c = UserInfo.getUserId();
       articleViewObj.articleNumber__c = articleDetails.ArticleNumber;
       try {
        insert articleViewObj;
        initialised=true;
       } catch(exception e){
            system.debug('@@@@@@@@@'+e);
       }
       
    }
    

    public Class KnowledgeArticleDetailsWrapper
    {
        public String Title {get;set;}
        public string URLName {get;set;}
        public String Summary {get;set;}
        public String Description {get;set;}
        public String Id {get;set;}
        public String DataCategoryName {get;set;}
        public String DataCategoryGroupName {get;set;}
        public Double AvgRating {get;set;}
        public Double UserRating {get;set;}
        public String KnowledgeArticleId {get;set;}
        public string ArticleNumber {get;set;}
        public Integer versionNumber {get;set;}
        public datetime LastModifiedDate {get;set;}
        public string Resolution {get;set;}
        public string Product {get;set;}
        public string ProductComponent {get;set;}
        public string ProductVersion {get;set;}
        public string AdditionProductComponent {get;set;}
        public string AdditionProductVersion {get;set;}
        public string Symptom {get;set;}
        public string AttachmentName1 {get;set;}
        public string AttachmentName2 {get;set;}
        public string AttachmentName3 {get;set;}
        public string AttachmentName4 {get;set;}
        public string AttachmentName5 {get;set;}
        public blob Attachment1 {get;set;}
        public blob Attachment2 {get;set;}
        public blob Attachment3 {get;set;}
        public blob Attachment4 {get;set;}
        public blob Attachment5 {get;set;}

        public KnowledgeArticleDetailsWrapper() {

        }

    }
}