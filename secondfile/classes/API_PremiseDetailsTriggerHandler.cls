/*
     Component Name :API_PremiseDetailsTriggerHandler 
     Requirement/User Story Number :US238470 
     Requirement Description:Update Derived Fields from Multiple Objects to Premise Details on Record Creation
     Component Author:Accenture IDC
     Created Date:5th May 2014 
     Version:1.0
     Last Modified By: Accenture IDC
    */
public with sharing class API_PremiseDetailsTriggerHandler extends SITriggerOperations.SITriggerImpl{
   
/* 
 Name: onAfterInsert
 Description: 
 */ 
    public override boolean onAfterInsert (SObject[] newObjects){
      try{           
        List<RDS_Premise_Details__c> prsList = newObjects;
        List<RDS_Premise_Details__c> prmsList = new List<RDS_Premise_Details__c>();
            for(RDS_Premise_Details__c Pr : prsList){
                if(Pr.MACD_Type__c!=SIConstants.MACDTYPED && Pr.MACD_Type__c!=SIConstants.MACDTYPEC){
                PrmsList.add(Pr);
                }
            }
            if(PrmsList.size()>0){
                try{
                    updateMACDAddOpptyRDSReceived(newObjects);    
                    insertCompetitveDiscountRecords(newObjects); 
                    insertBillingRelatedElementsBasedOnProductPricing(newObjects);            
                } catch (exception e){
                    e.getMessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            }
        return true;
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }
    } 
    
/* 
 Name: onBeforeInsert
 Description: 
 */ 
    public override boolean onBeforeInsert (SObject[] newObjects){
       try{
        //updateclassofservice(newObjects); 
        List<RDS_Premise_Details__c> prsList = newObjects;
        List<RDS_Premise_Details__c> prmsList = new List<RDS_Premise_Details__c>();
        Set<Id> premId= New Set<ID>();
            for(RDS_Premise_Details__c Pr : prsList){
                if(Pr.MACD_Type__c!=SIConstants.MACDTYPED && Pr.MACD_Type__c!=SIConstants.MACDTYPEC){
                    PrmsList.add(Pr);
                }
                if(!Pr.IsAtom__c){
                PremId.add(pr.Id);
                }
            }
            if(PrmsList.size()>0){
                try{    
                    defvalUpdateonUSOVLANIndicator(newObjects); 
                    getBANBasedOnLatafromMappingTable(newObjects);
                    if(PremId.size()>0){
                    OtherDerivationsCOS(newObjects);
                    }
                    OtherDerivations(newObjects);
                    macdAddUpdates(newObjects);
                } catch (exception e){
                    e.getMessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            }
        return true;
       }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }
    }
        
/* 
 Name: onBeforeUpdate
 Description: 
 */ 
    public override boolean onBeforeUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap){
        
        try{
          updateCurrentVersionOnDisconnect(oldObjects,updatedObjects);
         
           //OtherDerivations(updatedObjects);
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
        List<RDS_Premise_Details__c> oldPrsList = oldObjects;
        List<RDS_Premise_Details__c> prsList = updatedObjects;
        List<RDS_Premise_Details__c> prmsList = new List<RDS_Premise_Details__c>();
        List<RDS_Premise_Details__c> prmsRenewContractList = new List<RDS_Premise_Details__c>();
        map<id,RDS_Premise_Details__c> createRenewalContractITSMap = new map<id, RDS_Premise_Details__c>();
        map<id,RDS_Premise_Details__c> updateRenewalContractPremiseMap = new map<id, RDS_Premise_Details__c>();
        
        try{
        ChangeCircuitstatusVLANstatus(oldObjects,updatedObjects);
         }catch (exception p){
                    p.getMessage();
                    ATTException.logException( p.getTypeName(), ATTException.constructExceptionMessageString(p));
                }
        
            for(RDS_Premise_Details__c Pr : prsList){
                if(Pr.MACD_Type__c!=null && Pr.MACD_Type__c!=SIConstants.MACDTYPED && Pr.MACD_Type__c!=SIConstants.MACDTYPEC){
                PrmsList.add(Pr);
                }
            }
            
            for(RDS_Premise_Details__c oldPr : oldPrsList){
                for(RDS_Premise_Details__c newPr : prsList){
                    if( newPr.Id == oldPr.Id && (newPr.Renewal_Contract__c == true) && !String.isBlank(newPr.Notification_Status__c) && (newPr.Notification_Status__c != oldPr.Notification_Status__c) && newPr.Notification_Status__c == UtilityConstant.UPDATE_FAILED){                    
                        if((newPr.Deal_Hash_Premise_Notify_Count__c + 1) == 1){
                            if(!createRenewalContractITSMap.containsKey(newPr.id)){
                                createRenewalContractITSMap.put(newPr.id,newPr);
                            }
                        }
                    }
                    if( newPr.Id == oldPr.Id  && (newPr.Site_Status__c != oldPr.Site_Status__c) && (newPr.Change_Flow_Type__c == RenewConstant.Renewal) ){
                        updateRenewalContractPremiseMap.put(newPr.id,newPr);
                    }
                }
            }
            
             //Contract Renewal ITS Support Ticket Creation
            if(!createRenewalContractITSMap.isEmpty() && SIConstants.allowIDHITSTicketCreation == true){
                RDSExcelExceptionHandling rdsExcelExceptionHandlingObj = new RDSExcelExceptionHandling();
                rdsExcelExceptionHandlingObj.createContractRenewalIDHITSTicket(createRenewalContractITSMap);
                SIConstants.allowIDHITSTicketCreation = false;
            }
            if(!updateRenewalContractPremiseMap.isEmpty()){
                updateRenewalContractPremise(updateRenewalContractPremiseMap);
            }
            
            if(PrmsList.size()>0){
                try{
                  updateQuoteApprovalStage(oldObjects,updatedObjects);
                  updateGrid(oldObjects,updatedObjects);
                  createMACDOnDisconnect(oldObjects,updatedObjects);
                  updateChargeElementIdOnBRE(oldObjects,updatedObjects);
                } catch (exception e){
                    e.getMessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            } else {
                  try{
                      updateChargeElementIdOnBRE(oldObjects,updatedObjects);
                      createMACDOnDisconnect(oldObjects,updatedObjects);
                      updateQuoteApprovalStage(oldObjects,updatedObjects);
                  } catch (exception e){
                    e.getMessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }            
            }
      //  sendOutEmailToSpUser(oldObjects,updatedObjects);
        if(Test.isRunningTest()){
            //sendOutEmailToSpUser(oldObjects,updatedObjects);
          }
        return true;
    } 
    
    // to send out email to sp user for port speed access change 
/* 
 Name: sendOutEmailToSpUser
 Description: 
 */ 
    public void sendOutEmailToSpUser(SObject[] oldObjects,SObject[] updatedObjects){
      try{  
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List <Opportunity> listOppty = new list<Opportunity>();
        List <Deal_Hash__c> listOfDealHash =new List<Deal_Hash__c>();
        List <RDS_Premise_Details__c> selectedPremise = new List<RDS_Premise_Details__c>();
        Map <RDS_Premise_Details__c,Opportunity> mapPremiseEmail= new  Map <RDS_Premise_Details__c,Opportunity>();
        Set<ID> dealHashId = new Set<ID>();
        Set<String> opptyId = new Set<String>();
        List<RDS_Premise_Details__c> listUpdatedPremise = new List<RDS_Premise_Details__c>();
        listUpdatedPremise = updatedObjects;
        List<RDS_Premise_Details__c> listOldPremise = new List<RDS_Premise_Details__c>();
        listOldPremise = oldObjects;
        
        for( RDS_Premise_Details__c premiseOld : listOldPremise ){
            
            for( RDS_Premise_Details__c premiseNew : listUpdatedPremise ){                             
                
                if( premiseOld.Site_Status__c == UtilityConstant.PENDINGSPEED_CHANGE && premiseNew.Site_Status__c == UtilityConstant.ACTIVE){
                   dealHashId.add(premiseNew.DealHash__c);
                   SelectedPremise.add(premiseNew);
                }
     
            }
        }
        listOfDealHash = [SELECT Id, Selected_Opportunity__c FROM Deal_Hash__c WHERE id IN:dealHashId];
        
        for(Deal_Hash__c selectedDeal :   listOfDealHash){
            opptyId.add(selectedDeal.Selected_Opportunity__c);
        }
        listOppty = [SELECT id, createdBy.Id, createdBy.email FROM Opportunity WHERE id IN:opptyId]; 
        for(Opportunity opty : listOppty){
            for(Deal_Hash__c dealhash : listOfDealHash){
                for(RDS_Premise_Details__c premisedata : SelectedPremise){
                         
                 
                        mapPremiseEmail.put(premisedata,opty);
                   
                }
            }
        }
        
        EmailTemplate templateobj = new EmailTemplate ();
        templateobj = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Port_Access_Speed_Change_Email']; 
        
            for (RDS_Premise_Details__c primiseobj : mapPremiseEmail.keySet()) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(mapPremiseEmail.get(primiseobj).createdBy.Email);
                mail.setToAddresses(sendTo);
                mail.setOrgWideEmailAddressId(UtilityConstant.SIVARConst_0D260000000GOJT);
                mail.setTemplateId(templateobj.Id);
          
                mail.setTargetObjectId(mapPremiseEmail.get(primiseobj).createdBy.Id);
              
                mail.saveAsActivity = false;
                mails.add(mail);
            }
  
        if(!Test.isRunningTest()){
            Messaging.sendEmail(mails);
        }
        
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }
    
//This method is for inserting records of Competitive Discount after inserting the RDS Premise Details records

/* 
 Name: insertCompetitveDiscountRecords
 Description: 
 */ 
    public void insertCompetitveDiscountRecords(SObject[] newObjects){
        try{  
            List<RDS_Premise_Details__c> premiseDetailsList = newObjects;
            Set<String> premiseNumberList=new Set<String>();
            Map<Id, Product_Pricing__c> productPricingMap = new Map<Id, Product_Pricing__c>();
            List <RDS_Competitive_Discount__c> compDiscListToInsert = new List<RDS_Competitive_Discount__c>();
            List<Product_Pricing__c> prodPriceList = new List<Product_Pricing__c>();
            set<Id>  dealHashId = new Set<ID>();
            string deal15Id = SpecialCharacterConstant.CONCAT;
            Double discountedPrice;
            
            for(RDS_Premise_Details__c preD :premiseDetailsList ){
                premiseNumberList.add(preD.Premise_Number__c);
                dealHashId.add(preD.DealHash__c);
            }
            
            if(premiseNumberList.size()>0){
                prodPriceList = [Select Id, RecordType.Name,Wireline_Promo_Discount_SP_Order__c,discount_price__c,list_price__c, SP_Product__r.Deal__r.RDS_Deal_Hash__c,EBM_Competitive_Discount_Plan_ID__c,SP_Product__r.Competitive_Pricing_Status__c,SP_Product__r.Site_ID__c,SP_Discount_Percentage__c, Deal_Id__c, Special_Pricing_Percentage__c,Net_Price_with_SP_Order_Discounts__c,discounted_price__c,type__c From Product_Pricing__c Where SP_Product__r.Deal__r.RDS_Deal_Hash__c IN:dealHashId and SP_Product__r.Site_ID__c IN :premiseNumberList];
            } 
            if(prodPriceList.size()>0){
                for(RDS_Premise_Details__c preDetails :premiseDetailsList ){
                    for(Product_Pricing__c prodPrice :prodPriceList){
                        discountedPrice = 0.00;
                        if(prodPrice.Deal_Id__c != null && prodPrice.Deal_Id__c != SpecialCharacterConstant.CONCAT){
                            string dealID = prodPrice.Deal_Id__c;
                            Deal15Id = DealID.substring(0,15);
                        } 
                        if(preDetails.Premise_Number__c == prodPrice.SP_Product__r.Site_ID__c && prodPrice.EBM_Competitive_Discount_Plan_ID__c ==null && prodPrice.SP_Discount_Percentage__c ==null && prodPrice.SP_Product__r.Competitive_Pricing_Status__c !=UtilityConstant.SPECIALPRICING_APPROVED ){ 
                            discountedPrice = (prodPrice.Net_Price_with_SP_Order_Discounts__c != null && prodPrice.Net_Price_with_SP_Order_Discounts__c != 0.00) ? prodPrice.Net_Price_with_SP_Order_Discounts__c : ((prodPrice.discounted_price__c != null && prodPrice.discounted_price__c != 0.00) ? prodPrice.discounted_price__c : prodPrice.list_price__c);
                            if(prodPrice.list_price__c!= 0.00 && (discountedPrice < prodPrice.list_price__c) && prodPrice.type__c != 'NRC'){
                                compDiscListToInsert.add(new RDS_Competitive_Discount__c(Competitive_Discount_Type__c = prodPrice.RecordType.Name, PremiseDetails__c = preDetails.Id, Competitive_Discount_Plan_Id__c = prodPrice.EBM_Competitive_Discount_Plan_ID__c,Competitive_Discount_Amount__c=(((prodPrice.list_price__c - discountedPrice)/prodPrice.list_price__c)*100).setScale(2)));
                            }
                        }                        
                        else if(preDetails.Premise_Number__c == prodPrice.SP_Product__r.Site_ID__c && prodPrice.EBM_Competitive_Discount_Plan_ID__c !=null && prodPrice.SP_Discount_Percentage__c !=null && prodPrice.SP_Product__r.Competitive_Pricing_Status__c ==UtilityConstant.SPECIALPRICING_APPROVED && prodPrice.type__c != 'NRC'){
                            compDiscListToInsert.add(new RDS_Competitive_Discount__c(Competitive_Discount_Type__c = prodPrice.RecordType.Name, PremiseDetails__c = preDetails.Id, Competitive_Discount_Plan_Id__c = prodPrice.EBM_Competitive_Discount_Plan_ID__c, Competitive_Discount_Amount__c = ProdPrice.Special_Pricing_Percentage__c));
                        }
                    }
                } 
            }
            if(compDiscListToInsert.size()>0){            
                try{
                    insert compDiscListToInsert; 
                }
            
                catch(DMLException ex){
                    ex.getmessage();
                    ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
                }
            }
        }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }       
    } 
    
 /*
  This method is going to create billing related elements records on every insert/update on Premise details looking at
  each SP Product associated to the Opportunity linked with Premise detail record.
  */
  
/* 
 Name: insertBillingRelatedElementsBasedOnProductPricing
 Description: 
 */ 
    public void insertBillingRelatedElementsBasedOnProductPricing(SObject[] newObjects){
      try{  
        Set<Id> opptyIdSet = new Set<Id>(); 
        Map<string,RDS_Premise_Details__c> premiseSite = new Map<string,RDS_Premise_Details__c>();    
        List<RDS_BillingRelatedElements__c> billingRecordsToBeInserted = new List<RDS_BillingRelatedElements__c>(); 
        Map<Id,List<Id>> premiseOpptyMap = new Map<Id,List<Id>>(); 
        List<RDS_Premise_Details__c> listOfPremiseDetails = newObjects; 
        List<Opportunity> opportunityList= New List<Opportunity>();
        set<Id>  dealHashId = new Set<ID>();
        Set<String> spIdSet = new Set<String>();
       
        for(RDS_Premise_Details__c pd: listOfPremiseDetails){
            premiseSite.put(pd.Premise_Number__c,pd);
            dealHashId.add(pd.DealHash__c);
        }
        
      
        Boolean isATOMDeal = true;
        
        if(listOfPremiseDetails != null && listOfPremiseDetails.size() > 0 ){
            if( listOfPremiseDetails[0].Deal_Name__c.substring(0,1) == UtilityConstant.O1 ){
            
                isATOMDeal = false;
            }else{
                
                isATOMDeal = true;
            }
        }
        if(dealHashId!=null ){
        opportunityList=[Select id from Opportunity where RDS_Deal_Hash__c IN: dealHashId Order By CreatedDate Desc Limit 1 ];
        if(opportunityList.size()>0){
        List<SPProduct__c> listSpProduct = new List<SPProduct__c>();
        listSpProduct = [Select Id, Deal__c, Site_ID__c, RDS_Version__c from SPProduct__c where Site_ID__c =: premiseSite.keyset() AND RDS_Version__c =: premiseSite.values().RDS_Version__c AND Deal__r.ATOM_Deal__c =: isATOMDeal  and Deal__c=:opportunityList[0].Id];
        
        if(premiseSite.size()>0){
            for(SPProduct__c sppr : listSpProduct){
                for(RDS_Premise_Details__c pdd: listOfPremiseDetails){
                    if(pdd.Premise_Number__c == sppr.Site_ID__c && pdd.RDS_Version__c == sppr.RDS_Version__c){
                        spIdSet.add(sppr.Id);
                        opptyIdSet.add(sppr.Deal__c);
                            if(premiseOpptyMap.containsKey(sppr.Deal__c)){  
                                premiseOpptyMap.get(sppr.Deal__c).add(pdd.Id);            
                            } else{
                                premiseOpptyMap.put(sppr.Deal__c,new List<Id>{pdd.Id});
                            }
                    }
                }
            }
        }
    
              
        if(opptyIdSet.size()>0){
            List<Product_Pricing__c> listOfSpProduct = [Select id,Deal_Id__c,BEID__c,RecordType.Name,Product_Detail__c from Product_Pricing__c where  SP_Product__r.Deal__r.Id  in: opptyIdSet and SP_Site_Id__c=:premiseSite.keyset() and SP_Product__c =: spIdSet] ;
          
            for(Id str: premiseOpptyMap.keySet()){
                for(Id singlePremise: premiseOpptyMap.get(str) ){
                    for(Product_Pricing__c pp: listOfSpProduct ){
                        if(pp.RecordType.Name ==SIConstants.DISCOUNT_TYPE_PORT || pp.RecordType.Name ==SIConstants.DISCOUNT_TYPE_FEATURE){
                            billingRecordsToBeInserted.add(new RDS_BillingRelatedElements__c(Charge_Element_ID__c=pp.BEID__c,ChargeType__c=pp.RecordType.Name,Product_Detail__c=pp.Product_Detail__c,Currency_Code__c=UtilityConstant.USD,PremiseDetails__c = singlePremise) );  
                        }                 
                    }
                }
            }
        } 
         
        if(billingRecordsToBeInserted.size()>0){
            try{
                insert billingRecordsToBeInserted;
            }catch(Exception ex){
                ex.getMessage();
                ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            }
        }
       }
      } 
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }
  
/* This method will fetch BAN from LATA BAN Mapping Table by matching BAN and State on Premise to BAN and State in LATA BAN Mapping Table */
  
/* 
 Name: getBANBasedOnLatafromMappingTable
 Description: 
 */ 

    public void getBANBasedOnLatafromMappingTable(SObject[] newObjects){
      try{   
        List<RDS_Premise_Details__c> listOfPremiseDetails = newObjects; 
        List<LATA_BAN_Mapping__c> listOfLataBan= new List<LATA_BAN_Mapping__c>();
        List<RDS_Premise_Details__c> listOfPremiseToUpdate = new List<RDS_Premise_Details__c>(); 
        Set<Id> premiseIdset = new Set<Id>();
        Set<String> lataSet = new Set <String>();
        Set<String> lateState = new Set<String>();
    
        listOfLataBan = [Select id,Ban__c,Lata__c,Region__c,State__c from LATA_BAN_Mapping__c];
    
        if(listOfLataBan.size()>0){
            for(RDS_Premise_Details__c premise :listOfPremiseDetails){
                for(LATA_BAN_Mapping__c lata:listOfLataBan){
                    if(premise.LATA__c != null && premise.Service_Type__c==UtilityConstant.ASE && premise.Lata__c == lata.Lata__c){    
                        lataSet.add(premise.LATA__c);
                        lateState.add(premise.Premise_State__c);
                    }
                }
            }
        }
        
        List<LATA_BAN_Mapping__c> newlistOfLataBan= new List<LATA_BAN_Mapping__c>();
        if(lataSet.size()>0){
            newlistOfLataBan = [Select id,Ban__c,Lata__c,Region__c,State__c from LATA_BAN_Mapping__c where Lata__c IN : lataSet];
        }
    
        if(newlistOfLataBan.size() == 1 ){
            for(RDS_Premise_Details__c premise :listOfPremiseDetails){
                for(LATA_BAN_Mapping__c lata:newlistOfLataBan){            
                    premise.Ban__c = lata.Ban__c;
                    listOfPremiseToUpdate.add(premise);            
                } 
            }
        } else if(newlistOfLataBan.size() > 1){
            for(RDS_Premise_Details__c premise :listOfPremiseDetails){
                for(LATA_BAN_Mapping__c lata:newlistOfLataBan){
                    if(premise.Premise_State__c == lata.State__c ){
                        premise.Ban__c = lata.Ban__c;                   
                        listOfPremiseToUpdate.add(premise);
                    }                   
                } 
            }
        } else {
            for(RDS_Premise_Details__c premise :listOfPremiseDetails){
                for(LATA_BAN_Mapping__c lata:listOfLataBan){
                    if(premise.Premise_State__c == lata.State__c && premise.Lata__c != lata.Lata__c && (lata.Lata__c ==SpecialCharacterConstant.CONCAT || lata.Lata__c ==null) && premise.Service_Type__c==UtilityConstant.ASE){
                        premise.Ban__c = lata.Ban__c;                  
                        listOfPremiseToUpdate.add(premise);             
                    } 
                }
            }
        }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    } 
    
//Other Derivations-For COS

/* 
 Name: OtherDerivationsCOS
 Description: 
 */ 
    public void otherDerivationsCOS(SObject[] newObjects){
      try{  
        List<RDS_Premise_Details__c> premiseDetailsList = newObjects;
        List<RDS_Premise_Details__c> listToUpdate = new List<RDS_Premise_Details__c>();
        List<Product_Pricing__c> productPricingList= New List<Product_Pricing__c>();
        Set<Id> dealHashId= New Set<Id>();
        List<Opportunity> opptyList= new List<Opportunity>();
        ID rtypeId = SIRecordTypeHelper.GetRecordTypeIdByDevName('Product_Pricing__c','Feature');  
        List<SPProduct__c> spProductList= New List<SPProduct__c>();
        Set<Id> spSetId= New Set<Id>();
        
        for(RDS_Premise_Details__c premise:premiseDetailsList){        
            premise.Access_Provider_Project_Number__c = premise.Customer_Project_Number__c;
            if(premise.Service_Type__c==UtilityConstant.ASE){
                premise.Number_of_Locations__c=UtilityConstant.SIVARConst_1;
                listToUpdate.add(premise); 
            } else{
                premise.Number_of_Locations__c=UtilityConstant.SIVARConst_002;
                if(!premise.Class_of_Service__c){
                dealHashID.add(premise.DealHash__c);
                }
                listToUpdate.add(premise); 
            }
        }
        if(dealHashID.size()>0){
        opptyList=[Select Id from Opportunity where RDS_Deal_Hash__c=:dealHashID and ATOM_Deal__c=False order By createdDate DESC LIMIT 1];
        
        if(opptyList.size()>0){
        for(SPProduct__c spProduct:[Select Id from SPProduct__c where Deal__c=:opptyList[0].id]){
          spSetId.add(spProduct.id);
        }
        productPricingList = [Select Id,SP_Site_Id__c  from Product_Pricing__c where Deal_Id__c=: opptyList[0].Id and RecordTypeID=:rtypeId and SP_Product__c IN:spSetId and Product_Detail__c=: UtilityConstant.PORTCOS];
        if(productPricingList.size()>0){
        for(RDS_Premise_Details__c premise:premiseDetailsList){
           for(Product_Pricing__c ppRec:productPricingList ){
             if(ppRec.SP_Site_Id__c == premise.Premise_Number__c){
                if(!premise.Class_of_Service__c){
                premise.Class_of_Service__c = True;
                }
            
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
    
    
    
    //Other Derivations-For Access Provider Project Number & Number of Locations based on Service Type

/* 
 Name: OtherDerivations
 Description: 
 */ 
    public void otherDerivations(SObject[] newObjects){
     try{   
        List<RDS_Premise_Details__c> premiseDetailsList = newObjects;
        List<RDS_Premise_Details__c> listToUpdate = new List<RDS_Premise_Details__c>();
        List<Product_Pricing__c> productPricingList= New List<Product_Pricing__c>();
        Set<Id> dealHashId= New Set<Id>();
        List<Opportunity> opptyList= new List<Opportunity>();
        ID rtypeId = SIRecordTypeHelper.GetRecordTypeIdByDevName('Product_Pricing__c','Feature');  
        List<SPProduct__c> spProductList= New List<SPProduct__c>();
        Set<Id> spSetId= New Set<Id>();
        
        for(RDS_Premise_Details__c premise:premiseDetailsList){        
            premise.Access_Provider_Project_Number__c = premise.Customer_Project_Number__c;
            if(premise.Service_Type__c==UtilityConstant.ASE){
                premise.Number_of_Locations__c=UtilityConstant.SIVARConst_1;
                listToUpdate.add(premise); 
            } else{
                premise.Number_of_Locations__c=UtilityConstant.SIVARConst_002;
               }
              listToUpdate.add(premise); 
            }
        }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }   
       
       
// To update GRID Premise ID on SP Product based on GRID Premise ID on Premise
    
/* 
 Name: updateGrid
 Description: 
 */ 
    public void updateGrid(SObject[] oldObjects,SObject[] updatedObjects){
      try{  
        List<RDS_Premise_Details__c> rdpOList = oldObjects; 
        List<RDS_Premise_Details__c> rdpUList = updatedObjects;
        List<SPProduct__c> updateSpList = new List<SPProduct__c>();
        Map<String,SPProduct__c> spprodMap = new Map<String,SPProduct__c>();
        Map<String,RDS_Premise_Details__c> rdpMap = new Map<String,RDS_Premise_Details__c>();
        Set<String> oppIdSet = new Set<String>();
        Boolean isMacdAdd = false;
        
        for(RDS_Premise_Details__c rdpo : rdpOList){
            for(RDS_Premise_Details__c rdpu : rdpUList){
                if(rdpo.Premise_Number__c == rdpu.Premise_Number__c && (rdpu.Premise_Number__c!= SpecialCharacterConstant.CONCAT || rdpu.Premise_Number__c!= null)&& (rdpu.GRID_Premise_ID__c!= SpecialCharacterConstant.CONCAT || rdpu.GRID_Premise_ID__c!= null) && rdpu.Is_Deal_Hash_Call_Success__c == TRUE){
                    if(rdpu.MACD_Type__c == SpecialCharacterConstant.CONCAT || rdpu.MACD_Type__c == null){
                        oppIdSet.add(rdpu.OpptyID__c); 
                    } else if (rdpu.MACD_Type__c == UtilityConstant.A){
                        isMacdAdd = true;
                    }
                    rdpMap.put(rdpu.Premise_Number__c,rdpu);
                }
            }
        }
         
        if(oppIdSet.size()>0){            
            List<SPProduct__c> spList = [Select Id,Site_ID__c,Oppty_Record_Type__c,Deal__c,GRID_Premise_ID__c from SPProduct__c WHERE Deal__c IN: oppIdSet];
            if(spList.size()>0){
                for(SPProduct__c sp : spList){
                    if(sp.GRID_Premise_ID__c == SpecialCharacterConstant.CONCAT || sp.GRID_Premise_ID__c == null){
                        spprodMap.put(sp.Site_ID__c,sp);
                    }
                }   
            }
        }
        
        if(isMacdAdd){
            List<SPProduct__c> spAddList = [Select Id,Site_ID__c,Oppty_Record_Type__c,Deal__c,GRID_Premise_ID__c,MACD_Type__c from SPProduct__c WHERE Site_ID__c IN: rdpMap.keySet() AND MACD_Type__c =: UtilityConstant.A ];
            if(spAddList.size()>0){
                for(SPProduct__c sp : spAddList){
                    if(sp.GRID_Premise_ID__c == SpecialCharacterConstant.CONCAT || sp.GRID_Premise_ID__c == null){
                        spprodMap.put(sp.Site_ID__c,sp);
                    }
                }   
            }
        }
        
        if(spprodMap.size()>0 && rdpMap.size()>0){
            for(SPProduct__c s: spprodMap.values()){
                s.GRID_Premise_ID__c = rdpMap.get(s.Site_Id__c).GRID_Premise_ID__c;
                updateSpList.add(s);   
            }    
        }
        
        if(updateSpList.size()>0){
            try{
                update updateSpList;
            } catch(DMLException e){
                e.getmessage();
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }   
        }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }
    
/* Method to update Current Version field on Premise when MACD disconnect is performed */  
/* 
 Name: updateCurrentVersionOnDisconnect
 Description: 
 */ 
    public void updateCurrentVersionOnDisconnect(SObject[] oldObjects, SObject[] updatedObjects){
     try{   
        List<RDS_Premise_Details__c> newPremList = updatedObjects;
        List<RDS_Premise_Details__c> oldPremList = oldObjects;
        List<RDS_Premise_Details__c> updtPremList = new List<RDS_Premise_Details__c>(); // List of disconnected Premise to be updated
        Map<String,RDS_Premise_Details__c> archMap = new Map<String,RDS_Premise_Details__c>();
              
        for(RDS_Premise_Details__c oldp: oldPremList){
            for(RDS_Premise_Details__c p: newPremList){

                if((oldp.Id == p.Id) && (oldp.Disconnect_Type__c!= p.Disconnect_Type__c) && (p.Disconnect_Type__c == UtilityConstant.HARDDISCONNECT || p.Disconnect_Type__c == UtilityConstant.SOFTDISCONNECT|| p.Disconnect_Type__c == UtilityConstant.SOFTCANCEL )){
                    p.Current_Version__c = False;
                    archMap.put(p.Id,p); // Map of Premise Id and Premise on which Disconnect is being performed
                }
                
                
                if ( (oldp.Id == p.Id) && (oldp.Push_Notification_Site_Status__c != p.Push_Notification_Site_Status__c ) && (p.Push_Notification_Site_Status__c !=SpecialCharacterConstant.CONCAT || p.Push_Notification_Site_Status__c !=null) && oldp.Site_Status__c !=UtilityConstant.LOCKED ){
                      p.Site_Status__c = p.Push_Notification_Site_Status__c ;
                      p.Push_Notification_Site_Status__c=SpecialCharacterConstant.CONCAT;
                }
                if ( (oldp.Id == p.Id) && (oldp.Site_Status__c != p.Site_Status__c) && (p.Site_Status__c==UtilityConstant.LOCKED) && ( oldp.Site_Status__c != SpecialCharacterConstant.CONCAT || oldp.Site_Status__c != null)){
                      p.Push_Notification_Site_Status__c = oldp.Site_Status__c;
                }
                else{
                }
                if ( (oldp.Id == p.Id) && (oldp.Site_Status__c != p.Site_Status__c) && p.Site_Status__c==UtilityConstant.UNLOCKED && (p.Push_Notification_Site_Status__c != SpecialCharacterConstant.CONCAT || p.Push_Notification_Site_Status__c != null)){
                      p.Site_Status__c = p.Push_Notification_Site_Status__c ;
                      p.Push_Notification_Site_Status__c = SpecialCharacterConstant.CONCAT;
                }
               
            }
        }
        
        if(archMap.size()>0){
            for(RDS_Premise_Details__c upPre : archMap.values()){
                upPre.Current_Version__c = False;
                updtPremList.add(upPre);
            }   
        }
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }
    
/* Method to create MACD Opportunity + Related objects when disconnect is performed */   
/* 
 Name: createMACDOnDisconnect
 Description: 
 */ 
    public void createMACDOnDisconnect(SObject[] oldObjects, SObject[] updatedObjects){
     try{   
        List<RDS_Premise_Details__c> oldPremiseList = oldObjects;
        List<RDS_Premise_Details__c> updtPremiseList = updatedObjects;
        Map<String,RDS_Premise_Details__c> disconnectMap = new Map<String,RDS_Premise_Details__c>();
        Set<String> dealHIds = new Set<String>();
        List<Opportunity> mACDOptyList = new List<Opportunity>(); // List of cloned Optys after disconnect
        Map<String, Deal_Hash__c> dhMap = new Map<String, Deal_Hash__c>();
        String masterOppId;
        Id newMACDOptyId;        
        List<Deal_Hash__c> dhUpdateList = new List<Deal_Hash__c>();
        List<RDS_Premise_Details__c> premList = new List<RDS_Premise_Details__c>();
        Set<String> optyIds = new Set<String>();
        Set<String> addPremise = new Set<String>();
        Set<String> optyIdsAdd = new Set<String>();
        List<RDS_Premise_Details__c> mACDPremList = new List<RDS_Premise_Details__c>(); // List of cloned Premise after disconnect
        List<RDS_Premise_Details__c> updtPremList = new List<RDS_Premise_Details__c>(); // List of disconnected Premise to be updated
        List<Deal_Hash__c> dhList = new List<Deal_Hash__c>();
        Decimal version; // Current version that is incremented by 1 on each Disconnect
        Id dhId;  // Master Deal Hash to which all Premise are associated
        List<SPProduct__c> spIdList = new List<SPProduct__c>(); // Ids of SP Products associated to the Master Opty
        Map<String,SPProduct__c> spMap = new Map<String,SPProduct__c> ();
        Map<String,SPProduct__c> spMapAdd = new Map<String,SPProduct__c> ();
        List<SPProduct__c> cloneSPPrList = new List<SPProduct__c>();  //List of SP Product records to be cloned during Disconnect
        List<SPProduct__c> cloneAddSPPrList = new List<SPProduct__c>();  //List of Add SP Product records to be cloned during Disconnect
        Map<String,RDS_Premise_Details__c> premSiteMap = new Map<String,RDS_Premise_Details__c>();
        List<SPProduct__c> clonedSPIdList = new List<SPProduct__c>(); // Ids of cloned SP Products 
        List<SPProduct__c> clonedAddSPIdList = new List<SPProduct__c>(); // Ids of cloned Add SP Products 
        List<Product_Pricing__c> pprIdList = new List<Product_Pricing__c>(); // Ids of Product Pricing records associated to the Master Opty
        List<Product_Pricing__c> pprIdAddList = new List<Product_Pricing__c>(); // Ids of Product Pricing records associated to the Add Opty
        List<Product_Pricing__c> clonePPrList = new List<Product_Pricing__c>();  //List of Product Pricing records to be cloned during Disconnect
        List<Product_Pricing__c> cloneAddPPrList = new List<Product_Pricing__c>();  //List of Add Product Pricing records to be cloned during Disconnect
        List<RDS_Premise_Details__c> clonedPremIdList = new List<RDS_Premise_Details__c>(); // Ids of cloned Premise records 
        Integer bid = null;
        List<Circuit_and_VLAN_Details__c> cvlanList = new List<Circuit_and_VLAN_Details__c>(); // Ids of CVLAN associated to the Master Opty
        List<Circuit_and_VLAN_Details__c> clonecvlanList = new List<Circuit_and_VLAN_Details__c>();  //List of CVLAN records to be cloned during Disconnect
        List<RDS_BillingRelatedElements__c> cloneBillList = new List<RDS_BillingRelatedElements__c>();  //List of Billing records to be cloned during Disconnect
        List<RDS_Contact__c> cloneConList = new List<RDS_Contact__c>();  //List of Contact records to be cloned during Disconnect
        List<RDS_Competitive_Discount__c> cloneCompDiscList = new List<RDS_Competitive_Discount__c>();  //List of Competitive Discount records to be cloned during Disconnect
        Set<Id> masterCVLANIdSet = new Set<Id>();
        Set<Id> macdCVLANIdSet = new Set<Id>();
        Id rtypeId;
        String stat;
        String dealHashId;
        Decimal newVersion;
        
        for(RDS_Premise_Details__c oldprem: oldPremiseList){
            for(RDS_Premise_Details__c prem: updtPremiseList){
                if(oldprem.Premise_Number__c == prem.Premise_Number__c){
                    if((oldprem.Disconnect_Type__c != prem.Disconnect_Type__c) && (prem.Disconnect_Type__c == UtilityConstant.HARDDISCONNECT || prem.Disconnect_Type__c == UtilityConstant.SOFTDISCONNECT|| prem.Disconnect_Type__c == UtilityConstant.SOFTCANCEL )){
                        optyIds.add(prem.OpptyID__c);
                        if(prem.MACD_Type__c == SIConstants.MACDTYPEA){
                            addPremise.add(prem.Premise_Number__c);
                        }
                    if(prem.Disconnect_Type__c == UtilityConstant.HARDDISCONNECT){
                            stat = UtilityConstant.HARD;
                        } else{
                            stat = UtilityConstant.SOFT;
                        }
                    dealHIds.add(prem.DealHash__c);
                    premList.add(prem);
                    premSiteMap.put(prem.Premise_Number__c,prem); // Map of Premise Number and Premise on which Disconnect is being performed
                    }
                }
            }
        } 
        if(dealHIds.size()>0){
            dhList = [Select Id, Name, RDS_Version__c, Opportunity__c, RDS_Version_Select__c from Deal_Hash__c Where Id = :dealHIds limit 1];
            if(dhList.size()>0){
                for(Deal_Hash__c dh : dhList){
                    version = dh.RDS_Version__c;
                    dhId = dh.Id;
                    dhMap.put(dh.Opportunity__c,dh);    // Opportunity & Deal Hash Map
                }
            }
        
        
            if (optyIds.size()>0){
            rtypeId= [select Id,Name,SobjectType from RecordType where DeveloperName =: UtilityConstant.MACD and SobjectType=: UtilityConstant.OPPORTUNITY limit 1].Id;
            masterOppId = String.valueOf([Select Id from Opportunity where Id =: optyIds order by Id desc limit 1].Id);
            }   
            if(premSiteMap.size()>0){     //Disconnect is being performed for any regular premise
                for(SPProduct__c s : [Select Id, Site_ID__c, Deal__c from SPProduct__c Where Site_ID__c =: premSiteMap.keySet() AND Deal__c =: masterOppId]){
                    spMap.put(s.Id, s);
                }  
                if(spMap.size()>0){          
                    pprIdList = [Select Id, Type__c, SP_Product__c, SP_Site_Id__c, Deal_Id__c from Product_Pricing__c where SP_Product__c =: spMap.keySet()];
                }
            } 
            if(String.isNotBlank(masterOppId)){
            
            String soqlOpty = API_Utils.getCreatableFieldsSOQL('opportunity', 'id=\''+masterOppId+'\'');    //cloning optys when disconnect is performed
            Opportunity opp = (Opportunity)Database.query(soqlOpty);
            Opportunity newOpp = opp.clone(false,true,true,true);
            newOpp.RecordTypeId = rtypeId;
            newOpp.MACD_Type__c = SIConstants.MACDTYPED;
            newOpp.RDS_Version__c = version + 1;
            newOpp.Name = newOpp.Name + SpecialCharacterConstant.HYPHEN + String.valueof(newOpp.RDS_Version__c);
            newOpp.RDS_Deal_Hash__c = dhMap.get(opp.Id).Id;
            newOpp.API_Process_Status__c = SpecialCharacterConstant.CONCAT;
            newOpp.CDG_Sub_Account_Last_timestamp__c = null;
            newOpp.CDG_Sub_Account_Status__c = SpecialCharacterConstant.CONCAT;
            newOpp.CDG_Sub_Account_Last_Run_Error_Msg__c = SpecialCharacterConstant.CONCAT;
            newOpp.Circuit_ID_USO_Last_timestamp__c = null;
            newOpp.Circuit_ID_USO_Status__c = SpecialCharacterConstant.CONCAT;
            newOpp.Circuit_ID_USO_Last_Run_Error_Msg__c = SpecialCharacterConstant.CONCAT;
            newOpp.RDS_Received_Last_Time_Stamp__c = DateTime.Now();
            newOpp.RDS_Received_Status__c = UtilityConstant.SUCCESS;
            newOpp.RDS_Review_Complete_Last_Time_Stamp__c = null;
            newOpp.RDS_Review_Complete_Status__c = SpecialCharacterConstant.CONCAT;
            newOpp.SA_Contract_Subscription_Last_Time_Stamp__c = null;
            newOpp.SA_Contract_Subscription_Status__c = SpecialCharacterConstant.CONCAT;
            newOpp.SA_Contract_Subscription_Error_Msg__c = SpecialCharacterConstant.CONCAT;
            newOpp.Deal_Rate_Plan_Last_Time_Stamp__c = null;
            newOpp.Deal_Rate_Plan_Status__c = SpecialCharacterConstant.CONCAT;
            newOpp.Deal_Rate_Plan_Error_Msg__c = SpecialCharacterConstant.CONCAT;
            newOpp.MD5_Status__c = SpecialCharacterConstant.CONCAT;
            newOpp.MD5_Last_Time_Stamp__c = null;
            newOpp.MD5_Error_Msg__c = SpecialCharacterConstant.CONCAT;
            newOpp.BID_ID__c = newOpp.BID_ID__c+SpecialCharacterConstant.HYPHEN+newOpp.RDS_Version__c;
            newOpp.RDS_Excel_status__c = SpecialCharacterConstant.CONCAT;
            newOpp.RDS_Excel_Created__c = false;
            newOpp.RDS_Excel_failure_reason__c = SpecialCharacterConstant.CONCAT;
            newOpp.Ready_for_RDS_Excel__c = SpecialCharacterConstant.CONCAT;
            
                if(stat==UtilityConstant.HARD){
                    newOpp.MACDStatus__c = UtilityConstant.NEEDUSO;
                    newOpp.IsCircuit_ID_USOSucess__c=false;
                }
            newOpp.Master_deal_number__c = opp.BID_ID__c;
            MACDOptyList.add(newOpp);
            }
            if(MACDOptyList.size()>0){  
                try{
                    insert MACDOptyList;
                } catch(DMLException e){
                    e.getmessage();
                }
            }
            if(MACDOptyList.size()>0){
            newMACDOptyId = [Select Id from Opportunity Where Id =: MACDOptyList limit 1].Id;
            }
            
            if(spMap.size()>0){          //cloning SP Product records when disconnect is performed
                for(SPProduct__c sp : spMap.values()){
                    String soql = API_Utils.getCreatableFieldsSOQL('SPProduct__c', 'id=\''+sp.Id+'\'');    
                    SPProduct__c spd = (SPProduct__c)Database.query(soql);
                    SPProduct__c macSP = spd.clone(false,true,true,true);
                    macSP.Deal__c = newMACDOptyId;
                    macSP.MACD_Type__c = SIConstants.MACDTYPED;
                    macSP.Rome_Product_ID__c = null;
                    macSP.RDS_Version__c = version + 1;
                    macSP.API_Process_Error__c=SpecialCharacterConstant.CONCAT;
                    macSP.API_Process_Status__c=SpecialCharacterConstant.CONCAT;
                        if(premSiteMap.get(macSP.Site_ID__c).Disconnect_Type__c == BuyflowConstant.Soft_Disconnect || premSiteMap.get(macSP.Site_ID__c).Disconnect_Type__c == BuyflowConstant.Soft_Cancel){
                            macSP.Disconnect_Type__c =UtilityConstant.SD;
                        } else {
                            macSP.Disconnect_Type__c =UtilityConstant.HD;
                        }
                    cloneSPPrList.add(macSP);
                }
            }
            
            if(cloneSPPrList.size()>0){  
                try{
                    insert cloneSPPrList;
                } catch(DMLException e){
                    e.getmessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            }
            if(cloneSPPrList.size()>0){
            clonedSPIdList = [Select Id, Site_ID__c from SPProduct__c Where Id =: cloneSPPrList];
            }
            if(pprIdList.size()>0 && clonedSPIdList.size()>0){
                for(SPProduct__c spp : clonedSPIdList){
                    for(SPProduct__c sps : spMap.values()){
                        for(Product_Pricing__c pp : pprIdList){
                            if(pp.SP_Site_Id__c == sps.Site_ID__c && spp.Site_ID__c == sps.Site_ID__c && pp.SP_Product__c == sps.Id && pp.Type__c != UtilityConstant.NRC){
                                String soql = API_Utils.getCreatableFieldsSOQL('Product_Pricing__c', 'id=\''+pp.Id+'\'');    
                                Product_Pricing__c pPr = (Product_Pricing__c)Database.query(soql);
                                Product_Pricing__c newPP = pPr.clone(false,true,true,true);
                                newPP.SP_Product__c = spp.Id;
                                newPP.MACD_Type__c = SIConstants.MACDTYPED;
                                clonePPrList.add(newPP);
                            }
                        }
                    }
                }   
            }
                        
            if(clonePPrList.size()>0){  
                try{
                    insert clonePPrList;
                } catch(DMLException e){
                    e.getmessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            }
        
        if(addPremise.size()>0){   //Disconnect is being performed for an ADD premise
            for(SPProduct__c s : [Select Id, Site_ID__c, Deal__c from SPProduct__c Where Site_ID__c =: addPremise AND MACD_Type__c =: SIConstants.MACDTYPEA]){
                spMapAdd.put(s.Id, s);
            }            
            pprIdAddList = [Select Id, SP_Product__c, SP_Site_Id__c, Deal_Id__c from Product_Pricing__c where SP_Product__c =: spMapAdd.keySet()];
            
            if(spMapAdd.size()>0){          //cloning SP Product records when disconnect is performed on an Add Premise
                for(SPProduct__c sp : spMapAdd.values()){
                    String soql = API_Utils.getCreatableFieldsSOQL('SPProduct__c', 'id=\''+sp.Id+'\'');    
                    SPProduct__c spd = (SPProduct__c)Database.query(soql);
                    SPProduct__c macSP = spd.clone(false,true,true,true);
                    macSP.Deal__c = newMACDOptyId;
                    macSP.MACD_Type__c = SIConstants.MACDTYPED;
                    macSP.Rome_Product_ID__c = null;
                    macSP.RDS_Version__c = version + 1;
                        if(premSiteMap.get(macSP.Site_ID__c).Disconnect_Type__c ==  BuyflowConstant.Soft_Disconnect || premSiteMap.get(macSP.Site_ID__c).Disconnect_Type__c == BuyflowConstant.Soft_Cancel){
                            macSP.Disconnect_Type__c =UtilityConstant.SD;
                        } else {
                            macSP.Disconnect_Type__c =UtilityConstant.HD;
                        }
                    cloneAddSPPrList.add(macSP);
                }
            }
            
            if(cloneAddSPPrList.size()>0){  
                try{
                    insert cloneAddSPPrList;
                } catch(DMLException e){
                    e.getmessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            }
            if(cloneAddSPPrList.size()>0){
                clonedAddSPIdList = [Select Id, Site_ID__c from SPProduct__c Where Id =: cloneAddSPPrList];
            }
            
            if(pprIdAddList.size()>0 && clonedAddSPIdList.size()>0){
                for(SPProduct__c spp : clonedAddSPIdList){
                    for(SPProduct__c sps : spMapAdd.values()){
                        for(Product_Pricing__c pp : pprIdAddList){
                            if(pp.SP_Site_Id__c == sps.Site_ID__c && spp.Site_ID__c == sps.Site_ID__c && pp.SP_Product__c == sps.Id){
                                String soql = API_Utils.getCreatableFieldsSOQL('Product_Pricing__c', 'id=\''+pp.Id+'\'');    
                                Product_Pricing__c pPr = (Product_Pricing__c)Database.query(soql);
                                Product_Pricing__c newPP = pPr.clone(false,true,true,true);
                                newPP.SP_Product__c = spp.Id;
                                newPP.MACD_Type__c = SIConstants.MACDTYPED;
                                cloneAddPPrList.add(newPP);
                            }
                        }
                    }
                }   
            }
            
            if(cloneAddPPrList.size()>0){  
                try{
                    insert cloneAddPPrList;
                } catch(DMLException e){
                    e.getmessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            }
        }
        
        if(premList.size()>0){          //cloning premise on which disconnect is performed
        List<Circuit_and_VLAN_Details__c> cvlanVLANCKTList = [Select Id,Premise__c,(select Id from Circuit_and_VLAN_Details__r) from Circuit_and_VLAN_Details__c where Premise__c IN :premList];
            for(RDS_Premise_Details__c pr : premList){
                    String soql = API_Utils.getCreatableFieldsSOQL('RDS_Premise_Details__c', 'id=\''+pr.Id+'\'');    
                    RDS_Premise_Details__c orgPr = (RDS_Premise_Details__c)Database.query(soql);
                    RDS_Premise_Details__c macPr = orgPr.clone(false,true,true,true);
                    if(cvlanVLANCKTList.size()>0){
                        for(Circuit_and_VLAN_Details__c cvDet : cvlanVLANCKTList){
                            if(cvDet.Premise__c == pr.Id){
                                macPr.Circuit_mlppSegments__c = cvDet.Circuit_and_VLAN_Details__r.size();
                    
                            }
                        }
                    }
                    macPr.MACD_Type__c = SIConstants.MACDTYPED;
                    macPr.RDS_Version__c = version + 1;
                    if(macPr.Disconnect_Type__c != null && macPr.Disconnect_Type__c == UtilityConstant.HARDDISCONNECT)
                    {
                        macPr.Site_Status__c = UtilityConstant.PENDINGHARD_DISCONNECT;
                    }
                    else if(macPr.Disconnect_Type__c != null && macPr.Disconnect_Type__c == UtilityConstant.SOFTDISCONNECT)
                    {
                        macPr.Site_Status__c = UtilityConstant.PENDINGSOFT_DISCONNECT;
                    }
                    else if(macPr.Disconnect_Type__c != null && macPr.Disconnect_Type__c == UtilityConstant.SOFTCANCEL)
                    {
                        macPr.Site_Status__c = UtilityConstant.PENDINGSOFT_DISCONNECT_CANCEL;
                    }                
                    else {
                        macPr.Site_Status__c = UtilityConstant.PENDING;
                    }
                    macPr.Current_Version__c = true;
                    macPr.Is_Reviewed__c = true;
                    if(stat==UtilityConstant.HARD){
                        macPr.IsCircuit_ID_USO_Success__c = false;
                        macPr.Circuit_Order_Action__c = UtilityConstant.N;
                        macPr.Circuit_Circuit_Action__c =SpecialCharacterConstant.CONCAT;
                        macPr.Circuit_VLAN_Indicator__c =UtilityConstant.N;
                        macPr.Circuit_Service_Code__c =SpecialCharacterConstant.CONCAT;
                        macPr.Circuit_Service_Code_Modifier__c =SpecialCharacterConstant.CONCAT;
                        macPr.Circuit_Service_Type__c =SpecialCharacterConstant.CONCAT;
                        macPr.Circuit_ServiceSub_Type__c=SpecialCharacterConstant.CONCAT;
                        macPr.Circuit_mlppIndicator__c=SpecialCharacterConstant.CONCAT;
                        macPr.Circuit_Speed__c=SpecialCharacterConstant.CONCAT;
                        macPr.Circuit_Access_Type__c=SpecialCharacterConstant.CONCAT;
                        macPr.USO_Order_Action__c=UtilityConstant.A;
                    }                
                    //Start of changes to blank out the send to grid flag - Anand -0604
                    macPr.Sent_to_Grid__c = false;
                    //End of changes    
                    MACDPremList.add(macPr);
                }
            }
        
        if(MACDPremList.size()>0){  
                try{
                    insert MACDPremList;
                } catch(DMLException e){
                    e.getmessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
        }
        if(premList.size()>0){
        cvlanList = [Select Id, Premise__c,Action_Details__c,CVLAN_Premise_Number__c, MACD_Version__c from Circuit_and_VLAN_Details__c Where Premise__c =: premList];
        }
        if(MACDPremList.size()>0){        
        clonedPremIdList = [Select Id,Transport_Type__c,Premise_Number__c,Disconnect_Type__c from RDS_Premise_Details__c Where Id =: MACDPremList];

        }
        if(cvlanList.size()>0 && clonedPremIdList.size()>0){
            for(Circuit_and_VLAN_Details__c cv : cvlanList){
                    for(RDS_Premise_Details__c p : clonedPremIdList){
                        if(cv.CVLAN_Premise_Number__c == p.Premise_Number__c){
                            String soql = API_Utils.getCreatableFieldsSOQL('Circuit_and_VLAN_Details__c', 'id=\''+cv.Id+'\''); 
                            Circuit_and_VLAN_Details__c cvd = (Circuit_and_VLAN_Details__c)Database.query(soql);
                            Circuit_and_VLAN_Details__c newCVD = cvd.clone(false,true,true,true);
                            newCVD.Premise__c = p.Id;
                            newCVD.MACD_Type__c = SIConstants.MACDTYPED;
                             if(stat == SFDCConstant.HARD && p.Transport_Type__c==SFDCConstant.SWITCHEDETHERNET){
                            newCVD.Action_Details__c=SIConstants.MACDTYPED;
                            }else{
                           
                             newCVD.Action_Details__c=SFDCConstant.N;
                            }
                            clonecvlanList.add(newCVD);
                            masterCVLANIdSet.add(cv.Id);
                        }
                    }
            }   
        }
        
        if(clonecvlanList.size()>0){  
            try{
                insert clonecvlanList;
            } catch(DMLException e){
                e.getmessage();
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
            for(Circuit_and_VLAN_Details__c cvIds : clonecvlanList){
            macdCVLANIdSet.add(cvIds.Id);
            }
        }
        List<RDS_BillingRelatedElements__c> billList;        
        if(premList.size()>0){
            billList= [Select Id, PremiseDetails__c, Billing_Premise_Number__c from RDS_BillingRelatedElements__c Where PremiseDetails__c =: premList];
        }
        if(billList.size()>0 && clonedPremIdList.size()>0){
            for(RDS_BillingRelatedElements__c bill : billList){
                for(RDS_Premise_Details__c p : clonedPremIdList){
                    if(bill.Billing_Premise_Number__c == p.Premise_Number__c){
                        String soql = API_Utils.getCreatableFieldsSOQL('RDS_BillingRelatedElements__c', 'id=\''+bill.Id+'\'');    
                        RDS_BillingRelatedElements__c billD = (RDS_BillingRelatedElements__c)Database.query(soql);
                        RDS_BillingRelatedElements__c newBillD = billD.clone(false,true,true,true);
                        newBillD.PremiseDetails__c = p.Id;
                        newBillD.MACD_Type__c = SIConstants.MACDTYPED;
                        cloneBillList.add(newBillD);
                    }
                }
            }   
        }
      
        
        if(cloneBillList.size()>0){  
            try{
                insert cloneBillList;
            } catch(DMLException e){
                e.getmessage();
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
        List<RDS_Contact__c> conList;        
        if(premList.size()>0){
         conList = [Select Id, RDS_Premise_Details_Number__c, RDS_Premise_Details_Number__r.Premise_Number__c from RDS_Contact__c Where RDS_Premise_Details_Number__c =: premList];
        }
        if(conList.size()>0 && clonedPremIdList.size()>0){
            for(RDS_Contact__c rdCon : conList){
                for(RDS_Premise_Details__c pd : clonedPremIdList){
                    if(rdCon.RDS_Premise_Details_Number__r.Premise_Number__c == pd.Premise_Number__c){
                        String soql = API_Utils.getCreatableFieldsSOQL('RDS_Contact__c', 'id=\''+rdCon.Id+'\'');    
                        RDS_Contact__c rdsCon = (RDS_Contact__c)Database.query(soql);
                        RDS_Contact__c newRDSCon = rdsCon.clone(false,true,true,true);
                        newRDSCon.RDS_Premise_Details_Number__c = pd.Id;
                        newRDSCon.MACD_Type__c = SIConstants.MACDTYPED;
                        cloneConList.add(newRDSCon);
                    }
                }
            }   
        }
        
        if(cloneConList.size()>0){  
            try{
                insert cloneConList;
            } catch(DMLException e){
                e.getmessage();
                ATTException.logException(e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }   
        List<RDS_Competitive_Discount__c> compList;        
        if(premList.size()>0){
          compList = [Select Id, PremiseDetails__c, PremiseDetails__r.Premise_Number__c from RDS_Competitive_Discount__c Where PremiseDetails__c =: premList];
        }
        if(compList.size()>0 && clonedPremIdList.size()>0){
            for(RDS_Competitive_Discount__c rdCom : compList){
                    for(RDS_Premise_Details__c pdt : clonedPremIdList){
                        if(rdCom.PremiseDetails__r.Premise_Number__c == pdt.Premise_Number__c){
                            String soql = API_Utils.getCreatableFieldsSOQL('RDS_Competitive_Discount__c', 'id=\''+rdCom.Id+'\'');    
                            RDS_Competitive_Discount__c rdsComp = (RDS_Competitive_Discount__c)Database.query(soql);
                            RDS_Competitive_Discount__c newRDSComp = rdsComp.clone(false,true,true,true);
                            newRDSComp.PremiseDetails__c = pdt.Id;
                            newRDSComp.MACD_Type__c = SIConstants.MACDTYPED;
                            cloneCompDiscList.add(newRDSComp);
                        }
                    }
            }   
        }
        
        
        if(cloneCompDiscList.size()>0){  
            try{
                insert cloneCompDiscList;
            } catch(DMLException e){
                e.getmessage();
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }        

        
        if(dhMap.size()>0){
            for(Deal_Hash__c dhRec : dhMap.values()){  
                dhRec.RDS_Version__c = version + 1;
                newVersion = version + 1;
                dhRec.RDS_Version_Select__c = UtilityConstant.ALL;
                dealHashId = dhRec.Id;
                dhUpdateList.add(dhRec);
            }
        }
        
        if(dhUpdateList.size()>0){  
            try{
                update dhUpdateList;
            } catch(DMLException e){
                e.getmessage();
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
        
        API_MACDCVLAN.createChildRecordsForMACDCVLAN(macdCVLANIdSet,masterCVLANIdSet,dealHashId,stat,newMACDOptyId, newVersion);
        
        }
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }

/* Method to update default USO VLAN based on Number of USOs */    
/* 
 Name: defvalUpdateonUSOVLANIndicator
 Description: 
 */ 
    public void defvalUpdateonUSOVLANIndicator(Sobject[] newObject){
     try{   
        List<RDS_Premise_Details__c> premList = newObject;
        List<RDS_Premise_Details__c> premListtoUpdate = new List<RDS_Premise_Details__c>();
        
        for(RDS_Premise_Details__c pd :premList){
            if(pd.USO_Number_of_USOS__c == null){
                pd.USO_VLAN__c =UtilityConstant.N;
            }
        }
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }       
    }
    
/* Actions on MACD Add : Updating current version on Premise */
/* 
 Name: macdAddUpdates
 Description: 
 */ 
    public void macdAddUpdates(SObject[] newObjects){
     try{  
        List<RDS_Premise_Details__c> newPremiseList = newObjects;
        Set<String> premiseNumSet = new Set<String>();
        Set<String> dealHashIds = new Set<String>();
        List<Deal_Hash__c> dhToUpdateList = new List<Deal_Hash__c>();
        
        for(RDS_Premise_Details__c prem : newPremiseList){
            premiseNumSet.add(prem.Premise_Number__c);   
        }
        
        if(premiseNumSet.size()>0){
            for(SPProduct__c s : [Select Id, Site_ID__c, Deal__c, RDS_Version__c, MACD_Type__c, DealRegNum__c from SPProduct__c where Site_ID__c =: premiseNumSet]){ 
                for(RDS_Premise_Details__c p : newPremiseList){
                    if(p.Premise_Number__c==s.Site_ID__c && s.MACD_Type__c==SIConstants.MACDTYPEA){
                        p.RDS_Version__c = s.RDS_Version__c;
                        p.MACD_Type__c = SIConstants.MACDTYPEA;
                        p.MACD_RDS_Received_Date__c = DateTime.Now();
                        p.MACD_Deal_Reg_Number__c = s.DealRegNum__c;
                        dealHashIds.add(p.DealHash__c);
                    }
                }
            }
        }
        
        if(dealHashIds.size()>0){
            for(Deal_Hash__c d : [Select Id, RDS_Version_Select__c from Deal_Hash__c where Id =: dealHashIds]){
                d.RDS_Version_Select__c = UtilityConstant.ALL;
                dhToUpdateList.add(d);
            }
        }
        
        if(dhToUpdateList.size()>0){
            try{
                update dhToUpdateList;
            } catch(DMLException e){
                e.getmessage();
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    } 
    
//Method to update RDS Received status to success and hence the Pre-prov to Green when a MACD ADD Premise is inserted.  
/* 
 Name: updateMACDAddOpptyRDSReceived
 Description: 
 */ 
 public void updateMACDAddOpptyRDSReceived(SObject[] newObjects){
   try{ 
     List<RDS_Premise_Details__c> premiseDetailsList = newObjects;
     List<Opportunity> mACDOpptyList = new List<Opportunity>();
     Set<ID>dealhashIDset = new Set<ID>();
     Set<decimal>rDSVersionSet = new Set<decimal>();
     List<Opportunity> updatedMacdList = new List<Opportunity>();
 
     for(RDS_Premise_Details__c PremiseRecord: premiseDetailsList)
     {
        if(PremiseRecord.MACD_Type__c == UtilityConstant.A && PremiseRecord.RDS_Version__c>1)
        {   
            DealhashIDset.add(PremiseRecord.DealHash__c);
            RDSVersionSet.add(PremiseRecord.RDS_Version__c);
        }
     }
     if(DealhashIDset.size()>0 && RDSVersionSet.size()>0)
     {
        MACDOpptyList = [Select id,RDS_Deal_Hash__c, RDS_Version__c,MACD_Type__c,RDS_Received_Status__c,RDS_Received_Last_Time_Stamp__c FROM Opportunity WHERE RDS_Version__c IN:RDSVersionSet AND RDS_Deal_Hash__c IN:DealhashIDset AND MACD_Type__c=:SIConstants.MACDTYPEA];
     }
     if(MACDOpptyList.size()>0)
     {
     for(RDS_Premise_Details__c PremiseRecord: premiseDetailsList)
        {
            for(Opportunity MACDOppty:MACDOpptyList)
            {    
                if(PremiseRecord.RDS_Version__c == MACDOppty.RDS_Version__c && PremiseRecord.DealHash__c == MACDOppty.RDS_Deal_Hash__c && MACDOppty.RDS_Received_Status__c==null)
                {   
                    MACDOppty.RDS_Received_Status__c = UtilityConstant.SUCCESS;
                  
                    MACDOppty.RDS_Received_Last_Time_Stamp__c = System.now();
                }
                UpdatedMacdList.add(MACDOppty);
            }
        }
     }
     if(UpdatedMacdList.size()>0)
     {  
          try{
             update UpdatedMacdList;
             }
          catch(Exception ex){
                    ex.getMessage();
                    ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
                }
      }
   }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        } 
 }
 
// To update Charge Element ID on RDS-Billing Related Elements if Site Status on Premise is active after a UBB Change
    
/* 
 Name: updateChargeElementIdOnBRE
 Description: 
 */ 
    public void updateChargeElementIdOnBRE(SObject[] oldObjects,SObject[] updatedObjects){
     try{   
        List<RDS_Premise_Details__c> rdpOList = oldObjects; 
        List<RDS_Premise_Details__c> rdpUList = updatedObjects;
        Set<String> premIds = new Set<String>();
        List<RDS_BillingRelatedElements__c> billList = new List<RDS_BillingRelatedElements__c>();
        List<RDS_BillingRelatedElements__c> updateBillingList = new List<RDS_BillingRelatedElements__c>();
        
        for(RDS_Premise_Details__c rdpo : rdpOList){
            for(RDS_Premise_Details__c rdpu : rdpUList){
                if(rdpo.Premise_Number__c == rdpu.Premise_Number__c && rdpo.Site_Status__c!= rdpu.Site_Status__c && rdpu.Site_Status__c == UtilityConstant.ACTIVE){
                    premIds.add(rdpu.Id); 
                }
            }
        }
        
        if(premIds.size()>0){
            billList = [Select Id, Change_Charge_Element_ID__c, Charge_Element_ID__c, PremiseDetails__c From RDS_BillingRelatedElements__c where PremiseDetails__c IN: premIds];
            if(billList.size()>0){
                for(RDS_BillingRelatedElements__c rBill : billList){
                    if(String.isNotBlank(rBill.Change_Charge_Element_ID__c)){
                        rBill.Charge_Element_ID__c = rBill.Change_Charge_Element_ID__c;
                        rBill.Change_Charge_Element_ID__c = SpecialCharacterConstant.CONCAT;
                        updateBillingList.add(rBill);
                    }
                }
            }
        }
        
        if(updateBillingList.size()>0){
            try{
                update updateBillingList;
            } catch(DMLException e){
                e.getmessage();
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }   
        }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    } 
    
/* 
 Name: newObjects)
 Type: Class 
 
 Description: 
 */ 
    public void updateclassofservice(SObject[] newObjects){
        try
        {
        
        }
        catch(Exception e)
        {
        
        }
    
     }
     

/* 
 Name: ChangeCircuitstatusVLANstatus
 Description: 
 */ 
public void changeCircuitstatusVLANstatus(Sobject[] oldObjects,Sobject[] updatedObjects){
    try{
            List<RDS_Premise_Details__c> newPremiseList = updatedObjects;
            List<RDS_Premise_Details__c> oldPremiseList= oldObjects;
            List<VLAN_Information__c> vlanList = new List<VLAN_Information__c>();
            List<VLAN_Information__c> vlanListToUpdate = new List<VLAN_Information__c>();
            List<RDS_Access_Circuit_ID__C> accCktList = new List<RDS_Access_Circuit_ID__C>();
            List<RDS_Access_Circuit_ID__C> accCktListToUpdate = new List<RDS_Access_Circuit_ID__C>();
            Set<Id> premiseIds = new Set<Id>(); 
            
            for(RDS_Premise_Details__c oldPr : oldPremiseList){
                for(RDS_Premise_Details__c newPr : newPremiseList){
                    if(oldPr.Id == newPr.Id  && (newPr.Site_Status__c ==UtilityConstant.ACTIVE || newPr.Site_Status__c ==UtilityConstant.STATIC_NEW) && oldPr.Site_Status__c==UtilityConstant.PENDINGSPEED_CHANGE && newPr.MACD_Type__c==UtilityConstant.C){
                        premiseIds.add(newPr.Id);
                    }
                }
            }
            if(premiseIds.size()>0){
                vlanList = [Select Id, VLAN_status__c from VLAN_Information__c where Circuit_and_VLAN_Details__r.Premise__c =: premiseIds]; 
                accCktList = [Select Id, circuitStatus__c from RDS_Access_Circuit_ID__c where Circuit_and_VLAN_Details__r.Premise__c =: premiseIds];   
            }

            if(vlanList.size()>0){
                for(VLAN_Information__c vl: vlanList){
                    if(vl.VLAN_status__C == UtilityConstant.PENDINGDELETE){
                        vl.VLAN_status__C = UtilityConstant.DELETED;
                    } else {
                        vl.VLAN_status__C = UtilityConstant.ACTIVE;
                    }
                    vlanListToUpdate.add(vl);
                }
            }
            if(vlanListToUpdate.size()>0){
                try {
                    update vlanListToUpdate;
                } catch (DMLException e){
                    e.getMessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            }
            
            if(accCktList.size()>0){
                for(RDS_Access_Circuit_ID__C cl: accCktList){ 
                   if(cl.circuitStatus__c == UtilityConstant.PENDINGDELETE || cl.circuitStatus__c == UtilityConstant.DELETED){
                       cl.circuitStatus__c=UtilityConstant.DELETED;  
                    } else{
                      cl.circuitStatus__c=UtilityConstant.ACTIVE;
                    }
                    accCktListToUpdate.add(cl);
                }
            }   
            if(accCktListToUpdate.size()>0){
                try {
                    update accCktListToUpdate;
                } catch (DMLException e){
                    e.getMessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            }
    }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   

 }
 
 /*****Added for Inflight Cancel*****************/
/* 
 Name: updateQuoteApprovalStage
 Description: 
 */ 
 public void updateQuoteApprovalStage(Sobject[] oldObjects,Sobject[] updatedObjects){
     try{
          List<RDS_Premise_Details__c> newPremiseList = updatedObjects;
          List<RDS_Premise_Details__c> oldPremiseList= oldObjects;
          Set<String>premiseQuoteSet = new Set<String>();
          List<Apttus_Proposal__Proposal__c> quoteListToUpdate = new List<Apttus_Proposal__Proposal__c>();
          
           for(RDS_Premise_Details__c oldPr : oldPremiseList)
           {
                for(RDS_Premise_Details__c newPr : newPremiseList)
                {
                    if(oldPr.Id == newPr.Id && newPr.Site_Status__c!= oldPr.Site_Status__c && newPr.Site_Status__c ==UtilityConstant.CANCELLED && newPr.Cancel_Quote_Proposal__c!=null)
                    {
                            premiseQuoteSet.add(newPr.Cancel_Quote_Proposal__c);

                    }               
                }
            }
            if(premiseQuoteSet.size()>0)
            {
            for(Apttus_Proposal__Proposal__c inflightQuote: [Select id,name,Apttus_Proposal__Approval_Stage__c FROM Apttus_Proposal__Proposal__c WHERE id IN:premiseQuoteSet])
               {
                    inflightQuote.Apttus_Proposal__Approval_Stage__c=UtilityConstant.CANCELLATIONORDER_COMPLETED;
                    quoteListToUpdate.add(inflightQuote);
                    
               }
            }
            
            if(quoteListToUpdate.size()>0)
            {    
                try {  
                    update quoteListToUpdate;
                } catch (DMLException e){
                    e.getMessage();
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            
            }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }           
    }
    
    /*Method to update all the premises with Site Status when CI updates one of them for Contract Renewal flow and also to clear Contract Renewal Status on Deal Hash*/
    public void updateRenewalContractPremise(Map<id,RDS_Premise_Details__c> updateRenewalContractPremMap){
        List<ID> dhlist = new List<ID>();                 
        Set<Id> dealHashIdsToClearStage = new Set<Id>();
        
        for(RDS_Premise_Details__c premise : updateRenewalContractPremMap.values()){
            dhlist.add(premise.dealHash__c);
            if(premise.Site_Status__c == BuyflowConstant.ACTIVE2){
                dealHashIdsToClearStage.add(premise.dealHash__c);
            }
        }
        
        List<RDS_Premise_Details__c> newPremiseList = new List<RDS_Premise_Details__c>();
        List<RDS_Premise_Details__c> updatePremiseList = new List<RDS_Premise_Details__c>();
        newPremiseList = [select id,DealHash__c,Change_Flow_Type__c,Site_Status__c,Current_Version__c,RDS_Version__c from RDS_Premise_Details__c where DealHash__c  IN:dhList];
        
        for(RDS_Premise_Details__c prem : newPremiseList){
            for(RDS_Premise_Details__c pr : updateRenewalContractPremMap.values()){
                if(prem.DealHash__c  == pr.DealHash__c && prem.Current_Version__c == true && prem.Change_Flow_Type__c == RenewConstant.Renewal && prem.RDS_Version__c == pr.RDS_Version__c && prem.Site_Status__c != pr.Site_Status__c){
                    prem.Site_Status__c = pr.Site_Status__c;
                    updatePremiseList.add(prem);
                }
            }       
        }
        if(updatePremiseList != null && updatePremiseList.size() >0){
            update updatePremiseList;
        }
        
        //Logic to clear Contract Renewal Stage on Deal Hash
        List<Deal_Hash__c > dealhashlist = new List<Deal_Hash__c >();
        List<Deal_Hash__c > updateDhlist = new List<Deal_Hash__c >();
        dealhashlist = [select id,Contract_Renewal_Stage__c from Deal_Hash__c where id IN: dealHashIdsToClearStage];
        if(dealhashlist != null && dealhashlist.size() > 0){
            for(Deal_Hash__c dhl : dealhashlist){
                dhl.Contract_Renewal_Stage__c = null;
                updateDhlist.add(dhl);
            }    
        }
        
        if(updateDhlist!= null && updateDhlist.size() >0){
            update updateDhlist;
        }
    }  
}