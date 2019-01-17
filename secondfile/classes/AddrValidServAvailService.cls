/************************************************************************************** 
 Apex Class Name     : AddrValidServAvailService
 Version             : 1.0 
 Created Date        : 11 Aug 2014
 Function            : Service class to handle the address validation and service availability request
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gustavo Restrepo            8/11/2014              Original Version
*************************************************************************************/

public with sharing class AddrValidServAvailService {
    public String VariableCallType;
    public ATTServiceInfoBean handleAddressValidationServiceAvailabilityRequest(AddrValidServAvailInformationBean bean,Id siteId) {
         Boolean isMACD = true;
         list<Apttus_Proposal__Proposal__c> quoteList = new list<Apttus_Proposal__Proposal__c>();
         ATTServiceFactory service = new ATTServiceFactory();
         Object obj = service.getService(ATTConstants.VASA_WEBSERVICE);      
         AddrValidServAvailResponseBean resBean = new AddrValidServAvailResponseBean();         
         AddrValidServAvailIntegrationHandler.VASAResponseBeanAsync resBeanAsync = new AddrValidServAvailIntegrationHandler.VASAResponseBeanAsync();
         
         //Logic updated for User Story :US614050 and US614048 by Haemen
         //Code to fetch quote field - checkbox selected by User from UI and make a sync or aync call accordingly
         if(bean.ValidateAddressServiceAvailabilityRequest.sfdcQuoteId != null){
             string sfdcQuoteId = bean.ValidateAddressServiceAvailabilityRequest.sfdcQuoteId;
             quoteList = [select id,Send_Email_on_Service_Complete__c from Apttus_Proposal__Proposal__c where id =:sfdcQuoteId ];
             system.debug('Quote / Proposal ID :' + sfdcQuoteId);
             system.debug('Quote / Proposal list :' + quoteList);
             isMACD = false;
         }
         if(obj != null  && obj instanceOf AddrValidServAvailIntegrationHandler) {                                                     
            AddrValidServAvailIntegrationHandler handler = (AddrValidServAvailIntegrationHandler) obj; 
            system.debug('VAR TYPE HERE 21'+VariableCallType);
            handler.VarCallType = VariableCallType;
            system.debug('VAR TYPE HERE 23'+handler.VarCallType);
            CustomerSite__c customerSite = new CustomerSite__c();  
            Integer Max_sites = Integer.valueOf(Max_sites_allowed_VASA__c.getValues('VASA_max_sites_allowed') != null ? Max_sites_allowed_VASA__c.getValues('VASA_max_sites_allowed').value__c: 0);
           
            if(bean!=null && 
               bean.ValidateAddressServiceAvailabilityRequest!=null &&
               bean.ValidateAddressServiceAvailabilityRequest.AddressDetails!=null && 
               bean.ValidateAddressServiceAvailabilityRequest.mode.equals('A')) {
               //Added emailSelected flag to decide Sync or Async call to inform the user                              
                   if(bean.ValidateAddressServiceAvailabilityRequest.AddressDetails.size()<=Max_sites) {    
                            resBean = (AddrValidServAvailResponseBean)handler.handleServiceRequest(bean);                                 
                    try {
                        system.debug('@@@@@resBean.JSONResponse'+resBean.JSONResponse);
                        customerSite.VASAResponse__c = resBean.JSONResponse;
                        System.debug('@@@@Object'+customerSite.VASAResponse__c);
                        if(siteId!=null) {  
                            customerSite.id = siteId;                
                            update customerSite;
                        }   
                    }catch(Exception exp) {
                       // ATTException.createException('Update Customer Site',exp.getTypeName(),exp.getStackTraceString());
                    }
                    return resBean; 
                }else {
                    resBeanAsync = (AddrValidServAvailIntegrationHandler.VASAResponseBeanAsync)handler.handleServiceRequest(bean);                                 
                    return resBeanAsync; 
                } 
                
            }  
                else if(bean!=null && 
               bean.ValidateAddressServiceAvailabilityRequest!=null &&
               bean.ValidateAddressServiceAvailabilityRequest.AddressDetails!=null && 
               bean.ValidateAddressServiceAvailabilityRequest.mode.equals('B')) {
               system.debug('^^test'+bean.ValidateAddressServiceAvailabilityRequest.AddressDetails); 
               if(bean.ValidateAddressServiceAvailabilityRequest.AddressDetails.size()<=Max_sites*2 && isMACD) {
                   //Added check wheter the flow is a MACD flow or through Begin Quote and to decide Sync or Async call to inform the user
                   system.debug('Entered through MACD flow');
                   resBean = (AddrValidServAvailResponseBean)handler.handleServiceRequest(bean);  
                   system.debug('**Testing**'+resbean);                               
                   try{
                       customerSite.VASAResponse__c = resBean.JSONResponse;
                       System.debug('@@@@Object'+customerSite.VASAResponse__c);
                       if(siteId!=null) {  
                           customerSite.id = siteId;                
                           update customerSite;
                       }   
                   } catch(Exception exp){
                       system.debug('@@@@@exception: '+exp);
                       system.debug('@@@@@exception: '+exp.getLineNumber());
                       //ATTException.createException('Update Customer Site',exp.getTypeName(),exp.getStackTraceString());
                   }
                   return resBean;
               } else if(bean.ValidateAddressServiceAvailabilityRequest.AddressDetails.size()<=Max_sites*2 && !isMACD && quoteList[0].Send_Email_on_Service_Complete__c != true){
                   system.debug('Entered through regular buy flow');
                   resBean = (AddrValidServAvailResponseBean)handler.handleServiceRequest(bean);  
                   system.debug('**Testing**'+resbean);                               
                   try {
                       customerSite.VASAResponse__c = resBean.JSONResponse;
                       System.debug('@@@@Object'+customerSite.VASAResponse__c);
                       if(siteId!=null) {  
                           customerSite.id = siteId;                
                           update customerSite;
                       }   
                   } catch(Exception exp){
                    system.debug('@@@@@exception: '+exp);
                    system.debug('@@@@@exception: '+exp.getLineNumber());
                    //ATTException.createException('Update Customer Site',exp.getTypeName(),exp.getStackTraceString());
                   }
                     return resBean; 
                  } else{
                   resBeanAsync = (AddrValidServAvailIntegrationHandler.VASAResponseBeanAsync)handler.handleServiceRequest(bean);                                 
                   return resBeanAsync; 
               }     
            }             
        }    
    return null;
    }
}