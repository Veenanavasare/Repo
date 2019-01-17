/* 
 Name:  SITaskTriggerHandler
 Type: Class 
 
 Description: 
 */ 
public with sharing class SITaskTriggerHandler extends SITriggerOperations.SITriggerImpl {
    /**/
     public boolean isExecuted ;

    //Default cons
/* 
 Name: SITaskTriggerHandler
 Description: 
 */ 
    public SITaskTriggerHandler() {
        isExecuted = true;
    }
    
    //@Overridden Method.
    
/* 
 Name: onAfterUpdate
 Description: 
 */ 
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap) {
        try {
                
             CopyTasksoLead(updatedObjects);
                
            
        } catch(Exception excep) {
          
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    //@Overridden Method.
    
/* 
 Name: onAfterInsert
 Description: 
 */ 
    public override boolean onAfterInsert(SObject[] updatedObjects) {
        try {
             CopyTasksoLead(updatedObjects);
        } catch(Exception excep) {
          
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
/* 
 Name: CopyTasksoLead
 Description: 
 */ 
    public void copyTasksoLead(SObject[] updatedObjects){
        
        List<Task> tasklist =updatedObjects;
        Set<Id> contactIDs = new Set<Id>();
        List<Task> createTasklist =new List<Task>();
        Map<ID,ID> leadContactMap=new Map<ID,ID>();
        Map<ID,String> leadRecordtypeMap =new Map<ID,String>();
        Map<ID,String> leadContactName =new Map<ID,String>();

    
    
        for (Task TL:Tasklist){
            if(TL.Status==UtilityConstant.COMPLETED){
                ContactIDs.add(TL.WhoId);
            }
        }
    
        List<Contact> contactlist =[select Id,Lead__c,RecordTypeId,Name from Contact where Id in :ContactIDs];   
    
        for(Contact C:Contactlist){
            LeadContactMap.put(C.Id,C.Lead__c);
            LeadRecordtypeMap.put(C.Id,C.RecordTypeId);
            LeadContactName.put(C.Id,C.Name);
        }
        
        Task clonedTask = null;
        
        for (Task TL:Tasklist){
            
            if(LeadRecordtypeMap.get(TL.WhoId)==System.label.Lead_Contact_Record_Type){
                clonedTask = TL.clone(false);
                if(clonedTask.Contact_name__c==null){
                    clonedTask.Contact_name__c=LeadContactName.get(TL.WhoId);
                }
                clonedTask.WhoId = LeadContactMap.get(TL.WhoId);
                CreateTasklist.add(clonedTask);
            }
        }
        
        try{
            insert CreateTasklist;
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        } 
    }

}