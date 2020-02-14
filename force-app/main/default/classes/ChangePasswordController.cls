/**
 * An apex page controller that exposes the change password functionality
 */
    public class ChangePasswordController {
    public String oldPassword {get; set;}  
    //public String username {get; set;}
    //public String email {get; set;}
    public String newPassword {get; set {newPassword = value == null ? value : value.trim(); } }
    public String verifyNewPassword {get; set { verifyNewPassword = value == null ? value : value.trim(); } }

    //public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }


    private boolean isValidPassword() {
        return newPassword == verifyNewPassword;
    }

/*
    public PageReference registerUser() {

      
        if (!isValidPassword()) {

           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,

               Label.site.passwords_dont_match);

           ApexPages.addMessage(msg);

            return null;

        }   

        User u = new User();
        u.Username = username;
        u.Email = email;
        u.CommunityNickname = communityNickname;
   

        String userId = Site.createPortalUser(u, accountId, password);
        if (userId != null) {
            if (password != null && password.length() > 1) {
                return Site.login(username, password, null);
            }

            else {
               PageReference page = System.Page.SiteRegisterConfirm;
                page.setRedirect(true);
                return page;
            }

        }

        return null;
    }
    */
    
    public PageReference changePassword() {
        if (!isValidPassword()) {

           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.site.passwords_dont_match);
           ApexPages.addMessage(msg);
           return null;

        } 
        Site.changePassword(newPassword, verifyNewPassword, oldpassword);  
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your password has been updated');
        ApexPages.addMessage(msg);
        return  null;   
    }     
    
   	public ChangePasswordController() {}
    
   	public static testMethod void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page

        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty2'; 
        controller.verifyNewPassword = 'qwerty1';   
        System.assertEquals(controller.changePassword(),null);              

        ChangePasswordController controller1 = new ChangePasswordController();
        controller1.oldPassword = '123456';
        controller1.newPassword = 'qwerty1'; 
        controller1.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller1.changePassword(),null);                           
    }    
}