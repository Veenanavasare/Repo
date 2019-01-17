/* 
 Name: MACD_DiscountPricingHelper
 Type: Class 
 Description: 
 */ 
public class MACD_DiscountPricingHelper {
    
    /* 
     Name: MACD_DiscountPricingHelper
     Description: 
     */ 
    public MACD_DiscountPricingHelper (){
        
    }
    
    /* 
     Name: getMasterDealPromotions
     Description: 
     */ 
    public list<Promotion_Engine_Junction__c> getMasterDealPromotions(Apttus_Proposal__Proposal__c proposal){
      try{  
       Apttus_Proposal__Proposal__c proposalRec;
        if(proposal != null && proposal.id != null){
            proposalRec = [select id,MasterOpportunity__c from Apttus_Proposal__Proposal__c where id =: proposal.id limit 1];
        }
        if(proposalRec.MasterOpportunity__c != Null){
            id msterOpptyId = proposalRec.MasterOpportunity__c;
            list<Promotion_Engine_Junction__c> promotions = [select id,Rank__c,Opportunity__c,Discount_Percentage__c from 
                                                             Promotion_Engine_Junction__c where Opportunity__c =: msterOpptyId];
            if(promotions != null && promotions.size() > 0){
                return promotions;
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
        return null;
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
             return null;
             }
    }
    
    
    public list<Promotion_Engine_Junction__c> getDealPromotions(Apttus_Proposal__Proposal__c proposal){
      try{  
       Apttus_Proposal__Proposal__c proposalRec;
        if(proposal != null && proposal.id != null){
            proposalRec = [select id,Apttus_Proposal__Opportunity__c from Apttus_Proposal__Proposal__c where id =: proposal.id limit 1];
        }
        if(proposalRec.Apttus_Proposal__Opportunity__c != Null){
            id OpptyId = proposalRec.Apttus_Proposal__Opportunity__c;
            list<Promotion_Engine_Junction__c> promotions = [select id,Rank__c,Opportunity__c,Discount_Percentage__c from 
                                                             Promotion_Engine_Junction__c where Opportunity__c =: OpptyId];
            if(promotions != null && promotions.size() > 0){
                return promotions;
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
        return null;
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
             return null;
             }
    }
    
    
    
    
/* 
 Name: getSpDiscPercentage
 Description: 
 */ 
    public decimal getSpDiscPercentage(list<Promotion_Engine_Junction__c> promotions){
      try{  
        list<Promotion_Engine_Junction__c> promos = promotions;
        if(promos != null ){
            for(Promotion_Engine_Junction__c promo : promos){
                if(promo.Rank__c == 2){
                    decimal spDisc = promo.Discount_Percentage__c;
                    return spDisc;
                }
            }
        }
        return 0.0;
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
             return null;
             }
   }
    
/* 
 Name: getDealRegDiscPercentage
 Description: 
 */ 
    public decimal getDealRegDiscPercentage(list<Promotion_Engine_Junction__c> promotions){
    try{    
        list<Promotion_Engine_Junction__c> promos = promotions;
        if(promos != null){
            for(Promotion_Engine_Junction__c promo : promos){
                if(promo.Rank__c == 4){
                    decimal dealRegDisc = promo.Discount_Percentage__c;
                    return dealRegDisc;
                }
            }
        }
        return 0.0;
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
             return null;
             }  
    }
    /*Name: applyDiscount*/
    Public decimal applyDiscount(decimal listPrice, decimal discPercentage){
      try{  
        decimal listAmount = listPrice;
        decimal discPer = discPercentage;
        decimal discountAmount = 0.0;
        if( discPer != null && listAmount != null){
            discountAmount = (listAmount * discPer)/100;
        }
        return discountAmount;  
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
             return null;
             }  
    }
    /*Name:applyPromotions */
    Public decimal applyPromotions(decimal listPrice, list<Promotion_Engine_Junction__c> promotions){
        try{
        decimal fianlAmountAfterDisc = listPrice;
        if(promotions != null && promotions.size() > 0 && listPrice != null ){
            decimal spDiscPer = getSpDiscPercentage(promotions);
            decimal dealRegDiscPer = getDealRegDiscPercentage(promotions);
            decimal spDiscAmount = applyDiscount(listPrice,spDiscPer);
            decimal amountAfterSpDisc = listPrice - spDiscAmount; 
            decimal dealRegDiscAmount = applyDiscount(amountAfterSpDisc, dealRegDiscPer);
            fianlAmountAfterDisc = amountAfterSpDisc - dealRegDiscAmount;
        }
        return fianlAmountAfterDisc;  
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
             return null;
             }  
    }
    
/* 
 Name: clonePromoEngineJunctions
 Description: 
 */ 
    public list<Promotion_Engine_Junction__c> clonePromoEngineJunctions(id masterOptyId,id macdOptyId){
        try{
            list<Promotion_Engine_Junction__c> tempMasterOptyPromos = new list<Promotion_Engine_Junction__c>();
            list<Promotion_Engine_Junction__c> masterOptyPromos = new list<Promotion_Engine_Junction__c>();
            list<Opportunity> macdOptyList = new list<Opportunity>();
            Boolean contractRenewal = false;
            if(masterOptyId != null && macdOptyId != null){
                macdOptyList = [select id,Renewal_Contract__c from Opportunity where id =:macdOptyId LIMIT 1];
                if(macdOptyList != null && macdOptyList.size()>0){
                    contractRenewal = macdOptyList[0].Renewal_Contract__c;
                }
                system.debug('@@@contractRenewal'+contractRenewal);
                if(contractRenewal == true){
                    tempMasterOptyPromos = [select id,Opportunity__c,Rank__c from Promotion_Engine_Junction__c where Opportunity__c =: masterOptyId and Rank__c != 2];
                }else{
                    tempMasterOptyPromos = [select id,Opportunity__c from Promotion_Engine_Junction__c where Opportunity__c =: masterOptyId];
                }
                if(tempMasterOptyPromos != null && tempMasterOptyPromos.size() > 0){
                    //create set of ids for master opty prpmos
                    set<id> masterPromoIds = new set<id>();
                    for(Promotion_Engine_Junction__c masterPromo : tempMasterOptyPromos){
                        masterPromoIds.add(masterPromo.id);
                    }
                    //Get values for all fields in Sobject
                    masterOptyPromos = populateAllFieldsInSobjects(UtilityConstant.PROMOTIONENGINE_JUNCTION_C, masterPromoIds);
                }
                
                list<Promotion_Engine_Junction__c> macdOptyPromos = new  list<Promotion_Engine_Junction__c>();
                if(masterOptyPromos != null && masterOptyPromos.size() > 0){  
                    for(Promotion_Engine_Junction__c masterPromo : masterOptyPromos){
                        Promotion_Engine_Junction__c macdPromo = masterPromo.clone(false,true,false,false);
                        macdPromo.Opportunity__c = macdOptyId;
                        macdOptyPromos.add(macdPromo);
                    } 
                
                    if(macdOptyPromos != null && macdOptyPromos.size() > 0){
                        insert macdOptyPromos;
                        return macdOptyPromos;
                    }
                }
            }
            return null;
        
        }catch(exception ex){
            return null;
        }
    }
    
/* 
 Name: doPostDiscountUpdates
 Description: 
 */ 
    public void doPostDiscountUpdates(id masterOptyId,id macdOptyId){
        try{
            List<Opportunity> macdOpptyList = [Select Id,RDS_Deal_Hash__c,RDS_Deal_Hash__r.Opportunity__r.Name,Credit_Check_Status__c,Cumulative_List_Price__c,Cumulative_OTC_Price__c,Discounted_Price__c,Cumulative_OTC_Discount_Price__c,StageName,Standard_Discount_Percentage__c,Custom_Deal_Reg_Percentage__c,Discount_Amount__c from Opportunity where ID =:macdOptyId];
            if(macdOpptyList != null && macdOpptyList.size() > 0){
                SIHelper.genericPromotionEnginelogic(macdOpptyList);
                
                AggregateResult[] groupedResults = [SELECT Deal__c, SUM(List_Price__c) ListPrice, SUM(one_time_revenue__c) OTCPrice, SUM(One_Time_Revenue_Discount_Price__c) OTCDiscountPrice, SUM(Discounted_Price__c) DiscountedPrice FROM SPProduct__c sp WHERE sp.Deal__c =: macdOptyId GROUP BY sp.Deal__c];
                for(Opportunity op : macdOpptyList){
                    for(AggregateResult agr: groupedResults)
                    {
                        if(agr.get('Deal__c')== op.Id)
                        {
                            op.Cumulative_List_Price__c = (Decimal)agr.get('ListPrice');
                            op.Discounted_Price__c=(Decimal)agr.get('DiscountedPrice');
                            if( op.StageName != UtilityConstant.PRICINGSCHEDULE_PENDING && OP.StageName!=ATTConstants.QUOTE_PRICING_SCHEDULE_REQUESTED && OP.StageName!=SIConstants.OPP_STAGE_ORDER_SUB  ){
                                op.StageName = SIConstants.OPTY_DEAL_Auto_Approved;
                            }
                            op.Cumulative_OTC_Discount_Price__c =(Decimal)agr.get('OTCPrice');
                            op.Cumulative_OTC_Price__c =(Decimal)agr.get('OTCDiscountPrice');
                            if(op.Cumulative_List_Price__c != null && op.Discounted_Price__c != null){
                                op.Discount_Amount__c = op.Cumulative_List_Price__c - op.Discounted_Price__c;
                            }
                        }
                    }
                }
            }
            if(macdOpptyList != null && macdOpptyList.size() > 0){
                update macdOpptyList;
            }
        }catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    //Added to call backend MACD
    @future
/* 
 Name: clonePromosAndUpdateOpptybackendMACD
 Description: 
 */ 
    public static void clonePromosAndUpdateOpptybackendMACD(id masterOptyId,id macdOptyId){
        try{
            list<Promotion_Engine_Junction__c> tempMasterOptyPromos = new list<Promotion_Engine_Junction__c>();
            list<Promotion_Engine_Junction__c> masterOptyPromos = new list<Promotion_Engine_Junction__c>();
            
            if(masterOptyId != null && macdOptyId != null){
                tempMasterOptyPromos = [select id,Opportunity__c from Promotion_Engine_Junction__c where Opportunity__c =: masterOptyId];
               
                if(tempMasterOptyPromos != null && tempMasterOptyPromos.size() > 0){
                    //create set of ids for master opty prpmos
                    set<id> masterPromoIds = new set<id>();
                    for(Promotion_Engine_Junction__c masterPromo : tempMasterOptyPromos){
                        masterPromoIds.add(masterPromo.id);
                    }
                    //Get values for all fields in Sobject
                    masterOptyPromos = populateAllFieldsInSobjects(UtilityConstant.PROMOTIONENGINE_JUNCTION_C, masterPromoIds);
                }
                
                list<Promotion_Engine_Junction__c> macdOptyPromos = new  list<Promotion_Engine_Junction__c>();
                if(masterOptyPromos != null && masterOptyPromos.size() > 0){  
                    for(Promotion_Engine_Junction__c masterPromo : masterOptyPromos){
                        Promotion_Engine_Junction__c macdPromo = masterPromo.clone(false,true,false,false);
                        macdPromo.Opportunity__c = macdOptyId;
                        macdOptyPromos.add(macdPromo);
                    } 
                
                    if(macdOptyPromos != null && macdOptyPromos.size() > 0){
                        insert macdOptyPromos;
                    }
                }
            }
        
        }catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        
        List<Opportunity> opptyList=[Select Id,RDS_Deal_Hash__c,RDS_Deal_Hash__r.Opportunity__r.Name,Credit_Check_Status__c from Opportunity where ID =:masterOptyId];
        List<Opportunity> macdOpptyList=[Select Id,RDS_Deal_Hash__c,RDS_Deal_Hash__r.Opportunity__r.Name,Credit_Check_Status__c,Cumulative_List_Price__c,Cumulative_OTC_Price__c,Discounted_Price__c,Cumulative_OTC_Discount_Price__c,Standard_Discount_Percentage__c,Custom_Deal_Reg_Percentage__c from Opportunity where ID =:macdOptyId];
        SIHelper.genericPromotionEnginelogic(macdOpptyList);
        
        AggregateResult[] groupedResults = [SELECT Deal__c, SUM(List_Price__c) ListPrice, SUM(one_time_revenue__c) OTCPrice, SUM(One_Time_Revenue_Discount_Price__c) OTCDiscountPrice, SUM(Discounted_Price__c) DiscountedPrice FROM SPProduct__c sp WHERE sp.Deal__c =: macdOptyId GROUP BY sp.Deal__c];
        for(Opportunity OP:macdOpptyList){
            for(AggregateResult agr: groupedResults)
            {
                if(agr.get('Deal__c')== OP.Id)
                {
                     OP.Cumulative_List_Price__c = (Decimal)agr.get('ListPrice');
                     OP.Discounted_Price__c=(Decimal)agr.get('DiscountedPrice');
                     OP.Cumulative_OTC_Discount_Price__c =(Decimal)agr.get('OTCPrice');
                     OP.Cumulative_OTC_Price__c =(Decimal)agr.get('OTCDiscountPrice');
                }
            }
        }
        
        update macdOpptyList;
    } 
    
/* 
 Name: populateAllFieldsInSobjects
 Description: 
 */ 
    public static list<sObject> populateAllFieldsInSobjects(string objName, set<id> idsSet) {
        String fieldnames = SpecialCharacterConstant.CONCAT;
        list<sObject> objs;
        try {
            Map < String, Schema.SObjectType > sobjMap = Schema.getGlobalDescribe();
            Schema.SObjectType sObj = sobjMap.get(objName);
            Schema.DescribeSObjectResult sObjDescResult = sObj.getDescribe();

            //get fields
            Map < String, Schema.SObjectField > fields = sObjDescResult.fields.getMap();
            for (string field: fields.keySet()) {
                if (fieldnames == SpecialCharacterConstant.CONCAT) {
                    fieldnames = field;
                } else {
                    fieldnames += SpecialCharacterConstant.COMMA + field;
                }
            }

            //create SQL
            String sql = 'SELECT ' + fieldnames + ' FROM ' + objName + ' WHERE Id in : tempIdSetPlaceHolder';
            objs = database.query(sql.replace('tempIdSetPlaceHolder', 'idsSet' ));

        } catch (Exception e) {
            return null;
        }
        return objs;
    }
    
/* 
 Name: updatePPForWithoutDiscount
 Description: 
 */ 
    public void updatePPForWithoutDiscount(id macdOptyId){
        list<Product_Pricing__c> updatePPRecords = new list<Product_Pricing__c>();
        try{
            updatePPRecords = [SELECT Deal_Id__c,Product_Record_Type__c,SP_Discount_Percentage__c,Type__c,Discountable__c,List_Price__c,discount_price__c,Discounted_Price__c, Record_Type__c,Usage_Charges__c,Discounted_Usage_Charge__c FROM Product_Pricing__c pr WHERE pr.SP_Product__c IN (SELECT Id FROM SPProduct__c WHERE Deal__c =:macdOptyId) AND (Type__c= :SIConstants.TYPE_MRC OR Type__c= :SIConstants.TYPE_NRC OR Type__c= :SIConstants.TYPE_MUC)];
            if(!updatePPRecords.isEmpty()){
                for(Product_Pricing__c prod:updatePPRecords)
                        {
                            if(prod.Discounted_Price__c == null)
                            {
                                prod.Discounted_Price__c = prod.List_Price__c;
                            }
                        }
                update updatePPRecords;
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
/* 
 Name: clonePromosAndUpdateOppty
 Description: 
 */ 
    public void clonePromosAndUpdateOppty(Id masterOppty, Id  macdOppty){
        try{
            List<Opportunity> macdOpp = [select id,Cumulative_List_Price__c,Discounted_Price__c from Opportunity where id =:macdOppty];
            decimal discountedlistPrice = 0.0;
            list<Promotion_Engine_Junction__c> macdPromos = new list<Promotion_Engine_Junction__c>();
            macdPromos = clonePromoEngineJunctions(masterOppty, macdOppty);
            decimal listPrice = macdOpp[0].Cumulative_List_Price__c;
            decimal discountedPrice = macdOpp[0].Discounted_Price__c;
            if(macdOppty != null){
                if(macdPromos != null && macdPromos.size() >0){
                    discountedlistPrice = applyPromotions(listPrice, macdPromos);
                    doPostDiscountUpdates(masterOppty,macdOppty);
                    if(String.valueof(discountedPrice) ==SpecialCharacterConstant.CONCAT || String.valueof(discountedPrice) == null){
                        updatePPForWithoutDiscount(macdOppty);
                    }
                }
            }
        }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
             
             }
    }   
       
}