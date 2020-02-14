/**
* Created by Ed Harrold on 6/8/2017.
*
*
* 06.07.17 : Ed Harrold : Created
* 06.10.17 : Ed Harrold : Updated to use system method for getting future date/time
* 06.18.17 : Ed Harrold : Update and ensure latest code is in CVent
* 06.18.17 : Ed Harrold : Update for AutoRenewJob code coverage
* 06.07.19 : Dan Meseroll : Added to Finastra project
*/

    @IsTest
    private class AutoRenewContractSchedulableTest {
        
        static testMethod void testSchedulable() {
            System.debug('AutoRenewContractSchedulableTest.testSchedulable started ...');

            Date todayDate = System.today();
            Date oldDate = todayDate - 10;
            Date futureDate = todayDate + 1;
            Date contractStartDate = oldDate - 10;

            System.debug('AutoRenewContractSchedulableTest.testSchedulable: todayDate:'+todayDate+' oldDate:'+oldDate);

            //Id recordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('DeveloperName.Subscription_Agreement').getRecordTypeId();
            //Id recordTypeId = [select Id from RecordType where DeveloperName = 'Subscription_Agreement' limit 1].Id;
            //System.debug('AutoRenewContractSchedulableTest.testSchedulable: recordTypeId:'+recordTypeId);

            Account account = new Account();
            account.Name = 'Marbella, Test Bank';
            //account.BillingCountry = 'USA';
            insert account;
            
            Contract contract = new Contract();
            contract.AccountId = account.Id;
            contract.Status = 'Draft';
            contract.StartDate = contractStartDate;
            contract.ContractTerm = 12;
            contract.Auto_Renewal__c = true;
            contract.SBQQ__RenewalQuoted__c = false;
            contract.SBQQ__RenewalForecast__c = false;
            contract.Renewal_Creation_Date__c = oldDate;
            contract.Renewal_Quote_Creation_Date__c = futureDate;
            insert contract;

            Contract nc1 = contract.clone();
            nc1.Renewal_Creation_Date__c = oldDate;
            nc1.Renewal_Quote_Creation_Date__c = oldDate;
            insert nc1;

            Contract nc2 = contract.clone();
            nc2 = contract.clone();
            nc2.Renewal_Creation_Date__c = (todayDate-7);
            nc2.Renewal_Quote_Creation_Date__c = futureDate;
            insert nc2;

            Contract nc3 = contract.clone();
            nc3 = contract.clone();
            nc3.Renewal_Creation_Date__c = (todayDate-6);
            nc2.Renewal_Quote_Creation_Date__c = (todayDate-4);
            insert nc3;
            
            integer contractsForecast = [SELECT count() FROM Contract WHERE SBQQ__RenewalForecast__c = true];
            integer contractsQuoted = [SELECT count() FROM Contract WHERE SBQQ__RenewalQuoted__c = true];
            integer contractsAuto = [SELECT count() FROM Contract WHERE Auto_Renewal__c = true];
            Test.startTest();
			System.assertEquals(0, contractsForecast);
 			System.assertEquals(0, contractsQuoted);
 			System.assertEquals(4, contractsAuto);
            
            String strSchedule = createScheduleString(6,0);
            System.debug('AutoRenewContractSchedulableTest.testSchedulable: createScheduleString:'+strSchedule);

            String strJobName = 'AutoRenew-' + strSchedule;

            System.schedule(strJobName, strSchedule, new AutoRenewContractSchedulable());

            strSchedule = createScheduleString(6,3);
            strJobName = 'AutoContractRenewJob-' + strSchedule;
            System.schedule(strJobName, strSchedule, new AutoContractRenewJob());

            Test.stopTest();
            
            contractsForecast = [SELECT count() FROM Contract WHERE SBQQ__RenewalForecast__c = true];
            integer contractsFailed = [SELECT count() FROM Contract WHERE Failed_Auto_Renew__c = true];
 			//These contracts will fail to renew, because they do not contain enough data.
 			//If these contracts are set up correctly, then set the assertions to compare against the correct numbers.
            System.assertEquals(1, contractsFailed);
 			System.assertEquals(0, contractsForecast);
        }
        
        private static String createScheduleString(Integer fromNow, Integer hms){
            /*
             * Example usage:
             * String strSchedule = createScheduleString(5,3);
             * where fromNow is unit of time designated by
             * hms: 1=hour,2=min,3=sec, not 1,2,3 = sec
             * String strJobName = 'AutoRenew-' + strSchedule;
             * System.schedule(strJobName, strSchedule, new SomeSchedulableClass());
                The following are the values for the cron scheduleexpression:

                Name    Values  Special Characters
                Seconds 0–59    None
                Minutes 0–59    None
                Hours   0–23    None
                Day_of_month    1–31    special chars: , - * ? / L W
                Month   1–12 or the following:
                JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC special chars: , - * /
                Day_of_week 1–7 or the following:
                SUN MON TUE WED THU FRI SAT special chars: , - * ? / L #
                optional_year   null or 1970–2099    special chars: , - * /
             *
                ,   Delimits values. For example, use JAN, MAR, APR to specify more than one month.
                -   Specifies a range. For example, use JAN-MAR to specify more than one month.
                *   Specifies all values. For example, if Month is specified as *, the job is scheduled for every month.
                ?   Specifies no specific value. This is only available for Day_of_month and Day_of_week, and is generally used when specifying a value for one and not the other.
                /   Specifies increments. The number before the slash specifies when the intervals will begin, and the number after the slash is the interval amount. For example, if you specify 1/5 for Day_of_month, the Apex class runs every fifth day of the month, starting on the first of the month.
                L   Specifies the end of a range (last). This is only available for Day_of_month and Day_of_week. When used with Day of month, L always means the last day of the month, such as January 31, February 29 for leap years, and so on. When used with Day_of_week by itself, it always means 7 or SAT. When used with a Day_of_week value, it means the last of that type of day in the month. For example, if you specify 2L, you are specifying the last Monday of the month. Do not use a range of values with L as the results might be unexpected.
                W   Specifies the nearest weekday (Monday-Friday) of the given day. This is only available for Day_of_month. For example, if you specify 20W, and the 20th is a Saturday, the class runs on the 19th. If you specify 1W, and the first is a Saturday, the class does not run in the previous month, but on the third, which is the following Monday.
             */
            DateTime future;
            if(hms==1) {
                future = system.now().addHours(fromNow);
            }else if(hms==2){
                future = system.now().addMinutes(fromNow);
            }else{
                future = system.now().addSeconds(fromNow);
            }
            Integer year = future.year();
            Integer month = future.month();
            Integer day = future.day();
            Integer hour = future.hour();
            Integer minute = future.minute();
            Integer second = future.second();
            return second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;

        }
    }