public class community_MI_ServicesController {

	public string CTA_Title {get;set;}
    public string CTA_URL {get;set;}
    public string CTA_Helptext {get;set;}
    public List<Community_Homepage_CMS__c> MiServicesCMSContent {get; set;}
    public List<Community_Feature_Hyperlink__c> LeadContentLinks {get; set;}
    public Map<Id,Community_Feature_Hyperlink__c> contentLinks {get; set;}
    public Map<Id,string> contentImages {get; set;}
    public string QueryString {get; set;}
    public string LeadContentTitle {get; set;}
    public string LeadContentBody {get; set;}
    public string LeadContentImage {get;set;}
    public string LeadChatterGroupId {get;set;}
    public string JoinLeaveGroupCssClass {get; set;}
    public string JoinLeaveGroupName {get; set;}
    public string chatterGroupId {get;set;}
    public boolean displayMessage {get;set;}
    public List<contentWrapperClass> contentWrapper {get;set;}
    public string GAUserId {get;set;}
    public boolean showLeadImage {get;set;}
    
    //public ConnectAPI.FeedItemPage feedItemPage {get;set;}
    //public ConnectAPI.ChatterGroupPage chatterGroups {get;set;}
    //public ConnectAPI.GroupMembershipRequest groupRequest {get;set;}

    public community_MI_ServicesController() {
        showLeadImage = false;
        GAUserId = UserInfo.getUserId();
        displayMessage = false;
        for(List<Community_Header_CTA__c> cta : [SELECT CTA_Help_Text__c, CTA_Text__c, CTA_URL__c FROM Community_Header_CTA__c WHERE CTA_Page_To_Display__c='Services' LIMIT 1]) {
            for(Community_Header_CTA__c c : cta) {
                CTA_Title = c.CTA_Text__c;
                CTA_URL = c.CTA_URL__c;
                CTA_Helptext = c.CTA_Help_Text__c;
            }
           
        }

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
        for(List<Community_Homepage_CMS__c> cms: [SELECT Id,Title__c FROM Community_Homepage_CMS__c WHERE Active__c = True AND Page_to_Display__c='Services' and Is_Lead_Feature__c=true]){
            for(Community_Homepage_CMS__c c: cms) {
                cmsMap.put(c.Id, c.Title__c);
            }
        }
		ids = cmsMap.keySet();
        
        contentImages = New Map<Id, String>();
        for(List<Attachment> imageAttachments : [SELECT Id, Name, parentId FROM Attachment WHERE parentId in :ids]) {
            for(Attachment imageAttachment : imageAttachments) {
                showLeadImage = true;
                contentImages.put(imageAttachment.parentId, imageAttachment.Id);
            }
        }

        Set<String> resultIds = New Set<String>();
        List<CollaborationGroupMember> lstGroupMemberCheck = new List<CollaborationGroupMember>();
        lstGroupMemberCheck = [select id,CollaborationGroupId, CollaborationGroup.OwnerId from CollaborationGroupMember where MemberId =:userInfo.getuserid()];
        for(List<CollaborationGroupMember> groupMember: [select CollaborationGroupId from CollaborationGroupMember where MemberId = :userInfo.getuserid()]) {
            for(CollaborationGroupMember g : groupMember){
                system.debug(g.CollaborationGroupId);
                resultIds.add(g.CollaborationGroupId);
            }
            
        }
        //Set<Id> resultIds = (new Map<Id,SObject>(lstGroupMemberCheck)).keySet();

        contentWrapper = New List<contentWrapperClass>();

        LeadContentLinks = New List<Community_Feature_Hyperlink__c>();
        MiServicesCMSContent  = New List<Community_Homepage_CMS__c>();
        List<Community_Homepage_CMS__c> CMSContent = New List<Community_Homepage_CMS__c>();
        CMSContent = [SELECT Id, Body_Copy__c, Active__c,Is_Lead_Feature__c,Title__c, Chatter_Group_Id__c, (SELECT URL__c, Hyperlink_Text__c FROM Community_Feature_Hyperlinks__r) 
                        FROM Community_Homepage_CMS__c WHERE Active__c = True AND Page_to_Display__c='Services'];
        for(Community_Homepage_CMS__c cmsItem : CMSContent) {
            if(cmsItem.Is_Lead_Feature__c) {
                LeadContentTitle = cmsItem.Title__c;
                LeadContentBody = cmsItem.Body_Copy__c;
                LeadContentLinks.add(contentLinks.get(cmsItem.Id));
                LeadContentImage = contentImages.get(cmsItem.Id); 
                LeadChatterGroupId = cmsItem.Chatter_Group_Id__c;    
                if (cmsItem.Chatter_Group_Id__c != '' && cmsItem.Chatter_Group_Id__c != null) {
                    system.debug('DEBUG##' +cmsItem.Chatter_Group_Id__c );
                    if(resultIds.contains(cmsItem.Chatter_Group_Id__c)) {
                        JoinLeaveGroupCssClass =  'fa fa-close join'; 
                        JoinLeaveGroupName = 'Leave Group'; 
                    } else {
                        JoinLeaveGroupCssClass = 'fa fa-check join';
                        JoinLeaveGroupName = 'Join Group';
                    }
                    
                }        
            } else {
               contentWrapperClass cw = New contentWrapperClass();
                cw.LeadChatterGroupId = cmsItem.Chatter_Group_Id__c;
                cw.LeadContentBody = cmsItem.Body_Copy__c;
                cw.LeadContentTitle = cmsItem.Title__c;
                cw.LeadContentLinks = New List<Community_Feature_Hyperlink__c>();
                cw.LeadContentLinks.add(contentLinks.get(cmsItem.Id));
                cw.LeadContentImage = contentImages.get(cmsItem.Id); 
                if (cmsItem.Chatter_Group_Id__c != '' && cmsItem.Chatter_Group_Id__c != null) {
                    if(resultIds.contains(cmsItem.Chatter_Group_Id__c)) {
                        cw.joinLeaveGroupCssClass =  'fa fa-close join'; 
                        cw.joinLeaveGroupName = 'Leave Group'; 
                    } else {
                        cw.joinLeaveGroupCssClass = 'fa fa-check join';
                        cw.joinLeaveGroupName = 'Join Group';
                    }
                    
                }        
                contentWrapper.add(cw); 
                //MiServicesCMSContent.add(cmsItem);
            }
        }
    }
        //feedItemPage = ConnectAPI.ChatterFeeds.getFeedItemsFromFeed('0DB20000000XaHnGAK',ConnectAPI.FeedType.News, 'me');
        //chatterGroups = ConnectAPI.ChatterGroups.getGroups('0DB20000000XaHnGAK');
   
        
        //ConnectAPI.ChatterGroups.addMember('0DB20000000XaHnGAK', '0F9g0000000DIAICA4', '005g0000002Fqx4');
    

    @RemoteAction
    public static string joinLeaveGroup(String groupId, string GroupStatus){
     system.debug('%%%%%%%%%%%%%%%%%%%%'+groupId);
     GroupStatus= GroupStatus.replaceAll( '\\s+', '');
     system.debug('%%%%%%%%%%%%%%%%%%%%'+GroupStatus);
     
     if(GroupStatus == 'JoinGroup'){
         CollaborationGroupMember collGrp = new CollaborationGroupMember();
         collGrp.CollaborationGroupId = groupId;
         collGrp.CollaborationRole = 'Standard';
         collGrp.MemberId = userInfo.getUserId();
         insert collGrp;
         return 'Leave';
         }else{
            CollaborationGroupMember colGrp = [select id,CollaborationGroupId, CollaborationGroup.OwnerId from CollaborationGroupMember where MemberId =:userInfo.getuserid() and CollaborationGroupId =:groupId];
            delete colGrp;
            return 'Join';
         }
         

    }
/*
    public void addMemberToGroup(){
        try{
            CollaborationGroupMember groupMember = new CollaborationGroupMember();
            groupMember.memberid = UserInfo.getUserId();  //id of User you wish to add
            groupMember.CollaborationGroupId = chatterGroupId;
            insert groupMember;
            displayMessage = true;
        } catch(exception ex) {
            ApexPages.addMessages(ex);
        }
        
    }
*/
    public class contentWrapperClass {
        public string LeadContentTitle {get;set;}
        public string LeadContentBody {get;set;}
        public string LeadChatterGroupId {get;set;}
        public List<Community_Feature_Hyperlink__c> LeadContentLinks {get; set;}
        public string joinLeaveGroupCssClass {get;set;}
        public string joinLeaveGroupName {get;set;}
        public string LeadContentImage {get;set;}
    }
}