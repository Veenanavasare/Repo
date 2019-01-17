/************************************************************************************** 
Apex Class Name     : MISCOUP 
Version             : 1.0 
Created Date        : 5th May 2015
Function            : This class is for MIS PP Record Creation 
Modification Log    :
* Developer               Date                   Description
* ----------------------------------------------------------------------------                 
* Accenture IDC            05/12/2015              Original Version
*************************************************************************************/

public class MISCOUP {
  
    public static Boolean executeOnce = false; 
    public PageReference SubmitDeal(){
        //createSPProductsForQuotes(qList, spProductList, cJunSiteList, proposalLineItem, prodMapList);
        return null;        
    }

    public static void createSPProductsForQuotes(Set<Id> qList, List<SPProduct__c> spProductList, List<AT_T_Customer_Site_Quote__c> cJunSiteList, List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItem, List<Product_Mapping__c> prodMapList,List<Apttus_Config2__PriceMatrixEntry__c> priceMatrixList){
        List<Apttus_Proposal__Proposal__c> quoteLst = new List<Apttus_Proposal__Proposal__c>();
        Map<String,List<Apttus_Proposal__Proposal_Line_Item__c> > mapProposalLineItem = new Map<String,List<Apttus_Proposal__Proposal_Line_Item__c> >();        

        boolean isSuccess = false;
        executeOnce = true;
        String macdType = [Select Apttus_Proposal__Proposal__r.MACD_Change_Type__c from Apttus_Proposal__Proposal_Line_Item__c where Id IN : proposalLineItem limit 1].Apttus_Proposal__Proposal__r.MACD_Change_Type__c; // Added For Fetching the Field Apttus_Proposal__Proposal__r.MACD_Change_Type__c field to query for MACD requirement. 
        try{
            Double listPrice = 0.0;
            system.debug('MISCOUP@@@@@@@@');
            Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>> quoteLineItemMap = new Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>>();
            
            Boolean isVLAN = false;
            
            // Creating map based on the site .
            // Map for identifer such as VLAN, COS and Port Type.
            
           
            Map<String,Apttus_Config2__PriceMatrixEntry__c> mapPriceMatrixEntry= New Map<String,Apttus_Config2__PriceMatrixEntry__c>();
            Map<String,Apttus_Config2__PriceMatrixEntry__c> mapPriceMatrixEntryFeatureAccess= New Map<String,Apttus_Config2__PriceMatrixEntry__c>();
           
            
            for(Apttus_Proposal__Proposal_Line_Item__c p : proposalLineItem){
                if(quoteLineItemMap.containskey(p.AT_T_Customer_Site__c)){
                    quoteLineItemMap.get(p.AT_T_Customer_Site__c).add(p);                   
                }else{
                    quoteLineItemMap.put(p.AT_T_Customer_Site__c,new List<Apttus_Proposal__Proposal_Line_Item__c>{p});
                }
                 
            }
            
            if(priceMatrixList!=null){
            for(Apttus_Proposal__Proposal_Line_Item__c p : proposalLineItem){
             for(Apttus_Config2__PriceMatrixEntry__c priceMatrix:priceMatrixList){
                  {
                  
                   if(pricematrix.PLName__c==p.Apttus_QPConfig__PriceListItemId__r.Name ){
                      
                    mapPriceMatrixEntry.put(priceMatrix.Apttus_Config2__Dimension1Value__c+priceMatrix.PLName__c,priceMatrix);
                    mapPriceMatrixEntryFeatureAccess.put(priceMatrix.Apttus_Config2__Dimension1Value__c+priceMatrix.Apttus_Config2__Dimension2Value__c+priceMatrix.PLName__c,priceMatrix);
                    }
                   }
                }
           
             
             }
            }
            
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalList = new List<Apttus_Proposal__Proposal_Line_Item__c>(); 
            List<Apttus_Proposal__Proposal_Line_Item__c> quoteProposalList = new List<Apttus_Proposal__Proposal_Line_Item__c>(); 
            
            Map<Id, Id> siteSPProduct = new Map<Id, Id>(); // Site--> SP Prodcut ID
            for(SPProduct__c sp1: spProductList){
                siteSPProduct.put(sp1.CustomerSiteID__c, sp1.ID);
            }
            System.debug('siteSPProduct --- ' + siteSPProduct);
            
            Map<String,Product_Mapping__c> mapProductMap = new Map<String,Product_Mapping__c>();
            
            for(Product_Mapping__c prodMap : prodMapList){
                mapProductMap.put(prodMap.Combination__c,prodMap);
            }
            
            for(AT_T_Customer_Site_Quote__c prop : cJunSiteList){
                List<Product_Pricing__c> pPricingList = new List<Product_Pricing__c>();
                if(quoteLineItemMap.containsKey(prop.AT_T_Customer_Site__c)){               
                    listPrice = 0.0;
                    proposalList = quoteLineItemMap.get(prop.AT_T_Customer_Site__c);
                    Boolean MBC=false;
                    Boolean router=false;
                    string Portspeed, portType;
                    String Combination;
                    Boolean CombinationFlag = false;
                    String Pricelist; 
                    
                    for(Apttus_Proposal__Proposal_Line_Item__c pLine : proposalList){ 
                        System.debug('-----AB------'+pline);
                        if(pline.Apttus_QPConfig__ChargeType__c == 'Hi-Cap Flex'){
                            MBC = True;
                            if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE){
                                portType = ATT_Constant.MRCTYPE;
                            }else if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                portType = ATT_Constant.NRCTYPE;
                            }
                        }
                        
                        if(pline.Apttus_QPConfig__ChargeType__c == 'Plus Port (Managed)'){
                            router = true;
                        }
                        if( pline.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.PORT_SPEED)) {
                            PortSpeed = pline.Port_Speed__c;
                            
                        }
                        Pricelist = pLine.Apttus_QPConfig__PriceListId__r.name;
                        
                        
                        if(MBC && router){
                            CombinationFlag = true;
                        }
                    }
                    
                    
                    Boolean isCombinationCreated = false;
                    Decimal accessTotalFee = 0.00;
                     for( Apttus_Proposal__Proposal_Line_Item__c pLineAccess : proposalList ){
                              if( pLineAccess.Apttus_QPConfig__ChargeType__c.containsIgnoreCase('Access Speed')){
                
                                accessTotalFee += pLineAccess.Apttus_QPConfig__NetPrice__c;
                              }
        
                             }
              
                    for(Apttus_Proposal__Proposal_Line_Item__c pLine : proposalList){
                         
                        if (pLine.Apttus_QPConfig__ChargeType__c != 'Interface Type')
                        {
                            
                           
                          
                            Product_Pricing__c  pPricicng = new Product_Pricing__c();
                            
                            // Logic for Hi-Cap Flex-- Not in Scope for this sprint
                            if(pLine.Apttus_QPConfig__ChargeType__c== 'Hi-Cap Flex'  && CombinationFlag && !isCombinationCreated){
                                Combination = Pricelist+' + '+ATT_Constant.HcapFlex+' + '+PortSpeed;
                                if(mapProductMap.get(Combination)!=null){
                                    pPricicng.Determinant_Set_ID__c = String.valueOf(mapProductMap.get(Combination).Determinant_Set_Id__c);
                                    pPricicng.BEID__c = String.valueOf(mapProductMap.get(Combination).BEID__c);
                                    pPricicng.PBI_Number__c = String.valueOf(mapProductMap.get(Combination).PBIID__c);
                                    pPricicng.product_name__c = mapProductMap.get(Combination).Bill_Display_Name__c;
                                    pPricicng.type__c = portType;
                                    pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);           
                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                    pPricicng.Low_Level_Tier__c = String.valueOf(mapProductMap.get(Combination).Low_Level_Tier__c);

                                    isCombinationCreated = true;
                                    pPricingList.add(pPricicng);
                                    
                                }
                                
                            }
                            //Logic block for Managed Port
                            else if(pLine.Apttus_QPConfig__ChargeType__c == 'Plus Port (Managed)' && CombinationFlag && !isCombinationCreated){
                                if(mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null){
                                    pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                    pPricicng.BEID__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;
                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                    pPricicng.type__c = portType;
                                    pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);                                        
                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                    isCombinationCreated = true;
                                    pPricingList.add(pPricicng);
                                   
                                }
                                
                            }
                            // Logic block for COS Fee
                            
                            else if(pLine.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.COS)){  
                                    if(mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null){
                                        
                                        pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                        pPricicng.BEID__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                        pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                        pPricicng.product_name__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;
                                        pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;                                       
                                    }
                                    if(pLine.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE)
                                    pPricicng.type__c = ATT_Constant.MRCTYPE;
                                    if(pLine.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE)
                                    pPricicng.type__c = ATT_Constant.NRCTYPE;
                                    pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                    pPricicng.Product_Detail__c = pLine.Apttus_QPConfig__ChargeType__c;
                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);             
                                    
                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                    pPricingList.add(pPricicng);
                                  
                                }  
                                 // Logic block for Port(Hi-Cap Flex) Speed Fee
                                else if(pLine.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.PORT_SPEED) && PLine.HiCapFlex__c && !PLine.Managed_Router__c) {
                                                              
                                    if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.UBBSpeed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null){
                                    
                                        pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(pLine.UBBSpeed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                        pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.UBBSpeed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                        pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.UBBSpeed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                        pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.UBBSpeed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c; 
                                        pPricicng.Low_Level_Tier__c =mapPriceMatrixEntry.get(pLine.UBBSpeed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;                             
                                        if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                        }
                                        pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                       
                                        pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);
                                        pPricicng.Product_Detail__c = pLine.Apttus_QPConfig__ChargeType__c;           
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Port').getRecordTypeId();
                                        pPricingList.add(pPricicng);
                                        
                                     }
                                }
                                // Logic block for Port Speed Fee
                                else if(pLine.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.PORT_SPEED) && !PLine.HiCapFlex__c && !PLine.Managed_Router__c) {
                                                              
                                    if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null){
                                    
                                        pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                        pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                        pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                        pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;                              
                                        if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                        }
                                        pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                        pPricicng.Low_Level_Tier__c =mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                        pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);
                                        pPricicng.Product_Detail__c = pLine.Apttus_QPConfig__ChargeType__c;           
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Port').getRecordTypeId();
                                        pPricingList.add(pPricicng);
                                        
                                     }
                                }
                                else if(pLine.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.PORT_SPEED) && PLine.HiCapFlex__c && PLine.Managed_Router__c  ) {
                                                              
                                    if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.UBBSpeed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null){
                                    
                                        pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(pLine.UBBSpeed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                        pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.UBBSpeed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                        pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.UBBSpeed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                        pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.UBBSpeed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;                              
                                        if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                        }
                                        pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                        pPricicng.Low_Level_Tier__c =mapPriceMatrixEntry.get(pLine.UBBSpeed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                        pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);
                                        pPricicng.Product_Detail__c = pLine.Apttus_QPConfig__ChargeType__c;           
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Port').getRecordTypeId();
                                        pPricingList.add(pPricicng);
                                        
                                     }
                                }
                                else if(pLine.Apttus_QPConfig__ChargeType__c.contains(ATT_Constant.PORT_SPEED) && !PLine.HiCapFlex__c && PLine.Managed_Router__c ) {
                                                              
                                    if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null){
                                    
                                        pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                        pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                        pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                        pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;                              
                                        if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE){
                                            pPricicng.type__c = ATT_Constant.MRCTYPE;
                                        }else if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                            pPricicng.type__c = ATT_Constant.NRCTYPE;
                                        }
                                        pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                        pPricicng.Low_Level_Tier__c =mapPriceMatrixEntry.get(pLine.Port_Speed__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                        pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);
                                        pPricicng.Product_Detail__c = pLine.Apttus_QPConfig__ChargeType__c;           
                                        pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Port').getRecordTypeId();
                                        pPricingList.add(pPricicng);
                                        
                                     }
                                }
                                
                                
                                // Logic block for One Time Fee
                                else if(pLine.Apttus_QPConfig__ChargeType__c == 'One Time Fee' ){
                                  if(macdType != 'Port/Access Speed Change' && macdType != 'UBB Add' && macdType != 'UBB Change'&& macdType != 'UBB Remove' && macdType != 'Add CoS' && macdType != 'Remove CoS'){                                     
                                    System.debug('********VAL'+mapPriceMatrixEntry.get(portSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name));
                                    if(mapPriceMatrixEntry.get(portSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null) {
                                       system.debug('**PORT'+PortSpeed);
                                       System.debug('********VAL'+mapPriceMatrixEntry.get(portSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name));
                                        system.debug('******ONE***'+mapPriceMatrixEntryFeatureAccess.get(PortSpeed+pLine.One_Time_Fee__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name));
                                        pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                        pPricicng.BEID__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                        pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                        pPricicng.product_name__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;
                                        pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(PortSpeed+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                                                   
                                        
                                     }
                                                              
                                    if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE) {
                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                    } else if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE) {
                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                                    }
                                    pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);
                                    pPricicng.Product_Detail__c = pLine.Apttus_QPConfig__ChargeType__c;
                                    pPricicng.Discountable__c=true;           
                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                    pPricingList.add(pPricicng);
                                   } 
                                }
                                // Logic block for Access Speed Fee
                              else if(pLine.Apttus_QPConfig__ChargeType__c=='Access Speed Fee'){
                              
                                    if(!mapPriceMatrixEntryFeatureAccess.isEmpty() && mapPriceMatrixEntryFeatureAccess.get(pLine.Access_Speed__c+Pline.VASA_Region__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null){
                                    system.debug('CHARGE TYPE1'+pLine.Apttus_QPConfig__ChargeType__c );
                                    pPricicng.Determinant_Set_ID__c = mapPriceMatrixEntryFeatureAccess.get(pLine.Access_Speed__c+Pline.VASA_Region__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                    pPricicng.BEID__c =  mapPriceMatrixEntryFeatureAccess.get(pLine.Access_Speed__c+Pline.VASA_Region__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                    pPricicng.PBI_Number__c = mapPriceMatrixEntryFeatureAccess.get(pLine.Access_Speed__c+Pline.VASA_Region__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                    pPricicng.product_name__c = mapPriceMatrixEntryFeatureAccess.get(pLine.Access_Speed__c+Pline.VASA_Region__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;
                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntryFeatureAccess.get(pLine.Access_Speed__c+Pline.VASA_Region__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;                                                              
                                    if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE){
                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                      }else if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                                      }
                                     }
                                   
                                     pPricicng.list_price__c = accessTotalFee;
                                     pPricicng.Product_Detail__c = pLine.Apttus_QPConfig__ChargeType__c;
                                     pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c); 
                                         
                                     pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Access').getRecordTypeId();
                                    
                                     pPricingList.add(pPricicng);
                                     
                                   
                                 }
                               // Logic for DNS Fee
                                else if((pLine.Apttus_QPConfig__ChargeType__c!='Hi-Cap Flex' || pLine.Apttus_QPConfig__ChargeType__c != 'One Time Fee' || pLine.Apttus_QPConfig__ChargeType__c!='Plus Port (Managed)') && !isCombinationCreated){
                                        if(pLine.Apttus_QPConfig__ChargeType__c=='Additional DNS Fee'){
                                       
                                            if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.Additional_DNS__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null) 
                                               if(mapPriceMatrixEntry.get(pLine.Additional_DNS__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c!=null && mapPriceMatrixEntry.get(pLine.Additional_DNS__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c!=null && mapPriceMatrixEntry.get(pLine.Additional_DNS__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c!=null){
                                                    pPricicng.Determinant_Set_ID__c =mapPriceMatrixEntry.get(pLine.Additional_DNS__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                                    pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.Additional_DNS__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.Additional_DNS__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.Additional_DNS__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;
                                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(pLine.Additional_DNS__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                                    if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE){
                                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                                    }else if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                                                    }
                                                    pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);            
                                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                                    pPricingList.add(pPricicng);
                                               }
                                          }
                                       else if(pLine.Apttus_QPConfig__ChargeType__c=='VTN Fee'){
                                       
                                            if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null) {
                                               
                                                    pPricicng.Determinant_Set_ID__c =mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                                    pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;
                                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                                    if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE){
                                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                                    }else if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                                                    }
                                                    pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);            
                                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                                    pPricingList.add(pPricicng);
                                               }
                                          }
                                         else if(pLine.Apttus_QPConfig__ChargeType__c=='VoIP'){
                                       
                                            if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.Voip__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null) {
                                               
                                                    pPricicng.Determinant_Set_ID__c =mapPriceMatrixEntry.get(pLine.Voip__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                                    pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.Voip__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.Voip__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.Voip__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;
                                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(pLine.Voip__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                                    if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE){
                                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                                    }else if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                                                    }
                                                    pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);            
                                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                                    pPricingList.add(pPricicng);
                                               
                                            }
                                          }
                                          else if(pLine.Apttus_QPConfig__ChargeType__c=='Setup Fee'){
                                           if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null) {
                                               //if(mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c!=null && mapPriceMatrixEntry.get(pLine.Additional_DNS__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c!=null && mapPriceMatrixEntry.get(pLine.Additional_DNS__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c!=null)
                                                    pPricicng.Determinant_Set_ID__c =mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                                    pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;
                                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                                    if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE){
                                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                                    }else if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                                                    }
                                                    pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);            
                                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                                    pPricicng.Discountable__c=true;
                                                    pPricingList.add(pPricicng);
                                               }
                                          }
                                          
                                          else if(pLine.Apttus_QPConfig__ChargeType__c=='Enhanced Features'){
                                       
                                            if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null) {
                                                   pPricicng.Determinant_Set_ID__c =mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                                    pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;
                                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                                    if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE){
                                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                                    }else if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                                                    }
                                                    pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);            
                                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                                    pPricingList.add(pPricicng);
                                               }
                                          }
                                          else if(pLine.Apttus_QPConfig__ChargeType__c=='IP Flex Reach Plan'){
                                       
                                            if(!mapPriceMatrixEntry.isEmpty() && mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name)!=null) {
                                               
                                                    pPricicng.Determinant_Set_ID__c =mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Determinant_Set_Id__c;
                                                    pPricicng.BEID__c =  mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BEID__c;
                                                    pPricicng.PBI_Number__c = mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).PBI_Number__c;
                                                    pPricicng.product_name__c = mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).BillDisplayName__c;
                                                    pPricicng.Low_Level_Tier__c = mapPriceMatrixEntry.get(pLine.Ip_Flex_Reach_Plan__c+pLine.Apttus_QPConfig__PriceListItemId__r.Name).Low_Level__c;
                                                    if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE){
                                                        pPricicng.type__c = ATT_Constant.MRCTYPE;
                                                    }else if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                                        pPricicng.type__c = ATT_Constant.NRCTYPE;
                                                    }
                                                    pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                                    pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);            
                                                    pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                                    pPricingList.add(pPricicng);
                                               }
                                          }
                                          
                                          
                                    }
                                   
                        
                            }
                        }
                    }
                    system.debug('PRLST'+pPricingList);
                    insert pPricingList;
                }
                
            }catch(Exception e){
                system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
                ATTException.createException('Error in ApttusServiceUtilityHelper.createSPProductsForQuotes', e.getTypeName(), ATTException.constructExceptionMessageString(e));             
            }
        }
     
    }