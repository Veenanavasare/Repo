/*
*****************************************************************************************************************        
Component Name : SI_ATTProductAttributeValueTrigger 
Author Name : Accenture IDC    
Version: 1.0  
Description :
****************************************************************************************************************
*/
public class  SI_ATTProductAttributeValueTrigger extends SITriggerOperations.SITriggerImpl 
{  
    public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap){
        try{            
            ApttusServiceUtilityHelper  helper= new ApttusServiceUtilityHelper();                      
            List<Apttus_Proposal__Proposal__c> quoteLst = new List<Apttus_Proposal__Proposal__c>();
            List<ID> quoteLstID = new List<ID>();
            List<Apttus_Config2__ProductAttributeValue__c> oldAVList=oldObjects;
            List<Apttus_Config2__ProductAttributeValue__c> newAVList=newObjects;
            Map<ID,Decimal> quoteLstMap = new Map<ID,Decimal >();
            
            List<Apttus_Config2__LineItem__c> lineItems=new List<Apttus_Config2__LineItem__c>();
            
            if((oldAVList[0].Tier__c!=null && newAVList[0].Tier__c!=null && !oldAVList[0].Tier__c.equals(newAVList[0].Tier__c)) && newAVList[0].ServiceType__c.equals('ASE Basic')){
                lineItems = [SELECT Id, Apttus_Config2__BasePrice__c,Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__r.Id, Apttus_Config2__LineNumber__c, AT_T_Customer_Site__c, isPricingApplied__c FROM Apttus_Config2__LineItem__c WHERE  Apttus_Config2__AttributeValueId__c=:newAVList[0].id];
            }
            if(lineItems!=null && lineItems.size()>0){
                helper.computePrice(lineItems[0].Apttus_Config2__ConfigurationId__c, Integer.valueOf(lineItems[0].Apttus_Config2__LineNumber__c) );
            }
            
            System.debug('newAVList===='+newAVList);
            System.debug('oldAVList===='+oldAVList);
            for(integer i = 0; i < newAVList.size();i++){
                if( newAVList[i].IGLOO_Retrial_Failure_Count__c != null && (oldAVList[i].IGLOO_Retrial_Failure_Count__c != newAVList[i].IGLOO_Retrial_Failure_Count__c)){
                    quoteLstMap.put(newAVList[i].QuoteId__c,newAVList[i].IGLOO_Retrial_Failure_Count__c);
                }
            }
            
            if(quoteLstMap != null && quoteLstMap.size()>0){
                quoteLst = [SELECT id, RetrialFailure__c from Apttus_Proposal__Proposal__c where id In: quoteLstMap.keyset()];
            } 
            System.debug('quoteLst===='+quoteLst);
             System.debug('quoteLstMap===='+quoteLstMap);
            if(quoteLst != null && quoteLst.size()>0){
              for(Apttus_Proposal__Proposal__c quo :quoteLst){
                System.debug('quoteLstMap===='+quoteLstMap);
                System.debug('quo.id===='+quo.id);
                if(quoteLstMap.containsKey(quo.id)){
                    if(quoteLstMap.get(quo.id) == 0){
                        quo.RetrialFailure__c = 0;
                    }
                    else{
                        quo.RetrialFailure__c = quo.RetrialFailure__c != null ? quo.RetrialFailure__c + 1 : 1;
                    }
                }
              }
              System.debug('quoteLst===='+quoteLst);
              update quoteLst;
            }
        }
        catch(Exception e){        
            system.debug('Exception in onAfterUpdate method of SI_ATTProductAttributeValueTrigger class '+e+ 'and line no is '+e.getLineNumber());
        }

        return true;
    }
}