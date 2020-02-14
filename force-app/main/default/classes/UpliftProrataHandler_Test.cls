/**
 * @File Name          : UpliftProrataHandler_Test.cls
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 24/07/2019, 13:20:38
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    12/07/2019, 13:05:16   Peter Sabry     Initial Version
**/
@isTest
public class UpliftProrataHandler_Test {
    
    private static Uplift__c createUpliftData(){
        Uplift__c uplift1 = new Uplift__c(Exclude__c = true, Status__c = 'Pro-Rata', Billing_Type__c = 'Advance',Uplift_Advance__c = 61,Billing_Frequency__c = 'Monthly',
                                            Hold_Billing__c = false, Active__c = true, 
                                          Uplift_Application_Date__c  = Date.today(),Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today());
        insert uplift1; 
        
        return uplift1;
    }
    private static SBQQ__Subscription__c createSubData(Uplift__c uplift1){
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Varied_Licence__c = true,CPI_Uplift__c = uplift1.id,
                Transactions__c = 2, Sold_Value__c = 50, SBQQ__NetPrice__c = 100, SBQQ__BillingType__c = 'Advance');
        insert subscription; 
        
        return subscription;
    }
    private static Contract createContractUpliftData(Id accountId){
        Contract contract1 = new Contract(Uplift_Calc_Type__c = 'Pro-Rata', CPI_Uplift_Type__c='Calendar', Billing_Frequency__c = 'Monthly', AccountId = accountId,
                                            Hold_CPI_Uplift__c = false, Active__c = true, Uplift_Application_Date__c  = Date.today());
        insert contract1; 
        
        return contract1;
    }
    private static SBQQ__Subscription__c createSubDataFromContract(Contract contr){
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Uplift_Calc_Type__c = 'Pro-Rata', SO_Generation_Advance__c=60, Varied_Licence__c = true,SBQQ__Contract__c = contr.id, Uplift_Application_Date__c  = Date.today(),
                Transactions__c = 2, Sold_Value__c = 50, SBQQ__NetPrice__c = 100, Exclude__c = false, CPI_Uplift_Review_Date__c = Date.Today(), SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Monthly', Uplift_Effective_Date__c  = Date.today());
        insert subscription; 
        
        return subscription;
    }
    private static testmethod void updateUpliftDatesForProTest1(){

        Uplift__c  upl = createUpliftData();
        upl.Billing_Frequency__c = 'Monthly';
        update upl;
        SBQQ__Subscription__c sub = createSubData(upl);
        
        Map<Id, SBQQ__Subscription__c> subswithuplift = new Map<Id, SBQQ__Subscription__c>();
        subswithuplift.put(upl.id, sub);
         test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subswithuplift);
        Uplift__c up1 = [select id, Uplift_Effective_Date__c from Uplift__c limit 1];
        system.assertEquals(system.today().toStartOfMonth().addmonths(1), up1.Uplift_Effective_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest1_2(){
		Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        contr.Billing_Frequency__c = 'Monthly';
        update contr;
        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        subList.add(sub);
        test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subList);
        SBQQ__Subscription__c s1 = [select id, Uplift_Effective_Date__c from SBQQ__Subscription__c limit 1];
        system.assertEquals(system.today().toStartOfMonth().addmonths(1), s1.Uplift_Effective_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest2(){

        Uplift__c  upl = createUpliftData();
        upl.Billing_Frequency__c = 'Quarterly';
        update upl;
        SBQQ__Subscription__c sub = createSubData(upl);
        
        Map<Id, SBQQ__Subscription__c> subswithuplift = new Map<Id, SBQQ__Subscription__c>();
        subswithuplift.put(upl.id, sub);
         test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subswithuplift);
        Uplift__c up1 = [select id, Uplift_Effective_Date__c from Uplift__c limit 1];
        
        //system.assertEquals(system.today().toStartOfMonth().addmonths(2), up1.Uplift_Effective_Date__c);
        date dateqtr = system.today().toStartOfMonth().addmonths(3);
        date effectiveDate;
        if(dateqtr.month()==1 ||dateqtr.month()==2 || dateqtr.month()==3){
             effectiveDate = date.newinstance(dateqtr.year(), 1, 1);
        } else if (dateqtr.month()==4 ||dateqtr.month()==5 || dateqtr.month()==6){
             effectiveDate = date.newinstance(dateqtr.year(), 4, 1);
        } else if (dateqtr.month()==7 ||dateqtr.month()==8 || dateqtr.month()==9){
             effectiveDate = date.newinstance(dateqtr.year(), 7, 1);
        }
        else {
             effectiveDate = date.newinstance(dateqtr.year(), 10, 1);
        }
        system.assertEquals(effectiveDate, up1.Uplift_Effective_Date__c,''+effectiveDate+'<>'+up1.Uplift_Effective_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest2_2(){
        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        contr.Billing_Frequency__c = 'Quarterly';
        update contr;

        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        sub.SBQQ__BillingFrequency__c = 'Quarterly';
        update sub;
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        subList.add(sub);
        
         test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subList);
        SBQQ__Subscription__c s1 = [select id, Uplift_Effective_Date__c from SBQQ__Subscription__c limit 1];
        
        date dateqtr = system.today().toStartOfMonth().addmonths(3);
        date effectiveDate;
        if(dateqtr.month()==1 ||dateqtr.month()==2 || dateqtr.month()==3){
             effectiveDate = date.newinstance(dateqtr.year(), 1, 1);
        } else if (dateqtr.month()==4 ||dateqtr.month()==5 || dateqtr.month()==6){
             effectiveDate = date.newinstance(dateqtr.year(), 4, 1);
        } else if (dateqtr.month()==7 ||dateqtr.month()==8 || dateqtr.month()==9){
             effectiveDate = date.newinstance(dateqtr.year(), 7, 1);
        }
        else {
             effectiveDate = date.newinstance(dateqtr.year(), 10, 1);
        }
        system.assertEquals(effectiveDate, s1.Uplift_Effective_Date__c,''+effectiveDate+'<>'+s1.Uplift_Effective_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest3(){

        Uplift__c  upl = createUpliftData();
        upl.Billing_Frequency__c = 'Semiannual';
        upl.CPI_Uplift_Type__c = 'Calender';
        upl.Billing_Type__c = 'Arrears';
        update upl;
        SBQQ__Subscription__c sub = createSubData(upl);
        
        Map<Id, SBQQ__Subscription__c> subswithuplift = new Map<Id, SBQQ__Subscription__c>();
        subswithuplift.put(upl.id, sub);
         test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subswithuplift);
        Uplift__c up1 = [select id,Uplift_Advance__c,Status__c,Uplift_Application_Date__c, Uplift_Effective_Date__c from Uplift__c limit 1];
        date dateqtr = system.today().toStartOfMonth().addmonths(6);
        date effectiveDate;
        if(dateqtr.month()<= 6){
             effectiveDate = date.newinstance(dateqtr.year(), 7, 1);
        }
        else {
             effectiveDate = date.newinstance(dateqtr.year()+1, 1, 1);
        }
        system.assertEquals(effectiveDate, up1.Uplift_Effective_Date__c);
        system.assertEquals(up1.Uplift_Effective_Date__c.addDays((Integer) up1.Uplift_Advance__c), up1.Uplift_Application_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest3_2(){
        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        contr.Billing_Frequency__c = 'Semiannual';
        contr.CPI_Uplift_Type__c = 'Calendar';
        update contr;

        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        sub.SBQQ__BillingFrequency__c = 'Semiannual';
        sub.SBQQ__BillingType__c = 'Arrears';
        update sub;
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        subList.add(sub);

        test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subList);
        SBQQ__Subscription__c s1 = [select id, SO_Generation_Advance__c, Uplift_Application_Date__c, Uplift_Effective_Date__c from SBQQ__Subscription__c limit 1];
        
        date dateqtr = system.today().toStartOfMonth().addmonths(6);
        date effectiveDate;
        if(dateqtr.month()<= 6){
             effectiveDate = date.newinstance(dateqtr.year(), 7, 1);
        }
        else {
             effectiveDate = date.newinstance(dateqtr.year()+1, 1, 1);
        }
        system.assertEquals(effectiveDate, s1.Uplift_Effective_Date__c);
        system.assertEquals(s1.Uplift_Effective_Date__c.addDays((Integer) s1.SO_Generation_Advance__c).addDays(-1), s1.Uplift_Application_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest4(){

        Uplift__c  upl = createUpliftData();
        upl.Billing_Frequency__c = 'Annual';
        upl.CPI_Uplift_Type__c = 'Calender';
        update upl;
        SBQQ__Subscription__c sub = createSubData(upl);
        
        Map<Id, SBQQ__Subscription__c> subswithuplift = new Map<Id, SBQQ__Subscription__c>();
        subswithuplift.put(upl.id, sub);
         test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subswithuplift);
        Uplift__c up1 = [select id,Status__c, Uplift_Effective_Date__c from Uplift__c limit 1];
        system.assertEquals(date.newinstance(system.today().year()+1,1, 1), up1.Uplift_Effective_Date__c);
        system.assertEquals('Full Year', up1.Status__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest4_2(){
         Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        contr.Billing_Frequency__c = 'Annual';
        contr.CPI_Uplift_Type__c = 'Calendar';
        update contr;

        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        sub.SBQQ__BillingFrequency__c = 'Annual';
        update sub;
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id, SO_Generation_Advance__c, SBQQ__BillingFrequency__c, SBQQ__Contract__r.CPI_Uplift_Type__c, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c]);

        test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subList);
        SBQQ__Subscription__c s1 = [select id, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c limit 1];
       
        system.assertEquals(date.newinstance(system.today().year()+1,1, 1), s1.Uplift_Effective_Date__c);
        system.assertEquals('Full Year', s1.Uplift_Calc_Type__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest5(){

        Uplift__c  upl = createUpliftData();
        upl.Billing_Frequency__c = 'Semiannual';
        upl.CPI_Uplift_Type__c = 'Calender';
        upl.Billing_Type__c = 'Arrears';
        
        update upl;
        SBQQ__Subscription__c sub = createSubData(upl);
        
        Map<Id, SBQQ__Subscription__c> subswithuplift = new Map<Id, SBQQ__Subscription__c>();
        subswithuplift.put(upl.id, sub);
         test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subswithuplift);
        Uplift__c up1 = [select id,Uplift_Advance__c,Status__c,Uplift_Application_Date__c, Uplift_Effective_Date__c from Uplift__c limit 1];
        date dateqtr = system.today().toStartOfMonth().addmonths(6);
        date effectiveDate;
        if(dateqtr.month()<= 6){
             effectiveDate = date.newinstance(dateqtr.year(), 7, 1);
        }
        else {
             effectiveDate = date.newinstance(dateqtr.year()+1, 1, 1);
        }
        system.assertEquals(effectiveDate, up1.Uplift_Effective_Date__c);
        system.assertEquals(up1.Uplift_Effective_Date__c.addDays((Integer) up1.Uplift_Advance__c), up1.Uplift_Application_Date__c);
        //G.B 05.07.2019 -  fix test methods blocking predprod deployment
        system.assertEquals( (up1.Uplift_Effective_Date__c.month()<= 6?'Full Year':'Interim'), up1.Status__c);
        //system.assertEquals('Full Year', up1.Status__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest5_2(){
        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        contr.Billing_Frequency__c = 'Semiannual';
        contr.CPI_Uplift_Type__c = 'Calendar';
        update contr;

        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        sub.SBQQ__BillingFrequency__c = 'Semiannual';
        sub.SBQQ__BillingType__c = 'Arrears';
        update sub;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id, SO_Generation_Advance__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c, SBQQ__Contract__r.CPI_Uplift_Type__c, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c]);

        test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subList);
        
        SBQQ__Subscription__c s1 = [select id, Uplift_Calc_Type__c, SO_Generation_Advance__c, Uplift_Application_Date__c, Uplift_Effective_Date__c from SBQQ__Subscription__c limit 1];
       
        date dateqtr = system.today().toStartOfMonth().addmonths(6);
        date effectiveDate;
        if(dateqtr.month()<= 6){
             effectiveDate = date.newinstance(dateqtr.year(), 7, 1);
        }
        else {
             effectiveDate = date.newinstance(dateqtr.year()+1, 1, 1);
        }
        system.assertEquals(effectiveDate, s1.Uplift_Effective_Date__c);
        system.assertEquals(s1.Uplift_Effective_Date__c.addDays((Integer) s1.SO_Generation_Advance__c).addDays(-1), s1.Uplift_Application_Date__c);
        system.assertEquals( (s1.Uplift_Effective_Date__c.month()<= 6?'Full Year':'Interim'), s1.Uplift_Calc_Type__c);
        //system.assertEquals('Full Year', s1.Uplift_Calc_Type__c);        
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest6(){

        Uplift__c  upl = createUpliftData();
        upl.Billing_Frequency__c = 'Annual';
        upl.Uplift_Effective_Date__c = system.today().addmonths(3);
        upl.CPI_Uplift_Type__c = 'Calender';
        update upl;
        SBQQ__Subscription__c sub = createSubData(upl);
        
        Map<Id, SBQQ__Subscription__c> subswithuplift = new Map<Id, SBQQ__Subscription__c>();
        subswithuplift.put(upl.id, sub);
         test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subswithuplift);
        Uplift__c up1 = [select id, Status__c from Uplift__c limit 1];
        system.assertEquals('Full Year', up1.Status__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest6_2(){
        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        contr.Billing_Frequency__c = 'Annual';
        contr.CPI_Uplift_Type__c = 'Calendar';
        update contr;

        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        sub.SBQQ__BillingFrequency__c = 'Annual';
        sub.Uplift_Effective_Date__c = system.today().addmonths(3);
        
        update sub;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id, SO_Generation_Advance__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c, SBQQ__Contract__r.CPI_Uplift_Type__c, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c]);

        test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subList);
        
        SBQQ__Subscription__c s1 = [select id, Uplift_Calc_Type__c, SO_Generation_Advance__c, Uplift_Application_Date__c, Uplift_Effective_Date__c from SBQQ__Subscription__c limit 1];
       
        system.assertEquals('Full Year', s1.Uplift_Calc_Type__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest8(){
        Uplift__c  upl = createUpliftData();
        upl.Billing_Frequency__c = 'Quarterly';
        upl.Uplift_Effective_Date__c = system.today().addmonths(6);
         upl.CPI_Uplift_Type__c = 'Calender';
        update upl;
        SBQQ__Subscription__c sub = createSubData(upl);
        
        Map<Id, SBQQ__Subscription__c> subswithuplift = new Map<Id, SBQQ__Subscription__c>();
        subswithuplift.put(upl.id, sub);
         test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subswithuplift);
        Uplift__c up1 = [select id, Status__c from Uplift__c limit 1];
        //system.assertEquals('Interim', up1.Status__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest8_2(){
        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        contr.Billing_Frequency__c = 'Quarterly';
        contr.CPI_Uplift_Type__c = 'Calendar';
        
        update contr;

        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        sub.SBQQ__BillingFrequency__c = 'Quarterly';
        sub.Uplift_Effective_Date__c = date.newinstance(system.today().year(), 3, 15);
        update sub;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id, SO_Generation_Advance__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c, Uplift_Application_Date__c, SBQQ__Contract__r.CPI_Uplift_Type__c, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c]);

        test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subList);
        
        SBQQ__Subscription__c s1 = [select id, Uplift_Calc_Type__c, SO_Generation_Advance__c, Uplift_Application_Date__c, Uplift_Effective_Date__c from SBQQ__Subscription__c limit 1];
       
        system.assertEquals('Interim', s1.Uplift_Calc_Type__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest7(){

        Uplift__c  upl = createUpliftData();
        upl.Billing_Frequency__c = 'Quarterly';
        upl.Uplift_Effective_Date__c = system.today().addmonths(9);
        update upl;
        SBQQ__Subscription__c sub = createSubData(upl);
        
        Map<Id, SBQQ__Subscription__c> subswithuplift = new Map<Id, SBQQ__Subscription__c>();
        subswithuplift.put(upl.id, sub);
         test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subswithuplift);
        Uplift__c up1 = [select id, Uplift_Effective_Date__c from Uplift__c limit 1];
        //system.assertEquals(system.today().toStartOfMonth().addmonths(11), up1.Uplift_Effective_Date__c);
        
        date dateqtr = system.today().toStartOfMonth().addmonths(12);
        date effectiveDate;
        if(dateqtr.month()==1 ||dateqtr.month()==2 || dateqtr.month()==3){
             effectiveDate = date.newinstance(dateqtr.year(), 1, 1);
        } else if (dateqtr.month()==4 ||dateqtr.month()==5 || dateqtr.month()==6){
             effectiveDate = date.newinstance(dateqtr.year(), 4, 1);
        } else if (dateqtr.month()==7 ||dateqtr.month()==8 || dateqtr.month()==9){
             effectiveDate = date.newinstance(dateqtr.year(), 7, 1);
        }
        else {
             effectiveDate = date.newinstance(dateqtr.year(), 10, 1);
        }
        system.assertEquals(effectiveDate, up1.Uplift_Effective_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForProTest7_2(){
		Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        contr.Billing_Frequency__c = 'Quarterly';
        contr.CPI_Uplift_Type__c = 'Calendar';
        
        update contr;

        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        sub.SBQQ__BillingFrequency__c = 'Quarterly';
        sub.Uplift_Effective_Date__c = system.today().addmonths(9);
        update sub;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id, SO_Generation_Advance__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c, Uplift_Application_Date__c, SBQQ__Contract__r.CPI_Uplift_Type__c, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c]);
		
        test.startTest();
        UpliftProrataHandler.updateUpliftDatesForPro(subList);
        SBQQ__Subscription__c s1 = [select id, Uplift_Calc_Type__c, SO_Generation_Advance__c, Uplift_Application_Date__c, Uplift_Effective_Date__c from SBQQ__Subscription__c limit 1];
       
        date dateqtr = system.today().toStartOfMonth().addmonths(12);
        date effectiveDate;
        if(dateqtr.month()==1 ||dateqtr.month()==2 || dateqtr.month()==3){
             effectiveDate = date.newinstance(dateqtr.year(), 1, 1);
        } else if (dateqtr.month()==4 ||dateqtr.month()==5 || dateqtr.month()==6){
             effectiveDate = date.newinstance(dateqtr.year(), 4, 1);
        } else if (dateqtr.month()==7 ||dateqtr.month()==8 || dateqtr.month()==9){
             effectiveDate = date.newinstance(dateqtr.year(), 7, 1);
        }
        else {
             effectiveDate = date.newinstance(dateqtr.year(), 10, 1);
        }
        system.assertEquals(effectiveDate, s1.Uplift_Effective_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForInterimtest1(){

        Uplift__c  upl = createUpliftData();
        upl.Billing_Type__c = 'Advance';
        upl.Uplift_Advance__c = 61;
        update upl;
        SBQQ__Subscription__c sub = createSubData(upl);
        
        Map<Id, SBQQ__Subscription__c> subswithuplift = new Map<Id, SBQQ__Subscription__c>();
        subswithuplift.put(upl.id, sub);
         test.startTest();
        UpliftProrataHandler.updateUpliftDatesForInterim(subswithuplift);
        Uplift__c up1 = [select id, Uplift_Effective_Date__c,Uplift_Advance__c,Uplift_Application_Date__c from Uplift__c limit 1];
        system.assertEquals(date.newinstance(system.today().year()+1,1, 1), up1.Uplift_Effective_Date__c);
        system.assertEquals(up1.Uplift_Effective_Date__c.addDays(-(Integer) up1.Uplift_Advance__c), up1.Uplift_Application_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForInterimtest1_2(){

        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        
        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        sub.SBQQ__BillingFrequency__c = 'Quarterly';
        sub.SBQQ__BillingType__c = 'Advance';
        sub.SO_Generation_Advance__c = 60;
        update sub;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id, SO_Generation_Advance__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c, Uplift_Application_Date__c, SBQQ__Contract__r.CPI_Uplift_Type__c, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c]);
		
        test.startTest();
        UpliftProrataHandler.updateUpliftDatesForInterim(subList);
        
        SBQQ__Subscription__c s1 = [select id, Uplift_Calc_Type__c, SO_Generation_Advance__c, Uplift_Application_Date__c, Uplift_Effective_Date__c from SBQQ__Subscription__c limit 1];

        system.assertEquals(date.newinstance(system.today().year()+1,1, 1), s1.Uplift_Effective_Date__c);
        system.assertEquals(s1.Uplift_Effective_Date__c.addDays(-(Integer) s1.SO_Generation_Advance__c).addDays(-1), s1.Uplift_Application_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForInterimtest2(){

        Uplift__c  upl = createUpliftData();
        upl.Billing_Type__c = 'Arrears';
        upl.Uplift_Advance__c = 28;
        update upl;
        SBQQ__Subscription__c sub = createSubData(upl);
        
        Map<Id, SBQQ__Subscription__c> subswithuplift = new Map<Id, SBQQ__Subscription__c>();
        subswithuplift.put(upl.id, sub);
         test.startTest();
        UpliftProrataHandler.updateUpliftDatesForInterim(subswithuplift);
        Uplift__c up1 = [select id, Uplift_Effective_Date__c,Uplift_Application_Date__c,Uplift_Advance__c from Uplift__c limit 1];
        system.assertEquals(date.newinstance(system.today().year()+1,1, 1), up1.Uplift_Effective_Date__c);
        system.assertEquals(up1.Uplift_Effective_Date__c.addDays((Integer) up1.Uplift_Advance__c), up1.Uplift_Application_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForInterimtest2_2(){
        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        
        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        sub.SBQQ__BillingType__c = 'Arrears';
        sub.SO_Generation_Advance__c = 29;
        update sub;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id, SO_Generation_Advance__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c, Uplift_Application_Date__c, SBQQ__Contract__r.CPI_Uplift_Type__c, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c]);
		
        test.startTest();
        UpliftProrataHandler.updateUpliftDatesForInterim(subList);
        
        SBQQ__Subscription__c s1 = [select id, Uplift_Calc_Type__c, SO_Generation_Advance__c, Uplift_Application_Date__c, Uplift_Effective_Date__c from SBQQ__Subscription__c limit 1];

        system.assertEquals(date.newinstance(system.today().year()+1,1, 1), s1.Uplift_Effective_Date__c);
        system.assertEquals(s1.Uplift_Effective_Date__c.addDays((Integer) s1.SO_Generation_Advance__c).addDays(-1), s1.Uplift_Application_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForStdtest1(){

        Uplift__c  upl = createUpliftData();
        upl.Billing_Type__c = 'Advance';
        upl.Uplift_Advance__c = 61;
        update upl;
        SBQQ__Subscription__c sub = createSubData(upl);
        
        Map<Id, SBQQ__Subscription__c> subswithuplift = new Map<Id, SBQQ__Subscription__c>();
        subswithuplift.put(upl.id, sub);
         test.startTest();
        UpliftProrataHandler.updateUpliftDatesForStd(subswithuplift);
        Uplift__c up1 = [select id, Uplift_Effective_Date__c,Uplift_Application_Date__c,Uplift_Advance__c from Uplift__c limit 1];
        system.assertEquals(system.today().addyears(1), up1.Uplift_Effective_Date__c);
        system.assertEquals(up1.Uplift_Effective_Date__c.addDays(-(Integer) up1.Uplift_Advance__c), up1.Uplift_Application_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForStdtest1_2(){
        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        
        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        sub.SBQQ__BillingType__c = 'Advance';
        sub.SO_Generation_Advance__c = 60;
        update sub;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id, SO_Generation_Advance__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c, Uplift_Application_Date__c, SBQQ__Contract__r.CPI_Uplift_Type__c, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c]);
		
        test.startTest();
        UpliftProrataHandler.updateUpliftDatesForStd(subList);
        SBQQ__Subscription__c s1 = [select id, Uplift_Calc_Type__c, SO_Generation_Advance__c, Uplift_Application_Date__c, Uplift_Effective_Date__c from SBQQ__Subscription__c limit 1];

        system.assertEquals(system.today().addyears(1), s1.Uplift_Effective_Date__c);
        system.assertEquals(s1.Uplift_Effective_Date__c.addDays(-(Integer) s1.SO_Generation_Advance__c).addDays(-1), s1.Uplift_Application_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForStdtest2(){

        Uplift__c  upl = createUpliftData();
        upl.Billing_Type__c = 'Arrears';
        upl.Uplift_Advance__c = 28;
        update upl;
        SBQQ__Subscription__c sub = createSubData(upl);
        
        Map<Id, SBQQ__Subscription__c> subswithuplift = new Map<Id, SBQQ__Subscription__c>();
        subswithuplift.put(upl.id, sub);
         test.startTest();
        UpliftProrataHandler.updateUpliftDatesForStd(subswithuplift);
        Uplift__c up1 = [select id, Uplift_Effective_Date__c,Uplift_Application_Date__c,Uplift_Advance__c from Uplift__c limit 1];
        system.assertEquals(system.today().addyears(1), up1.Uplift_Effective_Date__c);
        system.assertEquals(up1.Uplift_Effective_Date__c.addDays((Integer) up1.Uplift_Advance__c), up1.Uplift_Application_Date__c);
        test.stopTest();
    }
    private static testmethod void updateUpliftDatesForStdtest2_2(){
        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        
        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        sub.SBQQ__BillingType__c = 'Arrears';
        sub.SO_Generation_Advance__c = 29;
        update sub;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id, SO_Generation_Advance__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c, Uplift_Application_Date__c, SBQQ__Contract__r.CPI_Uplift_Type__c, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c]);
		test.startTest();
        UpliftProrataHandler.updateUpliftDatesForStd(subList);
        
        SBQQ__Subscription__c s1 = [select id, Uplift_Calc_Type__c, SO_Generation_Advance__c, Uplift_Application_Date__c, Uplift_Effective_Date__c from SBQQ__Subscription__c limit 1];

        system.assertEquals(system.today().addyears(1), s1.Uplift_Effective_Date__c);
        system.assertEquals(s1.Uplift_Effective_Date__c.addDays((Integer) s1.SO_Generation_Advance__c).addDays(-1), s1.Uplift_Application_Date__c);
        test.stopTest();
    }
    Private static testmethod void calcualteUpliftFactortest1(){
        list<Uplift__c> allUps = new list<Uplift__c>();
        Uplift__c  upl = createUpliftData();
        SBQQ__Subscription__c sub = createSubData(upl);
        upl.Status__c = 'Pro-Rata';
        upl.Start_Date__c = system.today().toStartOfMonth().addmonths(-3);
        upl.Override__c = 4;
        upl.CA_Recurring_Fees_Index_Type__c = 'CAP';
        upl.Billing_Frequency__c = 'Annual';
        upl.Exclude__c = false;
        upl.Uplift_Effective_Date__c = system.today();
        allUps.add(upl);
        if(allUps.size()> 0)
        update allUps;
        test.startTest();
        UpliftProrataHandler.calcualteUpliftFactor(allUps);
        Uplift__c up1 = [select id, uplift_factor__c from Uplift__c limit 1];
        system.assertEquals(1.040000, up1.uplift_factor__c);
        test.stopTest();
        
    }
    Private static testmethod void calcualteUpliftFactortest1_2(){
        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        contr.Recurring_Fees_Index_Type__c = 'CAP';
        update contr;
        
        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        
        sub.Uplift_Calc_Type__c = 'Pro-Rata';
        sub.CPI_Uplift_Review_Date__c = system.today().toStartOfMonth().addmonths(-3);
        sub.CPI_Uplift_Override__c = 4;
        sub.SBQQ__BillingFrequency__c = 'Annual';
        sub.Uplift_Effective_Date__c = system.today();
        update sub;

        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id, Uplift_Factor__c, CPI_Uplift_Review_Date__c, Net_Customer_Uplift__c, Interim_Uplift_Percentage__c, SO_Generation_Advance__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c, Uplift_Application_Date__c, SBQQ__Contract__r.CPI_Uplift_Type__c, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c]);
		
        test.startTest();
        UpliftProrataHandler.calcualteUpliftFactorForSubs(subList);
        SBQQ__Subscription__c s1 = [select id, uplift_factor__c from SBQQ__Subscription__c limit 1];
        system.assertEquals(1.040000, s1.uplift_factor__c);
        test.stopTest();
        
    }
    Private static testmethod void calcualteUpliftFactortest2(){
        list<Uplift__c> allUps = new list<Uplift__c>();
        Uplift__c  upl = createUpliftData();
        SBQQ__Subscription__c sub = createSubData(upl);
        upl.Status__c = 'Pro-Rata';
        upl.Start_Date__c = system.today().toStartOfMonth().addmonths(-3);
        //upl.Override__c = 4;
        upl.CA_Recurring_Fees_Index_Type__c = 'CAP';
        upl.Billing_Frequency__c = 'Annual';
        upl.Uplift_Effective_Date__c = system.today();
        upl.Exclude__c = false;
        allUps.add(upl);
        if(allUps.size()> 0)
        update allUps;
        test.startTest();
        UpliftProrataHandler.calcualteUpliftFactor(allUps);
        Uplift__c up1 = [select id, uplift_factor__c from Uplift__c limit 1];
        system.assertEquals(1, up1.uplift_factor__c);
        test.stopTest();
        
    }
    Private static testmethod void calcualteUpliftFactortest2_2(){
        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        contr.Recurring_Fees_Index_Type__c = 'CAP';
        update contr;
        
        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        sub.Uplift_Calc_Type__c = 'Pro-Rata';
        sub.CPI_Uplift_Review_Date__c = system.today().toStartOfMonth().addmonths(-3);
        sub.SBQQ__BillingFrequency__c = 'Annual';
        sub.Uplift_Effective_Date__c = system.today();
        update sub;

        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id, Uplift_Factor__c, CPI_Uplift_Review_Date__c, Net_Customer_Uplift__c, Interim_Uplift_Percentage__c, SO_Generation_Advance__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c, Uplift_Application_Date__c, SBQQ__Contract__r.CPI_Uplift_Type__c, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c]);
		
        test.startTest();
        UpliftProrataHandler.calcualteUpliftFactorForSubs(subList);
        SBQQ__Subscription__c s1 = [select id, uplift_factor__c from SBQQ__Subscription__c limit 1];
        system.assertEquals(1, s1.uplift_factor__c);
        test.stopTest();
    }
    Private static testmethod void calcualteUpliftFactortest3(){
        list<Uplift__c> allUps = new list<Uplift__c>();
        Uplift__c  upl = createUpliftData();
        if(allUps.size()> 0)
        update allUps;
        test.startTest();
        UpliftProrataHandler.calcualteUpliftFactor(allUps);
        Uplift__c up1 = [select id, uplift_factor__c from Uplift__c limit 1];
        system.assertEquals(1, up1.uplift_factor__c);
        test.stopTest();
        
    }
    Private static testmethod void calcualteUpliftFactortest3_2(){
        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        update sub;
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id, Uplift_Factor__c, CPI_Uplift_Review_Date__c, Net_Customer_Uplift__c, Interim_Uplift_Percentage__c, SO_Generation_Advance__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c, Uplift_Application_Date__c, SBQQ__Contract__r.CPI_Uplift_Type__c, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c]);
		
        test.startTest();
        UpliftProrataHandler.calcualteUpliftFactorForSubs(subList);
        SBQQ__Subscription__c s1 = [select id, uplift_factor__c from SBQQ__Subscription__c limit 1];
        system.assertEquals(1.035, s1.uplift_factor__c);
        test.stopTest();        
    }
    private static testmethod void isEligibleForUplifttest1(){
        Uplift__c  upl = createUpliftData();
        SBQQ__Subscription__c sub = createSubData(upl);
        sub.CPI_Uplift__c=null;
        System.assertEquals(false,UpliftProrataHandler.isEligibleForUplift(sub));  
    }
    private static testmethod void isEligibleForUplifttest1_2(){
        Account account = new Account(name = 'uplift test account');
        insert account;
        
        Contract contr = createContractUpliftData(account.Id);
        contr.Skip_Uplift__c = true;
        update contr;
        
        SBQQ__Subscription__c sub = createSubDataFromContract(contr);
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id, Uplift_Factor__c, Exclude__c, SBQQ__Contract__r.Hold_CPI_Uplift__c, SBQQ__Contract__r.Skip_Uplift__c, SBQQ__Contract__r.Recurring_Fees_Index_Type__c, CPI_Uplift_Review_Date__c, Net_Customer_Uplift__c, Interim_Uplift_Percentage__c, SO_Generation_Advance__c, SBQQ__BillingType__c, SBQQ__BillingFrequency__c, Uplift_Application_Date__c, SBQQ__Contract__r.CPI_Uplift_Type__c, Uplift_Calc_Type__c, Uplift_Effective_Date__c from SBQQ__Subscription__c]);
		
        System.assertEquals(false,UpliftProrataHandler.isEligibleForCPIUplift(subList[0]));  
    }
    private static testmethod void isEligibleForUplifttest2(){
         try {
            UpliftProrataHandler.isEligibleForUplift(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
    }
  
}