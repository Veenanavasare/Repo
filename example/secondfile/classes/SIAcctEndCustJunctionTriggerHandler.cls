public with sharing class SIAcctEndCustJunctionTriggerHandler extends SITriggerOperations.SITriggerImpl
{
    public List <End_Customer__c> endCust= Null;
    map <Id,End_Customer__c> flagMap = New map<Id,End_Customer__c>();
    public List <User> usr= New List<User>();
    map<Id,String> mailMap= New map<Id,String>();
    public List <Account_End_Customer_Junction__c> aeList= New List<Account_End_Customer_Junction__c>();
    public EmailTemplate notificationTamplate=[Select Subject,Name,Id,HtmlValue From EmailTemplate  where Name ='Named Endcustomer Creation Alert' limit 1] ;
    public override boolean onAfterInsert(SObject[] newObjects) {
      validateCreation(newObjects);
        
       //Code for User Story US699119 
      createSharingrule(newObjects);  
      return True;
    }
    public void validateCreation(SObject[] newObjects)
    {
        aeList=newObjects;
        set<id> idSet=New set<id>();
        set<id> acctOwnerSet= New set <id>(); 
        for(Account_End_Customer_Junction__c ae:aeList)
        {
            idSet.add(ae.End_Customer__c);
            acctOwnerSet.add(ae.Account_Owner__c);
        }   
        endCust=[Select Id,Name,Named_Account__c from End_Customer__c Where Id IN : idSet];
        usr = [Select Id,Email from User Where Id IN :acctOwnerSet];
        
        for(End_Customer__c ec: endCust)
        {
            flagMap.Put(ec.Id,ec);
        }
        for(User us:usr)
        {
            mailMap.put(us.Id,us.Email);
        }
        
        
        for(Account_End_Customer_Junction__c ae:aeList)
        {
                if ((flagMap.get(ae.End_Customer__c)).Named_Account__c)
                {
                    sendNotification(ae,'Created','as Named End Customer');
                }
        }
    }
    
    public void sendNotification(Account_End_Customer_Junction__c aecJunc,String mailfor, String val )
    {
        String htmlEmailbody;
       
        //List <Account_End_Customer_Junction__c> acjList= New List<Account_End_Customer_Junction__c>();
        //endCust=[Select Id,Name from End_Customer__c Where End_Customer__c.Id=:aecJunc.End_Customer__c];
        List <Id> uList= New List <Id>();
        List <String> emailAddress = New List<String>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        emailAddress.add(mailMap.get(aecJunc.Account_Owner__c));        
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() +'/' +aecJunc.End_Customer__c;              
        mail.setToAddresses(emailAddress);
        mail.setSubject(notificationTamplate.Subject);
        htmlEmailbody = notificationTamplate.HtmlValue;
        htmlEmailbody = htmlEmailbody.replace('<![CDATA[', '');
        htmlEmailbody = htmlEmailbody.replace('{!End_Customer__c.Name}' , (flagMap.get(aecJunc.End_Customer__c)).Name);
        htmlEmailbody = htmlEmailbody.replace('{!End_Customer__c.Link}' , fullFileURL);
        htmlEmailbody = htmlEmailbody.replace('{Action}',mailfor);
        htmlEmailbody = htmlEmailbody.replace('{text}',val);
        htmlEmailbody = htmlEmailbody.replace(']]>', '');
        mail.setHtmlBody(htmlEmailbody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        emailAddress.clear();        
    }
    
     /* Method to provide Sharing rules */    
    public static void createSharingrule(SObject[] newObjects){  
        
        List<Account_End_Customer_Junction__c> attEndCustomerList =  newObjects;
        Map<Id,Id> endCustomerAccountIDsMap = new Map<Id,Id>();
        for(Account_End_Customer_Junction__c sp: attEndCustomerList){
            if(!String.isEmpty(sp.Account__c))
                endCustomerAccountIDsMap.put(sp.End_Customer__c,sp.Account__c);
        }
        if(!Test.isRunningTest()){
        if(endCustomerAccountIDsMap.size()>0){
            SIHelper.createSPSharingPartnerRule(SIConstants.END_CUSTOMER_SHARE,endCustomerAccountIDsMap);
        }
        }
        
    }
}