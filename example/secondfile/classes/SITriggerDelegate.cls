//A Delegate Model which controlls the flow for all the 'XXXXTriggerHandler.cls'
public with sharing class SITriggerDelegate {
   public SITriggerDelegate() { 
   }
   
   //A method returns the specific handler object 
   public SITriggerOperations.SITriggerImpl getHandlerHandleObject(String objectHandlerName) {
    SITriggerOperations.SITriggerImpl triggerHandlerHandle = null;
     try {
       if((null != objectHandlerName) && (objectHandlerName.length() > 0)) {
           if(objectHandlerName.equalsIgnoreCase(SIConstants.OPP_TRIG_HANDLER)) {
           triggerHandlerHandle = new SIOpportunityTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.PRO_TRIG_HANDLER)) {
           triggerHandlerHandle = new SIProductTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.LEAD_TRIG_HANDLER)) {
           triggerHandlerHandle = new SILeadTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.ACC_TRIG_HANDLER)) {
           triggerHandlerHandle = new SIAccountTriggerHandler(); 
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.MDF_TRIG_HANDLER)) {
           triggerHandlerHandle = new SIMDFTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.MDF_BUDGET_TRIG_HANDLER)) {
           triggerHandlerHandle = new SIMDFBudgetTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.END_CUSTOMER_TRIG_HANDLER)) {
           triggerHandlerHandle = new SIEndcustomerTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.AEJ_TRIG_HANDLER)) {
           triggerHandlerHandle = new SIAcctEndCustJunctionTriggerHandler();    
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.ROME_OPPORTUNITY_TRIGGER_HANDLER)){
           triggerHandlerHandle = new SIROMEOpportunityTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.PRODUCT_PRICING_HANDLER)){
           triggerHandlerHandle = new SIProductPricingTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.TASK_TRIG_HANDLER)){
           triggerHandlerHandle = new SITaskTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.CONTACT_TRIG_HANDLER )){
           triggerHandlerHandle = new SIContactTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.END_CUSTOMER_TICKET_HANDLE)){
           triggerHandlerHandle = new EUTktTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.SITE_TRIGGER_HANDLER)){
           triggerHandlerHandle = new SI_SiteTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.PARTNER_COURSE_TRIG_HANDLER)){
           triggerHandlerHandle = new SIPartnerCourseObjectTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.Financing_History_Tracking_TRIG_HANDLER)){
           triggerHandlerHandle = new SIFinanceTrackingTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.BLOG_TRIGGER_HANDLER)){
           triggerHandlerHandle = new SI_BlogTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.TOPIC_TRIGGER_HANDLER)){
           triggerHandlerHandle = new SITopicObjectTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.ENGAGEMENT_TRIGGER_HANDLER)){
           triggerHandlerHandle = new SI_EngagementObjectTriggerHandler();        
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.User_TRIGGER_HANDLER)){
            triggerHandlerHandle = new SI_UserObjectTriggerHandler();        
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.Directory_TRIGGER_HANDLER)){
           triggerHandlerHandle = new SIDirectoryTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.RDS_V4_Family_Data)){
           triggerHandlerHandle = new API_RDS_V4FamilyDataTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.RDS_V6_Family_Data)){
           triggerHandlerHandle = new API_RDSV6FamilyDataTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DEALHASH_TRIGGER_HANDLER)){
           triggerHandlerHandle = new API_DealhashTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.PremiseDetail_TRIGGER_HANDLER)){
           triggerHandlerHandle = new API_PremiseDetailsTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.CircuitAndVlan_TRIGGER_HANDLER)){
            triggerHandlerHandle = new API_CircuitAndVLanTriggerHandler(); 
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.VLANInfo_TRIGGER_HANDLER)){
            triggerHandlerHandle = new API_VLANInfoTriggerHandler(); 
         }else if(objectHandlerName.equalsIgnoreCase(SIConstants.RDS_Access_CktId_TRIGGER_HANDLER)){
            triggerHandlerHandle = new API_RDSAccessCktTriggerHandler();                 
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.RatePHI_TRIGGER_HANDLER)){
            triggerHandlerHandle = new API_RatePHITriggerHandler(); 
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.RDS_PRICING_SCHEDULE_TRIGGER_HANDLER)){
            triggerHandlerHandle = new API_RDSPricingScheduleTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DHStatusASR_TRIGGER_HANDLER)){
            triggerHandlerHandle = new API_DHStatusASRTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DHStatusAccessService_TRIGGER_HANDLER)){
            triggerHandlerHandle = new API_DHStatusAccessServiceTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DEALHASH_ETHERNET_HANDLER)){
            triggerHandlerHandle = new API_DHStatusEthernetTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DEALHASH_PRIVATELINE_HANDLER)){
            triggerHandlerHandle = new API_PrivateLineTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DHStatusUpdate_TRIG_HANDLER)){
            triggerHandlerHandle = new API_DHstatusUpdateTriggerHandler(); 
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DHStatusAccessTestStatus_TRIGGER_HANDLER)){
            triggerHandlerHandle = new API_DHStatus_AccessTest_TriggerHandler();  
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DHStatusAccessCircuit_TRIGGER_HANDLER)){
            triggerHandlerHandle = new APIDHStatus_AccessCircuit_TriggerHandler();  
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.ChatterFeedItem_TRIGGER_HANDLER)){
            triggerHandlerHandle = new SI_ChatterFeedItemTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.ChatterFeedComment_TRIGGER_HANDLER)){
            triggerHandlerHandle = new SI_ChatterFeedCommentTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.ChatterQuestion_TRIGGER_HANDLER)){
            triggerHandlerHandle = new SI_ChatterQuestionTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.ChatterReply_TRIGGER_HANDLER)){
            triggerHandlerHandle = new SI_ChatterReplyTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.BlockedWord_TRIG_HANDLER)){
            triggerHandlerHandle = new SIBlockedWordTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DHStatus_Logical_Provisioning_TRIG_HANDLER)){
            triggerHandlerHandle = new API_DHStatusLogicalProvisioningHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DHStatus_Billing_Update_Details_TRIGGER_HANDLER)){
            triggerHandlerHandle = new API_DHStatusBillingDetailsHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DHStatus_Provisioning_Billing_Details_TRIGGER_HANDLER)){
            triggerHandlerHandle = new API_DHStatusProvisioningHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DHStatusPLGroupPortData_TRIG_HANDLER)){
            triggerHandlerHandle = new  API_DHStatusPLGroupPortDataHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DHStatusConnectionLevel_TRIG_HANDLER)){
            triggerHandlerHandle = new API_DHStatusConnectionLevelDataHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DHStatusCompletionDetails_TRIGGER_HANDLER)){
            triggerHandlerHandle = new API_DHStatusCompletionDetailsHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.DHStatus_Other_Providers_Trigger_HANDLER)){
            triggerHandlerHandle = new API_DHStatusOtherProvidersHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.RDSValidation_TRIGGER_HANDLER)){
            triggerHandlerHandle = new API_RDSValidationTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.RDSValidationConfig_TRIGGER_HANDLER)){
            triggerHandlerHandle = new API_RDSValidationConfigTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.Docusign_Recepient_Trigger_Handler)){
            triggerHandlerHandle = new SI_DocusignRecipientTriggerHandler();
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.CUST_SITE_QUOTE_TRIG_HANDLER)){
            triggerHandlerHandle = new SI_ATTCustomerSiteQuoteTriggerHandler(); 
         } else if(objectHandlerName.equalsIgnoreCase(SIConstants.RDS_CONTACT_TRIGGER_HANDLER)){
            triggerHandlerHandle = new SIRDSContactTriggerHandler(); 
         }else if(objectHandlerName.equalsIgnoreCase(SIConstants.RDS_CONTRACT_TRIGGER_HANDLER)){
            triggerHandlerHandle = new SIRDSContractDetailsTriggerHandler(); 
         }else if(objectHandlerName.equalsIgnoreCase(SIConstants.RDS_SWIP_CONTACTS_TRIGGER_HANDLER )){
            triggerHandlerHandle = new SIRDSSwipContactsTriggerHandler(); 
         }else if(objectHandlerName.equalsIgnoreCase(SIConstants.ASE_Wholesale_Contract_Number_TriggerHandler)){
            triggerHandlerHandle = new ASEWholesaleContractNumberTriggerHandler(); 
         }else if(objectHandlerName.equalsIgnoreCase(SIConstants.ASE_Billing_Account_Number_TriggerHandler)){
            triggerHandlerHandle = new ASEBillingAccountNumberTriggerHandler();            
         }else if(objectHandlerName.equalsIgnoreCase(SIConstants.WIRELINE_PROMOTION_RULE_TRIGGER_HANDLER)){
            triggerHandlerHandle = new WirelinePromotionRuleTriggerHandler();            
         }
         else if(objectHandlerName.equalsIgnoreCase('CaseTriggerHandler')){
            triggerHandlerHandle = new CaseTriggerHandler(); 
         } 
         else if(objectHandlerName.equalsIgnoreCase(SIConstants.AV_TRIG_HANDLER)){
            triggerHandlerHandle = new SI_ATTProductAttributeValueTrigger(); 
         }
         else if(objectHandlerName.equalsIgnoreCase(SIConstants.PROPOSAL_LINE_ITEM_TRIG_HANDLER)){
            triggerHandlerHandle = new ProposalLineItemTriggerHandler(); 
         }
           else {
          //Add the code in the above way with if else (******.) ACCOUNT_TRIG_HANDLER
         }
       }
     } 
     catch(Exception excep) {
       System.debug('Exception Caught :'+excep.getMessage());
     }
     return triggerHandlerHandle;
   } //End for getHandlerHandleObject
}