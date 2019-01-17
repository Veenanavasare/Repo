/*
     Component Name :API_CircuitAndVLanTriggerHandler 
     Requirement/User Story Number :US238470 
     Requirement Description:Update Derived Fields from Multiple Objects to Circuit and Vlan on Record Creation
     Component Author:Accenture IDC
     Created Date:9th May 2014 
     Version:1.0
     Version:2.0 Last Modified on 4th July 2014 : Added Subscribed Serviced logic for MIS Transport Type  
     Last Modified By: Accenture IDC
    */
    public with sharing class API_CircuitAndVLanTriggerHandler extends SITriggerOperations.SITriggerImpl{
    
/* 
 Name: onBeforeInsert
 Description: 
 */ 
    public override boolean onBeforeInsert (SObject[] newObjects){
      try{  
        List<Circuit_and_VLAN_Details__c> cvList = newObjects;
        List<Circuit_and_VLAN_Details__c> chkCVList = new List<Circuit_and_VLAN_Details__c >();
        for(Circuit_and_VLAN_Details__c cvd : cvList){
            if(cvd.MACD_Type__c!=SIConstants.MACDTYPED && cvd.MACD_Type__c!=SIConstants.MACDTYPEC){
                chkCVList.add(cvd);
            }    
        }
        if(chkCVList.size()>0){
            try{
                populateMlppSegments(newObjects);
                mlppforEthernet(newObjects);
                populate_SWCCLLI(newObjects);
                updateServiceCodeandSpeed(newObjects);
            } catch (exception e){
                e.getMessage();
            }
        }
        return true;
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }   
    }
      
/* 
 Name: onAfterInsert
 Description: 
 */ 
    public override boolean onAfterInsert (SObject[] newObjects){
     try{   
        List<Circuit_and_VLAN_Details__c> cvList = newObjects;
        List<Circuit_and_VLAN_Details__c> chkCVList = new List<Circuit_and_VLAN_Details__c >();
        for(Circuit_and_VLAN_Details__c cvd : cvList){
            if(cvd.MACD_Type__c!=SIConstants.MACDTYPED && cvd.MACD_Type__c!=SIConstants.MACDTYPEC){
                chkCVList.add(cvd);
            }    
        }
        if(chkCVList.size()>0){
            try{   
                updateValidationFieldsOnPremise(newObjects);
                Deriving_Minimum_Bandwidth_Commitment(newObjects);
                deriveFieldsonPremise(newObjects);
            } catch (exception e){
                e.getMessage();
            }
        }
        return true;
     }catch(Exception ex)
        {
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
            deriveFieldsonPremise(updatedObjects);
           
            //update REmarks Field with Jack Type RDS-Premise Details>>Order Related Data >> Remarks__c
            updateRemarksField(oldObjects, updatedObjects);
        }catch (exception e){
              e.getMessage();
              ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return true;
    }
    
/* 
 Name: updateRemarksField
 Description: 
 */ 
     public void updateRemarksField(SObject[] oldObjects, SObject[] newObjects) {
      try{   
        List<Circuit_and_VLAN_Details__c> oldCVLanList = oldObjects;
        List<Circuit_and_VLAN_Details__c> newCVLanList = newObjects;
        Set<Id> premiseIds = new Set<Id>();
        Map<Id, RDS_Premise_Details__c> premiseDetailMap = new Map<Id, RDS_Premise_Details__c>();
        List<RDS_Premise_Details__c> lPremiseList = new List<RDS_Premise_Details__c>();
        List<RDS_Premise_Details__c> lUpdatedPremiseList = new List<RDS_Premise_Details__c>();
        integer i;
       
            for(i=0;i<newCVLanList.size();i++)  {
                if(oldCVLanList[i].Jack_Type__c != newCVLanList[i].Jack_Type__c) {
                    premiseIds.add(newCVLanList[i].Premise__c);
                }
            }
            
                
                if( premiseIds.size() > 0 ){        
                    lPremiseList = [Select Id, Remarks__c FROM RDS_Premise_Details__c WHERE RDS_Premise_Details__c.id IN:premiseIds];
                    for(RDS_Premise_Details__c p: lPremiseList ) {
                       premiseDetailMap.put(p.Id, p);
                       
                    }
                    for(i=0;i<newCVLanList.size();i++)
                    {
                      if(newCVLanList[i].Jack_Type__c != oldCVLanList[i].Jack_Type__c ) 
                      {
                            RDS_Premise_Details__c premise_to_update = premiseDetailMap.get(oldCVLanList[i].Premise__c);
                            if(premise_to_update!=null) {    
                              
                              //To avoid JackType:null getting appended on remarks field
                              if(null != newCVLanList[i].Jack_Type__c) {
                                  if(null != premise_to_update.remarks__c) {
                                      
                                      String[] arrRemarks= premise_to_update.remarks__c.split(SpecialCharacterConstant.COLEN);
                                      
                                          if(arrRemarks.size()>0) {
                                                   if(arrRemarks[0].contains(UtilityConstant.JACKTYPE)) {
                                                   //If modified, JackType as on CVLanDetails will be updated with remarks field's data.
                                                      premise_to_update.remarks__c = arrRemarks[0] + SpecialCharacterConstant.COLENSPACE + newCVLanList[i].Jack_Type__c; 
                                                  } else {
                                                  //JackType as on CVLanDetails will be appended with remarks field's data.
                                                      premise_to_update.remarks__c = arrRemarks[0] + UtilityConstant.JACK_TYPE_x + newCVLanList[i].Jack_Type__c; 
                                                  }                              
                                          } else {
                                          //JackType as on CVLanDetails will be appended with remarks field's data.
                                                  premise_to_update.remarks__c+=UtilityConstant.JACK_TYPE_x + newCVLanList[i].Jack_Type__c;
                                          }
                                          
                                      } else {
                                          //If remarks field is empty and Jack type has been selected, 
                                          //remarks field will be updated with Jack Type.
                                          premise_to_update.remarks__c = UtilityConstant.JACK_TYPE_x + newCVLanList[i].Jack_Type__c;
                                      } 
                                  } else {
                                  if(null != premise_to_update.remarks__c) {
                                     
                                      String[] arrRemarks= premise_to_update.remarks__c.split(UtilityConstant.JACKTYPE_x);
                                      
                                      if(arrRemarks.size()>0) {
                                      premise_to_update.remarks__c = arrRemarks[0];
                                      }                            
                                }    
                            }
                            lUpdatedPremiseList.add(premise_to_update);
                       }
                    }
                    }
                    if(lUpdatedPremiseList !=null && !lUpdatedPremiseList.isEmpty())
                    { 
                        database.update(lUpdatedPremiseList);
                    }
                    
                }
           }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            }   
        }
   
    
    List<Circuit_and_VLAN_Details__c> listOfVlanToBeupdated = new List<Circuit_and_VLAN_Details__c>();
    set<Id> setOfVlanId= new set<Id>();
    List<RDS_Premise_Details__c> listOfPremiseDetails = new List<RDS_Premise_Details__c>(); 
     
/*
    Logic to Update Field from Class of service and Service Code and FIC to Circuit VLAN   
    Fields :Service Code
    Faclity Interface Code      
*/    
/* 
 Name: updateServiceCodeandSpeed
 Description: 
 */ 
    public void updateServiceCodeandSpeed(SObject[] newObjects){
     try{   
        List<Circuit_and_VLAN_Details__c> newlistOfCVLAN = newObjects;            
        List<RDS_Premise_Details__c> listOfPremiseToupdate = new List<RDS_Premise_Details__c>();  
        Map<String,Service_Code_and_FIC_for_T1__c> mapOfT1 = new Map<String,Service_Code_and_FIC_for_T1__c>();
        Map<String,Class_Of_Service_USOC_Mapping__c> mapOfUSOC = new Map<String,Class_Of_Service_USOC_Mapping__c>();
        
        for(Service_Code_and_FIC_for_T1__c serv: [Select id,Speed__c,FIC__c,SUBS__c,Service_Code__c from Service_Code_and_FIC_for_T1__c]){
            if(serv.Speed__c != null){
                mapOfT1.put(serv.Speed__c ,serv);
            }
        }
        for(Class_Of_Service_USOC_Mapping__c usoc :[Select id,Speed__c,AVPN_Class_of_Svc__c,MIS_Class_of_Svc__c from Class_Of_Service_USOC_Mapping__c]){
            if(usoc.Speed__c != null){
                mapOfUSOC.put(usoc.Speed__c,usoc);
            }
        }
        if(newlistOfCVLAN.size() > 0){         
            for(Circuit_and_VLAN_Details__c vlan: newlistOfCVLAN ){
                setOfVlanId.add(vlan.Premise__c);    
            }
        }
            
        if (setOfVlanId.size()>0){
            listOfPremiseDetails =[Select id,Access_Region__c,Service_Type__c,Transport_Type__c,Customer_Project_Number__c, RDS_Premise_Details__c.DealHash__r.Opportunity__r.BID_ID__c ,Class_Of_Service_USOC__c from RDS_Premise_Details__c where Id in:setOfVlanId LIMIT 1 ];
        }
               
        if(newlistOfCVLAN.size() > 0 && listOfPremiseDetails.size() > 0){
            for(Circuit_and_VLAN_Details__c vlan : newlistOfCVLAN ){
                for(RDS_Premise_Details__c premiseDetails :listOfPremiseDetails){
     // changed logic for T1 and nT1, based on mail from Carola, dt. 4 Aug 2014
                    if (premiseDetails.Transport_Type__c ==SIConstants.TRANSPORTTYPET1||premiseDetails.Transport_Type__c == SIConstants.TRANSPORTTYPENT1){
                         vlan.Facility_Interface_Code__c=SIConstants.FACILITYINTERFACECODE;
                         vlan.Service_Code__c= SIConstants.SERVICECODE ;
                    }
                    /* added below line to take care of Speed = NULL. This condition may not be needed as there will always be a value for Speed
                    but this is an additional check.  4 Aug 2014  */
                    if(vlan.Access_Speed__c!= null || vlan.Access_Speed__c!= SpecialCharacterConstant.CONCAT) {  
                        Service_Code_and_FIC_for_T1__c serv=mapOfT1.get(vlan.Access_Speed__c);
                        if(serv != null) { 
                            if(vlan.Access_Speed__c==serv.Speed__c){
                                if(premiseDetails.Transport_Type__c==SIConstants.TRANSPORTTYPEETHERNET &&  vlan.Facility_Interface_Code__c==null && serv.FIC__c!=NUll){
                                    vlan.Facility_Interface_Code__c=serv.FIC__c;                       
                                    vlan.Service_Code__c=serv.Service_Code__c;
                                } else if(premiseDetails.Transport_Type__c==SIConstants.TRANSPORTTYPESWITCHEDETHERNET  &&  vlan.Facility_Interface_Code__c==null && serv.FIC__c!=null){
                                    vlan.Facility_Interface_Code__c=serv.FIC__c;
                                    vlan.Service_Code__c=serv.Service_Code__c;
                                        if (premiseDetails.Access_Region__c!=null && premiseDetails.Access_Region__c==UtilityConstant.Y ||premiseDetails.Access_Region__c==UtilityConstant.IR ){   
                                            vlan.Access_Method__c=SIConstants.ACCESSMETHODSEAMLESS; 
                                        } else if (premiseDetails.Access_Region__c!=null && premiseDetails.Access_Region__c==UtilityConstant.N ||premiseDetails.Access_Region__c==UtilityConstant.O||premiseDetails.Access_Region__c==UtilityConstant.OOR ||premiseDetails.Access_Region__c==UtilityConstant.OOF){
                                            vlan.Access_Method__c=SIConstants.ACCESSMETHODSHARED;
                                        }
                                        vlan.Subscribed_Services__c=serv.SUBS__c;                   
                                } else if(premiseDetails.Transport_Type__c==SIConstants.TRANSPORTTYPEDEDICATEDETHERNET &&  vlan.Facility_Interface_Code__c==null && serv.FIC__c!=null){
                                    vlan.Facility_Interface_Code__c=serv.FIC__c;
                                    vlan.Service_Code__c=serv.Service_Code__c;
                                    vlan.Access_Method__c=SIConstants.ACCESSMETHODDEDICATED;
                                }
                            }
                        }
                    }
                    
                    if(premiseDetails.Service_Type__c ==SIConstants.SERVICETYPEAVPN ){
                        if(premiseDetails.Transport_Type__c ==SIConstants.TRANSPORTTYPET1){
                            vlan.Subscribed_Services__c=SIConstants.SUSCRIBEDSERVICESSUBSPPP;   
                        } else if(premiseDetails.Transport_Type__c == SIConstants.TRANSPORTTYPENT1){
                            vlan.Subscribed_Services__c=SIConstants.SUSCRIBEDSERVICESSUBSMLPPP;
                        }          
                    } else if(premiseDetails.Service_Type__c ==SIConstants.SERVICETYPEMIS && (vlan.Subscribed_Services__c==null || vlan.Subscribed_Services__c==SpecialCharacterConstant.CONCAT || vlan.Subscribed_Services__c==UtilityConstant.NA)&& (premiseDetails.Transport_Type__c ==SIConstants.TRANSPORTTYPET1 || premiseDetails.Transport_Type__c == SIConstants.TRANSPORTTYPENT1) ){        
                        vlan.Subscribed_Services__c=SIConstants.SUSCRIBEDSERVICESSUBSMIS; 
                    } 
                    listOfVlanToBeupdated.add(vlan); 
                }
            }
        }
            
        if(newlistOfCVLAN.size() > 0 && listOfPremiseDetails.size() > 0) {
            for(Circuit_and_VLAN_Details__c vlan : newlistOfCVLAN ){
                for(RDS_Premise_Details__c premiseDetails :listOfPremiseDetails){
                    //changed logic for T1 and nT1, based on mail from Carola, dt. 4 Aug 2014
                    if(premiseDetails.Transport_Type__c ==SIConstants.TRANSPORTTYPET1||premiseDetails.Transport_Type__c == SIConstants.TRANSPORTTYPENT1) {
                        if(premiseDetails.Service_Type__c ==SIConstants.SERVICETYPEAVPN) {
                            premiseDetails.Class_Of_Service_USOC__c = UtilityConstant.AVCX5 ;
                        } else if(premiseDetails.Service_Type__c ==SIConstants.SERVICETYPEMIS) {
                            premiseDetails.Class_Of_Service_USOC__c = UtilityConstant.MLAX5 ;
                        }                   
                    }
                    if(premiseDetails.Customer_Project_Number__c==null){
                           premiseDetails.Customer_Project_Number__c= premiseDetails.DealHash__r.Opportunity__r.BID_ID__c;
                    } 
                    /* added below line to take care of Speed = NULL. This condition may not be needed as there will always be a value for Speed
                    but this is an additional check.  4 Aug 2014  */                
                    if(vlan.Access_Speed__c!= null || vlan.Access_Speed__c!= SpecialCharacterConstant.CONCAT) {
                        Class_Of_Service_USOC_Mapping__c usoc = mapOfUSOC.get(vlan.Access_Speed__c);
                    
                            if(premiseDetails.Transport_Type__c ==SIConstants.TRANSPORTTYPESWITCHEDETHERNET||premiseDetails.Transport_Type__c == SIConstants.TRANSPORTTYPEDEDICATEDETHERNET) { 
                                if(usoc != null) { 
                                    if(vlan.Access_Speed__c==usoc.Speed__c){
                                        if(premiseDetails.Service_Type__c == SIConstants.SERVICETYPEAVPN ||  premiseDetails.Service_Type__c == SIConstants.PROD_ASE && premiseDetails.Class_Of_Service_USOC__c==null && usoc.AVPN_Class_of_Svc__c!=null ){
                                            premiseDetails.Class_Of_Service_USOC__c = usoc.AVPN_Class_of_Svc__c;
                                        } else if(premiseDetails.Service_Type__c == SIConstants.SERVICETYPEMIS && premiseDetails.Class_Of_Service_USOC__c==null && usoc.MIS_Class_of_Svc__c!=null){
                                            premiseDetails.Class_Of_Service_USOC__c = usoc.MIS_Class_of_Svc__c;
                                        }
                                    } 
                                }
                            }
                    }
                    listOfPremiseToupdate.add(premiseDetails);  
                } 
            }
        }
        
        if (listOfPremiseToupdate.size()>0){
            try{
               update listOfPremiseToupdate;
            } catch(Exception ex){
                ex.getMessage();
                ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            }
        }  
     }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }       
    } 
      
//US296173:Populating SWC CLLI value with 11 digit value from SWC CLLI Mapping Table
/* 
 Name: populate_SWCCLLI
 Description: 
 */ 
    public void populate_SWCCLLI(SObject[] newObjects){ 
     try{
        List<Circuit_and_VLAN_Details__c> circuitandvlanlist=newobjects;
        Map<String,Circuit_and_VLAN_Details__c> cvlanmap = new Map<String,Circuit_and_VLAN_Details__c>();
        Map<String,SWC_CLLI_Mapping_Table__c> swccllimap =new Map<String,SWC_CLLI_Mapping_Table__c>();  
        List<SWC_CLLI_Mapping_Table__c> swcmappinglist=new List<SWC_CLLI_Mapping_Table__c>();
    
        if(circuitandvlanlist.size() > 0){
            for(Circuit_and_VLAN_Details__c cvlandetails: circuitandvlanlist){
                if(cvlandetails.SWC_CLLI__c!=NULL || cvlandetails.SWC_CLLI__c!=SpecialCharacterConstant.CONCAT){ 
                    cvlanmap.put(cvlandetails.SWC_CLLI__c,cvlandetails);
                }
            }
        }
   
        if(cvlanmap.size()>0){     
            swcmappinglist=[select Id,X8_Digit_CLLI__c,X11_Digit_CLLI__c from SWC_CLLI_Mapping_Table__c WHERE X8_Digit_CLLI__c IN:cvlanmap.keySet()];
        }       
        
        if(swcmappinglist.size()>0){      
            for(SWC_CLLI_Mapping_Table__c swc:swcmappinglist){
                swccllimap.put(swc.X8_Digit_CLLI__c,swc);  
            }
    
            if(swccllimap.size() > 0){
                for(String str:swccllimap.keyset()){
                    for(Circuit_and_VLAN_Details__c cvlanrec:cvlanmap.values()){
                        if(swccllimap.get(cvlanrec.SWC_CLLI__c).X11_Digit_CLLI__c!=NULL){
                             cvlanrec.SWC_CLLI__c=swccllimap.get(cvlanrec.SWC_CLLI__c).X11_Digit_CLLI__c;
                        }
                    }
                } 
            }
        }
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }
  
 /*User story:US321961 Derivation Logic for Circuit mlppSegments and Circuit mlppIndicator fields on RDS-Premise Details */
/* 
 Name: populateMlppSegments
 Description: 
 */ 
    public void populateMlppSegments(SObject[] newObjects){     
     try{      
        List<Circuit_and_VLAN_Details__c> cvlanList= newObjects; 
        Set <Id> vlanIdSet = new Set <Id>();  
        List<RDS_Premise_Details__c> listOfPremiseTocheck = new List<RDS_Premise_Details__c>();            
        List<RDS_Circuit_ID_Mapping__c> totalCktrecordsList = new List<RDS_Circuit_ID_Mapping__c>();
        List<RDS_Circuit_ID_Mapping__c> listOfCiruitrecordsfiltered = new List<RDS_Circuit_ID_Mapping__c>();
        List<RDS_Premise_Details__c> premiseListtoUpdate= new List<RDS_Premise_Details__c>(); 
        Decimal accspeed ;
           
        totalCktrecordsList = [Select Id,Access_Speed_Min__c,Access_Speed_Max__c,Circuit__c,Product__c From RDS_Circuit_ID_Mapping__c];
        
        for(Circuit_and_VLAN_Details__c vlans: cvlanList){
           VlanIdSet.add(vlans.Premise__c);    
        }        
        
        if (VlanIdSet.size()>0 && VlanIdSet.size()!= Null){
            listOfPremiseTocheck =[Select id,Transport_Type__c,Service_Type__c,Circuit_mlppSegments__c,Circuit_mlppIndicator__c from RDS_Premise_Details__c where Id in:VlanIdSet LIMIT 1 ];
        }

        if(listOfPremiseTocheck.size() > 0 ){
            for(RDS_Premise_Details__c RDSpremise: listOfPremiseTocheck ){
                for(RDS_Circuit_ID_Mapping__c CircuitIDMapping :totalCktrecordsList ){          
                    if (RDSpremise.Service_Type__c == CircuitIDMapping.Product__c && (RDSpremise.Transport_Type__c == SIConstants.TRANSPORTTYPET1 || RDSpremise.Transport_Type__c ==SIConstants.TRANSPORTTYPENT1 )){                
                        listOfCiruitrecordsfiltered.add(CircuitIDMapping );                
                    } 
                }                  
            }
        }
            
        if(cvlanList.size() > 0 && listOfCiruitrecordsfiltered.size() > 0 && listOfPremiseTocheck.size() > 0){
            for(Circuit_and_VLAN_Details__c circuitandvlan: cvlanList){          
                if(circuitandvlan.Access_Speed__c!=SpecialCharacterConstant.CONCAT || circuitandvlan.Access_Speed__c!=null){               
                    accspeed = Decimal.ValueOf(circuitandvlan.Access_Speed__c) *1000;
                        for(RDS_Circuit_ID_Mapping__c rdsmap: listOfCiruitrecordsfiltered){                           
                            if(accspeed >= rdsmap.Access_Speed_Min__c && accspeed <= rdsmap.Access_Speed_Max__c){ 
                                for(RDS_Premise_Details__c prem : listOfPremiseTocheck ){   
                                    prem.Circuit_mlppSegments__c= rdsmap.Circuit__c;
                                        if(prem.Circuit_mlppSegments__c> 1 ){
                                            prem.Circuit_mlppIndicator__c = UtilityConstant.Y;
                                        } else{
                                            prem.Circuit_mlppIndicator__c = UtilityConstant.N;
                                        }
                                        premiseListtoUpdate.add(prem); 
                                }
                            } 
                        } 
                }   
            }
        }
          
        if(premiseListtoUpdate.size()>0){
            try{
                update premiseListtoUpdate;
            } catch(DMLException e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                e.getmessage();
            }
        } 
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }

/* 
 Name: mlppforEthernet
 Description: 
 */ 
    public void mlppforEthernet(SObject[] newObjects){
     try{   
        List<Circuit_and_VLAN_Details__c> cvlanList= newObjects; 
        Set <Id> vlanIdSet = new Set <Id>();  
        List<RDS_Premise_Details__c> listOfPremiseTocheck = new List<RDS_Premise_Details__c>();
        List<RDS_Premise_Details__c> premiseListtoUpdate= new List<RDS_Premise_Details__c>();   
        
        if(cvlanList.size() > 0) {
            for(Circuit_and_VLAN_Details__c vlans: cvlanList){
                VlanIdSet.add(vlans.Premise__c);    
            }
        }
        
        if (VlanIdSet.size()>0 && VlanIdSet.size()!= Null){
            listOfPremiseTocheck =[Select id,Transport_Type__c,Service_Type__c,Circuit_mlppSegments__c,Circuit_mlppIndicator__c from RDS_Premise_Details__c where Id in:VlanIdSet LIMIT 1 ];
        }
       
        if(listOfPremiseTocheck.size() > 0){
            for(RDS_Premise_Details__c prem : listOfPremiseTocheck ){
                if((prem.Transport_Type__c ==SIConstants.TRANSPORTTYPESWITCHEDETHERNET || prem.Transport_Type__c == SIConstants.TRANSPORTTYPEDEDICATEDETHERNET) && prem.Circuit_mlppSegments__c == null){
                    prem.Circuit_mlppIndicator__c = UtilityConstant.N;
                    premiseListtoUpdate.add(prem);
                }
            }
        }
        
        if(premiseListtoUpdate.size()>0){
            try{
                update premiseListtoUpdate;
            } catch(DMLException e){
                e.getmessage();
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    } 
 
 /*User story:US321961 Derivation Logic for Circuit Service Code, Circuit Service Code Modifier,Circuit Speed fields on RDS-Premise Details from RDS-CVLAN Details */
/* 
 Name: deriveFieldsonPremise
 Description: 
 */ 
    public void deriveFieldsonPremise(SObject[] newObjects){
     try{   
        List<Circuit_and_VLAN_Details__c> cVLANList = newObjects;
        List<RDS_Premise_Details__c> premList = new List<RDS_Premise_Details__c>();
        List<RDS_Premise_Details__c> premListtobeUpdated = new List<RDS_Premise_Details__c>();
        Set<Id> premIdSet = new Set<Id>();
        
        if(CVLANList.size() > 0){
            for(Circuit_and_VLAN_Details__c cvlan :CVLANList ){
                premIdSet .add(cvlan.Premise__c);
            }
        }
        
        if(premIdSet.size()>0){
            premList =[select Id,Circuit_Service_Code__c,Transport_Type__c, Circuit_Service_Code_Modifier__c,Circuit_Speed__c from RDS_Premise_Details__c where Id in:premIdSet  ];
        }
        
        if(premList.size()>0 && CVLANList.size() > 0){   
            for(RDS_Premise_Details__c pdet :premList ){
                for(Circuit_and_VLAN_Details__c cvdet :CVLANList){
                    if(cvdet.Service_Code__c!=SpecialCharacterConstant.CONCAT || cvdet.Service_Code__c!=null ){
                        pdet.Circuit_Service_Code__c = cvdet.Service_Code__c;
                    }
                    if(cvdet.Service_Code_Modifier__c!=SpecialCharacterConstant.CONCAT || cvdet.Service_Code_Modifier__c!=null ){
                        pdet.Circuit_Service_Code_Modifier__c = cvdet.Service_Code_Modifier__c;
                    }
                    if(pdet.Transport_Type__c == SIConstants.TRANSPORTTYPENT1 || pdet.Transport_Type__c == SIConstants.TRANSPORTTYPET1){
                        pdet.Circuit_Speed__c = SpecialCharacterConstant.CONCAT;
                    }
                    if((cvdet.Access_Speed__c!=SpecialCharacterConstant.CONCAT || cvdet.Access_Speed__c!=null) && (pdet.Transport_Type__c==SIConstants.TRANSPORTTYPESWITCHEDETHERNET || pdet.Transport_Type__c == SIConstants.TRANSPORTTYPEDEDICATEDETHERNET) && pdet.id == cvdet.Premise__c){
                        pdet.Circuit_Speed__c = cvdet.Access_Speed__c;                       
                    }                   
                }  
                premListtobeUpdated.add(pdet);               
            }
        }
        
        if(premListtobeUpdated.size() > 0) {
            try{
                update premListtobeUpdated;
            } catch(DMLException e){
                e.getmessage();
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }
    
    
     
//New US:US340898-----HiCapFlex Billing Option- Minimum Bandwith Commitment---developed on 14th october 2014 
//Ali Mohasin: 11/17/2014 - updated where product pricing condition from Product_name__c to Product_Detail__c
    
/* 
 Name: Deriving_Minimum_Bandwidth_Commitment
 Description: 
 */ 
    public void deriving_Minimum_Bandwidth_Commitment(SObject[] newObjects){
     try{   
        List<Circuit_and_VLAN_Details__c> cvlanList=newObjects;
        Set<Id> cvlanopptyIdset=new Set<Id>();
        Set<Id> spproductset=new Set<Id>();
        Set<Id> premiseset=new Set<Id>();
        Set<String> cvlanpremiseset=new Set<String>();
        List<RDS_Premise_Details__c> premiseList=new List<RDS_Premise_Details__c>(); 
        List<SPProduct__c> spproductlist=new List<SPProduct__c>();
        List<Circuit_and_VLAN_Details__c> cvLanListvalues=new List<Circuit_and_VLAN_Details__c>();
        List<Product_Pricing__c> productpricinglist=new List<Product_Pricing__c>();
        Map<Id,Circuit_and_VLAN_Details__c> cvlanMap=new Map<Id,Circuit_and_VLAN_Details__c>();
        
        if(cvlanList.size() > 0) {
            for(Circuit_and_VLAN_Details__c cvlan:cvlanList){
                cvlanopptyIdset.add(cvlan.CVLAN_Opportunity_Id__c);
                cvlanpremiseset.add(cvlan.Premise__c);                   
            }
        }
            
        if(cvlanopptyIdset.size()>0){
            premiseList=[select Id,RDS_Premise_Details__c.Premise_Number__c,RDS_Premise_Details__c.Current_Version__c,RDS_Premise_Details__c.RDS_Version__c,RDS_Premise_Details__c.DealHash__r.Opportunity__r.Id from RDS_Premise_Details__c WHERE Id IN:cvlanpremiseset AND Premise_Number__c!=NULL AND Current_Version__c=true AND RDS_Version__c!=NULL];                      
            
            spproductlist=[select Id,SPProduct__c.MBC_Counter__c,SPProduct__c.Site_ID__c,SPProduct__c.RDS_Version__c,SPProduct__c.Deal__r.Id from SPProduct__c WHERE Deal__c IN:cvlanopptyIdset AND Site_ID__c!=NULL AND RDS_Version__c!=NULL];   
        }
                
        if(premiseList.size() > 0) {
            for(RDS_Premise_Details__c rpd:premiseList){
                premiseset.add(rpd.Id);
            }
        }
                
        if(premiseset.size()>0){
            cvLanListvalues=[select Id,Circuit_and_VLAN_Details__c.CVLAN_Opportunity_Id__c,Circuit_and_VLAN_Details__c.Hi_Cap_Flex_Minimum_Bandwidth_Commitment__c,Circuit_and_VLAN_Details__c.Premise__r.Premise_Number__c,Circuit_and_VLAN_Details__c.Premise__r.Current_Version__c,Circuit_and_VLAN_Details__c.Premise__r.RDS_Version__c,Circuit_and_VLAN_Details__c.Premise__r.DealHash__r.Opportunity__r.Id from Circuit_and_VLAN_Details__c WHERE Premise__c IN:premiseset];
        }
                                                 
        if(spproductlist.size()>0){
            for(SPProduct__c spp:spproductlist){
                spproductset.add(spp.Id);
            }
        }
                
        if(spproductset.size()>0){
            productpricinglist=[select Id,Product_Pricing__c.SP_Product__r.MBC_Counter__c,Product_Pricing__c.product_name__c,Product_Pricing__c.Physical_Value__c,Product_Pricing__c.SP_Product__r.Deal__c,Product_Pricing__c.SP_Product__r.Site_ID__c,Product_Pricing__c.SP_Product__r.RDS_Version__c from Product_Pricing__c WHERE SP_Product__c IN:spproductset AND Record_Type__c='Feature' AND Product_Detail__c='minimumBandwidthCommitment' AND Physical_Value__c!=NULL];  
        }
                   
        if(cvLanListvalues.size() > 0 && productpricinglist.size() > 0) {
            for(Circuit_and_VLAN_Details__c cvld:cvLanListvalues){
                for(Product_Pricing__c pp:productpricinglist){
                    if(cvld.CVLAN_Opportunity_Id__c==pp.SP_Product__r.Deal__c && cvld.Premise__r.Premise_Number__c == pp.SP_Product__r.Site_ID__c && cvld.Premise__r.RDS_Version__c == pp.SP_Product__r.RDS_Version__c && pp.SP_Product__r.MBC_Counter__c==1){
                        cvld.Hi_Cap_Flex_Minimum_Bandwidth_Commitment__c=pp.Physical_Value__c;
                        cvlanMap.put(cvld.Id,cvld);
                    }
                }
            }
        }
        
        if(cvlanMap.size()>0){
            try{
                update cvlanMap.values();
            } Catch(Exception e){
                e.getmessage();
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }  
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    } 
 
/*US345529: MACD CHANGE-Method to update validation fields on Premise*/
/* 
 Name: updateValidationFieldsOnPremise
 Description: 
 */ 
    public void updateValidationFieldsOnPremise(SObject[] newObjects){
     try{   
        List<Circuit_and_VLAN_Details__c> cVLANList = newObjects;
        List<RDS_Premise_Details__c> premiseList = new List<RDS_Premise_Details__c>();
        List<RDS_Premise_Details__c> newPremiseToUpdate = new List<RDS_Premise_Details__c>();
        Set<ID> cvlanSet = new Set<ID>();

        if(CVLANList.size() > 0){
            for(Circuit_and_VLAN_Details__c newcvlan:CVLANList){
                cvlanSet.add(newcvlan.Premise__c);
            }
        }
        if(cvlanSet.size()>0){
            premiseList = [Select id,Combined_VLAN_Speed__c,Product_Type__c,Unilink__c,VLAN_Count__c,Port_Speed__c,Transport_Type__c,Service_Type__c,USO_Number_of_USOS__c FROM RDS_Premise_Details__c where id IN:cvlanSet];
        }
        if(premiseList.size()>0 && CVLANList.size()>0){
            for(Circuit_and_VLAN_Details__c cvlan: CVLANList){ 
                for(RDS_Premise_Details__c premise:premiseList){ 
                    if((premise.Transport_Type__c==SIConstants.TRANSPORTTYPENT1 || premise.Transport_Type__c==SIConstants.TRANSPORTTYPET1) && (premise.id==cvlan.Premise__c)){  
                        premise.Port_Speed__c = cvlan.Contracted_Port_Speed__c;
                        premise.Unilink__c =cvlan.Unilink_Indicator__c;
                        premise.Product_Type__c = premise.Service_Type__c;
                        premise.VLAN_Count__c=cvlan.VLAN_Information__r.size(); //number of cvlans will be 0 for T1 and nT1
                        newPremiseToUpdate.add(premise);
                    }
                }
            }
        }
        if(newPremiseToUpdate.size()>0){
            try{
                update newPremiseToUpdate;
            } catch(DMLException ex){
                ex.getmessage();
                ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            }
        }
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }      
   
}