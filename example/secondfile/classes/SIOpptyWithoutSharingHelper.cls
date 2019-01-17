public without sharing class SIOpptyWithoutSharingHelper{

    public Boolean CheckDiffSpOpty(ID optyAccount ,String optyFuzzyEndCust,String optyEndCust ,String optyProdName,String optyAccName ,String Address,Date dt,String stageValue){
     List<Opportunity> Optylist = new List<Opportunity>();
     Optylist = [Select Id,Deal_Reg_Discount_Percentage__c, Account_Name__c, Service_type__c, EndCustomerName__c,End_Customer_Name__c, End_Customer_Address__c, EndCustomerCity__c, EndCustomerState__c, EndCustomerZip__c from Opportunity where AccountId != :optyAccount and ((End_Customer_Name__c = :optyFuzzyEndCust) or (EndCustomerName__c = :optyEndCust)) and Service_type__c = :optyProdName and Deal_Reg_Approval_Date__c > :dt and stageName not in(:stageValue) and End_Cust_Address__c =: Address order by Deal_Reg_Approval_Date__c ]   ;
     System.debug('Optylist ------------'+Optylist );
     if(Optylist != null && Optylist.size() > 0){
         return true;
     }  
     else{
         return false;
     }          
    }
}