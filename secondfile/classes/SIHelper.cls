//A helper class where the utility methods gets in.
/* 
 Name: SIHelper
 Type: Class 
 
 Description: 
 */ 
public  class SIHelper {
    public static SIHelper siHelperObj = null;
    public static Map<String, RecordType> recordTypeMap = null;
    public static Map<Id, RecordType> recordIdMap = null;
    public static Map<Id, Id> endCustomerMap = null;
    public static Map<String,RecordType> recordNameMap = null;    
    public static Map<String, List<String>> recordTypeNameCache = null;
    
    /*Name:SIHelper
     * Description:
     */
    private SIHelper() {}
    
    //Method to return the instance of the SIHelper - Singeleton
/* 
 Name: getInstance
 Description: 
 */ 
    public static SIHelper getInstance() {
     try{
        if(siHelperObj == null) {
            siHelperObj = new SIHelper();
        }
        return siHelperObj;
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
           return null;
        }
    }
    
    //Method to get the record type Ids by passing the Developer Name
/* 
 Name: getRecordTypeMap
 Description: 
 */ 
    public  static Id getRecordTypeMap(String developerName) {
       try{
        if(null == recordTypeMap) {
            recordTypeMap = new Map<String, RecordType>();
            for(RecordType recordTy : [Select Id,  Name, DeveloperName from RecordType Order by DeveloperName Asc]) {
                recordTypeMap.put(recordTy.DeveloperName, recordTy);
            }
        }
        return  recordTypeMap.get(developerName) != null ? recordTypeMap.get(developerName).Id : null;
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }
    }
    
/* 
 Name: getRecordNameMap
 Description: 
 */ 
    public static Id getRecordNameMap(String objectApiName,String recordTypeName){
        try{
            
            //One time activity
            if(recordNameMap == null){
                recordNameMap = new Map<String,RecordType>();
                for(RecordType rt:[SELECT ID,Name,SObjectType FROM RecordType Where isActive = true]){
                    recordNameMap.put(rt.SObjectType+Constant.siHelper_dot+rt.Name,rt);
                }                          
            }           
            
            if((null != objectApiName && objectApiName.length() > Constant.siHelper_Zero) &&
            (recordTypeName != null && recordTypeName.length() >Constant.siHelper_Zero)) {
                String objectRecordTypeName = objectApiName +Constant.siHelper_dot+recordTypeName;
                return recordNameMap.get(objectRecordTypeName ) !=null ? 
                    recordNameMap.get(objectRecordTypeName).Id:null;  
            }       
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        
        }
        return null;
    }
    
    //Http Callout Method to a web service (this is inside a salesforce)
    @future (callout=true)
/* 
 Name: generateExcelCallOut
 Description: 
 */ 
    public static void  generateExcelCallOut(String productsList) {
        HttpRequest requestObj = null;
        HttpResponse responseObj = null;
        Http httpObj = null;
        
        try {
            
            httpObj = new Http();
            
            String[] productDetails = productsList.split(Constant.siHelper_comma);
            String[] fieldDetails = null;
            
            List<Attachment> attList = new List<Attachment>();
            Attachment attObj = null;
            
            for(String spProductObj : productDetails) { 
                fieldDetails =  spProductObj.split(Constant.siHelper_Symbol);   
                requestObj = buildWebServiceRequest(fieldDetails[0]);
                responseObj = invokeWebService(httpObj, requestObj);
                attObj = generateExcelAttachment(responseObj, fieldDetails[0], fieldDetails[1]);
                if(null != attObj && attObj.parentId != null) {
                    attList.add(attObj);
                }
            } // end for UtilityConstant.FOR
            if(!attList.isEmpty()) {
                insert attList;
            }
        } catch(Exception excep) {
            ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
        }       
    } //End of a callout method.
    
    //Method used to generate the attachment
/* 
 Name: generateExcelAttachment
 Description: 
 */ 
    public static Attachment generateExcelAttachment(HttpResponse responsObj, String productId,String productSalesforceId) {
        Attachment attObj = null;
        try {
            attObj = new Attachment();
            attObj.ContentType = SIConstants.EXCEL_CONTENT_TYPE;
            attObj.body = Blob.valueOf(responsObj.getBody());
            attObj.name = Constant.siHelper_AVPNSites;
            attObj.parentId = productSalesforceId;
            return attObj;
        } catch(Exception excep) {
            throw excep;
            ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
        }
        return null;
    }
    
    //Method to bulid the HttpRequet Object
/* 
 Name: buildWebServiceRequest
 Description: 
 */ 
    public static HttpRequest buildWebServiceRequest(String productName) {
     try{
        String httpBody = Constant.siHelper_EmptyContent;
        HttpRequest requestObj = null;
        if(productName != null && productName.length() > 0) {
            requestObj = new HttpRequest();
            requestObj.setHeader(Constant.siHelper_ContentType, Constant.siHelper_Style);
            requestObj.setMethod(Constant.siHelper_POST);
            requestObj.setEndpoint(Label.SIVAR_URL+Constant.siHelper_URLString+productName);
            requestObj.setBody(httpBody);
        }
        return requestObj;    
        }catch(Exception excep) {
            ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
            return null;
        }
    }
    
    //Method to bulid the HttpResponse Object
/* 
 Name: invokeWebService
 Description: 
 */ 
    public static HttpResponse invokeWebService(Http httpObj, HttpRequest requestObj) {
     try{
        HttpResponse responseObj = httpObj.send(requestObj);
        
        return responseObj;
        }catch(Exception excep) {
            ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
            return null;
        }
    }
    
    //method used to get the opporunities based on the account name/customer name
/* 
 Name: fetchHeatMapRes
 Description: 
 */ 
    public static Map<Id, SPProduct__c> fetchHeatMapRes(String searchField, String accountName, String endCustomerName) {
        
        String searchQuery = Constant.siHelper_Blank;
        List<SPProduct__c> prodList = new List<SPProduct__c>();
        Map<Id, SPProduct__c> heatResMap = new Map<Id, SPProduct__c>(); 
        
        try {
            
            searchQuery = Constant.siHelper_SearchQuery;
            
            if((null != searchField) && ((accountName != null && accountName.length() > 0)) &&
                ((endCustomerName != null && endCustomerName.length() > Constant.siHelper_Zero))) {
                searchQuery += Constant.siHelper_SymbolForQury + accountName +Constant.siHelper_SymbolForQuery;
                searchQuery += Constant.siHelper_ConditionAdded + endCustomerName +Constant.siHelper_SymbolForQuery;
            }
            else if(((null != searchField) && (searchField.equalsIgnoreCase(Constant.siHelper_Account))) 
                && ((null != accountName) && (accountName.length() > Constant.siHelper_Zero))) {
                searchQuery += Constant.siHelper_SymbolForQury + accountName +Constant.siHelper_SymbolForQuery;
            } else if(((null != searchField) && (searchField.equalsIgnoreCase(Constant.siHelper_EndCustomer))) 
                && ((null != endCustomerName) && (endCustomerName.length() > Constant.siHelper_Zero))) {
                searchQuery += Constant.siHelper_ConditionAdded + endCustomerName +Constant.siHelper_SymbolForQuery;   
            } else {
                
            }
            
            searchQuery += Constant.siHelper_Query_Add;
            
            if(searchQuery.length() > Constant.siHelper_Zero) {
                prodList = Database.query(searchQuery);
                if(null != prodList && !prodList.isEmpty()) {
                    for(SPProduct__c prodObj : prodList) {
                        if(searchField.equalsIgnoreCase(Constant.siHelper_Account)) {
                            heatResMap.put(prodObj.Deal__r.Account.Id, prodObj);
                        } else {
                            heatResMap.put(prodObj.Deal__r.End_Customer__r.Id, prodObj);
                        }
                    }
                }
            }
        } catch(Exception excep) {
            ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
        }
        return heatResMap;
    }
    
    //A method used to fetch the heatmap based on the 
/* 
 Name: fetchSPAccountsHeatMap
 Description: 
 */ 
    public List<SIHeatMapUtility.SIHeatMapDto> fetchSPAccountsHeatMap(Set<String> accountEndCustomerSet) {
      
        List<SIHeatMapUtility.SIHeatMapDto> persistedHeatMapList = new List<SIHeatMapUtility.SIHeatMapDto>();
        List<SIHeatMapUtility.SIHeatMapDto> persistedHeatMapListTemp = new List<SIHeatMapUtility.SIHeatMapDto>();
        
        SIHeatMapUtility heatMapUtilityObj = null;
        String[] accountEndCustomerArr = null;
        
        try {
            if(null != accountEndCustomerSet && !accountEndCustomerSet.isEmpty()) {
                for(String accountEndIdStr : accountEndCustomerSet) {
                    accountEndCustomerArr = accountEndIdStr.split(Constant.siHelper_Symbol1);
                    heatMapUtilityObj = new SIHeatMapUtility(accountEndCustomerArr[2]);
                    persistedHeatMapListTemp = heatMapUtilityObj.persistedHeatMapList;
                    
                    for(SIHeatMapUtility.SIHeatMapDto heatMapObj : persistedHeatMapListTemp) {
                        if(heatMapObj.accountId.equalsIgnoreCase(accountEndCustomerArr[0]) &&
                            heatMapObj.endCustomerName.equalsIgnoreCase(accountEndCustomerArr[1])) {
                            persistedHeatMapList.add(heatMapObj);       
                        }
                    }
                }
            }
        } catch(Exception excep) {
                ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
        }
        return persistedHeatMapList;
    }
    
    
    /*Name:modifyPersistedHeatMapList
     * Description:A method to filter the heat map entries based on the account name and the endcustomer
     */
    public List<SIHeatMapUtility.SIHeatMapDto> modifyPersistedHeatMapList(String accountName, 
        String endCustomerName, List<SIHeatMapUtility.SIHeatMapDto> heatMapDtoList) {
        List<SIHeatMapUtility.SIHeatMapDto> modifiedPerHeatMapList = new List<SIHeatMapUtility.SIHeatMapDto>();
        try {
            if((accountName != null && accountName.length() > Constant.siHelper_Zero) 
                && (endCustomerName != null && endCustomerName.length() > Constant.siHelper_Zero)
                && (heatMapDtoList != null && !heatMapDtoList.isEmpty())) {
                for(SIHeatMapUtility.SIHeatMapDto heatMapDtoObj : heatMapDtoList) {
                    if(heatMapDtoObj.accountName.toLowerCase().contains(accountName.toLowerCase())
                        && (heatMapDtoObj.endCustomerName.toLowerCase().contains(endCustomerName.toLowerCase()))) {
                        modifiedPerHeatMapList.add(heatMapDtoObj);      
                    }
                }   
            }   
        } catch(Exception excep) {
                ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
        }
        return modifiedPerHeatMapList;
    }   
    
    //Method returns a List<SelectOption> in a sorted order.
/* 
 Name: getSortedList
 Description: 
 */ 
    public List<SelectOption> getSortedList(Map<String, SIWorkflowObjectDto> objectsMapGUI, boolean isNullItem) {
      try{
        List<String> keyList = new List<String>();
        List<SelectOption> sortedSelectList = new List<SelectOption>();
    
        keyList.add(Constant.siHelper_Acount);
        keyList.add(Constant.siHelper_Lead);
        keyList.add(Constant.siHelper_Opty);
        
        if(isNullItem) {
          sortedSelectList.add(new SelectOption(Constant.siHelper_Blank,Constant.siHelper_None));
        }
        keyList.sort();
          for(String stringItem : keyList) {
            sortedSelectList.add(new SelectOption(stringItem, stringItem)); 
           
          }
        
        return sortedSelectList;
        }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }
    }
    
    
    /*Name:getSortedFieldsList
     * Description:method used to return the objects fields
     */
    public List<SelectOption> getSortedFieldsList(List<SIWorkflowObjectDto.SIWorkflowField> fieldsList, 
        boolean isNullItem,String obj) {
       try{ 
        List<SelectOption> sortedSelectList = new List<SelectOption>();
        Map<String, String> fieldsMap = new Map<String, String>();
        List<String> sortedMapKeys = new List<String>();
        List<Schema.FieldSetMember> leadset;
        map<String,Boolean> excludeAPI=new map<String,Boolean>();
        
        
        if(isNullItem) {
          sortedSelectList.add(new SelectOption(Constant.siHelper_Blank,Constant.siHelper_None));
        }
        Leadset=SObjectType.Lead.FieldSets.Lead_Rule_Engine.getFields(); 
        for(Schema.FieldSetMember LA:Leadset){
            ExcludeAPI.put(LA.getFieldPath(),false);    
        }
        Leadset=SObjectType.Account.FieldSets.Account_Rule_Engine.getFields();
        for(Schema.FieldSetMember LA:Leadset){
            ExcludeAPI.put(LA.getFieldPath(),false);
        }
        Leadset=SObjectType.Opportunity.FieldSets.Opty_Rule_Engine.getFields();
        for(Schema.FieldSetMember LA:Leadset){
            ExcludeAPI.put(LA.getFieldPath(),false);
        }
        
        if(null != fieldsList && !fieldsList.isEmpty()) {
            for(SIWorkflowObjectDto.SIWorkflowField workflowFieldObj : fieldsList) {
                
                if(ExcludeAPI.get(workflowFieldObj.fieldApiName)!=null){
                 fieldsMap.put(workflowFieldObj.fieldLabel, workflowFieldObj.fieldApiName); 
                }           
            }
            
            sortedMapKeys.addAll(fieldsMap.keySet());
            sortedMapKeys.sort();
        }       
        for(String fieldItem : sortedMapKeys) {
            sortedSelectList.add(new SelectOption((String) fieldsMap.get(fieldItem), fieldItem));
            
        }       
        return sortedSelectList;
       }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }
    }
    
    //A method used to display the datatypes 
/* 
 Name: getSortedDataTypes
 Description: 
 */ 
    public List<SelectOption> getSortedDataTypes() {
      try{
        List<String> sortedDataTypeList = new List<String>();
        List<SelectOption> sortedDataTypeOptionList = new List<SelectOption>();
        
        
        sortedDataTypeList.add(Constant.siHelper_Number);
        sortedDataTypeList.add(Constant.siHelper_String);
        sortedDataTypeList.add(Constant.siHelper_Picklist);  
        sortedDataTypeList.sort();
        

        sortedDataTypeOptionList.add(new SelectOption(Constant.siHelper_Blank,Constant.siHelper_None ));
        
        for(String dataTypeItem : sortedDataTypeList) {
            sortedDataTypeOptionList.add(new SelectOption(dataTypeItem, dataTypeItem));
        }
        
        return sortedDataTypeOptionList;
        }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }
    }
    
/* 
 Name: getProducts
 Description: 
 */ 
    public static List<SIHeatMapController.SIHeatMapProduct> getProducts() {
      try{
        List<SIHeatMapController.SIHeatMapProduct> productsList = new List<SIHeatMapController.SIHeatMapProduct>();
        if(null != SIConstants.HEAT_MAP_PROD_NAMES && SIConstants.HEAT_MAP_PROD_NAMES.size() > Constant.siHelper_Zero) {
            for(String prodName : SIConstants.HEAT_MAP_PROD_NAMES) {
                if(productsList.isEmpty()) {
                    productsList.add(new SIHeatMapController.SIHeatMapProduct(Constant.siHelper_One, prodName, true));
                } else {
                    productsList.add(new SIHeatMapController.SIHeatMapProduct((Integer)productsList.size()+Constant.siHelper_One, prodName, true));
                }
            }
        }
        return productsList;
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }   
    }
    
    /*Name:objectEqualsCheck
     * Description:method to check the map values are true/false
     */
    private static boolean objectEqualsCheck(Map<String, boolean> fieldsCompareMap) {
        for(String fieldKey : fieldsCompareMap.keySet()) {
            if(!fieldsCompareMap.get(fieldKey)) {
                return false;
            }
        }
        return true;
    }
    
    
    /*Name:findElements
     * Description:check whether the element exists in the map
     */
    private static boolean findElements(Id currentObjectId , String equalityMode, String mapType, 
        Map<String, Map<String, Map<Id, SObject>>> objectDataStruct) {
        if(objectDataStruct.get(equalityMode).get(mapType).containsKey(currentObjectId)) {
            return true;
        }   
        return false;
    }
    
    
    /*Name:findElementsInArr
     * Description:method to check the element in the array 
     */
    private static SObject findElementsInArr(Id idObj, SObject[] objectArr) {
        for(SObject objectObj : objectArr) {
            if(objectObj.get(Constant.siHelper_Id) == idObj) {
                return objectObj;
            }
        }
        return null;
    }
    
    /*Name:getProductOBlist
     * Description:Method used to Bulk fire of Special Pricing Products 
     */
    public void getProductOBlist(String oppId)
    {
      try{
       Boolean checkOB=true;
       List<spProduct__c> prodOBlist;
       ProdOBlist =[Select id, Deal__c,Competitive_Pricing_Status__c from sPProduct__c where deal__c =:oppId AND Competitive_Pricing_Status__c<>NULL];
       
       for(spProduct__c OB:ProdOBlist){
           if(OB.Competitive_Pricing_Status__c==SIConstants.PROD_COMP_PRI_DEN || OB.Competitive_Pricing_Status__c ==SIConstants.PROD_COMP_PRI_APP)
           {
               OB.Retrigger_WS_to_BID__c=true;
           }else{
               CheckOB=false;
           }
       }
       if(CheckOB){
           update ProdOBlist;
       }
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }

    //method to get wheter the product is approved by system/not
/* 
 Name: doSystemApprovedEntry
 Description: 
 */ 
    public static boolean doSystemApprovedEntry(String valueToCheck) {
      try{
        return valueToCheck != null && valueToCheck.length() > 0 && valueToCheck.contains(Constant.siHelper_System) ? true : false;
        }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }
        
    }
    
    //method to get the color code/name
/* 
 Name: doSearchColorCodeOrName
 Description: 
 */ 
    public static String doSearchColorCodeOrName(String productDealStatus, boolean isNamedFlag) {
       try{
        if(productDealStatus != null && productDealStatus.length() > Constant.siHelper_Zero) {
            
            if(isNamedFlag || productDealStatus.toLowerCase().contains(Constant.siHelper_NamedAccount)) {
                return Constant.siHelper_Blue;
            }
            
            if(productDealStatus.equalsIgnoreCase(Constant.siHelper_OrderSubmitted)) {
                return Constant.siHelper_ColorRed;//dark red             
            }

            if(productDealStatus.toLowerCase().contains(Constant.siHelper_WithDiscount)) {
                return Constant.siHelper_Orange;                
            }

            if(productDealStatus.toLowerCase().contains(Constant.siHelper_WithOutDiscount)) {
                return Constant.siHelper_Orange;            
            }

            if(productDealStatus.equalsIgnoreCase(Constant.siHelper_Available) || 
                productDealStatus.equalsIgnoreCase(Constant.siHelper_DealRegistrationDenied) ||
                productDealStatus.equalsIgnoreCase(Constant.siHelper_DealRegistrationCancelled)) {
                return Constant.siHelper_Green;
            }
        }
        return Constant.siHelper_Blank;      
        }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }
    }
    
    //Method responsible to construct the heatmap query - search results
/* 
 Name: getHeatMapResultsQuery
 Description: 
 */ 
    public String getHeatMapResultsQuery(SIHeatMapControllerV2.SIHeatMapSearch searchObj) {
        try{
        String selectQuery = Constant.siHelper_Query ;
        
        String additionalConditions = Constant.siHelper_AdditConditions;
        
        String queryPredicate = Constant.siHelper_QueryPredicate ;
            
        if(null != searchObj) {
            String addCondition = Constant.siHelper_Blank;
            
            //For End Customer view
            if(searchObj.endCustomerName != null && searchObj.endCustomerName.length() > Constant.siHelper_Zero) {
                addCondition = Constant.siHelper_Cond +searchObj.endCustomerName+ Constant.siHelper_SymbolForQuery;
            }
            
            //for SP Account view
            if(searchObj.spAccountName != null && searchObj.spAccountName.length() > Constant.siHelper_Zero) {
                addCondition += Constant.siHelper_addConditionQry +searchObj.spAccountName+ Constant.siHelper_SymbolForQuery;
            }
            
            if(addCondition.startsWith(Constant.siHelper_And)) {
                addCondition = addCondition.replace(Constant.siHelper_And, Constant.siHelper_Blank);
                searchObj.bothInputtedFlag = false;
            } else {
                searchObj.bothInputtedFlag = true;
            }
            
            additionalConditions = additionalConditions + addCondition;
        }
        
        selectQuery += additionalConditions + queryPredicate;
        
        return selectQuery;
        }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }
    }
    
    //A method to return the list of record type names associated with the sobject
/* 
 Name: getRecordTypeNames
 Description: 
 */ 
    public static List<String> getRecordTypeNames(String objectName, List<String> recordTypeOmittedList, boolean isQueryExecute) {
        
        List<String> recordTypeNameList = null;

        try {
            if(null == recordTypeNameCache) {
                recordTypeNameCache = new Map<String, List<String>>();
            }
            
            if(objectName != null && objectName.length() > 0) {
                if(isQueryExecute) {
                    String[] keyName = recordTypeNameCache.get(objectName) != null ? recordTypeNameCache.remove(objectName) 
                        : new String[] {Constant.siHelper_Blank,Constant.siHelper_Blank};
                }
                
                if(null == recordTypeNameCache.get(objectName)) {
                    recordTypeNameList =  new List<String>();                   
                    for(RecordType recordTypeObj : [Select Id,Name,DeveloperName from RecordType 
                        Where SobjectType = :objectName and Name Not IN :recordTypeOmittedList Order By Name]) {
                        recordTypeNameList.add(recordTypeObj.Name);
                    }
                    
                    if(!recordTypeNameList.isEmpty()) {
                        recordTypeNameCache.put(objectName, recordTypeNameList);
                    }
                }
            } //end for objectName block
            
        } catch(Exception excep) {
            ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
        }
        return  recordTypeNameCache.get(objectName) != null ? recordTypeNameCache.get(objectName) :
            new List<String>();
            
    }
    
    
    /*Name:calculateDiscountforProductPricing
     * Description:This method is to calculate the discount for Product Pricing records, It will return a list of product Pricing records after calculation.
     */
    public static list<Product_Pricing__c> calculateDiscountforProductPricing(list <Product_Pricing__c> pricingList, Decimal percentage, Boolean withDiscount)
    {
        try
        {
            if(!pricingList.isEmpty() && pricingList!= null)
            {
                for(Product_Pricing__c ppr: pricingList)
                {
                    if(withDiscount==true)
                    {
                        if(ppr.Discountable__c==false)
                        {
                           if(ppr.Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE)
                            {
                                ppr.Discounted_Usage_Charge__c = ppr.Usage_Charges__c - Round4Digit((ppr.Usage_Charges__c * percentage)/100);
                            }else{
                                ppr.discount_price__c = applyRound((ppr.List_Price__c * percentage)/100);
                                ppr.Discounted_Price__c = ppr.List_Price__c - ppr.discount_price__c;
                            }
                        }
                        else
                        {
                           if(ppr.Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE){
                                ppr.Discounted_Usage_Charge__c=ppr.Usage_Charges__c;
                           }else{
                                ppr.discount_price__c=0;
                                ppr.Discounted_Price__c=ppr.List_Price__c;
                           }
                        }
                    }
                    else if(withDiscount==false)
                    {
                        if(ppr.Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE){
                            ppr.Discounted_Usage_Charge__c=ppr.Usage_Charges__c;
                        }else{
                            ppr.discount_price__c=0;
                            ppr.Discounted_Price__c=ppr.List_Price__c;
                        }
                    }
                }
                return pricingList;
            }
            else
            {
                return null;
            }
        }
        catch(Exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }
    /*Name:calculateDiscountonProductPricingRecords
     * Description:
     */
    public static list<Product_Pricing__c> calculateDiscountonProductPricingRecords(list <Product_Pricing__c> newList)
    {
        try{
            list <SPProduct__c> prodList = new list <SPProduct__c>();
            Decimal discPercen = null;
            set <Id> prodId = new set <Id>();
            set <Id> opptyIDs = new set <ID>();
            list<Opportunity> optylist = new list<Opportunity>();
            map<Id, Decimal> disocuntMap = new map<Id, Decimal>();
            
            if(!newList.isEmpty()&&newList!=null)
            {
                Admin_Control__c adminControl  = [select Discounted_Percentage__c, Mobility_Discunted_Percentage__c from Admin_Control__c limit 1];
                
                for(Product_Pricing__c pp : newList)
                {
                   prodId.add(pp.Sp_Product__c);
                    opptyIDs.add(pp.Deal_Id__c);
                }
                
                //Updated logic for promotion engine and for BID deals   
                if( opptyIDs.size() > 0 ) {     
                    optylist = [select id,Discounted_Percentage__c,Custom_Deal_Reg_Percentage__c, ATOM_Deal__c  from Opportunity where Id IN:opptyIDs ];
                    for(Opportunity setDiscount : optylist)
                    {
                        if(setDiscount.Custom_Deal_Reg_Percentage__c != null && setDiscount.ATOM_Deal__c)
                        {
                            disocuntMap.put(setDiscount.Id, setDiscount.Discounted_Percentage__c);
                        }
                    }
                }
                if(!prodId.isEmpty() && prodId != null && prodId.size() > 0)
                {
                    prodList = [SELECT Id,Deal__c,Record_Type_Name__c,Deal_Status__c,Registration_Discount__c,MACD_Type__c FROM SPProduct__c WHERE Id IN : prodId];
                }       
                if(!prodList.isempty() && prodList!=null){
                    for(Product_Pricing__c pp : newList){
                      
                        if(pp.Type__c == SIConstants.TYPE_MRC || pp.Type__c == SIConstants.TYPE_NRC || pp.Type__c == SIConstants.TYPE_MUC ){
                            for(SPProduct__c prod : prodList){                        
                                if (pp.Sp_Product__c==prod.Id){
                                    if(pp.Discountable__c == false){
                                        if(prod.Deal_Status__c == SIConstants.PROD_DEAL_REG_APP_WITH_DIS || (prod.Deal_Status__c == SIConstants.OPTY_DEAL_SUBMITTED && prod.Record_Type_Name__c==SIConstants.PROD_IPFLEX && Prod.Registration_Discount__c) || (prod.Deal_Status__c == SIConstants.OPP_STAGE_Tech_Review_Pending && prod.Record_Type_Name__c==SIConstants.PROD_ASE) || pp.X3rd_Party_Flag__c || pp.Clear_Special_Pricing__c || (prod.Deal_Status__c == SIConstants.OPTY_DEAL_SUBMITTED && prod.MACD_Type__c == Constant.siHelper_A))
                                        {
                                            if(prod.Record_Type_Name__c.equalsIgnoreCase(SIConstants.PROD_Attwireless) || prod.Record_Type_Name__c.equalsIgnoreCase(SIConstants.PROD_MDM))                                  
                                            {
                                                if(disocuntMap.get(prod.Deal__c)!=null){
                                                    discPercen = disocuntMap.get(prod.Deal__c);
                                                }
                                                else{
                                                    discPercen = adminControl.Mobility_Discunted_Percentage__c;
                                                }
                                            }
                                            else{
                                                if(disocuntMap.get(prod.Deal__c)!=null)
                                                {
                                                    discPercen = disocuntMap.get(prod.Deal__c);
                                                }
                                                else
                                                {
                                                    discPercen = adminControl.Discounted_Percentage__c;
                                                }
                                            }
                                            if(discPercen != null )
                                            {
                                               if(pp.Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE){
                                                    pp.Discounted_Usage_Charge__c = pp.Usage_Charges__c - Round4Digit((pp.Usage_Charges__c * discPercen)/100);   
                                               }else{
                                                    system.debug('\n pp.List_Price__c * discPercen '+pp.List_Price__c * discPercen );
                                                    // DEFECT FIX - 183750 -START
                                                    //pp.discount_price__c = applyRound((pp.List_Price__c * discPercen)/100);                                 
                                                    // DEFECT FIX - 183750 - END/**/
                                                    /*Updated as part of US344706*/
                                                    system.debug('@@@US344706 before if ');
                                                    if((string.isNotBlank(prod.MACD_Type__c)) || (prod.Record_Type_Name__c != 'AVPN' && prod.Record_Type_Name__c != 'MIS' && prod.Record_Type_Name__c != 'AMIS')){
                                                        system.debug('@@@US344706 entered if ');
                                                        pp.discount_price__c = (pp.List_Price__c * discPercen)/100;
                                                        pp.Discounted_Price__c = pp.List_Price__c - pp.discount_price__c;
                                                    }
                                               }
                                            }                                   
                                        }
                                        else if(prod.Deal_Status__c == SIConstants.PROD_DEAL_REG_APP_WITHOUT_DIS || (prod.Deal_Status__c == SIConstants.OPTY_DEAL_SUBMITTED && prod.Record_Type_Name__c==SIConstants.PROD_IPFLEX && !Prod.Registration_Discount__c) || (prod.Deal_Status__c == SIConstants.OPTY_DEAL_SUBMITTED && prod.MACD_Type__c == Constant.siHelper_A))
                                        {
                                           if(pp.Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE){
                                                pp.Discounted_Usage_Charge__c=pp.Usage_Charges__c;
                                           }else{
                                                system.debug('@@@US344706 before if ');
                                                if((string.isNotBlank(prod.MACD_Type__c)) || (prod.Record_Type_Name__c != 'AVPN' && prod.Record_Type_Name__c != 'MIS' && prod.Record_Type_Name__c != 'AMIS')){
                                                    system.debug('@@@US344706 entered if ');
                                                    pp.discount_price__c = 0;
                                                    pp.Discounted_Price__c = pp.List_Price__c;
                                                }
                                           }
                                        }
                                    }
                                    else if(pp.Discountable__c == true && (prod.Deal_Status__c == SIConstants.PROD_DEAL_REG_APP_WITH_DIS || prod.Deal_Status__c == SIConstants.PROD_DEAL_REG_APP_WITHOUT_DIS ||( prod.Deal_Status__c == SIConstants.OPTY_DEAL_SUBMITTED && prod.Record_Type_Name__c==SIConstants.PROD_IPFLEX))|| (prod.Deal_Status__c == SIConstants.OPTY_DEAL_SUBMITTED && prod.MACD_Type__c == Constant.siHelper_A)) {
                                       if(pp.Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE){
                                        pp.Discounted_Usage_Charge__c=pp.Usage_Charges__c;
                                       }else{
                                           system.debug('@@@US344706 before if ');
                                           if((string.isNotBlank(prod.MACD_Type__c)) || (prod.Record_Type_Name__c != 'AVPN' && prod.Record_Type_Name__c != 'MIS' && prod.Record_Type_Name__c != 'AMIS')){
                                                system.debug('@@@US344706 entered if ');
                                                pp.discount_price__c = 0;
                                                pp.Discounted_Price__c = pp.List_Price__c;
                                           }
                                       }
                                    }                       
                                }
                            }
                        }
                    }
                }
            }
            return newList;
        }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }   
    }
    
    // Applying roundup at the discount price of the product pricing level.
/* 
 Name: applyRound
 Description: 
 */ 
    public static Decimal applyRound(Decimal toRound){
      try{system.debug('inside applyroound  toRound'+toRound); 
        Decimal setScaleAmount= toRound.setScale(3) ;
        Decimal finalResultDisplay = 0;
        String coverttoString=String.ValueOf(setScaleAmount);
        String lastDigit= CoverttoString.substring(CoverttoString.length()-1);
        Integer finalVal= Integer.valueOf(lastDigit);
        
        if(finalVal > 5){
            finalResultDisplay = toRound + 0.010;
            String finalString=String.ValueOf(finalResultDisplay);
            String myTruncatedNumber = finalString.subString(0,finalString.indexOf(Constant.siHelper_dot)+3);
            finalResultDisplay = Decimal.valueOf(myTruncatedNumber);
         }else{
          String finalString=String.ValueOf(toRound );
           String myTruncatedNumber = SpecialCharacterConstant.SIVAR_CONST_00;
           if(finalString != SpecialCharacterConstant.SIVAR_CONST_00){
               myTruncatedNumber = finalString.subString(0,finalString.indexOf(Constant.siHelper_dot)+3);
           }
            
            finalResultDisplay = Decimal.valueOf(myTruncatedNumber);
       }
         return finalResultDisplay;  
      }catch(Exception ex)
        {
            return null;
        }    
          
   } 
   
   /*
     Name:applyRoundMACD(Decimal toRound
     Description:
    
    */
   public static Decimal applyRoundMACD(Decimal toRound){
      try{  system.debug(' inside applymacd and toround is '+toRound);
        Decimal setScaleAmount= toRound.setScale(3) ;
        Decimal finalResultDisplay = 0;
        String coverttoString=String.ValueOf(setScaleAmount);
        String lastDigit= CoverttoString.substring(CoverttoString.length()-1);
        Integer finalVal= Integer.valueOf(lastDigit);
        
        if(finalVal > 5){
            finalResultDisplay = toRound + 0.010;
            String finalString=String.ValueOf(finalResultDisplay);
            String myTruncatedNumber = finalString.subString(0,finalString.indexOf(Constant.siHelper_dot)+3);
            finalResultDisplay = Decimal.valueOf(myTruncatedNumber);
         }else{
             String finalString=String.ValueOf(toRound );
            String myTruncatedNumber = finalString.subString(0,finalString.indexOf(Constant.siHelper_dot)+3);
            finalResultDisplay = Decimal.valueOf(myTruncatedNumber);
         }
         return finalResultDisplay;  
      }catch(Exception ex)
        {  return null;
        }    
          
   } 
   
   
   
   
   
  
/* 
 Name: Round4Digit
 Description: 
 */ 
    public static Decimal Round4Digit(Decimal toRound){
      try{  
        Decimal setScaleAmount= toRound.setScale(5) ;
        Decimal finalResultDisplay = 0;
        String coverttoString=String.ValueOf(setScaleAmount);
        String lastDigit= CoverttoString.substring(CoverttoString.length()-1);
        Integer finalVal= Integer.valueOf(lastDigit);
        if(finalVal >= 5){
            finalResultDisplay = toRound + 0.0001;
            
            String finalString=String.ValueOf(finalResultDisplay);
            String myTruncatedNumber = finalString.subString(0,finalString.indexOf(Constant.siHelper_dot)+5);
            finalResultDisplay = Decimal.valueOf(myTruncatedNumber);
            
         }else{
            finalResultDisplay = toRound.setScale(4) ;
        }
         return finalResultDisplay;  
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;
        }    
          
   }           
   
   
    /*Name:updateProductsAfterDealDiscount
     * Description:@future
     */
   public static void updateProductsAfterDealDiscount(set <Id> prodSet, boolean withDiscount, Decimal discountPercentage){
        try{
            list <SPProduct__c> prodList = new list <SPProduct__c>();
            map<Id,map<String,Decimal>> discountMap = new map<Id,map<String,Decimal>>();
            String dealStatus =Constant.siHelper_Blank;
            if(withDiscount)
            {
                dealStatus=SIConstants.PROD_DEAL_REG_APP_WITH_DIS;
            }
            else
            {
                dealStatus = SIConstants.PROD_DEAL_REG_APP_WITHOUT_DIS;
            }
            if(!prodSet.isEmpty()&& prodSet!=null)
                {
                    prodList = [SELECT Id,One_Time_Revenue_Discount_Price__c,Discounted_Price__c,Deal_Registration_Discount__c,Deal_Status__c FROM SPProduct__c sp WHERE sp.Id IN : prodSet];
                    AggregateResult[] groupedResults = [SELECT Sp_Product__c,Type__c, SUM(Discounted_Price__c) DiscountedPrice, SUM(Discount_Price__c) DiscountPrice FROM Product_Pricing__c WHERE Sp_Product__c IN : prodSet GROUP BY Sp_Product__c,Type__c];
                    for(AggregateResult agr : groupedResults)
                    {
                        if(discountMap.get((Id)agr.get(Constant.siHelperSp_Product_c))== null)
                        {
                            if(agr.get(Constant.siHelper_Type_c) == Constant.siHelper_MRC)
                            {
                                discountMap.put(((Id)agr.get(Constant.siHelperSp_Product_c)),(new map<String,Decimal>{Constant.siHelper_DiscPrice=>(Decimal)agr.get(Constant.siHelper_DiscountedPrice)}));
                            }
                            else if(agr.get(Constant.siHelper_Type_c) == Constant.siHelper_NRC )
                            {
                                discountMap.put(((Id)agr.get(Constant.siHelperSp_Product_c)),(new map<String,Decimal>{Constant.siHelper_OtcDiscPrice=>(Decimal)agr.get(Constant.siHelper_DiscountedPrice)}));
                            }
                        }
                        else
                        {
                            if(agr.get(Constant.siHelper_Type_c) == Constant.siHelper_MRC)
                            {
                                discountMap.get((Id)agr.get(Constant.siHelperSp_Product_c)).put(Constant.siHelper_DiscPrice,(Decimal)agr.get(Constant.siHelper_DiscountedPrice));
                            }
                            else if(agr.get(Constant.siHelper_Type_c) == Constant.siHelper_NRC)
                            {
                                discountMap.get((Id)agr.get(Constant.siHelperSp_Product_c)).put(Constant.siHelper_OtcDiscPrice,(Decimal)agr.get(Constant.siHelper_DiscountedPrice));
                            }
                        }
                    }           
                    if(!prodList.isEmpty() && prodList!=null)
                    {
                        for(SPProduct__c sp : prodList)
                        {
                            sp.Deal_Registration_Discount__c=discountPercentage;
                            sp.Deal_Status__c = dealStatus;
                            if(discountMap.get(sp.Id)!=null)
                            {
                                sp.Discounted_Price__c = discountMap.get(sp.Id).get(Constant.siHelper_DiscPrice);
                                sp.One_Time_Revenue_Discount_Price__c = discountMap.get(sp.Id).get(Constant.siHelper_OtcDiscPrice);
                            }
                            else
                            {
                                sp.One_Time_Revenue_Discount_Price__c = Constant.siHelper_Zero;
                                sp.Discounted_Price__c= Constant.siHelper_Zero;
                            }                               
                        }
                        update prodList;
                    }
                }  
        }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }       
   }

    
    
   /*Name:createaccountProductMap
    * Description:This function creates a map of accounts and related products and returns the map
    */
    public static map <Id,String[]> createaccountProductMap(list <Partner_Course__c> pcList)
    {       
        map <Id,String[]> accountProdMap= new map <Id,String[]>();
        set <Id> accountIdSet = new set <Id>();
        try
        {
        String[] prodList ;
            for(Partner_Course__c pc : pcList)
            {
                if(!pc.Account__r.Product_Enablement_Override__c)
                {
                    accountIdSet.add(pc.Account__c);
                    if(accountProdMap.containsKey(pc.Account__c))
                    {
                        boolean inFlag=false;
                        prodList = accountProdMap.get(pc.Account__c);
                        for(String pl : prodList)
                        {
                            if(pl.equalsIgnoreCase((String)pc.Product__c))
                            {
                                inFlag=true;
                                break;
                            }
                        }
                        if(!inFlag)
                        {
                            prodList.add((String)pc.Product__c);
                            accountProdMap.put(pc.Account__c,prodList);
                        }
                    }
                    else
                    {
                        prodList=new list <String>();
                        prodList.add((String)pc.Product__c);
                        accountProdMap.put(pc.Account__c,prodList);
                    }
                }
            }
            if(!accountProdMap.isEmpty() && accountProdMap!=null)
            {
                return accountProdMap;
            }
            else
            {
                return null;
            }
        }
        catch (Exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }       
    }
    
        
    /*Name:createContactProductMap
     * Description:This function creates a map of Contact and related products and returns the map
     */
     public static map <Id,String[]> createContactProductMap(list <Partner_Course__c> pcList)
     {
        map <Id,String[]> contactProdMap= new map <Id,String[]>();
        try
        { 
        String[] prodList ;
            for(Partner_Course__c pc : pcList)
            {
                if(contactProdMap.containsKey(pc.Name__c))
                {
                    boolean inFlag=false;
                     prodList = contactProdMap.get(pc.Name__c);
                    for(String pl : prodList)
                    {
                        if(pl.equalsIgnoreCase((String)pc.Product__c))
                        {
                            inFlag=true;
                            break;
                        }
                    }
                    if(!inFlag)
                    {
                        prodList.add((String)pc.Product__c);
                        contactProdMap.put(pc.Name__c,prodList);
                    }
                }
                else
                {
                    prodList=new list <String>();
                    prodList.add((String)pc.Product__c);
                    contactProdMap.put(pc.Name__c,prodList);
                }
            } 
            if(!contactProdMap.isEmpty() && contactProdMap!=null)
            {
                return contactProdMap;
            }
            else
            {
                return null;
            }
        } 
        catch (Exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }       
     }  
     
     
     /*Name:updateContactsWithProductTrainingsCompleted
      * Description:This is to add the product in Product Training Completed field when one partner course object has been created with completed status
      */
     public static void updateContactsWithProductTrainingsCompleted(map <Id,String[]> contactProdMap)
     {
        String[] cntProdList = new list <String>();
        set <Id> contactSet = new set <Id>();
        list <Contact> updatableContacts = new list <Contact>();
        list <Product_Administration__c> productAdminList = new list <Product_Administration__c>();
        map<String,String> prodNameMap = new map<String,String>();
        try
        {
            list <Contact> contactList = [SELECT Id,Product_Trainings_Completed__c FROM Contact WHERE Id IN : contactProdMap.keySet()];
            productAdminList = [SELECT Id,NetExam_Name__c,Product_Training_Name__c FROM Product_Administration__c];
            if(!contactList.isEmpty() && contactList != null)
            {
                for(Product_Administration__c pa : productAdminList)
                {
                    prodNameMap.put(pa.NetExam_Name__c,pa.Product_Training_Name__c);
                }
                for(Contact cnt : contactList)
                {
                    cntProdList = contactProdMap.get(cnt.Id);
                    if(!cntProdList.isEmpty() && cntProdList != null)
                    {
                        for(String product : cntProdList)
                        {
                            String prod=prodNameMap.get(product);
                            if(cnt.Product_Trainings_Completed__c!=null)
                            {
                                if(!cnt.Product_Trainings_Completed__c.containsIgnoreCase(prod))
                                {
                                    cnt.Product_Trainings_Completed__c +=(Constant.siHelper_Symbol4+prod+Constant.siHelper_Symbol4);
                                    if(!contactSet.contains(cnt.Id))
                                    {
                                        contactSet.add(cnt.Id);
                                        updatableContacts.add(cnt);
                                    }
                                }
                            }
                            else
                            {
                                cnt.Product_Trainings_Completed__c = prod;
                                if(!contactSet.contains(cnt.Id))
                                {
                                    contactSet.add(cnt.Id);
                                    updatableContacts.add(cnt);
                                }
                            }
                        }
                    }
                }
            }
            if(!updatableContacts.isEmpty() && updatableContacts != null)
            {
                update updatableContacts;
            }
       }
        catch (Exception e)
        {
        ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }         
     }
     
     
     /*Name:removeInvalidCoursesFromContact
      * Description:This function is to remove the Product from Product training completed field of Contact when the Contact or Product fied in Partner course object have been changed.
      */
     public static void removeInvalidCoursesFromContact(map <Id,String[]> contactProdMap)
     {
        list <Product_Administration__c> productAdminList = new list <Product_Administration__c>();
        map <String,String> prodNameMap = new map <String,String>();
        list <Contact> updatableContacts = new list <Contact>();
        set <Id> updateSet = new set <Id>();
        map <Id,map<String,Decimal>> trainingCompletionMap = new map<Id,map<String,Decimal>>();
        try
        {
            list <Contact> contactList = [SELECT Id,Product_Trainings_Completed__c FROM Contact WHERE Id IN : contactProdMap.keySet()];
            AggregateResult[] groupedResults = [SELECT Name__c,Product__c,COUNT_DISTINCT(Id) countOfCompletion FROM Partner_Course__c WHERE Name__c IN:contactProdMap.keySet() AND Course_Status__c = :Constant.siHelper_Completed AND Course_Expiration_Date__c >= Today AND Product__c !=null GROUP BY Name__c,Product__c];
            productAdminList = [SELECT Id,NetExam_Name__c,Product_Training_Name__c FROM Product_Administration__c ];
            if(!productAdminList.isEmpty() && productAdminList!= null)
            {
                for(Product_Administration__c pa : productAdminList)
                {
                    prodNameMap.put(pa.NetExam_Name__c,pa.Product_Training_Name__c);
                }
            }
            if(!groupedResults.isEmpty() && groupedResults != null)
            {
                for(AggregateResult agr:groupedResults)
                {
                    if(trainingCompletionMap.containsKey((Id)agr.get(Constant.siHelper_Name_c)))
                    {
                        map <String,Decimal> temp =  trainingCompletionMap.get((Id)agr.get(Constant.siHelper_Name_c));
                        temp.put((String)agr.get(Constant.siHelper_Product_c),(Decimal)agr.get(Constant.siHelperCountOfCompletion));
                        trainingCompletionMap.put((Id)agr.get(Constant.siHelper_Name_c),temp);
                    }
                    else
                    {
                        trainingCompletionMap.put((Id)agr.get(Constant.siHelper_Name_c), new map<String,Decimal>{(String)agr.get(Constant.siHelper_Product_c) => (Decimal)agr.get(Constant.siHelperCountOfCompletion)});
                    }
                }
                
                for(Contact cnt:contactList)
                {
                    if(cnt.Product_Trainings_Completed__c!= null)
                    {
                        String[] prodList = contactProdMap.get(cnt.Id);
                        map <String,Decimal> tainingCountMap =  trainingCompletionMap.get(cnt.Id);
                        if(!tainingCountMap.isEmpty() && tainingCountMap != null)
                        {
                            for(String prod:prodList)
                            {
                                if(prodNameMap.containsKey(prod))
                                {
                                    prod=prodNameMap.get(prod);
                                    if(tainingCountMap.get(prod)== null)
                                    {
                                        if(cnt.Product_Trainings_Completed__c.containsIgnoreCase(prod))
                                        {
                                            cnt.Product_Trainings_Completed__c = cnt.Product_Trainings_Completed__c.replaceAll(Constant.siHelper_Symbol2+prod+Constant.siHelper_Symbol3,Constant.siHelper_Symbol4);
                                            if(!updateSet.contains(cnt.Id))
                                            {
                                                updateSet.add(cnt.Id);
                                                updatableContacts.add(cnt);
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                        else
                        {
                            for(String prod:prodList)
                            {
                                prod=prodNameMap.get(prod);
                                cnt.Product_Trainings_Completed__c = cnt.Product_Trainings_Completed__c.replaceAll(Constant.siHelper_Symbol2+prod+Constant.siHelper_Symbol3,Constant.siHelper_Symbol4);
                                if(!updateSet.contains(cnt.Id))
                                {
                                    updateSet.add(cnt.Id);
                                    updatableContacts.add(cnt);
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                for(Contact cnt:contactList)
                {
                    if(cnt.Product_Trainings_Completed__c!= null)
                    {
                        String[] prodList = contactProdMap.get(cnt.Id);
                        for(String prod:prodList)
                        {
                            prod=prodNameMap.get(prod);
                            cnt.Product_Trainings_Completed__c = cnt.Product_Trainings_Completed__c.replaceAll(Constant.siHelper_Symbol3+prod+Constant.siHelper_Symbol3,Constant.siHelper_Symbol4);
                            if(!updateSet.contains(cnt.Id))
                            {
                                updateSet.add(cnt.Id);
                                updatableContacts.add(cnt);
                            }
                        }
                    }
                }
            }
           
            if(!updatableContacts.isEmpty() && updatableContacts != null)
            {
                update updatableContacts;
            }
            
         }
         catch(exception e)
         {
         ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
         }      
     }
     
     
     /*Name:productEnablementAccountLevel
      * Description:This method is to add / Remove the products on Product Trainings completed field on Account Object.
      */
     public static void productEnablementAccountLevel(map <Id,String[]> accountProdMap)
     {
        list <Product_Administration__c> productAdminList = new list <Product_Administration__c>();
        list<Account> accountList = new list <Account>();
        list <Account> updatableAccounts = new list <Account>();
        map<String,String> prodNameMap = new map <String,String>();
        String adminProd =Constant.siHelper_Blank;
        set <Id> accountIdSet = new set <Id>();
        map<Id,map<String,map<String,map<String,Decimal>>>> pcCompleteMap = new map<Id,map<String,map<String,map<String,Decimal>>>>();
        map<String,map<String,map<String,Decimal>>> productAdminMap = new map<String,map<String,map<String,Decimal>>>();
        Integer score =0;
        try
        {
            Admin_Control__c adminControl  = [SELECT Id FROM Admin_Control__c limit 1];
            if(adminControl != null)
            {
                productAdminList = [SELECT Id,Product__c,Course_Count_Sales__c,Course_Count_Technical_Sales__c,Course_Count_Architect__c,Course_Count_Care__c,Course_Count_Technical_Support__c,Minimum_Users_Sales__c,Minimum_Users_Technical_Sales__c, Minimum_Users_Architect__c, Minimum_Users_Care__c, Minimum_Users_Technical_Support__c,Product_Training_Name__c,NetExam_Name__c FROM Product_Administration__c  WHERE Admin_Cntrl__c = :adminControl.Id];
            }
            
            //This block makes a map of product --> Course Type -->  Course count --> User Count. This is to avoid using nested for loop so that we can save a huge number of code statements getting executed against the salesfoce limitation.
            if(!productAdminList.isEmpty() && productAdminList != null)
            {
                for(Product_Administration__c pa : productAdminList)
                {
                    productAdminMap.put(pa.Product__c,new map<String,map<String,Decimal>>{Constant.siHelper_Sales=>new map<String,Decimal>{Constant.siHelper_CourseCount=>pa.Course_Count_Sales__c!=null ? pa.Course_Count_Sales__c : Constant.siHelper_Zero}});
                    productAdminMap.get(pa.Product__c).get(Constant.siHelper_Sales).put(Constant.siHelper_UserCount,pa.Minimum_Users_Sales__c!= null ?pa.Minimum_Users_Sales__c:Constant.siHelper_Zero);
                    productAdminMap.get(pa.Product__c).put(Constant.siHelper_TechnicalSales,new map<String,Decimal>{Constant.siHelper_CourseCount=>pa.Course_Count_Technical_Sales__c != null ? pa.Course_Count_Technical_Sales__c:Constant.siHelper_Zero});
                    productAdminMap.get(pa.Product__c).get(Constant.siHelper_TechnicalSales).put(Constant.siHelper_UserCount,pa.Minimum_Users_Technical_Sales__c!= null ?pa.Minimum_Users_Technical_Sales__c:Constant.siHelper_Zero);
                    productAdminMap.get(pa.Product__c).put(Constant.siHelper_Architect,new map<String,Decimal>{Constant.siHelper_CourseCount=>pa.Course_Count_Architect__c!= null ? pa.Course_Count_Architect__c:Constant.siHelper_Zero});
                    productAdminMap.get(pa.Product__c).get(Constant.siHelper_Architect).put(Constant.siHelper_UserCount,pa.Minimum_Users_Architect__c!= null ?pa.Minimum_Users_Architect__c:Constant.siHelper_Zero);
                    productAdminMap.get(pa.Product__c).put(Constant.siHelper_Care,new map<String,Decimal>{Constant.siHelper_CourseCount=>pa.Course_Count_Care__c!= null ? pa.Course_Count_Care__c:Constant.siHelper_Zero});
                    productAdminMap.get(pa.Product__c).get(Constant.siHelper_Care).put(Constant.siHelper_UserCount,pa.Minimum_Users_Care__c!= null ?pa.Minimum_Users_Care__c:Constant.siHelper_Zero);
                    productAdminMap.get(pa.Product__c).put(Constant.siHelper_TechnicalSupport,new map<String,Decimal>{Constant.siHelper_CourseCount=>pa.Course_Count_Technical_Support__c!= null ? pa.Course_Count_Technical_Support__c:Constant.siHelper_Zero});
                    productAdminMap.get(pa.Product__c).get(Constant.siHelper_TechnicalSupport).put(Constant.siHelper_UserCount,pa.Minimum_Users_Technical_Support__c!= null ?pa.Minimum_Users_Technical_Support__c:Constant.siHelper_Zero);
                    prodNameMap.put(pa.NetExam_Name__c,pa.Product_Training_Name__c);            
                }
                
                //This block is to make another map of Accounts --> Products --> Type Of Course --> Count of contacts from the list of completed product administration records.
                AggregateResult[] groupedResults = [SELECT Account__c,Product__c, Type__c,Course__c,COUNT_DISTINCT(Name__c) countOfContact FROM Partner_Course__c Where Account__c IN : accountProdMap.keySet() AND Course_Status__c = :SIConstants.PARTNER_COURSE_COMPLETED AND Course_Expiration_Date__c >= Today AND Product__c !=null AND Type__c!=null Group By Account__c,Product__c,Type__c,Course__c];
                if(!groupedResults.isEmpty() && groupedResults != null)
                {
                    for(AggregateResult agr: groupedResults)
                    {
                        if(!pcCompleteMap.containsKey((Id)agr.get(Constant.siHelperAccount_c)))
                        {
                            pcCompleteMap.put((Id)agr.get(Constant.siHelperAccount_c), new map<String,map<String,map<String,Decimal>>>{(String)agr.get(Constant.siHelper_Product_c)=> new map<String,map<String,Decimal>>{(String)agr.get(Constant.siHelper_Type_c)=>new map<String,Decimal>{(String)agr.get(Constant.siHelper_Course_c)=> (Decimal)agr.get(Constant.siHelper_CountOfContact)}}});
                        }
                        else
                        {
                            if(!pcCompleteMap.get((Id)agr.get(Constant.siHelperAccount_c)).containsKey((String)agr.get(Constant.siHelper_Product_c)))
                            {
                                pcCompleteMap.get((Id)agr.get(Constant.siHelperAccount_c)).put((String)agr.get(Constant.siHelper_Product_c), new map<String,map<String,Decimal>>{(String)agr.get(Constant.siHelper_Type_c)=>new map<String,Decimal>{(String)agr.get(Constant.siHelper_Course_c)=> (Decimal)agr.get(Constant.siHelper_CountOfContact)}});
                            }
                            else
                            {
                                if(!pcCompleteMap.get((Id)agr.get(Constant.siHelperAccount_c)).get((String)agr.get(Constant.siHelper_Product_c)).containsKey((String)agr.get(Constant.siHelper_Type_c)))
                                {
                                    pcCompleteMap.get((Id)agr.get(Constant.siHelperAccount_c)).get((String)agr.get(Constant.siHelper_Product_c)).put((String)agr.get(Constant.siHelper_Type_c), new map<String,Decimal>{(String)agr.get(Constant.siHelper_Course_c)=> (Decimal)agr.get(Constant.siHelper_CountOfContact)});
                                }
                                else
                                {
                                    pcCompleteMap.get((Id)agr.get(Constant.siHelperAccount_c)).get((String)agr.get(Constant.siHelper_Product_c)).get((String)agr.get(Constant.siHelper_Type_c)).put((String)agr.get(Constant.siHelper_Course_c),(Decimal)agr.get(Constant.siHelper_countOfContact));
                                }
                            }
                        }               
                    }
                }  
                
                //This block is to verify each accounts with list of products for which the threshold has been met or not. If threshold is met, 
                //then enable that product fot this account, otherwice remove the product from product training completed list. 
                accountList =[SELECT Id,Product_Trainings_Completed__c FROM Account WHERE Id IN : accountProdMap.keySet()];
                if(!accountList.isEmpty() && accountList != null)
                {
                    for(Account act: accountList)
                    {
                            if(pcCompleteMap.containsKey(act.Id))
                            {
                                String[] prodList= accountProdMap.get(act.Id);
                                for(String prod: prodList)
                                {
                                    adminProd= prodNameMap.get(prod);
                                    score=0;
                                    if(pcCompleteMap.get(act.Id).containsKey(prod))
                                    {
                                        if(productAdminMap.containsKey(adminProd) && (pcCompleteMap.get(act.Id).get(prod).containsKey(Constant.siHelper_Sales) ? pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_Sales).size():0)>=productAdminMap.get(adminProd).get(Constant.siHelper_Sales).get(Constant.siHelper_CourseCount) &&
                                         (pcCompleteMap.get(act.Id).get(prod).containsKey(Constant.siHelper_TechnicalSales) ? pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_TechnicalSales).size():0)>=productAdminMap.get(adminProd).get(Constant.siHelper_TechnicalSales).get(Constant.siHelper_CourseCount) &&
                                         (pcCompleteMap.get(act.Id).get(prod).containsKey(Constant.siHelper_Architect) ? pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_Architect).size():0)>=productAdminMap.get(adminProd).get(Constant.siHelper_Architect).get(Constant.siHelper_CourseCount) &&
                                         (pcCompleteMap.get(act.Id).get(prod).containsKey(Constant.siHelper_Care) ? pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_Care).size():0)>=productAdminMap.get(adminProd).get(Constant.siHelper_Care).get(Constant.siHelper_CourseCount) &&
                                         (pcCompleteMap.get(act.Id).get(prod).containsKey(Constant.siHelper_TechnicalSupport) ? pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_TechnicalSupport).size():0)>=productAdminMap.get(adminProd).get(Constant.siHelper_TechnicalSupport).get(Constant.siHelper_CourseCount))
                                         {
                                            Integer counter=0;
                                            
                                            //Sales Course Validation
                                            if(pcCompleteMap.get(act.Id).get(prod).containsKey(Constant.siHelper_Sales))
                                            {
                                                for(String courseName: pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_Sales).keySet())
                                                {
                                                    if(pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_Sales).get(courseName)>=productAdminMap.get(adminProd).get(Constant.siHelper_Sales).get(Constant.siHelper_UserCount))
                                                    {
                                                        counter=counter+1;
                                                    }
                                                }
                                                if(counter>=productAdminMap.get(adminProd).get(Constant.siHelper_Sales).get(Constant.siHelper_UserCount))
                                                {
                                                    score = score+1;
                                                }
                                            }
                                            else
                                            {
                                                score = score+1; 
                                            }
                                            
                                            //Technical Sales Validation
                                            counter=0;
                                            if(pcCompleteMap.get(act.Id).get(prod).containsKey(Constant.siHelper_TechnicalSales))
                                            {
                                                for(String courseName: pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_TechnicalSales).keySet())
                                                {
                                                    if(pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_TechnicalSales).get(courseName)>=productAdminMap.get(adminProd).get(Constant.siHelper_TechnicalSales).get(Constant.siHelper_UserCount))
                                                    {
                                                        counter=counter+1;
                                                    }
                                                }
                                                if(counter>=productAdminMap.get(adminProd).get(Constant.siHelper_TechnicalSales).get(Constant.siHelper_CourseCount))
                                                {
                                                    score = score+1;
                                                }
                                            }
                                            else
                                            {
                                                score = score+1; 
                                            }
                                            
                                            //Architect Validation
                                            counter=0;
                                            if(pcCompleteMap.get(act.Id).get(prod).containsKey(Constant.siHelper_Architect))
                                            {
                                                for(String courseName: pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_Architect).keySet())
                                                {
                                                    if(pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_Architect).get(courseName)>=productAdminMap.get(adminProd).get(Constant.siHelper_Architect).get(Constant.siHelper_UserCount))
                                                    {
                                                        counter=counter+1;
                                                    }
                                                }
                                                if(counter>=productAdminMap.get(adminProd).get(Constant.siHelper_Architect).get(Constant.siHelper_CourseCount))
                                                {
                                                    score = score+1;
                                                }
                                            }
                                            else
                                            {
                                                score = score+1; 
                                            }
                                            
                                            //Care Validation
                                            counter=0;
                                            if(pcCompleteMap.get(act.Id).get(prod).containsKey(Constant.siHelper_Care))
                                            {
                                                
                                                for(String courseName: pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_Care).keySet())
                                                {
                                                    if(pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_Care).get(courseName)>=productAdminMap.get(adminProd).get(Constant.siHelper_Care).get(Constant.siHelper_UserCount))
                                                    {
                                                        counter=counter+1;
                                                    }
                                                }
                                                if(counter>=productAdminMap.get(adminProd).get(Constant.siHelper_Care).get(Constant.siHelper_UserCount))
                                                {
                                                    score = score+1;
                                                }
                                            }
                                            else
                                            {
                                                score = score+1; 
                                            }
                                            
                                            //Technical Support Validation
                                            counter=0;
                                            if(pcCompleteMap.get(act.Id).get(prod).containsKey(Constant.siHelper_TechnicalSupport))
                                            {
                                                for(String courseName: pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_TechnicalSupport).keySet())
                                                {
                                                    if(pcCompleteMap.get(act.Id).get(prod).get(Constant.siHelper_TechnicalSupport).get(courseName)>=productAdminMap.get(adminProd).get(Constant.siHelper_TechnicalSupport).get(Constant.siHelper_UserCount))
                                                    {
                                                        counter=counter+1;
                                                    }
                                                }
                                                if(counter>=productAdminMap.get(adminProd).get(Constant.siHelper_TechnicalSupport).get(Constant.siHelper_CourseCount))
                                                {
                                                    score = score+1;
                                                }
                                            }
                                            else
                                            {
                                                score = score+1; 
                                            }
                                        }
                                    }
                                        if(act.Product_Trainings_Completed__c!=null)
                                        {
                                           if(!act.Product_Trainings_Completed__c.containsIgnoreCase(adminProd) && score==5)
                                            {
                                                    act.Product_Trainings_Completed__c +=(Constant.siHelper_Symbol4+adminProd+Constant.siHelper_Symbol4);
                                                    if(!accountIdSet.contains(act.Id))
                                                    {
                                                        accountIdSet.add(act.Id);
                                                        updatableAccounts.add(act);
                                                    }
                                            }
                                            else if(act.Product_Trainings_Completed__c.containsIgnoreCase(adminProd) && score<5)
                                            {
                                                act.Product_Trainings_Completed__c = act.Product_Trainings_Completed__c.replaceAll(Constant.siHelper_Symbol2+adminProd+Constant.siHelper_Symbol3,Constant.siHelper_Symbol4);
                                                if(!accountIdSet.contains(act.Id))
                                                {
                                                    accountIdSet.add(act.Id);
                                                    updatableAccounts.add(act);
                                                }
                                            }
                                        }
                                        else
                                        {
                                            if(score==5)
                                            {
                                                act.Product_Trainings_Completed__c = adminProd;
                                                if(!accountIdSet.contains(act.Id))
                                                {
                                                    accountIdSet.add(act.Id);
                                                    updatableAccounts.add(act);
                                                }
                                            }
                                        }   
                                    
                                }
                                
                            }
                            else
                            {
                                String[] prodList= accountProdMap.get(act.Id);
                                for(String prod: prodList)
                                {
                                    adminProd= prodNameMap.get(prod);
                                    if(act.Product_Trainings_Completed__c!=null)
                                    {
                                        if(act.Product_Trainings_Completed__c.containsIgnoreCase(adminProd))
                                        {
                                            act.Product_Trainings_Completed__c = act.Product_Trainings_Completed__c.replaceAll(Constant.siHelper_Symbol2+adminProd+Constant.siHelper_Symbol3,Constant.siHelper_Symbol4);
                                            if(!accountIdSet.contains(act.Id))
                                            {
                                                accountIdSet.add(act.Id);
                                                updatableAccounts.add(act);
                                             }
                                        }
                                    }
                                }
                            }
                    }
                    
                    if(!updatableAccounts.isEmpty() && updatableAccounts != null)
                    {
                        update updatableAccounts;
                        accountIdSet.clear();
                        updatableAccounts.clear();
                    }
                }      
            }
        }
        catch(exception e)
        {
         ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    
    /*This is the method to update Topics picklist on the basis of creation / Updation on Topics record*/
     @future(callout=true)
     public static void updateTopicsPickListMetadata(String sessionId)
     {
        list <Topic__c> topicList = new list <Topic__c>();
        set <String> activeTopicList = new set<String>();
        try
        {
            topicList = [SELECT Id,Name FROM Topic__c WHERE Name != null AND Topic_Status__c =:Constant.siHelper_Active];
            if(!topicList.isEmpty() && topicList != null)
            {
                for(Topic__c tp : topicList)
                {
                    activeTopicList.add(tp.Name);
                }
                
            }
            List<MetadataService.UpdateMetadata> updates = new  List<MetadataService.UpdateMetadata>();
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = sessionId;
            MetadataService.CustomField customField = new MetadataService.CustomField();
            customField.fullName =Constant.siHelper_News_KavTopics_c;
            customField.label=Constant.siHelper_Topics;
            customField.type_x = Constant.siHelper_MultiselectPicklist;
            customField.visibleLines = 4; 
            metadataservice.Picklist pt = new metadataservice.Picklist();
            pt.sorted= True;
            pt.picklistValues = new List<metadataservice.PicklistValue>();
            if(!activeTopicList.isEmpty() && activeTopicList != null)
            {
                metadataservice.PicklistValue pv ;
                for(String picVal : activeTopicList)
                {
                    pv = new metadataservice.PicklistValue();
                    pv.fullName = picVal;
                    pv.default_x = false;
                    pt.picklistValues.add(pv);
                }            
            }       
            else
            {
                metadataservice.PicklistValue pv = new metadataservice.PicklistValue();
                pv.fullName = Constant.siHelper_None;
                pv.default_x = false;
                pt.picklistValues.add(pv);
            }
            customField.picklist = pt;
            MetadataService.UpdateMetadata ut = new MetadataService.UpdateMetadata();
            ut.currentName= Constant.siHelper_News_KavTopics_c;
            ut.metadata= customField;
            updates.add(ut);
            MetadataService.AsyncResult[] results = service.updateMetadata(updates);
        }
        catch (Exception e)
        {
          ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
     }
     
         
     /*Name:updateOptyAfterProductupdate
      * Description:this is for Auto deal Approval
      */
    public static void updateOptyAfterProductupdate(set <Id> optySet,Decimal Percentage)
    {
      try{
        list <Opportunity> updatableOppties =new list<Opportunity>();
            
            if(!optySet.isEmpty() && optySet!= null)
            {
                updatableOppties = [SELECT Id,StageName,Cumulative_List_Price__c,Cumulative_OTC_Price__c,Discounted_Price__c,Cumulative_OTC_Discount_Price__c,Discounted_Percentage__c FROM Opportunity WHERE Id IN : optySet];
                
                AggregateResult[] groupedResults = [SELECT Deal__c, SUM(List_Price__c) ListPrice,SUM(one_time_revenue__c) OTCPrice, SUM(Discounted_Price__c) DiscountedPrice, SUM(One_Time_Revenue_Discount_Price__c) OTCDiscountPrice FROM SPProduct__c WHERE Deal__c IN : optySet GROUP BY Deal__c];
                if(!groupedResults.isEmpty()&& groupedResults!=null)
                {
                    for(Opportunity opty: updatableOppties)
                    {
                        for(AggregateResult agr:groupedResults)
                        {
                            if(agr.get(Constant.siHelper_Deal)==opty.Id)
                            {
                                opty.Cumulative_OTC_Discount_Price__c = (Decimal)agr.get(Constant.siHelper_OTCDiscountedPrice);
                                opty.Discounted_Price__c = (Decimal)agr.get(Constant.siHelper_DiscountedPrice);
                                opty.Cumulative_List_Price__c =(Decimal)agr.get(Constant.siHelper_ListPrice);
                                opty.Cumulative_OTC_Price__c =(Decimal)agr.get(Constant.siHelper_OTCPrice);
                                opty.StageName =SIConstants.OPTY_DEAL_Auto_Approved;
                                opty.Discounted_Percentage__c=Percentage;
                            }
                        }
                    }
                    update updatableOppties;
                }               
            }
        }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }
    
    
    /* Name:calculatePromotionDiscountOnPP
     * Description:Business logic to calcluate promotion discounts on product pricing records.
     */
    public static list<Product_Pricing__c> calculatePromotionDiscountOnPP( list<Opportunity> selectedOptys, list<Promotion_Engine_Junction__c> listFinalPromoRecords, list<Product_Pricing__c> updatePPRecords, map<Promotion_Engine_Junction__c, Decimal> mapPEFinalDiscount)
   {
        Boolean checkProductType;
        try{
            for(Opportunity optys : selectedOptys)
            {
                for(Promotion_Engine_Junction__c peJ :listFinalPromoRecords)
                {
                    if(optys.Id == peJ.Opportunity__c)
                    {
                        for(Product_Pricing__c pp : updatePPRecords)
                        {
                            if(pp.Deal_Id__c == optys.Id && peJ.Rank__c != 5 && peJ.Rank__c != 6 )
                            {
                                checkProductType=false;
                                if(peJ.Valid_For_Product__c!=null)
                                {
                                    if(peJ.Valid_For_Product__c.equalsIgnoreCase(pp.Product_Record_Type__c))
                                    {
                                        checkProductType=true;
                                    }
                                }
                                else
                                {
                                    checkProductType=true;
                                }                               
                                if(checkProductType)
                                {
                                    if(pp.Discountable__c==false)
                                    {
                                       if(pp.Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE)
                                        {
                                            if(pp.Discounted_Usage_Charge__c==null||pp.Discounted_Usage_Charge__c==Constant.siHelper_Zero)
                                            {
                                               if(peJ.Rank__c == Constant.siHelper_Three)
                                                {
                                                    pp.Discounted_Usage_Charge__c = pp.Usage_Charges__c - SIHelper.Round4Digit((pp.Usage_Charges__c * mapPEFinalDiscount.get(peJ))/Constant.siHelper_Hundred);
                                                }
                                                else if(peJ.Rank__c == Constant.siHelper_Four && (optys.Standard_Discount_Percentage__c!=null || optys.Custom_Deal_Reg_Percentage__c !=null))
                                                {
                                                    if(optys.Standard_Discount_Percentage__c!=null)
                                                    {
                                                            pp.Discounted_Usage_Charge__c = pp.Usage_Charges__c - SIHelper.Round4Digit((pp.Usage_Charges__c * optys.Standard_Discount_Percentage__c)/Constant.siHelper_Hundred);
                                                    }
                                                    else{
                                                            pp.Discounted_Usage_Charge__c = pp.Usage_Charges__c - SIHelper.Round4Digit((pp.Usage_Charges__c * optys.Custom_Deal_Reg_Percentage__c)/Constant.siHelper_Hundred);
                                                    }
                                                }
                                                else if(peJ.Rank__c != Constant.siHelper_Four)
                                                {
                                                    pp.Discounted_Usage_Charge__c = pp.Usage_Charges__c - SIHelper.Round4Digit((pp.Usage_Charges__c * peJ.Discount_Percentage__c)/Constant.siHelper_Hundred);
                                                }
                                            }
                                            else
                                            {
                                                
                                                if(peJ.Rank__c == Constant.siHelper_Three)
                                                {
                                                    pp.Discounted_Usage_Charge__c = pp.Discounted_Usage_Charge__c - SIHelper.Round4Digit((pp.Discounted_Usage_Charge__c * mapPEFinalDiscount.get(peJ))/Constant.siHelper_Hundred);
                                                    
                                                }
                                                else if(peJ.Rank__c == Constant.siHelper_Four && (optys.Standard_Discount_Percentage__c!=null || optys.Custom_Deal_Reg_Percentage__c !=null))
                                                {
                                                    
                                                    if(optys.Standard_Discount_Percentage__c!=null){
                                                        
                                                        pp.Discounted_Usage_Charge__c = pp.Discounted_Usage_Charge__c - SIHelper.Round4Digit((pp.Discounted_Usage_Charge__c * optys.Standard_Discount_Percentage__c)/Constant.siHelper_Hundred);
                                                    }
                                                    else{
                                                        
                                                        pp.Discounted_Usage_Charge__c = pp.Discounted_Usage_Charge__c - SIHelper.Round4Digit((pp.Discounted_Usage_Charge__c * optys.Custom_Deal_Reg_Percentage__c)/Constant.siHelper_Hundred);
                                                    }
                                                }
                                                else if(peJ.Rank__c != Constant.siHelper_Four){
                                                    
                                                    pp.Discounted_Usage_Charge__c = pp.Discounted_Usage_Charge__c - SIHelper.Round4Digit((pp.Discounted_Usage_Charge__c * peJ.Discount_Percentage__c)/Constant.siHelper_Hundred);
                                                }
                                            }
                                        }else{
                                                if(pp.Discounted_Price__c==null||pp.Discounted_Price__c==Constant.siHelper_Zero || pp.SP_Discount_Percentage__c!=null)
                                                {
                                                    if(peJ.Rank__c == Constant.siHelper_Three)
                                                    {
                                                        pp.discount_price__c = SIHelper.applyRound((pp.List_Price__c * mapPEFinalDiscount.get(peJ))/Constant.siHelper_Hundred);
                                                        pp.Discounted_Price__c = pp.List_Price__c - pp.discount_price__c;
                                                    }
                                                    else if(peJ.Rank__c == 4 && (optys.Standard_Discount_Percentage__c!=null || optys.Custom_Deal_Reg_Percentage__c !=null))
                                                    {
                                                        if(optys.Standard_Discount_Percentage__c!=null)
                                                        {
                                                            pp.discount_price__c = SIHelper.applyRound((pp.List_Price__c * optys.Standard_Discount_Percentage__c)/Constant.siHelper_Hundred);
                                                            pp.Discounted_Price__c = pp.List_Price__c - pp.discount_price__c;
                                                        }else{
                                                            // DEFECT FIX - 183750 -START
                                                            //pp.discount_price__c = SIHelper.applyRound((pp.List_Price__c * optys.Custom_Deal_Reg_Percentage__c)/Constant.siHelper_Hundred); 
                                                            pp.discount_price__c = (pp.List_Price__c * optys.Custom_Deal_Reg_Percentage__c)/Constant.siHelper_Hundred;
                                                            // DEFECT FIX - 183750 - END
                                                            
                                                            pp.Discounted_Price__c = pp.List_Price__c - pp.discount_price__c;
                                                        }
                                                    }
                                                    else if(peJ.Rank__c != Constant.siHelper_Four)
                                                    {
                                                        pp.discount_price__c = SIHelper.applyRound((pp.List_Price__c * peJ.Discount_Percentage__c)/Constant.siHelper_Hundred);
                                                        pp.Discounted_Price__c = pp.List_Price__c - pp.discount_price__c;
                                                    }
                                                    
                                                    pp.SP_Discount_Percentage__c=null;
                                                }
                                                else
                                                {
                                                     if(peJ.Rank__c == Constant.siHelper_Three)
                                                     {
                                                        pp.discount_price__c = SIHelper.applyRound((pp.Discounted_Price__c * mapPEFinalDiscount.get(peJ))/Constant.siHelper_Hundred);
                                                        pp.Discounted_Price__c = pp.Discounted_Price__c - pp.discount_price__c;
                                                     }
                                                     else if(peJ.Rank__c == 4 && (optys.Standard_Discount_Percentage__c!=null || optys.Custom_Deal_Reg_Percentage__c !=null))
                                                     {
                                                         if(optys.Standard_Discount_Percentage__c!=null)
                                                         {
                                                             pp.discount_price__c = SIHelper.applyRound((pp.Discounted_Price__c * optys.Standard_Discount_Percentage__c)/Constant.siHelper_Hundred);
                                                             pp.Discounted_Price__c = pp.Discounted_Price__c - pp.discount_price__c;
                                                         }else
                                                         {
                                                             decimal disc = 0;
                                                             disc = SIHelper.applyRound((pp.Discounted_Price__c * optys.Custom_Deal_Reg_Percentage__c)/Constant.siHelper_Hundred);
                                                             pp.Discounted_Price__c = pp.Discounted_Price__c - disc;
                                                             pp.discount_price__c = pp.discount_price__c +  disc;
                                                             
                                                         }
                                                     }
                                                     else if(peJ.Rank__c != Constant.siHelper_Four)
                                                     {
                                                        pp.discount_price__c = SIHelper.applyRound((pp.Discounted_Price__c * peJ.Discount_Percentage__c)/Constant.siHelper_Hundred);
                                                        pp.Discounted_Price__c = pp.Discounted_Price__c - pp.discount_price__c;
                                                     }
                                                }
                                        }
                                    }
                                    else
                                    {
                                       if(pp.Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE){
                                            pp.Discounted_Usage_Charge__c=pp.Usage_Charges__c;
                                       }else{
                                        pp.discount_price__c=0;
                                        pp.Discounted_Price__c=pp.List_Price__c;
                                       }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }catch(Exception e)
        {
         ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));    
        }
        return updatePPRecords;
    }
    
    
    /*Name:genericPromotionEnginelogic
     * Description:Generic business logic to calculate promotion engine discounts
     */
    public static void genericPromotionEnginelogic(list<Opportunity> optylist)
    {
      try{
        list<Opportunity> selectedOptys = optylist;
        list<Product_Pricing__c> updatePPRecords = new list<Product_Pricing__c>();
        set<Id> optyId = new set<Id>();
        list<Product_Pricing__c> finalProductPricingList = new list<Product_Pricing__c>();
        
        for(Opportunity  getOptyID : selectedOptys)
        {
            optyId.add(getOptyID.Id);
        }
        updatePPRecords = [SELECT Deal_Id__c,Product_Record_Type__c,SP_Discount_Percentage__c,Type__c,Discountable__c,List_Price__c,discount_price__c,Discounted_Price__c, Record_Type__c,Usage_Charges__c,Discounted_Usage_Charge__c FROM Product_Pricing__c pr WHERE pr.SP_Product__c IN (SELECT Id FROM SPProduct__c WHERE Deal__c IN:optyId) AND (Type__c= :SIConstants.TYPE_MRC OR Type__c= :SIConstants.TYPE_NRC OR Type__c= :SIConstants.TYPE_MUC)];
        if(updatePPRecords!=null && SIConstants.avoidrecursivecallOnHelper)
        {
            SIConstants.avoidrecursivecallOnHelper=false;
            List<Promotion_Engine_Junction__c> promoEngineRecordsWithThirdRank = [select Id, Activation_Date__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c, Input_Field__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Opportunity__c from Promotion_Engine_Junction__c where Eligible__c = true and Rank__c = :Constant.siHelper_Three AND Opportunity__c IN:optyId order by Rank__c ];
            List<Promotion_Engine_Junction__c> promoEngineRecords = [select Id, Activation_Date__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c, Input_Field__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Opportunity__c from Promotion_Engine_Junction__c where Eligible__c = true and Opportunity__c IN:optyId AND ID NOT IN:promoEngineRecordsWithThirdRank order by Rank__c ];
            Map<String, List<Promotion_Engine_Junction__c>> mapPERankedThirdGroupedByProduct = new Map<String, List<Promotion_Engine_Junction__c>>();
            for( Promotion_Engine_Junction__c peThirdItem :promoEngineRecordsWithThirdRank ){
                
                List<Promotion_Engine_Junction__c> tempList = new List<Promotion_Engine_Junction__c>();
                for( Promotion_Engine_Junction__c peThirdItemIterable :promoEngineRecordsWithThirdRank ){
                    if( peThirdItem.Valid_For_Product__c == peThirdItemIterable.Valid_For_Product__c){
                            tempList.add( peThirdItemIterable );
                            mapPERankedThirdGroupedByProduct.put( peThirdItem.Valid_For_Product__c, tempList );
                    }   
                }
            }  
            Map<Promotion_Engine_Junction__c, Decimal> mapPEFinalDiscount = new Map<Promotion_Engine_Junction__c, Decimal>();
             Promotion_Engine_Junction__c promoJunciton ;
            for(String eachProduct : mapPERankedThirdGroupedByProduct.keyset()){
                Decimal discountPerc;
                Integer loopCounter = Constant.siHelper_Zero;
                PromoJunciton = new Promotion_Engine_Junction__c();
                for( Promotion_Engine_Junction__c PromoJuncitonItem : mapPERankedThirdGroupedByProduct.get( eachProduct ) ){
                    if( loopCounter == Constant.siHelper_Zero ){
                        PromoJunciton = PromoJuncitonItem;
                        discountPerc = PromoJuncitonItem.Discount_Percentage__c;
                    }else{
                        discountPerc += PromoJuncitonItem.Discount_Percentage__c; 
                    }
                    loopCounter++;
                }
                mapPEFinalDiscount.put(PromoJunciton, discountPerc);
            }
            
            promoEngineRecords.addAll(mapPEFinalDiscount.keySet()); 
            
            List<Promotion_Engine_Junction__c> listFinalPromoRecords = [select Id, Activation_Date__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c, Input_Field__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Opportunity__c from Promotion_Engine_Junction__c where Eligible__c = true and Id IN:promoEngineRecords order by Rank__c];
            for(Product_Pricing__c prodPric:updatePPRecords)
            {
                prodPric.Discounted_Price__c=null;
            }
            Boolean checkProductType;
            try{
                if( promoEngineRecords!=null && promoEngineRecords.size() > Constant.siHelper_Zero )
                {
                    updatePPRecords = calculatePromotionDiscountOnPP( selectedOptys, listFinalPromoRecords, updatePPRecords, mapPEFinalDiscount );
                    //Update special pricing values
                    for(Product_Pricing__c prodPric:updatePPRecords)
                    {
                        if(prodPric.Discounted_Price__c!=null)
                        {
                            finalProductPricingList.add(prodPric);
                        }
                    }
                    if(finalProductPricingList!=null && finalProductPricingList.size()>0)
                    {
                        update finalProductPricingList;
                    }
                }  
            }catch(Exception excep) {
           }
        }
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }
     
/* 
 Name: sharingPartnerRule
 Description: 
 */ 
     public static void sharingPartnerRule(List<ID> opptyIds, String shareObjectName){
      try{
        List<Opportunity> opptyList = [SELECT Id,Account.Name FROM Opportunity where Id in:opptyIds];  
        Map<String,String> opptyRoleNameMap = new   Map<String,String> (); 
        Map<String,String> roleIdRoleNameMap = new   Map<String,String> (); 
        Map<String,String> roleNameGroupId = new   Map<String,String> (); 
        List<sObject> objects = new List<sObject>();
        String objecName = shareObjectName;     
        if(opptyList.size() > Constant.siHelper_Zero) {
            for(Opportunity  oppty : opptyList)  {
                String roleName = oppty.Account.Name + Constant.siHelper_PartnerUser;
                 opptyRoleNameMap.put(oppty.id,roleName);
              
             }
            
        }     
         
                  
        if(opptyRoleNameMap.size() > Constant.siHelper_Zero)  {          
            List <UserRole> roleLIst = [Select Id,Name From UserRole Where Name in :opptyRoleNameMap.values() ];
            if(roleLIst.size() > Constant.siHelper_Zero) {
                for(UserRole  role : roleLIst)  {
                    roleIdRoleNameMap.put(role.id,role.Name);
              
                }
                if(roleIdRoleNameMap.size() > Constant.siHelper_Zero) {
                    List<Group> roleGroupList = [Select Id,relatedId From Group Where Type =  :Constant.Type AND relatedId in :roleIdRoleNameMap.keySet()];
                    if(roleGroupList.size() > Constant.siHelper_Zero) {
                        for(Group  roleGroup : roleGroupList)  {
                            if(roleIdRoleNameMap.containsKey(roleGroup.relatedId)) {
                                String roleName = roleIdRoleNameMap.get(roleGroup.relatedId); 
                                roleNameGroupId.put(roleName,roleGroup.Id);                                 
                            }    
              
                         }
                        
                    }
                }
                
            }
        }
      
        if(roleNameGroupId.size() > Constant.siHelper_Zero) {
            for(Opportunity  oppty : opptyList)  {
                if(opptyRoleNameMap.containsKey(oppty.id)) {
                    String roleName = opptyRoleNameMap.get(oppty.id); 
                    if(roleNameGroupId.containsKey(roleName)) {
                        Id grpID =  roleNameGroupId.get(roleName);
                        sObject sObj = Schema.getGlobalDescribe().get(objecName).newSObject();                 
                        sObj.put(Constant.siHelper_OpportunityId , oppty.id) ;                       
                        sObj.put(Constant.siHelper_UserOrGroupId , grpID) ;
                    //    sObj.put(UtilityConstant.ACCOUNTACCESSLEVEL , UtilityConstant.READ) ;   
                        sObj.put(Constant.siHelper_OpportunityAccessLevel , Constant.siHelper_Edit) ;    
                        objects.add(sObj);
                        
                        
                    } 
                } 
            }
            
            if(objects.size() > Constant.siHelper_Zero) {
                insert objects; 
            }
            
        }     
       }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    
    }
    
   
/* 
 Name: createSPSharingPartnerRule
 Description: 
 */ 
    public static void createSPSharingPartnerRule(String shareObjectName, Map<Id,Id> parentAccountMap){
      try{    
        List<Id> acctIds = parentAccountMap.values();
        List<Account> acctList = [SELECT Id,Name FROM Account where Id in:acctIds];  
        Map<String,String> acctRoleNameMap = new   Map<String,String> (); 
        Map<String,String> roleIdRoleNameMap = new   Map<String,String> (); 
        Map<String,String> roleNameGroupId = new   Map<String,String> (); 
        
        List<sObject> objects = new List<sObject>();
        
        if(acctList.size() > Constant.siHelper_Zero) {
            for(Account  acct : acctList)  {
                String roleName = acct.Name + Constant.siHelper_PartnerUser;
                 acctRoleNameMap.put(acct.id,roleName);
             }
            
        }   
         
                  
        if(acctRoleNameMap.size() > Constant.siHelper_Zero)  {           
            List <UserRole> roleLIst = [Select Id,Name From UserRole Where Name in :acctRoleNameMap.values() ];
            if(roleLIst.size() > Constant.siHelper_Zero) {
                for(UserRole  role : roleLIst)  {
                    roleIdRoleNameMap.put(role.id,role.Name);
                }
                if(roleIdRoleNameMap.size() > Constant.siHelper_Zero) {
                    List<Group> roleGroupList = [Select Id,relatedId From Group Where Type = :Constant.siHelper_Type AND relatedId in :roleIdRoleNameMap.keySet()];
                    if(roleGroupList.size() > Constant.siHelper_Zero) {
                        for(Group  roleGroup : roleGroupList)  {
                            if(roleIdRoleNameMap.containsKey(roleGroup.relatedId)) {
                                String roleName = roleIdRoleNameMap.get(roleGroup.relatedId); 
                                roleNameGroupId.put(roleName,roleGroup.Id); 
                            }    
              
                         }
                        
                    }
                }
                
            }
        }
        
        String queryString2 =SpecialCharacterConstant.CONCAT;
        Set<Id> parentKeyList = parentAccountMap.keySet();
        
        list<String> userGroupLIst = roleNameGroupId.values();
        String editConstant = Constant.siHelper_Edit;
        
        if(shareObjectName == UtilityConstant.ACCOUNTSHARE) {
            queryString2 = 'SELECT AccountId FROM AccountShare where AccountId in:parentKeyList and UserOrGroupId in:userGroupLIst and AccountAccessLevel = :editConstant and OpportunityAccessLevel = :editConstant';       
        } else {
            // using sObj Record Ids                 
            string editAccess = UtilityConstant.EDIT ;
            queryString2 = 'SELECT ParentID  FROM ' + shareObjectName + ' where ParentID in: parentKeyList and UserOrGroupId in:userGroupLIst  and AccessLevel  =:editConstant';
        }
        
        List<sObject> objectShareList = Database.query(queryString2);
       
        String listType = 'List<' + shareObjectName + '>';      
      
      
      for(sObject shareRecord : objectShareList) { 
        if(shareObjectName == UtilityConstant.ACCOUNTSHARE) {
            String parentId=(String)shareRecord.get('AccountId');     
           if(parentAccountMap.containsKey(parentId)) {                       
                parentAccountMap.remove(parentId);

            }
            
        } else {
            String parentId=(String)shareRecord.get('ParentID');      
            if(parentAccountMap.containsKey(parentId))    {                   
                parentAccountMap.remove(parentId);
            }
        }
      }
        if(parentAccountMap.size() > 0) {
            for(Id  parentKey : parentAccountMap.keySet())  {
                Id actId = parentAccountMap.get(parentKey);                           
                if(acctRoleNameMap.containsKey(actId)) {
                    String roleName = acctRoleNameMap.get(actId); 
                    if(roleNameGroupId.containsKey(roleName)) {
                        Id grpID =  roleNameGroupId.get(roleName);
                        sObject sObj = Schema.getGlobalDescribe().get(shareObjectName).newSObject();                 
                        if(shareObjectName == UtilityConstant.ACCOUNTSHARE){
                            sObj.put(Constant.siHelper_AccountId , parentKey) ; 
                            sObj.put(Constant.siHelper_AccountAccessLevel , Constant.siHelper_Edit) ;   
                            sObj.put(Constant.siHelper_OpportunityAccessLevel , Constant.siHelper_Edit) ; 
                        } else {
                            sObj.put(Constant.siHelper_ParentId ,parentKey) ;
                            sObj.put(Constant.siHelper_AccessLevel , Constant.siHelper_Edit) ;
                        }                                 
                        sObj.put(Constant.siHelper_UserOrGroupId , grpID) ;
                          
                        if(parentKey != null) {
                           objects.add(sObj);
                       }
                        
                        
                    } 
                } 
            }
            
            if(objects.size() > 0) {
                insert objects; 
            }
            
        }     
        
    
    }catch(Exception ex){
                ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            } 
    } 
}