/************************************************************************************** 
 Apex Class Name     : ITPARequestResponseBean
 Version             : 1.0 
 Created Date        : 1st March 2016
 Function            : Class that tracks the state of web service request and response
 
***************************************************************************************/

public with sharing class ITPARequestResponseBean{

    public string endPoint;
    public string timeOut;
    public string getPostMethod;
    public string contentType;
    public string response;
    public string body;
    public string status;
    public integer statusCode;
    public HttpResponse finalResponse;
}