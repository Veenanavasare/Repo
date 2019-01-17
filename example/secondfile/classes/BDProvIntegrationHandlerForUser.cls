public class BDProvIntegrationHandlerForUser implements ATTServiceIntegrationInterface
{   
    public ID ContID;
    public ATTServiceInfoBean handleServiceRequest(ATTServiceInfoBean serviceInfobean){
            BDProvResponseBean webServiceResponse = new BDProvResponseBean();  
            BDUserProvRequestBean requestBean = new BDUserProvRequestBean();
            requestBean=(BDUserProvRequestBean)serviceInfobean;   
            DateTime dt = DateTime.now();                   
            String convID =  'sfdc-BD-'+dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');     
            string request = JSON.serialize(requestBean);
            String conResult ='{'+request.substring(15);
            
            webServiceResponse = parseResponse(userSendRequestAndReceiveResponse(conResult, convID));
            return webServiceResponse;
        }
        

    
     
     private BDProvResponseBean parseResponse(ATTRequestResponseBean resBean) {    
        try {
            system.debug('****In parse response'+resBean);
            system.debug('****In parse resBean.response'+resBean.response); 
            BDProvResponseBean responseBean = new BDProvResponseBean();    
            if(resBean !=null){      
                responseBean = (BDProvResponseBean)JSON.deserialize(resBean.response,BDProvResponseBean.class); 
                                
                if(responseBean == null)
                {
                    responseBean = new BDProvResponseBean(); 
                    responseBean.status = ATTConstants.FAILURE; 
                }
                else
                {
                    responseBean.status = ATTConstants.SUCCESS;
                }
                BDProvResponseBean.Response webResp = new BDProvResponseBean.Response();
                webResp.code = String.valueOf(resBean.statusCode);
                webResp.description = resBean.status;
                responseBean.Response = webResp;
                responseBean.JSONResponse = resBean.Response; 
                
            } else {
                System.debug('\n anand otherwise='+responseBean);
                responseBean.status = ATTConstants.FAILURE; 
                responseBean.JSONResponse = resBean.Response;  
                responseBean.MessageText = resBean.Status + resBean.response + resBean.body;
                
            }        
            return responseBean;
        }catch (Exception e) {
            String exceptionString = ATTException.constructExceptionMessageString(e);
            system.debug('Exception thrown (line 59): '+exceptionString);   
            return null;
        }  
    }
    
    
    
    private ATTRequestResponseBean userSendRequestAndReceiveResponse(String request, String tConvId){
        try {   
            ATTRequestResponseBean bean = new ATTRequestResponseBean();
            ATTRequestResponseBean Processedbean = new ATTRequestResponseBean();    
            bean.Body = request;
            bean.GetPostMethod = ATTConstants.GetMethod;
            bean.ContentType = ATTConstants.JsonContentType;    
            bean.authType = 'Basic';                   
            bean.authToken= Global_Variable__c.getValues('BD_AUTH_TOKEN') != null ? Global_Variable__c.getValues('BD_AUTH_TOKEN').Value__c : '';                    
            bean.convID = tConvId; 
            bean.TimeOut = Global_Variable__c.getValues('Session_Timeout') != null ? Global_Variable__c.getValues('Session_Timeout').Value__c : '12000';
            bean.EndPoint =  Endpoint_URL__c.getValues('END_POINT_BDUserService').URL__c != null ? Endpoint_URL__c.getValues('END_POINT_BDUserService').URL__c : '';
            ATTSendRequestAndReceiveResponse conn = new ATTSendRequestAndReceiveResponse();
            Processedbean = conn.sendRequestAndReceiveResponse(bean); 
            BDwebServiceLogCreation wbCreator = new BDwebServiceLogCreation();      
            wbCreator.createWebserviceLogs(request,Processedbean.Response,Processedbean,ContID,tConvId,Processedbean.responseWithHeader);        
            return Processedbean;   
            }catch (Exception e) {
            String exceptionString = ATTException.constructExceptionMessageString(e);
            system.debug('Exception thrown (line 89): '+exceptionString); 
            return null;
        }
    }
    
}