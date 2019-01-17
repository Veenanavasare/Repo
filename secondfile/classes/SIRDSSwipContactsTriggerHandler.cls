/*********************************
 * ******************************************************************************         
               Component Name : SIRDSSwipContactsTriggerHandler
               Component Description: All RDS Swip Contacts Related methods and exceution can be called from this Handler. A generic trigger handler class for all the 
                                      operations(Insert,Update,Delete and Undelete) which operates on 'Before/After'     
               Author Name : Accenture IDC    
               Version:1.0    
               Created Date: 23rd June 2016     
                    
     ****************************************************************************************************************
     */
    public with sharing class SIRDSSwipContactsTriggerHandler extends SITriggerOperations.SITriggerImpl {
        public boolean isExecuted;
        /***Constructor to exceute Trigger***/
        public SIRDSSwipContactsTriggerHandler(){
            isExecuted = true;
        }
         /***An Overridden method***/
        public override boolean onAfterInsert(SObject[] newObjects) {
            
            if(newObjects.size()>0){
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
            List<RDS_SWIP_Contacts__c> rdsConList = newObjects; 
            Map<Id,Id> sObjRecordIds = new Map<Id,Id>();
            for(RDS_SWIP_Contacts__c rdsSwip: rdsConList){
                if(!String.isEmpty(rdsSwip.RDS_Swip_Account_Id__c)){
                sObjRecordIds.put(rdsSwip.Id,rdsSwip.RDS_Swip_Account_Id__c);
                }
            }
            if(sObjRecordIds.size() > 0){
                SIHelper.createSPSharingPartnerRule('RDS_SWIP_Contacts__share',sObjRecordIds);
                }
            }
            catch(Exception e){
            }
    }
}