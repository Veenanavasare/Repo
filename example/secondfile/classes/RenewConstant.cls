/*************************************************************************************************************************************** 
Apex Class Name     : RenewConstant
Version             : 1.0 
Created Date        : 15 April 2017
Function            : This class holds the constants used in the Contract Renewal Flow
Owner               : rd0497
****************************************************************************************************************************************/
public with sharing class RenewConstant{
    public static final String TABSTATUS_ACTIVE = 'active';
    public static final String TABSTATUS_INCOMPLETE = 'incomplete';
    public static final String TABSTATUS_COMPLETE = 'completed';
    public static final String TABSTATUS_COMPLETECLASS = 'tabbed_menu_completed';
    public static final String TABSTATUS_INCOMPLETECLASS = 'tabbed_menu_disabled';
    public static final String TABSTATUS_ACTIVECLASS = 'active';
    public static final String TAB_ERRORMSG = 'Error TabMenuHandler.initializeTabMenu';
    public static final String EXCEPTION_MSG1 = 'Exception in ContractRenewalQuoteProcessingBatch during Customer Site Quote Junction insertion: ';
    public static final String EXCEPTION_MSG2 = 'Exception Caught at line : ';
    public static final String HTTPS_LITERAL = 'https://';
    public static final String URL_QT_PARAM = '&quoteid=';
    public static final String URL_TERM_PARAM = '&mode=terminfo';
    public static final String URL_ORDERCONF = '&mode=orderConf';    
    public static final String URL_REVIEW_PARAM = '&mode=reviewquote'; 
    public static final String URL_SPCL_PARAM = '&mode=spclPriceConf';
    public static final String URL_TERM_AND_COND_PARAM= '&mode=tnc&flow=contractRenewal&code=';
    public static final String OFFLINE_PROCESS_INIT = 'Offline Process Initiated';
    public static final String SPACE_HIPHEN_SPACE = ' - ';
    public static final String NS = 'ns';
    public static final String MS = 'ms';
    public static final String YEAR_LOWERCASE = 'year';
    public static final String PENDING_DEAL_REG = 'Pending Deal Reg';
    public static final String REVIEW_QUOTE = 'reviewquote';
    public static final String REVIEW_QUOTE_SPECIAL_PRICE = 'spclPriceReq';
    public static final String REVIEW_QUOTE_TERMINFO = 'terminfo';
    public static final String DRAFT = 'Draft';
    public static final String DEAL_REG_PENDING = 'Deal Reg Pending';
    public static final String PROCESSING_RENEWAL = 'Processing Renewal';
    public static final String DEAL_REG_APPROVED = 'Deal Reg Approved';    
    public static final String SP_APPROVAL_REQUESTED= 'SP Approval Requested';        
    public static final String SPECIAL_PRICING_REQUESTED = 'Special Pricing Requested';
    public static final String SPECIAL_PRICING_APPROVED = 'Special Pricing Approved';
    public static final String SPECIAL_PRICING_DENIED = 'Special Pricing Denied';
    public static final String ORDER_SUBMITTED= 'Order Submitted';
    public static final String SPECIAL_PRICING_CONF = 'spclPriceConf';
    public static final String RENEW_REVIEW_PAGE = 'RenewContractReview';
    public static final String RENEW_TERM_PAGE = 'RenewContractTermInfo';
    public static final String RENEW_SPECIAL_PRICE_PAGE = 'RenewContractSpecialPricingRequest';
    public static final String RENEW_SIVAR_API = 'SI/VAR - API';
    public static final String RENEW_DEALRATE_PLAN_API_FAILURE= 'Contract Renewal - Deal Rate Plan API Failure';
    public static final String RENEW_HIGH = '2 - High';
    public static final String RENEW_REPRODUCE_ERR_MSG2 = 'Refer to ';
    public static final String RENEW_REPRODUCE_ERR_MSG3 = ' for more details.';
    public static final String RENEW_ITS_API_IMPACT_MSG = 'Contract Renewal Order submitted by the SP User in the Force Portal will not be able to proceed forward because of this error.';    
    public static final String RENEW_ITS_API_STATUS = 'Open';
    public static final String RENEW_IDHAFTER_PUSH_NOTI_FAILURE = 'Contract Renewal - IDH Failure After WFE Push Notification'; 
    public static final String RENEW_OR = ' or '; 
    public static final String RENEW_IDH_PUSH_NOTI_FAILURE_IMPACT_MSG = 'System will not be able to update the Premise Status to \'Active\' of a Contract Renewal Order submitted by the SP User in the Force Portal because of this error.';   
    public static final String RENEW_MACDUPDATE_FAILURE = 'Contract Renewal – Automatic MACD Update Deal Hash Failure';
    public static final String RENEW_MACDUPDATE_IMPACT_MSG = 'System will not be able to update Deal Hash of a Contract Renewal Order submitted by the SP User in the Force Portal because of this error.';
    public static final String CONTRACT_RENEWAL_ERROR_MSG_FINISH = 'Exception in finish method of ContractRenewalDealHashUpdate ';
    public static final String CONTRACT_RENEWAL_ERROR_MSG_AT_LINE_NO = ' at line no ';
    public static final String CONTRACT_RENEWAL_ERROR_MSG = '  Message - >';
    public static final String CONTRACT_RENEWAL_ERROR_MSG_UPDATEPREMISE = 'Exception in cloneAndUpdatePremise method of ContractRenewalDealHashUpdate ';
    public static final String CONTRACT_RENEWAL_EXCEPTION = 'Exception ';
    public static final String RENEWAL_REQUEST_PENDING_CONST = 'Renewal Request Pending';
    public static final String PENDING_CONTRACT_RENEWAL_CONST = 'PENDING_CONTRACT_RENEWAL';
    public static final String RENEWAL_CONST = 'Renewal';
    public static final String CONTRACT_RENEWAL_CONST = 'Contract Renewal';
    public static final String Renewal = 'Renewal';
    
    public RenewConstant(){
    	
    }
}