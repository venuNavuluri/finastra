@isTest
public with sharing class test_CapiWhitespaceKeyChange
{
	private static Account testAccount;
	private static Acct_Profile__c ap;
	private static Profile_Whitespace__c[] pwArray;
	private static Profile_details__c pd;
	
	private static void setUp()
	{
        testAccount = TestUtility.sampleAccount();
        testAccount.Institution_Type__c = 'Sell-Side';
        testAccount.Pyramid_Tier__c = 'Tier 3';
        testAccount.Business_Footprint__c = 'Multi-regional';
        insert testAccount;
        
        ap = new Acct_Profile__c(Account__c = testAccount.Id);
        insert ap;
        
        pwArray = new Profile_Whitespace__c[]{
	       	new Profile_Whitespace__c(Name = 'SELL-SIDE3MULTI-REGIONALSYNDICATED LENDING', Product__c = 'TestProduct1'),
	       	new Profile_Whitespace__c(Name = 'BUY-SIDE3MULTI-REGIONALSYNDICATED LENDING', Product__c = 'TestProduct2'),
	       	new Profile_Whitespace__c(Name = 'SELL-SIDE1MULTI-REGIONALSYNDICATED LENDING', Product__c = 'TestProduct3'),
	       	new Profile_Whitespace__c(Name = 'SELL-SIDE3GLOBALSYNDICATED LENDING', Product__c = 'TestProduct4'),
	       	new Profile_Whitespace__c(Name = 'SELL-SIDE3MULTI-REGIONALBRANCH BANKING', Product__c = 'TestProduct5')
        };
        insert pwArray;
        
        pd = new Profile_details__c(Acct_Profile__c = ap.Id, Selection__c = 'Lending', Business_Area__c = 'Syndicated Lending', Solution_Type__c = 'Misys', Score__c = '12');
        insert pd;
        
        Profile_details__c updatedPd = queryUpdatedProfDetail(pd.Id);
        System.assertEquals('TestProduct1', updatedPd.Whitespace__r.Product__c);
	}
	
	
	private static Profile_details__c queryUpdatedProfDetail(Id pdid)
	{
        Profile_details__c updatedPD = [select InstitutionFootprint__c, Whitespace__r.Product__c from Profile_details__c where Id = :pdid];
        System.debug('@@@ InstitutionFootprint__c: ' + updatedPd.InstitutionFootprint__c);
        return updatedPD;
	}
	 
	
	public static testmethod void testAccountInstitutionTypeChange()
	{
		setUp();
		testAccount.Institution_Type__c = 'Buy-Side';
		update testAccount;

        Profile_details__c updatedPd = queryUpdatedProfDetail(pd.Id);
        System.assertEquals('TestProduct2', updatedPd.Whitespace__r.Product__c);
	}

	public static testmethod void testAccountPyramidTierChange()
	{
		setUp();
		testAccount.Pyramid_Tier__c = '1';
		update testAccount;

        Profile_details__c updatedPd = queryUpdatedProfDetail(pd.Id);
        System.assertEquals('TestProduct3', updatedPd.Whitespace__r.Product__c);
	}

	public static testmethod void testAccountBusinessFootprintChange()
	{
		setUp();
		testAccount.Business_Footprint__c = 'Global';
		update testAccount;

        Profile_details__c updatedPd = queryUpdatedProfDetail(pd.Id);
        System.assertEquals('TestProduct4', updatedPd.Whitespace__r.Product__c);
	}

	public static testmethod void testProfDetailsBusinessAreaChange()
	{
		setUp();
		pd.Business_Area__c = 'Branch Banking';
		update pd;

        Profile_details__c updatedPd = queryUpdatedProfDetail(pd.Id);
        System.assertEquals('TestProduct5', updatedPd.Whitespace__r.Product__c);
	}
}