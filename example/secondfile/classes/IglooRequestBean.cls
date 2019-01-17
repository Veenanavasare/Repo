/************************************************************************************** 
    Apex Class Name     : IglooRequestBean
    Version             : 1.0 
    Created Date        : 22 Jan 2017
    Function            : Request Bean for IGLOO Webservice Call
***************************************************************************************/
public class IglooRequestBean{
    
    public InquireEnterprisePriceQuoteDetailsRequest InquireEnterprisePriceQuoteDetailsRequest;
    
    public class InquireEnterprisePriceQuoteDetailsRequest {
        public DomesticPricePromoQuote DomesticPricePromoQuote;
    }
    
    public class DomesticPricePromoQuote {
        public DomesticAndOther DomesticAndOther;
    }
    
    public class DomesticAndOther {        
        public String quoteRequestType;
        public String service;
        public String accessTransport;
        public String requestedAccessBandwidth;
        public String misPNT;
        public String accessArrangement;
        public String physicalInterface;
        public String contractTerm;
        public String tailTechnology;
        public String accessInterconnect;
        public String accessArchitecture;
        public String circuitQuantity;
        public Integer discountPercentage;
        //public String serviceGuidePublishedDate; 
        public PromotionDetails PromotionDetails;
        public Boolean speedBumpIndicator;
    }
    
    public class PromotionDetails {
        public String lata;
        public Boolean territoryIndicator;
        public String geoTransactionId;
        public String locator;
        public String npaNxx;
        public DateTime responseTime;
        public DateTime acceptAddressTime;
        public DateTime requestTime;
        public RequestedAddress RequestedAddress;
        public MatchDetails MatchDetails;
        public StandardAddress StandardAddress;
        public CustomerGeoLocation CustomerGeoLocation;
        public ILECDetails ILECDetails;
        public List<String> preferredVendors;
        public List<String> avoidVendors;
    }
    
    public class RequestedAddress {
        public String city;
        public String state; 
        public String address;
        public String zipCode;
        public String zipCodeExtension;
    }
    
    public class MatchDetails {
        public String code;
        public String status;
        public String level;
        public String score;
    }
    
    public class StandardAddress {
        public String address;
        public String city;
        public String state; 
        public String streetAddress;
        public String zipCode;
        public String zipCodeExtension;    
    }
    
    public class CustomerGeoLocation {
        public String latitude;
        public String longitude;
        public String horizontalCoordinate;
        public String verticalCoordinate;
    }
    
    public class ILECDetails {
        public String servingWireCenter;
        public String vendorName;
    }
}