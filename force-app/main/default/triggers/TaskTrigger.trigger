trigger TaskTrigger on Task (before insert, after insert, after update, before update) {
    TaskTriggerHelper.Process(trigger.new, trigger.oldMap);

    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
       if(Constants.runonce()){
       
       
       
       List<String> str_List = system.label.Marketing_MQL_Task_Subject.split(',');
       
       
       
           //To filter out the marketing MQL tasks for processing
            List<Task> marketingMQLTasks = new List<Task>();
            
         
            
           
            
            
           
              
            for(Task tk: trigger.new)
            {
                for(String str : str_List)
                  {
                    
                      if(tk.RecordTypeId == IdManager.MarketingFollowUpRecTypeId && !String.isEmpty(tk.subject) && tk.subject.containsIgnoreCase(str))
                      {
                          marketingMQLTasks.add(tk); 
                          
                          break;
                      }
                 }
            } 
         
            if(marketingMQLTasks!=null && marketingMQLTasks.size()>0){
                //To call the TaskTriggerHelper method for processing the MQL tasks.
                TaskTriggerHelper.processMarketingMQLTasks(trigger.new);
            }
       
    }
    
}
}