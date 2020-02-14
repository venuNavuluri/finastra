public class UserTriggerHelper {
    Public static Id UI_2FApermissionSetId;
    Public static Id API_2FApermissionSetId;
    public static string API_2FA_PERMISSION_SET ='Two_Factor_Authentication_for_API_Required';
    public static string UI_2FA_PERMISSION_SET ='Two_Factor_Authentication_for_UI_Required';
    
    public static void processUserForTwoFA(Map<ID,User> mobilePhoneAppUsersMap, Map<ID,User> u2FKeyUsersMap){
 
         API_2FApermissionSetId  = [SELECT Id FROM PermissionSet where name = :API_2FA_PERMISSION_SET].Id;
         UI_2FApermissionSetId = [SELECT Id FROM PermissionSet where name = :UI_2FA_PERMISSION_SET].Id; 
         
         if(mobilePhoneAppUsersMap.size()>0){
             assignTwoFAPermissionSetToUser(mobilePhoneAppUsersMap);
         }
         if(u2FKeyUsersMap.size()>0){
             assignTwoFAPermissionSetToUser(u2FKeyUsersMap);
         }
     
     }
     
     public static void assignTwoFAPermissionSetToUser(Map<ID,User> usersToUpdateMap){
          
           List<PermissionSetAssignment> psaUpdateList = new List<PermissionSetAssignment>();
           Map<Id,PermissionSetAssignment> userIdtoPermissionSetAssigMap = new Map<Id,PermissionSetAssignment>();
           
          //to check if the 2FA permission sets are already assigned to the users.
           List<PermissionSetAssignment> existingAssignmentList = [SELECT AssigneeId,Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId in (:UI_2FApermissionSetId ,:API_2FApermissionSetId) AND AssigneeId in :usersToUpdateMap.keySet()];
           for(PermissionSetAssignment psaObj: existingAssignmentList){
               if(userIdtoPermissionSetAssigMap.get(psaObj.AssigneeId)==null){
                   userIdtoPermissionSetAssigMap.put(psaObj.AssigneeId,psaObj);
               }
               
           }
           //If permission set is not assigend only then assign else do not update the user record.
           for(User uObj: usersToUpdateMap.values()){
               if(userIdtoPermissionSetAssigMap.get(uObj.Id)!=null){
                   system.debug('Permission set already assigned to user');
                   continue;
               }else{
                     psaUpdateList.add(new PermissionSetAssignment(PermissionSetId = UI_2FApermissionSetId, AssigneeId = uObj.Id));
                     psaUpdateList.add(new PermissionSetAssignment(PermissionSetId = API_2FApermissionSetId, AssigneeId = uObj.Id));
               }
              
           }
           if(psaUpdateList.size()>0){
               insert psaUpdateList;
           }
           
     }
     
   
}