/**
* Class/Trigger  Name: SITopicObjectTriggerHandler
* Author: Accenture
* Date: 14-Feb-2014
* Requirement # US181929
* Description: This is the Trigger handler class for Topic object.
* Version History: V 1.0
*/

public with sharing class SITopicObjectTriggerHandler extends SITriggerOperations.SITriggerImpl
{
	public boolean isExecuted ;

    //Default constructor
    public SITopicObjectTriggerHandler() 
    {
        isExecuted = true;
    }
    
    public override boolean onBeforeInsert(SObject[] updatedObjects)  
    {
        try 
        {
        	checkforNavigationLimitation(updatedObjects, updatedObjects, true);
        }
        catch(Exception excep) 
        {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    public override boolean onAfterInsert(SObject[] newObjects) 
    {
        try 
        {
            updateTopicsPicklistInNewsObject(newObjects, newObjects, true,false);
        } 
        catch(Exception excep) 
        {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    public override boolean onBeforeUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap )  
    {
        try 
        {
        	checkforNavigationLimitation(oldObjects, updatedObjects, false);
        } 
        catch(Exception excep) {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap) 
    {
        try 
        {
           updateTopicsPicklistInNewsObject(oldObjects, updatedObjects, false,false);
        } 
        catch(Exception excep) 
        {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    
    }
    
    public override boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap) 
    {
        try 
        {
           updateTopicsPicklistInNewsObject(oldObjects, oldObjects, false,true);
        } 
        catch(Exception excep) 
        {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    
    }
    
    //This is a method to handle update the Topic picklist values in using metadata API. This executes a Metadata API future callout.
    public void updateTopicsPicklistInNewsObject(SObject[] oldObjects, SObject[] newObjects, boolean isInsert, boolean isDelete)
    {
    	list <Topic__c> newTopicsList = newObjects;
    	list <Topic__c> oldTopicsList = oldObjects;
    	list <String> topicsList = new list <String>();
    	try
    	{
    		//This section handles insertion of Topic records.
	    	if(!newTopicsList.isEmpty() && newTopicsList!=null)
	    	{
	    		if(isInsert && !isDelete)
	    		{
		    		for(Topic__c tp: newTopicsList)
		    		{
		    			if(tp.Name != null && tp.Name != '' && tp.Topic_Status__c == 'Active')
		    			{
		    				topicsList.add(tp.Name);
		    			}
		    		}
	    		}
	    		
	    		//This section handles updates on Topic records.
	    		else if(!isInsert && !isDelete)
	    		{
	    			for(Integer i=0 ; i<newTopicsList.size() ; i++)
	    			{
	    				if((oldTopicsList[i].Name== null && newTopicsList[i].Name != null && newTopicsList[i].Topic_Status__c=='Active') || 
	    				(newTopicsList[i].Name != null && ((oldTopicsList[i].Topic_Status__c != newTopicsList[i].Topic_Status__c) || 
	    				(oldTopicsList[i].Name != null && oldTopicsList[i].Name !=newTopicsList[i].Name ))) || 
	    				oldTopicsList[i].Name!= null && newTopicsList[i].Name == null)
	    				{
	    					topicsList.add(newTopicsList[i].Name);
	    				}
	    			}
	    		}
	    		
	    		//This section handles deletion of Topic records.
	    		else if(!isInsert && isDelete)
	    		{
	    			for(Topic__c tp : oldTopicsList)
	    			{
	    				if(tp.Name != null && tp.Name != '' && tp.Topic_Status__c == 'Active')
		    			{
		    				topicsList.add(tp.Name);
		    			}
	    			}
	    		}
	    		  		
	    		if(!topicsList.isEmpty() && topicsList != null)
	    		{
	    			SIHelper.updateTopicsPickListMetadata(UserInfo.getSessionId());
	    		}
	    	}
    	}
    	catch (Exception e)
    	{
    		system.debug('Exception : '+e);
    	}
    }
    
    public void checkforNavigationLimitation(SObject[] oldObjects, SObject[] newObjects, boolean isInsert)
    {
    	list <Topic__c> oldTopicList = oldObjects;
    	list <Topic__c> newTopicList = newObjects;
    	Decimal countOfFeatured = 0;
    	Decimal countOfYes =0;
    	Decimal diffFeatured=3;
    	Decimal diffYes=15;
    	AggregateResult[] groupedResults = [SELECT Include_in_Nav__c,count(Id) countOfNav From Topic__c GROUP BY Include_in_Nav__c];
    	if(isInsert)
    	{
    		for(Topic__c tp : newTopicList)
    		{
    			if(tp.Include_in_Nav__c == 'Yes')
    			{
    				countOfYes+=1;
    			}
    			else if(tp.Include_in_Nav__c == 'Featured')
    			{
    				countOfFeatured+=1;
    			}
    		}
    	}
    	else
    	{
    		for(Integer i=0;i<newTopicList.size();i++)
    		{
    			if((newTopicList[i].Include_in_Nav__c != oldTopicList[i].Include_in_Nav__c) && newTopicList[i].Include_in_Nav__c== 'Yes')
    			{
    				countOfYes+=1;
    			}
    			else if((newTopicList[i].Include_in_Nav__c != oldTopicList[i].Include_in_Nav__c) && newTopicList[i].Include_in_Nav__c== 'Featured')
    			{
    				countOfFeatured+=1;
    			}
    		}
    	}
    	
    	if(!groupedResults.isEmpty() && groupedResults != null)
    	{
    		for(AggregateResult agr:groupedResults)
    		{
    			if(((String)(agr.get('Include_in_Nav__c'))).equalsIgnoreCase('Featured'))
    			{
    				diffFeatured = 3-((Decimal)agr.get('countOfNav'));
    			}
    			else if (((String)(agr.get('Include_in_Nav__c'))).equalsIgnoreCase('Yes'))
    			{
    				diffYes = 15 -((Decimal)agr.get('countOfNav'));
    			}
    		}
    	}
    	else
    	{
    		diffFeatured =3;
    		diffYes=15;
    	}
    	
    	if(countOfYes > diffYes)    
    	{
    		for(Topic__c tp:newTopicList)
    		{
    			if(tp.Include_in_Nav__c == 'Yes')
    			{
    				tp.Include_in_Nav__c.addError('Maximum 15 Topics can have Include in navigation value as Yes');
    			}
    		}
    	}
    	
    	if(countOfFeatured >diffFeatured)
    	{
    		for(Topic__c tp:newTopicList)
    		{
		    	if(tp.Include_in_Nav__c == 'Featured')
		    	{
		    		tp.Include_in_Nav__c.addError('Maximum 3 Topics can be marked as Featured');
	    		}
    		}	
    	}
    }
}