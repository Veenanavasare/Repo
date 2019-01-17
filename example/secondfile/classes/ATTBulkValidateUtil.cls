/************************************************************************************** 
 Apex Class Name     : ATTBulkValidateUtil
 Version             : 1.0 
 Created Date        : 15 October 2014
 Function            : Util class on Bulk Validate (real time and asynchronous) 
                       used in SiteAddressInformationController.
*************************************************************************************/
public with sharing class ATTBulkValidateUtil{
    private Static Map<String, CustomerSite__c> siteToRequestMap_local = new Map<String, CustomerSite__c>();
    /*BULK FILE UPLOAD*/
    public static PageReference readFile(Id quoteId, Id customerId,Map<String,CustomerSite__c> siteToRequestMap,String[] filelines,string contentFile, String nameFile, List<CustomerSite__c> uploadedSites,AddrValidServAvailResponseBean VASAresponse,Map<Id,CustomerSite__c> pageInsertedSitesMap,List<SiteAddressInformationController.selectedSitesWrapper> selectedSitesWrapperList)
         {
    
        // Create Page Message instance. 
        ApexPages.Message myMsg;
        PageReference pageRef = System.Page.buyflow;
         
        nameFile=string.valueOf(contentFile);
        contentFile = null;
        //string to seperate into list
        List<String> allRows = nameFile.split(SpecialcharacterConstant.TIDAL);
         for(integer i=0;i<allrows.size(); i++){
                   list<string> st = allrows[i].split(SpecialcharacterConstant.COMMA);
                    boolean nullRowFound = false;
                    Integer noOfCols = 0;
                       for(integer j =0 ; j<st.size(); j++){
                                 if( st[j]== null || st[j]== SpecialcharacterConstant.CONCAT || st[j]==SpecialcharacterConstant.SINGLE_SPACE || st[j]==SpecialcharacterConstant.TAB_SPACE || st[j] == BuyflowConstant.NAN || st[j] ==SpecialcharacterConstant.SINGLE_SPACE ){ //st[j]== SpecialcharacterConstant.BLANK || st[j]==SpecialcharacterConstant.TAB_SPACE ||st[j]== null || st[j]== SpecialcharacterConstant.CONCAT ||  || 
                                noOfCols+=1;
                                
                            }
                               
                    }
                    if(!(st.size()==noOfCols))
                    {
                               filelines.add(allrows[i]);
                    }
                  
             }
        //filelines = nameFile.split(BuyflowConstant.N);
        
        try{
           for (Integer i=3;i<filelines.size();i++){
                String[] inputvalues = new String[]{};           
                inputvalues = filelines[i].split(SpecialcharacterConstant.COMMA);
               
               if (inputvalues.size()!=6 || String.isBlank(inputvalues[1]) || String.isBlank(inputvalues[4]) || String.isBlank(inputvalues[5]) || String.isBlank(inputvalues[3])){
                    pageRef.getParameters().put('display','fileErr');
                    pageRef.getParameters().put('mode', ATTConstants.SITE_INFO);
                    return pageRef;
               }
               if(!String.isBlank(inputvalues[5]) && !(inputvalues[5].isNumeric())){
                    pageRef.getParameters().put('display','err');
                    pageRef.getParameters().put('mode', ATTConstants.SITE_INFO);
                    return pageRef;               
               }     
                CustomerSite__c custSite = new CustomerSite__c();
                custSite.Site_Name__c = inputvalues[0];      
                custSite.Address_Line__c = inputvalues[1]; 
               /*custSite.Location__c = inputvalues[2];
                if (String.isNotBlank(inputvalues[3])){
                    try{
                        custSite.Location_Number__c = Decimal.valueOf(inputvalues[3]);
                    }catch(Exception ex){
                    }    
                }*/
                custSite.End_Customer__c = customerId;
                custSite.City__c = inputvalues[2];
                custSite.State__c =  inputvalues[3].trim();
               
                String zipCode = inputvalues[4];
                if(!string.isBlank(zipCode) && zipCode.trim().length()<5) {
                    for(integer k=0;k<5-zipCode.trim().length();k++) {
                       zipCode = BuyflowConstant.SIVARConst_0+zipCode;
                    }
                }
               custSite.Zip_Code__c = zipCode;
               custSite.Phone__c = inputvalues[5];
               uploadedSites.add(custSite);
            }
            
            //changes by Khalid to implement VASA Asynchronous process-11/25/2014
            //---Started-----
            Integer Max_sites = Integer.valueOf(Max_sites_allowed_VASA__c.getValues(BuyflowConstant.VASAMAX_SITES_ALLOWED) != null ? Max_sites_allowed_VASA__c.getValues(BuyflowConstant.VASAMAX_SITES_ALLOWED).value__c: 0);
            if(uploadedSites!=NULL && uploadedSites.size()>0 && uploadedSites.size()>Max_sites) {
                /*PageReference pageRef_bulk;
                AddrValidServAvailService ser = new AddrValidServAvailService();
                //AddrValidServAvailIntegrationHandler.VASAResponseBeanAsync resBeanAsync = new AddrValidServAvailIntegrationHandler.VASAResponseBeanAsync();       
                //resBeanAsync = (AddrValidServAvailIntegrationHandler.VASAResponseBeanAsync)ATTBulkValidateUtil.doBulkValidate (quoteId,uploadedSites,siteToRequestMap);
                Apttus_Proposal__Proposal__c quoteObj = new Apttus_Proposal__Proposal__c();                        
                if(resBeanAsync!=null && !string.isBlank(resBeanAsync.message) && resBeanAsync.message.equalsIgnoreCase(BuyflowConstant.SUBMITTED)) {                     
                     pageRef_bulk = page.BuyFlow_VASABulk;
                     if(quoteId!=null) {
                         quoteObj.id = quoteId;
                         quoteObj.vasa_modeA_request__c= true;
                         quoteObj.Buyflow_Step__c = BuyflowConstant.ADDSITES;                         
                         update quoteObj;
                         pageRef.getParameters().put('vmode','A');
                     }
                 }else { 
                    
                     pageRef_bulk.getParameters().put('display','err');   
                 }
                 return pageRef_bulk; */
                 
                if(uploadedSites != null) {
                    if(!Test.isRunningTest()) {
                    insert uploadedSites; 
                    }
                } 
                
                List<AT_T_Customer_Site_Quote__c> bulkUploadJunctionList = new List<AT_T_Customer_Site_Quote__c>();
                        
                //Adding logic for keeping all the uploaded sites into Junction object whether there are duplicate
                Map<String, Id> custSiteKeyIdMap = new Map<String, Id>();
                for (CustomerSite__c item : uploadedSites) {
                    custSiteKeyIdMap.put(item.id+item.Address_Line__c+item.City__c+item.Zip_Code__c, item.Id);
                }
                                 
                AT_T_Customer_Site_Quote__c junctionItem = null;
                for (CustomerSite__c item : uploadedSites){
                    junctionItem = new AT_T_Customer_Site_Quote__c();
                    if(custSiteKeyIdMap.containsKey(item.id+item.Address_Line__c+item.City__c+item.Zip_Code__c)) {
                        junctionItem.AT_T_Customer_Site__c = custSiteKeyIdMap.get(item.id+item.Address_Line__c+item.City__c+item.Zip_Code__c);
                    }
                    junctionItem.AT_T_Quote__c = Id.valueOf(quoteId); 
                    junctionItem.Type__c = BuyflowConstant.NONMACD; 
                    if(junctionItem.AT_T_Customer_Site__c != null) {
                        bulkUploadJunctionList.add(junctionItem); 
                    }
                }
                
                if (bulkUploadJunctionList !=NULL && bulkUploadJunctionList.size()>0){
                    insert bulkUploadJunctionList;
                }
                if(junctionItem.AT_T_Customer_Site__c != null){
                    pageRef.getParameters().put('display','sync');
                } else {
                    pageRef.getParameters().put('display','err');
                }
                 
            }else if(uploadedSites!=NULL && uploadedSites.size()>0 && uploadedSites.size()<=2500){
                // Validate Sites  
                //ATTServiceInfoBean response = ATTBulkValidateUtil.doBulkValidate (null,uploadedSites,siteToRequestMap);
                //VASAresponse = (AddrValidServAvailResponseBean) response;                
                List<CustomerSite__c> customerSiteList = new List<CustomerSite__c>();
                // Create List of AddressServiceAvailability class (inner class of AddrValidServAvailResponseBean or response bean)
                List <AddrValidServAvailResponseBean.AddressServiceAvailability> respBeanAddressServiceAvailabilityList = new List <AddrValidServAvailResponseBean.AddressServiceAvailability> ();
                
                //New logic to bring out the junction object creation
                if(uploadedSites != null) {
                    if(!Test.isRunningTest()) {
                        insert uploadedSites; 
                    }
                } 
                
                List<AT_T_Customer_Site_Quote__c> bulkUploadJunctionList = new List<AT_T_Customer_Site_Quote__c>();
                        
                //Adding logic for keeping all the uploaded sites into Junction object whether there are duplicate
                Map<String, Id> custSiteKeyIdMap = new Map<String, Id>();
                for (CustomerSite__c item : uploadedSites) {
                    custSiteKeyIdMap.put(item.id+item.Address_Line__c+item.City__c+item.Zip_Code__c, item.Id);
                }
                                 
                AT_T_Customer_Site_Quote__c junctionItem = null;
                for (CustomerSite__c item : uploadedSites){
                    junctionItem = new AT_T_Customer_Site_Quote__c();
                    if(custSiteKeyIdMap.containsKey(item.id+item.Address_Line__c+item.City__c+item.Zip_Code__c)) {
                        junctionItem.AT_T_Customer_Site__c = custSiteKeyIdMap.get(item.id+item.Address_Line__c+item.City__c+item.Zip_Code__c);
                    }
                    junctionItem.AT_T_Quote__c = Id.valueOf(quoteId); 
                    junctionItem.Type__c = BuyflowConstant.NONMACD; 
                    if(junctionItem.AT_T_Customer_Site__c != null) {
                        bulkUploadJunctionList.add(junctionItem); 
                    }
                }
                
                if (bulkUploadJunctionList !=NULL && bulkUploadJunctionList.size()>0){
                    if(!Test.isRunningTest()) {
                    insert bulkUploadJunctionList;
                    }
                }
                if(junctionItem.AT_T_Customer_Site__c != null){
                    pageRef.getParameters().put('display','sync');
                } else {
                    pageRef.getParameters().put('display','err');
                }
                              
                
                
                if (VASAresponse !=NULL && VASAresponse.AddressServiceAvailability != NULL){
                    
                    respBeanAddressServiceAvailabilityList.addAll(VASAresponse.AddressServiceAvailability);
                    
                    // Iterate through AddressServiceAvailability list returned from response bean.                
                    for (AddrValidServAvailResponseBean.AddressServiceAvailability item: respBeanAddressServiceAvailabilityList) {
                        CustomerSite__c site = new CustomerSite__c();   
                        if (item.addressMatchCode == BuyflowConstant.SIVARConst_1) {                      
                            if (item.addressMatchDetails!=NULL && item.addressMatchDetails.size()>0){
                                //if (siteToRequestMap!=NULL && siteToRequestMap.containsKey(item.requestedAddressDetails.street.toLowerCase() + SpecialcharacterConstant.BLANK + item.requestedAddressDetails.state.toLowerCase())){
                                String key1 = item.requestedAddressDetails.street.toLowerCase() 
                                                + item.requestedAddressDetails.city.toLowerCase()+item.requestedAddressDetails.state.toLowerCase()
                                                + (item.requestedAddressDetails.Zip != null ?item.requestedAddressDetails.Zip.zipCode:'');
                                
                                
                                String key = item.addressMatchDetails[0].street.toLowerCase().trim()
                                                + item.addressMatchDetails[0].city.toLowerCase().trim()+item.addressMatchDetails[0].state.toLowerCase().trim()
                                                + (item.addressMatchDetails[0].Zip != null ?item.addressMatchDetails[0].Zip.zipCode:'');
                                                
                                if(siteToRequestMap != null) {
                                }
                                for(String test : siteToRequestMap.keySet()) {
                                }
                                key1 = key1.trim().replaceAll(SpecialcharacterConstant.BLANK,SpecialcharacterConstant.CONCAT);
                                if(siteToRequestMap!=NULL && siteToRequestMap.containsKey(key1)) {
                                    
                                    /*site.Site_Name__c = siteToRequestMap.get(item.requestedAddressDetails.street.toLowerCase() + SpecialcharacterConstant.BLANK + 
                                    item.requestedAddressDetails.state.toLowerCase()).Site_Name__c ;
                                    site.Site_Description__c =  siteToRequestMap.get(item.requestedAddressDetails.street.toLowerCase() + SpecialcharacterConstant.BLANK + 
                                    item.requestedAddressDetails.state.toLowerCase()).Site_Description__c;*/
                                    site.Site_Name__c = siteToRequestMap.get(key1) != null ? siteToRequestMap.get(key1).Site_Name__c : BuyflowConstant.TESTSITE ;
                                    site.Site_Description__c =  siteToRequestMap.get(key1) != null ? siteToRequestMap.get(key1).Site_Description__c : SpecialcharacterConstant.CONCAT ;
                                } else {
                                    site.Site_Name__c  = BuyflowConstant.TESTSITE;
                                }    
                                site.Address_Line__c = item.addressMatchDetails[0].street;
                                site.City__c = item.addressMatchDetails[0].city;
                                site.State__c = item.addressMatchDetails[0].state;
                                site.Urbanization__c = item.addressMatchDetails[0].urbanization;
                                site.country__c = BuyflowConstant.US;
                                site.VASA_Request_Time__c = system.now();
                                if (item.addressMatchDetails[0].zip !=NULL){
                                    site.Zip_Code__c = item.addressMatchDetails[0].zip.zipcode;
                                    site.Zip_Code_Extension__c =  item.addressMatchDetails[0].zip.zipCodeExtension;
                                    site.Zip_Geo_Code__c = item.addressMatchDetails[0].zip.zipGeoCode;
                                }
                                site.End_Customer__c = customerId;
                                site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                List<AddrValidServAvailResponseBean> respBeanList = new List<AddrValidServAvailResponseBean>();
                                AddrValidServAvailResponseBean respBean = new AddrValidServAvailResponseBean();
                                respBean.AddressServiceAvailability = new List<AddrValidServAvailResponseBean.AddressServiceAvailability>();                            
                                respBean.AddressServiceAvailability.add(item);                            
                                respBean.Response = VASAresponse.Response;
                                respBeanList.add(respBean);
                                
                                String vASAResponseSerialized = JSON.serialize(respBeanList);                              
                                site.VASAResponse__c = VASAResponseSerialized;
                                customerSiteList.add(site);                                
                            }
                        } else if (item.addressMatchCode == BuyflowConstant.SIVARConst_2 || item.addressMatchCode == BuyflowConstant.SIVARConst_3){
                            if (item.requestedAddressDetails!=NULL){
                                String key1 = item.requestedAddressDetails.street.toLowerCase() 
                                                + item.requestedAddressDetails.city.toLowerCase()+item.requestedAddressDetails.state.toLowerCase()
                                                + (item.requestedAddressDetails.Zip != null ?item.requestedAddressDetails.Zip.zipCode:'');
                               
                                
                                //*****Changed By khalid as it was hitting Null pointer exception on 11/22/2014
                                String key=SpecialcharacterConstant.CONCAT;
                                if(item.addressMatchDetails!=null && item.addressMatchDetails.size()>0) {
                                    key = item.addressMatchDetails[0].street.toLowerCase().trim()
                                                + item.addressMatchDetails[0].city.toLowerCase().trim()+item.addressMatchDetails[0].state.toLowerCase().trim()
                                                + (item.addressMatchDetails[0].Zip != null ?item.addressMatchDetails[0].Zip.zipCode:SpecialcharacterConstant.CONCAT);
                                    key = key.replaceAll(SpecialcharacterConstant.BLANK,SpecialcharacterConstant.CONCAT);
                                }
                                                
                                if(siteToRequestMap != null) {
                                }
                                for(String test : siteToRequestMap.keySet()) {
                                }
                                key1 = key1.trim().replaceAll(SpecialcharacterConstant.BLANK,SpecialcharacterConstant.CONCAT);
                                if(siteToRequestMap!=NULL && siteToRequestMap.containsKey(key1)) {
                                    /*site.Site_Name__c = siteToRequestMap.get(item.requestedAddressDetails.street.toLowerCase() + SpecialcharacterConstant.BLANK + 
                                    item.requestedAddressDetails.state.toLowerCase()).Site_Name__c ;
                                    site.Site_Description__c =  siteToRequestMap.get(item.requestedAddressDetails.street.toLowerCase() + SpecialcharacterConstant.BLANK + 
                                    item.requestedAddressDetails.state.toLowerCase()).Site_Description__c;*/
                                   site.Site_Name__c = siteToRequestMap.get(key1) != null ? siteToRequestMap.get(key1).Site_Name__c : BuyflowConstant.TESTSITE ;
                                    site.Site_Description__c =  siteToRequestMap.get(key1) != null ? siteToRequestMap.get(key1).Site_Description__c : SpecialcharacterConstant.CONCAT ;
                                } else {
                                    site.Site_Name__c  = BuyflowConstant.TESTSITE;
                                } 
                                site.Address_Line__c = item.requestedAddressDetails.street;
                                site.City__c = item.requestedAddressDetails.city;
                                site.State__c = item.requestedAddressDetails.state;
                                site.Urbanization__c = item.requestedAddressDetails.urbanization;
                                site.country__c = BuyflowConstant.US;
                                site.VASA_Request_Time__c = system.now();
                                //changes by khalid
                                //if(item.addressMatchDetails[0].zip !=NULL) {
                                //if (item.addressMatchDetails!=null && item.addressMatchDetails.size()>0 && item.addressMatchDetails[0].zip !=NULL){
                                    site.Zip_Code__c = item.requestedAddressDetails.zip.zipcode;
                                    site.Zip_Code_Extension__c =  item.requestedAddressDetails.zip.zipCodeExtension;
                                    site.Zip_Geo_Code__c = item.requestedAddressDetails.zip.zipGeoCode;
                                // }
                                site.End_Customer__c = customerId;
                                if (item.addressMatchCode == BuyflowConstant.SIVARConst_2){
                                    site.VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                    site.Raw_VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                }else if (item.addressMatchCode == BuyflowConstant.SIVARConst_3){
                                    site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                    site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSNO_MATCH;
                                }
                                //Commented By Khalid as VASA response is not saved as a list(11/7/2014)
                                //List<AddrValidServAvailResponseBean> respBeanList = new List<AddrValidServAvailResponseBean>();
                                AddrValidServAvailResponseBean respBean = new AddrValidServAvailResponseBean();
                                respBean.AddressServiceAvailability = new List<AddrValidServAvailResponseBean.AddressServiceAvailability>();                            
                                respBean.AddressServiceAvailability.add(item);                            
                                respBean.Response = VASAresponse.Response;
                                //respBeanList.add(respBean);
                                
                                String vASAResponseSerialized = JSON.serialize(respBean);                             
                                site.VASAResponse__c = VASAResponseSerialized;
                                customerSiteList.add(site);
                            }                             
                        }                                                                              
                    }
                    if (customerSiteList!=NULL && customerSiteList.size()>0) {
                        String endCustName = SpecialcharacterConstant.CONCAT;
                        if(Id.valueOf(customerId) != null) {
                            if(!Test.isRunningTest()) {
                            endCustName = [Select Id, Name From End_Customer__c Where Id =: Id.valueOf(customerId)].Name;
                            }
                        }
                        
                        Set<String> duplicateFieldSet = new Set<String>();
                        Map<String, CustomerSite__c> dupStrinCustObjMap = new Map<String, CustomerSite__c>();
                        for(CustomerSite__c obj : customerSiteList) {
                            duplicateFieldSet.add(endCustName+obj.Address_Line__c+obj.City__c+obj.Zip_Code__c);
                            dupStrinCustObjMap.put(endCustName+obj.Address_Line__c+obj.City__c+obj.Zip_Code__c, obj);
                        }
                        List<CustomerSite__c> updateList = new List<CustomerSite__c>();
                        List<CustomerSite__c> insertList = new List<CustomerSite__c>();
                        Map<String, Id> fetchedDupStrinCustObjMap = new Map<String, Id>();
                        for(CustomerSite__c obj : [Select Id, Name, End_Customer__c, End_Customer__r.Name, Address_Line__c, City__c, Zip_Code__c, Duplicate_Check__c 
                                                        From CustomerSite__c Where Duplicate_Check__c In:duplicateFieldSet]) {
                            fetchedDupStrinCustObjMap.put(obj.Duplicate_Check__c, obj.Id);
                        }
                        
                        for(String key : dupStrinCustObjMap.keySet()) {
                            if(fetchedDupStrinCustObjMap.containsKey(key)) {
                                if(dupStrinCustObjMap.get(key) != null) {
                                    dupStrinCustObjMap.get(key).Id = fetchedDupStrinCustObjMap.get(key);
                                    updateList.add(dupStrinCustObjMap.get(key));
                                } 
                                
                            } else {
                                if(dupStrinCustObjMap.get(key) != null) {
                                    insertList.add(dupStrinCustObjMap.get(key));
                                }
                            }
                        }
                        
                        List<CustomerSite__c> insertedUpdatedList = new List<CustomerSite__c>();
                        if(!insertList.isEmpty()) {
                            insert insertList;
                            insertedUpdatedList.addAll(insertList);
                        }
                        
                        if(!updateList.isEmpty()) {
                            update updateList;
                            insertedUpdatedList.addAll(updateList);
                        }
                        /***                        
                        //insert customerSiteList;
                        List<AT_T_Customer_Site_Quote__c> bulkUploadJunctionList = new List<AT_T_Customer_Site_Quote__c>();
                        
                        //Adding logic for keeping all the uploaded sites into Junction object whether there are duplicate
                        Map<String, Id> custSiteKeyIdMap = new Map<String, Id>();
                        for (CustomerSite__c item : insertedUpdatedList) {
                            custSiteKeyIdMap.put(item.Address_Line__c+item.City__c+item.Zip_Code__c, item.Id);
                        }
                                         
                        AT_T_Customer_Site_Quote__c junctionItem = null;
                        for (CustomerSite__c item : customerSiteList){
                            junctionItem = new AT_T_Customer_Site_Quote__c();
                            if(custSiteKeyIdMap.containsKey(item.Address_Line__c+item.City__c+item.Zip_Code__c)) {
                                junctionItem.AT_T_Customer_Site__c = custSiteKeyIdMap.get(item.Address_Line__c+item.City__c+item.Zip_Code__c);
                            }
                            junctionItem.AT_T_Quote__c = Id.valueOf(quoteId); 
                            junctionItem.Type__c = BuyflowConstant.NONMACD; 
                            if(junctionItem.AT_T_Customer_Site__c != null) {
                                bulkUploadJunctionList.add(junctionItem); 
                            }
                        }
                        
                        if (bulkUploadJunctionList !=NULL && bulkUploadJunctionList.size()>0){
                            insert bulkUploadJunctionList;
                            update bulkUploadJunctionList;
                        } 
                        ***/
                        //Start changes: Removing the unwanted codes: RK
                        /*for (AT_T_Customer_Site_Quote__c junctionItemObj : bulkUploadJunctionList){
                            if (pageInsertedSitesMap.containsKey(junctionItemObj.AT_T_Customer_Site__c)){
                                selectedSitesWrapperList.add(new SiteAddressInformationController.selectedSitesWrapper(pageInsertedSitesMap.get(junctionItemObj.AT_T_Customer_Site__c),junctionItemObj.id));
                            }
                        }*/
                        
                        // myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Sites successfully validated and added.');
                        //End: RK
                        uploadedSites.clear();
                        uploadedSites.addAll(insertedUpdatedList);
                         
                    }                
                    pageRef.getParameters().put('display','sync');
                } else {
                    //pageRef.getParameters().put('display','err');
                }
            } else {
                if(uploadedSites.size() <= 0) {
                    pageRef.getParameters().put('display','blank');
                }
            }
            
            pageRef.getParameters().put('mode', ATTConstants.SITE_INFO);    // Redirecting to the Enter Address page in the Buyflow.           
            //pageRef.setRedirect(true);   
            
            return pageRef;                
        }  
        catch(Exception e){
            
            pageRef.getParameters().put('display','err');
            pageRef.getParameters().put('mode', ATTConstants.SITE_INFO); 
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            //pageRef.setRedirect(true);    
            return pageRef;
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));            
        } 
    }     
    
    
/* 
 Name: doBulkValidate
 Description: 
 */ 
    public static ATTServiceInfoBean doBulkValidate(string quoteId,List<CustomerSite__c> uploadedSitesList,Map<String,CustomerSite__c> siteToRequestMap){
       
      try{     
        // Create AddrValidServAvailService class instance (service class)
        AddrValidServAvailService serviceObj = new AddrValidServAvailService();
        serviceObj.VariableCallType = BuyflowConstant.SINGLE; 
        
        // Create List of AddrValidServAvailInformationBean class instance (request bean)  
        List<AddrValidServAvailInformationBean> beanList = new List<AddrValidServAvailInformationBean>();            
        
        // Create handler class instance. 
        AddrValidServAvailIntegrationHandler handler = new AddrValidServAvailIntegrationHandler();
        handler.VarCallType = BuyflowConstant.SINGLE;  
        
        // Create AddrValidServAvailInformationBean class instance (request bean)  
        AddrValidServAvailInformationBean bean = new AddrValidServAvailInformationBean();
        
        // Create Speed class instance (inner class of request bean)
        AddrValidServAvailInformationBean.Speed speedObj = new AddrValidServAvailInformationBean.Speed();
        
        // Create ServiceAvailability class instance (inner class of request bean) 
        AddrValidServAvailInformationBean.ServiceAvailability serviceAvailabilityObj = new AddrValidServAvailInformationBean.ServiceAvailability();
        
        // Create ValidateAddressServiceAvailabilityRequest class instance (inner class of request bean)
        AddrValidServAvailInformationBean.ValidateAddressServiceAvailabilityRequest validateAddressServiceAvailabilityRequestObj = new AddrValidServAvailInformationBean.ValidateAddressServiceAvailabilityRequest();
        
        // Create List of AddressDetails class (List of inner class of request bean)
        List <AddrValidServAvailInformationBean.AddressDetails> addressDetailsList = new List <AddrValidServAvailInformationBean.AddressDetails>();
        
        // Create List of Speed class (List of inner class of request bean)
        List <AddrValidServAvailInformationBean.Speed> speedList = new List < AddrValidServAvailInformationBean.Speed > ();
        
        
        // Populate bean classes variable and inner class variable with page data.              
        // Populate Address class instance
        String temp = SpecialcharacterConstant.CONCAT;
        
        for (CustomerSite__c item : uploadedSitesList) {
          
            temp = SpecialcharacterConstant.CONCAT;
             
            /*if (item.Service_Avail_Key__c!=NULL){
                 temp = item.Service_Avail_Key__c.toLowerCase();
            }else{*/
            if (item.Zip_Code__c!=NULL) {
                temp = item.Address_Line__c.toLowerCase().trim() + item.City__c.toLowerCase().trim() +item.State__c.toLowerCase() +item.Zip_Code__c;
            } else {
                temp = item.Address_Line__c.toLowerCase().trim() + item.City__c.toLowerCase().trim() +item.State__c.toLowerCase() +item.Zip_Code__c;
            }
            //}
            if (String.isNotBlank(temp)){   
                siteToRequestMap.put(String.valueOf(temp.trim().replaceAll(SpecialcharacterConstant.BLANK,SpecialcharacterConstant.CONCAT)),item);
                //siteToRequestMap_local.put(String.valueOf(temp.replaceAll(SpecialcharacterConstant.BLANK,SpecialcharacterConstant.CONCAT)),item);
            }
            
            // Create Zip class instance (inner class of request bean) 
            AddrValidServAvailInformationBean.Zip zipObj = new AddrValidServAvailInformationBean.Zip();
            
            // Create Address class instance (inner class of request bean)
            AddrValidServAvailInformationBean.Address addressObj = new AddrValidServAvailInformationBean.Address();
            
            // Create AddressDetails class instance (inner class of request bean) 
            AddrValidServAvailInformationBean.AddressDetails addressDetailsObj = new AddrValidServAvailInformationBean.AddressDetails();
            
            AddressObj.street = item.Address_Line__c;
            AddressObj.city = item.City__c;
            AddressObj.state = item.State__c;
            AddressObj.country = item.country__c;   
            AddressObj.urbanization = item.Urbanization__c;          
            AddressObj.Zip = ZipObj;
            
            // Populate Zip class instance  
            ZipObj.zipCodeExtension = item.Zip_Code_Extension__c;
            if (item.Zip_Code__c!=null){
                ZipObj.zipCode = item.Zip_Code__c.replaceAll(BuyflowConstant.R,SpecialcharacterConstant.CONCAT);
            }else{
                ZipObj.zipCode = item.Zip_Code__c;
            }
            ZipObj.zipCodeExtension = item.Zip_Code_Extension__c;
            
            // Populate AddressDetails class instance.
            AddressDetailsObj.Address = AddressObj;
            AddressDetailsObj.ServiceAvailability = ServiceAvailabilityObj;
            AddressDetailsObj.sfdcId = item.Site_Name__c;
            AddressDetailsList.add(AddressDetailsObj);
        }
        
        // Populate ValidateAddressServiceAvailabilityRequest class instance. 
        ValidateAddressServiceAvailabilityRequestObj.mode = BuyflowConstant.A;
        ValidateAddressServiceAvailabilityRequestObj.displayAllSpeeds = true;
        ValidateAddressServiceAvailabilityRequestObj.nearMatchIndicator = true;
        ValidateAddressServiceAvailabilityRequestObj.sfdcQuoteId = (quoteId!=null)?quoteId:SpecialcharacterConstant.CONCAT;
        
        ValidateAddressServiceAvailabilityRequestObj.AddressDetails = AddressDetailsList;
        
        // Populate AddrValidServAvailInformationBean (request bean) class instance
        bean.ValidateAddressServiceAvailabilityRequest = ValidateAddressServiceAvailabilityRequestObj;
        
        // Get VASA response from handleAddressValidationServiceAvailabilityRequest method by passing request bean and end customer Id.
        // VASA response is AddrValidServAvailResponseBean class instance (response bean)
        
        return serviceObj.handleAddressValidationServiceAvailabilityRequest(bean, null);                        
      } catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;    
            }
    }
    
/* 
 Name: doMultiSitesValidate
 Description: 
 */ 
    public static Map<Id,CustomerSite__c> doMultiSitesValidate (Id customerId,List<CustomerSite__c> uploadedSites,Map<String,CustomerSite__c> siteToRequestMap,AddrValidServAvailResponseBean VASAresponse){
      try{       
        if(uploadedSites!=NULL && uploadedSites.size()>0 && uploadedSites.size()<=2500){
                // Validate Sites 
                if(!Test.isRunningTest()) {
                    ATTServiceInfoBean response = ATTBulkValidateUtil.doBulkValidate (null,uploadedSites,siteToRequestMap);
                    VASAresponse = (AddrValidServAvailResponseBean) response;   
                }
                             
                Map<Id,CustomerSite__c> customerSiteMap = new Map<Id,CustomerSite__c>();
                
                // Create List of AddressServiceAvailability class (inner class of AddrValidServAvailResponseBean or response bean)
                List <AddrValidServAvailResponseBean.AddressServiceAvailability> respBeanAddressServiceAvailabilityList = new List <AddrValidServAvailResponseBean.AddressServiceAvailability> ();
                                
                if (VASAresponse !=NULL && VASAresponse.AddressServiceAvailability != NULL){
                    
                    respBeanAddressServiceAvailabilityList.addAll(VASAresponse.AddressServiceAvailability);
                    
                    
                    
                    // Iterate through AddressServiceAvailability list returned from response bean.                
                    for (AddrValidServAvailResponseBean.AddressServiceAvailability item: respBeanAddressServiceAvailabilityList) {
                        CustomerSite__c site = new CustomerSite__c();   
                        String temp = SpecialcharacterConstant.CONCAT;
                        if (item.requestedAddressDetails!=null && item.requestedAddressDetails.zip!=null){
                            temp =  item.requestedAddressDetails.street.toLowerCase() + item.requestedAddressDetails.city.toLowerCase() +item.requestedAddressDetails.state.toLowerCase() +item.requestedAddressDetails.zip.zipcode;
                            temp = temp.replaceAll(SpecialcharacterConstant.BLANK,SpecialcharacterConstant.CONCAT);
                        }else if (item.requestedAddressDetails!=null) {
                            temp = item.requestedAddressDetails.street.toLowerCase() + item.requestedAddressDetails.city.toLowerCase() +item.requestedAddressDetails.state.toLowerCase();
                            temp = temp.replaceAll(SpecialcharacterConstant.BLANK,SpecialcharacterConstant.CONCAT);
                        }
                        
                        if (siteToRequestMap.containsKey(temp)){
                        }
                        
                        if (String.isNotBlank(temp)){    
                            if (item.addressMatchCode == BuyflowConstant.SIVARConst_1){                      
                                if (item.addressMatchDetails!=NULL && item.addressMatchDetails.size()>0){                               
                                    if (siteToRequestMap!=NULL && siteToRequestMap.containsKey(temp)){                                        
                                        site.Site_Name__c = siteToRequestMap.get(temp).Site_Name__c ;
                                        site.id = siteToRequestMap.get(temp).Id;
                                        site.Site_Description__c =  siteToRequestMap.get(temp).Site_Description__c;
                                    }else{
                                        site.Site_Name__c  = BuyflowConstant.TESTSITE;
                                    }    
                                    site.Address_Line__c = item.addressMatchDetails[0].street;
                                    site.City__c = item.addressMatchDetails[0].city;
                                    site.State__c = item.addressMatchDetails[0].state;
                                    site.Urbanization__c = item.addressMatchDetails[0].urbanization;
                                    site.country__c = BuyflowConstant.US;
                                    site.VASA_Request_Time__c = system.now();
                                    if (item.addressMatchDetails[0].zip !=NULL){
                                        site.Zip_Code__c = item.addressMatchDetails[0].zip.zipcode;
                                        site.Zip_Code_Extension__c =  item.addressMatchDetails[0].zip.zipCodeExtension;
                                        site.Zip_Geo_Code__c = item.addressMatchDetails[0].zip.zipGeoCode;
                                    }                                
                                    site.End_Customer__c = customerId;                                
                                    site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                    site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                    List<AddrValidServAvailResponseBean> respBeanList = new List<AddrValidServAvailResponseBean>();
                                    AddrValidServAvailResponseBean respBean = new AddrValidServAvailResponseBean();
                                    respBean.AddressServiceAvailability = new List<AddrValidServAvailResponseBean.AddressServiceAvailability>();                            
                                    respBean.AddressServiceAvailability.add(item);                            
                                    respBean.Response = VASAresponse.Response;
                                    respBeanList.add(respBean);
                                    
                                    String vASAResponseSerialized = JSON.serialize(respBeanList);                              
                                    site.VASAResponse__c = VASAResponseSerialized;
                                    if (site!=NULL && site.id!=NULL){
                                        customerSiteMap.put(site.id,site);
                                    }
                                  } 
                                }else if (item.addressMatchCode == BuyflowConstant.SIVARConst_2 || item.addressMatchCode == BuyflowConstant.SIVARConst_3){
                                    if (item.requestedAddressDetails!=NULL){
                                        if (siteToRequestMap!=NULL && siteToRequestMap.containsKey(temp)){
                                            site.Site_Name__c = siteToRequestMap.get(temp).Site_Name__c ;
                                            site.id = siteToRequestMap.get(temp).id;
                                            site.Site_Description__c =  siteToRequestMap.get(temp).Site_Description__c;
                                        }else{
                                            site.Site_Name__c  = BuyflowConstant.TESTSITE;
                                        }    
                                        site.Address_Line__c = item.requestedAddressDetails.street;
                                        site.City__c = item.requestedAddressDetails.city;
                                        site.State__c = item.requestedAddressDetails.state;
                                        site.Urbanization__c = item.requestedAddressDetails.urbanization;
                                        site.country__c = BuyflowConstant.US;
                                        site.VASA_Request_Time__c = system.now();
                                        if (item.addressMatchDetails!=NULL && item.addressMatchDetails.size()>0 && item.addressMatchDetails[0].zip !=NULL){
                                            site.Zip_Code__c = item.requestedAddressDetails.zip.zipcode;
                                            site.Zip_Code_Extension__c =  item.requestedAddressDetails.zip.zipCodeExtension;
                                            site.Zip_Geo_Code__c = item.requestedAddressDetails.zip.zipGeoCode;
                                        }    
                                        site.End_Customer__c = customerId;
                                        if (item.addressMatchCode == BuyflowConstant.SIVARConst_2){
                                            site.VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                            site.Raw_VASA_Response_Status__c = BuyflowConstant.POSSIBLEMATCHES;
                                            
                                        }else if (item.addressMatchCode == BuyflowConstant.SIVARConst_3){
                                            site.VASA_Response_Status__c = BuyflowConstant.ADDRESSEXACT_MATCH;
                                            site.Raw_VASA_Response_Status__c = BuyflowConstant.ADDRESSNO_MATCH;
                                        }                                        
                                        List<AddrValidServAvailResponseBean> respBeanList = new List<AddrValidServAvailResponseBean>();
                                        AddrValidServAvailResponseBean respBean = new AddrValidServAvailResponseBean();
                                        respBean.AddressServiceAvailability = new List<AddrValidServAvailResponseBean.AddressServiceAvailability>();                            
                                         respBean.AddressServiceAvailability.add(item);                            
                                        respBean.Response = VASAresponse.Response;
                                        respBeanList.add(respBean);
                                        
                                        String vASAResponseSerialized = JSON.serialize(respBeanList);                             
                                        site.VASAResponse__c = VASAResponseSerialized;
                                    }     
                                     if (site!=NULL && site.id!=NULL){
                                         customerSiteMap.put(site.id,site);
                                     }                        
                                } 
                         }       
                    }
                     if (customerSiteMap!=NULL && customerSiteMap.size()>0){
                            update customerSiteMap.values();
                        }
                                 
                }
                return customerSiteMap;
            }
            return null;
     }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
            }
    } 
 }