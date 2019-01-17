/************************************************************************************** 
Apex Class Name     : PortalDesignController
Version             : 1.0 
Created Date        : 20 April 2018
Function            : Controller for Portal Design Pages
*************************************************************************************/
public with sharing class PortalDesignController{
    public Boolean isAVPN{get;set;}
    public Boolean isMIS{get;set;}
    public Boolean isIPFLEX{get;set;}
    public Boolean isASE{get;set;}
    public Boolean isAIA{get;set;}  
    public Boolean isANIRA{get;set;}
    public Boolean isFlexWare{get;set;}
    public Boolean isWirelessProduct{get;set;}
    
    /*Class Constructor*/
    public PortalDesignController(){    
        isAVPN=false;
        isMIS=false;
        isIPFLEX=false;
        isASE=false;
        isAIA=false;
        isANIRA=false;        
        isFlexWare=false;
        isWirelessProduct = false;
                
        User userObj = new User();
        Contact contObj;
        Account accObj;
        userObj = [select id, ContactId from User where id = :UserInfo.getUserId()];
        if(userObj != null && userObj.ContactId != null){
            contObj = [Select id, accountId from Contact where Id = :userObj.ContactId];
            if(contObj != NULL){
                accObj = [select Id,isAVPN__c,isMIS__c,IPFlex_Product__c,ASE_Product__c,AIA_Product__c,ANIRA_Product__c,Flexware_Product_Page__c,Wireless_Product__c from Account where Id =: contObj.accountId];
                if(accObj != null){
                    isAVPN = (accObj.isAVPN__c) ? true : false;
                    isMIS = (accObj.isMIS__c) ? true : false;
                    isIPFLEX = (accObj.IPFlex_Product__c) ? true : false;
                    isASE = (accObj.ASE_Product__c) ? true : false;
                    isAIA = (accObj.AIA_Product__c) ? true : false;
                    isANIRA= (accObj.ANIRA_Product__c) ? true : false;
                    isFlexWare = (accObj.Flexware_Product_Page__c) ? true : false;
                    isWirelessProduct = (accObj.Wireless_Product__c) ? true : false;
                }
            } 
        }        
    }
}