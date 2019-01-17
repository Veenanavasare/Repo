/************************************************************************************** 
 Apex Class Name     : ITPAServiceAvailInfoBean 
 Version             : 1.0 
 Created Date        : 1st March 2016
 Function            : Class that handles the state for ITPA Service Availability Call
*************************************************************************************/

public with sharing class ITPAServiceAvailInfoBean extends ITPAServiceInfoBean {

     public class UnfieldedAddress {
        public string addressLine1;//Required
        public string addressLine2;//Optional
        public string city;//Optional
        public string state;//Optional
        public string postalCode;//Optional
        public string postalCodePlus4;//Optional
        public string county;//Optional
        public string country;//Optional
        public string structureType;//Optional
        public string structureValue;//Optional
        public string levelType;//Optional
        public string levelValue;//Optional
        public string unitType;//Optional
        public string unitValue;//Optional
        public string additionalName;//Optional
        public string crossStreet;//Optional
        public string serviceId;//Optional
    }
    
    public class Telephone {
        public string attTelephoneNumber;//Required
    }
     
    public class Address {        
        public string siteId;
        public UnfieldedAddress UnfieldedAddress;
        public Telephone Telephone;
    }
        
    public class InquireTransportProductAvailabilityRequest {
        public string quoteId;
        public List<Address> Address;        
    }

    public InquireTransportProductAvailabilityRequest InquireTransportProductAvailabilityRequest;
}