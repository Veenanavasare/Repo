/************************************************************************************** 
 Apex Class Name     : Apex2JSON_AddrValidServAvail
 Version             : 1.0 
 Created Date        : 11 Aug 2014
 Function            : This class handles the state for address validation and service availability web service 
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gustavo Restrepo            8/11/2014              Original Version
* Md Khalid Munavar Ali       8/19/2014          Updated Data types
*************************************************************************************/
public with sharing class AddrValidServAvailInformationBean extends ATTServiceInfoBean {

    public class Zip {
        public string zipCode;//Required, 5 Characters
        public string zipCodeExtension;//Optional
        public string zipGeoCode;//Optional
    }
    
    public class Address {
        public string street;//Required
        public string city;//Optional
        public string county;//Optional
        public string urbanization;//Optional
        public string state;//Optional
        public Zip Zip;
        public string Country;//Optional
    }
    
    public class Speed {
        public string speedName;//Optional
        public string speedPhysicalValue;//Required
        public string speedUnit;//Optional
    }
    
    public class ServiceAvailability {
        public string transportType;//Values Ethernet Private Line
        // Rule - List, max size = 4
        public List<Speed> Speed;
        public string quantity;//Optional
    }
    
    public class AddressDetails {
        public Address Address;
        public ServiceAvailability ServiceAvailability;
        public string sfdcId;
    }
        
    public class ValidateAddressServiceAvailabilityRequest {
        public string mode;// Values 'A' and 'B'
        public boolean nearMatchIndicator;//Optional, default true
        public boolean displayAllSpeeds;//Optional, default false
        // Rule - List, max size = 6
        public List<AddressDetails> AddressDetails;
        public string sfdcQuoteId;
    }

    public class SecurityHeader {
        public String clientId;
        public String authToken;
    }
    
    public String version;
    public SecurityHeader SecurityHeader;
    public ValidateAddressServiceAvailabilityRequest ValidateAddressServiceAvailabilityRequest;
    //public List<ValidateAddressServiceAvailabilityRequest> ValidateAddressServiceAvailabilityRequest;

}