/************************************************************************************** 
 Apex Class Name     : ATT_Constant
 Version             : 1.0 
 Created Date        : 13 Oct 2014
 Function            : This class tracks the constants
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sunil Kumar            10/13/2014              Original Version
*************************************************************************************/
public with sharing class ATT_Constant {

    /*
     * @description: default constructor
     *
     */
    public ATT_Constant() {
        system.debug('This constructor is for covering the class from Test Class');
    }
    
    // ProductInformation 
    public static final string CONFIG_TYPE = 'Bundle';
    public static final string TERM_1YEAR = '1 Year';
    public static final string TERM_3YEAR = '3 Years';
    
    // Register Deal
    public static final string ACCESS_SPEED ='Access Speed';
    public static final string PORT_SPEED ='Port Speed';
    public static final string COS ='CoS';
    public static final string OPP_STAGE = 'Deal Registration Requested';
    public static final string OPP_CANCELSTAGE = 'Cancelled';
    public static final string INSTALLATION_TYPE = 'Installation Types';
    public static final string TELE_INSTALL = 'Tele Install';
    // added by Ravitej Varada: Start
    public static final string IP_FLEX_REACH_PLAN='IP Flex Reach Plan';
    public static final string VTN_FEE='VTN Fee';
    public static final string VOIP='VoIP';
    public static final string SETUP_FEE='Setup Fee';
    public static final string ENHANCED_FEATURES='Enhanced Features';
    // Added by Ravitej Varada: End
    
    //  Access Speed - Switch Ethernet pricing based on VASA response
     public static final string OUT_REGION_1 = 'Out of Region 1';
     public static final string OUT_REGION_1A = 'Out of Region 1A';
     public static final string OUT_REGION_2 = 'Out of Region 2';
     public static final string OUT_REGIONLine_1 = 'OO1';
     public static final string OUT_REGIONLine_1A = 'OO1A';
     public static final string OUT_REGIONLine_2 = 'OO2';
     
     // Quote Status values    
     public static final string SPECIAL_PRICING_REQUESTED = 'Special Pricing Requested';
     public static final string SPECIAL_PRICING_APPROVED = 'Special Pricing Approved';
     public static final string DEAL_REG_REQUESTED = 'Deal Registration Requested';
     public static final string DEAL_REG_APPROVED = 'Deal Reg Approved';
     public static final string SPECIAL_PRICING_DENIED = 'Special Pricing Denied';
     public static final string DEAL_REG_CANCELLED = 'Deal Registration Cancelled';
     public static final string APPLY_SPECIAL_PRICING = 'Apply Special Pricing';
     public static final string DELETED = 'Deleted';
     public static final string PENDING_ADDI_SITE_DET = 'Pending Additional Site Details';
     public static final string ORDER_SUBMITTED = 'Order Submitted';
     public static final string Q_PRICING_SCHEDULE_REQUESTED = 'Pricing Schedule Requested';
     public static final string Q_PRICING_SCHEDULE_APPROVED = 'Pricing Schedule Approved';
     public static final string CANCELLED = 'Cancelled';
     public static final string TSCREVIEW = 'TSC Review Confirmed';
     
     //Opportunity Stage Values
     public static final string OPP_DEAL_APP = 'Deal Registration Approved';
     public static final string OPP_DEAL_DEN = 'Deal Registration Denied';
     public static final string OPP_DEAL_DEL = 'Deal Registration Deleted';
     public static final string OPP_PRICING_SCHEDULE_REQUESTED = 'Pricing Schedule Requested';
     public static final string OPP_PRICING_SCHEDULE_APPROVED = 'Pricing Schedule Approved';
     public static final string OPP_ORDER_SUBMITTED = 'Order Submitted';
     
     // Special Pricing related values
     public static final string ONE_COMPETITOR = 'One Competitor Selected';
     public static final string MANY_COMPETITORS = 'Many Competitors Selected';
     public static final string ONE_PROVIDER = 'One Provider Selected';
     public static final string MANY_PROVIDERS = 'Many Providers Selected';
     
     // Product Configuration Stage
     public static final string STATUS = 'Finalized';
     public static final string SAVEDSTATUS = 'SAVED';
     public static final string NEWSTATUS='New';
     public static final string FREQUENCYONE ='One Time';
     public static final string FREQUENCYMONTHLY = 'Monthly';
     public static final string SUBTOTAL = 'Subtotal';
     public static final string TOTAL = 'Total';
     public static final string GRANDTOTAL = 'Grand Total';
     
     //QuoteLine Item 
     public static final string PRICETYPE = 'Recurring';
     public static final string ONETIMEPRICE = 'One Time';
     public static final string PRODUCTSERVICE = 'Product/Service';
     public static final string MINBANDWIDTH = 'Minimum Bandwidth Commitment';
     
     //Product Pricing
     public static final string MRCTYPE='MRC';
     public static final string NRCTYPE = 'NRC';
     
     // SP Product 
     public static final string ObjectApi = 'SPProduct__c';
     
     //MACD
     public static final string ADDSITES = 'Add Sites';
     
     // Product Name.
     
     public static final string AVPN = 'AT&T Virtual Private Network';
     public static final string VLAN = 'VLAN(s)/Logical Channel';
     public static final string ATTMIS= 'AT&T Managed Internet Service';
     public static final string ATTASE= 'AT&T Switched Ethernet Service';
     public static final string HcapFlex= 'Hi-Cap Flex';
     public static final string MANAGDROUTER= 'Managed Router';
     
     // Product Code
     Public static boolean isRecurcive=true;
     public static final string MIS = 'MIS';
     public static final string AMIS = 'AMIS';
     public static final string ASES= 'ASES';
     public static final string ASE= 'ASE';
     public static final string PRIVATECLOUD= 'PRIVATECLOUD';
     public static final string PC= 'PC';
     public static final string Colocation= 'Colocation';
     public static final string Colo= 'Colo';
     public static final string Sta ='StaaS';
     public static final string STAAS='STAAS';
     public static final string CAAS = 'CAAS';
     public static final string Ca= 'CaaS';
     public static final string Ani = 'Anira';
     public static final string ANIRA= 'ANIRA';
     public static final string A_VPN= 'AVPN';
     public static final string VPN= 'VPN';
     public static final string AIA= 'AIA';
     public static final string BROAD = 'Broadband';
     // RDS values
     public static final string RDSASNRANGES = '65000,65001,65002,65003,65004';
     
     public static final string COUNTERSIGNER_NAME = 'CounterSigner';
     public static final string COUNTERSIGNER_EMAIL = 'countersigner123@att.com';
	 public static final string SITE_ADDRESS_TEMPLATE_NAME = 'SiteAddressUploadTemplate_New';
     public static final string EMAIL_TEMPLATE_SP = 'Contact_Us_SP_Email_Template';	 
     public static final string EMAIL_TEMPLATE_EBM = 'Contact_Us_EBM_Email_Template';	 
	 public static final string VLAN_LOGICAL = 'Vlan Logical';
	 public static final string ACCEPTED_STRING = 'Accepted';
}