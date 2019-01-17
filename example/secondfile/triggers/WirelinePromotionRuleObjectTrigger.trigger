trigger WirelinePromotionRuleObjectTrigger  on Wireline_Promotion_Rules__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(Label.ExecuteWirelinePromoTrigger =='true' && SIConstants.allowWirelinePromotionTrigger == true){
        boolean isExecuted = false;
        SITriggerOperations.SITriggerImpl handler = new SITriggerDelegate().getHandlerHandleObject(SIConstants.WIRELINE_PROMOTION_RULE_TRIGGER_HANDLER);
    
        /* Before Insert */
        if(Trigger.isInsert && Trigger.isBefore){
            //isExecuted = handler.onBeforeInsert(Trigger.new);
        }
        /* After Insert */
        else if(Trigger.isInsert && Trigger.isAfter){
           system.debug('---in trigger after insert---');
           isExecuted = handler.onAfterInsert(Trigger.new);
        }
        /* Before Update*/
        else if(Trigger.isUpdate && Trigger.isBefore){
           system.debug('---in trigger before update---');
           isExecuted = handler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
        }
        /* After Update*/
        else if(Trigger.isUpdate && Trigger.isAfter){
            system.debug('---in trigger after udpate---');
            isExecuted = handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
        }
    }
}