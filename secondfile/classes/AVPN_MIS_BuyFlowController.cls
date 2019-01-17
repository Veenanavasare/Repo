public with sharing class AVPN_MIS_BuyFlowController {
    public String tabSelected {get;set;}
    public boolean userBeginQuote {get;set;}
    public boolean isReviewMode {get;set;}
    Public boolean isConfigMode {get;set;}
    public Apttus_Proposal__Proposal__c proposalData {get;set;}
    public String quoteId {get;set;}
    public Boolean isAvpn {get;set;}
    public Boolean isMIS {get;set;}
    public Boolean isASE {get;set;}
    public string pageToLoad {get;set;}
    
    public AVPN_MIS_BuyFlowController(){
        User userObj;
        userObj = [select id, Begin_Quote__c from User where id = :UserInfo.getUserId()];
        userBeginQuote = userObj.Begin_Quote__c;
        tabSelected = 'configProduct';
        isConfigMode = false;
        isReviewMode = false;
        isMIS = false;
        isAvpn = false;
        isASE = false;
        if( ApexPages.currentPage().getParameters().get('mode') == 'confsites' ){
            isConfigMode = true;
        }
        if( ApexPages.currentPage().getParameters().get('mode') == 'reviewquote' ){
            isReviewMode = true;
        } 
        
        if(ApexPages.currentPage().getParameters().get('quoteId') != null){
            quoteId = ApexPages.currentPage().getParameters().get('quoteId'); 
            system.debug('Quote Id: '+quoteId);
            proposalData = new Apttus_Proposal__Proposal__c();
            proposalData = [SELECT Id, Product_Name__c FROM Apttus_Proposal__Proposal__c WHERE Id =:quoteId];
            if( proposalData.Product_Name__c == 'AT&T Virtual Private Network' ){
                isAvpn = true;
            }else if ( proposalData.Product_Name__c == 'AT&T Managed Internet Service' ){
                isMIS = true;
            }else if( proposalData.Product_Name__c == 'AT&T Switched Ethernet Service'){
                isASE = true;
            } 
        }
         if(isConfigMode){
            if(isASE){
                pageToLoad = 'configuresite_ase';
            }else{
                pageToLoad = 'configuresite';
            }
        }else{
            pageToLoad = 'ReviewQuote';
        }       
    }
}