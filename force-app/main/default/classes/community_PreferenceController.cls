public with sharing class community_PreferenceController {

    private User user;
    private Contact contact, parentContact;
    private boolean isEdit = false;
    public string ReportsTo {get;set;}
    public String ErrorMessage {get;set;}
    public boolean showUserForm {get;set;}
    
    public User getUser() {
        return user;
    }

    public Contact getContact(){
        return contact;
    }

    public Contact getParentContact(){
        return parentContact;
    }

    public community_PreferenceController(){
        ReportsTo='';
        showUserForm = false;
         user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email, profile.name
                FROM User
                WHERE id =  :UserInfo.getUserId()];
        if(user.profile.name == 'Customer Community Banking User' || user.profile.name == 'Customer Community Banking User - SSO') {
            showUserForm = true;
            contact = [SELECT salutation, ReportsToId, Business_Continuity_Contact__c, AccountId, Product__c, Receive_Support_Handbook__c, 
            Receive_Customer_Support_Newsletter__c, Receive_Support_Maintenance_Updates__c, Receive_Customer_Support_Policy_Updates__c,
            Receive_Misys_Product_Updates__c, account.name FROM Contact WHERE Id = : user.ContactId];


        try {
            parentContact = [SELECT firstname, lastname FROM Contact WHERE id =: contact.ReportsToId LIMIT 1];
            ReportsTo = parentContact.firstname + ' ' + parentContact.lastname;
            } catch (Exception e) {
                parentContact = null;
            }
        
            system.debug('@@@@@@@@@@@@@contructor' + contact.AccountId);
            } else {
                ErrorMessage = 'This page is for customers within the Community. To change which updates are sent to you by mail from the Customer Portal Community, select My Settings from the User Action Menu on top right of main screen. From the resulting My Settings dialogue, click on Email Settings. Please leave the “Receive emails” option checked at all times on top left of this dialogue.';
                showUserForm = false;
            }

        

    }
    /*
    public community_PreferenceController(ApexPages.StandardController stdController) {
        
    }
    */
    public Boolean getIsEdit() {
        return isEdit;
    }
    
    public void edit() {
        isEdit=true;
    }    
    
    public void save() {
        ReportsTo = '';
        if (user.contact != null) {              
            setContactFields(user.contact, user);
        }
        
        try {
            update user;
            if (contact != null) { 
                update contact;
            }
            isEdit=false;
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }

        contact parentContact;
        system.debug('@@@@@@@@@@@@reports to:' + contact.ReportsToId);

        try {
            parentContact = [SELECT firstname, lastname FROM Contact WHERE id =: contact.ReportsToId];
            ReportsTo = parentContact.firstname + ' ' + parentContact.lastname;
            } catch (Exception e) {
                ReportsTo = '';
                parentContact = null;
                system.debug('@@@@@@@@@@@@@error' + e);
            }
    }

    public void cancel() {
        isEdit=false;
        user = [SELECT id, email, username, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
    }

    public void setContactFields(Contact c, User u) {
        c.title = u.title;
        c.firstname = u.firstname;
        c.lastname = u.lastname;
        c.email = u.email;
        c.phone = u.phone;
        c.mobilephone = u.mobilephone;
        c.fax = u.fax;
        c.mailingstreet = u.street;
        c.mailingcity = u.city;
        c.mailingstate = u.state;
        c.mailingpostalcode = u.postalcode;
        c.mailingcountry = u.country;


    }
}