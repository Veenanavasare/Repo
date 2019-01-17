/* Component Name :API_DHStatusLogicalProvisioningTriggerHandler   
Requirement/User Story Number : IDH New Derivation       
Requirement Description:Update DHStatus-Update Deal Hash Details Fields
Component Author:Accenture IDC     
Created Date: 25th november 2014      
Version:1.0     
*/   
 
public with sharing class API_DHStatusLogicalProvisioningHandler extends SITriggerOperations.SITriggerImpl{
// To be used for Future after insert operations     
     public override boolean onAfterInsert (SObject[] newObjects){        
         try{ 
            UpdateDHStatusUpdateDealHashDetailsFields(newObjects);
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      } 
      
     public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] newObjects, Map<Id, SObject>  newObjectsMap){
            try{
              
               }        
            catch (exception e){ 
                   e.getMessage();        
             }
            return true;    
      } 
   /* public override boolean onBeforeDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap){        
         try{ 
             //ClearDHStatusUpdateDealHashFields(oldObjects);
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      }*/
          
      
      public override boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap){        
         try{ 
             ClearDHStatusUpdateDealHashFields(oldObjects);
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      }
//populating TTU Status,TTU Last Attempted Date on DHStatus-Update Deal Hash Details from Logical Provisionning 
 public void UpdateDHStatusUpdateDealHashDetailsFields(SObject[] newObjects)
    {
        List<DHStatus_Logical_Provisioning__c> DHStatusLPList=newObjects;
        Set<String> DHStatusUDHDIDSet=new Set<String>();
        Set<String> DHStatusUDHDPremiseNumberSet=new Set<String>();
        List<DHStatus_Update_Deal_Hash_Details__c> DHStatusUDHDList=new List<DHStatus_Update_Deal_Hash_Details__c>();        
        Map<Id,DHStatus_Update_Deal_Hash_Details__c> DHStatusUDHDMap=new Map<Id,DHStatus_Update_Deal_Hash_Details__c>();
        for(DHStatus_Logical_Provisioning__c dlp:DHStatusLPList)
        {
            
                DHStatusUDHDIDSet.add(dlp.DHStatusUpdateDealHashDetailsID__c);
                DHStatusUDHDPremiseNumberSet.add(dlp.DHStatusUpdateDealHashPremiseNumber__c);
                
            
        }
                        
        if(DHStatusUDHDIDSet.size()>0 && DHStatusUDHDPremiseNumberSet.size()>0)
        {
            DHStatusUDHDList=[select Id,Premise_Number__c,Test_and_Turn_Up__c,TTU_Last_Attempted_Date__c from DHStatus_Update_Deal_Hash_Details__c WHERE Id IN:DHStatusUDHDIDSet AND Premise_Number__c IN:DHStatusUDHDPremiseNumberSet];
        } 
        if(DHStatusUDHDList.size()>0)
        {
            for(DHStatus_Update_Deal_Hash_Details__c udhd:DHStatusUDHDList)
            {
                for(DHStatus_Logical_Provisioning__c dlpp:DHStatusLPList)
                {
                    if(udhd.Id==dlpp.DHStatusUpdateDealHashDetailsID__c && udhd.Premise_Number__c==dlpp.DHStatusUpdateDealHashPremiseNumber__c && dlpp.DHStatus_IDH_Data_Type__c=='OrderNumberInstar')
                        {
                          udhd.Test_and_Turn_Up__c=dlpp.Activation_Status__c;
                          udhd.TTU_Last_Attempted_Date__c=dlpp.LastModifiedTimeStamp__c;
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
          Catch(Exception e)
          {
          }
      }         
  }
 //clear Corresponding DHStatusUpdateDealHash fields after deleting the logical provisioning 
   public void ClearDHStatusUpdateDealHashFields(SObject[] oldObjects)
     {
        
        List<DHStatus_Logical_Provisioning__c> DeleteDHStatusLPList=oldObjects;
        Map<String,DHStatus_Logical_Provisioning__c> DHStatusLPMap=new  Map<String,DHStatus_Logical_Provisioning__c>();
        Map<Id,DHStatus_Update_Deal_Hash_Details__c> DHStatusUDHDMap=new Map<Id,DHStatus_Update_Deal_Hash_Details__c>();
        
            for(DHStatus_Logical_Provisioning__c dlp:DeleteDHStatusLPList)
            {
                DHStatusLPMap.put(dlp.DHStatusUpdateDealHashDetailsID__c,dlp);
            }          
            if(DHStatusLPMap!=NULL || !DHStatusLPMap.isEmpty())
            {
                for(DHStatus_Update_Deal_Hash_Details__c udhd:[select Id,Test_and_Turn_Up__c,TTU_Last_Attempted_Date__c from DHStatus_Update_Deal_Hash_Details__c WHERE Id IN:DHStatusLPMap.keySet()])
                {
                    udhd.Test_and_Turn_Up__c=NULL;
                    udhd.TTU_Last_Attempted_Date__c=NULL;
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