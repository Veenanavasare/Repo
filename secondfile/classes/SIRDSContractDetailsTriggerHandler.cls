/*****
****************************************************************************************       
Component Name : SIRDSContractDetailsTriggerHandler 
Component Description: All RDS Contract Details Related methods and exceution can be called from this Handler. A generic trigger handler class for all the 
                      operations(Insert,Update,Delete and Undelete) which operates on 'Before/After'     
Author Name : Accenture IDC    
Version:1.0    
Created Date: 23rd June 2016     
****************************************************************************************
*****/
    public with sharing class SIRDSContractDetailsTriggerHandler extends SITriggerOperations.SITriggerImpl {
        public boolean isExecuted;
        /***Constructor to Execute Trigger***/
        public SIRDSContractDetailsTriggerHandler(){
            isExecuted = true;
        }       
       
         /***An Overridden method***/
        public override boolean onAfterInsert(SObject[] newObjects) {
            
           List<RDS_Contract_Details__c> newContractList = newObjects;        
            if(newContractList.size()>0){
                try {
                    createSharingrule(newObjects);
                    
                } catch(Exception excep) {
                    
                    isExecuted = false;
                    throw excep;
                }
            }       
            return isExecuted;
            
        }
        
        /****Method to call create share method for all SP Users' access to RDS Contract Details****/
        public static void createSharingrule(SObject[] newObjects){
            try{
            List<RDS_Contract_Details__c> rdsContractList = newObjects; 
            Map<Id,Id> sObjRecordIds = new Map<Id,Id>();
            for(RDS_Contract_Details__c rdsContract: rdsContractList){
                
                if(!String.isEmpty(rdsContract.RDS_Contract_Account_Id__c)){
                sObjRecordIds.put(rdsContract.Id,rdsContract.RDS_Contract_Account_Id__c);
                }
                
            }           
            if(sObjRecordIds.size()>0){
                SIHelper.createSPSharingPartnerRule(Constant.RdsContractDetailsShare,sObjRecordIds);
                }
            }
            catch(Exception e){
            }
    }
}