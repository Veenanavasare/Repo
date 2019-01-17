/* Component Name :API_DHStatusOtherProvidersTriggerHandler    
Requirement/User Story Number : Provisioning Milestones
Requirement Description: Update Demarc Location on DHStatus-Update IDH object from Demarc Location on DHStatus-Other Providers
Component Author:Accenture IDC     
Created Date: 27th Novemember 2014      
Version:1.0     
*/   
 
public with sharing class API_DHStatusOtherProvidersHandler extends SITriggerOperations.SITriggerImpl{


public override boolean onAfterInsert(SObject[] newObjects){
            try{
              updateDemarcLocation(newObjects);
               }        
            catch (exception e){ 
                   e.getMessage();        
             }
         return true;
      } 
public override boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap){        
         try{ 
             ClearDHStatusUpdateDealHashFields(oldObjects);
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      }      
      
      // Method to Update Demarc Location on DHStatus-Update IDH object from Demarc Location on DHStatus-Other Providers
        public void updateDemarcLocation(SObject[] newObjects){
        List<DHStatus_Other_Providers__c> DHStatusprovidersList=newObjects;
        Set<String> DHStatusUDHDIDSet=new Set<String>();
        //Set<String> DHStatusUDHDPremiseNumberSet=new Set<String>();
        List<DHStatus_Update_IDH__c> DHStatusUDHDList=new List<DHStatus_Update_IDH__c>();        
        Map<Id,DHStatus_Update_IDH__c> DHStatusUDHDMap=new Map<Id,DHStatus_Update_IDH__c>();
        for(DHStatus_Other_Providers__c dsop:DHStatusprovidersList)
        {
            if(dsop.Demarc_Location__c!=NULL)
            {
                DHStatusUDHDIDSet.add(dsop.DHStatusUpdateIDHID__c);
            }
        }
                        
        if(DHStatusUDHDIDSet.size()>0)
        {
            DHStatusUDHDList=[select Id,Demarc_Location__c,Data_Type__c,Demarc_Location2__c from DHStatus_Update_IDH__c WHERE Id IN:DHStatusUDHDIDSet];
            System.debug('---&&&---'+DHStatusUDHDList);
        } 
        if(DHStatusUDHDList.size()>0)
        {
            for(DHStatus_Update_IDH__c dhui:DHStatusUDHDList)
            {
                for(DHStatus_Other_Providers__c dhop:DHStatusprovidersList)
                {
                    if(dhui.Id==dhop.DHStatusUpdateIDHID__c && dhop.Record_Type__c == 'C' && dhui.Data_Type__c == 'Port')
                        {
                          dhui.Demarc_Location__c=dhop.Demarc_Location__c;
                          dhui.Demarc_Location2__c=dhop.Demarc_Location2__c;
                          DHStatusUDHDMap.put(dhui.Id,dhui);  
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
          Catch(Exception e)
          {
          }
      }         
  }  
  
   //clear Corresponding  Update Demarc Location on DHStatus-Update IDH object from Demarc Location on DHStatus-Other Providers
   public void ClearDHStatusUpdateDealHashFields(SObject[] oldObjects)
     {
        List<DHStatus_Other_Providers__c> DeleteDHStatusBUList=oldObjects;
        Map<String,DHStatus_Other_Providers__c> DHStatusBUMap=new  Map<String,DHStatus_Other_Providers__c>();
        Map<Id,DHStatus_Update_IDH__c> DHStatusUDHDMap=new Map<Id,DHStatus_Update_IDH__c>();
        
            for(DHStatus_Other_Providers__c dhop:DeleteDHStatusBUList)
            {
                DHStatusBUMap.put(dhop.DHStatusUpdateIDHID__c,dhop);
            }          
            if(DHStatusBUMap!=NULL || !DHStatusBUMap.isEmpty())
            {
                for(DHStatus_Update_IDH__c udhd:[select Id,Demarc_Location__c,Demarc_Location2__c from DHStatus_Update_IDH__c WHERE Id IN:DHStatusBUMap.keySet()])
                {
                    udhd.Demarc_Location__c=NULL;
                    udhd.Demarc_Location2__c=NULL;
                    DHStatusUDHDMap.put(udhd.Id,udhd);
                }
            }
           if(DHStatusUDHDMap.size()>0)
           {
               try
               {
                   update DHStatusUDHDMap.values();
               }
               Catch(Exception e)
               {
               }
           }                            
      }            

}