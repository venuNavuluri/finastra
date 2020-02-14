@isTest
private class test_CommunityPremiumService {

        @isTest static void testBehaviour() {
                // Implement test code
                Map<String,RecordType> recordTypesByName = new Map<String,RecordType>();
                for (List<RecordType> recordTypes :  [SELECT Id, Name FROM RecordType]){
                        for (RecordType recordType : recordTypes){
                                recordTypesByName.put(recordType.Name, recordType);
                        }
                }
                Account acct = new Account();
                acct.Name = 'Test Account';
                acct.recordTypeId = recordTypesByName.get('Finastra Customer').Id;
                acct.Region__c = 'Europe';
                acct.site = 'test site';
                acct.type = 'Customer';
                acct.Country__c = 'United Kingdom';
                insert acct;

                Contact con = New Contact();
                con.Lastname = 'Testing';
                con.RecordTypeId = recordTypesByName.get('Customer Portal').Id;
                con.AccountId = acct.Id;
                con.email = 'community@test.com';
                insert con;

                Profile standardProf = [select id from profile where name='Customer Community BANKING User'];
                User su = new User(alias = 'comm', email='community@test.com',
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                        localesidkey='en_US', profileid = standardProf.Id,
                        timezonesidkey='Europe/London', username='community@test.com', contactId=con.Id);
                insert su;

                Case csPremium = TestUtils.getCase(acct, con);
                csPremium.recordtypeId = recordTypesByName.get('Premium Support Services').Id;
                //csPremium.ownerId = u.Id;
                insert csPremium;

                Test.startTest();
                System.runAs(su) {
                        pageReference pageDetailsPremium = Page.community_CaseDetails;
                        ApexPages.StandardController scPremium = new ApexPages.standardController(csPremium);
                        Community_CaseViewExtension conDetailsPremium = New Community_CaseViewExtension(scPremium);


                }
                Test.stopTest();
        }



}