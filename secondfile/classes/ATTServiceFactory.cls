/************************************************************************************** 
 Apex Class Name     : ATTServiceFactory
 Version             : 1.0 
 Created Date        : 11 Aug 2014
 Function            : Factory class that will return the requested service
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gustavo Restrepo            8/11/2014              Original Version
*************************************************************************************/

public with sharing class ATTServiceFactory {  
    private Map<String, Object> attServiceModuleMap = new Map<String, Object>();
     
    public ATTServiceFactory(){   
        attServiceModuleMap.put(ATTConstants.VASA_WEBSERVICE,new AddrValidServAvailIntegrationHandler());
        attServiceModuleMap.put(ATTConstants.ITPA_WEBSERVICE,new ITPAServiceAvailIntegrationHandler());
        attServiceModuleMap.put(ATTConstants.ASE_ITPA_WEBSERVICE,new ASEITPAServiceAvailIntegrationHandler());
        attServiceModuleMap.put(ATTConstants.AIA_WEBSERVICE,new BrassIntegrationHandler());        
        attServiceModuleMap.put(ATTConstants.LOGIN_DISPATCH,new LoginDispatchIntegrationHandler());  
        attServiceModuleMap.put(ATTConstants.ESIGN_WEBSERVICE,new EsignContractIntegrationHandler());   
    }    

    public Object getService(String requestType){
        System.debug('-----ATTServiceFactory.getService-requestType---- : ' + requestType);
        if (attServiceModuleMap.containsKey(requestType)) {
            return attServiceModuleMap.get(requestType);
        } else {
            System.debug('-----ATTServiceFactory.getService----- : Requested service not available');
        }
        return null; 
    }
}