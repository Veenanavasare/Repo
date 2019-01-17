/* Component Name :API_DHStatusEthernetTriggerHandler      
Requirement/User Story Number : US311424      
Requirement Description:Update Field(Facility in Effect Date) on DHStatus-Update Deal Hash Details Object from DHStatus-Ethernet object
Component Author:Accenture IDC     
Created Date: 1st September 2014      
Version:1.0     
*/   
 
public with sharing class API_DHStatusCompletionDetailsHandler extends SITriggerOperations.SITriggerImpl{
    public override boolean onAfterInsert (SObject[] newObjects){        
         try{ 
            //String event = 'insert';
            //updateLECcircuitId(newObjects,event); 
            UpdateDHStatusIDHFields(newObjects);
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      } 
      
    /* public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] newObjects, Map<Id, SObject>  newObjectsMap){
            try{
                //updateProvisioningDates(newObjects);
               }        
            catch (exception e){ 
                   e.getMessage();        
             }
            return true;    
      }*/
      
     public override boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap){        
         try{ 
            //String event = 'delete';
            //updateLECcircuitId(oldObjects,event); 
            clearDHStatusIDHFields(oldObjects);
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      }  
     /*public void updateLECcircuitId(SObject[] newObjects,String event){
     List<DHStatus_Completion_Details__c> newCompList = newObjects;
     Map<Id,DHStatus_Completion_Details__c> compMap = new Map<Id,DHStatus_Completion_Details__c> (); 
     List<DHStatus_Update_IDH__c> idhList= new List<DHStatus_Update_IDH__c>(); 
     List<DHStatus_Update_IDH__c> idhListToUpdate= new List<DHStatus_Update_IDH__c>();
     List<DHStatus_Access_Test_Status_Details__c> accessList = new List<DHStatus_Access_Test_Status_Details__c>(); 
     //List<DHStatus_Completion_Details__c> listOfCompletion = new List<DHStatus_Completion_Details__c>();
     Set<Id> setofIdh = new Set<Id>();
         for(DHStatus_Completion_Details__c comp :newCompList){
             if(comp.Provider_Circuit_ID__c!=null){
                 compMap.put(comp.DHStatus_Update_Deal_Hash_Details__c,comp);    
             }        
         }
         if(compMap!=null || !compMap.isEmpty()){
             idhList = [Select id,LEC_Circuit_ID__c,Data_Type__c from DHStatus_Update_IDH__c where id in:compMap.keySet()];
             system.debug('idhList ....'+idhList );
             if(idhList.size()>0){
                 for(DHStatus_Update_IDH__c idh:idhList){
                 setofIdh.add(idh.id);
                 }
                 system.debug('setofIdh....'+setofIdh);
             }
             accessList = [Select id,Record_Type__c,DHStatus_Update_Deal_Hash_Details__c from DHStatus_Access_Test_Status_Details__c where DHStatus_Update_Deal_Hash_Details__c in: setofIdh and Record_Type__c = 'C'];
         }
         system.debug('accesslist....'+accessList);
         if(accessList.size()>0){
             for(DHStatus_Update_IDH__c idh:idhList){
                 for(DHStatus_Access_Test_Status_Details__c acc:accessList){
                     for(DHStatus_Completion_Details__c com:compMap.values()){
                         if(event == 'insert'){
                             if(com.Provider_Circuit_ID__c!=null && acc.DHStatus_Update_Deal_Hash_Details__c == com.DHStatus_Update_Deal_Hash_Details__c && com.DHStatus_Update_Deal_Hash_Details__c == idh.id && idh.Data_Type__c == 'Port'){
                                 system.debug('Hurrrayyyy!!');
                                 idh.LEC_Circuit_ID__c = com.Provider_Circuit_ID__c;
                                 idhListToUpdate.add(idh);
                             }
                         }
                         else if(event == 'delete'){
                             idh.LEC_Circuit_ID__c = '';
                             idhListToUpdate.add(idh);
                         }
                     }
                 }
                               
             }
                
         }
          if(idhListToUpdate.size()>0){
             try{
                 update idhListToUpdate;
             }
             catch(DMLException e){
                   e.getMessage();
             }
          }  
     }*/ 
public void UpdateDHStatusIDHFields(SObject[] newObjects)
{
    List<DHStatus_Completion_Details__c> DHStatusCDList=newObjects;
    Set<String> DHStatusIDSet=new Set<String>();
    List<DHStatus_Update_IDH__c> IDHList=new List<DHStatus_Update_IDH__c>();
    Map<Id,DHStatus_Update_IDH__c> IDHMap=new Map<Id,DHStatus_Update_IDH__c>();
    for(DHStatus_Completion_Details__c dhcd:DHStatusCDList)
    {
        if(dhcd.Provider_Circuit_ID__c!=NULL && dhcd.Record_Type__c=='C')
        {
            DHStatusIDSet.add(dhcd.DHStatus_Update_Deal_Hash_Details__c);
        }
    }
    
    if(DHStatusIDSet.size()>0)
    {
       IDHList=[select Id,LEC_Circuit_ID__c,Data_Type__c from DHStatus_Update_IDH__c WHERE Id IN:DHStatusIDSet]; 
    }
    if(IDHList.size()>0)
    {
        for(DHStatus_Update_IDH__c idh:IDHList)
        {
            for(DHStatus_Completion_Details__c cd:DHStatusCDList)
            {
                if(idh.id==cd.DHStatus_Update_Deal_Hash_Details__c && idh.Data_Type__c=='Port' && cd.Record_Type__c=='C')
                {
                    idh.LEC_Circuit_ID__c=cd.Provider_Circuit_ID__c;
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

public void clearDHStatusIDHFields(SObject[] oldObjects)
{
    List<DHStatus_Completion_Details__c> DeleteDHStatusCDList=oldObjects;
    Map<String,DHStatus_Completion_Details__c> DHCDMap=new Map<String,DHStatus_Completion_Details__c>();
    List<DHStatus_Update_IDH__c> IDHList=new List<DHStatus_Update_IDH__c>();
    Map<Id,DHStatus_Update_IDH__c> IDHMap=new Map<Id,DHStatus_Update_IDH__c>();
    for(DHStatus_Completion_Details__c dhcd:DeleteDHStatusCDList)
    {
        DHCDMap.put(dhcd.DHStatus_Update_Deal_Hash_Details__c,dhcd);
    }
    if(DHCDMap!=NULL && !DHCDMap.isEmpty())
    {
       IDHList=[select Id,LEC_Circuit_ID__c,Data_Type__c from DHStatus_Update_IDH__c WHERE Id IN:DHCDMap.keySet() AND Data_Type__c='Port']; 
    }
    if(IDHList.size()>0)
    {
        for(DHStatus_Update_IDH__c idh:IDHList)
        {
            for(DHStatus_Completion_Details__c dc:DeleteDHStatusCDList)
            {
                if(idh.id==dc.DHStatus_Update_Deal_Hash_Details__c && idh.Data_Type__c=='Port')
                {
                    idh.LEC_Circuit_ID__c=NULL;
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
}