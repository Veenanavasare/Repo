/*
Component Name :API_RDSValidationTriggerHandler
Requirement/User Story Number :US367115
Requirement Description:Update Record count of VLAN info records on RDS-Circuit and VLAN details
Component Author:Accenture IDC
Created Date:20th Nov 2014
Version:1.0
*/

/* 
 Name: SITriggerOperations.SITriggerImpl
 Type: Class 
 
 Description: 
 */ 
public with sharing class API_RDSValidationTriggerHandler extends SITriggerOperations.SITriggerImpl{
    
    /*  public override boolean onBeforeInsert (SObject[] newObjects)
{
try
{        

}
catch (exception e)
{
e.getMessage();
}
return true;
} */
    /*Will be used for future refence in case of any BeforeUpdate Operations  */  
    public override boolean onBeforeUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap)
    {
        try
        {
            updatePortMBCOnUBBChange(oldObjects,updatedObjects);
            populateWorkActionListonVAlidations(oldObjects,updatedObjects);   
        }
        catch (exception e)
        {
            e.getMessage();
        }
        return true;
    }       
    /* To be used for Future after insert operations*/
     public override boolean onAfterInsert (SObject[] newObjects)
    {
      
        if(newObjects.size()>0){
        try
        {   
        createSharingrule(newObjects);
        }
        catch (exception e)
        {
        e.getMessage();
        }
        }
        return true;
        }  
    /*To be used for Future After Update Operations*/
    public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] updatedObjects,Map<Id, SObject>  OldObjectsMap)
    {
        try
        {
            if(ATTConstants.recursiveCheckOnRDSValidationTriggerHandler == false) {
                
                createMACDOnChange(oldObjects, updatedObjects); 
            }
            ATTConstants.recursiveCheckOnRDSValidationTriggerHandler = true;
        }
        catch (exception e)
        {
            e.getMessage();
        }
        return true;
    }  
    
    
    /* Method to create MACD Opportunity + Related objects when change is performed */  
/* 
 Name: createMACDOnChange
 Description: 
 */ 
    public void createMACDOnChange(SObject[] oldObjects, SObject[] updatedObjects){
    
        List<RDS_Validation__c> oldValidationList = oldObjects;
        List<RDS_Validation__c> validationList = updatedObjects;
        Map<String,RDS_Validation__c> premiseValMap = new Map<String,RDS_Validation__c>();
        String stat = SpecialCharacterBuyFlowConstant.CONCAT;
        string portalmacdaction = SpecialCharacterBuyFlowConstant.CONCAT;
        Set<String> premiseIdSet = new Set<String>();
        Set<Id> macdPremiseIdSet = new Set<Id>();
        List<RDS_Premise_Details__c> premList = new List<RDS_Premise_Details__c>();
        List<RDS_Premise_Details__c> oldpremUpdateList = new List<RDS_Premise_Details__c>();
        Set<String> dealHIds = new Set<String>();
        Set<String> addPremise = new Set<String>();
        Set<String> opptyIdSet = new Set<String>();
        Map<String,RDS_Premise_Details__c> premSiteMap = new Map<String,RDS_Premise_Details__c>();
        List<Deal_Hash__c> dhList = new List<Deal_Hash__c>();
        Decimal version; // Current version that is incremented by 1 on each Change
        Id dhId;  // Master Deal Hash to which all Premise are associated
        Map<String, Deal_Hash__c> dhMap = new Map<String, Deal_Hash__c>();
        String masterOppId;
        Map<String,SPProduct__c> spMap = new Map<String,SPProduct__c>();  // Ids of SP Product records associated to the Master Opty
        Map<String,SPProduct__c> spMapAdd = new Map<String,SPProduct__c> (); //Ids of SP Product records associated to the Add MACD Opty
        Integer bid = null;
        List<Opportunity> mACDOptyList = new List<Opportunity>(); // List of cloned Optys after MACD
        List<SPProduct__c> cloneSPPrList = new List<SPProduct__c>();  //List of SP Product records to be cloned during MACD
        List<SPProduct__c> cloneAddSPPrList = new List<SPProduct__c>();  //List of Add SP Product records to be cloned during MACD
        List<SPProduct__c> clonedSPIdList = new List<SPProduct__c>(); // Ids of cloned SP Products
        List<SPProduct__c> clonedAddSPIdList = new List<SPProduct__c>(); // Ids of cloned Add SP Products
        List<Product_Pricing__c> pprIdList = new List<Product_Pricing__c>(); // Ids of Product Pricing records associated to the Master Opty
        List<Product_Pricing__c> pprIdAddList = new List<Product_Pricing__c>(); // Ids of Product Pricing records associated to the Add Opty
        List<Product_Pricing__c> clonePPrList = new List<Product_Pricing__c>();  //List of Product Pricing records to be cloned during MACD
        List<Product_Pricing__c> cloneAddPPrList = new List<Product_Pricing__c>();  //List of Add Product Pricing records to be cloned during MACD
        List<RDS_Premise_Details__c> mACDPremList = new List<RDS_Premise_Details__c>(); // List of cloned Premise after MACD
        List<Circuit_and_VLAN_Details__c> cvlanList = new List<Circuit_and_VLAN_Details__c>();
        List<RDS_Premise_Details__c> clonedPremIdList = new List<RDS_Premise_Details__c>();
        List<Circuit_and_VLAN_Details__c> clonecvlanList = new List<Circuit_and_VLAN_Details__c>();  //List of CVLAN records to be cloned during MACD
        Set<Id> masterCVLANIdSet = new Set<Id>();
        Set<Id> macdCVLANIdSet = new Set<Id>();
        List<RDS_BillingRelatedElements__c> cloneBillList = new List<RDS_BillingRelatedElements__c>();  //List of Billing records to be cloned during MACD
        List<RDS_Contact__c> cloneConList = new List<RDS_Contact__c>();  //List of Contact records to be cloned during MACD
        List<RDS_Competitive_Discount__c> cloneCompDiscList = new List<RDS_Competitive_Discount__c>();  //List of Competitive Discount records to be cloned during MACD
        List<Deal_Hash__c> dhUpdateList = new List<Deal_Hash__c>();     
        Set<Id> ppSetIds = new Set<Id>();
        Set<String> beidSet = new Set<String>();
        Set<String> pbinumberSet = new Set<String>();
        Set<String> deterSet = new Set<String>();
        Set<String> lowlevelSet = new Set<String>();
        Set<Id> optyIdSet = new Set<Id>();
        Map<String,String> premChangeTypeMap = new Map<String,String>();
        list <Rates__c> rateList = new list<Rates__c>();
        Set<String> dealRatePlanIdSet = new Set<String>();
        Map<String,Product_Pricing__c> premMACDPPMap = new Map<String,Product_Pricing__c>();
        List<Product_Pricing__c> newListToUpdate = new List<Product_Pricing__c>();
        Map<String, Rates__c> ratesmap = new Map<String, Rates__c>();
        Set<Id> valIds = new Set<Id>();
        Map<String,Product_Pricing__c> premMACDOLDPPMap = new Map<String,Product_Pricing__c>();
        Map<String,Integer> premValConfigMap = new Map<String,Integer>();
        Map<String,String> premValNonUnilinkVlanIdMap = new Map<String,String>();
        Map<String,Product_Pricing__c> pprecmap = new Map<String,Product_Pricing__c>();
        Map<String,COS_Value__c> misCosMap = new Map<String,COS_Value__c>();
        Map<String,COS_Value__c> avpnCosMap = new Map<String,COS_Value__c>();
        Id rtypeId;
        String masterDealratePlan;
        //ApttusServiceUtilityHelper  aptus = new ApttusServiceUtilityHelper ();
        
        String pricingRecord;
        List<RDS_Validation__c > vallist = new List<RDS_Validation__c>();
        Id newMACDOptyId;
        List<Product_Pricing__c> ppnewPorthistorylist= New List<Product_Pricing__c>();
        Map<Decimal,Product_Pricing__c> mapHistry= New Map<Decimal,Product_Pricing__c>();
        Map<Id,RDS_Validation_Configuration__c> vlanconfigmap = New Map<Id,RDS_Validation_Configuration__c>();
        List<RDS_Validation_Configuration__c> configlists = New List<RDS_Validation_Configuration__c>();
        List<Product_Pricing__c> pplists = new List<Product_Pricing__c>();
        Map<String,Product_Pricing__c> ppmap = New Map<String,Product_Pricing__c>();
        List<RDS_Validation__c> rdsvallist = new List<RDS_Validation__c>();
        List<Apttus_Proposal__Proposal__c> apptuslist = new List<Apttus_Proposal__Proposal__c>();
        Integer upgrade = 5;
        Boolean isAccessSpeedUpgradeFromT1 = false; //Holds true when access speed upgrade from T1 to nT1, holds false in other cases
        Boolean isAccessSpeedDowngradeToT1 = false; //Holds true when access speed downgrade to T1 from nT1, holds false in other cases
        Integer oldPortSpeedNum;
        Integer newPortSpeedNum;
        String oldPortSpeed;
        String newPortSpeed;
        String subOldPortSpeed;
        String subNewPortSpeed;
        String subOldAccessSpeed;
        String subNewAccessSpeed;
        Integer upgradeVal;
        Integer downgradeVal;
        Boolean isInterfaceChange = false;
        Boolean isEthernetAccessChange = false;
        Integer cktCount = 1;
        Integer cktMLPP = 1;
        Decimal newVersion;
        String dealHashId;
        Integer oldAccessSpeedNum;
        Integer newAccessSpeedNum;
        String oldAccessSpeed;
        String newAccessSpeed;
        Boolean isSEPortChange = false;
        Boolean isSEAccessChange = false;
        String interfacetype;
        String interfacetypeselected;
        String accessspeedvalue;
        Boolean relatedQuotePresent= false;
        String quoteOrderName;
        String macdDealReg;     
        String macdQuote;
        boolean isExecuted=false;
        String nonUnilinkVlanId;
        String portString;
        String groupPortString;
        ID quoteId;
        List<RDS_Validation__c> valListQuote= New List<RDS_Validation__c>();
        for(RDS_Validation__c oldRdsVal : oldValidationList){
            for(RDS_Validation__c rdsVal : validationList){
                if( String.valueOf(oldRdsVal.Status__c) != String.valueOf(rdsVal.Status__c) && String.valueOf(rdsVal.Status__c) == BuyFlowConstant.SUBMITTED1){
                    if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.ADDVLAN){
                        stat = BuyFlowConstant.ADD;
                    } else if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.DISCONNECTVLAN){
                        stat = BuyFlowConstant.DISCONNECT;
                    } else if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.UBBADD){
                        stat = BuyFlowConstant.UBBADD1;
                    } else if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.UBBCHANGE){
                        stat = BuyFlowConstant.UBBCHANGE1;
                    } else if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.UBBREMOVE){
                        stat = BuyFlowConstant.UBBREMOVE1;
                    } else if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.PORTSPEED_CHANGE){
                        stat = BuyFlowConstant.PORTSPEEDCHANGE;
                    } else if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.COSCHANGE){
                        stat = BuyFlowConstant.COSCHANGE1;
                    } else if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.VLANSPEED_CHANGE){
                        stat = BuyFlowConstant.VLANSPEEDCHANGE;
                    } else if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.PORTACCESS_SPEED_CHANGE){
                        stat = BuyFlowConstant.PORTACCESSSPEEDCHANGE;
                    } else if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.ADDCOS){
                        stat = BuyFlowConstant.COSADD;
                    } else if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.REMOVECOS){
                        stat = BuyFlowConstant.COSREMOVE2;
                    }    
                    if(rdsVal.Related_quote__c!=null && rdsVal.Related_quote__c!=SpecialCharacterBuyFlowConstant.CONCAT ){
                        
                        if (rdsVal.MACD_Change_Type__c ==BuyFlowConstant.UBBADD || rdsVal.MACD_Change_Type__c ==BuyFlowConstant.UBBCHANGE|| rdsVal.MACD_Change_Type__c ==BuyFlowConstant.UBBREMOVE || rdsVal.MACD_Change_Type__c ==BuyFlowConstant.PORTACCESS_SPEED_CHANGE || stat == BuyFlowConstant.PORTACCESSSPEEDCHANGE || stat == BuyFlowConstant.COSADD || stat == BuyFlowConstant.COSREMOVE2){
                            portalmacdaction = BuyFlowConstant.PORTALMACD;
                        }
                        else{
                            portalmacdaction=BuyFlowConstant.NONUBBMACD;  
                        }
                        relatedQuotePresent=true;
                        quoteId=rdsVal.Related_quote__c;
                        quoteOrderName=rdsVal.QuoteName__c;
                        macdQuote = rdsVal.RelatedQuote__c;
                    }
                    if(rdsVal.isAtom__c || rdsVal.isBid__c){
                        isExecuted=true; 
                    }
                    
                    premChangeTypeMap.put(rdsVal.Premise_Number__c,stat);
                    premiseIdSet.add(rdsVal.Premise__c);
                    macdPremiseIdSet.add(rdsVal.Premise__c);
                    premiseValMap.put(rdsVal.Premise_Number__c, rdsVal);
                    valIds.add(rdsVal.Id);
                    if(stat == BuyFlowConstant.PORTACCESSSPEEDCHANGE){
                        oldPortSpeed = rdsVal.Existing_Port_Speed_Technical__c;
                        newPortSpeed = rdsVal.New_Port_Speed_Technical__c;
                        
                        oldAccessSpeed = rdsVal.Existing_Access_Speed_Technical__c;
                        newAccessSpeed = rdsVal.New_Access_Speed_Technical__c;
                        
                        if(rdsVal.Transport_Type__c.contains(BuyFlowConstant.T1)){
                            if(String.isNotBlank(oldPortSpeed)){
                                if(oldPortSpeed.substring(0,1) == BuyFlowConstant.T){
                                    oldPortSpeedNum = 1;
                                } else{
                                    subOldPortSpeed = oldPortSpeed.substring(0,oldPortSpeed.indexOf('x'));
                                    oldPortSpeedNum = Integer.valueOf(subOldPortSpeed); 
                                }
                            }
                            if(String.isNotBlank(newPortSpeed)){
                                if(newPortSpeed.substring(0,1) == BuyFlowConstant.T){
                                    newPortSpeedNum = 1;
                                } else{
                                    subNewPortSpeed = newPortSpeed.substring(0,newPortSpeed.indexOf('x'));
                                    newPortSpeedNum = Integer.valueOf(subNewPortSpeed);  
                                }
                            }
                            if(String.isNotBlank(oldAccessSpeed)){
                                if(oldAccessSpeed.substring(0,1) == BuyFlowConstant.T){
                                    oldAccessSpeedNum = 1;
                                } else{
                                    subOldAccessSpeed = oldAccessSpeed.substring(0,oldAccessSpeed.indexOf('x'));
                                    oldAccessSpeedNum = Integer.valueOf(subOldAccessSpeed); 
                                }
                            }
                            if(String.isNotBlank(newAccessSpeed)){
                                if(newAccessSpeed.substring(0,1) == BuyFlowConstant.T){
                                    newAccessSpeedNum = 1;
                                } else{
                                    subNewAccessSpeed = newAccessSpeed.substring(0,newAccessSpeed.indexOf('x'));
                                    newAccessSpeedNum = Integer.valueOf(subNewAccessSpeed);
                                }  
                            }
                            if(oldPortSpeedNum < newPortSpeedNum){
                                upgrade = 1;
                                upgradeVal = newPortSpeedNum - oldPortSpeedNum;
                            } else if(oldPortSpeedNum > newPortSpeedNum){
                                upgrade = 0;
                                downgradeVal = oldPortSpeedNum - newPortSpeedNum;
                            }
                            if(oldAccessSpeedNum < newAccessSpeedNum){
                                cktMLPP = newAccessSpeedNum;
                                if( oldAccessSpeedNum == 1 ){ // Added as part of US533343, US533344
                                    isAccessSpeedUpgradeFromT1 = true;
                                }
                            } else if(oldAccessSpeedNum > newAccessSpeedNum){
                                if(newAccessSpeedNum > 1){      
                                    cktMLPP = oldAccessSpeedNum - newAccessSpeedNum;                                       
                                } else { 
                                    if ( newAccessSpeedNum == 1 ){
                                        isAccessSpeedDowngradeToT1 = true;
                                    }
                                    cktMLPP = oldAccessSpeedNum;
                                }
                            }
                            cktCount = newAccessSpeedNum;
                        }
                        
                        else if(rdsVal.Transport_Type__c.contains(BuyFlowConstant.ETHERNET)) {
                            
                            if(String.isNotBlank(oldPortSpeed)){
                                subOldPortSpeed = oldPortSpeed.substring(0,oldPortSpeed.indexOf(SpecialCharacterBuyFlowConstant.BLANK));
                                oldPortSpeedNum = Integer.valueOf(subOldPortSpeed); 
                            }
                            if(String.isNotBlank(newPortSpeed)){
                                subNewPortSpeed = newPortSpeed.substring(0,newPortSpeed.indexOf(SpecialCharacterBuyFlowConstant.BLANK));
                                newPortSpeedNum = Integer.valueOf(subNewPortSpeed);  
                            }
                            if(String.isNotBlank(oldAccessSpeed)){
                                subOldAccessSpeed = oldAccessSpeed.substring(0,oldAccessSpeed.indexOf(SpecialCharacterBuyFlowConstant.BLANK));
                                oldAccessSpeedNum = Integer.valueOf(subOldAccessSpeed); 
                            }
                            if(String.isNotBlank(newAccessSpeed)){
                                subNewAccessSpeed = newAccessSpeed.substring(0,newAccessSpeed.indexOf(SpecialCharacterBuyFlowConstant.BLANK));
                                newAccessSpeedNum = Integer.valueOf(subNewAccessSpeed);  
                            }
                            
                            if(oldPortSpeedNum < newPortSpeedNum){
                                upgrade = 1;
                                upgradeVal = newPortSpeedNum - oldPortSpeedNum;
                                isEthernetAccessChange = true;
                            } else if(oldPortSpeedNum > newPortSpeedNum){
                                upgrade = 0;
                                downgradeVal = oldPortSpeedNum - newPortSpeedNum;
                                isEthernetAccessChange = true;
                            }else if(oldPortSpeedNum==newPortSpeedNum){
                                upgrade = 0;
                                isEthernetAccessChange = true;// Defect 83670 Fix put for Ethernet to nT1
                            }
                            if(oldPortSpeedNum != newPortSpeedNum){
                                isSEPortChange = true;
                            }
                            if(oldAccessSpeedNum != newAccessSpeedNum){
                                isSEAccessChange = true;
                            }
                        }
                        // Fix added for defect 26872 -vineet
                        if( (rdsVal.Current_Interface_Type__c != rdsVal.Interface_Type__c) && rdsVal.Current_Interface_Type__c != BuyFlowConstant.NONE){
                            isInterfaceChange = true;
                        }
                    }
                    
                }
            }
        }
        if(!valIds.isEmpty() && valIds.size()>0 ){
            //Added to call backend macd quote creation methods
            
            Map<String,RDS_Validation__c> mapValQuote = new Map<String,RDS_Validation__c>();
            valListQuote=[Select Premise_Number__c,RelatedQuote__c,(Select Id, VLANID__c from RDS_Validation_Configurations__r) from RDS_Validation__c where Id IN:valIds];
            if(!relatedQuotePresent  && macdPremiseIdSet.size()>0 && isExecuted){
                BackendMACDQuoteCreation.createquote(macdPremiseIdSet);
                for(RDS_Validation__c rval:valListQuote){
                    mapValQuote.put(rval.Premise_Number__c,rval);
                }
            }      
            
            if(valIds.size()>0){
 
                for(RDS_Validation__c vl : [Select Id, Premise__c, Premise_Number__c, (Select Id, VLANID__c,MACD_Change_Feature__c from RDS_Validation_Configurations__r  where (MACD_Change_Feature__c = 'Vlan Add' OR MACD_Change_Feature__c = 'Vlan Disconnected' OR MACD_Change_Feature__c = 'UBB Add' OR MACD_Change_Feature__c = 'UBB Change' OR MACD_Change_Feature__c = 'UBB Remove')) from RDS_Validation__c where Id IN: valIds]){
                    premValConfigMap.put(vl.Premise_Number__c,vl.RDS_Validation_Configurations__r.size());
                }
                //Validation Configuration size check added to fix defect 37820
                if(valListQuote[0].RDS_Validation_Configurations__r.size() > 0){
                    for(RDS_Validation__c rdsValConf : valListQuote){
                        premValNonUnilinkVlanIdMap.put(rdsValConf.Premise_Number__c,rdsValConf.RDS_Validation_Configurations__r[0].VLANID__c); // This map will be used to procure VLAN Id in case of avpn switched ethernet
                    }
                }
            } 
            if(premiseIdSet.size()>0){
                premList = [Select Id,Name,SPuser_Email__c,Premise_Number__c, DealHash__c, RDS_Version__c, MACD_Type__c, OpptyID__c, Disconnect_Type__c, Current_Version__c, Work_Action_List__c, Transport_Type__c, Service_Type__c from RDS_Premise_Details__c where Id=: premiseIdSet];
                for(RDS_Premise_Details__c rdsP : premList){
                    dealHIds.add(rdsP.DealHash__c);
                    if(rdsP.MACD_Type__c == BuyFlowConstant.A){
                        addPremise.add(rdsP.Premise_Number__c);
                    }
                    opptyIdSet.add(rdsP.OpptyID__c);
                    premSiteMap.put(rdsP.Premise_Number__c,rdsP);
                    
                }
                
            }
            
            if(dealHIds.size()>0){ 
                dhList = [Select Id, Name, RDS_Version__c, Opportunity__c, Opportunity__r.Deal_Rate_Plan_ID__c, RDS_Version_Select__c from Deal_Hash__c Where Id = :dealHIds limit 1];
                for(Deal_Hash__c d : dhList){
                    version = d.RDS_Version__c;
                    newVersion = version + 1;
                    dhId = d.Id;
                    dhMap.put(d.Opportunity__c,d);    // Opportunity & Deal Hash Map
                }
                MasterDealratePlan=dhList[0].Opportunity__r.Deal_Rate_Plan_ID__c;
                
            }
            Opportunity oppty;
            
            if(opptyIdSet!=null){
                if(premSiteMap.size()>0){
                    SPProduct__c sproductToBeFectched =[Select Id, Site_ID__c,Deal__r.Discounted_Percentage__c, Deal__r.Id from SPProduct__c Where Deal__r.RDS_Deal_Hash__c IN:dealHIds  and  Site_ID__c =: premSiteMap.keySet() order by CreatedDate Desc Limit 1]; 
                    masterOppId=sproductToBeFectched.Deal__r.Id;
                    oppty=[Select Id,RDS_Deal_Hash__c,RDS_Deal_Hash__r.Opportunity__r.Name,Credit_Check_Status__c,Standard_Discount_Percentage__c,Custom_Deal_Reg_Percentage__c from Opportunity where ID =:masterOppId];
                }
            }
            Integer premSize;
            if(premSiteMap.size()>0){  
                //MACD is being performed for any regular premise
                premSize = premSiteMap.size();
                List<SPProduct__c> sppList=[Select Id, Site_ID__c,Deal__r.Discounted_Percentage__c, Deal__c from SPProduct__c Where Site_ID__c IN: premSiteMap.keySet()  AND  Deal__r.RDS_Deal_Hash__c IN: dealHIds AND MACD_Type__c!='A' Order by CreatedDate DESC ];
                
                Map<String,SPProduct__c> mapStrBySiteId = new Map<String,SPProduct__c>();
                for(SPProduct__c spp:sppList){    
                    if(!mapStrBySiteId .keyset().Contains(spp.Site_ID__c)){
                        mapStrBySiteId .put(spp.Site_ID__c,spp);
                    }
                    
                }
                
                for(SPProduct__c spp:mapStrBySiteId.Values()){    
                    if(!spMap.keyset().Contains(spp.Id)){
                        spMap.put(spp.Id,spp);
                    }
                }
                
                pprIdList = [Select Id, SP_Product__c, SP_Site_Id__c, Deal_Id__c,RecordType.Name,BEID__c,PBI_Number__c,Determinant_Set_ID__c,Low_Level_Tier__c,product_name__c,Deal_Rate_Plan_ID__c,Product_Detail__c,Record_Type__c,RDSVersion__c from Product_Pricing__c where SP_Product__c =: spMap.keySet() and type__c!='NRC'];
                for(Product_Pricing__c pp :pprIdList){
                    
                    if(pp.Record_Type__c == BuyFlowConstant.FEATURE || pp.Product_Detail__c == BuyFlowConstant.COSFEE){
                        
                        pprecmap.put(pp.Record_Type__c + pp.Product_Detail__c,pp);
                        PricingRecord = pp.Record_Type__c;
                    }
                }
            }
            if(String.isNotBlank(masterOppId)){
                rtypeId = [select Id,Name,SobjectType from RecordType where DeveloperName ='MACD' and SobjectType= 'Opportunity' limit 1].Id;
                
                if(portalmacdaction != BuyFlowConstant.PORTALMACD || portalmacdaction == BuyFlowConstant.NONUBBMACD)
                    
                {
                    String soqlOpty = API_Utils.getCreatableFieldsSOQL('opportunity', 'id=\''+masterOppId+'\'');    //cloning optys when disconnect is performed
                    Opportunity opp = (Opportunity)Database.query(soqlOpty);
                    Opportunity newOpp = opp.clone(false,true,true,true);
                    newOpp.RecordTypeId = rtypeId;
                    newOpp.MACD_Type__c = BuyFlowConstant.C;
                    newOpp.RDS_Version__c = version + 1;
                    newOpp.Review_Check__c = false;
                    newOpp.BackendMACDType__c=stat;
                    if(relatedQuotePresent && (stat == BuyFlowConstant.COSCHANGE1 || stat == BuyFlowConstant.DISCONNECT || stat == BuyFlowConstant.ADD || stat == BuyFlowConstant.VLANSPEEDCHANGE || stat == BuyFlowConstant.COSADD|| stat == BuyFlowConstant.COSREMOVE2)){
                        if(quoteOrderName!=null || quoteOrderName!=SpecialCharacterBuyFlowConstant.CONCAT){
                            newOpp.Name=quoteOrderName;
                        }
                    }else{
                        newOpp.Name = oppty.RDS_Deal_Hash__r.Opportunity__r.Name + SpecialCharacterBuyFlowConstant.HYPHEN + String.valueof(newOpp.RDS_Version__c);
                    }
                    newOpp.RDS_Deal_Hash__c = oppty.RDS_Deal_Hash__c;
                    newOpp.Number_of_Products__c=premSize;
                    newOpp.API_Process_Status__c = SpecialCharacterBuyFlowConstant.CONCAT;
                    newOpp.CDG_Sub_Account_Last_timestamp__c = null;
                    newOpp.CDG_Sub_Account_Status__c = SpecialCharacterBuyFlowConstant.CONCAT;
                    newOpp.Realted_Opportunity__c=masterOppId;
                    newOpp.CDG_Sub_Account_Last_Run_Error_Msg__c = SpecialCharacterBuyFlowConstant.CONCAT;
                    newOpp.Circuit_ID_USO_Last_timestamp__c = null;
                    newOpp.Circuit_ID_USO_Status__c = SpecialCharacterBuyFlowConstant.CONCAT;
                    newOpp.Circuit_ID_USO_Last_Run_Error_Msg__c = SpecialCharacterBuyFlowConstant.CONCAT;
                    newOpp.SA_Contract_Subscription_Last_Time_Stamp__c = null;
                    newOpp.SA_Contract_Subscription_Status__c = SpecialCharacterBuyFlowConstant.CONCAT;
                    newOpp.SA_Contract_Subscription_Error_Msg__c = SpecialCharacterBuyFlowConstant.CONCAT;
                    newOpp.Deal_Rate_Plan_Last_Time_Stamp__c = null;
                    newOpp.Deal_Rate_Plan_Status__c = SpecialCharacterBuyFlowConstant.CONCAT;
                    newOpp.Deal_Rate_Plan_Error_Msg__c = SpecialCharacterBuyFlowConstant.CONCAT;   
                    newOpp.MD5_Status__c = SpecialCharacterBuyFlowConstant.CONCAT;
                    newOpp.MD5_Last_Time_Stamp__c = null;
                    newOpp.ContersignedDate__c = null; // added for credit check US- Vineet
                    newOpp.MD5_Error_Msg__c = SpecialCharacterBuyFlowConstant.CONCAT; 
                    newOpp.Is_MD5_Call_Required__c = false;
                    newOpp.MACD_Update_Deal_hash_Status__c=SpecialCharacterBuyFlowConstant.CONCAT;
                    newOpp.MACD_Update_Deal_hash_Last_TimeStamp__c=null;
                    newOpp.Credit_Check_Status__c = SpecialCharacterBuyFlowConstant.CONCAT;
                    newOpp.RDS_Received_Last_Time_Stamp__c = DateTime.Now();
                    newOpp.RDS_Completion_Date__c = Date.Today();
                    newOpp.RDS_Percent_Complete__c = Decimal.valueof(100);
                    newOpp.RDS_Complete__c = True;
                    newOpp.RDS_Received_Status__c=BuyFlowConstant.SUCCESS;
                    newOpp.IsDocviewer__c = False;
                    newOpp.Manual_Pricing_Schedule_Complete__c = False;
                    newOpp.MACD_RDS_Review_Completed_Status__c = SpecialCharacterBuyFlowConstant.CONCAT;
                    newOpp.MACD_RDS_Review_Complete_LastTimeStamp__c = null;
                    newOpp.RDS_Excel_Created__c = false;
                    newOpp.RDS_Excel_status__c = SpecialCharacterBuyFlowConstant.CONCAT;
                    newOpp.RDS_Excel_failure_reason__c = SpecialCharacterBuyFlowConstant.CONCAT;
                    newOpp.Ready_for_RDS_Excel__c =SpecialCharacterBuyFlowConstant.CONCAT;
                    
                    if(relatedQuotePresent && (stat == BuyFlowConstant.COSCHANGE1 || stat == BuyFlowConstant.DISCONNECT || stat == BuyFlowConstant.ADD || stat == BuyFlowConstant.VLANSPEEDCHANGE || stat == BuyFlowConstant.COSADD || stat == BuyFlowConstant.COSREMOVE2)){
                        if(quoteOrderName!=null || quoteOrderName!=SpecialCharacterBuyFlowConstant.CONCAT){
                            newOpp.BID_ID__c=quoteOrderName.remove(SpecialCharacterBuyFlowConstant.HYPHEN);
                        }
                    }else{
                        String oppName = oppty.RDS_Deal_Hash__r.Opportunity__r.Name;
                        newOpp.BID_ID__c = oppName.remove(SpecialCharacterBuyFlowConstant.HYPHEN)+SpecialCharacterBuyFlowConstant.HYPHEN+String.valueof(newOpp.RDS_Version__c);
                    }
                    macdDealReg = newOpp.BID_ID__c;
                    newOpp.Master_deal_number__c = opp.BID_ID__c;
                    if(stat == BuyFlowConstant.VLANSPEEDCHANGE || stat==BuyFlowConstant.DISCONNECT || stat==BuyFlowConstant.ADD){
                        newOpp.MACD_Status__c = BuyFlowConstant.NEEDUSO;
                        newOpp.MACDStatus__c=BuyFlowConstant.NEEDUSO;
                        newOpp.IsCircuit_ID_USOSucess__c=false;
                    }
                    if(stat==BuyFlowConstant.PORTSPEEDCHANGE)
                    {
                        newOpp.IsCircuit_ID_USOSucess__c=false;
                    }
                    //Added for MACD Discount
                    if(oppty.Standard_Discount_Percentage__c !=null){
                        newOpp.Standard_Discount_Percentage__c=oppty.Standard_Discount_Percentage__c;
                    }
                    if(oppty.Custom_Deal_Reg_Percentage__c !=null){
                        newOpp.Custom_Deal_Reg_Percentage__c =oppty.Custom_Deal_Reg_Percentage__c ;
                    }
                    MACDOptyList.add(newOpp);
                }   
                if(MACDOptyList.size()>0){ 
                    try{
                        insert MACDOptyList;
                    }catch(Exception e){
                        ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                       
                    }
                }
            }
            if(!MACDOptyList.isEmpty())
            {
                newMACDOptyId = [Select Id from Opportunity Where Id =: MACDOptyList limit 1].Id;

                if(premiseValMap.size()>0){
                    
                    rdsvallist = [Select Id,COS_Profile_ID__c,MACD_Change_Type__c,Port_Speed__c,Premise_Number__c,Related_quote__c from RDS_Validation__c where ID IN : premiseValMap.values()];

                    if(rdsvallist[0].Related_quote__c!=null){
                        List<Apttus_Proposal__Proposal__c>  relatedquote = [select id,Apttus_Proposal__Opportunity__r.Id from Apttus_Proposal__Proposal__c where id=:rdsvallist[0].Related_quote__c];
 
                        for(Apttus_Proposal__Proposal__c app:relatedquote ){
                            app.Apttus_Proposal__Opportunity__c = MACDOptyList[0].Id;
                            app.Apttus_Proposal__Approval_Stage__c = BuyFlowConstant.ORDERSUBMITTED;    
                        }
                        if(relatedquote.size()>0){
                            update relatedquote ;
                        }
                    }
                    
                }
                if(spMap.size()>0 && newMACDOptyId!=null){          //cloning SP Product records when MACD is performed
                    for(SPProduct__c sp : spMap.values()){
                        for(RDS_Validation__c rdsvali : rdsvallist){
                            if(rdsvali.Premise_Number__c == sp.Site_ID__c){
                                String soql = API_Utils.getCreatableFieldsSOQL('SPProduct__c', 'id=\''+sp.Id+'\'');   
                                SPProduct__c spd = (SPProduct__c)Database.query(soql);
                                SPProduct__c macSP = spd.clone(false,true,true,true);
                                macSP.Deal__c = newMACDOptyId;
                                macSP.MACD_Type__c = BuyFlowConstant.C;
                                macSP.Rome_Product_ID__c = null;
                                macSp.MACD_Price_Compare__c = null;
                                macSP.RDS_Version__c = version + 1;
                                if(premChangeTypeMap.get(macSP.Site_ID__c) == 'Add'){
                                    macSP.MACD_Change_Type__c = BuyFlowConstant.ADDVLAN1;
                                    macSP.API_Process_Status__c=SpecialCharacterBuyFlowConstant.CONCAT;
                                    macSP.API_Process_Error__c=SpecialCharacterBuyFlowConstant.CONCAT;
                                    macSP.ROME_Opportunity__c = null;
                                }else if(premChangeTypeMap.get(macSP.Site_ID__c) =='Disconnect'){
                                    macSP.MACD_Change_Type__c = BuyFlowConstant.DISCONNECTVLAN1;
                                    macSP.API_Process_Status__c=SpecialCharacterBuyFlowConstant.CONCAT;
                                    macSP.API_Process_Error__c=SpecialCharacterBuyFlowConstant.CONCAT;
                                    macSP.ROME_Opportunity__c = null;
                                }else if(premChangeTypeMap.get(macSP.Site_ID__c) =='UBBAdd'){
                                    macSP.MACD_Change_Type__c = 'UBB Add';
                                } else if(premChangeTypeMap.get(macSP.Site_ID__c) =='UBBChange'){
                                    macSP.MACD_Change_Type__c = 'UBB Change';
                                } else if(premChangeTypeMap.get(macSP.Site_ID__c) =='UBBRemove'){
                                    macSP.MACD_Change_Type__c = 'UBB Remove';
                                } else if(premChangeTypeMap.get(macSP.Site_ID__c) =='CoSChange'){
                                    macSP.MACD_Change_Type__c = 'CoS Change';
                                    macSP.ROME_Opportunity__c = null;
                                } else if(premChangeTypeMap.get(macSP.Site_ID__c) =='PortSpeedChange'){
                                    macSP.MACD_Change_Type__c = BuyFlowConstant.PORTSPEED_CHANGE;
                                    macSP.Port_Speed_Physical_Value__c = rdsvali.Port_Speed__c;
                                    macSP.Port_Speed_Name__c = rdsvali.Port_Speed__c +BuyFlowConstant.MBPS;
                                    macSP.API_Process_Status__c=SpecialCharacterBuyFlowConstant.CONCAT;
                                    macSP.API_Process_Error__c=SpecialCharacterBuyFlowConstant.CONCAT;
                                } else if(premChangeTypeMap.get(macSP.Site_ID__c) ==BuyFlowConstant.VLANSPEEDCHANGE){
                                    macSP.MACD_Change_Type__c = BuyFlowConstant.VLANSPEED_CHANGE;
                                    macSP.API_Process_Status__c=SpecialCharacterBuyFlowConstant.CONCAT;
                                    macSP.API_Process_Error__c=SpecialCharacterBuyFlowConstant.CONCAT;
                                    macSP.ROME_Opportunity__c = null;
                                } else if(premChangeTypeMap.get(macSP.Site_ID__c) == BuyFlowConstant.PORTACCESS_SPEED_CHANGE){
                                    macSP.MACD_Change_Type__c = BuyFlowConstant.PORTACCESS_SPEED_CHANGE;
                                } else if(premChangeTypeMap.get(macSP.Site_ID__c) == BuyFlowConstant.COSADD){
                                    macSP.MACD_Change_Type__c = BuyFlowConstant.COSADD1;
                                } else if(premChangeTypeMap.get(macSP.Site_ID__c) == BuyFlowConstant.COSREMOVE2){
                                    macSP.MACD_Change_Type__c = BuyFlowConstant.COSREMOVE1;
                                }
                                cloneSPPrList.add(macSP);
                            }
                        }
                    }
                }
                if(cloneSPPrList.size()>0){ 
                    try{
                        insert cloneSPPrList;
                    }catch(Exception e){
                        ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                       
                    }
                }          
                
                Decimal versionHistory; // Variable for Populating Product Pricing History details
                Decimal currentrdsversion;
                String spSiteId;
                
                if(cloneSPPrList.size()>0){
                    clonedSPIdList = [Select Id, Site_ID__c,Record_Type_Name__c,RDS_Version__c,Deal__r.Discounted_Percentage__c from SPProduct__c Where Id =: cloneSPPrList];
                    currentrdsversion=clonedSPIdList[0].RDS_Version__c;
                    spSiteId=clonedSPIdList[0].Site_ID__c;
                }          
                
                for (Rates__c rates : [select Id, BEID__c,Bill_Display_Name__c,Determinant_Set_ID__c,PBI_Number__c,Amount__c,Low_Level__c,Billing_Element__c,Rate_Plan_Id_Technical__c from Rates__c where Billing_Element__c = 'MTHLYSVC' AND RatePHIRecord__c = 'Deal Rate Card' and Rate_Plan_Id_Technical__c =:MasterDealratePlan]) {
                    ratesmap.put(rates.BEID__c+rates.Bill_Display_Name__c+rates.Rate_Plan_Id_Technical__c, rates );
                }
                
                
                List<Product_Pricing__c> pphistorylist = [Select Id,Record_Type__c,SP_Product__c,RDSVersion__c, SP_Site_Id__c, Deal_Id__c,RecordType.Name,BEID__c,PBI_Number__c,Determinant_Set_ID__c,Low_Level_Tier__c,product_name__c,Deal_Rate_Plan_ID__c, Product_Record_Type__c,Product_Detail__c from Product_Pricing__c  where  ((RecordType.Name = 'PORT') OR (RecordType.Name = 'Feature') OR (RecordType.Name = 'Access')) and SP_Product__r.Deal__r.RDS_Deal_Hash__r.Id =:dealHIds ]; 
                for(Product_Pricing__c pp:pphistorylist ){
                    premMACDOLDPPMap.put(pp.BEID__c,pp);
                }
                
                /***************************************************Logic for populating PP History***********************************************/
                
                Map<String,Product_Pricing__c> mapHistoryPortMap= New Map<String,Product_Pricing__c>();
                Map<String,Product_Pricing__c> mapHistoryFeatures= New Map<String,Product_Pricing__c>();
                Map<String,Product_Pricing__c> mapHistoryAccess= New Map<String,Product_Pricing__c>();
                List<Product_Pricing__c> ppRecordHistryDetails=[Select Id,Record_Type__c,SP_Product__c,RDSVersion__c, SP_Site_Id__c, Deal_Id__c,RecordType.Name,BEID__c,PBI_Number__c,Determinant_Set_ID__c,Low_Level_Tier__c,product_name__c,Deal_Rate_Plan_ID__c, Product_Record_Type__c,Product_Detail__c from Product_Pricing__c where SP_Product__r.Deal__r.Id =:masterOppId  and SP_Product__r.Deal__r.RDS_Deal_Hash__r.Id =:dealHIds];
                for(Product_Pricing__c ppRecord:ppRecordHistryDetails){
                    mapHistoryPortMap.put(ppRecord.Record_Type__c+ppRecord.SP_Site_Id__c,ppRecord);    
                    mapHistoryFeatures.put(ppRecord.Record_Type__c+ppRecord.Product_Detail__c+ppRecord.SP_Site_Id__c,ppRecord);
                    mapHistoryAccess.put(ppRecord.Record_Type__c+ppRecord.Product_Detail__c+ppRecord.SP_Site_Id__c,ppRecord);
                }
                /**************************************************************************************************************************************/
                
                
                //ppnewPorthistorylist = [Select Id,Record_Type__c,SP_Product__c,RDSVersion__c, SP_Site_Id__c, Deal_Id__c,RecordType.Name,BEID__c,PBI_Number__c,Determinant_Set_ID__c,Low_Level_Tier__c,product_name__c,Deal_Rate_Plan_ID__c, Product_Record_Type__c,Product_Detail__c from Product_Pricing__c where SP_Site_Id__c =: spSiteId and Record_Type__c='Port' and SP_Product__r.Deal__r.RDS_Deal_Hash__r.Id =:dealHIds order by CreatedDate Desc ]; 
                
                //List<Product_Pricing__c> ppnewCoshistorylist = [Select Id,Record_Type__c,SP_Product__c,RDSVersion__c, SP_Site_Id__c, Deal_Id__c,RecordType.Name,BEID__c,PBI_Number__c,Determinant_Set_ID__c,Low_Level_Tier__c,product_name__c,Deal_Rate_Plan_ID__c, Product_Record_Type__c,Product_Detail__c from Product_Pricing__c where SP_Site_Id__c =: spSiteId and Record_Type__c='Feature' and Product_Detail__c ='CoS Fee' and  SP_Product__r.Deal__r.RDS_Deal_Hash__r.Id =:dealHIds order by CreatedDate Desc]; 
                //List<Product_Pricing__c> ppnewVlanhistorylist = [Select Id,Record_Type__c,SP_Product__c,RDSVersion__c, SP_Site_Id__c, Deal_Id__c,RecordType.Name,BEID__c,PBI_Number__c,Determinant_Set_ID__c,Low_Level_Tier__c,product_name__c,Deal_Rate_Plan_ID__c, Product_Record_Type__c,Product_Detail__c from Product_Pricing__c where SP_Site_Id__c =: spSiteId and Record_Type__c='Feature' and Product_Detail__c = 'VLAN(s)/Logical Channel' and SP_Product__r.Deal__r.RDS_Deal_Hash__r.Id =:dealHIds order by CreatedDate Desc]; 
                
                for(Product_Pricing__c pp:pphistorylist ){
                    
                    if(!ppmap.Keyset().Contains(pp.Product_Detail__c)){
                        ppmap.put(pp.Product_Detail__c,pp);
                    }
                    
                }
                if(mapHistry.size()>0){
                    Set<Id> ppids = new Set<Id>();
                    for(Product_Pricing__c pprecs : ppmap.values()){
                        if(!ppids.Contains(pprecs.id)){
                            ppids.add(pprecs.id);
                        }
                    }
                    pplists = [Select Id,Record_Type__c,SP_Product__c,RDSVersion__c, SP_Site_Id__c, Deal_Id__c,RecordType.Name,BEID__c,PBI_Number__c,Determinant_Set_ID__c,Low_Level_Tier__c,product_name__c,Deal_Rate_Plan_ID__c, Product_Record_Type__c,Product_Detail__c from Product_Pricing__c where ID IN : ppids and type__c!='NRC'];
                }     
                if(pprIdList.size()>0 && clonedSPIdList.size()>0){
                    for(SPProduct__c spp : clonedSPIdList){
                        for(SPProduct__c sps : spMap.values()){
                            for(Product_Pricing__c pp : pprIdList){
                                
                                // Check if the validation record map is not Empty
                                
                                if(!premiseValMap.isEmpty()){   
                                    
                                    if(pp.SP_Site_Id__c == sps.Site_ID__c && spp.Site_ID__c == sps.Site_ID__c && pp.SP_Product__c == sps.Id){
                                        
                                        String soql = API_Utils.getCreatableFieldsSOQL('Product_Pricing__c','id=\''+pp.Id+'\'');   
                                        Product_Pricing__c pPr = (Product_Pricing__c)Database.query(soql);
                                        Product_Pricing__c newPP = pPr.clone(false,true,true,true);                               
                                        newPP.SP_Product__c = spp.Id;
                                        newPP.MACD_Type__c = BuyFlowConstant.C;
                                        
                                        
                                        
                                        if(pp.Product_Detail__c == BuyFlowConstant.COSFEE2){
                                            newPP.Product_Detail__c = pprecmap.get(pp.Record_Type__c+pp.Product_Detail__c).Product_Detail__c;
                                        }
                                        
                                        // Processing Logic for Port Type PP records
                                        
                                        if((pp.RecordType.Name == SIConstants.RECORDTYPEPORT) && (premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == SIConstants.UBBAdd ||  premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == SIConstants.UBBChange || premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == SIConstants.UBBRemove))                                                   
                                        {
                                            
                                            if(premiseValMap.get(PP.SP_Site_Id__c).UBB__c==SpecialCharacterBuyFlowConstant.TRUE_LITERAL){
                                                
                                                newPP.BEID__c = premiseValMap.get(PP.SP_Site_Id__c).MBC_Speed_BEID__c;
                                                newPP.product_name__c = premiseValMap.get(PP.SP_Site_Id__c ).MBC_Speed_Name__c;
                                                newPP.Physical_Value__c = premiseValMap.get(PP.SP_Site_Id__c ).MBC__c;
                                            }else {
                                                
                                                newPP.BEID__c = premiseValMap.get(PP.SP_Site_Id__c).Port_Speed_BEID__c;
                                                
                                                newPP.product_name__c = premiseValMap.get(PP.SP_Site_Id__c ).Port_Speed_Name__c;
                                            }
                                            
                                            
                                            
                                            
                                            if(!ratesmap.isEmpty() && ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c)!=null){
                                                if(newPP.BEID__c == ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).BEID__c && newPP.product_name__c == ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Bill_Display_Name__c && pp.Deal_Rate_Plan_ID__c == ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Rate_Plan_Id_Technical__c){
                                                    
                                                    newPP.Determinant_Set_ID__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Determinant_Set_ID__c;
                                                    newPP.PBI_Number__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).PBI_Number__c;
                                                    newPP.list_price__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Amount__c;
                                                    newPP.Low_Level_Tier__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Low_Level__c;
                                                    newPP.discount_price__c = SIHelper.applyRound((spMap.get(pp.SP_Product__c).Deal__r.Discounted_Percentage__c*newPP.list_price__c)/100);
                                                    newPP.discounted_price__c = newPP.list_price__c - newPP.discount_price__c;
                                                }
                                            }
                                            
                                            // rate logic ends here
                                            
                                            if( PP.SP_Site_Id__c == premiseValMap.get(PP.SP_Site_Id__c).Premise_Number__c && !mapHistoryPortMap.isEMpty() && mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c)!=null ){
                                                
                                                newPP.product_Name_History__c  =mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).product_name__c;
                                                newPP.PBI_Number_History__c = mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).PBI_Number__c;
                                                newPP.Determinant_Set_ID_History__c=mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).Determinant_Set_ID__c;
                                                newPP.BEID_History__c = mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).BEID__c;
                                                newPP.Low_Level_Tier_History__c =mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).Low_Level_Tier__c;
                                                
                                            } 
                                        }
                                        // Logic for Port PP ends here
                                        // Logic for Port Speed Change and Passing Cos Speed Name and Cos Speed BEID to the new Product Pricing Record
                                        
                                        if((premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == SIConstants.PortSpeedChange || premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == 'Port/Access Speed Change') || premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == 'CoS Change' || premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == 'VLAN Speed Change'){
                                            if(pp.RecordType.Name == SIConstants.RECORDTYPEPORT && premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c != 'CoS Change' && premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c != 'VLAN Speed Change'){
                                                newPP.BEID__c = premiseValMap.get(PP.SP_Site_Id__c).Port_Speed_BEID__c;
                                                newPP.product_name__c = premiseValMap.get(PP.SP_Site_Id__c ).Port_Speed_Name__c;
                                            }
                                            
                                            if((Newpp.Product_Detail__c == BuyFlowConstant.COSFEE2 || Newpp.Product_Detail__c == BuyFlowConstant.PORTCOS) && premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == SIConstants.PortSpeedChange){
                                                
                                                newPP.BEID__c = premiseValMap.get(PP.SP_Site_Id__c).AVPN_COS_Speed_BEID__c;
                                                newPP.product_name__c = premiseValMap.get(PP.SP_Site_Id__c).AVPN_COS_Speed_Name__c;
                                            } else if(Newpp.Product_Detail__c == 'Cos Fee' && (premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == 'CoS Change' || premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == 'VLAN Speed Change') && !mapHistoryFeatures.isEmpty() && mapHistoryFeatures.get(newPP.Record_Type__c+newPP.Product_Detail__c+newPP.SP_Site_Id__c)!=null){
                                                newPP.BEID__c = mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).BEID__c;
                                                newPP.product_name__c =mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).product_name__c;
                                            }
                                            
                                            else if((newPP.Product_Detail__c == BuyFlowConstant.VLANS_LOGICAL_CHANNEL || newPP.Product_Detail__c == BuyFlowConstant.PORTUNILINK) && premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == SIConstants.PortSpeedChange){
                                                
                                                newPP.BEID__c = premiseValMap.get(PP.SP_Site_Id__c).AVPN_Unilink_Speed_BEID__c;
                                                newPP.product_name__c = premiseValMap.get(PP.SP_Site_Id__c ).AVPN_Unilink_Speed_Name__c;
                                            }else if((Newpp.Product_Detail__c == 'VLAN(s)/Logical Channel' || newPP.Product_Detail__c == 'portUnilink') && (premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == 'VLAN Speed Change' || premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == 'CoS Change') && !mapHistoryFeatures.isEmpty() && mapHistoryFeatures.get(newPP.Record_Type__c+newPP.Product_Detail__c+newPP.SP_Site_Id__c)!=null){
                                                newPP.BEID__c =mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).BEID__c;
                                                newPP.product_name__c =mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).product_name__c;
                                            }
                                            if(newPP.BEID__c!= null && newPP.product_name__c !=null )
                                                
                                            {
                                                
                                                if(!ratesmap.isEmpty() && ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c)!=null && premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c != 'CoS Change'){
                                                    if(newPP.BEID__c == ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).BEID__c && newPP.Product_name__c == ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Bill_Display_Name__c && pp.Deal_Rate_Plan_ID__c == ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Rate_Plan_Id_Technical__c){
                                                        newPP.Determinant_Set_ID__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Determinant_Set_ID__c;                                              
                                                        newPP.PBI_Number__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).PBI_Number__c;                                            
                                                        if(pp.Record_Type__c!=BuyFlowConstant.ACCESS ){
                                                        newPP.list_price__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Amount__c;
                                                        }
                                                        newPP.Low_Level_Tier__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Low_Level__c;
                                                        newPP.discount_price__c = SIHelper.applyRound((spMap.get(pp.SP_Product__c).Deal__r.Discounted_Percentage__c*newPP.list_price__c)/100);
                                                        newPP.discounted_price__c = newPP.list_price__c - newPP.discount_price__c;
                                                    }
                                                }                                                                                                                                                     
                                            }
                                            if(premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == SIConstants.PortSpeedChange || premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == 'Port/Access Speed Change')  {
                                                
                                                if(newPP.BEID__c != mapHistoryPortMap.get(PP.Record_Type__c+PP.SP_Site_Id__c).BEID__c && pp.Record_Type__c == BuyFlowConstant.PORT && pp.SP_Site_Id__c==premiseValMap.get(PP.SP_Site_Id__c).Premise_Number__c && !mapHistoryPortMap.isEMpty() && mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c)!=null){
                                                    
                                                    newPP.product_Name_History__c =mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).product_name__c;
                                                    newPP.PBI_Number_History__c = mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).PBI_Number__c;
                                                    newPP.Determinant_Set_ID_History__c=mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).Determinant_Set_ID__c;
                                                    newPP.BEID_History__c = mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).BEID__c;
                                                    newPP.Low_Level_Tier_History__c = mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).Low_Level_Tier__c;
                                                    
                                                }else if(newPP.BEID__c == mapHistoryPortMap.get(PP.Record_Type__c+PP.SP_Site_Id__c).BEID__c){
                                                    newPP.product_Name_History__c  = SpecialCharacterBuyFlowConstant.CONCAT;
                                                    newPP.PBI_Number_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                    newPP.Determinant_Set_ID_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                    newPP.BEID_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                    newPP.Low_Level_Tier_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                    
                                                }                                    
                                            }  
                                            
                                            if(newPP.BEID__c != mapHistoryAccess.get(pp.Record_Type__c+pp.Product_Detail__c+pp.SP_Site_Id__c).BEID__c && premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c ==BuyFlowConstant.PORTACCESS_SPEED_CHANGE)  { 
                                                
                                                if(pp.Record_Type__c == BuyFlowConstant.ACCESS && pp.SP_Site_Id__c==premiseValMap.get(PP.SP_Site_Id__c).Premise_Number__c && !mapHistoryAccess.isEMpty() && mapHistoryAccess.get(pp.Record_Type__c+pp.Product_Detail__c+pp.SP_Site_Id__c)!=null){
                                                    
                                                    
                                                    newPP.product_Name_History__c =mapHistoryAccess.get(pp.Record_Type__c+pp.Product_Detail__c+pp.SP_Site_Id__c).product_name__c;
                                                    newPP.PBI_Number_History__c = mapHistoryAccess.get(pp.Record_Type__c+pp.Product_Detail__c+pp.SP_Site_Id__c).PBI_Number__c;
                                                    newPP.Determinant_Set_ID_History__c=mapHistoryAccess.get(pp.Record_Type__c+pp.Product_Detail__c+pp.SP_Site_Id__c).Determinant_Set_ID__c;
                                                    newPP.BEID_History__c = mapHistoryAccess.get(pp.Record_Type__c+pp.Product_Detail__c+pp.SP_Site_Id__c).BEID__c;
                                                    newPP.Low_Level_Tier_History__c = mapHistoryAccess.get(pp.Record_Type__c+pp.Product_Detail__c+pp.SP_Site_Id__c).Low_Level_Tier__c;
                                                    
                                                }else if(newPP.BEID__c == mapHistoryAccess.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).BEID__c){
                                                    newPP.product_Name_History__c  = SpecialCharacterBuyFlowConstant.CONCAT;
                                                    newPP.PBI_Number_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                    newPP.Determinant_Set_ID_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                    newPP.BEID_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                    newPP.Low_Level_Tier_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                    
                                                }  
                                                
                                            }   
                                            
                                            
                                            //Logic For Population of History Dection for the CoS Fee
                                            if(newPP.BEID__c != mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).BEID__c && (newPP.Product_Detail__c == BuyFlowConstant.COSFEE1 || newPP.Product_Detail__c == BuyFlowConstant.PORTCOS) && (premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == SIConstants.PortSpeedChange || premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == BuyFlowConstant.PORTACCESS_SPEED_CHANGE) && pp.Record_Type__c == BuyFlowConstant.FEATURE && pp.SP_Site_Id__c==premiseValMap.get(PP.SP_Site_Id__c).Premise_Number__c && (spp.Record_Type_Name__c == BuyFlowConstant.AVPN || spp.Record_Type_Name__c==BuyFlowConstant.MIS || spp.Record_Type_Name__c==BuyFlowConstant.AMIS)) {
                                                //if(!mapHistoryFeatures.isEmpty() && mapHistoryFeatures.get(newPP.Record_Type__c+newPP.Product_Detail__c+newPP.SP_Site_Id__c)!=null){
                                                
                                                newPP.product_Name_History__c  =mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).product_name__c;
                                                newPP.PBI_Number_History__c =mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).PBI_Number__c;
                                                newPP.Determinant_Set_ID_History__c=mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).Determinant_Set_ID__c;
                                                newPP.BEID_History__c =mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).BEID__c;
                                                newPP.Low_Level_Tier_History__c =mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).Low_Level_Tier__c;
                                                //}
                                            }  else if(newPP.BEID__c == mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).BEID__c){
                                                newPP.product_Name_History__c  = SpecialCharacterBuyFlowConstant.CONCAT;
                                                newPP.PBI_Number_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                newPP.Determinant_Set_ID_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                newPP.BEID_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                newPP.Low_Level_Tier_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                
                                            }   
                                            
                                            //End Logic For Population of History Section for the CoS Fee 
                                            
                                            //Start Logic for Population of history Section of VLAN/Logical Channel Fee 
                                            if(newPP.BEID__c != mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).BEID__c && premiseValMap.get(PP.SP_Site_Id__c).Unilink__c == 'True' && pp.SP_Site_Id__c== premiseValMap.get(PP.SP_Site_Id__c).Premise_Number__c && pp.Record_Type__c == 'Feature' && (newPP.Product_Detail__c == 'VLAN(s)/Logical Channel' || newPP.Product_Detail__c == 'portUnilink') && !mapHistoryFeatures.IsEmpty() && mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c)!=null && (spp.Record_Type_Name__c == 'AVPN' || spp.Record_Type_Name__c == 'MIS' || spp.Record_Type_Name__c == 'AMIS')){
                                                
                                                newPP.product_Name_History__c  =mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).product_name__c;
                                                newPP.PBI_Number_History__c = mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).PBI_Number__c;
                                                newPP.Determinant_Set_ID_History__c=mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).Determinant_Set_ID__c;
                                                newPP.BEID_History__c = mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).BEID__c;
                                                newPP.Low_Level_Tier_History__c =mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).Low_Level_Tier__c; 
                                                
                                            } else if(newPP.BEID__c == mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).BEID__c){
                                                newPP.product_Name_History__c  = SpecialCharacterBuyFlowConstant.CONCAT;
                                                newPP.PBI_Number_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                newPP.Determinant_Set_ID_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                newPP.BEID_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                newPP.Low_Level_Tier_History__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                                
                                            }  
                                            
                                            //End Logic for Population of history Section of VLAN/Logical Channel Fee                              
                                        } 
                                        
                                        // Logic to Check if there is matcthing Rate Card record avaialble for Matching BEID and Product Name
                                        
                                        
                                        clonePPrList.add(newPP);
                                    }
                                }
                            }
                        }
                    }
                }  
                
                
                if(clonePPrList.size()>0){ 
                    try{
                        insert clonePPrList;
                    }catch(Exception e){
                        ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                       
                    }
                    
                    
                    List<Product_Pricing__c> pplist = [Select Id,SP_Site_Id__c,list_price__c,SP_Product__r.Id,type__c, Product_Detail__c, RecordType.Name, BEID__c From Product_Pricing__c where  Id IN: clonePPrList ];
                    
                    if(pplist.size()>0){
                        for(Product_Pricing__c p : pplist){
                            premMACDPPMap.put(p.SP_Site_Id__c,p);
                        }  
                        for(SPProduct__c spp :cloneSPPrList){
                            for(Product_Pricing__c p : pplist){
                                if(p.SP_Site_Id__c== spp.Site_ID__c && spp.Id==p.SP_Product__r.Id  &&  p.RecordType.Name == BuyFlowConstant.PORT){
                                    spp.Port_Price__c=p.list_price__c;
                                }  
                            }
                        }
                        
                        AggregateResult[] groupedResults = [SELECT Sp_Product__c,Type__c, SUM(Discounted_Price__c) DiscountedPrice, SUM(List_Price__c) ListPrice, SUM(Discount_Price__c) DiscountPrice FROM Product_Pricing__c WHERE Sp_Product__c IN : cloneSPPrList GROUP BY Sp_Product__c,Type__c];          
                        
                        if(!groupedResults.isEmpty() && groupedResults!=null)
                        {
                            for(SPProduct__c sp : cloneSPPrList)
                            {
                                for(AggregateResult agr : groupedResults)
                                {
                                    if(agr.get(BuyFlowConstant.SPPRODUCT_C)==sp.Id)
                                    {
                                        if(agr.get(BuyFlowConstant.TYPE_C) == BuyFlowConstant.MRC)
                                        {
                                            sp.Discounted_Price__c=(Decimal)agr.get(BuyFlowConstant.DISCOUNTEDPRICE);
                                            sp.List_Price__c=(Decimal)agr.get(BuyFlowConstant.LISTPRICE);
                                        }
                                        else if(agr.get(BuyFlowConstant.TYPE_C) == BuyFlowConstant.NRC)
                                        {                               
                                            sp.One_Time_Revenue_Discount_Price__c=(Decimal)agr.get(BuyFlowConstant.DISCOUNTEDPRICE);
                                            sp.one_time_revenue__c=(Decimal)agr.get(BuyFlowConstant.LISTPRICE);
                                        }
                                    }
                                }
                            }
                        }
                        
                        if(cloneSPPrList.size()>0){
                            update cloneSPPrList;
                        }
                        
                        
                    }
                }
                
                
                
                if(addPremise.size()>0 && dealHIds.size()>0 ){   //Disconnect is being performed for an ADD premise
                    for(SPProduct__c s : [Select Id,Deal__r.Discounted_Percentage__c, Site_ID__c,Deal__r.RDS_Deal_Hash__c, Deal__c from SPProduct__c Where Site_ID__c =: addPremise  AND Deal__r.RDS_Deal_Hash__c IN: dealHIds AND MACD_Type__c='A' ]){
                        spMapAdd.put(s.Id, s);
                    }           
                    pprIdAddList = [Select Id,Record_Type__c,SP_Product__c,Product_Detail__c, SP_Site_Id__c,type__c, Deal_Id__c,RecordType.Name,BEID__c,PBI_Number__c,Determinant_Set_ID__c,Low_Level_Tier__c,product_name__c,Deal_Rate_Plan_ID__c from Product_Pricing__c where SP_Product__c =: spMapAdd.keySet() AND type__c != 'NRC'];
                    for(Product_Pricing__c pp :pprIdAddList){
                        premMACDOLDPPMap.put(pp.BEID__c,pp);
                    }
                    
                    if(spMapAdd.size()>0){          //cloning SP Product records when MACD is performed on an Add Premise
                        for(SPProduct__c sp : spMapAdd.values()){
                            String soql = API_Utils.getCreatableFieldsSOQL('SPProduct__c', 'id=\''+sp.Id+'\'');   
                            SPProduct__c spd = (SPProduct__c)Database.query(soql);
                            SPProduct__c macSP = spd.clone(false,true,true,true);
                            macSP.Deal__c = newMACDOptyId;
                            macSP.MACD_Type__c = BuyFlowConstant.C;
                            macSP.Rome_Product_ID__c = null;
                            macSP.RDS_Version__c = version + 1;
                            if(premChangeTypeMap.get(macSP.Site_ID__c) == 'Add'){
                                macSP.MACD_Change_Type__c = 'Add Vlan';
                            }else if(premChangeTypeMap.get(macSP.Site_ID__c) =='Disconnect'){
                                macSP.MACD_Change_Type__c = 'Disconnect Vlan';
                            } else if(premChangeTypeMap.get(macSP.Site_ID__c) =='UBBAdd'){
                                macSP.MACD_Change_Type__c = 'UBB Add';
                            } else if(premChangeTypeMap.get(macSP.Site_ID__c) =='UBBChange'){
                                macSP.MACD_Change_Type__c = 'UBB Change';
                            } else if(premChangeTypeMap.get(macSP.Site_ID__c) =='UBBRemove'){
                                macSP.MACD_Change_Type__c = 'UBB Remove';
                            } else if(premChangeTypeMap.get(macSP.Site_ID__c) =='CoSChange'){
                                macSP.MACD_Change_Type__c = 'CoS Change';
                            } else if(premChangeTypeMap.get(macSP.Site_ID__c) =='PortSpeedChange'){
                                macSP.MACD_Change_Type__c = 'Port Speed Change';
                                macSP.Port_Speed_Physical_Value__c = premiseValMap.get(macSP.Site_ID__c).Port_Speed__c;
                                macSP.Port_Speed_Name__c = premiseValMap.get(macSP.Site_ID__c).Port_Speed__c +'Mbps';
                            } else if(premChangeTypeMap.get(macSP.Site_ID__c) =='VLANSpeedChange'){
                                macSP.MACD_Change_Type__c = 'VLAN Speed Change';
                            } else if(premChangeTypeMap.get(macSP.Site_ID__c) == 'Port/Access Speed Change'){
                                macSP.MACD_Change_Type__c = 'Port/Access Speed Change';
                            } else if(premChangeTypeMap.get(macSP.Site_ID__c) == 'CoSAdd'){
                                macSP.MACD_Change_Type__c = 'CoS Add';
                            } else if(premChangeTypeMap.get(macSP.Site_ID__c) == 'CoSRemove'){
                                macSP.MACD_Change_Type__c = 'CoS Remove';
                            }
                            cloneAddSPPrList.add(macSP);
                        }
                    }
                    
                    if(cloneAddSPPrList.size()>0){ 
                        try{
                            insert cloneAddSPPrList;
                        }catch(Exception e){
                            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                            
                        }
                    }
                    
                    clonedAddSPIdList = [Select Id, Record_Type_Name__c,Site_ID__c from SPProduct__c Where Id =: cloneAddSPPrList];     
                    if(pprIdAddList.size()>0 && clonedAddSPIdList.size()>0){
                        for(RDS_Validation__c rdsval : validationList){
                            for(SPProduct__c spp : clonedAddSPIdList){
                                for(SPProduct__c sps : spMapAdd.values()){
                                    for(Product_Pricing__c pp : pprIdAddList){
                                        if(!premiseValMap.isEmpty()){
                                            if(pp.SP_Site_Id__c == sps.Site_ID__c && spp.Site_ID__c == sps.Site_ID__c && pp.SP_Product__c == sps.Id){
                                                String soql = API_Utils.getCreatableFieldsSOQL('Product_Pricing__c', 'id=\''+pp.Id+'\'');   
                                                Product_Pricing__c pPr = (Product_Pricing__c)Database.query(soql);
                                                Product_Pricing__c newPP = pPr.clone(false,true,true,true);
                                                newPP.SP_Product__c = spp.Id;
                                                newPP.MACD_Type__c = BuyFlowConstant.C;
                                                
                                                
                                                if(pp.RecordType.Name == SIConstants.RECORDTYPEPORT && (premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == SIConstants.UBBAdd ||  premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == SIConstants.UBBChange || premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == SIConstants.UBBRemove))                                                             
                                                {
                                                    if(premiseValMap.get(PP.SP_Site_Id__c).UBB__c == SpecialCharacterBuyFlowConstant.TRUE_LITERAL){
                                                        newPP.BEID__c = premiseValMap.get(PP.SP_Site_Id__c).MBC_Speed_BEID__c;
                                                        newPP.product_name__c = premiseValMap.get(PP.SP_Site_Id__c ).MBC_Speed_Name__c;
                                                        newPP.Physical_Value__c = premiseValMap.get(PP.SP_Site_Id__c ).MBC__c;
                                                    }else {
                                                        newPP.BEID__c = premiseValMap.get(PP.SP_Site_Id__c).Port_Speed_BEID__c;
                                                        newPP.product_name__c = premiseValMap.get(PP.SP_Site_Id__c ).Port_Speed_Name__c;
                                                    }
                                                    
                                                    // Logic to Check if there is matcthing Rate Card record avaialble for Matching BEID and Product Name
                                                    
                                                    if (!ratesmap.isEmpty() && ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c)!=Null ){
                                                        if(newPP.BEID__c == ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).BEID__c && newPP.product_name__c == ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Bill_Display_Name__c){
                                                            
                                                            newPP.Determinant_Set_ID__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Determinant_Set_ID__c;
                                                            newPP.PBI_Number__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).PBI_Number__c;
                                                            newPP.list_price__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Amount__c;
                                                            newPP.Low_Level_Tier__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Low_Level__c;
                                                            newPP.discount_price__c = SIHelper.applyRound((spMap.get(pp.SP_Product__c).Deal__r.Discounted_Percentage__c*newPP.list_price__c)/100);
                                                            newPP.discounted_price__c = newPP.list_price__c - newPP.discount_price__c;
                                                        }
                                                    }
                                                    // Rate logic ends here
                                                    
                                                    if(PP.SP_Site_Id__c == premiseValMap.get(PP.SP_Site_Id__c).Premise_Number__c){
                                                        newPP.product_Name_History__c  =mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).product_name__c;
                                                        newPP.PBI_Number_History__c =mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).PBI_Number__c;
                                                        newPP.Determinant_Set_ID_History__c=mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).Determinant_Set_ID__c;
                                                        newPP.BEID_History__c = mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).BEID__c;
                                                        newPP.Low_Level_Tier_History__c =mapHistoryPortMap.get(pp.Record_Type__c+pp.SP_Site_Id__c).Low_Level_Tier__c;
                                                    }
                                                }  
                                                // Logic for Port Speed Change and Passing Cos Speed Name and Cos Speed BEID to the new Product Pricing Record
                                                
                                                // Logic for Port Speed Change and Passing Cos Speed Name and Cos Speed BEID to the new Product Pricing Record
                                                
                                                if(premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == SIConstants.PortSpeedChange || premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == BuyFlowConstant.COSCHANGE || premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == BuyFlowConstant.VLANSPEED_CHANGE){
                                                    if(pp.RecordType.Name == SIConstants.RECORDTYPEPORT){
                                                        newPP.BEID__c = premiseValMap.get(PP.SP_Site_Id__c).Port_Speed_BEID__c;
                                                        newPP.product_name__c = premiseValMap.get(PP.SP_Site_Id__c ).Port_Speed_Name__c;
                                                    }
                                                    
                                                    if((Newpp.Product_Detail__c == BuyFlowConstant.COSFEE2 || Newpp.Product_Detail__c == BuyFlowConstant.PORTCOS) && pp.SP_Site_Id__c==premiseValMap.get(PP.SP_Site_Id__c).Premise_Number__c && spp.Record_Type_Name__c == BuyFlowConstant.AVPN){
                                                        
                                                        newPP.BEID__c = premiseValMap.get(PP.SP_Site_Id__c).AVPN_COS_Speed_BEID__c;
                                                        newPP.product_name__c = premiseValMap.get(PP.SP_Site_Id__c).AVPN_COS_Speed_Name__c;
                                                    }
                                                    
                                                    else if((newPP.Product_Detail__c == BuyFlowConstant.VLANS_LOGICAL_CHANNEL || newPP.Product_Detail__c == BuyFlowConstant.PORTUNILINK) && pp.SP_Site_Id__c==premiseValMap.get(PP.SP_Site_Id__c).Premise_Number__c && spp.Record_Type_Name__c == BuyFlowConstant.AVPN){
                                                        
                                                        newPP.BEID__c = premiseValMap.get(PP.SP_Site_Id__c).AVPN_Unilink_Speed_BEID__c;
                                                        newPP.product_name__c = premiseValMap.get(PP.SP_Site_Id__c ).AVPN_Unilink_Speed_Name__c;
                                                    }
                                                    if(newPP.BEID__c!= null && newPP.product_name__c !=null )
                                                        
                                                    {
                                                        
                                                        if(!ratesmap.isEmpty() && ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c)!=null){
                                                            if(newPP.BEID__c == ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).BEID__c && newPP.Product_name__c == ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Bill_Display_Name__c && pp.Deal_Rate_Plan_ID__c == ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Rate_Plan_Id_Technical__c){
                                                                
                                                                newPP.Determinant_Set_ID__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Determinant_Set_ID__c;                                              
                                                                newPP.PBI_Number__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).PBI_Number__c;                                            
                                                                if(pp.Record_Type__c!=BuyFlowConstant.ACCESS && premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == SIConstants.PortSpeedChange){
                                                                  newPP.list_price__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Amount__c;
                                                                  }
                                                                newPP.Low_Level_Tier__c = ratesmap.get(newPP.BEID__c+newPP.product_name__c+pp.Deal_Rate_Plan_ID__c).Low_Level__c;
                                                                newPP.discount_price__c = SIHelper.applyRound((spMapAdd.get(pp.SP_Product__c).Deal__r.Discounted_Percentage__c*newPP.list_price__c)/100);
                                                                newPP.discounted_price__c = newPP.list_price__c - newPP.discount_price__c;
                                                            }
                                                        }                                                                                                           
                                                        
                                                    }  
                                                    if(premiseValMap.get(PP.SP_Site_Id__c).MACD_Change_Type__c == SIConstants.PortSpeedChange)  {
                                                        
                                                        
                                                        if(pp.Record_Type__c == 'Port' && pp.SP_Site_Id__c==premiseValMap.get(PP.SP_Site_Id__c).Premise_Number__c && mapHistoryPortMap.get(PP.Record_Type__c+PP.SP_Site_Id__c)!=null && !mapHistoryPortMap.isEmpty()){
                                                            
                                                            
                                                            newPP.product_Name_History__c  =mapHistoryPortMap.get(PP.Record_Type__c+PP.SP_Site_Id__c).product_name__c;
                                                            newPP.PBI_Number_History__c = mapHistoryPortMap.get(PP.Record_Type__c+PP.SP_Site_Id__c).PBI_Number__c;
                                                            newPP.Determinant_Set_ID_History__c=mapHistoryPortMap.get(PP.Record_Type__c+PP.SP_Site_Id__c).Determinant_Set_ID__c;
                                                            newPP.BEID_History__c = mapHistoryPortMap.get(PP.Record_Type__c+PP.SP_Site_Id__c).BEID__c;
                                                            newPP.Low_Level_Tier_History__c =mapHistoryPortMap.get(PP.Record_Type__c+PP.SP_Site_Id__c).Low_Level_Tier__c;
                                                            
                                                        }
                                                        
                                                    }                                                                   
                                                    //Logic For Population of History Dection for the CoS Fee
                                                    if(newPP.BEID__c != mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).BEID__c && (newPP.Product_Detail__c == BuyFlowConstant.COSFEE || newPP.Product_Detail__c == BuyFlowConstant.PORTCOS) && pp.SP_Site_Id__c==premiseValMap.get(PP.SP_Site_Id__c).Premise_Number__c) {
                                                        
                                                        
                                                        newPP.product_Name_History__c  =mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).product_name__c;
                                                        newPP.PBI_Number_History__c =mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).PBI_Number__c;
                                                        newPP.Determinant_Set_ID_History__c=mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).Determinant_Set_ID__c;
                                                        newPP.BEID_History__c = mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).BEID__c;
                                                        newPP.Low_Level_Tier_History__c =mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).Low_Level_Tier__c;
                                                        
                                                    } 
                                                    
                                                    //End Logic For Population of History Section for the CoS Fee 
                                                    
                                                    if(premiseValMap.get(PP.SP_Site_Id__c).Unilink__c == SpecialCharacterBuyFlowConstant.TRUE_CAMEL_LITERAL && pp.SP_Site_Id__c==premiseValMap.get(PP.SP_Site_Id__c).Premise_Number__c && pp.Record_Type__c == BuyFlowConstant.FEATURE && (newPP.Product_Detail__c == BuyFlowConstant.VLANS_LOGICAL_CHANNEL || newPP.Product_Detail__c == BuyFlowConstant.PORTUNILINK) && !mapHistoryFeatures.IsEmpty() && mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c)!=null){
                                                        
                                                        
                                                        newPP.product_Name_History__c  =mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).product_name__c;
                                                        newPP.PBI_Number_History__c = mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).PBI_Number__c;
                                                        newPP.Determinant_Set_ID_History__c=mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).Determinant_Set_ID__c;
                                                        newPP.BEID_History__c = mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).BEID__c;
                                                        newPP.Low_Level_Tier_History__c =mapHistoryFeatures.get(PP.Record_Type__c+PP.Product_Detail__c+PP.SP_Site_Id__c).Low_Level_Tier__c; 
                                                        
                                                    } 
                                                    
                                                    
                                                    //End Logic for Population of history Section of VLAN/Logical Channel Fee                              
                                                }
                                                
                                                // Logic to Check if there is matcthing Rate Card record avaialble for Matching BEID and Product Name                         
                                                cloneAddPPrList.add(newPP);
                                                
                                            }
                                        }
                                    }                      
                                }
                            }  
                        }
                    } 
                    
                    if(cloneAddPPrList.size()>0){ 
                        try{
                            insert cloneAddPPrList;
                            List<Product_Pricing__c> ppAddlist = [Select Id, SP_Site_Id__c,RecordType.Name, BEID__c From Product_Pricing__c where RecordType.Name = 'Port' and Id IN: cloneAddPPrList];
                            if(ppAddlist.size()>0){
                                for(Product_Pricing__c pl : ppAddlist){
                                    premMACDPPMap.put(pl.SP_Site_Id__c,pl);
                                }    
                            }
                        }catch(Exception e){
                            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                           
                        }
                    }
                }
            }
            
            //vallist = [Select Id,Premise_Number__c,VLANID__c,Class_of_Service__c,Unilink__c,Port_Speed__c,Vlan_Speed_Total__c, Access_Speed__c, No_of_VLANS__c, Work_Action_List__c, Transport_Type__c from RDS_Validation__c where id IN : premiseValMap.values()];
            vallist = [Select Id,Premise_Number__c,VLANID__c,Class_of_Service__c,Unilink__c,Port_Speed__c,Vlan_Speed_Total__c, Access_Speed__c, No_of_VLANS__c, Work_Action_List__c, Transport_Type__c,Current_Product_Type__c,Current_Cos_Profile_ID__c,Ingress_COS_Profile_ID__c,Port_Id_Technical__c from RDS_Validation__c where id IN : premiseValMap.values()];
            //Ingress_COS_Profile_ID__c,Current_Product_Type__c,Current_Cos_Profile_ID__c
            if(vallist.size()>0){
                
                for(RDS_Validation_Configuration__c  vlanconfig : [Select Id,Workactionlist__c,Validation_Premise_Number__c,RDS_Validation__c, RDS_Validation__r.Premise__c from RDS_Validation_Configuration__c where RDS_Validation__c =: vallist[0].id LIMIT 1]){
                    
                    vlanconfigmap.put(vlanconfig.RDS_Validation__r.Premise__c,vlanconfig);
                }
            }
            
            if(String.isBlank(macdDealReg)){        
                Id quoteOpptyId = [select Apttus_Proposal__Opportunity__c from Apttus_Proposal__Proposal__c where Id =: macdQuote limit 1][0].Apttus_Proposal__Opportunity__c;     
                macdDealReg = [Select BID_ID__c from Opportunity Where Id =: quoteOpptyId limit 1][0].BID_ID__c;       
            }
            
            apptuslist = [Select id,SP_Email__c,Name from Apttus_Proposal__Proposal__c where Name =: quoteOrderName];
            
            if(premList.size()>0){          //cloning premise on which MACD is performed
                List<Circuit_and_VLAN_Details__c> cvlanVLANCKTList = [Select Id,Premise__c,(select Id,Access_Circuit_ID__c, Circuit_and_VLAN_Details__r.Premise__c from Circuit_and_VLAN_Details__r),
                                                                      (select Id from VLAN_Information__r) from Circuit_and_VLAN_Details__c where Premise__c IN :premList];
                
                for(COS_Value__c CoS : [SELECT COS_1__c, COS_2__c, COS_3__c, COS_4__c, COS_5__c, COS_6__c, Egress_COS_Profile_ID__c, Egress_PPCOS__c, Ingress_COS_Profile_ID__c, Ingress_PPCOS__c, Package_AVPN__c, Prof_E_Value__c, Product__c FROM COS_Value__c]){
                                if(CoS.Product__c == BuyFlowConstant.AVPN){
                                    avpnCosMap.put(CoS.Ingress_COS_Profile_ID__c, CoS);
                                 } else if(CoS.Product__c == BuyFlowConstant.MIS){
                                    misCosMap.put(CoS.Ingress_COS_Profile_ID__c, CoS);
                                }
                             }
                
                //changes added as part of PL upgrade/downgrade work action changes
                map<id,list<RDS_Access_Circuit_ID__c>> orgPremToCircuitIdRecsMap  = new map<id,list<RDS_Access_Circuit_ID__c>>();
                map<id,RDS_Access_Circuit_ID__c> orgPremTo801CktRecMap = new map<id,RDS_Access_Circuit_ID__c>();
                
                for(RDS_Access_Circuit_ID__c circuitIdRec : cvlanVLANCKTList[0].Circuit_and_VLAN_Details__r){
                    id orgPremiseId = circuitIdRec.Circuit_and_VLAN_Details__r.Premise__c;
                    if(orgPremToCircuitIdRecsMap.get(orgPremiseId) != null){
                        orgPremToCircuitIdRecsMap.get(orgPremiseId).add(circuitIdRec);
                    }else{
                        orgPremToCircuitIdRecsMap.put(orgPremiseId, new list<RDS_Access_Circuit_ID__c>{circuitIdRec});
                    }
                }
                
                for(id premId : orgPremToCircuitIdRecsMap.keyset()){
                    for(RDS_Access_Circuit_ID__c cRec : orgPremToCircuitIdRecsMap.get(premId)){
                        string cktID = cRec.Access_Circuit_ID__c;
                        if(cktID != null && cktID.contains(BuyFlowConstant.SIVARConst_801_x)){
                            orgPremTo801CktRecMap.put(premId,cRec);
                        }
                    }
                }
                //Changes end
                
                
                for(RDS_Premise_Details__c pr : premList){
                    for(RDS_Validation__c rdsvlai : vallist){
                        if(rdsvlai.Premise_Number__c==pr.Premise_Number__c){
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
                            macPr.MACD_Type__c = BuyFlowConstant.C;
                            macPr.RDS_Version__c = version + 1;
                            macPr.Notification_Status__c = null;
                            macPr.Push_Notification_Site_Status__c = null;
                            //Adding new field SPuser Email, that will be used in email template
                            if(apptuslist.size()>0) {
                                macpr.SPuser_Email__c = apptuslist[0].SP_Email__c;
                            }
                            macPr.Customer_Purchase_Decision_Date__c = System.Today();
                            macPr.Current_Version__c = true;
                            macPr.RelatedQuote__c=quoteId;
                            macPr.Sent_to_Grid__c = false;
                            macPr.MACD_RDS_Received_Date__c = DateTime.Now();  
                            macPr.MACD_RDS_Review_Completed_Date__c = null;     
                            macPr.MACD_Deal_Reg_Number__c = macdDealReg;
                            if(premiseValMap.containsKey(macPr.Premise_Number__c)){
                                macPr.Combined_VLAN_Speed__c = premiseValMap.get(macPr.Premise_Number__c).Vlan_Speed_Total__c;
                                if(premiseValMap.get(macPr.Premise_Number__c).QuoteName__c!=SpecialCharacterBuyFlowConstant.CONCAT && premiseValMap.get(macPr.Premise_Number__c).QuoteName__c!=null){
                                    macPr.Related_Quote_Name__c = premiseValMap.get(macPr.Premise_Number__c).QuoteName__c;   
                                }
                            }
                            if(!mapValQuote.isEmpty() && mapValQuote.get(macPr.Premise_Number__c)!=null){       
                                macPr.RelatedQuote__c = mapValQuote.get(macPr.Premise_Number__c).RelatedQuote__c;
                            }
                            if((premChangeTypeMap.get(macPr.Premise_Number__c) ==BuyFlowConstant.ADD) ||(premChangeTypeMap.get(macPr.Premise_Number__c) ==BuyFlowConstant.DISCONNECT) ||(premChangeTypeMap.get(macPr.Premise_Number__c) ==BuyFlowConstant.UBBADD1) || (premChangeTypeMap.get(macPr.Premise_Number__c) ==BuyFlowConstant.UBBCHANGE1) || (premChangeTypeMap.get(macPr.Premise_Number__c) ==BuyFlowConstant.UBBREMOVE1)){
                                macPr.Circuit_Order_Action__c = BuyFlowConstant.N1;
                                macPr.Circuit_Circuit_Action__c =BuyFlowConstant.N1;
                                macPr.Circuit_VLAN_Indicator__c =SpecialCharacterBuyFlowConstant.CONCAT;
                                macPr.Circuit_Service_Code__c =SpecialCharacterBuyFlowConstant.CONCAT;
                                macPr.Circuit_Service_Code_Modifier__c =SpecialCharacterBuyFlowConstant.CONCAT;
                                macPr.Circuit_Service_Type__c =SpecialCharacterBuyFlowConstant.CONCAT;
                                macPr.Circuit_ServiceSub_Type__c=SpecialCharacterBuyFlowConstant.CONCAT;
                                macPr.Circuit_mlppIndicator__c=SpecialCharacterBuyFlowConstant.CONCAT;
                                macPr.USO_Order_Action__c=BuyFlowConstant.A;
                                macPr.USO_VLAN__c='Y';
                                macPr.Is_Reviewed__c = false;
                                if(premValConfigMap.containsKey(macPr.Premise_Number__c)){
                                    macPr.USO_Number_of_USOS__c = premValConfigMap.get(macPr.Premise_Number__c);        
                            }
                            }
                            if(premChangeTypeMap.get(macPr.Premise_Number__c) == BuyFlowConstant.ADD){
                                macPr.MACD_Change_Type__c = BuyFlowConstant.ADDVLAN2;
                                macPr.Work_Action_List__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                macPr.Site_Status__c = BuyFlowConstant.PENDINGMACD_CHANGE;
                                macPr.Is_Reviewed__c = true;
                                macPr.IsCircuit_ID_USO_Success__c = false;
                                if(premValConfigMap.containsKey(macPr.Premise_Number__c)){
                                    macPr.USO_Number_of_USOS__c = premValConfigMap.get(macPr.Premise_Number__c);
                                }    
                            }else if(premChangeTypeMap.get(macPr.Premise_Number__c) ==BuyFlowConstant.DISCONNECT){
                                macPr.MACD_Change_Type__c = BuyFlowConstant.DISCONNECTVLAN1;
                                macPr.Site_Status__c = BuyFlowConstant.PENDINGMACD_CHANGE;
                                macPr.IsCircuit_ID_USO_Success__c = false;
                                macPr.Is_Reviewed__c = true;
                                if(premValConfigMap.containsKey(macPr.Premise_Number__c)){
                                    macPr.USO_Number_of_USOS__c = premValConfigMap.get(macPr.Premise_Number__c);
                                }
                            } else if(premChangeTypeMap.get(macPr.Premise_Number__c) ==BuyFlowConstant.UBBADD1){
                                portString = premiseValMap.get(pr.Premise_Number__c).Port_Id_Technical__c;
                                macPr.Work_Action_List__c = BuyFlowConstant.ADDUBB_x +portString;
                                macPr.MACD_Change_Type__c = BuyFlowConstant.UBBADD;
                                macPr.Is_Reviewed__c = true;
                                macPr.Site_Status__c = BuyFlowConstant.PENDINGADD_UBB;
                                macPr.Port_Speed__c = orgPr.Port_Speed__c;
                                macPr.Unilink__c =orgPr.Unilink__c;
                                macPr.Product_Type__c = orgPr.Product_Type__c;
                                macPr.VLAN_Count__c = orgPr.VLAN_Count__c;
                                macPr.Combined_VLAN_Speed__c = orgPr.Combined_VLAN_Speed__c;
                                macPr.MACD_Type__c = BuyFlowConstant.C;
                                macPr.USO_Number_of_USOS__c = orgPr.VLAN_Count__c;
                            } else if(premChangeTypeMap.get(macPr.Premise_Number__c) ==BuyFlowConstant.UBBCHANGE1){
                                portString = premiseValMap.get(pr.Premise_Number__c).Port_Id_Technical__c;
                                macPr.Work_Action_List__c = BuyFlowConstant.CHANGEMBC_x+portString;
                                macPr.MACD_Change_Type__c = BuyFlowConstant.UBBCHANGE;
                                macPr.Is_Reviewed__c = true;
                                macPr.Site_Status__c = BuyFlowConstant.PENDINGCHANGE_MBC;
                                macPr.Port_Speed__c = orgPr.Port_Speed__c;
                                macPr.Unilink__c =orgPr.Unilink__c;
                                macPr.Product_Type__c = orgPr.Product_Type__c;
                                macPr.VLAN_Count__c = orgPr.VLAN_Count__c;
                                macPr.Combined_VLAN_Speed__c = orgPr.Combined_VLAN_Speed__c;
                                macPr.MACD_Type__c = BuyFlowConstant.C;
                                macPr.USO_Number_of_USOS__c = orgPr.VLAN_Count__c;
                            } else if(premChangeTypeMap.get(macPr.Premise_Number__c) ==BuyFlowConstant.UBBREMOVE1){
                                portString = premiseValMap.get(pr.Premise_Number__c).Port_Id_Technical__c;
                                macPr.Work_Action_List__c = BuyFlowConstant.REMOVEUBB+portString;
                                macPr.MACD_Change_Type__c = BuyFlowConstant.UBBREMOVE;
                                macPr.Is_Reviewed__c = true;
                                macPr.Site_Status__c = BuyFlowConstant.PENDINGREMOVE_UBB;
                                macPr.Port_Speed__c = orgPr.Port_Speed__c;
                                macPr.Unilink__c =orgPr.Unilink__c;
                                macPr.Product_Type__c = orgPr.Product_Type__c;
                                macPr.VLAN_Count__c = orgPr.VLAN_Count__c;
                                macPr.Combined_VLAN_Speed__c = orgPr.Combined_VLAN_Speed__c;
                                macPr.MACD_Type__c = BuyFlowConstant.C;
                                macPr.USO_Number_of_USOS__c = orgPr.VLAN_Count__c;

                            } else if(premChangeTypeMap.get(macPr.Premise_Number__c) ==BuyFlowConstant.PORTSPEEDCHANGE && (rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL || rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.CONCAT ||rdsvlai.Unilink__c == null)){
                                /*portString = premiseValMap.get(pr.Premise_Number__c).Port_Id_Technical__c;
                                macPr.Work_Action_List__c = BuyFlowConstant.CHANGEPORTSPEED+portString;*/
                                //Code changes as part of US
                                
                                if(premValNonUnilinkVlanIdMap.size()>0){
                                    nonUnilinkVlanId = premValNonUnilinkVlanIdMap.get(pr.Premise_Number__c);
                                }
                                portString = premiseValMap.get(pr.Premise_Number__c).Port_Id_Technical__c;
                                if(rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL || rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.CONCAT ||rdsvlai.Unilink__c == null){
                                    if(macPr.Transport_Type__c == BuyFlowConstant.T1 || macPr.Transport_Type__c == BuyFlowConstant.NT1){
                                        macPr.Work_Action_List__c = BuyFlowConstant.CHANGEPORTSPEED+portString;
                                    } 
                                    else if(macPr.Transport_Type__c == BuyFlowConstant.ETHERNET || macPr.Transport_Type__c == BuyFlowConstant.SWITCHEDETHERNET1){
                                        macPr.Work_Action_List__c = BuyFlowConstant.CHANGEPORTSPEED+portString+SpecialCharacterBuyFlowConstant.TIDE+BuyFlowConstant.CHANGEVLANSPEED+nonUnilinkVlanId;
                                    }
                                }
                                macPr.MACD_Change_Type__c = BuyFlowConstant.PORTSPEED_CHANGE;
                                macPr.Is_Reviewed__c = true;
                                macPr.Site_Status__c = BuyFlowConstant.PENDINGSPEED_CHANGE;
                                macPr.Port_Speed__c = rdsvlai.Port_Speed__c;
                                macPr.Unilink__c =orgPr.Unilink__c;
                                macPr.Product_Type__c = orgPr.Product_Type__c;
                                macPr.VLAN_Count__c = orgPr.VLAN_Count__c;
                                //Added as part of defect id 86750
                                if(rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL || rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.FALSE_CAMEL_LITERAL){
                                    macPr.Combined_VLAN_Speed__c = Decimal.valueOf(rdsvlai.Port_Speed__c);
                                } 
                                else {
                                    macPr.Combined_VLAN_Speed__c = orgPr.Combined_VLAN_Speed__c;
                                } 
                                //macPr.Combined_VLAN_Speed__c = orgPr.Combined_VLAN_Speed__c;
                                macPr.MACD_Type__c = BuyFlowConstant.C;
                            }  else if(premChangeTypeMap.get(macPr.Premise_Number__c) ==BuyFlowConstant.PORTSPEEDCHANGE && rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.TRUE_LITERAL){
                                portString = premiseValMap.get(pr.Premise_Number__c).Port_Id_Technical__c;
                                macPr.Work_Action_List__c = BuyFlowConstant.CHANGEPORTSPEED+portString;
                                macPr.MACD_Change_Type__c = BuyFlowConstant.PORTSPEED_CHANGE;
                                macPr.Is_Reviewed__c = true;
                                macPr.Site_Status__c = BuyFlowConstant.PENDINGMACD_CHANGE;
                                macPr.Port_Speed__c = orgPr.Port_Speed__c;
                                macPr.Unilink__c =orgPr.Unilink__c;
                                macPr.Product_Type__c = orgPr.Product_Type__c;
                                macPr.VLAN_Count__c = orgPr.VLAN_Count__c;
                                macPr.Combined_VLAN_Speed__c = orgPr.Combined_VLAN_Speed__c;
                                macPr.MACD_Type__c = BuyFlowConstant.C;         
                            }  else if(premChangeTypeMap.get(macPr.Premise_Number__c) ==Constant.API_RDSValidationTriggerHandler_CoSChangeLabel){
                                portString = premiseValMap.get(pr.Premise_Number__c).Port_Id_Technical__c;
                                groupPortString = premiseValMap.get(pr.Premise_Number__c).Group_Port_Id__c;
                                nonUnilinkVlanId = premValNonUnilinkVlanIdMap.get(pr.Premise_Number__c);
                                if(rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL || rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.CONCAT|| rdsvlai.Unilink__c == null){
                                     if(rdsvlai.Transport_Type__c != BuyFlowConstant.SWITCHEDETHERNET1){
                                       macPr.Work_Action_List__c = Constant.API_RDSValidationTriggerHandler_ChangeCOSLabel+groupPortString;
                                     }else{
                                        if(rdsvlai.Current_Product_Type__c==Constant.Api_Macd_VlanChange_MIS){
                                        if(misCosMap.get(rdsvlai.Current_Cos_Profile_ID__c).Package_AVPN__c !=null && misCosMap.get(rdsvlai.Ingress_COS_Profile_ID__c).Package_AVPN__c !=null ){
                                            if(misCosMap.get(rdsvlai.Current_Cos_Profile_ID__c).Package_AVPN__c == misCosMap.get(rdsvlai.Ingress_COS_Profile_ID__c).Package_AVPN__c ){
                                                macPr.Work_Action_List__c =Constant.API_RDSValidationTriggerHandler_ChangeCOSLabel+nonUnilinkVlanId;
                                            }
                                            else{
                                                macPr.Work_Action_List__c = Constant.API_RDSValidationTriggerHandler_ChangeCOSLabel+rdsvlai.Port_Id_Technical__c+'~'+'ChangeCOS|'+nonUnilinkVlanId;
                                            }
                                        }
                                    }
                                    if(rdsvlai.Current_Product_Type__c==Constant.AVPN ){
                                        if(avpnCosMap.get(rdsvlai.Current_Cos_Profile_ID__c).Package_AVPN__c != null && avpnCosMap.get(rdsvlai.Ingress_COS_Profile_ID__c).Package_AVPN__c != null){
                                            if(avpnCosMap.get(rdsvlai.Current_Cos_Profile_ID__c).Package_AVPN__c == avpnCosMap.get(rdsvlai.Ingress_COS_Profile_ID__c).Package_AVPN__c ){
                                                macPr.Work_Action_List__c =Constant.API_RDSValidationTriggerHandler_ChangeCOSLabel+nonUnilinkVlanId;
                                            }
                                            else{
                                                macPr.Work_Action_List__c = Constant.API_RDSValidationTriggerHandler_ChangeCOSLabel+rdsvlai.Port_Id_Technical__c+SpecialCharacterBuyFlowConstant.TIDE+Constant.API_RDSValidationTriggerHandler_ChangeCOSLabel+nonUnilinkVlanId;
                                            }
                                        }   
                                    }
                                    
                                    }
                                }
                                if(rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.TRUE_LITERAL && rdsvlai.Transport_Type__c == BuyFlowConstant.SWITCHEDETHERNET1){
                                    
                                    macPr.Work_Action_List__c = rdsvlai.Work_Action_List__c;
                                    
                                }
                                macPr.MACD_Change_Type__c = BuyFlowConstant.COSCHANGE;
                                macPr.Is_Reviewed__c = true;
                                macPr.Site_Status__c = BuyFlowConstant.PENDINGCHANGE_COS;
                                macPr.Port_Speed__c = orgPr.Port_Speed__c;
                                macPr.Unilink__c =orgPr.Unilink__c;
                                macPr.Product_Type__c = orgPr.Product_Type__c;
                                macPr.VLAN_Count__c = orgPr.VLAN_Count__c;
                                macPr.Combined_VLAN_Speed__c = orgPr.Combined_VLAN_Speed__c;
                                macPr.MACD_Type__c = BuyFlowConstant.C;
                            } else if(premChangeTypeMap.get(macPr.Premise_Number__c) ==BuyFlowConstant.VLANSPEEDCHANGE){
                                portString = premiseValMap.get(pr.Premise_Number__c).Port_Id_Technical__c;
                                if(macPr.Work_Action_List__c == null){
                                    macPr.Work_Action_List__c = vlanconfigmap.get(orgPr.Id).Workactionlist__c;
                                } else {
                                    macPr.Work_Action_List__c = macPr.Work_Action_List__c+SpecialCharacterBuyFlowConstant.TIDE+vlanconfigmap.get(orgPr.Id).Workactionlist__c;
                                } 
                                macPr.MACD_Change_Type__c = BuyFlowConstant.VLANSPEED_CHANGE;
                                macPr.Is_Reviewed__c = false;
                                macPr.IsCircuit_ID_USO_Success__c = false;
                                macPr.Site_Status__c = BuyFlowConstant.PENDINGMACD_CHANGE;
                                macPr.Port_Speed__c = orgPr.Port_Speed__c;
                                macPr.Unilink__c =orgPr.Unilink__c;
                                macPr.Product_Type__c = orgPr.Product_Type__c;
                                macPr.VLAN_Count__c = orgPr.VLAN_Count__c;
                                macPr.Combined_VLAN_Speed__c = rdsvlai.Vlan_Speed_Total__c;
                                macPr.MACD_Type__c = BuyFlowConstant.C;
                                macPr.IsCircuit_ID_USO_Success__c = false;
                            } else if(premChangeTypeMap.get(macPr.Premise_Number__c) ==BuyFlowConstant.PORTACCESSSPEEDCHANGE){
                                macPr.Circuit_Order_Action__c = BuyFlowConstant.N1;
                                macPr.USO_Order_Action__c=BuyFlowConstant.A;
                                macPr.USO_VLAN__c='Y';
                                macPr.MACD_Change_Type__c = BuyFlowConstant.PORTACCESS_SPEED_CHANGE;
                                macPr.Site_Status__c = BuyFlowConstant.PENDINGSPEED_CHANGE;
                                macPr.IsCircuit_ID_USO_Success__c = false;
                                macPr.USO_Number_of_USOS__c = premiseValMap.get(macPr.Premise_Number__c).No_of_VLANS__c;

                                macPr.Port_Speed__c = rdsvlai.Port_Speed__c;
                                macPr.Circuit_Speed__c = rdsvlai.Access_Speed__c;
                                if(isEthernetAccessChange){
                                    macPr.Circuit_mlppSegments__c=1;
                                } else{
                                    if(newPortSpeedNum > 1){
                                        macPr.Transport_Type__c = BuyFlowConstant.NT1;
                                    } else {
                                        macPr.Transport_Type__c = BuyFlowConstant.T1;
                                    }
                                    macPr.Circuit_mlppSegments__c=cktMLPP;
                                }
                                macPr.Is_Reviewed__c = true;                            
                                if(isEthernetAccessChange){
                                    if(premValNonUnilinkVlanIdMap.size()>0){
                                    nonUnilinkVlanId = premValNonUnilinkVlanIdMap.get(pr.Premise_Number__c);
                                    }
                                    String pId = premiseValMap.get(macPr.Premise_Number__c).Port_Id_Technical__c;
                                    if(isSEPortChange && !isSEAccessChange){
                                        if(isSEPortChange && (rdsvlai.Unilink__c.equalsIgnoreCase(SpecialCharacterBuyFlowConstant.FALSE_LITERAL) || rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.CONCAT)){
                                        macPr.Work_Action_List__c = BuyFlowConstant.CHANGEPORTSPEED+pId+SpecialCharacterBuyFlowConstant.TIDE+BuyFlowConstant.CHANGEVLANSPEED+nonUnilinkVlanId; }
                                        else {
                                        macPr.Work_Action_List__c = BuyFlowConstant.CHANGEPORTSPEED+pId;
                                        }
                                    } else if(!isSEPortChange && isSEAccessChange){
                                        macPr.Work_Action_List__c = BuyFlowConstant.CHANGEACCESSSPEED+pId;
                                    } else if(isSEPortChange && isSEAccessChange){
                                        if(isSEPortChange && (rdsvlai.Unilink__c.equalsIgnoreCase(SpecialCharacterBuyFlowConstant.FALSE_LITERAL) || rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.CONCAT)){
                                        macPr.Work_Action_List__c = BuyFlowConstant.CHANGEACCESSPORTSPEED+pId+SpecialCharacterBuyFlowConstant.TIDE+BuyFlowConstant.CHANGEVLANSPEED+nonUnilinkVlanId;}
                                        else {
                                        macPr.Work_Action_List__c = BuyFlowConstant.CHANGEACCESSPORTSPEED+pId;
                                        }
                                    } 
                                } else {
                                    String gpId = premiseValMap.get(macPr.Premise_Number__c).Group_Port_Id__c;
                                    if(upgrade == 0){
                                        if(newPortSpeedNum == 1){
                                            macPr.Work_Action_List__c = BuyFlowConstant.CHANGEMLPPPTOPPP+gpId;
                                        } else{
                                            macPr.Work_Action_List__c = BuyFlowConstant.CHANGEMLPPPTOMLPPP+gpId;
                                        }
                                    } else if(upgrade == 1){
                                        if(oldPortSpeedNum == 1){
                                            macPr.Work_Action_List__c = BuyFlowConstant.CHANGEPPPTOMLPPP+gpId;
                                        } else{
                                            macPr.Work_Action_List__c = BuyFlowConstant.CHANGEMLPPPTOMLPPP+gpId;
                                        }
                                    }
                                    
                                    //changes added as part of PL upgrade/downgrade work action changes
                                    if( isAccessSpeedUpgradeFromT1 ){
                                        string toAppend = '~BillingDisco|<';
                                        string cktString = SpecialCharacterBuyFlowConstant.CONCAT;
                                        list<RDS_Access_Circuit_ID__c> lstCircuitRecs = orgPremToCircuitIdRecsMap.get(orgPr.Id);
                                        if( lstCircuitRecs != null  && lstCircuitRecs.size() > 0){
                                            cktString = lstCircuitRecs[0].Access_Circuit_ID__c;
                                        }
                                        if(cktString != null && cktString != SpecialCharacterBuyFlowConstant.CONCAT){
                                            string wrkActionlist = macPr.Work_Action_List__c;
                                            toAppend = toAppend + cktString + '>';
                                            macPr.Work_Action_List__c = wrkActionlist + toAppend;
                                        }
                                    }
                                    else if( isAccessSpeedDowngradeToT1 ){
                                        string toAppend = '~BillingDisco|<';
                                        string cktString = SpecialCharacterBuyFlowConstant.CONCAT;
                                        RDS_Access_Circuit_ID__c circuitRec = orgPremTo801CktRecMap.get(orgPr.Id);
                                        if( circuitRec != null ){
                                            cktString = circuitRec.Access_Circuit_ID__c;
                                        }
                                        if(cktString != null && cktString != SpecialCharacterBuyFlowConstant.CONCAT){
                                            string wrkActionlist = macPr.Work_Action_List__c;
                                            toAppend = toAppend + cktString + '>';
                                            macPr.Work_Action_List__c = wrkActionlist + toAppend;
                                        }
                                    }
                                    //changes end
                                    
                                    macPr.USO_VLAN__c=BuyFlowConstant.N1;
                                    macPr.USO_Number_of_USOS__c = null;
                                }  

                                if(isEthernetAccessChange){
                                    if(isInterfaceChange){
                                        macPr.Change_Flow_Type__c = BuyFlowConstant.SPCHETHIC;
                                    } else {
                                        macPr.Change_Flow_Type__c = BuyFlowConstant.SPCHETH;
                                    }
                                } else {
                                    macPr.Change_Flow_Type__c = BuyFlowConstant.SPCHPL;
                                }
                            } else if(premChangeTypeMap.get(macPr.Premise_Number__c) =='CoSAdd'){
                                portString = premiseValMap.get(pr.Premise_Number__c).Port_Id_Technical__c;
                                groupPortString = premiseValMap.get(pr.Premise_Number__c).Group_Port_Id__c;
                                if(premValNonUnilinkVlanIdMap.size()>0){
                                    nonUnilinkVlanId = premValNonUnilinkVlanIdMap.get(pr.Premise_Number__c);
                                }
                                macPr.MACD_Change_Type__c = BuyFlowConstant.COSADD1;
                                macPr.Change_Flow_Type__c = BuyFlowConstant.COS1;
                                macPr.Site_Status__c = BuyFlowConstant.PENDINGADD_COS;
                                macPr.Class_of_Service__c = true;
                                macPr.Is_Reviewed__c = true;
                                if(rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL || rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.CONCAT){
                                    if(macPr.Transport_Type__c == BuyFlowConstant.T1 || macPr.Transport_Type__c == BuyFlowConstant.NT1){
                                        macPr.Work_Action_List__c = BuyFlowConstant.ADDCOS1+groupPortString;
                                    } else if(macPr.Transport_Type__c == BuyFlowConstant.ETHERNET || macPr.Transport_Type__c == BuyFlowConstant.SWITCHEDETHERNET1){
                                        if(macPr.Service_Type__c == BuyFlowConstant.AVPN){
                                            macPr.Work_Action_List__c = BuyFlowConstant.ADDCOS1+portString+SpecialCharacterBuyFlowConstant.TIDE+BuyFlowConstant.ADDCOS1+nonUnilinkVlanId;
                                        } else if(macPr.Service_Type__c == BuyFlowConstant.MIS){
                                            macPr.Work_Action_List__c = BuyFlowConstant.ADDCOS1+nonUnilinkVlanId;
                                        } else {
                                        }   
                                    }
                                }
                            } else if(premChangeTypeMap.get(macPr.Premise_Number__c) ==BuyFlowConstant.COSREMOVE2){
                                portString = premiseValMap.get(pr.Premise_Number__c).Port_Id_Technical__c;
                                groupPortString = premiseValMap.get(pr.Premise_Number__c).Group_Port_Id__c;
                                if(premValNonUnilinkVlanIdMap.size()>0){
                                    nonUnilinkVlanId = premValNonUnilinkVlanIdMap.get(pr.Premise_Number__c);
                                }
                                macPr.MACD_Change_Type__c = BuyFlowConstant.COSREMOVE1;
                                macPr.Change_Flow_Type__c = BuyFlowConstant.COS1;
                                macPr.Site_Status__c = BuyFlowConstant.PENDINGREMOVE_COS;
                                macPr.Class_of_Service__c = false;
                                macPr.Is_Reviewed__c = true;
                                if(rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL || rdsvlai.Unilink__c == SpecialCharacterBuyFlowConstant.CONCAT){
                                    if(macPr.Transport_Type__c == BuyFlowConstant.T1 || macPr.Transport_Type__c == BuyFlowConstant.NT1){
                                        macPr.Work_Action_List__c = BuyFlowConstant.REMOVECOS1+groupPortString;
                                    } else if(macPr.Transport_Type__c == BuyFlowConstant.ETHERNET || macPr.Transport_Type__c == BuyFlowConstant.SWITCHEDETHERNET1){
                                        if(macPr.Service_Type__c == BuyFlowConstant.AVPN){
                                            macPr.Work_Action_List__c = BuyFlowConstant.REMOVECOS1+portString+SpecialCharacterBuyFlowConstant.TIDE+BuyFlowConstant.REMOVECOS1+nonUnilinkVlanId;
                                        } else if(macPr.Service_Type__c == BuyFlowConstant.MIS){
                                            macPr.Work_Action_List__c = BuyFlowConstant.REMOVECOS1+nonUnilinkVlanId;
                                        } else {
                                        }   
                                    }
                              }
                            
                        }
                      MACDPremList.add(macPr);  
                      }
                    
                   } 
                }
                if(MACDPremList.size()>0){ 
                    try{
                        insert MACDPremList;
                    } catch(DMLException e){
                    }
                    if(premList.size()>0){
                        for(RDS_Premise_Details__c rp : premList){
                            rp.Current_Version__c = false;
                            rp.Work_Action_List__c = null;
                            oldpremUpdateList.add(rp);
                        }
                    }
                }
    
            if(oldpremUpdateList.size()>0){ 
                try{
                    update oldpremUpdateList;
                } catch(DMLException e){
                }
            }
            for(COS_Value__c CoS : [SELECT COS_1__c, COS_2__c, COS_3__c, COS_4__c, COS_5__c, COS_6__c, Egress_COS_Profile_ID__c, Egress_PPCOS__c, Ingress_COS_Profile_ID__c, Ingress_PPCOS__c, Package_AVPN__c, Prof_E_Value__c, Product__c FROM COS_Value__c]){
                if(CoS.Product__c == BuyFlowConstant.AVPN){
                    avpnCosMap.put(CoS.Ingress_COS_Profile_ID__c, CoS);
                } else if(CoS.Product__c == BuyFlowConstant.MIS){
                    misCosMap.put(CoS.Ingress_COS_Profile_ID__c, CoS);
                }
            }
            
            cvlanList = [Select Id, Premise__c,Ingress_COS_Profile_ID__c,Egress_COS_Profile_ID__c, CVLAN_Premise_Number__c, MACD_Version__c, Class_of_Service_Package__c from Circuit_and_VLAN_Details__c Where Premise__c =: premList];
            clonedPremIdList = [Select Id, RDS_Version__c,Premise_Number__c from RDS_Premise_Details__c Where Id =: MACDPremList];        
            if(cvlanList.size()>0 && clonedPremIdList.size()>0){
                for(Circuit_and_VLAN_Details__c cv : cvlanList){
                    for(RDS_Premise_Details__c p : clonedPremIdList){
                        for(RDS_Validation__c rdsvalid : validationList){                    
                            if(rdsvalid.Premise_Number__c == p.Premise_Number__c){                        
                                if(cv.CVLAN_Premise_Number__c == p.Premise_Number__c){
                                    String soql = API_Utils.getCreatableFieldsSOQL('Circuit_and_VLAN_Details__c', 'id=\''+cv.Id+'\'');
                                    Circuit_and_VLAN_Details__c cvd = (Circuit_and_VLAN_Details__c)Database.query(soql);
                                    Circuit_and_VLAN_Details__c newCVD = cvd.clone(false,true,true,true);
                                    newCVD.Premise__c = p.Id;
                                    newCVD.MACD_Type__c = BuyFlowConstant.C;
                                    newCVD.Master_CVLAN_Id__c = cv.Id;
                                    if(premChangeTypeMap.get(p.Premise_Number__c) == BuyFlowConstant.UBBADD1 || premChangeTypeMap.get(p.Premise_Number__c) == BuyFlowConstant.UBBCHANGE1){
                                        newCVD.Hi_Cap_Flex_Minimum_Bandwidth_Commitment__c = premiseValMap.get(p.Premise_Number__c).MBC__c;
                                        
                                    } else if(premChangeTypeMap.get(p.Premise_Number__c) == BuyFlowConstant.UBBREMOVE1){
                                        newCVD.Hi_Cap_Flex_Minimum_Bandwidth_Commitment__c = SpecialCharacterBuyFlowConstant.CONCAT;
                                    }if(premChangeTypeMap.get(p.Premise_Number__c) == BuyFlowConstant.PORTSPEEDCHANGE){                                
                                        newCVD.Contracted_Port_Speed__c = premiseValMap.get(p.Premise_Number__c).Port_Speed__c;                               
                                    }
                                    if(premChangeTypeMap.get(p.Premise_Number__c)==BuyFlowConstant.PORTACCESSSPEEDCHANGE && isEthernetAccessChange){
                                        interfacetypeselected = premiseValMap.get(p.Premise_Number__c).Interface_Type__c;
                                        accessspeedvalue = premiseValMap.get(p.Premise_Number__c).Access_Speed__c;
                                        newCVD.Access_Speed__c = premiseValMap.get(p.Premise_Number__c).Access_Speed__c;
                                        newCVD.Contracted_Port_Speed__c = premiseValMap.get(p.Premise_Number__c).Port_Speed__c;
                                        if(String.isNotBlank(interfacetypeselected) && isInterfaceChange){
                                            if(interfacetypeselected.contains(BuyFlowConstant.ELECTRICAL) && Integer.valueof(accessspeedvalue.trim()) <= 100){
                                                interfacetype = BuyFlowConstant.SIVARConst_100BASETX;
                                            }
                                            if(interfacetypeselected.contains(BuyFlowConstant.ELECTRICAL) && Integer.valueof(accessspeedvalue.trim()) > 100){
                                                interfacetype = BuyFlowConstant.SIVARConst_1000BASETX;
                                            }
                                            if(interfacetypeselected.contains(BuyFlowConstant.OPTICALSINGLE_MODE)){
                                                interfacetype = BuyFlowConstant.SIVARConst_1000BASELX;
                                            }
                                            if(interfacetypeselected.contains(BuyFlowConstant.OPTICALMULTI_MODE) && Integer.valueof(accessspeedvalue.trim()) > 100){
                                                interfacetype = BuyFlowConstant.SIVARConst_1000BASESX;
                                            }
                                            if(interfacetype == SpecialCharacterBuyFlowConstant.CONCAT){
                                                interfacetype = BuyFlowConstant.SIVARConst_100BASETX;
                                            }
                                            newCVD.Interface_Type__c = interfacetype;
                                        }
                                    }
                                    if(premChangeTypeMap.get(p.Premise_Number__c)==BuyFlowConstant.PORTACCESSSPEEDCHANGE && !isEthernetAccessChange){
                                        if(newPortSpeedNum == 1){
                                            newCVD.PL_Contracted_Port_Speed__c = BuyFlowConstant.T1;
                                            newCVD.Contracted_Port_Speed__c = premiseValMap.get(p.Premise_Number__c).Port_Speed__c; 
                                            newCVD.Access_Speed__c = premiseValMap.get(p.Premise_Number__c).Access_Speed__c;
                                        } else {
                                            newCVD.PL_Contracted_Port_Speed__c = BuyFlowConstant.MLPPP+newPortSpeedNum+BuyFlowConstant.XT1;
                                            newCVD.Contracted_Port_Speed__c = premiseValMap.get(p.Premise_Number__c).Port_Speed__c; 
                                            newCVD.Access_Speed__c = premiseValMap.get(p.Premise_Number__c).Access_Speed__c;
                                        }
                                    }
                                    if((rdsvalid.MACD_Change_Type__c == BuyFlowConstant.COSCHANGE) && (rdsvalid.Transport_Type__c == BuyFlowConstant.T1 || rdsvalid.Transport_Type__c == BuyFlowConstant.NT1)){                            
                                        newCVD.Ingress_COS_Profile_ID__c = rdsvalid.COS_Profile_ID__c;                             
                                        newCVD.Egress_COS_Profile_ID__c = rdsvalid.Egress_COS_Profile_ID__c;
                                    }
                                    // if(rdsvalid.MACD_Change_Type__c == BuyFlowConstant.ADDCOS && rdsvalid.Unilink__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL){ -Commented because of defect-59963- Vineet
                                    if(rdsvalid.MACD_Change_Type__c == BuyFlowConstant.ADDCOS && (rdsvalid.Transport_Type__c == BuyFlowConstant.T1 || rdsvalid.Transport_Type__c == BuyFlowConstant.NT1)){                          
                                        newCVD.Ingress_COS_Profile_ID__c = rdsvalid.Ingress_COS_Profile_ID__c;                             
                                        newCVD.Egress_COS_Profile_ID__c = rdsvalid.Egress_COS_Profile_ID__c;
                                    }
                                    
                                    if(rdsvalid.Unilink__c == null  || rdsvalid.Unilink__c == SpecialCharacterBuyFlowConstant.CONCAT  || rdsvalid.Unilink__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL ){
                                        if(rdsvalid.Service_Type_Technical__c == BuyFlowConstant.AVPN){
                                            if(!avpnCosMap.isEmpty() && rdsvalid.COS_Profile_ID__c != null && avpnCosMap.get(rdsvalid.COS_Profile_ID__c) != null){
                                                newCVD.Class_of_Service_Package__c = avpnCosMap.get(rdsvalid.COS_Profile_ID__c).Package_AVPN__c;
                                            }
                                        }else if(rdsvalid.Service_Type_Technical__c == BuyFlowConstant.MIS){
                                            if(!misCosMap.isEmpty() && rdsvalid.COS_Profile_ID__c != null && misCosMap.get(rdsvalid.COS_Profile_ID__c) != null){
                                                newCVD.Class_of_Service_Package__c = misCosMap.get(rdsvalid.COS_Profile_ID__c).Package_AVPN__c;
                                            }
                                        }
                                    }
                                    
                                    if(rdsvalid.MACD_Change_Type__c == BuyFlowConstant.ADDCOS && rdsvalid.Unilink__c == SpecialCharacterBuyFlowConstant.TRUE_LITERAL){                            
                                        newCVD.Class_of_Service_Package__c = BuyFlowConstant.MULTIMEDIAHIGH;
                                    }
                                    if(rdsvalid.MACD_Change_Type__c == BuyFlowConstant.REMOVECOS){ 
                                        if(rdsvalid.Unilink__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL || rdsvalid.Unilink__c == SpecialCharacterBuyFlowConstant.CONCAT){
                                            newCVD.Ingress_COS_Profile_ID__c = BuyFlowConstant.SIVARConst_125;                             
                                            newCVD.Egress_COS_Profile_ID__c = BuyFlowConstant.SIVARConst_125;
                                        } else if(rdsvalid.Unilink__c == SpecialCharacterBuyFlowConstant.TRUE_LITERAL){ 
                                            newCVD.Ingress_COS_Profile_ID__c = SpecialCharacterBuyFlowConstant.CONCAT;                 
                                            newCVD.Egress_COS_Profile_ID__c = SpecialCharacterBuyFlowConstant.CONCAT; 
                                        } else{
                                        }
                                        newCVD.Class_of_Service_Package__c = BuyFlowConstant.NOCOS2;
                                    }
                                    clonecvlanList.add(newCVD);
                                    masterCVLANIdSet.add(cv.Id);
                                } 
                            }
                        } 
                    }
                }  
            }
            if(clonecvlanList.size()>0){ 
                try{
                    insert clonecvlanList;
                } catch(DMLException e){
                }
                for(Circuit_and_VLAN_Details__c cvIds : clonecvlanList){
                    macdCVLANIdSet.add(cvIds.Id);
                }
            }
            
            //************Commenting the Code for Child Record Creation 101 SOQL Issue ****************************//
            //************ Logic for Billing Related elements, RDS Contac and Competitive Discount moved to API_MACDCVLAN_CHANGE.createChildRecordsForMACDCVLANCHANGE*************//
            
            Set<Id> oldPremiseSet = New Set<Id>();
            Set<Id> newPremiseSet= New Set<Id>();
            Set<Id> validationSetId= New Set<ID>();
            for(RDS_Premise_Details__c premiseList:premList)
            {
                OldPremiseSet.add(premiseList.ID);
            }
            for(RDS_Premise_Details__c premiseDetails: clonedPremIdList)
            {
                NewPremiseSet.add(premiseDetails.ID); 
            }
            for(RDS_Validation__c val:validationList){
                validationSetId.add(val.Id);
            }
            
            
            
            if(dhMap.size()>0){
                for(Deal_Hash__c dhRec : dhMap.values()){
                    dhRec.RDS_Version__c = version + 1;
                    dhRec.RDS_Version_Select__c = BuyFlowConstant.ALL1;
                    dealHashId = dhRec.Id;
                    dhUpdateList.add(dhRec);
                }
                
                if(dhUpdateList.size()>0){ 
                    try{
                        update dhUpdateList;
                    } catch(DMLException e){
                    }
                }
            }
            
            //Added for MACD Promotion Logic
            if(oppty.id !=null && newMACDOptyId !=null){
                MACD_DiscountPricingHelper.clonePromosAndUpdateOpptybackendMACD(oppty.id,newMACDOptyId);
            } 
            
            if(macdCVLANIdSet.size()>0 && masterCVLANIdSet.size()>0 && valIds.size()>0){       
                API_MACDCVLAN_CHANGE.createChildRecordsForMACDCVLANCHANGE(macdCVLANIdSet,masterCVLANIdSet,valIds,OldPremiseSet,NewPremiseSet,validationSetId,portalmacdaction,upgrade,stat,oldPortSpeedNum,newPortSpeedNum,cktCount,isEthernetAccessChange,newVersion,dealHashId,isInterfaceChange);
            }
        }  
    }
    
    
    }
    /* Method to update Port Speed BEID; Port Speed Name; MBC Speed BEID; MBC Speed Name when UBB change is performed */  
/* 
 Name: updatePortMBCOnUBBChange
 Description: 
 */ 
    public void updatePortMBCOnUBBChange(SObject[] oldObjects, SObject[] updatedObjects){
        List<RDS_Validation__c> oldValidationList = oldObjects;
        List<RDS_Validation__c> validationList = updatedObjects;
        for(RDS_Validation__c oldRdsVal : oldValidationList){
            for(RDS_Validation__c rdsVal : validationList){               
                
                
                if(oldRdsVal.Status__c != rdsVal.Status__c || oldRdsVal.MACD_Change_Type__c != rdsVal.MACD_Change_Type__c || oldRdsVal.MBC__c != rdsVal.MBC__c || oldRdsVal.Port_Speed__c != rdsVal.Port_Speed__c){
                    if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.UBBADD || rdsVal.MACD_Change_Type__c == BuyFlowConstant.UBBCHANGE){
                        if(rdsVal.Service_Type_Technical__c == BuyFlowConstant.AVPN){
                            AVPN_MBC_Setting__c avpnMBC = AVPN_MBC_Setting__c.getInstance(rdsVal.MBC__c);
                            rdsVal.MBC_Speed_BEID__c = avpnMBC.MBC_Speed_BEID__c;
                            rdsVal.MBC_Speed_Name__c = avpnMBC.MBC_Speed_Name__c;
                            rdsVal.Port_Speed_BEID__c = SpecialCharacterBuyFlowConstant.CONCAT ;
                            rdsVal.Port_Speed_Name__c = SpecialCharacterBuyFlowConstant.CONCAT ;
                        } else if(rdsVal.Service_Type_Technical__c == BuyFlowConstant.MIS){
                            MIS_MBC_Setting__c misMBC = MIS_MBC_Setting__c.getInstance(rdsVal.MBC__c);
                            rdsVal.MBC_Speed_BEID__c = misMBC.MBC_Speed_BEID__c;
                            rdsVal.MBC_Speed_Name__c = misMBC.MBC_Speed_Name__c;
                            rdsVal.Port_Speed_BEID__c = SpecialCharacterBuyFlowConstant.CONCAT ;
                            rdsVal.Port_Speed_Name__c = SpecialCharacterBuyFlowConstant.CONCAT ;
                        }
                    } else if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.UBBREMOVE){
                        if(rdsVal.Service_Type_Technical__c == BuyFlowConstant.AVPN){
                            AVPN_Port_Setting__c avpnPort = AVPN_Port_Setting__c.getInstance(rdsVal.Port_Speed__c);
                            rdsVal.Port_Speed_BEID__c = avpnPort.Port_Speed_BEID__c;
                            rdsVal.Port_Speed_Name__c = avpnPort.Port_Speed_Name__c;
                            rdsVal.MBC_Speed_BEID__c = SpecialCharacterBuyFlowConstant.CONCAT;
                            rdsVal.MBC_Speed_Name__c = SpecialCharacterBuyFlowConstant.CONCAT;
                        } else if(rdsVal.Service_Type_Technical__c == BuyFlowConstant.MIS){
                            MIS_Port_Setting__c misPort = MIS_Port_Setting__c.getInstance(rdsVal.Port_Speed__c);
                            rdsVal.Port_Speed_BEID__c = misPort.Port_Speed_BEID__c;
                            rdsVal.Port_Speed_Name__c = misPort.Port_Speed_Name__c;
                            rdsVal.MBC_Speed_BEID__c = SpecialCharacterBuyFlowConstant.CONCAT;
                            rdsVal.MBC_Speed_Name__c = SpecialCharacterBuyFlowConstant.CONCAT;
                        }
                    } else if (rdsVal.MACD_Change_Type__c == BuyFlowConstant.PORTSPEED_CHANGE){
                        if(rdsVal.Service_Type_Technical__c == BuyFlowConstant.AVPN || rdsVal.Service_Type_Technical__c == BuyFlowConstant.MIS){
                            if (rdsVal.Service_Type_Technical__c == BuyFlowConstant.AVPN){
                                if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.PORTSPEED_CHANGE && rdsVal.Unilink__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL && rdsVal.Class_of_Service__c == SpecialCharacterBuyFlowConstant.TRUE_LITERAL){
                                    AVPN_Port_Setting__c avpnPorts = AVPN_Port_Setting__c.getInstance(rdsVal.Port_Speed__c);
                                    rdsVal.Port_Speed_BEID__c = avpnPorts.Port_Speed_BEID__c;
                                    rdsVal.Port_Speed_Name__c = avpnPorts.Port_Speed_Name__c;
                                    AVPN_CoS_Setting__c avpnCos = AVPN_CoS_Setting__c.getInstance(rdsVal.Port_Speed__c);
                                    rdsVal.AVPN_COS_Speed_BEID__c = avpnCos.AVPN_CoS_Speed_BEID__c;
                                    rdsVal.AVPN_COS_Speed_Name__c = avpnCos.AVPN_CoS_Speed_Name__c;   
                                }
                                else if (rdsVal.MACD_Change_Type__c == BuyFlowConstant.PORTSPEED_CHANGE && rdsVal.Unilink__c == SpecialCharacterBuyFlowConstant.TRUE_LITERAL && rdsVal.Class_of_Service__c == SpecialCharacterBuyFlowConstant.TRUE_LITERAL){
                                    AVPN_Port_Setting__c avpnPorts = AVPN_Port_Setting__c.getInstance(rdsVal.Port_Speed__c);
                                    rdsVal.Port_Speed_BEID__c = avpnPorts.Port_Speed_BEID__c;
                                    rdsVal.Port_Speed_Name__c = avpnPorts.Port_Speed_Name__c;
                                    AVPN_CoS_Setting__c avpnCos = AVPN_CoS_Setting__c.getInstance(rdsVal.Port_Speed__c);
                                    rdsVal.AVPN_COS_Speed_BEID__c = avpnCos.AVPN_CoS_Speed_BEID__c;
                                    rdsVal.AVPN_COS_Speed_Name__c = avpnCos.AVPN_CoS_Speed_Name__c; 
                                    AVPN_Unilink_Setting__c avpnunilink= AVPN_Unilink_Setting__c.getInstance(rdsVal.Port_Speed__c);
                                    rdsVal.AVPN_Unilink_Speed_BEID__c = avpnunilink.AVPN_Unilink_Speed_BEID__c;
                                    rdsVal.AVPN_Unilink_Speed_Name__c = avpnunilink.AVPN_Unilink_Speed_Name__c;    
                                } else if (rdsVal.MACD_Change_Type__c == BuyFlowConstant.PORTSPEED_CHANGE && rdsVal.Unilink__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL && rdsVal.Class_of_Service__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL){
                                    AVPN_Port_Setting__c avpnPorts = AVPN_Port_Setting__c.getInstance(rdsVal.Port_Speed__c);
                                    rdsVal.Port_Speed_BEID__c = avpnPorts.Port_Speed_BEID__c;
                                    rdsVal.Port_Speed_Name__c = avpnPorts.Port_Speed_Name__c;
                                    
                                } else if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.PORTSPEED_CHANGE && rdsVal.Unilink__c == SpecialCharacterBuyFlowConstant.TRUE_LITERAL && rdsVal.Class_of_Service__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL){
                                    
                                    AVPN_Port_Setting__c avpnPorts = AVPN_Port_Setting__c.getInstance(rdsVal.Port_Speed__c);
                                    rdsVal.Port_Speed_BEID__c = avpnPorts.Port_Speed_BEID__c;
                                    rdsVal.Port_Speed_Name__c = avpnPorts.Port_Speed_Name__c;
                                    AVPN_Unilink_Setting__c avpnunilink= AVPN_Unilink_Setting__c.getInstance(rdsVal.Port_Speed__c);
                                    rdsVal.AVPN_Unilink_Speed_BEID__c = avpnunilink.AVPN_Unilink_Speed_BEID__c;
                                    rdsVal.AVPN_Unilink_Speed_Name__c = avpnunilink.AVPN_Unilink_Speed_Name__c;    
                                }
                                
                            } else if (rdsVal.Service_Type_Technical__c == BuyFlowConstant.MIS){
                                if(rdsVal.MACD_Change_Type__c == BuyFlowConstant.PORTSPEED_CHANGE && rdsVal.Class_of_Service__c == SpecialCharacterBuyFlowConstant.TRUE_LITERAL){
                                    MIS_Port_Setting__c misPorts = MIS_Port_Setting__c.getInstance(rdsVal.Port_Speed__c);
                                    rdsVal.Port_Speed_BEID__c = misPorts.Port_Speed_BEID__c;
                                    rdsVal.Port_Speed_Name__c = misPorts.Port_Speed_Name__c;
                                    
                                }else if (rdsVal.MACD_Change_Type__c == BuyFlowConstant.PORTSPEED_CHANGE && rdsVal.Class_of_Service__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL){
                                    MIS_Port_Setting__c misPorts = MIS_Port_Setting__c.getInstance(rdsVal.Port_Speed__c);
                                    rdsVal.Port_Speed_BEID__c = misPorts.Port_Speed_BEID__c;
                                    rdsVal.Port_Speed_Name__c = misPorts.Port_Speed_Name__c;
                                }
                                
                            }
                        } 
                    }
                }
            }
            
        }
        
    }   
    
    // Method to populate the WorkActionList on Validation based on MACD Change Type
    
/* 
 Name: populateWorkActionListonVAlidations
 Description: 
 */ 
    public void populateWorkActionListonVAlidations(SObject[] oldObjects, SObject[] updatedObjects){
        List<RDS_Validation__c> validationOldLists = oldObjects;
        List<RDS_Validation__c> validationNewLists = updatedObjects;
        List<RDS_Validation__c> valListsToUpdate = new List<RDS_Validation__c>();
        List<RDS_Premise_Details__c> premList = new List<RDS_Premise_Details__c>();
        Set<Id> valId = new Set<Id>();
        String portid;
        String portIDtechnical;
        
        for(RDS_Validation__c vO1 : validationOldLists ){
            for(RDS_Validation__c vO2 : validationNewLists ){
                if(vO1.Status__c != vO2.Status__c && vO2.Status__c == BuyFlowConstant.SUBMITTED1){
                    if(vO2.MACD_Change_Type__c == BuyFlowConstant.PORTSPEED_CHANGE || vO2.MACD_Change_Type__c == BuyFlowConstant.COSCHANGE|| vO2.MACD_Change_Type__c == BuyFlowConstant.VLANSPEED_CHANGE || vO2.MACD_Change_Type__c == BuyFlowConstant.UBBADD || vO2.MACD_Change_Type__c == BuyFlowConstant.UBBCHANGE || vO2.MACD_Change_Type__c == BuyFlowConstant.UBBREMOVE){
                        valId.add(vO2.Premise__c);
                    }
                }
            }
        }
        if(valId.size()>0){
            premList = [Select Id,Class_of_Service__c,Unilink__c,Premise_Number__c,MACD_Change_Type__c from RDS_Premise_Details__c where ID IN : valId];
            
        }
        
        for(RDS_Premise_Details__c rdsprem : premList){
            for(RDS_Validation__c rdsval : validationNewLists){
                
                if(rdsprem.Premise_Number__c == rdsval.Premise_Number__c && rdsval.Premise__c == rdsprem.id){
                    portid = rdsprem.Premise_Number__c;
                    PortIDtechnical = rdsval.Port_Id_Technical__c;
                    
                    if(PortIDtechnical != null && rdsval.MACD_Change_Type__c == BuyFlowConstant.PORTSPEED_CHANGE && rdsval.Class_of_Service__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL && rdsval.Unilink__c != SpecialCharacterBuyFlowConstant.TRUE_LITERAL)  {
                        rdsval.Work_Action_List__c = BuyFlowConstant.CHANGEPORTSPEED+PortIDtechnical;
                    } else if(portid != null && rdsval.MACD_Change_Type__c == BuyFlowConstant.PORTSPEED_CHANGE && rdsval.Class_of_Service__c == SpecialCharacterBuyFlowConstant.TRUE_LITERAL && rdsval.Unilink__c != SpecialCharacterBuyFlowConstant.TRUE_LITERAL){
                        rdsval.Work_Action_List__c =  BuyFlowConstant.CHANGEPORTSPEED+PortIDtechnical;
                    } else if(portid != null && rdsval.MACD_Change_Type__c == BuyFlowConstant.PORTSPEED_CHANGE && rdsval.Class_of_Service__c == SpecialCharacterBuyFlowConstant.FALSE_LITERAL && rdsval.Unilink__c == SpecialCharacterBuyFlowConstant.TRUE_LITERAL){
                        rdsval.Work_Action_List__c =  BuyFlowConstant.CHANGEPORTSPEED+PortIDtechnical;
                    } else if(portid != null && rdsval.MACD_Change_Type__c == BuyFlowConstant.COSCHANGE && rdsval.Unilink__c != SpecialCharacterBuyFlowConstant.TRUE_LITERAL && rdsval.Transport_Type__c != BuyFlowConstant.SWITCHEDETHERNET1){
                        rdsval.Work_Action_List__c = BuyFlowConstant.CHANGECOS_x+PortIDtechnical;
                    } else if(PortIDtechnical != null && rdsval.MACD_Change_Type__c == BuyFlowConstant.PORTSPEED_CHANGE && rdsval.Class_of_Service__c == SpecialCharacterBuyFlowConstant.TRUE_LITERAL && rdsval.Unilink__c == SpecialCharacterBuyFlowConstant.TRUE_LITERAL)  {
                        rdsval.Work_Action_List__c = BuyFlowConstant.CHANGEPORTSPEED+PortIDtechnical;         
                    } else if(PortIDtechnical != null && rdsval.MACD_Change_Type__c == BuyFlowConstant.UBBADD)  {
                        rdsval.Work_Action_List__c = BuyFlowConstant.ADDUBB_x+PortIDtechnical;         
                    } else if(PortIDtechnical != null && rdsval.MACD_Change_Type__c == BuyFlowConstant.UBBCHANGE)  {
                        rdsval.Work_Action_List__c = BuyFlowConstant.CHANGEMBC_x+PortIDtechnical;         
                    } else if(PortIDtechnical != null && rdsval.MACD_Change_Type__c == BuyFlowConstant.UBBREMOVE)  {
                        rdsval.Work_Action_List__c = BuyFlowConstant.REMOVEUBB+PortIDtechnical;         
                    }
                }
            }
            
        }
    }
    
    /****Method to call create share method for all SP Users' access to RDS-Validation records****/
/* 
 Name: createSharingrule
 Description: 
 */ 
    public static void createSharingrule(SObject[] newObjects){
        try{
        List<RDS_Validation__c> rdsvalList = newObjects;          
        Map<Id,Id> sObjRecordIds = new Map<Id,Id>();      
        
        for(RDS_Validation__c rval: rdsvalList){
            if(!String.isEmpty(rval.Validation_Account_Id__c)){
             sObjRecordIds.put(rval.Id,rval.Validation_Account_Id__c);
             }
        }
       if(sObjRecordIds.size() >0){
           SIHelper.createSPSharingPartnerRule('RDS_Validation__share',sObjRecordIds);
           }
        }
        catch(Exception e){
        }
     }
}