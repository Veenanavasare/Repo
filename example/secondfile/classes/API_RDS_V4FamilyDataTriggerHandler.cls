/*
     Component Name :API_RDS_V4FamilyDataTriggerHandler
     Requirement/User Story Number : US238470 
     Requirement Description:Insert History Tracking Record on V4 Record insert
     Component Author:Accenture IDC
     Created Date:5th May 2014 
     Version:1.0
     Version 1.1: updated the logic around inserting record in history table matching the routing protocol and Encrypted password.
     Last Modified By: Accenture IDC
    */ 
public with sharing class API_RDS_V4FamilyDataTriggerHandler extends SITriggerOperations.SITriggerImpl{
      
      public boolean isExecuted ;
      List<RDS_V4_Family_Data__c> listofv4= new List<RDS_V4_Family_Data__c>();

    //Default cons
/* 
 Name: API_RDS_V4FamilyDataTriggerHandler
 Description: 
 */ 
    public API_RDS_V4FamilyDataTriggerHandler() {
        isExecuted = true; 
    }
    
/* 
 Name: onAfterUpdate
 Description: 
 */ 
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap )  {
        try {
            rdsTriggerHistory(updatedObjects,false,true);
            
            checkMd5RequiredCheckboxOnOppty(updatedObjects);            
        
        } catch(Exception excep) {
            excep.getMessage();
            isExecuted = false;
            throw excep;
            ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
        }
        return isExecuted;
    }
    
/* 
 Name: onAfterInsert
 Description: 
 */ 
     public override boolean onAfterInsert(SObject[] updatedObjects)  {
        try {
            
            rdsTriggerHistory(updatedObjects,true,false);
            
            checkMd5RequiredCheckboxOnOppty(updatedObjects);                        
        } catch(Exception excep) {
             excep.getMessage();
            isExecuted = false;
            throw excep;
            ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
        }
        return isExecuted;
    }
     /*
      *Name :rdsTriggerHistory
      * */ 
     public void rdsTriggerHistory(SObject[] updatedObjects,Boolean isInsert, Boolean isUpdate)
     {
      try{   
        listofv4 = updatedObjects;
        Set<Id> rdsIdsetVLAN = New Set<Id>();
        Set<Id> rdsIdsetCVLAN = New Set<Id>();
        List<RDS_History_Tracking__c> rdsHistoryTrackingList = New List<RDS_History_Tracking__c>();
        List<Messaging.SingleEmailMessage> listOfMails = new List<Messaging.SingleEmailMessage>();
        List<RDS_History_Tracking__c> rdsexistingHistoryRecordList=New List<RDS_History_Tracking__c>();
        String opptyName;
        String reportURL;
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        
        if(isInsert || isUpdate)
        {
            for (RDS_V4_Family_Data__c v4familyRecord: listofv4  ){
                if(v4familyRecord.Routing_Protocol__c!=SIConstants.ROUTINGPROTOCOL && v4familyRecord.Encrypted_Password__c!=null && v4familyRecord.RDS_VLAN_Information_V4__c!=null){
                    rdsIdsetVLAN.add(v4familyRecord.Id);
                }
                if(v4familyRecord.Routing_Protocol__c!=SIConstants.ROUTINGPROTOCOL && v4familyRecord.Encrypted_Password__c!=null && v4familyRecord.RDS_Circuit_and_VLAN_Details_V4__c!=null){
                    rdsIdsetCVLAN.add(v4familyRecord.Id);
                }
            }
            if(!rdsIdsetVLAN.isEmpty() && rdsIdsetVLAN.size()>0){
                List<RDS_V4_Family_Data__c> v4familyRecordList=[Select Id,RDS_V4_Family_Data__c.RDS_VLAN_Information_V4__r.Circuit_and_VLAN_Details__r.Premise__r.DealHash__r.Opportunity__r.Owner.Email,RDS_V4_Family_Data__c.RDS_VLAN_Information_V4__r.Circuit_and_VLAN_Details__r.Premise__r.ID,RDS_VLAN_Information_V4__r.Id,RDS_V4_Family_Data__c.RDS_VLAN_Information_V4__r.Circuit_and_VLAN_Details__r.Premise__r.DealHash__r.Opportunity__r.Name ,RDS_V4_Family_Data__c.RDS_VLAN_Information_V4__r.Circuit_and_VLAN_Details__r.ID,RDS_VLAN_Information_V4__r.Circuit_and_VLAN_Details__r.Premise__r.DealHash__r.Id,Routing_Protocol__c,Encrypted_Password__c from RDS_V4_Family_Data__c where Id IN:rdsIdsetVLAN];
                if(v4familyRecordList.size()>0){
                    for(RDS_V4_Family_Data__c v4famRecord:v4familyRecordList){                        
                        List<String> sendTo= new List<String>();
                        sendTo.add(v4famRecord.RDS_VLAN_Information_V4__r.Circuit_and_VLAN_Details__r.Premise__r.DealHash__r.Opportunity__r.Owner.Email);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(sendTo);
                        opptyName=v4famRecord.RDS_VLAN_Information_V4__r.Circuit_and_VLAN_Details__r.Premise__r.DealHash__r.Opportunity__r.Name;
                        reportURL=sfdcBaseURL+'/'+Label.RDS_History_Tracking_Report_ID+'?pv1='+opptyName;
                        mail.setSubject('RDS - Information correction needed');
                        mail.setHtmlBody('<table><tr><td>Dear EBM,</td></tr><br/><tr><td>Please see attached report and make necessary corrections to RDS.  RDS review will not be completed without this information.</td></tr><br/><br/><tr><td>Click Here to view the Report</td></tr><tr><td>'+reportURL+'</td></tr><br/><tr><td>Best regards,</td></tr><br/><tr><td>SFDC Admin</td></tr></table>'); 
                        listOfMails.add(mail);
                        RDS_History_Tracking__c rdshistory= New  RDS_History_Tracking__c();
                        rdshistory.DealHash__c=v4famRecord.RDS_VLAN_Information_V4__r.Circuit_and_VLAN_Details__r.Premise__r.DealHash__r.Id;
                        rdshistory.V4Family__c=v4famRecord.Id;
                        rdshistory.RDSCircuitVLANDetails__c =v4famRecord.RDS_VLAN_Information_V4__r.Circuit_and_VLAN_Details__r.ID;
                        rdshistory.PremiseDetails__c=v4famRecord.RDS_VLAN_Information_V4__r.Circuit_and_VLAN_Details__r.Premise__r.Id;
                        rdshistory.Routing_Protocal__c=v4famRecord.Routing_Protocol__c;
                        rdshistory.Opportunity_Name__c=v4famRecord.RDS_VLAN_Information_V4__r.Circuit_and_VLAN_Details__r.Premise__r.DealHash__r.Opportunity__r.Name;
                        rdshistory.RDSModifiedDateTime__c= DateTime.Now();
                        rdshistory.Encrypted_Password__c =v4famRecord.Encrypted_Password__c;                        
                        
                        rdsHistoryTrackingList.add(rdshistory);
                    }  
                }           
                rdsexistingHistoryRecordList=[Select ID from RDS_History_Tracking__c where V4Family__c=:rdsIdsetVLAN];           
            }
            
            else if(!rdsIdsetCVLAN.isEmpty() && rdsIdsetCVLAN.size()>0){
                List<RDS_V4_Family_Data__c> v4familyRecordList=[Select Id,RDS_V4_Family_Data__c.RDS_Circuit_and_VLAN_Details_V4__r.Premise__r.DealHash__r.Opportunity__r.Owner.Email,RDS_V4_Family_Data__c.RDS_Circuit_and_VLAN_Details_V4__r.Premise__r.ID,RDS_Circuit_and_VLAN_Details_V4__r.Id,RDS_V4_Family_Data__c.RDS_Circuit_and_VLAN_Details_V4__r.Premise__r.DealHash__r.Opportunity__r.Name ,RDS_Circuit_and_VLAN_Details_V4__r.Premise__r.DealHash__r.Id,Routing_Protocol__c,Encrypted_Password__c from RDS_V4_Family_Data__c where Id IN:rdsIdsetCVLAN];
                if(v4familyRecordList.size()>0){
                    for(RDS_V4_Family_Data__c v4famRecord:v4familyRecordList){
                    
                        List<String> sendTo= new List<String>();
                        sendTo.add(v4famRecord.RDS_Circuit_and_VLAN_Details_V4__r.Premise__r.DealHash__r.Opportunity__r.Owner.Email);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(sendTo);
                        opptyName=v4famRecord.RDS_Circuit_and_VLAN_Details_V4__r.Premise__r.DealHash__r.Opportunity__r.Name;
                        reportURL=sfdcBaseURL+'/'+Label.RDS_History_Tracking_Report_ID+'?pv1='+opptyName;
                        mail.setSubject('RDS - Information correction needed');
                        mail.setHtmlBody('<table><tr><td>Dear EBM,</td></tr><br/><tr><td>Please see attached report and make necessary corrections to RDS.  RDS review will not be completed without this information.</td></tr><br/><br/><tr><td>Click Here to view the Report</td></tr><tr><td>'+reportURL+'</td></tr><br/><tr><td>Best regards,</td></tr><br/><tr><td>SFDC Admin</td></tr></table>'); 
                        listOfMails.add(mail);
                        RDS_History_Tracking__c rdshistory= New  RDS_History_Tracking__c();
                        rdshistory.DealHash__c=v4famRecord.RDS_Circuit_and_VLAN_Details_V4__r.Premise__r.DealHash__r.Id;
                        rdshistory.V4Family__c=v4famRecord.Id;
                        rdshistory.RDSCircuitVLANDetails__c =v4famRecord.RDS_Circuit_and_VLAN_Details_V4__r.ID;
                        rdshistory.PremiseDetails__c=v4famRecord.RDS_Circuit_and_VLAN_Details_V4__r.Premise__r.Id;
                        rdshistory.Routing_Protocal__c=v4famRecord.Routing_Protocol__c;
                        rdshistory.Opportunity_Name__c=v4famRecord.RDS_Circuit_and_VLAN_Details_V4__r.Premise__r.DealHash__r.Opportunity__r.Name;
                        rdshistory.RDSModifiedDateTime__c= DateTime.Now();
                        rdshistory.Encrypted_Password__c =v4famRecord.Encrypted_Password__c;                        
                        
                        rdsHistoryTrackingList.add(rdshistory);
                    } 
                }
                rdsexistingHistoryRecordList=[Select ID from RDS_History_Tracking__c where V4Family__c=:rdsIdsetCVLAN];       
            }
            
            if (rdsexistingHistoryRecordList.size()>0){
                try{
                    Database.Delete(rdsexistingHistoryRecordList);
                }catch(Exception exe){
                    exe.getMessage();
                    ATTException.logException( exe.getTypeName(), ATTException.constructExceptionMessageString(exe));
                }
            }
            if(rdsHistoryTrackingList.size()>0){ 
                try{
                    Database.Insert(rdsHistoryTrackingList);
                }catch(Exception exe){
                    exe.getMessage();
                ATTException.logException( exe.getTypeName(), ATTException.constructExceptionMessageString(exe));   
                }
            }
        
        }
        if(isInsert && listOfMails != null && listOfMails.size() > 0){
            Messaging.sendEmail(listOfMails);
        }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    
    } 
    /*
    The method is to set the isMD5 required checkbox on oppty, based on which MD5 call goes out. 
    This is to restrict MD5 call is only sent whenever required and not always i.e. whenever v4 family data comes with routing protocol = BGP4 and encrypted passwoed!=null 
    */   
    /*public void checkMd5RequiredCheckboxOnOppty(SObject[] updatedObjects){
        List<RDS_V4_Family_Data__c> listofv4 =updatedObjects;
        Map<Id,Opportunity> opptyMap= New Map<Id,Opportunity>();
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> opptyIdSet1 = new Set<Id>();
        Boolean v4MD5Checktrue=false;
        Boolean v4MD5CheckFalse=false;
        Boolean fieldUpdated = false;           
        
        for(RDS_V4_Family_Data__c v4:listofv4){   
            if(v4.Is_MD5_Call_Required__c == true){ 
                    v4MD5Checktrue=true;                
            }else{                 
                    v4MD5CheckFalse=true;
            }      
            opptyIdSet.add(v4.Selected_Opportunity_On_RDS__c);            
        }
        if(opptyIdSet.size()>0){
            for(Opportunity oppty: [Select id,Is_MD5_Call_Required__c from Opportunity where ID IN:opptyIdSet]){
                opptyMap.put(oppty.Id,oppty);
            }
        }
        
        if(!opptyMap.isEmpty() && opptyMap.size()>0){
            for(Opportunity opp:opptyMap.Values()){
                if(opp.Is_MD5_Call_Required__c == false && v4MD5Checktrue){
                    opp.Is_MD5_Call_Required__c = true;  
                    fieldUpdated = true;
                } /*else if(opp.Is_MD5_Call_Required__c == true && v4MD5CheckFalse){
                    opp.Is_MD5_Call_Required__c = false;  
                    fieldUpdated = true;
                }
            }
        }*/
        /*if(opptyMap.size()>0 && !opptyMap.isEmpty() && fieldUpdated){
            try{
                update opptyMap.Values();
            }
            Catch(Exception e){
                e.getMessage();
            }
        }
    
    }*/
/* 
 Name: checkMd5RequiredCheckboxOnOppty
 Description: 
 */ 
    public void checkMd5RequiredCheckboxOnOppty(SObject[] updatedObjects){
    try{    
        List<RDS_V4_Family_Data__c> listofv4 =updatedObjects;
        Map<Id,Opportunity> opptyMap= New Map<Id,Opportunity>();
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> opptyIdSet1 = new Set<Id>();
        Boolean v4MD5Checktrue=false;
        Boolean v4MD5CheckFalse=false;
        Boolean fieldUpdated = false;
        List<Opportunity>opptyList =  new List<Opportunity>();
        List<Opportunity>updatedOpptyList =  new List<Opportunity>();
        Set<ID> v4Set1= new Set<ID>();
        Set<Decimal> v4Set2= new Set<Decimal>();  

    for(RDS_V4_Family_Data__c v4:listofv4){ 
        if(v4.Is_MD5_Call_Required__c == true){
            V4Set1.add(v4.Deal_Hash_ID__c);
            v4Set2.add(v4.Version_From_Premise__c);
        }       
        }
    
    
     OpptyList = [Select id,RDS_Version__c,RDS_Deal_Hash__c,MACD_Type__c From Opportunity where RDS_Version__c IN: v4Set2 AND RDS_Deal_Hash__c IN: v4Set1 AND MACD_Type__c !=: UtilityConstant.C AND MACD_Type__c !=: UtilityConstant.D];
        if(OpptyList.size()>0){
            for(Opportunity Opp:OpptyList){
                for(RDS_V4_Family_Data__c v4:listofv4)
                    if(opp.RDS_Version__c== v4.Version_From_Premise__c && opp.RDS_Deal_Hash__c==v4.Deal_Hash_ID__c && v4.Is_MD5_Call_Required__c == true && opp.MACD_Type__c != UtilityConstant.C && opp.MACD_Type__c != UtilityConstant.D)
                    {
                        opp.Is_MD5_Call_Required__c = true; 
                        UpdatedOpptyList.add(opp);
                    }
                }
        }
     if(UpdatedOpptyList.size()>0){
            try{
                update UpdatedOpptyList;
            }
            Catch(Exception e){
                e.getMessage();
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
    
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
  }
 
}