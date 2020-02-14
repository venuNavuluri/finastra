trigger article_Feedback_Trigger on Article_Feedback__c (before insert, before update){

    List<String> articleIDs = new List<String>();
    List<KnowledgeArticleVersion> kAVs = new List<KnowledgeArticleVersion>();
    Map<String, KnowledgeArticleVersion> idToArticleContentMap = new Map<String, KnowledgeArticleVersion>();

    //Retrieve KnowledgeArticleVersion
    kAVs = [SELECT KnowledgeArticleId, ArticleNumber, Title, VersionNumber, ArticleType, PublishStatus FROM KnowledgeArticleVersion WHERE PublishStatus = 'online' AND Language = 'en_US'];

    for(KnowledgeArticleVersion kAV : kAVs){
        idToArticleContentMap.put(kAV.KnowledgeArticleId, kAV);
    }

    for(Article_Feedback__c oneAF : trigger.new){
        oneAF.Article_Title__c = idToArticleContentMap.get(oneAF.Article_ID__c).Title;
        oneAF.Article_Version__c = idToArticleContentMap.get(oneAF.Article_ID__c).VersionNumber;
        String type = idToArticleContentMap.get(oneAF.Article_ID__c).ArticleType;
        oneAF.Article_Type__c = type.substring(0, type.length() - 5);
        oneAF.Article_Number__c = idToArticleContentMap.get(oneAF.Article_ID__c).ArticleNumber;
    }
}