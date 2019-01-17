public class SIHeatMapUtility {
    private String sourceId = '';
    public List<SIHeatMapDto> persistedHeatMapList {get; set;}
    
    public SIHeatMapUtility() {
        sourceId = ApexPages.currentPage().getParameters().get('sourceId');
        persistedHeatMapList = new List<SIHeatMapDto>();
        doGenerateHeatMapGrid(sourceId);
    }
    
    public SIHeatMapUtility(String sourceId) {
        this.sourceId = sourceId;
        doGenerateHeatMapGrid(this.sourceId);
    }
    
    //HeatMap rendering
    public void doGenerateHeatMapGrid(String sourceId) {
        List<SPProduct__c> productsList = new List<SPProduct__c>();
        List<SPProduct__c> productSetWODup = new List<SPProduct__c>();
        SIHeatMapDto heatMapObj = null;
        
        Set<String> idSet = new Set<String>();
        List<SIHeatMapDto> heatMapList = new List<SIHeatMapDto>();
        
        try {
            productsList = [
                Select deal__r.Name, deal__r.End_Customer__r.Name,deal__r.StageName,deal__r.Account.Id, 
                deal__r.End_Customer__r.Id, deal__r.End_Customer__r.Named_Account__c, deal__r.Account.Name, 
                Deal_Status__c, RecordType.Name,CreatedDate from SPProduct__c 
                Where deal__r.End_Customer__r.Id = :sourceId and Deal_Status__c <> null 
                and deal__r.StageName <> :SIConstants.PRODUCT_EXPIRY order by CreatedDate Asc, 
                deal__r.Account.Name,RecordType.Name
            ];
            productSetWODup = removeListDuplicates(productsList);
            System.debug('Values in productSetWODup :'+productSetWODup);
            
            //Iterate a list without dup
            for(SPProduct__c productObj : productSetWODup) {
                if(idSet.add(productObj.deal__r.Account.Id)) {
                    heatMapObj = new SIHeatMapDto(productObj.deal__r.Account.Name,productObj.deal__r.Name,
                        productObj.deal__r.End_Customer__r.Name,productObj.deal__r.StageName,
                        productObj.deal__r.Account.Id, productObj.deal__r.End_Customer__r.Named_Account__c,
                        productObj.deal__r.End_Customer__r.Id);
                    for(String staticProdName : SIConstants.HEAT_MAP_PROD_NAMES) {
                        
                        //for current sp
                        if(staticProdName.equalsIgnoreCase(productObj.RecordType.Name)) {
                            heatMapObj.productCodeMap.put(staticProdName, 'Orange');
                            if(heatMapObj.oppStageName.equalsIgnoreCase('Order Submitted')) {
                                heatMapObj.productCodeMap.put(staticProdName, '#8A0808'); //dark red
                            }
                        } else {
                            heatMapObj.productCodeMap.put(staticProdName, 'Green');
                            for(SPProduct__c currentProductObj : productSetWODup) {
                                if(heatMapObj.accountId.equalsIgnoreCase(currentProductObj.deal__r.Account.Id)) {
                                    if(staticProdName.equalsIgnoreCase(currentProductObj.RecordType.Name)) {
                                    	heatMapObj.productCodeMap.put(staticProdName, 'Orange');
                                        if(currentProductObj.deal__r.StageName.equalsIgnoreCase('Order Submitted')) {
                                            heatMapObj.productCodeMap.put(staticProdName, '#8A0808'); //dark red
                                        }
                                    }       
                                }                               
                            }
                        } //end of else
                        
                        //For Named Account
                        if(heatMapObj.isNamedAccount) {
                        	heatMapObj.productCodeMap.put(staticProdName, 'Blue');
                        }
                    }
                    heatMapList.add(heatMapObj);                    
                }
            }   
                            
            System.debug('Actual List :'+heatMapList);
            changeGridValues(heatMapList);
            
        } catch(Exception excep) {
            System.debug('Exception Caught in doGenerateHeatMapGrid :'+excep.getMessage());
        }
    }
    
    //method used to remove the dupli
    private List<SPProduct__c> removeListDuplicates(List<SPProduct__c> productsList) {
        List<SPProduct__c> productSetWODup = new List<SPProduct__c>();
        Set<String> productSetListTemp = new Set<String>();

        SPProduct__c currentProduct = new SPProduct__c();
        SPProduct__c otherProduct = new SPProduct__c();
        String productName = '';
        
        for(Integer currentCounter = 0; currentCounter < productsList.size(); currentCounter++) {
            currentProduct = productsList.get(currentCounter);
            productName = currentProduct.deal__r.Account.Name+'~'+currentProduct.RecordType.Name;
            if(productSetListTemp.add(productName)) {
                productSetWODup.add(currentProduct);
            }
        }
        return productSetWODup;     
    }
    
    //A method used to change the colors
    public void changeGridValues(List<SIHeatMapDto> heatMapDtoList) {
        persistedHeatMapList = new List<SIHeatMapDto>();
        SIHeatMapDto currentHeatMapObj = null;
        SIHeatMapDto restHeatMapObj = null;
        Set<String> mapKeySet = null;
        
        try {
            if(null != heatMapDtoList && !heatMapDtoList.isEmpty()) {
                persistedHeatMapList = heatMapDtoList;
                for(Integer currentObjCounter = 0; currentObjCounter < persistedHeatMapList.size(); currentObjCounter++) {
                    currentHeatMapObj = (SIHeatMapDto) persistedHeatMapList.get(currentObjCounter);
                    mapKeySet = currentHeatMapObj.productCodeMap.keySet();
                    for(String keyString : mapKeySet) {
                        
                        //Traversing from current to bottom
                        for(Integer restObjCounter = currentObjCounter + 1; restObjCounter 
                            < persistedHeatMapList.size(); restObjCounter++) {
                            restHeatMapObj = (SIHeatMapDto) persistedHeatMapList.get(restObjCounter);
                            if(restHeatMapObj.isNamedAccount) {
                            	restHeatMapObj.productCodeMap.put(keyString, 'Blue'); //Named Account
                            } else if(currentHeatMapObj.productCodeMap.get(keyString).equalsIgnoreCase('Orange')) {
                                if(restHeatMapObj.productCodeMap.get(keyString).equalsIgnoreCase('Orange') ||
                                    restHeatMapObj.productCodeMap.get(keyString).equalsIgnoreCase('Green')) {   
                                    restHeatMapObj.productCodeMap.put(keyString, 'Yellow');
                                }
                            } else if(currentHeatMapObj.productCodeMap.get(keyString).equalsIgnoreCase('#8A0808')) {
                                if(restHeatMapObj.productCodeMap.get(keyString).equalsIgnoreCase('Orange') ||
                                    restHeatMapObj.productCodeMap.get(keyString).equalsIgnoreCase('Green') ||
                                    restHeatMapObj.productCodeMap.get(keyString).equalsIgnoreCase('Yellow')) {  
                                    restHeatMapObj.productCodeMap.put(keyString, 'Red');
                                }
                            }
                            System.debug('Selenium');
                        } // end for Traversing from current to bottom
                        
                        //Traversing from current to top
                        for(Integer restObjCounter = currentObjCounter - 1; restObjCounter >=0; restObjCounter--) {
                            restHeatMapObj = (SIHeatMapDto) persistedHeatMapList.get(restObjCounter);
                            if(restHeatMapObj.isNamedAccount) {
                            	restHeatMapObj.productCodeMap.put(keyString, 'Blue'); //Named Account
                            }else if(currentHeatMapObj.productCodeMap.get(keyString).equalsIgnoreCase('Orange')) {
                                if(restHeatMapObj.productCodeMap.get(keyString).equalsIgnoreCase('Orange') ||
                                    restHeatMapObj.productCodeMap.get(keyString).equalsIgnoreCase('Green')) {   
                                    restHeatMapObj.productCodeMap.put(keyString, 'Yellow');
                                }
                            } else if(currentHeatMapObj.productCodeMap.get(keyString).equalsIgnoreCase('#8A0808')) {
                                if(restHeatMapObj.productCodeMap.get(keyString).equalsIgnoreCase('Orange') ||
                                    restHeatMapObj.productCodeMap.get(keyString).equalsIgnoreCase('Green') ||
                                    restHeatMapObj.productCodeMap.get(keyString).equalsIgnoreCase('Yellow')) {  
                                    restHeatMapObj.productCodeMap.put(keyString, 'Red');
                                }
                            }
                        } // end for Traversing from current to top
                        
                    } //end for map keys
                } //end for current object
            }
        } catch(Exception excep) {
            System.debug('Exception Caught in changeGridValues :'+excep.getMessage());
            System.debug('Exception Occured at line # :'+excep.getLineNumber());
        }
        System.debug('Modified List :'+persistedHeatMapList);
    }
    
    //A class which holds the HeatMap Data
    public class SIHeatMapDto {
        public String accountName {get; set;}
        public String oppName {get; set;}
        public String endCustomerName {get; set;}
        public String oppStageName {get; set;}
        public String accountId {get; set;}
        public String endCustomerId {get; set;}
        public boolean isNamedAccount {get; set;}
        
        public Map<String, String> productCodeMap {get; set;}
        
        //Defaults Cons
        public SIHeatMapDto() {
            this.accountName = '';
            this.oppName = '';
            this.endCustomerName = '';
            this.oppStageName = '';
            this.accountId = '';
            this.endCustomerId = '';
            this.isNamedAccount = false;
            
            productCodeMap = new Map<String, String>();
            for(String prodName : SIConstants.HEAT_MAP_PROD_NAMES) {
                this.productCodeMap.put(prodName, '');
            }
        }
        
        //Params cons
        public SIHeatMapDto(String accountName, String oppName, 
            String endCustomerName, String stageName, String accountId, 
            boolean isNamedAccount, String endCustomerId) {
            this();
            this.accountName = accountName;
            this.oppName = oppName;
            this.endCustomerName = endCustomerName;
            this.oppStageName = stageName;
            this.accountId = accountId;
            this.endCustomerId = endCustomerId;
            
            this.isNamedAccount = isNamedAccount;
            system.debug('isNamedAccount :'+isNamedAccount);
        }
        
        override
        public String toString() {
            return accountName +'|'+oppName+'|'+endCustomerName+'|'+oppStageName+'|'+accountId +'|'+productCodeMap;
        }
    }
}