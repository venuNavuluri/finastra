trigger OpportunityLineItemRollUpTrigger on OpportunityLineItem (after delete, after insert, after update)
{
    List<OpportunityLineItem> param = trigger.isDelete ? trigger.old : trigger.new;

    /*List<Id> Ids = new List<Id>();
    if(((Trigger.isUpdate)||(Trigger.isInsert))&&(param!=NULL))
    {
        for(OpportunityLineItem a : param)
        {
            if(a.OpportunityId!=NULL)
                ids.add(a.OpportunityId);
        }
        List<Opportunity> oppty = [Select Id, Is_PearlMastered__c, In_QTR_ILF_CB_PERCENT__c, In_QTR_ILF_CL_PERCENT__c, 
                            In_QTR_ILF_CM_PERCENT__c, In_QTR_ILF_IM_PERCENT__c, In_QTR_ILF_ER_PERCENT__c, In_QTR_ILF_TB_PERCENT__c, 
                            In_YR_ILF_CB_PERCENT__c, In_YR_ILF_CL_PERCENT__c, In_YR_ILF_CM_PERCENT__c, In_YR_ILF_IM_PERCENT__c, 
                            In_YR_ILF_ER_PERCENT__c,In_YR_ILF_TB_PERCENT__c from Opportunity where Is_PearlMastered__c =TRUE AND Id IN:Ids];
        for(Opportunity oppty1 : oppty)
        {
            if(oppty1.Is_PearlMastered__c)
            {
                oppty1.In_QTR_ILF_CB_PERCENT__c =1;
                oppty1.In_QTR_ILF_CL_PERCENT__c =1;
                oppty1.In_QTR_ILF_CM_PERCENT__c =1;
                oppty1.In_QTR_ILF_IM_PERCENT__c =1;
                oppty1.In_QTR_ILF_ER_PERCENT__c =1;
                oppty1.In_QTR_ILF_TB_PERCENT__c =1;
                oppty1.In_YR_ILF_CB_PERCENT__c =1;
                oppty1.In_YR_ILF_CL_PERCENT__c =1;
                oppty1.In_YR_ILF_CM_PERCENT__c =1;
                oppty1.In_YR_ILF_IM_PERCENT__c =1;
                oppty1.In_YR_ILF_ER_PERCENT__c =1;
                oppty1.In_YR_ILF_TB_PERCENT__c =1;
                
            }
        }
        Update oppty;
    }*/
    
    RUMOppProductToOpportunity rumOLI2Oppty = new RUMOppProductToOpportunity(param, trigger.oldMap, trigger.isUpdate);
    rumOLI2Oppty.DoRollUp();
    
}