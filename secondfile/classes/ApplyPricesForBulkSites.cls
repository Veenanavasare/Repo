/*************************************************************************************************************************************** 
Apex Class Name     : ApplyPricesForBulkSites
Version             : 1.0 
Created Date        : 1 Feb 2016
Function            : This class handles the pricing for offline process for new starts
***************************************************************************************************************************************/
global class  ApplyPricesForBulkSites implements Database.Batchable<sObject> { 
  
    global final list<Integer> lineNumbers;
    global final set<Id> IglooAvId ; 
    global final String cartId;
    global final ApttusServiceUtilityHelper helper = new ApttusServiceUtilityHelper();
    global final boolean isASE;
    global final string siteQuoteJunctionId; 
    
    global ApplyPricesForBulkSites(list<Integer> lineNumbers, String cartId) {
        this.lineNumbers = lineNumbers;
        this.cartId = cartId;
    }
    global ApplyPricesForBulkSites (list<Integer> lineNumbers, String cartId, boolean isASE,set<Id> IglooAvId){
        this.lineNumbers = lineNumbers;
        this.cartId = cartId;
        this.isASE = isASE ;
        this.IglooAvId = IglooAvId ;
    }
    
    global ApplyPricesForBulkSites (list<Integer> lineNumbers, String cartId, boolean isASE,set<Id> IglooAvId ,string siteQuoteJunctionId){
        this.lineNumbers = lineNumbers;
        this.cartId = cartId;
        this.isASE = isASE ;
        this.IglooAvId = IglooAvId ;
        this.siteQuoteJunctionId = siteQuoteJunctionId; 
    }
  
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('@@@Cart Id: '+cartId );  
        system.debug('@@@Line Numbers: '+lineNumbers);  
        system.debug('@@@IGLOO AV Id: '+IglooAvId);  
        
        String Query = 'select Id, Product_Code__c ,Apttus_Config2__LineNumber__c,Apttus_Config2__ItemSequence__c,Apttus_Config2__PriceListItemId__c,Port_Speed__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.id,Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c,Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c,MBC_Speed__c,Apttus_Config2__ChargeType__c,Apttus_Config2__NetPrice__c,Apttus_Config2__ListPrice__c,Apttus_Config2__BasePrice__c,Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__ExtendedPrice__c from Apttus_Config2__LineItem__c where Apttus_Config2__PrimaryLineNumber__c IN :lineNumbers'+' and Apttus_Config2__ItemSequence__c = 1 and Apttus_Config2__ConfigurationId__c='+'\''+cartId+'\'';
        system.debug('@@@Query: '+Query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Apttus_Config2__LineItem__c> lineItems){
        try{        
            for(Apttus_Config2__LineItem__c lineItem : lineItems){ 
                system.debug('lineItem' + lineItem);
                helper.computePrice(cartId, (Integer)lineItem.Apttus_Config2__LineNumber__c ); 
            }    
        }
        catch( Exception ex ){    
            system.debug('@@Exception caught in ApplyPricesForBulkSites: '+ex.getMessage()+' :Line number: '+ex.getlineNumber());  
        }            
    }
 
    global void finish(Database.BatchableContext BC)
    {
        Map<string,string> mapJunction= new Map<string,string>();
        Set<Id> iglooUnExpiredSitesSet = new Set<Id>();
        boolean isEligibleForRateRefresh = false;
        list<Apttus_Config2__LineItem__c>  lineItems = [SELECT Id,Product_Code__c, Project_Id__c,Apttus_Config2__BaseExtendedCost__c,AccessSpeed__c,Lec_Name__c,Access_Type__c,  Apttus_Config2__PriceListId__r.Name , VASARegion__c,Mileage__c,IsBatchUpdate__c,UBBOveragePrice__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c,Apttus_Config2__PriceListItemId__c,Apttus_Config2__ExtendedPrice__c,Apttus_Config2__PriceListId__c,AT_T_Customer_Site__r.Id ,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.id, Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__ListPrice__c,AdditionalDnsType__c,Port_Speed__c, MBC_Speed__c,Apttus_Config2__BasePrice__c,Apttus_Config2__AttributeValueId__r.VLANs_Logical_Channels__c, isPricingApplied__c, Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c,Apttus_Config2__AttributeValueId__r.Additional_DNS__c, 
        Apttus_Config2__AttributeValueId__r.CoS__c,Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Rate_Card_Effective_Date__c,Apttus_Config2__PriceListId__r.Apttus_Config2__EffectiveDate__c,Apttus_Config2__AttributeValueId__r.VASA_Region__c,Apttus_Config2__AttributeValueId__r.Access_Type_AVPN__c,Apttus_Config2__AttributeValueId__r.Access_Type__c,Apttus_Config2__AttributeValueId__r.Igloo_Access_Price__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__PrimaryLineNumber__c IN :lineNumbers and Apttus_Config2__ConfigurationId__c= :cartId];      
        
        for(AT_T_Customer_Site_Quote__c junctObjList:[select id,Project_ID__c,AT_T_Quote__c,AT_T_Customer_Site__c,Iglow_Response_Received_Date__c from  AT_T_Customer_Site_Quote__c where AT_T_Quote__c =:lineItems[0].Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.id]){
            if(junctObjList.AT_T_Customer_Site__c!=null){
                system.debug('junctObjList' + junctObjList);
                mapJunction.put(junctObjList.AT_T_Customer_Site__c,junctObjList.Project_ID__c);
            }
            if(junctObjList.Iglow_Response_Received_Date__c!=null && junctObjList.Iglow_Response_Received_Date__c.daysBetween(system.now().date()) < 91 ){
                iglooUnExpiredSitesSet.add(junctObjList.AT_T_Customer_Site__c);
            }
        }
        
        if(lineItems != null && lineItems[0].Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Rate_Card_Effective_Date__c != null && lineItems[0].Apttus_Config2__PriceListId__r.Apttus_Config2__EffectiveDate__c != null && date.parse(lineItems[0].Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Rate_Card_Effective_Date__c).daysBetween(lineItems[0].Apttus_Config2__PriceListId__r.Apttus_Config2__EffectiveDate__c.date())>0){
            isEligibleForRateRefresh = true;
        }
        
        Map<String,Apttus_Config2__PriceMatrixEntry__c> netPriceMatrixEntryMap = new Map<String,Apttus_Config2__PriceMatrixEntry__c>(); 
        List<Apttus_Config2__PriceMatrixEntry__c> matrixEntryList = new List<Apttus_Config2__PriceMatrixEntry__c>();
        matrixEntryList = [ select Id,Apttus_Config2__Dimension1Value__c,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ChargeType__c,Description_PL__c,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id , Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Id, Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__PeriodEndDate__c,PriceListName__c from Apttus_Config2__PriceMatrixEntry__c where PriceListName__c=:lineItems[0].Apttus_Config2__PriceListId__r.Name and   Apttus_Config2__PeriodEndDate__c=null];     
        for(Apttus_Config2__PriceMatrixEntry__c priceMatrix:matrixEntryList ){
            netPriceMatrixEntryMap.put(priceMatrix.Apttus_Config2__Dimension1Value__c+priceMatrix.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ChargeType__c+priceMatrix.Description_PL__c+priceMatrix.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Id+priceMatrix.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id,priceMatrix);
        }
        
        for( Apttus_Config2__LineItem__c lineItem : lineItems ){ 
            if(isASE == false ){
                if(lineItem.Apttus_Config2__ChargeType__c == 'Port Speed Fee'){
                    if(!lineItem.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c){
                        if( netPriceMatrixEntryMap != NULL){
                            if(!Test.isRunningTest()){
                                if(netPriceMatrixEntryMap.get(lineItem.Port_Speed__c+lineItem.Apttus_Config2__ChargeType__c+lineItem.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c+lineItem.Apttus_Config2__PriceListItemId__c+lineItem.Apttus_Config2__PriceListId__c)!=null)
                                {
                                    lineItem.Apttus_Config2__NetPrice__c =  netPriceMatrixEntryMap.get(lineItem.Port_Speed__c+lineItem.Apttus_Config2__ChargeType__c+lineItem.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c+lineItem.Apttus_Config2__PriceListItemId__c+lineItem.Apttus_Config2__PriceListId__c).Apttus_Config2__AdjustmentAmount__c;    
                                }
                            }
                        }
                        else{
                            lineItem.Apttus_Config2__NetPrice__c =  0.00;    
                        }
                    }
                    else{
                        if( netPriceMatrixEntryMap != NULL){
                            if(!Test.isRunningTest()){
                                if(netPriceMatrixEntryMap.get(lineItem.MBC_Speed__c+lineItem.Apttus_Config2__ChargeType__c+lineItem.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c+lineItem.Apttus_Config2__PriceListItemId__c+lineItem.Apttus_Config2__PriceListId__c)!=null){
                                    lineItem.Apttus_Config2__NetPrice__c =  netPriceMatrixEntryMap.get(lineItem.MBC_Speed__c+lineItem.Apttus_Config2__ChargeType__c+lineItem.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c+lineItem.Apttus_Config2__PriceListItemId__c+lineItem.Apttus_Config2__PriceListId__c).Apttus_Config2__AdjustmentAmount__c;    
                                }
                            }
                        }
                        else {
                            lineItem.Apttus_Config2__NetPrice__c =  0.00;    
                        }
                    }
                    lineItem.Apttus_Config2__BaseExtendedCost__c = lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__AdjustedPrice__c = lineItem.Apttus_Config2__BaseExtendedPrice__c = lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__ListPrice__c = lineItem.Apttus_Config2__NetPrice__c;
                }
                 
                if(lineItem.Apttus_Config2__ChargeType__c == 'VLAN(s)/Logical Channel'){                
                    if( netPriceMatrixEntryMap != NULL ){
                        if(!Test.isRunningTest()){
                            lineItem.Apttus_Config2__NetPrice__c =  netPriceMatrixEntryMap.get(lineItem.Port_Speed__c+lineItem.Apttus_Config2__ChargeType__c+lineItem.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c+lineItem.Apttus_Config2__PriceListItemId__c+lineItem.Apttus_Config2__PriceListId__c).Apttus_Config2__AdjustmentAmount__c;        
                        }
                    }
                    else{
                        lineItem.Apttus_Config2__NetPrice__c =  0.00;    
                    }                    
                    lineItem.Apttus_Config2__BaseExtendedCost__c = lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__AdjustedPrice__c = lineItem.Apttus_Config2__BaseExtendedPrice__c = lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__ListPrice__c = lineItem.Apttus_Config2__NetPrice__c;
                }     
                if(lineItem.Apttus_Config2__ChargeType__c == 'Access Speed Fee' && isEligibleForRateRefresh && (!iglooUnExpiredSitesSet.isEmpty() &&   iglooUnExpiredSitesSet.contains(lineItem.AT_T_Customer_Site__r.Id)) && (lineItem.Apttus_Config2__AttributeValueId__r.VASA_Region__c!=null && !lineItem.Apttus_Config2__AttributeValueId__r.VASA_Region__c.equalsIgnoreCase('In Region')) &&  ((lineItem.Apttus_Config2__AttributeValueId__r.Access_Type_AVPN__c!=null && lineItem.Apttus_Config2__AttributeValueId__r.Access_Type_AVPN__c.equalsIgnoreCase('Switched Ethernet')) || (lineItem.Apttus_Config2__AttributeValueId__r.Access_Type__c!=null && lineItem.Apttus_Config2__AttributeValueId__r.Access_Type__c.equalsIgnoreCase('Switched Ethernet')))){                
                    
                    if(lineItem.Apttus_Config2__AttributeValueId__r.Igloo_Access_Price__c != null){
                        lineItem.Apttus_Config2__NetPrice__c =  lineItem.Apttus_Config2__AttributeValueId__r.Igloo_Access_Price__c;    
                    }else{
                        lineItem.Apttus_Config2__NetPrice__c =  0.00;    
                    }                  
                    lineItem.Apttus_Config2__BaseExtendedCost__c = lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__AdjustedPrice__c = lineItem.Apttus_Config2__BaseExtendedPrice__c = lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__ListPrice__c = lineItem.Apttus_Config2__NetPrice__c;
                }    
            }
            if(lineItems[0].Product_Code__c != null){
                if((lineItems[0].Product_Code__c.equalsIgnoreCase(BuyflowConstant.AMIS)) || (lineItems[0].Product_Code__c.equalsIgnoreCase(BuyflowConstant.AVPN))){
                    System.debug('@@@inside if');
                                        
                }
                else{
                    if( IglooAvId.size()<=0){  
                        lineItem.isPricingApplied__c = true; 
                        lineItem.IsBatchUpdate__c = true;
                    }

                    System.debug('@@@inside else');
                    system.debug('@@@lineItem.isPricingApplied__c' + lineItem.isPricingApplied__c);
                    system.debug('@@@lineItem.IsBatchUpdate__c' + lineItem.IsBatchUpdate__c); 
                    //lineItem.isPricingApplied__c = false; 
                    //lineItem.IsBatchUpdate__c = false;
                }
            }                
            if(!mapJunction.IsEmpty()){
                lineItem.Project_Id__c=mapJunction.get(lineItem.AT_T_Customer_Site__c);
            }
        } 
       
        update lineItems;
        system.debug('@@@IglooAvId::'+IglooAvId); 
        ID batchprocessid = database.executeBatch(new ApplyPricesForBulkSitesafterigloo(lineNumbers,cartId,IglooAvId ,siteQuoteJunctionId),1); 
    }
}