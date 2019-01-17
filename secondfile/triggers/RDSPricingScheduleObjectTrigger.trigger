trigger RDSPricingScheduleObjectTrigger on RDS_Pricing_Schedule_Detail__c (after delete, after insert, after undelete, after update, 
    before delete, before insert, before update) {
    
    
    boolean isExecuted = false;
    SITriggerOperations.SITriggerImpl handler = new SITriggerDelegate().getHandlerHandleObject(SIConstants.RDS_PRICING_SCHEDULE_TRIGGER_HANDLER);
    
    // A Template for the all operations modify accordingly
     /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        isExecuted = handler.onBeforeInsert(Trigger.new);
    }
    /* After Insert */
    else if(Trigger.isInsert && Trigger.isAfter){
       isExecuted = handler.onAfterInsert(Trigger.new);
    }
    /* Before Update */ //please uncomment below else if, if you need to perform before update event
   // else if(Trigger.isUpdate && Trigger.isBefore){
   //     isExecuted = handler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    //}
    /* After Update */ //please uncomment below else if, if you need to perform after update event
   // else if(Trigger.isUpdate && Trigger.isAfter){
     //  isExecuted = handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);

    //}
    /* Before Delete */ //please uncomment below else if, if you need to perform before delete event
    //else if(Trigger.isDelete && Trigger.isBefore){
    //    isExecuted = handler.onBeforeDelete(Trigger.old, Trigger.oldMap);
    //}
    /* After Delete */ //please uncomment below else if, if you need to perform after delete event
   // else if(Trigger.isDelete && Trigger.isAfter){
     //   isExecuted = handler.onAfterDelete(Trigger.old, Trigger.oldMap);
    //}
    /* After Undelete */ //please uncomment below else if, if you need to perform undelete event
    //else if(Trigger.isUnDelete){
      // isExecuted = handler.onUndelete(Trigger.new);
   // }
    //End for the template block 
  // }

}