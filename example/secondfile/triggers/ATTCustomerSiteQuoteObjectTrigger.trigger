trigger ATTCustomerSiteQuoteObjectTrigger on AT_T_Customer_Site_Quote__c(after delete, after insert, after undelete, after update, before delete, before insert, before update){
    if(Label.ExecuteSiteQuoteJuncTrigger == 'true' && SIConstants.allowSiteQuoteJuncTrigger == true){
        boolean isExecuted = false;
        SITriggerOperations.SITriggerImpl handler = new SITriggerDelegate().getHandlerHandleObject(SIConstants.CUST_SITE_QUOTE_TRIG_HANDLER);
       
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
            //isExecuted = handler.onAfterDelete(Trigger.old, Trigger.oldMap);
        }
        /* After Undelete */
        else if(Trigger.isUnDelete){
           // isExecuted = handler.onUndelete(Trigger.new);
        }
    }
}