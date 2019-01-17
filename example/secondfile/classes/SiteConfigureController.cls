/************************************************************************************** 
Apex Class Name     : SiteConfigureController   
Version             : 1.0 
Created Date        : 8/May/2015
Function            : This class handles the configure sites functionality.
Modification Log    :
* Developer                   Email for Support                  
* ----------------------------------------------------------------------------                 
* Manish Tiwari            manish.b.tiwari@accenture.com
* Smarjit Debata           smarjit.debata@accenture.com        
* Nidhin Varghese          nidhin.a.varghese@accenture.com
* Karthik Govindaraju      karthik.govindaraju@accenture.com  
*************************************************************************************/
public with sharing class SiteConfigureController{
    public String PromotionsForSite {get;set;}
    public static final String TRUNK_CALL_ROUTING = 'Trunk Call Routing';
    public static final String BOTHLINETRUNK = 'Both(Line Features & Trunk Call Routing)';
    public static final String LINE_FEATURES = 'Line Features';
    public String selectedSitePhone{get;set;}
    public map<string,string> softDeletedSitesmap = new Map<string,string>();
    public Boolean isHiCapFlex {get;set;}
    public Boolean allEligibleSelected {get;set;}
    public Boolean isIPFlex {get;set;}      
    public String siteid{get;set;}
    public String selectOptGrp {get;set;}
    public String selectOptGrpVal {get;set;}
    public Double grandTot {get;set;}
    public Double siteTotal {get;set;}
    public String accountId {get;set;}
    public Map<String,ASE_Wholesale_Contract_Number__c> cnumObjectMap{get;set;}
    public String quoteId{get;set;}
    public string junctToSoftDelete{get;set;}
    Public Map<String,string> mapJunction;
    public set<String> sugProdId{get;set;}
    public SiteVasaResValidator siteVasaResValidatorIns;
    public Map<String,Boolean> siteIdEthernetAvailMap {get;set;}
    public Boolean ethernetVal {get;set;}
    public transient List<QuoteProducts.cCustomerSite> eligibleSitesLst ;
    public AT_T_Customer_Site_Quote__c custSiteQuoteIns {get;set;}
    public String cartId{get;set;}
    transient List<Decimal> lineNumbersLst;
    transient String priceListId;
    public  String mainproductId{get;set;}    
    public Map<Id,Integer> siteLinenumberMap;
    private List<Apttus_CPQApi.CPQ.ProductOptionGroupDO> productOptionList;
    private ApttusServiceUtilityHelper helper;
    private QuoteInfoHelper Quotehelper;
    public QuoteProducts.SelectPricingWrap sPricingWrap{get;set;}
    public Map<String,QuoteProducts.SelectPricingWrap> sitePricingMap {get;set;}
    public Boolean disableNext {get;set;}
    public Boolean disablePrevious {get;set;}
    public Boolean isAllSitesNotProcessed{get;set;}
    public Boolean TypeConnection {get;set;}
    public Apttus_Proposal__Proposal__c quoteObj{get;set;}
    public String selectedFilter{get;set;}
    public List<QuoteProducts.cCustomerSite> ListCustomerSite{get;set;}
    public List<Apttus_Config2__ProductAttributeValue__c> updateAVValuesIpflex{get;set;}
    public String selectedSiteId {get;set;}
    public Decimal totalPerSite {get;set;}
    public Double totalPerCart {get;set;}
    public List<Apttus_Config2__ProductAttributeGroupMember__c> listAttrProductJunction;
    public List<Apttus_Config2__ProductAttribute__c> listAttr {get;set;}
    public Apttus_Config2__ProductAttributeValue__c listAttrVal {get;set;}
    public String jsonServiceAvailability {get;set;}
    public Integer numberOfOptions {get;set;}
    public Boolean isPricingDataAvailable {get;set;}
    public sObject sObj {get;set;}
    public Apttus_Config2__ProductConfiguration__c configData {get;set;}
    public List<Apttus_Config2__LineItem__c> lineItems {get;set;}
    public List<wrapperDataS> dataWrap {get;set;}
    public String selectedProductId {get;set;}
    public Apttus_Proposal__Proposal__c proposalData {get;set;}
    public CustomerSite__c selectedSiteInfo {get;set;}
    public CustomerSite__c tierInfo {get;set;}
    public Boolean isAvpn {get;set;}
    public Boolean isMIS {get;set;}
    public Boolean isASE {get;set;}
    public Boolean isReviewMode {get;set;}
    Public String fieldIndices {get;set;}
    Public String fieldIndicesUBB {get;set;}
    public String portTypeIndex {get;set;}
    public String selectCheckBox {get;set;}
    public String selectDropdown {get;set;} 
    Public Decimal oneTimeFee {get;set;} 
    public Decimal sumOneTimeFee {get;set;}
    public Boolean isContinueEnabled {get;set;}
    public List<QuoteProducts.cCustomerSite> listCustomerSiteMaster {get;set;}
    public Apttus_Config2__ProductAttributeValue__c selctedsiteAVRecords = new Apttus_Config2__ProductAttributeValue__c();
    public set<Integer> lineItemNumbersToPrice = new set<Integer>();
    public map<Id, Integer> lineNumbersNeedsToBeDeleted = new map<Id, Integer>();
    public Integer portTypeIndexInt {get;set;}
    public Integer portSpeedIndexInt {get;set;}
    public Integer accessSpeedIndex {get;set;}
    public Integer vlanIndex {get;set;}
    Public boolean isSitereview {get;set;}
    Public Boolean isConfigSiteModeOn {get;set;}
    public String productName {get; set;}
    public Decimal overgePerMb {get; set;}
    public boolean isUBBinCart{get;set;}
    public Boolean isIPFlexInCart{get;set;}
    public String HicapIndex{get; set;}
    public Integer HicapIndexInt{get; set;}
    Public Decimal amount;
    public boolean siteselect{get;set;}
    public Integer TotalSitesCount{get;set;}
    public Integer noOfConfigedSites{get;set;}
    public  Integer countOfSites{get;set;}
    public static Integer noOfSoftDeletedSites;
    public Set<String> noOfConfigedSitesSet = new Set<String>();
    public Boolean isAccessDiscountEligible;
    public Boolean checkDiscard{get;set;}
    public boolean removePopupOnLoadFlag{get;set;}
   
    public List<CustomerSite__c> validSitesToConfigureList = new List<CustomerSite__c>();
    ITPAServiceAvailResponseBean ITPAresponse = new ITPAServiceAvailResponseBean();
    public Boolean ITPAServiceRespose {get;set;}
    public Boolean doITPAPolling {get; set;} 
    public boolean ITPAError{get;set;}  
    public Integer PortedPhoneNumbersInt {get;set;}
    public Integer NewLocalPhoneNumbersInt{get;set;}
    public Integer NewVirtualPhoneNumbersInt {get;set;}
    public Integer ConcurrentCallsInt {get;set;}
    public Integer EnhancedFeaturesInt {get;set;}
    public Integer IPFlexibleReachPlanInt {get;set;}
    public list<CustomerSite__c> currentSiteData = new list<CustomerSite__c>();
    public Integer PortedPhoneNumbersIntUbb {get;set;}
    public Integer NewLocalPhoneNumbersIntUbb {get;set;}
    public Integer NewVirtualPhoneNumbersIntUbb {get;set;}
    public Integer ConcurrentCallsIntUbb {get;set;}
    public Integer EnhancedFeaturesIntUbb {get;set;}
    public Integer IPFlexibleReachPlanIntUbb {get;set;}
    public Integer totalPhoneNumber{get;set;}
    public Integer portedPhoneNumber {get;set;}
    public Integer newLocalPhoneNumber {get;set;}
    public Integer newVirtualPhoneNumber {get;set;}
    public String IPFlexPlans{get;set;}
    public String NumberAvailabilityIndicator{get;set;}
    public String NumberPortabilityIndicator{get;set;}
    public String VirtualTNAvailabilityIndicator{get;set;}
    public boolean configureSitesFlag{get;set;}
    public boolean selectAllCheckBox{get;set;}
    public Boolean isIPFlexProdChecked {get;set;}
    Public Boolean isManagedrouterchecked{get;set;}
    
    List<String> lecNameLst ;
    Public static List<AddrValidServAvailResponseBean.AddressServiceAvailability>AddressServiceAvailabilityList; 
    Public String JSONResponse;
    Public String aseTier;
    Public String lataNumber;
    public List<Provider_Grouping__c> pgList;
    public List<String> lecscopeList;
    public String accessType;
    public transient Map<Id,CustomerSite__c> siteMap ;
    public String regExp = '&quot;';
    public Map<integer,Set<String>> interfaceTypeMap {get;set;}
    private Map<String,Map<integer,Set<String>>> siteInterfaceTypeMap;
    public Set<String> interfaceTypeList {get;set;}
    public Set<String> interfaceType5 {get;set;}
    public Set<String> interfaceType10 {get;set;}
    public Set<String> interfaceType20 {get;set;}
    public Set<String> interfaceType50 {get;set;}
    public Set<String> interfaceType100 {get;set;}
    public Set<String> oorSEConfiguredSite;
    
    //ASE variables
    public string CNUMDropdownValue {get;set;}
    public string serviceTypeRadioValue {get;set;}
    public string CoSRadioValue {get;set;}
    public string networkTypeRadioValue {get;set;}
    public string LATARadioValue {get;set;}
    public string configTypeRadioValue {get;set;}
    public string siteDesignationRadioValue {get;set;}
    public string portVLANBasedRadioValue {get;set;}
    public string macAddressesRadioValue {get;set;}
    public string fiberCode {get;set;}
    public list<String> speedsNotAvailableITPAList{get;set;}
    
    public list<selectOption> dropDownList{get;set;}
    public boolean showASEOverlay{get;set;}
    public boolean enableASEBasic{get;set;}
    public boolean enableASEBroadband{get;set;}
    public boolean isPromotion{get;set;}
    public boolean isMaster{get;set;}
    public boolean isPPCoS{get;set;}
    public Boolean isAFBR{get;set;}
    public boolean isEoCU{get;set;}
    public boolean isASEoLS{get;set;}
    public list<Apttus_Config2__PriceMatrixEntry__c> basicPMList;
    public list<Apttus_Config2__PriceMatrixEntry__c> broadbandPMList;
    public Decimal maxSpeedValueBasic;
    public Decimal maxSpeedValueBroadband;
    public list<String> basic100BaseList{get;set;}
    public list<String> basic100PromoList{get;set;}
    public list<String> basic1000BaseList{get;set;}
    public list<String> basic1000PromoList{get;set;}
    public list<String> basic10000BaseList{get;set;}
    public list<String> broadband1000List{get;set;}
    public String aseTierValue{get;set;}
    public String selectedTerm;
    public map<id,decimal>aseMaxSpeedMapBasic;
    public map<id,String>aseAFBRSpeedMap;
    public map<id,String>aseAEoCUSpeedMap;  
    public map<id,decimal>aseMaxSpeedMapBroadband;
    public transient set<Id> eligiblesiteIds ;
    public list<String> BasePortSpeedAseList{get;set;}
    public list<String> PromoPortSpeedAseList{get;set;}
    public boolean isOfflineMode{get;set;}
    public String currntQuoteId{get;set;}
    public Boolean IglooReviewRequired{get;set;}
    public Boolean iglooSpeedNotAvailable {get;set;}
    List<QuoteProducts.cCustomerSite> IglooSiteLst;
    List<QuoteProducts.cCustomerSite> nonIglooSiteLst;
    List<QuoteProducts.cCustomerSite> siteLstNeedsToBeAdded ;
    public Boolean inRegionSite{get;set;}     
    public list<Admin_Control__c> adminControlList;
    public String configPageTimeout1{get;set;}
    public String configPageTimeout2{get;set;}
    public Integer noOfReviewRequiredSites{get;set;} 
    public IGLOOIntegrationHandler handler = new IGLOOIntegrationHandler();  
    public Boolean isIglooSpeedBump{get;set;}
    public Boolean showOORSEExpired{get;set;}   
    boolean isIglooExpired;
    public boolean eligibleRateRefresh{get;set;}
    Set<Id> avForInRegion;
    Set<Id> avForOOR;
    List<Integer> lineItemNumberForRateRefresh; 
    public boolean doBatchPolling{get;set;}
    
    //Wireline Promotions
    public map<String,list<Wireline_Promotion_Rules__c>> wirelinePromoMap{get;set;}
    public Id siteQuoteJunctionId;
    public String wirelinePromotions;
    public String wirelinePromotionsApplied;
    public Apttus_Proposal__Proposal__c proposalObject;
    public SiteConfigureController(){ 
        wirelinePromotions =''; 
        wirelinePromotionsApplied='';
        checkDiscard= false;
        removePopupOnLoadFlag = false;
        eligibleRateRefresh=false;
        doBatchPolling=false;
        isOfflineMode = false;
        isIglooExpired=false; 
        showOORSEExpired=false;
        avForInRegion=new Set<Id>();
        avForOOR=new Set<Id>();
        lineItemNumberForRateRefresh=new List<Integer>();
        adminControlList = [SELECT id, Rate_Card_Offline_Threshold__c, Rate_Card_OOR_Threshold__c,Config_Offline_Threshold__c, OOR_Offline_Threshold__c,Config_Page_Time_Out_1__c, Config_Page_Time_Out_2__c,IglooSpeedBump__c FROM Admin_Control__c limit 1]; 
        configPageTimeout1 = String.valueOf(adminControlList[0].Config_Page_Time_Out_1__c * 1000);        
        configPageTimeout2 = String.valueOf(adminControlList[0].Config_Page_Time_Out_2__c * 1000);
        isIglooSpeedBump =  adminControlList[0].IglooSpeedBump__c; 
        wirelinePromoMap = new map<String,list<Wireline_Promotion_Rules__c>>();
        
        //ASE Related Changes    
        isAccessDiscountEligible = false;    
        isASE =false;
        allEligibleSelected =false;
        IglooReviewRequired = false;
        iglooSpeedNotAvailable = false;
        
        List<Apttus_Proposal__Proposal__c> quotelist= new List<Apttus_Proposal__Proposal__c>();
        quoteId = apexpages.currentpage().getparameters().get('quoteId');
        if(quoteId != null) {
            quotelist = [Select Name,SiteRemovalCheck__c, Apttus_Proposal__Opportunity__c,Apttus_Proposal__Opportunity__r.StageName from Apttus_Proposal__Proposal__c  where  id = :quoteId];                
        }
        for(Apttus_Proposal__Proposal__c quoteOppty : quotelist){
             if(quoteOppty.Apttus_Proposal__Opportunity__c != null && quoteOppty.Apttus_Proposal__Opportunity__r.StageName != 'Deal Registration Requested' && quoteOppty.Apttus_Proposal__Opportunity__r.StageName != 'Deal Registration Approved' && quoteOppty.Apttus_Proposal__Opportunity__r.StageName != 'Deal Reg Auto-Approved' && quoteOppty.Apttus_Proposal__Opportunity__r.StageName != 'Cancelled') {   
                removePopupOnLoadFlag = true;
                if(!quoteOppty.SiteRemovalCheck__c){
                    checkDiscard = true;
                }
             }
        }
        quoteHelper = new QuoteInfoHelper();
        String currntQuoteId = ApexPages.currentPage().getParameters().get('quoteId'); 
        system.debug('Quote Id -> '+currntQuoteId );
        proposalObject= [select Id, Product_New_Name__c,Site_Status__c, Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Payment_Term__c,Product__r.ProductCode, Product__c,Rate_Card_Effective_Date__c,Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c,MACD_Change_Type__c,DealHash__c,Term__c,Apttus_Proposal__Account__r.Master_Agent__c,Apttus_Proposal__Account__r.Current_Tier__c,Name,subAccountNumber__c,Apttus_QPConfig__PriceListId__r.Id, Opportunity_Owner_Email__c, Docusign_Envelope__c, Denial_Reason__c, Contract_Read__c, End_Customer__c, Contract_Signed__c, End_Customer__r.Name,End_Customer__r.Mailing_Street_Address__c,End_Customer__r.City__c, Product__r.name, End_Customer__r.Zip__c,End_Customer__r.State__c,Product_Name__c, Apttus_Proposal__Opportunity__c,Apttus_Proposal__Approval_Stage__c,Is_Offline_Config_Completed__c,Bulk_Sevice_Availability_Indicator__c,isRateRefreshBatchProcessing__c,Buyflow_Step__c from Apttus_Proposal__Proposal__c where id = :currntQuoteId ];
        quoteObj = proposalObject;
        if(quoteObj.Apttus_Proposal__Approval_Stage__c.equals(BuyflowConstant.BULKSERVICE_AVAILABILITY_REQUESTED) || quoteObj.Apttus_Proposal__Approval_Stage__c.equals('Bulk Service Availability Requested')){
            isOfflineMode = true;
        }    
        if( quoteObj != null && quoteObj.Product_Name__c == 'AT&T Switched Ethernet Service'){
            isASE = true;
        }  
        
        selectedTerm= '';
        dropDownList = new list<SelectOption>();
        dropDownList.add(new Selectoption('', '--None--'));        
        basicPMList = new list<Apttus_Config2__PriceMatrixEntry__c>();
        broadbandPMList = new list<Apttus_Config2__PriceMatrixEntry__c>();  
        basic100BaseList = new list<String>();
        basic100PromoList = new list<String>();
        basic1000BaseList = new list<String>();
        basic1000PromoList = new list<String>();
        basic10000BaseList = new list<String>();
        broadband1000List = new list<String>();
                  
        interfaceType5=new Set<String>();
        interfaceType10=new Set<String>();
        interfaceType20=new Set<String>();
        interfaceType50=new Set<String>();
        interfaceType100=new Set<String>();
        interfaceTypeList=new Set<String>();
        BasePortSpeedAseList = new List<String>();
        PromoPortSpeedAseList= new List<String>();
        siteInterfaceTypeMap=new Map<String,Map<integer,Set<String>>>();
        mapJunction = new  Map<String,string> ();
        interfaceTypeMap=new Map<integer,Set<String>>();
        noOfSoftDeletedSites = 0;
        siteselect= false;
        totalPhoneNumber = 0;
        portedPhoneNumber = 0;
        newLocalPhoneNumber = 0;
        newVirtualPhoneNumber = 0;
        isHiCapFlex = false;
        isIPFlex = false;
        User userObj;
        userObj = [select id, Begin_Quote__c,Contact.Account.IPFlex_Product__c,Contact.Account.ManagedRouter__c,Contact.Account.Id from User where id = :UserInfo.getUserId()];
        accountId = userObj.Contact.Account.Id;
        siteIdEthernetAvailMap = new Map<String,Boolean>();        
        listCustomerSiteMaster = new List<QuoteProducts.cCustomerSite>();
        fiberCode = '';
        grandTot = 0;
        siteTotal = 0;
        disableNext = false;
        disablePrevious = true;
        isPricingDataAvailable = false;
        isReviewMode = false;
        isSitereview=false;
        oneTimeFee = 0.0;
        junctToSoftDelete = '';
        noOfConfigedSites = 0;
        siteLinenumberMap = new Map<Id,Integer>();
        helper = new ApttusServiceUtilityHelper();

        lineItems = new List<Apttus_Config2__LineItem__c>();
        configData = new Apttus_Config2__ProductConfiguration__c();
        dataWrap = new List<wrapperDataS>();
        sObject sObj = Schema.getGlobalDescribe().get('Apttus_Config2__ProductAttributeValue__c').newSObject();
        Apttus_Config2__ProductConfiguration__c configData = new Apttus_Config2__ProductConfiguration__c();
        lineItems = new List<Apttus_Config2__LineItem__c>();
        selectedSiteInfo = new customersite__c();
        
        //Added as part of apttus optimization changes
        lecNameLst = new List<String>();
        pgList = new List<Provider_Grouping__c>();
        lecscopeList = new List<String> ();
        speedsNotAvailableITPAList = new list<String>();
        
        quotehelper.initialiseparam(ApexPages.currentPage(),this);       
        if(ApexPages.currentPage().getParameters().get('quoteId') != null){
            quoteId = ApexPages.currentPage().getParameters().get('quoteId'); 
            system.debug('Quote Id -> '+quoteId);
            quoteObj = quoteHelper.getQuote(quoteId);
            system.debug('Quote Id @@@@@@@@-> '+quoteObj );
            proposalData = new Apttus_Proposal__Proposal__c();
            fetchAndInitQuoteDetails();
        }
        isConfigSiteModeOn = false;
        if( ApexPages.currentPage().getParameters().get('mode') == 'reviewquote' ){
            isReviewMode = true;
        }
        if( ApexPages.currentPage().getParameters().get('mode') == 'siteinfo' ){
            isSitereview = true;
        }
        if(isASE == false){
            isUBBinCart = iSHiCapInCart();
            isIPFlexInCart = isIPFlexInCart();
            handleHiCapOnRefresh();
            handleIPFlexOnRefresh();
            doITPAPolling =true;
            ITPAError=false;
            isIPFlexProdChecked = false;
            isManagedrouterchecked=false;
            if (userObj != null) {
                isIPFlexProdChecked = userObj.Contact.Account.IPFlex_Product__c;
                isManagedrouterchecked=userObj.Contact.Account.ManagedRouter__c;
            }  
        }
    }
    
    public SiteConfigureController(String igloo){         
    }
    
    public void loadPromotionListtoCache(String siteId, string promotionsList,string speedExlusion , string region){
        if(promotionsList ==null || promotionsList == ''){
          cache.session.remove('promotionpersite');
          return;
        }
  
        Map<String,String> discountSpeedsPortPlusMap = new Map<String,String>();
        Map<String,String> discountSpeedsPortBasicMap = new Map<String,String>();
        Map<String,string> discountSpeedsAccessMap = new Map<String,String>();
        Map<String,String> discountSpeedsMBCMISMap = new Map<String,String>();
        Map<String,String> discountSpeedsMBCMISPlusMap = new Map<String,String>();
        List<String> ipflexList = new List<String>();
        List<String> misPlusList = new List<String>();
        List<String> cosList = new List<String>();
        List<String> vlanList = new List<String>();
        List<String> mbcList = new List<String>();  
        List<String> dnsPrimaryMap = new List<String>();
        List<String> dnsSecondaryMap = new List<String>();
        List<String> planAList = new List<String>();
        List<String> planBList = new List<String>();
        List<String> planCList = new List<String>();

        System.debug('site id is: ' + siteId);
        System.debug('Promotion list is: ' + promotionsList);
        List<Wireline_Promo_Meta_Data__c> wirelineSpeeds;
    
        String promotionstoBedisplayed = promotionsList;
    
        List<String> promotionList = promotionstoBedisplayed.split(',');
        System.debug('Promotion List after split: ' + promotionList);
        Map<Id,Wireline_Promotion_Rules__c> wprMap = new Map<Id,Wireline_Promotion_Rules__c>();
        wprMap = Promotion.getAll();
        
        for(String pl : promotionList){
            List<String> promoIdandType = pl.split('_');
            System.debug('look for me: loading promotion from cache: ' + promoIdandType[0].trim());                      
            Wireline_Promotion_Rules__c pro = (Wireline_Promotion_Rules__c)Promotion.get(promoIdandType[0].trim());
            system.debug('@@@pro 1: '+pro);
            if(pro == null){
                pro = wprMap.get(promoIdandType[0].trim());  
            }
            System.debug('@@@@pro 2: ' + pro);
            if(!pro.Promotion_Notification__c){
                continue;
            }
            if(promoIdandType[1].containsIgnoreCase('Port')){
                String portPromoTag = SpecialCharacterConstant.CONCAT;
                System.debug('Promo prod flavor: ' + pro.Field_Inputs__c);
                List<String> promoValues = pro.Field_Inputs__c.split('\\|');
                System.debug('Promo Values: '+ promoValues);
                for (String pv: promoValues){
                    if (pv.containsIgnoreCase('Port Speed')){
                        System.debug('Port Speed: ' + pv.substringAfterLast(':'));
                        pv = pv.substringAfterLast(':');
                        pv = pv.replace('\"','');
                        pv = pv.replace('1000 Mbps','1G');
                        pv = pv.replace(' Mbps','M');
                        System.debug('pv is: '+ pv);
                        List<String> s = pv.split(';');
                        System.debug('speed list is: ' + s.size());
                        System.debug('speed list value is: ' + s[0]);
                        System.debug('size of s is: ' + s.size());
                        if(s.size()>0 && !String.isBlank(pro.Promotion_Tag__c)){
                            portPromoTag = pro.Promotion_Tag__c;
                        }
                    }
                }
                if(pro.Field_Inputs__c.containsIgnoreCase('Plus') && portPromoTag !=SpecialCharacterConstant.CONCAT){
                    discountSpeedsPortPlusMap.put(portPromoTag,pro.Discount_Percentage__c.format());
                }
               
                if(pro.Field_Inputs__c.containsIgnoreCase('Hi-Cap') && portPromoTag !=SpecialCharacterConstant.CONCAT){
                    if(pro.Field_Inputs__c.containsIgnoreCase('Plus')){
                         discountSpeedsMBCMISPlusMap.put(portPromoTag,pro.Discount_Percentage__c.format());
                            System.debug('look for me: discountSpeedsMBCMISMap: ' + JSON.serialize(discountSpeedsMBCMISPlusMap));
                    }
                    else{
                        discountSpeedsMBCMISMap.put(portPromoTag,pro.Discount_Percentage__c.format());
                        System.debug('look for me: discountSpeedsMBCMISMap: ' + JSON.serialize(discountSpeedsMBCMISMap));
                    }
                }
                if(!pro.Field_Inputs__c.containsIgnoreCase('Hi-Cap') && !pro.Field_Inputs__c.containsIgnoreCase('Plus')){
                    discountSpeedsPortBasicMap.put(portPromoTag,pro.Discount_Percentage__c.format());
                    System.debug('look for me: discountSpeedsPortBasicMap: ' + JSON.serialize(discountSpeedsPortBasicMap));
                }
            }
             
            if(promoIdandType[1].containsIgnoreCase('Access')){
                String portPromoTag = SpecialCharacterConstant.CONCAT;
                String speeds='';
                System.debug('Promo prod flavor: ' + pro.Field_Inputs__c);
                List<String> promoValues = pro.Field_Inputs__c.split('\\|');
                System.debug('Promo Values: '+ promoValues);
                
                for (String pv: promoValues){
                    if(pv.containsIgnoreCase('Access Speed')){
                        System.debug('Access Speed: ' + pv.substringAfterLast(':'));
                        pv = pv.substringAfterLast(':');
                        pv = pv.replace('\"','');
                        pv = pv.replace('1000 Mbps','1G');
                        pv = pv.replace(' Mbps','M');
                        List<String> s = pv.split(';');
                        List<String> speedAfterExlusion = new List<String>();
                        system.debug('@@@s: '+s);
                        if(s.size()>0 && !String.isBlank(pro.Promotion_Tag__c)){
                            portPromoTag = pro.Promotion_Tag__c;
                        }
                        for(String sp: s){
                            if(region !=null){
                                if((String.isNotBlank(speedExlusion) && !speedExlusion.containsIgnoreCase(sp)) || region == 'OOR'){
                                    speedAfterExlusion.add(sp);
                                }
                            }   
                            else{
                                speedAfterExlusion.add(sp);
                            }                 
                        }
                        System.debug(' Access speed list is: ' + s.size());
                        if(speedAfterExlusion.size()>=1 && speedAfterExlusion[0]!=''){
                            speeds = String.join(speedAfterExlusion,',');
                        }
                        speeds = speeds.replaceAll('1G','1000M');
                    }
                }
                if(discountSpeedsAccessMap.containsKey(speeds)){
                    speeds = speeds + '_' + discountSpeedsAccessMap.size();
                    System.debug('look for me: duplicate speeds: ' + speeds);
                }
                discountSpeedsAccessMap.put(portPromoTag,pro.Discount_Percentage__c.format());
                System.debug('look for me: discountSpeedsAccessMap: ' + JSON.serialize(discountSpeedsAccessMap));
            }

            if (pro.Field_Inputs__c.containsIgnoreCase('IPFLEX')){
                IpflexList.add(pro.Promotion_Name__c+':'+pro.Discount_Percentage__c.format()); 
            }
            if (pro.Field_Inputs__c.containsIgnoreCase('CoS')){
                cosList.add(pro.Promotion_Name__c+':'+pro.Discount_Percentage__c.format()); 
            }
            if(pro.Field_Inputs__c.containsIgnoreCase('Plus') && ((pro.Field_Inputs__c.unescapeHtml4()).containsIgnoreCase('Port Speed:|') || !pro.Field_Inputs__c.containsIgnoreCase('Port Speed'))){
                misPlusList.add(pro.Discount_Percentage__c.format());
            }
            if (pro.Field_Inputs__c.containsIgnoreCase('Primary') || pro.Field_Inputs__c.containsIgnoreCase('Secondary')){
                if (pro.Field_Inputs__c.containsIgnoreCase('Primary')){
                    dnsPrimaryMap.add(pro.Promotion_Name__c+':'+pro.Discount_Percentage__c.format()); 
                } 
                if (pro.Field_Inputs__c.containsIgnoreCase('Secondary')){
                    dnsSecondaryMap.add(pro.Promotion_Name__c+':'+pro.Discount_Percentage__c.format()); 
                } 
            }
            if(pro.Field_Inputs__c.containsIgnoreCase('Hi-Cap')){
                mbcList.add(pro.Discount_Percentage__c.format()); 
            }
            if(pro.Field_Inputs__c.containsIgnoreCase('VLAN')){
                vlanList.add(pro.Promotion_Name__c+':'+pro.Discount_Percentage__c.format()); 
            }
            if(pro.Field_Inputs__c.containsIgnoreCase('Plan')){
                if(pro.Field_Inputs__c.containsIgnoreCase('Plan A')){
                    planAList.add(pro.Discount_Percentage__c.format());    
                }
                if(pro.Field_Inputs__c.containsIgnoreCase('Plan B')){
                    planBList.add(pro.Discount_Percentage__c.format()); 
                }
                if(pro.Field_Inputs__c.containsIgnoreCase('Plan C')){
                    planCList.add(pro.Discount_Percentage__c.format());
                }
            }
        }
    
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('siteId', siteId);
        set<String> keys = discountSpeedsPortPlusMap.KeySet();
        System.debug('Basic key set is: ' + keys);
        if(keys.size()>0){
            gen.writeFieldName('MIS Plus');
        
            System.debug(discountSpeedsPortPlusMap.KeySet());
            gen.writeStartArray();
            for(String key: keys){
                String key1 = key.replaceAll('_[0-9]*',''); 
                gen.writeStartObject();
                gen.writeFieldName('Speed');
                gen.writeString(key1);
                gen.writeFieldName('Discount');
                gen.writeObject(discountSpeedsPortPlusMap.get(key));
                gen.writeEndObject();
            }
            gen.writeEndArray();
        }
        keys = discountSpeedsMBCMISMap.keySet();
        System.debug(' MBC Basic key set is: ' + keys);
        
        if(keys.size()>0){
            gen.writeFieldName('MBC Basic');     
            System.debug(discountSpeedsMBCMISMap.KeySet());
            gen.writeStartArray();
            for(String key: keys){
                gen.writeStartObject();
                gen.writeFieldName('Speed');
                String key1 = key.replaceAll('_[0-9]*',''); 
                gen.writeString(key1);
                gen.writeFieldName('Discount');
                gen.writeObject(discountSpeedsMBCMISMap.get(key));
                gen.writeEndObject();
            }
            gen.writeEndArray();
        }
    
        keys = discountSpeedsMBCMISPlusMap.keySet();
        System.debug('MBC plus key set is: ' + keys);
        if(keys.size()>0){
            gen.writeFieldName('MBC Plus');     
            System.debug(discountSpeedsMBCMISPlusMap.KeySet());
            gen.writeStartArray();
            for(String key: keys){
                gen.writeStartObject();
                gen.writeFieldName('Speed');
                String key1 = key.replaceAll('_[0-9]*',''); 
                gen.writeString(key1);
                gen.writeFieldName('Discount');
                gen.writeObject(discountSpeedsMBCMISPlusMap.get(key));
                gen.writeEndObject();
            }
            gen.writeEndArray();
        }
          
        keys = discountSpeedsPortBasicMap.KeySet();
        System.debug('Basic key set is: ' + keys);
        if(keys.size()>0){
            gen.writeFieldName('MIS Basic');
            System.debug(discountSpeedsPortPlusMap.KeySet());
            gen.writeStartArray();
            for(String key: keys){
                System.debug('key in loop is: ' + key);
                gen.writeStartObject();
                gen.writeFieldName('Speed');
                String key1 = key.replaceAll('_[0-9]*','');
                gen.writeString(key1);
                gen.writeFieldName('Discount');
                gen.writeObject(discountSpeedsPortBasicMap.get(key));
                gen.writeEndObject();
            }
            gen.writeEndArray();
        }
    
        keys = discountSpeedsAccessMap.KeySet();
        System.debug('Access key set is: ' + keys);
        
        if(keys.size()>0){
            gen.writeFieldName('ACCESS');       
            System.debug(discountSpeedsAccessMap.KeySet());
            gen.writeStartArray();
            for(String key: keys){
                String key1 = key.replaceAll('_[0-9]*',''); 
                gen.writeStartObject();
                gen.writeFieldName('Speed');
                gen.writeString(key1);
                gen.writeFieldName('Discount');
                gen.writeObject(discountSpeedsAccessMap.get(key));
                gen.writeEndObject();
            }
            gen.writeEndArray();
        }
        if(!misPlusList.isEmpty()){
            gen.writeFieldName('PLUS');
            gen.writeStartObject();
            gen.writeFieldName('Discount');
            gen.writeObject(misPlusList);
            gen.writeEndObject();
        }
        if(!cosList.isEmpty()){
            gen.writeFieldName('COS');
            gen.writeStartObject();
            gen.writeFieldName('Discount');
            gen.writeObject(cosList);
            gen.writeEndObject();
        }
        if(!IpflexList.isEmpty()){
            gen.writeFieldName('IPFLEX');
            gen.writeStartObject();
            gen.writeFieldName('Discount');
            gen.writeObject(IpflexList);
            gen.writeEndObject();
        }
        if(!vlanList.isEmpty()){
            gen.writeFieldName('VLAN');
            gen.writeStartObject();
            gen.writeFieldName('Discount');
            gen.writeObject(vlanList);
            gen.writeEndObject();
        }
        if( dnsPrimaryMap.size()>0 || dnsSecondaryMap.size()>0){
            gen.writeFieldName('DNS');
            gen.writeStartObject();
            if(dnsPrimaryMap.size()>0){
                gen.writeFieldName('Primary');
                gen.writeObject(dnsPrimaryMap);
            }
            if(dnsSecondaryMap.size()>0 ){
                gen.writeFieldName('Secondary');
                gen.writeObject(dnsSecondaryMap);
            }
            gen.writeEndObject();
        }
        
        if(planAList.size()>0 || planBList.size()>0 || planCList.size()>0){
            gen.writeFieldName('PLAN');
            gen.writeStartObject();
            if(planAList.size()>0){
                gen.writeFieldName('PLANA');
                gen.writeObject(planAList);
            }
            if(planBList.size()>0){
                gen.writeFieldName('PLANB');
                gen.writeObject(planBList);
            }
            if(planCList.size()>0){
                gen.writeFieldName('PLANC');
                gen.writeObject(planCList);
            }
            gen.writeEndObject();
        } 
        System.debug('JSON is: ' + gen.getAsString());
        System.debug('dml statments executed: ' + Limits.getLimitQueries());
      
        Cache.session.remove('promotionpersite');
        Cache.session.put('promotionpersite',gen.getAsString());
        PromotionsForSite = gen.getAsString();
        System.debug(Cache.session.get('promotionpersite')); 
    }
  
    public void loadSoftDeletedSite(){
        List<AT_T_Customer_Site_Quote__c> softDeletedSites = new List<AT_T_Customer_Site_Quote__c>();
        if(currntQuoteId != null){ 
             softDeletedSites = [SELECT Id,Is_Soft_Deleted__c,AT_T_Customer_Site__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c  =: currntQuoteId  and Is_Soft_Deleted__c=true ]; 
        }

        if(!softDeletedSites.isEmpty()){
            for(AT_T_Customer_Site_Quote__c deletedSites : softDeletedSites){    
                softDeletedSitesmap.put(deletedSites.AT_T_Customer_Site__c,deletedSites.AT_T_Customer_Site__c); 
            } 
        }
    }
    
    public void fetchAndInitQuoteDetails(){        
        proposalData = proposalObject;
        if(!Test.isRunningTest()){
            initializeIndices();
        }
        isMIS = false;
        isAvpn = false;
        isASE = false;
        
        if( proposalData.Product_Name__c == 'AT&T Virtual Private Network' ){
            isAvpn = true;
        }else if ( proposalData.Product_Name__c == 'AT&T Managed Internet Service' ){
            isMIS = true;
        }else if( proposalData.Product_Name__c == 'AT&T Switched Ethernet Service'){
            isASE = true;
        }           
        selectedFilter = proposalData.Site_Status__c;
        if(proposalData.Apttus_Proposal__Payment_Term__c != null){
            selectedTerm = proposalData.Apttus_Proposal__Payment_Term__c;
            if(String.isNotBlank(accountId)){
                dropDownList.addAll(fetchCNUMValues());
            }
        }
    }
    
    public void initializeIndices(){
        if(proposalData.Product_Name__c == 'AT&T Virtual Private Network' || proposalData.Product_Name__c == 'AT&T Managed Internet Service' ){
            Apttus_Attr_Mandatory_Fields__c mandetoryField = Apttus_Attr_Mandatory_Fields__c.getInstance(proposalData.Product_Name__c);
            fieldIndices = mandetoryField.Field_Indices__c;
            fieldIndicesUBB = mandetoryField.Field_IndicesUBB__c;            
            
            if(mandetoryField.IP_Flexible_Reach_Plan__c!=null){
                IPFlexibleReachPlanInt = Integer.valueOf( mandetoryField.IP_Flexible_Reach_Plan__c );
            }
            if(mandetoryField.Ported_Phone_Numbers__c!=null){
                PortedPhoneNumbersInt = Integer.valueOf( mandetoryField.Ported_Phone_Numbers__c );
            }
            if(mandetoryField.New_Local_Phone_Numbers__c!=null){
                NewLocalPhoneNumbersInt = Integer.valueOf( mandetoryField.New_Local_Phone_Numbers__c );
            }
            if(mandetoryField.New_Virtual_Phone_Numbers__c!=null){
                NewVirtualPhoneNumbersInt = Integer.valueOf( mandetoryField.New_Virtual_Phone_Numbers__c );
            }
            if(mandetoryField.Concurrent_Calls__c!=null){
                ConcurrentCallsInt = Integer.valueOf( mandetoryField.Concurrent_Calls__c );
            }
            if(mandetoryField.Enhanced_Features__c!=null){
                EnhancedFeaturesInt = Integer.valueOf( mandetoryField.Enhanced_Features__c );
            }            
            if(mandetoryField.IP_Flexible_Reach_Plan_Ubb__c!=null){
                IPFlexibleReachPlanIntUbb = Integer.valueOf( mandetoryField.IP_Flexible_Reach_Plan_Ubb__c );
            }
            if(mandetoryField.Ported_Phone_Numbers_Ubb__c!=null){
                PortedPhoneNumbersIntUbb = Integer.valueOf( mandetoryField.Ported_Phone_Numbers_Ubb__c );
            }
            if(mandetoryField.New_Local_Phone_Numbers_Ubb__c!=null){
                NewLocalPhoneNumbersIntUbb = Integer.valueOf( mandetoryField.New_Local_Phone_Numbers_Ubb__c );
            }
            if(mandetoryField.New_Virtual_Phone_Numbers_Ubb__c!=null){
                NewVirtualPhoneNumbersIntUbb = Integer.valueOf( mandetoryField.New_Virtual_Phone_Numbers_Ubb__c );
            }
            if(mandetoryField.Concurrent_Calls_Ubb__c!=null){
                ConcurrentCallsIntUbb = Integer.valueOf( mandetoryField.Concurrent_Calls_Ubb__c );
            }
            if(mandetoryField.Enhanced_Features_Ubb__c!=null){
                EnhancedFeaturesIntUbb = Integer.valueOf( mandetoryField.Enhanced_Features_Ubb__c );
            }
    
            if(isHiCapFlex == false){        
                portTypeIndex = mandetoryField.PortTypeInxed__c;
                portTypeIndexInt = Integer.valueOf(portTypeIndex);
                portSpeedIndexInt = portTypeIndexInt + 1;
                accessSpeedIndex = Integer.valueOf(mandetoryField.AccessSpeedIndex__c);
                if(mandetoryField.IndexOfVlan__c!=null){
                    vlanIndex = Integer.valueOf( mandetoryField.IndexOfVlan__c );
                }
                HicapIndex = mandetoryField.IndexOfUbb__c;
                HicapIndexInt = Integer.valueOf(HicapIndex);
                System.debug('------'+HicapIndexInt);
                        
                Apttus_Attr_Checkboxes__c checkBox = Apttus_Attr_Checkboxes__c.getInstance(proposalData.Product_Name__c);
                selectCheckBox = checkBox.IndicesOfCheckBoxes__c;
                
                Apttus_Attr_Dropdowns__c dropDown = Apttus_Attr_Dropdowns__c.getInstance(proposalData.Product_Name__c);
                selectDropdown = dropDown.IndicesOfDropdowns__c;
                
            }else{              
                portTypeIndex = mandetoryField.PortTypeInxed__c;
                portTypeIndexInt = Integer.valueOf(portTypeIndex);
                portTypeIndex = String.valueOf(portTypeIndexInt);
                portSpeedIndexInt = portTypeIndexInt + 1;
                accessSpeedIndex = Integer.valueOf(mandetoryField.AccessSpeedIndex__c);
                if(mandetoryField.IndexOfVlan__c!=null){
                    vlanIndex = Integer.valueOf( mandetoryField.IndexOfVlan__c );
                }
                HicapIndex = mandetoryField.IndexOfUbb__c;
                HicapIndexInt = Integer.valueOf(HicapIndex);
                System.debug('------'+HicapIndexInt);
                        
                Apttus_Attr_Checkboxes__c checkBox = Apttus_Attr_Checkboxes__c.getInstance(proposalData.Product_Name__c);
                selectCheckBox = checkBox.IndicesOfCheckBoxes__c;
                
                Apttus_Attr_Dropdowns__c dropDown = Apttus_Attr_Dropdowns__c.getInstance(proposalData.Product_Name__c);
                selectDropdown = dropDown.IndicesOfDropdowns__c;
            }
        }
    }
    
    public void checkAndInitializeCart(){
        PromotionQualifierUtil qualifier = new PromotionQualifierUtil();
        noOfSoftDeletedSites=0;
        try{
            if(!isOfflineMode && ! String.isEmpty(quoteId) && getCustomerSiteLst() != null && getCustomerSiteLst().size() >0 && !isReviewMode && !isSitereview ){
                checkExistenceAndInitializeCartLineItemsAndSelectedSiteDefault();
                List<Apttus_Proposal__Proposal__c> currentQuote = new List<Apttus_Proposal__Proposal__c>();
                currentQuote.add(proposalObject);
                if(currentQuote!=null && currentQuote.size()>0){
                    selectedProductId=currentQuote[0].Product__c;
                }
                Apttus_Config2__ProductConfiguration__c prodConfig = quoteHelper.retrieveExistingCartId(quoteId);
                system.debug('@@@@ prodConfig :: '+prodConfig);
                
                if(prodConfig != null){
                    cartId = prodConfig.Id;
                    system.debug('---selectedSiteId---'+selectedSiteId+'---quote id---'+quoteId);
                    if(!String.isEmpty(selectedSiteId)){
                        qualifier.determinePromotionAtSiteLevel(selectedSiteId,quoteId);
                        List<AT_T_Customer_Site_Quote__c> listSiteJunction = new List<AT_T_Customer_Site_Quote__c>();
                        listSiteJunction = [SELECT Id,Region__c,Speeds_Not_Available_ITPA__c,AT_T_Customer_Site__c,Igloo_Review_Required__c,Wireline_Promotion_Id_Sorted__c,Wireline_Promotion_Id_Before__c,Wireline_Promotion_Id_After__c,Wireline_Promotion_Id_Applied__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Customer_Site__c=: selectedSiteId and AT_T_Quote__c=: quoteId];
                        if(!listSiteJunction.isEmpty())
                        {
                            System.debug('@@@@@listSiteJunction'+listSiteJunction); 
                            siteQuoteJunctionId = listSiteJunction[0].Id;
                            IglooReviewRequired = listSiteJunction[0].Igloo_Review_Required__c;
                            loadPromotionData(listSiteJunction[0].Wireline_Promotion_Id_Applied__c);               
                            System.debug('look for me before promotions: ' + listSiteJunction[0].Wireline_Promotion_Id_Before__c);
                            System.debug('look for me after promotions: ' + listSiteJunction[0].Wireline_Promotion_Id_After__c);                     
                            wirelinePromotionsApplied = listSiteJunction[0].Wireline_Promotion_Id_Applied__c;
                            System.debug('look for me: wirelinePromotions: ' + wirelinePromotions );
                            loadPromotionListtoCache(listSiteJunction[0].AT_T_Customer_Site__c,listSiteJunction[0].Wireline_Promotion_Id_Sorted__c,listSiteJunction[0].Speeds_Not_Available_ITPA__c , listSiteJunction[0].Region__c);
                        }
                        createLiteItemOnSiteSelection(cartId, selectedProductId, selectedSiteId );
                    }                   
                }else{
                    qualifier.determinePromotionAtSiteLevel(selectedSiteId,quoteId);
                    List<AT_T_Customer_Site_Quote__c> listSiteJunction = new List<AT_T_Customer_Site_Quote__c>();
                    listSiteJunction = [SELECT Id,Region__c,AT_T_Customer_Site__c,Speeds_Not_Available_ITPA__c,Igloo_Review_Required__c,Wireline_Promotion_Id_Sorted__c,Wireline_Promotion_Id_Before__c,Wireline_Promotion_Id_After__c,Wireline_Promotion_Id_Applied__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c=: quoteId];
                    if(!listSiteJunction.isEmpty())
                    {
                        System.debug('@@@@@listSiteJunction'+listSiteJunction);     
                        selectedSiteId = listSiteJunction[0].AT_T_Customer_Site__c;
                        siteQuoteJunctionId = listSiteJunction[0].Id;
                        IglooReviewRequired = listSiteJunction[0].Igloo_Review_Required__c;
                        loadPromotionData(listSiteJunction[0].Wireline_Promotion_Id_Applied__c);
                        wirelinePromotionsApplied = listSiteJunction[0].Wireline_Promotion_Id_Applied__c;
                        System.debug('look for me before promotions: ' + listSiteJunction[0].Wireline_Promotion_Id_Before__c);
                        System.debug('look for me after promotions: ' + listSiteJunction[0].Wireline_Promotion_Id_After__c);  
                        wirelinePromotions=listSiteJunction[0].Wireline_Promotion_Id_Sorted__c;
                        loadPromotionListtoCache(selectedSiteId ,wirelinePromotions,listSiteJunction[0].Speeds_Not_Available_ITPA__c,listSiteJunction[0].Region__c);
                    }
                    cartId = helper.createCart(quoteId);
                    createLiteItemOnSiteSelection(cartId, selectedProductId, selectedSiteId );
                }
                initializeUIContentFromSchema();
                initializeData();
                if(isASE == true){
                    loadASEConfigurationData(listAttrVal);
                    checkBasicBroadbandEnablement();
                    loadASECIRPicklistValues();
                }
              
                List<AT_T_Customer_Site_Quote__c> custSiteQuoteLst = [Select Id,Is_Soft_Deleted__c, Name,Iglow_Response_Received_Date__c,AT_T_Customer_Site__c,hub__c,AT_T_Quote__c,AT_T_Quote__r.Product__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,AT_T_Quote__r.Name,AT_T_Quote__r.Apttus_Proposal__Payment_Term__c,AT_T_Quote__r.Apttus_QPConfig__PriceListId__c,AT_T_Quote__r.Product__r.Name, AT_T_Customer_Site__r.Id, AT_T_Customer_Site__r.Name, AT_T_Customer_Site__r.Site_Name__c, AT_T_Customer_Site__r.City__c, AT_T_Customer_Site__r.Service_Availability_Response__c, AT_T_Customer_Site__r.State__c, AT_T_Customer_Site__r.Address_Line__c,AT_T_Customer_Site__r.Tier__c ,AT_T_Customer_Site__r.Building_Cili__c,AT_T_Customer_Site__r.Code_EMUX_Fiber__c,AT_T_Customer_Site__r.LATA_Number__c,Igloo_Review_Required__c,Wireline_Promotion_Applied__c from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=:quoteId];
                if(custSiteQuoteLst.size()>0 && custSiteQuoteLst!=null &&  prodConfig!=null){
                   initializeCustomerSiteLst(custSiteQuoteLst);
                   readPricingStatusForAllLineItem(prodConfig);  
                }        
                handlefilterSites();
                if(!isOfflineMode){
                    if(date.parse(currentQuote[0].Rate_Card_Effective_Date__c).daysBetween(currentQuote[0].Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c.date())>0 && (currentQuote[0].MACD_Change_Type__c == '' || currentQuote[0].MACD_Change_Type__c == null)){
                        system.debug('rate refresh required');
                        isRateRefreshRequired();
                        if(!eligibleRateRefresh){
                            currentQuote[0].Rate_Card_Effective_Date__c =currentQuote[0].Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c.format('M/dd/yyyy');
                            update currentQuote[0]; 
                        }
                    }
                }
                checkForEligibleSitesCount(); 
                
            }
            system.debug('inside checkAndInitializeCart and doITPAPolling val is'+doITPAPolling);  
        }catch(Exception e){
            System.debug('*******exception in checkAndInitializeCart*****' + e.getLineNumber()+''+e+'trace is :'+e.getStackTraceString());
        }
    }
  
    /*******************************************************************
    * Method name : IglooExpirationCheck
    * Description : Method filters Expired and configure OOR SE sites
    * Return Type : List<String> Expired Sites id
    * User Story :  US868600
    * Update       : updated method for defect 226121
    *******************************************************************/    
    Set<String> SwitchedEthernetJunction;
    boolean isRemove=false;
    
    public Set<String> IglooExpirationCheck(List<AT_T_Customer_Site_Quote__c> jncSiteList,Boolean isApply){ 
        system.debug('inside IglooExpirationCheck and quoteid '+quoteId+' and cartId '+cartId);
        List<AT_T_Customer_Site_Quote__c> jncSiteQuoteList;
        try{
            if(isApply){
                 jncSiteQuoteList = [SELECT Id,AT_T_Customer_Site__c,Is_Soft_Deleted__c, Iglow_Response_Received_Date__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c  =: quoteId];
            }else{
                jncSiteQuoteList=jncSiteList;
            }
            Set<String> expiredJunction=new Set<String>();
            Set<String> JunctionList=new Set<String>();
            Set<String> allJunctionList=new Set<String>();
            Map<String,String> junctionSiteMap=new Map<String,String>();
            Map<String,String> expiredjunctionSiteMap=new Map<String,String>();
            SwitchedEthernetJunction=new Set<String>();
            oorSEConfiguredSite=new Set<String>();

            Map<String,boolean> softDeleteSiteMap=new Map<String,boolean>();
            String productCartId='';
            if(cartId!=null && cartId!=''){
                productCartId=cartId;
            }else{
                List<Apttus_Config2__ProductConfiguration__c> prodConfig= [select id,Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c=: quoteId order by createddate DESC limit 1];
                if(prodConfig!=null && prodConfig.size()>0)
                productCartId=prodConfig[0].id;
            }
            if(productCartId!=null){
            for(AT_T_Customer_Site_Quote__c junction : jncSiteQuoteList){          
                if(junction.Iglow_Response_Received_Date__c!=null && junction.Iglow_Response_Received_Date__c.daysBetween(system.now().date()) > 90){
                    expiredJunction.add(junction.AT_T_Customer_Site__c);
                    expiredjunctionSiteMap.put(junction.AT_T_Customer_Site__c,junction.id);
                }
                else if(junction.Iglow_Response_Received_Date__c!=null && junction.Iglow_Response_Received_Date__c.daysBetween(system.now().date()) < 91){
                    junctionSiteMap.put(junction.AT_T_Customer_Site__c,junction.id);
                    JunctionList.add(junction.id);
                }
                allJunctionList.add(junction.AT_T_Customer_Site__c);
                softDeleteSiteMap.put(junction.AT_T_Customer_Site__c,junction.Is_Soft_Deleted__c);
            }
        
            Map<String,String> expiredLineItemSiteMap=new Map<String,String>();
            Map<String,String> LineItemSiteMap=new Map<String,String>();         
            system.debug('expiredJunction '+expiredJunction);
            List<Apttus_Config2__LineItem__c> lineItemList = [SELECT Id,Alternate_Access_IGLOO_Access_Price__c, Apttus_Config2__AdjustedPrice__c,Apttus_Config2__ExtendedPrice__c,Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__BasePrice__c,Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c,AT_T_Customer_Site__r.id,Original_Net_Price__c,Original_Hidden_Price__c,Net_Price_with_Deal_Reg_Discounts__c,Net_Price_with_SP_Order_Discounts__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=: productCartId AND AT_T_Customer_Site__c IN : expiredJunction];
            Set<String> lineItemIDs=new Set<String>();        
            
            Map<Id,List<Apttus_Config2__LineItem__c>> avLineItemMap=new Map<Id,List<Apttus_Config2__LineItem__c>>();
            if(lineItemList!=null && lineItemList.size()>0){
                for(Apttus_Config2__LineItem__c lineItem : lineItemList){ 
                    if(expiredjunctionSiteMap.get(lineItem.AT_T_Customer_Site__r.id)!=null){
                        expiredLineItemSiteMap.put(lineItem.AT_T_Customer_Site__r.id,lineItem.id);                    
                        if(avLineItemMap!=null && avLineItemMap.get(lineItem.Apttus_Config2__AttributeValueId__c)!=null){
                            List<Apttus_Config2__LineItem__c> lineItems=avLineItemMap.get(lineItem.Apttus_Config2__AttributeValueId__c);
                            lineItems.add(lineItem);
                            avLineItemMap.put(lineItem.Apttus_Config2__AttributeValueId__c,lineItems);
                        }
                        else{
                            List<Apttus_Config2__LineItem__c> lineItems=new List<Apttus_Config2__LineItem__c>();
                            lineItems.add(lineItem);
                            avLineItemMap.put(lineItem.Apttus_Config2__AttributeValueId__c,lineItems);
                            
                        }                    
                    }
                    else{
                        LineItemSiteMap.put(lineItem.AT_T_Customer_Site__r.id,lineItem.id);
                    }
                    lineItemIDs.add(lineItem.Apttus_Config2__AttributeValueId__c);
                }
            }
        
            boolean isUpdated=false;
            boolean isLineItemUpdated=false;
            isRemove=false;
        
            if(lineItemIDs!=null && lineItemIDs.size()>0){
                List<Apttus_Config2__ProductAttributeValue__c> attributeValueList=[select id,VASA_Region__c,IGLOO_Port_Speed_Substituted__c,IGLOO_Access_Speed_Substituted__c,IGLOO_Interface_Type_Substituted__c,AT_T_Customer_Site__c,Access_Type_AVPN__c,Access_Type__c from Apttus_Config2__ProductAttributeValue__c where id IN : lineItemIDs];
                system.debug('lineItemList.size() '+lineItemList.size());
                for(Apttus_Config2__ProductAttributeValue__c  attributeValue : attributeValueList){
                    if((attributeValue.VASA_Region__c!=null && !attributeValue.VASA_Region__c.equalsIgnoreCase('In Region')) &&  (attributeValue.Access_Type_AVPN__c!=null && attributeValue.Access_Type_AVPN__c.equalsIgnoreCase('Switched Ethernet')) || (attributeValue.Access_Type__c!=null && attributeValue.Access_Type__c.equalsIgnoreCase('Switched Ethernet'))){
                        if(avLineItemMap!=null && avLineItemMap.get(attributeValue.id)!=null){
                            for(Apttus_Config2__LineItem__c    lineItem : avLineItemMap.get(attributeValue.id)){   
                                if(attributeValue.id==lineItem.Apttus_Config2__AttributeValueId__c && expiredLineItemSiteMap.get(lineItem.AT_T_Customer_Site__r.id)!=null){
                                    lineItem.Alternate_Access_IGLOO_Access_Price__c=0.0;
                                    lineItem.Apttus_Config2__AdjustedPrice__c=0.0;
                                    lineItem.Apttus_Config2__ExtendedPrice__c=0.0;
                                    lineItem.Apttus_Config2__BaseExtendedPrice__c=0.0;
                                    lineItem.Apttus_Config2__BasePrice__c=0.0;
                                    lineItem.Apttus_Config2__NetPrice__c=0.0;
                                    lineItem.Apttus_Config2__ListPrice__c=0.0;
                                    lineItem.Original_Net_Price__c= 0.00;
                                    isUpdated=true;
                                    isLineItemUpdated=true;  
                                    if(softDeleteSiteMap!=null && softDeleteSiteMap.size()>0 && softDeleteSiteMap.get(lineItem.AT_T_Customer_Site__c)){
                                       isRemove=true;
                                    }else{
                                        isRemove=false;
                                    }
                                    if(expiredjunctionSiteMap.get(lineItem.AT_T_Customer_Site__c)!=null){  
                                        if(!isApply){
                                            SwitchedEthernetJunction.add(expiredjunctionSiteMap.get(lineItem.AT_T_Customer_Site__c));
                                        }else{
                                            SwitchedEthernetJunction.add(lineItem.AT_T_Customer_Site__c);
                                        }
                                    }
                                } 
                                else if(junctionSiteMap.get(lineItem.AT_T_Customer_Site__c)!=null && lineItem.Apttus_Config2__NetPrice__c!=null && lineItem.Apttus_Config2__NetPrice__c!=0.0){  
                                    oorSEConfiguredSite.add(junctionSiteMap.get(attributeValue.AT_T_Customer_Site__c));
                                }
                            }
                        }
                        if(isLineItemUpdated){
                            attributeValue.IGLOO_Interface_Type_Substituted__c=false;
                            attributeValue.IGLOO_Access_Speed_Substituted__c=false;
                            attributeValue.IGLOO_Port_Speed_Substituted__c=false;
                            isLineItemUpdated=false;
                        }
                    }            
                }
                if(isUpdated){
                    update lineItemList;
                    update attributeValueList;
                }
            }
            system.debug('SwitchedEthernetJunction -->'+SwitchedEthernetJunction);
            }
        }
        catch(Exception e){
            System.debug('*******exception in IglooExpirationCheck *****' + e.getLineNumber()+''+e+'trace is :'+e.getStackTraceString());    
        }
        return SwitchedEthernetJunction;    
    }
       
    public void initializeUIContentFromSchema(){
        maxSpeedValueBasic = 0.00;
        maxSpeedValueBroadband = 0.00;
        sitePricingMap = new Map<String,QuoteProducts.SelectPricingWrap>();
    
        if(selectedSiteId != null){
            selectedSiteInfo = [SELECT Id, Alternate_Access_Building_Fiber_code__c, Code_EMUX_Fiber__c, Speeds_Not_Available_ITPA__c,Site_Name__c,phone__c,IPFlex_Plans_Qualified__c,VirtualTN_Availability_Indicator__c,Number_Availability_Indicator__c,Number_Portability_Indicator__c, Service_Availability_Response__c,Address_Line__c, City__c, State__c, Tier__c, Service_Types__c, EoCU_Max_CIR_Downstream_Speed__c, AFBR_Max_CIR_Downstream_Speed__c, ASEoLS_Max_CIR_Downstream_Speed__c FROM CustomerSite__c  WHERE Id =: selectedSiteId LIMIT 1];
        }
        if(selectedSiteInfo.Tier__c != null && selectedSiteInfo.Tier__c != ''){     
            aseTierValue = selectedSiteInfo.Tier__c;   
        }
        
        //Fiber Lit Logic
        if(proposalData.Product_Name__c != 'AT&T Switched Ethernet Service' && selectedSiteInfo.Alternate_Access_Building_Fiber_code__c != null && selectedSiteInfo.Alternate_Access_Building_Fiber_code__c != ''){        
            fiberCode = selectedSiteInfo.Alternate_Access_Building_Fiber_code__c;
        }else if(selectedSiteInfo.Code_EMUX_Fiber__c != null && selectedSiteInfo.Code_EMUX_Fiber__c != ''){
            fiberCode = selectedSiteInfo.Code_EMUX_Fiber__c;
        }
        if(selectedSiteInfo.Speeds_Not_Available_ITPA__c != null && selectedSiteInfo.Speeds_Not_Available_ITPA__c != ''){
            String stringOfSpeeds = selectedSiteInfo.Speeds_Not_Available_ITPA__c.replaceAll('M',' Mbps'); 
            stringOfSpeeds = stringOfSpeeds.replaceAll('1G','1000 Mbps'); 
            List<String> listOfSpeeds = stringOfSpeeds.split(',');
            for(String speed: listOfSpeeds){
                speedsNotAvailableITPAList.add('\''+speed+'\'');
            }
        }
        
        if(selectedSiteInfo.Service_Availability_Response__c != null){
            inRegionSite = siteVasaResValidatorIns.checkSiteInRegion(selectedSiteInfo.Service_Availability_Response__c, selectedSiteInfo.Id);
        } 
        if(selectedSiteInfo.Service_Types__c != null && selectedSiteInfo.Service_Types__c != ''){
            if(selectedSiteInfo.Service_Types__c.contains('AFBR')){
                isAFBR =  true;
            }
            if(selectedSiteInfo.Service_Types__c.contains('AEOCU')){
                isEoCU =  true;
            }
            if(selectedSiteInfo.Service_Types__c.contains('ASEoLS')){
                isASEoLS =  true;
            }  
        }
        
        if(isEoCU == true){
            if(selectedSiteInfo.EoCU_Max_CIR_Downstream_Speed__c != null && selectedSiteInfo.EoCU_Max_CIR_Downstream_Speed__c != ''){
                maxSpeedValueBasic = getSpeed(selectedSiteInfo.EoCU_Max_CIR_Downstream_Speed__c);
            }
        }       
        if(isAFBR == true){
            if(selectedSiteInfo.AFBR_Max_CIR_Downstream_Speed__c != null && selectedSiteInfo.AFBR_Max_CIR_Downstream_Speed__c != ''){
                maxSpeedValueBasic = getSpeed(selectedSiteInfo.AFBR_Max_CIR_Downstream_Speed__c);
            }
        }       
        if(isASEoLS == true ){
            if(selectedSiteInfo.ASEoLS_Max_CIR_Downstream_Speed__c != null && selectedSiteInfo.ASEoLS_Max_CIR_Downstream_Speed__c != ''){
                maxSpeedValueBroadband = getSpeed(selectedSiteInfo.ASEoLS_Max_CIR_Downstream_Speed__c);
            }
        }
        system.debug('@@@maxSpeedValueBasic: '+maxSpeedValueBasic);
        system.debug('@@@maxSpeedValueBroadband: '+maxSpeedValueBroadband);
        
        if(selectedSiteInfo.Service_Availability_Response__c != null){
            jsonServiceAvailability = selectedSiteInfo.Service_Availability_Response__c.unescapeHtml3();
            jsonServiceAvailability = String.escapeSingleQuotes(jsonServiceAvailability);
        }
        if(selectedSiteInfo.IPFlex_Plans_Qualified__c != null){
            IPFlexPlans = selectedSiteInfo.IPFlex_Plans_Qualified__c;
        }
        if( selectedSiteInfo.Number_Availability_Indicator__c != null ){
            NumberAvailabilityIndicator = selectedSiteInfo.Number_Availability_Indicator__c;
        }
        if( selectedSiteInfo.Number_Portability_Indicator__c != null ){
            NumberPortabilityIndicator = selectedSiteInfo.Number_Portability_Indicator__c;
        }        
        if( selectedSiteInfo.VirtualTN_Availability_Indicator__c != null ){
            VirtualTNAvailabilityIndicator = selectedSiteInfo.VirtualTN_Availability_Indicator__c;
        }
        
        listAttrProductJunction = new List<Apttus_Config2__ProductAttributeGroupMember__c>();
        listAttrProductJunction = [SELECT Id, Name, Apttus_Config2__Sequence__c, Apttus_Config2__ProductId__c, Apttus_Config2__AttributeGroupId__c FROM Apttus_Config2__ProductAttributeGroupMember__c WHERE Apttus_Config2__ProductId__r.Name =: proposalData.Product_Name__c LIMIT 1];
        system.debug('@@@@listAttrProductJunction'+listAttrProductJunction );
        listAttr = new List<Apttus_Config2__ProductAttribute__c>();
        listAttr = [SELECT Id, Name, Apttus_Config2__Sequence__c, Apttus_Config2__Field__c, Apttus_Config2__IsReadOnly__c FROM Apttus_Config2__ProductAttribute__c WHERE Apttus_Config2__AttributeGroupId__c =: listAttrProductJunction[0].Apttus_Config2__AttributeGroupId__c ORDER By  Apttus_Config2__Sequence__c];  
        system.debug('@@@@listAttr'+listAttr );
        
        //added to create custom order of the product attributes for MIS
        if(proposalData.Product_Name__c == 'AT&T Managed Internet Service'){
            listAttr = reorderMISProductAttributes(listAttr);
        }
        else if(proposalData.Product_Name__c == 'AT&T Virtual Private Network'){
            listAttr = reorderAVPNProductAttributes(listAttr);
        }
        
        sObj = listAttrVal;
        numberOfOptions = listAttr.size();
        if( !isSitereview ){
            isConfigSiteModeOn = true;
        }else{        
            isConfigSiteModeOn = false;
        }
        
        if( selectedSiteInfo.phone__c != null ){
            selectedSitePhone = selectedSiteInfo.phone__c;
        }
        else{
            selectedSitePhone ='';
        }        
    }
    
    public List<Apttus_Config2__ProductAttribute__c> reorderMISProductAttributes(List<Apttus_Config2__ProductAttribute__c> lstProdAttr){
        List<Apttus_Config2__ProductAttribute__c> tempLstAttr = new List<Apttus_Config2__ProductAttribute__c>();
        integer installationOptSequence;
        integer accessSpeedSequence;
        for(Apttus_Config2__ProductAttribute__c attr : lstProdAttr){
            if(attr.Apttus_Config2__Field__c == 'Install_Option_MIS__c'){
                installationOptSequence = integer.valueOf(attr.Apttus_Config2__Sequence__c);
            }
        }
        
        integer i = 0;
        integer installationOptIndex = installationOptSequence - 1;
        for(Apttus_Config2__ProductAttribute__c attr : lstProdAttr){
            if(i != installationOptIndex){
                tempLstAttr.add(attr);
            }
            if(attr.Apttus_Config2__Field__c == 'Additional_DNS__c'){
                tempLstAttr.add(lstProdAttr[installationOptIndex]);
            }
            i++;
        }
        return tempLstAttr;        
    }
   
    public List<Apttus_Config2__ProductAttribute__c> reorderAVPNProductAttributes(List<Apttus_Config2__ProductAttribute__c> lstProdAttr){
        List<Apttus_Config2__ProductAttribute__c> tempLstAttr = new List<Apttus_Config2__ProductAttribute__c>();
        integer installationOptSequence;
        integer accessSpeedSequence;
        for(Apttus_Config2__ProductAttribute__c attr : lstProdAttr){
            if(attr.Apttus_Config2__Field__c == 'Install_Option_AVPN__c'){
                installationOptSequence = integer.valueOf(attr.Apttus_Config2__Sequence__c);
            }
        }
        
        integer i = 0;
        integer installationOptIndex = installationOptSequence - 1;
        for(Apttus_Config2__ProductAttribute__c attr : lstProdAttr){
            if(i != installationOptIndex){
                tempLstAttr.add(attr);
            }
            if(attr.Apttus_Config2__Field__c == 'Interface_Type_AVPN__c'){
                tempLstAttr.add(lstProdAttr[installationOptIndex]);
            }
            i++;
        }
        return tempLstAttr;        
    }
    
    public void createLiteItemOnSiteSelection(String ConfigRecId, String ProductID, String SelectedSite){
        lineItems = [SELECT Id, Apttus_Config2__BasePrice__c,Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=:cartId AND AT_T_Customer_Site__c =: selectedSiteId];
        if(lineItems.size() == 0){
            Apttus_CPQApi.CPQ.AddMultiProductRequestDO request = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO();
            request.CartId = cartId;
            Apttus_CPQApi.CPQ.SelectedProductDO newProd = new Apttus_CPQApi.CPQ.SelectedProductDO();
            newProd.ProductId = ProductID;
            newProd.Quantity = 1;
            newProd.SellingTerm = 1;
            newProd.StartDate = System.today();
            newProd.EndDate = System.today()+2;
            request.SelectedProducts.add(newProd);
            Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(request);
            List<Decimal> LineItemNumberList=response.LineNumbers;
            List<Apttus_Config2__LineItem__c> lineItemList=[Select Id,Apttus_Config2__PricingStatus__c,AT_T_Customer_Site__c,AT_T_Customer_Site__r.Id,Apttus_Config2__LineNumber__c,Apttus_Config2__ChargeType__c,Apttus_Config2__PrimaryLineNumber__c from Apttus_Config2__LineItem__c where Apttus_Config2__PrimaryLineNumber__c=:response.LineNumbers and Apttus_Config2__ConfigurationId__c=:cartId];
            List<Apttus_Config2__LineItem__c> liteItemUpdated;
            for(Apttus_Config2__LineItem__c lineitem :lineItemList){
                lineitem.AT_T_Customer_Site__c=SelectedSite;
                lineitem.Apttus_Config2__LineNumber__c=lineItemList[0].Apttus_Config2__PrimaryLineNumber__c;
            }
            ATT_Constant.isRecurcive=true;
            update lineItemList;
        }  
    }
    
    public list<Integer> createLiteItemOnApply(String ConfigRecId, String ProductID, String SelectedSite, list<QuoteProducts.cCustomerSite> siteLstNeedsToBeAdded ){
        List <Apttus_CPQApi.CPQ.SelectedProductDO> selectedProdDOList = new List <Apttus_CPQApi.CPQ.SelectedProductDO>();
        Apttus_CPQApi.CPQ.AddMultiProductRequestDO request = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO();
        request.CartId = ConfigRecId;
        for( QuoteProducts.cCustomerSite products : siteLstNeedsToBeAdded ) {
            Apttus_CPQApi.CPQ.SelectedProductDO newProd = new Apttus_CPQApi.CPQ.SelectedProductDO();
            newProd.ProductId = ProductID;
            newProd.Quantity = 1;
            newProd.SellingTerm = 1;
            newProd.StartDate = System.today();
            newProd.EndDate = System.today()+2;
            selectedProdDOList.add(newProd);
        }
            
        request.SelectedProducts = selectedProdDOList;
        Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(request);
        List<Integer> LineItemNumberList= new List<Integer>();
        for( Decimal lNum : response.LineNumbers ){     
            LineItemNumberList.add(Integer.valueOf(lNum));
        }
        return LineItemNumberList;        
    }
    
    /******************************************************************
    * Method name : checkExistenceAndInitializeCartLineItemsAndSelectedSiteDefault
    * Description :  
    * Return Type : Null
    * Parameters  : None.
    *******************************************************************/      
    public void checkExistenceAndInitializeCartLineItemsAndSelectedSiteDefault(){       
        List<Apttus_Config2__ProductConfiguration__c> listExistingCart = new List<Apttus_Config2__ProductConfiguration__c>();
        listExistingCart = [SELECT Id, Name,Apttus_Config2__Status__c, Apttus_QPConfig__Proposald__c FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c =:quoteId ];
        if(ApexPages.currentPage().getParameters().get('siteid') != null){
            selectedSiteId = ApexPages.currentPage().getParameters().get('siteid');  
        }
        if( listExistingCart != null && listExistingCart.size() > 0 ){
            configData = [SELECT Id, Name, Apttus_QPConfig__Proposald__c FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c =:quoteId LIMIT 1];
            lineItems = [SELECT Id, Apttus_Config2__BasePrice__c,Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__r.Id, Apttus_Config2__LineNumber__c, AT_T_Customer_Site__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=:configData.Id AND Apttus_Config2__ChargeType__c = null];
        }
        if(ApexPages.currentPage().getParameters().get('siteid') != null){
            selectedSiteId = ApexPages.currentPage().getParameters().get('siteid'); 
        }else{    
            if(lineItems != null && lineItems.size() > 0){
                if(getCustomerSiteLst() != null && getCustomerSiteLst().size() > 0){
                    selectedSiteId = getCustomerSiteLst()[0].Id;
                }
                lineItems[0].AT_T_Customer_Site__c = selectedSiteId;
                update lineItems[0];
            }else{            
                if(selectedSiteId == null || String.isEmpty(selectedSiteId)){
                    if(getCustomerSiteLst() != null && getCustomerSiteLst().size() >0){
                        selectedSiteId = getCustomerSiteLst()[0].Id;
                    }
                } 
            }                
        }
    }
    
    /******************************************************************
    * Method name : wrapperDataS
    * Description :  
    * Return Type : Null
    * Parameters  : None.
    *******************************************************************/          
     public class wrapperDataS{    
        public String attr {get;set;}
        public Apttus_Config2__LineItem__c lineItemObj {get;set;}
        public Boolean isPricable {get;set;}
        public Boolean isShown {get;set;}
        public wrapperDataS(String token, Apttus_Config2__LineItem__c lineItemOb, Boolean isPriceON, Boolean isVisible ){
            attr = token;
            lineItemObj = lineItemOb;
            isPricable = isPriceON;
            isShown = isVisible;
        }
    }
        
    /******************************************************************
    * Method name : calculateAccessSpeedFeeTotal
    * Description :  
    * Return Type : Decimal
    * Parameters  : List<Apttus_Config2__LineItem__c>
    *******************************************************************/  
    public decimal calculateAccessSpeedFeeTotal( List<Apttus_Config2__LineItem__c> listItems ){
        Decimal accessTotalFee = 0.00;        
        for( Apttus_Config2__LineItem__c eachLineItem : listItems ){
            if( eachLineItem.Apttus_Config2__ChargeType__c != null && eachLineItem.Apttus_Config2__ChargeType__c.containsIgnoreCase('Access Speed')){                
                accessTotalFee += eachLineItem.Apttus_Config2__NetPrice__c.setScale(2);
            }        
        }
        return accessTotalFee;
    }    
    
    /******************************************************************
    * Method name : calculateAccessSpeedFeeOriginal
    * Description :  
    * Return Type : Decimal
    * Parameters  : List<Apttus_Config2__LineItem__c>
    *******************************************************************/  
    public decimal calculateAccessSpeedFeeOriginal( List<Apttus_Config2__LineItem__c> listItems ){
        
        Decimal accessOriginalFee = 0.00;
        for( Apttus_Config2__LineItem__c eachLineItem : listItems ){
            if( eachLineItem.Apttus_Config2__ChargeType__c != null && eachLineItem.Apttus_Config2__ChargeType__c.containsIgnoreCase('Access Speed')){                
                if(eachLineItem.Original_Net_Price__c != null){
                    accessOriginalFee +=eachLineItem.Original_Net_Price__c.setScale(2);
                }
            }        
        }
        return accessOriginalFee;
    }

    /******************************************************************
    * Method name : getMonthlyAmount
    * Description :  
    * Return Type : Decimal
    * Parameters  : String, String, String
    *******************************************************************/     
    public Decimal getMonthlyAmount(String selectedMBCwithMBps,String chargeType,String Description){
        if(isIglooExpired){return 0.0;}
        try{
            List<Apttus_Proposal__Proposal__c>quoteObjCheck = [select Id,Name,MACD_Change_Type__c,Apttus_QPConfig__PriceListId__r.Id, Opportunity_Owner_Email__c, Docusign_Envelope__c, Denial_Reason__c, Contract_Read__c, End_Customer__c, Contract_Signed__c, End_Customer__r.Name,End_Customer__r.Mailing_Street_Address__c,End_Customer__r.City__c, Product__r.name, End_Customer__r.Zip__c,End_Customer__r.State__c, Apttus_Proposal__Payment_Term__c, Apttus_Proposal__Proposal_Name__c,Product_Name__c, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where id = :quoteId];
            list<Apttus_Config2__PriceMatrixEntry__c> matrixEntryList = [ select Id,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id , Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__PeriodEndDate__c from Apttus_Config2__PriceMatrixEntry__c where  (Apttus_Config2__Dimension1Value__c =:selectedMBCwithMBps  and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ChargeType__c =:chargeType and Description_PL__c =:Description and  Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id =:quoteObjCheck[0].Apttus_QPConfig__PriceListId__r.Id and  Apttus_Config2__PeriodEndDate__c=null) ];
            if( matrixEntryList.size() > 0 ){                   
                for( Apttus_Config2__PriceMatrixEntry__c priceMatrix : matrixEntryList  ){
                    amount = priceMatrix.Apttus_Config2__AdjustmentAmount__c; // Returning only amount witho discount.
                }
            }
            else{
                return 0.0;
            }                
            return amount;
        }  
        catch(Exception ex){
            system.debug('Exception in getMonthlyAmount method: '+ex);
            return null;
        }
    }

    /******************************************************************
    * Method name : getMonthlyDnsAmount
    * Description :  
    * Return Type : Decimal
    * Parameters  : String, String, String
    *******************************************************************/     
    public Decimal getMonthlyDnsAmount(String dnsval,String chargeType,String Description){
        if(isIglooExpired){return 0.0;}
        try{ 
            List<Apttus_Proposal__Proposal__c>quoteObj = [select Id,Name,MACD_Change_Type__c,Apttus_QPConfig__PriceListId__r.Id, Opportunity_Owner_Email__c, Docusign_Envelope__c, Denial_Reason__c, Contract_Read__c, End_Customer__c, Contract_Signed__c, End_Customer__r.Name,End_Customer__r.Mailing_Street_Address__c,End_Customer__r.City__c, Product__r.name, End_Customer__r.Zip__c,End_Customer__r.State__c, Apttus_Proposal__Payment_Term__c, Apttus_Proposal__Proposal_Name__c,Product_Name__c, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where id = :quoteId];
            list<Apttus_Config2__PriceMatrixEntry__c> matrixEntryList = [ select Id,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id , Apttus_Config2__AdjustmentAmount__c, Apttus_Config2__PeriodEndDate__c from Apttus_Config2__PriceMatrixEntry__c where  (Apttus_Config2__Dimension1Value__c =:dnsval  and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ChargeType__c =:chargeType and Description_PL__c =:Description and  Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id =:quoteObj[0].Apttus_QPConfig__PriceListId__r.Id and  Apttus_Config2__PeriodEndDate__c=null) ];
            if( matrixEntryList.size() > 0 ){                   
                for( Apttus_Config2__PriceMatrixEntry__c priceMatrix : matrixEntryList  ){                       
                    amount = priceMatrix.Apttus_Config2__AdjustmentAmount__c; 
                }
            }
            else {
                return 0.0;
            }                
            return amount;
        }  
        catch(Exception ex){
            system.debug('Exception in getMonthlyAmount method: '+ex);
            apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in getMonthlyAmount method: '+ex));
            return null;
        }   
    }
    
    /******************************************************************
    * Method name : getOneTimePrice
    * Description :  
    * Return Type : Decimal
    * Parameters  : String, String, String
    *******************************************************************/     
    public Decimal getOneTimePrice(String productCode,String portSpeed,String installationOption,Boolean managedRouter){
        if(isIglooExpired){return 0.0;}
        try{ 
            List<Apttus_Proposal__Proposal__c>quoteObj = [select Id,Name,MACD_Change_Type__c,Apttus_QPConfig__PriceListId__r.Id, Opportunity_Owner_Email__c, Docusign_Envelope__c, Denial_Reason__c, Contract_Read__c, End_Customer__c, Contract_Signed__c, End_Customer__r.Name,End_Customer__r.Mailing_Street_Address__c,End_Customer__r.City__c, Product__r.name, End_Customer__r.Zip__c,End_Customer__r.State__c, Apttus_Proposal__Payment_Term__c, Apttus_Proposal__Proposal_Name__c,Product_Name__c, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where id = :quoteId];
            list<Apttus_Config2__PriceMatrixEntry__c> matrixEntryList = new list<Apttus_Config2__PriceMatrixEntry__c>();
            if(productCode == 'AVPN'){
                matrixEntryList = [select Id,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id,Apttus_Config2__AdjustmentAmount__c,Apttus_Config2__PeriodEndDate__c,Apttus_Config2__Dimension1Value__c,Apttus_Config2__Dimension2Value__c,Description_PL__c from Apttus_Config2__PriceMatrixEntry__c where (Apttus_Config2__Dimension1Value__c =:installationOption and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ChargeType__c ='One Time Fee' and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id =:quoteObj[0].Apttus_QPConfig__PriceListId__r.Id and Apttus_Config2__PeriodEndDate__c=null)];
                system.debug('@@@matrixEntryList -- AVPN: '+matrixEntryList);
            }else if(productCode == 'MIS'){
                if(managedRouter == true){
                    matrixEntryList = [select Id,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id,Apttus_Config2__AdjustmentAmount__c,Apttus_Config2__PeriodEndDate__c,Apttus_Config2__Dimension1Value__c,Apttus_Config2__Dimension2Value__c,Description_PL__c from Apttus_Config2__PriceMatrixEntry__c where (Apttus_Config2__Dimension1Value__c =:portSpeed and Apttus_Config2__Dimension2Value__c =:installationOption and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ChargeType__c ='One Time Fee' and Description_PL__c like '%MIS with Managed Router%' and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id =:quoteObj[0].Apttus_QPConfig__PriceListId__r.Id and Apttus_Config2__PeriodEndDate__c=null)];
                    system.debug('@@@matrixEntryList -- MIS Managed: '+matrixEntryList);
                }else{
                    matrixEntryList = [select Id,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id,Apttus_Config2__AdjustmentAmount__c,Apttus_Config2__PeriodEndDate__c,Apttus_Config2__Dimension1Value__c,Apttus_Config2__Dimension2Value__c,Description_PL__c from Apttus_Config2__PriceMatrixEntry__c where (Apttus_Config2__Dimension1Value__c =:portSpeed and Apttus_Config2__Dimension2Value__c =:installationOption and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ChargeType__c ='One Time Fee' and Description_PL__c = 'Tele Install Fee' and Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Id =:quoteObj[0].Apttus_QPConfig__PriceListId__r.Id and Apttus_Config2__PeriodEndDate__c=null)];
                    system.debug('@@@matrixEntryList -- MIS Unmanaged: '+matrixEntryList);
                }
            }
            if(matrixEntryList.size() > 0){                   
                for(Apttus_Config2__PriceMatrixEntry__c priceMatrix : matrixEntryList){                       
                    amount = priceMatrix.Apttus_Config2__AdjustmentAmount__c; 
                }
            }
            else{
                return 0.0;
            }                
            return amount;
        }  
        catch(Exception ex){
            system.debug('Exception in getOneTimePrice method: '+ex);
            return null;
        }   
    }
    
    /******************************************************************
    * Method name : getLatestOverragePrice
    * Description :  
    * Return Type : Decimal
    * Parameters  : String, String
    *******************************************************************/       
    public decimal getLatestOverragePrice(String selectedMBCwithMBps,String ProductCode){ 
        if(isIglooExpired){return 0.0;} 
        String speed= selectedMBCwithMBps.deleteWhitespace(); 
        decimal amount; 
        amount=0.00; 
        List<Apttus_Proposal__Proposal__c> quoteObj = new List<Apttus_Proposal__Proposal__c>();
        quoteObj.add(proposalObject);
        list<OverragePrice__c> overrageList = [SELECT Master_Agent__c,Name,OwnerId,Platinum_Elite__c,Platinum__c,ProductCode__c,RateEffectiveDate__c,RateExpiredDate__c,Speeds__c,Term__c FROM OverragePrice__c where Speeds__c=:speed and ProductCode__c=:ProductCode  and Term__c=:quoteObj[0].Term__c and   RateExpiredDate__c=null]; 
        String tier=''; 
        if(quoteObj[0].Apttus_Proposal__Account__r.Master_Agent__c){ 
            tier=SIConstants.TIERSILVER; 
        } 
        else{ 
            tier=quoteObj[0].Apttus_Proposal__Account__r.Current_Tier__c; 
        } 
        if(overrageList.size()>0){ 
            if(tier==SIConstants.TIERSILVER){ 
                amount = Double.valueOf(overrageList[0].Master_Agent__c); 
            } 
            else if(tier=='Platinum Elite' || tier==SIConstants.TIERGOLD){ 
                amount =  Double.valueOf(overrageList[0].Platinum_Elite__c); // Returning only amount witho discount. 
            } 
            else if(tier==SIConstants.TIERPLATINUM || tier=='Basic'){ 
                amount =  Double.valueOf(overrageList[0].Platinum__c); // Returning only amount witho discount. 
            } 
        }else{ 
            return 0.0; 
        } 
        return amount.setScale(2); 
    }
        
    public void initializeData(){
        system.debug('@@@^initializeData');
        boolean isIglooExpired=false;
        if(selectedSiteId!=null){
        lineItems = [SELECT Id,Project_Id__c,UBBOveragePrice__c,Product_Code__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__ExtendedPrice__c,AT_T_Customer_Site__r.Id , Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__ListPrice__c,AdditionalDnsType__c,Port_Speed__c, MBC_Speed__c,Apttus_Config2__BasePrice__c,Apttus_Config2__AttributeValueId__r.VLANs_Logical_Channels__c, isPricingApplied__c, Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c,Apttus_Config2__AttributeValueId__r.Additional_DNS__c,Apttus_Config2__AttributeValueId__r.CoS__c,Apttus_Config2__AttributeValueId__r.Access_Type_AVPN__c,Apttus_Config2__AttributeValueId__r.Access_Type__c,Apttus_Config2__AttributeValueId__r.Managed_Router__c,Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c,Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c,Apttus_Config2__AttributeValueId__r.Install_Option_AVPN__c,Apttus_Config2__AttributeValueId__r.Install_Option_MIS__c,Apttus_Config2__AttributeValueId__r.IP_Flex_Error__c, Apttus_Config2__AttributeValueId__r.IGLOO_Retrial_Failure_Count__c, Apttus_Config2__AttributeValueId__r.IGLOO_Call_Failure__c, Apttus_Config2__AttributeValueId__r.IGLOO_Speed_Unavailable__c,Original_Net_Price__c,Wireline_Promotion_Discount_Percentage__c,WP_Hidden_Discount_Percentage__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=:cartId AND AT_T_Customer_Site__c =: selectedSiteId];
            for(AT_T_Customer_Site_Quote__c junctObjList:[select id,Iglow_Response_Received_Date__c,Project_ID__c,AT_T_Quote__c,AT_T_Customer_Site__c from  AT_T_Customer_Site_Quote__c where AT_T_Quote__c =:quoteid and AT_T_Customer_Site__c =:selectedSiteId ]){                                                     
                if(junctObjList.AT_T_Customer_Site__c!=null ){                  
                    if(lineItems!=null && lineItems.size()>0 && ((lineItems[0].Apttus_Config2__AttributeValueId__r.Access_Type_AVPN__c!=null && lineItems[0].Apttus_Config2__AttributeValueId__r.Access_Type_AVPN__c.equalsIgnoreCase('Switched Ethernet'))||(lineItems[0].Apttus_Config2__AttributeValueId__r.Access_Type__c!=null && lineItems[0].Apttus_Config2__AttributeValueId__r.Access_Type__c.equalsIgnoreCase('Switched Ethernet')) )){
                        if(junctObjList.Iglow_Response_Received_Date__c!=null && junctObjList.Iglow_Response_Received_Date__c.daysBetween(system.now().date())> 90 && !isASE){
                            isIglooExpired=true;
                        }
                    }
                    mapJunction.put(junctObjList.AT_T_Customer_Site__c,junctObjList.Project_ID__c);                
                }
            }
        }
        
        List<Apttus_Config2__LineItem__c>  lineItemsTotal = new List<Apttus_Config2__LineItem__c> (); 
        if(!isIglooExpired){
            for(Apttus_Config2__LineItem__c linitem:lineItems){             
                if(!mapJunction.IsEmpty()){
                    linitem.Project_Id__c=mapJunction.get(linitem.AT_T_Customer_Site__c);
                }
           
                if((linitem.Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c && linitem.Apttus_Config2__AttributeValueId__r.IP_Flex_Error__c) || (linitem.Apttus_Config2__AttributeValueId__r.IGLOO_Retrial_Failure_Count__c > 0 && linitem.Apttus_Config2__AttributeValueId__r.IGLOO_Call_Failure__c == true) || linitem.Apttus_Config2__AttributeValueId__r.IGLOO_Speed_Unavailable__c == true || (String.isNotBlank(linitem.Apttus_Config2__ChargeType__c) && (linitem.Apttus_Config2__ChargeType__c.equalsIgnoreCase('CoS Fee') && linitem.Product_Code__c != 'ASE'))){
                    if(linitem.AT_T_Customer_Site__r.Id==selectedSiteId){                        
                        linitem.Original_Net_Price__c = linitem.Apttus_Config2__NetPrice__c = linitem.Apttus_Config2__ListPrice__c = linitem.Apttus_Config2__BasePrice__c = linitem.Apttus_Config2__BaseExtendedPrice__c = linitem.Apttus_Config2__AdjustedPrice__c = linitem.Apttus_Config2__ExtendedPrice__c = 0.00;
                    }
                }
                else{
                    if(linitem.Apttus_Config2__ChargeType__c == 'Port Speed Fee' && isASE ==false && LinItem.isPricingApplied__c){
                        if(linitem.AT_T_Customer_Site__r.Id==selectedSiteId){
                            if(!linitem.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c && !linitem.Apttus_Config2__AttributeValueId__r.Managed_Router__c && !linitem.Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c){
                                linitem.Original_Net_Price__c = (linitem.Wireline_Promotion_Discount_Percentage__c != null && linitem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? getMonthlyAmount(linitem.Port_Speed__c,linitem.Apttus_Config2__ChargeType__c,'Port Speed Charge') : null;
                                linitem.Apttus_Config2__NetPrice__c = (linitem.Wireline_Promotion_Discount_Percentage__c != null && linitem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? ((100-linitem.Wireline_Promotion_Discount_Percentage__c) * 0.01 * getMonthlyAmount(linitem.Port_Speed__c,linitem.Apttus_Config2__ChargeType__c,'Port Speed Charge')).setscale(2) : getMonthlyAmount(linitem.Port_Speed__c,linitem.Apttus_Config2__ChargeType__c,'Port Speed Charge'); 
                                linitem.Apttus_Config2__ListPrice__c = linitem.Apttus_Config2__BasePrice__c = linitem.Apttus_Config2__BaseExtendedPrice__c = linitem.Apttus_Config2__AdjustedPrice__c = linitem.Apttus_Config2__ExtendedPrice__c = linitem.Apttus_Config2__NetPrice__c;
                                system.debug('@@@Inside 1: After Net Price: '+linitem.Apttus_Config2__NetPrice__c + ' Original Price: ' + linitem.Original_Net_Price__c);
                            } 
                            else if(!linitem.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c && !linitem.Apttus_Config2__AttributeValueId__r.Managed_Router__c && linitem.Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c){
                                linitem.Original_Net_Price__c = (linitem.Wireline_Promotion_Discount_Percentage__c != null && linitem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? getMonthlyAmount(linitem.Port_Speed__c,linitem.Apttus_Config2__ChargeType__c,'Port Speed Charge') : null;  
                                linitem.Apttus_Config2__NetPrice__c = (linitem.Wireline_Promotion_Discount_Percentage__c != null && linitem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? ((100-linitem.Wireline_Promotion_Discount_Percentage__c) * 0.01 * getMonthlyAmount(linitem.Port_Speed__c,linitem.Apttus_Config2__ChargeType__c,'Port Speed Charge')).setscale(2) : getMonthlyAmount(linitem.Port_Speed__c,linitem.Apttus_Config2__ChargeType__c,'Port Speed Charge'); 
                                linitem.Apttus_Config2__ListPrice__c = linitem.Apttus_Config2__BasePrice__c = linitem.Apttus_Config2__BaseExtendedPrice__c = linitem.Apttus_Config2__AdjustedPrice__c = linitem.Apttus_Config2__ExtendedPrice__c = linitem.Apttus_Config2__NetPrice__c;  
                                system.debug('@@@Inside 2: Net Price: '+linitem.Apttus_Config2__NetPrice__c + ' Original Price: ' + linitem.Original_Net_Price__c);
                            }
                            else if(linitem.Apttus_Config2__AttributeValueId__r.Managed_Router__c && !linitem.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c ){
                                linitem.Original_Net_Price__c = (linitem.Wireline_Promotion_Discount_Percentage__c != null && linitem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? getMonthlyAmount(linitem.Port_Speed__c,linitem.Apttus_Config2__ChargeType__c,'MIS Plus Port') : null;
                                linitem.Apttus_Config2__NetPrice__c = (linitem.Wireline_Promotion_Discount_Percentage__c != null && linitem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? ((100-linitem.Wireline_Promotion_Discount_Percentage__c) * 0.01 * getMonthlyAmount(linitem.Port_Speed__c,linitem.Apttus_Config2__ChargeType__c,'MIS Plus Port')).setscale(2) : getMonthlyAmount(linitem.Port_Speed__c,linitem.Apttus_Config2__ChargeType__c,'MIS Plus Port'); 
                                linitem.Apttus_Config2__ListPrice__c = linitem.Apttus_Config2__BasePrice__c = linitem.Apttus_Config2__BaseExtendedPrice__c = linitem.Apttus_Config2__AdjustedPrice__c = linitem.Apttus_Config2__ExtendedPrice__c = linitem.Apttus_Config2__NetPrice__c; 
                                system.debug('@@@Inside 3: Net Price: '+linitem.Apttus_Config2__NetPrice__c + ' Original Price: ' + linitem.Original_Net_Price__c);
                            }
                            else if(linitem.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c && !linitem.Apttus_Config2__AttributeValueId__r.Managed_Router__c) {
                                linitem.Original_Net_Price__c = (linitem.Wireline_Promotion_Discount_Percentage__c != null && linitem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? getMonthlyAmount(linitem.MBC_Speed__c,linitem.Apttus_Config2__ChargeType__c,'UBB Charge'): null;
                                linitem.Apttus_Config2__NetPrice__c = (linitem.Wireline_Promotion_Discount_Percentage__c != null && linitem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? ((100-linitem.Wireline_Promotion_Discount_Percentage__c) * 0.01 * getMonthlyAmount(linitem.MBC_Speed__c,linitem.Apttus_Config2__ChargeType__c,'UBB Charge')).setscale(2) : getMonthlyAmount(linitem.MBC_Speed__c,linitem.Apttus_Config2__ChargeType__c,'UBB Charge');    
                                linitem.Apttus_Config2__ListPrice__c = linitem.Apttus_Config2__BasePrice__c = linitem.Apttus_Config2__BaseExtendedPrice__c = linitem.Apttus_Config2__AdjustedPrice__c = linitem.Apttus_Config2__ExtendedPrice__c = linitem.Apttus_Config2__NetPrice__c;   
                                system.debug('@@@Inside 4: Net Price: '+linitem.Apttus_Config2__NetPrice__c + ' Original Price: ' + linitem.Original_Net_Price__c);
                            } 
                            else if(linitem.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c && linitem.Apttus_Config2__AttributeValueId__r.Managed_Router__c) {
                                linitem.Original_Net_Price__c = (linitem.Wireline_Promotion_Discount_Percentage__c != null && linitem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? getMonthlyAmount(linitem.MBC_Speed__c,linitem.Apttus_Config2__ChargeType__c,'MIS Plus with Minimum Bandwidth Commitment') : null;   
                                linitem.Apttus_Config2__NetPrice__c = (linitem.Wireline_Promotion_Discount_Percentage__c != null && linitem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? ((100-linitem.Wireline_Promotion_Discount_Percentage__c) * 0.01 * getMonthlyAmount(linitem.MBC_Speed__c,linitem.Apttus_Config2__ChargeType__c,'MIS Plus with Minimum Bandwidth Commitment')).setscale(2) : getMonthlyAmount(linitem.MBC_Speed__c,linitem.Apttus_Config2__ChargeType__c,'MIS Plus with Minimum Bandwidth Commitment');    
                                linitem.Apttus_Config2__ListPrice__c = linitem.Apttus_Config2__BasePrice__c = linitem.Apttus_Config2__BaseExtendedPrice__c = linitem.Apttus_Config2__AdjustedPrice__c = linitem.Apttus_Config2__ExtendedPrice__c = linitem.Apttus_Config2__NetPrice__c;  
                                system.debug('@@@Inside 5: Net Price: '+linitem.Apttus_Config2__NetPrice__c + ' Original Price: ' + linitem.Original_Net_Price__c);
                            }
                        }     
                    }
                    if(LinItem.Apttus_Config2__ChargeType__c == 'VLAN(s)/Logical Channel' && LinItem.isPricingApplied__c){
                         linitem.Original_Net_Price__c = (linitem.Wireline_Promotion_Discount_Percentage__c != null && linitem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? getMonthlyAmount(LinItem.Port_Speed__c,LinItem.Apttus_Config2__ChargeType__c,'VLAN(s)/Logical Channel Fee'): null;
                         linItem.Apttus_Config2__NetPrice__c = (linitem.Wireline_Promotion_Discount_Percentage__c != null && linitem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? ((100-linitem.Wireline_Promotion_Discount_Percentage__c) * 0.01 * getMonthlyAmount(LinItem.Port_Speed__c,LinItem.Apttus_Config2__ChargeType__c,'VLAN(s)/Logical Channel Fee')).setscale(2) : getMonthlyAmount(LinItem.Port_Speed__c,LinItem.Apttus_Config2__ChargeType__c,'VLAN(s)/Logical Channel Fee');
                         linitem.Apttus_Config2__ListPrice__c = linitem.Apttus_Config2__BasePrice__c = linitem.Apttus_Config2__BaseExtendedPrice__c = linitem.Apttus_Config2__AdjustedPrice__c = linitem.Apttus_Config2__ExtendedPrice__c = linitem.Apttus_Config2__NetPrice__c;  
                         system.debug('@@@Inside 6: Net Price: '+linitem.Apttus_Config2__NetPrice__c + ' Original Price: ' + linitem.Original_Net_Price__c);
                    }
                    if(LinItem.Apttus_Config2__ChargeType__c == 'Additional DNS Fee' && LinItem.isPricingApplied__c){
                        linitem.Original_Net_Price__c = (linitem.Wireline_Promotion_Discount_Percentage__c != null && linitem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? getMonthlyDnsAmount(LinItem.AdditionalDnsType__c,LinItem.Apttus_Config2__ChargeType__c,'Additional DNS Fee') : null;
                        linItem.Apttus_Config2__NetPrice__c = (linitem.Wireline_Promotion_Discount_Percentage__c != null && linitem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? ((100-linitem.Wireline_Promotion_Discount_Percentage__c) * 0.01 * getMonthlyDnsAmount(LinItem.AdditionalDnsType__c,LinItem.Apttus_Config2__ChargeType__c,'Additional DNS Fee')).setscale(2) : getMonthlyDnsAmount(LinItem.AdditionalDnsType__c,LinItem.Apttus_Config2__ChargeType__c,'Additional DNS Fee');  
                        linitem.Apttus_Config2__ListPrice__c = linitem.Apttus_Config2__BasePrice__c = linitem.Apttus_Config2__BaseExtendedPrice__c = linitem.Apttus_Config2__AdjustedPrice__c = linitem.Apttus_Config2__ExtendedPrice__c = linitem.Apttus_Config2__NetPrice__c;  
                        system.debug('@@@Inside 7: Net Price: '+linitem.Apttus_Config2__NetPrice__c + ' Original Price: ' + linitem.Original_Net_Price__c); 
                    }
                    if(LinItem.Apttus_Config2__ChargeType__c == 'One Time Fee' && LinItem.isPricingApplied__c){
                        if(linItem.Product_Code__c == 'AVPN'){
                            linItem.Apttus_Config2__NetPrice__c = getOneTimePrice('AVPN',LinItem.Port_Speed__c,linItem.Apttus_Config2__AttributeValueId__r.Install_Option_AVPN__c,linitem.Apttus_Config2__AttributeValueId__r.Managed_Router__c);
                        }else if(linItem.Product_Code__c == 'AMIS'){
                            linItem.Apttus_Config2__NetPrice__c = getOneTimePrice('MIS',LinItem.Port_Speed__c,linItem.Apttus_Config2__AttributeValueId__r.Install_Option_MIS__c,linitem.Apttus_Config2__AttributeValueId__r.Managed_Router__c);
                        }
                    }
                }
            }
            if(lineItems.size()>0){
                if(!Test.isRunningTest()){   
                    update lineItems;
                }
            }
        }
        
        Apttus_Proposal__Proposal__c proposalToUpdate = new Apttus_Proposal__Proposal__c(Id=quoteId);
        if(proposalToUpdate.Rate_Card_Effective_Date__c!=null && proposalToUpdate.Rate_Card_Effective_Date__c!=''){
            proposalToUpdate.Rate_Card_Effective_Date__c=helper.getQuoteEffectiveDate(quoteId);
            Update proposalToUpdate ;
        }
    
        lineItemsTotal = [SELECT Id, Apttus_Config2__BasePrice__c,Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c,Original_Net_Price__c,Wireline_Promotion_Discount_Percentage__c,WP_Hidden_Discount_Percentage__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=:cartId];
        System.debug('@@@@'+lineItems);
        decimal accessTotal = calculateAccessSpeedFeeTotal(lineItems);
        decimal accessOriginalFee = calculateAccessSpeedFeeOriginal(lineItems);
        
        if(lineItemsTotal!=null && lineItems!=null && lineItems.size()>0){
            String strSoql;
            if(isAVPN || isMIS){
                strSoql = 'SELECT Id,ProductName__c,IP_Flex_Error__c,IGLOO_Port_Speed_Substituted__c, IGLOO_Access_Speed_Substituted__c, IGLOO_Interface_Type_Substituted__c, IGLOO_Speed_Unavailable__c, IGLOO_Old_Port_Speed__c, IGLOO_Old_Access_Speed__c, IGLOO_Old_Interface_Type__c, Alternate_Access_IGLOO_Interface_Code__c, Alternate_Access_IGLOO_Access_Price__c, Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c, Igloo_Call_Processing_Complete__c, AT_T_Customer_Site__c, Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Payment_Term__c, IGLOO_Retrial_Failure_Count__c, IGLOO_Call_Failure__c, Quote_Total_Failure_Count__c, IGLOO_Supplier_Name__c, Wireline_Promotion_Id__c, ';
                if(Test.isRunningTest()){
                    strSoql = 'SELECT Id,ProductName__c,Hi_Cap_Flex__c,IP_Flex_Error__c,IGLOO_Port_Speed_Substituted__c, IGLOO_Access_Speed_Substituted__c, IGLOO_Interface_Type_Substituted__c, IGLOO_Speed_Unavailable__c, IGLOO_Old_Port_Speed__c, IGLOO_Old_Access_Speed__c, IGLOO_Old_Interface_Type__c, Alternate_Access_IGLOO_Interface_Code__c, Alternate_Access_IGLOO_Access_Price__c, Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__c, Igloo_Call_Processing_Complete__c, AT_T_Customer_Site__c, Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Payment_Term__c, IGLOO_Retrial_Failure_Count__c, IGLOO_Call_Failure__c, Quote_Total_Failure_Count__c, IGLOO_Supplier_Name__c, Wireline_Promotion_Id__c, ';
                }
            }
            else if(isASE){
                strSoql = 'SELECT ProductName__c, ';
            }
            Integer i = 0;
            for( Apttus_Config2__ProductAttribute__c itemAttr : listAttr ){
                if( i == 0 ){
                    strSoql += itemAttr.Apttus_Config2__Field__c;
                }else{
                    strSoql += ','+itemAttr.Apttus_Config2__Field__c;
                }
                i++;
            }
            strSoql += ' FROM Apttus_Config2__ProductAttributeValue__c WHERE id = \''+lineItems[0].Apttus_Config2__AttributeValueId__c+'\' LIMIT 1';
            System.debug('soql----'+strSoql);
            listAttrVal = database.query(strSoql);
            dataWrap = new List<wrapperDataS>();
            dataWrap.clear();
            totalPerCart = 0.0;
            totalPerSite = 0.0;
            sumOneTimeFee = 0.0;
            loadSoftDeletedSite();
           
            if(!isIglooExpired){
                for( Apttus_Config2__LineItem__c eachItem : lineItems ){            
                    if( eachItem.Apttus_Config2__NetPrice__c != null ){
                        if( eachItem.Apttus_Config2__ChargeType__c != 'One Time Fee' && eachItem.Apttus_Config2__ChargeType__c != 'Interface Type' && eachItem.isPricingApplied__c ){
                            totalPerSite += eachItem.Apttus_Config2__NetPrice__c;
                            system.debug('@@@inside totalPerSite: '+totalPerSite);
                        }
                    }
                }
    
                for( Apttus_Config2__LineItem__c eachItem : lineItemsTotal ){
                    if( eachItem.Apttus_Config2__NetPrice__c != null && eachItem.Apttus_Config2__ChargeType__c != 'One Time Fee' && eachItem.Apttus_Config2__ChargeType__c != 'Interface Type' && !softDeletedSitesmap.containsKey(eachItem.AT_T_Customer_Site__c)){
                        totalPerCart += eachItem.Apttus_Config2__NetPrice__c;
                        system.debug('@@@ inside totalPerCart: '+totalPerCart);
                    }
                    if( eachItem.Apttus_Config2__ChargeType__c == 'One Time Fee' && !softDeletedSitesmap.containsKey(eachItem.AT_T_Customer_Site__c)){
                       sumOneTimeFee += eachItem.Apttus_Config2__NetPrice__c;

                    }
                }
            }
            system.debug('@@@@totalPerSite: '+totalPerSite);
            system.debug('@@@@totalPerCart: '+totalPerCart);
          
            for( Apttus_Config2__ProductAttribute__c itemAttr : listAttr ){
                wrapperDataS dsObj;
                if(isASE == false){
                    if(itemAttr.Apttus_Config2__Field__c == 'Port_Speed_MIS__c' || itemAttr.Apttus_Config2__Field__c == 'Port_Speed_AVPN__c'){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), true, true);
                        if(listAttrVal.Hi_Cap_Flex__c){
                            dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c, new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), false, true);
                        }
                        system.debug('@@@lineItems: '+lineItems );
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){
                           if( eachLineItem.Apttus_Config2__ChargeType__c == 'Port Speed Fee'){
                                if(eachLineItem.Apttus_Config2__AttributeValueId__r.Managed_Router__c && !eachLineItem.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c){
                                    eachLineItem.Apttus_Config2__NetPrice__c = (eachLineItem.Wireline_Promotion_Discount_Percentage__c != null && eachLineItem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? ((100-eachLineItem.Wireline_Promotion_Discount_Percentage__c) * 0.01 * getMonthlyAmount(eachLineItem.Port_Speed__c,eachLineItem.Apttus_Config2__ChargeType__c,'MIS Plus Port')).setscale(2) : getMonthlyAmount(eachLineItem.Port_Speed__c,eachLineItem.Apttus_Config2__ChargeType__c,'MIS Plus Port'); 
                                    eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                    dsObj.lineItemObj = eachLineItem;
                                }else if(!eachLineItem.Apttus_Config2__AttributeValueId__r.Managed_Router__c && !eachLineItem.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c){
                                   eachLineItem.Apttus_Config2__NetPrice__c = (eachLineItem.Wireline_Promotion_Discount_Percentage__c != null && eachLineItem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? ((100-eachLineItem.Wireline_Promotion_Discount_Percentage__c) * 0.01 * getMonthlyAmount(eachLineItem.Port_Speed__c,eachLineItem.Apttus_Config2__ChargeType__c,'Port Speed Charge')).setscale(2) : getMonthlyAmount(eachLineItem.Port_Speed__c,eachLineItem.Apttus_Config2__ChargeType__c,'Port Speed Charge'); 
                                   eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                   dsObj.lineItemObj = eachLineItem;
                                }
                            }
                        }
                    }else if( itemAttr.Apttus_Config2__Field__c == 'Port_Type_MIS__c' || itemAttr.Apttus_Config2__Field__c == 'Port_Type_AVPN__c' ){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), false, true);
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){
                           if( eachLineItem.Apttus_Config2__ChargeType__c == 'Port Type Fee' ){
                                eachLineItem.Apttus_Config2__NetPrice__c = eachLineItem.Apttus_Config2__NetPrice__c.setScale(2);
                                eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                dsObj.lineItemObj = eachLineItem;
                            }
                        }
                    }else if( itemAttr.Apttus_Config2__Field__c == 'Access_Speed_MIS__c' || itemAttr.Apttus_Config2__Field__c == 'Access_Speed_AVPN__c' ){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), true, true);
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){
                            if( eachLineItem.Apttus_Config2__ChargeType__c != null ){
                                if( eachLineItem.Apttus_Config2__ChargeType__c.containsIgnoreCase('Access Speed')){
                                   system.debug('ACCCESSS SPPED'+eachLineItem.Apttus_Config2__ChargeType__c+'PRICE'+eachLineItem.Apttus_Config2__NetPrice__c.setScale(2));
                                    eachLineItem.Apttus_Config2__NetPrice__c = accessTotal;
                                    eachLineItem.Original_Net_Price__c = accessOriginalFee;
                                    dsObj.lineItemObj = eachLineItem;
                                }
                            }
                        }   
                    }else if( itemAttr.Apttus_Config2__Field__c == 'Access_Type__c' || itemAttr.Apttus_Config2__Field__c == 'Access_Type_AVPN__c' ){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), false, true);
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){
                            if( eachLineItem.Apttus_Config2__ChargeType__c == 'Access Type Fee' ){
                                eachLineItem.Apttus_Config2__NetPrice__c = eachLineItem.Apttus_Config2__NetPrice__c.setScale(2);
                                eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                dsObj.lineItemObj = eachLineItem;
                            }
                        }
                    }else if( itemAttr.Apttus_Config2__Field__c == 'Additional_DNS__c'){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), true, true);
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){                            
                            if( eachLineItem.Apttus_Config2__ChargeType__c == 'Additional DNS Fee' ){                               
                                eachLineItem.Apttus_Config2__NetPrice__c = (eachLineItem.Wireline_Promotion_Discount_Percentage__c != null && eachLineItem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? ((100-eachLineItem.Wireline_Promotion_Discount_Percentage__c) * 0.01 * getMonthlyDnsAmount(eachLineItem.AdditionalDnsType__c,eachLineItem.Apttus_Config2__ChargeType__c,'Additional DNS Fee')).setscale(2) : getMonthlyDnsAmount(eachLineItem.AdditionalDnsType__c,eachLineItem.Apttus_Config2__ChargeType__c,'Additional DNS Fee');  
                                eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                dsObj.lineItemObj = eachLineItem;                                 
                                if( eachLineItem.Apttus_Config2__AttributeValueId__r.Additional_DNS__c == '' || eachLineItem.Apttus_Config2__AttributeValueId__r.Additional_DNS__c == null ){
                                    dsObj.isPricable = false;
                                }
                            }
                        }
                    }else if( itemAttr.Apttus_Config2__Field__c == 'CoS__c' ){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), false, true);
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){                            
                            if( eachLineItem.Apttus_Config2__ChargeType__c == 'CoS Fee' ){                              
                                eachLineItem.Apttus_Config2__NetPrice__c = eachLineItem.Apttus_Config2__NetPrice__c.setScale(2);
                                eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                dsObj.lineItemObj = eachLineItem;
                                if( eachLineItem.Apttus_Config2__AttributeValueId__r.CoS__c == true){                                   
                                    dsObj.isPricable = true;
                                }                               
                            }
                        }
                    }else if( itemAttr.Apttus_Config2__Field__c == 'Install_Option_MIS__c' || itemAttr.Apttus_Config2__Field__c == 'Install_Option_AVPN__c' ){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), true, true);
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){
                            if( eachLineItem.Apttus_Config2__ChargeType__c == 'One Time Fee' && eachLineItem.isPricingApplied__c ){                             
                                eachLineItem.Apttus_Config2__NetPrice__c = eachLineItem.Apttus_Config2__NetPrice__c.setScale(2);
                                eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                oneTimeFee = eachLineItem.Apttus_Config2__NetPrice__c.setScale(2);
                                dsObj.lineItemObj = eachLineItem;
                            }
                        }
                    }else if( itemAttr.Apttus_Config2__Field__c == 'VLANs_Logical_Channels__c' ){                       
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), false, true);
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){                            
                            if( eachLineItem.Apttus_Config2__ChargeType__c == 'VLAN(s)/Logical Channel' && eachLineItem.Apttus_Config2__AttributeValueId__r.VLANs_Logical_Channels__c ){
                                eachLineItem.Apttus_Config2__NetPrice__c = (eachLineItem.Wireline_Promotion_Discount_Percentage__c != null && eachLineItem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? ((100-eachLineItem.Wireline_Promotion_Discount_Percentage__c) * 0.01 * getMonthlyAmount(eachLineItem.Port_Speed__c,eachLineItem.Apttus_Config2__ChargeType__c,'VLAN(s)/Logical Channel Fee')).setscale(2) : getMonthlyAmount(eachLineItem.Port_Speed__c,eachLineItem.Apttus_Config2__ChargeType__c,'VLAN(s)/Logical Channel Fee');
                                eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                dsObj.lineItemObj = eachLineItem;
                                if( Integer.valueOf(dsObj.lineItemObj.Apttus_Config2__NetPrice__c) > 0 ){
                                    dsObj.isPricable = true;
                                }                               
                            }
                        }
                    }else if( itemAttr.Apttus_Config2__Field__c == 'Interface_Type__c' || itemAttr.Apttus_Config2__Field__c == 'Interface_Type_AVPN__c' ){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), false, true);
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){                            
                            if( eachLineItem.Apttus_Config2__ChargeType__c == 'Interface Type' ){
                                eachLineItem.Apttus_Config2__NetPrice__c = eachLineItem.Apttus_Config2__NetPrice__c.setScale(2);                                
                                eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                dsObj.lineItemObj = eachLineItem;                               
                            }
                        }                       
                    }else if( itemAttr.Apttus_Config2__Field__c == 'UBB_Speed_MIS__c' || itemAttr.Apttus_Config2__Field__c == 'UBB_Speed_AVPN__c' ){                            
                        if( isHiCapFlex == true || listAttrVal.Hi_Cap_Flex__c ){
                            initializeIndices();
                            dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), true, true);
                            for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){                                
                                if( eachLineItem.Apttus_Config2__ChargeType__c == 'Port Speed Fee' && !isIglooExpired){
                                    if(eachLineItem.Apttus_Config2__AttributeValueId__r.Managed_Router__c && eachLineItem.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c){
                                        eachLineItem.Apttus_Config2__NetPrice__c = (eachLineItem.Wireline_Promotion_Discount_Percentage__c != null && eachLineItem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? ((100-eachLineItem.Wireline_Promotion_Discount_Percentage__c) * 0.01 * getMonthlyAmount(eachLineItem.MBC_Speed__c,eachLineItem.Apttus_Config2__ChargeType__c,'MIS Plus with Minimum Bandwidth Commitment')).setscale(2) : getMonthlyAmount(eachLineItem.MBC_Speed__c,eachLineItem.Apttus_Config2__ChargeType__c,'MIS Plus with Minimum Bandwidth Commitment'); 
                                        eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                        if(eachLineItem.MBC_Speed__c!=null){
                                            overgePerMb=getLatestOverragePrice(eachLineItem.MBC_Speed__c,eachLineItem.Product_Code__c);
                                        }
                                        dsObj.lineItemObj = eachLineItem;
                                    }else if(!eachLineItem.Apttus_Config2__AttributeValueId__r.Managed_Router__c && eachLineItem.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c){
                                        eachLineItem.Apttus_Config2__NetPrice__c = (eachLineItem.Wireline_Promotion_Discount_Percentage__c != null && eachLineItem.Wireline_Promotion_Discount_Percentage__c != 0.00) ? ((100-eachLineItem.Wireline_Promotion_Discount_Percentage__c) * 0.01 * getMonthlyAmount(eachLineItem.MBC_Speed__c,eachLineItem.Apttus_Config2__ChargeType__c,'UBB Charge')).setscale(2) : getMonthlyAmount(eachLineItem.MBC_Speed__c,eachLineItem.Apttus_Config2__ChargeType__c,'UBB Charge');    
                                        eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                        if(eachLineItem.MBC_Speed__c!=null){
                                            overgePerMb=getLatestOverragePrice(eachLineItem.MBC_Speed__c,eachLineItem.Product_Code__c);
                                        }
                                        dsObj.lineItemObj = eachLineItem;
                                    }
                                }
                            }
                        }
                    }else if( itemAttr.Apttus_Config2__Field__c == 'AT_T_IP_Flexible_Reach__c' ){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), false, true);
                    }
                    else if( itemAttr.Apttus_Config2__Field__c == 'Managed_Router__c' && listAttrVal.ProductName__c == 'AMIS' ){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), false, true);
                    }
                    else if( itemAttr.Apttus_Config2__Field__c == 'IP_Flexible_Reach_Plan__c'){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), true, true);
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){
                            if( eachLineItem.Apttus_Config2__ChargeType__c == 'IP Flex Reach Plan' && eachLineItem.Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c ){
                                eachLineItem.Apttus_Config2__NetPrice__c = eachLineItem.Apttus_Config2__NetPrice__c.setScale(2);
                                eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                dsObj.lineItemObj = eachLineItem;
                                if( Integer.valueOf(dsObj.lineItemObj.Apttus_Config2__NetPrice__c) > 0 ){
                                    dsObj.isPricable = true;
                                }
                            }
                        }
                    }
                    else if( itemAttr.Apttus_Config2__Field__c == 'Ported_Phone_Numbers__c'){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), false, true);
                    }
                    else if( itemAttr.Apttus_Config2__Field__c == 'New_Local_Phone_Numbers__c'){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), false, true);
                    }
                    else if( itemAttr.Apttus_Config2__Field__c == 'New_Virtual_Phone_Numbers__c'){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), true, true);
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){                            
                            if( eachLineItem.Apttus_Config2__ChargeType__c == 'VTN Fee' && eachLineItem.Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c ){
                                eachLineItem.Apttus_Config2__NetPrice__c = eachLineItem.Apttus_Config2__NetPrice__c.setScale(2);
                                eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                dsObj.lineItemObj = eachLineItem;
                                if( Integer.valueOf(dsObj.lineItemObj.Apttus_Config2__NetPrice__c) > 0 ){
                                    dsObj.isPricable = true;
                                }                           
                            }
                        }
                    }
                    else if( itemAttr.Apttus_Config2__Field__c == 'Concurrent_Calls__c'){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), false, true);
                    }                      
                    else if( itemAttr.Apttus_Config2__Field__c == 'Enhanced_Features__c'){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), true, true);
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){                            
                            if( eachLineItem.Apttus_Config2__ChargeType__c == 'Enhanced Features' && eachLineItem.Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c ){
                                eachLineItem.Apttus_Config2__NetPrice__c = eachLineItem.Apttus_Config2__NetPrice__c.setScale(2);
                                eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                dsObj.lineItemObj = eachLineItem;
                                if( Integer.valueOf(dsObj.lineItemObj.Apttus_Config2__NetPrice__c) > 0 ){
                                    dsObj.isPricable = true;
                                }                            
                            }
                        }
                    }
                    else if( itemAttr.Apttus_Config2__Field__c == 'Setup_Fee__c'){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), true, true);
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){                            
                            if( eachLineItem.Apttus_Config2__ChargeType__c == 'Setup Fee' && eachLineItem.Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c ){
                                eachLineItem.Apttus_Config2__NetPrice__c = eachLineItem.Apttus_Config2__NetPrice__c.setScale(2);
                                eachLineItem.Original_Net_Price__c = eachLineItem.Original_Net_Price__c != null ? eachLineItem.Original_Net_Price__c.setScale(2): 0.00;
                                dsObj.lineItemObj = eachLineItem;
                                if( Integer.valueOf(dsObj.lineItemObj.Apttus_Config2__NetPrice__c) > 0 ){
                                    dsObj.isPricable = true;
                                }
                            }
                        }
                    }
                    else{
                        if(listAttrVal.ProductName__c == 'AVPN' || listAttrVal.ProductName__c == 'AMIS'){
                            if( itemAttr.Apttus_Config2__Field__c != 'VASA_Region__c' && itemAttr.Apttus_Config2__Field__c != 'Apttus_Config2__Vendor__c' && itemAttr.Apttus_Config2__Field__c != 'mileage__c' && itemAttr.Apttus_Config2__Field__c != 'Mileage_Adjustment__c' && itemAttr.Apttus_Config2__Field__c != 'UBB_Speed_AVPN__c' && itemAttr.Apttus_Config2__Field__c != 'UBB_Speed_MIS__c' && itemAttr.Apttus_Config2__Field__c == 'Hi_Cap_Flex__c' && itemAttr.Apttus_Config2__Field__c != 'IP_Flexible_Reach_Plan__c' && itemAttr.Apttus_Config2__Field__c != 'Managed_Router__c' && itemAttr.Apttus_Config2__Field__c != 'New_Virtual_Phone_Numbers__c' && itemAttr.Apttus_Config2__Field__c != 'Enhanced_Features__c' && itemAttr.Apttus_Config2__Field__c != 'Setup_Fee__c') {
                                dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00,Original_Net_Price__c=0.00), false, false );
                            }
                        }
                    }
                }
                else{
                    if( itemAttr.Apttus_Config2__Field__c == 'PortSpeedASE__c' ){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00), false, true);
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){                
                            if( eachLineItem.Apttus_Config2__ChargeType__c == 'Port Speed Fee' ){                    
                                eachLineItem.Apttus_Config2__NetPrice__c = eachLineItem.Apttus_Config2__NetPrice__c.setScale(2);
                                dsObj.lineItemObj = eachLineItem;
                                dsObj.isPricable = true;
                            }
                        }
                    }
                    else if( itemAttr.Apttus_Config2__Field__c == 'CIR__c' ){
                        dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00), false, true);
                        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){                
                            if( eachLineItem.Apttus_Config2__ChargeType__c == 'CoS Fee' ){                    
                                eachLineItem.Apttus_Config2__NetPrice__c = eachLineItem.Apttus_Config2__NetPrice__c.setScale(2);
                                dsObj.lineItemObj = eachLineItem;
                                dsObj.isPricable = true;
                            }
                        }
                    }
                    else{
                        if( itemAttr.Apttus_Config2__Field__c != 'Tier__c' && itemAttr.Apttus_Config2__Field__c != 'Term__c' && itemAttr.Apttus_Config2__Field__c != 'IsPromotional__c' ) {
                            dsObj = new wrapperDataS(itemAttr.Apttus_Config2__Field__c,  new Apttus_Config2__LineItem__c(Apttus_Config2__NetPrice__c=0.00), false, true);
                        }
                    }
                }
                system.debug('@@@dsObj:'+dsObj);
                dataWrap.add(dsObj);
            }
        }
        System.debug('---------------'+dataWrap);
        isUBBinCart = iSHiCapInCart();
        if(isASE == false){
            handleHiCapOnRefresh();
            checkForEligibleSitesCount();
        }
    }
    
    public void cleaFormUI(){
        list<AT_T_Customer_Site_Quote__c> siteQuoteList = new list<AT_T_Customer_Site_Quote__c>();
        siteQuoteList = [select id, AT_T_Customer_Site__c, AT_T_Quote__c, Iglow_Response_Received_Date__c, Igloo_Review_Required__c, Wireline_Promotion_Applied__c from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c =: selectedSiteId and AT_T_Quote__c =: quoteId];
        if(siteQuoteList[0].Igloo_Review_Required__c == true || siteQuoteList[0].Wireline_Promotion_Applied__c == true){
            siteQuoteList[0].Igloo_Review_Required__c = siteQuoteList[0].Wireline_Promotion_Applied__c = false;
            siteQuoteList[0].Iglow_Response_Received_Date__c = null; 
            update siteQuoteList;
        }
        lineItems = [SELECT Id, Apttus_Config2__LineNumber__c, Apttus_Config2__BasePrice__c,Original_Hidden_Price__c,Original_Net_Price__c,Apttus_Config2__NetPrice__c,Net_Price_with_Deal_Reg_Discounts__c,Net_Price_with_SP_Order_Discounts__c,Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=:cartId AND AT_T_Customer_Site__c =: selectedSiteId];
        System.debug('lineItems -------'+lineItems);
        Apttus_Config2__ProductAttributeValue__c newAVToBeUpdated = new Apttus_Config2__ProductAttributeValue__c ();
        newAVToBeUpdated.Apttus_Config2__LineItemId__c = lineItems[0].Id;
        System.debug('newAVToBeUpdated -------'+newAVToBeUpdated+'  lineItems[0].Id '+lineItems[0].Id);
        insert newAVToBeUpdated;
        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){        
            eachLineItem.Apttus_Config2__AttributeValueId__c = newAVToBeUpdated.Id;
            eachLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            eachLineItem.isPricingApplied__c = false;
            eachLineItem.Net_Price_with_Deal_Reg_Discounts__c = eachLineItem.Net_Price_with_SP_Order_Discounts__c = eachLineItem.Original_Hidden_Price__c = eachLineItem.Original_Net_Price__c = null;
        }
        update lineItems ;
        System.debug('after update lineItems -------'+lineItems);
        Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO priceRequest = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO(); 
        priceRequest.CartId = cartId; priceRequest.LineNumber = lineItems[0].Apttus_Config2__LineNumber__c; 
        Apttus_CPQApi.CPQ.ComputeNetPriceResponseDO priceResponse = Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(priceRequest);
        isPricingDataAvailable=false;
        Apttus_Config2__ProductConfiguration__c prodConfig = quoteHelper.retrieveExistingCartId(quoteId);
        readPricingStatusForAllLineItem(prodConfig);
    }
    
    public void clearFormASE(){        
        lineItems = [SELECT Id, Apttus_Config2__LineNumber__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__ExtendedPrice__c,Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__ListPrice__c, Apttus_Config2__BasePrice__c,Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c,Original_Net_Price__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=:cartId AND AT_T_Customer_Site__c =: selectedSiteId];
        System.debug('lineItems -------'+lineItems);
        Apttus_Config2__ProductAttributeValue__c newAVToBeUpdated = new Apttus_Config2__ProductAttributeValue__c ();
        newAVToBeUpdated.Apttus_Config2__LineItemId__c = lineItems[0].Id;
        System.debug('newAVToBeUpdated -------'+newAVToBeUpdated+'  lineItems[0].Id '+lineItems[0].Id);
        insert newAVToBeUpdated;
        CNUMDropdownValue = '';
        serviceTypeRadioValue ='' ;
        CoSRadioValue = '';
        networkTypeRadioValue = '';
        LATARadioValue ='' ;
        configTypeRadioValue ='' ;
        siteDesignationRadioValue = '';
        portVLANBasedRadioValue = '' ;
        macAddressesRadioValue = '';    
        
        for( Apttus_Config2__LineItem__c eachLineItem : lineItems ){        
            eachLineItem.Apttus_Config2__AttributeValueId__c = newAVToBeUpdated.Id;
            eachLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            eachLineItem.isPricingApplied__c = false;
            eachLineItem.Apttus_Config2__ListPrice__c = 0.0;
            eachLineItem.Apttus_Config2__BasePrice__c = 0.0;
            eachLineItem.Apttus_Config2__BaseExtendedPrice__c = 0.0;
            eachLineItem.Apttus_Config2__ExtendedPrice__c = 0.0;
            eachLineItem.Apttus_Config2__AdjustedPrice__c = 0.0;
            eachLineItem.Apttus_Config2__NetPrice__c = 0.0; 
            eachLineItem.Original_Net_Price__c = 0.0;
        }
        update lineItems ;
        System.debug('after update lineItems -------'+lineItems);
        isPricingDataAvailable=false;
        Apttus_Config2__ProductConfiguration__c prodConfig = quoteHelper.retrieveExistingCartId(quoteId);
        readPricingStatusForAllLineItem(prodConfig);         
    }
    
    public PageReference pageLoadOnClearForm(){
        Pagereference pg = page.PortalDesign_Buyflow;
        pg.getparameters().put('quoteid',Apexpages.currentpage().getparameters().get('quoteid'));
        pg.getparameters().put('siteid',selectedSiteId);
        pg.getparameters().put('mode','confsites');
        pg.setredirect(true);
        return pg;  
    }
        
    public pagereference togglesitesconfigpage(){    
        interfaceTypeMap=new Map<integer,Set<String>>();
        interfaceTypeMap=siteInterfaceTypeMap.get(selectedSiteId);
        interfaceTypeList=new Set<String>();
        if(interfaceTypeMap!=null && interfaceTypeMap.size()>0){
            interfaceType5=interfaceTypeMap.get(5);
            interfaceType10=interfaceTypeMap.get(10);
            interfaceType20=interfaceTypeMap.get(20);
            interfaceType50=interfaceTypeMap.get(50);
            interfaceType100=interfaceTypeMap.get(100);
        }       
        resetUBB();
        resetIpflex();
        system.debug('interfaceTypeMap in togglesitesconfigpage '+interfaceTypeMap);
        Pagereference pg = page.PortalDesign_Buyflow;
        pg.getparameters().put('quoteid',quoteId);
        pg.getparameters().put('siteid',selectedSiteId);
        pg.getparameters().put('mode','confsites');
        pg.setredirect(true);
        return pg;
    }
    
    public void resetUBB(){    
        //Logic to find the site which has UBB Check but pricing was not done
        set<Id> attrbuteId = new Set<id>();
        List<Apttus_Config2__LineItem__c> lineItemInCart=[SELECT Id,Apttus_Config2__AttributeValueId__c,Apttus_Config2__ConfigurationId__c,isPricingApplied__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartId and isPricingApplied__c=false];
        for(Apttus_Config2__LineItem__c li: lineItemInCart){
            attrbuteId.add(li.Apttus_Config2__AttributeValueId__c);
        } 
        if(attrbuteId!=null && attrbuteId.size()>0){
            list<Apttus_Config2__ProductAttributeValue__c> avRecordsInCart = [select id,Hi_Cap_Flex__c,AT_T_IP_Flexible_Reach__c from Apttus_Config2__ProductAttributeValue__c where ID IN: attrbuteId];
            for(Apttus_Config2__ProductAttributeValue__c avRec : avRecordsInCart){
                if(avRec.Hi_Cap_Flex__c){
                    avRec.Hi_Cap_Flex__c=false;
                    system.debug('Update Fired');
                }
            }
            if(avRecordsInCart!=null){
                update avRecordsInCart; 
            }
        }
    }
    
    public void resetIpflex(){    
        //Logic to find the site which has UBB Check but pricing was not done
        set<Id> attrbuteId = new Set<id>();
        List<Apttus_Config2__LineItem__c> lineItemInCart=[SELECT Id,Apttus_Config2__AttributeValueId__c,Apttus_Config2__ConfigurationId__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartId and isPricingApplied__c=false];
        for(Apttus_Config2__LineItem__c li: lineItemInCart){
            attrbuteId.add(li.Apttus_Config2__AttributeValueId__c);
        } 
        if(attrbuteId!=null && attrbuteId.size()>0){
            list<Apttus_Config2__ProductAttributeValue__c> avRecordsInCart = [select id,Managed_Router__c,CoS__c,Hi_Cap_Flex__c,AT_T_IP_Flexible_Reach__c from Apttus_Config2__ProductAttributeValue__c where ID IN: attrbuteId];
            for(Apttus_Config2__ProductAttributeValue__c avRec : avRecordsInCart){
                if(avRec.AT_T_IP_Flexible_Reach__c ){
                    avRec.AT_T_IP_Flexible_Reach__c=false;
                    avRec.Managed_Router__c=false;
                    avRec.CoS__c=false;
                    system.debug('Update Fired');
                }
            }
            if(avRecordsInCart!=null){
                update avRecordsInCart; 
            }
        }
    }
    
    public PageReference initializePricingData(){        
        Decimal siteTotalTemp = 0.0;
        Decimal onetTimeFeeTemp = 0.0;        
        system.debug('@@@Selected Site: '+selectedSiteId);       
        
        lineItems = [SELECT Id, UBBOveragePrice__c, Apttus_Config2__BasePrice__c, isPricingApplied__c, Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c, Apttus_Config2__LineNumber__c, AT_T_Customer_Site__c,Product_Code__c,MBC_Speed__c,Apttus_Config2__ConfigurationId__r.Apttus_Config2__AccountId__r.Current_Tier__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Payment_Term__c,Apttus_Config2__Description__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=:CartId AND AT_T_Customer_Site__c =: selectedSiteId];
        for( Apttus_Config2__LineItem__c eachItem : lineItems ){            
            eachItem.isPricingApplied__c = true;
            if( eachItem.Apttus_Config2__ChargeType__c != 'One Time Fee' && eachItem.Apttus_Config2__ChargeType__c != 'Interface Type' ){
                if( eachItem.Apttus_Config2__NetPrice__c != null ){
                    siteTotalTemp += eachItem.Apttus_Config2__NetPrice__c;
                }   
            }
            if( eachItem.Apttus_Config2__ChargeType__c == 'One Time Fee' ){
                if( eachItem.Apttus_Config2__NetPrice__c != null ){
                    onetTimeFeeTemp = eachItem.Apttus_Config2__NetPrice__c;
                }   
            }
        }
        
        for(QuoteProducts.cCustomerSite cs : ListCustomerSite){    
            if( cs.custSiteIns.Id == selectedSiteId ){
                cs.attCustomerSiteTotal = siteTotalTemp.setScale(2);
                cs.attCustomerSiteOneTime = onetTimeFeeTemp.setScale(2);
            }            
        }
        update lineItems;
        system.debug('@@@^lineItems'+lineItems);
        
      
        if(isASE == false){
            if(listAttrVal.Ported_Phone_Numbers__c != null){
                portedPhoneNumber = Integer.valueOf(listAttrVal.Ported_Phone_Numbers__c);
            }
            if(listAttrVal.New_Local_Phone_Numbers__c != null){
                newLocalPhoneNumber = Integer.valueOf(listAttrVal.New_Local_Phone_Numbers__c);
            }
            if(listAttrVal.New_Virtual_Phone_Numbers__c != null){
                newVirtualPhoneNumber = Integer.valueOf(listAttrVal.New_Virtual_Phone_Numbers__c);
            }            
            totalPhoneNumber = portedPhoneNumber + newLocalPhoneNumber + newVirtualPhoneNumber;
            
            if(listAttrVal.AT_T_IP_Flexible_Reach__c){
                if(totalPhoneNumber <= 25000){
                    listAttrVal.IP_Flex_Error__c = false;
                }
                else{                
                    listAttrVal.IP_Flex_Error__c = true;
                }
            }
        }
        listAttrVal.IGLOO_Supplier_Name__c = '';
        siteMap = new Map<Id,CustomerSite__c>([select id,VASAResponse__c,Service_Availability_Response__c,Tier__c,ASE_ITPA_Response__c,LATA_Number__c from CustomerSite__c where id = :selectedSiteId]);
        JSONResponse = siteMap.get(selectedSiteId).Service_Availability_Response__c;
        
        aseTier = siteMap.get(selectedSiteId).Tier__c;
        lataNumber = siteMap.get(selectedSiteId).LATA_Number__c;
        
        if(isAvpn || isMIS){
            helper.updateAVRecordsOnApply(listAttrVal,JSONResponse,isAvpn,isMIS);            
        }
        else if(isASE){
            helper.updateAVRecordsOnApplyASE(listAttrVal,aseTier,lataNumber,proposalData);
        }        
        update listAttrVal;
        System.debug('@@@@@@@@@@@STD'+listAttrVal);      
        
        if(isASE == true){
            if(!Test.isRunningTest()){            
                helper.computePrice(cartId, Integer.valueOf(lineItems[0].Apttus_Config2__LineNumber__c) );
            }
            
            isPricingDataAvailable = true;        
            initializeUIContentFromSchema();
            initializeData();  
            Apttus_Config2__ProductConfiguration__c prodConfig = quoteHelper.retrieveExistingCartId(quoteId);
            readPricingStatusForAllLineItem(prodConfig);
            handlefilterSites();  
            isUBBinCart = iSHiCapInCart();
        }
        return null;
    }
    
    public Id lineNumAttrIdMap;

    public void popMapforAIA(decimal LineNum, string QuoteId){
        set<string> prodconfigId = new set<string>();
        list<Apttus_Config2__LineItem__c> lineItems = new list<Apttus_Config2__LineItem__c>();
        try{      
            lineItems = [Select a.Apttus_Config2__LineNumber__c, a.Apttus_Config2__LineType__c,a.Apttus_Config2__OptionGroupLabel__c, a.Apttus_Config2__ConfigurationId__c, a.Apttus_Config2__AttributeValueId__c, a.Access_Speed__c, a.AT_T_Customer_Site__c From Apttus_Config2__LineItem__c a where a.Apttus_Config2__ConfigurationId__c =: cartId];
            if(lineItems != null){
                for(Apttus_Config2__LineItem__c line: lineItems){
                    if(LineNum != null && line.Apttus_Config2__LineType__c == 'Product/Service' && line.Apttus_Config2__LineNumber__c == LineNum){
                        lineNumAttrIdMap = line.Apttus_Config2__AttributeValueId__c;                    
                    }
                    else if(LineNum == null && lineNumAttrIdMap != null && line.Apttus_Config2__AttributeValueId__c == null){
                        line.Apttus_Config2__AttributeValueId__c = lineNumAttrIdMap;
                    }
                }              
            }
            if(LineNum == null){
                update lineItems;
            }
        }
        catch(Exception e){
            system.debug('Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in ApttusServiceUtilityHelper.updateLineItem', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }   
    }

    public void updateAttrRec(Integer linenumber, String optValAIA){
        try{
            if(lineNumAttrIdMap != null){
                List<Apttus_Config2__ProductAttributeValue__c> lstPrdAttrVal = [Select Id, Name , Dynamic__c, Static__c from Apttus_Config2__ProductAttributeValue__c where Id =: lineNumAttrIdMap];
                if(lstPrdAttrVal != null){
                    if(optValAIA == 'Dynamic'){
                        lstPrdAttrVal[0].Dynamic__c = true;
                        lstPrdAttrVal[0].Static__c = false;
                    }else if(optValAIA == 'Static'){
                        lstPrdAttrVal[0].Dynamic__c = false;
                        lstPrdAttrVal[0].Static__c = true;
                    }
                    update lstPrdAttrVal[0];
                }
            }
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.updateAttrRec', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }

    //create seleted products number of times 
    public void setupCartWithSelectedSites(){
        if(ApexPages.currentPage().getParameters().get('mode') == 'confsites'){
            boolean isExistingCart = false;              
            system.debug('initializeGlobalParameter completed --------------------> ');
            try{
                if(ApexPages.currentPage().getParameters().get('quoteId') != null){
                    quoteId = ApexPages.currentPage().getParameters().get('quoteId'); 
                    system.debug('Quote Id -> '+quoteId);                   
                }
                if(!String.isempty(quoteId)){ 
                    if(!calTableList()){
                        return; 
                    }
                    getCustomerSiteLst();
                    
                    //creating cart                 
                    Apttus_Config2__ProductConfiguration__c prodConfig = quoteHelper.retrieveExistingCartId(quoteId);
                    system.debug('@@@^Existing cart Id --> '+prodConfig); 
                    
                    if(prodConfig != null){
                        if(prodConfig.Apttus_Config2__LineItems__r.size()>2){
                            cartId = prodConfig.Id;
                            system.debug('cart Id found --> '+prodConfig); 
                        }
                    } 
                                      
                    if(!String.isempty(cartId) && ListCustomerSite!=null && prodConfig!=null){
                        readPricingStatusForAllLineItem(prodConfig);
                        IntializeUI(prodConfig, ListCustomerSite[0]);  
                        isExistingCart = true;                 
                    }else{
                        quoteHelper.removeExistingCart(quoteId);
                        cartId = helper.createCart(quoteId);
                        system.debug('Create Cart completed --------------------> ');
                        showDetail();
                    }

                    if(sPricingWrap!=NULL && sPricingWrap.optionsList!=NULL && sPricingWrap.optionsList.size()>0){
                        Boolean isNotDefaulted = true; 
                        Integer staticIndex = -1;
                        Integer counter = -1;
                        system.debug ('read :: ' + sPricingWrap.optionsList);
                        for(QuoteProducts.ProductOption obj: sPricingWrap.optionsList){
                            counter++;
                            if (obj.name!=NULL && obj.name.equalsIgnoreCase('static')){
                                staticIndex = counter;
                            }
                            if (obj.name!=NULL && (obj.name.equalsIgnoreCase('static')|| obj.name.equalsIgnoreCase('dynamic')) && obj.isSelected!=null && obj.isSelected){
                                isNotDefaulted  = false;                            
                            }                       
                        }
                        
                        if(isNotDefaulted && staticIndex!=-1 && staticIndex>=0){
                            sPricingWrap.optionsList[staticIndex].isSelected = true; 
                            selectOptGrp = 'Static';
                            if(!isExistingCart){
                                selectOptGrpVal = sPricingWrap.optionsList[staticIndex].productId;
                                selectedOptGrpQuery();
                                system.debug('staticIndex --> '+sPricingWrap.optionsList[staticIndex]);
                            }                           
                        }
                    }                           
                }    
            }
            catch(Exception e){
                ATTException.createException('Error in QuoteInfoController.setupCartWithSelectedSites', e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        } 
    }
    
    public void fetchUpdatedPriceOnLoad(){        
        Apttus_Config2__ProductConfiguration__c prodConfig = quoteHelper.retrieveExistingCartId(quoteId);
        readPricingStatusForAllLineItem(prodConfig); 
        handlefilterSites();
    }
    
    public void readPricingStatusForAllLineItem(Apttus_Config2__ProductConfiguration__c prodConfig){
        boolean allLineprocessed = true;
        isContinueEnabled = false;
        system.debug('@@@^ In read pricing '+isContinueEnabled);
        grandTot = 0;
        Decimal tprice = 0;
        boolean isSiteFoundInLineItems = false;
        String previousSiteId = '';
        String currentSiteId = '';
       
        Integer globalCounter = 0;
        if( ListCustomerSite != null ){
            countOfSites = ListCustomerSite.size();
        }
        Integer countOfConfiguredSites = 0;
        noOfConfigedSites = 0;
                
        Map<id,List<Apttus_Config2__LineItem__c>> pricingLineItemMap = new Map<id,List<Apttus_Config2__LineItem__c>>();
        List<Apttus_Config2__LineItem__c> pricingLineItemList = new List<Apttus_Config2__LineItem__c>();
        for(Apttus_Config2__LineItem__c pline: [select id, AT_T_Customer_Site__c, Apttus_Config2__ChargeType__c, isPricingApplied__c, Apttus_Config2__NetPrice__c,Apttus_Config2__LineNumber__c, Apttus_Config2__PricingStatus__c, Apttus_Config2__LineType__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: prodConfig.Id]){ 
            pricingLineItemList = pricingLineItemMap.get(pline.AT_T_Customer_Site__c);
            if(pricingLineItemList == null){
                pricingLineItemList = new List<Apttus_Config2__LineItem__c>();
            }
            pricingLineItemList.add(pline);
            pricingLineItemMap.put(pline.AT_T_Customer_Site__c,pricingLineItemList);
        }
        
        System.debug('!!sfdc lineItemMap  '+pricingLineItemMap);
        if(String.isNotBlank(selectedSiteId) && String.isNotBlank(quoteId)){
            updateCustomerSite();         
        }
         
        try{
            for(QuoteProducts.cCustomerSite cs : ListCustomerSite){                
                currentSiteId = cs.custSiteIns.Id;
                isSiteFoundInLineItems = false;
                if(prodConfig != null && prodConfig.Apttus_Config2__LineItems__r != null){
                    system.debug('#########'+prodConfig.Apttus_Config2__LineItems__r.size());
                    system.debug('#########'+cs.custSiteIns.id);
                    system.debug('@@gsp cs'+cs);
                    system.debug('@@gsp prodConfig.Apttus_Config2__LineItems__r  '+prodConfig.Apttus_Config2__LineItems__r);
                    Decimal siteTotalTemp = 0.00;
                    Decimal oneTimeFeeTemp = 0.00;
                    
                    System.debug('!!sfdc lineItemMap  '+pricingLineItemMap);
                    System.debug('!!sfdc currentSiteId  '+currentSiteId);
                    System.debug('!!sfdc lineItemMap.get(currentSiteId)  '+pricingLineItemMap.get(currentSiteId));
                    if(pricingLineItemMap !=null && pricingLineItemMap.keySet().contains(currentSiteId)){
                        for(Apttus_Config2__LineItem__c p: pricingLineItemMap.get(currentSiteId)){                           
                            system.debug('#########'+p.AT_T_Customer_Site__c);
                            if(cs.custSiteIns.id == p.AT_T_Customer_Site__c){
                                isSiteFoundInLineItems = true;
                                if( p.Apttus_Config2__ChargeType__c != 'One Time Fee' && p.Apttus_Config2__ChargeType__c != 'Interface Type' && p.isPricingApplied__c ){
                                    siteTotalTemp += p.Apttus_Config2__NetPrice__c;
                                }
                                system.debug(cs.lineNumber+'@@@@@@@@isSiteFoundInLineItems'+isSiteFoundInLineItems +'price'+siteTotalTemp);
                                if( p.Apttus_Config2__ChargeType__c == 'One Time Fee' && p.isPricingApplied__c ){
                                    oneTimeFeeTemp = p.Apttus_Config2__NetPrice__c;
                                }
                                if(cs.linenumber == null || cs.linenumber == 0){
                                    cs.isProcessed = true;
                                    cs.linenumber = p.Apttus_Config2__LineNumber__c;
                                    cs.pricingStatus = p.Apttus_Config2__PricingStatus__c;  
                                    system.debug('Site name -- > '+cs.custSiteIns.Site_Name__c + '  Linenumber -- > '+p.Apttus_Config2__LineNumber__c);                                            
                                }
                                system.debug('IS###########'+p.isPricingApplied__c);
                                if(p.isPricingApplied__c){
                                    cs.isProcessed = true;
                                    cs.eligibleSelected = true;
                                    cs.pricingStatus = ATTConstants.COMPLETE;
                                    if( cs.custSiteIns.id == selectedSiteId && !cs.OORSEExpired){    
                                        isPricingDataAvailable = true; 
                                    }  
                                    if((globalCounter == 0 || previousSiteId != currentSiteId) && !cs.isIglooReviewReq && !cs.OORSEExpired){
                                        noOfConfigedSites++;
                                        noOfConfigedSitesSet.add(currentSiteId);
                                        System.debug('SysAdmin');
                                    }           
                                }else{
                                    allLineprocessed = false;
                                    cs.isProcessed = false;
                                }
                                if('Product/Service'.equalsIgnoreCase(p.Apttus_Config2__LineType__c)){
                                    tprice =  QuoteHelper.checkNull(p.Apttus_Config2__NetPrice__c);               
                                    grandTot+= tprice;
                                }else{
                                    continue;
                                }
                                previousSiteId = p.AT_T_Customer_Site__c;
                            }else{
                                 allLineprocessed = false;
                            }
                            globalCounter++;
                        }
                    }                    
                    cs.attCustomerSiteTotal = siteTotalTemp.setScale(2);
                    cs.attCustomerSiteOneTime = oneTimeFeeTemp.setScale(2);
                }   
                
                if( cs.custSiteIns.Id == selectedSiteId ){                
                    cs.cellFilterSitesClass = 'selectedSiteHighlighted';                
                }else{                
                    cs.cellFilterSitesClass = '';                
                }      
            }            
            system.debug(countOfSites+'@@ASX@@@$$$$$$'+noOfConfigedSites );
            if(allLineprocessed){
                isAllSitesNotProcessed = false;
            }
            checkForEligibleSitesCount();
            system.debug(isContinueEnabled+'@@@isAllSitesNotProcessed: '+isAllSitesNotProcessed );
        }catch(Exception e){
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in QuoteInfoController.setupCartWithSelectedSites', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    public void checkForEligibleSitesCount(){ 
        system.debug('@@@^inside checkForEligibleSitesCount');
        Integer noOfSoftDeletedConfigSites = 0;
        noOfReviewRequiredSites = 0;
        Map<String,AT_T_Customer_Site_Quote__c> mapOfSiteQuote = new Map<String,AT_T_Customer_Site_Quote__c>();
        List<AT_T_Customer_Site_Quote__c> tmpSitequoteList = new List<AT_T_Customer_Site_Quote__c> ();
        List<AT_T_Customer_Site_Quote__c> noOfReviewRequiredSitesList = new List<AT_T_Customer_Site_Quote__c> ();
        
        List<AT_T_Customer_Site_Quote__c> siteJunctionList= [Select Id,Is_Soft_Deleted__c, Name,Iglow_Response_Received_Date__c,AT_T_Customer_Site__c,hub__c,AT_T_Quote__c,AT_T_Quote__r.Product__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,AT_T_Quote__r.Name,AT_T_Quote__r.Apttus_Proposal__Payment_Term__c,AT_T_Quote__r.Apttus_QPConfig__PriceListId__c,AT_T_Quote__r.Product__r.Name, AT_T_Customer_Site__r.Id, AT_T_Customer_Site__r.Name, AT_T_Customer_Site__r.Site_Name__c, AT_T_Customer_Site__r.City__c, AT_T_Customer_Site__r.Service_Availability_Response__c, AT_T_Customer_Site__r.State__c, AT_T_Customer_Site__r.Address_Line__c,AT_T_Customer_Site__r.Tier__c ,AT_T_Customer_Site__r.Building_Cili__c,AT_T_Customer_Site__r.Code_EMUX_Fiber__c,AT_T_Customer_Site__r.LATA_Number__c,Igloo_Review_Required__c,Wireline_Promotion_Applied__c from AT_T_Customer_Site_Quote__c where AT_T_Quote__c =: quoteId  ];  
        //Set<String> expiredOORSites=IglooExpirationCheck(siteJunctionList,false);
        
        for(AT_T_Customer_Site_Quote__c custSiteQuote: siteJunctionList){
            mapOfSiteQuote.put(custSiteQuote.id,custSiteQuote);
            if(custSiteQuote.Is_Soft_Deleted__c){
                tmpSitequoteList.add(custSiteQuote);
            }
            else if(custSiteQuote.Igloo_Review_Required__c && custSiteQuote.Is_Soft_Deleted__c == false){
                noOfReviewRequiredSitesList.add(custSiteQuote);
            }
        }
        
        noOfReviewRequiredSites = noOfReviewRequiredSitesList.size(); 
        Map<String,ID> noOfSoftDeletedSitesMap = new Map<String,ID>();
        Boolean blockReviewButton=false;
        noOfSoftDeletedSites = tmpSitequoteList.size();
        List<Apttus_Config2__ProductConfiguration__c> prodConfig =[Select IsPricingComplete__c,(select id,isPricingApplied__c From Apttus_Config2__LineItems__r where isPricingApplied__c=false) from Apttus_Config2__ProductConfiguration__c where Id=:CartId order by createdDate DESC Limit 1 ];
        
        if(prodConfig[0].Apttus_Config2__LineItems__r !=null && prodConfig[0].Apttus_Config2__LineItems__r.size()>0){
            if(noOfSoftDeletedSites == 0){
                blockReviewButton=true;
            }               
        }
        
        system.debug('***Block Review***'+blockReviewButton); 
        
        
        for(AT_T_Customer_Site_Quote__c p: tmpSitequoteList){
            noOfSoftDeletedSitesMap.put(p.AT_T_Customer_Site__c,p.AT_T_Customer_Site__c);               
        }
       
        for(String conId: noOfConfigedSitesSet){
            if(noOfSoftDeletedSitesMap.containsKey(conId)){
                noOfSoftDeletedConfigSites ++;            
            }   
        }
        if(noOfSoftDeletedSites == null){
            noOfSoftDeletedSites = 0;
        }

        if(noOfReviewRequiredSites>0){
            isContinueEnabled = false;
        }
        else if(countOfSites==noOfConfigedSites){  
            if((!(SwitchedEthernetJunction!=null && SwitchedEthernetJunction.size()>0)) || isRemove){
                isContinueEnabled = true;
            }       
        }
        else if(countOfSites == (noOfConfigedSites+noOfSoftDeletedSites) - noOfSoftDeletedConfigSites)
        { 
            if((!(SwitchedEthernetJunction!=null && SwitchedEthernetJunction.size()>0)) || isRemove){
                isContinueEnabled = true;
            }
        }
        else{
            isContinueEnabled = false;
        }
        
        //Logic to check enabling of Review Quote button                      
        if(prodConfig != null && prodConfig.size() > 0 && prodConfig[0].IsPricingComplete__c>0 && !blockReviewButton){
            if(countOfSites==noOfConfigedSites){
                isContinueEnabled = true;
            }else if(countOfSites == (noOfConfigedSites+noOfSoftDeletedSites) - noOfSoftDeletedConfigSites){
                isContinueEnabled = true;
            }else{
                isContinueEnabled = false;
            }
        }else{
            isContinueEnabled = false;
        }
        system.debug('isContinueEnabled  '+isContinueEnabled );
        if(String.isNotBlank(selectedSiteId) && String.isNotBlank(quoteId)){
            updateCustomerSite();
        }
    }
    
    public void updateCustomerSite(){
        List<AT_T_Customer_Site_Quote__c> jncSite=new  List<AT_T_Customer_Site_Quote__c>();
        Set<String> expiredSites= IglooExpirationCheck(jncSite,true);
        AT_T_Customer_Site_Quote__c juncSite = new AT_T_Customer_Site_Quote__c();
        system.debug('@@@selectedSiteId: '+selectedSiteId);
        system.debug('@@@quoteid: '+quoteid);
        juncSite = [select Igloo_Review_Required__c,Is_Soft_Deleted__c,Wireline_Promotion_Applied__c from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c =: selectedSiteId and AT_T_Quote__c =: quoteid];
        for(QuoteProducts.cCustomerSite cs : ListCustomerSite){    
            if( cs.custSiteIns.Id == selectedSiteId ){
                System.debug('juncSite ============'+juncSite);
                if(juncSite != null){
                    cs.isIglooReviewReq = juncSite.Igloo_Review_Required__c;
                    cs.isSoftDel = juncSite.Is_Soft_Deleted__c;
                    if(expiredSites!=null && expiredSites.size()>0 && expiredSites.contains(cs.custSiteIns.Id)){
                        cs.OORSEExpired=true;showOORSEExpired=true;
                    }else{ 
                        cs.OORSEExpired=false; showOORSEExpired=false;
                    }
                    cs.wirelinePromoApplied = juncSite.Wireline_Promotion_Applied__c;
                }                
            }            
        }
        system.debug('###############updateCustomerSite '+ListCustomerSite );          
    }
           
    public void IntializeUI(Apttus_Config2__ProductConfiguration__c prodConfig, QuoteProducts.cCustomerSite cs){
        Set<String> nextTypeSet = null;
        Map<String,String> nextTypeSelectedProdMap = null;
        Map<String,Decimal> nextTypeSelectedPriceMap = null;
        String nextList = '';
        Set<String> setConsId = new Set<String>();
        Set<String> availProdOptions = new Set<String>();
        Set<String> availProdOptionsMain = null;
        QuoteProducts.SelectPricingWrap sPWrapTemp = null;
        String selectedProductval = null;
        cartId = prodConfig.Id;
        if(quoteObj.Product__c == ProductId__c.getValues('ASES').Product_Id__c){
            mainproductId = quoteObj.Product__c;
            cartId = prodConfig.Id;
        }
        system.debug('Inside IntializeUI--------------------------------->');
        try{
            availProdOptionsMain = Quotehelper.getAllMajorProducts(mainproductId);
            if(productOptionList!=null && mainproductId!=null ){
                sPWrapTemp = helper.getProductComponentOptionWrapper(productOptionList, mainproductId);
            }
            availProdOptions = availProdOptionsMain.clone();
            nextTypeSet = new Set<String>();
            nextTypeSelectedProdMap = new Map<String,String>();
            nextTypeSelectedPriceMap = new Map<String,decimal>();
            if(prodConfig!=null){
                if(prodConfig.Apttus_Config2__LineItems__r!=null){
                    for(Apttus_Config2__LineItem__c p: prodConfig.Apttus_Config2__LineItems__r){
                        if(cs.custSiteIns.id!=null && p.AT_T_Customer_Site__c!=null){
                            if(cs.custSiteIns.id == p.AT_T_Customer_Site__c){                   
                                if(ATTConstants.CON_SPEED.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                                    nextList = ATTConstants.CON_SPEED; 
                                    availProdOptions.remove(ATTConstants.CON_SPEED);  
                                    nextTypeSet.add(ATTConstants.CON_SPEED); 
                                    setConsId.add(p.Apttus_Config2__OptionId__c);   
                                    nextTypeSelectedProdMap.put(ATTConstants.CON_SPEED, p.Apttus_Config2__OptionId__c); 
                                    nextTypeSelectedPriceMap.put(ATTConstants.CON_SPEED, p.Apttus_Config2__NetPrice__c);                          
                                }
                                else if(ATTConstants.IP_ADD.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                                    nextList = ATTConstants.IP_ADD; 
                                    availProdOptions.remove(ATTConstants.IP_ADD);  
                                    nextTypeSet.add(ATTConstants.IP_ADD);  
                                    nextTypeSelectedProdMap.put(ATTConstants.IP_ADD, p.Apttus_Config2__OptionId__c); 
                                    nextTypeSelectedPriceMap.put(ATTConstants.IP_ADD, p.Apttus_Config2__NetPrice__c);                          
                                }
                                else if(ATTConstants.AIA_CHARGES.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                                    nextList = ATTConstants.AIA_CHARGES; 
                                    availProdOptions.remove(ATTConstants.AIA_CHARGES);  
                                    nextTypeSet.add(ATTConstants.AIA_CHARGES);  
                                    nextTypeSelectedProdMap.put(ATTConstants.AIA_CHARGES, p.Apttus_Config2__OptionId__c); 
                                    nextTypeSelectedPriceMap.put(ATTConstants.AIA_CHARGES, p.Apttus_Config2__NetPrice__c);                          
                                }
                                else if(ATTConstants.AIA_INSTALL.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                                    nextList = ATTConstants.AIA_INSTALL; 
                                    availProdOptions.remove(ATTConstants.AIA_INSTALL);  
                                    nextTypeSet.add(ATTConstants.AIA_INSTALL);  
                                    nextTypeSelectedProdMap.put(ATTConstants.AIA_INSTALL, p.Apttus_Config2__OptionId__c); 
                                    nextTypeSelectedPriceMap.put(ATTConstants.AIA_INSTALL, p.Apttus_Config2__NetPrice__c);                          
                                }else if(ATTConstants.OPTIONS.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                                    nextList = ATTConstants.OPTIONS; 
                                    availProdOptions.remove(ATTConstants.OPTIONS);                         
                                    setConsId.add(p.Apttus_Config2__OptionId__c);  
                                    setConsId.add(p.Apttus_Config2__ProductId__c);
                                    selectOptGrp = p.Apttus_Config2__OptionId__r.Name;                                                  
                                }
                            }
                        }
                    }
                }
            }
            if(!availProdOptions.isempty()){
                //create dummy options for which user has not selected
                for(String leftoption : availProdOptions){
                    if(!'Options'.equalsIgnoreCase(leftoption)){                   
                        nextTypeSet.add(leftoption);  
                        nextTypeSelectedProdMap.put(leftoption, null);  
                    }  
                } 
            }
            sitePricingMap.put(cs.custSiteIns.id, sPWrapTemp);
            sPricingWrap = sPWrapTemp;
            sPricingWrap.disableApplyBtn = true;           
            list<Integer> primaryLineNumber = helper.getPrimaryLineNumForLineItems(cartId, cs.linenumber);
            sugProdId = helper.getConstraintRuleResultNewV2(cartId, primaryLineNumber, setConsId);
            helper.setMultiSelectOptionPortSpeed(sPWrapTemp.optionsList, nextTypeSet, sugProdId, nextTypeSelectedProdMap, nextTypeSelectedPriceMap);
            filterConnectionSpeed(sPWrapTemp);
            calcSiteTotal();            
        }catch(Exception e){
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in QuoteInfoController.IntializeUI', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }        
    }
    
    public PageReference SaveandExit(){
        QuoteProducts.cCustomerSite cs = null;
        boolean flag = false;
        Map<String, String> siteLineMapTemp = new Map<String, String>();
        try{
            for(String siteIdTemp : sitePricingMap.keySet()){
                QuoteProducts.SelectPricingWrap sPricingWrapTemp = sitePricingMap.get(siteIdTemp);
                Integer indx = siteLinenumberMap.get(siteIdTemp);
                if(ListCustomerSite.size()>= indx){
                    cs = ListCustomerSite[indx - 1]; 
                    flag = Quotehelper.ValidateAnyProductHasAlreadySelected(sPricingWrapTemp);
                    if(flag){               
                        flag = Quotehelper.ValidateApply(sPricingWrapTemp, cs.custSiteIns.Site_Name__c);
                    }
                    if(!flag){ 
                        return page.PortalDashboard_UI;
                    }
                    siteLineMapTemp.put(string.valueof(cs.linenumber.intValue()),cs.custSiteIns.Id);
                } 
            } 
            if(flag){
                helper.updateLineItemWithSite(siteLineMapTemp, quoteId);
                Quotehelper.saveProductConfiguration(cartId);
            } 
        }catch(Exception e){
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in QuoteInfoController.SaveandExit', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }      
        return page.PortalDashboard_UI;
    }
    
    /***********
    * Method name : calTableList
    * Description : called from constructor for populating list.
    * Return Type : None.
    * Parameters : None.
    ***********/
    public boolean calTableList(){
        boolean isValidData = true;
        try{
            if(ApexPages.currentPage().getParameters().get('quoteId') != null){
                quoteId = ApexPages.currentPage().getParameters().get('quoteId'); 
                quoteObj = quoteHelper.getQuote(quoteId);
            }
            if(!String.isEmpty(quoteId)){            
                List<AT_T_Customer_Site_Quote__c> custSiteQuoteLst = [Select Id,Is_Soft_Deleted__c,Iglow_Response_Received_Date__c, Name,AT_T_Customer_Site__c,hub__c,AT_T_Quote__c,AT_T_Quote__r.Product__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,AT_T_Quote__r.Name,AT_T_Quote__r.Apttus_Proposal__Payment_Term__c,AT_T_Quote__r.Apttus_QPConfig__PriceListId__c,AT_T_Quote__r.Product__r.Name, AT_T_Customer_Site__r.Id, AT_T_Customer_Site__r.Name, AT_T_Customer_Site__r.Site_Name__c, AT_T_Customer_Site__r.City__c, AT_T_Customer_Site__r.Service_Availability_Response__c, AT_T_Customer_Site__r.State__c, AT_T_Customer_Site__r.Address_Line__c,AT_T_Customer_Site__r.Tier__c ,AT_T_Customer_Site__r.Building_Cili__c, AT_T_Customer_Site__r.Code_EMUX_Fiber__c,AT_T_Customer_Site__r.LATA_Number__c FROM AT_T_Customer_Site_Quote__c where AT_T_Quote__c=:quoteId];
                if(custSiteQuoteLst != null && custSiteQuoteLst.size() >0){
                    initializeCustomerSiteLst(custSiteQuoteLst);
                    custSiteQuoteIns = custSiteQuoteLst[0];
                    mainproductId = custSiteQuoteIns.AT_T_Quote__r.Product__c;
                    priceListId = custSiteQuoteIns.AT_T_Quote__r.Apttus_QPConfig__PriceListId__c;
                    siteid = custSiteQuoteIns.AT_T_Customer_Site__r.Id;
                    productOptionList = helper.getProductOptionGroupDO(mainproductId , priceListId);
                    if(String.isEmpty(mainproductId) || String.isEmpty(priceListId)){
                        isValidData = false;
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'To Run configure site product Id and pricelist Id are mandatory');
                        ApexPages.addMessage(myMsg);
                    }
                }
            }
            eligibleSites();
        }
        catch(Exception e){
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in QuoteInfoController.calTableList', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }    
        return isValidData;
    }    
    
    /***********
    * Method name : showDetail
    * Description : on clicking site this creates wrapper list.
    * Return Type : None.
    * Parameters : None.
    ***********/
    public void showDetail(){  
        try{                        
            siteVasaResValidatorIns = new SiteVasaResValidator();           
            QuoteProducts.cCustomerSite cs = null;
            if(siteid!=null){
            ethernetVal = siteIdEthernetAvailMap.get(siteid);
            if(sitePricingMap!=null ){
                if(sitePricingMap.get(siteid)!=null){
                    sPricingWrap = sitePricingMap.get(siteid); 
                }               
            }else{
                Integer indx = siteLinenumberMap.get(siteid); 
                if(indx != null){
                    cs = ListCustomerSite[indx - 1];
                }
                if(cs!= null && (cs.linenumber == null || cs.linenumber == 0)){
                    lineNumbersLst = helper.addMainProductIntoBundle(cs.custSiteIns , mainproductId , cartId);
                    cs.linenumber = lineNumbersLst[0];
                    if(productOptionList!=null && mainProductId!=null){
                        sPricingWrap = helper.getProductComponentOptionWrapper(productOptionList,mainProductId);
                        sPricingWrap.disableApplyBtn = false; 
                    }
                    if(mainproductId == ProductId__c.getValues('AIA').Product_Id__c){                        
                        popMapforAIA(cs.linenumber,quoteId);
                        helper.getSelectOptionPortSpeed(sPricingWrap.optionsList,ethernetVal, ATTConstants.CON_SPEED);
                        for(QuoteProducts.ProductOption tempProdOpt : sPricingWrap.optionsList){                  
                            if(tempProdOpt.name.equalsIgnoreCase(ATTConstants.CON_SPEED) && tempProdOpt.showListOption == true){
                               tempProdOpt.prodOptnsLst = siteVasaResValidatorIns.brassResValidator(siteid,tempProdOpt.prodOptnsLst);
                            }
                        }
                        helper.getSelectOptionPortSpeed(sPricingWrap.optionsList,ethernetVal, ATTConstants.IP_ADD);
                        helper.getSelectOptionPortSpeed(sPricingWrap.optionsList,ethernetVal, ATTConstants.AIA_CHARGES);
                        helper.getSelectOptionPortSpeed(sPricingWrap.optionsList,ethernetVal, ATTConstants.AIA_INSTALL);
                    }
                    else if(mainproductId == ProductId__c.getValues('ASES').Product_Id__c){
                        helper.getSelectOptionPortSpeed(sPricingWrap.optionsList,ethernetVal, ATTConstants.PORT_SPEED);
                    }else{
                        helper.getSelectOptionPortType(sPricingWrap.optionsList,ethernetVal, ATTConstants.PORT_TYPE);
                    }
                    sitePricingMap.put(siteid, sPricingWrap);
                }else if(mainproductId != null){
                    Apttus_Config2__ProductConfiguration__c prodConfig = quoteHelper.retrieveExistingCartId(quoteId);
                    if(prodConfig!=null && cs!=null){
                       IntializeUI(prodConfig, cs);
                    }
                }
            }
            calcSiteTotal();
            }
        }
        catch(Exception e){
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in QuoteInformationController.showDetail', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /***********
    * Method name : calcSiteTotal
    * Description : to calculate total for respective sites.
    * Return Type : None.
    * Parameters : None.
    ***********/
    public void calcSiteTotal(){
        siteTotal = 0;
        Decimal tprice = 0;
        try{
            if(sitePricingMap!=null && siteId!=null ){
                if(sitePricingMap.get(siteid)!=null){
                    QuoteProducts.SelectPricingWrap sPricingWrapTemp = sitePricingMap.get(siteid);
                    if(sPricingWrapTemp != null && sPricingWrapTemp.optionsList != null){
                        for(QuoteProducts.ProductOption tempVal: sitePricingMap.get(siteid).optionsList){  
                            tprice =  QuoteHelper.checkNull(tempVal.price);                              
                            siteTotal+= tprice ;
                        } 
                    }
                } 
            }  
        }catch(Exception e){
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in QuoteInformationController.calcSiteTotal', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }                   
    }    
    
    /***********
    * Method name : selectedOptGrpQuery
    * Description : This method will fetch the price according to value selected.
    * Return Type : None.
    * Parameters : None.
    ***********/
    private List<System.SelectOption> temp = new List<System.SelectOption>();  
                
    public void selectedOptGrpQuery(){  
        try{
            Boolean optionsChecked = false;
            String nextList = '';
            Set<String> setConsId = new Set<String>();
            QuoteProducts.cCustomerSite cs = null;
            Integer indx = siteLinenumberMap.get(siteId);
            cs = ListCustomerSite[indx - 1];
            if(sPricingWrap.disableApplyBtn == true){                
                cs.isProcessed = false;
            }
            sPricingWrap.disableApplyBtn = false;
            if(mainproductId == ProductId__c.getValues('AIA').Product_Id__c){               
                if(selectOptGrp == 'Dynamic' || selectOptGrp == 'Static'){
                    updateAttrRec(cs.linenumber.intValue(),selectOptGrp);
                    Quotehelper.makeSelectedProductOptionsEmptyUI(sPricingWrap , ATTConstants.CON_SPEED);
                    Quotehelper.makeSelectedProductOptionsEmptyUI(sPricingWrap , ATTConstants.AIA_CHARGES);
                    Quotehelper.makeSelectedProductOptionsEmptyUI(sPricingWrap , ATTConstants.IP_ADD);
                    Quotehelper.makeSelectedProductOptionsEmptyUI(sPricingWrap , ATTConstants.AIA_INSTALL);
                    setConsId.add(selectOptGrpVal);  
                    setConsId.add(mainproductId);
                }
            }
            QuoteProducts.ProductOption selectedProduct = helper.getSelectedProduct(sPricingWrap.optionsList, selectOptGrp, selectOptGrpVal);
            if(selectedProduct != null){
                helper.createLineItem(quoteId, cs.linenumber.intValue(), selectOptGrp, cartId, selectedProduct); 
                if(mainproductId == ProductId__c.getValues('AIA').Product_Id__c){
                    popMapforAIA(null,quoteId);
                    
                }
                list<Integer> primaryLineNumber = helper.getPrimaryLineNumForLineItems(cartId, cs.linenumber);
                sugProdId = helper.getConstraintRuleResultNewV2(cartId, primaryLineNumber, setConsId);
            } 
            if(ATTConstants.PORT_TYPE.equals(selectOptGrp)) {
                nextList = ATTConstants.PORT_SPEED;                                          
            }else if(ATTConstants.PORT_SPEED.equals(selectOptGrp)){
                if(mainproductId == ProductId__c.getValues('ASES').Product_Id__c){
                    nextList = 'Serving Arrangement';
                }else{
                    nextList = ATTConstants.ACCESS_TYPE;
                }                
            }else if(selectOptGrp == 'Serving Arrangement' && selectOptGrpVal == ProductId__c.getValues('Basic').Product_Id__c){                
                nextList = 'Class of Service (Basic)';                 
            }else if(selectOptGrp == 'Serving Arrangement' && selectOptGrpVal == ProductId__c.getValues('Per Packet').Product_Id__c){                  
                nextList = 'Class of Service (Per Packet)';                          
            }else if(selectOptGrp == 'Class of Service (Per Packet)' || selectOptGrp == 'Class of Service (Basic)'){               
                nextList = 'CIR';                            
            }else if(selectOptGrp == 'CIR'){               
                nextList = ATTConstants.INTERFACE_TYPE;
                cs.CIRVal = selectedProduct.Name; 
                cs.CIRSubset = helper.getCIROption(sPricingWrap.optionsList ,  selectOptGrpVal);                      
            }else if(ATTConstants.ACCESS_TYPE.equals(selectOptGrp)){
                nextList = ATTConstants.ACCESS_SPEED; 
                sPricingWrap.portTypeName = selectedProduct.name; 
            }else if(ATTConstants.ACCESS_SPEED.equals(selectOptGrp)){
                nextList = ATTConstants.INTERFACE_TYPE;    
            }else if(ATTConstants.INTERFACE_TYPE.equals(selectOptGrp) && mainproductId != ProductId__c.getValues('ASES').Product_Id__c){
                nextList = ATTConstants.INSTALLATION_OPTIONS;
            }else if(ATTConstants.INTERFACE_TYPE.equals(selectOptGrp) && mainproductId == ProductId__c.getValues('ASES').Product_Id__c){
                nextList = 'MAC Limit';
            }else if(ATTConstants.INSTALLATION_OPTIONS.equals(selectOptGrp)){
                nextList = ATTConstants.MIN_BANDWIDTH_COM;
            }          
            
            if(!ATTConstants.DSELECT.equals(selectOptGrpVal) && mainproductId == ProductId__c.getValues('AIA').Product_Id__c && (selectOptGrp == 'Dynamic' || selectOptGrp == 'Static')){                
                helper.getSelectOptionPortSpeedNew(sPricingWrap.optionsList , ATTConstants.IP_ADD, sugProdId, selectOptGrp, selectOptGrpVal);               
                helper.getSelectOptionPortSpeedNew(sPricingWrap.optionsList , ATTConstants.AIA_INSTALL, sugProdId, selectOptGrp, selectOptGrpVal);                                              
                Integer index=-1;
                Integer broadbandIndex = -1;
                for (QuoteProducts.Productoption optgrp: sPricingWrap.optionsList){
                    if (optgrp.name.equals(ATTConstants.CON_SPEED)){                        
                        for (SelectOption item : optgrp.prodOptnsLst){ 
                            index++;       
                            if (item.getLabel() == '768K (Broadband)'){
                                broadbandIndex = index;
                                if(temp==NULL || temp.size()==0){
                                    temp.add(item);
                                }
                            }                              
                        }
                        if (broadbandIndex >-1 && selectOptGrp == 'Static'){
                            optgrp.prodOptnsLst.remove(broadbandIndex);
                        }else if (broadbandIndex == -1 && selectOptGrp == 'Dynamic'){
                            if(temp!=NULL && temp.size()>0){
                                optgrp.prodOptnsLst.add(1,temp[0]);
                            }
                        }
                    }
                }              
            }else if(!ATTConstants.DSELECT.equals(selectOptGrpVal) && mainproductId == ProductId__c.getValues('AIA').Product_Id__c && ATTConstants.CON_SPEED.equals(selectOptGrp)){                
                helper.getSelectOptionPortSpeedNew(sPricingWrap.optionsList , ATTConstants.AIA_CHARGES, sugProdId, selectOptGrp, selectOptGrpVal);
            }else if(!ATTConstants.DSELECT.equals(selectOptGrpVal)){
                helper.getSelectOptionPortSpeedNew(sPricingWrap.optionsList , nextList, sugProdId, selectOptGrp, selectOptGrpVal);
                if(nextList == ATTConstants.MIN_BANDWIDTH_COM && mainproductId == ProductId__c.getValues('AMIS').Product_Id__c){                    
                    nextList = 'Additional DNS';
                    helper.getSelectOptionPortSpeedNew(sPricingWrap.optionsList , nextList, sugProdId, selectOptGrp, selectOptGrpVal);
                }
            }
            if(ATTConstants.CON_SPEED.equals(selectOptGrp)){
                boolean pricingFlag = helper.computePrice(cartId,cs.linenumber.intvalue());
                quotehelper.updateLineItemPriceUI(cs.linenumber.intValue(), cartId, sPricingWrap);//no DML only update to temp data
            }            
            calcSiteTotal();
            grandTotalPopulate();
            
        }
        catch(Exception e){
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in QuoteInformationController.selectedOptGrpQuery', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }    
  
    /***********
    * Method name : grandTotalPopulate
    * Description : to calculate grand total.
    * Return Type : None.
    * Parameters : None.
    ***********/
    public void grandTotalPopulate(){
        try{
            grandTot = 0;
            Decimal tprice = 0;
            for(String tempSelPriWrap: sitePricingMap.keyset()){
                QuoteProducts.SelectPricingWrap sPricingWrapTemp = sitePricingMap.get(tempSelPriWrap);
                if(sPricingWrapTemp != null && sPricingWrapTemp.optionsList != null){                
                    for(QuoteProducts.ProductOption tempVal: sitePricingMap.get(tempSelPriWrap).optionsList){
                        tprice =  QuoteHelper.checkNull(tempVal.price);               
                        grandTot+= tprice;
                    } 
                }          
            }
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.grandTotalPopulate', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }  
        
    /***********
    * Method name : eligibleSites
    * Description : This will populate map with eligible sites.
    * Return Type : void.
    * Parameters : None.
    ***********/
    public void eligibleSites(){
        try{
            List<CustomerSite__c> customerSiteList = getCustomerSiteLst();
            SiteVasaResValidator siteVasaResValidatorIns = new SiteVasaResValidator();
            siteIdEthernetAvailMap = siteVasaResValidatorIns.custSiteEligible(customerSiteList);
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.eligibleSites', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /***********
    * Method name : eligibleSitesApply
    * Description : This will be called when apply button on pop up is clicked.
    * Return Type : void.
    * Parameters : None.
    ***********/
    public void eligibleSitesApply(){
        system.debug('@@@^ inside eligibleSitesApply');
        selctedsiteAVRecords = [select Id,CoS__c,Hi_Cap_Flex__c,Tier_1_Suffix__c,Tier_2_Suffix__c,Tier_3_Suffix__c,UBB_Speed_MIS__c,UBB_Speed_AVPN__c,VLANs_Logical_Channels__c, Access_Speed_AVPN__c,Access_Speed_MIS__c,Apttus_Config2__Vendor__c, VASA_Region__c, Port_Speed_AVPN__c, Port_Speed_MIS__c, Port_Type_AVPN__c, Port_Type_MIS__c, Interface_Type__c, Interface_Type_AVPN__c, Access_Type__c, Access_Type_AVPN__c, Additional_DNS__c, Install_Option_MIS__c, Install_Option_AVPN__c, Managed_Router__c,ServiceType__c,PortSpeedASE__c,Term__c,Tier__c,InterfaceTypeASE__c,Class_of_Service_TypeASE__c,Class_of_ServiceASE__c,Network_TypeASE__c,LATA__c,Config_TypeASE__c,Port_VLAN_BasedASE__c,MAC_AddressesASE__c,Contract_Number__c,CNUM_Rate_Card__c,Site_DesignationASE__c,CIR__c,IsPromotional__c,LATA_Number__c from Apttus_Config2__ProductAttributeValue__c where AT_T_Customer_Site__c =: selectedSiteId and cartId__c = :cartId order by LastModifiedDate DESC limit 1];
        siteLstNeedsToBeAdded = new List<QuoteProducts.cCustomerSite>();
        List<Decimal> siteLstNeedsToBeDeleted = new List<Decimal>();
        Map<String, String> siteLineMapTemp = new Map<String, String>();
        Map<Id, String> tierAVRecordMap = new Map<id, String>();
        Map<Id, String> lataNumberAVRecordMap = new Map<id, String>();
        Integer count = 0;
        List<Apttus_Config2__LineItem__c> lineItemsRevertList =[Select Id,Apttus_Config2__PricingStatus__c,AT_T_Customer_Site__c,Apttus_Config2__LineNumber__c,Apttus_Config2__ChargeType__c,Apttus_Config2__PrimaryLineNumber__c from Apttus_Config2__LineItem__c where  Apttus_Config2__ConfigurationId__c=:cartId];
        for( Apttus_Config2__LineItem__c lineItemsRevert : lineItemsRevertList ){
            lineItemsRevert.IsBatchUpdate__c = false;
        }
        if(lineItemsRevertList.size()>0){
            if(!test.isRunningTest()){
                update lineItemsRevertList ;
            }
        }
        set<Id> selectedSiteIdOnApply = new set<Id>();
        try{
            for(QuoteProducts.cCustomerSite temp: listCustomerSiteMaster){
                for(QuoteProducts.cCustomerSite csAll : ListCustomerSite){
                    if(temp.custSiteIns.Id == csAll.custSiteIns.Id){
                        tierAVRecordMap.put(temp.custSiteIns.Id,temp.custSiteIns.Tier__c);
                        lataNumberAVRecordMap.put(temp.custSiteIns.Id,temp.custSiteIns.LATA_Number__c);                         
                        if(allEligibleSelected==true){
                            if(temp.eligibleSFlag==false){
                                siteLstNeedsToBeAdded.add(temp);
                                sitePricingMap.put(temp.custSiteIns.Id,null);      
                                if( lineNumbersNeedsToBeDeleted.get(temp.custSiteIns.Id) != null ) {              
                                    siteLstNeedsToBeDeleted.add(lineNumbersNeedsToBeDeleted.get(temp.custSiteIns.Id));
                                }
                                else{
                                    siteLstNeedsToBeDeleted.add(temp.linenumber);
                                }
                                temp.eligibleSelected = false;
                            }
                        }
                        else if(temp.selected){
                            siteLstNeedsToBeAdded.add(temp);
                            sitePricingMap.put(temp.custSiteIns.Id,null);      
                            if( lineNumbersNeedsToBeDeleted.get(temp.custSiteIns.Id) != null ) {              
                                siteLstNeedsToBeDeleted.add(lineNumbersNeedsToBeDeleted.get(temp.custSiteIns.Id));
                            }
                            else{
                                 siteLstNeedsToBeDeleted.add(temp.linenumber);
                            }
                            temp.eligibleSelected = false;
                        }
                        break;
                    }
                }             
            }
            
            if(siteLstNeedsToBeDeleted.size()>0){
                helper.removeMultiBundles(cartId, siteLstNeedsToBeDeleted);
            }
            
            if( siteLstNeedsToBeAdded.size() > 0 ) {
                for(QuoteProducts.cCustomerSite temp: siteLstNeedsToBeAdded){
                    selectedSiteIdOnApply.add(temp.custSiteIns.Id);  
                }
                filterSitesEligibleForIglooCall(true);
                set<Id> iglooSiteIdOnApply = new set<Id>();
                if(IglooSiteLst!=null && IglooSiteLst.size()>0){
                    for(QuoteProducts.cCustomerSite temp: IglooSiteLst){
                        iglooSiteIdOnApply.add(temp.custSiteIns.Id);   
                    }
                }
                set<Id> noniglooSiteIdOnApply = new set<Id>();
                if(nonIglooSiteLst !=null && nonIglooSiteLst .size()>0){
                    for(QuoteProducts.cCustomerSite temp: nonIglooSiteLst ){
                       noniglooSiteIdOnApply.add(temp.custSiteIns.Id);   
                    }
                }
                
                list<AT_T_Customer_Site_Quote__c> nonIgloositeQuoteList = new list<AT_T_Customer_Site_Quote__c>();
                if(noniglooSiteIdOnApply!=null && noniglooSiteIdOnApply.size()>0){
                    nonIgloositeQuoteList = [select id, AT_T_Customer_Site__c, AT_T_Quote__c, Igloo_Review_Required__c from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c In: noniglooSiteIdOnApply and AT_T_Quote__c =: quoteId];
                }   
                List<Integer> linumbersLst = createLiteItemOnApply(cartId, selectedProductId, null , siteLstNeedsToBeAdded );
                for(QuoteProducts.cCustomerSite temp: siteLstNeedsToBeAdded){
                    for(QuoteProducts.cCustomerSite csAll : ListCustomerSite){
                        if(temp.custSiteIns.Id == csAll.custSiteIns.Id){ 
                            temp.linenumber = linumbersLst[count];
                            csAll.linenumber = temp.linenumber;
                            siteLineMapTemp.put(string.valueof(temp.linenumber.intValue()), temp.custSiteIns.Id);
                        }
                    }
                    count++;    
                }
                List<Apttus_Config2__LineItem__c> lineItemList=[Select Id,Apttus_Config2__PricingStatus__c,AT_T_Customer_Site__c,Apttus_Config2__LineNumber__c,Apttus_Config2__ChargeType__c,Apttus_Config2__PrimaryLineNumber__c from Apttus_Config2__LineItem__c where Apttus_Config2__PrimaryLineNumber__c=:linumbersLst and Apttus_Config2__ConfigurationId__c=:cartId];
                for(Apttus_Config2__LineItem__c lineItems : lineItemList){
                    lineItems.Apttus_Config2__LineNumber__c = lineItems.Apttus_Config2__PrimaryLineNumber__c;
                    lineItems.AT_T_Customer_Site__c = siteLineMapTemp.get(String.valueOf(lineItems.Apttus_Config2__PrimaryLineNumber__c));
                }
                update lineItemList;
                
                list<Apttus_Config2__ProductAttributeValue__c> updateAVValues = [select Id, mileage__c, AT_T_Customer_Site__c, Line_Number__c, Apttus_Config2__Vendor__c, VASA_Region__c, Port_Speed_AVPN__c, Port_Speed_MIS__c, Port_Type_AVPN__c, Port_Type_MIS__c, Interface_Type__c, Interface_Type_AVPN__c, Access_Type__c, Access_Type_AVPN__c, Additional_DNS__c, Install_Option_MIS__c, Install_Option_AVPN__c, UBB_Speed_MIS__c,UBB_Speed_AVPN__c,Managed_Router__c,ServiceType__c,PortSpeedASE__c,Term__c,Tier__c,InterfaceTypeASE__c,Class_of_Service_TypeASE__c,Class_of_ServiceASE__c,Network_TypeASE__c,LATA__c,Config_TypeASE__c,Port_VLAN_BasedASE__c,MAC_AddressesASE__c,Contract_Number__c,CNUM_Rate_Card__c,Site_DesignationASE__c,CIR__c,Tier_1_Suffix__c,Tier_2_Suffix__c,Tier_3_Suffix__c,IsPromotional__c,LATA_Number__c  from Apttus_Config2__ProductAttributeValue__c where AT_T_Customer_Site__c IN :selectedSiteIdOnApply and CartId__c=:cartId ];
                siteMap = new Map<Id,CustomerSite__c>([select id,VASAResponse__c,Service_Availability_Response__c,LATA_Number__c from CustomerSite__c where id IN :selectedSiteIdOnApply]);
                for(CustomerSite__c cs:siteMap.Values()){
                    JSONResponse = siteMap.get(cs.id).Service_Availability_Response__c;
                    if (String.isNotBlank(JSONResponse)){
                        JSONResponse = JSONResponse.replaceAll(regExp,'"');
                        AddrValidServAvailResponseBean ResponseBean = new AddrValidServAvailResponseBean();
                        ResponseBean = (AddrValidServAvailResponseBean)JSON.Deserialize(JSONResponse,AddrValidServAvailResponseBean.class);
                        AddressServiceAvailabilityList = ResponseBean.AddressServiceAvailability;                
                        AddrValidServAvailResponseBean.ServiceAvailabilityDetails ServiceAvailabilityDetailsObj = new AddrValidServAvailResponseBean.ServiceAvailabilityDetails(); 
                        
                        if(AddressServiceAvailabilityList!=null && AddressServiceAvailabilityList.size()>0){
                            for (AddrValidServAvailResponseBean.AddressServiceAvailability response: AddressServiceAvailabilityList) {              
                                lecscopeList.add(response.lecName);
                            }
                        }
                    }
                }
                if(lecscopeList.size()>0){
                    pgList = [Select lecName__c, Interface_Type__c, Speed__c, VASA_Region__c from Provider_Grouping__c where lecName__c IN : lecscopeList];
                }
                for( Apttus_Config2__ProductAttributeValue__c updateAtrributes : updateAVValues ){
                    updateAtrributes.Port_Speed_AVPN__c = selctedsiteAVRecords.Port_Speed_AVPN__c;
                    updateAtrributes.Port_Speed_MIS__c = selctedsiteAVRecords.Port_Speed_MIS__c;
                    updateAtrributes.Port_Type_AVPN__c = selctedsiteAVRecords.Port_Type_AVPN__c;
                    updateAtrributes.Port_Type_MIS__c = selctedsiteAVRecords.Port_Type_MIS__c;
                    updateAtrributes.Interface_Type__c = selctedsiteAVRecords.Interface_Type__c;
                    updateAtrributes.Interface_Type_AVPN__c = selctedsiteAVRecords.Interface_Type_AVPN__c;
                    updateAtrributes.Access_Type__c = selctedsiteAVRecords.Access_Type__c;
                    updateAtrributes.Access_Type_AVPN__c = selctedsiteAVRecords.Access_Type_AVPN__c;
                    updateAtrributes.Additional_DNS__c = selctedsiteAVRecords.Additional_DNS__c;
                    updateAtrributes.Install_Option_MIS__c = selctedsiteAVRecords.Install_Option_MIS__c;
                    updateAtrributes.Install_Option_AVPN__c  = selctedsiteAVRecords.Install_Option_AVPN__c;
                    updateAtrributes.Access_Speed_AVPN__c = selctedsiteAVRecords.Access_Speed_AVPN__c;
                    updateAtrributes.Access_Speed_MIS__c = selctedsiteAVRecords.Access_Speed_MIS__c;
                    updateAtrributes.CoS__c = selctedsiteAVRecords.CoS__c;
                    updateAtrributes.VLANs_Logical_Channels__c = selctedsiteAVRecords.VLANs_Logical_Channels__c ;
                    updateAtrributes.Hi_Cap_Flex__c = selctedsiteAVRecords.Hi_Cap_Flex__c;
                    updateAtrributes.UBB_Speed_MIS__c = selctedsiteAVRecords.UBB_Speed_MIS__c;
                    updateAtrributes.UBB_Speed_AVPN__c = selctedsiteAVRecords.UBB_Speed_AVPN__c;
                    updateAtrributes.Managed_Router__c = selctedsiteAVRecords.Managed_Router__c;
                    
                    if(isASE == true){                         
                        updateAtrributes.ServiceType__c   = selctedsiteAVRecords.ServiceType__c;        
                        updateAtrributes.PortSpeedASE__c  = selctedsiteAVRecords.PortSpeedASE__c  ;     
                        updateAtrributes.Term__c    = selctedsiteAVRecords.Term__c;
                        if(updateAtrributes.Tier__c == null || updateAtrributes.Tier__c == ''){     
                            updateAtrributes.Tier__c  = tierAVRecordMap.get(updateAtrributes.AT_T_Customer_Site__c);     
                        }
                        updateAtrributes.LATA_Number__c = lataNumberAVRecordMap.get(updateAtrributes.AT_T_Customer_Site__c);
                        updateAtrributes.IsPromotional__c   = selctedsiteAVRecords.IsPromotional__c ;
                        updateAtrributes.InterfaceTypeASE__c  = selctedsiteAVRecords.InterfaceTypeASE__c  ;     
                        updateAtrributes.CIR__c     = selctedsiteAVRecords.CIR__c;      
                        updateAtrributes.Class_of_Service_TypeASE__c = selctedsiteAVRecords.Class_of_Service_TypeASE__c;        
                        updateAtrributes.Class_of_ServiceASE__c = selctedsiteAVRecords.Class_of_ServiceASE__c;      
                        updateAtrributes.Network_TypeASE__c = selctedsiteAVRecords.Network_TypeASE__c;      
                        updateAtrributes.LATA__c = selctedsiteAVRecords.LATA__c;    
                        updateAtrributes.LATA_Number__c=siteMap.get(updateAtrributes.AT_T_Customer_Site__c).LATA_Number__c;      
                        updateAtrributes.Config_TypeASE__c = selctedsiteAVRecords.Config_TypeASE__c;        
                        updateAtrributes.Port_VLAN_BasedASE__c = selctedsiteAVRecords.Port_VLAN_BasedASE__c;        
                        updateAtrributes.MAC_AddressesASE__c = selctedsiteAVRecords.MAC_AddressesASE__c;        
                        updateAtrributes.Contract_Number__c = selctedsiteAVRecords.Contract_Number__c;      
                        updateAtrributes.CNUM_Rate_Card__c = selctedsiteAVRecords.CNUM_Rate_Card__c;        
                        updateAtrributes.Site_DesignationASE__c = selctedsiteAVRecords.Site_DesignationASE__c; 
                        updateAtrributes.Tier_1_Suffix__c=selctedsiteAVRecords.Tier_1_Suffix__c;
                        updateAtrributes.Tier_2_Suffix__c=selctedsiteAVRecords.Tier_2_Suffix__c;
                        updateAtrributes.Tier_3_Suffix__c=selctedsiteAVRecords.Tier_3_Suffix__c; 
                    }
                    lineItemNumbersToPrice.add((Integer)updateAtrributes.Line_Number__c);
                    
                    JSONResponse = siteMap.get(updateAtrributes.AT_T_Customer_Site__c).Service_Availability_Response__c;
                    if (String.isNotBlank(JSONResponse)){
                        if(isAvpn){
                            accessType=updateAtrributes.Access_Type_AVPN__c;
                        }else if (isMIS){
                            accessType=updateAtrributes.Access_Type__c;
                        }
                        JSONResponse = JSONResponse.replaceAll(regExp,'"');
                        AddrValidServAvailResponseBean ResponseBean = new AddrValidServAvailResponseBean();
                        ResponseBean = (AddrValidServAvailResponseBean)JSON.Deserialize(JSONResponse,AddrValidServAvailResponseBean.class);
                        AddressServiceAvailabilityList = ResponseBean.AddressServiceAvailability;                
                        AddrValidServAvailResponseBean.ServiceAvailabilityDetails ServiceAvailabilityDetailsObj = new AddrValidServAvailResponseBean.ServiceAvailabilityDetails(); 
                        
                        if(AddressServiceAvailabilityList!=null && AddressServiceAvailabilityList.size()>0){
                            for(AddrValidServAvailResponseBean.AddressServiceAvailability response: AddressServiceAvailabilityList){ 
                                if(response.region=='Y'){
                                    updateAtrributes.VASA_Region__c = 'In Region';
                                    updateAtrributes.Apttus_Config2__Vendor__c='AT&T';
                                }else if (response.region =='N' || response.region == 'O'){
                                    if(accessType=='Private Line' ){
                                        if(response.lecName.equalsIgnoreCase('Verizon') || response.lecName.equalsIgnoreCase('Cincinnati Bell') || response.lecName.equalsIgnoreCase('CenturyLink') || response.lecName.equalsIgnoreCase('Qwest')){
                                            updateAtrributes.VASA_Region__c = ATT_Constant.OUT_REGIONLine_1;                                
                                        }else{
                                            updateAtrributes.VASA_Region__c= ATT_Constant.OUT_REGIONLine_2;        
                                        }
                                    }else{
                                        lecNameLst.add(response.lecName);
                                    }
                                    if( accessType != null && accessType.equalsIgnoreCase('Switched Ethernet')){
                                        updateAtrributes.Iglow_Call_Date__c=system.today();
                                    }
                                }
                                if(updateAtrributes.Apttus_Config2__Vendor__c==null && response.lecName!=null){  
                                    updateAtrributes.Apttus_Config2__Vendor__c=response.lecName.toUpperCase();
                                } 
                                AddrValidServAvailResponseBean.ServiceAvailabilityDetails avs = response.ServiceAvailabilityDetails;
                                system.debug('@@@SiteConfigureController - avs: '+avs);
                                if(avs != null){
                                    if(avs.Ethernet != null && accessType!='Private Line'){
                                        system.debug('@@@SiteConfigureController - Ethernet: '+avs.Ethernet.mileage);
                                        updateAtrributes.mileage__c = String.isempty(avs.Ethernet.mileage) ? null : decimal.valueOf(avs.Ethernet.mileage);
                                        break;
                                    }else if( avs.PrivateLine != null && avs.PrivateLine.size()>0){
                                        system.debug('@@@SiteConfigureController - Private Line: '+avs.PrivateLine[0].mileage);
                                        updateAtrributes.mileage__c = avs.PrivateLine[0].mileage == null ? null : decimal.valueOf(avs.PrivateLine[0].mileage);
                                        break;
                                    }
                                }
                            }
                            if(updateAtrributes.Mileage__c == null && accessType == 'Private Line' && AddressServiceAvailabilityList[1].ServiceAvailabilityDetails != null && AddressServiceAvailabilityList[1].ServiceAvailabilityDetails.PrivateLine != null && AddressServiceAvailabilityList[1].ServiceAvailabilityDetails.PrivateLine.size() > 0 && AddressServiceAvailabilityList[1].ServiceAvailabilityDetails.PrivateLine[0].mileage != null){
                                updateAtrributes.Mileage__c = Decimal.valueOf(AddressServiceAvailabilityList[1].ServiceAvailabilityDetails.PrivateLine[0].mileage);
                                system.debug('@@@updateAtrributes.Mileage__c: '+updateAtrributes.Mileage__c);
                            }
                        }     
                    }
                    
                    if(lecNameLst!=null && pgList.size()>0){
                        String Region;
                        String interfaceType;
                        Decimal accessSpeed;
                        String accessSubsVal;
                        String accessSpeedVal;
                        Decimal speed;
                        if(updateAtrributes.Access_Speed_MIS__c!=null){
                            accessSpeedVal=updateAtrributes.Access_Speed_MIS__c;
                            accessSubsVal=accessSpeedVal.substring(accessSpeedVal.indexOf('(')+1,accessSpeedVal.indexOf('Mbps'));
                            accessSubsVal= accessSubsVal.indexOf('.') < 0 ? accessSubsVal: accessSubsVal.replaceAll('0*$', '').replaceAll('\\.$', '');
                            accessSpeed =Decimal.ValueOf(accessSubsVal.TRIM());
                        }else if(updateAtrributes.Access_Speed_AVPN__c!=null){
                            accessSpeedVal=updateAtrributes.Access_Speed_AVPN__c;
                            accessSubsVal=accessSpeedVal.substring(accessSpeedVal.indexOf('(')+1,accessSpeedVal.indexOf('Mbps'));
                            accessSubsVal= accessSubsVal.indexOf('.') < 0 ? accessSubsVal: accessSubsVal.replaceAll('0*$', '').replaceAll('\\.$', '');
                            accessSpeed=Decimal.ValueOf(accessSubsVal.TRIM());
                        }
                        if(updateAtrributes.Interface_Type__c!=null){
                            interfaceType=updateAtrributes.Interface_Type__c;
                        }else if(updateAtrributes.Interface_Type_AVPN__c!=null){
                            interfaceType=updateAtrributes.Interface_Type_AVPN__c;
                        }
                        if(interfaceType != null){
                            for(Provider_Grouping__c pg:pgList){
                                speed = String.isempty(pg.Speed__c)? 0 : Decimal.valueof(pg.Speed__c);
                                if(updateAtrributes.Apttus_Config2__Vendor__c==pg.lecName__c && accessSpeed == speed && interfaceType != null && interfaceType.contains(pg.Interface_Type__c)){
                                    if(pg.VASA_Region__c == ATT_Constant.OUT_REGION_1){
                                        updateAtrributes.VASA_Region__c = ATT_Constant.OUT_REGIONLine_1;
                                        region=updateAtrributes.VASA_Region__c;
                                    }
                                    if(pg.VASA_Region__c == ATT_Constant.OUT_REGION_1A){
                                        updateAtrributes.VASA_Region__c  = ATT_Constant.OUT_REGIONLine_1A;
                                        region=updateAtrributes.VASA_Region__c;
                                    }
                                    if(pg.VASA_Region__c == ATT_Constant.OUT_REGION_2){
                                        updateAtrributes.VASA_Region__c  = ATT_Constant.OUT_REGIONLine_2;
                                        region=updateAtrributes.VASA_Region__c;
                                    }
                                }
                            }
                            if(String.isempty(region)){
                                if(updateAtrributes.VASA_Region__c == null){
                                    updateAtrributes.VASA_Region__c = 'No Match['+updateAtrributes.Apttus_Config2__Vendor__c+'-'+accessSpeed+'-'+interfaceType+']';
                                }
                            }   
                        }
                    } 
                }
                update updateAVValues;
                system.debug('@@@^updateAVValues'+updateAVValues);
                
                if(nonIgloositeQuoteList.size()>0 && nonIgloositeQuoteList!=null){
                    for(AT_T_Customer_Site_Quote__c siteQuote : nonIgloositeQuoteList){
                        siteQuote.Igloo_Review_Required__c = false;
                    }
                    update nonIgloositeQuoteList;
                }
                set<id> iglooAVId = new set<id>();
                list<Apttus_Config2__ProductAttributeValue__c> iglooAVValues = [select Id  from Apttus_Config2__ProductAttributeValue__c where AT_T_Customer_Site__c IN :iglooSiteIdOnApply and CartId__c=:cartId ];
                for(Apttus_Config2__ProductAttributeValue__c av :iglooAVValues){
                    iglooAVId.add(av.id); 
                }
                Admin_Control__c adminControl = [select id, Config_Offline_Threshold__c, OOR_Offline_Threshold__c from Admin_Control__c limit 1];                       
                String offlineCount = adminControl.Config_Offline_Threshold__c+'';
                String iglooOfflineCount = adminControl.OOR_Offline_Threshold__c+'';
                
                if(!test.isRunningTest()){
                    System.debug('@@@iglooAVId: '+iglooAVId );
                    ID batchprocessid = database.executeBatch(new ApplyPricesForBulkSites(linumbersLst,cartId,isASE,iglooAVId ,siteQuoteJunctionId),1);                    
                    if(offlineCount!=null && offlineCount!='' && siteLstNeedsToBeAdded.size()> Integer.valueof(offlineCount) && isASE == false){                  
                        if(!(quoteId!=null && quoteId!='')){
                            quoteID=apexpages.currentpage().getparameters().get('quoteid');
                        }
                        Apttus_Proposal__Proposal__c quoteProposalObj= proposalObject;
                        quoteProposalObj.Apttus_Proposal__Approval_Stage__c=BuyflowConstant.BULKSERVICE_AVAILABILITY_REQUESTED;
                        quoteProposalObj.Is_Offline_Config_Completed__c=false;
                        update quoteProposalObj;
                        isOfflineMode = true;
                    }
                }
                if(iglooAVId.size() > Integer.valueOf(iglooOfflineCount) && isASE == false){    
                    system.debug('@@inside igloo offline');   
                    updateQStageForIgloo();    
                }  
            }
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.eligibleSitesApply', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }    
    
    /*Method to redirect to Offline Page based on Number of Offline Igloo calls */      
    public void updateQStageForIgloo(){     
        isOfflineMode = true;      
        try{        
            quoteObj.Apttus_Proposal__Approval_Stage__c = 'Bulk Service Availability Requested';        
            quoteObj.vasa_modeB_request__c= true;       
            update quoteObj;        
        }catch(Exception e){        
            system.debug('Exception Caught inside redirectForOfflineIgloo method of SiteconfigureController at line '+e.getLineNumber()+' Message: '+e.getMessage());       
        }       
    }
    
    /***********
    * Method name : eligibleSitesPop
    * Description : This will populate the list shwon in the datatable.
    * Return Type : void.
    * Parameters : None.
    ***********/    
    public void eligibleSitesPop(){
        try{
            eligibleSitesLst = new List< QuoteProducts.cCustomerSite>();
            QuoteProducts.cCustomerSite cs = null;
            QuoteProducts.cCustomerSite csn = null;
            Integer indx = siteLinenumberMap.get(selectedSiteId);
            Integer count = 0;
            String portTypeVal ;
            String accessSpeedSelectedSite = null;
            String portSpeedSelectedSite = null;
            set<Id> selectedLineItemIds = new set<Id>();
            eligiblesiteIds = new set<Id>();
            boolean checkEligibilityNoJSON = false;
            boolean inRegioncheckNoJSON = false;
            boolean inRegionSiteAddressNoJSON = false;
            boolean speedNotAvailableForSite = false;   
            configureSitesFlag = true;
            selectAllCheckBox = true;
            
            if(ListCustomerSite.size() == 1){
                configureSitesFlag = false;
                isContinueEnabled = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There are no other sites in your quote.');
                ApexPages.addMessage(myMsg);
                return;
            }
            if(ListCustomerSite.size()>= indx){  
                List<Apttus_Config2__LineItem__c> lineItemInCart2=[SELECT Id,Apttus_Config2__ConfigurationId__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartId ];
                selctedsiteAVRecords = [select Id,CoS__c,Hi_Cap_Flex__c,UBB_Speed_MIS__c,UBB_Speed_AVPN__c,VLANs_Logical_Channels__c, Access_Speed_AVPN__c,Access_Speed_MIS__c,Apttus_Config2__Vendor__c, VASA_Region__c, Port_Speed_AVPN__c, Port_Speed_MIS__c, Port_Type_AVPN__c, Port_Type_MIS__c, Interface_Type__c, Interface_Type_AVPN__c, Access_Type__c, Access_Type_AVPN__c, Additional_DNS__c, Install_Option_MIS__c, Install_Option_AVPN__c from Apttus_Config2__ProductAttributeValue__c where AT_T_Customer_Site__c =: selectedSiteId and Apttus_Config2__LineItemId__c IN: lineItemInCart2 limit 1];
                system.debug('@@kar::selctedsiteAVRecords::'+selctedsiteAVRecords);
                Apttus_Config2__LineItem__c selectedlineItems = [SELECT Id, isPricingApplied__c, Apttus_Config2__PricingStatus__c, Apttus_Config2__LineNumber__c, Apttus_Config2__BasePrice__c,Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__r.Port_Type_AVPN__c,Apttus_Config2__AttributeValueId__r.Port_Type_MIS__c,Apttus_Config2__AttributeValueId__r.Access_Speed_MIS__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c, Apttus_Config2__AttributeValueId__r.Access_Speed_AVPN__c, Apttus_Config2__AttributeValueId__r.Port_Speed_MIS__c,Apttus_Config2__AttributeValueId__r.Port_Speed_AVPN__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=:cartId AND AT_T_Customer_Site__c =: selectedSiteId limit 1 ];

                if( selectedlineItems.Apttus_Config2__AttributeValueId__r.Port_Type_MIS__c != null ) {
                    portTypeVal = selectedlineItems.Apttus_Config2__AttributeValueId__r.Port_Type_MIS__c;
                    portSpeedSelectedSite = selectedlineItems.Apttus_Config2__AttributeValueId__r.Port_Speed_MIS__c;
                    accessSpeedSelectedSite = selectedlineItems.Apttus_Config2__AttributeValueId__r.Access_Speed_MIS__c;
                }
                else{
                    portTypeVal = selectedlineItems.Apttus_Config2__AttributeValueId__r.Port_Type_AVPN__c;
                    portSpeedSelectedSite = selectedlineItems.Apttus_Config2__AttributeValueId__r.Port_Speed_AVPN__c;
                    accessSpeedSelectedSite = selectedlineItems.Apttus_Config2__AttributeValueId__r.Access_Speed_AVPN__c;
                }
                cs = ListCustomerSite[indx-1];
                system.debug('@@kar::cs'+cs);
                if(!selectedlineItems.isPricingApplied__c && !test.isrunningtest()){
                    configureSitesFlag = false;
                    isContinueEnabled = false;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Click Apply and Get Price to selected site before applying the same configuration to other sites.');
                    checkForEligibleSitesCount();
                    ApexPages.addMessage(myMsg);
                    return;
                }
                if(isASE == true){     
                    eligibleSiteASE();          
                }else{
                    for(QuoteProducts.cCustomerSite csAll : ListCustomerSite){                          
                        if(portTypeVal != null && portTypeVal.contains('Switched Ethernet') && cs.custSiteIns.Id != csAll.custSiteIns.Id){
                            checkEligibilityNoJSON = siteVasaResValidatorIns.siteSAResponseNoJSON(csAll.custSiteIns,portSpeedSelectedSite,accessSpeedSelectedSite);
                            inRegionSiteAddressNoJSON = siteVasaResValidatorIns.checkSiteInRegionNoJSON(csAll.custSiteIns);
                            if(inRegionSiteAddressNoJSON == true){
                                speedNotAvailableForSite = siteVasaResValidatorIns.checkSpeedAvailability(portSpeedSelectedSite, csAll.speedsNotAvailableITPA);
                            }                            
                            if(checkEligibilityNoJSON){
                                checkEligibilityNoJSON = false;
                                continue;
                            }
                        }
                        
                        if(selctedsiteAVRecords.Hi_Cap_Flex__c == false){
                            if((cs.vasaResStr == csAll.vasaResStr || csAll.vasaResStr == 'B') && cs.custSiteIns.Id != csAll.custSiteIns.Id && speedNotAvailableForSite == false){
                                csn = new  QuoteProducts.cCustomerSite(csAll); 
                                csn.linecount = count;
                                csn.eligibleSelected = false;
                                count++;
                                eligibleSitesLst.add(csn);
                                eligiblesiteIds.add(csAll.custSiteIns.Id);
                            }
                            if(portTypeVal != null && portTypeVal.contains('Switched Ethernet') && cs.vasaResStr == 'B' && cs.custSiteIns.Id != csAll.custSiteIns.Id && csAll.vasaResStr == 'E' && speedNotAvailableForSite == false){
                                csn = new  QuoteProducts.cCustomerSite(csAll); 
                                csn.linecount = count; 
                                csn.eligibleSelected = false; 
                                count++; 
                                eligibleSitesLst.add(csn); 
                                eligiblesiteIds.add(csAll.custSiteIns.Id);
                            }
                            if(portTypeVal != null && portTypeVal.contains('Private Line') && cs.vasaResStr == 'B' && cs.custSiteIns.Id != csAll.custSiteIns.Id && csAll.vasaResStr == 'P' && speedNotAvailableForSite == false){
                                csn = new  QuoteProducts.cCustomerSite(csAll); 
                                csn.linecount = count; 
                                csn.eligibleSelected = false; 
                                count++; 
                                eligibleSitesLst.add(csn); 
                                eligiblesiteIds.add(csAll.custSiteIns.Id);
                            }
                       }
                       else{
                            inRegioncheckNoJSON = siteVasaResValidatorIns.siteSAResponseHiCapFlexNoJSON(csAll.custSiteIns,accessSpeedSelectedSite);
                            System.debug('inside else of hicapflex');
                            csn = new  QuoteProducts.cCustomerSite(csAll);
                            if(inRegioncheckNoJSON == true && cs.custSiteIns.Id != csAll.custSiteIns.Id && speedNotAvailableForSite == false){
                                System.debug('inside if inRegion');
                                csn.linecount = count;
                                csn.eligibleSelected = false;
                                csn.eligibleSFlag = false;
                                csn.siteEnabled = false;
                                count++;
                                eligibleSitesLst.add(csn);
                                eligiblesiteIds.add(csAll.custSiteIns.Id);
                            }
                            else{                           
                                csn.eligibleSelected = true;
                                csn.eligibleSFlag = true;
                                csn.siteEnabled =true;
                            }                       
                        } 
                    }
                }
                
                system.debug('@@PS eligibleSitesLst  '+eligibleSitesLst.size()+eligibleSitesLst );
                if(eligibleSitesLst == null || eligibleSitesLst.size() == 0 ) {
                    configureSitesFlag = false;
                    checkForEligibleSitesCount();
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There are no other eligible sites in your quote.');
                    ApexPages.addMessage(myMsg);
                    return;
                }
                system.debug('@@kar::selectedlineItems.Id::'+selectedlineItems.Id);
                system.debug('@@kar::selectedSiteId::'+selectedSiteId );
                
                list<Apttus_Config2__LineItem__c> selectedlineItemList = [SELECT Id, isPricingApplied__c, Apttus_Config2__PricingStatus__c, Apttus_Config2__LineNumber__c, Apttus_Config2__BasePrice__c,Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__r.Port_Type_AVPN__c,Apttus_Config2__AttributeValueId__r.Port_Type_MIS__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=:cartId AND AT_T_Customer_Site__c =: eligiblesiteIds  ];
                for( Apttus_Config2__LineItem__c lineItem : selectedlineItemList   ) {
                    lineNumbersNeedsToBeDeleted.put(lineItem.AT_T_Customer_Site__c,(Integer)lineItem.Apttus_Config2__LineNumber__c);
                }
            }
            if(isASE == false){
                filterIPFLEXSites(listCustomerSiteMaster,eligiblesiteIds,updateAVValuesIpflex);
            }
        }catch(Exception e){
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in QuoteInfoController.eligibleSitesPop', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        system.debug('--------eligibleSitesLst length --> '+eligibleSitesLst.size());
        system.debug('@@kar::eligibleSitesLst'+eligibleSitesLst);
    }
    
    public void filterIPFLEXSites(List<QuoteProducts.cCustomerSite> listCustomerSiteMaster,set<Id> eligiblesiteIds,List<Apttus_Config2__ProductAttributeValue__c> UpdateIpflexlist){
        try{
            Map<id,boolean> ipflexMap = new Map<id,boolean> ();
            List<Apttus_Config2__LineItem__c> AVRecs = [select id, Apttus_Config2__ConfigurationId__r.id, Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c,AT_T_Customer_Site__r.id from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__r.id=: cartId and Apttus_Config2__ChargeType__c = 'Port Speed Fee' and AT_T_Customer_Site__r.id IN : eligiblesiteIds];
            for(Apttus_Config2__LineItem__c Ipflag : AVRecs){
                ipflexMap.put(Ipflag.AT_T_Customer_Site__r.id,Ipflag.Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c);
            }
            
            Integer counteligible =0;
            Integer countIpflex =0;
            Integer i =0;
            for(QuoteProducts.cCustomerSite IpflexSite : listCustomerSiteMaster){
                IpflexSite.selected=false;
                i++;         
                if(eligiblesiteIds.contains(IpflexSite.custSiteIns.id)){
                    IpflexSite.eligibleSFlag = false;
                    IpflexSite.siteEnabled= false;
                    counteligible ++;
                    if(ipflexMap.get(IpflexSite.custSiteIns.id) != null){
                        if(ipflexMap.get(IpflexSite.custSiteIns.id) == true){
                            IpflexSite.eligibleSFlag = true;
                            IpflexSite.siteEnabled= true;
                        }
                        else{
                            countIpflex ++;
                            IpflexSite.eligibleSFlag = false;
                            IpflexSite.siteEnabled= false;
                        }
                    } 
                }
                else{
                    IpflexSite.eligibleSFlag = true;
                    IpflexSite.siteEnabled= true;
                }  
            }
            if(countIpflex== 0 && AVRecs.size() == eligiblesiteIds.size() ) {
                configureSitesFlag = false;
                checkForEligibleSitesCount();
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There are no other eligible sites in your quote.');
                ApexPages.addMessage(myMsg);
                return;
            }
        }
        catch(Exception e){
            System.debug('*******exception in getCustomerSiteLst*****' + e.getLineNumber()+''+e+'trace is :'+e.getStackTraceString());
        }
    }
    
    
    public void handleApplyEligibleConfigUI(){
        system.debug('-------handleApplyEligibleConfigUI----------->');
        Apttus_Config2__ProductConfiguration__c prodConfig = quotehelper.retrieveExistingProductConfigusingCartId(cartId);
        readPricingStatusForAllLineItem(prodConfig);
    }
        
    public Pagereference siteTraverseMethodNext(){
        Pagereference pg = page.PortalDesign_Buyflow;
        try{
            Integer siteLineNum;
            if(siteLinenumberMap != null && siteLinenumberMap.containsKey(selectedSiteId)){
                siteLineNum = siteLinenumberMap.get(selectedSiteId);
            }
            system.debug('siteLineNum --------> '+siteLineNum);
            
            for(String strSiteId : siteLinenumberMap.keyset()){
                if(siteLineNum != null && siteLinenumberMap.get(strSiteId) == siteLineNum + 1 && disableNext == false){
                    siteid = strSiteId;
                    disablePrevious = false;
                }
            }
            if(ListCustomerSite != null && siteLineNum != null && siteLineNum == ListCustomerSite.size()){ //need to fix
                disableNext = true;
                disablePrevious = false;
            }   
            resetUBB(); 
            resetIpflex();   
            pg.getparameters().put('mode','confsites');
            pg.getparameters().put('quoteid',quoteId);
            pg.getparameters().put('siteid',siteid);
            pg.setredirect(true) ;   
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.siteTraverseMethodNext', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return pg;
    }
    
    public Pagereference siteTraverseMethodPrevious(){
        Pagereference pg = page.PortalDesign_Buyflow;
        try{
            Integer siteLineNum;
            disablePrevious =false;
            if(siteLinenumberMap != null && siteLinenumberMap.containsKey(selectedSiteID)){
                siteLineNum = siteLinenumberMap.get(SelectedsiteId);
            }
            system.debug('siteLineNum --------> '+siteLineNum);
            for(String strSiteId : siteLinenumberMap.keyset()){
                if(siteLineNum != null && siteLinenumberMap.get(strSiteId) == siteLineNum - 1 && disablePrevious == false){
                    siteid = strSiteId;
                    disableNext = false;
                }
            }
            
            if(ListCustomerSite != null && siteLineNum != null && siteLineNum == ListCustomerSite.size()){
                disablePrevious = true;
                disableNext = false;
            }
            resetUBB();
            resetIpflex();
            pg.getparameters().put('mode','confsites');
            pg.getparameters().put('quoteid',quoteId);
            pg.getparameters().put('siteid',siteid);
            pg.setredirect(true);   
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.siteTraverseMethodPrevious', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return pg;
    }
    
    public PageReference finalizeCart(){
        try{
            Quotehelper.saveProductConfiguration(cartId);
            quotehelper.updateByflowStep(quoteId);
            Set<id> AttCustid=new Set<id>();                
            List<AT_T_Customer_Site_Quote__c> junctionDeleteList = [SELECT Id,Is_Soft_Deleted__c,AT_T_Customer_Site__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c  =: quoteId and Is_Soft_Deleted__c=true];
            if(junctionDeleteList.size() > 0)  {
                
                 /*****Untagging End Customer for IPQ Site*****/ 
                List<CustomerSite__c> custObj = new List<CustomerSite__c>();
                List<id> custIdList = new List<Id>();
                Map<id,Integer> siteMap = new Map<id,Integer>();
                List<Id> untagSIteIdList = new List<Id>();
                List<End_Customer__c> endObj = new List<End_Customer__c>();
                endObj = [Select id from End_Customer__c where Name = 'Rest_End_Customer'];
                custObj=[select id,End_Customer__c,Site_Name__c,API_IPQ_Site__c from CustomerSite__c where API_IPQ_Site__c = true AND id in (select AT_T_Customer_Site__c from AT_T_Customer_Site_Quote__c where Id =: junctionDeleteList)];
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
                delete junctionDeleteList;
            }

            for(AT_T_Customer_Site_Quote__c  deljobj :junctionDeleteList) {
                AttCustid.add(deljobj.AT_T_Customer_Site__c);
            }
            if(AttCustid.size() > 0) {
                List<Apttus_Config2__LineItem__c> configlineItemDelete =[SELECT Id, AT_T_Customer_Site__c FROM Apttus_Config2__LineItem__c WHERE AT_T_Customer_Site__c in: AttCustid AND Quote_Id__c =: String.valueOf(quoteId).subString(0,15)];
                if(configlineItemDelete.size() > 0) {
                    delete configlineItemDelete;
                }   
            }            
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.finalizeCart', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        PageReference reviewAddressPage = system.page.PortalDesign_Buyflow;
        reviewAddressPage.getParameters().put('mode', 'reviewquote');
        reviewAddressPage.getParameters().put('quoteid', quoteId); 
        reviewAddressPage.setRedirect(true);
        return reviewAddressPage;
    } 
    
    public void handleClearUI(){
        try{            
            if(sitePricingMap.get(siteid)!=null){
                sPricingWrap = sitePricingMap.get(siteid); 
                for(QuoteProducts.ProductOption tempVal: sPricingWrap.optionsList){ 
                    tempVal.selectedProduct = null;
                    tempVal.price = null;
                    tempVal.isSelected = false;
                }               
            }
            for(QuoteProducts.cCustomerSite cs : ListCustomerSite){
                if(cs.custSiteIns.Id == siteid){
                    cs.isProcessed = false;
                    cs.spanClass = 'display:none; color:green;';                    
                    cs.eligibleSelected = false;
                    helper.cleanLineItemListOnPortSelect(cs.linenumber.intValue(), cartId);
                    sitePricingMap.put(cs.custSiteIns.Id,null);
                    Quotehelper.cleanUIOnOptionChange(sPricingWrap);
                }
            }        
            calcSiteTotal();
            grandTotalPopulate();
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.handleClearUI', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    public void handlefilterSites(){
        if(proposalData != null && selectedFilter != null){   
            proposalData.Site_Status__c = selectedFilter;
            update proposalData;
            list<AT_T_Customer_Site_Quote__c> multipleJunctionList = new list<AT_T_Customer_Site_Quote__c>();
            if(proposalData.Id != null){
                multipleJunctionList = [SELECT Id,Igloo_Review_Required__c,Is_Soft_Deleted__c, AT_T_Customer_Site__c, AT_T_Quote__c, Wireline_Promotion_Applied__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c  =: proposalData.Id];
            }
            
            listCustomerSiteMaster = new List<QuoteProducts.cCustomerSite>();
            listCustomerSiteMaster.clear();
            Boolean isFiltered = false;
            for(QuoteProducts.cCustomerSite csAll : ListCustomerSite){
                if(csAll.isProcessed && selectedFilter.equalsIgnoreCase('Configured') && !csAll.isIglooReviewReq && !csAll.OORSEExpired){
                    csAll.showSites = true;
                    csAll.spanClass = 'display:inline-block; color:green;';
                    if( csAll.custSiteIns.Id == selectedSiteId ){                
                        csAll.cellFilterSitesClass = 'selectedSiteHighlighted';
                    }else{
                        csAll.cellFilterSitesClass = '';
                    }  
                    listCustomerSiteMaster.add(csAll);
                    isFiltered = true;
                }else if((!csAll.isProcessed || csAll.isIglooReviewReq || csAll.OORSEExpired) && selectedFilter.equalsIgnoreCase('NotConfigured')){
                    csAll.showSites = true;
                    csAll.spanClass = 'display:inline-block; color:green;';
                    if( csAll.custSiteIns.Id == selectedSiteId ){
                        csAll.cellFilterSitesClass = 'selectedSiteHighlighted';
                    }else{
                        csAll.cellFilterSitesClass = '';
                    }  
                    listCustomerSiteMaster.add(csAll);
                    isFiltered = true;
                }
                else if(selectedFilter.equalsIgnoreCase('Removed') && !csAll.OORSEExpired){
                    set<id> fetchSoftDeletedCustSet = new set<id>();
                    if(!multipleJunctionList.isEmpty()){
                        for(AT_T_Customer_Site_Quote__c junctionObj: multipleJunctionList){
                            if(junctionObj.Is_Soft_Deleted__c == true || csAll.OORSEExpired){
                                fetchSoftDeletedCustSet.add(junctionObj.AT_T_Customer_Site__c);
                            }
                        }
                    }
                    if(fetchSoftDeletedCustSet.size() > 0) {
                        csAll.showSites = true;
                        isFiltered = true;
                        for(Id custId: fetchSoftDeletedCustSet){
                            if(csAll.custSiteIns.Id == custId){
                                listCustomerSiteMaster.add(csAll);
                            }
                        }
                    } else {
                        csAll.showSites = true;
                        isFiltered = true;
                    }
                }
                else if(selectedFilter.equalsIgnoreCase(ATTConstants.SITE_REVIEWREQUIREDVAL)){
                    set<id> fetchReviewRequiredCustSet = new set<id>();
                    if(!multipleJunctionList.isEmpty()){
                        for(AT_T_Customer_Site_Quote__c junctionObj: multipleJunctionList){
                            if((junctionObj.Igloo_Review_Required__c == true && junctionObj.Is_Soft_Deleted__c == false) || csAll.OORSEExpired){
                                fetchReviewRequiredCustSet.add(junctionObj.AT_T_Customer_Site__c);
                            }
                        }
                    }
                    if(fetchReviewRequiredCustSet.size() > 0) {
                        csAll.showSites = true;
                        isFiltered = true;
                        for(Id custId: fetchReviewRequiredCustSet){
                            if(csAll.custSiteIns.Id == custId) {
                                listCustomerSiteMaster.add(csAll);
                            }
                        }
                    }else{
                        csAll.showSites = true;
                        isFiltered = true;
                    }
                }else if(selectedFilter.equalsIgnoreCase('PromotionsApplied')){
                    set<id> fetchWirelinePromotionCustSet = new set<id>();
                    if(!multipleJunctionList.isEmpty()){
                        for(AT_T_Customer_Site_Quote__c junctionObj: multipleJunctionList){
                            if(junctionObj.Wireline_Promotion_Applied__c == true){
                                fetchWirelinePromotionCustSet.add(junctionObj.AT_T_Customer_Site__c);
                            }
                        }
                    }
                    if(fetchWirelinePromotionCustSet.size() > 0) {
                        csAll.showSites = true;
                        isFiltered = true;
                        for(Id custId: fetchWirelinePromotionCustSet){
                            if(csAll.custSiteIns.Id == custId) {
                                listCustomerSiteMaster.add(csAll);
                            }
                        }
                    }else{
                        csAll.showSites = true;
                        isFiltered = true;
                    }
                }else if(selectedFilter.equalsIgnoreCase('All')){
                    csAll.showSites = true;
                    csAll.spanClass = 'display:inline-block; color:green;';                 
                    isFiltered = false;
                }else{
                    csAll.showSites = false;
                    csAll.spanClass = 'display:none; color:green;';
                    csAll.cellFilterSitesClass = '';                
                }
            }        
            if( isFiltered == false ){
              /*Fix for removing additional empty boxes in list panel, TDP214888*/
                List<QuoteProducts.cCustomerSite> tempList = new List<QuoteProducts.cCustomerSite>();  
                for(QuoteProducts.cCustomerSite csAll : ListCustomerSite){
                    System.debug('csAll.showSites'+csAll.showSites);
                    if(csAll.showSites == true){
                        tempList.add(csAll);
                    }
                }
                listCustomerSiteMaster = tempList; 
            }                        
        }
    }
    
    public List<SelectOption> getFilterOptions(){
        List<SelectOption> filterOption = new List<SelectOption>();
        filterOption.add(new selectoption('All', 'Filter Sites'));
        filterOption.add(new selectoption('Configured', 'Configured'));
        filterOption.add(new selectoption('NotConfigured', 'Not Configured'));
        filterOption.add(new selectoption('Removed', 'Removed'));
        filterOption.add(new selectoption(ATTConstants.SITE_REVIEWREQUIREDVAL, ATTConstants.SITE_REVIEWREQUIREDLABEL));
        filterOption.add(new selectoption('PromotionsApplied', 'Promotions Applied'));
        return filterOption;
    }
    
    public PageReference GotoAddAddressPage(){
        PageReference pgRef = SaveandExit();
        Apttus_Proposal__Proposal__c quote = new Apttus_Proposal__Proposal__c();
        if (quoteId!=NULL){
            quote.Id = quoteId;
            quote.Buyflow_Step__c = 'Add Sites';
            update quote;
        }    
        PageReference AddaddressPage = system.page.buyflow;
        AddaddressPage.getParameters().put('mode', 'siteinfo');
        AddaddressPage.getParameters().put('quoteid', quoteId ); 
        AddaddressPage.getParameters().put('buyflow', 'false');
        return AddaddressPage;
    }
    
    //This method uses a simple SOQL query to return a List of Contacts
    public List<CustomerSite__c> getCustomerSiteLst() {
        List<CustomerSite__c> customerSiteList = new List<CustomerSite__c>();
        try{        
            Set<String> customerSiteIdSet = new Set<String>();          
            if(ListCustomerSite == null) {
                List<AT_T_Customer_Site_Quote__c> custSiteQuoteLst = [Select Id,Iglow_Response_Received_Date__c, Name,AT_T_Customer_Site__c,AT_T_Quote__c,AT_T_Quote__r.Product__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,AT_T_Quote__r.Name,AT_T_Quote__r.Apttus_Proposal__Payment_Term__c,AT_T_Quote__r.Apttus_QPConfig__PriceListId__c,AT_T_Quote__r.Product__r.Name, AT_T_Customer_Site__r.Id, AT_T_Customer_Site__r.Name, AT_T_Customer_Site__r.Site_Name__c, AT_T_Customer_Site__r.City__c, AT_T_Customer_Site__r.Service_Availability_Response__c, AT_T_Customer_Site__r.State__c, AT_T_Customer_Site__r.Address_Line__c ,AT_T_Customer_Site__r.Tier__c ,AT_T_Customer_Site__r.Building_Cili__c,AT_T_Customer_Site__r.Code_EMUX_Fiber__c,AT_T_Customer_Site__r.LATA_Number__c,Igloo_Review_Required__c,Wireline_Promotion_Applied__c,Is_Soft_Deleted__c,AT_T_Customer_Site__r.Speeds_Not_Available_ITPA__c,AT_T_Customer_Site__r.Ethernet_Other_Speeds__c,AT_T_Customer_Site__r.Ethernet_Max_Available_Speed__c,AT_T_Customer_Site__r.IsEtherNetAvaiable__c,AT_T_Customer_Site__r.Region__c from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=:quoteId];
                initializeCustomerSiteLst(custSiteQuoteLst);
            }
            if(ListCustomerSite!=null){
                for(QuoteProducts.cCustomerSite csAll : ListCustomerSite){
                    customerSiteList.add(csAll.custSiteIns);
                }
            }
            if(customerSiteList!=null){
                for(CustomerSite__c csIdL : customerSiteList){
                    customerSiteIdSet.add(csIdL.Id);
                }
            }
            updateAVValuesIpflex=new List<Apttus_Config2__ProductAttributeValue__c>();
            listCustomerSiteMaster = ListCustomerSite;
        }
        catch(Exception e){
            System.debug('*******exception in getCustomerSiteLst*****' + e.getLineNumber()+''+e+'trace is :'+e.getStackTraceString());
        }
        return customerSiteList;
    }    
    
    public void initializeCustomerSiteLst(List<AT_T_Customer_Site_Quote__c> custSiteQuoteLst){
        Integer count = 1;
        CustomerSite__c c;
        Set<Id> custSiteIdTemp = new Set<Id>();
        system.debug('custSiteQuoteLst >>>>'+custSiteQuoteLst);
        for(AT_T_Customer_Site_Quote__c custSiteQuoteLstTemp : custSiteQuoteLst){
            custSiteIdTemp.add(custSiteQuoteLstTemp.AT_T_Customer_Site__c);
        }
        List<CustomerSite__c> lstCustSite = new List<CustomerSite__c>();
        lstCustSite = [Select Id , Name,Service_Availability_Response__c from CustomerSite__c where Id IN: custSiteIdTemp];
        if(lstCustSite != null && lstCustSite.size() >0){
            try{
                siteVasaResValidatorIns = new SiteVasaResValidator();
                siteIdEthernetAvailMap = siteVasaResValidatorIns.custSiteEligible(lstCustSite);
                system.debug('siteIdEthernetAvailMap first>>>>>>>>>>'+siteIdEthernetAvailMap);            
            }catch(Exception e){
                system.debug('Method getOptionGroupsForPriceListProduct Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
                ATTException.createException('error in map siteIdEthernetAvailMap', e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
        system.debug('siteIdEthernetAvailMap >>>>>>>>>>'+siteIdEthernetAvailMap);
      
        showOORSEExpired=false;
        if(ListCustomerSite == null && !isReviewMode && !isSitereview) {
            ListCustomerSite = new List<QuoteProducts.cCustomerSite>();
            system.debug('customerSiteList.size()----------------->'+custSiteQuoteLst.size());
            Set<String> OORSESites=new Set<String>();
            OORSESites=IglooExpirationCheck(custSiteQuoteLst,false);
            for(AT_T_Customer_Site_Quote__c custSiteQuoteIns : custSiteQuoteLst){               
                // As each contact is processed we create a new cContact object and add it to the ListCustomerSite
                c = new CustomerSite__c();
                c.Id = custSiteQuoteIns.AT_T_Customer_Site__r.Id;
                c.Site_Name__c = custSiteQuoteIns.AT_T_Customer_Site__r.Site_Name__c;
                c.City__c = custSiteQuoteIns.AT_T_Customer_Site__r.City__c;
                c.Address_Line__c = custSiteQuoteIns.AT_T_Customer_Site__r.Address_Line__c;
                c.State__c = custSiteQuoteIns.AT_T_Customer_Site__r.State__c;
                c.Ethernet_Other_Speeds__c = custSiteQuoteIns.AT_T_Customer_Site__r.Ethernet_Other_Speeds__c ;
                c.Ethernet_Max_Available_Speed__c = custSiteQuoteIns.AT_T_Customer_Site__r.Ethernet_Max_Available_Speed__c ;
                c.IsEtherNetAvaiable__c = custSiteQuoteIns.AT_T_Customer_Site__r.IsEtherNetAvaiable__c ;
                c.Region__c =custSiteQuoteIns.AT_T_Customer_Site__r.Region__c;            
                c.Tier__c = custSiteQuoteIns.AT_T_Customer_Site__r.Tier__c;
                c.Building_Cili__c = custSiteQuoteIns.AT_T_Customer_Site__r.Building_Cili__c;
                c.Code_EMUX_Fiber__c = custSiteQuoteIns.AT_T_Customer_Site__r.Code_EMUX_Fiber__c;
                c.LATA_Number__c =  custSiteQuoteIns.AT_T_Customer_Site__r.LATA_Number__c; 
                
                system.debug('###########'+c);
                QuoteProducts.cCustomerSite ccs = new QuoteProducts.cCustomerSite(c);
                system.debug('########'+ccs);
                ccs.linecount = count;
                ccs.showSites = true; 
                ccs.isIglooReviewReq = custSiteQuoteIns.Igloo_Review_Required__c;
                ccs.speedsNotAvailableITPA = custSiteQuoteIns.AT_T_Customer_Site__r.Speeds_Not_Available_ITPA__c;
                ccs.wirelinePromoApplied = custSiteQuoteIns.Wireline_Promotion_Applied__c;
 
                if(OORSESites!=null && OORSESites.size()>0 && OORSESites.contains(custSiteQuoteIns.id)){
                    ccs.OORSEExpired=true;showOORSEExpired=true;
                    ccs.isOORSESite=false;
                }
                if (oorSEConfiguredSite!=null && oorSEConfiguredSite.size()>0 && oorSEConfiguredSite.contains(custSiteQuoteIns.id)){
                    ccs.isOORSESite=true;
                }else{
                    ccs.isOORSESite=false;
                }
                
                if(!String.isBlank(selectedSiteID) && selectedSiteID.equalsIgnoreCase(custSiteQuoteIns.AT_T_Customer_Site__c)){
                    IglooReviewRequired = custSiteQuoteIns.Igloo_Review_Required__c;
                }
                ccs.isSoftDel = custSiteQuoteIns.Is_Soft_Deleted__c;
                if(quoteobj.Ethernet_Configuration__c == 'Ethernet Virtual Private Line (Hub-and-Spoke)'){
                    typeConnection = true;
                    ccs.SiteConnectionType = 'Spoke';
                }
                else{
                    TypeConnection = false;
                    ccs.SiteConnectionType = 'P2P';
                }
                if(siteIdEthernetAvailMap != null && siteIdEthernetAvailMap.containsKey(String.valueOf(c.Id)) && siteIdEthernetAvailMap.get(String.valueOf(c.Id)) == false){
                    ccs.vasaResStr = 'P';
                }else if(siteIdEthernetAvailMap != null && siteIdEthernetAvailMap.containsKey(String.valueOf(c.Id)) && siteIdEthernetAvailMap.get(String.valueOf(c.Id)) == true){
                    ccs.vasaResStr = 'E';
                }else if(siteIdEthernetAvailMap != null && siteIdEthernetAvailMap.containsKey(String.valueOf(c.Id)) && siteIdEthernetAvailMap.get(String.valueOf(c.Id)) == null){
                    ccs.vasaResStr = 'B';
                }else{
                    ccs.vasaResStr = 'B'; 
                }
                ListCustomerSite.add(ccs);
                listCustomerSiteMaster = ListCustomerSite;
                siteLinenumberMap.put(c.Id, count);
                count++;
            }
        }
        if(ListCustomerSite!=null){
            TotalSitesCount = ListCustomerSite.size();
        }
    }
    
    public void filterConnectionSpeed(QuoteProducts.SelectPricingWrap sPricingWrapTemp){
        Integer index=-1;
        Integer broadbandIndex = -1;
        siteVasaResValidatorIns = new SiteVasaResValidator();
        for(QuoteProducts.ProductOption tempProdOpt : sPricingWrapTemp.optionsList){             
            if(tempProdOpt.name.equalsIgnoreCase(ATTConstants.CON_SPEED) && tempProdOpt.showListOption == true){
               tempProdOpt.prodOptnsLst = siteVasaResValidatorIns.brassResValidator(siteid,tempProdOpt.prodOptnsLst);
            }
        }
        for (QuoteProducts.Productoption optgrp: sPricingWrapTemp.optionsList){
            if (optgrp.name.equals(ATTConstants.CON_SPEED)){                        
                for (SelectOption item : optgrp.prodOptnsLst){ 
                    index++;       
                    if(item.getLabel() == '768K (Broadband)'){
                        broadbandIndex = index;
                        if (temp==NULL || temp.size()==0){
                           temp.add(item);
                        }
                    }                              
                }
                if (broadbandIndex >-1 && selectOptGrp == 'Static'){
                    optgrp.prodOptnsLst.remove(broadbandIndex);
                }else if (broadbandIndex == -1 && selectOptGrp == 'Dynamic'){
                    if (temp!=NULL && temp.size()>0){
                        optgrp.prodOptnsLst.add(1,temp[0]);
                    }
                }
            }
        }
    }
   
    @RemoteAction
    public static String checkLiemsPriceStatus( String cartId) {
        String resultVal = null;
        if(cartId!=null) {
            List<Apttus_Config2__LineItem__c> lineItemList=[Select Id,IsBatchUpdate__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartId and IsBatchUpdate__c = true];
            if(lineItemList.size()>0){
                resultVal = 'Completed';
                for( Apttus_Config2__LineItem__c lineItemsRevert : lineItemList ){
                    lineItemsRevert.IsBatchUpdate__c = false;
                }
                update lineItemList;
            }
            else{
                resultVal = 'Inprogress';
            }
        }
        return resultVal;
    }
    
    public boolean iSHiCapInCart(){
        boolean tempBool = false;
        List<Apttus_Config2__LineItem__c> lineItemInCart=[SELECT Id,Apttus_Config2__ConfigurationId__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartId ];
        list<Apttus_Config2__ProductAttributeValue__c> avRecordsInCart = [select id, Hi_Cap_Flex__c from Apttus_Config2__ProductAttributeValue__c where Apttus_Config2__LineItemId__c IN: lineItemInCart];
        for(Apttus_Config2__ProductAttributeValue__c avRec : avRecordsInCart){
        if(avRec.Hi_Cap_Flex__c){
            tempBool = true;
            break;
            }
        }
        return tempBool;
    }
    
    public boolean isIPFlexInCart(){
        boolean tempBool = false;
        List<Apttus_Config2__LineItem__c> lineItemInCart=[SELECT Id,Apttus_Config2__ConfigurationId__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartId ];
        list<Apttus_Config2__ProductAttributeValue__c> avRecordsInCart = [select id, AT_T_IP_Flexible_Reach__c from Apttus_Config2__ProductAttributeValue__c where Apttus_Config2__LineItemId__c IN: lineItemInCart];
        for(Apttus_Config2__ProductAttributeValue__c avRec : avRecordsInCart){
            if(avRec.AT_T_IP_Flexible_Reach__c){
                tempBool = true;
                break;
            }
        }
        return tempBool;
    }
   
    public void handleHiCapCheckUncheck(){
        List<Apttus_Config2__LineItem__c> lineItemPriceClear = new List<Apttus_Config2__LineItem__c>();
        Decimal tempNetprice = 0.00000;
        if(listAttrVal != null && listAttrVal.Hi_Cap_Flex__c == false ){
            listAttrVal.Hi_Cap_Flex__c = false;
            listAttrVal.UBB_Speed_MIS__c = null;
            listAttrVal.UBB_Speed_AVPN__c = null;
            update listAttrVal; 
            isHiCapFlex=false;           
        }
        else if(listAttrVal != null && listAttrVal.Hi_Cap_Flex__c == true){
            update listAttrVal;
            isHiCapFlex=true;
        }
        System.debug('#####listAttrVal='+listAttrVal);
        isPricingDataAvailable = false;       
        if(lineItems != null && lineItems.size()>0){
            system.debug('lineitemIshere--'+lineItems); 
            for(Apttus_Config2__LineItem__c lineItemClear : lineItems){
                if(lineItemClear.Apttus_Config2__NetPrice__c != null){
                    lineItemClear.Apttus_Config2__NetPrice__c = tempNetprice; 
                    lineItemClear.Net_Price_with_Deal_Reg_Discounts__c = lineItemClear.Net_Price_with_SP_Order_Discounts__c = lineItemClear.Original_Hidden_Price__c = lineItemClear.Original_Net_Price__c = null;
                    lineItemClear.isPricingApplied__c = false;
                }
                lineItemPriceClear.add(lineItemClear);    
            }      
            if(lineItemPriceClear != null && lineItemPriceClear.size()>0){   
                update lineItemPriceClear;  
                totalPerSite =0.0;
            }
        }
        for(QuoteProducts.cCustomerSite cs : ListCustomerSite){
            if( cs.custSiteIns.Id == selectedSiteId ){
                cs.attCustomerSiteTotal = 0.0;
                cs.attCustomerSiteOneTime = 0.0;
            }
        }
    }
    
    public void handleIPFlexAvailability(){
        currentSiteData =[SELECT Id,IPFLEX_Availability_Flag__c From CustomerSite__c where id =: selectedSiteId LIMIT 1];
        if(currentSiteData != null && currentSiteData.size() > 0 ){
            if(currentSiteData[0].IPFLEX_Availability_Flag__c == 'true'){
                if(listAttrVal != null && isAVPN){
                    listAttrVal.AT_T_IP_Flexible_Reach__c = true;
                    listAttrVal.CoS__c = true;              
                }
                else{
                    listAttrVal.AT_T_IP_Flexible_Reach__c = true;
                    listAttrVal.CoS__c = true;
                    listAttrVal.Managed_Router__c = true;
                }
                update listAttrVal; 
                isIPFlex = true; 
            }else{
                listAttrVal.AT_T_IP_Flexible_Reach__c = false;
                listAttrVal.CoS__c = false;
                listAttrVal.Managed_Router__c = false;
                listAttrVal.New_Virtual_Phone_Numbers__c=0;
                listAttrVal.New_Local_Phone_Numbers__c=0;
                listAttrVal.Ported_Phone_Numbers__c=0;
                listAttrVal.IP_Flexible_Reach_Plan__c=null;
                listAttrVal.Concurrent_Calls__c=0;
                listAttrVal.Enhanced_Features__c=null;
                listAttrVal.Setup_Fee__c='';
                update listAttrVal; 
                isIPFlex = false; 
            }  
            isPricingDataAvailable = false;    
            system.debug('@@@Line Items: '+lineItems);
            List<Apttus_Config2__LineItem__c> lineItemPriceClear = new List<Apttus_Config2__LineItem__c>();
            if(lineItems != null && lineItems.size()>0){ 
                for(Apttus_Config2__LineItem__c lineItemClear : lineItems){
                    if(lineItemClear.Apttus_Config2__NetPrice__c != null){
                        lineItemClear.Apttus_Config2__NetPrice__c = 0.00; 
                        lineItemClear.Net_Price_with_Deal_Reg_Discounts__c = lineItemClear.Net_Price_with_SP_Order_Discounts__c = lineItemClear.Original_Hidden_Price__c = lineItemClear.Original_Net_Price__c = null;
                        lineItemClear.isPricingApplied__c = false;
                    }
                    lineItemPriceClear.add(lineItemClear);    
                }      
                if(lineItemPriceClear != null && lineItemPriceClear.size()>0){   
                    update lineItemPriceClear;  
                    totalPerSite =0.0;
                }
            }
            for(QuoteProducts.cCustomerSite cs : ListCustomerSite){
                if( cs.custSiteIns.Id == selectedSiteId ){
                    cs.attCustomerSiteTotal = 0.0;
                    cs.attCustomerSiteOneTime = 0.0;
                }
            }
        }
        initializedata();
        Apttus_Config2__ProductConfiguration__c prodConfig = quoteHelper.retrieveExistingCartId(quoteId);
        readPricingStatusForAllLineItem(prodConfig);
    }
    
    public void removeIPFlexService(){
        List<Apttus_Config2__LineItem__c> lineItemsToClearPrice = new List<Apttus_Config2__LineItem__c>();
        Decimal netPrice = 0.00000;
        if(listAttrVal != null && isAVPN){
            listAttrVal.AT_T_IP_Flexible_Reach__c = false;
            listAttrVal.CoS__c = false;  
            listAttrVal.New_Virtual_Phone_Numbers__c=0;
            listAttrVal.New_Local_Phone_Numbers__c=0;
            listAttrVal.Ported_Phone_Numbers__c=0;
            listAttrVal.IP_Flexible_Reach_Plan__c=null;
            listAttrVal.Concurrent_Calls__c=0;
            listAttrVal.Enhanced_Features__c=null;
            listAttrVal.Setup_Fee__c='';            
        }
        else{
            listAttrVal.AT_T_IP_Flexible_Reach__c = false;
            listAttrVal.CoS__c = false;
            listAttrVal.Managed_Router__c = false;
            listAttrVal.New_Virtual_Phone_Numbers__c=0;
            listAttrVal.New_Local_Phone_Numbers__c=0;
            listAttrVal.Ported_Phone_Numbers__c=0;
            listAttrVal.IP_Flexible_Reach_Plan__c=null;
            listAttrVal.Concurrent_Calls__c=0;
            listAttrVal.Enhanced_Features__c=null;
            listAttrVal.Setup_Fee__c=''; 
            if(listAttrVal.Install_Option_MIS__c!=null && listAttrVal.Install_Option_MIS__c.equalsignorecase('Onsite Install')){
                listAttrVal.Install_Option_MIS__c=null;
            }
        }
        update listAttrVal; 
        System.debug('#####listAttrVal='+listAttrVal);
        isIPFlex = false; 
        isPricingDataAvailable = false;       
        
        if(lineItems != null && lineItems.size()>0){ 
            for(Apttus_Config2__LineItem__c item : lineItems){
                if(item.Apttus_Config2__NetPrice__c != null){
                    item.Apttus_Config2__NetPrice__c = netPrice; 
                    item.Net_Price_with_Deal_Reg_Discounts__c = item.Net_Price_with_SP_Order_Discounts__c = item.Original_Hidden_Price__c = item.Original_Net_Price__c = null;
                    item.isPricingApplied__c = false;
                }
                lineItemsToClearPrice.add(item);    
            }      
            if(lineItemsToClearPrice != null && lineItemsToClearPrice.size()>0){   
                update lineItemsToClearPrice;  
                totalPerSite =0.0;
            }
        }
        for(QuoteProducts.cCustomerSite cs : ListCustomerSite){
            if( cs.custSiteIns.Id == selectedSiteId ){
                cs.attCustomerSiteTotal = 0.0;
                cs.attCustomerSiteOneTime = 0.0;
                
            }
        }
        initializedata();
        Apttus_Config2__ProductConfiguration__c prodConfig = quoteHelper.retrieveExistingCartId(quoteId);
        readPricingStatusForAllLineItem(prodConfig);
    }
    
    public void handleHiCapOnRefresh(){        
        if(listAttrVal != null ){
            if(listAttrVal.Hi_Cap_Flex__c == true ){
                isHiCapFlex = true;           
            }
            else{
                isHiCapFlex = false;
            }
        }
    }
    
    public void handleIPFlexOnRefresh(){  
        if(listAttrVal != null){
            if(listAttrVal.AT_T_IP_Flexible_Reach__c == true){
                isIPFlex = true;           
            }
            else{
                isIPFlex = false;
            }
        }
    }
  
    public void initiateITPAServiceCall(){
        system.debug('@@@^inside initiateITPAServiceCall');
        validSitesToConfigureList = [SELECT Account_End_Customer_Junction__c,Address_Line1__c,Address_Line__c,AIA_Response_Status__c,ASES__c,ATT_Site_ID__c,AVPN__c,BRASSResponse__c,BRASS_Request_Time__c,BRASS_Response_Status__c,City__c,Country__c,County__c,CreatedById,CreatedDate,Display_All_Speeds__c,Duplicate_Check__c,End_Customer__c,Hub__c,Id,Interface_Type__c,IPFlex_Plans_Qualified__c,IpId_Availability_Indicator__c,IsDeleted,isRDS_Saved_Indicator__c,ITPA_Failure_Fault_Code__c,ITPA_Request_Time__c,ITPA_Response__c,ITPA_Validated_Address__c,LecName__c,Location_Number__c,Location__c,Mileage__c,MIS__c,Name,Near_Match_Indicator__c,OwnerId,Phone__c,popCLLI__c,Quantity__c,RDS_JSON_Request__c,Region__c,RoomBuildingFloorInput__c,Service_Availability_Response__c,Service_Avail_Key__c,Site_Description__c,Site_Name__c,Site_Number__c,Speed_Name__c,Speed_Physical_Value__c,Speed_Unit__c,State__c,swcCLLI__c,SWPO_Flag__c,SWPO_RDS_Information__c,SystemModstamp,Temp_ID__c,Transport_Type__c,Urbanization__c,Validated__c,VASAResponse__c,VASA_Request_Time__c,VASA_Response_Status__c,VOIP_Availability_Flag__c,VOIP_Local_Availability_Indicator__c,Zip_Code_Extension__c,Zip_Code__c,Zip_Geo_Code__c FROM CustomerSite__c where id=: selectedSiteId];
        ITPAServiceRespose= ITPAServiceAvailabilityUtil.doITPACall(validSitesToConfigureList,ITPAresponse,quoteid);
    }

    public void ITPAInitiatePopUp(){
        doITPAPolling=true;
        ITPAError=false;
        CustomerSite__c customerSiteForITPA;
        if(selectedSiteId!=null && selectedSiteId!=''){
            customerSiteForITPA= [SELECT Id, Site_Name__c, Address_Line__c, City__c, State__c, Zip_Code__c, Phone__c,Location__c,VASA_Response_Status__c  From CustomerSite__c where Id =: selectedSiteId];
            if(customerSiteForITPA!=null){
                selectedSitePhone = customerSiteForITPA.Phone__c;
            } 
        }
    }
    
    public void initiateITPAService(){
        doITPAPolling=true;
        ITPAError=false;
        CustomerSite__c custSiteUpdate=new CustomerSite__c();
        custSiteUpdate =[SELECT Id,Phone__c,Phone_Number_Updated__c,ITPA_Processing_Complete__c From CustomerSite__c where id =: selectedSiteId];
        if(custSiteUpdate.Phone__c != selectedSitePhone){
            custSiteUpdate.Phone__c=selectedSitePhone;
            custSiteUpdate.Phone_Number_Updated__c = true;
        }   
        custSiteUpdate.ITPA_Processing_Complete__c = false; 
        update custSiteUpdate;
        validSitesToConfigureList.add(custSiteUpdate);
    }
    
    public void startITPAPolling(){
        doITPAPolling=true;
        ITPAError=false;
        CustomerSite__c custSiteSelect=new CustomerSite__c();
        custSiteSelect=[SELECT Id,Phone__c, ITPA_Response_Code__c,ITPA_Response_Description__c, IPFLEX_Availability_Flag__c,Number_Portability_Indicator__c,Number_Availability_Indicator__c,VirtualTN_Availability_Indicator__c, ITPA_Processing_Complete__c From CustomerSite__c where id =: selectedSiteId];
        if(custSiteSelect.ITPA_Processing_Complete__c ){ 
            if(custSiteSelect.Number_Availability_Indicator__c != null){
                NumberAvailabilityIndicator = custSiteSelect.Number_Availability_Indicator__c;
            }
            if(custSiteSelect.Number_Portability_Indicator__c != null){
                NumberPortabilityIndicator = custSiteSelect.Number_Portability_Indicator__c;
            }
            if(custSiteSelect.VirtualTN_Availability_Indicator__c != null){
                VirtualTNAvailabilityIndicator = custSiteSelect.VirtualTN_Availability_Indicator__c;
            }
            doITPAPolling=false;
            if(custSiteSelect.IPFLEX_Availability_Flag__c == 'true'){
                ITPAServiceRespose=true;                
            }
            else{
                ITPAServiceRespose=false;                
                if(custSiteSelect.ITPA_Response_Code__c=='100' || custSiteSelect.ITPA_Response_Code__c=='200' || custSiteSelect.ITPA_Response_Code__c=='300' ||  custSiteSelect.ITPA_Response_Code__c=='400' ||  custSiteSelect.ITPA_Response_Code__c=='900'){
                    ITPAError=true;
                }
            }
        }
    }
    
    /*****************************************************************************
    * Method name : fetchSoftDeletedSites()
    * Description : This method returns the list with soft deleted site ids for a particular quote. See VF page for remoting call
    * Return Type : list<id>
    * Parameters  : Quote id
    ******************************************************************************/
    @RemoteAction
    public static list<id> fetchSoftDeletedSites(String quoteid){
        noOfSoftDeletedSites=0;
        list<AT_T_Customer_Site_Quote__c> multipleJunctionList = new list<AT_T_Customer_Site_Quote__c>();
        list<id> fetchSoftDeletedSiteList = new list<id>();
        if(quoteid != null){
            multipleJunctionList = [SELECT Id,Is_Soft_Deleted__c, AT_T_Customer_Site__c, AT_T_Quote__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c  =: quoteId];
        }
        if(!multipleJunctionList.isEmpty()){
            for(AT_T_Customer_Site_Quote__c junctionObj: multipleJunctionList){
                if(junctionObj.Is_Soft_Deleted__c == true){
                    fetchSoftDeletedSiteList.add(junctionObj.AT_T_Customer_Site__c);
                }
            }
        }
        if(!fetchSoftDeletedSiteList.isEmpty()){
            noOfSoftDeletedSites = fetchSoftDeletedSiteList.size();
            return fetchSoftDeletedSiteList;
        } else {
            noOfSoftDeletedSites= 0;
            return null;
        }
    }
    
    /*****************************************************************************
    * Method name : undoSoftDelete
    * Description : This method would update the junction object to unmark soft delete.
    * Return Type : void.
    * Parameters  : String from VF Remoting.
    ******************************************************************************/
    @RemoteAction
    public static string undoSoftDelete(String junctToUndoSoftDeleteVR,String quoteId ){
        String junctToUnDoSoftDeleteString = junctToUndoSoftDeleteVR;
        list<AT_T_Customer_Site_Quote__c> multipleJunctionList = new list<AT_T_Customer_Site_Quote__c>();
        set<id> junctionIdSet = new set<id>();
        list<AT_T_Customer_Site_Quote__c> junctionUpdateList = new list<AT_T_Customer_Site_Quote__c>();
        if(quoteid != null){
            multipleJunctionList = [SELECT Id, AT_T_Customer_Site__c, AT_T_Quote__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c  =: quoteId];
        }
        if(junctToUnDoSoftDeleteString!=null && junctToUnDoSoftDeleteString !=''){
            for(AT_T_Customer_Site_Quote__c junctionObj: multipleJunctionList){
                if(junctToUnDoSoftDeleteString.contains(junctionObj.AT_T_Customer_Site__c)){
                    junctionIdSet.add(junctionObj.id);
                }
            }
            for(AT_T_Customer_Site_Quote__c junctionObj2: [select id ,Is_Soft_Deleted__c,AT_T_Customer_Site__c from AT_T_Customer_Site_Quote__c where Id in :junctionIdSet ]){
                junctionObj2.Is_Soft_Deleted__c = false;
                junctionUpdateList.add(junctionObj2);
            }    
        }
        if(!junctionUpdateList.isEmpty()){
            update junctionUpdateList;
        }
        return null;
    }    
    
    /*****************************************************************************
    * Method name : removeConfigureSite
    * Description : This method would update the junction object whether should it be marked as soft delete or not.
    * Return Type : void.
    * Parameters : None.
    ******************************************************************************/
    
    public void removeConfigureSite(){
        noOfSoftDeletedSites = 0;
        String junctToSoftDeleteString = junctToSoftDelete;
        List<String> junctToSoftDeleteList = new List<String>();
        Apttus_Proposal__Proposal__c quoteObjj = new Apttus_Proposal__Proposal__c();
        list<AT_T_Customer_Site_Quote__c> junctionUpdateList = new list<AT_T_Customer_Site_Quote__c>();
        list<AT_T_Customer_Site_Quote__c> multipleJunctionList = new list<AT_T_Customer_Site_Quote__c>();
        set<id> junctionIdSet = new set<id>();
        if(quoteid != null){
            multipleJunctionList = [SELECT Id, AT_T_Customer_Site__c, AT_T_Quote__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c  =: quoteId];
            quoteObjj = [SELECT Id, SiteRemovalCheck__c FROM Apttus_Proposal__Proposal__c WHERE id =: quoteId];
        }
        if(junctToSoftDelete!=null && junctToSoftDelete!=''){
            junctToSoftDeleteList = junctToSoftDeleteString.split(',');
        } 
        if(junctToSoftDeleteString != null && junctToSoftDeleteString!=''){
            for(AT_T_Customer_Site_Quote__c junctionObj: multipleJunctionList){
                if(junctToSoftDeleteString.contains(junctionObj.AT_T_Customer_Site__c)){
                    junctionIdSet.add(junctionObj.id);
                }
            }
            for(AT_T_Customer_Site_Quote__c junctionObj2: [select id ,Is_Soft_Deleted__c,AT_T_Customer_Site__c from AT_T_Customer_Site_Quote__c where Id in :junctionIdSet ]){
                junctionObj2.Is_Soft_Deleted__c = true;
                junctionUpdateList.add(junctionObj2);
            }
        }
        if(!junctionUpdateList.isEmpty()){
            update junctionUpdateList;
        }
        if(quoteObjj != Null){
            quoteObjj.SiteRemovalCheck__c = true;
            update quoteObjj;
        }
        checkDiscard = false;
        checkForEligibleSitesCount();
    }
    
    public void cancelConfigureSiteChanges(){
        configureSitesFlag = false;
        selectAllCheckBox = false;        
        for(QuoteProducts.cCustomerSite IpflexSite : listCustomerSiteMaster){
            IpflexSite.eligibleSFlag=false;
            IpflexSite.siteEnabled=true;
            IpflexSite.selected= false;
        }
    }
    
    public void removeConfigureSiteTest(){
    
    }
  
    public void getInterfaceType(String selSiteId){
        String region='';
        set<String>  lecscopeList =new set<String>();
        Map<Id,String> siteAndLecName=new Map<Id,String>();
        String JSONResponse='';
        CustomerSite__c  custSite = [SELECT Id, Service_Availability_Response__c FROM CustomerSite__c  WHERE Id =: selSiteId LIMIT 1];
        
        if(custSite!=null){
            JSONResponse = custSite.Service_Availability_Response__c;
            if (String.isNotBlank(JSONResponse)){
                JSONResponse = JSONResponse.replaceAll(regExp,'"');
                AddrValidServAvailResponseBean ResponseBean = new AddrValidServAvailResponseBean();
                ResponseBean = (AddrValidServAvailResponseBean)JSON.Deserialize(JSONResponse,AddrValidServAvailResponseBean.class);
                AddressServiceAvailabilityList = ResponseBean.AddressServiceAvailability;                
                AddrValidServAvailResponseBean.ServiceAvailabilityDetails ServiceAvailabilityDetailsObj = new AddrValidServAvailResponseBean.ServiceAvailabilityDetails(); 
                if(AddressServiceAvailabilityList!=null && AddressServiceAvailabilityList.size()>0){                               
                    for(AddrValidServAvailResponseBean.AddressServiceAvailability response: AddressServiceAvailabilityList){                          
                        if (response.region =='N' || response.region == 'O'){                       
                            lecscopeList.add(response.lecName);
                            siteAndLecName.put(custSite.id,response.lecName);
                        }
                    } 
                }
            }
        }
        
        Map<integer,Set<String>> speedInterfaceTypeMap=new Map<integer,Set<String>>();
        Map<String,Map<integer,Set<String>>> siteInterfaceTypeMap=new Map<String,Map<integer,Set<String>>>();        
        Set<String> accessSpeed5;
        Set<String> accessSpeed10;
        Set<String> accessSpeed20;
        Set<String> accessSpeed50;
        Set<String> accessSpeed100;
        
        if(lecscopeList.size()>0){
            List<Provider_Grouping__c> pgList=[Select lecName__c, Interface_Type__c, Speed__c, VASA_Region__c from Provider_Grouping__c where lecName__c in: lecscopeList];
            JSONResponse = custSite.Service_Availability_Response__c;
            if(String.isNotBlank(JSONResponse)){
                JSONResponse = JSONResponse.replaceAll(regExp,'"');
                AddrValidServAvailResponseBean ResponseBean1 = new AddrValidServAvailResponseBean();
                ResponseBean1 = (AddrValidServAvailResponseBean)JSON.Deserialize(JSONResponse,AddrValidServAvailResponseBean.class);
                AddressServiceAvailabilityList = ResponseBean1.AddressServiceAvailability;                
                AddrValidServAvailResponseBean.ServiceAvailabilityDetails ServiceAvailabilityDetailsObj = new AddrValidServAvailResponseBean.ServiceAvailabilityDetails(); 
                if(AddressServiceAvailabilityList!=null && AddressServiceAvailabilityList.size()>0){                               
                    for(AddrValidServAvailResponseBean.AddressServiceAvailability response: AddressServiceAvailabilityList){ 
                        if(response.region =='N' || response.region == 'O'){                      
                            for(Provider_Grouping__c pg:pgList){
                                accessSpeed5=new Set<String>();
                                accessSpeed10=new Set<String>();
                                accessSpeed20=new Set<String>();
                                accessSpeed50=new Set<String>();
                                accessSpeed100=new Set<String>();
                          
                                if( integer.valueof(pg.speed__c) <= 100 && pg.lecName__c==response.lecName){
                                    if(pg.Interface_Type__c.equalsignorecase('Optical')){                                       
                                        if(integer.valueof(pg.speed__c) == 5){
                                            if(speedInterfaceTypeMap!=null && speedInterfaceTypeMap.size() > 0 && speedInterfaceTypeMap.get(integer.valueof(pg.speed__c))!=null){
                                                accessSpeed5=speedInterfaceTypeMap.get(integer.valueof(pg.speed__c));                                           
                                            }
                                            accessSpeed5.add('Optical Single Mode - 1000 Base LX');
                                            accessSpeed5.add('Optical Multi Mode - 1000 Base SX');
                                            speedInterfaceTypeMap.put(integer.valueof(pg.speed__c),accessSpeed5);
                                        }
                                        else if(integer.valueof(pg.speed__c) == 10){
                                            if(speedInterfaceTypeMap!=null && speedInterfaceTypeMap.size() > 0 && speedInterfaceTypeMap.get(integer.valueof(pg.speed__c))!=null){
                                                accessSpeed10=speedInterfaceTypeMap.get(integer.valueof(pg.speed__c));                                          
                                            }
                                            accessSpeed10.add('Optical Single Mode - 1000 Base LX');
                                            accessSpeed10.add('Optical Multi Mode - 1000 Base SX');
                                            speedInterfaceTypeMap.put(integer.valueof(pg.speed__c),accessSpeed10); 
                                        }
                                        else if(integer.valueof(pg.speed__c) == 20){
                                            if(speedInterfaceTypeMap!=null && speedInterfaceTypeMap.size() > 0 && speedInterfaceTypeMap.get(integer.valueof(pg.speed__c))!=null){
                                                accessSpeed20=speedInterfaceTypeMap.get(integer.valueof(pg.speed__c));
                                            }
                                            accessSpeed20.add('Optical Single Mode - 1000 Base LX');
                                            accessSpeed20.add('Optical Multi Mode - 1000 Base SX');
                                            speedInterfaceTypeMap.put(integer.valueof(pg.speed__c),accessSpeed20);
                                        }
                                        else if(integer.valueof(pg.speed__c) == 50){
                                            if(speedInterfaceTypeMap!=null && speedInterfaceTypeMap.size() > 0 && speedInterfaceTypeMap.get(integer.valueof(pg.speed__c))!=null){
                                                accessSpeed50=speedInterfaceTypeMap.get(integer.valueof(pg.speed__c));  
                                            }
                                            accessSpeed50.add('Optical Single Mode - 1000 Base LX');
                                            accessSpeed50.add('Optical Multi Mode - 1000 Base SX');
                                            speedInterfaceTypeMap.put(integer.valueof(pg.speed__c),accessSpeed50);
                                        }
                                        else if(integer.valueof(pg.speed__c) == 100){
                                            if(speedInterfaceTypeMap!=null && speedInterfaceTypeMap.size() > 0 && speedInterfaceTypeMap.get(integer.valueof(pg.speed__c))!=null){
                                                accessSpeed100=speedInterfaceTypeMap.get(integer.valueof(pg.speed__c)); 
                                            }
                                            accessSpeed100.add('Optical Single Mode - 1000 Base LX');
                                            accessSpeed100.add('Optical Multi Mode - 1000 Base SX');
                                            speedInterfaceTypeMap.put(integer.valueof(pg.speed__c),accessSpeed100);
                                        }                                          
                                    }
                                
                                    if(pg.Interface_Type__c.equalsignorecase('Electrical')){
                                        if(integer.valueof(pg.speed__c) == 5){
                                            if(speedInterfaceTypeMap!=null && speedInterfaceTypeMap.size() > 0 && speedInterfaceTypeMap.get(integer.valueof(pg.speed__c))!=null){
                                                accessSpeed5=speedInterfaceTypeMap.get(integer.valueof(pg.speed__c));
                                            }
                                            accessSpeed5.add('Electrical - 100 Base TX');
                                            speedInterfaceTypeMap.put(integer.valueof(pg.speed__c),accessSpeed5);
                                        }
                                        else if(integer.valueof(pg.speed__c) == 10){
                                            if(speedInterfaceTypeMap!=null && speedInterfaceTypeMap.size() > 0 && speedInterfaceTypeMap.get(integer.valueof(pg.speed__c))!=null){   
                                                accessSpeed10=speedInterfaceTypeMap.get(integer.valueof(pg.speed__c));  
                                            }
                                            accessSpeed10.add('Electrical - 100 Base TX');
                                            speedInterfaceTypeMap.put(integer.valueof(pg.speed__c),accessSpeed10);
                                        }
                                        else if(integer.valueof(pg.speed__c) == 20){
                                            if(speedInterfaceTypeMap!=null && speedInterfaceTypeMap.size() > 0 && speedInterfaceTypeMap.get(integer.valueof(pg.speed__c))!=null){
                                                accessSpeed20=speedInterfaceTypeMap.get(integer.valueof(pg.speed__c));  
                                            }
                                            accessSpeed20.add('Electrical - 100 Base TX');
                                            speedInterfaceTypeMap.put(integer.valueof(pg.speed__c),accessSpeed20);
                                        }
                                        else if(integer.valueof(pg.speed__c) == 50){
                                            if(speedInterfaceTypeMap!=null && speedInterfaceTypeMap.size() > 0 && speedInterfaceTypeMap.get(integer.valueof(pg.speed__c))!=null){    
                                                accessSpeed50=speedInterfaceTypeMap.get(integer.valueof(pg.speed__c));  
                                            }
                                            accessSpeed50.add('Electrical - 100 Base TX');
                                            speedInterfaceTypeMap.put(integer.valueof(pg.speed__c),accessSpeed50);
                                        }
                                        else if(integer.valueof(pg.speed__c) == 100){
                                            if(speedInterfaceTypeMap!=null && speedInterfaceTypeMap.size() > 0 && speedInterfaceTypeMap.get(integer.valueof(pg.speed__c))!=null){
                                                accessSpeed100=speedInterfaceTypeMap.get(integer.valueof(pg.speed__c)); 
                                            }   
                                            accessSpeed100.add('Electrical - 100 Base TX');
                                            speedInterfaceTypeMap.put(integer.valueof(pg.speed__c),accessSpeed100);
                                        }                                                                         
                                    }
                                }
                            }
                            siteInterfaceTypeMap.put(custSite.Id,speedInterfaceTypeMap);
                        }  
                    } 
                }           
            }
        } 
        interfaceTypeMap=siteInterfaceTypeMap.get(selectedSiteId);
        if(interfaceTypeMap!=null && interfaceTypeMap.size()>0){
          interfaceType5=interfaceTypeMap.get(5);
          interfaceType10=interfaceTypeMap.get(10);
          interfaceType20=interfaceTypeMap.get(20);
          interfaceType50=interfaceTypeMap.get(50);
          interfaceType100=interfaceTypeMap.get(100);
        }
    }
      
    /** Below two methods for US794164 **/
    public List<selectOption> fetchCNUMValues(){
        List<ASE_Wholesale_Contract_Number__c> CNUMList = null;
        if(selectedTerm != null) {
            CNUMList = [Select Id,Fiber__c,Broadband__c,Name,Short_Description__c,Rate_Card__c,Rate_Card_Type__c,PPCoS__c From ASE_Wholesale_Contract_Number__c WHERE Account_Name__c = :accountId and Active__c = true AND Term__c INCLUDES (:selectedTerm) ORDER BY Name ASC];
        }
        List<selectOption> CNUMSelectList = new List<selectOption>();
        cnumObjectMap = new Map<String,ASE_Wholesale_Contract_Number__c>();        
        if(CNUMList != null && CNUMList.size() > 0){
            String description = '';
            for(ASE_Wholesale_Contract_Number__c cnums : CNUMList){
                if(cnums.Short_Description__c != null){
                    description = ' '+cnums.Short_Description__c;
                }
                CNUMSelectList.add(new SelectOption(cnums.Name+description,cnums.Name+description));
                cnumObjectMap.put(cnums.name+description,cnums);
                description ='';
            }
        }
        return CNUMSelectList;
    }
    
    /** Method to show CNUM overlay for ASE product **/
    public void showCNUMOverlay(){
        fetchCNUMValues();
        system.debug('@@@@selectedSiteId'+selectedSiteId );
        system.debug('@@@@CNUMDropdownValue'+CNUMDropdownValue);
        showASEOverlay = false;
        if(CNUMDropdownValue != null && cnumObjectMap.get(CNUMDropdownValue).Rate_Card_Type__c != null && cnumObjectMap.get(CNUMDropdownValue).Rate_Card_Type__c.equalsIgnoreCase('Promotion')){
            if(String.isNotBlank(selectedSiteId)){
                CustomerSite__c selectedSiteInformation = [SELECT Id, Building_Cili__c,Code_EMUX_Fiber__c FROM CustomerSite__c  WHERE Id =: selectedSiteId LIMIT 1];
                String buildingCili = '';
                String productFTTBCode = '';
                if(selectedSiteInformation != null){
                    buildingCili = selectedSiteInformation.Building_Cili__c;
                    if(String.isNotBlank(buildingCili)){
                        productFTTBCode = selectedSiteInformation.Code_EMUX_Fiber__c;
                        if(String.isBlank(productFTTBCode)){
                            List<Fiber_Lit_Building_List__c> fiberList = [Select Id,Name FROM Fiber_Lit_Building_List__c];
                            Map<String,String> fiberListBuildingCili = new Map<String,String>();
                            for(Fiber_Lit_Building_List__c fiber : fiberList){
                                fiberListBuildingCili.put(fiber.Name,fiber.Id);
                            }
                            if(!fiberListBuildingCili.containsKey(buildingCili)){
                                showASEOverlay = true;
                            }
                        }else if(!productFTTBCode.equalsIgnoreCase('E')){
                            showASEOverlay = true;
                        }
                    }else{
                        showASEOverlay = true;
                    }
                }
            }
        }
        checkBasicBroadbandEnablement();
    }
        
    public void pollingMethod(){
        Integer delayInMilliseconds = 20;        
        Long startingTime = System.now().getTime();                 
        Long nowTime;    
        while ((nowTime = System.now().getTime()) - startingTime < delayInMilliseconds) {
        }
    }     
    
    public void longPollingMethod(){
        Integer delayInMilliseconds = 50;        
        Long startingTime = System.now().getTime();                 
        Long nowTime;    
        while ((nowTime = System.now().getTime()) - startingTime < delayInMilliseconds) {
        }
    }
        
    /** Method to check whether to enable ASE Basic and ASE Broadband Radio buttons for ASE **/
    public void checkBasicBroadbandEnablement(){
        fetchCNUMValues();
        isAFBR = false;
        isEoCU = false;
        isASEoLS = false;
        enableASEBasic = false;
        enableASEBroadband = false;
        isPromotion = false;
        isMaster = false;
        isPPCoS = false;
        String serviceTypes = '';
        String term = '';
        String rateCardSearchString = '';
                
        system.debug('@@@CNUMDropdownValue : '+CNUMDropdownValue);
        system.debug('@@@proposalData: '+proposalData);
        system.debug('@@@cnumObjectMap: '+cnumObjectMap);
        if(CNUMDropdownValue != null && cnumObjectMap != null && cnumObjectMap.get(CNUMDropdownValue).Rate_Card_Type__c != null && cnumObjectMap.get(CNUMDropdownValue).PPCoS__c != null && proposalData != null && proposalData.Apttus_Proposal__Payment_Term__c != null && proposalData.Apttus_Proposal__Payment_Term__c != ''  && cnumObjectMap != NULL && cnumObjectMap.get(CNUMDropdownValue) != null){
            if(cnumObjectMap.get(CNUMDropdownValue).Rate_Card_Type__c.equalsIgnoreCase('Promotion')){
                isPromotion = true;
            }
            rateCardSearchString = ('%'+cnumObjectMap.get(CNUMDropdownValue).Rate_Card__c+'%').deleteWhitespace();
            if(cnumObjectMap.get(CNUMDropdownValue).Rate_Card__c == 'Master'){
                isMaster = true;
            }            
            if(cnumObjectMap.get(CNUMDropdownValue).PPCoS__c.equalsIgnoreCase('Yes')){
                isPPCoS = true;
            }
            term = proposalData.Apttus_Proposal__Payment_Term__c;
            if(String.isNotBlank(selectedSiteId)){
                CustomerSite__c selectedSiteInformation = [SELECT Id, Service_Types__c,AFBR_Port_Speed__c,AEoCU_Port_Speed__c FROM CustomerSite__c  WHERE Id =: selectedSiteId LIMIT 1];
                if(selectedSiteInformation != null){
                    serviceTypes = selectedSiteInformation.Service_Types__c;
                    if(serviceTypes != '' && serviceTypes != null){
                        if(serviceTypes.contains('AFBR')){
                            isAFBR =  true;
                        }
                        if(serviceTypes.contains('AEOCU')){
                            isEoCU =  true;
                        }
                        if(serviceTypes.contains('ASEoLS')){
                            isASEoLS =  true;
                        }  
                    }
                }
                system.debug('@@@@Service Types: '+serviceTypes+' AFBR: '+isAFBR+' EoCU: '+isEoCU+' ASEoLS: ' +isASEoLS);
                system.debug('@@@@isPromotion: '+isPromotion);
                system.debug('@@@isMaster: '+isMaster);
                system.debug('@@@@isPPCoS: '+isPPCoS);
                system.debug('@@@rateCardSearchString: '+rateCardSearchString);
                
                if(isPromotion == true){            
                    basicPMList = [select id, PriceListName__c, Charge_Type_PL__c, Apttus_Config2__Dimension2Value__c, Description_PL__c from Apttus_Config2__PriceMatrixEntry__c where PriceListName__c = 'ASE Price List' and Charge_Type_PL__c = 'Port Speed Fee' and Description_PL__c like '%Basic%' and Description_PL__c like '%Promotion%' and Apttus_Config2__Dimension2Value__c =: term];
                    system.debug('@@@@Basic PM List - Promotion: '+basicPMList);
                    if(basicPMList.size() > 0  && (isAFBR == true || isEoCU == true) && cnumObjectMap.get(CNUMDropdownValue).Fiber__c == 'Yes'){
                        enableASEBasic = true;
                    }else{
                        enableASEBasic = false;
                    }
                    
                    broadbandPMList = [select id, PriceListName__c, Charge_Type_PL__c, Apttus_Config2__Dimension2Value__c, Description_PL__c from Apttus_Config2__PriceMatrixEntry__c where PriceListName__c = 'ASE Price List' and Charge_Type_PL__c = 'Port Speed Fee' and Description_PL__c like '%Broadband%' and Description_PL__c like '%Promotion%' and  Apttus_Config2__Dimension2Value__c =: term];
                    system.debug('@@@@Broadband PM List - Promotion: '+broadbandPMList);
                    if(broadbandPMList.size() > 0 && (isASEoLS == true) && cnumObjectMap.get(CNUMDropdownValue).Broadband__c == 'Yes'){
                        enableASEBroadband = true;
                    }else{
                        enableASEBroadband = false;
                    }
                }else if(isMaster == true){
                    basicPMList = [select id, PriceListName__c, Charge_Type_PL__c, Apttus_Config2__Dimension2Value__c, Description_PL__c from Apttus_Config2__PriceMatrixEntry__c where PriceListName__c = 'ASE Price List' and Charge_Type_PL__c = 'Port Speed Fee' and Description_PL__c like '%Basic%' and Description_PL__c like '%-Master-%' and Apttus_Config2__Dimension2Value__c =: term];
                    system.debug('@@@@Basic PM List - NO Promotion: '+basicPMList);
                    if(basicPMList.size() > 0  && (isAFBR == true || isEoCU == true) && cnumObjectMap.get(CNUMDropdownValue).Fiber__c == 'Yes'){
                        enableASEBasic = true;
                    }else{
                        enableASEBasic = false;
                    }
                    
                    broadbandPMList = [select id, PriceListName__c, Charge_Type_PL__c, Apttus_Config2__Dimension2Value__c, Description_PL__c  from Apttus_Config2__PriceMatrixEntry__c where PriceListName__c = 'ASE Price List' and Charge_Type_PL__c = 'Port Speed Fee' and Description_PL__c like '%Broadband%' and Description_PL__c like '%-Master)%' and Apttus_Config2__Dimension2Value__c =: term];
                    system.debug('@@@@Broadband PM List - NO Promotion: '+broadbandPMList);
                    if(broadbandPMList.size() > 0 && (isASEoLS == true) && cnumObjectMap.get(CNUMDropdownValue).Broadband__c == 'Yes' ){
                        enableASEBroadband = true;
                    }else{
                        enableASEBroadband = false;
                    }          
                }else{
                    basicPMList = [select id, PriceListName__c, Charge_Type_PL__c, Apttus_Config2__Dimension2Value__c, Description_PL__c from Apttus_Config2__PriceMatrixEntry__c where PriceListName__c = 'ASE Price List' and Charge_Type_PL__c = 'Port Speed Fee' and Description_PL__c like '%Basic%' and Description_PL__c like :rateCardSearchString and Apttus_Config2__Dimension2Value__c =: term];
                    system.debug('@@@@Basic PM List - NO Promotion: '+basicPMList);
                    if(basicPMList.size() > 0  && (isAFBR == true || isEoCU == true) && cnumObjectMap.get(CNUMDropdownValue).Fiber__c == 'Yes'){
                        enableASEBasic = true;
                    }else{
                        enableASEBasic = false;
                    }
                    
                    broadbandPMList = [select id, PriceListName__c, Charge_Type_PL__c, Apttus_Config2__Dimension2Value__c, Description_PL__c  from Apttus_Config2__PriceMatrixEntry__c where PriceListName__c = 'ASE Price List' and Charge_Type_PL__c = 'Port Speed Fee' and Description_PL__c like '%Broadband%' and Description_PL__c like :rateCardSearchString and Apttus_Config2__Dimension2Value__c =: term];
                    system.debug('@@@@Broadband PM List - NO Promotion: '+broadbandPMList);
                    if(broadbandPMList.size() > 0 && (isASEoLS == true) && cnumObjectMap.get(CNUMDropdownValue).Broadband__c == 'Yes' ){
                        enableASEBroadband = true;
                    }else{
                        enableASEBroadband = false;
                    }
                }
                
                if(selectedSiteInformation != null){
                    if((selectedSiteInformation.AFBR_Port_Speed__c == null || selectedSiteInformation.AFBR_Port_Speed__c == '' || selectedSiteInformation.AFBR_Port_Speed__c.remove(',').trim() == '100G')
                    && (selectedSiteInformation.AEoCU_Port_Speed__c== null || selectedSiteInformation.AEoCU_Port_Speed__c== '' || selectedSiteInformation.AEoCU_Port_Speed__c.remove(',').trim() == '100G')){                       
                        enableASEBasic = false;
                    }                    
                }
            }
        }
    }
    
    /** Method to load data on ASE configuration page from AV Record **/    
    public void loadASEConfigurationData(Apttus_Config2__ProductAttributeValue__c attributeValues){      
        tierInfo = new customersite__c();
        if(selectedSiteId != null){
            tierInfo = [SELECT Id, Tier__c,AEoCU_Port_Speed__c,AFBR_Port_Speed__c FROM CustomerSite__c  WHERE Id =: selectedSiteId LIMIT 1];
        }
        if(tierInfo.Tier__c != null && tierInfo.Tier__c != ''){
            aseTierValue = tierInfo.Tier__c;
        } 
        if(tierInfo != null){
            if(tierInfo.AFBR_Port_Speed__c != null && tierInfo.AFBR_Port_Speed__c != '' && tierInfo.AFBR_Port_Speed__c.remove(',').trim() != '100G'){
               SplitPortSpeedASE(tierInfo.AFBR_Port_Speed__c);         
            }
            else if(tierInfo.AEoCU_Port_Speed__c != null && tierInfo.AEoCU_Port_Speed__c != '' && tierInfo.AEoCU_Port_Speed__c.remove(',').trim() != '100G' ){
                SplitPortSpeedASE(tierInfo.AEoCU_Port_Speed__c);            
            }
            system.debug('@@@@ASE Basic: '+enableASEBasic);
            system.debug('@@@@ASE Broadband: '+enableASEBroadband);
        }
        
        System.debug('BasePortSpeedAseList ===='+BasePortSpeedAseList );
        System.debug('PromoPortSpeedAseList===='+PromoPortSpeedAseList);
        
        if(attributeValues !=null){
            if(attributeValues.Tier__c != null && attributeValues.Tier__c != ''){
                aseTierValue = attributeValues.Tier__c;
            } 
            CNUMDropdownValue = attributeValues.Contract_Number__c;
            serviceTypeRadioValue = attributeValues.ServiceType__c;
            CoSRadioValue = attributeValues.Class_of_Service_TypeASE__c;
            networkTypeRadioValue = attributeValues.Network_TypeASE__c;
            LATARadioValue = attributeValues.LATA__c;
            configTypeRadioValue = attributeValues.Config_TypeASE__c;
            siteDesignationRadioValue = attributeValues.Site_DesignationASE__c;
            portVLANBasedRadioValue = attributeValues.Port_VLAN_BasedASE__c;
            macAddressesRadioValue = attributeValues.MAC_AddressesASE__c;
        }
    }
    
    /** Method to load ASE CIR picklist possible picklist combinations **/
    public void loadASECIRPicklistValues(){        
        Decimal maxSpeedForBasic100Base = 0.00;
        Decimal maxSpeedForBasic100Promo = 0.00;
        Decimal maxSpeedForBasic1000Base = 0.00;
        Decimal maxSpeedForBasic1000Promo = 0.00;
        Decimal maxSpeedForBasic10000Base = 0.00;
        Decimal maxSpeedForBroadband1000 = 0.00; 
        
        list<ASE_Configuration__c> aseCIRDataList = new list<ASE_Configuration__c>();        
        aseCIRDataList = [select id, Field_Name__c, Sequence__c, Value__c, Type__c from ASE_Configuration__c where Field_Name__c = 'Committed Information Rate (CIR)' order by Sequence__c asc];
        system.debug('@@@aseCIRDataList '+aseCIRDataList );
        
        if(aseCIRDataList != null && aseCIRDataList.size() > 0){
            for (ASE_Configuration__c cir: aseCIRDataList){    
                if(cir.Type__c.contains('ASE Basic - 100 Mbps Port - Base')){
                    String tempString = cir.Value__c.replaceAll(',', '');
                    Decimal cirSpeed = Decimal.valueOf(tempString.split(' ').get(0));
                    if(cirSpeed >= maxSpeedForBasic100Base && cirSpeed <= maxSpeedValueBasic){
                        maxSpeedForBasic100Base = cirSpeed;
                    }               
                }    
                if(cir.Type__c.contains('ASE Basic - 100 Mbps Port - Promotional')){
                    String tempString = cir.Value__c.replaceAll(',', '');                    
                    Decimal cirSpeed = Decimal.valueOf(tempString.split(' ').get(0));
                    if(cirSpeed >= maxSpeedForBasic100Promo && cirSpeed <= maxSpeedValueBasic){
                        maxSpeedForBasic100Promo = cirSpeed;
                    }               
                }  
                if(cir.Type__c.contains('ASE Basic - 1 Gbps Port - Base')){
                    String tempString = cir.Value__c.replaceAll(',', ''); 
                    Decimal cirSpeed = Decimal.valueOf(tempString.split(' ').get(0));
                    if(cirSpeed >= maxSpeedForBasic1000Base && cirSpeed <= maxSpeedValueBasic){
                        maxSpeedForBasic1000Base = cirSpeed;
                    }               
                } 
                if(cir.Type__c.contains('ASE Basic - 1 Gbps Port - Promotional')){
                    String tempString = cir.Value__c.replaceAll(',', ''); 
                    Decimal cirSpeed = Decimal.valueOf(tempString.split(' ').get(0));
                    if(cirSpeed >= maxSpeedForBasic1000Promo && cirSpeed <= maxSpeedValueBasic){
                        maxSpeedForBasic1000Promo = cirSpeed;
                    }               
                } 
                if(cir.Type__c.contains('ASE Basic - 10 Gbps Port - Base')){
                    String tempString = cir.Value__c.replaceAll(',', ''); 
                    Decimal cirSpeed = Decimal.valueOf(tempString.split(' ').get(0));
                    if(cirSpeed >= maxSpeedForBasic10000Base && cirSpeed <= maxSpeedValueBasic){
                        maxSpeedForBasic10000Base = cirSpeed;
                    }               
                } 
                if(cir.Type__c.contains('ASE Broadband - 1 Gbps Port - Base & Promotional')){
                    String tempString = cir.Value__c.replaceAll(',', ''); 
                    Decimal cirSpeed = Decimal.valueOf(tempString.split(' ').get(0));
                    if(cirSpeed >= maxSpeedForBroadband1000 && cirSpeed <= maxSpeedValueBroadband){
                        maxSpeedForBroadband1000 = cirSpeed;
                    }               
                } 
            }
            
            string singleQuote = '\'';            
            for (ASE_Configuration__c cir: aseCIRDataList){ 
                if(cir.Type__c.contains('ASE Basic - 100 Mbps Port - Base')){ 
                    String tempString = cir.Value__c.replaceAll(',', ''); 
                    Decimal cirSpeed = Decimal.valueOf(tempString.split(' ').get(0));
                    if(cirSpeed <= maxSpeedForBasic100Base){
                        basic100BaseList.add(singleQuote+cir.Value__c+singleQuote);   
                    }
                }
                if(cir.Type__c.contains('ASE Basic - 100 Mbps Port - Promotional')){ 
                    String tempString = cir.Value__c.replaceAll(',', ''); 
                    Decimal cirSpeed = Decimal.valueOf(tempString.split(' ').get(0));
                    if(cirSpeed <= maxSpeedForBasic100Promo){
                        basic100PromoList.add(singleQuote+cir.Value__c+singleQuote);      
                    }
                }
                if(cir.Type__c.contains('ASE Basic - 1 Gbps Port - Base')){ 
                    String tempString = cir.Value__c.replaceAll(',', '');
                    Decimal cirSpeed = Decimal.valueOf(tempString.split(' ').get(0));
                    if(cirSpeed <= maxSpeedForBasic1000Base){
                        basic1000BaseList.add(singleQuote+cir.Value__c+singleQuote);      
                    }
                }
                if(cir.Type__c.contains('ASE Basic - 1 Gbps Port - Promotional')){ 
                    String tempString = cir.Value__c.replaceAll(',', '');
                    Decimal cirSpeed = Decimal.valueOf(tempString.split(' ').get(0));
                    if(cirSpeed <= maxSpeedForBasic1000Promo){
                        basic1000PromoList.add(singleQuote+cir.Value__c+singleQuote);     
                    }
                }
                if(cir.Type__c.contains('ASE Basic - 10 Gbps Port - Base')){ 
                    String tempString = cir.Value__c.replaceAll(',', '');
                    Decimal cirSpeed = Decimal.valueOf(tempString.split(' ').get(0));
                    if(cirSpeed <= maxSpeedForBasic10000Base){
                        basic10000BaseList.add(singleQuote+cir.Value__c+singleQuote);     
                    }
                }
                if(cir.Type__c.contains('ASE Broadband - 1 Gbps Port - Base & Promotional')){ 
                    String tempString = cir.Value__c.replaceAll(',', '');
                    Decimal cirSpeed = Decimal.valueOf(tempString.split(' ').get(0));
                    if(cirSpeed <= maxSpeedForBroadband1000){
                        broadband1000List.add(singleQuote+cir.Value__c+singleQuote);      
                    }
                }
            }
        }
    }
    
    /** Method to return the maximum possible speed permitted for ASE Configuration **/
    public Decimal getSpeed(String str) {
        Decimal speed = 0.00;
        String unit = '';
        if (str != null && str.length() > 0) {
            speed = Decimal.valueOf(str.substring(0, str.length()-1));
            unit = str.substring(str.length()-1);   
            if (unit == 'G'){
                speed = speed * 1000; 
            }
        }
        return speed;
    }
    
    public void eligibleSiteASE (){
        selctedsiteAVRecords = [select Id,CIR__c ,PortSpeedASE__c,IsPromotional__c,ServiceType__c from Apttus_Config2__ProductAttributeValue__c where AT_T_Customer_Site__c =: selectedSiteId and cartId__c = :cartId order by LastModifiedDate DESC limit 1];         
        string selectedCIR = selctedsiteAVRecords.CIR__c.substring(0, 1);
        String tempString = selctedsiteAVRecords.CIR__c.replaceAll(',', '');
        Decimal selectedCirSpeed= Decimal.valueOf(tempString.split(' ').get(0));
        string currentPortSpeed = selctedsiteAVRecords.PortSpeedASE__c == '100 Mbps Port' ? '100M' : selctedsiteAVRecords.PortSpeedASE__c == '1 Gbps Port'? '1G' : selctedsiteAVRecords.PortSpeedASE__c == '10 Gbps Port'?'10G':'';
        Decimal currentPortSp = getSpeed(currentPortSpeed);        
        maxSpeedBasicAndBroadband(listCustomerSiteMaster);
        for(QuoteProducts.cCustomerSite csite : listCustomerSiteMaster){
            if(aseMaxSpeedMapBasic.size()>0 ){
                csite.aseMaxSpeedBasic = aseMaxSpeedMapBasic.get(csite.custSiteIns.id);  
            }
            if(aseMaxSpeedMapBroadband.size()>0 ){
                csite.aseMaxSpeedBroadband = aseMaxSpeedMapBroadband.get(csite.custSiteIns.id);
            }
            if(aseAFBRSpeedMap.size()>0){
                csite.aFBRPortSpeed = aseAFBRSpeedMap.get(csite.custSiteIns.id);                
            }
            if(aseAEoCUSpeedMap.size()>0){
                csite.aEoCUPortSpeed = aseAEoCUSpeedMap.get(csite.custSiteIns.id);
            }
        }
        
        List<Fiber_Lit_Building_List__c> fiberList = [Select Id,Name FROM Fiber_Lit_Building_List__c];
        Map<String,String> fiberListBuildingCili = new Map<String,String>();
        for(Fiber_Lit_Building_List__c fiber : fiberList){
            fiberListBuildingCili.put(fiber.Name,fiber.Id);
        }
        
        for(QuoteProducts.cCustomerSite csite : listCustomerSiteMaster){
            boolean ASEEligible = true;
            if(selctedsiteAVRecords.IsPromotional__c){                     
                if(String.isNotBlank(csite.custSiteIns.Building_Cili__c)){
                    if(String.isBlank(csite.custSiteIns.Code_EMUX_Fiber__c)){
                        if(!fiberListBuildingCili.containsKey(csite.custSiteIns.Building_Cili__c)){
                                ASEEligible = false;
                                csite.siteEnabled = true;
                                csite.eligibleSFlag = true;
                                csite.eligibleSelected = true;
                            }
                        }else if(!csite.custSiteIns.Code_EMUX_Fiber__c.equalsIgnoreCase('E')){
                            ASEEligible = false;
                            csite.siteEnabled = true;
                            csite.eligibleSFlag = true;
                            csite.eligibleSelected = true;
                        }
                }else{
                    ASEEligible = false;
                    csite.siteEnabled = true;
                    csite.eligibleSFlag = true;
                    csite.eligibleSelected = true;
                }       
            }
            if(selctedsiteAVRecords.ServiceType__c=='ASE Broadband' && ASEEligible == true){
                if(csite.custSiteIns.Id != selectedSiteId){     
                    if(csite.aseMaxSpeedBroadband != 0.00 && csite.aseMaxSpeedBroadband<= aseMaxSpeedMapBroadband.get(selectedSiteId) && selectedCirSpeed<=csite.aseMaxSpeedBroadband    ){
                        eligibleSitesLst.add(csite);
                        eligiblesiteIds.add(csite.custSiteIns.Id);
                        csite.siteEnabled = false;
                        csite.eligibleSFlag = false;
                        csite.eligibleSelected = false;
                    }else{
                        csite.siteEnabled = true;
                        csite.eligibleSFlag = true;
                        csite.eligibleSelected = true;  
                    }
                }
            }else if(selctedsiteAVRecords.ServiceType__c=='ASE Basic'  && ASEEligible == true ){
                if(csite.custSiteIns.Id != selectedSiteId){
                    if(csite.aseMaxSpeedBasic != 0.00 && currentPortSp <= csite.aseMaxSpeedBasic &&  selectedCirSpeed<=csite.aseMaxSpeedBasic && csite.custSiteIns.Id != selectedSiteId && csite.custSiteIns.Tier__c!=null){
                        if(csite.aFBRPortSpeed != null && csite.aFBRPortSpeed != ''  && currentPortSpeed != null && currentPortSpeed != '' && csite.aFBRPortSpeed.remove(',').trim() != '100G'){
                            if(csite.aFBRPortSpeed.containsIgnoreCase(currentPortSpeed)){
                                eligibleSitesLst.add(csite);
                                eligiblesiteIds.add(csite.custSiteIns.Id);
                                csite.siteEnabled = false;
                                csite.eligibleSFlag = false;
                            }
                            else{
                                csite.siteEnabled = true;
                                csite.eligibleSFlag = true;
                                csite.eligibleSelected = true;     
                            } 
                        }
                        else if(csite.aEoCUPortSpeed != null&& csite.aEoCUPortSpeed != '' && currentPortSpeed != null && currentPortSpeed != '' && csite.aEoCUPortSpeed.remove(',').trim() != '100G'){
                            if(csite.aEoCUPortSpeed.containsIgnoreCase(currentPortSpeed)){
                                eligibleSitesLst.add(csite);
                                eligiblesiteIds.add(csite.custSiteIns.Id);
                                csite.siteEnabled = false;
                                csite.eligibleSFlag = false;
                            }
                            else{
                                csite.siteEnabled = true;
                                csite.eligibleSFlag = true;
                                csite.eligibleSelected = true;     
                            } 
                        }                           
                        else{
                            csite.siteEnabled = true;
                            csite.eligibleSFlag = true;
                            csite.eligibleSelected = true;     
                        } 
                    }else{
                        csite.siteEnabled = true;
                        csite.eligibleSFlag = true;
                        csite.eligibleSelected = true;     
                    } 
                }     
            }
        }   
    }   
         
    public void maxSpeedBasicAndBroadband( List<QuoteProducts.cCustomerSite> masterList ){         
        aseMaxSpeedMapBasic = new map<id,decimal>();
        aseMaxSpeedMapBroadband  = new map<id,decimal>();
        aseAFBRSpeedMap = new map<id,String>();
        aseAEoCUSpeedMap = new map<id,String>();        
        list<id> siteIds= new list<id>();
       
        list<CustomerSite__c> siteInfo =  new list<CustomerSite__c>();
        for(QuoteProducts.cCustomerSite site : masterList){
            siteIds.add(site.custSiteIns.id);
        }
        system.debug('@@ PS siteIds '+siteIds);
        if(siteIds != null){
            siteInfo = [SELECT Id,AEoCU_Port_Speed__c,AFBR_Port_Speed__c, Site_Name__c,phone__c,IPFlex_Plans_Qualified__c,VirtualTN_Availability_Indicator__c,Number_Availability_Indicator__c,Number_Portability_Indicator__c, Service_Availability_Response__c,Address_Line__c, City__c, State__c, Tier__c, Service_Types__c, EoCU_Max_CIR_Downstream_Speed__c, AFBR_Max_CIR_Downstream_Speed__c, ASEoLS_Max_CIR_Downstream_Speed__c FROM CustomerSite__c  WHERE Id In: siteIds ];
        }
        for(CustomerSite__c selectedsite: siteInfo){                
            decimal maxSpeedBasic = 0.00;
            decimal maxSpeedBroadband = 0.00;
            
            if(selectedSite.Tier__c != null && selectedSite.Tier__c != ''){
                aseTierValue = selectedSite.Tier__c;
            }
            if(selectedSite.AEoCU_Port_Speed__c != null && selectedSite.AEoCU_Port_Speed__c != '' ){
                aseAEoCUSpeedMap.put(selectedSite.id,selectedSite.AEoCU_Port_Speed__c);
            }
            if(selectedSite.AFBR_Port_Speed__c != null && selectedSite.AFBR_Port_Speed__c != '' ){
                aseAFBRSpeedMap.put(selectedSite.id,selectedSite.AFBR_Port_Speed__c); 
            }
            if(selectedSite.Service_Types__c != null && selectedSite.Service_Types__c != ''){
                if(selectedSite.Service_Types__c.contains('AFBR')){
                    isAFBR =  true;
                }
                if(selectedSite.Service_Types__c.contains('AEOCU')){
                    isEoCU =  true;
                }
                if(selectedSite.Service_Types__c.contains('ASEoLS')){
                    isASEoLS =  true;
                }  
            }
                
            if(isEoCU == true){
                if(selectedSite.EoCU_Max_CIR_Downstream_Speed__c != null && selectedSite.EoCU_Max_CIR_Downstream_Speed__c != ''){
                    maxSpeedBasic = getSpeed(selectedSite.EoCU_Max_CIR_Downstream_Speed__c);
                }
            }       
            if(isAFBR == true){
                if(selectedSite.AFBR_Max_CIR_Downstream_Speed__c != null && selectedSite.AFBR_Max_CIR_Downstream_Speed__c != ''){
                    maxSpeedBasic = getSpeed(selectedSite.AFBR_Max_CIR_Downstream_Speed__c);
                }
            }       
            if(isASEoLS == true ){
                if(selectedSite.ASEoLS_Max_CIR_Downstream_Speed__c != null && selectedSite.ASEoLS_Max_CIR_Downstream_Speed__c != ''){
                    maxSpeedBroadband = getSpeed(selectedSite.ASEoLS_Max_CIR_Downstream_Speed__c);
                }
            }
            if(selectedSite.Service_Types__c.contains('AFBR') || selectedSite.Service_Types__c.contains('AEOCU')){
                aseMaxSpeedMapBasic.put(selectedsite.id,maxSpeedBasic);
            }if(selectedSite.Service_Types__c.contains('ASEoLS')){
                aseMaxSpeedMapBroadband.put(selectedsite.id,maxSpeedBroadband);             
            }
        }
    }
      
    //Selecting VLANBAsed option on PORT/VLAN
    public void selectingVLANBasedOption(){
        portVLANBasedRadioValue = 'VLAN Based';
        listAttrVal.Port_VLAN_BasedASE__c= portVLANBasedRadioValue;
    }
    
    //Clearing options on PORT/VLAN
    public void clearPortVLANOption(){
        portVLANBasedRadioValue = '';
        listAttrVal.Port_VLAN_BasedASE__c= portVLANBasedRadioValue;
    }       
        
    /*Method to filter sites eligible for Igloo Call*/
    public void filterSitesEligibleForIglooCall(Boolean isBulkified){
        Boolean checkInRegionNoJson = false;
        List<Integer> iglooLineItemNumbers = new List<Integer>();
        IglooSiteLst = new List<QuoteProducts.cCustomerSite>();
        nonIglooSiteLst = new List<QuoteProducts.cCustomerSite>();
        if(isBulkified == false){
            for(QuoteProducts.cCustomerSite cs : ListCustomerSite){    
                if( cs.custSiteIns.Id == selectedSiteId ){
                    checkInRegionNoJSON = siteVasaResValidatorIns.checkSiteInRegionNoJSON(cs.custSiteIns);
                    if(checkInRegionNoJSON == false){
                        IglooSiteLst.add(cs);
                    }
                }
            }
            
            if( checkInRegionNoJSON == false && ((listAttrVal.ProductName__c == 'AMIS' && listAttrVal.Port_Type_MIS__c == 'Switched Ethernet') || (listAttrVal.ProductName__c == 'AVPN' && listAttrVal.Port_Type_AVPN__c == 'Switched Ethernet')) ){
                handler.executeIglooLogic(quoteId, selectedSiteId, listAttrVal);
                isAccessDiscountEligible= true;
            }else{
                handler.clearIglooFields(quoteId, selectedSiteId, listAttrVal);
                isAccessDiscountEligible= false;
            }            
            update listAttrVal;
        }
        else if(isBulkified == true){
            for(QuoteProducts.cCustomerSite cs : siteLstNeedsToBeAdded ){
                checkInRegionNoJSON = siteVasaResValidatorIns.checkSiteInRegionNoJSON(cs.custSiteIns);
                if(checkInRegionNoJSON == false && ((listAttrVal.ProductName__c == 'AMIS' && listAttrVal.Port_Type_MIS__c == 'Switched Ethernet') || (listAttrVal.ProductName__c == 'AVPN' && listAttrVal.Port_Type_AVPN__c == 'Switched Ethernet'))){
                    IglooSiteLst.add(cs);
                }else{
                    nonIglooSiteLst.add(cs);
                }
            }    
        }
    } 
    
    /*Method to filter sites eligible for Igloo Call*/
    public void filterSitesEligibleForIglooCallerMethod(){
        PromotionQualifierUtil qualifier = new PromotionQualifierUtil();
        if(!Test.isRunningTest()){           
            filterSitesEligibleForIglooCall(false);
            listAttrVal.IGLOO_Retrial_Failure_Count__c = listAttrVal.IGLOO_Retrial_Failure_Count__c != null ? listAttrVal.IGLOO_Retrial_Failure_Count__c : 0;
            if((!(listAttrVal.AT_T_IP_Flexible_Reach__c && listAttrVal.IP_Flex_Error__c)) && listAttrVal.IGLOO_Call_Failure__c == false && listAttrVal.IGLOO_Speed_Unavailable__c == false){                   
                helper.computePrice(cartId, Integer.valueOf(lineItems[0].Apttus_Config2__LineNumber__c));
            }
            if(isAccessDiscountEligible && listAttrVal.IGLOO_Call_Failure__c == false){
                handler.fetchAccessSpeedDiscountedPrice(quoteId, cartId, Integer.valueOf(lineItems[0].Apttus_Config2__LineNumber__c), listAttrVal);
            }      
        }
        
        //Wireline Promotion Logic
        System.debug('look for me list attr val: '+ listAttrVal);
        qualifier.determinePromotionAtSiteLevel(selectedSiteId,quoteId);
        List<Id> selectedSiteLst = new List<Id>();
        selectedSiteLst.add(selectedSiteId);
        List<Id> avLst = new List<Id>();
        avLst.add(listAttrVal.id);
        system.debug('@@@listAttrVal:'+listAttrVal);
        qualifier.appliedPromotionsCalcuationList(quoteId,selectedSiteLst,avLst);
        system.debug('@@@Wireline Promotion Logic'); 
        
        WirelinePromoCalculationHelper wirelinePromoHelper = new WirelinePromoCalculationHelper();
        list<Wireline_Promotion_Rules__c> wirelinePromoRuleList = new list<Wireline_Promotion_Rules__c>();
        Map<String,List<Wireline_Promotion_Rules__c>> junctionPromoRulesListMap = new Map<String,List<Wireline_Promotion_Rules__c>>();
        set<Id> promoIdSet = new set<Id>();
        List<AT_T_Customer_Site_Quote__c> listSiteJunction = new List<AT_T_Customer_Site_Quote__c>();
        listSiteJunction = [SELECT Id,AT_T_Customer_Site__c,Igloo_Review_Required__c,Wireline_Promotion_Id_Before__c,Wireline_Promotion_Id_After__c,Wireline_Promotion_Id_Applied__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Customer_Site__c=: selectedSiteId and AT_T_Quote__c=: quoteId];
        wirelinePromotionsApplied = listSiteJunction[0].Wireline_Promotion_Id_Applied__c;
        if(String.isNotBlank(wirelinePromotionsApplied) && siteQuoteJunctionId != null){
            wirelinePromotionsApplied = wirelinePromotionsApplied.deleteWhitespace();
            List<String> promoIdTypeSet = wirelinePromotionsApplied.split(',');
            system.debug('==@@==promoIdTypeSet==='+promoIdTypeSet+'==@@wirelinePromotionsApplied=='+wirelinePromotionsApplied);
            for(String promo : promoIdTypeSet){
                promoIdSet.add(Id.valueOf(promo.split('_')[0]));
            }
            wirelinePromoRuleList = [SELECT Id,Name,Active__c,Configured_Fields_After__c,Configured_Fields_Before__c,Configured_Fields_Number__c,Discount_Percentage__c,Display_Promotion_End_Date__c,Do_Not_Run__c,End_Date__c,Expiry_Notification__c,Field_Inputs__c,Field_input_values_JSON__c,For_Testing__c,Hierarchy__c,Priority_Number__c,Priority__c,Promotion_Certified_By__c,Promotion_Certified__c,Promotion_Name__c,Promotion_Notification__c,Promo_Configurator_Lookup__c,Promo_Configured_Fields__c,Promo_Type__c,Rank__c,Rule_Description__c,Selected_Fields__c,Select_Fields_Json__c,Stackable__c,Start_Date__c,Test_SP__c,Promotion_Tag__c,Early_Stop_Date__c FROM Wireline_Promotion_Rules__c where id in: promoIdSet];
            if(siteQuoteJunctionId != null && wirelinePromoRuleList.size()>0){
                junctionPromoRulesListMap.put(String.valueOf(siteQuoteJunctionId),wirelinePromoRuleList);
                wirelinePromoHelper.calculatePromotions(junctionPromoRulesListMap);
            }
        }else{
            junctionPromoRulesListMap.put(String.valueOf(siteQuoteJunctionId),wirelinePromoRuleList);
            wirelinePromoHelper.calculatePromotions(junctionPromoRulesListMap);
        }    
        loadPromotionData(wirelinePromotionsApplied);                    
        isPricingDataAvailable = true;        
        initializeUIContentFromSchema();
        initializeData();                  
        Apttus_Config2__ProductConfiguration__c prodConfig = quoteHelper.retrieveExistingCartId(quoteId);
        readPricingStatusForAllLineItem(prodConfig);
        handlefilterSites();  
        isUBBinCart = iSHiCapInCart();
        
        list<Apttus_Config2__LineItem__c> lineItems = new list<Apttus_Config2__LineItem__c>();
        lineItems = [SELECT Id,Project_Id__c,UBBOveragePrice__c,Product_Code__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__ExtendedPrice__c,AT_T_Customer_Site__r.Id , Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__ListPrice__c,AdditionalDnsType__c,Port_Speed__c, MBC_Speed__c,Apttus_Config2__BasePrice__c,Apttus_Config2__AttributeValueId__r.VLANs_Logical_Channels__c, isPricingApplied__c, Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c,Apttus_Config2__AttributeValueId__r.Additional_DNS__c, 
        Apttus_Config2__AttributeValueId__r.VASA_Region__c,Apttus_Config2__AttributeValueId__r.Access_Type_AVPN__c,Apttus_Config2__AttributeValueId__r.Access_Type__c,Apttus_Config2__AttributeValueId__r.Managed_Router__c,Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c,Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c,Apttus_Config2__AttributeValueId__r.IP_Flex_Error__c, Apttus_Config2__AttributeValueId__r.IGLOO_Retrial_Failure_Count__c, Apttus_Config2__AttributeValueId__r.IGLOO_Call_Failure__c, Apttus_Config2__AttributeValueId__r.IGLOO_Speed_Unavailable__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=:cartId AND AT_T_Customer_Site__c =: selectedSiteId];
        boolean isSEOOR=false; 
        if((lineItems[0].Apttus_Config2__AttributeValueId__r.VASA_Region__c!=null && !lineItems[0].Apttus_Config2__AttributeValueId__r.VASA_Region__c.equalsIgnoreCase('In Region')) &&  (lineItems[0].Apttus_Config2__AttributeValueId__r.Access_Type_AVPN__c!=null && lineItems[0].Apttus_Config2__AttributeValueId__r.Access_Type_AVPN__c.equalsIgnoreCase('Switched Ethernet')) || (lineItems[0].Apttus_Config2__AttributeValueId__r.Access_Type__c!=null && lineItems[0].Apttus_Config2__AttributeValueId__r.Access_Type__c.equalsIgnoreCase('Switched Ethernet'))){
            isSEOOR=true;
        }
        
        List<AT_T_Customer_Site_Quote__c> jncSiteQuoteList=new List<AT_T_Customer_Site_Quote__c>();
        Set<String> expiredSites=IglooExpirationCheck(jncSiteQuoteList,true);
        for(QuoteProducts.cCustomerSite cs : ListCustomerSite){    
            if( cs.custSiteIns.Id == selectedSiteId ){                
                AT_T_Customer_Site_Quote__c juncSite = new AT_T_Customer_Site_Quote__c();
                juncSite = [select Igloo_Review_Required__c,Iglow_Response_Received_Date__c,Wireline_Promotion_Applied__c from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c =: selectedSiteId and AT_T_Quote__c =: quoteid];
                if(juncSite != null){
                    cs.isIglooReviewReq = juncSite.Igloo_Review_Required__c;
                    if(isSEOOR && juncSite.Iglow_Response_Received_Date__c!=null){
                        cs.isOORSESite=true;
                    }else{
                        cs.isOORSESite=false;
                    } 
                    if(expiredSites!=null && expiredSites.size()>0 && expiredSites.contains(cs.custSiteIns.Id)){
                        cs.OORSEExpired=true;cs.isOORSESite=false;showOORSEExpired=true;
                    }
                    else{
                        cs.OORSEExpired=false;showOORSEExpired=false;
                    }
                    cs.wirelinePromoApplied = juncSite.Wireline_Promotion_Applied__c;
                }
            }
        }
    }
    
    /*Method to execute logic when Accept button is clicked*/
    public void executeIglooSpeedAcceptedLogic(){
        listAttrVal.IGLOO_Old_Port_Speed__c = listAttrVal.IGLOO_Old_Access_Speed__c = listAttrVal.IGLOO_Old_Interface_Type__c = '';   
        listAttrVal.IGLOO_Port_Speed_Substituted__c = listAttrVal.IGLOO_Access_Speed_Substituted__c = listAttrVal.IGLOO_Interface_Type_Substituted__c = listAttrVal.IGLOO_Speed_Unavailable__c = false;     
        update listAttrVal;
        list<AT_T_Customer_Site_Quote__c> siteQuoteList = new list<AT_T_Customer_Site_Quote__c>();
        siteQuoteList = [select id, AT_T_Customer_Site__c, AT_T_Quote__c, Igloo_Review_Required__c from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c =: selectedSiteId and AT_T_Quote__c =: quoteId];
        if(siteQuoteList.size()>0){
            siteQuoteList[0].Igloo_Review_Required__c = false;
            update siteQuoteList;
        }
        fetchUpdatedPriceOnLoad();
        for(QuoteProducts.cCustomerSite cs : ListCustomerSite){    
            if( cs.custSiteIns.Id == selectedSiteId ){                
                AT_T_Customer_Site_Quote__c juncSite = new AT_T_Customer_Site_Quote__c();
                juncSite = [select Igloo_Review_Required__c from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c =: selectedSiteId and AT_T_Quote__c =: quoteid];
                if(juncSite != null){
                    cs.isIglooReviewReq = juncSite.Igloo_Review_Required__c;
                }
            }            
        }
    }
    
    /*Parsing port speed ase*/
    public void SplitPortSpeedASE(String portSpeedAse){
        String asePortSpeed = portSpeedAse;
        string singleQuote = '\'';
        if(asePortSpeed.remove(',').trim() == '100G'){
            enableASEBasic = false;
        }
        else{
            if(asePortSpeed!= null && asePortSpeed != ''){
                if(asePortSpeed.containsIgnoreCase('100M')){
                    BasePortSpeedAseList.add(singleQuote+'100 Mbps Port'+singleQuote);
                    PromoPortSpeedAseList.add(singleQuote+'100 Mbps Port'+singleQuote);
                }
                if(asePortSpeed.containsIgnoreCase('1G')){
                    BasePortSpeedAseList.add(singleQuote+'1 Gbps Port'+singleQuote);
                    PromoPortSpeedAseList.add(singleQuote+'1 Gbps Port'+singleQuote);
                }
                if(asePortSpeed.containsIgnoreCase('10G')){
                    BasePortSpeedAseList.add(singleQuote+'10 Gbps Port'+singleQuote);
                }
            }
        }
    }
    
    /*updateApplyAllFlag Logic*/  
    public void updateApplyAllFlag(){
        quoteObj.applyAllFlag__c = false;
        update quoteObj;      
    }
        
    public void isRateRefreshRequired(){
        try{
            List<AT_T_Customer_Site_Quote__c> jncSiteQuoteList = [SELECT Id,AT_T_Customer_Site__c,Is_Soft_Deleted__c, Iglow_Response_Received_Date__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c  =: quoteId];
            Set<String> allJunctionList=new Set<String>();
            eligibleRateRefresh=false;
            Set<String> expiredJunction=new Set<String>();
            Set<String> JunctionList=new Set<String>();
            Map<String,String> junctionSiteMap=new Map<String,String>();
            Map<String,String> expiredjunctionSiteMap=new Map<String,String>();
            String productCartId='';
            if(cartId!=null && cartId!=''){
                productCartId=cartId;
            }
            else{
                Apttus_Config2__ProductConfiguration__c prodConfig= [select id,Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c=: quoteId order by createddate DESC limit 1];
                productCartId=prodConfig.id;
            }
            
            for(AT_T_Customer_Site_Quote__c junction : jncSiteQuoteList){ 
                if(junction.Iglow_Response_Received_Date__c!=null && junction.Iglow_Response_Received_Date__c.daysBetween(system.now().date()) > 90 ){
                    expiredJunction.add(junction.AT_T_Customer_Site__c);
                    expiredjunctionSiteMap.put(junction.AT_T_Customer_Site__c,junction.id);
                }
                else if(junction.Iglow_Response_Received_Date__c!=null && junction.Iglow_Response_Received_Date__c.daysBetween(system.now().date()) < 91){
                    junctionSiteMap.put(junction.AT_T_Customer_Site__c,junction.id);
                    JunctionList.add(junction.id);
                }
                allJunctionList.add(junction.AT_T_Customer_Site__c);
            }
            Map<String,String> expiredLineItemSiteMap=new Map<String,String>();
            Map<String,String> LineItemSiteMap=new Map<String,String>();    
            List<Apttus_Config2__LineItem__c> lineItemList = [SELECT Id,Alternate_Access_IGLOO_Access_Price__c,Apttus_Config2__LineNumber__c, Apttus_Config2__AdjustedPrice__c,Apttus_Config2__ExtendedPrice__c,Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__BasePrice__c,Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c,AT_T_Customer_Site__r.id FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=: productCartId AND AT_T_Customer_Site__c IN : allJunctionList and isPricingApplied__c=true];
       
            Set<String> lineItemIDs=new Set<String>();
            if(lineItemList!=null && lineItemList.size()>0){
                for(Apttus_Config2__LineItem__c lineItem : lineItemList){ 
                    if(expiredjunctionSiteMap.get(lineItem.AT_T_Customer_Site__r.id)!=null){
                        expiredLineItemSiteMap.put(lineItem.AT_T_Customer_Site__r.id,lineItem.id);
                    }
                    else{
                        LineItemSiteMap.put(lineItem.AT_T_Customer_Site__r.id,lineItem.id);
                    }
                    lineItemNumberForRateRefresh.add(Integer.valueOf(lineItem.Apttus_Config2__LineNumber__c));      
                    lineItemIDs.add(lineItem.Apttus_Config2__AttributeValueId__c);
                }
            }
  
      
            if(lineItemIDs!=null && lineItemIDs.size()>0){
                List<Apttus_Config2__ProductAttributeValue__c> attributeValueList=[select id,VASA_Region__c,IGLOO_Port_Speed_Substituted__c,IGLOO_Access_Speed_Substituted__c,IGLOO_Interface_Type_Substituted__c,AT_T_Customer_Site__c,Access_Type_AVPN__c,Access_Type__c from Apttus_Config2__ProductAttributeValue__c where id IN : lineItemIDs];
                for(Apttus_Config2__ProductAttributeValue__c  attributeValue : attributeValueList){
                    if((attributeValue.VASA_Region__c!=null && !attributeValue.VASA_Region__c.equalsIgnoreCase('In Region')) &&  ((attributeValue.Access_Type_AVPN__c!=null && attributeValue.Access_Type_AVPN__c.equalsIgnoreCase('Switched Ethernet')) || (attributeValue.Access_Type__c!=null && attributeValue.Access_Type__c.equalsIgnoreCase('Switched Ethernet')))){ 
                        for(Apttus_Config2__LineItem__c lineItem : lineItemList){
                            if(attributeValue.id==lineItem.Apttus_Config2__AttributeValueId__c && expiredLineItemSiteMap.get(lineItem.AT_T_Customer_Site__r.id)!=null){
                                avForOOR.add(attributeValue.id);
                                eligibleRateRefresh=true;
                            }
                            else if(attributeValue.id==lineItem.Apttus_Config2__AttributeValueId__c && junctionSiteMap.get(lineItem.AT_T_Customer_Site__r.id)!=null){
                                avForInRegion.add(attributeValue.id);
                                eligibleRateRefresh=true;
                            }
                            else if(attributeValue.id==lineItem.Apttus_Config2__AttributeValueId__c && !JunctionList.contains(lineItem.AT_T_Customer_Site__r.id)){
                                avForOOR.add(attributeValue.id);
                                eligibleRateRefresh=true;
                            }
                        }     
                    }
                    else{
                        avForInRegion.add(attributeValue.id);
                        eligibleRateRefresh=true;
                    }
                }            
            }
            system.debug('avForInRegion '+avForInRegion+' and avForOOR '+avForOOR);        
        }
        catch(Exception e){
            System.debug('*******exception in isRateRefreshRequired *****' + e.getLineNumber()+''+e+'trace is :'+e.getStackTraceString());    
        }
    }
    
    /*Rate Refresh Logic*/
    public void performRateRefresh(){   
        try{
            if((avForInRegion!=null && avForInRegion.size()>0)||(avForOOR!=null && avForOOR.size()>0)){
                ID batchprocessid = database.executeBatch(new ApplyPricesForBulkSites(lineItemNumberForRateRefresh,cartId,false,avForOOR),1);
                Integer noOfSites=avForInRegion.size();
                Admin_Control__c adminControl = [SELECT id, Rate_Card_Offline_Threshold__c, Rate_Card_OOR_Threshold__c,Config_Offline_Threshold__c, OOR_Offline_Threshold__c,Config_Page_Time_Out_1__c, Config_Page_Time_Out_2__c,IglooSpeedBump__c FROM Admin_Control__c limit 1]; 
                String offlineCount = adminControl.Rate_Card_Offline_Threshold__c+'';
                String iglooOfflineCount = adminControl.Rate_Card_OOR_Threshold__c+'';
                List<Apttus_Proposal__Proposal__c> quoteProposalObj = new List<Apttus_Proposal__Proposal__c>();
                quoteProposalObj.add(proposalObject);
                if((offlineCount!=null && offlineCount!='' && noOfSites> Integer.valueof(offlineCount)) || (iglooOfflineCount!=null && iglooOfflineCount!='' && avForOOR.size() > Integer.valueOf(iglooOfflineCount))){  
                    quoteProposalObj.add(proposalObject);
                    if(quoteProposalObj!=null && quoteProposalObj.size()>0){
                        quoteProposalObj[0].Apttus_Proposal__Approval_Stage__c=BuyflowConstant.BULKSERVICE_AVAILABILITY_REQUESTED;
                        quoteProposalObj[0].Is_Offline_Config_Completed__c=false;
                        doBatchPolling=false;
                        eligibleRateRefresh=false;
                        isOfflineMode = true;
                    }  
                }
                else{
                    if(quoteProposalObj!=null && quoteProposalObj.size()>0){
                        quoteProposalObj[0].isRateRefreshBatchProcessing__c=true;
                    }    
                    isOfflineMode =false;
                    doBatchPolling=true;
                }
                update quoteProposalObj[0];                
            }
        }
        catch(Exception e){
            System.debug('*******exception in performRateRefresh *****' + e.getLineNumber()+''+e+'trace is :'+e.getStackTraceString());
        }    
    }
    
    /*Rate Refresh Status Check*/
    public void rateRefreshBatchStatus(){
        Pagereference redirectToConfig;
        try{
            //List<Apttus_Proposal__Proposal__c>  proposal= [SELECT Id,isRateRefreshBatchProcessing__c,Apttus_Proposal__Approval_Stage__c,Buyflow_Step__c,Rate_Card_Effective_Date__c,Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c FROM Apttus_Proposal__Proposal__c WHERE Id =: quoteId LIMIT 1];
            List<Apttus_Proposal__Proposal__c>  proposal = new List<Apttus_Proposal__Proposal__c>();
            proposal.add(proposalObject);
            if(proposal!=null && proposal.size()>0){
                doBatchPolling=proposal[0].isRateRefreshBatchProcessing__c;
            }
        }
        catch(Exception e){
            System.debug('*******exception in rateRefreshBatchStatus*****' + e.getLineNumber()+''+e+'trace is :'+e.getStackTraceString());
        }   
    } 
            
    /*Method to load Promotions on page load*/
    public void loadPromotionData(String wirelinePromotions){
        Boolean hiCapFlexSite = false;
        wirelinePromoMap = new map<String,list<Wireline_Promotion_Rules__c>>();
        system.debug('@@@cartId:'+cartId);
        system.debug('@@@selectedSiteId '+selectedSiteId);
        if(String.isNotBlank(cartId) && String.isNotBlank(selectedSiteId)){
            list<Apttus_Config2__LineItem__c> lineItems = new list<Apttus_Config2__LineItem__c>();
            lineItems = [SELECT Id,Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c,AT_T_Customer_Site__c,Apttus_Config2__ConfigurationId__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =:cartId and AT_T_Customer_Site__c =:selectedSiteId LIMIT 1];
            if(lineItems.size()>0 && lineItems[0].Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c == true){
                hiCapFlexSite = true;
            }   
            system.debug('@@@isHiCapFlex:'+isHiCapFlex); 
        }
        set<Id> promoIdSet = new set<Id>();      
        list<Wireline_Promo_Fields__c> promoFieldList = Wireline_Promo_Fields__c.getall().values();    
        if(String.isNotBlank(wirelinePromotions)){                     
            List<String> promoIdTypeSet = wirelinePromotions.split(','); 
            system.debug('promoIdTypeSet '+promoIdTypeSet);
            for(String promo : promoIdTypeSet){
                promoIdSet.add(Id.valueOf(promo.split('_')[0].trim()));
            }            
            system.debug('@@@promoIdSet: '+promoIdSet);
            
            list<Wireline_Promotion_Rules__c> wirelinePromoRules = new list<Wireline_Promotion_Rules__c>();            
            wirelinePromoRules = [select Id,Promotion_Name__c,Discount_Percentage__c,End_Date__c,Promo_Type__c,Field_Inputs__c,Expiry_Notification__c,Promotion_Notification__c,Rank__c,Display_Promotion_End_Date__c,Promotion_Tag__c,Early_Stop_Date__c from Wireline_Promotion_Rules__c where id in: promoIdSet and Promotion_Notification__c = true order by Promo_Type__c,Rank__c];
            system.debug('@@@wirelinePromoRules:'+wirelinePromoRules);
            for(Wireline_Promotion_Rules__c wpr: wirelinePromoRules){
                if('Port'.equalsIgnoreCase(wpr.Promo_Type__c)){
                    system.debug('@@@Port: '+wpr);
                    wpr.Promo_Type__c = hiCapFlexSite == true? 'Minimum Bandwidth Commitment (MBC)' : 'Port Speed';
                    populateWirelinePromoMap(wpr);
                }else if('Access'.equalsIgnoreCase(wpr.Promo_Type__c)){
                    wpr.Promo_Type__c = 'Access Speed';
                    system.debug('@@@Access: '+wpr);
                    populateWirelinePromoMap(wpr);
                }else if('Feature'.equalsIgnoreCase(wpr.Promo_Type__c)){
                    if((wpr.Field_Inputs__c.unescapeHtml4()).contains(':IPFLEX;') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';IPFLEX;') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';IPFLEX"') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':IPFLEX|') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';IPFLEX|') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':IPFLEX"')){
                        for(Wireline_Promo_Fields__c field : promoFieldList){
                            if(field.IPFlex_Field__c){
                                wpr.Promo_Type__c = field.Name;
                                system.debug('@@@IPFlex: '+wpr);
                                populateWirelinePromoMap(wpr);
                            }
                        }
                    }
                    if((wpr.Field_Inputs__c.unescapeHtml4()).contains(':CoS;') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';CoS;') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';CoS"') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':CoS|') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';CoS|') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':CoS"')){
                        system.debug('@@@CoS: '+wpr);
                        wpr.Promo_Type__c = 'Class of Service';
                        populateWirelinePromoMap(wpr);
                    }
                    if((wpr.Field_Inputs__c.unescapeHtml4()).contains(':VLAN;') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';VLAN;') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';VLAN"') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':VLAN|') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';VLAN|') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':VLAN"')){
                        system.debug('@@@VLAN: '+wpr);
                        wpr.Promo_Type__c = 'VLANs/ Logical Channels';
                        populateWirelinePromoMap(wpr);
                    }      
                    if((wpr.Field_Inputs__c.unescapeHtml4()).contains(':Primary DNS;') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';Primary DNS;') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';Primary DNS"') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':Primary DNS|') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(',Primary DNS|') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':Primary DNS"') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':Secondary DNS;') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';Secondary DNS;') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';Secondary DNS"') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':Secondary DNS|') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';Secondary DNS|') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':Secondary DNS"') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':Primary;') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';Primary;') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';Primary"') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':Primary|') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';Primary|') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':Primary"') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':Secondary;') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';Secondary;') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';Secondary"') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':Secondary|') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(';Secondary|') || (wpr.Field_Inputs__c.unescapeHtml4()).contains(':Secondary"')){
                        system.debug('@@@DNS: '+wpr);
                        wpr.Promo_Type__c = 'Additional DNS';
                        populateWirelinePromoMap(wpr);
                    }  
                }                
            }  
        }
        for(Wireline_Promo_Fields__c field : promoFieldList){
            if(!wirelinePromoMap.keyset().contains(field.Name)){
                system.debug('@@@field.Name: '+field.Name);
                list<Wireline_Promotion_Rules__c> promoList = new list<Wireline_Promotion_Rules__c>();
                wirelinePromoMap.put(field.Name,promoList);
            }
        }            
        system.debug('@@@wirelinePromoMap Final: '+wirelinePromoMap);
    } 
    
    /*Method to populate Wireline Promotion Map*/
    public void populateWirelinePromoMap(Wireline_Promotion_Rules__c wpr){
        system.debug('@@@populateWirelinePromoMap : '+wpr);
        list<Wireline_Promotion_Rules__c> wirelinePromoList;
        if(wirelinePromoMap != null && wirelinePromoMap.keyset().contains(wpr.Promo_Type__c) && wirelinePromoMap.get(wpr.Promo_Type__c) != null){                        
            system.debug('@@@wpr if: '+wpr);
            wirelinePromoList = wirelinePromoMap.get(wpr.Promo_Type__c);
            wirelinePromoList.add(wpr);
            wirelinePromoMap.put(wpr.Promo_Type__c,wirelinePromoList);
            system.debug('@@@wirelinePromoMap: '+wirelinePromoMap);
        }else{
            system.debug('@@@wpr else: '+wpr);
            wirelinePromoList = new list<Wireline_Promotion_Rules__c>();
            wirelinePromoList.add(wpr);
            wirelinePromoMap.put(wpr.Promo_Type__c, wirelinePromoList);
            system.debug('@@@wirelinePromoMap: '+wirelinePromoMap);
        } 
    }   
    
    public PageReference discardChanges(){
        system.debug('---quoteId---');
        PageReference reconfigurePage;
        try{
            if(String.isBlank(quoteId)){
                quoteId = apexpages.currentpage().getparameters().get('quoteId');
            }
            DiscardFunctionalityHandler dFH = new DiscardFunctionalityHandler();
            dFH.discardNewChangesOnQuote(quoteId);
            reconfigurePage = system.page.dealreg;
            reconfigurePage.getParameters().put('quoteId', quoteId);
            //reconfigurePage.getParameters().put('vmode','B');
            reconfigurePage.getParameters().put('mode', 'regdeal');
        }catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
        return reconfigurePage;
    }
    
    /*Method to callDPERateRefresh*/
    public PageReference callDPERateRefresh(){
        Pagereference pg = page.PortalDesign_Buyflow;
        pg.getparameters().put('quoteid',quoteId);
        pg.getparameters().put('mode','confsites');
        pg.setredirect(true);
        if(quoteId != null){
            list<Apttus_Proposal__Proposal__c> proposalList = new list<Apttus_Proposal__Proposal__c>();
            proposalList = [select id,name,Apttus_Proposal__Approval_Stage__c,Apttus_Proposal__Opportunity__c, QuoteExpirationDate__c,Rate_Card_Effective_Date__c,SiteRemovalCheck__c from Apttus_Proposal__Proposal__c where id = :quoteId];               
            proposalList[0].Rate_Card_Effective_Date__c = null;
            proposalList[0].Apttus_QPConfig__PriceListId__c = null;
            proposalList[0].SiteRemovalCheck__c = true;
            try{
                update proposalList;
                List<Apttus_Config2__ProductConfiguration__c> prodConfigList = new List<Apttus_Config2__ProductConfiguration__c>();
                prodConfigList = [select id,Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c=: proposalList[0].Id order by createddate DESC limit 1];
                if(!prodConfigList.isEmpty()){
                    List<Apttus_Config2__LineItem__c> lineItemUpdateList = new List<Apttus_Config2__LineItem__c>();
                    List<Apttus_Config2__LineItem__c> lineItemList = new List<Apttus_Config2__LineItem__c>();
                    lineItemList = [SELECT Id,isPricingApplied__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=: prodConfigList[0].id];                
                    if(!lineItemList.isEmpty()){
                        for(Apttus_Config2__LineItem__c lineItem : lineItemList){
                            lineItem.isPricingApplied__c = false;
                            lineItemUpdateList.add(lineItem);
                        }
                        update lineItemUpdateList;
                    }               
                }                               
            }
            catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                return null;
            }     
        }
        return pg;
    }
}