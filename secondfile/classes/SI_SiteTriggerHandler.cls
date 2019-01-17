/**
* Class/T rigger  Name: SI_SiteTriggerHandler
* Author: Accenture
* Date: 28-Aug-2013
* Requirement # R-2339
* Description: This is the Trigger handler class for Site object, this can be re-used when any trigger updations required for Site object.
* Version History: V 1.0
*/
public with sharing class SI_SiteTriggerHandler extends SITriggerOperations.SITriggerImpl
{
    /*onAfterUpdate*/
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap)
    {
        try
        {
            updateProductSiteAddress(oldObjects,updatedObjects);
        }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                return null;
            }
        return true;
    }
     /*onAfterInsert*/
    public override boolean onAfterInsert (SObject[] newObjects)
    {
        try
        {
            isertSiteAddress(newObjects);
            return true;
       }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                return null;
            }
        
    }  
    
    /*This function is to update the SPProduct record once corresponding site record has been updated*/
    public void updateProductSiteAddress( SObject[] oldObjects, SObject[] updatedObjects )
    {
        list <Site__c> oldList = oldObjects;
        list <Site__c> updatedList = updatedObjects;
        list <SPProduct__c> prodList = new list <SPProduct__c>();
        map <Id,String> prodAddressMap = new map <Id,String>();
        try
        {
            if(!updatedList.isEmpty()&&updatedList!=null)
            {
                for (integer i=0;i<updatedList.size();i++)
                {
                    if(updatedList[i].Address__c!=oldList[i].Address__c || updatedList[i].City__c != oldList[i].City__c || updatedList[i].Zip__c != oldList[i].Zip__c || updatedList[i].State__c!= oldList[i].State__c )
                    {
                        prodAddressMap.put(updatedList[i].SPProduct__c,generateSiteAddress(updatedList[i]));                
                    }
                }
            }
            
            if ( !prodAddressMap.isEmpty() && prodAddressMap!=null && prodAddressMap.size() > 0 )
            {           
                prodList = [SELECT Id,Site_Address__c FROM SPProduct__c sp WHERE sp.Id IN :prodAddressMap.keyset()];
                
                if(!prodList.isEmpty() && prodList != null)
                {
                    for(integer i=0;i<prodList.size();i++)
                    {
                        prodList[i].Site_Address__c = prodAddressMap.get(prodList[i].Id);
                    }
                    update prodList;
                }
            }
        }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                
            }
    }
    
    /*This function return concatenates the Address, City, State, Zip with coma separated form.*/
    public String generateSiteAddress(Site__c siteRecord)
    {
        //String siteAddress = SpecialCharacterBuyFlowConstant.CONCAT+siteRecord.Address__c+SpecialCharacterBuyFlowConstant.COMASPACE+siteRecord.City__c +SpecialCharacterBuyFlowConstant.COMASPACE+siteRecord.State__c +SpecialCharacterBuyFlowConstant.COMASPACE+siteRecord.Zip__c;
        String siteAddress = null;
        try
        {
            if(siteRecord.Address__c!=null)
            {
                siteAddress=siteRecord.Address__c;
            }
            if(siteRecord.City__c!=null)
            {
                if(siteAddress==null)
                {
                    siteAddress = siteRecord.City__c;
                }
                else
                {
                    siteAddress = siteAddress +SpecialCharacterBuyFlowConstant.COMASPACE+siteRecord.City__c;
                }
            }
            
            if(siteRecord.State__c != null)
            {
                if(siteAddress==null)
                {
                    siteAddress = siteRecord.State__c;
                }
                else
                {
                    siteAddress = siteAddress +SpecialCharacterBuyFlowConstant.COMASPACE+siteRecord.State__c;
                }
            }
            
            if(siteRecord.Zip__c != null)
            {
                if(siteAddress==null)
                {
                    siteAddress = siteRecord.Zip__c;
                }
                else
                {
                    siteAddress = siteAddress +SpecialCharacterBuyFlowConstant.COMASPACE+siteRecord.Zip__c;
                }
            }
       }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                return null;
            }
        return siteAddress;
    }
    
    
    /* This function is to update Site Address field in SPProduct when new site record has been created.*/
    public void isertSiteAddress(SObject[] newObjects)
    {
        list <Site__c> siteList = newObjects;
        list <SPProduct__c> prodList = new list <SPProduct__c>();
        map <Id,String> prodAddressMap = new map <Id,String>();
        
        try
        {
            if(!siteList.isEmpty() && siteList!= null)
            {
                for(Site__c st: siteList)
                {
                    prodAddressMap.put(st.SPProduct__c,generateSiteAddress(st));
                }
            }
            
            if ( !prodAddressMap.isEmpty() && prodAddressMap!=null && prodAddressMap.size() > 0 )
            {           
                prodList = [SELECT Id,Site_Address__c FROM SPProduct__c sp WHERE sp.Id IN :prodAddressMap.keyset()];
                
                if(!prodList.isEmpty() && prodList != null)
                {
                    for(integer i=0;i<prodList.size();i++)
                    {
                        prodList[i].Site_Address__c = prodAddressMap.get(prodList[i].Id);
                    }
                    update prodList;
                }
            }
        }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                
            }
    }
}