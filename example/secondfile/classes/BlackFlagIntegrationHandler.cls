/************************************************************************************** 
Apex Class Name     : BlackFlagIntegrationHandler
Version             : 1.0 
Created Date        : 17 Jan 2017
Function            : To invoke black flag to get Auth Code
*************************************************************************************/
public class BlackFlagIntegrationHandler{

    public String InvokeBlackFlag(){
        String authToken = Global_Variable__c.getValues('BlackFlagAuthToken')!=null ? Global_Variable__c.getValues('BlackFlagAuthToken').Value__c : '';
        String authSecret = Global_Variable__c.getValues('BlackFlagAuthSecret')!=null ? Global_Variable__c.getValues('BlackFlagAuthSecret').Value__c : '';
        String scope = Global_Variable__c.getValues('BlackFlagRequestScope')!=null ? Global_Variable__c.getValues('BlackFlagRequestScope').Value__c : '';
        String grant = Global_Variable__c.getValues('BlackFlagGrant')!=null ? Global_Variable__c.getValues('BlackFlagGrant').Value__c : '';
        String endPointURL =Global_Variable__c.getValues('BlackFlagEndPoint')!=null ? Global_Variable__c.getValues('BlackFlagEndPoint').Value__c : '';
        Httprequest req = new HttpRequest();
        Http http = new Http();
        req.setEndpoint(endPointURL );
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Accept','application/json');
        req.setHeader('Accept-Language','en_US');  
        req.setBody('grant_type='+EncodingUtil.urlEncode(grant, 'UTF-8')
                   +'&client_id='+EncodingUtil.urlEncode(authToken, 'UTF-8')
                   +'&client_secret='+EncodingUtil.urlEncode(authSecret, 'UTF-8')              
                   +'&scope='+scope);       
        HttpResponse response = http.send(req);
        System.debug('responseBody: '+response.getBody());
        
        BlackFlagRequestBean responseBean=new BlackFlagRequestBean();
        responseBean= (BlackFlagRequestBean)JSON.deserialize(response.getBody(),BlackFlagRequestBean.class);    
        
        Global_Variable__c gv=[SELECT id,Value__C FROM Global_Variable__c WHERE name = 'BlackFlagAccessToken' limit 1];
        gv.Value__C=responseBean.access_token;
        update gv;
        
        BlackFlageCS__c blackFlagCS=[select id,value__c from BlackFlageCS__c where name ='AuthCodeRequestTime' limit 1];
        blackFlagCS.value__c=system.now(); //Need to update time from response
        update blackFlagCS;
        return responseBean.access_token;
    }
}