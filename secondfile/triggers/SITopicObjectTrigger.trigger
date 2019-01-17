/**
* Class/Trigger  Name: SITopicObjectTrigger
* Author: Accenture
* Date: 14-Feb-2014
* Requirement # US181929
* Description: This is the Trigger for Topic object.
* Version History: V 1.0
*/
trigger SITopicObjectTrigger on Topic__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	boolean isExecuted = false;
 	SITriggerOperations.SITriggerImpl handler = new SITriggerDelegate().getHandlerHandleObject(SIConstants.TOPIC_TRIGGER_HANDLER);
 	 	
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