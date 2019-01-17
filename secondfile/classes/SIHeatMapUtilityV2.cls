public class SIHeatMapUtilityV2 {
    private static SIHeatMapUtilityV2 mapUtilityV2 = null;
    private static List<String> productNamesList = null;
     
    private SIHeatMapUtilityV2() {}
    
    public static SIHeatMapUtilityV2 getInstance() {
        if(null == mapUtilityV2) {
            mapUtilityV2 = new SIHeatMapUtilityV2();
            productNamesList = SIHelper.getRecordTypeNames('SPProduct__c',new String[]{'Products'}, false);
        }
        return mapUtilityV2;
    }
    
    //Method used to fetch the products based on the end customer
    public Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> doFetchAssociatedProducts
    (String endCustomerId, String accountIdParam) {
        Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> accountsMap = new 
            Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>>();
        SICastIronFactory.ServiceProductDecorator productDecObj = null;
        List<SICastIronFactory.ServiceProductDecorator> serviceProductsList = new 
            List<SICastIronFactory.ServiceProductDecorator>();
        
        try {
            
            //Query to fetch the results
            for(AggregateResult ag :[Select Deal__r.Account.Id acctId, Deal__r.Account.Name acctName,RecordType.Name 
                prodFamilyName,Deal_Status__c prodDealStatus,Deal__r.End_Customer__r.Id endCustId,Deal__r.End_Customer__r.Name 
                endCustName, Deal__r.End_Customer__r.Named_Account__c namedAccount,Deal_Exclusivity_Date__c dealExDate,
                Count(Id) prodCount from SPProduct__c
                Where Deal__r.End_Customer__c = :endCustomerId
                and deal__r.Account.Id <> null and Deal__r.End_Customer__r.Id <> null and 
                RecordType.Name <> 'Products'
                Group By Deal__r.Account.Id, Deal__r.Account.Name,RecordType.Name,Deal_Status__c,
                Deal__r.End_Customer__r.Id, Deal__r.End_Customer__r.Name,Deal__r.End_Customer__r.Named_Account__c,
                Deal_Exclusivity_Date__c 
                Order By Deal__r.Account.Name,RecordType.Name]) {
                
                productDecObj = new SICastIronFactory.ServiceProductDecorator
                (
                    serviceProductsList.size() + 1, String.valueOf(ag.get('acctId')), String.valueOf(ag.get('acctName')), 
                    String.valueOf(ag.get('prodFamilyName')), String.valueOf(ag.get('prodDealStatus')), 
                    String.valueOf(ag.get('endCustId')),String.valueOf(ag.get('endCustName')), 
                    Boolean.valueOf(ag.get('namedAccount')),Integer.valueOf(ag.get('prodCount')),
                    Date.valueOf(ag.get('dealExDate') != null ? ag.get('dealExDate') : Date.today())                
                );
                serviceProductsList.add(productDecObj);
            }
            serviceProductsList.sort();
            
            //block to put in the datastructure
            for(SICastIronFactory.ServiceProductDecorator decObj : serviceProductsList) {
                if(accountsMap.get(decObj.accountId) == null) {
                    accountsMap.put(decObj.accountId, new Map<String, SICastIronFactory.ServiceProductDecorator>());
                }
                accountsMap.get(decObj.accountId).put(decObj.productFamilyName, decObj); 
            }
            System.debug('Debugged Code:'+accountsMap);
            accountsMap = modifyHeatMapRes(accountsMap);
            accountsMap = modifyHeatMapColors(accountsMap);

            if(null != accountIdParam && accountIdParam.length() > 0 && !accountsMap.isEmpty()) {
                accountsMap = doFetchAssociatedSPAccount(accountsMap, endCustomerId, accountIdParam);
            }
            
            accountsMap = doProductsExclusitivityDates(accountsMap);
                                
        } catch(Exception excep) {
            System.debug('Exception Caught :: SIHeatMapUtilityV2 Vijay'+excep.getMessage() +'#Line #'+excep.getLineNumber());
        }   
        
        return accountsMap;
    }
    
    //method to modify the existing resultset
    private Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> modifyHeatMapRes(
        Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> accountsMap) {
        SICastIronFactory.ServiceProductDecorator tempProductDeco = null;

        //Block to make the products available
        for(String accountId : accountsMap.keySet()) {
            tempProductDeco = new SICastIronFactory.ServiceProductDecorator();
            for(String productFamilyName : productNamesList) {
                if(null != accountsMap.get(accountId).get(productFamilyName)) {
                    tempProductDeco = accountsMap.get(accountId).get(productFamilyName);
                    break;
                }
            }
            
            for(String productFamilyName : productNamesList) {
                if(null == accountsMap.get(accountId).get(productFamilyName)) {
                    accountsMap.get(accountId).put(productFamilyName,
                        new SICastIronFactory.ServiceProductDecorator(
                            0, accountId, tempProductDeco.accountName, 
                            productFamilyName, '',  
                            tempProductDeco.endCustId,tempProductDeco.endCustName, 
                            tempProductDeco.isNamedAccount,0,Date.today()                
                        )
                    );
                } 
            }
        }   
        return accountsMap;
    } 
    
    //method to modify the colors based on the heatmap logic for the associated sp accounts
    private Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> modifyHeatMapColors(
        Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> accountsMap) {
        String currentColorCode = '';
        System.debug('modifyHeatMapColors :'+accountsMap);
        if(null != accountsMap) {
            //For Light Red
            for(String productFamilyName : productNamesList) {
                for(String accountId : accountsMap.keySet()) {
                    if(accountsMap.get(accountId).get(productFamilyName).
                        colorNameOrCode.equalsIgnoreCase('#8A0808')) {
                        for(String traverseAccountId : accountsMap.keySet()) {
                            if(!accountId.equalsIgnoreCase(traverseAccountId)) {
                                currentColorCode = accountsMap.get(traverseAccountId).get(productFamilyName).colorNameOrCode;                           
                                if(!currentColorCode.equalsIgnoreCase('#8A0808')) { //||!currentColorCode.equalsIgnoreCase('Green')) { 
                                    accountsMap.get(traverseAccountId).get(productFamilyName).colorNameOrCode = 'Red';
                                }
                            }
                        }
                        
                    }
                }
            }
            //For Yellow (With/without) existence of products
            for(String productFamilyName : productNamesList) {
                for(String accountId : accountsMap.keySet()) {
                    if(accountsMap.get(accountId).get(productFamilyName).
                        colorNameOrCode.equalsIgnoreCase('Orange')) {
                        for(String traverseAccountId : accountsMap.keySet()) {
                            if(!accountId.equalsIgnoreCase(traverseAccountId)) {
                                currentColorCode = accountsMap.get(traverseAccountId).get(productFamilyName).colorNameOrCode;
                                if(!currentColorCode.equalsIgnoreCase('Orange')) { //|| &&!currentColorCode.equalsIgnoreCase('Green')
                                    accountsMap.get(traverseAccountId).get(productFamilyName).colorNameOrCode = 'Yellow';
                                }
                            }
                        }
                    }
                }
            }
        }
        return accountsMap;
    }
    
    //method used to get the end customer associated to an account
    private Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>>
        doFetchAssociatedSPAccount(Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> accountsMap,
        String endCustomerId, String accountParamId) {
        Map<String, Map<String,SICastIronFactory.ServiceProductDecorator>> accountViewMap = new
            Map<String, Map<String,SICastIronFactory.ServiceProductDecorator>>();
        accountViewMap.put(endCustomerId,accountsMap.get(accountParamId));
        return accountViewMap;  
    }
    
    public Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> doGenerateAccountView(String accountId) {
        String paramAccountId = accountId != null ? accountId : '';
        Set<String> endCustomerSet = new Set<String>();
        Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> accoutViewMap =
            new Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>>();
        String[] endCustArr = new String[2];
        
        Map<String, SICastIronFactory.ServiceProductDecorator> endCustMap = null;
             
        try {
            
            //Query to fetch the results - Associated to a SP Account
           for(AggregateResult ag :[Select Deal__r.Account.Id acctId, Deal__r.Account.Name acctName,RecordType.Name 
                prodFamilyName,Deal_Status__c prodDealStatus,Deal__r.End_Customer__r.Id endCustId,Deal__r.End_Customer__r.Name 
                endCustName, Deal__r.End_Customer__r.Named_Account__c namedAccount,Deal_Exclusivity_Date__c dealExDate,
                Count(Id) prodCount from SPProduct__c
                Where Deal__r.AccountId = :paramAccountId 
                and deal__r.Account.Id <> null and Deal__r.End_Customer__r.Id <> null and 
                RecordType.Name <> 'Products'
                Group By Deal__r.Account.Id, Deal__r.Account.Name,RecordType.Name,Deal_Status__c,
                Deal__r.End_Customer__r.Id, Deal__r.End_Customer__r.Name,Deal__r.End_Customer__r.Named_Account__c,
                Deal_Exclusivity_Date__c 
                Order By Deal__r.Account.Name,RecordType.Name]) {
                endCustomerSet.add(String.valueOf(ag.get('endCustId'))+'|'+String.valueOf(ag.get('acctId')));   
           }
           
           //invoke the heatmap logic - for each and every end customer
           if(!endCustomerSet.isEmpty()) {
                for(String endCustomerId : endCustomerSet) {
                    endCustArr = endCustomerId.split('\\|');
                    endCustMap = doFetchAssociatedProducts(endCustArr[0], endCustArr[1]).get(endCustArr[0]);
                    if(null != endCustMap && !endCustMap.isEmpty()) {
                        accoutViewMap.put(endCustArr[0],endCustMap);
                    }
                }
           }
           
        } catch(Exception excep) {
            System.debug('Exception Caught :: doGenerateAccountView.@'+excep.getLineNumber()+','+excep.getMessage());
        }
        return accoutViewMap;
    }
    
    //method used to get the end customer associated to an account
    private Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>>
        doProductsExclusitivityDates(Map<String, Map<String, SICastIronFactory.ServiceProductDecorator>> acctEndCustMap) {
        SICastIronFactory.ServiceProductDecorator productDecorator = null;
        boolean isExclusitivityRemove = true;
        
        //For Marking the deal exclusitivity date
        for(String objectKey : acctEndCustMap.keySet()) {
            for(String productKey : acctEndCustMap.get(objectKey).keySet()) {
                productDecorator = acctEndCustMap.get(objectKey).get(productKey);
                if(productDecorator.productDealStatus.equalsIgnoreCase('Order Submitted')
                    && productDecorator.dealExclusitivityDate < Date.today() && !productDecorator.isNamedAccount) {
                    productDecorator.systemNotation += ' ExP'; //Exclusitivity Date Passed
                    productDecorator.isExclusitivityPassed = true;
                    productDecorator.colorNameOrCode = 'Red'; //Changed due to Exclusitivity Date Pass
                }
            }
        }
        
        //for removing the exclusitivity date passed records
        for(String objectKey : acctEndCustMap.keySet()) {
            Integer keyCounter = 0;
            for(String productKey : acctEndCustMap.get(objectKey).keySet()) {
                productDecorator = acctEndCustMap.get(objectKey).get(productKey);
                if(productDecorator.isExclusitivityPassed) {
                    keyCounter ++;
                }
            }
            if(acctEndCustMap.get(objectKey).keySet().size() == keyCounter) {
                acctEndCustMap.remove(objectKey);
            }
        }
        
        return acctEndCustMap;
    }
}