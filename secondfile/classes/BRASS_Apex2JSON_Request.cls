/************************************************************************************** 
 Apex Class Name     : BRASS_Apex2JSON_Request
 Version             : 1.0 
 Created Date        : 20 NOV 2014
 Function            : This class handles the state for BRASS Request Bean
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sunil Kumar       11/20/2014             Original Version
*************************************************************************************/
public with sharing class BRASS_Apex2JSON_Request extends ATTServiceInfoBean{
    
    public String Synchronous;  
    public List<PreQualifyRequest> PreQualifyRequest;
    public class PreQualifyRequest {
        public String Type; 
        public OfferType OfferType;
        public String CustomerType; 
        public String ConversationID;   
        public String AddrMatchCode;    
        public String OnlineOrderingInd;
        public String AddressParse; 
        public String ServiceRetainedInd;
        public Address Address;
        public String PromoCode;    
    }
    public class OfferType {
        public String UserType; 
    }
    public class Address {
        public String Street1;   
        public String Street2;
        public String City; 
        public String State;
        public String Zip;
        public String Country;
        public String Region;
        public String Telephone;
        public String Facsimile;
        public String Email;
        public String Url;
        public String Internet; 
    }
 }