/************************************************************************************** 
Apex Class Name     : IGLOOIntegrationHandler 
Version             : 1.0 
Created Date        : 1 Feb 2017
Function            : Integration Handler for AVPN/MIS IGLOO Call
***************************************************************************************/ 
public class IGLOOIntegrationHandler{
     
    /*IGLOO Integration Business Logic*/ 
    public HttpResponse getIglooResponse(Apttus_Config2__ProductAttributeValue__c attributeValue,Boolean isIglooSpeedBump,list<Apttus_Proposal__Proposal__c> quoteList){
        try{           
            list<String> preferredVendorList = new list<String>();
            list<String> avoidVendorList = new list<String>();
            
            CustomerSite__c custSite = [SELECT Id, Address_Line__c, City__c, State__c, Zip_Code__c, Zip_Code_Extension__c, Country__c, Alternate_Access_ITPA_Response__c, Alternate_Access_territoryIndicator__c, Alternate_Access_locator__c, Alternate_Access_npaNxx__c, 
                          Alternate_Access_code__c, Alternate_Access_status__c, Alternate_Access_level__c, Alternate_Access_score__c, Alternate_Access_latitude__c, Alternate_Access_longitude__c, Alternate_Access_meetPointVCoordinate__c,
                          Alternate_Access_meetPointHCoordinate__c, Alternate_Access_servingWireCenter__c, Alternate_Access_vendorName__c, Service_Availability_Response__c FROM CustomerSite__c WHERE Id =: Id.valueOf(attributeValue.AT_T_Customer_Site__c)];
                 
            IglooResponseBean responseBean = new IglooResponseBean();
            IglooRequestBean requestBean = new IglooRequestBean();
            IglooRequestBean.InquireEnterprisePriceQuoteDetailsRequest reqInquireEnterpriseObj = new IglooRequestBean.InquireEnterprisePriceQuoteDetailsRequest();
            IglooRequestBean.DomesticPricePromoQuote domesticPricePromoQuoteObj = new IglooRequestBean.DomesticPricePromoQuote(); 
            IglooRequestBean.DomesticAndOther domesticAndOtherObj = new IglooRequestBean.DomesticAndOther();
            IglooRequestBean.PromotionDetails promotionDetailsObj = new IglooRequestBean.PromotionDetails(); 
            IglooRequestBean.RequestedAddress requestedAddressObj = new IglooRequestBean.RequestedAddress(); 
            IglooRequestBean.MatchDetails matchDetailsObj = new IglooRequestBean.MatchDetails(); 
            IglooRequestBean.StandardAddress standardAddressObj = new IglooRequestBean.StandardAddress();
            IglooRequestBean.CustomerGeoLocation customerGeoLocationObj = new IglooRequestBean.CustomerGeoLocation(); 
            IglooRequestBean.ILECDetails iLECDetailsObj = new IglooRequestBean.ILECDetails();             
            
            long randomNumber = (long) Math.floor(Math.random() * 9000000000L) + 1000000000L;
            requestedAddressObj.city = custSite.City__c != null ? custSite.City__c : SpecialCharacterConstant.CONCAT; 
            requestedAddressObj.state = custSite.State__c != null ? custSite.State__c : SpecialCharacterConstant.CONCAT; 
            requestedAddressObj.address = custSite.Address_Line__c != null ? custSite.Address_Line__c : SpecialCharacterConstant.CONCAT; 
            requestedAddressObj.zipCode = custSite.Zip_Code__c != null ? custSite.Zip_Code__c : SpecialCharacterConstant.CONCAT;
            requestedAddressObj.zipCodeExtension = custSite.Zip_Code_Extension__c != null ? custSite.Zip_Code_Extension__c : Constant.SIVARConst_0000;
            
            matchDetailsObj.code = custSite.Alternate_Access_code__c != null ? custSite.Alternate_Access_code__c : SpecialCharacterConstant.CONCAT;
            matchDetailsObj.status = custSite.Alternate_Access_status__c != null ? custSite.Alternate_Access_status__c : SpecialCharacterConstant.CONCAT;
            matchDetailsObj.level = custSite.Alternate_Access_level__c != null ? custSite.Alternate_Access_level__c : SpecialCharacterConstant.CONCAT;
            matchDetailsObj.score = custSite.Alternate_Access_score__c != null ? custSite.Alternate_Access_score__c : SpecialCharacterConstant.CONCAT;
            
            standardAddressObj.address = (requestedAddressObj.address + SpecialCharacterConstant.COMMA + requestedAddressObj.city + SpecialCharacterConstant.COMMA + requestedAddressObj.state + SpecialCharacterConstant.COMMA + requestedAddressObj.zipCode + SpecialCharacterConstant.HYPHEN + requestedAddressObj.zipCodeExtension).toUpperCase(); 
            standardAddressObj.city = requestedAddressObj.city;
            standardAddressObj.state = requestedAddressObj.state;
            standardAddressObj.streetAddress = requestedAddressObj.address;
            standardAddressObj.zipCode = requestedAddressObj.zipCode;
            standardAddressObj.zipCodeExtension = requestedAddressObj.zipCodeExtension;
            
            customerGeoLocationObj.latitude = custSite.Alternate_Access_latitude__c != null ? custSite.Alternate_Access_latitude__c : SpecialCharacterConstant.CONCAT;
            customerGeoLocationObj.longitude = custSite.Alternate_Access_longitude__c != null ? custSite.Alternate_Access_longitude__c : SpecialCharacterConstant.CONCAT;
            customerGeoLocationObj.horizontalCoordinate = custSite.Alternate_Access_meetPointHCoordinate__c != null ? custSite.Alternate_Access_meetPointHCoordinate__c : SpecialCharacterConstant.CONCAT;
            customerGeoLocationObj.verticalCoordinate = custSite.Alternate_Access_meetPointVCoordinate__c != null ? custSite.Alternate_Access_meetPointVCoordinate__c : SpecialCharacterConstant.CONCAT;  
            
            ILECDetailsObj.vendorName = custSite.Alternate_Access_vendorName__c != null ? custSite.Alternate_Access_vendorName__c : SpecialCharacterConstant.CONCAT;
            ILECDetailsObj.servingWireCenter = custSite.Alternate_Access_servingWireCenter__c != null ? custSite.Alternate_Access_servingWireCenter__c : SpecialCharacterConstant.CONCAT;
            
            system.debug('@@@attributeValue'+attributeValue);
            preferredVendorList = getPreferredVendorName(custSite.Service_Availability_Response__c,quoteList,attributeValue);
            
            promotionDetailsObj.lata = String.valueOf(getLATAValueFromSAResponse(custSite.Service_Availability_Response__c));
            promotionDetailsObj.territoryIndicator = custSite.Alternate_Access_territoryIndicator__c == Constant.Y ? true : false;
            promotionDetailsObj.geoTransactionId = datetime.now().getTime() + String.valueOf(randomNumber);
            promotionDetailsObj.locator = custSite.Alternate_Access_locator__c != null ? custSite.Alternate_Access_locator__c : SpecialCharacterConstant.CONCAT;
            promotionDetailsObj.npaNxx = custSite.Alternate_Access_npaNxx__c != null ? custSite.Alternate_Access_npaNxx__c : SpecialCharacterConstant.CONCAT;
            promotionDetailsObj.responseTime = promotionDetailsObj.acceptAddressTime = promotionDetailsObj.requestTime = system.today();
            promotionDetailsObj.RequestedAddress = requestedAddressObj;
            promotionDetailsObj.MatchDetails = matchDetailsObj;
            promotionDetailsObj.StandardAddress = standardAddressObj;
            promotionDetailsObj.CustomerGeoLocation = customerGeoLocationObj;
            promotionDetailsObj.ILECDetails = ILECDetailsObj;            
            promotionDetailsObj.preferredVendors = preferredVendorList;
            promotionDetailsObj.avoidVendors = avoidVendorList;
            
            domesticAndOtherObj.quoteRequestType = Constant.AUTOQUOTE;
            domesticAndOtherObj.service = (attributeValue.ProductName__c == Constant.AVPN) ? Constant.AVPNETH : (attributeValue.ProductName__c == Constant.AMIS) ? Constant.MIS : SpecialCharacterConstant.CONCAT; 
            domesticAndOtherObj.accessTransport = Constant.ETHERNET;
            domesticAndOtherObj.requestedAccessBandwidth = attributeValue.ProductName__c == Constant.AVPN ? String.valueOf(Integer.valueOf(attributeValue.Access_Speed_AVPN__c.split(SpecialCharacterConstant.BLANK).get(0)) * 1000) : (attributeValue.ProductName__c == Constant.AMIS) ? String.valueOf(Integer.valueOf(attributeValue.Access_Speed_MIS__c.split(SpecialCharacterConstant.BLANK).get(0)) * 1000) : SpecialCharacterConstant.CONCAT; 
            domesticAndOtherObj.misPNT = Constant.NA;
            domesticAndOtherObj.accessArrangement = Constant.TOTAL_SERVICE;
            if(attributeValue.ProductName__c == Constant.AVPN){
                domesticAndOtherObj.physicalInterface = attributeValue.Interface_Type_AVPN__c == Constant.ELECTRICAL_100_BASE_TX ? Constant.SIVARConst_1003 : attributeValue.Interface_Type_AVPN__c == Constant.OPTICALSINGLE_MODE_1000_BASE_LX ? Constant.SIVARConst_1010 : attributeValue.Interface_Type_AVPN__c == Constant.OPTICALMULTI_MODE_1000_BASE_SX ? Constant.SIVARConst_1009 : SpecialCharacterConstant.CONCAT;
            }else if(attributeValue.ProductName__c == Constant.AMIS){
                domesticAndOtherObj.physicalInterface = attributeValue.Interface_Type__c == Constant.ELECTRICAL_100_BASE_TX ? Constant.SIVARConst_1003 : attributeValue.Interface_Type__c == Constant.OPTICALSINGLE_MODE_1000_BASE_LX ? Constant.SIVARConst_1010 : attributeValue.Interface_Type__c == Constant.OPTICALMULTI_MODE_1000_BASE_SX ? Constant.SIVARConst_1009 : SpecialCharacterConstant.CONCAT;
            }
            domesticAndOtherObj.contractTerm = String.valueOf(Integer.valueOf(attributeValue.Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Payment_Term__c.split(SpecialCharacterConstant.BLANK).get(0)) * 12);
            domesticAndOtherObj.tailTechnology =  Constant.ESPETH_DEDICATED ;
            domesticAndOtherObj.accessInterconnect = (attributeValue.ProductName__c == Constant.AVPN) ? Constant.GATEWAYINTERCONNECT : (attributeValue.ProductName__c == Constant.AMIS) ? Constant.DIRECTCONNECT : SpecialCharacterConstant.CONCAT; 
            domesticAndOtherObj.accessArchitecture = Constant.SWITCHED;
            domesticAndOtherObj.circuitQuantity = Constant.NA1;
            domesticAndOtherObj.discountPercentage = 0;
            domesticAndOtherObj.PromotionDetails = promotionDetailsObj;
            domesticAndOtherObj.speedBumpIndicator = isIglooSpeedBump;
                                
            domesticPricePromoQuoteObj.DomesticAndOther = domesticAndOtherObj;
            reqInquireEnterpriseObj.DomesticPricePromoQuote = domesticPricePromoQuoteObj;              
            requestBean.InquireEnterprisePriceQuoteDetailsRequest = reqInquireEnterpriseObj;
            HttpResponse response = initiateIGLOOCall(requestBean);
            return response;
        }
        catch(Exception e){
           ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
           return null;
        }
        return null;
    }
    
    /*Method to initiate the IGLOO call*/
    public HttpResponse initiateIGLOOCall(IglooRequestBean requestBean){
        IglooResponseBean responseBean = new IglooResponseBean();
        try{ 
            String body = JSON.serialize(requestBean);
            String endPointURL = Global_Variable__c.getValues('FlowIGLOOEndPoint')!=null ? Global_Variable__c.getValues('FlowIGLOOEndPoint').Value__c : ''; 
            String accessToken = Global_Variable__c.getValues('BlackFlagAccessToken').Value__c;
            String authorizationHeader = Constant.BEARER + accessToken;               
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();        
                        
            Long startTime = datetime.now().getTime();
            Http connection = new Http();              
            request.setMethod('POST');
            request.setEndpoint(endPointURL);
            request.setHeader('X-CSI-TimeToLive', '120000');
            request.setHeader('Content-Length', '30');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authorizationHeader);
            request.setTimeOut(120000);        
            request.setBody(body);  
            
            system.debug('@@@IGLOO Request: '+request.getBody());
            response = connection.send(request);
            system.debug('@@@IGLOO Response: '+response.getBody());
            Long endTime = datetime.now().getTime();
            Long totalTime = endTime - startTime; 
            system.debug('@@@IGLOO Time Taken: '+totalTime +'ms'); 
            return response;            
         }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }
    
    /*Method to get the LATA value from Service Availability Response*/ 
    public Integer getLATAValueFromSAResponse(String serviceAvailabilityResponse){
        AddrValidServAvailResponseBean responseBean = new AddrValidServAvailResponseBean();
        Integer lataValue = 000;
        
        if(serviceAvailabilityResponse != null && serviceAvailabilityResponse != SpecialCharacterConstant.CONCAT){
            serviceAvailabilityResponse = serviceAvailabilityResponse.replaceAll(Constant.QUOT_x,SpecialCharacterConstant.DOUBLE_QOUTE);            
            responseBean = (AddrValidServAvailResponseBean)JSON.deserialize(serviceAvailabilityResponse, AddrValidServAvailResponseBean.class);        
            if(responseBean != null && responseBean.AddressServiceAvailability != null){
                for(integer i=0 ; i<responseBean.AddressServiceAvailability.size() ; i++){                                        
                    if(responseBean.AddressServiceAvailability[i].ServiceAvailabilityDetails != null && responseBean.AddressServiceAvailability[i].ServiceAvailabilityDetails.Ethernet != null){                             
                        if(responseBean.AddressServiceAvailability[i].ServiceAvailabilityDetails.Ethernet.lata != null){
                            lataValue = responseBean.AddressServiceAvailability[i].ServiceAvailabilityDetails.Ethernet.lata;
                        }               
                    }
                }   
            }
        }
        return lataValue;
    }
    
    /*Method to get the preferred Vendor Name from Service Availability Response*/ 
    public List<String> getPreferredVendorName(String serviceAvailabilityResponse, list<Apttus_Proposal__Proposal__c> quoteList, Apttus_Config2__ProductAttributeValue__c attributeValue){
        List<String> preferredVendorNameList = new List<String>();
        AddrValidServAvailResponseBean responseBean = new AddrValidServAvailResponseBean();
        String preferredVendorName = '';
        String lecNameValue = '';
        system.debug('@@sfdc quoteList[0].Renewal_Contract__c '+quoteList[0].Renewal_Contract__c);
        system.debug('@@@attributeValue: '+attributeValue);
        
        if(quoteList[0].Renewal_Contract__c){
            if(attributeValue.Alternate_Access_IGLOO_Access_Price__c != null && attributeValue.Apttus_Config2__Vendor__c != null && (attributeValue.VASA_Region__c!=null && !attributeValue.VASA_Region__c.equalsIgnoreCase('In Region')) && ((attributeValue.Access_Type_AVPN__c!=null && attributeValue.Access_Type_AVPN__c.equalsIgnoreCase('Switched Ethernet')) || (attributeValue.Access_Type__c!=null && attributeValue.Access_Type__c.equalsIgnoreCase('Switched Ethernet')))){
                lecNameValue = attributeValue.Apttus_Config2__Vendor__c; 
                preferredVendorNameList.add(lecNameValue);
                system.debug('@@@Scenario 1: preferredVendorNameList'+preferredVendorNameList);          
            }
            else if(serviceAvailabilityResponse != null && serviceAvailabilityResponse != SpecialCharacterConstant.CONCAT){
                serviceAvailabilityResponse = serviceAvailabilityResponse.replaceAll(Constant.QUOT_x,SpecialCharacterConstant.DOUBLE_QOUTE);            
                responseBean = (AddrValidServAvailResponseBean)JSON.deserialize(serviceAvailabilityResponse, AddrValidServAvailResponseBean.class);        
                if(responseBean != null && responseBean.AddressServiceAvailability != null){
                    for(integer i=0 ; i<responseBean.AddressServiceAvailability.size() ; i++){ 
                        if(responseBean.AddressServiceAvailability[i].ServiceAvailabilityDetails != null && responseBean.AddressServiceAvailability[i].ServiceAvailabilityDetails.Ethernet != null){
                            if(responseBean.AddressServiceAvailability[i].lecName != null){
                                lecNameValue = responseBean.AddressServiceAvailability[i].lecName;
                                if(responseBean.AddressServiceAvailability[i].AddressMatchDetails != null){
                                     if((lecNameValue.equalsIgnoreCase('Frontier') || lecNameValue.equalsIgnoreCase('FRONTIER COMMUNICATIONS')) && responseBean.AddressServiceAvailability[i].AddressMatchDetails[0].State == 'CT'){
                                         lecNameValue = lecNameValue +'-CT';
                                     } 
                                }   
                            } 
                        }  
                    }
                }
                if(lecNameValue != null && lecNameValue != ''){
                    preferredVendorName = String.valueOf(LecName_IglooProvider_Mapping__c.getvalues(lecNameValue).IglooProvider__c);
                    preferredVendorNameList.add(preferredVendorName);
                    system.debug('@@@Scenario 2: preferredVendorNameList'+preferredVendorNameList); 
                }
            }            
        }
        return preferredVendorNameList;
    }
    
    /*Method to make webservice callout to Igloo and get response*/
    public void executeIglooLogic(String quoteId, String siteId, Apttus_Config2__ProductAttributeValue__c listAttrVal){ 
        Boolean iglooStubbingActivated = false;
        Boolean isIgloospeedBump;
        Admin_Control__c adminControl = [select id,IglooSpeedBump__c, IGLOO_Response_Stubbing_Activated__c from Admin_Control__c limit 1];
        iglooStubbingActivated = adminControl.IGLOO_Response_Stubbing_Activated__c;        
        
        if(Test.isRunningTest())
        {
            iglooStubbingActivated = true;
        }
        
        list<Apttus_Proposal__Proposal__c> quoteList = new list<Apttus_Proposal__Proposal__c>();
        quoteList = [select id,MACD_Change_Type__c,RetrialFailure__c,Renewal_Contract__c from Apttus_Proposal__Proposal__c where id=: quoteId limit 1];
        if(quoteList[0].Renewal_Contract__c){
            isIgloospeedBump = False;
        }else {
            isIgloospeedBump = adminControl.IglooSpeedBump__c;
        }
        system.debug('@@@isIgloospeedBump'+isIgloospeedBump );        
        list<AT_T_Customer_Site_Quote__c> siteQuoteList = new list<AT_T_Customer_Site_Quote__c>();
        siteQuoteList = [select id, AT_T_Customer_Site__c,Alternate_Access_IGLOO_Request_Time__c,CSI_Conversation_Id__c, Alternate_Access_IGLOO_Response__c, Alternate_Access_IGLOO_Response_Status__c, Alternate_Access_IGLOO_Failure_Code__c, Alternate_Access_IGLOO_Process_Completed__c, Alternate_Access_IGLOO_Access_Speed__c, Alternate_Access_IGLOO_Access_Price__c, Alternate_Access_IGLOO_Interface_Code__c, Alternate_Access_IGLOO_Interface_Type__c, Iglow_Response_Received_Date__c, AT_T_Quote__c, Igloo_Review_Required__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__r.Deal_Reg_Approved__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__r.Stagename from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c =: siteId and AT_T_Quote__c =: quoteId];

        String macdChangeType= quoteList[0].MACD_Change_Type__c;   
        try{
            String iglooResponse = SpecialCharacterConstant.CONCAT;
            Integer iglooAccessSpeed = 0;
            String iglooInterfaceType = SpecialCharacterConstant.CONCAT;
            String iglooInterfaceCode = SpecialCharacterConstant.CONCAT;
            
            Integer currentAccessSpeed = listAttrVal.ProductName__c == Constant.AVPN ? Integer.valueOf(listAttrVal.Access_Speed_AVPN__c.split(SpecialCharacterConstant.BLANK).get(0)) : Integer.valueOf(listAttrVal.Access_Speed_MIS__c.split(SpecialCharacterConstant.BLANK).get(0));
            Integer currentPortSpeed = listAttrVal.ProductName__c == Constant.AVPN ? Integer.valueOf(listAttrVal.Port_Speed_AVPN__c.split(SpecialCharacterConstant.BLANK).get(0)) : Integer.valueOf(listAttrVal.Port_Speed_MIS__c.split(SpecialCharacterConstant.BLANK).get(0));
            String currentInterfaceType = listAttrVal.ProductName__c == Constant.AVPN ? listAttrVal.Interface_Type_AVPN__c : listAttrVal.Interface_Type__c;
                   
                        
            //Make IGLOO Call
            IGLOOIntegrationHandler handler = new IGLOOIntegrationHandler();           
            
            if(iglooStubbingActivated == true){
                if(siteQuoteList[0].Alternate_Access_IGLOO_Response__c != null){
                    siteQuoteList[0].Alternate_Access_IGLOO_Response_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Response__c;
                }    
                siteQuoteList[0].Alternate_Access_IGLOO_Response__c = iglooResponse = WebserviceResponseStub.getFlowIglooResponse();
            }else{
                HttpResponse response = handler.getIglooResponse(listAttrVal,isIgloospeedBump,quoteList);
                if(siteQuoteList[0].Alternate_Access_IGLOO_Response__c != null){
                    siteQuoteList[0].Alternate_Access_IGLOO_Response_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Response__c;
                }
                siteQuoteList[0].Alternate_Access_IGLOO_Response__c = iglooResponse = response.getbody();
                if(response.getHeader('X-CSI-ConversationId')!=null){
                    if(siteQuoteList[0].CSI_Conversation_Id__c != null){
                        siteQuoteList[0].CSI_Conversation_Id_Old__c = siteQuoteList[0].CSI_Conversation_Id__c;
                    }
                    siteQuoteList[0].CSI_Conversation_Id__c=response.getHeader('X-CSI-ConversationId');
                    system.debug('@@@CSI Conversation Id : '+siteQuoteList[0].CSI_Conversation_Id__c);
                }
            }                       
            if(!quoteList[0].Renewal_Contract__c){
                if(iglooResponse != null && iglooResponse != SpecialCharacterConstant.CONCAT){
                    iglooResponse = iglooResponse.replaceAll(Constant.QUOT_x,SpecialCharacterConstant.DOUBLE_QOUTE); 
                    IglooResponseBean responseBean = new IglooResponseBean();                 
                    ResponseBean = (IglooResponseBean)JSON.Deserialize(iglooResponse, IglooResponseBean.class);
                   
                    if(ResponseBean != null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse != null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.Response != null){
                        if(ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.Response.description != null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.Response.description == Constant.SUCCESS && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth != null){
                            if(siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c != null){
                                siteQuoteList[0].Alternate_Access_IGLOO_ResponseStatusOld__c = siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c;
                            }
                            if(siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c != null){
                                siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c;
                            }
                            siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c = Constant.SUCCESS;
                            siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c = SpecialCharacterConstant.CONCAT;
                            listAttrVal.Igloo_Call_Processing_Complete__c = true;
                            listAttrVal.IGLOO_Retrial_Failure_Count__c = 0;
                            listAttrVal.IGLOO_Call_Failure__c = false; 
                            quoteList[0].RetrialFailure__c = 0;
                            system.debug('@@@Inside IGLOO Success Scenario');
                            if(ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails!=null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails.supplierName!=null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails.supplierName!=SpecialCharacterConstant.CONCAT){
                                listAttrVal.Apttus_Config2__Vendor__c = ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails.supplierName.replaceAll(',','');
                                siteQuoteList[0].IGLOO_Supplier_Name__c = ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails.supplierName.replaceAll(',','');
                                System.debug('@@@IGLOO_Supplier_Name__c'+siteQuoteList[0].IGLOO_Supplier_Name__c);
                                listAttrVal.IGLOO_Supplier_Name__c = ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails.supplierName.replaceAll(',','');
                            }
                            
                            if(ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails != null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails.baseMonthlyPriceUSD != null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.accessBandwidth != null){
                                if(ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails.baseMonthlyPriceUSD != null){
                                    if(siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c != null){
                                        siteQuoteList[0].Alternate_Access_IGLOO_Access_Price_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c;
                                    }
                                    siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c = Decimal.valueOf(ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails.baseMonthlyPriceUSD);
                                    Set<String> LNSSupplierSet = new set<String>();
                                    LNSSupplierSet = LNSSupplierNames__c.getAll().keySet();
                                    if(!LNSSupplierSet.isEmpty() && (LNSSupplierSet.contains(listAttrVal.Apttus_Config2__Vendor__c) || listAttrVal.Apttus_Config2__Vendor__c.contains('AT&T'))){
                                        listAttrVal.Alternate_Access_IGLOO_Access_Price__c = null;
                                    }else{
                                        listAttrVal.Alternate_Access_IGLOO_Access_Price__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c;   
                                    }
                                }                            

                                if(ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.accessBandwidth != null){
                                    iglooAccessSpeed = Integer.valueOf(ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.accessBandwidth)/1000;
                                    if(siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c != Null){
                                        siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c;
                                    }
                                    siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c = iglooAccessSpeed + Constant.MBPS1;
                                }
                                
                                system.debug('@@@iglooAccessSpeed: '+iglooAccessSpeed);
                                system.debug('@@@currentAccessSpeed: '+currentAccessSpeed);
                                
                                if(iglooAccessSpeed == 0){
                                    executeIglooUnavailableLogic(siteId, listAttrVal,macdChangeType);
                                    system.debug('@@@inside unavailable 1');
                                    if(siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c != null){
                                        siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c;
                                    }
                                    if(siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c != null){
                                        siteQuoteList[0].Alternate_Access_IGLOO_Access_Price_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c;
                                    }
                                    if(siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c != null){
                                        siteQuoteList[0].Alternate_Access_IGLOO_Interface_CodeOld__c = siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c;
                                    }
                                    siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c = siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c = SpecialCharacterConstant.CONCAT;
                                    siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c = null;
                                }
                                else if(iglooAccessSpeed != currentAccessSpeed){
                                    listAttrVal.IGLOO_Speed_Unavailable__c = false;
                                    //Access Speed Logic
                                    listAttrVal.IGLOO_Old_Access_Speed__c = listAttrVal.ProductName__c == Constant.AVPN ? listAttrVal.Access_Speed_AVPN__c : listAttrVal.Access_Speed_MIS__c;                        
                                    if(listAttrVal.ProductName__c == Constant.AVPN){                            
                                        listAttrVal.Access_Speed_AVPN__c = iglooAccessSpeed + Constant.MBPS1;
                                    }else{
                                        listAttrVal.Access_Speed_MIS__c = iglooAccessSpeed + Constant.MBPS1;
                                    }
                                    listAttrVal.IGLOO_Access_Speed_Substituted__c = true;  
                                    
                                    //Port Speed Logic
                                    if(listAttrVal.ProductName__c == Constant.AVPN){
                                        if(iglooAccessSpeed < currentPortSpeed){
                                            listAttrVal.IGLOO_Old_Port_Speed__c = listAttrVal.Port_Speed_AVPN__c;
                                            listAttrVal.Port_Speed_AVPN__c = iglooAccessSpeed + Constant.MBPS1;
                                            listAttrVal.IGLOO_Port_Speed_Substituted__c = true;                                            
                                        }else{
                                            listAttrVal.IGLOO_Port_Speed_Substituted__c = false;
                                            listAttrVal.IGLOO_Old_Port_Speed__c = SpecialCharacterConstant.CONCAT;
                                        }
                                    }else{
                                        listAttrVal.IGLOO_Old_Port_Speed__c = listAttrVal.Port_Speed_MIS__c;
                                        listAttrVal.Port_Speed_MIS__c = iglooAccessSpeed + Constant.MBPS1;
                                        listAttrVal.IGLOO_Port_Speed_Substituted__c = true;                           
                                    }
                                }
                                else{
                                    listAttrVal.IGLOO_Port_Speed_Substituted__c = listAttrVal.IGLOO_Access_Speed_Substituted__c = false;
                                    listAttrVal.IGLOO_Old_Port_Speed__c = listAttrVal.IGLOO_Old_Access_Speed__c = SpecialCharacterConstant.CONCAT;
                                    listAttrVal.IGLOO_Speed_Unavailable__c = false;
                                }                    
                                    
                                //Interface Type Logic                    
                                if(ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.physicalInterface != null){
                                    if(siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c != null){
                                        siteQuoteList[0].Alternate_Access_IGLOO_Interface_CodeOld__c = siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c;
                                    }
                                    siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c = listAttrVal.Alternate_Access_IGLOO_Interface_Code__c = ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.physicalInterface;
                                    if(listAttrVal.Alternate_Access_IGLOO_Interface_Code__c == Constant.SIVARConst_1003){
                                        iglooInterfaceType = Constant.ELECTRICAL_100_BASE_TX1;
                                    }else if(listAttrVal.Alternate_Access_IGLOO_Interface_Code__c == Constant.SIVARConst_1010){
                                        iglooInterfaceType = Constant.OPTICALSINGLE_MODE_1000_BASE_LX; 
                                    }else if(listAttrVal.Alternate_Access_IGLOO_Interface_Code__c == Constant.SIVARConst_1009){
                                        iglooInterfaceType = Constant.OPTICALMULTI_MODE_1000_BASE_SX;
                                    }
                                    
                                    if(iglooInterfaceType != currentInterfaceType){
                                        listAttrVal.IGLOO_Old_Interface_Type__c = listAttrVal.ProductName__c == Constant.AVPN ? listAttrVal.Interface_Type_AVPN__c : listAttrVal.Interface_Type__c;                        
                                        if(listAttrVal.ProductName__c == Constant.AVPN){ 
                                            listAttrVal.Interface_Type_AVPN__c = iglooInterfaceType;
                                        }else{
                                            listAttrVal.Interface_Type__c = iglooInterfaceType;
                                        }
                                        listAttrVal.IGLOO_Interface_Type_Substituted__c = true;
                                    }else{
                                        listAttrVal.IGLOO_Interface_Type_Substituted__c = false;
                                        listAttrVal.IGLOO_Old_Interface_Type__c = SpecialCharacterConstant.CONCAT;
                                    }                       
                                }
                                else{
                                    listAttrVal.IGLOO_Interface_Type_Substituted__c = false;
                                    listAttrVal.IGLOO_Old_Interface_Type__c = SpecialCharacterConstant.CONCAT;
                                }                 
                            }else{
                                if(siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c != null){
                                    siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c;
                                }
                                if(siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c != null){
                                    siteQuoteList[0].Alternate_Access_IGLOO_Access_Price_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c;
                                }
                                if(siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c != null){
                                    siteQuoteList[0].Alternate_Access_IGLOO_Interface_CodeOld__c = siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c;
                                }
                                siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c = siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c = SpecialCharacterConstant.CONCAT;
                                siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c = null;
                                executeIglooUnavailableLogic(siteId, listAttrVal,macdChangeType);
                                system.debug('@@@inside unavailable 2');
                            }
                        }
                        else{
                            if(siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c != null){
                                siteQuoteList[0].Alternate_Access_IGLOO_ResponseStatusOld__c = siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c;
                            }
                            if(siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c != null){
                                siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c;
                            }
                            if(siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c != null){
                                siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c;
                            }
                            if(siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c != null){
                                siteQuoteList[0].Alternate_Access_IGLOO_Access_Price_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c;
                            }
                            if(siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c != null){
                                siteQuoteList[0].Alternate_Access_IGLOO_Interface_CodeOld__c = siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c;
                            }
                            siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c = Constant.FAILURE;
                            siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c = Constant.SIVARConst_0044;
                            siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c = siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c = SpecialCharacterConstant.CONCAT;
                            siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c = null;
                            executeIglooFailureLogic(siteId, listAttrVal);
                        }
                    }
                    else{
                        if(siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c != null){
                            siteQuoteList[0].Alternate_Access_IGLOO_ResponseStatusOld__c = siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c;
                        }
                        if(siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c != null){
                            siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c;
                        }
                        if(siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c != null){
                            siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c;
                        }
                        if(siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c != null){
                            siteQuoteList[0].Alternate_Access_IGLOO_Access_Price_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c;
                        }
                        if(siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c != null){
                            siteQuoteList[0].Alternate_Access_IGLOO_Interface_CodeOld__c = siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c;
                        }
                        siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c = Constant.FAILURE;
                        siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c = Constant.SIVARConst_0044;
                        siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c = siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c = SpecialCharacterConstant.CONCAT;
                        siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c = null;
                        executeIglooFailureLogic(siteId, listAttrVal);                        
                    }
                }
                if(siteQuoteList[0].Alternate_Access_IGLOO_Request_Time__c != null){
                    siteQuoteList[0].Alternate_Access_IGLOO_Request_Time_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Request_Time__c;
                }
                if(siteQuoteList[0].Iglow_Response_Received_Date__c != null){
                    siteQuoteList[0].Igloo_Response_Received_Date_Old__c = siteQuoteList[0].Iglow_Response_Received_Date__c;
                }
                if(siteQuoteList[0].Alternate_Access_IGLOO_Process_Completed__c != null){
                    siteQuoteList[0].Alternate_Access_IGLOO_ProcessCmpltd_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Process_Completed__c;
                }          
                siteQuoteList[0].Alternate_Access_IGLOO_Process_Completed__c = true;
                siteQuoteList[0].Alternate_Access_IGLOO_Request_Time__c = system.now();
                siteQuoteList[0].Iglow_Response_Received_Date__c=system.today();  
                
                if(listAttrVal.IGLOO_Access_Speed_Substituted__c == true || listAttrVal.IGLOO_Interface_Type_Substituted__c == true || listAttrVal.IGLOO_Interface_Type_Substituted__c){
                    siteQuoteList[0].Igloo_Review_Required__c = true;
                }else{
                    siteQuoteList[0].Igloo_Review_Required__c = false;
                }        
            }else if(quoteList[0].Renewal_Contract__c){
            
                system.debug('@@sfdc inside Renewal Contract block '+iglooResponse);
                if(iglooResponse != null && iglooResponse != SpecialCharacterConstant.CONCAT){
                    iglooResponse = iglooResponse.replaceAll(Constant.QUOT_x,SpecialCharacterConstant.DOUBLE_QOUTE); 
                    IglooResponseBean responseBean = new IglooResponseBean();                 
                    ResponseBean = (IglooResponseBean)JSON.Deserialize(iglooResponse, IglooResponseBean.class);
                    if(siteQuoteList[0].Alternate_Access_IGLOO_Request_Time__c != null){
                        siteQuoteList[0].Alternate_Access_IGLOO_Request_Time_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Request_Time__c;
                    }
                    if(siteQuoteList[0].Iglow_Response_Received_Date__c != null){
                        siteQuoteList[0].Igloo_Response_Received_Date_Old__c = siteQuoteList[0].Iglow_Response_Received_Date__c;
                    }
                    if(siteQuoteList[0].Alternate_Access_IGLOO_Process_Completed__c != null){
                        siteQuoteList[0].Alternate_Access_IGLOO_ProcessCmpltd_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Process_Completed__c;
                    } 
                    siteQuoteList[0].Alternate_Access_IGLOO_Process_Completed__c = true;
                    siteQuoteList[0].Alternate_Access_IGLOO_Request_Time__c = system.now();
                    siteQuoteList[0].Iglow_Response_Received_Date__c=system.today();
                    
                    system.debug('@@@listAttrVal: '+listAttrVal); 
                    
                    if(ResponseBean != null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse != null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.Response != null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.Response.description != null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.Response.description == Constant.SUCCESS && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth != null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails != null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails.baseMonthlyPriceUSD != null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.accessBandwidth != null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.physicalInterface != null && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails.coverage.equalsIgnoreCase('Found-Firm') && ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails.vendorPreferenceMetFlag.equalsIgnoreCase('true')){
                        iglooAccessSpeed = Integer.valueOf(ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.accessBandwidth)/1000;
                        iglooInterfaceCode = ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.physicalInterface;
                        if(iglooInterfaceCode == Constant.SIVARConst_1003){
                            iglooInterfaceType = Constant.ELECTRICAL_100_BASE_TX1;
                        }else if(iglooInterfaceCode == Constant.SIVARConst_1010){
                            iglooInterfaceType = Constant.OPTICALSINGLE_MODE_1000_BASE_LX; 
                        }else if(iglooInterfaceCode == Constant.SIVARConst_1009){
                            iglooInterfaceType = Constant.OPTICALMULTI_MODE_1000_BASE_SX;
                        }               
                        
                        system.debug('@@sfdc inside if of Renewal iglooAccessSpeed  '+iglooAccessSpeed );
                        system.debug('@@sfdc inside if of Renewal currentAccessSpeed '+currentAccessSpeed);
                        system.debug('@@sfdc inside if of Renewal iglooInterfaceCode '+iglooInterfaceCode );
                        system.debug('@@sfdc inside if of Renewal iglooInterfaceType '+iglooInterfaceType );
                        system.debug('@@sfdc inside if of Renewal currentInterfaceType '+currentInterfaceType);
                        
                        if(iglooAccessSpeed == currentAccessSpeed && iglooInterfaceType == currentInterfaceType){
                            if(siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c != null){
                                siteQuoteList[0].Alternate_Access_IGLOO_ResponseStatusOld__c = siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c;
                            }
                            if(siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c != null){
                                siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c;
                            }
                            siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c = Constant.SUCCESS;
                            siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c = SpecialCharacterConstant.CONCAT;                             
                            listAttrVal.Apttus_Config2__Vendor__c = ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails.supplierName.replaceAll(',','');
                            system.debug('@@@contract renewal : listAttrVal.Apttus_Config2__Vendor__c: '+listAttrVal.Apttus_Config2__Vendor__c);
                            listAttrVal.Igloo_Call_Processing_Complete__c = true;
                            listAttrVal.IGLOO_Retrial_Failure_Count__c = 0;
                            listAttrVal.IGLOO_Call_Failure__c = false; 
                            quoteList[0].RetrialFailure__c = 0;                            
                            if(siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c != null){
                                siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c;
                            }
                            if(siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c != null){
                                siteQuoteList[0].Alternate_Access_IGLOO_Access_Price_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c;
                            }
                            if(siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c != null){
                                siteQuoteList[0].Alternate_Access_IGLOO_Interface_CodeOld__c = siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c;
                            }
                            siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c = listAttrVal.ProductName__c == Constant.AVPN ? listAttrVal.Access_Speed_AVPN__c : listAttrVal.Access_Speed_MIS__c;
                            siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c = listAttrVal.Alternate_Access_IGLOO_Interface_Code__c;                            
                            siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c = listAttrVal.Alternate_Access_IGLOO_Access_Price__c = Decimal.valueOf(ResponseBean.InquireEnterprisePriceQuoteDetailsResponse.DomesticPricePromoQuoteResponse.Bandwidth.ContractDetails.baseMonthlyPriceUSD);
                        }else{
                            listAttrVal.ContractRenewal_IglooError__C= true;
                        }
                    }else{
                        listAttrVal.ContractRenewal_IglooError__C= true;
                    }
                }else{
                    listAttrVal.ContractRenewal_IglooError__C= true;
                }
            }
            
            update siteQuoteList;
            update quoteList;
        }catch(Exception e){
            if(quoteList[0].Renewal_Contract__c){
                listAttrVal.ContractRenewal_IglooError__c= true;
            }else{
                if(siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c != null){
                    siteQuoteList[0].Alternate_Access_IGLOO_ResponseStatusOld__c = siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c;
                }
                if(siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c != null){
                    siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c;
                }
                if(siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c != null){
                    siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c;
                }
                if(siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c != null){
                    siteQuoteList[0].Alternate_Access_IGLOO_Access_Price_Old__c = siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c;
                }
                if(siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c != null){
                    siteQuoteList[0].Alternate_Access_IGLOO_Interface_CodeOld__c = siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c;
                }   
                siteQuoteList[0].Alternate_Access_IGLOO_Response_Status__c = Constant.FAILURE;
                siteQuoteList[0].Alternate_Access_IGLOO_Failure_Code__c = Constant.SIVARConst_0044;
                siteQuoteList[0].Alternate_Access_IGLOO_Access_Speed__c = siteQuoteList[0].Alternate_Access_IGLOO_Interface_Code__c = SpecialCharacterConstant.CONCAT;
                siteQuoteList[0].Alternate_Access_IGLOO_Access_Price__c = null;
                executeIglooFailureLogic(siteId, listAttrVal);
            }
        }
    }
    
    /*Method to clear Igloo Flags*/
    public void clearIglooFields(String quoteId, String siteId, Apttus_Config2__ProductAttributeValue__c listAttrVal){
        list<AT_T_Customer_Site_Quote__c> siteQuoteList = new list<AT_T_Customer_Site_Quote__c>();
        siteQuoteList = [select id, AT_T_Customer_Site__c, AT_T_Quote__c, Igloo_Review_Required__c from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c =: siteId and AT_T_Quote__c =: quoteId];
        siteQuoteList[0].Igloo_Review_Required__c = false;
        listAttrVal.IGLOO_Port_Speed_Substituted__c = listAttrVal.IGLOO_Access_Speed_Substituted__c = listAttrVal.IGLOO_Interface_Type_Substituted__c = listAttrVal.IGLOO_Speed_Unavailable__c = listAttrVal.Igloo_Call_Processing_Complete__c = listAttrVal.IGLOO_Call_Failure__c = false;
        listAttrVal.IGLOO_Old_Port_Speed__c = listAttrVal.IGLOO_Old_Access_Speed__c = listAttrVal.IGLOO_Old_Interface_Type__c = SpecialCharacterConstant.CONCAT;
        update siteQuoteList;
    }
    
    /*Method to execute logic when Igloo is unavailable*/
    public void executeIglooUnavailableLogic(String siteId, Apttus_Config2__ProductAttributeValue__c listAttrVal,String macdChangeType){  
        Boolean isPricingDataAvailable;        
        List<Apttus_Config2__LineItem__c> lineItems = [SELECT Id, Apttus_Config2__LineNumber__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__ExtendedPrice__c,Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__ListPrice__c, Apttus_Config2__BasePrice__c,Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c =: listAttrVal.Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c AND AT_T_Customer_Site__c =: siteId];
        Apttus_Config2__ProductAttributeValue__c newAVToBeUpdated = new Apttus_Config2__ProductAttributeValue__c ();
        newAVToBeUpdated.Apttus_Config2__LineItemId__c = lineItems[0].Id;        
        newAVToBeUpdated.IGLOO_Old_Access_Speed__c = listAttrVal.ProductName__c == Constant.AVPN ? listAttrVal.Access_Speed_AVPN__c : listAttrVal.Access_Speed_MIS__c;                        
        try{
        if(macdChangeType==Constant.PORTACCESS_SPEED_CHANGE){
            if(listAttrVal.ProductName__c == Constant.AVPN){                                      
                newAVToBeUpdated.Port_Type_AVPN__c =  newAVToBeUpdated.Access_Type_AVPN__c = listAttrVal.Port_Type_AVPN__c;
                newAVToBeUpdated.Interface_Type_AVPN__c = listAttrVal.Interface_Type_AVPN__c;
                newAVToBeUpdated.Install_Option_AVPN__c = listAttrVal.Install_Option_AVPN__c;
                newAVToBeUpdated.VLANs_Logical_Channels__c = listAttrVal.VLANs_Logical_Channels__c;
                newAVToBeUpdated.CoS__c = listAttrVal.CoS__c;   
            }else{
                newAVToBeUpdated.Port_Type_MIS__c = newAVToBeUpdated.Access_Type__c = listAttrVal.Port_Type_MIS__c;
                newAVToBeUpdated.Interface_Type_MIS__c = listAttrVal.Interface_Type_MIS__c;
                newAVToBeUpdated.Install_Option_MIS__c = listAttrVal.Install_Option_MIS__c;
                newAVToBeUpdated.Additional_DNS__c = listAttrVal.Additional_DNS__c;
                newAVToBeUpdated.CoS__c = listAttrVal.CoS__c;
            }        
        }
        newAVToBeUpdated.IGLOO_Speed_Unavailable__c = true;  
        insert newAVToBeUpdated;
        
        for( Apttus_Config2__LineItem__c eachLineItem : lineItems){        
            eachLineItem.Apttus_Config2__AttributeValueId__c = newAVToBeUpdated.Id;
            eachLineItem.Apttus_Config2__PricingStatus__c = Constant.PENDING;
            eachLineItem.isPricingApplied__c = false;
            eachLineItem.Apttus_Config2__ListPrice__c = eachLineItem.Apttus_Config2__BasePrice__c = eachLineItem.Apttus_Config2__BaseExtendedPrice__c = eachLineItem.Apttus_Config2__ExtendedPrice__c = eachLineItem.Apttus_Config2__AdjustedPrice__c = eachLineItem.Apttus_Config2__NetPrice__c = 0.0;
        }
        update lineItems;
        isPricingDataAvailable=false; 
        } catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*Method to execute logic IGLOO Failure Logic*/
    public void executeIglooFailureLogic(String siteId, Apttus_Config2__ProductAttributeValue__c listAttrVal){ 
        Boolean isPricingDataAvailable;
        listAttrVal.IGLOO_Retrial_Failure_Count__c = listAttrVal.IGLOO_Retrial_Failure_Count__c != null ? listAttrVal.IGLOO_Retrial_Failure_Count__c + 1 : 1;   
        listAttrVal.IGLOO_Call_Failure__c = true;
        listAttrVal.IGLOO_Old_Port_Speed__c = listAttrVal.IGLOO_Old_Access_Speed__c = listAttrVal.IGLOO_Old_Interface_Type__c = SpecialCharacterConstant.CONCAT;   
        listAttrVal.IGLOO_Port_Speed_Substituted__c = listAttrVal.IGLOO_Access_Speed_Substituted__c = listAttrVal.IGLOO_Interface_Type_Substituted__c = listAttrVal.IGLOO_Speed_Unavailable__c = false;     
        list<Apttus_Config2__LineItem__c> lineItems = [SELECT Id, Apttus_Config2__LineNumber__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__ExtendedPrice__c,Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__ListPrice__c, Apttus_Config2__BasePrice__c,Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c,Alternate_Access_IGLOO_Access_Price__c,Alternate_Access_IGLOO_Discount__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c =: listAttrVal.Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c AND AT_T_Customer_Site__c =: siteId];
        try{
        for( Apttus_Config2__LineItem__c eachLineItem : lineItems){        
            eachLineItem.Apttus_Config2__PricingStatus__c = Constant.PENDING;
            eachLineItem.isPricingApplied__c = false;
            eachLineItem.Apttus_Config2__ListPrice__c = eachLineItem.Apttus_Config2__BasePrice__c = eachLineItem.Apttus_Config2__BaseExtendedPrice__c = eachLineItem.Apttus_Config2__ExtendedPrice__c = eachLineItem.Apttus_Config2__AdjustedPrice__c = eachLineItem.Apttus_Config2__NetPrice__c = 0.0;
            eachLineItem.Alternate_Access_IGLOO_Access_Price__c = eachLineItem.Alternate_Access_IGLOO_Discount__c = null;
        }
        update lineItems;
        isPricingDataAvailable=false; 
        } catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*To update Discounted price on Line Item for Access Speed Fee returned from Igloo*/
    public void fetchAccessSpeedDiscountedPrice(String quoteId, String cartId, Integer lineNumber, Apttus_Config2__ProductAttributeValue__c listAttrVal){
        
        Apttus_Proposal__Proposal__c proposalData = new Apttus_Proposal__Proposal__c();  
        list<Apttus_Config2__LineItem__c> accessLineItemList = new list<Apttus_Config2__LineItem__c>();
        accessLineItemList = [Select Alternate_Access_IGLOO_Discount__c, Alternate_Access_IGLOO_Access_Price__c, Apttus_Config2__NetPrice__c,Apttus_Config2__ListPrice__c,Apttus_Config2__BasePrice__c,Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__ExtendedPrice__c,Apttus_Config2__AttributeValueId__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=:cartId AND Apttus_Config2__LineNumber__c =:lineNumber AND Apttus_Config2__ChargeType__c ='Access Speed Fee' LIMIT 1];
        proposalData = [SELECT Id, Apttus_QPConfig__PriceListId__r.Id, Name, Product_New_Name__c, Product_Name__c, Site_Status__c, Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Payment_Term__c,Product__r.ProductCode, MACDMasterTier__c FROM Apttus_Proposal__Proposal__c WHERE Id =:quoteId];
        try{
            if(proposalData != null && String.isNotBlank(cartId)){ 
                //LNS Access Pricing Logic 
                system.debug('@@sfdc listAttrVal ContractRenewal_Access_Price__c  '+listAttrVal.ContractRenewal_Access_Price__c);
                if(listAttrVal.ContractRenewal_IglooError__C){
                   accessLineItemList[0].Apttus_Config2__NetPrice__c = accessLineItemList[0].Apttus_Config2__ListPrice__c = accessLineItemList[0].Apttus_Config2__BasePrice__c = accessLineItemList[0].Apttus_Config2__BaseExtendedPrice__c = accessLineItemList[0].Apttus_Config2__AdjustedPrice__c = accessLineItemList[0].Apttus_Config2__ExtendedPrice__c  = listAttrVal.ContractRenewal_Access_Price__c;
                   update accessLineItemList;
                }else{
                    Set<String> LNSSupplierSet = new set<String>();
                    LNSSupplierSet = LNSSupplierNames__c.getAll().keySet();
                    if(!LNSSupplierSet.isEmpty() && (LNSSupplierSet.contains(listAttrVal.Apttus_Config2__Vendor__c) || listAttrVal.Apttus_Config2__Vendor__c.contains('AT&T'))){
                        updateIGLOOLNSPricing(proposalData, listAttrVal, accessLineItemList);
                    }            
                    //IGLOO Access Pricing Logic
                    else{                 
                        Decimal discountedAccessFee = 0.00;
                        Decimal discountPercent = 0.00;   
                        list<Alternate_Access_Discount__c> discList = new list<Alternate_Access_Discount__c>();     
                        Decimal baseMonthlyPriceUSD = listAttrVal.Alternate_Access_IGLOO_Access_Price__c != null ? listAttrVal.Alternate_Access_IGLOO_Access_Price__c : 0.00;
                        String proCode = (proposalData.Product__r.ProductCode == Constant.AMIS) ? Constant.MIS : (proposalData.Product__r.ProductCode == Constant.AVPN) ? Constant.AVPN : SpecialCharacterConstant.CONCAT;
                        discList = [Select Percent__c FROM Alternate_Access_Discount__c WHERE Product__c =: proCode AND Term__c =:proposalData.Apttus_Proposal__Payment_Term__c.mid(0,1) AND Tier__c =: proposalData.MACDMasterTier__c LIMIT 1];
                        if(discList != null && discList.size()>0){
                            discountPercent = discList[0].Percent__c;
                        }
                                        
                        if(discountPercent != null){
                            discountedAccessFee = (((100 - discountPercent)/100)*baseMonthlyPriceUSD).setScale(2);
                        }                        
                        
                        if(accessLineItemList != null && accessLineItemList.size() > 0){
                            accessLineItemList[0].Alternate_Access_IGLOO_Access_Price__c= baseMonthlyPriceUSD;
                            accessLineItemList[0].Alternate_Access_IGLOO_Discount__c = discountPercent;
                            accessLineItemList[0].Apttus_Config2__NetPrice__c = accessLineItemList[0].Apttus_Config2__ListPrice__c = accessLineItemList[0].Apttus_Config2__BasePrice__c = accessLineItemList[0].Apttus_Config2__BaseExtendedPrice__c = accessLineItemList[0].Apttus_Config2__AdjustedPrice__c = accessLineItemList[0].Apttus_Config2__ExtendedPrice__c  = discountedAccessFee;
                            update accessLineItemList;
                        }
                    }
                    
                    list<Apttus_Config2__ProductAttributeValue__c> accessAVList = new list<Apttus_Config2__ProductAttributeValue__c>();
                    if(accessLineItemList != null && accessLineItemList.size() > 0){
                        accessAVList=[select id,VASA_Region__c,Igloo_Access_Price__c from Apttus_Config2__ProductAttributeValue__c where id = :accessLineItemList[0].Apttus_Config2__AttributeValueId__c];
                        accessAVList[0].Igloo_Access_Price__c = accessLineItemList[0].Apttus_Config2__NetPrice__c;
                        update accessAVList;
                    }
                }
            }
        } catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*To get the LNS pricing after IGLOO Call for eligible sites*/
    public void updateIGLOOLNSPricing(Apttus_Proposal__Proposal__c proposalData, Apttus_Config2__ProductAttributeValue__c listAttrVal, list<Apttus_Config2__LineItem__c> accessLineItemList){
        try{
            Decimal lnsAccessPrice = 0.00;
            String accessSpeed = listAttrVal.ProductName__c == Constant.AVPN ? listAttrVal.Access_Speed_AVPN__c : listAttrVal.Access_Speed_MIS__c;
            list<Apttus_Config2__PriceMatrixEntry__c> matrixEntryList = new list<Apttus_Config2__PriceMatrixEntry__c>();            
            matrixEntryList = [select Id,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id, Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__PeriodEndDate__c from Apttus_Config2__PriceMatrixEntry__c where Apttus_Config2__Dimension1Value__c =: accessSpeed and Apttus_Config2__Dimension2Value__c = 'In Region' and Description_PL__c = 'Matrix part Access Speed Fee for switched ethernet' and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id =: proposalData.Apttus_QPConfig__PriceListId__r.Id and Apttus_Config2__PeriodEndDate__c = null];
            if( matrixEntryList != null && matrixEntryList.size() > 0 ){                   
                for( Apttus_Config2__PriceMatrixEntry__c matrix : matrixEntryList ){                       
                    lnsAccessPrice = matrix.Apttus_Config2__AdjustmentAmount__c; 
                }
            }            
            if(accessLineItemList != null && accessLineItemList.size() > 0){
                accessLineItemList[0].Alternate_Access_IGLOO_Access_Price__c = accessLineItemList[0].Apttus_Config2__NetPrice__c = accessLineItemList[0].Apttus_Config2__ListPrice__c = accessLineItemList[0].Apttus_Config2__BasePrice__c = accessLineItemList[0].Apttus_Config2__BaseExtendedPrice__c = accessLineItemList[0].Apttus_Config2__AdjustedPrice__c = accessLineItemList[0].Apttus_Config2__ExtendedPrice__c  = lnsAccessPrice;
                update accessLineItemList;
            }
        } 
        catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
}