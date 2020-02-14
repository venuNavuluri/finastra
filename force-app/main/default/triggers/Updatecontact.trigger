trigger Updatecontact on User (after insert, after update)
{
    if(Trigger.isInsert && Trigger.isAfter)
    {
        UserTriggerMethods.PortalUserCreated(Trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isAfter)
    {
               
        if(Userinfo.getUserType() == 'PowerCustomerSuccess' || Userinfo.getLastName().contains('Portal (Kim)'))
        { 
          UserTriggerMethods.UserUpdateToContact(Trigger.oldMap, Trigger.newMap);
        }
    }
    
    UserTriggerMethods.UpdateUserContactLicenseFlag(Trigger.oldMap, Trigger.newMap);
}