global with sharing class AccountChartClass{
    WebService Static List<String> AwaitingChartData(){
        Set<id> ids = new Set<id>();
        id userid = Userinfo.getUserId();
        // id userid = '00520000000q9Gx';

        User u1 = [Select id, contactid from User where id = :userid];
        Contact Cont = [Select AccountId from Contact where id = :u1.ContactId];
        ids.add(Cont.AccountId);
        List<Accounts_Supported__c> accSupp = [Select id, Supported_Account__c from Accounts_Supported__c where contact__c = :u1.contactId];
        for(Accounts_Supported__c acc : accSupp)
            ids.add(acc.Supported_Account__c);

        Set<String> sCaseStatus = new Set<String>{
                'Additional Information Required', 'Client Information Required', 'Client Testing', 'On Hold with Client', 'Solution Provided', 'With Client'
        };
        List<Case> lCase = [Select c.Status, c.RecordType.Name, c.RecordTypeId, c.IsVisibleInSelfService, c.AccountId From Case c where AccountId IN :ids and c.IsVisibleInSelfService = True AND c.Status IN :sCaseStatus];
        System.debug('List of cases' + lCase);
        Set<String> sRecordType = new Set<String>();
        List<String> lRecordType = new List<String>();
        List<String> sData = new List<String>();
        if(lCase.size() > 0){
            for(Case C : lCase){
                sRecordType.add(C.RecordType.Name);
            }

            for(String S : sRecordType){
                lRecordType.add(S);
            }
            lRecordType.sort();
            for(String S : lRecordType){
                Integer n = 0;
                for(Case C : lCase){
                    if(S == C.RecordType.Name)
                        n++;
                }
                sData.add(s + ',' + n);
            }
        }
        if(sData.size() < 1){
            sData.add(',');
            sData.add(',');
        } else if(sData.size() < 2){
            sData.add(',');
        }

        System.debug('sData' + sData);
        return sData;

    }
    WebService Static List<String> CasesWithMisysChartData(){
        Set<id> ids = new Set<id>();
        id userid = Userinfo.getUserId();
        // id userid = '00520000000q9Gx';

        User u1 = [Select id, contactid from User where id = :userid];
        Contact Cont = [Select AccountId, Account.Site from Contact where id = :u1.ContactId];
        ids.add(Cont.AccountId);
        List<Accounts_Supported__c> accSupp = [Select id, Supported_Account__c from Accounts_Supported__c where contact__c = :u1.contactId];
        for(Accounts_Supported__c acc : accSupp)
            ids.add(acc.Supported_Account__c);
        Set<String> sCaseStatus = new Set<String>{
                'Additional Information Required', 'Client Information Required', 'Client Testing', 'On Hold with Client', 'Solution Provided', 'With Client', 'Closed', 'Resolved'
        };
        List<Case> lCase = [Select c.Status, c.RecordType.Name, c.RecordTypeId, c.IsVisibleInSelfService, c.AccountId From Case c where AccountId IN :ids and c.IsVisibleInSelfService = True AND c.Status not IN :sCaseStatus];
        Set<String> sRecordType = new Set<String>();
        List<String> lRecordType = new List<String>();
        List<String> sData = new List<String>();
        if(lCase.size() > 0){
            for(Case C : lCase){
                sRecordType.add(C.RecordType.Name);
            }

            for(String S : sRecordType){
                lRecordType.add(S);
            }
            lRecordType.sort();

            String sit = cont.Account.Site;
            Integer temp = 0;


            for(String S : lRecordType){
                Integer n = 0;

                for(Case C : lCase){
                    if(S == C.RecordType.Name)
                        n++;
                }
                temp++;
                sData.add(s + ',' + n); // + ',' + temp + ',' + sit);
            }
        }

        if(sData.size() < 1){
            sData.add(',');
            sData.add(',');
        } else if(sData.size() < 2){
            sData.add(',');
        }


        return sData;

    }

    WebService Static List<String> TotalCasesLogged(){
        List<String> sData = new List<String>();

        Set<id> ids = new Set<id>();
        id userid = Userinfo.getUserId();
        //  id userid = '00520000000q9Gx';

        User u1 = [Select id, contactid from User where id = :userid];
        Contact Cont = [Select AccountId from Contact where id = :u1.ContactId];
        ids.add(Cont.AccountId);

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

        String[] currMthArr = new String[]{
                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        };

        String currentDate = '' + currDay + ' ' + currMthArr[currMonth - 1] + ' ' + currYear;
        String previousDate = '' + prevDay + ' ' + currMthArr[prevMonth - 1] + ' ' + prevYear;
        //String currentDate = '' + dtToday.date().format();

        //  datetime myDate = datetime.newInstance(2010,02,01);
        //  Date pDate = myDate.date();
        //  System.debug('Value of datechangeTest' + pDate);


        List<Accounts_Supported__c> accSupp = [Select id, Supported_Account__c from Accounts_Supported__c where contact__c = :u1.contactId];
        for(Accounts_Supported__c acc : accSupp)
            ids.add(acc.Supported_Account__c);

        //Set<String> sCasePriority = new Set<String>{'Low','Medium','High'};
        List<String> lAllCasePriorities = Label.PortalChart_CasePriorityOrder.split(';');
        System.debug('List of cases' + ids + pdate);
        //List<Case> lCase = [Select Status,Priority,IsClosed,RecordType.Name,RecordTypeId, IsVisibleInSelfService, AccountId From Case  where CreatedDate >= :pDate AND AccountId IN :ids AND Priority IN : sCasePriority];
        List<Case> lCase = [Select Status,Priority,IsClosed,RecordType.Name,RecordTypeId, IsVisibleInSelfService, AccountId From Case where CreatedDate >= :pDate AND AccountId IN :ids AND Priority IN :lAllCasePriorities];
        System.debug('List of cases' + lCase);
        Set<String> sPriority = new Set<String>();
        for(Case C : lCase){
            sPriority.add(C.Priority);
        }

        //Get the list of Case Priority values in the correct order
        //List<String> lAllCasePriorities = Label.PortalChart_CasePriorityOrder.split(';');
        system.debug('lCasePriority list: ' + lAllCasePriorities);

        //Create a list in the proper order that includes only statuses with cases
        List<String> lCasePriority = new List<String>();
        for(String S : lAllCasePriorities){
            if(sPriority.contains(S)) lCasePriority.add(S);
        }
        //lCasePriority.sort();

//Main loop Start       
        for(String S : lCasePriority){
            Integer n = 0;
            Integer m = 0;
            for(Case C : lCase){
                if(S == C.Priority)
                    n++;

                if((S == C.Priority) && (C.status == 'Resolved' || C.IsClosed == true)){
                    m++;
                }
            }
            sData.add(s + ',' + n + ',' + m + ',' + currentDate + ',' + previousDate);

        }

        System.debug('SData' + sData);

//Main loop End

        if(sData.size() < 1){
            sData.add(',,,' + currentDate + ',' + previousDate);
            sData.add(',,,' + currentDate + ',' + previousDate);
        } else if(sData.size() < 2){
            sData.add(',,,' + currentDate + ',' + previousDate);
        }

        system.debug('sData returned: ' + sData);
        return sData;

    }


}