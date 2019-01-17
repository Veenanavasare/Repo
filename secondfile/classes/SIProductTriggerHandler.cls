/*
****************************************** **********************************************************************        
Component Name : SIProductTriggerHandler 
Component Description: All SP Product Related methods and exceution can be called from this Handeler. A generic trigger handler class for all the 
operations(Insert,Update,Delete and Undelete) which operates on 'Before/After'     
Author Name : Accenture IDC    
Version:1.0    
Created Date:12th Jan  2013     
Last Modified Date:12th Dec 2014      
Description: Code Refactoring and Condition Check for API Methods/SOQL    
Last Modified Date:2nd Dec 2014      
Description: Code Optimzation and  Addition of Constant Static for Hard Coded Values   
Last Modified Date : 12th Dec 2014  
Description : Addition of Constant Static for Hard Coded Values  

****************************************************************************************************************
*/

/* 
 Name: SITriggerOperations.SITriggerImpl
 Type: Class 
 
 Description: 
 */ 
public with sharing class  SIProductTriggerHandler extends SITriggerOperations.SITriggerImpl {
    public boolean isExecuted ;
    Public boolean isPricingScheduleRequested; 
    Public  boolean isOrderSubmitted; 
    
    //Default cons
/* 
 Name: SIProductTriggerHandler
 Description: 
 */ 
    public SIProductTriggerHandler() {
        isExecuted = true;
    }  
    
    //An Overridden method
/* 
 Name: onBeforeInsert
 Description: 
 */ 
    public override boolean onBeforeInsert(SObject[] newObjects) {
      try{  
        List<SPProduct__c> sppList = newObjects;
        List<SPProduct__c> spList = new List<SPProduct__c>();
        List<SPProduct__c> changeSPList = new List<SPProduct__c>();
        
        //Code to nullify Rome Opportunity for non price impacting MACD's
        for(SPProduct__c spp : sppList){        
            if(spp.MACD_Change_Type__c == UtilityConstant.ADDVLAN || spp.MACD_Change_Type__c == UtilityConstant.DISCONNECTVLAN || spp.MACD_Change_Type__c == UtilityConstant.COSCHANGE || spp.MACD_Change_Type__c == UtilityConstant.VLANSPEED_CHANGE){
                spp.Rome_Opportunity__c = null;
            }
        }
        
        for(SPProduct__c spPr : sppList){
            if((spPr.MACD_Type__c != UtilityConstant.D && spPr.MACD_Type__c != UtilityConstant.C) || spPr.Renewal_Contract__c == true){
                spList.add(spPr);
            }
            if(spPr.MACD_Type__c == UtilityConstant.C && (spPr.Discounted_Price__c != null || spPr.List_Price__c != null)) {
                changeSPList.add(spPr);
            }
        }
        if(spList.size()>0){
            try {
                assignDealStatus(newObjects,true); 
                updateEBMDiscountPlanId(newObjects) ;  
                macdASubAccInsert(newObjects);
                
            } catch(Exception e) {
                isExecuted = false;
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
        
        if(changeSPList.size()>0){
            try{
                populatePriceCompare(newObjects);
            }
            catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                isExecuted = false;
            }
            
        }
        
        return isExecuted;
      }
        catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }   
    }
    
    //An Overridden method
/* 
 Name: onAfterInsert
 Description: 
 */ 
    public override boolean onAfterInsert(SObject[] newObjects) {
        
        List<SPProduct__c> sppList = newObjects;
        List<SPProduct__c> spList = new List<SPProduct__c>();
        List<SPProduct__c> macdChangeSPList = new List<SPProduct__c>();
        Set<String> spSiteIdASE = new Set<String>();
        Map<String,String> spASRStatusMapASE = new Map<String,String>();
        Map<String,SPProduct__c> spASECircuitID = new Map<String,SPProduct__c>();
        Set<String> optyIdASESet = new Set<String>();
        
        for(SPProduct__c spPr : sppList){
            if((spPr.MACD_Type__c != UtilityConstant.D && spPr.MACD_Type__c != UtilityConstant.C) || spPr.Renewal_Contract__c == true){
                spList.add(spPr);
            }
            else if(spPr.MACD_Type__c == UtilityConstant.C && spPr.MACD_Price_Compare__c != null){
                macdChangeSPList.add(spPr);
            }
            if(spPr.Product_Name__c != null && spPr.Product_Name__c.equals(BuyflowConstant.ATT_SWITCHED_ETHERNET_SERVICE)){
                optyIdASESet.add(spPr.Deal__c);
                spSiteIdASE.add(spPr.Site_ID__c);
                spASRStatusMapASE.put(spPr.Site_ID__c,spPr.ASR_Status__c);
                spASECircuitID.put(spPr.Site_ID__c,spPr);
            } 
        }
        if(spList.size()>0){
            try {
                updatePricingDiscountsOnOpportunity(newObjects,newObjects,true);
                updateDealStatus(newObjects,newObjects, true); 
                updateOpptyAttwireless(newObjects);
                updateDealOnOffCartFieldonProduct(newObjects,newObjects,true); 
                updateNumberOfProductsField(newObjects);
                createSharingrule(newObjects);
                if( !test.isRunningTest() ) {
                    updateInRegionDiscount(newObjects,newObjects,true);
                }
            } catch(Exception excep) {
                isExecuted = false;
                ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
            }
        }
        
        if(macdChangeSPList != null && macdChangeSPList.size() > 0){
            try{
                updatePricingDiscountsOnOpportunity(newObjects,newObjects,true);
            }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
        if(spSiteIdASE.size()>0){
            try{
                updateASRStatusOnQuoteJunction(optyIdASESet,spSiteIdASE,spASRStatusMapASE,spASECircuitID);
            }catch(Exception e){
                ATTException.createExceptionWithoutFuture('Error in SIProductTriggerHandler', e.getTypeName(), ATTException.constructExceptionMessageString(e));
                isExecuted=false;
                throw e;
            }
        }
        
        return isExecuted;
    }
    
    //An Overridden method
/* 
 Name: onBeforeUpdate
 Description: 
 */ 
    public override boolean onBeforeUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap ){
       try{ 
        List<SPProduct__c> sppList = newObjects;
        List<SPProduct__c> spList = new List<SPProduct__c>();
        List<SPProduct__c> changeSPList = new List<SPProduct__c>();
        Map<id,SPProduct__c> oldSPMap = new Map<id,SPProduct__c>();
        Map<id,SPProduct__c> newSPMap = (Map<id,SPProduct__c>)newObjectsMap;
        isPricingScheduleRequested=false;
        isOrderSubmitted=false;
        for(SPProduct__c oldspr: (List<SPProduct__c>)oldObjects){
            oldSPMap.put(oldspr.id,oldspr);            
        }
        
        for(SPProduct__c spPr : sppList){
            if((spPr.MACD_Type__c != UtilityConstant.D && spPr.MACD_Type__c != UtilityConstant.C) || spPr.Renewal_Contract__c == true){
                spList.add(spPr);
            }
            SPProduct__c oldSpRec = oldSPMap.get(spPr.id);
            if( spPr.MACD_Type__c == UtilityConstant.C && oldSpRec != null ){
                if( spPr.Discounted_Price__c != null && (spPr.Discounted_Price__c != oldSpRec.Discounted_Price__c || spPr.MACD_Price_Compare__c != oldSpRec.MACD_Price_Compare__c) ){
                    changeSPList.add(spPr);
                }
                else if( spPr.Discounted_Price__c == null ){
                    if( spPr.List_Price__c != null && (spPr.List_Price__c != oldSpRec.List_Price__c || spPr.MACD_Price_Compare__c != oldSpRec.MACD_Price_Compare__c) ){
                        changeSPList.add(spPr);
                    }
                }
            }
            system.debug('$$$$StageOppty$$$'+spPr.Deal_Stage_on_Product__c);
            if(spPr.Deal_Stage_on_Product__c== SIConstants.dealstatus){
            
                isPricingScheduleRequested=true;
            }
            if(spPr.Deal_Stage_on_Product__c== SIConstants.OPP_STAGE_ORDER_SUB){
               isOrderSubmitted=true;
            }
        }
        
        if(spList.size()>0){
            try{
                if(!SIConstants.isDealRegApproval)
                {
                    system.debug('$$$$StageOppty$$$2'+isPricingScheduleRequested);
                    assignDealStatus(newObjects,false);
                    if(!isPricingScheduleRequested && !isOrderSubmitted){ 
                        updateDealStatus(newObjects,oldObjects, false);
                        clearDiscountFields(newObjects,oldObjects);
                    }
                }
            
                updateEBMDiscountPlanId(newObjects);//created for API-we r calling this method to Populate EBM Discount Plan Id on SPProduct   
                if(isPricingScheduleRequested){
                 updateEBMDiscountPlanAssignmentStatus(oldObjects,newObjects);
                }
            }
            catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                isExecuted=false;
                throw e;
            }
        }
        if(changeSPList.size()>0){
            try{
                populatePriceCompare(newObjects);
            }
            catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                isExecuted = false;
            }
            
        }
        return isExecuted;    
       }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }
    }
    
    
    //An Overridden method
/* 
 Name: onAfterUpdate
 Description: 
 */ 
    public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap ){
      try{  
        List<SPProduct__c> sppList = newObjects;
        List<SPProduct__c> SPList = new List<SPProduct__c>();
        List<SPProduct__c> macdChangeSPList = new List<SPProduct__c>();
        Map<id,SPProduct__c> oldSPMap = new Map<id,SPProduct__c>();
        isPricingScheduleRequested=false;
        isOrderSubmitted=false;
        List<SPProduct__c> SPListASE = new List<SPProduct__c>();
        Set<String> SPSetASE = new Set<String>();
        Set<String> spSiteIdASE = new Set<String>();
        Map<String,String> spASRStatusMapASE = new Map<String,String>();
        Map<String,SPProduct__c> spASECircuitID = new Map<String,SPProduct__c>();
        Set<String> optyIdASESet = new Set<String>();
        
        for(SPProduct__c oldspr : (List<SPProduct__c>) oldObjects){
            oldSPMap.put(oldspr.id,oldspr);
           }
        for(SPProduct__c spPr : sppList){
            if((spPr.MACD_Type__c != UtilityConstant.D && spPr.MACD_Type__c != UtilityConstant.C) || spPr.Renewal_Contract__c == true){
                SPList.add(spPr);
            }
            else if(spPr.MACD_Type__c == UtilityConstant.C && spPr.MACD_Price_Compare__c != null && spPr.MACD_Price_Compare__c != oldSPMap.get(spPr.id).MACD_Price_Compare__c){
                macdChangeSPList.add(spPr);
            }
            if(spPr.Deal_Stage_on_Product__c== SIConstants.dealstatus){
                isPricingScheduleRequested=true;
            }
            if(spPr.Deal_Stage_on_Product__c== SIConstants.OPP_STAGE_ORDER_SUB){
               isOrderSubmitted=true;
            }
            
            if(spPr.Product_Name__c == BuyflowConstant.ATT_SWITCHED_ETHERNET_SERVICE && spPr.ASR_Status__c != oldSPMap.get(spPr.id).ASR_Status__c){
                optyIdASESet.add(spPr.Deal__c);    
                spSiteIdASE.add(spPr.Site_ID__c);
                spASRStatusMapASE.put(spPr.Site_ID__c,spPr.ASR_Status__c);
                 spASECircuitID.put(spPr.Site_ID__c,spPr);
                updateNumberOfProductsField(newObjects);
                if(spPr.ASR_Status__c == SIConstants.RDS_PREMISE_SITE_STATUS_CANCELLED || spPr.ASR_Status__c == MACDConstant.DISCONNECTED){
                    SPListASE.add(spPr);
                    SPSetASE.add(spPr.Site_ID__c);
                }
            }
            
         }
        if(SPList.size()>0){
            try{
                if(!SIConstants.isDealRegApproval)
                {                   
                    if(!isPricingScheduleRequested && !isOrderSubmitted){ 
                        updateDealOnOffCartFieldonProduct(oldObjects,newObjects,false);
                        updateSpecialPricingFlag(newObjects,oldObjects);
                        updatePricingDiscountsOnOpportunity(oldObjects,newObjects,false);
                        updateProductPricingOnDealStatusChange(oldObjects,newObjects,newObjectsMap);// added additional check for MACD Add deal
                    } 
                } 
                updateOpportunityfields(newobjects);  
                updateEBMCompetitiveDiscountPlanID(oldObjects, newobjects);//created for API-we r calling this method to Populate EBMCompetitiveDiscountPlanID on Product Pricing       
            }
            catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                isExecuted=false;
                throw e;
            }
        }
        if(macdChangeSPList != null && macdChangeSPList.size() > 0){
            updatePricingDiscountsOnOpportunity(oldObjects,newObjects,false);
        }
        if(spSiteIdASE.size()>0){
            try{
                updateASRStatusOnQuoteJunction(optyIdASESet,spSiteIdASE,spASRStatusMapASE,spASECircuitID);
            }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                isExecuted=false;
                throw e;
            }
        }
        if(SPListASE.size()>0){
            updatePrice(SPListASE,SPSetASE);
        }
        return isExecuted;  
       }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }   
    }
    
    
    //An Overridden method
/* 
 Name: onBeforeDelete
 Description: 
 */ 
    public override boolean onBeforeDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap){
        try{          
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            isExecuted=false;
            throw e;
        }    
        return isExecuted;
    }
    /* 
     Name: onAfterDelete
     Description: 
    */  
    public override boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap)
    {
        try
        {
            updateNumberOfProductsField(oldObjects); 
            updatePricingFieldsAfterDeletion(oldObjects, oldObjectsMap);
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            isExecuted=false;
            throw e;
        }    
        return isExecuted;
    }
    
    /* 
     Name: onUndelete
     Description: 
     */ 
    public override boolean onUndelete(SObject[] newObjects)
    {
        try
        {
            updateNumberOfProductsField(newObjects); 
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            isExecuted=false;
            throw e;
        }    
        return isExecuted;
    }
    //Method Used Assign the Deal status values to prodcut before insert
    
/* 
 Name: assignDealStatus
 Description: 
 */ 
    public void assignDealStatus(SObject[] updatedObjects,Boolean isInsert){   
        try{ 
            
            Map<Id,String> optyMap=new Map<Id,String>();
            List<SPProduct__c> prodList = updatedObjects;
            Set<Id> prodsIdsList = new Set<Id>();
            Admin_Control__c admin = [Select Discounted_Percentage__c,Mobility_Discunted_Percentage__c,ASE_Auto_Approved__c From Admin_Control__c Limit 1];    
            
            for(SPProduct__c SP:prodList){
                prodsIdsList.add(SP.deal__c);
            }
            if( prodsIdsList.size() > 0 ){
                List<Opportunity> optylist = [SELECT id,StageName FROM Opportunity WHERE Id in :prodsIdsList];
                
                for(Opportunity opty: optylist){
                    optyMap.put(opty.id,opty.StageName);
                }
            }
            for(SPProduct__c s:prodList){
                if(isInsert){
                    if(null == s.Deal_Status__c || s.Deal_Status__c.equalsIgnoreCase(SpecialCharacterConstant.CONCAT)) {
                        if(optyMap.get(s.deal__c)==SIConstants.PROD_DEAL_REG_REQ || optyMap.get(s.deal__c)==SIConstants.PROD_DEAL_REG_PENDING || optyMap.get(s.deal__c)==SIConstants.OPTY_DEAL_Auto_Approved )
                        {
                            s.Deal_Status__c=optyMap.get(s.deal__c);
                        }
                    }
                    //US216710  : ASE Auto Approval ---should be Approved with discount -- updated logic to fire only for BID Deal
                    if( s.Record_Type_Name__c ==SIConstants.PROD_ASE && admin.ASE_Auto_Approved__c && (optyMap.get(s.deal__c)==SIConstants.PROD_DEAL_REG_REQ || optyMap.get(s.deal__c)==SIConstants.OPTY_DEAL_APPROVED ) && !s.ATOM_Deal__c ){
                        s.Deal_Status__c=SIConstants.OPTY_DEAL_APP_WITH_DIS;
                        s.Deal_Registration_Discount__c=admin.Discounted_Percentage__c;
                    }
                    
                }
                else{
                    if(OptyMap.get(s.deal__c)==SIConstants.OPP_STAGE_ORDER_SUB && s.Deal_Status__c!=SIConstants.OPP_STAGE_ORDER_SUB){
                        s.Deal_Status__c=OptyMap.get(s.deal__c);
                    }
                }
                //US216710  : ASE Auto Approval ---should be Approved with discount -- updated logic to fire only for BID Deal
                if(s.Record_Type_Name__c ==SIConstants.PROD_ASE && admin.ASE_Auto_Approved__c && (OptyMap.get(s.deal__c)==SIConstants.PROD_DEAL_REG_REQ || OptyMap.get(s.deal__c)==SIConstants.OPTY_DEAL_APPROVED)  && !s.ATOM_Deal__c ){
                    s.Deal_Status__c=SIConstants.OPTY_DEAL_APP_WITH_DIS;
                    s.Deal_Registration_Discount__c=admin.Discounted_Percentage__c;
                }else if(s.X3rd_Party_Flag__c){
                    s.Deal_Registration_Discount__c=admin.Discounted_Percentage__c;
                }
            }  
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        } 
    } 
    
    
    /* 
     Name: updateDealStatus
     Description: A method to update the auto approval on deal status
    */ 
    private void updateDealStatus(SObject[] newObjects,SObject[] oldObjects, boolean isInsertFlag) {
        Set<Id> productSet = new Set<Id>();
        Map<Id, SPProduct__c> productMap = new Map<Id, SPProduct__c>();
        Set<Id> endCustomerSet = new Set<Id>();
        Map<String, SPProduct__c> productKeyMap = new Map<String, SPProduct__c>();
        
        SPProduct__c prodObj = null;
        SPProduct__c productActuObj = null;
        SPProduct__c productClonedObj = null;
        String objectKey = SpecialCharacterConstant.CONCAT;
        
        try {
            if(isInsertFlag){
                    for(SPProduct__c productObj : (SPProduct__c[]) newObjects) {
                        if(productObj.Deal_Status__c != null && productObj.Deal_Status__c.length() > 0 &&(productObj.Deal_Status__c.equalsIgnoreCase(UtilityConstant.DEALREGISTRATION_PENDING)|| productObj.Deal_Status__c.equalsIgnoreCase(SIConstants.PROD_DEAL_STATUS[0])|| productObj.Deal_Status__c.equalsIgnoreCase(UtilityConstant.DEALREG_AUTO_APPROVED))) {
                            productSet.add(productObj.Id);
                            if(isInsertFlag) {
                                productClonedObj = productObj.clone(true, false, true, true);
                                productClonedObj.Deal_Status__c = SIConstants.PROD_DEAL_STATUS_AFTER[0];
                                productMap.put(productObj.Id, productClonedObj);
                            } else {
                                productObj.Deal_Status__c = SIConstants.PROD_DEAL_STATUS_AFTER[0];
                                productMap.put(productObj.Id, productObj);
                            }
                        }
                    }
                }else{
                    for(SPProduct__c productObj : (SPProduct__c[]) newObjects) {
                        for(SPProduct__c productOldObj: (SPProduct__c[]) oldObjects){
                            if(productObj.Deal_Status__c != null && productOldObj.Deal_Status__c != productObj.Deal_Status__c && productObj.Deal_Status__c.length() > 0 && (productObj.Deal_Status__c.equalsIgnoreCase(UtilityConstant.DEALREGISTRATION_PENDING) ||
                               productObj.Deal_Status__c.equalsIgnoreCase(SIConstants.PROD_DEAL_STATUS[0]))) {
                                   productSet.add(productObj.Id);
                                   if(isInsertFlag) {
                                       productClonedObj = productObj.clone(true, false, true, true);
                                       productClonedObj.Deal_Status__c = SIConstants.PROD_DEAL_STATUS_AFTER[0];
                                       productMap.put(productObj.Id, productClonedObj);
                                   } else {
                                       productObj.Deal_Status__c = SIConstants.PROD_DEAL_STATUS_AFTER[0];
                                       productMap.put(productObj.Id, productObj);
                                   }
                               }
                        }
                    }
                } 
            if( !productSet.isEmpty() && productSet.size() > 0 ) {
                List<SPProduct__c> sprodList = [Select Deal__r.End_Customer__r.Id, RecordType.DeveloperName, Id, 
                                                Deal__r.End_Customer__r.Named_Account__c,Deal__r.Account.Id from SPProduct__c Where Id In :productSet];
                for(SPProduct__c productObj : sprodList) {
                    endCustomerSet.add(productObj.Deal__r.End_Customer__r.Id);
                    productKeyMap.put(productObj.Deal__r.End_Customer__r.Id +'|'+
                                      productObj.RecordType.DeveloperName+'|'+productObj.Deal__r.End_Customer__r.Named_Account__c, 
                                      productObj);
                }
                
                //Block to handle the deal reg
                if( endCustomerSet.size() > 0 ) {
                    AggregateResult[] groupedResults = [
                        Select Deal__r.Account.Id acctId, Deal__r.End_Customer__r.Id endCustId, 
                        Deal__r.End_Customer__r.Named_Account__c endCustNamedAcct,
                        RecordType.DeveloperName developerName, Deal_Status__c, count(name) productCnt from SPProduct__c
                        Where RecordType.Name <> 'Products' and Deal__r.Account.Name <> null 
                        and Deal__r.End_Customer__r.Id <> null and (Deal_Status__c like 'System%')
                        and Deal__r.End_Customer__r.Id IN :endCustomerSet and Id Not IN :productSet
                        group by Deal__r.Account.Id,  Deal__r.End_Customer__r.Id, 
                        Deal__r.End_Customer__r.Named_Account__c, RecordType.DeveloperName, Deal_Status__c ];
                    for(AggregateResult aggRes : groupedResults) {
                        
                        objectKey = (String) aggRes.get('endCustId') +'|'+
                            (String) aggRes.get('developerName') +'|'+aggRes.get('endCustNamedAcct');
                        
                        if(isInsertFlag) {
                            productClonedObj = productKeyMap.get(objectKey) != null ? 
                                (SPProduct__c) productMap.get(productKeyMap.get(objectKey).Id) : null;
                            if(null != productClonedObj) {
                                if((boolean)aggRes.get('endCustNamedAcct')) {
                                    productClonedObj.Deal_Status__c = SIConstants.PROD_DEAL_STATUS_AFTER[2];
                                } else if(Integer.valueOf(aggRes.get('productCnt')) > 0) {
                                    productClonedObj.Deal_Status__c = SIConstants.PROD_DEAL_STATUS_AFTER[1];
                                    if(productKeyMap.get(objectKey).Deal__r.Account.Id == aggRes.get('acctId')) {
                                        productClonedObj.Deal_Status__c = (String) aggRes.get('Deal_Status__c');
                                    }
                                }
                            }
                        } else {
                            productActuObj = productKeyMap.get(objectKey) != null ? 
                                (SPProduct__c) productMap.get(productKeyMap.get(objectKey).Id) : null;
                            if(null != productActuObj) {
                                if((boolean)aggRes.get('endCustNamedAcct')) {
                                    productActuObj.Deal_Status__c = SIConstants.PROD_DEAL_STATUS_AFTER[2];                  
                                } else if(Integer.valueOf(aggRes.get('productCnt')) > 0) {
                                    productActuObj.Deal_Status__c = SIConstants.PROD_DEAL_STATUS_AFTER[1];
                                    System.debug(productKeyMap.get(objectKey).Deal__r.Account.Id +SpecialCharacterConstant.COLEN+aggRes.get(BuyflowConstant.acctId));
                                   if(productKeyMap.get(objectKey).Deal__r.Account.Id == aggRes.get('acctId')) {
                                        productActuObj.Deal_Status__c = (String) aggRes.get('Deal_Status__c');   
                    }
                                }
                            }
                        }       
                    } 
                }//end for deal reg
                
                //Named Account block
                for(String productKeyMapKey : productKeyMap.keySet()) {
                    if(Boolean.valueOf(productKeyMapKey.split(SpecialCharacterConstant.TWOBACKSPACELINE)[2])) {
                        prodObj = (SPProduct__c) productMap.get(productKeyMap.get(productKeyMapKey).Id);
                        prodObj.Deal_Status__c = SIConstants.PROD_DEAL_STATUS_AFTER[2]; 
                    }
                }
                if(isInsertFlag) {
                    update(productMap.values());
                }
            }
            
        } catch(Exception excep) {
            ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
            throw excep;
        }
    }        
       
    /* 
     Name: clearDiscountFields
     Description: 
    */ 
    public Void clearDiscountFields(SObject[] newObjects,SObject[] oldObjects)
    {
    try{    
        List <SPProduct__c> newOptyList= newObjects;
        List <SPProduct__c> oldOptyList=oldObjects;
        for(Integer i=0;i< oldOptyList.size();i++)
        {
            if(newOptyList[i].Deal_Status__c!=oldOptyList[i].Deal_Status__c&&newOptyList[i].Deal_Status__c==SIConstants.PROD_DEAL_QUOTE_EXPIRED)
            {
                newOptyList[i].Discount_Percentage__c=Null;
                newOptyList[i].Flat_Discount_Value__c=Null;
                newOptyList[i].Discount_Amount__c=Null;
                newOptyList[i].Discounted_Percentage__c=Null;
                newOptyList[i].Competitive_Pricing_Status__c=Null;
                newOptyList[i].Deal_Registration_Discount__c=Null;
                newOptyList[i].Discounted_Price__c=Null;
            }
        } 
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }       
    }
    
    //This is update Opportunity Attwireless Flag field to true
/* 
 Name: updateOpptyAttwireless
 Description: 
 */ 
    public Void updateOpptyAttwireless(SObject[] newObjects){
     try{   
        List<SPProduct__c> prodList = newObjects;
        List<Opportunity> optyList = new List<Opportunity>();
        Map<Id,String> attMap=new Map<Id,String>();
        for(SPProduct__c SP : prodList){
            if((SP.Record_Type_Name__c == SIConstants.PROD_Attwireless) || (SP.Record_Type_Name__c == SIConstants.PROD_MDM)){ 
                attMap.put(sp.Deal__c,UtilityConstant.ATT1);
            }
            if(SP.Record_Type_Name__c == SIConstants.PROD_MIS){ 
                attMap.put(sp.Deal__c,UtilityConstant.MIS);
            }
            if(SP.Record_Type_Name__c == SIConstants.PROD_Broadband){
                attMap.put(sp.Deal__c,UtilityConstant.BROADBAND);
            }
            if(SP.Record_Type_Name__c == SIConstants.PROD_ASE){
                attMap.put(sp.Deal__c,UtilityConstant.ASE);
            }
            /*Promotion engine -- Updtaed logic for IPFLEX Deal*/
            if(SP.Record_Type_Name__c == SIConstants.PROD_IPFLEX){
                attMap.put(sp.Deal__c,UtilityConstant.IPFLEX);
            }
        }
        if( attMap.size() >  0 ) {
            optyList = [select Id,Mobility__c,MIS_Product__c,BroadBand_Product__c,ASE_Product__c from Opportunity where Id IN :attMap.keySet()];
            for(Opportunity op: optyList){
                if(attMap.get(op.Id)==UtilityConstant.ATT1){
                    op.Mobility__c = true;
                }else if(attMap.get(op.Id)==UtilityConstant.MIS){
                    op.MIS_Product__c = true;
                }else if(attMap.get(op.Id)==UtilityConstant.BROADBAND){
                    op.BroadBand_Product__c = true;
                }else if(attMap.get(op.Id)==UtilityConstant.ASE){
                    op.ASE_Product__c = true;
                }else if(attMap.get(op.Id)==UtilityConstant.IPFLEX){
                    op.Product_IPFLEX__c = true;
                    op.IPFlex_Deal__c = SpecialCharacterConstant.TRUE_CAMEL_LITERAL;
                }   
                
                
            }   
            update optyList;
        }
     }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }
    
    /*Name:updateDealOnOffCartFieldonProduct
      Description:
    */
    public void updateDealOnOffCartFieldonProduct(SObject[] oldObjects, SObject[] newObjects, Boolean isInsertFlag)
    {
      
        list <SPProduct__c> oldlist = oldObjects;
        list <SPProduct__c> updatedlist = newObjects;
        list <Opportunity> optyList = new list <Opportunity>();
        set <Id> optyIdSet = new set <Id>();
        list <note> noteList = new list <note>();
        map <Id,String> commentsMap = new map <Id,String>();
        
        try
        {
            if(isInsertFlag){   
                if(!updatedlist.isEmpty() && updatedlist!=null) {
                    for(SPProduct__c sp : updatedlist) {
                        if(sp.On_Off_Cart__c==SIConstants.SPPRODUCT_OFF_CART){
                            optyIdSet.add(sp.Deal__c);
                        }
                        if(sp.Comments__c!= null){
                            commentsMap.put(sp.Id,sp.Comments__c);
                        }
                    }
                }
            }
            else{
                for(integer i=0;i<updatedlist.size();i++)
                {
                    if(oldlist[i].On_Off_Cart__c!=updatedlist[i].On_Off_Cart__c && updatedlist[i].On_Off_Cart__c==SIConstants.SPPRODUCT_OFF_CART)
                    {
                        optyIdSet.add(updatedlist[i].Deal__c);
                    }
                
                    if(oldlist[i].Comments__c!=updatedlist[i].Comments__c && updatedlist[i].Comments__c!= null)
                    {
                        commentsMap.put(updatedlist[i].Id,updatedlist[i].Comments__c);
                    }
                }
            }
            //This is to handle Deal On/Off Cart value updation
            if( !optyIdSet.isEmpty() && optyIdSet!=null && optyIdSet.size() > 0 )
            {
                optyList = [SELECT Id,Deal_On_Off_Cart__c FROM Opportunity opty WHERE opty.Id IN :optyIdSet];   
            }
            
            if( !optyList.isEmpty() && optyList!=null && optyList.size() > 0 )
            {
                for(Opportunity op : optyList)
                {
                    op.Deal_On_Off_Cart__c=SIConstants.DEAL_OFF_CART;
                }
                update optyList;
            }
            
            //This is to handle creation of notes when updating comments field.
            if( !commentsMap.isEmpty()&&commentsMap!=null&&commentsMap.size()>0 )
            {
                for(Id prodId : commentsMap.keySet())
                {
                    
                    note newNote = new note();
                    if((commentsMap.get(prodId)).length() > 77)
                    {
                        newNote.title=commentsMap.get(prodId).substring(0,76)+UtilityConstant.THREEDOTS;
                    }
                    else
                    {
                        newNote.title=commentsMap.get(prodId);
                    }
                    newNote.parentId=prodId;
                    newNote.body=commentsMap.get(prodId);
                    newNote.isPrivate=false;
                    noteList.add(newNote);
                }
            }
            
            if(!noteList.isEmpty()&&noteList!=null&&noteList.size()>0)
            {
                insert noteList;
            }
        }
        catch (exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            e.getMessage();
        }
    }

/* 
 Name: updateSpecialPricingFlag
 Description: 
 */ 
    public Void updateSpecialPricingFlag(SObject[] newObjects,SObject[] oldObjects){
      try{  
        List<SPProduct__c> prodList = newObjects;
        List<SPProduct__c> oldProdList=oldObjects;
        List<Opportunity> optyList = new List<Opportunity>();
        List<Deal_Hash__c> dealHashList= New List<Deal_Hash__c>();
        Set<ID> oppId = new Set<Id>();
        Set<ID> opptyID= New Set<Id>();
        for(SPProduct__c SP : prodList){
            for(SPProduct__c spold: oldProdList){
                if(SP.Competitive_Pricing_Status__c == SIConstants.PROD_COMP_PRI_REQ){ 
                    oppId.add(sp.Deal__c);
                }
                if(SP.Sub_Account__c!=spold.Sub_Account__c && SP.Sub_Account__c!=null){
                    opptyID.add(sp.Deal__c);
                }
            }
        }
        
        if(oppId.size()>0){
            optyList = [select Id,Special_Pricing_Request__c,isSPConfirmed__c from Opportunity where Id IN :oppId];
            if(!optyList .isEmpty()&&optyList !=null){
                for(Opportunity op: optyList){
                    op.Special_Pricing_Request__c = true;
                    op.isSPConfirmed__c=false;
                    op.Prevent_Calculated_Discount_Price_Update__c = true;//This check is used to prevent calculation of Discounted Percentage on opportunity when stage is special pricing requested.
                }   
                update optyList;
            }
        }
        if(opptyID.size()>0){
            dealHashList=[Select Id,Sub_Account_Number__c from Deal_Hash__c where Opportunity__c IN:opptyID];
            
            if(!dealHashList.isEmpty()&& dealHashList!=null){
                for(Deal_Hash__c dealHash: dealHashList){
                    for(SPProduct__c SP : prodList){
                        if(SP.Sub_Account__c!=null && dealHash.Sub_Account_Number__c == null){
                            dealHash.Sub_Account_Number__c = SP.Sub_Account__c;
                        }
                    }  
                }
                try{   
                    update dealHashList;
                }catch(Exception exe){
                    exe.getMessage();
                }
            }
            
        }
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        } 
    }
    
    /** This function is to update the field named Number of Products in Opportunity when products has been added/deleted/undeleted from an opportunity.
*   Release : SI/VAR - 8 - September Release
*   Requirement # : R-2339
*/
    public void updateNumberOfProductsField(SObject[] newObjects)
    {
      
        List<SPProduct__c> prodList = newObjects;
        
        set <Id> optyIdList = new set <Id>();
       list <Opportunity> optyUpdateList = new list <Opportunity>();
        list <Opportunity> existingOpty = new list <Opportunity>();
        set <Id> updateIdList = new set <Id>();     
        list <AggregateResult> prodCount = new list <AggregateResult>();
        
        try
        {
            if(!prodList.isEmpty()&&prodList!=null&&prodList.size()>0)
            {
                for(SPProduct__c prod:prodList)
                {
                    optyIdList.add(prod.Deal__c);
                }                
                if( !prodList.isEmpty() && optyIdList!=null && optyIdList.size()>0 )
                {
                    existingOpty = [SELECT Number_of_Products__c FROM Opportunity Op WHERE Op.Id IN  : optyIdList];                  
                }
            }           
            if( !optyIdList.isEmpty() && optyIdList!=null && optyIdList.size()>0 )
            {
                prodCount = [SELECT Deal__c, count(Id) FROM SPProduct__c Sp WHERE Sp.Deal__c IN : optyIdList And Sp.ASR_Status__c not in('Cancelled','Disconnected') GROUP BY Deal__c ];   
            }            
            if(!prodCount.isEmpty() && prodCount != null)
            {
                for(AggregateResult agr: prodCount)
                {
                    updateIdList.add((Id)agr.get('Deal__c'));
                }
                if(!updateIdList.isEmpty()&&updateIdList!=null)
                {
                    for(AggregateResult agr: prodCount)
                    {
                        for(Opportunity opty : existingOpty)
                        {
                            if(opty.Id ==(Id)agr.get('Deal__c'))
                            {
                                opty.Number_of_Products__c = (Decimal)agr.get('expr0');
                                optyUpdateList.add(opty);
                            }                           
                        }
                    }                                       
                }                   
            }
            if(optyIdList.size()!=optyUpdateList.size())
            {
                boolean optyFlag = false;
                for(Opportunity opty : existingOpty)
                {    
                    if(optyUpdateList.size()!=0)
                    {                       
                        for(Opportunity innerLoop : optyUpdateList)
                        {
                            if(innerLoop.Id==opty.Id)
                            {
                                optyFlag = true;
                            }
                        }                                   
                        if(optyFlag==false)
                        {
                            opty.Number_of_Products__c=0;
                            optyUpdateList.add(opty);
                        }
                        else
                        {
                            optyFlag = false;
                        }
                    }
                    else
                    {
                        opty.Number_of_Products__c=0;
                        optyUpdateList.add(opty);
                    }                                
                }
            }
            if(!optyUpdateList.isEmpty()&&optyUpdateList!=null) 
            {
                update optyUpdateList;
            }   
        }       
        catch (exception e)
        {
            e.getMessage();
        }
    }    
     
    /* 
     Name: updatePricingDiscountsOnOpportunity
     Description: 
    */ 
    public void updatePricingDiscountsOnOpportunity(SObject[] oldObjects,SObject[] newObjects,Boolean isInsertEvent)
    {
      try{  
        list <SPProduct__c> oldList = oldObjects;
        list <SPProduct__c> newList = newObjects;
        set <Id> optySet = new set <Id>();
        list <Opportunity> updatableOppties =new list <Opportunity>();
        if(!newList.isEmpty() && newList!=null)
        {
            for(Integer i =0; i<newList.size(); i++)
            {
                if(isInsertEvent){
                    if(newList[i].Deal__c != null) {
                        optySet.add(newList[i].Deal__c);
                    }
                    
                }else if(oldList[i].MACD_Price_Compare__c != newList[i].MACD_Price_Compare__c || oldList[i].List_Price__c!=newList[i].List_Price__c || oldList[i].one_time_revenue__c!=newList[i].one_time_revenue__c || oldList[i].One_Time_Revenue_Discount_Price__c!=newList[i].One_Time_Revenue_Discount_Price__c || oldList[i].Discounted_Price__c != newList[i].Discounted_Price__c)
                {
                    if(newList[i].Deal__c != null) {
                        optySet.add(newList[i].Deal__c);
                    }
                }
            }
            
            if( !optySet.isEmpty() && optySet!= null && optySet.size()>0 )
            {
                updatableOppties = [SELECT Id, discount_amount__c,StageName,Mobility__c,X3rd_Party_Flag__c,Cumulative_List_Price__c,Cumulative_OTC_Price__c,Discounted_Price__c,Cumulative_OTC_Discount_Price__c,ASE_Product__c,Discounted_Percentage__c FROM Opportunity WHERE Id IN : optySet];
                Admin_Control__c admin = [Select ASE_Auto_Approved__c,Discounted_Percentage__c,Mobility_Discunted_Percentage__c From Admin_Control__c Limit 1]; 
                AggregateResult[] groupedResults = [SELECT Deal__c,SUM(MACD_Price_Compare__c)MACDPriceCompare, SUM(List_Price__c) ListPrice,SUM(one_time_revenue__c) OTCPrice, SUM(Discounted_Price__c) DiscountedPrice, SUM(One_Time_Revenue_Discount_Price__c) OTCDiscountPrice FROM SPProduct__c WHERE Deal__c IN : optySet GROUP BY Deal__c];
                if( !groupedResults.isEmpty()&& groupedResults!=null )
                {
                    for( Opportunity opty: updatableOppties )
                    {
                        for( AggregateResult agr:groupedResults )
                        {
                            if( agr.get('Deal__c')==opty.Id )
                            {
                                opty.Cumulative_OTC_Discount_Price__c = (Decimal)agr.get('OTCDiscountPrice');
                                //opty.Discounted_Price__c = (Decimal)agr.get('DiscountedPrice');
                                
                                opty.Cumulative_List_Price__c =(Decimal)agr.get('ListPrice');
                                if(opty.discount_amount__c!=null){
                                 opty.Discounted_Price__c= opty.Cumulative_List_Price__c-opty.discount_amount__c;
                                }else{
                                opty.Discounted_Price__c = (Decimal)agr.get('DiscountedPrice');
                                }
                                opty.Cumulative_OTC_Price__c =(Decimal)agr.get('OTCPrice');
                                opty.MACD_growth__c = (Decimal)agr.get('MACDPriceCompare');
                                //ASE Products Auto Approved
                                if( opty.ASE_Product__c && admin.ASE_Auto_Approved__c && opty.StageName==SIConstants.PROD_DEAL_REG_REQ && !opty.ATOM_Deal__c ){
                                    opty.StageName=SIConstants.OPTY_DEAL_APPROVED;
                                    opty.Discounted_Percentage__c=admin.Discounted_Percentage__c;
                                }
                                if( opty.X3rd_Party_Flag__c )
                                {
                                    if( opty.Mobility__c )                                  
                                    {
                                        opty.Discounted_Percentage__c = admin.Mobility_Discunted_Percentage__c;
                                    }
                                    else
                                    {
                                        opty.Discounted_Percentage__c= admin.Discounted_Percentage__c;
                                    }
                                }
                                
                            }
                        }
                    }
                    try{
                        update updatableOppties;
                    } Catch(DMLException ex){
                        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
                    }
                }               
            }
        }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }
    
    /*
        Name: updatePricingFieldsAfterDeletion
        Description: This is to update the Deal Pricing fields after deleting a product.
    */
    public void updatePricingFieldsAfterDeletion(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap)
    {
       try{ 
        list <SPProduct__c> prodList = oldObjects;
        list <Opportunity> optyList = new list <Opportunity>();
        set <Id> optySet = new set <Id>();
        if(!prodList.isEmpty() && prodList!= null)
        {
            for(SPProduct__c prod : prodList)
            {
                optySet.add(prod.Deal__c);
                
            }
            
            if(!optySet.isEmpty() && optySet!=null && optySet.size() > 0)
            {
                optyList = [SELECT Id,Cumulative_List_Price__c, Discounted_Price__c, Cumulative_OTC_Discount_Price__c, Cumulative_OTC_Price__c from Opportunity where Id IN :optySet];
                
                for(Opportunity opty : optyList)
                {
                    opty.Cumulative_List_Price__c = 0;
                    opty.Discounted_Price__c=0;
                    opty.Cumulative_OTC_Discount_Price__c =0;
                    opty.Cumulative_OTC_Price__c =0;
                }
                AggregateResult[] groupedResults = [SELECT Deal__c, SUM(List_Price__c) ListPrice, SUM(one_time_revenue__c) OTCPrice, SUM(One_Time_Revenue_Discount_Price__c) OTCDiscountPrice, SUM(Discounted_Price__c) DiscountedPrice FROM SPProduct__c sp WHERE sp.Deal__c IN : optySet GROUP BY sp.Deal__c];
                
                if(!groupedResults.isEmpty() && groupedResults != null)
                {
                    for(Opportunity opty: optyList)
                    {
                        for(AggregateResult agr: groupedResults)
                        {
                            if(agr.get('Deal__c')== opty.Id)
                            {
                                opty.Cumulative_List_Price__c = (Decimal)agr.get('ListPrice');
                                opty.Discounted_Price__c=(Decimal)agr.get('DiscountedPrice');
                                opty.Cumulative_OTC_Discount_Price__c =(Decimal)agr.get('OTCDiscountPrice');
                                opty.Cumulative_OTC_Price__c =(Decimal)agr.get('OTCPrice');
                            }
                        }
                    }
                }
                try{
                    update optyList;
                } Catch(DMLException exe){
                    exe.getMessage();
                }
            }
        }
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }
    
    /*Name:
      Description:updateProductPricingOnDealStatusChange   
    */
    public void updateProductPricingOnDealStatusChange(SObject[] oldObjects,SObject[] newObjects, Map<Id, SObject>  oldObjectsMap)
    {
      try{  
        list <SPProduct__c> oldList =oldObjects;
        list <SPProduct__c> newList = newObjects;
        list <Product_Pricing__c> pricingList = new list <Product_Pricing__c>();
        set<Id> prodIds = new set <Id>();
        for(Integer i=0;i<newList.size();i++ )
        {
            if(oldList[i].Deal_Status__c != newList[i].Deal_Status__c && (newList[i].Deal_Status__c==SIConstants.PROD_DEAL_REG_APP_WITHOUT_DIS || newList[i].Deal_Status__c==SIConstants.PROD_DEAL_REG_APP_WITH_DIS) && newList[i].Record_Type_Name__c!=SIConstants.PROD_Attwireless)
            {
                prodIds.add(newList[i].Id);
            }
        }
        
        if(!prodIds.isEmpty() && prodIds!= null && prodIds.size() > 0 )
        {
            pricingList=[SELECT Id,Deal_Id__c ,SP_Product__c,Type__c,Discountable__c,List_Price__c,discount_price__c,Discounted_Price__c,Record_Type__c,Usage_Charges__c,Discounted_Usage_Charge__c,X3rd_Party_Flag__c,Clear_Special_Pricing__c FROM Product_Pricing__c WHERE SP_Product__c IN :prodIds AND (Type__c =:SIConstants.TYPE_NRC OR Type__c =:SIConstants.TYPE_MRC OR Type__c= :SIConstants.TYPE_MUC)];
            if(!pricingList.isEmpty() && pricingList != null)
            {
                list <Product_Pricing__c> updateDiscount = SIHelper.calculateDiscountonProductPricingRecords(pricingList);
                if(!updateDiscount.isEmpty() && updateDiscount != null)
                {
                    update updateDiscount;
                }
            }           
        }
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }
    
   /*Name:updateEBMDiscountPlanId
     Descrition:
   */
   //API Code
    public void  updateEBMDiscountPlanId(SObject[] newObjects)
    {
      try{  
        List<SPProduct__c> discountSPProductList=newObjects;
        List<Rate_PHI__c> rateList=new List<Rate_PHI__c>();
        Set<String> sptierlist=new Set<String>();
        Set<Integer> sptermlist=new Set<Integer>();
        Set<String> sprecordtypenames=new Set<String>();
        
        for(SPProduct__c spp:discountSPProductList){
            if((spp.Deal_Status__c == SIConstants.dealstatus  && spp.API_Flag__c)
               ||(spp.Deal_Stage_on_Product__c == SIConstants.dealstatus  && spp.API_Flag__c)
               ||(spp.Deal_Status__c==SIConstants.OPP_STAGE_ORDER_SUB  && spp.X3rd_Party_Flag__c)
               ||(spp.Deal_Stage_on_Product__c==SIConstants.OPP_STAGE_ORDER_SUB  && spp.X3rd_Party_Flag__c)){
                // Added OR Condition 
                if(spp.Term_Length_Value__c!=NULL){
                    Integer myInt = Integer.valueOf(spp.Term_Length_Value__c );
                    sptermlist.add(myInt);
                }
                if(spp.Tier__c!=NULL){
                    sptierlist.add(spp.Tier__c);
                }
                if(spp.Record_Type_Name__c !=NULL){
                    sprecordtypenames.add(spp.Record_Type_Name__c);
                }
            }
        }
        
        if (sptermlist.size()>0&&sptierlist.size()>0&&sprecordtypenames.size()>0 && sptermlist!=NULL){
            rateList=[select Id,RecordType.Name,Rate_Plan_ID__c,Discount_Id__c,Tier__c,Term__c,Service_Type__c,Version__c,Effective_Date__c from Rate_PHI__c WHERE (RecordType.Name=:UtilityConstant.BLANKETDISCOUNT) OR (Tier__c IN:sptierlist and Term__c IN:sptermlist and RecordType.Name=:UtilityConstant.MASTERRATECARD and Service_Type__c IN:sprecordtypenames)];
        }
        if (rateList.size()>0 && discountSPProductList.size()>0){
            try{
                for(SPProduct__c spp:discountSPProductList){
                    for(Rate_PHI__c rp:rateList){
                        if(rp.RecordType.Name == SIConstants.blanketdiscount){
                            spp.EBM_Discount_Plan_ID__c=rp.Rate_Plan_ID__c;
                        }
                        if(spp.Tier__c == rp.Tier__c && spp.Term_Length_Value__c == rp.Term__c && spp.Record_Type_Name__c == rp.Service_Type__c  && rp.RecordType.Name == SIConstants.masterratecard){  
                            if(rp.Rate_Plan_ID__c!=NULL && spp.Rate_Plan_ID__c == null){
                                spp.Rate_Plan_ID__c=rp.Rate_Plan_ID__c;
                            }
                            if(rp.Effective_Date__c!=NULL && spp.Rate_Card_Effective_Date__c == null){
                                spp.Rate_Card_Effective_Date__c=rp.Effective_Date__c.Date().format();
                            }                               
                        }
                    }
                }
            }catch(Exception ex){
                ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            }     
        }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }
    
    /*
    Name:updateEBMCompetitiveDiscountPlanID
    Description:API code
    */
    public void updateEBMCompetitiveDiscountPlanID(SObject[] oldObjects, SObject[] newobjects)
    {
       try{ 
        List<SPProduct__c> splist=newobjects;
        List<SPProduct__c> spOldList=oldObjects;
        Set<String> dealNames=new Set<String>();
        Set<String> spIdLst=new Set<String>();
        Set<String> spRateLst=new Set<String>();
        List<Rate_PHI__c> ratephilist=new List<Rate_PHI__c>();
        List<Product_Pricing__c> productpricelist=new List<Product_Pricing__c>();
        Set<Product_Pricing__c> pricingList=new Set<Product_Pricing__c>();
        List<Product_Pricing__c> prilist=new List<Product_Pricing__c>();
        Set<Integer> spterm=new Set<Integer>();
        Set<String> sptier=new Set<String>();
        Set<Id> rateIdsLst=new Set<Id>();
        List<Rates__c> ratepbiList=new List<Rates__c>();
        Set<String> sprecordnamess=new Set<String>();
        List<Opportunity> opprecords=new List<Opportunity>();
        Map<Id,Opportunity> opptyrecordsmap=new  Map<Id,Opportunity>();
        boolean productpriceone=false;
        boolean productpricetwo=false;
        
        for(Integer i=0; i<splist.size();i++)        
        {                 
            if(splist[i].Competitive_Pricing_Status__c!=null && splist[i].Competitive_Pricing_Status__c == SIConstants.PROD_COMP_PRI_APP && spOldList[i].Competitive_Pricing_Status__c!=splist[i].Competitive_Pricing_Status__c && splist[i].SP_Discount_Percentage__c!=null && splist[i].SP_Discount_Percentage__c!=0)
            { 
                
                Integer myInt1 = Integer.valueOf(splist[i].Term_Length_Value__c);                    
                spIdLst.add(splist[i].Id);                       
                spterm.add(myInt1 );            
                sptier.add(splist[i].Tier__c);            
                sprecordnamess.add(splist[i].Record_Type_Name__c);            
                dealNames.add(splist[i].Deal__c);           
            }
        }  
        
        if(spIdLst.size()>0 && spterm.size()>0 && sprecordnamess.size()>0)
        {           
            ratephilist=[select Id,RecordType.Name,Discount_Id__c,Rate_Plan_ID__c,Tier__c,Term__c,Service_Type__c from Rate_PHI__c WHERE (RecordType.Name=:UtilityConstant.ACCESSDISCOUNT) OR (RecordType.Name=:UtilityConstant.PORTDISCOUNT) OR (RecordType.Name=:UtilityConstant.FEATUREDISCOUNT)];
        }             
        if(spIdLst.size()>0)
        {
            productpricelist=[select Id,Product_Pricing__c.Record_Type__c,Product_Pricing__c.SP_Product__r.API_Flag__c,Product_Pricing__c.SP_Product__r.Term_Length_Value__c,Product_Pricing__c.SP_Product__r.X3rd_Party_Flag__c,Product_Pricing__c.PBI_Number__c,Product_Pricing__c.SP_Product__r.Record_Type_Name__c,Product_Pricing__c.SP_Product__r.Tier__c,Product_Pricing__c.SP_Product__r.Term_Length__c,Product_Pricing__c.SP_Product__r.SP_Discount_Percentage__c,Product_Pricing__c.SP_Product__r.Rate_Plan_ID__c,Product_Pricing__c.SP_Product__r.Competitive_Pricing_Status__c,Product_Pricing__c.SP_Discount_Percentage__c,Product_Pricing__c.EBM_Competitive_Discount_Plan_ID__c from Product_Pricing__c WHERE SP_Product__c IN:spIdLst];
        }
        
        if(ratephilist.size()>0)
        {
            for(Rate_PHI__c rpo:ratephilist)
            {
                rateIdsLst.add(rpo.Id); 
            }
        }
        
        if(rateIdsLst.size()>0){   
            ratepbiList=[select Id,Rates__c.Rate_PHI__r.Discount_Plan_Status__c,Rates__c.Rate_PHI__r.Rate_Plan_Name__c,Rates__c.Rate_PHI__r.Rate_Plan_ID__c,Rates__c.PBI_Name__c,Rates__c.PBI_Number__c, Rates__c.Rate_PHI__r.Term__c,Rates__c.Rate_PHI__r.Tier__c,Rates__c.Rate_PHI__r.Service_Type__c from Rates__c WHERE Rate_PHI__c IN:rateIdsLst and Rates__c.Rate_PHI__r.RecordType.Name=:UtilityConstant.FEATUREDISCOUNT];   
        }     
        
        if(ratephilist.size()>0 && productpricelist.size()>0){  
            for(Product_Pricing__c proprig:productpricelist)
            {
                for(Rate_PHI__c rphi:ratephilist)
                {
                    
                    if(proprig.SP_Product__r.Competitive_Pricing_Status__c == SIConstants.PROD_COMP_PRI_APP && proprig.SP_Product__r.SP_Discount_Percentage__c!=NULL && proprig.SP_Product__r.SP_Discount_Percentage__c!=0.0 && rphi.RecordType.Name == SIConstants.accessdiscount && rphi.Rate_Plan_ID__c!=NULL && proprig.SP_Product__r.API_Flag__c ==true && proprig.Record_Type__c==SIConstants.product_pricing_access && proprig.SP_Discount_Percentage__c!=NULL && proprig.SP_Discount_Percentage__c!=0)
                    {
                        
                        proprig.EBM_Competitive_Discount_Plan_ID__c=rphi.Rate_Plan_ID__c;
                        
                        pricingList.add(proprig);
                        
                        productpriceone=true;
                    }
                    if(proprig.SP_Product__r.Competitive_Pricing_Status__c == SIConstants.PROD_COMP_PRI_APP && proprig.SP_Product__r.SP_Discount_Percentage__c!=NULL && proprig.SP_Product__r.SP_Discount_Percentage__c!=0.0 && rphi.RecordType.Name == SIConstants.portdiscount && rphi.Rate_Plan_ID__c!=NULL && proprig.SP_Product__r.API_Flag__c==true && proprig.Record_Type__c==SIConstants.product_pricing_port &&  proprig.SP_Discount_Percentage__c!=NULL && proprig.SP_Discount_Percentage__c!=0)
                    {
                        proprig.EBM_Competitive_Discount_Plan_ID__c=rphi.Rate_Plan_ID__c;
                        pricingList.add(proprig);
                        productpriceone=true;
                    }
                    
                }
            }
        }  
        if(pricingList.size()>0){   
            for(Product_Pricing__c pi:pricingList)
            {
                prilist.add(pi);   
            }
        }   
        if(prilist.size()>0){
            if(productpriceone == true){   
                try{
                    update prilist;   
                }Catch(DMLException e){ 
                    e.getMessage(); 
                } 
            }
        }
        Set<Product_Pricing__c> pprSet=new Set<Product_Pricing__c>();
        Map<Id,Product_Pricing__c> pprMap=new Map<Id,Product_Pricing__c>();
        
        if(productpricelist.size()>0 && ratepbiList.size()>0){
            
            for(Product_Pricing__c ppci:productpricelist)
            {
                for(Rates__c rpb:ratepbiList)
                {  
                   
                    if(ppci.PBI_Number__c == rpb.PBI_Number__c && ppci.SP_Product__r.Competitive_Pricing_Status__c == SIConstants.PROD_COMP_PRI_APP && rpb.Rate_PHI__r.Rate_Plan_ID__c!=NULL && ppci.Record_Type__c==SIConstants.product_pricing_feature && ppci.SP_Product__r.SP_Discount_Percentage__c!=NULL && ppci.SP_Product__r.SP_Discount_Percentage__c!=0.0 && rpb.Rate_PHI__r.Discount_Plan_Status__c == SIConstants.API_RatePHI_Discountplan_Success &&  rpb.Rate_PHI__r.Rate_Plan_Name__c != SIConstants.API_RatePHI_Name_EBM_Competitive_Feature &&  ppci.SP_Discount_Percentage__c!=NULL && ppci.SP_Discount_Percentage__c!=0)
                    {
                        
                        ppci.EBM_Competitive_Discount_Plan_ID__c=rpb.Rate_PHI__r.Rate_Plan_ID__c;
                        
                        pprMap.put(ppci.id,ppci);
                        productpricetwo=true;
                      
                        break;
                    }
                    else if(ppci.PBI_Number__c == rpb.PBI_Number__c && ppci.SP_Product__r.Competitive_Pricing_Status__c == SIConstants.PROD_COMP_PRI_APP && rpb.Rate_PHI__r.Rate_Plan_ID__c!=NULL && ppci.Record_Type__c==SIConstants.product_pricing_feature && ppci.SP_Product__r.SP_Discount_Percentage__c!=NULL && ppci.SP_Product__r.SP_Discount_Percentage__c!=0.0 && rpb.Rate_PHI__r.Rate_Plan_Name__c == SIConstants.API_RatePHI_Name_EBM_Competitive_Feature && ppci.SP_Discount_Percentage__c!=NULL && ppci.SP_Discount_Percentage__c!=0)// && EBMCheckValue==false)
                    {
                        
                        ppci.EBM_Competitive_Discount_Plan_ID__c=rpb.Rate_PHI__r.Rate_Plan_ID__c;
                        pprMap.put(ppci.id,ppci);
                        productpricetwo=true;
                        break;
                    }
                }
            }  
        } 
        
        if (pprMap.size()>0){
            try{ 
                update pprMap.values();
            }Catch(DMLException e){
                e.getMessage();
            }
        }
       }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }       
    }
    
    /*
    Name:updateEBMDiscountPlanAssignmentStatus
    Description: populating EBM DiscountPlan Assignment Status on Opportunity and SPProduct when Deal Status on SPProduct is UtilityConstant.PRICINGSCHEDULE_REQUESTED and API Flag is true      
    */
    public void updateEBMDiscountPlanAssignmentStatus(SObject[] oldObjects,SObject[] newobjects)
    {
       try{ 
        List<SPProduct__c> spnewList=newobjects;
        List<SPProduct__c> spoldList=oldObjects;
        Set<Id> spDealset=new Set<Id>();
        Set<Id> spidsset=new Set<Id>();
        List<Opportunity> opplist=new List<Opportunity>();
        List<Product_Pricing__c> pplist=new List<Product_Pricing__c>();
        Map<Id,Opportunity> opptyrecordsmap=new  Map<Id,Opportunity>();
        for(Integer i=0;i<spnewList.size();i++)
        {
            if(spnewList[i].Deal_Status__c==SIConstants.dealstatus  && spoldList[i].Deal_Status__c!=spnewList[i].Deal_Status__c && spnewList[i].API_Flag__c==true)
            {
                
                spDealset.add(spnewList[i].Deal__c);
                spidsset.add(spnewList[i].Id);  
            }
            else if(spoldList[i].Deal_Stage_on_SP__c!=spnewList[i].Deal_Stage_on_SP__c && spnewList[i].Deal_Stage_on_SP__c==SIConstants.dealstatus && spnewList[i].API_Flag__c==true)
            {
                spDealset.add(spnewList[i].Deal__c);
                spidsset.add(spnewList[i].Id);   
            }   
        }
        
        if(spDealset.size()>0)
        {
            opplist=[select Id,EBM_Discount_Plan_Assignment_Status__c,API_Flag__c from opportunity WHERE Id IN:spDealset];  
        }
        
        if(spidsset.size()>0)
        {
            pplist=[select Id,Product_Pricing__c.SP_Product__r.Deal__r.API_Flag__c,Product_Pricing__c.SP_Product__c,Product_Pricing__c.EBM_Competitive_Discount_Plan_ID__c,Product_Pricing__c.SP_Product__r.EBM_Discount_Plan_ID__c,Product_Pricing__c.SP_Product__r.Deal__c,Product_Pricing__c.SP_Discount_Percentage__c from Product_Pricing__c WHERE SP_Product__c IN:spidsset AND Discountable__c=false AND SP_Discount_Percentage__c!=NULL AND SP_Discount_Percentage__c!=0 AND Product_Pricing__c.SP_Product__r.API_Flag__c=true]; 
            
        }
        if(opplist.size()>0 && pplist.size()>0)
        {
            for(Opportunity oppty:opplist)
            {
                for(Product_Pricing__c prpr:pplist)
                {
                   
                    if(oppty.Id==prpr.SP_Product__r.Deal__c && prpr.EBM_Competitive_Discount_Plan_ID__c!=NULL && prpr.SP_Discount_Percentage__c!=NULL && prpr.SP_Discount_Percentage__c!=0 && prpr.SP_Product__r.EBM_Discount_Plan_ID__c!=NULL)
                    {
                        oppty.EBM_Discount_Plan_Assignment_Status__c=SIConstants.discountplansuccess;  
                        opptyrecordsmap.put(oppty.Id,oppty);
                        
                    }
                    else If(oppty.Id==prpr.SP_Product__r.Deal__c && prpr.SP_Discount_Percentage__c!=NULL && prpr.SP_Discount_Percentage__c!=0 && (prpr.SP_Product__r.EBM_Discount_Plan_ID__c==NULL || prpr.EBM_Competitive_Discount_Plan_ID__c==NULL))
                    {
                        
                        oppty.EBM_Discount_Plan_Assignment_Status__c=SIConstants.discountplanfailed;
                        opptyrecordsmap.put(oppty.Id,oppty);
                        break;  
                    }                         
                }
            }                
        }
        
        if(opptyrecordsmap.size()>0)
        {
            try
            {
                update opptyrecordsmap.values();
            }
            Catch(Exception e)
            {
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
        
        if(pplist.size()>0)
        {
            for(Integer i=0;i<spnewList.size();i++)
            {
                for(Product_Pricing__c pr:pplist)
                {    
                    
                    boolean emptyebm=false;
                    if(spnewList[i].Id == pr.SP_Product__c && (spnewList[i].Deal_Status__c==SIConstants.dealstatus || spnewList[i].Deal_Stage_on_SP__c==SIConstants.dealstatus) &&  pr.EBM_Competitive_Discount_Plan_ID__c!=NULL && pr.SP_Discount_Percentage__c!=NULL && pr.SP_Discount_Percentage__c!=0 && pr.SP_Product__r.EBM_Discount_Plan_ID__c!=NULL && pr.SP_Product__r.Deal__r.API_Flag__c == true) 
                    {
                        spnewList[i].EBM_Discount_Plan_Assignment_Status_p__c=SIConstants.discountplansuccess;
                        emptyebm=true;    
                    }
                    else If(spnewList[i].Id == pr.SP_Product__c && (spnewList[i].Deal_Status__c==SIConstants.dealstatus || spnewList[i].Deal_Stage_on_SP__c==SIConstants.dealstatus) && pr.SP_Discount_Percentage__c!=NULL && pr.SP_Discount_Percentage__c!=0 && (pr.SP_Product__r.EBM_Discount_Plan_ID__c==NULL ||  pr.EBM_Competitive_Discount_Plan_ID__c==NULL) && emptyebm==false && pr.SP_Product__r.Deal__r.API_Flag__c == true) 
                    {  
                        
                        spnewList[i].EBM_Discount_Plan_Assignment_Status_p__c=SIConstants.discountplanfailed;
                        break;
                    }
                    
                }
            }
        } 
       }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }       
    }
    //API Code
/* 
 Name: updateOpportunityfields
 Description: 
 */ 
    public void updateOpportunityfields(SObject[] newobjects){
        
     try{   
        List<SPProduct__c> spproductList=newobjects;
        Set<Id> spIdList=new Set<Id>(); //this set will hold all SPProducts Id's those record which is referenced by trigger.new(here it is newobjects)
        Set<String> spDealList=new Set<String>();// this will hold all Deal Id's.
        List<Opportunity> oppListforHoldingValues=new List<Opportunity>();
        Set<Opportunity> addOpptyListSet= New Set<Opportunity>();
        List<Opportunity> opptyListToUpdate= New List<Opportunity>();
        List<SPProduct__c> spProd = new List<SPProduct__c>();
        
        for(SPProduct__c spc:spproductList)
        {     
            if((spc.Deal_Status__c == SIConstants.dealstatus  && spc.API_Flag__c)||(spc.Deal_Status__c==SIConstants.OPP_STAGE_ORDER_SUB  && spc.X3rd_Party_Flag__c) || spc.IsPricingScheduleRequested__c==true){
                spIdList.add(spc.Id);
                spDealList.add(spc.Deal__c); 
                spProd.add(spc);
            }
        }
        if(spDealList.size()>0){
            List<Opportunity>  opp = [select Id,ATOM_Deal__c,Deal_Status__c,Rate_Card_Effective_Date__c,StageName,X3rd_Party_Flag__c,Rate_Plan_ID__c,Rate_Stability_Date__c from Opportunity WHERE Id IN:spDealList];
           if(opp!=null && opp.size()>0 ){ 
            for(SPProduct__c spr :spProd)
            {
                for(Opportunity oppi :opp)
                {
                    if(spr.Deal__c == oppi.Id && spr.Deal_Status__c!=NULL &&( spr.Deal_Status__c == SIConstants.dealstatus || spr.API_Flag__c==true || spr.X3rd_Party_Flag__c ) && spr.Rate_Plan_ID__c!=NULL && spr.Rate_Stability_Date__c!=NULL)
                    {
                        if (spr.IsPricingScheduleRequested__c && spr.Deal_Status__c != SIConstants.dealstatus){
                            oppi.Deal_Status__c=oppi.StageName;
                        }else{
                            oppi.Deal_Status__c=spr.Deal_Status__c;
                        }
                        if(spr.Rate_Plan_ID__c != null && oppi.Rate_Plan_ID__c == null){
                            oppi.Rate_Plan_ID__c=spr.Rate_Plan_ID__c;
                        }
                        if(spr.Rate_Card_Effective_Date__c != null && oppi.Rate_Card_Effective_Date__c == null){
                            oppi.Rate_Card_Effective_Date__c=spr.Rate_Card_Effective_Date__c;
                        }
                        if(spr.Rate_Stability_Date__c != null && oppi.Rate_Stability_Date__c == null){
                            oppi.Rate_Stability_Date__c=spr.Rate_Stability_Date__c;
                        }
                        oppListforHoldingValues.add(oppi);  
                    }
                }
            }
          }  
        }
        if(oppListforHoldingValues.size()>0){ 
            addOpptyListSet.addAll(oppListforHoldingValues);
            opptyListToUpdate.addAll(addOpptyListSet);
            if (opptyListToUpdate.size()>0){    
                try{      
                    update opptyListToUpdate;   
                }catch(Exception e){
                    e.getMessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                } 
            }
        } 
     }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }
    
    /*
    Name:updateInRegionDiscount
    Description: Business logic to count IR region percentage on opportunity.
    */
    public void updateInRegionDiscount(SObject[] oldObjects,SObject[] newObjects, Boolean isInsert)
    {
      try{  
        list<SPProduct__c> oldList = oldObjects;
        list<SPProduct__c> newList = newObjects;
        set<Id> optyIds = new set<Id>();
        map<Id,Decimal> regionMap=new map<Id,Decimal>();
        map<Id,Decimal> optySPPCount = new map<Id,Decimal>();
        list<Opportunity> updateOpty = new list<Opportunity>();
        list<Opportunity> optyList = new list<Opportunity>();
        
        
        if( isInsert && newList!= null )
        {
            for(SPProduct__c spproduct : newList)
            {
                if( spproduct.Region__c == UtilityConstant.IR && spproduct.ATOM_Deal__c && (spproduct.Opportunity_Stage__c == UtilityConstant.DEALREGISTRATION_REQUESTED || spproduct.Opportunity_Stage__c == UtilityConstant.DEALREG_AUTO_APPROVED || spproduct.Opportunity_Stage__c == UtilityConstant.DEALREGISTRATION_APPROVED) )
                {
                    optyIds.add(spproduct.Deal__c);
                }
            }
        }
        else if( !isInsert &&  newList!= null )
        {
            for(Integer i=0; i<newList.size(); i++)
            {
                if( newList[i].Opportunity_Stage__c == UtilityConstant.DEALREGISTRATION_REQUESTED || newList[i].Opportunity_Stage__c == UtilityConstant.DEALREG_AUTO_APPROVED || newList[i].Opportunity_Stage__c == UtilityConstant.DEALREGISTRATION_APPROVED)
                {
                    optyIds.add(newList[i].Deal__c);
                }
            }
        }
        if(optyIds.size()>0){
            if( optyIds!=null && optyIds.size() > 0 )
            {
                optyList = [select Id, In_Region__c,StageName from Opportunity where Id IN :optyIds];
                AggregateResult[] groupedResSPProductCount = [select count(Id) countsp, Deal__c deal from SPProduct__c where Deal__c IN :optyIds  group by deal__c];
                AggregateResult[] groupedResSPProductIRCount = [select count(Id) countIR, Deal__c deal from SPProduct__c where Deal__c IN :optyIds and Region__c=: UtilityConstant.IR  group by deal__c];
                
                if(groupedResSPProductCount != null)
                {
                    for(AggregateResult agrIRCount: groupedResSPProductIRCount)
                    {
                        if( agrIRCount.get('countIR') != null )
                        {
                            regionMap.put((Id)agrIRCount.get('deal'),(Decimal)agrIRCount.get('countIR') );
                        }
                    }
                    for(AggregateResult agrSPPCount: groupedResSPProductCount)
                    {
                        if( agrSPPCount.get('countsp') != null )
                        {
                            optySPPCount.put((Id)agrSPPCount.get('deal'),(Decimal)agrSPPCount.get('countsp'));
                        }
                    }
                    
                    
                    for(Opportunity op: optyList)
                    {
                        if(optySPPCount.get(op.Id)!=0)
                        {
                            if(regionMap.get(op.Id)==null)
                            {
                                op.In_Region__c = ((0/optySPPCount.get(op.Id))*100);
                                updateOpty.add(op);
                            }
                            else
                            {
                                op.In_Region__c = ((regionMap.get(op.Id)/optySPPCount.get(op.Id))*100);
                                updateOpty.add(op);
                            }
                        }
                    }
                    if( updateOpty.size() > 0 )
                    {
                        update updateOpty;
                    }
                }
            }
        }
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }
    //This method is for updating SubAccount & RDS Version during MACD Add
/* 
 Name: macdASubAccInsert
 Description: 
 */ 
    public void macdASubAccInsert(SObject[] newObjects){
        try{  
            List<SPProduct__c> spProdList = newObjects;
            Set<String> macdOpptyIds = new Set<String>();
            Map<String,Opportunity> masterMACDOpptyDealMap = new Map<String,Opportunity>();
            Map<String,SPProduct__c> subAccMasterDealMap = new Map<String,SPProduct__c>();
            Map<String,SPProduct__c> masterDealSubAccMap = new Map<String,SPProduct__c>();
            Map<String, String> dealSubMap = new Map<String, String>();
            
            for(SPProduct__c s : spProdList){
                if(s.Sub_Account__c == null || s.Sub_Account__c ==SpecialCharacterConstant.CONCAT){
                    macdOpptyIds.add(s.Deal__c);
                }
            }
            
            if(macdOpptyIds.size()>0){
                for(Opportunity o : [Select Id, Master_deal_number__c, RDS_Version__c from Opportunity where Id =: macdOpptyIds AND MACD_Type__c=:SIConstants.MACDTYPEA]){
                    if(o.Master_deal_number__c !=null || o.Master_deal_number__c !=SpecialCharacterConstant.CONCAT){    
                        masterMACDOpptyDealMap.put(o.Master_deal_number__c,o);
                    }
                }
            }
            
            if(masterMACDOpptyDealMap.size()>0){
                for(SPProduct__c spp : [Select Sub_Account__c, Master_Deal_Reg_Number__c, RDS_Version__c From SPProduct__c where  Master_Deal_Reg_Number__c =: masterMACDOpptyDealMap.keyset()]){
                    if(spp.Sub_Account__c != null || spp.Sub_Account__c != SpecialCharacterConstant.CONCAT){
                        subAccMasterDealMap.put(spp.Sub_Account__c,spp);
                    }
                }
            }
            
            if(subAccMasterDealMap.size()>0){
                for(SPProduct__c sp : subAccMasterDealMap.values()){
                    masterDealSubAccMap.put(sp.Master_Deal_Reg_Number__c, sp);
                }
            }
            
            if(masterDealSubAccMap.size()>0){
                for(Opportunity op : masterMACDOpptyDealMap.values()){
                    for(SPProduct__c spp : spProdList){
                        if(op.Id == spp.Deal__c){
                            spp.Sub_Account__c = masterDealSubAccMap.get(op.Master_deal_number__c).Sub_Account__c;
                            spp.RDS_Version__c = op.RDS_Version__c;
                        }
                    }
                }
            }
        }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        } 
    }
    
 
    //Logic to populate MACD Price compare field on MACD Change SP Product
/* 
 Name: populatePriceCompare
 Description: 
 */ 
    public void populatePriceCompare(SObject[] newobjects) {
        List<SPProduct__c> macdSpProductList = newobjects;
        Set<string> siteIDs = new Set<string>();
        List<SPProduct__c> oldSpProductList = new List<SPProduct__c>();
        map<string,SPProduct__c> siteIdToPrevSpProductMap = new map<string,SPProduct__c>();
        try{
            for(SPProduct__c MACDSp : macdSpProductList){
                if( MACDSp.MACD_Type__c == UtilityConstant.C && MACDSp.Site_ID__c != null && (MACDSp.Discounted_Price__c != null || MACDSp.List_Price__c != null)){
                    siteIDs.add(MACDSp.Site_ID__c);
                }
            }
            
            if(siteIDs != null && siteIDs.size() > 0){
                oldSpProductList = [Select id,Discounted_Price__c,List_Price__c,RDS_Version__c,Site_ID__c from SPProduct__c where (Site_ID__c =:siteIDs) AND Deal__r.StageName=: UtilityConstant.ORDERSUBMITTED];
            }
            
            if(oldSpProductList != null && oldSpProductList.size() > 0){
                for(SPProduct__c oldSp : oldSpProductList){
                    SPProduct__c tempSp = null;
                    if(siteIdToPrevSpProductMap != null){
                        tempSp = siteIdToPrevSpProductMap.get(oldSp.Site_ID__c);
                    }
                    if( tempSp == null || ( tempSp != null && oldSp.RDS_Version__c > tempSp.RDS_Version__c )){                  
                        siteIdToPrevSpProductMap.put(oldSp.Site_ID__c, oldSp);
                    }
                }   
            }
            for(SPProduct__c MACDSp : macdSpProductList){
                SPProduct__c prevSpProduct;
                if(MACDSp.Site_ID__c != null){
                    prevSpProduct = siteIdToPrevSpProductMap.get(MACDSp.Site_ID__c);
                }
                if(prevSpProduct != null ){
                    MACDSp.MACD_Price_Compare__c = getPriceDiff(MACDSp, prevSpProduct);
                }
            }
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }     
    }
    
/* 
 Name: getPriceDiff
 Description: 
 */ 
    public decimal getPriceDiff(SPProduct__c macdSpProd, SPProduct__c prevSpProd){
        decimal prevSpProdFinalPrice = null;
        decimal macdSpProdFinalPrice = null;
        decimal difference;
        try{
            if( macdSpProd.Discounted_Price__c != null){
                macdSpProdFinalPrice = macdSpProd.Discounted_Price__c;
            }else if( macdSpProd.List_Price__c != null ){
                macdSpProdFinalPrice = macdSpProd.List_Price__c;
            }
            
            if( prevSpProd.Discounted_Price__c != null){
                prevSpProdFinalPrice = prevSpProd.Discounted_Price__c;
            }else if( prevSpProd.List_Price__c != null ){
                prevSpProdFinalPrice = prevSpProd.List_Price__c;
            }
            
            if( macdSpProdFinalPrice != null && prevSpProdFinalPrice != null ){
                difference = macdSpProdFinalPrice - prevSpProdFinalPrice;
            }else{
                difference = null;  
            }
            return difference;
        }
        catch(exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }
    }
    
    /****Method to call create share method for all SP Users' access to SP Products****/
    
/* 
 Name: createSharingrule
 Description: 
 */ 
     public static void createSharingrule(SObject[] newObjects){
        try{
        List<SPProduct__c> spProdList = newObjects; 
        Map<Id,Id> sObjRecordIds = new Map<Id,Id>();
        for(Spproduct__c sp: spProdList){
            if(!String.isEmpty(sp.Deal_Account_Id__c)){
            sObjRecordIds.put(sp.Id,sp.Deal_Account_Id__c);
            }
        }

        if(sObjRecordIds.size()>0){
            SIHelper.createSPSharingPartnerRule(SIConstants.SP_PRODUCT_SHARE,sObjRecordIds);
            }
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e)); 
        }
     }
     
     /*Name:updatePrice
     Description: 
     */ 
    public void updatePrice(List<SPProduct__c>  spProductList, Set<String> SPSetASE){
    
        Set<String> quoteIdSet = new Set<String>();
        Set<String> optyIdSet = new Set<String>();
        Set<String> siteIdSet = new Set<String>();
        Set<String> custSiteIdSet = new Set<String>();
        Map<String,SPProduct__c> SPMap = new Map<String,SPProduct__c>();
        List<Product_Pricing__c> ppUpdateList = new List<Product_Pricing__c>();
        List<Product_Pricing__c> productPricingList=[select id,list_price__c,discount_price__c,discounted_price__c from Product_Pricing__c where SP_Product__c IN : SPSetASE];
       
        if(productPricingList!=null && productPricingList.size()>0){
            for(Product_Pricing__c productPricing : productPricingList){
                productPricing.list_price__c=0;
                productPricing.discount_price__c=0;
                productPricing.discounted_price__c=0;
                ppUpdateList.add(productPricing);
            }
            if(ppUpdateList != null && ppUpdateList.size() >0){
                SIConstants.allowPPTrigger = false;
              
                update ppUpdateList;
            }
        }
        SPProduct__c productClonedObj = null;
        
        for(SPProduct__c spProduct : spProductList){
            productClonedObj = spProduct.clone(true, false, true, true);
            productClonedObj.Port_Price__c=0.00;
            productClonedObj.Onsite_Install_Charges__c=0.00;
            productClonedObj.List_Price__c=0.00;
            productClonedObj.Discounted_Price__c=0.00;
            siteIdSet.add(spProduct.Site_ID__c);
            optyIdSet.add(spProduct.Deal__c);  
            SPMap.put(productClonedObj.id,productClonedObj); 
        }
        update(SPMap.values());
        AggregateResult[] groupedResults = [SELECT Deal__c, SUM(List_Price__c) ListPrice, SUM(one_time_revenue__c) OTCPrice, SUM(One_Time_Revenue_Discount_Price__c) OTCDiscountPrice, SUM(Discounted_Price__c) DiscountedPrice FROM SPProduct__c sp WHERE sp.Deal__c IN : optyIdSet GROUP BY sp.Deal__c];
        List<Opportunity> optyList = [SELECT id,Cumulative_List_Price__c,Discounted_Price__c,Cumulative_OTC_Discount_Price__c,Cumulative_OTC_Price__c from  Opportunity where id IN: optyIdSet];        
        if(!groupedResults.isEmpty() && groupedResults != null)
        {
            for(Opportunity opty: optyList)
            {
                for(AggregateResult agr: groupedResults)
                {
                    if(agr.get('Deal__c')== opty.Id)
                    {
                        opty.Cumulative_List_Price__c = (Decimal)agr.get('ListPrice');
                        opty.Discounted_Price__c=(Decimal)agr.get('DiscountedPrice');
                        opty.Cumulative_OTC_Discount_Price__c =(Decimal)agr.get('OTCDiscountPrice');
                        opty.Cumulative_OTC_Price__c =(Decimal)agr.get('OTCPrice');
                    }
                }
            }
        }
       update optyList;
    
        List<Apttus_Proposal__Proposal__c> quote=[select id from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c IN: optyIdSet];
        if(quote!=null && quote.size()>0){
            for(Apttus_Proposal__Proposal__c quo : quote){
                quoteIdSet.add(quo.id);
            }
        }
        
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = [select Apttus_QPConfig__PriceListItemId__r.Name, Apttus_Proposal__Proposal__c,Apttus_QPConfig__NetPrice__c,Managed_Router__c,Apttus_QPConfig__AdjustedPrice__c,Apttus_QPConfig__ListPrice__c from Apttus_Proposal__Proposal_Line_Item__c where  Apttus_Proposal__Proposal__c IN: quoteIdSet and AT_T_Customer_Site__c IN:custSiteIdSet];
        if(proposalLineItemList!=null && proposalLineItemList.size()>0){
            for(Apttus_Proposal__Proposal_Line_Item__c proposalLineItem : proposalLineItemList)
            {
                proposalLineItem.Apttus_QPConfig__NetPrice__c = 0.00;
                proposalLineItem.Apttus_QPConfig__ListPrice__c= 0.00;
            }
         
            update proposalLineItemList;
        }   
    
        list<Apttus_Config2__ProductConfiguration__c> prodConfig = new list<Apttus_Config2__ProductConfiguration__c>([select id, Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c IN: quoteIdSet]);
    
        if(prodConfig!=null && prodConfig.size()>0){
            List<Apttus_Config2__LineItem__c> lineItemList = [SELECT id,AT_T_Customer_Site__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c IN: prodConfig and AT_T_Customer_Site__c IN: custSiteIdSet];
            if(lineItemList!=null && lineItemList.size()>0)
            {
                for(Apttus_Config2__LineItem__c linitem : lineItemList){
                linitem.Apttus_Config2__NetPrice__c = 0.00;
                linitem.Apttus_Config2__ListPrice__c= 0.00;
                linitem.Apttus_Config2__BasePrice__c= 0.00;
                linitem.Apttus_Config2__BaseExtendedPrice__c= 0.00;
                linitem.Apttus_Config2__AdjustedPrice__c= 0.00;
                linitem.Apttus_Config2__ExtendedPrice__c= 0.00;
    
            }
          
            update lineItemList;
            }
        }
    }
    
    /*Name: updateASRStatusOnQuoteJunction
    Deescription:
    */
    public void updateASRStatusOnQuoteJunction(Set<String> optyIdSet, Set<String> spSiteNumber,Map<String,String> spASRStatusMap,Map<String,SPProduct__c> spASECircuitID){
        try {
        
        Set<String> quoteASEIdSet = new Set<String>();
        List<Apttus_Proposal__Proposal__c> quote=[select id from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c IN: optyIdSet];
        if(quote!=null && quote.size()>0){
            for(Apttus_Proposal__Proposal__c quo : quote){
                quoteASEIdSet.add(quo.id);
            }
        }
        List<AT_T_Customer_Site_Quote__c> custQuoteJunList = [SELECT id,ASR_Received_Date__c ,ASR_Processed_Date__c,ASR_Completion_Date__c ,ASE_Circuit_ID__c ,AT_T_Quote__c,Site_ID__c,AT_T_Customer_Site__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c IN: quoteASEIdSet and Site_ID__c IN: spSiteNumber for update];
        if(custQuoteJunList !=null && custQuoteJunList .size()>0){
            for(AT_T_Customer_Site_Quote__c cs : custQuoteJunList){
                if(cs.Site_ID__c != null && spASRStatusMap.containsKey(cs.Site_ID__c)){
                    if(spASRStatusMap.get(cs.Site_ID__c) == BuyflowConstant.MACD_Pending){
                        cs.ASE_MACD_Site_Status__c = BuyflowConstant.Pending_Pending;
                    }
                    else{
                        cs.ASE_MACD_Site_Status__c = spASRStatusMap.get(cs.Site_ID__c);
                        
                    }
                    SPProduct__c spProduct= spASECircuitID.get(cs.Site_ID__c);
                    if(spProduct!=null){
                    if(spProduct.ASR_Received_Date__c!=null )
                    {
                        cs.ASR_Received_Date__c = spProduct.ASR_Received_Date__c;
                    }
                    if(spProduct.ASR_Processed_Date__c!=null )
                    {
                        cs.ASR_Processed_Date__c = spProduct.ASR_Processed_Date__c;
                    }
                    if(spProduct.ASR_Completion_Date__c !=null )
                    {
                        cs.ASR_Completion_Date__c = spProduct.ASR_Completion_Date__c;
                    }
                    if(spProduct.ASE_Circuit_ID__c !=null && spProduct.ASE_Circuit_ID__c !=SpecialCharacterConstant.BLANK)
                    {
                        cs.ASE_Circuit_ID__c = spProduct.ASE_Circuit_ID__c;
                    }
                    }
                   
                }
            }
        }
        update custQuoteJunList; 
        } 
        catch(Exception e) 
        { 
            System.debug('*******exception  in updateASRStatusOnQuoteJunction*****' + e.getLineNumber()+''+e+'trace is :'+e.getStackTraceString()); 
        } 
    } 
}