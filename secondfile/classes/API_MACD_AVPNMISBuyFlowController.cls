public with sharing class API_MACD_AVPNMISBuyFlowController {
    public boolean userBeginQuote{get; set;}
    public String customerName {get; set;}
    public String subAccNo {get; set;}
    public String conEndDate {get; set;}
    public String productName {get; set;}
    public String quoteId {get; set;}
    public String pageToLoad {get; set;}
    
    public API_MACD_AVPNMISBuyFlowController(){
        User userObj;
        userObj = [select id, Begin_Quote__c from User where id = :UserInfo.getUserId()];
        userBeginQuote = userObj.Begin_Quote__c;
        String quoteId = ApexPages.CurrentPage().getParameters().get('quoteId');
        String mode = ApexPages.CurrentPage().getParameters().get('mode');
        System.debug('---Quote Id---'+quoteId);
        try{
            if(quoteId != null){    
                String oppId = [Select Id, MasterOpportunity__c from Apttus_Proposal__Proposal__c where Id =: quoteId Limit 1].MasterOpportunity__c;
                String dhId = [Select Id, RDS_Deal_Hash__c from Opportunity where Id =: oppId limit 1].RDS_Deal_Hash__c;
                Deal_Hash__c deal = [Select Id,End_Customer_Name__c,Sub_Account_Number__c,ContractEndDate__c,ServiceType__c
                                     from Deal_Hash__c where Id =: dhId Limit 1];
                customerName = deal.End_Customer_Name__c;
                subAccNo = deal.Sub_Account_Number__c;
                conEndDate = deal.ContractEndDate__c;
                if(deal.ServiceType__c.equals('MIS')) {
                    productName = 'Managed Internet Service';
                } else if(deal.ServiceType__c.equals('AVPN')) {
                    productName = 'AT&T Virtual Private Network Service';
                }
                if(mode == 'reviewquote'){
                    pageToLoad = 'API_MACD_ReviewQuote';
                }else{
                    pageToLoad = 'API_MACD_configuresite';
                }
            }
        } catch(Exception ex){
            System.debug('exception in consturctor Inventorylookup_SiteInventoryController'+ex);
        }
    }
}