public with sharing Class API_PrivateLineTriggerHandler extends SITriggerOperations.SITriggerImpl{
    /*public override boolean onBeforeInsert (SObject[] newObjects)
    {
    }*/
    public override boolean onAfterInsert (SObject[] newObjects)
    {   try{
            populateFacilityInEffectDate(newObjects);
        }
        catch (exception e)
        {
            e.getMessage();        
        } 
         return true; 
    }
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] newObjects, Map<Id, SObject>  newObjectsMap)
    {
         try{
                populateFacilityInEffectDate(newObjects);
               }        
            catch (exception e){ 
                   e.getMessage();        
             }
            return true;    
    }
       public override boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap){        
         try{ 
             clearInEffectDate(oldObjects);
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      } 
    public void populateFacilityInEffectDate(SObject[] newObjects){
    
    List<DHStatus_Private_Line__c> listOfnewPrivateLine = newObjects;
    Map<Id,DHStatus_Private_Line__c> mapOfIdAndPrivateLine = new Map<Id,DHStatus_Private_Line__c>();
    List<DHStatus_Update_IDH__c> dhStatusList = new List<DHStatus_Update_IDH__c>();
    List<DHStatus_Update_IDH__c> dhStatusListToUpdate = new List<DHStatus_Update_IDH__c>();
    
    
        for(DHStatus_Private_Line__c privateline :listOfnewPrivateLine)
        {
            mapOfIdAndPrivateLine.put(privateline.DHStatus_Update_Deal_Hash_Details__c,privateline);
        }
        
        if((mapOfIdAndPrivateLine!= null)|| (!mapOfIdAndPrivateLine.isEmpty())){
            for(DHStatus_Update_IDH__c dhs :[select id,Circuit_Facility_Assignment_TimeReceived__c, DHStatus_Update_Deal_Hash_Details__c from DHStatus_Update_IDH__c where id in :mapOfIdAndPrivateLine.keySet()])
            {
                if(mapOfIdAndPrivateLine.get(dhs.DHStatus_Update_Deal_Hash_Details__c).Design__c!=null)
                {
                        dhs.Circuit_Facility_Assignment_TimeReceived__c = 'Yes';
                        dhStatusListToUpdate.add(dhs);
                }
                else{                
                        dhs.Circuit_Facility_Assignment_TimeReceived__c = 'No';
                        dhStatusListToUpdate.add(dhs);       
                    }
            }
        }
       
        
        if(dhStatusListToUpdate.size()>0){
            try{
                update dhStatusListToUpdate;
            }Catch(DMLException e){
                e.getMessage();
            }
        
        }
        
        }
        public void clearInEffectDate(SObject[] oldObjects){
        List<DHStatus_Private_Line__c> listOfnewPrivateLine = oldObjects;
        Map<Id,DHStatus_Private_Line__c> mapOfIdAndPrivateLine = new Map<Id,DHStatus_Private_Line__c>();
        List<DHStatus_Update_IDH__c> dhStatusList = new List<DHStatus_Update_IDH__c>();
        List<DHStatus_Update_IDH__c> dhStatusListToUpdate = new List<DHStatus_Update_IDH__c>();
    
    
        for(DHStatus_Private_Line__c privateline :listOfnewPrivateLine)
        {
            mapOfIdAndPrivateLine.put(privateline.DHStatus_Update_Deal_Hash_Details__c,privateline);
        }
        
        if((mapOfIdAndPrivateLine!= null)|| (!mapOfIdAndPrivateLine.isEmpty())){
            for(DHStatus_Update_IDH__c dhs :[select id,Circuit_Facility_Assignment_TimeReceived__c from DHStatus_Update_IDH__c where id in :mapOfIdAndPrivateLine.keySet()])
            {
                dhs.Circuit_Facility_Assignment_TimeReceived__c = '';
                dhStatusListToUpdate.add(dhs);                
            }
        }
       
        
        if(dhStatusListToUpdate.size()>0){
            try{
                update dhStatusListToUpdate;
            }Catch(DMLException e){
                e.getMessage();
            }
        
        }
        
        
        }
    }