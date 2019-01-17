/************************************************************************************** 
Apex Class Name     : BirchProvIntegrationHandler
Version             : 1.0 
Created Date        : 23 Aug 2015
Function            : This class handles the building of request and parsing of response for birch provisioning service
Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* AM            8/23/2015              Original Version
*************************************************************************************/
public class BirchProvIntegrationHandler implements ATTServiceIntegrationInterface 
{
    public static final String Birch_CONV_ID = 'CONV-ID';
    
    public static final String BIRCH_CLIENT_ID = 'BIRCH_CLIENT_ID';
    public static final String BIRCH_AUTH_TOKEN = 'BIRCH_AUTH_TOKEN'; 
    public ID AcctID;
    /*
* Method name  : handleServiceRequest
* Description  : This method will handle Lead Transfer Webservice request
* Return Type  : ATTServiceInfoBean 
* Parameter    : ATTServiceInfoBean 
*/  
    
    public  ATTServiceInfoBean handleServiceRequest(ATTServiceInfoBean serviceInfobean){
        try 
        {
            BirchAccountProvRequestBean requestBean = new BirchAccountProvRequestBean();
            requestBean=(BirchAccountProvRequestBean)serviceInfobean;   
            //String convID = requestBean.convId;
            DateTime dt = DateTime.now();
            String convID =  'sfdc-MDF-'+dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            
            // Set the Security Header
           // requestBean.SecurityHeader = null;
            String birchClientId = Global_Variable__c.getValues(BIRCH_CLIENT_ID) != null ? Global_Variable__c.getValues(BIRCH_CLIENT_ID).Value__c : '';
            String birchAuthToken = Global_Variable__c.getValues(BIRCH_AUTH_TOKEN) != null ? Global_Variable__c.getValues(BIRCH_AUTH_TOKEN).Value__c : '';
            /**
            if (String.isNotBlank(birchClientId) && String.isNotBlank(birchAuthToken)) {
                requestBean.SecurityHeader = new BirchAccountProvRequestBean.SecurityHeader();
                requestBean.SecurityHeader.clientId = birchClientId;
                requestBean.SecurityHeader.authToken = birchAuthToken; 
            }**/
            string request = JSON.serialize(requestBean);
            String conResult = '{'+request.substring(15);
            
            BirchProvResponseBean webServiceResponse = new BirchProvResponseBean();
            webServiceResponse = parseResponse(sendRequestAndReceiveResponse(conResult, convID));
            
            return webServiceResponse;
        }catch (Exception e) {
            String exceptionString = ATTException.constructExceptionMessageString(e);
            
           // ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);            
            return null;
        }
    }
    /*
* Method name  : parseResponse
* Description  : This method is used to parse the response and store it in bean 0bject
* Return Type  : String
* Parameter    : ATTRequestResponseBean 
*/
    private BirchProvResponseBean parseResponse(ATTRequestResponseBean resBean) {    
        try {
            system.debug('****In parse response'+resBean);
            system.debug('****In parse resBean.response'+resBean.response); 
            BirchProvResponseBean responseBean = new BirchProvResponseBean();    
            if(resBean !=null){      
                responseBean = (BirchProvResponseBean)JSON.deserialize(resBean.response,BirchProvResponseBean.class); 
                System.debug('\n anand 200 resBean.Response='+resBean.Response);
                System.debug('\n anand 200 resBean.Status='+resBean.Status);
                System.debug('\n anand 200 resBean.statusCode='+resBean.statusCode);
                System.debug('\n anand  responseBean.MessageText='+responseBean.MessageText);
                System.debug('\n anand  responseBean.MessageCode='+responseBean.MessageCode);
                
                if(responseBean == null)
                {
                    responseBean = new BirchProvResponseBean(); 
                    responseBean.status = ATTConstants.FAILURE; 
                }
                else
                {
                    responseBean.status = ATTConstants.SUCCESS;
                }
                BirchProvResponseBean.Response myResp = new BirchProvResponseBean.Response();
                myResp.code = String.valueOf(resBean.statusCode);
                myResp.description = resBean.status;
                responseBean.Response = myResp;
                responseBean.JSONResponse = resBean.Response; 
            } else {
                System.debug('\n anand otherwise='+responseBean);
                responseBean.status = ATTConstants.FAILURE; 
                responseBean.JSONResponse = resBean.Response;  
                responseBean.MessageText = resBean.Status + resBean.response + resBean.body;
                //responseBean.MessageCode = resBean.statusCode;
            }        
            return responseBean;
        }catch (Exception e) {
            
            String exceptionString = ATTException.constructExceptionMessageString(e);
            //ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);            
            return null;
        }
    }
    /*
* Method name  : sendRequestAndReceiveResponse
* Description  : This method is used to make actual webservice call.
* Return Type  : ATTRequestResponseBean 
* Parameter    : String
*/
    private ATTRequestResponseBean sendRequestAndReceiveResponse(String request, String tConvId){
        try {   
            ATTRequestResponseBean bean = new ATTRequestResponseBean();
            ATTRequestResponseBean Processedbean = new ATTRequestResponseBean();
            bean.Body = request;
            bean.GetPostMethod = ATTConstants.GetMethod;
            bean.ContentType = ATTConstants.JsonContentType;   
            bean.authType = 'Basic';
            bean.authToken= Global_Variable__c.getValues('BIRCH_AUTH_TOKEN') != null ? Global_Variable__c.getValues('BIRCH_AUTH_TOKEN').Value__c : (Global_Variable__c.getValues('BD_AUTH_TOKEN') != null ? Global_Variable__c.getValues('BD_AUTH_TOKEN').Value__c : '');

            bean.convId =  tConvId;
            
            bean.TimeOut = Global_Variable__c.getValues('Session_Timeout') != null ? Global_Variable__c.getValues('Session_Timeout').Value__c : '12000';
            bean.EndPoint =  Endpoint_URL__c.getValues('END_POINT_BIRCHAccountService') != null ? Endpoint_URL__c.getValues('END_POINT_BIRCHAccountService').URL__c : '';
            String authToken = Global_Variable__c.getValues('MULESOFT_AUTH_TOKEN') != null ? Global_Variable__c.getValues('MULESOFT_AUTH_TOKEN').Value__c : '';
            /**
            if (!String.isBlank(authToken)) {
                bean.authType = 'Basic';
                bean.authToken = authToken;
            }
**/
            ATTSendRequestAndReceiveResponse conn = new ATTSendRequestAndReceiveResponse();
            System.debug('\n bean='+bean);
            Processedbean = conn.sendRequestAndReceiveResponse(bean);

            BirchwebServiceLogCreation wbCreator = new BirchwebServiceLogCreation ();
            wbCreator.createWebserviceLogs(request,Processedbean.Response,Processedbean,AcctID,tConvId,Processedbean.responseWithHeader); 
           // wbCreator.insertWeBlogs();
            return Processedbean;                  
        }catch (Exception e) {
            String exceptionString = ATTException.constructExceptionMessageString(e);
            system.debug('<<<< line number' + e.getLineNumber() + 'mess' + e.getMessage());
            //ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);            
            return null;
        }
    }
    
}