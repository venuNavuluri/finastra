@isTest
public class TestUtils 
{
    public static Account getAccount(String name)
    {
        Account a = new Account();
        a.Name = name;
        a.BillingCountry = 'United States';
        a.ShippingCountry = 'United States';
        
        return a;
    }
    
    public static Contact getContact(Account a)
    {
        return getContact(a, 'ut Contact 1');
    }
   
    public static Contact getContact(Account a, String name)
    {
        //CONSTANTS.DISABLE_INDIVIDUAL_TRIGGER = true;
        Contact c = new Contact();
        c.AccountID = a.id;
        c.LastName = name;
        c.Salutation = 'Mr.';
        return c;
    }
    
    public static Project__c getProject(Account a)
    {
        Project__c p = new Project__c();
        p.Account__c = a.id;
        
        return p;
    }
    
    public static Product2 getProduct(String name)
    {
        Product2 p = new Product2();
        p.Name = name;
        p.IsActive = true;
        p.Use_On_Case__c = true;
        p.Asset_Created_for_Product__c = true;
        return p;
    }
    
    public static Product2 getProduct(String name, String familyName)
    {
        Product2 p = getProduct(name);
        p.Family = familyName;
        return p;
    }
    
    
    public static Opportunity getOpportunity(Account a, String name)
    {
        Opportunity oppty = new Opportunity();
        oppty.AccountID = a.id;
        oppty.Name = name;
        oppty.StageName = 'Plan';
        oppty.CloseDate = Date.Today().addMonths(2);
        oppty.Legal_Review__c = 'Approved';
        oppty.Order_Type__c = Constants.ORDER_TYPE_NEW_PRODUCT;
       // Intacct_Entity__c ie = getIntacctEntity();
      //  insert ie;
       // oppty.Intacct_Entity__c = ie.id;
        return oppty;
    }
    
    public static Id getStandardPriceBookId()
    {

        return test.getStandardPricebookId();
        
    }
    public static PriceBook2 getStandardPriceBook()
    {
        PriceBook2 pb = [Select Id, Name from PriceBook2 where isStandard =: true];
        return pb;
    }
    
    public static PriceBookEntry getPriceBookEntry(Product2 p, Id pbId)
    {
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.PriceBook2ID = pbId;
        pbe.Product2Id = p.id;
        pbe.UnitPrice = 1;
        pbe.isActive = true;
        return pbe;
    }
    
    /*
    public static Quote_Group__c getQuoteGroup(Opportunity oppty)
    {
        Quote_Group__c qp = new Quote_Group__c();
        qp.Opportunity__c = oppty.id;
        
        return qp;
    }
    */
    
    public static OpportunityLineItem getOLI(Opportunity oppty)
    {
        Product2 p = getProduct('ut prod1');
        insert p;
        Id pbId = getStandardPriceBookId();
        PriceBookEntry pbe = getPriceBookEntry(p, pbId);
        insert pbe;
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityID = oppty.id;
        oli.PriceBookEntryID = pbe.id;
        oli.Quantity = 1;
        oli.TotalPrice = 1;
        return oli;
    }
    
    public static OpportunityLineItem getOLI(Opportunity oppty, Product2 p)
    {
        Id pbId = getStandardPriceBookId();
        PriceBookEntry pbe = getPriceBookEntry(p, pbId);
        insert pbe;
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityID = oppty.id;
        oli.PriceBookEntryID = pbe.id;
        oli.Quantity = 1;
        oli.TotalPrice = 1;
        return oli;
    }
    
    public static Case getCase(Account a)
    {
        //CONSTANTS.DISABLE_INDIVIDUAL_TRIGGER = true;
        Contact c = getContact(a, 'ut contact 1');
        insert c;
        
        return getCase(a,  c);
    }
    
    public static Case getCase(Account a, Contact c)
    {
        Case cs = new Case();
        cs.AccountId = a.id;
        cs.ContactId = c.id;
        
        return cs;
    }
    
    public static Attachment getAttachment(String parentID)
    {
        Attachment att = new Attachment();
        att.Name = 'Unit Test Att';
        att.Body = Blob.valueOf(att.Name);
        att.parentId = parentId;
        
        return att;
    }
    
    public static CaseComment getCaseComment(Case cs)
    {
        CaseComment cc = new CaseComment();
        cc.ParentID = cs.id;
        cc.CommentBody = 'some comment';
        cc.IsPublished = true;
        return cc;
    }
 
    /*   
    public static Entitlement__c getEntitlement(Account a)
    {
        return getEntitlement(a, 'ut ent1');
    }
    
    public static Entitlement__c getEntitlement(Account a, String name)
    {
        Entitlement__c ent = new Entitlement__c();
        ent.Name = name;
        ent.Account__c = a.id;
        ent.StartDate = Date.Today();
        ent.EndDate = Date.Today().addDays(30);
        
        return ent;
    }
    */
    
    public static System__c getSystem(Account a, String name)
    {
        System__c sys = new System__c();
        sys.Account__c = a.id;
        sys.Name = name;
        return sys;
    }
    
    public static Contract_Asset__c getAsset(Account a, Product2 p, System__c sys)
    {
        Contract_Asset__c ast = new Contract_Asset__c();
        ast.System__c = sys.id;
        ast.Account__c = a.id;
        ast.Maintenance_Status__c = Constants.STATUS_ON_MAINTENANCE;
        ast.Billing_Frequency__c = 'monthly';
        return ast;
    }
    
    //public static Additional_Environment__c getAdditionalEnvironment(Account a, System__c sys, String name)
    //{
    //  Additional_Environment__c ae = new Additional_Environment__c();
    //  ae.Account__c = a.id;
    //  ae.System__c = sys.id;
    //  ae.Cost_Percentage_of_Base__c = 10;
    //  ae.Name = name;
    //  return ae;
    //}
    
    //public static Additional_Environment_Asset_Junction__c getEnvironmentAssetJunction(Additional_Environment__c ae, Contract_Asset__c ast)
    //{
    //  Additional_Environment_Asset_Junction__c aeaj = new Additional_Environment_Asset_Junction__c();
    //  aeaj.Additional_Environment__c = ae.id;
    //  aeaj.Contract_Asset__c = ast.id;
    //  return aeaj;
    //}
    
    /*
    public static Product_Version__c getVersion(Product2 p, String version)
    {
        Product_Version__c v1 = new Product_Version__c();
        v1.Product__c = p.id;
        v1.Name = version;
        v1.Version_Code__c = version;
        return v1;
    }
        
    public static Component__c getComponent(Product2 p, String name)
    {
        Component__c comp1 = new Component__c();
        comp1.Product__c = p.id;
        comp1.Name = name;
        return comp1;
    }
    */
       
    public static Case getCase()
    {
        Case c = new Case();
        return c;
    }
    
    /*
    public static Case getCase(Account a, Contact cnt, Project__c prj, Entitlement ent, System__c sys, Contract_Asset__c ast, Additional_Environment__c ae, Product_Version__c pv, Component__c comp)
    {
        Case c = new Case();
        c.AccountID = a.id;
        c.ContactID = cnt.id;
        c.Project__c = prj.id;
        c.EntitlementID = ent.id;
        c.System__c = sys.id;
        c.Asset__c = ast.id;
        c.Additional_Environment__c = ae.id;
        c.Version__c = pv.id;
        c.Component_Name__c = comp.id;
        c.ProductId = pv.Product__c;
        return c;
    }
    */
    
    public static CaseComment getCaseComment()
    {
        CaseComment cc = new CaseComment();
        cc.CommentBody = 'boyd text';
        return cc;
    }
    
    public static User getTestUser(String userName, String profileName)
    {
        String profileId;
        try
        {
            profileId = [SELECT Id FROM Profile WHERE Name like: '%'+profileName+'%' limit 1].Id;
        }
        catch(Exception ex)
        {
            System.debug(ex);
            System.assert(false, 'No profile exists with name '+ profileName);
        }
        User testUser = new User();
        testUser.LastName = 'test ' + UserName;
        testUser.Alias = UserName;  
        testUser.Email = UserName+'@accruent.com';
        testUser.Username = UserName+UserName+'@test.com';
        testUser.CommunityNickname = 'a'+UserName;
        testUser.TimeZoneSidKey = 'America/New_York';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.ProfileId = profileId;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.IsActive = true;
        
        return testUser;    
    }
    
    public static User getAdminUser(String adminName)
    {
        return getTestUser(adminName, 'System Administrator');
    }
    
    public static User getStandardInternalUser(String repName)
    {
        return getTestUser(repName, 'Standard User');
    }
    
    public static User getCustomerPortalUser(String repName, Contact c)
    {
        User portalUser = getTestUser(repName, 'Customer Portal Manager Custom');
        portalUser.ContactID = c.id;
        portalUser.portalRole = 'Executive';
         
        return portalUser;
    }
    
    /*
    public static Case_History__c getCaseHistory(Case c, String fromValue , String toValue, String field)
    {
        Case_History__c ch = new Case_History__c();
        ch.Case__c = c.id;
        ch.From__c = fromValue;
        ch.To__c = toValue;
        ch.Field__c = field;
        ch.User__c = UserInfo.getUserId();
        return ch;
        
    }
    */
    
    /*public static Intacct_Entity__c getIntacctEntity()
    {
        Intacct_Entity__c ie = new Intacct_Entity__c();
        return ie;
    }*/
    
    public static Contract getContract(Account a)
    {
        Contract ctrct = new Contract();
        ctrct.AccountID = a.id;
        return ctrct;
    }
    
    public static Bill_To_Ship_To__c getBillToShipTo(Account a)
    {
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c();
        btst.Account__c = a.id;
        btst.Subscriber_Sub_Account_Number__c = DateTime.now().format().trim().substring(0,10);//thsi has to be a unqiue number
        
        return btst;
    }
    
}