/********************************************************************************************* 
 Apex Class Name     : ITPAServiceAvailResponseBean
 Version             : 1.0 
 Created Date        : 1st March 2016
 Function            : Class that handles the state for ITPA Service Availability Web Service
 
**********************************************************************************************/

global class ITPAServiceAvailResponseBean extends ITPAServiceInfoBean{

    global List<InquireTransportProductAvailabilityResponse> InquireTransportProductAvailabilityResponse{get;set;}
   
    global String JSONResponse;
   
    global class InquireTransportProductAvailabilityResponse {
        global ProductVoiceOverIP ProductVoiceOverIP {get;set;}
        global FieldedAddress FieldedAddress{get;set;}
        global Response Response {get;set;} 
        global String quoteid;
        global String siteid;
    }
    
    global class ProductVoiceOverIP {
        global VoiceOverIPServiceAvailability VoiceOverIPServiceAvailability{get;set;}
    }
    
    global class VoiceOverIPServiceAvailability {
        global String rateCenter{get;set;}
        global String rateCenterState{get;set;}
        global String numberAvailabilityIndicator{get;set;}
        global String lnsSwitchCLLI{get;set;}
        global String numberPortabilityIndicator{get;set;}
        global String voipAvailabilityFlag{get;set;}
        global String voipE911AvailabilityFlag{get;set;}
        global String voipLocalAvailabilityFlag{get;set;}
        global String vdnasbaAvailabilityIndicator{get;set;}
        global String e911AvailabilityFlag{get;set;}
        global String virtualTNAvailabilityIndicator{get;set;}
        global String ipldAvailabilityIndicator{get;set;}
        global String trinityAvailabilityIndicator{get;set;}
        global String taxGeoCode{get;set;}
    }
    
    global class Response {
        global String code {get;set;}
        global String description {get;set;}
    }
    
    global class FieldedAddress {
        global String houseNumber{get;set;}
        global String streetDirection{get;set;}
        global String streetName{get;set;}
        global String streetThoroughfare{get;set;}
        global String streetNameSuffix{get;set;}
        global String city{get;set;}
        global String state{get;set;}
        global Integer postalCode{get;set;}
        global String county{get;set;}
        global String country{get;set;}
        global String singleLineStandardizedAddress{get;set;}
    }
}