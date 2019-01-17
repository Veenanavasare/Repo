public class QuoteProducts {
    
    public class ProductOption{
        public String componentId{get;set;}
        public String productId{get;set;}
        public String ProductOptionGroupId{get;set;}
        public String name{get;set;}
        public String selectedProduct{get;set;}
        public String interfaceType{get;set;}
        public String accessType{get;set;}
        public Decimal price{get;set;}
        public Boolean showOption{get;set;}
        public Boolean showListOption{get;set;}
        public Boolean isSelected{get;set;}
        public Boolean deletionRequired{get;set;}
        public Integer minOptions{get;set;}
        public Integer maxOptions{get;set;}
        public List<ProductOption> portTypeList {get;set;}
        public List<SelectOption> prodOptnsLst {get;set;}
        public List<ProductOption> portSpeedList {get;set;}
        public List<ProductOption> accessSpeedList {get;set;}
        public List<ProductOption> installOptionList {get;set;}
        public List<ProductOption> minBandList {get;set;}
        public List<ProductOptionAtrribute> prodOptAttrLst {get;set;}
    }
    
    public class ProductOptionAtrribute {
        public String attrName {get;set;}
        public String selectedAttr {get;set;}
        public List<SelectOption> attrSelectListOptions {get;set;}
    }
    
     public class SelectPricingWrap{
        public String portTypeName {get;set;}
        public String portSpeedId {get;set;}
        public String accessSpeedId {get;set;}
        public String portTypePrdId {get;set;}
        public String linenumber {get;set;}
        public List<SelectOption> prodOptnsLst {get;set;}
        public List<String> optnsLstValues {get;set;}
        public Double oneYrPrice {get;set;}
        public Double threeYrPrice {get;set;}
        public Boolean isSelected {get;set;}
        public Map<String,String> optGrpSelectedValMap {get;set;}
        public String prodOptOptnsVal {get;set;}
        public ProductOption options;
        public ProductOption portType;
        public ProductOption portSpeed;
        public ProductOption accessSpeed;
        public ProductOption installOption;
        public Boolean isProcessed{get;set;}
        public ProductOption minBand;
        public List<ProductOption> optionsList {get;set;}
        public Boolean disableApplyBtn {get;set;}
        public string selectedCustomer {get;set;}
        public SelectPricingWrap(){
        
        }
        
        
    }
    
    // code for select check boxes on the left panel
    public class cCustomerSite {
        public CustomerSite__c custSiteIns {get; set;}
        public Boolean selected {get; set;}
        public String spanClass {get;set;} //glyphicon glyphicon-ok
        public Boolean isProcessed{get;set;}
        public Integer linecount;
        public Decimal linenumber;
        public String SiteConnectionType {get;set;}
        public Boolean eligibleSelected {get;set;}
        public String vasaResStr {get;set;}
        public String pricingStatus {get;set;}
        public String CIRVal {get;set;}
        public String CIRSelectedId {get;set;}
        public Boolean showSites {get;set;}
        public list<selectoption> CIRSubset {get;set;}
        public AT_T_Customer_Site_Quote__c EVCfrom {get;set;}
        public AT_T_Customer_Site_Quote__c EVCto {get;set;}
        public String CoS {get;set;}
        public string EVCCir {get;set;}
        public string Name {get;set;}
        public Integer COSVal {get;set;}
        public list<SelectOption> RelatedCust = new List<SelectOption>();
        public string selectedCustomer {get;set;}
        public decimal attCustomerSiteTotal {get;set;}
        public decimal attCustomerSiteOneTime {get;set;}
        public string cellFilterSitesClass {get;set;}
        public String IPFLEXFlag {get; set;}
        public Boolean eligibleSFlag{get;set;}
        public Boolean siteEnabled{get;set;} 
        public Boolean isIglooReviewReq{get;set;}
        public Boolean isSoftDel{get;set;}
        public Decimal aseMaxSpeedBroadband;
        public Decimal aseMaxSpeedBasic; 
        public String aFBRPortSpeed;
        public String aEoCUPortSpeed;
        public Boolean OORSEExpired{get; set;}
        public Boolean isOORSESite{get; set;}   
        public String speedsNotAvailableITPA{get;set;}
        public Boolean wirelinePromoApplied{get;set;}
              
        public cCustomerSite(CustomerSite__c c){
            custSiteIns = c;
            selected = false;
            isProcessed = false;           
            spanClass = 'display:none; color:green;';
            linenumber = 0;
            eligibleSelected = false;
            IPFLEXFlag = c.IPFLEX_Availability_Flag__c;
            eligibleSFlag = false;
            siteEnabled=true;
            isIglooReviewReq = false;
            isSoftDel = false;
            OORSEExpired=false;
            isOORSESite=false;
            wirelinePromoApplied = false;
        }
        
        public cCustomerSite(cCustomerSite cs){
            this.custSiteIns = cs.custSiteIns;
            this.linenumber = cs.linenumber;
            this.isProcessed = cs.isProcessed;           
            this.SiteConnectionType = cs.SiteConnectionType;
            this.vasaResStr = cs.vasaResStr;
            this.eligibleSelected = cs.eligibleSelected;
            this.IPFLEXFlag = cs.IPFLEXFlag;
            this.eligibleSFlag = cs.eligibleSFlag;
            this.siteEnabled= cs.siteEnabled; 
            this.speedsNotAvailableITPA = cs.speedsNotAvailableITPA;
        }
    }
    
    public Class FlagStatus{
        public Boolean vlanChecked {get;set;}
        public Boolean manageRouterChecked {get;set;}
        public Boolean hicapChecked {get;set;}
    }  
}