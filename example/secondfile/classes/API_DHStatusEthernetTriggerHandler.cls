/* Component Name :API_DHStatusEthernetTriggerHandler      
Requirement/User Story Number : US311424      
Requirement Description:Update Field(Facility in Effect Date) on DHStatus-Update Deal Hash Details Object from DHStatus-Ethernet object
Component Author:Accenture IDC     
Created Date: 1st September 2014      
Version:1.0     
*/   
 
public with sharing class API_DHStatusEthernetTriggerHandler extends SITriggerOperations.SITriggerImpl{
// To be used for Future after insert operations     
     public override boolean onAfterInsert (SObject[] newObjects){        
         try{ 
             updateFacilityInEffectDateOnDHStatus(newObjects);
             populateCircuitInEffectDateonUpdateIDH(newObjects);
            }        
         catch (exception e){e.getMessage();} 
         return true;    
      } 
      
    /* public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] newObjects, Map<Id, SObject>  newObjectsMap){
            try{
               //updateFacilityInEffectDateOnDHStatus(newObjects); 
               }        
            catch (exception e){ 
                   e.getMessage();        
             }
            return true;    
      } */
      public override boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap){        
         try{ 
             clearFacilityInEffectDate(oldObjects);
             ClearCircuitInEffectDateonUpdateIDH(oldObjects);
            }        
         catch (exception e){e.getMessage();} 
         return true;    
      } 
      
/* Method to update Facility in Effect Date on DHStatus-Update Deal Hash Details Object from DHStatus-Ethernet object */      
      public void updateFacilityInEffectDateOnDHStatus(SObject[] newObjects){
      List<DHStatus_Ethernet__c> dhEthernet = newObjects;
      Map<Id,DHStatus_Ethernet__c> dhEthernetMap = new Map<Id,DHStatus_Ethernet__c>();  
      List<DHStatus_Update_IDH__c> updateDHStatus= new List<DHStatus_Update_IDH__c>();
        
        for(DHStatus_Ethernet__c dhEDets: dhEthernet){
            if(dhEDets.Facility_IN_Effect_Date__c !=null || dhEDets.Facility_IN_Effect_Date__c != ''){
            dhEthernetMap.put(dhEDets.DHStatus_Update_IDH_ID__c,dhEDets);
            }
        } 
        
        if(dhEthernetMap!=null || !dhEthernetMap.isEmpty()){
            for(DHStatus_Update_IDH__c udhdObj : [select Id,Facility_in_Effect_Date__c from DHStatus_Update_IDH__c where ID in :dhEthernetMap.keySet() AND Data_Type__c='Port']){
            udhdObj.Facility_in_Effect_Date__c = dhEthernetMap.get(udhdObj.ID).Facility_IN_Effect_Date__c;
            updateDHStatus.add(udhdObj);
            }
        }
        
        if(updateDHStatus.size()>0){
            try{
                 update updateDHStatus;
            }catch(DMLException e){e.getMessage();}        
        }    
      }
      public void clearFacilityInEffectDate(SObject[] oldObjects){
      List<DHStatus_Ethernet__c> dhEthernet = oldObjects;
      Map<Id,DHStatus_Ethernet__c> dhEthernetMap = new Map<Id,DHStatus_Ethernet__c>();  
      List<DHStatus_Update_IDH__c> updateDHStatus= new List<DHStatus_Update_IDH__c>();
      
        for(DHStatus_Ethernet__c dhEDets: dhEthernet){
            
            dhEthernetMap.put(dhEDets.DHStatus_Update_IDH_ID__c,dhEDets);
            
        } 
        
        if(dhEthernetMap!=null || !dhEthernetMap.isEmpty()){
            for(DHStatus_Update_IDH__c udhdObj : [select Id,Facility_in_Effect_Date__c from DHStatus_Update_IDH__c where ID in :dhEthernetMap.keySet()]){
            udhdObj.Facility_in_Effect_Date__c =NULL;
            updateDHStatus.add(udhdObj);
            }
        }
        
        if(updateDHStatus.size()>0){
            try{
                 update updateDHStatus;
            }catch(DMLException e){e.getMessage();}        
        }
      
      }
//Method to populate CircuitInEffectDate on DH-Status Update IDH from DHStatus-Ethernet      
      
      public void populateCircuitInEffectDateonUpdateIDH(SObject[] newObjects){
      
        List<DHStatus_Ethernet__c> DHStatusLPList=newObjects;
        Set<String> DHStatusUDHDIDSet=new Set<String>();
        Set<String> DHStatusUDHDPremiseNumberSet=new Set<String>();
        List<DHStatus_Update_IDH__c> DHStatusUDHDList=new List<DHStatus_Update_IDH__c>();        
        Map<Id,DHStatus_Update_IDH__c> DHStatusUDHDMap=new Map<Id,DHStatus_Update_IDH__c>();
        for(DHStatus_Ethernet__c dhse:DHStatusLPList)
        {
            if(dhse.CircuitInEffect_Date__c!=NULL)
            {
                DHStatusUDHDIDSet.add(dhse.DHStatus_Update_IDH_ID__c);
           
            }
        }
                        
        if(DHStatusUDHDIDSet.size()>0)
        {
            DHStatusUDHDList=[select Id,Circuit_In_Effect_Date__c,Data_Type__c from DHStatus_Update_IDH__c WHERE Id IN:DHStatusUDHDIDSet];
        } 
        if(DHStatusUDHDList.size()>0)
        {
            for(DHStatus_Update_IDH__c udhd:DHStatusUDHDList)
            {
                for(DHStatus_Ethernet__c dhse:DHStatusLPList)
                {
                    if(udhd.id==dhse.DHStatus_Update_IDH_ID__c && udhd.Data_Type__c == 'Port')
                        {
                          udhd.Circuit_In_Effect_Date__c = dhse.CircuitInEffect_Date__c;
                          DHStatusUDHDMap.put(udhd.Id,udhd);  
                        }    
                }
            }
        }
      if(DHStatusUDHDMap.size()>0)
      {
          try
          {
          update DHStatusUDHDMap.Values();
          }
          Catch(Exception e){ }
      }         
  }  
  
  //Method to Clear CircuitInEffectDate on DH-Status Update IDH from DHStatus-Ethernet      
      
      public void ClearCircuitInEffectDateonUpdateIDH(SObject[] oldObjects){
      
        List<DHStatus_Ethernet__c> DeleteDHStatusBUList=oldObjects;
        Map<String,DHStatus_Ethernet__c> DHStatusBUMap=new  Map<String,DHStatus_Ethernet__c>();
        Map<Id,DHStatus_Update_IDH__c> DHStatusUDHDMap=new Map<Id,DHStatus_Update_IDH__c>();
        
            for(DHStatus_Ethernet__c dhes:DeleteDHStatusBUList)
            {
                DHStatusBUMap.put(dhes.DHStatus_Update_IDH_ID__c,dhes);
                system.debug('--@@--'+DHStatusBUMap);
            }          
            if(DHStatusBUMap!=NULL || !DHStatusBUMap.isEmpty())
            {
                for(DHStatus_Update_IDH__c udhd:[select Id,Circuit_In_Effect_Date__c from DHStatus_Update_IDH__c WHERE Id IN:DHStatusBUMap.keySet()])
                {
                    udhd.Circuit_In_Effect_Date__c=NULL;
                    DHStatusUDHDMap.put(udhd.Id,udhd);
                }
            }
           if(DHStatusUDHDMap.size()>0)
           {
               try
               {
                   update DHStatusUDHDMap.values();
               }
               Catch(Exception e){ }
           }                            
      }            
  }