public with sharing Class APIDHStatus_AccessCircuit_TriggerHandler extends SITriggerOperations.SITriggerImpl{
// To be used for Future after insert operations     
     public override boolean onAfterInsert (SObject[] newObjects){        
         try{ 
             populateTestAndTurnUpDate(newObjects);
            
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      }
       
      public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] newObjects, Map<Id, SObject>  newObjectsMap){
            try{
                populateTestAndTurnUpDate(newObjects);
                
               }        
            catch (exception e){ 
                   e.getMessage();        
             }
             return true;    
      }
      public override boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap){        
         try{ 
             clearTestandTurnUpDate(oldObjects);
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      } 
      
      public void populateTestAndTurnUpDate(SObject[] newObjects){
          List<DHStatus_Access_Circuit_Data__c> listOfcircuit= newObjects;
          Map<Id,DHStatus_Access_Circuit_Data__c> mapofCircuit = new Map<Id,DHStatus_Access_Circuit_Data__c>();
          List<DHStatus_Update_Deal_Hash_Details__c> udhdObjList = new List<DHStatus_Update_Deal_Hash_Details__c>();
          List<DHStatus_Update_Deal_Hash_Details__c> udhdObjListToUpdate = new List<DHStatus_Update_Deal_Hash_Details__c>();
          
          for(DHStatus_Access_Circuit_Data__c cir:listOfcircuit){
              if(cir.Private_Line_Activation_Status__c!= null){                  
                  mapofCircuit.put(cir.DHStatus_Update_Deal_Hash_Details__c,cir);
              }          
          }
         
         if((mapofCircuit!= null)|| (!mapofCircuit.isEmpty())){
             udhdObjList = [select id,Test_and_Turn_Up__c from DHStatus_Update_Deal_Hash_Details__c where id in :mapofCircuit.keySet()]; 
             if(udhdObjList.size()>0){        
                 for(DHStatus_Update_Deal_Hash_Details__c dh:udhdObjList){
                     for(DHStatus_Access_Circuit_Data__c cir :mapofCircuit.values()){ 
                       if(cir.DHStatus_Update_Deal_Hash_Details__c == dh.Id){              
                           dh.Test_and_Turn_Up__c = cir.Private_Line_Activation_Status__c;
                           udhdObjListToUpdate .add(dh);         
                       }       
                     }
                 }
             }
         }
             if(udhdObjListToUpdate.size()>0){
                 try{
                     update udhdObjListToUpdate;
                 }Catch(Exception e){
                     e.getMessage();
                 }
             
             }
         
      }
      public void clearTestandTurnUpDate(SObject[] oldObjects){
          List<DHStatus_Access_Circuit_Data__c> listOfcircuit= oldObjects;
          Map<Id,DHStatus_Access_Circuit_Data__c> mapofCircuit = new Map<Id,DHStatus_Access_Circuit_Data__c>();
          List<DHStatus_Update_Deal_Hash_Details__c> udhdObjList = new List<DHStatus_Update_Deal_Hash_Details__c>();
          List<DHStatus_Update_Deal_Hash_Details__c> udhdObjListToUpdate = new List<DHStatus_Update_Deal_Hash_Details__c>();
          
          for(DHStatus_Access_Circuit_Data__c cir:listOfcircuit){
                               
                  mapofCircuit.put(cir.DHStatus_Update_Deal_Hash_Details__c,cir);
                        
          }
         
         if((mapofCircuit!= null)|| (!mapofCircuit.isEmpty())){
             udhdObjList = [select id,Test_and_Turn_Up__c from DHStatus_Update_Deal_Hash_Details__c where id in :mapofCircuit.keySet()]; 
             if(udhdObjList.size()>0){        
                 for(DHStatus_Update_Deal_Hash_Details__c dh:udhdObjList){
                     for(DHStatus_Access_Circuit_Data__c cir :mapofCircuit.values()){
                       if(cir.DHStatus_Update_Deal_Hash_Details__c == dh.Id){                 
                           dh.Test_and_Turn_Up__c = '';
                           udhdObjListToUpdate .add(dh); 
                       }               
                     }
                 }
             }
         }
             if(udhdObjListToUpdate.size()>0){
                 try{
                     update udhdObjListToUpdate;
                 }Catch(Exception e){
                     e.getMessage();
                 }
             
             }
      }
}