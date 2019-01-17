/************************************************************************************** 
 Apex Class Name     : BirchwebServiceLogCreation
 Version             : 1.1
 Created Date        : 13 Oct 2015
 Function            : This class handles webservice log creation with request & response JSONs 
*************************************************************************************/
public class BirchwebServiceLogCreation
{
	public static List<WebServiceLog__c> WebLogList;
    public BirchwebServiceLogCreation(){
        
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
                  
               objWebLog.WSLogTitle__c = 'Birch Account/User Create/Update Logs' ;
                objWebLog.Message_Id__c = response.getHeader('Mule-MessageID');

             objWebLog.Request_Data__c = requestBean;
             objWebLog.Conversation_Id__c = convID;
             system.debug('Header Keys'+response.getHeaderKeys());
                          
             
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
                if(responseClass.statuscode != 1){
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
        System.debug('\n WebLogList='+WebLogList);
        System.debug('\n WebLogList size='+WebLogList.size());
            List<WebServiceLog__c> finalWebLogList = new List<WebServiceLog__c>();
            if(WebLogList.size()>0)
            {
                for(WebServiceLog__c tWeb : WebLogList)
                {
                    System.debug('\n tWeb.Response_Data__c='+tWeb.Response_Data__c);
                    if(tWeb.Response_Data__c == null || !tWeb.Response_Data__c.containsIgnoreCase('Address1 cannot be null'))
                    {
                        System.debug('match found for address');
                        finalWebLogList.add(tWeb);
                    }
                }
                insert finalWebLogList;
            }
        }
        catch (Exception exc) {
            String exceptions = ATTException.constructExceptionMessageString(exc);
            system.debug('Exception thrown (line 72 webService log creation): '+exceptions);            
            }
        }
    }