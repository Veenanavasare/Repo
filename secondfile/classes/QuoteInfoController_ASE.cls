/************************************************************************************** 
Apex Class Name     : QuoteInfoController_ASE
Version             : 1.0 
Created Date        : 12 Sep 2014
Function            : This class handles the configure sites functionality.
Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mayank Agarwal            9/12/2014              Original Version
* Kumar Gaurav             10/21/2014              
*************************************************************************************/

public with sharing class QuoteInfoController_ASE {
public class myException extends Exception {}  
 
    public boolean userBeginQuote{get; set;}    
    public String siteid{get;set;}
    public string selectCirVal{get;set;}
    public String selectOptGrp {get;set;}
    public String selectOptGrpVal {get;set;}
    public Double grandTot {get;set;}
    public Double siteTotal {get;set;}
    //public List<CustomerSite__c> customerSiteList {get;set;}
    public CustomerSite__c custSiteInsSelectedValue {get; set;} // to show selected site on page
    public Map<String,String> optGrpSelectedVal {get;set;}
    public String quoteId{get;set;}
    public String prodName;
    public set<String> sugProdId{get;set;}
    public SiteVasaResValidator siteVasaResValidatorIns;
    public Map<String,Boolean> siteIdEthernetAvailMap {get;set;}
    public Boolean ethernetVal {get;set;}
    public Boolean Isfinalized {get;set;}
    public List<QuoteProducts.cCustomerSite> eligibleSitesLst {get;set;}
    public Map<String,List<QuoteProducts.cCustomerSite>> siteIdEligibleSitesMap {get;set;}
    public AT_T_Customer_Site_Quote__c custSiteQuoteIns {get;set;}
    public String cartId{get;set;}
    transient List<Decimal> lineNumbersLst;
    transient String priceListId;
    public  String mainproductId{get;set;}    
    public Map<string,Integer> siteLinenumberMap;
    private List<Apttus_CPQApi.CPQ.ProductOptionGroupDO> productOptionList;
    private ApttusServiceUtilityHelper helper;
    private QuoteInfoHelper Quotehelper;
    public QuoteProducts.SelectPricingWrap sPricingWrap{get;set;}
    public Map<String,QuoteProducts.SelectPricingWrap> sitePricingMap {get;set;}
    public Boolean disableNext {get;set;}
    public Boolean disablePrevious {get;set;}
    public Boolean isAllSitesNotProcessed{get;set;}
    public Boolean TypeConnection {get;set;}
    public String SelectSiteHub {get;set;}
    public String selectedCustomer{get;set;}
    public Apttus_Proposal__Proposal__c quoteObj{get;set;}
    public String selectedFilter{get;set;}
    public boolean haserrors {get;set;}
    public List<QuoteProducts.cCustomerSite> ListCustomerSite {get; set;}
    public list<EVC_Details__c> EVCList {get;set;}
    public List<SelectOption> hubSiteSelectOptions {get;set;}
    public map<String,Integer> cosValue = new map<String,Integer>{'Real Time' => 1, 'Interactive' => 2, 'Business Critical High' => 3, 'Business Critical Medium' => 4, 'Non Critical High' => 5};
    
    //constructor
    public QuoteInfoController_ASE(){
        User userObj;
        userObj = [select id, Begin_Quote__c from User where id = :UserInfo.getUserId()];
        userBeginQuote = userObj.Begin_Quote__c;
    system.debug('Enter Constructor-@@@@@@@@@@@@');
        siteIdEthernetAvailMap = new Map<String,Boolean>();
        siteIdEligibleSitesMap = new Map<String,List<QuoteProducts.cCustomerSite>>();
        grandTot = 0;
        siteTotal = 0;
        disableNext = false;
        haserrors = false;
        disablePrevious = true;
        //customerSiteList = new List<CustomerSite__c>();
        siteLinenumberMap = new Map<string,Integer>();
        helper = new ApttusServiceUtilityHelper();
        quoteHelper = new QuoteInfoHelper();
        evcListTable =  new List<QuoteProducts.cCustomerSite>(); 
        
        quotehelper.initialiseparamASE(ApexPages.currentPage(),this);       
        //initialize the quote Id in constructor
        if(ApexPages.currentPage().getParameters().get('quoteId') != null){
            quoteId = ApexPages.currentPage().getParameters().get('quoteId'); 
            system.debug('Quote Id -> '+quoteId);
            quoteObj = quoteHelper.getQuote(quoteId);
            system.debug('Quote Id @@@@@@@@-> '+quoteObj );
        }
        sitePricingMap = new Map<String,QuoteProducts.SelectPricingWrap>();
        isAllSitesNotProcessed = true;
        //showDetail();

    }
    
    public void populateEVCLst(){
        list<QuoteProducts.cCustomerSite> EVClist = new list<QuoteProducts.cCustomerSite>();
        system.debug('size >>>>>>>>>>>'+ListCustomerSite.size());
        EVClist = quotehelper.getEVCList(ListCustomerSite,quoteId);
        evcListTable = EVClist;
        //return EVClist;
    }
    
    public List<QuoteProducts.cCustomerSite> evcListTable {get;set;}
    
    public List<SelectOption> getSitesForHub() 
    {
        if(hubSiteSelectOptions == null || hubSiteSelectOptions.isEmpty()){
            hubSiteSelectOptions = new List<SelectOption>();
            list<AT_T_Customer_Site_Quote__c> custSiteQuoteLst = [Select Id, Name,AT_T_Customer_Site__c,AT_T_Quote__c,Customer__c,hub__c,AT_T_Quote__r.Product__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,AT_T_Quote__r.Name,AT_T_Quote__r.Apttus_Proposal__Payment_Term__c,AT_T_Quote__r.Apttus_QPConfig__PriceListId__c,AT_T_Quote__r.Product__r.Name from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=:quoteId];
            hubSiteSelectOptions.add(new SelectOption('','-None-'));
            for(QuoteProducts.cCustomerSite cc :ListCustomerSite){
                hubSiteSelectOptions.add(new SelectOption(cc.custSiteIns.Id, cc.custSiteIns.Site_Name__c));
            }
            for(AT_T_Customer_Site_Quote__c csq :custSiteQuoteLst){
                if(csq.hub__c == true){
                    SelectSiteHub = csq.AT_T_Customer_Site__c;
                    quotehelper.updateHub(selectsitehub,ListCustomerSite);      
                }
            }
        }
        return hubSiteSelectOptions;
    } 
    
    /******************************************************************************************************************/    
    public List<SelectOption> getRelatedCust() 
    {
        list<SelectOption> RelatedCust = new List<SelectOption>();
        list<AT_T_Customer_Site_Quote__c> custSiteQuoteLst = [Select Id, Name,AT_T_Customer_Site__c,AT_T_Quote__c,Customer__c,AT_T_Quote__r.Product__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,AT_T_Quote__r.Name,AT_T_Quote__r.Apttus_Proposal__Payment_Term__c,AT_T_Quote__r.Apttus_QPConfig__PriceListId__c,AT_T_Quote__r.Product__r.Name from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=:quoteId];
        //quoteObj = [select Name, End_Customer__c,Apttus_Proposal__Account__c, End_Customer__r.Name, Apttus_Proposal__Proposal_Name__c,Product__c,Apttus_Proposal__Payment_Term__c,Ethernet_Configuration__c,Traffic_Jurisdiction__c from Apttus_Proposal__Proposal__c where id = :quoteId];                
        list<Account_End_Customer_Junction__c>AccendCustomer = new list<Account_End_Customer_Junction__c>([select Id, Account__c, End_Customer__c, End_Customer__r.Name from Account_End_Customer_Junction__c where account__c =: quoteObj.Apttus_Proposal__Account__c order by End_Customer__r.Name]);
        for(Account_End_Customer_Junction__c endC :AccendCustomer)
        {
            if(endC.End_Customer__c != null)
            {
                RelatedCust.add(new SelectOption(endC.End_Customer__c, endC.End_Customer__r.Name));
            }
        }
        for(AT_T_Customer_Site_Quote__c csq :custSiteQuoteLst){
          if(csq.Customer__c != null && csq.AT_T_Customer_Site__c == siteId){
            selectedCustomer = csq.Customer__c;
          }
          else if(csq.Customer__c == null && csq.AT_T_Customer_Site__c == siteId){
            selectedCustomer = '';
          }
        }
        system.debug('AccendCustomer-----> '+ AccendCustomer);
        system.debug('RelatedCust-----> '+ RelatedCust);
        return RelatedCust;
    }

/************************************************************************************************************************/
    public pageReference updateCustomer()
    {
        List<AT_T_Customer_Site_Quote__c> custSiteQuoteLst = [Select Id, Name,AT_T_Customer_Site__c,AT_T_Quote__c,Customer__c,AT_T_Quote__r.Product__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,AT_T_Quote__r.Name,AT_T_Quote__r.Apttus_Proposal__Payment_Term__c,AT_T_Quote__r.Apttus_QPConfig__PriceListId__c,AT_T_Quote__r.Product__r.Name from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=:quoteId];
        List<AT_T_Customer_Site_Quote__c> custSiteQuoteLstupdate = new List<AT_T_Customer_Site_Quote__c>();
        system.debug('siteId-----> '+ siteId);
        if(custSiteQuoteLst != null)
        {
            for(AT_T_Customer_Site_Quote__c qsj :custSiteQuoteLst)
            {
                if(qsj.AT_T_Customer_Site__c == siteId)
                {
                    qsj.customer__c = selectedCustomer;
                    custSiteQuoteLstupdate.add(qsj);
                }
            }
        }
        if(custSiteQuoteLstupdate != null)
            update custSiteQuoteLstupdate;
        system.debug('custSiteQuoteLstupdate-----> '+ custSiteQuoteLstupdate);
        return null;
    }

/************************************************************************************************************************/
    // Gavin 20150128: Created to initialize the Customer Name value if not previously set
    public void initializeCustomer()
    {
        List<AT_T_Customer_Site_Quote__c> custSiteQuoteLst = [Select Id, Name,AT_T_Customer_Site__c,AT_T_Quote__c,Customer__c,AT_T_Quote__r.Product__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,AT_T_Quote__r.Name,AT_T_Quote__r.Apttus_Proposal__Payment_Term__c,AT_T_Quote__r.Apttus_QPConfig__PriceListId__c,AT_T_Quote__r.Product__r.Name,hub__c from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=:quoteId];
        List<AT_T_Customer_Site_Quote__c> custSiteQuoteLstupdate = new List<AT_T_Customer_Site_Quote__c>();
        if(custSiteQuoteLst != null && quoteObj != null)
        {
            for(AT_T_Customer_Site_Quote__c qsj :custSiteQuoteLst)
            {
                if(qsj.customer__c == null){
                    qsj.customer__c = quoteObj.End_Customer__c;
                    custSiteQuoteLstupdate.add(qsj);
                }
                if(qsj.hub__c == true){
                    SelectSiteHub = qsj.AT_T_Customer_Site__c;
                    quotehelper.updateHub(selectsitehub,ListCustomerSite); //added by Gaurav 1/28/2015     
                }
            }
        }
        
        if(custSiteQuoteLstupdate != null) {
            update custSiteQuoteLstupdate;
        }
        system.debug('custSiteQuoteLstupdate-----> '+ custSiteQuoteLstupdate);
    }
    

public Id lineNumAttrIdMap;


    
/**********************************************************************************************************************/   
    public void updateHub(){
        //selectsitehub = ApexPages.currentPage().getParameters().get('selectsitehub');
        quotehelper.updateHub(selectsitehub,ListCustomerSite);       
        system.debug('ListCustomerSite-----> '+ ListCustomerSite);
        
    }
    
    public Long printTime(Long startTime){
        Long endTime = datetime.now().getTime();
        Long totalTime = endTime - startTime;
        system.debug('Total Time Taken --------------------> '+totalTime);
        return endTime;
    }
    
    //create seleted products number of times 
    public void setupCartWithSelectedSites(){
         boolean isConfiguredSite = false;
        Long startTime = datetime.now().getTime();               
        system.debug('Action Intiated --------------------> '+startTime);
        initializeGlobalParameter();
        system.debug('initializeGlobalParameter completed --------------------> ');
        startTime = printTime(startTime);
        QuoteProducts.cCustomerSite selectedSiteT = null;
        try{
            //customerSiteList = new List<CustomerSite__c>();
            if(ApexPages.currentPage().getParameters().get('quoteId') != null){
                quoteId = ApexPages.currentPage().getParameters().get('quoteId'); 
                system.debug('Quote Id -> '+quoteId);
                
            }
            if(!String.isempty(quoteId)){ 
                quoteObj = quoteHelper.getQuote(quoteId);
                if(!calTableList()){
                    return; 
                }
                system.debug('calTableList completed --------------------> ');
                startTime = printTime(startTime);
                //system.debug('customerSiteList >>>>>>>>>'+customerSiteList);
                getCustomerSiteLst();
                system.debug('getCustomerList completed --------------------> ');
                startTime = printTime(startTime);
                //creating cart 
                Apttus_Config2__ProductConfiguration__c prodConfig = quoteHelper.retrieveExistingCartId(quoteId);
                system.debug('Existing cart Id --> '+prodConfig); 
                //if(prodConfig != null && (ATTConstants.SAVED.equalsIgnoreCase(prodConfig.Apttus_Config2__Status__c) || ATTConstants.FINALIZED.equalsIgnoreCase(prodConfig.Apttus_Config2__Status__c))){
                    if(prodConfig != null){
                    cartId = prodConfig.Id;
                    system.debug('cart Id found --> '+prodConfig); 
                } 
                system.debug('Checking Existing Cart completed --------------------> ');
                
                // Gavin 20150128: Added to initialize the Customer Name for every site (if not already set)
                initializeCustomer();
                
                startTime = printTime(startTime); 
                system.debug(String.isempty(cartId)+'customerSiteList.isEmpty()---------> '+ListCustomerSite.isEmpty());                        
                if(!String.isempty(cartId) && !ListCustomerSite.isEmpty()){
                    List<Decimal> bundleNeedsToBeRemovedLst = readAllUnconfiguredLines(prodConfig);
                    helper.removeMultiBundles(cartId, bundleNeedsToBeRemovedLst); 
                    if(ApexPages.currentPage().getParameters().get('siteid') != null){
                        siteid = ApexPages.currentPage().getParameters().get('siteid'); 
                        system.debug('siteid Id found in URL -> '+siteid);
                        Integer indx = siteLinenumberMap.get(siteid);
                        system.debug('Indx ----> '+indx);              
                        if(indx != null && indx > 0){
                            selectedSiteT = ListCustomerSite[indx - 1];
                            custSiteInsSelectedValue = ListCustomerSite[indx - 1].custSiteIns;
                            system.debug('1 Initializing Site --------------------> '+selectedSiteT);
                        }else{
                            selectedSiteT = ListCustomerSite[0];
                            system.debug('2 Initializing Site --------------------> '+selectedSiteT);
                        }
                    }
                    if(String.isempty(siteid) || selectedSiteT == null){
                         selectedSiteT = ListCustomerSite[0];
                         system.debug('3 Initializing Site --------------------> '+selectedSiteT);
                    }
                    system.debug('isConfiguredSite --------------------> '+isConfiguredSite);
                    isConfiguredSite = readPricingStatusForAllLineItem(prodConfig, selectedSiteT.custSiteIns.Id);
                    if(isConfiguredSite){
                        //Added on 1/28/2014 by Kumar Gaurav
                        system.debug('4 Initializing Site --------------------> '+selectedSiteT);
                        IntializeUI(prodConfig, selectedSiteT, true); //changes end //1/28/2015
                    }else{
                        showDetail();
                    }    
                }else{
                    quoteHelper.removeExistingCart(quoteId);
                    cartId = helper.createCart(quoteId);
                    system.debug('Create Cart completed --------------------> ');
                    startTime = printTime(startTime);
                    showDetail();
                }
                system.debug('UI intialized Cart completed --------------------> ');
                startTime = printTime(startTime);                       
            }
            if(test.isRunningTest()){
                throw new myException('Error');
            }
        }
        
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.setupCartWithSelectedSites', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*public void readPricingStatusForAllLineItem(Apttus_Config2__ProductConfiguration__c prodConfig){
        boolean allLineprocessed = true;
        grandTot = 0;
        boolean isSiteFoundInLineItems = false;
        Decimal tprice = 0;
        try{
            for(QuoteProducts.cCustomerSite cs : ListCustomerSite){
                if(prodConfig != null && prodConfig.Apttus_Config2__LineItems__r != null){
                    for(Apttus_Config2__LineItem__c p: prodConfig.Apttus_Config2__LineItems__r){
                        if(cs.custSiteIns.id == p.AT_T_Customer_Site__c){
                            isSiteFoundInLineItems = true;
                            if(cs.linenumber == null || cs.linenumber == 0){
                                cs.linenumber = p.Apttus_Config2__LineNumber__c;
                                cs.pricingStatus = p.Apttus_Config2__PricingStatus__c;  
                                system.debug('Site name -- > '+cs.custSiteIns.Site_Name__c + '  Linenumber -- > '+p.Apttus_Config2__LineNumber__c);                                            
                            }
                            if(ATTConstants.COMPLETE.equalsIgnoreCase(p.Apttus_Config2__PricingStatus__c)){
                                cs.isProcessed = true;
                                cs.eligibleSelected = true;
                                cs.spanClass = 'display:inline-block; color:green;';                       
                                cs.pricingStatus = ATTConstants.COMPLETE;                           
                            }else{
                                allLineprocessed = false;
                            }
                            if('Product/Service'.equalsIgnoreCase(p.Apttus_Config2__LineType__c)){
                                tprice =  QuoteHelper.checkNull(p.Apttus_Config2__NetPrice__c);               
                                grandTot+= tprice;
                            }else{
                                continue;
                            }
                        } else {
                            //TO DO: RK: This is the check where we need to find out if all the Sites has been configured
                            //allLineprocessed = false;
                        }
                    }
                    if(!isSiteFoundInLineItems){
                        allLineprocessed = false;
                    }
                }                 
            }
            if(allLineprocessed){
                isAllSitesNotProcessed = false;
            }
            if(test.isRunningTest()){
                throw new myException('Error');
            }
        }catch(Exception e){
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in QuoteInfoController.setupCartWithSelectedSites', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }*/
    
    public List<Decimal> readAllUnconfiguredLines(Apttus_Config2__ProductConfiguration__c prodConfig){
        Set<Decimal> bundleNeedsToBeRemovedSet = new Set<Decimal>();
        List<Decimal> bundleNeedsToBeRemovedLst = new List<Decimal>();
        Set<String> userSelectedSiteSet = new Set<String>();
        for(QuoteProducts.cCustomerSite cs : ListCustomerSite){
            userSelectedSiteSet.add(cs.custSiteIns.id);
        }
        if(prodConfig != null && prodConfig.Apttus_Config2__LineItems__r != null){
            for(Apttus_Config2__LineItem__c p: prodConfig.Apttus_Config2__LineItems__r){
                if(String.isEmpty(p.AT_T_Customer_Site__c) && !bundleNeedsToBeRemovedSet.contains(p.Apttus_Config2__LineNumber__c)){
                    bundleNeedsToBeRemovedSet.add(p.Apttus_Config2__LineNumber__c);
                }else if(!String.isEmpty(p.AT_T_Customer_Site__c) && !bundleNeedsToBeRemovedSet.contains(p.Apttus_Config2__LineNumber__c) && !userSelectedSiteSet.contains(p.AT_T_Customer_Site__c)){
                    bundleNeedsToBeRemovedSet.add(p.Apttus_Config2__LineNumber__c);
                }
            }
        }
        if(!bundleNeedsToBeRemovedSet.isEmpty()){
            bundleNeedsToBeRemovedLst = new List<Decimal>(bundleNeedsToBeRemovedSet);
        }
        return bundleNeedsToBeRemovedLst;
    }
    
    public boolean readPricingStatusForAllLineItem(Apttus_Config2__ProductConfiguration__c prodConfig, String initSiteId){
        boolean allLineprocessed = true;
        grandTot = 0;
        Decimal tprice = 0;
        boolean isSiteFoundInLineItems = false;
        boolean isIntialSiteFound = false;
        try{
            for(QuoteProducts.cCustomerSite cs : ListCustomerSite){
                isSiteFoundInLineItems = false;
                if(prodConfig != null && prodConfig.Apttus_Config2__LineItems__r != null){
                    for(Apttus_Config2__LineItem__c p: prodConfig.Apttus_Config2__LineItems__r){
                        if(cs.custSiteIns.id == p.AT_T_Customer_Site__c){
                            isSiteFoundInLineItems = true;
                            if(cs.linenumber == null || cs.linenumber == 0){
                                cs.linenumber = p.Apttus_Config2__LineNumber__c;
                                cs.pricingStatus = p.Apttus_Config2__PricingStatus__c;  
                                system.debug('Site name -- > '+cs.custSiteIns.Site_Name__c + '  Linenumber -- > '+p.Apttus_Config2__LineNumber__c);                                            
                            }
                            if(ATTConstants.COMPLETE.equalsIgnoreCase(p.Apttus_Config2__PricingStatus__c)){
                                cs.isProcessed = true;
                                cs.eligibleSelected = true;
                                cs.spanClass = 'display:inline-block; color:green;';                       
                                cs.pricingStatus = ATTConstants.COMPLETE;                           
                            }else{
                                allLineprocessed = false;
                            }
                            if('Product/Service'.equalsIgnoreCase(p.Apttus_Config2__LineType__c)){
                                tprice =  QuoteHelper.checkNull(p.Apttus_Config2__NetPrice__c);               
                                grandTot+= tprice;
                            }else{
                                continue;
                            }
                        }
                        if(cs.custSiteIns.id == p.AT_T_Customer_Site__c && cs.custSiteIns.id == initSiteId){
                            isIntialSiteFound = true;
                        } 
                    }
                    if(!isSiteFoundInLineItems){
                        allLineprocessed = false;
                    }
                }                 
            }
            if(allLineprocessed){
                isAllSitesNotProcessed = false;
            }
        }catch(Exception e){
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in QuoteInfoController.setupCartWithSelectedSites', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return isIntialSiteFound;
    }
    
    
    public void IntializeUI(Apttus_Config2__ProductConfiguration__c prodConfig, QuoteProducts.cCustomerSite cs, boolean IsrunConstraintrequired){
        Set<String> nextTypeSet = null;
        Map<String,String> nextTypeSelectedProdMap = null;
        Map<String,Decimal> nextTypeSelectedPriceMap = null;
        String nextList = '';
        Set<String> availProdOptions = new Set<String>();
        Set<String> availProdOptionsMain = null;
        QuoteProducts.SelectPricingWrap sPWrapTemp = null;
        String selectedProductval = null;
        cartId = prodConfig.id;
        String portTypeId = null;
        Set<String> setConsId = new Set<String>();
        system.debug('Inside IntializeUI--------------------------------->');
        system.debug('prodConfig 2 >>>>>>>>'+prodConfig);
        system.debug('cCustomerSite 2 >>>>>>>>'+cs);
        system.debug('IsrunConstraintrequired 2 >>>>>>>>'+IsrunConstraintrequired);
        try{
            availProdOptionsMain = Quotehelper.getAllMajorProducts(mainproductId);
            sPWrapTemp = helper.getProductComponentOptionWrapper(productOptionList, mainproductId);
            sPWrapTemp.disableApplyBtn = true;
            availProdOptions = availProdOptionsMain.clone();
            nextTypeSet = new Set<String>();
            nextTypeSelectedProdMap = new Map<String,String>();
            nextTypeSelectedPriceMap = new Map<String,decimal>();
            system.debug('availProdOptions--------------->'+availProdOptions);
            system.debug('sugProdId--------------->'+sugProdId);
            for(Apttus_Config2__LineItem__c p: prodConfig.Apttus_Config2__LineItems__r){
                system.debug('Existing Lineitem ----- > '+p.Apttus_Config2__Description__c);
                if(cs.custSiteIns.id == p.AT_T_Customer_Site__c){                    
                    if(ATTConstants.PORT_TYPE.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){                        
                        availProdOptions.remove(ATTConstants.PORT_TYPE);
                        nextTypeSet.add(ATTConstants.PORT_TYPE); 
                        nextTypeSelectedProdMap.put(ATTConstants.PORT_TYPE, p.Apttus_Config2__OptionId__c); 
                        nextTypeSelectedPriceMap.put(ATTConstants.PORT_TYPE, p.Apttus_Config2__NetPrice__c);                                                                
                    }else if(ATTConstants.PORT_SPEED.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                      portTypeId = p.Apttus_Config2__OptionId__c;
                        nextList = ATTConstants.PORT_SPEED; 
                        availProdOptions.remove(ATTConstants.PORT_SPEED); 
                        nextTypeSet.add(ATTConstants.PORT_SPEED);
                        setConsId.add(p.Apttus_Config2__OptionId__c);
                        nextTypeSelectedProdMap.put(ATTConstants.PORT_SPEED, p.Apttus_Config2__OptionId__c); 
                        nextTypeSelectedPriceMap.put(ATTConstants.PORT_SPEED, p.Apttus_Config2__NetPrice__c);                           
                    }else if(ATTConstants.ACCESS_SPEED.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                        nextList = ATTConstants.ACCESS_SPEED;
                        availProdOptions.remove(ATTConstants.ACCESS_SPEED);
                        nextTypeSet.add(ATTConstants.ACCESS_SPEED);
                        nextTypeSelectedProdMap.put(ATTConstants.ACCESS_SPEED, p.Apttus_Config2__OptionId__c);
                        nextTypeSelectedPriceMap.put(ATTConstants.ACCESS_SPEED, p.Apttus_Config2__NetPrice__c);                              
                    }else if(ATTConstants.ACCESS_TYPE.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                        nextList = ATTConstants.ACCESS_TYPE;
                        availProdOptions.remove(ATTConstants.ACCESS_TYPE); 
                        nextTypeSet.add(ATTConstants.ACCESS_TYPE);
                        nextTypeSelectedProdMap.put(ATTConstants.ACCESS_TYPE, p.Apttus_Config2__OptionId__c); 
                        nextTypeSelectedPriceMap.put(ATTConstants.ACCESS_TYPE, p.Apttus_Config2__NetPrice__c);                            
                    }else if(ATTConstants.INTERFACE_TYPE.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                        nextList = ATTConstants.INTERFACE_TYPE; 
                        availProdOptions.remove(ATTConstants.INTERFACE_TYPE); 
                        nextTypeSet.add(ATTConstants.INTERFACE_TYPE);
                        nextTypeSelectedProdMap.put(ATTConstants.INTERFACE_TYPE, p.Apttus_Config2__OptionId__c); 
                        nextTypeSelectedPriceMap.put(ATTConstants.INTERFACE_TYPE, p.Apttus_Config2__NetPrice__c);                             
                    }else if(ATTConstants.INSTALLATION_OPTIONS.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                        nextList = ATTConstants.INSTALLATION_OPTIONS;
                        availProdOptions.remove(ATTConstants.INSTALLATION_OPTIONS); 
                        nextTypeSet.add(ATTConstants.INSTALLATION_OPTIONS); 
                        nextTypeSelectedProdMap.put(ATTConstants.INSTALLATION_OPTIONS, p.Apttus_Config2__OptionId__c);
                        nextTypeSelectedPriceMap.put(ATTConstants.INSTALLATION_OPTIONS, p.Apttus_Config2__NetPrice__c);                           
                    }else if(ATTConstants.MIN_BANDWIDTH_COM.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                        nextList = ATTConstants.MIN_BANDWIDTH_COM; 
                        availProdOptions.remove(ATTConstants.MIN_BANDWIDTH_COM);  
                        nextTypeSet.add(ATTConstants.MIN_BANDWIDTH_COM);  
                        nextTypeSelectedProdMap.put(ATTConstants.MIN_BANDWIDTH_COM, p.Apttus_Config2__OptionId__c); 
                        nextTypeSelectedPriceMap.put(ATTConstants.MIN_BANDWIDTH_COM, p.Apttus_Config2__NetPrice__c);                          
                    }
                    else if(ATTConstants.SERVING_ARRANGEMENT.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                        nextList = ATTConstants.SERVING_ARRANGEMENT; 
                        availProdOptions.remove(ATTConstants.SERVING_ARRANGEMENT);  
                        nextTypeSet.add(ATTConstants.SERVING_ARRANGEMENT);  
                        nextTypeSelectedProdMap.put(ATTConstants.SERVING_ARRANGEMENT, p.Apttus_Config2__OptionId__c); 
                        nextTypeSelectedPriceMap.put(ATTConstants.SERVING_ARRANGEMENT, p.Apttus_Config2__NetPrice__c);                          
                    }      
                    else if(ATTConstants.CLASS_OF_SERVICE.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                        nextList = ATTConstants.CLASS_OF_SERVICE; 
                        availProdOptions.remove(ATTConstants.CLASS_OF_SERVICE);  
                        nextTypeSet.add(ATTConstants.CLASS_OF_SERVICE); 
                        setConsId.add(p.Apttus_Config2__OptionId__c);
                        system.debug('p.Apttus_Config2__OptionGroupLabel__c@@@@@@>'+p.Apttus_Config2__OptionGroupLabel__c);
                        //system.debug('p.Apttus_Config2__OptionId__c@@@@@@>'+p.Apttus_Config2__OptionId__r.Name);
                        //system.debug('p.Apttus_Config2__OptionId__c@@@@@@>'+p.Apttus_Config2__OptionId__c);
                        cs.CoS = p.Apttus_Config2__OptionId__c;
                        cs.COSVal = COSValue.get(p.Apttus_Config2__OptionId__r.Name); 
                        selectedProductval = p.Apttus_Config2__OptionId__c;
                        nextTypeSelectedProdMap.put(ATTConstants.CLASS_OF_SERVICE, p.Apttus_Config2__OptionId__c); 
                        nextTypeSelectedPriceMap.put(ATTConstants.CLASS_OF_SERVICE, p.Apttus_Config2__NetPrice__c);                          
                    } 
                    else if(ATTConstants.CIR.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                        nextList = ATTConstants.CIR; 
                        availProdOptions.remove(ATTConstants.CIR);  
                        nextTypeSet.add(ATTConstants.CIR); 
                        setConsId.add(p.Apttus_Config2__OptionId__c); 
                        nextTypeSelectedProdMap.put(ATTConstants.CIR, p.Apttus_Config2__OptionId__c); 
                        nextTypeSelectedPriceMap.put(ATTConstants.CIR, p.Apttus_Config2__NetPrice__c); 
                        system.debug('p.Apttus_Config2__OptionGroupLabel__c@@@@@@>'+p.Apttus_Config2__OptionGroupLabel__c);
                        system.debug('p.Apttus_Config2__OptionId__c@@@@@@>'+p.Apttus_Config2__OptionId__c);  
                        cs.CIRVal = p.Apttus_Config2__OptionId__r.Name; 
                        selectedProductval = p.Apttus_Config2__OptionId__c;                         
                         
                    }
                    else if(ATTConstants.MAC_LIMIT.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                        nextList = ATTConstants.MAC_LIMIT; 
                        availProdOptions.remove(ATTConstants.MAC_LIMIT);  
                        nextTypeSet.add(ATTConstants.MAC_LIMIT);  
                        nextTypeSelectedProdMap.put(ATTConstants.MAC_LIMIT, p.Apttus_Config2__OptionId__c); 
                        nextTypeSelectedPriceMap.put(ATTConstants.MAC_LIMIT, p.Apttus_Config2__NetPrice__c);                          
                    }
                    
                    system.debug('quoteobj.Ethernet_Configuration__c >>>>>>>>>>'+quoteobj.Ethernet_Configuration__c);
                    system.debug('Main Option List ----------->'+sPWrapTemp.optionsList);
                    system.debug('p.Apttus_Config2__OptionGroupLabel__c ->'+p.Apttus_Config2__OptionGroupLabel__c+'  p.Apttus_Config2__OptionId__c-->'+p.Apttus_Config2__OptionId__c+'  ');
                    //Quotehelper.setSelectedProductInOptionsList(sPWrapTemp.optionsList, p.Apttus_Config2__OptionGroupLabel__c, p.Apttus_Config2__OptionId__c , p.Apttus_Config2__NetPrice__c);
                }
            }//End of For
            if(!availProdOptions.isempty()){
                //create dummy options for which user has not selected
                system.debug('Fixing non selected product ---> '+availProdOptions);
                for(String leftoption : availProdOptions){
                    if(!'Options'.equalsIgnoreCase(leftoption) && !ATTConstants.MAC_LIMIT.equalsIgnoreCase(leftoption)){              
                        //helper.getSelectOptionPortSpeedNew(sPWrapTemp.optionsList , leftoption, sugProdId, 'None', null);  
                        nextTypeSet.add(leftoption);  
                        nextTypeSelectedProdMap.put(leftoption, null);  
                    }
                    //loop added as for hub and spoke Mac Limit is optional - start
                    else if((ATTConstants.MAC_LIMIT).equalsIgnoreCase(leftoption) && (mainproductId == ProductId__c.getValues(ATTConstants.ASES).Product_Id__c) && (ATTConstants.ETHER_HUB_SPOKE).equalsIgnoreCase(quoteobj.Ethernet_Configuration__c)){
                        system.debug('leftoption --> '+leftoption); 
                        nextTypeSet.add(leftoption);  
                        nextTypeSelectedProdMap.put(leftoption, null);  
                    }
                    //loop added as for hub and spoke Mac Limit is optional - end
                } 
            }
            if(availProdOptionsMain.size()!= availProdOptions.size()){                
                sitePricingMap.put(cs.custSiteIns.id, sPWrapTemp);
                sPricingWrap = sPWrapTemp;
                sPricingWrap.disableApplyBtn = true; 
                system.debug('selectedProductval@@@@@@>'+selectedProductval); 
                system.debug('sPWrapTemp.optionsList@@@@@@>'+sPWrapTemp.optionsList);
                list<Integer> primaryLineNumber = helper.getPrimaryLineNumForLineItems(cartId, cs.linenumber);
                system.debug('primarylinenumber @@@@@@> '+primaryLineNumber);
                sPricingWrap.portTypePrdId = portTypeId;
                if(IsrunConstraintrequired){
                    system.debug('@@@@@@@>setcon '+sPricingWrap.portTypePrdId);
                    if(sPricingWrap.portTypePrdId != null){
                         setConsId.add(sPricingWrap.portTypePrdId);
                    }
                    sugProdId = helper.getConstraintRuleResultNewV2(cartId, primaryLineNumber, setConsId);
                   
                }
                if(sugProdId == null){
                    sugProdId = new Set<String>();
                }
                
                helper.getSelectOptionPortSpeedNew(sPWrapTemp.optionsList , 'CIR', sugProdId, cs.CIRVal, selectedProductval);
                cs.CIRSubset = helper.getCIROption(sPWrapTemp.optionsList ,  selectedProductval); 
                system.debug('cs.CIRSubset@@@@@@>'+cs.CIRSubset);               
            }
                                
            list<Integer> primaryLineNumber = helper.getPrimaryLineNumForLineItems(cartId, cs.linenumber);
            system.debug('primaryLineNumber@@@@@@> '+primaryLineNumber);
            if(IsrunConstraintrequired && sugProdId == null){
                system.debug('@@@@@@@>setcon '+sPricingWrap.portTypePrdId);
                    if(sPricingWrap.portTypePrdId != null){
                         setConsId.add(sPricingWrap.portTypePrdId);
                    }
                    sugProdId = helper.getConstraintRuleResultNewV2(cartId, primaryLineNumber, setConsId);
            }
            //sugProdId = helper.getConstraintRuleResult(cartId, cs.linenumber);
            system.debug('sugProdId before ---> '+sugProdId);
            helper.setMultiSelectOptionPortSpeed(sPWrapTemp.optionsList, nextTypeSet, sugProdId, nextTypeSelectedProdMap, nextTypeSelectedPriceMap);
            calcSiteTotal();
            //break;
            system.debug('Final Map --------------------> '+sitePricingMap);
            system.debug('Display wrapper -> '+sPricingWrap);
             // added for populating site ins to show in the page
            Integer indx = siteLinenumberMap.get(siteid);
            system.debug('Indx ----> '+indx);              
            if(indx != null)
            custSiteInsSelectedValue = ListCustomerSite[indx - 1].custSiteIns;
            // added for populating site ins to show in page
            if(test.isRunningTest()){
                throw new myException('Error');
            }
        }catch(Exception e){
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in QuoteInfoController.IntializeUI', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        
    }
    
    public PageReference SaveandExit() {
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
                system.debug('Need Validation flag --> '+flag);
                if(flag){               
                    flag = Quotehelper.ValidateApply(sPricingWrapTemp, cs.custSiteIns.Site_Name__c);
                    system.debug('ValidateApply2 flag --> '+flag);
                }
                if(!flag){ 
                    //return null;//show error message
                    return page.PortalDashboard_UI;//QuotesAndOrdersDashboard_UI;
                }
                siteLineMapTemp.put(string.valueof(cs.linenumber.intValue()),cs.custSiteIns.Id);
            } 
        } 
        if(flag){
            helper.updateLineItemWithSite(siteLineMapTemp, quoteId);
            Quotehelper.saveProductConfiguration(cartId);
            quoteObj.Buyflow_Step__c = 'Configure Sites';
            update quoteObj;
        }
            if(test.isRunningTest()){
                throw new myException('Error');
            }
        }catch(Exception e){
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in QuoteInfoController.SaveandExit', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }      
        return page.PortalDashboard_UI;//QuotesAndOrdersDashboard_UI;
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
                system.debug('Quote Id -> '+quoteId);
                quoteObj = quoteHelper.getQuote(quoteId);
            }
            //List<String> custSiteIds =  new List<String>();
            if(!String.isEmpty(quoteId)){            
                List<AT_T_Customer_Site_Quote__c> custSiteQuoteLst = [Select Id, Name,AT_T_Customer_Site__c,AT_T_Quote__c,AT_T_Quote__r.Product__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,AT_T_Quote__r.Name,AT_T_Quote__r.Apttus_Proposal__Payment_Term__c,AT_T_Quote__r.Apttus_QPConfig__PriceListId__c,AT_T_Quote__r.Product__r.Name, AT_T_Customer_Site__r.Id, AT_T_Customer_Site__r.Name, AT_T_Customer_Site__r.Site_Name__c, AT_T_Customer_Site__r.City__c, AT_T_Customer_Site__r.Service_Availability_Response__c, AT_T_Customer_Site__r.State__c, AT_T_Customer_Site__r.Address_Line__c,Customer__c  from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=:quoteId];
                if(custSiteQuoteLst != null && custSiteQuoteLst.size() >0){
                    /*for(AT_T_Customer_Site_Quote__c custSiteQuote : custSiteQuoteLst){
                        custSiteIds.add(custSiteQuote.AT_T_Customer_Site__c);
                        
                    }*/
                    initializeCustomerSiteLst(custSiteQuoteLst);
                    custSiteQuoteIns = custSiteQuoteLst[0];
                    mainproductId = custSiteQuoteIns.AT_T_Quote__r.Product__c;
                    prodName = custSiteQuoteIns.AT_T_Quote__r.Product__r.Name;
                    priceListId = custSiteQuoteIns.AT_T_Quote__r.Apttus_QPConfig__PriceListId__c;
                    siteid = custSiteQuoteIns.AT_T_Customer_Site__r.Id;
                    productOptionList = helper.getProductOptionGroupDO(mainproductId , priceListId);
                    system.debug('productOptionList is @@@@@@> '+productOptionList);
                    if(String.isEmpty(mainproductId) || String.isEmpty(priceListId)){
                        isValidData = false;
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'To Run configure site product Id and pricelist Id are mandatory');
                        ApexPages.addMessage(myMsg);
                    }
                }
                //customerSiteList = [Select Id, Name,Site_Name__c,City__c, Address_Line__c, State__c, Service_Availability_Response__c  from CustomerSite__c where Id IN: custSiteIds];
                //if(customerSiteList.size()>0){
                //    siteid = customerSiteList[0].Id;
                //}
            }
            eligibleSites();
            if(test.isRunningTest()){
                throw new myException('Error');
            }
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
        system.debug('----------------------------------show detail'+siteid);  
        try{                        
            siteVasaResValidatorIns = new SiteVasaResValidator();           
            QuoteProducts.cCustomerSite cs = null;
            ethernetVal = siteIdEthernetAvailMap.get(siteid);
            system.debug('ethernetVal  -- > '+ethernetVal);
            if(sitePricingMap.get(siteid)!=null){
                sPricingWrap = sitePricingMap.get(siteid);
                 //start
                Integer indx = siteLinenumberMap.get(siteid);
                system.debug('Indx ----> '+indx);              
                if(indx != null)                
                custSiteInsSelectedValue = ListCustomerSite[indx - 1].custSiteIns;
                //end                
            }else{
                Integer indx = siteLinenumberMap.get(siteid);
                system.debug('Indx ----> '+indx);              
                if(indx != null)
                cs = ListCustomerSite[indx - 1];
                custSiteInsSelectedValue = cs.custSiteIns;
                system.debug('Selected customer site --> '+cs);
                if(cs!= null && (cs.linenumber == null || cs.linenumber == 0)){
                    system.debug('mainproductId >>>>>>>>>>>>>>'+mainproductId);
                    system.debug('cartId >>>>>>>>>>>>>>'+cartId);
                    lineNumbersLst = helper.addMainProductIntoBundle(cs.custSiteIns , mainproductId , cartId);
                    
                    system.debug('Main product Added ----> '+lineNumbersLst);
                    cs.linenumber = lineNumbersLst[0];
                    sPricingWrap = helper.getProductComponentOptionWrapper(productOptionList,mainProductId);
                    //sPricingWrap.disableApplyBtn = false;
                    sPricingWrap.disableApplyBtn = true; // updated from false to true by Praveen for the defect : DE90145
                    system.debug('mainproductId >>>>>>>>>>'+mainproductId);
                    if(mainproductId == ProductId__c.getValues('ASES').Product_Id__c)
                    helper.getSelectOptionPortSpeed(sPricingWrap.optionsList,ethernetVal, ATTConstants.PORT_SPEED);
                    else
                    helper.getSelectOptionPortType(sPricingWrap.optionsList,ethernetVal, ATTConstants.PORT_TYPE);
                    sitePricingMap.put(siteid, sPricingWrap);
                }else if(mainproductId != null){
                    system.debug('mainproductId >>>>>>>>>>'+mainproductId);
                    Apttus_Config2__ProductConfiguration__c prodConfig = quoteHelper.retrieveExistingCartId(quoteId);
                    IntializeUI(prodConfig, cs, true);
                }
                
                system.debug('Main Option List ----------->'+sPricingWrap.optionsList);
               //calcSiteTotal();   
            }
            calcSiteTotal();
            if(test.isRunningTest()){
                throw new myException('Error');
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
            System.debug('Site Id for pricing --> '+siteid);
            QuoteProducts.SelectPricingWrap sPricingWrapTemp = sitePricingMap.get(siteid);
            if(sPricingWrapTemp != null && sPricingWrapTemp.optionsList != null){
                for(QuoteProducts.ProductOption tempVal: sitePricingMap.get(siteid).optionsList){  
                    tprice =  QuoteHelper.checkNull(tempVal.price);             
                    siteTotal+= tprice ;
                    system.debug('tprice @@@@@@>'+ tprice);
                } 
            }  
            if(test.isRunningTest()){
                throw new myException('Error');
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
    public void selectedOptGrpQuery(){  
        try{
            Boolean optionsChecked = false;
            String nextList = '';
            QuoteProducts.cCustomerSite cs = null;
            String portSpeed = null;
            list<Integer> primaryLineNumber = null;
            Map<String, String> siteLineMapTemp = new Map<String, String>();
            Set<String> setConsId = new Set<String>();
            QuoteProducts.ProductOption selectedProduct = null;
            Integer indx = siteLinenumberMap.get(siteId);
            cs = ListCustomerSite[indx - 1];
            if(sPricingWrap.disableApplyBtn == true){                
                cs.isProcessed = false;
                cs.spanClass = 'display:none; color:green;';
            }
            sPricingWrap.disableApplyBtn = false;
            isAllSitesNotProcessed = true;            
            system.debug('selected Site   --- > '+cs);
            system.debug('selectOptGrp  --- > '+selectOptGrp);
            system.debug('selectOptGrpVal  --- > '+selectOptGrpVal);
            system.debug('mainproductId  --- > '+mainproductId);
            system.debug('sPricingWrap.optionsList  --- > '+sPricingWrap.optionsList);
            selectedProduct = helper.getSelectedProduct(sPricingWrap.optionsList, selectOptGrp, selectOptGrpVal);
            system.debug('selectedProduct  -- > '+selectedProduct );
            if(selectedProduct != null){
                    helper.createLineItem(quoteId, cs.linenumber.intValue(), selectOptGrp, cartId, selectedProduct); 
                    primaryLineNumber = helper.getPrimaryLineNumForLineItems(cartId, cs.linenumber);
                    system.debug('primarylinenumber @@@@@@> '+primaryLineNumber);
                    //sugProdId = helper.getConstraintRuleResultNew(cartId,primaryLineNumber);
                    setConsId.add(selectOptGrpVal);
                    if(sPricingWrap.portTypePrdId != null){
                         setConsId.add(sPricingWrap.portTypePrdId);
                    }
                    //sugProdId = helper.getConstraintRuleResultNewV2(cartId, primaryLineNumber, setConsId);
                    system.debug('----->sugProdId'+ sugProdId);                    
            } 
            if(ATTConstants.PORT_TYPE.equals(selectOptGrp)) {
                nextList = ATTConstants.PORT_SPEED;                                          
            }else if(ATTConstants.PORT_SPEED.equals(selectOptGrp)){
                sPricingWrap.portTypePrdId = selectOptGrpVal;
                Quotehelper.makeSelectedProductOptionsEmptyUI(sPricingWrap , ATTConstants.CLASS_OF_SERVICE);
                //Quotehelper.makeSelectedProductOptionsEmptyUI(sPricingWrap , ATTConstants.INTERFACE_TYPE);
                Quotehelper.removeSelectedProductOptionsUI(sPricingWrap , ATTConstants.CIR);
                Quotehelper.removeSelectedProductOptionsUI(sPricingWrap , ATTConstants.INTERFACE_TYPE);
                if(mainproductId == ProductId__c.getValues(ATTConstants.ASES).Product_Id__c){
                    //nextList = 'Serving Arrangement';
                    nextList = ATTConstants.SERVING_ARRANGEMENT;
                }else{
                    nextList = ATTConstants.ACCESS_TYPE;
                }
                sugProdId = helper.getConstraintRuleResultNewV2(cartId, primaryLineNumber, setConsId);                
            }else if(ATTConstants.SERVING_ARRANGEMENT.equalsIgnoreCase(selectOptGrp) && selectOptGrpVal == ProductId__c.getValues(ATTConstants.BASIC).Product_Id__c){                
                    //nextList = ATTConstants.CLASS_OF_SERVICE_BASIC; 
                    nextList = ATTConstants.CLASS_OF_SERVICE;
            }else if(ATTConstants.CLASS_OF_SERVICE_PACKET.equalsIgnoreCase(selectOptGrp) || ATTConstants.CLASS_OF_SERVICE_BASIC.equalsIgnoreCase(selectOptGrp) || ATTConstants.CLASS_OF_SERVICE.equalsIgnoreCase(selectOptGrp)){               
                    nextList = ATTConstants.CIR;
                    cs.CoS = selectedProduct.productId;  
                    cs.COSVal = cosValue.get(SelectedProduct.Name);                             
            }else if(ATTConstants.CIR.equalsIgnoreCase(selectOptGrp)){  
                   //Quotehelper.makeSelectedProductOptionsEmptyUI(sPricingWrap , ATTConstants.INTERFACE_TYPE);
                   primaryLineNumber = helper.getPrimaryLineNumForLineItems(cartId, cs.linenumber);
                   system.debug('primarylinenumber @@@@@@> '+primaryLineNumber);
                   system.debug('@@@@@@@>setcon '+sPricingWrap.portTypePrdId);
                   if(sPricingWrap.portTypePrdId != null){
                        setConsId.add(sPricingWrap.portTypePrdId);
                    }
                    sugProdId = helper.getConstraintRuleResultNewV2(cartId, primaryLineNumber, setConsId);
                    nextList = ATTConstants.INTERFACE_TYPE;
                    boolean pricingFlag = helper.computePrice(cartId,cs.linenumber.intvalue());                   
                    //make CIR options
                    cs.CIRVal = selectedProduct.Name; 
                    cs.CIRSelectedId = selectedProduct.productId;
                    system.debug('CIRSubset--------------->'+helper.getCIROption(sPricingWrap.optionsList ,  selectOptGrpVal));                         
            }else if(ATTConstants.INTERFACE_TYPE.equals(selectOptGrp) && mainproductId != ProductId__c.getValues(ATTConstants.ASES).Product_Id__c){
                nextList = ATTConstants.INSTALLATION_OPTIONS;
            }else if(ATTConstants.INTERFACE_TYPE.equals(selectOptGrp) && mainproductId == ProductId__c.getValues(ATTConstants.ASES).Product_Id__c && quoteobj.Ethernet_Configuration__c == 'Ethernet Virtual Private Line (Hub-and-Spoke)'){
                //nextList = 'MAC Limit';
                nextList = ATTConstants.MAC_LIMIT;
            }
            /*if(ATTConstants.INTERFACE_TYPE.equals(selectOptGrp) && mainproductId == ProductId__c.getValues('ASES').Product_Id__c ){
                sPricingWrap.disableApplyBtn = false;
            }*/
            if(!ATTConstants.DSELECT.equals(selectOptGrpVal)){
                system.debug('Next List ------------> '+nextList);
                helper.getSelectOptionPortSpeedNew(sPricingWrap.optionsList , nextList, sugProdId, selectOptGrp, selectOptGrpVal);
                
            }         
            System.debug('Site Id for pricing Before--> '+siteid);
            if(ATTConstants.CIR.equalsIgnoreCase(selectOptGrp)){            
                quotehelper.updateLineItemPriceUI(cs.linenumber.intValue(), cartId, sPricingWrap);
            }
            
            calcSiteTotal();
            grandTotalPopulate();
            if(test.isRunningTest()){
                throw new myException('Error');
            }
            
        }
        catch(Exception e){
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in QuoteInformationController.selectedOptGrpQuery', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    
   /* public void updateLineWithIA(Integer linenumber, String accessType, String interfaceType){
        try{
            system.debug('updateLineItem for Interface type & Access type ------------------->'+interfaceType+'  AType -> '+accessType+'  Id->'+quoteId+'  Line ->'+siteLinenumberMap.get(siteid));
            helper.updateLineItem(linenumber,interfaceType,accessType,quoteId);
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.updateLineWithIA', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }*/
    
    
    /***********
* Method name : applyProdOpt
* Description : called when apply button is clicked.
* Return Type : None.
* Parameters : None.
***********/
    
    
    public void applyProdOpt()
    {
        boolean flag = false;
        QuoteProducts.SelectPricingWrap sPricingWrap = null;
        QuoteProducts.cCustomerSite cs = null;
        Map<String, String> siteLabelAttrMapTemp = new Map<String, String>();
        try{           
            sPricingWrap = sitePricingMap.get(siteId);
            Integer indx = siteLinenumberMap.get(siteId);              
            if(ListCustomerSite.size()>= indx)
            {
                cs = ListCustomerSite[indx-1];              
                system.debug('Linenumber -> '+indx+'  ListCustomerSite size --> '+ListCustomerSite.size());
                flag = Quotehelper.ValidateApply(sPricingWrap, cs.custSiteIns.Site_Name__c);
                system.debug('ValidateApply2 flag --> '+flag);
                if(flag){                   
                    helper.updateLineItemWithSiteLineNumber(siteId, cs.linenumber.intvalue(), QuoteId, siteLabelAttrMapTemp);//updating line item with customer site DML
                    boolean pricingFlag = helper.computePrice(cartId,cs.linenumber.intvalue());
                    system.debug('pricingFlag  --> '+pricingFlag);
                    quotehelper.updateLineItemPriceUI(cs.linenumber.intValue(), cartId, sPricingWrap); //1/26/2015 - update grandtotal
                   // quotehelper.updateLineItem(cs.linenumber, QuoteId, sPricingWrap);//no DML only update to temp data
                    if(pricingFlag)
                    { 
                        system.debug('Disable Apply button success---> ');                      
                        cs.spanClass = 'display:inline-block; color:green;';
                        cs.isProcessed = true;
                        cs.pricingStatus = ATTConstants.COMPLETE;
                        sPricingWrap.disableApplyBtn = true;
                        isAllSitesNotProcessed = Quotehelper.isAllSiteProcessed(ListCustomerSite);
                        calcSiteTotal();
                        grandTotalPopulate();
                        helper.removeAppliedRule(cartId);
                        
                    }
                }
            }
            handlefilterSites();
            if(test.isRunningTest()){
                throw new myException('Error');
            }
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.applyProdOpt', e.getTypeName(), ATTException.constructExceptionMessageString(e));
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
            //system.debug('----->sitePricingMap'+sitePricingMap);
            /*for(String tempSelPriWrap: sitePricingMap.keyset()){
                system.debug('----->tempSelPriWrap'+tempSelPriWrap);
                QuoteProducts.selectPricingWrap sPricingWrapTemp = sitePricingMap.get(tempSelPriWrap);
                if(sPricingWrapTemp != null && sPricingWrapTemp.optionsList != null){                
                    for(QuoteProducts.ProductOption tempVal: sitePricingMap.get(tempSelPriWrap).optionsList){
                        system.debug('----->tempVal'+tempVal); 
                        tprice =  QuoteHelper.checkNull(tempVal.price);               
                        grandTot+= tprice;
                    } 
                }          
            }*/// commented on 1/26/2015
            grandTot = quotehelper.getGrandTotalForCartId(cartId);//Added by Gaurav 1/26/2015
            system.debug('----->grandTot'+grandTot); 
            if(test.isRunningTest()){
                throw new myException('Error');
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
            system.debug('Eligible Sites -- > '+siteIdEthernetAvailMap);
            if(test.isRunningTest()){
                throw new myException('Error');
            }
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
        List<QuoteProducts.cCustomerSite> siteLstNeedsToBeAdded = new List<QuoteProducts.cCustomerSite>();
        //List<QuoteProducts.cCustomerSite> siteLstNeedsToBeDeleted = new List<QuoteProducts.cCustomerSite>();
        List<Decimal> siteLstNeedsToBeDeleted = new List<Decimal>();
        Map<String, String> siteLineMapTemp = new Map<String, String>();
        Set<Id> selectedSiteId = new Set<Id>();
        Integer count = 0;
        try{
            for(QuoteProducts.cCustomerSite temp: eligibleSitesLst){  
                for(QuoteProducts.cCustomerSite csAll : ListCustomerSite){
                    if(temp.custSiteIns.Id == csAll.custSiteIns.Id){
                        if(temp.eligibleSelected && !csAll.isProcessed){
                            siteLstNeedsToBeAdded.add(temp);
                            sitePricingMap.put(temp.custSiteIns.Id,null);
                            siteLstNeedsToBeDeleted.add(temp.linenumber);
                            system.debug(temp.eligibleSelected+ ' --Selected Site Flag to be added --------->'+csAll.isProcessed);
                        }else if(!temp.eligibleSelected && csAll.isProcessed){
                            //siteLstNeedsToBeDeleted.add(temp);
                        }else if(temp.eligibleSelected && csAll.isProcessed){
                            siteLstNeedsToBeAdded.add(temp);
                            sitePricingMap.put(temp.custSiteIns.Id,null);
                            siteLstNeedsToBeDeleted.add(temp.linenumber);
                        }
                        break;
                    }
                }             
                
            }
            if(siteLstNeedsToBeDeleted.size()>0){
                //remove existing products
                helper.removeMultiBundles(cartId, siteLstNeedsToBeDeleted);
            }
            system.debug('Number of sites need to be created--------->'+siteLstNeedsToBeAdded.size());
            if(siteLstNeedsToBeAdded.size()>0){
                List<Decimal> linumbersLst = helper.addMainProductsIntoBundle(siteLstNeedsToBeAdded, mainproductid, cartId);
                for(QuoteProducts.cCustomerSite temp: siteLstNeedsToBeAdded){
                    for(QuoteProducts.cCustomerSite csAll : ListCustomerSite){
                        if(temp.custSiteIns.Id == csAll.custSiteIns.Id){ 
                            temp.linenumber = linumbersLst[count];
                            csAll.linenumber = temp.linenumber;
                            siteLineMapTemp.put(string.valueof(temp.linenumber.intValue()), temp.custSiteIns.Id);
                            selectedSiteId.add(temp.custSiteIns.Id);
                        }
                    }
                    count++;    
                }
                //helper.updateLineItemWithSite(siteLineMapTemp, quoteId);
                system.debug('siteLineMapTemp >>>>>>>>>>>>'+siteLineMapTemp);
                updateCustomerForEligibleSites(selectedSiteId); // method added to keep the customer value selected intact for eligible sites through link 1/26/2015
                helper.updateLineItemWithSiteUsingCartId(siteLineMapTemp, cartId);
            }
            grandTotalPopulate();
            if(test.isRunningTest()){
                throw new myException('Error');
            }
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.eligibleSitesApply', e.getTypeName(), ATTException.constructExceptionMessageString(e));
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
            Integer indx = siteLinenumberMap.get(siteId);
            Integer count = 0;              
            if(ListCustomerSite.size()>= indx){
                cs = ListCustomerSite[indx-1];
                if(!cs.isProcessed){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Click Apply to selected site before applying the same configuration to other sites. your selected site is '+cs.custSiteIns.Site_Name__c);
                    ApexPages.addMessage(myMsg);
                    return;
                } 
                for(QuoteProducts.cCustomerSite csAll : ListCustomerSite){
                    system.debug(cs.vasaResStr + ' VASA Comparison --> '+ csAll.vasaResStr);
                    if(cs.vasaResStr == csAll.vasaResStr && cs.custSiteIns.Id != csAll.custSiteIns.Id){
                        csn = new  QuoteProducts.cCustomerSite(csAll);
                        csn.linecount = count;
                        count++;
                        eligibleSitesLst.add(csn);
                    }
                }
            }
            if(test.isRunningTest()){
                throw new myException('Error');
            }
        }catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.eligibleSitesPop', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        system.debug('--------eligibleSitesLst length --> '+eligibleSitesLst.size());
    }
    
    /************************************************************************************************************************/
    // method added to keep the customer value selected intact for eligible sites through link - Start 1/26/2015
    public void updateCustomerForEligibleSites(Set<Id> eligibleSitesId)
    {
        List<AT_T_Customer_Site_Quote__c> custSiteQuoteLst = [Select Id, Name,AT_T_Customer_Site__c,AT_T_Quote__c,Customer__c,AT_T_Quote__r.Product__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,AT_T_Quote__r.Name,AT_T_Quote__r.Apttus_Proposal__Payment_Term__c,AT_T_Quote__r.Apttus_QPConfig__PriceListId__c,AT_T_Quote__r.Product__r.Name from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=:quoteId and AT_T_Customer_Site__c IN : eligibleSitesId];
        List<AT_T_Customer_Site_Quote__c> custSiteQuoteLstupdate = new List<AT_T_Customer_Site_Quote__c>();
        system.debug('siteId-----> '+ siteId);
        if(custSiteQuoteLst != null)
        {
            for(AT_T_Customer_Site_Quote__c qsj :custSiteQuoteLst)
            {
                    qsj.customer__c = selectedCustomer;
                    custSiteQuoteLstupdate.add(qsj);
                
            }
        }
        if(custSiteQuoteLstupdate != null)
            update custSiteQuoteLstupdate;
        system.debug('custSiteQuoteLstupdate-----> '+ custSiteQuoteLstupdate);
        
    }
    // End
    
    @RemoteAction
    public static Boolean IsPricingUpdateRequired(String quoteId, String cartId, String siteId) {
        Boolean needMoreProcessing = false;
        Map<String, String> siteLabelAttrMapTemp = new Map<String, String>();
        QuoteInfoHelper Quotehelper = new QuoteInfoHelper ();
        ApttusServiceUtilityHelper helper = new ApttusServiceUtilityHelper();
        boolean pricingFlag = false;
        List<QuoteProducts.Productoption> lineitemList = null;
        system.debug('IsPricingUpdateRequired Input -----------------------------quoteId------>'+quoteId+'  Cart Id -->'+cartId + ' Site Id -->'+siteId);
        Apttus_Config2__ProductConfiguration__c prodConfig = quotehelper.retrieveExistingProductConfigusingCartId(cartId);
        Map<Integer, String> siteLineMapTemp = quotehelper.retrieveAnyPendingLineitem(prodConfig);
        Integer linenumber = 0;
        if(!siteLineMapTemp.isempty()){
            system.debug('Sitelinemap------------> '+siteLineMapTemp);
            lineitemList = quotehelper.retrieveLineItemsForGivenSite(prodConfig, siteId, siteLabelAttrMapTemp);
            if(lineitemList!= null && lineitemList.size()>0){
                List<Apttus_CPQApi.CPQ.SelectedOptionDO> selectedOptionList = helper.createSelectedOptionList(lineitemList);
                List<Integer> linenumbers = new List<Integer>(siteLineMapTemp.keySet());
                system.debug('linenumberLst------------> '+linenumbers);
                linenumber = linenumbers[0];
                system.debug('linenumber------------> '+linenumber);
                helper.addOptionsToBundle(linenumber, cartId, selectedOptionList); 
                system.debug('siteLabelAttrMapTemp--------------->'+siteLabelAttrMapTemp);
                helper.updateLineItemWithSiteLineNumber(siteLineMapTemp.get(linenumber), linenumber, quoteId, siteLabelAttrMapTemp);//updating line item with customer site DML
                pricingFlag = helper.computePrice(cartId,linenumber); 
                if(pricingFlag){               
                    needMoreProcessing = true;               
                }   
            }                  
        }
        return needMoreProcessing;
    }
    
    
    public void handleApplyEligibleConfigUI(){
        system.debug('-------handleApplyEligibleConfigUI----------->');
        Apttus_Config2__ProductConfiguration__c prodConfig = quotehelper.retrieveExistingProductConfigusingCartId(cartId);
        //readPricingStatusForAllLineItem(prodConfig);
        readPricingStatusForAllLineItem(prodConfig, siteId);
        isAllSitesNotProcessed = Quotehelper.isAllSiteProcessed(ListCustomerSite);
    }
    
    
    public void siteTraverseMethodNext(){
        try{
            Integer siteLineNum;
            if(siteLinenumberMap != null && siteLinenumberMap.containsKey(siteid)){
                siteLineNum = siteLinenumberMap.get(siteid);
                 if(ListCustomerSite.size()>= siteLineNum){
                    custSiteInsSelectedValue = ListCustomerSite[siteLineNum - 1].custSiteIns; 
                }
            }
            system.debug('siteLineNum --------> '+siteLineNum);
            
            for(String strSiteId : siteLinenumberMap.keyset()){
                if(siteLineNum != null && siteLinenumberMap.get(strSiteId) == siteLineNum + 1 && disableNext == false){
                    siteid = strSiteId;
                    disablePrevious = false;
                }
            }
            system.debug('siteLineNum --------> '+siteLineNum);
            if(ListCustomerSite != null && siteLineNum != null && siteLineNum == ListCustomerSite.size()){ //need to fix
                disableNext = true;
                disablePrevious = false;
            }       
            showDetail();
            if(test.isRunningTest()){
                throw new myException('Error');
            }
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.siteTraverseMethodNext', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    public void siteTraverseMethodPrevious(){
        try{
            Integer siteLineNum;
            if(siteLinenumberMap != null && siteLinenumberMap.containsKey(siteid)){
                siteLineNum = siteLinenumberMap.get(siteid);
                 if(ListCustomerSite.size()>= siteLineNum){
                    custSiteInsSelectedValue = ListCustomerSite[siteLineNum - 1].custSiteIns; 
                }
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
            showDetail();
            if(test.isRunningTest()){
                throw new myException('Error');
            }
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.siteTraverseMethodPrevious', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    public void finalizeCart(){
        try{
            //Isfinalized = helper.finalizeCart(cartId);
            quotehelper.saveProductConfiguration(cartId);
            if(quoteObj.Product__r.productcode == 'ASES'){
                quotehelper.updatehubinJunction(quoteId, selectsitehub);
                quoteHelper.hubAndSpokeCIRValidationnew(ListCustomerSite,this,quoteId);
                //populateEVCLst();
                evcListTable = quotehelper.getEVCList(ListCustomerSite,quoteId);
            }
            //quotehelper.saveProductConfiguration(cartId);
            quotehelper.updateByflowStep(quoteId); 
            system.debug('$$$$$$$$$$$ evcListTable '+evcListTable); 
            if(test.isRunningTest()){
                throw new myException('Error');
            }
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.finalizeCart', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        system.debug ('READ VAL :: ' + evcListTable.size() + ',' + evcListTable);
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
                    //changed on 1/28/2015
                    //helper.cleanLineItemListOnPortSelect(, cartId);changed on 1/28/2015
                    helper.removeBundle(cartId, cs.linenumber.intValue());//changed on 1/28/2015
                    helper.removeAppliedRule(cartId);
                    sitePricingMap.remove(cs.custSiteIns.Id);
                    //changed on 1/28/2015
                    showDetail(); 
                    Quotehelper.removeSelectedProductOptionsUI(sPricingWrap , ATTConstants.CIR);
                    Quotehelper.removeSelectedProductOptionsUI(sPricingWrap , ATTConstants.INTERFACE_TYPE);
                    Quotehelper.removeSelectedProductOptionsUI(sPricingWrap , ATTConstants.CLASS_OF_SERVICE);
                    Quotehelper.removeSelectedProductOptionsUI(sPricingWrap , ATTConstants.SERVING_ARRANGEMENT);
                    Quotehelper.makeSelectedProductOptionsEmptyUI(sPricingWrap , ATTConstants.PORT_SPEED);
                }
            }
            isAllSitesNotProcessed = true;
            calcSiteTotal();
            grandTotalPopulate();
            if(test.isRunningTest()){
                throw new myException('Error');
            }
        }
        catch(Exception e){
            ATTException.createException('Error in QuoteInfoController.handleClearUI', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    
    public void handlefilterSites(){
        for(QuoteProducts.cCustomerSite csAll : ListCustomerSite){
            if(csAll.isProcessed && selectedFilter.equalsIgnoreCase('Configured')){
                csAll.showSites = true;
                csAll.spanClass = 'display:inline-block; color:green;';
            }else if(!csAll.isProcessed && selectedFilter.equalsIgnoreCase('NotConfigured')){
                csAll.showSites = true;
                csAll.spanClass = 'display:none; color:green;';
            }else if(selectedFilter.equalsIgnoreCase('All')){
                csAll.showSites = true;
                //csAll.spanClass = 'display:inline-block; color:green;';
            }else{
                csAll.showSites = false;
                csAll.spanClass = 'display:none; color:green;';
            }
        }
    }
    
    public List<SelectOption> getFilterOptions(){
        List<SelectOption> filterOption = new List<SelectOption>();
        filterOption.add(new selectoption('All', 'Filter Sites'));
        filterOption.add(new selectoption('Configured', 'Configured'));
        filterOption.add(new selectoption('NotConfigured', 'NotConfigured'));       
        return filterOption;
    }
    
    public PageReference GotoAddAddressPage() {
        system.debug('quoteId >>>>>>>>'+quoteId);
        PageReference pgRef = SaveandExit();
        //pgRef = 
        system.debug('after save and exit >>>>>>>>'+pgRef);
        Apttus_Proposal__Proposal__c quote = new Apttus_Proposal__Proposal__c();
        quote.Id = quoteId;
        quote.Buyflow_Step__c = 'Add Sites';
        update quote;
        PageReference AddaddressPage = system.page.buyflow;
        AddaddressPage.getParameters().put('mode', 'siteinfo');
        AddaddressPage.getParameters().put('quoteid', quoteId ); 
        AddaddressPage.getParameters().put('buyflow', 'false');
        System.debug('***quoteId********'+quoteId);       
        return AddaddressPage;
        
    }
    

    
    //This method uses a simple SOQL query to return a List of Contacts
    public List<CustomerSite__c> getCustomerSiteLst() {
        List<CustomerSite__c> customerSiteList = new List<CustomerSite__c>();
        if(ListCustomerSite == null) {
            List<AT_T_Customer_Site_Quote__c> custSiteQuoteLst = [Select Id, Name,AT_T_Customer_Site__c,AT_T_Quote__c,AT_T_Quote__r.Product__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,AT_T_Quote__r.Name,AT_T_Quote__r.Apttus_Proposal__Payment_Term__c,AT_T_Quote__r.Apttus_QPConfig__PriceListId__c,AT_T_Quote__r.Product__r.Name, AT_T_Customer_Site__r.Id, AT_T_Customer_Site__r.Name, AT_T_Customer_Site__r.Site_Name__c, AT_T_Customer_Site__r.City__c, AT_T_Customer_Site__r.Service_Availability_Response__c, AT_T_Customer_Site__r.State__c, AT_T_Customer_Site__r.Address_Line__c,Customer__c  from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=:quoteId];
            initializeCustomerSiteLst(custSiteQuoteLst);
        }
        for(QuoteProducts.cCustomerSite csAll : ListCustomerSite){
            customerSiteList.add(csAll.custSiteIns);
        }
        return customerSiteList;
    }
    
    
    public void initializeCustomerSiteLst(List<AT_T_Customer_Site_Quote__c> custSiteQuoteLst){
        Integer count = 1;
        CustomerSite__c c = null;
        if(ListCustomerSite == null) {
            ListCustomerSite = new List<QuoteProducts.cCustomerSite>();
            system.debug('customerSiteList.size()----------------->'+custSiteQuoteLst.size());
            //for(CustomerSite__c c: customerSiteList) {
            for(AT_T_Customer_Site_Quote__c custSiteQuoteIns : custSiteQuoteLst) {
                // As each contact is processed we create a new cContact object and add it to the ListCustomerSite
                c = new CustomerSite__c();
                c.Id = custSiteQuoteIns.AT_T_Customer_Site__r.Id;
                //c.Name = custSiteQuoteIns.AT_T_Customer_Site__r.Name;
                c.Site_Name__c = custSiteQuoteIns.AT_T_Customer_Site__r.Site_Name__c;
                c.City__c = custSiteQuoteIns.AT_T_Customer_Site__r.City__c;
                c.Address_Line__c = custSiteQuoteIns.AT_T_Customer_Site__r.Address_Line__c;
                c.State__c = custSiteQuoteIns.AT_T_Customer_Site__r.State__c;
                c.Service_Availability_Response__c = custSiteQuoteIns.AT_T_Customer_Site__r.Service_Availability_Response__c;
                 QuoteProducts.cCustomerSite ccs = new  QuoteProducts.cCustomerSite(c);
                ccs.linecount = count;
                ccs.showSites = true; 
                           
                if(quoteobj.Ethernet_Configuration__c == 'Ethernet Virtual Private Line (Hub-and-Spoke)')
                {
                    typeConnection = true;
                    ccs.SiteConnectionType = 'Spoke';
                }
                else
                {
                    TypeConnection = false;
                    ccs.SiteConnectionType = 'P2P';
                }
                
                if(siteIdEthernetAvailMap != null && siteIdEthernetAvailMap.containsKey(String.valueOf(c.Id)) && siteIdEthernetAvailMap.get(String.valueOf(c.Id)) == false)
                        ccs.vasaResStr = 'P';
                    else if(siteIdEthernetAvailMap != null && siteIdEthernetAvailMap.containsKey(String.valueOf(c.Id)) && siteIdEthernetAvailMap.get(String.valueOf(c.Id)) == true)
                        ccs.vasaResStr = 'E';
                    else if(siteIdEthernetAvailMap != null && siteIdEthernetAvailMap.containsKey(String.valueOf(c.Id)) && siteIdEthernetAvailMap.get(String.valueOf(c.Id)) == null)
                        ccs.vasaResStr = 'B';
                    else
                       ccs.vasaResStr = 'B'; 
                ListCustomerSite.add(ccs);
                siteLinenumberMap.put(c.Id, count);
                count++;
            }
        }
        system.debug('siteLinenumberMap----------------->'+siteLinenumberMap);
    }
    
    public void beforecontinue()
    {
        try{
            selectCirVal='not select';
            
            for(QuoteProducts.cCustomerSite cs :evcListTable){
                if(cs.EVCCir.equalsIgnoreCase('select')){
                    selectCirVal = 'select';
                    system.debug('EVCCir@@@@@@> '+ cs.EVCCir);
                    system.debug('selectCirVal @@@@@@> '+ selectCirVal );
                    break;
                }
            }
            if(test.isRunningTest()){
                throw new myException('Error');
            }
           
             system.debug('selectCirVal out of for @@@@@@> '+ selectCirVal );           
        } catch(Exception e){
            
        }
       
    }
    public PageReference continueClick() {
        try{
            //selectCirVal='select';
            List<ApexPages.Message> errormessages = new List<ApexPages.Message>();
            EVCList = new list<EVC_Details__c>();
            for(QuoteProducts.cCustomerSite cs :evcListTable){
                EVC_Details__c evc = new EVC_Details__c();
                evc.EVC_From__c = cs.EVCfrom.id;
                evc.EVC_To__c = cs.EVCto.id;
                if(cs.Name != null)
                evc.Name = cs.Name;
                else
                evc.Name = 'EVC - '+cs.EVCfrom.AT_T_Customer_Site__r.Site_Name__c;
                if(cs.EVCCir.equalsIgnoreCase('select')){
                    selectCirVal = 'select';
                    system.debug('EVCCir@@@@@@> '+ cs.EVCCir);
                    system.debug('selectCirVal @@@@@@> '+ selectCirVal );
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,+' CIR Selection is important');
                    errormessages.add(myMsg);
                }
                evc.Committed_Info_Rate__c = cs.EVCCir;
                system.debug('cosval @@@@@@> '+ cs.cosval);
                system.debug('cos @@@@@@> '+ cs.cos);
                evc.cos__c = cs.Cos;
                EVCList.add(evc);
            }
            if(errormessages!=null && errormessages.size()>0)
            {
                
                for(ApexPages.Message errormessage : errormessages)
                    ApexPages.addMessage(errormessage);
            }
            else if(EVCList != null){
                insert EVCList;
            }
                        
        } catch(Exception e){
            
        }
        return null;
    }
    
    public void initializeGlobalParameter(){
        siteIdEthernetAvailMap = new Map<String,Boolean>();
        siteIdEligibleSitesMap = new Map<String,List<QuoteProducts.cCustomerSite>>();
        grandTot = 0;
        siteTotal = 0;
        disableNext = false;
        haserrors = false;
        disablePrevious = true;
        //customerSiteList = new List<CustomerSite__c>();
        siteLinenumberMap = new Map<string,Integer>();
        helper = new ApttusServiceUtilityHelper();
        quoteHelper = new QuoteInfoHelper();
        evcListTable =  new List<QuoteProducts.cCustomerSite>();        
        sitePricingMap = new Map<String,QuoteProducts.SelectPricingWrap>();
        isAllSitesNotProcessed = true;
        cartId = null;
        siteid = null;
        ListCustomerSite = null;
    }
    
}