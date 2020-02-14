/*
 * @author Serhii Volynets sergey.volinets@weare4c.com
 * This purpose of this class is to find FDIC_NCUA_Data__c records which are not associated with Account, and associate them with Account using Certificate__c as a key.
 * The use case for that is when FDIC_NCUA_Data__c insert is earlier then Account record. 
 */
global class FDIC_Batch implements Schedulable,Database.Batchable<sobject> 
{
    /*
     * method returns query locator of FDIC records which is used by Batchable class to split them  and execute Account search
     * 
     * */
    global Database.QueryLocator start(Database.BatchableContext bc)
    {// looking for FDIC records with empty account__c field value
        string expr = 'select id,Certificate__c,Quarter__c,Report_Date__c,Year__c, Data_Source__c,Account__c from FDIC_NCUA_Data__c where Account__c = null order by Report_Date__c';
        return Database.getQueryLocator(expr);
    }
    
    /*
     * method executes account search for given part of FDIC record which do not have Account__c populated
     */
    global void execute(Database.BatchableContext bc, list<sobject> lrec)
    {
        list<FDIC_NCUA_Data__c>lupdate = new list<FDIC_NCUA_Data__c>();
        for(sobject obj: lrec)
        {
            FDIC_NCUA_Data__c rec= (FDIC_NCUA_Data__c)obj;
            lupdate.add(rec);
        }
        FDIC.findAccountBefore(lupdate); // trying to find appropriate Account record for these FDIC records
        update lupdate;
    }
    
 
    global void finish(Database.BatchableContext bc)
    {
        //putting dml here causes attempt to de-reference null object
    }
    /*
     * method executes the scheduled job of FDIC_Batch class instance
     */    
    global void execute(SchedulableContext sc){
        database.executeBatch(new FDIC_Batch(),5000);
    } 
}