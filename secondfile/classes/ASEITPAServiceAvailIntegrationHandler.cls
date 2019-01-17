/****************************************************************************************************************************** 
 Apex Class Name     : ASEITPAServiceAvailIntegrationHandler
 Version             : 1.0 
 Created Date        : 12 November 2016
 Function            : This class handles the building of request and parsing of response for ASE ITPA Service Availability
*******************************************************************************************************************************/

public with sharing class ASEITPAServiceAvailIntegrationHandler implements ASEITPAServiceIntegrationInterface {
     
    public list<Apttus_Proposal__Proposal__c> quoteList = new list<Apttus_Proposal__Proposal__c>();    
    
    /*Method to handle ASE ITPA Service Availability Request*/ 
    public ASEITPAServiceInfoBean handleServiceRequest(ASEITPAServiceInfoBean serviceInfobean){
         try {
            ASEITPAServiceAvailInfoBean requestBean = new ASEITPAServiceAvailInfoBean();
            requestBean=(ASEITPAServiceAvailInfoBean)serviceInfobean;
                     
            if(requestBean.InquireTransportProductAvailabilityRequest.quoteId != null){
                String quoteId = requestBean.InquireTransportProductAvailabilityRequest.quoteId;
                quoteList = [select id,Send_Email_on_Service_Complete__c from Apttus_Proposal__Proposal__c where id =: quoteId];
            }
             
            string request = buildJSONRequest(requestBean);
            String conResult = '{'+request.substring(15);
            ASEITPAServiceAvailResponseBean webServiceResponse = new ASEITPAServiceAvailResponseBean();
            
            Integer Max_Sites = Integer.valueOf(Max_Sites_Allowed_For_ITPA__c.getValues('ASE_ITPA_Max_Sites') != null ? Max_Sites_Allowed_For_ITPA__c.getValues('ASE_ITPA_Max_Sites').value__c: 0);                       
          
            if(requestBean!=null && requestBean.InquireTransportProductAvailabilityRequest !=null && requestBean.InquireTransportProductAvailabilityRequest.addresses != null){
                if(requestBean.InquireTransportProductAvailabilityRequest.addresses.size() <= Max_Sites && quoteList[0].Send_Email_on_Service_Complete__c != true){
                    webServiceResponse = parseResponse(sendRequestAndReceiveResponse(conResult));
                    return webServiceResponse;                       
                }else{
                    webServiceResponse = parseResponse(sendRequestAndReceiveResponseAsync(conResult));
                    return webServiceResponse;                            
                }     
            }                                                    
            return null;
        }
        catch (Exception e){   
            system.debug('Exception in ASEITPAServiceAvailIntegrationHandler.handleServiceRequest'+e);            
            return null;
        }
     }
     
    /* This method is used to build JSON String*/    
    private String buildJSONRequest(ASEITPAServiceAvailInfoBean addrValidServAvailBeanInst){
        return JSON.serialize(addrValidServAvailBeanInst);
    }

    /*This method is used to make actual ASE ITPA webservice call for Sync process*/
    private ASEITPARequestResponseBean sendRequestAndReceiveResponse(String request){
        try{   
            ASEITPARequestResponseBean bean = new ASEITPARequestResponseBean();
            bean.Body = request;
            bean.GetPostMethod = ATTConstants.PostMethod;
            bean.ContentType = ATTConstants.JsonContentType;               
            bean.TimeOut = Global_Variable__c.getValues(BuyflowConstant.SESSIONTIMEOUT) != null ? Global_Variable__c.getValues(BuyflowConstant.SESSIONTIMEOUT).Value__c : BuyflowConstant.SIVARConst_12000;
            bean.EndPoint =  Endpoint_URL__c.getValues('End_Point_ASEITPAService') != null ? Endpoint_URL__c.getValues('End_Point_ASEITPAService').URL__c : '';
            ASEITPASendRequestAndReceiveResponse conn = new ASEITPASendRequestAndReceiveResponse();
            return conn.sendRequestAndReceiveResponse(bean);                  
        }catch(Exception e){         
            system.debug('Exception in ASEITPAServiceAvailIntegrationHandler.sendRequestAndReceiveResponse'+e);                
            return null;
        }
    }
    
    /*This method is used to make actual ASE ITPA webservice call for Async process*/
    private ASEITPARequestResponseBean sendRequestAndReceiveResponseAsync(String request){
        try {   
            ASEITPARequestResponseBean bean = new ASEITPARequestResponseBean();
            bean.Body = request;
            bean.GetPostMethod = ATTConstants.PostMethod;
            bean.ContentType = ATTConstants.JsonContentType;               
            bean.TimeOut = Global_Variable__c.getValues(BuyflowConstant.SESSIONTIMEOUT) != null ? Global_Variable__c.getValues(BuyflowConstant.SESSIONTIMEOUT).Value__c : BuyflowConstant.SIVARConst_12000;
            bean.EndPoint =  Endpoint_URL__c.getValues('End_Point_ASEITPAServiceAsync') != null ? Endpoint_URL__c.getValues('End_Point_ASEITPAServiceAsync').URL__c : '';
            ASEITPASendRequestAndReceiveResponse conn = new ASEITPASendRequestAndReceiveResponse();
            return conn.sendRequestAndReceiveResponse(bean);   
        }catch (Exception e) {
            system.debug('Exception in ASEITPAServiceAvailIntegrationHandler.sendRequestAndReceiveResponseAsync'+e);                
            return null;
        }                 
    }
    
    /*This method is used to parse the response and store it in bean object*/
    private ASEITPAServiceAvailResponseBean parseResponse(ASEITPARequestResponseBean resBean) {    
        try {
            ASEITPAServiceAvailResponseBean responseBean = new ASEITPAServiceAvailResponseBean(); 
            system.debug('@@@@resBean.response'+resBean.response);       
            if(resBean !=null && resBean.response.contains('"inquireTransportProductAvailabilityResponse"')){          
                responseBean = (ASEITPAServiceAvailResponseBean)JSON.deserialize(resBean.Response,ASEITPAServiceAvailResponseBean.class);                                    
                responseBean.status = ATTConstants.SUCCESS;
                responseBean.ASEITPAResponse = resBean.Response;                     
            } else {
                responseBean.status = ATTConstants.FAILURE;            
            }        
            return responseBean;
        }catch (Exception e) {
            system.debug('Exception in ASEITPAServiceAvailIntegrationHandler.parseResponse'+e);
            return null;
        }
    }     
    
    
}