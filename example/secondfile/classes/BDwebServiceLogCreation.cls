/************************************************************************************** 
 Apex Class Name     : BDwebServiceLogCreation
 Version             : 1.1
 Created Date        : 13 Oct 2015
 Function            : This class handles webservice log creation with request & response JSONs 
*************************************************************************************/
public class BDwebServiceLogCreation
{
public static List<WebServiceLog__c> WebLogList;
    public BDwebServiceLogCreation(){
        
        if(WebLogList == NULL){
            WebLogList = new List<WebServiceLog__c>();
        }
        else{
            system.debug('***********************'+WebLogList.size());
        }
    }
    public void createWebserviceLogs(string requestBean, string ResponseString,ATTRequestResponseBean responseClass,Id SobjectID,string convID,HttpResponse response){
         WebServiceLog__c objWebLog = new WebServiceLog__c();
         
        
        try{
                  
             objWebLog.WSLogTitle__c = 'BD Company/User Creation Logs' ;
             objWebLog.Request_Data__c = requestBean;
             objWebLog.Conversation_Id__c = convID;
             system.debug('Header Keys'+response.getHeaderKeys());
                          
             objWebLog.Message_Id__c = response.getHeader('mule-message-id');
             objWebLog.Notification_Message__c= 'mule root Id: '+ response.getHeader('mule-root-id');
             //If Account
             if((string.Valueof(SobjectID)).substring(0,3) == '001'){
                 objWebLog.Account_Id_WSLog__c = SobjectID;
             }
             
             else if((string.Valueof(SobjectID)).substring(0,3) == '003'){
                 objWebLog.Contact_Id_WSLog__c = SobjectID;
             }                    
             
             string responseLog;
             if(!String.isBlank(ResponseString)){
                 
                 if(!String.isBlank(objWebLog.Response_Data__c)){
                     objWebLog.Response_Data__c += '\r\n';
                     objWebLog.Response_Data__c= objWebLog.Response_Data__c+ResponseString;
                     }
                  else{
                     objWebLog.Response_Data__c=ResponseString;
                  }
                 objWebLog.Response_Data__c += '\r\n';
                if(ResponseString.contains('code') || (responseClass.statuscode == 400)){
                 objWebLog.WSLog_error__c = ResponseString;
             }    
                     
             }       
         
         if(objWebLog != NULL){
            WebLogList.add(objWebLog);
        
         }
      
        }
        catch (Exception exc) {
            String exceptions = ATTException.constructExceptionMessageString(exc);
            system.debug('Exception thrown (line 59 webService log creation): '+exceptions);            
            
        }
    }
    //Insert Web Service Logs
    public void insertWeBlogs(){
        try{
            if(WebLogList.size()>0){
                insert WebLogList;
            }
        }
        catch (Exception exc) {
            String exceptions = ATTException.constructExceptionMessageString(exc);
            system.debug('Exception thrown (line 72 webService log creation): '+exceptions);            
            }
        }
    }