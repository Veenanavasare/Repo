/******************************************************************************************** 
 Apex Class Name     : ASEITPASendRequestAndReceiveResponse
 Version             : 1.0 
 Created Date        : 12 November 2016
 Function            : This class handles the ASE ITPA web service request and response
*********************************************************************************************/
public with sharing class ASEITPASendRequestAndReceiveResponse{

    public ASEITPARequestResponseBean sendRequestAndReceiveResponse(ASEITPARequestResponseBean aseITPABean){
    
        Long startTime = datetime.now().getTime();
 
        Http connection = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();        
                     
        request.setEndpoint(aseITPABean.endpoint);
        request.setMethod(aseITPABean.getPostMethod);
        request.setTimeOut(integer.valueOf(aseITPABean.timeOut));        
        request.setBody(aseITPABean.body);
                
        system.debug('ASE ITPA Request: '+aseITPABean.body); 
        response = connection.send(request);
        system.debug('ASE ITPA Response: '+response.getBody());
        
        aseITPABean.status = response.getStatus();
        aseITPABean.Response = response.getBody();
        aseITPABean.statusCode = response.getStatusCode();
        
        Long endTime = datetime.now().getTime();
        Long totalTime = endTime - startTime;
        system.debug('ASE ITPA Callout Duration: ' + totalTime + ' ms');
        system.debug('@@@aseITPABean returned'+aseITPABean);
        return aseITPABean;
    }
}