/************************************************************************************** 
 Apex Class Name     : ATTServiceAvailabilityUtil
 Version             : 1.0 
 Created Date        : 15 October 2014
 Function            : Util class on Service Availability (real time and asynchronous) used in SiteAddressInformationController.
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Arpan Kumar Patra         10/15/2014              Original Version
*************************************************************************************/
    public with sharing class ATTServiceAvailabilityUtil{
    
    /* 
    Name: doServiceAvailCheck
    Description: 
    */  
    public static Boolean doServiceAvailCheck(List<CustomerSite__c>validSitesToConfigureList,AddrValidServAvailResponseBean VASAresponse,String quoteId){    
        
        // Service Availability Check for selected and valid customer sites 
        Map <Integer, List<CustomerSite__c>> serviceAvailMap  = new Map<Integer,List<CustomerSite__c>>();
        Integer keyIndex = 0;
        boolean serviceAvailFlag = false;
        boolean isEmailSelected = false;
        Map<Id, CustomerSite__c> custSiteIdCustSiteObjMap = new Map<Id, CustomerSite__c>();
        for (CustomerSite__c item : [Select Id, VASACallFlag__c, VASA_Response_Status__c , Raw_VASA_Response_Status__c, Service_Availability_Response__c, VASA_Request_Time__c, Duplicate_Check__c From CustomerSite__c Where Id In: validSitesToConfigureList]) {
            item.VASA_Response_Status__c = null; 
            custSiteIdCustSiteObjMap.put(item.Id, item);            
        }
        
        // Logic updated for User Story : US614050 and US614048
        // Query to check if the asyn process to be carried out or not if User opts to be notified later once processing complete
        if(quoteid != null){
            list<Apttus_Proposal__Proposal__c> quoteList = [select id,Send_Email_on_Service_Complete__c from Apttus_Proposal__Proposal__c where id =:quoteid ];
            isEmailSelected = quoteList[0].Send_Email_on_Service_Complete__c;    
        }
        
        Integer max_sites = Integer.valueOf(Max_sites_allowed_VASA__c.getValues(BuyflowConstant.VASAMAX_SITES_ALLOWED) != null ? Max_sites_allowed_VASA__c.getValues(BuyflowConstant.VASAMAX_SITES_ALLOWED).value__c: 0);
        Set<Id> validSiteSet = new Set<Id>();
       for (CustomerSite__c item : validSitesToConfigureList) {
        if (validSitesToConfigureList.size() <= Max_sites ) {
                
                validSiteSet.add(item.Id);
            } 
            if (validSitesToConfigureList.size() <= Max_sites && custSiteIdCustSiteObjMap.get(item.Id) != null && custSiteIdCustSiteObjMap.get(item.Id).Service_Availability_Response__c == NULL 
            ||(custSiteIdCustSiteObjMap.get(item.Id).Service_Availability_Response__c != NULL && custSiteIdCustSiteObjMap.get(item.Id).VASA_Request_Time__c != NULL 
            &&((custSiteIdCustSiteObjMap.get(item.Id).VASA_Request_Time__c.date().daysBetween(system.now().date())) >30 || custSiteIdCustSiteObjMap.get(item.Id).VASACallFlag__c == true || isEmailSelected || custSiteIdCustSiteObjMap.get(item.Id).Raw_VASA_Response_Status__c == 'POSSIBLE MATCHES')
            )){
                if(custSiteIdCustSiteObjMap.get(item.Id).VASA_Request_Time__c != null){
               }
                serviceAvailFlag = true;
                if(!serviceAvailMap.containsKey(keyIndex)) {                  
                    serviceAvailMap.put(keyIndex,new List<CustomerSite__c>{item});
                } else {
                    if (serviceAvailMap.get(keyIndex).size() == 3) {
                        keyIndex ++;
                        serviceAvailMap.put(keyIndex,new List<CustomerSite__c>{item}); 
                    } else {
                        serviceAvailMap.get(keyIndex).add(item);
                    }    
                }
            } else if(validSitesToConfigureList.size()>Max_sites) {
                serviceAvailFlag = true;
                if(!serviceAvailMap.containsKey(keyIndex)) {                  
                    serviceAvailMap.put(keyIndex,new List<CustomerSite__c>{item});
                }else{
                    if (serviceAvailMap.get(keyIndex).size()==3){
                        keyIndex ++;
                        serviceAvailMap.put(keyIndex,new List<CustomerSite__c>{item}); 
                    }else{
                        serviceAvailMap.get(keyIndex).add(item);
                    }    
                }
            }
            else{
            
            }
        }    
        //In case there is no Customer Site which require to get the SA request i.e. the VASA request time is less that 30 days then return true by default
        if(!serviceAvailFlag) {
            return true;
        }
        
        // Create list of AddrValidServAvailInformationBean class instance (request bean)  
        List<AddrValidServAvailInformationBean> beanList = new List<AddrValidServAvailInformationBean>();    
        
        // Create Map(ServiceAvailKey, Customer Site) to update Service Availabilty JSON response after receiving successful response.
        Map<String, List<CustomerSite__c>> updateServiceAvailResponseMap = new Map<String,List<CustomerSite__c>>();  
        
        // Create AddrValidServAvailService class instance (service class)
        AddrValidServAvailService serviceObj = new AddrValidServAvailService();        
        serviceObj.VariableCallType = BuyflowConstant.SINGLE; 
        
        // Create ValidateAddressServiceAvailabilityRequest class instance (inner class of request bean)
        AddrValidServAvailInformationBean.ValidateAddressServiceAvailabilityRequest ValidateAddressServiceAvailabilityRequestObj = new AddrValidServAvailInformationBean.ValidateAddressServiceAvailabilityRequest();
                
        // Create List of AddressDetails class (List of inner class of request bean)
        List <AddrValidServAvailInformationBean.AddressDetails> AddressDetailsList = new List <AddrValidServAvailInformationBean.AddressDetails>();
        
        // Create handler class instance. 
        AddrValidServAvailIntegrationHandler handler = new AddrValidServAvailIntegrationHandler();
        handler.VarCallType = BuyflowConstant.SINGLE;  
                
        // Create AddrValidServAvailInformationBean class instance (request bean)  
        AddrValidServAvailInformationBean bean = new AddrValidServAvailInformationBean();           
        
        // Call doServiceAvailCheck method for service availablity 
        if (serviceAvailMap!=NULL && serviceAvailMap.size()>0){  
            
            // Populate ValidateAddressServiceAvailabilityRequest class instance. 
            ValidateAddressServiceAvailabilityRequestObj.mode = BuyflowConstant.B;
            ValidateAddressServiceAvailabilityRequestObj.sfdcQuoteId = (quoteId!=null)?quoteId:SpecialcharacterConstant.CONCAT;
            ValidateAddressServiceAvailabilityRequestObj.displayAllSpeeds = true;
            ValidateAddressServiceAvailabilityRequestObj.nearMatchIndicator = true;  
                         
            for (Integer key: serviceAvailMap.keyset()) {
                                           
                // Create List of Speed class (List of inner class of request bean)
                List <AddrValidServAvailInformationBean.Speed> speedList_Ethernet = new List < AddrValidServAvailInformationBean.Speed > ();
                
                // Create List of Speed class (List of inner class of request bean)
                List <AddrValidServAvailInformationBean.Speed> speedList_PrivateLine = new List < AddrValidServAvailInformationBean.Speed > ();          
                
                // Populate bean classes variable and inner class variable with page data.              
                // Populate Address class instance
                for(CustomerSite__c item : serviceAvailMap.get(key)) {     
                    if(!updateServiceAvailResponseMap.containsKey(item.Service_Avail_Key__c)) {
                        updateServiceAvailResponseMap.put(item.id,new List<CustomerSite__c>{item});
                    }else {
                        updateServiceAvailResponseMap.get(item.id).add(item);
                    }
                    SpeedList_Ethernet = new List <AddrValidServAvailInformationBean.Speed>();
                    SpeedList_PrivateLine = new List <AddrValidServAvailInformationBean.Speed>();                     
                    
                    // Create AddressDetails class instance (inner class of request bean) 
                    AddrValidServAvailInformationBean.AddressDetails addressDetailsObj_Ethernet = new AddrValidServAvailInformationBean.AddressDetails();
                    AddrValidServAvailInformationBean.AddressDetails addressDetailsObj_PrivateLine = new AddrValidServAvailInformationBean.AddressDetails();
                    
                    // Create Speed class instance (inner class of request bean)
                    AddrValidServAvailInformationBean.Speed speedObj_Ethernet = new AddrValidServAvailInformationBean.Speed();
                    AddrValidServAvailInformationBean.Speed speedObj_PrivateLine = new AddrValidServAvailInformationBean.Speed();
                    
                    // Create Zip class instance (inner class of request bean) 
                    AddrValidServAvailInformationBean.Zip zipObj = new AddrValidServAvailInformationBean.Zip();   
                    
                    // Create Address class instance (inner class of request bean)
                    AddrValidServAvailInformationBean.Address addressObj = new AddrValidServAvailInformationBean.Address();
                    
                    // Create ServiceAvailability class instance (inner class of request bean) 
                    AddrValidServAvailInformationBean.ServiceAvailability serviceAvailabilityObj_Ethernet = new AddrValidServAvailInformationBean.ServiceAvailability();                
                    AddrValidServAvailInformationBean.ServiceAvailability serviceAvailabilityObj_PrivateLine = new AddrValidServAvailInformationBean.ServiceAvailability();
                    
                    AddressObj.street = item.Address_Line__c;
                    AddressObj.city = item.City__c;
                    AddressObj.state = item.State__c;
                    AddressObj.country = item.country__c;   
                    AddressObj.urbanization = item.Urbanization__c;    
                    
                    // Populate Zip class instance  
                    ZipObj.zipCodeExtension = item.Zip_Code_Extension__c;
                    ZipObj.zipCode = String.valueof(item.Zip_Code__c);
                    ZipObj.zipCodeExtension = item.Zip_Code_Extension__c;    
                    
                    AddressObj.Zip = ZipObj;            
                    
                    // Populate Speed class instance (for Ethernet) 
                    SpeedObj_Ethernet.speedPhysicalValue = BuyflowConstant.SIVARConst_1000;
                    SpeedObj_Ethernet.speedUnit = item.Speed_Unit__c;
                    SpeedObj_Ethernet.speedName = item.Speed_Name__c;
                    SpeedList_Ethernet.add(SpeedObj_Ethernet); 
                    
                    // Populate ServiceAvailability class instance (for Ethernet)       
                    ServiceAvailabilityObj_Ethernet.quantity = item.Quantity__c;
                    ServiceAvailabilityObj_Ethernet.Speed = SpeedList_Ethernet;   
                    
                    // Adding Ethernet transport type to address details list        
                    ServiceAvailabilityObj_Ethernet.transportType = BuyflowConstant.ETHERNET; 
                    
                    // Populate AddressDetails class instance (for Ethernet)
                    AddressDetailsObj_Ethernet.Address = AddressObj;
                    
                    AddressDetailsObj_Ethernet.ServiceAvailability = ServiceAvailabilityObj_Ethernet;                
                    AddressDetailsObj_Ethernet.sfdcId = item.Id;   
                    AddressDetailsList.add(AddressDetailsObj_Ethernet);                 
                                        
                    // Populate Speed class instance (for Private Line) 
                    SpeedObj_PrivateLine.speedPhysicalValue = BuyflowConstant.T1;
                    SpeedObj_PrivateLine.speedUnit = item.Speed_Unit__c;
                    SpeedObj_PrivateLine.speedName = item.Speed_Name__c;
                    SpeedList_PrivateLine.add(SpeedObj_PrivateLine);           
                    
                   
                    // Populate ServiceAvailability class instance (for Private Line)          
                    ServiceAvailabilityObj_PrivateLine.quantity = item.Quantity__c;
                    ServiceAvailabilityObj_PrivateLine.Speed = SpeedList_PrivateLine;      
                    
                    // Populate AddressDetails class instance.
                    AddressDetailsObj_PrivateLine.Address = AddressObj;
                    
                    // Adding Private Line transport type to address details list        
                    ServiceAvailabilityObj_PrivateLine.transportType = BuyflowConstant.PRIVATELINE; 
                    
                    AddressDetailsObj_PrivateLine.ServiceAvailability = ServiceAvailabilityObj_PrivateLine;   
                    
                    AddressDetailsObj_PrivateLine.sfdcId = item.Id;  
                    AddressDetailsList.add(AddressDetailsObj_PrivateLine);  
                     
                }
                
            }
             ValidateAddressServiceAvailabilityRequestObj.AddressDetails = AddressDetailsList;             
                
             // Populate AddrValidServAvailInformationBean (request bean) class instance            
             bean.ValidateAddressServiceAvailabilityRequest = ValidateAddressServiceAvailabilityRequestObj; 
        }   
        
           try{     
            // Get VASA response from handleAddressValidationServiceAvailabilityRequest method by passing request bean and end customer Id.
            // VASA response is AddrValidServAvailResponseBean class instance (response bean)
             AddrValidServAvailIntegrationHandler.VASAResponseBeanAsync resBeanAsync = new AddrValidServAvailIntegrationHandler.VASAResponseBeanAsync();                
             //Logic updated for User Story :US614050 and US614048 by Haemen
             //Added emailSelected flag to decide Sync or Async call to inform the user
             if (bean!=null  && validSitesToConfigureList.size()<=Max_sites && serviceAvailFlag && isEmailSelected == false){
                VASAresponse = (AddrValidServAvailResponseBean)serviceObj.handleAddressValidationServiceAvailabilityRequest(bean, null);
             }else if((bean!=null  && validSitesToConfigureList.size()>Max_sites && serviceAvailFlag) || isEmailSelected){
                  resBeanAsync = (AddrValidServAvailIntegrationHandler.VASAResponseBeanAsync)serviceObj.handleAddressValidationServiceAvailabilityRequest(bean, null);
                  if(resBeanAsync!=null && !string.isBlank(resBeanAsync.message) && resBeanAsync.message.equalsIgnoreCase(BuyflowConstant.SUBMITTED)) {       
                      return true;
                  }
             }            
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        
        // Create List of AddressServiceAvailability class (inner class of AddrValidServAvailResponseBean or response bean)
        List <AddrValidServAvailResponseBean.AddressServiceAvailability> respBeanAddressServiceAvailabilityList = new List <AddrValidServAvailResponseBean.AddressServiceAvailability> ();
        
        try{
            // Assign response bean AddressServiceAvailabilityList to  list instance created.
            if (VASAresponse != NULL && VASAresponse.AddressServiceAvailability != NULL && validSitesToConfigureList!=NULL) {
                respBeanAddressServiceAvailabilityList.addAll(VASAresponse.AddressServiceAvailability);
                
                Map<String,List<AddrValidServAvailResponseBean.AddressServiceAvailability>> jsonMap = new Map<String,List<AddrValidServAvailResponseBean.AddressServiceAvailability>>();
                  SiteVasaResValidator vasaRespValidate=new SiteVasaResValidator();
                // Iterate through AddressServiceAvailability list returned from response bean.                
                for (AddrValidServAvailResponseBean.AddressServiceAvailability item: respBeanAddressServiceAvailabilityList) {
                    String tempKey = item.sfdcId;
                  if (updateServiceAvailResponseMap.containsKey(tempKey)){
                        AddrValidServAvailResponseBean respBean = new AddrValidServAvailResponseBean();
                        if (jsonMap.containsKey(tempKey)){
                            jsonMap.get(tempKey).add(item);
                        }else{
                            jsonMap.put(tempKey,new List<AddrValidServAvailResponseBean.AddressServiceAvailability>{item});
                        }
                        respBean.AddressServiceAvailability = new List<AddrValidServAvailResponseBean.AddressServiceAvailability>();                            
                        respBean.AddressServiceAvailability.addAll(jsonMap.get(tempKey)); 
                        respBean.AddressServiceAvailability[0].AddressMatchDetails = null;
                        respBean.AddressServiceAvailability[0].RequestedAddressDetails = null;                           
                        respBean.Response = VASAresponse.Response;
                        for (CustomerSite__c site : updateServiceAvailResponseMap.get(tempKey)){
                            site.VASACallFlag__c = false;
                            site.VASA_Request_Time__c = system.now();                           
                            site.Service_Availability_Response__c = vasaRespValidate.flipVasaResponse(respBean); //JSON.serialize(respBean);
                            site.Raw_Vasa__c = vasaRespValidate.flipVasaResponse(respBean);
                            system.debug('@@@site.Service_Availability_Response__c'+site.Service_Availability_Response__c);
                            system.debug('@@@site.Raw_Vasa__c'+site.Raw_Vasa__c);
                            if(item.statusCode ==null){
                                if(item.addressMatchCode == BuyflowConstant.SIVARConst_1 ){
                                    site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                    site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                if( item.AddressMatchDetails != null){
                                site.State__c = item.AddressMatchDetails[0].state;
                                site.Address_Line__c = item.AddressMatchDetails[0].street;
                                site.City__c = item.AddressMatchDetails[0].city;
                                site.Zip_Code__c = item.AddressMatchDetails[0].Zip.zipCode;
                                    }  
                                }
                                else if(item.addressMatchCode == BuyflowConstant.SIVARConst_2 ){
                                    site.VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                    site.Raw_VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                }
                                else if(item.addressMatchCode == BuyflowConstant.SIVARConst_3){
                                    site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                    site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSNO_MATCH;
                                }
                                else {
                                        if(site.VASA_Response_Status__c != BuyflowConstant.ADDRESSEXACT_MATCH && site.VASA_Response_Status__c != BuyflowConstant.POSSIBLEMATCHES && site.VASA_Response_Status__c != BuyflowConstant.ADDRESSNO_MATCH){
                                            site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                            site.Raw_VASA_Response_Status__c = BuyflowConstant.SERVICEUNAVAILABLE;
                                        }
                                }
                            }
                            if(item.statusCode!=null){
                                if(Integer.valueOf(item.statusCode)>=1 && Integer.valueOf(item.statusCode)<=3) {
                                    if(item.addressMatchCode == BuyflowConstant.SIVARConst_1 ){
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                      if( item.AddressMatchDetails != null){
                                        site.State__c = item.AddressMatchDetails[0].state;
                                        site.Address_Line__c = item.AddressMatchDetails[0].street;
                                        site.City__c = item.AddressMatchDetails[0].city;
                                        site.Zip_Code__c = item.AddressMatchDetails[0].Zip.zipCode;
                                        }  
                                    }
                                    else if(item.addressMatchCode == BuyflowConstant.SIVARConst_2 ){
                                        site.VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                    }
                                    else if(item.addressMatchCode == BuyflowConstant.SIVARConst_3){
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSNO_MATCH;
                                    }
                                    else{
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.SERVICEUNAVAILABLE;
                                    }
                                } else if(Integer.valueOf(item.statusCode) == 0){
                                    if(item.addressMatchCode == BuyflowConstant.SIVARConst_1 ){
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        if( item.AddressMatchDetails != null){
                                        site.State__c = item.AddressMatchDetails[0].state;
                                        site.Address_Line__c = item.AddressMatchDetails[0].street;
                                        site.City__c = item.AddressMatchDetails[0].city;
                                        site.Zip_Code__c = item.AddressMatchDetails[0].Zip.zipCode;
                                        }  
                                    }
                                    else if(item.addressMatchCode == BuyflowConstant.SIVARConst_2 ){
                                        site.VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                    }
                                    else if(item.addressMatchCode == BuyflowConstant.SIVARConst_3){
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSNO_MATCH;
                                    }
                                    else{
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.SERVICEUNAVAILABLE;
                                    }
                                }
                                else{
                                    if(site.VASA_Response_Status__c != BuyflowConstant.ADDRESSEXACT_MATCH && site.VASA_Response_Status__c != BuyflowConstant.POSSIBLEMATCHES && site.VASA_Response_Status__c != BuyflowConstant.ADDRESSNO_MATCH){
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.SERVICEUNAVAILABLE;
                                    }
                                }
                            }
                        }
                        
                        
                    }       
                    
                 }    
                 
                
                List<AT_T_Customer_Site_Quote__c> updateSiteQuoteList = new List<AT_T_Customer_Site_Quote__c>();
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
                        Integer x = 0;
                        for(CustomerSite__c siteObj :tempBeforeList) {
                            AT_T_Customer_Site_Quote__c siteQuoteObj = new AT_T_Customer_Site_Quote__c();
                            siteQuoteObj.AT_T_Customer_Site__c = siteObj.id;
                          siteQuoteObj.AT_T_Quote__c = quoteid;  
                            siteQuoteObj.Type__c = BuyflowConstant.NONMACD;                          
                            UpdateSiteQuoteList.add(siteQuoteObj);
                          
                        }
                        List<AT_T_Customer_Site_Quote__c> siteQuoteList = [select id,AT_T_Customer_Site__c,AT_T_Customer_Site__r.Duplicate_Check__c 
                                                                                    From AT_T_Customer_Site_Quote__c 
                                                                                    where AT_T_Quote__r.id=:quoteId
                                                                                    And AT_T_Customer_Site__c In: validSiteSet]; 
                       
                        delete SiteQuoteList;
                        if(UpdateSiteQuoteList!=null && UpdateSiteQuoteList.size()>0){
                        insert UpdateSiteQuoteList;
                         update UpdateSiteQuoteList;
                         }
                         
                        Boolean responseBool = doValidateBlankResponse(quoteId);
                        return responseBool;
                       return true;
                    } else {
                        return false;
                    }
                }                                
            }   
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return false;
        }    
        return false;
    }   
    
/* 
 Name: doValidateBlankResponse
 Description: 
 */ 
    public Static Boolean doValidateBlankResponse(String quoteId){
    try{
        Boolean respBool = true;
        List<AT_T_Customer_Site_Quote__c> siteQuoteList = new List<AT_T_Customer_Site_Quote__c>();
        SiteQuoteList = [select id,AT_T_Customer_Site__c,AT_T_Customer_Site__r.Service_Availability_Response__c From AT_T_Customer_Site_Quote__c where AT_T_Quote__r.id=:quoteId]; 
        Integer countJnc = SiteQuoteList.size(); 
        List<AT_T_Customer_Site_Quote__c> listQtSiteJncToDelete = new List<AT_T_Customer_Site_Quote__c>();
        for( AT_T_Customer_Site_Quote__c siteQtJnc : SiteQuoteList ){
        
            if( siteQtJnc.AT_T_Customer_Site__r.Service_Availability_Response__c == null || siteQtJnc.AT_T_Customer_Site__r.Service_Availability_Response__c == SpecialcharacterConstant.CONCAT ){
                listQtSiteJncToDelete.add(siteQtJnc);
            }
        }
        Integer cntDeletedItems = listQtSiteJncToDelete.size();
        delete listQtSiteJncToDelete;

        if( cntDeletedItems == countJnc ){ 
        
            respBool = false;
        }else{
        
            respBool = true;
        }
        return respBool;
       }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
            }
    }
    
    /*Name:doServiceAvailCheckNewStart
      Descripition:
    */   
    public static Boolean doServiceAvailCheckNewStart(List<CustomerSite__c>validSitesToConfigureList,AddrValidServAvailResponseBean VASAresponse,String quoteId){    
        
        // Service Availability Check for selected and valid customer sites 
        map <Integer, List<CustomerSite__c>> serviceAvailMap  = new Map<Integer,List<CustomerSite__c>>();
        integer keyIndex = 0;
        integer MaxdiffAllowed = 30;
        boolean serviceAvailFlag = false;
        boolean flagCSIInvalidResponse = true;
        boolean isEmailSelected = false;
        map<Id, CustomerSite__c> custSiteIdCustSiteObjMap = new Map<Id, CustomerSite__c>();
        List<CustomerSite__c> sitesOverThrityList = new List<CustomerSite__c>();
        integer max_sites = Integer.valueOf(Max_sites_allowed_VASA__c.getValues(BuyflowConstant.VASAMAX_SITES_ALLOWED) != null ? Max_sites_allowed_VASA__c.getValues(BuyflowConstant.VASAMAX_SITES_ALLOWED).value__c: 0);
        set<Id> validSiteSet = new set<Id>();
        
        for(CustomerSite__c item : [Select Id, VASACallFlag__c, VASA_Response_Status__c , Service_Availability_Response__c, VASA_Request_Time__c From CustomerSite__c Where Id In: validSitesToConfigureList]) {
            item.VASA_Response_Status__c = null; 
            custSiteIdCustSiteObjMap.put(item.Id, item);            
        }
        
        // Logic updated for User Story : US614050 and US614048
        // Query to check if the asyn process to be carried out or not if User opts to be notified later once processing complete
        list<Apttus_Proposal__Proposal__c> quoteList;
        if(quoteid != null){
             quoteList = [select id,Send_Email_on_Service_Complete__c from Apttus_Proposal__Proposal__c where id =:quoteid ];
            isEmailSelected = quoteList[0].Send_Email_on_Service_Complete__c;    
        }     
        
        for(CustomerSite__c custSuteObj :validSitesToConfigureList){
            if((custSuteObj.VASA_Request_Time__c != NULL && (custSuteObj.VASA_Request_Time__c.Date().daysBetween(system.now().date())) > MaxdiffAllowed) || custSuteObj.VASA_Request_Time__c == NULL){
                sitesOverThrityList.add(custSuteObj);
            }
        }
        
      
        boolean flag=false;
       
        for(CustomerSite__c item : validSitesToConfigureList) {
            if( ( !sitesOverThrityList.isEmpty() && sitesOverThrityList.size() <= Max_sites )
                    && custSiteIdCustSiteObjMap.get(item.Id) != null 
                    && custSiteIdCustSiteObjMap.get(item.Id).Service_Availability_Response__c == NULL  || (custSiteIdCustSiteObjMap.get(item.Id).Service_Availability_Response__c != null && custSiteIdCustSiteObjMap.get(item.Id).Service_Availability_Response__c.contains('AddressServiceAvailability&quot;:[]'))
                    || ( custSiteIdCustSiteObjMap.get(item.Id).Service_Availability_Response__c != NULL && custSiteIdCustSiteObjMap.get(item.Id).VASA_Request_Time__c != NULL && ((custSiteIdCustSiteObjMap.get(item.Id).VASA_Request_Time__c.date().daysBetween(system.now().date())) > 30 || isEmailSelected)
                    ) 
            )
            {   
                boolean qualifiedsite = false ; 
                
                if(custSiteIdCustSiteObjMap.get(item.Id).VASA_Request_Time__c == null ){
                    qualifiedsite = true;
                    flag=true;
                }
                if(custSiteIdCustSiteObjMap.get(item.Id).VASA_Request_Time__c != null && (custSiteIdCustSiteObjMap.get(item.Id).VASA_Request_Time__c.date().daysBetween(system.now().date())) >30){
                    qualifiedsite = true;
                    flag=true;
                }
                
                serviceAvailFlag = true;
                
                if(qualifiedsite){
                    if(!serviceAvailMap.containsKey(keyIndex)){                  
                        serviceAvailMap.put(keyIndex,new List<CustomerSite__c>{item});
                    }else{
                        if(serviceAvailMap.get(keyIndex).size() == 3) {
                            keyIndex ++;
                            serviceAvailMap.put(keyIndex,new List<CustomerSite__c>{item}); 
                        } else {
                            serviceAvailMap.get(keyIndex).add(item);
                        }    
                    }
                }
            } else if ((!sitesOverThrityList.isEmpty() && sitesOverThrityList.size() <= Max_sites )
                        && custSiteIdCustSiteObjMap.get(item.Id) != null  && custSiteIdCustSiteObjMap.get(item.Id).Service_Availability_Response__c != NULL 
                        && custSiteIdCustSiteObjMap.get(item.Id).VASA_Request_Time__c != NULL 
                        && (custSiteIdCustSiteObjMap.get(item.Id).VASA_Request_Time__c.date().daysBetween(system.now().date())) <= 30 ){
                validSiteSet.add(item.Id);
            } 
            else if( !sitesOverThrityList.isEmpty() && sitesOverThrityList.size() > Max_sites) {
                serviceAvailFlag = true;
                if(!serviceAvailMap.containsKey(keyIndex)){                  
                    serviceAvailMap.put(keyIndex,new List<CustomerSite__c>{item});
                }else{
                    if (serviceAvailMap.get(keyIndex).size()==3){
                        keyIndex ++;
                        serviceAvailMap.put(keyIndex,new List<CustomerSite__c>{item}); 
                    }else{
                        serviceAvailMap.get(keyIndex).add(item);
                    }    
                }
            }
            else{
            
            }
        }    
                if(!flag && isEmailSelected)
                {
                                  ID batchProcessId =  database.executeBatch(new FLOWITPABatchProcess(quoteId),1); 
                                   return true; 
        }    
            //In case there is no Customer Site which require to get the SA request i.e. the VASA request time is less that 30 days then return true by default
            if(!serviceAvailFlag) {
                return true;
            }
        

        // Create list of AddrValidServAvailInformationBean class instance (request bean)  
        List<AddrValidServAvailInformationBean> beanList = new List<AddrValidServAvailInformationBean>();    
        
        // Create Map(ServiceAvailKey, Customer Site) to update Service Availabilty JSON response after receiving successful response.
        Map<String, List<CustomerSite__c>> updateServiceAvailResponseMap = new Map<String,List<CustomerSite__c>>();          
        
        AddrValidServAvailService serviceObj = new AddrValidServAvailService();// Create AddrValidServAvailService class instance (service class)    
        serviceObj.VariableCallType = BuyflowConstant.SINGLE; 
        
        // Create ValidateAddressServiceAvailabilityRequest class instance (inner class of request bean)
        AddrValidServAvailInformationBean.ValidateAddressServiceAvailabilityRequest ValidateAddressServiceAvailabilityRequestObj = new AddrValidServAvailInformationBean.ValidateAddressServiceAvailabilityRequest();
        
        List <AddrValidServAvailInformationBean.AddressDetails> AddressDetailsList = new List <AddrValidServAvailInformationBean.AddressDetails>(); // Create List of AddressDetails class (List of inner class of request bean)
        
        AddrValidServAvailIntegrationHandler handler = new AddrValidServAvailIntegrationHandler(); // Create handler class instance. 
        handler.VarCallType = BuyflowConstant.SINGLE;          

        AddrValidServAvailInformationBean bean = new AddrValidServAvailInformationBean(); // Create AddrValidServAvailInformationBean class instance (request bean)         
 
        // Create List of AddressServiceAvailability class (inner class of AddrValidServAvailResponseBean or response bean)
        List <AddrValidServAvailResponseBean.AddressServiceAvailability> respBeanAddressServiceAvailabilityList = new List <AddrValidServAvailResponseBean.AddressServiceAvailability> ();
 
        // Call doServiceAvailCheck method for service availablity 
        if (serviceAvailMap!=NULL && serviceAvailMap.size()>0){  
            
            // Populate ValidateAddressServiceAvailabilityRequest class instance. 
            ValidateAddressServiceAvailabilityRequestObj.mode = BuyflowConstant.B;
            ValidateAddressServiceAvailabilityRequestObj.sfdcQuoteId = (quoteId!=null)?quoteId:SpecialcharacterConstant.CONCAT;
            ValidateAddressServiceAvailabilityRequestObj.displayAllSpeeds = true;
            ValidateAddressServiceAvailabilityRequestObj.nearMatchIndicator = true;  
                         
            for (Integer key: serviceAvailMap.keyset()) {
                // Create List of Speed class (List of inner class of request bean)
                List <AddrValidServAvailInformationBean.Speed> speedList_Ethernet = new List < AddrValidServAvailInformationBean.Speed > ();
                
                // Create List of Speed class (List of inner class of request bean)
                List <AddrValidServAvailInformationBean.Speed> speedList_PrivateLine = new List < AddrValidServAvailInformationBean.Speed > ();          
                
                // Populate bean classes variable and inner class variable with page data.              
                // Populate Address class instance
                for(CustomerSite__c item : serviceAvailMap.get(key)) {     
                    if(!updateServiceAvailResponseMap.containsKey(item.Service_Avail_Key__c)) {
                        updateServiceAvailResponseMap.put(item.id,new List<CustomerSite__c>{item});
                    }else {
                        updateServiceAvailResponseMap.get(item.id).add(item);
                    }
                    SpeedList_Ethernet = new List <AddrValidServAvailInformationBean.Speed>();
                    SpeedList_PrivateLine = new List <AddrValidServAvailInformationBean.Speed>();                     
                    
                    // Create AddressDetails class instance (inner class of request bean) 
                    AddrValidServAvailInformationBean.AddressDetails addressDetailsObj_Ethernet = new AddrValidServAvailInformationBean.AddressDetails();
                    AddrValidServAvailInformationBean.AddressDetails addressDetailsObj_PrivateLine = new AddrValidServAvailInformationBean.AddressDetails();
                    
                    // Create Speed class instance (inner class of request bean)
                    AddrValidServAvailInformationBean.Speed speedObj_Ethernet = new AddrValidServAvailInformationBean.Speed();
                    AddrValidServAvailInformationBean.Speed speedObj_PrivateLine = new AddrValidServAvailInformationBean.Speed();
                    
                    // Create Zip class instance (inner class of request bean) 
                    AddrValidServAvailInformationBean.Zip zipObj = new AddrValidServAvailInformationBean.Zip();   
                    
                    // Create Address class instance (inner class of request bean)
                    AddrValidServAvailInformationBean.Address addressObj = new AddrValidServAvailInformationBean.Address();
                    
                    // Create ServiceAvailability class instance (inner class of request bean) 
                    AddrValidServAvailInformationBean.ServiceAvailability serviceAvailabilityObj_Ethernet = new AddrValidServAvailInformationBean.ServiceAvailability();                
                    AddrValidServAvailInformationBean.ServiceAvailability serviceAvailabilityObj_PrivateLine = new AddrValidServAvailInformationBean.ServiceAvailability();
                    
                    AddressObj.street = item.Address_Line__c;
                    AddressObj.city = item.City__c;
                    AddressObj.state = item.State__c;
                    AddressObj.country = item.country__c;   
                    AddressObj.urbanization = item.Urbanization__c;    
                    
                    // Populate Zip class instance  
                    ZipObj.zipCodeExtension = item.Zip_Code_Extension__c;
                    ZipObj.zipCode = String.valueof(item.Zip_Code__c);
                    ZipObj.zipCodeExtension = item.Zip_Code_Extension__c;    
                    
                    AddressObj.Zip = ZipObj;            
                    
                    // Populate Speed class instance (for Ethernet) 
                    SpeedObj_Ethernet.speedPhysicalValue = BuyflowConstant.SIVARConst_1000;
                    SpeedObj_Ethernet.speedUnit = item.Speed_Unit__c;
                    SpeedObj_Ethernet.speedName = item.Speed_Name__c;
                    SpeedList_Ethernet.add(SpeedObj_Ethernet); 
                    
                    // Populate ServiceAvailability class instance (for Ethernet)       
                    ServiceAvailabilityObj_Ethernet.quantity = item.Quantity__c;
                    ServiceAvailabilityObj_Ethernet.Speed = SpeedList_Ethernet;   
                    
                    // Adding Ethernet transport type to address details list        
                    ServiceAvailabilityObj_Ethernet.transportType = BuyflowConstant.ETHERNET; 
                    
                    // Populate AddressDetails class instance (for Ethernet)
                    AddressDetailsObj_Ethernet.Address = AddressObj;
                    
                    AddressDetailsObj_Ethernet.ServiceAvailability = ServiceAvailabilityObj_Ethernet;                
                    AddressDetailsObj_Ethernet.sfdcId = item.Id;   
                    AddressDetailsList.add(AddressDetailsObj_Ethernet);                 
                    
                    // Populate Speed class instance (for Private Line) 
                    SpeedObj_PrivateLine.speedPhysicalValue = BuyflowConstant.T1;
                    SpeedObj_PrivateLine.speedUnit = item.Speed_Unit__c;
                    SpeedObj_PrivateLine.speedName = item.Speed_Name__c;
                    SpeedList_PrivateLine.add(SpeedObj_PrivateLine);                           
                    
                    // Populate ServiceAvailability class instance (for Private Line)          
                    ServiceAvailabilityObj_PrivateLine.quantity = item.Quantity__c;
                    ServiceAvailabilityObj_PrivateLine.Speed = SpeedList_PrivateLine;      
                    
                    // Populate AddressDetails class instance.
                    AddressDetailsObj_PrivateLine.Address = AddressObj;
                    
                    // Adding Private Line transport type to address details list        
                    ServiceAvailabilityObj_PrivateLine.transportType = BuyflowConstant.PRIVATELINE; 
                    
                    AddressDetailsObj_PrivateLine.ServiceAvailability = ServiceAvailabilityObj_PrivateLine;   
                    AddressDetailsObj_PrivateLine.sfdcId = item.Id;  
                    AddressDetailsList.add(AddressDetailsObj_PrivateLine);              
                }
            }
            ValidateAddressServiceAvailabilityRequestObj.AddressDetails = AddressDetailsList;             
                
            // Populate AddrValidServAvailInformationBean (request bean) class instance            
            bean.ValidateAddressServiceAvailabilityRequest = ValidateAddressServiceAvailabilityRequestObj; 
        }   
        
           try{   
            // Get VASA response from handleAddressValidationServiceAvailabilityRequest method by passing request bean and end customer Id.
            // VASA response is AddrValidServAvailResponseBean class instance (response bean)
             AddrValidServAvailIntegrationHandler.VASAResponseBeanAsync resBeanAsync = new AddrValidServAvailIntegrationHandler.VASAResponseBeanAsync();                
             //Logic updated for User Story :US614050 and US614048 by Haemen
             //Added emailSelected flag to decide Sync or Async call to inform the user
             if (bean!=null  && (!sitesOverThrityList.isEmpty() && sitesOverThrityList.size() <= Max_sites) && serviceAvailFlag && isEmailSelected == false){
                                  
                VASAresponse = (AddrValidServAvailResponseBean)serviceObj.handleAddressValidationServiceAvailabilityRequest(bean, null);
             }else if((bean!=null  && (!sitesOverThrityList.isEmpty() && sitesOverThrityList.size() > Max_sites ) && serviceAvailFlag) || isEmailSelected){
                    
                  resBeanAsync = (AddrValidServAvailIntegrationHandler.VASAResponseBeanAsync)serviceObj.handleAddressValidationServiceAvailabilityRequest(bean, null);
                  if(resBeanAsync!=null && !string.isBlank(resBeanAsync.message) && resBeanAsync.message.equalsIgnoreCase(BuyflowConstant.SUBMITTED)) {       
                                  
                      return true;
                  }
             }            
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        
        // Create List of AddressServiceAvailability class (inner class of AddrValidServAvailResponseBean or response bean)
       // List <AddrValidServAvailResponseBean.AddressServiceAvailability> respBeanAddressServiceAvailabilityList = new List <AddrValidServAvailResponseBean.AddressServiceAvailability> ();
        
        try{                     
            // Assign response bean AddressServiceAvailabilityList to  list instance created.
            if (VASAresponse != NULL && VASAresponse.AddressServiceAvailability != NULL && validSitesToConfigureList!=NULL) {
                respBeanAddressServiceAvailabilityList.addAll(VASAresponse.AddressServiceAvailability);
                
                Map<String,List<AddrValidServAvailResponseBean.AddressServiceAvailability>> jsonMap = new Map<String,List<AddrValidServAvailResponseBean.AddressServiceAvailability>>();
                  SiteVasaResValidator vasaRespValidate=new SiteVasaResValidator();
                // Iterate through AddressServiceAvailability list returned from response bean.                
                for (AddrValidServAvailResponseBean.AddressServiceAvailability item: respBeanAddressServiceAvailabilityList) {

                    String tempKey = item.sfdcId;

                    if (updateServiceAvailResponseMap.containsKey(tempKey)){
                        AddrValidServAvailResponseBean respBean = new AddrValidServAvailResponseBean();
                        if (jsonMap.containsKey(tempKey)){
                            jsonMap.get(tempKey).add(item);
                        }else{
                            jsonMap.put(tempKey,new List<AddrValidServAvailResponseBean.AddressServiceAvailability>{item});
                        }
                        respBean.AddressServiceAvailability = new List<AddrValidServAvailResponseBean.AddressServiceAvailability>();                            
                        respBean.AddressServiceAvailability.addAll(jsonMap.get(tempKey)); 
                        respBean.AddressServiceAvailability[0].AddressMatchDetails = null;
                        respBean.AddressServiceAvailability[0].RequestedAddressDetails = null;                           
                        respBean.Response = VASAresponse.Response;
                        for (CustomerSite__c site : updateServiceAvailResponseMap.get(tempKey)){
                            site.VASACallFlag__c = false;
                            site.VASA_Request_Time__c = system.now();                             
                          
                            site.Service_Availability_Response__c = vasaRespValidate.flipVasaResponse(respBean);
                            site.Raw_Vasa__c = vasaRespValidate.flipVasaResponse(respBean);

                            if(Global_Variable__c.getValues('VASA_Irregular_Response')  != null){
                                site.Raw_Vasa__c = site.Service_Availability_Response__c = Global_Variable__c.getInstance('VASA_Irregular_Response').Value__c;
                            }
                            if(item.statusCode ==null){
                                if(item.addressMatchCode == BuyflowConstant.SIVARConst_1 ){
                                    site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                    site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                if( item.AddressMatchDetails != null){
                                site.State__c = item.AddressMatchDetails[0].state;
                                site.Address_Line__c = item.AddressMatchDetails[0].street;
                                site.City__c = item.AddressMatchDetails[0].city;
                                site.Zip_Code__c = item.AddressMatchDetails[0].Zip.zipCode;
                                    }  
                                }
                                else if(item.addressMatchCode == BuyflowConstant.SIVARConst_2 ){
                                    site.VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                    site.Raw_VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                }
                                else if(item.addressMatchCode == BuyflowConstant.SIVARConst_3){
                                    site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                    site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSNO_MATCH;
                                }
                                else{
                                    if(site.VASA_Response_Status__c != BuyflowConstant.ADDRESSEXACT_MATCH && site.VASA_Response_Status__c != BuyflowConstant.POSSIBLEMATCHES && site.VASA_Response_Status__c != BuyflowConstant.ADDRESSNO_MATCH){
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.SERVICEUNAVAILABLE;
                                    }
                                }
                            }
                            if(item.statusCode!=null){
                                if(Integer.valueOf(item.statusCode)> =1 && Integer.valueOf(item.statusCode)<=3) {
                                    if(item.addressMatchCode == BuyflowConstant.SIVARConst_1 ){
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                      if( item.AddressMatchDetails != null){
                                        site.State__c = item.AddressMatchDetails[0].state;
                                        site.Address_Line__c = item.AddressMatchDetails[0].street;
                                        site.City__c = item.AddressMatchDetails[0].city;
                                        site.Zip_Code__c = item.AddressMatchDetails[0].Zip.zipCode;
                                        }  
                                    }
                                    else if(item.addressMatchCode == BuyflowConstant.SIVARConst_2 ){
                                        site.VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                    }
                                    else if(item.addressMatchCode == BuyflowConstant.SIVARConst_3){
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSNO_MATCH;
                                    }
                                    else{
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.SERVICEUNAVAILABLE;
                                    }
                                } else if(Integer.valueOf(item.statusCode) == 0){
                                    if(item.addressMatchCode == BuyflowConstant.SIVARConst_1 ){
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        if( item.AddressMatchDetails != null){
                                        site.State__c = item.AddressMatchDetails[0].state;
                                        site.Address_Line__c = item.AddressMatchDetails[0].street;
                                        site.City__c = item.AddressMatchDetails[0].city;
                                        site.Zip_Code__c = item.AddressMatchDetails[0].Zip.zipCode;
                                        }  
                                    }
                                    else if(item.addressMatchCode == BuyflowConstant.SIVARConst_2 ){
                                        site.VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                    }
                                    else if(item.addressMatchCode == BuyflowConstant.SIVARConst_3){
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSNO_MATCH;
                                    }
                                    else{
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.SERVICEUNAVAILABLE;
                                    }
                                }
                                else{
                                    if(site.VASA_Response_Status__c != BuyflowConstant.ADDRESSEXACT_MATCH && site.VASA_Response_Status__c != BuyflowConstant.POSSIBLEMATCHES && site.VASA_Response_Status__c != BuyflowConstant.ADDRESSNO_MATCH){
                                        site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                        site.Raw_VASA_Response_Status__c = BuyflowConstant.SERVICEUNAVAILABLE;
                                    }
                                }
                            }
                           string strippedString = site.Service_Availability_Response__c.remove('"');
                           // DEFECT FIX - 221158
                            if(strippedString.contains(BuyflowConstant.ADDSERAVAILBRACK)){
                                site.VASA_Response_Status__c = BuyflowConstant.ADDRESS_RECORD_CREATED ;
                                site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESS_RECORD_CREATED ;
                                site.VASA_Request_Time__c = null;
                                
                                flagCSIInvalidResponse = false;
                            }
                        }                        
                    }       
                    
                 }    
                 
                
                List<AT_T_Customer_Site_Quote__c> updateSiteQuoteList = new List<AT_T_Customer_Site_Quote__c>();
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
                    /** We are consuming 3 SOQL with an expectation that by max of three attempts, we shall have all unique keys. **/

                    if (tempBeforeList!=NULL && tempBeforeList.size()>0 && quoteId!=null){
                        Integer x = 0;

                        for(CustomerSite__c siteObj :tempBeforeList) {
                            AT_T_Customer_Site_Quote__c siteQuoteObj = new AT_T_Customer_Site_Quote__c();
                            siteQuoteObj.AT_T_Customer_Site__c = siteObj.id;
                            siteQuoteObj.AT_T_Quote__c = quoteid;  
                            siteQuoteObj.Type__c = BuyflowConstant.NONMACD;                          
                            UpdateSiteQuoteList.add(siteQuoteObj);

                        }
                        List<AT_T_Customer_Site_Quote__c> siteQuoteList = [select id,AT_T_Customer_Site__c,AT_T_Customer_Site__r.Duplicate_Check__c 
                                                                                    From AT_T_Customer_Site_Quote__c 
                                                                                    where AT_T_Quote__r.id=:quoteId
                                                                                    And AT_T_Customer_Site__c Not In: validSiteSet]; 
                        if(!SiteQuoteList.isEmpty()){
                           
                        }
                        delete SiteQuoteList;
                        insert UpdateSiteQuoteList;
                        update UpdateSiteQuoteList;
                        Boolean responseBool = doValidateBlankResponse(quoteId);
                        if(!flagCSIInvalidResponse){
                            responseBool = flagCSIInvalidResponse;
                        }
                        return responseBool;
                     
                    } else {
                        return false;
                    }
                }                                
            }   
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }   
        return false;
    }
}