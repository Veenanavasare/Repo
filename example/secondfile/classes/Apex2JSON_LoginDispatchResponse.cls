/************************************************************************************** 
 Apex Class Name     : Apex2JSON_LoginDispatchResponse
 Version             : 1.0 
 Created Date        : 22 Oct 2014
 Function            : This class handles the Login Dispatch Response web service 
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Kumar Gupta           10/22/2014              Original Version
* Prem Kumar Gupta           10/24/2014              Modified Version
*************************************************************************************/
public with sharing class Apex2JSON_LoginDispatchResponse extends ATTServiceInfoBean{
    public LoginDispatchResponse LoginDispatchResponse;
    public class LoginDispatchResponse {
        public WSResponseHeader WSResponseHeader;
        public Header Header;
        public LoginDispatch LoginDispatch;
    }
    public class WSResponseHeader {
        //"WSResponseHeader": null,
    }
    public class Header {
        public String sourceSystem; //EBM
        public String sourceServerDomain;   //ST
        public String transactionID;    //1413313506665
    }
    public class LoginDispatch {
        public String TokenURL; //C5j45mSEdqfz4f4GnrwR2T25tizY5gb3JoVNtWp8DiYOW5d+qvPx/ODmQIQqNXpZ1YkIjLwu5BAjDh3QmlrC4DKwTvbSrVqxh7OJdGDQy61pY0V/p3JINnSHoA3V59y8PyEKzw0ipJYRx7aH4P45A54fHUeYAPmhl7eJfTknjgvK3gInuom2gAc05rEGSSNfrWNXFcr7/OozXbrO2lDposIo1aWyIGxHHPbH1HDxrXGv6QKkir068oPZ4JYvmwvml9MLyBajtQ6FzExrjz+iWyEpyAIGMY920/wNhfDv9Qy6wU2my048Od2Cp5l7aPvg
        public Response Response;
    }
    public class Response {
        public String code; //200
        public String description;  //SUCCESS
    }
    
     /*
    // This code is for parse purpose 
    public static Apex2JSON_LoginDispatchResponse parse(String json){
        return (Apex2JSON_LoginDispatchResponse) System.JSON.deserialize(json, Apex2JSON_LoginDispatchResponse.class);
    }
    // This code is for testing Purpose 
    public static testMethod void testParse() {
        String json=        '{'+
        '    "LoginDispatchResponse": {'+
        '        "WSResponseHeader": null,'+
        '        "Header": {'+
        '            "sourceSystem": "EBM",'+
        '            "sourceServerDomain": "ST",'+
        '            "transactionID": "1413313506665"'+
        '        },'+
        '        "LoginDispatch": {'+
        '            "TokenURL": "C5j45mSEdqfz4f4GnrwR2T25tizY5gb3JoVNtWp8DiYOW5d+qvPx/ODmQIQqNXpZ1YkIjLwu5BAjDh3QmlrC4DKwTvbSrVqxh7OJdGDQy61pY0V/p3JINnSHoA3V59y8PyEKzw0ipJYRx7aH4P45A54fHUeYAPmhl7eJfTknjgvK3gInuom2gAc05rEGSSNfrWNXFcr7/OozXbrO2lDposIo1aWyIGxHHPbH1HDxrXGv6QKkir068oPZ4JYvmwvml9MLyBajtQ6FzExrjz+iWyEpyAIGMY920/wNhfDv9Qy6wU2my048Od2Cp5l7aPvg",'+
        '            "Response": {'+
        '                "code": "200",'+
        '                "description": "SUCCESS"'+
        '            }'+
        '        }'+
        '    }'+
        '}';
        Apex2JSON_LoginDispatchResponse obj = parse(json);
        System.assert(obj != null);
    }
 */
   
   
}