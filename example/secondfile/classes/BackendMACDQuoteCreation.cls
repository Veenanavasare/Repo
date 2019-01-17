/**************************************************************************************************************** 
   Component Name: BackendMACDQuoteCreation 
   Description: Create Quote and Other Chaild Records for Back End MACD Process
   Creation By: Accenture IDC
   Created Date : 19th August 2015          
   Version:1.0
   Last Modified By:21st August 2015
**************************************************************************************************************** */
public  class BackendMACDQuoteCreation { 
    
    Public String soql {get;set;}
    Public string quoteId {get;set;}
    Public boolean redirect;
    
    /*
     * BackendMACDQuoteCreation Constructor
    */
    public BackendMACDQuoteCreation () {
     // Constuctor 
    }
    
    /*
     This method is for creating Quote from Backend MACD's.
    
    */    
    public  static void createquote(Set<Id> selectedPremiseIds) {
     Apttus_Proposal__Proposal__c quoteName ;
     List<AT_T_Customer_Site_Quote__c> macdCustomerSiteList = new List<AT_T_Customer_Site_Quote__c>(); 
     List<Apttus_Config2__LineItem__c> macdLineItem = new List<Apttus_Config2__LineItem__c>();
     List<Apttus_Config2__TempObject__c> macdTempObj = new List<Apttus_Config2__TempObject__c>();
     List<Apttus_Config2__LineItem__c> cartLine= new List<Apttus_Config2__LineItem__c> ();
     ApttusServiceUtilityHelper helper = new ApttusServiceUtilityHelper();
     boolean redirect;
     //string MACDSelectedAction= action;
     List<SPProduct__c> spProducts = new List<SPProduct__c>();
     Set<String> premiseNumber= New Set<String>();
     Set<Id> dealHashID= New Set<ID>();
    
     List<Opportunity> oppty = new List<Opportunity>();
     Map<String,RDS_Validation__c> validationMap = new Map<String,RDS_Validation__c>();
     List<RDS_Validation__c> validationRecordList= New List<RDS_Validation__c>();
     List<Apttus_Proposal__Proposal__c> quoteIdvalue = new  List<Apttus_Proposal__Proposal__c>();
     List<RDS_Premise_Details__c> premiseList =[select id,RDS_Version__c,Service_Type__c,Customer_Project_Number__c,Site_Status__c,Premise_Number__c,DealHash__r.Opportunity__c,DealHash__r.id,DealHash__r.Term__c,DealHash__r.ServiceType__c,DealHash__r.Opportunity__r.Rate_Stability_Date__c from RDS_Premise_Details__c where id IN: selectedPremiseIds];
       for(RDS_Premise_Details__c prem:premiseList){
       premiseNumber.add(prem.Premise_Number__c);
       dealHashId.add(prem.DealHash__r.id);
      }
      if(premiseNumber.size()>0 && dealHashId.size()>0){
         spProducts = [select lastmodifieddate, createddate, id,Site_ID__c, Deal__r.RDS_Deal_Hash__r.ID from SPProduct__c where Site_ID__c IN: premiseNumber AND Deal__r.RDS_Deal_Hash__r.ID IN : DealHashId order by createddate asc];
         Oppty= [select id,AccountId,End_Customer__c from Opportunity where id =: spProducts [0].Deal__c];
         quoteIdvalue = [select id,Apttus_Proposal__Opportunity__c,Apttus_QPConfig__PriceListId__c from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c =:spProducts[0].Deal__c];
         validationRecordList=[Select Id,Premise__c,MACD_Change_Type__c,Premise_Number__c,Port_Speed__c,MBC__c from RDS_Validation__c where Premise__r.ID IN:selectedPremiseIds and Premise_Number__c IN:premiseNumber];
          }
            
            /*************Validation Map Binding***************/
            if(validationRecordList.size()>0){ 
                for(RDS_Validation__c rdsval:validationRecordList){
                      validationMap.put(rdsval.Premise_Number__c,rdsval);
                }
            }
            /************Ends Here**********************/
            
            string quoteId=SpecialCharacterConstant.CONCAT;
            redirect = false;
            
            /******* Logic for Quote Creation/Cloning ***********/
            
            String custId = Oppty[0].End_Customer__c;
            Apttus_Proposal__Proposal__c apttusquote = new Apttus_Proposal__Proposal__c();
            if(String.isBlank(quoteId)) {
                apttusquote.Apttus_Proposal__ExpectedStartDate__c = system.today();
                apttusquote.Apttus_Proposal__ExpectedEndDate__c = system.today().addmonths(6);
            }
            if(!String.isBlank(custId)) {
                apttusquote.End_Customer__c = custId;
                apttusquote.Apttus_Proposal__Account__c = Oppty[0].AccountId;
               
                if(premiseList[0].DealHash__r.Term__c==BuyflowConstant.SIVARConst_36){
                  apttusquote.Apttus_Proposal__Payment_Term__c= BuyflowConstant.SIVARConst_3_SPACE_YEARS;
                }
                else if(premiseList[0].DealHash__r.Term__c==BuyflowConstant.SIVARConst_12){
               
                apttusquote.Apttus_Proposal__Payment_Term__c= BuyflowConstant.SIVARConst_1YEAR;
                }
               
                apttusquote.Service_Type__c = premiseList[0].Service_Type__c;
                if(premiseList[0].Service_Type__c == BuyflowConstant.AVPN)
                {
             
                apttusquote.Product__c = Label.AVPN_Product_Id;
            
                }
                else if(premiseList[0].Service_Type__c == BuyflowConstant.MIS)
                {
                
                apttusquote.Product__c = Label.MIS_Product_Id;
               
                }
                if(Quoteidvalue.size() > 0 && Quoteidvalue != null){
                    apttusquote.RelatedQuote__c = Quoteidvalue[0].id;
                }
                apttusquote.MACD_Change_Type__c = MACDConstant.BACKENDMACD;
                apttusquote.Rate_Stability_Date__c = premiseList[0].DealHash__r.Opportunity__r.Rate_Stability_Date__c;
                apttusquote.MasterOpportunity__c = premiseList[0].DealHash__r.Opportunity__r.id;
                apttusquote.CaptureOpptyforMACD__c = Oppty[0].id;
                apttusquote.CaptureDealHashid__c = premiseList[0].DealHash__r.id;
                apttusquote.Apttus_QPConfig__PriceListId__c=Quoteidvalue[0].Apttus_QPConfig__PriceListId__c;
                
            }
            if(String.isBlank(quoteId)) {
                insert apttusquote;
                
                 quoteName = [select id,name,Apttus_Proposal__Proposal_Name__c  from Apttus_Proposal__Proposal__c where id=:apttusquote.id];
                 quoteName.Apttus_Proposal__Proposal_Name__c=quoteName.Name;
                 update quoteName;
                 
                 
                } 
            /*********Logic Ends Here **************************/
            
            /**********Cart Creation Logic **********************/    
            quoteId = apttusquote.Id;
            
            Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
            request.QuoteId =quoteId ;
            Apttus_CPQApi.CPQ.CreateCartResponseDO response = Apttus_CPQApi.CPQWebService.createCart(request);
            
            /********Logic ends here ***************************/
            
            /*********Logic for Site Cloning/Creation************/
            
            string cartId=response.CartId;
            redirect = true;
            Set<Id> siteIds= New Set<Id>();
            Map<String,AT_T_Customer_Site_Quote__c> mapJunctionSite= New Map<String,AT_T_Customer_Site_Quote__c>();
            
            if(premiseNumber.size()>0 && Quoteidvalue.size()>0){ 
                List<AT_T_Customer_Site_Quote__c> cSites = [SELECT id,AT_T_Quote__c,Site_ID__c,AT_T_Customer_Site__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c =:Quoteidvalue[0].id and Site_ID__c IN:premiseNumber];
            
            if(!CSites.isEmpty() && CSites!=null)
            {
                for(AT_T_Customer_Site_Quote__c CSite : CSites)
                {
                    String soqlOpty = API_Utils.getCreatableFieldsSOQL('AT_T_Customer_Site_Quote__c','id=\''+CSite.Id+'\'');     
                    AT_T_Customer_Site_Quote__c  cSiteOld = (AT_T_Customer_Site_Quote__c)Database.query(soqlOpty);
                    AT_T_Customer_Site_Quote__c  newCSiteOld = CSiteOld.clone(false,true,true,true);
                    newCSiteOld.AT_T_Customer_Site__c =CSiteOld.AT_T_Customer_Site__c;  
                    newCSiteOld.RDS_JSON_Request__c = CSiteOld.RDS_JSON_Request__c; 
                    newCSiteOld.AT_T_Quote__c = quoteId;
                    MACDCustomerSiteList.add(newCSiteOld);
                    siteIds.add(CSite.AT_T_Customer_Site__c);
                }
            }
            if(MACDCustomerSiteList.size()>0){  
                try{
                insert MACDCustomerSiteList;
                } catch(DMLException e){
                System.debug(BuyflowConstant.EXCEPTION_HERE+ e);
                }
              }
            }  
           
           for(AT_T_Customer_Site_Quote__c csite:MACDCustomerSiteList){
            mapJunctionSite.put(csite.AT_T_Customer_Site__c,csite);
           }
           /**********************Logic ends here**********************************************/
           
           /**********************Logic for Cart Line Items Creation ***********************/
            
           String status = BuyflowConstant.FINALIZED;
           if(siteIds!=null && Quoteidvalue.size()>0){
           List<Apttus_Config2__LineItem__c> pli = [SELECT id,AT_T_Customer_Site__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.id= : Quoteidvalue[0].id and Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c =:Status and AT_T_Customer_Site__c IN:siteIds];
          
            if(!pli.isEmpty())
            {
            for(Apttus_Config2__LineItem__c plir : pli)
             {
                String soqlline = API_Utils.getCreatableFieldsSOQL('Apttus_Config2__LineItem__c','id=\''+plir.Id+'\'');     
                Apttus_Config2__LineItem__c pl = (Apttus_Config2__LineItem__c)Database.query(soqlline);
                Apttus_Config2__LineItem__c newpl = pl.clone(false,true,true,true);
                newpl.Apttus_Config2__ConfigurationId__c= CartId;  
                
                MACDLineItem.add(newpl);
                
              }
            }
            if(MACDLineItem.size()>0){  
                try{
                insert MACDLineItem;
                } catch(DMLException e){
                    System.debug(BuyflowConstant.EXCEPTION_HERE+ e);
                }
             }   
            }
            /************************Logic Ends Here ***************************************/
            
            /************************Logic for Attribute Creation***************************/
            
            Set<Id> attributeIdsToClone = new Set<Id>();
                
                List <Apttus_Config2__LineItem__c> newLineItemList = [SELECT id, Apttus_Config2__LineNumber__c, Apttus_Config2__ItemSequence__c,Apttus_Config2__AttributeValueId__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.MACD_Change_Type__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Product_Name__c,Apttus_Config2__AttributeValueId__r.Hi_Cap_Flex__c,Apttus_Config2__ConfigurationId__c,Apttus_Config2__AttributeValueId__r.UBB_Speed_AVPN__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.id = :quoteId  and Apttus_Config2__ConfigurationId__c = :CartId ORDER BY Apttus_Config2__LineNumber__c, Apttus_Config2__ItemSequence__c];
                Map<id, List<Id>> attributeLineItemIdMap = new Map<id, List<Id>>();
                List<Id> listItemIds = new List<Id>();
                
                for (Apttus_Config2__LineItem__c item: newLineItemList )
                {
                    attributeIdsToClone.add(item.Apttus_Config2__AttributeValueId__c);
                   
                    if (!attributeLineItemIdMap.keyset().contains(item.Apttus_Config2__AttributeValueId__c))
                    {
                        listItemIds = new List<Id>();
                        listItemIds.add(item.Id);
                        attributeLineItemIdMap.put(item.Apttus_Config2__AttributeValueId__c, listItemIds);
                    }
                    else
                    {
                        attributeLineItemIdMap.get(item.Apttus_Config2__AttributeValueId__c).add(item.id);
                    }
                }
                
                List<Apttus_Config2__ProductAttributeValue__c> oldAttributeList = [SELECT UBB_Speed_AVPN__c,UBB_Speed_MIS__c,Access_Speed_AVPN__c,Access_Speed_MIS__c,Access_Type_AVPN__c,Access_Type_MIS__c,Access_Type__c,Additional_DNS__c,Apttus_Config2__Color__c,Apttus_Config2__IsTransient__c,Apttus_Config2__LineItemId__c,Apttus_Config2__Vendor__c,AT_T_Customer_Site__c,cartId__c,Consume_for_Use_Fan__c,CoS__c,
                                                                                   CreatedById,CreatedDate,Dynamic__c,End_Customer_FAN__c,First_Choice_AT_T_Data_Center__c,Hi_Cap_Flex__c,Id,Install_Option_AVPN__c,Install_Option_MIS__c,Interface_Type_AVPN__c,Interface_Type_MIS__c,Interface_Type__c,IsDeleted,LastActivityDate,
                                                                                   LastModifiedById,LastModifiedDate,Line_Number__c,Managed_Router__c,MileageAbove20__c,MileageAbove50__c,Mileage__c,Name,Policy_1_Local_Protection__c,Policy_2_Remote_Application__c,Port_Speed_AVPN__c,Port_Speed_MIS__c,Port_Speed__c,Port_Type_AVPN__c,Port_Type_MIS__c,Static__c,SystemModstamp,
                                                                                   traffic_jurisdiction__c,ProductName__c,VASA_Region__c,VLANs_Logical_Channels__c from Apttus_Config2__ProductAttributeValue__c where Id IN :attributeIdsToClone];
                
                List<Apttus_Config2__ProductAttributeValue__c> newAttributeList = new List<Apttus_Config2__ProductAttributeValue__c>();
                
                for ( Apttus_Config2__ProductAttributeValue__c attr : oldAttributeList ) 
                {
                    Apttus_Config2__ProductAttributeValue__c newAttr = new Apttus_Config2__ProductAttributeValue__c();
                    newAttr = attr.clone();
                    newAttr.Apttus_Config2__LineItemId__c = attributeLineItemIdMap.get(attr.Id)[0];
                                       
                    newAttributeList.add(newAttr);
                }
                if(newAttributeList.size() >0)
                {
                    insert newAttributeList;
                }
                // Associate Premise Number/Site ID on the Attribute Record 
                for(Apttus_Config2__ProductAttributeValue__c att : newAttributeList){
                 for (AT_T_Customer_Site_Quote__c csite:MACDCustomerSiteList){
                       if(att.AT_T_Customer_Site__c== csite.AT_T_Customer_Site__c){
                         att.SiteId__c=mapJunctionSite.get(att.AT_T_Customer_Site__c).Site_ID__c;
                         break;
                       }
                  }
                }
                update newAttributeList;
                
                
                // Update Line Item to refer the newly created Attribute Records 
                for( Apttus_Config2__LineItem__c lineItem : MACDLineItem)
                {
                    for ( Apttus_Config2__ProductAttributeValue__c att : newAttributeList)
                    {
                        if (lineItem.Apttus_Config2__LineNumber__c == att.Line_Number__c)
                        {
                            lineItem.Apttus_Config2__AttributeValueId__c = att.Id;
                            break;
                        }
                    }
                }
                update MACDLineItem;
                List<Integer> lineNumberList= New List<Integer>();
                Boolean uBBChange= False;
                Boolean portChange= False;
                for(Apttus_Config2__ProductAttributeValue__c att : newAttributeList){
                   lineNumberList.add(Integer.valueof(att.Line_Number__c));
                    for(RDS_Validation__c rdsval:validationRecordList){
                       if(rdsval.Premise_Number__c==att.SiteId__c){
                          
                          rdsval.RelatedQuote__c=quoteName.Id;
                          rdsval.Related_quote__c=quoteId;
                          if(BuyflowConstant.UBBADD == rdsval.MACD_Change_Type__c || BuyflowConstant.UBBCHANGE == rdsval.MACD_Change_Type__c){
                            att.Hi_Cap_Flex__c=true;
                            UBBChange=true;
                          if(att.ProductName__c==BuyflowConstant.AMIS){ 
                             att.UBB_Speed_MIS__c=rdsval.MBC__c+BuyflowConstant.MBPS;
                             }else if (att.ProductName__c==BuyflowConstant.AVPN){
                             att.UBB_Speed_AVPN__c =rdsval.MBC__c+BuyflowConstant.MBPS;
                             }
                          }else if(rdsval.MACD_Change_Type__c==BuyflowConstant.UBBREMOVE){
                          UBBChange=true;
                           att.Hi_Cap_Flex__c=false;
                           if(att.ProductName__c==BuyflowConstant.AMIS){ 
                             att.UBB_Speed_MIS__c=SpecialCharacterConstant.CONCAT;
                             }else if (att.ProductName__c==BuyflowConstant.AVPN){
                             att.UBB_Speed_AVPN__c =SpecialCharacterConstant.CONCAT;
                             }
                           }else if(rdsval.MACD_Change_Type__c==BuyflowConstant.PORTSPEED_CHANGE){
                             PortChange=true;
                             if(att.ProductName__c==BuyflowConstant.AMIS){ 
                                 att.Port_Speed_MIS__c=rdsval.Port_Speed__c+BuyflowConstant.MBPS;
                               }else if (att.ProductName__c==BuyflowConstant.AVPN){
                                 att.Port_Speed_AVPN__c=rdsval.Port_Speed__c+BuyflowConstant.MBPS;
                             }
                           }
                         break;
                       }
                  }
                }
                update newAttributeList;
                Update validationRecordList;
            
            // Initiate Pricing Call    
            if(UBBChange || PortChange)
            {  
             if(!Test.isRunningTest()){
                 ID batchprocessid = database.executeBatch(new ApplyPricesForBulkSitesMACD(lineNumberList,CartId),1);
             }
            } else {
            
            Apttus_CPQApi.CPQ.FinalizeCartRequestDO request2 = new Apttus_CPQApi.CPQ.FinalizeCartRequestDO();
            Request2.CartId = cartId;
            Apttus_CPQApi.CPQ.FinalizeCartResponseDO result2 = Apttus_CPQApi.CPQWebService.finalizeCart(request2);   
           } 
           
            /***********************************Logic ends here******************************/
	}      
}