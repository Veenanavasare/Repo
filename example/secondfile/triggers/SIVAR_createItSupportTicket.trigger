trigger SIVAR_createItSupportTicket on End_User_Support_Ticket__c (after insert, after update, before update) {
    
   boolean isExecuted = false;
   SITriggerOperations.SITriggerImpl handler = new SITriggerDelegate().getHandlerHandleObject(SIConstants.END_CUSTOMER_TICKET_HANDLE);
    
    /* After Insert */
    if(Trigger.isInsert && Trigger.isAfter){
       isExecuted = handler.onAfterInsert(Trigger.new);
    }
    
    /* After Update */
    else if(Trigger.isUpdate && Trigger.isAfter){
          isExecuted = handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }    
    
/*
            List<IT_Support_Ticket__c> itstList = new List<IT_Support_Ticket__c>();

            if(Trigger.isAfter){
            for(End_User_Support_Ticket__c endUsSupp:trigger.new)
            {
            if(endUsSupp.Status__c == 'Open (IT)' && endUsSupp.IT_Support_Ticket__c == null)
            {
            if(SIVAR_itSupp.firstrun)
            {
                IT_Support_Ticket__c itSuppTick = new IT_Support_Ticket__c();
                itSuppTick.Related_to__c = endUsSupp.Related_To__c;
                itSuppTick.Severity__c =endUsSupp.Severity__c;
                itSuppTick.Ticket_Subject__c =endUsSupp.Subject__c;
                itSuppTick.Steps_to_Reproduce_Error__c =endUsSupp.Steps_to_Reproduce_Error__c;
                itSuppTick.Error_Message_Received__c =endUsSupp.Error_Message_Received__c;
                itSuppTick.Impact__c =endUsSupp.Impact__c +':'+ endUsSupp.End_User_Support_Ticket__c;
                itSuppTick.Added_Screenshot_as_Note_Attachment__c =endUsSupp.Screen__c;
                itSuppTick.Status__c ='Open';
                itSuppTick.OwnerId =endUsSupp.Owner_AT_T__c;
                itSuppTick.Owner_Work_Phone__c =endUsSupp.Owner_Work_Phone__c;
                itSuppTick.Logged_Date_Time__c = endUsSupp.Logged_Date_Time__c;
                itSuppTick.End_User_Support_Ticket__c=endUsSupp.End_User_Support_Ticket__c;
                itstList.add(itSuppTick);
            
            }
            }
            }
            
    if(SIVAR_itSupp.firstrun)
    {
    Insert itstList;
    SIVAR_itSupp.firstrun = false;
    }

    }*/ /*else if(Trigger.isBefore){
                for(End_User_Support_Ticket__c endUsSupp:trigger.new)
                {
                if(endUsSupp.Status__c =='In Progress (AT&T)'|| endUsSupp.Status__c =='Open (IT)')
                {
                endUsSupp.OwnerId=endUsSupp.Owner_AT_T__c;
                }
                }
            } */
    

}