Public Class DiscardFunctionalityHandler{

    /*******************************************************************
    * Method name : discardNewChangesOnQuote
    * Description : Discard the latest user changes on Quote
    * Return Type : None
    * Parameters  : Quote Id
    *******************************************************************/     
    
    public void discardNewChangesOnQuote(String quoteIdp){
        List<Apttus_Config2__ProductConfiguration__c> prodConfigList = new List<Apttus_Config2__ProductConfiguration__c>();
        List<Apttus_Config2__ProductConfiguration__c> finalizedProdConfigList = new List<Apttus_Config2__ProductConfiguration__c>();
        List<AT_T_Customer_Site_Quote__c> allJunctionObjofQuoteList = new List<AT_T_Customer_Site_Quote__c>();
        List<AT_T_Customer_Site_Quote__c> junctionObjTobeDeletedList = new List<AT_T_Customer_Site_Quote__c>();
        Set<String> finalizedcustomerSiteIdSet = new Set<String>();
        Set<String> customerSiteIdSetTobeDeleted = new Set<String>();
        List<Apttus_Proposal__Proposal__c> qutoeObjList = new List<Apttus_Proposal__Proposal__c>();
        List<AT_T_Customer_Site_Quote__c> junctionObjTobeUpdatedList = new List<AT_T_Customer_Site_Quote__c>();
        List<Opportunity> opptyList = new List<Opportunity>();
        String opptyId = '';
        system.debug('---in wpcontroller---');
        if(quoteIdp != Null){
            allJunctionObjofQuoteList = [SELECT id,AT_T_Customer_Site__c,Wireline_Promotion_Id_Sorted__c,Wireline_Promotion_Id_Sorted_Old__c,Wireline_Promotion_Id_Before__c,Wireline_Promotion_Id_Before_Old__c,
                                            Wireline_Promotion_Id_After__c,Wireline_Promotion_Id_After_Old__c,Wireline_Promotion_Applied_Old__c,Wireline_Promotion_Applied__c,Wireline_Promotion_Id_Applied__c,
                                            Wireline_Promotion_Id_Applied_Old__c,Alternate_Access_IGLOO_Response__c,Alternate_Access_IGLOO_Response_Old__c,Alternate_Access_IGLOO_Request_Time__c,
                                            Alternate_Access_IGLOO_Request_Time_Old__c,Iglow_Response_Received_Date__c,Igloo_Response_Received_Date_Old__c,Alternate_Access_IGLOO_Response_Status__c,
                                            Alternate_Access_IGLOO_ResponseStatusOld__c,Alternate_Access_IGLOO_Failure_Code__c,Alternate_Access_IGLOO_Failure_Code_Old__c,Alternate_Access_IGLOO_Access_Speed__c,
                                            Alternate_Access_IGLOO_Access_Speed_Old__c,Alternate_Access_IGLOO_Access_Price__c,Alternate_Access_IGLOO_Access_Price_Old__c,Alternate_Access_IGLOO_Interface_Code__c,
                                            Alternate_Access_IGLOO_Interface_CodeOld__c,Alternate_Access_IGLOO_Process_Completed__c,Alternate_Access_IGLOO_ProcessCmpltd_Old__c,CSI_Conversation_Id__c,
                                            CSI_Conversation_Id_Old__c,Wireline_Promotion_Name_Applied__c,Wireline_Promotion_Name_Applied_Old__c,Wireline_Promotion_Number_Applied__c,Wireline_Promotion_Number_Applied_Old__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c =: quoteIdp];
                                            
            prodConfigList = [SELECT id, Apttus_QPConfig__Proposald__c, Apttus_Config2__Status__c,(SELECT Id, AT_T_Customer_Site__c
                                FROM Apttus_Config2__LineItems__r) FROM Apttus_Config2__ProductConfiguration__c 
                                WHERE Apttus_QPConfig__Proposald__c =: quoteIdp AND Apttus_Config2__Status__c != 'Finalized' ORDER BY CreatedDate DESC Limit 1];
            finalizedProdConfigList = [SELECT id, Apttus_QPConfig__Proposald__c, Apttus_Config2__Status__c,(SELECT Id, AT_T_Customer_Site__c
                                FROM Apttus_Config2__LineItems__r) FROM Apttus_Config2__ProductConfiguration__c 
                                WHERE Apttus_QPConfig__Proposald__c =: quoteIdp AND Apttus_Config2__Status__c = 'Finalized' ORDER BY CreatedDate DESC Limit 1];  
            qutoeObjList = [SELECT id,Wireline_Promotions_at_SP_Order_Level__c,Wireline_Promotions_at_Deal_Reg_Level__c,Wireline_Promotions_at_SP_Order_LevelOld__c,Wireline_Promotions_at_Deal_Reg_LevelOld__c,Apttus_Proposal__Opportunity__c,SP_Status_Backend__c FROM Apttus_Proposal__Proposal__c WHERE id =: quoteIdp];
            if(!qutoeObjList.isEmpty()){
                if(qutoeObjList[0].Apttus_Proposal__Opportunity__c != Null){
                    opptyId = qutoeObjList[0].Apttus_Proposal__Opportunity__c;
                }
            }
            if(opptyId != '')
                opptyList = [SELECT id,StageName,name,IsReconfigureDeal__c,IsCancelled__c FROM Opportunity WHERE id =:opptyId ];
        }
        if(!finalizedProdConfigList.isEmpty()){
            For(Apttus_Config2__ProductConfiguration__c prodConfigObj : finalizedProdConfigList){
                if(!prodConfigObj.Apttus_Config2__LineItems__r.isEmpty()){
                    For(Apttus_Config2__LineItem__c lineItemObj : prodConfigObj.Apttus_Config2__LineItems__r){
                        finalizedcustomerSiteIdSet.add(lineItemObj.AT_T_Customer_Site__c);
                    }
                }
            }
        }
        if(!allJunctionObjofQuoteList.isEmpty()){
            For(AT_T_Customer_Site_Quote__c junctionObj : allJunctionObjofQuoteList){
                if(!finalizedcustomerSiteIdSet.contains(junctionObj.AT_T_Customer_Site__c)){
                    customerSiteIdSetTobeDeleted.add(junctionObj.AT_T_Customer_Site__c);
                    junctionObjTobeDeletedList.add(junctionObj);
                }
                else{
                    junctionObjTobeUpdatedList.add(junctionObj);
                }
            }
        }
        if(!junctionObjTobeUpdatedList.isEmpty()){
            updateJunctionwithOldValues(junctionObjTobeUpdatedList);
        }
        if(!junctionObjTobeDeletedList.isEmpty()){
            
            /*****Untagging End Customer for IPQ Site*****/ 
                List<CustomerSite__c> custObj = new List<CustomerSite__c>();
                List<id> custIdList = new List<Id>();
                Map<id,Integer> siteMap = new Map<id,Integer>();
                List<Id> untagSIteIdList = new List<Id>();
                List<End_Customer__c> endObj = new List<End_Customer__c>();
                endObj = [Select id from End_Customer__c where Name = 'Rest_End_Customer'];
                custObj=[select id,End_Customer__c,Site_Name__c,API_IPQ_Site__c from CustomerSite__c where API_IPQ_Site__c = true AND id in (select AT_T_Customer_Site__c from AT_T_Customer_Site_Quote__c where Id =: junctionObjTobeDeletedList)];
                if(!custObj.isEmpty()){
                    for(CustomerSite__c cust :custObj){
                        custIdList.add(cust.id);
                    }
                    for(AT_T_Customer_Site_Quote__c junObj : [select AT_T_Customer_Site__c from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c =: custIdList]){
                        if(siteMap.containsKey(junObj.AT_T_Customer_Site__c)){
                            siteMap.put(junObj.AT_T_Customer_Site__c,siteMap.get(junObj.AT_T_Customer_Site__c) + 1);
                        }else{
                            siteMap.put(junObj.AT_T_Customer_Site__c,1);
                        }
                    }
                    for(id siteId : siteMap.keySet()){
                        if(siteMap.get(siteId) <= 2){
                            untagSIteIdList.add(siteId);
                            System.debug('@@@untagSIteIdList---->'+untagSIteIdList);
                        }
                    }

                        for(CustomerSite__c cust1 :custObj){
                            if(untagSIteIdList.contains(cust1.id)){
                                cust1.Site_Name__c = '';
                                cust1.End_Customer__c = endObj[0].id;
                                System.debug('SUCCESSS');
                                update cust1;   
                            }
                        }
                }
                /*******************/
            
            Delete junctionObjTobeDeletedList;
        }
        if(!prodConfigList.isEmpty()){
            Delete prodConfigList;
        }
        if(!qutoeObjList.isEmpty()){
            qutoeObjList[0].SP_Status_Backend__c = 'Accepted';
            qutoeObjList[0].Buyflow_Step__c = 'Review Request';
            qutoeObjList[0].Apttus_Proposal__Approval_Stage__c = ATTConstants.QUOTE_DEAL_REG_APPROVED;
            
            qutoeObjList[0].Review_Address_Check__c = false ;
            qutoeObjList[0].StopApprovalEmailOnDiscard__c = true;
            //if(qutoeObjList[0].Wireline_Promotions_at_SP_Order_LevelOld__c != Null && qutoeObjList[0].Wireline_Promotions_at_SP_Order_LevelOld__c != '')
                qutoeObjList[0].Wireline_Promotions_at_SP_Order_Level__c = qutoeObjList[0].Wireline_Promotions_at_SP_Order_LevelOld__c;
            
            update qutoeObjList;
        }
        if(!opptyList.isEmpty()){
            List<id> quoteIdList = new List<Id>();
            quoteIdList.add(quoteIdp);
            
            opptyList[0].IsReconfigureDeal__c = true;
            opptyList[0].Deal_Reg_Approved__c = false; 
            opptyList[0].stagename =  ATTConstants.OPPTY_DEAL_REG_AUTO_APPROVED;
            update opptyList;
            
            List <SPProduct__c> delSPprod = new List <SPProduct__c>();
            delSPprod= [Select id from SPProduct__c where Deal__c =: opptyList[0].id ];
            if (delSPprod.size() != 0){
                delete delSPprod;
            }
            if(!Test.isrunningTest()){
                 ID batchProcessId = database.executeBatch(new DealRegistrationBatchProcessUpgrade(quoteIdList,opptyList[0].Id),1);
            }
            
        }
        
    }
    
    public void updateJunctionwithOldValues(List<AT_T_Customer_Site_Quote__c> junctionObjTobeUpdatedListp){
        List<AT_T_Customer_Site_Quote__c> updatedJunctionList = new List<AT_T_Customer_Site_Quote__c>();
        for(AT_T_Customer_Site_Quote__c siteQuote : junctionObjTobeUpdatedListp){
            
            //if(siteQuote.Wireline_Promotion_Id_Sorted_Old__c != Null && siteQuote.Wireline_Promotion_Id_Sorted_Old__c != '')
                siteQuote.Wireline_Promotion_Id_Sorted__c = siteQuote.Wireline_Promotion_Id_Sorted_Old__c;
            
            //if(siteQuote.Wireline_Promotion_Id_Before_Old__c != Null && siteQuote.Wireline_Promotion_Id_Before_Old__c != '')
                siteQuote.Wireline_Promotion_Id_Before__c = siteQuote.Wireline_Promotion_Id_Before_Old__c;
            
            //if(siteQuote.Wireline_Promotion_Id_After_Old__c != Null && siteQuote.Wireline_Promotion_Id_After_Old__c != '')
                siteQuote.Wireline_Promotion_Id_After__c = siteQuote.Wireline_Promotion_Id_After_Old__c;
            
            //if(siteQuote.Wireline_Promotion_Id_Applied_Old__c != Null)
                siteQuote.Wireline_Promotion_Applied__c = siteQuote.Wireline_Promotion_Applied_Old__c;
    
            //if(siteQuote.Wireline_Promotion_Id_Applied_Old__c != Null && siteQuote.Wireline_Promotion_Id_Applied_Old__c != '')
                siteQuote.Wireline_Promotion_Id_Applied__c = siteQuote.Wireline_Promotion_Id_Applied_Old__c;
            
                siteQuote.Wireline_Promotion_Name_Applied__c = siteQuote.Wireline_Promotion_Name_Applied_Old__c;
                
                siteQuote.Wireline_Promotion_Number_Applied__c = siteQuote.Wireline_Promotion_Number_Applied_Old__c;
    
            //if(siteQuote.Alternate_Access_IGLOO_Response_Old__c != Null && siteQuote.Alternate_Access_IGLOO_Response_Old__c != '')
                siteQuote.Alternate_Access_IGLOO_Response__c = siteQuote.Alternate_Access_IGLOO_Response_Old__c;
    
            //if(siteQuote.Alternate_Access_IGLOO_Request_Time_Old__c != Null)
                siteQuote.Alternate_Access_IGLOO_Request_Time__c = siteQuote.Alternate_Access_IGLOO_Request_Time_Old__c;
            
            //if(siteQuote.Igloo_Response_Received_Date_Old__c != Null)
                siteQuote.Iglow_Response_Received_Date__c = siteQuote.Igloo_Response_Received_Date_Old__c;
            
            //if(siteQuote.Alternate_Access_IGLOO_ResponseStatusOld__c != Null && siteQuote.Alternate_Access_IGLOO_ResponseStatusOld__c != '')
                siteQuote.Alternate_Access_IGLOO_Response_Status__c = siteQuote.Alternate_Access_IGLOO_ResponseStatusOld__c;
            
            //if(siteQuote.Alternate_Access_IGLOO_Failure_Code_Old__c != Null && siteQuote.Alternate_Access_IGLOO_Failure_Code_Old__c != '')
                siteQuote.Alternate_Access_IGLOO_Failure_Code__c = siteQuote.Alternate_Access_IGLOO_Failure_Code_Old__c;
            
            //if(siteQuote.Alternate_Access_IGLOO_Access_Speed_Old__c != Null && siteQuote.Alternate_Access_IGLOO_Access_Speed_Old__c != '')
                siteQuote.Alternate_Access_IGLOO_Access_Speed__c = siteQuote.Alternate_Access_IGLOO_Access_Speed_Old__c;
            
            //if(siteQuote.Alternate_Access_IGLOO_Access_Price_Old__c != Null)
                siteQuote.Alternate_Access_IGLOO_Access_Price__c = siteQuote.Alternate_Access_IGLOO_Access_Price_Old__c;
            
            //if(siteQuote.Alternate_Access_IGLOO_Interface_CodeOld__c != Null && siteQuote.Alternate_Access_IGLOO_Interface_CodeOld__c != '')
                siteQuote.Alternate_Access_IGLOO_Interface_Code__c = siteQuote.Alternate_Access_IGLOO_Interface_CodeOld__c;
            
            //if(siteQuote.Alternate_Access_IGLOO_ProcessCmpltd_Old__c != Null)
                siteQuote.Alternate_Access_IGLOO_Process_Completed__c = siteQuote.Alternate_Access_IGLOO_ProcessCmpltd_Old__c;
            
            //if(siteQuote.CSI_Conversation_Id_Old__c!= Null && siteQuote.CSI_Conversation_Id_Old__c!= '')
                siteQuote.CSI_Conversation_Id__c = siteQuote.CSI_Conversation_Id_Old__c;

            updatedJunctionList.add(siteQuote);
        }
        if(!updatedJunctionList.isEmpty()){
            update updatedJunctionList;
        }
    }
    public static void clearWirelinePromotionAndIglooFeldsDataOnJunctionObject(List<AT_T_Customer_Site_Quote__c> junctionObjTobeUpdatedListp){
        system.debug('---clearwireline---');
        String quoteId = '';
        if(junctionObjTobeUpdatedListp[0].AT_T_Quote__c != Null){
            quoteId = junctionObjTobeUpdatedListp[0].AT_T_Quote__c;
            clearValuesOnQuote(quoteId);
        }
        
        List<AT_T_Customer_Site_Quote__c> updatedJunctionList = new List<AT_T_Customer_Site_Quote__c>();
        for(AT_T_Customer_Site_Quote__c siteQuote : junctionObjTobeUpdatedListp){
            siteQuote.Wireline_Promotion_Id_Sorted_Old__c = '';
            siteQuote.Wireline_Promotion_Id_Before_Old__c = '';
            siteQuote.Wireline_Promotion_Id_After_Old__c = '';
            siteQuote.Wireline_Promotion_Applied_Old__c = false;
            siteQuote.Wireline_Promotion_Id_Applied_Old__c = '';
            siteQuote.Alternate_Access_IGLOO_Response_Old__c = '';
            siteQuote.Alternate_Access_IGLOO_Request_Time_Old__c = Null;
            siteQuote.Igloo_Response_Received_Date_Old__c = Null;
            siteQuote.Alternate_Access_IGLOO_ResponseStatusOld__c = '';
            siteQuote.Alternate_Access_IGLOO_Failure_Code_Old__c = '';
            siteQuote.Alternate_Access_IGLOO_Access_Speed_Old__c = '';
            siteQuote.Alternate_Access_IGLOO_Access_Price_Old__c = Null;
            siteQuote.Alternate_Access_IGLOO_Interface_CodeOld__c = '';
            siteQuote.Alternate_Access_IGLOO_ProcessCmpltd_Old__c = false;
            siteQuote.CSI_Conversation_Id_Old__c = '';
            siteQuote.Wireline_Promotion_Number_Applied_Old__c = '';
            siteQuote.Wireline_Promotion_Name_Applied_Old__c = '';
            
            updatedJunctionList.add(siteQuote);
        }
        if(!updatedJunctionList.isEmpty()){
            update updatedJunctionList;
        }
    }
    public static void clearValuesOnQuote(string quoteIdp){
        Apttus_Proposal__Proposal__c quoteObj = new Apttus_Proposal__Proposal__c();
        quoteObj = [SELECT id,Wireline_Promotions_at_SP_Order_LevelOld__c,Wireline_Promotions_at_Deal_Reg_LevelOld__c FROM Apttus_Proposal__Proposal__c WHERE id =: quoteIdp];
        quoteObj.Wireline_Promotions_at_SP_Order_LevelOld__c = '';
        quoteObj.Wireline_Promotions_at_Deal_Reg_LevelOld__c = '';
        update quoteObj;
    }
    
    public static void copyCurrentPromotionIdsBeforeChanging(String quoteIdp){
        List<Apttus_Proposal__Proposal__c> quoteObjList = new List<Apttus_Proposal__Proposal__c>();
        List<AT_T_Customer_Site_Quote__c> allJunctionObjofQuoteList = new List<AT_T_Customer_Site_Quote__c>();
        List<AT_T_Customer_Site_Quote__c> junctionListtoBeUpdated = new List<AT_T_Customer_Site_Quote__c>();
        
        if(quoteIdp != Null){
            quoteObjList = [SELECT id,Wireline_Promotions_at_SP_Order_Level__c,Wireline_Promotions_at_Deal_Reg_Level__c,Wireline_Promotions_at_SP_Order_LevelOld__c,Wireline_Promotions_at_Deal_Reg_LevelOld__c,Apttus_Proposal__Opportunity__c,SP_Status_Backend__c FROM Apttus_Proposal__Proposal__c WHERE id =: quoteIdp];
            
            allJunctionObjofQuoteList = [SELECT id,AT_T_Customer_Site__c,Wireline_Promotion_Id_Sorted__c,Wireline_Promotion_Id_Sorted_Old__c,Wireline_Promotion_Id_Before__c,Wireline_Promotion_Id_Before_Old__c,
                                            Wireline_Promotion_Id_After__c,Wireline_Promotion_Id_After_Old__c,Wireline_Promotion_Applied_Old__c,Wireline_Promotion_Applied__c,Wireline_Promotion_Id_Applied__c,
                                            Wireline_Promotion_Id_Applied_Old__c,Alternate_Access_IGLOO_Response__c,Alternate_Access_IGLOO_Response_Old__c,Alternate_Access_IGLOO_Request_Time__c,
                                            Alternate_Access_IGLOO_Request_Time_Old__c,Iglow_Response_Received_Date__c,Igloo_Response_Received_Date_Old__c,Alternate_Access_IGLOO_Response_Status__c,
                                            Alternate_Access_IGLOO_ResponseStatusOld__c,Alternate_Access_IGLOO_Failure_Code__c,Alternate_Access_IGLOO_Failure_Code_Old__c,Alternate_Access_IGLOO_Access_Speed__c,
                                            Alternate_Access_IGLOO_Access_Speed_Old__c,Alternate_Access_IGLOO_Access_Price__c,Alternate_Access_IGLOO_Access_Price_Old__c,Alternate_Access_IGLOO_Interface_Code__c,
                                            Alternate_Access_IGLOO_Interface_CodeOld__c,Alternate_Access_IGLOO_Process_Completed__c,Alternate_Access_IGLOO_ProcessCmpltd_Old__c,CSI_Conversation_Id__c,
                                            CSI_Conversation_Id_Old__c,Wireline_Promotion_Name_Applied__c,Wireline_Promotion_Name_Applied_Old__c,Wireline_Promotion_Number_Applied__c,Wireline_Promotion_Number_Applied_Old__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c =: quoteIdp];
        }
        if(!quoteObjList.isEmpty()){ 
            if(quoteObjList[0].Wireline_Promotions_at_SP_Order_Level__c != Null){
                quoteObjList[0].Wireline_Promotions_at_SP_Order_LevelOld__c = quoteObjList[0].Wireline_Promotions_at_SP_Order_Level__c;
            }
            update quoteObjList[0];
        }
        if(!allJunctionObjofQuoteList.isEmpty()){
            For(AT_T_Customer_Site_Quote__c junObj : allJunctionObjofQuoteList){
                if(junObj.Wireline_Promotion_Id_Sorted__c != Null && junObj.Wireline_Promotion_Id_Sorted__c != '')
                junObj.Wireline_Promotion_Id_Sorted_Old__c = junObj.Wireline_Promotion_Id_Sorted__c;
            
                if(junObj.Wireline_Promotion_Id_Before__c != Null && junObj.Wireline_Promotion_Id_Before__c != '')
                    junObj.Wireline_Promotion_Id_Before_Old__c = junObj.Wireline_Promotion_Id_Before__c;
                
                if(junObj.Wireline_Promotion_Id_After__c != Null && junObj.Wireline_Promotion_Id_After__c != '')
                    junObj.Wireline_Promotion_Id_After_Old__c = junObj.Wireline_Promotion_Id_After__c;
                
                if(junObj.Wireline_Promotion_Name_Applied__c != Null && junObj.Wireline_Promotion_Name_Applied__c != '')
                    junObj.Wireline_Promotion_Name_Applied_Old__c = junObj.Wireline_Promotion_Name_Applied__c;
                
                if(junObj.Wireline_Promotion_Number_Applied__c != Null && junObj.Wireline_Promotion_Number_Applied__c != '')
                    junObj.Wireline_Promotion_Number_Applied_Old__c = junObj.Wireline_Promotion_Number_Applied__c;
                
                if(junObj.Wireline_Promotion_Applied__c != Null)
                    junObj.Wireline_Promotion_Applied_Old__c = junObj.Wireline_Promotion_Applied__c;
        
                if(junObj.Wireline_Promotion_Id_Applied__c != Null && junObj.Wireline_Promotion_Id_Applied__c != '')
                    junObj.Wireline_Promotion_Id_Applied_Old__c = junObj.Wireline_Promotion_Id_Applied__c;
        
                if(junObj.Alternate_Access_IGLOO_Response__c != Null && junObj.Alternate_Access_IGLOO_Response__c != '')
                    junObj.Alternate_Access_IGLOO_Response_Old__c = junObj.Alternate_Access_IGLOO_Response__c;
        
                if(junObj.Alternate_Access_IGLOO_Request_Time__c != Null)
                    junObj.Alternate_Access_IGLOO_Request_Time_Old__c = junObj.Alternate_Access_IGLOO_Request_Time__c;
                
                if(junObj.Iglow_Response_Received_Date__c != Null)
                    junObj.Igloo_Response_Received_Date_Old__c = junObj.Iglow_Response_Received_Date__c;
                
                if(junObj.Alternate_Access_IGLOO_Response_Status__c != Null && junObj.Alternate_Access_IGLOO_Response_Status__c != '')
                    junObj.Alternate_Access_IGLOO_ResponseStatusOld__c = junObj.Alternate_Access_IGLOO_Response_Status__c;
                
                if(junObj.Alternate_Access_IGLOO_Failure_Code__c != Null && junObj.Alternate_Access_IGLOO_Failure_Code__c != '')
                    junObj.Alternate_Access_IGLOO_Failure_Code_Old__c = junObj.Alternate_Access_IGLOO_Failure_Code__c;
                
                if(junObj.Alternate_Access_IGLOO_Access_Speed__c != Null && junObj.Alternate_Access_IGLOO_Access_Speed__c != '')
                    junObj.Alternate_Access_IGLOO_Access_Speed_Old__c = junObj.Alternate_Access_IGLOO_Access_Speed__c;
                
                if(junObj.Alternate_Access_IGLOO_Access_Price__c != Null)
                    junObj.Alternate_Access_IGLOO_Access_Price_Old__c = junObj.Alternate_Access_IGLOO_Access_Price__c;
                
                if(junObj.Alternate_Access_IGLOO_Interface_Code__c != Null && junObj.Alternate_Access_IGLOO_Interface_Code__c != '')
                    junObj.Alternate_Access_IGLOO_Interface_CodeOld__c = junObj.Alternate_Access_IGLOO_Interface_Code__c;
                
                if(junObj.Alternate_Access_IGLOO_Process_Completed__c != Null)
                    junObj.Alternate_Access_IGLOO_ProcessCmpltd_Old__c = junObj.Alternate_Access_IGLOO_Process_Completed__c;
                
                if(junObj.CSI_Conversation_Id__c != Null && junObj.CSI_Conversation_Id__c != '')
                    junObj.CSI_Conversation_Id_Old__c = junObj.CSI_Conversation_Id__c;
                junctionListtoBeUpdated.add(junObj);
            }
            if(!junctionListtoBeUpdated.isEmpty()){
                update junctionListtoBeUpdated;
            }
        }
    }

}