/************************************************************************************** 
Apex Class Name     : MISCOUPnew 
Version             : 1.0 
Created Date        : 5th May 2015
Function            : This class is for MIS PP Record Creation 
Modification Log    :
* Developer               Date                   Description
* ----------------------------------------------------------------------------                 
* Accenture IDC            05/12/2015              Original Version
*************************************************************************************/
public class MISCOUPNew  {
    
    public static Boolean executeOnce = false; 
    /* 
Name: SubmitDeal
Description: 
*/ 
    public PageReference submitDeal(){
        try{
            //createSPProductsForQuotes(qList, spProductList, cJunSiteList, proposalLineItem, prodMapList);
            return null;        
        }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            return null;      
        }
    }
    
    /* 
Name: createSPProductsForQuotes
Description: 
*/ 
    public static void createSPProductsForQuotes(Set<Id> qList, List<SPProduct__c> spProductList, List<AT_T_Customer_Site_Quote__c> cJunSiteList, List<Apttus_Config2__LineItem__c> proposalLineItem, List<Product_Mapping__c> prodMapList,List<Apttus_Config2__PriceMatrixEntry__c> priceMatrixList){
        
        List<Apttus_Proposal__Proposal__c> quoteLst = new List<Apttus_Proposal__Proposal__c>();
        Map<String,List<Apttus_Config2__LineItem__c> > mapProposalLineItem = new Map<String,List<Apttus_Config2__LineItem__c> >();        
        boolean isSuccess = false;
        string macdType;
        executeOnce = true;
        //String macdType = [Select Apttus_Config2__ConfigurationId__r.Apttus_Config2__Proposald__r.MACD_Change_Type__c from Apttus_Config2__LineItem__c where Id IN : proposalLineItem limit 1].Apttus_Config2__ConfigurationId__r.Apttus_Config2__Proposald__r.MACD_Change_Type__c; // Added For Fetching the Field Apttus_Proposal__Proposal__r.MACD_Change_Type__c field to query for MACD requirement. 
        if(proposalLineItem.size()>0){
            if(proposalLineItem[0].Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.MACD_Change_Type__c!=null){
                macdType=proposalLineItem[0].Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.MACD_Change_Type__c;
            }
        }
        try{
            Double listPrice = 0.0;
            Map<String,List<Apttus_Config2__LineItem__c>> quoteLineItemMap = new Map<String,List<Apttus_Config2__LineItem__c>>();
            
            Boolean isVLAN = false;
            
            // Creating map based on the site .
            // Map for identifer such as VLAN, COS and Port Type.
            
            
            Map<String,Apttus_Config2__PriceMatrixEntry__c> mapPriceMatrixEntry= New Map<String,Apttus_Config2__PriceMatrixEntry__c>();
            Map<String,Apttus_Config2__PriceMatrixEntry__c> mapPriceMatrixEntryFeatureAccess= New Map<String,Apttus_Config2__PriceMatrixEntry__c>();
            
            
            for(Apttus_Config2__LineItem__c p : proposalLineItem){
                if(quoteLineItemMap.containskey(p.AT_T_Customer_Site__c)){
                    quoteLineItemMap.get(p.AT_T_Customer_Site__c).add(p);                   
                }else{
                    quoteLineItemMap.put(p.AT_T_Customer_Site__c,new List<Apttus_Config2__LineItem__c>{p});
                }
                
            }
            
            if(priceMatrixList!=null){
                for(Apttus_Config2__LineItem__c p : proposalLineItem){
                    for(Apttus_Config2__PriceMatrixEntry__c priceMatrix:priceMatrixList){
                        {
                            
                            if(pricematrix.PLName__c==p.Apttus_Config2__PriceListItemId__r.Name ){
                                mapPriceMatrixEntry.put(priceMatrix.Apttus_Config2__Dimension1Value__c+priceMatrix.PLName__c,priceMatrix);
                                mapPriceMatrixEntryFeatureAccess.put(priceMatrix.Apttus_Config2__Dimension1Value__c+priceMatrix.Apttus_Config2__Dimension2Value__c+priceMatrix.PLName__c,priceMatrix);
                            }
                        }
                    }
                    
                    
                }
            }
            
            List<Apttus_Config2__LineItem__c> proposalList = new List<Apttus_Config2__LineItem__c>(); 
            List<Apttus_Config2__LineItem__c> quoteProposalList = new List<Apttus_Config2__LineItem__c>(); 
            
            Map<Id, Id> siteSPProduct = new Map<Id, Id>(); // Site--> SP Prodcut ID
            for(SPProduct__c sp1: spProductList){
                siteSPProduct.put(sp1.CustomerSiteID__c, sp1.ID);
            }
            
            Map<String,Product_Mapping__c> mapProductMap = new Map<String,Product_Mapping__c>();
            
            for(Product_Mapping__c prodMap : prodMapList){
                mapProductMap.put(prodMap.Combination__c,prodMap);
            }
            
            for(AT_T_Customer_Site_Quote__c prop : cJunSiteList){
                List<Product_Pricing__c> pPricingList = new List<Product_Pricing__c>();
                if(quoteLineItemMap.containsKey(prop.AT_T_Customer_Site__c)){               
                    listPrice = 0.0;
                    proposalList = quoteLineItemMap.get(prop.AT_T_Customer_Site__c);
                    Boolean mBC=false;
                    Boolean router=false;
                    string portspeed, portType;
                    String combination;
                    Boolean combinationFlag = false;
                    String pricelist; 
                    for(Apttus_Config2__LineItem__c pLine : proposalList){ 
                        if(pline.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c){
                            MBC = True;
                            if(pline.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                portType = ATT_Constant.MRCTYPE;
                            }else if(pline.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                portType = ATT_Constant.NRCTYPE;
                            }
                        }
                        
                        if(pline.Apttus_Config2__AttributeValueId__r.Managed_Router__c){
                            router = true;
                        }
                        if( pline.Apttus_Config2__ChargeType__c==UtilityConstant.PORTSPEED_FEE) {
                            PortSpeed = pline.Port_Speed__c;
                            
                        }
                        Pricelist = pLine.Apttus_Config2__PriceListId__r.name;
                        
                        
                        if(MBC && router){
                            CombinationFlag = true;
                        }
                    }
                    
                    
                    Boolean isCombinationCreated = false;
                    Decimal accessTotalFee = 0.00;
                    Decimal accessTotalDiscountFee = 0.00;
                    Decimal accessTotalNetPriceWithSPOrderDisc = 0.00;
                    Decimal accessTotalHiddenPrice = 0.00;
                    Decimal accessTotalOriginalNetPrice = 0.00;
                    
                    for( Apttus_Config2__LineItem__c pLineAccess : proposalList ){
                        if( pLineAccess.Apttus_Config2__ChargeType__c.containsIgnoreCase(UtilityConstant.ACCESSSPEED)){
                            accessTotalFee +=  (pLineAccess.Original_Net_Price__c != null && pLineAccess.Original_Net_Price__c!= 0.00 ? pLineAccess.Original_Net_Price__c : pLineAccess.Apttus_Config2__NetPrice__c);
                            accessTotalDiscountFee += (pLineAccess.Net_Price_with_SP_Order_Discounts__c != null && pLineAccess.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLineAccess.Net_Price_with_SP_Order_Discounts__c : pLineAccess.Apttus_Config2__NetPrice__c);
                            accessTotalNetPriceWithSPOrderDisc += (pLineAccess.Net_Price_with_SP_Order_Discounts__c != null && pLineAccess.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLineAccess.Net_Price_with_SP_Order_Discounts__c : 0.00);
                            accessTotalHiddenPrice += pLineAccess.Original_Hidden_Price__c = (pLineAccess.Original_Hidden_Price__c != null && pLineAccess.Original_Hidden_Price__c != 0.00 ? pLineAccess.Original_Hidden_Price__c : 0.00);
                            accessTotalOriginalNetPrice += pLineAccess.Original_Net_Price__c = (pLineAccess.Original_Net_Price__c != null && pLineAccess.Original_Net_Price__c != 0.00 ? pLineAccess.Original_Net_Price__c : 0.00);
                        }
                    }
                    system.debug('@@@accessTotalFee :'+accessTotalFee);
                    system.debug('@@@accessTotalDiscountFee :'+accessTotalDiscountFee);
                    
                    for(Apttus_Config2__LineItem__c pLine : proposalList){
                        
                        if (pLine.Apttus_Config2__ChargeType__c != UtilityConstant.INTERFACETYPE)
                        {                          
                            Product_Pricing__c  pPricicng = new Product_Pricing__c();
                            
                            //Logic block for Managed Port
                            if(pLine.Apttus_Config2__ChargeType__c == UtilityConstant.PLUSPORT_MANAGED_x && CombinationFlag && !isCombinationCreated){
                                if(mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name)!=null){
                                    pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                    pPricicng.BEID__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                    pPricicng.type__c = portType;
                                    pPricicng.list_price__c = (pLine.Original_Net_Price__c != null && pLine.Original_Net_Price__c!= 0.00 ? pLine.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                    pPricicng.discounted_price__c = (pLine.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLine.Net_Price_with_SP_Order_Discounts__c : pLine.Apttus_Config2__NetPrice__c);
                                    pPricicng.Net_Price_with_SP_Order_Discounts__c = (pline.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pline.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                    pPricicng.Original_Hidden_Price__c = (pline.Original_Hidden_Price__c != null && pLine.Original_Hidden_Price__c != 0.00 ? pline.Original_Hidden_Price__c : 0.00);
                                    pPricicng.Original_Net_Price__c = (pline.Original_Net_Price__c != null && pLine.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : 0.00);
                                    pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (pLine.WP_Hidden_Discount_Percentage__c !=null ? pLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Map_Site__c = (pLine.Wireline_Promotion_Discount_Percentage__c !=null ? pLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (pLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? pLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                    pPricicng.Wireline_Promo_Discount_SP_Order__c = (pLine.Wireline_Promo_Discount_SP_Order__c != null  ? pLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);                                        
                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                    isCombinationCreated = true;
                                    pPricicng.Wireline_Promotion_Name_Applied__c = pLine.Wireline_Promotion_Name_Applied__c;
                                    pPricicng.Wireline_Promotion_Number_Applied__c = pLine.Wireline_Promotion_Number_Applied__c;
                                    pPricingList.add(pPricicng);
                                    
                                    
                                }
                                
                            }
                            // Logic block for COS Fee
                            
                            else if(pLine.Apttus_Config2__ChargeType__c.contains(ATT_Constant.COS)){                                                           
                                if(mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name)!=null){
                                    
                                    pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                    pPricicng.BEID__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;                                       
                                }
                                if(pLine.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                    pPricicng.type__c = ATT_Constant.MRCTYPE;
                                }
                                if(pLine.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                    pPricicng.type__c = ATT_Constant.NRCTYPE;
                                }
                                pPricicng.list_price__c = (pLine.Original_Net_Price__c != null && pLine.Original_Net_Price__c!= 0.00 ? pLine.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                pPricicng.discounted_price__c = (pLine.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLine.Net_Price_with_SP_Order_Discounts__c : pLine.Apttus_Config2__NetPrice__c);
                                pPricicng.Net_Price_with_SP_Order_Discounts__c = (pline.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pline.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                pPricicng.Original_Hidden_Price__c = (pline.Original_Hidden_Price__c != null && pLine.Original_Hidden_Price__c != 0.00 ? pline.Original_Hidden_Price__c : 0.00);
                                pPricicng.Original_Net_Price__c = (pline.Original_Net_Price__c != null && pLine.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : 0.00);
                                pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                pPricicng.Product_Detail__c = pLine.Apttus_Config2__ChargeType__c;
                                pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);             
                                pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (pLine.WP_Hidden_Discount_Percentage__c !=null ? pLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                pPricicng.Wireline_Promo_Discount_Map_Site__c = (pLine.Wireline_Promotion_Discount_Percentage__c !=null ? pLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (pLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? pLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                pPricicng.Wireline_Promo_Discount_SP_Order__c = (pLine.Wireline_Promo_Discount_SP_Order__c != null  ? pLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                pPricicng.Wireline_Promotion_Name_Applied__c = pLine.Wireline_Promotion_Name_Applied__c;
                                pPricicng.Wireline_Promotion_Number_Applied__c = pLine.Wireline_Promotion_Number_Applied__c;
                                pPricingList.add(pPricicng);
                                
                            }  
                            // Logic block for Port(Hi-Cap Flex) Speed Fee
                            else if(pLine.Apttus_Config2__ChargeType__c.contains(ATT_Constant.PORT_SPEED) && PLine.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c && !PLine.Apttus_Config2__AttributeValueId__r.Managed_Router__c ) {
                                if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.MBC_Speed__C+pLine.Apttus_Config2__PriceListItemId__r.Name)!=null){
                                    
                                    pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(pLine.MBC_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                    pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.MBC_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.MBC_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.MBC_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c; 
                                    pPricicng.Low_Level_Tier__c =mapPriceMatrixEntry.get(pLine.MBC_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;                             
                                    if(pline.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                    }else if(pline.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                                    }
                                    pPricicng.list_price__c = (pLine.Original_Net_Price__c != null && pLine.Original_Net_Price__c!= 0.00 ? pLine.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                    pPricicng.discounted_price__c = (pLine.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLine.Net_Price_with_SP_Order_Discounts__c : pLine.Apttus_Config2__NetPrice__c);
                                    pPricicng.Net_Price_with_SP_Order_Discounts__c = (pline.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pline.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                    pPricicng.Original_Hidden_Price__c = (pline.Original_Hidden_Price__c != null && pLine.Original_Hidden_Price__c != 0.00 ? pline.Original_Hidden_Price__c : 0.00);
                                    pPricicng.Original_Net_Price__c = (pline.Original_Net_Price__c != null && pLine.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : 0.00);
                                    pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (pLine.WP_Hidden_Discount_Percentage__c !=null ? pLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Map_Site__c = (pLine.Wireline_Promotion_Discount_Percentage__c !=null ? pLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (pLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? pLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                    pPricicng.Wireline_Promo_Discount_SP_Order__c = (pLine.Wireline_Promo_Discount_SP_Order__c != null  ? pLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);
                                    pPricicng.Product_Detail__c = pLine.Apttus_Config2__ChargeType__c;           
                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Port').getRecordTypeId();
                                    pPricicng.Wireline_Promotion_Name_Applied__c = pLine.Wireline_Promotion_Name_Applied__c;
                                    pPricicng.Wireline_Promotion_Number_Applied__c = pLine.Wireline_Promotion_Number_Applied__c;                                       
                                    pPricingList.add(pPricicng);
                                    
                                }
                            }
                            // Logic block for Port Speed Fee
                            else if(pLine.Apttus_Config2__ChargeType__c.contains(ATT_Constant.PORT_SPEED) && !PLine.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c && !PLine.Apttus_Config2__AttributeValueId__r.Managed_Router__c ) {
                                if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name)!=null){
                                    pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                    pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;                              
                                    if(pline.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                    }else if(pline.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                                    }
                                    pPricicng.list_price__c = (pLine.Original_Net_Price__c != null && pLine.Original_Net_Price__c!= 0.00 ? pLine.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                    pPricicng.discounted_price__c = (pLine.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLine.Net_Price_with_SP_Order_Discounts__c : pLine.Apttus_Config2__NetPrice__c);
                                    pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                    pPricicng.Net_Price_with_SP_Order_Discounts__c = (pline.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pline.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                    pPricicng.Original_Hidden_Price__c = (pline.Original_Hidden_Price__c != null && pLine.Original_Hidden_Price__c != 0.00 ? pline.Original_Hidden_Price__c : 0.00);
                                    pPricicng.Original_Net_Price__c = (pline.Original_Net_Price__c != null && pLine.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (pLine.WP_Hidden_Discount_Percentage__c !=null ? pLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Map_Site__c = (pLine.Wireline_Promotion_Discount_Percentage__c !=null ? pLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (pLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? pLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                    pPricicng.Wireline_Promo_Discount_SP_Order__c = (pLine.Wireline_Promo_Discount_SP_Order__c != null  ? pLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                    pPricicng.Low_Level_Tier__c =mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);
                                    pPricicng.Product_Detail__c = pLine.Apttus_Config2__ChargeType__c;           
                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Port').getRecordTypeId();
                                    pPricicng.Wireline_Promotion_Name_Applied__c = pLine.Wireline_Promotion_Name_Applied__c;
                                    pPricicng.Wireline_Promotion_Number_Applied__c = pLine.Wireline_Promotion_Number_Applied__c;                                       
                                    pPricingList.add(pPricicng);
                                    
                                }
                            }
                            else if(pLine.Apttus_Config2__ChargeType__c.contains(ATT_Constant.PORT_SPEED) && PLine.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c && PLine.Apttus_Config2__AttributeValueId__r.Managed_Router__c  ) {
                                
                                if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.MBC_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name)!=null){
                                    
                                    pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(pLine.MBC_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                    pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.MBC_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.MBC_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.MBC_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;                              
                                    if(pline.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                    }else if(pline.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                                    }
                                    pPricicng.list_price__c = (pLine.Original_Net_Price__c != null && pLine.Original_Net_Price__c!= 0.00 ? pLine.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                    pPricicng.discounted_price__c = (pLine.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLine.Net_Price_with_SP_Order_Discounts__c : pLine.Apttus_Config2__NetPrice__c);
                                    pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                    pPricicng.Net_Price_with_SP_Order_Discounts__c = (pline.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pline.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                    pPricicng.Original_Hidden_Price__c = (pline.Original_Hidden_Price__c != null && pLine.Original_Hidden_Price__c != 0.00 ? pline.Original_Hidden_Price__c : 0.00);
                                    pPricicng.Original_Net_Price__c = (pline.Original_Net_Price__c != null && pLine.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (pLine.WP_Hidden_Discount_Percentage__c !=null ? pLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Map_Site__c = (pLine.Wireline_Promotion_Discount_Percentage__c !=null ? pLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (pLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? pLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                    pPricicng.Wireline_Promo_Discount_SP_Order__c = (pLine.Wireline_Promo_Discount_SP_Order__c != null  ? pLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                    pPricicng.Low_Level_Tier__c =mapPriceMatrixEntry.get(pLine.MBC_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);
                                    pPricicng.Product_Detail__c = pLine.Apttus_Config2__ChargeType__c;           
                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Port').getRecordTypeId();
                                    pPricicng.Wireline_Promotion_Name_Applied__c = pLine.Wireline_Promotion_Name_Applied__c;
                                    pPricicng.Wireline_Promotion_Number_Applied__c = pLine.Wireline_Promotion_Number_Applied__c;
                                    pPricingList.add(pPricicng);
                                    
                                }
                            }
                            else if(pLine.Apttus_Config2__ChargeType__c.contains(ATT_Constant.PORT_SPEED) && !PLine.Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c && PLine.Apttus_Config2__AttributeValueId__r.Managed_Router__c ) {
                                
                                if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name)!=null){
                                    
                                    pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                    pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;                              
                                    if(pline.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                    }else if(pline.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                                    }
                                    pPricicng.list_price__c = (pLine.Original_Net_Price__c != null && pLine.Original_Net_Price__c!= 0.00 ? pLine.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                    pPricicng.discounted_price__c = (pLine.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLine.Net_Price_with_SP_Order_Discounts__c : pLine.Apttus_Config2__NetPrice__c);
                                    pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                    pPricicng.Net_Price_with_SP_Order_Discounts__c = (pline.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pline.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                    pPricicng.Original_Hidden_Price__c = (pline.Original_Hidden_Price__c != null && pLine.Original_Hidden_Price__c != 0.00 ? pline.Original_Hidden_Price__c : 0.00);
                                    pPricicng.Original_Net_Price__c = (pline.Original_Net_Price__c != null && pLine.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (pLine.WP_Hidden_Discount_Percentage__c !=null ? pLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Map_Site__c = (pLine.Wireline_Promotion_Discount_Percentage__c !=null ? pLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (pLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? pLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                    pPricicng.Wireline_Promo_Discount_SP_Order__c = (pLine.Wireline_Promo_Discount_SP_Order__c != null  ? pLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                    pPricicng.Low_Level_Tier__c =mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);
                                    pPricicng.Product_Detail__c = pLine.Apttus_Config2__ChargeType__c;           
                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Port').getRecordTypeId();
                                    pPricicng.Wireline_Promotion_Name_Applied__c = pLine.Wireline_Promotion_Name_Applied__c;
                                    pPricicng.Wireline_Promotion_Number_Applied__c = pLine.Wireline_Promotion_Number_Applied__c;
                                    pPricingList.add(pPricicng);
                                    
                                }
                            }
                            
                            
                            // Logic block for One Time Fee
                            else if(pLine.Apttus_Config2__ChargeType__c == UtilityConstant.ONETIME_FEE ){
                                if(macdType != UtilityConstant.PORTACCESS_SPEED_CHANGE && macdType != UtilityConstant.UBBADD && macdType != UtilityConstant.UBBCHANGE&& macdType != UtilityConstant.UBBREMOVE && macdType != UtilityConstant.ADDCOS && macdType != UtilityConstant.REMOVECOS){ 
                                    if(mapPriceMatrixEntry.get(portSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name)!=null) {
                                        pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                        pPricicng.BEID__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                        pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                        pPricicng.product_name__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                        pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                        
                                        
                                    }
                                    
                                    if(pline.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE) {
                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                    } else if(pline.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE) {
                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                                    }
                                    pPricicng.list_price__c = (pLine.Original_Net_Price__c != null && pLine.Original_Net_Price__c!= 0.00 ? pLine.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                    pPricicng.discounted_price__c = (pLine.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLine.Net_Price_with_SP_Order_Discounts__c : pLine.Apttus_Config2__NetPrice__c);
                                    pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                    pPricicng.Net_Price_with_SP_Order_Discounts__c = (pline.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pline.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                    pPricicng.Original_Hidden_Price__c = (pline.Original_Hidden_Price__c != null && pLine.Original_Hidden_Price__c != 0.00 ? pline.Original_Hidden_Price__c : 0.00);
                                    pPricicng.Original_Net_Price__c = (pline.Original_Net_Price__c != null && pLine.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (pLine.WP_Hidden_Discount_Percentage__c !=null ? pLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Map_Site__c = (pLine.Wireline_Promotion_Discount_Percentage__c !=null ? pLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                    pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (pLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? pLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                    pPricicng.Wireline_Promo_Discount_SP_Order__c = (pLine.Wireline_Promo_Discount_SP_Order__c != null  ? pLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);
                                    pPricicng.Product_Detail__c = pLine.Apttus_Config2__ChargeType__c;
                                    pPricicng.Discountable__c=true;           
                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                    pPricicng.Wireline_Promotion_Name_Applied__c = pLine.Wireline_Promotion_Name_Applied__c;
                                    pPricicng.Wireline_Promotion_Number_Applied__c = pLine.Wireline_Promotion_Number_Applied__c;
                                    pPricingList.add(pPricicng);
                                } 
                            }
                            // Logic block for Access Speed Fee
                            else if(pLine.Apttus_Config2__ChargeType__c==UtilityConstant.ACCESSSPEED_FEE){
                                
                                if(!mapPriceMatrixEntryFeatureAccess.isEmpty() && mapPriceMatrixEntryFeatureAccess.get(pLine.AccessSpeed__c+Pline.VASARegion__c+pLine.Apttus_Config2__PriceListItemId__r.Name)!=null){
                                    pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntryFeatureAccess.get(pLine.AccessSpeed__c+Pline.VASARegion__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                    pPricicng.BEID__c =  mapPriceMatrixEntryFeatureAccess.get(pLine.AccessSpeed__c+Pline.VASARegion__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                    pPricicng.PBI_Number__c = mapPriceMatrixEntryFeatureAccess.get(pLine.AccessSpeed__c+Pline.VASARegion__c+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                    pPricicng.product_name__c = mapPriceMatrixEntryFeatureAccess.get(pLine.AccessSpeed__c+Pline.VASARegion__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntryFeatureAccess.get(pLine.AccessSpeed__c+Pline.VASARegion__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;                                                              
                                }
                                if(pline.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                    pPricicng.type__c = ATT_Constant.MRCTYPE;
                                }else if(pline.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                    pPricicng.type__c = ATT_Constant.NRCTYPE;
                                }
                                system.debug('@@@inside accessTotalFee'+accessTotalFee);
                                system.debug('@@@inside accessTotalDiscountFee'+accessTotalDiscountFee);
                                pPricicng.list_price__c = accessTotalFee;
                                pPricicng.discounted_price__c = accessTotalDiscountFee;
                                pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                pPricicng.Net_Price_with_SP_Order_Discounts__c = accessTotalNetPriceWithSPOrderDisc;
                                pPricicng.Original_Hidden_Price__c = accessTotalHiddenPrice;
                                pPricicng.Original_Net_Price__c = accessTotalOriginalNetPrice;
                                pPricicng.Product_Detail__c = pLine.Apttus_Config2__ChargeType__c;
                                pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c); 
                                pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (pLine.WP_Hidden_Discount_Percentage__c !=null ? pLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                pPricicng.Wireline_Promo_Discount_Map_Site__c = (pLine.Wireline_Promotion_Discount_Percentage__c !=null ? pLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (pLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? pLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                pPricicng.Wireline_Promo_Discount_SP_Order__c = (pLine.Wireline_Promo_Discount_SP_Order__c != null  ? pLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Access').getRecordTypeId();
                                pPricicng.Wireline_Promotion_Name_Applied__c = pLine.Wireline_Promotion_Name_Applied__c;
                                pPricicng.Wireline_Promotion_Number_Applied__c = pLine.Wireline_Promotion_Number_Applied__c;
                                pPricingList.add(pPricicng);  
                            }
                            // Logic for DNS Fee
                            else if((pLine.Apttus_Config2__ChargeType__c!=UtilityConstant.HICAP_FLEX || pLine.Apttus_Config2__ChargeType__c != UtilityConstant.ONETIME_FEE || pLine.Apttus_Config2__ChargeType__c!=UtilityConstant.PLUSPORT_MANAGED_x) && !isCombinationCreated){
                                if(pLine.Apttus_Config2__ChargeType__c==UtilityConstant.ADDITIONALDNS_FEE){
                                    
                                    if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.AdditionalDnsType__c+pLine.Apttus_Config2__PriceListItemId__r.Name)!=null) 
                                        if(mapPriceMatrixEntry.get(pLine.AdditionalDnsType__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c!=null && mapPriceMatrixEntry.get(pLine.AdditionalDnsType__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c!=null && mapPriceMatrixEntry.get(pLine.AdditionalDnsType__c+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c!=null){
                                            pPricicng.Determinant_Set_ID__c =mapPriceMatrixEntry.get(pLine.AdditionalDnsType__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                            pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.AdditionalDnsType__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                            pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.AdditionalDnsType__c+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                            pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.AdditionalDnsType__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                            pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(pLine.AdditionalDnsType__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                            if(pline.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                                pPricicng.type__c = ATT_Constant.MRCTYPE;
                                            }else if(pline.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                                pPricicng.type__c = ATT_Constant.NRCTYPE;
                                            }
                                            pPricicng.list_price__c = (pLine.Original_Net_Price__c != null && pLine.Original_Net_Price__c!= 0.00 ? pLine.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                            pPricicng.discounted_price__c = (pLine.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLine.Net_Price_with_SP_Order_Discounts__c : pLine.Apttus_Config2__NetPrice__c);
                                            pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                            pPricicng.Net_Price_with_SP_Order_Discounts__c = (pline.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pline.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                            pPricicng.Original_Hidden_Price__c = (pline.Original_Hidden_Price__c != null && pLine.Original_Hidden_Price__c != 0.00 ? pline.Original_Hidden_Price__c : 0.00);
                                            pPricicng.Original_Net_Price__c = (pline.Original_Net_Price__c != null && pLine.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : 0.00);
                                            pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (pLine.WP_Hidden_Discount_Percentage__c !=null ? pLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                            pPricicng.Wireline_Promo_Discount_Map_Site__c = (pLine.Wireline_Promotion_Discount_Percentage__c !=null ? pLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                            pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (pLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? pLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                            pPricicng.Wireline_Promo_Discount_SP_Order__c = (pLine.Wireline_Promo_Discount_SP_Order__c != null  ? pLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                            pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);    
                                            pPricicng.Product_Detail__c = pLine.Apttus_Config2__ChargeType__c;        
                                            pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                            pPricicng.Wireline_Promotion_Name_Applied__c = pLine.Wireline_Promotion_Name_Applied__c;
                                            pPricicng.Wireline_Promotion_Number_Applied__c = pLine.Wireline_Promotion_Number_Applied__c;                                                   
                                            pPricingList.add(pPricicng);
                                        }
                                }
                                else if(pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.VTN_FEE)){
                                    
                                    if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name)!=null) {
                                        
                                        pPricicng.Determinant_Set_ID__c =mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                        pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                        pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                        pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                        pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                        if(pline.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(pline.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                        }
                                        pPricicng.list_price__c = (pLine.Original_Net_Price__c != null && pLine.Original_Net_Price__c!= 0.00 ? pLine.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discounted_price__c = (pLine.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLine.Net_Price_with_SP_Order_Discounts__c : pLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                        pPricicng.Net_Price_with_SP_Order_Discounts__c = (pline.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pline.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                        pPricicng.Original_Hidden_Price__c = (pline.Original_Hidden_Price__c != null && pLine.Original_Hidden_Price__c != 0.00 ? pline.Original_Hidden_Price__c : 0.00);
                                        pPricicng.Original_Net_Price__c = (pline.Original_Net_Price__c != null && pLine.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (pLine.WP_Hidden_Discount_Percentage__c !=null ? pLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Map_Site__c = (pLine.Wireline_Promotion_Discount_Percentage__c !=null ? pLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (pLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? pLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                        pPricicng.Wireline_Promo_Discount_SP_Order__c = (pLine.Wireline_Promo_Discount_SP_Order__c != null  ? pLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                        pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);      
                                        pPricicng.Product_Detail__c = pLine.Apttus_Config2__ChargeType__c;      
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                        pPricicng.Wireline_Promotion_Name_Applied__c = pLine.Wireline_Promotion_Name_Applied__c;
                                        pPricicng.Wireline_Promotion_Number_Applied__c = pLine.Wireline_Promotion_Number_Applied__c;
                                        pPricingList.add(pPricicng);
                                    }
                                }
                                else if(pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.VOIP)){
                                    
                                    if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.VOIP__c+pLine.Apttus_Config2__PriceListItemId__r.Name)!=null) {
                                        
                                        pPricicng.Determinant_Set_ID__c =mapPriceMatrixEntry.get(pLine.VOIP__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                        pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.VOIP__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                        pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.VOIP__c+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                        pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.VOIP__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                        pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(pLine.VOIP__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                        if(pline.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(pline.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                        }
                                        pPricicng.list_price__c = (pLine.Original_Net_Price__c != null && pLine.Original_Net_Price__c!= 0.00 ? pLine.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discounted_price__c = (pLine.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLine.Net_Price_with_SP_Order_Discounts__c : pLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                        pPricicng.Net_Price_with_SP_Order_Discounts__c = (pline.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pline.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                        pPricicng.Original_Hidden_Price__c = (pline.Original_Hidden_Price__c != null && pLine.Original_Hidden_Price__c != 0.00 ? pline.Original_Hidden_Price__c : 0.00);
                                        pPricicng.Original_Net_Price__c = (pline.Original_Net_Price__c != null && pLine.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (pLine.WP_Hidden_Discount_Percentage__c !=null ? pLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Map_Site__c = (pLine.Wireline_Promotion_Discount_Percentage__c !=null ? pLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (pLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? pLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                        pPricicng.Wireline_Promo_Discount_SP_Order__c = (pLine.Wireline_Promo_Discount_SP_Order__c != null  ? pLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                        pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);   
                                        pPricicng.Product_Detail__c = pLine.Apttus_Config2__ChargeType__c;         
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                        pPricicng.Wireline_Promotion_Name_Applied__c = pLine.Wireline_Promotion_Name_Applied__c;
                                        pPricicng.Wireline_Promotion_Number_Applied__c = pLine.Wireline_Promotion_Number_Applied__c;                                                   
                                        pPricingList.add(pPricicng);
                                        
                                    }
                                }
                                else if(pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.SETUP_FEE)){
                                    if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name)!=null) {
                                        //if(mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c!=null && mapPriceMatrixEntry.get(pLine.AdditionalDnsType__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c!=null && mapPriceMatrixEntry.get(pLine.AdditionalDnsType__c+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c!=null)
                                        pPricicng.Determinant_Set_ID__c =mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                        pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                        pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                        pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                        pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                        if(pline.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(pline.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                        }
                                        pPricicng.list_price__c = (pLine.Original_Net_Price__c != null && pLine.Original_Net_Price__c!= 0.00 ? pLine.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discounted_price__c = (pLine.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLine.Net_Price_with_SP_Order_Discounts__c : pLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                        pPricicng.Net_Price_with_SP_Order_Discounts__c = (pline.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pline.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                        pPricicng.Original_Hidden_Price__c = (pline.Original_Hidden_Price__c != null && pLine.Original_Hidden_Price__c != 0.00 ? pline.Original_Hidden_Price__c : 0.00);
                                        pPricicng.Original_Net_Price__c = (pline.Original_Net_Price__c != null && pLine.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (pLine.WP_Hidden_Discount_Percentage__c !=null ? pLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Map_Site__c = (pLine.Wireline_Promotion_Discount_Percentage__c !=null ? pLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (pLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? pLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                        pPricicng.Wireline_Promo_Discount_SP_Order__c = (pLine.Wireline_Promo_Discount_SP_Order__c != null  ? pLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                        pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);  
                                        pPricicng.Product_Detail__c = pLine.Apttus_Config2__ChargeType__c;          
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                        pPricicng.Discountable__c=true;
                                        pPricicng.Wireline_Promotion_Name_Applied__c = pLine.Wireline_Promotion_Name_Applied__c;
                                        pPricicng.Wireline_Promotion_Number_Applied__c = pLine.Wireline_Promotion_Number_Applied__c;
                                        pPricingList.add(pPricicng);
                                    }
                                }
                                
                                else if(pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.ENHANCED_FEATURES)){
                                    
                                    if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name)!=null) {
                                        pPricicng.Determinant_Set_ID__c =mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                        pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                        pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                        pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                        pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                        if(pline.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(pline.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                        }
                                        pPricicng.list_price__c = (pLine.Original_Net_Price__c != null && pLine.Original_Net_Price__c!= 0.00 ? pLine.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discounted_price__c = (pLine.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLine.Net_Price_with_SP_Order_Discounts__c : pLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                        pPricicng.Net_Price_with_SP_Order_Discounts__c = (pline.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pline.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                        pPricicng.Original_Hidden_Price__c = (pline.Original_Hidden_Price__c != null && pLine.Original_Hidden_Price__c != 0.00 ? pline.Original_Hidden_Price__c : 0.00);
                                        pPricicng.Original_Net_Price__c = (pline.Original_Net_Price__c != null && pLine.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (pLine.WP_Hidden_Discount_Percentage__c !=null ? pLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Map_Site__c = (pLine.Wireline_Promotion_Discount_Percentage__c !=null ? pLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (pLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? pLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                        pPricicng.Wireline_Promo_Discount_SP_Order__c = (pLine.Wireline_Promo_Discount_SP_Order__c != null  ? pLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                        pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);   
                                        pPricicng.Product_Detail__c = pLine.Apttus_Config2__ChargeType__c;         
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                        pPricicng.Wireline_Promotion_Name_Applied__c = pLine.Wireline_Promotion_Name_Applied__c;
                                        pPricicng.Wireline_Promotion_Number_Applied__c = pLine.Wireline_Promotion_Number_Applied__c;                                                   
                                        pPricingList.add(pPricicng);
                                    }
                                }
                                else if(pLine.Apttus_Config2__ChargeType__c.Contains(ATT_Constant.IP_FLEX_REACH_PLAN)){
                                    
                                    if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name)!=null) {
                                        
                                        pPricicng.Determinant_Set_ID__c =mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                        pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BEID__c;
                                        pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).PBI_Number__c;
                                        pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).BillDisplayName__c;
                                        pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(pLine.Apttus_Config2__AttributeValueId__r.IP_Flexible_Reach_Plan__c+pLine.Apttus_Config2__PriceListItemId__r.Name).Low_Level__c;
                                        if(pline.Apttus_Config2__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(pline.Apttus_Config2__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                        }
                                        pPricicng.list_price__c = (pLine.Original_Net_Price__c != null && pLine.Original_Net_Price__c!= 0.00 ? pLine.Original_Net_Price__c : pLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discounted_price__c = (pLine.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pLine.Net_Price_with_SP_Order_Discounts__c : pLine.Apttus_Config2__NetPrice__c);
                                        pPricicng.discount_price__c = (pPricicng.list_price__c !=null && pPricicng.list_price__c != 0.00 && pPricicng.discounted_price__c!=null && pPricicng.discounted_price__c != 0.00 ? (pPricicng.list_price__c - pPricicng.discounted_price__c) : 0.00);
                                        pPricicng.Net_Price_with_SP_Order_Discounts__c = (pline.Net_Price_with_SP_Order_Discounts__c != null && pLine.Net_Price_with_SP_Order_Discounts__c != 0.00 ? pline.Net_Price_with_SP_Order_Discounts__c : 0.00);
                                        pPricicng.Original_Hidden_Price__c = (pline.Original_Hidden_Price__c != null && pLine.Original_Hidden_Price__c != 0.00 ? pline.Original_Hidden_Price__c : 0.00);
                                        pPricicng.Original_Net_Price__c = (pline.Original_Net_Price__c != null && pLine.Original_Net_Price__c != 0.00 ? pline.Original_Net_Price__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Access_Hidden__c = (pLine.WP_Hidden_Discount_Percentage__c !=null ? pLine.WP_Hidden_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Map_Site__c = (pLine.Wireline_Promotion_Discount_Percentage__c !=null ? pLine.Wireline_Promotion_Discount_Percentage__c : 0.00);
                                        pPricicng.Wireline_Promo_Discount_Deal_Reg__c = (pLine.Wireline_Promo_Discount_Deal_Reg__c != null  ? pLine.Wireline_Promo_Discount_Deal_Reg__c :0.00);
                                        pPricicng.Wireline_Promo_Discount_SP_Order__c = (pLine.Wireline_Promo_Discount_SP_Order__c != null  ? pLine.Wireline_Promo_Discount_SP_Order__c :0.00);
                                        pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);    
                                        pPricicng.Product_Detail__c = pLine.Apttus_Config2__ChargeType__c;        
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                        pPricicng.Wireline_Promotion_Name_Applied__c = pLine.Wireline_Promotion_Name_Applied__c;
                                        pPricicng.Wireline_Promotion_Number_Applied__c = pLine.Wireline_Promotion_Number_Applied__c;                                                   
                                        pPricingList.add(pPricicng);
                                    }
                                }
                            }
                        }
                    }
                }
                insert pPricingList;
            }
            
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));            
        }
    }
}