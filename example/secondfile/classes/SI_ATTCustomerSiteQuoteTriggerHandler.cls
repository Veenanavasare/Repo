public class SI_ATTCustomerSiteQuoteTriggerHandler extends SITriggerOperations.SITriggerImpl{
    
     public boolean isExecuted ;

    //Default cons 
    public SI_ATTCustomerSiteQuoteTriggerHandler() 
    {
        isExecuted = true;
    }
    
    public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap){
        System.debug('@@@@@@onBeforeUpdate@@@@@');
        List<AT_T_Customer_Site_Quote__c> newobj = newObjects;
        List<AT_T_Customer_Site_Quote__c> oldobj = oldObjects;
        List<AT_T_Customer_Site_Quote__c> siteQuote = new List<AT_T_Customer_Site_Quote__c>();
        for(Integer i=0;i< newobj.size();i++){
            if(newobj[i].ASE_MACD_Site_Status__c != oldobj[i].ASE_MACD_Site_Status__c){
                siteQuote.add(newobj[i]) ;   
            }
        }
        if(siteQuote.size()>0){
            UpdateAVASRStatus(siteQuote);
        }       
        return isExecuted;    
    }
    
     //An Overridden method
    public override boolean onAfterInsert(SObject[] newObjects) 
    {
        try 
        {
             createSharingrule(newObjects);                      
         
        } 
        catch(Exception excep) 
        {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    /* Method to provide Sharing rules */    
    public static void createSharingrule(SObject[] newObjects){  
        
        List<AT_T_Customer_Site_Quote__c> attCustSiteList =  newObjects;
        Map<Id,Id> customerSiteAccountIdsMap = new Map<Id,Id>();
        for(AT_T_Customer_Site_Quote__c sp: attCustSiteList){
            if(!String.isEmpty(sp.Account_Name__c))
                customerSiteAccountIdsMap.put(sp.AT_T_Customer_Site__c,sp.Account_Name__c);
        }
        if(!Test.isRunningTest()){
        if(customerSiteAccountIdsMap.size()>0){
            SIHelper.createSPSharingPartnerRule(SIConstants.CUSTOMER_SITE_SHARE,customerSiteAccountIdsMap);
        }
        }
        
    }
    public void UpdateAVASRStatus(List<AT_T_Customer_Site_Quote__c> siteQuoteLst){
        Set<Id> proposalIdSet = new Set<Id>();
        Set<String> quoteIdSet = new Set<String>();
        Set<ID> siteIdSet = new Set<ID>();
        List<Apttus_Config2__ProductAttributeValue__c> AvRecordLst = new List<Apttus_Config2__ProductAttributeValue__c>();
        Map<String,String> asrStatMap = new Map<String,String>();
        List<Apttus_Config2__ProductConfiguration__c> configData = new List<Apttus_Config2__ProductConfiguration__c>();
        for(AT_T_Customer_Site_Quote__c sitequo : siteQuoteLst){
            System.debug('1111111111111111111111'+String.valueof(sitequo.AT_T_Quote__c).substring(0,15));
            proposalIdSet.add(sitequo.AT_T_Quote__c);
            quoteIdSet.add(String.valueof(sitequo.AT_T_Quote__c).substring(0,15));
            siteIdSet.add(ID.valueof(sitequo.AT_T_Customer_Site__c));
            String temp = String.valueof(sitequo.AT_T_Quote__c).substring(0,15)+ string.valueof(sitequo.AT_T_Customer_Site__c);
            asrStatMap.put(temp,sitequo.ASE_MACD_Site_Status__c);
        }
        System.debug('@@@@@@proposalIdSet@@@@@'+proposalIdSet);
        System.debug('@@@@@@asrStatMap@@@@@'+asrStatMap);
        System.debug('@@@@@@siteIdSet@@@@@'+siteIdSet);
        System.debug('@@@@@@quoteIdSet@@@@@'+quoteIdSet);
        configData = [SELECT Id, Name, Apttus_QPConfig__Proposald__c,Apttus_Config2__Status__c FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c IN: proposalIdSet and Apttus_Config2__Status__c in('New','Saved','Finalized') order by createddate desc LIMIT 1];
        AvRecordLst = [select ASR_Status__c,AT_T_Customer_Site__c,QuoteId__c,id from Apttus_Config2__ProductAttributeValue__c where AT_T_Customer_Site__c IN: siteIdSet and QuoteId__c IN: quoteIdSet  and cartId__c =: configData[0].id];
        System.debug('@@@@@@AvRecordLst@@@@@'+AvRecordLst);
        System.debug('@@@@@@configData @@@@@'+configData );
        for(Apttus_Config2__ProductAttributeValue__c av: AvRecordLst){
        System.debug('@@@@@@av.AT_T_Customer_Site__c@@@@@'+av.AT_T_Customer_Site__c);
        System.debug('@@@@@@av.QuoteId__c@@@@@'+av.QuoteId__c);
            if(av.AT_T_Customer_Site__c != null && av.QuoteId__c != null){
                System.debug('@@@@@@asrStatMap.containskey@@@@@'+asrStatMap.containskey(av.QuoteId__c+av.AT_T_Customer_Site__c));
                if(asrStatMap.containskey(av.QuoteId__c+av.AT_T_Customer_Site__c)){
                    if(asrStatMap.get(av.QuoteId__c+av.AT_T_Customer_Site__c) == 'Pending-Pending'){
                        av.ASR_Status__c = 'MACD Pending';
                    }
                    else{
                        av.ASR_Status__c = asrStatMap.get(av.QuoteId__c+av.AT_T_Customer_Site__c);
                    }
                }
                System.debug('@@@@@@av.ASR_Status__c@@@@@'+av.ASR_Status__c);
            }
        
        }
        update AvRecordLst;
        System.debug('@@@@@@AvRecordLst update@@@@@'+AvRecordLst);
    }
}