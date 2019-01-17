/*************************************************************************************************************************************** 
Apex Class Name     : ApplyPricesForBulkSitesMACD 
Version             : 1.0   
Created Date        : 1 Feb 2016
Function            : This class handles the pricing for offline process for MACD Add Site
***************************************************************************************************************************************/
global class  ApplyPricesForBulkSitesMACD implements Database.Batchable<sObject> {
  
    global final list<Integer> lineNumbers;
    global final set<Id> IglooAvId;
    global final String cartId;
    global final ApttusServiceUtilityHelper helper = new ApttusServiceUtilityHelper();
    
    global ApplyPricesForBulkSitesMACD ( list<Integer> lineNumbers, String cartId) {
        this.lineNumbers = lineNumbers;
        this.cartId = cartId;
    }
    
    global ApplyPricesForBulkSitesMACD ( list<Integer> lineNumbers, String cartId, set<Id> IglooAvId) {
        this.lineNumbers = lineNumbers;
        this.cartId = cartId;
        this.IglooAvId = IglooAvId ;
    }
  
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('@@@Line Numbers: '+lineNumbers);  
        String Query = 'select Id, Apttus_Config2__LineNumber__c,Apttus_Config2__PriceListItemId__c,Port_Speed__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.id,Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c,Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c,MBC_Speed__c,Apttus_Config2__ChargeType__c,Apttus_Config2__NetPrice__c,Apttus_Config2__ListPrice__c,Apttus_Config2__BasePrice__c,Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__ExtendedPrice__c from Apttus_Config2__LineItem__c where Apttus_Config2__PrimaryLineNumber__c IN :lineNumbers'+' and Apttus_Config2__ConfigurationId__c='+'\''+cartId+'\'';
        system.debug('@@Query: '+Query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Apttus_Config2__LineItem__c> lineItems){
        for(Apttus_Config2__LineItem__c lineItem : lineItems) { 
            helper.computePrice(cartId, (Integer)lineItem.Apttus_Config2__LineNumber__c );          
        }    
    }
 
    global void finish(Database.BatchableContext BC){
        Map<String,Apttus_Config2__PriceMatrixEntry__c> netPriceMatrixEntryMap = new Map<String,Apttus_Config2__PriceMatrixEntry__c>();
        List<Apttus_Config2__PriceMatrixEntry__c> matrixEntryList = new List<Apttus_Config2__PriceMatrixEntry__c>();
        list<Apttus_Config2__LineItem__c>  lineItems = [SELECT Id,Apttus_Config2__BaseExtendedCost__c,AccessSpeed__c,Lec_Name__c,Access_Type__c,  Apttus_Config2__PriceListId__r.Name , VASARegion__c,Mileage__c,IsBatchUpdate__c,UBBOveragePrice__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c,Apttus_Config2__PriceListItemId__c,Apttus_Config2__ExtendedPrice__c,Apttus_Config2__PriceListId__c,AT_T_Customer_Site__r.Id ,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.id, Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__ListPrice__c,AdditionalDnsType__c,Port_Speed__c, MBC_Speed__c,Apttus_Config2__BasePrice__c,Apttus_Config2__AttributeValueId__r.VLANs_Logical_Channels__c, isPricingApplied__c, Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c,Apttus_Config2__AttributeValueId__r.Additional_DNS__c, 
                                                        Apttus_Config2__AttributeValueId__r.CoS__c,Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__PrimaryLineNumber__c IN :lineNumbers and Apttus_Config2__ConfigurationId__c= :cartId];      
        
        matrixEntryList = [ select Id,Apttus_Config2__Dimension1Value__c,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ChargeType__c,Description_PL__c,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id , Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Id, Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__PeriodEndDate__c,PriceListName__c from Apttus_Config2__PriceMatrixEntry__c where PriceListName__c=:lineItems[0].Apttus_Config2__PriceListId__r.Name and   Apttus_Config2__PeriodEndDate__c=null];     
        for(Apttus_Config2__PriceMatrixEntry__c priceMatrix: matrixEntryList ){
            netPriceMatrixEntryMap.put(priceMatrix.Apttus_Config2__Dimension1Value__c+priceMatrix.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ChargeType__c+priceMatrix.Description_PL__c+priceMatrix.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Id+priceMatrix.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id,priceMatrix);
        }
        
        for( Apttus_Config2__LineItem__c lineItem : lineItems ){ 
            if(lineItem.Apttus_Config2__ChargeType__c == 'Port Speed Fee'){
                if(!lineItem.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c){
                    if (netPriceMatrixEntryMap.containsKey(lineItem.Port_Speed__c+lineItem.Apttus_Config2__ChargeType__c+lineItem.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c+lineItem.Apttus_Config2__PriceListItemId__c+lineItem.Apttus_Config2__PriceListId__c)) {
                        lineItem.Apttus_Config2__BaseExtendedCost__c = lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__AdjustedPrice__c = lineItem.Apttus_Config2__BaseExtendedPrice__c = lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__ListPrice__c = lineItem.Apttus_Config2__NetPrice__c = netPriceMatrixEntryMap.get(lineItem.Port_Speed__c+lineItem.Apttus_Config2__ChargeType__c+lineItem.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c+lineItem.Apttus_Config2__PriceListItemId__c+lineItem.Apttus_Config2__PriceListId__c).Apttus_Config2__AdjustmentAmount__c;
                    }
                }else{
                    if (netPriceMatrixEntryMap.containsKey(lineItem.Port_Speed__c+lineItem.Apttus_Config2__ChargeType__c+lineItem.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c+lineItem.Apttus_Config2__PriceListItemId__c+lineItem.Apttus_Config2__PriceListId__c)) {
                        lineItem.Apttus_Config2__BaseExtendedCost__c = lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__AdjustedPrice__c = lineItem.Apttus_Config2__BaseExtendedPrice__c = lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__ListPrice__c = lineItem.Apttus_Config2__NetPrice__c = netPriceMatrixEntryMap.get(lineItem.MBC_Speed__c+lineItem.Apttus_Config2__ChargeType__c+lineItem.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c+lineItem.Apttus_Config2__PriceListItemId__c+lineItem.Apttus_Config2__PriceListId__c).Apttus_Config2__AdjustmentAmount__c;    
                    }
                }
            } 
            if(lineItem.Apttus_Config2__ChargeType__c == 'VLAN(s)/Logical Channel' && netPriceMatrixEntryMap.containsKey(lineItem.Port_Speed__c+lineItem.Apttus_Config2__ChargeType__c+lineItem.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c+lineItem.Apttus_Config2__PriceListItemId__c+lineItem.Apttus_Config2__PriceListId__c)){
                lineItem.Apttus_Config2__BaseExtendedCost__c = lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__AdjustedPrice__c = lineItem.Apttus_Config2__BaseExtendedPrice__c = lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__ListPrice__c = lineItem.Apttus_Config2__NetPrice__c = netPriceMatrixEntryMap.get(lineItem.Port_Speed__c+lineItem.Apttus_Config2__ChargeType__c+lineItem.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c+lineItem.Apttus_Config2__PriceListItemId__c+lineItem.Apttus_Config2__PriceListId__c).Apttus_Config2__AdjustmentAmount__c; 
            }    
            lineItem.isPricingApplied__c = true; 
            lineItem.IsBatchUpdate__c = true; 
        }
        update lineItems; 
        if (IglooAvId != null && !IglooAvId.isEmpty()) {
            ID batchprocessid = database.executeBatch(new ApplyPricesForBulkSitesafterigloo(lineNumbers,cartId,IglooAvId),1);
        }  
     }  
}