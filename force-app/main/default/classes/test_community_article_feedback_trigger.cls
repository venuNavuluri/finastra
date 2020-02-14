@isTest
private class test_community_article_feedback_trigger {

    @isTest static void shouldUpdateFeedbackBasedOnArticle() {
		
        User adminUser = TestUtils.getAdminUser('admin');
        adminUser.UserPermissionsKnowledgeUser = true;
        
        System.runAs(adminUser){
            //create the kav instance
            Documentation__kav a = new 	Documentation__kav(
                    Additional_Product_Component__c = 'test apex',
                    Title = 'test',
                    UrlName = 'test67876478643786348'
            );
    
            insert a;
            //retrieve master article Id created on FAQ__kav record insertion
            //in order to get the KnowledgeArticleId
            a = [SELECT KnowledgeArticleId FROM Documentation__kav WHERE Id = :a.Id];
    
    
            //publish it
            KbManagement.PublishingService.publishArticle(a.KnowledgeArticleId, true);
    
            test.startTest();
            KnowledgeArticleVersion kAV = [SELECT KnowledgeArticleId, ArticleNumber, Title, VersionNumber, ArticleType, PublishStatus FROM KnowledgeArticleVersion WHERE PublishStatus = 'online' AND Language = 'en_US' LIMIT 1];
            Article_Feedback__c af = new Article_Feedback__c(Article_ID__c=kAV.KnowledgeArticleId);
            insert af;
            test.stopTest();
            Article_Feedback__c insertedAF = [SELECT Id, Article_Title__c,Article_Version__c,Article_Number__c FROM Article_Feedback__c WHERE Id = :af.Id LIMIT 1];
            system.assertEquals(kAV.Title, insertedAF.Article_Title__c);
            system.assertEquals(kAV.VersionNumber, insertedAF.Article_Version__c);
            system.assertEquals(kAV.ArticleNumber, insertedAF.Article_Number__c);
        }
    }
}