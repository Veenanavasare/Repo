/************************************************************************************** 
Apex Class Name     : AddSitetoTokenBatch
Version             : 1.0 
Created Date        : 2 July 2018
Function            : Batch to add multiple tokens to quote
***************************************************************************************/ 
global class AddSitetoTokenBatch implements Database.batchable<sObject>{
    
    public Apttus_Proposal__Proposal__c quoteObj;
    public map<String,String> tokenSuccessMap;
    
    /*Constructor*/
    public AddSitetoTokenBatch(Apttus_Proposal__Proposal__c quoteObj, map<String,String> tokenSuccessMap){
        this.quoteObj = quoteObj;
        this.tokenSuccessMap = tokenSuccessMap;
    }

    /*Batch Start Method*/
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('@@@AddSitetoTokenBatch Start Method!!!');
        Set<String> tokenIdSet = new Set<String>();
        tokenIdSet = tokenSuccessMap.keySet();
        string customerSitesList = 'SELECT Id,Name,Site_Name__c,End_Customer__c,End_Customer__r.Name,IPQProposal__r.Name,IPQProposal__r.Apttus_Proposal__Payment_Term__c,IPQProposal__r.Product__r.Name,IPQProposal__r.Apttus_Proposal__Account__c,IPQProposal__r.End_Customer__c,CreatedDate,Address_Line__c,IPQProposal__c,Location__c,City__c,State__c,Zip_Code__c,End_Customer_Name__c,Site_Quote_Expiration_Date__c FROM CustomerSite__c where Id IN: tokenIdSet';
        return Database.getQueryLocator(customerSitesList);      
    }
    
    /*Batch Execute Method*/
    global void execute(Database.batchableContext BC, List<CustomerSite__c> customerSitesList){
        try{
            system.debug('@@@AddSitetoTokenBatch Execute Method!!! Customer Site: '+customerSitesList);
            String cartId = '',tokenId = '',tokenquoteid = '',selectedProductId = '',selectedProductCode = '', proposalName = '';
            ApttusServiceUtilityHelper helper = new ApttusServiceUtilityHelper(); 
            List<Apttus_Config2__LineItem__c> lineItemList = new List<Apttus_Config2__LineItem__c>();
            
            List<Apttus_Proposal__Proposal__c> currentQuoteList = new List<Apttus_Proposal__Proposal__c>();
            currentQuoteList = [select Id, Product_New_Name__c, Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Payment_Term__c,Product__r.ProductCode, Product__c,Rate_Card_Effective_Date__c,Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c,MACD_Change_Type__c,DealHash__c,Term__c,Apttus_Proposal__Account__r.Master_Agent__c,Apttus_Proposal__Account__r.Current_Tier__c,Name,subAccountNumber__c,Apttus_QPConfig__PriceListId__r.Id, Opportunity_Owner_Email__c, Docusign_Envelope__c, Denial_Reason__c, Contract_Read__c, End_Customer__c, Contract_Signed__c, End_Customer__r.Name,End_Customer__r.Mailing_Street_Address__c,End_Customer__r.City__c, Product__r.name, End_Customer__r.Zip__c,End_Customer__r.State__c,Product_Name__c, Apttus_Proposal__Opportunity__c,Apttus_Proposal__Approval_Stage__c,Is_Offline_Config_Completed__c,Bulk_Sevice_Availability_Indicator__c,isRateRefreshBatchProcessing__c,Buyflow_Step__c from Apttus_Proposal__Proposal__c where id = :quoteObj.Id];
            if(currentQuoteList.size() > 0){
                selectedProductId = currentQuoteList[0].Product__c;
                selectedProductCode = currentQuoteList[0].Product__r.ProductCode;
                proposalName = currentQuoteList[0].Apttus_Proposal__Proposal_Name__c;
            }
            
            if(customerSitesList.size()>0){
                tokenId = customerSitesList[0].Id;
                tokenquoteid = customerSitesList[0].IPQProposal__r.Name;
            }
    
            list<Apttus_Config2__ProductConfiguration__c> prodConfig = new list<Apttus_Config2__ProductConfiguration__c>();
            prodConfig = [SELECT Id, Name,Apttus_Config2__Status__c, Apttus_QPConfig__Proposald__c,CreatedDate FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c = :quoteObj.Id order by CreatedDate desc LIMIT 1];
            if(!prodConfig.isEmpty()){
                cartId = prodConfig[0].Id;
            }
            else{
                cartId = helper.createCart(currentQuoteList[0].id);
            }
            system.debug('@@@Cart Id: '+cartId);
            system.debug('@@@Site Token Id: '+tokenId );
            system.debug('@@@Token Quote Id: '+tokenquoteid);
    
            if(String.isNotBlank(cartId)){   
                Apttus_CPQApi.CPQ.AddMultiProductRequestDO request = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO();            
                Apttus_CPQApi.CPQ.SelectedProductDO prod = new Apttus_CPQApi.CPQ.SelectedProductDO();
                prod.ProductId = selectedProductId;
                prod.Quantity = prod.SellingTerm = 1;
                prod.StartDate = system.today();
                prod.EndDate = system.today()+2;
                request.CartId = cartId;
                request.SelectedProducts.add(prod);
                Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(request);
                list<Decimal> lineNumberList = response.LineNumbers;
                lineItemList=[Select Id,isPricingApplied__c,Apttus_Config2__PricingStatus__c,AT_T_Customer_Site__c,AT_T_Customer_Site__r.Id,Apttus_Config2__LineNumber__c,Apttus_Config2__ChargeType__c,Apttus_Config2__PrimaryLineNumber__c from Apttus_Config2__LineItem__c where Apttus_Config2__PrimaryLineNumber__c=:response.LineNumbers and Apttus_Config2__ConfigurationId__c=:cartId];
                List<Apttus_Config2__LineItem__c> liteItemUpdated;
                for(Apttus_Config2__LineItem__c lineitem :lineItemList){
                    lineitem.AT_T_Customer_Site__c = tokenId;
                    lineitem.Apttus_Config2__LineNumber__c=lineItemList[0].Apttus_Config2__PrimaryLineNumber__c;
                    lineitem.isPricingApplied__c = true;
                }
                update lineItemList;           
            }
            
            //Updating AV record
            list<Apttus_Config2__ProductAttributeValue__c> avListOld = new list<Apttus_Config2__ProductAttributeValue__c>();
            avListOld = [SELECT Id,Name,Proposal__c,Apttus_Config2__LineItemId__r.AT_T_Customer_Site__r.Service_Availability_Response__c,ProductName__c,IP_Flex_Error__c,IGLOO_Port_Speed_Substituted__c, IGLOO_Access_Speed_Substituted__c, IGLOO_Interface_Type_Substituted__c, IGLOO_Speed_Unavailable__c, IGLOO_Old_Port_Speed__c, IGLOO_Old_Access_Speed__c, IGLOO_Old_Interface_Type__c, Alternate_Access_IGLOO_Interface_Code__c, Alternate_Access_IGLOO_Access_Price__c, Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c, Igloo_Call_Processing_Complete__c, AT_T_Customer_Site__c, Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Payment_Term__c, IGLOO_Retrial_Failure_Count__c, IGLOO_Call_Failure__c, Quote_Total_Failure_Count__c, AT_T_IP_Flexible_Reach__c,Managed_Router__c,CoS__c,VLANs_Logical_Channels__c,Hi_Cap_Flex__c,Port_Type_AVPN__c,Port_Type_MIS__c,Port_Speed_MIS__c,Port_Speed_AVPN__c,UBB_Speed_AVPN__c,UBB_Speed_MIS__c,Access_Type__c,Access_Type_AVPN__c,Access_Speed_MIS__c,Access_Speed_AVPN__c,Interface_Type_AVPN__c,Interface_Type__c,Additional_DNS__c,Install_Option_MIS__c,Install_Option_AVPN__c,VASA_Region__c,Apttus_Config2__Vendor__c,Mileage__c,IP_Flexible_Reach_Plan__c,Ported_Phone_Numbers__c,New_Local_Phone_Numbers__c,New_Virtual_Phone_Numbers__c,Concurrent_Calls__c,enhanced_features__c,Directory_Listing_Phone_Number__c,Setup_Fee__c,Alternate_Access_IGLOO_Interface_Type__c,Igloo_Access_Price__c,Iglow_Call_Date__c,Wireline_Promotion_Id__c from Apttus_Config2__ProductAttributeValue__c where Proposal__c =: tokenquoteid LIMIT 1];
            System.debug('@@@Old AV List: '+avListOld);
            
            map<String,Apttus_Config2__LineItem__c> oldPriceMap = new map<String,Apttus_Config2__LineItem__c>();
            if(avListOld.size()>0){
                list<Apttus_Config2__LineItem__c> lineItemListOld = new list<Apttus_Config2__LineItem__c>();            
                lineItemListOld = [select id,Original_Hidden_Price__c,Original_Net_Price__c,Apttus_Config2__NetPrice__c,Alternate_Access_IGLOO_Access_Price__c,Alternate_Access_IGLOO_Discount__c,Apttus_Config2__ChargeType__c,Wireline_Promotion_Discount_Percentage__c,WP_Hidden_Discount_Percentage__c from Apttus_Config2__LineItem__c where Apttus_Config2__AttributeValueId__c =: avListOld[0].Id and AT_T_Customer_Site__c =: tokenId];
                for(Apttus_Config2__LineItem__c item : lineItemListOld){
                    oldPriceMap.put(item.Apttus_Config2__ChargeType__c, item);
                }
            }
            system.debug('@@@oldPriceMap: '+oldPriceMap);
            
            list<Apttus_Config2__ProductAttributeValue__c> avList = new list<Apttus_Config2__ProductAttributeValue__c>();
            avList = [SELECT Id,Name,Proposal__c,Apttus_Config2__LineItemId__r.AT_T_Customer_Site__r.Service_Availability_Response__c,ProductName__c,IP_Flex_Error__c,IGLOO_Port_Speed_Substituted__c, IGLOO_Access_Speed_Substituted__c, IGLOO_Interface_Type_Substituted__c, IGLOO_Speed_Unavailable__c, IGLOO_Old_Port_Speed__c, IGLOO_Old_Access_Speed__c, IGLOO_Old_Interface_Type__c, Alternate_Access_IGLOO_Interface_Code__c, Alternate_Access_IGLOO_Access_Price__c, Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c, Igloo_Call_Processing_Complete__c, AT_T_Customer_Site__c, Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Payment_Term__c, IGLOO_Retrial_Failure_Count__c, IGLOO_Call_Failure__c, Quote_Total_Failure_Count__c, AT_T_IP_Flexible_Reach__c,Managed_Router__c,CoS__c,VLANs_Logical_Channels__c,Hi_Cap_Flex__c,Port_Type_AVPN__c,Port_Type_MIS__c,Port_Speed_MIS__c,Port_Speed_AVPN__c,UBB_Speed_AVPN__c,UBB_Speed_MIS__c,Access_Type__c,Access_Type_AVPN__c,Access_Speed_MIS__c,Access_Speed_AVPN__c,Interface_Type_AVPN__c,Interface_Type__c,Additional_DNS__c,Install_Option_MIS__c,Install_Option_AVPN__c,VASA_Region__c,Apttus_Config2__Vendor__c,Mileage__c,IP_Flexible_Reach_Plan__c,Ported_Phone_Numbers__c,New_Local_Phone_Numbers__c,New_Virtual_Phone_Numbers__c,Concurrent_Calls__c,enhanced_features__c,Directory_Listing_Phone_Number__c,Setup_Fee__c,Alternate_Access_IGLOO_Interface_Type__c,Igloo_Access_Price__c,Iglow_Call_Date__c,Wireline_Promotion_Id__c from Apttus_Config2__ProductAttributeValue__c where Proposal__c =: proposalName AND Apttus_Config2__LineItemId__c =: lineItemList[0].id LIMIT 1];
            System.debug('@@@NEWList--->'+avList);
            
            if(!avListOld.isEmpty()){
                if(avList.size()>0){
                    avList[0].Apttus_Config2__Vendor__c = avListOld[0].Apttus_Config2__Vendor__c ;
                    avList[0].Mileage__c = avListOld[0].Mileage__c;
                    avList[0].VASA_Region__c = avListOld[0].VASA_Region__c;
                    avList[0].Alternate_Access_IGLOO_Interface_Code__c = avListOld[0].Alternate_Access_IGLOO_Interface_Code__c;
                    avList[0].Alternate_Access_IGLOO_Access_Price__c = avListOld[0].Alternate_Access_IGLOO_Access_Price__c;
                    avList[0].Igloo_Access_Price__c = avListOld[0].Igloo_Access_Price__c;
                    avList[0].Iglow_Call_Date__c = avListOld[0].Iglow_Call_Date__c;
                    avList[0].Igloo_Call_Processing_Complete__c = avListOld[0].Igloo_Call_Processing_Complete__c;
                    avList[0].Wireline_Promotion_Id__c = avListOld[0].Wireline_Promotion_Id__c;
                    avList[0].Managed_Router__c = avListOld[0].Managed_Router__c;
                    avList[0].IP_Flexible_Reach_Plan__c = avListOld[0].IP_Flexible_Reach_Plan__c;
                    avList[0].Hi_Cap_Flex__c = avListOld[0].Hi_Cap_Flex__c;
                    avList[0].Ported_Phone_Numbers__c = avListOld[0].Ported_Phone_Numbers__c;
                    avList[0].New_Local_Phone_Numbers__c = avListOld[0].New_Local_Phone_Numbers__c;
                    avList[0].New_Virtual_Phone_Numbers__c = avListOld[0].New_Virtual_Phone_Numbers__c;
                    avList[0].Concurrent_Calls__c  = avListOld[0].Concurrent_Calls__c;
                    avList[0].CoS__c = avListOld[0].CoS__c;
                    avList[0].enhanced_features__c = avListOld[0].enhanced_features__c;
                    avList[0].Additional_DNS__c = avListOld[0].Additional_DNS__c;
                    avList[0].AT_T_IP_Flexible_Reach__c = avListOld[0].AT_T_IP_Flexible_Reach__c;
                    
                    if(selectedProductCode == 'AVPN'){            
                        avList[0].Access_Speed_AVPN__c = avListOld[0].Access_Speed_AVPN__c;
                        avList[0].Access_Type_AVPN__c = avListOld[0].Access_Type_AVPN__c;
                        avList[0].Interface_Type_AVPN__c = avListOld[0].Interface_Type_AVPN__c;                   
                        avList[0].Port_Speed_AVPN__c = avListOld[0].Port_Speed_AVPN__c;
                        avList[0].Port_Type_AVPN__c = avListOld[0].Port_Type_AVPN__c;
                        avList[0].Install_Option_AVPN__c = avListOld[0].Install_Option_AVPN__c;
                        avList[0].UBB_Speed_AVPN__c = avListOld[0].UBB_Speed_AVPN__c;
                        avList[0].VLANs_Logical_Channels__c = avListOld[0].VLANs_Logical_Channels__c;
                    }
                    else{
                        avList[0].Access_Speed_MIS__c = avListOld[0].Access_Speed_MIS__c;
                        avList[0].Access_Type__c = avListOld[0].Access_Type__c;
                        avList[0].Interface_Type__c = avListOld[0].Interface_Type__c;                    
                        avList[0].Port_Speed_MIS__c = avListOld[0].Port_Speed_MIS__c;
                        avList[0].Port_Type_MIS__c = avListOld[0].Port_Type_MIS__c;
                        avList[0].Install_Option_MIS__c = avListOld[0].Install_Option_MIS__c;
                        avList[0].UBB_Speed_MIS__c = avListOld[0].UBB_Speed_MIS__c;                  
                    }
                }
            }
            
            if(avList.size()>0){
                Apttus_Config2__ProductAttributeValue__c av = new Apttus_Config2__ProductAttributeValue__c();
                av = avList[0];            
                if(selectedProductId == 'AVPN'){
                    helper.updateAVRecordsOnApply(av,av.Apttus_Config2__LineItemId__r.AT_T_Customer_Site__r.Service_Availability_Response__c,true,false);   
                }else{
                    helper.updateAVRecordsOnApply(av,av.Apttus_Config2__LineItemId__r.AT_T_Customer_Site__r.Service_Availability_Response__c,false,true);   
                }
            }
            update avList;
            
            helper.computePrice(cartId,Integer.valueOf(lineItemList[0].Apttus_Config2__LineNumber__c));
            
            list<Apttus_Config2__LineItem__c>  newlineItems = [SELECT Id,Product_Code__c, Project_Id__c,Apttus_Config2__BaseExtendedCost__c,AccessSpeed__c,Lec_Name__c,Access_Type__c,  Apttus_Config2__PriceListId__r.Name , VASARegion__c,Mileage__c,IsBatchUpdate__c,UBBOveragePrice__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c,Apttus_Config2__PriceListItemId__c,Apttus_Config2__ExtendedPrice__c,Apttus_Config2__PriceListId__c,AT_T_Customer_Site__r.Id ,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.id, Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__ListPrice__c,AdditionalDnsType__c,Port_Speed__c, MBC_Speed__c,Apttus_Config2__BasePrice__c,Apttus_Config2__AttributeValueId__r.VLANs_Logical_Channels__c, isPricingApplied__c, Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c,Apttus_Config2__AttributeValueId__r.Additional_DNS__c, Apttus_Config2__AttributeValueId__r.CoS__c,Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Rate_Card_Effective_Date__c,Apttus_Config2__PriceListId__r.Apttus_Config2__EffectiveDate__c,Apttus_Config2__AttributeValueId__r.VASA_Region__c,Apttus_Config2__AttributeValueId__r.Access_Type_AVPN__c,Apttus_Config2__AttributeValueId__r.Access_Type__c,Apttus_Config2__AttributeValueId__r.Igloo_Access_Price__c,Alternate_Access_IGLOO_Access_Price__c,Alternate_Access_IGLOO_Discount__c,Wireline_Promotion_Discount_Percentage__c,WP_Hidden_Discount_Percentage__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c= :cartId and AT_T_Customer_Site__c =:tokenId];      
                   
            for(Apttus_Config2__LineItem__c lineItem : newlineItems){
                if(lineItem.Apttus_Config2__ChargeType__c == 'Port Speed Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('Port Speed Fee')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('Port Speed Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('Port Speed Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('Port Speed Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('Port Speed Fee').Wireline_Promotion_Discount_Percentage__c;
                }            
                else if(lineItem.Apttus_Config2__ChargeType__c == 'Access Speed Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('Access Speed Fee')){
                    lineItem.Alternate_Access_IGLOO_Access_Price__c = oldPriceMap.get('Access Speed Fee').Alternate_Access_IGLOO_Access_Price__c;
                    lineItem.Alternate_Access_IGLOO_Discount__c = oldPriceMap.get('Access Speed Fee').Alternate_Access_IGLOO_Discount__c;
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('Access Speed Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('Access Speed Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('Access Speed Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('Access Speed Fee').Wireline_Promotion_Discount_Percentage__c;
                    lineItem.WP_Hidden_Discount_Percentage__c = oldPriceMap.get('Access Speed Fee').WP_Hidden_Discount_Percentage__c;
                }
                else if(lineItem.Apttus_Config2__ChargeType__c == 'Access Speed Mileage Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('Access Speed Mileage Fee')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('Access Speed Mileage Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('Access Speed Mileage Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('Access Speed Mileage Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('Access Speed Mileage Fee').Wireline_Promotion_Discount_Percentage__c;
                }
                else if(lineItem.Apttus_Config2__ChargeType__c == 'One Time Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('One Time Fee')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('One Time Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('One Time Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('One Time Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('One Time Fee').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'VLAN(s)/Logical Channel' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('VLAN(s)/Logical Channel')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('VLAN(s)/Logical Channel').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('VLAN(s)/Logical Channel').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('VLAN(s)/Logical Channel').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('VLAN(s)/Logical Channel').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'Access Speed' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('Access Speed')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('Access Speed').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('Access Speed').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('Access Speed').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('Access Speed').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'CoS Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('CoS Fee')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('CoS Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('CoS Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('CoS Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('CoS Fee').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'Additional DNS Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('Additional DNS Fee')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('Additional DNS Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('Additional DNS Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('Additional DNS Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('Additional DNS Fee').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'VTN Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('VTN Fee')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('VTN Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('VTN Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('VTN Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('VTN Fee').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'VoIP' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('VoIP')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('VoIP').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('VoIP').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('VoIP').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('VoIP').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'Enhanced Features' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('Enhanced Features')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('Enhanced Features').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('Enhanced Features').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('Enhanced Features').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('Enhanced Features').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'Setup Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('Setup Fee')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('Setup Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('Setup Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('Setup Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('Setup Fee').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'IP Flex Reach Plan' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('IP Flex Reach Plan')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('IP Flex Reach Plan').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('IP Flex Reach Plan').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('IP Flex Reach Plan').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('IP Flex Reach Plan').Wireline_Promotion_Discount_Percentage__c;
                }                
                lineItem.Apttus_Config2__BaseExtendedCost__c = lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__AdjustedPrice__c = lineItem.Apttus_Config2__BaseExtendedPrice__c = lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__ListPrice__c = lineItem.Apttus_Config2__NetPrice__c;
            }
            update newLineItems;
            
            list<CustomerSite__c> customerSiteList = new list<CustomerSite__c>();
            customerSiteList = [SELECT id,Site_Name__c,End_Customer__c from CustomerSite__c where id =:tokenId LIMIT 1];
            if(customerSiteList.size() > 0){
                String trimmedSiteId = String.valueOf(customerSiteList[0].Id).subString(0,15);
                if(tokenSuccessMap.containsKey(trimmedSiteId)){
                    customerSiteList[0].Site_Name__c = tokenSuccessMap.get(trimmedSiteId);
                }
                if(quoteObj.End_Customer__c != null){
                    customerSiteList[0].End_Customer__c = quoteObj.End_Customer__c;
                }
                update customerSiteList;
            }
            
            List<AT_T_Customer_Site_Quote__c> siteQuoteJuncOld = new List<AT_T_Customer_Site_Quote__c>();
            siteQuoteJuncOld = [SELECT Id,AT_T_Customer_Site__c,Igloo_Review_Required__c,Wireline_Promotion_Id_Before__c,Wireline_Promotion_Id_After__c,Wireline_Promotion_Id_Applied__c,Alternate_Access_IGLOO_Response__c,Alternate_Access_IGLOO_Request_Time__c,Iglow_Response_Received_Date__c,Alternate_Access_IGLOO_Response_Status__c,Alternate_Access_IGLOO_Failure_Code__c,Alternate_Access_IGLOO_Access_Speed__c,Alternate_Access_IGLOO_Access_Price__c,Alternate_Access_IGLOO_Interface_Code__c,Alternate_Access_IGLOO_Interface_Type__c,Alternate_Access_IGLOO_Process_Completed__c,CSI_Conversation_Id__c,IGLOO_Supplier_Name__c,Wireline_Promotion_Applied__c,Wireline_Promotion_Id_Sorted__c,Wireline_Promotion_Name_Applied__c,Wireline_Promotion_Number_Applied__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__r.Name =: tokenquoteid AND AT_T_Customer_Site__c=: tokenId];
            System.debug('siteQuoteJuncOld--->'+siteQuoteJuncOld);
            AT_T_Customer_Site_Quote__c newSiteQuoteJunc = new AT_T_Customer_Site_Quote__c();
            if(!siteQuoteJuncOld.isEmpty() && siteQuoteJuncOld.size()>0){
                newSiteQuoteJunc.AT_T_Customer_Site__c = Id.valueOf(tokenId);
                newSiteQuoteJunc.AT_T_Quote__c = Id.valueOf(quoteObj.Id);
                newSiteQuoteJunc.Type__c = 'Non-MACD';
                newSiteQuoteJunc.Alternate_Access_IGLOO_Response__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Response__c;
                newSiteQuoteJunc.Alternate_Access_IGLOO_Request_Time__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Request_Time__c;
                newSiteQuoteJunc.Iglow_Response_Received_Date__c = siteQuoteJuncOld[0].Iglow_Response_Received_Date__c;
                newSiteQuoteJunc.Alternate_Access_IGLOO_Response_Status__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Response_Status__c;
                newSiteQuoteJunc.Alternate_Access_IGLOO_Failure_Code__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Failure_Code__c;
                newSiteQuoteJunc.Alternate_Access_IGLOO_Access_Speed__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Access_Speed__c;
                newSiteQuoteJunc.Alternate_Access_IGLOO_Access_Price__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Access_Price__c;
                newSiteQuoteJunc.Alternate_Access_IGLOO_Interface_Code__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Interface_Code__c;
                newSiteQuoteJunc.Alternate_Access_IGLOO_Process_Completed__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Process_Completed__c;
                newSiteQuoteJunc.CSI_Conversation_Id__c = siteQuoteJuncOld[0].CSI_Conversation_Id__c;
                newSiteQuoteJunc.IGLOO_Supplier_Name__c = siteQuoteJuncOld[0].IGLOO_Supplier_Name__c;
                newSiteQuoteJunc.Wireline_Promotion_Applied__c = siteQuoteJuncOld[0].Wireline_Promotion_Applied__c;
                newSiteQuoteJunc.Wireline_Promotion_Id_Before__c = siteQuoteJuncOld[0].Wireline_Promotion_Id_Before__c;
                newSiteQuoteJunc.Wireline_Promotion_Id_After__c = siteQuoteJuncOld[0].Wireline_Promotion_Id_After__c;
                newSiteQuoteJunc.Wireline_Promotion_Id_Sorted__c = siteQuoteJuncOld[0].Wireline_Promotion_Id_Sorted__c;
                newSiteQuoteJunc.Wireline_Promotion_Id_Applied__c = siteQuoteJuncOld[0].Wireline_Promotion_Id_Applied__c;
                newSiteQuoteJunc.Wireline_Promotion_Name_Applied__c = siteQuoteJuncOld[0].Wireline_Promotion_Name_Applied__c;
                newSiteQuoteJunc.Wireline_Promotion_Number_Applied__c = siteQuoteJuncOld[0].Wireline_Promotion_Number_Applied__c;
            }
            insert newSiteQuoteJunc;
        }
        catch(Exception ex){
            system.debug('@@@Exception in calculateSiteToken method in SiteAddressInformationController: '+ex+' at line number: '+ex.getLineNumber());
        }
    }   

    /*Batch Finish Method*/
    global void finish(Database.BatchableContext BC){
        system.debug('@@@@@@AddSitetoTokenBatch Completed Successfully!!!');
        if(quoteObj.Apttus_Proposal__Approval_Stage__c == 'Bulk Service Availability Requested'){
            quoteObj.Apttus_Proposal__Approval_Stage__c = 'Bulk Service Availability Completed';
        }
        quoteObj.Bulk_Add_Token_Batch_Completed__c = true;
        update quoteObj;
    }
}