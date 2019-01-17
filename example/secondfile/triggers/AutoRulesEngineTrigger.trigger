trigger AutoRulesEngineTrigger on Promotion_Engine__c (before delete,before update) {
    AutoRulesEngineTriggerHandler aREhandler = new AutoRulesEngineTriggerHandler();
    if(trigger.isbefore && trigger.isdelete){
        aREhandler.EmailAfterDelete(trigger.old);    
    }
    
    if(trigger.isbefore && trigger.isupdate){
        aREhandler.CheckCategoryThreeRule(trigger.old,trigger.new,trigger.oldmap);
    }
  
}