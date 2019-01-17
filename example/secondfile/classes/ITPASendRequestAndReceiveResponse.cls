/********************************************************************************************* 
 Apex Class Name     : ITPASendRequestAndReceiveResponse
 Version             : 1.0 
 Created Date        : 1st March 2016
 Function            : Class that handles the web service request and response
 
**********************************************************************************************/

public with sharing class ITPASendRequestAndReceiveResponse{

    public ITPARequestResponseBean sendRequestAndReceiveResponse(ITPARequestResponseBean itpaBean){
    
        Long startTime = datetime.now().getTime();
 
        Http connection = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        request.setEndpoint(itpaBean.endpoint);
        request.setMethod(itpaBean.getPostMethod);
        request.setTimeOut(integer.valueOf(itpaBean.timeOut));
        request.setBody(itpaBean.body);        
        system.debug('ITPA Request: '+itpaBean.body);
        
        if(!Test.isRunningTest()){
        response = connection.send(request);
        }
        
        system.debug('ITPA Response: '+response.getBody());
        itpaBean.status = response.getStatus();
        itpaBean.Response = response.getBody();
        itpaBean.statusCode = response.getStatusCode();
        
        Long endTime = datetime.now().getTime();
        Long totalTime = endTime - startTime;
        system.debug('ITPA Callout Duration: ' + totalTime + ' ms');
        
        itpaBean.finalResponse = response;        
        return itpaBean;
    }
}