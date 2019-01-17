/************************************************************************************** 
 Apex Class Name     : BuyflowUtil
 Version             : 1.0 
 Created Date        : 02/20/2017
 Function            : This class tracks the portal constants
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* US827483             02/20/2017                    Original Version
*************************************************************************************/

public class BuyflowUtil{
    
    /*
    @Method :returnVASAFAILRecords
    @Returns : list<AT_T_Customer_Site_Quote__c> 
    @Paramenter : string quoteId    
    */ 
    public static list<AT_T_Customer_Site_Quote__c> returnVASAFAILRecords(string quoteId){
        datetime myDateTime = datetime.now().addDays(-30);
        system.debug('myDateTime : ' +myDateTime );
        list<AT_T_Customer_Site_Quote__c> addRecCreatedSites = new list<AT_T_Customer_Site_Quote__c>();
        addRecCreatedSites = [select id, AT_T_Customer_Site__r.VASA_Request_Time__c from AT_T_Customer_Site_Quote__c where AT_T_Quote__c =: quoteId and  (AT_T_Customer_Site__r.VASA_Response_Status__c =: BuyflowConstant.ADDRESS_RECORD_CREATED or AT_T_Customer_Site__r.VASA_Request_Time__c <: myDateTime)];
        
        return addRecCreatedSites;
        
    }   
    /*******************************************************************
    * Method 		: returnITPAFAILRecords
    * Description 	: Return ITPA Failed site records 
    * Returns 		: list<AT_T_Customer_Site_Quote__c> 
    * Paramenter 	: string quoteId
    *******************************************************************/  
    public static list<AT_T_Customer_Site_Quote__c> returnITPAFAILRecords(string quoteId){
        
        set<string> errorStringSet = sendITPASuccessCodes();       
        
        list<AT_T_Customer_Site_Quote__c> addRecCreatedSites = new list<AT_T_Customer_Site_Quote__c>();
        addRecCreatedSites = [select id from AT_T_Customer_Site_Quote__c where AT_T_Quote__c =: quoteId and (AT_T_Customer_Site__r.Alternate_Access_ITPA_Response_Status__c != NULL AND  AT_T_Customer_Site__r.Alternate_Access_ITPA_Response_Status__c  NOT IN : errorStringSet) ];
        //addRecCreatedSites = [select id,ACC_ITPA_Call_Status__c from AT_T_Customer_Site_Quote__c where AT_T_Quote__c =: quoteId and (AT_T_Quote__r.ACC_ITPA_Call_Status__c ='Failed' OR(AT_T_Quote__r.ACC_ITPA_Call_Status__c  !='Failed' AND  AT_T_Customer_Site__r.Alternate_Access_ITPA_Response_Status__c  NOT IN : errorStringSet)) ];
        
        return addRecCreatedSites;
        
    }
   /*******************************************************************
    * Method name : sendITPASuccessCodes
    * Description : Sends out the codes for error consideration
    * Return Type : set<string>
    * Parameters  : None.
    *******************************************************************/        
    public static set<string> sendITPASuccessCodes(){
        set<string> errorStringSet = new set<string>();
        errorStringSet.add('200'); 
        errorStringSet.add('900');        
        return errorStringSet ;
    }
    
    /*******************************************************************
    * Method name : returnApexMessage
    * Description : Error text values for the retrail failures
    * Return Type : apexpages.message
    * Parameters  : integer
    * Used in : API_MACD_SiteAddInfoController & SiteAddressInformationController 
    *******************************************************************/    
    public static ApexPages.Message returnApexMessage(integer trialCount){
        ApexPages.Message flashMsg ; 
        if(trialCount >= 4){
            flashMsg = new ApexPages.Message(ApexPages.Severity.INFO, BuyflowConstant.VASA_VALIDATION_ERROR2 );
        }else{
            flashMsg = new ApexPages.Message(ApexPages.Severity.INFO, BuyflowConstant.VASA_VALIDATION_ERROR );
        }
        return flashMsg;
    }
    /*******************************************************************
    * Method name : returnApConfigLineItems
    * Description : Return the apptus config line items which are configured for switched ethernet
    * Return Type : list<Apttus_Config2__LineItem__c>
    * Parameters  : None.
    *******************************************************************/      
    public static list<Apttus_Config2__LineItem__c> returnApConfigLineItems(set<string> siteIdSet, string prodConfigId){
        list<Apttus_Config2__LineItem__c> lineItemList = new  list<Apttus_Config2__LineItem__c>();
        if(!siteIdSet.isEmpty()){
            lineItemList = [SELECT Id,Alternate_Access_IGLOO_Access_Price__c, Apttus_Config2__AttributeValueId__r.Port_Type_AVPN__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__ExtendedPrice__c, Apttus_Config2__AttributeValueId__r.Port_Type_MIS__c, Apttus_Config2__BaseExtendedPrice__c,Apttus_Config2__BasePrice__c,Apttus_Config2__NetPrice__c, Apttus_Config2__AttributeValueId__c,  Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c,AT_T_Customer_Site__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c=: prodConfigId AND AT_T_Customer_Site__c IN : siteIdSet AND ( (Apttus_Config2__AttributeValueId__r.Port_Type_AVPN__c !=null AND Apttus_Config2__AttributeValueId__r.Port_Type_AVPN__c  = 'Switched Ethernet')OR (Apttus_Config2__AttributeValueId__r.Port_Type_MIS__c != null AND Apttus_Config2__AttributeValueId__r.Port_Type_MIS__c = 'Switched Ethernet'))];
            
        }
        return lineItemList;
    }
    /*******************************************************************
    * Method name : returnApConfigLineItems
    * Description : Return the apptus config line items which are configured for switched ethernet
    * Return Type : list<Apttus_Config2__LineItem__c>
    * Parameters  : None.
    *******************************************************************/      
    public static map<string,string> returnEligibleSiteJunctions(string quoteId){
        integer IglooExpirationDays = 90; 
        map<string,string> custSiteJuncMap = new map<string,string>();
        list<AT_T_Customer_Site_Quote__c> lineItemList = new  list<AT_T_Customer_Site_Quote__c>();
        if(string.isNOTBlank(quoteId)){
            for(AT_T_Customer_Site_Quote__c custSiteQuote:[select id,AT_T_Customer_Site__c,Iglow_Response_Received_Date__c, AT_T_Quote__c,Hub__c from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=:quoteId ]){
                if(custSiteQuote.Iglow_Response_Received_Date__c != null && custSiteQuote.Iglow_Response_Received_Date__c.daysBetween(system.now().date()) > IglooExpirationDays ){
                    //expiredSiteJunctionIdSet.add(custSiteQuote.AT_T_Customer_Site__c);
                    custSiteJuncMap.put(custSiteQuote.AT_T_Customer_Site__c,custSiteQuote.id);
                }
            }
        }
        return custSiteJuncMap;
    }
    
    /*******************************************************************
    * Method name : retrieveExistingCartId
    * Description : Sends out the codes for error consideration
    * Return Type : Apttus_Config2__ProductConfiguration__c 
    * Parameters  : String
    *******************************************************************/    
     public static Apttus_Config2__ProductConfiguration__c retrieveExistingCartId(string quoteId){
        system.debug('\n Inside buyflowUtil retrieveExistingCartId method------');
        string cartId = null;
        Apttus_Config2__ProductConfiguration__c prodConfig = null;
        list<Apttus_Config2__ProductConfiguration__c> prodConfigLst = null;        
        List<String> statusList = new List<String>();
        ApttusServiceUtilityHelper helper = new ApttusServiceUtilityHelper();
        statusList.add(SpecialCharacterConstant.NEW_CAPS_LITERAL);
        statusList.add(BuyflowConstant.SAVED);
        statusList.add(BuyflowConstant.FINALIZED);
        try{
            prodConfigLst = [select id, Apttus_QPConfig__Proposald__c, Apttus_Config2__Status__c,(Select Id, isPricingApplied__c,Apttus_Config2__ChargeType__c, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__Description__c,Apttus_Config2__OptionGroupLabel__c,Apttus_Config2__LineType__c,Apttus_Config2__NetPrice__c,Apttus_Config2__OptionId__r.Name,Apttus_Config2__PricingStatus__c, Apttus_Config2__ProductOptionId__c,Apttus_Config2__AttributeValueId__c, Apttus_Config2__ListPrice__c, Apttus_Config2__Quantity__c,Apttus_Config2__PriceType__c  From Apttus_Config2__LineItems__r) from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =: quoteId AND  Apttus_Config2__Status__c IN: statusList order by CreatedDate desc];
            if(prodConfigLst.size() > 0){
                prodConfig = prodConfigLst[0];                               
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return prodConfig;
    }
    /*******************************************************************
    * Method name : offsetSPOnOppty
    * Description : Removes any additional pricing applied
    * Return Type : void
    * Parameters  : Id
    *******************************************************************/ 
    public static void offsetSPOnOppty(Id OpptyId){
    
        Opportunity OpUpdate = new Opportunity();
        OpUpdate.id = OpptyId;
        OpUpdate.Special_Pricing_Approved__c = false;
        OpUpdate.Clear_Special_Pricing__c = true;
        //OpUpdate.Cumulative_List_Price__c = 0;
        //OpUpdate.Discounted_Price__c=0;
        //OpUpdate.Cumulative_OTC_Price__c =0;
        //OpUpdate.Cumulative_OTC_Discount_Price__c=0;
        update OpUpdate ;   
    }
    /*******************************************************************
    * Method name : returnConfigSiteReference
    * Description : Returns buyflow page reference
    * Return Type : void
    * Parameters  : pagereference
    *******************************************************************/ 
    public static pagereference returnConfigSiteReference(string quoteId){
        pagereference redirectToConfigPage = page.PortalDesign_Buyflow ;
        redirectToConfigPage.getparameters().put('mode','confsites');                
        redirectToConfigPage.getparameters().put('quoteid',quoteId);
        redirectToConfigPage.setredirect(true);  
        return redirectToConfigPage;    
    }
    /*******************************************************************
    * Method name : returnConfigSiteAddSiteReference
    * Description : Returns buyflow page reference
    * Return Type : void
    * Parameters  : pagereference
    *******************************************************************/ 
    public static pagereference returnConfigSiteAddSiteReference(string quoteId){
        pagereference redirectToConfigPage = page.API_MACD_PortalDesign_AVPN_MIS_BuyFlow; //api_macd_dealreg // API_MACD_PortalDesign_AVPN_MIS_BuyFlow
        redirectToConfigPage.getparameters().put('mode','confsites');                
        redirectToConfigPage.getparameters().put('quoteid',quoteId);
        redirectToConfigPage.setredirect(true);  
        return redirectToConfigPage;    
    }    
    /*******************************************************************
    * Method name : offSetProductPricing
    * Description : Removes any additional pricing applied
    * Return Type : void
    * Parameters  : Id
    *******************************************************************/ 
    public static void offSetProductPricing(Id OpptyId){
        list<Product_Pricing__c> ProdPricingUpdateList = new list<Product_Pricing__c>();
        for(Product_Pricing__c ppObj : [Select Id, Name, Record_Type__c,list_price__c, discounted_price__c,Discount_Price__c,   Product_Record_Type__c, Product_Name__c, Discount_Type__c, SP_Product__r.Competitive_Pricing_Status__c,Discountable__c,Type__c
                        from Product_Pricing__c where SP_Product__r.Deal__c =: OpptyId AND SP_Product__r.Competitive_Pricing_Status__c != null Order By Name ASC]){
            ppObj.discount_Price__c = 0;
            ppObj.discounted_Price__c = 0;
            ppObj.Discount_Type__c = '';
            ppObj.SP_Discount_Percentage__c = 0;
            ProdPricingUpdateList.add(ppObj);
        }
        if(!ProdPricingUpdateList.isEmpty()){
            update ProdPricingUpdateList;                                
        }
    }
}