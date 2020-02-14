/**
 * @File Name          : Uplift_TestUtils.cls
 * @Description        : 
 * @Author             : venu.navuluri@finastra.com
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 25/07/2019, 10:37:16
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    04/06/2019, 10:58:50   venu.navuluri@finastra.com     Initial Version
**/
@isTest
public class Uplift_TestUtils{

    public class BaseData{
        public Id uplift1Id { get; set; }

        public Id sub21Id { get; set; }
        public Id sub22Id { get; set; }
        public Id sub23Id { get; set; }
        public Id sub24Id { get; set; }
        public Id sub31Id { get; set; }

        public Id line111Id { get; set; }
        public Id line112Id { get; set; }
        public Id line121Id { get; set; }
        public Id line122Id { get; set; }
        public Id line123Id { get; set; }

        public BaseData(){}
    }

    public class ResultData{
        public Map<Id, Quote_Line_Transaction_Tier__c> resultQLineToTiers{ get; set; }
        public Map<Id, SBQQ__Subscription__c> resultSubscriptions{ get; set; }
        public Uplift__c resultUplift{ get; set; }
    }

    public static BaseData SetupBasicScenario(){

        BaseData baseData = new BaseData();
        Account account = new Account(name = 'uplift test account');
        insert account;
        Contact c = new Contact(lastname = 'test', Legal_Notifications__c = true, Inactive_Contact__c = false,
            Left_Bank__c = false, Email = 'test@test.com', accountId = account.Id);
        insert c;
        Opportunity opp = new Opportunity(Name = 'uplift test opp', StageName = 'Suspect', CloseDate = Date.today());
        insert opp;
        List<Contract> contracts = new List<Contract>();
        Contract contract1 = new Contract(accountId = account.Id, SBQQ__Opportunity__c = opp.Id,
                Next_Uplift_Date__c = Date.today(), status = 'Draft', ContractTerm = 12);
        contracts.add(contract1);
        Contract contract2 = new Contract(accountId = account.Id, SBQQ__Opportunity__c = opp.Id,
                Next_Uplift_Date__c = Date.today(), status = 'Draft', ContractTerm = 12);
        contracts.add(contract2);
        Contract contract3 = new Contract(accountId = account.Id, SBQQ__Opportunity__c = opp.Id,
                Next_Uplift_Date__c = Date.today(), status = 'Draft', Skip_Uplift__c = true, Recurring_Fees_Index_Type__c = Constants.RF_INDEX_TYPE_NO_INCREASE, ContractTerm = 12);
        contracts.add(contract3);
        insert contracts;
        contract1.status = 'Active';
        contract2.status = 'Active';
        contract3.status = 'Active';
        update contracts;
        
        RF_Index__c recIndex = new RF_Index__c();
        insert recIndex;
        
        List<Uplift__c> uplifts = new List<Uplift__c>();
        Uplift__c uplift1 = new Uplift__c(Exclude__c = true, Override__c = 10, Account__c = account.Id,Billing_Frequency__c = 'Quarterly',Status__c = 'Interim',Uplift_Factor__c=1,
                Uplift_Application_Date__c = Date.today(), Type__c = 'Custom',Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today().addYears(1), Base_Index__c = recIndex.Id);
        Uplift__c uplift2 = new Uplift__c(Exclude__c = false, Override__c = 15, Account__c = account.Id,Billing_Frequency__c = 'Semiannual',Status__c = 'Pro-Rata',
                Uplift_Application_Date__c = Date.today(), Type__c = 'Custom',Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today().addYears(1), Base_Index__c = recIndex.Id);
        Uplift__c uplift6 = new Uplift__c(Exclude__c = false, Override__c = 20, Account__c = account.Id,Billing_Frequency__c = 'Annual', Status__c = 'Interim',
                Uplift_Application_Date__c = Date.today(), Type__c = 'Custom',Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today().addYears(1), Base_Index__c = recIndex.Id);
        Uplift__c uplift3 = new Uplift__c(Exclude__c = false, Override__c = 20, Account__c = account.Id,Billing_Frequency__c = 'Annual', Status__c = 'Full Year',
                Uplift_Application_Date__c = Date.today(), Type__c = 'Custom',Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today(), Base_Index__c = recIndex.Id);
        Uplift__c uplift4 = new Uplift__c(Exclude__c = false, Override__c = 25, Account__c = account.Id, Status__c = 'Interim',Billing_Frequency__c = 'Semiannual',Uplift_Factor__c=1,
                Uplift_Application_Date__c = Date.today(), Type__c = 'Custom',Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today(), Base_Index__c = recIndex.Id);
        Uplift__c uplift5 = new Uplift__c(Exclude__c = false, Override__c = 30, Account__c = account.Id, Status__c = 'Pro-Rata',Billing_Frequency__c = 'Annual',
                Uplift_Application_Date__c = Date.today(), Type__c = 'Custom',Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today().addYears(1),Base_Index__c = recIndex.Id);
        uplifts.add(uplift1);
        uplifts.add(uplift2);
        uplifts.add(uplift3);
        uplifts.add(uplift4);
        uplifts.add(uplift5);
        uplifts.add(uplift6);
        insert uplifts;
        baseData.uplift1Id = uplift1.Id;        

        List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub11 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract1.Id, SBQQ__Quantity__c = 1,
                Transactional__c = true, CPI_Uplift__c = uplift1.Id,  Fair_Value__c=30,Exclude__c = false,Billing_Status__c='Active billing'); //tiers, skipped because uplift not active
        SBQQ__Subscription__c sub12 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract1.Id, SBQQ__Quantity__c = 1,
                Transactional__c = true, CPI_Uplift__c = uplift2.Id,  Fair_Value__c=30, Exclude__c = false,Billing_Status__c='Active billing'); // tiers
        SBQQ__Subscription__c sub21 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract2.Id, SBQQ__Quantity__c = 1,
                Transactional__c = false, CPI_Uplift__c = uplift3.Id, Fair_Value__c=30,SBQQ__NetPrice__c = 300, Exclude__c = false,Billing_Status__c='Active billing');
        SBQQ__Subscription__c sub22 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract2.Id, SBQQ__Quantity__c = 1,
                Transactional__c = false, CPI_Uplift__c = uplift4.Id,  Fair_Value__c=30, SBQQ__NetPrice__c = 400, Exclude__c = false,Billing_Status__c='Active billing');
        SBQQ__Subscription__c sub23 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract2.Id, SBQQ__Quantity__c = 1,
                Transactional__c = false, CPI_Uplift__c = uplift5.Id,  Fair_Value__c=30, SBQQ__NetPrice__c = 500, Exclude__c = false,Billing_Status__c='Active billing');
        SBQQ__Subscription__c sub24 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract2.Id, SBQQ__Quantity__c = 1,
                Transactional__c = false, CPI_Uplift__c = uplift5.Id,  Fair_Value__c=30, SBQQ__NetPrice__c = 500, Exclude__c = true,Billing_Status__c='Active billing');
        SBQQ__Subscription__c sub31 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract3.Id, SBQQ__Quantity__c = 1,
                Transactional__c = false, CPI_Uplift__c = uplift5.Id,  Fair_Value__c=30, SBQQ__NetPrice__c = 500, Exclude__c = false,Billing_Status__c='Active billing');
        subs.add(sub11);
        subs.add(sub12);
        subs.add(sub21);
        subs.add(sub22);
        subs.add(sub23);
        subs.add(sub24);
        subs.add(sub31);
        insert subs;

        baseData.sub21Id = sub21.Id;
        baseData.sub22Id = sub22.Id;
        baseData.sub23Id = sub23.Id;
        baseData.sub24Id = sub24.Id;
        baseData.sub31Id = sub31.Id;

        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = account.Id, SBQQ__Opportunity2__c = opp.Id);
        insert quote;
        Product2 product = new Product2(Name = 'testProd', SO_Grouping__c = 'ILF-ILF',
                CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561');
        insert product;

        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
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
        insert quoteLines;

        baseData.line111Id = line111.Id;
        baseData.line112Id = line112.Id;
        baseData.line121Id = line121.Id;
        baseData.line122Id = line122.Id;
        baseData.line123Id = line123.Id;

        List<Quote_Line_Transaction_Tier__c> tiers = new List<Quote_Line_Transaction_Tier__c>();
        Quote_Line_Transaction_Tier__c tier111 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub11.Id,
                Quote_Line__c = line111.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 100,Price__c=100,Minimum_Price__c=100);
        Quote_Line_Transaction_Tier__c tier112 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub11.Id,
                Quote_Line__c = line112.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 150,Price__c=100,Minimum_Price__c=100);
        Quote_Line_Transaction_Tier__c tier121 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub12.Id,
                Quote_Line__c = line121.Id, Start_Date__c = Date.today().addDays(5), Unit_Price__c = 200,Price__c=100,Minimum_Price__c=100); // not included in calc
        Quote_Line_Transaction_Tier__c tier122 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub12.Id,
                Quote_Line__c = line122.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 300,Price__c=100,Minimum_Price__c=100);
        Quote_Line_Transaction_Tier__c tier123 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub12.Id,
                Quote_Line__c = line123.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 400,Price__c=100,Minimum_Price__c=100);

        tiers.add(tier111);
        tiers.add(tier112);
        tiers.add(tier121);
        tiers.add(tier122);
        tiers.add(tier123);
        insert tiers;

        return baseData;
    }
	
    public static ResultData queryCreatedArtifacts(Id uplift1Id)
    {
        ResultData result = new ResultData();

        List<Quote_Line_Transaction_Tier__c> resultTiers = [
                select id, Subscription__c, Quote_Line__c, Unit_Price__c
                from Quote_Line_Transaction_Tier__c
        ];

        result.resultQLineToTiers = new Map<Id, Quote_Line_Transaction_Tier__c>();

        for(Quote_Line_Transaction_Tier__c tier : resultTiers){
            result.resultQLineToTiers.put(tier.Quote_Line__c, tier);
        }

        result.resultSubscriptions = new Map<Id, SBQQ__Subscription__c>([select id, CPI_Uplift__c,Fair_Value__c, SO_Amount__c,
                SBQQ__NetPrice__c, Exclude__c from SBQQ__Subscription__c]);

        result.resultUplift = [select id, Exclude__c from Uplift__c where id = :uplift1id];
        return result;
    }
}