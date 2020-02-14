@isTest private class TimeCalculator_Test 
{
    /*
    public static testmethod void testTimeCalculator1()
    {
        System.debug('second test');
        
        Case testCase = [select Id, Status, Priority,Date_Time_Responded__c,Workaround_Provided__c,Original_Priority__c from Case where Date_Time_Responded__c = null limit 1];
        
        //TimeCalculator.CalculateElapsedTimes(new List<ID>{testCase.Id});
        
        //Time_Object__c timeObject = [select Id, Date_Time_Responded__c, Response_Time__c from Time_Object__c where Id =:testCase.Time_Object__c limit 1];
        Time_Object__c timeObject = [select Id, Date_Time_Responded__c, Response_Time__c from Time_Object__c where Case__c =:testCase.Id limit 1];
        
        timeObject.Date_Time_Responded__c = Datetime.now();
        update timeObject;
        
        testCase.Priority = 'Low';
        testCase.Workaround_Provided__c = 'No';
        testCase.Date_Time_Responded__c =  Datetime.now();
        testCase.Status = 'Client Testing';
        update testCase;
        
        //TimeCalculator.CalculateElapsedTimes(new List<ID>{testCase.Id});
        TimeCalculator.CalculateTimesNew(new List<ID>{testCase.Id});        
    }
    */

    public static testmethod void testTimeCalculator2()
    {
        /*
        System.debug('third test');
        
        Case testCase = [select Id, Status from Case where CaseNumber = '00308120' limit 1];
        
        TimeCalculator.CalculateTimes(new List<ID>{testCase.Id});
        */
    }
    
   /*
    public static testmethod void testTimeCalculator_1()
    {
        // Create a case with Subject : Test Case - PSP2 Loading, Priority: Medium
        // Ensure that SLA, Account and BHIU are all allocated
        // Change Status from L1 to L2 and Save
        // Change Status from L2 to L3 and Save
        // Change Category from Support Request to Defect
        
        List<BusinessHours> lBusinessHours = [select id from BusinessHours limit 2];
        Case testCase = [select Id, Status, Time_Object__c, Date_Time_Responded__c,BusinessHours__c from Case where Subject = 'Test Case - PSP2 Loading' limit 1];
        testCase.Date_Time_Responded__c = DateTime.now();
        //testCase.Breach_Analysis_Comments__c = 'comment';
        if(lBusinessHours != null && lBusinessHours.size() > 0)        
        	testCase.BusinessHours__c = lBusinessHours[0].id; 
        update testCase;
        
        TimeCalculator.CalculateTimes(new List<ID>{testCase.Id});
        if(lBusinessHours != null && lBusinessHours.size() > 1)        
        	testCase.BusinessHours__c = lBusinessHours[1].id;
        
        testCase.Status = 'Closed';
        update testCase;
        
        TimeCalculator.CalculateTimes(new List<ID>{testCase.Id});
    }
    */

	/*
    public static testmethod void testTimeCalculator_2()
    {
        // Create a case with Subject : Test Case - PSP2 Loading without history, Priority: Medium
        // Ensure that SLA, Account and BHIU are all allocated
        // Do not change anything else      

        List<Case> testCase = [select Id, Status, Time_Object__c, Date_Time_Responded__c from Case where Subject = 'Test Case - PSP2 Loading without history' limit 1];
        
        if(testCase.size() > 0)
            TimeCalculator.CalculateTimes(new List<ID>{testCase[0].Id});
        // Executing the Time Scheduler
        /*String seconds = '0'; //Execute at Zero Seconds
        String minutes = '10,20,30,40,50'; //Execute at every 10th minute of hour
        String hours = '*'; // Execute Every Hour
        String dayOfMonth = '*'; // Execute Every Day of the Month
        String month = '*'; //Execute only in November(11)
        String dayOfWeek = '?'; //Execute on all 7 days of the Week
        String year = '2010'; //Execute only for year 2009
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
        //Integer dt = system.Datetime().addMinutes(2).minutes();*/
        /*system.debug('Nitin Yes 1'); 
        System.schedule('Run at every 5 mins1', '0 10 * * * ? *', new TimeObjectScheduler());
        System.schedule('Run at every 5 mins2', '0 20 * * * ? *', new TimeObjectScheduler());
        System.schedule('Run at every 5 mins3', '0 30 * * * ? *', new TimeObjectScheduler());
        System.schedule('Run at every 5 mins4', '0 40 * * * ? *', new TimeObjectScheduler());
        System.schedule('Run at every 5 mins5', '0 50 * * * ? *', new TimeObjectScheduler());
        System.schedule('Run at every 5 mins6', '0 59 * * * ? *', new TimeObjectScheduler());
        system.debug('Nitin Yes 2' + datetime.now());*/
        /*System.abortJob('Run at every 5 mins1');
        System.abortJob('Run at every 5 mins2');
        System.abortJob('Run at every 5 mins3');
        System.abortJob('Run at every 5 mins4');
        System.abortJob('Run at every 5 mins5');
        System.abortJob('Run at every 5 mins6');*//*        
    }
    */

    public static testmethod void testTimeCalculator()
    {
        /*
        //Account testAcc = [select Id, Name, Site from Account where Id = '00120000000loSo'];
        //Account testAcc = [Select a.Site, a.Name From Account a where Site='London' and Name='Marbella Bankcorp' limit 1];
        
        //SLA__c sla = [select Id from SLA__c where Id='a14R000000008P7'];
        
        //Case testCase = new Case(Subject='teste',AccountId=testAcc.Id, Priority='Critical', Status='L1 – Awaiting Analysis');
        //insert testCase;

        Case testCase = [select Id, Status, Priority from Case where Subject = 'xxxxxxxxxxxxxxxxxxxx1234' limit 1];
        Case testCase1 = [select Id, Status, Priority from Case where Subject = 'xxxxxxxxxxxxxxxxxxxx12345' limit 1];
        
        testCase.Status = 'L2 – Under Analysis';
        update testCase;

        //TimeCalculator.CalculateElapsedTimes(new List<ID>{testCase.Id});
        
        //Time_Object__c timeObject = [select Id, Date_Time_Responded__c, Response_Time__c from Time_Object__c where Id =:testCase.Time_Object__c limit 1];
        Time_Object__c timeObject = [select Id, Date_Time_Responded__c, Response_Time__c from Time_Object__c where Case__c =:testCase.Id limit 1];
        
        timeObject.Date_Time_Responded__c = Datetime.now();
        update timeObject;
        
        testCase.Status = 'Client Testing';
        update testCase;
        
        //TimeCalculator.CalculateElapsedTimes(new List<ID>{testCase.Id});
        TimeCalculator.CalculateTimes(new List<ID>{testCase.Id});
        */
    }
}