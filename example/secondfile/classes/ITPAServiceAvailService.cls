/************************************************************************************** 
 Apex Class Name     : ITPAServiceAvailService
 Version             : 1.0 
 Created Date        : 1st March 2016
 Function            : Class that handles the ITPA Service Availability Request 
 
***************************************************************************************/

public with sharing class ITPAServiceAvailService{
    
    public ITPAServiceInfoBean handleAddressValidationServiceAvailabilityRequest(ITPAServiceAvailInfoBean bean, Id siteId){
        try{
            ATTServiceFactory service = new ATTServiceFactory();         
            Object obj = service.getService(ATTConstants.ITPA_WEBSERVICE);      
            ITPAServiceAvailResponseBean resBean = new ITPAServiceAvailResponseBean();         
            
            if(obj != null  && obj instanceOf ITPAServiceAvailIntegrationHandler) {                                                     
                ITPAServiceAvailIntegrationHandler handler = (ITPAServiceAvailIntegrationHandler) obj;
                if(bean!=null && bean.InquireTransportProductAvailabilityRequest!=null && bean.InquireTransportProductAvailabilityRequest.Address!=null) {
                    resBean = (ITPAServiceAvailResponseBean)handler.handleServiceRequest(bean); 
                    return resBean;             
                }             
            }
        }  
        catch (Exception e) {
            system.debug('Exception in ITPAServiceAvailService.handleAddressValidationServiceAvailabilityRequest'+e);
            return null;
        }  
    return null;
    }
}