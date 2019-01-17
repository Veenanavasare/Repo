/************************************************************************************** 
Apex Class Name     : FlowITPAResposnseBean 
Version             : 1.0 
Created Date        : 17 Jan 2017
Function            : Response Bean for AVPN/MIS ITPA Response
*************************************************************************************/
public class FlowITPAResposnseBean{    
    public String id;
    public List<Site> site;    
    
    public class Place{
        public String type;
        public String id;
        public String href;
    }
    
    public class PhysicalResource{
        public String accessType;
        public String availability;
    }
    
    public class ServiceAvailability{
        public List<Service> service;
    }
    
    public class Service{
        public List<Characteristic> characteristic;
        public ServiceSpecification serviceSpecification;
        public String availability;
        public String serviceabilityDate;
        public String id;
        public String href;
        public String name;
    }

    public class ServiceSpecification{
        public String id;
        public String href;
        public String name;
    }

    public class Characteristic {
        public String name;
        public String value;
    }
    
    public class Site {
        public String id;
        public String href;
        public String description;
        public String interactionDate;
        public String interactionDateComplete;
        public String interactionStatus;
        public Place place;
        public List<PhysicalResource> physicalResource;
        public ServiceAvailability serviceAvailability;
    }
}