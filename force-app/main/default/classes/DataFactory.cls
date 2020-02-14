/*  @author Serhii Volynets sergey.volinets@weare4c.com
 * @Jira RBX-119
 * This module provides data for Asset Uplift and Beam unit tests
 * Main methods:
 * DataFactory() - constructs DataFactory insteance with data populated
*/
@isTest
public class DataFactory 
{
    @TestVisible private Account acc;
    @TestVisible private FDIC_NCUA_Data__c fdic;   
    @TestVisible private Contact con;
    @TestVisible private Opportunity opp;
    @TestVisible private List<Contract> contracts;
    @TestVisible private RF_Index__c recIndex;
    @TestVisible private List<Uplift__c> uplifts;
    @TestVisible private List<SBQQ__Subscription__c> subs;
    @TestVisible private SBQQ__Quote__c quote;
    @TestVisible private Product2 product;   
    @TestVisible private List<SBQQ__QuoteLine__c> quoteLines;
    @TestVisible private List<Quote_Line_Transaction_Tier__c> tiers;
    @TestVisible private List<Billing_Group__c> bgs;
    @TestVisible private static final String arrears='Arrears';

    
    /*
     * this is a constructor method which initializes data
 	 * @Jira RBX-119
     */
	public DataFactory()
    {
        NS_Revenue_Recognition_Template__c nrrt = new NS_Revenue_Recognition_Template__c(Name = 'POC');
        insert nrrt;//Added NS RevRec template - needed to generate Sales Order
        TestDataFactory.add_NsCurrencyMap();//Added NSCurrency map - needed to generate Sales Order
		fdic = new FDIC_NCUA_Data__c();
        fdic.Total_Assets__c = 2000;
        fdic.Quarter__c =3;
        fdic.Year__c = '2018';
        fdic.Certificate__c = '12345';
        insert fdic; //Added FDIC record before the account it belongs to


        acc = new Account(name = 'uplift test account');
        acc.DH_MSCRM_Hfs_fdic_num__c = '12345';
        insert acc; // Added Account with FDIC number populated
        fdic = new FDIC_NCUA_Data__c();
        fdic.Total_Assets__c = 2000;
        fdic.Quarter__c =4;
        fdic.Year__c = '2018';
        fdic.Certificate__c = '12345';        
        insert fdic; // Added second FDIC record

        con = new Contact(lastname = 'test', Legal_Notifications__c = true, Inactive_Contact__c = false,
            Left_Bank__c = false, Email = 'test@test.com', accountId = acc.Id);
        insert con; //Added contact for given account
        
        opp = new Opportunity(Name = 'uplift test opp', StageName = 'Suspect', CloseDate = Date.today(), Service_Type__c ='Consultancy' );
        insert opp;
        contracts = new List<Contract>();
        Contract contract1 = new Contract(accountId = acc.Id, SBQQ__Opportunity__c = opp.Id,Next_Asset_Uplift_Date__c=Date.today()-300,Asset_Size__c=800,
                Next_Uplift_Date__c = Date.today(), status = 'Draft', ContractTerm = 12);
        contracts.add(contract1);
        Contract contract2 = new Contract(accountId = acc.Id, SBQQ__Opportunity__c = opp.Id,Next_Asset_Uplift_Date__c=Date.today()-300,Asset_Size__c=800,
                Next_Uplift_Date__c = Date.today(), status = 'Draft', ContractTerm = 12);
        contracts.add(contract2);
        Contract contract3 = new Contract(accountId = acc.Id, SBQQ__Opportunity__c = opp.Id,Next_Asset_Uplift_Date__c=Date.today()-300,Asset_Size__c=800,
                Next_Uplift_Date__c = Date.today(), status = 'Draft', Skip_Uplift__c = true, ContractTerm = 12);
        contracts.add(contract3);
        insert contracts;  //Created contracts
        contract1.status = 'Active';
        contract2.status = 'Active';
        contract3.status = 'Active';
        update contracts;  // activated contracts
		
		recIndex = new RF_Index__c();
		insert recIndex;
		
       	uplifts = new List<Uplift__c>();
        Uplift__c uplift1 = new Uplift__c(Exclude__c = true, Override__c = 10, Account__c = acc.Id,Billing_Frequency__c = 'Quarterly',Status__c = 'Pro-Rata',
                Uplift_Application_Date__c = Date.today(), Type__c = 'Custom',Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today().addYears(1), Base_Index__c = recIndex.Id);
        Uplift__c uplift2 = new Uplift__c(Exclude__c = false, Override__c = 15, Account__c = acc.Id,Billing_Frequency__c = 'Semiannual',Status__c = 'Pro-Rata',
                Uplift_Application_Date__c = Date.today(), Type__c = 'Custom',Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today().addYears(1), Base_Index__c = recIndex.Id);
        Uplift__c uplift6 = new Uplift__c(Exclude__c = false, Override__c = 20, Account__c = acc.Id,Billing_Frequency__c = 'Annual', Status__c = 'Pro-Rata',
                Uplift_Application_Date__c = Date.today(), Type__c = 'Custom',Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today().addYears(1), Base_Index__c = recIndex.Id);
        Uplift__c uplift3 = new Uplift__c(Exclude__c = false, Override__c = 20, Account__c = acc.Id,Billing_Frequency__c = 'Annual', Status__c = 'Full Year',
                Uplift_Application_Date__c = Date.today(), Type__c = 'Custom',Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today(), Base_Index__c = recIndex.Id);
        Uplift__c uplift4 = new Uplift__c(Exclude__c = false, Override__c = 25, Account__c = acc.Id, status__c = 'Interim',Billing_Frequency__c = 'Semiannual',
                Uplift_Application_Date__c = Date.today(), Type__c = 'Custom',Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today(), Base_Index__c = recIndex.Id);
        Uplift__c uplift5 = new Uplift__c(Exclude__c = false, Override__c = 30, Account__c = acc.Id, Status__c = 'Pro-Rata',Billing_Frequency__c = 'Annual',
                Uplift_Application_Date__c = Date.today(), Type__c = 'Custom',Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today().addYears(1),Base_Index__c = recIndex.Id);
        uplifts.add(uplift1);
        uplifts.add(uplift2);
        uplifts.add(uplift3);
        uplifts.add(uplift4);
        uplifts.add(uplift5);
        uplifts.add(uplift6);
        insert uplifts; //created Uplift records

        quote = new SBQQ__Quote__c(SBQQ__Account__c = acc.Id, SBQQ__Opportunity2__c = opp.Id);
        insert quote; //created quote
        product = new Product2(Name = 'testProd', SO_Grouping__c = 'ILF-ILF',
                CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561');

        insert product; //added product
		NS_Product__c nsp = new NS_Product__c();
        nsp.NS_Product_Internal_Id__c = '123';
        nsp.Name = '123';
        insert nsp; // added NS product - needed to create sales order items
        quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c line111 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = product.Id);
        SBQQ__QuoteLine__c line112 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = product.Id);
        SBQQ__QuoteLine__c line121 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = product.Id);
        SBQQ__QuoteLine__c line122 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = product.Id);
        SBQQ__QuoteLine__c line123 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = product.Id);
        quoteLines.add(line111);
        quoteLines.add(line112);
        quoteLines.add(line121);
        quoteLines.add(line122);
        quoteLines.add(line123);
        insert quoteLines; //created quote lines
		List<NS_Billing_Frequency__c> bgFreqs = createBillingFrequencies(); // billing fgrequences are needed for recurring sales orders generation
		bgs = newBillingGroup(6); 
        
		Billing_Group__c bg1 = bgs[0];
		bg1.Fixed_Billing_Date__c=System.today();
		bg1.NS_Billing_Frequency__c=bgFreqs[1].id;
		bg1.BG_Client_Contracting_Name__c=acc.id;
		bg1.NS_Subscription_Billing_Method__c='Advance';
		bg1.Original_Contract__c = contracts[0].id;
        bg1.Original_Opportunity__c = opp.id;

		Billing_Group__c bg2 = bgs[1];
		bg2.Fixed_Billing_Date__c=System.today();
		bg2.NS_Billing_Frequency__c=bgFreqs[1].id;
		bg2.BG_Client_Contracting_Name__c=acc.id;
		bg2.NS_Subscription_Billing_Method__c='Advance';
 		bg2.Original_Contract__c = contracts[0].id;  
		bg2.Original_Opportunity__c = opp.id;

		Billing_Group__c bg3 = bgs[2];
		bg3.Fixed_Billing_Date__c=System.today();
		bg3.NS_Billing_Frequency__c=bgFreqs[2].id;
		bg3.BG_Client_Contracting_Name__c=acc.id;
		bg3.NS_Subscription_Billing_Method__c=arrears;
 		bg3.Original_Contract__c = contracts[1].id; 
 		bg3.Original_Opportunity__c = opp.id;       

        Billing_Group__c bg4 = bgs[3];
		bg4.Fixed_Billing_Date__c=System.today();
		bg4.NS_Billing_Frequency__c=bgFreqs[2].id;
		bg4.BG_Client_Contracting_Name__c=acc.id;
		bg4.NS_Subscription_Billing_Method__c=arrears;
  		bg4.Original_Contract__c = contracts[1].id;  
		bg4.Original_Opportunity__c = opp.id;  
        
		Billing_Group__c bg5 = bgs[4];
		bg5.Fixed_Billing_Date__c=System.today();
		bg5.NS_Billing_Frequency__c=bgFreqs[2].id;
		bg5.BG_Client_Contracting_Name__c=acc.id;
		bg5.NS_Subscription_Billing_Method__c=arrears;
   		bg5.Original_Contract__c = contracts[1].id; 
 		bg5.Original_Opportunity__c = opp.id;       

		Billing_Group__c bg6 = bgs[5];
		bg6.Fixed_Billing_Date__c=System.today();
		bg6.NS_Billing_Frequency__c=bgFreqs[2].id;
		bg6.BG_Client_Contracting_Name__c=acc.id;
		bg6.NS_Subscription_Billing_Method__c=arrears;
   		bg6.Original_Contract__c = contracts[2].id;
  		bg6.Original_Opportunity__c = opp.id;
		insert bgs;// billing groups are needed for recurring sales orders generation
        
        NS_Item__c nsItem = TestDataFactory.createNsItem(false);
        nsItem.Legacy_SKU__c = '1234';
        nsItem.NS_Item_Name__c = 'US Payment: Test Core';
        nsItem.NS_Product_Dimension_ID__c = '123';
        insert nsItem;    // NS items are needed for  sales order items creation  
		subs = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub11 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract1.Id, SBQQ__Quantity__c = 1,Billing_Group__c = bgs[0].Id,Uplift_Multiplier__c = 200, RLF_Uplift_Multiplier_Percent__c = 0.01,
                Transactional__c = true, CPI_Uplift__c = uplift1.Id, Exclude__c = false); //tiers, skipped because uplift not active
        SBQQ__Subscription__c sub12 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract1.Id, SBQQ__Quantity__c = 1,Billing_Group__c = bgs[1].Id,Uplift_Multiplier__c = 200, RLF_Uplift_Multiplier_Percent__c = 0.01,
                Transactional__c = true, CPI_Uplift__c = uplift2.Id, Exclude__c = false, Billing_Method__c = 'Asset'/*,RLF_Asset_Size__c = 500*/, /*ILF_Asset_Size__c=800,*/Sold_Value__c=10); // tiers
        SBQQ__Subscription__c sub21 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract2.Id, SBQQ__Quantity__c = 1,Billing_Group__c = bgs[2].Id,Uplift_Multiplier__c = 200, RLF_Uplift_Multiplier_Percent__c = 0.01,
                Transactional__c = false, CPI_Uplift__c = uplift3.Id, SBQQ__NetPrice__c = 300, Exclude__c = false, Billing_Method__c = 'Asset'/*,RLF_Asset_Size__c = 500*/, /*ILF_Asset_Size__c=800,*/Sold_Value__c=80);
        SBQQ__Subscription__c sub22 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract2.Id, SBQQ__Quantity__c = 1,Billing_Group__c = bgs[3].Id,Uplift_Multiplier__c = 200, RLF_Uplift_Multiplier_Percent__c = 0.01,
                Transactional__c = false, CPI_Uplift__c = uplift4.Id, SBQQ__NetPrice__c = 400, Exclude__c = false, Billing_Method__c = 'Asset'/*,RLF_Asset_Size__c = 500*/, /*ILF_Asset_Size__c=800,*/Sold_Value__c=80);
        SBQQ__Subscription__c sub23 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract2.Id, SBQQ__Quantity__c = 1,Billing_Group__c = bgs[4].Id,Uplift_Multiplier__c = 200, RLF_Uplift_Multiplier_Percent__c = 0.01,
                Transactional__c = false, CPI_Uplift__c = uplift5.Id, SBQQ__NetPrice__c = 500, Exclude__c = false);
        SBQQ__Subscription__c sub24 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract2.Id, SBQQ__Quantity__c = 1,Billing_Group__c = bgs[4].Id,Uplift_Multiplier__c = 200, RLF_Uplift_Multiplier_Percent__c = 0.01,
                Transactional__c = false, CPI_Uplift__c = uplift5.Id, SBQQ__NetPrice__c = 500, Exclude__c = true);
        SBQQ__Subscription__c sub31 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract3.Id, SBQQ__Quantity__c = 1,Billing_Group__c = bgs[5].Id,Uplift_Multiplier__c = 200, RLF_Uplift_Multiplier_Percent__c = 0.01,
                Transactional__c = false, CPI_Uplift__c = uplift5.Id, SBQQ__NetPrice__c = 500, Exclude__c = false);
        subs.add(sub11);
        subs.add(sub12);
        subs.add(sub21);
        subs.add(sub22);
        subs.add(sub23);
        subs.add(sub24);
        subs.add(sub31);
        for(SBQQ__Subscription__c sub : subs)
        {
            sub.Inital_NS_Item__c =nsItem.id;
            
        }
        insert subs; //subscriptions are needed for recurring sales order generation

        tiers = new List<Quote_Line_Transaction_Tier__c>();
        Quote_Line_Transaction_Tier__c tier111 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub11.Id,Lower_Bound__c = 0,
                Quote_Line__c = line111.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 100);
        Quote_Line_Transaction_Tier__c tier112 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub11.Id,Lower_Bound__c = 0,
                Quote_Line__c = line112.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 150);
        Quote_Line_Transaction_Tier__c tier121 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub12.Id,Lower_Bound__c = 0,
                Quote_Line__c = line121.Id, Start_Date__c = Date.today().addDays(5), Unit_Price__c = 200); // not included in calc
        Quote_Line_Transaction_Tier__c tier122 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub12.Id,Lower_Bound__c = 0,
                Quote_Line__c = line122.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 300);
        Quote_Line_Transaction_Tier__c tier123 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub12.Id,Lower_Bound__c = 0,
                Quote_Line__c = line123.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 400);

        tiers.add(tier111);
        tiers.add(tier112);
        tiers.add(tier121);
        tiers.add(tier122);
        tiers.add(tier123);
        insert tiers; //QLTT are needed for SO generation
    }
 
    /*
     * this method creates the list of NS_Billing_Frequency__c with Frequency types
     * @return list of NS_Billing_Frequency__c with Frequency types
     */
    	private static List<NS_Billing_Frequency__c> createBillingFrequencies() 
        {
		List<NS_Billing_Frequency__c> bgFreqs = new List<NS_Billing_Frequency__c>();
		NS_Billing_Frequency__c bgFreq1 = new NS_Billing_Frequency__c();
		bgFreq1.Name='Yearly';
		bgFreqs.add(bgFreq1);
		NS_Billing_Frequency__c bgFreq2 = new NS_Billing_Frequency__c();
		bgFreq2.Name='Semi-Annually';
		bgFreqs.add(bgFreq2);
		NS_Billing_Frequency__c bgFreq3 = new NS_Billing_Frequency__c();
		bgFreq3.Name='Monthly';
		bgFreqs.add(bgFreq3);
		NS_Billing_Frequency__c bgFreq4 = new NS_Billing_Frequency__c();
		bgFreq4.Name='Quarterly';
		bgFreqs.add(bgFreq4);
		NS_Billing_Frequency__c bgFreq5 = new NS_Billing_Frequency__c();
		bgFreq5.Name='Biennial';
		bgFreqs.add(bgFreq5);
		NS_Billing_Frequency__c bgFreq6 = new NS_Billing_Frequency__c();
		bgFreq6.Name='Triennial';
		bgFreqs.add(bgFreq6);
		insert bgFreqs;
		return bgFreqs;
	}
    
	public static list<Billing_Group__c> newBillingGroup(integer cnt)
	{
        list<Billing_Group__c> lbg = new list<Billing_Group__c>();
        list<Billing_Entity__c> lbe = new list<Billing_Entity__c>();
        for(integer i=0; i<cnt; i++)
        {
            Billing_Entity__c be = new Billing_Entity__c();
            lbe.add(be);
        }
        insert lbe;
        for(integer i=0; i<cnt; i++)
        {
            Billing_Entity__c be = lbe.get(i);
            Billing_Group__c bg = new Billing_Group__c(BG_Misys_Billing_Entity__c = be.id);
            lbg.add(bg);
        }
 //       insert lbg;
		return lbg;
	}
	
}