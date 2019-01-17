/************************************************************************************** 
 Apex Class Name     : LoginDispatchService
 Version             : 1.0 
 Created Date        : 22 Oct 2014
 Function            : This class handles the service availability request
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Dipendu Chanda          10/22/2014              Original Version
* Prem Kumar Gupta        10/24/2014              Modified Version
*************************************************************************************/
public with sharing class LoginDispatchService {
    // 32 bit data need to be assign to variable 'key'
    //public final Blob key=Blob.valueOf('v3erqY/EGg1NI0yFHYLsMt7IuqJksxNjo1dlhsOo6Zs=');
    
    public ATTServiceInfoBean handleLoginDispatchService(Apex2JSON_LoginDispatchRequest bean) {
         ATTServiceFactory service = new ATTServiceFactory();
         Object obj = service.getService(ATTConstants.LOGIN_DISPATCH);      
         Apex2JSON_LoginDispatchResponse resBean = new Apex2JSON_LoginDispatchResponse();         
         if(obj != null  && obj instanceOf LoginDispatchIntegrationHandler) {                                                     
            LoginDispatchIntegrationHandler handler = (LoginDispatchIntegrationHandler) obj;
            
            // calling mocking request bean, only use for mock request data passing
            //Apex2JSON_LoginDispatchRequest bean = new Apex2JSON_LoginDispatchRequest();
            //bean = LoginDispatchService.populateRequestBean();
            
            
            resBean = (Apex2JSON_LoginDispatchResponse)handler.handleServiceRequest(bean);
                          //Check for null before retrieving the blob information - Anand 0922
             if(resBean.LoginDispatchResponse != null && resBean.LoginDispatchResponse.LoginDispatch != null && resBean.LoginDispatchResponse.LoginDispatch.TokenURL != null)
             { 
                 System.debug('resBean :    '+resBean );
                 Blob encrypted=Blob.valueOf(resBean.LoginDispatchResponse.LoginDispatch.TokenURL);
                 String encryptedString=encrypted.toString();
                 System.debug('encryptedString:    '+encryptedString);
                 System.debug('handler'+handler);    
             }
            return resBean;                        
         }else {
             return null;
         }             
    }    
    
    public Apex2JSON_LoginDispatchRequest populateRequestBean(List<Map<String,String>> requestBeanList){
    
        Apex2JSON_LoginDispatchRequest.WSEndUserToken wSEndUserToken= new Apex2JSON_LoginDispatchRequest.WSEndUserToken();
        wSEndUserToken.Token='';
        wSEndUserToken.TokenType='';
        Apex2JSON_LoginDispatchRequest.WSNameValue wSNameValue= new Apex2JSON_LoginDispatchRequest.WSNameValue();
        wSNameValue.Name= /*ATnT_RequestData__c.getInstance().Username1__c;//*/'username';
        wSNameValue.Value=/*ATnT_RequestData__c.getInstance().Username2__c; //*/'pe';
        List<Apex2JSON_LoginDispatchRequest.WSNameValue> wSNameValueList1= new List<Apex2JSON_LoginDispatchRequest.WSNameValue>();
        system.debug('******'+wSNameValue);
        wSNameValueList1.add(wSNameValue);
        Apex2JSON_LoginDispatchRequest.WSNameValue wSNameValueP= new Apex2JSON_LoginDispatchRequest.WSNameValue();
        wSNameValueP.Name= /*ATnT_RequestData__c.getInstance().Password1__c;//*/'password';
        wSNameValueP.Value=/*ATnT_RequestData__c.getInstance().Password2__c;//*/'pe7att';
        wSNameValueList1.add(wSNameValueP);
        wSEndUserToken.WSNameValue=wSNameValueList1;
        
        Apex2JSON_LoginDispatchRequest.WSContext wSContext= new Apex2JSON_LoginDispatchRequest.WSContext();
        wSContext.FromAppId='';
        wSContext.ToAppId='';
        Apex2JSON_LoginDispatchRequest.Version version= new Apex2JSON_LoginDispatchRequest.Version();
        version.major='';
        version.minor='';
        wSContext.Version=version;
        wSContext.SourceIPAddress='';
        Apex2JSON_LoginDispatchRequest.WSNameValue wSNameValue1= new Apex2JSON_LoginDispatchRequest.WSNameValue();
        wSNameValue1.Name='';
        wSNameValue1.Value='';
        List<Apex2JSON_LoginDispatchRequest.WSNameValue> wSNameValueList2= new List<Apex2JSON_LoginDispatchRequest.WSNameValue>();
        wSNameValueList2.add(wSNameValue1);
        wSContext.WSNameValue=wSNameValueList2;
        
        Apex2JSON_LoginDispatchRequest.WSCallback  wSCallback= new Apex2JSON_LoginDispatchRequest.WSCallback();
        wSCallback.URL='';
        wSCallback.WSCorrelationId='';
        wSCallback.FaultURL='';
        
        
        Apex2JSON_LoginDispatchRequest.WSMessageData wSMessageData= new Apex2JSON_LoginDispatchRequest.WSMessageData();
        wSMessageData.MessageId='';
        wSMessageData.RefToMessageId='';
        wSMessageData.Timestamp='';
        
        
        Apex2JSON_LoginDispatchRequest.WSEnterpriseLogging wSEnterpriseLogging=new Apex2JSON_LoginDispatchRequest.WSEnterpriseLogging();
        wSEnterpriseLogging.ApplicationID='';
        wSEnterpriseLogging.LoggingKey='';
        
        
        Apex2JSON_LoginDispatchRequest.WSHeader wSHeader= new Apex2JSON_LoginDispatchRequest.WSHeader();
        wSHeader.WSEndUserToken=wSEndUserToken;
        wSHeader.WSContext=wSContext;
        wSHeader.WSCallback=wSCallback;
        wSHeader.WSConversationId='';
        wSHeader.WSMessageData=wSMessageData;
        wSHeader.WSResponseMessageExpiration='';
        wSHeader.WSEnterpriseLogging=wSEnterpriseLogging;
         
        
        Apex2JSON_LoginDispatchRequest.Header header=new Apex2JSON_LoginDispatchRequest.Header();
        header.sourceSystem=/*ATnT_RequestData__c.getInstance().SourceSystem__c;//*/'EBM';
        header.sourceServerDomain=/*ATnT_RequestData__c.getInstance().SourceServerDomain__c;//*/'Force';
        header.transactionID=String.valueOf(Math.random()).substring(2,15);//Generating 13 digits random number e.g.'1413313506665';
        
        Apex2JSON_LoginDispatchRequest.LoginDispatch loginDispatch=new Apex2JSON_LoginDispatchRequest.LoginDispatch();
        system.debug('List--->'+requestBeanList.get(0));
        loginDispatch.ProvisioningServiceID=requestBeanList.get(0).get('ProvisioningServiceID');//System.Label.ProvisioningServiceID;
        loginDispatch.ProfileType= requestBeanList.get(0).get('ProfileType');//System.Label.profileType;
        loginDispatch.SourceSystemUserID= requestBeanList.get(0).get('SourceSystemUserID');//System.Label.SourceSystemUserID;
        loginDispatch.PremierLogin= requestBeanList.get(0).get('PremierLogin');//System.Label.PremierLogin;
        loginDispatch.PremierOrderId= requestBeanList.get(0).get('PremierOrderId') != null ? requestBeanList.get(0).get('PremierOrderId') : '' ;
        loginDispatch.Dealdiscount= '';
        loginDispatch.PremierUserStatus= requestBeanList.get(0).get('PremierUserStatus') != null ? requestBeanList.get(0).get('PremierUserStatus') : '' ;
        loginDispatch.PEDealStatus= '';
        
        
        
        Apex2JSON_LoginDispatchRequest.LoginDispatchRequest loginDispatchRequestObj= new Apex2JSON_LoginDispatchRequest.LoginDispatchRequest();
        loginDispatchRequestObj.WSHeader=wSHeader;
        loginDispatchRequestObj.Header=header;
        loginDispatchRequestObj.LoginDispatch=loginDispatch;
        
        Apex2JSON_LoginDispatchRequest  loginDispatchRequest= new Apex2JSON_LoginDispatchRequest();
        loginDispatchRequest.LoginDispatchRequest=loginDispatchRequestObj;
    
        system.debug('request output:'+loginDispatchRequest);
    return loginDispatchRequest;

    }
    
    
    
    /*Sample response Bean , can be tested for Mocking purpose or to verfify the webservice response */
    /*public static Apex2JSON_LoginDispatchResponse populateResponseBean(){
        Apex2JSON_LoginDispatchResponse.WSResponseHeader wSResponseHeader= new Apex2JSON_LoginDispatchResponse.WSResponseHeader();
        
        Apex2JSON_LoginDispatchResponse.Header header= new Apex2JSON_LoginDispatchResponse.Header();
        header.sourceSystem='EBM';
        header.sourceServerDomain='ST';
        header.transactionID='1413313506665';
        
        Apex2JSON_LoginDispatchResponse.LoginDispatch loginDispatch= new Apex2JSON_LoginDispatchResponse.LoginDispatch();
        loginDispatch.TokenURL='C5j45mSEdqfz4f4GnrwR2T25tizY5gb3JoVNtWp8DiYOW5d+qvPx/ODmQIQqNXpZ1YkIjLwu5BAjDh3QmlrC4DKwTvbSrVqxh7OJdGDQy61pY0V/p3JINnSHoA3V59y8PyEKzw0ipJYRx7aH4P45A54fHUeYAPmhl7eJfTknjgvK3gInuom2gAc05rEGSSNfrWNXFcr7/OozXbrO2lDposIo1aWyIGxHHPbH1HDxrXGv6QKkir068oPZ4JYvmwvml9MLyBajtQ6FzExrjz+iWyEpyAIGMY920/wNhfDv9Qy6wU2my048Od2Cp5l7aPvg';
        Apex2JSON_LoginDispatchResponse.Response response= new Apex2JSON_LoginDispatchResponse.Response();
        response.code='200';
        response.description='SUCCESS';
        loginDispatch.Response=response;
        
        Apex2JSON_LoginDispatchResponse.LoginDispatchResponse loginDispatchResponseObj = new Apex2JSON_LoginDispatchResponse.LoginDispatchResponse();
        loginDispatchResponseObj.WSResponseHeader=wSResponseHeader;
        loginDispatchResponseObj.Header=header;
        loginDispatchResponseObj.LoginDispatch=loginDispatch;
        
        Apex2JSON_LoginDispatchResponse  loginDispatchResponse= new Apex2JSON_LoginDispatchResponse();
        loginDispatchResponse.LoginDispatchResponse=loginDispatchResponseObj;
        
        system.debug('response output:::'+loginDispatchResponse);

    return loginDispatchResponse;
    }
    */
}