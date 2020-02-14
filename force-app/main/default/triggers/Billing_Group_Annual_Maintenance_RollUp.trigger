/* 
- This trigger will insert / update the Billing_Group_Annual_Maintenance_RollUp record when ever the NS_Annual_Maintenance_History__c is add or updated
- Please note that for the existing contract assets a one time Maitenance Sweep job called initalAMRollUpForBillingGroup will insert these record
*/

trigger Billing_Group_Annual_Maintenance_RollUp on NS_Annual_Maintenance_History__c (after insert, after update, after delete) {

if(Label.Disable_Billing_Group_Roll_Up_Trigger !='Disable'){
     Set<ID> bgID = new Set<ID>();
    
    if(Trigger.isAfter && Trigger.isInsert)
    for (NS_Annual_Maintenance_History__c aMH :Trigger.new)
    {
        If(aMH.Billing_Group__c!=null)
        bgID.add(aMH.Billing_Group__c);
    }
    else  if(Trigger.isAfter && Trigger.isUpdate)
    {
         for (NS_Annual_Maintenance_History__c aMH :Trigger.new)
         {
            If(aMH.Billing_Group__c!=null)
              bgID.add(aMH.Billing_Group__c);
         }
         for (NS_Annual_Maintenance_History__c aMH :Trigger.old)
         {
            If(aMH.Billing_Group__c!=null)
              bgID.add(aMH.Billing_Group__c);
         }
    }
    else
    for (NS_Annual_Maintenance_History__c aMH :Trigger.old)
    {
        If(aMH.Billing_Group__c!=null)
        bgID.add(aMH.Billing_Group__c);
    }
    
    if(bgID.size()>0){
        AggregateResult[] groupedResultLIs = [select Billing_Group__c bgID ,Calendar_Year__c Year ,sum(Annual_Maintenance__c) total from  NS_Annual_Maintenance_History__c  where Billing_Group__c in : bgID and CA_Billing_Status__c!='Inactive billing'  group by Calendar_Year__c ,Billing_Group__c]; 
         Map<String,BG_Annual_Maintenance_Summary__c> bgAMSMap= new Map<String,BG_Annual_Maintenance_Summary__c> ();
         List<BG_Annual_Maintenance_Summary__c> bgAMSList = ([Select Billing_Group__c, AMH_Currency_Code__c,BG_Annual_Maintenance_Total__c, Calendar_Year__c from BG_Annual_Maintenance_Summary__c where Billing_Group__c in : bgID ]);
         
         Map<Id,Billing_Group__c> bgMap = new Map<Id,Billing_Group__c>([select id,currencyIsoCode, CY_Billing_Current_Amount__c,BG_Calendar_Year_Billing_Current_Temp__c, AM_Roll_Up_Flag__c,BG_Misys_Billing_Entity__c from Billing_Group__c where id = :bgID]);
         
         
         List<BG_Annual_Maintenance_Summary__c> bgAMSUpdateList = new  List<BG_Annual_Maintenance_Summary__c>();
         List<BG_Annual_Maintenance_Summary__c> bgAMSUpdateInsert = new  List<BG_Annual_Maintenance_Summary__c>();
            
        Map<string,double> currencyCodeMap = new Map<string,double>();
        List<currencytype > currencyCodeList = [SELECT isocode,conversionrate  FROM currencytype ];
        
        for(currencytype cc: currencyCodeList)
        {
            currencyCodeMap.put(cc.isocode,cc.conversionrate);
        }
        
         //populate MS map
         for(BG_Annual_Maintenance_Summary__c bgAMS :bgAMSList)
         {
               bgAMSMap.put(bgAMS.Billing_Group__c + bgAMS.Calendar_Year__c,bgAMS);
                 //may be reset billing group before insert
                 bgAMS.BG_Annual_Maintenance_Total__c = 0;
                 bgAMS.BG_Annual_Maintenance_Total_Converted__c = 0;
               }
             if(bgAMSList.size()>0)  
             update bgAMSList;
            
             for(AggregateResult ar : groupedResultLIs) 
            {
                if( bgAMSMap.get((ID)ar.get('bgID')+(String)ar.get('year'))!=null)
                {
                BG_Annual_Maintenance_Summary__c  bgAMS= bgAMSMap.get((ID)ar.get('bgID')+(String)ar.get('year'));
                    // bgAMSMap.get((ID)ar.get('bgID')).Calendar_Year__c = (String)ar.get('year');
                   //  bgAMSMap.get((ID)ar.get('bgID')+(String)ar.get('year')).BG_Annual_Maintenance_Total__c = (Double)ar.get('total');
                   //  bgAMSMap.get((ID)ar.get('bgID')+(String)ar.get('year')).BG_Annual_Maintenance_Total_Converted__c =  currencyCodeMap.get( bgAMSMap.get((ID)ar.get('bgID')+(String)ar.get('year')).AMH_Currency_Code__c)  bgAMSMap.get((ID)ar.get('bgID')+(String)ar.get('year')).BG_Annual_Maintenance_Total__c;
                    
                    /*****
                    Change Currency iso Code here - as required*/
                //    bgAMS.currencyisocode = (String)ar.get('currencyisocode'); //UserInfo.getDefaultCurrency();
                    bgAMS.BG_Annual_Maintenance_Total__c = (Double)ar.get('total');
                    bgAMS.AMH_Currency_Code__c = bgMap.get(bgAMS.Billing_Group__c).currencyIsoCode;
                    if(bgAMS.AMH_Currency_Code__c!=null)
                    {
                     Double bgAMSTotalAmount = 0;
                    	 if (bgAMS.BG_Annual_Maintenance_Total__c!=null)
                    	 bgAMSTotalAmount = bgAMS.BG_Annual_Maintenance_Total__c;
                    	 
                     bgAMS.BG_Annual_Maintenance_Total_Converted__c =  currencyCodeMap.get( bgAMS.AMH_Currency_Code__c) * bgAMSTotalAmount /*bgAMS.BG_Annual_Maintenance_Total__c*/;
                     //check and confirm
                      bgMap.get(bgAMS.Billing_Group__c).BG_Calendar_Year_Billing_Current_Temp__c = bgAMS.BG_Annual_Maintenance_Total_Converted__c;
                    }
                     //bgAMSUpdateList.add(bgAMSMap.get((ID)ar.get('bgID')+(String)ar.get('year')));
                     bgAMSUpdateList.add(bgAMS);
                      
                 
                } 
                else // the BG AM record does not exist
                {
                               /*****
                    Change Currency iso Code here - as required*/
                BG_Annual_Maintenance_Summary__c bgAMS= new  BG_Annual_Maintenance_Summary__c();
                bgAMS.BG_Annual_Maintenance_Total__c = (Double)ar.get('total');
                if(bgAMS.BG_Annual_Maintenance_Total__c==null) bgAMS.BG_Annual_Maintenance_Total__c = 0;
                bgAMS.Calendar_Year__c = (String)ar.get('year');
                bgAMS.Billing_Group__c = (ID)ar.get('bgID');
                if(bgMap.get(bgAMS.Billing_Group__c)!=null)
                bgAMS.AMH_Currency_Code__c = bgMap.get(bgAMS.Billing_Group__c).currencyIsoCode;
               
                if(bgAMS.AMH_Currency_Code__c!=null && bgAMS.AMH_Currency_Code__c!='')
                    {
                    	 Double bgAMSTotalAmount = 0;
                    	 if (bgAMS.BG_Annual_Maintenance_Total__c!=null)
                    	 bgAMSTotalAmount = bgAMS.BG_Annual_Maintenance_Total__c;
                    	 
                     bgAMS.BG_Annual_Maintenance_Total_Converted__c =   currencyCodeMap.get( bgAMS.AMH_Currency_Code__c) * bgAMSTotalAmount /*bgAMS.BG_Annual_Maintenance_Total__c*/;
                      //check and confirm
                      bgMap.get(bgAMS.Billing_Group__c).BG_Calendar_Year_Billing_Current_Temp__c = bgAMS.BG_Annual_Maintenance_Total_Converted__c;
                    }
              //  bgAMS.AMH_Currency_Code__c= (ID)ar.get('bgID');
                bgAMSUpdateInsert.add(bgAMS);
                }      
            }   
  
       
       if(bgAMSUpdateList.size() > 0)
       update bgAMSUpdateList;
       
       if(bgAMSUpdateInsert.size()>0)
       insert bgAMSUpdateInsert;
       
       if(bgMap.values().size()>0)
       update bgMap.values();
    }
   
}

}