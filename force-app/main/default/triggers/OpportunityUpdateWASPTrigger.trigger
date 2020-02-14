trigger OpportunityUpdateWASPTrigger on Opportunity (after delete, after update)
{
if(Label.Disable_WASP_Trigger != 'Disable'){
 /*   OpportunityWASPTriggerHelper th;
    if (trigger.isUpdate) {
        th = new OpportunityUpdateWASPTriggerHelper(trigger.new, trigger.OldMap);
    }
    else if (trigger.isDelete) {
        th = new OpportunityDeleteWASPTriggerHelper(trigger.old);
    }
    if (th != null) { th.Execute(); }*/
    }
}