/********************************************************************************************************************    
Component Name : ProposalLineItemTriggerHandler 
Component Description:  Trigger handler class for the Proposal Line Item Object 
Author Name : Accenture IDC    
Created Date: 6th September 2018 
*********************************************************************************************************************/
public with sharing class ProposalLineItemTriggerHandler extends SITriggerOperations.SITriggerImpl{
    public boolean isExecuted;
    
    /***Constructor to execute Trigger***/    
    public ProposalLineItemTriggerHandler(){
        isExecuted = true;
    }
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  oldObjectsMap) {
        try{
            List<Apttus_Proposal__Proposal_Line_Item__c> updatedProposalLineItemObjList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
            if(updatedObjects!=null){
                updatedProposalLineItemObjList = updatedObjects;
            }
            for(Apttus_Proposal__Proposal_Line_Item__c  updateObj : updatedProposalLineItemObjList){
                if(updateObj.Apttus_QPConfig__AttributeValueId__c==NULL) {
                    list<Apttus_Config2__ProductConfiguration__c> productConfigurationList = new list<Apttus_Config2__ProductConfiguration__c>();
                    productConfigurationList=[select id,Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c=:updateObj.Apttus_Proposal__Proposal__c order by CreatedDate desc LIMIT 1];
                    system.debug('@@@^productConfigurationList--'+productConfigurationList);  
                    if(productConfigurationList.size()>0){
                        system.debug('@testtest');
                        ApttusServiceUtilityHelper helper = new ApttusServiceUtilityHelper();
                        helper.finalizeCart(productConfigurationList[0].id);
                        Exception__c exp = new  Exception__c();
                        exp.Name = 'Missing speed-pricing schedule';
                        insert exp;
                        //Apttus_Proposal__Proposal_Line_Item__c lineItem=updateObj[0];
                        //List<Apttus_Config2__ProductConfiguration__c> upLineItemList = new List<Apttus_Config2__ProductConfiguration__c>();
                        //upLineItemList=[select id,Is_Executed__c from Apttus_Config2__ProductConfiguration__c where id = :productConfigurationList[0].id];
                        //upLineItemList[0].Is_Executed__c=True;
                        //system.debug('@@@upLineItemList[0].Is_Executed__c' + upLineItemList[0].Is_Executed__c);
                        //system.debug('@@@upLineItemList[0].id' + upLineItemList[0].id);
                        //upLineItemList.add(upLineItemList[0]);
                        //update upLineItemList;
                    }
                }
            }
        }catch(Exception e){
            system.debug('----line no ---'+e.getLinenumber());
        }
        return null;
    }
}