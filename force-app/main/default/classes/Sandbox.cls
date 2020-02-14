global class Sandbox
{
    final static string GEN_PRODUCTSET_NAME = 'General Product Set';
    final static string DUMMY_SYSTEM_NAME = 'WAFASALAF-MOROCCO::SYS::Prod::K Products::';
    final static string DUMMY_ENTITLEMENT_NAME = 'WAFASALAF-MOROCCO::SE::Prod::Kondor Trade Processing';
    final static string CONSTANT_EXTID_PRODUCTSET = 'DUMMY PRODUCT SET ID';
    final static string CONSTANT_EXTID_SYSTEM = 'DUMMY SYSTEM ID';
    final static string CONSTANT_EXTID_ENTITLEMENT = 'DUMMY_ENTITLEMENT_ID';

    webservice static Integer FoobarPartnerEmails()
    {
        System.debug('@@@ called SandboxService.FoobarPartnerEmails...');
        User[] mbsDataAdmins = [
            select Id, UserName from User
            where LastName = 'Carousel'
            and Profile.Name = 'MBS DataAdmin'
            and isActive = true
        ];
        if (mbsDataAdmins == null || mbsDataAdmins.size() == 0) { return -1; }
        System.runAs(mbsDataAdmins[0]) {
            for (Partner_Approvals_Renewals__c[] approvals : [Select p.Partner_Email__c, p.Id From Partner_Approvals_Renewals__c p]) {
                for (Partner_Approvals_Renewals__c a : approvals) {
                    if (a.Partner_Email__c != null) { a.Partner_Email__c = 'foobar@foobar.com'; }
                }
                update approvals;
            }
        }
        return 0;
    } 

    webservice static void Initialize()
    {
        System.debug('@@@ called SandboxService.Initialize...');
        SetupConstantsRecords();
        SetupBigDealAlerts();
    }
    
    private static void SetupConstantsRecords()
    {
        Constants__c[] constantsRecords =
          [select Name, ExternalId__c, Value__c
           from Constants__c
           where ExternalId__c in (:CONSTANT_EXTID_PRODUCTSET, :CONSTANT_EXTID_SYSTEM, :CONSTANT_EXTID_ENTITLEMENT)];
        
        Map<String, Constants__c> constantsMap = new Map<String, Constants__c>();
        for (Constants__c c : constantsRecords) {
          constantsMap.put(c.ExternalId__c, c);
        }
        
        Product_Set__c prSet = [select Id, Name from Product_Set__c where Name = :GEN_PRODUCTSET_NAME];
        constantsMap.get(CONSTANT_EXTID_PRODUCTSET).Value__c = prSet.Id;
        
        update constantsRecords;
    }
    
    private static void SetupBigDealAlerts()
    {
        Group gr = [Select g.Name, g.Id From Group g where name = 'Big Deal Alert'];
        CollaborationGroup chatterGroup = [Select c.Name, c.Id From CollaborationGroup c where name = 'Big Deal Alerts'];
        
        ChatterBigDealAlertSettings__c chatterSettings = [
            Select c.Name, c.Id, c.ExternalId__c, c.Big_Deal_Alert_Chatter_Group__c, c.AutoSubscribeGroupId__c
            From ChatterBigDealAlertSettings__c c
            where ExternalId__c = 'Default'
        ];
        
        chatterSettings.AutoSubscribeGroupId__c = gr.id;
        chatterSettings.Big_Deal_Alert_Chatter_Group__c = chatterGroup.id;
        
        update chatterSettings;
    }
}