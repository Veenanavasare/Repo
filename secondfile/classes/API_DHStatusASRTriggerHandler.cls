/* Component Name :API_DHStatusASRTriggerHandler      
Requirement/User Story Number :US290910 ; US311424     
Requirement Description:Update Derived Fields on DHStatus-Update Deal Hash Details Object from DHStatus-ASR Details object
Component Author:Accenture IDC     
Created Date:29th July 2014      
Version:1.0     
*/   
 
public with sharing class API_DHStatusASRTriggerHandler extends SITriggerOperations.SITriggerImpl{
// To be used for Future after insert operations     
     public override boolean onAfterInsert (SObject[] newObjects){        
         try{ 
             UpdateDHStatusIDHFields(newObjects);
             //updateEADDateOnInsert(newObjects);
             //updateProvisioningDates(newObjects);
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      }
       
      public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] newObjects, Map<Id, SObject>  newObjectsMap){
            try{
                //updateEADDateOnUpdate(oldObjects,newObjects);
                //updateProvisioningDates(newObjects);
               }        
            catch (exception e){ 
                   e.getMessage();        
             }
             return true;    
      }
      public override boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap){        
         try{ 
             ClearDHStatusIDHFields(oldObjects);
             //deleteProvisioningDates(oldObjects);
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      } 
      
     

          
 public void UpdateDHStatusIDHFields(SObject[] newObjects)
    {
         List<DHStatus_ASR_Details__c> DHStatusASRList=newObjects;
         Set<String> DHStatusIDHIDSet=new Set<String>();
         List<DHStatus_Update_IDH__c> IDHList=new List<DHStatus_Update_IDH__c>();
         Map<Id,DHStatus_Update_IDH__c> IDHMap=new Map<Id,DHStatus_Update_IDH__c>();
         for(DHStatus_ASR_Details__c asr:DHStatusASRList)
         {
             if(asr.Purchase_Order_Number__c!=NULL || asr.Expected_Order_Confirmation_Date__c!=NULL ||  asr.Service_Order_Due__c!=NULL)
             {
                 DHStatusIDHIDSet.add(asr.DHStatus_Update_IDH__c);
             }
         }
         
             if(DHStatusIDHIDSet.size()>0)
             {
                IDHList=[select Id,Exchange_Access_Date_EVC_PON__c,Exchange_Access_Date_UNI_PON__c,Expected_FOC_Date_EVC_PON__c,Expected_FOC_Date_UNI_PON__c,Data_Type__c,UNI_PON__c,EVC_PON__c from DHStatus_Update_IDH__c WHERE Id IN:DHStatusIDHIDSet]; 
             }
             if(IDHList.size()>0)
             {
                 for(DHStatus_Update_IDH__c idh:IDHList)
                 {
                     for(DHStatus_ASR_Details__c asrr:DHStatusASRList)
                     {
                         if(idh.Id==asrr.DHStatus_Update_IDH__c && idh.Data_Type__c=='Port')
                         {
                            idh.UNI_PON__c=asrr.Purchase_Order_Number__c;
                            idh.Expected_FOC_Date_UNI_PON__c=asrr.Expected_Order_Confirmation_Date__c;
                            idh.Exchange_Access_Date_UNI_PON__c=asrr.Service_Order_Due__c;
                            IDHMap.put(idh.Id,idh);
                         }
                          else if(idh.Id==asrr.DHStatus_Update_IDH__c && idh.Data_Type__c=='Vlan')
                         {
                             idh.EVC_PON__c=asrr.Purchase_Order_Number__c;
                             idh.Expected_FOC_Date_EVC_PON__c=asrr.Expected_Order_Confirmation_Date__c;
                             idh.Exchange_Access_Date_EVC_PON__c=asrr.Service_Order_Due__c;
                             IDHMap.put(idh.Id,idh);
                         }
                     }
                 }
             }
         if(IDHMap.size()>0)
         {
             try
             {
                update IDHMap.values();   
             }
             Catch(Exception e)
             {
             }
         }  
                
    }
    
 public void ClearDHStatusIDHFields(SObject[] oldObjects)
 {
     List<DHStatus_ASR_Details__c> DeleteASRList=oldObjects;
     Map<String,DHStatus_ASR_Details__c> DHStatusASRMap=new  Map<String,DHStatus_ASR_Details__c>();        
     Map<Id,DHStatus_Update_IDH__c> IDHMap=new Map<Id,DHStatus_Update_IDH__c>();
      
     for(DHStatus_ASR_Details__c asr:DeleteASRList)
     {
         DHStatusASRMap.put(asr.DHStatus_Update_IDH__c,asr);
     } 
     
         if(DHStatusASRMap.size()>0 && DHStatusASRMap!=NULL)
         {
             for(DHStatus_Update_IDH__c idh:[select Id,Exchange_Access_Date_EVC_PON__c,Exchange_Access_Date_UNI_PON__c,Expected_FOC_Date_EVC_PON__c,Expected_FOC_Date_UNI_PON__c,Data_Type__c,UNI_PON__c,EVC_PON__c from DHStatus_Update_IDH__c WHERE Id IN:DHStatusASRMap.keySet()])
             {
                 if(idh.Data_Type__c=='Port')
                 {
                     idh.UNI_PON__c=NULL;
                     idh.Expected_FOC_Date_UNI_PON__c=NULL;
                     idh.Exchange_Access_Date_UNI_PON__c=NULL;
                     IDHMap.put(idh.Id,idh);
                 }
                 else if(idh.Data_Type__c=='Vlan')
                 {
                      idh.EVC_PON__c=NULL;
                      idh.Expected_FOC_Date_EVC_PON__c=NULL;
                      idh.Exchange_Access_Date_EVC_PON__c=NULL;
                      IDHMap.put(idh.Id,idh);
                 }
             }
         }
        if(IDHMap.size()>0)
        {
            try
            {
                update IDHMap.values();
            }
            Catch(Exception e)
            {
            }
        } 
     }   
}