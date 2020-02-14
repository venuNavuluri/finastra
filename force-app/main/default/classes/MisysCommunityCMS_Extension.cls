public with sharing class MisysCommunityCMS_Extension {

    public Document document {get; set;}
    public String url {get; set;}
    private Community_Homepage_CMS__c cms_content;
    Public transient Attachment myfile;


    Public Attachment getmyfile(){
        myfile = new Attachment();
        return myfile;
    }
	
    public MisysCommunityCMS_Extension(ApexPages.StandardController stdController) {
        document = new document();
        this.cms_content = (Community_Homepage_CMS__c)stdController.getRecord();
    }

    public MisysCommunityCMS_Extension() {
        
    }

    public pageReference Save() {

        //cms_content.Is_Lead_Feature__c = false;
        insert cms_content;

        if(myfile.name != null && myfile.name != '') {
            Attachment a = new Attachment(parentId = cms_content.Id, name=myfile.name, body = myfile.body);
            insert a;
        }
        
        PageReference pageRef = new PageReference('/a4B/o');
        return pageRef;
    }

   
}