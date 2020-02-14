public class SessionInfo {
	public Boolean InPortal {get; set;}
	public Boolean IsEmployeeOnSite {get; set;}
	public Boolean IsEnhancementRequest {get; set;}
	private Profile userProfile;
	private User currentUser;
	public ID LoggedInContactId {get; set;}

	public SessionInfo(){
		this.userProfile = [Select p.UserType,p.Name from Profile p where p.Id= :UserInfo.getProfileId()];
		InPortal = false;
		IsEmployeeOnSite = false;
		IsEnhancementRequest = false;

		if(userProfile.UserType == 'Standard' || userProfile.Name == 'Customer Portal User HC Employee on site'){
			InPortal = false;
			if(userProfile.Name == 'Customer Portal User HC Employee on site'){
		 		IsEmployeeOnSite = true;
		 	}
		}else{
			InPortal = true;
		}
	}

	public void setUser(){
		this.currentUser = [select u.ContactId from User u  where u.Id= :UserInfo.getUserId()];
		LoggedInContactId = currentUser.ContactId;
	}
	
    // AC 9/4/09 - test methods moved to separate class

}