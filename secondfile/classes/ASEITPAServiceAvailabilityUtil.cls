/************************************************************************************** 
 Apex Class Name     : ASEITPAServiceAvailabilityUtil
 Version             : 1.0 
 Created Date        : 13 November 2016
 Function            : Util class for ASE ITPA Service Availability 
*************************************************************************************/
public with sharing class ASEITPAServiceAvailabilityUtil{
    /*Check Service Availability for ASE ITPA*/  
    public static Boolean doASEITPACall(List<CustomerSite__c>validSiteList,ASEITPAServiceAvailResponseBean ASEITPAresponse,String quoteId){
        // Service Availability Check for selected and valid customer sites 
        Map <Integer, List<CustomerSite__c>> ITPAAvailMap  = new Map<Integer,List<CustomerSite__c>>();
        Integer keyIndex = 0;
        boolean ITPAAvailFlag = false;
        boolean isEmailSelected = false;
        Map<Id, CustomerSite__c> custSiteIdCustSiteObjMap = new Map<Id, CustomerSite__c>();
        for (CustomerSite__c item : [Select Id, ASE_ITPA_Response__c, ASE_ITPA_Response_Status__c, ASE_ITPA_Request_Time__c, ASE_ITPA_Processing_Complete__c From CustomerSite__c Where Id In: validSiteList]){
            custSiteIdCustSiteObjMap.put(item.Id, item);            
        }
        if(quoteid != null){
            list<Apttus_Proposal__Proposal__c> quoteList = [select id,Send_Email_on_Service_Complete__c from Apttus_Proposal__Proposal__c where id =:quoteid];
            isEmailSelected = quoteList[0].Send_Email_on_Service_Complete__c;    
        }       
        Integer max_sites = Integer.valueOf(Max_Sites_Allowed_For_ITPA__c.getValues('ASE_ITPA_Max_Sites') != null ? Max_Sites_Allowed_For_ITPA__c.getValues('ASE_ITPA_Max_Sites').value__c: 30);
        Integer max_days = Integer.valueOf(Max_Validity_for_ITPA__c.getValues('ASE_ITPA_Max_Days') != null ? Max_Validity_for_ITPA__c.getValues('ASE_ITPA_Max_Days').value__c: 20);
        Set<Id> validSiteSet = new Set<Id>();
        for (CustomerSite__c item : validSiteList) {           
            if (validSiteList.size() <= Max_sites && custSiteIdCustSiteObjMap.get(item.Id) != null &&
                (custSiteIdCustSiteObjMap.get(item.Id).ASE_ITPA_Response__c == NULL  || 
                   custSiteIdCustSiteObjMap.get(item.Id).ASE_ITPA_Processing_Complete__c == false ||
                    (custSiteIdCustSiteObjMap.get(item.Id).ASE_ITPA_Response__c != NULL 
                        && custSiteIdCustSiteObjMap.get(item.Id).ASE_ITPA_Request_Time__c != NULL 
                         && ((custSiteIdCustSiteObjMap.get(item.Id).ASE_ITPA_Request_Time__c.date().daysBetween(system.now().date())) > max_days || isEmailSelected)) )){
                ITPAAvailFlag = true;
                if(!ITPAAvailMap.containsKey(keyIndex)) {                  
                    ITPAAvailMap.put(keyIndex,new List<CustomerSite__c>{item});
                } else {
                    if (ITPAAvailMap.get(keyIndex).size() == 3) {
                        keyIndex ++;
                        ITPAAvailMap.put(keyIndex,new List<CustomerSite__c>{item}); 
                    } else {
                        ITPAAvailMap.get(keyIndex).add(item);
                    }    
                }
            } else if (validSiteList.size() <= Max_sites 
                        && custSiteIdCustSiteObjMap.get(item.Id) != null  
                        && custSiteIdCustSiteObjMap.get(item.Id).ASE_ITPA_Response__c != NULL 
                        && custSiteIdCustSiteObjMap.get(item.Id).ASE_ITPA_Request_Time__c != NULL 
                        && (custSiteIdCustSiteObjMap.get(item.Id).ASE_ITPA_Request_Time__c.date().daysBetween(system.now().date())) <= max_days ) {
                validSiteSet.add(item.Id);
            } else if(validSiteList.size()>Max_sites) {
                ITPAAvailFlag = true;
                if (!ITPAAvailMap.containsKey(keyIndex)) {                  
                    ITPAAvailMap.put(keyIndex,new List<CustomerSite__c>{item});
                } else {
                    if (ITPAAvailMap.get(keyIndex).size()==3){
                        keyIndex ++;
                        ITPAAvailMap.put(keyIndex,new List<CustomerSite__c>{item}); 
                    }else{
                        ITPAAvailMap.get(keyIndex).add(item);
                    }    
                }
            } else {
            }
        }    
        //In case there is no Customer Site which require to get the ASE ITPA request i.e. the ASE ITPA request time is less than 20 days
        if(!ITPAAvailFlag) {
            return true;
        }
      
        List<ASEITPAServiceAvailInfoBean> beanList = new List<ASEITPAServiceAvailInfoBean>();    
        Map<String, List<CustomerSite__c>> updateServiceAvailResponseMap = new Map<String,List<CustomerSite__c>>();          
        ASEITPAServiceAvailService serviceObj = new ASEITPAServiceAvailService();    
        ASEITPAServiceAvailInfoBean.InquireTransportProductAvailabilityRequest InquireTransportProductAvailabilityRequestObj = new ASEITPAServiceAvailInfoBean.InquireTransportProductAvailabilityRequest();
        List <ASEITPAServiceAvailInfoBean.addresses> AddressList = new List <ASEITPAServiceAvailInfoBean.addresses>();
        ASEITPAServiceAvailIntegrationHandler handler = new ASEITPAServiceAvailIntegrationHandler();
        ASEITPAServiceAvailInfoBean bean = new ASEITPAServiceAvailInfoBean();                 
        if (ITPAAvailMap!=NULL && ITPAAvailMap.size()>0){      
            for (Integer key: ITPAAvailMap.keyset()) {               
                for(CustomerSite__c item : ITPAAvailMap.get(key)) {     
                    if(!updateServiceAvailResponseMap.containsKey(item.Service_Avail_Key__c)) {
                        updateServiceAvailResponseMap.put(item.id,new List<CustomerSite__c>{item});
                    }else {
                        updateServiceAvailResponseMap.get(item.id).add(item);
                    } 
                    
                    ASEITPAServiceAvailInfoBean.additionalRequestData additionalRequestDataObj = new ASEITPAServiceAvailInfoBean.additionalRequestData();
                    additionalRequestDataObj.productType = 'SDN';
                    additionalRequestDataObj.fiberCheckIndicator = true;
                    additionalRequestDataObj.aseLSCheckIndicator = true;
                    additionalRequestDataObj.aseCopperCheckIndicator = true;
                    
                    ASEITPAServiceAvailInfoBean.ase aseObj = new ASEITPAServiceAvailInfoBean.ase();
                    aseObj.aseIndicator = true;
                    aseObj.additionalRequestData = additionalRequestDataObj;
                    
                    ASEITPAServiceAvailInfoBean.requestedProducts requestedProductsObj = new ASEITPAServiceAvailInfoBean.requestedProducts();
                    requestedProductsObj.ase = aseObj;
                    
                    ASEITPAServiceAvailInfoBean.validationOptions validationOptionsObj = new ASEITPAServiceAvailInfoBean.validationOptions();
                    validationOptionsObj.glidLookup = 3;
                    validationOptionsObj.maxAlternativeReturn = 10;                 
                   
                    ASEITPAServiceAvailInfoBean.unfieldedAddress unfieldedAddressObj = new ASEITPAServiceAvailInfoBean.unfieldedAddress();
                    unfieldedAddressObj.addressLine = item.Address_Line__c;
                    unfieldedAddressObj.structureValue = item.Structure__c;
                    unfieldedAddressObj.levelValue = item.Level__c;
                    unfieldedAddressObj.unitValue = item.Unit__c;
                    unfieldedAddressObj.city = item.City__c;
                    unfieldedAddressObj.state = item.State__c;
                    unfieldedAddressObj.postalCode = String.valueof(item.Zip_Code__c);
                    
                    ASEITPAServiceAvailInfoBean.locationOptions locationOptionsObj = new ASEITPAServiceAvailInfoBean.locationOptions();
                    locationOptionsObj.unfieldedAddress = unfieldedAddressObj;
                   
                    ASEITPAServiceAvailInfoBean.location locationObj = new ASEITPAServiceAvailInfoBean.location();
                    locationObj.locationOptions = locationOptionsObj;
                    locationObj.validationOptions = validationOptionsObj;
                    
                    ASEITPAServiceAvailInfoBean.addresses addressesObj = new ASEITPAServiceAvailInfoBean.addresses();
                    addressesObj.siteId = item.Id;
                    addressesObj.location = locationObj;
                    addressesObj.requestedProducts = requestedProductsObj;
                    AddressList.add(addressesObj);                      
                }                
            }
            InquireTransportProductAvailabilityRequestObj.quoteId = (quoteId!=null)? quoteId : ''; 
            InquireTransportProductAvailabilityRequestObj.addresses = AddressList;     
            bean.InquireTransportProductAvailabilityRequest = InquireTransportProductAvailabilityRequestObj; 
        }    
        try{     
            if (bean!=null  && validSiteList.size() <= Max_sites && ITPAAvailFlag && isEmailSelected == false){                
                ASEITPAresponse = (ASEITPAServiceAvailResponseBean)serviceObj.handleAddressValidationServiceAvailabilityRequest(bean, null);
            }else if((bean!=null  && validSiteList.size() >Max_sites && ITPAAvailFlag ) || isEmailSelected){
                ASEITPAresponse = (ASEITPAServiceAvailResponseBean)serviceObj.handleAddressValidationServiceAvailabilityRequest(bean, null);
                //if(resBeanAsync!=null && !string.isBlank(resBeanAsync.message) && resBeanAsync.message.equalsIgnoreCase(BuyflowConstant.SUBMITTED)) {       
                return true;
                //}
            }      
        }catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        try{
            if (ASEITPAresponse != NULL && ASEITPAresponse.InquireTransportProductAvailabilityResponse != NULL && validSiteList!=NULL) {
                ITPAServiceAvailResponseBean respBean = new ITPAServiceAvailResponseBean();
                if(respBean != null){
                    system.debug('@@@@response'+JSON.serialize(respBean));
                }
            }   
        }catch(Exception e) {
            system.debug('Exception in ASEITPAServiceAvailabilityUtil.doITPACall'+e);
        }    
        return false;
    }   
}