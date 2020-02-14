@isTest(seeAllData=true)
public class Article_Test{
    public static testmethod void ShowDocumentation() {
        Documentation__kav article = new Documentation__kav(Title='Unit Test');
                        
        ApexPages.currentPage().getParameters().put('id', 'ka011000000043xAAA');
        ApexPages.currentPage().getParameters().put('type', 'Documentation');
        
        ShowArticleController controller = new ShowArticleController();
        
        System.assert(controller.DocumentationItem != null);
    }
    
    public static testmethod void ShowTroubleshooting() {
		Troubleshooting__kav article = new Troubleshooting__kav(Title='Unit Test');        
        
        ApexPages.currentPage().getParameters().put('id', article.Id);
        ApexPages.currentPage().getParameters().put('type', 'Troubleshooting');
        
        ShowArticleController controller = new ShowArticleController();
        
        System.assert(controller.TroubleshootingItem != null);
    }
    
    public static testmethod void GetArticles() {
        ApexPages.currentPage().getParameters().put('search', 'test');
        ApexPages.currentPage().getParameters().put('articleTypes', 'Troubleshooting__kav');
        ApexPages.currentPage().getParameters().put('category', 'Product:Trade_Innovation_TI_PLUS_1');
        
        ArticleController controller = new ArticleController();
        controller.Next();
		controller.Previous();

		System.assert(controller.RenderPreviousButton == false);        
    }
    
    private static Troubleshooting__kav CreateTroubleshooting() {
        Troubleshooting__kav article = new Troubleshooting__kav();
        article.Title = 'Troubleshooting Test';
        article.UrlName = 'Url-Name';
        article.Language = 'en_US';
        
        return article;
    }
    
    private static Documentation__kav CreateDocumentation() {
        Documentation__kav article = new Documentation__kav();
        article.Title = 'Documentation Test';
        article.UrlName = 'Url-Name';
        article.Language = 'en_US';
                
        return article;
    }
}