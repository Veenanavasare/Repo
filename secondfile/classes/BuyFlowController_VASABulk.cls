/************************************************************************************** 
 Apex Class Name     : BuyFlowController_VASABulk
 Version             : 1.0 
 Created Date        : 21 AUG 2014
 Function            :
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Md Khalid Munavar Ali       3/12/2014              Original Version
*************************************************************************************/

public with sharing class BuyFlowController_VASABulk {
    public String Message {get;set;}
    public Apttus_Proposal__Proposal__c quote {get;set;}   
    public boolean userBeginQuote{get; set;} 
    public String subAccNo{get;set;}
    public String contractEndDate{get;set;}
    public Boolean isEnterAddressStep{get;set;}
    public Boolean tokenMode{get;set;}
    public String prodName{get;set;}
    public BuyFlowController_VASABulk() {
        isEnterAddressStep = false;
        tokenMode = false;
        Integer maxSites =  Integer.valueOf(Max_sites_allowed_VASA__c.getValues('VASA_max_sites_allowed') != null ? Max_sites_allowed_VASA__c.getValues('VASA_max_sites_allowed').value__c: 0);                  
        string quoteId =  ApexPages.currentPage().getParameters().get('quoteid');
        string vasaMode =  ApexPages.currentPage().getParameters().get('vmode');
        if(quoteId!=null && !string.isBlank(quoteId)) {
            quote = [select name,MasterOpportunity__c,Buyflow_Step__c,Product__r.Name,Product__r.ProductCode,Send_Email_on_Service_Complete__c,Apttus_Proposal__Payment_Term__c,End_Customer__r.Name,Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id =:quoteId LIMIT 1];
        }
        if(quote != null){
            prodName = quote.Product__r.Name;
            if('AT&T Virtual Private Network'.equalsIgnoreCase(quote.Product__r.Name)){
                prodName +=' Service';
            }
            if(quote.Buyflow_Step__c != null && (quote.Buyflow_Step__c==BuyflowConstant.ADDSITES || quote.Buyflow_Step__c==BuyflowConstant.ADDSITE)){
                isEnterAddressStep = true;
            }
            if(quote.Product__r.ProductCode == BuyflowConstant.ASE){
                maxSites = Integer.valueOf(Max_Sites_Allowed_For_ITPA__c.getValues('ASE_ITPA_Max_Sites') != null ? Max_Sites_Allowed_For_ITPA__c.getValues('ASE_ITPA_Max_Sites').value__c: 30);
            }
            String oppId = '';
            String dhId = '';
            if(String.isNotBlank(quote.MasterOpportunity__c)){
                oppId = quote.MasterOpportunity__c;
            }
            if(String.isNotBlank(oppId)){
                dhId = [Select Id, RDS_Deal_Hash__c from Opportunity where Id =: oppId limit 1].RDS_Deal_Hash__c;
            }
            if(String.isNotBlank(dhId)){
                Deal_Hash__c deal = [Select Id,Sub_Account_Number__c,ContractEndDate__c from Deal_Hash__c where Id =: dhId Limit 1];
                subAccNo = deal.Sub_Account_Number__c;
                contractEndDate = deal.ContractEndDate__c;
            }
            if(vasaMode!=null && vasaMode.equals('A'))
            Message = 'The system will check for the validation on the sites and email you when it\'s ready.';
            if(vasaMode!=null && vasaMode.equals('B') && quote.Send_Email_on_Service_Complete__c == false)
            Message = 'You have submitted more than '+ maxSites +' sites.The system will check for the service availability on the sites and email you when it\'s ready.';
            if(vasaMode!=null && vasaMode.equals('D'))
            tokenMode = true;            
            if(vasaMode!=null && vasaMode.equals('B') && quote.Send_Email_on_Service_Complete__c == true)
            Message = 'The system will check for the service availability on the sites and email you when it\'s ready.';
        }
        User userObj;
        userObj = [select id, Begin_Quote__c from User where id = :UserInfo.getUserId()];
        userBeginQuote = userObj.Begin_Quote__c;
    }
    public PageReference updateQuote() {
        try {
            PageReference pageRef = page.PortalDashboard_UI;        
            string quoteId =  ApexPages.currentPage().getParameters().get('quoteid');
            Apttus_Proposal__Proposal__c quoteObj = new Apttus_Proposal__Proposal__c();                        
            if(quoteId!=null && !string.isBlank(quoteId)) {
                quoteObj.id = quoteId;
                quoteObj.Apttus_Proposal__Approval_Stage__c = 'Draft';
                update quoteObj;                            
                return pageRef;
            } 
            return null;       
        }catch(Exception e){            
            ATTException.createException('Error in BuyFlowController_VASABulk.updateQuote', e.getTypeName(), ATTException.constructExceptionMessageString(e));            
            return null;            
        } 
    }  
}