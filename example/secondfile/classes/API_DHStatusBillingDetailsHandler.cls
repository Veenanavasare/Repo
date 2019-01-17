/* Component Name :API_DHStatusBillingUpdateDetailsHandler   
Requirement/User Story Number : Provisioning Milestone Report      
Requirement Description:Update DHStatus-Update Deal Hash Details Fields
Component Author:Accenture IDC     
Created Date: 25th november 2014      
Version:1.0     
*/   
 
public with sharing class API_DHStatusBillingDetailsHandler extends SITriggerOperations.SITriggerImpl{

public override boolean onAfterInsert(SObject[] newObjects){        
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
    public override boolean onBeforeDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap){        
         try{ 
             //ClearDHStatusUpdateDealHashFields(oldObjects);
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
//populating Circuit Billing Activation EffectiveDate,Circuit Competitive Discounts EfC Date on DHStatus-Update Deal Hash Details from DHStatus-Status Update Details  
public void UpdateDHStatusUpdateDealHashDetailsFields(SObject[] newObjects)
{
        List<DHStatus_Billing_Update_Details__c> DHStatusLPList=newObjects;
        Set<String> DHStatusUDHDIDSet=new Set<String>();
        Set<String> DHStatusUDHDPremiseNumberSet=new Set<String>();
        List<DHStatus_Update_Deal_Hash_Details__c> DHStatusUDHDList=new List<DHStatus_Update_Deal_Hash_Details__c>();        
        Map<Id,DHStatus_Update_Deal_Hash_Details__c> DHStatusUDHDMap=new Map<Id,DHStatus_Update_Deal_Hash_Details__c>();
        for(DHStatus_Billing_Update_Details__c bup:DHStatusLPList)
        {
           
                DHStatusUDHDIDSet.add(bup.DHStatusUpdateDealHashDetailsID__c);
                DHStatusUDHDPremiseNumberSet.add(bup.DHStatusUpdateDealHashPremiseNumber__c);
                
        }
                        
        if(DHStatusUDHDIDSet.size()>0 && DHStatusUDHDPremiseNumberSet.size()>0)
        {
            DHStatusUDHDList=[select Id,Premise_Number__c,Circuit_Billing_Activation_EffectiveDate__c,Circuit_Competitive_Discounts_EfC_Date__c from DHStatus_Update_Deal_Hash_Details__c WHERE Id IN:DHStatusUDHDIDSet AND Premise_Number__c IN:DHStatusUDHDPremiseNumberSet];
        } 
        if(DHStatusUDHDList.size()>0)
        {
            for(DHStatus_Update_Deal_Hash_Details__c udhd:DHStatusUDHDList)
            {
                for(DHStatus_Billing_Update_Details__c dhud:DHStatusLPList)
                {
                    if(udhd.Id==dhud.DHStatusUpdateDealHashDetailsID__c && udhd.Premise_Number__c==dhud.DHStatusUpdateDealHashPremiseNumber__c && dhud.DHStatus_IDH_Data_Type__c=='Port')
                        {
                          udhd.Circuit_Billing_Activation_EffectiveDate__c=dhud.Access_Billing_Details__c;
                          udhd.Circuit_Competitive_Discounts_EfC_Date__c=dhud.Competitive_Access_DiscountEffectiveDate__c;
                          DHStatusUDHDMap.put(udhd.Id,udhd);  
                        }
                    else if(udhd.Id==dhud.DHStatusUpdateDealHashDetailsID__c && udhd.Premise_Number__c==dhud.DHStatusUpdateDealHashPremiseNumber__c && dhud.DHStatus_IDH_Data_Type__c=='Billing')
                        {
                          udhd.Circuit_Billing_Activation_2_EfCDate__c=dhud.Access_Billing_Details__c; //GCS
                          udhd.Circuit_Competitive_Discounts_2_EfC_Date__c=dhud.Competitive_Access_DiscountEffectiveDate__c; //GCS
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
  
  //clear Corresponding DHStatusUpdateDealHash fields after deleting the DHStatus-Status Update Details
   public void ClearDHStatusUpdateDealHashFields(SObject[] oldObjects)
     {
        List<DHStatus_Billing_Update_Details__c> DeleteDHStatusBUList=oldObjects;
        Map<String,DHStatus_Billing_Update_Details__c> DHStatusBUMap=new  Map<String,DHStatus_Billing_Update_Details__c>();
        Map<Id,DHStatus_Update_Deal_Hash_Details__c> DHStatusUDHDMap=new Map<Id,DHStatus_Update_Deal_Hash_Details__c>();
        
            for(DHStatus_Billing_Update_Details__c dbu:DeleteDHStatusBUList)
            {
                DHStatusBUMap.put(dbu.DHStatusUpdateDealHashDetailsID__c,dbu);
                system.debug('--@@--'+DHStatusBUMap);
            }          
            if(DHStatusBUMap!=NULL || !DHStatusBUMap.isEmpty())
            {
                for(DHStatus_Update_Deal_Hash_Details__c udhd:[select Id,Premise_Number__c,Circuit_Billing_Activation_EffectiveDate__c,Circuit_Competitive_Discounts_EfC_Date__c, Circuit_Billing_Activation_2_EfCDate__c, Circuit_Competitive_Discounts_2_EfC_Date__c from DHStatus_Update_Deal_Hash_Details__c WHERE Id IN:DHStatusBUMap.keySet()])
                {
                    udhd.Circuit_Billing_Activation_EffectiveDate__c=NULL;
                    udhd.Circuit_Competitive_Discounts_EfC_Date__c=NULL;
                    udhd.Circuit_Billing_Activation_2_EfCDate__c=NULL; //GCS
                    udhd.Circuit_Competitive_Discounts_2_EfC_Date__c=NULL; //GCS
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