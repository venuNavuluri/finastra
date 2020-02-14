trigger beforeInsert on Task (before Insert,before Update) 

   {

   
     for (Task tt : Trigger.new)
    {
        if(tt.Status!='Completed')
        { 
          tt.Task_Score__c=NULL;
          }
          else
         
           if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Introductory Call / GTM' && tt.Status=='Completed')
          
          { tt.Task_Score__c=0.012;
            /*System.debug('RamRam'+tt.Task_Score__c);*/
            }
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Lead / MQL follow up' && tt.Status=='Completed')
            tt.Task_Score__c=0.012;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Opportunity Progression' && tt.Status=='Completed')
            tt.Task_Score__c=0.012;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Demo or Presentation' && tt.Status=='Completed')  
            tt.Task_Score__c=0.012;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Negotiation / Opportunity Close' && tt.Status=='Completed')
            tt.Task_Score__c=0.012;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Relationship (SAG, NPS)' && tt.Status=='Completed')
            tt.Task_Score__c=0.012;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Support issue / CS related' && tt.Status=='Completed')  
            tt.Task_Score__c=0.012;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Project / PS related' && tt.Status=='Completed')
            tt.Task_Score__c=0.012;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Collections / Maintenance Sweep' && tt.Status=='Completed')
            tt.Task_Score__c=0.012;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Misys Connect Nomination / Presentation follow up' && tt.Status=='Completed')  
            tt.Task_Score__c=0.012;
/* Sales Exec CC-C completed and Sales Player/Manager CC-C starting*/
else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Introductory Call / GTM' && tt.Status=='Completed')  
            tt.Task_Score__c=0.02;

else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Lead / MQL follow up' && tt.Status=='Completed')
            tt.Task_Score__c=0.02;
 else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Opportunity Progression' && tt.Status=='Completed')
            tt.Task_Score__c=0.02;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Demo or Presentation' && tt.Status=='Completed')  
            tt.Task_Score__c=0.02;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Negotiation / Opportunity Close' && tt.Status=='Completed')
            tt.Task_Score__c=0.02;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Relationship (SAG, NPS)' && tt.Status=='Completed')
            tt.Task_Score__c=0.02;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Support issue / CS related' && tt.Status=='Completed')  
            tt.Task_Score__c=0.02;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Project / PS related' && tt.Status=='Completed')
            tt.Task_Score__c=0.02;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Collections / Maintenance Sweep' && tt.Status=='Completed')
            tt.Task_Score__c=0.02;
            
else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Misys Connect Nomination / Presentation follow up' && tt.Status=='Completed')  
            tt.Task_Score__c=0.02;


/* Sales Player/Manager CC-C completed and GSS Sales CC-C starting*/
else if(tt.Sales_Role__c=='GSS Sales' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Introductory Call / GTM' && tt.Status=='Completed')  
            tt.Task_Score__c=0.0334;

else if(tt.Sales_Role__c=='GSS Sales' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Lead / MQL follow up' && tt.Status=='Completed')
            tt.Task_Score__c=0.0334;
 else if(tt.Sales_Role__c=='GSS Sales' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Opportunity Progression' && tt.Status=='Completed')
            tt.Task_Score__c=0.0334;
   
 else if(tt.Sales_Role__c=='GSS Sales' && tt.Sales_Activity_Type__c=='Client Communications - Call' && tt.Activity_Type__c=='Demo or Presentation' && tt.Status=='Completed')  
            tt.Task_Score__c=0.0334;
            




/* GSS Sales CC-C completed and Sales Exec CC-M starting*/


            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Introductory Call / GTM' && tt.Status=='Completed')  
            tt.Task_Score__c=0.045;         
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Lead / MQL follow up' && tt.Status=='Completed')
            tt.Task_Score__c=0.045;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Opportunity Progression' && tt.Status=='Completed')
            tt.Task_Score__c=0.045;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Demo or Presentation' && tt.Status=='Completed')  
            tt.Task_Score__c=0.045;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Negotiation / Opportunity Close' && tt.Status=='Completed')
            tt.Task_Score__c=0.045;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Relationship (SAG, NPS)' && tt.Status=='Completed')
            tt.Task_Score__c=0.045;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Support issue / CS related' && tt.Status=='Completed')  
            tt.Task_Score__c=0.045;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Project / PS related' && tt.Status=='Completed')
            tt.Task_Score__c=0.045;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Collections / Maintenance Sweep' && tt.Status=='Completed')
            tt.Task_Score__c=0.045;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Misys Connect Nomination / Presentation follow up' && tt.Status=='Completed')  
            tt.Task_Score__c=0.045;
 
  /* Sales Exec CC-M completed and Sales Player/Manager CC-M starting*/
else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Introductory Call / GTM' && tt.Status=='Completed')  
            tt.Task_Score__c=0.09;         
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Lead / MQL follow up' && tt.Status=='Completed')
            tt.Task_Score__c=0.09;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Opportunity Progression' && tt.Status=='Completed')
            tt.Task_Score__c=0.09;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Demo or Presentation' && tt.Status=='Completed')  
            tt.Task_Score__c=0.09;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Negotiation / Opportunity Close' && tt.Status=='Completed')
            tt.Task_Score__c=0.09;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Relationship (SAG, NPS)' && tt.Status=='Completed')
            tt.Task_Score__c=0.09;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Support issue / CS related' && tt.Status=='Completed')  
            tt.Task_Score__c=0.09;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Project / PS related' && tt.Status=='Completed')
            tt.Task_Score__c=0.09;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Collections / Maintenance Sweep' && tt.Status=='Completed')
            tt.Task_Score__c=0.09;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Misys Connect Nomination / Presentation follow up' && tt.Status=='Completed')  
            tt.Task_Score__c=0.09;


/* Sales Player/Manager CC-M completed and GSS Sales CC-M starting*/
else if(tt.Sales_Role__c=='GSS Sales' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Introductory Call / GTM' && tt.Status=='Completed')  
            tt.Task_Score__c=0.1;         
 else if(tt.Sales_Role__c=='GSS Sales' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Lead / MQL follow up' && tt.Status=='Completed')
            tt.Task_Score__c=0.1;
 else if(tt.Sales_Role__c=='GSS Sales' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Opportunity Progression' && tt.Status=='Completed')
            tt.Task_Score__c=0.1;
 else if(tt.Sales_Role__c=='GSS Sales' && tt.Sales_Activity_Type__c=='Client Communications - Meeting' && tt.Activity_Type__c=='Demo or Presentation' && tt.Status=='Completed')  
            tt.Task_Score__c=0.1;



/* GSS Sales CC-M completed and Sales Exec Internal starting*/
         
            
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Internal' && tt.Activity_Type__c=='Partner Development' && tt.Status=='Completed')
            tt.Task_Score__c=0.075;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Internal' && tt.Activity_Type__c=='Sales Training' && tt.Status=='Completed')  
            tt.Task_Score__c=0.15;
            else if(tt.Sales_Role__c=='Sales Exec' && tt.Sales_Activity_Type__c=='Internal' && tt.Activity_Type__c=='Marketing Event' && tt.Status=='Completed')  
            tt.Task_Score__c=0.15;

  /* Sales Exec Internal completed and Sales Player/Manager Internal starting*/
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Internal' && tt.Activity_Type__c=='Partner Development' && tt.Status=='Completed')
            tt.Task_Score__c=0.075;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Internal' && tt.Activity_Type__c=='Sales Training' && tt.Status=='Completed')  
            tt.Task_Score__c=0.15;
            else if(tt.Sales_Role__c=='Sales Player/Manager' && tt.Sales_Activity_Type__c=='Internal' && tt.Activity_Type__c=='Marketing Event' && tt.Status=='Completed')  
            tt.Task_Score__c=0.15;


/* Sales Player/Manager Internal completed and Inside Sales All Activities Starting*/

else if(tt.Sales_Role__c=='Inside Sales / Sales Graduate' && tt.Sales_Activity_Type__c=='Inside Sales' && tt.Activity_Type__c=='Call Meaningful Conversation' && tt.Status=='Completed')  
            tt.Task_Score__c=0.0125;         
 else if(tt.Sales_Role__c=='Inside Sales / Sales Graduate' && tt.Sales_Activity_Type__c=='Inside Sales' && tt.Activity_Type__c=='Meetings Booked Against Campaign' && tt.Status=='Completed')
            tt.Task_Score__c=0.125;
 else if(tt.Sales_Role__c=='Inside Sales / Sales Graduate' && tt.Sales_Activity_Type__c=='Inside Sales' && tt.Activity_Type__c=='Event Attendance' && tt.Status=='Completed')
            tt.Task_Score__c=0.005;
 else if(tt.Sales_Role__c=='Inside Sales / Sales Graduate' && tt.Sales_Activity_Type__c=='Inside Sales' && tt.Activity_Type__c=='MQLs Progressed' && tt.Status=='Completed')  
            tt.Task_Score__c=0.033;



   
    }

   }