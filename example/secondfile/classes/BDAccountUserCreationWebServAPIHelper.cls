/****
Class Desc: To create account and user in Business Direct via Mulesoft API
Author: Accenture
Version: 1.1
*****/
global class BDAccountUserCreationWebServAPIHelper
{
    public List<Account> AccountstoUpdate = new  List<Account>();
    //public static ATTRequestResponseBean CompleteResponse = new ATTRequestResponseBean();
    List<Contact> ListContact;
    //List<Account> ListAccount;
    Map<Id,Account> AccMap = new Map<Id,Account>();
    Map<Id,Contact> ConMap = new Map<Id,Contact>();
    
 //Method gets called on creation of account/customer to send company details to BD  
 @future(callout=true)
 public static void sendAccountDetailstoBD (Set<Id> SetOfAccountIds){
     Set<Id> AccountIdSet = new Set<Id>();
     List<Account> ListAccount = new List<Account>();
     List<Account> ListAccounttoProcess = new List<Account>();
     BDProvResponseBean resBean = new BDProvResponseBean();
     BDProvIntegrationHandler handler = new BDProvIntegrationHandler();
     String dummyRes = '';
     List<String> offerString = new List<String>();
     offerString.add('OTHER');
     List<String> appString = new String[]{'mapadvantage','tm','intsrvoffer','elecbllpymt'};
     //List<String> appString = new List<String>();
     //appString.add('mapadvantage');
     //appString.add('tm');
     try{
     if(SetOfAccountIds.size()>0){
         ListAccounttoProcess = [select id,name,BD_Company_ID__c from Account where ID IN: SetOfAccountIds];
     }
     BDAccountUserCreationWebServAPIHelper helperclass = new BDAccountUserCreationWebServAPIHelper();
     
      if(ListAccounttoProcess != null && ListAccounttoProcess.size() > 0 && ListAccounttoProcess.size() < Limits.getLimitCallouts()/3)
        {
        ListAccount = new List<Account>();
        for(Account acc:ListAccounttoProcess){
          
          BDAccountProvRequestBean mBean = new BDAccountProvRequestBean();
          mBean.name = acc.name;
          mBean.strata  = 'Signature_Client_Program';
          mBean.applications = appString;
          mBean.offers = offerString;
          
          if(test.isRunningTest()){
                    resBean = (BDProvResponseBean)JSON.deserialize(dummyRes,BDProvResponseBean.class);
                    }
          if(!test.isRunningTest()){
                    handler.AcctID = acc.ID;
                    resBean = (BDProvResponseBean)handler.handleServiceRequest(mBean);  
           system.debug('BD COMPANY ID: '+resBean.Id); 
                      
               acc.BD_Company_ID__c = resBean.Id;
               AccountIdSet.add(acc.id);
               ListAccount.add(acc);
               helperclass.AccMap.put(acc.id,acc);
               }
               
           }
           if(ListAccount.size()>0){
           
               //update ListAccount;
               //Call user creation methods after account is updated with BD Company ID
               //BDAccountUserCreationWebServAPIHelper helperclass = new BDAccountUserCreationWebServAPIHelper();
               helperclass.createContactsinBD(AccountIdSet);
               //helperclass.AccountstoUpdate = new List<Account>(ListAccount);
           }
        }
        
     
     }
     catch(exception exc){
            String exceptions = ATTException.constructExceptionMessageString(exc);
            system.debug('Exception while calling BD webservice'+exceptions);            
            
     }
 }
 
 // Method to call contact creation in BD method after Account is updated with BD COMPANY ID
 public void createContactsinBD(set<id> accountIdset){
     List<contact> ListContact = new List<contact>();
     if(accountIdset.size()>0){
         ListContact = [select id,firstname,lastname,account.BillingPostalCode,Partner_Exchange_User_Name__c,email,account.BD_Company_ID__c,BD_User_ID__c,BD_Trigger_Date_Time__c,BD_Provisioning_Type__c,MailingPostalCode from contact where accountId IN: accountIdset];
     }
     if(ListContact.size()>0){
         
         sendContactDetailstoBD(ListContact);
     }
     else if(AccMap.size()>0){
            updateAccounts(AccMap.values());
            BDwebServiceLogCreation wbCreator = new BDwebServiceLogCreation();
            wbCreator.insertWeBlogs();
     }
 }
    //Method gets called on creation of contact to send user details to BD 
    public void sendContactDetailstoBD (List<Contact> ListContacttoProcess){
        
        try{
            ListContact = new List<Contact>();
            BDProvResponseBean userResBean = new BDProvResponseBean();
            BDProvIntegrationHandlerForUser userHandler = new BDProvIntegrationHandlerForUser();
            String dummyRes = '';
            List<String> appString = new String[]{'mapadvantage','tm','intsrvoffer','elecbllpymt'};
            //List<String> appString = new String[]{'mapadvantage','tm'};
            
            
            integer limitCalls = (Limits.getLimitCallouts()*2)/3;
            
            if(ListContacttoProcess != null && ListContacttoProcess.size() < limitCalls){
            for(contact con:ListContacttoProcess){
                BDUserProvRequestBean uBean = new BDUserProvRequestBean();
                //DateTime dt = DateTime.now();
                //uBean.convId =  dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                uBean.Firstname = con.firstname;
                uBean.Lastname = con.Lastname;
                uBean.applications = appString;
                //uBean.companyId = con.account.BD_Company_ID__c;
                if(AccMap.keyset().contains(con.accountID)){
                    uBean.companyId = AccMap.get(con.accountID).BD_Company_ID__c;
                }
                else{
                     uBean.companyId = con.account.BD_Company_ID__c;
                }
                uBean.proposedId= con.Partner_Exchange_User_Name__c;
                uBean.emailAddress = con.Email;
                uBean.zipCode = con.account.BillingPostalCode;
                uBean.userType='Company_Admin'; 
                
                if(test.isRunningTest()){
                    userResBean = (BDProvResponseBean)JSON.deserialize(dummyRes,BDProvResponseBean.class);
                    }
                if(!test.isRunningTest()){
                    userHandler.ContID = con.ID;
                    userResBean = (BDProvResponseBean)userHandler.handleServiceRequest(uBean);  
                    system.debug('BD USER ID: '+userResBean.Id); 
                con.BD_User_ID__c = userResBean.Id;
                if(con.BD_Trigger_Date_Time__c == NULL){
                    con.BD_Trigger_Date_Time__c = datetime.now();
                }
                ListContact.add(con);
                }
                }
                
            }
            //Update accounts
            if(AccMap.size()>0){
            updateAccounts(AccMap.values());
            }
            //Update contacts with BD userID
            if(ListContact.size()>0){
                updateContacts(ListContact);
                
            }
            
            
        }Catch(Exception ex){
        
            String exceptions = ATTException.constructExceptionMessageString(ex);
            system.debug('Exception while calling BD webservice'+exceptions);  
        }
        //create web service logs after all callouts are completed
            BDwebServiceLogCreation wbCreator = new BDwebServiceLogCreation();
            wbCreator.insertWeBlogs();
    }
    //Update call for accounts
    public void updateAccounts(List<Account> Accts){
        try{
            update Accts;
        }
        Catch(Exception ex){
        
            String exceptions = ATTException.constructExceptionMessageString(ex);
            system.debug('Exception while creating accounts'+exceptions);  
        }        
    }
    //Update call for contacts
    public void updateContacts(List<Contact> Conts){
        try{
            update conts;
        }
        Catch(Exception ex){
        
            String exceptions = ATTException.constructExceptionMessageString(ex);
            system.debug('Exception while creating contacts'+exceptions);  
        }        
    }
 //Future call only for manually created contacts where existing account is there   
 @future(callout=true)
 public static void sendUserDetailstoBDhelper (Set<Id> SetOfContactIds){
         List<Contact> conToProcess = new List<Contact>();
         conToProcess = [select id,firstname,lastname,Partner_Exchange_User_Name__c,BD_Trigger_Date_Time__c,email,account.BillingPostalCode,account.BD_Company_ID__c,BD_User_ID__c,BD_Provisioning_Type__c,MailingPostalCode from contact where Id IN: SetOfContactIds];
         BDAccountUserCreationWebServAPIHelper helperclass = new BDAccountUserCreationWebServAPIHelper();
         helperclass.sendContactDetailstoBD(conToProcess);
 }
}