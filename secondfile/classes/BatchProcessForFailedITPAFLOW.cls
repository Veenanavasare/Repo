/*************************************************************************************************** 
 Apex Class Name     : BatchProcessForFailedITPAFLOW
 Version             : 1.0
 Created Date        : 2 Feb 2017
 Description         : Offline ITPA Processing Batch
 Modified By         : Bhupesh Kumar
 Modified Date       : 27.9.2017
***************************************************************************************************/
global class BatchProcessForFailedITPAFLOW implements Database.Batchable<sObject>,Database.AllowsCallouts {
    
    Set<Id> setfailedCustomerSiteIds;
    String quoteId;
    /* 
    *Name: FLOWITPABatchProcess
    *Description: This is the constructor of the class.
    */
    global BatchProcessForFailedITPAFLOW(Set<Id> failedCustomerSiteIds, String quoteIdAsParam){  
        
        system.debug('====failedCustomerSiteIds===='+failedCustomerSiteIds);
        system.debug('====quoteIdAsParam===='+quoteIdAsParam);
        
        setfailedCustomerSiteIds = new Set<Id>();
        quoteId = '';
        
        if(!failedCustomerSiteIds.isEmpty()){
            //setfailedCustomerSiteIds = failedCustomerSiteIds;
            setfailedCustomerSiteIds.addAll(failedCustomerSiteIds);
        }
        if(string.isNotBlank(quoteIdAsParam)){
            quoteId = quoteIdAsParam;
        }
        
        system.debug('====setfailedCustomerSiteIds===='+setfailedCustomerSiteIds);
        system.debug('====quoteId===='+quoteId);
        
    }
   
    /* 
    *Name: start
    *Description: This is the start method of the Batch Class, which is used to retrieve the records based on the query.
                  The list of retrieved records will be passed to the execute method for the further processing.
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
    
        system.debug('===inside start method of first retrigger batch===');
        system.debug('===inside start method of first retrigger batch==='+setfailedCustomerSiteIds);
        
        return Database.getQueryLocator([SELECT Id,Site_Failed_Counter__c,Has_Failed_Request__c,Alternate_Access_ITPA_Request_Time__c,Name, End_Customer__c, Speed_Unit__c,
                                                VASAResponse__c,Service_Availability_Response__c, VASA_Response_Status__c,Country__c,
                                                Display_All_Speeds__c,Transport_Type__c,Phone__c,Zip_Code_Extension__c,Zip_Geo_Code__c,
                                                Site_Description__c, Site_Name__c,City__c,Address_Line__c, State__c, Zip_Code__c,  
                                                Location__c,Alternate_Access_ITPA_Response_Status__c,Structure__c, Level__c, Unit__c,
                                                Alternate_Access_latitude__c,Alternate_Access_level__c,Alternate_Access_locator__c,
                                                Alternate_Access_longitude__c,Alternate_Access_ITPA_Process_Completed__c,
                                                Alternate_Access_meetPointHCoordinate__c,Alternate_Access_meetPointVCoordinate__c,
                                                Alternate_Access_npaNxx__c,Alternate_Access_score__c,Alternate_Access_servingWireCenter__c,
                                                Alternate_Access_status__c,Alternate_Access_territoryIndicator__c,Alternate_Access_vendorName__c,
                                                Alternate_Access_code__c,Speeds_Not_Available_ITPA__c,Raw_VASA_Response_Status__c 
                                         From CustomerSite__c 
                                         where Id IN: setfailedCustomerSiteIds]);
                                         
    }
    
    /* 
    *Name: execute
    *Description: This is the execute method of the Batch Class, which is used to process the records passed from the Start method.
    */  
    global void execute(Database.BatchableContext BC, List<CustomerSite__c> custSiteList){
        
        system.debug('====inside execte method of first retrigger batch to process failed sites==='+custSiteList);
        
        try{
            String regExp = '&quot;';
            List<CustomerSite__c> customerSiteList = new List<CustomerSite__c>();  
               
            if(!custSiteList.isEmpty()){
                customerSiteList = custSiteList;
            }
            
            system.debug('====execute method list customerSiteList 2====='+customerSiteList);
            system.debug('====execute method list quote ====='+quoteID);
            
            FlowITPAIntegrationHandler handler = new FlowITPAIntegrationHandler();
            List<FlowITPARequestBean> requestList = handler.parseRequestBulk(customerSiteList,quoteID);            
            FlowITPAContinuationController controller = new FlowITPAContinuationController();
            
            system.debug('====Number of requests are===='+requestList.size());
            
            integer i=1;
            List<HttpResponse> responseList = new List<HttpResponse>();
            for(FlowITPARequestBean requestBean : requestList){    
                system.debug('====calling request no===='+i);    
                i++;
                HttpResponse response = new HttpResponse();
                response = controller.InitiateCallBulk(requestBean,customerSiteList);
                responseList.add(response);
            }
            
            system.debug('====responseList===='+responseList);
            system.debug('====Number of customerSiteList are===='+customerSiteList);
            
            controller.processFLOWITPAResponseBulk(responseList,customerSiteList);
        }
        catch(Exception e){
            system.debug('Exception '+e.getMessage()+' at line no '+e.getLineNumber());        
        }
    }
  
    /* 
    *Name: finish
    *Description: This is the finish method of the Batch Class, which will be called once execute method is completed.
    */ 
    global void finish(Database.BatchableContext BC){
        system.debug('===inside finish of BatchProcessForFailed 1 ======');
        try{
            //normal flow 
            
            Set<Id> failedCustomerSiteIds = new Set<Id>();
            Set<Id> passedCustomerSiteIds = new Set<Id>();
            
            map<Id, AT_T_Customer_Site_Quote__c> jnSiteQuoteMap = 
            new map<Id, AT_T_Customer_Site_Quote__c>([SELECT Id, AT_T_Customer_Site__c, AT_T_Customer_Site__r.Has_Failed_Request__c, AT_T_Quote__c 
                                                      FROM AT_T_Customer_Site_Quote__c 
                                                      WHERE AT_T_Quote__c  =: quoteId]);
                                                      
            if(!jnSiteQuoteMap.isEmpty()) {
                for(AT_T_Customer_Site_Quote__c jnSiteQuote : jnSiteQuoteMap.values()){
                    if(jnSiteQuote.AT_T_Customer_Site__r.Has_Failed_Request__c == true){
                        failedCustomerSiteIds.add(jnSiteQuote.AT_T_Customer_Site__c);
                    }
                    if(jnSiteQuote.AT_T_Customer_Site__r.Has_Failed_Request__c == false){
                        passedCustomerSiteIds.add(jnSiteQuote.AT_T_Customer_Site__c);
                    }
                }
            }
            if(!passedCustomerSiteIds.isEmpty() && failedCustomerSiteIds.isEmpty()){
                //normal flow     
                Apttus_Proposal__Proposal__c  quoteObj = [select id,RetrialFailure__c,Apttus_Proposal__Approval_Stage__c ,
                                                                 vasa_modeA_request__c,Buyflow_Step__c ,End_Customer__c,Product_New_Name__c,
                                                                 End_Customer__r.Name,Ethernet_Configuration__c,Name,Review_Address_Check__c,
                                                                 Bulk_Sevice_Availability_Indicator__c,Product__c,Product__r.ProductCode,Product__r.Name,
                                                                 Apttus_Proposal__Payment_Term__c,Apttus_Proposal__Proposal_Name__c 
                                                          From Apttus_Proposal__Proposal__c 
                                                          where id =: quoteID 
                                                          AND (RetrialFailure__c = 0  OR RetrialFailure__c = Null)];
                                                      
                system.debug('Inside Finish method of BatchProcessForFailedITPAFLOW: '+quoteID);          
                if(quoteObj.Apttus_Proposal__Approval_Stage__c != Null 
                    && (quoteObj.Apttus_Proposal__Approval_Stage__c.equals(BuyflowConstant.BULKSERVICE_AVAILABILITY_REQUESTED) 
                    || quoteObj.Apttus_Proposal__Approval_Stage__c.equals('Bulk  Service Availability Requested'))) {
                        
                        quoteObj.Bulk_Sevice_Availability_Indicator__c = true;
                        quoteObj.Buyflow_Step__c = BuyflowConstant.ADDSITES;
                        quoteObj.Review_Address_Check__c = true;
                        quoteObj.Apttus_Proposal__Approval_Stage__c = BuyflowConstant.BULKSERVICE_AVAILABILITY_COMPLETED;
                        update quoteObj;
                        
                        quoteObj.Bulk_Sevice_Availability_Indicator__c = false; 
                        update quoteObj;
                }
            }
            
            
            list<CustomerSite__c> customerSiteList;
            
            if(!setfailedCustomerSiteIds.isEmpty()) {
                customerSiteList = [SELECT Id,Has_Failed_Request__c,Site_Failed_Counter__c 
                                    From CustomerSite__c 
                                    where Id IN: setfailedCustomerSiteIds];
            }
            if(!customerSiteList.isEmpty()){
                for(CustomerSite__c customerSitesObj : customerSiteList) {
                    if(customerSitesObj.Has_Failed_Request__c == true) { //&& customerSitesObj.Site_Failed_Counter__c <= 3 
                        failedCustomerSiteIds.add(customerSitesObj.Id);
                        
                        system.debug('====offline batch inside 1st retrigger===='+failedCustomerSiteIds);
                    }
                }
            }
            if(!failedCustomerSiteIds.isEmpty()) { 
                
                system.debug('====inside finish method failed sites===='+failedCustomerSiteIds);
                system.debug('====inside finish method quote id===='+quoteId);
                 
                BatchProcessForFailedITPAFLOW2 batchObj = new BatchProcessForFailedITPAFLOW2(failedCustomerSiteIds,quoteId);
                Database.executeBatch(batchObj, 1);
                
            } 
        }
        catch(Exception e){    
            system.debug('Exception '+e.getMessage()+' at line no '+e.getLineNumber());    
        }
    }
}