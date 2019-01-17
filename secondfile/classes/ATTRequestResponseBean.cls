/************************************************************************************** 
 Apex Class Name     : ATTRequestResponseBean
 Version             : 1.0 
 Created Date        : 11 Aug 2014
 Function            : This class tracks the state of the web service request and response 
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gustavo Restrepo            8/11/2014              Original Version
*************************************************************************************/
public with sharing class ATTRequestResponseBean {

    public string endPoint;
    public string timeOut;
    public string token;
    public string getPostMethod;
    public string contentType;
    public string response;
    public Dom.Document responseDocument;
    public string body;
    public string authorizationHeader;
    public string status;
    public string acceptHeader;
    public integer statusCode;
    // Changes to support Basic Auth support (VASA)
    public string authType; 
    public string authToken;
    //for BD Company creation
    public string convID;
    public HttpResponse responseWithHeader;
}