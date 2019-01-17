trigger RDSContactObjectTrigger on RDS_Contact__c (after delete, after insert, after undelete, after update, 
    before delete, before insert, before update) {
    
    boolean isExecuted = false;
    SITriggerOperations.SITriggerImpl handler = new SITriggerDelegate().getHandlerHandleObject(SIConstants.RDS_CONTACT_TRIGGER_HANDLER);
    
    // A Template for the all operations modify accordingly
     /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        isExecuted = handler.onBeforeInsert(Trigger.new);
    }
    /* After Insert */
    else if(Trigger.isInsert && Trigger.isAfter){
       isExecuted = handler.onAfterInsert(Trigger.new);
    }
    //End for the template block 
}