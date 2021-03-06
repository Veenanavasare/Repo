trigger API_DHStatusLogicalProvisioningTrigger on DHStatus_Logical_Provisioning__c(before insert, after insert,  
before update, after update, before delete, after delete, after undelete) {
  
    boolean isExecuted = false;
   SITriggerOperations.SITriggerImpl handler = new SITriggerDelegate().getHandlerHandleObject(SIConstants.DHStatus_Logical_Provisioning_TRIG_HANDLER);
   
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
        isExecuted = handler.onAfterDelete(Trigger.old, Trigger.oldMap);
    }
    /* After Undelete */
    else if(Trigger.isUnDelete){
       // isExecuted = handler.onUndelete(Trigger.new);
    }
    //End for the template block
}