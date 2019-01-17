/************************************************************************************** 
 Apex Class Name     : ATTBulkValidateUtilAIA
 Version             : 1.0 
 Created Date        : 28 Nov 2014
 Function            : Util class on Bulk Validate (real time and asynchronous) used in SiteAddressInformationController.
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Arpan Kumar Patra         11/28/2014              Original Version
*Dasetti Venkata Ramiah     08/18/2015              Updated code bulk file to Read from Excel
*************************************************************************************/

/* 
 Name: ATTBulkValidateUtilAIA
 Type: Class 
 
 Description: 
 */ 
public with sharing class ATTBulkValidateUtilAIA {
    
    // BULK FILE UPLOAD
    /*******************************************************************
    * Method name : ReadFile
    * Description : Method to insert customer site based on user selection of close match sites from closeMatchAddrWrapper wrapper list. 
    * Return Type : PageReference.
    * Parameters  : Id,Id,Map<String,CustomerSite__c>,String[],Blob,String,List<CustomerSite__c>,
    *               AddrValidServAvailResponseBean,Map<Id,CustomerSite__c>,List<SiteAddressInformationController.selectedSitesWrapper>.
    *******************************************************************/  
    public static PageReference ReadFile(Id quoteId, 
                                            Id customerId,
                                            Map<String,CustomerSite__c> siteToRequestMap,
                                            String[] filelines,
                                            string contentFile, 
                                            String nameFile, 
                                            List<CustomerSite__c> SitesToValidateList, 
                                            BRASS_Acknowledgement_Response BRASSresponse,
                                            Map<Id,CustomerSite__c> pageInsertedSitesMap,
                                            List<SiteAddressInformationController.selectedSitesWrapper> selectedSitesWrapperList, 
                                            String conversationID) {
                                                try{
        // Create Page Message instance. 
        ApexPages.Message myMsg;
        PageReference pageRef = System.Page.buyflow;
         
        nameFile=string.valueOf(contentFile);                                        
       // nameFile=contentFile.toString();
        contentFile = null;
                                                
        List<String> allRows = nameFile.split(SpecialCharacterConstant.DOUBLE_TILDE);  
        // for loop to filter out the null values
         for(integer i=0;i<allrows.size(); i++){
                   list<string> st = allrows[i].split(SpecialCharacterConstant.COMMA);
                    boolean nullRowFound = false;
                    Integer noOfCols = 0;
                       for(integer j =0 ; j<st.size(); j++){
                                 if( st[j]== null || st[j]== SpecialCharacterConstant.CONCAT || st[j]==SpecialCharacterConstant.TABSPACE || st[j]==SpecialCharacterConstant.DOUBLETABSPACE || st[j] == MiscConstant.NAN || st[j] ==SpecialCharacterConstant.TABSPACE ){ //st[j]== SpecialCharacterConstant.BLANK || st[j]==SpecialCharacterConstant.DOUBLETABSPACE ||st[j]== null || st[j]== SpecialCharacterConstant.CONCAT ||  || 
                                noOfCols+=1;
                                
                            }
                               
                    }
                    if(!(st.size()==noOfCols))
                    {
                               filelines.add(allrows[i]);
                    }
                  
             }
           
                                                
        try{
            for (Integer i=3;i<filelines.size();i++){
                String[] inputvalues = new String[]{};           
                inputvalues = filelines[i].split(SpecialCharacterConstant.COMMA);
                
                 if (inputvalues.size()!=6 || String.isBlank(inputvalues[1]) || String.isBlank(inputvalues[2]) || String.isBlank(inputvalues[3]) || String.isBlank(inputvalues[4])|| String.isBlank(inputvalues[5])){
                    pageRef.getParameters().put('display','fileErr');
                    pageRef.getParameters().put('mode', ATTConstants.SITE_INFO);
                    return pageRef;
               }
                CustomerSite__c custSite = new CustomerSite__c();
                custSite.Site_Name__c = inputvalues[0];      
                custSite.Address_Line__c = inputvalues[1]; 
                /* custSite.Location__c = inputvalues[2];
                if (String.isNotBlank(inputvalues[3])){
                    try{
                        custSite.Location_Number__c = Decimal.valueOf(inputvalues[3]);
                    }catch(Exception ex){
                    }   
                }*/
                custSite.End_Customer__c = customerId;
                custSite.City__c = inputvalues[2];
                custSite.State__c =  inputvalues[3];
                //----Changes by khalid on date 11/6/2014 to solve defect :bulk upload
                String zipCode = inputvalues[4];
                if(!string.isBlank(zipCode) && zipCode.trim().length()<5) {
                    for(integer k=0;k<5-zipCode.trim().length();k++) {
                       zipCode = '0'+zipCode;
                    }
                }
                custSite.Zip_Code__c = zipCode;
                custSite.Phone__c = inputvalues[5];
                SitesToValidateList.add(custSite);
            }
        
            if(SitesToValidateList!=NULL && SitesToValidateList.size()>0 && SitesToValidateList.size()<=2500){
                // Validate Sites  
                ATTServiceInfoBean response = ATTBulkValidateUtilAIA.doBulkValidate (SitesToValidateList,siteToRequestMap,conversationID);
             
                BRASSresponse = (BRASS_Acknowledgement_Response) response;
                          
                if (BRASSresponse !=NULL && BRASSresponse.Acknowledgement.equals('Acknowledged! Request is being processed.')){
                    pageRef.getParameters().put('display','syncAIA');
                }else{
                    pageRef.getParameters().put('display','err');
                }    
            }else if (SitesToValidateList.size() <= 0){
                    pageRef.getParameters().put('display','blank');
            }
        
            pageRef.getParameters().put('mode', ATTConstants.SITE_INFO);    // Redirecting to the Enter Address page in the Buyflow.  
            return pageRef;
                
        }catch(Exception e) {
            pageRef.getParameters().put('display','err');
            pageRef.getParameters().put('mode', ATTConstants.SITE_INFO); 
            //pageRef.setRedirect(true);    
            return pageRef;
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            // ATTException.createException(MiscConstant.ERRORIN_SITEADDRESSINFOCONTROLLER_CLONE_AIA_READFILE, e.getTypeName(), ATTException.constructExceptionMessageString(e));
        } 
    }    
catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
    }
                                            }   
    
    /*******************************************************************
    * Method name : doBulkValidate
    * Description : Common method to do validateAddress as well Service availability callouts
    * Return Type : ATTServiceInfoBean.
    * Parameters  : List<CustomerSite__c> ,Map<String,CustomerSite__c> , String
    *******************************************************************/  
    public static ATTServiceInfoBean doBulkValidate(List<CustomerSite__c> SitesToValidateListList,
                                                        Map<String,CustomerSite__c> siteToRequestMap, 
                                                        String conversationID) {
                                                            try{
         
        // Create AddrValidServAvailService class instance (service class)
        BrassService serviceObj = new BrassService();
        
        // Create List of BRASS_Apex2JSON_Request class instance (request bean)  
        List<BRASS_Apex2JSON_Request> beanList = new List<BRASS_Apex2JSON_Request>();            
        
        // Create handler class instance. 
        BrassIntegrationHandler handler = new BrassIntegrationHandler();
        
        // Create AddrValidServAvailInformationBean class instance (request bean)  
        BRASS_Apex2JSON_Request bean = new BRASS_Apex2JSON_Request();
               
        // Create List of Pre-Qualify class (List of inner class of request bean)
        List <BRASS_Apex2JSON_Request.PreQualifyRequest> prequalifyResultList = new List <BRASS_Apex2JSON_Request.PreQualifyRequest>();
        
        siteToRequestMap = new Map<String,CustomerSite__c>();
        
        
        // Populate bean classes variable and inner class variable with page data.              
        // Populate Address class instance
        String temp = SpecialCharacterConstant.CONCAT;
        List<CustomerSite__c> insertList = new List<CustomerSite__c>();
        String conversationIdLocal = SpecialCharacterConstant.CONCAT;
        for (CustomerSite__c item : SitesToValidateListList) {
            temp = SpecialCharacterConstant.CONCAT;
            if(item.Service_Avail_Key__c!=NULL){
                temp = item.Service_Avail_Key__c.replaceAll(' ', '').toLowerCase().trim();
            } else {
                if(item.Zip_Code__c != NULL) {
                    temp = item.Address_Line__c.toLowerCase().trim() 
                            + item.City__c.toLowerCase().trim() 
                            + item.State__c.toLowerCase().trim() 
                            + item.Zip_Code__c;
                    temp = temp.replaceAll(' ', '');        
                }
                
            }
            
            if (String.isNotBlank(temp.trim()) && !siteToRequestMap.containsKey(temp.trim())) {   
                siteToRequestMap.put(temp.trim(),item);
            }    
            
            conversationIdLocal = conversationID + '-' + temp.trim();
            //conversationID = conversationID + '-' + temp.trim();
            // Create Pre-Qualify class instance (inner class of request bean)
           
            BRASS_Apex2JSON_Request.PreQualifyRequest prequalifyResult = new BRASS_Apex2JSON_Request.PreQualifyRequest();         
            
            BRASS_Apex2JSON_Request.OfferType offerType = new BRASS_Apex2JSON_Request.OfferType();
        
            BRASS_Apex2JSON_Request.Address AddressObj = new BRASS_Apex2JSON_Request.Address(); 
            
            AddressObj.street1 = item.Address_Line__c.toUpperCase();
            AddressObj.city = item.City__c.toUpperCase();
            AddressObj.state = item.State__c.toUpperCase();
            AddressObj.country = item.country__c; 
            if (item.Zip_Code__c!=null){
                AddressObj.Zip = item.Zip_Code__c.replaceAll('\r','');   
            }else{
                AddressObj.Zip = item.Zip_Code__c;  
            }
            AddressObj.Region = item.Urbanization__c;  
            AddressObj.Street2 = SpecialCharacterConstant.CONCAT;
            AddressObj.Facsimile = SpecialCharacterConstant.CONCAT; 
            AddressObj.Email = SpecialCharacterConstant.CONCAT;
            AddressObj.Url = SpecialCharacterConstant.CONCAT;
            AddressObj.Internet=SpecialCharacterConstant.CONCAT;
            AddressObj.Telephone = MiscConstant.SIVARConst_9085551234;
            
            offerType.UserType = MiscConstant.ALL; 
            
            prequalifyResult.Address = AddressObj;
            prequalifyResult.Type = MiscConstant.PREQUALWITH_GEOCODE;
            prequalifyResult.CustomerType = SpecialCharacterConstant.CONCAT;
            prequalifyResult.AddrMatchCode = SpecialCharacterConstant.CONCAT;
            prequalifyResult.OnlineOrderingInd = MiscConstant.N;
            prequalifyResult.AddressParse = MiscConstant.Y;
            prequalifyResult.ServiceRetainedInd = MiscConstant.Y;
            prequalifyResult.PromoCode = SpecialCharacterConstant.CONCAT;
            prequalifyResult.offerType = offerType;
            prequalifyResult.ConversationID = conversationIdLocal;
            prequalifyResultList.add(prequalifyResult);
        }
        
        bean.Synchronous = MiscConstant.N;
        bean.PreQualifyRequest = prequalifyResultList;
       
        // Get VASA response from handleAddressValidationServiceAvailabilityRequest method by passing request bean and end customer Id.
        // VASA response is AddrValidServAvailResponseBean class instance (response bean)
        
        
        if (bean!=null && SitesToValidateListList.size()<=2500){
            ATTServiceInfoBean returnBean = serviceObj.BrassServiceRequest(bean);
            if (siteToRequestMap!=NULL && siteToRequestMap.size()>0){    
                upsert siteToRequestMap.values();
            }
            return returnBean;
        }       
        
        else if (beanList!=null && beanList.size()>0 && SitesToValidateListList.size()>2500){
            // return serviceObj.handleAddressValidationServiceAvailabilityRequest(beanList, null,true);
            return null;
        }         
        
        return null;
    }
    catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
    }
                                                        
    }
    
    public static Boolean doMultiSitesValidate(Id customerId, 
                                                List<CustomerSite__c> SitesToValidateList , 
                                                Map<String,CustomerSite__c> siteToRequestMap,
                                                BRASS_Acknowledgement_Response BRASSresponse, 
                                                String conversationID, Boolean AddEditSiteFlag) {
        try{
                                                        
        if(SitesToValidateList!=NULL && SitesToValidateList.size()>0 && SitesToValidateList.size()<=2500){
        
            if (SitesToValidateList.size()==1 && AddEditSiteFlag){
                String siteKey = SitesToValidateList[0].Address_Line__c.trim() + SitesToValidateList[0].City__c.trim() + SitesToValidateList[0].State__c.trim() + SitesToValidateList[0].Zip_Code__c.trim();
                siteKey = siteKey.replaceAll(' ','');
                List<CustomerSite__c> duplicateCheckSiteList = new List<customerSite__c>();
                if (String.isNotBlank(siteKey) && customerId!=NULL){
                    duplicateCheckSiteList = [SELECT id,Name,BRASSResponse__c from CustomerSite__c where Service_Avail_Key__c = :siteKey and End_Customer__c = :customerId LIMIT 1];
                }
                if (duplicateCheckSiteList!=NULL && duplicateCheckSiteList.size()>0){
                        return false;
                    }
                }
           
            
           BRASS_Acknowledgement_Response response = (BRASS_Acknowledgement_Response) ATTBulkValidateUtilAIA.doBulkValidate (
                                                                            SitesToValidateList,siteToRequestMap,conversationID);
            
              if (response!=NULL && response.Acknowledgement!=NULL && response.Acknowledgement.equals('Acknowledged! Request is being processed.')) {
                return true;
            } else {
                return false;
            }
        }
        return null;
    }
    catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    return null;    
    }
     
     
}