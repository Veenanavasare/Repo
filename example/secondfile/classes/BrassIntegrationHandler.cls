/************************************************************************************** 
 Apex Class Name     : BrassIntegrationHandler
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
public with sharing class BrassIntegrationHandler implements ATTServiceIntegrationInterface {
                
    /*
     * Method name  : handleServiceRequest
     * Description  : This method will handle Lead Transfer Webservice request
     * Return Type  : ATTServiceInfoBean 
     * Parameter    : ATTServiceInfoBean 
     */  
      
     public  ATTServiceInfoBean handleServiceRequest(ATTServiceInfoBean serviceInfobean){
       BRASS_Apex2JSON_Request requestBean = new BRASS_Apex2JSON_Request();
       //requestBean=(BRASS_Apex2JSON_Request)serviceInfobean;
       requestBean=(BRASS_Apex2JSON_Request)serviceInfobean;        
       string request = buildJSONRequest(requestBean);
       String conResult = '{'+request.substring(15);
       BRASS_Acknowledgement_Response webServiceResponse = parseResponse(sendRequestAndReceiveResponse(conResult));
       system.debug('-----webServiceResponse ----- = ' + webServiceResponse );                                 
       return webServiceResponse ;        
     }
     /*
     * Method name  : buildJSONRequest
     * Description  : This method is used to build JSON String
     * Return Type  : String
     * Parameter    : BRASS_Apex2JSON_Request 
     */
    private String buildJSONRequest(BRASS_Apex2JSON_Request BeanInst){        
        return JSON.serialize(BeanInst);
    }

    /*
     * Method name  : sendRequestAndReceiveResponse
     * Description  : This method is used to make actual webservice call.
     * Return Type  : ATTRequestResponseBean 
     * Parameter    : String
     */
    private ATTRequestResponseBean sendRequestAndReceiveResponse(String request){
        system.debug ('read request :: ' + request);   
        ATTRequestResponseBean bean = new ATTRequestResponseBean();
        bean.Body = request;
        bean.GetPostMethod = ATTConstants.PostMethod;
        bean.ContentType = ATTConstants.JsonContentType;               
        bean.TimeOut = Global_Variable__c.getValues('Session_Timeout') != null ? Global_Variable__c.getValues('Session_Timeout').Value__c : '12000';
        bean.EndPoint =  Endpoint_URL__c.getValues('ENDPOINT_BRASS') != null ? Endpoint_URL__c.getValues('ENDPOINT_BRASS').URL__c : '';        
        ATTSendRequestAndReceiveResponse conn = new ATTSendRequestAndReceiveResponse();        
        return conn.sendRequestAndReceiveResponse(bean);   
        //return new ATTRequestResponseBean();            
    }

    /*
     * Method name  : parseResponse
     * Description  : This method is used to parse the response and store it in bean 0bject
     * Return Type  : String
     * Parameter    : ATTRequestResponseBean 
     */
    public BRASS_Acknowledgement_Response parseResponse(ATTRequestResponseBean resBean){  
        //resBean.response = '{"PreQualify_Response":{"Service_Availability":[{"Selected_Provider_Name":"HSIA","Possible_Provider_Names":"HSIA","Offer_Name":{"Name":"Broadband Up to 768 Kbps/Up to 384 Kbps Service"},"Offer_Id":{"Offer_Code":"ASOSH"},"List_Price":{"Price":"$45.00"}}],"Return_Code":{"Return_Code":"00"},"Overall_SA_Results":"ASOSH,HSIA:ASOSJ,HSIA:ASOMJ,HSIA:ASOSL,HSIA:ASOML,HSIA:","Error_Info":{"Error_Message":"","Error_Code":""},"Dry_Loop_Ind":"N"}}';
      // resBean.response = '{"PreQualify_Response":[{"Return_Code":{"Return_Code":"00"},"CSI_Address_Info":{"StreetName":"Witmer Road","streetNumberPrefix":"WR","streetNumber":"3909","streetNumberSuffix":"","streetDirection":"North","streetType":"","City":"Niagara Falls","State":"NY","PostalCode":"14305","PostalCodePlus4":"","streetTrailingDirection":"","assignedStreetNumber":"","RateZoneBandCode":"RZB","AddressId":"","LegalEntity":"","BuildingType":"","tarCode":"","rateCenterCode":"","exchangeCode":"","primaryNpaNxx":"","Clli8":"","videoHubOffice":"","lastDisconnectTransportType":"","smartMoves":"Y"},"ProductQualificationResults":[{"ProductName":"AIA","QualificationResultCode":"","NetworkTypeGroup":{"NetworkType_Count":"","NetworkType1":"","Exhaust_Code1":"","Primary_RTID1":"","Secondary_RTID1":"","SubTransport_Frequency_17MHz_Indicator1":"","SubTransport_Vectoring_Indicator1":"","SubTransport_Bandwidth_Indicator1":"","NetworkType2":"","Exhaust_Code2":"","Primary_RTID2":"","Secondary_RTID2":"","SubTransport_Frequency_17MHz_Indicator2":"","SubTransport_Vectoring_Indicator2":"","SubTransport_Bandwidth_Indicator2":""}}],"GeoCode_Result":{"Result":"","GeoCode_Details":{"GeoCode":"","Address":{"Street1":"","Street2":"","City":"","State":"","Zip":"","Telephone":""}}},"Dry_Loop_Ind":"","Error_Info":{"Error_Code":"","Error_Message":""}}]}';
        system.debug('****In parse response'+resBean);            
        BRASS_Acknowledgement_Response responseBean = new BRASS_Acknowledgement_Response();        
        if(resBean.response !=null && resBean.response.contains ('Acknowledged! Request is being processed')) {                                              
            responseBean = (BRASS_Acknowledgement_Response )JSON.deserialize(resBean.Response,BRASS_Acknowledgement_Response.class);                                   
            responseBean.status = ATTConstants.SUCCESS;            
        } else {
            responseBean.status = ATTConstants.FAILURE;  
        }        
        return responseBean;
    }
    
   
}