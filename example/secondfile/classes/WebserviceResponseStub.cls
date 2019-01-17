/************************************************************************************** 
Apex Class Name     : WebserviceResponseStub
Version             : 1.0 
Created Date        : 17 Jan 2017
Function            : Response Stub for REST Webservice Calls
***************************************************************************************/
public class WebserviceResponseStub{

    public static String getFlowIglooResponse(){ 
        Admin_Control__c admin= [select Flow_IGLOO_Response__c from Admin_Control__c limit 1]; 
        return admin.Flow_IGLOO_Response__c;
    }
        
    public static String getFlowITPAResponse(){           
        Admin_Control__c admin= [select FlowITPAResponse__c from Admin_Control__c limit 1]; 
        return admin.FlowITPAResponse__c ;        
    }
}