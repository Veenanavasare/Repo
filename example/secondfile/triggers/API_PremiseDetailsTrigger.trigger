trigger API_PremiseDetailsTrigger on RDS_Premise_Details__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
  
    boolean isExecuted = false;
   SITriggerOperations.SITriggerImpl handler = new SITriggerDelegate().getHandlerHandleObject(SIConstants.PremiseDetail_TRIGGER_HANDLER);
   
   // A Template for the all operations modify accordingly
   
   /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
       isExecuted = handler.onBeforeInsert(Trigger.new);
    }
    
    /* after Insert */
    else if(Trigger.isInsert && Trigger.isAfter){
       isExecuted = handler.onAfterInsert(Trigger.new);
    }
    
    /* Before Update */
    else if(Trigger.isUpdate && Trigger.isBefore){
        isExecuted = handler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
    
    /* After Update */
    else if(Trigger.isUpdate && Trigger.isAfter){
          isExecuted = handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        
    }
    
}