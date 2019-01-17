global class NetExamWebServiceAPIHelper82
{

    public class MissingAccountInformationException extends Exception{}
    public class NetExamWebserviceException extends Exception{}
    public with sharing class TestException extends Exception {}
    
    //NetExam Credentials         
    private static string ne_apiKey = System.Label.NE_API_KEY;
    private static string ne_apiUser = System.Label.NE_API_USER; 
    private static string ne_apiPass = System.Label.NE_API_PASS;      
    
    public static string contactSalesforceErrorMsg = 'Salesforce is unable to send the Contact details to NetExam. ';
    private static List<String> exceptionsContacts = new List<String>();
   
    @Future(callout=true)
    public static void SendContactListToNetExam(Set<Id> contactIDList)
    {
        try
        {
            
            webservicesNetexamComUserservice82.ArrayOfUserExtended Users = GetNetExamUsers(contactIDList);            
            
            if(Users != null)
            {
                BulkUpsertUsersWithUserGroups(Users);
            }            
            
        }
        catch(Exception e)
        {
            System.debug('SendContactListToNetExam Exception: ' + e);
        }
    }    
   
   
    public static webservicesNetexamComUserservice82.ArrayOfUserExtended GetNetExamUsers(Set<Id> contactIDList)
    {
      
         webservicesNetexamComUserservice82.ArrayOfUserExtended Users = new webservicesNetexamComUserservice82.ArrayOfUserExtended();
         Users.UserExtended =  new webservicesNetexamComUserservice82.UserExtended[]{}; 
         
         webservicesNetexamComUserservice82.UserExtended neUser = null;         
         
         try
         {
              for(String contactId: contactIDList)
              {
                  try
                  {           
                      neUser = CreateNetExamUser(contactId); 
                      
                      System.debug('FOUND CONTACT ID: ' + neUser.ExternalID);                                       
                       
                      if(neUser.ExternalID != '')
                      {
                          Users.UserExtended.Add(neUser);
                      }
                  }
                  catch(Exception innerEx)
                  {
                      //LOG AND MOVE ON TO NEXT CONTACT
                  }
        
               }
          }
          catch(Exception ex)
          {
              System.debug('GetNetExamUsers: ' + ex);
              throw ex;
          }
    
          return Users; 

    }

    public static webservicesNetexamComUserservice82.UserExtended CreateNetExamUser(string contactID)
    {
        string transactionResult = 'Contact Not sent: Invalid Contact ID';
        System.debug('called CreateNetExamUser');
        webservicesNetexamComUserservice82.UserExtended neUser = new webservicesNetexamComUserservice82.UserExtended();
        try
        {
            List<Contact>objContact =new List<Contact> ();
           
            if(String.isNotBlank(contactID))
            {
            
                 objContact = [Select 
                                ID,
                                FirstName,
                                LastName,
                                Email,
                                Phone,
                                MailingStreet,
                                MailingCity,
                                MailingCountry,
                                MailingState,
                                MailingPostalCode, 
                                ReportsToId,
                                PE_User_ID__c, 
                                NetExam_User_Type__c, 
                                User_Role__c, 
                                Training_Coordinator__c,                                     
                                Contact.Account.ID,
                                Contact.Account.BillingStreet,
                                Contact.Account.BillingCountry,
                                Contact.Account.BillingCity,
                                Contact.Account.BillingState,
                                Contact.Account.BillingPostalCode,
                                Contact.Account.Name           
                                FROM Contact WHERE Id = :contactID LIMIT 1];        
     
                                       
                if(objContact==null || objContact.size()==0)
                {
                     transactionResult = contactID + ': Contact Not sent. Invalid Contact ID';
                    exceptionsContacts.add(transactionResult);
                    return neUser;
                }
                
                  System.debug('objContact.size()='+objContact.size());  
                    
                if((String.isBlank(objContact[0].ID)) ||
                   (String.isBlank(objContact[0].Account.ID)) ||
                   (String.isBlank(objContact[0].FirstName)) ||
                   (String.isBlank(objContact[0].LastName)) ||
                   (String.isBlank(objContact[0].Email))
                ){
                    transactionResult = contactID + ': Contact Not Sent.Invalid Contact field values. Check Account, First Name, Last Name and Email';
                    exceptionsContacts.add(transactionResult);
                    return neUser;
                 }
                
               
            
                string sfdcContactID = objContact[0].ID;
                string firstName = objContact[0].FirstName;
                string lastName = objContact[0].LastName;
                string email = objContact[0].Email;                
                string accountID = objContact[0].Account.ID;
                string accountCountry = 'USA';
                string accountName = objContact[0].Account.Name;    
                //string accountStatus = objContact.Account.Account_Status__c; 
                            
                string language = 'English';
                string userType = 'Partner';
                string userRole = 'Student'; 
                string managerSFDCContactID = '';
                string UsersCountry = 'USA';
                string UsersStatus = '';        
                string userName = '';  
                string businessPhone = '';  
                string UsersUserType = '';
                string userActive = '1';
                string errorMsg = '';          
                
                
                //Optional variables: Default to empty strings if not used
                string jobTitle = '';
                string ContactsTimeZone = '';
                string personalEmail = '';
                string address1 = '';
                string address2 = '';
                string city = '';
                string postalCode = '';
                string state = '';
                string jobCategory = '';
                DateTime UsersStartDate = NULL;
                string UsersUserRole = '';
                string SalesforceUserID = '';
                String sfdcUserId = '';
                String hireDate = '';
                string formattedStartDate = '';
                string userGroupMgrUserId = '';
                string userGroupMgrContactId = '';
                string userGroupMgrExternalId = '';
                string secondaryUserGroup = 'Invalid';
                string groupName = '';
                Boolean bSendToNetExam = true;
                Boolean bUserTypeDefined = false;

                string partnerExchangeUserId = '';
                Boolean trainingCoordinator = false;
                
                
                //transactionResult = 'ACCOUNT STATUS: ' + accountStatus;
                //exceptionsContacts.add(transactionResult);
                //return neUser;
              
                
                if(!bSendToNetExam)
                {
                    transactionResult = contactID + ': Contact Not Sent. Please make sure the NetExam Access checkbox is checked';
                    exceptionsContacts.add(transactionResult);
                    return neUser;
                }
                            
               
                    
                //Check to make sure the required fields for the account object have the required information
                errorMsg = ValidateAccountData(accountName, accountID, accountCountry);        
                if(errorMsg != 'Success'){
                    transactionResult = contactID + ': Missing Account Information. Contact was not sent. ' + errorMsg;
                    exceptionsContacts.add(transactionResult);
                    return neUser;
                }
                        
                //Check to make sure the required fields for the account object have the required information
                errorMsg = ValidateContactData(sfdcContactID, firstName, lastName, email, language, userType, userRole, managerSFDCContactID);
                if(errorMsg != 'Success'){
                        
                    transactionResult = contactID + ': Missing Contact Data. Contact was not sent. ' + errorMsg;
                    exceptionsContacts.add(transactionResult);
                    return neUser;
                }                           
                
                //Get Business Phone
                try { businessPhone = ((String.isNotBlank(objContact[0].Phone)) ? objContact[0].Phone : '');} catch(Exception e){ businessPhone = '';}
                
                 //Get Street Address
                try { address1 = ((String.isNotBlank(objContact[0].MailingStreet)) ? objContact[0].MailingStreet : (String.isNotBlank(objContact[0].Account.BillingStreet)? objContact[0].Account.BillingStreet: ''));} catch(Exception e){ address1 = '';}
                        
                //Get City
                try { city = ((String.isNotBlank(objContact[0].MailingCity)) ? objContact[0].MailingCity : (String.isNotBlank(objContact[0].Account.BillingCity) ? objContact[0].Account.BillingCity : ''));} catch(Exception e){ city = '';}

                //Get the Country //check on null for account
                try { UsersCountry = ((String.isNotBlank(objContact[0].MailingCountry)) ? objContact[0].MailingCountry:(String.isNotBlank(objContact[0].Account.BillingCountry) ? objContact[0].Account.BillingCountry : 'USA')); } catch(Exception e){ UsersCountry = 'USA'; }
                
                //Get State 
                try { state = ((String.isNotBlank(objContact[0].MailingState)) ? objContact[0].MailingState : (String.isNotBlank(objContact[0].Account.BillingState) ? objContact[0].Account.BillingState : '')); } catch(Exception e){ state = ''; }

                //Get Postal Code
                try { postalCode = ((String.isNotBlank(objContact[0].MailingPostalCode)) ? objContact[0].MailingPostalCode : (String.isNotBlank(objContact[0].Account.BillingPostalCode) ? objContact[0].Account.BillingPostalCode : '')); } catch(Exception e){ postalCode = ''; }

                //Get the User Id for the user who is the Account owner
                try { userGroupMgrUserId = ((String.isNotBlank(objContact[0].Account.OwnerId)) ? objContact[0].Account.OwnerId : ''); } catch(Exception e){ userGroupMgrUserId = ''; }

                //Get Partner ExchangeUserId
                try { partnerExchangeUserId = ((String.isNotBlank(objContact[0].PE_User_ID__c)) ? objContact[0].PE_User_ID__c : ''); } catch(Exception e){ partnerExchangeUserId = ''; }
                        
                //Get Training Coordinator
                trainingCoordinator = objContact[0].Training_Coordinator__c; //)) ? objContact[0].Training_Coordinator__c : false); } catch(Exception e){ trainingCoordinator = false; }
                        
                //Get User Type
                try { userType = ((String.isNotBlank(objContact[0].NetExam_User_Type__c)) ? objContact[0].NetExam_User_Type__c : 'Solution Provider'); } catch(Exception e){ userType = 'Solution Provider'; }
        
                //Get User Role
                try { userRole = ((String.isNotBlank(objContact[0].User_Role__c)) ? objContact[0].User_Role__c : 'Student'); } catch(Exception e){ userRole = 'Student'; }
        
                //Manager SFDCID
                try { managerSFDCContactID = ((String.isNotBlank(objContact[0].ReportsToId)) ? objContact[0].ReportsToId : ''); } catch(Exception e){ UsersUserRole = ''; }
        
                //Populate User Name field in NE with Partner Exchange for SSO 
                userName = partnerExchangeUserId; 
        

                webservicesNetexamComUserservice82.AddressData address = new webservicesNetexamComUserservice82.AddressData();
                address.StreetAddress1 = address1;
                address.StreetAddress2 = '';
                address.City = city;
                address.State = state;
                address.PostalCode = postalCode;
                address.Country = UsersCountry; 

            
                // Ensure that we have a valid country by setting a default
               if(String.isBlank(accountCountry))
               {
                  accountCountry = 'USA';
               }       
               
               if(String.isBlank(UsersCountry)) 
               {
                  UsersCountry = 'USA';
               }       

               // Ensure that we have a valid language by setting a default
               if(String.isBlank(language))
               {
                  language = 'English';
               } 
                        
            
               Boolean emailOptIn = true;
               Boolean preserveUserGroup = false;

                
               //Try and pull the User Id from the User record if it exists
               List<User> objUser = [Select Id FROM User WHERE ContactId = :sfdcContactID LIMIT 1]; 
               if(objUser != null)
               {       
                  try{
                        sfdcUserId = objUser[0].Id;
                     }
                     catch(Exception e){
                      //Do Nothing with this exception
                       System.debug('Error Finding User: ' + e);             
                     }
               }     

               webservicesNetexamComUserservice82.ArrayOfCustomField CustomFields = new webservicesNetexamComUserservice82.ArrayOfCustomField();
               CustomFields.CustomField=  new webservicesNetexamComUserservice82.CustomField[]{};

               webservicesNetexamComUserservice82.CustomField PartnerExchangeID = new webservicesNetexamComUserservice82.CustomField();
               PartnerExchangeID.Name = 'Partner Exchange User ID';
               PartnerExchangeID.Value = partnerExchangeUserId;
                
               CustomFields.CustomField.add(PartnerExchangeID); 
               
               
               // Create the array of user groups to send to NetExam. Only the PrimaryGroup is required.
               webservicesNetexamComUserservice82.ArrayOfUserUserGroup Groups = new webservicesNetexamComUserservice82.ArrayOfUserUserGroup();
               Groups.UserUserGroup =  new webservicesNetexamComUserservice82.UserUserGroup[]{};              
                
                
               // ADD ACCOUNT AS PRIMARY USER GROUP
               webservicesNetexamComUserservice82.UserUserGroup PrimaryGroup = new webservicesNetexamComUserservice82.UserUserGroup();
               PrimaryGroup.Name = accountName;
               PrimaryGroup.ExternalID = accountID;
               PrimaryGroup.IsPrimaryUserGroup = 1;
               PrimaryGroup.Country = accountCountry;
               if(!trainingCoordinator)
                    PrimaryGroup.AccountManagerExternalID = '';
               else
                    PrimaryGroup.AccountManagerExternalID = sfdcContactID;
                
               Groups.UserUserGroup.add(PrimaryGroup); 
                             

                //NetExam User
                neUser.FirstName = firstName;
                neUser.LastName = lastName;
                neUser.UserName = userName;
                neUser.Email = email;
                neUser.BusinessPhone = businessPhone;
                neUser.PersonalEmail = personalEmail;
                neUser.address = address;
                neUser.TimeZone = ContactsTimeZone; 
                neUser.Language = language;
                neUser.UserGroups = Groups; 
                neUser.JobCategory = jobCategory; 
                neUser.JobTitle = jobTitle; 
                neUser.UserTypeName = userType; 
                neUser.ExternalID = sfdcContactID; 
                neUser.ExternalUserID = sfdcUserId;
                neUser.Status = userActive; 
                neUser.ManagerExternalID = managerSFDCContactID; 
                neUser.PreserveUserGroup = preserveUserGroup; 
                neUser.customFields = CustomFields;     
                neUser.UserRole = userRole;
                neUser.AlternateEmail = '';
                neUser.version = 0;   
                neUser.EmailOptIn= emailOptIn;      
                neUser.HireDate = DateTime.Now().format();
                neUser.RegistrationEmailType = 1;
                neUser.EmailCommunication = true;
                neUser.MessageWidgetCommunication = false;
            }
        }
        catch(Exception ex)
        {
           System.debug('CreateNetExamUser: ' + ex);              
           throw ex;
        } 
                       
        return neUser;

    }
   
 
   Webservice static string SendContactToNetExam(string contactID)
    {
        string transactionResult = 'Contact Sent Successfully';
        
        
        
        webservicesNetexamComUserservice82.UserExtended neUser = CreateNetExamUser(contactId);
        
        if(String.isBlank(neUser.ExternalID))
        {
            if(exceptionsContacts.size() > 0)
            {
                transactionResult = exceptionsContacts.get(0);
                exceptionsContacts.clear();
            }
        
        }
        else
        {
                          
             // Send the Contact to NetExam
             Boolean bStatus = ((neUser.Status=='1')?true:false);                                                                                                                                                                                                                                                                                                                                                         
             string errorMsg = UpsertUserWithUserGroupsExtended(ne_apiKey, 
                                                               ne_apiUser, 
                                                               ne_apiPass,
                                                               neUser.FirstName, 
                                                               neUser.LastName, 
                                                               neUser.UserName,
                                                               neUser.UserRole, 
                                                               neUser.Email, 
                                                               neUser.BusinessPhone, 
                                                               neUser.PersonalEmail, 
                                                               neUser.address,                                                                
                                                               neUser.TimeZone,                                                               
                                                               neUser.Language,
                                                               neUser.UserGroups, 
                                                               neUser.JobCategory, 
                                                               neUser.JobTitle, 
                                                               neUser.UserTypeName, 
                                                               neUser.ExternalID, 
                                                               neUser.ExternalUserID,
                                                               bStatus, 
                                                               neUser.ManagerExternalID, 
                                                               neUser.PreserveUserGroup,
                                                               //neUser.PreserveCustomFields, 
                                                               neUser.customFields, 
                                                               neUser.EmailOptIn,      
                                                               neUser.HireDate,
                                                               neUser.RegistrationEmailType,
                                                               neUser.EmailCommunication,
                                                               neUser.MessageWidgetCommunication);
               
                if(errorMsg != 'Success')
                {
                    transactionResult = 'Error Sending Data to NE web service. Contact was not sent. ' + errorMsg;
                }
                    
            }  
                    
                        
            return transactionResult;
    
    }

    public static void BulkUpsertUsersWithUserGroups(webservicesNetexamComUserservice82.ArrayOfUserExtended Users)
    {
       string ne_result = ''; 

       try{
           webservicesNetexamComUserservice82.UserServiceSoap ne_Webservice = new webservicesNetexamComUserservice82.UserServiceSoap();
           webservicesNetexamComUserservice82.ApiResult apiResult = ne_Webservice.BulkUpsertUsersWithUserGroups(ne_apiKey, ne_apiUser, ne_apiPass, Users);
           System.debug('Result: ' + apiResult.Code + ':' + apiResult.Description);
           ne_result = 'Success';

       }
       catch(System.CalloutException e){
            System.debug('Error: ' + e);            
            ne_result = e.getMessage().replace('Web service callout failed: WebService returned a SOAP Fault: ','').replace('faultcode=soap:Client faultactor=','');          
       }
    }
    
      
    //This method will create a user in NetExam OR if the user already exists(checked by sfdcContactID) the user's information will be updated.
    Public static string UpsertUserWithUserGroupsExtended(string apiKey, string apiUser, string apiPass, string firstName,string lastName, string userName, string userRole, string email, string businessPhone, string personalEmail, webservicesNetexamComUserservice82.AddressData address, string ContactsTimeZone, string language, webservicesNetexamComUserservice82.ArrayOfUserUserGroup Groups,string jobCategory, string jobTitle, string userType, string sfdcContactID, string sfdcUserId, Boolean status, string managerSFDCContactID, Boolean preserveUserGroup, webservicesNetexamComUserservice82.ArrayOfCustomField CustomFields, Boolean emailOptIn,string startDate,Integer RegistrationEmailType, Boolean EmailCommunication,Boolean MessageWidgetCommunication)
    {
        string ne_result = '';
       //INVOKE WEBSERVICE CALL TO ADD/UPDATE USER        
       
       try{
           webservicesNetexamComUserservice82.UserServiceSoap ne_Webservice = new webservicesNetexamComUserservice82.UserServiceSoap();
           webservicesNetexamComUserservice82.ApiResult Result = ne_Webservice.UpsertUserWithUserGroupsExtended(apiKey, apiUser, apiPass, firstName,lastName, userName, userRole, email, businessPhone, personalEmail, address, ContactsTimeZone, language, Groups, jobCategory, jobTitle, userType, sfdcContactID, sfdcUserId, status, managerSFDCContactID, preserveUserGroup, CustomFields, emailOptIn,startDate,RegistrationEmailType,EmailCommunication,MessageWidgetCommunication);
           System.debug('Result: ' + Result.Code + ':' + Result.Description);
           ne_result = 'Success';
        }
        catch(System.CalloutException e){
            System.debug('Error: ' + e);            
            ne_result = e.getMessage().replace('Web service callout failed: WebService returned a SOAP Fault: ','').replace('faultcode=soap:Client faultactor=','');          
        }
        
        return ne_result;  
        
    }  
   

    // NIyati- Testing Purpose 

    @Future(callout=true)
    public static void SendContactFromTrigger(string sfdcContactID, string firstName, string lastName, string email,string accountID)
    {       
        String accountName = '';
        String country = '';
        String language = 'English';
        String userType = 'EBM Employee';
        String userRole = 'Student';
        String managerSFDCContactID = ''; 

                
        //Depending on your account setup, you may need to alter where the country is pulled from. If no country is available for the account, you can pull it from another relationship or default it.
        //Common country fields: Account.BillingCountry, Account.ShippingCountry. If you change the email here, also change the variable name below at the country assignment
        List<Account> objAccount = [Select BillingCountry, Name FROM Account WHERE Id = :accountID LIMIT 1];        
        if(accountID != 'test')
        {
            try {
                accountName = objAccount[0].Name;
            }
            catch(Exception e){
                throw new MissingAccountInformationException('Account Could Not Be Found'); 
            }
        }
            
        //if we survived, we must be able to get account information, lets try the optional country field.
        try{
          country = objAccount[0].BillingCountry; //If you changed the query above, be sure to change the name of the variable here
        }
        catch(Exception e){
          // No real problem here, we must not have permissions to the billing fields, default to USA
        }      
          
        if(country == null) {country = 'USA';} 
        
      
        
        String returnValue = SendContactToNetExam( sfdcContactID);
        
            
        if( returnValue != 'Success' && accountID != 'test')            
        {
            throw new MissingAccountInformationException(returnValue); 
        }
        
        return;
    }   

   //This function to be called from trigger to send account/ update account to Net Exam
   @Future(callout=true) 
   public static void SendAccountFromTrigger (string AccountName, string AccountID, string AccountCountry)
   {
        string ne_result = SpecialCharacterConstant.CONCAT;      
        try{
            webservicesNetexamComUserservice82.UserServiceSoap ne_Webservice = new webservicesNetexamComUserservice82.UserServiceSoap();
            string Result = ne_Webservice.AddEditUserGroup(ne_apiKey , ne_apiUser , ne_apiPass , AccountName, AccountID, AccountCountry); 
            ne_result = UtilityConstant.SUCCESS;
        }
        catch(System.CalloutException e){
            ne_result = e.getMessage();          
        }
        return ;
    }

    
    //This method simply checks to make sure that there is enough information to create the user group. 
    // If these values are missing, the webservice would return an error.
    // NOTE: Not all params are required, so not all params are checked.
    public static string ValidateAccountData(string accountName, string accountID, string accountCountry)
    {
        string errorMsg = '';
       
        if(String.isNotBlank(accountID))
        {
            if(accountID.length() == 0){
                errorMsg = errorMsg + '<br>Account ID';
            }
        }
        else{
            errorMsg = errorMsg + '<br>Account ID';
        }        
        
        if(String.isNotBlank(accountName))
        {     
            if(accountName.length() == 0){
                errorMsg  = errorMsg + '<br>Account Name';
            }
        }
        else{
            errorMsg  = errorMsg + '<br>Account Name';
        }
        
        if(errorMsg.length() > 0){
            errorMsg = 'Missing required information: ' + errorMsg;
        }
        else{
            errorMsg = 'Success';
        }

        return errorMsg;
    }
    
    //This method simply checks to make sure that there is enough information to create the user group. 
    // If these values are missing, the webservice would return an error.
    // NOTE: Not all params are required, so not all params are checked.
    public static string ValidateContactData(string sfdcContactID, string firstName, string lastName, string email, string language, string userType, string userRole, string managerSFDCContactID)
    {
        string errorMsg = '';       
        
        //check null for all variables 
        if(String.isNotBlank(firstName))
        {
            if(firstName.length() == 0){
                errorMsg  = errorMsg + '<br>First Name';
            }
        }
        else{
            errorMsg  = errorMsg + '<br>First Name';
        }
        
        if(String.isNotBlank(lastName))
        {
            if(lastName.length() == 0){
                errorMsg = errorMsg + '<br>Last Name';
            }
        }
        else{
            errorMsg = errorMsg + '<br>Last Name';
        }
        
        if(String.isNotBlank(lastName))
        {
            if(email.length() == 0){
                errorMsg = errorMsg + '<br>Email';
            }
        }
        else{
            errorMsg = errorMsg + '<br>Email';
        }
        
        if(errorMsg.length() > 0){
            errorMsg = 'Missing required information: ' + errorMsg;
        }
        else{
            errorMsg = 'Success';
        }

        return errorMsg;
    
    }
    
    
        Webservice static string SendContactToNetExamExtended(string sfdcContactID, string firstName, string lastName, string email, string language, string userType, string userRole, string managerSFDCContactID, string accountName, string accountID, string accountCountry)
    {
                   
        string errorMsg = SpecialCharacterConstant.CONCAT; 
        string ContactsTimeZone = SpecialCharacterConstant.CONCAT;
        string UsersCountry = UtilityConstant.USA;
        string UsersStatus = SpecialCharacterConstant.CONCAT;
        string jobTitle = SpecialCharacterConstant.CONCAT;
        string userName = SpecialCharacterConstant.CONCAT;  
        string businessPhone = SpecialCharacterConstant.CONCAT;  
        string UsersUserType = userType; 
        Boolean userActive = true; 
        string UsersTeamMemberID = SpecialCharacterConstant.CONCAT;
        string UsersDepartment = SpecialCharacterConstant.CONCAT;
        Object RecordType = SpecialCharacterConstant.CONCAT;
        
        //Default these variables to Empty as they are not used in this integration
        string personalEmail = SpecialCharacterConstant.CONCAT;
        string address1 = SpecialCharacterConstant.CONCAT;
        string address2 = SpecialCharacterConstant.CONCAT;
        string city = SpecialCharacterConstant.CONCAT;
        string postalCode = SpecialCharacterConstant.CONCAT;
        string state = SpecialCharacterConstant.CONCAT;
        string jobCategory = SpecialCharacterConstant.CONCAT;
        DateTime UsersStartDate = NULL;
        string UsersUserRole = SpecialCharacterConstant.CONCAT;
        string SalesforceUserID = SpecialCharacterConstant.CONCAT;
        String sfdcUserId = SpecialCharacterConstant.CONCAT;       
                
        

        //Check to make sure the required fields for the account object have the required information
        errorMsg = ValidateAccountData(accountName, accountID, accountCountry);        
        if(errorMsg != UtilityConstant.SUCCESS){
            return 'Missing Account Information. Contact was not sent. ' + errorMsg;
        }
        
        //Check to make sure the required fields for the account object have the required information
        errorMsg = ValidateContactData(sfdcContactID, firstName, lastName, email, language, userType, userRole, managerSFDCContactID);
        if(errorMsg != UtilityConstant.SUCCESS){
            return 'Missing Contact Data. Contact was not sent. ' + errorMsg;
        }
             
        
        // Ensure that we have a valid country by setting a default
        integer accountCountryLength;
        accountCountryLength = accountCountry.length();
        if(accountCountryLength == 0){
            accountCountry = UtilityConstant.USA;
        }
        
        integer usersCountryLength;
        usersCountryLength = UsersCountry.length();
        if(usersCountryLength == 0){
            UsersCountry = UtilityConstant.USA;
        }        

        // Ensure that we have a valid language by setting a default
        integer languageLength;
        languageLength = language.length(); 
        if(languageLength == 0){
            language = UtilityConstant.ENGLISH;
        } 
        
        Boolean emailOptIn = true;
        Boolean preserveUserGroup = true;
        
        
        //Try and pull the User Id from the User record if it exists
        // This code was uncommnetd out to send SFDC UserId to Netexam.
        List<User> objUser = [Select Id FROM User WHERE ContactId = :sfdcContactID LIMIT 1];        
        try {
                sfdcUserId = objUser[0].Id;
        }
        catch(Exception e){
            //Do Nothing with this exception
        }      
        webservicesNetexamComUserservice82.ArrayOfCustomField CustomFields = new webservicesNetexamComUserservice82.ArrayOfCustomField();
        CustomFields.CustomField=  new webservicesNetexamComUserservice82.CustomField[]{};
        
          
        
         // Create the array of user groups to send to NetExam. Only the PrimaryGroup is required.
        webservicesNetexamComUserservice82.ArrayOfUserUserGroup Groups = new webservicesNetexamComUserservice82.ArrayOfUserUserGroup();
        Groups.UserUserGroup =  new webservicesNetexamComUserservice82.UserUserGroup[]{};
    
        
        // Add account as primary user group
        webservicesNetexamComUserservice82.UserUserGroup PrimaryGroup = new webservicesNetexamComUserservice82.UserUserGroup();
        PrimaryGroup.Name = accountName;
        PrimaryGroup.ExternalID = accountID;
        PrimaryGroup.IsPrimaryUserGroup = 1;
        PrimaryGroup.Country = accountCountry;
        PrimaryGroup.AccountManagerExternalID = SpecialCharacterConstant.CONCAT;   
        
        Groups.UserUserGroup.add(PrimaryGroup);     
        
                            
       string hireDate = SpecialCharacterConstant.CONCAT;         
        // Send the Contact to NetExam                                                                                                                                                                                                                                                                                                                                                          
      
      
      List<Contact> objContact = [Select ReportsToId,PE_User_ID__c, NetExam_User_Type__c,User_Role__c FROM Contact WHERE Id = :sfdcContactID LIMIT 1];        
       
       //Get Managers ID: //Manager (SFDC Record Id)
       try {                          
              managerSFDCContactID = objContact[0].ReportsToId; 
              if((String.isEmpty(managerSFDCContactID))||(managerSFDCContactID == SpecialCharacterConstant.CONCAT)) 
                  managerSFDCContactID = SpecialCharacterConstant.CONCAT;
            }
            catch(Exception e){
                  managerSFDCContactID = SpecialCharacterConstant.CONCAT;
            }

    //Get Partner Exchange User Id
    string partnerExchangeUserId = SpecialCharacterConstant.CONCAT;
       try {                          
              partnerExchangeUserId = objContact[0].PE_User_ID__c; 
              if((String.isEmpty(partnerExchangeUserId))||(partnerExchangeUserId == SpecialCharacterConstant.CONCAT)) 
                  partnerExchangeUserId = SpecialCharacterConstant.CONCAT;
            }
            catch(Exception e){
                  partnerExchangeUserId = SpecialCharacterConstant.CONCAT;
            }  
            //Populate User Name field in NE with Partner Exchange for SSO 
   userName = partnerExchangeUserId; 


 //Get NetExam User Type
       try {                          
              userType = objContact[0].NetExam_User_Type__c; 
              if((String.isEmpty(userType))||(userType == SpecialCharacterConstant.CONCAT)) 
                  userType = UtilityConstant.SOLUTIONPROVIDER;
            }
            catch(Exception e){
                  userType = UtilityConstant.SOLUTIONPROVIDER;
            }

 //Get NetExam User Role
       try {                          
              userRole = objContact[0].User_Role__c; 
              if((String.isEmpty(userRole))||(userRole == SpecialCharacterConstant.CONCAT)) 
                  userRole = UtilityConstant.STUDENT;
            }
            catch(Exception e){
                  userRole = UtilityConstant.STUDENT;
            }


    webservicesNetexamComUserservice82.CustomField PartnerExchangeID = new webservicesNetexamComUserservice82.CustomField();
        PartnerExchangeID.Name = UtilityConstant.PARTNEREXCHANGE_USER_ID;
        PartnerExchangeID.Value = partnerExchangeUserId;
                
        CustomFields.CustomField.add(PartnerExchangeID);
        
            List<Contact> objContactAddress = [Select MailingStreet, MailingCity, MailingState, MailingPostalCode  FROM Contact WHERE Id = :sfdcContactID LIMIT 1];   
             //Get Street Address
                try { address1 = ((String.isNotBlank(objContactAddress[0].MailingStreet)) ? objContactAddress[0].MailingStreet : SpecialCharacterConstant.CONCAT);} catch(Exception e){ address1 = SpecialCharacterConstant.CONCAT;}
                        
                //Get City
                try { city = ((String.isNotBlank(objContactAddress[0].MailingCity)) ? objContactAddress[0].MailingCity : SpecialCharacterConstant.CONCAT);} catch(Exception e){ city = SpecialCharacterConstant.CONCAT;}
               
                //Get State 
                try { state = ((String.isNotBlank(objContactAddress[0].MailingState)) ? objContactAddress[0].MailingState : SpecialCharacterConstant.CONCAT); } catch(Exception e){ state = SpecialCharacterConstant.CONCAT; }

                //Get Postal Code
                try { postalCode = ((String.isNotBlank(objContactAddress[0].MailingPostalCode)) ? objContactAddress[0].MailingPostalCode :SpecialCharacterConstant.CONCAT); } catch(Exception e){ postalCode = SpecialCharacterConstant.CONCAT; }
        
        webservicesNetexamComUserservice82.AddressData address = new webservicesNetexamComUserservice82.AddressData();
                        address.StreetAddress1 = address1;
                        address.StreetAddress2 = address2;
                        address.City = city;
                        address.State = state;
                        address.PostalCode = postalCode;
                        address.Country = UsersCountry; 
      
      Integer RegistrationEmailType = 1; 
      Boolean EmailCommunication = true; 
      Boolean MessageWidgetCommunication = false;
        
       errorMsg = UpsertUserWithUserGroupsExtended(ne_apiKey, ne_apiUser, ne_apiPass,firstName, lastName, userName,userRole, email, businessPhone, personalEmail, address, ContactsTimeZone, language,Groups, jobCategory, jobTitle, userType, sfdcContactID, sfdcUserId,userActive, managerSFDCContactID, preserveUserGroup, CustomFields, emailOptIn,hireDate, RegistrationEmailType, EmailCommunication, MessageWidgetCommunication );
       
        if(errorMsg != UtilityConstant.SUCCESS){
            return 'Error Sending Data to NE web service. Contact was not sent. ' + errorMsg;
        }
        
        return 'Success';         
    }   
}