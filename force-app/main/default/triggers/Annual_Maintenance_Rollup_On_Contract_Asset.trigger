// AM - Existing Trigger on Contract Asset looks obsolete and its doing rollup on old field - I have created this new trigger and and we may delete the existing one later

/* 
- This trigger will insert / update the Annual Maintenance History record based on releavant CA field updates
- Please note that for the existing contract assets a one time Maitenance Sweep job called baseLineAnnualMaintenanceData will insert the record
- Afterward these record will be updated for existing contract assets
- and for new contract assets we will insert new records
- Subssequently the trigger called Billing_Group_Annual_Maintenance_RollUp will do the rollups on BG
*/
trigger Annual_Maintenance_Rollup_On_Contract_Asset on Contract_Asset__c (after insert, before update, before delete) {

if( Label.Disable_Annual_Maintenance_History_Trigger!= 'Disable'){
//Set<ID> bgID = new Set<ID>();

/*
 //pick current financial year - create utility function once confirmed..
    Integer year= System.Today().year();
    Integer month = System.Today().month();
    
    if(month >=6 && month < = 12)
    year = year + 1;
    
    String currentYear = String.valueof(year);
    */
    String currentYear = Label.Current_Billing_Year_for_Annual_Maintenance_History;
    
 //currentYear
    
    List<NS_Annual_Maintenance_History__c> aMHList = new   List<NS_Annual_Maintenance_History__c>();
    
  if(!Trigger.isDelete)
             aMHList =  [select Contract_Asset__c,Annual_Maintenance__c, Billing_Group__c,CurrencyIsoCode,CA_Billing_Status__c from NS_Annual_Maintenance_History__c where Contract_Asset__c in :Trigger.new and Calendar_Year__c = :currentYear ];
  
  // if the history record does not exist
  if(aMHList.size() == 0 && !Trigger.isDelete)
    {
            NS_Annual_Maintenance_History__c aMH;
            List<NS_Annual_Maintenance_History__c> aMHInsertList = new List<NS_Annual_Maintenance_History__c>();
            
            for(Contract_asset__c ca :Trigger.new)
            {
                aMH = new NS_Annual_Maintenance_History__c();
                aMH.Calendar_Year__c  = currentYear;
                aMH.Contract_Asset__c = ca.id;
                aMH.Billing_Group__c = ca.CA_Billing_Group__c;
                aMH.Annual_Maintenance__c = ca.Annual_Maintenance__c;
                if(aMH.Annual_Maintenance__c == null)
                   aMH.Annual_Maintenance__c = 0;
            
                aMH.CA_Billing_Status__c = ca.CA_Billing_Status__c;
                aMH.currencyisocode = ca.currencyisocode;
                aMHInsertList.add(aMH);
            }
            if(aMHInsertList.size()>0)
            insert aMHInsertList;   
    }
else if(trigger.isUpdate)
{

    // update AMH for the current financial year
   // List<NS_Annual_Maintenance_History__c> aMHList = [select Contract_Asset__c,Annual_Maintenance__c, Billing_Group__c from NS_Annual_Maintenance_History__c where Contract_Asset__c in :Trigger.new and Calendar_Year__c = :currentYear ];
     
    Map<id,NS_Annual_Maintenance_History__c> aMHUpdateMap = new  Map<id, NS_Annual_Maintenance_History__c>();
      
    for (NS_Annual_Maintenance_History__c aMH :aMHList)
        {
           // if(Trigger.newMap.get(aMH.Contract_Asset__c).Annual_Maintenance__c!=null){
                if( aMH.Annual_Maintenance__c!=Trigger.newMap.get(aMH.Contract_Asset__c).Annual_Maintenance__c)
                {  //assumption here is that the record already exists
                   aMH.Annual_Maintenance__c  = Trigger.newMap.get(aMH.Contract_Asset__c).Annual_Maintenance__c;
                   if(aMH.Annual_Maintenance__c == null)
                   aMH.Annual_Maintenance__c = 0;
              
                   aMHUpdateMap.put(aMH.id , aMH);
                }
                if(aMH.Billing_Group__c!=Trigger.newMap.get(aMH.Contract_Asset__c).CA_Billing_Group__c)
                {
                    aMH.Billing_Group__c  = Trigger.newMap.get(aMH.Contract_Asset__c).CA_Billing_Group__c;
                    aMHUpdateMap.put(aMH.id , aMH);
                }
                
                 if(aMH.CA_Billing_Status__c!=Trigger.newMap.get(aMH.Contract_Asset__c).CA_Billing_Status__c)
                {
                    aMH.CA_Billing_Status__c  = Trigger.newMap.get(aMH.Contract_Asset__c).CA_Billing_Status__c;
                    aMHUpdateMap.put(aMH.id , aMH);
                }
                
                if(aMH.currencyisocode!=Trigger.newMap.get(aMH.Contract_Asset__c).currencyisocode)
                {
                    aMH.currencyisocode= Trigger.newMap.get(aMH.Contract_Asset__c).currencyisocode;
                    aMHUpdateMap.put(aMH.id , aMH);
                }
                
                
          //  }
            
        }
        
    if(aMHUpdateMap.size()>0)
    update aMHUpdateMap.values();
    
 /*   // If the billing group has changed then pick the old id to update the rollUps
    for(Contract_Asset__c ca: Trigger.new)
    {
        if(Trigger.oldMap.get(ca.Id).CA_Billing_Group__c!=Trigger.newMap.get(ca.Id).CA_Billing_Group__c)
            bgID.add(Trigger.oldMap.get(ca.Id).CA_Billing_Group__c);
           
    }
 */   
}

// delete the corresponding AMH records so that they dont affect the BG AM rollup figure
if(Trigger.isDelete)
{
    
    List<NS_Annual_Maintenance_History__c> aMHDeleteList = [select id from NS_Annual_Maintenance_History__c where Contract_Asset__c in :Trigger.old]; 
    if(aMHDeleteList.size()>0)
    delete aMHDeleteList;
}

 /*AggregateResult[] groupedResultLIs = [select Billing_Group__c bgID ,Calendar_Year__c Year ,sum(Annual_Maintenance__c) total from  NS_Annual_Maintenance_History__c  where Billing_Group__c in : bgID and CA_Billing_Status__c='Active billing'  group by Calendar_Year__c ,Billing_Group__c]; 
     Map<id,BG_Annual_Maintenance_Summary__c> bgAMSMap= new Map<id,BG_Annual_Maintenance_Summary__c> ();
     List<BG_Annual_Maintenance_Summary__c> bgAMSList = ([Select Billing_Group__c, BG_Annual_Maintenance_Total__c, Calendar_Year__c from BG_Annual_Maintenance_Summary__c where Billing_Group__c in : bgID ]);
       
     //populate MS map
     for(BG_Annual_Maintenance_Summary__c bgAMS :bgAMSList)
           bgAMSMap.put(bgAMS.Billing_Group__c,bgAMS);
        
         for(AggregateResult ar : groupedResultLIs) 
        {
            if( bgAMSMap.get((ID)ar.get('bgID'))!=null)
            {
                 bgAMSMap.get((ID)ar.get('bgID')).Calendar_Year__c = (String)ar.get('year');
                 bgAMSMap.get((ID)ar.get('bgID')).BG_Annual_Maintenance_Total__c = (Double)ar.get('total');
                 
               //  bgAMSUpdateList.add(bgAMSMap.get((ID)ar.get('bgID')));
            }       
        }
        update bgAMSMap.values();
*/
}

}
/*
Queries 
1. I am assuming we are considering finanical yar from June to May so Nov 2016 is considered as 2017 - generic variable
2. What if the billing group is not assigned - it will not roll up
3. will we only touch current year?
*/