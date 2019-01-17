/*************************************************************************************************************************************** 
Apex Class Name     : ApplyPricesForBulkSitesafterigloo 
Version             : 1.0 
Created Date        : 1 Feb 2017    
Function            : This class handles the IGLOO Bulk Callout for OOR Switched Ethernet Sites
****************************************************************************************************************************************/
global class  ApplyPricesForBulkSitesafterigloo implements Database.Batchable<sObject>, Database.AllowsCallouts {
  
    global final list<Integer> lineNumbers;
    global final String cartId;
    global final set<id> IglooAvId;
    global final Integer iglooAvSize; 
    global final string siteQuoteJunctionId;
    global ApplyPricesForBulkSitesafterigloo( list<Integer> lineNumbers,String cartId , set<id>IglooAvId) {
        this.iglooAvSize = IglooAvId.size();
        this.lineNumbers = lineNumbers;
        this.cartId = cartId;
        this.IglooAvId= IglooAvId;
    }
    
    global ApplyPricesForBulkSitesafterigloo( list<Integer> lineNumbers,String cartId , set<id>IglooAvId ,string siteQuoteJunctionId) {
        this.iglooAvSize = IglooAvId.size();
        this.lineNumbers = lineNumbers;
        this.cartId = cartId;
        this.IglooAvId= IglooAvId;
        this.siteQuoteJunctionId = siteQuoteJunctionId;
    }  
    
    /*Batch start method to query the Attribute Value records for IGLOO Call*/
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('@@@Line Numbers: '+lineNumbers.size());  
        system.debug('@@@IGLOO AV Ids: '+IglooAvId);  
        String Query = 'SELECT Id ,Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Payment_Term__c, AT_T_Customer_Site__c,QuoteId__c,Apttus_Config2__LineItemId__c,ProductName__c,IP_Flex_Error__c,IGLOO_Port_Speed_Substituted__c, IGLOO_Access_Speed_Substituted__c, IGLOO_Interface_Type_Substituted__c, IGLOO_Speed_Unavailable__c, IGLOO_Old_Port_Speed__c, IGLOO_Old_Access_Speed__c, IGLOO_Old_Interface_Type__c, Alternate_Access_IGLOO_Interface_Code__c, Alternate_Access_IGLOO_Access_Price__c, Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c ,AT_T_IP_Flexible_Reach__c,CoS__c,VLANs_Logical_Channels__c,Hi_Cap_Flex__c,Port_Type_AVPN__c,Port_Speed_AVPN__c,UBB_Speed_AVPN__c,Access_Type_AVPN__c,Access_Speed_AVPN__c,Install_Option_AVPN__c,Interface_Type_AVPN__c,VASA_Region__c,Apttus_Config2__Vendor__c,Mileage__c,IP_Flexible_Reach_Plan__c,Ported_Phone_Numbers__c,New_Local_Phone_Numbers__c,New_Virtual_Phone_Numbers__c,Concurrent_Calls__c,Enhanced_Features__c,Directory_Listing_Phone_Number__c,Setup_Fee__c,Managed_Router__c,Port_Type_MIS__c,Port_Speed_MIS__c,UBB_Speed_MIS__c,Access_Type__c,Access_Speed_MIS__c,Install_Option_MIS__c,Interface_Type__c,Additional_DNS__c,Apttus_Config2__LineItemId__r.Apttus_Config2__LineNumber__c,IGLOO_Retrial_Failure_Count__c,IGLOO_Call_Failure__c,Quote_Total_Failure_Count__c,ContractRenewal_Access_Price__c,ContractRenewal_IglooError__C FROM Apttus_Config2__ProductAttributeValue__c WHERE id IN :IglooAvId'+' and Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c= '+'\''+cartId+'\'';
        return Database.getQueryLocator(query);
    }

    /*Batch execute method to fetch the IGLOO prices and update Access Speed Line Items*/
    global void execute(Database.BatchableContext BC,List<Apttus_Config2__ProductAttributeValue__c> avRecords){
        try{  
            system.debug('@@AV Record: '+avRecords); 
            IGLOOIntegrationHandler handler = new IGLOOIntegrationHandler();      
            for(Apttus_Config2__ProductAttributeValue__c av: avRecords){
                system.debug('av.AT_T_Customer_Site__c' + av.AT_T_Customer_Site__c); 
                handler.executeIglooLogic(av.QuoteId__c,av.AT_T_Customer_Site__c,av);
                update av;
                handler.fetchAccessSpeedDiscountedPrice(av.QuoteId__c, cartId ,Integer.valueOf(av.Apttus_Config2__LineItemId__r.Apttus_Config2__LineNumber__c) , av);
            }   
        }    
        catch(Exception ex){ 
            system.debug('@@Exception caught in ApplyPricesForBulkSitesafterigloo: '+ex.getMessage()+' :Line number: '+ex.getlineNumber());     
        }
    }
    
    /*Bath finish method executes business logic after batch completion*/
    global void finish(Database.BatchableContext BC){
        list<Apttus_Config2__LineItem__c> lineItems = new list<Apttus_Config2__LineItem__c>();
        lineItems = [SELECT Id,isPricingApplied__c,Product_Code__c,IsBatchUpdate__c,Apttus_Config2__AttributeValueId__r.QuoteId__c,AT_T_Customer_Site__r.Id,Apttus_Config2__AttributeValueId__r.VASA_Region__c,Apttus_Config2__AttributeValueId__r.IGLOO_Speed_Unavailable__c,Apttus_Config2__AttributeValueId__r.IGLOO_Call_Failure__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__PrimaryLineNumber__c IN :lineNumbers and Apttus_Config2__ConfigurationId__c= :cartId];
        if(lineItems.size()>0){
            if(String.isNotBlank(lineItems[0].Product_Code__c) && ((lineItems[0].Product_Code__c.equalsIgnoreCase(BuyflowConstant.AMIS)) || (lineItems[0].Product_Code__c.equalsIgnoreCase(BuyflowConstant.AVPN)))){
                string quoteId;
                quoteId = lineItems[0].Apttus_Config2__AttributeValueId__r.QuoteId__c;
                ID batchprocessid = database.executeBatch(new ApplyPromotionsForEligibleSites(lineNumbers,cartId,IglooAvId,lineitems,quoteId ,siteQuoteJunctionId),1); 
            }
            else{
                Map<String,String> siteAndRegionMap = new Map<String,String>();
                for( Apttus_Config2__LineItem__c lineItem : lineItems ){         
                    if(lineItem.Apttus_Config2__AttributeValueId__r.IGLOO_Speed_Unavailable__c == false && lineitem.Apttus_Config2__AttributeValueId__r.IGLOO_Call_Failure__c == false){         
                        lineItem.isPricingApplied__c = true; 
                    }
                    lineItem.IsBatchUpdate__c = true;
                    siteAndRegionMap.put(lineitem.AT_T_Customer_Site__r.id,lineitem.Apttus_Config2__AttributeValueId__r.VASA_Region__c);
                } 
                update lineItems;   
                
                //Igloo Quote Stage Updates
                system.debug('@@@lineItems[0].Apttus_Config2__AttributeValueId__r.QuoteId__c: '+lineItems[0].Apttus_Config2__AttributeValueId__r.QuoteId__c);
                
                if(!lineItems.isEmpty() && String.isNotBlank(lineItems[0].Apttus_Config2__AttributeValueId__r.QuoteId__c)){
                    String quoteId = lineItems[0].Apttus_Config2__AttributeValueId__r.QuoteId__c;
                    Apttus_Proposal__Proposal__c quoteObj = [Select Id,Renewal_Contract__c,Is_Offline_Config_Completed__c,Apttus_Proposal__Opportunity__c,Send_Email_on_Rate_Refresh__c,isRateRefreshBatchProcessing__c,Buyflow_Step__c,Rate_Card_Effective_Date__c,Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c, Apttus_Proposal__Approval_Stage__c,applyAllFlag__c FROM Apttus_Proposal__Proposal__c WHERE Id =:quoteId  LIMIT 1];
                    if(quoteObj.Is_Offline_Config_Completed__c){  
                        quoteObj.Is_Offline_Config_Completed__c = false;
                        update quoteObj;
                    }
                                
                    //After IGLOO offline processing, stage will only be updated to Bulk Service Availability Completed if all the sites have got Successful IGLOO response
                    Boolean offlineProcessingComplete = false;
                    system.debug('@@@quoteObj.Rate_Card_Effective_Date__c: '+quoteObj.Rate_Card_Effective_Date__c);
                    system.debug('@@@quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c: '+quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c);
                    
                    if(quoteObj.Renewal_Contract__c == false && (quoteObj.Rate_Card_Effective_Date__c != null && quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c != null && date.parse(quoteObj.Rate_Card_Effective_Date__c).daysBetween(quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c.date()) == 0) && (quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(BuyflowConstant.BULKSERVICE_AVAILABILITY_REQUESTED) || quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('Bulk Service Availability Requested')) ){
                        quoteObj.Apttus_Proposal__Approval_Stage__c = BuyflowConstant.BULKSERVICE_AVAILABILITY_COMPLETED;
                        offlineProcessingComplete = true;
                        system.debug('@@@Bulk Processing Completed!!!');
                    }
                    quoteObj.applyAllFlag__c = true; 
                   
                    //Rate Refresh Logic            
                    if(quoteObj.Renewal_Contract__c == false && quoteObj.Rate_Card_Effective_Date__c != null && quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c != null && date.parse(quoteObj.Rate_Card_Effective_Date__c).daysBetween(quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c.date())>0){  
                        
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
    }
}