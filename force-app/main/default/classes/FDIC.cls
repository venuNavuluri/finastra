/*  @author Serhii Volynets sergey.volinets@weare4c.com
 * @Jira: RBX-381
 * This class implements business logics, including trigger methods and utility methods.
* main methods: 
beforeUpdateFDIC - populates FDIC field values, populates account__c value
updateFDIC - updates account record with most recent FDIC record lookup value
* TODO: rename FDIC class to FDIC.. Trigger.. , add high level overview: implement business logics, including trigger methods and utility classes, 
move details to specific method levels, put details of p
*/
public without sharing class FDIC
{
     /*
     * this method proceeds FDIC_NCUA_Data__c records before update or insert
     * if populates to  Commercial_Loans__c, 
     * 	Consumer_and_Commercial_Loans__c, 
     * Loans_and_Leases_minus_Family_Residentia__c, 
     * Loans_and_Leases_minus_Family_Residentia__c fields based on lnrecons__c, lnrenres__c,lnremult__c,lnci__c field values
     * also it populates account__c field for those records which have account__c empty or Certificate__c or Data_Source__c changed
 	 * @Jira: RBX-381
     * @param lFDIC -  corresponds to Trigger.new return
     * @param mOld - corresponds to Trigger.oldMap return or null for insert
     * @return void
     */ 
    
    public static void beforeUpdateFDIC(list<FDIC_NCUA_Data__c> lFDIC,map<id,FDIC_NCUA_Data__c> mOld)
    {
        list<FDIC_NCUA_Data__c> lFDICAcc = new list<FDIC_NCUA_Data__c> (); 
        for(FDIC_NCUA_Data__c rec: lFDIC)
        {        
            FDIC_NCUA_Data__c oldRec = null;
            if(mOld != null)
                oldrec= mOld.get(rec.id);  
            //if fields for Commercial_Loans__c are changed
            if(isChanged(rec,'lnrecons__c',oldRec) ||
               isChanged(rec,'lnrenres__c',oldRec) ||
               isChanged(rec,'lnremult__c',oldRec) ||
               isChanged(rec,'lnci__c',oldRec)
              )
            { // then populate Commercial_Loans__c
                rec.Commercial_Loans__c = 
                    MathUtils.NVL(rec.lnrecons__c)+
                    MathUtils.NVL(rec.lnrenres__c)+
                    MathUtils.NVL(rec.lnremult__c)+
                    MathUtils.NVL(rec.lnci__c);
            }
            // if fields for Consumer_and_Commercial_Loans__c are changed
            if(isChanged(rec,'lnlsnet__c',oldRec) ||
               isChanged(rec,'lnrersfm__c',oldRec)
              )
            {
                // then  populate Consumer_and_Commercial_Loans__c
                rec.Consumer_and_Commercial_Loans__c = 
                    MathUtils.NVL(rec.lnlsnet__c)-
                    MathUtils.NVL(rec.lnrersfm__c);
            }
              // if fields for Loans_and_Leases_minus_Family_Residentia__c are changed          
            if(isChanged(rec,'lnlsnet__c',oldRec) ||
               isChanged(rec,'lnreres__c',oldRec)
              )
            {
                // then  populate Consumer_and_Commercial_Loans__c                
                rec.Loans_and_Leases_minus_Family_Residentia__c = 
                    MathUtils.NVL(rec.lnlsnet__c)-
                    MathUtils.NVL(rec.lnreres__c);
            }           
            
            if(isChanged(rec,'Certificate__c', oldRec) || isChanged(rec,'Data_Source__c', oldRec) || rec.Account__c == null )
            {
                lFDICAcc.add(rec);
            }
        }
        if(!lFDICAcc.isEmpty())
        {
            findAccountBefore(lFDICAcc); // if it is an before update, then we can update related account's primary FDIC, if it is before insert - then can not
        }
    }
    
     /*
     * this method proceeds FDIC_NCUA_Data__c records after update or insert, updates account.FDIC_NCUA_Data__c field value with the most recent record
 	 * @Jira: RBX-381
     * @param lFDIC -  corresponds to Trigger.new return
     * @param mOld - corresponds to Trigger.oldMap return or null for insert
     * @return void
     */     
    public static void updateFDIC(list<FDIC_NCUA_Data__c> lFDIC,map<id,FDIC_NCUA_Data__c> mOld)
    {
        map<id,account>mAcc = new map<id,account>();
        map<id,FDIC_NCUA_Data__c> mFDIC = new map<id,FDIC_NCUA_Data__c>();
        // collect FDIC records and account__c field values which have account__c field value changed
        for(FDIC_NCUA_Data__c rec: lFDIC)
        {
            FDIC_NCUA_Data__c oldRec = null;
            if(mOld != null)
                oldrec= mOld.get(rec.id);
            if(/*rec.Account__c != null && */isChanged(rec,'Account__c',oldRec))
                mAcc.put(rec.Account__c, null);
        }
        
        if(!mAcc.isEmpty())
        {
            //query for accounts which correspond to FDIC records with changed account__c field value
            list<account>lacc = [select id, FDIC_NCUA_Data__c from account where id in :mAcc.keySet()];
            for(account acc: lacc)
            {
                macc.put(acc.id, acc);
            }
            
            //query for all FDIC records which correspond to account id's we've collected
            list<FDIC_NCUA_Data__c>lFDICAll = [select id, account__c, Report_Date__c, Quarter__c, Year__c from FDIC_NCUA_Data__c where account__c in :mAcc.keySet()];
            for(FDIC_NCUA_Data__c rec : lFDICAll)
            {
                FDIC_NCUA_Data__c old = mFDIC.get(rec.account__c);
                // determine the most recent FDIC record for each of accounts
                if(old == null || 
                   (old.Year__c<rec.Year__c) ||
                   (old.Year__c==rec.Year__c && old.Quarter__c <rec.Quarter__c) ||
                   (old.Year__c==rec.Year__c && old.Quarter__c == rec.Quarter__c && old.Report_Date__c < rec.Report_Date__c)
                  )
                {
                    mFDIC.put(rec.account__c, rec);
                }
            }
            
            list<account>lupdate = new list<account>();
            //iterate on account records array
            for(id accId: mAcc.keySet())
            {
                account acc = mAcc.get(accId);
                if(acc == null)
                    continue;
                FDIC_NCUA_Data__c rec = mFDIC.get(acc.id);
                //if account's FDIC_NCUA_Data__c field value was changed, we have to update it
                if(rec != null && rec.Id != acc.FDIC_NCUA_Data__c)
                {
                    lupdate.add(new account(id = acc.id, FDIC_NCUA_Data__c = rec.id));
                }
            }
            // if there are accounts to update
            if(!lupdate.isEmpty())
                update lupdate;
                
        }
    }

     /*
     * this method populates Account__c field for  FDIC_NCUA_Data__c 
 	 * @Jira: RBX-381
     * @param lFDIC - list of FDIC_NCUA_Data__c records
     * @return - list of FDIC_NCUA_Data__c records
     */    
    public static list<FDIC_NCUA_Data__c> findAccountBefore(list<FDIC_NCUA_Data__c>lSFIC)
    {
        list<FDIC_NCUA_Data__c> ret = new list<FDIC_NCUA_Data__c>();
        set<string> sFDIC= new set<string>();
        for(FDIC_NCUA_Data__c rec: lSFIC)
        {
            sFDIC.add(rec.Certificate__c);  // find all certificate field values for accounts search      
        }
        map<string,account>mAccUpdate = new  map<string,account>();
        map<string,account>macc = new map<string,account>();
        map<string,account>macc2 = new map<string,account>();    
        //searching for accounts with given certificate id
        list<account>lAcc = 
            [
                select id, DH_MSCRM_Hfs_fdic_num__c, 
                FDIC_NCUA_Data__c,
                FDIC_NCUA_Data__r.Year__c,
                FDIC_NCUA_Data__r.Quarter__c, 
                FDIC_NCUA_Data__r.Report_Date__c  ,
                DH_MSCRM_Hfs_charter_num__c 
                from account 
                where DH_MSCRM_Hfs_fdic_num__c in :sFDIC
                OR DH_MSCRM_Hfs_charter_num__c in :sFDIC
            ];
        // put them into map for futher fast access
        for(account acc :lacc)
        {
            macc.put(acc.DH_MSCRM_Hfs_fdic_num__c,acc);
            macc2.put(acc.DH_MSCRM_Hfs_charter_num__c, acc);
        }

        system.debug('FDIC matching accounts');
        system.debug(macc);
        // iterate on FDIC records and populate account__c lookup for them
        for(FDIC_NCUA_Data__c rec: lSFIC)
        {
            account acc = null;
            if(rec.Data_Source__c == 'FDIC') //based on FDIC data source, matching with different account field name (DH_MSCRM_Hfs_fdic_num__c or DH_MSCRM_Hfs_charter_num__c)
                acc = macc.get(rec.Certificate__c);
            else if(rec.Data_Source__c == 'NCUA')
                acc = macc2.get(rec.Certificate__c);
            if(acc != null)
            {
                if(rec.Account__c != acc.id)
                {
                    rec.Account__c = acc.id;
                    ret.add(rec);                   
                }
            }
        }
        return ret;
    }
    
    /*
     * this method determines if specific field was changed in record
 	 * @Jira: RBX-381
     * @param rec - the record after the change
     * @param sFieldName - field name
     * @param oldRec - the record before the change
     * @return - true - if the field value was changed
     */
    public static boolean isChanged(sobject rec,string sFieldName, sobject oldRec)
    {
        if(oldRec == null)
            return rec.get(sFieldName) == null;
        return rec.get(sFieldName) != oldRec.get(sFieldName);
    }
}