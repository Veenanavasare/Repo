/************************************************************************************************************************************** 
Apex Class Name     : WirelinePromoCalculationHelper
Version             : 1.0 
Created Date        : 25 October 2017
Function            : This handles the logic for calculation of Wireline Promotion Discounts
***************************************************************************************************************************************/
public class WirelinePromoCalculationHelper{   
   
    public void calculatePromotions(Map<String,List<Wireline_Promotion_Rules__c>> junctionPromoRulesListMap){ 
        try{
            system.debug('@@@junctionPromoRulesListMap: '+junctionPromoRulesListMap);      
            
            //Preparing the Maps from Customer Site Junction for Promotion Calculations
            Boolean isConfigureSite = false;
            Boolean isPromoRemoved = false;
            String quoteId = SpecialCharacterConstant.CONCAT; 
            Date siteQuoteExpDate = null;       
            Set<id> siteids = new Set<id>();        
            List<AT_T_Customer_Site_Quote__c> junctionsList= [SELECT AT_T_Quote__c,AT_T_Customer_Site__c,AT_T_Customer_Site__r.Site_Quote_Expiration_Date__c,Wireline_Promotion_Id_After__c,Wireline_Promotion_Id_Applied__c,Wireline_Promotion_Applied__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__r.Deal_Reg_Approved__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__r.StageName FROM AT_T_Customer_Site_Quote__c WHERE Id =:junctionPromoRulesListMap.keySet()];
           
            Map<String,String> custSiteJunctionMap = new Map<String,String>();
            list<string> wireLinePromos = new list<string>();
            Map<String,String> siteWireLinePromoIdMap = new Map<String,String>();
            Map<String,AT_T_Customer_Site_Quote__c> junctionIdjunctionMap = new Map<String,AT_T_Customer_Site_Quote__c>();
            
            system.debug('@@@junctionsList: '+junctionsList);
            system.debug('@@@junctionsList: '+junctionsList.size());
            if(junctionsList != null && junctionsList.size() > 0){
                quoteId = String.valueOf(junctionsList[0].AT_T_Quote__c).mid(0,15); 
                for(AT_T_Customer_Site_Quote__c junction : junctionsList){
                    junctionIdjunctionMap.put(junction.Id,junction);
                    custSiteJunctionMap.put(junction.AT_T_Customer_Site__c,junction.Id);
                    if(String.isBlank(junction.Wireline_Promotion_Id_Applied__c)){
                        isPromoRemoved = true;  
                        system.debug('@@@==isPromoRemoved: '+isPromoRemoved);                       
                    }
                    system.debug('@@@custSiteJunctionMap: '+custSiteJunctionMap);
                }
                update junctionsList;
            }
            
            if(junctionsList.size()> 0 && junctionsList[0].AT_T_Customer_Site__r.Site_Quote_Expiration_Date__c != null){        
                siteQuoteExpDate = junctionsList[0].AT_T_Customer_Site__r.Site_Quote_Expiration_Date__c;
            }
            //Preparing the Maps from Apttus Line Items for Promotion Calculations
            Apttus_Config2__ProductConfiguration__c prodConfig = new Apttus_Config2__ProductConfiguration__c();
            list<Apttus_Config2__LineItem__c> lineitemsList = new list<Apttus_Config2__LineItem__c>();
            Set<string> attributeValueIds = new Set<string>();
            List<Apttus_Config2__ProductAttributeValue__c> attributeValuelist = new List<Apttus_Config2__ProductAttributeValue__c>();
            Map<String,String> attributeValueMap = new Map<String,String>();
            Map<String,List<Apttus_Config2__LineItem__c>> siteJunctionLineItemsMap = new Map<String,List<Apttus_Config2__LineItem__c>>();
            List<Apttus_Config2__LineItem__c> junctionLineItemsList = new List<Apttus_Config2__LineItem__c>();
            list<Apttus_Proposal__Proposal__c> quoteList = new list<Apttus_Proposal__Proposal__c>();
            quoteList = [Select id,Lowest_Promotion_Expiry_Date__c,Buyflow_Step__c,API_IPQ_Quote__c,Site_Quote_Expiration_Date__c from Apttus_Proposal__Proposal__c where id =: quoteId];
            list<AT_T_Customer_Site_Quote__c> SitesList= new list<AT_T_Customer_Site_Quote__c>();
            SitesList = [SELECT AT_T_Quote__c,AT_T_Customer_Site__c,Wireline_Promotion_Id_Applied__c,Wireline_Promotion_Applied__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c =: quoteId];
            system.debug('@@@SitesList: '+SitesList);
            system.debug('@@@SitesList: '+SitesList.size());
            
            if(SitesList.size() > 0){
                for(AT_T_Customer_Site_Quote__c jnctn: SitesList){
                    if(String.isNotBlank(jnctn.Wireline_Promotion_Id_Applied__c)){
                        wireLinePromos.add(jnctn.Wireline_Promotion_Id_Applied__c);
                    }
                }   
            }
            system.debug('@@@==wireLinePromos: '+wireLinePromos);   
            
            if(quoteList.size() > 0 && quoteList[0].Buyflow_Step__c != null && quoteList[0].Buyflow_Step__c == 'Configure Sites'){
                isConfigureSite = true;
            }
            if(quoteList.size() > 0 && String.isNotBlank(quoteList[0].Lowest_Promotion_Expiry_Date__c) &&  isPromoRemoved == true && wireLinePromos.isEmpty()){
                quoteList[0].Lowest_Promotion_Expiry_Date__c = '';
            }
    
            prodConfig = [select id,Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c=: quoteId order by createddate DESC limit 1];
            system.debug('@@prodConfig' + prodConfig);
            if(prodConfig != null){
                lineitemsList = [SELECT Id,AT_T_Customer_Site__c,AT_T_Customer_Site__r.Id,Quote_Id__c,Name,Apttus_Config2__ListPrice__c,Apttus_Config2__BasePrice__c,Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__ExtendedPrice__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__NetPrice__c,Original_Net_Price__c,Original_Hidden_Price__c,Apttus_Config2__ConfigurationId__c,Apttus_Config2__AttributeValueId__c,Apttus_Config2__ChargeType__c,Wireline_Promotion_Discount_Percentage__c FROM Apttus_Config2__LineItem__c WHERE Quote_Id__c =:quoteId and Apttus_Config2__ConfigurationId__c=: prodConfig.Id and AT_T_Customer_Site__c in: custSiteJunctionMap.keyset()];            
                system.debug('@@lineItemList' + lineitemsList);
                for(Apttus_Config2__LineItem__c item : lineitemsList){             
                    attributeValueMap.put(item.AT_T_Customer_Site__c,item.Apttus_Config2__AttributeValueId__c);
                    
                    system.debug('@@@item: '+item );              
                    if(siteJunctionLineItemsMap.containskey(custSiteJunctionMap.get(item.AT_T_Customer_Site__c))){ 
                        siteJunctionLineItemsMap.get(custSiteJunctionMap.get(item.AT_T_Customer_Site__c)).add(item); 
                        system.debug('@@@inside 1'+siteJunctionLineItemsMap);                       
                    } else if(custSiteJunctionMap.get(item.AT_T_Customer_Site__c) != null){
                        system.debug('@@@junction id: '+custSiteJunctionMap.get(item.AT_T_Customer_Site__c));
                        siteJunctionLineItemsMap.put(custSiteJunctionMap.get(item.AT_T_Customer_Site__c),new list<Apttus_Config2__LineItem__c>{item}); 
                        system.debug('@@@inside 2'+siteJunctionLineItemsMap);
                    } 
                    system.debug('@@@siteJunctionLineItemsMap: '+siteJunctionLineItemsMap);            
                }
            }
            
            system.debug('@@@siteJunctionLineItemsMap:'+siteJunctionLineItemsMap);
            
            
            
            
            map<string,list<string>> portPromoAppliedNameJunctionMap = new map<string,list<string>>();
            map<string,list<string>> accessAppliedNameJunctionMap = new map<string,list<string>>();
            map<string,list<string>> cosFeatureAppliedNameJunctionMap = new map<string,list<string>>();
            map<string,list<string>> dnsFeatureAppliedNameJunctionMap = new map<string,list<string>>();
            map<string,list<string>> ipflexFeatureNameAppliedJunctionMap = new map<string,list<string>>();
            map<string,list<string>> vlanFeatureAppliedNameJunctionMap = new map<string,list<string>>();
            
            map<string,list<string>> portPromoAppliedNumberJunctionMap = new map<string,list<string>>();
            map<string,list<string>> accessAppliedNumberJunctionMap = new map<string,list<string>>();
            map<string,list<string>> cosFeatureAppliedNumberJunctionMap = new map<string,list<string>>();
            map<string,list<string>> dnsFeatureAppliedNumberJunctionMap = new map<string,list<string>>();
            map<string,list<string>> ipflexFeatureNumberAppliedJunctionMap = new map<string,list<string>>();
            map<string,list<string>> vlanFeatureAppliedNumberJunctionMap = new map<string,list<string>>();
            
            //Preparing the Discount Fractions for each Promotion Type
            Map<String,Map<String,Decimal>> junctionFractionMap = new Map<String,Map<String,Decimal>>();
            Map<String,Boolean> junctionAccessNonStackablePromotionNotificationMap = new Map<String,Boolean>();
            Map<String,Map<Decimal,Wireline_Promotion_Rules__c>> junctionNonAccessMap = new Map<String,Map<Decimal,Wireline_Promotion_Rules__c>>();
            for(String junctionId : junctionPromoRulesListMap.keyset()){
                
                list<string> ratecardPromoAppliedNameList = new list<string>();
                list<string> portPromoAppliedNameList = new list<string>();
                list<string> accessAppliedNameList = new list<string>();
                list<string> cosFeatureAppliedNameList = new list<string>();
                list<string> dnsFeatureAppliedNameList = new list<string>();
                list<string> ipflexFeatureAppliedNameList = new list<string>();
                list<string> vlanFeatureAppliedNameList = new list<string>();
                
                list<string> ratecardPromoAppliedNumberList = new list<string>();
                list<string> portPromoAppliedNumberList = new list<string>();
                list<string> accessAppliedNumberList = new list<string>();
                list<string> cosFeatureAppliedNumberList = new list<string>();
                list<string> dnsFeatureAppliedNumberList = new list<string>();
                list<string> ipflexFeatureAppliedNumberList = new list<string>();
                list<string> vlanFeatureAppliedNumberList = new list<string>();
                
                Decimal ratecardDiscountFraction = 1.00;
                Decimal portDiscountFraction = 1.00;
                Decimal accessDiscountFraction = 1.00;
                Decimal accessDiscountFractionNonHidden = 1.00;
                Decimal cosDiscountFraction = 1.00;
                Decimal dnsDiscountFraction = 1.00;            
                Decimal ipflexDiscountFraction = 1.00;
                Decimal vlanDiscountFraction = 1.00;
                Map<Decimal,Wireline_Promotion_Rules__c> nonStackablePortRankDiscountMap = new Map<Decimal,Wireline_Promotion_Rules__c>();              
                Map<Decimal,Wireline_Promotion_Rules__c> nonStackableAccessRankDiscountMap = new Map<Decimal,Wireline_Promotion_Rules__c>();
                Map<Decimal,Wireline_Promotion_Rules__c> nonStackableFeatureRankDiscountMap = new Map<Decimal,Wireline_Promotion_Rules__c>();
                Set<String> promoTypeSet = new Set<String>();
                Map<String,Decimal> promoTypeDiscountFractionMap = new Map<String,Decimal>();
                List<String> promIdList = new List<String>();
                
                List<AT_T_Customer_Site_Quote__c> allJUnctions = new List<AT_T_Customer_Site_Quote__c>();
                allJUnctions = [SELECT id,Wireline_Promotion_Id_Applied__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c =: quoteId]; 
                For(AT_T_Customer_Site_Quote__c juncObj : allJUnctions){
                    if(juncObj.Wireline_Promotion_Id_Applied__c != Null && juncObj.Wireline_Promotion_Id_Applied__c != ''){
                        for(String promId : juncObj.Wireline_Promotion_Id_Applied__c.split(',')){
                            promIdList.add(promId.split('_')[0]);
                        }
                    }
                }
                List<Wireline_Promotion_Rules__c> allPromoRulesList = new List<Wireline_Promotion_Rules__c>();
                allPromoRulesList = [SELECT id,Promotion_Name__c,Discount_Percentage__c,End_Date__c,Promo_Type__c,Field_Inputs__c,Expiry_Notification__c,Promotion_Notification__c,Rank__c,Display_Promotion_End_Date__c,Promotion_Tag__c,Early_Stop_Date__c FROM Wireline_Promotion_Rules__c WHERE Id IN: promIdList];
                
                List<Wireline_Promotion_Rules__c> promoRulesList = junctionPromoRulesListMap.get(junctionId);
                list<Date> expiryDateList = new list<Date>(); 
                list<Date> iPQExpiryDateList = new list<Date>(); 
                date lowestPEDate;
                date minDate;
                date iPQminDate;
                Boolean isPromoExpired = false; 
                        
                if(siteQuoteExpDate != null && quoteList[0].API_IPQ_Quote__c == true){
                    quoteList[0].Site_Quote_Expiration_Date__c = siteQuoteExpDate;     
                }           
                if(!allPromoRulesList.isEmpty() && !quoteList.isEmpty()){
                    for(Wireline_Promotion_Rules__c wprObj : allPromoRulesList){
                        if(wprObj.End_Date__c != null && (quoteList[0].Buyflow_Step__c == 'Configure Sites' || quoteList[0].Buyflow_Step__c == 'Review Quote' || quoteList[0].API_IPQ_Quote__c == true)){
                            if(wprObj.Expiry_Notification__c){
                                expiryDateList.add(wprObj.End_Date__c);
                            }
                            if(wprObj.Display_Promotion_End_Date__c){
                                iPQExpiryDateList.add(wprObj.End_Date__c);
                            }
                            if(!iPQExpiryDateList.isEmpty()){
                                iPQExpiryDateList.sort();
                                iPQminDate = iPQExpiryDateList.get(0);
                            }
                            if(!expiryDateList.isEmpty()){
                                expiryDateList.sort();
                                minDate = expiryDateList.get(0);
                            }
                            system.debug('---siteQuoteExpDate---'+siteQuoteExpDate);
                            if(siteQuoteExpDate != null && iPQminDate != Null && quoteList[0].API_IPQ_Quote__c == true && iPQminDate < siteQuoteExpDate){
                                quoteList[0].Site_Quote_Expiration_Date__c = iPQminDate; 
                            }
                            system.debug('@@@minDate: '+minDate+'---iPQminDate---'+iPQminDate);
                        }
                    }
                }                           
                for(Wireline_Promotion_Rules__c promoRule : promoRulesList){
                    if('Rate Card Map'.equalsIgnoreCase(promoRule.Promo_Type__c)){
                        if(promoRule.Stackable__c){ 
                            system.debug('@@promoRule' + promoRule);
                            ratecardPromoAppliedNameList.add(promoRule.Promotion_Name__c + '_' + promoRule.Promo_Type__c);
                            ratecardPromoAppliedNumberList.add(promoRule.Name + '_' + promoRule.Promo_Type__c);
                            ratecardDiscountFraction = ratecardDiscountFraction*((100-promoRule.Discount_Percentage__c)/100); //Rate Card Discount - Stackable
                        }else{
                            nonStackablePortRankDiscountMap.put(promoRule.Rank__c,promoRule); //Port Discount - Non-Stackable
                        }
                    }
                    if('Port'.equalsIgnoreCase(promoRule.Promo_Type__c)){
                        if(promoRule.Stackable__c){ 
                            system.debug('@@promoRule' + promoRule);
                            portPromoAppliedNameList.add(promoRule.Promotion_Name__c + '_' + promoRule.Promo_Type__c);
                            portPromoAppliedNumberList.add(promoRule.Name + '_' + promoRule.Promo_Type__c);
                            portDiscountFraction = portDiscountFraction*((100-promoRule.Discount_Percentage__c)/100); //Port Discount - Stackable
                        }else{
                            nonStackablePortRankDiscountMap.put(promoRule.Rank__c,promoRule); //Port Discount - Non-Stackable
                        }
                                               
                    }else if('Access'.equalsIgnoreCase(promoRule.Promo_Type__c)){
                        if(promoRule.Stackable__c){
                            accessAppliedNameList.add(promoRule.Promotion_Name__c + '_' + promoRule.Promo_Type__c);
                            accessAppliedNumberList.add(promoRule.Name + '_' + promoRule.Promo_Type__c);
                            accessDiscountFraction = accessDiscountFraction*((100-promoRule.Discount_Percentage__c)/100); //Access Discount - Stackable                     
                            if(promoRule.Promotion_Notification__c){
                                accessDiscountFractionNonHidden = accessDiscountFractionNonHidden*((100-promoRule.Discount_Percentage__c)/100); //Access Discount - Stackable-Hidden
                            }
                        }else{                          
                            nonStackableAccessRankDiscountMap.put(promoRule.Rank__c,promoRule); //Access Discount - Non-Stackable
                        }
                        
                    }else if('Feature'.equalsIgnoreCase(promoRule.Promo_Type__c)){
                        if(!promoRule.Stackable__c){
                            nonStackableFeatureRankDiscountMap.put(promoRule.Rank__c,promoRule); //Feature Discount - Non-Stackable
                        }
                        if((promoRule.Field_Inputs__c.unescapeHtml4()).contains(':CoS;') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';CoS;') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';CoS"') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':CoS|') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';CoS|') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':CoS"')){
                            cosFeatureAppliedNameList.add(promoRule.Promotion_Name__c +'_'+ promoRule.Promo_Type__c);
                            cosFeatureAppliedNumberList.add(promoRule.Name +'_'+ promoRule.Promo_Type__c);
                            cosDiscountFraction = cosDiscountFraction*((100-promoRule.Discount_Percentage__c)/100); //Feature Discount(CoS) - Stackable
                        }
                        if((promoRule.Field_Inputs__c.unescapeHtml4()).contains(':Primary DNS;') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';Primary DNS;') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';Primary DNS"') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':Primary DNS|') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';Primary DNS|') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':Primary DNS"') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':Secondary DNS;') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';Secondary DNS;') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';Secondary DNS"') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':Secondary DNS|') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';Secondary DNS|') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':Secondary DNS"') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':Primary;') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';Primary;') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';Primary"') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':Primary|') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';Primary|') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':Primary"') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':Secondary;') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';Secondary;') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';Secondary"') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':Secondary|') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';Secondary|') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':Secondary"')){
                            dnsFeatureAppliedNameList.add(promoRule.Promotion_Name__c +'_'+ promoRule.Promo_Type__c);
                            dnsFeatureAppliedNumberList.add(promoRule.Name +'_'+ promoRule.Promo_Type__c);
                            dnsDiscountFraction = dnsDiscountFraction*((100-promoRule.Discount_Percentage__c)/100); //Feature Discount(DNS) - Stackable
                        }
                        if((promoRule.Field_Inputs__c.unescapeHtml4()).contains(':IPFLEX;') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';IPFLEX;') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';IPFLEX"') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':IPFLEX|') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';IPFLEX|') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':IPFLEX"')){
                            ipflexFeatureAppliedNameList.add(promoRule.Promotion_Name__c +'_'+ 'Feature');
                            ipflexFeatureAppliedNumberList.add(promoRule.Name +'_'+ promoRule.Promo_Type__c);
                            ipflexDiscountFraction = ipflexDiscountFraction*((100-promoRule.Discount_Percentage__c)/100); //Feature Discount(IPFLEX) - Stackable
                        }
                        if((promoRule.Field_Inputs__c.unescapeHtml4()).contains(':VLAN;') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';VLAN;') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';VLAN"') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':VLAN|') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(';VLAN|') || (promoRule.Field_Inputs__c.unescapeHtml4()).contains(':VLAN"')){
                            vlanFeatureAppliedNameList.add(promoRule.Promotion_Name__c +'_'+ 'Feature');
                            vlanFeatureAppliedNumberList.add(promoRule.Name +'_'+ promoRule.Promo_Type__c);
                            vlanDiscountFraction = vlanDiscountFraction*((100-promoRule.Discount_Percentage__c)/100); //Feature Discount(VLAN) - Stackable
                        }
                    }              
                }
                 
                if(minDate != null && quoteList.size()>0){
                    datetime converttoYY = minDate;
                    string leastDate =  converttoYY.formatGmt('MM/dd/yy');
                    quoteList[0].Lowest_Promotion_Expiry_Date__c = 'Promotion Expires ' + leastDate; 
                }else{
                    quoteList[0].Lowest_Promotion_Expiry_Date__c = ''; 
                }
                
                //Preparing the Non Stackable Discount Fractions 
                
                if(nonStackablePortRankDiscountMap.size() > 0){
                    portPromoAppliedNameList = new list<string>();
                    portPromoAppliedNumberList = new list<string>();
                    List<Decimal> nonStackablePortRankList = new List<Integer>();
                    nonStackablePortRankList.addAll(nonStackablePortRankDiscountMap.keySet());
                    nonStackablePortRankList.sort();
                    Wireline_Promotion_Rules__c lowestRankPortPromo = nonStackablePortRankDiscountMap.get(nonStackablePortRankList[0]);
                    portPromoAppliedNameList.add(lowestRankPortPromo.Promotion_Name__c +'_'+ lowestRankPortPromo.Promo_Type__c);
                    portPromoAppliedNumberList.add(lowestRankPortPromo.Name +'_'+ lowestRankPortPromo.Promo_Type__c);
                    portDiscountFraction = (100-lowestRankPortPromo.Discount_Percentage__c)/100;
                }
                if(nonStackableAccessRankDiscountMap.size() > 0){
                    accessAppliedNameList = new list<string>();
                    accessAppliedNumberList = new list<string>();
                    junctionNonAccessMap.put(junctionId,nonStackableAccessRankDiscountMap);
                    List<Decimal> nonStackableAccessRankList = new List<Integer>();
                    nonStackableAccessRankList.addAll(nonStackableAccessRankDiscountMap.keySet());
                    nonStackableAccessRankList.sort();
                    Wireline_Promotion_Rules__c lowestRankAccessPromo = nonStackableAccessRankDiscountMap.get(nonStackableAccessRankList[0]);
                    accessAppliedNameList.add(lowestRankAccessPromo.Promotion_Name__c +'_'+ lowestRankAccessPromo.Promo_Type__c);
                    accessAppliedNumberList.add(lowestRankAccessPromo.Name +'_'+ lowestRankAccessPromo.Promo_Type__c);
                    accessDiscountFraction = (100-lowestRankAccessPromo.Discount_Percentage__c)/100;                    
                    junctionAccessNonStackablePromotionNotificationMap.put(junctionId,lowestRankAccessPromo.Promotion_Notification__c);             
                }
    
                if(nonStackableFeatureRankDiscountMap.size() > 0){
                    cosFeatureAppliedNameList = new list<string>();
                    dnsFeatureAppliedNameList = new list<string>();
                    ipflexFeatureAppliedNameList = new list<string>();
                    vlanFeatureAppliedNameList = new list<string>();
                    cosFeatureAppliedNumberList = new list<string>();
                    dnsFeatureAppliedNumberList = new list<string>();
                    ipflexFeatureAppliedNumberList = new list<string>();
                    vlanFeatureAppliedNumberList = new list<string>();
                    
                    
                    List<Decimal> nonStackableFeatureRankList = new List<Integer>();
                    nonStackableFeatureRankList.addAll(nonStackableFeatureRankDiscountMap.keySet());
                    nonStackableFeatureRankList.sort();
                    Wireline_Promotion_Rules__c lowestRankFeaturePromo = nonStackableFeatureRankDiscountMap.get(nonStackableFeatureRankList[0]);
                    system.debug('@@lowestRankFeaturePromo' + lowestRankFeaturePromo);
                    if((lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':CoS;') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';CoS;') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';CoS"') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':CoS|') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';CoS|') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':CoS"')){
                        cosFeatureAppliedNameList.add(lowestRankFeaturePromo.Promotion_Name__c +'_'+ lowestRankFeaturePromo.Promo_Type__c);
                        cosFeatureAppliedNumberList.add(lowestRankFeaturePromo.Name +'_'+ lowestRankFeaturePromo.Promo_Type__c);
                        cosDiscountFraction = (100-lowestRankFeaturePromo.Discount_Percentage__c)/100;
                    }
                    if((lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':Primary DNS;') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';Primary DNS;') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';Primary DNS"') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':Primary DNS|') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';Primary DNS|') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':Primary DNS"') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':Secondary DNS;') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';Secondary DNS;') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';Secondary DNS"') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':Secondary DNS|') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';Secondary DNS|') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':Secondary DNS"') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':Primary;') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';Primary;') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';Primary"') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4().unescapeHtml4()).contains(':Primary|') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';Primary|') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':Primary"') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':Secondary;') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';Secondary;') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';Secondary"') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':Secondary|') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';Secondary|') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':Secondary"')){
                        system.debug('@@lowestRankFeaturePromo' + lowestRankFeaturePromo);
                        dnsFeatureAppliedNameList.add(lowestRankFeaturePromo.Promotion_Name__c +'_'+ lowestRankFeaturePromo.Promo_Type__c);
                        dnsFeatureAppliedNumberList.add(lowestRankFeaturePromo.Name +'_'+ lowestRankFeaturePromo.Promo_Type__c);
                        dnsDiscountFraction = (100-lowestRankFeaturePromo.Discount_Percentage__c)/100;
                    }
                    if((lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':IPFLEX;') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';IPFLEX;') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';IPFLEX"') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':IPFLEX|') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';IPFLEX|') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':IPFLEX"')){
                        ipflexFeatureAppliedNameList.add(lowestRankFeaturePromo.Promotion_Name__c +'_'+ lowestRankFeaturePromo.Promo_Type__c);
                        ipflexFeatureAppliedNumberList.add(lowestRankFeaturePromo.Name +'_'+ lowestRankFeaturePromo.Promo_Type__c);
                        ipflexDiscountFraction = (100-lowestRankFeaturePromo.Discount_Percentage__c)/100;
                    }
                     if((lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':VLAN;') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';VLAN;') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';VLAN"') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':VLAN|') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(';VLAN|') || (lowestRankFeaturePromo.Field_Inputs__c.unescapeHtml4()).contains(':VLAN"')){
                        vlanFeatureAppliedNameList.add(lowestRankFeaturePromo.Promotion_Name__c +'_'+ lowestRankFeaturePromo.Promo_Type__c);
                        vlanFeatureAppliedNumberList.add(lowestRankFeaturePromo.Name +'_'+ lowestRankFeaturePromo.Promo_Type__c);
                        vlanDiscountFraction = (100-lowestRankFeaturePromo.Discount_Percentage__c)/100;
                    }
                }
                
                //Preparing the Final Discount Maps for each Promotion Type
                if(portDiscountFraction < 1.00){
                    promoTypeDiscountFractionMap.put('Port',portDiscountFraction);
                }
                if(accessDiscountFraction < 1.00){
                    promoTypeDiscountFractionMap.put('Access',accessDiscountFraction);
                }                                                                              
                if(accessDiscountFractionNonHidden < 1.00){
                    promoTypeDiscountFractionMap.put('AccessNonHidden',accessDiscountFractionNonHidden);
                }
                if(cosDiscountFraction < 1.00){
                    promoTypeDiscountFractionMap.put('CoS',cosDiscountFraction);
                }
                if(dnsDiscountFraction < 1.00){
                    promoTypeDiscountFractionMap.put('AdditionalDNS',dnsDiscountFraction);
                }                                                                             
                if(ipflexDiscountFraction < 1.00){
                    promoTypeDiscountFractionMap.put('IPFLEX',ipflexDiscountFraction);
                }
                if(vlanDiscountFraction < 1.00){
                    promoTypeDiscountFractionMap.put('VLAN',vlanDiscountFraction);
                }          
                junctionFractionMap.put(junctionId,promoTypeDiscountFractionMap);
                
                portPromoAppliedNameJunctionMap.put(junctionId, portPromoAppliedNameList);
                accessAppliedNameJunctionMap.put(junctionId, accessAppliedNameList);
                cosFeatureAppliedNameJunctionMap.put(junctionId, cosFeatureAppliedNameList);
                dnsFeatureAppliedNameJunctionMap.put(junctionId, dnsFeatureAppliedNameList);
                ipflexFeatureNameAppliedJunctionMap.put(junctionId, ipflexFeatureAppliedNameList);
                vlanFeatureAppliedNameJunctionMap.put(junctionId, vlanFeatureAppliedNameList);
                
                portPromoAppliedNumberJunctionMap.put(junctionId, portPromoAppliedNumberList);
                accessAppliedNumberJunctionMap.put(junctionId, accessAppliedNumberList);
                cosFeatureAppliedNumberJunctionMap.put(junctionId, cosFeatureAppliedNumberList);
                dnsFeatureAppliedNumberJunctionMap.put(junctionId, dnsFeatureAppliedNumberList);
                ipflexFeatureNumberAppliedJunctionMap.put(junctionId, ipflexFeatureAppliedNumberList);
                vlanFeatureAppliedNumberJunctionMap.put(junctionId, vlanFeatureAppliedNumberList);
                
                
                
            }
            system.debug('@@@Junction Fraction Map: '+junctionFractionMap);
            
            //Updating Promotions on AV records and applying discounts on Line Items 
            Boolean isLineItemUpdateRequired = false;
            list<Apttus_Config2__LineItem__c> lineitemsListPerSite = new list<Apttus_Config2__LineItem__c>();
            list<Apttus_Config2__LineItem__c> lineItemUpdateList = new list<Apttus_Config2__LineItem__c>();
            Decimal totalPriceBeforePromotions = 0.00;
            Decimal totalPriceAfterPromotions = 0.00;
            Map<String,Boolean> junctionIdAppliedCheckboxMap = new Map<String,Boolean>();
            system.debug('@@@custSiteJunctionMap: '+custSiteJunctionMap);
            system.debug('@@@siteJunctionLineItemsMap:'+siteJunctionLineItemsMap);
            for(String junctionId : custSiteJunctionMap.values()){ 
                totalPriceBeforePromotions = 0.00;
                totalPriceAfterPromotions = 0.00;
                system.debug('@@@junctionId: '+junctionId);
                lineitemsListPerSite = siteJunctionLineItemsMap.get(junctionId);
                system.debug('@@@lineitemsListPerSite : '+lineitemsListPerSite);
                if(lineitemsListPerSite != null && lineitemsListPerSite.size()>0){
                    isLineItemUpdateRequired = true;                                           
                    for(Apttus_Config2__LineItem__c lineItem : lineitemsListPerSite){ 
                        lineItem.Original_Net_Price__c = lineItem.Original_Net_Price__c != null ? lineItem.Original_Net_Price__c : 0.00;                    
                        lineItem.Original_Hidden_Price__c = lineItem.Original_Hidden_Price__c != null ? lineItem.Original_Hidden_Price__c : 0.00;
                        if(lineItem.Apttus_Config2__NetPrice__c > 0.00){
                            if(lineItem.Apttus_Config2__ChargeType__c.equalsIgnoreCase('Port Speed Fee')){
                                system.debug('@@@inside port logic');
                                if(junctionFractionMap.get(junctionId).containsKey('Port')){
                                    system.debug('@@@@Wireline_Promotion_Name_Applied__c' + lineItem.Wireline_Promotion_Name_Applied__c);
                                    //system.debug('@@@@portPromoAppliedNameList' + portPromoAppliedNameList);
                                    lineItem.Original_Net_Price__c = (isConfigureSite || (!isConfigureSite && lineItem.Original_Net_Price__c == 0.00)) ? lineItem.Apttus_Config2__NetPrice__c : lineItem.Original_Net_Price__c;
                                    lineItem.Wireline_Promotion_Discount_Percentage__c = (1-junctionFractionMap.get(junctionId).get('Port'))*100;  
                                    lineItem.Apttus_Config2__NetPrice__c = isConfigureSite ? (lineItem.Apttus_Config2__NetPrice__c*junctionFractionMap.get(junctionId).get('Port')).setscale(2) : (lineItem.Original_Net_Price__c*junctionFractionMap.get(junctionId).get('Port')).setscale(2);
                                    system.debug('@@@@portPromoAppliedNameJunctionMap' + portPromoAppliedNameJunctionMap);
                                    lineItem.Wireline_Promotion_Name_Applied__c = String.join(portPromoAppliedNameJunctionMap.get(junctionId) , ',');
                                    lineItem.Wireline_Promotion_Number_Applied__c = String.join(portPromoAppliedNumberJunctionMap.get(junctionId) , ',');
                                    system.debug('@@@Port Speed with Discounts: '+lineItem);
                                }else{
                                    lineItem.Apttus_Config2__NetPrice__c = (isConfigureSite || (!isConfigureSite && lineItem.Original_Net_Price__c == 0.00)) ? lineItem.Apttus_Config2__NetPrice__c : lineItem.Original_Net_Price__c;
                                    lineItem.Original_Net_Price__c = 0.00;
                                    lineItem.Wireline_Promotion_Discount_Percentage__c = lineItem.WP_Hidden_Discount_Percentage__c = 0;                                
                                    lineItem.Wireline_Promotion_Name_Applied__c = null;
                                    lineItem.Wireline_Promotion_Number_Applied__c = null;
                                    system.debug('@@@Port Speed without Discounts: '+lineItem);
                                } 
                                lineItem.Apttus_Config2__ListPrice__c = lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__BaseExtendedPrice__c = lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__AdjustedPrice__c = lineItem.Apttus_Config2__NetPrice__c;
                                system.debug('@@@@@@line item after port logic'+lineItem);
                            }
                            else if(lineItem.Apttus_Config2__ChargeType__c.containsIgnoreCase('Access Speed')){                            
                                //Only One Promotion-Non Stackable 
                                if(junctionNonAccessMap.size() > 0){ 
                                    //Show Notification - True
                                    if(junctionAccessNonStackablePromotionNotificationMap.size() > 0 && junctionAccessNonStackablePromotionNotificationMap.keyset().contains(junctionId) && junctionAccessNonStackablePromotionNotificationMap.get(junctionId)){ 
                                        lineItem.Original_Net_Price__c = isConfigureSite ? lineItem.Apttus_Config2__NetPrice__c : ((!isConfigureSite && lineItem.Original_Hidden_Price__c != 0.00) ? lineItem.Original_Hidden_Price__c : ((!isConfigureSite && lineItem.Original_Net_Price__c != 0.00) ? lineItem.Original_Net_Price__c: lineItem.Apttus_Config2__NetPrice__c));
                                        if(junctionFractionMap.get(junctionId).containsKey('Access')){
                                            lineItem.Apttus_Config2__NetPrice__c = isConfigureSite ? (lineItem.Apttus_Config2__NetPrice__c*junctionFractionMap.get(junctionId).get('Access')).setscale(2) : (lineItem.Original_Net_Price__c*junctionFractionMap.get(junctionId).get('Access')).setscale(2);
                                        }
                                        lineItem.Original_Hidden_Price__c = lineItem.WP_Hidden_Discount_Percentage__c =  0.00;
                                        lineItem.Wireline_Promotion_Discount_Percentage__c = ((lineItem.Original_Net_Price__c - lineItem.Apttus_Config2__NetPrice__c)/lineItem.Original_Net_Price__c)*100;
                                        lineItem.Wireline_Promotion_Name_Applied__c = String.join(accessAppliedNameJunctionMap.get(junctionId) , ',');
                                        lineItem.Wireline_Promotion_Number_Applied__c = String.join(accessAppliedNumberJunctionMap.get(junctionId) , ',');
                                        system.debug('@@@Non Stackable - Show Promotions - Access Speed : '+lineItem);
                                    }
                                    //Show Notification - False
                                    else if(junctionAccessNonStackablePromotionNotificationMap.size() > 0 && junctionAccessNonStackablePromotionNotificationMap.keyset().contains(junctionId) && !junctionAccessNonStackablePromotionNotificationMap.get(junctionId)){
                                        lineItem.Original_Hidden_Price__c = isConfigureSite ? lineItem.Apttus_Config2__NetPrice__c : ((!isConfigureSite && lineItem.Original_Hidden_Price__c != 0.00) ? lineItem.Original_Hidden_Price__c : ((!isConfigureSite && lineItem.Original_Net_Price__c != 0.00) ? lineItem.Original_Net_Price__c: lineItem.Apttus_Config2__NetPrice__c));
                                        if(junctionFractionMap.get(junctionId).containsKey('Access')){
                                            lineItem.Apttus_Config2__NetPrice__c = isConfigureSite ? (lineItem.Apttus_Config2__NetPrice__c*junctionFractionMap.get(junctionId).get('Access')).setscale(2) : (lineItem.Original_Hidden_Price__c*junctionFractionMap.get(junctionId).get('Access')).setscale(2);
                                        }
                                        lineItem.Original_Net_Price__c = lineItem.Wireline_Promotion_Discount_Percentage__c = 0.00;                                    
                                        lineItem.WP_Hidden_Discount_Percentage__c = ((lineItem.Original_Hidden_Price__c - lineItem.Apttus_Config2__NetPrice__c)/lineItem.Original_Hidden_Price__c)*100;
                                        lineItem.Wireline_Promotion_Name_Applied__c = String.join(accessAppliedNameJunctionMap.get(junctionId) , ',');
                                        lineItem.Wireline_Promotion_Number_Applied__c = String.join(accessAppliedNumberJunctionMap.get(junctionId) , ',');
                                        system.debug('@@@Non Stackable - Hide Promotions - Access Speed : '+lineItem);
                                    }
                                }
                                //One or More Promotions-Stackable                            
                                else if(junctionFractionMap.get(junctionId).containsKey('Access') && junctionFractionMap.get(junctionId).containsKey('AccessNonHidden') && junctionFractionMap.get(junctionId).get('Access') == junctionFractionMap.get(junctionId).get('AccessNonHidden')){    //all show promotions true
                                    lineItem.Original_Net_Price__c = isConfigureSite ? lineItem.Apttus_Config2__NetPrice__c : ((!isConfigureSite && lineItem.Original_Hidden_Price__c != 0.00) ? lineItem.Original_Hidden_Price__c : ((!isConfigureSite && lineItem.Original_Net_Price__c != 0.00) ? lineItem.Original_Net_Price__c: lineItem.Apttus_Config2__NetPrice__c));
                                    lineitem.Apttus_Config2__NetPrice__c = isConfigureSite ? (lineitem.Apttus_Config2__NetPrice__c*junctionFractionMap.get(junctionId).get('Access')).setscale(2) : (lineItem.Original_Net_Price__c*junctionFractionMap.get(junctionId).get('Access')).setscale(2);
                                    lineItem.Original_Hidden_Price__c = lineItem.WP_Hidden_Discount_Percentage__c = 0.00;
                                    lineItem.Wireline_Promotion_Discount_Percentage__c = ((lineItem.Original_Net_Price__c - lineItem.Apttus_Config2__NetPrice__c)/lineItem.Original_Net_Price__c)*100;
                                    lineItem.Wireline_Promotion_Name_Applied__c = String.join(accessAppliedNameJunctionMap.get(junctionId) , ',');
                                    lineItem.Wireline_Promotion_Number_Applied__c = String.join(accessAppliedNumberJunctionMap.get(junctionId) , ',');
                                    system.debug('@@@Stackable - Show Promotions - Access Speed : '+lineItem);
                                }
                                else if(junctionFractionMap.get(junctionId).containsKey('Access') && !junctionFractionMap.get(junctionId).containsKey('AccessNonHidden')){  //all show promotions false
                                    lineItem.Original_Hidden_Price__c = isConfigureSite ? lineItem.Apttus_Config2__NetPrice__c : ((!isConfigureSite && lineItem.Original_Hidden_Price__c != 0.00) ? lineItem.Original_Hidden_Price__c : ((!isConfigureSite && lineItem.Original_Net_Price__c != 0.00) ? lineItem.Original_Net_Price__c: lineItem.Apttus_Config2__NetPrice__c));
                                    lineitem.Apttus_Config2__NetPrice__c = isConfigureSite ? (lineitem.Apttus_Config2__NetPrice__c*junctionFractionMap.get(junctionId).get('Access')).setscale(2) : (lineItem.Original_Hidden_Price__c*junctionFractionMap.get(junctionId).get('Access')).setscale(2);
                                    lineItem.Original_Net_Price__c = lineItem.Wireline_Promotion_Discount_Percentage__c = 0.00;                                
                                    lineItem.WP_Hidden_Discount_Percentage__c = ((lineItem.Original_Hidden_Price__c - lineItem.Apttus_Config2__NetPrice__c)/lineItem.Original_Hidden_Price__c)*100;
                                    lineItem.Wireline_Promotion_Name_Applied__c = String.join(accessAppliedNameJunctionMap.get(junctionId) , ',');
                                    lineItem.Wireline_Promotion_Number_Applied__c = String.join(accessAppliedNumberJunctionMap.get(junctionId) , ',');
                                    system.debug('@@@Stackable - Hide Promotions - Access Speed : '+lineItem);
                                }
                                else if(junctionFractionMap.get(junctionId).containsKey('Access') && junctionFractionMap.get(junctionId).containsKey('AccessNonHidden') && junctionFractionMap.get(junctionId).get('Access') < 1 && junctionFractionMap.get(junctionId).get('AccessNonHidden') < 1){
                                    lineItem.Original_Hidden_Price__c = isConfigureSite ? lineItem.Apttus_Config2__NetPrice__c : ((!isConfigureSite && lineItem.Original_Hidden_Price__c != 0.00) ? lineItem.Original_Hidden_Price__c : ((!isConfigureSite && lineItem.Original_Net_Price__c != 0.00) ? lineItem.Original_Net_Price__c: lineItem.Apttus_Config2__NetPrice__c));
                                    lineItem.Original_Net_Price__c = isConfigureSite ? (lineitem.Apttus_Config2__NetPrice__c*(junctionFractionMap.get(junctionId).get('Access')/junctionFractionMap.get(junctionId).get('AccessNonHidden'))).setscale(2) : (lineitem.Original_Hidden_Price__c * (junctionFractionMap.get(junctionId).get('Access')/junctionFractionMap.get(junctionId).get('AccessNonHidden'))).setscale(2);
                                    lineitem.Apttus_Config2__NetPrice__c = isConfigureSite ? (lineitem.Apttus_Config2__NetPrice__c*junctionFractionMap.get(junctionId).get('Access')).setscale(2) :  (lineitem.Original_Hidden_Price__c *junctionFractionMap.get(junctionId).get('Access')).setscale(2);
                                    lineItem.WP_Hidden_Discount_Percentage__c = ((lineItem.Original_Hidden_Price__c - lineItem.Apttus_Config2__NetPrice__c)/lineItem.Original_Hidden_Price__c)*100;
                                    lineItem.Wireline_Promotion_Discount_Percentage__c = ((lineItem.Original_Net_Price__c - lineItem.Apttus_Config2__NetPrice__c)/lineItem.Original_Net_Price__c)*100;
                                    lineItem.Wireline_Promotion_Name_Applied__c = String.join(accessAppliedNameJunctionMap.get(junctionId) , ',');
                                    lineItem.Wireline_Promotion_Number_Applied__c = String.join(accessAppliedNumberJunctionMap.get(junctionId) , ',');
                                    system.debug('@@@Stackable - Show/Hide Promotions - Access Speed : '+lineItem);
                                }else{
                                    lineItem.Apttus_Config2__NetPrice__c = isConfigureSite ? lineItem.Apttus_Config2__NetPrice__c : ((!isConfigureSite && lineItem.Original_Hidden_Price__c != 0.00) ? lineItem.Original_Hidden_Price__c : ((!isConfigureSite && lineItem.Original_Net_Price__c != 0.00) ? lineItem.Original_Net_Price__c: lineItem.Apttus_Config2__NetPrice__c));
                                    lineItem.Original_Hidden_Price__c = lineItem.Original_Net_Price__c = 0.00;
                                    lineItem.Wireline_Promotion_Discount_Percentage__c = lineItem.WP_Hidden_Discount_Percentage__c = 0;
                                    lineItem.Wireline_Promotion_Name_Applied__c = null;
                                    lineItem.Wireline_Promotion_Number_Applied__c = null;
                                    system.debug('@@@Access Speed without Discounts: '+lineItem); 
                                }                            
                                lineItem.Apttus_Config2__ListPrice__c = lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__BaseExtendedPrice__c = lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__AdjustedPrice__c = lineItem.Apttus_Config2__NetPrice__c;  
                            }                        
                            else if(lineItem.Apttus_Config2__ChargeType__c.equalsIgnoreCase('CoS Fee')){
                                if(junctionFractionMap.get(junctionId).containsKey('CoS')){ 
                                    system.debug('@@@inside cos');                               
                                    lineItem.Original_Net_Price__c = (isConfigureSite || (!isConfigureSite && lineItem.Original_Net_Price__c == 0.00)) ? lineItem.Apttus_Config2__NetPrice__c : lineItem.Original_Net_Price__c;
                                    system.debug('@@@1 - lineItem.Original_Net_Price__c:'+lineItem.Original_Net_Price__c);
                                    lineItem.Wireline_Promotion_Discount_Percentage__c = (1-junctionFractionMap.get(junctionId).get('CoS'))*100;
                                    system.debug('@@@2 - lineItem.Wireline_Promotion_Discount_Percentage__c :'+lineItem.Wireline_Promotion_Discount_Percentage__c );
                                    lineItem.Apttus_Config2__NetPrice__c =  isConfigureSite ? (lineItem.Apttus_Config2__NetPrice__c*junctionFractionMap.get(junctionId).get('CoS')).setscale(2) : (lineItem.Original_Net_Price__c*junctionFractionMap.get(junctionId).get('CoS')).setscale(2);
                                    system.debug('@@@3 - lineItem.Apttus_Config2__NetPrice__c:'+lineItem.Apttus_Config2__NetPrice__c);
                                    lineItem.Apttus_Config2__ListPrice__c = lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__BaseExtendedPrice__c = lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__AdjustedPrice__c = lineItem.Apttus_Config2__NetPrice__c;
                                    lineItem.Wireline_Promotion_Name_Applied__c = String.join(cosFeatureAppliedNameJunctionMap.get(junctionId), ',');
                                    lineitem.Wireline_Promotion_Number_Applied__c = String.join(cosFeatureAppliedNumberJunctionMap.get(junctionId) , ',');
                                    system.debug('@@@CoS Fee with Discounts: '+lineItem); 
                                }else{
                                    lineItem.Apttus_Config2__NetPrice__c = (isConfigureSite || (!isConfigureSite && lineItem.Original_Net_Price__c == 0.00)) ? lineItem.Apttus_Config2__NetPrice__c : lineItem.Original_Net_Price__c;
                                    system.debug('@@@4 - lineItem.Apttus_Config2__NetPrice__c:'+lineItem.Apttus_Config2__NetPrice__c);
                                    lineItem.Original_Hidden_Price__c = lineItem.Original_Net_Price__c = 0.00;
                                    system.debug('@@@5 - lineItem.Original_Hidden_Price__c:'+lineItem.Original_Hidden_Price__c);
                                    lineItem.Wireline_Promotion_Discount_Percentage__c = lineItem.WP_Hidden_Discount_Percentage__c = 0;
                                    lineItem.Wireline_Promotion_Name_Applied__c = null;
                                    lineitem.Wireline_Promotion_Number_Applied__c = null;
                                    system.debug('@@@6 - lineItem.Wireline_Promotion_Discount_Percentage__c:'+lineItem.Wireline_Promotion_Discount_Percentage__c);
                                    system.debug('@@@CoS Fee without Discounts: '+lineItem); 
                                }
                            }
                            else if(lineItem.Apttus_Config2__ChargeType__c.equalsIgnoreCase('Additional DNS Fee')){
                                if(junctionFractionMap.get(junctionId).containsKey('AdditionalDNS')){
                                    lineItem.Original_Net_Price__c = (isConfigureSite || (!isConfigureSite && lineItem.Original_Net_Price__c == 0.00)) ? lineItem.Apttus_Config2__NetPrice__c : lineItem.Original_Net_Price__c;
                                    lineItem.Wireline_Promotion_Discount_Percentage__c = (1-junctionFractionMap.get(junctionId).get('AdditionalDNS'))*100;
                                    lineItem.Apttus_Config2__NetPrice__c = isConfigureSite ? (lineItem.Apttus_Config2__NetPrice__c*junctionFractionMap.get(junctionId).get('AdditionalDNS')).setscale(2) : (lineItem.Original_Net_Price__c*junctionFractionMap.get(junctionId).get('AdditionalDNS')).setscale(2);
                                    lineItem.Apttus_Config2__ListPrice__c = lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__BaseExtendedPrice__c = lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__AdjustedPrice__c = lineItem.Apttus_Config2__NetPrice__c;
                                    lineItem.Wireline_Promotion_Name_Applied__c = String.join(dnsFeatureAppliedNameJunctionMap.get(junctionId), ',');
                                    lineItem.Wireline_Promotion_Number_Applied__c = String.join(dnsFeatureAppliedNumberJunctionMap.get(junctionId), ',');
                                    system.debug('@@@Additional DNS with Discounts: '+lineItem); 
                                }else{
                                    lineItem.Apttus_Config2__NetPrice__c = (isConfigureSite || (!isConfigureSite && lineItem.Original_Net_Price__c == 0.00)) ? lineItem.Apttus_Config2__NetPrice__c : lineItem.Original_Net_Price__c;
                                    lineItem.Original_Hidden_Price__c = lineItem.Original_Net_Price__c = 0.00;
                                    lineItem.Wireline_Promotion_Discount_Percentage__c = lineItem.WP_Hidden_Discount_Percentage__c = 0;
                                    lineItem.Wireline_Promotion_Name_Applied__c = null;
                                    lineItem.Wireline_Promotion_Number_Applied__c = null;
                                    system.debug('@@@Additional DNS without Discounts: '+lineItem); 
                                } 
                            }
                            else if((lineItem.Apttus_Config2__ChargeType__c.equalsIgnoreCase('IP Flex Reach Plan') || lineItem.Apttus_Config2__ChargeType__c.equalsIgnoreCase('VTN Fee') || lineItem.Apttus_Config2__ChargeType__c.equalsIgnoreCase('VoIP') || lineItem.Apttus_Config2__ChargeType__c.equalsIgnoreCase('Enhanced Features') || lineItem.Apttus_Config2__ChargeType__c.equalsIgnoreCase('Setup Fee'))){
                                if(junctionFractionMap.get(junctionId).containsKey('IPFLEX')){        
                                    lineItem.Original_Net_Price__c = (isConfigureSite || (!isConfigureSite && lineItem.Original_Net_Price__c == 0.00)) ? lineItem.Apttus_Config2__NetPrice__c : lineItem.Original_Net_Price__c;
                                    lineItem.Wireline_Promotion_Discount_Percentage__c = (1-junctionFractionMap.get(junctionId).get('IPFLEX'))*100;
                                    lineItem.Apttus_Config2__NetPrice__c = isConfigureSite ? (lineItem.Apttus_Config2__NetPrice__c*junctionFractionMap.get(junctionId).get('IPFLEX')).setscale(2) : (lineItem.Original_Net_Price__c*junctionFractionMap.get(junctionId).get('IPFLEX')).setscale(2);
                                    lineItem.Apttus_Config2__ListPrice__c = lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__BaseExtendedPrice__c = lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__AdjustedPrice__c = lineItem.Apttus_Config2__NetPrice__c;
                                    lineItem.Wireline_Promotion_Name_Applied__c = String.join(ipflexFeatureNameAppliedJunctionMap.get(junctionId), ',');
                                    lineItem.Wireline_Promotion_Number_Applied__c = String.join(ipflexFeatureNumberAppliedJunctionMap.get(junctionId), ',');
                                    system.debug('@@@IPFlex with Discounts: '+lineItem);
                                }else{
                                    lineItem.Apttus_Config2__NetPrice__c = (isConfigureSite || (!isConfigureSite && lineItem.Original_Net_Price__c == 0.00)) ? lineItem.Apttus_Config2__NetPrice__c : lineItem.Original_Net_Price__c;
                                    lineItem.Original_Hidden_Price__c = lineItem.Original_Net_Price__c = 0.00;
                                    lineItem.Wireline_Promotion_Discount_Percentage__c = lineItem.WP_Hidden_Discount_Percentage__c = 0;
                                    lineItem.Wireline_Promotion_Name_Applied__c = null;
                                    lineItem.Wireline_Promotion_Number_Applied__c = null;
                                    system.debug('@@@IPFlex without Discounts: '+lineItem); 
                                }
                            }
                            else if(lineItem.Apttus_Config2__ChargeType__c.equalsIgnoreCase('VLAN(s)/Logical Channel')){
                                if(junctionFractionMap.get(junctionId).containsKey('VLAN')){
                                    lineItem.Original_Net_Price__c = (isConfigureSite || (!isConfigureSite && lineItem.Original_Net_Price__c == 0.00)) ? lineItem.Apttus_Config2__NetPrice__c : lineItem.Original_Net_Price__c;
                                    lineItem.Wireline_Promotion_Discount_Percentage__c = (1-junctionFractionMap.get(junctionId).get('VLAN'))*100;
                                    lineItem.Apttus_Config2__NetPrice__c =  isConfigureSite ? (lineItem.Apttus_Config2__NetPrice__c*junctionFractionMap.get(junctionId).get('VLAN')).setscale(2) : (lineItem.Original_Net_Price__c*junctionFractionMap.get(junctionId).get('VLAN')).setscale(2);
                                    lineItem.Apttus_Config2__ListPrice__c = lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__BaseExtendedPrice__c = lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__AdjustedPrice__c = lineItem.Apttus_Config2__NetPrice__c;
                                    lineItem.Wireline_Promotion_Name_Applied__c = String.join(vlanFeatureAppliedNameJunctionMap.get(junctionId), ',');
                                    lineItem.Wireline_Promotion_Number_Applied__c = String.join(vlanFeatureAppliedNumberJunctionMap.get(junctionId), ',');
                                    system.debug('@@@VLAN with Discounts: '+lineItem); 
                                }else{
                                    lineItem.Apttus_Config2__NetPrice__c = (isConfigureSite || (!isConfigureSite && lineItem.Original_Net_Price__c == 0.00)) ? lineItem.Apttus_Config2__NetPrice__c : lineItem.Original_Net_Price__c;
                                    lineItem.Original_Hidden_Price__c = lineItem.Original_Net_Price__c = 0.00;
                                    lineItem.Wireline_Promotion_Discount_Percentage__c = lineItem.WP_Hidden_Discount_Percentage__c = 0;
                                    lineItem.Wireline_Promotion_Name_Applied__c = null;
                                    lineItem.Wireline_Promotion_Number_Applied__c = null;
                                    system.debug('@@@VLAN without Discounts: '+lineItem); 
                                } 
                            }
                        }
                        
                        //Logic to update the wireline promotions applied checkbox on junction.
                        totalPriceBeforePromotions = (lineItem.Original_Net_Price__c != 0.00) ? totalPriceBeforePromotions + lineItem.Original_Net_Price__c : totalPriceBeforePromotions + lineItem.Apttus_Config2__NetPrice__c;
                        system.debug('totalPriceBeforePromotionsLoop'+totalPriceBeforePromotions);
                        totalPriceAfterPromotions =totalPriceAfterPromotions + lineItem.Apttus_Config2__NetPrice__c;
                        lineItemUpdateList.add(lineItem);
                        system.debug('@@@Final lineItemUpdateList:'+lineItemUpdateList);
                    }        
                    system.debug('totalPriceBeforePromotions'+totalPriceBeforePromotions);
                    system.debug('totalPriceAfterPromotions'+totalPriceAfterPromotions);
                    if(totalPriceBeforePromotions == totalPriceAfterPromotions){
                        junctionIdAppliedCheckboxMap.put(junctionId,false);
                    }else{
                        junctionIdAppliedCheckboxMap.put(junctionId,true);
                    }
                    system.debug('junctionIdAppliedCheckboxMap'+junctionIdAppliedCheckboxMap);
                    junctionIdjunctionMap.get(junctionId).Wireline_Promotion_Applied__c = junctionIdAppliedCheckboxMap.get(junctionId);
                    update junctionIdJunctionMap.values();
                }         
            } 
            if(lineItemUpdateList.size() > 0){
                if(!Test.isRunningTest()){
                    update lineItemUpdateList;               
                }
            }
            system.debug('@@@lineItemUpdateList:'+lineItemUpdateList);
            Boolean isAVUpdateRequired = false;
            attributeValuelist = [select id, Wireline_Promotion_Id__c,AT_T_Customer_Site__c from Apttus_Config2__ProductAttributeValue__c where id IN:attributeValueMap.Values()];
            if(attributeValuelist != null){
                //Logic to filter the correct wireline Promo Ids based on Stackable-Non Stackable criteria
                Set<String> wirelinePromotionRulesIdSet = new Set<String>();
                List<List<Wireline_Promotion_Rules__c>> allPromoRulesNestedList = new List<List<Wireline_Promotion_Rules__c>>();
                allPromoRulesNestedList.addAll(junctionPromoRulesListMap.values());
                for(List<Wireline_Promotion_Rules__c> eachList : allPromoRulesNestedList){
                    for(Wireline_Promotion_Rules__c eachPromo : eachList){
                        wirelinePromotionRulesIdSet.add(eachPromo.Id);
                    }
                }  
                List<Wireline_Promotion_Rules__c> sortedPromotionsList = [SELECT Id,Stackable__c,Rank__c,Promo_Type__c,Promotion_Tag__c,Early_Stop_Date__c FROM Wireline_Promotion_Rules__c WHERE Id IN: wirelinePromotionRulesIdSet ORDER BY Promo_Type__c,Stackable__c,Rank__c];
                for(Apttus_Config2__ProductAttributeValue__c attVal: attributeValuelist){               
                    if(junctionIdjunctionMap.size() > 0 && custSiteJunctionMap.containsKey(attVal.AT_T_Customer_Site__c) &&junctionIdjunctionMap.containsKey(custSiteJunctionMap.get(attVal.AT_T_Customer_Site__c))){
                        attVal.Wireline_Promotion_Id__c = junctionIdjunctionMap.get(custSiteJunctionMap.get(attVal.AT_T_Customer_Site__c)).Wireline_Promotion_Id_Applied__c;
                    }
                }
                update attributeValueList;   
            }        
            if(quoteList != null && quoteList.size()>0){
                update quoteList;
            }
        }
        catch(Exception e){
            system.debug('@@@Exception in calculatePromotions method of WirelinePromoCalculationHelper: ' + e.getLineNumber()+''+e+'Trace is: '+e.getStackTraceString());
        }
    }
}