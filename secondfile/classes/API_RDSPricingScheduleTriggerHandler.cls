/*
     Component Name :API_RDSPricingScheduleTriggerHandler 
      Requirement/User Story Number :
     Requirement Description: 1. Update Rate Stability Date On SPProduct(assigning PE Signed Date) after RDSPricingScheduleRecord is Created
     Component Author:Accenture IDC
     Created Date:2nd july 2014 
     Version:1.0
     Last Modified By: Accenture IDC
    */
    
/* 
 Name: SITriggerOperations.SITriggerImpl
 Type: Class 
 
 Description: 
 */ 
public with sharing class API_RDSPricingScheduleTriggerHandler extends SITriggerOperations.SITriggerImpl{
    
   //// To be used for Future Before insert operations 
   /* public override boolean onBeforeInsert (SObject[] newObjects)
    {
        try
        {
          }
        catch (exception e)
        {
           e.getMessage();
        }
        return true;
    }*/
      

   /* 
   Name: SITriggerOperations.SITriggerImpl
   Description: To be used for Future After insert operations 
   */ 
    public override boolean onAfterInsert (SObject[] newObjects)
    {
        try
        {
          
          updateRateStabilitydateonspproduct(newObjects);
          pricingScheduleIndicatorOnOpportunity(newObjects);
          createSharingrule(newObjects);
          
        }
        catch (exception e)
        {
            e.getMessage();
        }
        return true;
    } 
    
    
    // To be used for Before Update Operations 
   /* public override boolean onBeforeUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap)
    {
        try
        {
           }
        catch (exception e)
        {
            e.getMessage();
        }
        return true;
    }  */
    
    
    /*To be used for Future After Update Operations*/ 
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] newObjects, Map<Id, SObject>  newObjectsMap)
    {
        try
        {           
        }
        catch (exception e)
        {
              e.getMessage();
        }
        return true;
    } 
   
 //Assigning PE Signed Date to Rate Stability Date on SPProduct after creating RDS_Pricing_Schedule Record is Created. 
 /*we are calling this method on after insert*/    
public void updateRateStabilitydateonspproduct(SObject[] newObjects)
{
 List<RDS_Pricing_Schedule_Detail__c> rdspricingschedulerecords=newObjects;
 Set<String> rdspricingdeals=new Set<String>();
 List<SPProduct__c> spproductrecords=new List<SPProduct__c>();
 Map<Id,SPProduct__c> pricingsppMap=new Map<Id,SPProduct__c>();
 Datetime Ratedate = DateTime.parse('7/13/2014 11:46 AM');
 
 if(rdspricingschedulerecords.size()>0)
  {
   for(RDS_Pricing_Schedule_Detail__c rpsd:rdspricingschedulerecords)
    {
      if(rpsd.PE_Sign_Date__c!=NULL && rpsd.Deal__c!=NULL)
      {
        rdspricingdeals.add(rpsd.Deal__c);
      }
      
    }
    
 if(rdspricingdeals.size()>0)
 {
  spproductrecords=[select Id,Deal__c,Rate_Stability_Date__c from SPProduct__c WHERE Deal__c IN:rdspricingdeals];
 }
 if(spproductrecords.size()>0)
 {
     for(SPProduct__c spp:spproductrecords)
     {
       for(RDS_Pricing_Schedule_Detail__c rps:rdspricingschedulerecords)
       {
         if(spp.Deal__c!=NULL && spp.Deal__c == rps.Deal__c)
         {
           if(rps.PE_Sign_Date__c>Ratedate){
           spp.Rate_Stability_Date__c=rps.PE_Sign_Date__c;
           pricingsppMap.put(spp.Id,spp);
         }
         else
         {
            spp.Rate_Stability_Date__c=Ratedate;
            pricingsppMap.put(spp.Id,spp);
         }
       }
       }
     } 
 }
 
if(pricingsppMap.size()>0)
 {
  try{
    update pricingsppMap.values();
  }Catch(DMLException e)
  {
   e.getMessage();
  }
 }     
  }
}
 /*pricingScheduleIndicatorOnOpportunity*/
   public void pricingScheduleIndicatorOnOpportunity (SObject[] newObjects)
   {
      List<Opportunity> oppty = new list<Opportunity>();  
      Set<String> pricingschedule = new Set<String>();     
      List<RDS_Pricing_Schedule_Detail__c> rdsList = newObjects;
      if(RdsList.size()>0)
        {
          for(RDS_Pricing_Schedule_Detail__c rpsd : RdsList )
           {
           if(rpsd.Deal__c!=NULL)
             {
               pricingschedule.add(rpsd.Deal__c);
             }
      
         }
    if(pricingschedule.size()>0)
     {
         oppty = [select Id,Pricing_Schedule_Indicator__c from Opportunity WHERE id IN:pricingschedule];
     }      
         
 if(oppty.size()>0)
 {    
 for(Opportunity opp: oppty){
       for(RDS_Pricing_Schedule_Detail__c rps:RdsList )
       {
         if(rps.Deal__c == opp.Id)
         {
          
           opp.Pricing_Schedule_Indicator__c = True;
           
           }
         
          }
       }      
     } 
   }     
 if(oppty.size()>0)
 {
  try{
    update oppty;
  }Catch(DMLException e)
  {
   e.getMessage();
  }
 } 
 
 }

     /* 
     Name: createSharingrule
     Description: Method to call create share method for all SP Users' access to RDS-Pricing Schedule records
     */ 
     public static void createSharingrule(SObject[] newObjects){
            try{
            List<RDS_Pricing_Schedule_Detail__c> rdspricingList = newObjects; 
            Map<Id,Id> sObjRecordIds = new Map<Id,Id>();       
            for(RDS_Pricing_Schedule_Detail__c rdsp: RdspricingList){
                if(!String.isEmpty(rdsp.RDS_Pricing_Schedule_AccountId__c)){
                sObjRecordIds.put(rdsp.Id,rdsp.RDS_Pricing_Schedule_AccountId__c);
                }
            }
            if(sObjRecordIds.size()>0){
                SIHelper.createSPSharingPartnerRule('RDS_Pricing_Schedule_Detail__share',sObjRecordIds);
                }
            }
            catch(Exception e){
            }
         }
     
 }