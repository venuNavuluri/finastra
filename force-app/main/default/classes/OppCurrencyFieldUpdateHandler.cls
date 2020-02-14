public class OppCurrencyFieldUpdateHandler
{
    public void onBeforeInsert(List<Opportunity> oppListInsert)
    {
        for(Opportunity oppInsert : oppListInsert)
        {
            oppInsert.ILF_Equiv_SUB__c = getValue(oppInsert.SUB_Amount__c) * 2.5;
            oppInsert.ILF_Equiv_CLD__c = getValue(oppInsert.CLD_Amount__c) * 2.5;
            oppInsert.ILF_Equiv_HOS__c = getValue(oppInsert.HOS_Amount__c) * 2.5;
            
            if(getValue(oppInsert.Booking_Adjustment_percent__c) == 0 || getValue(oppInsert.Booking_Adjustment_percent__c) == null)
            	oppInsert.ILF_Equiv_CSH__c = getValue(oppInsert.ILF_Equiv_SUB__c) + getValue(oppInsert.ILF_Equiv_CLD__c) + getValue(oppInsert.ILF_Equiv_HOS__c);
            
            else	
            	oppInsert.ILF_Equiv_CSH__c = getValue(oppInsert.Booking_Adjustment_percent__c / 100) * (getValue(oppInsert.ILF_Equiv_SUB__c) + getValue(oppInsert.ILF_Equiv_CLD__c) + getValue(oppInsert.ILF_Equiv_HOS__c));

            oppInsert.ILF_ILF_Equiv_CSH__c = getValue(oppInsert.Total_ILF_In_Qtr__c) + getValue(oppInsert.ILF_Equiv_CSH__c);
            oppInsert.CLD_CB_ILF_Equiv__c = getValue(oppInsert.RSF_CLD_CB_TP__c) * 2.5;
            oppInsert.CLD_CL_ILF_Equiv__c = getValue(oppInsert.RSF_CLD_CL_TP__c) * 2.5;
            oppInsert.CLD_ER_ILF_Equiv__c = getValue(oppInsert.RSF_CLD_ER_TP__c) * 2.5;
            oppInsert.CLD_CM_ILF_Equiv__c = getValue(oppInsert.RSF_CLD_CM_TP__c) * 2.5;
            oppInsert.CLD_TB_ILF_Equiv__c = getValue(oppInsert.RSF_CLD_TB_TP__c) * 2.5;
            oppInsert.CLD_IM_ILF_Equiv__c = getValue(oppInsert.RSF_CLD_IM_TP__c) * 2.5;


            oppInsert.SUB_CB_ILF_Equiv__c = getValue(oppInsert.RSF_SUB_CB_TP__c) * 2.5;
            oppInsert.SUB_CL_ILF_Equiv__c = getValue(oppInsert.RSF_SUB_CL_TP__c) * 2.5;
            oppInsert.SUB_ER_ILF_Equiv__c = getValue(oppInsert.RSF_SUB_ER_TP__c) * 2.5;
            oppInsert.SUB_CM_ILF_Equiv__c = getValue(oppInsert.RSF_SUB_CM_TP__c) * 2.5;
            oppInsert.SUB_TB_ILF_Equiv__c = getValue(oppInsert.RSF_SUB_TB_TP__c) * 2.5;
            oppInsert.SUB_IM_ILF_Equiv__c = getValue(oppInsert.RSF_SUB_IM_TP__c) * 2.5;

            oppInsert.HOS_CB_ILF_Equiv__c = getValue(oppInsert.RSF_HOS_CB_TP__c) * 2.5;
            oppInsert.HOS_CL_ILF_Equiv__c = getValue(oppInsert.RSF_HOS_CL_TP__c) * 2.5;
            oppInsert.HOS_ER_ILF_Equiv__c = getValue(oppInsert.RSF_HOS_ER_TP__c) * 2.5;
            oppInsert.HOS_CM_ILF_Equiv__c = getValue(oppInsert.RSF_HOS_CM_TP__c) * 2.5;
            oppInsert.HOS_TB_ILF_Equiv__c = getValue(oppInsert.RSF_HOS_TB_TP__c) * 2.5;
            oppInsert.HOS_IM_ILF_Equiv__c = getValue(oppInsert.RSF_HOS_IM_TP__c) * 2.5;
			
			//PN 22/10/2018 - changing the calculations as per Robert ACV document
            /*oppInsert.CSH_CB_ILF_ILF_Equiv__c = getValue(oppInsert.In_QTR_ILF_CB_Revenue__c)
                    +((getValue(oppInsert.RSF_CLD_CB_TP__c)
                    + getValue(oppInsert.RSF_SUB_CB_TP__c)
                    + getValue(oppInsert.RSF_HOS_CB_TP__c))* 2.5);*/
                    
            oppInsert.CSH_CB_ILF_ILF_Equiv__c =   getValue(oppInsert.In_QTR_ILF_CB_Revenue__c) + (getValue(oppInsert.ACV_Booking_CB__c) * 2.5);   
			
			
           /* oppInsert.CSH_CL_ILF_ILF_Equiv__c  =  getValue(oppInsert.In_QTR_ILF_CL_Revenue__c)
                    + ((getValue(oppInsert.RSF_CLD_CL_TP__c)
                    + getValue(oppInsert.RSF_SUB_CL_TP__c)
                    + getValue(oppInsert.RSF_HOS_CL_TP__c))* 2.5);*/
                    
            oppInsert.CSH_CL_ILF_ILF_Equiv__c =   getValue(oppInsert.In_QTR_ILF_CL_Revenue__c) + (getValue(oppInsert.ACV_Booking_CL__c) * 2.5);        

           /* oppInsert.CSH_ER_ILF_ILF_Equiv__c  =  (oppInsert.In_QTR_ILF_ER_Revenue__c==null ? 0 : oppInsert.In_QTR_ILF_ER_Revenue__c)
                    + ((getValue(oppInsert.RSF_CLD_ER_TP__c)
                    + getValue(oppInsert.RSF_SUB_ER_TP__c)
                    + getValue(oppInsert.RSF_HOS_ER_TP__c)) * 2.5); */
                    
            oppInsert.CSH_ER_ILF_ILF_Equiv__c =   getValue(oppInsert.In_QTR_ILF_ER_Revenue__c) + (getValue(oppInsert.ACV_Booking_ER__c) * 2.5);            

           /* oppInsert.CSH_CM_ILF_ILF_Equiv__c= (oppInsert.In_QTR_ILF_CM_Revenue__c==null ? 0 : oppInsert.In_QTR_ILF_CM_Revenue__c)
                    +((getValue(oppInsert.RSF_CLD_CM_TP__c)
                    + getValue(oppInsert.RSF_SUB_CM_TP__c)
                    + getValue(oppInsert.RSF_HOS_CM_TP__c))* 2.5);*/
                    
            oppInsert.CSH_CM_ILF_ILF_Equiv__c =   getValue(oppInsert.In_QTR_ILF_CM_Revenue__c) + (getValue(oppInsert.ACV_Booking_CM__c) * 2.5);             

           /* oppInsert.CSH_TB_ILF_ILF_Equiv__c= (oppInsert.In_QTR_ILF_TB_Revenue__c==null ? 0 : oppInsert.In_QTR_ILF_TB_Revenue__c)
                    +((getValue(oppInsert.RSF_CLD_TB_TP__c)
                    + getValue(oppInsert.RSF_SUB_TB_TP__c)
                    + getValue(oppInsert.RSF_HOS_TB_TP__c))* 2.5);*/
                    
			oppInsert.CSH_TB_ILF_ILF_Equiv__c =   getValue(oppInsert.In_QTR_ILF_TB_Revenue__c) + (getValue(oppInsert.ACV_Booking_TB__c) * 2.5);      
            
           /* oppInsert.CSH_IM_ILF_ILF_Equiv__c= (oppInsert.In_QTR_ILF_IM_Revenue__c==null ? 0 : oppInsert.In_QTR_ILF_IM_Revenue__c)
                    +((getValue(oppInsert.RSF_CLD_IM_TP__c)
                    + getValue(oppInsert.RSF_SUB_IM_TP__c)
                    + getValue(oppInsert.RSF_HOS_IM_TP__c))* 2.5);*/
            
            oppInsert.CSH_IM_ILF_ILF_Equiv__c =   getValue(oppInsert.In_QTR_ILF_IM_Revenue__c) + (getValue(oppInsert.ACV_Booking_IM__c) * 2.5);           
                    
            //PN 22/10/2018 - changing the calculations as per Robert ACV document        
        }
    }

    private Decimal getValue(Decimal fieldValue){
        return (fieldValue == null ? 0 : fieldValue);
    }

    public void onBeforeUpdate(List<Opportunity> oppListUpdate,Map<Id,Opportunity> oldMap)
    {
        for(Opportunity oppUpdate : oppListUpdate)
        {
            if(oppUpdate.SUB_Amount__c!=oldMap.get(oppUpdate.Id).SUB_Amount__c)
                oppUpdate.ILF_Equiv_SUB__c = getValue(oppUpdate.SUB_Amount__c) * 2.5;

            if(oppUpdate.CLD_Amount__c!=oldMap.get(oppUpdate.Id).CLD_Amount__c)
                oppUpdate.ILF_Equiv_CLD__c = getValue(oppUpdate.CLD_Amount__c) * 2.5;

            if(oppUpdate.HOS_Amount__c!=oldMap.get(oppUpdate.Id).HOS_Amount__c)
                oppUpdate.ILF_Equiv_HOS__c = getValue(oppUpdate.HOS_Amount__c) * 2.5;

            if(oppUpdate.Booking_Adjustment_percent__c !=oldMap.get(oppUpdate.Id).Booking_Adjustment_percent__c  || oppUpdate.ILF_Equiv_SUB__c!=oldMap.get(oppUpdate.Id).ILF_Equiv_SUB__c || oppUpdate.ILF_Equiv_CLD__c!=oldMap.get(oppUpdate.Id).ILF_Equiv_CLD__c ||  oppUpdate.ILF_Equiv_HOS__c!=oldMap.get(oppUpdate.Id).ILF_Equiv_HOS__c ){
                
                if(oppUpdate.Booking_Adjustment_percent__c == 0 || oppUpdate.Booking_Adjustment_percent__c == null)
                	oppUpdate.ILF_Equiv_CSH__c = getValue(oppUpdate.ILF_Equiv_SUB__c) + getValue(oppUpdate.ILF_Equiv_CLD__c) + getValue(oppUpdate.ILF_Equiv_HOS__c);
                
                else
                	oppUpdate.ILF_Equiv_CSH__c = getValue(oppUpdate.Booking_Adjustment_percent__c / 100) * (getValue(oppUpdate.ILF_Equiv_SUB__c) + getValue(oppUpdate.ILF_Equiv_CLD__c) + getValue(oppUpdate.ILF_Equiv_HOS__c));
                		
            } 

            if(oppUpdate.ILF_Equiv_CSH__c !=null && oppUpdate.Total_ILF_In_Qtr__c!=oldMap.get(oppUpdate.Id).Total_ILF_In_Qtr__c|| oppUpdate.ILF_Equiv_CSH__c!=oldMap.get(oppUpdate.Id).ILF_Equiv_CSH__c )
                oppUpdate.ILF_ILF_Equiv_CSH__c = getValue(oppUpdate.Total_ILF_In_Qtr__c) + getValue(oppUpdate.ILF_Equiv_CSH__c);

            if(oppUpdate.RSF_CLD_CB_TP__c!=oldMap.get(oppUpdate.Id).RSF_CLD_CB_TP__c)
                oppUpdate.CLD_CB_ILF_Equiv__c = getValue(oppUpdate.RSF_CLD_CB_TP__c) * 2.5;

            if(oppUpdate.RSF_CLD_CL_TP__c!=oldMap.get(oppUpdate.Id).RSF_CLD_CL_TP__c)
                oppUpdate.CLD_CL_ILF_Equiv__c = getValue(oppUpdate.RSF_CLD_CL_TP__c) * 2.5;

            if(oppUpdate.RSF_CLD_ER_TP__c!=oldMap.get(oppUpdate.Id).RSF_CLD_ER_TP__c)
                oppUpdate.CLD_ER_ILF_Equiv__c = getValue(oppUpdate.RSF_CLD_ER_TP__c) * 2.5;

            if(oppUpdate.RSF_CLD_CM_TP__c!=oldMap.get(oppUpdate.Id).RSF_CLD_CM_TP__c)
                oppUpdate.CLD_CM_ILF_Equiv__c = getValue(oppUpdate.RSF_CLD_CM_TP__c) * 2.5;

            if(oppUpdate.RSF_CLD_TB_TP__c!=oldMap.get(oppUpdate.Id).RSF_CLD_TB_TP__c)
                oppUpdate.CLD_TB_ILF_Equiv__c = getValue(oppUpdate.RSF_CLD_TB_TP__c) * 2.5;

            if(oppUpdate.RSF_CLD_IM_TP__c!=oldMap.get(oppUpdate.Id).RSF_CLD_IM_TP__c)
                oppUpdate.CLD_IM_ILF_Equiv__c = getValue(oppUpdate.RSF_CLD_IM_TP__c) * 2.5;


            if(oppUpdate.RSF_SUB_CB_TP__c!=oldMap.get(oppUpdate.Id).RSF_SUB_CB_TP__c)
                oppUpdate.SUB_CB_ILF_Equiv__c = getValue(oppUpdate.RSF_SUB_CB_TP__c) * 2.5;

            if(oppUpdate.RSF_SUB_CL_TP__c!=oldMap.get(oppUpdate.Id).RSF_SUB_CL_TP__c)
                oppUpdate.SUB_CL_ILF_Equiv__c = getValue(oppUpdate.RSF_SUB_CL_TP__c) * 2.5;

            if(oppUpdate.RSF_SUB_ER_TP__c!=oldMap.get(oppUpdate.Id).RSF_SUB_ER_TP__c)
                oppUpdate.SUB_ER_ILF_Equiv__c = getValue(oppUpdate.RSF_SUB_ER_TP__c) * 2.5;

            if(oppUpdate.RSF_SUB_CM_TP__c!=oldMap.get(oppUpdate.Id).RSF_SUB_CM_TP__c)
                oppUpdate.SUB_CM_ILF_Equiv__c = getValue(oppUpdate.RSF_SUB_CM_TP__c) * 2.5;

            if(oppUpdate.RSF_SUB_TB_TP__c!=oldMap.get(oppUpdate.Id).RSF_SUB_TB_TP__c)
                oppUpdate.SUB_TB_ILF_Equiv__c = getValue(oppUpdate.RSF_SUB_TB_TP__c) * 2.5;

            if(oppUpdate.RSF_SUB_IM_TP__c!=oldMap.get(oppUpdate.Id).RSF_SUB_IM_TP__c)
                oppUpdate.SUB_IM_ILF_Equiv__c = getValue(oppUpdate.RSF_SUB_IM_TP__c) * 2.5;


            if(oppUpdate.RSF_HOS_CB_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_CB_TP__c)
                oppUpdate.HOS_CB_ILF_Equiv__c = getValue(oppUpdate.RSF_HOS_CB_TP__c) * 2.5;

            if(oppUpdate.RSF_HOS_CL_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_CL_TP__c)
                oppUpdate.HOS_CL_ILF_Equiv__c = getValue(oppUpdate.RSF_HOS_CL_TP__c) * 2.5;

            if(oppUpdate.RSF_HOS_ER_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_ER_TP__c)
                oppUpdate.HOS_ER_ILF_Equiv__c = getValue(oppUpdate.RSF_HOS_ER_TP__c) * 2.5;

            if(oppUpdate.RSF_HOS_CM_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_CM_TP__c)
                oppUpdate.HOS_CM_ILF_Equiv__c = getValue(oppUpdate.RSF_HOS_CM_TP__c) * 2.5;

            if(oppUpdate.RSF_HOS_TB_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_TB_TP__c)
                oppUpdate.HOS_TB_ILF_Equiv__c = getValue(oppUpdate.RSF_HOS_TB_TP__c) * 2.5;

            if(oppUpdate.RSF_HOS_IM_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_IM_TP__c)
                oppUpdate.HOS_IM_ILF_Equiv__c = getValue(oppUpdate.RSF_HOS_IM_TP__c) * 2.5;



            //if(oppUpdate.CSH_CB_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_CB_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_CB_Revenue__c || oppUpdate.RSF_CLD_CB_TP__c!=oldMap.get(oppUpdate.Id).RSF_CLD_CB_TP__c || oppUpdate.RSF_SUB_CB_TP__c!=oldMap.get(oppUpdate.Id).RSF_SUB_CB_TP__c || oppUpdate.RSF_HOS_CB_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_CB_TP__c){
			if(oppUpdate.CSH_CB_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_CB_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_CB_Revenue__c || oppUpdate.ACV_Booking_CB__c!=oldMap.get(oppUpdate.Id).ACV_Booking_CB__c){
			
               // oppUpdate.CSH_CB_ILF_ILF_Equiv__c  = getValue(oppUpdate.In_QTR_ILF_CB_Revenue__c) + ((getValue(oppUpdate.RSF_CLD_CB_TP__c) + getValue(oppUpdate.RSF_SUB_CB_TP__c) + getValue(oppUpdate.RSF_HOS_CB_TP__c)) * 2.5);
				oppUpdate.CSH_CB_ILF_ILF_Equiv__c =   getValue(oppUpdate.In_QTR_ILF_CB_Revenue__c) + (getValue(oppUpdate.ACV_Booking_CB__c) * 2.5);   
            }


           // if(oppUpdate.CSH_CL_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_CL_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_CL_Revenue__c || oppUpdate.RSF_CLD_CL_TP__c !=oldMap.get(oppUpdate.Id).RSF_CLD_CL_TP__c || oppUpdate.RSF_SUB_CL_TP__c !=oldMap.get(oppUpdate.Id).RSF_SUB_CL_TP__c || oppUpdate.RSF_HOS_CL_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_CL_TP__c){
			if(oppUpdate.CSH_CL_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_CL_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_CL_Revenue__c || oppUpdate.ACV_Booking_CL__c!=oldMap.get(oppUpdate.Id).ACV_Booking_CL__c){
			
				oppUpdate.CSH_CL_ILF_ILF_Equiv__c =   getValue(oppUpdate.In_QTR_ILF_CL_Revenue__c) + (getValue(oppUpdate.ACV_Booking_CL__c) * 2.5);   

            }


           // if(oppUpdate.CSH_ER_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_ER_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_ER_Revenue__c || oppUpdate.RSF_CLD_ER_TP__c !=oldMap.get(oppUpdate.Id).RSF_CLD_ER_TP__c || oppUpdate.RSF_SUB_ER_TP__c !=oldMap.get(oppUpdate.Id).RSF_SUB_ER_TP__c || oppUpdate.RSF_HOS_ER_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_ER_TP__c){
			if(oppUpdate.CSH_ER_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_ER_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_ER_Revenue__c || oppUpdate.ACV_Booking_ER__c!=oldMap.get(oppUpdate.Id).ACV_Booking_ER__c){

				oppUpdate.CSH_ER_ILF_ILF_Equiv__c =   getValue(oppUpdate.In_QTR_ILF_ER_Revenue__c) + (getValue(oppUpdate.ACV_Booking_ER__c) * 2.5);   

            }


           // if(oppUpdate.CSH_CM_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_CM_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_CM_Revenue__c || oppUpdate.RSF_CLD_CM_TP__c !=oldMap.get(oppUpdate.Id).RSF_CLD_CM_TP__c || oppUpdate.RSF_SUB_CM_TP__c !=oldMap.get(oppUpdate.Id).RSF_SUB_CM_TP__c || oppUpdate.RSF_HOS_CM_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_CM_TP__c){
			if(oppUpdate.CSH_CM_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_CM_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_CM_Revenue__c || oppUpdate.ACV_Booking_CM__c!=oldMap.get(oppUpdate.Id).ACV_Booking_CM__c){

				oppUpdate.CSH_CM_ILF_ILF_Equiv__c =   getValue(oppUpdate.In_QTR_ILF_CM_Revenue__c) + (getValue(oppUpdate.ACV_Booking_CM__c) * 2.5);   

            }


            //if(oppUpdate.CSH_TB_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_TB_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_TB_Revenue__c || oppUpdate.RSF_CLD_TB_TP__c!=oldMap.get(oppUpdate.Id).RSF_CLD_TB_TP__c || oppUpdate.RSF_SUB_TB_TP__c !=oldMap.get(oppUpdate.Id).RSF_SUB_TB_TP__c || oppUpdate.RSF_HOS_TB_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_TB_TP__c){
			if(oppUpdate.CSH_TB_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_TB_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_TB_Revenue__c || oppUpdate.ACV_Booking_TB__c!=oldMap.get(oppUpdate.Id).ACV_Booking_TB__c){

				oppUpdate.CSH_TB_ILF_ILF_Equiv__c =   getValue(oppUpdate.In_QTR_ILF_TB_Revenue__c) + (getValue(oppUpdate.ACV_Booking_TB__c) * 2.5);   

            }


            //if(oppUpdate.CSH_IM_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_IM_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_IM_Revenue__c || oppUpdate.RSF_CLD_IM_TP__c !=oldMap.get(oppUpdate.Id).RSF_CLD_IM_TP__c || oppUpdate.RSF_SUB_IM_TP__c !=oldMap.get(oppUpdate.Id).RSF_SUB_IM_TP__c || oppUpdate.RSF_HOS_IM_TP__c!=oldMap.get(oppUpdate.Id).RSF_HOS_IM_TP__c){
			if(oppUpdate.CSH_IM_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_IM_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_IM_Revenue__c || oppUpdate.ACV_Booking_IM__c!=oldMap.get(oppUpdate.Id).ACV_Booking_IM__c){

				oppUpdate.CSH_IM_ILF_ILF_Equiv__c =   getValue(oppUpdate.In_QTR_ILF_IM_Revenue__c) + (getValue(oppUpdate.ACV_Booking_IM__c) * 2.5);   

            }


			if(oppUpdate.CSH_CB_ILF_ILF_Equiv__c !=null && oppUpdate.In_QTR_ILF_CB_Revenue__c!=oldMap.get(oppUpdate.Id).In_QTR_ILF_CB_Revenue__c || oppUpdate.ACV_Booking_CB__c!=oldMap.get(oppUpdate.Id).ACV_Booking_CB__c){

				oppUpdate.CSH_CB_ILF_ILF_Equiv__c =   getValue(oppUpdate.In_QTR_ILF_CB_Revenue__c) + (getValue(oppUpdate.ACV_Booking_CB__c) * 2.5);   

            }

        }

    }




}