/* Component Name :API_DHStatusPLGroupPortDataHandler  
Requirement/User Story Number : IDH New Derivation       
Requirement Description:Update DHStatus-Update Deal Hash Details Fields
Component Author:Accenture IDC     
Created Date: 25th november 2014      
Version:1.0     
*/   
 
public with sharing class API_DHStatusPLGroupPortDataHandler extends SITriggerOperations.SITriggerImpl{
// To be used for Future after insert operations     
     public override boolean onAfterInsert (SObject[] newObjects){        
         try{ 
                UpdateDHStatusDealHashDetialsFields(newObjects);
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      } 
      
    /* public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] newObjects, Map<Id, SObject>  newObjectsMap){
            try{
              
               }        
            catch (exception e){ 
                   e.getMessage();        
             }
            return true;    
      } */
      public override boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap){        
         try{ 
             ClearDHStatusUpdateDealHashFields(oldObjects);
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      }
  
//populating Corresponding DHStatus-Update Deal Hash Details Fields           
public void UpdateDHStatusDealHashDetialsFields(SObject[] newObjects)
    {
      List<DHStatus_PL_Group_Port_Data__c> DHStatusPLGPDList=newObjects;
      Set<String> DHStatusUDHDIdSet=new Set<String>();
      Set<String> DHStatusUDHDPremiseSet=new Set<String>();
      List<DHStatus_Update_Deal_Hash_Details__c> DHStatusUDHDList=new List<DHStatus_Update_Deal_Hash_Details__c>();
      Map<Id,DHStatus_Update_Deal_Hash_Details__c> DHStatusUDHDMap=new Map<Id,DHStatus_Update_Deal_Hash_Details__c>();
      for(DHStatus_PL_Group_Port_Data__c dhpl:DHStatusPLGPDList)
      {
        
              DHStatusUDHDIdSet.add(dhpl.DHStatus_Update_Deal_Hash_Detials_ID__c);
              DHStatusUDHDPremiseSet.add(dhpl.DHStatus_Update_Deal_Hash_Detail_Premise__c);
          
      }
          if(DHStatusUDHDIdSet.size()>0 && DHStatusUDHDPremiseSet.size()>0)
          {
            DHStatusUDHDList=[select Id,Premise_Number__c,V4_CER_IP_Address__c,V6_CER_IP_Address__c,V4_PER_IP_Address__c,V6_PER_IP_Address__c,V4_WAN_IP_Address__c,V6_WAN_IP_Address__c,V4_WAN_Address_Mask__c,V6_WAN_Address_Mask__c,V4_LAN_IP_Address__c,V6_LAN_IP_Address__c,V4_LAN_Address_Mask__c,V6_LAN_Address_Mask__c from DHStatus_Update_Deal_Hash_Details__c WHERE Id IN:DHStatusUDHDIdSet AND Premise_Number__c IN:DHStatusUDHDPremiseSet];
          }
          if(DHStatusUDHDList.size()>0)
          {
              for(DHStatus_Update_Deal_Hash_Details__c dhud:DHStatusUDHDList)
              {
                  for(DHStatus_PL_Group_Port_Data__c dhplg:DHStatusPLGPDList)
                  {
                      if(dhud.Id==dhplg.DHStatus_Update_Deal_Hash_Detials_ID__c && dhud.Premise_Number__c == dhplg.DHStatus_Update_Deal_Hash_Detail_Premise__c && dhplg.DHStatus_Update_IDH_Data_Type__c == 'GroupPort')
                       {
                          dhud.V4_CER_IP_Address__c=dhplg.V4_WAN_CER_IP_Address__c;
                          dhud.V6_CER_IP_Address__c=dhplg.V6_WAN_CER_IP_Address__c;
                          dhud.V4_PER_IP_Address__c=dhplg.V4_WAN_PER_IP_Address__c;
                          dhud.V6_PER_IP_Address__c=dhplg.V6_WAN_PER_IP_Address__c;                          
                          dhud.V4_WAN_IP_Address__c=dhplg.V4_WAN_IP_Address__c;
                          dhud.V6_WAN_IP_Address__c=dhplg.V6_WAN_IP_Address__c;
                          dhud.V4_WAN_Address_Mask__c=dhplg.V4_WAN_Address_Mask__c;
                          dhud.V6_WAN_Address_Mask__c=dhplg.V6_WAN_Address_Mask__c;
                          dhud.V4_LAN_IP_Address__c=dhplg.V4_LAN_IP_Address__c;
                          dhud.V6_LAN_IP_Address__c=dhplg.V6_LAN_IP_Address__c;
                          dhud.V4_LAN_Address_Mask__c=dhplg.V4_LAN_Address_Mask__c;
                          dhud.V6_LAN_Address_Mask__c=dhplg.V6_LAN_Address_Mask__c;
                          DHStatusUDHDMap.put(dhud.Id,dhud); 
                       }                       
                  }
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
  //deleting DHStatus Update Deal Hash Details Fields.
  public void ClearDHStatusUpdateDealHashFields(SObject[] oldObjects)
  {
         
        List<DHStatus_PL_Group_Port_Data__c> DeleteDHStatusPLGroupList=oldObjects;
        Map<String,DHStatus_PL_Group_Port_Data__c> DHStatusPLGroupMap=new  Map<String,DHStatus_PL_Group_Port_Data__c>();
        Map<Id,DHStatus_Update_Deal_Hash_Details__c> DHStatusUDHDMap=new Map<Id,DHStatus_Update_Deal_Hash_Details__c>();
        
            for(DHStatus_PL_Group_Port_Data__c dpl:DeleteDHStatusPLGroupList)
            {
                DHStatusPLGroupMap.put(dpl.DHStatus_Update_Deal_Hash_Detials_ID__c,dpl);
                
            }
            system.debug('#########' +DHStatusPLGroupMap);
               // system.debug('@@@@@@@@@' +dpl.DHStatus_Update_Deal_Hash_Detials_ID__c);
            
                      
            if(DHStatusPLGroupMap!=NULL || !DHStatusPLGroupMap.isEmpty())
            {
                for(DHStatus_Update_Deal_Hash_Details__c udhd:[select Id,V4_CER_IP_Address__c,V6_CER_IP_Address__c,V4_PER_IP_Address__c,V6_PER_IP_Address__c,V4_WAN_IP_Address__c,V6_WAN_IP_Address__c,V4_WAN_Address_Mask__c,V6_WAN_Address_Mask__c,V4_LAN_IP_Address__c,V6_LAN_IP_Address__c,V4_LAN_Address_Mask__c,V6_LAN_Address_Mask__c from DHStatus_Update_Deal_Hash_Details__c WHERE Id IN:DHStatusPLGroupMap.keySet()])
                {
                    udhd.V4_CER_IP_Address__c=NULL;
                    udhd.V6_CER_IP_Address__c=NULL;
                    udhd.V4_PER_IP_Address__c=NULL;
                    udhd.V6_PER_IP_Address__c=NULL;
                    udhd.V4_WAN_IP_Address__c=NULL;
                    udhd.V6_WAN_IP_Address__c=NULL;
                    udhd.V4_WAN_Address_Mask__c=NULL;
                    udhd.V6_WAN_Address_Mask__c=NULL;
                    udhd.V4_LAN_IP_Address__c=NULL;
                    udhd.V6_LAN_IP_Address__c=NULL;
                    udhd.V4_LAN_Address_Mask__c=NULL;
                    udhd.V6_LAN_Address_Mask__c=NULL;
                   
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