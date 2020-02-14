/**
 * @author     Steve Fouracre, Tony Bave
 * @Jira       RBX-317
 * This class holds example object definitions for use in test classes. The definitions are stored in Json format.
 * When creating a Test Class, these object definitions should be used. Additional standard or custom entries can be
 * added to support other common test setups. NB. The TestDataReturn class method prepareSObject() will instantiate
 * objects from a Json string.
 */
public class TestDataJsonLibrary {

    /**
     * This class holds the default JSON strings for each Object type.
     */
    public class Standard{

        /**
         * Map of Object type name to JSON string
         */
        public final Map<String, String> jsonMap = new Map<String, String> {
                Constants.TDF_USER
                        => JSON.serialize(new User(
                                LastName = 'Test-xyz',
                                Alias = 'xyz',
                                Email = 'xyz.test@test.test',
                                Username = 'xyz.test@test.test',
                                CommunityNickname = 'xyzy',
                                TimeZoneSidKey = 'America/New_York',
                                LocaleSidKey = 'en_US',
                                EmailEncodingKey = 'ISO-8859-1',
                                LanguageLocaleKey = 'en_US',
                                IsActive = true)
                        ),
                Constants.TDF_ACCOUNT
                        => '{"attributes":{"type":"Account"},"Name":"Test Account"}',
                Constants.TDF_CONTACT
                        => '{"attributes":{"type":"Contact"},"LastName":"Last","Email":"testuser@foo.com"}',
                Constants.TDF_LEAD
                        => JSON.serialize(new Lead(Company = 'Test Company', LastName = 'Last', Salutation = 'Mr.')),
                Constants.TDF_OPPORTUNITY
                        => JSON.serialize(new Opportunity(
                                Name = 'Test Opp - Mouse',
                                StageName = 'Suspect',
                                CurrencyIsoCode = 'GBP',
                                CloseDate = System.today()+7,
                                ContractID__c = '1234',
                                Term_Estimate_Months__c = 30,
                                Deliver_Contracts__c = Datetime.now().dateGmt(),
                                Completed_Strength_of_Sales_Checklist__c = true,
                                Compelling_Event__c = 'yes')
                        ),
                Constants.TDF_OPP_LINE_ITEM
                        => JSON.serialize(new OpportunityLineItem(
                                Quantity = 1,
                                TotalPrice = 100.00)
                        ),
                Constants.TDF_OPP_CONTACT_ROLE
                        => JSON.serialize(new OpportunityContactRole(Role = 'Decision Maker', IsPrimary = true)),
                Constants.TDF_PRODUCT
                        => JSON.serialize(new Product2(
                                Name = 'Test Product',
                                Product_Set__c = Product2.Product_Set__c.getDescribe().getPicklistValues()[0].getValue(),
                                Asset_Name__c = 'Almonde',
                                UPID__c = 'PS')
                        )
        };
    }

    /**
     * This class holds the alternative JSON strings for extended test scenarios.
     */
    public class Custom{

        /**
         * Map of Custom Name (declared in Constants class) to JSON string
         */
        public final Map<String, String> jsonMap = new Map<String, String> {
                Constants.TDF_CUSTOM_ACCOUNT
                        => '{"attributes":{"type":"Account"},"Name":"Custom Account"}'
        };
    }
}