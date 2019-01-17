/************************************************************************************** 
Apex Class Name     : PortalDesignHeaderController
Version             : 1.0 
Created Date        : 10 Nov 2014
Function            : This class tracks the constants and provides actions
Modification Log    :
* Developer                    Date                    Description
* ----------------------------------------------------------------------------                 
* Gavin Johnson                11/10/2014              Original Version
* Karthik Govindaraju          Feb 02 2015             updating portal header to include functionality for logout and profile page.
*************************************************************************************/
/*
  Class Name: PortalDesignHeaderController 
  Description:  
*/                                                     

public with sharing class PortalDesignHeaderController {
    
    public string userFirstName{get; private set;}
    public string userSmallPhotoUrl{get; private set;}
    public user userObj{get; private set;}
    public user userObj1{get; private set;}
    public boolean userBeginQuote{get; set;}
    public boolean userCreateModifyProfile {get; set;}
    public string userCreateModifyProfile11 {get; set;}
    public string userLicenseType {get;set;}
    public Boolean isRedirect {get;set;}
    public String encryptedUrl{get;set;}
    public String deEncryptedUrl{get;set;}
    public String deEncryptedUrlMange{get;set;}    
    public String deEncryptedUrltest{get;set;}    
    public String ErrorMessage{ get; set; }
    public String aotsURL{get;set;}
    public Boolean aotsApiFlag{ get; set; }    
    public String aotsBdID{get;set;}
    public String aotsSaartID{ get; set; }
    public String aotsPhNum{ get; set; }
    public String aotsEmailId{ get; set; }
    public Boolean isCommunityUser{get;set;}
    public Boolean isGuest {get;set;}   
    public List<NewsroomPermission__c > newsroomName {get;set;}     
    public String BDUserID {get;set;}
    public Contact loggedinContact{get;set;}
    public boolean BDEbill{get;set;}
    public boolean BDsla {get;set;}
    public boolean BDnet {get;set;}
    public boolean AOTSTickets {get;set;}
    public boolean ManageMob{get;set;}
    public boolean supportCenter{get;set;}
    public Boolean isInternalUser{get;set;}
    public String peUserName {get;set;}
    public String peUserFLName {get;set;}
    public boolean acctraining {get;set;}
    public String NEUserRole {get;set;}
    public Boolean isBypassApplicationFreeze{get;set;}
    public Boolean isDeveloper{get;set;}
    public Boolean isAVPN{get;set;}
    public Boolean isMIS{get;set;}
    public Boolean isAIA{get;set;}
    public Boolean isIPFLEX{get;set;}
    public Boolean isASE{get;set;}
    public Boolean isFlexWare{get;set;}
    public Boolean isWirelessProduct{get;set;}
    public Boolean isANIRA{get;set;}
    public Boolean devFunds{get;set;}
    public Boolean isCampaignBuilderEnabled{get;set;}
    public Boolean isProposalBuilderEnabled{get;set;}
    public list<wrapperClass> wpList{get; set;}
    public integer unseenNotificationCount{get; set;}
    public static string loggedInUserId;
    public static list<User> userList;
    public static list<notifications__c> notificationList{get;set;}
    public integer unreadNotificationCount{get;set;} 
    public static map<string,string> userNotificationMap {get;set;}
    public static boolean notificationRead{get;set;}
    public static map<integer,string> yearMap=new map<integer,string>(); 
    public String billingStatusStr{get;set;}
    public Boolean emailNotificationFlag {get;set;}
    public Boolean documentArchive{get; set;}
    
    /* 
     Name: PortalDesignHeaderController
     Description: 
     */ 
    public  PortalDesignHeaderController(){
        notificationList = new list<notifications__c>();
        emailNotificationFlag = false;
        userList = new list<User>();
        unseenNotificationCount = 0;
        System.debug('inside const');
        wpList = new List<wrapperClass>();
        fetchNotifications();
        unseenNotificationCount = UnseenNotificationCount();
        newsroomName =[Select name from NewsroomPermission__c limit 1];        
        isRedirect = false;
        BDEbill = false;
        AOTSTickets = false;
        BDsla = false;
        BDnet = false;
        ManageMob = false;
        supportCenter= false;
        isDeveloper = false;
        isAVPN=false;
        isMIS=false;
        isASE=false;
        isANIRA=false;
        isAIA=false;
        isFlexWare=false;
        isWirelessProduct = false;
        isIPFLEX=false;
        devFunds = false;
        isCampaignBuilderEnabled = false;
        isProposalBuilderEnabled = false;         
        billingStatusStr = '';
        User userObj = new User();
        deEncryptedUrlMange = SpecialCharacterConstant.CONCAT;
        handlePortalDesignHeaderRequest();
        userCreateModifyProfile11  = 'https://test-www.wireless.att.com/b2bservlets/TCMLoginDispatch.dyn?loginChannel=EBM&uid=B73bea954e200dcc3bae5ff8a2ccbd6ae9b2375f8&sourceSystemId=Dummy%20company&profileType=PLATINUM&premierUserStatus=Exist&peDealId=EBM&enableDDR=true';
        deEncryptedUrltest ='http://www.youtube.com/watch?v=j6cxZp4ii6c';
         /*****************for BD user story**************/ 
         User userObj1 = new User();
         Contact contObj1;
         userObj1 = [select id, Partner_Exchange_User_Name__c, FirstName,LastName, ContactId, Bypass_Application_Freeze__c from User where id = :UserInfo.getUserId()];
         peUserName=userObj1.Partner_Exchange_User_Name__c;
         peUserFLName=userObj1.FirstName;
         isBypassApplicationFreeze = userObj1.Bypass_Application_Freeze__c;
            if(userObj1.ContactId != null)
            { 
                Id cntId = userObj1.ContactId; 
                If(cntId != null){
                    contObj1 = [Select id,Account.Training__c,Manage_Billing__c,Service_Assurance__c ,Billing_Status__c,accountId,BD_User_ID__c,User_Role__c,Partner_Exchange_User_Name__c from Contact where Id = :cntId];
                    loggedinContact = contObj1;
                    handleBDnAOTSLinkFromAccount();
                    if(contObj1 != null) {
                        BDUserID = contObj1.Partner_Exchange_User_Name__c;
                        acctraining=contObj1.Account.Training__c;
                        NEUserRole =contObj1.User_Role__c;
                    }
                }                
           }  
        /*********************End*********************/  
        /******For Email Notification User Story****/
        
        Admin_Control__c adminctrl = new Admin_Control__c();
        adminctrl = [select Portal_Email_Notifications__c from Admin_Control__c limit 1];
        if(adminctrl.Portal_Email_Notifications__c == true){
            emailNotificationFlag = true;
        }
        /******End******/
    }
    
    /*
    * Method name  : handleBDnAOTSLinkFromAccount
    * Description  : This method is called to see if the customer user is supposed to see the Support links
    * Return Type  : None
    * Parameter    : None
    */ 
    public void handleBDnAOTSLinkFromAccount(){
        try{
            if(loggedinContact != NULL){
            Account acc = [select Billing__c,BasicTier__c,Wireless_Product__c,API_Developer_Tools_Access__c,isMIS__c,ANIRA_Product__c,Flexware_Product_Page__c,ASE_Product__c,IPFlex_Product__c,isAVPN__c,AIA_Product__c,Trouble_Tickets__c,Service_Level_Agreements__c,Network_Status__c,Manage_My_Funds__c,Manage_Mobility_Services__c,Support_Center__c,Campaign_Builder_Access__c,Proposal_Builder_Access__c,Document_Archive__c  from Account where Id =: loggedinContact.accountId];
                
                
                if(loggedinContact.Manage_Billing__c == true && acc.Billing__c == true){
                    BDEbill = true;
                }
                
                 
                
               // BDEbill = (acc.Billing__c) ? true : false;
               if(loggedinContact.Billing_Status__c != null && !loggedinContact.Billing_Status__c.equals('')){
                    billingStatusStr = loggedinContact.Billing_Status__c;
                }
                if(loggedinContact.Service_Assurance__c == true && acc.Trouble_Tickets__c == true){
                    AOTSTickets = true;
                }
                
                if(loggedinContact.Service_Assurance__c == true && acc.Service_Level_Agreements__c == true){
                    BDsla = true;
                }
                
                if(loggedinContact.Service_Assurance__c == true && acc.Network_Status__c == true){
                    BDnet = true;
                }
                //AOTSTickets = (acc.Trouble_Tickets__c) ? true : false;
                //BDsla = (acc.Service_Level_Agreements__c) ? true : false;
                ManageMob = (acc.Manage_Mobility_Services__c) ? true : false;
                documentArchive = (acc.Document_Archive__c) ? true : false;
                supportCenter= (acc.Support_Center__c) ? true : false;
                isDeveloper = (acc.API_Developer_Tools_Access__c) ? true : false;
                isAVPN = (acc.isAVPN__c) ? true : false;
                isMIS = (acc.isMIS__c) ? true : false;
                isAIA = (acc.AIA_Product__c) ? true : false;
                isIPFLEX = (acc.IPFlex_Product__c) ? true : false;
                isASE = (acc.ASE_Product__c) ? true : false;
                isFlexWare = (acc.Flexware_Product_Page__c) ? true : false;
                isANIRA= (acc.ANIRA_Product__c) ? true : false;
                isWirelessProduct = (acc.Wireless_Product__c) ? true : false;
                //devFunds = (acc.Manage_My_Funds__c) ? true : false;
                //Updated as part of US756857
                  if(acc.Manage_My_Funds__c && !acc.BasicTier__c  ) 
                  {
                      devFunds=true; 
                    }else if(acc.BasicTier__c ){
                      
                      devFunds=false;
                   }
                isCampaignBuilderEnabled = (acc.Campaign_Builder_Access__c) ? true : false;
                isProposalBuilderEnabled = (acc.Proposal_Builder_Access__c) ? true : false;
            }
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }    
    
    /*
    * Method name  : handlePortalDesignHeaderRequest
    * Description  : This method is called when the header is loaded
    * Return Type  : None
    * Parameter    : None
    */ 
    public void handlePortalDesignHeaderRequest(){
        try{
            if( !Test.isRunningTest() ){
                // Adding new field AccountId
                userObj = [select id, UserType, Username, LastName, FirstName, Name, AccountId,CompanyName, Email, FullPhotoUrl, User_license_Type__c, SmallPhotoUrl, Begin_Quote__c, Create_Modify_Profile__c from User where id = :UserInfo.getUserId()];
                // Adding below list
                list<Attachment> Attch = new list<Attachment>();
                Attch = [select id,Name from Attachment where ParentId=:userObj.AccountId and name='SP Logo' limit 1];   
            //Boolean variable to identify community users without switch
            if(userObj.UserType==SIConstants.User_Type_Customer)
            { 
                  isCommunityUser=true;  
            }else
            {
                isCommunityUser=false;
            }    
            //Boolean variable to identfiy site users/Guest users
            if( userObj.UserType==SIConstants.User_Type_Guest ) 
            {
                isGuest = true;
            } 
            else 
            { 
                isGuest = false; 
            }
            //Boolean variable to identify internal users with switch
            if(userObj.UserType==BuyflowConstant.STANDARD)
            { 
                  isInternalUser=true;  
            }else
            {
                isInternalUser=false;
            }               
                userFirstName = userObj.FirstName;
                if (Attch.size() > 0){
                    userSmallPhotoUrl='/servlet/servlet.FileDownload?file='+Attch[0].Id;
                }else{
                    userSmallPhotoUrl = userObj.SmallPhotoUrl;
                }
                userBeginQuote = userObj.Begin_Quote__c;
                userLicenseType  = userObj.User_license_Type__c;
                userCreateModifyProfile  = userObj.Create_Modify_Profile__c;
                try {
                    checkPageAccessAndPermission(); 
                } catch (System.NullPointerException e) {
                    e.getmessage();
                } 
            }
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /* 
     Name: checkPageAccessAndPermission
     Description: 
    */
    public void checkPageAccessAndPermission(){
        try{
            if( !Test.isRunningTest() ){
                String currentPageName = getVFPageName();
                Buyflow_Pages__c csListObj = new Buyflow_Pages__c();
                csListObj = Buyflow_Pages__c.getInstance(currentPageName.toLowerCase());
                if( csListObj != null && ! userBeginQuote && userLicenseType  == 'Partner'){
                /*System.debug('Developer--IN');
PageReference pgRef = new PageReference('/basic_manage_template');
pgRef.setRedirect(true);
return pgRef;*/
                    isRedirect = true;
                }else {                
                    isRedirect = false;
                }
            } 
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }       
    }
    
    /* 
     Name: getVFPageName
     Description: 
     */ 
    public string getVFPageName() {
        try{
            String pagename;
            if( !test.isRunningTest() ){
                pageName = ApexPages.CurrentPage().getUrl();     // THIS IS THE CLOSEST YOU CAN GET SO FAR
            }else{
                pageName = 'https://testfeb-attpartnerexchange.cs18.force.com/apex/buyflow';
            }
            pageName = pageName.replaceFirst('/apex/','');          // IT ALWAYS STARTS WITH /APEX/ SO REMOVE IT
            pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');   // YOU WANT TO END AT THE QUESTION MARK BUT
            // YOU HAVE TO ENCODE IT FIRST
            string[] pageNameExtra = pageName.split('%3F',0);   // %3F IS THE VALUE OF THE QUESTION MARK IN UTF-8
            // SO YOU MAY SPLIT THE STRING AT THAT POINT
            pageName = pageNameExtra[0]; 
            // IN THE RESULTING ARRAY
            return pageName;                                        // HERE IS YOUR PRODUCT
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }
    
    
    /*
    * Method name  : portalLogOut
    * Description  : Business logic to end session of partner user on click of logout link.
    * Return Type  : pageReference 
    * Parameter    : None
    */ 
    public pageReference portalLogOut(){
        try{
            list<AuthSession> authSessionLoggedInUser = [select Id,LoginType, LogoutUrl, ParentId, SessionType, UserType, UsersId from AuthSession where UsersId = :UserInfo.getUserId() ]; 
            delete authSessionLoggedInUser;
            return null;
            
        }catch( Exception ex ) {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }
        return null;
    }
    
    /* 
     Name: callLoginDispatchService
     Description: 
    */ 
    public void callLoginDispatchService(){
        String encryptedString=null;
        Id contId;
        Contact contObj;
        Account acctObj;
        List<Map<String,String>> requestBeanList=null;
        try{            
            userObj = [select id, ContactId,Username, LastName, FirstName, Name, CompanyName, Email, FullPhotoUrl, User_license_Type__c, SmallPhotoUrl, Begin_Quote__c, Create_Modify_Profile__c from User where id = :UserInfo.getUserId()];
            if(userObj != null && userObj.ContactId != null)
            {
                contId =  userObj.ContactId; 
                contObj = [Select AccountId,Premier_Login__c from Contact where Id = :contId];
            }
            if(contObj != null)
            {
                acctObj = [select Id,Current_Tier__c,Name,Premier_Login__c from Account where Id = :contObj.AccountId];
            }
            
            Apex2JSON_LoginDispatchRequest requestBean = new Apex2JSON_LoginDispatchRequest();
            LoginDispatchService objService= new LoginDispatchService();
            
            List<String> qouteOb = new List<String>();
            qouteOb.add(acctObj.Name/**quoteObject.End_Customer__r.Name**/);
            qouteOb.add(acctObj.Current_Tier__c/**quoteObject.Apttus_Proposal__Account__r.Current_Tier__c**/);
            
            requestBeanList= new List<Map<String,String>>();
            Map<String,String> mapObj= new Map<String,String>();
            
            mapObj.put('ProvisioningServiceID','EBM'); 
            mapObj.put('SourceSystemUserID','Dummy company');
            mapObj.put('ProfileType',(!string.isBlank(acctObj.Current_Tier__c)?acctObj.Current_Tier__c.toUpperCase():'')); 
            mapObj.put('PremierLogin',(!string.isBlank(contObj.Premier_Login__c)?contObj.Premier_Login__c:'')); 
            mapObj.put('PremierUserStatus','Exist');
            mapObj.put('PremierOrderId','');
            requestBeanList.add(mapObj);
            
            requestBean = objService.populateRequestBean(requestBeanList); 
            
            Apex2JSON_LoginDispatchResponse responseBean = new Apex2JSON_LoginDispatchResponse();
            String strTemp = '{"LoginDispatchResponse": {"WSResponseHeader": null,"Header": {"sourceSystem": "EBM","sourceServerDomain": "ST","transactionID": "1413313506665"},"LoginDispatch": {"TokenURL": "C5j45mSEdqfz4f4GnrwR2T25tizY5gb3JoVNtWp8DiYOW5d+qvPx/ODmQIQqNXpZ1YkIjLwu5BAjDh3QmlrC4DKwTvbSrVqxh7OJdGDQy61pY0V/p3JINnSHoA3V59y8PyEKzw0ipJYRx7aH4P45A54fHUeYAPmhl7eJfTknjgvK3gInuom2gAc05rEGSSNfrWNXFcr7/OozXbrO2lDposIo1aWyIGxHHPbH1HDxrXGv6QKkir068oPZ4JYvmwvml9MLyBajtQ6FzExrjz+iWyEpyAIGMY920/wNhfDv9Qy6wU2my048Od2Cp5l7aPvg","Response": {"code": "200","description": "SUCCESS"}}}}';
            if(Test.isrunningTest()){
                responseBean  = (Apex2JSON_LoginDispatchResponse)JSON.deserialize(strTemp, Apex2JSON_LoginDispatchResponse.class);
            }
            if(!Test.isrunningTest()){               
                responseBean  = (Apex2JSON_LoginDispatchResponse)objService.handleLoginDispatchService(requestBean);
            }
            if(responseBean!=null&& responseBean.LoginDispatchResponse!=null &&
               responseBean.LoginDispatchResponse.LoginDispatch!=null &&
               responseBean.LoginDispatchResponse.LoginDispatch.response!=null) {
                   if(!responseBean.LoginDispatchResponse.LoginDispatch.response.code.equals('200') &&
                      responseBean.LoginDispatchResponse.LoginDispatch.response.description!=null &&
                      responseBean.LoginDispatchResponse.LoginDispatch.TokenURL == null) {
                          ErrorMessage = (!string.isBlank(responseBean.LoginDispatchResponse.LoginDispatch.response.description))?responseBean.LoginDispatchResponse.LoginDispatch.response.description:'';
                          encryptedUrl = '';
                          deEncryptedUrl = '';
                          return;
                      }else if(responseBean.LoginDispatchResponse.LoginDispatch.response.code.equals('200') &&
                               !String.isBlank(responseBean.LoginDispatchResponse.LoginDispatch.TokenURL)){
                                   encryptedString=responseBean.LoginDispatchResponse.LoginDispatch.TokenURL;
                               //    Blob encryptedUrl1 = Blob.valueOf(responseBean.LoginDispatchResponse.LoginDispatch.TokenURL);
                                   Blob encryptedUrl1 = EncodingUtil.base64Decode(encryptedString);
                                   
                                  // ATnT_Encrypt_LD__c base64Key = ATnT_Encrypt_LD__c.getValues('Encrypted_Key_Value__c');
                                  // Blob key = Blob.valueof(base64Key.Encrypted_Key_Value__c);
                                   ATnT_Encrypt_LD__c base64Key = ATnT_Encrypt_LD__c.getInstance();
                                   Blob key = EncodingUtil.base64Decode(base64Key.Encrypted_Key_Value__c);
                                   //Blob key = Blob.valueof(base64Key.Encrypted_Key_Value__c);
                                   Blob deEncryptedUrlB = Crypto.decryptWithManagedIV('AES256', key, encryptedUrl1);
                                   deEncryptedUrl = deEncryptedUrlB.toString();
                                   deEncryptedUrlMange = deEncryptedUrl;
                               }else{
                                   ErrorMessage = 'Premier is unavailable. Please try again later.';
                                   encryptedUrl = '';
                                   deEncryptedUrl='';
                                   return;
                               }
                               
               }else {
                   ErrorMessage = 'Premier is unavailable. Please try again later.';
                   encryptedUrl = '';
                   deEncryptedUrl='';
                   return;
               }
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.createException('Error in ProductInformationController.handleProductInfoRequest', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        encryptedUrl=encryptedString;
    }   
    
    /*
      Name: setupAotsValues   
      Description:  
    */                                                     
    public void setupAotsValues()
    {
        try{
            aotsURL =  Endpoint_URL__c.getValues(System.Label.END_POINT_AOTS) != null ? Endpoint_URL__c.getValues(System.Label.END_POINT_AOTS).URL__c : '';
            Id contId;
            Contact contObj;
            Account acctObj;
            userObj = [select id, ContactId,Username, LastName, FirstName, Name, CompanyName, Email, FullPhotoUrl, User_license_Type__c, SmallPhotoUrl, Begin_Quote__c, Create_Modify_Profile__c from User where id = :UserInfo.getUserId()];
        if(userObj != null && userObj.ContactId != null)
        {
                contId =  userObj.ContactId; 
                contObj = [Select AccountId,BD_User_ID__c,PE_User_ID__c,Email,Phone from Contact where Id = :contId];
            }
            if(contObj != null){
                acctObj = [select Id,API_Flag__c,Mobility_L2_ID__c,SAART_Customer_Account_ID__c from Account where Id = :contObj.AccountId];
            }
            
            if(contObj != null){
                aotsBdID = contObj.BD_User_ID__c;
                aotsPhNum =  contObj.Phone;
                aotsEmailId =  contObj.Email;
            }
            if(acctObj != null){
                aotsSaartID = acctObj.SAART_Customer_Account_ID__c;
            }       
            else{
                aotsSaartID = SpecialCharacterConstant.CONCAT;
            }
            if(aotsBdID != null && aotsBdID != SpecialCharacterConstant.CONCAT){
                aotsApiFlag = false;            
            }
            else{
                aotsApiFlag = true;     
            }
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }    
    
    /* 
     Name: selectDeEncrypted
     Description: 
     */ 
    public void selectDeEncrypted(){
        try{
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
       
    }
    //Method to update notification field on user once user reads a notification
    @RemoteAction
    public static boolean updateUserOnNotificationRead(string noId){
        integer tempCount = 0;
        boolean readCheck = false;
        list<string> ls = new list<string>();
        system.debug('QQQQQQQQQQQQ' + noId);
        loggedInUserId = userInfo.getUserId();
        if(loggedInUserId!=null && loggedInUserId!=Constant.EMPTY){
            userList = [select id,Read_Notification_IDs__c from user where id=: loggedInUserId limit 1];
        }
        system.debug('LLLLLLLLLLLL' + userList);
        if(!userList.isEmpty()){
            if(userList[0].Read_Notification_IDs__c == Constant.EMPTY || userList[0].Read_Notification_IDs__c == null){
                userList[0].Read_Notification_IDs__c = noId;
                readCheck = true;
            }else if(!userList[0].Read_Notification_IDs__c.contains(noId)){
                userList[0].Read_Notification_IDs__c = userList[0].Read_Notification_IDs__c+ Constant.COMMA +  noId;
                readCheck = true;
            }else{
                //if already ID is read return false
                readCheck = false;
            }       
        }
        if(!userList.isEmpty()){
            update userList;
        }
        return readCheck;
    }
    
    @remoteAction
    public static boolean updateUserOnNotificationSeen(){
        boolean seenCheck = false;
        loggedInUserId = userInfo.getUserId();
        if(loggedInUserId!=null && loggedInUserId!=Constant.EMPTY){
            userList = [select id,Seen_Notification_IDs__c from user where id=: loggedInUserId limit 1];
        }
        notificationList = [select Id,Description__c,CreateDateTime__c,Is_Active__c,Start_Date__c,End_Date__c from Notifications__c where Is_Active__c=: True ORDER BY CreateDateTime__c DESC];
        system.debug('LLLLLLLLLLLL' + userList);
        if(!userList.isEmpty() && !notificationList.isEmpty()){
            for(Notifications__c notObj: notificationList){
                if(userList[0].Seen_Notification_IDs__c == Constant.EMPTY || userList[0].Seen_Notification_IDs__c == null){
                    userList[0].Seen_Notification_IDs__c = notObj.id;
                } else if(!userList[0].Seen_Notification_IDs__c.contains(notObj.id)){
                    userList[0].Seen_Notification_IDs__c = userList[0].Seen_Notification_IDs__c+ Constant.COMMA +  notObj.id;
                }  
            }
        }
        if(!userList.isEmpty()){
            update userList;
            seenCheck = true;
        }
        return seenCheck;
    }
    
    public integer UnseenNotificationCount(){
        loggedInUserId = userInfo.getUserId();
        notificationList = [select Id,Description__c,CreateDateTime__c,Is_Active__c,Start_Date__c,End_Date__c from Notifications__c where Is_Active__c=: True ORDER BY CreateDateTime__c DESC];
        if(loggedInUserId!=null && loggedInUserId!=Constant.EMPTY){
            userList = [select id,Seen_Notification_IDs__c from user where id=: loggedInUserId limit 1];
        }
        if((userList[0].Seen_Notification_IDs__c == Constant.EMPTY || userList[0].Seen_Notification_IDs__c == null) && !notificationList.isEmpty()){
            unseenNotificationCount = notificationList.size();
        } else if((userList[0].Seen_Notification_IDs__c == Constant.EMPTY || userList[0].Seen_Notification_IDs__c == null) && notificationList.isEmpty()){
            return unseenNotificationCount;
        } else if(notificationList.isEmpty()){
            return unseenNotificationCount;
        } else {
            for(Notifications__c notObj: notificationList){
                if(!userList[0].Seen_Notification_IDs__c.contains(notObj.id)){
                    unseenNotificationCount = unseenNotificationCount + 1;
                }
            }
        }
        return unseenNotificationCount;
    }
    
    
    public void fetchNotifications(){
        unreadNotificationCount = 0;
        userNotificationMap = new Map<string,string>();
        loggedInUserId = userInfo.getUserId();
        notificationList = [select Id,Description__c,CreateDateTime__c,Is_Active__c,Start_Date__c,End_Date__c from Notifications__c where Is_Active__c=: True ORDER BY CreateDateTime__c DESC];
        system.debug('AAAAAAAAAAAAAAAA' + notificationList);        
        if(loggedInUserId!=null && loggedInUserId!=Constant.EMPTY){
            userList = [select id,Read_Notification_IDs__c from user where id=: loggedInUserId];
            system.debug('CCCCCCCCC' + userList);
            if(userList[0].Read_Notification_IDs__c != null && userList[0].Read_Notification_IDs__c != Constant.EMPTY){
                userNotificationMap.put(userList[0].id,userList[0].Read_Notification_IDs__c);
            } else {
                userNotificationMap.put(userList[0].id,Constant.EMPTY);
            }
        }
        if(!notificationList.isEmpty()){
            for(Notifications__c notObj : notificationList){
                wrapperClass wp = new wrapperClass(notObj);
                wpList.add(wp);
            } 
        }
        system.debug('SSSSSSSSSSSSSSSSSS' + wpList);
        if(!wpList.isEmpty()){
            for(wrapperClass wp : wpList){
                if(wp.readCheck == false){
                    unreadNotificationCount = unreadNotificationCount + 1;
                }
            }
        }
    }
    
    public class wrapperClass{
        public String description {get; set;}
        public boolean readCheck {get; set;}
        public string notificationId {get; set;}
        public string timeLeft {get; set;}
        
        public wrapperClass(Notifications__c notObj){
            description = notObj.Description__c;
            readCheck = PortalDesignHeaderController.fetchReadUnreadCheck(loggedInUserId,notObj.id);
            notificationId = notObj.Id;
            timeLeft = PortalDesignHeaderController.fetchTime(notObj);
        }
    }
    
    public static boolean fetchReadUnreadCheck(string userId,string notId){
        notificationRead = false;
        if(userNotificationMap.containsKey(userId)){
            string UserNotificationIds = userNotificationMap.get(userId);
            if(UserNotificationIds!= null && UserNotificationIds!= Constant.EMPTY ){
                if(UserNotificationIds.contains(notId)){
                    notificationRead = true;
                } 
            }
        }
        return notificationRead ;
    }
    
    public static string fetchTime(Notifications__c notification){
        yearMap.put(1,Constant.JAN);
        yearMap.put(2,Constant.Feb);
        yearMap.put(3,Constant.Mar);
        yearMap.put(4,Constant.Apr);
        yearMap.put(5,Constant.May);
        yearMap.put(6,Constant.Jun);
        yearMap.put(7,Constant.Jul);
        yearMap.put(8,Constant.Aug);
        yearMap.put(9,Constant.Sep);
        yearMap.put(10,Constant.Oct);
        yearMap.put(11,Constant.Nov);
        yearMap.put(12,Constant.Dec);
        String formattedDt = Constant.EMPTY;
        system.debug('x'+notification.CreateDateTime__c);
        Date createdDate = notification.CreateDateTime__c.date();
        system.debug('createdDate '+createdDate);
        if(createdDate==system.now().date() ){                                             
            String[] parts = notification.CreateDateTime__c.format().split(Constant.BLANK_VALUE);
            formattedDt = (parts.size() == 3) ? (parts[1] + ' ' + parts[2]) : parts[1]; 
            system.debug('time ' + formattedDt);
        } else if(createdDate.daysBetween(system.today())>=1) {
            if( createdDate.daysBetween(system.today())<=7){
                formattedDt = notification.CreateDateTime__c.format(Constant.E);
            } else if(createdDate.daysBetween(system.today())>7) { 
                formattedDt=yearMap.get(createdDate.month())+ Constant.BLANK_VALUE +createdDate.day();
            }
        }
        string UpperCaseDate = formattedDt.toUpperCase();
        return UpperCaseDate;
    } 
}