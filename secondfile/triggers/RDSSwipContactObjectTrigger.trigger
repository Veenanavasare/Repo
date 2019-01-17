trigger RDSSwipContactObjectTrigger on RDS_SWIP_Contacts__c(after delete, after insert, after undelete, after update, 
    before delete, before insert, before update) {
    
    boolean isExecuted = false;
    SITriggerOperations.SITriggerImpl handler = new SITriggerDelegate().getHandlerHandleObject(SIConstants.RDS_SWIP_CONTACTS_TRIGGER_HANDLER);
    
    // A Template for the all operations modify accordingly
     /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        isExecuted = handler.onBeforeInsert(Trigger.new);
    }
    /* After Insert */
    else if(Trigger.isInsert && Trigger.isAfter){
       isExecuted = handler.onAfterInsert(Trigger.new);
    }
    /* Before Update */
    else if(Trigger.isUpdate && Trigger.isBefore){
        isExecuted = handler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
         // Start
           // UpdateQuoteStage.quoteStage(Trigger.new,Trigger.oldMap);
        //End of change
    }
    /* After Update */
    else if(Trigger.isUpdate && Trigger.isAfter){
            isExecuted = handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        
    }
    /* Before Delete */
    else if(Trigger.isDelete && Trigger.isBefore){
        //isExecuted = handler.onBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    /* After Delete */
    else if(Trigger.isDelete && Trigger.isAfter){
        //isExecuted = handler.onAfterDelete(Trigger.old, Trigger.oldMap);
    }
    /* After Undelete */
    else if(Trigger.isUnDelete){
       //isExecuted = handler.onUndelete(Trigger.new);
    }
    //End for the template block 
}