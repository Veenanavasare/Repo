/************************************************************************************** 
Apex Class Name     : ManageExistingNetworkSerInvContoller
Version             : 2.0  
Created Date        : 29th Mar 2017
Function            : ManageExistingNetworkSerInvContoller
*************************************************************************************/
global with sharing class ManageExistingNetworkSerInvContoller{
    public boolean enableAddSitesOption {get;set;}
    
    public ManageExistingNetworkSerInvContoller(){
        manageNetworkServicesOnload();
    }    
    
    /*
    Method Name: manageNetworkServicesOnload
    Method Description: This method is used MIS Add Sites Suppression
    Method Arguments:  
    Method Return Type: void
    Method Version: 1.0
    */ 
    public void manageNetworkServicesOnload(){
        enableAddSitesOption = [Select Id, MIS_Add_Sites_Suppression__c from Admin_Control__c LIMIT 1].MIS_Add_Sites_Suppression__c;
    }   
    
    
    /*
    Method Name: fetchDealHashAndPremiseRecords
    Method Description: This method is used to query AVPN,MIS and ASE deal hash
    Method Arguments:  
    Method Return Type: List<Deal_Hash__c>
    Method Version: 1.0
    */
    @RemoteAction
    global static List<Deal_Hash__c> fetchDealHashAndPremiseRecords() {
        try{
            User usr = new User();
            usr = [Select Id,ContactId FROM User WHERE id=:userinfo.getuserId()];
            Contact con = new Contact();
            if(usr.ContactId != null) {  
                con = [SELECT Id, AccountId FROM Contact WHERE Id=:usr.ContactId];
            }
            Id accId = con.AccountId;  
            String soql ='select End_Customer_Name__c, Sub_Account_Number__c,ContractEndDate__c, ServiceType__c, Number_of_Sites__c, Action__c, IsDealHashCreationSuccess__c, isBeginQuotePermission__c,ManualFlow__c,DH_Quote_Name__c,DH_Quote_Id__c,ASE_MACD_Lock__c,Contract_Renewal_Status__c, Contract_Renewal_Stage__c,Opportunity__r.Account_Contract_Renewal__c,IsEligibleForContract__c, Contract_Action_Tooltips__c, Contract_Renewal_Lock__c from Deal_Hash__c where Sub_Account_Number__c != null And Opportunity__r.AccountId =: accId And Number_of_Sites__c != 0 AND Eligible_Deal_Hash__c = TRUE AND Opportunity__r.ATOM_Deal__c = TRUE ';
            return Database.query(soql); 
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }  
    }   
}