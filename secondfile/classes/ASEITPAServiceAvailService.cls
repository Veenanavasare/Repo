/********************************************************************************************** 
 Apex Class Name     : ASEITPAServiceAvailService
 Version             : 1.0 
 Created Date        : 12 November 2016
 Function            : Service class to handle the ASE ITPA Service Availability Request
***********************************************************************************************/

public with sharing class ASEITPAServiceAvailService{
 
    public ASEITPAServiceInfoBean handleAddressValidationServiceAvailabilityRequest(ASEITPAServiceAvailInfoBean bean,Id siteId) {
        try{ 
            ATTServiceFactory service = new ATTServiceFactory();
            Object obj = service.getService(ATTConstants.ASE_ITPA_WEBSERVICE);      
            ASEITPAServiceAvailResponseBean resBean = new ASEITPAServiceAvailResponseBean();     
            
            if(obj != null  && obj instanceOf ASEITPAServiceAvailIntegrationHandler) {                                                     
                ASEITPAServiceAvailIntegrationHandler handler = (ASEITPAServiceAvailIntegrationHandler) obj; 
                if(bean != null && bean.InquireTransportProductAvailabilityRequest != null && bean.InquireTransportProductAvailabilityRequest.addresses != null) {
                    resBean = (ASEITPAServiceAvailResponseBean)handler.handleServiceRequest(bean); 
                    return resBean;      
                }             
            } 
        }  
        catch (Exception e) {
            system.debug('Exception in ASEITPAServiceAvailService.handleAddressValidationServiceAvailabilityRequest'+e);
            return null;
        }   
        return null;
    }
}