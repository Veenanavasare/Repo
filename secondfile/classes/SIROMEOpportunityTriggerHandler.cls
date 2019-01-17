/**
* Class/Trigger  Name: SIROMEOpportunityTriggerHandler
* Author: Accenture
* Date: 29-May-2013
* Requirement # R-2123 
* Description: This is the trigger for ROMEOpportunity object
* Version History:1.1
*/

public with sharing class SIROMEOpportunityTriggerHandler extends SITriggerOperations.SITriggerImpl
{
	public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap) 
	{
		
        try 
        {
        	updateOpportunityCreditCheckStatus(oldObjects,updatedObjects);
        	
        }catch(Exception excep)        	
        {
            System.debug('Exception Caught :'+excep.getMessage()); 
			return false;
			throw excep;      
        } 
          return true; 	
     }
     
     // This function is to update the Credit Check Status Field.
     public void updateOpportunityCreditCheckStatus(SObject[] oldObjects, SObject[] updatedObjects)
     {
     	List <Rome_Opportunity__c> oldList= oldObjects;
     	List <Rome_Opportunity__c> newList= updatedObjects;
     	map<Id,String> optyMap= New map<Id,String>();
     	set<id> optyIdSet= New set <id>(); 
     	for(integer i=0;i<oldList.size();i++)
     	{
     		if(oldList[i].Credit_Check_Result__c!=newList[i].Credit_Check_Result__c)
     		{
     			optyMap.put(newList[i].Opportunity_Name__c,newList[i].Credit_Check_Result__c);
     			optyIdSet.add(newList[i].Opportunity_Name__c);    			
     		}
     	}
     	List <Opportunity> optyList= [select Id, Credit_Check_Status__c from Opportunity where Id IN:optyIdSet];
     	for(integer i=0;i<optyList.size();i++)
     	{
     		if((SIConstants.PASS).equalsIgnoreCase(optyMap.get(optyList[i].Id)))
     		{
     			optyList[i].Credit_Check_Status__c=SIConstants.CREDIT_CHECK_PASSED;
     		}
     		else if((SIConstants.FAIL).equalsIgnoreCase(optyMap.get(optyList[i].Id)))
     		{
     			optyList[i].Credit_Check_Status__c=SIConstants.CREDIT_CHECK_FAILED;
     		}
     	}
     	update optyList;
     }
}