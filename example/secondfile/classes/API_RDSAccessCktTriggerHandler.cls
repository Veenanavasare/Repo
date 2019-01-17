/*
     Component Name :API_RDSAccessCktTriggerHandler 
      Requirement/User Story Number :US319209 
     Requirement Description:Populate PortId on VLAN Info object as Lookup to PortId in Access Circuit ID
     Component Author:Accenture IDC
     Created Date:26th Sep 2014 
     Version:1.0
*/
    
/* 
 Name: API_RDSAccessCktTriggerHandler
 Type: Class 
 
 Description: 
 */ 
public with sharing class API_RDSAccessCktTriggerHandler extends SITriggerOperations.SITriggerImpl{
   
   /* public override boolean onBeforeInsert (SObject[] newObjects)
    {
        try
        {         
            populatePortIdOnVLaN(newObjects);    
        }
        catch (exception e)
        {
           e.getMessage();
        }
        return true;
    } */
    
     /* 
     Name: MACD_ReviewRequestPanelBuilder
     Description: To be used for Future after insert operations 
     */  
    public override boolean onAfterInsert (SObject[] newObjects)
    {
        try
        {
             populatePortIdOnVLaN(newObjects);         
        }
        catch (exception e)
        {
            e.getMessage();
        }
        return true;
    } 
    
     /* 
     Name: MACD_ReviewRequestPanelBuilder
     Description: To be used for Future After Update Operations  
     */  
    public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] updatedObjects,Map<Id, SObject>  OldObjectsMap)
    {
        try
        {
             populatePortIdOnVLaN(updatedObjects);       
        }
        catch (exception e)
        {
              e.getMessage();
        }
        return true;
    }

 /* User story:US319209 Lookup to PortId in Access Circuit ID */
  
    /* 
     Name: populatePortIdOnVLaN
     Description: 
     */ 
  public void populatePortIdOnVLaN(SObject[] newObjects){
      try{
          List<RDS_Access_Circuit_ID__c> newAccessCktIDList = newObjects;
          List<VLAN_Information__c> listOfVLAN= new List<VLAN_Information__c>();
          List<VLAN_Information__c> listOfVLANToBeUpdated= new List<VLAN_Information__c>();
          Set<Id> setOfVlanId = new Set<Id>();
          
          for(RDS_Access_Circuit_ID__c acc :newAccessCktIDList ){  
              setOfVlanId.add(acc.Circuit_and_VLAN_Details__c);
          }
          
          if(setOfVlanId.size()>0){
            listOfVLAN =[Select Id,PortID__c,Circuit_and_VLAN_Details__c From VLAN_Information__c Where Circuit_and_VLAN_Details__c IN: setOfVlanId];                   
          }
          if(listOfVLAN.size()>0){
              for(VLAN_Information__c vlaninfo : listOfVLAN )
              {
                  for(RDS_Access_Circuit_ID__c accId : newAccessCktIDList){
                      if(vlaninfo.Circuit_and_VLAN_Details__c == accId.Circuit_and_VLAN_Details__c){
                         vlaninfo.PortID__c = accId.PortID__c; 
                         listOfVLANToBeUpdated.add(vlaninfo); 
                      }
                  }   
              }   
          }  
          
            try{
                update listOfVLANToBeUpdated;
            }
            catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }  
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
  } 
}