/*************************************************************************************************************************************** 
Apex Class Name     : DealRegistrationBatchProcessUpgrade 
Version             : 1.0 
Created Date        : 1 Jan 2015
Function            : This class handles the logic for finalizing the cart, creating Pricing components and applying discounts
****************************************************************************************************************************************/
global class  DealRegistrationBatchProcessUpgrade implements Database.Batchable<sObject> {
    
    global String quoteId;
    global String opptyId;
    global final ApttusServiceUtilityHelper helper = new ApttusServiceUtilityHelper();
    global final Set<Id> qList = new Set<Id>();
    global Boolean isUpdateOpportunity = false;
    global Boolean isMACDSpecialPricing = false;
    
    /*Batch Constructor*/
    global DealRegistrationBatchProcessUpgrade(List<Id> qtId, String oppId){
        this.opptyId = oppId;
        this.qList.addAll(qtId);
        this.quoteId = qtId[0];    
    }
    
    /*Batch start method to finalize the cart and query the list of sites for the quote*/
    global Database.QueryLocator start(Database.BatchableContext BC){
        list<String> statusList = new list<String>();
        statusList.add('New');
        statusList.add('Saved');
        statusList.add('SAVED');
        if(quoteId != null){
            List<Apttus_Proposal__Proposal__c>  quoteFinalizeList = [select id,IsBIDMigrationCompleted__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Proposal_Name__c,(Select Id From Apttus_QPConfig__Configurations__r WHERE Apttus_Config2__Status__c in: statusList ) from Apttus_Proposal__Proposal__c where id = :quoteId];                    
            if(quoteFinalizeList.size()>0){
                if(quoteFinalizeList[0].Apttus_QPConfig__Configurations__r!= null && quoteFinalizeList[0].Apttus_QPConfig__Configurations__r.size()>0){
                    helper.finalizeCart(quoteFinalizeList[0].Apttus_QPConfig__Configurations__r[0].Id);
                    system.debug('@@@DealRegistrationBatchProcessUpgrade - Cart Finalized');
                }
            }    
        }         
        String queryString = 'SELECT AT_T_Quote__c,AT_T_Customer_Site__r.Site_Name__c,Site_Id__c,AT_T_Customer_Site__c,AT_T_Customer_Site__r.name,AT_T_Customer_Site__r.State__c,AT_T_Customer_Site__r.City__c,AT_T_Customer_Site__r.Country__c,AT_T_Customer_Site__r.Phone__c,AT_T_Customer_Site__r.Address_Line__c,AT_T_Customer_Site__r.Zip_Code__c, AT_T_Quote__r.Apttus_Proposal__Approval_Stage__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Expiration_Date__c,AT_T_Quote__r.Product__r.ProductCode,AT_T_Quote__r.City__c,AT_T_Quote__r.State__c,AT_T_Quote__r.Business_Address_Line_2__c,AT_T_Quote__r.Product__r.name,AT_T_Quote__r.End_Customer__r.Name,AT_T_Quote__r.End_Customer__c ,AT_T_Quote__r.Business_Address_Line_1__c,AT_T_Quote__r.Zip_Code__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__c,AT_T_Quote__r.DUNS_Number__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__r.MACD_Type__c,AT_T_Quote__r.Renewal_Contract__c,AT_T_Quote__r.SubAccountNumber__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__r.RDS_Version__c from AT_T_Customer_Site_Quote__c where AT_T_Quote__c='+'\''+quoteId+'\'';
        return Database.getQueryLocator(queryString);
    }
    
    /*Batch execute logic to do the business logic per site*/
    global void execute( Database.BatchableContext BC, List<AT_T_Customer_Site_Quote__c> jncList){
        
        system.debug('@@@execute');
        List<Apttus_Proposal__Proposal__c> quoteLst = new List<Apttus_Proposal__Proposal__c>();
        Map<String,List<Apttus_Config2__LineItem__c> > mapProposalLineItem = new Map<String,List<Apttus_Config2__LineItem__c> >();
        boolean isSuccess = false;
        Savepoint sp = null;
        sp = Database.setSavepoint();
        Double listPrice = 0.0;
        List<SPProduct__c> spProductList = new List<SPProduct__c>();
        
        // Query Quote Line Item       
        List<Apttus_Config2__LineItem__c> proposalLineItem  =  [SELECT AccessSpeed__c,Apttus_Config2__AttributeValueId__r.Ported_Phone_Numbers__c,Apttus_Config2__AttributeValueId__r.New_Local_Phone_Numbers__c,Apttus_Config2__PriceListId__r.Name,Access_Speed__c,Apttus_Config2__AttributeValueId__r.New_Virtual_Phone_Numbers__c,
                                                                Apttus_Config2__AttributeValueId__r.Concurrent_Calls__c,Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c,Apttus_Config2__AttributeValueId__r.Enhanced_features__c,Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c,Apttus_Config2__AttributeValueId__r.Install_Option_MIS__c,Apttus_Config2__AttributeValueId__r.Apttus_Config2__Vendor__c,Apttus_Config2__AttributeValueId__r.ContractRenewal_IglooError__c,Apttus_Config2__AttributeValueId__r.VASA_Region__c,Access_Type__c,Account_Tier__c,AdditionalDnsType__c,Apttus_Config2__AdjustmentAmount__c,Apttus_Config2__AdjustmentType__c,Apttus_Config2__AttributeValueId__c,Apttus_Config2__BaseExtendedCost__c,Apttus_Config2__BaseExtendedPrice__c,
                                                                Apttus_Config2__BasePriceMethod__c,Apttus_Config2__BasePriceOverride__c,Apttus_Config2__BasePrice__c,Apttus_Config2__BaseProductId__c,Apttus_Config2__ChargeType__c,Apttus_Config2__ConfigurationId__c,Apttus_Config2__EndDate__c,Apttus_Config2__LineNumber__c,Apttus_Config2__NetPrice__c,Apttus_Config2__Term__c,AT_T_Customer_Site__c,
                                                                CreatedDate,Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c,One_Time_Fee__c,Apttus_Config2__PriceType__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Payment_Term__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.MACD_Change_Type__c,VOIP__c,Apttus_Config2__LineType__c,
                                                                Apttus_Config2__AttributeValueId__r.Managed_Router__c,Port_Speed__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Traffic_Jurisdiction__c,Apttus_Config2__PriceListItemId__r.Name,Port_Type__c,Product_Code__c,VASARegion__c,Vasa_region__c,Extra_Mileage_Charge__c,Extra_Mileage__c,Installation_Option__c,Interface_Type__c,IsBatchUpdate__c,IsDuplicated__c,isPricingApplied__c,Lec_Name__c,Managed_Router__c,MBC_Speed__c,Mileages__c,Mileage__c,Name,Net_Price_with_SP_Order_Discounts__c, Original_Net_Price__c, WP_Hidden_Discount_Percentage__c, Wireline_Promotion_Discount_Percentage__c,Wireline_Promo_Discount_Deal_Reg__c,Wireline_Promo_Discount_SP_Order__c, Net_Price_with_Deal_Reg_Discounts__c, Original_Hidden_Price__c,Wireline_Promotion_Name_Applied__c,Wireline_Promotion_Number_Applied__c FROM Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c IN:qList and Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c='Finalized'];
        
        List<AT_T_Customer_Site_Quote__c> cJunSiteList = jncList;        
        Map<String,List<Apttus_Config2__LineItem__c>> quoteLineItemMap = new Map<String,List<Apttus_Config2__LineItem__c>>();
        Map<String,Boolean> vLANMAP = new Map<String,Boolean>();
        Map<String,Boolean> iNTERSTATEMAP = new Map<String,Boolean>();
        Map<String,Boolean> iNTRASTATEMAP = new Map<String,Boolean>();
        Map<String,Boolean> pORTTYEPMAP = new Map<String,Boolean>();
        Map<String,Boolean> cOSTYEPMAP = new Map<String,Boolean>();
        Map<id,String> pORTTYEPMAPWithLineItemId = new Map<id,String>();
        Map<id,String> coSTYEPMAPWithLineItemId= new Map<id,String>();
        Map<id,String> cIRTYEPMAPWithLineItemId= new Map<id,String>();
        Boolean isVLAN = false;
        Set<String> priceListItem = New Set<String>();
        
        Map<String,Apttus_Config2__PriceMatrixEntry__c> mapPriceMatrixEntry= New Map<String,Apttus_Config2__PriceMatrixEntry__c>();
        Map<String,Apttus_Config2__PriceMatrixEntry__c> mapPriceMatrixEntryFeatureAccess= New Map<String,Apttus_Config2__PriceMatrixEntry__c>();
        
        // Creating map based on the site for charge types        
        for(Apttus_Config2__LineItem__c p : proposalLineItem){
            priceListItem.add(p.Apttus_Config2__PriceListItemId__r.Name);  
            if(quoteLineItemMap.containskey(p.AT_T_Customer_Site__c)){
                quoteLineItemMap.get(p.AT_T_Customer_Site__c).add(p);                   
            }else{
                quoteLineItemMap.put(p.AT_T_Customer_Site__c,new List<Apttus_Config2__LineItem__c>{p});
            }
            if(p.Apttus_Config2__ChargeType__c!=null){
                if(p.Apttus_Config2__ChargeType__c.contains(ATT_Constant.VLAN)){
                    VLANMAP.put(p.AT_T_Customer_Site__c,true);
                    COSTYEPMAP.put(p.AT_T_Customer_Site__c,false);
                    isVLAN = true;
                }else if(p.Apttus_Config2__ChargeType__c.contains(ATT_Constant.COS) && isVLAN == false){
                    VLANMAP.put(p.AT_T_Customer_Site__c,false);
                    COSTYEPMAP.put(p.AT_T_Customer_Site__c,true);                
                }
                
                if(p.Apttus_Config2__ChargeType__c.contains(ATT_Constant.PORT_SPEED)){
                    PORTTYEPMAP.put(p.AT_T_Customer_Site__c,true);
                    PORTTYEPMAPWithLineItemId.put(p.AT_T_Customer_Site__c,p.Apttus_Config2__ChargeType__c);
                }
            }
            if(p.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Traffic_Jurisdiction__c == UtilityConstant.INTERSTATE){
                INTERSTATEMAP.put(p.AT_T_Customer_Site__c,true);
                INTRASTATEMAP.put(p.AT_T_Customer_Site__c,false);
            }
            if(p.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Traffic_Jurisdiction__c == UtilityConstant.INTRASTATE){
                INTRASTATEMAP.put(p.AT_T_Customer_Site__c,true);
                INTERSTATEMAP.put(p.AT_T_Customer_Site__c,false);
            }
        }
        
        List<Apttus_Config2__LineItem__c> proposalList = new List<Apttus_Config2__LineItem__c>(); 
        List<Apttus_Config2__LineItem__c> quoteProposalList = new List<Apttus_Config2__LineItem__c>(); 
        String accessSpeedVal;
        String accessspeedvalue=SpecialCharacterConstant.CONCAT;
        Decimal accessSpeed;
        Integer i = 0;
        String finalSiteNo = SpecialCharacterConstant.CONCAT;
        
        //SP Product Insertion
        for(AT_T_Customer_Site_Quote__c prop : cJunSiteList){   
            if(quoteLineItemMap.containsKey(prop.AT_T_Customer_Site__c)){  
                listPrice = 0.0;
                proposalList = quoteLineItemMap.get(prop.AT_T_Customer_Site__c);
                SPProduct__c spProductObj = new SPProduct__c();                 
                spProductObj.List_Price__c = 0.0; 
                spProductObj.one_time_revenue__c = 0.0;
                
                for(Apttus_Config2__LineItem__c pLine : proposalList){                    
                    if((pline.Product_Code__c==ATT_Constant.AMIS || pline.Product_Code__c==ATT_Constant.A_VPN) && pLine.Apttus_Config2__ChargeType__c!=null ){
                        if(pline.Product_Code__c==ATT_Constant.AMIS){
                            if(pLine.Apttus_Config2__ChargeType__c==UtilityConstant.ACCESSSPEED_FEE){
                                spProductObj.Access_Speed_Physical_Value__c = helper.physicalSpeedCalculation(pLine.AccessSpeed__c); 
                                spProductObj.Access_Speed_Name__c = pLine.AccessSpeed__c;
                                spProductObj.Access_Speed_List_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                spProductObj.Access_Speed_Type__c = PLine.Access_Type__c;
                                listPrice=listPrice + (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                if(pLIne.Apttus_Config2__AttributeValueId__r.VASA_Region__c==UtilityConstant.INREGION){
                                    spProductObj.Region__c=UtilityConstant.IR;
                                }else if(pLIne.Apttus_Config2__AttributeValueId__r.VASA_Region__c==UtilityConstant.OO1 || pLIne.Apttus_Config2__AttributeValueId__r.VASA_Region__c==UtilityConstant.OO1A|| pLIne.Apttus_Config2__AttributeValueId__r.VASA_Region__c==UtilityConstant.OO2) {
                                    spProductObj.Region__c=UtilityConstant.STATIC_OR;
                                }
                                if(pLIne.Apttus_Config2__AttributeValueId__r.Apttus_Config2__Vendor__c!=null || pLIne.Apttus_Config2__AttributeValueId__r.Apttus_Config2__Vendor__c!=''){
                                    if(pLIne.Apttus_Config2__AttributeValueId__r.VASA_Region__c==UtilityConstant.INREGION){
                                        spProductObj.Access_Vendor_LEC__c=UtilityConstant.ATT;  
                                    }else{
                                        spProductObj.Access_Vendor_LEC__c=pLIne.Apttus_Config2__AttributeValueId__r.Apttus_Config2__Vendor__c;
                                    }
                                }
                                //Contract Renewal Error Flag - Old prices fetched due to IGLOO Call Error                            
                                spProductObj.ContractRenewal_IglooError__c = pLine.Apttus_Config2__AttributeValueId__r.ContractRenewal_IglooError__c;
                            }
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.PORT_SPEED)){
                                spProductObj.Port_Speed_Physical_Value__c=String.valueOf(helper.physicalSpeedCalculation(pLine.Port_Speed__c));
                                spProductObj.Port_Speed_Name__c = pLine.Port_Speed__c;
                                spProductObj.Port_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                spProductObj.MBC_Speed__c = pLine.MBC_Speed__c;
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                            }
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.contains(ATT_Constant.COS)){
                                spProductObj.COS_Product_Name__c =ATT_Constant.COS;
                                spProductObj.COS_List_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);                            
                            }
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.Contains('One Time')){ 
                                if(pLine.Apttus_Config2__AttributeValueId__r.Install_Option_MIS__c==UtilityConstant.ONSITEINSTALL){
                                    spProductObj.Onsite_Install_Charges__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                }
                                else if(pLine.Apttus_Config2__AttributeValueId__r.Install_Option_MIS__c==UtilityConstant.TELEINSTALL){
                                    spProductObj.Tele_Install_Charges__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                }
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                            }
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.Contains('Additional DNS Fee')){
                                spProductObj.Additional_DNS__c = pLine.AdditionalDnsType__c;
                            }
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.IP_FLEX_REACH_PLAN)){
                                spProductObj.Ip_Flex_Reach_Plan_Name__c=pline.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c;
                                spProductObj.IP_FLEX_REACH_PLAN_List_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);                                
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);                
                            }
                            
                            if(pLine.Apttus_Config2__AttributeValueId__r.Managed_Router__c && (pLine.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c==UtilityConstant.MISPLUS_PORT ||  pLine.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Description__c==UtilityConstant.MISPLUS_WITH_MINIMUM_BANDWIDTH_COMMITMENT)){
                                spProductObj.Managed__c=true;                           
                            }  
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.VTN_FEE)){
                                spProductObj.VTN_Fee_Name__c=String.valueOf(pline.Apttus_Config2__AttributeValueId__r.New_Virtual_Phone_Numbers__c);
                                spProductObj.VTN_FEE_List_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                            }
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.VOIP)){
                                spProductObj.VOIP_Name__c=pline.VOIP__c;
                                spProductObj.VOIP_List_Price__c = pLine.Apttus_Config2__NetPrice__c;
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);                        
                            }
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.ENHANCED_FEATURES)){
                                if(pline.Apttus_Config2__AttributeValueId__r.Enhanced_features__c!=null){                          
                                    spProductObj.Enhanced_Features_Name__c=pline.Apttus_Config2__AttributeValueId__r.Enhanced_features__c;
                                }else{
                                    spProductObj.Enhanced_Features_Name__c=UtilityConstant.NONE;
                                }
                                spProductObj.ENHANCED_FEATURES_List_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                            }else{
                                spProductObj.Enhanced_Features_Name__c=UtilityConstant.NONE;
                            }
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.SETUP_FEE)){
                                spProductObj.SETUP_FEE_Name__c=pline.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c;
                                spProductObj.SETUP_FEE_List_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                            }
                            spProductObj.Concurrent_Calls__c=pLine.Apttus_Config2__AttributeValueId__r.Concurrent_Calls__c;
                            spProductObj.New_Virtual_Phone_Numbers__c=pLine.Apttus_Config2__AttributeValueId__r.New_Virtual_Phone_Numbers__c;
                            spProductObj.New_Local_Phone_Numbers__c=pLine.Apttus_Config2__AttributeValueId__r.New_Local_Phone_Numbers__c;
                            spProductObj.Ported_Phone_Numbers__c=pLine.Apttus_Config2__AttributeValueId__r.Ported_Phone_Numbers__c;                                                     
                        }
                        else if(pline.Product_Code__c==ATT_Constant.A_VPN){                            
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c==UtilityConstant.ACCESSSPEED_FEE){
                                spProductObj.Access_Speed_Physical_Value__c = helper.physicalSpeedCalculation(pLine.AccessSpeed__c); 
                                spProductObj.Access_Speed_Name__c = pLine.AccessSpeed__c;
                                spProductObj.Access_Speed_List_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                spProductObj.Access_Speed_Type__c = pLine.Access_Type__c;
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                if(pLIne.Apttus_Config2__AttributeValueId__r.VASA_Region__c==UtilityConstant.INREGION){
                                    spProductObj.Region__c=UtilityConstant.IR;                                    
                                }else if(pLIne.Apttus_Config2__AttributeValueId__r.VASA_Region__c==UtilityConstant.OO1 || pLIne.Apttus_Config2__AttributeValueId__r.VASA_Region__c==UtilityConstant.OO1A|| pLIne.Apttus_Config2__AttributeValueId__r.VASA_Region__c==UtilityConstant.OO2) {
                                    spProductObj.Region__c=UtilityConstant.STATIC_OR;
                                }
                                
                                if(pLIne.Apttus_Config2__AttributeValueId__r.Apttus_Config2__Vendor__c!=null || pLIne.Apttus_Config2__AttributeValueId__r.Apttus_Config2__Vendor__c!=SpecialCharacterConstant.CONCAT){
                                    if(pLIne.Apttus_Config2__AttributeValueId__r.VASA_Region__c==UtilityConstant.INREGION){
                                        spProductObj.Access_Vendor_LEC__c=UtilityConstant.ATT;  
                                    }else{
                                        spProductObj.Access_Vendor_LEC__c=pLIne.Apttus_Config2__AttributeValueId__r.Apttus_Config2__Vendor__c;
                                    }
                                }
                                //Contract Renewal Error Flag - Old prices fetched due to IGLOO Call Error                            
                                spProductObj.ContractRenewal_IglooError__c = pLine.Apttus_Config2__AttributeValueId__r.ContractRenewal_IglooError__c;
                            }
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.PORT_SPEED)){
                                spProductObj.Port_Speed_Physical_Value__c=String.valueOf(helper.physicalSpeedCalculation(pLine.Port_Speed__c));
                                spProductObj.Port_Speed_Name__c = pLine.Port_Speed__c;
                                spProductObj.Port_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                spProductObj.MBC_Speed__c = pLine.MBC_Speed__c;
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                            }
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.contains(ATT_Constant.COS)){
                                spProductObj.COS_Product_Name__c =ATT_Constant.COS;
                                spProductObj.COS_List_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);                              
                            }
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.contains('One Time')){
                                spProductObj.Onsite_Install_Charges__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                            }
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.IP_FLEX_REACH_PLAN)){
                                spProductObj.Ip_Flex_Reach_Plan_Name__c=pline.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c;
                                spProductObj.IP_FLEX_REACH_PLAN_List_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);                               
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                            }
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.VTN_FEE)){
                                spProductObj.VTN_Fee_Name__c=String.ValueOf(pline.Apttus_Config2__AttributeValueId__r.New_Virtual_Phone_Numbers__c);
                                spProductObj.VTN_FEE_List_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                            }
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.VOIP)){
                                spProductObj.VOIP_Name__c=pline.VOIP__c;
                                spProductObj.VOIP_List_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                            }
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.ENHANCED_FEATURES)){
                                if(pline.Apttus_Config2__AttributeValueId__r.Enhanced_features__c!=null){                          
                                    spProductObj.Enhanced_Features_Name__c=pline.Apttus_Config2__AttributeValueId__r.Enhanced_features__c;
                                }else{
                                    spProductObj.Enhanced_Features_Name__c=UtilityConstant.NONE;
                                }
                                spProductObj.ENHANCED_FEATURES_List_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                            }else{
                                spProductObj.Enhanced_Features_Name__c=UtilityConstant.NONE;
                            }
                            
                            if(pLine.Apttus_Config2__ChargeType__c!=null && pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.SETUP_FEE)){
                                spProductObj.SETUP_FEE_Name__c=pline.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c;
                                spProductObj.SETUP_FEE_List_Price__c = (pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                listPrice=listPrice+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);                           
                            }
                            
                            spProductObj.Concurrent_Calls__c=pLine.Apttus_Config2__AttributeValueId__r.Concurrent_Calls__c;
                            spProductObj.New_Virtual_Phone_Numbers__c=pLine.Apttus_Config2__AttributeValueId__r.New_Virtual_Phone_Numbers__c;
                            spProductObj.New_Local_Phone_Numbers__c=pLine.Apttus_Config2__AttributeValueId__r.New_Local_Phone_Numbers__c;
                            spProductObj.Ported_Phone_Numbers__c=pLine.Apttus_Config2__AttributeValueId__r.Ported_Phone_Numbers__c;
                        }
                        if(String.isNotBlank(pline.Wireline_Promotion_Name_Applied__c) && spProductObj.DPE_Promotions_applied_except_Deal_Reg__c != true){                          
                            spProductObj.DPE_Promotions_applied_except_Deal_Reg__c= true;
                        }
                        if(String.isNotBlank(pline.Wireline_Promotion_Name_Applied__c) && (pline.Wireline_Promotion_Name_Applied__c.contains('_Access') || pline.Wireline_Promotion_Name_Applied__c.contains('_Port') || pline.Wireline_Promotion_Name_Applied__c.contains('_Feature')) && spProductObj.Site_Level_Promotions_applied__c != true){
                            spProductObj.Site_Level_Promotions_applied__c= true;
                        }
                    }
                    
                    if(pLine.Apttus_Config2__LineType__c == ATT_Constant.PRODUCTSERVICE){
                        if(pLine.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                            spProductObj.List_Price__c = spProductObj.List_Price__c+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                        }
                        else if( pLine.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE ){
                            spProductObj.one_time_revenue__c = spProductObj.one_time_revenue__c+(pline.Original_Net_Price__c != null && pline.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                        }
                    }
                    spProductObj.Term_Length__c = pline.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Payment_Term__c;
                    
                }
                
                spProductObj.End_Customer_Name__c = prop.AT_T_Quote__r.End_Customer__r.Name;
                spProductObj.Quote_Expiration_Date__c = prop.AT_T_Quote__r.Apttus_Proposal__Proposal_Expiration_Date__c;
                spProductObj.State__c = prop.AT_T_Customer_Site__r.State__c;
                spProductObj.Street__c = prop.AT_T_Customer_Site__r.Address_Line__c;
                spProductObj.City__c = prop.AT_T_Customer_Site__r.City__c;
                spProductObj.Mailing_Street_Address__c = prop.AT_T_Customer_Site__r.Address_Line__c;
                spProductObj.Zip__c = String.isempty(prop.AT_T_Customer_Site__r.Zip_Code__c)? null : prop.AT_T_Customer_Site__r.Zip_Code__c;
                spProductObj.DUNS__c = prop.AT_T_Quote__r.DUNS_Number__c;                 
                spProductObj.Deal__c = prop.AT_T_Quote__r.Apttus_Proposal__Opportunity__c;
                spProductObj.MACD_Type__c = prop.AT_T_Quote__r.Apttus_Proposal__Opportunity__r.MACD_Type__c;
                spProductObj.Product_Name__c =  prop.AT_T_Quote__r.Product__r.name; 
                spProductObj.Site_Friendly_Name__c = prop.AT_T_Customer_Site__r.Site_Name__c;                              
                spProductObj.Site_ID__c = prop.Site_Id__c;
                spProductObj.CustomerSiteID__c = prop.AT_T_Customer_Site__c;
                
                if(Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().containskey(prop.AT_T_Quote__r.Product__r.ProductCode)){ // Null check added by Praveen (Defect : DE86900)               
                    spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(prop.AT_T_Quote__r.Product__r.ProductCode).getRecordTypeId();
                }    
                else if(prop.AT_T_Quote__r.Product__r.ProductCode == ATT_Constant.AMIS ){
                    spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(ATT_Constant.MIS).getRecordTypeId();                  
                }
                else if(prop.AT_T_Quote__r.Product__r.ProductCode == ATT_Constant.ASES ){
                    spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(ATT_Constant.ASE).getRecordTypeId();                  
                }
                else if(prop.AT_T_Quote__r.Product__r.ProductCode == ATT_Constant.STAAS){
                    spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(ATT_Constant.Sta).getRecordTypeId();                  
                }
                else if(prop.AT_T_Quote__r.Product__r.ProductCode == ATT_Constant.CAAS){
                    spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(ATT_Constant.Ca).getRecordTypeId();                   
                }
                else if(prop.AT_T_Quote__r.Product__r.ProductCode == ATT_Constant.AIA){
                    spProductObj.RecordTypeId = Schema.SObjectType.SPProduct__c.getRecordTypeInfosByName().get(ATT_Constant.BROAD).getRecordTypeId();                   
                }
                //Contract Renewal Logic
                if(prop.AT_T_Quote__r.Renewal_Contract__c == true){
                    spProductObj.Renewal_Contract__c = prop.AT_T_Quote__r.Renewal_Contract__c;
                    spProductObj.Sub_Account__c = prop.AT_T_Quote__r.SubAccountNumber__c;
                    spProductObj.RDS_Version__c = prop.AT_T_Quote__r.Apttus_Proposal__Opportunity__r.RDS_Version__c; 
                }
                spProductList.add(spProductObj);
            } 
        }                                       
        insert spProductList;                 
        
        //Product Pricing Record Insertion
        List<Product_Pricing__c> pPricingList = new List<Product_Pricing__c>();
        List<Site__c> siteList = new List <Site__c>();
        
        //Fetch the records of product mapping.
        Map<String,Product_Mapping__c> mapProductMap = new Map<String,Product_Mapping__c>();
        List<Product_Mapping__c> prodMapList = [select id,Name,BEID__c,Bill_Display_Name__c,Billing_Element__c,Combination__c,Determinant_Set_Id__c,Low_Level_Tier__c,PBIID__c,Associated_Price_List__c,
                                                Associated_Product_One_Selected__c,Associated_Product_Two_Selected__c,Rate_Amount__c from Product_Mapping__c];
        
        List<Apttus_Config2__PriceMatrixEntry__c> priceMatrixList=[Select Id,Determinant_Set_ID__c,BEID__c,Low_Level__c,PriceListItemId__c,PLName__c,BillDisplayName__c,PBI_Number__c,Apttus_Config2__PeriodEndDate__c,Apttus_Config2__Dimension1Value__c,Rate__r.Bill_Display_Name__c,Apttus_Config2__Dimension2Value__c from Apttus_Config2__PriceMatrixEntry__c where PLName__c IN :priceListItem and Apttus_Config2__PeriodEndDate__c=null ];  
        
        if(priceMatrixList!=null){
            for(Apttus_Config2__LineItem__c p : proposalLineItem){
                for(Apttus_Config2__PriceMatrixEntry__c priceMatrix:priceMatrixList){
                    if(pricematrix.PLName__c==p.Apttus_Config2__PriceListItemId__r.Name ){
                        mapPriceMatrixEntry.put(priceMatrix.Apttus_Config2__Dimension1Value__c+priceMatrix.PLName__c,priceMatrix);           
                        mapPriceMatrixEntryFeatureAccess.put(priceMatrix.Apttus_Config2__Dimension1Value__c+priceMatrix.Apttus_Config2__Dimension2Value__c+priceMatrix.PLName__c,priceMatrix);
                    }
                }
            }
        }
        
        for(Product_Mapping__c prodMap : prodMapList){
            mapProductMap.put(prodMap.Combination__c,prodMap);
        }        
        Map<String, List<Apttus_Config2__LineItem__c>> optionQuoteLineMap = new Map<String, List<Apttus_Config2__LineItem__c>>();
        
        for(SPProduct__c sprod : spProductList){            
            //Logic for AVPN product.  
            if(sprod.Product_Name__c == ATT_Constant.AVPN){                
                Product_Pricing__c vlanPricing = new Product_Pricing__c();
                Product_Pricing__c cosPricing = new Product_Pricing__c();
                if(quoteLineItemMap.containsKey(sprod.CustomerSiteID__c)){
                    quoteProposalList =  new List<Apttus_Config2__LineItem__c>();
                    quoteProposalList = quoteLineItemMap.get(sprod.CustomerSiteID__c);
                    string portspeed;
                    Decimal accessTotalFee = 0.00;
                    Decimal accessTotalDiscountedPrice = 0.00;
                    Decimal accessTotalNetPriceWithSPOrderDisc = 0.00;
                    Decimal accessTotalHiddenPrice = 0.00;
                    Decimal accessTotalOriginalNetPrice = 0.00;
                    
                    for(Apttus_Config2__LineItem__c accesPLine : quoteProposalList){
                        if(accesPLine.Apttus_Config2__ChargeType__c != null && accesPLine.Apttus_Config2__ChargeType__c.contains(ATT_Constant.PORT_SPEED) && sprod.CustomerSiteID__c== accesPLine.AT_T_Customer_Site__c) {
                            PortSpeed = accesPLine.Port_Speed__c;
                        }
                        if(accesPLine.Apttus_Config2__ChargeType__c != null && accesPLine.Apttus_Config2__ChargeType__c.containsIgnoreCase(UtilityConstant.ACCESSSPEED) && sprod.CustomerSiteID__c== accesPLine.AT_T_Customer_Site__c ){
                            accessTotalFee += (accesPLine.Original_Net_Price__c != null && accesPLine.Original_Net_Price__c!= 0.00 ? accesPLine.Original_Net_Price__c : accesPLine.Apttus_Config2__NetPrice__c);
                            accessTotalDiscountedPrice += (accesPLine.Net_Price_with_SP_Order_Discounts__c != null && accesPLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? accesPLine.Net_Price_with_SP_Order_Discounts__c : accesPLine.Apttus_Config2__NetPrice__c);
                            accessTotalNetPriceWithSPOrderDisc += (accesPLine.Net_Price_with_SP_Order_Discounts__c != null && accesPLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? accesPLine.Net_Price_with_SP_Order_Discounts__c : 0.00);
                            accessTotalHiddenPrice += accesPLine.Original_Hidden_Price__c = (accesPLine.Original_Hidden_Price__c != null && accesPLine.Original_Hidden_Price__c != 0.00 ? accesPLine.Original_Hidden_Price__c : 0.00);
                            accessTotalOriginalNetPrice += accesPLine.Original_Net_Price__c = (accesPLine.Original_Net_Price__c != null && accesPLine.Original_Net_Price__c != 0.00 ? accesPLine.Original_Net_Price__c : 0.00);
                        }                        
                    }
                    system.debug('@@@accessTotalFee:'+accessTotalFee);
                    system.debug('@@@accessTotalDiscountedPrice :'+accessTotalDiscountedPrice );
                    
                    for(Apttus_Config2__LineItem__c aPLine : quoteProposalList){                        
                        
                        if(aPLine.Apttus_Config2__ChargeType__c !=null && aPLine.Apttus_Config2__ChargeType__c.contains(ATT_Constant.VLAN)){
                            
                            if( PORTTYEPMAP.containsKey(aPLine.AT_T_Customer_Site__c) && PORTTYEPMAP.get(aPLine.AT_T_Customer_Site__c) == true){
                                Product_Pricing__c pPricicng = new Product_Pricing__c();
                                if(mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_Config2__PriceListItemId__r.Name)!=null){
                                    pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                    pPricicng.BEID__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                }
                                if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE)
                                    pPricicng.type__c = ATT_Constant.MRCTYPE;
                                if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                    pPricicng.type__c = ATT_Constant.NRCTYPE;
                                pPricicng.list_price__c =  (aPLine.Original_Net_Price__c != null && aPLine.Original_Net_Price__c!= 0.00 ? aPLine.Original_Net_Price__c : aPLine.Apttus_Config2__NetPrice__c);
                                pPricicng.discounted_price__c = (aPLine.Net_Price_with_SP_Order_Discounts__c != null && aPLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? aPLine.Net_Price_with_SP_Order_Discounts__c : aPLine.Apttus_Config2__NetPrice__c);
                                pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                pPricicng.SP_Product__c = sprod.id; 
                                pPricicng.Product_Detail__c = aPLine.Apttus_Config2__ChargeType__c;
                                pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (aPLine.WP_Hidden_Discount_Percentage__c !=null ? aPLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                pPricicng.Wireline_Promo_Discount_Map_Site__c = (aPLine.Wireline_Promotion_Discount_Percentage__c !=null ? aPLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (aPLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? aPLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                pPricicng.Wireline_Promo_Discount_SP_Order__c = (aPLine.Wireline_Promo_Discount_SP_Order__c != null  ? aPLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                pPricicng.Net_Price_with_SP_Order_Discounts__c = (aPLine.Net_Price_with_SP_Order_Discounts__c !=null ? aPLine.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                //Commented all pPricicng.Net_Price_with_Deal_Reg_Discounts__c as part of Prod Defect 566791                
                                // pPricicng.Net_Price_with_Deal_Reg_Discounts__c = (aPLine.Net_Price_with_Deal_Reg_Discounts__c !=null ? aPLine.Net_Price_with_Deal_Reg_Discounts__c : 0.00);
                                pPricicng.Original_Hidden_Price__c = (aPLine.Original_Hidden_Price__c !=null ? aPLine.Original_Hidden_Price__c : 0.00);
                                pPricicng.Original_Net_Price__c = (aPLine.Original_Net_Price__c !=null ? aPLine.Original_Net_Price__c : 0.00);
                                pPricicng.Wireline_Promotion_Name_Applied__c = aPLine.Wireline_Promotion_Name_Applied__c;
                                pPricicng.Wireline_Promotion_Number_Applied__c = aPLine.Wireline_Promotion_Number_Applied__c;
                                
                                pPricingList.add(pPricicng);                                
                            }                            
                        }
                        
                        else if(aPLine.Apttus_Config2__ChargeType__c !=null && aPLine.Apttus_Config2__ChargeType__c.contains(ATT_Constant.COS)){                         
                            if( PORTTYEPMAP.containsKey(aPLine.AT_T_Customer_Site__c) && PORTTYEPMAP.get(aPLine.AT_T_Customer_Site__c) == true){
                                Product_Pricing__c pPricicng = new Product_Pricing__c(); 
                                if(mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_Config2__PriceListItemId__r.Name)!=null){
                                    pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                    pPricicng.BEID__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(PortSpeed+aPLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                }
                                if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE)
                                    pPricicng.type__c = ATT_Constant.MRCTYPE;
                                if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                    pPricicng.type__c = ATT_Constant.NRCTYPE;
                                pPricicng.list_price__c =  (aPLine.Original_Net_Price__c != null && aPLine.Original_Net_Price__c!= 0.00 ? aPLine.Original_Net_Price__c : aPLine.Apttus_Config2__NetPrice__c);
                                pPricicng.discounted_price__c = (aPLine.Net_Price_with_SP_Order_Discounts__c != null && aPLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? aPLine.Net_Price_with_SP_Order_Discounts__c : aPLine.Apttus_Config2__NetPrice__c);
                                pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                pPricicng.SP_Product__c = sprod.id;           
                                pPricicng.Product_Detail__c = aPLine.Apttus_Config2__ChargeType__c;
                                pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (aPLine.WP_Hidden_Discount_Percentage__c !=null ? aPLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                pPricicng.Wireline_Promo_Discount_Map_Site__c = (aPLine.Wireline_Promotion_Discount_Percentage__c !=null ? aPLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (aPLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? aPLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                pPricicng.Wireline_Promo_Discount_SP_Order__c = (aPLine.Wireline_Promo_Discount_SP_Order__c != null  ? aPLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                pPricicng.Net_Price_with_SP_Order_Discounts__c = (aPLine.Net_Price_with_SP_Order_Discounts__c !=null ? aPLine.Net_Price_with_SP_Order_Discounts__c : 0.00);
                               // pPricicng.Net_Price_with_Deal_Reg_Discounts__c = (aPLine.Net_Price_with_Deal_Reg_Discounts__c !=null ? aPLine.Net_Price_with_Deal_Reg_Discounts__c : 0.00);
                                pPricicng.Original_Hidden_Price__c = (aPLine.Original_Hidden_Price__c !=null ? aPLine.Original_Hidden_Price__c : 0.00);
                                pPricicng.Original_Net_Price__c = (aPLine.Original_Net_Price__c !=null ? aPLine.Original_Net_Price__c : 0.00);
                                pPricicng.Wireline_Promotion_Name_Applied__c = aPLine.Wireline_Promotion_Name_Applied__c;
                                pPricicng.Wireline_Promotion_Number_Applied__c = aPLine.Wireline_Promotion_Number_Applied__c;
                                
                                pPricingList.add(pPricicng);
                            }
                        }
                        else if(aPLine.Apttus_Config2__ChargeType__c !=null && aPLine.Apttus_Config2__ChargeType__c.contains(ATT_Constant.PORT_SPEED) && !aPLine.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c){
                            Product_Pricing__c pPricicng = new Product_Pricing__c();
                            if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(aPLine.Port_Speed__c+aPLine.Apttus_Config2__PriceListItemId__r.Name)!=null){
                                
                                pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(aPLine.Port_Speed__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                pPricicng.BEID__c =  mapPriceMatrixEntry.get(aPLine.Port_Speed__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(aPLine.Port_Speed__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                pPricicng.product_name__c = mapPriceMatrixEntry.get(aPLine.Port_Speed__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c; 
                                pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(aPLine.Port_Speed__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                pPricicng.Product_Detail__c = aPLine.Apttus_Config2__ChargeType__c;   
                            }
                            if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE)
                                pPricicng.type__c = ATT_Constant.MRCTYPE;
                            if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                pPricicng.type__c = ATT_Constant.NRCTYPE;
                            pPricicng.list_price__c =  (aPLine.Original_Net_Price__c != null && aPLine.Original_Net_Price__c!= 0.00 ? aPLine.Original_Net_Price__c : aPLine.Apttus_Config2__NetPrice__c);
                            pPricicng.discounted_price__c = (aPLine.Net_Price_with_SP_Order_Discounts__c != null && aPLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? aPLine.Net_Price_with_SP_Order_Discounts__c : aPLine.Apttus_Config2__NetPrice__c);
                            pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                            pPricicng.SP_Product__c = sprod.id;           
                            pPricicng.Product_Detail__c = aPLine.Apttus_Config2__ChargeType__c;
                            pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Port').getRecordTypeId();
                            pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (aPLine.WP_Hidden_Discount_Percentage__c !=null ? aPLine.WP_Hidden_Discount_Percentage__c : 0.00);
                            pPricicng.Wireline_Promo_Discount_Map_Site__c = (aPLine.Wireline_Promotion_Discount_Percentage__c !=null ? aPLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                            pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (aPLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? aPLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                            pPricicng.Wireline_Promo_Discount_SP_Order__c = (aPLine.Wireline_Promo_Discount_SP_Order__c != null  ? aPLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                            pPricicng.Net_Price_with_SP_Order_Discounts__c = (aPLine.Net_Price_with_SP_Order_Discounts__c !=null ? aPLine.Net_Price_with_SP_Order_Discounts__c : 0.00);
                            //pPricicng.Net_Price_with_Deal_Reg_Discounts__c = (aPLine.Net_Price_with_Deal_Reg_Discounts__c !=null ? aPLine.Net_Price_with_Deal_Reg_Discounts__c : 0.00);
                            pPricicng.Original_Hidden_Price__c = (aPLine.Original_Hidden_Price__c !=null ? aPLine.Original_Hidden_Price__c : 0.00);
                            pPricicng.Original_Net_Price__c = (aPLine.Original_Net_Price__c !=null ? aPLine.Original_Net_Price__c : 0.00);
                            pPricicng.Wireline_Promotion_Name_Applied__c = aPLine.Wireline_Promotion_Name_Applied__c;
                            pPricicng.Wireline_Promotion_Number_Applied__c = aPLine.Wireline_Promotion_Number_Applied__c;
                            
                            pPricingList.add(pPricicng);
                        } 
                        else if(aPLine.Apttus_Config2__ChargeType__c !=null && aPLine.Apttus_Config2__ChargeType__c.contains(ATT_Constant.PORT_SPEED) && aPLine.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c){
                            system.debug('@@@Entered If of PORT_SPEED');
                            Product_Pricing__c pPricicng = new Product_Pricing__c();
                            if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(aPLine.MBC_Speed__c+aPLine.Apttus_Config2__PriceListItemId__r.Name)!=null){
                                pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(aPLine.MBC_Speed__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                pPricicng.BEID__c =  mapPriceMatrixEntry.get(aPLine.MBC_Speed__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(aPLine.MBC_Speed__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                pPricicng.product_name__c = mapPriceMatrixEntry.get(aPLine.MBC_Speed__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c; 
                                pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(aPLine.MBC_Speed__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                pPricicng.Product_Detail__c = aPLine.Apttus_Config2__ChargeType__c;   
                            }
                            if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE)
                                pPricicng.type__c = ATT_Constant.MRCTYPE;
                            if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                pPricicng.type__c = ATT_Constant.NRCTYPE;
                            system.debug('@@@aPLine.Original_Net_Price__c' + aPLine.Original_Net_Price__c);
                            pPricicng.list_price__c =  (aPLine.Original_Net_Price__c != null && aPLine.Original_Net_Price__c!= 0.00 ? aPLine.Original_Net_Price__c : aPLine.Apttus_Config2__NetPrice__c);
                            pPricicng.discounted_price__c = (aPLine.Net_Price_with_SP_Order_Discounts__c != null && aPLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? aPLine.Net_Price_with_SP_Order_Discounts__c : aPLine.Apttus_Config2__NetPrice__c);
                            pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                            pPricicng.SP_Product__c = sprod.id;           
                            pPricicng.Product_Detail__c = aPLine.Apttus_Config2__ChargeType__c;
                            pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get(UtilityConstant.PORT).getRecordTypeId();
                            pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (aPLine.WP_Hidden_Discount_Percentage__c !=null ? aPLine.WP_Hidden_Discount_Percentage__c : 0.00);
                            pPricicng.Wireline_Promo_Discount_Map_Site__c = (aPLine.Wireline_Promotion_Discount_Percentage__c !=null ? aPLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                            pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (aPLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? aPLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                            pPricicng.Wireline_Promo_Discount_SP_Order__c = (aPLine.Wireline_Promo_Discount_SP_Order__c != null  ? aPLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                            pPricicng.Net_Price_with_SP_Order_Discounts__c = (aPLine.Net_Price_with_SP_Order_Discounts__c !=null ? aPLine.Net_Price_with_SP_Order_Discounts__c : 0.00);
                            //pPricicng.Net_Price_with_Deal_Reg_Discounts__c = (aPLine.Net_Price_with_Deal_Reg_Discounts__c !=null ? aPLine.Net_Price_with_Deal_Reg_Discounts__c : 0.00);
                            pPricicng.Original_Hidden_Price__c = (aPLine.Original_Hidden_Price__c !=null ? aPLine.Original_Hidden_Price__c : 0.00);
                            pPricicng.Original_Net_Price__c = (aPLine.Original_Net_Price__c !=null ? aPLine.Original_Net_Price__c : 0.00);
                            pPricicng.Wireline_Promotion_Name_Applied__c = aPLine.Wireline_Promotion_Name_Applied__c;
                            pPricicng.Wireline_Promotion_Number_Applied__c = aPLine.Wireline_Promotion_Number_Applied__c;    
                            
                            pPricingList.add(pPricicng);
                            
                        }
                        else if(aPLine.Apttus_Config2__ChargeType__c !=null && aPLine.Apttus_Config2__ChargeType__c==UtilityConstant.ACCESSSPEED_FEE){
                            Product_Pricing__c pPricicng = new Product_Pricing__c();
                            
                            if(!mapPriceMatrixEntryFeatureAccess.isEmpty() && mapPriceMatrixEntryFeatureAccess.get(aPLine.AccessSpeed__c+aPLine.VASARegion__c+aPLine.Apttus_Config2__PriceListItemId__r.Name)!=null) {                                    
                                pPricicng.BEID__c = mapPriceMatrixEntryFeatureAccess.get(aPLine.AccessSpeed__c+aPLine.VASARegion__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                pPricicng.PBI_Number__c = mapPriceMatrixEntryFeatureAccess.get(aPLine.AccessSpeed__c+aPLine.VASARegion__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntryFeatureAccess.get(aPLine.AccessSpeed__c+aPLine.VASARegion__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                pPricicng.product_name__c = mapPriceMatrixEntryFeatureAccess.get(aPLine.AccessSpeed__c+aPLine.VASARegion__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                pPricicng.Low_Level_Tier__c = mapPriceMatrixEntryFeatureAccess.get(aPLine.AccessSpeed__c+aPLine.VASARegion__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                
                            }
                            if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE)
                                pPricicng.type__c = ATT_Constant.MRCTYPE;
                            if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                pPricicng.type__c = ATT_Constant.NRCTYPE;
                            pPricicng.list_price__c = accessTotalFee;
                            pPricicng.discounted_price__c = accessTotalDiscountedPrice;
                            system.debug('@@@inside accessTotalFee:'+accessTotalFee);
                            system.debug('@@@inside accessTotalDiscountedPrice:'+accessTotalDiscountedPrice);
                            pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                            pPricicng.SP_Product__c = sprod.id;
                            pPricicng.Product_Detail__c = aPLine.Apttus_Config2__ChargeType__c;
                            pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Access').getRecordTypeId();
                            pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (aPLine.WP_Hidden_Discount_Percentage__c !=null ? aPLine.WP_Hidden_Discount_Percentage__c : 0.00);
                            pPricicng.Wireline_Promo_Discount_Map_Site__c = (aPLine.Wireline_Promotion_Discount_Percentage__c !=null ? aPLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                            pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (aPLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? aPLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                            pPricicng.Wireline_Promo_Discount_SP_Order__c = (aPLine.Wireline_Promo_Discount_SP_Order__c != null  ? aPLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                            pPricicng.Net_Price_with_SP_Order_Discounts__c = accessTotalNetPriceWithSPOrderDisc;
                            pPricicng.Original_Hidden_Price__c = accessTotalHiddenPrice;
                            pPricicng.Original_Net_Price__c = accessTotalOriginalNetPrice;
                            pPricicng.Wireline_Promotion_Name_Applied__c = aPLine.Wireline_Promotion_Name_Applied__c;
                            pPricicng.Wireline_Promotion_Number_Applied__c = aPLine.Wireline_Promotion_Number_Applied__c;
                            
                            pPricingList.add(pPricicng); 
                        }
                        else{
                            if(aPLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.MACD_Change_Type__c != UtilityConstant.PORTACCESS_SPEED_CHANGE && aPLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.MACD_Change_Type__c != UtilityConstant.UBBADD && aPLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.MACD_Change_Type__c != UtilityConstant.UBBCHANGE && aPLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.MACD_Change_Type__c != UtilityConstant.UBBREMOVE && aPLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.MACD_Change_Type__c != UtilityConstant.ADDSITE && aPLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.MACD_Change_Type__c != UtilityConstant.ADDCOS && aPLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.MACD_Change_Type__c != UtilityConstant.REMOVECOS){
                                if(aPLine.Apttus_Config2__ChargeType__c !=null && !aPLine.Apttus_Config2__ChargeType__c.contains(UtilityConstant.INSTALLATION) && !aPLine.Apttus_Config2__ChargeType__c.contains(UtilityConstant.INTERFACETYPE)){
                                    if(aPLine.Apttus_Config2__ChargeType__c == UtilityConstant.ONETIME_FEE ){
                                        Product_Pricing__c pPricicng = new Product_Pricing__c();                                        
                                        if(mapPriceMatrixEntry.get(aPLine.One_Time_Fee__c+aPLine.Apttus_Config2__PriceListItemId__r.Name)!=null) {    
                                            pPricicng.BEID__c = mapPriceMatrixEntry.get(aPLine.One_Time_Fee__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                            pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(aPLine.One_Time_Fee__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                            pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(aPLine.One_Time_Fee__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                            pPricicng.product_name__c = mapPriceMatrixEntry.get(aPLine.One_Time_Fee__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                            pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(aPLine.One_Time_Fee__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                            pPricicng.Product_Detail__c = aPLine.Apttus_Config2__ChargeType__c; 
                                        }
                                        if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                            pPricicng.Discountable__c=true;
                                        }
                                        pPricicng.list_price__c =  (aPLine.Original_Net_Price__c != null && aPLine.Original_Net_Price__c!= 0.00 ? aPLine.Original_Net_Price__c : aPLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discounted_price__c = (aPLine.Net_Price_with_SP_Order_Discounts__c != null && aPLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? aPLine.Net_Price_with_SP_Order_Discounts__c : aPLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                        pPricicng.SP_Product__c = sprod.id;
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                        pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (aPLine.WP_Hidden_Discount_Percentage__c !=null ? aPLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Map_Site__c = (aPLine.Wireline_Promotion_Discount_Percentage__c !=null ? aPLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (aPLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? aPLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                        pPricicng.Wireline_Promo_Discount_SP_Order__c = (aPLine.Wireline_Promo_Discount_SP_Order__c != null  ? aPLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                        pPricicng.Net_Price_with_SP_Order_Discounts__c = (aPLine.Net_Price_with_SP_Order_Discounts__c !=null ? aPLine.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                       // pPricicng.Net_Price_with_Deal_Reg_Discounts__c = (aPLine.Net_Price_with_Deal_Reg_Discounts__c !=null ? aPLine.Net_Price_with_Deal_Reg_Discounts__c : 0.00);
                                        pPricicng.Original_Hidden_Price__c = (aPLine.Original_Hidden_Price__c !=null ? aPLine.Original_Hidden_Price__c : 0.00);
                                        pPricicng.Original_Net_Price__c = (aPLine.Original_Net_Price__c !=null ? aPLine.Original_Net_Price__c : 0.00);
                                        pPricicng.Wireline_Promotion_Name_Applied__c = aPLine.Wireline_Promotion_Name_Applied__c;
                                        pPricicng.Wireline_Promotion_Number_Applied__c = aPLine.Wireline_Promotion_Number_Applied__c;
                                        
                                        pPricingList.add(pPricicng);
                                    }
                                    
                                    //IP Flex PP records creation
                                    if(aPLine.Apttus_Config2__ChargeType__c !=null && aPLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.IP_FLEX_REACH_PLAN) ){
                                        Product_Pricing__c pPricicng = new Product_Pricing__c();
                                        
                                        if(mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name)!=null) {    
                                            pPricicng.BEID__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                            pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                            pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                            pPricicng.product_name__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                            pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                            pPricicng.Product_Detail__c = aPLine.Apttus_Config2__ChargeType__c; 
                                        }
                                        
                                        if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                            pPricicng.Discountable__c=true;
                                        }
                                        pPricicng.list_price__c = (aPLine.Original_Net_Price__c != null && aPLine.Original_Net_Price__c!= 0.00 ? aPLine.Original_Net_Price__c : aPLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discounted_price__c = (aPLine.Net_Price_with_SP_Order_Discounts__c != null && aPLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? aPLine.Net_Price_with_SP_Order_Discounts__c : aPLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                        pPricicng.SP_Product__c = sprod.id;
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                        pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (aPLine.WP_Hidden_Discount_Percentage__c !=null ? aPLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Map_Site__c = (aPLine.Wireline_Promotion_Discount_Percentage__c !=null ? aPLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (aPLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? aPLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                        pPricicng.Wireline_Promo_Discount_SP_Order__c = (aPLine.Wireline_Promo_Discount_SP_Order__c != null  ? aPLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                        pPricicng.Net_Price_with_SP_Order_Discounts__c = (aPLine.Net_Price_with_SP_Order_Discounts__c !=null ? aPLine.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                       // pPricicng.Net_Price_with_Deal_Reg_Discounts__c = (aPLine.Net_Price_with_Deal_Reg_Discounts__c !=null ? aPLine.Net_Price_with_Deal_Reg_Discounts__c : 0.00);
                                        pPricicng.Original_Hidden_Price__c = (aPLine.Original_Hidden_Price__c !=null ? aPLine.Original_Hidden_Price__c : 0.00);
                                        pPricicng.Original_Net_Price__c = (aPLine.Original_Net_Price__c !=null ? aPLine.Original_Net_Price__c : 0.00);
                                        pPricicng.Wireline_Promotion_Name_Applied__c = aPLine.Wireline_Promotion_Name_Applied__c;
                                        pPricicng.Wireline_Promotion_Number_Applied__c = aPLine.Wireline_Promotion_Number_Applied__c;
                                        
                                        pPricingList.add(pPricicng);
                                    }
                                    
                                    if(aPLine.Apttus_Config2__ChargeType__c !=null && aPLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.VTN_FEE) ){
                                        Product_Pricing__c pPricicng = new Product_Pricing__c();
                                        if(mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name)!=null) {
                                            pPricicng.BEID__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                            pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                            pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                            pPricicng.product_name__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                            pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                            pPricicng.Product_Detail__c = aPLine.Apttus_Config2__ChargeType__c; 
                                        }
                                        
                                        if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                            pPricicng.Discountable__c=true;
                                        }
                                        pPricicng.list_price__c =  (aPLine.Original_Net_Price__c != null && aPLine.Original_Net_Price__c!= 0.00 ? aPLine.Original_Net_Price__c : aPLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discounted_price__c = (aPLine.Net_Price_with_SP_Order_Discounts__c != null && aPLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? aPLine.Net_Price_with_SP_Order_Discounts__c : aPLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                        pPricicng.SP_Product__c = sprod.id;
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                        pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (aPLine.WP_Hidden_Discount_Percentage__c !=null ? aPLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Map_Site__c = (aPLine.Wireline_Promotion_Discount_Percentage__c !=null ? aPLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (aPLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? aPLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                        pPricicng.Wireline_Promo_Discount_SP_Order__c = (aPLine.Wireline_Promo_Discount_SP_Order__c != null  ? aPLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                        pPricicng.Net_Price_with_SP_Order_Discounts__c = (aPLine.Net_Price_with_SP_Order_Discounts__c !=null ? aPLine.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                        //pPricicng.Net_Price_with_Deal_Reg_Discounts__c = (aPLine.Net_Price_with_Deal_Reg_Discounts__c !=null ? aPLine.Net_Price_with_Deal_Reg_Discounts__c : 0.00);
                                        pPricicng.Original_Hidden_Price__c = (aPLine.Original_Hidden_Price__c !=null ? aPLine.Original_Hidden_Price__c : 0.00);
                                        pPricicng.Original_Net_Price__c = (aPLine.Original_Net_Price__c !=null ? aPLine.Original_Net_Price__c : 0.00);
                                        pPricicng.Wireline_Promotion_Name_Applied__c = aPLine.Wireline_Promotion_Name_Applied__c;
                                        pPricicng.Wireline_Promotion_Number_Applied__c = aPLine.Wireline_Promotion_Number_Applied__c;
                                        
                                        pPricingList.add(pPricicng);
                                    }
                                    
                                    if(aPLine.Apttus_Config2__ChargeType__c !=null && aPLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.ENHANCED_FEATURES) ){
                                        Product_Pricing__c pPricicng = new Product_Pricing__c();
                                        if(mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name)!=null) {    
                                            pPricicng.BEID__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                            pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                            pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                            pPricicng.product_name__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                            pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                            pPricicng.Product_Detail__c = aPLine.Apttus_Config2__ChargeType__c; 
                                        }
                                        
                                        if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                            pPricicng.Discountable__c=true;
                                        }
                                        pPricicng.list_price__c =   (aPLine.Original_Net_Price__c != null && aPLine.Original_Net_Price__c!= 0.00 ? aPLine.Original_Net_Price__c : aPLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discounted_price__c = (aPLine.Net_Price_with_SP_Order_Discounts__c != null && aPLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? aPLine.Net_Price_with_SP_Order_Discounts__c : aPLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                        pPricicng.SP_Product__c = sprod.id;
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                        pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (aPLine.WP_Hidden_Discount_Percentage__c !=null ? aPLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Map_Site__c = (aPLine.Wireline_Promotion_Discount_Percentage__c !=null ? aPLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (aPLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? aPLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                        pPricicng.Wireline_Promo_Discount_SP_Order__c = (aPLine.Wireline_Promo_Discount_SP_Order__c != null  ? aPLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                        pPricicng.Net_Price_with_SP_Order_Discounts__c = (aPLine.Net_Price_with_SP_Order_Discounts__c !=null ? aPLine.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                        //pPricicng.Net_Price_with_Deal_Reg_Discounts__c = (aPLine.Net_Price_with_Deal_Reg_Discounts__c !=null ? aPLine.Net_Price_with_Deal_Reg_Discounts__c : 0.00);
                                        pPricicng.Original_Hidden_Price__c = (aPLine.Original_Hidden_Price__c !=null ? aPLine.Original_Hidden_Price__c : 0.00);
                                        pPricicng.Original_Net_Price__c = (aPLine.Original_Net_Price__c !=null ? aPLine.Original_Net_Price__c : 0.00);
                                        pPricicng.Wireline_Promotion_Name_Applied__c = aPLine.Wireline_Promotion_Name_Applied__c;
                                        pPricicng.Wireline_Promotion_Number_Applied__c = aPLine.Wireline_Promotion_Number_Applied__c;
                                        
                                        pPricingList.add(pPricicng);
                                    }
                                    
                                    if(aPLine.Apttus_Config2__ChargeType__c !=null && aPLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.SETUP_FEE) ){
                                        Product_Pricing__c pPricicng = new Product_Pricing__c();
                                        if(mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name)!=null) {    
                                            pPricicng.BEID__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                            pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                            pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                            pPricicng.product_name__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                            pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(aPLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                            pPricicng.Product_Detail__c = aPLine.Apttus_Config2__ChargeType__c; 
                                        }
                                        
                                        if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                            pPricicng.Discountable__c=true;
                                        }
                                        pPricicng.list_price__c =  (aPLine.Original_Net_Price__c != null && aPLine.Original_Net_Price__c!= 0.00 ? aPLine.Original_Net_Price__c : aPLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discounted_price__c = (aPLine.Net_Price_with_SP_Order_Discounts__c != null && aPLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? aPLine.Net_Price_with_SP_Order_Discounts__c : aPLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                        pPricicng.SP_Product__c = sprod.id;
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                        pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (aPLine.WP_Hidden_Discount_Percentage__c !=null ? aPLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Map_Site__c = (aPLine.Wireline_Promotion_Discount_Percentage__c !=null ? aPLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (aPLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? aPLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                        pPricicng.Wireline_Promo_Discount_SP_Order__c = (aPLine.Wireline_Promo_Discount_SP_Order__c != null  ? aPLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                        pPricicng.Net_Price_with_SP_Order_Discounts__c = (aPLine.Net_Price_with_SP_Order_Discounts__c !=null ? aPLine.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                        //pPricicng.Net_Price_with_Deal_Reg_Discounts__c = (aPLine.Net_Price_with_Deal_Reg_Discounts__c !=null ? aPLine.Net_Price_with_Deal_Reg_Discounts__c : 0.00);
                                        pPricicng.Original_Hidden_Price__c = (aPLine.Original_Hidden_Price__c !=null ? aPLine.Original_Hidden_Price__c : 0.00);
                                        pPricicng.Original_Net_Price__c = (aPLine.Original_Net_Price__c !=null ? aPLine.Original_Net_Price__c : 0.00);
                                        pPricicng.Wireline_Promotion_Name_Applied__c = aPLine.Wireline_Promotion_Name_Applied__c;
                                        pPricicng.Wireline_Promotion_Number_Applied__c = aPLine.Wireline_Promotion_Number_Applied__c;
                                        
                                        pPricingList.add(pPricicng);
                                    }
                                    
                                    if(aPLine.Apttus_Config2__ChargeType__c !=null && aPLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.VOIP) ){
                                        Product_Pricing__c pPricicng = new Product_Pricing__c();
                                        if(mapPriceMatrixEntry.get(aPLine.VOIP__c+aPLine.Apttus_Config2__PriceListItemId__r.Name)!=null) {    
                                            pPricicng.BEID__c = mapPriceMatrixEntry.get(aPLine.VOIP__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                            pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(aPLine.VOIP__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                            pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(aPLine.VOIP__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                            pPricicng.product_name__c = mapPriceMatrixEntry.get(aPLine.VOIP__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                            pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(aPLine.VOIP__c+aPLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                            pPricicng.Product_Detail__c = aPLine.Apttus_Config2__ChargeType__c; 
                                        }
                                        
                                        if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(aPLine.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                            pPricicng.Discountable__c=true;
                                        }
                                        pPricicng.list_price__c =   (aPLine.Original_Net_Price__c != null && aPLine.Original_Net_Price__c!= 0.00 ? aPLine.Original_Net_Price__c : aPLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discounted_price__c = (aPLine.Net_Price_with_SP_Order_Discounts__c != null && aPLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? aPLine.Net_Price_with_SP_Order_Discounts__c : aPLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                        pPricicng.SP_Product__c = sprod.id;
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                        pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (aPLine.WP_Hidden_Discount_Percentage__c !=null ? aPLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Map_Site__c = (aPLine.Wireline_Promotion_Discount_Percentage__c !=null ? aPLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (aPLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? aPLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                        pPricicng.Wireline_Promo_Discount_SP_Order__c = (aPLine.Wireline_Promo_Discount_SP_Order__c != null  ? aPLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                        pPricicng.Net_Price_with_SP_Order_Discounts__c = (aPLine.Net_Price_with_SP_Order_Discounts__c !=null ? aPLine.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                       // pPricicng.Net_Price_with_Deal_Reg_Discounts__c = (aPLine.Net_Price_with_Deal_Reg_Discounts__c !=null ? aPLine.Net_Price_with_Deal_Reg_Discounts__c : 0.00);
                                        pPricicng.Original_Hidden_Price__c = (aPLine.Original_Hidden_Price__c !=null ? aPLine.Original_Hidden_Price__c : 0.00);
                                        pPricicng.Original_Net_Price__c = (aPLine.Original_Net_Price__c !=null ? aPLine.Original_Net_Price__c : 0.00);                              
                                        pPricicng.Wireline_Promotion_Name_Applied__c = aPLine.Wireline_Promotion_Name_Applied__c;
                                        pPricicng.Wireline_Promotion_Number_Applied__c = aPLine.Wireline_Promotion_Number_Applied__c;
                                        pPricingList.add(pPricicng);
                                    }
                                }
                            }
                        }
                    }
                }
            } 
            else if(sprod.Product_Name__c == ATT_Constant.ATTMIS){
                if(!MISCOUPNew.executeOnce){
                    MISCOUPNew.createSPProductsForQuotes(qList, spProductList, cJunSiteList, proposalLineItem, prodMapList,priceMatrixList);
                    if(MISCOUPNew.executeOnce == true)
                        IsUpdateOpportunity=true;
                }
            }    
            else if(sprod.Product_Name__c == UtilityConstant.ATT_INTERNET_ACCESS){
                if(!AIACOUP.executeAIAOnce){
                    if(AIACOUP.executeAIAOnce == true)
                        IsUpdateOpportunity=true;
                }
            }  
            
            Site__c s = new Site__c();
            s.Address__c = sprod.Mailing_Street_Address__c;
            s.State__c = sprod.State__c;
            s.City__c = sprod.City__c;                          
            s.Line__c = sprod.Mailing_Street_Address__c;
            s.Zip__c = String.valueOf(sprod.Zip__c);
            s.SPProduct__c = sprod.id; 
            s.Site_Friendly_Name__c = sprod.Site_Friendly_Name__c;             
            siteList.add(s);
        } 
        
        insert siteList;
        insert pPricingList;
        
        if(pPricingList.size() != 0){
            IsUpdateOpportunity=true;   
        }
        for(Apttus_Proposal__Proposal__c acp :[Select a.Id,DUNS_Number__c,MACD_Change_Type__c,Apttus_Proposal__Account__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Approval_Stage__c,Apttus_Proposal__Proposal_Expiration_Date__c, End_Customer__r.Name,IsBIDMigrationCompleted__c, Owner.Name, Name, Apttus_Proposal__ExpectedEndDate__c,Product__r.name, (select Apttus_Proposal__Proposal__c,Apttus_Proposal__Product__r.name,
                                                                                                                                                                                                                                                                                                                                                                    Apttus_QPConfig__NetPrice__c,Apttus_QPConfig__AdjustedPrice__c,Apttus_QPConfig__OptionId__r.Description,Apttus_Proposal__Quantity__c,AT_T_Customer_Site__c,Apttus_QPConfig__ListPrice__c,AT_T_Customer_Site__r.State__c,AT_T_Customer_Site__r.Address_Line__c,AT_T_Customer_Site__r.City__c,AT_T_Customer_Site__r.Zip_Code__c   From Apttus_Proposal__R00N70000001yUfBEAU__r) From Apttus_Proposal__Proposal__c a where Id IN : qList]){
                                                                                                                                                                                                                                                                                                                                                                        quoteLst.add(acp);
                                                                                                                                                                                                                                                                                                                                                                    } 
        
        if(IsUpdateOpportunity){
            helper.updateOpportunityForQuotes(quoteLst);
        }
        isSuccess = true;      
    }
    
    
    /*Batch finish method to perform business logic after batch completion*/
    global void finish(Database.BatchableContext BC){
       list<Admin_Control__c> adminControlList = [Select id, Lockin_days__c, MACD_Price_Lock_in_days__c, Pricing_Schedule_Expiry_Days__c from Admin_Control__c LIMIT 1];
        Opportunity opp = new Opportunity(id=opptyId);
        opp.Lockin_Days__c = adminControlList.get(0).Lockin_days__c;
        opp.isDealSubmitCompleted__c = true;
        if(!Test.isRunningTest()){
            updateInRegionDiscount(opptyId);
            updateIPFlexDealFlag(opptyId);
            updateLOARequiredFlag(opptyId);
        }
        update opp;      
        
        List<Promotion_Engine_Junction__c> promotionsList = new List<Promotion_Engine_Junction__c>();
        promotionsList=[Select id,Rank__c,Discount_Percentage__c,Opportunity__c from Promotion_Engine_Junction__c where Opportunity__c=:opptyId];
        decimal listPrice=0.0; 
        
        //Code added to finalize cart in Batch for Non-MACD deals
        Opportunity clonedOppty = [select id,IsReconfigureDeal__c,Renewal_Contract__c,MACD_Type__c,ATOM_Deal__c,stagename,RecordType.Name,Cumulative_List_Price__c,Discounted_Price__c,Discount_Percentage__c, IsMigratedDeal__c from Opportunity where id= :opptyId];
        if(clonedOppty != null && (clonedOppty.MACD_Type__c == null || clonedOppty.MACD_Type__c == '')){
            List<Apttus_Proposal__Proposal__c> proposalList = [select id,IsBIDMigrationCompleted__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Proposal_Name__c,(Select Id From Apttus_QPConfig__Configurations__r WHERE Apttus_Config2__Status__c =:ATTConstants.SAVED ) from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c = :clonedOppty.id];       
            if(proposalList.size()>0){
                if(proposalList[0].Apttus_QPConfig__Configurations__r!= null && proposalList[0].Apttus_QPConfig__Configurations__r.size()>0){
                    helper.finalizeCart(proposalList[0].Apttus_QPConfig__Configurations__r[0].Id);
                }
            }
        }
        
        //MACD Discount and Contract Renewal Logic
        if(clonedOppty !=null && (((clonedOppty.MACD_Type__c == UtilityConstant.A || clonedOppty.MACD_Type__c == UtilityConstant.C) && clonedOppty.RecordType.Name ==UtilityConstant.MACD) || clonedOppty.Renewal_Contract__c == true)) {
            Apttus_Proposal__Proposal__c  proposalList = [select id,Renewal_Contract__c,Apttus_Proposal__Approval_Stage__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Proposal_Name__c,MasterOpportunity__c from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c = :opptyId LIMIT 1];               
            if(proposalList !=null){                 
                system.debug('@@@MACD Discount logic');
                Id masterOpptyId = proposalList.MasterOpportunity__c;
                Id macdOpptyId = proposalList.Apttus_Proposal__Opportunity__c;
                MACD_DiscountPricingHelper promoHelper = new MACD_DiscountPricingHelper();
                promoHelper.clonePromosAndUpdateOppty(masterOpptyId,macdOpptyId);
                if(IsMACDSpecialPricing){       
                    updateSpecialPricingStatusOnSpProductsForAddSites(opptyId);
                }
                //Contract Renewal Stage Update
                if(proposalList.Renewal_Contract__c == true){
                    helper.clearContractRenewalStage(proposalList.Id);
                    noIglooMatchNotification(opp.id);                    
                }
            }
        }
        
        //Auto deal approval logic for New Starts
        if ((clonedOppty!=null && ( clonedOppty.IsReconfigureDeal__c || clonedOppty.stagename==SIConstants.OPTY_DEAL_Auto_Approved || clonedOppty.stagename==UtilityConstant.DEALREGISTRATION_APPROVED) && clonedOppty.ATOM_Deal__c==TRUE && clonedOppty.RecordType.Name ==UtilityConstant.DEALREG_REQUESTED && clonedOppty.Renewal_Contract__c == false)){    
            Apttus_Proposal__Proposal__c proposalList = [select id,Renewal_Contract__c,Apttus_Proposal__Approval_Stage__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Proposal_Name__c,MasterOpportunity__c from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c = :opptyId];               
            if(promotionsList.size()>0){   
                decimal discountedlistPrice = 0.0;
                listPrice = clonedOppty.Cumulative_List_Price__c;
                MACD_DiscountPricingHelper promoHelper = new MACD_DiscountPricingHelper();
                discountedlistPrice = promoHelper.applyPromotions(listPrice,promotionsList);
                doPostDiscountUpdates(opptyId,'NA');             
            }
            
            clonedOppty.IsReconfigureDeal__c = false;
            clonedOppty.StageName = ATTConstants.OPPTY_DEAL_REG_AUTO_APPROVED;    
            upsert clonedOppty;
            
            if(clonedOppty.StageName == ATTConstants.OPPTY_DEAL_REG_AUTO_APPROVED ){
                proposalList.Apttus_Proposal__Approval_Stage__c = ATTConstants.QUOTE_DEAL_REG_APPROVED;  
            }
            else if(clonedOppty.StageName.equals(BuyflowConstant.DEALREGISTRATION_DENIED) ){
                proposalList.Apttus_Proposal__Approval_Stage__c = BuyflowConstant.DEALREG_DENIED;  
            }
            else{
                proposalList.Apttus_Proposal__Approval_Stage__c = ATTConstants.QUOTE_PENDING_DEAL_REG;  
            }
            //proposalList.StopApprovalEmailOnDiscard__c = false; 
            update proposalList;
        }        
        
        //Discount logic for UBB/CoS/Add Site
        Apttus_Proposal__Proposal__c currentQuoteObj=[select id,MACD_Change_Type__c, MasterOpportunity__c, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Opportunity__r.Cumulative_List_Price__c,Apttus_Proposal__Opportunity__r.Calculated_Discount_Percentage__c from Apttus_Proposal__Proposal__c where id =:quoteId  limit 1];
        if(currentQuoteObj.MACD_Change_Type__c!=null && (currentQuoteObj.MACD_Change_Type__c.contains('UBB')||  currentQuoteObj.MACD_Change_Type__c.contains('CoS'))){
            updateDiscountOnOpptyForUBB(opptyId,currentQuoteObj);
        }
        else if(currentQuoteObj.MACD_Change_Type__c!=null && currentQuoteObj.MACD_Change_Type__c.contains('AddSite')){        
            doPostDiscountUpdates(opptyId,'AddSite');
        }
        
        //Deal Reg discount logic for New Start flow - Wireline Promotion Logic
        if(quoteId != null && clonedOppty != null && clonedOppty.Renewal_Contract__c == false && (clonedOppty.MACD_Type__c == null || clonedOppty.MACD_Type__c == '')){
            calculateDealRegPromotions(opptyId, quoteId);
        }
        
        //Update Quote State to Success
        Apttus_Proposal__Proposal__c ipq = [select id,Renewal_Contract__c,Apttus_Proposal__Approval_Stage__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Proposal_Name__c,MasterOpportunity__c,IPQ_Quote__c,Quote_State__c from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c = :opptyId];
        ipq.Quote_State__c = 'Success';
        update ipq;
        opp.Quote_State__c = 'Success';
        update opp;
    }
    
    /*Discount calculation for MACD UBB and MACD CoS */
    public void updateDiscountOnOpptyForUBB(id oppty,Apttus_Proposal__Proposal__c currentQuoteObj){
        List<Opportunity> OpptyList = [Select Id,discount_amount__c,RDS_Deal_Hash__c,RDS_Deal_Hash__r.Opportunity__r.Name,Credit_Check_Status__c,Cumulative_List_Price__c,Cumulative_OTC_Price__c,Discounted_Price__c,Cumulative_OTC_Discount_Price__c,StageName,Standard_Discount_Percentage__c,Custom_Deal_Reg_Percentage__c from Opportunity where ID =:oppty];
        for(Opportunity OP : OpptyList){                 
            Decimal disAmt=(SIHelper.applyRound(((currentQuoteObj.Apttus_Proposal__Opportunity__r.Cumulative_List_Price__c*currentQuoteObj.Apttus_Proposal__Opportunity__r.Calculated_Discount_Percentage__c)/100)));
            op.Discounted_Price__c=currentQuoteObj.Apttus_Proposal__Opportunity__r.Cumulative_List_Price__c-disAmt;      
        }
        if(OpptyList != null && OpptyList.size() > 0){
            update OpptyList;
        }
    }
    
    /*Do post discount updates for MACD Add Site*/
    public void doPostDiscountUpdates(id oppty,String macdType){    
        try{
            List<Opportunity> opptyList = [Select Id,discount_amount__c,RDS_Deal_Hash__c,RDS_Deal_Hash__r.Opportunity__r.Name,Credit_Check_Status__c,Cumulative_List_Price__c,Cumulative_OTC_Price__c,Discounted_Price__c,Cumulative_OTC_Discount_Price__c,StageName,Standard_Discount_Percentage__c,Custom_Deal_Reg_Percentage__c from Opportunity where ID =:oppty];
            if(OpptyList != null && OpptyList.size() > 0){
                SIHelper.genericPromotionEnginelogic(OpptyList);
                AggregateResult[] groupedResults = [SELECT Deal__c, SUM(List_Price__c) ListPrice, SUM(one_time_revenue__c) OTCPrice, SUM(One_Time_Revenue_Discount_Price__c) OTCDiscountPrice, SUM(Discounted_Price__c) DiscountedPrice FROM SPProduct__c sp WHERE sp.Deal__c =: OpptyList GROUP BY sp.Deal__c];
                for(Opportunity op : OpptyList){
                    for(AggregateResult agr: groupedResults){
                        if(agr.get('Deal__c')== op.Id){
                            op.Cumulative_List_Price__c = (Decimal)agr.get('ListPrice');
                            decimal spDiscountPercent;
                            decimal dealRegDiscountPercent;
                            Decimal spDiscount = 0.0;
                            decimal dealRegDiscount = 0.0;
                            decimal totalDiscount=0.00;
                            Apttus_Proposal__Proposal__c  proposalList = [select id,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Proposal_Name__c,MasterOpportunity__c   from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c = :opptyId];               
                            MACD_DiscountPricingHelper discountHelper = new MACD_DiscountPricingHelper(); 
                            list<Promotion_Engine_Junction__c> promotions;
                            if(macdType.equals('AddSite')){
                                promotions = discountHelper.getMasterDealPromotions(proposalList);
                            }
                            else{
                                promotions = discountHelper.getDealPromotions(proposalList);
                            }
                            
                            if(promotions != null && promotions.size() > 0){
                                spDiscountPercent = discountHelper.getSpDiscPercentage(promotions);
                                dealRegDiscountPercent = discountHelper.getDealRegDiscPercentage(promotions);
                            }                            
                            
                            if(spDiscountPercent != 0.0){
                                spDiscount = discountHelper.applyDiscount(OP.Cumulative_List_Price__c, spDiscountPercent);
                            }
                            decimal amountAfterSpDiscount = OP.Cumulative_List_Price__c- spDiscount;
                            if(dealRegDiscountPercent != 0.0){
                                dealRegDiscount = discountHelper.applyDiscount(amountAfterSpDiscount, dealRegDiscountPercent);
                            }
                            
                            dealRegDiscount = SIHelper.applyRound(dealRegDiscount);
                            totalDiscount=dealRegDiscount+spDiscount;
                            
                            op.StageName = SIConstants.OPTY_DEAL_Auto_Approved;                                                          
                            op.discount_amount__c=totalDiscount;
                            op.Discounted_Price__c= op.Cumulative_List_Price__c- op.discount_amount__c;
                            OP.Cumulative_OTC_Discount_Price__c =(Decimal)agr.get('OTCPrice');
                            OP.Cumulative_OTC_Price__c =(Decimal)agr.get('OTCDiscountPrice');
                        }
                    }
                }
            }
            if(OpptyList != null && OpptyList.size() > 0){
                update OpptyList;
            }
        }catch(exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));         
        }   
    }
    
    /*Update Special Pricing Status On SP Products For Add Sites*/
    public void updateSpecialPricingStatusOnSpProductsForAddSites(id optyId){
        try{
            list<SPProduct__c> spproducts = [Select Id,Competitive_Pricing_Status__c from SPProduct__c where Deal__c=:optyId];            
            if(spproducts != null && !spproducts.isempty()){
                for(integer i = 0; i < spproducts.size(); i++){
                    spproducts[i].Competitive_Pricing_Status__c = ATT_Constant.SPECIAL_PRICING_REQUESTED;  
                }
                update spproducts;
            }
        }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));        
        }
    }
    
    /*Method for In Region Calculation*/
    public void updateInRegionDiscount(id optyId){
        try{    
            set<Id> optyIds = new set<Id>();
            map<Id,Decimal> regionMap=new map<Id,Decimal>();
            map<Id,Decimal> optySPPCount = new map<Id,Decimal>();
            list<Opportunity> updateOpty = new list<Opportunity>();
            list<Opportunity> optyList = new list<Opportunity>();
            
            if(optyIds!=null){
                optyList = [select Id, In_Region__c,StageName from Opportunity where Id = :optyId];
                AggregateResult[] groupedResSPProductCount = [select count(Id) countsp, Deal__c deal from SPProduct__c where Deal__c = :optyId  group by deal__c];
                AggregateResult[] groupedResSPProductIRCount = [select count(Id) countIR, Deal__c deal from SPProduct__c where Deal__c = :optyId and Region__c='IR'  group by deal__c];
                
                if(groupedResSPProductCount != null){
                    for(AggregateResult agrIRCount: groupedResSPProductIRCount){
                        if(agrIRCount.get('countIR') != null){
                            regionMap.put((Id)agrIRCount.get('deal'),(Decimal)agrIRCount.get('countIR') );
                        }
                    }
                    for(AggregateResult agrSPPCount: groupedResSPProductCount){
                        if(agrSPPCount.get('countsp') != null){
                            optySPPCount.put((Id)agrSPPCount.get('deal'),(Decimal)agrSPPCount.get('countsp'));
                        }
                    }
                    
                    for(Opportunity op: optyList){
                        if(optySPPCount.get(op.Id)!=0 && optySPPCount.get(op.Id) != null){
                            if(regionMap.get(op.Id)==null || regionMap.get(op.Id) == 0){                            
                                op.In_Region__c = ((0/optySPPCount.get(op.Id))*100);
                                updateOpty.add(op);
                            }
                            else{
                                op.In_Region__c = ((regionMap.get(op.Id)/optySPPCount.get(op.Id))*100);
                                updateOpty.add(op);
                            }
                        }
                    }
                    if(updateOpty.size() > 0){
                        update updateOpty;
                    }
                }
            }   
        }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));        
        }
    }
    
    /*Method to update IPFlex Deal flag if IPFlex Product is added to the deal*/
    public void updateIPFlexDealFlag(id optyId){
        try{            
            set<Id> optyIds = new set<Id>();
            map<Id,Decimal> optySPPCount = new map<Id,Decimal>();
            list<Opportunity> updateOpty = new list<Opportunity>();
            list<Opportunity> optyList = new list<Opportunity>();
            string ipdealVal=SpecialCharacterConstant.CONCAT;
            boolean misDeal =false;
            
            if(optyIds!=null){
                optyList = [select Id,MISPlus__c,IPFlex_Deal__c from Opportunity where Id = :optyId];
                List<Apttus_Config2__LineItem__c> listItemListWithIP=[Select id,Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c,Apttus_Config2__AttributeValueId__r.Managed_Router__c from Apttus_Config2__LineItem__c where    Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c=:quoteId and  Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c=true and Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c='Finalized'];
                
                List<Apttus_Config2__LineItem__c> listItemListWithMR=[Select id,Apttus_Config2__AttributeValueId__r.Managed_Router__c,Apttus_Config2__AttributeValueId__r.AT_T_IP_Flexible_Reach__c,Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c from Apttus_Config2__LineItem__c where    Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c=: quoteId and Apttus_Config2__AttributeValueId__r.Managed_Router__c=true  and Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c='Finalized'];
                if(listItemListWithIP.size()>0 && listItemListWithIP!=null){
                    ipdealVal='true';
                }else{
                    ipdealVal=SpecialCharacterConstant.FALSE_LITERAL;
                }
                if(listItemListWithMR.size()>0 && listItemListWithMR!=null){
                    misDeal=true;   
                }else{
                    misDeal=false;  
                }            
                for(Opportunity op: optyList){            
                    op.IPFlex_Deal__c =ipdealVal;
                    op.MISPlus__c =misDeal;
                    updateOpty.add(op);          
                }
            }
            if(updateOpty.size() > 0){
                update updateOpty;
            }          
        }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));        
        }   
    }          
    
    /*Method to update LOA Required flag if Ported Phone Number is greater than 1 for any of the SP Products*/   
    public void updateLOARequiredFlag(id optyId){  
        try{ 
            set<Id> optyIds = new set<Id>();
            map<Id,Decimal> optySPPCount = new map<Id,Decimal>();        
            list<Opportunity> updateOpty = new list<Opportunity>();
            list<Opportunity> optyList = new list<Opportunity>();
            
            if(optyIds!=null){
                optyList = [select Id, LOA_Required__c from Opportunity where Id = :optyId];
                AggregateResult[] loaRequiredCount = [select count(Id) loaCount, Deal__c deal from SPProduct__c where Deal__c = :optyId and Ported_Phone_Numbers__c != null and Ported_Phone_Numbers__c > 0 group by deal__c];
                if(loaRequiredCount != null){
                    for(AggregateResult aggLoaCount : loaRequiredCount){
                        if(aggLoaCount.get('loaCount') != null){
                            optySPPCount.put((Id)aggLoaCount.get('deal'),(Decimal)aggLoaCount.get('loaCount'));
                        }
                    }
                    for(Opportunity op: optyList){
                        if(optySPPCount.get(op.Id)!=0 && optySPPCount.get(op.Id) > 0){
                            op.LOA_Required__c = SpecialCharacterConstant.TRUE_CAMEL_LITERAL;                        
                        }
                        else{
                            op.LOA_Required__c = SpecialCharacterConstant.FALSE_CAMEL_LITERAL;
                        }                    
                        updateOpty.add(op);
                    }
                    if(updateOpty.size() > 0){                
                        update updateOpty;
                    }                
                }            
            }   
        }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));        
        }
    }
    
    /*Method to send IGLOO failure notification*/
    public void noIglooMatchNotification(Id opptyId){    
        List<SPProduct__c> spList = new List<SPProduct__c>();        
        spList = [SELECT id,Name,Site_Address__c ,ContractRenewal_IglooError__c,Deal__r.BID_ID__c,Deal__r.Account.Name,Deal__r.End_Customer_Name__c from SPProduct__c where Deal__c =: opptyId];
        String iglooErrorSites = '';
        
        for(SPProduct__c sp : spList){
            if(sp.ContractRenewal_IglooError__c == true){
                iglooErrorSites = iglooErrorSites+'<br/>'+sp.Name + ' : '+ sp.Site_Address__c;                   
            } 
        }       
        system.debug('@@@final - iglooErrorSites: '+iglooErrorSites);
        
        iglooErrorSites = iglooErrorSites .removeEnd(',');
        if(!String.isBlank(iglooErrorSites)){
            list<OrgWideEmailAddress> owea = new list<OrgWideEmailAddress>();
            owea = [select Id,DisplayName,Address  from OrgWideEmailAddress where Address='partnerexchangesupport@amcustomercare.att-mail.com' Limit 1];
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{Label.No_Igloo_Match_Email};
                mail.setToAddresses(toAddresses);
            mail.saveAsActivity = false;
            
            EmailTemplate temp = new EmailTemplate();
            temp=[Select id,HtmlValue,Body from EmailTemplate WHERE Name = 'No Igloo Match Notification'];
            
            if(owea != null && owea.size() > 0){
                mail.setOrgWideEmailAddressId(owea[0].Id);
            } 
            String  htmlBody, plainBody;
            
            htmlBody = temp.HtmlValue;
            plainBody = temp.Body;
            htmlBody = htmlBody.replace('{!Opportunity.BID_ID__c}', spList[0].Deal__r.BID_ID__c);
            plainBody = plainBody.replace('{!Opportunity.BID_ID__c}', spList[0].Deal__r.BID_ID__c);
            htmlBody = htmlBody.replace('{!Opportunity.Account}', spList[0].Deal__r.Account.Name);
            plainBody = plainBody.replace('{!Opportunity.Account}', spList[0].Deal__r.Account.Name);
            htmlBody = htmlBody.replace('{!Opportunity.End_Customer_Name__c}', spList[0].Deal__r.End_Customer_Name__c);
            plainBody = plainBody.replace('{!Opportunity.End_Customer_Name__c}', spList[0].Deal__r.End_Customer_Name__c);
            htmlBody = htmlBody.replace('{!}', iglooErrorSites);
            plainBody = plainBody.replace('{!}', iglooErrorSites);
            
            mail.setHtmlBody(htmlBody);
            mail.setPlainTextBody(plainBody);
            mail.setSubject('Renewal pricing request - No Igloo match');
            mail.setSaveAsActivity(false); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail },false);    
        }
    }
    
    /*Method to calculate Deal Reg Wireline Promotions for New Start Flow*/
    public void calculateDealRegPromotions(Id opptyId, Id quoteId){
        system.debug('@@@quoteId: '+quoteId);    
        if(opptyId != null && quoteId != null){  
            set<String> promotionStringSet = new set<String>();
            set<Id> dealRegPromotionIds = new set<Id>();
            list<AT_T_Customer_Site_Quote__c> siteQuoteJunctionList = new list<AT_T_Customer_Site_Quote__c>();
            siteQuoteJunctionList = [SELECT Id,AT_T_Customer_Site__c,Igloo_Review_Required__c,Wireline_Promotion_Id_Before__c,Wireline_Promotion_Id_After__c,Wireline_Promotion_Id_Applied__c,Wireline_Promotion_Number_Applied__c, Wireline_Promotion_Name_Applied__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c=: quoteId];
            
            //Preparing Wireline Promotion Map
            list<Wireline_Promotion_Rules__c> wirelinePromoRuleList = new list<Wireline_Promotion_Rules__c>();
            map<Id,Wireline_Promotion_Rules__c> wirelinePromoDataMap = new map<Id,Wireline_Promotion_Rules__c>();
            for(Wireline_Promotion_Rules__c wpr : [SELECT Id,Name,Active__c,Configured_Fields_After__c,Configured_Fields_Before__c,Configured_Fields_Number__c,Discount_Percentage__c,Display_Promotion_End_Date__c,Do_Not_Run__c,End_Date__c,Expiry_Notification__c,Field_Inputs__c,Field_input_values_JSON__c,For_Testing__c,Hierarchy__c,Priority_Number__c,Priority__c,Promotion_Certified_By__c,Promotion_Certified__c,Promotion_Name__c,Promotion_Notification__c,Promo_Configurator_Lookup__c,Promo_Configured_Fields__c,Promo_Type__c,Rank__c,Rule_Description__c,Selected_Fields__c,Select_Fields_Json__c,Stackable__c,Start_Date__c,Test_SP__c FROM Wireline_Promotion_Rules__c]){
                wirelinePromoDataMap.put(wpr.Id, wpr);
            }        
            
            for(AT_T_Customer_Site_Quote__c junc: siteQuoteJunctionList){
                if(String.isNotBlank(junc.Wireline_Promotion_Id_Before__c)){
                    promotionStringSet.addAll(junc.Wireline_Promotion_Id_Before__c.deleteWhitespace().split(','));
                }
                if(String.isNotBlank(junc.Wireline_Promotion_Id_After__c)){
                    promotionStringSet.addAll(junc.Wireline_Promotion_Id_After__c.deleteWhitespace().split(','));
                }
            }
            
            system.debug('@@@@promotionStringSet'+promotionStringSet);
            system.debug('@@@promotionStringSet.size(): '+promotionStringSet.size());
            
            map<Decimal,Wireline_Promotion_Rules__c> nonStackableRankDealRegPromoMap = new map<Decimal,Wireline_Promotion_Rules__c>();
            Decimal dealregDiscountFraction = 1.00;
            list<string> dealPromotionNameAppliedList = new list<string>();
            list<string> dealPromotionNumberAppliedList = new list<string>();
            
            for(String str: promotionStringSet){
                if(String.isNotBlank(str) && str.split('_')[1] == 'DealReg' && wirelinePromoDataMap.size()>0 && wirelinePromoDataMap.get(Id.valueOf(str.split('_')[0])) != null){
                    if(wirelinePromoDataMap.get(Id.valueOf(str.split('_')[0])).Stackable__c != true){
                        nonStackableRankDealRegPromoMap.put(wirelinePromoDataMap.get(Id.valueOf(str.split('_')[0])).Rank__c,wirelinePromoDataMap.get(Id.valueOf(str.split('_')[0])));
                    }
                    dealregDiscountFraction = dealregDiscountFraction*((100-wirelinePromoDataMap.get(Id.valueOf(str.split('_')[0])).Discount_Percentage__c)/100);
                    dealPromotionNameAppliedList.add(wirelinePromoDataMap.get(Id.valueOf(str.split('_')[0])).Promotion_Name__c + '_' + wirelinePromoDataMap.get(Id.valueOf(str.split('_')[0])).Promo_Type__c);
                    dealPromotionNumberAppliedList.add(wirelinePromoDataMap.get(Id.valueOf(str.split('_')[0])).Name + '_' + wirelinePromoDataMap.get(Id.valueOf(str.split('_')[0])).Promo_Type__c);
                    dealRegPromotionIds.add(Id.valueOf(str.split('_')[0]));
                }
            }
            
            if(nonStackableRankDealRegPromoMap.size()>0){
                dealPromotionNameAppliedList = new list<string>();
                dealPromotionNumberAppliedList = new list<string>();
                List<Decimal> nonStackableDealRegRankList = new List<Integer>();
                dealRegPromotionIds = new set<Id>();
                nonStackableDealRegRankList.addAll(nonStackableRankDealRegPromoMap.keySet());
                nonStackableDealRegRankList.sort();
                dealregDiscountFraction = (100-(nonStackableRankDealRegPromoMap.get(nonStackableDealRegRankList[0]).Discount_Percentage__c))/100;
                dealPromotionNumberAppliedList.add(nonStackableRankDealRegPromoMap.get(nonStackableDealRegRankList[0]).Name + '_' + nonStackableRankDealRegPromoMap.get(nonStackableDealRegRankList[0]).Promo_Type__c);
                dealPromotionNameAppliedList.add(nonStackableRankDealRegPromoMap.get(nonStackableDealRegRankList[0]).Promotion_Name__c + '_' + nonStackableRankDealRegPromoMap.get(nonStackableDealRegRankList[0]).Promo_Type__c);
                dealRegPromotionIds.add(nonStackableRankDealRegPromoMap.get(nonStackableDealRegRankList[0]).Id); 
            }
            
            list<Apttus_Proposal__Proposal__c> quoteList = new list<Apttus_Proposal__Proposal__c>();
            list<date> expiryDateList = new list<date>();
            Date lowestpromoDate = null;
            Date compSiteQuoteDate;
            if(String.isNotBlank(quoteId)){
                system.debug('@@@quoteId: '+quoteId);
                quoteList = [select id,name,Apttus_Proposal__Approval_Stage__c,Apttus_Proposal__Opportunity__r.StageName,Wireline_Promotions_at_Deal_Reg_Level__c,Lowest_Promotion_Expiry_Date__c from Apttus_Proposal__Proposal__c where id =: quoteId];               
                if(quoteList.size()>0){
                    system.debug('@@@quoteList:'+quoteList);
                    list<String> promotionIdList = new list<String>(); 
                    for(Id val : dealRegPromotionIds){
                        promotionIdList.add(String.valueOf(val));
                    }
                    if(String.isNotBlank(quoteList[0].Lowest_Promotion_Expiry_Date__c) && quoteList[0].Lowest_Promotion_Expiry_Date__c.contains('Promotion Expires ')){                         
                        lowestpromoDate = date.parse(quoteList[0].Lowest_Promotion_Expiry_Date__c.remove('Promotion Expires ')); 
                        system.debug('====lowestpromoDate===='+lowestpromoDate);
                    }   
                    system.debug('@@@dealRegPromotionIds:'+dealRegPromotionIds);
                    if(promotionIdList.size()>0){
                        List<Wireline_Promotion_Rules__c> promList = new List<Wireline_Promotion_Rules__c>();
                        promList = [SELECT Id,Expiry_Notification__c,End_Date__c from Wireline_Promotion_Rules__c where id in: promotionIdList];
                        if(!promList.isEmpty()){
                            for(Wireline_Promotion_Rules__c wpr: promList){
                                if(wpr.Expiry_Notification__c){
                                    expiryDateList.add(wpr.End_Date__c);
                                }
                            }
                            if(!expiryDateList.isEmpty()){
                                expiryDateList.sort();                          
                                compSiteQuoteDate = expiryDateList.get(0);
                            }
                            if(compSiteQuoteDate != null && (compSiteQuoteDate < lowestpromoDate || lowestpromoDate == null)){
                                datetime converttoYY = compSiteQuoteDate;
                                string leastDate =  converttoYY.formatGmt('MM/dd/yy');
                                system.debug('====leastDate===='+leastDate);
                                quoteList[0].Lowest_Promotion_Expiry_Date__c = 'Promotion Expires ' + leastDate;                          
                            }   
                        }
                    }
                    
                    if(promotionIdList.size()>0){            
                        if(quoteList[0].Wireline_Promotions_at_Deal_Reg_Level__c != Null && quoteList[0].Wireline_Promotions_at_Deal_Reg_Level__c != String.join(promotionIdList,',')){
                            quoteList[0].Wireline_Promotions_at_Deal_Reg_LevelOld__c = quoteList[0].Wireline_Promotions_at_Deal_Reg_Level__c;
                        }
                        quoteList[0].Wireline_Promotions_at_Deal_Reg_Level__c = String.join(promotionIdList,',');
                    }else{
                        if(quoteList[0].Wireline_Promotions_at_Deal_Reg_Level__c != Null && quoteList[0].Wireline_Promotions_at_Deal_Reg_Level__c != ''){
                            quoteList[0].Wireline_Promotions_at_Deal_Reg_LevelOld__c = quoteList[0].Wireline_Promotions_at_Deal_Reg_Level__c;
                        }
                        quoteList[0].Wireline_Promotions_at_Deal_Reg_Level__c = '';
                    }
                    update quoteList;
                }
            }
            
            //Updating Proposal Line Items
            list<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemUpdateList = new list<Apttus_Proposal__Proposal_Line_Item__c>();
            proposalLineItemUpdateList = [select id,Apttus_QPConfig__NetPrice__c,Net_Price_with_Deal_Reg_Discounts__c,Net_Price_with_SP_Order_Discounts__c,Apttus_QPConfig__ChargeType__c, Wireline_Promotion_Name_Applied__c, Wireline_Promotion_Number_Applied__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c =: quoteId];
            system.debug('@@@dealregDiscountFraction : '+dealregDiscountFraction);
            Boolean lineItemUpdateRequired = false;
            if(dealregDiscountFraction <= 1 && quoteList != null){
                for(Apttus_Proposal__Proposal_Line_Item__c item : proposalLineItemUpdateList){ 
                    if(item.Apttus_QPConfig__ChargeType__c != null && item.Apttus_QPConfig__ChargeType__c != BuyflowConstant.ONETIME_FEE && item.Apttus_QPConfig__ChargeType__c != BuyflowConstant.INTERFACETYPE){                     
                        Decimal netPrice = item.Net_Price_with_SP_Order_Discounts__c != null ? item.Net_Price_with_SP_Order_Discounts__c : (item.Apttus_QPConfig__NetPrice__c != null ? item.Apttus_QPConfig__NetPrice__c : 0.00); 
                        if(item.Net_Price_with_Deal_Reg_Discounts__c != (netPrice*dealregDiscountFraction).setscale(2)){
                            item.Net_Price_with_Deal_Reg_Discounts__c = (netPrice*dealregDiscountFraction).setscale(2); 
                            item.Wireline_Promo_Discount_Deal_Reg__c = (1 - dealregDiscountFraction) * 100;
                            if(String.isNotBlank(item.Wireline_Promotion_Name_Applied__c)){
                                if(dealPromotionNameAppliedList.size()>0){
                                    item.Wireline_Promotion_Name_Applied__c = item.Wireline_Promotion_Name_Applied__c + ',' + String.join(dealPromotionNameAppliedList , ',');
                                }
                            }
                            else{
                                if(dealPromotionNameAppliedList.size()>0){
                                    item.Wireline_Promotion_Name_Applied__c = String.join(dealPromotionNameAppliedList , ',');
                                }                                                                            
                            }
                            if(String.isNotBlank(item.Wireline_Promotion_Number_Applied__c )){
                                    if(dealPromotionNumberAppliedList.size()>0){
                                        item.Wireline_Promotion_Number_Applied__c = item.Wireline_Promotion_Number_Applied__c + ',' + String.join(dealPromotionNumberAppliedList , ',');
                                    }
                            }
                            else{
                                if(dealPromotionNumberAppliedList.size()>0){
                                    item.Wireline_Promotion_Number_Applied__c = String.join(dealPromotionNumberAppliedList , ',');
                                }
                            }
                            lineItemUpdateRequired = true;
                        } 
                    }
                }
                if(lineItemUpdateRequired == true){
                    update proposalLineItemUpdateList;
                }
            }
            
            //Updating Product Pricing Records
            list<Product_Pricing__c> ppList = new list<Product_Pricing__c>();
            Boolean productPricingUpdateRequired = false;
            Decimal discountedPrice = 0.00;
            if(quoteList[0].Apttus_Proposal__Opportunity__c != null){
                ppList = [SELECT Id,SP_Product__c,SP_Site_Id__c,Product_Detail__c,list_price__c,discounted_price__c,discount_price__c,Special_Pricing_Percentage__c,Net_Price_with_SP_Order_Discounts__c,Net_Price_with_Deal_Reg_Discounts__c,Wireline_Promo_Discount_Deal_Reg__c,Wireline_Promotion_Name_Applied__c,Wireline_Promotion_Number_Applied__c FROM Product_Pricing__c pr WHERE pr.SP_Product__c IN (SELECT Id FROM SPProduct__c WHERE Deal__c = :opptyId) ];
            }
            if(dealregDiscountFraction <= 1 && quoteList != null){
                for(Product_Pricing__c pp : ppList){ 
                    if(pp.Product_Detail__c != null && pp.Product_Detail__c != BuyflowConstant.ONETIME_FEE && pp.Product_Detail__c != BuyflowConstant.INTERFACETYPE){                     
                        Decimal netPrice = pp.Net_Price_with_SP_Order_Discounts__c != null ? pp.Net_Price_with_SP_Order_Discounts__c : (pp.list_price__c != null ? pp.list_price__c : 0.00); 
                        if(pp.discounted_price__c != (netPrice*dealregDiscountFraction).setscale(2)){
                            system.debug('@@@@before reviewedealpp.discounted_price__c ' +pp.discounted_price__c );
                            pp.discounted_price__c = pp.Net_Price_with_Deal_Reg_Discounts__c = (netPrice*dealregDiscountFraction).setscale(2); 
                            system.debug('@@@@After reviewedealpp.discounted_price__c ' +pp.discounted_price__c );
                            pp.Wireline_Promo_Discount_Deal_Reg__c = (1 - dealregDiscountFraction) * 100;
                            pp.discount_price__c = pp.list_price__c - pp.discounted_price__c;
                            if(String.isNotBlank(pp.Wireline_Promotion_Name_Applied__c)){
                                if(dealPromotionNameAppliedList.size()>0){
                                    pp.Wireline_Promotion_Name_Applied__c = pp.Wireline_Promotion_Name_Applied__c + ',' + String.join(dealPromotionNameAppliedList , ',');
                                }
                            }
                            else{
                                if(dealPromotionNameAppliedList.size()>0){
                                    pp.Wireline_Promotion_Name_Applied__c = String.join(dealPromotionNameAppliedList , ',');
                                }                                                                            
                            }
                            if(String.isNotBlank(pp.Wireline_Promotion_Number_Applied__c)){
                                if(dealPromotionNumberAppliedList.size()>0){
                                    pp.Wireline_Promotion_Number_Applied__c = pp.Wireline_Promotion_Number_Applied__c + ',' + String.join(dealPromotionNumberAppliedList , ',');
                                }
                            }
                            else{
                                if(dealPromotionNumberAppliedList.size()>0){
                                    pp.Wireline_Promotion_Number_Applied__c = String.join(dealPromotionNumberAppliedList , ',');
                                }
                            }
                            productPricingUpdateRequired = true;
                        } 
                        discountedPrice = discountedPrice + pp.discounted_price__c;
                    }
                }
                if(productPricingUpdateRequired == true){
                    update ppList;
                }
            } 
            if(dealPromotionNameAppliedList.size()>0 || dealPromotionNumberAppliedList.size()>0){
                for(AT_T_Customer_Site_Quote__c junc: siteQuoteJunctionList){
                    if(String.isNotBlank(junc.Wireline_Promotion_Name_Applied__c)){
                        if(dealPromotionNameAppliedList.size()>0){
                            junc.Wireline_Promotion_Name_Applied__c = junc.Wireline_Promotion_Name_Applied__c + ',' + String.join(dealPromotionNameAppliedList , ',');
                        }
                    }
                    else{
                        if(dealPromotionNameAppliedList.size()>0){
                            junc.Wireline_Promotion_Name_Applied__c = String.join(dealPromotionNameAppliedList , ',');
                        }                                                                            
                    }
                    if(String.isNotBlank(junc.Wireline_Promotion_Number_Applied__c)){
                        if(dealPromotionNumberAppliedList.size()>0){
                            junc.Wireline_Promotion_Number_Applied__c = junc.Wireline_Promotion_Number_Applied__c + ',' + String.join(dealPromotionNumberAppliedList , ',');
                        }
                    }
                    else{
                        if(dealPromotionNumberAppliedList.size()>0){
                            junc.Wireline_Promotion_Number_Applied__c = String.join(dealPromotionNumberAppliedList , ',');
                        }
                    } 
                }
                SIConstants.allowSiteQuoteJuncTrigger = false;
                update siteQuoteJunctionList;
            }
            //Updating Opportunity and SPProduct Discount    
            system.debug('@@@opptyId:' +opptyId);
            list<Opportunity> opptyList = new list<Opportunity>();
            opptyList = [Select Id,Calculated_Discount_Percentage__c,Discounted_Percentage__c,Discount_Amount__c,Cumulative_List_Price__c,Cumulative_OTC_Price__c,Discounted_Price__c,Cumulative_OTC_Discount_Price__c,StageName,Standard_Discount_Percentage__c,Custom_Deal_Reg_Percentage__c from Opportunity where ID =:opptyId];
            if(opptyList.size()>0 && dealregDiscountFraction <=1 && productPricingUpdateRequired == true){
                opptyList[0].Discounted_Price__c = discountedPrice;
                opptyList[0].Discounted_Percentage__c = opptyList[0].Custom_Deal_Reg_Percentage__c = opptyList[0].Calculated_Discount_Percentage__c = (1 - dealregDiscountFraction) * 100;
                opptyList[0].Discount_Amount__c = opptyList[0].Cumulative_List_Price__c - opptyList[0].Discounted_Price__c;
                update opptyList;                
            } 
        }
    }
}