trigger UserTrigger on User (after insert, after update) 
{
    Map<Id,User> mobilePhoneAppUsersMap = new Map<Id,User>();
    Map<Id,User> u2FKeyUsersMap = new Map<Id,User>();

    if(Trigger.isAfter && trigger.isUpdate){
        for(User newUser: Trigger.new){
            if(newUser.UserType  == 'Standard' && newUser.Authentication_Mechanism__c!= Null && !(newUser.Exempt_from_2FA__c)){
                system.debug('Old record authentication mechanism -->> ' + Trigger.oldMap.get(newUser.id).Authentication_Mechanism__c);
                if(!newUser.Authentication_Mechanism__c.equals(Trigger.oldMap.get(newUser.id).Authentication_Mechanism__c) && newUser.Authentication_Mechanism__c.equals('Mobile Phone App') ){
                    mobilePhoneAppUsersMap.put(newUser.Id,newUser);
                }else if(newUser.Apply_U2F_Key_Authentication__c!=Trigger.oldMap.get(newUser.id).Apply_U2F_Key_Authentication__c && newUser.Apply_U2F_Key_Authentication__c && newUser.Authentication_Mechanism__c.equals('U2F Key')){
                    u2FKeyUsersMap.put(newUser.Id,newUser);
                }
            }
        }
        if(mobilePhoneAppUsersMap.size()>0 || u2FKeyUsersMap.size()>0){
            UserTriggerHelper.processUserForTwoFA(mobilePhoneAppUsersMap,u2FKeyUsersMap);
        }
    }
}