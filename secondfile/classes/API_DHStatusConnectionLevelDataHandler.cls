/* Component Name :API_DHStatusConnectionLevelDataHandler     
Requirement/User Story Number : New IDH Structure    
Requirement Description:populating DHStatus-Update Deal Hash Details Fields
Component Author:Accenture IDC     
Created Date: 25th november 2014      
Version:1.0     
*/   
 
public with sharing class API_DHStatusConnectionLevelDataHandler extends SITriggerOperations.SITriggerImpl{
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
      
 /*    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] newObjects, Map<Id, SObject>  newObjectsMap){
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
 public void UpdateDHStatusUpdateDealHashDetailsFields(SObject[] newObjects)
     {
         List<DHStatus_Connection_Level_Data__c> DHStatusCLDList=newObjects;
         Set<String> IDHIdSet=new Set<String>();
         List<DHStatus_Update_IDH__c> IDHList=new List<DHStatus_Update_IDH__c>();
         Map<Id,DHStatus_Update_IDH__c> IDHMap=new Map<Id,DHStatus_Update_IDH__c>();
         for(DHStatus_Connection_Level_Data__c dcl:DHStatusCLDList)
         {
           
                 IDHIdSet.add(dcl.DHStatus_Update_IDH__c);
            
         }
            if(IDHIdSet.size()>0)
            {
              IDHList=[select Id,Data_Type__c,VLAN_V4_CER_IP_Address__c,VLAN_V4_LAN_Address_Mask__c,VLAN_V4_LAN_IP_Address__c,VLAN_V4_PER_IP_Address__c,VLAN_V4_WAN_Address_Mask__c,VLAN_V4_WAN_IP_Address__c,VLAN_V6_CER_IP_Address__c,VLAN_V6_LAN_Address_Mask__c,VLAN_V6_LAN_IP_Address__c,VLAN_V6_PER_IP_Address__c,VLAN_V6_WAN_Address_Mask__c,VLAN_V6_WAN_IP_Address__c from DHStatus_Update_IDH__c WHERE Id IN:IDHIdSet AND Data_Type__c='Vlan'];  
            } 
         if(IDHList.size()>0)
         {
             for(DHStatus_Update_IDH__c idh:IDHList)
             {
                 for(DHStatus_Connection_Level_Data__c dcld:DHStatusCLDList)
                 {
                     if(idh.Id==dcld.DHStatus_Update_IDH__c && idh.Data_Type__c=='Vlan')
                     {
                         idh.VLAN_V4_CER_IP_Address__c=dcld.V4_WAN_CER_IP_Address__c;
                         idh.VLAN_V6_CER_IP_Address__c=dcld.V6_WAN_CER_IP_Address__c;
                         
                         idh.VLAN_V4_PER_IP_Address__c=dcld.V4_WAN_PER_IP_Address__c;
                         idh.VLAN_V6_PER_IP_Address__c=dcld.V6WAN_PER_IP_Address__c;
                         
                         idh.VLAN_V4_WAN_IP_Address__c=dcld.V4_WAN_IP_Address__c;
                         idh.VLAN_V6_WAN_IP_Address__c=dcld.V6_WAN_IP_Address__c;
                         
                         idh.VLAN_V4_WAN_Address_Mask__c=dcld.V4_WAN_Address_Mask__c;
                         idh.VLAN_V6_WAN_Address_Mask__c=dcld.V6_WAN_Address_Mask__c;
                         
                         idh.VLAN_V4_LAN_IP_Address__c=dcld.V4_LAN_IP_Address__c;
                         idh.VLAN_V6_LAN_IP_Address__c=dcld.V6_LAN_IP_Address__c;
                         
                         idh.VLAN_V4_LAN_Address_Mask__c=dcld.V4_LAN_Address_Mask__c;
                         idh.VLAN_V6_LAN_Address_Mask__c=dcld.V6_LAN_Address_Mask__c;
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
             
         
         /*List<DHStatus_Connection_Level_Data__c> DHStatusCLDList=newObjects;
         Set<String> DHStatusUDHDIdSet=new Set<String>();
         Set<String> DHStatusUDHDPremiseSet=new Set<String>();
         List<DHStatus_Update_Deal_Hash_Details__c> DHStatusUDHDList=new List<DHStatus_Update_Deal_Hash_Details__c>();
         Map<Id,DHStatus_Update_Deal_Hash_Details__c> DHStatusUDHDMap=new Map<Id,DHStatus_Update_Deal_Hash_Details__c>();
         for(DHStatus_Connection_Level_Data__c dcl:DHStatusCLDList)
         {
             if(dcl.V4_WAN_CER_IP_Address__c!=NULL || dcl.V6_WAN_CER_IP_Address__c!=NULL || dcl.V4_WAN_PER_IP_Address__c!=NULL || dcl.V6WAN_PER_IP_Address__c!=NULL || dcl.V4_WAN_IP_Address__c!=NULL || dcl.V6_WAN_IP_Address__c!=NULL || dcl.V4_WAN_Address_Mask__c!=NULL || dcl.V6_WAN_Address_Mask__c!=NULL || dcl.V4_LAN_IP_Address__c!=NULL || dcl.V6_LAN_IP_Address__c!=NULL || dcl.V4_LAN_Address_Mask__c!=NULL || dcl.V6_LAN_Address_Mask__c!=NULL)
             {
                 DHStatusUDHDIdSet.add(dcl.DHStatus_Update_Deal_Hash_Detials_ID__c);
                 DHStatusUDHDPremiseSet.add(dcl.DHStatus_Update_Deal_Hash_Detail_Premise__c);
             }
             
         }
              
             if(DHStatusUDHDIdSet.size()>0 && DHStatusUDHDPremiseSet.size()>0)
          {
            DHStatusUDHDList=[select Id,Premise_Number__c,V4_CER_IP_Address__c,V6_CER_IP_Address__c,V4_PER_IP_Address__c,V6_PER_IP_Address__c,V4_WAN_IP_Address__c,V6_WAN_IP_Address__c,V4_WAN_Address_Mask__c,V6_WAN_Address_Mask__c,V4_LAN_IP_Address__c,V6_LAN_IP_Address__c,V4_LAN_Address_Mask__c,V6_LAN_Address_Mask__c from DHStatus_Update_Deal_Hash_Details__c WHERE Id IN:DHStatusUDHDIdSet AND Premise_Number__c IN:DHStatusUDHDPremiseSet];
          }
          
          if(DHStatusUDHDList.size()>0)
          {
              for(DHStatus_Update_Deal_Hash_Details__c dhud:DHStatusUDHDList)
              {
                  for(DHStatus_Connection_Level_Data__c dcld:DHStatusCLDList)
                  {
                      if(dhud.Id==dcld.DHStatus_Update_Deal_Hash_Detials_ID__c && dhud.Premise_Number__c == dcld.DHStatus_Update_Deal_Hash_Detail_Premise__c && dcld.DHStatus_Update_IDH_Data_Type__c == 'Vlan')
                       {
                           System.debug('i am in');
                          dhud.V4_CER_IP_Address__c=dcld.V4_WAN_CER_IP_Address__c;
                          dhud.V6_CER_IP_Address__c=dcld.V6_WAN_CER_IP_Address__c;
                          dhud.V4_PER_IP_Address__c=dcld.V4_WAN_PER_IP_Address__c;
                          dhud.V6_PER_IP_Address__c=dcld.V6WAN_PER_IP_Address__c;                          
                          dhud.V4_WAN_IP_Address__c=dcld.V4_WAN_IP_Address__c;
                          dhud.V6_WAN_IP_Address__c=dcld.V6_WAN_IP_Address__c;
                          dhud.V4_WAN_Address_Mask__c=dcld.V4_WAN_Address_Mask__c;
                          dhud.V6_WAN_Address_Mask__c=dcld.V6_WAN_Address_Mask__c;
                          dhud.V4_LAN_IP_Address__c=dcld.V4_LAN_IP_Address__c;
                          dhud.V6_LAN_IP_Address__c=dcld.V6_LAN_IP_Address__c;
                          dhud.V4_LAN_Address_Mask__c=dcld.V4_LAN_Address_Mask__c;
                          dhud.V6_LAN_Address_Mask__c=dcld.V6_LAN_Address_Mask__c;
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
       } */
      }
  
  
  //deleting DHStatus Update Deal Hash Details Fields.
  public void ClearDHStatusUpdateDealHashFields(SObject[] oldObjects)
  {
       List<DHStatus_Connection_Level_Data__c> DeleteDHStatusCLDList=oldObjects; 
       Map<String,DHStatus_Connection_Level_Data__c> DeleteDHStatusCLDMap=new Map<String,DHStatus_Connection_Level_Data__c>();
       Map<Id,DHStatus_Update_IDH__c> IDHMap=new Map<Id,DHStatus_Update_IDH__c>();
       for(DHStatus_Connection_Level_Data__c dcl:DeleteDHStatusCLDList)
            {
                DeleteDHStatusCLDMap.put(dcl.DHStatus_Update_IDH__c,dcl);
            }
            
            if(DeleteDHStatusCLDMap!=NULL || !DeleteDHStatusCLDMap.isEmpty())
            {
               for(DHStatus_Update_IDH__c idh:[select Id,Data_Type__c,VLAN_V4_CER_IP_Address__c,VLAN_V4_LAN_Address_Mask__c,VLAN_V4_LAN_IP_Address__c,VLAN_V4_PER_IP_Address__c,VLAN_V4_WAN_Address_Mask__c,VLAN_V4_WAN_IP_Address__c,VLAN_V6_CER_IP_Address__c,VLAN_V6_LAN_Address_Mask__c,VLAN_V6_LAN_IP_Address__c,VLAN_V6_PER_IP_Address__c,VLAN_V6_WAN_Address_Mask__c,VLAN_V6_WAN_IP_Address__c from DHStatus_Update_IDH__c WHERE Id IN:DeleteDHStatusCLDMap.keySet() AND Data_Type__c='Vlan'])  
                {
                         idh.VLAN_V4_CER_IP_Address__c=NULL;
                         idh.VLAN_V6_CER_IP_Address__c=NULL;
                         
                         idh.VLAN_V4_PER_IP_Address__c=NULL;
                         idh.VLAN_V6_PER_IP_Address__c=NULL;
                         
                         idh.VLAN_V4_WAN_IP_Address__c=NULL;
                         idh.VLAN_V6_WAN_IP_Address__c=NULL;
                         
                         idh.VLAN_V4_WAN_Address_Mask__c=NULL;
                         idh.VLAN_V6_WAN_Address_Mask__c=NULL;
                         
                         idh.VLAN_V4_LAN_IP_Address__c=NULL;
                         idh.VLAN_V6_LAN_IP_Address__c=NULL;
                         
                         idh.VLAN_V4_LAN_Address_Mask__c=NULL;
                         idh.VLAN_V6_LAN_Address_Mask__c=NULL;
                         IDHMap.put(idh.Id,idh);
                    
                }
            }
            if(IDHMap.size()>0)
            {
               try
               { 
                Update IDHMap.values();
               }
               Catch(Exception e)
               {
               }
            }
        
        /*List<DHStatus_Connection_Level_Data__c> DeleteDHStatusCLDList=oldObjects;
        Map<String,DHStatus_Connection_Level_Data__c> DHStatusCLDMap=new  Map<String,DHStatus_Connection_Level_Data__c>();
        Map<Id,DHStatus_Update_Deal_Hash_Details__c> DHStatusUDHDMap=new Map<Id,DHStatus_Update_Deal_Hash_Details__c>();
        
            for(DHStatus_Connection_Level_Data__c dcl:DeleteDHStatusCLDList)
            {
                DHStatusCLDMap.put(dcl.DHStatus_Update_Deal_Hash_Detials_ID__c,dcl);
            }
            
                      
            if(DHStatusCLDMap!=NULL || !DHStatusCLDMap.isEmpty())
            {
                for(DHStatus_Update_Deal_Hash_Details__c udhd:[select Id,V4_CER_IP_Address__c,V6_CER_IP_Address__c,V4_PER_IP_Address__c,V6_PER_IP_Address__c,V4_WAN_IP_Address__c,V6_WAN_IP_Address__c,V4_WAN_Address_Mask__c,V6_WAN_Address_Mask__c,V4_LAN_IP_Address__c,V6_LAN_IP_Address__c,V4_LAN_Address_Mask__c,V6_LAN_Address_Mask__c from DHStatus_Update_Deal_Hash_Details__c WHERE Id IN:DHStatusCLDMap.keySet()])
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
           }*/                     
  }  
                           
   }