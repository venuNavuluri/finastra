public with sharing class community_groupListingController {

   // public List<String> groupIds = new List<String>();
   // public List<String> groupAllIds = new List<String>();
   // public ConnectApi.BatchResult[] batchResults {get;set;}
  //  public ConnectApi.BatchResult[] batchAllResults {get;set;}  
    public List<CollaborationGroup> lstCollabGroups {get; set;}
  //  public List<ConnectApi.ChatterGroup> lstGroupData {get;set;}
  //  public List<CollaborationGroup> lstAllCollabGroups = new List<CollaborationGroup>();
 //   public List<ConnectApi.ChatterGroup> lstAllGroupData {get;set;}
   // public List<chatterGroupWrapper> lstAllGroupDataWrapper {get;set;} 
   // public List<chatterGroupWrapper> lstAllCollabGroupsWrapper {get;set;}
  //  public List<CollaborationGroupMember> lstGroupMemberCheck = new List<CollaborationGroupMember>();
  //  public List<CollaborationGroupMember> lstGroupMemberCheckAll = new List<CollaborationGroupMember>();
    
	
    public community_groupListingController() {
        lstCollabGroups = new List<CollaborationGroup>();
        lstCollabGroups = [select id, name from CollaborationGroup where networkId =:Label.CommunityId  ];
    /*   ConnectApi.BatchResult[] batchResults = ConnectApi.ChatterGroups.getGroupBatch(Label.CommunityId, groupIds);
        lstGroupData = new List<ConnectApi.ChatterGroup>();
        lstAllGroupDataWrapper = new List<chatterGroupWrapper>();
        for (ConnectApi.BatchResult batchResult : batchResults) {
            if (batchResult.isSuccess()) {
                ConnectApi.ChatterGroup aGroup;
                if(batchResult.getResult() instanceof ConnectApi.ChatterGroup) {
                   aGroup = (ConnectApi.ChatterGroup) batchResult.getResult();  
                   lstGroupData.add(aGroup);
                   chatterGroupWrapper CwG = new chatterGroupWrapper();
                   CwG.groupId = aGroup.id;
                   CwG.name = aGroup.name;
               
                   
                   lstAllGroupDataWrapper.add(CwG);
                }
            }
    */
    }

}