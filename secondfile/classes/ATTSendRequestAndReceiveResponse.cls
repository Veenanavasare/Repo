/************************************************************************************** 
 Apex Class Name     : ATTSendRequestAndReceiveResponse
 Version             : 1.0 
 Created Date        : 11 Aug 2014
 Function            : This class handles the web service request and response
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gustavo Restrepo            8/11/2014              Original Version
*************************************************************************************/
public with sharing class ATTSendRequestAndReceiveResponse {

    public ATTRequestResponseBean sendRequestAndReceiveResponse(ATTRequestResponseBean attBean){
        system.debug('---ATTSendRequestAndReceiveResponse.sendRequestAndReceiveResponse---attBean---: ' + attBean);
        Long startTime = datetime.now().getTime();
 
        Http connection = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
                     
        request.setEndpoint(attBean.endpoint);
        request.setMethod(attBean.getPostMethod);
        request.setTimeOut(integer.valueOf(attBean.timeOut));        
        request.setBody(attBean.body);
        
        //Changes for adding contentType and Session ID: RK
        if(attBean.contentType != null)
            request.setHeader('Content-Type', attBean.contentType);
        if(attBean.authorizationHeader != null)
            request.setHeader('Authorization', 'Bearer '+attBean.authorizationHeader);
        if(attBean.authorizationHeader != null)
            request.setHeader('Authorization', 'Bearer '+attBean.authorizationHeader);  
        if(attBean.convID != null)
            request.setHeader('conv-id', attBean.convID); 
        //End: RK
        
        //G. Restrepo - adding support for MuleSoft basic auth
        if (!String.isBlank(attBean.authType) && !String.isBlank(attBean.authToken)) {
            request.setHeader('Authorization', attBean.authType + ' ' + attBean.authToken);
        }
        
        system.debug('---ATTSendRequestAndReceiveResponse.sendRequestAndReceiveResponse---request---: '+request);

        response = connection.send(request);
        system.debug('---ATTSendRequestAndReceiveResponse.sendRequestAndReceiveResponse---response---: '+response);
        system.debug('---ATTSendRequestAndReceiveResponse.sendRequestAndReceiveResponse---response.Body---: '+response.getBody());
        attBean.status = response.getStatus();
        attBean.Response = response.getBody();
        attBean.statusCode = response.getStatusCode();
        Long endTime = datetime.now().getTime();
        Long totalTime = endTime - startTime;
        attBean.responseWithHeader = response;
        system.debug('---ATTSendRequestAndReceiveResponse.sendRequestAndReceiveResponse---Time taken for call out ----- = ' + totalTime + ' ms');
        system.debug('---ATTSendRequestAndReceiveResponse.sendRequestAndReceiveResponse---attBean---: ' + attBean);
        return attBean;
    }

}