/************************************************************************************** 
    Apex Class Name     : IglooResponseBean
    Version             : 1.0 
    Created Date        : 22 Jan 2017
    Function            : Response Bean for IGLOO Webservice Call
***************************************************************************************/

public class IglooResponseBean{

    public String code;
    public String description;
    public String error;
   
    public InquireEnterprisePriceQuoteDetailsResponse InquireEnterprisePriceQuoteDetailsResponse;
    
    public class InquireEnterprisePriceQuoteDetailsResponse{
        public DomesticPricePromoQuoteResponse DomesticPricePromoQuoteResponse;
        public Response Response;
    }
    
    public class DomesticPricePromoQuoteResponse {
        public String url;
        public String service;
        public String onNetCheckFlag;
        public String availability;
        public String misPNT;
        public String accessArrangement;
        public String leadTime;
        public String portLevelClassOfServiceFlag;
        public String accessInterconnect;
        public String tailTechnology;
        public String technology;
        public String physicalInterface;
        public CustomerDetails CustomerDetails;
        public MatchDetails MatchDetails;
        public Bandwidth Bandwidth;
    }
    
     public class CustomerDetails{
         public String addressLineOne;
         public String city;
         public String state;
         public String zipCode;   
         public String zipCodeExtension;
         public String country;
         public String telephoneNumber;
         public GeoLocation GeoLocation;
    }
    
    public class GeoLocation {
        public String latitude;
        public String longitude;  
    }
    
    public class MatchDetails {
        public String status;
        public String level;
        public String score;
    }
    
    public class Bandwidth {
        public String requestedAccessBandwidth;
        public String accessBandwidth;
        public String requestedAccessArchitecture;
        public String accessArchitecture;
        public String accessType;
        public String errorMessage; 
        public ContractDetails ContractDetails;
    }
    
    public class ContractDetails{
        public String contractTerm;
        public String accessTransport;
        public String coverage;
        public String quoteQualification;
        public String architectureMetFlag;
        public String bandwidthMetFlag;
        public String vendorPreferenceMetFlag;
        public String serviceGuideEligibleFlag;
        public String serviceGuidePublishedDate;
        public String pricingZone;
        public String circuitQuantity;
        public String ethernetInterOfficeConnect;
        public String internationalTelecomUnionCarrierCode;
        public String supplierName;
        public String providerProductName;
        public String pointOfPresenceCLLI;
        public String ILECServiceWireCenter;
        public String clecLNSServingWireCentreCLLI;
        public String vendorPreferenceRequestedFlag;
        public String discountPercentage;
        public String baseMonthlyPriceLocal;
        public String monthlyPriceLocal;
        public String oneTimePriceLocal;
        public String baseMonthlyPriceUSD;
        public String monthlyPriceUSD;
        public String oneTimePriceUSD;
        public String localCurrency;
        public String standardEthernetAccessPricingSerialNumber;
        public String tokenId;
        public String serialNumber;
        public String quoteRequestDate;
        public String daysUntilQuoteExpires;
        public String quoteExpirationDate;
        public String customerMaximumTransmittedUnit;
        public String providerMaximumTransmittedUnit;
        public String maximumTransmittedUnitSupportMessage;
    }
    
    public class Response {
        public String code;
        public String description;
    } 
}