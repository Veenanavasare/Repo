/************************************************************************************** 
Apex Class Name     : SiteAddressInformationController 
Version             : 3.0   
Created Date        : 15th Oct 2014
Function            : Controller for SiteAddressInformation VF page.
Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Arpan Kumar Patra         10/15/2014              Original Version
* Rahul Kunal               11/30/2014              Updated Version with AIA Changes and other defects
* Rahul Kunal               12/05/2014              Final version with all the defect fixes on code freeze
* 10842                     23/02/2016              Alternate Access  | Enter Address | Vasa or ITPA Error Message
*************************************************************************************/
global with sharing class SiteAddressInformationController{  
    
    public boolean checkServErr {get;set;}
    public boolean displayNoSiteAdded {get;set;}
    public WrapperUIRenderComponent wrcSites{get;set;}
    public boolean checkDiscard{get;set;}    
    public List<CustomerSite__c> listOfSitesToExport {get;set;}
    public CustomerSite__c customerSite {get; set;}
    public Id customerId {get; set;}
    private static String staticCustomerId = SpecialCharacterConstant.CONCAT;
    public Map <String, CustomerSite__c> siteDataMap {get; private set;}
    public String selectedSiteId {get; set;}
    public Id quoteId {get; set;}
    public Id cartId;   
    private Map<Id,CustomerSite__c> pageInsertedSitesMap;
    private Map<Id,AT_T_Customer_Site_Quote__c> junctionMap;    
    public Apttus_Proposal__Proposal__c quote {get; set;}
    public Apttus_Proposal__Proposal__c statusQuote {get; set;}
    public String country {get; set;}
    public QuoteInfoHelper Quotehelper;
    public String sSiteName {get; set;}   
    public String sCity {get; set;}
    public String sAddressLine {get; set;}
    public String sState {get; set;}
    public String sLocation {get; set;}
    public String sZip {get; set;}
    public String sPhone {get; set;}
    public String sRoomBuildingFloorInput {get; set;}
    public String productname {get; set;}
    public String custSiteIdASE {get;set;}
    public boolean checkStatusASE {get;set;}
    public boolean removePopupOnLoadFlag{get;set;}
    public Map<String,String> errMsgMap{get;set;}
    public List<String> tokenErrMap{get;set;}
    public Map<String,String> errorMap{get;set;}
    public Map<string,string> tokenErrorMap{get;set;} 
    PageReference AddaddressPageRef = system.page.buyflow;    
    public String selectedProductId;
    public String selectedProductCode;
    public Apttus_Proposal__Proposal__c proposalObject;
    public String ProposalName;
    public String tokenData{get;set;}
    public Boolean retrieveTokenOffline{get;set;}
        
    /*******************************************************************
    * VASA ADDRESS VALIDATION VARIABLES                 
    *******************************************************************/  
    public String VASArequest {get; set;}
    public AddrValidServAvailResponseBean VASAresponse {get; set;}
    public ASEITPAServiceAvailResponseBean ASEITPAresponse {get; set;}
    public List <AddressMatchDetails> exactAddressMatch {get; private set;}
    public List <AddressMatchDetails> closeAddressMatch {get; private set;}
    public List <AddressMatchDetails> noAddressMatch {get; private set;}
    public List <closeMatchAddressWrapper> closeMatchAddrWrapper {get; set;}
    public String addressLine {get; set;}
    public String room {get; set;}
    public String floor {get; set;}
    public String state {get; set;}
    public String location {get;set;}
    public String inpLocation {get;set;}
    public String inpRoomBuildingFloor {get;set;}
  
    /*******************************************************************
    * DISPLAY EXISTING SITE RECORDS
    *******************************************************************/  
    public List <CustomerSite__c> existingSitesList {get; private set;}     
    public Map <Id, matchIndicator> existingSiteValidationClassIndicatorMap {get; private set;  }
    public List <existingSitesWrapper> existingSitesWrapperList {get; private set;}
    public List <CustomerSite__c> selectedSitesList {get; private set;}
    private Map <Id,CustomerSite__c> selectedSitesMap;
    public String siteToUpdateId {get; set;}
    public String junctionToUpdateId {get; set;}        
    public String siteToRemoveId {get; set;}   
    Map<String,CustomerSite__c> siteToRequestMap = new Map<String,CustomerSite__c>();      
    public List<selectedSitesWrapper> selectedSitesWrapperList {get; set;}         
    
    /*******************************************************************
    * CONFIGURE SITES SELECTION DETAILS
    *******************************************************************/     
    public List<CustomerSite__c> validSitesToConfigureList {get; private set;}    
    public Boolean isConfigureReady {get; set;}    
    public Boolean isConfigured {get; set;}    
    public Boolean isSiteSelected {get; private set;}
    public Boolean isSelectAll {get; set;}
    private Boolean isSingleSiteSent;
    private boolean possibleMatchFlag;
 
    /*******************************************************************
    * FILE UPLOAD 
    *******************************************************************/      
    public blob contentFile {get; set;}
    public String nameFile {get; set;}
    public string strDocUrl {get; set;}
    String[] filelines = new String[]{};
    public List<CustomerSite__c> uploadedSites {get; private set;}
    public String BulkUploadMsg {get; set;}    
    public String fileContentType {get; set;}    
    public string excelBody{get;set;}
          
    
    /*******************************************************************
    * LATA SELECT 
    *******************************************************************/    
    public Map<Integer,List<CustomerSite__c>> mapOfSites = new Map<Integer,List<CustomerSite__c>>();
    private Map<String,List<CustomerSite__c>> mapOfLATAandSites = new Map<String,List<CustomerSite__c>>();
    public String ASE_type {get; set;}
    public String selectedCloseRadio {get;set;}
    public String adressCorrectionSiteId {get;set;}
    
    /*******************************************************************
    * SITE SELECTION FOR AIA PRODUCTS
    *******************************************************************/          
    public Boolean isAIASelected {get; set;}    
    public BRASS_Acknowledgement_Response BRASSresponse {get; set;}
    public Boolean doPolling {get; set;}
    public String conversationID {get; set;}
    
    /*******************************************************************
    * INSUFFICIENT PRIVILAGES FOR BEGIN QUOTE
    *******************************************************************/     
    public boolean userBeginQuote{get; set;}     

    /*******************************************************************
    * VARIABLES ADDED FOR FRAMEWORK AND REVIEW ADDRESS PAGE
    *******************************************************************/     
    public transient WrapperUIRenderComponent wrc{get;set;}  
    public Boolean isReviewAddress{get;set;}
    public Boolean isEmailSelected{get;set;}
    public Boolean isConfigMode;
    public Boolean isReviewMode;
    public Boolean isSiteInfoMode;
    public Boolean addSiteSuccess{get;set;}
    public Boolean FirstTimeUserASE{get;set;}
    public Boolean isITPAOnline{get;set;}
    public List<CustomerSite__c> ITPAcustSiteList;
    public List<FlowITPARequestBean> ITPArequestList;
    public String requestContinue{get;set;}
    public String requestLabel;
    public List<String> requestLabelList;
    public List<String> resultList { get; set; }     
    public String result{get;set;}
    public Integer currentReqNo;
    public  Apttus_Proposal__Proposal__c  quoteObjITPA; 
    public list<CustomerSite__c> customerSiteErrorList;
    public Set<Id> failedCustomerSiteIds;
    public Set<Id> failedCustomerSiteIds2;
    public Set<Id> failedCustomerSiteIds3;
    public Set<Id> failedCustomerSiteIds4;
    public Map<String,String> tokenIdSiteNameMap = new Map<String,String>();
    
    /********************************
    * RETRIEVE TOKEN SITE
    ********************************/   
    public string userInputToken {get;set;}
    public boolean showRelatedSites{get;set;}
    public List<CustomerSite__c> lstCustomerSite{get;set;}
    public string tokensiteName{get;set;}
    public string tokenId{get;set;}
    public string tokenaddress{get;set;}
    public string tokenlocation{get;set;}
    public string tokencity{get;set;}
    public string tokenstate{get;set;}
    public string tokenzip{get;set;}
    public string tokenPortSpeed{get;set;}
    public string tokenAccessSpeed{get;set;}
    public string tokenquoteid{get;set;}
    public CustomerSite__c retreiveCustomerSite {get; set;}
    public String retreiveTokenErrorMsg {get; set;}
    
    /*******************************************************************
    * Retrieve Multiple Token  
    *******************************************************************/      
    public string strRetrieveTokenDocUrl {get;set;}
    public String retrieveExcelBody{get;set;} 
    public Boolean retrieveBulkTokenFlag{get;set;}
    public Boolean retrieveBulkErrorFlag{get;set;}
    public Boolean retrieveBulkSuccessFlag{get;set;}
    public Boolean retrieveBulkLimitExceeds{get;set;}
    public Boolean tokenBulkBatchPolling{get;set;}
    
    /*******************************************************************
    * Method name : SiteAddressInformationController (CLASS CONSTRUCTOR)
    * Description : Initialize variables and collections
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/    
    global SiteAddressInformationController() {
        tokenErrorMap = new Map<String,String>();
        tokenErrMap= new List<String>();
        tokenErrMap.add('2312d');
        tokenErrMap.add('tokenName');
        system.debug(' --- BulkUploadMsg value1=' +BulkUploadMsg);
        requestLabel='';
        currentReqNo=0;
        checkDiscard = false;
        requestLabelList=new List<String>();
        resultList = new List<String>();
        ITPAcustSiteList=new List<CustomerSite__c>();
        ITPArequestList=new   List<FlowITPARequestBean>();
        requestContinue='false';
        isITPAOnline=False;
        User userObj;
        failedCustomerSiteIds = new Set<Id>();
        failedCustomerSiteIds2 = new Set<Id>();
        failedCustomerSiteIds3 = new Set<Id>();
        failedCustomerSiteIds4 = new Set<Id>();
        removePopupOnLoadFlag = false;
        showRelatedSites = false;
        lstCustomerSite = new List<CustomerSite__c>();
        
        tokensiteName = '';
        tokenId = '';
        tokenaddress = '';
        tokenlocation = '';
        tokencity = '';
        tokenstate = '';
        tokenzip = '';
        tokenPortSpeed = ''; 
        tokenAccessSpeed = '';
        tokenquoteid = '';
        retreiveTokenErrorMsg = SpecialCharacterConstant.CONCAT;
        strRetrieveTokenDocUrl = SpecialCharacterConstant.CONCAT;
        retrieveExcelBody = SpecialCharacterConstant.CONCAT;
        retrieveBulkTokenFlag = false;
        retrieveBulkErrorFlag = false;
        retrieveBulkSuccessFlag = false;
        retrieveBulkLimitExceeds = false;
        tokenBulkBatchPolling = false;
        tokenIdSiteNameMap = new Map<String,String>();
  retrieveTokenOffline = false;
     
        userObj = [select id, Begin_Quote__c from User where id = :UserInfo.getUserId()];        
        userBeginQuote = userObj.Begin_Quote__c;
        Quotehelper= new QuoteInfoHelper();
        checkServErr = false;
        // Initialize all variables related to Customer Site and Single address validation. 
        customerSite = new CustomerSite__c();
        retreiveCustomerSite = new CustomerSite__c();
        customerSite.RoomBuildingFloorInput__c = SpecialCharacterConstant.CONCAT;
        customerSite.location__c = SpecialCharacterConstant.CONCAT;
        country = BuyflowConstant.US;
        pageInsertedSitesMap = new Map<Id,CustomerSite__c>();
        
        // Initialize all variables related to Single Address VASA validation.
        exactAddressMatch = new List <AddressMatchDetails>();
        closeAddressMatch = new List <AddressMatchDetails>();
        
        noAddressMatch = new List < AddressMatchDetails > ();
        closeMatchAddrWrapper = new List <closeMatchAddressWrapper > ();
        
        // Initialize all variables related to existing Sites. 
        existingSitesList = new List<CustomerSite__c>();
        existingSitesWrapperList = new List <existingSitesWrapper>();
        existingSiteValidationClassIndicatorMap = new Map <Id, matchIndicator>();
        selectedSitesList = new List <CustomerSite__c>();
        selectedSitesMap = new Map <Id, CustomerSite__c>();
        
        // Initialize List of valid customer site Ids for configure sites tab 
        validSitesToConfigureList = new List<CustomerSite__c>();            
        isConfigured = false;
        displayNoSiteAdded = false;
        
        // Call doCheckIsConfigurable method to re-evaluate if sites can be configured.     
        doCheckIsConfigurable();
        
        // Bulk sites upload
        uploadedSites = new List <CustomerSite__c>();
        
        // Selected sites wrapper list
        selectedSitesWrapperList = new List<selectedSitesWrapper>();
        
        //Remove and export functionality
        isSiteSelected = false;
        isSelectAll = false;
        isSingleSiteSent = false;
        doPolling = false;
        List<String> docNameList = new List<String>{'SiteAddressUploadTemplate_New','RetrieveTokenUploadTemplate'};
        List<Document> docList = new List<Document>([Select Name,DeveloperName from Document where DeveloperName IN: docNameList order by DeveloperName desc]);
        
        if (docList !=NULL && docList.size()>0){
            for(Document docObj: docList){
                String devName = docObj.DeveloperName;
                if(String.isNotBlank(devName) && 'SiteAddressUploadTemplate_New'.equals(devName)){
                    strDocUrl = '/servlet/servlet.FileDownload?file='+String.valueOf(docObj.Id);
                }
                else if(String.isNotBlank(devName) && 'RetrieveTokenUploadTemplate'.equals(devName)){
                    strRetrieveTokenDocUrl = '/servlet/servlet.FileDownload?file='+String.valueOf(docObj.Id);
                }
            }
        }
        possibleMatchFlag = false;
        
        
        // AKP Changes for AIA 
        isAIASelected = false;
        listOfSitesToExport  = new list<CustomerSite__c>();
        
        if(quote != null){
            if(quote.Product__r.ProductCode == BuyflowConstant.AMIS){
                    productname = BuyflowConstant.MIS;
                }
                else if(quote.Product__r.ProductCode == BuyflowConstant.AVPN){
                    productname = BuyflowConstant.AVPN;
                }
                else if(quote.Product__r.ProductCode == BuyflowConstant.ASE){
                    productname = BuyflowConstant.ASE;
                }
            }
        isConfigMode = false;
        isReviewMode = false;
        isSiteInfoMode = false;
        if( ApexPages.currentPage().getParameters().get('mode') == 'reviewquote' ){
            isReviewMode = true;
        }
        if( ApexPages.currentPage().getParameters().get('mode') == 'confsites' ){
            isConfigMode = true;
        }
        if( ApexPages.currentPage().getParameters().get('mode') == 'siteinfo' ){
            isSiteInfoMode = true;
        }
        
        addSiteSuccess=false;
        Apttus_Proposal__Proposal__c quoteObj = new Apttus_Proposal__Proposal__c();
        quoteId = apexpages.currentpage().getparameters().get('quoteId');
        if(quoteId != null) {
            quoteObj = [select id,Apttus_Proposal__Approval_Stage__c,Name,SiteRemovalCheck__c, First_time_ASE__c, Apttus_Proposal__Opportunity__c,Apttus_Proposal__Opportunity__r.StageName,Bulk_Add_Token_Batch_Completed__c from Apttus_Proposal__Proposal__c  where  id = :quoteId];                
        }
        if(quoteObj != null){
            if(quoteObj.First_time_ASE__c== true){
                FirstTimeUserASE = true;
            }
            else{
                FirstTimeUserASE = false;
            }
            
            if(quoteObj.Apttus_Proposal__Opportunity__c != null && quoteObj.Apttus_Proposal__Opportunity__r.StageName != 'Deal Registration Requested' && quoteObj.Apttus_Proposal__Opportunity__r.StageName != 'Deal Registration Approved' && quoteObj.Apttus_Proposal__Opportunity__r.StageName != 'Deal Reg Auto-Approved' && quoteObj.Apttus_Proposal__Opportunity__r.StageName != 'Cancelled'){
                removePopupOnLoadFlag = true;
                if(!quoteObj.SiteRemovalCheck__c){
                    checkDiscard = true;
                }
            }
        }
    }
   
    /* 
    Name: GotoAddAddressPage
    Description: 
    */ 
    public PageReference GotoAddAddressPage() {
        try{
            if(quoteId == null) {
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            if (quoteId !=NULL && quote==null) { 
                quote = new Apttus_Proposal__Proposal__c();
                quote = [select id,Review_Address_Check__c,Buyflow_Step__c,Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(quote!=NULL) {
                quote.Review_Address_Check__c=false;
            }
            update quote;
            
            isReviewAddress = quote.Review_Address_Check__c;
            PageReference AddaddressPage = system.page.buyflow;
            AddaddressPage.getParameters().put('mode', 'siteinfo');
            AddaddressPage.getParameters().put('quoteid', quote.id); 
            AddaddressPage.getParameters().put('buyflow', 'false');
            AddaddressPage.setRedirect(true);
            return AddaddressPage;
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }   
    }     
    
    /* 
    Name: reInitializeSiteAddress
    Description: Changes for ReInitializing the Site List
    */ 
    public void reInitializeSiteAddress() {
        try{
            existingSitesList = new List<CustomerSite__c>();
            existingSitesWrapperList = new List <existingSitesWrapper>();
            existingSiteValidationClassIndicatorMap = new Map <Id, matchIndicator>();
            selectedSitesWrapperList = new List<selectedSitesWrapper>();
            selectedSitesList = new List <CustomerSite__c>();
            selectedSitesMap = new Map <Id, CustomerSite__c>();
            pageInsertedSitesMap = new Map<Id,CustomerSite__c>();
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }   
    }
    
    /* 
    Name: goToReviewAddress
    Description: 
    */ 
    public pageReference goToReviewAddress(){
        PageReference retPageRef;
        system.debug( ' isReviewAddress  ' + isReviewAddress);
        try{  
            if(quoteId == null) {
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            system.debug( ' isReviewAddress  ' + isReviewAddress);
            if(quoteId !=NULL && quote==null){ 
                quote = new Apttus_Proposal__Proposal__c();
                quote = [select id,Review_Address_Check__c,RetrialFailure__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(quote!=NULL){
                quote.Review_Address_Check__c=true;
            }
            system.debug( ' quote.RetrialFailure__c  ' + quote.RetrialFailure__c);
            update quote;
            system.debug( 'Quote    :::::::::::::::::::' + quote);
            retPageRef = Page.Buyflow;
            retPageRef.getParameters().put('quoteid', quote.id);
            retPageRef.getParameters().put('mode', 'siteinfo');
            retPageRef.setRedirect(true);
            return retPageRef;
        }
        catch(Exception e){
            system.debug( ' isReviewAddress  ' + isReviewAddress +' eccc '+e.getlinenumber());
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }   
    }
    
    /*******************************************************************
    * Method name : getstatePickList
    * Description : Get values from custom setting for State picklist 
    * Return Type : List<SelectOption>.
    * Parameters  : None.
    *******************************************************************/  
    public List<SelectOption> getstatePickList(){
        try{
            List<SelectOption> statePickList = new List<SelectOption>();
            List<ATT_StateMapping__c> stateList = ATT_StateMapping__c.getall().values();
            if(stateList!=NULL){
                for(ATT_StateMapping__c item : stateList){
                    statePickList.add(new selectoption(item.name,item.State_Code__c));
                }
            }
            statePickList.sort();
            SelectOption placeholderText;
            statePickList.add(0,new SelectOption(SpecialCharacterConstant.SELECT_CAPS_LITERAL,SpecialCharacterConstant.SELECT_CAPS_LITERAL));
            return statePickList;
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }   
    }
    
    /*******************************************************************
    * Method name : doValidate
    * Description : Logic behind BuyflowConstant.VALIDATEADDRESS button to perform VASA validation on entered site details 
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/    
    public Void doValidate(){
        system.debug('inside doValidate method ');
        try{
            if(isSiteInfoMode){
                if(quoteId == null) {
                    quoteId = apexpages.currentpage().getparameters().get('quoteid');
                }
                if (quoteId !=NULL && quote==null) { // (one time run to query quote and store end customer Id)
                    quote = new Apttus_Proposal__Proposal__c();
                    quote = [select id,End_Customer__c,Product_New_Name__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,
                                Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c,
                                Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
                }       
                if(quote!=NULL) {
                    quoteId = quote.id;
                    customerId = quote.End_Customer__c;
                }
                   
                //Changes for close Match Test: RK
                selectedCloseRadio = ApexPages.currentPage().getParameters().get('selectedCloseRadio');
                List <AddressMatchDetails> closeMatchUserSelectionList = new List <AddressMatchDetails>();
                if(possibleMatchFlag && !closeMatchAddrWrapper.isEmpty()) {
                    possibleMatchFlag = false;
                    // Iterate through list of close match wrapper and store user selection in closeMatchUserSelectionList list.       
                    for (closeMatchAddressWrapper item: closeMatchAddrWrapper) {
                        if (item.radioId == selectedCloseRadio) {
                            selectedCloseRadio = SpecialCharacterConstant.CONCAT;
                            closeMatchUserSelectionList.add(item.closeMatchAddress);
                        }
                    }
                }
                if(!closeMatchUserSelectionList.isEmpty()) {
                    customerSite.Address_Line__c = closeMatchUserSelectionList[0].street;
                    customerSite.City__c = closeMatchUserSelectionList[0].city;
                    customerSite.State__c = closeMatchUserSelectionList[0].state;
                    customerSite.End_Customer__c = customerId;
                    customerSite.Country__c = BuyflowConstant.US;
                    customerSite.Zip_Code__c = closeMatchUserSelectionList[0].zip.zipcode;
                    customerSite.VASA_Request_Time__c=Date.today().addDays(-32);
                } else {
                    // Assign site Address field to user entered address line, room and floor on the page. 
                    customerSite.Address_Line__c = String.valueOf(addressLine + (room!=null?' '+room:'') + (floor!=null?' '+floor:''));
                    if (String.isNotBlank(state) && state != 'Select a state'){
                        customerSite.State__c = ATT_StateMapping__c.getInstance(state).State_Code__c;
                    }
                    if (String.isNotBlank(location) && location != SpecialCharacterConstant.SELECT_CAPS_LITERAL){
                        customerSite.Location__c = ATT_LocationMapping__c.getInstance(location).name;
                    }
                    // Assign end customer Id to customerSite instance.  
                    customerSite.End_Customer__c = customerId;
                    customerSite.Country__c = BuyflowConstant.US;
                    customerSite.VASA_Request_Time__c=Date.today().addDays(-32);
                }
               
                /* For US796451 */ 
                if(String.isNotBlank(customerSite.RoomBuildingFloorInput__c)){
                    Integer delimiterCount = customerSite.RoomBuildingFloorInput__c.countMatches(SpecialCharacterConstant.SLASH);
                    List<String> roomBuildingFloorList = null;
                    customerSite.Structure__c = BuyflowConstant.BLANKQUOTES;
                    customerSite.Level__c = BuyflowConstant.BLANKQUOTES;
                    customerSite.Unit__c = BuyflowConstant.BLANKQUOTES;
                    if(delimiterCount < 3){
                        if(delimiterCount > 0){
                            roomBuildingFloorList = customerSite.RoomBuildingFloorInput__c.deleteWhiteSpace().split(SpecialCharacterConstant.SLASH);
                        }
                        if(delimiterCount == 0){
                            customerSite.Structure__c = customerSite.RoomBuildingFloorInput__c.deleteWhiteSpace();
                        }else if (roomBuildingFloorList.size() >= 1 && (delimiterCount == 1  || (delimiterCount == 2 && customerSite.RoomBuildingFloorInput__c.endsWith('//')))){
                            customerSite.Structure__c = roomBuildingFloorList[0];
                            if(roomBuildingFloorList.size() == 2){
                                customerSite.Level__c = roomBuildingFloorList[1];
                            }
                        }else if(delimiterCount == 2 && roomBuildingFloorList.size() >= 2){
                            customerSite.Structure__c = roomBuildingFloorList[0];
                            customerSite.Level__c = roomBuildingFloorList[1];
                            if(roomBuildingFloorList.size() == 3){
                                customerSite.Unit__c = roomBuildingFloorList[2];
                            }
                        }
                    }
                }
                /* US796451 Ends */
                // Initialize the Exact Match, Close Match and No match list and the close match wrapper.    
                exactAddressMatch = new List <AddressMatchDetails>();
                closeAddressMatch = new List <AddressMatchDetails>();
                noAddressMatch = new List <AddressMatchDetails>();
                
                closeMatchAddrWrapper = new List <closeMatchAddressWrapper>();
                
                // Perform page level validation for required values (Site Name, Address Line, City, State, Zip code, Phone)         
                if(String.isNotBlank(quoteId) && customerSite.End_Customer__c !=NULL && String.isNotBlank(customerSite.Site_Name__c) && String.isNotBlank(customerSite.Address_Line__c) && String.isNotBlank(customerSite.City__c) && String.isNotBlank(customerSite.State__c) && customerSite.Zip_Code__c != null/* && String.isNotBlank(customerSite.Phone__c)*/) {
                    //ATTSingleSiteValidateUtil.doSingleSiteValidate(junctionToUpdateId,quoteId, customerId,customerSite,VASAresponse,exactAddressMatch,closeAddressMatch,closeMatchAddrWrapper,noAddressMatch,selectedSitesWrapperList);
                    if(customerSite.id != null) {
                        customerSite.VASACallFlag__c = true;
                        customerSite.ASE_ITPA_Processing_Complete__c = false;
                        adressCorrectionSiteId=customerSite.id;
                        update customerSite; 
                    }else {
                        upsert customerSite; 
                        adressCorrectionSiteId=customerSite.id;
                    }
                    if(customerSite.id!=null){
                        List<AT_T_Customer_Site_Quote__c> juncList = [Select Id From AT_T_Customer_Site_Quote__c Where AT_T_Customer_Site__c =: customerSite.id];
                        boolean flag = false;
                        // Insert junction object record.
                        AT_T_Customer_Site_Quote__c junctionItem = new AT_T_Customer_Site_Quote__c();
                        
                        junctionItem.AT_T_Customer_Site__c = customerSite.id;
                        custSiteIdASE = customerSite.id;
                        junctionItem.AT_T_Quote__c = Id.valueOf(quoteId);           
                        if(!juncList.isEmpty()) {
                            junctionItem.Id = juncList[0].Id;
                            update junctionItem;
                        } else if(juncList.isEmpty() && customerSite.VASACallFlag__c == false) {
                            insert junctionItem;
                        }
                        selectedSitesWrapperList.add(new SiteAddressInformationController.selectedSitesWrapper(customerSite,junctionItem));
                    }
                
                    // Call doFetchExistingSites method to update the existing sites table with newly created site data.
                    doFetchSelectedSites();             
                    doCheckIsConfigurable();            
                    if (customerSite.id!=NULL){              
                        addSiteSuccess = true;
                    }  
                    else{
                        addSiteSuccess = false;
                    }  
                    
                    // Re-initalize lists storing exact match, close match, no match and close match wrapper list for subsequent transaction. 
                    exactAddressMatch = new List <SiteAddressInformationController.AddressMatchDetails>();
                    closeAddressMatch = new List <SiteAddressInformationController.AddressMatchDetails>();
                    noAddressMatch = new List <SiteAddressInformationController.AddressMatchDetails>();
                        
                    // Re-initialize the customer site variable for subsequent transaction.   
                    customerSite = new CustomerSite__c();
                    customerSite.RoomBuildingFloorInput__c = SpecialCharacterConstant.CONCAT;
                    customerSite.location__c = SpecialCharacterConstant.CONCAT;
                    customerSite.End_Customer__c  = customerId; 
                    
                    addressLine = SpecialCharacterConstant.CONCAT; 
                    room = SpecialCharacterConstant.CONCAT;
                    floor = SpecialCharacterConstant.CONCAT;      
                    state = SpecialCharacterConstant.CONCAT;
                    location =SpecialCharacterConstant.CONCAT;   
                } 
                // Page Level validation failed. The user did not enter one or more required fields on the page.   
                else{
                    // Re-initialize the customer site variable for subsequent transaction.   
                    customerSite = new CustomerSite__c(); 
                    customerSite.RoomBuildingFloorInput__c = SpecialCharacterConstant.CONCAT;
                    customerSite.location__c = SpecialCharacterConstant.CONCAT;   
                    customerSite.End_Customer__c  = customerId; 
                    addressLine = SpecialCharacterConstant.CONCAT; 
                    room = SpecialCharacterConstant.CONCAT;
                    floor = SpecialCharacterConstant.CONCAT;            
                    state = SpecialCharacterConstant.CONCAT;
                    location = SpecialCharacterConstant.CONCAT;
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*******************************************************************
    * Method name : doCloseMatchSiteCreation
    * Description : Method to insert customer site based on user selection of close match sites from closeMatchAddrWrapper wrapper list. 
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/       
    public void doCloseMatchSiteCreation() {
        try{
            if(quoteId == null) {
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            if (quoteId !=NULL && quote==null) { // (one time run to query quote and store end customer Id)
                quote = new Apttus_Proposal__Proposal__c();
                quote = [select id,End_Customer__c,Product_New_Name__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,
                            Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c,
                            Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(quote!=NULL) {
                quoteId = quote.id;
                customerId = quote.End_Customer__c;
            }
           
            // AddressMatchDetails list to hold user selection from close match wrapper list.
            List <AddressMatchDetails> closeMatchUserSelectionList = new List <AddressMatchDetails>();
            
            // Iterate through list of close match wrapper and store user selection in closeMatchUserSelectionList list.       
            for (closeMatchAddressWrapper item: closeMatchAddrWrapper) {
                if (item.isSelected) {
                    closeMatchUserSelectionList.add(item.closeMatchAddress);
                }
            }
            // Pre-populate input fields based on user selection of close match site.
            if (closeMatchUserSelectionList != NULL && closeMatchUserSelectionList.size() == 1) {
                try{
                    // Populate Customer Site instance with selected close match site details and create site record.
                    customerSite.Address_Line__c = closeMatchUserSelectionList[0].street;
                    customerSite.City__c = closeMatchUserSelectionList[0].city;
                    customerSite.State__c = closeMatchUserSelectionList[0].state;
                    customerSite.Urbanization__c = closeMatchUserSelectionList[0].urbanization;
                    customerSite.country__c = closeMatchUserSelectionList[0].country;
                    customerSite.Zip_Code__c = closeMatchUserSelectionList[0].zip.zipcode;
                    customerSite.Zip_Code_Extension__c =  closeMatchUserSelectionList[0].zip.zipCodeExtension;
                    customerSite.Zip_Geo_Code__c = closeMatchUserSelectionList[0].zip.zipGeoCode;
                    customerSite.Site_Name__c = customerSite.Site_Name__c;
                    
                    customerSite.VASA_Response_Status__c = 'ADDRESS EXACT MATCH'; // updated as per US614049
                    customerSite.Raw_VASA_Response_Status__c = 'ADDRESS EXACT MATCH'; // updated as per US614049
                    upsert customerSite;
                    
                    // Page Message Instance
                    ApexPages.Message myMsg;
                    myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Congratulations you have successfully added the selected closed match site.');  
                    ApexPages.addMessage(myMsg);
                    
                    // Call doFetchExistingSites method to update the existing sites table with newly created site data.
                    //doFetchExistingSites();
                    
                    // Call doSitesSelection method to update selection from existing sites table (optional)
                    doSitesSelection();    
                    
                    // Re-initialize the customer site variable for subsequent transaction.   
                    customerSite = new CustomerSite__c();
                    customerSite.RoomBuildingFloorInput__c = SpecialCharacterConstant.CONCAT;
                    customerSite.location__c = SpecialCharacterConstant.CONCAT;
                    addressLine = SpecialCharacterConstant.CONCAT; 
                    room = SpecialCharacterConstant.CONCAT;    
                    state = SpecialCharacterConstant.CONCAT; 
                    
                    // Re-initalize lists storing exact match, close match, no match and close match wrapper list for subsequent transaction. 
                    exactAddressMatch = new List <AddressMatchDetails>();
                    closeAddressMatch = new List <AddressMatchDetails>();
                    noAddressMatch = new List <AddressMatchDetails>();
                    closeMatchAddrWrapper = new List <closeMatchAddressWrapper>(); 
                }catch(Exception e){
                    // Page Message Instance                
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }  
            } 
            // Display page level validation error message for more than 1 close match selections.   
            else if (closeMatchUserSelectionList!= NULL && closeMatchUserSelectionList.size() > 1) {
                // Page Message Instance
                ApexPages.Message myMsg;
                myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, Label.Site_CloseMatchSelectionError); 
                ApexPages.addMessage(myMsg);           
            }
            // Add page validation error message if no close match selection is made.    
            else if (closeMatchUserSelectionList!=NULL && closeMatchUserSelectionList.size() < 1) {
                // Page Message Instance
                ApexPages.Message myMsg;
                myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,Label.Site_CloseMatch); 
                ApexPages.addMessage(myMsg);               
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }   
    }
    
    /* 
    Name: retrieveIndexOfTheElement
    Description: 
    */ 
    public Integer retrieveIndexOfTheElement(List<AT_T_Customer_Site_Quote__c> junctionItemList, String siteId){
        Integer counter = 0;
        Integer responseVal = -1;
        try{  
            for( AT_T_Customer_Site_Quote__c jncItem : junctionItemList ){        
                if( jncItem.AT_T_Customer_Site__c == siteId ){            
                    responseVal = counter;
                    break;
                }
                counter++;
            }
            return responseVal;        
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }   
    }    
    
    /*******************************************************************
    * Method name : doSitesSelection
    * Description : Logic behind BuyflowConstant.ADD button on page to add existing sites to left selected sites panel
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/  
    public void doSitesSelection() {
        try{
            if(isSiteInfoMode){
                checkServErr = false;
                if(quoteId == null) {
                    quoteId = apexpages.currentpage().getparameters().get('quoteid');
                }
                Boolean isAlreadyAdded = false;
                List<AT_T_Customer_Site_Quote__c> jncSiteQuote = new List<AT_T_Customer_Site_Quote__c>();
                if (quoteId !=NULL && quote==null) { // (one time run to query quote and store end customer Id)
                    quote = new Apttus_Proposal__Proposal__c();
                    quote = [select id,End_Customer__c,Product_New_Name__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,
                                Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c,
                                Apttus_Proposal__Proposal_Name__c, RetrialFailure__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];

                    jncSiteQuote = [SELECT Id, AT_T_Customer_Site__c, AT_T_Quote__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c  =: quoteId];
                }
                jncSiteQuote = [SELECT Id, AT_T_Customer_Site__c, AT_T_Quote__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c  =: quoteId];   
                if(quote!=NULL) {
                    quoteId = quote.id;
                    customerId = quote.End_Customer__c;
                }
                // Create CustomerSite List to store selected customer sites.
                selectedSitesList = new List <CustomerSite__c>();
                
                //Start: Changes for dynamic Data Table: RK 11/21
                String selectedSitesId = ApexPages.currentPage().getParameters().get('selectedCustomerIds');

                if(selectedSitesId != null && selectedSitesId != SpecialCharacterConstant.CONCAT) {
                    List<String> selectedSiteIdList = selectedSitesId.split(SpecialCharacterConstant.SEMICOLON);
                    List<CustomerSite__c> fetchedCustomerSiteList = [SELECT Id,Name, End_Customer__c,Speed_Name__c, Speed_Unit__c,VASAResponse__c,
                                                                        Service_Availability_Response__c, Service_Avail_Key__c,VASA_Response_Status__c, 
                                                                        Country__c,Display_All_Speeds__c,Transport_Type__c,Urbanization__c,
                                                                        Phone__c,Zip_Code_Extension__c,Zip_Geo_Code__c,Speed_Physical_Value__c,
                                                                        Near_Match_Indicator__c,Quantity__c, Site_Description__c, BRASSResponse__c,
                                                                        BRASS_Request_Time__c, Site_Name__c, BRASS_Response_Status__c, City__c, 
                                                                        Address_Line__c, State__c, Zip_Code__c, VASA_Request_Time__c, Location__c, 
                                                                        RoomBuildingFloorInput__c, Structure__c, Level__c, Unit__c 
                                                                        From CustomerSite__c where Id IN: selectedSiteIdList order by CreatedDate desc];
                
                    selectedSitesList.addAll(fetchedCustomerSiteList);
                    List<CustomerSite__c> sitesToValidateList = new List<CustomerSite__c>();
                   
                    if(!fetchedCustomerSiteList.isEmpty()) {                 
                        
                        //New Change for keeping the duplicate value: RK 11/11
                        AT_T_Customer_Site_Quote__c junctionItem = null;
                        List<AT_T_Customer_Site_Quote__c> junctionItemList = new List<AT_T_Customer_Site_Quote__c>();
                        
                        Map<Id, CustomerSite__c> custSiteIdCustSiteObj = new Map<Id, CustomerSite__c>();
                        
                          if(quoteId != null) {
                            for (CustomerSite__c site: selectedSitesList) {
                                junctionItem = new AT_T_Customer_Site_Quote__c();
                                junctionItem.AT_T_Customer_Site__c = site.id;
                                junctionItem.Type__c = 'Non-MACD';
                                junctionItem.AT_T_Quote__c = Id.valueOf(quoteId);
                                junctionItemList.add(junctionItem);

                                custSiteIdCustSiteObj.put(site.Id, site);
                            }
                            List<AT_T_Customer_Site_Quote__c> junctionItemListTemp = new List<AT_T_Customer_Site_Quote__c>();
                            for( AT_T_Customer_Site_Quote__c jncItem : jncSiteQuote){
                                Integer indexOfElement = retrieveIndexOfTheElement(junctionItemList, jncItem.AT_T_Customer_Site__c);
                                if( indexOfElement != -1 ){                                
                                    junctionItemList.remove(indexOfElement);
                                    isAlreadyAdded = true;
                                }                        
                            }
                            if(!junctionItemList.isEmpty()) {
                                insert junctionItemList;
                                update junctionItemList;
                            }
                            Map<AT_T_Customer_Site_Quote__c,Id> junctionItemIdCustSiteIdMap = new Map<AT_T_Customer_Site_Quote__c,Id>();
                            for(AT_T_Customer_Site_Quote__c attCustSiteQuoteObj : junctionItemList) {
                                junctionItemIdCustSiteIdMap.put(attCustSiteQuoteObj, attCustSiteQuoteObj.AT_T_Customer_Site__c);
                            }
                            
                            for(AT_T_Customer_Site_Quote__c attCustSiteQuoteObj : junctionItemList) {
                                if(custSiteIdCustSiteObj.containsKey(junctionItemIdCustSiteIdMap.get(attCustSiteQuoteObj))) {
                                        selectedSitesWrapperList.add(new selectedSitesWrapper(custSiteIdCustSiteObj.get(junctionItemIdCustSiteIdMap.get(attCustSiteQuoteObj)),attCustSiteQuoteObj));
                                }
                            }
                        }
                        doFetchSelectedSites();   
                        doCheckIsConfigurable(); 
                        if(isAlreadyAdded == true){
                            ApexPages.Message myMsg;
                            myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Warning : One of the sites already added to the quote.'); 
                            ApexPages.addMessage(myMsg); 
                            checkServErr = true;
                        }
                    }
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }   
    }
    
    /*******************************************************************
    * Method name : doRemove
    * Description : Method to remove selected sites from right panel.
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/     
    public void doRemove() {
        try{    
            Apttus_Config2__ProductConfiguration__c prodConfig;
            // Store Id of siteToRemove from page based on user click
            Set<Id>junctionToRemoveSet = new Set<Id>();
            set<Id> siteIdset= new set<Id>();
            if(quoteId == null) {
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            if (quoteId !=NULL && quote==null) { // (one time run to query quote and store end customer Id)
                quote = new Apttus_Proposal__Proposal__c();
                quote = [select id,Product_New_Name__c,RetrialFailure__c,End_Customer__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,
                        Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c,
                        Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(quote!=NULL) {
                quoteId = quote.id;
                customerId = quote.End_Customer__c;
                prodConfig= quoteHelper.retrieveExistingCartId(quoteId);
                if(prodConfig!=null){
                    cartId = prodConfig.Id;
                }
            }
            
            for (selectedSitesWrapper item : selectedSitesWrapperList){
                if (item.isSelected){
                    junctionToRemoveSet.add(item.junctionRecordId);
                }
            }
        
            // Delete the junction object record between customer site and quote.
            if(junctionToRemoveSet!=NULL && junctionToRemoveSet.size()>0){               
                try{
                    if(cartId!=null){
                        list<Apttus_Config2__LineItem__c> lineItems = new List<Apttus_Config2__LineItem__c>();
                        for(AT_T_Customer_Site_Quote__c junctionlist:[select id ,AT_T_Customer_Site__c from AT_T_Customer_Site_Quote__c where Id in :junctionToRemoveSet]){
                            siteIdset.add(junctionlist.AT_T_Customer_Site__c);
                        }
                        if(siteIdset.size()>0){
                         List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineitemlist=[select id,AT_T_Customer_Site__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_QPConfig__ConfigurationId__c=:Cartid AND AT_T_Customer_Site__c IN :siteIdset ];
                            lineItems = [SELECT Id,AT_T_Customer_Site__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=:CartId AND AT_T_Customer_Site__c IN: siteIdset];
                            
                            if(lineItems.size()>0){
                                delete lineItems;
                            } 
                            if(proposalLineitemlist.size()>0){
                                delete proposalLineitemlist;
                            }
                        }
                        /*****Untagging End Customer for IPQ Site*****/ 
                        List<CustomerSite__c> custObj = new List<CustomerSite__c>();
                        List<id> custIdList = new List<Id>();
                        Map<id,Integer> siteMap = new Map<id,Integer>();
                        List<Id> untagSIteIdList = new List<Id>();
                        List<End_Customer__c> endObj = new List<End_Customer__c>();
                        endObj = [Select id from End_Customer__c where Name = 'Rest_End_Customer'];
                        custObj=[select id,End_Customer__c,Site_Name__c,API_IPQ_Site__c from CustomerSite__c where API_IPQ_Site__c = true AND id in (select AT_T_Customer_Site__c from AT_T_Customer_Site_Quote__c where Id =: junctionToRemoveSet)];
                        if(!custObj.isEmpty()){
                            for(CustomerSite__c cust :custObj){
                                custIdList.add(cust.id);
                            }
                            for(AT_T_Customer_Site_Quote__c junObj : [select AT_T_Customer_Site__c from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c =: custIdList]){
                                if(siteMap.containsKey(junObj.AT_T_Customer_Site__c)){
                                    siteMap.put(junObj.AT_T_Customer_Site__c,siteMap.get(junObj.AT_T_Customer_Site__c) + 1);
                                }else{
                                    siteMap.put(junObj.AT_T_Customer_Site__c,1);
                                }
                            }
                            for(id siteId : siteMap.keySet()){
                                if(siteMap.get(siteId) <= 2){
                                    untagSIteIdList.add(siteId);
                                    System.debug('@@@untagSIteIdList---->'+untagSIteIdList);
                                }
                            }

                            for(CustomerSite__c cust1 :custObj){
                                if(untagSIteIdList.contains(cust1.id)){
                                    cust1.Site_Name__c = '';
                                    cust1.End_Customer__c = endObj[0].id;
                                    System.debug('SUCCESSS');
                                    update cust1;   
                                }
                            }
                        }
                    }
                    delete [select id from AT_T_Customer_Site_Quote__c where Id in :junctionToRemoveSet];
                    system.debug('---setting removal check---');
                    if(quote!=NULL) {
                        if(removePopupOnLoadFlag){
                            quote.SiteRemovalCheck__c = true;
                            update quote;
                        }
                    } 
                    checkDiscard = false;       
                }catch(Exception e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }  
            }
            //Make the isSiteSelected as false to disable the Remove as well as the export button disable
            isSiteSelected = false;
            
            //Check if this from Select All checkbox then make this select All checkbox uncheck as well
            if(isSelectAll) {
                isSelectAll = false;
            }
            doFetchSelectedSites();
            doCheckIsConfigurable(); 
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }   
    }
    
    /*******************************************************************
    * Method name : doSingleSiteRemove
    * Description : Method to remove selected sites from right panel one at a time.
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/     
    public void doSingleSiteRemove() {
        try{
            if(quoteId == null) {
            quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            if (quoteId !=NULL && quote==null) { // (one time run to query quote and store end customer Id)
                quote = new Apttus_Proposal__Proposal__c();
                quote = [select id,Product_New_Name__c,RetrialFailure__c,End_Customer__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,
                            Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c,
                            Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(quote!=NULL) {
                quoteId = quote.id;
                customerId = quote.End_Customer__c;
            }
            // Store Id of siteToRemove from page based on user click
            Id siteToRemoveId = Id.valueOf(siteToRemoveId);
        
            // Delete the junction object record between customer site and quote.        
            if(siteToRemoveId !=NULL){
                delete [select id from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c= :siteToRemoveId];
            }    
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }    
        doFetchSelectedSites();
        doCheckIsConfigurable(); 
    }
    
    /* 
    Name: doCheckIsConfigurable
    Description: Method to check if sites can be configured 
    */ 
    public void doCheckIsConfigurable(){
        
        try{    
            // Initialize List of valid customer Site Ids 
            validSitesToConfigureList = new List<CustomerSite__c>(); 
            
            // Initialize isConfigureReady to false
            isConfigureReady = false;   
            if(selectedSitesWrapperList != null){
                for(SelectedSitesWrapper wrapObj : selectedSitesWrapperList) {
                    if(wrapObj.selectedSite != null) {
                        if(!isAIASelected){
                            validSitesToConfigureList.add(wrapObj.selectedSite);
                        }
                        else{
                            if(wrapObj.selectedSite.BRASS_Response_Status__c == BuyflowConstant.VALID || wrapObj.selectedSite.BRASS_Response_Status__c == BuyflowConstant.ALTEREDADDRESS) {
                                validSitesToConfigureList.add(wrapObj.selectedSite);
                            }
                        }
                    }
                } 
                if (!selectedSitesWrapperList.isEmpty() /*&& selectedSitesWrapperList.size() == validSitesToConfigureList.size()*/){
                    isConfigureReady = true;   
                } 
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }   
    }
    
    /*******************************************************************
    * Method name : setEmailOnCompleteFlag
    * Description : Method to set the Flag "Send Email on Service Complete" to decede the type of Vasa call to be made and 
                    send email accordingly
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/
    public void setEmailOnCompleteFlag(){
        //Code added to update quote on the basis of the checkbox selected by User from UI and make a sync or aync call accordingly
        try{
            if(quoteid != null){
                list<Apttus_Proposal__Proposal__c> quoteList = [select id,Send_Email_on_Service_Complete__c from Apttus_Proposal__Proposal__c where id =:quoteid ];
                if(isEmailSelected){
                    quoteList[0].Send_Email_on_Service_Complete__c = true;
                } else {
                    quoteList[0].Send_Email_on_Service_Complete__c = false;
                }
                update quoteList;
            }
        } catch(Exception e){            
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));

        }
    }
    
    /*******************************************************************
    * Method name : doConfigure
    * Description : Method for service availability check and redirect to configure sites tab on clicking BuyflowConstant.CONFIGURESITES1 button.
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/     
    public PageReference doConfigure(){
        list<CustomerSite__c> sitesOverThrityList = new list<CustomerSite__c>();        
        integer MaxdiffAllowed = 30;
        string offlineStringCheck = 'false';         
        boolean eligibleforVASAOffline = false;
        String checkExistingVASAResponseStatus = '';
        list<AT_T_Customer_Site_Quote__c> addRecCreatedSites = new list<AT_T_Customer_Site_Quote__c>();
        integer countOfNoServiceSite = 0;
        Integer Max_sites = Integer.valueOf(Max_sites_allowed_VASA__c.getValues('VASA_max_sites_allowed') != null ? Max_sites_allowed_VASA__c.getValues('VASA_max_sites_allowed').value__c: 0);          
        system.debug('inside doConfigure method ');
        
        try{
            if(quoteId == null) {
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            if (quoteId !=NULL && quote ==null) { // (one time run to query quote and store end customer Id)
                quote = new Apttus_Proposal__Proposal__c();
                quote = [select id,Apttus_Proposal__Approval_Stage__c, Product_New_Name__c,RetrialFailure__c,Send_Email_on_Service_Complete__c,End_Customer__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,
                        Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c, Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(quote!=NULL) {
                quoteId = quote.id;
                customerId = quote.End_Customer__c;
            }
            
            doFetchSelectedSites();

            doCheckIsConfigurable();
            if(quote != null) {
                if(quote.Product__r.ProductCode == BuyflowConstant.AIA) {
                    isAIASelected = true;
                }
                else if(quote.Product__r.ProductCode == BuyflowConstant.AMIS){
                    productname = BuyflowConstant.MIS;
                }
                else if(quote.Product__r.ProductCode == BuyflowConstant.AVPN){
                    productname = BuyflowConstant.AVPN;
                }
                else if(quote.Product__r.ProductCode == BuyflowConstant.ASE){
                    productname = BuyflowConstant.ASE;
                }
            }
           
            system.debug('\nMax_sites   '+Max_sites);
            
            if(quote.Product__r.ProductCode == BuyflowConstant.ASE){
                Max_sites = Integer.valueOf(Max_Sites_Allowed_For_ITPA__c.getValues('ASE_ITPA_Max_Sites') != null ? Max_Sites_Allowed_For_ITPA__c.getValues('ASE_ITPA_Max_Sites').value__c: 30);
            }
            // US827484
            try{
                sitesOverThrityList = new list<CustomerSite__c>();
                if((productname == BuyflowConstant.AVPN || productname == BuyflowConstant.MIS) && !validSitesToConfigureList.isEmpty()){
                    system.debug('@@PS validSitesToConfigureList'+validSitesToConfigureList);
                    for(CustomerSite__c custSuteObj : validSitesToConfigureList){                    
                        if((custSuteObj.VASA_Request_Time__c != NULL && (system.now().date().daysBetween(custSuteObj.VASA_Request_Time__c.Date())*-1 > MaxdiffAllowed)) || custSuteObj.VASA_Request_Time__c == NULL){
                            sitesOverThrityList.add(custSuteObj);
                        }
                    }
                    system.debug('@@PS sitesOverThrityList'+sitesOverThrityList);
                    if(!sitesOverThrityList.isEmpty() && sitesOverThrityList.size()> Max_sites || isEmailSelected){
                        eligibleforVASAOffline = true;
                    }
                }
                system.debug('\n eligibleforVASAOffline  '+eligibleforVASAOffline +'\n sitesOverThrityList  size :  '+sitesOverThrityList.size() + '\n sitesOverThrityList  '+sitesOverThrityList);
            }
            catch(exception ex){
                system.debug('This is the real reason for exception : '+ex+ex.getLineNumber());
            }   
            
            // ONLINE MODE        
            if (isConfigureReady && validSitesToConfigureList!=NULL && validSitesToConfigureList.size() > 0) {
                checkExistingVASAResponseStatus  = validSitesToConfigureList[0].VASA_Response_Status__c;
                if(validSitesToConfigureList!=NULL && validSitesToConfigureList.size()>0 && (validSitesToConfigureList.size()<=Max_sites || ((productname == BuyflowConstant.AVPN || productname == BuyflowConstant.MIS) && !eligibleforVASAOffline) || isAIASelected) && (isEmailSelected != true)) {
                    if(!isAIASelected){
                        if(quote.Product__r.ProductCode == BuyflowConstant.ASE){
                            isConfigured = ASEITPAServiceAvailabilityUtil.doASEITPACall(validSitesToConfigureList,ASEITPAresponse,quoteid);  
                            doPolling=true;  
                        }
                        else{
                           isConfigured = ATTServiceAvailabilityUtil.doServiceAvailCheckNewStart(validSitesToConfigureList,VASAresponse,quoteid);
                           doPolling=isConfigured;

                        }
                        system.debug('\n Checking isConfigured'+isConfigured);
                    } else {
                        //call for AIA
                        isConfigured = doConfigureAIA();
                    }
                    // US827483  VASA ERROR MESSAGE IN CASE OF SERVICE FAILURE, CHECK FOR ADDRESS RECORD CREATED VALUE
                    
                    if(!isConfigured && quoteId != null && !isAIASelected && productname != null){
                        //quoteToUpdate.Id = quoteId;
                        if(( productname == BuyflowConstant.MIS || productname == BuyflowConstant.AVPN)){
                            addRecCreatedSites = BuyflowUtil.returnVASAFAILRecords(quoteID);
                            if(!addRecCreatedSites.isEmpty()){
                                countOfNoServiceSite = addRecCreatedSites.size();
                            }                           
                        }
                        system.debug('countOfNoServiceSite ===== '+countOfNoServiceSite);
                        if(countOfNoServiceSite != null){
                            system.debug('\n quote '+quote + '\n countOfNoServiceSite '+countOfNoServiceSite);
                            if(countOfNoServiceSite > 0){
                                if(quote.RetrialFailure__c != null){
                                    quote.RetrialFailure__c ++ ;
                                }
                                else{
                                    quote.RetrialFailure__c = 1;
                                }
                                system.debug('\n checkServErr Post the check'+checkServErr + '\n quoteToUpdate.RetrialFailure__c '+ quote.RetrialFailure__c);
                                if(quote.RetrialFailure__c != null && quote.RetrialFailure__c != 0){
                                    if(quote.RetrialFailure__c >= 4){
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, BuyflowConstant.VASA_VALIDATION_ERROR2 ));
                                    }else{
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, BuyflowConstant.VASA_VALIDATION_ERROR ));
                                    }
                                    addSiteSuccess = false;
                                    checkServErr = true;
                                    displayNoSiteAdded = true;                                    
                                    excelBody = '';
                                    uploadedSites.clear();
                                    
                                } 
                            }
                            system.debug('\n uploadedSites '+ uploadedSites+'\n excelBody '+ excelBody+'\n addSiteSuccess '+ addSiteSuccess + '\n checkServErr Post the check '+ checkServErr + '\n quoteToUpdate.RetrialFailure__c '+ quote.RetrialFailure__c);
                        }
                        update quote;  
                        if(BuyflowConstant.MIS.equalsIgnoreCase(productName) || BuyflowConstant.AVPN.equalsIgnoreCase(productName)){                      
                            delete addRecCreatedSites;
                            removeAddRecJunc();
                        }    
                    }
                    if(isConfigured && quoteId != null && !isAIASelected && productname != null){
                        if(countOfNoServiceSite == 0){
                            quote.RetrialFailure__c = 0;                            
                            checkServErr = false;
                            update quote;
                        }
                    }
                    if(pageRefBulk.getParameters().get('display') == 'sync' && !checkServErr ){
                        return pageRefBulk;
                    }
                } 
                // OFFLINE MODE
                else if((validSitesToConfigureList!=NULL && (validSitesToConfigureList.size() > Max_sites || ((productname == BuyflowConstant.AVPN || productname == BuyflowConstant.MIS) && eligibleforVASAOffline))) || (isEmailSelected == true)) {
                    if(quote.Product__r.ProductCode == BuyflowConstant.ASE){
                        isConfigured = ASEITPAServiceAvailabilityUtil.doASEITPACall(validSitesToConfigureList,ASEITPAresponse,quoteid);    
                    }
                    else{
                        isConfigured = ATTServiceAvailabilityUtil.doServiceAvailCheckNewStart(validSitesToConfigureList,VASAresponse,quoteid);  
                        doPolling = isConfigured;
                        system.debug('-----isConfigured   '+ isConfigured );
                        
                        if(eligibleforVASAOffline){                      
                            system.debug('----- Entering the item where offline');                            
                            quote.Apttus_Proposal__Approval_Stage__c = 'Bulk Service Availability Requested';
                            quote.vasa_modeB_request__c= true;
                            if(isEmailSelected){
                                quote.Send_Email_on_Service_Complete__c=True;
                            }
                            update quote;
                            PageReference retPageRef = page.BuyFlow_VASABulk;
                            retPageRef.getParameters().put('quoteId', quote.id);
                            retPageRef.getParameters().put('vmode','B');                            
                            return retPageRef;
                        }
                    }
                    system.debug('\n isAIASelected '+ isAIASelected + '\n productname '+productname);
                   
                    if(isConfigured && quoteId!=null) {
                        Apttus_Proposal__Proposal__c quoteToUpdate = new Apttus_Proposal__Proposal__c(); 
                        quoteToUpdate.vasa_modeB_request__c= true;                                             
                        quoteToUpdate.Id = quoteId;
                        if(isEmailSelected){
                            quoteToUpdate.Send_Email_on_Service_Complete__c=True;
                        }
                        quoteToUpdate.Buyflow_Step__c = BuyflowConstant.ADDSITES;
                        if(quote.Product__r.ProductCode == BuyflowConstant.ASE){
                            quoteToUpdate.Apttus_Proposal__Approval_Stage__c = 'Bulk Service Availability Requested';
                        }
                        
                        update quoteToUpdate;
                        PageReference retPageRef = page.BuyFlow_VASABulk;
                        retPageRef.getParameters().put('quoteId', quote.id);
                        retPageRef.getParameters().put('vmode','B');
                        return retPageRef;
                    }else{   
                        ApexPages.Message myMsg;
                        myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Site_ConfigureError);
                        ApexPages.addMessage(myMsg);   
                    }                   
                }
            }
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }
        return null;
    }    
    
    /*******************************************************************
    * Method name : doFetchQuoteInfo
    * Description : Method to fetch quote, end customer and site related data on page load.
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/     
    public void doFetchQuoteInfo(){
        try{  
            if(quoteId == null) {
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            BulkUploadMsg = apexpages.currentpage().getparameters().get('display');
            ApexPages.Message myMsg;
            if(String.isNotBlank(quoteId)){
                // Get end customer Id from quote Id for the first run and store in customerId variable. 
                if (customerId ==NULL) { // (one time run to query quote and store end customer Id)
                    List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
                    quoteList = [select id,Review_Address_Check__c,RetrialFailure__c,Send_Email_on_Service_Complete__c,Product_New_Name__c,End_Customer__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c,Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
                    if (quoteList!=NULL && quoteList.size()>0){
                        customerId = quoteList[0].End_Customer__c; 
                        staticCustomerId = quoteList[0].End_Customer__c; 
                        isReviewAddress= quoteList[0].Review_Address_Check__c ;
                        isEmailSelected = quoteList[0].Send_Email_on_Service_Complete__c;
                        quote =  quoteList[0];
                        if(quoteList[0].Ethernet_Configuration__c != null && quoteList[0].Ethernet_Configuration__c == BuyflowConstant.ETHERNETPRIVATE_LINE_POINT_TO_POINT_x) {
                           ASE_type=BuyflowConstant.PTP;
                        }
                        if(quoteList[0].Ethernet_Configuration__c != null && quoteList[0].Ethernet_Configuration__c == BuyflowConstant.ETHERNETVIRTUAL_PRIVATE_LINE_HUB_AND_SPOKE_x) {
                            ASE_type=BuyflowConstant.HUB;
                        }
                        // AKP Changes for AIA          
                        if(quoteList[0].Product__r.ProductCode == BuyflowConstant.AIA){ 
                            isAIASelected = true;
                        }
                    }
                    // Call this method to fetch existing sites on Quote when moving from BuyflowConstant.CONFIGURESITES Tab to BuyflowConstant.ENTERADDRESSES Tab
                    doFetchSelectedSites();                
                    // Check if selected sites are configurable
                    doCheckIsConfigurable();
                    system.debug(' --- BulkUploadMsg value6=' +BulkUploadMsg);
                }
            }   
        
            system.debug(' --- BulkUploadMsg value7=' +BulkUploadMsg);
            if(BulkUploadMsg == BuyflowConstant.INVALID) {
                myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, Label.Site_TemplateError);
                ApexPages.addMessage(myMsg);
                system.debug(' --- BulkUploadMsg value8=' +BulkUploadMsg);
            }else if (BulkUploadMsg == BuyflowConstant.ERR) {
                myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, Label.Site_ValidateFailure);
                ApexPages.addMessage(myMsg);
            }else if(BulkUploadMsg == BuyflowConstant.BLANK) {
                myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'The uploaded file seems to be empty or selected template is invalid.');
                ApexPages.addMessage(myMsg);
            }else if(BulkUploadMsg == BuyflowConstant.ASYNC) {
                myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'The Bulk VASA request has been submitted successfully. Once the Sites will be added we will notify you.');
                ApexPages.addMessage(myMsg);
            }else if (BulkUploadMsg == BuyflowConstant.FILEERR){
                myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'One or more mandatory fields are empty or selected template is invalid.');
                ApexPages.addMessage(myMsg);
            }else if (BulkUploadMsg == BuyflowConstant.SYNCAIA){
                myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Sites successfully sent for bulk upload for AIA product.');
                ApexPages.addMessage(myMsg);
            }else if (BulkUploadMsg == BuyflowConstant.SYNC){
                myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Sites successfully bulk uploaded.');
                ApexPages.addMessage(myMsg);
            }      
        } catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*******************************************************************
    * Method name : doFetchSelectedSites
    * Description : Populate left side selected sites when moving back from Configure Sites Tab.
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/      
    public void doFetchSelectedSites(){
        try{  
            if(isSiteInfoMode){        
                if(quoteId == null) {
                    quoteId = apexpages.currentpage().getparameters().get('quoteid');
                }
                if (quoteId !=NULL && quote==null) { // (one time run to query quote and store end customer Id)
                    quote = new Apttus_Proposal__Proposal__c();
                    quote = [select id,Product_New_Name__c,RetrialFailure__c,End_Customer__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,
                                Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c,
                                Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
                }       
                if(quote!=NULL) {
                    quoteId = quote.id;
                    customerId = quote.End_Customer__c;
                }
            
                //Query ATT Customer Site Quote object to fetch already linked sites with the quote 
                if(quoteId !=NULL){
                    selectedSitesWrapperList = new List<selectedSitesWrapper>();
                    Set<Id> customerSiteIdSet = new Set<Id>();
                    Map<AT_T_Customer_Site_Quote__c, Id> junctionParentIdMap = new Map<AT_T_Customer_Site_Quote__c, Id>();
                    for (AT_T_Customer_Site_Quote__c item : [SELECT Id, AT_T_Customer_Site__c, CreatedDate from AT_T_Customer_Site_Quote__c where AT_T_Quote__c = :quoteId]) {
                        customerSiteIdSet.add(item.AT_T_Customer_Site__c);
                        junctionParentIdMap.put(item,item.AT_T_Customer_Site__c);
                        //selectedSitesWrapperList.add(new selectedSitesWrapper(pageInsertedSitesMap.get(item.AT_T_Customer_Site__c),item.id));

                    }
                               
                    Map<Id, CustomerSite__c> customerIdObjMap = new Map<Id, CustomerSite__c>();
                    for(CustomerSite__c obj : [SELECT id,API_IPQ_Site__c,Name, End_Customer__c,Speed_Name__c, Speed_Unit__c,VASAResponse__c,Service_Availability_Response__c,
                                                Service_Avail_Key__c,VASA_Response_Status__c, Country__c,Display_All_Speeds__c,Transport_Type__c,
                                                Urbanization__c, Phone__c,Zip_Code_Extension__c,Zip_Geo_Code__c,Speed_Physical_Value__c,
                                                Near_Match_Indicator__c,Quantity__c, Site_Description__c, Site_Name__c, City__c, Address_Line__c, State__c, createddate,
                                                Zip_Code__c,VASA_Request_Time__c, BRASS_Request_Time__c, BRASS_Response_Status__c, BRASSResponse__c, Location__c, RoomBuildingFloorInput__c, Structure__c, Level__c, Unit__c   
                                                From CustomerSite__c where Id IN: customerSiteIdSet order by CreatedDate desc]) {
                       
                       customerIdObjMap.put(obj.id, obj);
                    } 
                    for( AT_T_Customer_Site_Quote__c junctionId :junctionParentIdMap.keyset()) {
                        if(customerIdObjMap.get(junctionParentIdMap.get(junctionId)) != null) {
                            selectedSitesWrapperList.add(new selectedSitesWrapper(customerIdObjMap.get(junctionParentIdMap.get(junctionId)),junctionId));
                        }
                    } 
                    selectedSitesWrapperList.sort();            
                    // Call doCSSDefine method to define CSS for selected sites (left panel)
                    doCSSDefine();      
                } 
            }   
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        } 
    }
    
    /*******************************************************************
    * Method name : doHandleServiceAvailError
    * Description : Method to check for service availability error.
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/ 
    public void doHandleServiceAvailError(){
        try{   
            Integer Max_sites = Integer.valueOf(Max_sites_allowed_VASA__c.getValues('VASA_max_sites_allowed') != null ? Max_sites_allowed_VASA__c.getValues('VASA_max_sites_allowed').value__c: 0);                                               
            isAIASelected = Boolean.valueOf(apexpages.currentpage().getparameters().get('isAIASelected'));
        
            if(validSitesToConfigureList!=NULL && validSitesToConfigureList.size()>Max_sites){           
                if(isConfigured) {
                    ApexPages.Message myMsg;
                    myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Your Request submitted successfully. We will notify you once the sites are validated.');
                    ApexPages.addMessage(myMsg); 
                    isConfigureReady = false;
                }else{     
                    ApexPages.Message myMsg;
                    myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Site_ConfigureError);
                    ApexPages.addMessage(myMsg);   
                }                                 
            }
            else if (!isConfigured){
                if (!isAIASelected){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Site_ServiceAvailabilityError);                
                    ApexPages.addMessage(myMsg);
                }else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'The selected sites do not qualify for service availability.');
                    ApexPages.addMessage(myMsg);
                }   
            }
            doFetchSelectedSites();
            doCheckIsConfigurable();
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*******************************************************************
    * Method name : ReadFile
    * Description : Method to implement bulk upload functionality.
    * Return Type : PageReference.
    * Parameters  : None.
    *******************************************************************/  
    PageReference pageRefBulk = System.Page.buyflow;
    public PageReference ReadFile(){
        try{
            if(quoteId == null) {
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            if (quoteId !=NULL && quote==null) { // (one time run to query quote and store end customer Id)
                quote = new Apttus_Proposal__Proposal__c();
                quote = [select id,Product_New_Name__c,RetrialFailure__c,End_Customer__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,
                         Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c,
                         Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(quote!=NULL) {
                quoteId = quote.id;
                customerId = quote.End_Customer__c;
            }
            
            ApexPages.Message myMsg;
            system.debug( '\n excelBody  ' + excelBody);
            system.debug( '\n uploadedSites  ' + uploadedSites);
            if(String.isNotBlank(excelBody)){
                if (excelBody!=NULL && customerId!=NULL && quoteId!=NULL){ 
                filelines = new String[]{}; 
                uploadedSites = new List <CustomerSite__c>();           
                      pageRefBulk= ATTBulkValidateUtil.ReadFile(quoteId,customerId,siteToRequestMap,filelines,excelBody,nameFile,uploadedSites,VASAResponse,pageInsertedSitesMap,selectedSitesWrapperList);
                    if (quote!=NULL && quote.id!=NULL){
                        pageRefBulk.getParameters().put('quoteid',quote.id);
                        pageRefBulk.getParameters().put('vmode','A');                                      
                    }        
                }
                //condition to cover error File scenario for MIS and AVPN added as part of 1705 ITS ticket
                if(pageRefBulk != null && pageRefBulk.getParameters().get('display') !=null && (quote.Product__r.Name == 'AT&T Switched Ethernet Service' || pageRefBulk.getParameters().get('display') == 'err' || pageRefBulk.getParameters().get('display') == 'fileErr' || pageRefBulk.getParameters().get('display') == 'blank')){
                    return pageRefBulk;
                }                
            }else{
                pageRefBulk.getParameters().put('display','invalid');
                pageRefBulk.getParameters().put('mode', ATTConstants.SITE_INFO);  
                pageRefBulk.getParameters().put('quoteid',quoteId);
                return pageRefBulk;
            }
        }catch(StringException strExp){
          pageRefBulk.getParameters().put('display','invalid');
            pageRefBulk.getParameters().put('mode', ATTConstants.SITE_INFO);  
            pageRefBulk.getParameters().put('quoteid',quoteId);
            return pageRefBulk;
        }
        return null;    
    }
    
    /*******************************************************************
    * Method name : doCSSDefine
    * Description : Method to define CSS Class for customer sites to indicate Exact match, Close match and no match for selected sites in right panel.
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/      
    public void doCSSDefine() {
        // String for CSS Class name 
        try{  
            String EXACTMATCHCLASS = BuyflowConstant.GLYPHICONOK;
            String NOMATCHCLASS = BuyflowConstant.GLYPHICONREMOVE;
            String CLOSEMATCHCLASS = BuyflowConstant.GLYPHICONMINUS;
            String EXACTMATCHBGCOLOR = BuyflowConstant.SIVARConst_4CA90C;
            String NOMATCHBGCOLOR = BuyflowConstant.B30A3C;
            String CLOSEMATCHBGCOLOR = BuyflowConstant.FFF200;
            
            // Iterate through selectedSitesList (left panel) and define CSS Class to be used in page.
            if (selectedSitesWrapperList!= NULL && selectedSitesWrapperList.size() > 0) {
                for (selectedSitesWrapper item: selectedSitesWrapperList) {
                    if(item.selectedSite != null) {
                        if(!isAIASelected) {
                            if(item.selectedSite.VASA_Response_Status__c != null && item.selectedSite.VASA_Response_Status__c.equalsIgnoreCase(BuyflowConstant.ADDRESSEXACT_MATCH)) {
                                item.glyphicon = EXACTMATCHCLASS;
                                item.backroundColor = EXACTMATCHBGCOLOR;
                            }else if (item.selectedSite.VASA_Response_Status__c != null && item.selectedSite.VASA_Response_Status__c.equalsIgnoreCase(BuyflowConstant.ADDRESSNO_MATCH)) {
                                item.glyphicon = NOMATCHCLASS;
                                item.backroundColor = NOMATCHBGCOLOR;
                            }else if (item.selectedSite.VASA_Response_Status__c != null && item.selectedSite.VASA_Response_Status__c.equalsIgnoreCase(BuyflowConstant.POSSIBLEMATCHES)) {
                                item.glyphicon = CLOSEMATCHCLASS;
                                item.backroundColor = CLOSEMATCHBGCOLOR;
                            }else {
                                item.glyphicon = SpecialCharacterConstant.CONCAT;
                                item.backroundColor = SpecialCharacterConstant.CONCAT;
                            }
                        }else{
                            if(item.selectedSite.BRASS_Response_Status__c != null 
                                    && (item.selectedSite.BRASS_Response_Status__c.equalsIgnoreCase('VALID') 
                                    || item.selectedSite.BRASS_Response_Status__c.equalsIgnoreCase('ALTERED ADDRESS'))) {
                                item.glyphicon = EXACTMATCHCLASS;
                                item.backroundColor = EXACTMATCHBGCOLOR;
                            }else if (item.selectedSite.BRASS_Response_Status__c != null && item.selectedSite.BRASS_Response_Status__c.equalsIgnoreCase('NO MATCH')) {
                                item.glyphicon = NOMATCHCLASS;
                                item.backroundColor = NOMATCHBGCOLOR;
                            }else if (item.selectedSite.BRASS_Response_Status__c != null && item.selectedSite.BRASS_Response_Status__c.equalsIgnoreCase('ALTERNATE ADDRESS')) {
                                item.glyphicon = CLOSEMATCHCLASS;
                                item.backroundColor = CLOSEMATCHBGCOLOR;
                            }else {
                                item.glyphicon = SpecialCharacterConstant.CONCAT;
                                item.backroundColor = SpecialCharacterConstant.CONCAT;
                            }
                        }
                    }
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }   
    }
    
    /*******************************************************************
    * Method name : doSiteSelectionCheck
    * Description : Method to check if any selected site (right panel) is set to true.
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/     
    public void doSiteSelectionCheck() {
        try { 
            boolean firstTime = false;
            if(selectedSitesWrapperList == null || selectedSitesWrapperList.isEmpty()) {
                doFetchSelectedSites();
                firstTime = true;
            }
            String selectedJunctionId = ApexPages.currentPage().getParameters().get('selectedJunctionId');
            isSiteSelected = false;
            for(selectedSitesWrapper item : selectedSitesWrapperList) {
                if(firstTime) {
                    if(item.junctionRecordId == selectedJunctionId) {
                        isSiteSelected = true;
                        item.isSelected = true;
                    }
                }else{
                    Boolean noneSelected = true;
                    if(item.isSelected){
                        isSiteSelected = true;
                        noneSelected = false;
                    }
                    if(noneSelected){
                        isSelectAll = false;
                    }
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }   
    }
    
    /*******************************************************************
    * Method name : doSiteSelectionAll
    * Description : Method to set all selected site (right panel) to true.
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/      
    public void doSiteSelectionAll() {
        try{  
            if(selectedSitesWrapperList == null || selectedSitesWrapperList.isEmpty()) {
                doFetchSelectedSites();
            }
            if (isSiteSelected){
                isSiteSelected = false;
            }else{
                isSiteSelected = true;
            }
            if (isSelectAll) {  
                for (selectedSitesWrapper item : selectedSitesWrapperList)  {
                    item.isSelected = true;           
                }
                isSiteSelected = true;
            } else {
                for (selectedSitesWrapper item : selectedSitesWrapperList) {
                    item.isSelected = false;           
                }
                isSiteSelected = false;
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }   
    }
    

    /*******************************************************************
    * Method name : doFetchUpdatingRecord
    * Description : Method to Auto-populate the customer site data into input fields based on user BuyflowConstant.EDIT click. Used for re-validating address 
    *               before Configure Sites.
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/ 
    public void doFetchUpdatingRecord() {
        try{  
            // Store site Id of siteToUpdate from page based on user click.
            if(quoteId == null) {
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            if(!Test.isRunningTest()){
                if(quoteId !=NULL && quote==null){ // (one time run to query quote and store end customer Id)
                    quote = new Apttus_Proposal__Proposal__c();
                    quote = [select id,Product_New_Name__c,RetrialFailure__c,End_Customer__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c,Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
                } 
            }   
            if(quote!=NULL) {
                quoteId = quote.id;
                customerId = quote.End_Customer__c;
                if(quote.Product__r.ProductCode == BuyflowConstant.AMIS){
                    productname = BuyflowConstant.MIS;
                }
                else if(quote.Product__r.ProductCode == BuyflowConstant.AVPN){
                    productname = BuyflowConstant.AVPN;
                }
                else if(quote.Product__r.ProductCode == BuyflowConstant.ASE){
                    productname = BuyflowConstant.ASE;
                }
            }
            
            Id siteId = Id.valueOf(apexpages.currentpage().getparameters().get('siteToUpdate'));
           
            ApexPages.Message myMsg;
            closeMatchAddrWrapper = new List <closeMatchAddressWrapper>();
            if (siteId != null) {
                customerSite = [SELECT id,Name, End_Customer__c,Speed_Name__c, Speed_Unit__c,VASAResponse__c,Service_Availability_Response__c,
                                    Service_Avail_Key__c,VASA_Response_Status__c, Country__c,Display_All_Speeds__c,Transport_Type__c,Urbanization__c,
                                    Phone__c,Zip_Code_Extension__c,Zip_Geo_Code__c,Speed_Physical_Value__c,Near_Match_Indicator__c,Quantity__c, 
                                    Site_Description__c, Site_Name__c, City__c, Address_Line__c, State__c, Zip_Code__c, 
                                    VASA_Request_Time__c, BRASSResponse__c, BRASS_Request_Time__c, BRASS_Response_Status__c, Location__c, RoomBuildingFloorInput__c, 
                                    ASE_ITPA_Response__c, ASE_ITPA_Response_Status__c From CustomerSite__c Where ID =: siteId order by CreatedDate desc];

                addressLine = customerSite.Address_Line__c;
                
                sAddressLine=addressLine;
                sSiteName=customerSite.Site_Name__c;
                sCity=customerSite.City__c;
                sLocation=customerSite.Location__c;
                sZip=customerSite.Zip_Code__c;
                sPhone=customerSite.Phone__c;
                sRoomBuildingFloorInput=customerSite.RoomBuildingFloorInput__c;
                
                List<ATT_StateMapping__c> stateList = new List<ATT_StateMapping__c>();
                if (customerSite !=NULL && customerSite.state__c!=NULL){
                    stateList = [SELECT Name,State_Code__c from ATT_StateMapping__c where State_Code__c = :customerSite.state__c];
                }
                if (stateList !=NULL && stateList.size()>0){
                    state = stateList[0].Name;
                }
                
                sState=state;
                if(productname == 'ASE'){
                    system.debug('@@@'+productname );
                    system.debug('@@@@customerSite.ASE_ITPA_Response_Status__c'+customerSite.ASE_ITPA_Response_Status__c);
                    if (customerSite.ASE_ITPA_Response_Status__c == BuyflowConstant.ADDRESSNO_MATCH){
                        myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Site_OverlayNoMatchMsg);
                        ApexPages.addMessage(myMsg);            
                    }else if (customerSite.ASE_ITPA_Response_Status__c == BuyflowConstant.POSSIBLEMATCHES) {
                        possibleMatchFlag = true;
                        myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Site_OverlayCloseMatchMsg);
                        ApexPages.addMessage(myMsg); 
                        
                        if (customerSite!=NULL){
                            String ASEITPAResponse = customerSite.ASE_ITPA_Response__c ; 
                            if (String.isNotBlank(ASEITPAResponse)){
                                String RegEx ='&quot;';
                                ASEITPAResponse = ASEITPAResponse.replaceAll(RegEx,'"'); 
                                ASEITPAResponseBean ResponseBean = new ASEITPAResponseBean();     
                                ResponseBean = (ASEITPAResponseBean)JSON.Deserialize(ASEITPAResponse,ASEITPAResponseBean.class);
                                system.debug('@@@@ResponseBean '+ResponseBean );
                                system.debug('@@@GISLocationAttributes'+ResponseBean.InquireTransportProductAvailabilityResponse.MultiProductAvailability.Location.GISLocationAttributes);
                                
                                List<ASEITPAResponseBean.GISLocationAttributes> addressMatchDetailsList = new List<ASEITPAResponseBean.GISLocationAttributes>();
                                if (ResponseBean!=NULL && ResponseBean.InquireTransportProductAvailabilityResponse.MultiProductAvailability != null && ResponseBean.InquireTransportProductAvailabilityResponse.MultiProductAvailability.Location.GISLocationAttributes!=NULL){
                                    addressMatchDetailsList.addAll(ResponseBean.InquireTransportProductAvailabilityResponse.MultiProductAvailability.Location.GISLocationAttributes);
                                }
                                system.debug('@@@addressMatchDetailsList'+addressMatchDetailsList);
                                
                                closeMatchAddrWrapper = new List <closeMatchAddressWrapper>();
                                Zip zipinfo;
                                Integer radioCount = 0;
                                for (ASEITPAResponseBean.GISLocationAttributes addressItem: addressMatchDetailsList) {
                                    radioCount++;
                                    system.debug('@@@@addressItem'+addressItem);
                                    zipInfo = new SiteAddressInformationController.Zip(
                                                            addressItem.FieldedAddress.postalCode, 
                                                            '', 
                                                            '');
                                    closeAddressMatch.add(new SiteAddressInformationController.AddressMatchDetails(
                                                            addressItem.FieldedAddress.houseNumber+
                                                              ((addressItem.FieldedAddress.streetName != null || addressItem.FieldedAddress.streetName != '') ? ' '+addressItem.FieldedAddress.streetName : '')+
                                                              ((addressItem.FieldedAddress.streetThoroughfare != null || addressItem.FieldedAddress.streetThoroughfare != '') ? ' '+addressItem.FieldedAddress.streetThoroughfare : ''), 
                                                            addressItem.FieldedAddress.city, 
                                                            addressItem.FieldedAddress.country, 
                                                            '', 
                                                            addressItem.FieldedAddress.state, zipInfo));
                                    closeMatchAddrWrapper.add(new SiteAddressInformationController.closeMatchAddressWrapper(
                                                            new SiteAddressInformationController.AddressMatchDetails(
                                                            addressItem.FieldedAddress.houseNumber+
                                                              ((addressItem.FieldedAddress.streetName != null || addressItem.FieldedAddress.streetName != '') ? ' '+addressItem.FieldedAddress.streetName : '')+
                                                              ((addressItem.FieldedAddress.streetThoroughfare != null || addressItem.FieldedAddress.streetThoroughfare != '') ? ' '+addressItem.FieldedAddress.streetThoroughfare : ''), 
                                                            addressItem.FieldedAddress.city, 
                                                            addressItem.FieldedAddress.country, 
                                                            '', 
                                                            addressItem.FieldedAddress.state, 
                                                            zipInfo),'SiteId'+radioCount,customerSite.id));
                                    system.debug('@@@@closeMatchAddrWrapper'+closeMatchAddrWrapper);
                                                            
                                }
                            }
                        }
                    } 
                }            
                else if(isAIASelected) {
                    if (customerSite.BRASS_Response_Status__c == BuyflowConstant.NOMATCH){
                        myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Site_OverlayNoMatchMsg);
                        ApexPages.addMessage(myMsg);            
                    } else if(customerSite.BRASS_Response_Status__c == BuyflowConstant.ALTERNATEADDRESS) {
                        //To do: When it will be clear hot to use the near match records: RK
                        possibleMatchFlag = true;
                        myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Site_OverlayCloseMatchMsg);
                        ApexPages.addMessage(myMsg);
                        
                        if (customerSite!=NULL){
                            String JSONresponse = customerSite.BRASSResponse__c; 
                            if (String.isNotBlank(JSONresponse)){
                                String RegEx ='&quot;';
                                JSONResponse = JSONResponse.replaceAll(RegEx,'"'); 
                                List<BRASS_Apex2JSON_Response> brassResponse = (List<BRASS_Apex2JSON_Response>)JSON.deserialize(JSONResponse , List<BRASS_Apex2JSON_Response>.class);
                                List<BRASS_Apex2JSON_Response.cls_GeoCode_Details> geoCodeDetailsList = new List<BRASS_Apex2JSON_Response.cls_GeoCode_Details>();
                       
                                if(brassResponse != null && !brassResponse.isEmpty()) {
                                    if(brassResponse[0].PreQualify_Response != null && brassResponse[0].PreQualify_Response.GeoCode_Result != null) {
                                        geoCodeDetailsList = brassResponse[0].PreQualify_Response.GeoCode_Result.GeoCode_Details;
                                    }
                                    
                                    closeMatchAddrWrapper = new List <closeMatchAddressWrapper>();
                                    Zip zipinfo;
                                    Integer radioCount = 0;
                                    if (geoCodeDetailsList!=NULL){
                                    for (BRASS_Apex2JSON_Response.cls_GeoCode_Details geoCodeDetailsObj: geoCodeDetailsList) {
                                        radioCount++;
                                        if(geoCodeDetailsObj.Address != null) {
                                            zipInfo = new SiteAddressInformationController.Zip(
                                                                geoCodeDetailsObj.Address.Zip, 
                                                                '', 
                                                                '');
                                            closeAddressMatch.add(new SiteAddressInformationController.AddressMatchDetails(
                                                                    geoCodeDetailsObj.Address.Street1 + 
                                                                        ((geoCodeDetailsObj.Address.Street2 != null 
                                                                            || geoCodeDetailsObj.Address.Street2 != '') 
                                                                            ? ' '+geoCodeDetailsObj.Address.Street2 : ''), 
                                                                    geoCodeDetailsObj.Address.City, 
                                                                    'US', 
                                                                    '', 
                                                                    geoCodeDetailsObj.Address.State, zipInfo));
                                            closeMatchAddrWrapper.add(new SiteAddressInformationController.closeMatchAddressWrapper(
                                                                        new SiteAddressInformationController.AddressMatchDetails(
                                                                        geoCodeDetailsObj.Address.Street1 + 
                                                                            ((geoCodeDetailsObj.Address.Street2 != null 
                                                                                || geoCodeDetailsObj.Address.Street2 != '') 
                                                                                ? ' '+geoCodeDetailsObj.Address.Street2 : ''), 
                                                                        geoCodeDetailsObj.Address.City, 
                                                                        'US', 
                                                                        '', 
                                                                        geoCodeDetailsObj.Address.State, zipInfo),'SiteId'+radioCount,customerSite.id));
                                            }
                                        }                               
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (customerSite.VASA_Response_Status__c == BuyflowConstant.ADDRESSNO_MATCH){
                        myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Site_OverlayNoMatchMsg);
                        ApexPages.addMessage(myMsg);            
                    }else if (customerSite.VASA_Response_Status__c == BuyflowConstant.POSSIBLEMATCHES) {
                        possibleMatchFlag = true;
                        myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Site_OverlayCloseMatchMsg);
                        ApexPages.addMessage(myMsg); 
                        
                        if(customerSite!=NULL){
                            String JSONresponse = customerSite.Service_Availability_Response__c ; 
                            if (String.isNotBlank(JSONresponse)){
                                String RegEx ='&quot;';
                                JSONResponse = JSONResponse.replaceAll(RegEx,'"'); 
                                AddrValidServAvailResponseBean ResponseBean = new AddrValidServAvailResponseBean();     
                                ResponseBean = (AddrValidServAvailResponseBean)JSON.Deserialize(JSONResponse,AddrValidServAvailResponseBean.class);
                                List<AddrValidServAvailResponseBean.AddressMatchDetails> addressMatchDetailsList = 
                                                            new List<AddrValidServAvailResponseBean.AddressMatchDetails>();
                                if (ResponseBean!=NULL && ResponseBean.AddressServiceAvailability != null && ResponseBean.AddressServiceAvailability[0]!=NULL && ResponseBean.AddressServiceAvailability[0].AddressMatchDetails != null){
                                    addressMatchDetailsList.addAll(ResponseBean.AddressServiceAvailability[0].AddressMatchDetails);
                                }
                              
                                closeMatchAddrWrapper = new List <closeMatchAddressWrapper>();
                                Zip zipinfo;
                                Integer radioCount = 0;
                                for (AddrValidServAvailResponseBean.AddressMatchDetails addressItem: addressMatchDetailsList) {
                                    radioCount++;
                                    zipInfo = new SiteAddressInformationController.Zip(
                                                            addressItem.zip.zipCode, 
                                                            addressItem.zip.zipCodeExtension, 
                                                            addressItem.zip.zipGeoCode);
                                    closeAddressMatch.add(new SiteAddressInformationController.AddressMatchDetails(
                                                            addressItem.street, 
                                                            addressItem.city, 
                                                            addressItem.country, 
                                                            addressItem.urbanization, 
                                                            addressItem.state, zipInfo));
                                    closeMatchAddrWrapper.add(new SiteAddressInformationController.closeMatchAddressWrapper(
                                                            new SiteAddressInformationController.AddressMatchDetails(
                                                            addressItem.street, 
                                                            addressItem.city, 
                                                            addressItem.country, 
                                                            addressItem.urbanization, 
                                                            addressItem.state, 
                                                            zipInfo),'SiteId'+radioCount,customerSite.id));
                                }
                            }
                        }
                    }
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }  
    }    
    
    /*******************************************************************
    * Wrapper Class Name : closeMatchAddressWrapper  
    *******************************************************************/ 
    public class closeMatchAddressWrapper {
        public Boolean isSelected {get; set;}
        public String siteId{get;set;}
        public AddressMatchDetails closeMatchAddress {get; private set;}
        public String radioId {get;set;}
        public closeMatchAddressWrapper(AddressMatchDetails closeMatchAddress, String radioId,String siteId) {
            this.isSelected = false;
            this.siteId=siteId;
            this.closeMatchAddress = closeMatchAddress;
            this.radioId = radioId;
        }
    }
    
    /*******************************************************************
    * Wrapper Class Name : AddressMatchDetails 
    *******************************************************************/    
    public class AddressMatchDetails {
        public string street {get; set;}
        public string city {get; set;}
        public string country {get; set;}
        public string urbanization {get; set;}
        public string state {get; set;}
        public Zip zip {get; set;}
        public AddressMatchDetails(String street, String city, String country, String urbanization, String state, Zip zip) {
            this.street = street;
            this.city = city;
            this.country = country;
            this.urbanization = urbanization;
            this.state = state;
            this.zip = zip;
        }
    }

    /*******************************************************************
    * Wrapper Class Name : Zip 
    *******************************************************************/ 
    public class Zip {
        public string zipCode {get; set;}
        public string zipCodeExtension {get; set;}
        public string zipGeoCode {get; set;}        
        public Zip(String zipCode, String zipCodeExtension, String zipGeoCode) {
            this.zipCode = zipCode;
            this.zipCodeExtension = zipCodeExtension;
            this.zipGeoCode = zipGeoCode;
        }
    }
    
    /*******************************************************************
    * Wrapper Class Name : matchIndicator
    *******************************************************************/    
    public class matchIndicator {
        public String className {get; private set;}
        public String bgcolor {get; private set;}   
        public matchIndicator(String className, String bgcolor) {
            this.className = className;
            this.bgcolor = bgcolor;
        }
    }  
    
    /*******************************************************************
    * Wrapper Class Name : existingSitesWrapper
    *******************************************************************/  
    public class existingSitesWrapper {
        public Boolean isSelected {get; set;}
        public CustomerSite__c existingSites {get; private set;}
        
        public existingSitesWrapper(CustomerSite__c existingSites, boolean bool) {
            try{
                this.isSelected = bool;
                this.existingSites = existingSites;
            }catch(Exception e){
                ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            }   
        }
    }
    
    /*******************************************************************
    * Wrapper Class Name : selectedSitesWrapper
    *******************************************************************/
    public class selectedSitesWrapper implements comparable{
        public Boolean isSelected {get; set;}
        public CustomerSite__c selectedSite {get; private set;}
        public String junctionRecordId {get; private set;}
        public String glyphicon {get;set;}
        public String backroundColor {get;set;}
        public AT_T_Customer_Site_Quote__c juncCreateddate {get;set;}
     
        public selectedSitesWrapper(CustomerSite__c selectedSite, AT_T_Customer_Site_Quote__c junctionRecordId) {
            try{
                this.isSelected = false;
                selectedSite.Service_Availability_Response__c='';
                this.selectedSite = selectedSite;
                this.junctionRecordId = junctionRecordId.Id;
                juncCreateddate = junctionRecordId;
                this.glyphicon = SpecialCharacterConstant.CONCAT;
                this.backroundColor = SpecialCharacterConstant.CONCAT;
            }
            catch(exception e){
                
            }           
        } 
        
        public Integer compareTo(Object objectToBePared){
            selectedSitesWrapper wrapperObj = (selectedSitesWrapper) objectToBePared;
            if(this.juncCreateddate.createddate > wrapperObj.juncCreateddate.createddate){
                return -1;
            }
            if(this.juncCreateddate.createddate < wrapperObj.juncCreateddate.createddate){
                return 1;
            }
            return 0;
        }     
    }
    
    /******************************************************************
    * Method name : getLocationPicklist
    * Description : Get values from custom setting for Location picklist 
    * Return Type : List<SelectOption>.
    * Parameters  : None.
    *******************************************************************/    
    public List<SelectOption> getLocationPicklist(){
        try{
            List<SelectOption> locationPicklist = new List<SelectOption>();
            List<ATT_LocationMapping__c> LocationList = ATT_LocationMapping__c.getall().values();
            if (LocationList!=NULL){
                for(ATT_LocationMapping__c item : LocationList){
                    locationPicklist.add(new selectoption(item.name,item.name));
                }
            }
            locationPicklist.sort();
            locationPicklist.add(0,new SelectOption('','Select'));
            return locationPicklist;
        }  
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }    
    
    /* 
    Name: addLATASites
    Description: 
    */ 
    public void addLATASites() {
        try{  
            List<String> vasaResponseList = new List<String>();
            Set<Id> customerSiteIdSet = new Set<Id>();
            Map<Id, CustomerSite__c> customerSiteIdCustSiteObjMap = new Map<Id, CustomerSite__c>();
            for(SelectedSitesWrapper wrapObj : selectedSitesWrapperList) {
                if(wrapObj.selectedSite != null) {
                    customerSiteIdSet.add(wrapObj.selectedSite.Id);
                    customerSiteIdCustSiteObjMap.put(wrapObj.selectedSite.Id, wrapObj.selectedSite);
                }
            }
            Map<Id, String> custSiteIdResMap = new Map<Id, String>();
            for(CustomerSite__c siteObj : [Select Id, Service_Availability_Response__c From CustomerSite__c Where Id In:customerSiteIdSet]) {
                if(siteObj.Service_Availability_Response__c != null) {
                    custSiteIdResMap.put(siteObj.Id, siteObj.Service_Availability_Response__c.replace('&quot;','"'));
                }
            }
        
            mapOfSites = new Map<Integer,List<CustomerSite__c>>();
            for(Id custSiteIdObj : custSiteIdResMap.keySet()) {
                AddrValidServAvailResponseBean bean = (AddrValidServAvailResponseBean) JSON.Deserialize(custSiteIdResMap.get(custSiteIdObj), AddrValidServAvailResponseBean.Class);
                Set<String> lataSet=new Set<String>();
                List<AddrValidServAvailResponseBean.AddressMatchDetails> aadrMatchDtlsList;
                
                for(AddrValidServAvailResponseBean.AddressServiceAvailability aaaaa:bean.AddressServiceAvailability ) { 
                    if(aaaaa.ServiceAvailabilityDetails !=null) {
                        AddrValidServAvailResponseBean.ServiceAvailabilityDetails serAvDetls = aaaaa.ServiceAvailabilityDetails;
                        if(serAvDetls.Ethernet !=null) {
                            AddrValidServAvailResponseBean.Ethernet ethrntObj = serAvDetls.Ethernet;
                            if(ethrntObj.lata != null) { 
                                Integer lataNum = ethrntObj.lata;
                                if(!mapOfSites.containsKey(lataNum)){ 
                                    if(customerSiteIdCustSiteObjMap.containsKey(custSiteIdObj) && customerSiteIdCustSiteObjMap.get(custSiteIdObj) != null) {
                                        mapOfSites.put(lataNum,new List<CustomerSite__c>{customerSiteIdCustSiteObjMap.get(custSiteIdObj)});
                                    }
                                }else{
                                    if(mapOfSites.get(lataNum) != null) {
                                        mapOfSites.get(lataNum).add(customerSiteIdCustSiteObjMap.get(custSiteIdObj));
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Integer lataCount=0;
            LataSelectedSitesWrapper wrap = null;
            list<LataSelectedSitesWrapper>lataWrapperList = new list<LataSelectedSitesWrapper>();
            for(Integer siteKey:mapOfSites.keySet()) {
                lataCount++;
                String LATA_Count='LATA'+String.valueOf(lataCount);
                wrap = new LataSelectedSitesWrapper(LATA_Count, mapOfSites.get(siteKey));
                lataWrapperList.add(wrap);
                mapOfLATAandSites.put(LATA_Count,mapOfSites.get(siteKey));
            }
        }catch(Exception e){
        ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }   
    }    
    
    /* 
    Name: LataSelectedSitesWrapper
    Type: Class      
    Description: 
    */ 
    public class LataSelectedSitesWrapper {
        public string lataName{get;set;}
        public List<CustomerSite__c> lataGrpSiteList{get;set;}
        public String selectButtonClass {get;set;}
    
        public LataSelectedSitesWrapper(String lataName, List<CustomerSite__c> lataGrpSiteList){
            try{  
                this.lataName = lataName;
                this.lataGrpSiteList = lataGrpSiteList;
                this.selectButtonClass = '';
            }catch(Exception e){
                ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            }   
        }
    }
    
    
    /* 
    Name: updateATTCustomerSiteJuntion
    Description: 
    */ 
    public void updateATTCustomerSiteJuntion() {
        try{
            String selectedLata = ApexPages.currentPage().getParameters().get('selectedLata');
            List<AT_T_Customer_Site_Quote__c> deleteList = [Select Id, AT_T_Quote__c From AT_T_Customer_Site_Quote__c Where AT_T_Quote__c =: quoteId];
            //Delete the existing records in case of LATA so that fresh Lata records will be added
            if(!deleteList.isEmpty()) {
                delete deleteList;
            }
            AT_T_Customer_Site_Quote__c junctionItem = null;
            List<AT_T_Customer_Site_Quote__c> junctionInsertList = new List<AT_T_Customer_Site_Quote__c>();
            for(CustomerSite__c custObj : mapOfLATAandSites.get(selectedLata)) {
                junctionItem = new AT_T_Customer_Site_Quote__c();
                junctionItem.AT_T_Customer_Site__c = custObj.id;
                junctionItem.AT_T_Quote__c = Id.valueOf(quoteId); 
                junctionInsertList.add(junctionItem);
            }
            
            if(!junctionInsertList.isEmpty()) {
                insert junctionInsertList;
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }  
    }
    
    
    /* 
    Name: updateJunctionOnExport
    Description: 
    */ 
    public void updateJunctionOnExport() {
        try{   
            Set<Id> junctionIdSet = new Set<Id>();
            for(selectedSitesWrapper wrapObj : selectedSitesWrapperList) {
                if(wrapObj.isSelected) {
                    junctionIdSet.add(wrapObj.junctionRecordId);
                }
            }
            List<AT_T_Customer_Site_Quote__c> junctionToUpdateList = new List<AT_T_Customer_Site_Quote__c>();
            for(AT_T_Customer_Site_Quote__c junctionObj : [Select Id, IsSelected__c From AT_T_Customer_Site_Quote__c Where Id In: junctionIdSet ]) {
                junctionObj.IsSelected__c = true;
                junctionToUpdateList.add(junctionObj);
            }
            if(!junctionToUpdateList.isEmpty()){
                update junctionToUpdateList;
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }   
    }
    
    /******************************Start Dynamic DataTable Change: RK**************************************************/
    private static String searchText = SpecialCharacterConstant.CONCAT;
    
    // Defines shape of JSON response
    global class Response {
        public Integer sEcho;
        public Integer iTotalRecords;
        public Integer iTotalDisplayRecords;
        Sobject[] aaData;
        Response(Integer echo, Integer total, Sobject[] sobs) {
            this.sEcho = echo;
            this.iTotalRecords = total;
            this.iTotalDisplayRecords = total;
            this.aaData = sobs;
        }
    }
    
    /* 
    Name: fetchCustomerSiteinfo1
    Description: 
    */ 
    public void fetchCustomerSiteinfo1(String a){
        try{
            quoteId =a;
            fetchCustomerSiteinfo();
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /* 
    Name: fetchCustomerSiteinfo
    Description: 
    */ 
    public void fetchCustomerSiteinfo(){
        try{
            if(!isConfigMode && !isReviewMode ){
                String product = SpecialCharacterConstant.CONCAT;
                if(quoteId == null) {
                    quoteId = apexpages.currentpage().getparameters().get('quoteid');
                    system.debug('fetchCustomerSiteinfo'+ quoteId );
                }
                String custId = SpecialCharacterConstant.CONCAT;
      
                List<Apttus_Proposal__Proposal__c> quoteList = [select id,Product_New_Name__c,RetrialFailure__c,End_Customer__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,Product__c,Product__r.Name,Product__r.ProductCode,Apttus_Proposal__Payment_Term__c,Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id =: quoteId ];
                if (quoteList!=NULL && quoteList.size()>0) {
                    custId = quoteList[0].End_Customer__c; 
                    if(quoteList[0].Product__r.ProductCode != null){                      
                        product = quoteList[0].Product__r.ProductCode;
                    }
                }
                system.debug('fetchCustomerSiteinfo custId is'+ custId );
                String whereClauseText = '';Set<Id> customerSiteIdSet = new Set<Id>();
                for (AT_T_Customer_Site_Quote__c item : [SELECT Id, AT_T_Customer_Site__c, CreatedDate from AT_T_Customer_Site_Quote__c where AT_T_Quote__c = :quoteId]) {
                        customerSiteIdSet.add(item.AT_T_Customer_Site__c);
                }
                List<CustomerSite__c> customerSiteList=new List<CustomerSite__c>();
                for(CustomerSite__c obj :[SELECT Id, Site_Name__c, Address_Line__c, City__c, State__c, Zip_Code__c, Phone__c,Location__c,VASA_Response_Status__c,ASE_ITPA_Response_Status__c,Speeds_Not_Available_ITPA__c,Raw_VASA_Response_Status__c From CustomerSite__c where Id IN : customerSiteIdSet order by CreatedDate desc]) {
                      customerSiteList.add(obj);
                }
                Map<String,boolean> junctionMap=new Map<String,boolean>();
                List<AT_T_Customer_Site_Quote__c> currentSiteQuote=new List<AT_T_Customer_Site_Quote__c>();
                for(AT_T_Customer_Site_Quote__c quoteObj :  [Select id,IsSoftRemove__c,AT_T_Customer_Site__c, AT_T_Quote__c from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=: quoteId and AT_T_Customer_Site__c IN : customerSiteIdSet]){
                    junctionMap.put(quoteObj.AT_T_Customer_Site__c,quoteObj.IsSoftRemove__c);
                }
                PopulateSiteAddReviewDataBuilder pTableBuilder = new PopulateSiteAddReviewDataBuilder(BuyflowConstant.SITEADDRESS_INFO_TABLE);           
                wrc = pTableBuilder.populateRevReqData(customerSiteList,junctionMap,product);
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }   
    }
    
    @RemoteAction
    global static Response fetchCustomerSiteRecords(List<Map<String, Object>> request) {
        String custId = SpecialCharacterConstant.CONCAT;
        Params p = new Params(request);
        if(p.quoteId != null && p.quoteId != SpecialCharacterConstant.CONCAT){
            List<Apttus_Proposal__Proposal__c> quoteList = [select id,Product_New_Name__c,RetrialFailure__c,End_Customer__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,Product__c,Product__r.Name,Product__r.ProductCode,Apttus_Proposal__Payment_Term__c,Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id =: p.quoteId];
            if (quoteList!=NULL && quoteList.size()>0) {
                custId = quoteList[0].End_Customer__c; 
            }
        
        }
        //String whereClauseText = (p.searchString != null && p.searchString != '') ? whereClause(p) : '';
        String whereClauseText = '';
        if(p.searchString != null && p.searchString != '') {
            searchText = '%'+string.escapeSingleQuotes(p.searchString)+'%';
            whereClauseText = 'Site_Name__c Like: searchText Or City__c Like: searchText Or State__c Like: searchText Or Zip_Code__c Like: searchText';
        }
        String soql = ''
                + ' select ' + String.join(p.columns, ', ')
                + ' from CustomerSite__c'
                + ' Where API_IPQ_Site__c = false AND End_Customer__c =: custId '+((whereClauseText != null && whereClauseText != '') ? 'AND ('+whereClauseText+')' :'')
                + ' order by ' + String.join(orderBys(p), ', ')
                + ' limit :length'
                +  ' offset :start'
                ;
        
        Integer start = p.start;
        Integer length = p.length;

        Response res = null;
        if(whereClauseText == SpecialCharacterConstant.CONCAT) {

            res = new Response(
                p.echo,
                [select Count() from CustomerSite__c Where API_IPQ_Site__c = false AND End_Customer__c =: custId limit 50000],
                Database.query(soql)
                );
        }else {
            res = new Response(
                p.echo,
                [select Count() from CustomerSite__c Where API_IPQ_Site__c = false AND End_Customer__c =: custId AND (Site_Name__c Like: searchText Or City__c Like: searchText Or State__c Like: searchText Or Zip_Code__c Like: searchText) limit 50000],
                Database.query(soql)
                );
        }
        
        List<CustomerSite__c> customerSiteList=new List<CustomerSite__c>();
        if(whereClauseText == SpecialCharacterConstant.CONCAT) {
            customerSiteList= [select Id, Site_Name__c, Address_Line__c, City__c, State__c, Zip_Code__c, Phone__c,Location__c,VASA_Response_Status__c,Structure__c, Level__c, Unit__c,Speeds_Not_Available_ITPA__c,Raw_VASA_Response_Status__c from CustomerSite__c Where End_Customer__c =: custId limit 50000];
        }else{
            customerSiteList= [select Id, Site_Name__c, Address_Line__c, City__c, State__c, Zip_Code__c, Phone__c,Location__c,VASA_Response_Status__c,Structure__c, Level__c, Unit__c,Speeds_Not_Available_ITPA__c,Raw_VASA_Response_Status__c from CustomerSite__c Where End_Customer__c =: custId AND (Site_Name__c Like: searchText Or City__c Like: searchText Or State__c Like: searchText Or Zip_Code__c Like: searchText) limit 50000];
        }
        whereClauseText = SpecialCharacterConstant.CONCAT;
        List<String> currentSiteLists=new List<String>();
        for(CustomerSite__c cList: customerSiteList){
            currentSiteLists.add(cList.id);
        }
  
        map<String,boolean> junctionMap = new map<String,boolean>();
        list<AT_T_Customer_Site_Quote__c> currentSiteQuote=new List<AT_T_Customer_Site_Quote__c>();
        List<String> selectedSites=new List<String>();
        list<CustomerSite__c> customerSiteListUpdated = new List<CustomerSite__c>();
        for(AT_T_Customer_Site_Quote__c quoteObj :  [Select id,IsSoftRemove__c,AT_T_Customer_Site__c, AT_T_Quote__c from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=: p.quoteId and AT_T_Customer_Site__c IN : currentSiteLists]){  
            junctionMap.put(quoteObj.AT_T_Customer_Site__c,quoteObj.IsSoftRemove__c);
        }
      
        for(CustomerSite__c obj :[SELECT Id, Site_Name__c, Address_Line__c, City__c, State__c, Zip_Code__c, Phone__c,Location__c,VASA_Response_Status__c,Structure__c, Level__c, Unit__c  From CustomerSite__c where Id IN : selectedSites order by CreatedDate desc]) {
            customerSiteListUpdated.add(obj);
        }
        return res;
    }
    
    private static String whereClause(Params p) {
        String whereClause = '';
        //searchText = p.searchString;
        searchText = '%test%';
        system.debug('Check Value: '+p.columns);
        system.debug('Check size: '+p.columns.size());
        boolean flag = false;
        for(Integer i=0;i<p.columns.size();i++){
            if(!p.columns[i].equalsIgnoreCase('Id')) {
                whereClause += p.columns[i]+' Like: searchText ';
            }
            
            if(i > 0 && i < (p.columns.size()-1)) {
                if(whereClause != '') {
                    whereClause += ' OR '; 
                }
            }
        }
        return whereClause;
    }
    
    private static String[] orderBys(Params p) {
        Map<String, String> soqlDirections = new Map<String, String>{
                'asc' => 'desc nulls last',
                'desc' => 'asc nulls first'
                };
        String[] orderBys = new String[] {};
        Integer min = Math.min(p.sortColumns.size(), p.sortDirections.size());
        for (Integer i = 0; i < min; i++) {
            if(p.columns[p.sortColumns[i]] == 'Id'){
                orderBys.add(''
                    + 'CreatedDate'
                    + ' '
                    + soqlDirections.get(p.sortDirections[i])
                    );
            }
            else{
                orderBys.add(''
                    + p.columns[p.sortColumns[i]]
                    + ' '
                    + soqlDirections.get(p.sortDirections[i])
                    );
            }
        }
        return orderBys;
    }
    
    // DataTable passes JSON definition of what server should do
    private class Params {
        Map<String, Object> m = new Map<String, Object>();
        Integer echo;
        Integer start;
        Integer length;
        String[] columns;
        String searchString;
        Integer[] sortColumns;
        String[] sortDirections;
        String quoteId;
        Params(List<Map<String, Object>> request) {
            for (Map<String, Object> r : request) {
                system.debug('r.get: '+r.get('name'));
                m.put((String) r.get('name'), r.get('value'));
            }
            system.debug('Print me: '+m);
            echo = integer('sEcho');
            start = integer('iDisplayStart');
            length = integer('iDisplayLength');
            columns = stringArray('mDataProp');
            sortColumns = integerArray('iSortCol');
            sortDirections = stringArray('sSortDir');
            quoteId = m.get('quoteId') != null ? (String)m.get('quoteId') : '';
            searchString = m.get('searchText') != null ? (String)m.get('searchText') : '';
        }
         
        String[] stringArray(String prefix){
            String[] strings = new String[] {};
            for (Object o : array(prefix)) {
                strings.add(o != null ? esc(String.valueOf(o)) :null);
            }
            return strings;
        }
         
        Integer[] integerArray(String prefix){
            Integer[] integers = new Integer[] {};
            for (Object o : array(prefix)) {
                integers.add(o != null ? Integer.valueOf(o) : null);
            }
            return integers;
        }
 
        Object[] array(String prefix){
            Object[] objects = new Object[] {};
            for (Integer i = 0; true; i++) {
                Object o = m.get(prefix + '_' + i);
                if (o != null) {
                    objects.add(o);
                } else {
                    break;
                }
            }
            return objects;
        }
         
        Integer integer(String name){
            Object o = m.get(name);
            if (o instanceof Decimal){
                return ((Decimal) o).intValue();
            }else if (o instanceof Integer){
                return (Integer) o;
            }else{
                return null;
            }
        }
         
        // Guard against SOQL injection
        String esc(String s) {
            return s != null ? String.escapeSingleQuotes(s) : null;
        }
    }
     
    /*******************************************************************
    * Method name : doSitesSelectionForAIA
    * Description : Method for validating and adding selected sites from existing sites table to the right panel.
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/     
    List<CustomerSite__c> sitesToValidateList = new List<CustomerSite__c>();
    public void doSitesSelectionForAIA() {
        try{  
            if(quoteId == null){
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            if(quoteId !=NULL && quote==null) { // (one time run to query quote and store end customer Id)
                quote = new Apttus_Proposal__Proposal__c();
                quote = [select id,Product_New_Name__c,RetrialFailure__c,End_Customer__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,
        Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c,
        Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(quote!=NULL) {
                quoteId = quote.id;
                customerId = quote.End_Customer__c;
            }
 
            //Changes for close Match Test: RK
            selectedCloseRadio = ApexPages.currentPage().getParameters().get('selectedCloseRadio');
            List <AddressMatchDetails> closeMatchUserSelectionList = new List <AddressMatchDetails>();
            if(possibleMatchFlag && !closeMatchAddrWrapper.isEmpty()){
                possibleMatchFlag = false;
                // Iterate through list of close match wrapper and store user selection in closeMatchUserSelectionList list.       
                for (closeMatchAddressWrapper item: closeMatchAddrWrapper) {
                    if (item.radioId == selectedCloseRadio) {
                        selectedCloseRadio = SpecialCharacterConstant.CONCAT;
                        closeMatchUserSelectionList.add(item.closeMatchAddress);
                    }
                }
            }
        
            if(!closeMatchUserSelectionList.isEmpty()) {
                customerSite.Address_Line__c = closeMatchUserSelectionList[0].street;
                customerSite.City__c = closeMatchUserSelectionList[0].city;
                customerSite.State__c = closeMatchUserSelectionList[0].state;
                customerSite.End_Customer__c = customerId;
                customerSite.Country__c = BuyflowConstant.US;
                customerSite.Zip_Code__c = closeMatchUserSelectionList[0].zip.zipcode;
            }else{
                customerSite.Address_Line__c = String.valueOf(addressLine + (room!=null?' '+room:'') + (floor!=null?' '+floor:''));
                if(String.isNotBlank(state) && state != 'Select a state'){
                    customerSite.State__c = ATT_StateMapping__c.getInstance(state) != null ? ATT_StateMapping__c.getInstance(state).State_Code__c: '';
                }
                // Assign end customer Id to customerSite instance.  
                customerSite.End_Customer__c = customerId;
                customerSite.Country__c = BuyflowConstant.US;
            }
            doPolling = false;
            
            sitesToValidateList = new List<CustomerSite__c>();
            sitesToValidateList.add(customerSite);
    
            if(sitesToValidateList!=NULL && sitesToValidateList.size()>0){ 
                conversationID = Math.Random() + '-' + quoteId;
                doPolling = ATTBulkValidateUtilAIA.doMultiSitesValidate(customerId,sitesToValidateList,siteToRequestMap,BRASSresponse,conversationID,true);
            }
        
            ApexPages.Message myMsg;
            if(!doPolling){
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'System Error Has Occured and/or Site with same details exists.');
                ApexPages.addMessage(myMsg);
                // Re-initialize the customer site variable for subsequent transaction.   
                customerSite = new CustomerSite__c();
                customerSite.RoomBuildingFloorInput__c = SpecialCharacterConstant.CONCAT;
                customerSite.location__c = SpecialCharacterConstant.CONCAT;
                customerSite.End_Customer__c  = customerId;
                state = SpecialCharacterConstant.CONCAT;
                location = SpecialCharacterConstant.CONCAT;
                addressLine = SpecialCharacterConstant.CONCAT;
            }
            // Initialize the Exact Match, Close Match and No match list and the close match wrapper.    
            exactAddressMatch = new List <AddressMatchDetails>();
            closeAddressMatch = new List <AddressMatchDetails>();
            noAddressMatch = new List <AddressMatchDetails>();
            closeMatchAddrWrapper = new List <closeMatchAddressWrapper>();
            
            doFetchSelectedSites();
            
            // Call doConfigure method to re-evaluate if sites can be configured.     
            doCheckIsConfigurable(); 
            pollingRequestStartTime = system.now();  
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }
    }

    /*******************************************************************
    * Method name : doMultipleSitesSelectionForAIA
    * Description : Method for validating and adding selected sites from existing sites table to the right panel.
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/    
    public void doMultipleSitesSelectionForAIA() {
        try{  
            if(quoteId == null) {
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            if (quoteId !=NULL && quote==null) { // (one time run to query quote and store end customer Id)
                quote = new Apttus_Proposal__Proposal__c();
                quote = [select id,Product_New_Name__c,RetrialFailure__c,End_Customer__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,
                            Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c,
                            Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(quote!=NULL) {
                quoteId = quote.id;
                customerId = quote.End_Customer__c;
            }

            // Create CustomerSite List to store selected customer sites.
            selectedSitesList = new List <CustomerSite__c>();
            
            //Start: Changes for dynamic Data Table: RK 11/21
            String selectedSitesId = ApexPages.currentPage().getParameters().get('selectedCustomerIds');
            if(selectedSitesId != null && selectedSitesId != SpecialCharacterConstant.CONCAT) {
                List<String> selectedSiteIdList = selectedSitesId.split(SpecialCharacterConstant.SEMICOLON);
                List<CustomerSite__c> fetchedCustomerSiteList = [SELECT Id,Name, End_Customer__c,Speed_Name__c, Speed_Unit__c,VASAResponse__c,
                                                                    Service_Availability_Response__c, Service_Avail_Key__c,VASA_Response_Status__c, 
                                                                    Country__c,Display_All_Speeds__c,Transport_Type__c,Urbanization__c,
                                                                    Phone__c,Zip_Code_Extension__c,Zip_Geo_Code__c,Speed_Physical_Value__c,
                                                                    Near_Match_Indicator__c,Quantity__c, Site_Description__c, BRASSResponse__c,
                                                                    BRASS_Request_Time__c, Site_Name__c, BRASS_Response_Status__c, City__c, 
                                                                    Address_Line__c, State__c, Zip_Code__c, VASA_Request_Time__c, Location__c, RoomBuildingFloorInput__c, Structure__c, Level__c, Unit__c  
                                                                    From CustomerSite__c where Id IN: selectedSiteIdList order by CreatedDate desc];
            
                List<CustomerSite__c> sitesToValidateList = new List<CustomerSite__c>();
                
                if(!fetchedCustomerSiteList.isEmpty()) {
                    for (CustomerSite__c obj: fetchedCustomerSiteList) {
                        sitesToValidateList.add(obj);
                    }
                }
                
                doPolling = false;
                
                if (sitesToValidateList!=NULL && sitesToValidateList.size()>0) {
                    conversationID = Math.Random() + SpecialCharacterConstant.HYPHEN + quoteId;
                    doPolling = ATTBulkValidateUtilAIA.doMultiSitesValidate(customerId,
            sitesToValidateList,siteToRequestMap,BRASSresponse,conversationID,false);
                }
                ApexPages.Message myMsg;
                if (doPolling){
                    myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Sites successfully sent for validation. We will update once completed.');
                    ApexPages.addMessage(myMsg);
                    
                } else {
                    myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'System Error Has Occured and/or Site with same details exists.');
                    ApexPages.addMessage(myMsg);
                }
                doFetchSelectedSites();
                // Call doConfigure method to re-evaluate if sites can be configured.     
                doCheckIsConfigurable(); 
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }   
    } 
    
    public DateTime pollingRequestStartTime = system.now();
      
    /* 
    Name: initPolling
    Description: 
    */ 
    public void initPolling(){
        try{  
            system.debug('@@@@inside initpolling');
            quoteId = apexpages.currentpage().getparameters().get('quoteId');
            if (quoteId !=NULL && quote==null) { 
                quote = new Apttus_Proposal__Proposal__c();
                quote = [select id,RetrialFailure__c,Review_Address_Check__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }   
            if(quote != null){
                if(quote.Product__r.ProductCode == BuyflowConstant.AMIS){
                    productname = BuyflowConstant.MIS;
                }
                else if(quote.Product__r.ProductCode == BuyflowConstant.AVPN){
                    productname = BuyflowConstant.AVPN;
                }
                else if(quote.Product__r.ProductCode == BuyflowConstant.ASE){
                    productname = BuyflowConstant.ASE;
                }
            }
            system.debug('\n quote.RetrialFailure__c' +  quote.RetrialFailure__c + '-- \n' +quote.Review_Address_Check__c +'\n @@@@productname'+productname ); 
             
            DateTime pollingRequestEndTime; 
            String converseId;
                    
            List<CustomerSite__c> CustomerSiteResult = new List<CustomerSite__c>();     
            //if (String.isNotBlank(conversationID)){       
            if (validSitesToConfigureList!=NULL && validSitesToConfigureList.size()>0){ 
                if(conversationID != null){ 
                    converseId = conversationID.substringAfterLast('-').replaceAll(' ','').toLowerCase();     
                }
                system.debug ('Read converse Id : ' + converseId + ',' + conversationId);       
                List<String> validSiteIds=new List<String>();       
                for(CustomerSite__c validateSites:validSitesToConfigureList){       
                    validSiteIds.add(validateSites.id);  
                }      
                system.debug('@@@@validSiteIds'+validSiteIds); 
                if(productname == BuyflowConstant.ASE){
                    CustomerSiteResult = [SELECT id, ASE_ITPA_Request_Time__c,ASE_ITPA_Response_Status__c,ASE_ITPA_Processing_Complete__c from CustomerSite__c where id IN :validSiteIds order by ASE_ITPA_Processing_Complete__c asc];       
                    system.debug('@@@CustomerSiteResult for ASE'+CustomerSiteResult );
                }
                else{
                    CustomerSiteResult = [SELECT id, VASA_Request_Time__c,VASA_Response_Status__c from CustomerSite__c where VASA_Request_Time__c !=NULL and id IN :validSiteIds order by CreatedDate desc];   
                    system.debug('@@@CustomerSiteResult for other products'+CustomerSiteResult );
                }
            }       
                    
            pollingRequestEndTime = system.now();      
            system.debug('@@@@pollingRequestEndTime '+pollingRequestEndTime );
                    
            if(CustomerSiteResult!=NULL && CustomerSiteResult.size()>0){       
                doPolling = false;      
                system.debug('@@@CustomerSiteResult'+CustomerSiteResult);    
                for(CustomerSite__c siteResult:CustomerSiteResult)      {
                    if(productname == BuyflowConstant.ASE){      
                        if(siteResult.ASE_ITPA_Response_Status__c != NULL && siteResult.ASE_ITPA_Processing_Complete__c == true){       
                            system.debug('@@@@ inside if --  ITPA processing');
                            doPolling = false;     
                        }       
                        else{       
                            system.debug('@@@@ inside else -- ITPA processing');
                            doPolling = true;         
                            break;      
                        } 
                    }
                    else{
                        if(siteResult.VASA_Response_Status__c != NULL){       
                            doPolling = false; 
                            system.debug('------VASA response is not null '+doPolling);    
                        }       
                        else{                                   
                            doPolling = true;         
                            break;      
                        } 
                    }      
                }            
                system.debug('------outside the checks and prior to enter add '+doPolling);                            
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Sites successfully validated and added.');        
                ApexPages.addMessage(myMsg);        
                        
                // Re-initialize the customer site variable for subsequent transaction.         
                customerSite = new CustomerSite__c();       
                customerSite.RoomBuildingFloorInput__c = SpecialCharacterConstant.CONCAT;        
                customerSite.location__c = SpecialCharacterConstant.CONCAT;      
                customerSite.End_Customer__c  = customerId;     
                state = SpecialCharacterConstant.CONCAT;     
                location = SpecialCharacterConstant.CONCAT;      
                addressLine = SpecialCharacterConstant.CONCAT;       
            }else if (Double.valueOf(pollingRequestEndTime.getTime() - pollingRequestStartTime.getTime()) > 180000){   
                doPolling = false;      
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Sites successfully sent for validation. We will update once completed.');     
                ApexPages.addMessage(myMsg);        
                // Re-initialize the customer site variable for subsequent transaction.        
                customerSite = new CustomerSite__c();       
                customerSite.RoomBuildingFloorInput__c = SpecialCharacterConstant.CONCAT;        
                customerSite.location__c = SpecialCharacterConstant.CONCAT;      
                customerSite.End_Customer__c  = customerId;     
                state = SpecialCharacterConstant.CONCAT;     
                location = SpecialCharacterConstant.CONCAT;      
                addressLine = SpecialCharacterConstant.CONCAT;       
            }
            else{
                doPolling = true;       
                system.debug('\n doPolling inside else'+doPolling);
            }
            system.debug('\n Polling Time'+Double.valueOf(pollingRequestEndTime.getTime() - pollingRequestStartTime.getTime()));       
            system.debug('\n Check fr '+doPolling); 
            doFetchSelectedSites();     
            //Call doConfigure method to re-evaluate if sites can be configured.           
            doCheckIsConfigurable();        
            system.debug('\n Another post do check configurable'+doPolling);
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }
    }   
    
    /* 
     Name: startPolling
     Description: 
     */ 
    public void startPolling(){
        try{   
            DateTime pollingRequestEndTime; 
            List<CustomerSite__c> CustomerSiteResult = new List<CustomerSite__c>();
            if(sitesToValidateList!=NULL && sitesToValidateList.size()>0){
               String converseId = conversationID.substringAfterLast('-').replaceAll(' ','').toLowerCase();
                system.debug ('Read converse Id : ' + converseId + ',' + conversationId);
                CustomerSiteResult = [SELECT id, BRASS_Request_Time__c from CustomerSite__c where BRASS_Request_Time__c!=NULL 
                and id=:sitesToValidateList[0].id order by CreatedDate  desc];
            }
            pollingRequestEndTime = system.now();
            
            if(CustomerSiteResult!=NULL && CustomerSiteResult.size()>0){
                doPolling = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Sites successfully validated and added.');
                ApexPages.addMessage(myMsg);
                
                // Re-initialize the customer site variable for subsequent transaction.   
                customerSite = new CustomerSite__c();
                customerSite.RoomBuildingFloorInput__c = SpecialCharacterConstant.CONCAT;
                customerSite.location__c = SpecialCharacterConstant.CONCAT;
                customerSite.End_Customer__c  = customerId;
                state = SpecialCharacterConstant.CONCAT;
                location = SpecialCharacterConstant.CONCAT;
                addressLine = SpecialCharacterConstant.CONCAT;
            }else if (Double.valueOf(pollingRequestEndTime.getTime() - pollingRequestStartTime.getTime()) > 180000){
                doPolling = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Sites successfully sent for validation. We will update once completed.');
                ApexPages.addMessage(myMsg);
                // Re-initialize the customer site variable for subsequent transaction.   
                customerSite = new CustomerSite__c();
                customerSite.RoomBuildingFloorInput__c = SpecialCharacterConstant.CONCAT;
                customerSite.location__c = SpecialCharacterConstant.CONCAT;
                customerSite.End_Customer__c  = customerId;
                state = SpecialCharacterConstant.CONCAT;
                location = SpecialCharacterConstant.CONCAT;
                addressLine = SpecialCharacterConstant.CONCAT;
            }
            doFetchSelectedSites();
            // Call doConfigure method to re-evaluate if sites can be configured.     
            doCheckIsConfigurable(); 
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }   
    }
    
    /* 
    Name: ReadFileForAIA
    Description: 
    */ 
    public PageReference ReadFileForAIA(){
        try{
            if(quoteId == null){
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            if(quoteId !=NULL && quote==null){ // (one time run to query quote and store end customer Id)
                quote = new Apttus_Proposal__Proposal__c();
                quote = [select id,Product_New_Name__c,End_Customer__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,
        Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c,
        Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(quote!=NULL) {
                quoteId = quote.id;
                customerId = quote.End_Customer__c;
            }
            PageReference pageRef = System.Page.buyflow;
            ApexPages.Message myMsg;
            
            if(String.isNotBlank(excelBody)){
                if(excelBody!=NULL && customerId!=NULL && quoteId!=NULL){  
                    conversationID = Math.Random() + '-' + quoteId;
                    pageRef = ATTBulkValidateUtilAIA.ReadFile(quoteId,customerId,siteToRequestMap,filelines,excelBody,nameFile,uploadedSites,BRASSResponse,pageInsertedSitesMap,selectedSitesWrapperList,conversationID);
                    pageRef.getParameters().put('quoteid',quoteId);
                }            
                return pageRef;
            }else{
                pageRef.getParameters().put('display','invalid');
                pageRef.getParameters().put('mode', ATTConstants.SITE_INFO);  
                pageRef.getParameters().put('quoteid',quoteId);
                return pageRef;
            }
            return null;    
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }
    }
    
    /* 
    Name: doConfigureAIA
    Description: 
    */     
    public boolean doConfigureAIA() {
        try{  
            if(quoteId == null) {
            quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            if (quoteId !=NULL && quote==null) { // (one time run to query quote and store end customer Id)
            quote = new Apttus_Proposal__Proposal__c();
            quote = [select id,Product_New_Name__c,RetrialFailure__c,End_Customer__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c,
                        Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(quote!=NULL) {
                quoteId = quote.id;
                customerId = quote.End_Customer__c;
            }

            boolean serviceAvailabilityStatus = false;
            String brassResponse = SpecialCharacterConstant.CONCAT;
            List<BRASS_Apex2JSON_Response> respBeanObjList = null;
            Set<Id> avaialbleSiteIdSet = new Set<Id>();
            for(CustomerSite__c siteObj : validSitesToConfigureList) {
                brassResponse = siteObj.BRASSResponse__c;
                if (String.isNotBlank(brassResponse)){
                    brassResponse = brassResponse.replaceALL('&quot;','"');
                    respBeanObjList = (List<BRASS_Apex2JSON_Response>)JSON.deserialize(brassResponse , List<BRASS_Apex2JSON_Response>.class);
                    if(respBeanObjList != null 
                        && respBeanObjList.size() > 0 
                        && respBeanObjList[0].PreQualify_Response != null 
                        && respBeanObjList[0].PreQualify_Response.ProductQualificationResults != null 
                        && respBeanObjList[0].PreQualify_Response.ProductQualificationResults.size() > 0) {
                        serviceAvailabilityStatus = true;
                        avaialbleSiteIdSet.add(siteObj.Id);
                    }                
                }
            }
            
            if(serviceAvailabilityStatus) {
                //Delete all the junction first 
                List<AT_T_Customer_Site_Quote__c> SiteQuoteList = [select id,AT_T_Customer_Site__c,AT_T_Customer_Site__r.Duplicate_Check__c From AT_T_Customer_Site_Quote__c where AT_T_Quote__r.id=:quoteId]; 
                if(!SiteQuoteList.isEmpty()) {
                    delete SiteQuoteList;
                }
                AT_T_Customer_Site_Quote__c validServAvlcustSiteQuoteObj = null;
                List<AT_T_Customer_Site_Quote__c> validServAvlcustSiteQuoteObjList = new List<AT_T_Customer_Site_Quote__c>();
                for(Id siteIdObj : avaialbleSiteIdSet) {
                    validServAvlcustSiteQuoteObj = new AT_T_Customer_Site_Quote__c();
                    validServAvlcustSiteQuoteObj.AT_T_Customer_Site__c = siteIdObj;
                    validServAvlcustSiteQuoteObj.AT_T_Quote__c = quoteid;
                    validServAvlcustSiteQuoteObjList.add(validServAvlcustSiteQuoteObj);
                }
                if(!validServAvlcustSiteQuoteObjList.isEmpty()) {
                    insert validServAvlcustSiteQuoteObjList;
                }
            }
            return serviceAvailabilityStatus;
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }
    }
 
    /* 
    Name: saveAndNavigateToDashboard
    Description: 
    */ 
    public PageReference  saveAndNavigateToDashboard(){
        try{
            String siteIDs = apexpages.currentpage().getparameters().get('siteIDs');
            system.debug('inside saveAndNavigateToDashboard and siteIDs is'+siteIDs+'and');
            List<String> siteIDList = new List<String>();
            if(siteIDs!=null && siteIDs!=''){
                siteIDList=siteIDs.split(',');
                if(quoteId == null) {
                    quoteId = apexpages.currentpage().getparameters().get('quoteid');
                }
                List<AT_T_Customer_Site_Quote__c> currentSiteQuote = new List<AT_T_Customer_Site_Quote__c>();
                for(AT_T_Customer_Site_Quote__c quoteObj :  [Select id,IsSoftRemove__c,AT_T_Customer_Site__c, AT_T_Quote__c from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=: quoteId and AT_T_Customer_Site__c IN : siteIDList]){
                    if(quoteObj.IsSoftRemove__c){
                        quoteObj.IsSoftRemove__c= false;}
                    else{
                        quoteObj.IsSoftRemove__c= true;}
                        currentSiteQuote.add(quoteObj);
                }
                update currentSiteQuote;
            } 
            statusQuote = new Apttus_Proposal__Proposal__c();
            statusQuote = [select id,Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            statusQuote.Apttus_Proposal__Approval_Stage__c = BuyflowConstant.DRAFT;
            update statusQuote ;
            PageReference AddaddressPage = system.page.PortalDashboard_UI; 
            return AddaddressPage  ;   
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }
    }

    /* 
    Name: createURLParams
    Description: 
    */ 
    public void createURLParams(){
        try{ 
            if(quoteId == null) {
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            if (quoteId !=NULL && quote==null) { 
                quote = new Apttus_Proposal__Proposal__c();
                quote = [select id,Review_Address_Check__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(quote!=NULL) {
                quote.Review_Address_Check__c = false;
            }
            update quote;

            if(quote!=NULL) {
                isReviewAddress = quote.Review_Address_Check__c;
            }
            AddaddressPageRef.getParameters().put('mode', 'siteinfo');
            AddaddressPageRef.getParameters().put('quoteid', quote.id); 
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }
    }
    
    /* 
    Name: goToEnterAddressPage
    Description: 
    */ 
    public PageReference goToEnterAddressPage() {
        try{
            createURLParams();
            return AddaddressPageRef;
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }
    }

    /* 
    Name: goToAddNewAddressTab
    Description: 
    */     
    public PageReference goToAddNewAddressTab() {
        try{  
            createURLParams();
            AddaddressPageRef.getParameters().put('addNewAddress', 'true');
            return AddaddressPageRef;
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }
    }

    /* 
    Name: goToConfigSitesPage
    Description: 
    */ 
    public PageReference goToConfigSitesPage() {
        try{
            if(quoteId == null) {
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            if (quoteId !=NULL && quote==null) { 
                quote = new Apttus_Proposal__Proposal__c();
                quote = [select id,RetrialFailure__c,Review_Address_Check__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(quote!=NULL) {
                quote.Review_Address_Check__c=false;
                quote.Buyflow_Step__c = BuyflowConstant.CONFIGURESITES;
                quote.Apttus_Proposal__Approval_Stage__c = BuyflowConstant.DRAFT;
            }
            update quote;
            
            String siteIDs = apexpages.currentpage().getparameters().get('siteIDs');
            system.debug('inside gottoConfigSitepage and SiteIds'+siteIDs);
            
            List<String> siteIDList = new List<String>();
            if(siteIDs!=null && siteIDs!=SpecialCharacterConstant.CONCAT){
                siteIDList=siteIDs.split(SpecialCharacterConstant.COMMA);
                
            }
            List<AT_T_Customer_Site_Quote__c> currentSiteQuote=new List<AT_T_Customer_Site_Quote__c>();
            for (AT_T_Customer_Site_Quote__c item : [SELECT Id, AT_T_Customer_Site__c,IsSoftRemove__c, CreatedDate from AT_T_Customer_Site_Quote__c where Id IN : siteIDList and IsSoftRemove__c=: true]){
                item.IsSoftRemove__c= false;
                currentSiteQuote.add(item);
            }
            update currentSiteQuote;
            
            if(siteIdList.size()>0){
                 /*****Untagging End Customer for IPQ Site*****/ 
                List<CustomerSite__c> custObj = new List<CustomerSite__c>();
                List<id> custIdList = new List<Id>();
                Map<id,Integer> siteMap = new Map<id,Integer>();
                List<Id> untagSIteIdList = new List<Id>();
                List<End_Customer__c> endObj = new List<End_Customer__c>();
                endObj = [Select id from End_Customer__c where Name = 'Rest_End_Customer'];
                custObj=[select id,End_Customer__c,Site_Name__c,API_IPQ_Site__c from CustomerSite__c where API_IPQ_Site__c = true AND id IN :siteIdList];
                if(!custObj.isEmpty()){
                    for(CustomerSite__c cust :custObj){
                        custIdList.add(cust.id);
                    }
                    for(AT_T_Customer_Site_Quote__c junObj : [select AT_T_Customer_Site__c from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c =: custIdList]){
                        if(siteMap.containsKey(junObj.AT_T_Customer_Site__c)){
                            siteMap.put(junObj.AT_T_Customer_Site__c,siteMap.get(junObj.AT_T_Customer_Site__c) + 1);
                        }else{
                            siteMap.put(junObj.AT_T_Customer_Site__c,1);
                        }
                    }
                    for(id siteId : siteMap.keySet()){
                        if(siteMap.get(siteId) <= 2){
                            untagSIteIdList.add(siteId);
                            System.debug('@@@untagSIteIdList---->'+untagSIteIdList);
                        }
                    }

                    for(CustomerSite__c cust1 :custObj){
                        if(untagSIteIdList.contains(cust1.id)){
                            cust1.Site_Name__c = '';
                            cust1.End_Customer__c = endObj[0].id;
                            System.debug('SUCCESSS');
                            update cust1;   
                        }
                    }
                }   
                /*******************/
                delete [select id from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c IN :siteIdList AND AT_T_Quote__c =: quoteId];
                delete [select id from Apttus_Config2__LineItem__c where AT_T_Customer_Site__c IN :siteIdList AND Quote_Id__c =: String.valueOf(quoteId).subString(0,15)];
                system.debug('@@@@@@quoteId------->'+quoteId);
                if(removePopupOnLoadFlag){
                    quote.siteremovalcheck__c = true;
                }
            }
            update quote;
            
            PageReference AddaddressPage = system.page.PortalDesign_Buyflow;
            AddaddressPage.getParameters().put('mode', 'confsites');
            AddaddressPage.getParameters().put('quoteid', quote.id); 
            AddaddressPage.setRedirect(true);
            return AddaddressPage;
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }
    }
        
    /* 
    Name: getExcelSheetSiteList
    Description: 
    */ 
    public List<ExportedSitesWrapper> getExcelSheetSiteList() {
        try{    
            List<ExportedSitesWrapper> exportedSitesWrapperList = new List<ExportedSitesWrapper>();
            ExportedSitesWrapper wrapper = null;

        for(CustomerSite__c obj : listOfSitesToExport ) {
            wrapper = new ExportedSitesWrapper(obj.Site_Name__c,
                                                obj.Site_Description__c,
                                                obj.Address_Line__c,
                                                obj.City__c,
                                                obj.State__c,
                                                obj.Zip_Code__c,
                                                obj.VASA_Response_Status__c == 'ADDRESS EXACT MATCH'? 'Ready To Configure': obj.VASA_Response_Status__c == 'POSSIBLE MATCHES'? 'Address Correction Needed': obj.VASA_Response_Status__c == 'ADDRESS NO MATCH'? 'Service Unavailable': '',
                                                obj.Location__c != 'Select' ?obj.Location__c:'',
                                                obj.RoomBuildingFloorInput__c != null ?''+obj.RoomBuildingFloorInput__c:'', 
                                                obj.Phone__c);
            exportedSitesWrapperList.add(wrapper);
            
        }
        
        return exportedSitesWrapperList;
          }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }
    }
    
    /* 
     Name: ExportedSitesWrapper
     Type: Class      
     Description: 
     */ 
    public class ExportedSitesWrapper {
        public String siteName {get;set;}
        public String siteDesc {get;set;}
        public String addressLine {get;set;}
        public String location {get;set;}
        public String locationNum {get;set;}
        public String city {get;set;}
        public String state {get;set;}
        public String zipcode {get;set;}
        public String status {get;set;}
        public String phone {get;set;}
        
        public ExportedSitesWrapper(String siteName,
    String siteDesc,
    String addressLine,
    String city,
    String state,
    String zipcode,
    String status,
    String location,
    String locationNum,
    String phone){
            this.siteName = siteName;
            this.siteDesc = siteDesc;
            this.addressLine = addressLine;
            this.city = city;
            this.state = state;
            this.zipcode = zipcode;
            this.status = status;
            this.location = location;
            this.locationNum = locationNum;
            this.phone = phone;
        }
    }

    /* 
    Name: updateJunctionObjectWrc
    Description: Method to update the junction object for isSelected = false
    */ 
    public void updateJunctionObjectWrc() {
        try{
            String siteIDs = apexpages.currentpage().getparameters().get('siteList');
            system.debug('@@@@siteIDList'+siteIDs);
            ExportCustomerSitesController ecsc=   new ExportCustomerSitesController ();
            wrcSites= ecsc.callLoadExportSites(siteIDs);
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }
    }
    
    /* 
    Name: updateJunctionObject
    Description: 
    */  
    public void updateJunctionObject() {
       try{
        string siteIDs = apexpages.currentpage().getparameters().get('siteList');
        list<string> siteIDList = new list<string>();
        if(siteIDs!=null && siteIDs!=SpecialCharacterConstant.CONCAT){
            siteIDList=siteIDs.split(SpecialCharacterConstant.COMMA);
        }
        if(siteIDList.size()> 0 && siteIDList != null) {
            listOfSitesToExport = [Select Id, Site_Name__c, City__c, State__c, Address_Line__c, Zip_Code__c, Site_Description__c, BRASS_Response_Status__c, Phone__c,VASA_Response_Status__c, Location__c, RoomBuildingFloorInput__c From CustomerSite__c where Id in :siteIDList order by Site_Name__c asc]; 
        }
        
      }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            } 
    }
    
    /*Method to update First Time ASE*/
    public void updateusersASE(){
        try{
            Apttus_Proposal__Proposal__c quoteObj = new Apttus_Proposal__Proposal__c();
            quoteId = apexpages.currentpage().getparameters().get('quoteId');
            if(quoteId != null) {
                quoteObj = [select Name, First_time_ASE__c from Apttus_Proposal__Proposal__c where id = :quoteId];                
            }
            quoteObj.First_time_ASE__c  = true;
            update quoteObj ;
            FirstTimeUserASE= true;
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }    
    }
    
    /*Method to reload review address on edit site*/
    
    public PageReference refreshEditSite(){
        PageReference retPageRef; 
        string prodCode;
        system.debug('Inside refreshEditSite **************************************' );
        
        try{  
            quoteId = apexpages.currentpage().getparameters().get('quoteid');
       
            if (quoteId !=NULL && quote==null) { 
                quote = new Apttus_Proposal__Proposal__c();
                quote = [select id,ProdCode__c,RetrialFailure__c,Product__c,Review_Address_Check__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(quote!=NULL){
                quote.Review_Address_Check__c=true;
                prodCode = quote.ProdCode__c;
            }
            update quote;
            
            retPageRef = Page.Buyflow;
            retPageRef.getParameters().put('quoteid', quote.id);
            retPageRef.getParameters().put('mode', 'siteinfo');
            retPageRef.setRedirect(true);
            return retPageRef;
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }
    }
    
    public boolean checkItpaStatus(){
        CustomerSite__c custSite = new CustomerSite__c();
        System.debug('customerSite.id ======='+custSiteIdASE);
        custSite = [Select ASE_ITPA_Processing_Complete__c ,id from CustomerSite__c where id =: custSiteIdASE];
        System.debug('ustSite.ASE_ITPA_Processing_Complete__c ======='+custSite.ASE_ITPA_Processing_Complete__c);
        return custSite.ASE_ITPA_Processing_Complete__c;
    
    }
    
    public void checkASEItpaStatus(){
        try{  
            String prodCode;
            Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();  
            quoteId = apexpages.currentpage().getparameters().get('quoteid');         
            if (quoteId !=NULL){ 
                proposal = [select id,ProdCode__c,RetrialFailure__c,Product__c,Review_Address_Check__c from Apttus_Proposal__Proposal__c where id = :Id.valueOf(quoteId)];
            }       
            if(proposal !=NULL) {
                prodCode = proposal.ProdCode__c;
            }
            System.debug('quote.ProdCode__c-----------------'+prodCode );
            if(prodCode == 'ASE'){
                checkStatusASE = false;                
                checkStatusASE = checkItpaStatus();   
            }
            else{
                checkStatusASE = true;
            }   
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
               
        }
    }
    
    /*
    Updated method for Sprint-51 316724
    */
    public Object configureSiteForITPA(){
      
        integer countOfNoServiceSite = 0;
        system.debug(' inside configureSiteForITPAAVPNAMIS and quoteproduct name is '+ quote.Product_New_Name__c);
        quoteObjITPA= new Apttus_Proposal__Proposal__c();
        PageReference retPageRef;
        if(quote.Product_New_Name__c=='AT&T Managed Internet Service' || quote.Product_New_Name__c == 'AT&T Virtual Private Network Service'){            
            boolean errorInInvocation = false;
            try{
                String quoteID='';
                quoteID=apexpages.currentpage().getparameters().get('quoteid');
                system.debug('quoteid -->'+quoteID);
                quoteObjITPA= [select id,Send_Email_on_Service_Complete__c,RetrialFailure__c,Apttus_Proposal__Approval_Stage__c ,vasa_modeA_request__c,Buyflow_Step__c ,End_Customer__c,Product_New_Name__c,End_Customer__r.Name,Ethernet_Configuration__c,Name,Review_Address_Check__c,Bulk_Sevice_Availability_Indicator__c,Product__c,Product__r.ProductCode,Product__r.Name,Apttus_Proposal__Payment_Term__c,Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id = :quoteID];
                
                List<AT_T_Customer_Site_Quote__c> oorJunctionList=new List<AT_T_Customer_Site_Quote__c>();
                List<AT_T_Customer_Site_Quote__c> jncSiteQuoteList = [SELECT Id, AT_T_Customer_Site__c, AT_T_Quote__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c  =: quoteId];
                List<String> siteIdSet=new List<String>();
                
                for(AT_T_Customer_Site_Quote__c jncSite : jncSiteQuoteList){
                    siteIdSet.add(jncSite.AT_T_Customer_Site__c);
                }
                ITPAcustSiteList=[SELECT Id,Has_Failed_Request__c,Alternate_Access_ITPA_Request_Time__c,Name, End_Customer__c, Speed_Unit__c,VASAResponse__c,
                                 Service_Availability_Response__c, VASA_Response_Status__c,Country__c,Display_All_Speeds__c,Transport_Type__c,Phone__c,Zip_Code_Extension__c,Zip_Geo_Code__c,Site_Description__c, Site_Name__c,  City__c,Address_Line__c, State__c, Zip_Code__c,  Location__c,Alternate_Access_ITPA_Response_Status__c,Structure__c, Level__c, Unit__c,Alternate_Access_latitude__c,Alternate_Access_level__c,Alternate_Access_locator__c,Alternate_Access_longitude__c,Speeds_Not_Available_ITPA__c,Raw_VASA_Response_Status__c,Alternate_Access_ITPA_Process_Completed__c,Alternate_Access_meetPointHCoordinate__c,Alternate_Access_meetPointVCoordinate__c,Alternate_Access_npaNxx__c,Alternate_Access_score__c,Alternate_Access_servingWireCenter__c,Alternate_Access_status__c,Alternate_Access_territoryIndicator__c,Alternate_Access_vendorName__c,Alternate_Access_code__c From CustomerSite__c where Id IN: siteIdSet AND API_IPQ_Site__c = false order by CreatedDate desc];
                Integer ITPA_Max_sites = Integer.valueOf(Max_sites_allowed_VASA__c.getValues('FLOWITPAMaxSite') != null ? Max_sites_allowed_VASA__c.getValues('FLOWITPAMaxSite').value__c: 9);       
                String regExp = '&quot;';
                  
                set<String> custIdSet=new Set<String>();
                list<CustomerSite__c> customerSiteList=new List<CustomerSite__c>(); 
                customerSiteErrorList=new List<CustomerSite__c>(); 
                list<AddrValidServAvailResponseBean.AddressServiceAvailability> addressServiceAvailabilityList = new  List<AddrValidServAvailResponseBean.AddressServiceAvailability>();
                system.debug('  custSiteList '+ITPAcustSiteList);
                for(CustomerSite__c custSite: ITPAcustSiteList){
                    if((custSite.Alternate_Access_ITPA_Request_Time__c != null && custSite.Alternate_Access_ITPA_Request_Time__c.date().daysBetween(system.now().date()) >30 ) || !(custSite.Alternate_Access_ITPA_Request_Time__c!=null) || custSite.Alternate_Access_ITPA_Response_Status__c != '200'){
                        customerSiteList.add(custSite);
                        custIdSet.add(custSite.id);
                    }

                    if((custSite.Alternate_Access_ITPA_Request_Time__c != null && custSite.Alternate_Access_ITPA_Request_Time__c.date().daysBetween(system.now().date()) <30 ) && (custSite.Alternate_Access_ITPA_Response_Status__c != '200' || custSite.Alternate_Access_ITPA_Response_Status__c != '900')) {
                            customerSiteErrorList.add(custSite);
                    }   
                }
                system.debug( ' ITPA_Max_sites   '+ITPA_Max_sites +' and isEmailSelected '+isEmailSelected+' and customerSiteList.size() '+customerSiteList.size());
                //online Process
                if(customerSiteList!=null && customerSiteList.size()>0 && customerSiteList.size()<=ITPA_Max_sites && !isEmailSelected){
                    system.debug('inside if and customerSiteList.size() '+customerSiteList.size());
                    FlowITPAIntegrationHandler handler=new FlowITPAIntegrationHandler();
                    ITPArequestList= handler.parseRequestBulk(customerSiteList,quoteID);
                    system.debug('requestList ' +ITPArequestList);
                    system.debug(' no of requests are '+ITPArequestList.size());
                    isITPAOnline=true;
                    return null;
                }
                //offline Process
                if((customerSiteList!=null && customerSiteList.size()>0 && customerSiteList.size()>ITPA_Max_sites) ||  isEmailSelected ) {
                    //Async call
                    system.debug('inside async block and no of sites are '+customerSiteList.size());
          
                    ID batchProcessId =  database.executeBatch(new FLOWITPABatchProcess(quoteID),1);                      
                    Apttus_Proposal__Proposal__c quoteToUpdate = new Apttus_Proposal__Proposal__c(); 
                    quoteToUpdate.vasa_modeB_request__c= true;                                             
                    quoteToUpdate.Id = quoteObjITPA.id;
                    quoteToUpdate.Apttus_Proposal__Approval_Stage__c = 'Bulk Service Availability Requested';
                    update quoteToUpdate;
                    PageReference pageRef_bulk = page.BuyFlow_VASABulk;
                    pageRef_bulk.getParameters().put('quoteId', quote.id);
                    pageRef_bulk.getParameters().put('vmode','B');
                    return pageRef_bulk;
                }    
                system.debug('\n isReviewAddress   '+isReviewAddress + '\n quoteObj.RetrialFailure__c ' + quoteObjITPA.RetrialFailure__c + '\n quoteObjITPA.Review_Address_Check__c' + quoteObjITPA.Review_Address_Check__c);     
            }catch(Exception e){
                ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            }
            system.debug('retPageRef ' +retPageRef);
            return retPageRef;            
        }else{
            retPageRef = doConfigure();
            return retPageRef;
        }
    }
    
    public Object CallITPAContinuation(){
        Continuation con;
        try{
            if(ITPArequestList!=null && ITPArequestList.size()>0){
                Integer continuationTime=Integer.valueof(Global_Variable__c.getValues('FlowITPAContinuationTime')!=null ? Global_Variable__c.getValues('FlowITPAContinuationTime').Value__c : BuyflowConstant.SIVARConst_120);
                String endPointURL = Global_Variable__c.getValues('FlowITPAEndPoint')!=null ? Global_Variable__c.getValues('FlowITPAEndPoint').Value__c : SpecialCharacterConstant.CONCAT; 
                String accessToken= Global_Variable__c.getValues('BlackFlagAccessToken')!=null ? Global_Variable__c.getValues('BlackFlagAccessToken').Value__c : SpecialCharacterConstant.CONCAT;    
                String  tokenType=  Global_Variable__c.getValues('BlackFlageTokenType')!=null ? Global_Variable__c.getValues('BlackFlageTokenType').Value__c : BuyflowConstant.BEARER_CONST;
                String authorizationHeader =tokenType+' ' + accessToken; 
                con = new Continuation(120);
                system.debug('con obj '+con);
                
                for(FlowITPARequestBean requestBean : ITPArequestList){
                    system.debug('calling request no '+currentReqNo+' and request is '+Json.serialize(requestBean));                
                    con.continuationMethod='processResponse';
                    HttpRequest request = new HttpRequest();  
                    Http connection = new Http();
                    HttpResponse response = new HttpResponse();  
                    request.setEndpoint(endPointURL);
                    request.setMethod(ATTConstants.PostMethod);
                    request.setHeader('X-CSI-TimeToLive', '120000');
                    request.setHeader('Content-Type', 'application/json');
                    request.setHeader('Authorization',authorizationHeader);
                    request.setTimeOut(120000);    
                    request.setBody(Json.serialize(requestBean)); 
                    requestLabel = con.addHttpRequest(request);
                    requestLabelList.add(requestLabel); 
                    currentReqNo++;
                }
            }
            else{
                Apttus_Proposal__Proposal__c quoteToUpdate = new Apttus_Proposal__Proposal__c(); 
                quoteToUpdate.Id = quoteId;
                quoteToUpdate.Review_Address_Check__c = true;
                quoteToUpdate.RetrialFailure__c=0;
                update quoteToUpdate ;

                PageReference retPageRef;
                retPageRef = Page.Buyflow;
                retPageRef.getParameters().put('quoteid', quoteId);
                retPageRef.getParameters().put('mode', 'siteinfo');
                retPageRef.setRedirect(true);
                return retPageRef;  
            } 
        }
        catch(Exception e){
            system.debug('Exception in CallITPAContinuation method of SiteAddressInformationController'+e+' at line no '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
        }            
       
        return con;
    }  
    
    public Object processResponse() {   
        PageReference retPageRef;
        integer countOfNoServiceSite = 0;
        boolean errorInInvocation = false;
        list<AT_T_Customer_Site_Quote__c> addRecCreatedSites = new list<AT_T_Customer_Site_Quote__c>();  
        try{   
            system.debug('inside processResponse method');
            result='';
            List<HttpResponse> responseList=new List<HttpResponse>();
            for(String str : requestLabelList){  
                HttpResponse response = Continuation.getResponse(str);
                //responseList.add(response);
                system.debug('inside processResponse method and request label '+str +' \n response '+response);
                if(response != null){
                    system.debug('response.getBody()  '+response.getBody());
                    this.result = response.getBody();
                    //resultList.add(result);
                    FlowITPAResposnseBean responseBean= (FlowITPAResposnseBean)JSON.deserialize(response.getBody(),FlowITPAResposnseBean.class);
                    List<FlowITPAResposnseBean.Site> addressList=new List<FlowITPAResposnseBean.Site>();
                    system.debug('addressList  '+addressList.size());
                    for(FlowITPAResposnseBean.Site site : addressList){
                        system.debug('site.description-->'+site.description);
                        if(site.description!=null && site.description!='' && site.description.contains('Failure')){
                            errorInInvocation = true;  
                        }
                    }  
                    if(response.getStatusCode() != 200){
                        errorInInvocation = true;
                    }
                    responseList.add(response);
                }
            }
            system.debug('errorInInvocation -->'+errorInInvocation );
            FlowITPAContinuationController controller=new FlowITPAContinuationController();
            controller.processFLOWITPAResponseBulk(responseList,ITPAcustSiteList);
          
            // *************New Logic to process the failed request*******************
            system.debug('ITPAcustSiteList '+ITPAcustSiteList);
            if(!ITPAcustSiteList.isEmpty()){
                for(CustomerSite__c custometSiteObj : ITPAcustSiteList){
                   if(custometSiteObj.Has_Failed_Request__c == true){
                       failedCustomerSiteIds.add(custometSiteObj.Id);
                       system.debug('===failedCustomerSiteIds==='+failedCustomerSiteIds);
                   }
                }
            }
                    
            //**************END of New Logic ******************************************
            
            //US827483  VASA ERROR MESSAGE IN CASE OF SERVICE FAILURE, CHECK FOR ADDRESS RECORD CREATED VALUE
            
            if(!addRecCreatedSites.isEmpty()){
                countOfNoServiceSite = addRecCreatedSites.size();
            } 
            if(failedCustomerSiteIds!= null && failedCustomerSiteIds.size()>0){
                system.debug('\n quote '+quoteObjITPA+ '\n countOfNoServiceSite '+countOfNoServiceSite);            
                quoteObjITPA.Review_Address_Check__c = false;
                isReviewAddress = quoteObjITPA.Review_Address_Check__c;
                addSiteSuccess = false;
                checkServErr = true;
                if(quoteObjITPA.RetrialFailure__c != null){
                    quoteObjITPA.RetrialFailure__c ++ ;
                }
                else{
                    quoteObjITPA.RetrialFailure__c = 1 ;
                }                               
                update quoteObjITPA;
            }
                        
            system.debug('\n isReviewAddress' +isReviewAddress + '\n checkServErr Post the check'+checkServErr + '\n quoteObjITPA.RetrialFailure__c '+ quoteObjITPA.RetrialFailure__c);                 
            if(quoteObjITPA.RetrialFailure__c!=null && quoteObjITPA.RetrialFailure__c> 0){
                checkServErr = true;   
                return null;
            }                        
            system.debug('\n This is outside the service site check '+'\n isReviewAddress ' +isReviewAddress + '\n checkServErr Post the check '+checkServErr + '\n quoteObjITPA.RetrialFailure__c '+ quoteObjITPA.RetrialFailure__c);  
                   
            if(countOfNoServiceSite == 0 && !(errorInInvocation) ){
               Apttus_Proposal__Proposal__c quoteToUpdate = new Apttus_Proposal__Proposal__c(); 
               quoteToUpdate.Id = quoteId;
               quoteToUpdate.Review_Address_Check__c = true;
               quoteToUpdate.RetrialFailure__c=0;
               update quoteToUpdate ;
               isReviewAddress = true;
               checkServErr = false ;
               
               retPageRef = Page.Buyflow;
               retPageRef.getParameters().put('quoteid', quoteId);
               retPageRef.getParameters().put('mode', 'siteinfo');
               retPageRef.setRedirect(true);
            }
        }
        catch(Exception e){
            system.debug('Exception in processResponse method of SiteAddressInformationController '+e+' at line no '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
        }
         return retPageRef;                      
    }       
       
    public void updateAddressCorrectionVasaCall(){
        System.debug('inside updateAddressCorrectionVasaCall '+adressCorrectionSiteId);        
        if(adressCorrectionSiteId!=null && adressCorrectionSiteId!=''){
             List<CustomerSite__c> custSiteList=[SELECT Id,Has_Failed_Request__c,Alternate_Access_ITPA_Request_Time__c,Name, End_Customer__c, Speed_Unit__c,VASAResponse__c,Service_Availability_Response__c, VASA_Response_Status__c,Country__c,Display_All_Speeds__c,Transport_Type__c,Phone__c,Zip_Code_Extension__c,Zip_Geo_Code__c,Site_Description__c, Site_Name__c,  City__c,Address_Line__c, State__c, Zip_Code__c,  Location__c,Alternate_Access_ITPA_Response_Status__c,Structure__c, Level__c, Unit__c,Alternate_Access_latitude__c,Alternate_Access_level__c,Alternate_Access_locator__c,Alternate_Access_longitude__c,Speeds_Not_Available_ITPA__c,Raw_VASA_Response_Status__c,Alternate_Access_ITPA_Process_Completed__c,Alternate_Access_meetPointHCoordinate__c,Alternate_Access_meetPointVCoordinate__c,Alternate_Access_npaNxx__c,Alternate_Access_score__c,Alternate_Access_servingWireCenter__c,Alternate_Access_status__c,Alternate_Access_territoryIndicator__c,Alternate_Access_vendorName__c,Alternate_Access_code__c From CustomerSite__c where Id =: adressCorrectionSiteId order by CreatedDate desc];
                
            String regExp = '&quot;';
                      
            if(custSiteList !=null && custSiteList.size()>0 ){
                FlowITPAIntegrationHandler handler=new FlowITPAIntegrationHandler();
                List<FlowITPARequestBean> requestList= handler.parseRequestBulk(custSiteList,quoteID);
                FlowITPAContinuationController  controller=new FlowITPAContinuationController();
                system.debug(' no of requests are '+requestList.size());
                integer i=1;
                List<HttpResponse> responseList=new List<HttpResponse>();
                for(FlowITPARequestBean requestBean : requestList){                
                    system.debug('calling request no '+i);                
                    i++;
                    HttpResponse response=new HttpResponse();
                    response= controller.InitiateCallBulk(requestBean,custSiteList);
                    responseList.add(response);
                }
                controller.processFLOWITPAResponseBulk(responseList,custSiteList);
                
                // *************New Logic to process the failed request*******************
                if(!custSiteList.isEmpty()){
                    for(CustomerSite__c custometSiteObj : custSiteList){
                        if(custometSiteObj.Has_Failed_Request__c == true){
                            failedCustomerSiteIds.add(custometSiteObj.Id);
                        }
                    }
                }
                //**************END of New Logic ******************************************
            }
        }    
    }
    
    public void callBlackFlag(){ 
        if(quote.Product_New_Name__c=='AT&T Managed Network Service' || quote.Product_New_Name__c == 'AT&T Virtual Private Network Service'){       
            DateTime authCodeExpireTime= BlackFlageCS__c.getValues('AuthCodeRequestTime')!=null ? BlackFlageCS__c.getValues('AuthCodeRequestTime').Value__c : system.now().addDays(-1);
            if(authCodeExpireTime.date().daysBetween(system.now().date())>0){
                BlackFlagIntegrationHandler blackFlagHandler=new BlackFlagIntegrationHandler();
                string token= blackFlagHandler.InvokeBlackFlag();
                system.debug('token -->'+token);
            }
        }
    }
    
    /**
    * Method : removeAddRecJunc()
    * Param : None
    * Returns : None
    * Description : Remove the junction records with Address record created only
    ***/
    public void removeAddRecJunc(){
        datetime outsideBufferPeriod = datetime.now().addDays(-30);
        if(selectedSitesWrapperList != null){
            for(Integer i = 0; i < selectedSitesWrapperList.size(); i++ ){
                SelectedSitesWrapper wrapObj = selectedSitesWrapperList[i];
                if(wrapObj.selectedSite != null) {              
                    if(wrapObj.selectedSite.VASA_Response_Status__c == BuyflowConstant.ADDRESS_RECORD_CREATED || wrapObj.selectedSite.VASA_Request_Time__c < outsideBufferPeriod) {
                        selectedSitesWrapperList.remove(i); 
                        i--;                    
                    }
                }
            }
        }
    }
    
    /**
    * Method : retriggerFailedRequest()
    * Param : List of Failed Customer Sites
    * Returns : None
    * Description : Retrigger the failed customer sites
    **/
    public PageReference callFirstRetriggerMethod(){ 
        system.debug('====inside first oncomplete for failed sites==='+failedCustomerSiteIds);
        if(!failedCustomerSiteIds.isEmpty()){
            list<CustomerSite__c> lstFailedCustomerSite = [SELECT Id,Has_Failed_Request__c,Alternate_Access_ITPA_Request_Time__c,Name, End_Customer__c, Speed_Unit__c,VASAResponse__c,Service_Availability_Response__c, VASA_Response_Status__c,Country__c,Display_All_Speeds__c,Transport_Type__c,Phone__c,Zip_Code_Extension__c,Zip_Geo_Code__c,Site_Description__c, Site_Name__c,  City__c,Address_Line__c, State__c, Zip_Code__c,  Location__c,Alternate_Access_ITPA_Response_Status__c,Structure__c, Level__c, Unit__c,Alternate_Access_latitude__c,Alternate_Access_level__c,Alternate_Access_locator__c,Alternate_Access_longitude__c,Speeds_Not_Available_ITPA__c,Raw_VASA_Response_Status__c,Alternate_Access_ITPA_Process_Completed__c,Alternate_Access_meetPointHCoordinate__c,Alternate_Access_meetPointVCoordinate__c,Alternate_Access_npaNxx__c,Alternate_Access_score__c,Alternate_Access_servingWireCenter__c,Alternate_Access_status__c,Alternate_Access_territoryIndicator__c,Alternate_Access_vendorName__c,Alternate_Access_code__c FROM CustomerSite__c WHERE Id IN : failedCustomerSiteIds];
                                                           
            if(!lstFailedCustomerSite.isEmpty()){
               
                FlowITPAIntegrationHandler handler = new FlowITPAIntegrationHandler();
                List<HttpResponse> responseList = new List<HttpResponse>();
                List<FlowITPARequestBean> requestList = handler.parseRequestBulk(lstFailedCustomerSite,quoteID);
                FlowITPAContinuationController controller = new FlowITPAContinuationController();
        
                for(FlowITPARequestBean  requestBean : requestList){
                    HttpResponse response = new HttpResponse();
                    response = controller.InitiateCallBulk(requestBean,lstFailedCustomerSite);               
                    responseList.add(response);
                }
                        
                controller.processFLOWITPAResponseBulk(responseList,lstFailedCustomerSite);
                
                // *************New Logic to process the failed request*******************
                            
                if(!lstFailedCustomerSite.isEmpty()){
                    for(CustomerSite__c customerSiteObj : lstFailedCustomerSite) {
                        if(customerSiteObj.Has_Failed_Request__c == true){
                            failedCustomerSiteIds2.add(customerSiteObj.Id);
                        }
                    }
                }
                           
                //**************END of New Logic ******************************************
            }
        }
        
        if(failedCustomerSiteIds2.isEmpty()){
            system.debug('===first retrigger is successful so redirect to next page===');
            
            Apttus_Proposal__Proposal__c quoteToUpdate = new Apttus_Proposal__Proposal__c(); 
            quoteToUpdate.Id = quoteId;
            quoteToUpdate.Review_Address_Check__c = true;
            update quoteToUpdate ;
            isReviewAddress = true;
            checkServErr = false ;
            
            PageReference retPageRef = Page.Buyflow;
            retPageRef.getParameters().put('quoteid', quoteId);
            retPageRef.getParameters().put('mode', 'siteinfo');
            retPageRef.setRedirect(true);
            return retPageRef; 
        }
        else{
            return Null;
        }
    }
    
    public PageReference callSecondRetriggerMethod(){   
        
        system.debug('====inside 2nd oncomplete for failed sites==='+failedCustomerSiteIds2);
                    
        if(!failedCustomerSiteIds2.isEmpty()) {
            list<CustomerSite__c> lstFailedCustomerSite = [SELECT Id,Has_Failed_Request__c,Alternate_Access_ITPA_Request_Time__c,Name, End_Customer__c, Speed_Unit__c,VASAResponse__c,Service_Availability_Response__c, VASA_Response_Status__c,Country__c,Display_All_Speeds__c,Transport_Type__c, Phone__c,Zip_Code_Extension__c,Zip_Geo_Code__c,Site_Description__c, Site_Name__c,  City__c,Address_Line__c, State__c, Zip_Code__c,  Location__c,Alternate_Access_ITPA_Response_Status__c, Structure__c, Level__c, Unit__c,Alternate_Access_latitude__c,Alternate_Access_level__c,Alternate_Access_locator__c,Alternate_Access_longitude__c,Speeds_Not_Available_ITPA__c,Raw_VASA_Response_Status__c,Alternate_Access_ITPA_Process_Completed__c,Alternate_Access_meetPointHCoordinate__c,Alternate_Access_meetPointVCoordinate__c,Alternate_Access_npaNxx__c,Alternate_Access_score__c,Alternate_Access_servingWireCenter__c,Alternate_Access_status__c,Alternate_Access_territoryIndicator__c,Alternate_Access_vendorName__c,Alternate_Access_code__c FROM CustomerSite__c WHERE Id IN : failedCustomerSiteIds2];
                                                           
            if(!lstFailedCustomerSite.isEmpty()){
               
               FlowITPAIntegrationHandler handler = new FlowITPAIntegrationHandler();
                List<HttpResponse> responseList = new List<HttpResponse>();
                List<FlowITPARequestBean> requestList = handler.parseRequestBulk(lstFailedCustomerSite,quoteID);
                FlowITPAContinuationController controller = new FlowITPAContinuationController();
        
                for(FlowITPARequestBean  requestBean : requestList){
                    HttpResponse response = new HttpResponse();
                    response = controller.InitiateCallBulk(requestBean,lstFailedCustomerSite);               
                    responseList.add(response);
                }
                        
                controller.processFLOWITPAResponseBulk(responseList,lstFailedCustomerSite);
                
                // *************New Logic to process the failed request*******************
                            
                if(!lstFailedCustomerSite.isEmpty()){
                    for(CustomerSite__c customerSiteObj : lstFailedCustomerSite) {
                        if(customerSiteObj.Has_Failed_Request__c == true){
                            failedCustomerSiteIds3.add(customerSiteObj.Id);
                        }
                    }
                }        
                //**************END of New Logic ******************************************
            }
        }
        
        if(failedCustomerSiteIds3.isEmpty()){
            system.debug('===second retrigger is successful so redirect to next page===');
            
            Apttus_Proposal__Proposal__c quoteToUpdate = new Apttus_Proposal__Proposal__c(); 
            quoteToUpdate.Id = quoteId;
            quoteToUpdate.Review_Address_Check__c = true;
            update quoteToUpdate ;
            isReviewAddress = true;
            checkServErr = false ;
            
            PageReference retPageRef = Page.Buyflow;
            retPageRef.getParameters().put('quoteid', quoteId);
            retPageRef.getParameters().put('mode', 'siteinfo');
            retPageRef.setRedirect(true);
            return retPageRef; 
        }
        else{
            return Null;
        }
    }
    
    public PageReference callThirdRetriggerMethod(){   
        system.debug('====inside 3rd oncomplete for failed sites==='+failedCustomerSiteIds2);
        if(!failedCustomerSiteIds3.isEmpty()) {
            
        
        list<CustomerSite__c> lstFailedCustomerSite = [SELECT Id,Has_Failed_Request__c,Alternate_Access_ITPA_Request_Time__c,Name, End_Customer__c, Speed_Unit__c,VASAResponse__c,Service_Availability_Response__c, VASA_Response_Status__c,Country__c,Display_All_Speeds__c,Transport_Type__c,
            Phone__c,Zip_Code_Extension__c,Zip_Geo_Code__c,Site_Description__c, Site_Name__c,  City__c,Address_Line__c, State__c, Zip_Code__c,  Location__c,Alternate_Access_ITPA_Response_Status__c,Structure__c, Level__c, Unit__c,Alternate_Access_latitude__c,Alternate_Access_level__c,Alternate_Access_locator__c,Alternate_Access_longitude__c,Speeds_Not_Available_ITPA__c,Raw_VASA_Response_Status__c,Alternate_Access_ITPA_Process_Completed__c,Alternate_Access_meetPointHCoordinate__c,Alternate_Access_meetPointVCoordinate__c,Alternate_Access_npaNxx__c,Alternate_Access_score__c,Alternate_Access_servingWireCenter__c,Alternate_Access_status__c,Alternate_Access_territoryIndicator__c,Alternate_Access_vendorName__c,Alternate_Access_code__c FROM CustomerSite__c WHERE Id IN : failedCustomerSiteIds3];
                                                           
            if(!lstFailedCustomerSite.isEmpty()){
               
               FlowITPAIntegrationHandler handler = new FlowITPAIntegrationHandler();
                List<HttpResponse> responseList = new List<HttpResponse>();
                List<FlowITPARequestBean> requestList = handler.parseRequestBulk(lstFailedCustomerSite,quoteID);
                FlowITPAContinuationController controller = new FlowITPAContinuationController();
        
                for(FlowITPARequestBean  requestBean : requestList){
                    HttpResponse response = new HttpResponse();
                    response = controller.InitiateCallBulk(requestBean,lstFailedCustomerSite);               
                    responseList.add(response);
                }
                controller.processFLOWITPAResponseBulk(responseList,lstFailedCustomerSite);
                
                // *************New Logic to process the failed request*******************
                if(!lstFailedCustomerSite.isEmpty()){
                    for(CustomerSite__c customerSiteObj : lstFailedCustomerSite) {
                        if(customerSiteObj.Has_Failed_Request__c == true){
                            failedCustomerSiteIds4.add(customerSiteObj.Id);
                        }
                    }
                }         
                //**************END of New Logic ******************************************
            }
        }
        
        if(failedCustomerSiteIds4.isEmpty()){
            system.debug('===third retrigger is successful so redirect to next page===');            
            Apttus_Proposal__Proposal__c quoteToUpdate = new Apttus_Proposal__Proposal__c(); 
            quoteToUpdate.Id = quoteId;
            quoteToUpdate.Review_Address_Check__c = true;
            update quoteToUpdate ;
            isReviewAddress = true;
            checkServErr = false ;
            
            PageReference retPageRef = Page.Buyflow;
            retPageRef.getParameters().put('quoteid', quoteId);
            retPageRef.getParameters().put('mode', 'siteinfo');
            retPageRef.setRedirect(true);
            return retPageRef; 
        }
        else{
            return Null;
        }
    }
    
    public PageReference CreateITSupportTicket() {  
        system.debug('===create IT Support tickets====='+failedCustomerSiteIds4);
        // call the class 
        if(!failedCustomerSiteIds4.isEmpty()) {
            createITSTicketForFailedSites.createITSTickets(failedCustomerSiteIds4);
        }
        system.debug('===Third retrigger failed,ITS ticket created and redirecting to next page====='+failedCustomerSiteIds4);
    
        Apttus_Proposal__Proposal__c quoteToUpdate = new Apttus_Proposal__Proposal__c(); 
        quoteToUpdate.Id = quoteId;
        quoteToUpdate.Review_Address_Check__c = true;
        update quoteToUpdate ;
        isReviewAddress = true;
        checkServErr = false ;
            
        PageReference retPageRef = Page.Buyflow;
        retPageRef.getParameters().put('quoteid', quoteId);
        retPageRef.getParameters().put('mode', 'siteinfo');
        retPageRef.setRedirect(true);
        return retPageRef; 
    }
    
    public PageReference discardChanges(){
        PageReference reconfigurePage;
        checkDiscard = false;
        try{
            if(String.isBlank(quoteId)){
                quoteId = apexpages.currentpage().getparameters().get('quoteId');
            }
            DiscardFunctionalityHandler dFH = new DiscardFunctionalityHandler();
            dFH.discardNewChangesOnQuote(quoteId);
            reconfigurePage = system.page.dealreg;
            reconfigurePage.getParameters().put('quoteId', quoteId);
            reconfigurePage.getParameters().put('mode', 'regdeal');
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
        return reconfigurePage;
    }
        
    /* 
    Name: retrieveSiteToken
    Description: 
    */ 
    public void retrieveSiteToken(){ 
        try{        
            lstCustomerSite = new List<CustomerSite__c>();
            retreiveTokenErrorMsg = SpecialCharacterConstant.CONCAT;
            retrieveBulkSuccessFlag = false;
            retrieveBulkTokenFlag = false;
            retrieveBulkErrorFlag = false;
            system.debug('===userInputToken=='+userInputToken);
            system.debug('===retrieveExcelBody=='+retrieveExcelBody);
            
            String[] filelines = new String[]{};
            Apttus_Proposal__Proposal__c quoteObj = new Apttus_Proposal__Proposal__c();
            list<Apttus_Config2__ProductAttributeValue__c> avList = new list<Apttus_Config2__ProductAttributeValue__c>();
            list<AT_T_Customer_Site_Quote__c> attCustSiteJuncListObj = new list<AT_T_Customer_Site_Quote__c>();
            if(quoteId != null) {
                quoteObj = [select Name,Product__c,Product__r.Name,End_Customer__c,Apttus_Proposal__Payment_Term__c, Apttus_Proposal__Opportunity__c,Apttus_Proposal__Opportunity__r.StageName,Apttus_Proposal__Account__c,End_Customer_Name__c from Apttus_Proposal__Proposal__c where id =:quoteId Limit 1];                   
                attCustSiteJuncListObj = [select id, AT_T_Customer_Site__c, AT_T_Quote__c from AT_T_Customer_Site_Quote__c where AT_T_Quote__c =: quoteId];
            }
            
            if(String.isNotBlank(userInputToken) && userInputToken.startsWithIgnoreCase('a53') && userInputToken.length() == 15){            
                string customerSitesList = 'SELECT Id,Name,Site_Name__c,End_Customer__c,End_Customer__r.Name,IPQProposal__r.Name,IPQProposal__r.Apttus_Proposal__Payment_Term__c,IPQProposal__r.Product__r.Name,IPQProposal__r.Apttus_Proposal__Account__c,IPQProposal__r.End_Customer__c,CreatedDate,Address_Line__c,IPQProposal__c,Location__c,City__c,State__c,Zip_Code__c,End_Customer_Name__c,Site_Quote_Expiration_Date__c FROM CustomerSite__c where Id = \''+String.escapeSingleQuotes(userInputToken)+'\' Limit 1';  
                lstCustomerSite = Database.query(customerSitesList);                                                    
            }
            system.debug('===lstCustomerSite=='+lstCustomerSite); 
            
            system.debug('@@@lstCustomerSite[0].IPQProposal__r.Apttus_Proposal__Account__c: '+lstCustomerSite[0].IPQProposal__r.Apttus_Proposal__Account__c);
            system.debug('@@@quoteObj.Apttus_Proposal__Account__c: '+quoteObj.Apttus_Proposal__Account__c);
            if(!lstCustomerSite.isEmpty() && lstCustomerSite[0].IPQProposal__r.Apttus_Proposal__Account__c == quoteObj.Apttus_Proposal__Account__c) {
                showRelatedSites = true;
                retreiveCustomerSite = lstCustomerSite[0];
                retreiveCustomerSite.Site_Name__c = SpecialCharacterConstant.CONCAT;
                if(quoteObj.End_Customer__c != null){
                    retreiveCustomerSite.End_Customer__c = quoteObj.End_Customer__c;
                }
                for(CustomerSite__c cs : lstCustomerSite){
                    tokenId = String.valueOf(cs.Id).subString(0,15);
                    tokenaddress = cs.Address_Line__c;
                    tokenlocation = cs.Location__c;
                    tokencity = cs.City__c;
                    tokenstate = cs.State__c;
                    tokenzip = cs.Zip_Code__c; 
                    tokenquoteid = cs.IPQProposal__r.Name;
                }
                system.debug('===tokenquoteid=='+tokenquoteid);
                 
                if(String.isNotBlank(tokenquoteid)){
                    avList = [select id,Port_Speed_Generic__c,Access_Speed_Generic__c,Proposal__c from Apttus_Config2__ProductAttributeValue__c where Proposal__c =: tokenquoteid LIMIT 1];
                    if(avList.size()>0){
                        tokenPortSpeed = avList[0].Port_Speed_Generic__c != null ? avList[0].Port_Speed_Generic__c: '' ;                              
                        tokenAccessSpeed = avList[0].Access_Speed_Generic__c != null ? avList[0].Access_Speed_Generic__c: '';
                    }
                }
                system.debug('@@@Token Port Speed: '+tokenPortSpeed);  
                system.debug('@@@Token Access Speed: '+tokenAccessSpeed); 
                
                Date currentDate = Date.Today();   
                
                if(lstCustomerSite[0].IPQProposal__r.Product__r.Name != quoteObj.Product__r.Name){
                    retreiveTokenErrorMsg = 'Token is invalid for product type';
                    showRelatedSites = false;  
                }            
                else if(lstCustomerSite[0].IPQProposal__r.Apttus_Proposal__Payment_Term__c != quoteObj.Apttus_Proposal__Payment_Term__c){
                    retreiveTokenErrorMsg = 'Token is invalid for selected term';
                    showRelatedSites = false;
                }
                else if(lstCustomerSite[0].Site_Quote_Expiration_Date__c < currentDate){
                    retreiveTokenErrorMsg = 'Token is expired';
                    showRelatedSites = false;
                }            
                else if((lstCustomerSite[0].End_Customer_Name__c != quoteObj.End_Customer_Name__c) && lstCustomerSite[0].End_Customer_Name__c != 'Rest_End_Customer'){
                    retreiveTokenErrorMsg = 'Token ID is already associated with'+' '+lstCustomerSite[0].End_Customer_Name__c;
                    showRelatedSites = false;
                }   
                else if(attCustSiteJuncListObj != null && attCustSiteJuncListObj.size() > 0){
                    for(AT_T_Customer_Site_Quote__c siteJunc : attCustSiteJuncListObj){
                        if(siteJunc.AT_T_Customer_Site__c == lstCustomerSite[0].id){
                            retreiveTokenErrorMsg = 'Site is already added to quote';
                            showRelatedSites = false;
                        }
                    }
                }  
            }
            else{
                retreiveTokenErrorMsg = 'Token not found';
                showRelatedSites = false;  
            }
        }
        catch(Exception e){             
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            retreiveTokenErrorMsg = 'Token not found';
            showRelatedSites = false; 
        }
    }
    
    /*******************************************************************
    * Method name : retrieveMultipleSiteToken
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/ 
    public void retrieveMultipleSiteToken(){
        try{
            system.debug('@@@Excel Body: '+retrieveExcelBody); 
            String[] filelines = new String[]{};
            if(!String.isBlank(retrieveExcelBody)){
                retrieveBulkLimitExceeds = false;
                retrieveBulkErrorFlag = false;
                tokenErrorMap = new Map<String,String>();
                tokenIdSiteNameMap = new Map<String,String>();
                List<String> allRows = retrieveExcelBody.split(SpecialcharacterConstant.TIDAL);
                system.debug('allRows ====='+allRows);
                if(allRows != null && allRows.size()>203){
                    retrieveBulkLimitExceeds = true;
                    return;
                }
                for(integer i=3; i<allrows.size(); i++){
                    filelines.add(allrows[i]);
                }
                for(Integer i=0;i<filelines.size();i++){
                    String[] inputColumnArray = new String[]{}; 
                    inputColumnArray = filelines[i].split(SpecialcharacterConstant.COMMA);
                    String tokenId = SpecialCharacterConstant.CONCAT;
                    String siteName = SpecialCharacterConstant.CONCAT;
                    if(inputColumnArray.size() >= 2 && String.isNotBlank(inputColumnArray[0]) && String.isNotBlank(inputColumnArray[1])){
                        if(inputColumnArray[0].length()>15){
                            tokenId = String.valueOf(inputColumnArray[0]).subString(0,15);
                        }else{
                            tokenId = inputColumnArray[0];
                        }
                        siteName = inputColumnArray[1];
                        tokenIdSiteNameMap.put(tokenId,siteName);
                    }
                }
                system.debug('tokenIdSiteNameMap==='+tokenIdSiteNameMap);
                if(tokenIdSiteNameMap.size() > 0){
                    retrieveBulkSiteToken(tokenIdSiteNameMap);
                }
            }
        }
        catch(Exception e){  
            system.debug('@@@Exception caught in retrieveMultipleSiteToken method : '+e+'at Line Number: '+e.getLineNumber());           
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
     /*******************************************************************
    * Method name : retrieveBulkSiteToken
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/
    public void retrieveBulkSiteToken(Map<String,String> tokenIdSiteNameMap){
        try{
            Integer Max_tokens_allowed = Integer.valueOf(Max_sites_allowed_VASA__c.getValues('AddSiteTokens') != null ? Max_sites_allowed_VASA__c.getValues('AddSiteTokens').value__c: 0);
            List<CustomerSite__c> lstCustomerSite = new List<CustomerSite__c>();
            Map<string,string> tokenSuccessMap = new Map<String,String>();
            Set<String> allSiteIdSet = new Set<String>();
            
            Apttus_Proposal__Proposal__c quoteObj = new Apttus_Proposal__Proposal__c();
            list<AT_T_Customer_Site_Quote__c> attCustSiteJuncListObj = new list<AT_T_Customer_Site_Quote__c>();            
            Date currentDate = Date.Today(); 
            
            if(quoteId != null){
                quoteObj = [select Name,Product__c,Product__r.Name,End_Customer__c,Apttus_Proposal__Payment_Term__c, Apttus_Proposal__Opportunity__c,Apttus_Proposal__Opportunity__r.StageName,Apttus_Proposal__Account__c,End_Customer_Name__c,Bulk_Add_Token_Batch_Completed__c,Token_Bulk_Service_Indicator__c,Apttus_Proposal__Approval_Stage__c  from Apttus_Proposal__Proposal__c where id =:quoteId]; 
                attCustSiteJuncListObj = [select id, AT_T_Customer_Site__c, AT_T_Quote__c from AT_T_Customer_Site_Quote__c where AT_T_Quote__c =: quoteId];
            }  

            if(tokenIdSiteNameMap.size() > 0){
                allSiteIdSet.addAll(tokenIdSiteNameMap.keySet());
                string customerSitesList = 'SELECT Id,Name,Site_Name__c,End_Customer__c,End_Customer__r.Name,IPQProposal__r.Name,IPQProposal__r.Apttus_Proposal__Payment_Term__c,IPQProposal__r.Product__r.Name,IPQProposal__r.Apttus_Proposal__Account__c,IPQProposal__r.End_Customer__c,CreatedDate,Address_Line__c,IPQProposal__c,Location__c,City__c,State__c,Zip_Code__c,End_Customer_Name__c,Site_Quote_Expiration_Date__c FROM CustomerSite__c where Id IN: allSiteIdSet';  
                lstCustomerSite = Database.query(customerSitesList);
            }

            for(CustomerSite__c custSite : lstCustomerSite){
             String retreiveTokenBulkErrorMsg = SpecialCharacterConstant.CONCAT;
                if(custSite.IPQProposal__r.Apttus_Proposal__Account__c == quoteObj.Apttus_Proposal__Account__c){
                    String trimmedSiteId = String.valueOf(custSite.Id).subString(0,15);
                    system.debug('@@@trimmedSiteId: '+trimmedSiteId); 
                    Boolean sitePresentInMap = allSiteIdSet.remove(trimmedSiteId);  
                    retreiveTokenBulkErrorMsg = 'Success';
                    if(custSite.IPQProposal__r.Product__r.Name != quoteObj.Product__r.Name){
                        retreiveTokenBulkErrorMsg = 'Token is invalid for product type';
                    }                
                    else if(custSite.IPQProposal__r.Apttus_Proposal__Payment_Term__c != quoteObj.Apttus_Proposal__Payment_Term__c){
                        retreiveTokenBulkErrorMsg = 'Token is invalid for selected term';
                    }
                    else if(custSite.Site_Quote_Expiration_Date__c < currentDate){
                        retreiveTokenBulkErrorMsg = 'Token is expired';
                    }
                    else if((custSite.End_Customer_Name__c != quoteObj.End_Customer_Name__c) && custSite.End_Customer_Name__c != 'Rest_End_Customer'){
                        retreiveTokenBulkErrorMsg = 'Token ID is already associated with'+' '+custSite.End_Customer_Name__c;
                    } 
                    else if(attCustSiteJuncListObj != null && attCustSiteJuncListObj.size() > 0){
                        for(AT_T_Customer_Site_Quote__c siteJunc : attCustSiteJuncListObj){
                            if(siteJunc.AT_T_Customer_Site__c == custSite.id){
                                retreiveTokenBulkErrorMsg = 'Site is already added to quote';
                            }
                        }
                    }
                    system.debug('@@@retreiveTokenBulkErrorMsg: '+retreiveTokenBulkErrorMsg);
                    system.debug('@@@tokenIdSiteNameMap: '+tokenIdSiteNameMap);
                    if(retreiveTokenBulkErrorMsg.equals('Success') && tokenIdSiteNameMap.containsKey(trimmedSiteId)){
                        tokenSuccessMap.put(trimmedSiteId,tokenIdSiteNameMap.get(trimmedSiteId));
                        system.debug('tokenSuccessMap===='+tokenSuccessMap);   
                    }else{              
                        tokenErrorMap.put(trimmedSiteId,retreiveTokenBulkErrorMsg);
                        system.debug('tokenErrorMap===='+tokenErrorMap);
                    }                  
                } 
            }
            
            for(String str : allSiteIdSet){
                tokenErrorMap.put(str,'Token not found');
            }
            if(tokenSuccessMap.size()>0){
                Boolean updateFlag = false;
                system.debug('@@@@@successmappp==='+tokenSuccessMap.size());
                system.debug('@@@@@max tokens==='+Max_tokens_allowed);
                if(tokenSuccessMap.size()>Max_tokens_allowed){
                    quoteObj.Apttus_Proposal__Approval_Stage__c = 'Bulk Service Availability Requested';
                    quoteObj.vasa_modeD_request__c= true;
                    updateFlag = true;                  
                    retrieveTokenOffline = true;
                    system.debug('@@@@retrieveTokenOffline===='+retrieveTokenOffline);
                }
                if(quoteObj.Bulk_Add_Token_Batch_Completed__c == true){
                    quoteObj.Bulk_Add_Token_Batch_Completed__c = false;
                    updateFlag = true;
                }
                if(updateFlag){
                    system.debug('@@@@quoteObj: '+quoteObj);
                    update quoteObj;
                }
                system.debug('@@@@tokenSuccessMap.size(): '+tokenSuccessMap.size());
                AddSitetoTokenBatch batch = new AddSitetoTokenBatch(quoteObj,tokenSuccessMap);
                Id batchProcessId = database.executeBatch(batch,1);               
            }
            else{           
                    quoteObj.Bulk_Add_Token_Batch_Completed__c = true;
                    update quoteObj;
            }    
            
        }catch(Exception e){     
            system.debug('@@@Exception caught in retrieveBulkSiteToken method : '+e+'at Line Number: '+e.getLineNumber());         
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*******************************************************************
    * Method name : redirectToOfflinePage
    * Description : Logic to redirect to offline page
    * Return Type : PageReference.
    * Parameters  : None.
    *******************************************************************/ 
    public PageReference redirectToOfflinePage(){
        system.debug('@@@inside pagefreffff');
        PageReference pageRef_bulk = page.BuyFlow_VASABulk;
        pageRef_bulk.getParameters().put('quoteId', quote.id);
        pageRef_bulk.getParameters().put('vmode','D');
        return pageRef_bulk;
    }
    
    /*******************************************************************
    * Method name : addTokenSiteToQuote
    * Description : Logic behind BuyflowConstant.ADD button on page to add token sites to quote
    * Return Type : None.
    * Parameters  : None.
    *******************************************************************/  
    public void addTokenSiteToQuote() {
        try{
            if(quoteId == null) {
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            if(retreiveCustomerSite != null){
                upsert retreiveCustomerSite; 
            }
            if(quoteId != null && !String.isBlank(tokenId)){
                ApexPages.currentPage().getParameters().put('selectedCustomerIds',tokenId);
                doSitesSelection();
                calculateSiteToken();
                retreiveCustomerSite = new CustomerSite__c();
                tokenId = SpecialCharacterConstant.CONCAT;
                tokenaddress = SpecialCharacterConstant.CONCAT;
                tokenlocation = SpecialCharacterConstant.CONCAT;
                tokencity = SpecialCharacterConstant.CONCAT;
                tokenstate = SpecialCharacterConstant.CONCAT;
                tokenzip = SpecialCharacterConstant.CONCAT; 
                tokenquoteid = SpecialCharacterConstant.CONCAT;
                tokenPortSpeed = SpecialCharacterConstant.CONCAT;
                tokenAccessSpeed = SpecialCharacterConstant.CONCAT;
                userInputToken = SpecialCharacterConstant.CONCAT;
                showRelatedSites = false;
            }
            system.debug('retreiveCustomerSite:::'+retreiveCustomerSite);
            system.debug('token ID:::'+tokenId);
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
        }
    }
   
    public void disableDiscardOnRemoveSite(){
        Apttus_Proposal__Proposal__c quoteToUpdate = new Apttus_Proposal__Proposal__c(); 
        quoteToUpdate.Id = quoteId;
        quoteToUpdate.SiteRemovalCheck__c = true;
        update quoteToUpdate ;
        system.debug('---inside discard disable---');
        checkDiscard = false;
    }
    
    /* 
    Name: calculateSiteToken
    Description: creates cart,line item and computes the price by applying eligible promotions
    */ 
    public void calculateSiteToken(){ 
        try{
            String cartId = '';
            if(quoteId == null){
                quoteId = apexpages.currentpage().getparameters().get('quoteid');
            }
            ApttusServiceUtilityHelper helper = new ApttusServiceUtilityHelper(); 
            List<Apttus_Config2__LineItem__c> lineItemList = new List<Apttus_Config2__LineItem__c>();
            proposalObject= [select Id, Product_New_Name__c, Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Payment_Term__c,Product__r.ProductCode, Product__c,Rate_Card_Effective_Date__c,Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c,MACD_Change_Type__c,DealHash__c,Term__c,Apttus_Proposal__Account__r.Master_Agent__c,Apttus_Proposal__Account__r.Current_Tier__c,Name,subAccountNumber__c,Apttus_QPConfig__PriceListId__r.Id, Opportunity_Owner_Email__c, Docusign_Envelope__c, Denial_Reason__c, Contract_Read__c, End_Customer__c, Contract_Signed__c, End_Customer__r.Name,End_Customer__r.Mailing_Street_Address__c,End_Customer__r.City__c, Product__r.name, End_Customer__r.Zip__c,End_Customer__r.State__c,Product_Name__c, Apttus_Proposal__Opportunity__c,Apttus_Proposal__Approval_Stage__c,Is_Offline_Config_Completed__c,Bulk_Sevice_Availability_Indicator__c,isRateRefreshBatchProcessing__c,Buyflow_Step__c from Apttus_Proposal__Proposal__c where id = :quoteId];
            
            List<Apttus_Proposal__Proposal__c> currentQuote = new List<Apttus_Proposal__Proposal__c>();
            currentQuote.add(proposalObject);
            if(currentQuote!=null && currentQuote.size()>0){
                selectedProductId=currentQuote[0].Product__c;
                selectedProductCode=currentQuote[0].Product__r.ProductCode;
                ProposalName=currentQuote[0].Apttus_Proposal__Proposal_Name__c;
            }
    
            list<Apttus_Config2__ProductConfiguration__c> prodConfig = new list<Apttus_Config2__ProductConfiguration__c>();
            prodConfig = [SELECT Id, Name,Apttus_Config2__Status__c, Apttus_QPConfig__Proposald__c,CreatedDate FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c = :quoteId order by CreatedDate desc LIMIT 1];
            if(!prodConfig.isEmpty()){
                cartId = prodConfig[0].Id;
            }
            else{
                cartId = helper.createCart(currentQuote[0].id);
            }
            system.debug('@@@Cart Id: '+cartId);
            system.debug('@@@Site Token Id: '+tokenId );
            system.debug('@@@Token Quote Id: '+tokenquoteid );
            system.debug('@@@Quote Id: '+quoteId );
    
            if(String.isNotBlank(cartId)){   
                Apttus_CPQApi.CPQ.AddMultiProductRequestDO request = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO();            
                Apttus_CPQApi.CPQ.SelectedProductDO prod = new Apttus_CPQApi.CPQ.SelectedProductDO();
                prod.ProductId = selectedProductId;
                prod.Quantity = prod.SellingTerm = 1;
                prod.StartDate = system.today();
                prod.EndDate = system.today()+2;
                request.CartId = cartId;
                request.SelectedProducts.add(prod);
                Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(request);
                list<Decimal> lineNumberList = response.LineNumbers;
                lineItemList=[Select Id,isPricingApplied__c,Apttus_Config2__PricingStatus__c,AT_T_Customer_Site__c,AT_T_Customer_Site__r.Id,Apttus_Config2__LineNumber__c,Apttus_Config2__ChargeType__c,Apttus_Config2__PrimaryLineNumber__c from Apttus_Config2__LineItem__c where Apttus_Config2__PrimaryLineNumber__c=:response.LineNumbers and Apttus_Config2__ConfigurationId__c=:cartId];
                List<Apttus_Config2__LineItem__c> liteItemUpdated;
                for(Apttus_Config2__LineItem__c lineitem :lineItemList){
                    lineitem.AT_T_Customer_Site__c= tokenId;
                    lineitem.Apttus_Config2__LineNumber__c=lineItemList[0].Apttus_Config2__PrimaryLineNumber__c;
                    lineitem.isPricingApplied__c = true;
                }
                update lineItemList;           
            }
            
            //Updating AV record
            list<Apttus_Config2__ProductAttributeValue__c> avListOld = new list<Apttus_Config2__ProductAttributeValue__c>();
            avListOld = [SELECT Id,Name,Proposal__c,Apttus_Config2__LineItemId__r.AT_T_Customer_Site__r.Service_Availability_Response__c,ProductName__c,IP_Flex_Error__c,IGLOO_Port_Speed_Substituted__c, IGLOO_Access_Speed_Substituted__c, IGLOO_Interface_Type_Substituted__c, IGLOO_Speed_Unavailable__c, IGLOO_Old_Port_Speed__c, IGLOO_Old_Access_Speed__c, IGLOO_Old_Interface_Type__c, Alternate_Access_IGLOO_Interface_Code__c, Alternate_Access_IGLOO_Access_Price__c, Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c, Igloo_Call_Processing_Complete__c, AT_T_Customer_Site__c, Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Payment_Term__c, IGLOO_Retrial_Failure_Count__c, IGLOO_Call_Failure__c, Quote_Total_Failure_Count__c, AT_T_IP_Flexible_Reach__c,Managed_Router__c,CoS__c,VLANs_Logical_Channels__c,Hi_Cap_Flex__c,Port_Type_AVPN__c,Port_Type_MIS__c,Port_Speed_MIS__c,Port_Speed_AVPN__c,UBB_Speed_AVPN__c,UBB_Speed_MIS__c,Access_Type__c,Access_Type_AVPN__c,Access_Speed_MIS__c,Access_Speed_AVPN__c,Interface_Type_AVPN__c,Interface_Type__c,Additional_DNS__c,Install_Option_MIS__c,Install_Option_AVPN__c,VASA_Region__c,Apttus_Config2__Vendor__c,Mileage__c,IP_Flexible_Reach_Plan__c,Ported_Phone_Numbers__c,New_Local_Phone_Numbers__c,New_Virtual_Phone_Numbers__c,Concurrent_Calls__c,enhanced_features__c,Directory_Listing_Phone_Number__c,Setup_Fee__c,Alternate_Access_IGLOO_Interface_Type__c,Igloo_Access_Price__c,Iglow_Call_Date__c,Wireline_Promotion_Id__c from Apttus_Config2__ProductAttributeValue__c where Proposal__c =: tokenquoteid LIMIT 1];
            System.debug('@@@Old AV List: '+avListOld);
            
            map<String,Apttus_Config2__LineItem__c> oldPriceMap = new map<String,Apttus_Config2__LineItem__c>();
            if(avListOld.size()>0){
                list<Apttus_Config2__LineItem__c> lineItemListOld = new list<Apttus_Config2__LineItem__c>();            
                lineItemListOld = [select id,Original_Hidden_Price__c,Original_Net_Price__c,Apttus_Config2__NetPrice__c,Alternate_Access_IGLOO_Access_Price__c,Alternate_Access_IGLOO_Discount__c,Apttus_Config2__ChargeType__c,Wireline_Promotion_Discount_Percentage__c,WP_Hidden_Discount_Percentage__c from Apttus_Config2__LineItem__c where Apttus_Config2__AttributeValueId__c =: avListOld[0].Id and AT_T_Customer_Site__c =: tokenId];
                for(Apttus_Config2__LineItem__c item : lineItemListOld){
                    oldPriceMap.put(item.Apttus_Config2__ChargeType__c, item);
                }
            }
            system.debug('@@@oldPriceMap: '+oldPriceMap);
            
            list<Apttus_Config2__ProductAttributeValue__c> avList = new list<Apttus_Config2__ProductAttributeValue__c>();
            avList = [SELECT Id,Name,Proposal__c,Apttus_Config2__LineItemId__r.AT_T_Customer_Site__r.Service_Availability_Response__c,ProductName__c,IP_Flex_Error__c,IGLOO_Port_Speed_Substituted__c, IGLOO_Access_Speed_Substituted__c, IGLOO_Interface_Type_Substituted__c, IGLOO_Speed_Unavailable__c, IGLOO_Old_Port_Speed__c, IGLOO_Old_Access_Speed__c, IGLOO_Old_Interface_Type__c, Alternate_Access_IGLOO_Interface_Code__c, Alternate_Access_IGLOO_Access_Price__c, Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c, Igloo_Call_Processing_Complete__c, AT_T_Customer_Site__c, Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Payment_Term__c, IGLOO_Retrial_Failure_Count__c, IGLOO_Call_Failure__c, Quote_Total_Failure_Count__c, AT_T_IP_Flexible_Reach__c,Managed_Router__c,CoS__c,VLANs_Logical_Channels__c,Hi_Cap_Flex__c,Port_Type_AVPN__c,Port_Type_MIS__c,Port_Speed_MIS__c,Port_Speed_AVPN__c,UBB_Speed_AVPN__c,UBB_Speed_MIS__c,Access_Type__c,Access_Type_AVPN__c,Access_Speed_MIS__c,Access_Speed_AVPN__c,Interface_Type_AVPN__c,Interface_Type__c,Additional_DNS__c,Install_Option_MIS__c,Install_Option_AVPN__c,VASA_Region__c,Apttus_Config2__Vendor__c,Mileage__c,IP_Flexible_Reach_Plan__c,Ported_Phone_Numbers__c,New_Local_Phone_Numbers__c,New_Virtual_Phone_Numbers__c,Concurrent_Calls__c,enhanced_features__c,Directory_Listing_Phone_Number__c,Setup_Fee__c,Alternate_Access_IGLOO_Interface_Type__c,Igloo_Access_Price__c,Iglow_Call_Date__c,Wireline_Promotion_Id__c from Apttus_Config2__ProductAttributeValue__c where Proposal__c =: ProposalName AND Apttus_Config2__LineItemId__c =: lineItemList[0].id LIMIT 1];
            System.debug('@@@NEWList--->'+avList);
             System.debug('@@@avListOld[0]--->'+avListOld[0]);
             System.debug('@@@avList[0]--->'+avList[0]);
            
            if(!avListOld.isEmpty()){
                if(avList.size()>0){
                    avList[0].Apttus_Config2__Vendor__c = avListOld[0].Apttus_Config2__Vendor__c ;
                    System.debug('@@@avListOld[0]--->'+avListOld[0].Apttus_Config2__Vendor__c);
             System.debug('@@@avList[0]--->'+avList[0].Apttus_Config2__Vendor__c);
                    avList[0].Mileage__c = avListOld[0].Mileage__c;
                    avList[0].VASA_Region__c = avListOld[0].VASA_Region__c;
                    avList[0].Alternate_Access_IGLOO_Interface_Code__c = avListOld[0].Alternate_Access_IGLOO_Interface_Code__c;
                    avList[0].Alternate_Access_IGLOO_Access_Price__c = avListOld[0].Alternate_Access_IGLOO_Access_Price__c;
                    avList[0].Igloo_Access_Price__c = avListOld[0].Igloo_Access_Price__c;
                    avList[0].Iglow_Call_Date__c = avListOld[0].Iglow_Call_Date__c;
                    avList[0].Igloo_Call_Processing_Complete__c = avListOld[0].Igloo_Call_Processing_Complete__c;
                    avList[0].Wireline_Promotion_Id__c = avListOld[0].Wireline_Promotion_Id__c;
                    avList[0].Managed_Router__c = avListOld[0].Managed_Router__c;
                    avList[0].IP_Flexible_Reach_Plan__c = avListOld[0].IP_Flexible_Reach_Plan__c;
                    avList[0].Hi_Cap_Flex__c = avListOld[0].Hi_Cap_Flex__c;
                    avList[0].Ported_Phone_Numbers__c = avListOld[0].Ported_Phone_Numbers__c;
                    avList[0].New_Local_Phone_Numbers__c = avListOld[0].New_Local_Phone_Numbers__c;
                    avList[0].New_Virtual_Phone_Numbers__c = avListOld[0].New_Virtual_Phone_Numbers__c;
                    avList[0].Concurrent_Calls__c  = avListOld[0].Concurrent_Calls__c;
                    avList[0].CoS__c = avListOld[0].CoS__c;
                    avList[0].enhanced_features__c = avListOld[0].enhanced_features__c;
                    avList[0].Additional_DNS__c = avListOld[0].Additional_DNS__c;
                    avList[0].AT_T_IP_Flexible_Reach__c = avListOld[0].AT_T_IP_Flexible_Reach__c;
                    
                    if(selectedProductCode == 'AVPN'){            
                        avList[0].Access_Speed_AVPN__c = avListOld[0].Access_Speed_AVPN__c;
                        avList[0].Access_Type_AVPN__c = avListOld[0].Access_Type_AVPN__c;
                        avList[0].Interface_Type_AVPN__c = avListOld[0].Interface_Type_AVPN__c;                   
                        avList[0].Port_Speed_AVPN__c = avListOld[0].Port_Speed_AVPN__c;
                        avList[0].Port_Type_AVPN__c = avListOld[0].Port_Type_AVPN__c;
                        avList[0].Install_Option_AVPN__c = avListOld[0].Install_Option_AVPN__c;
                        avList[0].UBB_Speed_AVPN__c = avListOld[0].UBB_Speed_AVPN__c;
                        avList[0].VLANs_Logical_Channels__c = avListOld[0].VLANs_Logical_Channels__c;
                    }
                    else{
                        avList[0].Access_Speed_MIS__c = avListOld[0].Access_Speed_MIS__c;
                        avList[0].Access_Type__c = avListOld[0].Access_Type__c;
                        avList[0].Interface_Type__c = avListOld[0].Interface_Type__c;                    
                        avList[0].Port_Speed_MIS__c = avListOld[0].Port_Speed_MIS__c;
                        avList[0].Port_Type_MIS__c = avListOld[0].Port_Type_MIS__c;
                        avList[0].Install_Option_MIS__c = avListOld[0].Install_Option_MIS__c;  
                        avList[0].UBB_Speed_MIS__c = avListOld[0].UBB_Speed_MIS__c;                 
                    }
                }
            }
            
            if(avList.size()>0){
                Apttus_Config2__ProductAttributeValue__c av = new Apttus_Config2__ProductAttributeValue__c();
                av = avList[0];            
                if(selectedProductId == 'AVPN'){
                    helper.updateAVRecordsOnApply(av,av.Apttus_Config2__LineItemId__r.AT_T_Customer_Site__r.Service_Availability_Response__c,true,false);   
                }else{
                    helper.updateAVRecordsOnApply(av,av.Apttus_Config2__LineItemId__r.AT_T_Customer_Site__r.Service_Availability_Response__c,false,true);   
                }
            }
            update avList;
            
            helper.computePrice(cartId,Integer.valueOf(lineItemList[0].Apttus_Config2__LineNumber__c));
            
            list<Apttus_Config2__LineItem__c>  newlineItems = [SELECT Id,Product_Code__c, Project_Id__c,Apttus_Config2__BaseExtendedCost__c,AccessSpeed__c,Lec_Name__c,Access_Type__c,  Apttus_Config2__PriceListId__r.Name , VASARegion__c,Mileage__c,IsBatchUpdate__c,UBBOveragePrice__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c,Apttus_Config2__PriceListItemId__c,Apttus_Config2__ExtendedPrice__c,Apttus_Config2__PriceListId__c,AT_T_Customer_Site__r.Id ,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.id, Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__ListPrice__c,AdditionalDnsType__c,Port_Speed__c, MBC_Speed__c,Apttus_Config2__BasePrice__c,Apttus_Config2__AttributeValueId__r.VLANs_Logical_Channels__c, isPricingApplied__c, Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c,Apttus_Config2__AttributeValueId__r.Additional_DNS__c, Apttus_Config2__AttributeValueId__r.CoS__c,Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Rate_Card_Effective_Date__c,Apttus_Config2__PriceListId__r.Apttus_Config2__EffectiveDate__c,Apttus_Config2__AttributeValueId__r.VASA_Region__c,Apttus_Config2__AttributeValueId__r.Access_Type_AVPN__c,Apttus_Config2__AttributeValueId__r.Access_Type__c,Apttus_Config2__AttributeValueId__r.Igloo_Access_Price__c,Alternate_Access_IGLOO_Access_Price__c,Alternate_Access_IGLOO_Discount__c,Wireline_Promotion_Discount_Percentage__c,WP_Hidden_Discount_Percentage__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c= :cartId and AT_T_Customer_Site__c =:tokenId];      
                   
            for(Apttus_Config2__LineItem__c lineItem : newlineItems){
                if(lineItem.Apttus_Config2__ChargeType__c == 'Port Speed Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('Port Speed Fee')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('Port Speed Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('Port Speed Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('Port Speed Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('Port Speed Fee').Wireline_Promotion_Discount_Percentage__c;
                }            
                else if(lineItem.Apttus_Config2__ChargeType__c == 'Access Speed Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('Access Speed Fee')){
                    lineItem.Alternate_Access_IGLOO_Access_Price__c = oldPriceMap.get('Access Speed Fee').Alternate_Access_IGLOO_Access_Price__c;
                    lineItem.Alternate_Access_IGLOO_Discount__c = oldPriceMap.get('Access Speed Fee').Alternate_Access_IGLOO_Discount__c;
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('Access Speed Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('Access Speed Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('Access Speed Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('Access Speed Fee').Wireline_Promotion_Discount_Percentage__c;
                    lineItem.WP_Hidden_Discount_Percentage__c = oldPriceMap.get('Access Speed Fee').WP_Hidden_Discount_Percentage__c;
                }
                else if(lineItem.Apttus_Config2__ChargeType__c == 'Access Speed Mileage Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('Access Speed Mileage Fee')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('Access Speed Mileage Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('Access Speed Mileage Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('Access Speed Mileage Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('Access Speed Mileage Fee').Wireline_Promotion_Discount_Percentage__c;
                }
                else if(lineItem.Apttus_Config2__ChargeType__c == 'One Time Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('One Time Fee')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('One Time Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('One Time Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('One Time Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('One Time Fee').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'VLAN(s)/Logical Channel' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('VLAN(s)/Logical Channel')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('VLAN(s)/Logical Channel').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('VLAN(s)/Logical Channel').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('VLAN(s)/Logical Channel').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('VLAN(s)/Logical Channel').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'Access Speed' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('Access Speed')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('Access Speed').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('Access Speed').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('Access Speed').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('Access Speed').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'CoS Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('CoS Fee')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('CoS Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('CoS Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('CoS Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('CoS Fee').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'Additional DNS Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('Additional DNS Fee')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('Additional DNS Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('Additional DNS Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('Additional DNS Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('Additional DNS Fee').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'VTN Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('VTN Fee')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('VTN Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('VTN Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('VTN Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('VTN Fee').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'VoIP' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('VoIP')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('VoIP').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('VoIP').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('VoIP').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('VoIP').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'Enhanced Features' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('Enhanced Features')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('Enhanced Features').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('Enhanced Features').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('Enhanced Features').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('Enhanced Features').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'Setup Fee' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('Setup Fee')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('Setup Fee').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('Setup Fee').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('Setup Fee').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('Setup Fee').Wireline_Promotion_Discount_Percentage__c;
                }else if(lineItem.Apttus_Config2__ChargeType__c == 'IP Flex Reach Plan' && oldPriceMap != null && oldPriceMap.size()> 0 && oldPriceMap.containsKey('IP Flex Reach Plan')){
                    lineItem.Original_Hidden_Price__c = oldPriceMap.get('IP Flex Reach Plan').Original_Hidden_Price__c;
                    lineItem.Original_Net_Price__c = oldPriceMap.get('IP Flex Reach Plan').Original_Net_Price__c;
                    lineItem.Apttus_Config2__NetPrice__c = oldPriceMap.get('IP Flex Reach Plan').Apttus_Config2__NetPrice__c;
                    lineItem.Wireline_Promotion_Discount_Percentage__c = oldPriceMap.get('IP Flex Reach Plan').Wireline_Promotion_Discount_Percentage__c;
                }                               
                lineItem.Apttus_Config2__BaseExtendedCost__c = lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__AdjustedPrice__c = lineItem.Apttus_Config2__BaseExtendedPrice__c = lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__ListPrice__c = lineItem.Apttus_Config2__NetPrice__c;
            }
            update newLineItems;
            
            //Copy sitequotejunc
            List<AT_T_Customer_Site_Quote__c> siteQuoteJuncOld = new List<AT_T_Customer_Site_Quote__c>();
            siteQuoteJuncOld = [SELECT Id,AT_T_Customer_Site__c,Igloo_Review_Required__c,Wireline_Promotion_Id_Before__c,Wireline_Promotion_Id_After__c,Wireline_Promotion_Id_Applied__c,Alternate_Access_IGLOO_Response__c,Alternate_Access_IGLOO_Request_Time__c,Iglow_Response_Received_Date__c,Alternate_Access_IGLOO_Response_Status__c,Alternate_Access_IGLOO_Failure_Code__c,Alternate_Access_IGLOO_Access_Speed__c,Alternate_Access_IGLOO_Access_Price__c,Alternate_Access_IGLOO_Interface_Code__c,Alternate_Access_IGLOO_Interface_Type__c,Alternate_Access_IGLOO_Process_Completed__c,CSI_Conversation_Id__c,IGLOO_Supplier_Name__c,Wireline_Promotion_Applied__c,Wireline_Promotion_Id_Sorted__c,Wireline_Promotion_Name_Applied__c,Wireline_Promotion_Number_Applied__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__r.Name =: tokenquoteid AND AT_T_Customer_Site__c=: tokenId];
            System.debug('siteQuoteJuncOld--->'+siteQuoteJuncOld);
            List<AT_T_Customer_Site_Quote__c> siteQuoteJuncNew = new List<AT_T_Customer_Site_Quote__c>();
            siteQuoteJuncNew = [SELECT Id,AT_T_Customer_Site__c,Igloo_Review_Required__c,Wireline_Promotion_Id_Before__c,Wireline_Promotion_Id_After__c,Wireline_Promotion_Id_Applied__c,Alternate_Access_IGLOO_Response__c,Alternate_Access_IGLOO_Request_Time__c,Iglow_Response_Received_Date__c,Alternate_Access_IGLOO_Response_Status__c,Alternate_Access_IGLOO_Failure_Code__c,Alternate_Access_IGLOO_Access_Speed__c,Alternate_Access_IGLOO_Access_Price__c,Alternate_Access_IGLOO_Interface_Code__c,Alternate_Access_IGLOO_Interface_Type__c,Alternate_Access_IGLOO_Process_Completed__c,CSI_Conversation_Id__c,IGLOO_Supplier_Name__c,Wireline_Promotion_Applied__c,Wireline_Promotion_Id_Sorted__c,Wireline_Promotion_Name_Applied__c,Wireline_Promotion_Number_Applied__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c=: quoteId AND AT_T_Customer_Site__c=: tokenId];
            System.debug('siteQuoteJuncNew--->'+siteQuoteJuncNew);
            if(!siteQuoteJuncOld.isEmpty() && siteQuoteJuncOld.size()>0){
                if(!siteQuoteJuncNew.isEmpty()){
                    siteQuoteJuncNew[0].Alternate_Access_IGLOO_Response__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Response__c;
                    siteQuoteJuncNew[0].Alternate_Access_IGLOO_Request_Time__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Request_Time__c;
                    siteQuoteJuncNew[0].Iglow_Response_Received_Date__c = siteQuoteJuncOld[0].Iglow_Response_Received_Date__c;
                    siteQuoteJuncNew[0].Alternate_Access_IGLOO_Response_Status__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Response_Status__c;
                    siteQuoteJuncNew[0].Alternate_Access_IGLOO_Failure_Code__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Failure_Code__c;
                    siteQuoteJuncNew[0].Alternate_Access_IGLOO_Access_Speed__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Access_Speed__c;
                    siteQuoteJuncNew[0].Alternate_Access_IGLOO_Access_Price__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Access_Price__c;
                    siteQuoteJuncNew[0].Alternate_Access_IGLOO_Interface_Code__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Interface_Code__c;
                    siteQuoteJuncNew[0].Alternate_Access_IGLOO_Process_Completed__c = siteQuoteJuncOld[0].Alternate_Access_IGLOO_Process_Completed__c;
                    siteQuoteJuncNew[0].CSI_Conversation_Id__c = siteQuoteJuncOld[0].CSI_Conversation_Id__c;
                    siteQuoteJuncNew[0].IGLOO_Supplier_Name__c = siteQuoteJuncOld[0].IGLOO_Supplier_Name__c;
                    siteQuoteJuncNew[0].Wireline_Promotion_Applied__c = siteQuoteJuncOld[0].Wireline_Promotion_Applied__c;
                    siteQuoteJuncNew[0].Wireline_Promotion_Id_Before__c = siteQuoteJuncOld[0].Wireline_Promotion_Id_Before__c;
                    siteQuoteJuncNew[0].Wireline_Promotion_Id_After__c = siteQuoteJuncOld[0].Wireline_Promotion_Id_After__c;
                    siteQuoteJuncNew[0].Wireline_Promotion_Id_Sorted__c = siteQuoteJuncOld[0].Wireline_Promotion_Id_Sorted__c;
                    siteQuoteJuncNew[0].Wireline_Promotion_Id_Applied__c = siteQuoteJuncOld[0].Wireline_Promotion_Id_Applied__c;
                    siteQuoteJuncNew[0].Wireline_Promotion_Name_Applied__c = siteQuoteJuncOld[0].Wireline_Promotion_Name_Applied__c;
                    siteQuoteJuncNew[0].Wireline_Promotion_Number_Applied__c = siteQuoteJuncOld[0].Wireline_Promotion_Number_Applied__c;
                }
            }
            update siteQuoteJuncNew;
            System.debug('Junc Updated Successfully--->'+siteQuoteJuncNew);
        }
        catch(Exception ex){
            system.debug('@@@Exception in calculateSiteToken method in SiteAddressInformationController: '+ex+' at line number: '+ex.getLineNumber());
        }
    }
    
    /*Render Multiple Token Upload*/
    public void renderMultiTokenUpload(){
        try{  
            retreiveTokenErrorMsg = SpecialCharacterConstant.CONCAT;
            showRelatedSites = false;
            tokenBulkBatchPolling = false;
            retrieveTokenOffline = false;
            retrieveBulkSuccessFlag = false;
            retrieveBulkLimitExceeds = false;
            retrieveBulkErrorFlag = false;
            userInputToken = SpecialCharacterConstant.CONCAT;
            tokenErrorMap = new Map<String,String>(); 
            tokenIdSiteNameMap = new Map<String,String>();
            String showBulk = apexpages.currentpage().getparameters().get('showBulk');
            system.debug('@@@@@showBulk: '+showBulk);
            if(String.isNotBlank(showBulk) && showBulk == 'true'){
                retrieveBulkTokenFlag = true;
            }
            else{
                retrieveBulkTokenFlag = false;
                tokenErrorMap = new Map<String,String>(); 
            }
            system.debug('@@@@@retrieveBulkTokenFlag: '+retrieveBulkTokenFlag);
        }catch(Exception e){
            system.debug('@@@Exception in uploadBulkToken method in SiteAddressInformationController: '+e+' at line number: '+e.getLineNumber());
        }
    }
    
    /*Method to check if the Bulk Token Batch is completed*/
    public void checkTokenBatchStatus(){
        try{
            list<Apttus_Proposal__Proposal__c> proposal= new list<Apttus_Proposal__Proposal__c>();
            proposal = [SELECT Id,Bulk_Add_Token_Batch_Completed__c FROM Apttus_Proposal__Proposal__c WHERE Id =: quoteId LIMIT 1];
            if(proposal!=null && proposal.size()>0){
                tokenBulkBatchPolling = proposal[0].Bulk_Add_Token_Batch_Completed__c;
                system.debug('tokenBulkBatchPolling ====='+tokenBulkBatchPolling);
                 if(tokenBulkBatchPolling == true){
                    if(tokenErrorMap != null && tokenErrorMap.size()>0){
                        retrieveBulkErrorFlag = true;
                        retrieveBulkSuccessFlag = false;
                    }
                    else{
                        retrieveBulkErrorFlag = false;
                        retrieveBulkSuccessFlag = true;
                    }
                 }
                
            }
            system.debug('@@@Token Bulk Status: '+tokenBulkBatchPolling);
        }
        catch(Exception e){
            System.debug('@@@Exception in checkTokenBatchStatus method in SiteAddressInformationController: '+e+ 'At Line Number: '+e.getLineNumber()+'Trace is: '+e.getStackTraceString());
        }
    }
    
    public void RefreshBatchpolling(){
      system.debug('@@@@dummyMethod');
    
    }
}