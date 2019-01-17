/*************************************************************************************************************** 
Apex Class Name     : ASEITPAServiceAvailResponseBean
Version             : 1.0 
Created Date        : 9 November 2016
Function            : This class handles the state for ASE ITPA Service Availability 
*****************************************************************************************************************/
global class ASEITPAServiceAvailResponseBean extends ASEITPAServiceInfoBean{

    global String ASEITPAResponse;        
    
    global InquireTransportProductAvailabilityResponse InquireTransportProductAvailabilityResponse{get;set;}
    
    global class InquireTransportProductAvailabilityResponse {
        //global Response Response {get;set;} 
        //global String quoteid;
        global String responseStatus;
    } 
    
    //global class Response {
    //    global String code {get;set;}
    //    global String description {get;set;}
    //}    
}