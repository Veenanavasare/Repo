/*
     Component Name :API_RDSValidationConfigTriggerHandler 
     Requirement/User Story Number : US417738
     Requirement Description: MACD Change - VLAN Configuration
     Component Author:Accenture IDC
     Created Date: April 03, 2015
     Version:1.0
*/
    
/* 
 Name: SITriggerOperations.SITriggerImpl
 Type: Class 
 
 Description: 
 */ 
/* 
 Name: SITriggerOperations.SITriggerImpl
 Type: Class 
 
 Description: 
 */ 
public with sharing class API_RDSValidationConfigTriggerHandler extends SITriggerOperations.SITriggerImpl{
    
// Will be used for future refence in case of any BeforeInsert Operations 
 /* public override boolean onBeforeInsert (SObject[] newObjects){
        try
        {         
         
           
        }
        catch (exception e)
        {
           e.getMessage();
        }
        return true;
    } */
        
    /*Name:onBeforeUpdate
     * Description:Will be used for future refence in case of any BeforeUpdate Operations
     */
    public override boolean onBeforeUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap)
    {
        try
        {
            populateWorkActionListonvalidation(oldObjects, updatedObjects);                  
        }
        catch (exception e)
        {
             e.getMessage();
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return true;
    }        
     
    /*Name:onAfterInsert
     * Description:To be used for Future after insert operations 
     */
  public override boolean onAfterInsert (SObject[] newObjects)
    {
        try
        {    
            updateUSOOnAddMACDPremise(newObjects);
        }
        catch (exception e)
        {
            e.getMessage();
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return true;
    }  
     
  /*Name:onAfterUpdate
     * Description:To be used for Future After Update Operations
     */
   public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] updatedObjects,Map<Id, SObject>  OldObjectsMap)
    {
        try
        {
            populateWorkActionListonPremise(oldObjects,updatedObjects);
            vlanMACDChanges(oldObjects,updatedObjects);     
        }
        catch (exception e)
        {
              e.getMessage();
              ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return true;
    } 
    
/* User story:367115 populate WorkActionList field on RDS Validation obj based on VLANID field of VLAN_Information__c obj */ 
  // Now moved to Validation Child object
   
/* 
 Name: populateWorkActionListonvalidation
 Description: 
 */ 
/* 
 Name: populateWorkActionListonvalidation
 Description: 
 */ 
    public void populateWorkActionListonvalidation(SObject[] oldObjects, SObject[] updatedObjects){  
     try{
        List<RDS_Validation_Configuration__c> validationOldList = oldObjects;
        List<RDS_Validation_Configuration__c> validationNewList = updatedObjects;
        
        for(RDS_Validation_Configuration__c oldValid : validationOldList){
            for(RDS_Validation_Configuration__c valid : validationNewList){
                if(oldValid.Status_on_Validation__c != valid.Status_on_Validation__c || oldValid.MACD_Change_Feature__c!=valid.MACD_Change_Feature__c && valid.Status_on_Validation__c == UtilityConstant.SUBMITTED){
                    if(valid.MACD_Change_Feature__c == UtilityConstant.VLANDISCONNECTED && valid.VLANID__c!=SpecialCharacterConstant.CONCAT){
                        valid.Workactionlist__c = SFDCConstant.DISCONNECTVLAN+valid.VLANID__c;
                    } else if(valid.MACD_Change_Feature__c == UtilityConstant.VLANSPEED_CHANGE){
                        valid.Workactionlist__c = UtilityConstant.CHANGEVLANSPEED+valid.VLANID__c;
                    } else if(valid.MACD_Change_Feature__c == UtilityConstant.COSCHANGE1){
                        valid.Workactionlist__c = SFDCConstant.CHANGECOS+valid.VLANID__c;
                   } else if(valid.MACD_Change_Feature__c == UtilityConstant.ADDCOS && valid.Ingress_COS_Profile_ID__c != null && valid.Ingress_COS_Profile_ID__c != SpecialCharacterConstant.CONCAT){
                        valid.Workactionlist__c = SFDCConstant.ADDCOS+valid.VLANID__c;
                   } else if(valid.MACD_Change_Feature__c == UtilityConstant.REMOVECOS && valid.Unilink__c == SpecialCharacterConstant.TRUE_LITERAL){
                        valid.Workactionlist__c = SFDCConstant.REMOVECOS+valid.VLANID__c;
                    }
                }
            }
        }
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }
    
/* Method to populate work action list on premise as per US367115*/  
    // Now moved to Validation Child object
    
/* 
 Name: populateWorkActionListonPremise
 Description: 
 */ 
/* 
 Name: populateWorkActionListonPremise
 Description: 
 */ 
    public void populateWorkActionListonPremise(SObject[] oldObjects, SObject[] updatedObjects){
      try{  
        List<RDS_Validation_Configuration__c> validationOldList = oldObjects;
        List<RDS_Validation_Configuration__c> validationNewList = updatedObjects;
        Set<Id> valIds = new Set<Id>();
        List<RDS_Validation__c> valListToUpdate = new List<RDS_Validation__c>();
        List<RDS_Premise_Details__c> premListToUpdate = new List<RDS_Premise_Details__c>();
        List<RDS_Premise_Details__c> macdPremToUpdate = new List<RDS_Premise_Details__c>();
        Set<String> premIds = new Set<String>();
        Set<Id> dealHashId= New set<Id>();
        
        for(RDS_Validation_Configuration__c vO : validationOldList){
            for(RDS_Validation_Configuration__c vi : validationNewList){
                if((vO.Status_on_Validation__c != vi.Status_on_Validation__c || vO.MACD_Change_Feature__c!=vi.MACD_Change_Feature__c) && vi.Status_on_Validation__c == UtilityConstant.SUBMITTED){
                    if(vi.MACD_Change_Feature__c == UtilityConstant.VLANDISCONNECTED || vi.MACD_Change_Feature__c == UtilityConstant.VLANSPEED_CHANGE || vi.MACD_Change_Feature__c == UtilityConstant.COSCHANGE1 || (vi.MACD_Change_Feature__c == UtilityConstant.ADDCOS && vi.Ingress_COS_Profile_ID__c != null && vi.Ingress_COS_Profile_ID__c != SpecialCharacterConstant.CONCAT) || (vi.MACD_Change_Feature__c == UtilityConstant.REMOVECOS && vi.Unilink__c == SpecialCharacterConstant.TRUE_LITERAL)){
                        valIds.add(vi.RDS_Validation__c);
                        premIds.add(vi.Validation_Premise_Number__c);
                        //premIds.add(vi.premise__c);
                        dealHashId.add(vi.DealHashId__c);
                    }
                }
            }
        }
        
        if(valIds.size()>0){
            for(RDS_Validation__c rVa : [Select Id,isbackend__c,MACD_Change_Type__c,Port_Id_Technical__c ,Unilink__c, Premise_Number__c, Work_Action_List__c, (Select Id, Workactionlist__c, MACD_Change_Feature__c From RDS_Validation_Configurations__r where (MACD_Change_Feature__c =:UtilityConstant.VLANDISCONNECTED OR MACD_Change_Feature__c =:UtilityConstant.VLANSPEED_CHANGE OR MACD_Change_Feature__c =:UtilityConstant.COSCHANGE1 OR MACD_Change_Feature__c =:UtilityConstant.ADDCOS OR MACD_Change_Feature__c =:UtilityConstant.REMOVECOS)) From RDS_Validation__c Where Id IN: valIds]){
                if(rVa.RDS_Validation_Configurations__r.size()>0){
                    rVa.Work_Action_List__c = String.valueOf(rVa.RDS_Validation_Configurations__r[0].Workactionlist__c);
                    for(integer i=1;i<rVa.RDS_Validation_Configurations__r.size();i++){
                         if(rVa.RDS_Validation_Configurations__r[i].Workactionlist__c != SpecialCharacterConstant.CONCAT && rVa.RDS_Validation_Configurations__r[i].Workactionlist__c != null && String.valueof(rVa.RDS_Validation_Configurations__r[i].Workactionlist__c) != null && String.valueof(rVa.RDS_Validation_Configurations__r[i].Workactionlist__c) != SpecialCharacterConstant.CONCAT){
                            //rVa.Work_Action_List__c = rVa.Work_Action_List__c+SpecialCharacterBuyflowConstant.TIDE+String.valueOf(rVa.RDS_Validation_Configurations__r[i].Workactionlist__c);
                            if(rVa.Work_Action_List__c!=null){
                                  rVa.Work_Action_List__c = rVa.Work_Action_List__c+SpecialCharacterBuyflowConstant.TIDE+String.valueOf(rVa.RDS_Validation_Configurations__r[i].Workactionlist__c);
                             }else{
                                rVa.Work_Action_List__c =String.valueOf(rVa.RDS_Validation_Configurations__r[i].Workactionlist__c);
                              }        
                        }          
                    } 
                if(rVa.MACD_Change_Type__c == UtilityConstant.REMOVECOS && rVa.Unilink__c == SpecialCharacterConstant.TRUE_LITERAL ){
                        String wrkActionRemcos = rVa.Work_Action_List__c;
                        rVa.Work_Action_List__c =  SFDCConstant.REMOVECOS+rva.Port_Id_Technical__c+SpecialCharacterBuyflowConstant.TIDE+wrkActionRemcos;
                  }
                     if(rVa.MACD_Change_Type__c == UtilityConstant.ADDCOS && rVa.Unilink__c == SpecialCharacterConstant.TRUE_LITERAL) {
                        String wrkActionAddcos = rVa.Work_Action_List__c;
                        rVa.Work_Action_List__c =  SFDCConstant.ADDCOS+rva.Port_Id_Technical__c+SpecialCharacterBuyflowConstant.TIDE+wrkActionAddcos;
                  } 
                    valListToUpdate.add(rVa);
                }
            }
        }
        
        if(valListToUpdate.size()>0){
            try{
            update valListToUpdate;
            } catch(DMLException e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e)); 
            }
        }
        
        if(premIds.size()>0){
            for(RDS_Premise_Details__c pr : [Select Id,DealHash__r.Id, Work_Action_List__c, Premise_Number__c, Current_Version__c From RDS_Premise_Details__c where Premise_Number__c IN: premIds AND  DealHash__c=:dealHashId and Current_Version__c=true order by createdDate desc LIMIT 1 ]){ 
                for(RDS_Validation__c v : valListToUpdate){
                  
                  if(pr.Premise_Number__c == v.Premise_Number__c && v.Unilink__c == SpecialCharacterBuyflowConstant.TRUE_LITERAL){  //&& v.isbackend__c==SFDCConstant.BACKENDMACD){  commented as part of defect 51507
                        pr.Work_Action_List__c = v.Work_Action_List__c;
                        premListToUpdate.add(pr);
                       } 
                    
                }               
            }
        }
        
        if(premListToUpdate.size()>0){
            try{
            update premListToUpdate;
            } catch(DMLException e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }
    
//Logic for VLAN related changes on MACD Change transaction when a saved record is submitted
/* 
 Name: vlanMACDChanges
 Description: 
 */ 
/* 
 Name: vlanMACDChanges
 Description: 
 */ 
    public void vlanMACDChanges(SObject[] oldObjects,SObject[] updatedObjects){
     try{   
        List<RDS_Validation_Configuration__c> valConfigList = updatedObjects;
        List<RDS_Validation_Configuration__c> oldValConfigList = oldObjects;
        Map<String, RDS_Validation_Configuration__c> addVlanMap = new Map<String, RDS_Validation_Configuration__c>();
        Set<String> premNumSet = new Set<String>();
        Map<String, Circuit_and_VLAN_Details__c> macdCVLANMap = new Map<String, Circuit_and_VLAN_Details__c>();
        Set<Id> masterCVLANIds = new Set<Id>();
        Set<Id> masterVLANIds = new Set<Id>();
        List<VLAN_Information__c> vlanList = new List<VLAN_Information__c>();
        Map<String,String> premInstarMap = new Map<String,String>();
        Map<String,Integer> vlanPremExternalIdMap = new Map<String,Integer>();
        List<VLAN_Information__c> newVlanToInsert = new List<VLAN_Information__c>();
        List<RDS_V4_Family_Data__c> v4FamShortList = new List<RDS_V4_Family_Data__c>();
        List<V6_Family_Data__c> v6FamShortList = new List<V6_Family_Data__c>();
        List<RDS_V4_Family_Data__c> v4FamLongList = new List<RDS_V4_Family_Data__c>();
        List<V6_Family_Data__c> v6FamLongList = new List<V6_Family_Data__c>();
        Map<String,RDS_V4_Family_Data__c> premV4Map = new Map<String,RDS_V4_Family_Data__c>();
        Map<String,V6_Family_Data__c> premV6Map = new Map<String,V6_Family_Data__c>();
        Integer count = 0;
        String topology ;
        List<VLAN_Information__c> newChangeVLANList = new List<VLAN_Information__c>();
        Map<String, String> premEncryptPwdV4Map = new Map<String, String>();
        Map<String, String> premEncryptPwdV6Map = new Map<String, String>();
        Map<String, String> premUnEncryptPwdV4Map = new Map<String, String>();
        Map<String, String> premUnEncryptPwdV6Map = new Map<String, String>();
        List<RDS_V4_Family_Data__c> v4ChangeList = new List<RDS_V4_Family_Data__c>();
        List<V6_Family_Data__c> v6ChangeList = new List<V6_Family_Data__c>();
        Set<String> addVLANPremIdSet = new Set<String>();
        Map<String,RDS_Premise_Details__c> newAddVLANPremToUpdateMap = new Map<String,RDS_Premise_Details__c>();
        Set<Id> addValIds = new Set<Id>();
        Map<String,String> cvlanAccPortMap = new Map<String,String>();
    
        for(RDS_Validation_Configuration__c oldValCon : oldValConfigList){
            for(RDS_Validation_Configuration__c newValCon : valConfigList){
                if(oldValCon.Status_on_Validation__c != newValCon.Status_on_Validation__c && newValCon.Status_on_Validation__c == UtilityConstant.SUBMITTED){
                    if(newValCon.MACD_Change_Feature__c == UtilityConstant.VLANADD){
                        addVlanMap.put(newValCon.Id,newValCon);
                        addValIds.add(newValCon.RDS_Validation__c);
                    }
                }
            }
        }
        
        if(addVlanMap.size()>0){
           for(RDS_Validation__c val : [Select Id, Premise_Number__c,Premise__r.DealHash__c,QuoteName__c,(Select Id, External_Id__c from RDS_Validation_Configurations__r where External_Id__c!=null) from RDS_Validation__c where Id IN: addValIds]){
                premNumSet.add(val.Premise_Number__c);
                String quoteName = val.QuoteName__c;
                if(String.isBlank(quoteName)){               
                    count = val.RDS_Validation_Configurations__r.size() + 1;
                } else {
                    count = val.RDS_Validation_Configurations__r.size();
                }
                vlanPremExternalIdMap.put(val.Premise_Number__c,count);
                count = 0;
            }
            
            if(premNumSet.size()>0){
                for(Circuit_and_VLAN_Details__c cv: [Select Id, Master_CVLAN_Id__c, CVLAN_Premise_Number__c, Premise__c, Current_Version_on_Premise__c, (Select Id from VLAN_Information__r) from Circuit_and_VLAN_Details__c where CVLAN_Premise_Number__c =: premNumSet AND Current_Version_on_Premise__c=true]){
                    macdCVLANMap.put(cv.CVLAN_Premise_Number__c,cv);    // map of CVLAN records that were created because of MACD Change
                    masterCVLANIds.add(cv.Master_CVLAN_Id__c);
                }
                
                topology = [Select Id, Topology__c, VPN_Premise_Number__c, Current_Version_on_premise__c from  RDS_VPN_Data__c where VPN_Premise_Number__c =: premNumSet LIMIT 1].Topology__c;
            }
            
            if(masterCVLANIds.size()>0){
                for(RDS_Access_Circuit_ID__c ackt : [Select Id, PortID__c, RDS_Premise_Number__c, Circuit_and_VLAN_Details__c FROM RDS_Access_Circuit_ID__c Where Circuit_and_VLAN_Details__c =: masterCVLANIds]){
                    cvlanAccPortMap.put(ackt.RDS_Premise_Number__c,ackt.PortID__c);
                }
            }
            
            if(macdCVLANMap.size()>0){
                vlanList = [Select Id, Circuit_and_VLAN_Details__c, VLANID__c,VLAN_Premise_Number__c, INSTAR_Order_Number__c, External_ID__c from VLAN_Information__c where Circuit_and_VLAN_Details__c =: masterCVLANIds];
                
                v4FamShortList = [Select Id, V4_Family_Premise_Number__c, RDS_Circuit_and_VLAN_Details_V4__c, Routing_Protocol__c, Routing_ASN__c, Send_Default_Indicator__c, ASN_Override_Indicator__c, Encrypted_Password__c, Unencrypted_Password__c from RDS_V4_Family_Data__c where RDS_Circuit_and_VLAN_Details_V4__c =: masterCVLANIds Order By Id asc];
                if(!Test.isRunningTest()){
                    v6FamShortList = [Select Id, V6_Family_Premise_Number__c, RDS_Circuit_and_VLAN_Details_V6__c, Routing_Protocol__c, Routing_ASN__c, Send_Default_Indicator__c, AS_Override_Indicator__c, Encrypted_Password__c, Unencrypted_Password__c from V6_Family_Data__c where RDS_Circuit_and_VLAN_Details_V6__c =: masterCVLANIds Order By Id asc];  
                }
                else{
                    v6FamShortList = [Select Id, V6_Family_Premise_Number__c, RDS_Circuit_and_VLAN_Details_V6__c, Routing_Protocol__c, Routing_ASN__c, Send_Default_Indicator__c, AS_Override_Indicator__c, Encrypted_Password__c, Unencrypted_Password__c from V6_Family_Data__c where RDS_Circuit_and_VLAN_Details_V6__c =: masterCVLANIds Order By Id asc LIMIT 1000];  
                }
                if(vlanList.size()>0){
                    for(VLAN_Information__c v : vlanList){
                        if(v.INSTAR_Order_Number__c != SpecialCharacterConstant.CONCAT){
                            if(premInstarMap.containsKey(v.VLAN_Premise_Number__c)){
                            } else{
                            premInstarMap.put(v.VLAN_Premise_Number__c, v.INSTAR_Order_Number__c);
                            }
                        }
                        masterVLANIds.add(v.id);
                    }
                    
                    v4FamLongList = [Select Id, V4_Family_Premise_Number__c, RDS_VLAN_Information_V4__c, Routing_Protocol__c, Routing_ASN__c, Send_Default_Indicator__c, ASN_Override_Indicator__c, Encrypted_Password__c, Unencrypted_Password__c from RDS_V4_Family_Data__c where RDS_VLAN_Information_V4__c =: masterVLANIds Order By Id asc];
                    v6FamLongList = [Select Id, V6_Family_Premise_Number__c, RDS_VLAN_Information__c, Routing_Protocol__c, Routing_ASN__c, Send_Default_Indicator__c, AS_Override_Indicator__c, Encrypted_Password__c, Unencrypted_Password__c from V6_Family_Data__c where RDS_VLAN_Information__c =: masterVLANIds Order By Id asc]; 
                }
            }
            
            if(v4FamShortList.size()>0){
                for(RDS_V4_Family_Data__c rV4 : v4FamShortList){
                    if(rV4.Encrypted_Password__c != rV4.Unencrypted_Password__c && rV4.Encrypted_Password__c !=SpecialCharacterConstant.CONCAT && rV4.Unencrypted_Password__c !=SpecialCharacterConstant.CONCAT){
                        if(!premEncryptPwdV4Map.containsKey(rV4.V4_Family_Premise_Number__c)){
                            premEncryptPwdV4Map.put(rV4.V4_Family_Premise_Number__c,rV4.Encrypted_Password__c);
                        }
                        if(!premUnEncryptPwdV4Map.containsKey(rV4.V4_Family_Premise_Number__c)){
                            premUnEncryptPwdV4Map.put(rV4.V4_Family_Premise_Number__c,rV4.Unencrypted_Password__c);
                        }
                    }
                    if(!premV4Map.containsKey(rV4.V4_Family_Premise_Number__c)){
                        premV4Map.put(rV4.V4_Family_Premise_Number__c,rV4);
                    }
                }
            }
            if(v6FamShortList.size()>0){
                for(V6_Family_Data__c rV6 : v6FamShortList){
                    if(rV6.Encrypted_Password__c != rV6.Unencrypted_Password__c && rV6.Encrypted_Password__c !=SpecialCharacterConstant.CONCAT && rV6.Unencrypted_Password__c !=SpecialCharacterConstant.CONCAT){
                        if(!premEncryptPwdV6Map.containsKey(rV6.V6_Family_Premise_Number__c)){
                            premEncryptPwdV6Map.put(rV6.V6_Family_Premise_Number__c,rV6.Encrypted_Password__c);
                        }
                        if(!premUnEncryptPwdV6Map.containsKey(rV6.V6_Family_Premise_Number__c)){
                            premUnEncryptPwdV6Map.put(rV6.V6_Family_Premise_Number__c,rV6.Unencrypted_Password__c);
                        }
                    }
                    if(!premV6Map.containsKey(rV6.V6_Family_Premise_Number__c)){
                        premV6Map.put(rV6.V6_Family_Premise_Number__c,rV6);
                    }
                }
            }
            
            if(premV4Map.size()<=0){
                if(v4FamLongList.size()>0){
                    for(RDS_V4_Family_Data__c rV4 : v4FamLongList){
                        if(rV4.Encrypted_Password__c != rV4.Unencrypted_Password__c && rV4.Encrypted_Password__c !=SpecialCharacterConstant.CONCAT && rV4.Unencrypted_Password__c !=SpecialCharacterConstant.CONCAT){
                            if(!premEncryptPwdV4Map.containsKey(rV4.V4_Family_Premise_Number__c)){
                            premEncryptPwdV4Map.put(rV4.V4_Family_Premise_Number__c,rV4.Encrypted_Password__c);
                            }
                            if(!premUnEncryptPwdV4Map.containsKey(rV4.V4_Family_Premise_Number__c)){
                                premUnEncryptPwdV4Map.put(rV4.V4_Family_Premise_Number__c,rV4.Unencrypted_Password__c);
                            }
                        }
                        if(!premV4Map.containsKey(rV4.V4_Family_Premise_Number__c)){
                            premV4Map.put(rV4.V4_Family_Premise_Number__c,rV4);
                        }
                    }
                }
            }

            if(premV6Map.size()<=0){    
                if(v6FamLongList.size()>0){
                    for(V6_Family_Data__c rV6 : v6FamLongList){
                        if(rV6.Encrypted_Password__c != rV6.Unencrypted_Password__c && rV6.Encrypted_Password__c !=SpecialCharacterConstant.CONCAT && rV6.Unencrypted_Password__c !=SpecialCharacterConstant.CONCAT){
                            if(!premEncryptPwdV6Map.containsKey(rV6.V6_Family_Premise_Number__c)){
                            premEncryptPwdV6Map.put(rV6.V6_Family_Premise_Number__c,rV6.Encrypted_Password__c);
                            }
                            if(!premUnEncryptPwdV6Map.containsKey(rV6.V6_Family_Premise_Number__c)){
                                premUnEncryptPwdV6Map.put(rV6.V6_Family_Premise_Number__c,rV6.Unencrypted_Password__c);
                            }
                        }
                        if(!premV6Map.containsKey(rV6.V6_Family_Premise_Number__c)){
                            premV6Map.put(rV6.V6_Family_Premise_Number__c,rV6);
                        }
                    }
                }
            } 
    
            for(RDS_Validation_Configuration__c rdVal : addVlanMap.values()){
                VLAN_Information__c newVlan = new VLAN_Information__c();
                newVlan.VLAN_Speed__c = rdVal.VLAN_Speed__c;
                newVlan.VPN_Name__c = rdVal.VPN_Name__c;
                newVlan.Circuit_and_VLAN_Details__c = macdCVLANMap.get(rdVal.Validation_Premise_Number__c).Id;
                newVlan.INSTAR_Order_Number__c = premInstarMap.get(rdVal.Validation_Premise_Number__c);
                newVlan.IP_Version__c = rdVal.IP_Version__c;
                newVlan.MACD_Type__c = UtilityConstant.C;
                newVlan.Ingress_COS_Profile_ID__c = rdVal.Ingress_Profile_ID__c;
                newVlan.Egress_COS_Profile_ID__c = rdVal.Egress_Profile_ID__c;
                newVlan.VLAN_Status__c = UtilityConstant.PENDINGADD;
                newVlan.Add_VLAN__c = true;
                    if(topology == UtilityConstant.ANYTOANY){
                        newVlan.VPN_Connection_Type__c = SpecialCharacterConstant.CONCAT ;
                    } else{
                        newVlan.VPN_Connection_Type__c = UtilityConstant.SPOKE;
                    }
                    if(vlanPremExternalIdMap.containsKey(rdVal.Validation_Premise_Number__c)){
                        count = vlanPremExternalIdMap.get(rdVal.Validation_Premise_Number__c) + 1;
                        newVlan.External_ID__c = String.valueOf(count);
                        vlanPremExternalIdMap.put(rdVal.Validation_Premise_Number__c,count);
                        count = 0;
                    }
                    if(cvlanAccPortMap.containsKey(rdVal.Validation_Premise_Number__c)){
                        newVlan.PortID__c = cvlanAccPortMap.get(rdVal.Validation_Premise_Number__c);
                    }
                newVlan.Validation_Record_Id__c = rdVal.Id;
                newVlanToInsert.add(newVlan);
            }
            
            if(newVlanToInsert.size()>0){
                try{
                    insert newVlanToInsert;
                    newChangeVLANList = [Select Id, VLANID__c, Validation_Record_Id__c, Circuit_and_VLAN_Details__r.Premise__c,VLAN_Premise_Number__c from VLAN_Information__c where Id =: newVlanToInsert];
                } catch(DMLException e){
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            }   

            if(newChangeVLANList.size()>0){
                for(VLAN_Information__c vI : newChangeVLANList){
                    for(RDS_Validation_Configuration__c rV : addVlanMap.values()){
                            if(vI.VLAN_Premise_Number__c == rV.Validation_Premise_Number__c && vI.Validation_Record_Id__c == rV.Id){
                                if(rV.IP_Version__c ==UtilityConstant.V4){
                                    RDS_V4_Family_Data__c v4ChRec = new RDS_V4_Family_Data__c();
                                    v4ChRec.Customer_Edge_IP_Address__c = rV.Customer_IP_V4_Address__c;
                                    v4ChRec.ATT_Edge_IP_Address__c = rV.ATT_IP_Address__c;
                                    v4ChRec.Subnet_Mask__c = rV.Subnet_Mask_V4__c;
                                    v4ChRec.RDS_VLAN_Information_V4__c = vI.Id;
                                    v4ChRec.MACD_Type__c = UtilityConstant.C;
                                  if(premV4Map.size()>0 && rV.MACD_Action__c != UtilityConstant.ADDVLAN1){
                                        v4ChRec.Routing_Protocol__c = premV4Map.get(rV.Validation_Premise_Number__c).Routing_Protocol__c;
                                        v4ChRec.Routing_ASN__c = premV4Map.get(rV.Validation_Premise_Number__c).Routing_ASN__c;
                                        v4ChRec.ASN_Override_Indicator__c = premV4Map.get(rV.Validation_Premise_Number__c).ASN_Override_Indicator__c;
                                        v4ChRec.Send_Default_Indicator__c = premV4Map.get(rV.Validation_Premise_Number__c).Send_Default_Indicator__c;
                                        v4ChRec.Encrypted_Password__c = premEncryptPwdV4Map.get(rV.Validation_Premise_Number__c);
                                        v4ChRec.Unencrypted_Password__c = premUnEncryptPwdV4Map.get(rV.Validation_Premise_Number__c);
                                    }
                                    if(premV4Map.size()>0 && rV.MACD_Action__c == UtilityConstant.ADDVLAN){
                                        v4ChRec.Encrypted_Password__c=rV.V4_Encrypted_Password__c;
                                        v4ChRec.Routing_Protocol__c=rV.V4_Routing_Protocol__c;
                                        v4ChRec.Routing_ASN__c=rV.V4_Routing_ASN__c;
                                        v4ChRec.Send_Default_Indicator__c=rV.V4_Send_Default_Indicator__c;
                                        v4ChRec.ASN_Override_Indicator__c=rV.V4_ASN_Override_Indicator__c;
      
                                    }
                                    v4ChangeList.add(v4ChRec);
                                } else if(rV.IP_Version__c ==UtilityConstant.V6){
                                    V6_Family_Data__c v6ChRec = new V6_Family_Data__c();
                                    v6ChRec.RDS_VLAN_Information__c = vI.Id;
                                    v6ChRec.MACD_Type__c = UtilityConstant.C;
                                    if(premV6Map.size()>0 && rV.MACD_Action__c != UtilityConstant.ADDVLAN){
                                        v6ChRec.Routing_Protocol__c = premV6Map.get(rV.Validation_Premise_Number__c).Routing_Protocol__c;
                                        v6ChRec.Routing_ASN__c = premV6Map.get(rV.Validation_Premise_Number__c).Routing_ASN__c;
                                        v6ChRec.AS_Override_Indicator__c = premV6Map.get(rV.Validation_Premise_Number__c).AS_Override_Indicator__c;
                                        v6ChRec.Send_Default_Indicator__c = premV6Map.get(rV.Validation_Premise_Number__c).Send_Default_Indicator__c;
                                        v6ChRec.Encrypted_Password__c = premEncryptPwdV6Map.get(rV.Validation_Premise_Number__c);
                                        v6ChRec.Unencrypted_Password__c = premUnEncryptPwdV6Map.get(rV.Validation_Premise_Number__c);
                                    }
                                    if(premV6Map.size()>0 && rV.MACD_Action__c == UtilityConstant.ADDVLAN){
                                         v6ChRec.Routing_Protocol__c=rV.V6_Routing_Protocol__c;
                                         v6ChRec.Routing_ASN__c=rV.V6_Routing_ASN__c;
                                         v6ChRec.Send_Default_Indicator__c=rV.V6_Send_Default_Indicator__c;
                                         v6ChRec.AS_Override_Indicator__c=rV.V6_ASN_Override_Indicator__c;
                                         v6ChRec.Encrypted_Password__c=rV.V6_Encrypted_Password__c;
                                    }
                                    v6ChangeList.add(v6ChRec);
                                }  else if(rV.IP_Version__c ==UtilityConstant.V4V6){
                                    RDS_V4_Family_Data__c v4ChRec = new RDS_V4_Family_Data__c();
                                    v4ChRec.Customer_Edge_IP_Address__c = rV.Customer_IP_V4_Address__c;
                                    v4ChRec.ATT_Edge_IP_Address__c = rV.ATT_IP_Address__c;
                                    v4ChRec.Subnet_Mask__c = rV.Subnet_Mask_V4__c;
                                    v4ChRec.RDS_VLAN_Information_V4__c = vI.Id;
                                    v4ChRec.MACD_Type__c = UtilityConstant.C;
                                    if(premV4Map.size()>0 && rV.MACD_Action__c != UtilityConstant.ADDVLAN){
                                        v4ChRec.Routing_Protocol__c = premV4Map.get(rV.Validation_Premise_Number__c).Routing_Protocol__c;
                                        v4ChRec.Routing_ASN__c = premV4Map.get(rV.Validation_Premise_Number__c).Routing_ASN__c;
                                        v4ChRec.ASN_Override_Indicator__c = premV4Map.get(rV.Validation_Premise_Number__c).ASN_Override_Indicator__c;
                                        v4ChRec.Send_Default_Indicator__c = premV4Map.get(rV.Validation_Premise_Number__c).Send_Default_Indicator__c;
                                        v4ChRec.Encrypted_Password__c = premEncryptPwdV4Map.get(rV.Validation_Premise_Number__c);
                                        v4ChRec.Unencrypted_Password__c = premUnEncryptPwdV4Map.get(rV.Validation_Premise_Number__c);
                                    }
                                    if(premV4Map.size()>0 && rV.MACD_Action__c == UtilityConstant.ADDVLAN){
                                        v4ChRec.Encrypted_Password__c=rV.V4_Encrypted_Password__c;
                                        v4ChRec.Routing_Protocol__c=rV.V4_Routing_Protocol__c;
                                        v4ChRec.Routing_ASN__c=rV.V4_Routing_ASN__c;
                                        v4ChRec.Send_Default_Indicator__c=rV.V4_Send_Default_Indicator__c;
                                        v4ChRec.ASN_Override_Indicator__c=rV.V4_ASN_Override_Indicator__c;
                                    }
                                    v4ChangeList.add(v4ChRec);
                                    V6_Family_Data__c v6ChRec = new V6_Family_Data__c();
                                    v6ChRec.RDS_VLAN_Information__c = vI.Id;
                                    v6ChRec.MACD_Type__c = UtilityConstant.C;
                                    if(premV6Map.size()>0 && rV.MACD_Action__c != UtilityConstant.ADDVLAN){
                                        v6ChRec.Routing_Protocol__c = premV6Map.get(rV.Validation_Premise_Number__c).Routing_Protocol__c;
                                        v6ChRec.Routing_ASN__c = premV6Map.get(rV.Validation_Premise_Number__c).Routing_ASN__c;
                                        v6ChRec.AS_Override_Indicator__c = premV6Map.get(rV.Validation_Premise_Number__c).AS_Override_Indicator__c;
                                        v6ChRec.Send_Default_Indicator__c = premV6Map.get(rV.Validation_Premise_Number__c).Send_Default_Indicator__c;
                                        v6ChRec.Encrypted_Password__c = premEncryptPwdV6Map.get(rV.Validation_Premise_Number__c);
                                        v6ChRec.Unencrypted_Password__c = premUnEncryptPwdV6Map.get(rV.Validation_Premise_Number__c);
                                    }
                                    if(premV6Map.size()>0 && rV.MACD_Action__c == UtilityConstant.ADDVLAN){
                                         v6ChRec.Routing_Protocol__c=rV.V6_Routing_Protocol__c;
                                         v6ChRec.Routing_ASN__c=rV.V6_Routing_ASN__c;
                                         v6ChRec.Send_Default_Indicator__c=rV.V6_Send_Default_Indicator__c;
                                         v6ChRec.AS_Override_Indicator__c=rV.V6_ASN_Override_Indicator__c;
                                         v6ChRec.Encrypted_Password__c=rV.V6_Encrypted_Password__c;
                                    }
                                    v6ChangeList.add(v6ChRec);
                                }
                            }
                    }
                    addVLANPremIdSet.add(vI.Circuit_and_VLAN_Details__r.Premise__c);
                }
             }
             
             if(addVLANPremIdSet.size()>0){
                 for(RDS_Premise_Details__c addRDSP : [Select Id, Work_Action_List__c from RDS_Premise_Details__c where Id =: addVLANPremIdSet]){
                     for(VLAN_Information__c vIAdd : newChangeVLANList){
                         if(addRDSP.Id == vIAdd.Circuit_and_VLAN_Details__r.Premise__c){
                             if(addRDSP.Work_Action_List__c == null){
                                 addRDSP.Work_Action_List__c = SFDCConstant.ADDVLAN+vIAdd.VLANID__c;
                             } else {
                                 addRDSP.Work_Action_List__c = addRDSP.Work_Action_List__c+SFDCConstant.ADDVLAN_x+vIAdd.VLANID__c;
                             }
                            newAddVLANPremToUpdateMap.put(addRDSP.Id,addRDSP);
                        }
                     } 
                 }
             }
             
             if(newAddVLANPremToUpdateMap.size()>0){
                 try{
                    update newAddVLANPremToUpdateMap.values();
                 } catch(DMLException e){
                     ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                 }
             }
             
             if(v4ChangeList.size()>0){
                 try{
                    insert v4ChangeList;
                 } catch(DMLException e){
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e)); 
                 }
             } 
             
             if(v6ChangeList.size()>0){
                 try{
                    insert v6ChangeList;
                 } catch(DMLException e){
                     ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                 }
             } 
        }       
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }
    
/* Method to populate USO Number of USOs on insert of VLAN Add with submitted status */ 
   
/* 
 Name: updateUSOOnAddMACDPremise
 Description: 
 */ 
/* 
 Name: updateUSOOnAddMACDPremise
 Description: 
 */ 
    public void updateUSOOnAddMACDPremise(SObject[] newObjects){  
    try{
        List<RDS_Validation_Configuration__c> validationNewList = newObjects;       
        Set<Id> valIds = new Set<Id>();
        Map<String,Integer> premValConfigMap = new Map<String,Integer>();
        List<RDS_Premise_Details__c> macdPremToUpdate = new List<RDS_Premise_Details__c>();
        
        for(RDS_Validation_Configuration__c valid : validationNewList){
            if((valid.MACD_Change_Feature__c == UtilityConstant.VLANDISCONNECTED || valid.MACD_Change_Feature__c == UtilityConstant.VLANADD) && valid.Status_on_Validation__c == UtilityConstant.SUBMITTED){
                valIds.add(valid.Id);
            }
        } 
        
        if(valIds.size()>0){
            for(RDS_Validation__c vl : [Select Id, Premise__c, Premise_Number__c, (Select Id from RDS_Validation_Configurations__r Where MACD_Change_Feature__c =: UtilityConstant.VLANDISCONNECTED OR MACD_Change_Feature__c =: UtilityConstant.DISCONNECTVLAN OR MACD_Change_Feature__c =: UtilityConstant.VLANADD) from RDS_Validation__c where Id IN: valIds]){
                premValConfigMap.put(vl.Premise_Number__c,vl.RDS_Validation_Configurations__r.size());
            }
        }
        
        if(premValConfigMap.size()>0){
            for(RDS_Premise_Details__c macPr : [Select Id, MACD_Change_Type__c, VLAN_Count__c, USO_Number_of_USOS__c, Current_Version__c, Premise_Number__c From RDS_Premise_Details__c where Premise_Number__c IN: premValConfigMap.keySet() AND Current_Version__c = true]){ 
                macPr.USO_Number_of_USOS__c = premValConfigMap.get(macPr.Premise_Number__c);
                macPr.VLAN_Count__c = premValConfigMap.get(macPr.Premise_Number__c);
                macdPremToUpdate.add(macPr);
            }
        }
        
        if(macdPremToUpdate.size()>0){
            try{
            update macdPremToUpdate;
            } catch(DMLException e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }
    
}