public with sharing class SI_EngagementObjectTriggerHandler extends SITriggerOperations.SITriggerImpl{

public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject> newObjectsMap)
    {
        try
        {
           CheckStatusActiveEngagement(updatedObjects);
        }
        catch (exception e)
        {
            System.debug('Exception : '+ e);
        }
        return true;
    } 
    public override boolean onAfterInsert(SObject[] newObjects)
    {
        try
        {
             CheckStatusActiveEngagement(newObjects);
        }
        catch (exception e)
        {
            System.debug('Exception : '+ e);
        }
        return true;
    }  
    //An Overridden method
    public override boolean onBeforeUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap) {
        try {
                updateEngagementFields(oldObjects,newObjects);
        }catch (exception e)
        {
            System.debug('Exception : '+ e);
        }
        return true;
    }
    public void CheckStatusActiveEngagement(SObject[] updatedObjects){
    Integer total_size=0;
    List<Engagement__c> EngagementList = updatedObjects;
    total_size=[select count() from Engagement__c where RecordType.Name ='Banner' AND Banner_Status__c='Active'];
    system.debug('*********************************');
    if(total_size>1){
            for(Engagement__c E:EngagementList){
              E.Banner_Status__c.adderror('Only one Engagement Record should have its Banner Status set as Active');
              system.debug('&&&&&&&&&&&');
              }
           }    
    }

//Business logic to update "Display On Landing Page" to false when status change from published to another status.
    public void updateEngagementFields(SObject[] oldObjects,SObject[] newObjects)
    {
        list<Engagement__c> oldList = oldObjects;
        list<Engagement__c> newList = newObjects;
        
        for (Integer i=0; i<newList.size(); i++)
        {
            if(oldList[i].Status__c == SIConstants.Engagement_Status_Published && newList[i].Status__c != SIConstants.Engagement_Status_Published && newList[i].Display_On_Landing_Page__c)
            {
                newList[i].Display_On_Landing_Page__c = false;
            }
        }
    }
}