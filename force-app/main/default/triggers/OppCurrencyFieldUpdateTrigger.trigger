trigger OppCurrencyFieldUpdateTrigger on Opportunity (before insert,before update) 
{

    if(Trigger.isbefore && Trigger.isInsert)
      {
        OppCurrencyFieldUpdateHandler h = new OppCurrencyFieldUpdateHandler();
        h.onBeforeInsert(Trigger.new);
      }
      
    if(Trigger.isbefore && Trigger.isUpdate)
      {
        OppCurrencyFieldUpdateHandler h = new OppCurrencyFieldUpdateHandler();
        h.onBeforeUpdate(Trigger.new,Trigger.oldMap);
      }




}