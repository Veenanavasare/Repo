/************************************************************************************** 
Apex Class Name     : AddrValidServAvailResponseBean
Version             : 1.0 
Created Date        : 27 Aug 2014
Function            : This class  state for address validation and service availability web service 
Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Md Khalid Munavar Ali       8/25/2014              Original Version
*************************************************************************************/
global class AddrValidServAvailResponseBean extends ATTServiceInfoBean {

  //to store the raw json Response
  global String JSONResponse;        

  global List<AddressServiceAvailability> AddressServiceAvailability{get;set;}
  global Response Response {get;set;}   
  global String sfdcQuoteId;   
  global String conversationId;     
  global String messageId;     

  global class Response {
    global String code {get;set;}
    global String description {get;set;}
  }

  global class PrivateLine {
    global String popCLLI {get;set;}
    global String speed {get;set;}
    global Integer spareQuantity {get;set;}
    global string mileage {get;set;}    
  }

  global class ExistingConnectivity {
    global String copperFiber {get;set;}
    global String currentMaxSpeed {get;set;}
  }

  global class OtherSpeed {
    global String speed {get;set;}
    global String electricalOptical {get;set;}
    global Integer networkType {get;set;}
  }

  global class Service {
    global String name {get;set;}
    global String switchedDedicated {get;set;}
  }

  global class Ethernet {
    global String popCLLI {get;set;}
    global String ethernetAvailability {get;set;}
    global Integer lata {get;set;}
    global String maxAvailableSpeed {get;set;}
    global String availableSpeed {get;set;}
    global List<Service> Service {get;set;}
    global List<OtherSpeed> OtherSpeed {get;set;}
    global ExistingConnectivity ExistingConnectivity {get;set;}
    global String electricalOptical {get;set;}
    global String equipmentType {get;set;}
    global String mileage {get;set;}
  }

  global class Geocode {
    global Double latitude {get;set;}
    global double longitude {get;set;}
  }

  global class Zip {
    global string zipCode {get;set;}//Max 5 Characters
    global string zipCodeExtension {get;set;}//Optional
    global string zipGeoCode {get;set;}//Optional
  }

  global class RequestedAddressDetails{
    global string street {get;set;}
    global string city {get;set;}//Optional
    global string county {get;set;}//Optional
    global string urbanization {get;set;}//Optional
    global string state {get;set;}//Optional
    global Zip Zip {get;set;}
    global string Country {get;set;}
  }

  global class AddressMatchDetails{
    global string street {get;set;}
    global string city {get;set;}//Optional
    global string county {get;set;}//Optional
    global string urbanization {get;set;}//Optional
    global string state {get;set;}//Optional
    global Zip Zip {get;set;}
    global string Country {get;set;}
  }

  global class AddressServiceAvailability {
    global RequestedAddressDetails RequestedAddressDetails {get;set;}
    global List<AddressMatchDetails> AddressMatchDetails {get;set;}
    global Geocode Geocode {get;set;}
    global String addressMatchCode {get;set;}
    global String lecName {get;set;}
    global String sfdcId {get;set;}
    global String region {get;set;}
    global String swcClli {get;set;}
    global String locationClli {get;set;}
    global ServiceAvailabilityDetails ServiceAvailabilityDetails {get;set;}
    global Integer statusCode {get;set;}
    global String statusMessage {get;set;}
    global String csiMessageId{get;set;}
    global String csiConversationId{get;set;}
    global String csiUniqueTrackingId{get;set;}
  }

  global class ServiceAvailabilityDetails {
    global String requestedSpeed {get;set;}
    global Ethernet Ethernet {get;set;}
    global List<PrivateLine> PrivateLine {get;set;}
  }          
}