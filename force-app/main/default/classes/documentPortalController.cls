public class documentPortalController {
 
    public string QueryString {get; set;}
    public string LeadContentTitle {get; set;}
    public string LeadContentBody {get; set;}
    
    public List<Community_Homepage_CMS__c> KnowledgeCMSContent {get; set;}
    public List<Community_Feature_Hyperlink__c> LeadContentLinks {get; set;}
    public Map<Id,Community_Feature_Hyperlink__c> contentLinks {get; set;}
    map<Id,RecordType> mapArticleType;
    public List<KnowledgeWrapper> KnowledgeArticles {get; set;}
    public List<KnowledgeWrapper> KnowledgeArticleRatings {get; set;}
    private KnowledgeWrapper KnowledgeObject;
    private KnowledgeWrapper KnowledgeRatings;
       
       
    public documentPortalController(){
        QueryString = 'http://docportal.misys.com/SFDCCommunity.aspx?emailId=sfdc_doc@misys.com';
        
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
                
        for(List<knowledgeArticleVersion> KAV : [SELECT Title,id,knowledgearticleId,articletype,lastpublisheddate,articlenumber,URLName FROM knowledgeArticleVersion WHERE PublishStatus = 'Online' AND  Language = 'en_US' AND knowledgearticleId In : ids]) {
            for(knowledgeArticleVersion knowledgeArticle : KAV){
                KnowledgeObject = New KnowledgeWrapper();
                KnowledgeObject.ArticleId = knowledgeArticle.knowledgearticleId;
                KnowledgeObject.ArticleViews = ViewStatMap.get(knowledgeArticle.knowledgearticleId);
                KnowledgeObject.LastPublishedDate = knowledgeArticle.lastpublisheddate;
                KnowledgeObject.Title = knowledgeArticle.Title;
                KnowledgeObject.ArticleNumber = knowledgeArticle.articlenumber;
                KnowledgeObject.ArticleType = knowledgeArticle.articletype;
                KnowledgeObject.ArticleURL = '/articles/' + KnowledgeObject.ArticleType + '/' + knowledgeArticle.URLName;
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
                
        for(List<knowledgeArticleVersion> KARating : [SELECT Title,id,knowledgearticleId,articletype,lastpublisheddate,articlenumber,URLName FROM knowledgeArticleVersion WHERE PublishStatus = 'Online' AND  Language = 'en_US' AND knowledgearticleId In : RatingIds]) {
            for(knowledgeArticleVersion knowledgeArticle : KARating){
                KnowledgeObject = New KnowledgeWrapper();
                KnowledgeObject.ArticleId = knowledgeArticle.knowledgearticleId;
                KnowledgeObject.ArticleRating = VoteStatMap.get(knowledgeArticle.knowledgearticleId);
                KnowledgeObject.LastPublishedDate = knowledgeArticle.lastpublisheddate;
                KnowledgeObject.Title = knowledgeArticle.Title;
                KnowledgeObject.ArticleNumber = knowledgeArticle.articlenumber;
                KnowledgeObject.ArticleType = knowledgeArticle.articletype;
                KnowledgeObject.ArticleURL = '/articles/' + KnowledgeObject.ArticleType + '/' + knowledgeArticle.URLName;
                KnowledgeArticleRatings.Add(KnowledgeObject);
            }
            
        }
        KnowledgeWrapper.sortBy = KnowledgeWrapper.SORT_BY.byRating;
        KnowledgeArticleRatings.sort();

        //pull out the CMS sections for the page
        contentLinks = New Map<Id, Community_Feature_Hyperlink__c>();

        for(List<Community_Feature_Hyperlink__c> links : [SELECT URL__c, Hyperlink_Text__c,Knowledge_Homepage_Feature__c,Id FROM Community_Feature_Hyperlink__c]) {
            for(Community_Feature_Hyperlink__c link : links) {
                contentLinks.put(link.Knowledge_Homepage_Feature__c,link);
                system.debug('output link objects....');
                system.debug(link);
            }          
        }
        
        LeadContentLinks = New List<Community_Feature_Hyperlink__c>();
        KnowledgeCMSContent  = New List<Community_Homepage_CMS__c>();
        List<Community_Homepage_CMS__c> CMSContent = New List<Community_Homepage_CMS__c>();
        CMSContent = [SELECT Id, Body_Copy__c,Active__c,Is_Lead_Feature__c,Title__c, (SELECT URL__c, Hyperlink_Text__c FROM Community_Feature_Hyperlinks__r) FROM Community_Homepage_CMS__c WHERE Active__c = True];
        for(Community_Homepage_CMS__c cmsItem : CMSContent) {
            if(cmsItem.Is_Lead_Feature__c) {
                LeadContentTitle = cmsItem.Title__c;
                LeadContentBody = cmsItem.Body_Copy__c;
                LeadContentLinks.add(contentLinks.get(cmsItem.Id));
                               
            } else {
                 KnowledgeCMSContent.add(cmsItem);
            }
        }

       
        
    }
 
   
}