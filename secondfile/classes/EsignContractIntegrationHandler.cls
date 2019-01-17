/*********************************************************************************************************************************** 
 Apex Class Name     : EsignContractIntegrationHandler
 Version             : 1.0 
 Created Date        : 5 January 2017
 Function            : This class handles the building of request and parsing of response for the Esign Calls
************************************************************************************************************************************/
public with sharing class EsignContractIntegrationHandler implements ESignContractIntegrationInterface {
    
    public list<Apttus_Proposal__Proposal__c> quoteList = new list<Apttus_Proposal__Proposal__c>();    
    
    /*Method to handle Esign Contract Signature Request*/ 
    public EsignContractInfoBean handleEsignRequest(EsignContractInfoBean eSignInfobean){
         try {
            EsignContractRequestBean requestBean = new EsignContractRequestBean();
            requestBean=(EsignContractRequestBean)eSignInfobean;
            system.debug('@@@@Quote Id: '+requestBean.RequestContractSignatureRequest.contractGroup.contractGroupIdentifier.sourceContractGroupIdentifier.split('_').get(0));
            if(requestBean.RequestContractSignatureRequest.contractGroup.contractGroupIdentifier.sourceContractGroupIdentifier != null){
                String quoteId = requestBean.RequestContractSignatureRequest.contractGroup.contractGroupIdentifier.sourceContractGroupIdentifier.split('_').get(0);
                quoteList = [select id, eSign_Request_Id__c from Apttus_Proposal__Proposal__c where id =: quoteId];
            }
            system.debug('@@@@QuoteList: '+quoteList ); 
            
            string request = JSON.serialize(requestBean);
            String conResult = '{'+request.substring(15);
            
            EsignContractServiceResponseBean webServiceResponse = new EsignContractServiceResponseBean();
            
            if(quoteList!= null && requestBean!=null && requestBean.RequestContractSignatureRequest.contractGroup !=null && requestBean.RequestContractSignatureRequest.contractGroup.contractGroupIdentifier != null){
                webServiceResponse = parseResponse(sendRequestAndReceiveResponse(conResult));
                return webServiceResponse;   
            }                                      
            return null;
        }
        catch (Exception e){   
            system.debug('Exception in EsignContractIntegrationHandler.handleEsignRequest'+e);            
            return null;
        }
    }

    /*This method is used to make Esign Contract Signature Request Call*/
    private EsignContractReqRespBean sendRequestAndReceiveResponse(String request){
        try{   
            EsignContractReqRespBean bean = new EsignContractReqRespBean();
            bean.Body = request;
            bean.GetPostMethod = ATTConstants.PostMethod;
            bean.ContentType = ATTConstants.JsonContentType;               
            bean.TimeOut = Global_Variable__c.getValues(BuyflowConstant.SESSIONTIMEOUT) != null ? Global_Variable__c.getValues(BuyflowConstant.SESSIONTIMEOUT).Value__c : '120000';
            bean.EndPoint =  Endpoint_URL__c.getValues('Endpoint_ESignRequestContract') != null ? Endpoint_URL__c.getValues('Endpoint_ESignRequestContract').URL__c : '';
            EsignContractSendReqReceiveResp conn = new EsignContractSendReqReceiveResp();
            return conn.sendRequestAndReceiveResponse(bean);                  
        }catch(Exception e){         
            system.debug('Exception in EsignContractIntegrationHandler.sendRequestAndReceiveResponse'+e);                
            return null;
        }
    }
     
    /*This method is used to parse the Esign Contract Signature response and store it in bean object*/
    private EsignContractServiceResponseBean parseResponse(EsignContractReqRespBean resBean) {    
        try {
            EsignContractServiceResponseBean responseBean = new EsignContractServiceResponseBean(); 
            system.debug('@@@@resBean.response'+resBean.response);       
            if(resBean !=null && resBean.response.contains('"RequestContractSignatureResponse"')){          
                responseBean = (EsignContractServiceResponseBean)JSON.deserialize(resBean.Response,EsignContractServiceResponseBean.class);                                    
                responseBean.status = ATTConstants.SUCCESS;
                responseBean.EsignContractResponse = resBean.Response;                     
            } else {
                responseBean.status = ATTConstants.FAILURE;            
            }        
            return responseBean;
        }catch (Exception e) {
            system.debug('Exception in EsignContractIntegrationHandler.parseResponse'+e);
            return null;
        }
    }  
    
    /*Method to handle Esign Query Contract Request*/ 
    public EsignContractInfoBean handleEsignQueryRequest(EsignContractInfoBean eSignInfobean){
         try {
            ESignQueryContractRequestBean requestBean = new ESignQueryContractRequestBean();
            requestBean=(ESignQueryContractRequestBean)eSignInfobean;
            system.debug('@@@@quoteid'+requestBean.QueryContractRequest.ContractGroupIdentifier.sourceContractGroupIdentifier.split('_').get(0));
            if(requestBean.QueryContractRequest.ContractGroupIdentifier.sourceContractGroupIdentifier != null){
                String quoteId = requestBean.QueryContractRequest.ContractGroupIdentifier.sourceContractGroupIdentifier.split('_').get(0);
                quoteList = [select id, eSign_Request_Id__c from Apttus_Proposal__Proposal__c where id =: quoteId];
            }
            system.debug('@@@@quoteList '+quoteList); 
            
            string request = JSON.serialize(requestBean);
            String conResult = '{'+request.substring(15);
            
            ESignQueryContractResponseBean webServiceResponse = new ESignQueryContractResponseBean();
            
            if(quoteList!= null && requestBean!=null && requestBean.QueryContractRequest.ContractGroupIdentifier !=null && requestBean.QueryContractRequest.ContractGroupIdentifier.sourceContractGroupIdentifier != null){
                webServiceResponse = parseQueryResponse(sendQueryRequestAndReceiveResponse(conResult));
                return webServiceResponse;   
            }                                      
            return null;
        }
        catch (Exception e){   
            system.debug('Exception in EsignContractIntegrationHandler.handleEsignQueryRequest '+e);            
            return null;
        }
    }
     
    /*This method is used to make Esign Query Contract Request Call*/
    private EsignContractReqRespBean sendQueryRequestAndReceiveResponse(String request){
        try{   
            EsignContractReqRespBean bean = new EsignContractReqRespBean();
            bean.Body = request;
            bean.GetPostMethod = ATTConstants.PostMethod;
            bean.ContentType = ATTConstants.JsonContentType;               
            bean.TimeOut = Global_Variable__c.getValues(BuyflowConstant.SESSIONTIMEOUT) != null ? Global_Variable__c.getValues(BuyflowConstant.SESSIONTIMEOUT).Value__c : '120000';
            bean.EndPoint =  Endpoint_URL__c.getValues('Endpoint_ESignQueryContract') != null ? Endpoint_URL__c.getValues('Endpoint_ESignQueryContract').URL__c : '';
            EsignContractSendReqReceiveResp conn = new EsignContractSendReqReceiveResp();
            return conn.sendRequestAndReceiveResponse(bean);                  
        }
        catch(Exception e){         
            system.debug('Exception in EsignContractIntegrationHandler.sendQueryRequestAndReceiveResponse'+e);                
            return null;
        }
    }
    
    /*This method is used to parse the Esign Query Contract response and store it in bean object*/
    private ESignQueryContractResponseBean parseQueryResponse(EsignContractReqRespBean resBean) {    
        try {
            ESignQueryContractResponseBean responseBean = new ESignQueryContractResponseBean(); 
            system.debug('@@@@resBean.response'+resBean.response);       
            if(resBean !=null && resBean.response.contains('"QueryContractResponse"')){          
                responseBean = (ESignQueryContractResponseBean)JSON.deserialize(resBean.Response,ESignQueryContractResponseBean.class);                                    
                responseBean.status = ATTConstants.SUCCESS;
                responseBean.EsignQueryContractResponse = resBean.Response;                     
            } else {
                responseBean.status = ATTConstants.FAILURE;            
            }        
            return responseBean;
        }catch (Exception e) {
            system.debug('Exception in EsignContractIntegrationHandler.parseQueryResponse'+e);
            return null;
        }
    }    
}