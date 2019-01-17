public class AIACOUP {
    
    public static Boolean executeAIAOnce = false; 
  

    public static void createSPProductsForQuotes(Set<Id> qList, List<SPProduct__c> spProductList, List<AT_T_Customer_Site_Quote__c> cJunSiteList, List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItem, List<Product_Mapping__c> prodMapList){
        List<Apttus_Proposal__Proposal__c> quoteLst = new List<Apttus_Proposal__Proposal__c>();
        Map<String,List<Apttus_Proposal__Proposal_Line_Item__c> > mapProposalLineItem = new Map<String,List<Apttus_Proposal__Proposal_Line_Item__c> >();
        boolean isSuccess = false;
        executeAIAOnce = true;
        try{
            Double listPrice = 0.0;
            
            Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>> quoteLineItemMap = new Map<String,List<Apttus_Proposal__Proposal_Line_Item__c>>();
            
            Boolean isVLAN = false;
            
            // Creating map based on the site .
            // Map for identifer such as VLAN, COS and Port Type.
            
            for(Apttus_Proposal__Proposal_Line_Item__c p : proposalLineItem){
                if(quoteLineItemMap.containskey(p.AT_T_Customer_Site__c)){
                    quoteLineItemMap.get(p.AT_T_Customer_Site__c).add(p);                   
                }else{
                    quoteLineItemMap.put(p.AT_T_Customer_Site__c,new List<Apttus_Proposal__Proposal_Line_Item__c>{p});
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
                    
                  
                   
                    
                    for(Apttus_Proposal__Proposal_Line_Item__c pLine : proposalList){ 
                        if (pLine.Apttus_QPConfig__OptionId__c != NULL && pLine.Option_Group__c != 'Access Type' && pLine.Option_Group__c != 'Port Type' && pLine.Option_Group__c != 'Interface Type'&& pLine.Option_Group__c != 'Installation Options')
                        {
                            System.debug('pLine ----- ' + pLine);
                            System.debug('siteSPProduct.get(prop.AT_T_Customer_Site__c) ----- ' + siteSPProduct.get(prop.AT_T_Customer_Site__c));
                            
                            Product_Pricing__c  pPricicng = new Product_Pricing__c();
                              pPricicng.Determinant_Set_ID__c = pLine.Apttus_QPConfig__PriceListItemId__r.Determinant_Set_Id__c;
                                pPricicng.BEID__c =  pLine.Apttus_QPConfig__PriceListItemId__r.BEID__c;
                                pPricicng.PBI_Number__c = String.valueOf(pLine.Apttus_QPConfig__PriceListItemId__r.PBIID__c);
                                pPricicng.product_name__c = pLine.Apttus_QPConfig__PriceListItemId__r.Bill_Display_Name__c; 
                                if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.PRICETYPE){
                                    pPricicng.type__c = ATT_Constant.MRCTYPE;
                                }else if(pline.Apttus_QPConfig__PriceType__c == ATT_Constant.ONETIMEPRICE){
                                    pPricicng.type__c = ATT_Constant.NRCTYPE;
                                }
                                pPricicng.list_price__c = pLine.Apttus_QPConfig__NetPrice__c;
                                pPricicng.SP_Product__c = siteSPProduct.get(prop.AT_T_Customer_Site__c);            
                                pPricicng.RecordTypeId = Schema.SObjectType.Product_Pricing__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
                                pPricingList.add(pPricicng);
                                System.debug('------- ELSE ---- ');
                                
                            
                            
                        }
                    }
                }
                System.debug('pPricingList ---- ' + pPricingList);
                insert pPricingList;
            }
            
        }catch(Exception e){
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in ApttusServiceUtilityHelper.createSPProductsForQuotes', e.getTypeName(), ATTException.constructExceptionMessageString(e));             
        }
    }
}