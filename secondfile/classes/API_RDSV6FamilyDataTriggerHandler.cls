/*
     Component Name :API_RDSV6FamilyDataTriggerHandler
     Requirement/User Story Number : US238470 
     Requirement Description:Insert History Tracking Record on V6 Record insert
     Component Author:Accenture IDC
     Created Date:5th May 2014 
     Version:1.0
     Version 1.1: updated the logic around inserting record in history table matching the routing protocol and Encrypted password.
     Last Modified By: Accenture IDC
    */
    public with sharing class API_RDSV6FamilyDataTriggerHandler extends SITriggerOperations.SITriggerImpl{
    
      public boolean isExecuted ;
      Set<Id> rdsIdsetVLAN = New Set<Id>();
      Set<Id> rdsIdsetCVLAN = New Set<Id>();
      List<RDS_History_Tracking__c> rdsHistoryTrackingList = new List<RDS_History_Tracking__c>();
      List<Messaging.SingleEmailMessage> listOfMails = new List<Messaging.SingleEmailMessage>();
      List<V6_Family_Data__c> listofv6= new List<V6_Family_Data__c>();

    //Default cons
/* 
 Name: API_RDSV6FamilyDataTriggerHandler
 Description: 
 */ 
    public API_RDSV6FamilyDataTriggerHandler() {
        isExecuted = true; 
    }
    
/* 
 Name: onAfterUpdate
 Description: 
 */ 
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap )  {
        try {
            rdsV6TriggerHistory(updatedObjects,false,true);
            
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
            
            rdsV6TriggerHistory(updatedObjects,true,false);
            
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
     * Name : rdsV6TriggerHistory
     * */
    public void rdsV6TriggerHistory(SObject[] updatedObjects,Boolean isInsert, Boolean isUpdate)
    {
    try{    
        listofv6=updatedObjects;
        String opptyName;
        String reportURL;
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        List<RDS_History_Tracking__c> rdsexistingHistoryRecordList=New List<RDS_History_Tracking__c>();
    
    
        if(isInsert || isUpdate){          
            for (V6_Family_Data__c v6familyRecord:listofv6){
                if(v6familyRecord.Routing_Protocol__c!=SIConstants.ROUTINGPROTOCOL && v6familyRecord.Encrypted_Password__c!=null && v6familyRecord.RDS_VLAN_Information__c!=null)
                  {
                   rdsIdsetVLAN.add(v6familyRecord.Id);
                  }
                if(v6familyRecord.Routing_Protocol__c!=SIConstants.ROUTINGPROTOCOL && v6familyRecord.Encrypted_Password__c!=null && v6familyRecord.RDS_Circuit_and_VLAN_Details_V6__c!=null)
                  {
                   rdsIdsetCVLAN.add(v6familyRecord.Id);
                  }
            }
            if(!rdsIdsetVLAN.isEmpty()&& rdsIdsetVLAN.size()>0 ){
                List<V6_Family_Data__c> v6familyRecordList=[Select Id,V6_Family_Data__c.RDS_VLAN_Information__r.Circuit_and_VLAN_Details__r.Premise__r.DealHash__r.Opportunity__r.Owner.Email,V6_Family_Data__c.RDS_VLAN_Information__r.Circuit_and_VLAN_Details__r.Premise__r.ID,V6_Family_Data__c.RDS_VLAN_Information__r.Id,V6_Family_Data__c.RDS_VLAN_Information__r.Circuit_and_VLAN_Details__r.Premise__r.DealHash__r.Opportunity__r.Name ,V6_Family_Data__c.RDS_VLAN_Information__r.Circuit_and_VLAN_Details__r.ID,V6_Family_Data__c.RDS_VLAN_Information__r.Circuit_and_VLAN_Details__r.Premise__r.DealHash__r.Id,Routing_Protocol__c,Encrypted_Password__c from V6_Family_Data__c where Id IN:rdsIdsetVLAN];
                if(v6familyRecordList.size()>0){
                    for(V6_Family_Data__c v6famRecord:v6familyRecordList){      
                        List<String> sendTo= new List<String>();
                        sendTo.add(v6famRecord.RDS_VLAN_Information__r.Circuit_and_VLAN_Details__r.Premise__r.DealHash__r.Opportunity__r.Owner.Email);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(sendTo);
                        mail.setSubject('RDS - Information correction needed');
                        opptyName=v6famRecord.RDS_VLAN_Information__r.Circuit_and_VLAN_Details__r.Premise__r.DealHash__r.Opportunity__r.Name;
                        reportURL=sfdcBaseURL+'/'+Label.RDS_History_Tracking_Report_ID+'?pv1='+opptyName;
                        mail.setHtmlBody('<table><tr><td>Dear EBM,</td></tr><br/><tr><td>Please see attached report and make necessary corrections to RDS.  RDS review will not be completed without this information.</td></tr><br/><br/><tr><td>Click Here to view the Report</td></tr><tr><td>'+reportURL+'</td></tr><br/><tr><td>Best regards,</td></tr><br/><tr><td>SFDC Admin</td></tr></table>'); 
                        listOfMails.add(mail);    
                        RDS_History_Tracking__c rdshistory= New  RDS_History_Tracking__c();
                        rdshistory.DealHash__c=v6famRecord.RDS_VLAN_Information__r.Circuit_and_VLAN_Details__r.Premise__r.DealHash__r.Id;
                        rdshistory.V6Family__c=v6famRecord.Id;
                        rdshistory.RDSCircuitVLANDetails__c =v6famRecord.RDS_VLAN_Information__r.Circuit_and_VLAN_Details__r.ID;
                        rdshistory.PremiseDetails__c=v6famRecord.RDS_VLAN_Information__r.Circuit_and_VLAN_Details__r.Premise__r.Id;
                        rdshistory.Routing_Protocal__c=v6famRecord.Routing_Protocol__c;
                        rdshistory.Opportunity_Name__c=v6famRecord.RDS_VLAN_Information__r.Circuit_and_VLAN_Details__r.Premise__r.DealHash__r.Opportunity__r.Name;
                        rdshistory.RDSModifiedDateTime__c= DateTime.Now();
                        rdshistory.Encrypted_Password__c =v6famRecord.Encrypted_Password__c; 
                        rdsHistoryTrackingList.add(rdshistory);
                    }  
                }
                rdsexistingHistoryRecordList=[Select ID from RDS_History_Tracking__c where V6Family__c=:rdsIdsetVLAN];  
            }   
            
            else if(!rdsIdsetCVLAN.isEmpty() && rdsIdsetCVLAN.size()>0){
                List<V6_Family_Data__c> v6familyRecordList=[Select Id,V6_Family_Data__c.RDS_Circuit_and_VLAN_Details_V6__r.Premise__r.DealHash__r.Opportunity__r.Owner.Email,V6_Family_Data__c.RDS_Circuit_and_VLAN_Details_V6__r.Premise__r.ID,V6_Family_Data__c.RDS_Circuit_and_VLAN_Details_V6__r.Premise__r.DealHash__r.Opportunity__r.Name ,V6_Family_Data__c.RDS_Circuit_and_VLAN_Details_V6__r.ID,V6_Family_Data__c.RDS_Circuit_and_VLAN_Details_V6__r.Premise__r.DealHash__r.Id,Routing_Protocol__c,Encrypted_Password__c from V6_Family_Data__c where Id IN:rdsIdsetCVLAN];
                if(v6familyRecordList.size()>0){
                    for(V6_Family_Data__c v6famRecord:v6familyRecordList){      
                        List<String> sendTo= new List<String>();
                        sendTo.add(v6famRecord.RDS_Circuit_and_VLAN_Details_V6__r.Premise__r.DealHash__r.Opportunity__r.Owner.Email);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(sendTo);
                        mail.setSubject('RDS - Information correction needed');
                        opptyName=v6famRecord.RDS_Circuit_and_VLAN_Details_V6__r.Premise__r.DealHash__r.Opportunity__r.Name;
                        reportURL=sfdcBaseURL+'/'+Label.RDS_History_Tracking_Report_ID+'?pv1='+opptyName;
                        mail.setHtmlBody('<table><tr><td>Dear EBM,</td></tr><br/><tr><td>Please see attached report and make necessary corrections to RDS.  RDS review will not be completed without this information.</td></tr><br/><br/><tr><td>Click Here to view the Report</td></tr><tr><td>'+reportURL+'</td></tr><br/><tr><td>Best regards,</td></tr><br/><tr><td>SFDC Admin</td></tr></table>'); 
                        listOfMails.add(mail);    
                        RDS_History_Tracking__c rdshistory= New  RDS_History_Tracking__c();
                        rdshistory.DealHash__c=v6famRecord.RDS_Circuit_and_VLAN_Details_V6__r.Premise__r.DealHash__r.Id;
                        rdshistory.V6Family__c=v6famRecord.Id;
                        rdshistory.RDSCircuitVLANDetails__c =v6famRecord.RDS_Circuit_and_VLAN_Details_V6__r.ID;
                        rdshistory.PremiseDetails__c=v6famRecord.RDS_Circuit_and_VLAN_Details_V6__r.Premise__r.Id;
                        rdshistory.Routing_Protocal__c=v6famRecord.Routing_Protocol__c;
                        rdshistory.Opportunity_Name__c=v6famRecord.RDS_Circuit_and_VLAN_Details_V6__r.Premise__r.DealHash__r.Opportunity__r.Name;
                        rdshistory.RDSModifiedDateTime__c= DateTime.Now();
                        rdshistory.Encrypted_Password__c =v6famRecord.Encrypted_Password__c; 
                        rdsHistoryTrackingList.add(rdshistory);
                    }
                }               
                rdsexistingHistoryRecordList=[Select ID from RDS_History_Tracking__c where V6Family__c=:rdsIdsetCVLAN];  
            }
            
            if (rdsHistoryTrackingList.size()>0){
                try{
                Database.Delete(rdsexistingHistoryRecordList);
                }Catch(Exception excp){
                excp.getMessage();
                }
            }
            if(rdsHistoryTrackingList.size()>0){ 
               try{
                Database.Insert(rdsHistoryTrackingList);
                }catch(Exception excp){
                 excp.getMessage();
                 ATTException.logException( excp.getTypeName(), ATTException.constructExceptionMessageString(excp));
                }
            }
    
        }
        if(isInsert && listOfMails != null && listOfMails.size()>0){
            Messaging.sendEmail(listOfMails);
        }
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    
    }
    /*
    The method is to set the isMD5 required checkbox on oppty, based on which MD5 call goes out. 
    This is to restrict MD5 call is only sent whenever required and not always i.e. whenever v6 family data comes with routing protocol = BGP4 and encrypted passwoed!=null 
    */   
/* 
 Name: checkMd5RequiredCheckboxOnOppty
 Description: 
 */ 
    public void checkMd5RequiredCheckboxOnOppty(SObject[] updatedObjects){
     try{   
        List<V6_Family_Data__c> listofv6 =updatedObjects;        
        List<Opportunity>opptyList =  new List<Opportunity>();
        List<Opportunity>updatedOpptyList =  new List<Opportunity>();
        Set<ID> v6Set1= new Set<ID>();
        Set<Decimal> v6Set2= new Set<Decimal>();  

    for(V6_Family_Data__c v6:listofv6){ 
        if(v6.Is_MD5_Call_Required__c == true){
            V6Set1.add(v6.Deal_Hash_ID__c);
            v6Set2.add(v6.Version_From_Premise__c);
        }       
        }
    
    if(V6Set1.size()>0 && v6Set2.size()>0){
     OpptyList = [Select id,RDS_Version__c,RDS_Deal_Hash__c,MACD_Type__c From Opportunity where RDS_Version__c IN: V6Set2 AND RDS_Deal_Hash__c IN: V6Set1 AND MACD_Type__c !=: UtilityConstant.C AND MACD_Type__c !=: UtilityConstant.D];
        if(OpptyList.size()>0){
            for(Opportunity Opp:OpptyList){
                for(V6_Family_Data__c v6:listofv6)
                    if(opp.RDS_Version__c== v6.Version_From_Premise__c && opp.RDS_Deal_Hash__c==v6.Deal_Hash_ID__c && v6.Is_MD5_Call_Required__c == true && opp.MACD_Type__c != UtilityConstant.C && opp.MACD_Type__c != UtilityConstant.D)
                    {
                        opp.Is_MD5_Call_Required__c = true; 
                        UpdatedOpptyList.add(opp);
                    }
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