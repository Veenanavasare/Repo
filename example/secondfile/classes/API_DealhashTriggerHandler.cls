/*
     Component Name :API_DealhashTriggerHandler 
     Requirement/User Story Number :US238470 
     Requirement Description:Update Derived Fields from Multiple Objects to Deal Hash on Record Creation
     Component Author:Accenture IDC
     Created Date:5th May 2014 
     Version:1.0
*/
public with sharing class API_DealhashTriggerHandler extends SITriggerOperations.SITriggerImpl{

    public Boolean hasRun = false; 
/* 
 Name: onBeforeInsert
 Description: 
 */ 
    public override boolean onBeforeInsert (SObject[] newObjects){
        try{
            UpdateDiscountAmountOnDealHash(newObjects);
            UpdateBundleAccountNumber(newObjects);
            UpdateCustomerDefiningGroup(newObjects);            
            UpdateSPProductDetailsonDealHash(newObjects);
            UpdatePricingScheduleDetailsonDealHash(newObjects); 
            updateSelectedOpptyonDH(newObjects);     
       } catch (exception e){
            e.getMessage(); 
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return true;
    }
    
/* 
 Name: onAfterInsert
 Description: 
 */ 
    public override boolean onAfterInsert (SObject[] newObjects){
        try {
            updateDHOnRegularOpty(newObjects);
        }catch (exception e){
            e.getMessage();
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return true;
    } 
    
/* 
 Name: onBeforeUpdate
 Description: 
 */ 
    public override boolean onBeforeUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id,SObject>  newObjectsMap){
        try{
            updateCPNonDH(oldObjects,updatedObjects);
            updateProvisoningStatus(oldObjects,updatedObjects);
        } catch (exception e){
            e.getMessage();
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return true;
    } 
   
/* 
 Name: onAfterUpdate
 Description: 
 */ 
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap){
        try{
            insertDHStatusUpdateDealHashRecords(updatedObjects,oldObjects);
            insertDHstatusRecordsForMACD(updatedObjects,oldObjects);
            updateDHstatusRecordsForContractRenewal(updatedObjects,oldObjects);
            macdReviewedOnPremise(updatedObjects,oldObjects);              
            updateReviewCompleteonOppty(updatedObjects,oldObjects);
            UpdateCurrentVersionOnPremise(updatedObjects,oldObjects);          
            sendOutEmailOnSiteStatusActive(oldObjects,newObjectsMap);          
        } catch (exception e){
            e.getMessage();
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return true;
    }    
    
    Map<Id, List<Deal_Hash__c>> oppDealMap = new Map<Id, List<Deal_Hash__c>>();
    List<Deal_Hash__c> updatedDeals = new List<Deal_Hash__c>();
    
    /*
     Update RDS-Deal Hash Fields with Values from Related Account Field Values
     Deal Hash :Bundle Account Number
     Deal Hash : Customer ID
     Deal Hash: Hierarchy ID
     Deal Hash : Invoice Account Numebr   
   */ 
   public void updateBundleAccountNumber(SObject[] newObjects){
      try{ 
        List<Deal_Hash__c> bundleDeal = newObjects;
        Map<Id, Opportunity> accountOppMap = new Map<Id, Opportunity>();
                
        for(Deal_Hash__c deal :bundleDeal ){
            if(OppDealMap.containsKey(deal.Opportunity__c)){
                OppDealMap.get(deal.Opportunity__c).add(deal);
            } else{
                OppDealMap.put(deal.Opportunity__c, new List<Deal_Hash__c>{deal});
            }
        }
        if(!OppDealMap.isEmpty() && OppDealMap.size()>0){
            for(Opportunity opp : [Select Id,Account.hierarchyId__c,Account.invoiceAccountNumber__c, AccountId, Account.bundleAccountNumber__c,Account.customerId__c from Opportunity where Id IN:OppDealMap.keySet()]){
                AccountOppMap.put(opp.Id, opp);
            }
            if(!AccountOppMap.isEmpty() && AccountOppMap.size()>0) {
                for(String str:OppDealMap.keySet()){
                    for(Deal_Hash__c singleDeal :OppDealMap.get(str)){
                        if(singleDeal.Bundle_Account_Number__c == NULL && AccountOppMap.get(singleDeal.Opportunity__c).Account.bundleAccountNumber__c != NULL){
                            singleDeal.Bundle_Account_Number__c = AccountOppMap.get(singleDeal.Opportunity__c).Account.bundleAccountNumber__c;
                        }
                         if(singleDeal.Customer_ID__c == NULL && AccountOppMap.get(singleDeal.Opportunity__c).Account.customerId__c != NULL){
                            singleDeal.Customer_ID__c = AccountOppMap.get(singleDeal.Opportunity__c).Account.customerId__c;
                        }
                        if(singleDeal.Hierarchy_ID__c == NULL && AccountOppMap.get(singleDeal.Opportunity__c).Account.hierarchyId__c != NULL){
                            singleDeal.Hierarchy_ID__c = AccountOppMap.get(singleDeal.Opportunity__c).Account.hierarchyId__c;
                        } 
                        if(singleDeal.Invoice_Account_Number__c == NULL && AccountOppMap.get(singleDeal.Opportunity__c).Account.invoiceAccountNumber__c != NULL){
                            singleDeal.Invoice_Account_Number__c = AccountOppMap.get(singleDeal.Opportunity__c).Account.invoiceAccountNumber__c;
                        }
                        updatedDeals.add(singleDeal);
                    }
                } 
            }
        }  
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }
    
    /*
     Update RDS-Deal Hash Fields with Values from Related Endcustomer's and Account-End Customer Junction Field Values
     Deal Hash :Customer Defining Group ID     
     Deal Hash: SFDC Account End Customer ID (AEJ ID)
               
   */ 
    public void updateCustomerDefiningGroup(SObject[] newObjects)
    {
        try{
         List<Deal_Hash__c> cDGdeal = newObjects;
         Set <ID> endCustomerId= New set<Id>();
         Map<Id, Opportunity> oppEndCustMap = new Map<Id, Opportunity>();
         Set<ID> acctID= New Set<ID>();
         Map<Id, Account_End_Customer_Junction__c> accntEndCustJunctionMap = new Map<Id, Account_End_Customer_Junction__c>();
        
         
         for(Deal_Hash__c deal :CDGdeal){
            if(OppDealMap.containsKey(deal.Opportunity__c)) {
                OppDealMap.get(deal.Opportunity__c).add(deal);
            } else{
                OppDealMap.put(deal.Opportunity__c, new List<Deal_Hash__c>{deal});   
            }
         }
         
        if(!OppDealMap.isEmpty() && OppDealMap.size()>0){
            for(Opportunity opp : [Select Id,AccountID, End_Customer__c, End_Customer__r.CDG__c from Opportunity where Id IN:OppDealMap.keySet()]){
                OppEndCustMap.put(opp.Id, opp);
                endCustomerId.add(opp.End_Customer__c);
                acctID.add(opp.AccountID);
            }
            
            if(endCustomerId.size()>0){
                for(Account_End_Customer_Junction__c accEndCust: [Select Id,Name, End_Customer__c,Account_End_Customer_Junction__c.Account__c,Account_End_Customer_Junction__c.Account__r.Id,Account_End_Customer_Junction__c.End_Customer__r.ID
                 from Account_End_Customer_Junction__c where Account_End_Customer_Junction__c.End_Customer__r.ID IN:endCustomerId]){
                    AccntEndCustJunctionMap.put(accEndCust.End_Customer__c , accEndCust);
                }
            }
         
            if(!AccntEndCustJunctionMap.isEmpty() && AccntEndCustJunctionMap.size()>0){
                for(String str:OppDealMap.keySet()){
                    for(Deal_Hash__c singleDeal :OppDealMap.get(str)){
                        if(OppEndCustMap.size()>0){
                            for(Opportunity oppCheck:OppEndCustMap.Values()) {
                                if(singleDeal.Customer_Defining_Group_ID__c == NULL && OppEndCustMap.get(singleDeal.Opportunity__c).End_Customer__r.CDG__c != NULL){
                                    singleDeal.Customer_Defining_Group_ID__c = OppEndCustMap.get(singleDeal.Opportunity__c).End_Customer__r.CDG__c;
                                }
                                if(OppEndCustMap.get(singleDeal.Opportunity__c).End_Customer__r.Id == AccntEndCustJunctionMap.get(oppCheck.End_Customer__c).End_Customer__r.ID ){
                                    singleDeal.SFDC_Account_End_Customer_ID_AEJ_ID__c=AccntEndCustJunctionMap.get(oppCheck.End_Customer__c).Name;
                                }
                            updatedDeals.add(singleDeal);
                            }
                        }
                    }    
                } 
            }
        }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    
    }   
    
    /*
     Update RDS-Deal Hash Fields with Values from Related Opprtunity's Products
     Deal Hash :Contract Number    
     Deal Hash: Discount Ammount
     Deal Hash: Discount Plan ID
     Deal Hash: Rate Plan ID 
     Deal Hash: Sub Account Number               
    */
     public void updateSPProductDetailsonDealHash(SObject[] newObjects){
      try{
        List<Deal_Hash__c> sPdeal = newObjects;
        Map<Id, SPProduct__c> oppProductMap = new Map<Id, SPProduct__c>();
        Set<ID> acctID= New Set<ID>();
                 
        for(Deal_Hash__c deal :SPdeal){
            if(OppDealMap.containsKey(deal.Opportunity__c)) {
                OppDealMap.get(deal.Opportunity__c).add(deal);
            } else{
                OppDealMap.put(deal.Opportunity__c, new List<Deal_Hash__c>{deal});   
            }
        }
          
        if(!OppDealMap.isEmpty()&& OppDealMap.size()>0){
            for(SPProduct__c spProduct: [Select Id, ServiceContractNumber__c,Term_Length_Value__c,Term_Length__c,Exclusivity_Period_Months__c,Deal_Rate_Plan_ID__c,Deal_Registration_Discount__c,rate_plan__c,Sub_Account__c,EBM_Discount_Plan_ID__c, Deal__c,SPProduct__c.Deal__r.ID from SPProduct__c where SPProduct__c.Deal__r.Id IN:OppDealMap.keySet() LIMIT 1]){
                OppProductMap.put(spProduct.Deal__r.Id ,spProduct);
            }
             
            for(String str:OppDealMap.keySet()){
                for(Deal_Hash__c singleDeal :OppDealMap.get(str)){
                    if(OppProductMap.size()>0){ 
                        if(singleDeal.Contract_Number__c==NULL && OppProductMap.get(singleDeal.Opportunity__c).ServiceContractNumber__c!=NULL){
                            singleDeal.Contract_Number__c = OppProductMap.get(singleDeal.Opportunity__c).ServiceContractNumber__c;
                        }
                                 
                        if(singleDeal.Discount_Plan_ID__c==NUll && OppProductMap.get(singleDeal.Opportunity__c).EBM_Discount_Plan_ID__c!=NULL){
                            singleDeal.Discount_Plan_ID__c = OppProductMap.get(singleDeal.Opportunity__c).EBM_Discount_Plan_ID__c;
                        }
                         
                        if(singleDeal.Rate_Plan_ID__c==NUll && OppProductMap.get(singleDeal.Opportunity__c).Deal_Rate_Plan_ID__c!=NULL){
                            singleDeal.Rate_Plan_ID__c = OppProductMap.get(singleDeal.Opportunity__c). Deal_Rate_Plan_ID__c;
                        }
                         
                        if(singleDeal.Sub_Account_Number__c==NUll && OppProductMap.get(singleDeal.Opportunity__c).Sub_Account__c!=NULL){
                            singleDeal.Sub_Account_Number__c = OppProductMap.get(singleDeal.Opportunity__c).Sub_Account__c;
                        }
                         
                        if(singleDeal.Term__c== NUll && OppProductMap.get(singleDeal.Opportunity__c).Term_Length_Value__c!=NULL){
                            singleDeal.Term__c = String.ValueOf(Integer.valueOf(OppProductMap.get(singleDeal.Opportunity__c).Term_Length_Value__c)*12);
                        }
                    updatedDeals.add(singleDeal);
                    }
                }
            }
        }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
        
    }
      
   /* To update Discount Amount on Deal Hash from Opportunity's Deal Reg Discount Percent- Hot fix(10/15)*/
    public void updateDiscountAmountOnDealHash (SObject[] newObjects){
     try{   
        List<Deal_Hash__c> newDealHash = newObjects;
        Set<ID> oppIdset = new Set<ID>();
        List<Deal_Hash__c> updatedList = new List<Deal_Hash__c>();
     
        for(Deal_Hash__c dh:newDealHash){
            oppIdset.add(dh.Opportunity__c);
        }
     
        if(oppIdset.size()>0){ 
            for(Opportunity opp: [Select Id, Discounted_Percentage__c,Deal_Registration_Discounted_Percentage__c from Opportunity where Id IN:oppIdset]){   
                for(Deal_Hash__c dh : newDealHash){
                    if(opp.Deal_Registration_Discounted_Percentage__c !=null && dh.Opportunity__c == opp.Id){
                        dh.Discount_Amount__c = opp.Deal_Registration_Discounted_Percentage__c;
                        updatedList.add(dh);
                    }
                }
            }
        }
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }    
    
     /*
     Update RDS-Deal Hash Fields with Values from Related RDS/Pricing Schedule Field Values
     Deal Hash :Rate Stability Date 
     Deal Hash : Start Date
     */
    public void updatePricingScheduleDetailsonDealHash(SObject[] newObjects){ 
      try{
         List<Deal_Hash__c> pricingschedList = newObjects;
         Map<Id, RDS_Pricing_Schedule_Detail__c> oppPricingScheduleMap = new Map<Id, RDS_Pricing_Schedule_Detail__c>();
         Datetime ratedate = DateTime.parse('7/13/2014 11:46 AM');
         Set<ID> acctID= New Set<ID>();
                 
         for(Deal_Hash__c deal :pricingschedList){
            if(OppDealMap.containsKey(deal.Opportunity__c)) {
                 OppDealMap.get(deal.Opportunity__c).add(deal);
            } else{
                OppDealMap.put(deal.Opportunity__c, new List<Deal_Hash__c>{deal});  
            }
         }  
         
         if(!OppDealMap.isEmpty()&& OppDealMap.size()>0){      
            for(RDS_Pricing_Schedule_Detail__c rdsPS: [Select Id, EBM_Sign_Date__c,PE_Sign_Date__c,RDS_Pricing_Schedule_Detail__c.Deal__c from RDS_Pricing_Schedule_Detail__c where RDS_Pricing_Schedule_Detail__c.Deal__c IN:OppDealMap.keySet() LIMIT 1 ]){
                OppPricingScheduleMap.put(rdsPS.Deal__c ,rdsPS);
            }
            
         if (!OppPricingScheduleMap.isEmpty() && OppPricingScheduleMap.size()>0 ) {           
            for(String str:OppDealMap.keySet()){
                for(Deal_Hash__c singleDeal :OppDealMap.get(str)){
                    if(singleDeal.Rate_Stability_Date__c==NULL && OppPricingScheduleMap.get(singleDeal.Opportunity__c).PE_Sign_Date__c!=NULL && OppPricingScheduleMap.get(singleDeal.Opportunity__c).PE_Sign_Date__c>Ratedate){
                     singleDeal.Rate_Stability_Date__c = OppPricingScheduleMap.get(singleDeal.Opportunity__c).PE_Sign_Date__c;
                     }
                     else if(singleDeal.Rate_Stability_Date__c==NULL && OppPricingScheduleMap.get(singleDeal.Opportunity__c).PE_Sign_Date__c!=NULL && OppPricingScheduleMap.get(singleDeal.Opportunity__c).PE_Sign_Date__c<Ratedate){
                     singleDeal.Rate_Stability_Date__c=Ratedate;
                     }
                    //Start date for API flag
                    if(OppPricingScheduleMap.get(singleDeal.Opportunity__c).EBM_Sign_Date__c!=NULL && (!singleDeal.X3rd_Party_Flag_On_Opportunity__c) && OppPricingScheduleMap.get(singleDeal.Opportunity__c).EBM_Sign_Date__c>Ratedate){
                    singleDeal.Start_Date__c = OppPricingScheduleMap.get(singleDeal.Opportunity__c).EBM_Sign_Date__c;
                    }                    
                    //Start date for 3rd party flag
                    else if(OppPricingScheduleMap.get(singleDeal.Opportunity__c).PE_Sign_Date__c!=NULL && (singleDeal.X3rd_Party_Flag_On_Opportunity__c) && OppPricingScheduleMap.get(singleDeal.Opportunity__c).PE_Sign_Date__c > Ratedate){
                    singleDeal.Start_Date__c = OppPricingScheduleMap.get(singleDeal.Opportunity__c).PE_Sign_Date__c;
                    }  else{
                    //defaults Start date to 7/13
                    singleDeal.Start_Date__c=Ratedate;}
                    updatedDeals.add(singleDeal);                    
                }    
            }
         }
        }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    
    }
      
      /*
     User Story:US241753
     Description :Create DHStatus-Update Deal Hash Details entries      
     */
     public void insertDHStatusUpdateDealHashRecords(SObject[] newObjects,SObject[] oldObjects){
      try{
        List<Deal_Hash__c> newDealHash = newObjects; 
        List<Deal_Hash__c> oldDealHash = oldObjects; 
        Map<Id,Deal_Hash__c> mapOfIdandParent = new Map<Id,Deal_Hash__c>();
        Map<Id, List<DHStatus_Update_Deal_Hash_Details__c>> dhStatusMap = new Map<Id,List<DHStatus_Update_Deal_Hash_Details__c>>();
        Map<Id,List<RDS_Premise_Details__c>> mapofIdandListofPremise = new Map<Id,List<RDS_Premise_Details__c>>();
        List<DHStatus_Update_Deal_Hash_Details__c> listOfDHStatustoInsert = new List<DHStatus_Update_Deal_Hash_Details__c>();
        List<RDS_Premise_Details__c> listOfPremiseDetails = new List<RDS_Premise_Details__c>();
        
        for(Deal_Hash__c d:newDealHash ){
            for(Deal_Hash__c dold:oldDealHash ){
                if((d.IsDealHashCreationSuccess__c == true && dold.IsDealHashCreationSuccess__c == false) && d.RenewedQuote__c == null){
                    mapOfIdandParent.put(d.id,d);   
                }     
            }
        }
        if(mapOfIdandParent.size()>0){
            for(DHStatus_Update_Deal_Hash_Details__c dhStatus : [Select Id,RDS_Deal_Hash__c from DHStatus_Update_Deal_Hash_Details__c where RDS_Deal_Hash__c IN: mapOfIdandParent.keySet() ]){
                if(dhStatusMap.containsKey(dhStatus.RDS_Deal_Hash__c)){
                    dhStatusMap.get(dhStatus.RDS_Deal_Hash__c).add(dhStatus );
                } else{  
                    dhStatusMap.put(dhStatus.RDS_Deal_Hash__c,new List<DHStatus_Update_Deal_Hash_Details__c>{dhStatus} );
                }
            }        
            
            for(RDS_Premise_Details__c singleRDS: [Select id,DealHash__c,Site_Status__c,Premise_Number__c,GRID_Premise_ID__c,MACD_Change_Type__c, Transport_Type__c from RDS_Premise_Details__c where RDS_Premise_Details__c.DealHash__c in:mapOfIdandParent.keySet()]){
                if(mapofIdandListofPremise.containsKey(singleRDS.DealHash__c)){ 
                    mapofIdandListofPremise.get(singleRDS.DealHash__c).add(singleRDS);
                } else{ 
                    mapofIdandListofPremise.put(singleRDS.DealHash__c,new List<RDS_Premise_Details__c>{singleRDS});
                }
            } 
               
            if(mapofIdandListofPremise.size()>0) {
                for(String id:mapofIdandListofPremise.keySet()){
                    for(RDS_Premise_Details__c premise: mapofIdandListofPremise.get(id)){
                        if(mapOfIdandParent.get(id).RDS_object_status__c ==SIConstants.RDSSTATUSCREATE && !dhStatusMap.containsKey(id) && (premise.Site_Status__c!=SIConstants.RDS_PREMISE_SITE_STATUS_CANCELLED && premise.Site_Status__c!=SIConstants.RDS_PREMISE_SITE_STATUS_PENDINGCANCEL)){
                            DHStatus_Update_Deal_Hash_Details__c dhStatus = new DHStatus_Update_Deal_Hash_Details__c();             
                            dhStatus.RDS_Deal_Hash__c= mapOfIdandParent.get(id).Id;
                            dhStatus.Premise_Number__c = premise.Premise_Number__c;
                            dhStatus.RDS_Premise_Details_For_DHStatus__c = premise.Id; 
                            dhStatus.MACD_Change_Type__c = premise.MACD_Change_Type__c;
                            if(premise.Transport_Type__c == UtilityConstant.T1 || premise.Transport_Type__c == UtilityConstant.NT1){
                                dhStatus.Demarc_Location__c= UtilityConstant.SPCHPL;
                            } else if (premise.Transport_Type__c == UtilityConstant.SWITCHEDETHERNET) {
                                dhStatus.Demarc_Location__c= UtilityConstant.SPCHETH;
                            }
                            listOfDHStatustoInsert.add(dhStatus);
                        }
                    }
                }
            }
        }
        
        if(listOfDHStatustoInsert.size()>0){
            try{
             insert listOfDHStatustoInsert;
             } catch(Exception ex){
               ex.getMessage();
               ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
             }
        }  
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
        
    }
  
/* To update RDS Deal Hash on regular Opportunity */
/* 
 Name: updateDHOnRegularOpty
 Description: 
 */ 
    public void updateDHOnRegularOpty(SObject[] newObjects){
      try{ 
        List<Deal_Hash__c> newDealHash = newObjects;
        Map<String,Deal_Hash__c> optyDHMap = new Map<String,Deal_Hash__c>();
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
         
        for(Deal_Hash__c dh:newDealHash){
            if(dh.Opportunity__c != null){
                OptyDHMap.put(dh.Opportunity__c, dh);
            }
        }
        
        if(OptyDHMap.size()>0){
            for(Opportunity opp: [Select Id, RDS_Deal_Hash__c, MACD_Type__c from Opportunity where Id IN:OptyDHMap.keyset() AND (MACD_Type__c != 'D' AND MACD_Type__c!= 'A')]){
                if(opp.RDS_Deal_Hash__c == null){
                    opp.RDS_Deal_Hash__c = OptyDHMap.get(opp.Id).Id;
                    oppListToUpdate.add(opp);
                }
            }
        }
        
        if(oppListToUpdate.size()>0){
            try{
                update oppListToUpdate;
            } catch(Exception ex){
                ex.getMessage();
                ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            }
        } 
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
        
    } 
    
    /*This method is to insert DHstatus Records whenever we get a new premise after any MACD is performed. 
    The records only gets inserted when we have GRID premise ID populated on related premise and status changes from in progress to success.  */  
    public void insertDHstatusRecordsForMACD(SObject[] newObjects,SObject[] oldObjects){
     try{ 
        List<Deal_Hash__c> newDealHash = newObjects; 
        List<Deal_Hash__c> oldDealHash = oldObjects; 
        Map<Id,Deal_Hash__c> mapOfdh = new Map<Id,Deal_Hash__c>();
        List<RDS_Premise_Details__c> listOfPremiseDetails = new List<RDS_Premise_Details__c>();
        List<DHStatus_Update_Deal_Hash_Details__c> listOfDhstatusToinsert = new List<DHStatus_Update_Deal_Hash_Details__c>();
        List<DHStatus_Update_Deal_Hash_Details__c> listOfDhstatuswithVersion = new List<DHStatus_Update_Deal_Hash_Details__c>();
        
        for(Deal_Hash__c dnew : newDealHash){
            for(Deal_Hash__c dold:oldDealHash ){
                if(dnew.Id == dold.Id && dnew.RenewedQuote__c == null && dnew.MACD_Update_Status__c == UtilityConstant.SUCCESS && dold.MACD_Update_Status__c == UtilityConstant.INPROGRESS){
                    mapOfdh.put(dnew.id,dnew);   
                }               
            }
        }
        if(mapOfdh.size()>0){
            listOfPremiseDetails = [Select id,DealHash__c,Site_Status__c,RDS_Version__c,MACD_Type__c, MACD_Change_Type__c,Premise_Number__c,GRID_Premise_ID__c, Transport_Type__c from RDS_Premise_Details__c where RDS_Premise_Details__c.DealHash__c =: mapOfdh.keySet() AND RDS_Version__c =: Decimal.valueof(mapOfdh.values().RDS_Version_Select__c)];
            
            listOfDhstatuswithVersion = [Select id,RDS_Version__c,RDS_Deal_Hash__c from DHStatus_Update_Deal_Hash_Details__c where RDS_Deal_Hash__c in:mapOfdh.keySet() AND RDS_Version__c =: Decimal.valueof(mapOfdh.values().RDS_Version_Select__c)];
        }
        
        if(listOfPremiseDetails.size()>0 && listOfDhstatuswithVersion.size()<1 ){
            for(RDS_Premise_Details__c pre:listOfPremiseDetails){
             if(pre.Site_Status__c!=SIConstants.RDS_PREMISE_SITE_STATUS_CANCELLED && pre.Site_Status__c!=SIConstants.RDS_PREMISE_SITE_STATUS_PENDINGCANCEL)
              {
                DHStatus_Update_Deal_Hash_Details__c dhs = new DHStatus_Update_Deal_Hash_Details__c();
                dhs.RDS_Premise_Details_For_DHStatus__c = pre.id;
                dhs.RDS_Deal_Hash__c = pre.DealHash__c;
                dhs.Premise_Number__c = pre.Premise_Number__c;   
                dhs.MACD_Change_Type__c = pre.MACD_Change_Type__c; 
                if(pre.Transport_Type__c == UtilityConstant.T1 || pre.Transport_Type__c == UtilityConstant.NT1){
                    dhs.Demarc_Location__c= UtilityConstant.SPCHPL;
                } else if (pre.Transport_Type__c == UtilityConstant.SWITCHEDETHERNET) {
                    dhs.Demarc_Location__c= UtilityConstant.SPCHETH;
                }
                listOfDhstatusToinsert.add(dhs); 
              }           
            }
        }
        
        if(listOfDhstatusToinsert.size()>0){
            try{
                insert listOfDhstatusToinsert;
            } Catch(Exception e){
                e.getMessage();
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }
    
    /*This method is to insert DHstatus Record when the Contract Renewal Update Status is updated to Success*/  
    public void updateDHstatusRecordsForContractRenewal(SObject[] newObjects,SObject[] oldObjects){
        try{ 
            system.debug('@@@inside updateDHstatusRecordsForContractRenewal');
            List<Deal_Hash__c> newDealHash = newObjects; 
            List<Deal_Hash__c> oldDealHash = oldObjects; 
            Map<Id,Deal_Hash__c> dealHashMap = new Map<Id,Deal_Hash__c>();
            Map<id,Deal_Hash__c> createRenewalContractDealHashMap = new Map<id, Deal_Hash__c>();
            List<RDS_Premise_Details__c> activePremiseList = new List<RDS_Premise_Details__c>();
            List<DHStatus_Update_Deal_Hash_Details__c> dhsListToInsert = new List<DHStatus_Update_Deal_Hash_Details__c>();
            List<DHStatus_Update_Deal_Hash_Details__c> existingDHSRecordList = new List<DHStatus_Update_Deal_Hash_Details__c>();
            
            for(Deal_Hash__c dnew : newDealHash){
                for(Deal_Hash__c dold :oldDealHash ){
                    if(dold.Id == dnew.Id && dnew.RenewedQuote__c != null && (dold.MACD_Update_Status__c == UtilityConstant.INPROGRESS || dold.MACD_Update_Status__c == UtilityConstant.FAILED) && dnew.MACD_Update_Status__c == UtilityConstant.SUCCESS){
                        dealHashMap.put(dnew.id,dnew);   
                    } 
                     if(dold.Id == dnew.Id && dnew.RenewedQuote__c != null &&  ((dnew.MACD_Update_Status__c != null && (dnew.MACD_Update_Status__c != dold.MACD_Update_Status__c) && (dnew.MACD_Update_Status__c == UtilityConstant.FAILED))  || (dnew.RDS_object_status__c!=null && (dnew.RDS_object_status__c != dold.RDS_object_status__c) && (dnew.RDS_object_status__c.equalsIgnoreCase('Deal Hash Creation API Failed'))) )){
                        if(!createRenewalContractDealHashMap.containsKey(dnew.id)){
                            createRenewalContractDealHashMap.put(dnew.id,dnew);
                        }
                    }               
                }
            }
            
            if(!createRenewalContractDealHashMap.isEmpty() && SIConstants.allowIDHITSTicketCreation == true){
                RDSExcelExceptionHandling rdsExcelExceptionHandlingObj = new RDSExcelExceptionHandling();
                rdsExcelExceptionHandlingObj.createContractRenewalDHITSTicket(createRenewalContractDealHashMap);
                SIConstants.allowIDHITSTicketCreation = false;
            }
            
            if(dealHashMap.size()>0){
                activePremiseList = [Select id,DealHash__c,DealHash__r.Old_Contract_Number__c,DealHash__r.RenewedQuote__c,Site_Status__c,RDS_Version__c,MACD_Type__c, MACD_Change_Type__c,Premise_Number__c,GRID_Premise_ID__c, Transport_Type__c from RDS_Premise_Details__c where RDS_Premise_Details__c.DealHash__c =: dealHashMap.keySet() AND RDS_Version__c =: dealHashMap.values().RDS_Version__c AND Site_Status__c = 'PENDING_CONTRACT_RENEWAL' order by Id ];
                existingDHSRecordList = [Select id,RDS_Version__c,RDS_Deal_Hash__c from DHStatus_Update_Deal_Hash_Details__c where RDS_Deal_Hash__c in:dealHashMap.keySet() AND RDS_Version__c =: dealHashMap.values().RDS_Version__c];
            }
            system.debug('@@@activePremiseList'+activePremiseList);
            system.debug('@@@existingDHSRecordList'+existingDHSRecordList);
            
            if(activePremiseList.size()>0 && existingDHSRecordList.size()<1){
                DHStatus_Update_Deal_Hash_Details__c dhs = new DHStatus_Update_Deal_Hash_Details__c();
                dhs.RDS_Premise_Details_For_DHStatus__c = activePremiseList[0].id;
                dhs.RDS_Deal_Hash__c = activePremiseList[0].DealHash__c;
                dhs.Premise_Number__c = activePremiseList[0].Premise_Number__c;   
                dhs.MACD_Change_Type__c = activePremiseList[0].MACD_Change_Type__c; 
                dhs.Renewed_Quote__c = activePremiseList[0].DealHash__r.RenewedQuote__c;                
                dhs.Renewal_Contract__c = true;
                String workActionList = '';
                if(activePremiseList[0].Transport_Type__c == UtilityConstant.T1 || activePremiseList[0].Transport_Type__c == UtilityConstant.NT1){
                    dhs.Demarc_Location__c= UtilityConstant.SPCHPL;
                } else if (activePremiseList[0].Transport_Type__c == UtilityConstant.SWITCHEDETHERNET) {
                    dhs.Demarc_Location__c= UtilityConstant.SPCHETH;
                }
                for(RDS_Premise_Details__c pr : activePremiseList){
                    workActionList += '~'+pr.GRID_Premise_ID__c;                                             
                }
                dhs.Work_Action_List__c = activePremiseList[0].DealHash__r.Old_Contract_Number__c+workActionList;                
                dhsListToInsert.add(dhs);
            }
        
            if(dhsListToInsert.size()>0){
                try{
                    insert dhsListToInsert;
                } Catch(Exception e){
                    e.getMessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            }
        }catch(Exception ex){
            ATTException.logException(ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }
    
    /*This method will update the Premise Record's Is Reviewed Checkbox to true whenever user has completed review on RDS for a particular select version*/    
    public void macdReviewedOnPremise(SObject[] newObjects,SObject[] oldObjects){
     try{   
        List<Deal_Hash__c> newDealHash = newObjects; 
        List<Deal_Hash__c> oldDealHash = oldObjects; 
        List<RDS_Premise_Details__c> listOfPremiseDetails = new List<RDS_Premise_Details__c>();
        List<RDS_Premise_Details__c> listofPremiseToBeUpDated = new List<RDS_Premise_Details__c>();
        Map<Id,Deal_Hash__c> mapOfdh = new Map<Id,Deal_Hash__c>();
        for(Deal_Hash__c dnew  :newDealHash){
            for(Deal_Hash__c dold:oldDealHash ){
                if(dnew.Id == dold.Id && dnew.Is_MACDReviewComplete__c == true && dold.Is_MACDReviewComplete__c == false){
                    mapOfdh.put(dnew.id,dnew);   
                }               
            }
        }
        if(!mapOfdh.isEmpty()&& mapOfdh.size()>0){
            listOfPremiseDetails = [Select id,DealHash__c,RDS_Version__c,Is_Reviewed__c,MACD_Type__c,Premise_Number__c,GRID_Premise_ID__c from RDS_Premise_Details__c where DealHash__c =: mapOfdh.keySet()  and RDS_Version__c =: Decimal.valueof(mapOfdh.values().RDS_Version_Select__c) ];
        }
        if(listOfPremiseDetails.size()>0){
            for(RDS_Premise_Details__c pre:listOfPremiseDetails){
                if(pre.Is_Reviewed__c == false)
                pre.Is_Reviewed__c = true;
                listofPremiseToBeUpDated.add(pre);
            }
        }
        if(listofPremiseToBeUpDated.size()>0){
            try{
                update listofPremiseToBeUpDated;
            } Catch(Exception e){
                e.getMessage();
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    
    }
     
// This method is to update Selected Opportunity field on DH based on the version # selected on RDS Version Select field.//
/* 
 Name: updateCPNonDH
 Description: 
 */ 
    public void updateCPNonDH(SObject[] oldObjects,SObject[] updatedObjects){
     try{   
        List<Deal_Hash__c> oldDealHash = oldObjects;
        List<Deal_Hash__c> newDealHash = updatedObjects;
        Map<String, RDS_Premise_Details__c> premiseDetailsMap = new Map<String,RDS_Premise_Details__c>();
        Map<Id,Deal_Hash__c> mapOfdhVersion = new Map<Id,Deal_Hash__c>();
        Map<Id,Deal_Hash__c> mapOfdhVersionALL = new Map<Id,Deal_Hash__c>();
        List<Deal_Hash__c> dealHashUpdateList = new List<Deal_Hash__c>();
        List<Deal_Hash__c> dealHashUpdateRvwList = new List<Deal_Hash__c>();
        List<Opportunity> opptyList = new List<Opportunity>();
        Set<Decimal> versionSet = new Set<Decimal>();
        Boolean brk = true;
        
        for(Deal_Hash__c dnew  :newDealHash){
            for(Deal_Hash__c dold:oldDealHash ){
                if(dnew.Id == dold.Id && dnew.RDS_Version_Select__c != dold.RDS_Version_Select__c && dnew.RDS_Version_Select__c != UtilityConstant.ALL && dnew.RDS_Version_Select__c != SpecialCharacterConstant.CONCAT){
                    mapOfdhVersion.put(dnew.id,dnew);  
                }  
                if(dnew.RDS_Version_Select__c == UtilityConstant.ALL || dnew.RDS_Version_Select__c == SpecialCharacterConstant.CONCAT ){
                    mapOfdhVersionALL.put(dnew.id,dnew);     
                }
            }
        }
        
        if(mapOfdhVersion.size()>0){
             for(RDS_Premise_Details__c rdsP : [Select Id, DealHash__c, OpptyID__c,RDS_Version__c, MACD_Change_Type__c, Customer_Project_Number__c, Is_Reviewed__c, MACD_Type__c from RDS_Premise_Details__c WHERE DealHash__c =: mapOfdhVersion.keySet() AND RDS_Version__c =: Decimal.valueof(mapOfdhVersion.values().RDS_Version_Select__c)]){
                premiseDetailsMap.put(rdsP.DealHash__c, rdsP);
                versionSet.add(rdsP.RDS_Version__c);
             }
            if(premiseDetailsMap.size()>0){
                opptyList = [Select id,BID_ID__c, RDS_Deal_Hash__c, RDS_Version__c from Opportunity where RDS_Deal_Hash__c =:premiseDetailsMap.keyset() AND RDS_Version__c =: versionSet];              
                
                for(Deal_Hash__c dh : mapOfdhVersion.values()){
                    for(RDS_Premise_Details__c p : premiseDetailsMap.values()){
                        if(opptyList.size()>0){
                            for(Opportunity opp :opptyList ){
                                if(p.DealHash__c == dh.Id && opp.RDS_Deal_Hash__c == dh.Id && p.RDS_Version__c == Decimal.valueof(dh.RDS_Version_Select__c) && opp.RDS_Version__c == p.RDS_Version__c ){
                                    dh.Selected_Opportunity__c = opp.id;
                                    dealHashUpdateList.add(dh);
                                }
                            }
                        }
                    }
                }
                
                for(Deal_Hash__c dhs : mapOfdhVersion.values()){
                    for(RDS_Premise_Details__c prd : premiseDetailsMap.values()){
                        if(prd.DealHash__c == dhs.Id && prd.RDS_Version__c == Decimal.valueof(dhs.RDS_Version_Select__c) && brk==true){
                            if(prd.MACD_Type__c == UtilityConstant.D || prd.MACD_Change_Type__c == UtilityConstant.UBBADD || prd.MACD_Change_Type__c == UtilityConstant.UBBCHANGE || prd.MACD_Change_Type__c == UtilityConstant.UBBREMOVE){
                                dhs.Is_Review_Complete_for_Version__c = true;
                                brk = false;
                            } else if(prd.Is_Reviewed__c == true){
                                dhs.Is_Review_Complete_for_Version__c = true;
                            } else if(prd.Is_Reviewed__c == false){
                                dhs.Is_Review_Complete_for_Version__c = false;
                                brk = false;
                            }
                            dealHashUpdateRvwList.add(dhs);
                        }
                    }
                }
            } else{
                for(Deal_Hash__c dhs : mapOfdhVersion.values()){
                    dhs.Is_Review_Complete_for_Version__c = false;
                    dealHashUpdateRvwList.add(dhs);
                }
            }   
        }
        
        if(mapOfdhVersionALL.size()>0){
            for(Deal_Hash__c dh : mapOfdhVersionALL.values()){
                dh.Selected_Opportunity__c = dh.Opportunity__c;
                dh.Is_Review_Complete_for_Version__c = false;
                dealHashUpdateList.add(dh);
            }
        }
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    
    }
    
    //This method is to populate the pre provisioning status for MACD deal after RDS Review is completed.
/* 
 Name: updateReviewCompleteonOppty
 Description: 
 */ 
    public void updateReviewCompleteonOppty(SObject[] updatedObjects,SObject[] oldObjects){
    try{    
         List<Deal_Hash__c> oldDealHash = oldObjects;
         List<Deal_Hash__c> newDealHash = updatedObjects;
         List<Deal_Hash__c> dealHashUpdateList = new List<Deal_Hash__c>();
         List<Opportunity> opptyList = new List<Opportunity>();
         List<Opportunity> opptyListToupdate = new List<Opportunity>();
         List<Opportunity> newopptyList = new List<Opportunity>();
         List<Opportunity> opptysForAddSiteCheck = new List<Opportunity>();
         
         Set<ID> setOfopptyId = new Set<ID>(); 
         Set<ID> setOfopptyIdAdd = new Set<ID>(); 
          
          for(Deal_Hash__c dnewAdd  :newDealHash){
              setOfopptyIdAdd.add(dnewAdd.Selected_Opportunity__c);
          }
          opptysForAddSiteCheck = [Select Id, RDS_Deal_Hash__c, MACD_Type__c, RDS_Version__c from Opportunity where Id IN:setOfopptyIdAdd order by RDS_Version__c desc];
          if(opptysForAddSiteCheck != null && opptysForAddSiteCheck.size()>0){
              String macdTypeOppty = opptysForAddSiteCheck[0].MACD_Type__c;
          
         for(Deal_Hash__c dnew  :newDealHash){
            for(Deal_Hash__c dold:oldDealHash ){
                if((dnew.Id == dold.Id && dnew.Is_Review_Complete_for_Version__c != dold.Is_Review_Complete_for_Version__c && dnew.Is_Review_Complete_for_Version__c == true && dnew.RDS_Version__c > 1) || (macdTypeOppty == UtilityConstant.A && dnew.RDS_Version__c > 1 && dnew.Is_Review_Complete_for_Version__c == true)){
                    setOfopptyId .add(dnew.Selected_Opportunity__c);
                }
            }
        }
       }
        if(setOfopptyId .size()>0){      
            opptyList = [select id,BID_ID__c,Review_Check__c,InterfaceChanged__c ,MACD_RDS_Review_Completed_Status__c,MACD_RDS_Review_Complete_LastTimeStamp__c,BackendMACDType__c from Opportunity where id in:setOfopptyId ];        
        }

        if(opptyList.size()>0){
                for(Opportunity opp:opptyList){
                    if(opp.Review_Check__c == false && opp.BackendMACDType__c !=UtilityConstant.COSCHANGE && opp.InterfaceChanged__c == false){
                        opp.Review_Check__c = true;
                        opp.MACD_RDS_Review_Completed_Status__c = UtilityConstant.SUCCESS;
                        opp.MACD_RDS_Review_Complete_LastTimeStamp__c = System.now();
                        opptyListToupdate.add(opp);

                    }
                    
                }
         }
         if(opptyListToupdate.size()>0){
                try{
                    update opptyListToupdate;
                }Catch(Exception e){
                    e.getMessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            
         }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
 
    }
    
    // This method is to populate the Selected Opportunity field when a new Deal Hash is received //
/* 
 Name: updateSelectedOpptyonDH
 Description: 
 */ 
    public void updateSelectedOpptyonDH(SObject[] newObjects){
     try{   
        List<Deal_Hash__c> newDealHash = newObjects;  
        List<Deal_Hash__c> dealHashUpdate = new List<Deal_Hash__c>();       
            for(Deal_Hash__c dnew  :newDealHash){
                    dnew.Selected_Opportunity__c = dnew.Opportunity__c;
                    updatedDeals.add(dnew);
            }
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    
    }
    //This method is to populate the timestamp ,error message and status on provisioning status bar on Opportunity
/* 
 Name: updateProvisoningStatus
 Description: 
 */ 
    public void updateProvisoningStatus(SObject[] oldObjects,SObject[] updatedObjects){
      try{  
         List<Deal_Hash__c> oldDealHash = oldObjects;
         List<Deal_Hash__c> newDealHash = updatedObjects;     
         List<Opportunity> opptyList = new List<Opportunity>();
         Set<Id> opptySet = new Set<Id>();
         List<Opportunity> opptyListToUpdate = new List<Opportunity>();
         for(Deal_Hash__c dnew  :newDealHash){
            for(Deal_Hash__c dold:oldDealHash ){
                 if(dnew.Id == dold.Id && dnew.MACD_Update_Status__c != dold.MACD_Update_Status__c && dnew.RDS_Version_Select__c != UtilityConstant.ALL && dnew.RDS_Version_Select__c != SpecialCharacterConstant.CONCAT && dnew.RDS_Version_Select__c != UtilityConstant.SIVARConst_1){
                     opptySet.add(dnew.Selected_Opportunity__c); 
                 } 
             }
          }
          if(opptySet.size()>0){
              opptyList = [Select id,RDS_Version__c,MACD_Update_Deal_hash_Status__c,MACD_Update_Deal_hash_Last_TimeStamp__c,MACD_Update_Deal_hash_Error_Msg__c,MACD_Update_Deal_hash__c from Opportunity where id in:opptySet];
                 
                 for(Opportunity o: opptyList){
                     for(Deal_Hash__c deal:newDealHash){
                         if(o.RDS_Version__c == Decimal.valueof(deal.RDS_Version_Select__c)&& o.Id == deal.Selected_Opportunity__c){
                             o.MACD_Update_Deal_hash_Status__c = deal.MACD_Update_Status__c;
                             o.MACD_Update_Deal_hash_Last_TimeStamp__c = system.now();
                             o.MACD_Update_Deal_hash_Error_Msg__c = deal.MACD_Update_Error_Code__c;
                             opptyListToUpdate.add(o);
                         }            
                     }
                 }
             }
             if(opptyListToUpdate.size()>0){
                try{
                    update opptyListToUpdate;
                }Catch(Exception e){
                    e.getMessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            
         }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
     
    }
   
 // Requirement as per US423172--InFlight Cancel � New objects 
/*Name:  UpdateCurrentVersionOnPremise
 * Description:set Premise->current_version to false when Premise->site_status is set to �CANCELLED" and RDS deal Hash->RDS Status =  "Deal Hash Update - Cancel API Successful"
 */
 public void updateCurrentVersionOnPremise(SObject[] updatedObjects,SObject[] oldObjects)
 {
    try{
     List<Deal_Hash__c> oldDealHash = oldObjects ;
     List<Deal_Hash__c> newDealHash = updatedObjects;
     Set<Id> rDSDealHashIDSet=new Set<Id>();
     List<RDS_Premise_Details__c> premiseRecords=new List<RDS_Premise_Details__c>();
     Map<Id,RDS_Premise_Details__c> premiseMap=new  Map<Id,RDS_Premise_Details__c>();
     for(Integer i=0;i<newDealHash.size();i++)
     {
        
         if(newDealHash[i].RDS_object_status__c!=oldDealHash[i].RDS_object_status__c  && newDealHash[i].RDS_object_status__c == SIConstants.DEAL_HASH_UPDATE_CANCEL_API_SUCCESSFUL)
         {
             RDSDealHashIDSet.add(newDealHash[i].Id);
           
         }
         if(!RDSDealHashIDSet.isempty()|| RDSDealHashIDSet.size()>0)
         {
           PremiseRecords=[select Id,Site_Status__c,Current_Version__c,DealHash__c from RDS_Premise_Details__c  WHERE DealHash__c IN:RDSDealHashIDSet AND Current_Version__c=true AND Site_Status__c=:SIConstants.RDS_PREMISE_SITE_STATUS_CANCELLED];  
            
         }
         if(PremiseRecords.size()>0 && PremiseRecords!=NULL)
         {
             for(RDS_Premise_Details__c rp:PremiseRecords)
             {
                 for(Deal_Hash__c dh:newDealHash)
                 {
                     if(rp.DealHash__c==dh.Id && rp.Site_Status__c==SIConstants.RDS_PREMISE_SITE_STATUS_CANCELLED && rp.Current_Version__c==true && dh.RDS_object_status__c==SIConstants.DEAL_HASH_UPDATE_CANCEL_API_SUCCESSFUL)
                     {
                         rp.Current_Version__c=false;
                         PremiseMap.put(rp.Id,rp);
                        
                     }
                 }
             }
         }
         if(PremiseMap.size()>0)
         {
             try
             {
                 update PremiseMap.values();
             }
             Catch(Exception e)
             {
                 ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
             }
         }
     }  
    }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
     }    
   }
public void sendOutEmailOnSiteStatusActive(SObject[] oldObjects, Map<Id, SObject>  newObjectsMap){
        
        List<Deal_Hash__c> oldDealHash = oldObjects;
        Map<Id, SObject> newdhMap = new Map<Id, Deal_Hash__c>();
        newdhMap = newObjectsMap;
        List<Deal_Hash__c> dhList = new List<Deal_Hash__c>();
        List<Apttus_Proposal__Proposal__c> quoteObj= New List<Apttus_Proposal__Proposal__c>(); 
        
        for(Deal_Hash__c dold : oldDealHash){
           Deal_Hash__c  dhobj = (Deal_Hash__c)newdhMap.get(dold.id);
            if(dold.PremiseDetailActiveCount__c != dhobj.PremiseDetailActiveCount__c && dhobj.CountOfRdsPremise__c == dhobj.PremiseDetailActiveCount__c){
                dhList.add(dhobj);
            }
        }
        if(!dhList.isEmpty()){  
            Id quoteId = dhList[0].RenewedQuote__c;
            quoteObj = [select Id,Name,Apttus_Proposal__Account__r.Id,Owner.Email from Apttus_Proposal__Proposal__c WHERE id =:quoteId];
            Contact con = [SELECT id,accountId, Name from Contact WHERE accountId =: quoteObj[0].Apttus_Proposal__Account__r.Id and Email = :quoteObj[0].Owner.Email];
            list<OrgWideEmailAddress> owea = new list<OrgWideEmailAddress>();
            owea = [select Id,DisplayName,Address  from OrgWideEmailAddress where Address='partnerexchangesupport@amcustomercare.att-mail.com' Limit 1];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            EmailTemplate temp = [select Id,Name from EmailTemplate where Name = 'Billing Backend Completion Email Template'];
            if (owea != null && owea.size() > 0){
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }  
            mail.setTemplateId(temp.id);
            mail.settargetObjectId(con.id);
            mail.saveAsActivity = false;
            mail.setWhatId(quoteId); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }   
}