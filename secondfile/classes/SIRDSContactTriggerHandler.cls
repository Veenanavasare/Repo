/*****    
Component Name : SIRDSContactTriggerHandler 
Component Description: All RDS Contact Related methods and exceution can be called from this Handler. A generic trigger handler class for all the 
                      operations(Insert,Update,Delete and Undelete) which operates on 'Before/After'     
Author Name : Accenture IDC    
Version:1.0    
Created Date: 23rd June 2016 
*****/
    public with sharing class SIRDSContactTriggerHandler extends SITriggerOperations.SITriggerImpl {
        public boolean isExecuted;
        
        /***Constructor to exceute Trigger***/
        public SIRDSContactTriggerHandler(){
            isExecuted = true;
        }       
       
         /***An Overridden method***/
        public override boolean onAfterInsert(SObject[] newObjects) {
            List<RDS_Contact__c> newContactList = newObjects;            
            
            if(newContactList.size()>0){
                try {
                    createSharingrule(newObjects);
                    
                } catch(Exception excep) {
                    
                    isExecuted = false;
                    throw excep;
                }
            }       
            return isExecuted;
            
        }
        
        /****Method to call create share method for all SP Users' access to RDS Contacts****/
        public static void createSharingrule(SObject[] newObjects){
            try{
            List<RDS_Contact__c> rdsConList = newObjects; 
            Map<Id,Id> sObjRecordIds = new Map<Id,Id>();
            for(RDS_Contact__c rdsCon: rdsConList){
                if(!String.isEmpty(rdsCon.AccountId__c)){
                sObjRecordIds.put(rdsCon.Id,rdsCon.AccountId__c);
                }
            }
            if(sObjRecordIds.size()>0){
                SIHelper.createSPSharingPartnerRule(Constant.RdsContactShare,sObjRecordIds);
                }
            }
            catch(Exception e){
            }
    }
}