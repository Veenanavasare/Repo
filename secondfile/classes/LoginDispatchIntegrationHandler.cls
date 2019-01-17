/************************************************************************************** 
 Apex Class Name     : LoginDispatchIntegrationHandler
 Version             : 1.0 
 Created Date        : 22 Oct 2014
 Function            : This class handles the Login Dispatch Request web service 
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Kumar Gupta           10/22/2014              Original Version
*************************************************************************************/
public with sharing class LoginDispatchIntegrationHandler implements ATTServiceIntegrationInterface {
     /*
         * Method name  : handleServiceRequest
         * Description  : This method will handle Lead Transfer Webservice request
         * Return Type  : ATTServiceInfoBean 
         * Parameter    : ATTServiceInfoBean 
     */  
      
     public  ATTServiceInfoBean handleServiceRequest(ATTServiceInfoBean serviceInfobean){
        Apex2JSON_LoginDispatchRequest requestBean = new Apex2JSON_LoginDispatchRequest();
        requestBean=(Apex2JSON_LoginDispatchRequest)serviceInfobean;
        string request = buildJSONRequest(requestBean);
        System.debug('Request input sent is :'+request);
        String conResult = '{'+request.substring(Integer.ValueOf(System.Label.Login_Dispatch_Substring_Length));
        system.debug('-----conResult ----- = ' + conResult );        
        ATTRequestResponseBean  aTTRequestResponseBeanobj= sendRequestAndReceiveResponse(conResult);  
        system.debug('response bean before Parsing:'+aTTRequestResponseBeanobj);                
        Apex2JSON_LoginDispatchResponse webServiceResponse = parseResponse(aTTRequestResponseBeanobj);
        system.debug('-----webServiceResponse ----- = ' + webServiceResponse );                                 
        return webServiceResponse ;
        //return null;
     }
     /*
         * Method name  : buildJSONRequest
         * Description  : This method is used to build JSON String
         * Return Type  : String
         * Parameter    : AddrValidServAvailInformationBean
     */
    private String buildJSONRequest(Apex2JSON_LoginDispatchRequest loginDispatchRequestInst){
        system.debug('-----Apex2JSON_LoginDispatchRequest.buildJSONRequest-JSON Request----- = ' + JSON.serialize(loginDispatchRequestInst));
        return JSON.serialize(loginDispatchRequestInst);
    }
     /*
         * Method name  : sendRequestAndReceiveResponse
         * Description  : This method is used to make actual webservice call.
         * Return Type  : ATTRequestResponseBean 
         * Parameter    : String
     */
    private ATTRequestResponseBean sendRequestAndReceiveResponse(String request){
           
        ATTRequestResponseBean bean = new ATTRequestResponseBean();
        bean.Body = request;
        system.debug('body:'+ bean.Body);
        bean.GetPostMethod = ATTConstants.PostMethod;
        system.debug('post::'+bean.GetPostMethod);
        bean.ContentType = ATTConstants.JsonContentType; 
        system.debug('content::'+bean.ContentType);    
        Integer timeOut=Integer.ValueOf(System.Label.Login_Dispatch_Session_Timeout);    
        system.debug('timeOut Int::'+timeOut);      
        //bean.TimeOut = Global_Variable__c.getValues(System.Label.Session_Timeout) != null ? Global_Variable__c.getValues(System.Label.Session_Timeout).Value__c : 'Integer.ValueOf(System.Label.Login_Dispatch_Session_Timeout)';
        bean.TimeOut = Global_Variable__c.getValues(System.Label.Session_Timeout) != null ? Global_Variable__c.getValues(System.Label.Session_Timeout).Value__c : ''+timeOut+'';
        system.debug('timeout::'+bean.TimeOut);
        bean.EndPoint =  Endpoint_URL__c.getValues(System.Label.END_POINT_LOGINDISPATCH) != null ? Endpoint_URL__c.getValues(System.Label.END_POINT_LOGINDISPATCH).URL__c : '';
        system.debug('endpoint::'+bean.EndPoint);
        ATTSendRequestAndReceiveResponse conn = new ATTSendRequestAndReceiveResponse();
        return conn.sendRequestAndReceiveResponse(bean);                  
    }
     /*
         * Method name  : parseResponse
         * Description  : This method is used to parse the response and store it in bean 0bject
         * Return Type  : String
         * Parameter    : ATTRequestResponseBean 
     */
    private Apex2JSON_LoginDispatchResponse parseResponse(ATTRequestResponseBean resBean){    
        system.debug('****In parse response'+resBean);            
        Apex2JSON_LoginDispatchResponse responseBean = new Apex2JSON_LoginDispatchResponse();        
       
        //mocking the sample response in resBean.Response, it should be remove when bean.EndPoint will be defined
        //resBean.Response='{"LoginDispatchResponse": {"WSResponseHeader": null,"Header": {"sourceSystem": "EBM","sourceServerDomain": "ST","transactionID": "1413313506665"},"LoginDispatch": {"TokenURL": "C5j45mSEdqfz4f4GnrwR2T25tizY5gb3JoVNtWp8DiYOW5d+qvPx/ODmQIQqNXpZ1YkIjLwu5BAjDh3QmlrC4DKwTvbSrVqxh7OJdGDQy61pY0V/p3JINnSHoA3V59y8PyEKzw0ipJYRx7aH4P45A54fHUeYAPmhl7eJfTknjgvK3gInuom2gAc05rEGSSNfrWNXFcr7/OozXbrO2lDposIo1aWyIGxHHPbH1HDxrXGv6QKkir068oPZ4JYvmwvml9MLyBajtQ6FzExrjz+iWyEpyAIGMY920/wNhfDv9Qy6wU2my048Od2Cp5l7aPvg","Response": {"code": "200","description": "SUCCESS"}}}}';
        if(resBean !=null ) {      
            System.debug('\n  resBean.Response='+resBean.Response);
            responseBean = (Apex2JSON_LoginDispatchResponse)JSON.deserialize(resBean.Response,Apex2JSON_LoginDispatchResponse.class);                                    
            responseBean.status = ATTConstants.SUCCESS;
        } else {
            responseBean.status = ATTConstants.FAILURE;  
        }    
        System.debug('responseBean-Hander-->'+responseBean);    
        return responseBean;        
    }

}