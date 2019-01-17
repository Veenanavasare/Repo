//A HeapMap Controller
public class SIHeatMapController {
    
    public String accountName {get; set;}
    public String endCustomerName {get; set;}

    public String searchType {get; set;}
    public String searchResStr {get; set;}
    
    public boolean isSearResDisplay {get; set;}
    public boolean isHeatMapDisplay {get; set;}
    public boolean isErrorDisplay {get; set;}
    
    public String headerDisplayStr {get; set;}
    public String heatMapObjId {get; set;}
    
    public Map<Id, SPProduct__c> heatResMap {get; set;}
    
    public String accountId {get; set;}
    public String objectTypeName {get; set;}
    
    public List<SIHeatMapUtility.SIHeatMapDto> persistedHeatMapList {get; set;}
    
    public List<SIHeatMapProduct> heatMapProducts {get; set;}
    public boolean isProductSelectAll {get; set;}
    
    //public ApexPages.StandardSetController con{get;set;} //For pagination
      
    //default cons
    public SIHeatMapController() {
        heatResMap = new Map<Id, SPProduct__c>();
        heatMapObjId = '';
        endCustomerName = '';
        accountName = '';
        isErrorDisplay = false;
        persistedHeatMapList = new List<SIHeatMapUtility.SIHeatMapDto>();
        heatMapProducts = SIHelper.getProducts();
    }
    
    //params cons
    public SIHeatMapController(String accountId) {
        this.accountId = accountId;
    }
    
    //To get search results
    public PageReference getSearchResults() {
        isSearResDisplay = false;
        isHeatMapDisplay = false;
        isErrorDisplay = false;
        heatResMap = new Map<Id, SPProduct__c>();
        heatMapObjId = '';

        headerDisplayStr = searchType.equalsIgnoreCase('account') ? 'SP Account' : 'End Customer';      
        searchResStr = searchType.equalsIgnoreCase('account') ? 'Account Search Results' : 'End Customers Search Results';
        
        if(null != searchType && searchType.length() > 0) {
            if(searchType.equalsIgnoreCase('account')) {
                if(null != accountName && accountName.length() > 0) {
                    heatResMap = SIHelper.fetchHeatMapRes('account', accountName, endCustomerName);
                    
                    
                }
            }
            if(searchType.equalsIgnoreCase('endCustomer')) {
                if(null != endCustomerName && endCustomerName.length() > 0) {
                    heatResMap = SIHelper.fetchHeatMapRes('endCustomer', accountName, endCustomerName);
                    
                }
            }
        }        
        if(heatResMap.size() > 0) {
            isSearResDisplay = true;
        } else {
                isErrorDisplay = true;
        }
              
        System.debug('Value :'+isProductSelectAll);
        return null;
    }
    
    //method used to cancel the searchResults
    public PageReference doCancelSearchAndSearchRes() {
        heatResMap = new Map<Id, SPProduct__c>();
        endCustomerName = '';
        accountName = '';
        isSearResDisplay = false;
        isErrorDisplay = false;
        return null;
    }
    
    //Generate a Heat Map
    public PageReference doHeatMap() {
        persistedHeatMapList = new List<SIHeatMapUtility.SIHeatMapDto>();
        System.debug('HeatMapObj :'+heatMapObjId);
        isHeatMapDisplay = false;
        
        if(searchType.equalsIgnoreCase('account')) {
            persistedHeatMapList = fetchSPAccountsHeatMap(heatMapObjId);

        } else {
            persistedHeatMapList = new SIHeatMapUtility(heatMapObjId).persistedHeatMapList;        
        }

        if(persistedHeatMapList !=null && !persistedHeatMapList.isEmpty()) {
            isHeatMapDisplay = true;
            if((null != accountName && accountName.length() > 0) && 
                (null != endCustomerName && endCustomerName.length() > 0)) {
                persistedHeatMapList = SIHelper.getInstance().
                        modifyPersistedHeatMapList(accountName, endCustomerName, persistedHeatMapList);
                System.debug('Both Criteria :'+persistedHeatMapList.size());
            }
        }
        
        return null;
    }
 
    //Method used to get the heatmap list related to the sp accounts
    public List<SIHeatMapUtility.SIHeatMapDto> fetchSPAccountsHeatMap(String accountId) {
        List<SIHeatMapUtility.SIHeatMapDto> heatMapList = new List<SIHeatMapUtility.SIHeatMapDto>();
        Set<String> accountStrSet = new Set<String>();
        SIHelper helperObj = SIHelper.getInstance();
        
        try {
            List<SPProduct__c> productList = [
                Select deal__r.Name, deal__r.End_Customer__r.Name,deal__r.StageName,deal__r.Account.Id,
                deal__r.End_Customer__r.Id,deal__r.Account.Name, RecordType.Name,CreatedDate from SPProduct__c 
                Where deal__r.Account.Id = :accountId order by CreatedDate Asc, 
                deal__r.Account.Name,RecordType.Name
            ];
            
            for(SPProduct__c productObj : productList) {
                accountStrSet.add(productObj.deal__r.Account.Id +'~'+productObj.deal__r.End_Customer__r.Name 
                        +'~'+productObj.deal__r.End_Customer__r.Id);
            }
                        
            heatMapList = helperObj.fetchSPAccountsHeatMap(accountStrSet);
        } catch(Exception excep) {
            System.debug('Exception Caught fetchSPAccountsHeatMap :'+excep.getMessage()); 
        }
        return heatMapList;
    }
    
    //An inner class to handle the product search
    public class SIHeatMapProduct {
        public Integer productCounter {get; set;}
        public String productName {get; set;}
        public boolean isSelected {get; set;}
        
        /*public SIHeatMapProduct() {
            productCounter = 0;
            productName = '';
            isSelected = false;
        }*/
        
        public SIHeatMapProduct(Integer productCounter, String productName, boolean isSelected) {
            this.productCounter = productCounter;
            this.productName = productName;
            this.isSelected = isSelected;
        }
        
        override
        public String toString() {
            return productCounter +'|'+ productName +'|'+isSelected;
        }
    }
}