/*************************************************************************************************************************************** 
Apex Class Name     : RDSExcelExceptionHandling
Version             : 1.0 
Created Date        : 1 Feb 2016 
Function            : This class handles exception handling for RDS/API Calls/Contract Renewal flows
****************************************************************************************************************************************/
public class RDSExcelExceptionHandling{
    Opportunity Opp ;
    ITS_Ticket_Flag__c itsFlag= ITS_Ticket_Flag__c.getInstance();
    
    /*Method to create ITS Support Ticket for RDS Excel Creation Failure*/    
    public void changeOpptyStatus(Id oppId, string ExcelStat,string failReason,string quoteName){
        try{             
            Opp = [select Id,Name,BID_ID__c,RDS_Excel_status__c,RDS_Excel_failure_reason__c from Opportunity where Id =: oppId];
            Opp.RDS_Excel_status__c = ExcelStat;
            Opp.RDS_Excel_failure_reason__c = failReason;
            update Opp;
            //Custom Setting to on/off the ITS ticket creation
            if(itsFlag.Create_ITS__c && !string.isBlank(failReason)){
                createITS(failReason,Opp.BID_ID__c,Opp.Id);
            }                 
        }
        catch(exception e){
            failReason='Catch changing status of Oppty: '+e.getLinenumber();
            if(itsFlag.Create_ITS__c && !string.isBlank(failReason)){
                createITS(failReason,Opp.BID_ID__c,Opp.Id);
            }
            system.debug('Exception while changing status of Oppty: '+e.getLinenumber());
        }
    }
        
    /*Create ITS Support Ticket for RDS Excel Creation*/     
    public void createITS(string failedR, string sname, Id opptyId){
        IT_Support_Ticket__c itss = new IT_Support_Ticket__c();
        itss.Related_to__c = 'Force Portal/BID Portal';
        itss.Logged_Date_Time__c = System.Now();
        itss.Ticket_Subject__c = 'RDS Excel Creation Failed for Quote Id: '+sname ;
        itss.Impact__c = 'High';
        itss.Severity__c = '2 - High';
        string err = 'Excel Failure for Quote Id: '+sname+'\n'+failedR;
        itss.Error_Message_Received__c = err;
        itss.Related_Opportunity__c = opptyId;
        insert itss;
    }
    
    /*Create ITS Support Ticket in case of API Call Failure*/    
    public void createAPITicket(map<id,Apttus_Proposal__Proposal__c> failedAPICallMap){
        final string RELATED_TO = 'SI/VAR-API';
        final string TKT_SUBJECT = 'API Failure due to service unavailable';
        final string SEVERITY = '2 - High';
        final string IMPACT = 'API Call Failed Due to Service Unavailable, User is unable to continue in portal for this order and potentially others';
        list<IT_Support_Ticket__c> insertITSList = new list<IT_Support_Ticket__c>();
        try{
            for(Apttus_Proposal__Proposal__c apObj : failedAPICallMap.values()){
                IT_Support_Ticket__c itObj = new IT_Support_Ticket__c();                    
                itObj.Related_to__c = RELATED_TO ;
                itObj.Ticket_Subject__c = TKT_SUBJECT;
                itObj.Severity__c = SEVERITY;
                itObj.Steps_to_Reproduce_Error__c = 'Order '+ apObj.Name +' is receiving API failure due to Service being Unavailable for one or more APIs in the system. SP User has tried multiple time to retrigger API in the system.'+'\n'+'Please investigate '+apObj.Name;  
                itObj.Impact__c = IMPACT;
                itObj.Status__c = Constant.Status_Open;
                itObj.RelatedQuote__c = apObj.id;
                itObj.Logged_Date_Time__c = System.Now();
                itObj.OwnerId = apObj.ownerId;
                insertITSList.add(itObj);                    
            }
            if(!insertITSList.isEmpty()){
                insert insertITSList;
            }
        }
        catch(Exception exce){
            string exceptionString = ATTException.constructExceptionMessageString(exce);
            ATTException.createExceptionWithoutFuture( 'RDSExcelExceptionHandling createAPITicket',exceptionString, exce.getMessage());        
        }   
    }
        
    /*Create ITS Support Ticket in case of Deal Rate Plan Failure for Contract Renewal Flow*/
    public void createContractRenewalITSTicket(map<id,Opportunity> renewalContractOpptyMap){
        final string RELATED_TO = RenewConstant.RENEW_SIVAR_API;
        final string TKT_SUBJECT = RenewConstant.RENEW_DEALRATE_PLAN_API_FAILURE;
        final string SEVERITY = RenewConstant.RENEW_HIGH;
        final string IMPACT = RenewConstant.RENEW_ITS_API_IMPACT_MSG;
        list<IT_Support_Ticket__c> insertITSList = new list<IT_Support_Ticket__c>();
        try{
            for(Opportunity oppty : renewalContractOpptyMap.values()){
                IT_Support_Ticket__c itObj = new IT_Support_Ticket__c();                    
                itObj.Related_to__c = RELATED_TO;                
                itObj.Ticket_Subject__c = TKT_SUBJECT;
                itObj.Severity__c = SEVERITY;
                itObj.Steps_to_Reproduce_Error__c = RenewConstant.RENEW_DEALRATE_PLAN_API_FAILURE+'\n'+RenewConstant.RENEW_REPRODUCE_ERR_MSG2+oppty.Quote_ID__c+RenewConstant.RENEW_REPRODUCE_ERR_MSG3;  
                itObj.Impact__c = IMPACT;
                itObj.Status__c = RenewConstant.RENEW_ITS_API_STATUS;
                itObj.Logged_Date_Time__c = System.Now();
                itObj.OwnerId = oppty.createdById;
                itObj.Related_Opportunity__c = oppty.Id;
                insertITSList.add(itObj);                    
            }
            if(!insertITSList.isEmpty()){
                insert insertITSList;
            }
        }
        catch(Exception exce){
            string exceptionString = ATTException.constructExceptionMessageString(exce);
            ATTException.createExceptionWithoutFuture( 'RDSExcelExceptionHandling createContractRenewalITSTicket',exceptionString, exce.getMessage());            
        }   
    }
    
    /*201945 Contract Renewal  ITS Ticket Creation  IDH Failure After WFE Push Notification*/
    public void createContractRenewalIDHITSTicket(map<id,RDS_Premise_Details__c> renewalContractPremiseMap){
        list<IT_Support_Ticket__c> insertITSList = new list<IT_Support_Ticket__c>();
        try{
            for(RDS_Premise_Details__c premise : renewalContractPremiseMap.values()){
                IT_Support_Ticket__c itObj = new IT_Support_Ticket__c();                    
                itObj.Related_to__c = RenewConstant.RENEW_SIVAR_API;                
                itObj.Ticket_Subject__c = RenewConstant.RENEW_IDHAFTER_PUSH_NOTI_FAILURE;
                itObj.Severity__c = RenewConstant.RENEW_HIGH;
                itObj.Steps_to_Reproduce_Error__c = RenewConstant.RENEW_IDHAFTER_PUSH_NOTI_FAILURE+'\n'+RenewConstant.RENEW_REPRODUCE_ERR_MSG2+premise.Renewal_Contract_Quote__c+RenewConstant.RENEW_OR+premise.Renewal_Contract_Deal_Hash__c+RenewConstant.RENEW_REPRODUCE_ERR_MSG3;  
                itObj.Impact__c = RenewConstant.RENEW_IDH_PUSH_NOTI_FAILURE_IMPACT_MSG;
                itObj.Status__c = RenewConstant.RENEW_ITS_API_STATUS;
                itObj.Logged_Date_Time__c = System.Now();
                itObj.OwnerId = premise.createdById;
                itObj.RelatedQuote__c = premise.RelatedQuote__c;
                insertITSList.add(itObj);                    
            }
            if(!insertITSList.isEmpty()){
                insert insertITSList;
            }
        }
        catch(Exception exce){
            string exceptionString = ATTException.constructExceptionMessageString(exce);
            ATTException.createExceptionWithoutFuture( 'RDSExcelExceptionHandling createContractRenewalIDHITSTicket',exceptionString, exce.getMessage());            
        }   
    }
    
    /*201972 Contract Renewal  ITS Ticket Creation & Email Notification  Automatic MACD Update Deal Hash Failure - Scenario one : DH MACD Update Status */
    public void createContractRenewalDHITSTicket(Map<id,Deal_Hash__c> renewalContractDealHashMap){
        list<IT_Support_Ticket__c> insertITSList = new list<IT_Support_Ticket__c>();
        try{
            for(Deal_Hash__c dealHashObj : renewalContractDealHashMap.values()){
                IT_Support_Ticket__c itObj = new IT_Support_Ticket__c();                    
                itObj.Related_to__c = RenewConstant.RENEW_SIVAR_API; 
                if(dealHashObj.RDS_object_status__c!=null && dealHashObj.RDS_object_status__c.equalsIgnoreCase('Deal Hash Creation API Failed'))
                {               
                    itObj.Ticket_Subject__c = 'Contract Renewal – Automatic Update Deal Hash Failure';
                    itObj.Steps_to_Reproduce_Error__c = 'Contract Renewal – Automatic Update Deal Hash Failure'+'\n'+RenewConstant.RENEW_REPRODUCE_ERR_MSG2+dealHashObj.Renewal_Contract_Quote_Name__c+RenewConstant.RENEW_OR+dealHashObj.Name+RenewConstant.RENEW_REPRODUCE_ERR_MSG3;  
                } 
                else
                {
                    itObj.Ticket_Subject__c = RenewConstant.RENEW_MACDUPDATE_FAILURE;
                     itObj.Steps_to_Reproduce_Error__c = RenewConstant.RENEW_MACDUPDATE_FAILURE+'\n'+RenewConstant.RENEW_REPRODUCE_ERR_MSG2+dealHashObj.Renewal_Contract_Quote_Name__c+RenewConstant.RENEW_OR+dealHashObj.Name+RenewConstant.RENEW_REPRODUCE_ERR_MSG3;  
                }
                itObj.Severity__c = RenewConstant.RENEW_HIGH;
               
                itObj.Impact__c = RenewConstant.RENEW_MACDUPDATE_IMPACT_MSG;
                itObj.Status__c = RenewConstant.RENEW_ITS_API_STATUS;
                itObj.Logged_Date_Time__c = System.Now();
                itObj.OwnerId = dealHashObj.createdById;
                itObj.RelatedQuote__c = dealHashObj.RenewedQuote__c;
                insertITSList.add(itObj);                    
            }
            if(!insertITSList.isEmpty()){
                insert insertITSList;
            }
        }
        catch(Exception exce){
            string exceptionString = ATTException.constructExceptionMessageString(exce);
            ATTException.createExceptionWithoutFuture( 'RDSExcelExceptionHandling createContractRenewalMACDUpdateITSTicket',exceptionString, exce.getMessage());            
        }   
    }
    
    /*201972 Contract Renewal  ITS Ticket Creation & Email Notification  Automatic MACD Update Deal Hash Failure - Scenario one : DHS API Process Status    */
    public void createContractRenewalDHSITSTicket(Map<id,DHStatus_Update_Deal_Hash_Details__c> renewalContractDhStatusMap){
        list<IT_Support_Ticket__c> insertITSList = new list<IT_Support_Ticket__c>();
        try{
            for(DHStatus_Update_Deal_Hash_Details__c dhStatusObj : renewalContractDhStatusMap.values()){
                IT_Support_Ticket__c itObj = new IT_Support_Ticket__c();                    
                itObj.Related_to__c = RenewConstant.RENEW_SIVAR_API;   
                           
                itObj.Ticket_Subject__c = RenewConstant.RENEW_MACDUPDATE_FAILURE;
                itObj.Severity__c = RenewConstant.RENEW_HIGH;
                itObj.Steps_to_Reproduce_Error__c = RenewConstant.RENEW_MACDUPDATE_FAILURE+'\n'+RenewConstant.RENEW_REPRODUCE_ERR_MSG2+dhStatusObj.Renewal_Contract_Quote_Name__c+RenewConstant.RENEW_OR+dhStatusObj.Deal_Hash_Name__c+RenewConstant.RENEW_REPRODUCE_ERR_MSG3;  
                itObj.Impact__c = RenewConstant.RENEW_MACDUPDATE_IMPACT_MSG;
                itObj.Status__c = RenewConstant.RENEW_ITS_API_STATUS;
                itObj.Logged_Date_Time__c = System.Now();
                itObj.OwnerId = Id.ValueOf(dhStatusObj.Deal_Hash_Created_By__c);
                itObj.RelatedQuote__c = dhStatusObj.Renewed_Quote__c;
                insertITSList.add(itObj);                    
            }
            if(!insertITSList.isEmpty()){
                insert insertITSList;
            }
        }
        catch(Exception exce){
            string exceptionString = ATTException.constructExceptionMessageString(exce);
            ATTException.createExceptionWithoutFuture( 'RDSExcelExceptionHandling createContractRenewalMACDUpdateITSTicket',exceptionString, exce.getMessage());            
        }   
    }
}