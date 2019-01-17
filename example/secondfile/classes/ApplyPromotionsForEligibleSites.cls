/*************************************************************************************************** 
 Apex Class Name     : ApplyPromotionsForEligibleSites
 Version             : 1.0
 Created Date        : 25 October 2017
 Description         : Applying promotion for all the Eligible Sites
 Modified By         : 
 Modified Date       : 
***************************************************************************************************/

global class ApplyPromotionsForEligibleSites implements Database.Batchable<sObject> {
    
    global final list<Integer> lineNumbers;
    global final set<Id> IglooAvId ; 
    global final String cartId;
    global final Integer iglooAvSize; 
    global final list<Apttus_Config2__LineItem__c>  lineItems = new list<Apttus_Config2__LineItem__c>();
    global final String quoteId;
    global final string siteQuoteJunctionId; 
     
    global ApplyPromotionsForEligibleSites(list<Integer> lineNumbers, String cartId , set<id> IglooAvId ,list<Apttus_Config2__LineItem__c>  lineItems ,string quoteId){
        this.iglooAvSize = IglooAvId.size();
        this.lineNumbers = lineNumbers;
        this.cartId = cartId;
        this.IglooAvId = IglooAvId;
        this.lineItems.addAll(lineItems);
        this.quoteId = quoteId;
    }
    
    global ApplyPromotionsForEligibleSites(list<Integer> lineNumbers, String cartId , set<id> IglooAvId ,list<Apttus_Config2__LineItem__c>  lineItems ,string quoteId ,string siteQuoteJunctionId){
        this.iglooAvSize = IglooAvId.size();
        this.lineNumbers = lineNumbers;
        this.cartId = cartId;
        this.IglooAvId = IglooAvId;
        this.lineItems.addAll(lineItems);
        this.quoteId = quoteId;
        this.siteQuoteJunctionId = siteQuoteJunctionId;
    }
   
    /* 
    *Name: start
    *Description: This is the start method of the Batch Class, which is used to retrieve the records based on the query.
                  The list of retrieved records will be passed to the execute method for the further processing.
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        try{
            String Query = 'Select id,AT_T_Quote__c,Wireline_Promotion_Id_After__c, AT_T_Customer_Site__c,Wireline_Promotion_Id_Sorted__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c=:quoteId AND AT_T_Customer_Site__c IN (Select AT_T_Customer_Site__c FROM Apttus_Config2__LineItem__c  WHERE  Apttus_Config2__LineNumber__c IN: lineNumbers '+' and Apttus_Config2__ConfigurationId__c='+'\''+cartId+'\')';
            return Database.getQueryLocator(query);
        }
        catch( Exception ex ){    
            system.debug('@@Exception caught in ApplyPromotionsForEligibleSites : '+ex.getMessage()+' :Line number: '+ex.getlineNumber());  
            return null;
        } 
    }

    /* 
    *Name: execute
    *Description: This is the execute method of the Batch Class, which is used to process the records passed from the Start method.
    */  
    global void execute(Database.BatchableContext BC,List<AT_T_Customer_Site_Quote__c> customerJuncList){    
        System.debug('execute');  
        system.debug('@@@Customer Junc List: ' + customerJuncList);
        map<ID,ID> siteAVIDMap = new map<ID,ID>();
        list<Id> siteIdList = new list<Id>();
        List<Id> avIdLst = new list<Id>();
        for(Apttus_Config2__LineItem__c lineItem : lineItems){
            siteAVIDMap.put(lineItem.AT_T_Customer_Site__c , lineItem.Apttus_Config2__AttributeValueId__c);
        }
        for(AT_T_Customer_Site_Quote__c junc : customerJuncList){        
            ID avId = siteAVIDMap.get(junc.AT_T_Customer_Site__c);
            siteIdlist.add(junc.AT_T_Customer_Site__c);
            avIdLst.add(avId); 
        }
        
        PromotionQualifierUtil qualifier = new PromotionQualifierUtil();
        if(!Test.isRunningTest()){ 
            for(Id siteId:siteIdlist){
                qualifier.determinePromotionAtSiteLevel(siteId,quoteId);
            }
            qualifier.appliedPromotionsCalcuationList(quoteId, siteIdlist, avIDLst);
        }
        
        for(AT_T_Customer_Site_Quote__c junc : customerJuncList){
            list<Wireline_Promotion_Rules__c> wirelinePromoRuleList = new list<Wireline_Promotion_Rules__c>();
            WirelinePromoCalculationHelper wirelinePromoHelper = new WirelinePromoCalculationHelper();            
            Map<String,List<Wireline_Promotion_Rules__c>> junctionPromoRulesListMap = new Map<String,List<Wireline_Promotion_Rules__c>>();
            set<Id> promoIdSet = new set<Id>();
            List<String> promoIdTypeSet = new List<String>();
            AT_T_Customer_Site_Quote__c attQuoteSite = [select id, Wireline_Promotion_Id_Applied__c,  AT_T_Customer_Site__c ,Wireline_Promotion_Id_Sorted__c from  AT_T_Customer_Site_Quote__c  where id =:junc.id ];
            
            system.debug('@@@Wireline Promotion Id Applied for : '+attQuoteSite.Id + ':' +attQuoteSite.Wireline_Promotion_Id_Applied__c);
            if(promoIdTypeSet != null){
                if(attQuoteSite.Wireline_Promotion_Id_Applied__c != null){
                    promoIdTypeSet = attQuoteSite.Wireline_Promotion_Id_Applied__c.split(',');
                }
                for(String promo : promoIdTypeSet){
                     promoIdSet.add(ID.valueOf((promo.split('_')[0]).deleteWhiteSpace()));
                }
                wirelinePromoRuleList = [SELECT Id,Name,Active__c,Configured_Fields_After__c,Configured_Fields_Before__c,Configured_Fields_Number__c,Discount_Percentage__c,Display_Promotion_End_Date__c,Do_Not_Run__c,End_Date__c,Expiry_Notification__c,Field_Inputs__c,Field_input_values_JSON__c,For_Testing__c,Hierarchy__c,Priority_Number__c,Priority__c,Promotion_Certified_By__c,Promotion_Certified__c,Promotion_Name__c,Promotion_Notification__c,Promo_Configurator_Lookup__c,Promo_Configured_Fields__c,Promo_Type__c,Rank__c,Rule_Description__c,Selected_Fields__c,Select_Fields_Json__c,Stackable__c,Start_Date__c,Test_SP__c FROM Wireline_Promotion_Rules__c where id in: promoIdSet];                    
                system.debug('@@@WirelinePromoRuleList: ' + wirelinePromoRuleList);
                if(wirelinePromoRuleList !=null){
                    junctionPromoRulesListMap.put(String.valueOf(attQuoteSite.Id),wirelinePromoRuleList);
                    system.debug('@@@before calculatePromotions');              
                    wirelinePromoHelper.calculatePromotions(junctionPromoRulesListMap);
                    system.debug('@@@After calculatePromotions');
                }
            }
        } 
    }
    
    /* 
    *Name: finish
    *Description: This is the finish method of the Batch Class, which will be called once execute method is completed.
    */ 
    global void finish(Database.BatchableContext BC){
        System.debug('finish');
        Map<String,String> siteAndRegionMap = new Map<String,String>();
        for( Apttus_Config2__LineItem__c lineItem : lineItems ){         
            if(lineItem.Apttus_Config2__AttributeValueId__r.IGLOO_Speed_Unavailable__c == false && lineitem.Apttus_Config2__AttributeValueId__r.IGLOO_Call_Failure__c == false){         
                lineItem.isPricingApplied__c = true; 
            }
            lineItem.IsBatchUpdate__c = true;
            siteAndRegionMap.put(lineitem.AT_T_Customer_Site__r.id,lineitem.Apttus_Config2__AttributeValueId__r.VASA_Region__c);
        }
        if(!Test.isRunningTest()){ 
            update lineItems;   
        }
    
        //Igloo Quote Stage Updates      
        if(!lineItems.isEmpty() && String.isNotBlank(lineItems[0].Apttus_Config2__AttributeValueId__r.QuoteId__c)){
            Apttus_Proposal__Proposal__c quoteObj = [Select Id,Renewal_Contract__c,Is_Offline_Config_Completed__c,Apttus_Proposal__Opportunity__c,Send_Email_on_Rate_Refresh__c,isRateRefreshBatchProcessing__c,Buyflow_Step__c,Rate_Card_Effective_Date__c,Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c, Apttus_Proposal__Approval_Stage__c,applyAllFlag__c FROM Apttus_Proposal__Proposal__c WHERE Id =:quoteId  LIMIT 1];
            if(quoteObj.Is_Offline_Config_Completed__c){  
                quoteObj.Is_Offline_Config_Completed__c = false;
                update quoteObj;
            }
                        
            //After IGLOO offline processing, stage will only be updated to Bulk Service Availability Completed if all the sites have got Successful IGLOO response
            Boolean offlineProcessingComplete = false;            
            system.debug('@@@@(date.parse(quoteObj.Rate_Card_Effective_Date__c).daysBetween(quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c.date())' + (date.parse(quoteObj.Rate_Card_Effective_Date__c).daysBetween(quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c.date())));
            if(quoteObj.Renewal_Contract__c == false && (quoteObj.Rate_Card_Effective_Date__c != null && quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c != null && (date.parse(quoteObj.Rate_Card_Effective_Date__c).daysBetween(quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c.date()) == 0 || date.parse(quoteObj.Rate_Card_Effective_Date__c).daysBetween(quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c.date()) == 1 || date.parse(quoteObj.Rate_Card_Effective_Date__c).daysBetween(quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c.date()) == -1 ))  && (quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(BuyflowConstant.BULKSERVICE_AVAILABILITY_REQUESTED) || quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('Bulk Service Availability Requested'))){
                quoteObj.Apttus_Proposal__Approval_Stage__c = BuyflowConstant.BULKSERVICE_AVAILABILITY_COMPLETED;
                offlineProcessingComplete = true;
                system.debug('@@@Bulk Processing Completed!!!');
            }
            quoteObj.applyAllFlag__c = true; 
           
            //Rate Refresh Logic            
            if(quoteObj.Renewal_Contract__c == false && quoteObj.Rate_Card_Effective_Date__c != null && quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c != null && date.parse(quoteObj.Rate_Card_Effective_Date__c).daysBetween(quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c.date())>1){  
                
                if(quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(BuyflowConstant.BULKSERVICE_AVAILABILITY_REQUESTED)){
                    quoteObj.Apttus_Proposal__Approval_Stage__c = BuyflowConstant.BULKSERVICE_AVAILABILITY_COMPLETED;
                    update quoteObj;
                } 
                else{
                    quoteObj.Apttus_Proposal__Approval_Stage__c = 'Draft';
                }
                quoteObj.isRateRefreshBatchProcessing__c = false; 
                quoteObj.Rate_Card_Effective_Date__c = quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c.format('M/dd/yyyy');
                List<Opportunity> opp=new List<Opportunity>();
                opp=[select id,stageName from Opportunity  where id =: quoteObj.Apttus_Proposal__Opportunity__c];
                
                if(quoteObj.Buyflow_Step__c!=null && quoteObj.Buyflow_Step__c!= ATTConstants.CONFIGURE_SITES && iglooAvSize>0){
                    quoteObj.Buyflow_Step__c = ATTConstants.CONFIGURE_SITES;
                    quoteObj.Apttus_Proposal__Approval_Stage__c = 'Draft'; 
                    if(opp!=null && opp.size()>0){
                        opp[0].stageName='Saved';
                        update opp[0];
                    }
                }
                else{
                    if(opp!=null && opp.size()>0){
                        if(opp[0].StageName!=null && opp[0].StageName!='' && (opp[0].StageName=='Deal Reg Approved' || opp[0].StageName=='Deal Reg Auto-Approved')){
                            quoteObj.Apttus_Proposal__Approval_Stage__c = 'Deal Reg Approved'; 
                        }
                        else if(opp[0].StageName!=null && opp[0].StageName!='' && opp[0].StageName=='Deal Registration Requested'){
                            quoteObj.Apttus_Proposal__Approval_Stage__c = 'Pending Deal Reg';
                        }
                        else if(opp[0].StageName!=null && opp[0].StageName!='' && opp[0].StageName=='Pricing Schedule Pending'){
                            quoteObj.Send_Email_on_Rate_Refresh__c=true;
                      }                      
                  }
              }     
            }
            else if(offlineProcessingComplete == true){                        
                quoteObj.Is_Offline_Config_Completed__c = true;
            } 
            
            //Contract Renewal Logic
            if(quoteObj.Renewal_Contract__c == true){
                quoteObj.Apttus_Proposal__Approval_Stage__c = 'Pending Deal Reg';                
            }                   
            update quoteObj;
            if(quoteObj.Renewal_Contract__c == true){
                ApttusServiceUtilityHelper helper = new ApttusServiceUtilityHelper();
                if(!test.isrunningTest()){
                    helper.createContractRenewalDeal(quoteObj.Id);
                }
            }          
        }  
    }
}