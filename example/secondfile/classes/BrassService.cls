/************************************************************************************** 
 Apex Class Name     : AddrValidServAvailService
 Version             : 1.0 
 Created Date        : 11 Aug 2014
 Function            : Service class to handle the address validation and service availability request
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gustavo Restrepo            8/11/2014              Original Version
*************************************************************************************/

public with sharing class BrassService {    
    /* public ATTServiceInfoBean BrassServiceRequest(Apex2JSON_AIARequest requestBean) {
         ATTServiceFactory service = new ATTServiceFactory();         
         Object obj = service.getService(ATTConstants.AIA_WEBSERVICE);      
         Apex2JSON_AIAResponse resBean = new Apex2JSON_AIAResponse();         
         if(obj != null  && obj instanceOf BrassIntegrationHandler) {                                                     
            BrassIntegrationHandler handler = (BrassIntegrationHandler) obj; 
            resBean = (Apex2JSON_AIAResponse)handler.handleServiceRequest(requestBean);
         }
         return resBean;
         //Additional logic will be implemented here.   
    }*/
    
    public ATTServiceInfoBean BrassServiceRequest(BRASS_Apex2JSON_Request requestBean) {
         try {
             ATTServiceFactory service = new ATTServiceFactory();         
             Object obj = service.getService(ATTConstants.AIA_WEBSERVICE);      
             BRASS_Acknowledgement_Response resBean = new BRASS_Acknowledgement_Response();         
             if(obj != null  && obj instanceOf BrassIntegrationHandler) {                                                     
                BrassIntegrationHandler handler = (BrassIntegrationHandler) obj; 
                resBean = (BRASS_Acknowledgement_Response) handler.handleServiceRequest(requestBean);
             }
             return resBean;
         }catch (Exception e) {
            String exceptionString = ATTException.constructExceptionMessageString(e);
            ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);            
            return null;
        }
    }
}