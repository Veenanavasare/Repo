/************************************************************************************** 
Apex Class Name     : FlowITPAResposnseBean 
Version             : 1.0 
Created Date        : 17 Jan 2017
Function            : Response Bean for AVPN/MIS ITPA Response
*************************************************************************************/
public class FlowITPAResposnseBeanWrapper {

  public string endPoint;
    public string timeOut;
    public string getPostMethod;
    public string contentType;
    public string response;
    public string body;
    public string status;
    public integer statusCode;
    public String authCode;
    Public FlowITPARequestBean reqBean;
    public HttpResponse finalResponse;

}