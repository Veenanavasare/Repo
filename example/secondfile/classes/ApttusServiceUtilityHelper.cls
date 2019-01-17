/************************************************************************************** 
Apex Class Name     : ApttusServiceUtilityHelper
Version             : 1.0 
Created Date        : 14 Oct 2014
Function            : This class is a uitlity to handle Apttus deal registration
Modification Log    :
* Developer               Date                   Description
* ----------------------------------------------------------------------------                 
* Kumar Gaurav            10/14/2014              Original Version  1.0 
* Accenture IDC           05/15/2015              Updated Version   1.1  
* Upadted Logic for AVPN and MIS to use Attibutes values instaed of option ID/Option Grp
*************************************************************************************/
public with sharing class ApttusServiceUtilityHelper {
    
/*  
 Name: getProductOptionComponentsIdMap  
 Description: 
 */ 
    public Map<string,string> getProductOptionComponentsIdMap(String productId){
        Map<String,String> productOptionComponentMap = new Map<String, String>();
        List<PriceList_Default__c> prlst = null;
        String priceListId = null;
        Apttus_CPQApi.CPQ.ProductOptionGroupSearchResultDO result = null;
        try
        {
            if(productId !=null)
            prlst = [Select Id,PriceList__c from PriceList_Default__c where Product__c =: productId]; 
            if(prlst.size()>0){
                priceListId = prlst[0].PriceList__c;
            }
            if(!String.isempty(priceListId)){
                //passing default pricelist Id and collecting all available option products
                result = Apttus_CPQApi.CPQWebService.getOptionGroupsForPriceListProduct(priceListId,productId);
                Integer counter = 1;
                if(result!= null && result.HasOptionGroups){
                    for(Apttus_CPQApi.CPQ.ProductOptionGroupDO og : result.OptionGroups){
                        if(og.HasOptionComponents){
                            for(Apttus_CPQApi.CPQ.ProductOptionComponentDO pocd: og.OptionComponents){
                                productOptionComponentMap.put(pocd.ComponentProductId, pocd.ComponentId);
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return productOptionComponentMap;
    }
    
    
/* 
 Name: getProductOptionGroupDO
 Description: 
 */ 
    public List<Apttus_CPQApi.CPQ.ProductOptionGroupDO> getProductOptionGroupDO(String productId, String priceListId){
        List<Apttus_CPQApi.CPQ.ProductOptionGroupDO> productOptionList = null;
        Apttus_CPQApi.CPQ.ProductOptionGroupSearchResultDO result = null;
        List<PriceList_Default__c> prlst = null;
        
        try{
            if(String.isempty(priceListId) && productId != null){
                prlst = [Select Id,PriceList__c from PriceList_Default__c where Product__c =: productId]; 
                if(prlst.size()>0){
                    priceListId = prlst[0].PriceList__c;
                }
            }        
            if(!String.isempty(priceListId)){
                //passing default pricelist Id and collecting all available option products
                result = Apttus_CPQApi.CPQWebService.getOptionGroupsForPriceListProduct(priceListId,productId);
                Integer counter = 1;
                if(result!= null && result.HasOptionGroups){
                    productOptionList = result.OptionGroups;                
                }
            }
        }
        catch(Exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return productOptionList;
    }
    
    /* Memthod to fecth the price based on date criteria from the latest rate cards for BULK Transaction */
    
/* 
 Name: getLatestPriceFromRateforBulk
 Description: 
 */ 
     public  decimal getLatestPriceFromRateforBulk(String selectedMBCwithMBps,String chargeType,String description,Id plid,Id qid, ID quoteId){
   
     try{
                decimal amount;
                amount=0.00;
                List<Apttus_Proposal__Proposal__c> quoteObj = [select Id,DealHash__c,Name,MACD_Change_Type__c,subAccountNumber__c,Apttus_QPConfig__PriceListId__r.Id, Opportunity_Owner_Email__c, Docusign_Envelope__c, Denial_Reason__c, Contract_Read__c, End_Customer__c, Contract_Signed__c, End_Customer__r.Name,End_Customer__r.Mailing_Street_Address__c,End_Customer__r.City__c, Product__r.name, End_Customer__r.Zip__c,End_Customer__r.State__c, Apttus_Proposal__Payment_Term__c, Apttus_Proposal__Proposal_Name__c,Product_Name__c, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where id = :quoteId];
                list<Apttus_Config2__PriceMatrixEntry__c> matrixEntryList = [ select Id,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id , Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__PeriodEndDate__c from Apttus_Config2__PriceMatrixEntry__c where  (Apttus_Config2__Dimension1Value__c =:selectedMBCwithMBps  and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ChargeType__c =:chargeType and Description_PL__c =:description and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id =:qid and  Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Id=:plid and  Apttus_Config2__PeriodEndDate__c=null)];
                //logic to fecth a single price on multiple retrevals
                if( matrixEntryList.size() > 0 ){
                    boolean priceFound = false;
                    for( Apttus_Config2__PriceMatrixEntry__c priceMatrix : matrixEntryList  ){
                       amount = priceMatrix.Apttus_Config2__AdjustmentAmount__c; // Returning only amount witho discount.
                        }
                    }
                else {
                    return 0.00;
                }
                
                return amount ;
               }
             catch(Exception ex){
                
                ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        return null;
             }
   
   
           
     }
     
/* 
 Name: getLatestPriceFromRate
 Description: 
 */ 
     public  decimal getLatestPriceFromRate(String selectedMBCwithMBps,String chargeType,String description,Id plid,Id qid, ID quoteId){
   
     try{
                decimal amount;
                amount=0.00;
                List<Apttus_Proposal__Proposal__c> quoteObj = [select Id,DealHash__c, MasterOpportunity__r.RDS_Deal_Hash__r.Id ,Name,MACD_Change_Type__c,subAccountNumber__c,Apttus_QPConfig__PriceListId__r.Id, Opportunity_Owner_Email__c, Docusign_Envelope__c, Denial_Reason__c, Contract_Read__c, End_Customer__c, Contract_Signed__c, End_Customer__r.Name,End_Customer__r.Mailing_Street_Address__c,End_Customer__r.City__c, Product__r.name, End_Customer__r.Zip__c,End_Customer__r.State__c, Apttus_Proposal__Payment_Term__c, Apttus_Proposal__Proposal_Name__c,Product_Name__c, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where id = :quoteId];
                Deal_Hash__c dealHash=[SELECT id,Rate_Stability_Date__c,StabilityDate__c,Sub_Account_Number__c FROM Deal_Hash__c where ID =:quoteObj[0].MasterOpportunity__r.RDS_Deal_Hash__r.Id   LIMIT 1];   
                if(dealHash!=null){
                list<Apttus_Config2__PriceMatrixEntry__c> matrixEntryList = [ select Id,Apttus_Config2__PeriodStartDate__c,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id , Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__PeriodEndDate__c from Apttus_Config2__PriceMatrixEntry__c where  (Apttus_Config2__Dimension1Value__c =:selectedMBCwithMBps  and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ChargeType__c =:chargeType and Description_PL__c =:description and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id =:qid and  Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Id=:plid)];
                //logic to fecth a single price on multiple retrevals
                if( matrixEntryList.size() > 0 ){
                    boolean priceFound = false;
                    for( Apttus_Config2__PriceMatrixEntry__c priceMatrix : matrixEntryList  ){
                        
                        if( priceMatrix.Apttus_Config2__PeriodEndDate__c != null && priceMatrix.Apttus_Config2__PeriodStartDate__c<=dealHash.StabilityDate__c &&  priceMatrix.Apttus_Config2__PeriodEndDate__c >= dealHash.StabilityDate__c){
                            priceFound = true;
                            amount = priceMatrix.Apttus_Config2__AdjustmentAmount__c; // Returning only amount witho discount.
                            
                        }
                        else if( !priceFound &&  priceMatrix.Apttus_Config2__PeriodEndDate__c == null  ){
                            amount = priceMatrix.Apttus_Config2__AdjustmentAmount__c; // Returning only amount witho discount.
                            }
                        }
                    }
                else {
                    return 0.00;
                }
                }
                return amount ;
                
               }
             catch(Exception ex){
               
                ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        return null;
             }
   
   
           
     }
    
    /* Memthod to fecth the price based on date criteria from the latest rate cards */
    
/* 
 Name: getLatestPriceFromRateOld
 Description: 
 */ 
     public  decimal getLatestPriceFromRateOld(String selectedMBCwithMBps,String chargeType,String description,Id plid,Id qid, ID quoteId){
   
     try{
                decimal amount;
                amount=0.00;
                List<Apttus_Proposal__Proposal__c> quoteObj = [select Id,DealHash__c,Name,MACD_Change_Type__c,subAccountNumber__c,Apttus_QPConfig__PriceListId__r.Id, Opportunity_Owner_Email__c, Docusign_Envelope__c, Denial_Reason__c, Contract_Read__c, End_Customer__c, Contract_Signed__c, End_Customer__r.Name,End_Customer__r.Mailing_Street_Address__c,End_Customer__r.City__c, Product__r.name, End_Customer__r.Zip__c,End_Customer__r.State__c, Apttus_Proposal__Payment_Term__c, Apttus_Proposal__Proposal_Name__c,Product_Name__c, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where id = :quoteId];
                Deal_Hash__c dealHash=[SELECT id,Rate_Stability_Date__c,StabilityDate__c,Sub_Account_Number__c FROM Deal_Hash__c where Name=:quoteObj[0].DealHash__c  LIMIT 1];   
                list<Apttus_Config2__PriceMatrixEntry__c> matrixEntryList = [ select Id,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id , Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__PeriodEndDate__c from Apttus_Config2__PriceMatrixEntry__c where  (Apttus_Config2__Dimension1Value__c =:selectedMBCwithMBps  and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ChargeType__c =:chargeType and Description_PL__c =:description and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id =:qid and  Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Id=:plid)];
                //logic to fecth a single price on multiple retrevals
                if( matrixEntryList.size() > 0 ){
                    boolean priceFound = false;
                    for( Apttus_Config2__PriceMatrixEntry__c priceMatrix : matrixEntryList  ){
                        
                        if( priceMatrix.Apttus_Config2__PeriodEndDate__c != null && priceMatrix.Apttus_Config2__PeriodEndDate__c >= dealHash.StabilityDate__c){
                            priceFound = true;
                            amount = priceMatrix.Apttus_Config2__AdjustmentAmount__c; // Returning only amount witho discount.
                            
                        }
                        else if( !priceFound &&  priceMatrix.Apttus_Config2__PeriodEndDate__c == null  ){
                            amount = priceMatrix.Apttus_Config2__AdjustmentAmount__c; // Returning only amount witho discount.
                            }
                        }
                    }
                else {
                    return 0.00;
                }
                
                return amount ;
               }
             catch(Exception ex){
        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));

                return null;
             }
   
   
           
     }
     
/* 
 Name: calculateAccessSpeedFeeTotal
 Description: 
 */ 
     public decimal calculateAccessSpeedFeeTotal( List<Apttus_Config2__LineItem__c> listItems ){
        Decimal accessTotalFee = 0.00;
        try{
        for( Apttus_Config2__LineItem__c eachLineItem : listItems ){
            if( eachLineItem.Apttus_Config2__ChargeType__c != null && eachLineItem.Apttus_Config2__ChargeType__c.containsIgnoreCase(UtilityConstant.ACCESSSPEED)){
                
                accessTotalFee += eachLineItem.Apttus_Config2__NetPrice__c.setScale(2);
            }
        
        }
        return accessTotalFee;
        } catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            
            return null;
    }
     }
   
 
/* 
 Name: getLatestOverragePrice
 Description: 
 */ 
   public  Map<String,Decimal> getLatestOverragePrice(String ProductCode, ID quoteId){
                Date quoteEffectiveDate;
                Deal_Hash__c dealhash;
                String subAccountNumber;
                String tier;
                try{
                List<Apttus_Proposal__Proposal__c> quoteObj = [select Id,MACDMasterTier__c,RelatedPremise__r.DealHash__r.Sub_Account_Number__c,QuoteExpirationDate__c,Rate_Card_Effective_Date__c,DealHash__c,Term__c,Apttus_Proposal__Account__r.Master_Agent__c,Apttus_Proposal__Account__r.Current_Tier__c,Name,MACD_Change_Type__c,subAccountNumber__c,Apttus_QPConfig__PriceListId__r.Id, Opportunity_Owner_Email__c, Docusign_Envelope__c, Denial_Reason__c, Contract_Read__c, End_Customer__c, Contract_Signed__c, End_Customer__r.Name,End_Customer__r.Mailing_Street_Address__c,End_Customer__r.City__c, Product__r.name, End_Customer__r.Zip__c,End_Customer__r.State__c, Apttus_Proposal__Payment_Term__c, Apttus_Proposal__Proposal_Name__c,Product_Name__c, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where id = :quoteId];
                if(quoteObj[0].subAccountNumber__c !=null){
                subAccountNumber=quoteObj[0].subAccountNumber__c;
                }else{
                 subAccountNumber=quoteObj[0].RelatedPremise__r.DealHash__r.Sub_Account_Number__c;
                } 
                if(subAccountNumber!=null){
                 dealHash=[SELECT id,Rate_Stability_Date__c,StabilityDate__c,Sub_Account_Number__c FROM Deal_Hash__c where Sub_Account_Number__c=:subAccountNumber  LIMIT 1];      
                }
                map<string, OverragePrice__c> mbcToOverageMap= new Map<string, OverragePrice__c>();
                map<string, decimal> tempMap = new map<string, decimal>();
                string field;
        // Fix for QC SEV1  Defects 202300/202298 
                if(quoteObj[0].MACD_Change_Type__c!=null){
                    tier=quoteObj[0].MACDMasterTier__c;
                }else if (quoteObj[0].Apttus_Proposal__Account__r.Master_Agent__c){
                    tier=UtilityConstant.SILVER;
                }else{
                    tier=quoteObj[0].Apttus_Proposal__Account__r.Current_Tier__c;
                }
                if(tier==UtilityConstant.PLATINUM || tier==UtilityConstant.BASIC){
                    field = UtilityConstant.PLATINUM_C;
                }
                else if(tier==UtilityConstant.PLATINUMELITE || tier==UtilityConstant.GOLD){
                    field = UtilityConstant.PLATINUMELITE_C;
                }
                else if(tier==UtilityConstant.SILVER || quoteObj[0].Apttus_Proposal__Account__r.Master_Agent__c){
                    field = UtilityConstant.MASTERAGENT_C;
                }

                 
             if(dealhash!=null){
                 quoteEffectiveDate=Date.ValueOf(dealHash.StabilityDate__c);
             }else{    
                 String datval=String.ValueOf(Date.Parse(quoteObj[0].Rate_Card_Effective_Date__c));
                 quoteEffectiveDate=Date.ValueOf(Datval);
             } 
             list<OverragePrice__c> overageList = [SELECT Master_Agent__c,Name,OwnerId,Platinum_Elite__c,Platinum__c,ProductCode__c,RateEffectiveDate__c,RateExpiredDate__c,Speeds__c,Term__c FROM OverragePrice__c where  ProductCode__c=:ProductCode  and Term__c=:quoteObj[0].Term__c ]; 
             for(OverragePrice__c overage:overageList){
               if(overage.RateEffectiveDate__c<=quoteEffectiveDate && (overage.RateExpiredDate__c>=quoteEffectiveDate|| overage.RateExpiredDate__c==null )){
                    mbcToOverageMap.put(overage.Speeds__c+SpecialCharacterConstant.COMMA+Overage.Name,overage) ;  
                }
                
             }
       
             for(string mbcSpeed : mbcToOverageMap.keySet()){
              list<string>  keyArray = mbcSpeed.split(SpecialCharacterConstant.COMMA);
              String  keyWithoutName = KeyArray[0]; 
              if(mbcToOverageMap.get(mbcSpeed ) != null){
                if(mbcToOverageMap.get(mbcSpeed ).get(field) != null){
                    string price = string.valueOf(mbcToOverageMap.get(mbcSpeed).get(field));
                    tempMap.put(KeyWithoutName, decimal.valueOf(price).setscale(2));  
                    
                }
            }
           }
         return tempMap;
                } catch(Exception ex){
                    ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
                    
                    return null;
                }
    
        }
   
    //ends here
    
/* 
 Name: getMACDOverragePrice
 Description: 
 */ 
    public decimal getMACDOverragePrice(String selectedMBCwithMBps,String ProductCode,Id quoteID){
   
     try{
                Date quoteEffectiveDate;
                Deal_Hash__c dealhash;
                String subAccountNumber;
                String speed= selectedMBCwithMBps.deleteWhitespace();
                String tier;
                decimal amount;
                amount=0.00;
                List<Apttus_Proposal__Proposal__c> quoteObj = [select Id,MACDMasterTier__c,DealHash__c,Term__c,RelatedPremise__r.DealHash__r.Sub_Account_Number__c,Apttus_Proposal__Account__r.Master_Agent__c,Apttus_Proposal__Account__r.Current_Tier__c,Name,MACD_Change_Type__c,subAccountNumber__c,Apttus_QPConfig__PriceListId__r.Id, Opportunity_Owner_Email__c, Docusign_Envelope__c, Denial_Reason__c, Contract_Read__c, End_Customer__c, Contract_Signed__c, End_Customer__r.Name,End_Customer__r.Mailing_Street_Address__c,End_Customer__r.City__c, Product__r.name, End_Customer__r.Zip__c,End_Customer__r.State__c, Apttus_Proposal__Payment_Term__c, Apttus_Proposal__Proposal_Name__c,Product_Name__c, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where id = :quoteId];
                if(quoteObj[0].subAccountNumber__c !=null){
                subAccountNumber=quoteObj[0].subAccountNumber__c;
                }else{
                 subAccountNumber=quoteObj[0].RelatedPremise__r.DealHash__r.Sub_Account_Number__c;
                } 
                if(subAccountNumber!=null){
                 dealHash=[SELECT id,Rate_Stability_Date__c,StabilityDate__c,Sub_Account_Number__c FROM Deal_Hash__c where Sub_Account_Number__c=:subAccountNumber  LIMIT 1];      
                }
                list<OverragePrice__c> overageList = [SELECT Master_Agent__c,Name,OwnerId,Platinum_Elite__c,Platinum__c,ProductCode__c,RateEffectiveDate__c,RateExpiredDate__c,Speeds__c,Term__c FROM OverragePrice__c where Speeds__c=:speed and ProductCode__c=:ProductCode  and Term__c=:quoteObj[0].Term__c];
                //logic to fecth a single price on multiple retrevals
                if(quoteObj[0].MACD_Change_Type__c!=null){
                  tier=quoteObj[0].MACDMasterTier__c;
                   }else{
                  tier= quoteObj[0].Apttus_Proposal__Account__r.Current_Tier__c;
                }
                if(dealhash!=null){
                 quoteEffectiveDate =Date.ValueOf(dealHash.StabilityDate__c);
                 }
                if( overageList.size() > 0 ){
                  
                    for( OverragePrice__c overage : overageList ){
                          
                          if(overage.RateEffectiveDate__c<=quoteEffectiveDate && (overage.RateExpiredDate__c>=quoteEffectiveDate || overage.RateExpiredDate__c==null )){
                            
                            if(tier==UtilityConstant.PLATINUM || tier==UtilityConstant.BASIC){
                             amount = Double.valueOf(overage .Platinum__c); 
                             }else if(tier==UtilityConstant.PLATINUMELITE || tier==UtilityConstant.GOLD){
                             amount =  Double.valueOf(overage .Platinum_Elite__c); // Returning only amount witho discount.
                             }else if(tier==UtilityConstant.SILVER || quoteObj[0].Apttus_Proposal__Account__r.Master_Agent__c ){
                             amount = Double.valueOf(overage .Master_Agent__c); // Returning only amount witho discount.
                             }
                            
                        }
                        
                    }
                   }
                else {
                    return 0.00;
                }
                
                return amount.setScale(2) ;
                 
               }
              catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
                
                return null;
             }
   
   
           
     }
     // ends here 
     
      /************************************Method for gettingLatestRateEffectiveDate *****************************************/
      /*
        Method Name :getQuoteEffectiveDate
        Method Description: To get the latest Rate Card Effective Date for AVPN and MIS products based on Tier and Term
      */
     Public String getQuoteEffectiveDate(ID quoteId){
      String dt;
    //Code to populate Rate Card Effective Date for AVPN and MIS products based on Tier and Term
        List<Apttus_Proposal__Proposal__c> proposals= [select id,Name,Apttus_Proposal__Payment_Term__c,Apttus_Proposal__Account__c,Product_Name__c from Apttus_Proposal__Proposal__c where id = :quoteId];                
        Set<Id> accountIdSet = new Set<Id>();
        try{
        for (Apttus_Proposal__Proposal__c item : proposals){
            accountIdSet.add(item.Apttus_Proposal__Account__c);
        }
        Map <Id, Account> accMap = new Map<Id,Account>([SELECT id,Master_Agent__c,Current_Tier__c from Account where Id in :accountIdSet]); 
        if (proposals!=NULL && proposals.size()>0 ){    
            for (Apttus_Proposal__Proposal__c item : proposals){                    
                if(proposals[0].Product_Name__c == UtilityConstant.ATT_VIRTUAL_PRIVATE_NETWORK){
                    if(accMap.get(item.Apttus_Proposal__Account__c).Master_Agent__c){
                        if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_1YEAR){
                            item.Rate_Card_Effective_Date__c = System.Label.AVPN_1_year_Master_Agent;
                        }
                        else if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_3YEARS){
                            item.Rate_Card_Effective_Date__c = System.Label.AVPN_3_year_Master_Agent;
                        }
                     }
                     else if(accMap.get(item.Apttus_Proposal__Account__c).Current_Tier__c == UtilityConstant.GOLD){
                        if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_1YEAR){
                            item.Rate_Card_Effective_Date__c = System.Label.AVPN_1_year_Platinum_Elite;
                        }
                        else if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_3YEARS){
                            item.Rate_Card_Effective_Date__c = System.Label.AVPN_3_year_Platinum_Elite;
                        }
                     }
                     else if(accMap.get(item.Apttus_Proposal__Account__c).Current_Tier__c == UtilityConstant.PLATINUM){
                        if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_1YEAR){
                            item.Rate_Card_Effective_Date__c = System.Label.AVPN_1_year_Platinum;
                        }
                        else if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_3YEARS){
                            item.Rate_Card_Effective_Date__c = System.Label.AVPN_3_year_Platinum;
                        }
                     }
                     else if(accMap.get(item.Apttus_Proposal__Account__c).Current_Tier__c == UtilityConstant.SILVER){
                        if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_1YEAR){
                            item.Rate_Card_Effective_Date__c = System.Label.AVPN_1_year_Master_Agent;
                        }
                        else if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_3YEARS){
                            item.Rate_Card_Effective_Date__c = System.Label.AVPN_3_year_Master_Agent;
                        }
                     }
                 }
                 else if(proposals[0].Product_Name__c == UtilityConstant.ATT_MANAGED_INTERNET_SERVICE){
                     if(accMap.get(item.Apttus_Proposal__Account__c).Master_Agent__c){
                        if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_1YEAR){
                            item.Rate_Card_Effective_Date__c = System.Label.MIS_1_year_Master_Agent;
                        }
                        else if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_3YEARS){
                            item.Rate_Card_Effective_Date__c = System.Label.MIS_3_year_Master_Agent;
                        }
                     }
                     else if(accMap.get(item.Apttus_Proposal__Account__c).Current_Tier__c == UtilityConstant.GOLD){
                        if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_1YEAR){
                            item.Rate_Card_Effective_Date__c = System.Label.MIS_1_year_Platinum_Elite;
                        }
                        else if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_3YEARS){
                            item.Rate_Card_Effective_Date__c = System.Label.MIS_3_year_Platinum_Elite;
                        }
                     }
                     else if(accMap.get(item.Apttus_Proposal__Account__c).Current_Tier__c == UtilityConstant.PLATINUM){
                        if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_1YEAR){
                            item.Rate_Card_Effective_Date__c = System.Label.MIS_1_year_Platinum;
                        }
                        else if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_3YEARS){
                            item.Rate_Card_Effective_Date__c = System.Label.MIS_3_year_Platinum;
                        }
                     }
                     else if(accMap.get(item.Apttus_Proposal__Account__c).Current_Tier__c == UtilityConstant.SILVER){
                        if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_1YEAR){
                            item.Rate_Card_Effective_Date__c = System.Label.MIS_1_year_Master_Agent;
                        }
                        else if(item.Apttus_Proposal__Payment_Term__c == UtilityConstant.SIVARConst_3YEARS){
                            item.Rate_Card_Effective_Date__c = System.Label.MIS_3_year_Master_Agent;
                        }
                     }
                 }
                 else{
                     item.Rate_Card_Effective_Date__c = null;
                 }
                 dt=item.Rate_Card_Effective_Date__c;
             }
             
         }
        return dt;
    
    } catch(Exception ex){
        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        
        return null;
    }
     }
       
     //ends here   
    
/* 
 Name: createCart
 Description: 
 */ 
    public String createCart(String quoteId){
        //CREATE CART
        system.debug('@@@@linee 490'+quoteId);
        String cartId;
        Apttus_CPQApi.CPQ.CreateCartRequestDO request = null;
        Apttus_CPQApi.CPQ.CreateCartResponseDO cartRespDO = null;
        system.debug('@@@@linee 494');
        try
        {
            request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
            request.QuoteID = quoteId;
            system.debug('@@@@line 499'+request.QuoteID);
            cartRespDO = Apttus_CPQApi.CPQWebService.CreateCart(request);
            system.debug('@@@line 501'+cartRespDO.cartID);
            cartId = cartRespDO.cartID;
        }
        catch(Exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return cartId;
    }
    /**********************************************************************************************************************************************************************************************************/    
    public Map<string,string> createBundle(List<SiteProductDetails> spdsLst, Map<string,string> optionsMap, String cartId)
    {
        Map<string,string> siteLinenumberMap = new Map<string,string>();
        
        //Adding products based upon number of sites selected and its products
        try
        {
            for(SiteProductDetails sadt : spdsLst){
                Apttus_CPQApi.CPQ.AddBundleRequestDO requestAdBun = new Apttus_CPQApi.CPQ.AddBundleRequestDO();
                requestAdBun.CartId = cartID;
                Apttus_cPQApi.CPQ.SelectedProductDO selectedProduct = new Apttus_CPQApi.CPQ.SelectedProductDO();
                requestAdBun.SelectedBundle = new Apttus_CPQApi.CPQ.SelectedBundleDO();
                SelectedProduct.ProductId = sadt.parentProductId;
                SelectedProduct.Quantity = 1;
                SelectedProduct.SellingTerm = 1;
                SelectedProduct.StartDate = Date.Today();
                SelectedProduct.EndDate = Date.Today() + 12;
                SelectedProduct.Comments = UtilityConstant.ADDEDBY_CODE; 
                List<Apttus_CPQApi.CPQ.SelectedOptionDO> optionDOList = new List<Apttus_CPQApi.CPQ.SelectedOptionDO>();
                //for(QuoteLineItems qli : quoteInformation.QuoteLineItems){
                for(String  pid : sadt.productSetIds){
                    Apttus_cPQApi.CPQ.SelectedOptionDO selectedOption = new Apttus_CPQApi.CPQ.SelectedOptionDO();
                    SelectedOption.ComponentId = optionsMap.get(pid);
                    SelectedOption.ComponentProductId = pid;
                    SelectedOption.Quantity = 1;
                    SelectedOption.SellingTerm = 1;
                    SelectedOption.StartDate = Date.Today();
                    SelectedOption.EndDate = Date.Today() + 12;
                    SelectedOption.Comments = UtilityConstant.ADDEDBY_CODE; 
                    optionDOList.add(SelectedOption);
                }
                requestAdBun.SelectedBundle.SelectedProduct = SelectedProduct;
                requestAdBun.SelectedBundle.SelectedOptions = optionDOList;
                Apttus_CPQApi.CPQ.AddBundleResponseDO response = Apttus_CPQApi.CPQWebService.addBundle(requestAdBun);
                siteLinenumberMap.put(String.valueof(response.LineNumber), sadt.siteAddressId);
            } 
        }
        catch(Exception e)
        {
          ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));  
        }
        return siteLinenumberMap;
    }
    
/* 
 Name: computePrice
 Description: 
 */ 
    public boolean computePrice(String cartId, Integer lineNumber){
        //RE-PRICE 
        system.debug('inside compute price');
        Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO netRequest = null;
        Apttus_CPQApi.CPQ.ComputeNetPriceResponseDO res = null;
        boolean isSuccess = false;
        try{
            netRequest = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            netRequest.CartId = cartId;
            netRequest.LineNumber = Integer.valueof(lineNumber);
            if(!test.isrunningTest()){
            res = Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(netRequest);
            isSuccess = res.IsSuccess;
            }
            return isSuccess;
            //computeMBCPriceAndUpdateCart(cartId, lineNumber); //To calculate mbc price and update port speed line item
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
        
    }
    
    //computes price for MBC and updates the port speed fee line item
    //with the calculated price for mbc, only if UBB is selected in cart 
    //Returns true if method executed successfully 
/* 
 Name: computeMBCPriceAndUpdateCart
 Description: 
 */ 
    public boolean computeMBCPriceAndUpdateCart(String cartId, Integer lineNumber){
        try{
            list<Apttus_Config2__LineItem__c> cartLinelist = [select id,MBC_Speed__c,UBBOveragePrice__c,Apttus_Config2__LineNumber__c,Apttus_Config2__ConfigurationId__c,
                                                              Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,
                                                              Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Rate_Card_Effective_Date__c,
                                                              Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__PriceListId__r.Id,
                                                              Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c,
                                                              Apttus_Config2__ConfigurationId__r.Apttus_Config2__AccountId__r.Current_Tier__c,
                                                              Apttus_Config2__ConfigurationId__r.Apttus_Config2__AccountId__r.SP_Tier__c, 
                                                              Apttus_Config2__ConfigurationId__r.Apttus_Config2__AccountId__r.Master_Agent__c,
                                                              Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Payment_Term__c,
                                                              Apttus_Config2__Description__c, Apttus_Config2__ChargeType__c,Apttus_Config2__ProductId__r.Product_New_Name__c
                                                              from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c = :cartId and Apttus_Config2__LineNumber__c = :lineNumber];
            boolean isSuccess = false;
            if(cartLinelist != null && cartLinelist.size() > 0){
                boolean isUsageBasedBilling = cartLinelist[0].Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c;
                Apttus_Config2__LineItem__c portSpeedLineItem;
                //fetch port speed fee line item
                for(Apttus_Config2__LineItem__c lineItem : cartLinelist){
                    if(lineItem.Apttus_Config2__ChargeType__c == UtilityConstant.PORTSPEED_FEE){
                        portSpeedLineItem = lineItem;      
                    }    
                }
                if(isUsageBasedBilling){
                    decimal mbcPrice;
                    string customerType;
                    if(portSpeedLineItem != null){
                        string selectedMbc = portSpeedLineItem.MBC_Speed__c;
                        date rateEffectiveDate = Date.parse(portSpeedLineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Rate_Card_Effective_Date__c.trim());
                        string priceListId = portSpeedLineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__PriceListId__r.Id;
                        mbcPrice = getMBCPrice(selectedMbc, rateEffectiveDate, priceListId);
                        boolean masterAgentFlag = portSpeedLineItem.Apttus_Config2__ConfigurationId__r.Apttus_Config2__AccountId__r.Master_Agent__c;
                        if(masterAgentFlag){
                            customerType = UtilityConstant.MASTERAGENT;
                        }
                        else {
                            customerType =  portSpeedLineItem.Apttus_Config2__ConfigurationId__r.Apttus_Config2__AccountId__r.Current_Tier__c;
                            if(customerType == UtilityConstant.GOLD){
                                customerType = UtilityConstant.PLATINUMELITE;
                            }
                            if(customerType == UtilityConstant.SILVER){
                                customerType = UtilityConstant.MASTERAGENT;
                            }
                        }
                        
                         
                        string productType = portSpeedLineItem.Apttus_Config2__ProductId__r.Product_New_Name__c;
                        string term = portSpeedLineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Payment_Term__c;
                        decimal overageCharge = getOverageMBCCharge(selectedMbc, customerType, productType, term);
                        if(mbcPrice != null){
                            //Update the Port speed fee line item with MBC price
                            portSpeedLineItem.Apttus_Config2__NetPrice__c = mbcPrice;
                            portSpeedLineItem.Apttus_Config2__BaseExtendedPrice__c = mbcPrice;
                            portSpeedLineItem.UBBOveragePrice__c = overageCharge;
                            update portSpeedLineItem;
                            isSuccess = true;
                        }
                    }
                }else{ 
                    //UBB is not present in cart. So method is executed as expected
                    if(portSpeedLineItem.UBBOveragePrice__c != null){
                        portSpeedLineItem.UBBOveragePrice__c = null;
                        update portSpeedLineItem;
                    }
                    isSuccess = true;    
                }
            }
            return isSuccess;  
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return false;
        }
    }
    
    //calculates MBC price from Price matrix entry
/* 
 Name: getMBCPrice
 Description: 
 */ 
    public decimal getMBCPrice(string selectedMBC, date rateEffectiveDate, string priceListId){
        try{
            decimal amount = null;
            String selectedMBCwithMBps = SpecialCharacterConstant.CONCAT; 
            if(selectedMBC != null && selectedMBC != UtilityConstant.SELECT1)
            {
                selectedMBCwithMBps = selectedMBC.trim();
                //logic to fetch amount from matric entry table based on beid, bill dispaly name and rate satbility date          
                list<Apttus_Config2__PriceMatrixEntry__c> matrixEntryList = [ select Id,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id , Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__PeriodEndDate__c from Apttus_Config2__PriceMatrixEntry__c where  (Apttus_Config2__Dimension1Value__c =:selectedMBCwithMBps and Apttus_Config2__PeriodStartDate__c <= :rateEffectiveDate and Description_PL__c =: UtilityConstant.UBBCHARGE and Charge_Type_PL__c =: UtilityConstant.PORTSPEED_FEE and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id =: priceListId) ];
                //logic to fecth a single price on multiple retrevals
                if( matrixEntryList.size() > 0 ){
                    boolean priceFound = false;
                    for( Apttus_Config2__PriceMatrixEntry__c priceMatrix : matrixEntryList  ){
                            if( priceMatrix.Apttus_Config2__PeriodEndDate__c != null && priceMatrix.Apttus_Config2__PeriodEndDate__c >= rateEffectiveDate ){
                            priceFound = true;
                            amount = priceMatrix.Apttus_Config2__AdjustmentAmount__c; // Returning only amount witho discount.
                        }
                        else if( !priceFound &&  priceMatrix.Apttus_Config2__PeriodEndDate__c == null  ){
                            amount = priceMatrix.Apttus_Config2__AdjustmentAmount__c; // Returning only amount witho discount.
                        }
                    }
                }
                else {
                    return null;
                }
                return amount;
            }
            return null;
        }
        catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }    
    }
    public String overMBC{get;set;}
    public decimal overMbcDecimal{get;set;} 
/* 
 Name: getOverageMBCCharge
 Description: 
 */ 
    public decimal getOverageMBCCharge(String MBC,String customerType,String productName,String termLength){
       try{
        if(MBC!= null && MBC !=SpecialCharacterConstant.CONCAT){
            string field;
            if(customerType==UtilityConstant.PLATINUM)
                field=UtilityConstant.PLATINUM_C;
            else if(customerType==UtilityConstant.PLATINUMELITE)
                field=UtilityConstant.PLATINUMELITE_C;
            else{ 
                field=UtilityConstant.MASTERAGENT_C;}
            if(productName==UtilityConstant.ATT_VIRTUAL_PRIVATE_NETWORK_SERVICE)
            {
                if(termlength == UtilityConstant.SIVARConst_1 || termlength.equalsIgnoreCase(UtilityConstant.SIVARConst_1YEAR))
                {
                    AVPN_1year_OveragePrices__c overMBCSet = AVPN_1year_OveragePrices__c.getvalues(MBC.replace(' ',''));
                    overMBC =string.valueof(OverMBCSet.get(field)); 
                }
                else if(termlength == UtilityConstant.SIVARConst_3 || termlength.equalsIgnoreCase(UtilityConstant.SIVARConst_3YEARS))
                {
                    AVPN_3years_OveragePrices__c overMBCSet=AVPN_3years_OveragePrices__c.getvalues(MBC.replace(' ',''));
                    overMBC =string.valueof(OverMBCSet.get(field)); 
                }
                if(overMBC != NULL && overMBC != SpecialCharacterConstant.CONCAT)
                    overMbcDecimal = decimal.valueof(overMBC);
            }
            else if(productName==UtilityConstant.ATT_MANAGED_INTERNET_SERVICE){
                if(termlength==UtilityConstant.SIVARConst_1 || termlength.equalsIgnoreCase(UtilityConstant.SIVARConst_1YEAR)){
                    MIS_1year_OveragePrices__c overMBCSet=MIS_1year_OveragePrices__c.getvalues(MBC.replace(SpecialCharacterConstant.BLANK,SpecialCharacterConstant.CONCAT));
                    overMBC =string.valueof(OverMBCSet.get(field)); 
                }
                else if(termlength==UtilityConstant.SIVARConst_3 || termlength.equalsIgnoreCase(UtilityConstant.SIVARConst_3YEARS)){
                    MIS_3years_OveragePrices__c overMBCSet=MIS_3years_OveragePrices__c.getvalues(MBC.replace(SpecialCharacterConstant.BLANK,SpecialCharacterConstant.CONCAT));
                    overMBC =string.valueof(OverMBCSet.get(field));
                }
                overMbcDecimal = decimal.valueof(overMBC);
            }
            else {
                overMBC = null;
                overMbcDecimal=0.0;
            }
        }
        return overMbcDecimal;
    } catch(Exception ex){
        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        
        return null;
    }
    }
    
    //Returns map of mbc speeds and it's overage charges based on product, tier and term length 
/* 
 Name: getMbcToOverageMap
 Description: 
 */ 
    public map<string, decimal>  getMbcToOverageMap(string productCode, string tier, string termLength){
        map<string, decimal> mbcToOverageMap;
        map<string, SObject> overMbcMap;
        string field;
        try{
        if(tier == UtilityConstant.PLATINUM)
            field = UtilityConstant.PLATINUM_C;
        else if(tier == UtilityConstant.PLATINUMELITE)
            field = UtilityConstant.PLATINUMELITE_C;
        else 
            field = UtilityConstant.MASTERAGENT_C;
        
               
        if(productCode == UtilityConstant.AVPN){
            if(termLength == UtilityConstant.SIVARConst_1 || termLength.equalsIgnoreCase(UtilityConstant.SIVARConst_1YEAR)){
                OverMbcMap = AVPN_1year_OveragePrices__c.getAll();
            }
            else if(termLength == UtilityConstant.SIVARConst_3 || termLength.equalsIgnoreCase(UtilityConstant.SIVARConst_3YEARS)){
                OverMbcMap = AVPN_3years_OveragePrices__c.getAll();
            }
        }
        if(productCode ==UtilityConstant.MIS){
            if(termLength == UtilityConstant.SIVARConst_1 || termLength.equalsIgnoreCase(UtilityConstant.SIVARConst_1YEAR)){
                OverMbcMap = MIS_1year_OveragePrices__c.getAll();
            }
            else if(termLength == UtilityConstant.SIVARConst_3 || termLength.equalsIgnoreCase(UtilityConstant.SIVARConst_3YEARS)){
                OverMbcMap = MIS_3years_OveragePrices__c.getAll();
            }
        }   
        mbcToOverageMap = prepareOverageMap(OverMbcMap, field );
        return mbcToOverageMap;
    } catch(Exception ex){
        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
       
        return null;
    }
    }
 
    
    map<string, decimal> prepareOverageMap(map<string, SObject> customSettingsMap, string field){
         map<string, decimal> tempMap = new map<string, decimal>();
        for(string mbcSpeed : customSettingsMap.keySet()){
            if(customSettingsMap.get(mbcSpeed) != null){
                if(customSettingsMap.get(mbcSpeed).get(field) != null){
                    string price = string.valueOf(customSettingsMap.get(mbcSpeed).get(field));
                    tempMap.put(mbcSpeed, decimal.valueOf(price));    
                }
            }
        }
        return tempMap;
    }
    /**********************************************************************************************************************************************************************************************************/    
    public boolean finalizeCart(String cartId)
    {
        Apttus_CPQApi.CPQ.FinalizeCartRequestDO finReq = null;
        Apttus_CPQApi.CPQ.FinalizeCartResponseDO res = null;
        //FINALIZE 
        try
        {
            finReq = new Apttus_CPQApi.CPQ.FinalizeCartRequestDO();
            finReq.CartId = cartId; 
            res = Apttus_CPQApi.CPQWebService.finalizeCart(finReq);
            return res.IsSuccess;
        }
        catch(Exception e)
        {
           // ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
           system.debug('exception in apttus service utility helper  '+e.getmessage());
        }
        return null;
    }
    
/* 
 Name: updatePriceOfCart
 Description: 
 */ 
    public void updatePriceOfCart(String cartId){
        try{
            Apttus_CPQApi.CPQ.UpdatePriceRequestDO requestPrice = new Apttus_CPQApi.CPQ.UpdatePriceRequestDO();
            requestPrice.CartId = cartId;
            Apttus_CPQApi.CPQ.UpdatePriceResponseDO responsePrice = Apttus_CPQApi.CPQWebService.updatePriceForCart(requestPrice);
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
/* 
 Name: updateOpportunityForQuotes
 Description: 
 */ 
    public boolean updateOpportunityForQuotes(List<Apttus_Proposal__Proposal__c> qList){
        Map<Id, Apttus_Proposal__Proposal__c> oppIdsMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        boolean isSuccess = false;
        String strTempQuoteName; //Added by Ranvijay to remove hyphen from quote name
        try{
            for(Apttus_Proposal__Proposal__c pc:qList){
                oppIdsMap.put(pc.Apttus_Proposal__Opportunity__c, pc);
            }
            List<Opportunity> opps = [Select API_Flag__c,ManualFlow__c ,Contract_Flow__c,IPFlex_Deal__c,Id,Renewal_Contract__c,Record_Type_Name_for_Internal_use__c from  Opportunity where Id IN : oppIdsMap.keySet()];
            List<Apttus_Config2__LineItem__c> listItemListWithMR=[Select id,Apttus_Config2__AttributeValueId__r.Managed_Router__c,Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c from Apttus_Config2__LineItem__c where    Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c=: qList[0].id and (Apttus_Config2__AttributeValueId__r.Managed_Router__c=true OR Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c=true) and  Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c=:ATT_Constant.STATUS];
            Admin_Control__c adminControl = [select AVPN_CAP_P29__c,MIS_CAP_P29__c from Admin_Control__c limit 1 ]; 
            if(opps.size()>0){
                for(Opportunity opp : opps){
                    //Changed by Ranvijay to remove hyphen from quote name
                    //opp.BID_ID__c = (oppIdsMap.get(opp.Id)).Name;
                    strTempQuoteName = (oppIdsMap.get(opp.Id)).Name;
                    if(!oppIdsMap.get(opp.Id).IsBIDMigrationCompleted__c){
                     opp.BID_ID__c = strTempQuoteName.substringBefore('-') + strTempQuoteName.substringAfter('-');
                     }
                    //change end Ranvijay
                    opp.Initial_BID_Deal_Owner__c = (oppIdsMap.get(opp.Id)).Owner.Name;
                    opp.Current_BID_Deal_Owner__c  = (oppIdsMap.get(opp.Id)).Owner.Name;
                   // opp.Quote_Expiration_Date__c = (oppIdsMap.get(opp.Id)).Apttus_Proposal__ExpectedEndDate__c;
                    opp.Quote_ID__c = (oppIdsMap.get(opp.Id)).Name;
                    opp.Accountid = oppIdsMap.get(opp.Id).Apttus_Proposal__Account__c;
                    //opp.term__c = oppIdsMap.get(opp.Id).Apttus_Proposal__Payment_Term__c;
                    
                    opp.CI_Promo_Complete__c = true;
                    if(listItemListWithMR.size()>0){
                      opp.API_Flag__c=false;
                      opp.ManualFlow__c=true; 
                      opp.Contract_Flow__c = '';
                    }else{
                        
                        if(((oppIdsMap.get(opp.Id)).Apttus_Proposal__Approval_Stage__c == ATTConstants.QUOTE_DEAL_REG_APPROVED) && opp.Record_Type_Name_for_Internal_use__c != 'MACD' && ((adminControl.AVPN_CAP_P29__c && (oppIdsMap.get(opp.Id)).Product__r.name =='AT&T Virtual Private Network') || (adminControl.MIS_CAP_P29__c && (oppIdsMap.get(opp.Id)).Product__r.name =='AT&T Managed Internet Service'))){
                            opp.ManualFlow__c=true;
                            opp.Contract_Flow__c = 'Manual';
                        }else{  
                            opp.ManualFlow__c=false;
                            opp.Contract_Flow__c = ''; 
                        }
                         opp.API_Flag__c = true;
                         opp.MISPlus__c =false;
                         opp.IPFlex_Deal__c =SpecialCharacterConstant.FALSE_LITERAL;
                    }
                    
                    //Contract Renewal Changes
                    if(opp.Renewal_Contract__c == true){
                        opp.ManualFlow__c = false;
                        opp.Contract_Flow__c = '';
                        system.debug('@@@inside contract renewal');
                    }
                    
                    if(listItemListWithMR.size()>0){ 
                    if(listItemListWithMR[0].Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c){
                      opp.IPFlex_Deal__c =SpecialCharacterConstant.TRUE_CAMEL_LITERAL;
                      }else{
                      opp.IPFlex_Deal__c =SpecialCharacterConstant.FALSE_LITERAL;
                      }
                      if(listItemListWithMR[0].Apttus_Config2__AttributeValueId__r.Managed_Router__c){    
                        opp.MISPlus__c =true;
                        }  
                     }
                    //opp.NTWK_CI_Complete__c = true;
                    //opp.OwnerId = accList[0].ownerID;put the owner id in first place

                }
               
                update opps;
            }
            isSuccess = true;
        }catch(Exception e){
           ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return isSuccess;
    }//End of Method
     
   /**************************************************************************************************************************************  
     Method for calculating Port and Access Physical Speed Values i.e T1(1.544 Mbps)
      Final Result will be 1.544 if 3xT1 (4.632 Mbps) then Result will be 4.632 
    */
     Public Decimal physicalSpeedCalculation(String portSpeedVal){
        String portSpeedvalue=SpecialCharacterConstant.CONCAT;
        Decimal portSpeed;
        boolean isSuccess = false;
        try{
        if(portSpeedVal!=UtilityConstant.SIVARConst_0 && portSpeedVal!=null ){
          if(portSpeedVal.indexOf(UtilityConstant.T1)>=0)
                    portSpeedvalue= portSpeedVal.substring(portSpeedVal.indexOf('(')+1,portSpeedVal.indexOf('Mbps'));
                else if(portSpeedVal.indexOf(UtilityConstant.T1) < 0 && portSpeedVal.indexOf(UtilityConstant.MBPS) >=0)
                    portSpeedvalue= portSpeedVal.substring(0,portSpeedVal.indexOf(UtilityConstant.MBPS));
                else if(portSpeedVal.indexOf(UtilityConstant.T1) < 0 && portSpeedVal.indexOf(UtilityConstant.MBPS) < 0 && portSpeedVal.indexOf(UtilityConstant.GBPS) >= 0)
                    portSpeedvalue= portSpeedVal.substring(0,portSpeedVal.indexOf(UtilityConstant.GBPS));
                  portSpeedvalue= portSpeedvalue.indexOf('.') < 0 ? portSpeedvalue: portSpeedvalue.replaceAll('0*$', '').replaceAll('\\.$', '');
              if(portSpeedvalue!= null){
                portSpeed= Decimal.valueof(portSpeedvalue.trim());
                if(portSpeedVal.indexOf(UtilityConstant.GBPS) >= 0){
                    portSpeed= portSpeed*1024;
                  }
              }
           
        }
        return portSpeed;
        
     } catch(Exception ex){
         ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
         
         return null;
     }
     }
     
    //Ends of method 
    
/* 
 Name: createSPProductsForQuotes
 Description: 
 */ 
     public boolean createSPProductsForQuotes(Set<Id> qList, boolean IsUpdateOpportunity){
        //FETCH Apttus_Proposal__Proposal_Line_Item__c
        // Query on quote (EBM Org) 
        List<Apttus_Proposal__Proposal__c> quoteLst = new List<Apttus_Proposal__Proposal__c>();
        Map<String,List<Apttus_Proposal__Proposal_Line_Item__c> > mapProposalLineItem = new Map<String,List<Apttus_Proposal__Proposal_Line_Item__c> >();
        boolean isSuccess = false;
        Savepoint sp = null;
        try{
            //for(Apttus_Proposal__Proposal__c pc:qList){
            //quoteIdsMap.put(pc.Id, pc);
            //}
            //bulk quote reading
            sp = Database.setSavepoint();
            Double listPrice = 0.0;
            List<SPProduct__c> spProductList = new List<SPProduct__c>();
            // Query Quote Line Item.
            
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItem = [select Apttus_QPConfig__OptionId__c,HiCapFlex__c,UBBSpeed__c,vasa_region__c,Additional_DNS__c,Apttus_QPConfig__PriceListItemId__r.Name,Apttus_QPConfig__OptionId__r.Name,Option_Group__c,Bill_Display_Name__c ,Apttus_Proposal__Proposal__r.Traffic_Jurisdiction__c,
            Apttus_Proposal__Proposal__c,Apttus_Proposal__Proposal__r.Apttus_Proposal__Payment_Term__c,Apttus_QPConfig__OptionId__r.ProductCode,Apttus_Proposal__Product__r.name,Apttus_QPConfig__PriceListId__r.name,
            Apttus_QPConfig__NetPrice__c,Apttus_QPConfig__AdjustedPrice__c,Apttus_QPConfig__OptionId__r.Description,Apttus_QPConfig__PriceType__c,Apttus_QPConfig__PriceListItemId__c,
            Apttus_QPConfig__PriceListId__c,Apttus_QPConfig__PriceListItemId__r.BEID__c,Apttus_QPConfig__PriceListItemId__r.Low_Level_Tier__c,Apttus_QPConfig__PriceListItemId__r.PBIID__c,Apttus_QPConfig__PriceListItemId__r.Bill_Display_Name__c,Apttus_QPConfig__PriceListItemId__r.Determinant_Set_Id__c,
            Apttus_Proposal__Quantity__c,Apttus_QPConfig__ChargeType__c,Product_Code__c, Apttus_QPConfig__AttributeValueId__r.Port_Speed_MIS__c,Port_Speed__c,Access_Speed__c,Access_Type__c,Port_Type__c, AT_T_Customer_Site__c,Apttus_QPConfig__ListPrice__c,Apttus_QPConfig__LineType__c, One_Time_Fee__c, Apttus_Proposal__Proposal__r.MACD_Change_Type__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c IN : qList];
            // Swastika Added Apttus_Proposal__Proposal__r.MACD_Change_Type__c field to query for MACD Add requirement 
            
            List<AT_T_Customer_Site_Quote__c> cJunSiteList = [select AT_T_Quote__c,AT_T_Customer_Site__c,AT_T_Customer_Site__r.name,AT_T_Customer_Site__r.State__c,AT_T_Customer_Site__r.City__c,
            AT_T_Customer_Site__r.Country__c,AT_T_Customer_Site__r.Phone__c,AT_T_Customer_Site__r.Address_Line__c,AT_T_Customer_Site__r.Zip_Code__c, 
            AT_T_Quote__r.Apttus_Proposal__Approval_Stage__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Expiration_Date__c,AT_T_Quote__r.Product__r.ProductCode,
            AT_T_Quote__r.City__c,AT_T_Quote__r.State__c,AT_T_Quote__r.Business_Address_Line_2__c,AT_T_Quote__r.Product__r.name,Site_ID__c ,
            AT_T_Quote__r.End_Customer__r.Name,AT_T_Quote__r.End_Customer__c ,AT_T_Quote__r.Business_Address_Line_1__c,AT_T_Quote__r.Zip_Code__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__c,
            AT_T_Quote__r.DUNS_Number__c from AT_T_Customer_Site_Quote__c where AT_T_Quote__c IN : qList];
            
            Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>> quoteLineItemMap = new Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>>();
            Map<String,Boolean> vLANMAP = new Map<String,Boolean>();
            Map<String,Boolean> iNTERSTATEMAP = new Map<String,Boolean>();
            Map<String,Boolean> iNTRASTATEMAP = new Map<String,Boolean>();
            Map<String,Boolean> pORTTYEPMAP = new Map<String,Boolean>();
            Map<String,Boolean> cOSTYEPMAP = new Map<String,Boolean>();
            Map<id,String> pORTTYEPMAPWithLineItemId = new Map<id,String>();
            Map<id,String> coSTYEPMAPWithLineItemId= new Map<id,String>();
            Map<id,String> cIRTYEPMAPWithLineItemId= new Map<id,String>();
            Boolean isVLAN = false;
            Set<String> priceListItem = New Set<String>();
            
            Map<String,Apttus_Config2__PriceMatrixEntry__c> mapPriceMatrixEntry= New Map<String,Apttus_Config2__PriceMatrixEntry__c>();
            Map<String,Apttus_Config2__PriceMatrixEntry__c> mapPriceMatrixEntryFeatureAccess= New Map<String,Apttus_Config2__PriceMatrixEntry__c>();
            
            // Creating map based on the site .
            // Map for identifer such as VLAN, COS and Port Type.
           
           
            for(Apttus_Proposal__Proposal_Line_Item__c p : proposalLineItem){
                priceListItem.add(p.Apttus_QPConfig__PriceListItemId__r.Name);  
                if(quoteLineItemMap.containskey(p.AT_T_Customer_Site__c)){
                    quoteLineItemMap.get(p.AT_T_Customer_Site__c).add(p);                   
                }else{
                     quoteLineItemMap.put(p.AT_T_Customer_Site__c,new List<Apttus_Proposal__Proposal_Line_Item__c>{p});
                  }
                if(p.Product_Code__c !=ATT_Constant.AMIS && p.Product_Code__c !=ATT_Constant.A_VPN){
                    if(p.Apttus_QPConfig__OptionId__r.Name == ATT_Constant.VLAN){
                        VLANMAP.put(p.AT_T_Customer_Site__c,true);
                        COSTYEPMAP.put(p.AT_T_Customer_Site__c,false);
                        isVLAN = true;
                    }
                    else if(p.Apttus_QPConfig__OptionId__r.Name == ATT_Constant.COS && isVLAN == false){
                        VLANMAP.put(p.AT_T_Customer_Site__c,false);
                        COSTYEPMAP.put(p.AT_T_Customer_Site__c,true);
                        
                    }
                    if(p.Option_Group__c == ATT_Constant.PORT_SPEED){
                        PORTTYEPMAP.put(p.AT_T_Customer_Site__c,true);
                        PORTTYEPMAPWithLineItemId.put(p.AT_T_Customer_Site__c,p.Apttus_QPConfig__OptionId__r.Name);
                    }
                    if(ATTConstants.CLASS_OF_SERVICE.equalsIgnoreCase(p.Option_Group__c)){
                        CoSTYEPMAPWithLineItemId.put(p.AT_T_Customer_Site__c,p.Apttus_QPConfig__OptionId__r.Name);
                    }
                    if(p.Option_Group__c == UtilityConstant.CIR){
                        CIRTYEPMAPWithLineItemId.put(p.AT_T_Customer_Site__c,p.Apttus_QPConfig__OptionId__r.Name);
                    }
                }else{
                    if(p.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.VLAN)){
                        VLANMAP.put(p.AT_T_Customer_Site__c,true);
                        COSTYEPMAP.put(p.AT_T_Customer_Site__c,false);
                        isVLAN = true;
                    }
                    else if(p.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.COS) && isVLAN == false){
                        VLANMAP.put(p.AT_T_Customer_Site__c,false);
                        COSTYEPMAP.put(p.AT_T_Customer_Site__c,true);
                        
                    }
                    if(p.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.PORT_SPEED)){
                        PORTTYEPMAP.put(p.AT_T_Customer_Site__c,true);
                        PORTTYEPMAPWithLineItemId.put(p.AT_T_Customer_Site__c,p.Apttus_QPConfig__ChargeType__c);
                    } /*
                    if(ATTConstants.CLASS_OF_SERVICE.equalsIgnoreCase(p.Option_Group__c)){
                        CoSTYEPMAPWithLineItemId.put(p.AT_T_Customer_Site__c,p.Apttus_QPConfig__ChargeType__c);
                    }
                    if(p.Option_Group__c == UtilityConstant.CIR){
                        CIRTYEPMAPWithLineItemId.put(p.AT_T_Customer_Site__c,p.Apttus_QPConfig__ChargeType__c);
                    }  */
                }
                if(p.Apttus_Proposal__Proposal__r.Traffic_Jurisdiction__c == UtilityConstant.INTERSTATE){
                  INTERSTATEMAP.put(p.AT_T_Customer_Site__c,true);
                  INTRASTATEMAP.put(p.AT_T_Customer_Site__c,false);
                }
                if(p.Apttus_Proposal__Proposal__r.Traffic_Jurisdiction__c == UtilityConstant.INTRASTATE){
                  INTRASTATEMAP.put(p.AT_T_Customer_Site__c,true);
                  INTERSTATEMAP.put(p.AT_T_Customer_Site__c,false);
                }
            }
            
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalList = new List<Apttus_Proposal__Proposal_Line_Item__c>(); 
            List<Apttus_Proposal__Proposal_Line_Item__c> quoteProposalList = new List<Apttus_Proposal__Proposal_Line_Item__c>(); 
            String accessSpeedVal;
            String accessspeedvalue=SpecialCharacterConstant.CONCAT;
            Decimal accessSpeed;
            /*Integer randNo = Integer.valueOf((Site_Number__c.getValues(UtilityConstant.SITEVALUE) != null && Site_Number__c.getValues(UtilityConstant.SITEVALUE).Value__c != null )? Site_Number__c.getValues(UtilityConstant.SITEVALUE).Value__c : UtilityConstant.SIVARConst_100000000);
            Integer i = 0;
            String finalSiteNo = SpecialCharacterConstant.CONCAT;*/
            for(AT_T_Customer_Site_Quote__c prop : cJunSiteList){   
                 if(quoteLineItemMap.containsKey(prop.AT_T_Customer_Site__c)){               
                    listPrice = 0.0;
                    proposalList = quoteLineItemMap.get(prop.AT_T_Customer_Site__c);
                    SPProduct__c spProductObj = new SPProduct__c();                 
                    spProductObj.List_Price__c = 0.0; 
                    spProductObj.one_time_revenue__c = 0.0;
                    
                    for(Apttus_Proposal__Proposal_Line_Item__c pLine : proposalList){
                                 
                          if(pLine.Apttus_QPConfig__OptionId__c != null && pline.Product_Code__c !=ATT_Constant.AMIS && pline.Product_Code__c !=ATT_Constant.A_VPN){
                                            
                            if(pLine.Option_Group__c == ATT_Constant.ACCESS_SPEED){
                                spProductObj.Access_Speed_Name__c = pLine.Apttus_QPConfig__OptionId__r.Name;
                                spProductObj.Access_Speed_List_Price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                spProductObj.Access_Speed_Type__c = pLine.Option_Group__c;
                                listPrice=listPrice+pLine.Apttus_QPConfig__NetPrice__c;
                            }
                            if(pLine.Option_Group__c == ATT_Constant.PORT_SPEED){
                                spProductObj.Port_Speed_Name__c = pLine.Apttus_QPConfig__OptionId__r.Name;
                                spProductObj.Port_Price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                listPrice=listPrice+pLine.Apttus_QPConfig__NetPrice__c;
                            }
                            if(pLine.Option_Group__c == ATT_Constant.COS){
                                spProductObj.COS_Product_Name__c = pLine.Apttus_QPConfig__OptionId__r.Name;
                                spProductObj.COS_List_Price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                listPrice=listPrice+pLine.Apttus_QPConfig__NetPrice__c;
                                
                            }
                            if(pLine.Option_Group__c == ATT_Constant.INSTALLATION_TYPE){
                                spProductObj.Onsite_Install_Charges__c = pLine.Apttus_QPConfig__NetPrice__c;
                                listPrice=listPrice+pLine.Apttus_QPConfig__NetPrice__c;
                            }
                         } else if ((pline.Product_Code__c==ATT_Constant.AMIS || pline.Product_Code__c==ATT_Constant.A_VPN) && pLine.Apttus_QPConfig__ChargeType__c!=null ){
                             
                          if(pline.Product_Code__c==ATT_Constant.AMIS){
                                if(pLine.Apttus_QPConfig__ChargeType__c==UtilityConstant.ACCESSSPEED_FEE){
                                    spProductObj.Access_Speed_Physical_Value__c=physicalSpeedCalculation(pLine.Access_Speed__c); 
                                    spProductObj.Access_Speed_Name__c = pLine.Access_Speed__c;
                                    spProductObj.Access_Speed_List_Price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                    spProductObj.Access_Speed_Type__c = PLine.Access_Type__c;
                                    listPrice=listPrice+pLine.Apttus_QPConfig__NetPrice__c;
                                    if(pLIne.Vasa_Region__c==UtilityConstant.INREGION){
                                        spProductObj.Region__c=UtilityConstant.IR;
                                    }
                                    else if(pLIne.Vasa_Region__c==UtilityConstant.OO1 || pLIne.Vasa_Region__c==UtilityConstant.OO1A|| pLIne.Vasa_Region__c==UtilityConstant.OO2) {
                                     spProductObj.Region__c=UtilityConstant.STATIC_OR;
                                   }  
                                }
                                if(pLine.Apttus_QPConfig__ChargeType__c.Contains(ATT_Constant.PORT_SPEED)){
                                    spProductObj.Port_Speed_Physical_Value__c=String.valueOf(physicalSpeedCalculation(pLine.Port_Speed__c));
                                    spProductObj.Port_Speed_Name__c = pLine.Port_Speed__c;
                                    spProductObj.Port_Price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                    listPrice=listPrice+pLine.Apttus_QPConfig__NetPrice__c;
                                }
                                if(pLine.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.COS)){
                                    spProductObj.COS_Product_Name__c =ATT_Constant.COS;
                                    spProductObj.COS_List_Price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                    listPrice=listPrice+pLine.Apttus_QPConfig__NetPrice__c;
                                    
                                }
                                if(pLine.Apttus_QPConfig__ChargeType__c.Contains(UtilityConstant.ONETIME)){
                                    spProductObj.Onsite_Install_Charges__c = pLine.Apttus_QPConfig__NetPrice__c;
                                    listPrice=listPrice+pLine.Apttus_QPConfig__NetPrice__c;
                                }
                                
        
                            }else if(pline.Product_Code__c==ATT_Constant.A_VPN){
                            
                                 if(pLine.Apttus_QPConfig__ChargeType__c==UtilityConstant.ACCESSSPEED_FEE){
                                    spProductObj.Access_Speed_Physical_Value__c=physicalSpeedCalculation(pLine.Access_Speed__c); 
                                    spProductObj.Access_Speed_Name__c = pLine.Access_Speed__c;
                                    spProductObj.Access_Speed_List_Price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                    spProductObj.Access_Speed_Type__c = pLine.Access_Type__c;
                                    listPrice=listPrice+pLine.Apttus_QPConfig__NetPrice__c;
                                    if(pLIne.Vasa_Region__c==UtilityConstant.INREGION){
                                        spProductObj.Region__c=UtilityConstant.IR;
                                    }
                                    else if(pLIne.Vasa_Region__c==UtilityConstant.OO1 || pLIne.Vasa_Region__c==UtilityConstant.OO1A|| pLIne.Vasa_Region__c==UtilityConstant.OO2) {
                                        spProductObj.Region__c=UtilityConstant.STATIC_OR;
                                    }
                                 }
                                if(pLine.Apttus_QPConfig__ChargeType__c.Contains(ATT_Constant.PORT_SPEED)){
                                    spProductObj.Port_Speed_Physical_Value__c=String.valueOf(physicalSpeedCalculation(pLine.Port_Speed__c));
                                    spProductObj.Port_Speed_Name__c = pLine.Port_Speed__c;
                                    spProductObj.Port_Price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                    listPrice=listPrice+pLine.Apttus_QPConfig__NetPrice__c;
                                 }
                                if(pLine.Apttus_QPConfig__ChargeType__c.Contains(ATT_Constant.COS)){
                                    spProductObj.COS_Product_Name__c =ATT_Constant.COS;
                                    spProductObj.COS_List_Price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                    listPrice=listPrice+pLine.Apttus_QPConfig__NetPrice__c;
                                    
                                }
                                if(pLine.Apttus_QPConfig__ChargeType__c.contains(UtilityConstant.ONETIME)){
                                    spProductObj.Onsite_Install_Charges__c = pLine.Apttus_QPConfig__NetPrice__c;
                                    listPrice=listPrice+pLine.Apttus_QPConfig__NetPrice__c;
                                }
                            }
                            if(pline.Apttus_Proposal__Proposal__r.MACD_Change_Type__c==UtilityConstant.ADDSITE){ //Added by Swastika to set MACD type for MACD Add Site
                                spProductObj.MACD_Type__c = UtilityConstant.A;
                            }
                        }
                       if(pLine.Apttus_QPConfig__LineType__c == ATT_Constant.PRODUCTSERVICE && Integer.valueOf(pline.Apttus_QPConfig__NetPrice__c) >0){
                            
                            /* updating code as part of prod defect ** diffrentiating between MRC & NRC.. */
                            if( pLine.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE ) {
                                spProductObj.List_Price__c = spProductObj.List_Price__c+pline.Apttus_QPConfig__NetPrice__c;
                             }
                              else if( pLine.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE ){
                                spProductObj.one_time_revenue__c = spProductObj.one_time_revenue__c+pline.Apttus_QPConfig__NetPrice__c;
                             }
                         }                    
                        
                        spProductObj.Term_Length__c = pline.Apttus_Proposal__Proposal__r.Apttus_Proposal__Payment_Term__c;
                        
                    }
                    //spProductObj.List_Price__c = listPrice;                   
                    spProductObj.End_Customer_Name__c = prop.AT_T_Quote__r.End_Customer__r.Name;
                    spProductObj.Quote_Expiration_Date__c = prop.AT_T_Quote__r.Apttus_Proposal__Proposal_Expiration_Date__c;
                    spProductObj.State__c = prop.AT_T_Customer_Site__r.State__c;
                    spProductObj.Street__c = prop.AT_T_Customer_Site__r.Address_Line__c;
                    spProductObj.City__c = prop.AT_T_Customer_Site__r.City__c;
                    spProductObj.Mailing_Street_Address__c = prop.AT_T_Customer_Site__r.Address_Line__c;
                    spProductObj.Zip__c = String.isempty(prop.AT_T_Customer_Site__r.Zip_Code__c)? null : prop.AT_T_Customer_Site__r.Zip_Code__c;
                    spProductObj.DUNS__c = prop.AT_T_Quote__r.DUNS_Number__c;                 
                    spProductObj.Deal__c = prop.AT_T_Quote__r.Apttus_Proposal__Opportunity__c;
                    spProductObj.Product_Name__c =  prop.AT_T_Quote__r.Product__r.name;                 
                    //spProductObj.Site_ID__c = String.ValueOf(randNo + i++);
                    //finalSiteNo = String.ValueOf(randNo + i);
                    spProductObj.Site_ID__c =prop.Site_ID__c;
                    spProductObj.CustomerSiteID__c = prop.AT_T_Customer_Site__c;
                    
                    if(Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().containskey(prop.AT_T_Quote__r.Product__r.ProductCode)){ // Null check added by Praveen (Defect : DE86900)               
                        spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(prop.AT_T_Quote__r.Product__r.ProductCode).getRecordTypeId();
                    }    
                    else if(prop.AT_T_Quote__r.Product__r.ProductCode == ATT_Constant.AMIS ){
                        spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(ATT_Constant.MIS).getRecordTypeId();                  
                    }
                    else if(prop.AT_T_Quote__r.Product__r.ProductCode == ATT_Constant.ASES ){
                        spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(ATT_Constant.ASE).getRecordTypeId();                  
                    }
                    /*
                    else if(prop.AT_T_Quote__r.Product__r.ProductCode == ATT_Constant.PC){
                        spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(ATT_Constant.PRIVATECLOUD).getRecordTypeId();                     
                    }
                    else if(prop.AT_T_Quote__r.Product__r.ProductCode == ATT_Constant.Colo){
                        spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(ATT_Constant.Colocation).getRecordTypeId();                   
                    }
                    */
                    else if(prop.AT_T_Quote__r.Product__r.ProductCode == ATT_Constant.STAAS){
                        spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(ATT_Constant.Sta).getRecordTypeId();                  
                    }
                    else if(prop.AT_T_Quote__r.Product__r.ProductCode == ATT_Constant.CAAS){
                        spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(ATT_Constant.Ca).getRecordTypeId();                   
                    }
                    else if(prop.AT_T_Quote__r.Product__r.ProductCode == ATT_Constant.AIA){
                        spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(ATT_Constant.BROAD).getRecordTypeId();                   
                    }
                    spProductList.add(spProductObj);
                }
                
                
            }                                       
            insert spProductList;                 
            /* Updating custom setting with latest site number.
            List<Site_Number__c> siteNumList = new List<Site_Number__c>();
            siteNumList = [select id,name from Site_Number__c where name =: 'Site_Value' limit 1];
            if(siteNumList.size()>0 && spProductList.size() >0){
                Site_Number__c siteNumObj = new Site_Number__c(id = siteNumList[0].id);
                siteNumObj.Value__c = finalSiteNo;
                update siteNumObj;
            }*/
            
            List<Product_Pricing__c> pPricingList = new List<Product_Pricing__c>();
            List<Site__c> siteList = new List <Site__c>();
            
            // Fetch the records of product mapping.
            Map<String,Product_Mapping__c> mapProductMap = new Map<String,Product_Mapping__c>();
            List<Product_Mapping__c> prodMapList = [select id,Name,BEID__c,Bill_Display_Name__c,Billing_Element__c,Combination__c,Determinant_Set_Id__c,Low_Level_Tier__c,PBIID__c,Associated_Price_List__c,
            Associated_Product_One_Selected__c,Associated_Product_Two_Selected__c,Rate_Amount__c from Product_Mapping__c];
            
            List<Apttus_Config2__PriceMatrixEntry__c> priceMatrixList=[Select Id,Determinant_Set_ID__c,BEID__c,Low_Level__c,PriceListItemId__c,PLName__c,BillDisplayName__c,PBI_Number__c,Apttus_Config2__PeriodEndDate__c,Apttus_Config2__Dimension1Value__c,Rate__r.Bill_Display_Name__c,Apttus_Config2__Dimension2Value__c from Apttus_Config2__PriceMatrixEntry__c where PLName__c IN :priceListItem and Apttus_Config2__PeriodEndDate__c=null ];  
            
            if(priceMatrixList!=null){
                for(Apttus_Proposal__Proposal_Line_Item__c p : proposalLineItem){
                    for(Apttus_Config2__PriceMatrixEntry__c priceMatrix:priceMatrixList){
                       if(pricematrix.PLName__c==p.Apttus_QPConfig__PriceListItemId__r.Name && pricematrix.BEID__c!=null ){
                            mapPriceMatrixEntry.put(priceMatrix.Apttus_Config2__Dimension1Value__c+priceMatrix.PLName__c,priceMatrix);           
                            mapPriceMatrixEntryFeatureAccess.put(priceMatrix.Apttus_Config2__Dimension1Value__c+priceMatrix.Apttus_Config2__Dimension2Value__c+priceMatrix.PLName__c,priceMatrix);
                        }
                    }
                }
            }
            
            for(Product_Mapping__c prodMap : prodMapList){
                mapProductMap.put(prodMap.Combination__c,prodMap);
            }
            
            Map<String, List<Apttus_Proposal__Proposal_Line_Item__c>> optionQuoteLineMap = new Map<String, List<Apttus_Proposal__Proposal_Line_Item__c>>();
            for(SPProduct__c sprod : spProductList){
                // Check the Product.
                //Logic for AVPN product.  
                if(sprod.Product_Name__c == ATT_Constant.AVPN){
                    
                    Product_Pricing__c vlanPricing = new Product_Pricing__c();
                    Product_Pricing__c cosPricing = new Product_Pricing__c();
                    if(quoteLineItemMap.containsKey(sprod.CustomerSiteID__c)){
                        quoteProposalList =  new List<Apttus_Proposal__Proposal_Line_Item__c>();
                        quoteProposalList = quoteLineItemMap.get(sprod.CustomerSiteID__c);
                        string portspeed;
                        Decimal accessTotalFee = 0.00;
                        for(Apttus_Proposal__Proposal_Line_Item__c accesPLine : quoteProposalList){
                         if(accesPLine.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.PORT_SPEED) && sprod.CustomerSiteID__c== accesPLine.AT_T_Customer_Site__c) {
                                 PortSpeed = accesPLine.Port_Speed__c;
                             }
                         if( accesPLine.Apttus_QPConfig__ChargeType__c.containsIgnoreCase(UtilityConstant.ACCESSSPEED) && sprod.CustomerSiteID__c== accesPLine.AT_T_Customer_Site__c ){
                                
                                accessTotalFee += accesPLine.Apttus_QPConfig__NetPrice__c;
                             }
   
                        }
                        for(Apttus_Proposal__Proposal_Line_Item__c aPLine : quoteProposalList){
        
                        //    if(aPLine.Apttus_QPConfig__LineType__c==UtilityConstant.OPTION){
                         
                                if(aPLine.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.VLAN)){
                                    
                                    if( PORTTYEPMAP.containsKey(aPLine.AT_T_Customer_Site__c) && PORTTYEPMAP.get(aPLine.AT_T_Customer_Site__c) == true){
                                        Product_Pricing__c pPricicng = new Product_Pricing__c();
                                    
                                        if(mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null){                                 
                                            
                                            pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                            pPricicng.BEID__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                            pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                            pPricicng.product_name__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;
                                            pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                            }
                                            if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE)
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                            if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                            pPricicng.list_price__c = aPLine.Apttus_QPConfig__NetPrice__c;
                                            pPricicng.SP_Product__c = sprod.id;
                                            pPricicng.Product_Detail__c = aPLine.Apttus_QPConfig__ChargeType__c;  
                                            pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get(UtilityConstant.FEATURE).getRecordTypeId();
                                            pPricingList.add(pPricicng);
     
                                    }
    
                                }
                                else if(aPLine.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.COS)){                         
                                    if( PORTTYEPMAP.containsKey(aPLine.AT_T_Customer_Site__c) && PORTTYEPMAP.get(aPLine.AT_T_Customer_Site__c) == true){
                                        Product_Pricing__c pPricicng = new Product_Pricing__c(); 
                                       
                                        if(mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null){
                                            pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                            pPricicng.BEID__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                            pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                            pPricicng.product_name__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;
                                            pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                                                                       
                                            }
                                            if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE)
                                                pPricicng.type__c = ATT_Constant.MRCTYPE;
                                            if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                                pPricicng.type__c = ATT_Constant.NRCTYPE;
                                            pPricicng.list_price__c = aPLine.Apttus_QPConfig__NetPrice__c;
                                            pPricicng.SP_Product__c = sprod.id;           
                                            pPricicng.Product_Detail__c = aPLine.Apttus_QPConfig__ChargeType__c;
                                            pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                            pPricingList.add(pPricicng);
                                            
                                        
                                        
                                     }
                                  
                                    
                                }else if(aPLine.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.PORT_SPEED) && !aPLine.HiCapFlex__c){
                                    Product_Pricing__c pPricicng = new Product_Pricing__c();
                                    if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(aPLine.Port_Speed__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null){
                                                                                                               
                                    pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(aPLine.Port_Speed__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                    pPricicng.BEID__c =  mapPriceMatrixEntry.get(aPLine.Port_Speed__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(aPLine.Port_Speed__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(aPLine.Port_Speed__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c; 
                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(aPLine.Port_Speed__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                    pPricicng.Product_Detail__c = aPLine.Apttus_QPConfig__ChargeType__c;  
                                    pPricicng.Product_Detail__c = aPLine.Apttus_QPConfig__ChargeType__c; 
                                    }
                                    if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE)
                                    pPricicng.type__c = ATT_Constant.MRCTYPE;
                                    if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                    pPricicng.type__c = ATT_Constant.NRCTYPE;
                                    pPricicng.list_price__c = aPLine.Apttus_QPConfig__NetPrice__c;                                   
                                    pPricicng.SP_Product__c = sprod.id;           
                                    
                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Port').getRecordTypeId();
                                    pPricingList.add(pPricicng);
                                }else if(aPLine.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.PORT_SPEED) && aPLine.HiCapFlex__c){
                                    Product_Pricing__c pPricicng = new Product_Pricing__c();
                                    if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(aPLine.UBBSpeed__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null){
                                                                                                               
                                    pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(aPLine.UBBSpeed__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                    pPricicng.BEID__c =  mapPriceMatrixEntry.get(aPLine.UBBSpeed__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(aPLine.UBBSpeed__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(aPLine.UBBSpeed__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c; 
                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(aPLine.UBBSpeed__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                    pPricicng.Product_Detail__c = aPLine.Apttus_QPConfig__ChargeType__c;   
                                    }
                                    if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE)
                                    pPricicng.type__c = ATT_Constant.MRCTYPE;
                                    if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                    pPricicng.type__c = ATT_Constant.NRCTYPE;
                                    pPricicng.list_price__c = aPLine.Apttus_QPConfig__NetPrice__c;
                                    pPricicng.SP_Product__c = sprod.id;           
                                    pPricicng.Product_Detail__c = aPLine.Apttus_QPConfig__ChargeType__c;
                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Port').getRecordTypeId();
                                    pPricingList.add(pPricicng);
                                }else if(aPLine.Apttus_QPConfig__ChargeType__c==UtilityConstant.ACCESSSPEED_FEE){
                                    Product_Pricing__c pPricicng = new Product_Pricing__c();
                                   
                                    if(!mapPriceMatrixEntryFeatureAccess.isEmpty() && mapPriceMatrixEntryFeatureAccess.get(aPLine.Access_Speed__c+aPLine.VASA_Region__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null) {                                    
                                    pPricicng.BEID__c = mapPriceMatrixEntryFeatureAccess.get(aPLine.Access_Speed__c+aPLine.VASA_Region__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                    pPricicng.PBI_Number__c = mapPriceMatrixEntryFeatureAccess.get(aPLine.Access_Speed__c+aPLine.VASA_Region__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                    pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntryFeatureAccess.get(aPLine.Access_Speed__c+aPLine.VASA_Region__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                    pPricicng.product_name__c = mapPriceMatrixEntryFeatureAccess.get(aPLine.Access_Speed__c+aPLine.VASA_Region__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;
                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntryFeatureAccess.get(aPLine.Access_Speed__c+aPLine.VASA_Region__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                    
                                    }
                                    if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE)
                                    pPricicng.type__c = ATT_Constant.MRCTYPE;
                                    if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                    pPricicng.type__c = ATT_Constant.NRCTYPE;
                                    pPricicng.list_price__c =accessTotalFee;
                                    pPricicng.SP_Product__c = sprod.id;
                                    pPricicng.Product_Detail__c = aPLine.Apttus_QPConfig__ChargeType__c;
                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Access').getRecordTypeId();
                                    pPricingList.add(pPricicng); 
                                }else{
                                   if(aPLine.Apttus_Proposal__Proposal__r.MACD_Change_Type__c != UtilityConstant.PORTACCESS_SPEED_CHANGE && aPLine.Apttus_Proposal__Proposal__r.MACD_Change_Type__c != UtilityConstant.UBBADD && aPLine.Apttus_Proposal__Proposal__r.MACD_Change_Type__c != UtilityConstant.UBBCHANGE && aPLine.Apttus_Proposal__Proposal__r.MACD_Change_Type__c != UtilityConstant.UBBREMOVE && aPLine.Apttus_Proposal__Proposal__r.MACD_Change_Type__c != UtilityConstant.ADDSITE){                                    
                                    if(!aPLine.Apttus_QPConfig__ChargeType__c.contains(UtilityConstant.INSTALLATION) && !aPLine.Apttus_QPConfig__ChargeType__c.contains(UtilityConstant.INTERFACETYPE)){
                                       if(aPLine.Apttus_QPConfig__ChargeType__c == UtilityConstant.ONETIME_FEE ){
                                        Product_Pricing__c pPricicng = new Product_Pricing__c();
                                        
                                        if(mapPriceMatrixEntry.get(aPLine.One_Time_Fee__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null) {    
                                            pPricicng.BEID__c = mapPriceMatrixEntry.get(aPLine.One_Time_Fee__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                            pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(aPLine.One_Time_Fee__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                            pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(aPLine.One_Time_Fee__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                            pPricicng.product_name__c = mapPriceMatrixEntry.get(aPLine.One_Time_Fee__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;
                                            pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(aPLine.One_Time_Fee__c+aPLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                            pPricicng.Product_Detail__c = aPLine.Apttus_QPConfig__ChargeType__c; 
                                           }
                                            if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                            }else if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                            pPricicng.Discountable__c=true;
                                            }
                                            pPricicng.list_price__c = aPLine.Apttus_QPConfig__NetPrice__c;
                                            pPricicng.SP_Product__c = sprod.id;
                                            pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                            pPricingList.add(pPricicng);
                                        }
                                       }
                                      } 
                                   }       
                        //    }   
                            
                        }
                        
                        
                    }
                    
                    
                }else if(sprod.Product_Name__c == ATT_Constant.ATTASE){
                    Product_Pricing__c cosPricing = new Product_Pricing__c();
                    if(quoteLineItemMap.containsKey(sprod.CustomerSiteID__c)){
                        quoteProposalList =  new List<Apttus_Proposal__Proposal_Line_Item__c>();
                        quoteProposalList = quoteLineItemMap.get(sprod.CustomerSiteID__c);
                        for(Apttus_Proposal__Proposal_Line_Item__c aPLine : quoteProposalList){
                            
                            if(aPLine.Apttus_QPConfig__LineType__c==UtilityConstant.OPTION){
                                if(aPLine.Option_Group__c == UtilityConstant.CIR){
                                    
                                    if( CoSTYEPMAPWithLineItemId.containsKey(aPLine.AT_T_Customer_Site__c) ){
                                        //CoSTYEPMAPWithLineItemId
                                        //CIRTYEPMAPWithLineItemId
                                        Product_Pricing__c pPricicng = new Product_Pricing__c();
                                        String combination = SpecialCharacterConstant.CONCAT;
                                        
                                        if (INTERSTATEMAP.get(aPLine.AT_T_Customer_Site__c)){
                                            Combination = aPLine.Apttus_QPConfig__PriceListId__r.name+' + '+CoSTYEPMAPWithLineItemId.get(aPLine.AT_T_Customer_Site__c)+' + '+CIRTYEPMAPWithLineItemId.get(aPLine.AT_T_Customer_Site__c)+' + Interstate';
                                        }
                                        if (INTRASTATEMAP.get(aPLine.AT_T_Customer_Site__c)){
                                            Combination = aPLine.Apttus_QPConfig__PriceListId__r.name+' + '+CoSTYEPMAPWithLineItemId.get(aPLine.AT_T_Customer_Site__c)+' + '+CIRTYEPMAPWithLineItemId.get(aPLine.AT_T_Customer_Site__c)+' + Intrastate';
                                        }
                                         
                                        if(mapProductMap.containsKey(Combination) ){
                                           
                                            pPricicng.Determinant_Set_ID__c = String.valueOf(mapProductMap.get(Combination).Determinant_Set_Id__c);
                                            pPricicng.BEID__c = String.valueOf(mapProductMap.get(Combination).BEID__c);
                                            pPricicng.PBI_Number__c = String.valueOf(mapProductMap.get(Combination).PBIID__c);
                                            pPricicng.product_name__c = mapProductMap.get(Combination).Bill_Display_Name__c;
                                            pPricicng.Low_Level_Tier__c = String.valueOf(mapProductMap.get(Combination).Low_Level_Tier__c);                                           
                                        }
                                        else{
                                            pPricicng.BEID__c = aPLine.Apttus_QPConfig__PriceListItemId__r.BEID__c;
                                            pPricicng.PBI_Number__c = String.valueOf(aPLine.Apttus_QPConfig__PriceListItemId__r.PBIID__c);
                                            pPricicng.Determinant_Set_ID__c = aPLine.Apttus_QPConfig__PriceListItemId__r.Determinant_Set_Id__c;
                                            pPricicng.product_name__c = aPLine.Apttus_QPConfig__PriceListItemId__r.Bill_Display_Name__c;
                                            pPricicng.Low_Level_Tier__c = String.valueOf(aPLine.Apttus_QPConfig__PriceListItemId__r.Low_Level_Tier__c);
                                        }
                                        if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE)
                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                                        pPricicng.list_price__c = aPLine.Apttus_QPConfig__NetPrice__c;
                                        pPricicng.SP_Product__c = sprod.id; 
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                        pPricingList.add(pPricicng);
                                        
                                        }
                                        
                                    }                                    
                                
                                else if(aPLine.Option_Group__c == ATT_Constant.PORT_SPEED ){ 
                                    Product_Pricing__c pPricicng = new Product_Pricing__c();
                                    String combination = SpecialCharacterConstant.CONCAT;
                                    if (INTERSTATEMAP.get(aPLine.AT_T_Customer_Site__c)){
                                        Combination = aPLine.Apttus_QPConfig__PriceListId__r.name+' + '+PORTTYEPMAPWithLineItemId.get(aPLine.AT_T_Customer_Site__c)+' + Interstate';
                                    }
                                    if (INTRASTATEMAP.get(aPLine.AT_T_Customer_Site__c)){
                                        Combination = aPLine.Apttus_QPConfig__PriceListId__r.name+' + '+PORTTYEPMAPWithLineItemId.get(aPLine.AT_T_Customer_Site__c)+' + Intrastate';
                                    }
                                     
                                    if(mapProductMap.containsKey(Combination) ){
                                       
                                        pPricicng.Determinant_Set_ID__c = String.valueOf(mapProductMap.get(Combination).Determinant_Set_Id__c);
                                        pPricicng.BEID__c = String.valueOf(mapProductMap.get(Combination).BEID__c);
                                        pPricicng.PBI_Number__c = String.valueOf(mapProductMap.get(Combination).PBIID__c);
                                        pPricicng.product_name__c = mapProductMap.get(Combination).Bill_Display_Name__c;
                                        pPricicng.Low_Level_Tier__c = String.valueOf(mapProductMap.get(Combination).Low_Level_Tier__c);
                                    }
                                    else{
                                        pPricicng.Determinant_Set_ID__c = aPLine.Apttus_QPConfig__PriceListItemId__r.Determinant_Set_Id__c;
                                        pPricicng.BEID__c =  aPLine.Apttus_QPConfig__PriceListItemId__r.BEID__c;
                                        pPricicng.PBI_Number__c = String.valueOf(aPLine.Apttus_QPConfig__PriceListItemId__r.PBIID__c);
                                        pPricicng.product_name__c = aPLine.Apttus_QPConfig__PriceListItemId__r.Bill_Display_Name__c;
                                        pPricicng.Low_Level_Tier__c = String.valueOf(aPLine.Apttus_QPConfig__PriceListItemId__r.Low_Level_Tier__c);
                                    }
                                    
                                    if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE)
                                    pPricicng.type__c = ATT_Constant.MRCTYPE;
                                    if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                    pPricicng.type__c = ATT_Constant.NRCTYPE;
                                    pPricicng.list_price__c = aPLine.Apttus_QPConfig__NetPrice__c;
                                    pPricicng.SP_Product__c = sprod.id;           
                                    
                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Port').getRecordTypeId();
                                    pPricingList.add(pPricicng);
                                }
                                else{
                                    if(aPLine.Option_Group__c!=UtilityConstant.PORTTYPE && (!ATTConstants.CLASS_OF_SERVICE.equalsIgnoreCase(aPLine.Option_Group__c)) && aPLine.Option_Group__c != UtilityConstant.SERVINGARRANGEMENT){
                                        if(aPLine.Apttus_QPConfig__PriceListItemId__r.BEID__c != SpecialCharacterConstant.CONCAT && aPLine.Apttus_QPConfig__PriceListItemId__r.Determinant_Set_Id__c != SpecialCharacterConstant.CONCAT && aPLine.Apttus_QPConfig__PriceListItemId__r.PBIID__c!= Null && aPLine.Apttus_QPConfig__PriceListItemId__r.Low_Level_Tier__c != NULL){
                                            Product_Pricing__c pPricicng = new Product_Pricing__c();
                                            pPricicng.BEID__c = aPLine.Apttus_QPConfig__PriceListItemId__r.BEID__c;
                                            pPricicng.PBI_Number__c = String.valueOf(aPLine.Apttus_QPConfig__PriceListItemId__r.PBIID__c);
                                            pPricicng.Determinant_Set_ID__c = aPLine.Apttus_QPConfig__PriceListItemId__r.Determinant_Set_Id__c;
                                            if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE)
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                            if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                            pPricicng.list_price__c = aPLine.Apttus_QPConfig__NetPrice__c;
                                            pPricicng.product_name__c = aPLine.Apttus_QPConfig__PriceListItemId__r.Bill_Display_Name__c;
                                            pPricicng.Low_Level_Tier__c = String.valueOf(aPLine.Apttus_QPConfig__PriceListItemId__r.Low_Level_Tier__c);
                                            pPricicng.SP_Product__c = sprod.id;
                                            pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                            pPricingList.add(pPricicng);
                                        }
                                    }
                                }       
                            }   
                          }  
                        }                                
                        
                    }                                       
                    
                else if(sprod.Product_Name__c == ATT_Constant.ATTMIS){
                    if(!MISCOUP.executeOnce){
                        MISCOUP.createSPProductsForQuotes(qList, spProductList, cJunSiteList, proposalLineItem, prodMapList,priceMatrixList);
                        if(MISCOUP.executeOnce == true)
                            IsUpdateOpportunity=true;
                    }
                }    
                 else if(sprod.Product_Name__c == UtilityConstant.ATT_INTERNET_ACCESS){
                    if(!AIACOUP.executeAIAOnce){
                        AIACOUP.createSPProductsForQuotes(qList, spProductList, cJunSiteList, proposalLineItem, prodMapList);
                        if(AIACOUP.executeAIAOnce == true)
                            IsUpdateOpportunity=true;
                    }
                }  
                
                Site__c s = new Site__c();
                s.Address__c = sprod.Mailing_Street_Address__c;
                s.State__c = sprod.State__c;
                s.City__c = sprod.City__c;                          
                s.Line__c = sprod.Mailing_Street_Address__c;
                s.Zip__c = String.valueOf(sprod.Zip__c);
                s.SPProduct__c = sprod.id;              
                siteList.add(s);         
                
            } 
            
            insert siteList;
            insert pPricingList;
            if ( pPricingList.size() != 0  )
                IsUpdateOpportunity=true;   
            
            for(Apttus_Proposal__Proposal__c acp :[Select a.Id,DUNS_Number__c,Apttus_Proposal__Account__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Approval_Stage__c,Apttus_Proposal__Proposal_Expiration_Date__c, End_Customer__r.Name, Owner.Name, Name, Apttus_Proposal__ExpectedEndDate__c,Product__r.name, (select Apttus_QPConfig__OptionId__c,Apttus_QPConfig__OptionId__r.Name,Option_Group__c,
            Apttus_Proposal__Proposal__c,Apttus_QPConfig__OptionId__r.ProductCode,Apttus_Proposal__Product__r.name,
            Apttus_QPConfig__NetPrice__c,Apttus_QPConfig__AdjustedPrice__c,Apttus_QPConfig__OptionId__r.Description,
            Apttus_Proposal__Quantity__c,AT_T_Customer_Site__c,Apttus_QPConfig__ListPrice__c,AT_T_Customer_Site__r.State__c,AT_T_Customer_Site__r.Address_Line__c,AT_T_Customer_Site__r.City__c,AT_T_Customer_Site__r.Zip_Code__c   From Apttus_Proposal__R00N70000001yUfBEAU__r) From Apttus_Proposal__Proposal__c a where Id IN : qList]){
                /*for(Apttus_Proposal__Proposal_Line_Item__c pLine : acp.Apttus_Proposal__R00N70000001yUfBEAU__r){
                    SPProduct__c spProductObj = new SPProduct__c(); 
                    listPrice = 0.0;
                    if(pLine.Option_Group__c == ATT_Constant.ACCESS_SPEED){
                        spProductObj.Access_Speed_Name__c = pLine.Apttus_QPConfig__OptionId__r.Name;
                        spProductObj.Access_Speed_List_Price__c = pLine.Apttus_QPConfig__ListPrice__c;
                        spProductObj.Access_Speed_Type__c = pLine.Option_Group__c;
                        listPrice=listPrice+pLine.Apttus_QPConfig__ListPrice__c;
                    }
                    if(pLine.Option_Group__c == ATT_Constant.PORT_SPEED){
                        spProductObj.Port_Speed_Name__c = pLine.Apttus_QPConfig__OptionId__r.Name;
                        spProductObj.Port_Price__c = pLine.Apttus_QPConfig__ListPrice__c;
                        listPrice=listPrice+pLine.Apttus_QPConfig__ListPrice__c;
                    }
                    if(pLine.Option_Group__c == ATT_Constant.COS){
                        spProductObj.COS_Product_Name__c = pLine.Apttus_QPConfig__OptionId__r.Name;
                        spProductObj.COS_List_Price__c = pLine.Apttus_QPConfig__ListPrice__c;
                        listPrice=listPrice+pLine.Apttus_QPConfig__ListPrice__c;
                    
                    }
                    if(pLine.Option_Group__c == ATT_Constant.INSTALLATION_TYPE){
                        spProductObj.Onsite_Install_Charges__c = pLine.Apttus_QPConfig__ListPrice__c;
                        listPrice=listPrice+pLine.Apttus_QPConfig__ListPrice__c;
                    }
                    spProductObj.List_Price__c = listPrice;                   
                    spProductObj.End_Customer_Name__c = acp.End_Customer__r.Name;
                    spProductObj.Quote_Expiration_Date__c = acp.Apttus_Proposal__Proposal_Expiration_Date__c;
                    spProductObj.State__c = pLine.AT_T_Customer_Site__r.State__c;
                    spProductObj.Street__c = pLine.AT_T_Customer_Site__r.Address_Line__c;
                    spProductObj.City__c = pLine.AT_T_Customer_Site__r.City__c;
                    spProductObj.Mailing_Street_Address__c = pLine.AT_T_Customer_Site__r.Address_Line__c;
                    spProductObj.Zip__c = String.isempty(pLine.AT_T_Customer_Site__r.Zip_Code__c)? null : Integer.valueOf(pLine.AT_T_Customer_Site__r.Zip_Code__c);                 
                    spProductObj.DUNS__c = acp.DUNS_Number__c;
                    spProductObj.RecordTypeId = UtilityConstant.SIVARConst_01260000000LXBL; // For now we have hardcoded to                 
                    record type.
                    spProductObj.Deal__c = acp.Apttus_Proposal__Opportunity__c;
                    spProductObj.Product_Name__c =  acp.Product__r.name;
                    spProductObj.Site_ID__c = pLine.AT_T_Customer_Site__c;
                    
                    spProductList.add(spProductObj);    
                }*/
                quoteLst.add(acp);
            }
            
            /*insert spProductList;                 
            List<Product_Pricing__c> pPricingList = new List<Product_Pricing__c>();
            List<Site__c> siteList = new List <Site__c>();
            for(SPProduct__c sprod : spProductList){
                if(sprod.Port_Speed_Name__c != null){
                    Product_Pricing__c pPricicng = new Product_Pricing__c();
                    pPricicng.SP_Product__c = sprod.id;               
                    pPricicng.product_name__c = sprod.Product_Name__c;
                    pPricicng.list_price__c = sprod.Port_Price__c;
                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get(UtilityConstant.PORT).getRecordTypeId();
                    pPricingList.add(pPricicng); 
                }
                if(sprod.Access_Speed_Name__c != null){
                    Product_Pricing__c aPricicng = new Product_Pricing__c();
                    aPricicng.SP_Product__c = sprod.id;               
                    aPricicng.product_name__c = sprod.Product_Name__c;
                    aPricicng.list_price__c = sprod.Access_Speed_List_Price__c;
                    aPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get(UtilityConstant.ACCESS).getRecordTypeId();
                    pPricingList.add(aPricicng); 
                }
                Site__c s = new Site__c();
                s.City__c = sprod.City__c;                          
                s.Line__c = sprod.Mailing_Street_Address__c;
                s.Zip__c = String.valueOf(sprod.Zip__c);
                s.SPProduct__c = sprod.id;              
                siteList.add(s);           
            
                            
            } 
            insert siteList;
            insert pPricingList; */
            
            if(IsUpdateOpportunity){
                updateOpportunityForQuotes(quoteLst);
            }
            isSuccess = true;
        }catch(Exception e){
            Database.rollback(sp);
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return isSuccess;
        
        
    }

/* 
 Name: updateLineItemWithSiteUsingCartId
 Description: 
 */ 
    public void updateLineItemWithSiteUsingCartId(Map<string,string> siteLinenumberMap, String cartId){
        List<Apttus_Config2__ProductConfiguration__c> propsalLineList = new List<Apttus_Config2__ProductConfiguration__c>();
        List<Apttus_Config2__LineItem__c> updatePropsalList = new List<Apttus_Config2__LineItem__c>();
        try{
            if(cartId != null){
                propsalLineList = [Select a.Id, a.Apttus_QPConfig__Proposald__c, (Select Id, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c  From Apttus_Config2__LineItems__r) From Apttus_Config2__ProductConfiguration__c a where Id = :cartId];
                if(propsalLineList.size()>0){
                    for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                        if(!String.isempty(siteLinenumberMap.get(String.valueOf(p.Apttus_Config2__LineNumber__c)))){
                            p.AT_T_Customer_Site__c = siteLinenumberMap.get(String.valueOf(p.Apttus_Config2__LineNumber__c));
                            updatePropsalList.add(p);
                        }
                    }
                    update updatePropsalList;
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }    
/* 
 Name: updateLineItemWithSite
 Description: 
 */ 
    public void updateLineItemWithSite(Map<string,string> siteLinenumberMap, String quoteId){
        List<Apttus_Config2__ProductConfiguration__c> propsalLineList = new List<Apttus_Config2__ProductConfiguration__c>();
        if(quoteId != null)
        propsalLineList = [Select a.Id, a.Apttus_QPConfig__Proposald__c, (Select Id, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c  From Apttus_Config2__LineItems__r) From Apttus_Config2__ProductConfiguration__c a where Apttus_QPConfig__Proposald__c = :quoteId];
        List<Apttus_Config2__LineItem__c> updatePropsalList = new List<Apttus_Config2__LineItem__c>();
        try
        {       
            if(propsalLineList.size()>0){
                for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                    if(!String.isempty(siteLinenumberMap.get(String.valueOf(p.Apttus_Config2__LineNumber__c)))){
                        p.AT_T_Customer_Site__c = siteLinenumberMap.get(String.valueOf(p.Apttus_Config2__LineNumber__c));
                        updatePropsalList.add(p);
                    }
                }
                update updatePropsalList;
            }
        }
        catch(Exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
/* 
 Name: updateLineItemWithSiteLineNumber
 Description: 
 */ 
    public void updateLineItemWithSiteLineNumber(String siteId, Integer linenumber , String quoteId, Map<String, String> siteLabelAttrMapTemp){
        List<Apttus_Config2__ProductConfiguration__c> propsalLineList = new List<Apttus_Config2__ProductConfiguration__c>();
        if(quoteId != null)
        propsalLineList = [Select a.Id, a.Apttus_QPConfig__Proposald__c, (Select Id, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c, Apttus_Config2__OptionGroupLabel__c  From Apttus_Config2__LineItems__r) From Apttus_Config2__ProductConfiguration__c a where Apttus_QPConfig__Proposald__c = :quoteId];
        List<Apttus_Config2__LineItem__c> updatePropsalList = new List<Apttus_Config2__LineItem__c>();
        try
        {       
            if(propsalLineList.size()>0){
                for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                    if(linenumber == p.Apttus_Config2__LineNumber__c){
                        p.AT_T_Customer_Site__c = siteId;
                        if(!String.isempty(siteLabelAttrMapTemp.get(p.Apttus_Config2__OptionGroupLabel__c))){
                            p.Apttus_Config2__AttributeValueId__c = siteLabelAttrMapTemp.get(p.Apttus_Config2__OptionGroupLabel__c);
                        }
                        updatePropsalList.add(p);
                    }
                }
                update updatePropsalList;
            }
        }
        catch(Exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    
    
/* 
 Name: updateLineItemWithSiteLineNumberUsingCartId
 Description: 
 */ 
    public void updateLineItemWithSiteLineNumberUsingCartId(String siteId, Integer linenumber , String cartId, Map<String, String> siteLabelAttrMapTemp){
        List<Apttus_Config2__ProductConfiguration__c> propsalLineList = new List<Apttus_Config2__ProductConfiguration__c>();
        try{ 
            if(cartId != null){
                propsalLineList = [Select a.Id, a.Apttus_QPConfig__Proposald__c, (Select Id, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c, Apttus_Config2__OptionGroupLabel__c  From Apttus_Config2__LineItems__r) From Apttus_Config2__ProductConfiguration__c a where Id = :cartId];
                List<Apttus_Config2__LineItem__c> updatePropsalList = new List<Apttus_Config2__LineItem__c>();
                if(propsalLineList.size()>0){
                    for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                        if(linenumber == p.Apttus_Config2__LineNumber__c){
                            p.AT_T_Customer_Site__c = siteId;
                            if(!String.isempty(siteLabelAttrMapTemp.get(p.Apttus_Config2__OptionGroupLabel__c))){
                                p.Apttus_Config2__AttributeValueId__c = siteLabelAttrMapTemp.get(p.Apttus_Config2__OptionGroupLabel__c);
                            }
                            updatePropsalList.add(p);
                        }
                    }
                    update updatePropsalList;
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
/* 
 Name: getPicklistValues
 Description: 
 */ 
    public  List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 
        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
      try{
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return lstPickvals;
    }  catch(Exception ex){
        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        
        return null;
    }
    }

    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    
    
/* 
 Name: getAttributeValues
 Description: 
 */ 
    public Map<String, List<String>> getAttributeValues(String productId){
        Map<String, List<String>>  accessNameValueMap = new Map<String, List<String>>();
        List<String> attributeGrpIdLst = new List<String>();
        String attributeBusinessObj;
        try
        {
            //product id for test '01tm0000000ItyZ'
            List<Apttus_Config2__ProductAttributeGroupMember__c> pagmlst = [Select Id, Name, Apttus_Config2__Sequence__c, Apttus_Config2__ProductId__c, Apttus_Config2__AttributeGroupId__c, Apttus_Config2__AttributeGroupId__r.Name, Apttus_Config2__AttributeGroupId__r.Apttus_Config2__BusinessObject__c  from Apttus_Config2__ProductAttributeGroupMember__c where Apttus_Config2__ProductId__c =:productId  and Apttus_Config2__AttributeGroupId__r.Apttus_Config2__BusinessObject__c = 'Apttus_Config2__ProductAttributeValue__c' LIMIT 100];
            for(Apttus_Config2__ProductAttributeGroupMember__c  pagm : pagmlst){
                attributeBusinessObj = pagm.Apttus_Config2__AttributeGroupId__r.Apttus_Config2__BusinessObject__c;
                attributeGrpIdLst.add(pagm.Apttus_Config2__AttributeGroupId__c);
            }
            List<Apttus_Config2__ProductAttributeGroup__c> pagLst = [select Id, Name, Apttus_Config2__TwoColumnAttributeDisplay__c, (select Id, Apttus_Config2__Field__c, Apttus_Config2__IsReadOnly__c from Apttus_Config2__Attributes__r ) from Apttus_Config2__ProductAttributeGroup__c where id IN : attributeGrpIdLst LIMIT 100];
            for(Apttus_Config2__ProductAttributeGroup__c pag:pagLst){
                for(Apttus_Config2__ProductAttribute__c pca : pag.Apttus_Config2__Attributes__r){
                    accessNameValueMap.put(pag.Name, getPicklistValues(attributeBusinessObj, pca.Apttus_Config2__Field__c));
                }
            }
        }
        catch(Exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return accessNameValueMap;
    }

    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    
    
/* 
 Name: addMainProductsIntoBundle
 Description: 
 */ 
    public  List<Decimal> addMainProductsIntoBundle(List<QuoteProducts.cCustomerSite> customerSiteList, String mainproductId, String cartId){
        List<Decimal> lineNumbersLst = new List<Decimal>();
        List <Apttus_CPQApi.CPQ.SelectedProductDO> selectedProdDOList = new List <Apttus_CPQApi.CPQ.SelectedProductDO>();
        Apttus_CPQApi.CPQ.SelectedProductDO selProdDO = null;
        try
        {
            for(QuoteProducts.cCustomerSite cs : customerSiteList){           
                selProdDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
                selProdDO.ProductID = mainproductId;
                selProdDO.Quantity = 1;
                selProdDO.SellingTerm = 1;
                selProdDO.StartDate = Date.Today();
                selProdDO.EndDate = Date.Today() + 12;
                selProdDO.Comments = UtilityConstant.ADDEDBY_CODE; 
                selectedProdDOList.add(selProdDO);                         
            } 
            Apttus_CPQApi.CPQ.AddMultiProductRequestDO bundleReqDO = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO();
            bundleReqDO.cartID = cartId;
            bundleReqDO.SelectedProducts = selectedProdDOList;
            Apttus_CPQApi.CPQ.AddMultiProductResponseDO bundleRespDO = Apttus_CPQApi.CPQWebService.addMultiProducts(bundleReqDO);       
            lineNumbersLst = bundleRespDO.LineNumbers;
        }
        catch(Exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return lineNumbersLst;
    } 
    
    
    /**********************************************************************************************************************************************************************************************************/    
/* 
 Name: addMainProductIntoBundle
 Description: 
 */ 
    public  List<Decimal> addMainProductIntoBundle(CustomerSite__c customerSiteList, String mainproductId, String cartId){
        List<Decimal> lineNumbersLst = new List<Decimal>();
        List <Apttus_CPQApi.CPQ.SelectedProductDO> selectedProdDOList = new List <Apttus_CPQApi.CPQ.SelectedProductDO>();
        Apttus_CPQApi.CPQ.SelectedProductDO selProdDO = null;
        try
        {
            selProdDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
            selProdDO.ProductID = mainproductId;
            selProdDO.Quantity = 1;
            selProdDO.SellingTerm = 1;
            selProdDO.StartDate = Date.Today();
            selProdDO.EndDate = Date.Today() + 12;
            selProdDO.Comments = UtilityConstant.ADDEDBY_CODE; 
            selectedProdDOList.add(selProdDO);                                                 
            Apttus_CPQApi.CPQ.AddMultiProductRequestDO bundleReqDO = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO();
            bundleReqDO.cartID = cartId;
            bundleReqDO.SelectedProducts = selectedProdDOList;
            Apttus_CPQApi.CPQ.AddMultiProductResponseDO bundleRespDO = Apttus_CPQApi.CPQWebService.addMultiProducts(bundleReqDO);       
            lineNumbersLst = bundleRespDO.LineNumbers;
        }
        catch(Exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return lineNumbersLst;
    } 
    

    /**********************************************************************************************************************************************************************************************************/    
    public QuoteProducts.SelectPricingWrap getProductComponentOptionWrapper(List<Apttus_CPQApi.CPQ.ProductOptionGroupDO> productOptionGLst, String mainproductId)
    {
        
        QuoteProducts.SelectPricingWrap pcw = new QuoteProducts.SelectPricingWrap();
        list<QuoteProducts.ProductOption> optionsList = new list<QuoteProducts.ProductOption>();
        list<QuoteProducts.ProductOption> portTypeList = new list<QuoteProducts.ProductOption>();
        list<QuoteProducts.ProductOption> portSpeedList = new list<QuoteProducts.ProductOption>();
        list<QuoteProducts.ProductOption> accessSpeedList = new list<QuoteProducts.ProductOption>();
        list<QuoteProducts.ProductOption> minbandList = new list<QuoteProducts.ProductOption>();
        list<QuoteProducts.ProductOption> installOptionList = new list<QuoteProducts.ProductOption>();
        try
        {
            for(Apttus_CPQApi.CPQ.ProductOptionGroupDO optg :productOptionGLst)
            {
                if(optg.Name == UtilityConstant.OPTIONS && mainProductId != ProductId__c.getValues(UtilityConstant.ASES).Product_Id__c)
                {
                    QuoteProducts.ProductOption options = new QuoteProducts.ProductOption();
                    options.Name = optg.Name;
                    options.productoptionGroupId = optg.productoptiongroupId;
                    options.minOptions = optg.minOptions;
                    options.MaxOptions = optg.MaxOptions;
                    options.price = 0.00;
                    options.showoption = false;
                    pcw.options= options;
                    for(Apttus_CPQApi.CPQ.ProductOptionComponentDO optgcomp: optg.OptionComponents)
                    {
                        QuoteProducts.ProductOption po = new QuoteProducts.ProductOption();
                        po.Name = optgcomp.Name;
                        po.componentid = optgcomp.ComponentId;
                        po.productid = optgcomp.ComponentProductId;
                        po.showoption = true;
                        if(optgcomp.hasprices)
                        {
                            po.price = optgcomp.Prices[0].value;
                        }
                        optionsList.add(po);    
                    }
                    
                    
                }               
                if(optg.Name == UtilityConstant.PORTTYPE1){
                    QuoteProducts.ProductOption porttype = createProduct(optg);
                    optionsList.add(porttype);
                }else if(optg.Name == UtilityConstant.PORTSPEED){                    
                    QuoteProducts.ProductOption portSpeed = createProduct(optg);
                    optionsList.add(portSpeed);
                }else if(optg.Name == UtilityConstant.ACCESSSPEED){
                    QuoteProducts.ProductOption accessspeed = createProduct(optg);
                    optionsList.add(accessspeed);
                }else if(optg.Name == UtilityConstant.INSTALLATIONOPTIONS){
                    QuoteProducts.ProductOption installOption = createProduct(optg);
                    optionsList.add(installOption);
                }else{ //if(optg.Name.equalsIgnoreCase(UtilityConstant.MINIMUMBANDWIDTH_COMMITMENT) || optg.Name.equalsIgnoreCase(UtilityConstant.ACCESSTYPE) || optg.Name.equalsIgnoreCase(UtilityConstant.INTERFACETYPE) || optg.Name == UtilityConstant.ADDITIONALDNS || optg.Name == UtilityConstant.SERVINGARRANGEMENT || optg.Name == UtilityConstant.CLASSOF_SERVICE || optg.Name == UtilityConstant.CLASSOF_SERVICE_PER_PACKET_x || optg.Name == UtilityConstant.CIR){
                    QuoteProducts.ProductOption minband = createProduct(optg);
                    optionsList.add(minband);
                }
                
            }
            pcw.optionslist = optionsList;
        }catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return pcw;
    }

    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    
    private QuoteProducts.ProductOption createProduct(Apttus_CPQApi.CPQ.ProductOptionGroupDO optg)
    {
        QuoteProducts.ProductOption mainProduct = new QuoteProducts.ProductOption ();
        
        mainProduct.Name = optg.Name;
        mainProduct.productoptionGroupId = optg.productoptiongroupId;
        mainProduct.minOptions = optg.minOptions;
        mainProduct.MaxOptions = optg.MaxOptions;
        mainProduct.price = 0.00;
        mainProduct.showoption = false;
        
        list<QuoteProducts.ProductOption> prodchildList = new list<QuoteProducts.ProductOption>();
        
        if(optg.HasOptionComponents){
            for(Apttus_CPQApi.CPQ.ProductOptionComponentDO optgcomp: optg.OptionComponents)
            {
                QuoteProducts.ProductOption mb = new QuoteProducts.ProductOption();
                mb.Name = optgcomp.Name;
                mb.componentid = optgcomp.ComponentId;
                mb.productid = optgcomp.ComponentProductId;
                mb.showoption = false;
                if(optgcomp.hasprices)
                {
                    mb.price = optgcomp.Prices[0].value;
                }
                prodchildList.add(mb);    
            }
        }
        if(optg.Name == UtilityConstant.PORTTYPE){
            mainProduct.portTypeList = prodchildList;
        }
        else if(optg.Name == UtilityConstant.PORTSPEED){
            mainProduct.portSpeedList = prodchildList;
        }
        else if(optg.Name == UtilityConstant.ACCESSSPEED){
            mainProduct.accessSpeedList = prodchildList;
        }
        else if(optg.Name == UtilityConstant.INSTALLATIONOPTIONS){
            mainProduct.accessSpeedList = prodchildList;
        }
        else{
            mainProduct.minBandList = prodchildList;
        }
        
        return mainProduct;
    }

    /**********************************************************************************************************************************************************************************************************/      
    public void getSelectOptionPortType(List<QuoteProducts.Productoption> optionsList , Boolean flag, String porttype )
    {
        list<selectoption> porttypeselectopt = new list<selectoption>();
        porttypeselectopt.add(new selectoption(UtilityConstant.SELECT1, porttype));
        try{
        for(QuoteProducts.Productoption optgrp: optionslist)
        {
            if(optgrp.name == porttype)
            {
                for(QuoteProducts.Productoption port: optgrp.porttypelist )
                {
                    if(flag == true && port.name == UtilityConstant.SWITCHEDETHERNET1)
                    porttypeselectopt.add(new selectoption(port.productid, port.name));
                    if(flag == false && (port.name == UtilityConstant.PRIVATELINE_T1 || port.name == UtilityConstant.PRIVATELINE_T3))
                    porttypeselectopt.add(new selectoption(port.productid, port.name));
                    if(flag == null)
                    porttypeselectopt.add(new selectoption(port.productid, port.name));
                }
                optgrp.prodOptnsLst = porttypeselectopt; 
                optgrp.showListOption = true; 

            }
            //optgrp.prodOptnsLst = porttypeselectopt;
            
        }
        
    } catch(Exception ex){
        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        
       
    }
    }
    
    /**********************************************************************************************************************************************************************************************************/    
    public void getSelectOptionPortSpeed(List<QuoteProducts.Productoption> optionsList , Boolean flag, String PortSpeed )
    {
        list<selectoption> porttypeselectopt = new list<selectoption>();
        List<QuoteProducts.Productoption> optList = null;
        porttypeselectopt.add(new selectoption(UtilityConstant.SELECT1, PortSpeed));
        try{
        for(QuoteProducts.Productoption optgrp: optionslist)
        {
            if(optgrp.name == PortSpeed)
            {
                if(optgrp.porttypelist != null){
                    optList = optgrp.porttypelist;
                }else if(optgrp.portspeedlist != null){
                    optList = optgrp.portspeedlist;
                }else if(optgrp.accessSpeedList  != null){
                    optList = optgrp.accessSpeedList;
                }else if(optgrp.installOptionList   != null){
                    optList = optgrp.installOptionList;
                } else if(optgrp.minBandList   != null){
                    optList = optgrp.minBandList;
                }  
                for(QuoteProducts.Productoption port: optList)
                {
                    porttypeselectopt.add(new selectoption(port.productid, port.name));
                }
                optgrp.prodOptnsLst = porttypeselectopt; 
                optgrp.showListOption = true; 

            }/*else if(optgrp.name == UtilityConstant.CONNECTIONSPEED || optgrp.name == UtilityConstant.IPADDRESSES)
            {
                for(QuoteProducts.Productoption port: optgrp.minBandList)
                {
                        porttypeselectopt.add(new selectoption(port.productid, port.name));
                }
                optgrp.prodOptnsLst = porttypeselectopt; 
                optgrp.showListOption = true; 

            }*/
            //optgrp.prodOptnsLst = porttypeselectopt;
            
        }
        
    } catch(Exception ex){
        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
       
     
    }
        
    }

    /**********************************************************************************************************************************************************************************************************/ 
    public list<selectoption> getSelectOptionPortSpeedNewV2(List<QuoteProducts.Productoption> optionsList , String portspeed, set<string>suggProdId, String prevLst,String selectedProdId, String portType)
    {
        list<selectoption> portspeedselectopt = new list<selectoption>();
        portspeedselectopt.add(new selectoption(UtilityConstant.SELECTAMALLCAP, portspeed));
        List<QuoteProducts.Productoption> optList = null;
        List<QuoteProducts.Productoption> optListnext = null;
        try{
        for(QuoteProducts.Productoption optgrp: optionslist)
        {
            if(optgrp.name == prevLst)
            {
                if(optgrp.porttypelist != null){
                    optList = optgrp.porttypelist;
                }else if(optgrp.portspeedlist != null){
                    optList = optgrp.portspeedlist;
                }else if(optgrp.accessSpeedList  != null){
                    optList = optgrp.accessSpeedList;
                }else if(optgrp.installOptionList   != null){
                    optList = optgrp.installOptionList;
                } else if(optgrp.minBandList   != null){
                    optList = optgrp.minBandList;
                }  
                if(optList != null){
                    for(QuoteProducts.Productoption port: optList)
                    {
                        if(port.productId == selectedProdId){
                            optgrp.price = port.price;
                        }
                    }
                }              

            }
            if(optgrp.name == portspeed)
            {
                if(optgrp.porttypelist != null){
                    optListnext = optgrp.porttypelist;
                }else if(optgrp.portspeedlist != null){
                    optListnext = optgrp.portspeedlist;
                }else if(optgrp.accessSpeedList  != null){
                    optListnext = optgrp.accessSpeedList;
                }else if(optgrp.installOptionList   != null){
                    optListnext = optgrp.installOptionList;
                } else if(optgrp.minBandList   != null){
                    optListnext = optgrp.minBandList;
                }  
                if(optListnext != null){
                    if(UtilityConstant.SWITCHEDETHERNET.equalsIgnoreCase(portType)){
                        for(QuoteProducts.Productoption port: optListnext){
                            // if(!suggProdId.contains(SelectedProdId))
                            if((!String.isempty(port.name)) && (!port.name.contains(UtilityConstant.T1)))
                            {
                                portspeedselectopt.add(new selectoption(port.productid, port.name));
                            }
                            if(optgrp.productId == selectedProdId){
                                optgrp.price = port.price;
                            }
                        }
                    }else{
                        for(QuoteProducts.Productoption port: optListnext){
                            // if(!suggProdId.contains(SelectedProdId))
                            if((!String.isempty(port.name)) && (port.name.contains(UtilityConstant.T1)))
                            {
                                portspeedselectopt.add(new selectoption(port.productid, port.name));
                            }
                            if(optgrp.productId == selectedProdId){
                                optgrp.price = port.price;
                            }
                        }
                    }
                    optgrp.prodOptnsLst = portspeedselectopt; 
                    optgrp.showListOption = true; 
                }              

            }
            
        }
        return portspeedselectopt;
        
    } catch(Exception ex){
        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
       
        return null;
    }
    }
        
    /**********************************************************************************************************************************************************************************************************/     
    public list<selectoption> getSelectOptionPortSpeedNew(List<QuoteProducts.Productoption> optionsList , String portspeed, set<string>suggProdId, String prevLst,String selectedProdId)
    {
        try{
        list<selectoption> portspeedselectopt = new list<selectoption>();
        portspeedselectopt.add(new selectoption(UtilityConstant.SELECTAMALLCAP, portspeed));
        List<QuoteProducts.Productoption> optList = null;
        List<QuoteProducts.Productoption> optListnext = null;
        
        for(QuoteProducts.Productoption optgrp: optionslist)
        {
            if(optgrp.name == prevLst)
            {
                if(optgrp.porttypelist != null){
                    optList = optgrp.porttypelist;
                }else if(optgrp.portspeedlist != null){
                    optList = optgrp.portspeedlist;
                }else if(optgrp.accessSpeedList  != null){
                    optList = optgrp.accessSpeedList;
                }else if(optgrp.installOptionList   != null){
                    optList = optgrp.installOptionList;
                } else if(optgrp.minBandList   != null){
                    optList = optgrp.minBandList;
                }  
                if(optList != null){
                    for(QuoteProducts.Productoption port: optList)
                    {
                        if(port.productId == selectedProdId){
                            optgrp.price = port.price;
                        }
                    }
                }              

            }
            if(optgrp.name == portspeed)
            {
                if(optgrp.porttypelist != null){
                    optListnext = optgrp.porttypelist;
                }else if(optgrp.portspeedlist != null){
                    optListnext = optgrp.portspeedlist;
                }else if(optgrp.accessSpeedList  != null){
                    optListnext = optgrp.accessSpeedList;
                }else if(optgrp.installOptionList   != null){
                    optListnext = optgrp.installOptionList;
                } else if(optgrp.minBandList   != null){
                    optListnext = optgrp.minBandList;
                }  
                if(optListnext != null){
                    for(QuoteProducts.Productoption port: optListnext)
                    {
                        // if(!suggProdId.contains(SelectedProdId))
                        if(!suggProdId.contains(port.productId))
                        {
                            portspeedselectopt.add(new selectoption(port.productid, port.name));
                        }
                        if(optgrp.productId == selectedProdId){
                            optgrp.price = port.price;
                        }
                    }
                    optgrp.prodOptnsLst = portspeedselectopt; 
                    optgrp.showListOption = true; 
                }              

            }
            
        }
        return portspeedselectopt;
        
    } catch(Exception ex){
        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        
        return null;
    }
    }
    
    /**********************************************************************************************************************************************************************************************************/
    public void setMultiSelectOptionPortSpeed(List<QuoteProducts.Productoption> optionsList , Set<String> nextTypeSet, set<string>suggProdId, Map<String,String> nextTypeSelectedProdMap, Map<String,decimal> nextTypeSelectedPriceMap)
    {
        list<selectoption> portspeedselectopt = new list<selectoption>();
        List<QuoteProducts.Productoption> optList = null;
        List<QuoteProducts.Productoption> optListnext = null;
        Decimal tprice = 0;
        QuoteInfoHelper quoteHelper = new QuoteInfoHelper();
        try{
            for(QuoteProducts.Productoption optgrp: optionslist){
                if(nextTypeSet.contains(optgrp.name)){
                    portspeedselectopt = new list<selectoption>();  
                    portspeedselectopt.add(new selectoption(UtilityConstant.SELECT1, optgrp.name));
                    if(optgrp.portspeedlist != null){
                        optListnext = optgrp.portspeedlist;
                    }else if(optgrp.accessSpeedList  != null){
                        optListnext = optgrp.accessSpeedList;
                    }else if(optgrp.installOptionList   != null){
                        optListnext = optgrp.installOptionList;
                    } else if(optgrp.minBandList   != null){
                        optListnext = optgrp.minBandList;
                    } else if(optgrp.porttypelist   != null){
                        optListnext = optgrp.porttypelist;
                    }   
                    if(optListnext != null){
                        for(QuoteProducts.Productoption port: optListnext){
                            if(!suggProdId.contains(port.productId)){
                                portspeedselectopt.add(new selectoption(port.productid, port.name));
                            }
                            /*if(optgrp.productId == selectedProdId){
                                optgrp.price = port.price;
                            }*/
                        }
                        optgrp.selectedProduct = nextTypeSelectedProdMap.get(optgrp.name);
                        tprice = QuoteHelper.checkNull(nextTypeSelectedPriceMap.get(optgrp.name));
                        optgrp.price = tprice;
                        optgrp.prodOptnsLst = portspeedselectopt; 
                        optgrp.showListOption = true; 
                    }              
                }                        
            } 
        }catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }       
    }    
    /**********************************************************************************************************************************************************************************************************/ 
    /**********************************************************************************************************************************************************************************************************/
    public void setMultiSelectOptionPortSpeedV2(List<QuoteProducts.Productoption> optionsList , Set<String> nextTypeSet, set<string>suggProdId, Map<String,String> nextTypeSelectedProdMap, Map<String,decimal> nextTypeSelectedPriceMap, Boolean boolVal)
    {
        list<selectoption> portspeedselectopt = new list<selectoption>();
        List<QuoteProducts.Productoption> optList = null;
        List<QuoteProducts.Productoption> optListnext = null;
        Decimal tprice = 0;
        QuoteInfoHelper quoteHelper = new QuoteInfoHelper();
        try{
            for(QuoteProducts.Productoption optgrp: optionslist){
                if(nextTypeSet.contains(optgrp.name)){
                    portspeedselectopt = new list<selectoption>();  
                    portspeedselectopt.add(new selectoption(UtilityConstant.SELECTAMALLCAP, optgrp.name));
                    if(optgrp.portspeedlist != null){
                        optListnext = optgrp.portspeedlist;
                    }else if(optgrp.accessSpeedList  != null){
                        optListnext = optgrp.accessSpeedList;
                    }else if(optgrp.installOptionList   != null){
                        optListnext = optgrp.installOptionList;
                    } else if(optgrp.minBandList   != null){
                        optListnext = optgrp.minBandList;
                    } else if(optgrp.porttypelist   != null){
                        optListnext = optgrp.porttypelist;
                    }   
                    if(optListnext != null){
                        for(QuoteProducts.Productoption port: optListnext){
                             if(!suggProdId.contains(port.productId) && optgrp.porttypelist != null){
                                if((boolVal == true && port.name == UtilityConstant.SWITCHEDETHERNET) || (boolVal == false && port.name == UtilityConstant.PRIVATELINE_T1) || (boolVal == null)){
                                    portspeedselectopt.add(new selectoption(port.productid, port.name));
                                }
                            }
                            else if(!suggProdId.contains(port.productId)){
                                portspeedselectopt.add(new selectoption(port.productid, port.name));
                            }else{
                            }
                            /*if(optgrp.productId == selectedProdId){
                                optgrp.price = port.price;
                            }*/
                        }
                        optgrp.selectedProduct = nextTypeSelectedProdMap.get(optgrp.name);
                        tprice = QuoteHelper.checkNull(nextTypeSelectedPriceMap.get(optgrp.name));
                        optgrp.price = tprice;
                        optgrp.prodOptnsLst = portspeedselectopt; 
                        optgrp.showListOption = true; 
                    }else{
                        optgrp.selectedProduct = nextTypeSelectedProdMap.get(optgrp.name);
                        tprice = QuoteHelper.checkNull(nextTypeSelectedPriceMap.get(optgrp.name));
                        optgrp.price = tprice;
                        optgrp.isSelected = true;
                    }              
                }                        
            } 
        }catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }       
    }    
    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    
/* 
 Name: getPrimaryLineNumForLineItems
 Description: 
 */ 
    public list<Integer> getPrimaryLineNumForLineItems(String cartId, decimal linenumber){
        list<Integer> primarylineNumberList = new list<Integer>();
        List<Apttus_Config2__LineItem__c> existingLineitemList =new List<Apttus_Config2__LineItem__c>() ;
        list<Integer> linenumberList = new list<Integer>();
        Integer primaryLineCount = 0;
        Integer countline = 1;
        Integer max = 0;
        try{
            //linenumberList.add(linenumber.intValue());   
            if(cartId != null){
              if(linenumber.intValue() == 1){
                return primarylineNumberList;
              }
                max = linenumber.intValue() == 1 ? 1 : linenumber.intValue() -1;
                for(integer i = 1; i <= max; i++){ //get the line number for a configuration
                    linenumberList.add(i);
                }
                //get lineitems from the congiguration belonging to the linenumbers to get the primary line numbers
                existingLineitemList = [Select Id, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__OptionGroupLabel__c, Apttus_Config2__Description__c,Apttus_Config2__ProductOptionId__c, Apttus_Config2__PrimaryLineNumber__c, Apttus_Config2__ConfigurationId__c From Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: cartId and Apttus_Config2__LineNumber__c in :linenumberlist];
            }
            if(existingLineitemList != null){
                primaryLineCount = existingLineitemList.size();
                for(Apttus_Config2__LineItem__c li: existingLineitemList){
                    //primarylineNumberList.add((li.Apttus_Config2__PrimaryLineNumber__c.intValue()-1));
                    primarylineNumberList.add((li.Apttus_Config2__PrimaryLineNumber__c.intValue()));
                    if((primaryLineCount-1) == countLine){
                        break;
                    }
                    countLine++;
                }
            }  
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return primarylineNumberList;
    }

    /**********************************************************************************************************************************************************************************************************/    
    public set<String> getConstraintRuleResultNew(String cartId, list<Integer>primarylinenumber)
    {
        Set<string> suggestedProdIdSet = new set<string>();
        list<String> suggProdList = new list<String>();
        List<Integer> linenumberList = new List<Integer>();
        try{
            //linenumberList.add(linenumber.intValue());   
            Apttus_CPQApi.CPQWebService.associateConstraintRules(cartId,primarylinenumber);
            Apttus_CPQApi.CPQWebService.applyConstraintRules(cartId, false);
            Apttus_CPQApi.CPQ.ConstraintResultDO constraintResult = Apttus_CPQApi.CPQWebService.getConstraintRuleResult(cartId);
            if(constraintResult != null){
                if(constraintResult.ConstraintRuleActions != null){
                    for(Apttus_CPQApi.CPQ.AppliedActionDO appliedAct :constraintResult.ConstraintRuleActions)
                    {
                        if(appliedAct.actionType == UtilityConstant.EXCLUSION)
                        {
                            suggProdList = appliedAct.SuggestedProductIds;
                            suggestedProdIdSet.addAll(suggProdList);
                        }
                    }
                }               
            }            
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        
        
        return suggestedProdIdSet;
    }
    
    /* 
     * Name : getConstraintRuleResultNewV2
      */
    public set<String> getConstraintRuleResultNewV2(String cartId, list<Integer>primarylinenumber, Set<String>  selectedProductId)
    {
        Set<string> suggestedProdIdSet = new set<string>();
        list<String> suggProdList = new list<String>();
        List<Integer> linenumberList = new List<Integer>();
        String tpid = null;
        Integer max = 0;
        try{
            //linenumberList.add(linenumber.intValue()); 
            if(primarylinenumber.isEmpty()){//changed on 1/27/2014
                primarylinenumber.add(1);
            }    
            Apttus_CPQApi.CPQWebService.associateConstraintRules(cartId,primarylinenumber);
            Apttus_CPQApi.CPQWebService.applyConstraintRules(cartId, false);
            Apttus_CPQApi.CPQ.ConstraintResultDO constraintResult = Apttus_CPQApi.CPQWebService.getConstraintRuleResult(cartId);
            if(constraintResult != null){
                if(constraintResult.ConstraintRuleActions != null){
                    for(Apttus_CPQApi.CPQ.AppliedActionDO appliedAct :constraintResult.ConstraintRuleActions)
                    {
                        Tpid = (appliedAct.TriggeringProductIds != null && appliedAct.TriggeringProductIds.size() > 0) ? appliedAct.TriggeringProductIds[0] : null;
                        if(Tpid != null && appliedAct.actionType == UtilityConstant.EXCLUSION && selectedProductId.contains(Tpid)){
                            suggProdList = appliedAct.SuggestedProductIds;
                            suggestedProdIdSet.addAll(suggProdList);
                            if(suggestedProdIdSet.contains(UtilityConstant.SIVARConst_01TM0000000ISHSAAS)){
                            }
                        }
                    }
                }               
            }            
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        
        
        return suggestedProdIdSet;
    }
    
    /**********************************************************************************************************************************************************************************************************/    
    public set<String> getConstraintRuleResult(String cartId, decimal linenumber)
    {
        Set<string> suggestedProdIdSet = new set<string>();
        list<String> suggProdList = new list<String>();
        List<Integer> linenumberList = new List<Integer>();
        try{
            linenumberList.add(linenumber.intValue());   
            //for(integer i =1; i <22; i++)
            //linenumberList.add(i); 
            //linenumberList.add(2);
            //linenumberList.add(3);   
            Apttus_CPQApi.CPQWebService.associateConstraintRules(cartId,linenumberList);
            
            Apttus_CPQApi.CPQWebService.applyConstraintRules(cartId, false);
            Apttus_CPQApi.CPQ.ConstraintResultDO constraintResult = Apttus_CPQApi.CPQWebService.getConstraintRuleResult(cartId);
            if(constraintResult != null){
                if(constraintResult.ConstraintRuleActions != null){
                    for(Apttus_CPQApi.CPQ.AppliedActionDO appliedAct :constraintResult.ConstraintRuleActions)
                    {
                        if(appliedAct.actionType == UtilityConstant.EXCLUSION)
                        {
                            suggProdList = appliedAct.SuggestedProductIds;
                            suggestedProdIdSet.addAll(suggProdList);
                        }
                    }
                }               
            }            
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        
        
        return suggestedProdIdSet;
    }
    
    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    
    
/* 
 Name: getSelectedProduct
 Description: 
 */ 
    public QuoteProducts.Productoption getSelectedProduct(List<QuoteProducts.Productoption> optionsList, String type, String productId){
        QuoteProducts.Productoption selectedProduct;
        try{
            for(QuoteProducts.Productoption optgrp: optionslist){
                if(type.equalsIgnoreCase(optgrp.name)){
                    if(!String.isempty(optgrp.selectedProduct)){
                        List<QuoteProducts.Productoption> optListNext = null;
                        if(optgrp.porttypelist != null){
                            optListNext = optgrp.porttypelist;
                        }else if(optgrp.portspeedlist != null){
                            optListNext = optgrp.portspeedlist;
                        }else if(optgrp.accessSpeedList  != null){
                            optListNext = optgrp.accessSpeedList;
                        }else if(optgrp.installOptionList   != null){
                            optListNext = optgrp.installOptionList;
                        } else if(optgrp.minBandList   != null){
                            optListNext = optgrp.minBandList;
                        }
                        if(optListNext != null){
                            for(QuoteProducts.Productoption op: optListNext){
                                if(op.productId.equalsIgnoreCase(productId)){
                                    selectedProduct = op;
                                    break;
                                }
                            } 
                        }else if(optListNext == null && optgrp.productId == productId) {
                            selectedProduct = optgrp;
                            break;
                        }                  
                    }else if(optgrp.productId == productId){
                        selectedProduct = optgrp;
                        if(optgrp.isselected){
                            selectedProduct.deletionRequired = false;
                        }else{
                            selectedProduct.deletionRequired = true;
                        }                       
                        break;
                    }
                }           
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return selectedProduct;
    }

    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    
    
/* 
 Name: createLineItem
 Description: 
 */ 
    public void createLineItem(String quoteId, Integer linenumber, String type, String cartId, QuoteProducts.Productoption selectedProduct){
        boolean isSuccess = false;    
        List<Apttus_Config2__ProductConfiguration__c> propsalLineList = [Select a.Id, a.Apttus_QPConfig__Proposald__c, (Select Id, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__OptionGroupLabel__c, Apttus_Config2__Description__c,Apttus_Config2__ProductOptionId__c   From Apttus_Config2__LineItems__r) From Apttus_Config2__ProductConfiguration__c a where Id = :cartId];
        List<Apttus_Config2__LineItem__c> existingLineitemList = new List<Apttus_Config2__LineItem__c>();
        List<String> deleteProductIds = new List<String>();
        List<String> componentsProductIds = new List<String>();
        try{
            if(propsalLineList.size()>0){
                boolean found = false;
                for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                    if(p.Apttus_Config2__LineNumber__c == linenumber && type.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                        found = true;
                        if(p.Apttus_Config2__Description__c.equalsIgnoreCase(selectedProduct.name)){
                            if(selectedProduct.deletionRequired != null && selectedProduct.deletionRequired){
                                existingLineitemList.add(p);
                                deleteProductIds.add(p.Apttus_Config2__ProductId__c);
                                componentsProductIds.add(p.Apttus_Config2__ProductOptionId__c);                            
                                break;
                            }
                            break;//do nothing
                        }else{
                            existingLineitemList.add(p);
                            deleteProductIds.add(p.Apttus_Config2__ProductId__c);
                            componentsProductIds.add(p.Apttus_Config2__ProductOptionId__c);
                            found = false;
                            break;
                        }                   
                    }else if(p.Apttus_Config2__LineNumber__c == linenumber && UtilityConstant.OPTIONS.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c) && type.equalsIgnoreCase(p.Apttus_Config2__Description__c)){
                        if(selectedProduct.deletionRequired){
                            existingLineitemList.add(p);
                            deleteProductIds.add(p.Apttus_Config2__ProductId__c);
                            componentsProductIds.add(p.Apttus_Config2__ProductOptionId__c);  
                            found = true;                          
                            break;
                        }
                    }
                }
                if(existingLineitemList.size()>0){
                    //delete existingLineitemList;
                    isSuccess = removeOptions(cartId, linenumber, componentsProductIds);
                    if(isSuccess){
                        applyConstraintRulesOnDelete(cartId, deleteProductIds);
                    }
                }
                if(!found){
                    List<QuoteProducts.Productoption> prodOptCompDOList = new List<QuoteProducts.Productoption>();
                    prodOptCompDOList.add(selectedProduct);
                    List<Apttus_CPQApi.CPQ.SelectedOptionDO> selectedOptionList = createSelectedOptionList(prodOptCompDOList);
                    addOptionsToBundle(linenumber, cartId, selectedOptionList);
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        
    }

    /**********************************************************************************************************************************************************************************************************/

/* 
 Name: createLineItemV2
 Description: 
 */ 
    public List<String> createLineItemV2(String quoteId, Integer linenumber, String type, String cartId, QuoteProducts.Productoption selectedProduct){
        boolean isSuccess = false;    
        List<Apttus_Config2__ProductConfiguration__c> propsalLineList = [Select a.Id, a.Apttus_QPConfig__Proposald__c, (Select Id, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__OptionGroupLabel__c, Apttus_Config2__Description__c,Apttus_Config2__ProductOptionId__c   From Apttus_Config2__LineItems__r) From Apttus_Config2__ProductConfiguration__c a where Id = :cartId];
        List<Apttus_Config2__LineItem__c> existingLineitemList = new List<Apttus_Config2__LineItem__c>();
        List<String> deleteProductIds = new List<String>();
        List<String> componentsProductIds = new List<String>();
        try{
            if(propsalLineList.size()>0){
                boolean found = false;
                for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                    if(p.Apttus_Config2__LineNumber__c == linenumber && type.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                        found = true;
                        if(p.Apttus_Config2__Description__c.equalsIgnoreCase(selectedProduct.name)){
                            if(selectedProduct.deletionRequired != null && selectedProduct.deletionRequired){
                                existingLineitemList.add(p);
                                deleteProductIds.add(p.Apttus_Config2__ProductId__c);
                                componentsProductIds.add(p.Apttus_Config2__ProductOptionId__c);                            
                                break;
                            }
                            break;//do nothing
                        }else{
                            existingLineitemList.add(p);
                            deleteProductIds.add(p.Apttus_Config2__ProductId__c);
                            componentsProductIds.add(p.Apttus_Config2__ProductOptionId__c);
                            found = false;
                            break;
                        }                   
                    }else if(p.Apttus_Config2__LineNumber__c == linenumber && UtilityConstant.OPTIONS.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c) && type.equalsIgnoreCase(p.Apttus_Config2__Description__c)){
                        if(selectedProduct.deletionRequired){
                            existingLineitemList.add(p);
                            deleteProductIds.add(p.Apttus_Config2__ProductId__c);
                            componentsProductIds.add(p.Apttus_Config2__ProductOptionId__c);  
                            found = true;                          
                            break;
                        }
                    }
                }
                if(existingLineitemList.size()>0){
                    //delete existingLineitemList;
                    //isSuccess = removeOptions(cartId, linenumber, componentsProductIds);
                    //if(isSuccess){
                    //applyConstraintRulesOnDelete(cartId, deleteProductIds);
                    //}
                }
                if(!found){
                    List<QuoteProducts.Productoption> prodOptCompDOList = new List<QuoteProducts.Productoption>();
                    prodOptCompDOList.add(selectedProduct);
                    List<Apttus_CPQApi.CPQ.SelectedOptionDO> selectedOptionList = createSelectedOptionList(prodOptCompDOList);
                    addOptionsToBundle(linenumber, cartId, selectedOptionList);
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return componentsProductIds;
    }    
    /**********************************************************************************************************************************************************************************************************/    
    
/* 
 Name: removeOptions
 Description: 
 */ 
    public Boolean removeOptions(Id cartId, Integer lineNumber, LIST<String> componentIds){
        boolean isSuccess = false;
        try{
            Apttus_CPQApi.CPQ.RemoveOptionsResponseDO res = Apttus_CPQApi.CPQWebService.removeOptions( cartId, lineNumber, componentIds);
            isSuccess = res.IsSuccess;
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return isSuccess;
    }
    
    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    
    
/* 
 Name: applyConstraintRulesOnDelete
 Description: 
 */ 
    public void applyConstraintRulesOnDelete(String cartId, list<String> productIds){
        try{           
            Apttus_CPQApi.CPQWebService.applyConstraintRulesOnDelete(cartId, productIds);
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }

    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    
    
/* 
 Name: createSelectedOptionList
 Description: 
 */ 
    public List<Apttus_CPQApi.CPQ.SelectedOptionDO>  createSelectedOptionList(List<QuoteProducts.Productoption> prodOptCompDOList) {
        try{
        List<Apttus_CPQApi.CPQ.SelectedOptionDO> selectedOptDOList = new List<Apttus_CPQApi.CPQ.SelectedOptionDO>();
        for(QuoteProducts.Productoption prodOptCompDO :prodOptCompDOList ) {
            Apttus_CPQApi.CPQ.SelectedOptionDO selectedOptDO = new Apttus_CPQApi.CPQ.SelectedOptionDO();
            selectedOptDO.ComponentId = prodOptCompDO.ComponentId;
            selectedOptDO.ComponentProductId = prodOptCompDO.ProductId;
            selectedOptDO.Quantity = 1;
            selectedOptDOList.add(selectedOptDO);
        }
        return selectedOptDOList;
    } catch(Exception ex){
        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        
        return null;
    }
    }
    
    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    

/* 
 Name: addOptionsToBundle
 Description: 
 */ 
    public void addOptionsToBundle(Integer liNum,String cartId, List<Apttus_CPQApi.CPQ.SelectedOptionDO> selectOptDOList) {
        try{
            Apttus_CPQApi.CPQ.AddOptionsResponseDO addOptRespDO = Apttus_CPQApi.CPQWebService.addOptions(cartId, liNum, selectOptDOList);
            //SynchronizeCart(cartId);
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    
   /* private void synchronizeCart(String cartId){
        try{
            // create the synchronize cart request
            Apttus_CPQApi.CPQ.SynchronizeCartRequestDO request = new Apttus_CPQApi.CPQ.SynchronizeCartRequestDO();
            // add requestparameters
            request.CartId = cartId;
            // synchronize the cart
            Apttus_CPQApi.CPQ.SynchronizeCartResponseDO result = Apttus_CPQApi.CPQWebService.synchronizeCart(request);
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }*/

    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    
    
    /*public void updateLineItem(decimal LineNum, string interfaceType, string accessType, string QuoteId)
{
    set<string> prodconfigId = new set<string>();
    list<Apttus_Config2__LineItem__c> lineItems = new list<Apttus_Config2__LineItem__c>();
    list<Apttus_Config2__LineItem__c> linesToUpdate = new list<Apttus_Config2__LineItem__c>();
    list<Apttus_Config2__ProductConfiguration__c> prodConfig = new list<Apttus_Config2__ProductConfiguration__c>();
    list<Apttus_Config2__ProductAttributeValue__c> prodattr = new list<Apttus_Config2__ProductAttributeValue__c>();
    list<string> lineId = new list<string>();  
    Set<string> linesToUpdateCheck = new Set<string>();   
    try
    {
        prodConfig = new list<Apttus_Config2__ProductConfiguration__c>([select id, Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =: QuoteId]);
        
        if(prodConfig !=null)
        {
            for(Apttus_Config2__ProductConfiguration__c pc : prodConfig)
                prodconfigId.add(pc.Id);
        }
        
        if(prodConfigId != null)
            lineItems = [Select a.Apttus_Config2__LineNumber__c,a.Apttus_Config2__OptionGroupLabel__c, a.Apttus_Config2__ConfigurationId__c, a.Apttus_Config2__AttributeValueId__c, a.Access_Speed__c, a.AT_T_Customer_Site__c From Apttus_Config2__LineItem__c a where a.Apttus_Config2__ConfigurationId__c in :prodConfigId];
        
        if(lineItems != null)
        {
            for(Apttus_Config2__LineItem__c line: lineItems)
            {
                if(line.Apttus_Config2__OptionGroupLabel__c == UtilityConstant.ACCESSSPEED && line.Apttus_Config2__LineNumber__c == lineNum)
                {
                    Apttus_Config2__ProductAttributeValue__c attrVal = new Apttus_Config2__ProductAttributeValue__c();
                    attrVal.Access_Type__c = accessType;
                    attrVal.Interface_Type__c = interfaceType;
                    attrVal.Apttus_Config2__LineItemId__c = line.Id;
                    prodattr.add(attrVal);
                    lineId.add(line.id);
                }
            }  
            if(prodattr != null)
                insert prodattr; 
        for(Apttus_Config2__ProductAttributeValue__c pattr: [select id, Apttus_Config2__LineItemId__c from Apttus_Config2__ProductAttributeValue__c where Apttus_Config2__LineItemId__c in :lineId])
        {
            for(Apttus_Config2__LineItem__c li: lineItems)
            {
                if(li.id == pattr.Apttus_Config2__LineItemId__c)
                {
                    li.Apttus_Config2__AttributeValueId__c = pattr.Id;
                    if(!linesToUpdateCheck.contains(li.id)){
                        linesToUpdate.add(li);
                        linesToUpdateCheck.add(li.id);
                    }
                }
            }
        }
        }
        
        if(linesToUpdate != null)
        {
            update linesToUpdate;
        }
    }
    catch(Exception e)
    {
        ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
    }   
} */

/* 
 Name: updateLineItem
 Description: 
 */ 
    public void updateLineItem(String optionGroupLabel, decimal LineNum, string interfaceType, string accessType, string cartId, Map<string,string> siteLinenumberMap){
        String prodId = null;
        List<Apttus_Config2__LineItem__c> pecsList = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c pLine = null;
        try{
            List<Apttus_Config2__ProductConfiguration__c> propsalLineList = [select Id,Name,(Select Id,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__LineItem__c.Apttus_Config2__OptionId__r.Name,Apttus_Config2__Description__c,Apttus_Config2__OptionGroupLabel__c,Apttus_Config2__LineType__c,Apttus_Config2__NetPrice__c,Apttus_Config2__PricingStatus__c, Apttus_Config2__ProductOptionId__c,Apttus_Config2__AttributeValueId__c, Access_Speed__c  From Apttus_Config2__LineItems__r where Apttus_Config2__LineNumber__c =: LineNum.intValue()) from Apttus_Config2__ProductConfiguration__c where Apttus_Config2__ProductConfiguration__c.Id=:cartID];
            if(propsalLineList.size()>0 && propsalLineList[0].Apttus_Config2__LineItems__r.size()>0){
                for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                    if(optionGroupLabel.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                        pLine = p;
                    }
                    pecsList.add(p);
                }
            }
            if(pecsList != null && pecsList.size()>0){
                //Creating the ProductAttributeValue object as per selected policy and adding it to the Line item
                Apttus_Config2__ProductAttributeValue__c obj = new  Apttus_Config2__ProductAttributeValue__c();
                if(pLine != null && UtilityConstant.ACCESSSPEED.equalsIgnoreCase(pLine.Apttus_Config2__OptionGroupLabel__c)){
                    obj.Access_Type__c = accessType;
                    obj.Interface_Type__c = interfaceType;
                    obj.Apttus_Config2__LineItemId__c = pLine.Id;
                }else if(pLine != null && UtilityConstant.PORTSPEED.equalsIgnoreCase(pLine.Apttus_Config2__OptionGroupLabel__c)){
                    if(Boolean.valueOf(accessType)){
                        obj.Managed_Router__c = true;
                    }else{
                        obj.Managed_Router__c = false;
                    }
                    obj.Apttus_Config2__LineItemId__c = pLine.Id;
                }
                if(pLine.Apttus_Config2__AttributeValueId__c != null){
                    obj.Id = pLine.Apttus_Config2__AttributeValueId__c;
                    update obj;
                }else{
                    insert obj; 
                }
                for(Apttus_Config2__LineItem__c pecsObj: pecsList){ 
                    if(optionGroupLabel.equalsIgnoreCase(pecsObj.Apttus_Config2__OptionGroupLabel__c)){
                        pecsObj.Apttus_Config2__AttributeValueId__c = obj.Id; 
                    }         
                    pecsObj.AT_T_Customer_Site__c = siteLinenumberMap.get(String.valueOf(LineNum));
                }
                update pecsList;
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }



/* 
 Name: getCIROption
 Description: 
 */ 
    public list<selectoption> getCIROption(List<QuoteProducts.Productoption> optionsList ,  String selectedProdId){
       try{
        list<selectoption> portspeedselectopt = new list<selectoption>();  
        for(QuoteProducts.Productoption optgrp: optionslist){
            if(UtilityConstant.CIR.equalsIgnoreCase(optgrp.name)){
                for(Selectoption so : optgrp.prodOptnsLst){
                    if(selectedProdId != null && (so.getValue() == selectedProdId || selectedProdId.equalsIgnoreCase(so.getValue()))){
                        portspeedselectopt.add(new selectoption(so.getValue(),so.getlabel()));
                        break;
                    }else{
                        portspeedselectopt.add(new selectoption(so.getValue(),so.getlabel()));
                    }
                }
            }
        }
        return portspeedselectopt;
    } catch(Exception ex){
        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        
        return null;
    }
    }

    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    
    
/* 
 Name: SiteProductDetails
 Type: Class 
 
 Description: 
 */ 
    public class SiteProductDetails{
        public Set<String> productSetIds{set;get;}
        public String siteAddressId{set;get;}
        public String parentProductId{set;get;}
    } 
    /**********************************************************************************************************************************************************************************************************/    
    //Anira Specific Logic


/* 
 Name: getSelectedProduct
 Description: 
 */ 
   //Removed as part of US787937  
   public QuoteInfoController_Anira.Productoption getSelectedProduct(List<QuoteInfoController_Anira.Productoption> optionsList, String type, String productId){
        QuoteInfoController_Anira.Productoption selectedProduct;
        try{
            for(QuoteInfoController_Anira.Productoption optgrp: optionslist){
                if(optgrp.ComponentProductId == productId){
                    selectedProduct = optgrp;
                    break;
                }       
            }
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return selectedProduct;
    }

    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    

/* 
 Name: createLineItem
 Description: 
 */ 
 //Removed as part of US787937  
    public void createLineItem(String quoteId, Integer linenumber, String type, String cartId, QuoteInfoController_Anira.Productoption selectedProduct){    
        List<Apttus_Config2__ProductConfiguration__c> propsalLineList = [Select a.Id, a.Apttus_QPConfig__Proposald__c, (Select Id, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__OptionGroupLabel__c, Apttus_Config2__Description__c,Apttus_Config2__ProductOptionId__c   From Apttus_Config2__LineItems__r) From Apttus_Config2__ProductConfiguration__c a where Apttus_QPConfig__Proposald__c = :quoteId];
        List<Apttus_Config2__LineItem__c> existingLineitemList = new List<Apttus_Config2__LineItem__c>();
        List<String> deleteProductIds = new List<String>();
        List<String> componentsProductIds = new List<String>();
        try{
            if(propsalLineList.size()>0){
                boolean found = false;
                for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                    if(p.Apttus_Config2__LineNumber__c == linenumber && type.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                        found = true;
                        if(p.Apttus_Config2__Description__c.equalsIgnoreCase(selectedProduct.name)){
                            if(selectedProduct.deletionRequired != null && selectedProduct.deletionRequired){
                                existingLineitemList.add(p);
                                deleteProductIds.add(p.Apttus_Config2__ProductId__c);
                                componentsProductIds.add(p.Apttus_Config2__ProductOptionId__c);                            
                                break;
                            }
                            break;//do nothing
                        }else{
                            existingLineitemList.add(p);
                            deleteProductIds.add(p.Apttus_Config2__ProductId__c);
                            componentsProductIds.add(p.Apttus_Config2__ProductOptionId__c);
                            found = false;
                            break;
                        }                   
                    }else if(p.Apttus_Config2__LineNumber__c == linenumber && UtilityConstant.OPTIONS.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c) && type.equalsIgnoreCase(p.Apttus_Config2__Description__c)){
                        if(selectedProduct.deletionRequired){
                            existingLineitemList.add(p);
                            deleteProductIds.add(p.Apttus_Config2__ProductId__c);
                            componentsProductIds.add(p.Apttus_Config2__ProductOptionId__c);  
                            found = true;                          
                            break;
                        }
                    }
                }
                if(existingLineitemList.size()>0){
                    //delete existingLineitemList;
                    removeOptions(cartId, linenumber, componentsProductIds);
                    applyConstraintRulesOnDelete(cartId, deleteProductIds);
                }
                if(!found){
                    List<QuoteInfoController_Anira.Productoption> prodOptCompDOList = new List<QuoteInfoController_Anira.Productoption>();
                    prodOptCompDOList.add(selectedProduct);
                    List<Apttus_CPQApi.CPQ.SelectedOptionDO> selectedOptionList = createSelectedOptionList(prodOptCompDOList);
                    addOptionsToBundle_Anira(linenumber, cartId, selectedOptionList);
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        
    }




/* 
 Name: createSelectedOptionList
 Description: 
 */
 //Removed as part of US787937   
    public List<Apttus_CPQApi.CPQ.SelectedOptionDO>  createSelectedOptionList(List<QuoteInfoController_Anira.Productoption> prodOptCompDOList) {
       try{
        List<Apttus_CPQApi.CPQ.SelectedOptionDO> selectedOptDOList = new List<Apttus_CPQApi.CPQ.SelectedOptionDO>();
        for(QuoteInfoController_Anira.Productoption prodOptCompDO :prodOptCompDOList ) {
            Apttus_CPQApi.CPQ.SelectedOptionDO selectedOptDO = new Apttus_CPQApi.CPQ.SelectedOptionDO();
            selectedOptDO.ComponentId = prodOptCompDO.ComponentId;
            selectedOptDO.ComponentProductId = prodOptCompDO.ComponentProductId;
            selectedOptDO.Quantity = 1;
            selectedOptDOList.add(selectedOptDO);
        }
        return selectedOptDOList;
    } catch(Exception ex){
        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        
        return null;
    }
    }

    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    

/* 
 Name: addOptionsToBundle_Anira
 Description: 
 */ 
    public void addOptionsToBundle_Anira(Integer liNum,String cartId, List<Apttus_CPQApi.CPQ.SelectedOptionDO> selectOptDOList) {
        try{
            Apttus_CPQApi.CPQ.AddOptionsResponseDO addOptRespDO = Apttus_CPQApi.CPQWebService.addOptions(cartId, liNum, selectOptDOList);
            //SynchronizeCart(cartId);
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    
    /*CreateSPProducts specifically for ANIRA   */

/* 
 Name: createSPProductsForQuotes_Anira
 Description: 
 */ 
    public boolean createSPProductsForQuotes_Anira(Set<Id> qList, boolean IsUpdateOpportunity){
        //FETCH Apttus_Proposal__Proposal_Line_Item__c
        // Query on quote (EBM Org) 
        List<Apttus_Proposal__Proposal__c> quoteLst = new List<Apttus_Proposal__Proposal__c>();
        Map<String,List<Apttus_Proposal__Proposal_Line_Item__c> > mapProposalLineItem = new Map<String,List<Apttus_Proposal__Proposal_Line_Item__c> >();
        Map<String,String> quoteOpp = new Map<String, String>();
        boolean isSuccess = false;
        Savepoint sp = null;
        try{

            //bulk quote reading
            sp = Database.setSavepoint();
            Double listPrice = 0.0;
            List<SPProduct__c> spProductList = new List<SPProduct__c>();
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItem = [select Apttus_QPConfig__OptionId__c,Apttus_QPConfig__OptionId__r.Name,Option_Group__c,
            Apttus_Proposal__Proposal__c,Apttus_QPConfig__OptionId__r.ProductCode,Apttus_Proposal__Product__r.name,
            Apttus_QPConfig__NetPrice__c, Apttus_QPConfig__AdjustedPrice__c,Apttus_QPConfig__OptionId__r.Description,Apttus_QPConfig__PriceType__c,
            Apttus_Proposal__Quantity__c, Apttus_QPConfig__ChargeType__c, AT_T_Customer_Site__c,Apttus_QPConfig__ListPrice__c,Apttus_QPConfig__LineType__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c IN : qList];

            quoteLst = [Select id, Apttus_Proposal__Opportunity__c, EndCustomerName__c, Apttus_Proposal__Approval_Stage__c, Apttus_Proposal__Proposal_Expiration_Date__c,  EndCustomerState__c, EndCustomerCity__c, EndCustomerMailingStreetAddress__c, DUNS_Number__c, Product__r.name, EndCustomerZip__c, Product__r.ProductCode from Apttus_Proposal__Proposal__c where id IN :qList];
            for (Apttus_Proposal__Proposal__c q : quoteLst) {
                quoteOpp.put(q.Apttus_Proposal__Opportunity__c, q.id);    
            }

            Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>> quoteLineItemMap = new Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>>();
            //Done
            for(Apttus_Proposal__Proposal_Line_Item__c p : proposalLineItem){
                if(quoteLineItemMap.containskey(p.Apttus_Proposal__Proposal__c)){
                    quoteLineItemMap.get(p.Apttus_Proposal__Proposal__c).add(p);                   
                }else{
                    quoteLineItemMap.put(p.Apttus_Proposal__Proposal__c,new List<Apttus_Proposal__Proposal_Line_Item__c>{p});
                }
            }
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalList = new List<Apttus_Proposal__Proposal_Line_Item__c>(); 
            List<Apttus_Proposal__Proposal_Line_Item__c> quoteProposalList = new List<Apttus_Proposal__Proposal_Line_Item__c>(); 
            
            for(Apttus_Proposal__Proposal__c prop : quoteLst){
                if(quoteLineItemMap.containsKey(prop.id)){               
                    listPrice = 0.0;
                    proposalList = quoteLineItemMap.get(prop.id);//pass quote id here
                    SPProduct__c spProductObj = new SPProduct__c(); 
                    for(Apttus_Proposal__Proposal_Line_Item__c pLine : proposalList){ 
                        if(pLine.Apttus_QPConfig__OptionId__c != null){                     
                            if(pLine.Option_Group__c == UtilityConstant.PNCBANDWIDTH){
                                spProductObj.PNC_Bandwidth__c = pLine.Apttus_QPConfig__OptionId__r.Name;                              
                                listPrice=listPrice+pLine.Apttus_QPConfig__NetPrice__c;
                            }
                        }              
                        
                        
                    }
                    spProductObj.List_Price__c = listPrice;                   
                    spProductObj.End_Customer_Name__c = prop.EndCustomerName__c;
                    spProductObj.Quote_Expiration_Date__c = prop.Apttus_Proposal__Proposal_Expiration_Date__c;
                    spProductObj.State__c = prop.EndCustomerState__c;
                    spProductObj.City__c = prop.EndCustomerCity__c;
                    spProductObj.Mailing_Street_Address__c = prop.EndCustomerMailingStreetAddress__c;
                    spProductObj.Zip__c = String.isempty(prop.EndCustomerZip__c)? null : prop.EndCustomerZip__c;
                    spProductObj.DUNS__c = prop.DUNS_Number__c;                 
                    spProductObj.Deal__c = prop.Apttus_Proposal__Opportunity__c;
                    spProductObj.Product_Name__c =  prop.Product__r.name;
                    //spProductObj.Site_ID__c = prop.AT_T_Customer_Site__c;    

                     if(Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().containskey(Label.AniraLabel)) { // Null check added by Praveen (Defect : DE86900)               
                         spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(Label.AniraLabel).getRecordTypeId();
                     }   
                    spProductList.add(spProductObj);
                }
                
                
            }                                       
            insert spProductList;                 
            
            List<Product_Pricing__c> pPricingList = new List<Product_Pricing__c>();

            for(SPProduct__c sprod : spProductList){       
                if(sprod.PNC_Bandwidth__c != null){
                    Product_Pricing__c pPricicng = new Product_Pricing__c();
                    if(quoteLineItemMap.containsKey(quoteOpp.get(sprod.Deal__c))){
                        quoteProposalList =  new List<Apttus_Proposal__Proposal_Line_Item__c>();
                        quoteProposalList = quoteLineItemMap.get(quoteOpp.get(sprod.Deal__c));
                        for(Apttus_Proposal__Proposal_Line_Item__c aPLine : quoteProposalList){
                            if(aPLine.Option_Group__c == UtilityConstant.PNCBANDWIDTH){
                                pPricicng.list_price__c = aPLine.Apttus_QPConfig__NetPrice__c;
                                if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE)
                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                if(aPLine.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                             
                            }
                            
                        }
                    }                    
                    pPricicng.SP_Product__c = sprod.id;               
                    pPricicng.product_name__c = sprod.Product_Name__c;                   
                    // pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get(UtilityConstant.PORT).getRecordTypeId();
                    pPricingList.add(pPricicng); 
                }
                
            }
            
            
            
            /* Code Changes begins -DE97469 -  Ashfaq - 01-08-2015*/
            if(pPricingList.size()>0){
                IsUpdateOpportunity = true;
            
            }
            
            /* Code Changes Ends -DE97469 -  Ashfaq - 01-08-2015*/
            
             
            
            
            
            insert pPricingList;
            
            
            for(Apttus_Proposal__Proposal__c acp :[Select a.Id,DUNS_Number__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Approval_Stage__c,Apttus_Proposal__Proposal_Expiration_Date__c, End_Customer__r.Name, Owner.Name, Name, Apttus_Proposal__ExpectedEndDate__c,Product__r.name, (select Apttus_QPConfig__OptionId__c,Apttus_QPConfig__OptionId__r.Name,Option_Group__c,
            Apttus_Proposal__Proposal__c,Apttus_QPConfig__OptionId__r.ProductCode,Apttus_Proposal__Product__r.name,
            Apttus_QPConfig__NetPrice__c,Apttus_QPConfig__AdjustedPrice__c,Apttus_QPConfig__OptionId__r.Description,
            Apttus_Proposal__Quantity__c, Apttus_QPConfig__ChargeType__c, AT_T_Customer_Site__c,Apttus_QPConfig__ListPrice__c,AT_T_Customer_Site__r.State__c,AT_T_Customer_Site__r.Address_Line__c,AT_T_Customer_Site__r.City__c,AT_T_Customer_Site__r.Zip_Code__c   From Apttus_Proposal__R00N70000001yUfBEAU__r) From Apttus_Proposal__Proposal__c a where Id IN : qList]){

                quoteLst.add(acp);
            }
            
            if(IsUpdateOpportunity){
                updateOpportunityForQuotes(quoteLst);
            }
            isSuccess = true;
        }catch(Exception e){
            Database.rollback(sp);
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));          
        }
        return isSuccess;
    }

    /**********************************************************************************************************************************************************************************************************/    
    /**********************************************************************************************************************************************************************************************************/    
/* 
 Name: createSPProductsForQuotes_STAAS
 Description: 
 */ 
    public boolean createSPProductsForQuotes_STAAS(Set<Id> qList, boolean IsUpdateOpportunity){
        //FETCH Apttus_Proposal__Proposal_Line_Item__c
        // Query on quote (EBM Org) 
        List<Apttus_Proposal__Proposal__c> quoteLst = new List<Apttus_Proposal__Proposal__c>();
        Map<String,List<Apttus_Proposal__Proposal_Line_Item__c> > mapProposalLineItem = new Map<String,List<Apttus_Proposal__Proposal_Line_Item__c> >();
        Map<String,String> quoteOpp = new Map<String, String>();
        boolean isSuccess = false;
        Savepoint sp = null;
        try{

            //bulk quote reading
            sp = Database.setSavepoint();
            Double listPrice = 0.0;
            Double oneTimePrice = 0.0;
            List<SPProduct__c> spProductList = new List<SPProduct__c>();
            List<Apttus_Config2__ProductConfiguration__c> lstProductConfig = new List<Apttus_Config2__ProductConfiguration__c>();
            List<Apttus_Config2__LineItem__c> lstProductConfigLine = new List<Apttus_Config2__LineItem__c>();
            Map<String, String> mapQuoteConfig = new Map<String, String>();
            
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItem = [select Apttus_QPConfig__OptionId__c,Apttus_QPConfig__OptionId__r.Name,Option_Group__c, Apttus_QPConfig__ExtendedPrice__c,        
            Apttus_Proposal__Proposal__c,Apttus_QPConfig__OptionId__r.ProductCode,Apttus_Proposal__Product__r.name,Apttus_QPConfig__PriceListItemId__c,Apttus_QPConfig__PriceListItemId__r.PBIID__c,
            Apttus_QPConfig__PriceListItemId__r.Determinant_Set_Id__c,Apttus_QPConfig__PriceListItemId__r.BEID__c,Apttus_QPConfig__PriceListItemId__r.Low_Level_Tier__c,
            Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__AttributeValueId__r.Policy_1_Local_Protection__c, Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__AttributeValueId__r.Policy_2_Remote_Application__c, 
            Apttus_QPConfig__NetPrice__c, Apttus_QPConfig__AdjustedPrice__c,Apttus_QPConfig__OptionId__r.Description,Apttus_QPConfig__PriceType__c,
            Apttus_Proposal__Quantity__c, Apttus_QPConfig__ChargeType__c, AT_T_Customer_Site__c,Apttus_QPConfig__ListPrice__c,Apttus_QPConfig__LineType__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c IN : qList];
            
            lstProductConfig = [Select id, Apttus_QPConfig__Proposald__c From Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c in : qList];
            for (Apttus_Config2__ProductConfiguration__c  objProductConfig : lstProductConfig) {
                mapQuoteConfig.put(objProductConfig.Apttus_QPConfig__Proposald__c, objProductConfig.id);    
            }
            // lstProductConfigLine = [Select id, Apttus_Config2__AttributeValueId__c, Apttus_Config2__AttributeValueId__r.Policy_1_Local_Protection__c, Apttus_Config2__AttributeValueId__r.Policy_2_Remote_Application__c where Apttus_Config2__ProductAttributeValue__c IN : qList];
            
            quoteLst = [Select id, Apttus_Proposal__Opportunity__c, EndCustomerName__c, Apttus_Proposal__Approval_Stage__c, Apttus_Proposal__Proposal_Expiration_Date__c,  EndCustomerState__c, EndCustomerCity__c, EndCustomerMailingStreetAddress__c, DUNS_Number__c, Product__r.name, EndCustomerZip__c, Product__r.ProductCode from Apttus_Proposal__Proposal__c where id IN : qList];
            for (Apttus_Proposal__Proposal__c q : quoteLst) {
                quoteOpp.put(q.Apttus_Proposal__Opportunity__c, q.id);    
            }

            Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>> quoteLineItemMap = new Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>>();
            //Done
            for(Apttus_Proposal__Proposal_Line_Item__c p : proposalLineItem){
                if(quoteLineItemMap.containskey(p.Apttus_Proposal__Proposal__c)){
                    quoteLineItemMap.get(p.Apttus_Proposal__Proposal__c).add(p);                   
                }else{
                    quoteLineItemMap.put(p.Apttus_Proposal__Proposal__c,new List<Apttus_Proposal__Proposal_Line_Item__c>{p});
                }
            }
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalList = new List<Apttus_Proposal__Proposal_Line_Item__c>(); 
            List<Apttus_Proposal__Proposal_Line_Item__c> quoteProposalList = new List<Apttus_Proposal__Proposal_Line_Item__c>(); 
            
            for(Apttus_Proposal__Proposal__c prop : quoteLst){
                if(quoteLineItemMap.containsKey(prop.id)){               
                    listPrice = 0.0;
                    oneTimePrice  = 0.0;
                    proposalList = quoteLineItemMap.get(prop.id);//pass quote id here
                    SPProduct__c spProductObj = new SPProduct__c(); 
                    for(Apttus_Proposal__Proposal_Line_Item__c pLine : proposalList){ 
                        if ( pLine.Apttus_QPConfig__OptionId__c == NULL && pLine .Apttus_QPConfig__PriceType__c == UtilityConstant.RECURRING)
                        listPrice = pLine.Apttus_QPConfig__ExtendedPrice__c;
                        if ( pLine.Apttus_QPConfig__OptionId__c == NULL && pLine .Apttus_QPConfig__PriceType__c == UtilityConstant.ONETIME)
                        oneTimePrice  = pLine .Apttus_QPConfig__ExtendedPrice__c;
                        
                        
                    }
                    spProductObj.List_Price__c = listPrice;
                    spProductObj.one_time_revenue__c= oneTimePrice;                    
                    spProductObj.End_Customer_Name__c = prop.EndCustomerName__c;
                    spProductObj.Quote_Expiration_Date__c = prop.Apttus_Proposal__Proposal_Expiration_Date__c;
                    spProductObj.State__c = prop.EndCustomerState__c;
                    spProductObj.City__c = prop.EndCustomerCity__c;
                    spProductObj.Mailing_Street_Address__c = prop.EndCustomerMailingStreetAddress__c;
                    spProductObj.Zip__c = String.isempty(prop.EndCustomerZip__c)? null : prop.EndCustomerZip__c;
                    spProductObj.DUNS__c = prop.DUNS_Number__c;                 
                    spProductObj.Deal__c = prop.Apttus_Proposal__Opportunity__c;
                    spProductObj.Product_Name__c =  prop.Product__r.name;
                    //spProductObj.Site_ID__c = prop.AT_T_Customer_Site__c;    
                    if(Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().containskey(prop.Product__r.ProductCode)) // Null check added by Praveen (Defect : DE86900)               
                    spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get('StaaS').getRecordTypeId();
                    else
                    spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get('StaaS').getRecordTypeId();
                    spProductList.add(spProductObj);
                }
                
                
            }                                       
            insert spProductList;                 
            
            List<Product_Pricing__c> pPricingList = new List<Product_Pricing__c>();

            for(SPProduct__c sprod : spProductList){       
                for(Apttus_Proposal__Proposal__c prop : quoteLst){
                    if(quoteLineItemMap.containsKey(prop.id)){ 
                        proposalList = quoteLineItemMap.get(prop.id);
                        for(Apttus_Proposal__Proposal_Line_Item__c Pline :proposalList ){
                            if(Pline.Apttus_QPConfig__OptionId__c!=null){
                                Product_Pricing__c pPricicng = new Product_Pricing__c();
                                pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                pPricicng.list_price__c = Pline.Apttus_QPConfig__NetPrice__c;
                                pPricicng.PBI_Number__c = string.valueof(Pline.Apttus_QPConfig__PriceListItemId__r.PBIID__c);
                                pPricicng.Determinant_Set_ID__c=Pline.Apttus_QPConfig__PriceListItemId__r.Determinant_Set_Id__c;
                                pPricicng.BEID__c=Pline.Apttus_QPConfig__PriceListItemId__r.BEID__c;
                                pPricicng.Low_Level_Tier__c=String.valueOf(Pline.Apttus_QPConfig__PriceListItemId__r.Low_Level_Tier__c);
                                pPricicng.SP_Product__c = sprod.id; 
                                if( Pline.Apttus_QPConfig__OptionId__r.Name == UtilityConstant.BULKINGESTION_DATA_TRANSFER_PER_DISK_DRIVE){
                                    pPricicng.product_name__c = UtilityConstant.STORAGEBULK_INGESTION_ADD_ON;
                                    pPricicng.type__c = UtilityConstant.NRC;
                                }
                                else if( Pline.Apttus_QPConfig__OptionId__r.Name == UtilityConstant.AVERAGEOUTBOUND_DATA_TRANSFER_PER_MONTH_GB_x){
                                    pPricicng.product_name__c = UtilityConstant.TRANSFERAMOUNT;
                                    pPricicng.type__c = UtilityConstant.MRC;
                                }
                                else if( Pline.Apttus_QPConfig__OptionId__r.Name == UtilityConstant.AVERAGESTORAGE_PER_MONTH_GB_x){
                                    pPricicng.type__c = UtilityConstant.MRC;
                                    if(Pline.Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__AttributeValueId__r.Policy_1_Local_Protection__c){
                                        pPricicng.product_name__c = UtilityConstant.POLICY1_LOCAL_PROTECTION;
                                    }else if(Pline.Apttus_QPConfig__DerivedFromId__r.Apttus_Config2__AttributeValueId__r.Policy_2_Remote_Application__c){
                                        pPricicng.product_name__c = UtilityConstant.POLICY2_REMOTE_REPLICATION;
                                    }
                                } 
                                else{
                                    pPricicng.type__c = UtilityConstant.MRC;
                                    pPricicng.product_name__c = UtilityConstant.NOOPTION;
                                }
                                pPricingList.add(pPricicng); 
                            }
                        }
                    }
                    
                    
                } 
            }
            
            insert pPricingList;
            
            
            for(Apttus_Proposal__Proposal__c acp :[Select a.Id,DUNS_Number__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Approval_Stage__c,Apttus_Proposal__Proposal_Expiration_Date__c, End_Customer__r.Name, Owner.Name, Name, Apttus_Proposal__ExpectedEndDate__c,Product__r.name, (select Apttus_QPConfig__OptionId__c,Apttus_QPConfig__OptionId__r.Name,Option_Group__c,
            Apttus_Proposal__Proposal__c,Apttus_QPConfig__OptionId__r.ProductCode,Apttus_Proposal__Product__r.name,
            Apttus_QPConfig__NetPrice__c,Apttus_QPConfig__AdjustedPrice__c,Apttus_QPConfig__OptionId__r.Description,
            Apttus_Proposal__Quantity__c, Apttus_QPConfig__ChargeType__c, AT_T_Customer_Site__c,Apttus_QPConfig__ListPrice__c,AT_T_Customer_Site__r.State__c,AT_T_Customer_Site__r.Address_Line__c,AT_T_Customer_Site__r.City__c,AT_T_Customer_Site__r.Zip_Code__c   From Apttus_Proposal__R00N70000001yUfBEAU__r) From Apttus_Proposal__Proposal__c a where Id IN : qList]){

                quoteLst.add(acp);
            }
            
            if(IsUpdateOpportunity){
                updateOpportunityForQuotes(quoteLst);
            }
            isSuccess = true;
        }catch(Exception e){
            Database.rollback(sp);
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));             
        }
        return isSuccess;
    }


/* 
 Name: cleanLineItemListOnPortSelect
 Description: 
 */ 
    public void cleanLineItemListOnPortSelect(Integer linenumber,  String cartId){
        List<Apttus_Config2__ProductConfiguration__c> propsalLineList = [Select a.Id, a.Apttus_QPConfig__Proposald__c, (Select Id, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__OptionGroupLabel__c, Apttus_Config2__Description__c,Apttus_Config2__ProductOptionId__c   From Apttus_Config2__LineItems__r where Apttus_Config2__LineNumber__c =: linenumber ) From Apttus_Config2__ProductConfiguration__c a where Id = :cartId];
        List<String> componentsProductIds = new List<String>();
        List<String> deleteProductIds = new List<String>();
        try{
            if(propsalLineList.size()>0){
                for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                    if(p.Apttus_Config2__LineNumber__c == linenumber && !String.isempty(p.Apttus_Config2__OptionGroupLabel__c) && (!UtilityConstant.Options.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)) && (!UtilityConstant.INSTALLATIONOPTIONS.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c))){
                        deleteProductIds.add(p.Apttus_Config2__ProductId__c);
                        componentsProductIds.add(p.Apttus_Config2__ProductOptionId__c);
                    }
                }
                if(componentsProductIds.size()>0){
                    boolean isSuccess = removeOptions(cartId, linenumber, componentsProductIds);
                    if(isSuccess){
                        applyConstraintRulesOnDelete(cartId, deleteProductIds);
                    }
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));           
        }
    }
    
    /*
     * Method name  : getProductOptionComponent
     * Description  : This method gets the Product Option Component object for the specified Option Group Name and Option Component Name
     * Return Type  : Apttus_CPQApi.CPQ.ProductOptionComponentDO - The Product Option Component object
     * Parameter    : string - Product Option Grou Name, string - Product Option Component Name
     */
/* 
 Name: getProductOptionComponent
 Description: 
 */ 
    public Apttus_CPQApi.CPQ.ProductOptionComponentDO getProductOptionComponent(string productOptionGroupName, string productOptionComponentName, List<Apttus_CPQApi.CPQ.ProductOptionGroupDO> productOptionList){
        Apttus_CPQApi.CPQ.ProductOptionComponentDO retComponent;
        try{
        for(Apttus_CPQApi.CPQ.ProductOptionGroupDO currentPO : productOptionList){
            if(currentPO.Name == productOptionGroupName){
                if(currentPO.HasOptionComponents){
                    for(Apttus_CPQApi.CPQ.ProductOptionComponentDO currentOC : currentPO.OptionComponents){
                        if(currentOC.Name == productOptionComponentName){
                            retComponent = currentOC;
                        }
                    }
                }
            }
        }
        
        return retComponent;
    } catch(Exception ex){
        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        
        return null;
    }
    }

  /*
     * Method name  : updateLineItemWithSiteAndAttributeUsingCartId
     * Description  : This method gets the Product Option Component object for the specified Option Group Name and Option Component Name
     * Return Type  : Apttus_CPQApi.CPQ.ProductOptionComponentDO - The Product Option Component object
     * Parameter    : string - Product Option Grou Name, string - Product Option Component Name
     */
/* 
 Name: updateLineItemWithSiteAndAttributeUsingCartId
 Description: 
 */ 
    public void updateLineItemWithSiteAndAttributeUsingCartId(Map<string,string> siteLinenumberMap, Map<string,string> siteProdAttrMap, String cartId){
        List<Apttus_Config2__ProductConfiguration__c> propsalLineList = new List<Apttus_Config2__ProductConfiguration__c>();
        List<Apttus_Config2__LineItem__c> updatePropsalList = new List<Apttus_Config2__LineItem__c>();
        String siteProdKey = null;
        try{
            if(cartId != null){
                propsalLineList = [Select a.Id, a.Apttus_QPConfig__Proposald__c, (Select Id, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c  From Apttus_Config2__LineItems__r) From Apttus_Config2__ProductConfiguration__c a where Id = :cartId];
                if(propsalLineList.size()>0){
                    for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                        if(!String.isempty(siteLinenumberMap.get(String.valueOf(p.Apttus_Config2__LineNumber__c)))){
                            p.AT_T_Customer_Site__c = siteLinenumberMap.get(String.valueOf(p.Apttus_Config2__LineNumber__c));
                            siteProdKey = SpecialCharacterConstant.CONCAT+p.AT_T_Customer_Site__c+p.Apttus_Config2__OptionId__c;
                            if(!String.isempty(siteProdAttrMap.get(siteProdKey))){
                              p.Apttus_Config2__AttributeValueId__c = siteProdAttrMap.get(siteProdKey);
                            }
                            updatePropsalList.add(p);
                        }
                    }
                    update updatePropsalList;
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }   
    
    /*
     * Method name  : removeMultiBundles
     * Description  : This method gets the card Id and line number to remove it from product configurations
     * Return Type  : void
     * Parameter    : string - Cart Id, List - linenumbers
     */
/* 
 Name: removeMultiBundles
 Description: 
 */ 
    public void removeMultiBundles(String cartId, List<Decimal> linenumbers){
        Apttus_CPQApi.CPQ.RemoveMultiBundlesRequestDO request;
        Apttus_CPQApi.CPQ.RemoveMultiBundlesResponseDO response;
        try{
            request = new Apttus_CPQApi.CPQ.RemoveMultiBundlesRequestDO();
            request.CartId = cartId;
            request.LineNumbers = linenumbers;
            response = Apttus_CPQApi.CPQWebService.removeMultiBundles(request);
            
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*
     * Method name  : removeBundle
     * Description  : This method gets the card Id and line number to remove it from product configurations
     * Return Type  : void
     * Parameter    : string - Cart Id, List - linenumbers
     */
/* 
 Name: removeBundle
 Description: 
 */ 
    public void removeBundle(String cartId, Decimal linenumber){
        Apttus_CPQApi.CPQ.RemoveBundleRequestDO request;
        Apttus_CPQApi.CPQ.RemoveBundleResponseDO response; 
        try{
            request = new Apttus_CPQApi.CPQ.RemoveBundleRequestDO();
            request.CartId = cartId;
            request.linenumber = linenumber;
            response = Apttus_CPQApi.CPQWebService.removeBundle(request);
            
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    



    /*
     * Method name  : removeAppliedRule
     * Description  : This method gets the card Id  remove it from product applied rule
     * Return Type  : void
     * Parameter    : string - Cart Id, List - linenumbers
     */
/* 
 Name: removeAppliedRule
 Description: 
 */ 
    public void removeAppliedRule(String cartId){
        try{
            List<Apttus_Config2__AppliedRuleInfo__c> lst = [Select Id from Apttus_Config2__AppliedRuleInfo__c where Apttus_Config2__ConfigurationId__c =: cartId limit 200];
            if(!lst.isempty()){
                delete lst;
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /* 
        Name: updateAVRecordsOnApply    
        Description: 
    */
    
    public void updateAVRecordsOnApply(Apttus_Config2__ProductAttributeValue__c listAttrVal, String JSONResponse, Boolean isAvpn, Boolean isMIS){
        String accessType;
        String regExp = UtilityConstant.QUOT_x;
        List<String> lecNameLst = new List<String>();
        try{
            List<AddrValidServAvailResponseBean.AddressServiceAvailability>addressServiceAvailabilityList = new  List<AddrValidServAvailResponseBean.AddressServiceAvailability>();
            if(String.isNotBlank(JSONResponse)){
                if(isAvpn){
                    accessType=listAttrVal.Access_Type_AVPN__c;
                }else if (isMIS){
                    accessType=listAttrVal.Access_Type__c;
                }
                JSONResponse = JSONResponse.replaceAll(regExp,'"');
                AddrValidServAvailResponseBean responseBean = new AddrValidServAvailResponseBean();
                ResponseBean = (AddrValidServAvailResponseBean)JSON.Deserialize(JSONResponse,AddrValidServAvailResponseBean.class);            
                AddressServiceAvailabilityList = ResponseBean.AddressServiceAvailability;                
                AddrValidServAvailResponseBean.ServiceAvailabilityDetails serviceAvailabilityDetailsObj = new AddrValidServAvailResponseBean.ServiceAvailabilityDetails(); 
                
                if(AddressServiceAvailabilityList!=null && AddressServiceAvailabilityList.size()>0){
                    for(AddrValidServAvailResponseBean.AddressServiceAvailability response: AddressServiceAvailabilityList){              
                        if(response.region==UtilityConstant.Y){
                            listAttrVal.VASA_Region__c = UtilityConstant.INREGION;
                            listAttrVal.Apttus_Config2__Vendor__c=UtilityConstant.ATT;
                        }else if (response.region ==UtilityConstant.N || response.region == UtilityConstant.O){
                            if(accessType==UtilityConstant.PRIVATELINE ){
                                if(response.lecName.equalsIgnoreCase(UtilityConstant.VERIZON) || response.lecName.equalsIgnoreCase(UtilityConstant.CINCINNATIBELL) || response.lecName.equalsIgnoreCase(UtilityConstant.CENTURYLINK) || response.lecName.equalsIgnoreCase(UtilityConstant.QWEST)){
                                    listAttrVal.VASA_Region__c = ATT_Constant.OUT_REGIONLine_1;                                
                                }else{
                                    listAttrVal.VASA_Region__c= ATT_Constant.OUT_REGIONLine_2;        
                                }
                            }else{
                                lecNameLst.add(response.lecName);
                            }
                        }
                        if(listAttrVal.Apttus_Config2__Vendor__c==null && response.lecName!=null){
                            listAttrVal.Apttus_Config2__Vendor__c=response.lecName.toUpperCase();
                        }
                      
                        AddrValidServAvailResponseBean.ServiceAvailabilityDetails avs = response.ServiceAvailabilityDetails;
                        system.debug('@@@ApttusServiceUtilityHelper - avs: '+avs);
                        if(avs != null){
                            if(avs.Ethernet != null && accessType!=UtilityConstant.PRIVATELINE){
                                system.debug('@@@ApttusServiceUtilityHelper - Ethernet: '+avs.Ethernet.mileage);
                                listAttrVal.mileage__c = String.isempty(avs.Ethernet.mileage) ? null : decimal.valueOf(avs.Ethernet.mileage);
                                break;
                            }else if( avs.PrivateLine != null && avs.PrivateLine.size()>0){
                                system.debug('@@@ApttusServiceUtilityHelper - Private Line: '+avs.PrivateLine[0].mileage);
                                listAttrVal.mileage__c = avs.PrivateLine[0].mileage == null ? null : decimal.valueOf(avs.PrivateLine[0].mileage);
                                break;
                            }
                        }
                    }
                    if(listAttrVal.Mileage__c == null && accessType == 'Private Line' && AddressServiceAvailabilityList[1].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[1].ServiceAvailabilityDetails.PrivateLine != null && AddressServiceAvailabilityList[1].ServiceAvailabilityDetails.PrivateLine.size() > 0 && AddressServiceAvailabilityList[1].ServiceAvailabilityDetails.PrivateLine[0].mileage != null){
                        listAttrVal.Mileage__c = Decimal.valueOf(AddressServiceAvailabilityList[1].ServiceAvailabilityDetails.PrivateLine[0].mileage);
                        system.debug('@@@listAttrVal.Mileage__c: '+listAttrVal.Mileage__c);
                    }
                }     
            } 
            
            // Region for Ethernet Block
            if(lecNameLst.size()>0){
                String region;
                String interfaceType;
                Decimal accessSpeed;
                String accessSubsVal;
                String accessSpeedVal;
                List<Provider_Grouping__c> pgList = [Select lecName__c, Interface_Type__c, Speed__c, VASA_Region__c from Provider_Grouping__c where lecName__c IN : lecNameLst];
                Decimal speed;
                if(listAttrVal.Access_Speed_MIS__c!=null){
                    accessSpeedVal=listAttrVal.Access_Speed_MIS__c;
                    accessSubsVal=accessSpeedVal.substring(accessSpeedVal.indexOf('(')+1,accessSpeedVal.indexOf('Mbps'));
                    accessSubsVal= accessSubsVal.indexOf('.') < 0 ? accessSubsVal: accessSubsVal.replaceAll('0*$', '').replaceAll('\\.$', '');
                    accessSpeed =Decimal.ValueOf(accessSubsVal.TRIM());
                }else if(listAttrVal.Access_Speed_AVPN__c!=null){
                     accessSpeedVal=listAttrVal.Access_Speed_AVPN__c;
                     accessSubsVal=accessSpeedVal.substring(accessSpeedVal.indexOf('(')+1,accessSpeedVal.indexOf('Mbps'));
                     accessSubsVal= accessSubsVal.indexOf('.') < 0 ? accessSubsVal: accessSubsVal.replaceAll('0*$', '').replaceAll('\\.$', '');
                     accessSpeed=Decimal.ValueOf(accessSubsVal.TRIM());
                }
                if(listAttrVal.Interface_Type__c!=null){
                    interfaceType=listAttrVal.Interface_Type__c;
                }else if(listAttrVal.Interface_Type_AVPN__c!=null){
                    interfaceType=listAttrVal.Interface_Type_AVPN__c;
                }
                if(interfaceType != null){
                    for(Provider_Grouping__c pg:pgList){
                        speed = String.isempty(pg.Speed__c)? 0 : Decimal.valueof(pg.Speed__c);
                        if(listAttrVal.Apttus_Config2__Vendor__c==pg.lecName__c && accessSpeed == speed && interfaceType != null && interfaceType.contains(pg.Interface_Type__c)){
                            if(pg.VASA_Region__c == ATT_Constant.OUT_REGION_1){
                                listAttrVal.VASA_Region__c = ATT_Constant.OUT_REGIONLine_1;
                                region=listAttrVal.VASA_Region__c;
                            }
                            if(pg.VASA_Region__c == ATT_Constant.OUT_REGION_1A){
                                 listAttrVal.VASA_Region__c  = ATT_Constant.OUT_REGIONLine_1A;
                                 region=listAttrVal.VASA_Region__c;
                            }
                            if(pg.VASA_Region__c == ATT_Constant.OUT_REGION_2){
                                 listAttrVal.VASA_Region__c  = ATT_Constant.OUT_REGIONLine_2;
                                 region=listAttrVal.VASA_Region__c;
                            }
                        }
                    }
                    if(String.isempty(region)){
                        listAttrVal.VASA_Region__c = 'No Match['+listAttrVal.Apttus_Config2__Vendor__c+'-'+accessSpeed+'-'+interfaceType+']';
                    }   
                }
            }
            Map<String,String> avrecordMap= new  Map<String,String>();
            avrecordMap= createMapfromAVRecord(listAttrVal);
            system.debug('avrecordMap--->'+avrecordMap);
            
            ProductCatalogIntegrationHandler catalogObj= new ProductCatalogIntegrationHandler();
            Map<String,String> CatalogIdMap=  new Map<String,String>();
            CatalogIdMap=catalogObj.getCatalogIdFromData(avrecordMap);
            system.debug('CatalogIdMap--->'+CatalogIdMap);
            
            listAttrVal.Access_Catalog_Id__c=CatalogIdMap.get('Access_Catalog_Id__c');
            listAttrVal.COS_catalog_Id__c=CatalogIdMap.get('COS_catalog_Id__c');
            listAttrVal.DNS_catalog_Id__c=CatalogIdMap.get('DNS_catalog_Id__c');
            listAttrVal.Hi_cap_Flex_catalog_Id__c=CatalogIdMap.get('Hi_cap_Flex_catalog_Id__c');
            listAttrVal.Installation_Catalog_Id__c=CatalogIdMap.get('Installation_Catalog_Id__c');
            listAttrVal.IPFlex_catalog_Id__c=CatalogIdMap.get('IPFlex_catalog_Id__c');
            listAttrVal.Port_Catalog_Id__c=CatalogIdMap.get('Port_Catalog_Id__c');
            
            
            list<Apttus_Config2__ProductAttributeValue__c> prodAttr = new list<Apttus_Config2__ProductAttributeValue__c>();
            prodAttr =[select id,Port_Speed_AVPN__c,Port_Speed_MIS__c,QuoteId__c,Apttus_Config2__LineItemId__r.Apttus_Config2__PriceListItemId__c from Apttus_Config2__ProductAttributeValue__c where id=:listAttrVal.Id];
            system.debug('@@@@@@@@prodAttr '+prodAttr);

            list<Apttus_Config2__PriceMatrixEntry__c> matrixEntryList = new list<Apttus_Config2__PriceMatrixEntry__c>();

            matrixEntryList=[select Id,BEID__c,Apttus_Config2__Dimension1Value__c from Apttus_Config2__PriceMatrixEntry__c where Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Id =: prodAttr[0].Apttus_Config2__LineItemId__r.Apttus_Config2__PriceListItemId__c];
            system.debug('@@@@@@@@matrixEntryList'+matrixEntryList);
            
            for(Apttus_Config2__PriceMatrixEntry__c prodAttri:matrixEntryList){
            if(isAvpn && listAttrVal.Port_Speed_AVPN__c == prodAttri.Apttus_Config2__Dimension1Value__c){
                    listAttrVal.Port_BEID__c=matrixEntryList[0].BEID__c ;
                }else if (isMIS){
                    listAttrVal.Port_BEID__c=matrixEntryList[0].BEID__c ;
                }
                }
        }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }
    
    public void updateAVRecordsOnApplyASE(Apttus_Config2__ProductAttributeValue__c listAttrVal, String tierValue, String lataNumber, Apttus_Proposal__Proposal__c proposalValue){
        String cNumType;
        String accountId;
        list <ASE_Wholesale_Contract_Number__c> contractList = new list <ASE_Wholesale_Contract_Number__c>();
        User userObj;
        userObj = [select id, Begin_Quote__c,Contact.Account.IPFlex_Product__c,Contact.Account.ManagedRouter__c,Contact.Account.Id from User where id = :UserInfo.getUserId()];
        accountId = userObj.Contact.Account.Id;
        
        Apttus_Config2__LineItem__c lineItem = new Apttus_Config2__LineItem__c();
        Apttus_Config2__ProductAttributeValue__c prodAttr = new Apttus_Config2__ProductAttributeValue__c();
        
        system.debug('@@@listAttrVal.Contract_Number__c'+listAttrVal.Contract_Number__c);
        system.debug('@@@accountId'+accountId);

        try{
            if(!String.isblank(listAttrVal.Contract_Number__c)){
                contractList = [Select id,name,Short_Description__c,Rate_Card_Type__c,Rate_Card__c,Tier_1_Suffix__c,Tier_2_Suffix__c,Tier_3_Suffix__c,PPCoS_Suffix__c,Broadband_Suffix__c from ASE_Wholesale_Contract_Number__c where Name_Description__c =: listAttrVal.Contract_Number__c and Active__c = true and Account_Name__c =: accountId];
                if(contractList.size()>0){
                    cNumType = contractList[0].Rate_Card_Type__c;   
                    listAttrVal.CNUM_Rate_Card__c = contractList[0].Rate_Card__c;
                    listAttrVal.Tier_1_Suffix__c = contractList[0].Tier_1_Suffix__c;
                    listAttrVal.Tier_2_Suffix__c = contractList[0].Tier_2_Suffix__c;
                    listAttrVal.Tier_3_Suffix__c = contractList[0].Tier_3_Suffix__c;
                    listAttrVal.PPCoS_Suffix__c = contractList[0].PPCoS_Suffix__c;
                    listAttrVal.Broadband_Suffix__c = contractList[0].Broadband_Suffix__c;
                } 
                system.debug('@@@cNumType '+cNumType);             
                if(cNumType == 'Promotion'){
                    listAttrVal.IsPromotional__c = true ;
                    system.debug('@@@inside true');
                }
                else{
                    listAttrVal.IsPromotional__c = false;
                    system.debug('@@@inside true');
                }
            }
            
            if(listAttrVal.Config_TypeASE__c == 'Point To Point' || listAttrVal.Config_TypeASE__c == 'Multi Point'){
                listAttrVal.Site_DesignationASE__c = '';     
            }
            if(listAttrVal.Tier__c==null || listAttrVal.Tier__c==''){
                listAttrVal.Tier__c = tierValue;
            }
            if(lataNumber != null && lataNumber != ''){
                listAttrVal.LATA_Number__c = lataNumber;
            }
            listAttrVal.Term__c = proposalValue.Apttus_Proposal__Payment_Term__c;  
        }
        catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));  
        }
    }    
    
    public void updateAVRecordsOnApplyASEMACD(Apttus_Config2__ProductAttributeValue__c listAttrVal, String tierValue, String lataNumber, Apttus_Proposal__Proposal__c proposalValue){
        system.debug('@@@@inside updateAVRecordsOnApplyASEMACD');
        String cNumType;
        String accountId;
        list <ASE_Wholesale_Contract_Number__c> contractList = new list <ASE_Wholesale_Contract_Number__c>();
        list<AT_T_Customer_Site_Quote__c> siteQuoteJunctionList = new list<AT_T_Customer_Site_Quote__c>();
        list<Opportunity> opptyList = new list<Opportunity>();
        User userObj;
        userObj = [select id, Begin_Quote__c,Contact.Account.IPFlex_Product__c,Contact.Account.ManagedRouter__c,Contact.Account.Id from User where id = :UserInfo.getUserId()];
        accountId = userObj.Contact.Account.Id;
        
        Apttus_Config2__LineItem__c lineItem = new Apttus_Config2__LineItem__c();
        Apttus_Config2__ProductAttributeValue__c prodAttr = new Apttus_Config2__ProductAttributeValue__c();
        list<Apttus_Config2__ProductAttributeValue__c> attributeValueList = new list<Apttus_Config2__ProductAttributeValue__c>();
        
        try{     
            if(proposalValue.Apttus_Proposal__Opportunity__c != null){   
                opptyList = [select id, ASE_MACD_Deal__c from Opportunity where id =: proposalValue.Apttus_Proposal__Opportunity__c];
                if(opptyList != null && opptyList.size() > 0){
                    opptyList[0].ASE_MACD_Deal__c = true;
                    update opptyList;
                }
            }
                        
            if(!String.isblank(listAttrVal.Contract_Number__c)){
                contractList = [Select id,name,Short_Description__c,Rate_Card_Type__c,Rate_Card__c,Tier_1_Suffix__c,Tier_2_Suffix__c,Tier_3_Suffix__c,PPCoS_Suffix__c,Broadband_Suffix__c from ASE_Wholesale_Contract_Number__c where Name_Description__c =: listAttrVal.Contract_Number__c and Active__c = true and Account_Name__c =: accountId];
                if(contractList.size()>0){
                    cNumType = contractList[0].Rate_Card_Type__c;   
                    listAttrVal.CNUM_Rate_Card__c = contractList[0].Rate_Card__c;
                    listAttrVal.Tier_1_Suffix__c = contractList[0].Tier_1_Suffix__c;
                    listAttrVal.Tier_2_Suffix__c = contractList[0].Tier_2_Suffix__c;
                    listAttrVal.Tier_3_Suffix__c = contractList[0].Tier_3_Suffix__c;
                    listAttrVal.PPCoS_Suffix__c = contractList[0].PPCoS_Suffix__c;
                    listAttrVal.Broadband_Suffix__c = contractList[0].Broadband_Suffix__c;
                }              
                if(cNumType == 'Promotion'){
                    listAttrVal.IsPromotional__c = true ;
                }
                else{
                    listAttrVal.IsPromotional__c = false;
                }
            }
            
            if(listAttrVal.Config_TypeASE__c == 'Point To Point' || listAttrVal.Config_TypeASE__c == 'Multi Point'){
                listAttrVal.Site_DesignationASE__c = '';     
            }
            if(listAttrVal.Tier__c==null || listAttrVal.Tier__c==''){
                listAttrVal.Tier__c = tierValue;
            }
            if(lataNumber != null && lataNumber != ''){
                listAttrVal.LATA_Number__c = lataNumber;
            }
            listAttrVal.Term__c = proposalValue.Apttus_Proposal__Payment_Term__c;
            
            prodAttr = [Select AT_T_Customer_Site__c,QuoteId__c,Block_MACD_Updates__c,Basic100MbpsASENCCode__c,Basic10GbpsASENCCode__c,Broadband1GbpsASENCCode__c,Basic1GbpsASENCCode__c,Old_Committed_Information_Rate_Price__c,InterfaceTypeASE__c,CIR__c,Class_of_ServiceASE__c,MAC_AddressesASE__c,ASE_SPEC_CodeFinal__c,Old_Interface_Type__c,Old_Committed_Information_Rate__c,Old_Class_of_Service__c,Old_MAC_Addresses__c from Apttus_Config2__ProductAttributeValue__c where id=:listAttrVal.id]; 
            lineItem = [Select Apttus_Config2__NetPrice__c from Apttus_Config2__LineItem__c where Product_Code__c = 'ASE' and Apttus_Config2__ChargeType__c = 'CoS Fee' and Apttus_Config2__AttributeValueId__c =:listAttrVal.id limit 1];
            
            system.debug('lineItem@@@'+lineItem);
            system.debug('prodAttr@@@'+prodAttr);            
            
            if(prodAttr.AT_T_Customer_Site__c != null && prodAttr.QuoteId__c != null){
                Id customerSiteId = Id.valueOf(prodAttr.AT_T_Customer_Site__c);
                Id quoteId = Id.valueOf(prodAttr.QuoteId__c);
                siteQuoteJunctionList = [select id, ASE_MACD_Site_Status__c, Project_ID__c from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c =:customerSiteId and AT_T_Quote__c =: quoteId];
                system.debug('@@@@before: siteQuoteJunctionList '+siteQuoteJunctionList );
                if((prodAttr.Block_MACD_Updates__c == false && (listAttrVal.InterfaceTypeASE__c != prodAttr.InterfaceTypeASE__c || listAttrVal.CIR__c != prodAttr.CIR__c || listAttrVal.Class_of_ServiceASE__c != prodAttr.Class_of_ServiceASE__c || listAttrVal.MAC_AddressesASE__c != prodAttr.MAC_AddressesASE__c )) ||
                   (prodAttr.Block_MACD_Updates__c == true && (listAttrVal.InterfaceTypeASE__c != prodAttr.Old_Interface_Type__c || listAttrVal.CIR__c != prodAttr.Old_Committed_Information_Rate__c || listAttrVal.Class_of_ServiceASE__c != prodAttr.Old_Class_of_Service__c || listAttrVal.MAC_AddressesASE__c != prodAttr.Old_MAC_Addresses__c)))
                {
                    siteQuoteJunctionList[0].ASE_MACD_Site_Status__c = 'Active-Modified';
                    listAttrVal.ASR_Status__c = 'Active-Modified';
                }    
                else{
                    siteQuoteJunctionList[0].ASE_MACD_Site_Status__c = 'Active';
                    listAttrVal.ASR_Status__c = 'Active';
                }            
                if(siteQuoteJunctionList != null && siteQuoteJunctionList.size() > 0){
                    update siteQuoteJunctionList;
                }
                system.debug('@@@@after: siteQuoteJunctionList '+siteQuoteJunctionList);
                
                if(siteQuoteJunctionList[0].Project_ID__c != null){
                    listAttrVal.Project_ID__c = siteQuoteJunctionList[0].Project_ID__c;
                }
            }
            
            if(prodAttr != null && prodAttr.Block_MACD_Updates__c == false){      
            
                if(prodAttr.Class_of_ServiceASE__c != null){
                    listAttrVal.Old_Class_of_Service__c = prodAttr.Class_of_ServiceASE__c;
                }
                if(prodAttr.CIR__c != null){
                    listAttrVal.Old_Committed_Information_Rate__c = prodAttr.CIR__c;
                }                
                if(prodAttr.Basic100MbpsASENCCode__c != null){
                    listAttrVal.Old_NC_Code__c = prodAttr.Basic100MbpsASENCCode__c;
                }
                if(prodAttr.Basic10GbpsASENCCode__c != null){
                    listAttrVal.Old_NC_Code__c = prodAttr.Basic10GbpsASENCCode__c;
                }
                if(prodAttr.Broadband1GbpsASENCCode__c != null){
                    listAttrVal.Old_NC_Code__c = prodAttr.Broadband1GbpsASENCCode__c;
                }
                if(prodAttr.Basic1GbpsASENCCode__c != null){
                    listAttrVal.Old_NC_Code__c = prodAttr.Basic1GbpsASENCCode__c;
                }
                if(prodAttr.InterfaceTypeASE__c != null){
                    listAttrVal.Old_Interface_Type__c = prodAttr.InterfaceTypeASE__c;
                }
                if(prodAttr.MAC_AddressesASE__c != null){
                    listAttrVal.Old_MAC_Addresses__c = prodAttr.MAC_AddressesASE__c;
                }
                if(prodAttr.ASE_SPEC_CodeFinal__c != null){
                    listAttrVal.Old_SPEC_Code__c = prodAttr.ASE_SPEC_CodeFinal__c;
                }                
                if(lineItem != null && lineItem.Apttus_Config2__NetPrice__c != null){
                    listAttrVal.Old_Committed_Information_Rate_Price__c = lineItem.Apttus_Config2__NetPrice__c;
                }
                listAttrVal.Block_MACD_Updates__c = true;
            }            
        }
        catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));  
        }
    }

    /*Method to fetch the auto countersign decision*/
    public Boolean fetchAutoSignDecision(String quoteId){
        Boolean autoSignFlag = false;
        try{
            if(quoteId != null){
                Apttus_Proposal__Proposal__c quoteObj = [Select Id, Apttus_Proposal__Opportunity__r.Calculated_Discount_Percentage__c,Apttus_Proposal__Opportunity__r.Discounted_Price__c From Apttus_Proposal__Proposal__c Where id=:quoteId LIMIT 1];
                List<Automatic_Countersign__c> autoList = [Select Field_Name__c, Operator__c, Value__c from Automatic_Countersign__c LIMIT 2];
                if(quoteObj != null && autoList != null && autoList.size()>0) {
                    Decimal adminMRC = 0.00;
                    Decimal adminDiscount = 0.00;
                    Decimal opptyMRC = 0.00;
                    Decimal opptyDiscount = 0.00;
                    String mrcOprt = '';
                    String discOprt = '';
                    Boolean mrcCondition = false;
                    Boolean disCondition  = false;
                    //assigning discount and MRC price from Opportunity
                    if(quoteObj.Apttus_Proposal__Opportunity__r.Calculated_Discount_Percentage__c != null){
                        opptyDiscount = quoteObj.Apttus_Proposal__Opportunity__r.Calculated_Discount_Percentage__c;
                    }
                    if(quoteObj.Apttus_Proposal__Opportunity__r.Discounted_Price__c != null){
                        opptyMRC = quoteObj.Apttus_Proposal__Opportunity__r.Discounted_Price__c;
                    }
                    for(Automatic_Countersign__c autoObj : autoList){
                        if(autoObj.Field_Name__c.contains('Net Discount')){
                            adminDiscount = autoObj.Value__c;
                            discOprt = autoObj.Operator__c;
                        }else if(autoObj.Field_Name__c.contains('Total MRC')){
                            adminMRC = autoObj.Value__c;
                            mrcOprt = autoObj.Operator__c;
                        }
                    }
                           
                    if(mrcOprt.equals('>')){
                        mrcCondition  = opptyMRC > adminMRC;
                    }else if(mrcOprt.equals('<')){
                        mrcCondition  = opptyMRC < adminMRC;
                    }else if(mrcOprt.equals('=')){
                        mrcCondition  = opptyMRC == adminMRC;
                    }
                    
                    if(discOprt.equals('>')){
                        disCondition  = opptyDiscount > adminDiscount;
                    }else if(discOprt.equals('<')){
                        disCondition  = opptyDiscount < adminDiscount;
                    }else if(discOprt.equals('=')){
                        disCondition  = opptyDiscount == adminDiscount;
                    }
                    
                    autoSignFlag = mrcCondition && disCondition;
                }
            }
        }catch(Exception e){
            system.debug('Exception Caught inside fetchAutoSignDecision method of ApttusServiceUtilityHelper Class, at line : '+e.getLineNumber());
        }
        return autoSignFlag;
    }
    
    /*Apttus call to create line item for each site*/
    public List<Decimal> createLineItemPerSite(String productId, String cartId){    
        Apttus_CPQApi.CPQ.AddMultiProductRequestDO request = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO();            
        Apttus_CPQApi.CPQ.SelectedProductDO prod = new Apttus_CPQApi.CPQ.SelectedProductDO();
        prod.ProductId = productId;
        prod.Quantity = prod.SellingTerm = 1;
        prod.StartDate = system.today();
        prod.EndDate = system.today()+2;
        request.CartId = cartId;
        request.SelectedProducts.add(prod);
        Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(request);
        list<Decimal> lineNumberList = response.LineNumbers;
        return lineNumberList;
    }  
    
    /*Create Contract Renewal Opportunity and related pricing components with applicable discounts*/
    public void createContractRenewalDeal(Id quoteId){
        
        Apttus_Proposal__Proposal__c quoteObj = new Apttus_Proposal__Proposal__c(); 
        list<Rate_PHI__c> ratePHIList = new list<Rate_PHI__c>();
        Deal_Hash__c dealHash = new Deal_Hash__c();
        Decimal rdsCurrentVersion;
        Id masterOpptyId;
        ID accountId;
        
        if(quoteId != null){
            quoteObj = [select Id,Name,MasterOpportunity__c,Term__c,Rate_Card_Effective_Date__c, End_Customer__c,Docusign_Envelope__c, End_Customer__r.Name,End_Customer__r.Mailing_Street_Address__c,End_Customer__r.City__c,Apttus_Proposal__Opportunity__c,Owner.Name,Apttus_Proposal__ExpectedEndDate__c,Product__r.productcode,Contract_Renewal_Deal_Hash__c,
                        End_Customer__r.Zip__c,End_Customer__r.State__c, Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Payment_Term__c,Apttus_Proposal__Approval_Stage__c,ProdCode__c,MACDMasterTier__c,Ethernet_Configuration__c,Traffic_Jurisdiction__c, Product__r.name, MACD_Change_Type__c FROM Apttus_Proposal__Proposal__c where id = :quoteId];
            Integer term = Integer.valueof(quoteObj.Term__c); 
            ratePHIList = [select Id,RecordType.Name,Rate_Plan_ID__c,Discount_Id__c,Tier__c,Term__c,Service_Type__c,Version__c,Effective_Date__c from Rate_PHI__c WHERE Tier__c =:quoteObj.MACDMasterTier__c and Term__c =:term and RecordType.Name =: ATTConstants.RECORD_TYPE_MC and Service_Type__c =:quoteObj.ProdCode__c];            
            dealHash = [Select RenewedQuote__c,RDS_Version__c from Deal_Hash__c where Id =:quoteObj.Contract_Renewal_Deal_Hash__c LIMIT 1];
            Admin_Control__c adminControl = [select Id,AVPN_CAP_P29__c,MIS_CAP_P29__c from Admin_Control__c limit 1 ]; 
            
            //Opportunity creation
            Opportunity oppObj; 
            User usr = [Select Id,Name,Is_Approver__c,ContactId,Email FROM User WHERE id =: userinfo.getuserId()];
            Contact con = new Contact();            
            if(usr.ContactId != null){
                con = [SELECT Id, Name, AccountId,Account.Name FROM Contact WHERE Id=:usr.ContactId];
                accountId = con.AccountId;
            }
            else{
                ATTDefaultAccount__c accName = ATTDefaultAccount__c.getValues(BuyflowConstant.ACCOUNTNAME);
                list<Account> accountList = new list<Account>();
                accountList = [SELECT Id FROM Account WHERE name=:accName.Account_Name__c limit 1];
                if(accountList.size() > 0){
                  accountId = accountList[0].id;
                }
            }
            
            List<Account> accList = [select id,ownerid from account where id =:accountId];  
            if(quoteObj.Apttus_Proposal__Opportunity__c != null){
                oppObj = new Opportunity(id = quoteObj.Apttus_Proposal__Opportunity__c);
            }
            else{
                oppObj = new Opportunity();            
            }
            if(accList != null && accList.size()>0){
                oppObj.accountid = accList[0].id;
                oppObj.ownerId = accList[0].ownerId; 
            }
            
            //Assiging Opportunity data
            if(quoteObj.Apttus_Proposal__Proposal_Name__c == null || quoteObj.Apttus_Proposal__Proposal_Name__c == SpecialCharacterConstant.CONCAT){
                oppObj.name = quoteObj.name;
            }else{
                oppObj.name = quoteObj.Apttus_Proposal__Proposal_Name__c;  
            } 
            if(quoteObj.Apttus_Proposal__Approval_Stage__c != BuyflowConstant.DELETED){
                oppObj.StageName = SIConstants.OPTY_DEAL_Auto_Approved;
                oppObj.LikelihoodtoClose__c = 'Approved (20%)';
            }
            
            oppObj.CloseDate = System.today().addMonths(6);
            rdsCurrentVersion = dealHash.RDS_Version__c;
            if(rdsCurrentVersion != null){
                oppObj.RDS_Version__c = rdsCurrentVersion + 1;
            }
            oppObj.Rate_Stability_Date__c =system.now();
            oppObj.RDS_Deal_Hash__c = dealHash.Id;
            oppObj.MACD_Type__c = BuyflowConstant.C;
            oppObj.Accountid = accList[0].id; 
            oppObj.End_Customer__c = quoteObj.End_Customer__c;
            
            String strTempQuoteName = quoteObj.Name;
            oppObj.BID_ID__c = strTempQuoteName.substringBefore(SpecialCharacterConstant.HYPHEN) + strTempQuoteName.substringAfter(SpecialCharacterConstant.HYPHEN);
            oppObj.Initial_BID_Deal_Owner__c = quoteObj.Owner.Id;
            oppObj.Current_BID_Deal_Owner__c  = quoteObj.Owner.Id;
            oppObj.Quote_Expiration_Date__c = quoteObj.Apttus_Proposal__ExpectedEndDate__c;
            oppObj.Rate_Card_Effective_Date__c = quoteObj.Rate_Card_Effective_Date__c;
            oppObj.Quote_ID__c = quoteObj.Name; 
            oppObj.Deal_Reg_Approved__c = false;     
            oppObj.MACD_Opportunity__c = true;
            oppObj.NTWK_CI_Complete__c = false;
            oppObj.Isdocviewer__c = true; 
            oppObj.Renewal_Contract__c =true;
            
            //Updating Rate Plan Id for the Opportunity from Rate PHI record
            system.debug('@@@Rate PHI List: '+ratePHIList);
            if(ratePHIList != null && ratePHIList.size() > 0){
                for(Rate_PHI__c rp : ratePHIList){    
                    if(quoteObj.MACDMasterTier__c == rp.Tier__c && rp.Rate_Plan_ID__c != NULL && quoteObj.ProdCode__c== rp.Service_Type__c && rp.RecordType.Name == SIConstants.masterratecard){
                        oppObj.Rate_Plan_ID__c = rp.Rate_Plan_ID__c;
                    }
                }
            } 
            
            //Updating Discount Percentage from Master Opportunity        
            if(quoteObj.MasterOpportunity__c != null){
                masterOpptyId = quoteObj.MasterOpportunity__c;
                Opportunity masterOppty = [select id,Rate_Stability_Date__c,Standard_Discount_Percentage__c,Custom_Deal_Reg_Percentage__c from Opportunity where id=:masterOpptyId]; 
                if(masterOppty.Standard_Discount_Percentage__c !=null){
                    oppObj.Standard_Discount_Percentage__c = masterOppty.Standard_Discount_Percentage__c;
                }
                if(masterOppty.Custom_Deal_Reg_Percentage__c !=null){
                    oppObj.Custom_Deal_Reg_Percentage__c = masterOppty.Custom_Deal_Reg_Percentage__c ;
                }
            }            
            
            oppObj.Contract_Flow__c = 'API';
            oppObj.API_Flag__c = true;
            oppObj.Service_type__c = quoteObj.Product__r.productcode;
            oppObj.IPFlex_Deal__c = SpecialCharacterConstant.FALSE_LITERAL;          
            upsert oppObj;  

            //Updating Quote record
            Apttus_Proposal__Proposal__c proposalObj = new Apttus_Proposal__Proposal__c(id=quoteObj.id);
            proposalObj.Apttus_Proposal__Opportunity__c = oppObj.id;            
            if(proposalObj.Apttus_Proposal__Approval_Stage__c!=BuyflowConstant.DELETED){
                proposalObj.Apttus_Proposal__Approval_Stage__c = ATT_Constant.DEAL_REG_APPROVED;                
            }
            proposalObj.QuoteExpirationDate__c = System.today().addMonths(6);
            update proposalObj;
            dealHash.RenewedQuote__c = quoteId;
            update dealHash;
            
            //Calling batch to create pricing components and apply discounts
            Set<Id> quoteIds = new Set<Id>();
            quoteIds.add(quoteObj.id);                
            List<Id> qtIds = New List<Id>();
            qtIds.addAll(quoteIds);
            if(!test.isRunningTest())
              Id batchProcessId = database.executeBatch(new DealRegistrationBatchProcessUpgrade(qtIds,oppObj.Id),1);
        }
    } 
    
    /*Method to clear the Contract Renewal Stage on Deal Hash and update CR Approved flag to true*/
    public void clearContractRenewalStage(Id quoteId){   
        list<Deal_Hash__c> dealHashList = new list<Deal_Hash__c>();
        dealHashList = [SELECT Id, RenewedQuote__c from Deal_Hash__c where RenewedQuote__c =:quoteId LIMIT 1];
        if(dealHashList != null && dealHashList.size() > 0){    
            dealHashList[0].Contract_Renewal_Stage__c = null;
        }
        update dealHashList;
        list<Apttus_Proposal__Proposal__c> proposalList = new list<Apttus_Proposal__Proposal__c>();
        proposalList = [SELECT Id, CR_Approved__c,Renewal_Contract__c from Apttus_Proposal__Proposal__c where id =:quoteId and Renewal_Contract__c= true and CR_Approved__c = false LIMIT 1];
        if(proposalList.size()>0){
            proposalList[0].CR_Approved__c = true;
            update proposalList;
        }
    }   
    
    /*Method to clear the Contract Renewal Stage on Deal Hash*/
    public void clearContractRenewalFields(Id quoteId){   
        list<Deal_Hash__c> dealHashList = new list<Deal_Hash__c>();
        dealHashList = [SELECT Id, RenewedQuote__c,Contract_Renewal_Stage__c from Deal_Hash__c where RenewedQuote__c =:quoteId LIMIT 1];
        if(dealHashList != null && dealHashList.size() > 0){    
            dealHashList[0].RenewedQuote__c = dealHashList[0].Contract_Renewal_Stage__c = null;
        }
        update dealHashList;
    }  
    
    /*Method to cancel the Contract Renewal Request*/
    public PageReference cancelContractRequest(string subAcc, Id quoteId, string startPage){  
        system.debug('Inside Cancel Contract request');
        // Deal Hash
        PageReference retPageRef;
        Deal_Hash__c dealHash;
        Opportunity Opp;
        try{                       
            dealHash = [Select Contract_Renewal_Lock__c,isContractRenewalFlow__c,Contract_Renewal_LockedBy_UserId__c from Deal_Hash__c where  Sub_Account_Number__c =: subAcc limit 1];   
            // Unlock Contract Renewal
            if(dealHash!= null && dealHash.Contract_Renewal_Lock__c){
                dealHash.Contract_Renewal_Lock__c=false;
                dealHash.Contract_Renewal_LockedBy_UserId__c='';
            }
            // Contract Renewal Flow Uncheck
            if(dealHash.isContractRenewalFlow__c){
                dealHash.isContractRenewalFlow__c = false;
            }
            update dealHash;
            
            Apttus_Proposal__Proposal__c quoteToCancel = [Select Id,Apttus_Proposal__Approval_Stage__c,Apttus_Proposal__Opportunity__c,SubAccountNumber__c,Contract_Renewal_Deal_Hash__c FROM Apttus_Proposal__Proposal__c WHERE Id=:quoteId LIMIT 1];
                        
            if(quoteToCancel != null){
                quoteToCancel.Apttus_Proposal__Approval_Stage__c = Constant.QD_DELETED;
                quoteToCancel.SubAccountNumber__c = quoteToCancel.Contract_Renewal_Deal_Hash__c = null;                  
                update quoteToCancel;
                if(quoteToCancel.Apttus_Proposal__Opportunity__c != null){
                    opp = new Opportunity(id = quoteToCancel.Apttus_Proposal__Opportunity__c);
                    opp.StageName = SIConstants.OPTY_DEAL_REG_DELETED;
                    opp.RDS_Deal_Hash__c = null;
                    update opp;                                  
                }    
                clearContractRenewalFields(quoteToCancel.Id);
            }
            
            if((RenewConstant.NS).equalsIgnoreCase(startPage)){
                retPageRef = Page.Inventorylookup_SiteInventory;
                retPageRef.getParameters().put('id', subAcc);
            }else{
                retPageRef = Page.ManageExistingNetworkServiceInventry;
            }
        }catch(Exception e){            
            ATTException.logException(RenewConstant.EXCEPTION_MSG2 + e.getLineNumber(), ATTException.constructExceptionMessageString(e));
        }   
        system.debug('retPageRef'+retPageRef); 
        return retPageRef;      
    }  
    
    /* Method to unlock the deal*/
    public void unLockDeal(string subAcc){
        try{
            system.debug('Inside Unlock Deal');
            Deal_Hash__c dealHash;       
            dealHash = [Select Contract_Renewal_Lock__c,Contract_Renewal_LockedBy_UserId__c from Deal_Hash__c where Sub_Account_Number__c =: subAcc limit 1];
            if(dealHash!= null){
                if(dealHash.Contract_Renewal_Lock__c){
                    dealHash.Contract_Renewal_Lock__c = false;
                    dealHash.Contract_Renewal_LockedBy_UserId__c='';
                    update dealHash;
                    system.debug('contract lock false');
                }
            }    
        }
        catch(Exception e){
            system.debug('Exception Caught in UnlockDeal method of ApttusServiceUtilityHelper at line :'+e.getLineNumber());
        }
    } 
    
    public Map<String,String> createMapfromAVRecord(Apttus_Config2__ProductAttributeValue__c listAttrVal){
        
        Map<String,String> AVRecordMap= new Map<String,String>();
        AVRecordMap.put('Access_Speed_AVPN__c',listAttrVal.Access_Speed_AVPN__c);
        AVRecordMap.put('ProductName__c',listAttrVal.ProductName__c);
        AVRecordMap.put('Port_Speed_MIS__c',listAttrVal.Port_Speed_MIS__c);
        AVRecordMap.put('Port_Type_MIS__c',listAttrVal.Port_Type_MIS__c);
        AVRecordMap.put('Interface_Type__c',listAttrVal.Interface_Type__c);
        AVRecordMap.put('Managed_Router__c',string.valueOf(listAttrVal.Managed_Router__c));
        AVRecordMap.put('Port_Speed_AVPN__c',listAttrVal.Port_Speed_AVPN__c);
        AVRecordMap.put('Port_Type_AVPN__c',listAttrVal.Port_Type_AVPN__c);
        AVRecordMap.put('Interface_Type_AVPN__c',listAttrVal.Interface_Type_AVPN__c);
        AVRecordMap.put('Access_Type__c',listAttrVal.Access_Type__c);
        AVRecordMap.put('Access_Type_AVPN__c',listAttrVal.Access_Type_AVPN__c);
        AVRecordMap.put('Access_Speed_MIS__c',listAttrVal.Access_Speed_MIS__c);
        AVRecordMap.put('CoS__c',string.valueOf(listAttrVal.CoS__c));
        AVRecordMap.put('Install_Option_MIS__c',listAttrVal.Install_Option_MIS__c);
        AVRecordMap.put('Install_Option_AVPN__c',listAttrVal.Install_Option_AVPN__c);
        AVRecordMap.put('UBB_Speed_AVPN__c',listAttrVal.UBB_Speed_AVPN__c);
        AVRecordMap.put('UBB_Speed_MIS__c',listAttrVal.UBB_Speed_MIS__c);
        AVRecordMap.put('Hi_Cap_Flex__c',string.valueOf(listAttrVal.Hi_Cap_Flex__c));
        AVRecordMap.put('Additional_DNS__c',listAttrVal.Additional_DNS__c);
        AVRecordMap.put('AT_T_IP_Flexible_Reach__c',string.valueOf(listAttrVal.AT_T_IP_Flexible_Reach__c));
        AVRecordMap.put('IP_Flexible_Reach_Plan__c',string.valueOf(listAttrVal.IP_Flexible_Reach_Plan__c));
        
        return AVRecordMap;
        
        
    }
   }