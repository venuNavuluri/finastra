@isTest
private class SubscriptionTriggerMethods_Test{

	private static SBQQ__Subscription__c createSubData(){
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, Varied_Licence__c = true,
                Transactions__c = 2, Sold_Value__c = 50, SBQQ__NetPrice__c = 100, SBQQ__BillingType__c = 'Advance');
        insert subscription; 
        
        return subscription;
	}

	private static Quote_Line_Transaction_Tier__c createTranData(SBQQ__Subscription__c subscription){
		SBQQ__QuoteLine__c line = createData();
		
        Quote_Line_Transaction_Tier__c tier = new Quote_Line_Transaction_Tier__c(Subscription__c = subscription.Id,
                Quote_Line__c = line.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 100,
                Lower_Bound__c = 0, Upper_Bound__c = null, Minimum_Price__c = 15, Price__c = 50, Licence_Fees__c = 20);
        insert tier;
        subscription.Transactions__c = 5;
        update subscription;
        
        return tier;
	}
    private static SBQQ__QuoteLine__c createData(){
        Account account = new Account(name = 'uplift test account');
        insert account;
        Opportunity opp = new Opportunity(Name = 'uplift test opp', StageName = 'Suspect', CloseDate = Date.today());
        insert opp;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = account.Id, SBQQ__Opportunity2__c = opp.Id);
        insert quote;
        Product2 product = new Product2(Name = 'testProd', SO_Grouping__c = 'ILF-ILF',
                CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561');
        insert product;
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = product.Id);
        insert line;
        return line;
    }
	//G.B 10.06.2019
    private static testmethod void soAmountUpdateTest(){
        
        User sysAdmin = [SELECT Id FROM User WHERE isActive = true AND Profile.Name = 'System Administrator' limit 1];
        System.runAs(sysAdmin){
            TestDataFactory.bypassCPQValidation();
        }
        User runningUser = TestDataFactory.getRunningUser('M B&RA / CAT profile');
        System.runAs(runningUser){
            //Record being inserted
            Test.startTest();
                SBQQ__Subscription__c subscription = createSubData();
                subscription = [SELECT Id, SO_Amount__c, SBQQ__NetPrice__c,SBQQ__ProrateMultiplier__c FROM SBQQ__Subscription__c WHERE Id=:subscription.Id limit 1];
                system.assertEquals(subscription.SO_Amount__c, subscription.SBQQ__NetPrice__c / subscription.SBQQ__ProrateMultiplier__c);
                //Record being updated
                subscription.SBQQ__NetPrice__c = 500;
                subscription.SBQQ__ProrateMultiplier__c = 5;
                update subscription;
                subscription = [SELECT Id, SO_Amount__c, SBQQ__NetPrice__c,SBQQ__ProrateMultiplier__c FROM SBQQ__Subscription__c WHERE Id=:subscription.Id limit 1];
                system.assertEquals(subscription.SO_Amount__c, subscription.SBQQ__NetPrice__c / subscription.SBQQ__ProrateMultiplier__c);
            Test.stopTest();    
        }  
    }
    private static testmethod void assignSOadvDaysToSubsTest1(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Test.startTest();
	    	SubscriptionTriggerMethods.assignSOadvDaysToSubs(new SBQQ__Subscription__c[]{subscription}, null, true);
	        SBQQ__Subscription__c resultSub = [select id, SO_Generation_Advance__c from SBQQ__Subscription__c limit 1];
	        system.assertEquals(60, resultSub.SO_Generation_Advance__c);
        Test.stopTest();
    }

    private static testmethod void assignSOadvDaysToSubsTest2(){
    	SBQQ__Subscription__c subscription = createSubData();
    	subscription.SBQQ__BillingType__c = 'Arrears';
    	subscription.SO_Generation_Advance__c = null;
    	update subscription;
    	Test.startTest();
	    	SubscriptionTriggerMethods.assignSOadvDaysToSubs(new SBQQ__Subscription__c[]{subscription}, null, true);
	        SBQQ__Subscription__c resultSub = [select id, SO_Generation_Advance__c from SBQQ__Subscription__c limit 1];
	        system.assertEquals(30, resultSub.SO_Generation_Advance__c);
        Test.stopTest();
    }

    private static testmethod void assignSOadvDaysToSubsTest3(){
    	SBQQ__Subscription__c subscription = createSubData();
    	subscription.SBQQ__BillingType__c = null;
    	subscription.SO_Generation_Advance__c = null;
    	update subscription;
    	Test.startTest();
	    	SubscriptionTriggerMethods.assignSOadvDaysToSubs(new SBQQ__Subscription__c[]{subscription}, null, true);
	        SBQQ__Subscription__c resultSub = [select id, SO_Generation_Advance__c from SBQQ__Subscription__c limit 1];
	        system.assertEquals(null, resultSub.SO_Generation_Advance__c);
        Test.stopTest();
    }

    private static testmethod void assignSOadvDaysToSubsTest4(){
    	SBQQ__Subscription__c subscription = createSubData();
    	subscription.SBQQ__BillingType__c = 'Advance';
    	subscription.SO_Generation_Advance__c = null;
    	update subscription;
    	Test.startTest();
	    	SubscriptionTriggerMethods.assignSOadvDaysToSubs(new SBQQ__Subscription__c[]{subscription}, null, true);
	        SBQQ__Subscription__c resultSub = [select id, SO_Generation_Advance__c from SBQQ__Subscription__c limit 1];
	        system.assertEquals(60, resultSub.SO_Generation_Advance__c);
        Test.stopTest();
    }

	
    private static testmethod void processSubscriptionsForNetPriceTest1(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
    	Quote_Line_Transaction_Tier__c[] tranLst = new Quote_Line_Transaction_Tier__c[]{tier};
    	Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>> subscriptionsWithTiers = new Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>>();
    	subscriptionsWithTiers.put(subscription, tranLst);
    	Test.startTest();
	    	SubscriptionTriggerMethods.processSubscriptionsForNetPrice(subscriptionsWithTiers);
	        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
	        system.assertEquals(100, resultSub.SBQQ__NetPrice__c);
        Test.stopTest();
    }

    private static testmethod void processSubscriptionsForNetPriceTest2(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
        subscription.Transactions__c = 6;
        subscription.Varied_Licence__c = false;
        update subscription;

    	Quote_Line_Transaction_Tier__c[] tranLst = new Quote_Line_Transaction_Tier__c[]{tier};
    	Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>> subscriptionsWithTiers = new Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>>();
    	subscriptionsWithTiers.put(subscription, tranLst);
    	Test.startTest();
	    	SubscriptionTriggerMethods.processSubscriptionsForNetPrice(subscriptionsWithTiers);
	        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
	        system.assertEquals(650, resultSub.SBQQ__NetPrice__c);
        Test.stopTest();
    }
	
    private static testmethod void processSubscriptionsForNetPriceTest3(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
        tier.price__c = null;
        update tier;
        
    	Quote_Line_Transaction_Tier__c[] tranLst = new Quote_Line_Transaction_Tier__c[]{tier};
    	Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>> subscriptionsWithTiers = new Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>>();
    	subscriptionsWithTiers.put(subscription, tranLst);
    	Test.startTest();
	    	SubscriptionTriggerMethods.processSubscriptionsForNetPrice(subscriptionsWithTiers);
	        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
	        system.assertEquals(100, resultSub.SBQQ__NetPrice__c);
        Test.stopTest();
    }
	
    private static testmethod void processSubscriptionsForNetPriceTest4(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
        tier.Lower_Bound__c = 5;
        update tier;
        system.debug('tier = '+tier);	

		subscription.Transactions__c = 6;
        subscription.Varied_Licence__c = false;
        update subscription;
        
    	Quote_Line_Transaction_Tier__c[] tranLst = new Quote_Line_Transaction_Tier__c[]{tier};
    	Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>> subscriptionsWithTiers = new Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>>();
    	subscriptionsWithTiers.put(subscription, tranLst);
    	Test.startTest();
	    	SubscriptionTriggerMethods.processSubscriptionsForNetPrice(subscriptionsWithTiers);
	        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
	        system.assertEquals(250, resultSub.SBQQ__NetPrice__c);
        Test.stopTest();
    }
	
	private static testmethod void getSubscriptionsWithTransactionsChangeTest1(){
		SBQQ__Subscription__c subscription = createSubData();
		SBQQ__Subscription__c[] subLst = new SBQQ__Subscription__c[]{subscription};
		
		Map<Id, SBQQ__Subscription__c> oldMap = new Map<Id, SBQQ__Subscription__c>();
		oldMap.put(subscription.id, subscription);
    	Test.startTest();
	    	Map<Id, SBQQ__Subscription__c> changedSubscriptions = SubscriptionTriggerMethods.getSubscriptionsWithTransactionsChange(subLst, oldMap);
	        system.assert(changedSubscriptions.isempty());
        Test.stopTest();
    }
	
	private static testmethod void getSubscriptionsWithTransactionsChangeTest2(){
		//-ve
		SBQQ__Subscription__c[] subLst = new SBQQ__Subscription__c[]{};
		Map<Id, SBQQ__Subscription__c> oldMap = new Map<Id, SBQQ__Subscription__c>();
    	Test.startTest();
	    	Map<Id, SBQQ__Subscription__c> changedSubscriptions = SubscriptionTriggerMethods.getSubscriptionsWithTransactionsChange(subLst, oldMap);
	        system.assert(changedSubscriptions.isempty());
        Test.stopTest();
    }
	
    
    private static testmethod void fetchSubscriptionsWithTiersTest1(){
		//-ve
		SBQQ__Subscription__c subscription = createSubData();
		Map<Id, SBQQ__Subscription__c> sMap = new Map<Id, SBQQ__Subscription__c>();
		sMap.put(subscription.id, subscription);
    	Test.startTest();
	    	Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>> subscriptionsWithTiers = SubscriptionTriggerMethods.fetchSubscriptionsWithTiers(sMap);
	        system.assert(subscriptionsWithTiers.isempty());
        Test.stopTest();
    }

    private static testmethod void fetchSubscriptionsWithTiersTest2(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);

		Map<Id, SBQQ__Subscription__c> sMap = new Map<Id, SBQQ__Subscription__c>();
		sMap.put(subscription.id, subscription);
    	Test.startTest();
	    	Map<SBQQ__Subscription__c, List<Quote_Line_Transaction_Tier__c>> subscriptionsWithTiers = SubscriptionTriggerMethods.fetchSubscriptionsWithTiers(sMap);
	        system.assert(!subscriptionsWithTiers.isempty());
        Test.stopTest();
    }
	
    private static testmethod void isCorrectTierTest1(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
    	Test.startTest();
	    	system.assert(SubscriptionTriggerMethods.isCorrectTier(subscription,tier));
        Test.stopTest();
    }
	
    private static testmethod void isCorrectTierTest2(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
    	tier.Start_Date__c = Date.today();
    	update tier;
    	Test.startTest();
	    	system.assert(!SubscriptionTriggerMethods.isCorrectTier(subscription,tier));
        Test.stopTest();
    }
	
    private static testmethod void isCorrectTierTest3(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
    	tier.End_Date__c = Date.today();
    	update tier;
    	Test.startTest();
	    	system.assert(!SubscriptionTriggerMethods.isCorrectTier(subscription,tier));
        Test.stopTest();
    }
	
    private static testmethod void isCorrectTierTest4(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
    	tier.Lower_Bound__c = 5;
    	update tier;
    	Test.startTest();
	    	system.assert(SubscriptionTriggerMethods.isCorrectTier(subscription,tier));
        Test.stopTest();
    }
	
    private static testmethod void isCorrectTierTest5(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
    	tier.Upper_Bound__c = 4;
    	update tier;
    	Test.startTest();
	    	system.assert(!SubscriptionTriggerMethods.isCorrectTier(subscription,tier));
        Test.stopTest();
    }
	
    private static testmethod void setNetPriceForTierPriceTest1(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
    	tier.Price__c = 10;
    	update tier;
    	Test.startTest();
	    	SubscriptionTriggerMethods.setNetPriceForTierPrice(subscription,tier);
	    	update subscription;
	        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
	        system.assertEquals(510, resultSub.SBQQ__NetPrice__c);
        Test.stopTest();
    }
	
    private static testmethod void setNetPriceForTierPriceTest2(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
    	tier.Lower_Bound__c = 4;
    	update tier;
    	Test.startTest();
	    	SubscriptionTriggerMethods.setNetPriceForTierPrice(subscription,tier);
	    	update subscription;
	        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
	        system.assertEquals(250, resultSub.SBQQ__NetPrice__c);
        Test.stopTest();
    }
	
    private static testmethod void setNetPriceForTierPriceTest3(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
    	tier.Unit_Price__c = 80;
    	update tier;
    	Test.startTest();
	    	SubscriptionTriggerMethods.setNetPriceForTierPrice(subscription,tier);
	    	update subscription;
	        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
	        system.assertEquals(450, resultSub.SBQQ__NetPrice__c);
        Test.stopTest();
    }
	
    private static testmethod void setNetPriceForNullTierPriceTest1(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
    	tier.Unit_Price__c = 1;
    	update tier;
    	Test.startTest();
	    	SubscriptionTriggerMethods.setNetPriceForNullTierPrice(subscription,tier);
	    	update subscription;
	        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
	        system.assertEquals(15, resultSub.SBQQ__NetPrice__c);
        Test.stopTest();
    }
	
    private static testmethod void setNetPriceForNullTierPriceTest2(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
    	Test.startTest();
	    	SubscriptionTriggerMethods.setNetPriceForNullTierPrice(subscription,tier);
	    	update subscription;
	        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
	        system.assertEquals(500, resultSub.SBQQ__NetPrice__c);
        Test.stopTest();
    }
	
    private static testmethod void setNetPriceForNullTierPriceTest3(){
    	SBQQ__Subscription__c subscription = createSubData();
    	Quote_Line_Transaction_Tier__c tier = createTranData(subscription);
    	tier.Unit_Price__c = 1;
    	tier.Minimum_Price__c = null;
    	update tier;
    	Test.startTest();
	    	SubscriptionTriggerMethods.setNetPriceForNullTierPrice(subscription,tier);
	    	update subscription;
	        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
	        system.assertEquals(5, resultSub.SBQQ__NetPrice__c);
        Test.stopTest();
    }
	
    @isTest
    private static void shouldCalculateFeeForVariedLicenceAndCreateSalesOrder(){

        // that's for sales order
        NS_Revenue_Recognition_Template__c nrrt = new NS_Revenue_Recognition_Template__c(Name = 'POC');
        insert nrrt;
        Test.startTest();
        SBQQ__QuoteLine__c line = createData();
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Varied_Licence__c = true,
                Transactions__c = 2, Sold_Value__c = 50, SBQQ__NetPrice__c = 100);
        insert subscription;
        Quote_Line_Transaction_Tier__c tier = new Quote_Line_Transaction_Tier__c(Subscription__c = subscription.Id,
                Quote_Line__c = line.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 100,
                Lower_Bound__c = 0, Upper_Bound__c = null, Minimum_Price__c = 15, Price__c = 50, Licence_Fees__c = 20);
        insert tier;
        subscription.Transactions__c = 5;
        update subscription;
        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
        system.assertEquals(100, resultSub.SBQQ__NetPrice__c);
        Test.stopTest();
        
        // Functionality was changed and we are not creating SO and SO items.
       /*
        List<Sales_Order__c> salesOrdes = [select id from Sales_Order__c];
        List<Sales_Order_Item__c> salesOrderItems = [select id from Sales_Order_Item__c];

        system.assertEquals(1, salesOrdes.size());
        system.assertEquals(1, salesOrderItems.size());
         */

    }
    @isTest
    private static void shouldCalculateNetPrice(){
        SBQQ__QuoteLine__c line = createData();
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1);
        insert subscription;
        Quote_Line_Transaction_Tier__c tier = new Quote_Line_Transaction_Tier__c(Subscription__c = subscription.Id,
                Quote_Line__c = line.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 100,
                Lower_Bound__c = 0, Upper_Bound__c = 3, Minimum_Price__c = 15, Price__c = 50);
        insert tier;
        subscription.Transactions__c = 1;
        update subscription;
        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
        system.assertEquals(150, resultSub.SBQQ__NetPrice__c, 'Calculated net price on subscription is not correct');
    }
    @isTest
    private static void shouldCalculateNetPrice2(){
        SBQQ__QuoteLine__c line = createData();
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1);
        insert subscription;
        Quote_Line_Transaction_Tier__c tier = new Quote_Line_Transaction_Tier__c(Subscription__c = subscription.Id,
                Quote_Line__c = line.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 100,
                Lower_Bound__c = 1, Upper_Bound__c = 4, Minimum_Price__c = 15, Price__c = 50);
        insert tier;
        subscription.Transactions__c = 3;
        update subscription;
        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
        system.assertEquals(350, resultSub.SBQQ__NetPrice__c, 'Calculated net price on subscription is not correct');
    }
    @isTest
    private static void shouldCalculateNetPriceForNullPrice(){
        SBQQ__QuoteLine__c line = createData();
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1);
        insert subscription;
        Quote_Line_Transaction_Tier__c tier = new Quote_Line_Transaction_Tier__c(Subscription__c = subscription.Id,
                Quote_Line__c = line.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 100,
                Lower_Bound__c = 0, Upper_Bound__c = 3, Minimum_Price__c = 15);
        insert tier;
        subscription.Transactions__c = 2;
        update subscription;
        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
        system.assertEquals(200, resultSub.SBQQ__NetPrice__c, 'Calculated net price on subscription is not correct');
    }
    @isTest
    private static void shouldCalculateNetPriceForMinimum(){
        SBQQ__QuoteLine__c line = createData();
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1);
        insert subscription;
        Quote_Line_Transaction_Tier__c tier = new Quote_Line_Transaction_Tier__c(Subscription__c = subscription.Id,
                Quote_Line__c = line.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 100,
                Lower_Bound__c = 0, Upper_Bound__c = 3, Minimum_Price__c = 420);
        insert tier;
        subscription.Transactions__c = 2;
        update subscription;
        SBQQ__Subscription__c resultSub = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c where id = :subscription.Id];
        system.assertEquals(420, resultSub.SBQQ__NetPrice__c, 'Calculated net price on subscription is not correct');
    }
    @isTest
    private static void shouldCalculateNetPriceMultiple(){
        SBQQ__QuoteLine__c line = createData();
        List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1);
        subs.add(sub1);
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1);
        subs.add(sub2);
        SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1);
        subs.add(sub3);
        insert subs;

        List<Quote_Line_Transaction_Tier__c> tiers = new List<Quote_Line_Transaction_Tier__c>();
        Quote_Line_Transaction_Tier__c tier11 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub1.Id,
                Quote_Line__c = line.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 10,
                Lower_Bound__c = 0, Upper_Bound__c = 2, Minimum_Price__c = 10, Price__c = 50);
        tiers.add(tier11);
        Quote_Line_Transaction_Tier__c tier12 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub1.Id,
                Quote_Line__c = line.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 10,
                Lower_Bound__c = 1, Upper_Bound__c = 3, Minimum_Price__c = 10000);
        tiers.add(tier12);

        Quote_Line_Transaction_Tier__c tier21 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub2.Id,
                Quote_Line__c = line.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 380,
                Lower_Bound__c = 0, Upper_Bound__c = 2, Minimum_Price__c = 10, Price__c = 150);
        tiers.add(tier21);
        Quote_Line_Transaction_Tier__c tier22 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub2.Id,
                Quote_Line__c = line.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 10,
                Lower_Bound__c = 1, Upper_Bound__c = 2, Minimum_Price__c = 10, Price__c = 50);
        tiers.add(tier22);
        Quote_Line_Transaction_Tier__c tier23 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub2.Id,
                Quote_Line__c = line.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 410,
                Lower_Bound__c = 1, Upper_Bound__c = 4, Minimum_Price__c = 10, Price__c = 500);
        tiers.add(tier23);

        Quote_Line_Transaction_Tier__c tier31 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub3.Id,
                Quote_Line__c = line.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 10,
                Lower_Bound__c = 0, Upper_Bound__c = 2, Minimum_Price__c = 10, Price__c = 50);
        tiers.add(tier31);
        Quote_Line_Transaction_Tier__c tier32 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub3.Id,
                Quote_Line__c = line.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 870,
                Lower_Bound__c = 1, Minimum_Price__c = 10);
        tiers.add(tier32);
        insert tiers;

        sub1.Transactions__c = 2;
        sub2.Transactions__c = 3;
        sub3.Transactions__c = 2;
        update subs;
        List<SBQQ__Subscription__c> resultSubs = [select id, SBQQ__NetPrice__c from SBQQ__Subscription__c];
        SBQQ__Subscription__c resultSub1, resultSub2, resultSub3;
        for(SBQQ__Subscription__c sub : resultSubs){
            if(sub.Id == sub1.Id) resultSub1 = sub;
            else if(sub.Id == sub2.Id) resultSub2 = sub;
            else if(sub.Id == sub3.Id) resultSub3 = sub;
        }

        system.assertEquals(10000, resultSub1.SBQQ__NetPrice__c, 'Calculated net price on subscription is not correct');
        system.assertEquals(1730, resultSub2.SBQQ__NetPrice__c, 'Calculated net price on subscription is not correct');
        system.assertEquals(1740, resultSub3.SBQQ__NetPrice__c, 'Calculated net price on subscription is not correct');
    }


}