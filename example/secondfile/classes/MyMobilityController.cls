public with sharing class MyMobilityController {
  public boolean displayPopup {get; set;}    
  public boolean userBeginQuote{get; set;} 
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    public MyMobilityController(){
        User userObj;
        userObj = [select id, Begin_Quote__c from User where id = :UserInfo.getUserId()];
        userBeginQuote = userObj.Begin_Quote__c;
    }
   /* public pageReference redirectToErrorPage(){
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
}