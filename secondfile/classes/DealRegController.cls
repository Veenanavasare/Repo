public  class DealRegController {

    public String tabSelected {get;set;}
    public boolean registerDealPage {get;set;}
    public boolean specialPriceRequest {get;set;}
    public boolean specialPriceConfirm {get;set;}
    public boolean orderConfirmationFlag {get;set;}
    public boolean STAASProduct{get;set;}
    public boolean pricingScheduleFlag {get;set;}
    public boolean productsetpage{get;set;}
    public boolean userBeginQuote{get; set;}
    public boolean AIAProduct{get;set;}
    public boolean ipflexTNCFlag {get;set;}
        public boolean ESignFlag {get;set;}
        public string pageToLoad{get;set;}
    
    public DealRegController() {
        User userObj;
        userObj = [select id, Begin_Quote__c from User where id = :UserInfo.getUserId()];
        userBeginQuote = userObj.Begin_Quote__c;

        tabSelected = 'reviewDealRegTab';
        String mode = ApexPages.currentPage().getParameters().get('mode');
        string procode = ApexPages.currentPage().getParameters().get('code');

        if(mode == 'regdeal') {
            registerDealPage = true;
        } else {
            registerDealPage = false;
        }
   
        if(procode== 'ANIRA') {
            productsetpage= true;
        } else {
            productsetpage= false;
        }
        if(procode== 'STAAS') {
            STAASProduct= true;
        } else {
            STAASProduct= false;
        }
        if(procode == 'AIA') {
            AIAProduct = true;
        } else {
            AIAProduct = false;
        }
        
        if(mode == 'spclPriceReq') {
            specialPriceRequest = true;
        } else {
            specialPriceRequest = false;
        }
        
        if(mode == 'spclPriceConf') {
            specialPriceConfirm = true;
        } else {
            specialPriceConfirm = false;
        }
        
        if(mode == 'orderConf') {
            orderConfirmationFlag = true;
        } else {
            orderConfirmationFlag = false;
        }
        if(mode == 'ipflexTNC') {
            ipflexTNCFlag = true;
        } else {
            ipflexTNCFlag = false;
        }
        
        if(mode == 'contract') {
            pricingScheduleFlag = true;
                ESignFlag = false;
            } else if(mode == 'ESign') {
                ESignFlag = true;
                pricingScheduleFlag = false;
            }
            else{
                ESignFlag = false;
            pricingScheduleFlag = false;
        }
            // PAGE LOAD CHECKS 
            if(!productsetpage && !STAASProduct && registerDealPage){
                pageToLoad = 'DealReg_ReviewDealRegistration';
    }
            else if(productsetpage && registerDealPage){
                pageToLoad = 'DealReg_ReviewDealRegistration_Anira';
            }
            else if(STAASProduct && registerDealPage){
                pageToLoad = 'DealReg_ReviewDealRegistration_STAAS';
            }
            else if(specialPriceRequest){
                pageToLoad = 'SpecialPricingRequest';
            }
            else if(specialPriceConfirm){
                pageToLoad = 'SpecialPricingConfirmation';
            }   
            else if(orderConfirmationFlag == true){
                pageToLoad = 'OrderConfirmation';
            }else if(pricingScheduleFlag == true){
                pageToLoad = 'PricingScheduleLaunch';
            }else if(ipflexTNCFlag == true){
                pageToLoad = 'ipflex_tnc';
            }else if(ESignFlag == true){
                pageToLoad = 'ESignLaunch';
            }else{
                pageToLoad = 'submitOrder';
            }                       
        }
        
    public pageReference redirectToErrorPage(){
        User userObj;
        userObj = [select id, Begin_Quote__c from User where id = :UserInfo.getUserId()];
        userBeginQuote = userObj.Begin_Quote__c;
        if( !userBeginQuote ){
        pageReference errorPage = new pageReference('/apex/basic_manage_template');
        errorPage.setRedirect(true);
        return errorPage;
        }
    return null;
} 
}