/***************************************************************************************************************         
Component Name : SIOpportunityTriggerHandler 
Component Description: All Opportunity Related methods and exceution can be called from this Handeler. A generic trigger handler class for all the 
                      operations(Insert,Update,Delete and Undelete) which operates on UtilityConstant.BEFOREAFTER     
Author Name : Accenture IDC    
Version:1.0    
Created Date:12th Jan  2013     
Last Modified Date:12th Dec 2014      
Description: Code Refactoring and Condition Check for API Methods/SOQL    
Last Modified Date:2nd Dec 2014      
Description: Code Optimzation and  Addition of Constant Static for Hard Coded Values   
                        
*****************************************************************************************************************/

/* 
 Name: SITriggerOperations.SITriggerImpl
 Type: Class 
 
 Description:  
 */ 
        public with sharing class SIOpportunityTriggerHandler extends SITriggerOperations.SITriggerImpl {
              
           public boolean isExecuted ;

            
/* 
 Name: SIOpportunityTriggerHandler
 Description: Default cons
 */ 
            public SIOpportunityTriggerHandler() {
                isExecuted = true;
            }
            
            
            
/* 
 Name: onAfterUpdate
 Description:@Overridden Method.
 */ 
            public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap) {
                try{
                    
            List<Opportunity> opptList = updatedObjects;
            List<Opportunity> opptyList = new List<Opportunity>();
            List<Opportunity> autoApprovalOpptys = new List<Opportunity>();
            List<Opportunity> optyOldList =oldObjects;
            Map<id,Opportunity> oldMapOppty = new Map<id,Opportunity>();
            List<Opportunity> opptyCap29List = new List<Opportunity>();
            List<Opportunity> renewalContractOpptyList = new List<Opportunity>();
            map<id,Opportunity> createRenewalContractITSMap = new map<id, Opportunity>();
            Set<string> rdsCheckId= new set<String>();
            for(integer i=0;i<OpptList .size();i++)
            {     
             if(OptyOldList[i].ManualFlow__c!=OpptList [i].ManualFlow__c){
                
                 rdsCheckId.add(OpptList [i].id);
               }                    
               oldMapOppty.put(OptyOldList[i].Id,OptyOldList[i]); 
               //Contract Renewal ITS Support Ticket Creation
               if((OpptList[i].Renewal_Contract__c == true) && !String.isBlank(OpptList[i].API_Process_Status__c) && (OptyOldList[i].API_Process_Status__c != OpptList[i].API_Process_Status__c) && OpptList[i].API_Process_Status__c == UtilityConstant.DEAL_RATEPLAN_API_FAILED ){
                    if(!createRenewalContractITSMap.containsKey(OpptList[i].id)){
                        createRenewalContractITSMap.put(OpptList[i].id,OpptList[i]);
                    }
                }
            }
            for(Opportunity oppty : OpptList){
                if((oppty.MACD_Type__c != UtilityConstant.D && oppty.MACD_Type__c != UtilityConstant.C) || oppty.Renewal_Contract__c){
                    OpptyList.add(oppty);
                    }
                if(oppty.MACD_Type__c != UtilityConstant.D && oppty.MACD_Type__c != UtilityConstant.C && oppty.MACD_Type__c != UtilityConstant.A 
                   && oppty.StageName == SIConstants.OPTY_DEAL_REQUESTED && oppty.ATOM_Deal__c && oppty.isDealSubmitCompleted__c &&
                   (oppty.Auto_Approval_Status__c ==  UtilityConstant.APPROVEDWITH_DISCOUNT|| oppty.Auto_Approval_Status__c ==  UtilityConstant.APPROVEDWITHOUT_DISCOUNT)){
                       autoApprovalOpptys.add(oppty);
                   } 
               if(oppty.MACD_Type__c != UtilityConstant.D  && oppty.MACD_Type__c != UtilityConstant.C && oppty.MACD_Type__c != UtilityConstant.A){
                    opptyCap29List.add(oppty);
               }
            }
            if(rdsCheckId.size()>0){
            //added for manual flow check
              updateRDSDealHashManualFlow(oldObjects,updatedObjects); // added as part of API rel July 12
            }
            
            //Contract Renewal ITS Support Ticket Creation
            if(!createRenewalContractITSMap.isEmpty() && SIConstants.allowITSTicketCreation == true){
                RDSExcelExceptionHandling rdsExcelExceptionHandlingObj = new RDSExcelExceptionHandling();
                rdsExcelExceptionHandlingObj.createContractRenewalITSTicket(createRenewalContractITSMap);
                SIConstants.allowITSTicketCreation = false;
            }
            
            if(opptyCap29List.size()>0){
                try {
                    activateManualFlow(oldObjects,updatedObjects,false);
                }catch(Exception excep) {                              
                    isExecuted = false;                
                    throw excep;            
                }
            }
            if(OpptyList.size()>0){
                try {
                    List<SPProduct__c> spProductsList = lookupProductsSites(newObjectsMap,oldMapOppty);
                    takeNoteFromCommentsOnUpdate(oldObjects,updatedObjects);
                    clearSpecialPricing(oldObjects,updatedObjects);
                    if(!spProductsList.isEmpty()) {
                        String productIdLists = getProductsIds(spProductsList);
                        //updated logic to not to fire when triggered through a batch
                        if( (null != productIdLists) && (productIdLists.length() > 0) && !system.isbatch()) {
                            //Do call out/Webservice
                            //SIHelper.generateExcelCallOut(productIdLists);
                        }
                    }
                    
                    //Feb-12
                    updateDealStatus(oldObjects,updatedObjects);
                    DealStageonSP(oldObjects,updatedObjects);
                    updateDealStatus_Requested(oldObjects,updatedObjects);
                    MobilityAutomation(OldObjects,updatedObjects);
                    updateVLANDetails(updatedObjects,OldObjects);
                    updateRDSDealHashfields(oldObjects,updatedObjects); // added as part of API rel July 12
                    updatePricingSchedule(updatedObjects,oldObjects,false);
                    createDealrateCardOnDealrateSuccess(oldObjects,updatedObjects);
                    /* Promotion Engine -- Remove special pricing and apply promotions*/
                    removeSpecialPricingApplyPromotion( oldObjects, updatedObjects );
                    /* Promotion Engine-->Deal Reg Re-Request--> Re-Applying promotion logic*/
                    reApplyPromotionLogicCheck(oldObjects, updatedObjects, true );
                    /* Promotion Enigne--> Apply deal registration on opportunity along with promotions. */
                    applyDealRegPromotionDiscounts(oldObjects, updatedObjects );
                   //Call method to create RDS Excel on Oppty
                    createRDSExcelonOppty(oldObjects, updatedObjects);
                   doUpdateStatusonSPWithoutDiscount(oldObjects, updatedObjects);
                                        
                  //  if(OpptList!=null && OpptList.size()>0 && OpptList[0].StageName!='Order Submitted')
                   // {
                        doUpdateDealRegistrationDiscountPercentOnSP(oldObjects, updatedObjects); // This line was commenetd by Mallik for batbbch rate card
                       
                      
                  //  }
                    //End of Feb-12
                    createRDSAccessBillingElements(oldObjects,updatedObjects);
                    
                      
                } catch(Exception excep) {                              
        isExecuted = false;                
        throw excep;            
        }
            }
           if(autoApprovalOpptys.size()>0){
                doAutoDealRegApproval(autoApprovalOpptys);
            }
            return isExecuted;
        }
        catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
        
/* 
 Name: onBeforeUpdate
 Description: 
 */ 
        public override boolean onBeforeUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap )  {
            try{
            List<Opportunity> opptList = updatedObjects;
            List<Opportunity> opptyList = new List<Opportunity>();
                for(Opportunity oppty : OpptList){
                    if(oppty.MACD_Type__c != UtilityConstant.D && oppty.MACD_Type__c != UtilityConstant.C){
                    OpptyList.add(oppty);
                    }
                }
                if(OpptyList.size()>0){
                try {
                    
                    //Rules Engine Utility
                    String obj=UtilityConstant.OPPORTUNITY;
                    String event=SpecialCharacterConstant.STATIC_UPDATE;
                    if( label.WFEngineOpportunityFlag == SpecialCharacterConstant.TRUE_CAMEL_LITERAL ){
                        SIWFEngineUtility.getInstance().Rulescoringengine(obj,event,oldObjects,updatedObjects);
                    }
                    CheckforSharedEC(updatedObjects);
                    setDiscountFieldstoNull(oldObjects,updatedObjects);
                    setDefaultvaluesforLikelihoodtoclose(oldObjects,updatedObjects,event);
                    //settingPurchasedCloudProductFlag(oldObjects,updatedObjects);--karthik changed to Rome opportuniy
                    
                 //Quote Expiration Date from Lockin days
                 calculateExpirationDate( oldObjects, updatedObjects, true ) ;
                    
                    
                } catch(Exception excep) {                             
         isExecuted = false;               
          throw excep;          
            }
            }
                return isExecuted;
            }
            catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
            
/* 
 Name: onBeforeInsert
 Description: 
 */ 
        public override boolean onBeforeInsert(SObject[] updatedObjects)  {
            try{
            List<Opportunity> opptList = updatedObjects;
            List<Opportunity> opptyList = new List<Opportunity>();
            List<Opportunity> autoApprovalOpptys = new List<Opportunity>();      
            List<Opportunity> autoApprovalAcctOpptys = new List<Opportunity>();
            List<Account> accList = new List<Account>();
            accList = [select id, ATOM_Account__c from Account where id=: OpptList[0].AccountID limit 1]; 
            
            for(Opportunity oppty : OpptList){
                if(oppty.MACD_Type__c != UtilityConstant.D && oppty.MACD_Type__c != UtilityConstant.C){
                    OpptyList.add(oppty);
                }
                
                if(oppty.MACD_Type__c != UtilityConstant.D && oppty.MACD_Type__c != UtilityConstant.C && oppty.MACD_Type__c != UtilityConstant.A && (oppty.Service_type__c == UtilityConstant.ANIRA || (oppty.Service_type__c == UtilityConstant.AMIS && !oppty.Auto_Deal_Registration__c))){
                    autoApprovalOpptys.add( oppty ); 
                } else if(oppty.MACD_Type__c != UtilityConstant.D && oppty.MACD_Type__c != UtilityConstant.C && oppty.MACD_Type__c != UtilityConstant.A && oppty.Auto_Deal_Registration__c && oppty.PROMPT_Manual_Opportunity__c != true && accList[0].ATOM_Account__c && (oppty.Service_type__c == UtilityConstant.AMIS || oppty.Service_type__c == UtilityConstant.AVPN)) {
                     autoApprovalAcctOpptys.add( oppty ); 
                }
            }
            if(OpptyList.size()>0){
                try {
                    //Rules Engine Utility
                    String obj=UtilityConstant.OPPORTUNITY;
                    String event=UtilityConstant.STATIC_INSERT;
                    if( label.WFEngineOpportunityFlag == SpecialCharacterConstant.TRUE_CAMEL_LITERAL ){
                        SIWFEngineUtility.getInstance().Rulescoringengine(obj,event,updatedObjects,updatedObjects);
                    }
                    CheckforSharedEC(updatedObjects);           
                    setDefaultvaluesforLikelihoodtoclose(updatedObjects,updatedObjects,event);
                    updateOffCartDealName(updatedObjects);
                    updatePricingSchedule(updatedObjects,null,true);
                    macdAActions(updatedObjects);
                    updateDealRegDiscountOnMACD(updatedObjects);
                    updateAtomDealFalg(updatedObjects);
                    calculateExpirationDate( null, updatedObjects, false) ;
                     
                } catch(Exception excep) {                excep.getMessage();                isExecuted = false;                throw excep;            }
            }
            if( autoApprovalOpptys.size() > 0 ){
                populateAutoApprovalStatus( autoApprovalOpptys );
            }
            if( autoApprovalAcctOpptys.size() > 0 ){
                populateAutoApprovalAcctDealStatus( autoApprovalAcctOpptys );
            }
                
            return isExecuted;
        }
        catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
 /* 
 Name: onAfterInsert
 Description: 
 */        
        public override boolean onAfterInsert(SObject[] newObjects) 
        {
            
            List<Opportunity> opptList = newObjects;
            List<Opportunity> opptyList = new List<Opportunity>();
            List<Opportunity> opptyCap29List = new List<Opportunity>();
                for(Opportunity oppty : OpptList){
                    if(oppty.MACD_Type__c != UtilityConstant.D && oppty.MACD_Type__c != UtilityConstant.C){
                    OpptyList.add(oppty);
                    }
                    if(oppty.MACD_Type__c != UtilityConstant.D  && oppty.MACD_Type__c != UtilityConstant.C && oppty.MACD_Type__c != UtilityConstant.A){
                        opptyCap29List.add(oppty);
                    }
                }
                if(opptyCap29List.size()>0){
                    try {
                        activateManualFlow(null,opptyCap29List,true);
                    }catch(Exception excep) {                              
                        isExecuted = false;                
                        throw excep;            
                    }
                }
                if(OpptyList.size()>0){
                try 
                {
                     takeNoteFromCommentsOnInsert(newObjects);
                    /*Promotion Engine-->Deal Reg Re-Request--> Re-Applying promotion logic*/
                    reApplyPromotionLogicCheck(null,newObjects,false);
                } 
                catch(Exception excep) { 
                excep.getMessage();               
                isExecuted = false;               
                throw excep;
            }
                }
                return isExecuted;
            }
            //Method used to lookup the sites associated to the UtilityConstant.AVPN product.
        // Optimization 1 for defect 8516 
/* 
 Name: lookupProductsSites
 Description: 
 */ 
            public List<SPProduct__c>  lookupProductsSites(Map<Id, SObject>  newObjectsMap,Map<Id, Opportunity> oldMapOppty) {
                Set<Id> oppsIdsList = new Set<Id>();
                Set<Id> prodsIdsList = new Set<Id>();
                
                List<Opportunity> oppList = new List<Opportunity>();
                List<SPProduct__c> spProductList = new List<SPProduct__c>();
                List<SPProduct__c> productSitesList = new List<SPProduct__c>();
                
                try {
                    //Block to handle the newObjestMap and checking the stage value to UtilityConstant.ORDERSUBMITTED    
                    if((null != newObjectsMap) && (!newObjectsMap.isEmpty()) && newObjectsMap.size() > 0 ) {
                        Opportunity oppObj = null;
                        Set<Id> newMapIdSet =  newObjectsMap.keySet();
                        for(Id idObj : newMapIdSet) {
                            oppObj = (Opportunity) newObjectsMap.get(idObj);
                            if(!oldMapOppty.get(oppObj.Id).StageName.equalsIgnoreCase(SIConstants.OPP_STAGE_ORDER_SUB) && oppObj.StageName.equalsIgnoreCase(SIConstants.OPP_STAGE_ORDER_SUB) && !oppObj.Site_Excel_Creation_Flag__c ) {
                                oppsIdsList.add(idObj);
                            }
                        }
                    } //End for if block
                    
                    //Block to fetch the opportunity ids
                    if( !oppsIdsList.isEmpty() && oppsIdsList.size() >  0 ) {
                        oppList = [Select Id, Name, (Select Id,Name,Deal__c from SPProducts__r Where RecordType.DeveloperName = :SIConstants.PRODUCT_NAMES[0]) 
                            from Opportunity Where Id IN :oppsIdsList Order by LastModifiedDate Desc];
                        if( !oppList.isEmpty() && oppList.size() > 0 ) {
                            List<SPProduct__c> blckSPProductsList = new List<SPProduct__c>();
                            for(Opportunity loopOppObj : oppList) {
                                blckSPProductsList = loopOppObj.SPProducts__r;
                                if(!blckSPProductsList.isEmpty()) {
                                    for(SPProduct__c productObj : blckSPProductsList) {
                                        prodsIdsList.add(productObj.Id);
                                    }
                                }
                            }
                        } //End for if block
                    } //End for Opportunity fetch
                    
                    //Products and sites fetch
                    if( !prodsIdsList.isEmpty() && prodsIdsList.size() > 0 ) {
                        spProductList =  [SELECT Id, Name,Deal__c,(Select Id, Name, Line__c, Line_2__c, City__c, State__c, Zip__c, Speed__c, 
                            Class_of_Service__c, MOS__c from Sites__r) FROM SPProduct__c Where Id in :prodsIdsList order by lastModifiedDate Desc];
                        if(!spProductList.isEmpty()) {
                            for(SPProduct__c loopProductObj : spProductList) {
                                if(!loopProductObj.Sites__r.isEmpty()) {
                                    productSitesList.add(loopProductObj);           
                                }
                            }
                        }
                    } //Products and sites fetch
                    
                } catch(Exception excep) {              
                excep.getMessage();        
                throw excep;       
                }
                return productSitesList;
            } //End of lookupProductsSites
            
            //An method used to cache the products and their sites
/* 
 Name: getProductsIds
 Description: 
 */ 
            public  String getProductsIds(List<SPProduct__c>  productsList) {
                 String productNamesStr = SpecialCharacterConstant.CONCAT;
                 try {
                    if(!productsList.isEmpty()) {
                        for(SPProduct__c spProductObj : productsList) {
                            productNamesStr += ','+spProductObj.Name+'^'+spProductObj.Id+'^'+spProductObj.Deal__c ;
                        }
                        productNamesStr = productNamesStr.subStringAfter(',');
                    }
                 } catch(Exception excep) {       
                 excep.getMessage();      
                 }
                return productNamesStr;
            }
            
           //Feb-2' Implemenation R-2015
            
/* 
 Name: updateDealStatus
 Description: 
 */ 
            public void updateDealStatus(SObject[] oldObjects, SObject[] updatedObjects){   
                try{      
                    Map<Id,String> optyMap=new Map<Id,String>();
                    List<Opportunity> optyOldList =oldObjects;
                    List<Opportunity> optyNewList =updatedObjects;
                    Map<Id,Map<String,Date>> maxNum = new  Map<Id,Map<String,Date>>();
                    Date maxdate;
                    for(integer i=0;i<OptyNewList.size();i++){
                        if(OptyOldList[i].StageName!=OptyNewList[i].StageName && (OptyNewList[i].StageName==SIConstants.PROD_DEAL_QUOTE_EXTN_REQ  || OptyNewList[i].StageName==SIConstants.OPP_STAGE_ORDER_SUB || OptyNewList[i].StageName==SIConstants.PROD_DEAL_REG_DENY  || OptyNewList[i].StageName==SIConstants.OPTY_DEAL_REG_CANCEL || OptyNewList[i].StageName==SIConstants.PROD_DEAL_QUOTE_EXTN_APRVD  || OptyNewList[i].StageName==SIConstants.PROD_DEAL_QUOTE_EXPIRED ||OptyNewList[i].StageName==SIConstants.PROD_DEAL_QUOTE_EXTN_DENY||(OptyNewList[i].StageName==SIConstants.dealstatus && OptyNewList[i].API_Flag__c ) )){
                        OptyMap.put(OptyNewList[i].id,OptyNewList[i].StageName);
                        MaxNum.put(OptyNewList[i].id,new Map<String, Date>());
                        }
                    }
                    
                    if(OptyMap.size()>0){
                    Admin_Control__c admin = [select Number_of_Months_for_Deal_Reg_Disc__c from Admin_Control__c limit 1 ];
                    List<SPProduct__c>  spProdList=[SELECT id, Name,deal__c,IsPricingScheduleRequested__c,SPProduct__c.deal__r.StageName,Deal_Status__c,Record_Type_Name__c,Exclusivity_Period_Months__c ,Product_Exclusivity_End_Date__c,Deal_Exclusivity_Date__c,Term_Length__c,Committed_VM_Duration__c,Select_IP_Flex_Term_Length__c FROM SPProduct__c WHERE deal__c in :OptyMap.Keyset()];
                      
                    for(SPProduct__c s:spProdList){
                        if(s.deal__r.StageName!=SIConstants.dealstatus){          
                        s.Deal_Status__c=OptyMap.get(s.deal__c);
                        }else{
                          s.IsPricingScheduleRequested__c=true;
                        } 
                        
                        //R-2141 Deal Exclusivity End Date Updation
                         if(s.Deal_Status__c==SIConstants.OPP_STAGE_ORDER_SUB){
                                                
                            if(s.Term_Length__c!=null){
                             
                                if((s.Term_Length__c).substring(0,1)==UtilityConstant.SIVARConst_1){
                                    s.Exclusivity_Period_Months__c=12;
                                }else if((s.Term_Length__c).substring(0,1)==UtilityConstant.SIVARConst_2){
                                    s.Exclusivity_Period_Months__c=24;
                                }else if((s.Term_Length__c).substring(0,1)==UtilityConstant.SIVARConst_3){
                                    s.Exclusivity_Period_Months__c=36;
                                }else if((s.Term_Length__c).substring(0,1)==UtilityConstant.SIVARConst_5){
                                    s.Exclusivity_Period_Months__c=60;
                                 }
                            }else{
                                s.Exclusivity_Period_Months__c=Admin.Number_of_Months_for_Deal_Reg_Disc__c;
                            }   
                            
                           if(s.Exclusivity_Period_Months__c!=null){
                                s.Product_Exclusivity_End_Date__c=system.today().addMonths(Integer.valueOf(s.Exclusivity_Period_Months__c));
                                }else{
                                s.Product_Exclusivity_End_Date__c=system.today().addMonths(Integer.valueOf(Admin.Number_of_Months_for_Deal_Reg_Disc__c));
                            }
                            
                            maxdate=MaxNum.get(s.deal__c).get(s.Record_Type_Name__c);
                            if(maxdate==null){
                                maxdate=system.today();
                            }
                            
                            if(s.Product_Exclusivity_End_Date__c >= maxdate){
                                MaxNum.get(s.deal__c).put(s.Record_Type_Name__c,s.Product_Exclusivity_End_Date__c);
                            }
                        }
                    }
                     
                    for(SPProduct__c s:spProdList){
                        s.Deal_Exclusivity_Date__c = MaxNum.get(s.deal__c).get(s.Record_Type_Name__c);
                    }
                    
                    update spProdList;                        
                }
                
                } catch(Exception e){
                    e.getMessage();
                }
            }   
            
            
/* 
 Name: updateDealStatus_Requested
 Description: 
 */ 
             public void updateDealStatus_Requested(SObject[] oldObjects, SObject[] updatedObjects){   
                try{      
                    Map<Id,String> optyMapReq=new Map<Id,String>();
                    List<Opportunity> optyOldList =oldObjects;
                    List<Opportunity> optyNewList =updatedObjects;
                    
                    for(integer i=0;i<OptyNewList.size();i++){
                        if(OptyOldList[i].StageName!=OptyNewList[i].StageName && (OptyNewList[i].StageName==SIConstants.PROD_DEAL_REG_REQ || OptyNewList[i].StageName==SIConstants.PROD_DEAL_REG_PENDING) ){
                        OptyMapReq.put(OptyNewList[i].id,OptyNewList[i].StageName);
                        }
                    }
                    if( OptyMapReq.size() > 0 ){
                        List<SPProduct__c>  spProdListreq=[SELECT id, Name,deal__c,Deal_Status__c FROM SPProduct__c WHERE deal__c in :OptyMapReq.Keyset() ];  
                        List<SPProduct__c> spProductToUpdate = new List<SPProduct__c>();
                        for(SPProduct__c s:spProdListreq){
                        
                           if(s.Deal_Status__c!=SIConstants.PROD_DEAL_REG_APP_WITH_DIS && s.Deal_Status__c!=SIConstants.PROD_DEAL_REG_APP_WITHOUT_DIS)
                            {        
                                s.Deal_Status__c=OptyMapReq.get(s.deal__c);  
                                spProductToUpdate.add(s);
                            }
                                     
                        } 
                        if(spProductToUpdate.size()>0){ 
                        update spProductToUpdate;                        
                        }
                    }
                
                }catch(Exception e){     
                e.getMessage();    
                } 
                
            }    
            
            //April&May Release ..check for EC created by EBM
        //Optimization 6 for defect 8516
/* 
 Name: CheckforSharedEC
 Description: 
 */ 
            public void checkforSharedEC(SObject[] updatedObjects){
              try{              
                List<Opportunity> optyNewList =updatedObjects;
                 Set<Id> ecId = new Set<Id>();
                 Map<Id,Id> eCMap=new Map<Id,Id>();
                
                for(Opportunity Opty:OptyNewList){
            if(opty.Shared_EC__c == false){
                        ecId.add(opty.End_Customer__c);
            }
                }
                if(ecId.size()>0){
                    List<End_Customer__c> ecList = [select Id from End_Customer__c where Id in :ecId and Shared_EC__c=true];
                    for(End_Customer__c EC: ecList){
                        ECMap.put(EC.id,EC.Id);
                    }
                    if(ECMap.size()>0){
                        for(Opportunity Opty:OptyNewList){
                            if(ECMap.get(opty.End_Customer__c)!=null){
                                opty.Shared_EC__c=true;
                            }
                        }
                    }
                }
            } 
            catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));

}
}
         
         //April May Release. To update the Discount fields to Null When the status is changing to Quote Expired.
            /*Name:setDiscountFieldstoNull
             * Description:
             */
        public void setDiscountFieldstoNull(SObject[] oldObjects, SObject[] updatedObject)
        {
            try
            {
                List<Opportunity> optyOldList =oldObjects;
                List<Opportunity> optyNewList =updatedObject;
                for(integer i=0;i<OptyOldList.size();i++)
                {
                   if( OptyOldList[i].StageName!=OptyNewList[i].StageName && OptyNewList[i].StageName==SIConstants.PROD_DEAL_QUOTE_EXPIRED  )
                    {
                        OptyNewList[i].Discounted_Price__c=Null;
                        OptyNewList[i].Discount_Amount__c=Null;
                        OptyNewList[i].Discounted_Percentage__c=Null;
                        OptyNewList[i].Discount_Percentage__c=Null;
                    }
                    
                }   
            }catch(Exception e)     
            {               
            e.getMessage();  
            } 
         }
        // July Release - June Sprint : Mapping Default values for Likelihood to Close when stage is selected.
        /*Name:setDefaultvaluesforLikelihoodtoclose
         * Description:
         */
        public void setDefaultvaluesforLikelihoodtoclose(SObject[] oldObjects, SObject[] updatedObject,String check)
        {
            try
            {
                List<Opportunity> optyOldList =oldObjects;
                List<Opportunity> optyNewList =updatedObject;
                for(integer i=0;i<OptyOldList.size();i++)
                {
                    if((OptyOldList[i].StageName!=OptyNewList[i].StageName ||check==UtilityConstant.STATIC_INSERT) && OptyNewList[i].StageName==SIConstants.OPTY_DEAL_QUOTE_CREATED)
                    {
                        OptyNewList[i].LikelihoodtoClose__c=SIConstants.OPTY_DEAL_LTC_NONE;
                        
                    }
                    else if((OptyOldList[i].StageName!=OptyNewList[i].StageName ||check==UtilityConstant.STATIC_INSERT) && (OptyNewList[i].StageName==SIConstants.OPTY_DEAL_APPROVED ||OptyNewList[i].StageName==SIConstants.OPTY_DEAL_Auto_Approved))
                    {
                         OptyNewList[i].LikelihoodtoClose__c=SIConstants.OPTY_DEAL_LTC_APPROVED;
                    }
                    else  if((OptyOldList[i].StageName!=OptyNewList[i].StageName ||check==UtilityConstant.STATIC_INSERT) && OptyNewList[i].StageName==SIConstants.OPTY_DEAL_REQUESTED)
                    {
                         OptyNewList[i].LikelihoodtoClose__c=SIConstants.OPTY_DEAL_LTC_REG_REQUESTED;
                    }
                    else  if((OptyOldList[i].StageName!=OptyNewList[i].StageName ||check==UtilityConstant.STATIC_INSERT) && (OptyNewList[i].StageName==SIConstants.OPTY_DEAL_SUBMITTED||OptyNewList[i].StageName==SIConstants.OPTY_DEAL_WON))
                    {
                         OptyNewList[i].LikelihoodtoClose__c=SIConstants.OPTY_DEAL_LTC_ORDERED;
                    }
                     
                     else  if((OptyOldList[i].StageName!=OptyNewList[i].StageName ||check==UtilityConstant.STATIC_INSERT) && OptyNewList[i].StageName==SIConstants.OPTY_DEAL_DENY)
                    {
                         OptyNewList[i].LikelihoodtoClose__c=SIConstants.OPTY_DEAL_LTC_NONE;
                    }
                    else if((OptyOldList[i].StageName!=OptyNewList[i].StageName ||check==UtilityConstant.STATIC_INSERT) && OptyNewList[i].StageName==SIConstants.OPTY_DEAL_EXPIRED)               
                    {
                        OptyNewList[i].LikelihoodtoClose__c=SIConstants.OPTY_DEAL_LTC_NONE;
                    } 
                    else if((OptyOldList[i].StageName!=OptyNewList[i].StageName ||check==UtilityConstant.STATIC_INSERT) && OptyNewList[i].StageName==SIConstants.PRODUCT_EXPIRY)               
                    {
                        OptyNewList[i].LikelihoodtoClose__c=SIConstants.OPTY_LTC_DEAL_LOST;
                    }
                } 
                                        
            }catch(Exception e)   
            {             
            e.getMessage();    
            } 
         }

         // after insert
        /*Name:takeNoteFromCommentsOnInsert
         * Description:
         */
             public void takeNoteFromCommentsOnInsert(SObject[] newObjects)
             {
                list <Opportunity> optyList = newObjects;
                list <note> noteList = new list <note>();
                map <Id,String> commentsMap = new map <Id,String>();
                
                try
                {
                if(!optyList.isEmpty()&&optyList!=null)
                {
                    for(Opportunity opty : optyList)
                    {
                        if(opty.Comments__c!=null)
                        {
                            commentsMap.put(opty.Id,opty.Comments__c);
                        }
                    }
                    
                if(!commentsMap.isEmpty()&&commentsMap!=null)
                    {
                        for(Id optyId : commentsMap.keySet())
                        {   
                            note newNote = new note();
                            if((commentsMap.get(optyId)).length() > 77)
                            {
                                newNote.title=commentsMap.get(optyId).substring(0,76)+'...';
                            }
                            else
                            {
                                 newNote.title=commentsMap.get(optyId);
                            }
                            newNote.parentId=optyId;
                            newNote.body=commentsMap.get(optyId);
                            newNote.isPrivate=false;
                            noteList.add(newNote);
                        }           
                    }
                if(!noteList.isEmpty()&&noteList!=null)
                {
                    insert noteList;
                }
                }
                }
             
             catch (exception e)  
             {         
             e.getMessage();    
             }
             }
             // after update
             /*Name:takeNoteFromCommentsOnUpdate
              * Description:
              */
             public void takeNoteFromCommentsOnUpdate(SObject[] oldObjects,SObject[] updatedObjects)
             {
                list <Opportunity> oldList = oldObjects;
                list <Opportunity> updatedList = updatedObjects;
                list <note> noteList = new list <note>();
                map <Id,String> commentsMap = new map <Id,String>();
                try
                {           
                if( !updatedList.isEmpty()&&updatedList!=null && updatedList.size() > 0 )
                {
                    for(integer i=0;i<updatedList.size();i++)
                    {
                        if(updatedList[i].Comments__c != oldList[i].Comments__c && updatedList[i].Comments__c!=null)
                        {
                            commentsMap.put(updatedList[i].Id,updatedList[i].Comments__c);
                        }
                    }
                    
                    if( !commentsMap.isEmpty()&&commentsMap!=null && commentsMap.size() > 0 )
                    {
                        for(Id optyId : commentsMap.keySet())
                        {   
                            note newNote = new note();
                            if((commentsMap.get(optyId)).length() > 77)
                            {
                                newNote.title=commentsMap.get(optyId).substring(0,76)+'...';
                            }
                            else
                            {
                                newNote.title=commentsMap.get(optyId);
                            }
                            newNote.parentId=optyId;
                            newNote.body=commentsMap.get(optyId);
                            newNote.isPrivate=false;
                            noteList.add(newNote);
                        }           
                    }
                    if(!noteList.isEmpty()&&noteList!=null)
                    {
                        insert noteList;
                    }
                }
                    
                }
                catch (exception e)    
                {            
                e.getMessage();      
                }       
             }
             
           /*  public void settingPurchasedCloudProductFlag(SObject[] oldObjects,SObject[] updatedObjects){
                
                
                list <Opportunity> oldList = oldObjects;
                list <Opportunity> updatedList = updatedObjects;
                list <Account> AccList;
                
                Set<Id> OptyIds = new Set<Id>();
                Set<Id> AccountIds = new Set<Id>();
                
                
                 for(integer i=0;i<updatedList.size();i++)
                 {
                   if( oldList[i].StageName!=updatedList[i].StageName && updatedList[i].StageName==SIConstants.OPP_STAGE_ORDER_SUB  )
                    {
                        OptyIds.add(updatedList[i].Id);
                    
                    }
                 }
                 if( OptyIds.size() > 0 ) {
                    AggregateResult[] groupedResults = [SELECT AccountId, count(Id) FROM Opportunity
                                        where ID IN (Select Deal__c from SPProduct__c where RecordType.Name IN ('Caas', 'StaaS', 'PaaS') ) and ID=:OptyIds
                                        Group By AccountId ];
                    
                    for(AggregateResult agr: groupedResults)
                                {
                                    AccountIds.add((Id)agr.get('AccountId'));
                        
                                }
                    
                    if( AccountIds.size() > 0 ) {
                        AccList=[select Id,Purchased_Cloud_Product__c from Account where Id=:AccountIds];
                        for(Account A:AccList)      {
                            A.Purchased_Cloud_Product__c=true;
                        }   
                        try{
                        update  AccList; 
                        }Catch(DMLException ex){
                         ex.getMessage();
                        }
                    }  
                }     
             } */
             /*Name:updateOffCartDealName
              * Description:
              */
             public void updateOffCartDealName(SObject[] updatedObjects)
             {
                 try{
                list <Opportunity> optyList = updatedObjects;
                list<Opportunity> opList= new list<Opportunity>();
                Integer nameVar = 10000;
                opList=[SELECT Name FROM Opportunity op Where (NOT op.Name LIKE 'OC-0%') AND (op.Name LIKE 'OC-%') ORDER BY op.Name Desc];
                if(!opList.isEmpty() && opList != null)
                {
                    for(opportunity op : opList)
                    {
                        try
                        {
                            nameVar=Integer.valueOf(op.Name.substring(3));
                            break;
                        }
                        catch (Exception e)                 
               {                      
                 if(!(String.valueOf(e)).contains('Invalid integer:'))                     
                    {                         
                                            break;                    
                                    }                 
                                   }
                    }
                }
                for(Opportunity opty:optyList)
                {
                    if(opty.Name==UtilityConstant.STATIC_NEW || opty.Name==SpecialCharacterConstant.CONCAT || opty.Name==null)
                    {
                        nameVar+=1;
                        opty.Name= 'OC-'+nameVar;
                    }
                }   
             }
             catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}

                //Mobility Automation Start.
             
/* 
 Name: MobilityAutomation
 Description: 
 */ 
                public void mobilityAutomation(SObject[]  OldObjects ,SObject[] updatedObjects){
                try{
                    list <Opportunity> optyOldList = OldObjects;
                    list <Opportunity> optyNewList = updatedObjects;
                    Map <ID,Product_Pricing__c> pPList;
                    Map <ID,SPProduct__c> sPList;
                    list <Discount__c> discountList=new list<Discount__c>();
                    list <Product_Pricing__c> pPUpdateList=new list<Product_Pricing__c>();
                    list <SPProduct__c> sPUpdateList=new list<SPProduct__c>();
                    list <Opportunity> optyUpdateList=new list<Opportunity>();
                    
                    Map<Id,Map<String,Decimal>> discountMap=new Map<Id,Map<String,Decimal>>();
                    Set<Id> mobilityIds = New Set<Id>();
                    
                    for(Integer i=0;i<optyNewList.size();i++){
                        if(optyNewList[i].CI_process_completed__c==true && optyOldList[i].CI_process_completed__c ==false){
                            MobilityIds.add(optyNewList[i].Id);
                        }       
                    }
                    
                  if( !MobilityIds.isEmpty()&& MobilityIds!=null && MobilityIds.size() > 0 ){
                    
                    SPList=new Map <ID,SPProduct__c>([select Id from SPProduct__c where Deal__C IN :MobilityIds]);
                    if( SPList.size() > 0 ) {
                        PPList=new Map<ID,Product_Pricing__c>([SELECT Id,SP_Product__c,Type__c,Discountable__c,List_Price__c,discount_price__c,Discounted_Price__c,Record_Type__c,Usage_Charges__c,Discounted_Usage_Charge__c FROM Product_Pricing__c WHERE (Type__c =:SIConstants.TYPE_NRC OR Type__c =:SIConstants.TYPE_MRC OR Type__c= :SIConstants.TYPE_MUC) AND SP_Product__c IN : SPList.keySet()]);
                    }
                    if( PPList.size() > 0 || SPList.size() > 0 ) {
                        DiscountList =[Select Id,Percent_Off__c,Amount_off__c,Product_Pricing__c,SPProduct__c,Deal__c from Discount__c where (Product_Pricing__c IN : PPList.keySet() or SPProduct__c IN : SPList.keySet() or Deal__c IN :MobilityIds)];
                    }                        
                    for (Discount__c DL:DiscountList){
                        if(DL.Product_Pricing__c!=null){
                            if(DL.Percent_Off__c!=null){
                                DiscountMap.put(DL.Product_Pricing__c,new Map<String,Decimal>{UtilityConstant.PERCENT=>DL.Percent_Off__c});
                            }else if(DL.Amount_off__c!=null){
                                DiscountMap.put(DL.Product_Pricing__c,new Map<String,Decimal>{UtilityConstant.AMOUNT=>DL.Amount_off__c});
                            }
                        }if (DL.SPProduct__c!=null){
                            if(DL.Percent_Off__c!=null){
                                DiscountMap.put(DL.SPProduct__c,new Map<String,Decimal>{UtilityConstant.PERCENT=>DL.Percent_Off__c});
                            }else if(DL.Amount_off__c!=null){
                                DiscountMap.put(DL.SPProduct__c,new Map<String,Decimal>{UtilityConstant.AMOUNT=>DL.Amount_off__c});
                            }
                        }if (DL.Deal__c!=null){
                            if(DL.Percent_Off__c!=null){
                                DiscountMap.put(DL.Deal__c,new Map<String,Decimal>{UtilityConstant.PERCENT=>DL.Percent_Off__c});
                            }else if(DL.Amount_off__c!=null){
                                DiscountMap.put(DL.Deal__c,new Map<String,Decimal>{UtilityConstant.AMOUNT=>DL.Amount_off__c});
                            }
                        }
                    }
                    
                    for(ID PP : PPList.keySet()){
                        if(DiscountMap.containsKey(PP)){
                            if(DiscountMap.get(PP).containsKey('PERCENT')){
                                    Decimal percentage =DiscountMap.get(PP).get('PERCENT');
                                    if(PPList.get(PP).Discountable__c==false)
                                    {
                                       if(PPList.get(PP).Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE)
                                         {
                                           PPList.get(PP).Discounted_Usage_Charge__c = PPList.get(PP).Usage_Charges__c - SIHelper.Round4Digit((PPList.get(PP).Usage_Charges__c * percentage)/100);
                                           if(PPList.get(PP).Discounted_Usage_Charge__c<0){
                                                PPList.get(PP).Discounted_Usage_Charge__c=0.0;
                                           }
                                        }else{
                                           PPList.get(PP).discount_price__c = SIHelper.applyRound((PPList.get(PP).List_Price__c * percentage)/100);
                                           PPList.get(PP).Discounted_Price__c = PPList.get(PP).List_Price__c - PPList.get(PP).discount_price__c;
                                           if(PPList.get(PP).Discounted_Price__c<0){
                                                PPList.get(PP).Discounted_Price__c=0.0;
                                           }
                                        }
                                    }
                                    else
                                    {
                                       if(PPList.get(PP).Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE){
                                            PPList.get(PP).Discounted_Usage_Charge__c=PPList.get(PP).Usage_Charges__c;
                                       }else{
                                            PPList.get(PP).discount_price__c=0;
                                            PPList.get(PP).Discounted_Price__c=PPList.get(PP).List_Price__c;
                                       }
                                    }
                            }else if(DiscountMap.get(PP).containsKey('AMOUNT')){
                            
                                    Decimal disAmount =DiscountMap.get(PP).get('AMOUNT');
                                    if(PPList.get(PP).Discountable__c==false)
                                    {
                                       if(PPList.get(PP).Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE)
                                        {
                                            PPList.get(PP).Discounted_Usage_Charge__c = PPList.get(PP).Usage_Charges__c - DisAmount;
                                            if(PPList.get(PP).Discounted_Usage_Charge__c<0){
                                                PPList.get(PP).Discounted_Usage_Charge__c=0.0;
                                           }
                                        }else{
                                            PPList.get(PP).discount_price__c = DisAmount;
                                            PPList.get(PP).Discounted_Price__c = PPList.get(PP).List_Price__c - PPList.get(PP).discount_price__c;
                                            if(PPList.get(PP).Discounted_Price__c<0){
                                                PPList.get(PP).Discounted_Price__c=0.0;
                                           }
                                        }
                                    }
                                    else
                                    {
                                       if(PPList.get(PP).Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE){
                                            PPList.get(PP).Discounted_Usage_Charge__c=PPList.get(PP).Usage_Charges__c;
                                       }else{
                                        PPList.get(PP).discount_price__c=0;
                                        PPList.get(PP).Discounted_Price__c=PPList.get(PP).List_Price__c;
                                       }
                                    }
                            }
                        }else{
                            if(PPList.get(PP).Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE){
                                            PPList.get(PP).Discounted_Usage_Charge__c=PPList.get(PP).Usage_Charges__c;
                                       }else{
                                        PPList.get(PP).discount_price__c=0;
                                        PPList.get(PP).Discounted_Price__c=PPList.get(PP).List_Price__c;
                                       }
                        }
                        PPUpdateList.add(PPList.get(PP));
                    }
                    
                    update PPUpdateList;
                    if( MobilityIds.size() > 0 ) {
                        SPUpdateList =[Select Id,List_Price__c,Discounted_Price__c,one_time_revenue__c,One_Time_Revenue_Discount_Price__c,NRC_Discounted_Price__c,MRC_Discounted_Price__c from sPProduct__c where deal__c IN:MobilityIds];

                          
                        for(sPProduct__c SP:SPUpdateList){
                            if(DiscountMap.containsKey(SP.id)){
                                if(DiscountMap.get(SP.id).containsKey('PERCENT')){
                                    Decimal percentage =DiscountMap.get(SP.id).get('PERCENT');
                                        if(SP.List_Price__c!=null){
                                            SP.Discounted_Price__c =SP.MRC_Discounted_Price__c -(percentage/100)*SP.List_Price__c;
                                            if(SP.Discounted_Price__c<0){
                                                SP.Discounted_Price__c=0.0;
                                            }
                                        }if(SP.one_time_revenue__c!=null){
                                            SP.One_Time_Revenue_Discount_Price__c = SP.NRC_Discounted_Price__c - (percentage/100)*SP.one_time_revenue__c;
                                            if(SP.One_Time_Revenue_Discount_Price__c<0){
                                                SP.One_Time_Revenue_Discount_Price__c=0.0;
                                            }
                                        }
                                }else if(DiscountMap.get(SP.id).containsKey('AMOUNT')){
                                        Decimal disAmount =DiscountMap.get(SP.id).get('AMOUNT');
                                        SP.Discounted_Price__c =SP.MRC_Discounted_Price__c -DisAmount;
                                        SP.One_Time_Revenue_Discount_Price__c = SP.NRC_Discounted_Price__c - DisAmount;
                                        if(SP.Discounted_Price__c<0){
                                            SP.Discounted_Price__c=0.0;
                                        }
                                        if(SP.One_Time_Revenue_Discount_Price__c<0){
                                            SP.One_Time_Revenue_Discount_Price__c=0.0;
                                        }
                                }
                            }else{
                                     SP.Discounted_Price__c =SP.MRC_Discounted_Price__c;
                                     SP.One_Time_Revenue_Discount_Price__c = SP.NRC_Discounted_Price__c;
                                }
                        }
                    try{    
                    update SPUpdateList;
                    }Catch(DMLException ex){                 ex.getMessage();                }
                    OptyUpdateList =[select Cumulative_List_Price__c,Cumulative_OTC_Price__c,Discounted_Price__c,Cumulative_OTC_Discount_Price__c from Opportunity where Id IN:MobilityIds];
                    
                    AggregateResult[] groupedResults = [SELECT Deal__c, SUM(List_Price__c) ListPrice, SUM(one_time_revenue__c) OTCPrice, SUM(One_Time_Revenue_Discount_Price__c) OTCDiscountPrice, SUM(Discounted_Price__c) DiscountedPrice FROM SPProduct__c sp WHERE sp.Deal__c IN : MobilityIds GROUP BY sp.Deal__c];
                
                    for(Opportunity OP:OptyUpdateList){
                        
                        for(AggregateResult agr: groupedResults)
                                {
                                    if(agr.get('Deal__c')== OP.Id)
                                    {
                                        OP.Cumulative_List_Price__c = (Decimal)agr.get('ListPrice');
                                        OP.Discounted_Price__c=(Decimal)agr.get('DiscountedPrice');
                                        OP.Cumulative_OTC_Discount_Price__c =(Decimal)agr.get('OTCPrice');
                                        OP.Cumulative_OTC_Price__c =(Decimal)agr.get('OTCDiscountPrice');
                                        
                                        
                                            if(DiscountMap.containsKey(OP.id)){
                                                if(DiscountMap.get(OP.id).containsKey('PERCENT')){
                                                    Decimal percentage =DiscountMap.get(OP.id).get('PERCENT');
                                                        if(OP.Cumulative_List_Price__c!=null){
                                                            OP.Discounted_Price__c =OP.Discounted_Price__c -(percentage/100)*OP.Cumulative_List_Price__c;
                                                            if(OP.Discounted_Price__c<0){
                                                                OP.Discounted_Price__c=0.0;
                                                            }
                                                        }if(OP.Cumulative_OTC_Price__c!=null){
                                                            OP.Cumulative_OTC_Discount_Price__c = OP.Cumulative_OTC_Discount_Price__c - (percentage/100)*OP.Cumulative_OTC_Price__c;
                                                            if(OP.Cumulative_OTC_Discount_Price__c<0){
                                                                OP.Cumulative_OTC_Discount_Price__c=0.0;
                                                            }
                                                        }
                                                }else if(DiscountMap.get(OP.id).containsKey('AMOUNT')){
                                                       Decimal disAmount =DiscountMap.get(OP.id).get('AMOUNT');
                                                        OP.Discounted_Price__c =OP.Discounted_Price__c -DisAmount;
                                                        OP.Cumulative_OTC_Discount_Price__c = OP.Cumulative_OTC_Discount_Price__c - DisAmount;
                                                        if(OP.Discounted_Price__c<0){
                                                            OP.Discounted_Price__c=0.0;
                                                        }if(OP.Cumulative_OTC_Discount_Price__c<0){
                                                            OP.Cumulative_OTC_Discount_Price__c=0.0;
                                                        }
                                                }
                                            }
                                    }
                                }
                        }
                    try{
                    update OptyUpdateList;
                    } Catch(DMLException ex){                  ex.getMessage();                }
                 }
             }
           }
           catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
             //Mobility Automation End
        // This method is used to update related RDS-VLAN Information object records when RDS Access Circuit Id creation is successful for an Opportunity and a particular Premise
/* 
 Name: updateVLANDetails
 Description: 
 */ 
            public void updateVLANDetails(SObject[] updatedObjects,SObject[] oldObjects){
            try{
            List<VLAN_Information__c> vlanRecordsToBeUpdated = new List<VLAN_Information__c>(); 
            List<Opportunity> oppDetailsold=oldObjects;
            Set<String> oppIds = new Set<String>();
            Set<String> premiseNumberSet = new Set<String>();
            Map<String, String> premiseCktMap = new Map<String, String>();
            List<Opportunity> oppDetails=updatedObjects;
                for(Opportunity opps: oppDetails){
                    for(Opportunity oppold: oppDetailsold){
                    if( opps.Id == oppold.Id && opps.IsCircuit_ID_USOSucess__c == true && oppold.IsCircuit_ID_USOSucess__c==false &&( opps.X3rd_Party_Flag__c || opps.API_Flag__c ) ){
                        String opps18Id = opps.Id;
                        String opps15Id = opps18Id.substring(0, 15);
                        oppIds.add(opps15Id);
                    }
                    }
                }
            if(oppIds!=null && oppIds.size()>0 && SIConstants.recursiveCheckOnVLANDetails){
                SIConstants.recursiveCheckOnVLANDetails = false;
                List<RDS_Premise_Details__c> premiseNumberList = [Select Id, Premise_Number__c from RDS_Premise_Details__c WHERE Premise_Number__c !=null AND OpptyID__c IN: oppIds];
                if(premiseNumberList.size()>0){
                for(RDS_Premise_Details__c rpd: premiseNumberList){
                    premiseNumberSet.add(rpd.Premise_Number__c);
                    }
                }
                if(premiseNumberSet!=null && premiseNumberSet.size() > 0 ){
                List<RDS_Access_Circuit_ID__c> accessCircuitRecords = [Select Id, RDS_Premise_Number__c, Access_Circuit_ID__c from RDS_Access_Circuit_ID__c WHERE RDS_Premise_Number__c IN: premiseNumberSet];
                    if( accessCircuitRecords.size()>0 ){
                    for(RDS_Access_Circuit_ID__c rdsAccCkt: accessCircuitRecords){
                        premiseCktMap.put(rdsAccCkt.RDS_Premise_Number__c, rdsAccCkt.Access_Circuit_ID__c);
                        }
                    }
                  List<VLAN_Information__c> vlanRecords = [Select Id, EVC_Source_Port__c, EVC_Destination_Port__c from VLAN_Information__c WHERE EVC_Source_Port__c IN: premiseNumberSet OR EVC_Destination_Port__c IN: premiseNumberSet];
                    if(vlanRecords.size()>0){
                        for(VLAN_Information__c vlanInfo: vlanRecords){
                            if(vlanInfo.EVC_Source_Port__c!=null){
                                vlanInfo.EVC_Source_Port__c = premiseCktMap.get(vlanInfo.EVC_Source_Port__c);
                                
                            }
                            if(vlanInfo.EVC_Destination_Port__c!=null){
                                vlanInfo.EVC_Destination_Port__c = premiseCktMap.get(vlanInfo.EVC_Destination_Port__c);
                                        
                            }
                            vlanRecordsToBeUpdated.add(vlanInfo);
                            }
                        }
                            
                    if(vlanRecordsToBeUpdated.size()>0){
                    try{
                            update vlanRecordsToBeUpdated;
                    } catch(Exception ex){                          ex.getMessage();                        }
                    } 
                    }
                }
            } 
            catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
            //This method will populate the EBM SIGNED checkbox on Related Pricing Schedule object with the value of 3rd party flag present on Oppty   
            //After Update and before insert
            //optimization 2 for defect 8516 
/* 
 Name: updatePricingSchedule
 Description: 
 */ 
            public void updatePricingSchedule(SObject[] updatedObjects,SObject[] oldObjects, boolean insertevent){
            try{
                List<Opportunity> oppDetails=updatedObjects;
                List<Opportunity> oldoppDetails = new List<Opportunity>();
                if(!insertevent){
                    OldoppDetails = oldObjects;
                }
                //List<Opportunity> OldoppDetails = oldObjects;
                Map<Id,Opportunity> opptyOldMap = new Map<Id,Opportunity>();
                Set<Id> opptyId = new Set<Id>();
                List<RDS_Pricing_Schedule_Detail__c> listofPricingtoBeupdated = new List<RDS_Pricing_Schedule_Detail__c>();
                for(Opportunity opp:OldoppDetails){
                    opptyOldMap.put(opp.Id,opp);
                }
                for(Opportunity opp:oppDetails){    
                    if((opp.X3rd_Party_Flag__c == true && insertevent) || (!insertevent && opp.X3rd_Party_Flag__c == true &&  opptyOldMap.containsKey(opp.Id) && opptyOldMap.get(opp.Id).X3rd_Party_Flag__c == false)){
                        opptyId.add(opp.id); 
                    }    
                }
              if(opptyId.size()>0){
                List<RDS_Pricing_Schedule_Detail__c> listOfPricingSchedule = new List<RDS_Pricing_Schedule_Detail__c>();
                listOfPricingSchedule = [Select id,EBM_Signed__c from RDS_Pricing_Schedule_Detail__c where Deal__c in:opptyId];
                
                for(RDS_Pricing_Schedule_Detail__c pricing : listOfPricingSchedule){
                    pricing.EBM_Signed__c = true;
                    listofPricingtoBeupdated.add(pricing);    
                 }
              }
                try{
                    update listofPricingtoBeupdated;
                }catch(Exception ex){                ex.getMessage();            }
            }
            catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
            
            //BAU Functionality to clear Special Pricing
            /*Name:clearSpecialPricing
             * Description:
             */
            public void clearSpecialPricing(SObject[] oldObjects,SObject[] updatedObjects)
            {
                try{
                list<Opportunity> newOptyList =updatedObjects;
                list<Opportunity> oldOptyList =oldObjects;
                set<Id> optyId = new set<Id>();
                set<Id> productPricingId = new set<Id>();
                list<Product_Pricing__c> productPricing = new list<Product_Pricing__c>();
                list<Product_Pricing__c> updatedProductPricingList = new list<Product_Pricing__c>();
                list<SPProduct__c> spProductlist = new list<SPPRoduct__c>(); 
                list<Opportunity> updateFlagToFlase = new list<Opportunity>();      
                if(!newOptyList.isEmpty() && newOptyList!= null)
                {
                    for (Integer i=0; i<newOptyList.size(); i++)
                    {
                        if(!oldOptyList[i].Clear_Special_Pricing__c && newOptyList[i].Clear_Special_Pricing__c)
                        {
                            optyId.add(newOptyList[i].Id);
                        }
                    }
                }
                
                if( optyId!=null && SIConstants.isClearSpecialpricing &&optyId.size()>0 )
                {
                    SIConstants.isClearSpecialpricing=false;           
                    productPricing = [SELECT Id,Deal_Id__c,SP_Product__c,Type__c,Discountable__c,List_Price__c,discount_price__c,Discounted_Price__c,Record_Type__c,Usage_Charges__c,Discounted_Usage_Charge__c,Clear_Special_Pricing__c,X3rd_Party_Flag__c FROM Product_Pricing__c where SP_Product__r.Deal__c IN :optyId];
                    if(productPricing!=null)
                    {
                        UpdatedProductPricingList = SIHelper.calculateDiscountonProductPricingRecords(productPricing);
                    }
                    
                    if(UpdatedProductPricingList!=null)
                    {
                        
                        update UpdatedProductPricingList;   
                        spProductlist = [select Id, Competitive_Pricing_Status__c, Discount_Amount__c, SP_Discount_Percentage__c, Discounted_Percentage__c from SPProduct__c where Deal__c IN:optyId];
                        if(spProductlist!=null)
                        {
                            for(SPProduct__c spp :spProductlist)
                            {
                                spp.Competitive_Pricing_Status__c = null;
                                spp.Discount_Amount__c=null;
                                spp.SP_Discount_Percentage__c=null;
                                spp.Discounted_Percentage__c=null;
                            }
                            try{
                            update spProductlist;
                            }Catch(DMLException ex){                          ex.getMessage();                        }
                        }
                    }
                    
                }
            }
            catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
            
/* 
 Name: updateRDSDealHashfields
 Description: 
 */ 
            public void updateRDSDealHashfields(SObject[] oldObjects,SObject[] updatedObjects){
            try{
                List<Opportunity> optyOldList =oldObjects;
                List<Opportunity> oppList = updatedObjects;
                Set<String> oppSet=new Set<String>();// this will hold all Opportunity Id's.
                Set<Deal_Hash__c> dhList = new Set<Deal_Hash__c>();
                List<Opportunity>  contractRenewalOppty=new List<Opportunity>();
                Set<String> dealHashIds=new Set<String>();
                for(integer i=0;i<oppList.size();i++)
                {         
                  if(OptyOldList[i].Deal_Rate_Plan_ID__c != oppList[i].Deal_Rate_Plan_ID__c && oppList[i].StageName==SIConstants.OPP_STAGE_ORDER_SUB ) 
                    {
                       oppSet.add(oppList[i].id); 
                       if(oppList[i].renewal_contract__c)
                       {
                        dealHashIds.add(oppList[i].RDS_Deal_Hash__c);
                       }
                     }
                }
                if (oppSet.size()>0)
                {    
                    List<Deal_Hash__c> dealList=new List<Deal_Hash__c>();
                     if(dealHashIds!=null && dealHashIds.size()>0)
                     {
                        dealList = [select Id,Opportunity__c,Discount_Amount__c,Rate_Plan_ID__c,Rate_Stability_Date__c from Deal_Hash__c WHERE Id  IN: dealHashIds limit 1];
                     }
                     else
                     {
                          dealList = [select Id,Opportunity__c,Discount_Amount__c,Rate_Plan_ID__c,Rate_Stability_Date__c from Deal_Hash__c WHERE Opportunity__c IN:oppSet limit 1];   
                     }
                   
                      if(dealList.size()>0)
                      {
                            for(Opportunity opp : oppList )
                            {
                                 for(Deal_Hash__c deal :dealList)
                                 {
                                      if(opp.Deal_Rate_Plan_ID__c!=null && deal.Rate_Plan_ID__c == null )
                                      {
                                       deal.Rate_Plan_ID__c = opp.Deal_Rate_Plan_ID__c;
                                       deal.Discount_Amount__c = opp.Discounted_Percentage__c;  
                                       deal.Rate_Stability_Date__c = opp.Rate_Stability_Date__c;  
                                       dhList.add(deal); 
                                       }
                                       if(opp.renewal_contract__c && opp.Deal_Rate_Plan_ID__c!=deal.Rate_Plan_ID__c)
                                       {
                                           deal.Rate_Plan_ID__c = opp.Deal_Rate_Plan_ID__c;
                                           dhList.add(deal);
                                       
                                       }
                                       
                                 }
                             }
                       }
                  }    
                 if(dhList.size()>0)
                 {      
                       try
                       {      
                          List<Deal_Hash__c> listDh=new List<Deal_Hash__c>();
                          listDh.addAll(dhList);
                          update listDh;   
                       }catch(Exception ex){                        ex.getMessage();                   } 
                 }
            }
            catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}


            // Logic for updating manual flag on related Opportunity 
/* 
 Name: updateRDSDealHashManualFlow
 Description: 
 */ 
           public void updateRDSDealHashManualFlow(SObject[] oldObjects,SObject[] updatedObjects){
               try{
                List<Opportunity> optyOldList =oldObjects;
                List<Opportunity> oppList = updatedObjects;
                Set<String> oppSet=new Set<String>();// this will hold all Opportunity Id's.
                List<Deal_Hash__c> dhList = new List<Deal_Hash__c>();
                
                for(integer i=0;i<oppList.size();i++)
                {     
                   if(OptyOldList[i].ManualFlow__c!=oppList[i].ManualFlow__c){
                     oppSet.add(oppList[i].RDS_Deal_Hash__c);
                    } 
                }
                if (oppSet.size()>0)
                {
                      List<Deal_Hash__c> dealList = [select Id,Opportunity__c,Discount_Amount__c,Rate_Plan_ID__c,Rate_Stability_Date__c from Deal_Hash__c WHERE ID IN:oppSet limit 1];   
                      if(dealList.size()>0)
                      {
                            for(Opportunity opp : oppList )
                            {
                                 for(Deal_Hash__c deal :dealList)
                                 {
                                       deal.ManualFlow__c=opp.ManualFlow__c;
                                       dhList.add(deal); 
                                 }
                             }
                       }
                  }    
                 if(dhList.size()>0)
                 {      
                       try
                       {      
                          update dhList;   
                       }catch(Exception ex){                        
                       ex.getMessage();              
                       } 
                 }
            }  
            catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}


        //US284794: Special Pricing Removal and applying promotion for the deal.
           /*Name:removeSpecialPricingApplyPromotion
            * Description:
            */
            public void removeSpecialPricingApplyPromotion( SObject[] oldObjects, SObject[] updatedObjects )
            {
                
                list<Opportunity> newOptyList =updatedObjects;
                list<Opportunity> oldOptyList =oldObjects;
                set<Id> optyId =  new set<Id>(); 
                list<Product_Pricing__c> updatePPRecords = new list<Product_Pricing__c>();
                list<Opportunity> selectedOptys =new list<Opportunity>();    
                list<SPProduct__c> spProductlist = new list<SPPRoduct__c>(); 
                list<Product_Pricing__c> finalPPRecords = new list<Product_Pricing__c>(); 
                  
                try{        
                  if(!newOptyList.isEmpty() && newOptyList!= null)
                  {
                      for (Integer i=0; i<newOptyList.size(); i++)
                      {
                        //Old stage "Approved" to "Requested" And Deal Reg Approved Flag = True AND Remove special pricing = ture
                          if( !oldOptyList[i].Remove_special_pricing__c && newOptyList[i].Remove_special_pricing__c && oldOptyList[i].StageName == SIConstants.OPP_STAGE_Approved && newOptyList[i].StageName == SIConstants.OPP_STAGE_REQUESTED && newOptyList[i].Apply_Promotions__c == false && newOptyList[i].ATOM_Deal__c )
                          {
                              optyId.add(newOptyList[i].Id);
                              selectedOptys.add(newOptyList[i]);
                          }
                      }
                      if( optyId!=null && optyId.size()>0 )
                      {
                          updatePPRecords = [SELECT Deal_Id__c,Product_Record_Type__c,SP_Discount_Percentage__c,Type__c,Discountable__c,List_Price__c,discount_price__c,Discounted_Price__c, Record_Type__c,Usage_Charges__c,Discounted_Usage_Charge__c FROM Product_Pricing__c pr WHERE pr.SP_Product__c IN (SELECT Id FROM SPProduct__c WHERE Deal__c IN:optyId) AND (Type__c= :SIConstants.TYPE_MRC OR Type__c= :SIConstants.TYPE_NRC OR Type__c= :SIConstants.TYPE_MUC)];
                        if( updatePPRecords!=null && SIConstants.removeSpecialpricing && updatePPRecords.size()>0 )
                        {
                            SIConstants.removeSpecialpricing=false;
                            List<Promotion_Engine_Junction__c> promoEngineRecordsWithThirdRank = [select Id, Activation_Date__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c, Input_Field__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Opportunity__c from Promotion_Engine_Junction__c where Eligible__c = true and Rank__c = 3 AND Opportunity__c IN:optyId order by Rank__c ];
                            List<Promotion_Engine_Junction__c> promoEngineRecords = [select Id, Activation_Date__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c, Input_Field__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Opportunity__c from Promotion_Engine_Junction__c where Eligible__c = true and Opportunity__c IN:optyId AND ID NOT IN:promoEngineRecordsWithThirdRank order by Rank__c ];
                            
                            Map<String, List<Promotion_Engine_Junction__c>> mapPERankedThirdGroupedByProduct = new Map<String, List<Promotion_Engine_Junction__c>>();
                            for( Promotion_Engine_Junction__c peThirdItem :promoEngineRecordsWithThirdRank ){
                                
                                List<Promotion_Engine_Junction__c> tempList = new List<Promotion_Engine_Junction__c>();
                                for( Promotion_Engine_Junction__c peThirdItemIterable :promoEngineRecordsWithThirdRank ){
                                    if( peThirdItem.Valid_For_Product__c == peThirdItemIterable.Valid_For_Product__c){
                                            tempList.add( peThirdItemIterable );
                                            mapPERankedThirdGroupedByProduct.put( peThirdItem.Valid_For_Product__c, tempList );
                                    }   
                                }
                            }  
                            Map<Promotion_Engine_Junction__c, Decimal> mapPEFinalDiscount = new Map<Promotion_Engine_Junction__c, Decimal>();
                            for(String eachProduct : mapPERankedThirdGroupedByProduct.keyset()){
                                Decimal discountPerc;
                                Integer loopCounter = 0;
                                Promotion_Engine_Junction__c promoJunciton = new Promotion_Engine_Junction__c();
                                for( Promotion_Engine_Junction__c PromoJuncitonItem : mapPERankedThirdGroupedByProduct.get( eachProduct ) ){
                                    if( loopCounter == 0 ){
                                        PromoJunciton = PromoJuncitonItem;
                                        discountPerc = PromoJuncitonItem.Discount_Percentage__c;
                                    }else{
                                        discountPerc += PromoJuncitonItem.Discount_Percentage__c; 
                                    }
                                    loopCounter++;
                                }
                                mapPEFinalDiscount.put(PromoJunciton, discountPerc);
                            }
                            
                            promoEngineRecords.addAll(mapPEFinalDiscount.keySet()); 
                            
                            List<Promotion_Engine_Junction__c> listFinalPromoRecords = [select Id, Activation_Date__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c, Input_Field__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Opportunity__c from Promotion_Engine_Junction__c where Eligible__c = true and Id IN:promoEngineRecords order by Rank__c];
                            
                            for(Product_Pricing__c prodPric:updatePPRecords)
                            {
                                prodPric.Discounted_Price__c=null;
                            }
                            Boolean checkProductType;
                          
                              if( listFinalPromoRecords!=null  && listFinalPromoRecords.size() > 0 )
                              {
                                  finalPPRecords = SIHelper.calculatePromotionDiscountOnPP(selectedOptys, listFinalPromoRecords, updatePPRecords, mapPEFinalDiscount);
                                  //Update special pricing values
                                  try{
                                  update finalPPRecords;
                                  }Catch(DMLException exe){                                exe.getMessage();                              }
                                  spProductlist = [select Id, Competitive_Pricing_Status__c, Discount_Amount__c, SP_Discount_Percentage__c, Discounted_Percentage__c from SPProduct__c where Deal__c IN:optyId];
                                  if( spProductlist!=null && spProductlist.size() > 0 )
                                  {
                                      for(SPProduct__c spp :spProductlist)
                                      {
                                          spp.Competitive_Pricing_Status__c = null;
                                          spp.Discount_Amount__c=null;
                                          spp.SP_Discount_Percentage__c=null;
                                          spp.Discounted_Percentage__c=null;
                                      }
                                      try{
                                      update spProductlist;
                                      }Catch(DMLException exe){                                   exe.getMessage();                                  }
                                  }
                              }
                        }
                      }
                  }
              }catch(Exception excep) {           
              excep.getMessage();      
              }
            }
            
            /*Name:reApplyPromotionLogicCheck
             * Description:
             */
             public void reApplyPromotionLogicCheck( SObject[] oldObjects, SObject[] updatedObjects, Boolean isUpdate )
            {
              try{
                list<Opportunity> newOptyList =updatedObjects;
                list<Opportunity> oldOptyList =oldObjects;
                list<Opportunity> newOptyListAcctAutoDelreg = new list<Opportunity>();
                list<Opportunity> oldOptyListAcctAutoDelreg = new list<Opportunity>();
                list<Opportunity> newOptyListAutoDelreg = new list<Opportunity>();
                list<Opportunity> oldOptyListAutoDelreg = new list<Opportunity>();
                Map<id,Opportunity> oppMap = new Map<id,Opportunity>([select id ,Name,Account.Auto_Deal_Registration__c,Account.ATOM_Account__c from Opportunity where id in : newOptyList  ]);
                for ( Integer i=0; i<newOptyList.size(); i++ ) {
                    if(OppMap != null  && OppMap.Containskey(newOptyList[i].Id)  && (OppMap.get(newOptyList[i].Id).Account.Auto_Deal_Registration__c) && (OppMap.get(newOptyList[i].Id).Account.ATOM_Account__c )){
                        newOptyListAcctAutoDelreg.add(newOptyList[i]);  
                        if(isUpdate) {
                            OldOptyListAcctAutoDelreg.add(oldOptyList[i]);                       
                        } 
                            
                    
                    } else if(OppMap != null  && OppMap.Containskey(newOptyList[i].Id)  && (!OppMap.get(newOptyList[i].Id).Account.Auto_Deal_Registration__c)){ 
                        newOptyListAutoDelreg.add(newOptyList[i]);  
                        if(isUpdate) {
                            OldOptyListAutoDelreg.add(oldOptyList[i]);  
                        } 
                        
                        }            
                    
                }
                
                if(newOptyListAcctAutoDelreg.size() > 0) {
                    reApplyPromotionLogicWithAcctCheck( OldOptyListAcctAutoDelreg, newOptyListAcctAutoDelreg, isUpdate );
                }
                if(newOptyListAutoDelreg.size() > 0) {
                    reApplyPromotionLogic( OldOptyListAutoDelreg, newOptyListAutoDelreg, isUpdate );
                }
            }
            catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
           
            
            //US284572:Deal Reg Re-Request--> Re-Applying promotion logic
             /*Name:reApplyPromotionLogicWithAcctCheck
              * Description:
              */
            public void reApplyPromotionLogicWithAcctCheck( SObject[] oldObjects, SObject[] updatedObjects, Boolean isUpdate )
            { 
            try{
                list<Opportunity> newOptyList =updatedObjects;
                list<Opportunity> oldOptyList =oldObjects;
                set<Id> optyIDToDeletePEJ =  new set<Id>(); 
                list<Opportunity> createPEJOnOpty = new list<Opportunity>();
                List<Criteria__c> criteriaRecords = new List<Criteria__c>();
                List<Promotion_Engine__c> promoEngineRecords  = new List<Promotion_Engine__c>();
                map<Integer,Criteria__c> criteriaResultsWithRecord = new  map<Integer,Criteria__c>();//Mohsin
                map<Integer,Boolean> criteriaResults = new  map<Integer,Boolean>();
                map<Integer,Integer> criteriaAndOrVal = new map<Integer,Integer>();
                list<Promotion_Engine_Junction__c> insertPEJRecs = new list<Promotion_Engine_Junction__c>();
                boolean applydiscounts = false;
                list<Opportunity> processOptyList = new list<Opportunity>(); 
                
                if( !newOptyList.isEmpty() && newOptyList!= null )
                {
                    
                    for ( Integer i=0; i<newOptyList.size(); i++ ){
                        
                        String opptyServiceType = newOptyList[i].Service_type__c;
                        if(opptyServiceType == UtilityConstant.AMIS) {
                           opptyServiceType = SIConstants.SERVICETYPEMIS;
                        }
                        
                        if(isUpdate ){
                          //from ?Deal Reg Approved? to ?Deal Reg Requested? AND Deal Reg Approved Flag = True AND ATOM Deal = True AND CI Promo Complete flag = True
                            if(((oldOptyList[i].StageName == SIConstants.OPP_STAGE_Approved && newOptyList[i].StageName == SIConstants.OPP_STAGE_REQUESTED && !oldOptyList[i].CI_Promo_Complete__c && newOptyList[i].CI_Promo_Complete__c && newOptyList[i].Deal_Reg_Approved__c) && (!newOptyList[i].Remove_special_pricing__c && !oldOptyList[i].Remove_special_pricing__c) && newOptyList[i].ATOM_Deal__c ) || (newOptyList[i].StageName == SIConstants.OPP_STAGE_REQUESTED && !oldOptyList[i].CI_Promo_Complete__c && newOptyList[i].CI_Promo_Complete__c && newOptyList[i].ATOM_Deal__c && !newOptyList[i].Deal_Reg_Approved__c ))
                          //   if( newOptyList[i].StageName == SIConstants.OPP_STAGE_REQUESTED  ) //mohsin 8/8/2016
                             {
                                OptyIDToDeletePEJ.add(newOptyList[i].Id);   
                                createPEJOnOpty.add(newOptyList[i]);                
                             }
                        }
                        else
                        {
                            if( newOptyList[i].StageName == SIConstants.OPP_STAGE_REQUESTED && newOptyList[i].CI_Promo_Complete__c && newOptyList[i].ATOM_Deal__c && !newOptyList[i].Deal_Reg_Approved__c )
                            {
                                
                                OptyIDToDeletePEJ.add(newOptyList[i].Id);   
                                createPEJOnOpty.add(newOptyList[i]);
                            }
                        }
                        
                        if( OptyIDToDeletePEJ!=null && SIConstants.reapplyPromotions && OptyIDToDeletePEJ.size()>0 ){
                            SIConstants.reapplyPromotions = false;
                            SIConstants.removeSpecialpricing=false;
                            List<Promotion_Engine_Junction__c> deletePEJ = [select Id from Promotion_Engine_Junction__c where Opportunity__c IN: OptyIDToDeletePEJ];
                            if( deletePEJ!=null && deletePEJ.size()>0 )
                            {
                                delete  deletePEJ;
                            }
                            
                            promoEngineRecords = [select Id,Default_Deal_Reg_Decision__c, Activation_Date__c,Product_Discount_Percentage__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c,OptyInputField__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Operator_Formula__c,Input_Data_Type__c,Number_Of_Criterias__c,Category_Order__c  from Promotion_Engine__c where Currently_Active__c = true and Rank__c in(0 ,2)and Activation_Date__c   <= :  system.today() and Expiration_Date__c >= : system.today() order by Rank__c desc,Category_Order__c ];
                            criteriaRecords = [ select id,Deal_Reg_Decision__c,Deal_Reg_Discount__c,Criteria_Name__c,AndOrFormula__c, Input_Data_Type__c, Input_Field__c, Operator__c, Operator_Formula__c, Value__c,CriteriaNumber__c, Promotion_Engine__c from Criteria__c  where Promotion_Engine__c in : promoEngineRecords order by CriteriaNumber__c];
                            
                            String lVal,rVal;                        
                            Boolean insertPromoRecord;
                            String dealregDecision;
                            Decimal deagRegDiscountPercent;                       
                            Boolean uniqueOptylist;                               
                            Boolean directConsumption; 
                            Boolean skipDealReg;
                            Boolean validForProduct;
                            Boolean queryReady; 
                            Boolean dupEndCustForProd;
                            Date dt;
                            String stageValue = SpecialCharacterConstant.CONCAT;
                            String autoDealRegStatus = SpecialCharacterConstant.CONCAT;
                            
                            String recordName;
                            Boolean metTelAccount = false;            
                            for( Opportunity opty : createPEJOnOpty ){
                                for( Promotion_Engine__c promE : promoEngineRecords ){
                                    for( Criteria__c critera : criteriaRecords ){
                                        if(critera.Promotion_Engine__c == promE.Id){    
                                            if(critera.Input_Data_Type__c == SpecialCharacterConstant.STATIC_STRING){
                                                if((PromE.Valid_For_Product__c != null ||PromE.Valid_For_Product__c != SpecialCharacterConstant.CONCAT) && (opptyServiceType.equalsIgnoreCase(PromE.Valid_For_Product__c)) && PromE.Category_Order__c == UtilityConstant.SIVARConst_3) { 
                                                    if(critera.Input_Field__c == UtilityConstant.DEALREG_APPROVAL_DATE_C)  {   
                                                        recordName = critera.Value__c;
                                                        String regex = UtilityConstant.A_ZA_Z_1_x;
                                                        String recordNumber = recordName.replaceAll(regex, '').trim();
                                                        // if string contains months then add months else if string contain days add days , skipping the first letter for case sensitivity 
                                                        if ( recordName.containsIgnoreCase(UtilityConstant.DAYS)){
                                                            dt = system.today().addDays(-1*(integer.valueof(recordNumber)));
                                                        }
                                                        else if ( recordName.containsIgnoreCase(UtilityConstant.MONTHS)){
                                                             dt = system.today().addMonths(-1*(integer.valueof(recordNumber)));
                                                        }
                                                    }
                                                    
                                                    if(critera.Input_Field__c.equalsIgnoreCase(UtilityConstant.STAGENAME)) { 
                                                         stageValue = critera.Value__c;                                                 
                                                         queryReady = true;
                                                    }   
                                                }
                                            }
                                        }
                                    }
                                }  
                            }
                            
                            String optyFuzzyEndCust = newOptyList[0].End_Customer_Name__c;
                            String optyEndCust = newOptyList[0].EndCustomerName__c;
                            String optyProdName = newOptyList[0].Service_type__c;  
                            String optyAccName =  newOptyList[0].Account_Name__c;  
                            String Address = newOptyList[0].End_Cust_Address__c;
                            ID optyAccount =  newOptyList[0].AccountId;
                            List <Opportunity> existingQuoteCheck = new List<Opportunity> ();
                            Boolean existingQuoteDiffSPCheck  = false;

                            System.debug('Address11111111==='+Address);
                            List <Opportunity> endCustCheck = new List<Opportunity> ();
                            endCustCheck = [Select Id, Account_Name__c, Service_type__c, EndCustomerName__c,End_Customer_Name__c, End_Customer_Address__c, EndCustomerCity__c, EndCustomerState__c, EndCustomerZip__c from Opportunity where Account_Name__c = :optyAccName and ((End_Customer_Name__c = :optyFuzzyEndCust) or (EndCustomerName__c = :optyEndCust)) and Service_type__c = :optyProdName and Deal_Reg_Approval_Date__c > :dt and stageName not in(:stageValue)  order by Deal_Reg_Approval_Date__c asc ]   ;
                            existingQuoteCheck = [Select Id,Deal_Reg_Discount_Percentage__c, Account_Name__c, Service_type__c, EndCustomerName__c,End_Customer_Name__c, End_Customer_Address__c, EndCustomerCity__c, EndCustomerState__c, EndCustomerZip__c from Opportunity where Account_Name__c = :optyAccName and ((End_Customer_Name__c = :optyFuzzyEndCust) or (EndCustomerName__c = :optyEndCust)) and Service_type__c = :optyProdName and Deal_Reg_Approval_Date__c > :dt and stageName not in(:stageValue) and End_Cust_Address__c =: Address  order by Deal_Reg_Approval_Date__c desc limit 1 ]   ;
                            System.debug('existingQuoteCheck==='+existingQuoteCheck);       
                            SIOpptyWithoutSharingHelper siOpphelper = new SIOpptyWithoutSharingHelper();
                            existingQuoteDiffSPCheck = siOpphelper.CheckDiffSpOpty(optyAccount ,optyFuzzyEndCust,optyEndCust ,optyProdName,optyAccName ,Address,dt,stageValue);
                    
                            System.debug('existingQuoteWDiffSPCheck==='+existingQuoteDiffSPCheck);
                            List<Promotion_Engine__c> peCategory4Records = new List<Promotion_Engine__c>();
                            peCategory4Records = [select Id, Product_Discount_Percentage__c, Default_Deal_Reg_Decision__c, Currently_Active__c, Discount_Percentage__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Category_Order__c,Expiration_Date__c, Activation_Date__c  from Promotion_Engine__c where Currently_Active__c = true and Rank__c in(0) and Category_Order__c in('4')and Activation_Date__c   <= :  system.today() and Expiration_Date__c >= : system.today()];
                            Map<String,Promotion_Engine__c> discountPercentageMap = new Map<String,Promotion_Engine__c>();
                            for(Promotion_Engine__c pe : peCategory4Records)
                            {     
                                if(opptyServiceType.equalsIgnoreCase(pe.Valid_For_Product__c)){
                                    discountPercentageMap.put(pe.Valid_For_Product__c,pe); 
                                }
                            }
                            for( Opportunity opty : createPEJOnOpty )
                            {
                                uniqueOptylist = false;
                                skipDealReg = false;
                                
                                dupEndCustForProd = false; 
                                
                                
                                for( Promotion_Engine__c promE : promoEngineRecords ){
                                
                                    if(!skipDealReg) {    
                                        insertPromoRecord = false;
                                        directConsumption = false;
                                        
                                        CriteriaResults.clear();
                                        for( Criteria__c critera : criteriaRecords ){
                                            if(critera.Promotion_Engine__c == promE.Id){    
                                                if(critera.Input_Data_Type__c == SpecialCharacterConstant.STATIC_STRING){
                                                    if(critera.Input_Field__c.equalsIgnoreCase(UtilityConstant.DIRECTCOSUMPTION_C)) {
                                                        if(opty.Direct_cosumption__c) {
                                                            directConsumption = true;
                                                        }
                                                    } else if(critera.Input_Field__c ==UtilityConstant.SPACCOUNT_NAME_C) {
                                                        if(critera.Value__c.equalsIgnoreCase(opty.Account_Name__c)) {
                                                            insertPromoRecord = true;
                                                            skipDealReg = true;
                                                            dealregDecision = critera.Deal_Reg_Decision__c;
                                                            deagRegDiscountPercent = critera.Deal_Reg_Discount__c; 
                                                        }
                                                    } else if((PromE.Valid_For_Product__c != null ||PromE.Valid_For_Product__c != SpecialCharacterConstant.CONCAT) && (opptyServiceType.equalsIgnoreCase(PromE.Valid_For_Product__c))) { 
                                                        if(PromE.Category_Order__c == UtilityConstant.SIVARConst_3){
                                                            if(PromE.Promotion_Name__c.containsIgnoreCase('Duplicate SP, EC')){
                                                                skipDealReg = true;
                                                                dealregDecision = critera.Deal_Reg_Decision__c;
                                                                deagRegDiscountPercent = critera.Deal_Reg_Discount__c;
                                                                autoDealRegStatus = PromE.Promotion_Name__c;
                                                                if(existingQuoteCheck.size() > 0 && dealregDecision != null && existingQuoteCheck[0].Deal_Reg_Discount_Percentage__c != null){
                                                                    deagRegDiscountPercent = existingQuoteCheck[0].Deal_Reg_Discount_Percentage__c;
                                                                        
                                                                    autoDealRegStatus = PromE.Promotion_Name__c;
                                                                    dealregDecision = PromE.Default_Deal_Reg_Decision__c;       
                                                                }
                                                                else if(existingQuoteDiffSPCheck == true && dealregDecision != null ){
                                                                    deagRegDiscountPercent = 0.00;
                                                                    autoDealRegStatus = PromE.Promotion_Name__c;
                                                                    dealregDecision = PromE.Default_Deal_Reg_Decision__c;
                                                                    
                                                                }
                                                                else if(dealregDecision != null){
                                                                    if(discountPercentageMap.get(opptyServiceType).Product_Discount_Percentage__c != null && discountPercentageMap.get(opptyServiceType).Product_Discount_Percentage__c > 0){
                                                                            deagRegDiscountPercent = discountPercentageMap.get(opptyServiceType).Product_Discount_Percentage__c;
                                                                    }
                                                                    else{
                                                                        deagRegDiscountPercent = discountPercentageMap.get(opptyServiceType).Discount_Percentage__c;
                                                                    }
                                                                    autoDealRegStatus = discountPercentageMap.get(opptyServiceType).Promotion_Name__c;
                                                                    dealregDecision = discountPercentageMap.get(opptyServiceType).Default_Deal_Reg_Decision__c;
                                                                    
                                                                
                                                                }
                                                                insertPromoRecord = true;
                                                            }
                                                            else{
                                                                skipDealReg = true;
                                                                dealregDecision = critera.Deal_Reg_Decision__c;
                                                                deagRegDiscountPercent = critera.Deal_Reg_Discount__c;
                                                                autoDealRegStatus = PromE.Promotion_Name__c;
                                                                if(endCustCheck.size() == 0 && dealregDecision != null){
                                                                    dealregDecision = discountPercentageMap.get(opptyServiceType).Default_Deal_Reg_Decision__c;
                                                                    if(discountPercentageMap.get(opptyServiceType).Product_Discount_Percentage__c != null && discountPercentageMap.get(opptyServiceType).Product_Discount_Percentage__c > 0){
                                                                            deagRegDiscountPercent = discountPercentageMap.get(opptyServiceType).Product_Discount_Percentage__c;
                                                                    }
                                                                   else{
                                                                        deagRegDiscountPercent = discountPercentageMap.get(opptyServiceType).Discount_Percentage__c;
                                                                   }
                                                                    autoDealRegStatus = discountPercentageMap.get(opptyServiceType).Promotion_Name__c;
                                                                   
                                                                }
                                                                insertPromoRecord = true;
                                                            }
                                                        } 
                                                    } else if(critera.Input_Field__c.equalsIgnoreCase(UtilityConstant.SPDISCOUNT_C)) {
                                                        lVal=String.valueOf(opty.get(critera.Input_Field__c));
                                                        rVal=critera.Value__c;                                              
                                                        if(lVal==rVal){
                                                            insertPromoRecord = true;
                                                            dealregDecision = critera.Deal_Reg_Decision__c;
                                                            deagRegDiscountPercent = promE.Discount_Percentage__c;  
                                                        }
                                                    }
                                                    if(directConsumption) {
                                                        if(critera.Criteria_Name__c.equalsIgnoreCase(UtilityConstant.CFUCHECK)) {
                                                            String endCustDet = opty.EndCustomerName__c+opty.End_Customer_Address__c+opty.EndCustomerCity__c+opty.EndCustomerState__c+opty.EndCustomerZip__c ;
                                                            String actCustDet = opty.Account_Name__c+opty.Account_Address__c+opty.Account_City__c+opty.Account_State__c+opty.Account_Zipcode__c ;
                                                            if(endCustDet.equalsIgnoreCase(actCustDet)) {                                                        
                                                                skipDealReg = true;
                                                            } else {
                                                                insertPromoRecord = true;
                                                                skipDealReg = true;
                                                                dealregDecision = critera.Deal_Reg_Decision__c;
                                                                deagRegDiscountPercent = critera.Deal_Reg_Discount__c;   
                                                            }
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    
                                    
                                        //Insert PEJ on opty.
                                        if( insertPromoRecord ){
                                           Promotion_Engine_Junction__c pEJ = new Promotion_Engine_Junction__c();
                                           pEJ.Promotion_Engine__c = promE.Id;
                                           pEJ.BCC_Code__c = promE.BCC_Code__c;
                                           system.debug('@@@/*Updated as part of US344706*/ trigger before if ');
                                           if((opty.Service_type__c != 'AVPN' && opty.Service_type__c != 'AMIS') || (string.isNotBlank(opty.MACD_Type__c))){
                                                system.debug('@@@/*Updated as part of US344706*/ trigger entered if ');
                                                pEJ.Currently_Active__c = promE.Currently_Active__c;
                                                pEJ.Discount_Percentage__c = deagRegDiscountPercent;
                                                //Discount will be overrided for Anira Product on reapply                                   
                                                pEJ.Eligible__c = true;
                                            }
                                           pEJ.Opportunity__c = opty.Id;
                                           pEJ.Promotion_Description__c = promE.Promotion_Description__c;
                                           if(autoDealRegStatus != null && autoDealRegStatus != SpecialCharacterConstant.CONCAT){
                                                pEJ.Promotion_Name__c =autoDealRegStatus;
                                               }
                                               else{
                                                pEJ.Promotion_Name__c = promE.Promotion_Name__c;
                                               }
                                           
                                           if(promE.Rank__c == 2) {
                                              pEJ.Rank__c = promE.Rank__c;
                                           } else {
                                             pEJ.Rank__c = 4;
                                           }
                                           
                                           pEJ.Valid_For_Product__c = promE.Valid_For_Product__c;
                                           insertPEJRecs.add(pEJ);
                                           uniqueOptylist = true;
                                        }
                                    }
                                }
                                
                                
                                Boolean rank4Promo = false;
                                for( Promotion_Engine_Junction__c pej : insertPEJRecs ) {
                                    if(pej.Rank__c == 4) {
                                        rank4Promo = true;                                
                                    }
                                }
                                if(!rank4Promo) {
                                    /* This logic will kick of when Auto deal reg is on but there were auto deal reg flags conditions as true to create rank4 promotions. As the manual deal reg process expects rank 4 promotion, this will create a place holder.*/
                                    List<Promotion_Engine__c> promoEngineRecordsFor4  = new List<Promotion_Engine__c>();                      
                                    promoEngineRecordsFor4 = [select Id, Activation_Date__c, BCC_Code__c, Currently_Active__c, Discount_Percentage__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c from Promotion_Engine__c where Currently_Active__c = true and Promotion_Name__c = 'Deal Reg Discount' and Rank__c = 4 limit 1];
                                    if(promoEngineRecords.size() > 0) {
                                     for( Promotion_Engine__c promE : promoEngineRecordsFor4 )   {
                                       Promotion_Engine_Junction__c pEJ = new Promotion_Engine_Junction__c();
                                               pEJ.Promotion_Engine__c = promE.Id;
                                               pEJ.BCC_Code__c = promE.BCC_Code__c;
                                               system.debug('@@@/*Updated as part of US344706*/ trigger before if ');
                                               if((opty.Service_type__c != 'AVPN' && opty.Service_type__c != 'AMIS') || (string.isNotBlank(opty.MACD_Type__c))){
                                                    system.debug('@@@/*Updated as part of US344706*/ trigger entered if ');
                                                    pEJ.Currently_Active__c = promE.Currently_Active__c;
                                                    pEJ.Discount_Percentage__c = promE.Discount_Percentage__c;                       
                                                    pEJ.Eligible__c = true;
                                                }
                                               pEJ.Opportunity__c = opty.Id;
                                               pEJ.Promotion_Description__c = promE.Promotion_Description__c;
                                               pEJ.Promotion_Name__c = promE.Promotion_Name__c;
                                               pEJ.Rank__c = promE.Rank__c;                       
                                               pEJ.Valid_For_Product__c = promE.Valid_For_Product__c;
                                               insertPEJRecs.add(pEJ);
                                               uniqueOptylist = true;
                                       
                                     }                 
                                    }
                                  
                                }
                                
                                 if( uniqueOptylist && opty.Deal_Reg_Approved__c )//Updated logic form opty.StageName != SIConstants.OPP_STAGE_REQUESTED to Deal_Reg_Approved__c
                                {
                                    processOptyList.add(opty);
                                }
                            
                                    
                                     
                            }
                            
                           
                         }
                        
                                
                                
                            }
                              
                                      
                            
                            //insert list of promotion engine junction records to Opportunity
                            if( insertPEJRecs!=null && insertPEJRecs.size()>0 )
                            {
                                insert insertPEJRecs;
                                applydiscounts = true;
                            }
                            //Applying promotions on opportunity
                            if( applydiscounts )
                            {
                                SIHelper.genericPromotionEnginelogic(processOptyList);
                            }
                        }             
            }  
catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}           
            
            
         
           
            
            //US284572:Deal Reg Re-Request--> Re-Applying promotion logic
            /*Name:reApplyPromotionLogic
             * Description:
             */
            public void reApplyPromotionLogic( SObject[] oldObjects, SObject[] updatedObjects, Boolean isUpdate )
            {
                try{
                list<Opportunity> newOptyList =updatedObjects;
                list<Opportunity> oldOptyList =oldObjects;
                set<Id> optyIDToDeletePEJ =  new set<Id>(); 
                list<Opportunity> createPEJOnOpty = new list<Opportunity>();
                List<Criteria__c> criteriaRecords = new List<Criteria__c>();
                List<Promotion_Engine__c> promoEngineRecords  = new List<Promotion_Engine__c>();
                map<Integer,Boolean> criteriaResults = new  map<Integer,Boolean>();
                map<Integer,Integer> criteriaAndOrVal = new map<Integer,Integer>();
                list<Promotion_Engine_Junction__c> insertPEJRecs = new list<Promotion_Engine_Junction__c>();
                boolean applydiscounts = false;
                list<Opportunity> processOptyList = new list<Opportunity>(); 
                
                if( !newOptyList.isEmpty() && newOptyList!= null )
                {
                     for ( Integer i=0; i<newOptyList.size(); i++ )
                     {
                        if( isUpdate )
                        {
                          //from ?Deal Reg Approved? to ?Deal Reg Requested? AND Deal Reg Approved Flag = True AND ATOM Deal = True AND CI Promo Complete flag = True
                             if(((oldOptyList[i].StageName == SIConstants.OPP_STAGE_Approved && newOptyList[i].StageName == SIConstants.OPP_STAGE_REQUESTED && !oldOptyList[i].CI_Promo_Complete__c && newOptyList[i].CI_Promo_Complete__c && newOptyList[i].Deal_Reg_Approved__c) && (!newOptyList[i].Remove_special_pricing__c && !oldOptyList[i].Remove_special_pricing__c) && newOptyList[i].ATOM_Deal__c ) || (newOptyList[i].StageName == SIConstants.OPP_STAGE_REQUESTED && !oldOptyList[i].CI_Promo_Complete__c && newOptyList[i].CI_Promo_Complete__c && newOptyList[i].ATOM_Deal__c && !newOptyList[i].Deal_Reg_Approved__c ))
                             {
                                OptyIDToDeletePEJ.add(newOptyList[i].Id);   
                                createPEJOnOpty.add(newOptyList[i]);                
                             }
                        }
                        else
                        {
                            if( newOptyList[i].StageName == SIConstants.OPP_STAGE_REQUESTED && newOptyList[i].CI_Promo_Complete__c && newOptyList[i].ATOM_Deal__c && !newOptyList[i].Deal_Reg_Approved__c )
                            {
                                OptyIDToDeletePEJ.add(newOptyList[i].Id);   
                                createPEJOnOpty.add(newOptyList[i]);
                            }
                        }
                         if( OptyIDToDeletePEJ!=null && SIConstants.reapplyPromotions && OptyIDToDeletePEJ.size()>0 )
                         {
                            SIConstants.reapplyPromotions = false;
                            SIConstants.removeSpecialpricing=false;
                            List<Promotion_Engine_Junction__c> deletePEJ = [select Id from Promotion_Engine_Junction__c where Opportunity__c IN: OptyIDToDeletePEJ];
                            if( deletePEJ!=null && deletePEJ.size()>0 )
                            {
                                delete  deletePEJ;
                            }
                            promoEngineRecords = [select Id, Activation_Date__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c, OptyInputField__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Operator_Formula__c,Input_Data_Type__c,Number_Of_Criterias__c from Promotion_Engine__c where Currently_Active__c = true and Rank__c <> 0 order by Rank__c ];
                            criteriaRecords = [ select id, Criteria_Name__c,AndOrFormula__c, Input_Data_Type__c, Input_Field__c, Operator__c, Operator_Formula__c, Value__c,CriteriaNumber__c, Promotion_Engine__c from Criteria__c  order by CriteriaNumber__c]; 
                            String lVal,rVal;
                            Double declval,decrval;
                            Boolean insertRecord;
                            Boolean insertPromoRecord;
                            Integer loopCounter;
                            Boolean uniqueOptylist;
                            Boolean aniraProd;
                            Id endCustomer;
                            Map<ID,Decimal> aniraCustDiscount = new Map<ID,Decimal>();
                            Set<ID> aniraCustSet = new Set<ID>(); 
                          //  Boolean firstTimeOppty; 
                         //   List<Opportunity> autoApprovalAniraOpptys = new List<Opportunity>(); 
                            map<string, SPProduct__c> opptyPrevProductMap;                     
                            for( Opportunity opty : createPEJOnOpty ) {
                                if(opty.Service_type__c == UtilityConstant.ANIRA) {                              
                                      aniraCustSet.add(opty.End_Customer__c); 
                                   //   autoApprovalAniraOpptys.add(opty);                              
                                                                 
                                }
                            }
                            if(aniraCustSet.size() > 0) {
                                List<End_Customer__c> aniraSiteLIst= [select  Id,Anira_Custom_Discount__c  from End_Customer__c WHERE Id in :aniraCustSet];
                                for( End_Customer__c aniraSite: aniraSiteLIst) {                            
                                   aniraCustDiscount.put(aniraSite.Id ,aniraSite.Anira_Custom_Discount__c );                              
                                }                            
                             //   opptyPrevProductMap = createPrevProductMap(autoApprovalAniraOpptys);                        
                            }
                              
                            
                            for( Opportunity opty : createPEJOnOpty )
                            {
                                uniqueOptylist = false;
                                for( Promotion_Engine__c promE : promoEngineRecords )
                                {
                                    insertPromoRecord = false;
                                    CriteriaResults.clear();
                                    for( Criteria__c critera : criteriaRecords )
                                    {
                                        if(critera.Promotion_Engine__c == promE.Id)
                                        {
                                            loopCounter = 0;
                                            insertRecord=false;
                                            if(critera.Input_Data_Type__c == SpecialCharacterConstant.STATIC_STRING)
                                            {
                                                lVal=String.valueOf(opty.get(critera.Input_Field__c));
                                                rVal=critera.Value__c;
                                                if(critera.Operator_Formula__c==2){
                                                    if(lVal==rVal){
                                                        insertRecord=true;
                                                        aniraProd = false;
                                                        if(critera.Input_Field__c == UtilityConstant.SERVICETYPE_C && opty.Service_type__c == UtilityConstant.ANIRA) {
                                                           aniraProd = true;
                                                           endCustomer = opty.End_Customer__c;
                                                        }
                                                         if(opty.Service_type__c == UtilityConstant.ANIRA && critera.Input_Field__c ==UtilityConstant.PROMODEAL_REG_C) { 
                                                            insertRecord=false;                                                          
                                                        }
                                                    }
                                                }
                                                if(critera.Operator_Formula__c==3){
                                                    if(lVal!=rVal){
                                                        insertRecord=true;
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                if(critera.Input_Field__c!=null && critera.Value__c!=null)
                                                {
                                                    declval=Double.valueOf(opty.get(critera.Input_Field__c));
                                                    decrval=Double.ValueOf(critera.Value__c);
                                                    if(critera.Operator_Formula__c==0){
                                                        
                                                        if(declval>decrval){
                                                            insertRecord=true;
                                                        }
                                                        
                                                    }
                                                    if(critera.Operator_Formula__c==1){
                                                        
                                                        if(declval<decrval){
                                                            insertRecord=true;
                                                        }
                                                    }
                                                    if(critera.Operator_Formula__c==2){
                                                        
                                                        if(declval==decrval){
                                                            insertRecord=true;
                                                        }
                                                        
                                                    }
                                                    if(critera.Operator_Formula__c==3){
                                                        
                                                        if(declval!=decrval){
                                                            insertRecord=true;
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            //Applying logic to get results of promotion engine.
                                            if( insertRecord )
                                            {
                                                CriteriaResults.put((Integer)critera.CriteriaNumber__c,insertRecord);
                                                CriteriaAndOrVal.put((Integer)critera.CriteriaNumber__c,(Integer)critera.AndOrFormula__c);
                                            }
                                            else
                                            {
                                                CriteriaResults.put((Integer)critera.CriteriaNumber__c,insertRecord);
                                                CriteriaAndOrVal.put((Integer)critera.CriteriaNumber__c,(Integer)critera.AndOrFormula__c);
                                            }
                                        }
                                    }
                                    
                                    //Check eligibilty of criteria for an individual records
                                    if(promE.Number_Of_Criterias__c ==1)//for one criteria record
                                    {
                                        if(CriteriaResults.get(1))
                                        {
                                            insertPromoRecord = true;
                                        }
                                    }
                                    if(promE.Number_Of_Criterias__c ==2)//for 2 criteria records
                                    {
                                        if(CriteriaAndOrVal.get(1) == 1)
                                        {
                                            if(CriteriaResults.get(1) && CriteriaResults.get(2))
                                            {
                                                insertPromoRecord = true;
                                            }
                                        }
                                        else
                                        {
                                             if(CriteriaResults.get(1) || CriteriaResults.get(2))
                                            {
                                                insertPromoRecord = true;
                                            }
                                        }
                                    }
                                    if(promE.Number_Of_Criterias__c ==3)//for 3 criteria records
                                    {
                                        if( CriteriaAndOrVal.get(1) == 1 && CriteriaAndOrVal.get(2) == 1 )
                                        {
                                            if(CriteriaResults.get(1) && CriteriaResults.get(2) && CriteriaResults.get(3))
                                            {
                                                insertPromoRecord = true;
                                            }
                                        }
                                        else if(CriteriaAndOrVal.get(1) == 1 && CriteriaAndOrVal.get(2) == 2 )
                                        {
                                            if((CriteriaResults.get(1) && CriteriaResults.get(2)) || CriteriaResults.get(3))
                                            {
                                                insertPromoRecord = true;
                                            }
                                        }
                                        else if(CriteriaAndOrVal.get(2) == 2 && CriteriaAndOrVal.get(1) == 1)
                                        {
                                            if((CriteriaResults.get(1) || CriteriaResults.get(2)) && CriteriaResults.get(3))
                                            {
                                                insertPromoRecord = true;
                                            }
                                        }
                                        else
                                        {
                                            if((CriteriaResults.get(1) || CriteriaResults.get(2)) || CriteriaResults.get(3))
                                            {
                                                insertPromoRecord = true;
                                            }
                                        }
                                    }
                                    
                                    //Insert PEJ on opty.
                                    if( insertPromoRecord )
                                    {
                                       Promotion_Engine_Junction__c pEJ = new Promotion_Engine_Junction__c();
                                       pEJ.Promotion_Engine__c = promE.Id;
                                       pEJ.BCC_Code__c = promE.BCC_Code__c;
                                       system.debug('@@@/*Updated as part of US344706*/ trigger before if ');
                                       if((opty.Service_type__c != 'AVPN' && opty.Service_type__c != 'AMIS') || (string.isNotBlank(opty.MACD_Type__c))){
                                           system.debug('@@@/*Updated as part of US344706*/ trigger entered if ');
                                           pEJ.Currently_Active__c = promE.Currently_Active__c;
                                           pEJ.Discount_Percentage__c = promE.Discount_Percentage__c;
                                           pEJ.Eligible__c = true;
                                        }
                                       // Discount will be overrided for Anira Product on reapply
                                       if(aniraProd) {                                                                               
                                            if(aniraCustDiscount.containsKey(endCustomer )){
                                                
                                             pEJ.Discount_Percentage__c =   aniraCustDiscount.get(endCustomer);
                                             
                                            }
                                       }                                   
                                        
                                       pEJ.Opportunity__c = opty.Id;
                                       pEJ.Promotion_Description__c = promE.Promotion_Description__c;
                                       pEJ.Promotion_Name__c = promE.Promotion_Name__c;
                                       pEJ.Rank__c = promE.Rank__c;
                                       pEJ.Valid_For_Product__c = promE.Valid_For_Product__c;
                                       insertPEJRecs.add(pEJ);
                                       uniqueOptylist = true;
                                    }
                                }
                                if( uniqueOptylist && opty.Deal_Reg_Approved__c )//Updated logic form opty.StageName != SIConstants.OPP_STAGE_REQUESTED to Deal_Reg_Approved__c
                                {
                                    processOptyList.add(opty);
                                }
                            }
                            
                            //insert list of promotion engine junction records to Opportunity
                            if( insertPEJRecs!=null && insertPEJRecs.size()>0 )
                            {
                                insert insertPEJRecs;
                                applydiscounts = true;
                            }
                            
                            //Applying promotions on opportunity
                            if( applydiscounts )
                            {
                                SIHelper.genericPromotionEnginelogic(processOptyList);
                            }
                        }
                     }
                }
            }
            catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
        
             
            /*Name:applyDealRegPromotionDiscounts
             * Description:
             */
            public static void applyDealRegPromotionDiscounts( SObject[] oldObjects, SObject[] updatedObjects)
            {
                try{
                list<Opportunity> newOptyList =updatedObjects;
                list<Opportunity> oldOptyList =oldObjects;
                list<Opportunity> selectedOptys = new list<Opportunity>();
                set<ID> optysID = new set<ID>();
                set<ID> deletePEJOnopty = new set<ID>();
                list<Product_Pricing__c> updatePPRecords = new list<Product_Pricing__c>();
                list<Product_Pricing__c> finalPPRecords = new list<Product_Pricing__c>();
                list<SPProduct__c> spProductlist = new list<SPProduct__c>();
                boolean withDiscount;
                list<Promotion_Engine__c> promoEngine = new list<Promotion_Engine__c>();
                //promoEngine = [Select id, Rank__c from Promotion_Engine__c where Rank__c = 6 LIMIT 1];
                list<Promotion_Engine_Junction__c> promoJunc = new list<Promotion_Engine_Junction__c>();
                
                if(!newOptyList.isEmpty() && newOptyList!= null)
                {
                    for (Integer i=0; i<newOptyList.size(); i++)
                    {
                        if( oldOptyList[i].Apply_Promotions__c == false && newOptyList[i].Apply_Promotions__c==true && newOptyList[i].ATOM_Deal__c)
                        {
                            selectedOptys.add(newOptyList[i]);
                            optysID.add(newOptyList[i].Id);
                        }
                    } 
                    if( selectedOptys != null && selectedOptys.size() > 0 && SIConstants.dealRegPromotions )
                    {
                        SIConstants.dealRegPromotions = false;
                        SIConstants.removeSpecialpricing=false;
                        
                        list<SPProduct__c> updateSPProductStatus = [select Id from SPProduct__c where Deal__c IN:optysID];
                        if( updateSPProductStatus!=null && updateSPProductStatus.size()>0 )
                        {
                            for(Opportunity selOpty : selectedOptys)
                            {
                                if(selOpty.Standard_Discount_Percentage__c == null && selOpty.Custom_Deal_Reg_Percentage__c == null && !selOpty.Auto_Deal_Registration__c)
                                {
                                    deletePEJOnopty.add(selOpty.Id);
                                    withDiscount = false;
                                    promoEngine = [Select id, Rank__c, Currently_Active__c,Promotion_Name__c from Promotion_Engine__c where Rank__c = 6 and Currently_Active__c = true LIMIT 1];
                                    if(promoEngine.size() > 0 && promoEngine != null){
                                        Promotion_Engine_Junction__c junc = new Promotion_Engine_Junction__c();
                                        junc.Opportunity__c = selOpty.id;
                                        junc.Promotion_Engine__c = promoEngine[0].id;
                                        junc.Rank__c = 6;
                                        junc.Currently_Active__c = true;
                                        junc.Promotion_Name__c = UtilityConstant.WITHOUTDISCOUNT;
                                        junc.Eligible__c = true;
                                        insert junc;
                                    }
                                }
                                else
                                {
                                    withDiscount = true;
                                }
                            }
                            
                            for(SPProduct__c spp : updateSPProductStatus)
                            {
                                if(withDiscount)
                                {
                                    spp.Deal_Status__c = SIConstants.PROD_DEAL_REG_APP_WITH_DIS;
                                }
                                else
                                {
                                    spp.Deal_Status__c = SIConstants.PROD_DEAL_REG_APP_WITHOUT_DIS;
                                }
                            }
                            
                            update updateSPProductStatus;
                            
                            if( deletePEJOnopty!=null && deletePEJOnopty.size() > 0 )
                            {
                                list<Promotion_Engine_Junction__c> deletePEJRank4 = [select Id from Promotion_Engine_Junction__c where Eligible__c = true and Rank__c = 4 and Opportunity__c IN:deletePEJOnopty];
                                if( deletePEJRank4.size() > 0 )
                                {
                                    delete deletePEJRank4;
                                }
                            }
                            updatePPRecords = [SELECT Deal_Id__c,Product_Record_Type__c,SP_Discount_Percentage__c,Type__c,Discountable__c,List_Price__c,discount_price__c,Discounted_Price__c, Record_Type__c,Usage_Charges__c,Discounted_Usage_Charge__c FROM Product_Pricing__c pr WHERE pr.SP_Product__c IN (SELECT Id FROM SPProduct__c WHERE Deal__c IN:optysID) AND (Type__c= :SIConstants.TYPE_MRC OR Type__c= :SIConstants.TYPE_NRC OR Type__c= :SIConstants.TYPE_MUC)];
                            if( updatePPRecords!=null && updatePPRecords.size() > 0 )
                            {
                                List<Promotion_Engine_Junction__c> promoEngineRecordsWithThirdRank = [select Id, Activation_Date__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c, Input_Field__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Opportunity__c from Promotion_Engine_Junction__c where Eligible__c = true and Rank__c = 3 AND Opportunity__c IN:optysID order by Rank__c ];
                                List<Promotion_Engine_Junction__c> promoEngineRecords = [select Id, Activation_Date__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c, Input_Field__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Opportunity__c from Promotion_Engine_Junction__c where Eligible__c = true and Opportunity__c IN:optysID AND ID NOT IN:promoEngineRecordsWithThirdRank order by Rank__c ];
                                
                                Map<String, List<Promotion_Engine_Junction__c>> mapPERankedThirdGroupedByProduct = new Map<String, List<Promotion_Engine_Junction__c>>();
                                for( Promotion_Engine_Junction__c peThirdItem :promoEngineRecordsWithThirdRank ){
                                    
                                    List<Promotion_Engine_Junction__c> tempList = new List<Promotion_Engine_Junction__c>();
                                    for( Promotion_Engine_Junction__c peThirdItemIterable :promoEngineRecordsWithThirdRank ){
                                        if( peThirdItem.Valid_For_Product__c == peThirdItemIterable.Valid_For_Product__c){
                                                tempList.add( peThirdItemIterable );
                                                mapPERankedThirdGroupedByProduct.put( peThirdItem.Valid_For_Product__c, tempList );
                                        }   
                                    }
                                }  
                                Map<Promotion_Engine_Junction__c, Decimal> mapPEFinalDiscount = new Map<Promotion_Engine_Junction__c, Decimal>();
                                for(String eachProduct : mapPERankedThirdGroupedByProduct.keyset()){
                                    Decimal discountPerc;
                                    Integer loopCounter = 0;
                                    Promotion_Engine_Junction__c promoJunciton = new Promotion_Engine_Junction__c();
                                    for( Promotion_Engine_Junction__c PromoJuncitonItem : mapPERankedThirdGroupedByProduct.get( eachProduct ) ){
                                        if( loopCounter == 0 ){
                                            PromoJunciton = PromoJuncitonItem;
                                            discountPerc = PromoJuncitonItem.Discount_Percentage__c;
                                        }else{
                                            discountPerc += PromoJuncitonItem.Discount_Percentage__c; 
                                        }
                                        loopCounter++;
                                    }
                                    mapPEFinalDiscount.put(PromoJunciton, discountPerc);
                                }
                                
                                promoEngineRecords.addAll(mapPEFinalDiscount.keySet()); 
                                
                                List<Promotion_Engine_Junction__c> listFinalPromoRecords = [select Id, Activation_Date__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c, Input_Field__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Opportunity__c from Promotion_Engine_Junction__c where Eligible__c = true and Id IN:promoEngineRecords order by Rank__c];
                                
                                for(Product_Pricing__c prodPric:updatePPRecords)
                                {
                                    prodPric.Discounted_Price__c=null;
                                }
                                Boolean checkProductType;
                                try{
                                        if( listFinalPromoRecords!=null && listFinalPromoRecords.size() > 0 )
                                        {
                                            finalPPRecords = SIHelper.calculatePromotionDiscountOnPP(selectedOptys, listFinalPromoRecords, updatePPRecords, mapPEFinalDiscount);
                                            //Update special pricing values
                                            for(Product_Pricing__c prod : finalPPRecords)
                                            {
                                                if(prod.Discounted_Price__c == null)
                                                {
                                                    prod.Discounted_Price__c = prod.List_Price__c;
                                                }
                                            }
                                            update updatePPRecords;
                                        }
                                    }catch(Exception e) { 
                                        ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                                                }
                            }
                        }
                    }
                }
            }
            catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
            
            /* Business to logic to update ATOM Deal flag to true on craetion of ATOM Deal. */
/* 
 Name: updateAtomDealFalg
 Description: 
 */ 
 public void updateAtomDealFalg( SObject[] updatedObjects ){
                try{
                list<Opportunity> newOptyList =updatedObjects;
                
                for( Opportunity deal: newOptyList  ) {
                    if( deal.BID_ID__c != null ) {
                        if( deal.BID_ID__c.startsWith(UtilityConstant.Q) && !deal.ATOM_Deal__c ) {
                            deal.ATOM_Deal__c = True;
                        }
                    }            
                }
            
            }
            catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
            
            //updating Deal Stage on SP (new field) on spproduct when Opportunity StageName==UtilityConstant.PRICINGSCHEDULE_REQUESTED

        public void DealStageonSP(SObject[] oldObjects,SObject[] updatedObjects)
        {
            try{
            List<Opportunity> oppoldlist=oldObjects;
            List<Opportunity> oppnewlist=updatedObjects;
            Set<Id> oppIdsset=new Set<Id>();
            List<SPProduct__c> splist=new List<SPProduct__c>();
            Map<Id,SPProduct__c> spMap=new Map<Id,SPProduct__c>();
          for(Integer i=0;i<oppnewlist.size(); i++)
          {
              if(oppnewlist[i].StageName!=oppoldlist[i].StageName && oppnewlist[i].StageName!=NULL)
              {
                  oppIdsset.add(oppnewlist[i].Id);
              }
          }
          if(oppIdsset.size()>0)
              {
                  splist=[select Id,Deal__c,Deal_Stage_on_SP__c,Deal_Status__c from SPProduct__c WHERE Deal__c IN:oppIdsset];
              }
          if(splist.size()>0)
          {    
             for(Opportunity opp:oppnewlist)
             {
                 for(SPProduct__c spp:splist)
                 {
                     if(opp.Id==spp.Deal__c)
                     {
                         spp.Deal_Stage_on_SP__c=opp.StageName;
                         if(opp.StageName==UtilityConstant.PRICINGSCHEDULE_REQUESTED && SPP.Deal_Status__c==null){
                         SPP.Deal_Status__c=opp.StageName;
                         }
                         spMap.put(spp.Id,spp); 
                     }
                    
                   }
             }
          if(spMap.size()>0)
          {
              try{
                 update spMap.values();
              }
              Catch(Exception e)          {    
                  ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
              }
          }      
        }
        }
        catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
            
             /*****
            User story US314885: To update Deal Reg Discount percent of MACD Oppty from Master Oppty.
            *****/               
           public void updateDealRegDiscountOnMACD(SObject[] newObjects)
            {
                try{
             List<Opportunity> mACDOppList = newObjects;
             List <Opportunity> masterList = new List <Opportunity>();
             Set<String> regSet = new Set<String>();
             Set<Id> mACDSet=new Set<Id>();
             for(Opportunity opp : MACDOppList)
             {
                if(opp.Record_Type_Name_for_Internal_use__c==SIConstants.RECORDTYPEMACD && (opp.Master_deal_number__c != SpecialCharacterConstant.CONCAT || opp.Master_deal_number__c !=null) && opp.MACD_Type__c==SIConstants.MACDTYPEA)
                {    
                    regSet.add(opp.Master_deal_number__c);
                    MACDSet.add(opp.Id);
                }
                if(opp.MACD_Type__c!=null && opp.MACD_Type__c!=''){
                    if(opp.Discounted_Percentage__c!=null && opp.Discounted_Percentage__c>0.00)
                    {
                    Decimal disAmount=SIHelper.applyRound(((opp.Cumulative_List_Price__c*opp.Discounted_Percentage__c)/100));
                    opp.Discounted_Price__c=opp.Cumulative_List_Price__c-disAmount;
                    
                }
                 }
             }
             if(regSet.size()>0){
             MasterList = [select Id,BID_ID__c,Discounted_Percentage__c,Record_Type_Name_for_Internal_use__c FROM Opportunity WHERE BID_ID__c IN:regSet AND Record_Type_Name_for_Internal_use__c ='Deal Reg Requested'];
             }
             
             if(MasterList.size()>0){
              for(Opportunity oppMACD :MACDOppList)
             {  
                for(Opportunity oppMaster : MasterList)
                {
                    if(oppMACD.Master_deal_number__c==oppMaster.BID_ID__c)
                    {
                        oppMACD.Discounted_Percentage__c=oppMaster.Discounted_Percentage__c;
                    }
                }  
             }
             }
            }
            catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
            
           //This method is for creating RDS Access Billing Element Details records when Opportunity-API Status = "Circuit ID/USO API Successful"
/* 
 Name: createRDSAccessBillingElements
 Description: 
 */ 
            public void createRDSAccessBillingElements(SObject[] oldObjects, SObject[] updatedObjects){
            try{
                List<Opportunity> oldOpps = oldObjects;   
                List<Opportunity> updatedOpps = updatedObjects;
                Set<String> oppWithCktSet = new Set<String>();
                Set<String> opp18IdWithCktSet = new Set<String>();
                Set<String> premiseNumberSet = new Set<String>();
                List<RDS_Access_Billing_Element_Details__c> accessBillingRecordsToBeInserted = new List<RDS_Access_Billing_Element_Details__c>();
                List<RDS_Access_Billing_Element_Details__c> accessBillingRecords = new List<RDS_Access_Billing_Element_Details__c>();
                Set<string> acktIdSet = new Set<string>();        
                Map<String, Decimal> siteAmountsMap = new Map<String, Decimal>();
                Map<String, String> siteBEIDMap = new Map<String, String>();
                Map<String,RDS_Access_Circuit_ID__c> accessCktMap = new Map<String,RDS_Access_Circuit_ID__c>();
                Map<String, RDS_Premise_Details__c> premiseMap = new Map<String, RDS_Premise_Details__c>();
                Decimal accessAmount =0;
                Decimal circuitCount =1;
                Map<Id,RDS_Access_Billing_Element_Details__c> cktAccBillMap = new Map<Id,RDS_Access_Billing_Element_Details__c>();
                
                for(Opportunity oldOpp: oldOpps){
                    for(Opportunity opp: updatedOpps){
                            if(opp.IsCircuit_ID_USOSucess__c ==true && oldOpp.IsCircuit_ID_USOSucess__c != opp.IsCircuit_ID_USOSucess__c){
                                    String optyId = opp.Id;
                                    String oppId = optyId.substring(0,15);
                                    oppWithCktSet.add(oppId);
                                    opp18IdWithCktSet.add(optyId);
                            }
                    }
                }
                           
                if(oppWithCktSet.size()>0){
                    for(SPProduct__c spPrt : [Select Id, Site_ID__c, Deal__c, RDS_Version__c from SPProduct__c Where Deal__c =: oppWithCktSet]){
                        premiseNumberSet.add(spPrt.Site_ID__c);
                    }
                }
                
                if(premiseNumberSet.size()>0){
                    for(RDS_Premise_Details__c rps : [Select Id, Premise_Number__c, Circuit_mlppSegments__c from RDS_Premise_Details__c where Premise_Number__c =: premiseNumberSet]){
                        String premId = rps.Id;
                        String subPremId = premId.substring(0,15);
                        premiseMap.put(subPremId, rps);
                    }
                }
            
                if(premiseMap.size()>0){
                    for(RDS_Access_Circuit_ID__c ackt : [Select Id, Premise_Service_Type__c, RDS_PremiseDetailID__c, RDS_Premise_Number__c From RDS_Access_Circuit_ID__c Where RDS_PremiseDetailID__c =: premiseMap.keySet()]){
                        accessCktMap.put(ackt.Id, ackt);
                        String acktId = ackt.Id;
                        String subAcktId = acktId.substring(0,15);
                        acktIdSet.add(subAcktId);
                    }
                    for(Product_Pricing__c prodPrice: [SELECT Id, list_price__c, Deal_Id__c, SP_Site_Id__c, Record_Type__c, BEID__c From Product_Pricing__c where SP_Site_Id__c=: premiseNumberSet AND Deal_Id__c =: opp18IdWithCktSet AND Record_Type__c =: UtilityConstant.ACCESS AND list_price__c !=0.00]) {
                                siteAmountsMap.put(prodPrice.SP_Site_Id__c, prodPrice.list_price__c);
                                siteBEIDMap.put(prodPrice.SP_Site_Id__c, prodPrice.BEID__c);
                    }
              
                }
                if(acktIdSet.size()>0){
                    accessBillingRecords = [Select Id, RDS_Access_Circuit_ID__c from RDS_Access_Billing_Element_Details__c where RDS_Access_Circuit_ID__c =: acktIdSet];
                } 
                
                if(accessBillingRecords.size()>0){
                    for(RDS_Access_Billing_Element_Details__c acb : accessBillingRecords){
                        cktAccBillMap.put(acb.RDS_Access_Circuit_ID__c,acb);
                    }
                }
                if(premiseMap.size()>0 && accessCktMap.size()>0 && siteBEIDMap.size()>0){
                        for(RDS_Premise_Details__c rdsP: premiseMap.values()){
                          circuitCount =1;   
                            if (rdsP.Circuit_mlppSegments__c > 1){
                                circuitCount = rdsP.Circuit_mlppSegments__c;
                            }
                            accessAmount = siteAmountsMap.get(rdsP.Premise_Number__c);  
                            Decimal accessOverrideRateAmount = accessAmount/circuitCount;            
                                    for(RDS_Access_Circuit_ID__c accessCkt : accessCktMap.values()){
                                        if(!cktAccBillMap.containsKey(accessCkt.Id)){
                                            if(accessCkt.RDS_PremiseDetailID__c == rdsP.Id){
                                                RDS_Access_Billing_Element_Details__c accessBillingrecord = new RDS_Access_Billing_Element_Details__c();
                                                if(accessCkt.Premise_Service_Type__c == UtilityConstant.AVPN || accessCkt.Premise_Service_Type__c== UtilityConstant.MIS){
                                                    accessBillingrecord.Access_Override_Rate_Amount__c = String.valueof(accessOverrideRateAmount);        
                                                }                          
                                                    accessBillingrecord.RDS_Access_Circuit_ID__c = accessCkt.Id;
                                                    accessBillingrecord.Access_Charge_Element_ID__c = siteBEIDMap.get(accessCkt.RDS_Premise_Number__c);
                                                    accessBillingRecordsToBeInserted.add(accessBillingrecord);
                                            }
                                        }
                                    }
                            }
                }
                    
                if(accessBillingRecordsToBeInserted.size()>0){
                    try{
                       insert accessBillingRecordsToBeInserted;
                    }catch(Exception ex){                   ex.getMessage();                                   }
                } 
            } 
catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}           
            
             /***********
        User Story:US318275     Add SFDC - Opportunity Deal Rate Plan Logic
        This method is to insert the Rate Phi Record of type Deal rate Card whenever the deal rate plan call is successfull on Opportunity.

        *****/
/* 
 Name: createDealrateCardOnDealrateSuccess
 Description: 
 */ 
            public void createDealrateCardOnDealrateSuccess(SObject[] oldObjects,SObject[] updatedObjects){
            try{
                List<Rate_PHI__c> dealrateCardListToInsert = new List<Rate_PHI__c>();
                List<Opportunity> listOfUpdatedOppty = updatedObjects;
                List<Opportunity> listOfOldOppty = oldObjects;
                List<Opportunity> opptyWithDealSuccess = new List<Opportunity>();
                SPProduct__c objSP= new SPProduct__c();
                String sprecord;
                Set<Id> oppIdwithDealSuccess = new Set<Id>();
                    for(Opportunity oppUpd:listOfUpdatedOppty ){
                        for(Opportunity oppOld:listOfOldOppty ){
                            if(oppUpd.IsDeal_Rate_Plan_Sucess__c == true && oppUpd.RecordType.Name!=UtilityConstant.MACD && (oppUpd.IsDeal_Rate_Plan_Sucess__c!=oppOld.IsDeal_Rate_Plan_Sucess__c)){
                                oppIdwithDealSuccess.add(oppUpd.id);
                                opptyWithDealSuccess.add(oppUpd);
                            }
                        }    
                    } 
                    if(opptyWithDealSuccess.size() >0 ){
                        objSP=[select Id,RecordType.Name,Deal__c from SPProduct__c where Deal__c in :opptyWithDealSuccess limit 1];
                        if( objSP!= null )
                        sprecord = objSP.RecordType.Name;
                        ID rtypeId = SIRecordTypeHelper.GetRecordTypeIdByDevName('Rate_PHI__c','Deal_Rate_Card');  
                        for(Opportunity o:opptyWithDealSuccess){
                            if(o.Rate_Stability_Date__c!=null  && (o.Deal_Rate_Plan_ID__c!=SpecialCharacterConstant.CONCAT || o.Deal_Rate_Plan_ID__c!=null)  ){
                                Rate_PHI__c ratePhi = new Rate_PHI__c();
                                ratePhi.Rate_Plan_ID__c = o.Deal_Rate_Plan_ID__c;
                                ratePhi.Effective_Date__c = o.Rate_Stability_Date__c;
                                ratePhi.Service_Type__c = sprecord ;
                                ratePhi.Rate_Plan_Name__c = o.BID_ID__c;
                                ratePhi.Availability_Date__c = o.Rate_Stability_Date__c.Date();
                                ratePhi.Rates_Retrieved__c = false;
                                ratePhi.RecordTypeId = rtypeId;
                                dealrateCardListToInsert.add(ratephi); 
                           }                   
                        }
                        if(dealrateCardListToInsert.size()>0){
                            try{
            
                                insert dealrateCardListToInsert;
                            }Catch(DMLException e){                            e.getMessage();                        }
                        }
                    }
            }  
            catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}

        //This method is for updating Opportunity fields, linking correct Deal Hash and versioning during MACD Add
                      
/* 
 Name: macdAActions
 Description: 
 */ 
            public void macdAActions(SObject[] updatedObjects){
                try{
            List<Opportunity> oppsList = updatedObjects; 
            Set<String> masterOppDealNumbrs = new Set<String>();
            Set<String> dhVIds = new Set<String>();
            List<Deal_Hash__c> dhVersionUpdtList = new List<Deal_Hash__c>();
            Map<String,Opportunity> masterDealMap = new Map<String,Opportunity>();
            Decimal vrs = 0;

            for(Opportunity opp: oppsList){
                if(opp.MACD_Type__c == UtilityConstant.A && opp.Master_deal_number__c != null){
                    masterOppDealNumbrs.add(opp.Master_deal_number__c);
                }
            }
                
            if(masterOppDealNumbrs.size()>0){
                for(Opportunity opt : [Select BID_ID__c, Deal_Rate_Plan_ID__c,RDS_Deal_Hash__c, Rate_Plan_ID__c, Rate_Stability_Date__c, Deal_Rate_Plan_Status__c, RDS_Received_Status__c, CDG_Sub_Account_Status__c, SA_Contract_Subscription_Status__c From Opportunity where BID_ID__c =: masterOppDealNumbrs]){
                    masterDealMap.put(opt.BID_ID__c, opt);
                    dhVIds.add(opt.RDS_Deal_Hash__c);
                }
            }
            
            if(dhVIds.size()>0){   
                for(Deal_Hash__c rd : [Select Id, RDS_Version__c from Deal_Hash__c where Id =: dhVIds]){
                    vrs = rd.RDS_Version__c + 1;
                    rd.RDS_Version__c = rd.RDS_Version__c + 1;
                    dhVersionUpdtList.add(rd);
                }
            }
            
            if(masterDealMap.size()>0){ 
            
                if(dhVersionUpdtList.size()>0){
                        try{
                            update dhVersionUpdtList;
                        } catch(Exception ex){                        ex.getMessage();                    }
                }
                
                for(Opportunity opty : oppsList){ 
                        opty.Deal_Rate_Plan_ID__c = masterDealMap.get(opty.Master_deal_number__c).Deal_Rate_Plan_ID__c;
                        opty.Rate_Plan_ID__c = masterDealMap.get(opty.Master_deal_number__c).Rate_Plan_ID__c;
                        opty.Rate_Stability_Date__c = masterDealMap.get(opty.Master_deal_number__c).Rate_Stability_Date__c; 
                        opty.RDS_Deal_Hash__c = masterDealMap.get(opty.Master_deal_number__c).RDS_Deal_Hash__c;
                        opty.RDS_Version__c = vrs;
                        //opty.Deal_Rate_Plan_Status__c = masterDealMap.get(opty.Master_deal_number__c).Deal_Rate_Plan_Status__c;
                        //opty.CDG_Sub_Account_Status__c = masterDealMap.get(opty.Master_deal_number__c).CDG_Sub_Account_Status__c;
                        //opty.SA_Contract_Subscription_Status__c = masterDealMap.get(opty.Master_deal_number__c).SA_Contract_Subscription_Status__c;
                        opty.Deal_Rate_Plan_Status__c = SpecialCharacterConstant.CONCAT;
                        opty.Deal_Rate_Plan_Status__c = SpecialCharacterConstant.CONCAT;
                        opty.Deal_Rate_Plan_Error_Msg__c = SpecialCharacterConstant.CONCAT;
                        opty.CDG_Sub_Account_Last_timestamp__c = null;
                        opty.CDG_Sub_Account_Status__c = SpecialCharacterConstant.CONCAT;
                        opty.CDG_Sub_Account_Last_Run_Error_Msg__c = SpecialCharacterConstant.CONCAT;
                        opty.SA_Contract_Subscription_Last_Time_Stamp__c = null;
                        opty.SA_Contract_Subscription_Status__c = SpecialCharacterConstant.CONCAT;
                        opty.SA_Contract_Subscription_Error_Msg__c = SpecialCharacterConstant.CONCAT;
                       // opty.RDS_Received_Status__c = masterDealMap.get(opty.Master_deal_number__c).RDS_Received_Status__c; // Commented based on defect-48000: RDS Received Status shows as Success before RDS is submitted
                }
            }
        }
        catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
            /* 
            Name: populateAutoApprovalStatus
            Description: 
            */     
        void populateAutoApprovalStatus( List<Opportunity> Opptys ){
            try{
            map<string, SPProduct__c> opptyPrevProductMap;
            opptyPrevProductMap = createPrevProductMap(Opptys);
            for(opportunity eachOppty : Opptys){
                string formatString = eachOppty.AccountID + SpecialCharacterConstant.CONCAT + eachOppty.End_Customer__c;
                SPProduct__c prevProd = opptyPrevProductMap.get(formatString);
                if(prevProd != null){
                    eachOppty.Auto_Approval_Status__c = getAutoApprovalStatus(prevProd.Deal_Status__c, prevProd.Registration_Discount__c); 
                }else{
                    eachOppty.Auto_Approval_Status__c = UtilityConstant.REQUESTED;   
                }
            }       
        }
        catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
        
/* 
 Name: createPrevProductMap
 Description: 
 */ 
        public map<string, SPProduct__c> createPrevProductMap(List<opportunity> Opptys){
            try{
            map<string, SPProduct__c> tempMap = new map<string, SPProduct__c>();
            
            list<String> dealStatuses = new list<string>{UtilityConstant.DEALREG_APPROVED_WITH_DISCOUNT,UtilityConstant.DEALREG_APPROVED_WITHOUT_DISCOUNT,UtilityConstant.ORDERSUBMITTED, UtilityConstant.PRICINGSCHEDULE_REQUESTED,UtilityConstant.DEALREGISTRATION_DENIED};
            string soqlSelectClause = 'select Deal_Status__c, Registration_Discount__c, Opportunity_Account__c, Opportunity_End_Customer__c, LastModifiedDate, Deal__r.AccountID from SPProduct__c';
            string soqlWhereClause = ' where Deal__r.RecordType.DeveloperName = \'Deal_Reg_Requested\' AND Deal__r.Renewal_Contract__c = false AND (Record_Type_Name__c = \'MIS\' OR Record_Type_Name__c = \'ANIRA\') AND Deal_Status__c IN : dealStatuses AND (';

            for(integer i = 0 ; i <  Opptys.size() ; i++){
                string spAccId = Opptys[i].AccountId;
                string endCustId = Opptys[i].End_Customer__c;
                string prodName = Opptys[i].Service_type__c;
                if(prodName == UtilityConstant.AMIS) {
                   prodName = SIConstants.SERVICETYPEMIS;
                }
                soqlWhereClause = soqlWhereClause + '( Deal__r.AccountID =\'' + spAccId + '\'AND Opportunity_End_Customer__c =\'' + endCustId + '\' AND Record_Type_Name__c = \'' + prodName + '\')';
                if( i != Opptys.size() - 1 ){
                    soqlWhereClause = soqlWhereClause + ' OR ';
                }
            }
            soqlWhereClause = soqlWhereClause + ')';
            string soqlQuery = soqlSelectClause + soqlWhereClause;
            list<spproduct__c> spProds = database.query(soqlQuery);
            for(opportunity eachOpty : Opptys){
                string formatString = eachOpty.AccountID + SpecialCharacterConstant.CONCAT + eachOpty.End_Customer__c;
                for(spproduct__c eachProd : spProds){
                    spproduct__c currentSpProd = tempMap.get(formatString);
                    if(eachProd.Deal__r.AccountID == eachOpty.AccountID && eachProd.Opportunity_End_Customer__c == eachOpty.End_Customer__c ){
                        if(currentSpProd == null){
                            tempMap.put(formatString, eachProd);    
                        }
                        else if(currentSpProd != null && currentSpProd.LastModifiedDate < eachProd.LastModifiedDate){
                            tempMap.put(formatString, eachProd);    
                        }           
                    }
                    
                }
            }
            return tempMap;
        }
        catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
        
/* 
 Name: getAutoApprovalStatus
 Description: 
 */ 
        public String getAutoApprovalStatus(String dealStatus, Boolean isDealRegDisc ){
            try{
            string autoApprovalStatus;
            
            if(dealStatus == SIConstants.PROD_DEAL_REG_APP_WITH_DIS){
                autoApprovalStatus = UtilityConstant.APPROVEDWITH_DISCOUNT;      
            }
            else if(dealStatus == SIConstants.PROD_DEAL_REG_APP_WITHOUT_DIS){
                autoApprovalStatus = UtilityConstant.APPROVEDWITHOUT_DISCOUNT;       
            }
            else if(dealStatus == SIConstants.PROD_DEAL_REG_DENY){
                autoApprovalStatus = UtilityConstant.REQUESTED;       
            }
            else if(dealStatus == SIConstants.dealstatus || dealStatus == SIConstants.OPTY_DEAL_SUBMITTED){
                if (isDealRegDisc ==  True){
                    autoApprovalStatus = UtilityConstant.APPROVEDWITH_DISCOUNT;
                }
                else{
                    autoApprovalStatus = UtilityConstant.APPROVEDWITHOUT_DISCOUNT;      
                }
            } 
            else{
                autoApprovalStatus = UtilityConstant.REQUESTED;
            }
            return (autoApprovalStatus);
        } 
catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}       
        /* 
        Name: doAutoDealRegApproval
        Description: 
        */ 
        void doAutoDealRegApproval(list<opportunity> opptys){
            try{
            id opptyIdToApprove = opptys[0].id;
            SIATOMDealRegistrationApproval obj =  new SIATOMDealRegistrationApproval(opptyIdToApprove);
            obj.calculateDiscounts();
            if(opptys[0].Auto_Approval_Status__c == UtilityConstant.APPROVEDWITH_DISCOUNT){
                obj.dealApproveWithDiscount();
            }else if(opptys[0].Auto_Approval_Status__c == UtilityConstant.APPROVEDWITHOUT_DISCOUNT){
                obj.dealApproveWithoutDiscount();    
            }
        }
        catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));

}
}
        
        public void populateAutoApprovalAcctDealStatus(SObject[] updatedObjects)
            {
                try{
              
                list<Opportunity> newOptyList =updatedObjects;
                List<Criteria__c> criteriaRecords = new List<Criteria__c>();
                List<Promotion_Engine__c> promoEngineRecords  = new List<Promotion_Engine__c>();
               
                
                if( !newOptyList.isEmpty() && newOptyList!= null )
                
                {
                    promoEngineRecords = [select Id,Default_Deal_Reg_Decision__c,Category_Order__c, Activation_Date__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c,OptyInputField__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Operator_Formula__c,Input_Data_Type__c,Number_Of_Criterias__c  from Promotion_Engine__c where Currently_Active__c = true and Rank__c in( 0)and Activation_Date__c   <= :  system.today() and Expiration_Date__c >= : system.today() order by Category_Order__c ];
                    criteriaRecords = [ select id,Deal_Reg_Decision__c,Deal_Reg_Discount__c,Criteria_Name__c,AndOrFormula__c, Input_Data_Type__c, Input_Field__c, Operator__c, Operator_Formula__c, Value__c,CriteriaNumber__c, Promotion_Engine__c from Criteria__c  where Promotion_Engine__c in : promoEngineRecords order by CriteriaNumber__c];
                                     
                    String lVal,rVal;                        
                    Boolean insertPromoRecord;
                    String dealregDecision;
                    Decimal deagRegDiscountPercent;                       
                    Boolean uniqueOptylist;                               
                    Boolean directConsumption; 
                    Boolean skipDealReg;
                    Boolean validForProduct;
                    Boolean queryReady; 
                    Boolean dupEndCustForProd;
                    String autoDealRegStatus = SpecialCharacterConstant.CONCAT;
                    Date dt;
                    String stageValue = SpecialCharacterConstant.CONCAT;
                    String recordName;
                    Boolean metTelAccount = false;     
                    String dealRegDecisionOpty;
                    
                    String opptyServiceType = newOptyList[0].Service_type__c;
                        if(opptyServiceType == UtilityConstant.AMIS) {
                           opptyServiceType = SIConstants.SERVICETYPEMIS;
                        }
                           
                    for( Opportunity opty : newOptyList){
                        for( Promotion_Engine__c promE : promoEngineRecords ){
                            for( Criteria__c critera : criteriaRecords ){
                                if(critera.Promotion_Engine__c == promE.Id){    
                                    if(critera.Input_Data_Type__c == SpecialCharacterConstant.STATIC_STRING){
                                        if((PromE.Valid_For_Product__c != null ||PromE.Valid_For_Product__c != SpecialCharacterConstant.CONCAT) && (opptyServiceType.equalsIgnoreCase(PromE.Valid_For_Product__c)) && PromE.Category_Order__c == UtilityConstant.SIVARConst_3) { 
                                            if(critera.Input_Field__c == UtilityConstant.DEALREG_APPROVAL_DATE_C)  {   
                                                recordName = critera.Value__c;
                                                String regex = UtilityConstant.A_ZA_Z_1_x;
                                                String recordNumber = recordName.replaceAll(regex, '').trim();
                                                // if string contains months then add months else if string contain days add days , skipping the first letter for case sensitivity 
                                                if ( recordName.containsIgnoreCase(UtilityConstant.DAYS)){
                                                    dt = system.today().addDays(-1*(integer.valueof(recordNumber)));
                                                }
                                                else if ( recordName.containsIgnoreCase(UtilityConstant.MONTHS1)){
                                                     dt = system.today().addMonths(-1*(integer.valueof(recordNumber)));
                                                }
                                            }
                                            if(critera.Input_Field__c.equalsIgnoreCase(UtilityConstant.STAGENAME)) { 
                                                 stageValue = critera.Value__c;                                                 
                                                 queryReady = true;
                                            }   
                                        }
                                    }
                                }
                            }
                        }  
                    }
                    String optyFuzzyEndCust = newOptyList[0].End_Customer_Name__c;
                    String optyEndCust = newOptyList[0].EndCustomerName__c;
                    String optyProdName = newOptyList[0].Service_type__c;  
                    String optyAccName =  newOptyList[0].Account_Name__c;  
                    ID optyAccount =  newOptyList[0].AccountId;
                    
                    String Address = newOptyList[0].End_Cust_Address__c;
                    List <Opportunity> endCustCheck = new List<Opportunity> ();
                    List <Opportunity> existingQuoteCheck = new List<Opportunity> ();
                    Boolean existingQuoteDiffSPCheck = false;
                    System.debug('Address==='+Address);
                    System.debug('optyFuzzyEndCust==='+optyFuzzyEndCust);
                    System.debug('optyAccount==='+optyAccount);
                    
                    endCustCheck = [Select Id, Account_Name__c, Service_type__c, EndCustomerName__c,End_Customer_Name__c, End_Customer_Address__c, EndCustomerCity__c, EndCustomerState__c, EndCustomerZip__c from Opportunity where Account_Name__c = :optyAccName and ((End_Customer_Name__c = :optyFuzzyEndCust) or (EndCustomerName__c = :optyEndCust)) and Service_type__c = :optyProdName and Deal_Reg_Approval_Date__c > :dt and stageName not in(:stageValue)  order by Deal_Reg_Approval_Date__c asc ]   ;
                    existingQuoteCheck = [Select Id,Deal_Reg_Discount_Percentage__c, Account_Name__c, Service_type__c, EndCustomerName__c,End_Customer_Name__c, End_Customer_Address__c, EndCustomerCity__c, EndCustomerState__c, EndCustomerZip__c from Opportunity where AccountId = :optyAccount and ((End_Customer_Name__c = :optyFuzzyEndCust) or (EndCustomerName__c = :optyEndCust)) and Service_type__c = :optyProdName and Deal_Reg_Approval_Date__c > :dt and stageName not in(:stageValue) and End_Cust_Address__c =: Address  order by Deal_Reg_Approval_Date__c desc limit 1 ]   ;
                    System.debug('existingQuoteCheck==='+existingQuoteCheck);
                    SIOpptyWithoutSharingHelper siOpphelper = new SIOpptyWithoutSharingHelper();
                    existingQuoteDiffSPCheck = siOpphelper.CheckDiffSpOpty(optyAccount ,optyFuzzyEndCust,optyEndCust ,optyProdName,optyAccName ,Address,dt,stageValue);
                    System.debug('existingQuoteWDiffSPCheck==='+existingQuoteDiffSPCheck);
                    if(endCustCheck != null && endCustCheck.size() > 0 && endCustCheck[0].id != null){
                        dealRegDecisionOpty = String.valueOf(endCustCheck[0].Id);
                    }
                    List<Promotion_Engine__c> peCategory4Records = new List<Promotion_Engine__c>();
                    peCategory4Records = [select Id,Default_Deal_Reg_Decision__c, Product_Discount_Percentage__c, Currently_Active__c, Discount_Percentage__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Category_Order__c,Expiration_Date__c, Activation_Date__c  from Promotion_Engine__c where Currently_Active__c = true and Rank__c in(0) and Category_Order__c in('4')and Activation_Date__c   <= :  system.today() and Expiration_Date__c >= : system.today()];
                    Map<String,Promotion_Engine__c> discountPercentageMap = new Map<String,Promotion_Engine__c>();
                    for(Promotion_Engine__c pe : peCategory4Records)
                    {   
                        if(opptyServiceType.equalsIgnoreCase(pe.Valid_For_Product__c)){
                            discountPercentageMap.put(pe.Valid_For_Product__c,pe); 
                        }
                    }
                    for( Opportunity opty : newOptyList )
                    {
                        uniqueOptylist = false;
                        skipDealReg = false;
                        directConsumption = false;
                        dupEndCustForProd = false; 
                        
                        
                        for( Promotion_Engine__c promE : promoEngineRecords ){
                        
                            if(!skipDealReg) {    
                                insertPromoRecord = false;
                                
                                
                                for( Criteria__c critera : criteriaRecords ){
                                    if(critera.Promotion_Engine__c == promE.Id){    
                                        if(critera.Input_Data_Type__c == SpecialCharacterConstant.STATIC_STRING){
                                            if(critera.Input_Field__c.equalsIgnoreCase(UtilityConstant.DIRECTCOSUMPTION_C)) {
                                                if(opty.Direct_cosumption__c) {
                                                    directConsumption = true;
                                                }
                                            } else if(critera.Input_Field__c ==UtilityConstant.SPACCOUNT_NAME_C) {
                                                if(critera.Value__c.equalsIgnoreCase(opty.Account_Name__c)) {
                                                    insertPromoRecord = true;
                                                    skipDealReg = true;
                                                    metTelAccount=true;
                                                    dealregDecision = critera.Deal_Reg_Decision__c;
                                                    deagRegDiscountPercent = critera.Deal_Reg_Discount__c; 
                                                }
                                            } else if((PromE.Valid_For_Product__c != null ||PromE.Valid_For_Product__c != SpecialCharacterConstant.CONCAT) && (opptyServiceType.equalsIgnoreCase(PromE.Valid_For_Product__c))) { 
                                                if(PromE.Category_Order__c == UtilityConstant.SIVARConst_3){
                                                    if(PromE.Promotion_Name__c.containsIgnoreCase('Duplicate SP, EC')){
                                                        skipDealReg = true;
                                                        dealregDecision = critera.Deal_Reg_Decision__c;
                                                        deagRegDiscountPercent = critera.Deal_Reg_Discount__c;
                                                        autoDealRegStatus = PromE.Promotion_Name__c;
                                                        if(existingQuoteCheck.size() > 0 && dealregDecision != null && existingQuoteCheck[0].Deal_Reg_Discount_Percentage__c != null){
                                                            deagRegDiscountPercent = existingQuoteCheck[0].Deal_Reg_Discount_Percentage__c;
                                                        
                                                            autoDealRegStatus = PromE.Promotion_Name__c;
                                                            dealregDecision = PromE.Default_Deal_Reg_Decision__c;
                                                            opty.Auto_Deal_Registration_Rule_Applied__c=autoDealRegStatus;
                                                            
                                                            
                                                        }
                                                        else if(existingQuoteDiffSPCheck == true && dealregDecision != null ){
                                                            deagRegDiscountPercent = 0.00;
                                                            autoDealRegStatus = PromE.Promotion_Name__c;
                                                            dealregDecision = PromE.Default_Deal_Reg_Decision__c;
                                                            opty.Auto_Deal_Registration_Rule_Applied__c=autoDealRegStatus;
                                                        }
                                                        
                                                        else if(dealregDecision != null){
                                                            if(discountPercentageMap.get(opptyServiceType).Product_Discount_Percentage__c != null && discountPercentageMap.get(opptyServiceType).Product_Discount_Percentage__c > 0){
                                                                    deagRegDiscountPercent = discountPercentageMap.get(opptyServiceType).Product_Discount_Percentage__c;
                                                            }
                                                           else{
                                                                deagRegDiscountPercent = discountPercentageMap.get(opptyServiceType).Discount_Percentage__c;
                                                           }
                                                            autoDealRegStatus = discountPercentageMap.get(opptyServiceType).Promotion_Name__c;
                                                            dealregDecision = discountPercentageMap.get(opptyServiceType).Default_Deal_Reg_Decision__c;
                                                            opty.Auto_Deal_Registration_Rule_Applied__c=autoDealRegStatus;
                                                        
                                                        }
                                                        
                                                        insertPromoRecord = true;
                                                    }
                                                    else{
                                                        skipDealReg = true;
                                                        dealregDecision = critera.Deal_Reg_Decision__c;
                                                        deagRegDiscountPercent = critera.Deal_Reg_Discount__c;
                                                        autoDealRegStatus = PromE.Promotion_Name__c;
                                                        if(endCustCheck.size() == 0 && dealregDecision != null){
                                                            if(discountPercentageMap.get(opptyServiceType).Product_Discount_Percentage__c != null && discountPercentageMap.get(opptyServiceType).Product_Discount_Percentage__c > 0){
                                                                    deagRegDiscountPercent = discountPercentageMap.get(opptyServiceType).Product_Discount_Percentage__c;
                                                            }
                                                           else{
                                                                deagRegDiscountPercent = discountPercentageMap.get(opptyServiceType).Discount_Percentage__c;
                                                           }
                                                            autoDealRegStatus = discountPercentageMap.get(opptyServiceType).Promotion_Name__c;
                                                            dealregDecision = discountPercentageMap.get(opptyServiceType).Default_Deal_Reg_Decision__c;
                                                            opty.Auto_Deal_Registration_Rule_Applied__c=autoDealRegStatus;
                                                        }
                                                        insertPromoRecord = true;
                                                    }
                                                } 
                                            } 
                                            if(directConsumption) {
                                                if(critera.Criteria_Name__c.equalsIgnoreCase(UtilityConstant.CFUCHECK)) {
                                                    String endCustDet = opty.EndCustomerName__c+opty.End_Customer_Address__c+opty.EndCustomerCity__c+opty.EndCustomerState__c+opty.EndCustomerZip__c ;
                                                    String actCustDet = opty.Account_Name__c+opty.Account_Address__c+opty.Account_City__c+opty.Account_State__c+opty.Account_Zipcode__c ;
                                                    if(endCustDet.equalsIgnoreCase(actCustDet)) {                                                        
                                                        skipDealReg = true;
                                                        dealregDecision = UtilityConstant.DENY ;
                                                    } else {
                                                        insertPromoRecord = true;
                                                        skipDealReg = true;
                                                        dealregDecision = critera.Deal_Reg_Decision__c;
                                                        deagRegDiscountPercent = critera.Deal_Reg_Discount__c;   
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        opty.DealRegDecisionOpty__c = dealRegDecisionOpty;
                        if( directConsumption) {
                            opty.Auto_Deal_Registration_Rule_Applied__c = UtilityConstant.DIRECTCONSUMPTION_SP_TYPE_RULE;
                        }
                        else if(metTelAccount){
                            opty.Auto_Deal_Registration_Rule_Applied__c = UtilityConstant.METTELSP_ACCOUNT_RULE;                       
                        } else if(opty.Auto_Deal_Registration_Rule_Applied__c == SpecialCharacterConstant.CONCAT || opty.Auto_Deal_Registration_Rule_Applied__c == null) {                                                                                
                            opty.Auto_Deal_Registration_Rule_Applied__c=autoDealRegStatus;
                        }
                        
                        
                        if(dealregDecision != null) {
                            if(dealregDecision == UtilityConstant.APPROVE){
                                //if(deagRegDiscountPercent > 0) {
                                    opty.Auto_Approval_Status__c = UtilityConstant.APPROVEDWITH_DISCOUNT;
                                /*} else {
                                 opty.Auto_Approval_Status__c = UtilityConstant.APPROVEDWITHOUT_DISCOUNT;   
                               }  */
                                
                            } else if(dealregDecision == UtilityConstant.DENY){
                                opty.StageName = SIConstants.PROD_DEAL_REG_DENY;
                                opty.Discount_Amount__c = null;
                                opty.Discounted_Percentage__c = null;
                                opty.Custom_Deal_Reg_Percentage__c = null;
                                opty.Standard_Discount_Percentage__c =null;
                                opty.OTC_Discount_Amount__c = null;
                                opty.Cumulative_OTC_Discount_Price__c = null ;
                                opty.Discounted_Price__c = null ;
                            } else {
                            
                                opty.Auto_Approval_Status__c = UtilityConstant.REQUESTED; 
                            }
                            
                        } else {
                            opty.Auto_Approval_Status__c = UtilityConstant.REQUESTED;   
                        }
                                
                                        
                }
                              
                                      
                           
              }             
                            
                                   
            }
catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}           
        //This Method is for updating Deal Status On SP Product for Add Site when Approved Without Discount 
        //Optimization 4 for defect 8516    
/* 
 Name: doUpdateStatusonSPWithoutDiscount
 Description: 
 */ 
        public Void doUpdateStatusonSPWithoutDiscount(SObject[] oldObjects,SObject[] updatedObjects){
            try{
            List<Opportunity> listUpdatedOpptyWithoutDis = updatedObjects;
            List<Opportunity> oldListOppWithoutDis = oldObjects;
            List<SPProduct__c> listSPProductUpdate = new List<SPProduct__c>();
            List<SPProduct__c> spListToUpdate = new List<SPProduct__c>();
            Map<Id,SPProduct__c> mapToUpdateSP = new Map<Id,SPProduct__c>();
            Set<Id> oppIdSet = new Set<Id>();
            
            for(Opportunity oldListOpp : oldListOppWithoutDis){       
                for(Opportunity opplistUpdate : listUpdatedOpptyWithoutDis){
                
                    if(opplistUpdate.MACD_Type__c == UtilityConstant.A && opplistUpdate.Record_Type_Name_for_Internal_use__c == UtilityConstant.MACD
                       && opplistUpdate.Discounted_Price__c == opplistUpdate.Cumulative_List_Price__c && opplistUpdate.StageName == UtilityConstant.DEALREG_AUTO_APPROVED){                  
                           oppIdSet.add(opplistUpdate.id);                      
                    }
                }         
            }
        if(oppIdSet.size()>0){
                listSPProductUpdate = [Select id,Deal__c,Deal_Status__c from SPProduct__c where Deal__c =: oppIdSet];     
        }
            for(SPProduct__c spplist : listSPProductUpdate){
            
                spplist.Deal_Status__c = UtilityConstant.DEALREGISTRATION_APPROVED_WITHOUT_DISCOUNT; 
                spListToUpdate.add(spplist);              
            }
            if(spListToUpdate.size()>0 && spListToUpdate != null){
                update spListToUpdate;
            }
        }
        catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
        //Optimization 5 for defect 8516
/* 
 Name: doUpdateDealRegistrationDiscountPercentOnSP
 Description: 
 */ 
        public Void doUpdateDealRegistrationDiscountPercentOnSP(SObject[] oldObjects,SObject[] updatedObjects){
            try{
            List<Opportunity> listUpdatedOppty = updatedObjects;
            List<Opportunity> oldListOp = oldObjects;
            List<Opportunity> selectedOpptyList = new list<Opportunity>();
            List<SPProduct__c> listSP = new List<SPProduct__c>();
            List<SPProduct__c> spListToUpdate = new List<SPProduct__c>();       
            Map<String,SPProduct__c> mapSpListToUpdate = new Map<String,SPProduct__c>();
            Map<String,Opportunity> mapOpptyListToUpdate = new Map<String,Opportunity>();
            Set<Id> opptIdSet = new Set<Id>();
            
            for(Opportunity oldListOpp : oldListOp){
                for(Opportunity opplistUpdate : listUpdatedOppty){
                    if(oldListOpp.Discounted_Percentage__c != opplistUpdate.Discounted_Percentage__c ){
                       selectedOpptyList.add(opplistUpdate);
                       opptIdSet.add(opplistUpdate.id); 
                       mapOpptyListToUpdate.put(opplistUpdate.id,opplistUpdate);
                       }
                }         
            }
        if(opptIdSet.size()>0){
                listSP = [Select id,Deal_Registration_Discount__c,Deal__c from SPProduct__c where Deal__c =: opptIdSet];
        }
            for(SPProduct__c spplist : listSP){
                if(mapOpptyListToUpdate.containsKey(spplist.Deal__c)){
                   if(!(mapOpptyListToUpdate.get(spplist.Deal__c).Discounted_Price__c != null && mapOpptyListToUpdate.get(spplist.Deal__c).Cumulative_List_Price__c != null && mapOpptyListToUpdate.get(spplist.Deal__c).Cumulative_List_Price__c == mapOpptyListToUpdate.get(spplist.Deal__c).Discounted_Price__c && mapOpptyListToUpdate.get(spplist.Deal__c).Auto_Deal_Registration_Rule_Applied__c == 'Duplicate SP, EC & MIS Rule')){
                       spplist.Deal_Registration_Discount__c = mapOpptyListToUpdate.get(spplist.Deal__c).Discounted_Percentage__c ; 
                       System.debug('spplist.Deal_Registration_Discount__c************'+spplist.Deal_Registration_Discount__c);
                   } 
                   mapSpListToUpdate.put(spplist.Id,spplist);             
                }
            //    for(Opportunity Oppty : selectedOpptyList){
            //        spplist.Deal_Registration_Discount__c = Oppty.Discounted_Percentage__c ; 
                   // spListToUpdate.add(spplist); 
             //      mapSpListToUpdate.put(spplist.Id,spplist);
                    
             // }
                }
            
             for(SPProduct__c spList:mapSpListToUpdate.values()){
                spListToUpdate.add(spList); 
                
             }
                     
            if(spListToUpdate.size()>0 && spListToUpdate != null){
                update spListToUpdate;
            }
        }
        catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
        
/* 
 Name: createRDSExcelonOppty
 Description: 
 */ 
        public void createRDSExcelonOppty(SObject[] oldObjects,SObject[] updatedObjects){
            try{
            List<Opportunity> newOpps = updatedObjects;
            List<Opportunity> oldOpps= oldObjects;
            Set<Id> oppIdSet = new Set<Id>();
            List<Attachment> attList = new List<Attachment>();
            Map<Id,Opportunity> newOppMap = new Map<Id,Opportunity>();
        for(Opportunity opp:newOpps){
            newOppMap.put(opp.Id,opp);
        }
        for(Opportunity opp:oldOpps){
            //For deals submitted from Force portal "Submit RDS"
            if(opp.Ready_for_RDS_Excel__c  != newOppMap.get(opp.Id).Ready_for_RDS_Excel__c && newOppMap.get(opp.Id).Ready_for_RDS_Excel__c  == UtilityConstant.READY && newOppMap.get(opp.Id).ATOM_Deal__c){
                if(opp.MACD_Type__c != UtilityConstant.C && opp.MACD_Type__c != UtilityConstant.D){
                    OppIdSet.add(opp.Id);
                    CreateRDSExcelBatch batchclass = new CreateRDSExcelBatch();
                    batchclass.opptyId = opp.Id;
                    //Id batchInstanceId = Database.executeBatch(batchclass, 1);
                  //  String cronID = System.scheduleBatch(batchclass , UtilityConstant.CREATERDSEXCELBATCH, 1,1);
                   Database.executeBatch(batchclass, 1);
                }
                
            }
            //For Deal submission via BID
            else if(opp.RDS_Percent_Complete__c != newOppMap.get(opp.Id).RDS_Percent_Complete__c && newOppMap.get(opp.Id).RDS_Percent_Complete__c == 100 && !newOppMap.get(opp.Id).ATOM_Deal__c && newOppMap.get(opp.Id).API_Flag__c ){
                if(opp.MACD_Type__c != UtilityConstant.C && opp.MACD_Type__c != UtilityConstant.D){
                    OppIdSet.add(opp.Id);
                    CreateRDSExcelBatch batchclass = new CreateRDSExcelBatch();
                    batchclass.opptyId = opp.Id;
                    //Id batchInstanceId = Database.executeBatch(batchclass, 1);
                    String cronID = System.scheduleBatch(batchclass , UtilityConstant.CREATERDSEXCELBATCHBID, 5,1);
                }
            }
        }
       
      }
      catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }    
    }
    public void activateManualFlow(SObject[] oldObjects,SObject[] newObjects, boolean isInsert){
        
        List<Opportunity> oldOpptList = oldObjects;
        List<Opportunity> newOpptList = newObjects;
        if(isInsert){ 
            if(!newOpptList[0].Manualflow__c && newOpptList[0].Renewal_Contract__c == false && (newOpptList[0].StageName == 'Deal Registration Approved' || newOpptList[0].StageName == 'Deal Reg Auto-Approved')){
                Opportunity currOpty = [select id, name,Manualflow__c,Service_type__c from Opportunity where id =:newObjects limit 1];
                List<Admin_Control__c> adminControl = [select AVPN_CAP_P29__c,MIS_CAP_P29__c from Admin_Control__c limit 1 ];           
                if(adminControl != null && adminControl.size() > 0 && ((adminControl[0].AVPN_CAP_P29__c && currOpty.Service_type__c=='AVPN') || (adminControl[0].MIS_CAP_P29__c && currOpty.Service_type__c=='AMIS'))){
                     currOpty.Manualflow__c = true;
                     currOpty.Contract_Flow__c = 'Manual';
                     update currOpty;
                     system.debug('@@@inside if');
                }
            } 
        }else{
            if(oldOpptList != null && !newOpptList[0].Manualflow__c && newOpptList[0].Renewal_Contract__c == false){
                if((oldOpptList[0].StageName != newOpptList[0].StageName) && (newOpptList[0].StageName == 'Deal Registration Approved' || newOpptList[0].StageName == 'Deal Reg Auto-Approved')){
                    Opportunity currOpty = [select id, name,Manualflow__c,Service_type__c from Opportunity where id =:newObjects limit 1];
                    List<Admin_Control__c> adminControl = [select AVPN_CAP_P29__c,MIS_CAP_P29__c from Admin_Control__c limit 1 ];           
                    if(adminControl != null && adminControl.size() > 0 && ((adminControl[0].AVPN_CAP_P29__c && currOpty.Service_type__c=='AVPN') || (adminControl[0].MIS_CAP_P29__c && currOpty.Service_type__c=='AMIS'))){
                        currOpty.Manualflow__c = true;
                        currOpty.Contract_Flow__c = 'Manual';
                        update currOpty;
                        system.debug('@@@inside else');
                    }
                } 
            }
        }        
     }  
     
     /*To calculate the quote expiration date from lockin days*/
     public void calculateExpirationDate( SObject[] oldObjects, SObject[] updatedObjects, Boolean isUpdate ) {
         list<Opportunity> newOptyList =updatedObjects;
         list<Opportunity> oldOptyList =oldObjects;
         //list<Apttus_Proposal__Proposal__c> quote;
         //list<Admin_Control__c> adminControlList = [Select id, Lockin_days__c from Admin_Control__c LIMIT 1];
         try{
            if(newOptyList!= null && (!newOptyList.isEmpty())){
                for ( Integer i=0; i<newOptyList.size(); i++ ){
                    if(isUpdate){
                        if(oldOptyList[i].StageName != newOptyList[i].StageName && (newOptyList[i].StageName == SIConstants.OPTY_DEAL_APPROVED || newOptyList[i].StageName == SIConstants.OPTY_DEAL_Auto_Approved)){
                             //quote=[Select id,Apttus_Proposal__Opportunity__c,QuoteExpirationDate__c from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c =: newOptyList[i].id];
                             //quote[0].QuoteExpirationDate__c = system.today().adddays(integer.valueOf(newOptyList.get(i).Lockin_days__c));
                             //System.Debug('@@Quote Expiration Date='+quote[0].QuoteExpirationDate__c);
                             //newOptyList[i].Lockin_Days__c = adminControlList.get(0).Lockin_days__c;
                             //newOptyList[i].Quote_Expiration_Date__c = system.today().adddays(integer.valueOf(adminControlList.get(0).Lockin_days__c));
                            newOptyList[i].Price_Expiration_Date__c = system.today().adddays(integer.valueOf(newOptyList.get(i).Lockin_days__c)); 
                            newOptyList[i].Quote_Expiration_Date__c = system.today().adddays(integer.valueOf(newOptyList.get(i).Lockin_days__c));   
                        }
                    }
                    else{
                        if(newOptyList[i].StageName == SIConstants.OPTY_DEAL_APPROVED || newOptyList[i].StageName == SIConstants.OPTY_DEAL_Auto_Approved){
                           //quote=[Select id,Apttus_Proposal__Opportunity__c,QuoteExpirationDate__c from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c =: newOptyList[i].id];
                           //quote[0].QuoteExpirationDate__c = system.today().adddays(integer.valueOf(newOptyList.get(i).Lockin_days__c));
                           //System.Debug('@@Quote Expiration Date='+quote[0].QuoteExpirationDate__c);
                           //newOptyList[i].Lockin_Days__c = adminControlList.get(0).Lockin_days__c;
                           //newOptyList[i].Quote_Expiration_Date__c = system.today().adddays(integer.valueOf(adminControlList.get(0).Lockin_days__c)); 
                           newOptyList[i].Price_Expiration_Date__c = system.today().adddays(integer.valueOf(newOptyList.get(i).Lockin_days__c)); 
                           newOptyList[i].Quote_Expiration_Date__c = system.today().adddays(integer.valueOf(newOptyList.get(i).Lockin_days__c));    
                        }
                    }
                }
                //update quote;
            }
            }
            catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }    
 }