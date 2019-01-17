public class SIHeatMapControllerV2 {
        
        //For Search GUI
        public SIHeatMapSearch searchCriteria {get; set;}
        public List<SIHeatMapSearchResults> searchResList {get; set;}
        public boolean searchResFlag {get; set;}
        
        public String compHeatMapObjId {get; set;}
        public boolean compHeatEndCustFlag {get; set;}
        public boolean compHeatMapRenderFlag {get;set;}
        
        public String[] compKeyValues {get; set;}
        public String[] dupCompKeyValues {get; set;}
        
        public Id paramId {get; set;}
        public boolean endCustView {get; set;}
        
        public String displayProductName {get; set;}
        public String displayHeaderId {get; set;}
        public Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> heatMapProducts {get; set;}
       
        public Integer endCustAcctSize {get; set;}
        public boolean isRefreshClicked {get; set;}
        public Integer noOfRecords {get; set;}
        
        //Debug block
        public String debugQueryString {get; set;}
        
        //Default Cons
        public SIHeatMapControllerV2() {
            searchCriteria = new SIHeatMapSearch();
            resetHeatMapData();
        }
        
        //method to generate the GUI
        public void getGenerateGUI() {
            try {
                System.debug('View Data :'+endCustView);
                displayHeaderId = '';
                heatMapProducts = endCustView ? 
                    SIHeatMapUtilityV2.getInstance().doFetchAssociatedProducts(paramId, '') :
                        SIHeatMapUtilityV2.getInstance().doGenerateAccountView(paramId);

                if(heatMapProducts != null && !heatMapProducts.isEmpty() && compKeyValues != null) {
                    heatMapProducts = doFilterRecordsBasedOnSearch(heatMapProducts, compKeyValues);
                    endCustAcctSize = heatMapProducts.size();    
                    doRemoveElements();
                    if(heatMapProducts != null && !heatMapProducts.isEmpty()) {
                        displayHeaderId = new List<String>(heatMapProducts.keySet()).get(0);
                        displayProductName = new List<String>
                            (heatMapProducts.get(displayHeaderId).keySet()).get(0);
                    }
                }
            } catch(Exception excep) {
                System.debug('Exception Caught :SIHeatMapControllerV2-#'+
                    excep.getLineNumber()+','+excep.getMessage());
            }
        }
        
        //method used to get the product status - contains the product/not
        public boolean getHeatMapProductsStatus() {
            return heatMapProducts != null ? heatMapProducts.isEmpty() : false;
        }
        
        //method used to remove the elements from the map
        private void doRemoveElements() {
        System.debug('Problem :'+endCustAcctSize +' '+noOfRecords);
            if((noOfRecords >= 1) && (endCustAcctSize > 3)) {
                List<String> mapKeySetSet = new List<String>();
                mapKeySetSet.addAll(heatMapProducts.keySet());
                for(Integer counter = 3; counter < mapKeySetSet.size(); counter++) {
                    heatMapProducts.remove(mapKeySetSet.get(counter));
                }
                System.debug('Inside the if block...');
            } else {
                isRefreshClicked = true;
                System.debug('Inside the else block...');
            }
        }
        
        //Invoked when the user clicks on search button
        public PageReference doSearchByCustAcct() {
            String heatMapQuery = '';
            Set<String> searchResSet = new Set<String>();
            
            try {
                resetHeatMapData();
                searchCriteria.searchType = (searchCriteria.searchMode != null && 
                    searchCriteria.searchMode.equalsIgnoreCase('account')) ? 
                        SIHeatMapControllerV2.SEARCHMODE.SP_ACCOUNT : SIHeatMapControllerV2.SEARCHMODE.END_CUSTOMER;
                
                searchCriteria.endCustViewFlag = (searchCriteria.searchType != null && 
                    searchCriteria.searchType == SIHeatMapControllerV2.SEARCHMODE.END_CUSTOMER) ? true : false;             
            
                SIHeatMapSearchResults searchResObj = new SIHeatMapSearchResults();
                
                if(doValidateHeatMapFields(searchCriteria)) {
                    
                    heatMapQuery = SIHelper.getInstance().getHeatMapResultsQuery(searchCriteria);
                    debugQueryString = heatMapQuery;
                    
                    List<AggregateResult> aggList = Database.query(heatMapQuery);
                    
                    if(!aggList.isEmpty()) {
                        for(AggregateResult aggObj : aggList) {
                            searchResObj = new SIHeatMapSearchResults(searchResSet.size() + 1, 
                                    searchCriteria.endCustViewFlag ? (String) 
                                        aggObj.get('endCustId') : (String) aggObj.get('acctId') , 
                                    searchCriteria.endCustViewFlag ? (String) 
                                        aggObj.get('endCustName') : (String) aggObj.get('acctName'),
                                    searchCriteria.endCustViewFlag ? (Boolean) 
                                        aggObj.get('namedAccount') : false, searchCriteria);
                            if(!searchResSet.contains(searchResObj.toString())) {
                                searchResSet.add(searchResObj.toString());
                                searchResList.add(searchResObj);
                            }
                        }
                        searchResList.sort();
                        searchResFlag = true;
                    }
                    if(searchResList.isEmpty()) {
                        doAddErrorMsg(SIConstants.HEAT_MAP_VALIDATION_ERRORS[2]);
                    }
                    
                }
            } catch(Exception excep) {
                System.debug('Exception Caught :'+excep.getMessage()+', Line#'+excep.getLineNumber());
                throw excep;
            }
            return null;
        }
        
        //Invoked when the user clicks on clear button
        public PageReference doResetHeatMap() {
            if(null != searchCriteria) {
                searchCriteria = new SIHeatMapSearch();
            }
            resetHeatMapData();
            return null;
        }
        
        //method to reset
        private void resetHeatMapData() {
            searchResList = new List<SIHeatMapSearchResults>();
            searchResFlag = false;
            compHeatMapObjId = '';
            compHeatEndCustFlag = false;
            compHeatMapRenderFlag = false;
            heatMapProducts = new Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>>();
            compKeyValues = new String[3];
            dupCompKeyValues = new String[3];
            endCustAcctSize = 0;
            isRefreshClicked = false;
            noOfRecords = 0;
        }
        
        //method to assign the values to the component objects 
        public PageReference doHeatMapRendering() {
            try {
                if(doValidateHeatMapFields(searchCriteria)) {
                    compHeatMapRenderFlag = true;
                    doAssignValuesArr();
                    getGenerateGUI();
                }
            } catch(Exception excep) {
                System.debug('Exception Caught :'+excep.getMessage()+', #'+excep.getLineNumber());
            }
            return null;
        }
        
        //Method to validate the heatmap search criteria fields
        private boolean doValidateHeatMapFields(SIHeatMapSearch searchObj) {
            Integer selectedProducts = 0;
            
            if(searchObj.searchType == SEARCHMODE.END_CUSTOMER) {
                if(searchObj.endCustomerName != null && searchObj.endCustomerName.length() <=0) {
                    doAddErrorMsg(SIConstants.HEAT_MAP_VALIDATION_ERRORS[0]);
                }
            } else {
                if(searchObj.spAccountName != null && searchObj.spAccountName.length() <=0) {
                    doAddErrorMsg(SIConstants.HEAT_MAP_VALIDATION_ERRORS[1]);
                }
            }
            
            //For Product Selection validation
            for(SIProductType productType : searchObj.productList) {
                if(productType.selected) {
                    selectedProducts ++;
                }
            }
            if(selectedProducts <= 0) {
                doAddErrorMsg(SIConstants.HEAT_MAP_VALIDATION_ERRORS[3]);
            }
            
            return ApexPages.hasMessages() ? false : true;
        }
        
        //Method to add the validation messages
        private void doAddErrorMsg(String errorMsg) {
                ApexPages.Message errorInfoMsg = new ApexPages.Message(ApexPages.Severity.INFO, errorMsg);
                ApexPages.addMessage(errorInfoMsg);     
        }        

        //A method used to assign the values that too be passed to the component
        private void doAssignValuesArr() {
            if(null != searchCriteria) {
                if(searchCriteria.spAccountName.length() > 0 && searchCriteria.endCustomerName.length() > 0) {
                    compKeyValues[0] = 'spAccountName^' + searchCriteria.spAccountName;
                    compKeyValues[1] = 'endCustomerName^' + searchCriteria.endCustomerName;
                } else {
                    compKeyValues[0] = 'spAccountName^' + ' ';
                    compKeyValues[1] = 'endCustomerName^' + ' ';
                }
                
                if(searchCriteria.productList != null && !searchCriteria.productList.isEmpty()) {
                    String productStr = 'products^';
                    for(SIProductType prodObj : searchCriteria.productList) {
                        if(prodObj.selected) {
                            productStr += prodObj.productName +'|';
                        }
                    }
                    compKeyValues[2] = productStr;
                }
            }                                   
        }
        
        //method used to filter the records based on the search
        private Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> doFilterRecordsBasedOnSearch(
            Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> dupHeatMapProducts,
            String[] dupCompKeyValuesArrObj) {
            Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> filteredHeatMapProducts =
                new Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>>();
            
            if(null != dupCompKeyValuesArrObj && dupCompKeyValuesArrObj[0] != null && dupCompKeyValuesArrObj[1] != null) {          
                String spaccountName = dupCompKeyValuesArrObj[0].split('\\^')[1].length() > 0 
                    ? dupCompKeyValuesArrObj[0].split('\\^')[1] : '';
                String endCustomerName = dupCompKeyValuesArrObj[1].split('\\^')[1].length() > 0 ? 
                    dupCompKeyValuesArrObj[1].split('\\^')[1] : '';
                
                if(spaccountName.length() > 0 && endCustomerName.length() > 0) {
                    for(String spEndCustObjKey : dupHeatMapProducts.keySet()) {
                        for(String productObjKey : dupHeatMapProducts.get(spEndCustObjKey).keySet()) {
                            if(dupHeatMapProducts.get(spEndCustObjKey).get(productObjKey).endCustName
                                .toLowerCase().contains(endCustomerName.toLowerCase()) 
                                &&
                                dupHeatMapProducts.get(spEndCustObjKey).get(productObjKey).accountName
                                .toLowerCase().contains(spaccountName.toLowerCase())) {
                                filteredHeatMapProducts.put(spEndCustObjKey, dupHeatMapProducts.get(spEndCustObjKey));
                                break;
                            }
                        } //end for prod keys
                    } //end for end customers/sp account
                }
                return  doFilterByProducts(
                    filteredHeatMapProducts.isEmpty() ? dupHeatMapProducts : filteredHeatMapProducts,
                    dupCompKeyValuesArrObj[2].split('\\^')[1]
                );
            }
            return dupHeatMapProducts;
        }
        
        //Method used to get the products based on the products selection
        private Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> doFilterByProducts
            (Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> dupHeatMapProducts, String productList) {

            Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> filteredHeatMapProducts =
                new Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>>();
            
            if(productList.length() > 0) {
                for(String keyObj : dupHeatMapProducts.keySet()) {
                    filteredHeatMapProducts.put(keyObj, new Map<String, SICastIronFactory.ServiceProductDecorator>());
                    for(String prodKeyName : productList.split('\\|')) {
                        for(String prodName : dupHeatMapProducts.get(keyObj).keySet()) {
                            if(prodKeyName.equalsIgnoreCase(prodName)) {
                                filteredHeatMapProducts.get(keyObj).put(prodKeyName, 
                                    dupHeatMapProducts.get(keyObj).get(prodKeyName));
                            }
                        }
                    }
                } 
                
            } else {
                return dupHeatMapProducts;
            }
            return filteredHeatMapProducts;
        } 

        //ENUM - Search mode - By End Customer / By SP Account
        public enum SEARCHMODE {END_CUSTOMER, SP_ACCOUNT}

        // A decorator class to hold all the products
        public class SIProductType implements Comparable {
            public Integer productCounter {get; set;}
            public String productName {get; set;}
            public boolean selected {get; set;}
            public SIProductType() {
                productCounter = 0;
                productName  = '';
                selected = true;
            }
            
            public SIProductType(String productName, Integer productCounter) {
                this();
                this.productCounter = productCounter;
                this.productName = productName;
            }
            
            override
            public String toString() {
                return productCounter +'|'+ productName +'|'+ selected;
                
            }
            
            public Integer compareTo(Object objectCompare) {
                SIProductType toCompareObj = (SIProductType) objectCompare;
                return this.productName.compareTo(toCompareObj.productName);
            }
        }           
        
        //A decorator class which contains the search fields
        public class SIHeatMapSearch {
            public String endCustomerName {get; set;}
            public String spAccountName {get; set;}
            public String searchMode {get; set;} //By SPAccount/End Customer
            public SIHeatMapControllerV2.SEARCHMODE searchType ;
            public List<SIProductType> productList {get; set;}
            
            public boolean endCustViewFlag {get;set;}
            public boolean bothInputtedFlag {get;set;}
            
            //Defaults Cons
            public SIHeatMapSearch() {
                endCustomerName = '';
                spAccountName = '';
                searchMode = '';
                endCustViewFlag = false;
                bothInputtedFlag = false;
                productList = new List<SIProductType>();
                populateProductNames();
            }
            
            override
            public String toString() {
                return searchMode +'|'+ (searchType == SIHeatMapControllerV2.SEARCHMODE.END_CUSTOMER 
                    ? endCustomerName : spAccountName) + '|'+ endCustViewFlag;
            }
            
            //method generates the recordtypes - to be displayed on the GUI
            private void populateProductNames() {
                SIProductType prodTypeObj = null;
                for(String recordTypeStr : SIHelper.getRecordTypeNames('SPProduct__c',new String[]{'Products'}, false)) {
                    productList.add(new SIProductType(recordTypeStr, productList.size() + 1));
                }
                productList.sort();
            }
        }
        
        //A decorator class which holds the search results
        public class SIHeatMapSearchResults implements Comparable {
            public Integer objectCounter {get; set;} 
            public String objectSfdcId {get; set;}
            public String objectName {get; set;}
            public boolean namedAccount {get; set;}
            public SIHeatMapSearch searchCriteriaObj {get; set;}
            //no args
            public SIHeatMapSearchResults() {
                objectCounter = 0;
                objectSfdcId = '';
                objectName = '';
                namedAccount = false;
                searchCriteriaObj = new SIHeatMapSearch();
            }
            
            //cons with params
            public SIHeatMapSearchResults(Integer objectCounter, String objectSfdcId, 
                String objectName, boolean namedAccount, SIHeatMapSearch searchCriteriaObj) {
                this();
                this.objectCounter = objectCounter;
                this.objectSfdcId = objectSfdcId;
                this.objectName = objectName;
                this.namedAccount = namedAccount;
                this.searchCriteriaObj = searchCriteriaObj;
            }
            
            //Objects to compare
            public Integer compareTo(Object objectToCompare) {
                SIHeatMapSearchResults objectToCompareObj = (SIHeatMapSearchResults) objectToCompare;
                
                if(this.objectSfdcId.compareTo(objectToCompareObj.objectSfdcId) == 0 &&
                    (this.objectName.compareTo(objectToCompareObj.objectName) == 0)) {
                    return 0;
                }
                
                if(this.objectSfdcId.compareTo(objectToCompareObj.objectSfdcId) > 0 &&
                    (this.objectName.compareTo(objectToCompareObj.objectName) > 0)) {
                    return 1;
                }
                return -1;
            }
            
            override
            public String toString() {
                String concatedStr = objectSfdcId +'|'+objectName;
                if(searchCriteriaObj.searchType == SIHeatMapControllerV2.SEARCHMODE.END_CUSTOMER)   {
                    concatedStr += '|' +namedAccount;           
                }            
                return concatedStr;
            }   
        }
}