trigger CapiAccountChangeTrigger on Account (after update)
{
if(Label.disable_capi_trigger!='false')
{
    CapiAccountChangeTriggerManager capiAcctChgMgr = new CapiAccountChangeTriggerManager(trigger.oldMap, trigger.newMap);
    capiAcctChgMgr.Execute();
    }
}