/************************************************************************************** 
 Apex Class Name     : ITPAServiceAvailIntegrationHandler
 Version             : 1.0 
 Created Date        : 1st March 2016
 Function            : Class that handles building ITPA request and parsing response 
 
***************************************************************************************/

public with sharing class ITPAServiceAvailIntegrationHandler implements ITPAServiceIntegrationInterface {

     //Handles Lead Transfer Webservice request
     public  ITPAServiceInfoBean handleServiceRequest(ITPAServiceInfoBean serviceInfobean){
         try {
            ITPAServiceAvailInfoBean requestBean = new ITPAServiceAvailInfoBean();
            requestBean=(ITPAServiceAvailInfoBean)serviceInfobean;
            string request = buildJSONRequest(requestBean);
            String conResult = '{'+request.substring(15);
            ITPAServiceAvailResponseBean webServiceResponse = new ITPAServiceAvailResponseBean();
           
            if(requestBean!=null && requestBean.InquireTransportProductAvailabilityRequest!=null && requestBean.InquireTransportProductAvailabilityRequest.Address!=null) {      
                  webServiceResponse = parseResponse(sendRequestAndReceiveResponse(conResult));
                  return webServiceResponse ;
            }                                       
            return null;
        }catch (Exception e) {
            system.debug('Exception in ITPAServiceAvailIntegrationHandler.handleServiceRequest'+e);                 
            return null;
        }
     }               

    //Build JSON Request
    private String buildJSONRequest(ITPAServiceAvailInfoBean addrValidServAvailBeanInst){
        return JSON.serialize(addrValidServAvailBeanInst);
    }

    //Make actual web service call
    private ITPARequestResponseBean sendRequestAndReceiveResponse(String request){
        try {   
            ITPARequestResponseBean bean = new ITPARequestResponseBean();
            bean.Body = request;
            bean.GetPostMethod = ATTConstants.PostMethod;
            bean.ContentType = ATTConstants.JsonContentType;               
            bean.TimeOut = Global_Variable__c.getValues('Session_Timeout') != null ? Global_Variable__c.getValues('Session_Timeout').Value__c : '12000';
            bean.EndPoint =  Endpoint_URL__c.getValues('End_Point_ITPAService') != null ? Endpoint_URL__c.getValues('End_Point_ITPAService').URL__c : '';
            ITPASendRequestAndReceiveResponse conn = new ITPASendRequestAndReceiveResponse();
            return conn.sendRequestAndReceiveResponse(bean);                  
        }catch (Exception e) {
            system.debug('Exception in ITPAServiceAvailIntegrationHandler.sendRequestAndReceiveResponse'+e);        
            return null;
        }
    }

    //Parse the response and store it in bean object
    private ITPAServiceAvailResponseBean parseResponse(ITPARequestResponseBean resBean) {    
        try {        
            ITPAServiceAvailResponseBean responseBean = new ITPAServiceAvailResponseBean();        
            if(resBean !=null && resBean.response.contains('"ProductVoiceOverIP"')){          
                responseBean = (ITPAServiceAvailResponseBean)JSON.deserialize(resBean.Response,ITPAServiceAvailResponseBean.class);                                    
                responseBean.status = ATTConstants.SUCCESS;
                responseBean.JSONResponse = resBean.Response;                      
            } else {
                responseBean.status = ATTConstants.FAILURE;            
            }        
            return responseBean;
        }catch (Exception e) {
            system.debug('Exception in ITPAServiceAvailIntegrationHandler.parseResponse'+e);
            return null;
        }
    }
                 
}