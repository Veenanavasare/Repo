/* Component Name :API_DHStatusProvisioningTriggerHandler   
 Requirement/User Story Number : Provisioning Milestone Report      
Requirement Description:Update DHStatus-Update Deal Hash Details Fields
Component Author:Accenture IDC     
Created Date: 25th november 2014      
Version:1.0     
*/    
public with sharing class API_DHStatusProvisioningHandler extends SITriggerOperations.SITriggerImpl{
/*method*/
public override boolean onAfterInsert (SObject[] newObjects){        
         try{ 
            UpdateDHStatusUpdateDealHashDetailsFields(newObjects);
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
/*populating Port Billing Activation Effective Date,Port Competitive Discounts EffectiveDate on DHStatus-Update Deal Hash Details from DHStatus Provisioning Billing Details  */
public void updateDHStatusUpdateDealHashDetailsFields(SObject[] newObjects)
{
        List<DHStatus_Provisioning_Billing_Details__c> dHStatusLPList=newObjects;
        Set<String> dHStatusUDHDIDSet=new Set<String>();
        Set<String> dHStatusUDHDPremiseNumberSet=new Set<String>();
        List<DHStatus_Update_Deal_Hash_Details__c> dHStatusUDHDList=new List<DHStatus_Update_Deal_Hash_Details__c>();        
        Map<Id,DHStatus_Update_Deal_Hash_Details__c> dHStatusUDHDMap=new Map<Id,DHStatus_Update_Deal_Hash_Details__c>();
        for(DHStatus_Provisioning_Billing_Details__c dlp:DHStatusLPList)
        {
         
                DHStatusUDHDIDSet.add(dlp.DHStatusUpdateDealHashDetailsID__c);
                DHStatusUDHDPremiseNumberSet.add(dlp.DHStatusUpdateDealHashPremiseNumber__c);
                
        }
                        
        if(DHStatusUDHDIDSet.size()>0 && DHStatusUDHDPremiseNumberSet.size()>0)
        {
            DHStatusUDHDList=[select Id,Premise_Number__c,Port_Billing_Activation_Effective_Date__c,Port_Competitive_Discounts_EffectiveDate__c from DHStatus_Update_Deal_Hash_Details__c WHERE Id IN:DHStatusUDHDIDSet AND Premise_Number__c IN:DHStatusUDHDPremiseNumberSet];
        } 
        if(DHStatusUDHDList.size()>0)
        {
            for(DHStatus_Update_Deal_Hash_Details__c udhd:DHStatusUDHDList)
            {
                for(DHStatus_Provisioning_Billing_Details__c dlpp:DHStatusLPList)
                {
                    if(udhd.Id==dlpp.DHStatusUpdateDealHashDetailsID__c && udhd.Premise_Number__c==dlpp.DHStatusUpdateDealHashPremiseNumber__c && dlpp.DHStatus_IDH_Data_Type__c=='Billing')
                        {
                          udhd.Port_Billing_Activation_Effective_Date__c=dlpp.Effective_Date__c;
                          udhd.Port_Competitive_Discounts_EffectiveDate__c=dlpp.Competitive_Discount_Effective_Date__c;
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
          }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
      }         
  }

/*clear Corresponding DHStatusUpdateDealHash fields after deleting the logical provisioning */
   public void clearDHStatusUpdateDealHashFields(SObject[] oldObjects)
     {
       
        List<DHStatus_Provisioning_Billing_Details__c> deleteDHStatusPBList=oldObjects;
        Map<String,DHStatus_Provisioning_Billing_Details__c> dHStatusPBMap=new  Map<String,DHStatus_Provisioning_Billing_Details__c>();
        Map<Id,DHStatus_Update_Deal_Hash_Details__c> dHStatusUDHDMap=new Map<Id,DHStatus_Update_Deal_Hash_Details__c>();
        
            for(DHStatus_Provisioning_Billing_Details__c dpb:DeleteDHStatusPBList)
            {
                DHStatusPBMap.put(dpb.DHStatusUpdateDealHashDetailsID__c,dpb);
               
            }          
            if(DHStatusPBMap!=NULL || !DHStatusPBMap.isEmpty())
            {
                for(DHStatus_Update_Deal_Hash_Details__c udhd:[select Id,Premise_Number__c,Port_Billing_Activation_Effective_Date__c,Port_Competitive_Discounts_EffectiveDate__c from DHStatus_Update_Deal_Hash_Details__c WHERE Id IN:DHStatusPBMap.keySet()])
                {
                    udhd.Port_Billing_Activation_Effective_Date__c=NULL;
                    udhd.Port_Competitive_Discounts_EffectiveDate__c=NULL;
                    DHStatusUDHDMap.put(udhd.Id,udhd);
                }
            }
           if(DHStatusUDHDMap.size()>0)
           {
               try
               {
                   update DHStatusUDHDMap.values();
               }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
           }                            
      }      
 
}