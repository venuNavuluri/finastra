/**
 * @File Name          : UpliftProrataHandler.cls
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 30/07/2019, 16:10:41
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    09/07/2019, 17:00:31   Peter Sabry     Initial Version
**/
public class UpliftProrataHandler {
    
    public static void updateUpliftDatesForPro(Map<Id, SBQQ__Subscription__c> uplift_sub_map){
        List<Uplift__c> updateUplifts = new List<Uplift__c>();
        try{
            for(Uplift__c up: [SELECT Id, Name, Uplift_Effective_Date__c,Billing_Type__c,Uplift_Advance__c,IUP__c,CPI_Uplift_Type__c,Billing_Frequency__c, Uplift_Application_Date__c,NCU__c, Status__c FROM Uplift__c WHERE Id IN: uplift_sub_map.keySet()]){                
                if(up.Uplift_Advance__c == null) up.Uplift_Advance__c = 0;
                if(up.Billing_Frequency__c == 'Monthly'){
                    Date tdate = up.Uplift_Effective_Date__c.addMonths(1);
                    up.Uplift_Effective_Date__c  = tdate.toStartOfMonth();
                    
                }else if(up.Billing_Frequency__c == 'Quarterly'){
                    Date tdate = up.Uplift_Effective_Date__c.addMonths(3);
                    switch on tdate.month() {
                        when 1, 2, 3 {  // Q1   
                            up.Uplift_Effective_Date__c  = date.newinstance(tdate.year(), 1, 1);  
                        }   
                        when 4, 5, 6 {  // Q2   
                            up.Uplift_Effective_Date__c  = date.newinstance(tdate.year(), 4, 1);  
                        }
                        when 7, 8, 9 {  // Q3   
                            up.Uplift_Effective_Date__c  = date.newinstance(tdate.year(), 7, 1);  
                        }
                        when 10, 11, 12 { // Q4
                            up.Uplift_Effective_Date__c  = date.newinstance(tdate.year(), 10, 1);  
                        }
                    }
                } 
                else if(up.Billing_Frequency__c == 'Semiannual'){
                    Date tdate = up.Uplift_Effective_Date__c.addMonths(6);
                    if(tdate.month() <= 6){
                        up.Uplift_Effective_Date__c  = date.newinstance(tdate.year(), 7, 1);
                    } else {
                        up.Uplift_Effective_Date__c  = date.newinstance(tdate.year() +1, 1, 1);
                    }
                    
                } 
                else if(up.Billing_Frequency__c == 'Annual'){
                    up.Uplift_Effective_Date__c  = date.newinstance(up.Uplift_Effective_Date__c.year() +1, 1, 1);
                }
                if(up.Billing_Type__c == 'Advance'){
                    up.Uplift_Application_Date__c = up.Uplift_Effective_Date__c.addDays(-(Integer) up.Uplift_Advance__c);  
                }
                else if(up.Billing_Type__c == 'Arrears'){
                    up.Uplift_Application_Date__c = up.Uplift_Effective_Date__c.addDays((Integer) up.Uplift_Advance__c); 
                }
                
                if((up.CPI_Uplift_Type__c  == 'Anniversary' || up.CPI_Uplift_Type__c == 'Calender') && up.Billing_Frequency__c == 'Annual'){
                    up.Status__c = 'Full Year';
                } else if(up.CPI_Uplift_Type__c == 'Calender' && up.Billing_Frequency__c != 'Annual'){
                    if(up.Uplift_Effective_Date__c.month() == 1 && up.Uplift_Effective_Date__c.day() == 1 ){
                        up.Status__c = 'Full Year';
                    }else{
                      up.Status__c = 'Interim';
                      up.IUP__c = up.NCU__c;
                    }
                                    }
                updateUplifts.add(up);
            }          
        } Catch(Exception Ex){
            system.debug('unable to fetch uplift => '+ex.getMessage() + ' => '+ex.getLineNumber());
        }    finally{
            if(updateUplifts.size() > 0){
                update updateUplifts;
            }
        }     
    }
    
    public static void updateUpliftDatesForInterim(Map<Id, SBQQ__Subscription__c> uplift_sub_map){
        List<Uplift__c> updateUplifts = new List<Uplift__c>();
        try{
            for(Uplift__c up: [SELECT Id, Name, Uplift_Effective_Date__c ,Billing_Type__c, Uplift_Application_Date__c,IUP__c,Uplift_Advance__c, Status__c FROM Uplift__c WHERE Id IN: uplift_sub_map.keySet()]){
                up.Uplift_Effective_Date__c  = date.newinstance(up.Uplift_Effective_Date__c.year() + 1, 1, 1);
                //up.Uplift_Application_Date__c = date.newinstance(system.today().year(), 12, 31).addDays(-(Integer)uplift_sub_map.get(up.Id).SO_Generation_Advance__c); 
                if(up.Uplift_Advance__c == null) up.Uplift_Advance__c = 0;
                if(up.Billing_Type__c == 'Advance'){
                    up.Uplift_Application_Date__c = up.Uplift_Effective_Date__c.addDays(-(Integer) up.Uplift_Advance__c);  
                }
                else if(up.Billing_Type__c == 'Arrears'){
                    up.Uplift_Application_Date__c = up.Uplift_Effective_Date__c.addDays((Integer) up.Uplift_Advance__c); 
                }
                up.Status__c = 'Full Year';
                updateUplifts.add(up);
            }          
        } Catch(Exception Ex){
            system.debug('unable to fetch uplift => '+ex.getMessage() + ' => '+ex.getLineNumber());
        }    finally{
            if(updateUplifts.size() > 0){
                update updateUplifts;
            }
        }     
    }
    
    public static void updateUpliftDatesForStd(Map<Id, SBQQ__Subscription__c> uplift_sub_map){
        List<Uplift__c> updateUplifts = new List<Uplift__c>();
        try{
            for(Uplift__c up: [SELECT Id, Name, Uplift_Effective_Date__c, Uplift_Application_Date__c,Billing_Type__c,Uplift_Advance__c ,IUP__c, Status__c FROM Uplift__c WHERE Id IN: uplift_sub_map.keySet()]){                
                up.Uplift_Effective_Date__c  = up.Uplift_Effective_Date__c.addYears(1);
                if(up.Uplift_Advance__c == null) up.Uplift_Advance__c = 0;
                if(up.Billing_Type__c == 'Advance'){
                    up.Uplift_Application_Date__c = up.Uplift_Effective_Date__c.addDays(-(Integer) up.Uplift_Advance__c);  
                }
                else if(up.Billing_Type__c == 'Arrears'){
                    up.Uplift_Application_Date__c = up.Uplift_Effective_Date__c.addDays((Integer) up.Uplift_Advance__c); 
                }
                updateUplifts.add(up);
            }          
        } Catch(Exception Ex){
            system.debug('unable to fetch uplift => '+ex.getMessage() + ' => '+ex.getLineNumber());
        }    finally{
            if(updateUplifts.size() > 0){
                update updateUplifts;
            }
        }     
    }
    
    public static Boolean isEligibleForUplift(SBQQ__Subscription__c sub){
        return sub.CPI_Uplift__c != null && !sub.Exclude__c && !sub.CPI_Uplift__r.Exclude__c && !sub.SBQQ__Contract__r.Skip_Uplift__c;
    }
    
    public static Uplift__c[] calcualteUpliftFactor(Uplift__c[] newUps){
        for(Uplift__c up: newUps){
            if(up.Status__c != null /* && (Trigger.isUpdate && Trigger.oldMap.get(up.Id).status__c != up.Status__c)*/){            
                if(up.Status__c == 'Pro-Rata' && up.Start_Date__c  != null && up.Uplift_Effective_Date__c  != null){
                    Decimal daysInPeriod ;
                    if(up.Billing_Frequency__c == 'Monthly'){
                        daysInPeriod = up.Uplift_Effective_Date__c.daysBetween((up.Uplift_Effective_Date__c).addMonths(1));
                    }else if(up.Billing_Frequency__c == 'Quarterly'){
                        daysInPeriod = up.Uplift_Effective_Date__c.daysBetween((up.Uplift_Effective_Date__c ).addMonths(3));
                    }else if(up.Billing_Frequency__c == 'Semiannual'){
                        daysInPeriod = up.Uplift_Effective_Date__c.daysBetween((up.Uplift_Effective_Date__c ).addMonths(6));
                    }else if(up.Billing_Frequency__c == 'Annual'){
                        daysInPeriod = up.Uplift_Effective_Date__c.daysBetween((up.Uplift_Effective_Date__c ).addMonths(12));
                    }
                    Date endDate = (up.Start_Date__c );
                    decimal factor;
                    
                    if((up.Uplift_Effective_Date__c.daysBetween(endDate)/daysInPeriod ) > 1) factor = 0;
                    else if (up.Start_Date__c  < up.Uplift_Effective_Date__c  ) factor = 1;
                    else factor = 1 - ((up.Uplift_Effective_Date__c.daysBetween(endDate))/daysInPeriod).setScale(4);
                    if(up.NCU__c != null)
                    up.uplift_factor__c = 1+ ((factor*up.NCU__c)/100);                
                } 
                else if((up.Status__c == 'Interim') && up.IUP__c != null){
                    up.uplift_factor__c = 1 + up.IUP__c/100;  
                } 
                 else if((up.Status__c == 'Full Year' ) && up.NCU__c != null){
                    up.uplift_factor__c = 1 + up.NCU__c/100;  
                } 
            }
        }
        return newUps;
    }
    
    //NACM Billing - CPI Uplift - ATG Model - Start
    public static void updateUpliftDatesForPro(List<SBQQ__Subscription__c> subsList){
        try{
            for(SBQQ__Subscription__c sub: subsList){    
                if(sub.SO_Generation_Advance__c == null) sub.SO_Generation_Advance__c = 0;
                if(sub.SBQQ__BillingFrequency__c == 'Monthly'){
                    Date tdate = sub.Uplift_Effective_Date__c.addMonths(1);
                    sub.Uplift_Effective_Date__c  = tdate.toStartOfMonth();
                    
                }else if(sub.SBQQ__BillingFrequency__c == 'Quarterly'){
                    Date tdate = sub.Uplift_Effective_Date__c.addMonths(3);
                    switch on tdate.month() {
                        when 1, 2, 3 {  // Q1   
                            sub.Uplift_Effective_Date__c  = date.newinstance(tdate.year(), 1, 1);  
                        }   
                        when 4, 5, 6 {  // Q2   
                            sub.Uplift_Effective_Date__c  = date.newinstance(tdate.year(), 4, 1);  
                        }
                        when 7, 8, 9 {  // Q3   
                            sub.Uplift_Effective_Date__c  = date.newinstance(tdate.year(), 7, 1);  
                        }
                        when 10, 11, 12 { // Q4
                            sub.Uplift_Effective_Date__c  = date.newinstance(tdate.year(), 10, 1);  
                        }
                    }
                } 
                else if(sub.SBQQ__BillingFrequency__c == 'Semiannual'){
                    Date tdate = sub.Uplift_Effective_Date__c.addMonths(6);
                    if(tdate.month() <= 6){
                        sub.Uplift_Effective_Date__c  = date.newinstance(tdate.year(), 7, 1);
                    } else {
                        sub.Uplift_Effective_Date__c  = date.newinstance(tdate.year() +1, 1, 1);
                    }
                    
                } 
                else if(sub.SBQQ__BillingFrequency__c == 'Annual'){
                    sub.Uplift_Effective_Date__c  = date.newinstance(sub.Uplift_Effective_Date__c.year() +1, 1, 1);
                }
                if(sub.SBQQ__BillingType__c == 'Advance'){
                    sub.Uplift_Application_Date__c = sub.Uplift_Effective_Date__c.addDays(-(Integer) sub.SO_Generation_Advance__c).addDays(-1);  
                }
                else if(sub.SBQQ__BillingType__c == 'Arrears'){
                    sub.Uplift_Application_Date__c = sub.Uplift_Effective_Date__c.addDays((Integer) sub.SO_Generation_Advance__c).addDays(-1); 
                }
                if((sub.SBQQ__Contract__r.CPI_Uplift_Type__c  == 'Anniversary' || sub.SBQQ__Contract__r.CPI_Uplift_Type__c == 'Calendar') && sub.SBQQ__BillingFrequency__c == 'Annual'){
                    sub.Uplift_Calc_Type__c = 'Full Year';
                } else if(sub.SBQQ__Contract__r.CPI_Uplift_Type__c == 'Calendar' && sub.SBQQ__BillingFrequency__c != 'Annual'){
                    if(sub.Uplift_Effective_Date__c.month() == 1 && sub.Uplift_Effective_Date__c.day() == 1 ){
                        sub.Uplift_Calc_Type__c = 'Full Year';
                    }else{
                      sub.Uplift_Calc_Type__c = 'Interim';
                      sub.Interim_Uplift_Percentage__c = sub.Net_Customer_Uplift__c;
                    }
                }
            }          
        } Catch(Exception ex){
            system.debug('unable to fetch uplift => '+ex.getMessage() + ' => '+ex.getLineNumber());
            throw ex;
        }    finally{
            if(subsList.size() > 0){
                update subsList;
            }
        }     
    }
    
    public static void updateUpliftDatesForInterim(List<SBQQ__Subscription__c> subsList){
        try{
            for(SBQQ__Subscription__c sub : subsList){
                sub.Uplift_Effective_Date__c  = date.newinstance(sub.Uplift_Effective_Date__c.year() + 1, 1, 1);
                if(sub.SO_Generation_Advance__c == null) sub.SO_Generation_Advance__c = 0;
                if(sub.SBQQ__BillingType__c == 'Advance'){
                    sub.Uplift_Application_Date__c = sub.Uplift_Effective_Date__c.addDays(-(Integer) sub.SO_Generation_Advance__c).addDays(-1);  
                }
                else if(sub.SBQQ__BillingType__c == 'Arrears'){
                    sub.Uplift_Application_Date__c = sub.Uplift_Effective_Date__c.addDays((Integer) sub.SO_Generation_Advance__c).addDays(-1); 
                }
                sub.Uplift_Calc_Type__c = 'Full Year';
            }          
        } Catch(Exception ex){
            system.debug('unable to fetch uplift => '+ex.getMessage() + ' => '+ex.getLineNumber());
            throw ex;
        }    finally{
            if(subsList.size() > 0){
                update subsList;
            }
        }     
    }
    
    public static void updateUpliftDatesForStd(List<SBQQ__Subscription__c> subsList){
        try{
            for(SBQQ__Subscription__c sub : subsList){
                sub.Uplift_Effective_Date__c  = sub.Uplift_Effective_Date__c.addYears(1);
                if(sub.SO_Generation_Advance__c == null) sub.SO_Generation_Advance__c = 0;
                if(sub.SBQQ__BillingType__c == 'Advance'){
                    sub.Uplift_Application_Date__c = sub.Uplift_Effective_Date__c.addDays(-(Integer) sub.SO_Generation_Advance__c).addDays(-1);  
                }
                else if(sub.SBQQ__BillingType__c == 'Arrears'){
                    sub.Uplift_Application_Date__c = sub.Uplift_Effective_Date__c.addDays((Integer) sub.SO_Generation_Advance__c).addDays(-1); 
                }
            }          
        } Catch(Exception ex){
            system.debug('unable to fetch uplift => '+ex.getMessage() + ' => '+ex.getLineNumber());
            throw ex;
        }    finally{
            if(subsList.size() > 0){
                update subsList;
            }
        }     
    }
    
    public static Boolean isEligibleForCPIUplift(SBQQ__Subscription__c sub){
        return sub != null && !sub.Exclude__c && !sub.SBQQ__Contract__r.Skip_Uplift__c && (sub.SBQQ__Contract__r.Recurring_Fees_Index_Type__c != Constants.RF_INDEX_TYPE_NO_INCREASE) && !sub.SBQQ__Contract__r.Hold_CPI_Uplift__c;
    }
    
    public static List<SBQQ__Subscription__c> calcualteUpliftFactorForSubs(List<SBQQ__Subscription__c> subs){
        for(SBQQ__Subscription__c sub: subs){
            if(sub.Uplift_Calc_Type__c != null){  
                if(sub.Uplift_Calc_Type__c == 'Pro-Rata' && sub.CPI_Uplift_Review_Date__c != null && sub.Uplift_Effective_Date__c != null){
                    Decimal daysInPeriod ;
                    string billingFrequency = sub.SBQQ__BillingFrequency__c;
            
                    if(billingFrequency == 'Monthly'){
                        daysInPeriod = sub.Uplift_Effective_Date__c.daysBetween((sub.Uplift_Effective_Date__c).addMonths(1));
                    }else if(billingFrequency == 'Quarterly'){
                        daysInPeriod = sub.Uplift_Effective_Date__c.daysBetween((sub.Uplift_Effective_Date__c ).addMonths(3));
                    }else if(billingFrequency == 'Semiannual'){
                        daysInPeriod = sub.Uplift_Effective_Date__c.daysBetween((sub.Uplift_Effective_Date__c ).addMonths(6));
                    }else if(billingFrequency == 'Annual'){
                        daysInPeriod = sub.Uplift_Effective_Date__c.daysBetween((sub.Uplift_Effective_Date__c ).addMonths(12));
                    }else if(billingFrequency == 'Biennial'){
                        daysInPeriod = sub.Uplift_Effective_Date__c.daysBetween((sub.Uplift_Effective_Date__c ).addMonths(24));
                    }else if(billingFrequency == 'Triennial'){
                        daysInPeriod = sub.Uplift_Effective_Date__c.daysBetween((sub.Uplift_Effective_Date__c ).addMonths(36));
                    }else if(billingFrequency == 'Quinquennial'){
                        daysInPeriod = sub.Uplift_Effective_Date__c.daysBetween((sub.Uplift_Effective_Date__c ).addMonths(60));
                    }
                    Date endDate = sub.CPI_Uplift_Review_Date__c;
                    decimal factor;
                    
                    if((sub.Uplift_Effective_Date__c.daysBetween(endDate)/daysInPeriod ) > 1) {
                        factor = 0;
                    }
                    else if (endDate < sub.Uplift_Effective_Date__c  ) {
                        factor = 1;
                    }
                    else {
                        factor = 1 - ((sub.Uplift_Effective_Date__c.daysBetween(endDate))/daysInPeriod).setScale(4);
                    }
                    
                    if(sub.Net_Customer_Uplift__c != null) {
                        sub.Uplift_Factor__c = 1 + ((factor*sub.Net_Customer_Uplift__c)/100);           
                    }
                } 
                else if((sub.Uplift_Calc_Type__c == 'Interim') && sub.Interim_Uplift_Percentage__c != null){
                    sub.Uplift_Factor__c = 1 + sub.Interim_Uplift_Percentage__c/100;
                } 
                else if((sub.Uplift_Calc_Type__c == 'Full Year' ) && sub.Net_Customer_Uplift__c != null){
                    sub.Uplift_Factor__c = 1 + sub.Net_Customer_Uplift__c/100;
                }
            }
        }
        return subs;
    }
    //NACM Billing - CPI Uplift - ATG Model - End
}