public class community_ViewAttachmentController {
    public Attachment att {get; set;}
    public String attachmentSize {get; set;}
    public String ownerName {get; set;}

    public community_ViewAttachmentController() {
        att = [SELECT Id, Name, contenttype,createdDate,ownerId, description, bodylength FROM attachment where id = : ApexPages.currentPage().getParameters().get('AttId')];
        system.debug('att = ' + att);
        if(att!=NULL)
        {
            list<User> ownNameList = [SELECT Name FROM user WHERE Id = : att.ownerId];
            if(ownNameList != null && ownNameList.size() > 0)
                ownerName = ownNameList[0].Name;
                //ownerName = [SELECT Name FROM user WHERE Id = : att.ownerId].Name;
        }
        double d = Math.round(att.bodylength/1000);
        integer i = integer.ValueOf(d);
        attachmentSize = string.ValueOf(i);

    }
}