/**************************************************************************************** 
 Apex Class Name     : ASEITPARequestResponseBean
 Version             : 1.0 
 Created Date        : 12 November 2016
 Function            : This class tracks the state of the ASE ITPA Request and Response
*****************************************************************************************/

public with sharing class ASEITPARequestResponseBean{

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