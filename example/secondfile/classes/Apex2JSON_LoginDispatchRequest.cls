/************************************************************************************** 
 Apex Class Name     : Apex2JSON_LoginDispatchRequest
 Version             : 1.0 
 Created Date        : 22 Oct 2014
 Function            : This class handles the Login Dispatch Request web service 
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Kumar Gupta           10/22/2014              Original Version
* Prem Kumar Gupta           10/24/2014              Modified Version
*************************************************************************************/
public  with sharing class Apex2JSON_LoginDispatchRequest extends ATTServiceInfoBean{
  public LoginDispatchRequest LoginDispatchRequest;
    public class LoginDispatchRequest {
        public WSHeader WSHeader;
        public Header Header;
        public LoginDispatch LoginDispatch;
    }
    public class WSHeader {
        public WSEndUserToken WSEndUserToken;
        public WSContext WSContext;
        public WSCallback WSCallback;
        public String WSConversationId; //
        public WSMessageData WSMessageData;
        public String WSResponseMessageExpiration;  //
        public WSEnterpriseLogging WSEnterpriseLogging;
    }
    public class WSEndUserToken {
        public String Token;    //
        public String TokenType;    //
        public List<WSNameValue> WSNameValue;
    }
    public class WSNameValue {
        public String Name; //
        public String Value;    //
    }
    public class WSContext {
        public String FromAppId;    //
        public String ToAppId;  //
        public Version Version;
        public String SourceIPAddress;  //
        public List<WSNameValue> WSNameValue;
    }
    public class Version {
        public String major;    //
        public String minor;    //
    }
    public class WSCallback {
        public String URL;  //
        public String WSCorrelationId;  //
        public String FaultURL; //
    }
    public class WSMessageData {
        public String MessageId;    //
        public String RefToMessageId;   //
        public String Timestamp;    //
    }
    public class WSEnterpriseLogging {
        public String ApplicationID;    //
        public String LoggingKey;   //
    }
    public class Header {
        public String sourceSystem; //EBM
        public String sourceServerDomain;   //ST
        public String transactionID;    //1413313506665
    }
    public class LoginDispatch {
        public String ProvisioningServiceID;    //o31634600562
        public String ProfileType;  //PLATINUM
        public String SourceSystemUserID;   //iPhone 6 - New Order
        public String PremierLogin; //QAPEMobilityTCM-Rain
        public String PremierOrderId;   //
        public String Dealdiscount; //
        public String PremierUserStatus;    //
        public String PEDealStatus; //
    }
    
 /*
   // This code is for parse purpose 
    public static Apex2JSON_LoginDispatchRequest parse(String json){
        return (Apex2JSON_LoginDispatchRequest) System.JSON.deserialize(json, Apex2JSON_LoginDispatchRequest.class);
    }
   // This code is for testing Purpose  
    static testMethod void testParse() {
        String json=        '{'+
        '    "LoginDispatchRequest": {'+
        '        "WSHeader": {'+
        '            "WSEndUserToken": {'+
        '                "Token": "",'+
        '                "TokenType": "",'+
        '                "WSNameValue": ['+
        '                    {'+
        '                        "Name": "username",'+
        '                        "Value": "pe"'+
        '                    },'+
        '                    {'+
        '                        "Name": "password",'+
        '                        "Value": "pe7att"'+
        '                    }'+
        '                ]'+
        '            },'+
        '            "WSContext": {'+
        '                "FromAppId": "",'+
        '                "ToAppId": "",'+
        '                "Version": {'+
        '                    "major": "",'+
        '                    "minor": ""'+
        '                },'+
        '                "SourceIPAddress": "",'+
        '                "WSNameValue": ['+
        '                    {'+
        '                        "Name": "",'+
        '                        "Value": ""'+
        '                    }'+
        '                ]'+
        '            },'+
        '            "WSCallback": {'+
        '                "URL": "",'+
        '                "WSCorrelationId": "",'+
        '                "FaultURL": ""'+
        '            },'+
        '            "WSConversationId": "",'+
        '            "WSMessageData": {'+
        '                "MessageId": "",'+
        '                "RefToMessageId": "",'+
        '                "Timestamp": ""'+
        '            },'+
        '            "WSResponseMessageExpiration": "",'+
        '            "WSEnterpriseLogging": {'+
        '                "ApplicationID": "",'+
        '                "LoggingKey": ""'+
        '            }'+
        '        },'+
        '        "Header": {'+
        '            "sourceSystem": "EBM",'+
        '            "sourceServerDomain": "ST",'+
        '            "transactionID": "1413313506665"'+
        '        },'+
        '        "LoginDispatch": {'+
        '            "ProvisioningServiceID": "o31634600562",'+
        '            "ProfileType": "PLATINUM",'+
        '            "SourceSystemUserID": "iPhone 6 - New Order",'+
        '            "PremierLogin": "QAPEMobilityTCM-Rain",'+
        '            "PremierOrderId": "",'+
        '            "Dealdiscount": "",'+
        '            "PremierUserStatus": "",'+
        '            "PEDealStatus": ""'+
        '        }'+
        '    }'+
        '}';
        Apex2JSON_LoginDispatchRequest obj = parse(json);
        System.assert(obj != null);
    }
}

*/



  
}