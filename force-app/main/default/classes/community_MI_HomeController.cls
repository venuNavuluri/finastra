public with sharing class community_MI_HomeController {

    public List<Community_Homepage_CMS__c> MiHomeCMSContent {get; set;}
    public List<Community_Feature_Hyperlink__c> LeadContentLinks {get; set;}
    public Map<Id,Community_Feature_Hyperlink__c> contentLinks {get; set;}
    public Map<Id,string> contentImages {get; set;}
    public string QueryString {get; set;}
    public string LeadContentTitle {get; set;}
    public string LeadContentBody {get; set;}
    public string LeadContentImage {get;set;}
    public List<ProductSetVersion> lstProductSetVersion {get;set;}
    public string CTA_Title {get;set;}
    public string CTA_URL {get;set;}
    public string CTA_Helptext {get;set;}
    public static boolean showPopUp {get;set;}
    public static boolean showChatterDisclaimer {get;set;}
    public List<ProductSetVersion> supportChangeProducts {get;set;}
    public static boolean popUpClosed = false;
    public static boolean showDialogCloseBtn {get;set;}
    private string typeOfService {get;set;} 
    private User user;
    private Contact contact;
    public boolean showLeadImage {get;set;}
    public string GAUserId {get;set;}

    //public Contact getContact(){
    //    return contact;
    //}
    //public User getUser() {
    //    return user;
    //}
    
    public community_MI_HomeController() {
        GAUserId = UserInfo.getUserId();
        string currentUser ;
        boolean showProducts = true;
        showLeadImage = false;
        user =  [SELECT Chatter_Disclaimer__c, id, Contact.Id, profile.name From User where Id = :UserInfo.getUserId() LIMIT 1];
        system.debug('@@@@@@@@@@@con:' + user.Contact.Id);
        if(user.profile.name =='Customer Community Banking User' || user.profile.name =='Customer Community Banking User - SSO' ) {
            contact = [SELECT salutation, ReportsToId, Business_Continuity_Contact__c, AccountId, Product__c, Receive_Support_Handbook__c, 
            Receive_Customer_Support_Newsletter__c, Receive_Support_Maintenance_Updates__c, Receive_Customer_Support_Policy_Updates__c,
            Receive_Misys_Product_Updates__c, account.name FROM Contact WHERE Id = : user.Contact.Id];
            system.debug('@@@@@@@@@@@acct:' + contact.AccountId);
            currentUser = contact.AccountId;
            showProducts = true;
        } else {
            showProducts = false;
        }
       
              

        showDialogCloseBtn = false;
        showChatterDisclaimer = false;
        showPopUp = false;
        try {
            for(List<Community_Header_CTA__c> cta : [SELECT CTA_Help_Text__c, CTA_Text__c, CTA_URL__c FROM Community_Header_CTA__c WHERE  CTA_Page_To_Display__c='Home']) {
            CTA_Title = cta[0].CTA_Text__c;
            CTA_URL = cta[0].CTA_URL__c;
            CTA_Helptext = cta[0].CTA_Help_Text__c;
        }
        } catch (exception e) {
            CTA_URL = '';
        }
        

        
        Constants__c mc = Constants__c.getValues('CommunityURL');
        queryString = mc.Value__c;

        contentLinks = New Map<Id, Community_Feature_Hyperlink__c>();
        for(List<Community_Feature_Hyperlink__c> links : [SELECT URL__c, Hyperlink_Text__c,Knowledge_Homepage_Feature__c,Id FROM Community_Feature_Hyperlink__c]) {
            for(Community_Feature_Hyperlink__c link : links) {
                contentLinks.put(link.Knowledge_Homepage_Feature__c,link);
                system.debug('output link objects....');
                system.debug(link);
            }          
        }
    Map<Id,string> cmsMap = New Map<Id, string>();
        Set<ID> ids = new Set<ID>();
        for(List<Community_Homepage_CMS__c> cms: [SELECT Id,Title__c FROM Community_Homepage_CMS__c WHERE Active__c = True AND Page_to_Display__c='Home']){
            for(Community_Homepage_CMS__c c: cms) {
                cmsMap.put(c.Id, c.Title__c);
            }
        }
    ids = cmsMap.keySet();
        
        contentImages = New Map<Id, String>();
        for(List<Attachment> imageAttachments : [SELECT Id, Name, parentId FROM Attachment WHERE parentId in :ids]) {
            for(Attachment imageAttachment : imageAttachments) {
                contentImages.put(imageAttachment.parentId, imageAttachment.Id);
                showLeadImage = true;
            }
        }
       
        
        LeadContentLinks = New List<Community_Feature_Hyperlink__c>();
        MiHomeCMSContent  = New List<Community_Homepage_CMS__c>();
        List<Community_Homepage_CMS__c> CMSContent = New List<Community_Homepage_CMS__c>();
        CMSContent = [SELECT Id, Body_Copy__c, Active__c,Is_Lead_Feature__c,Title__c, (SELECT URL__c, Hyperlink_Text__c FROM Community_Feature_Hyperlinks__r) 
                        FROM Community_Homepage_CMS__c WHERE Active__c = True AND Page_to_Display__c='Home'];
        for(Community_Homepage_CMS__c cmsItem : CMSContent) {
            if(cmsItem.Is_Lead_Feature__c) {
                LeadContentTitle = cmsItem.Title__c;
                LeadContentBody = cmsItem.Body_Copy__c;
                LeadContentLinks.add(contentLinks.get(cmsItem.Id));
                LeadContentImage = contentImages.get(cmsItem.Id);               
            } else {
                 MiHomeCMSContent.add(cmsItem);
            }
        }


        List<product_set__c> productSet = New List<product_set__c>();
        

        if (showProducts) {
             productSet = [SELECT Name, Standard_Support__c,Customer_Advocate__c, Product_Version_Master__c, Product_Version_Master__r.Product_Name__c, Product_Version_Master__r.Product_Version__c, 
        Product_Version_Master__r.GA_Date__c, Product_Version_Master__r.Standard_Support_Date__c, Sustaining_Support__c, Sustaining_to_Technical_Support__c, Standard_to_Sustaining_Support__c,
        Product_Version_Master__r.Technical_Support__c, Product_Version_Master__r.Support_Type__c , Next_Logical_Support_Move__c, Type_of_Support__c
        FROM product_set__c where account__c = : currentUser and Customer_Advocate__c <>''  and Product_Version_Master__c <>'' order by Sustaining_Support__c ASC] ;

        //set<Id> setUsers = New set<Id>();
        set<Id> setProductVersion = New set<Id>();

        for(product_set__c  productUser : productSet) {
            //setUsers.add(productUser.customer_Advocate__c);
            setProductVersion.add(productUser.Product_Version_Master__c);
        }

        //Map<Id, User> mapIdToUsers = new Map<Id, User>([select FirstName,LastName from User where Id IN :setUsers]);
        Map<Id, Product_Version_Master__c> mapIdToProductSetVersion = New Map<Id, Product_Version_Master__c>([SELECT Id, Product_Name__c, Product_Version__c, 
        GA_Date__c, Standard_Support_Date__c, Sustaining_Support_date__c,Technical_Support__c, Support_Type__c  FROM Product_Version_Master__c where Id IN: setProductVersion order by Sustaining_Support__c ASC]);

        lstProductSetVersion = new List<ProductSetVersion>();
        supportChangeProducts = new List<ProductSetVersion>();

        for(product_set__c productSetDetail : productSet){
            ProductSetVersion PSV = New ProductSetVersion();
            //ProductVersions productVersion = New ProductVersions();
            //User currentUserObj = mapIdToUsers.get(productSetDetail.Customer_Advocate__c);
            Product_Version_Master__c currentVersionMaster = mapIdToProductSetVersion.get(productSetDetail.Product_Version_Master__c);
                          
                PSV.productVersionMaster = currentVersionMaster;
                PSV.ProductSetDetail = productSetDetail ;
                if(productSetDetail.Sustaining_Support__c != null) {
                    if(productSetDetail.Sustaining_Support__c <= date.today()) {
                        PSV.showUpdate = true;
                        PSV.updateClass = 'update';
                    } else {
                        PSV.showUpdate = false;
                        PSV.updateClass = '';
                    }
                } 
                date currentDate =system.today();   
                date SupportChangeDate; 
                date startDate = date.newinstance(2016, 6, 1);
         //       if(productSetDetail.Standard_Support__c > startDate || productSetDetail.Sustaining_Support__c > startDate) {
                    if (!popUpClosed ) {
                      system.debug('@@@@@@@@@type of support' + productSetDetail.Type_of_Support__c);
                        if(productSetDetail.Type_of_Support__c == 'Standard Support' && productSetDetail.Standard_Support__c > startDate) {
                            SupportChangeDate = productSetDetail.Standard_Support__c;
                            system.debug('SupportChangeDate' + productSetDetail.Standard_Support__c);
                           
                            if(currentDate.monthsBetween(productSetDetail.Standard_Support__c) <=15 && ! productSetDetail.Standard_to_Sustaining_Support__c) {
                                //integer monthsBetween = currentDate.monthsBetween(productSetDetail.Standard_Support__c);
                                //system.debug('months::' + monthsBetween);

                                showPopUp = true;                     
                                PSV.expiringDate = productSetDetail.Standard_Support__c;
                                PSV.nextSupportType = 'Sustaining Support';
                                supportChangeProducts.add(PSV);
                            }
                        } else if (productSetDetail.Type_of_Support__c == 'Sustaining Support' && productSetDetail.Sustaining_Support__c > startDate) {
                            integer monthsBetween = currentDate.monthsBetween(productSetDetail.Sustaining_Support__c);
                            system.debug('@@@@@@@@months::' + productSetDetail.Sustaining_Support__c);
                            if(currentDate.monthsBetween(productSetDetail.Sustaining_Support__c) <=15 && ! productSetDetail.Sustaining_to_Technical_Support__c) {
                                showPopUp = true;
                                PSV.expiringDate = productSetDetail.Sustaining_Support__c;
                                PSV.nextSupportType = 'Technical Support';
                                try{
                                    supportChangeProducts.add(PSV);
                                    } catch (exception e) {
                                        system.debug(e);
                                    }
                                
                            }
                        }
                    }
              //  }
                
                
                lstProductSetVersion.add(PSV);
            
            }
        }
       
    
        if (! user.Chatter_Disclaimer__c) {
            showChatterDisclaimer = true;
        }
     
    }

    public void serviceCheck() {
        string passedParam1 = Apexpages.currentPage().getParameters().get('myParam');
        system.debug('@@@DEBUG::' + passedParam1);
        List<string> parts = passedParam1.split('-');
        integer i=0;
        string Id;

        for(string s : parts) {
            system.debug(s);
            if(i==0){
                Id = s;
            } else {
                typeOfService = s;
            }
            i++;
        }
        product_set__c productSet ;
        system.debug('@@@ID::'+Id);
        if(typeOfService =='Technical Support') {
           productSet = [SELECT Sustaining_to_Technical_Support__c FROM product_set__c WHERE Id=: Id LIMIT 1];
           productSet.Sustaining_to_Technical_Support__c = true;
        } else {
            productSet = [SELECT Standard_to_Sustaining_Support__c FROM product_set__c WHERE Id=: Id LIMIT 1];
            productSet.Standard_to_Sustaining_Support__c = true;
        }
        update productset;
    }


    public void disclaimerCheck() {
        string passedParam1 = Apexpages.currentPage().getParameters().get('disclaimer');
        system.debug('DEBUG::' + passedParam1);
        showDialogCloseBtn = true;

        user.Chatter_Disclaimer__c = true;
        update user;
    }

     public class ProductSetVersion {
        public Product_Version_Master__c productVersionMaster {get;set;}
        public product_set__c ProductSetDetail {get;set;}
        public boolean showUpdate {get;set;} 
        public string updateClass {get;set;}
        public date expiringDate {get;set;}
        public string nextSupportType {get;set;}

        public ProductSetVersion() {
            showUpdate = false;
            
        }
    }
/*
    public void CloseWindow() {
        popUpClosed = true;  
        showPopUp = false;
    }
*/
}