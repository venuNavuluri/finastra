public class ShowArticleController{
    //Exceptions
    public class ArticleTypeNotImplementedException extends Exception {}
    
    public transient Troubleshooting__kav TroubleshootingItem { get; private set; }
    public transient Documentation__kav DocumentationItem { get; private set; }
    
    public ShowArticleController() {
        Boolean allowedSearch = false;
        String articleType = ApexPages.currentPage().getParameters().get('type');
        String knowledgeArticleId = ApexPages.currentPage().getParameters().get('id');
        
        system.debug('ArticleType in controller: ' + articleType);
        system.debug('Id in controller: ' + knowledgeArticleId);
                
        //Common fields between documentation and troubleshooting
        String commonFields = 'Additional_Product_Component__c, CurrencyIsoCode, ArticleNumber, ArticleType, Created_By_Historical__c, Created_Date_Historical__c, Description__c, LastPublishedDate, Migration_ID__c, Product__c, Product_Component__c, Product_Version__c, Resolution__c, Rolled_In_At__c, Solution_Number__c, Summary, Symptom__c, Technical_Info_internal_only__c, Title, UrlName, Attachment1__Name__s, Attachment2__Name__s,Attachment3__Name__s';
                
        if(articleType == 'Documentation') {
            SetupDocumentation(commonFields, knowledgeArticleId);
        } else if (articleType == 'Troubleshooting') {            
			SetupTroubleshooting(commonFields, knowledgeArticleId);            
        } else {
            throw new ArticleTypeNotImplementedException('That article type is not supported');
        }
    }
    
    private void SetupDocumentation(String commonFields, String knowledgeArticleId) {
        String uniqueFields = ', Documentation_Name__c, Document_Type__c';
        String query = 'SELECT ' + commonFields + uniqueFields + ' FROM Documentation__kav WHERE PublishStatus=\'Online\' AND Language=\'en_US\' AND KnowledgeArticleId = \'' + knowledgeArticleId + '\' LIMIT 1';
        try {
            DocumentationItem = database.query(query);
        } catch(Exception ex) {
            DocumentationItem = new Documentation__kav();
        }
 
    }
    
    private void SetupTroubleshooting(String commonFields, String knowledgeArticleId) {
        String uniqueFields = ', AttachmentMigrated__c';
        String query = 'SELECT ' + commonFields + uniqueFields + ' FROM Troubleshooting__kav WHERE PublishStatus=\'Online\' AND Language=\'en_US\' AND KnowledgeArticleId = \'' + knowledgeArticleId + '\' LIMIT 1';        
        try {
            TroubleshootingItem = database.query(query); 
        } catch(Exception ex) {
            TroubleshootingItem = new Troubleshooting__kav();
        }              
    }
}