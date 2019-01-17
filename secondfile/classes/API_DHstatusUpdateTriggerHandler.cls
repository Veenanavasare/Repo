/**************************************************************************************************************************************************
Component Name :API_DHstatusUpdateTriggerHandler      
Requirement/User Story Number : US311424      
Requirement Description: Update ATT Countersignature Date on DHStatus-Update Deal Hash Details object from EBM Sign Date on RDS Pricing Schedule
Component Author:Accenture IDC     
Created Date: 8th September 2014      
Version:1.0     
**************************************************************************************************************************************************/
public with sharing class API_DHstatusUpdateTriggerHandler extends SITriggerOperations.SITriggerImpl{     
    /* 
    Name: onBeforeInsert
    Description: To be used for Future after insert operations
    */ 
    public override boolean onBeforeInsert(SObject[] newObjects){        
        try{ 
            UpdateDHStatus_UpdateDealHashDetials(newObjects);
            updateATTCounterSignDateFromRDSPricingSch(newObjects);
            PopulateInstarOrderNumber(newObjects);
            PopulateWorkActionListonDHStatus(newObjects);
        }        
        catch (exception e){
            e.getMessage();
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));   
        } 
        return true;    
    }       

    /* 
    Name: onBeforeUpdate
    Description: 
    */ 
    public override boolean onBeforeUpdate(SObject[] oldObjects, SObject[] newObjects, Map<Id, SObject>  newObjectsMap){
        try{
            UpdateDHStatus_UpdateDealHashDetials(newObjects); 
            updateATTCounterSignDateFromRDSPricingSch(newObjects); 
            PopulateInstarOrderNumber(newObjects);
        }        
        catch (exception e){ 
            e.getMessage();
            ATTException.logException(e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return true;    
    } 

    /* 
    Name: onAfterUpdate
    Description: 
    */ 
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] newObjects, Map<Id, SObject>  newObjectsMap){
        try{      
            populateContractRenewalDHSData(oldObjects, newObjects);
        }        
        catch (exception e){ 
            e.getMessage(); 
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return true;    
    } 


    /* 
    Name: updateATTCounterSignDateFromRDSPricingSch
    Description: Method to Update ATT Countersignature Date on DHStatus-Update Deal Hash Details object from EBM Sign Date on RDS Pricing Schedule 
    */ 
    public void updateATTCounterSignDateFromRDSPricingSch(SObject[] newObjects){
    try{  
        List<DHStatus_Update_Deal_Hash_Details__c> dhStatusNewList = newObjects;
        List<RDS_Pricing_Schedule_Detail__c> rdsobjList = new List<RDS_Pricing_Schedule_Detail__c>();
        List<DHStatus_Update_Deal_Hash_Details__c> udhdList = new List<DHStatus_Update_Deal_Hash_Details__c>();        
        Set<String> opptyIdsSet = new Set<String>();
        String macdType;
        Set<String> premIdSet = new Set<String>();
        Map<String, RDS_Premise_Details__c> premiseDetailsMap = new Map<String,RDS_Premise_Details__c>();
        Set<Decimal> versionSet = new Set<Decimal>();
        List<Opportunity> opptyList = new List<Opportunity>();
        List<OpportunityHistory> oppHist = new List<OpportunityHistory>();
        DateTime macdPartnerSignDate;
        DateTime macdEbmSignDate;

        for(DHStatus_Update_Deal_Hash_Details__c dhStatusobj : dhStatusNewList){
            macdType = dhStatusobj.MACD_Change_Type__c;
            if(String.isNotBlank(macdType) && (macdType != UtilityConstant.ADDVLAN || macdType != UtilityConstant.DISCONNECTVLAN || macdType != UtilityConstant.COSCHANGE1)){
                premIdSet.add(dhStatusobj.RDS_Premise_Details_For_DHStatus__c);
            } else {
                OpptyIdsSet.add(dhStatusobj.Opportunity_Id__c);
            }
        } 
    
        if(premIdSet.size()>0){
            for(RDS_Premise_Details__c rdsP : [Select Id, DealHash__c, OpptyID__c,RDS_Version__c, MACD_Change_Type__c, Customer_Project_Number__c, Is_Reviewed__c, MACD_Type__c from RDS_Premise_Details__c WHERE Id =: premIdSet]){
                premiseDetailsMap.put(rdsP.DealHash__c, rdsP);
                versionSet.add(rdsP.RDS_Version__c);
            }
        }
        
        if(premiseDetailsMap.size()>0){
            opptyList = [Select id,BID_ID__c, RDS_Deal_Hash__c, RDS_Version__c from Opportunity where RDS_Deal_Hash__c =:premiseDetailsMap.keyset() AND RDS_Version__c =: versionSet];              
            if(opptyList.size()>0){
                for(RDS_Premise_Details__c p : premiseDetailsMap.values()){
                    for(Opportunity opp :opptyList ){
                        if(p.DealHash__c == opp.RDS_Deal_Hash__c && p.RDS_Version__c == opp.RDS_Version__c){
                            OpptyIdsSet.add(opp.id);
                        }
                    }
                }
            }
        }
        

        if(OpptyIdsSet.size()>0){
            rdsobjList = [select Id,Deal__c,EBM_Sign_Date__c,PE_Sign_Date__c from RDS_Pricing_Schedule_Detail__c where Deal__c in :OpptyIdsSet AND EBM_Sign_Date__c != null AND PE_Sign_Date__c !=null];   
            oppHist = [SELECT StageName, SystemModstamp, CreatedDate FROM OpportunityHistory where OpportunityId =: OpptyIdsSet];
        }
        
        if(rdsobjList.size()>0){
            for(DHStatus_Update_Deal_Hash_Details__c dhStatus : dhStatusNewList){
                for(RDS_Pricing_Schedule_Detail__c rdsobjdets : rdsobjList){    
                    macdType = dhStatus.MACD_Change_Type__c; 
                    if(dhStatus.Change_Flow_Type__c == 'Renewal'){
                    system.debug('dhStatus.Renewed_Opportunity__c  '+dhStatus.Renewed_Opportunity__c);
                    system.debug('rdsobjdets.Deal__c '+rdsobjdets.Deal__c);
                        if(Id.ValueOf(dhStatus.Renewed_Opportunity__c) == rdsobjdets.Deal__c){
                            if((dhStatus.ATT_Countersignature_Date__c != rdsobjdets.EBM_Sign_Date__c) || (dhStatus.ATT_Signature_Date__c != rdsobjdets.PE_Sign_Date__c)){
                                dhStatus.ATT_Countersignature_Date__c = rdsobjdets.EBM_Sign_Date__c; 
                                dhStatus.ATT_Signature_Date__c = rdsobjdets.PE_Sign_Date__c; 
                                udhdList.add(dhStatus); 
                            }        
                        }
                    }
                    else if((macdType != UtilityConstant.ADDVLAN || macdType != UtilityConstant.DISCONNECTVLAN || macdType != UtilityConstant.COSCHANGE)){  
                        if(dhStatus.ATT_Countersignature_Date__c != rdsobjdets.EBM_Sign_Date__c || dhStatus.ATT_Signature_Date__c != rdsobjdets.PE_Sign_Date__c){
                            dhStatus.ATT_Countersignature_Date__c = rdsobjdets.EBM_Sign_Date__c;                           
                            dhStatus.ATT_Signature_Date__c = rdsobjdets.PE_Sign_Date__c;
                            udhdList.add(dhStatus);
                        }
                    }   
                    else{
                        dhStatus.ATT_Countersignature_Date__c = null;                           
                        dhStatus.ATT_Signature_Date__c = null;
                        udhdList.add(dhStatus);
                    }
                }    
            }   
        } 
        else {
            if(oppHist.size()>0){
                for(OpportunityHistory op : oppHist){
                    if(op.StageName == UtilityConstant.PRICINGSCHEDULE_REQUESTED){
                        macdPartnerSignDate = op.CreatedDate;
                    }
                    if(op.StageName == UtilityConstant.PRICINGSCHEDULE_APPROVED){
                        macdEbmSignDate = op.CreatedDate;
                    }
                }
            }
            for(DHStatus_Update_Deal_Hash_Details__c dhStatus : dhStatusNewList){
                dhStatus.ATT_Countersignature_Date__c = macdPartnerSignDate;                           
                dhStatus.ATT_Signature_Date__c = macdEbmSignDate;
                udhdList.add(dhStatus);
            }
        }
        }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }


    /*Name:UpdateDHStatus_UpdateDealHashDetials
    * Description:populating DHstatus-UpdateDealHashFields Premise Address, Port Speed,Access Speed.
    */
    public void updateDHStatus_UpdateDealHashDetials(SObject[] newObjects)
    {    
        try{ 
        List<DHStatus_Update_Deal_Hash_Details__c> dHstatus_UDHD_List=newObjects;// reference to new records
        List<DHStatus_Update_Deal_Hash_Details__c> dHStatusUDHDList=new  
        List<DHStatus_Update_Deal_Hash_Details__c>();
        Set<String> uDHD_Premise_Set=new Set<String>();//Set contains premise Id's of DHStatus-Update Deal Hash
        List<RDS_Premise_Details__c> rDSpremiseList=new  List<RDS_Premise_Details__c>();//List contains premises
        Map<Id,DHStatus_Update_Deal_Hash_Details__c> uDHDMap=new Map<Id,DHStatus_Update_Deal_Hash_Details__c>();// Map of DHStatus Update Deal Hash Details
        List<Circuit_and_VLAN_Details__c> cvlanList=new List<Circuit_and_VLAN_Details__c>();//List of CVLAN details 
        Map<Id,DHStatus_Update_Deal_Hash_Details__c> uDHMapp=new Map<Id,DHStatus_Update_Deal_Hash_Details__c>();
        List<RDS_Access_Circuit_ID__c> accessCircuitList=new List<RDS_Access_Circuit_ID__c>();
        for(DHStatus_Update_Deal_Hash_Details__c udhd:DHstatus_UDHD_List)//looping all referenced new records
        {
            if(udhd.Premise_Number__c!=NULL) //checking null condition
            {
                UDHD_Premise_Set.add(udhd.RDS_Premise_Details_For_DHStatus__c);//adding new records premise Ids to set
            }        
        }            
        if(UDHD_Premise_Set.size()>0)
        {
            RDSpremiseList=[select Id,Premise_Street_Number__c,Premise_Street_Direction__c,Premise_Street_Name__c,Premise_Street_Type__c,Premise_City__c,Premise_State__c,Premise_Zipcode__c,Premise_Number__c from RDS_Premise_Details__c WHERE Premise_Number__c!=NULL AND Id IN:UDHD_Premise_Set];
            cvlanList=[select Id,CVLAN_Premise_Number__c,Premise__c,Contracted_Port_Speed__c,Access_Speed__c from Circuit_and_VLAN_Details__c WHERE Contracted_Port_Speed__c!=NULL AND Access_Speed__c!=NULL AND Premise__c IN:UDHD_Premise_Set];       
        }                                     
        if(cvlanList.size()>0)
        {
            for(DHStatus_Update_Deal_Hash_Details__c udh:DHstatus_UDHD_List)
            {
                for(Circuit_and_VLAN_Details__c cvlan:cvlanList)
                {
                    if(udh.RDS_Premise_Details_For_DHStatus__c == cvlan.Premise__c && udh.Premise_Number__c == cvlan.CVLAN_Premise_Number__c)
                    {
                        udh.Port_Speed__c=cvlan.Contracted_Port_Speed__c;
                        udh.Access_Speed__c=cvlan.Access_Speed__c;
                    }
                }
            }
        }

        }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    } 

    /* 
    Name: PopulateInstarOrderNumber
    Description: method to pupolate Instar Order Number from Access Circuit Record (from any Circuit record if there are multiple, 
    since Instar number is excted to be same on all), to DH Status Update record on Insert/Update. The field is used in Provisioning Milestone Report.
    */ 
    public void populateInstarOrderNumber(SObject[] newObjects){
        try{
            List<DHStatus_Update_Deal_Hash_Details__c> dHStatusUPList=newObjects;
            Set<String> dHStatusUDHDIDSet=new Set<String>();
            Set<String> dHStatusUDHDPremiseNumberSet=new Set<String>();
            List<RDS_Access_Circuit_ID__c> rdsaccesscircuit=new List<RDS_Access_Circuit_ID__c>();        
            Map<Id,RDS_Access_Circuit_ID__c> dHStatusUDHDMap=new Map<Id,RDS_Access_Circuit_ID__c>();

            for(DHStatus_Update_Deal_Hash_Details__c dhsu:DHStatusUPList)
            {            
                DHStatusUDHDIDSet.add(dhsu.RDS_Premise_Details_For_DHStatus__c);
                DHStatusUDHDPremiseNumberSet.add(dhsu.Premise_Number__c);
            }

            if(DHStatusUDHDIDSet.size()>0)
            {
                rdsaccesscircuit=[select Id,INSTAR_Order_Number__c,RDS_PremiseDetailID__c,RDS_Premise_Number__c FROM RDS_Access_Circuit_ID__c 
                Where RDS_Premise_Number__c IN:DHStatusUDHDPremiseNumberSet And Instar_Order_Number__c!=NULL ORDER By Id desc limit 1 ];
            }

            if(rdsaccesscircuit.size()>0)
            {
                for(DHStatus_Update_Deal_Hash_Details__c udhd:DHStatusUPList)
                {
                    for(RDS_Access_Circuit_ID__c dhud : rdsaccesscircuit)
                    {
                        if(udhd.Premise_Number__c==dhud.RDS_Premise_Number__c)
                        {
                            udhd.INSTAR_Order_Number__c=dhud.INSTAR_Order_Number__c;
                            DHStatusUDHDMap.put(udhd.id,dhud);  
                        }    
                    }
                }
            }

            if(DHStatusUDHDMap.size()>0)
            {
                try
                {
                    Update DHStatusUDHDMap.Values();
                }
                Catch(Exception e)
                {
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            } 
        }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }  

    /* 
    Name: PopulateWorkActionListonDHStatus
    Description: 
    */ 
    public void populateWorkActionListonDHStatus(SObject[] newObjects){
        try{
            List<DHStatus_Update_Deal_Hash_Details__c> dhlist = newObjects;
            List<RDS_Premise_Details__c> premlist = new list<RDS_Premise_Details__c>();
            set<id> premiseIds=new set<id>();

            for(DHStatus_Update_Deal_Hash_Details__c dh: dhlist){
                premiseIds.add(dh.RDS_Premise_Details_For_DHStatus__c);
            }  

            if(premiseIds.size()>0){
                premlist = [select Id, Name, Work_Action_List__c, MACD_Type__c from RDS_Premise_Details__c where Id IN :premiseIds AND MACD_Type__c='C'];
            }

            if(premlist.size()>0){
                for(RDS_Premise_Details__c  prem : premlist){
                    for(DHStatus_Update_Deal_Hash_Details__c dh:dhlist){
                        if(dh.RDS_Premise_Details_For_DHStatus__c==prem.id && dh.Renewal_Contract__c == false){
                            dh.Work_Action_List__c= prem.Work_Action_List__c;          
                        }
                    }
                }
            }
        }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }  
    
    /*
    * Name: populateContractRenewalDHSData
    * Description : Prepare data to create ITS ticket in case of IDH API Process Status - Provisioning Initiation API Failed
    */
    public void populateContractRenewalDHSData(SObject[] oldObjects, SObject[] newObjects){
        try{
            List<DHStatus_Update_Deal_Hash_Details__c> newDHS = newObjects; 
            List<DHStatus_Update_Deal_Hash_Details__c> oldDHS = oldObjects; 
            Map<id,DHStatus_Update_Deal_Hash_Details__c> createRenewalContractDHStatusMap = new Map<id, DHStatus_Update_Deal_Hash_Details__c>();
            for(DHStatus_Update_Deal_Hash_Details__c dhsNew : newDHS){
                for(DHStatus_Update_Deal_Hash_Details__c dhsOld :oldDHS ){
                    if(dhsOld.Id == dhsNew.Id && dhsNew.Renewal_Contract__c ==  true && dhsNew.API_Process_Status__c != null && (dhsNew.API_Process_Status__c != dhsOld.API_Process_Status__c) && (dhsNew.API_Process_Status__c == SIConstants.PROVISIONING_INITIATION_CANCEL_FAILED)){
                        if(!createRenewalContractDHStatusMap.containsKey(dhsNew.id)){
                            createRenewalContractDHStatusMap.put(dhsNew.id,dhsNew);
                        }
                    }  
                }
            }
            if(!createRenewalContractDHStatusMap.isEmpty() && SIConstants.allowDHSITSTicketCreation  == true){
                RDSExcelExceptionHandling rdsExcelExceptionHandlingObj = new RDSExcelExceptionHandling();
                rdsExcelExceptionHandlingObj.createContractRenewalDHSITSTicket(createRenewalContractDHStatusMap);
                SIConstants.allowDHSITSTicketCreation  = false;
            }
            
        }catch(Exception ex){
            ATTException.logException(ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }

}