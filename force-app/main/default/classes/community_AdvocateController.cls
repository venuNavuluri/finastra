public class community_AdvocateController {
 
    public List<ProductSetVersion> lstProductSetVersion {get;set;}
    public string productTypeColorCode {get;set;}
       
    public community_AdvocateController() {
        List<product_set__c> productSet = New List<product_set__c>();
        //string currentUser ='00120000000KJlgAAG' ; 
        string currentUser = [SELECT contact.accountId From User where Id = :UserInfo.getUserId() ].contact.accountId;
        
        productSet = [SELECT Customer_Advocate__c, Product_Version_Master__c, Product_Version_Master__r.Product_Name__c, Product_Version_Master__r.Product_Version__c, 
        Product_Version_Master__r.GA_Date__c, Product_Version_Master__r.Standard_Support_Date__c, Product_Version_Master__r.Sustaining_Support__c,
        Product_Version_Master__r.Technical_Support__c, Product_Version_Master__r.Support_Type__c  
        FROM product_set__c where account__c = : currentUser and Customer_Advocate__c <>''  and Product_Version_Master__c <>''] ;

        set<Id> setUsers = New set<Id>();
        set<Id> setProductVersion = New set<Id>();

        for(product_set__c  productUser : productSet) {
            setUsers.add(productUser.customer_Advocate__c);
            setProductVersion.add(productUser.Product_Version_Master__c);
        }

        Map<Id, User> mapIdToUsers = new Map<Id, User>([select FirstName,LastName from User where Id IN :setUsers]);
        Map<Id, Product_Version_Master__c> mapIdToProductSetVersion = New Map<Id, Product_Version_Master__c>([SELECT Id, Product_Name__c, Product_Version__c, 
        GA_Date__c, Standard_Support_Date__c, Sustaining_Support__c,Technical_Support__c, Support_Type__c  FROM Product_Version_Master__c where Id IN: setProductVersion]);

        lstProductSetVersion = new List<ProductSetVersion>();

        for(product_set__c productSetDetail : productSet){
            ProductSetVersion PSV = New ProductSetVersion();
            //ProductVersions productVersion = New ProductVersions();
            User currentUserObj = mapIdToUsers.get(productSetDetail.Customer_Advocate__c);
            Product_Version_Master__c currentVersionMaster = mapIdToProductSetVersion.get(productSetDetail.Product_Version_Master__c);
            if(currentUserObj != NULL)
            {
                system.debug(productSetDetail.Product_Version_Master__r.Product_name__c);
               /* productVersion.ProductName = currentVersionMaster.Product_name__c;
                productVersion.ProductVersion = currentVersionMaster.Product_Version__c;
                productVersion.SustainingSupport = currentVersionMaster.Sustaining_Support__c;
                productVersion.TechnicalSupport = currentVersionMaster.Technical_Support__c;
                productVersion.GADate = currentVersionMaster.GA_Date__c.format();
                productVersion.StandardSupportDate = currentVersionMaster.Standard_Support_Date__c;
                productVersion.SupportType = currentVersionMaster.Support_Type__c; */
                if(currentVersionMaster.Support_Type__c == 'Technical Support') {
                    productTypeColorCode = '<span style=\'color:#FF0000\'>';
                    } else if (currentVersionMaster.Support_Type__c == 'Sustaining Support') {
                        productTypeColorCode = '<span style=\'color:#CCC328\'>';
                        } else {
                            productTypeColorCode = '<span style=\'color:#469B00\'>';
                        }
                PSV.customerAdvocate = currentUserObj;
                PSV.productVersionMaster = currentVersionMaster;
                PSV.ProductSetDetail = productSetDetail ;
                lstProductSetVersion.add(PSV);
            } 
        }

    }

    public class ProductSetVersion {
        public Product_Version_Master__c productVersionMaster {get;set;}
        public product_set__c ProductSetDetail {get;set;}
        public User customerAdvocate {get;set;}   
    }
    /*
    public class ProductVersions {
        public string ProductName {get;set;}
        public string ProductVersion {get;set;}
        public string SustainingSupport {get;set;}
        public string TechnicalSupport {get;set;}
        public string SupportType {get; set;}
        public string GADate {get;set; }
        public datetime StandardSupportDate {get; set;  }

        public ProductVersions(){}
    }
    */
}