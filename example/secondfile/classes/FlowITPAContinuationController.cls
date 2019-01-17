/************************************************************************************** 
Apex Class Name     : FlowITPAContinuationController
Version             : 1.0 
Created Date        : 17 Jan 2017
Function            : Response Bean for AVPN/MIS ITPA Response
**************************************************************************************/
public class FlowITPAContinuationController{    
    
    /*FlowITPAContinuationController constructor*/
    public FlowITPAContinuationController(){       
        
    }    
  
    /*Method Name: InitiateCallBulk*/
    public HttpResponse InitiateCallBulk(FlowITPARequestBean requestBean,List<CustomerSite__c> customerSiteList) {
        Long endTime ,startTime ,totalTime ;
        HttpResponse response;
        try{
            Integer continuationTime=Integer.valueof(Global_Variable__c.getValues('FlowITPAContinuationTime')!=null ? Global_Variable__c.getValues('FlowITPAContinuationTime').Value__c : BuyflowConstant.SIVARConst_120);
            String endPointURL = Global_Variable__c.getValues('FlowITPAEndPoint')!=null ? Global_Variable__c.getValues('FlowITPAEndPoint').Value__c : SpecialCharacterConstant.CONCAT; 
            String accessToken= Global_Variable__c.getValues('BlackFlagAccessToken')!=null ? Global_Variable__c.getValues('BlackFlagAccessToken').Value__c : SpecialCharacterConstant.CONCAT;    
            String  tokenType=  Global_Variable__c.getValues('BlackFlageTokenType')!=null ? Global_Variable__c.getValues('BlackFlageTokenType').Value__c : BuyflowConstant.BEARER_CONST;
            String authorizationHeader =tokenType+' ' + accessToken; 
            startTime = datetime.now().getTime();
              
            HttpRequest request = new HttpRequest();  
            Http connection = new Http();
            response = new HttpResponse();  
            request.setEndpoint(endPointURL);
            request.setMethod(ATTConstants.PostMethod);
            request.setHeader('X-CSI-TimeToLive', '120000');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization',authorizationHeader);
            request.setTimeOut(120000);    
            request.setBody(Json.serialize(requestBean));  
            
            system.debug('@@@ITPA Request: '+request.getBody());
            response = connection.send(request);            
            system.debug('@@@ITPA Response: '+response.getBody());
            endTime = datetime.now().getTime();
            totalTime = endTime - startTime;      
            system.debug('@@@Time Taken for ITPA Call: '+totalTime+ 'ms');
            list<String> headerkeyList = new list<String>();
            headerkeyList = response.getHeaderKeys();  
            for(String s : headerkeyList){
                system.debug('Header Key: ' + s + ' Header Value: ' + response.getHeader(s));       
            }
        }
        catch(Exception e){
            system.debug('Exception in InitiateCallBulk method of FlowITPAContinuationController '+e+' at line no '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
         }
        return response;
    }
    
    /*Method Name: processFLOWITPAResponseBulk*/
    public void processFLOWITPAResponseBulk(List<HttpResponse> responseList,List<CustomerSite__c> customerSiteList){ 
        try{
            system.debug('@@@Response List: '+responseList);
            system.debug('@@@Customer Site List: '+customerSiteList);
            String ITPAErrorCode = Label.ITPA_Error_Code;
            Map<String,FlowITPAResposnseBean.Site> itpaSiteResponseMap = new Map<String,FlowITPAResposnseBean.Site>();
            Map<String,String> itpaSiteConversationIdMap = new Map<String,String>();
            Map<String,String> siteIdITPAEthernetAvailabilityMap = new Map<String,String>();
            Set<String> allSpeedsSet = new Set<String>();
            List<Fiber_Lit_Speeds__c> speeds = Fiber_Lit_Speeds__c.getall().values();
            system.debug(speeds);
            for(Fiber_Lit_Speeds__c speed: speeds){
                allSpeedsSet.add(speed.Name);
            }
            List<String> defaultSpeedsList=new List<String>();
            defaultSpeedsList.addAll(allSpeedsSet);           
            Boolean isITPAStubActivated = false;
            Admin_Control__c adminControl = [SELECT ITPA_Response_Stubbing_Activated__c, FlowITPAResponse__c FROM Admin_Control__c LIMIT 1];
            if(adminControl != null){
                isITPAStubActivated = adminControl.ITPA_Response_Stubbing_Activated__c;
            }
            system.debug('@@@ITPA Stub Activated: '+isITPAStubActivated );
            if(!isITPAStubActivated){
                for(HttpResponse response : responseList){
                    FlowITPAResposnseBean responseBean= (FlowITPAResposnseBean)JSON.deserialize(response.getBody(),FlowITPAResposnseBean.class);
                    List<FlowITPAResposnseBean.Site> addressList=new List<FlowITPAResposnseBean.Site>();
                    if(responseBean.Site != null){
                        addressList = responseBean.Site;
                    }
                    system.debug('@@@AddressList: '+addressList);
                    for(FlowITPAResposnseBean.Site address : addressList){
                        itpaSiteResponseMap.put(address.id,address);
                        itpaSiteConversationIdMap.put(address.id,response.getHeader('X-CSI-ConversationId'));
                        system.debug('@@@CSI Conversation Id for ITPA Call: '+response.getHeader('X-CSI-ConversationId'));
                        //Ethernet check logic
                        List<FlowITPAResposnseBean.physicalResource> physicalResourceList = new List<FlowITPAResposnseBean.physicalResource>();
                        
                        String ethAvailable = '';
                        if(address.physicalResource!=null){
                            physicalResourceList = address.physicalResource;
                            for(FlowITPAResposnseBean.physicalResource phyResource : physicalResourceList){ 
                                if(phyResource.availability != null){
                                    if('true'.equalsIgnoreCase(phyResource.availability)){
                                        ethAvailable = 'true';
                                        break;
                                    }
                                }
                            }
                        }
                        if('true'.equalsIgnoreCase(ethAvailable)){
                            siteIdITPAEthernetAvailabilityMap.put(address.id,'true');
                        }else{
                            siteIdITPAEthernetAvailabilityMap.put(address.id,'false');
                        }
                    }                
                }
            }else{
                system.debug('@@@ITPA Stub Activated');
                FlowITPAResposnseBean responseBean= (FlowITPAResposnseBean)JSON.deserialize(adminControl.FlowITPAResponse__c,FlowITPAResposnseBean.class);
                List<FlowITPAResposnseBean.Site> addressList=new List<FlowITPAResposnseBean.Site>();
                if(responseBean.Site != null){
                    addressList = responseBean.Site;
                }
                system.debug('@@@AddressList: '+addressList);
                for(CustomerSite__c custSite : customerSiteList){
                    for(FlowITPAResposnseBean.Site address : addressList){
                        itpaSiteResponseMap.put(custSite.id,address);
                        itpaSiteConversationIdMap.put(custSite.id,'stubbedresponse-'+custSite.id);
                        //Ethernet check logic
                        List<FlowITPAResposnseBean.physicalResource> physicalResourceList = new List<FlowITPAResposnseBean.physicalResource>();
                        String ethAvailable = '';
                        if(address.physicalResource != null){
                            physicalResourceList = address.physicalResource;                        
                            for(FlowITPAResposnseBean.physicalResource phyResource : physicalResourceList){ 
                                if(phyResource.availability != null){
                                    if('true'.equalsIgnoreCase(phyResource.availability)){
                                        ethAvailable = 'true';
                                        break;
                                    }
                                }
                            }
                        }
                        if('true'.equalsIgnoreCase(ethAvailable)){
                            siteIdITPAEthernetAvailabilityMap.put(custSite.id,'true');
                        }else{
                            siteIdITPAEthernetAvailabilityMap.put(custSite.id,'false');
                        }
                    }          
                }               
            }
            
            List<Attachment> attachmentList=new List<Attachment>();
            FlowITPAResposnseBean.ServiceAvailability serviceAvailability = new FlowITPAResposnseBean.ServiceAvailability();
            FlowITPAResposnseBean.Place place = new FlowITPAResposnseBean.Place();
            List<FlowITPAResposnseBean.Characteristic> charList = new List<FlowITPAResposnseBean.Characteristic >();
            
            for(CustomerSite__c custSite : customerSiteList){
                custSite.Has_Failed_Request__c = false; 
                custSite.Has_Failed_API_MACD__c = false;
                String swCLLI='', lata='', latitude='', longitude='', locationClli='',territoryIndicator='';
                String address= UtilityConstant.blank;
                Attachment attach;
                if(itpaSiteResponseMap.get(custSite.id)!=null){
                    FlowITPAResposnseBean.Site currentAddress=itpaSiteResponseMap.get(custSite.id);
                    custSite.Speeds_Not_Available_ITPA__c = String.join(defaultSpeedsList,',');
                    custSite.Alternate_Access_ITPA_Conversation_Id__c = itpaSiteConversationIdMap.get(custSite.id);
                    if(ITPAErrorCode != UtilityConstant.SIVARConst_0){
                        custSite.Alternate_Access_ITPA_Response_Status__c = ITPAErrorCode;                     
                    }else{
                        custSite.Alternate_Access_ITPA_Response_Status__c = currentAddress.interactionStatus;
                    }  
                    custSite.Alternate_Access_ITPA_Process_Completed__c = true;
                    if(currentAddress.interactionStatus!=null && BuyflowUtil.sendITPASuccessCodes().contains(currentAddress.interactionStatus) && ITPAErrorCode ==UtilityConstant.SIVARConst_0){
                        custSite.Alternate_Access_ITPA_Request_Time__c=system.now();
                    }else{
                        custSite.Alternate_Access_ITPA_Request_Time__c=null;
                    }
            
                    system.debug('@@@itpaSiteResponseMap' + itpaSiteResponseMap);
                    blob csvBlob = Blob.valueOf(Json.serialize(itpaSiteResponseMap.get(custSite.id)));
                    attach = new Attachment(); 
                    attach.Body =csvBlob ;
                    attach.Name = BuyflowConstant.ITPA_RESPONSE_CONST+SpecialCharacterConstant.UNDERSCORE+(system.now()+SpecialCharacterConstant.CONCAT).replaceALL(SpecialCharacterBuyflowConstant.BLANK,SpecialCharacterConstant.UNDERSCORE)+BuyflowConstant.TXT_EXT_CONST;
                    attach.IsPrivate = false;
                    attach.ParentId = custSite.id;
                    attachmentList.add(attach);

                    Set<String> speedSet=new Set<String>();
                    if(currentAddress.serviceAvailability!=null && currentAddress.serviceAvailability.service!=null){ 
                        for(integer i=0; i<currentAddress.serviceAvailability.service.size();i++){
                            if(currentAddress.serviceAvailability.service[i].serviceSpecification!=null && currentAddress.serviceAvailability.service[i].serviceSpecification.id!=null){
                                if(FlowITPASpeedIDMap__c.getValues(currentAddress.serviceAvailability.service[i].serviceSpecification.id)!=null){
                                    speedSet.add(FlowITPASpeedIDMap__c.getValues(currentAddress.serviceAvailability.service[i].serviceSpecification.id).SpeedId__c);
                                }
                            }
                        }
                    }
                    System.debug('@@@Place'+currentAddress.place);
                    if(currentAddress.place!=null && currentAddress.place.id!=null){
                        custSite.Global_Location_ID__c = currentAddress.place.id;
                    }
                    
                    if(speedSet.size()>0){
                        custSite.Alternate_Access_Port_Speed__c=string.valueof(speedSet).substring(1, string.valueof(speedSet).length()-1);
                    }
                    else{
                        custSite.Alternate_Access_Port_Speed__c=UtilityConstant.blank;
                    }
                
                    if(currentAddress.serviceAvailability!=null && currentAddress.serviceAvailability.service!=null && currentAddress.serviceAvailability.service[0].characteristic!=null){
                        charList=currentAddress.serviceAvailability.service[0].characteristic;
                        system.debug('@@@Characteristic List: '+charList);
              
                        for(FlowITPAResposnseBean.Characteristic characteristic : charList){                        
                            if(characteristic.name!=null && characteristic.name.equals('swCLLI')){
                                swCLLI = characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.LATITUDE_LOWER_CONST)){
                                latitude = custSite.Alternate_Access_latitude__c = characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals('lata')){
                                lata = characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals('longitude')){
                                longitude = custSite.Alternate_Access_longitude__c = characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.MATCHDETAILS_SLASH_LEVEL_CONST)){
                                custSite.Alternate_Access_level__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.LOCATOR_CONST)){
                                custSite.Alternate_Access_locator__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.LONGITUDE_LOWER_CONST)){
                                custSite.Alternate_Access_longitude__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.HORIZONTALCOORDINATE_CONST)){
                                custSite.Alternate_Access_meetPointHCoordinate__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.VERTICALCOORDINATE_CONST)){
                                custSite.Alternate_Access_meetPointVCoordinate__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.NPA_LOWER_CONST)){
                                custSite.Alternate_Access_npaNxx__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.NXX_LOWER_CONST)){
                                custSite.Alternate_Access_npaNxx__c=custSite.Alternate_Access_npaNxx__c+characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.MATCHDETAILS_SLASH_SCORE_CONST)){
                                custSite.Alternate_Access_score__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.ILECDETAILS_SLASH_SERVINGWIRECENTER_CONST)){
                                custSite.Alternate_Access_servingWireCenter__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals('MatchDEtails/status')){
                                custSite.Alternate_Access_status__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.TERRITORYINDICATOR_CONST)){
                                territoryIndicator = custSite.Alternate_Access_territoryIndicator__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.ILECDETAILS_SLASH_VENDORNAME_CONST)){
                                custSite.Alternate_Access_vendorName__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.MATCHDETAILS_SLASH_CODE_CONST)){
                                custSite.Alternate_Access_code__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.NOD_TECHNOLOGY_ASE_CONST)){
                                custSite.Alternate_Access_ASE_NOD_status__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.NOD_TECHNOLOGY_MIS_CONST)){
                                custSite.Alternate_Access_MIS_NOD_status__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.BUILDINGFIBERSTATUS_SLASH_COLOR_CONST)){
                                custSite.Alternate_Access_Building_Fiber_color__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.BUILDINGFIBERSTATUS_SLASH_CODE_CONST)){
                                custSite.Alternate_Access_Building_Fiber_code__c=characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals(BuyflowConstant.BUILDINGCLLI_CONST)){
                                locationClli = custSite.Alternate_Access_Building_CLLI__c = characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals('pricingTier')){
                                custSite.Pricing_Tier__c = characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals('QualificationTier')){
                                custSite.Qualification_Tier__c = characteristic.value;
                                continue;
                            }
                            if(characteristic.name!=null && characteristic.name.equals('coreBasedStatisticalAreaCode')){
                                custSite.Core_Based_Statistical_Area_Code__c = characteristic.value;
                                continue;
                            }
                        }
                        
                        //Speed Exclusion Logic
                        for(FlowITPAResposnseBean.Service Sev : currentAddress.serviceAvailability.service){
                            for(FlowITPAResposnseBean.Characteristic characteristic : Sev.Characteristic){
                                if(characteristic.name !=null && characteristic.name.equalsIgnoreCase('downloadSpeed')){
                                    custSite.Speeds_Not_Available_ITPA__c = 'None';
                                    String speed = characteristic.value.toUpperCase();
                                    if(allSpeedsSet.contains(speed)){
                                        allSpeedsSet.remove(speed);
                                    }                                                                   
                                }
                            }
                        }
                        
                        system.debug('@@@Speed Set: '+allSpeedsSet);
                        if(allSpeedsSet!=null && allSpeedsSet.size() > 0){
                            custSite.Speeds_Not_Available_ITPA__c = null;
                            List<String> speedExcList=new List<String>();
                            speedExcList.addAll(allSpeedsSet);
                            custSite.Speeds_Not_Available_ITPA__c = String.join(speedExcList,',');
                        }         
                    }
                }
                
                //Logic to update VASA with ITPA Response 
                String regExp = '&quot;';
                set<Integer> successCodes = new set<Integer>{0,1,2};
                String JSONResponse = custSite.Service_Availability_Response__c;
                JSONResponse = JSONResponse.replaceAll(regExp,'"');
                list<AddrValidServAvailResponseBean.AddressServiceAvailability> addressServiceAvailabilityList = new list<AddrValidServAvailResponseBean.AddressServiceAvailability>();
                AddrValidServAvailResponseBean responseBean = new AddrValidServAvailResponseBean();
                ResponseBean = (AddrValidServAvailResponseBean)JSON.Deserialize(JSONResponse,AddrValidServAvailResponseBean.class);
                AddressServiceAvailabilityList = ResponseBean.AddressServiceAvailability;                
                AddrValidServAvailResponseBean.ServiceAvailabilityDetails serviceAvailabilityDetailsObj = new AddrValidServAvailResponseBean.ServiceAvailabilityDetails(); 
                AddrValidServAvailResponseBean res; 
                system.debug('@@@AddressServiceAvailabilityList: '+AddressServiceAvailabilityList);
                                
                //Logic to check if ethernet speed is available and update VASA Response Status based on ITPA response
                Boolean ethernetAvailabilityForSite = false;
                system.debug('@@@Speeds Not Available: '+custSite.Speeds_Not_Available_ITPA__c);
                
                if(String.isNotBlank(custSite.Speeds_Not_Available_ITPA__c) && !custSite.Speeds_Not_Available_ITPA__c.equalsIgnoreCase(string.join(defaultSpeedsList , ','))){
                    ethernetAvailabilityForSite = true;
                    system.debug('Inside Ethernet Availability: '+ethernetAvailabilityForSite);
                }else if(custSite.Raw_VASA_Response_Status__c != null && (custSite.Raw_VASA_Response_Status__c == 'ADDRESS NO MATCH' || custSite.Raw_VASA_Response_Status__c == 'SERVICE UNAVAILABLE' || custSite.VASA_Response_Status__c == 'ADDRESS RECORD CREATED')){
                    custSite.VASA_Response_Status__c = 'SERVICE UNAVAILABLE';
                    custSite.Alternate_Access_Port_Speed__c = custSite.Alternate_Access_latitude__c = custSite.Alternate_Access_longitude__c  = custSite.Alternate_Access_level__c = custSite.Alternate_Access_locator__c = custSite.Alternate_Access_longitude__c = custSite.Alternate_Access_meetPointHCoordinate__c = custSite.Alternate_Access_meetPointVCoordinate__c = custSite.Alternate_Access_npaNxx__c = custSite.Alternate_Access_score__c = custSite.Alternate_Access_servingWireCenter__c = custSite.Alternate_Access_status__c = custSite.Alternate_Access_territoryIndicator__c = custSite.Alternate_Access_vendorName__c = custSite.Alternate_Access_code__c = custSite.Alternate_Access_ASE_NOD_status__c = custSite.Alternate_Access_MIS_NOD_status__c = custSite.Alternate_Access_Building_Fiber_color__c = custSite.Alternate_Access_Building_Fiber_code__c = custSite.Alternate_Access_Building_CLLI__c = null;
                    if(AddressServiceAvailabilityList != null && AddressServiceAvailabilityList.size()>0){                    
                        AddressServiceAvailabilityList[0].statusCode = 4;
                        AddressServiceAvailabilityList[0].statusMessage = 'Ethernet Service Is Not Available at this site'; 
                    }
                    system.debug('@@@Inside Service Unavailable Scenario: '+custSite.VASA_Response_Status__c);
                }  
                
                //Logic to populate Region based on Territory Indicator
                if(String.isNotBlank(territoryIndicator) && BuyflowConstant.Y.equalsIgnoreCase(territoryIndicator)){
                    custSite.Region__c = 'IR';
                }else if(String.isNotBlank(territoryIndicator) && !BuyflowConstant.Y.equalsIgnoreCase(territoryIndicator)){
                    custSite.Region__c = 'OOR';  
                }else if(AddressServiceAvailabilityList != null && String.isNotBlank(AddressServiceAvailabilityList[0].region)){
                    custSite.Region__c = BuyflowConstant.Y.equalsIgnoreCase(AddressServiceAvailabilityList[0].region) ? 'IR' : 'OOR';
                }
                
                if(AddressServiceAvailabilityList!=null && AddressServiceAvailabilityList.size()>0){
                    res = new AddrValidServAvailResponseBean();   
                    system.debug('@@@Territory Indicator: '+territoryIndicator);
                    if(String.isNotBlank(territoryIndicator)){
                        AddressServiceAvailabilityList[0].region = territoryIndicator;
                        if(AddressServiceAvailabilityList.size() > 1 && AddressServiceAvailabilityList[1].region != null){
                            AddressServiceAvailabilityList[1].region = territoryIndicator;
                        }
                        if(AddressServiceAvailabilityList.size() > 1 && AddressServiceAvailabilityList[1].lecName != null){
                            if(String.isNotBlank(AddressServiceAvailabilityList[1].lecName) && AddressServiceAvailabilityList[1].lecName == 'AT&amp;T'){
                                custSite.VASA_LEC__c = 'AT&T';
                            }else{
                                custSite.VASA_LEC__c = AddressServiceAvailabilityList[1].lecName;
                            }
                        }
                    }
                    if(String.isNotBlank(territoryIndicator) && BuyflowConstant.Y.equalsIgnoreCase(territoryIndicator)){ 
                        system.debug('@@@Inside VASA Replacement Logic for In Region');                        
                        AddressServiceAvailabilityList[0].swcClli = swCLLI;
                        AddressServiceAvailabilityList[0].locationClli = locationClli;
                        AddressServiceAvailabilityList[0].lecName = 'AT&T';
                
                        AddrValidServAvailResponseBean.Geocode geoCodeInst = new AddrValidServAvailResponseBean.Geocode(); 
                        geoCodeInst.latitude = Double.valueof(latitude);
                        geoCodeInst.longitude = Double.valueof(longitude);                        
                        AddressServiceAvailabilityList[0].Geocode = geoCodeInst;
                
                        AddrValidServAvailResponseBean.ServiceAvailabilityDetails serviceAvailabilityDetailsInst = new AddrValidServAvailResponseBean.ServiceAvailabilityDetails();
                        AddrValidServAvailResponseBean.Ethernet ethernetInst = new AddrValidServAvailResponseBean.Ethernet();
                        AddrValidServAvailResponseBean.PrivateLine privateLineInst = new AddrValidServAvailResponseBean.PrivateLine();
                        List<AddrValidServAvailResponseBean.PrivateLine> privateLineList = new List<AddrValidServAvailResponseBean.PrivateLine>();

                        if(ethernetAvailabilityForSite){
                            ethernetInst.ethernetAvailability = 'Y';
                        }else{
                            ethernetInst.ethernetAvailability = 'N';
                        }
                        List<AddrValidServAvailResponseBean.Service> ethServiceList = new List<AddrValidServAvailResponseBean.Service>();
                        List<AddrValidServAvailResponseBean.OtherSpeed> otherSpeedList = new List<AddrValidServAvailResponseBean.OtherSpeed>();
                        
                        //VASA Ethernet Available
                        if(successCodes.contains(AddressServiceAvailabilityList[0].statusCode)){ 
                            system.debug('@@@VASA Ethernet Available');   
                            if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.requestedSpeed != null){
                                serviceAvailabilityDetailsInst.requestedSpeed = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.requestedSpeed;
                            }else{
                                serviceAvailabilityDetailsInst.requestedSpeed = '';
                            }
                            ethernetInst.lata = Integer.valueof(lata);
                            if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.popCLLI != null){
                                ethernetInst.popCLLI = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.popCLLI;
                            }else{
                                ethernetInst.popCLLI = '';
                            }
                            if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.mileage != null){
                                ethernetInst.mileage = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.mileage;
                            }else{
                                ethernetInst.mileage = '';
                            }
                            if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.maxAvailableSpeed != null){
                                ethernetInst.maxAvailableSpeed = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.maxAvailableSpeed;
                            }else{
                                ethernetInst.maxAvailableSpeed = '';
                            }
                            if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.equipmentType != null){
                                ethernetInst.equipmentType = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.equipmentType;
                            }else{
                                ethernetInst.equipmentType = '';
                            }
                            if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.electricalOptical != null){
                                ethernetInst.electricalOptical = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.electricalOptical;
                            }else{
                                ethernetInst.electricalOptical = '';
                            }
                            if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.availableSpeed != null){
                                ethernetInst.availableSpeed = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.availableSpeed;
                            }else{
                                ethernetInst.availableSpeed = '';
                            }
                            
                            if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.Service.size() > 0){
                                for(AddrValidServAvailResponseBean.Service serviceInstVASA : AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.Service){
                                    AddrValidServAvailResponseBean.Service ethServiceInst = new AddrValidServAvailResponseBean.Service();
                                    ethServiceInst.name = serviceInstVASA.name;
                                    ethServiceInst.switchedDedicated = serviceInstVASA.switchedDedicated;
                                    ethServiceList.add(ethServiceInst);
                                }
                            }
                        }else{
                            system.debug('@@@VASA Ethernet Not Available');                           
                            serviceAvailabilityDetailsInst.requestedSpeed = '1000';
                            
                            if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null){
                                if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && String.isNotBlank(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.popCLLI)){
                                    ethernetInst.popCLLI = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.popCLLI;
                                }else if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.PrivateLine != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.PrivateLine.size()>0){
                                    ethernetInst.popCLLI = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.PrivateLine[0].popCLLI;
                                }else{
                                    ethernetInst.popCLLI = '';
                                }
                            }
                            
                            ethernetInst.maxAvailableSpeed = '1000';
                            ethernetInst.lata = Integer.valueof(lata);         
                            
                            if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.equipmentType != null){
                                ethernetInst.equipmentType = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.equipmentType;
                            }
                            ethernetInst.availableSpeed = '1000';
                            
                            if(siteIdITPAEthernetAvailabilityMap.get(custSite.id).equalsIgnoreCase('true')){
                                AddressServiceAvailabilityList[0].statusCode = 0;
                                AddressServiceAvailabilityList[0].statusMessage = 'Ethernet Service Availability Check Successful';
                                custSite.VASA_Response_Status__c = 'ADDRESS EXACT MATCH';
                            }
                            AddrValidServAvailResponseBean.Service ethServiceInst = new AddrValidServAvailResponseBean.Service();
                            ethServiceInst.name =  'AT&T Switched Ethernet';
                            ethServiceInst.switchedDedicated = 'SWITCHED';   
                            ethServiceList.add(ethServiceInst);
                        }
                        
                        if(!siteIdITPAEthernetAvailabilityMap.get(custSite.id).equalsIgnoreCase('true') || ethernetAvailabilityForSite == false){
                            AddressServiceAvailabilityList[0].statusCode = 4;
                            if(String.isNotBlank(swCLLI)){
                                AddressServiceAvailabilityList[0].statusMessage = 'Ethernet Service Availability - No Data Found for Serving Wire Center '+swCLLI+'. Ethernet service is not available';                 
                            }else{
                                AddressServiceAvailabilityList[0].statusMessage = 'Ethernet Service Is Not Available at this site';
                            }                        
                        }
                                                
                        ethernetInst.Service = ethServiceList;
                        if(ethernetInst.OtherSpeed == null || ethernetInst.OtherSpeed.size() == 0){
                            ethernetInst.OtherSpeed = otherSpeedList;
                        }
                        serviceAvailabilityDetailsInst.Ethernet = ethernetInst;
                        privateLineList.add(privateLineInst);
                        serviceAvailabilityDetailsInst.PrivateLine  = privateLineList;
                        AddressServiceAvailabilityList[0].ServiceAvailabilityDetails = serviceAvailabilityDetailsInst;
                    }
                    else if(String.isBlank(custSite.Alternate_Access_ITPA_Response_Status__c) || String.isBlank(custSite.Alternate_Access_territoryIndicator__c) || custSite.Alternate_Access_ITPA_Response_Status__c != '200' ){
                        system.debug('@@@Removing Ethernet Availability for Out Region Sites: '+custSite.Alternate_Access_ITPA_Response_Status__c);
                        
                        AddrValidServAvailResponseBean.ServiceAvailabilityDetails serviceAvailabilityDetailsInst = new AddrValidServAvailResponseBean.ServiceAvailabilityDetails();
                        AddrValidServAvailResponseBean.Ethernet ethernetInst = new AddrValidServAvailResponseBean.Ethernet();
                        AddrValidServAvailResponseBean.PrivateLine privateLineInst = new AddrValidServAvailResponseBean.PrivateLine();
                        List<AddrValidServAvailResponseBean.PrivateLine> privateLineList = new List<AddrValidServAvailResponseBean.PrivateLine>();
                        List<AddrValidServAvailResponseBean.Service> ethServiceList = new List<AddrValidServAvailResponseBean.Service>();
                        List<AddrValidServAvailResponseBean.OtherSpeed> otherSpeedList = new List<AddrValidServAvailResponseBean.OtherSpeed>();
                        
                        ethernetInst.ethernetAvailability = 'N';

                        if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.requestedSpeed != null){
                            serviceAvailabilityDetailsInst.requestedSpeed = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.requestedSpeed;
                        }else{
                            serviceAvailabilityDetailsInst.requestedSpeed = '';
                        }
                        if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.lata != null){
                            ethernetInst.lata = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.lata;
                        }
                        if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.popCLLI != null){
                            ethernetInst.popCLLI = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.popCLLI;
                        }else{
                            ethernetInst.popCLLI = '';
                        }
                        if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.mileage != null){
                            ethernetInst.mileage = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.mileage;
                        }else{
                            ethernetInst.mileage = '';
                        }
                        if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.maxAvailableSpeed != null){
                            ethernetInst.maxAvailableSpeed = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.maxAvailableSpeed;
                        }else{
                            ethernetInst.maxAvailableSpeed = '';
                        }
                        if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.equipmentType != null){
                            ethernetInst.equipmentType = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.equipmentType;
                        }else{
                            ethernetInst.equipmentType = '';
                        }
                        if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.electricalOptical != null){
                            ethernetInst.electricalOptical = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.electricalOptical;
                        }else{
                            ethernetInst.electricalOptical = '';
                        }
                        if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.availableSpeed != null){
                            ethernetInst.availableSpeed = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.availableSpeed;
                        }else{
                            ethernetInst.availableSpeed = '';
                        }
                            
                        if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.Service.size() > 0){
                            for(AddrValidServAvailResponseBean.Service serviceInstVASA : AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.Service){
                                AddrValidServAvailResponseBean.Service ethServiceInst = new AddrValidServAvailResponseBean.Service();
                                ethServiceInst.name = serviceInstVASA.name;
                                ethServiceInst.switchedDedicated = serviceInstVASA.switchedDedicated;
                                ethServiceList.add(ethServiceInst);
                            }
                        }
                                                
                        ethernetInst.Service = ethServiceList;
                        if(ethernetInst.OtherSpeed == null || ethernetInst.OtherSpeed.size() == 0){
                            ethernetInst.OtherSpeed = otherSpeedList;
                        }
                        serviceAvailabilityDetailsInst.Ethernet = ethernetInst;
                        privateLineList.add(privateLineInst);
                        serviceAvailabilityDetailsInst.PrivateLine  = privateLineList;
                        AddressServiceAvailabilityList[0].ServiceAvailabilityDetails = serviceAvailabilityDetailsInst;
                        AddressServiceAvailabilityList[0].statusCode = 4;
                        AddressServiceAvailabilityList[0].statusMessage = 'Ethernet Service Is Not Available at this site'; 
                    }
                    
                    //Populating Ethernet Related Fields
                    if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet != null){
                        custSite.IsEtherNetAvaiable__c  = true;
                        if(String.isNotBlank(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.maxAvailableSpeed)){
                            custSite.Ethernet_Max_Available_Speed__c = AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.maxAvailableSpeed;
                        }                        
                        if(AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.OtherSpeed != null && AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.OtherSpeed.size() > 0){
                            custSite.Ethernet_Other_Speeds__c = SpecialCharacterConstant.CONCAT;
                            for(AddrValidServAvailResponseBean.OtherSpeed otherspeed : AddressServiceAvailabilityList[0].ServiceAvailabilityDetails.Ethernet.OtherSpeed){
                                if(otherspeed.speed != null && otherspeed.speed != SpecialCharacterConstant.CONCAT){
                                    custSite.Ethernet_Other_Speeds__c = custSite.Ethernet_Other_Speeds__c != SpecialCharacterConstant.CONCAT ? custSite.Ethernet_Other_Speeds__c +','+otherspeed.speed : otherspeed.speed;                                
                                }
                            }
                        }                       
                    }
                    
                    //Populating Lec Name 
                    if((AddressServiceAvailabilityList != null && custSite.Region__c != null && custSite.Region__c == 'IR') || (AddressServiceAvailabilityList != null && AddressServiceAvailabilityList[0].lecname == 'AT&amp;T')){
                        custSite.Access_Vendor_LEC__c = 'AT&T';                       
                    }else if(AddressServiceAvailabilityList != null && String.isNotBlank(AddressServiceAvailabilityList[0].lecname)){
                        custSite.Access_Vendor_LEC__c = AddressServiceAvailabilityList[0].lecname;
                    }
                    
                    system.debug('@@@Ethernet Max Available Speed: '+custSite.Ethernet_Max_Available_Speed__c);
                    system.debug('@@@Ethernet Other Speeds: '+custSite.Ethernet_Other_Speeds__c);
                    system.debug('@@@LEC Name: '+custSite.Access_Vendor_LEC__c );
                    
                    //Marking Site as Service Unavailable if PL and SE are not available after ITPA Call
                    if(String.isBlank(territoryIndicator) && custSite.Region__c != null && custSite.Region__c == 'IR' && ethernetAvailabilityForSite == false && !successCodes.contains(AddressServiceAvailabilityList[1].statusCode) && !BuyflowConstant.POSSIBLEMATCHES.equalsIgnoreCase(custSite.VASA_Response_Status__c)){
                        system.debug('@@@inside Service Unavailable for ITPA');
                        AddressServiceAvailabilityList[0].statusCode = 4;
                        AddressServiceAvailabilityList[0].statusMessage = 'Ethernet Service Is Not Available at this site';
                        custSite.VASA_Response_Status__c = 'SERVICE UNAVAILABLE';
                    }
                    
                    res.AddressServiceAvailability = new List<AddrValidServAvailResponseBean.AddressServiceAvailability>();
                    res.AddressServiceAvailability.add(AddressServiceAvailabilityList[0]);
                    
                    if(AddressServiceAvailabilityList.size() > 1){
                        res.AddressServiceAvailability.add(AddressServiceAvailabilityList[1]);                      
                    }
                    system.debug('@@@AddressServiceAvailabilityList After Merging ITPA: '+AddressServiceAvailabilityList);
                    String finalResponse = JSON.serialize(res);
                    custSite.Service_Availability_Response__c = finalResponse; 
                    system.debug('Final Updated VASA Response: '+finalResponse);              
                }    
                
                //Mark Site as Service Unavailable if both Private Line and Switched Ethernet are not available
                if(((!successCodes.contains(AddressServiceAvailabilityList[0].statusCode) || ethernetAvailabilityForSite == false) && !successCodes.contains(AddressServiceAvailabilityList[1].statusCode) && String.isNotBlank(territoryIndicator) && BuyflowConstant.Y.equalsIgnoreCase(territoryIndicator)) 
                  ||(!BuyflowConstant.Y.equalsIgnoreCase(territoryIndicator) && !successCodes.contains(AddressServiceAvailabilityList[0].statusCode) && !successCodes.contains(AddressServiceAvailabilityList[1].statusCode) && !BuyflowConstant.POSSIBLEMATCHES.equalsIgnoreCase(custSite.VASA_Response_Status__c))){
                    custSite.VASA_Response_Status__c = 'SERVICE UNAVAILABLE';
                    system.debug('@@@Updating Service Unavailable if both PL and SE is not available');
                }
                
                system.debug('@@@Alternate Access ITPA Response Status: '+custSite.Alternate_Access_ITPA_Response_Status__c);
                if(String.isBlank(custSite.Alternate_Access_ITPA_Response_Status__c) || custSite.Alternate_Access_ITPA_Response_Status__c != '200'){
                    custSite.Has_Failed_Request__c = true;
                } 
                else if(String.isNotBlank(custSite.Alternate_Access_ITPA_Response_Status__c) && custSite.Alternate_Access_ITPA_Response_Status__c == '200'){
                    custSite.Has_Failed_Request__c = false;
                    custSite.Site_Failed_Counter__c = 0; 
                }      
                system.debug('@@@Alternate Access ITPA Failed Request: '+custSite.Has_Failed_Request__c);
            }
            update customerSiteList;
            insert attachmentList;      
        } 
        catch(Exception e){
            system.debug('Exception in processFLOWITPAResponseBulk method of FlowITPAContinuationController '+e+' at line no '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
        }
    } 
    
    /*Method to update ITPA failed sites*/
    public void updateFailedCustomerSitesFlag(list<CustomerSite__c> customerSiteList){        
        list<CustomerSite__c> lstCustomerSiteToBeUpdated = new list<CustomerSite__c>();
        if(!customerSiteList.isEmpty()) {
            for(CustomerSite__c failedCustomSite : customerSiteList) {
                if(failedCustomSite.Has_Failed_Request__c == true && String.isNotBlank(failedCustomSite.Alternate_Access_ITPA_Response_Status__c) && failedCustomSite.Alternate_Access_ITPA_Response_Status__c == '200') {
                    failedCustomSite.Has_Failed_Request__c = false;
                    failedCustomSite.Site_Failed_Counter__c = 0; 
                }
                if(failedCustomSite.Has_Failed_API_MACD__c == true && String.isNotBlank(failedCustomSite.Alternate_Access_ITPA_Response_Status__c) && failedCustomSite.Alternate_Access_ITPA_Response_Status__c == '200') {
                    failedCustomSite.Has_Failed_API_MACD__c = false;
                    failedCustomSite.Site_Failed_Counter__c = 0; 
                }
                lstCustomerSiteToBeUpdated.add(failedCustomSite);
            }
        }
        if(!lstCustomerSiteToBeUpdated.isEmpty()){
            update lstCustomerSiteToBeUpdated;
        } 
    } 
}