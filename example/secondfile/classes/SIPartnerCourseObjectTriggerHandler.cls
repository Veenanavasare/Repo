/**
* Class/Trigger  Name: SIPartnerCourseObjectTriggerHandler
* Author: Accenture
* Date: 22-Nov-2013
* Requirement # R-2440,R-2429
* Description: This is the Trigger handler class for Partner Course object. This handles all the triggers in Partner Course objec.
* Version History: v 1.0
* Version History: v 1.1 : Upadting NetExam entry criterias by usinng an Admin control object.
*/
public with sharing class SIPartnerCourseObjectTriggerHandler extends SITriggerOperations.SITriggerImpl
{
   public boolean isExecuted ;
   public Admin_Control__c adminControl;
    
    public SIPartnerCourseObjectTriggerHandler() 
    {
        isExecuted = true; 
        // SOQL query used to fetch Admin control record which will be used as an entry criteria for the below business logics.
        adminControl = [select Id, Course_Score__c from Admin_Control__c limit 1];
    }
    
    //The function to handle all the trigger actions to be peformed after insert
    public override boolean onAfterInsert(SObject[] newObjects) 
    {
        try 
        {
            updateProductTrainingsCompleted(newObjects,newObjects,false);
            updateProductTrainingCompletedonContact(newObjects,newObjects,false);
    
        }
        catch(Exception excep) 
        {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    //The function to handle all the trigger actions to be peformed after update 
    /*
    Name:onAfterUpdate
    Description:
    */
    public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap )
    {
        try
        {
            updateProductTrainingsCompleted(oldObjects,newObjects,true);
            updateProductTrainingCompletedonContact(oldObjects,newObjects,true);
        }
        catch(Exception e)
        {
            system.Debug('Exception here:'+e.getMessage());
            isExecuted=false;
            throw e;
        }
        return isExecuted;
    }
    
    //The function is to create a list of new Partner Course Id's which is created as completed status and expiration date is greater than today.
    /*
    Name:updateProductTrainingsCompleted
    Description:
    */
    public void updateProductTrainingsCompleted(SObject[] oldObjects,SObject[] newObjects,Boolean isUpdatedRecord)
    {
        list <Partner_Course__c> newCourseList = newObjects;
        list <Partner_Course__c> oldCourseList = oldObjects;
        set <Id> accountIds = new set <Id>();
        map<Id,boolean> accountOverrideMap = new map <Id,boolean>();
        list <Account> actList = new list <Account>();
        list <Partner_Course__c> listToProcess = new list <Partner_Course__c>();
        list <Partner_Course__c> oldListToProcess = new list <Partner_Course__c>();
        map <Id,String[]> accountProdMap= new map <Id,String[]>();  
        try
        {   
            for(Partner_Course__c pcs : newCourseList )
            {
                accountIds.add(pcs.Account__c);
            }
            if(accountIds != null && !accountIds.isEmpty())
            {
                actList = [SELECT Id,Product_Enablement_Override__c FROM Account WHERE Id IN : accountIds];
                if(!actList.isEmpty() && actList != null)
                {
                    for(Account ac: actList)
                    {
                        accountOverrideMap.put(ac.Id,ac.Product_Enablement_Override__c);
                    }
                }
            }
            if(!newCourseList.isEmpty()&& newCourseList != null && !accountOverrideMap.isEmpty() && accountOverrideMap != null)
            {
                if(!isUpdatedRecord)
                {
                    for(Partner_Course__c pc : newCourseList)
                    {
                        if(!accountOverrideMap.get(pc.Account__c))
                        {
                            if( pc.Course_Status__c != null && pc.Course_Expiration_Date__c != null && pc.Account__c != null && pc.Name__c != null && pc.Product__c != null && pc.Type__c != null && pc.Course_Score__c != null )
                            {
                                if( pc.Course_Status__c==SIConstants.PARTNER_COURSE_COMPLETED && pc.Course_Expiration_Date__c>System.Today() && pc.Course_Score__c >= adminControl.Course_Score__c )
                                {
                                    listToProcess.add(pc);
                                }
                            }
                        }
                    }
                }
                else
                {
                    for(integer i=0;i< newCourseList.size();i++)
                    {
                        if(!accountOverrideMap.get(newCourseList[i].Account__c))
                        {
                            if(newCourseList[i].Course_Status__c != null && newCourseList[i].Course_Expiration_Date__c != null && newCourseList[i].Account__c != null && newCourseList[i].Name__c != null && newCourseList[i].Type__c != null && newCourseList[i].Product__c != null && newCourseList[i].Course_Score__c != null )
                            {
                                if( (oldCourseList[i].Course_Status__c == null || oldCourseList[i].Course_Expiration_Date__c  == null || oldCourseList[i].Account__c == null || oldCourseList[i].Name__c == null || oldCourseList[i].Type__c == null || oldCourseList[i].Product__c == null || oldCourseList[i].Course_Score__c == null) && newCourseList[i].Course_Score__c >= adminControl.Course_Score__c )
                                {
                                    listToProcess.add(newCourseList[i]);
                                }
                                else
                                {
                                    if( (oldCourseList[i].Course_Status__c != newCourseList[i].Course_Status__c || oldCourseList[i].Course_Expiration_Date__c != newCourseList[i].Course_Expiration_Date__c ||oldCourseList[i].Account__c != newCourseList[i].Account__c || oldCourseList[i].Name__c != newCourseList[i].Name__c || oldCourseList[i].Type__c != newCourseList[i].Type__c || oldCourseList[i].Product__c != newCourseList[i].Product__c || oldCourseList[i].Course_Score__c != newCourseList[i].Course_Score__c) && newCourseList[i].Course_Score__c >= adminControl.Course_Score__c )
                                    {
                                        listToProcess.add(newCourseList[i]);
                                    }
                                    if( (oldCourseList[i].Product__c != newCourseList[i].Product__c || oldCourseList[i].Account__c != newCourseList[i].Account__c) && newCourseList[i].Course_Score__c >= adminControl.Course_Score__c )
                                    {
                                        oldListToProcess.add(oldCourseList[i]);
                                    }
                                }
                                
                            }
                            else if(newCourseList[i].Course_Status__c == null || newCourseList[i].Course_Expiration_Date__c == null || newCourseList[i].Account__c == null || newCourseList[i].Name__c == null || newCourseList[i].Type__c == null || newCourseList[i].Product__c == null )
                            {
                                if(oldCourseList[i].Course_Status__c != null && oldCourseList[i].Course_Expiration_Date__c  != null && oldCourseList[i].Account__c != null && oldCourseList[i].Name__c != null && oldCourseList[i].Type__c != null && oldCourseList[i].Product__c != null && newCourseList[i].Course_Score__c >= adminControl.Course_Score__c )
                                {
                                    listToProcess.add(oldCourseList[i]);
                                }
                            }
                        }
                    }
                }
                
                if(!oldListToProcess.isEmpty() && oldListToProcess != null)
                {
                    accountProdMap = SIHelper.createaccountProductMap(oldListToProcess);
                    if(!accountProdMap.isEmpty() && accountProdMap != null)
                    {
                        SIHelper.productEnablementAccountLevel(accountProdMap);
                    }
                    accountProdMap.clear();
                    oldListToProcess.clear();
                }
                if(!listToProcess.isEmpty() && listToProcess != null)
                {
                    accountProdMap = SIHelper.createaccountProductMap(listToProcess);
                    if(!accountProdMap.isEmpty() && accountProdMap != null)
                    {
                        SIHelper.productEnablementAccountLevel(accountProdMap);
                    }
                    accountProdMap.clear();
                    listToProcess.clear();
                }
            }   
        }
        catch (Exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }   
    }
    /*
    Name:updateProductTrainingCompletedonContact
    Description:
    */
    public void updateProductTrainingCompletedonContact(SObject[] oldObjects,SObject[] newObjects, boolean isUpdate)
    {
        try{
        list <Partner_Course__c> oldPCList =  oldObjects;
        list <Partner_Course__c> newPCList =  newObjects;
        map <Id,String[]> prodContactMap = new map <Id,String[]>();
        map <Id,String[]> removableProdContactMap = new map <Id,String[]>();
        list <Partner_Course__c> processList = new list <Partner_Course__c>();
        list <Partner_Course__c> removeList = new list <Partner_Course__c>();
        removeList.clear();
        processList.clear();
        if(!newPCList.isEmpty() && newPCList != null)
        {
            if(!isUpdate)
            {
                for(Partner_Course__c pc: newPCList)
                {
                    if(pc.Name__c != null && pc.Course_Status__c != null && pc.Course_Expiration_Date__c != null && pc.Product__c != null && pc.Type__c != null)
                    {
                        if(pc.Course_Status__c==SIConstants.PARTNER_COURSE_COMPLETED && pc.Course_Expiration_Date__c>System.Today())
                        {
                            processList.add(pc);
                        }
                    }
                }
            }
            else
            {
                for(Integer i = 0 ; i < newPCList.size() ; i++)
                {
                    if(newPCList[i].Name__c != null && newPCList[i].Course_Status__c != null && newPCList[i].Course_Expiration_Date__c != null && newPCList[i].Product__c != null)
                    {
                        if(oldPCList[i].Name__c == null || oldPCList[i].Course_Status__c == null || oldPCList[i].Course_Expiration_Date__c == null || oldPCList[i].Product__c == null)
                        {
                            if(newPCList[i].Course_Status__c==SIConstants.PARTNER_COURSE_COMPLETED && newPCList[i].Course_Expiration_Date__c>System.Today())
                            {
                                processList.add(newPCList[i]);
                            }
                            
                        }
                        else
                        {
                            if((oldPCList[i].Name__c!= newPCList[i].Name__c || oldPCList[i].Course_Status__c != newPCList[i].Course_Status__c || oldPCList[i].Course_Expiration_Date__c != newPCList[i].Course_Expiration_Date__c || oldPCList[i].Product__c != newPCList[i].Product__c) && newPCList[i].Course_Status__c==SIConstants.PARTNER_COURSE_COMPLETED && newPCList[i].Course_Expiration_Date__c>System.Today())
                            {
                                processList.add(newPCList[i]);
                                if(oldPCList[i].Name__c!= newPCList[i].Name__c || oldPCList[i].Product__c != newPCList[i].Product__c)
                                {
                                    removeList.add(oldPCList[i]);
                                }
                            }
                        }
                    }
                    else if(oldPCList[i].Name__c != null && oldPCList[i].Course_Status__c != null && oldPCList[i].Course_Expiration_Date__c != null && oldPCList[i].Product__c != null && oldPCList[i].Course_Status__c==SIConstants.PARTNER_COURSE_COMPLETED && (newPCList[i].Name__c == null || newPCList[i].Course_Status__c == null || newPCList[i].Course_Expiration_Date__c == null || newPCList[i].Product__c == null))
                    {
                        removeList.add(oldPCList[i]);
                    }
                }
            }
        }
        
        if(!removeList.isEmpty() && removeList != null && isUpdate)
        {
            removableProdContactMap = SIHelper.createContactProductMap(removeList);
            if(!removableProdContactMap.isEmpty() && removableProdContactMap != null)
            {
                SIHelper.removeInvalidCoursesFromContact(removableProdContactMap);
                removeList.clear();
                removableProdContactMap.clear();
            }
        }
        
        if(!processList.isEmpty() && processList != null)
        {
            prodContactMap= SIHelper.createContactProductMap(processList);
            if(!prodContactMap.isEmpty() && prodContactMap != null)
            {
                SIHelper.updateContactsWithProductTrainingsCompleted(prodContactMap);
                processList.clear();
                prodContactMap.clear();
            }
        }
        
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));

}
}
}