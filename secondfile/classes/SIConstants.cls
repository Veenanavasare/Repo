//A Constant Class, no method implementations should go here
public  class SIConstants {
    
    public static boolean isControl = true;
    public static boolean isControlOTC = true; //OTC discounted price
    public static boolean isBreak = true;
    public static boolean isControlDC = true; //discounted price
    public static boolean isControlCLP = true; //Cumulative list price
    public static boolean isControlListPrice = true; //Cumulative list price after insert
    public static boolean isControlOTCPrice = true; 
    public static boolean isControlOTConOppty = true; //Cumulative OTC On product Update
    public static boolean isDealRegApproval = false;
    public static boolean isClearSpecialpricing= true;
    public static boolean removeSpecialpricing= true;
    public static boolean applyPromotions= true; //To Control Recursive calls.
    public static boolean avoidrecursivecallOnHelper = true;
    public static boolean reapplyPromotions = true;
    public static boolean dealRegPromotions = true;
    public static boolean inRegionRecursive = true;
    public static boolean isDisplaySucessMsg = false;// To ATOM ManagerUsersController
    public static boolean recursiveCheckOnVLANDetails = true;//To avoid recursive ckeck on oppotunity VLANDetails 
    public static final string SPTYPEBASIC='Basic';  
    public static boolean allowQuoteTrigger = true;
    public static boolean allowSiteQuoteJuncTrigger = true;
    public static boolean allowOpptyTrigger = true;    
    public static boolean allowSPTrigger = true;
    public static boolean allowContactTrigger = true;      
    public static boolean allowPPTrigger = true;
    public static boolean allowITSTicketCreation = true;
    public static boolean allowIDHITSTicketCreation = true;
    public static boolean allowDHITSTicketCreation = true;
    public static boolean allowDHSITSTicketCreation = true;
    public static boolean allowWirelinePromotionTrigger = true;
    public static boolean allowProposalLineItemTrigger = true;
    
    //Constants Specific to Sharing Object
    public static final String CUSTOMER_SITE_SHARE = 'CustomerSite__Share';
    public static final String SP_PRODUCT_SHARE = 'SPProduct__share';
    public static final String ACCOUNT_SHARE = 'AccountShare';
    public static final String APTTUS_PROPOSAL_SHARE ='Apttus_Proposal__Proposal__Share';
    public static final String END_CUSTOMER_SHARE ='End_Customer__Share';
    public static final String Finalized = 'Finalized';
    public static final String onetwofive = '125';
    public static final String Locked = 'LOCKED';
    public static final String OneneEight = '118';
    public static final String OnetwoTwo = '122';
    public static final String Cosfee = 'CoS Fee';
    public static final String Portspeedfee ='Port Speed Fee';
    public static final String AdditionalDNSfee ='Additional DNS Fee';
    public static final String OneTimefee ='One Time Fee';
    public static final String AccessSpeedfee ='Access Speed Fee';
    public static final String VlanLogicalfee ='VLAN(s)/Logical Channel';
    public static final String AccessSpeed ='Access Speed';
    public static final String None1='--None--';
    public static final String AddCos='Add CoS';
    public static final String DocusignCounterSign='Signer and Counter Signer should not be same.';
    public static final String DocusignCountersigner='Counter Signer is not assigned in EBM, please contact your system administrator';
    public static final String DocusignError='There was an error in generating pricing schedule, please contact your system administrator';
    public static final String DocusignErr='You are not added to the contract as a recipient, please contact your system administrator';
    public static final String DocusignErr1='There was an error in opening pricing schedule, please contact your system administrator';
    public static final String DocusignError1 ='Error in DocusignIntegrationHandler.CreateEnvelopeRecipient';
    public static final String DocusignError2 ='Error in MACD_UBBDocusignIntegrationHandler.AddDocusignRecipientTabs';
    public static final String DocusignError3 ='Error in DocusignIntegrationHandler.DeleteRecipient';
    public static final String DocusignError4 ='Error in MACD_UBBDocusignIntegrationHandler.SendRequest';
    public static final String DocusignError5 ='Error in DocusignIntegrationHandler.GetEnvelopeDocument';
    public static final String DocusignError6 = 'Error in DocusignIntegrationHandler.SendRequest';   
    
    //Constants Specific to SI/VAR
    public static final String[] PRODUCT_NAMES = new String[] {'AVPN','CaaS','StaaS'};
    public static final String OPP_STAGE_ORDER_SUB = 'Order Submitted';
    public static final String OPP_EXCEL_PAGE_NAME = '/apex/SIOppExcelPage?productId=';
    public static final String EXCEL_CONTENT_TYPE = 'application/vnd.ms-excel';
    public static final String OPP_STAGE_PRICING_APPROVED='Pricing Schedule Approved';
    public static final String OPP_STAGE_TSC_Confirmed = 'TSC Review Confirmed';
    public static final String OPP_STAGE_TSC_Denied = 'TSC Review Denied';
    public static final String OPP_STAGE_ERB_Approved = 'ERB Review Approved';
    public static final String OPP_STAGE_ERB_Denied = 'ERB Review Denied';
    public static final String OPP_STAGE_SA_Review_Confirmed = 'SA Review Confirmed';
    public static final String OPP_STAGE_SA_Review_Denied = 'SA Review Denied';
    public static final String OPP_STAGE_Tech_Review_Pending='Technical Review Pending';
    public static final String OPP_STAGE_RE_REQUESTED='Deal Registration ReRequested';
    public static final String OPP_STAGE_REQUESTED='Deal Registration Requested';
    public static final String OPP_STAGE_Approved ='Deal Registration Approved';
    public static final string STRING_MACD_TYPE_c = 'c';
    public static final string STRING_PROPOSAL_APPROVAL_STAGE = 'Order Submitted';
    public static final string STRING_DISCONNECT = 'Disconnect';
    
    //User type
    public static final String User_Type_Customer = 'CspLitePortal';
    public static final String User_Type_Guest = 'Guest';
    public static final String User_Type_Partner = 'PowerPartner';
    
    //Profile Type
    public static final String ATTPartnerCommunityUser = 'ATT Partner Community User';    
     
    //Constants for Blocked words and Audit usage.
    public static final String Post_Type_ChatterPost = 'Chatter Post';
    public static final String Post_Type_ChatterComment = 'Chatter Comment';
    public static final String Post_Type_Answer = 'Answer';
    public static final String Post_Type_Question = 'Question';
    public static final String Post_Type_Review = 'Review';
    public static final String chatterPost_ErrMsg = 'We’re sorry, but we cannot save this record. Your post appears to contain inappropriate language. To proceed, please remove "';
        
    //Constant for product Pricing for sprcial Pricing model
    public static final String DISCOUNT_TYPE_ACC = 'Access';
    public static final String DISCOUNT_TYPE_PORT = 'Port';
    public static final String DISCOUNT_TYPE_FEATURE = 'Feature';
    public static final String DISCOUNT_TYPE_USAGE = 'Usage';
    Public static final String TRIGGER_INSERT_OPERATION='insert';
    Public static final String TRIGGER_UPDATE_OPERATION='update';
    Public static final String NEWOPPTY='New';
    
    //Lead Status
    public static final String Lead_Status_CAMAssPen = 'CAM Assignment Pending';
    public static final String Lead_Status_SPProfileCompleted = 'SP Profile Completed'; 
    public static final String Contact_Roll_MainContact = 'Main Contact';
    public static final String Contact_Roll_PrimaryBilling = 'Primary Billing Contact';
    
    //NDA/MRA
     public static final String Standard_NDA_Template_Name='Standard NDA Template';
     public static final String Standard_MRA_Template_Name='Standard MRA Template';
     public static final String NDA='NDA';
     public static final String MRA='MRA';
     public static final string STANDARD='Standard';
     public static final string CUSTOM='Custom';
     
     //Finance Tracking 
     public static final string FHT_Status_Approved = 'Approved';
     public static final string FHT_Status_Submitted = 'Submitted';
     public static final string FHT_Status_Archived_Approved='Archived Approved';
     public static final string FHT_Status_Expired='Expired';
     public static final string FHT_Requestor_System='System';
     
     //RDS/Pricing Schedule
     public static final String FileType_Pricer='Pricer';
     public static final String RDS_ErrorMess_EBMName='EBM Name should not be null';
     public static final String RDS_ErrorMess_CountersignCheck='Please select at least one document to countersign before clicking on save button';
     Public static final String RDS_STATUS_REVIEWINPROGRESS='Review in progress';
     Public static final String RDS_STATUS_REVIEWCOMPLETED='Review completed';
     Public static final String RDS_STATUS_RECEIVED='Received';
     Public static final String RDS_STATUS_EXPIRED='Edit period expired';
     
     //API Variables
     Public static final String RDS_V4_Family_Data = 'RDS V4 Family Data Handler';
     Public static final String RDS_V6_Family_Data = 'RDS V6 Family Data Handler';
     public static final String DEALHASH_TRIGGER_HANDLER = 'RDS DealHash Handler';
     public static final String DHS_UPDATEDEALHASH_TRIGGER_HANDLER = 'DHStatus Handler';
     public static final String PremiseDetail_TRIGGER_HANDLER = 'RDS Premise Detail Handler';
     public static final String DHStatus_Provisioning_Billing_Details_TRIGGER_HANDLER = 'DHStatus-Provisioning Billing Details';
     public static final String DHStatus_Billing_Update_Details_TRIGGER_HANDLER = 'DHStatus-Billing Update Details';
     public static final String BillingRelatedElements_TRIGGER_HANDLER='RDS Billing Related Elements';
     public static final String CircuitAndVlan_TRIGGER_HANDLER='RDS Circuit and Vlan';
     public static final String RDSValidation_TRIGGER_HANDLER='RDS Validation';
     public static final String RDSValidationConfig_TRIGGER_HANDLER='RDS Validation Configuration';
     public static final String VLANInfo_TRIGGER_HANDLER='RDS- VLAN Information';
     public static final String RDS_Access_CktId_TRIGGER_HANDLER='RDS-Access Circuit ID';
     public static final String RDS_PremiseDetails_TRIGGER_HANDLER='RDS Premise Details';
     public static final String RatePHI_TRIGGER_HANDLER='Rate PHI';    
     Public static final String SERVICETYPEAVPN='AVPN';
     Public static final String SERVICETYPEMIS='MIS';
     public static final String SERVICETYPEAMIS='AMIS'; 
     public static final String SERVICETYPEANIRA='ANIRA';
     Public static final String TRANSPORTTYPESWITCHEDETHERNET='SwitchedEthernet';
     Public static final String TRANSPORTTYPEDEDICATEDETHERNET='DedicatedEthernet';     
     Public static final String TRANSPORTTYPEETHERNET='Ethernet';
     Public static final String TRANSPORTTYPENT1='nT1'; 
     Public static final String TRANSPORTTYPET1='T1';
     Public static final String FACILITYINTERFACECODE='04DU91SN';
     Public static final String SERVICECODE = 'DH';  // added based on mail from Carola, 4th Aug 2014
     Public static final String ACCESSMETHODSEAMLESS='SEAMLESS_CONTROL_PLANE'; 
     Public static final String ACCESSMETHODDEDICATED='ESP_ETH_DEDICATED'; 
     Public static final String ACCESSMETHODSHARED='ESP_ETH_SHARED'; 
     Public static final String SUSCRIBEDSERVICESSUBSPPP='SUBSPPP'; 
     Public static final String SUSCRIBEDSERVICESSUBSMLPPP='SUBSMLPPP'; 
     Public static final String SUSCRIBEDSERVICESSUBSMIS='SUBSMIS'; 
     Public static final String PROVISIONINGSTATUS='Provisioning Initiated'; 
     Public static final String RDSSTATUSCREATE='Deal Hash Creation API Successful';
     Public static final String ROUTINGPROTOCOL='BGP4';
     Public static final String TIERGOLD='Gold';
     Public static final String TIERSILVER='Silver';
     Public static final String TIERPLATINUM='Platinum';
     Public static final String TERMONE='1';
     Public static final String TERMTWO='2';
     Public static final String TERMTHREE='3';
     Public static final String TERMFOUR='4';
     Public static final String TERMFIVE='5';
     public static final String FailureStatus='Failure';
     public static final String weekcode='EEEE'; 
     public static final String dealstatus='Pricing Schedule Requested'; 
     public static final String dealstatus_pending='Pricing Schedule Pending';
     public static final String blanketdiscount='Blanket Discount';
     public static final String masterratecard='Master Rate Card';
     public static final String discountplanfailed='Discount Plan Assignment Failed';
     public static final String discountplansuccess='Discount Plan Assignment Successful'; 
     public static final String portdiscount='Port Discount';
     public static final String accessdiscount='Access Discount';
     public static final String product_pricing_access='Access';
     public static final String product_pricing_port='Port';  
     public static final String product_pricing_feature='Feature';
     public static final String RECORDTYPEMACD = 'MACD';
     public static final String RECORDTYPEPORT = 'Port';
     public static final String MACDTYPEA = 'A';
     public static final String MACDTYPEC = 'C';       
     public static final String MACDTYPED = 'D';      
     public static final String UBBAdd = 'UBB Add';
     public static final String UBBChange= 'UBB Change';
     public static final String UBBRemove= 'UBB Remove';
     public static final String CoSChange= 'CoS Change';
     public static final String PortSpeedChange= 'Port Speed Change';
     public static final String VLANSpeedChange= 'VLAN Speed Change';
        
     public static final String API_RatePHI_Discountplan_Success='Create Discount Plan Successful';
     public static final String API_RatePHI_Name_EBM_Competitive_Feature='EBM Competitive Feature Discount Plan';
     public static final String RDS_PRICING_SCHEDULE_TRIGGER_HANDLER='RDS pricing schedule Handler';
     public static final String SA_Contract_Failed = 'SA Contract Subscription API Failed';
     public static final String SA_API_Process_Error = '300 PARENT PLAN SA TRANSLATION FAILED!!! Still waiting on deal rate plan data to flow to Billing System, once complete, this step can be retriggered';
     public static final String DHStatus_Logical_Provisioning_TRIG_HANDLER='DHStatus Logical Provisioning Trigger Handler';
     public static final String DHStatusPLGroupPortData_TRIG_HANDLER='DHStatus PLGroupPortData Trigger Handler';
     public static final String DHStatusConnectionLevel_TRIG_HANDLER='DHStatus Connection Level Data Trigger Handler';
     public static final string DEAL_HASH_UPDATE_CANCEL_API_SUCCESSFUL='Deal Hash Update - Cancel API Successful';
     public static final string DEAL_HASH_UPDATE_CANCEL_API_PROGRESS = 'Deal Hash Update - Cancel API In Progress';
     Public static final string PROVISIONING_INITIATION_CANCEL_FAILED='Provisioning Initiation API Failed';      
     public static final string RDS_PREMISE_SITE_STATUS_CANCELLED='CANCELLED';
     Public static final string RDS_PREMISE_SITE_STATUS_PENDINGCANCEL ='PENDING_CANCEL';
     //Mobility Activation 
     Public static final string SITEREQUESTTITLE='EBM SP Request for Premier Site Build.xls';
     Public static final string SIFANAGREEMENT='EBM SP Agreement ID.xls';
     Public static final string SIFANTEMPLATE='EBM SP FAN Request.xls';
     Public Static final string SIMAINCONTACT='Main Contact';
     Public Static final string SIPRIMARYBILLCONTACT='Primary Billing Contact';
     Public Static final string SICRUUSER='CRU User';
     Public Static final string SICFUUSER='CFU User';
     Public Static final string SIBOTHUSER='Both';     
     Public Static final String FANNUMBER='FAN Number'; 
     Public Static final String CREDITCHECKSUBJECTLINE='Credit Check Request for ';
     Public Static final String AGREEMENTREQUESTSUBJECTLINE='EBM Agreement Request for ';
     Public Static final String PREMIERSITESUBJECTLINE='EBM Premier Site Build Request for ';
     Public Static final String PROFILEREQUESTSUBJECTLINE='EBM Update: Requesting Additional ID Request for ';
     Public Static final String FANREQUESTSUBJECTLINE='EBM FAN Creation Request for ';
     Public Static final String XLSCONTENTTYPE='application/vnd.ms-excel';
     Public Static final String DOMAINNAME='.com';
    
     //Source
     public static final String Source_Type_Other='Other';
     public static final String Record_Origin_UserCreated='User Created';
     
     //Directory
     public static final String Status_Pending_Approval='Pending Approval';
     public static final String Status_Pending_Legal_Approval='Pending Legal Approval';
     public static final String Status_Review_Requested='Review Requested';
     public static final String Status_Published='Published';  
     public static final String Status_Published_Pending_New_Version='Published - Pending New Version';
     public static final String Status_Archived='Archived';
     
     //Authenticated & UnAuthenticated Users
     public static final String GUEST ='Guest';
     
     //TechnicalResources Article
     public static final String FEEDBACK='Feedback';
     public static final String SHARING='Sharing';
          
     //Engagement
     public static final String Engagement_Status_Published='Published'; 
     public static final String EVENT='Event';
     public static final String SPONSORSHIP='Sponsorship';
          
     //Profile Names
     public static final String System_Administrator='System Administrator';
     public static final String SI_API_User='SI_API User';
     public static final String SI_Customer_Community_User='SI Customer Community User';
      
     //Error Meassages
     public static final String ThirdPartyErrorMess1 = 'Please enter a value for Request Amount.';
     public static final String ThirdPartyErrorMess2 = 'Please enter a number which contains only two decimal values.';
     public static final String ThirdPartyErrorMess3 = 'Please enter a number which is greater then 0.';
     public static final String ThirdPartyErrorMess4 = 'Please enter a numeric value.';   
     public static final String TSCErrorMess1 = 'Please select a radio button before submit.';
     public static final String TSCErrorMess2 = 'Confirmed Data Center: You must select a value.';
     public static final String TSCErrorMess3 = 'Please attach a template before clicking on submit button.';
     public static final String TSCErrorMess4 = 'Only PDF documents are allowed';
     public static final String EngineerErrorMess1 = 'Please select a radio button before submit.';
        
    //Define the Handler Class Short Names like
    public static final String AV_TRIG_HANDLER = 'Att Product Attribute Value Handler';
    public static final String CUST_SITE_QUOTE_TRIG_HANDLER = 'Att Customer Site Quote Handler';
    public static final String LEAD_TRIG_HANDLER = 'Lead Handler';
    public static final String ACC_TRIG_HANDLER = 'Account Handler';
    public static final String OPP_TRIG_HANDLER = 'Opportunity Handler';
    public static final String PRO_TRIG_HANDLER = 'Product Handler';
    public static final String MDF_TRIG_HANDLER = 'MDF Handler';  
    public static final String MDF_BUDGET_TRIG_HANDLER = 'MDF Budget Handler';
    public static final String END_CUSTOMER_TRIG_HANDLER = 'Endcustomer Handler';
    public static final String AEJ_TRIG_HANDLER = 'Account Endcustomer Junction Handler';
    public static final String ROME_OPPORTUNITY_TRIGGER_HANDLER='ROME Opportunity Handler';
    public static final String PRODUCT_PRICING_HANDLER='Product Pricing Handler';
    public static final String TASK_TRIG_HANDLER = 'Task Trigger Handler';
    public static final String CONTACT_TRIG_HANDLER = 'Contact Handler';
    public static final String END_CUSTOMER_TICKET_HANDLE='Endcustomer Ticket Handler';
    public static final String SITE_TRIGGER_HANDLER='Site Handler';
    public static final String PARTNER_COURSE_TRIG_HANDLER = 'Partner Course Trigger Handler';
    public static final String PARTNER_CERTIFICATION_TRIG_HANDLER = 'Partner Certification Trigger Handler';
    public static final String Financing_History_Tracking_TRIG_HANDLER = 'Financing History Trigger Handler';
    public static final String BLOG_TRIGGER_HANDLER='Blog Handler';
    public static final String TOPIC_TRIGGER_HANDLER='Topic Trigger Handler';
    public static final String ENGAGEMENT_TRIGGER_HANDLER='Engagement Handler';
    public static final String Directory_TRIGGER_HANDLER='Directory Trigger Handler';
    public static final String User_TRIGGER_HANDLER='User Trigger Handler';
    public static final String DHStatusASR_TRIGGER_HANDLER='DHStatus-ASR Details Trigger Handler';
    public static final String DHStatusAccessService_TRIGGER_HANDLER='DHStatus-Access Service Request Status Trigger Handler';
    public static final String DEALHASH_ETHERNET_HANDLER='DHStatus-Ethernet Trigger Handler';
    public static final String DEALHASH_PRIVATELINE_HANDLER='DHStatus-PrivateLine Trigger Handler';
    public static final String DHStatusUpdate_TRIG_HANDLER= 'DHStatus-Update Deal Hash Details Trigger Handler';
    public static final String DHStatusAccessTestStatus_TRIGGER_HANDLER = 'DHStatus-Access Test Status Trigger Handler';
    public static final String DHStatusAccessCircuit_TRIGGER_HANDLER = 'DHStatus-AccessCircuit Trigger Handler';
    public static final String DHStatusCompletionDetails_TRIGGER_HANDLER = 'DHStatus- CompletionDetails Trigger Handler';
    public static final String ChatterFeedItem_TRIGGER_HANDLER='ChatterFeedItem Trigger Handler';
    public static final String ChatterFeedComment_TRIGGER_HANDLER='ChatterFeedComment Trigger Handler';
    public static final String ChatterQuestion_TRIGGER_HANDLER='ChatterQuestion Trigger Handler';
    public static final String ChatterReply_TRIGGER_HANDLER='ChatterReply Trigger Handler';
    public static final String BlockedWord_TRIG_HANDLER = 'Blocked Word Trigger Handler';
    public static final String IRUFanActivity_TRIG_HANDLER = 'IRUFanActivity Trigger Handler';
    public static final String IRUCompensation_TRIG_HANDLER = 'IRUCompensation Trigger Handler';
    public static final String DHStatus_Other_Providers_Trigger_HANDLER = 'DHStatus Other Providers Trigger Handler';  
    public static final String Docusign_Recepient_Trigger_Handler = 'Docusign recepient trigger handler';
    public static final String ASE_Wholesale_Contract_Number_TriggerHandler = 'ASE_Wholesale_Contract_Number_Trigger';
    public static final String ASE_Billing_Account_Number_TriggerHandler= 'ASE_Billing_Account_Number_Trigger';
    public static final String PROPOSAL_LINE_ITEM_TRIG_HANDLER = 'Proposal Line Item Trigger Handler';
    
    //Competitve Pricing
    public static final String LIST_PRICE = '"List Price" is not defined.';
    public static final String COMP_PRIC_ST = '"Special Pricing Status" should be "Special Pricing Requested"';
    public static final String PERCEN_DISCOUNT = 'Percentage Discount';
    public static final String FLAT_DISCOUNT = 'Flat Discount';
        
    //Competitive Pricing Constants
    public static final String PROD_COMP_PRI_REQ='Special Pricing Requested';
    public static final String PROD_COMP_PRI_APP = 'Special Pricing Approved';
    public static final String PROD_COMP_PRI_DEN = 'Special Pricing Denied';
    public static final String PROD_COMP_PRI_IN = 'Special Pricing Incomplete';
    public static final String PROD_COMP_APPROVE = 'Approve';
    public static final String PROD_COMP_More_INFO = 'More Info';
    public static final String PROD_COMP_REJECT = 'Reject';
    public static final String PROD_COMP_FIXED = 'Fixed Price';
    public static final String PROD_COMP_DISCOUNT_PER = 'Discount %';
    public static final String PROD_SAAS = 'StaaS';
    public static final String PROD_CAAS = 'CaaS';
    public static final String PROD_PAAS = 'PaaS';
    public static final String PROD_Attwireless = 'Attwireless';
    public static final String PROD_MDM = 'MDM';
    public static final String PROD_MPLSPNT = 'MPLSPNT';
    public static final String PROD_PRICING_TYPE = 'NRC';
    public static final String PROD_MIS = 'MIS';
    public static final String PROD_Broadband  = 'Broadband';
    public static final String PROD_ASE  = 'ASE';
    public static final String PROD_IPFLEX = 'IPFLEX';
    
    
    //Deal Registration at Opty Level Constants
    public static final String OPTY_DEAL_DENY ='Deal Registration Denied';
    public static final String OPTY_DEAL_APP_WITH_DIS ='Deal Reg Approved with discount';    
    public static final String OPTY_DEAL_REG_APP_WITHOUT_DIS='Deal Reg Approved without discount';
    public static final String OPTY_DEAL_REG_CANCEL='Deal Registration Cancelled';
    public static final String OPTY_DEAL_REG_DELETED='Deal Registration Deleted';
    public static final String OPTY_DEAL_APPROVED='Deal Registration Approved';
    public static final String OPTY_DEAL_SUBMITTED='Order Submitted';
    public static final String OPTY_DEAL_REQUESTED='Deal Registration Requested';
    public static final String OPTY_DEAL_LOST='Deal Lost';
    public static final String OPTY_DEAL_QUOTE_CREATED='Deal Quote Created';
    public static final String OPTY_DEAL_EXPIRED='Deal Registration Expired';
    public static final String OPTY_DEAL_WON='Deal Won';
    public static final String OPTY_DEAL_SAVED='Saved';
    public static final String OPTY_DEAL_Auto_Approved='Deal Reg Auto-Approved';
    public static final String deal_regAuto ='Deal Reg Auto-Approved';
    public static final String PROD_DEAL_EXPIRED = 'Expired';
    
    //Deal Likelihood to Close at Oppty Level Constants 
    public static final String OPTY_DEAL_LTC_APPROVED='Approved (20%)';
    public static final String OPTY_DEAL_LTC_CONT_REQUESTED='Contracts Requested (80%)';
    public static final String OPTY_DEAL_LTC_REG_REQUESTED='Deal Registration Requested (0%)';
    public static final String OPTY_DEAL_LTC_NONE='None (0%)';
    public static final String OPTY_DEAL_LTC_ORDERED='Ordered (100%)';
    public static final String OPTY_DEAL_LTC_STALE='Stale (5%)';
    public static final String OPTY_DEAL_LTC_UNDER_CONSD='Under active consideration by customer (50%)'; 
    public static final String OPTY_LTC_DEAL_LOST='Deal Lost (0%)';       
    
    //Deal Registration Constants  
    public static final String PROD_DEAL_REG_PENDING ='Deal Registration Pending';
    public static final String PROD_DEAL_REG_DENY='Deal Registration Denied';
    public static final String PROD_DEAL_REG_APP_WITH_DIS ='Deal Reg Approved with discount';
    public static final String PROD_DEAL_REG_APP_WITHOUT_DIS ='Deal Reg Approved without discount';
    public static final String PROD_DEAL_REG_REQ ='Deal Registration Requested';
    public static final String PROD_DEAL_REG_SYS_AUTO_APP_WITH_DIS ='System Auto Approve with Discount';
    public static final String PROD_DEAL_REG_SYS_AUTO_APP_WITHOUT_DIS ='System Auto Approve without Discount';
    public static final String PROD_DEAL_REG_SYS_AUTO_DENIED ='System auto denied – Named Account';
    public static final String PROD_DEAL_REG_CANCELLED='Deal Registration Cancelled';
    public static final String PROD_DEAL_QUOTE_EXPIRED='Deal Registration Expired';
    public static final String PROD_DEAL_QUOTE_EXTN_APRVD='Deal Extension Approved';
    public static final String PROD_DEAL_QUOTE_EXTN_REQ='Deal Extension Requested';
    public static final String PROD_DEAL_QUOTE_EXTN_DENY='Deal Extension Denied';
    public static final String PROD_DEAL_DELETED='Deleted';
    
    public static final String CREDIT_CHECK_PASSED='Credit Check Approved';
    public static final String CREDIT_CHECK_FAILED='Credit Check Denied';
    public static final String CREDIT_CHECK_REVIEW='Credit Check Review';
    public static final String PASS='Approved'; 
    public static final String FAIL='Denied';
    public static final String PENDING ='Pending';
    public static final String CUSTOMERIDINITIAL='A-';
    public static final String BLANKSPACCOUNTID='Please check the SP Account ID. Value is null or blank';
    
    //SPProduct "On/Off Cart" field LOVs   
    public static final String SPPRODUCT_OFF_CART = 'Off Cart';
    public static final String SPPRODUCT_ON_CART = 'On Cart';
    
    //Opportunity "Deal On/Off Cart" field LOVs
    public static final String DEAL_OFF_CART = 'Off Cart';
    public static final String DEAL_ON_CART = 'On Cart';
    
    //Product Pricing Types
    
    public static final String TYPE_MRC = 'MRC';
    public static final String TYPE_NRC = 'NRC';
    public static final String TYPE_MUC = 'MUC';
    
    //Partner Course Status'
    public static final String PARTNER_COURSE_COMPLETED = 'Completed';
    public static final String PNT = 'PNT';
    
    public static final String[] PROD_DEAL_REG_VALUES=new String[]{'Deal Registration Denied','Deal Registration Approved With Discount','Deal Registration Approved Without Discount','Deal Registration Requested','System Auto Approve with Discount','System Auto Approve without Discount','System auto denied – Named Account'};
   
    //ATOM Partner User Constants 
     public static final String USERNAMESUBJECTLINE='AT&T: Your AT&T Partner Exchange User Name';
     public static final String PASSWORDSUBJECTLINE='AT&T: Your AT&T Partner Exchange Password';
     Public Static final String[] UPPERCASECHARACTERS = new String[]{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'}; 
     Public Static final String[] NUMBERIC= new String[]{'1','2','3','4','5','6','7','8','9','0'}; 
     Public Static final String[] LOWERCASECHARACTERS = new String[]{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}; 
     Public Static final String[] SPECIAL= new String[]{'+','=','?','!','@','#','$','%','*'}; 
     public static final String TIMEZONESIDKEY='America/Los_Angeles';
     public static final string LANGUAGESIDKEY='en_US';
     public static final string LANGUAGELOCALEKEY='en_US';
     public static final String EMAILENCODINGKEY='UTF-8';
    
    //constant to be used in triggers created for External Security USs    
    public static final String RDS_CONTACT_TRIGGER_HANDLER = 'SIRDSContactTriggerHandler';
    public static final String RDS_CONTRACT_TRIGGER_HANDLER = 'SIRDSContractDetailsTriggerHandler';
    public static final String RDS_SWIP_CONTACTS_TRIGGER_HANDLER = 'SIRDSSwipContactsTriggerHandler';
    public static final String WIRELINE_PROMOTION_RULE_TRIGGER_HANDLER = 'WirelinePromotionRuleTriggerHandler';
    
    //Constants to be used in PromoEngineController class 
     public static final String NONE = 'None';
     public static final String PERCENTAGE = 'Percentage';
     public static final String S = 'S';
     public static final String LESSTHANOPERATOR = '<';
     public static final String GREATERTHANOPERATOR = '>';
     public static final String DATATYPE_NAME_STRING = 'String';
     public static final String DATATYPE_NAME_DATE = 'Date';
     public static final String DATATYPE_NAME_PICKLIST = 'Picklist';
     public static final String BLANKSPACE = '';
     public static final String ALL_INPUTS_REQUIRED_ERROR = 'All inputs are required for criteria : ';
     public static final String CHECK_INPUT_VALUES_ERROR = 'Please Check Input values';
     public static final String STRING_DATA_TYPE_ERROR = 'String Datatype can only have =,!=';
     public static final String DEAL_REG_DISCOUNT_RANGE = 'Deal Reg Discount cannot be greater than 50 or less than 0';
     public static final String ATLEAST_ONE_SHOULD_BE_ENTERED = 'Atleast one criteria needs to be entered.';
    public static final String STRING_DATA_TYPE_ERROR1 = 'String Datatype can only have =,!=';
    public static final String ALL_REQUIRED_EXCEPT_CURRENTLYACTIVE_VFP = 'All inputs are required in promotion engine section except Currently Active & Valid For Product.';
    public static final String SYS_ADMIN_ONLY = 'Only System Administrator can create a new rule';
    
    //For Feb-02 Release
    public static final String[] HEAT_MAP_PROD_NAMES = new String[] {'AVPN','CaaS','StaaS','MIS','MPLSPNT','IPFlex','PaaS'};
    public static final String[] HEAP_MAP_COLOR = new String[] {'Green','Red','Yellow','Blue', 'Orange',''};
    Public Static final String[] VALID_STATES =new String[]{'AL','AK','AZ','AR','CA','CO','CT','DE','DC','FL','GA','HI','ID','IL',
                                                              'IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV',
                                                              'NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD',
                                                              'TN','TX','UT','VT','VA','WA','WV','WI','WY'};
    
    /*public static final String HEAT_MAP_QUERY =
         'Select Account.Id, Account.Name, End_Customer__r.Id, End_Customer__r.Name, End_Customer__r.Named_Account__c,'+
         'Id, Name, StageName,(Select Id, Name, Deal_Status__c, RecordType.Name from SPProducts__r)'+ 
         'from Opportunity Where End_Customer__r.Id != null and Account.Id != null'; */
    
    public static final String[] PROD_DEAL_STATUS = new String[] {'Deal Registration Requested',
        'Deal Registration Approved Without Discount', 'Named Account','Deal Registration Approved With Discount'};       
    
    
    public static final String[] PROD_DEAL_STATUS_AFTER = new String[] {
        'System Auto Approve with Discount','System Auto Approve without Discount','System auto denied – Named Account'
    };
    
    //For enhanced heatmap
    public static final String[] DATA_TYPE_NAMES = new String[] {'Number', 'String', 'Boolean', 'Date','Picklist'};
    public static final String PRODUCT_EXPIRY = 'Cancelled';

    public static final String SER_ASS_ERROR_MSG = 'Ticket cannot be refreshed at this time.';
    public static final String MDF_REQ_EXISTS_MSG = 'MDF Budget already exists for this Quarter for this Account.'+ 
                    +'Please create a new MDF Budget for a different Quarter or update an existing MDF Budget record';  
    
    public static final String LEAD_SEARCH_NO_RECORDS = 'No records were found that match the specified search criteria.';
    public static final String LEAD_SEARCH_MORE_RECORDS = 'More than 10 Companies have been found,'+
        ' Please refine your search criteria if the Company you are searching is not listed.';
    
    public static final String[] SP_ACCOUNT_TICKET_RECORD_TYPES = new String[] {'AOTSCM','AOTSTM','ISOM'};
    
    public static final String[] LEAD_SEARCH_VALIDATION_ERRORS = new String[] {
        'Company Legal Name cannot contain less than 5 characters.',
        'Duns Number needs to be 9 characters long, example: "123987456".',
        'Duns Number can only contain Numeric Values from \'0-9\', example: "012345678".',
        'Zip Code needs to be 5 characters long, example: "10002".',
        'Zip Code can only contain Numeric Values from \'0-9\', example: "12345".',
        'In Search criteria, please enter Company Legal Name/Duns Number.',
        'State needs to 2 characters long, example: "NY", "NJ", "TX", and etc...',
        'A valid two-letter state code is required.' ,
        'A Lead/Account with the ROME account Id selected already exist in the system, please see below to URL to access the record. If this is the incorrect Lead/Account, please retry your search.'
    };
    public static final String[] HEAT_MAP_VALIDATION_ERRORS = new String[] {
        'For "End Customer View", "End Customer" is a required field.',
        'For "SP Account View", "SP Account" is a required field.',
        'No records found for your search.',
        'Atleast a "Single Product Selection" is required.'     
    };
    public static final String Attwireless = 'Attwireless';   
}