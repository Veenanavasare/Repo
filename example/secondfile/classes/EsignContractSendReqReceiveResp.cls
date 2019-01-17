/******************************************************************************************** 
 Apex Class Name     : EsignContractSendReqReceiveResp
 Version             : 1.0 
 Created Date        : 5 January 2017
 Function            : This class handles the ESign Calls
*********************************************************************************************/
public with sharing class EsignContractSendReqReceiveResp{

    public EsignContractReqRespBean sendRequestAndReceiveResponse(EsignContractReqRespBean esignContractBean){
    
        Long startTime = datetime.now().getTime();
 
        Http connection = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();        
                     
        request.setEndpoint(esignContractBean.endpoint);
        request.setMethod(esignContractBean.getPostMethod);
        request.setTimeOut(integer.valueOf(esignContractBean.timeOut));        
        request.setBody(esignContractBean.body);
                
        system.debug('Esign Request: '+esignContractBean.body); 
        response = connection.send(request);
        system.debug('Esign Response: '+response.getBody());
        
        esignContractBean.status = response.getStatus();
        esignContractBean.Response = response.getBody();
        esignContractBean.statusCode = response.getStatusCode();
        
        Long endTime = datetime.now().getTime();
        Long totalTime = endTime - startTime;
        system.debug('Esign Callout Duration: ' + totalTime + ' ms');
        system.debug('Esign Contract Bean: '+esignContractBean);
        return esignContractBean;
    }
}