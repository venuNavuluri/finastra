public class RUMOppProductToOpportunity extends RollUpManager
{
    public final static Integer RollUpFieldCount = 44;
    
    public class RUOWOppLineItem extends RollUpChild
    {
        public RUOWOppLineItem(OpportunityLineItem oli) { super(oli); }
        public override Id getParentId() { return TheOLI.OpportunityId; }
    
        public OpportunityLineItem TheOLI {
            get { return (OpportunityLineItem)TheSObject; }
            set { TheSObject = value; }
        }
    
        public string getProductFamily()
        {
            system.debug('***CLD Product Family'+TheOLI.PricebookEntry.Product2.Family);
            return TheOLI.PricebookEntry.Product2.Family;
        }
    
        public boolean isProductFamily(string revFam)
        {
            return (
                getProductFamily() == revFam + ' (CB)' ||
                getProductFamily() == revFam + ' (CL)' ||
                getProductFamily() == revFam + ' (CM)' ||
                getProductFamily() == revFam + ' (ER)' ||
                getProductFamily() == revFam + ' (IM)' ||
                getProductFamily() == revFam + ' (TB)' 
                //getProductFamily() == revFam + ' (XX)' 
                
            );
        }
        
        public boolean isServiceProductFamily(string revFam)
        {
            return (
                getProductFamily() == 'PS (' + revFam + ')' ||
                getProductFamily() == 'PSS (' + revFam + ')' ||
                getProductFamily() == 'FD (' + revFam + ')'
            );
        }
        
        //Service desk-1425487 : KK - added the new method to check the product code for the PS products
        public boolean isPSProductCode()
        {   
            String productCode= TheOLI.PricebookEntry.Product2.ProductCode;
            system.debug('isPSProductCode method: Product code is --> '+productCode );
            if(productCode == 'FVPS' || productCode == 'FVFE' ){
                return true;
            }
            return false;
        }
    
        public override string getCurrencyCode() { return TheOLI.CurrencyIsoCode; }
        public override Integer amountFieldCount() { return RUMOppProductToOpportunity.RollUpFieldCount; }
        public override Decimal getAmount(Integer i) {
        
            //BEGIN PN-21/02/2019
            // Adding code to check if product family is Global Payments or Us payments then the rollup
            // should use the total price instead of fair value.
            //replacing the lines 78 and below with variable amt 
            
            Decimal Amt = 0;
            
            if(TheOLI.Misys_Product_Family__c == 'Global Payments'|| TheOLI.Misys_Product_Family__c == 'US Payments') {
                Amt =  TheOLI.TotalPrice;
            }
            
            else{
                Amt =  TheOLI.Fair_Value__c;
            }
            
            //END PN-21/02/2019
            // Adding code to check if product family is Global Payments or Us payments then the rollup
            // should use the total price instead of fair value.
            
            if (i == 0) { return getProductFamily() == 'HOS (IM)' ? Amt : null; }
            else if (i == 1) { return getProductFamily() == 'HOS (CB)' ? Amt : null; }
            else if (i == 2) { return getProductFamily() == 'HOS (CL)' ? Amt : null; }
            else if (i == 3) { return getProductFamily() == 'HOS (CM)' ? Amt : null; }
            else if (i == 4) { return getProductFamily() == 'HOS (ER)' ? Amt : null; }
            else if (i == 5) { return getProductFamily() == 'HOS (TB)' ? Amt : null; }
            else if (i == 6) { return getProductFamily() == 'ILF (IM)' ? Amt : null; }
            else if (i == 7) { return getProductFamily() == 'ILF (CB)' ? Amt : null; }
            else if (i == 8) { return getProductFamily() == 'ILF (CL)' ? Amt : null; }
            else if (i == 9) { return getProductFamily() == 'ILF (CM)' ? Amt : null; }
            else if (i == 10) { return getProductFamily() == 'ILF (ER)' ? Amt : null; }
            else if (i == 11) { return getProductFamily() == 'ILF (TB)' ? Amt : null;  }
            else if (i == 12) { return getProductFamily() == 'SUB (IM)' ? Amt : null; }
            else if (i == 13) { return getProductFamily() == 'SUB (CB)' ? Amt : null; }
            else if (i == 14) { return getProductFamily() == 'SUB (CL)' ? Amt : null; }
            else if (i == 15) { return getProductFamily() == 'SUB (CM)' ? Amt : null; }
            else if (i == 16) { return getProductFamily() == 'SUB (ER)' ? Amt : null; }
            else if (i == 17) { return getProductFamily() == 'SUB (TB)' ? Amt : null; }
            else if (i == 18) { return isServiceProductFamily('IM') ? Amt : null; }
            else if (i == 19) { return isServiceProductFamily('CB') ? Amt : null; }
            else if (i == 20) { return isServiceProductFamily('CL') ? Amt : null; }
            else if (i == 21) { return isServiceProductFamily('CM') ? Amt : null; }
            else if (i == 22) { return isServiceProductFamily('ER') ? Amt : null; }
            else if (i == 23) { return isServiceProductFamily('TB') ? Amt : null; }
            else if (i == 24) { return getProductFamily() == 'RLF (IM)' ? Amt : null; }
            else if (i == 25) { return getProductFamily() == 'RLF (CB)' ? Amt : null; }
            else if (i == 26) { return getProductFamily() == 'RLF (CL)' ? Amt : null; }
            else if (i == 27) { return getProductFamily() == 'RLF (CM)' ? Amt : null; }
            else if (i == 28) { return getProductFamily() == 'RLF (ER)' ? Amt : null; }
            else if (i == 29) { return getProductFamily() == 'RLF (TB)' ? Amt : null; }
            else if (i == 30) { return getProductFamily() == 'CLD (IM)' ? Amt : null; }
            else if (i == 31) { return getProductFamily() == 'CLD (CB)' ? Amt : null; }
            else if (i == 32) { return getProductFamily() == 'CLD (CL)' ? Amt : null; }
            else if (i == 33) { return getProductFamily() == 'CLD (CM)' ? Amt : null; }
            else if (i == 34) { return getProductFamily() == 'CLD (ER)' ? Amt : null; }
            else if (i == 35) { return getProductFamily() == 'CLD (TB)' ? Amt : null; }
            else if (i == 36) { return getProductFamily() == 'ILF (XX)' ? Amt : null; }
            else if (i == 37) { return getProductFamily() == 'SUB (XX)' ? Amt : null; }
            else if (i == 38) { return getProductFamily() == 'HOS (XX)' ? Amt : null; }
            else if (i == 39) { return getProductFamily() == 'CLD (XX)' ? Amt : null; }
           //Service desk-1425487 : KK - added condition for the PS product code for new field RSF_PS_FV__c
            else if (i == 40) { return isPSProductCode() ? Amt : null; }
            
            return null;
        }
        
        /*

            Method Name: getAmount_TP;
            Method Description: Returning the respective fields containing the roll-up value of Total Price;
            Input Parameter: Integer;
            Return Type: Decimal;
            Methods called: getProductFamily() , isServiceProductFamily(string);
            Created By: Mihir Kumar;
        **/
        
        public override Decimal getAmount_TP(Integer i) {
            if (i == 0) { return getProductFamily() == 'HOS (IM)' ? TheOLI.TotalPrice : null; }
            else if (i == 1) { return getProductFamily() == 'HOS (CB)' ? TheOLI.TotalPrice : null; }
            else if (i == 2) { return getProductFamily() == 'HOS (CL)' ? TheOLI.TotalPrice : null; }
            else if (i == 3) { return getProductFamily() == 'HOS (CM)' ? TheOLI.TotalPrice : null; }
            else if (i == 4) { return getProductFamily() == 'HOS (ER)' ? TheOLI.TotalPrice : null; }
            else if (i == 5) { return getProductFamily() == 'HOS (TB)' ? TheOLI.TotalPrice : null; }
            else if (i == 6) { return getProductFamily() == 'ILF (IM)' ? TheOLI.TotalPrice : null; }
            else if (i == 7) { return getProductFamily() == 'ILF (CB)' ? TheOLI.TotalPrice : null; }
            else if (i == 8) { return getProductFamily() == 'ILF (CL)' ? TheOLI.TotalPrice : null; }
            else if (i == 9) { return getProductFamily() == 'ILF (CM)' ? TheOLI.TotalPrice : null; }
            else if (i == 10) { return getProductFamily() == 'ILF (ER)' ? TheOLI.TotalPrice : null; }
            else if (i == 11) { return getProductFamily() == 'ILF (TB)' ? TheOLI.TotalPrice : null; }
            else if (i == 12) { return getProductFamily() == 'SUB (IM)' ? TheOLI.TotalPrice : null; }
            else if (i == 13) { return getProductFamily() == 'SUB (CB)' ? TheOLI.TotalPrice : null; }
            else if (i == 14) { return getProductFamily() == 'SUB (CL)' ? TheOLI.TotalPrice : null; }
            else if (i == 15) { return getProductFamily() == 'SUB (CM)' ? TheOLI.TotalPrice : null; }
            else if (i == 16) { return getProductFamily() == 'SUB (ER)' ? TheOLI.TotalPrice : null; }
            else if (i == 17) { return getProductFamily() == 'SUB (TB)' ? TheOLI.TotalPrice : null; }
            else if (i == 18) { return isServiceProductFamily('IM') ? TheOLI.TotalPrice : null; }
            else if (i == 19) { return isServiceProductFamily('CB') ? TheOLI.TotalPrice : null; }
            else if (i == 20) { return isServiceProductFamily('CL') ? TheOLI.TotalPrice : null; }
            else if (i == 21) { return isServiceProductFamily('CM') ? TheOLI.TotalPrice : null; }
            else if (i == 22) { return isServiceProductFamily('ER') ? TheOLI.TotalPrice : null; }
            else if (i == 23) { return isServiceProductFamily('TB') ? TheOLI.TotalPrice : null; }
            else if (i == 24) { return getProductFamily() == 'RLF (IM)' ? TheOLI.TotalPrice : null; }
            else if (i == 25) { return getProductFamily() == 'RLF (CB)' ? TheOLI.TotalPrice : null; }
            else if (i == 26) { return getProductFamily() == 'RLF (CL)' ? TheOLI.TotalPrice : null; }
            else if (i == 27) { return getProductFamily() == 'RLF (CM)' ? TheOLI.TotalPrice : null; }
            else if (i == 28) { return getProductFamily() == 'RLF (ER)' ? TheOLI.TotalPrice : null; }
            else if (i == 29) { return getProductFamily() == 'RLF (TB)' ? TheOLI.TotalPrice : null; }
            else if (i == 30) { return getProductFamily() == 'CLD (IM)' ? TheOLI.TotalPrice : null; }
            else if (i == 31) { return getProductFamily() == 'CLD (CB)' ? TheOLI.TotalPrice : null; }
            else if (i == 32) { return getProductFamily() == 'CLD (CL)' ? TheOLI.TotalPrice : null; }
            else if (i == 33) { return getProductFamily() == 'CLD (CM)' ? TheOLI.TotalPrice : null; }
            else if (i == 34) { return getProductFamily() == 'CLD (ER)' ? TheOLI.TotalPrice : null; }
            else if (i == 35) { return getProductFamily() == 'CLD (TB)' ? TheOLI.TotalPrice : null; }
            else if (i == 36) { return getProductFamily() == 'ILF (XX)' ? TheOLI.TotalPrice : null; }
            else if (i == 37) { return getProductFamily() == 'SUB (XX)' ? TheOLI.TotalPrice : null; }
            else if (i == 38) { return getProductFamily() == 'HOS (XX)' ? TheOLI.TotalPrice : null; }
            else if (i == 39) { return getProductFamily() == 'CLD (XX)' ? TheOLI.TotalPrice : null; }
            else if (i == 40) { return isProductFamily('FD') ? TheOLI.TotalPrice : null; }
            else if (i == 41) { return isProductFamily('PSS') ? TheOLI.TotalPrice : null; }
            else if (i == 42) { return isProductFamily('PS') ? TheOLI.TotalPrice : null; }
            
            /*The below statement has been added to get the Commissionable Value of Opportunity Product for 
            Rollup Summary of all Commissionable Values to CSH Commissionable Value on Opportunity*/
            else if (i == 43) {
                system.debug('TheOLI = ' + TheOLI); 
                return getProductFamily() == 'CLD (CB)'||getProductFamily() == 'CLD (CL)'||getProductFamily() == 'CLD (CM)'||
                       getProductFamily() == 'CLD (ER)'||getProductFamily() == 'CLD (IM)'||getProductFamily() == 'CLD (TB)'||
                       getProductFamily() == 'SUB (CB)'||getProductFamily() == 'SUB (CL)'||getProductFamily() == 'SUB (CM)'||
                       getProductFamily() == 'SUB (ER)'||getProductFamily() == 'SUB (IM)'||getProductFamily() == 'SUB (TB)'||
                       getProductFamily() == 'HOS (CB)'||getProductFamily() == 'HOS (CL)'||getProductFamily() == 'HOS (CM)'||
                       getProductFamily() == 'HOS (ER)'||getProductFamily() == 'HOS (IM)'||getProductFamily() == 'HOS (TB)'
                        ? TheOLI.Commissionable_Value__c : null; 
            }
            
            
            return null;
        }
        
    }

    public class RUOWOpportunity extends RollUpParent
    {
        public RUOWOpportunity(Opportunity oppty) { super(oppty); }
    
        private Opportunity TheOppty {
            get { return (Opportunity)TheSObject; }
            set { TheSObject = value; }
        }
    
        public override string getCurrencyCode() { return TheOppty.CurrencyIsoCode; }
        public override Integer amountFieldCount() { return RUMOppProductToOpportunity.RollUpFieldCount; }
        public override Decimal getRollUpAmount(Integer i) {
            if (i == 0) { return TheOppty.RSF_HOS_IM__c; }
            else if (i == 1) { return TheOppty.RSF_HOS_CB__c; }
            else if (i == 2) { return TheOppty.RSF_HOS_CL__c; }
            else if (i == 3) { return TheOppty.RSF_HOS_CM__c; }
            else if (i == 4) { return TheOppty.RSF_HOS_ER__c; }
            else if (i == 5) { return TheOppty.RSF_HOS_TB__c; }
            else if (i == 6) { return TheOppty.RSF_ILF_IM__c; }
            else if (i == 7) { return TheOppty.RSF_ILF_CB__c; }
            else if (i == 8) { return TheOppty.RSF_ILF_CL__c; }
            else if (i == 9) { return TheOppty.RSF_ILF_CM__c; }
            else if (i == 10) { return TheOppty.RSF_ILF_ER__c; }
            else if (i == 11) { return TheOppty.RSF_ILF_TB__c; }
            else if (i == 12) { return TheOppty.RSF_SUB_IM__c; }
            else if (i == 13) { return TheOppty.RSF_SUB_CB__c; }
            else if (i == 14) { return TheOppty.RSF_SUB_CL__c; }
            else if (i == 15) { return TheOppty.RSF_SUB_CM__c; }
            else if (i == 16) { return TheOppty.RSF_SUB_ER__c; }
            else if (i == 17) { return TheOppty.RSF_SUB_TB__c; }
            else if (i == 18) { return TheOppty.RSF_SVC_IM__c; }
            else if (i == 19) { return TheOppty.RSF_SVC_CB__c; }
            else if (i == 20) { return TheOppty.RSF_SVC_CL__c; }
            else if (i == 21) { return TheOppty.RSF_SVC_CM__c; }
            else if (i == 22) { return TheOppty.RSF_SVC_ER__c; }
            else if (i == 23) { return TheOppty.RSF_SVC_TB__c; }
            else if (i == 24) { return TheOppty.RSF_RLF_IM__c; }
            else if (i == 25) { return TheOppty.RSF_RLF_CB__c; }
            else if (i == 26) { return TheOppty.RSF_RLF_CL__c; }
            else if (i == 27) { return TheOppty.RSF_RLF_CM__c; }
            else if (i == 28) { return TheOppty.RSF_RLF_ER__c; }
            else if (i == 29) { return TheOppty.RSF_RLF_TB__c; }
            else if (i == 30) { return TheOppty.RSF_CLD_IM__c; }
            else if (i == 31) { return TheOppty.RSF_CLD_CB__c; }
            else if (i == 32) { return TheOppty.RSF_CLD_CL__c; }
            else if (i == 33) { return TheOppty.RSF_CLD_CM__c; }
            else if (i == 34) { return TheOppty.RSF_CLD_ER__c; }
            else if (i == 35) { return TheOppty.RSF_CLD_TB__c; }
            else if (i == 36) { return TheOppty.RSF_ILF_XX__c; }
            else if (i == 37) { return TheOppty.RSF_SUB_XX__c;}
            else if (i == 38) { return TheOppty.RSF_HOS_XX__c;}
            else if (i == 39) { return TheOppty.RSF_CLD_XX__c;}
            //Service desk-1425487 : KK - added the new field RSF_PS_FV__c for PF fair value
            else if (i == 40) { return TheOppty.RSF_PS_FV__c; }
            
            
            
            return null;
        }
        
        /*
            Method Name: getRollUpAmount_TP;
            Method Description: Returning the respective fields containing the roll-up value of Total Price;
            Input Parameter: Integer;
            Return Type: Decimal;
            Methods called: NA;
            Created By: Mihir Kumar;
        **/
        
        public override Decimal getRollUpAmount_TP(Integer i) {
            if (i == 0) { return TheOppty.RSF_HOS_IM_TP__c; }
            else if (i == 1) { return TheOppty.RSF_HOS_CB_TP__c; }
            else if (i == 2) { return TheOppty.RSF_HOS_CL_TP__c; }
            else if (i == 3) { return TheOppty.RSF_HOS_CM_TP__c; }
            else if (i == 4) { return TheOppty.RSF_HOS_ER_TP__c; }
            else if (i == 5) { return TheOppty.RSF_HOS_TB_TP__c; }
            else if (i == 6) { return TheOppty.RSF_ILF_IM_TP__c; }
            else if (i == 7) { return TheOppty.RSF_ILF_CB_TP__c; }
            else if (i == 8) { return TheOppty.RSF_ILF_CL_TP__c; }
            else if (i == 9) { return TheOppty.RSF_ILF_CM_TP__c; }
            else if (i == 10) { return TheOppty.RSF_ILF_ER_TP__c; }
            else if (i == 11) { return TheOppty.RSF_ILF_TB_TP__c; }
            else if (i == 12) { return TheOppty.RSF_SUB_IM_TP__c; }
            else if (i == 13) { return TheOppty.RSF_SUB_CB_TP__c; }
            else if (i == 14) { return TheOppty.RSF_SUB_CL_TP__c; }
            else if (i == 15) { return TheOppty.RSF_SUB_CM_TP__c; }
            else if (i == 16) { return TheOppty.RSF_SUB_ER_TP__c; }
            else if (i == 17) { return TheOppty.RSF_SUB_TB_TP__c; }
            else if (i == 18) { return TheOppty.RSF_SVC_IM_TP__c; }
            else if (i == 19) { return TheOppty.RSF_SVC_CB_TP__c; }
            else if (i == 20) { return TheOppty.RSF_SVC_CL_TP__c; }
            else if (i == 21) { return TheOppty.RSF_SVC_CM_TP__c; }
            else if (i == 22) { return TheOppty.RSF_SVC_ER_TP__c; }
            else if (i == 23) { return TheOppty.RSF_SVC_TB_TP__c; }
            else if (i == 24) { return TheOppty.RSF_RLF_IM__c; }
            else if (i == 25) { return TheOppty.RSF_RLF_CB_TP__c; }
            else if (i == 26) { return TheOppty.RSF_RLF_CL_TP__c; }
            else if (i == 27) { return TheOppty.RSF_RLF_CM_TP__c; }
            else if (i == 28) { return TheOppty.RSF_RLF_ER_TP__c; }
            else if (i == 29) { return TheOppty.RSF_RLF_TB_TP__c; }
            else if (i == 30) { return TheOppty.RSF_CLD_CB_TP__c; }
            else if (i == 31) { return TheOppty.RSF_CLD_CL_TP__c; }
            else if (i == 32) { return TheOppty.RSF_CLD_CM_TP__c; }
            else if (i == 33) { return TheOppty.RSF_CLD_ER_TP__c; }
            else if (i == 34) { return TheOppty.RSF_CLD_IM_TP__c; }
            else if (i == 35) { return TheOppty.RSF_CLD_TB_TP__c; }
            else if (i == 36) { return TheOppty.RSF_ILF_XX_TP__c ; }
            
            else if (i == 37) { return TheOppty.RSF_SUB_XX_TP__c; }
            else if (i == 38) { return TheOppty.RSF_HOS_XX_TP__c; }
            else if (i == 39) { return TheOppty.RSF_CLD_XX_TP__c; }
             
            
            else if (i == 40) { return TheOppty.RSF_FD_ALL__c; }
            else if (i == 41) { return TheOppty.RSF_PSS_ALL__c; }
            else if (i == 42) { return TheOppty.RSF_PS_ALL__c; }
            else if (i == 43) { return TheOppty.CSH_Commissionable_Value__c; }
            return null;
        }
        
        public override void setRollUpAmount(Integer i, Decimal amt) {
            if (i == 0) 
            { 
                TheOppty.RSF_HOS_IM__c = amt; 
            }
            else if (i == 1) 
            { 
                TheOppty.RSF_HOS_CB__c = amt; 
            }
            else if (i == 2) 
            { 
                TheOppty.RSF_HOS_CL__c = amt; 
            }
            else if (i == 3) 
            { 
                TheOppty.RSF_HOS_CM__c = amt; 
            }
            else if (i == 4) 
            { 
                TheOppty.RSF_HOS_ER__c = amt; 
            }
            else if (i == 5) 
            { 
                TheOppty.RSF_HOS_TB__c = amt; 
            }
            else if (i == 6) 
            { 
                TheOppty.RSF_ILF_IM__c = amt; 
            }
            else if (i == 7) 
            { 
            TheOppty.RSF_ILF_CB__c = amt; 
            }
            else if (i == 8) 
            { 
            TheOppty.RSF_ILF_CL__c = amt; 
            }
            else if (i == 9) 
            { 
            TheOppty.RSF_ILF_CM__c = amt; 
            }
            else if (i == 10) 
            { 
            TheOppty.RSF_ILF_ER__c = amt; 
            }
            else if (i == 11) 
            { 
            TheOppty.RSF_ILF_TB__c = amt; 
            }
            else if (i == 12) 
            { 
            TheOppty.RSF_SUB_IM__c = amt; 
            }
            else if (i == 13) 
            { 
            TheOppty.RSF_SUB_CB__c = amt; 
            }
            else if (i == 14) 
            { 
            TheOppty.RSF_SUB_CL__c = amt; 
            }
            else if (i == 15) 
            { 
            TheOppty.RSF_SUB_CM__c = amt; 
            }
            else if (i == 16) 
            { 
            TheOppty.RSF_SUB_ER__c = amt; 
            }
            else if (i == 17) 
            { 
            TheOppty.RSF_SUB_TB__c = amt; 
            }
            else if (i == 18) 
            { 
            TheOppty.RSF_SVC_IM__c = amt; 
            }
            else if (i == 19) 
            { 
            TheOppty.RSF_SVC_CB__c = amt; 
            }
            else if (i == 20) 
            { 
            TheOppty.RSF_SVC_CL__c = amt; 
            }
            else if (i == 21) 
            { 
            TheOppty.RSF_SVC_CM__c = amt; 
            }
            else if (i == 22) 
            { 
            TheOppty.RSF_SVC_ER__c = amt; 
            }
            else if (i == 23) 
            { 
            TheOppty.RSF_SVC_TB__c = amt; 
            }
            else if (i == 24) 
            { 
            TheOppty.RSF_RLF_IM__c = amt; 
            }
            else if (i == 25) 
            { 
            TheOppty.RSF_RLF_CB__c = amt; 
            }
            else if (i == 26) 
            { 
            TheOppty.RSF_RLF_CL__c = amt; 
            }
            else if (i == 27) 
            { 
            TheOppty.RSF_RLF_CM__c = amt; 
            }
            else if (i == 28) 
            { 
            TheOppty.RSF_RLF_ER__c = amt; 
            }
            else if (i == 29) 
            { 
            TheOppty.RSF_RLF_TB__c = amt; 
            }
            else if (i == 30) 
            { 
            TheOppty.RSF_CLD_IM__c = amt; 
            }
            else if (i == 31) 
            { 
            TheOppty.RSF_CLD_CB__c = amt; 
            }
            else if (i == 32) 
            { 
            TheOppty.RSF_CLD_CL__c = amt; 
            }
            else if (i == 33) 
            { 
            TheOppty.RSF_CLD_CM__c = amt; 
            }
            else if (i == 34) 
            { 
            TheOppty.RSF_CLD_ER__c = amt; 
            }
            else if (i == 35) 
            { 
            TheOppty.RSF_CLD_TB__c = amt; 
            }
            else if (i == 36) 
            { 
            TheOppty.RSF_ILF_XX__c = amt; 
            }
            else if (i == 37)
            {
            TheOppty.RSF_SUB_XX__c = amt; 
            }
            else if (i == 38)
            {
            TheOppty.RSF_HOS_XX__c = amt;
            }
            else if (i == 39)
            {
            TheOppty.RSF_CLD_XX__c = amt;
            }
            //Service desk-1425487 : KK - added the new field RSF_PS_FV__c for PF fair value roll up
            else if (i == 40) 
            { 
            TheOppty.RSF_PS_FV__c = amt; 
            }
            
            
        }
        
        /*
            Method Name: setRollUpAmount_TP;
            Method Description: Setting roll-up value of Total Price to respective fields;
            Input Parameter: Integer , Decimal;
            Return Type: Void;
            Methods called: NA;
            Created By: Mihir Kumar;
        **/
        
        public override void setRollUpAmount_TP(Integer i, Decimal amt1) {
            if (i == 0) 
            { 
            TheOppty.RSF_HOS_IM_TP__c = amt1; 
            }
            else if (i == 1) 
            { 
            TheOppty.RSF_HOS_CB_TP__c = amt1; 
            }
            else if (i == 2) 
            { 
            TheOppty.RSF_HOS_CL_TP__c = amt1; 
            }
            else if (i == 3) 
            { 
            TheOppty.RSF_HOS_CM_TP__c = amt1; 
            }
            else if (i == 4) 
            { 
            TheOppty.RSF_HOS_ER_TP__c = amt1; 
            }
            else if (i == 5) 
            { 
            TheOppty.RSF_HOS_TB_TP__c = amt1; 
            }
            else if (i == 6) 
            { 
            TheOppty.RSF_ILF_IM_TP__c = amt1; 
            }
            else if (i == 7) 
            { 
            TheOppty.RSF_ILF_CB_TP__c = amt1; 
            }
            else if (i == 8) 
            { 
            TheOppty.RSF_ILF_CL_TP__c = amt1; 
            }
            else if (i == 9) 
            { 
            TheOppty.RSF_ILF_CM_TP__c = amt1; 
            }
            else if (i == 10) 
            { 
            TheOppty.RSF_ILF_ER_TP__c = amt1; 
            }
            else if (i == 11) 
            { 
            TheOppty.RSF_ILF_TB_TP__c = amt1; 
            }
            else if (i == 12) 
            { 
            TheOppty.RSF_SUB_IM_TP__c = amt1; 
            }
            else if (i == 13) 
            { 
            TheOppty.RSF_SUB_CB_TP__c = amt1; 
            }
            else if (i == 14) 
            { 
            TheOppty.RSF_SUB_CL_TP__c = amt1; 
            }
            else if (i == 15) 
            { 
            TheOppty.RSF_SUB_CM_TP__c = amt1; 
            }
            else if (i == 16) 
            { 
            TheOppty.RSF_SUB_ER_TP__c = amt1; 
            }
            else if (i == 17) 
            { 
            TheOppty.RSF_SUB_TB_TP__c = amt1; 
            }
            else if (i == 18) 
            { 
            TheOppty.RSF_SVC_IM_TP__c = amt1; 
            }
            else if (i == 19) 
            { 
            TheOppty.RSF_SVC_CB_TP__c = amt1; 
            }
            else if (i == 20) 
            { 
            TheOppty.RSF_SVC_CL_TP__c = amt1; 
            }
            else if (i == 21) 
            { 
            TheOppty.RSF_SVC_CM_TP__c = amt1; 
            }
            else if (i == 22) 
            { 
            TheOppty.RSF_SVC_ER_TP__c = amt1; 
            }
            else if (i == 23) 
            { 
            TheOppty.RSF_SVC_TB_TP__c = amt1; 
            }
            else if (i == 24) 
            { 
            TheOppty.RSF_RLF_IM_TP__c = amt1; 
            }
            else if (i == 25) 
            { 
            TheOppty.RSF_RLF_CB_TP__c = amt1; 
            }
            else if (i == 26) 
            { 
            TheOppty.RSF_RLF_CL_TP__c = amt1; 
            }
            else if (i == 27) 
            { 
            TheOppty.RSF_RLF_CM_TP__c = amt1; 
            }
            else if (i == 28) 
            { 
            TheOppty.RSF_RLF_ER_TP__c = amt1; 
            }
            else if (i == 29) 
            { 
            TheOppty.RSF_RLF_TB_TP__c = amt1; 
            }
            else if (i == 30) 
            { 
            TheOppty.RSF_CLD_IM_TP__c = amt1; 
            }
            else if (i == 31) 
            { 
            TheOppty.RSF_CLD_CB_TP__c = amt1; 
            }
            else if (i == 32) 
            { 
            TheOppty.RSF_CLD_CL_TP__c = amt1; 
            }
            else if (i == 33) 
            { 
            TheOppty.RSF_CLD_CM_TP__c = amt1; 
            }
            else if (i == 34) 
            { 
            TheOppty.RSF_CLD_ER_TP__c = amt1; 
            }
            else if (i == 35) 
            { 
            TheOppty.RSF_CLD_TB_TP__c = amt1; 
            }
            else if (i == 36) 
            { 
            TheOppty.RSF_ILF_XX_TP__c = amt1; 
            }
            
            else if (i == 37) 
            { 
            TheOppty.RSF_SUB_XX_TP__c= amt1; 
            }
            
            else if (i == 38) 
            { 
            TheOppty.RSF_HOS_XX_TP__c= amt1; 
            }
            
            else if (i == 39) 
            { 
            TheOppty.RSF_CLD_XX_TP__c= amt1; 
            }
            
            else if (i == 40) 
            { 
            TheOppty.RSF_FD_ALL__c = amt1; 
            }
            else if (i == 41) 
            { 
            TheOppty.RSF_PSS_ALL__c = amt1; 
            }
            else if (i == 42) 
            { 
            TheOppty.RSF_PS_ALL__c = amt1; 
            }
            else if (i == 43) 
            { 
            TheOppty.CSH_Commissionable_Value__c = amt1; 
            }
        }
    }
    
    public RUMOppProductToOpportunity(List<OpportunityLineItem> triggerList, Map<Id, OpportunityLineItem> oldMap, boolean isUpdate)
    {
        List<RollUpChild> theChildren = new List<RollUpChild>();
        Map<Id, RollUpChild> theOldMap = new Map<Id, RollUpChild>();
        for (OpportunityLineItem oli : triggerList) {
            if (isRelevantChild(oli, oldMap, isUpdate)) {
                theChildren.add(createRollUpChild(oli));
                if (oldMap != null) { // update or delete
                    theOldMap.put(oli.Id, createRollUpChild(oldMap.get(oli.Id)));
                }
            }
        }
        SetParentIds(theChildren, theOldMap);
    }

    private boolean isRelevantChild(OpportunityLineItem oli, Map<Id, OpportunityLineItem> oldMap, boolean isUpdate)
    {
        //if (oli.Pearl_Item__c) { return false; } // the Pearl push will be taken care of by the batch job
        boolean isRelevantChange;
        if (isUpdate) {
            isRelevantChange = ((oli.Fair_Value__c != oldMap.get(oli.Id).Fair_Value__c)||(oli.TotalPrice != oldMap.get(oli.Id).TotalPrice));
        }
        else {
            isRelevantChange = true;
        }
        
        return (isRelevantChange && oli.Product_Family__c != null);
    }

    protected override RollUpChild createRollUpChild(SObject oli)
    {
        return new RUOWOppLineItem((OpportunityLineItem)oli);
    }

    public override map<id, RollUpParent> createParentIdToObjectMap(Set<Id> parentIds)
    {
        map<id, RollUpParent> parentIdToObjectMap = new map<id, RollUpParent>();
        //AK - added the field Rollup_Calculate_Batch_Hold__c in the SOQL
        //Service desk-1425487 : KK - added the field RSF_PS_FV__c in SOQL
        for (Opportunity oppty : [
                select id, Name, CurrencyIsoCode, Is_PearlMastered__c,
                In_QTR_ILF_TB_PERCENT__c, In_QTR_ILF_CB_PERCENT__c, In_QTR_ILF_CL_PERCENT__c, In_QTR_ILF_CM_PERCENT__c, 
                In_QTR_ILF_ER_PERCENT__c, In_QTR_ILF_IM_PERCENT__c, In_YR_ILF_CB_PERCENT__c, In_YR_ILF_CL_PERCENT__c,
                In_YR_ILF_CM_PERCENT__c, In_YR_ILF_IM_PERCENT__c, In_YR_ILF_ER_PERCENT__c, In_YR_ILF_TB_PERCENT__c,RSF_ILF_XX__c,
                RSF_HOS_IM__c, RSF_HOS_CB__c, RSF_HOS_CL__c, RSF_HOS_CM__c, RSF_HOS_ER__c, RSF_HOS_TB__c, RSF_ILF_XX_TP__c,
                RSF_ILF_IM__c, RSF_ILF_CB__c, RSF_ILF_CL__c, RSF_ILF_CM__c, RSF_ILF_ER__c, RSF_ILF_TB__c, 
                RSF_SUB_IM__c, RSF_SUB_CB__c, RSF_SUB_CL__c, RSF_SUB_CM__c, RSF_SUB_ER__c, RSF_SUB_TB__c, 
                RSF_SVC_IM__c, RSF_SVC_CB__c, RSF_SVC_CL__c, RSF_SVC_CM__c, RSF_SVC_ER__c, RSF_SVC_TB__c,
                RSF_CLD_IM__c, RSF_CLD_CB__c, RSF_CLD_CL__c, RSF_CLD_CM__c, RSF_CLD_ER__c, RSF_CLD_TB__c,
                RSF_RLF_IM__c, RSF_RLF_CB__c, RSF_RLF_CL__c, RSF_RLF_CM__c, RSF_RLF_ER__c, RSF_RLF_TB__c,
                RSF_HOS_IM_TP__c, RSF_HOS_CB_TP__c, RSF_HOS_CL_TP__c, RSF_HOS_CM_TP__c, RSF_HOS_ER_TP__c, RSF_HOS_TB_TP__c, 
                RSF_ILF_IM_TP__c, RSF_ILF_CB_TP__c, RSF_ILF_CL_TP__c, RSF_ILF_CM_TP__c, RSF_ILF_ER_TP__c, RSF_ILF_TB_TP__c, 
                RSF_SUB_IM_TP__c, RSF_SUB_CB_TP__c, RSF_SUB_CL_TP__c, RSF_SUB_CM_TP__c, RSF_SUB_ER_TP__c, RSF_SUB_TB_TP__c, 
                RSF_CLD_IM_TP__c, RSF_CLD_CB_TP__c, RSF_CLD_CL_TP__c, RSF_CLD_CM_TP__c, RSF_CLD_ER_TP__c, RSF_CLD_TB_TP__c,
                RSF_SVC_IM_TP__c, RSF_SVC_CB_TP__c, RSF_SVC_CL_TP__c, RSF_SVC_CM_TP__c, RSF_SVC_ER_TP__c, RSF_SVC_TB_TP__c,
                RSF_RLF_IM_TP__c, RSF_RLF_CB_TP__c, RSF_RLF_CL_TP__c, RSF_RLF_CM_TP__c, RSF_RLF_ER_TP__c, RSF_RLF_TB_TP__c,
                RSF_FD_ALL__c, RSF_PSS_ALL__c, RSF_PS_ALL__c,RSF_SUB_XX__c,RSF_HOS_XX__c,RSF_CLD_XX__c,RSF_CLD_XX_TP__c,RSF_HOS_XX_TP__c,RSF_SUB_XX_TP__c, CSH_Commissionable_Value__c, Rollup_Calculate_Batch_Hold__c,RSF_PS_FV__c
                from Opportunity
                where Id in :parentIds
        ]) {
            parentIdToObjectMap.put(oppty.Id, new RUOWOpportunity(oppty));
        }
        return parentIdToObjectMap;
    }
    
    //Service desk-1425487 : KK - added the field PricebookEntry.Product2.ProductCode in SOQL
    public override map<id, RollUpChild> createChildIdToObjectMap(Set<Id> parentIds)
    {
        map<id, RollUpChild> childrenIdToObjectMap = new map<id, RollUpChild>();
        for (OpportunityLineItem oli : [
            select id, TotalPrice, Fair_Value__c, Misys_Product_Family__c ,CurrencyIsoCode, OpportunityId, PricebookEntry.Product2.Family, Commissionable_Value__c,PricebookEntry.Product2.ProductCode
            from OpportunityLineItem
            where OpportunityID in :parentIds
            and PricebookEntry.Product2.Family != null
        ]) {
            childrenIdToObjectMap.put(oli.Id, createRollUpChild(oli));
        }
        return childrenIdToObjectMap;
    }

    public override void updateParents(List<RollUpParent> parents)
    {
        List<Opportunity> toUpdate = new List<Opportunity>{};
        for (RollUpParent sow : parents) {
            toUpdate.add((Opportunity)sow.TheSObject);
        }
        system.debug('Opportunity Update - Gunish0402  - ' + JSON.serialize(toUpdate));
        update toUpdate;
    }

}