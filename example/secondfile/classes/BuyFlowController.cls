public with sharing class BuyFlowController{

public boolean userBeginQuote{get; set;}
public String quoteIdForLink {get; set;}
public Apttus_Proposal__Proposal__c quoteObjForLink {get; set;}
public boolean backToEnterAddressLink {get; set;}
    public BuyFlowController() {
    
        User userObj;
        userObj = [select id, Begin_Quote__c from User where id = :UserInfo.getUserId()];
        userBeginQuote = userObj.Begin_Quote__c;
        
        //Added to set flag for backtoenteraddress link on Review Address page
        if(quoteIdForLink == null) {
            quoteIdForLink = apexpages.currentpage().getparameters().get('quoteid');
        }
        if (quoteIdForLink !=NULL && quoteIdForLink != '') { 
            quoteObjForLink = [select id,Review_Address_Check__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteIdForLink)];
            backToEnterAddressLink = quoteObjForLink.Review_Address_Check__c;
        }  
    }
    //Method to go back to Enter Address from Review Address
    public PageReference goToEnterAddressPage() {
        if(quoteObjForLink!=NULL) {
            quoteObjForLink.Review_Address_Check__c = false;
        }
        if(!Test.isRunningTest()){
        update quoteObjForLink;
        }
        if(quoteObjForLink.Review_Address_Check__c == true) {
            backToEnterAddressLink = true;
        }
        else{
            backToEnterAddressLink = false;
        }
        
        PageReference AddaddressPage = system.page.buyflow;
        AddaddressPage.getParameters().put('mode', 'siteinfo');
        AddaddressPage.getParameters().put('quoteid', quoteObjForLink.id); 
        AddaddressPage.getParameters().put('buyflow', 'false');
        AddaddressPage.setRedirect(true);
        return AddaddressPage;
    }
    
   /*  public pageReference redirectToErrorPage(){
        User userObj;
        userObj = [select id, Begin_Quote__c from User where id = :UserInfo.getUserId()];
        userBeginQuote = userObj.Begin_Quote__c;
        if( !userBeginQuote ){
        pageReference errorPage = new pageReference('/apex/basic_manage_template');
        errorPage.setRedirect(true);
        return errorPage;
        }
    return null;
}*/

   /* public String tabSelected {get;set;}
    public static End_Customer__c selectedEndCustomer {get; set;}
    
    public BuyFlowController(){
        tabSelected = 'selectCustomer';
        system.debug ('main checkpoint :: ' + selectedEndCustomer);
    }
    
    public BuyFlowController(CustomerManagementController controller) {
        tabSelected = 'selectCustomer';
        system.debug ('main checkpoint 2:: ' + selectedEndCustomer);
    }
    
    public PageReference checkAuthentication() {
        if(!ATTUtils.isUserAuthenticated()) {
            return system.page.ATOMLoginError;
        }
        
        return null;
    }
    */

}