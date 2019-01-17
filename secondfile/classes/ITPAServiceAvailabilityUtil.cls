/************************************************************************************** 
 Apex Class Name     : ITPAServiceAvailabilityUtil
 Version             : 1.0 
 Created Date        : 1st March 2016
 Function            : Utility Class for IPFlex ITPA Call 

*************************************************************************************/

/* 
 Name: ITPAServiceAvailabilityUtil
 Type: Class 
 
 Description: 
 */ 
public with sharing class ITPAServiceAvailabilityUtil{


/* 
 Name: doITPACall
 Description: 
 */ 
    public static Boolean doITPACall(List<CustomerSite__c> siteList, ITPAServiceAvailResponseBean ITPAresponse, String quoteId){
        
        Map <Integer, List<CustomerSite__c>> ITPAAvailMap  = new Map<Integer,List<CustomerSite__c>>();
        Map<Id, CustomerSite__c> custIdObjMap = new Map<Id, CustomerSite__c>();
        Boolean ITPAAvailFlag = false;
        String voipAvailabilityFlag;
        String voipLocalAvailabilityFlag;
        String ipIDAvailabilityIndicator;
        String PlansQualify;
        Integer index = 0;       
        list<CustomerSite__c> listOfSitesToBeUpdated = new list<CustomerSite__c>();
        
        for (CustomerSite__c item : [Select Id, ITPA_Response__c, ITPA_Request_Time__c, Phone_Number_Updated__c, IPFLEX_Availability_Flag__c From CustomerSite__c Where Id In: siteList]) {
            custIdObjMap.put(item.Id, item);            
        }
        
        for (CustomerSite__c item : siteList) {
            if (custIdObjMap.get(item.Id) != null && (custIdObjMap.get(item.Id).ITPA_Response__c == NULL || custIdObjMap.get(item.Id).ITPA_Request_Time__c == NULL || custIdObjMap.get(item.Id).Phone_Number_Updated__c == true || custIdObjMap.get(item.Id).IPFLEX_Availability_Flag__c != SpecialCharacterBuyflowConstant.TRUE_LITERAL 
                || (custIdObjMap.get(item.Id).ITPA_Request_Time__c != NULL && (custIdObjMap.get(item.Id).ITPA_Request_Time__c.date().daysBetween(system.now().date())) >30))){
                    ITPAAvailFlag = true;                             
                    if(!ITPAAvailMap.containsKey(index)) {                  
                        ITPAAvailMap.put(index,new List<CustomerSite__c>{item});
                    } else {
                        if (ITPAAvailMap.get(index).size() == 3) {
                            index ++;
                            ITPAAvailMap.put(index,new List<CustomerSite__c>{item}); 
                        } else {
                            ITPAAvailMap.get(index).add(item);
                        }    
                    }
            }else{
                if(custIdObjMap.get(item.Id) != null && custIdObjMap.get(item.Id).Id != null){
                    String siteId = custIdObjMap.get(item.Id).Id;                
                    listOfSitesToBeUpdated  = [Select Id, ITPA_Processing_Complete__c,Phone_Number_Updated__c from CustomerSite__c Where Id =: siteId]; 
                    if(listOfSitesToBeUpdated != null && listOfSitesToBeUpdated.size() > 0 ){
                        listOfSitesToBeUpdated[0].ITPA_Processing_Complete__c = true;
                        listOfSitesToBeUpdated[0].Phone_Number_Updated__c  = false;
                        update listOfSitesToBeUpdated;
                    }
                }
            }            
        }    

        if(!ITPAAvailFlag) {
            
            return true;
        }
        
       
        List<ITPAServiceAvailInfoBean> beanList = new List<ITPAServiceAvailInfoBean>();    
        Map<String, List<CustomerSite__c>> updateServiceAvailResponseMap = new Map<String,List<CustomerSite__c>>();  
        ITPAServiceAvailService serviceObj = new ITPAServiceAvailService();   
        ITPAServiceAvailInfoBean.InquireTransportProductAvailabilityRequest InquireTransportProductAvailabilityRequestObj = new ITPAServiceAvailInfoBean.InquireTransportProductAvailabilityRequest();
        List <ITPAServiceAvailInfoBean.Address> AddressList = new List <ITPAServiceAvailInfoBean.Address>();
        ITPAServiceAvailIntegrationHandler handler = new ITPAServiceAvailIntegrationHandler();
        ITPAServiceAvailInfoBean bean = new ITPAServiceAvailInfoBean();           
        
        // Call doServiceAvailCheck method for service availablity 
        if (ITPAAvailMap!=NULL && ITPAAvailMap.size()>0){  
       
            InquireTransportProductAvailabilityRequestObj.quoteId = (quoteId!=null)?quoteId:SpecialCharacterBuyflowConstant.CONCAT;
          
            for (Integer key: ITPAAvailMap.keyset()) {         
                            
                // Populate Address class instance
                for(CustomerSite__c item : ITPAAvailMap.get(key)) {     
                    if(!updateServiceAvailResponseMap.containsKey(item.Service_Avail_Key__c)) {
                        updateServiceAvailResponseMap.put(item.id,new List<CustomerSite__c>{item});
                    }else {
                        updateServiceAvailResponseMap.get(item.id).add(item);
                    }
                    
                    ITPAServiceAvailInfoBean.UnfieldedAddress UnfieldedAddressObj = new ITPAServiceAvailInfoBean.UnfieldedAddress();
                    UnfieldedAddressObj.addressLine1 = item.Address_Line__c;
                    UnfieldedAddressObj.addressLine2 = SpecialCharacterBuyflowConstant.CONCAT;
                    UnfieldedAddressObj.city = item.City__c;
                    UnfieldedAddressObj.state = item.State__c;
                    UnfieldedAddressObj.postalCode = String.valueof(item.Zip_Code__c);
                    UnfieldedAddressObj.postalCodePlus4 = SpecialCharacterBuyflowConstant.CONCAT;
                    UnfieldedAddressObj.county = SpecialCharacterBuyflowConstant.CONCAT;
                    UnfieldedAddressObj.country = item.country__c; 
                    UnfieldedAddressObj.structureType = SpecialCharacterBuyflowConstant.CONCAT;
                    UnfieldedAddressObj.structureValue = SpecialCharacterBuyflowConstant.CONCAT;
                    UnfieldedAddressObj.levelType = SpecialCharacterBuyflowConstant.CONCAT;
                    UnfieldedAddressObj.levelValue = SpecialCharacterBuyflowConstant.CONCAT;
                    UnfieldedAddressObj.unitType = SpecialCharacterBuyflowConstant.CONCAT;
                    UnfieldedAddressObj.unitValue = SpecialCharacterBuyflowConstant.CONCAT;
                    UnfieldedAddressObj.additionalName = SpecialCharacterBuyflowConstant.CONCAT;
                    UnfieldedAddressObj.crossStreet = SpecialCharacterBuyflowConstant.CONCAT;
                    UnfieldedAddressObj.serviceId = SpecialCharacterBuyflowConstant.CONCAT;
                    
                    ITPAServiceAvailInfoBean.Telephone TelephoneObj = new ITPAServiceAvailInfoBean.Telephone();
                    TelephoneObj.attTelephoneNumber = item.Phone__c;
                    
                    ITPAServiceAvailInfoBean.Address AddressObj = new ITPAServiceAvailInfoBean.Address();
                    AddressObj.siteId = item.Id;
                    AddressObj.Telephone = TelephoneObj;
                    AddressObj.UnfieldedAddress = UnfieldedAddressObj;
                    AddressList.add(AddressObj);     
                }
            }
             InquireTransportProductAvailabilityRequestObj.Address = AddressList;         
             bean.InquireTransportProductAvailabilityRequest = InquireTransportProductAvailabilityRequestObj; 
        }   
        
        try{        
            // Get VASA response from handleAddressValidationServiceAvailabilityRequest method by passing request bean and end customer Id.
            // VASA response is ITPAServiceAvailResponseBean class instance (response bean) 
            if(!Test.isRunningTest()){  
                 if (bean!=null && ITPAAvailFlag){
                    ITPAresponse = (ITPAServiceAvailResponseBean)serviceObj.handleAddressValidationServiceAvailabilityRequest(bean, null);
                 }
             }         
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.createException('Error in VASA handlers', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        
        // Create List of AddressServiceAvailability class (inner class of ITPAServiceAvailResponseBean or response bean)
        List <ITPAServiceAvailResponseBean.InquireTransportProductAvailabilityResponse> respBeanAddressServiceAvailabilityList = new List <ITPAServiceAvailResponseBean.InquireTransportProductAvailabilityResponse> ();
        
        try{
            // Assign response bean AddressServiceAvailabilityList to  list instance created.
           
            if (ITPAresponse != NULL && ITPAresponse.InquireTransportProductAvailabilityResponse!= NULL && siteList!=NULL) {
                respBeanAddressServiceAvailabilityList.addAll(ITPAresponse.InquireTransportProductAvailabilityResponse);
                
                Map<String,List<ITPAServiceAvailResponseBean.InquireTransportProductAvailabilityResponse>> jsonMap = new Map<String,List<ITPAServiceAvailResponseBean.InquireTransportProductAvailabilityResponse>>();
                
                
                // Iterate through AddressServiceAvailability list returned from response bean.                
                for (ITPAServiceAvailResponseBean.InquireTransportProductAvailabilityResponse item: respBeanAddressServiceAvailabilityList) {
                    if(item.Response.Code!=null && item.ProductVoiceOverIP !=null && item.ProductVoiceOverIP.VoiceOverIPServiceAvailability != null && Integer.valueOf(item.Response.Code)==0 ) {
                        String tempKey = item.siteid;
                        if (updateServiceAvailResponseMap.containsKey(tempKey)){
                            ITPAServiceAvailResponseBean respBean = new ITPAServiceAvailResponseBean();
                            if (jsonMap.containsKey(tempKey)){
                                jsonMap.get(tempKey).add(item);
                            }else{
                                jsonMap.put(tempKey,new List<ITPAServiceAvailResponseBean.InquireTransportProductAvailabilityResponse>{item});
                            }
                            respBean.InquireTransportProductAvailabilityResponse = new List<ITPAServiceAvailResponseBean.InquireTransportProductAvailabilityResponse>();                            
                            respBean.InquireTransportProductAvailabilityResponse.addAll(jsonMap.get(tempKey)); 
                           
                            for (CustomerSite__c site : updateServiceAvailResponseMap.get(tempKey)){
                                site.ITPA_Response__c = JSON.serialize(respBean);
                                site.ITPA_Request_Time__c = system.now();
                                site.ITPA_Failure_Fault_Code__c = SpecialCharacterBuyflowConstant.CONCAT;
                                site.ITPA_Processing_Complete__c = true;
                                site.Phone_Number_Updated__c  = false;
                                if(item.Response.Code != null){
                                    site.ITPA_Response_Code__c = item.Response.Code;
                                } 
                                if(item.Response.Description != null){
                                    site.ITPA_Response_Description__c = item.Response.Description;
                                }
                                
                                if(item.FieldedAddress.singleLineStandardizedAddress != null){
                                    site.ITPA_Validated_Address__c = item.FieldedAddress.singleLineStandardizedAddress;
                                }                             
                                
                                if(item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.numberAvailabilityIndicator != null){
                                    site.Number_Availability_Indicator__c = item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.numberAvailabilityIndicator;
                                }
                                else{
                                    site.Number_Availability_Indicator__c = SpecialCharacterBuyflowConstant.FALSE_LITERAL;
                                }
                                
                                if(item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.numberPortabilityIndicator != null){
                                    site.Number_Portability_Indicator__c = item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.numberPortabilityIndicator;
                                }
                                else{
                                    site.Number_Portability_Indicator__c = SpecialCharacterBuyflowConstant.FALSE_LITERAL;
                                }
                                
                                if(item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.virtualTNAvailabilityIndicator != null){
                                    site.VirtualTN_Availability_Indicator__c = item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.virtualTNAvailabilityIndicator;
                                }
                                else{
                                    site.VirtualTN_Availability_Indicator__c = SpecialCharacterBuyflowConstant.FALSE_LITERAL;
                                }
                                
                                if(item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.rateCenter != null){
                                    site.Rate_Center__c = item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.rateCenter;
                                }                                
                                
                                if(item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.voipLocalAvailabilityFlag != null){
                                    site.VOIP_Local_Availability_Indicator__c = item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.voipLocalAvailabilityFlag;
                                    voipLocalAvailabilityFlag = item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.voipLocalAvailabilityFlag;
                                }
                                
                                if(item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.voipAvailabilityFlag != null){
                                    site.VOIP_Availability_Flag__c = item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.voipAvailabilityFlag;
                                    voipAvailabilityFlag = item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.voipAvailabilityFlag;
                                }
                                
                                if(item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.ipldAvailabilityIndicator != null){
                                    site.IpId_Availability_Indicator__c = item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.ipldAvailabilityIndicator;
                                    ipIDAvailabilityIndicator = item.ProductVoiceOverIP.VoiceOverIPServiceAvailability.ipldAvailabilityIndicator;
                                }
                                
                                if(voipAvailabilityFlag != null && ((voipAvailabilityFlag == NewStartConstant.Y) || (voipAvailabilityFlag == NewStartConstant.Y1))){
                                    if(voipLocalAvailabilityFlag != null && ipIDAvailabilityIndicator != null && ((voipLocalAvailabilityFlag == NewStartConstant.Y || voipLocalAvailabilityFlag == NewStartConstant.Y1) && (ipIDAvailabilityIndicator == SpecialCharacterBuyflowConstant.TRUE_LITERAL ))){
                                        PlansQualify = NewStartConstant.PLANA_PLAN_B_PLAN_C;
                                    }
                                    else if((voipLocalAvailabilityFlag != null && ipIDAvailabilityIndicator != null) && ((voipLocalAvailabilityFlag == NewStartConstant.N || voipLocalAvailabilityFlag == NewStartConstant.N2) && (ipIDAvailabilityIndicator == SpecialCharacterBuyflowConstant.TRUE_LITERAL ))){
                                        PlansQualify = NewStartConstant.PLANA;
                                    }
                                    else{
                                        PlansQualify=SpecialCharacterBuyflowConstant.CONCAT;
                                    }
                                }
                                else{
                                    PlansQualify=SpecialCharacterBuyflowConstant.CONCAT;
                                }
                                site.IPFlex_Plans_Qualified__c = PlansQualify;
                                if(voipAvailabilityFlag != null && ipIDAvailabilityIndicator != null && ((voipAvailabilityFlag == NewStartConstant.Y) || (voipAvailabilityFlag == NewStartConstant.Y1)) && (ipIDAvailabilityIndicator == SpecialCharacterBuyflowConstant.TRUE_LITERAL)){
                                    site.IPFLEX_Availability_Flag__c= SpecialCharacterBuyflowConstant.TRUE_LITERAL;
                                }
                                else{
                                    site.IPFLEX_Availability_Flag__c = SpecialCharacterBuyflowConstant.FALSE_LITERAL;
                                }                                
                            }
                         }       
                      }
                      else{
                          String tempKey = item.siteid;
                          if (updateServiceAvailResponseMap.containsKey(tempKey)){
                              ITPAServiceAvailResponseBean respBean = new ITPAServiceAvailResponseBean();
                              for (CustomerSite__c site : updateServiceAvailResponseMap.get(tempKey)){
                                  if(item.Response.Code != null){
                                      site.ITPA_Failure_Fault_Code__c = item.Response.Code;
                                      site.ITPA_Response_Code__c = item.Response.Code;
                                      site.ITPA_Request_Time__c = system.now();
                                      site.VOIP_Local_Availability_Indicator__c = NewStartConstant.N2;
                                      site.VOIP_Availability_Flag__c = NewStartConstant.N2;
                                      site.IpId_Availability_Indicator__c = SpecialCharacterBuyflowConstant.FALSE_LITERAL;
                                      site.IPFLEX_Availability_Flag__c = SpecialCharacterBuyflowConstant.FALSE_LITERAL;
                                      site.ITPA_Validated_Address__c = SpecialCharacterBuyflowConstant.CONCAT;
                                      site.Number_Availability_Indicator__c = SpecialCharacterBuyflowConstant.FALSE_LITERAL;
                                      site.Number_Portability_Indicator__c = SpecialCharacterBuyflowConstant.FALSE_LITERAL;
                                      site.VirtualTN_Availability_Indicator__c = SpecialCharacterBuyflowConstant.FALSE_LITERAL;
                                      site.Rate_Center__c = SpecialCharacterBuyflowConstant.CONCAT;                                      
                                      site.IPFlex_Plans_Qualified__c = SpecialCharacterBuyflowConstant.CONCAT;
                                      site.ITPA_Processing_Complete__c = true;
                                      site.Phone_Number_Updated__c  = false;
                                  }
                                  if(item.Response.Description != null){
                                      site.ITPA_Response_Description__c = item.Response.Description;
                                  }                                  
                                  if(respBean != null){
                                      site.ITPA_Response__c = JSON.serialize(respBean);
                                  }
                              }
                          }
                      }
                 }    
                
                List<AT_T_Customer_Site_Quote__c> UpdateSiteQuoteList = new List<AT_T_Customer_Site_Quote__c>();
                
                // Update Customer site records to store Service Availability JSON response.
                if (!updateServiceAvailResponseMap.isEmpty() && updateServiceAvailResponseMap!=NULL && updateServiceAvailResponseMap.size()>0){
                    List<CustomerSite__c> updateServAvailSitesList = new List<CustomerSite__c>();
                               
                    List<CustomerSite__c> tempBeforeList = new List<CustomerSite__c>();
                    for (String key : updateServiceAvailResponseMap.keyset()){
                        tempBeforeList.addAll(updateServiceAvailResponseMap.get(key));
                    }
                               
                    Map<Id,List<CustomerSite__c>> temp = new Map<Id,List<CustomerSite__c>>();
                    for (CustomerSite__c item : tempBeforeList){
                        if (!temp.containsKey(item.id)){
                            temp.put(item.id,new List<CustomerSite__c>{item});
                        }else{
                            temp.get(item.id).add(item);
                        }
                    }                    
                    
                    List<CustomerSite__c> tempAfterList = new List<CustomerSite__c>();
                    for (String key : temp.keyset()){
                        tempAfterList.add(temp.get(key).get(0));
                    }
                    
                    updateServAvailSitesList.addAll(tempAfterList);
                    update updateServAvailSitesList;
                    
                    if (tempBeforeList!=NULL && tempBeforeList.size()>0 && quoteId!=null){
                        return true;
                    } else {
                        return false;
                    }
                }                                
            }   
            }catch(Exception e){
                 ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                
            }    
          return false;
     }   
}