public with sharing class community_MI_ProfileController{

    //private User user;
    //private Contact contact, parentContact;
    //private Account account;
    //private boolean isEdit = false;
    //public string profileImageUrl    { get; set; }
    //public ConnectAPI.Photo userPhoto {get;set;}
    //public transient Blob ChatterPhoto{get;set;}
    //public ConnectAPI.UserDetail userProfile {get; set;}
    //public ConnectAPI.ChatterGroups userGroups {get; set;}
    //public List<ConnectApi.ChatterGroup> lstGroupData {get;set;}
    //public List<CollaborationGroupMember> lstCollabGroups {get;set;}
    //public ConnectAPI.FollowingPage following {get;set;}
    public integer expiredProducts{ get; set; }
    public integer numberOfProducts{ get; set; }
    public integer expiringProducts{ get; set; }
    public List<ProductSetVersion> lstProductSetVersion{ get; set; }
    //public string accountOwner {get;set;}
    //public string productColorClass {get; set;}
    public string accountOwnerEmail{ get; set; }
    private User user{ get; set; }
    public string CommunityURL {get; set;}
    
/*
    public User getUser() {
        return user;
    }

    public Contact getContact(){
        return contact;
    }
    
    public Account getAccount(){
        return account;
    }

    //public Contact getParentContact(){
    //    return parentContact;
    //}
*/
    public community_MI_ProfileController(){
        //customerPreferences();
        // chatterOverview();

        Constants__c mc = Constants__c.getValues('CommunityURL');
        CommunityURL = mc.Value__c;

        user = [SELECT contact.accountId From User where Id = :UserInfo.getUserId() LIMIT 1];
        Id currentUserAccountId = user.contact.accountId;
        List<product_set__c> productSet = New List<product_set__c>();

        system.debug('@@@@@@@@@@testacct:' + currentUserAccountId);


        productSet = [
                SELECT Customer_Advocate__c, Product_Version_Master__c, Product_Version_Master__r.Product_Name__c, Product_Version_Master__r.Product_Version__c,
                        Product_Version_Master__r.GA_Date__c, Product_Version_Master__r.Standard_Support_Date__c, Product_Version_Master__r.Sustaining_Support__c, Type_of_Support__c, Sustaining_Support__c,
                        Product_Version_Master__r.Technical_Support__c, Product_Version_Master__r.Support_Type__c, Product_Version_Master__r.Sustaining_Support_Date__c, Product_Version_Master__r.Technical_Support_Date__c
                        ,Sustaining_to_Technical_Support__c, name
                FROM product_set__c
                where account__c = :currentUserAccountId and Customer_Advocate__c <> '' and Product_Version_Master__c <> ''
        ] ;
        system.debug('@@@@@@@@productSet:' + productSet);
        set<Id> setUsers = New set<Id>();
        set<Id> setProductVersion = New set<Id>();

        for(product_set__c productUser : productSet){
            system.debug('@@@@@@@@@@@advocate: ' + productUser.customer_Advocate__c);
            setUsers.add(productUser.customer_Advocate__c);
            setProductVersion.add(productUser.Product_Version_Master__c);
        }

        Map<Id, User> mapIdToUsers = new Map<Id, User>([select FirstName,LastName from User where Id IN :setUsers]);
        Map<Id, Product_Version_Master__c> mapIdToProductSetVersion = New Map<Id, Product_Version_Master__c>([
                SELECT Id, Product_Name__c, Product_Version__c,
                        GA_Date__c, Standard_Support_Date__c, Sustaining_Support_Date__c, Technical_Support_Date__c, Sustaining_Support__c,Technical_Support__c, Support_Type__c
                FROM Product_Version_Master__c
                where Id IN:setProductVersion
        ]);

        lstProductSetVersion = new List<ProductSetVersion>();
        numberOfProducts = 0;
        expiredProducts = 0;
        expiringProducts = 0;
        for(product_set__c productSetDetail : productSet){

            numberOfProducts++;
            ProductSetVersion PSV = New ProductSetVersion();
            User currentUserObj = mapIdToUsers.get(productSetDetail.Customer_Advocate__c);
            system.debug('current user:' + currentUserObj);
            Product_Version_Master__c currentVersionMaster = mapIdToProductSetVersion.get(productSetDetail.Product_Version_Master__c);
            //if(currentUserObj != NULL)
            try{
                PSV.updateClass = '';
                system.debug('@@@@@@@@@@@@@' + productSetDetail.Product_Version_Master__r.Technical_Support__c);
                date currentDate = system.today();
                if(currentDate.monthsBetween(currentVersionMaster.Standard_Support_Date__c) > 15){
                    PSV.contentDivClass = 'content-pad content group';
                    integer month = currentDate.monthsBetween(currentVersionMaster.Standard_Support_Date__c);
                    system.debug('month::' + month);
                } else if(currentDate.monthsBetween(currentVersionMaster.Standard_Support_Date__c) <= 15 && currentDate.monthsBetween(currentVersionMaster.Standard_Support_Date__c) > 9){
                    PSV.contentDivClass = 'content-pad content expiring group';
                    PSV.showUpdate = true;
                    PSV.updateClass = 'update';
                    expiringProducts++;
                } else{
                    PSV.contentDivClass = 'content-pad content expired group';
                    PSV.showUpdate = true;
                    PSV.updateClass = 'update';
                    expiredProducts++;
                }

                PSV.customerAdvocate = currentUserObj;
                PSV.productVersionMaster = currentVersionMaster;
                PSV.ProductSetDetail = productSetDetail ;
                lstProductSetVersion.add(PSV);
            } catch(exception e){
                system.debug(LoggingLevel.ERROR,'Exception while initializing controller: ' + e);
            }


        }
    }

    public class ProductSetVersion{
        public Product_Version_Master__c productVersionMaster{ get; set; }
        public product_set__c ProductSetDetail{ get; set; }
        public User customerAdvocate{ get; set; }
        public string contentDivClass{ get; set; }
        public boolean showUpdate{ get; set; }
        public string updateClass{ get; set; }
    }
    
/*
  
      

    
    public void uploadChatterPhoto() {
        ConnectApi.BinaryInput b=new ConnectApi.BinaryInput(ChatterPhoto,'image/jpeg','myimage');
        ConnectApi.UserProfiles.setPhoto(Label.CommunityId,userinfo.getUserId(), b); 
	}
  */  
/*
                date currentDate =system.today();   
                date SupportChangeDate; 
                date startDate = date.newinstance(2016, 6, 1);
                PSV.contentDivClass = 'content-pad content group';
                if(productSetDetail.Type_of_Support__c == 'Standard Support') {
                        SupportChangeDate = productSetDetail.Standard_Support__c;
                        system.debug('SupportChangeDate' + productSetDetail.Standard_Support__c);
                        if(currentDate.monthsBetween(productSetDetail.Standard_Support__c) <=15 && ! productSetDetail.Standard_to_Sustaining_Support__c) {
                            //integer monthsBetween = currentDate.monthsBetween(productSetDetail.Standard_Support__c);
                            //system.debug('months::' + monthsBetween);

                            PSV.contentDivClass = 'content-pad content expiring group';                   
                            //PSV.expiringDate = productSetDetail.Standard_Support__c;
                            //PSV.nextSupportType = 'Sustaining Support';
                            PSV.showUpdate = true;
                            PSV.updateClass = 'update';
                            //supportChangeProducts.add(PSV);

                            expiringProducts++;
                        }
                    } else if (productSetDetail.Type_of_Support__c == 'Sustaining Support') {
                        integer monthsBetween = currentDate.monthsBetween(productSetDetail.Sustaining_Support__c);
                        system.debug('months::' + productSetDetail.Sustaining_Support__c);
                        if(currentDate.monthsBetween(productSetDetail.Sustaining_Support__c) <=15 && ! productSetDetail.Sustaining_to_Technical_Support__c) {
                            PSV.contentDivClass = 'content-pad content expiring group';
                            //PSV.expiringDate = productSetDetail.Sustaining_Support__c;
                            //PSV.nextSupportType = 'Technical Support';
                            PSV.showUpdate = true;
                            PSV.updateClass = 'update';
                            try{
                                //supportChangeProducts.add(PSV);
                                } catch (exception e) {
                                    system.debug(e);
                                }
                            expiringProducts++;
                        }
                    }


*/
}