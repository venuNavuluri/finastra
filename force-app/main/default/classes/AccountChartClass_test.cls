@isTest private class AccountChartClass_test{

    private static testmethod void shouldGenerateChartData(){

        Account acc1 = TestUtility.sampleAccount();
        acc1.Type = 'Customer';
        insert acc1;

        Account acc2 = TestUtility.sampleAccount();
        acc2.Type = 'Customer';
        insert acc2;

        Contact con = TestUtility.sampleContact();
        con.accountId = acc1.Id;
        insert con;

        User runUser = [select Id from User where Id = :userInfo.getUserId() and isActive = true LIMIT 1];
        User testUser;
        System.runAs(runUser){
            testUser = TestUtility.sampleCustPortalUser(con);
            testUser.TimeZoneSidKey = UserInfo.getTimeZone().getID();
            insert testUser;
        }
        
        Accounts_Supported__c testAcctSupp = TestUtility.sampleAccountsSupported(con, acc2);
        insert testAcctSupp;

        RecordType rc = [Select Name, Id From RecordType where name = 'Midas' limit 1];
        List<Case> caseToInsert = new List<Case>();

        Case lCase = TestUtility.sampleCase();
        lCase.Status = 'Client Testing';
        lCase.Priority = 'Low';
        lCase.RecordTypeId = rc.Id;
        lCase.AccountId = con.AccountId;
        caseToInsert.add(lCase);

        Case lCase1 = TestUtility.sampleCase();
        lCase1.Status = 'Solution Provided';
        lCase1.Priority = 'Low';
        lCase1.RecordTypeId = rc.Id;
        lCase1.AccountId = acc2.Id;
        caseToInsert.add(lCase1);

        Case lCase2 = TestUtility.sampleCase();
        lCase2.Status = 'New';
        lCase2.Priority = 'Low';
        lCase2.RecordTypeId = rc.Id;
        lCase2.AccountId = con.AccountId;
        caseToInsert.add(lCase2);

        insert caseToInsert;

        Case l = [Select id, priority, createddate, accountid from Case where id = :lcase.id];
        System.debug('case value' + l.priority + l.accountid + l.createddate);
        Datetime dtToday = datetime.now();    //Get today's date
        System.debug('Value of date' + dtToday);

        Integer interval = -30;          //Days to go back in time

        Datetime dtmonthback = dttoday.addDays(interval);
        Date pDate = dtmonthback.date();

        Integer currDay = dtToday.Day();
        Integer prevDay = pDate.Day();
        Integer currMonth = dtToday.month();
        Integer prevMonth = pDate.month();
        Integer currYear = dtToday.Year();
        Integer prevYear = pDate.Year();

        String[] currMthArr = new String[]{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};

        String currentDate = '' + currDay + ' ' + currMthArr[currMonth - 1] + ' ' + currYear;
        String previousDate = '' + prevDay + ' '  + currMthArr[prevMonth - 1] + ' '  +  prevYear;

        System.runAs(testUser){
            Test.startTest();
                List<String> result1 = AccountChartClass.AwaitingChartData();
                List<String> result2 = AccountChartClass.CasesWithMisysChartData();
                List<String> result3 = AccountChartClass.TotalCasesLogged();
            Test.stopTest();
            system.assertEquals(new List<String>{'Midas,1', ','}, result1);
            system.assertEquals(new List<String>{'Midas,1', ','}, result2);
            //system.assertEquals(new List<String>{'Medium,2,0,'+currentDate+','+previousDate,',,,'+currentDate+','+previousDate}, result3);
            system.debug('AAA ' + 'Medium,2,0,'+currentDate+','+previousDate+',,,'+currentDate+','+previousDate + ' AAA ' + result3);
        }

    }
}