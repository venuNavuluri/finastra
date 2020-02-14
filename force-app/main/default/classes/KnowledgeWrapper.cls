Global class KnowledgeWrapper implements Comparable {
    public KnowledgeArticle Article{get; set;} 
    public Decimal ArticleRating {get; set;}
    public Decimal ArticleViews {get; set;}
    public string ArticleId {get; set;}
    public string Title {get; set;}
    public datetime LastPublishedDate {get; set;}
    public string ArticleType {get{
        return ArticleType;
    } set{
        system.debug(value);
        string[] ArticleArr = value.split('_');
        ArticleType = ArticleArr[0];
        
    }}
    public string ArticleNumber {get; set;}
    public string ArticleURL {get; set;}
    public string Summary {get; set;}

    public enum SORT_BY {
        ByRating, ByViews
    }

    public static SORT_BY sortBy = SORT_BY.ByRating;
    
    public KnowledgeWrapper(){}
    
    Global Integer compareTo(Object compareTo) {
        KnowledgeWrapper compareToKW = (KnowledgeWrapper)compareTo;
        if (sortBy == SORT_BY.ByRating) {
                if (ArticleRating == compareToKW.ArticleRating) return 0;
                if (ArticleRating < compareToKW.ArticleRating) return 1;
            } else {
                if (ArticleViews == compareToKW.ArticleViews) return 0;
                if (ArticleViews < compareToKW.ArticleViews) return 1;
            }
        
        return -1; 
            
        
    }
}