/************************************************************************************** 
 Apex Class Name     : AddrValidServAvailIntegrationHandler
 Version             : 1.0 
 Created Date        : 11 Aug 2014
 Function            : This class handles the building of request and parsing of response for address validation and service availability
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gustavo Restrepo            8/11/2014              Original Version
* Md khalid Munavar Ali       8/19/2014              Updating Methods
* Md Khalid Munavar Ali       8/25/2014              Upadting Method Signature
*************************************************************************************/
/* 
 Name: ATTServiceIntegrationInterface
 Type: Class 
 
 Description: 
 */ 
public with sharing class AddrValidServAvailIntegrationHandler implements ATTServiceIntegrationInterface {
    
    public static final String VASA_CLIENT_ID = BuyflowConstant.VASACLIENT_ID;
    public static final String VASA_AUTH_TOKEN = BuyflowConstant.VASAAUTH_TOKEN;
    public String varCallType;
    Boolean isMACD = true; 
  //public static Id WebLogId;
    public static final String WEBSERVICE_LOG_TITLE = BuyflowConstant.SITEADDRESS_VALIDATION;     
    public list<Apttus_Proposal__Proposal__c> quoteList = new list<Apttus_Proposal__Proposal__c>();    
    /*
     * Method name  : handleServiceRequest
     * Description  : This method will handle Lead Transfer Webservice request
     * Return Type  : ATTServiceInfoBean 
     * Parameter    : ATTServiceInfoBean 
     */  
      
/* 
 Name: handleServiceRequest
 Description: 
 */ 
     public  ATTServiceInfoBean handleServiceRequest(ATTServiceInfoBean serviceInfobean){
         try {
            AddrValidServAvailInformationBean requestBean = new AddrValidServAvailInformationBean();
            requestBean=(AddrValidServAvailInformationBean)serviceInfobean;
            
            // Set the Security Header
            requestBean.SecurityHeader = null;
            String vasaClientId = Global_Variable__c.getValues(VASA_CLIENT_ID) != null ? Global_Variable__c.getValues(VASA_CLIENT_ID).Value__c : SpecialcharacterConstant.CONCAT;
            String vasaAuthToken = Global_Variable__c.getValues(VASA_AUTH_TOKEN) != null ? Global_Variable__c.getValues(VASA_AUTH_TOKEN).Value__c : SpecialcharacterConstant.CONCAT;
            if (String.isNotBlank(vasaClientId) && String.isNotBlank(vasaAuthToken)) {
                requestBean.SecurityHeader = new AddrValidServAvailInformationBean.SecurityHeader();
                requestBean.SecurityHeader.clientId = vasaClientId;
                requestBean.SecurityHeader.authToken = vasaAuthToken; 
            }
            
            //Logic updated for User Story :US614050 and US614048 by Haemen in Sprint 14 
            //Code to fetch quote field - checkbox selected by User from UI and make a sync or aync call accordingly
            if(requestBean.ValidateAddressServiceAvailabilityRequest.sfdcQuoteId != null){
                string sfdcQuoteId = requestBean.ValidateAddressServiceAvailabilityRequest.sfdcQuoteId;
                quoteList = [select id,Send_Email_on_Service_Complete__c from Apttus_Proposal__Proposal__c where id =:sfdcQuoteId ];
                isMACD = false;
            }
             
            string request = buildJSONRequest(requestBean);
            String conResult = SpecialcharacterConstant.OPEN_BRACE_FLOWER+request.substring(15);
            AddrValidServAvailResponseBean webServiceResponse = new AddrValidServAvailResponseBean();
            VASAResponseBeanAsync webServiceResponseAsync = new VASAResponseBeanAsync();
            Integer max_sites = Integer.valueOf(Max_sites_allowed_VASA__c.getValues(BuyflowConstant.VASAMAX_SITES_ALLOWED) != null ? Max_sites_allowed_VASA__c.getValues(BuyflowConstant.VASAMAX_SITES_ALLOWED).value__c: 0);                       
            Id weblogId;
            
            if(requestBean!=null && 
               requestBean.ValidateAddressServiceAvailabilityRequest!=null &&
               requestBean.ValidateAddressServiceAvailabilityRequest.AddressDetails!=null && 
               requestBean.ValidateAddressServiceAvailabilityRequest.mode.equals(BuyflowConstant.A)) { 
               //Added emailSelected flag to decide Sync or Async call to inform the user              
                   if(requestBean.ValidateAddressServiceAvailabilityRequest.AddressDetails.size()<=Max_sites) {                                     
                      webServiceResponse = parseResponse(sendRequestAndReceiveResponse(conResult));
                      //WebLogId = createWebserviceLogs(conResult,requestBean,webServiceResponse.toString(),NULL,webServiceResponse,VarCallType,requestBean.ValidateAddressServiceAvailabilityRequest.mode);
                      return webServiceResponse ;
                    }else {
                      webServiceResponseAsync = parseResponseAsync(sendRequestAndReceiveResponseAsync(conResult));
                        //WebLogId = createWebserviceLogs(conResult,requestBean,webServiceResponse.toString(),NULL,webServiceResponse,VarCallType,requestBean.ValidateAddressServiceAvailabilityRequest.mode);
                        return webServiceResponseAsync;         
                    } 
            }else if(requestBean!=null && 
               requestBean.ValidateAddressServiceAvailabilityRequest!=null &&
               requestBean.ValidateAddressServiceAvailabilityRequest.AddressDetails!=null && 
               requestBean.ValidateAddressServiceAvailabilityRequest.mode.equals(BuyflowConstant.B)) { 
               //Added emailSelected flag to decide Sync or Async call to inform the user    
                   if(requestBean.ValidateAddressServiceAvailabilityRequest.AddressDetails.size()<=Max_sites*2 && isMACD) {
                       webServiceResponse = parseResponse(sendRequestAndReceiveResponse(conResult));
                       //WebLogId = createWebserviceLogs(conResult,requestBean,webServiceResponse.toString(),NULL,webServiceResponse,VarCallType,requestBean.ValidateAddressServiceAvailabilityRequest.mode);
                       return webServiceResponse ;
                   } else if(requestBean.ValidateAddressServiceAvailabilityRequest.AddressDetails.size()<=Max_sites*2 && !isMACD && quoteList[0].Send_Email_on_Service_Complete__c != true){
                           webServiceResponse = parseResponse(sendRequestAndReceiveResponse(conResult));
                           //WebLogId = createWebserviceLogs(conResult,requestBean,webServiceResponse.toString(),NULL,webServiceResponse,VarCallType,requestBean.ValidateAddressServiceAvailabilityRequest.mode);
                           return webServiceResponse;                       
                   } else{
                        webServiceResponseAsync = parseResponseAsync(sendRequestAndReceiveResponseAsync(conResult));
                        //WebLogId = createWebserviceLogs(conResult,requestBean,webServiceResponse.toString(),NULL,webServiceResponse,VarCallType,requestBean.ValidateAddressServiceAvailabilityRequest.mode);
                        return webServiceResponseAsync;          
                    }     
            }                                       
            return null;
        }catch (Exception e) {
            //String exceptionString = ATTException.constructExceptionMessageString(e);
            //ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString); 
                         
            return null;
        }
     }
     
    /*
     * Method name  : buildJSONRequest
     * Description  : This method is used to build JSON String
     * Return Type  : String
     * Parameter    : AddrValidServAvailInformationBean
     */
    private String buildJSONRequest(AddrValidServAvailInformationBean addrValidServAvailBeanInst){
        return JSON.serialize(addrValidServAvailBeanInst);
    }

    /*
     * Method name  : sendRequestAndReceiveResponse
     * Description  : This method is used to make actual webservice call.
     * Return Type  : ATTRequestResponseBean 
     * Parameter    : String
     */
    private ATTRequestResponseBean sendRequestAndReceiveResponse(String request){
        try {   
            ATTRequestResponseBean bean = new ATTRequestResponseBean();
            bean.Body = request;
            bean.GetPostMethod = ATTConstants.PostMethod;
            bean.ContentType = ATTConstants.JsonContentType;               
            bean.TimeOut = Global_Variable__c.getValues(BuyflowConstant.SESSIONTIMEOUT) != null ? Global_Variable__c.getValues(BuyflowConstant.SESSIONTIMEOUT).Value__c : BuyflowConstant.SIVARConst_12000;
            bean.EndPoint =  Endpoint_URL__c.getValues(BuyflowConstant.ENDPOINT_VASASERVICE) != null ? Endpoint_URL__c.getValues(BuyflowConstant.ENDPOINT_VASASERVICE).URL__c : SpecialcharacterConstant.CONCAT;
            String authToken = Global_Variable__c.getValues(BuyflowConstant.MULESOFTAUTH_TOKEN) != null ? Global_Variable__c.getValues(BuyflowConstant.MULESOFTAUTH_TOKEN).Value__c : SpecialcharacterConstant.CONCAT;
            if (!String.isBlank(authToken)) {
                bean.authType = BuyflowConstant.BASIC;
                bean.authToken = authToken;
            }
            ATTSendRequestAndReceiveResponse conn = new ATTSendRequestAndReceiveResponse();
            return conn.sendRequestAndReceiveResponse(bean);                  
        }catch (Exception e) {
            //String exceptionString = ATTException.constructExceptionMessageString(e);
            //ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);            
            return null;
        }
    }

/*
     * Method name  : sendRequestAndReceiveResponseAsync
     * Description  : This method is used to make actual webservice call for Async process.
     * Return Type  : ATTRequestResponseBean 
     * Parameter    : String
     */
    private ATTRequestResponseBean sendRequestAndReceiveResponseAsync(String request){
        try {   
            ATTRequestResponseBean bean = new ATTRequestResponseBean();
            bean.Body = request;
            bean.GetPostMethod = ATTConstants.PostMethod;
            bean.ContentType = ATTConstants.JsonContentType;               
            bean.TimeOut = Global_Variable__c.getValues(BuyflowConstant.SESSIONTIMEOUT) != null ? Global_Variable__c.getValues(BuyflowConstant.SESSIONTIMEOUT).Value__c : BuyflowConstant.SIVARConst_12000;
            bean.EndPoint =  Endpoint_URL__c.getValues(BuyflowConstant.ENDPOINT_VASA_ASYNC) != null ? Endpoint_URL__c.getValues(BuyflowConstant.ENDPOINT_VASA_ASYNC).URL__c : SpecialcharacterConstant.CONCAT;
            String authToken = Global_Variable__c.getValues(BuyflowConstant.MULESOFTAUTH_TOKEN) != null ? Global_Variable__c.getValues(BuyflowConstant.MULESOFTAUTH_TOKEN).Value__c : SpecialcharacterConstant.CONCAT;
            if (!String.isBlank(authToken)) {
                bean.authType = BuyflowConstant.BASIC;
                bean.authToken = authToken;
            }
            ATTSendRequestAndReceiveResponse conn = new ATTSendRequestAndReceiveResponse();
            return conn.sendRequestAndReceiveResponse(bean); 
        }catch (Exception e) {
            //String exceptionString = ATTException.constructExceptionMessageString(e);
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
    private AddrValidServAvailResponseBean parseResponse(ATTRequestResponseBean resBean) {    
        try {
            AddrValidServAvailResponseBean responseBean = new AddrValidServAvailResponseBean();        
            if(resBean !=null && resBean.response.contains(BuyflowConstant.ADDRESSSERVICEAVAILABILITY_x)){          
                responseBean = (AddrValidServAvailResponseBean)JSON.deserialize(resBean.Response,AddrValidServAvailResponseBean.class);                                    
                responseBean.status = ATTConstants.SUCCESS;
                responseBean.JSONResponse = resBean.Response;                     
            } else {
                responseBean.status = ATTConstants.FAILURE;            
            }        
            return responseBean;
        }catch (Exception e) {
            //String exceptionString = ATTException.constructExceptionMessageString(e);
            //ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);            
            return null;
        }
    }
    /*
     * Method name  : parseResponseAsync
     * Description  : This method is used to parse the response and store it in bean 0bject
     * Return Type  : String
     * Parameter    : ATTRequestResponseBean 
     */
    private VASAResponseBeanAsync parseResponseAsync(ATTRequestResponseBean resBean) {    
        try {
            VASAResponseBeanAsync responseBean = new VASAResponseBeanAsync();
            if(resBean !=null &&
              (resBean.response.contains('{"message":'))) {
              responseBean = (VASAResponseBeanAsync)JSON.deserialize(resBean.Response,VASAResponseBeanAsync.class);                                    
              responseBean.status = ATTConstants.SUCCESS;          
            } else {
                responseBean.status = ATTConstants.FAILURE;   
            }
            return responseBean;    
        }catch (Exception e) {
            //String exceptionString = ATTException.constructExceptionMessageString(e);
            //ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);            
            return null;
        }
    }
    //class to handle the state of reponse in Async Process
/* 
 Name: ATTServiceInfoBean
 Type: Class 
 
 Description: 
 */ 
    public class VASAResponseBeanAsync extends ATTServiceInfoBean{
        public String message;
    }
    String responseString = '{'+
               '"addressServiceAvailability":['+
                  '{'+
                    ' "requestedAddressDetails":{'+
                        '"street":"2800 PEBBLE CREEK CT",'+
                        '"city":"Plano",'+
                        '"county":null,'+
                        '"urbanization":null,'+
                        '"state":"TX",'+
                        '"zip":{'+
                           '"zipCode":"75023",'+
                           '"zipCodeExtension":null,'+
                           '"zipGeoCode":null'+
                        '},'+
                        '"country":null'+
                     '},'+
                     '"addressMatchDetails":['+
                        '{'+
                           '"street":"2800 PEBBLE CREEK CT",'+
                           '"city":"PLANO",'+
                           '"county":null,'+
                           '"urbanization":null,'+
                           '"state":"TX",'+
                           '"zip":{'+
                              '"zipCode":"75023",'+
                              '"zipCodeExtension":"5941",'+
                              '"zipGeoCode":null'+
                           '},'+
                           '"country":null'+
                        '}'+
                     '],'+
                     '"geocode":{'+
                        '"latitude":33.053754,'+
                        '"longitude":-96.767466'+
                     '},'+
                     '"addressMatchCode":"1",'+
                     '"lecName":"VERIZON",'+
                     '"region":"O",'+
                     '"swcClli":"PLANTXXB",'+
                     '"locationClli":"PLANTXWGW00",'+
                     '"serviceAvailabilityDetails":{'+
                        '"requestedSpeed":"1000",'+
                        '"ethernet":{'+
                           '"popCLLI":"IRNGTX27",'+
                           '"ethernetAvailability":"Y",'+
                           '"lata":552,'+
                           '"maxAvailableSpeed":"1000",'+
                           '"availableSpeed":"1000",'+
                           '"service":['+
                              '{'+
                                 '"name":"VZON",'+
                                 '"switchedDedicated":"DEDICATED"'+
                              '},'+
                              '{'+
                                 '"name":"TLS-ERS",'+
                                 '"switchedDedicated":"SWITCHED"'+
                              '}'+
                           '],'+
                           '"electricalOptical":"O",'+
                           '"equipmentType":null,'+
                           '"mileage":0,'+
                           '"otherSpeed":['+
                              '{'+
                                 '"speed":"1",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"2",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"3",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"4",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"5",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"6",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"7",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"8",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"9",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"10",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"20",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"30",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"40",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"50",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":3'+
                              '},'+
                              '{'+
                                 '"speed":"60",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"70",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"80",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"90",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"100",'+
                                 '"electricalOptical":"B",'+
                                 '"networkType":3'+
                              '},'+
                              '{'+
                                 '"speed":"150",'+
                                 '"electricalOptical":"O",'+
                                 '"networkType":2'+
                              '},'+
                              '{'+
                                 '"speed":"200",'+
                                 '"electricalOptical":"O",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"300",'+
                                 '"electricalOptical":"O",'+
                                 '"networkType":3'+
                              '},'+
                              '{'+
                                 '"speed":"400",'+
                                 '"electricalOptical":"O",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"500",'+
                                 '"electricalOptical":"O",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"600",'+
                                 '"electricalOptical":"O",'+
                                 '"networkType":3'+
                              '},'+
                              '{'+
                                 '"speed":"700",'+
                                 '"electricalOptical":"O",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"800",'+
                                 '"electricalOptical":"O",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"900",'+
                                 '"electricalOptical":"O",'+
                                 '"networkType":1'+
                              '},'+
                              '{'+
                                 '"speed":"1000",'+
                                 '"electricalOptical":"O",'+
                                 '"networkType":3'+
                              '}'+
                           '],'+
                           '"existingConnectivity":null'+
                        '},'+
                        '"privateLine":['+
                        ']'+
                     '},'+
                     '"statusCode":0,'+
                     '"statusMessage":"Ethernet Service Availability Check Successful"'+
                 ' },'+
                  '{'+
                    '"requestedAddressDetails":{'+
                        '"street":"2800 PEBBLE CREEK CT",'+
                        '"city":"Plano",'+
                        '"county":null,'+
                        '"urbanization":null,'+
                        '"state":"TX",'+
                        '"zip":{'+
                           '"zipCode":"75023",'+
                           '"zipCodeExtension":null,'+
                           '"zipGeoCode":null'+
                        '},'+
                        '"country":null'+
                     '},'+
                     '"addressMatchDetails":['+
                        '{'+
                           '"street":"2800 PEBBLE CREEK CT",'+
                           '"city":"PLANO",'+
                           '"county":null,'+
                           '"urbanization":null,'+
                           '"state":"TX",'+
                           '"zip":{'+
                              '"zipCode":"75023",'+
                              '"zipCodeExtension":"5941",'+
                              '"zipGeoCode":null'+
                           '},'+
                           '"country":null'+
                        '}'+
                     '],'+
                     '"geocode":{'+
                       '"latitude":33.053754,'+
                       '"longitude":-96.767466'+
                     '},'+
                     '"addressMatchCode":"1",'+
                     '"lecName":"VERIZON",'+
                     '"region":"O",'+
                     '"swcClli":"PLANTXXB",'+
                     '"locationClli":"PLANTXWGW00",'+
                     '"serviceAvailabilityDetails":{'+
                        '"requestedSpeed":"T1,T3",'+
                        '"ethernet":null,'+
                        '"privateLine":['+
                           '{'+
                              '"popCLLI":"IRNGTX27",'+
                              '"speed":"T1",'+
                              '"spareQuantity":770,'+
                              '"mileage":0'+
                           '},'+
                           '{'+
                             '"popCLLI":"IRNGTX27",'+
                              '"speed":"T3",'+
                              '"spareQuantity":11,'+
                              '"mileage":0'+
                           '}'+
                        ']'+
                     '},'+
                     '"statusCode":0,'+
                     '"statusMessage":"PrivateLine Service Availability Check Successful"'+
                  '}'+
               '],'+
               '"response":{'+
                  '"code":"0",'+
                  '"description":"Success"'+
               '}'+
            '}';
            
             /*
     * Method name  : createWebserviceLogs
     * Description  : This method is used to create logs for webservice calls in "handleServiceRequest" method
     * Return Type  : void
     * Parameter    : AddrValidServAvailInformationBean , ResponseString, ExceptionString, AddrValidServAvailResponseBean 
     */
     
/* 
 Name: mode)
 Type: Class 
 
 Description: 
 */ 
     public Id createWebserviceLogs(string requestBean,AddrValidServAvailInformationBean requestclass, string ResponseString, String ExceptionString,AddrValidServAvailResponseBean responseClass, string SingleorBatch, string mode){
         WebServiceLog__c objWebLog = new WebServiceLog__c();
        Id quotesalesforceId =  ApexPages.currentPage().getParameters().get('quoteid');
        try{
         //Create a record for logs if the Id parameter is blank
         
             objWebLog.WSLogTitle__c = BuyflowConstant.SITEADDRESS_VALIDATION_x+mode ;
             String finalresquest ;
             if(!String.isBlank(requestBean)){
                if((requestBean).length()> 32768){
                    finalresquest = (requestBean).substring(0,32766);
                }
                else{
                    finalresquest = requestBean;
                    }
                  }
             objWebLog.Request_Data__c = finalresquest;
             objWebLog.Quote_Proposal__c = quotesalesforceId;
             
             if(!String.isBlank(requestclass.ValidateAddressServiceAvailabilityRequest.sfdcQuoteId)){
                   objWebLog.Quote_Proposal__c = requestclass.ValidateAddressServiceAvailabilityRequest.sfdcQuoteId;
             }
             
        
             string responseLog;
             string finalresponse;
             if(!String.isBlank(ResponseString)){
                 if(!String.isBlank(responseClass.JSONResponse)){
                if((responseClass.JSONResponse).length()> 32768){
                    finalresponse = (responseClass.JSONResponse).substring(0,32766);
                }
                else{
                    finalresponse = responseClass.JSONResponse;
                }
                    }
                 if(!String.isBlank(objWebLog.Response_Data__c)){
                     objWebLog.Response_Data__c += BuyflowConstant.R_N;
                     objWebLog.Response_Data__c= objWebLog.Response_Data__c+finalresponse;
                     }
                  else{
                     objWebLog.Response_Data__c= finalresponse;
                  }
                 objWebLog.Response_Data__c += BuyflowConstant.R_N;
                     if(!String.isBlank(responseClass.conversationId)){
                         objWebLog.Conversation_Id__c = responseClass.conversationId;
                     }
                    
             }
             if(!String.isBlank(ExceptionString)){
                 objWebLog.WSLog_error__c = ExceptionString;
             }
             if(!String.isBlank(responseClass.sfdcQuoteId)){
                   objWebLog.Quote_Proposal__c = responseClass.sfdcQuoteId;
             }
         
           if(SingleorBatch != BuyflowConstant.BATCH && SingleorBatch == BuyflowConstant.SINGLE){
            insert objWebLog;
        
         }
         else{
             
         }
         return null;
         
        }
        catch (Exception exc) {
            String exceptions = ATTException.constructExceptionMessageString(exc);
            return null;
        }
     }
}