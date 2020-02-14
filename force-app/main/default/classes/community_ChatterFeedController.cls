public class community_ChatterFeedController {

    public List<feedItem> userFeedList {get;set;}
    public List<UserFeedInfo> lstFeeds{get;set;}
    public List <KnowledgeArticleVersion> KAVlist {get;set;}

   /*
    public community_ChatterFeedController(ApexPages.StandardController stdController) {
        //this.mysObject = (sObject)stdController.getRecord();
    }
    */

    public community_ChatterFeedController() {

        userFeedList=[SELECT Id,Body,CreatedById,CreatedDate, ParentId, Type, (SELECT Id, FieldName, OldValue, NewValue 
                      FROM FeedTrackedChanges ORDER BY Id DESC)
                      FROM FeedItem where ParentId IN (SELECT ParentId FROM EntitySubscription WHERE SubscriberId =: UserInfo.getUserId() ) AND ParentId IN (SELECT KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' AND Language= 'en_US') ORDER BY CreatedDate DESC, Id DESC LIMIT 8];

        set<Id> setFeedUsers = new set<Id>();
        set<Id> setFeedArticles = new set<Id>();
        set<Id> setFeedComments = new set<Id>();
        
        for(FeedItem userFeedItem : userFeedList)
        {
            setFeedUsers.add(userFeedItem.CreatedById);
            setFeedArticles.add(userFeedItem.ParentId);
            setFeedComments.add(userFeedItem.Id);
        }


        
        Map<Id, User> mapIdToUsers = new Map<Id, User>([select FullPhotoUrl,FirstName,LastName from User where Id IN :setFeedUsers]);
        List<FeedComment> userComments = New List<FeedComment>([select feeditemId, commentbody, CreatedDate, CreatedById from feedComment where feeditemId IN : setFeedComments]);

        Map<string, KnowledgeArticleVersion> mapIdToArticle= new Map<string, KnowledgeArticleVersion>();
        for(List<KnowledgeArticleVersion> KAV : [select knowledgeArticleId, title from KnowledgeArticleVersion where PublishStatus = 'Online' And knowledgeArticleId  IN : setFeedArticles]){
            for(KnowledgeArticleVersion KAVItem : KAV)
            mapIdToArticle.put(KAVItem.knowledgeArticleId, KAVItem);
        }

        lstFeeds = new List<UserFeedInfo>();
        
        
        for(FeedItem userFeedItem : userFeedList)
        {
            List<commentWrapper> currentComments = New List<commentWrapper>();
            FeedComment thisComment = New FeedComment();
            UserFeedInfo userFeedInfo= new UserFeedInfo();
            User currentFeedUser = mapIdToUsers.get(userFeedItem.CreatedById);
            KnowledgeArticleVersion currentArticle = mapIdToArticle.get(userFeedItem.ParentId);

            for(feedComment currentfc : userComments) {
                if(currentfc.feedItemId == userFeedItem.Id) {
                    commentWrapper currentComment = New commentWrapper();
                    currentComment.commentBody = currentfc.commentBody;
                    currentComment.CreatedDate = currentfc.CreatedDate;
                    currentComment.userName = mapIdToUsers.get(currentfc.CreatedById);
                    currentComments.add(currentComment);
                }       
            }
            

            system.debug('Id: ' + currentArticle.knowledgeArticleId);
            
            if(currentFeedUser != NULL)
            {
                userFeedInfo.feedUser= currentFeedUser;
                userFeedInfo.userFeedItem = userFeedItem ;
                userFeedInfo.feedArticle = currentArticle;
                userFeedInfo.feedComments = currentComments;
                lstFeeds.add(userFeedInfo);
            } 
        } 

    }

    public class UserFeedInfo
      {
          public User feedUser {get;set;}
          public FeedItem userFeedItem {get;set;}
          public KnowledgeArticleVersion feedArticle {get;set;}
          public List<commentWrapper> feedComments {get; set;}
      }

      public class commentWrapper {
        public User userName {get;set;}
        public string commentBody {get; set;}
        public datetime CreatedDate {get;set;}
      }
}