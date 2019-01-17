/************************************************************************************** 
 Apex Class Name     : ATTConstants
 Version             : 1.0 
 Created Date        : 11 Aug 2014
 Function            : This class tracks the constants
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gustavo Restrepo            8/11/2014              Original Version
*************************************************************************************/
public with sharing class ATTConstants {
    
    /*
     * @description: default constructor
     *
     */
    public ATTConstants() {
        system.debug('This constructor is for covering the class from Test Class');
    }

    public static final string Error_in_checkAutoDealRegEnabled = 'Error in checkAutoDealRegEnabled';
    public static final string PostMethod = 'POST';
    public static final string GetMethod = 'GET';
    public static final string JsonContentType = 'application/json';
    public static final String SUCCESS = 'Success';
    public static final String FAILURE = 'Failure';
    public static final String LOGIN_CALLOUT = 'LOGIN_CALLOUT';
    public static final String VALIDATE_PARTNER = 'VALIDATE_PARTNER';
    public static final String VALIDATE_PARTNER_USER = 'VALIDATE_PARTNER_USER';
    public static final String DEAL_REGISTRATION = 'DEAL_REGISTRATION';
    public static final String SPECIAL_PRICING = 'SPECIAL_PRICING';
    
    // Inquire APIs
    public static final String INQUIRE_NETWORK_PRODUCT_CATALOG = 'INQUIRE_NETWORK_PRODUCT_CATALOG';
    public static final String INQUIRE_NETWORK_PRODUCT_PRICE_QUOTE = 'INQUIRE_NETWORK_PRODUCT_PRICE_QUOTE';
    public static final String INQUIRE_NETWORK_PRODUCT_RATE_CARD = 'INQUIRE_NETWORK_PRODUCT_RATE_CARD';
    
    public static final string BUSINESS_ACCOUNT_RT_UNCONVERTED_LEADS = 'Unconverted_Leads';
    public static final string BUSINESS_ACCOUNT_RT_ENABLEMENT_RESOURCE = 'Enablement_Resource';
    public static final string BUSINESS_ACCOUNT_RT_SOLN_PROV_PT_EDIT = 'PT_NonEdit';
    
    public static final String CANCEL_PROVISIONING_ORDER = 'CANCEL_PROVISIONING_ORDER';
    
    //VASA API    
    public static final string VASA_WEBSERVICE = 'VasaWebServiceCall';
    public static final string EXACT_MATCH= 'EXACT MATCH FOUND';
    public static final string CLOSE_MATCH= 'CLOSE MATCH FOUND';
    public static final string NO_MATCH= 'NO MATCH FOUND';
    public static final string ETHERNET_TRANSPORT_TYPE = 'Ethernet';
    public static final string ETHERNET_MAX_SPEED = '1000';
    public static final string PRIVATELINE_TRANSPORT_TYPE = 'PrivateLine';
    public static final string PRIVATELINE_T1 = 'T1';
    public static final string PRIVATELINE_T2 = 'T2'; 
    
    //ITPA Call
    public static final string ITPA_WEBSERVICE = 'ITPAWebServiceCall';
    
    //ASE ITPA Call
    public static final string ASE_ITPA_WEBSERVICE = 'ASEITPAWebServiceCall';
    
    //Esign Call
    public static final string ESIGN_WEBSERVICE = 'EsignWebServiceCall';
        
    // Quote Override
    public static String PRODUCT_INFO = 'productinfo';
    public static String SITE_INFO = 'siteinfo';
    public static String CONF_SITE = 'confsites';
    public static String STATUS = 'Deal Registration Requested';
    
    //Post Buyflow
    public static final List<String> DRAFT_PICKLIST = new List<String>{'Request Deal Registration','Cancel Quote','Duplicate Quote'};
    public static final List<String> DEAL_REG_APR_PICKLIST = new List<String>{'Cancel Quote','Duplicate Quote','Apply Special Pricing'};
    public static final List<String> DEAL_REG_REQ_PICKLIST = new List<String>{'Cancel Pending Deal Registration'};
    public static final string QUOTE_PENDING_DEAL_REG = 'Pending Deal Reg';
    public static final string QUOTE_DEAL_REG_APPROVED = 'Deal Reg Approved';
    public static final string OPPTY_DEAL_REG_APPROVED = 'Deal Registration Approved';
    public static final string OPPTY_DEAL_REG_AUTO_APPROVED = 'Deal Reg Auto-Approved';
    public static final string OPPTY_DEAL_REG_DELETED = 'Deal Registration Deleted';
    public static final string QUOTE_PRICING_SCHEDULE_REQUESTED = 'Pricing Schedule Requested';
    public static final string QUOTE_TSC_REVIEW_REQUESTED = 'TSC Review Requested';
    public static final string QUOTE_DELETED = 'Deleted';
    
    //Atom Dashboard
    public static String DATE_FORMAT = 'MM-dd-yyyy';
    public static String TIME_ZONE = 'America/Chicago';    
    // Method which stores the value from Custom Setting - ConstantHelper__c into constantMap
    
    //Test Method Parameter
    public static String methodToCallInPartnervaliate = '';
    public static String methodToCallInDealRegistration = '';
    public static String methodToCallInSpecialPricing = '';
    public static String methodToCallInATTATOMLogin = '';
    
    //AIA Service Availability API
    public static final string AIA_WEBSERVICE= 'AIAwebServiceCall';
    
    //Adopt Hosting API
    public static final string ADOPTHOSTING_WEBSERVICE= 'AdoptHostingwebServiceCall';
    
     
    //Batch Execution Message
    public static final string BATCH_ADMIN_EMAIL = 'kumgaurav@deloitte.com';
    public static final string ADMIN_AT = '@';
    public static final string EMAIL_SEPERATOR= ',';
    
    //Login Dispatch API
    public static final string LOGIN_DISPATCH = 'LoginDipatchCall';
    
    //Buy Flow
    public static final string SPAN = 'display:inline-block; color:green;';
    public static final string SPANNONE = 'display:none; color:green;';
    public static final string CONF = 'Configured';
    public static final string NOT_CONF = 'NotConfigured';
    public static final string ADD_SITES = 'Add Sites';
    public static final string CONFIGURE_SITES = 'Configure Sites';
    public static final string SWITCHETHER = 'Switched Ethernet'; 
    public static final string PRIVATELINE = 'Private Line';
    public static final string PRIVATES = 'Private';
    public static final string PRODSERV = 'Product/Service';
    public static final string ADD_DNS = 'Additional DNS';
    public static final string OPTIONS = 'Options';
    public static final string IP_FLEX = 'IP Flex Plan';
    public static final string OtherIP_FLEX = 'Other IP Flex Options';
    public static final string IP_FLEX_REACH = 'IP Flex Reach';
    public static final string QUOTEID = 'quoteId';
    public static final string VLAN = 'VLAN(s)/Logical Channel';
    public static final string MANAGED_ROUTER = 'Managed Router';
    public static final string HI_CAP_FLEX = 'Hi-Cap Flex';
    public static final string ADD = 'ADD';
    public static final string ALL = 'All';
    public static final string ASES = 'ASES';
    public static final string AMIS = 'AMIS';
    public static final string AVPN = 'AVPN';
    public static final string DELETES = 'DELETE'; 
    public static final string BASIC = 'Basic';  
    public static final string COS = 'CoS';
    public static final string FILTER = 'Filter Sites';
    public static final string MODE = 'mode';
    public static final string SITEINFO = 'siteinfo';
    public static final string PORT_TYPE = 'Port Type';
    public static final string PORT_SPEED = 'Port Speed';
    public static final string DSELECT = 'select';
    public static final string ACCESS_SPEED = 'Access Speed';
    public static final string ACCESS_TYPE = 'Access Type';
    public static final string INTERFACE_TYPE = 'Interface Type';
    public static final string INSTALLATION_OPTIONS = 'Installation Options';
    public static final string MIN_BANDWIDTH_COM = 'Minimum Bandwidth Commitment';
    public static final string SERVING_ARRANGEMENT = 'Serving Arrangement';
    public static final string CLASS_OF_SERVICE_BASIC = 'Class of Service';
    public static final string CLASS_OF_SERVICE_PACKET = 'Class of Service (Per Packet)';
    public static final string CLASS_OF_SERVICE = 'Class of Service';
    public static final string CIR = 'CIR';
    public static final string MAC_LIMIT = 'MAC Limit';
    public static final string CON_SPEED = 'Connection Speed';
    public static final string IP_ADD = 'IP Addresses';
    public static final string AIA_CHARGES = 'AIA One TIme Charges';
    public static final string AIA_INSTALL = 'AIA Installation';
    public static final string SAVED = 'SAVED';
    public static final string PENDING = 'PENDING';
    public static final string COMPLETE = 'Complete';
    public static final string COMPLETED = 'Completed';
    public static final string FINALIZED = 'Finalized';
    public static final string NE_W = 'New';
    public static final string ELECTRICAL = 'ELECTRICAL';
    public static final string T1 = 'T1';
    public static final string MBPS = 'Mbps';
    public static final string CONFIG_SITE_ERROR_MSG = ' has not been configured for ';
    public static final string CONFIG_SITE_PRICING_ERROR_MSG = 'We are currently unable to price your order. Please retry or contact your Channel Account Manager for ';
    public static final string ETHER_HUB_SPOKE = 'Ethernet Virtual Private Line (Hub-and-Spoke)';
    public static final string VASA_JSON_ERROR = 'Vasa json request is empty';
    public static final string GRAND_TOTAL = 'Grand Total';
    public static final string TRU_E = 'TRUE';
    public static final string FALS_E = 'FALSE';
    
    //Test Class Variable
    public static string VASA_NEAR_MATCH = '';
    public static string SUBMIT_QUOTE = 'Submit Quote';
    public static final string DEFAULT_STRING = 'default';
    public static final string TECHNICAL_REVIEW_REQUESTED = 'Technical Review Requested';
    public static final string TECHNICAL_REVIEW_DENIED = 'Technical Review Denied'; 
    public static final string TECHNICAL_REVIEW_APPROVED = 'Technical Review Approved';
    public static final string RECONFIGURE_STRING = 'Reconfigure';
    public static final string DENIED_STRING = 'Denied';
    public static final string APPROVED_STRING = 'Approved';
    public static final string PENDING_STRING = 'Pending'; 
    public static final string ORDER_SUBMITTED = 'Order Submitted';           
    //RDSDerivedFieldMapping variables
    public static string CUSTOMERTYPE = 'CUSTOMER';
    public static string BILLINGTYPE = 'BILLING';
    public static string TECHNICALTYPE = 'TECHNICAL';
    public static string TECHFIRSTNAME= 'EBM';
    public static string TECHLASTNAME = 'Ops';
    public static string TECHPHONE = '8552778686';
    public static string TECHEMAIL = 'DL-EBM_SD@att.com';
    public static string SOLUTION_PROVIDERTYPE= 'SOLUTION_PROVIDER';
    public static string PRI_BILLINGTYPE = 'Primary Billing Contact';
    public static final string MANUAL_STRING = 'Manual';
    public static final string ASE_BB = 'ASE Broadband';
    public static final string ASE_Basic = 'ASE Basic';
    public static final string BAN_Check = 'BAN Check';
    public static final string CHECKED = 'Checked';
    public static final string CNUMTYPE = 'CNUM Type';
    public static final string Service_Type = 'Service Type';
    public static final string PortSpeed = 'Port Speed';
    public static final string Tech_Field = 'ASE Basic CIR Downstream Mbps Speed';
    public static final string Tech_Field2 = 'ASE Broadband CIR Downstream Mbps Speed';
    public static final string Network_Type = 'Network Type';
    public static final string LATA_STRING = 'LATA';
    public static final string Config_Type = 'Config Type';
    public static final string Site_Designation = 'Site Designation';
    public static final string P_VLAN = 'Port/VLAN Based';
    public static final string MAC_ADD = 'MAC Addresses';
    public static final string HD = 'Hard Disconnect';
    public static final string HARD_STAT = 'hard';
    public static final string CUSTOMERSIGNED = 'CustomerSigned';
    public static final string SUPPLIERSIGNED = 'SupplierSigned';
    public static final string CUSTOMERREJECTED = 'CustomerRejected';
    public static final string PRIMARY = 'Primary';
    public static final string SECONDARY= 'Secondary';
    public static final string ACCESS_SPEED_MILEAGE_FEE ='Access Speed Mileage Fee';
    public static final string ONEYR = 'ONEYR';
    public static final string ONE_YEAR = '1 Year';
    public static final string THREEYR= 'THREEYR';    
    public static final string THREE_YEAR= '3 Year';    
    public static final string CHANGE_LOWER = 'change';
    public static final string ADD_LOWER = 'add';
    public static final string REMOVE_LOWER = 'remove';  
    public static final string ONSITE_INSTALL= 'Onsite Install';  
        
    public static final string RECORD_TYPE_MC = 'Master Rate Card';
    //RDSValidationTriggerHandler References
    public static Boolean recursiveCheckOnRDSValidationTriggerHandler = false;
    
    //check CI error for MD5 password encryption
    public static Boolean isCIError = false;
    
    //Constants for ASEOrderingFactSheetController haeman superman
    //Constants for ASEOrderingFactSheetController
    public static string EMPTY = '';
    public static string ASRWebAccessOrdering = 'https://access-os2.att.com/waoWeb/loginDisplay.do';
    public static string ASEServiceGuide = 'https://www.att.com/partnerexchange/support/contractDocLibrary.jsp';
    public static string portalURL = 'www.att.com/partnerexchange';
    public static string ProductType = 'Network Services';
    public static string ProductName = 'AT&T Switched Ethernet Service';
    /*Sprint 35 ACC Siteconfigure*/
    public static final String SITE_REVIEWREQUIREDVAL = 'ReviewRequired';
    public static final String SITE_REVIEWREQUIREDLABEL = 'Review Required';
    
}