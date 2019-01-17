/************************************************************************************** 
Apex Class Name     : ASEITPAResponseBean
Version             : 1.0 
Created Date        : 21 Nov 2016
Function            : Response Bean for ASE ITPA Response
*************************************************************************************/

public class ASEITPAResponseBean{

     public class Status {
           public String code;
           public String description;
     }

     public class FieldedAddress {
           public String houseNumber;
           public String streetName;
           public String streetThoroughfare;
           public String city;
           public String state;
           public String postalCode;
           public String postalCodePlus4;
           public String county;
           public String country;
           public String singleLineStandardizedAddress;
     }

     public class LocationProperties {
           public String cityStatePostalCodeValidFlag;
           public String convergedBillingAvailabilityFlag;
           public Coordinates Coordinates;
           public String coreBasedStatisticalAreaCode;
           public String gisLocationCode;
           public String gisMatchCode;
           public String locator;
           public String matchLevel;
           public String matchStatus;
           public String superScore;
     }

     public class Coordinates {
           public String latitude;
           public String longitude;
     }

     public class GISLocationAttributes {
           public FieldedAddress FieldedAddress;
           public String addressType;
           public LocationProperties LocationProperties;
     }

     public class HostResponse {
           public Status Status;
           public String hostName;
           public String MatchStatus;
           public Status enterpriseGeocodingModuleStatus;
     }

     public class MultiProductAvailability {
           public Location Location;
     }

     public class Location {
           public List<GISLocationAttributes> GISLocationAttributes;
           public List<HostResponse> HostResponse;
     }

     public class InquireTransportProductAvailabilityResponse {
           public MultiProductAvailability MultiProductAvailability;
     }
     
     public InquireTransportProductAvailabilityResponse InquireTransportProductAvailabilityResponse;
}