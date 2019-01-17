/************************************************************************************** 
 Apex Class Name     : ContactUsController
 Version             : 1.0 
 Created Date        : 07 Oct 2014
 Function            : This class is the controller for Contact Us VF page 
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sruthy Dileep            10/07/2014              Original Version
* Gavin Johnson            11/12/2014              Major Revision
*************************************************************************************/

/* 
 Name: ContactUsController
 Type: Class 
 
 Description: 
 */ 
public class ContactUsController {
    
    public boolean authenticated {get;set;}
    private PageReference submitPageRef {get; set;}
    
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String companyName {get; set;}
    public String companyWebsite {get; set;}
    public String email {get; set;}
    public String phoneNumber {get; set;}
    public String service {get; set;}
    public String subject {get; set;}
    public String message {get; set;}
    private String queryNumber {get; set;}
                
    public String firstNameError {get; set;}
    public String lastNameError {get; set;}
    public String companyNameError {get; set;}
    public String companyWebsiteError {get; set;}
    public String emailError {get; set;}
    public String phoneNumberError {get; set;}
    public String serviceError {get; set;}
    public String subjectError {get; set;}
    public String messageError {get; set;}
    public String thankYouMessage {get; set;}
    
    private boolean firstNameValid {get; set;}
    private boolean lastNameValid {get; set;}
    private boolean companyNameValid {get; set;}
    private boolean companyWebsiteValid {get; set;}
    private boolean emailValid {get; set;}
    private boolean phoneNumberValid {get; set;}
    private boolean serviceValid {get; set;}
    private boolean subjectValid {get; set;}
    private boolean messageValid {get; set;}
    public boolean submitButtonEnabled {get; set;}
    
    public list<SelectOption> servicePickList {get; set;}


    /*
     * Method name  : ContactUsController
     * Description  : This method instantiates a ContactUsController object
     * Return Type  : None
     * Parameter    : None
     */ 
     
     
/* 
 Name: ContactUsController
 Description: 
 */ 
    public ContactUsController(){
        
        // Set the Service picklist values
        if (servicePickList == null) {
            servicePickList = new list<SelectOption>();    
        }
        servicePickList.add(new SelectOption(SpecialCharacterConstant.CONCAT, BuyflowConstant.SELECTA_SERVICE_PRODUCT));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_VIRTUAL_PRIVATE_NETWORK,BuyflowConstant.ATT_VIRTUAL_PRIVATE_NETWORK));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_MANAGED_INTERNET_SERVICES,BuyflowConstant.ATT_MANAGED_INTERNET_SERVICES));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_MPLS_PRIVATE_NETWORK_TRANSPORT,BuyflowConstant.ATT_MPLS_PRIVATE_NETWORK_TRANSPORT));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_NETWORK_BASED_IP_VPN_REMOTE_ACCESS,BuyflowConstant.ATT_NETWORK_BASED_IP_VPN_REMOTE_ACCESS));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_INTERNET_ACCESS,BuyflowConstant.ATT_INTERNET_ACCESS));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_NETWORK_BASED_FIREWALL_SERVICE,BuyflowConstant.ATT_NETWORK_BASED_FIREWALL_SERVICE));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_SWITCHED_ETHERNET_SERVICE,BuyflowConstant.ATT_SWITCHED_ETHERNET_SERVICE));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_IP_FLEXIBLE_REACH,BuyflowConstant.ATT_IP_FLEXIBLE_REACH));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_IP_TOLL_FREE,BuyflowConstant.ATT_IP_TOLL_FREE));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_WIRELESS,BuyflowConstant.ATT_WIRELESS));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_ENHANCED_PUSH_TO_TALK_SERVICE,BuyflowConstant.ATT_ENHANCED_PUSH_TO_TALK_SERVICE));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_BUSINESS_CONNECT,BuyflowConstant.ATT_BUSINESS_CONNECT));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_SYNAPTIC_COMPUTE_AS_A_SERVICE,BuyflowConstant.ATT_SYNAPTIC_COMPUTE_AS_A_SERVICE));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_SYNAPTIC_STORAGE_AS_A_SERVICE,BuyflowConstant.ATT_SYNAPTIC_STORAGE_AS_A_SERVICE));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_COLOCATION_HOSTING_SERVICES,BuyflowConstant.ATT_COLOCATION_HOSTING_SERVICES));
        servicePickList.add(new SelectOption(BuyflowConstant.ATT_PRIVATE_CLOUD,BuyflowConstant.ATT_PRIVATE_CLOUD));
        servicePickList.add(new SelectOption(BuyflowConstant.OTHER,BuyflowConstant.OTHER));
        
        // If the parameters have a Query Number, set the thank you messate and remove that parameter
        //submitPageRef = System.currentPageReference();
        //submitPageRef = Apexpages.Currentpage();
          submitPageRef = page.PortalDesign_ThankYouAuth;
        queryNumber = submitPageRef.getParameters().get('contactUsQueryNumber');
        if(queryNumber != null && queryNumber != ''){
            thankYou();
            System.currentPageReference().getParameters().remove('contactUsQueryNumber');
            submitPageRef.getParameters().remove('contactUsQueryNumber');
        }
        
        // Reset the class variables
        resetValues();
    }
    
/* 
 Name: enableSubmitButton
 Description: 
 */ 
    public void enableSubmitButton(){
        try{
        // Validate the field values
        firstNameValid = validateFirstName();
        lastNameValid = validateLastName();
        companyNameValid = validateCompanyName();
        companyWebsiteValid = validateCompanyWebsite();
        emailValid = validateEmail();
        phoneNumberValid = validatePhoneNumber();
        serviceValid = validateService();
        subjectValid = validateSubject();
        messageValid = validateMessage();
        
        submitButtonEnabled = (firstNameValid && lastNameValid && companyNameValid && companyWebsiteValid  && emailValid && phoneNumberValid && serviceVAlid && subjectValid && messageValid);
    }
    catch(Exception e){
    
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    }

    
    /*
     * Method name  : submitAction
     * Description  : This method is called when the Submit button is clicked. It validates fields, 
     *                creates the Contact Us Query record, sends emails, and sets Thank You text
     * Return Type  : PageReference
     * Parameter    : None
     */ 
/* 
 Name: submitAction
 Description: 
 */ 
    public PageReference submitAction(){
        try{
        PageReference ret;
        
        // Validate the field values
        firstNameValid = validateFirstName();
        lastNameValid = validateLastName();
        companyNameValid = validateCompanyName();
        companyWebsiteValid = validateCompanyWebsite();
        emailValid = validateEmail();
        phoneNumberValid = validatePhoneNumber();
        serviceValid = validateService();
        subjectValid = validateSubject();
        messageValid = validateMessage();
        
        // If field values are valid, create the Contact Us Query record, send emails, and set the Query Number in a parameter (to display thank you)
        if(firstNameValid && lastNameValid && companyNameValid && companyWebsiteValid && emailValid && phoneNumberValid && serviceVAlid && subjectValid && messageValid){
            try{
                Contact_Us_Query__c contactUsQuery = createContactUsQuery();
                if(contactUsQuery != null){
                    queryNumber = contactUsQuery.Name;
                    submitPageRef.getParameters().put('contactUsQueryNumber',queryNumber);
                    
                    Messaging.SingleEmailMessage spEmail = constructEmail(false);
                    Messaging.SingleEmailMessage ebmEmail = constructEmail(true);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {spEmail,ebmEmail},false);
                    thankYou();
                }
            } catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
            ret = submitPageRef;
        } else{
            ret = null;
        }
        
        return ret;
    }
    catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
    return null;
}
    }
    
    /*
     * Method name  : resetValues
     * Description  : This method resets the object's variables
     * Return Type  : None
     * Parameter    : None
     */ 
    private void resetValues(){
        
        // Reset the field values
        queryNumber = SpecialCharacterConstant.CONCAT;
        firstName = SpecialCharacterConstant.CONCAT;
        lastName = SpecialCharacterConstant.CONCAT;
        companyName = SpecialCharacterConstant.CONCAT;
        companyWebsite = SpecialCharacterConstant.CONCAT;
        email = SpecialCharacterConstant.CONCAT;
        phoneNumber = SpecialCharacterConstant.CONCAT;
        service = SpecialCharacterConstant.CONCAT;
        subject = SpecialCharacterConstant.CONCAT;
        message = SpecialCharacterConstant.CONCAT;
        
        // Get the current page reference to see if it's the authenticated page
        try{
            if(System.currentPageReference().getUrl().equalsIgnoreCase(Page.PortalDesign_ContactUsAuth.getUrl())){
                authenticated = true;
            } else{
                authenticated = false;
            }
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        // If authenticated, default fields from the user object
        if(authenticated){
            User userObj;
            try{
                userObj = [select id, FirstName, LastName, CompanyName, Email, Phone from User where id = :UserInfo.getUserId()];
            } catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
            
            if(userObj != null){
                firstName = (userObj.FirstName != null) ? userObj.FirstName : SpecialCharacterConstant.CONCAT;
                lastName = (userObj.LastName != null) ? userObj.LastName : SpecialCharacterConstant.CONCAT;
                companyName = (userObj.CompanyName != null) ? userObj.CompanyName : SpecialCharacterConstant.CONCAT;
                email = (userObj.Email != null) ? userObj.Email : SpecialCharacterConstant.CONCAT;
                if(userObj.Phone != null) {
                    phoneNumber = userObj.Phone;
                
                    phoneNumber = phoneNumber.remove(SpecialCharacterConstant.BLANK);
                    phoneNumber = phoneNumber.remove(SpecialCharacterConstant.OPEN_BRACE);
                    phoneNumber = phoneNumber.remove(SpecialCharacterConstant.CLOSE_BRACKET);
                    phoneNumber = phoneNumber.remove(SpecialCharacterConstant.HYPHEN);
                    phoneNumber = phoneNumber.remove(SpecialCharacterConstant.ADD);
                    phoneNumber = phoneNumber.removeStart(BuyflowConstant.SIVARConst_0);
                    phoneNumber = phoneNumber.removeStart(BuyflowConstant.SIVARConst_1);
                     if(!Pattern.matches('^[0-9]{10}$',phoneNumber)){
                        phoneNumber = SpecialCharacterConstant.CONCAT;
                    }
                }
            }
        }
        
        // Reset the validity booleans
        firstNameValid = false;
        lastNameValid = false;
        companyNameValid = false;
        companyWebsiteValid = false;
        emailValid = false;
        phoneNumberValid = false;
        serviceValid = false;
        subjectValid = false;
        messageValid = false;
        
        // Reset the field errors
        firstNameError = SpecialCharacterConstant.CONCAT;
        lastNameError = SpecialCharacterConstant.CONCAT;
        companyNameError = SpecialCharacterConstant.CONCAT;
        companyWebsiteError = SpecialCharacterConstant.CONCAT;
        emailError = SpecialCharacterConstant.CONCAT;
        phoneNumberError = SpecialCharacterConstant.CONCAT;
        serviceError = SpecialCharacterConstant.CONCAT;
        subjectError = SpecialCharacterConstant.CONCAT;
        messageError = SpecialCharacterConstant.CONCAT;
        
        submitButtonEnabled = false;
    

    }
    
    /*
     * Method name  : createContactUsQuery
     * Description  : This method creates the Contact Us Query record
     * Return Type  : Contact_Us_Query__c
     * Parameter    : None
     */ 
    private Contact_Us_Query__c createContactUsQuery(){
        Contact_Us_Query__c contactUsQuery = new Contact_Us_Query__c();
        
        // Set the Contact Us Query fields to the field values
        contactUsQuery.First_Name__c = firstName;
        contactUsQuery.Last_Name__c = lastName;
        contactUsQuery.Company_Name__c = companyName;
        contactUsQuery.Company_Website__c = companyWebsite;
        contactUsQuery.Email__c = email;
        contactUsQuery.Phone_Number__c = phoneNumber;
        contactUsQuery.Service__c = service;
        contactUsQuery.Subject__c = subject;
        contactUsQuery.Message__c = message;
        if(authenticated){
            contactUsQuery.User__c = UserInfo.getUserId();
        }
        
        // Insert the Contact Us Query record
        try{
            insert contactUsQuery;
            
            contactUsQuery = [SELECT Id, Name, First_Name__c, Last_Name__c, Company_Name__c, Company_Website__c, Email__c, Phone_Number__c, Service__c, Subject__c, Message__c FROM Contact_Us_Query__c WHERE Id =: contactUsQuery.Id];
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        
        return contactUsQuery;
    }
    
    /*
     * Method name  : constructEmail
     * Description  : This method constructs the SP or EBM email
     * Return Type  : Messaging.SingleEmailMessage
     * Parameter    : ebmEmailBool (boolean) - Whether the EBM email should be constructed or not
     */ 
    private Messaging.SingleEmailMessage constructEmail(boolean ebmEmailBool){
        Messaging.SingleEmailMessage ebmEmail = new Messaging.SingleEmailMessage();
        BrandTemplate brandTemplate;
        EmailTemplate emailTemplate;
        List<String> toList = new List<String>();
        String headerImgUrl, htmlBody, plainBody, ebmFirstNames;
        
        try{
            // Get the header image url
            brandTemplate = [SELECT Id, Value FROM BrandTemplate where DeveloperName = 'ATT_LetterHead'];
            headerImgUrl = brandTemplate.Value;
            headerImgUrl = headerImgUrl.substring(headerImgUrl.indexOf('"headerImage"'));
            headerImgUrl = headerImgUrl.substring(0,headerImgUrl.indexOf('</img>'));
            headerImgUrl = headerImgUrl.substring(headerImgUrl.indexOf('<![CDATA['),headerImgUrl.indexOf(']]>'));
            headerImgUrl = headerImgUrl.remove('<![CDATA[');
            
            // Set the email template to Contact_Us_EBM_Email_Template
            // Loop through Portal_Contact_Us_EBM_Email__c to get the internal user email addresses and first names
            if(ebmEmailBool){
                emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName =: ATT_Constant.EMAIL_TEMPLATE_EBM];
                
                List<Portal_Contact_Us_EBM_Email__c> ebmToList = [select First_Name__c, Last_Name__c, Email__c from Portal_Contact_Us_EBM_Email__c];
                
                integer loopCount = 0;
                for(Portal_Contact_Us_EBM_Email__c ebmEmailAddr : ebmToList){
                    toList.add(ebmEmailAddr.Email__c);
                    if(loopCount == 0){
                        ebmFirstNames = ebmEmailAddr.First_Name__c;
                    } else{
                        ebmFirstNames = ebmFirstNames + SpecialCharacterConstant.COMMA_SPACE + ebmEmailAddr.First_Name__c;
                    }
                    
                    loopCount++;
                }
            }
            // Set the email template to Contact_Us_SP_Email_Template
            else{
                emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName =: ATT_Constant.EMAIL_TEMPLATE_SP ];
                toList.add(email);
            }
            
            // Set the from, to, and subject
            OrgWideEmailAddress fromAddress = [select Id from OrgWideEmailAddress where DisplayName = 'partnerexchangesupport@m2k.att-mail.com'];
            ebmEmail.setOrgWideEmailAddressId(fromAddress.Id);
            ebmEmail.setToAddresses(toList);
            ebmEmail.setSaveAsActivity(false);
            ebmEmail.setSubject(emailTemplate.subject);
            
            // Replace the dynamic fields in the email template
            htmlBody = emailTemplate.HtmlValue;
            plainBody = emailTemplate.Body;
           
            if(ebmEmailBool){
                htmlBody = htmlBody.replace('{!ebmFirstNames}', ebmFirstNames);
                plainBody = plainBody.replace('{!ebmFirstNames}', ebmFirstNames);
            }
            htmlBody = htmlBody.replace('{!headerImage}', headerImgUrl);
            htmlBody = htmlBody.replace('{!queryNumber}', queryNumber);
            plainBody = plainBody.replace('{!queryNumber}', queryNumber);
            htmlBody = htmlBody.replace('{!firstName}', firstName);
            plainBody = plainBody.replace('{!firstName}', firstName);
            htmlBody = htmlBody.replace('{!lastName}', lastName);
            plainBody = plainBody.replace('{!lastName}', lastName);
            htmlBody = htmlBody.replace('{!phoneNumber}', phoneNumber);
            plainBody = plainBody.replace('{!phoneNumber}', phoneNumber);
            htmlBody = htmlBody.replace('{!email}', email);
            plainBody = plainBody.replace('{!email}', email);
            htmlBody = htmlBody.replace('{!companyName}', companyName);
            plainBody = plainBody.replace('{!companyName}', companyName);
            htmlBody = htmlBody.replace('{!companyWebsite}', companyWebsite);
            plainBody = plainBody.replace('{!companyWebsite}', companyWebsite);
            htmlBody = htmlBody.replace('{!subject}', subject);
            plainBody = plainBody.replace('{!subject}', subject);
            htmlBody = htmlBody.replace('{!service}', service);
            plainBody = plainBody.replace('{!service}', service);
            htmlBody = htmlBody.replace('{!message}', message.replace('\n','<br />'));
            plainBody = plainBody.replace('{!message}', message);
            
            // Set the email body to the email template body with the replaced dynamic fields
            ebmEmail.setHtmlBody(htmlBody);
            ebmEmail.setPlainTextBody(plainBody);
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        
        return ebmEmail;
    }
    
    /*
     * Method name  : thankYou
     * Description  : This method constructs the Thank You message and resets object variables
     * Return Type  : None
     * Parameter    : None
     */ 
    private void thankYou(){
        
        // Set the Thank You message
         thankYouMessage = 'Your request was submitted successfully (Query Number: ' + queryNumber + '). You will receive a confirmation email soon. Thank you for contacting AT&T.';
        
        // Reset the class variables
        //resetValues();
    
 
    }
    
    /*
     * Method name  : validateFirstName
     * Description  : This method validates the First Name variable
     * Return Type  : boolean
     * Parameter    : None
     */ 
    private boolean validateFirstName(){
        
        boolean ret;
        
        firstNameError = SpecialCharacterConstant.CONCAT;
        ret = validateFieldNotEmpty(firstName);
        if(ret){
            ret = (ret && validateFieldNoBegSpace(firstName));
            
            if(!ret){
                firstNameError = Label.First_Name + BuyflowConstant.CANNOT_BEGIN_WITH_A_SPACE;
            }
        } else{
            firstNameError = Label.First_Name + BuyflowConstant.MUST_BE_SPECIFIED;
        }
        
        return ret;
    }
 
    
    
    /*
     * Method name  : validateLastName
     * Description  : This method validates the Last Name variable
     * Return Type  : boolean
     * Parameter    : None
     */ 
    private boolean validateLastName(){
        
        boolean ret;
        
        CompanyNameError = SpecialCharacterConstant.CONCAT;
        ret = validateFieldNotEmpty(lastName);
        if(ret){
            ret = (ret && validateFieldNoBegSpace(LastName));
            
            if(!ret){
                lastNameError = Label.Last_Name + BuyflowConstant.CANNOT_BEGIN_WITH_A_SPACE;
            }
        } else{
            lastNameError = Label.Last_Name + BuyflowConstant.MUST_BE_SPECIFIED;
        }
        
        return ret;
    }

    
    
    /*
     * Method name  : validateCompanyName
     * Description  : This method validates the Company Name variable
     * Return Type  : boolean
     * Parameter    : None
     */ 
    private boolean validateCompanyName(){
        
        boolean ret;
        
        companyNameError = SpecialCharacterConstant.CONCAT;
        ret = validateFieldNotEmpty(companyName);
        if(ret){
            ret = (ret && validateFieldNoBegSpace(companyName));
            
            if(!ret){
                companyNameError = Label.Company_Name + BuyflowConstant.CANNOT_BEGIN_WITH_A_SPACE;
            }
        } else{
            companyNameError = Label.Company_Name + BuyflowConstant.MUST_BE_SPECIFIED;
        }
        
        return ret;
    }
 
    
    
    /*
     * Method name  : validateCompanyWebsite
     * Description  : This method validates the Company Website variable
     * Return Type  : boolean
     * Parameter    : None
     */ 
    private boolean validateCompanyWebsite(){
        
        boolean ret;
        
        companyWebsiteError = SpecialCharacterConstant.CONCAT;
        ret = validateFieldNotEmpty(companyWebsite);
        if(ret){
            ret = (ret && validateFieldNoBegSpace(companyWebsite));                       
            if(!ret){
                companyWebsiteError = Label.Company_Website + BuyflowConstant.CANNOT_BEGIN_WITH_A_SPACE;
            }
        } else{
            companyWebsiteError = Label.Company_Website + BuyflowConstant.MUST_BE_SPECIFIED;
        }
        
        return ret;
    }
  
    
    /*
     * Method name  : validateEmail
     * Description  : This method validates the Email variable
     * Return Type  : boolean
     * Parameter    : None
     */ 
    private boolean validateEmail(){
        
        boolean ret;
        
        emailError = SpecialCharacterConstant.CONCAT;
        ret = validateFieldNotEmpty(email);
        if(ret){
            ret = (ret && validateFieldNoBegSpace(email));
            
            if(ret){
                ret = (ret && validateFieldEmail(email));
                
                if(!ret){
                    emailError = Label.Email + BuyflowConstant.HAS_TO_BE_A_VALID_EMAIL_ADDRESS;
                }
            } else{
                emailError = Label.Email + BuyflowConstant.CANNOT_BEGIN_WITH_A_SPACE;
            }
        } else{
            emailError = Label.Email + BuyflowConstant.MUST_BE_SPECIFIED;
        }
        
        return ret;
    }
  
    
    
    /*
     * Method name  : validatePhoneNumber
     * Description  : This method validates the Phone Number variable
     * Return Type  : boolean
     * Parameter    : None
     */ 
    private boolean validatePhoneNumber(){
        
        boolean ret;
        
        phoneNumberError = SpecialCharacterConstant.CONCAT;
        ret = validateFieldNotEmpty(phoneNumber);
        if(ret){
            ret = (ret && validateFieldNoBegSpace(phoneNumber));
            
            if(ret) {
                ret = (ret && validateFieldPhoneNumber(phoneNumber));
                if(!ret){
                    phoneNumberError = BuyflowConstant.AVALID_10_DIGIT_x + Label.Phone_Number + BuyflowConstant.IS_REQUIRED;
                }
            } else {
                phoneNumberError = Label.Phone_Number + BuyflowConstant.CANNOT_BEGIN_WITH_A_SPACE;
            }
        } else{
            phoneNumberError = Label.Phone_Number + BuyflowConstant.MUST_BE_SPECIFIED;
        }
        
        return ret;
    }
  
    
    
    /*
     * Method name  : validateService
     * Description  : This method validates the Service variable
     * Return Type  : boolean
     * Parameter    : None
     */ 
    private boolean validateService(){
        
        boolean ret;
        
        serviceError = SpecialCharacterConstant.CONCAT;
        ret = validateFieldNotEmpty(service);
        if(!ret){
            serviceError = Label.Service_Product + BuyflowConstant.MUST_BE_SPECIFIED;
        }
        
        return ret;
    }

    
    
    /*
     * Method name  : validateSubject
     * Description  : This method validates the Subject variable
     * Return Type  : boolean
     * Parameter    : None
     */ 
    private boolean validateSubject(){
        
        boolean ret;
        
        subjectError = SpecialCharacterConstant.CONCAT;
        ret = validateFieldNotEmpty(subject);
        if(ret){
            ret = (ret && validateFieldNoBegSpace(subject));
            
            if(!ret){
                subjectError = Label.Subject + BuyflowConstant.CANNOT_BEGIN_WITH_A_SPACE;
            }
        } else{
            subjectError = Label.Subject + BuyflowConstant.MUST_BE_SPECIFIED;
        }
        
        return ret;
    }

    
    
    /*
     * Method name  : validateMessage
     * Description  : This method validates the Message variable
     * Return Type  : boolean
     * Parameter    : None
     */ 
    private boolean validateMessage(){
        
        boolean ret;
        
        messageError = SpecialCharacterConstant.CONCAT;
        ret = validateFieldNotEmpty(message);
        if(ret){
            ret = (ret && validateFieldNoBegSpace(message));
            
            if(!ret){
                messageError = Label.Message + BuyflowConstant.CANNOT_BEGIN_WITH_A_SPACE;
            }
        } else{
            messageError = Label.Message + BuyflowConstant.MUST_BE_SPECIFIED;
        }
        
        return ret;        
    }
  
    
    /*
     * Method name  : validateFieldNotEmpty
     * Description  : This method validates a field value is not empty
     * Return Type  : boolean
     * Parameter    : None
     */ 
    private boolean validateFieldNotEmpty(string valString){
        
        boolean ret;
        if(valString != SpecialCharacterConstant.CONCAT && valString != null){
            ret = true;
        } else{
            ret = false;
        }
        return ret;
    }
 
    
    
    /*
     * Method name  : validateFieldNoBegSpace
     * Description  : This method validates a field value does not begin with a space
     * Return Type  : boolean
     * Parameter    : None
     */ 
    private boolean validateFieldNoBegSpace(string valString){
        
        boolean ret;
        string spaceString = SpecialCharacterConstant.BLANK;
        if(valString.charAt(0) != spaceString.charAt(0)){
            ret = true;
        } else{
            ret = false;
        }
        return ret;
    }
 
    
    
    /*
     * Method name  : validateFieldNotEmpty
     * Description  : This method validates an email field
     * Return Type  : boolean
     * Parameter    : None
     */ 
    private boolean validateFieldEmail(string valString){
        
        boolean ret;
        if(Pattern.matches('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9_%+-]+\\.[a-zA-Z.]+$', valString))
        {
            ret = true;
        } else {
            ret = false;
        }
        return ret;
    }

    
    
    /*
     * Method name  : validateFieldNotEmpty
     * Description  : This method validates a phone number field
     * Return Type  : boolean
     * Parameter    : None
     */ 
    private boolean validateFieldPhoneNumber(string valString){
        
        boolean ret;
        valString = valString.remove(SpecialCharacterConstant.BLANK);
        valString = valString.remove(SpecialCharacterConstant.OPEN_BRACE);
        valString = valString.remove(SpecialCharacterConstant.CLOSE_BRACKET);
        valString = valString.remove(SpecialCharacterConstant.HYPHEN);
        valString = valString.remove(SpecialCharacterConstant.ADD);
        valString = valString.removeStart(BuyflowConstant.SIVARConst_0);
        valString = valString.removeStart(BuyflowConstant.SIVARConst_1);
        
        if(Pattern.matches('^[0-9]{10}$',valString))
        {
            ret = true;
        } else {
            ret = false;
        }
        return ret;
    }
 
    
        
}