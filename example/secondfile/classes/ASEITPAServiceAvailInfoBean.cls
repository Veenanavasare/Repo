/******************************************************************************************************************
 Apex Class Name     : ASEITPAServiceAvailInfoBean 
 Version             : 1.0 
 Created Date        : 12 November 2016
 Function            : This class handles the state for ASE ITPA Service Availability 
*******************************************************************************************************************/
public with sharing class ASEITPAServiceAvailInfoBean extends ASEITPAServiceInfoBean{
    
    public class additionalRequestData {
        public String productType;
        public boolean fiberCheckIndicator;
        public boolean aseLSCheckIndicator;
        public boolean aseCopperCheckIndicator;
    }
    
    public class ase {
        public boolean aseIndicator;
        public additionalRequestData additionalRequestData;
    }
    
    public class requestedProducts {
        public ase ase;
    }
    
    public class validationOptions {
        public Integer glidLookup;
        public Integer maxAlternativeReturn;
    }
    
    public class unfieldedAddress {
        public String addressLine;
        public String structureValue;
        public String levelValue;
        public String unitValue;
        public String city;
        public String state;
        public String postalCode;
    }

    public class locationOptions {
        public unfieldedAddress unfieldedAddress;
    }
    
    public class location {
        public locationOptions locationOptions;
        public validationOptions validationOptions;
    }
    
    public class addresses {
        public String siteId;
        public location location;
        public requestedProducts requestedProducts;        
    }
    
    public class InquireTransportProductAvailabilityRequest {
        public string quoteId;
        public List<addresses> addresses;        
    }

    public InquireTransportProductAvailabilityRequest InquireTransportProductAvailabilityRequest;

}