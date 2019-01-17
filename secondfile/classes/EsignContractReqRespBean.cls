/************************************************************************************************
 Apex Class Name     : EsignContractReqRespBean
 Version             : 1.0 
 Created Date        : 5 January 2017
 Function            : This class tracks the state of the Esign Request Calls
*************************************************************************************************/
public with sharing class EsignContractReqRespBean{

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