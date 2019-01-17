/************************************************************************************** 
Apex Class Name     : FlowITPARequestBean
Version             : 1.0 
Created Date        : 17 Jan 2017
Function            : Response Bean for AVPN/MIS ITPA Response
*************************************************************************************/
global class FlowITPARequestBean {

    public String id;
    public List<Site> site;
    
    public FlowITPARequestBean(){}
    
    public FlowITPARequestBean(String id, List<Site> site){
        this.id = id;
        this.site = site;
    }   
    
    public class Site{
        public String id;
        public Place place;
        public List<PhysicalResource> physicalResource;
    }
    
    public class Place{
        public String type;
        public location Location;
    }
    
    public class location{
        public locationOptions LocationOptions;
    }
    
    public class locationOptions{
        public unfieldedAddress UnfieldedAddress;
    }    
    
    public class unfieldedAddress {
        public String addressLine;
        public String city;
        public String state;
        public String postalCode;
        public String postalCodePlus4;
        public String county;
    }
    
    public class PhysicalResource {
        public  String accessType;
        public PhysicalResource(){}
        public PhysicalResource(String accessType){
            this.accessType = accessType;
        }
    }
}