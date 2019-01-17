/*Name:SIATOMDealRegistrationApproval
Description:
*/
public class SIATOMDealRegistrationApproval
{
    public Id optyID{get;set;}    
    public Opportunity Opty{get;set;}
    public End_Customer__c endCust;
    public Boolean isCalculated=false;
    public Admin_Control__c adminControl{get;set;}
    public list <Opportunity> optyList = new list <Opportunity>();
    public set<ID> allOptyIds=new set<ID>();
    public list <SPProduct__c> spProductList = new list <SPProduct__c>();
    public list <Product_Pricing__c> pricingList = new list <Product_Pricing__c>();
    public Date newdate = Date.today().addmonths(6);
    
    public set <Id> discountedProdSet = new set <Id>();
    public set <Id> nonDiscountedProdSet = new set <Id>();
    public Double discountableListPrice{get;set;}
    public Double nonDiscountableListPrice{get;set;}
    public Double discountableOTCPrice{get;set;}
    public Double nonDiscountableOTCPrice{get;set;}
    public Boolean applyPromotion = false;
    private boolean isAutoDealApproval;
    public set<Id> optyIdPEJ = new set<Id>();
    public List<Apttus_Proposal__Proposal__c> proposalList{get;set;}
    public Apttus_Proposal__Proposal__c optyDecisionName {get;set;}
    public Boolean displayCategory3Details{get;set;}
    public String optyDecisionId ;
    
    /*
    Name: SIATOMDealRegistrationApproval
    */    
    public SIATOMDealRegistrationApproval(ApexPages.StandardController controller) 
    {
        displayCategory3Details = false;
        optyID=ApexPages.CurrentPage().getParameters().get('id');
        if(optyID!=null)
        {
            proposalList = New List<Apttus_Proposal__Proposal__c>();
            optyIdPEJ.add(optyID);
            Opty=[SELECT o.ID ,o.Account.Name,o.StageName,o.DealRegDecisionOpty__c,o.Auto_Deal_Registration_Rule_Applied__c,o.EndCustomerName__c,o.End_Customer__c,o.Service_type__c,o.X3rd_Party_Flag__c,o.AccountId,o.BroadBand_Product__c,o.MIS_Product__c,o.Cumulative_List_Price__c,o.Discount_Amount__c,o.OTC_Discount_Amount__c, o.Cumulative_OTC_Price__c, o.Cumulative_OTC_Discount_Price__c, o.Discounted_Price__c,o.Discounted_Percentage__c,o.Mobility__c,o.Custom_Deal_Reg_Percentage__c,o.Number_of_products__c, Auto_Deal_Registration__c FROM Opportunity o WHERE o.ID=:optyID];            
            proposalList=[Select Id,Apttus_Proposal__Opportunity__c,Product_Name__c,QuoteExpirationDate__c,Deal_Registration_Expire_Date__c,Apttus_Proposal__Opportunity__r.Id from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__r.Id=:optyID];
            opty.Custom_Deal_Reg_Percentage__c = 5;
            isAutoDealApproval = false;
            if(Opty.DealRegDecisionOpty__c != null){
                optyDecisionId = Opty.DealRegDecisionOpty__c;
            }
            optyDecisionName =[Select Id,Apttus_Proposal__Opportunity__c,EndCustomerName__c  from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__r.Id= :optyDecisionId limit 1];
             if(Opty.StageName == UtilityConstant.DEALREGISTRATION_REQUESTED && opty.Auto_Deal_Registration_Rule_Applied__c == UtilityConstant.DUPLICATEEC_AVPN_RULE || opty.Auto_Deal_Registration_Rule_Applied__c == UtilityConstant.DUPLICATEEC_MIS_RULE){
                  displayCategory3Details = true;    
            }
            
            setDiscountedPercentage();
            setList_OTCPrices(optyID);
        }
    }
    
  
    /*
      Name: SIATOMDealRegistrationApproval
      Description:To be used by external classes to auto approve 
    */    
    public SIATOMDealRegistrationApproval(id oppId) 
    {
        proposalList = New List<Apttus_Proposal__Proposal__c>();
        optyID = oppId;
        if(optyID!=null)
        {
            optyIdPEJ.add(optyID);
            Opty = [SELECT o.ID ,o.StageName,o.End_Customer__c,o.Service_type__c,o.X3rd_Party_Flag__c,o.AccountId,o.BroadBand_Product__c,o.MIS_Product__c,o.Cumulative_List_Price__c,o.Discount_Amount__c,o.OTC_Discount_Amount__c, o.Cumulative_OTC_Price__c, o.Cumulative_OTC_Discount_Price__c,Auto_Deal_Registration_Rule_Applied__c, o.Discounted_Price__c,o.Discounted_Percentage__c,o.Mobility__c,o.Custom_Deal_Reg_Percentage__c,o.Auto_Deal_Registration__c, o.MACD_Type__c FROM Opportunity o WHERE o.ID=:optyID];            
            
            proposalList = [Select Id,QuoteExpirationDate__c,Quote_Expiration_Date__c,Deal_Registration_Expire_Date__c,Apttus_Proposal__Opportunity__r.Id from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__r.Id=:optyID];
            system.debug('@@@@@@@opty' + opty);
            if((opty.Service_type__c != 'AVPN' && opty.Service_type__c != 'AMIS') || (string.isNotBlank(opty.MACD_Type__c))){
                opty.Custom_Deal_Reg_Percentage__c = 5;
            }
             if(opty.Service_type__c == UtilityConstant.ANIRA) {
                endCust = [SELECT Anira_Custom_Discount__c FROM End_Customer__c WHERE ID=:opty.End_Customer__c limit 1];
                if(endCust.Anira_Custom_Discount__c != null) {
                    opty.Custom_Deal_Reg_Percentage__c = endCust.Anira_Custom_Discount__c;
                }
            }
            
            if(opty.Auto_Deal_Registration__c && (opty.Service_type__c == UtilityConstant.AVPN || opty.Service_type__c == UtilityConstant.AMIS )) {
                 List<Promotion_Engine_Junction__c>  promoEngineRecordsWithFourthRank = [select Id,Promotion_Name__c, Discount_Percentage__c from Promotion_Engine_Junction__c where Eligible__c = true and Rank__c = 4 AND Opportunity__c =:optyID limit 1 ];
                
                
                if(promoEngineRecordsWithFourthRank.size() > 0) {
                    if(promoEngineRecordsWithFourthRank[0].Discount_Percentage__c != null) {
                      opty.Custom_Deal_Reg_Percentage__c = promoEngineRecordsWithFourthRank[0].Discount_Percentage__c;
                    }
                    
                }  
            }
            
            isAutoDealApproval = true;
            
            setDiscountedPercentage();
            setList_OTCPrices(optyID);
        }
    }
    
    /*
        Name:setDiscountedPercentage
        Description:Setting Discounted Percentage
    */  
    public void setDiscountedPercentage()
    {
        adminControl=[SELECT Discounted_Percentage__c,Mobility_Discunted_Percentage__c FROM Admin_Control__c Limit 1];
        try
        {
            if(Opty.Mobility__c == true)
            {
                Opty.Discounted_Percentage__c=Double.ValueOf(adminControl.Mobility_Discunted_Percentage__c);
                Opty.Standard_Discount_Percentage__c = Double.ValueOf(adminControl.Mobility_Discunted_Percentage__c);
            }
            else
            {
                Opty.Discounted_Percentage__c=Double.ValueOf(adminControl.Discounted_Percentage__c);
                Opty.Standard_Discount_Percentage__c = Double.ValueOf(adminControl.Discounted_Percentage__c);
            }
        }
        catch(Exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    
    /*
    Name:setList_OTCPrices
    Description:Setting values for Discountabel and Non-Discountabel List/OTC Prices
    */
    public void setList_OTCPrices(Id opID)
    {        
        discountableListPrice=0;
        nonDiscountableListPrice=0;
        discountableOTCPrice=0;
        nonDiscountableOTCPrice=0;
        AggregateResult[] groupedResults = [SELECT SUM(list_price__c) sumValue,Type__c,Discountable__c FROM Product_Pricing__c pr WHERE pr.SP_Product__c IN (SELECT Id FROM SPProduct__c WHERE Deal__c = :opID) GROUP BY Type__c, Discountable__c];
        try
        {
            if(!groupedResults.isEmpty() && groupedResults!=null)
            {
                for(AggregateResult agr: groupedResults)
                {
                    if(((agr.get(UtilityConstant.TYPE_C))==UtilityConstant.MRC) && ((agr.get(UtilityConstant.DISCOUNTABLE_C))==false))
                    {
                        discountableListPrice = Double.ValueOf(agr.get(UtilityConstant.SUMVALUE));
                    }
                    else if(((agr.get(UtilityConstant.TYPE_C))==UtilityConstant.MRC) && ((agr.get(UtilityConstant.DISCOUNTABLE_C))==true))
                    {
                        nonDiscountableListPrice = Double.ValueOf(agr.get(UtilityConstant.SUMVALUE));
                    }
                    else if(((agr.get(UtilityConstant.TYPE_C))==UtilityConstant.NRC) && ((agr.get(UtilityConstant.DISCOUNTABLE_C))==false))
                    {
                        discountableOTCPrice = Double.ValueOf(agr.get(UtilityConstant.SUMVALUE));
                    }
                    else if (((agr.get(UtilityConstant.TYPE_C))==UtilityConstant.NRC) && ((agr.get(UtilityConstant.DISCOUNTABLE_C))==true))
                    {
                        nonDiscountableOTCPrice = Double.ValueOf(agr.get(UtilityConstant.SUMVALUE));
                    }
                }
            }
        }
        catch(Exception e)
        {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }           
    }
    
    
    /*
    Name:calculateDiscounts
    Description:This function is to calculate the discount
    */
    public PageReference calculateDiscounts()
    {
        try{
            if(opty.Custom_Deal_Reg_Percentage__c != null)
            {
                    if(opty.Custom_Deal_Reg_Percentage__c < Opty.Discounted_Percentage__c || opty.Custom_Deal_Reg_Percentage__c > 50)
                    {
                        ApexPages.Message msg=new ApexPages.Message(ApexPages.Severity.Fatal,'Custom Discount Percentage should not be less than '+Opty.Discounted_Percentage__c+' or greater than 50');
                        //ApexPages.addMessage(msg);
                    }
            }
            else if( Opty.Discounted_Percentage__c < 0 && Opty.Discounted_Percentage__c > 100 )
            {
                ApexPages.Message msg=new ApexPages.Message(ApexPages.Severity.Fatal,'Discount Percentage should not be less than 1 / greater than 99 or / null');
                //ApexPages.addMessage(msg);
            }
                
                List<Promotion_Engine_Junction__c> promoEngineRecordsWithThirdRank = [select Id, Activation_Date__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c, Input_Field__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Opportunity__c from Promotion_Engine_Junction__c where Eligible__c = true and Rank__c = 3 AND Opportunity__c IN:optyIdPEJ order by Rank__c ];
                List<Promotion_Engine_Junction__c> promoEngineRecords = [select Id, Activation_Date__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c, Input_Field__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Opportunity__c from Promotion_Engine_Junction__c where Eligible__c = true and Opportunity__c IN:optyIdPEJ AND ID NOT IN:promoEngineRecordsWithThirdRank order by Rank__c ];
                
                Map<String, List<Promotion_Engine_Junction__c>> mapPERankedThirdGroupedByProduct = new Map<String, List<Promotion_Engine_Junction__c>>();
                for( Promotion_Engine_Junction__c peThirdItem :promoEngineRecordsWithThirdRank ){
                    
                    List<Promotion_Engine_Junction__c> tempList = new List<Promotion_Engine_Junction__c>();
                    for( Promotion_Engine_Junction__c peThirdItemIterable :promoEngineRecordsWithThirdRank ){
                        if( peThirdItem.Valid_For_Product__c == peThirdItemIterable.Valid_For_Product__c){
                                tempList.add( peThirdItemIterable );
                                mapPERankedThirdGroupedByProduct.put( peThirdItem.Valid_For_Product__c, tempList );
                        }   
                    }
                }  
                
                Map<Promotion_Engine_Junction__c, Decimal> mapPEFinalDiscount = new Map<Promotion_Engine_Junction__c, Decimal>();
                for(String eachProduct : mapPERankedThirdGroupedByProduct.keyset()){
                    Decimal discountPerc;
                    Integer loopCounter = 0;
                    Promotion_Engine_Junction__c promoJunciton = new Promotion_Engine_Junction__c();
                    for( Promotion_Engine_Junction__c PromoJuncitonItem : mapPERankedThirdGroupedByProduct.get( eachProduct ) ){
                        if( loopCounter == 0 ){
                            promoJunciton = PromoJuncitonItem;
                            discountPerc = PromoJuncitonItem.Discount_Percentage__c;
                        }else{
                            discountPerc += PromoJuncitonItem.Discount_Percentage__c; 
                        }
                        loopCounter++;
                    }
                    mapPEFinalDiscount.put(promoJunciton, discountPerc);
                }
                
                promoEngineRecords.addAll(mapPEFinalDiscount.keySet());
                list<Promotion_Engine_Junction__c> listFinalPromoRecords = [select Id, Activation_Date__c, BCC_Code__c, Criteria_Name__c, Currently_Active__c, Discount_Percentage__c,Expiration_Date__c, Operator__c, Input_Field__c,Promotion_Description__c,Promotion_Name__c,Rank__c,Valid_For_Product__c,Value__c,Opportunity__c from Promotion_Engine_Junction__c where Eligible__c = true and Id IN:promoEngineRecords order by Rank__c];
                list<Opportunity> selectedOptys = [select Id, Standard_Discount_Percentage__c, Deal_Reg_Discount_Percentage__c from Opportunity where Id =:optyID ];
                list<Product_Pricing__c> updatePPRecords = [SELECT Id,Deal_Id__c,Product_Record_Type__c,SP_Discount_Percentage__c,Type__c,Discountable__c,List_Price__c,discount_price__c,Discounted_Price__c, Record_Type__c,Usage_Charges__c,Discounted_Usage_Charge__c FROM Product_Pricing__c pr WHERE pr.SP_Product__c IN (SELECT Id FROM SPProduct__c WHERE Deal__c =:optyID) AND (Type__c= :SIConstants.TYPE_MRC OR Type__c= :SIConstants.TYPE_NRC OR Type__c= :SIConstants.TYPE_MUC)];
                if(opty.Custom_Deal_Reg_Percentage__c!=null)
                {
                    selectedOptys[0].Custom_Deal_Reg_Percentage__c = opty.Custom_Deal_Reg_Percentage__c;
                    selectedOptys[0].Standard_Discount_Percentage__c = null;
                }
                else
                {
                    selectedOptys[0].Standard_Discount_Percentage__c = opty.Standard_Discount_Percentage__c;
                    selectedOptys[0].Custom_Deal_Reg_Percentage__c = null;
                }
                for(Product_Pricing__c prodPric:updatePPRecords)
                {
                    prodPric.Discounted_Price__c=0;
                }
                if( updatePPRecords.size()>0 && listFinalPromoRecords.size()>0 )
                {
                    list<Product_Pricing__c> iteratePPRecords = SIHelper.calculatePromotionDiscountOnPP(selectedOptys, listFinalPromoRecords, updatePPRecords, mapPEFinalDiscount);
                    if(iteratePPRecords.size()>0)
                    {
                        integer mrcCounter = 0;
                        integer nrcCounter = 0;
                        decimal bufferDiscountedPrice = 0;
                        decimal bufferOTCDiscountedPrice = 0;
                        for( Product_Pricing__c ppRecords : iteratePPRecords )
                        {
                            if( ppRecords.type__c==UtilityConstant.MRC && ppRecords.Product_Record_Type__c!=UtilityConstant.USAGE )
                            {
                                if( mrcCounter == 0 )
                                {
                                    bufferDiscountedPrice = ppRecords.discounted_price__c;
                                    mrcCounter++;
                                }
                                else
                                {
                                    bufferDiscountedPrice = bufferDiscountedPrice + ppRecords.discounted_price__c;
                                }
                            }
                            else if( ppRecords.type__c==UtilityConstant.NRC && ppRecords.Product_Record_Type__c!=UtilityConstant.USAGE )
                            {
                                if( nrcCounter == 0 )
                                {
                                    bufferOTCDiscountedPrice = ppRecords.discounted_price__c;
                                    nrcCounter++;
                                }
                                else
                                {
                                    bufferOTCDiscountedPrice = bufferOTCDiscountedPrice + ppRecords.discounted_price__c;
                                }
                            }
                        }
                        //MRC
                        opty.Discounted_Price__c = bufferDiscountedPrice;
                        opty.Discount_Amount__c = (discountableListPrice + nonDiscountableListPrice) - opty.Discounted_Price__c;
                        //NRC
                         opty.Cumulative_OTC_Discount_Price__c = bufferOTCDiscountedPrice;
                         opty.OTC_Discount_Amount__c = (discountableOTCPrice + nonDiscountableListPrice) - opty.Cumulative_OTC_Discount_Price__c;
                        
                        
                           /*
                          ///// Logic starts
                            decimal spDiscountPercent;
                            decimal dealRegDiscountPercent;
                            Decimal spDiscount = 0.0;
                            decimal dealRegDiscount = 0.0;
                            decimal totalDiscount=0.00;
                            list<Promotion_Engine_Junction__c> promotions = [select id,Rank__c,Opportunity__c,Discount_Percentage__c from 
                                                             Promotion_Engine_Junction__c where Opportunity__c =: Opty.Id];
                            MACD_DiscountPricingHelper discountHelper= New MACD_DiscountPricingHelper();
                            system.debug('Promotions'+promotions);
                        
                            if(promotions != null && promotions.size() > 0){
                                    spDiscountPercent = discountHelper.getSpDiscPercentage(promotions);
                                    dealRegDiscountPercent = discountHelper.getDealRegDiscPercentage(promotions);
                            }
                            system.debug('SP'+spDiscountPercent+'DealREG'+dealRegDiscountPercent);
                            if(spDiscountPercent != 0.0){
                                    spDiscount = discountHelper.applyDiscount(discountableListPrice + nonDiscountableListPrice, spDiscountPercent);
                            }
                            decimal amountAfterSpDiscount = (discountableListPrice + nonDiscountableListPrice)- spDiscount;
                            if(dealRegDiscountPercent != 0.0){
                                dealRegDiscount = discountHelper.applyDiscount(amountAfterSpDiscount, dealRegDiscountPercent);
                            }
                           
                            dealRegDiscount = SIHelper.applyRound(dealRegDiscount);
                            totalDiscount=dealRegDiscount+spDiscount;
                                                     
                            opty.Discount_Amount__c=totalDiscount;
                            opty.Discounted_Price__c =  (discountableListPrice + nonDiscountableListPrice) -  opty.Discount_Amount__c;
                        
                        
                             //NRC
                           opty.Cumulative_OTC_Discount_Price__c = bufferOTCDiscountedPrice;
                           opty.OTC_Discount_Amount__c = (discountableOTCPrice + nonDiscountableListPrice) - opty.Cumulative_OTC_Discount_Price__c;
                           */
                        
                        
                        
                        //Commented above and wrote below as part of 1 cent defect fix

                       /* opty.Discount_Amount__c=  SIHelper.applyRound((((discountableListPrice + nonDiscountableListPrice)*opty.Custom_Deal_Reg_Percentage__c)/100));
                       opty.Discounted_Price__c = (discountableListPrice + nonDiscountableListPrice)-opty.Discount_Amount__c;
                        //NRC
                        opty.Cumulative_OTC_Discount_Price__c = bufferOTCDiscountedPrice;
                        opty.OTC_Discount_Amount__c = (discountableOTCPrice + nonDiscountableListPrice) - opty.Cumulative_OTC_Discount_Price__c;*/
                    }
                }
            }catch( Exception e )
            {
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        isCalculated=true;
        return null;
    }
    
    
    /*
    Name:dealApproveWithDiscount
    Description:This function should be called to Approve the Deal.
    */
    public PageReference dealApproveWithDiscount()
    {
        try{
            Decimal customDiscountPercentage;
            if(Opty.Custom_Deal_Reg_Percentage__c != null){
                customDiscountPercentage = Opty.Custom_Deal_Reg_Percentage__c;
            }
            if(isCalculated==true)
            {
                if(Opty.Number_of_Products__c != null && Opty.Number_of_Products__c >= 75){
                    system.debug('@@@Opty.Id'+Opty.Id);
                    ID batchProcessId = database.executeBatch(new ATOMDealRegApprovalBatchProcess(Opty.Id, true, isAutoDealApproval, customDiscountPercentage),1);
                    system.debug('@@@Batch Process Id'+batchProcessId);
                }
                else{
                   if (!Opty.X3rd_Party_Flag__c){
                        if(isAutoDealApproval){
                            Opty.StageName = SIConstants.OPTY_DEAL_Auto_Approved;
                        }else{
                            Opty.StageName = SIConstants.OPTY_DEAL_APPROVED;    
                        }
                   }
                   if(Opty.Custom_Deal_Reg_Percentage__c  != null)
                   {
                       Opty.Standard_Discount_Percentage__c = null;
                   }
                   list<Promotion_Engine_Junction__c> pejRank4 = new list<Promotion_Engine_Junction__c>();
                   pejRank4 = [select Id,Promotion_Name__c,Discount_Percentage__c from Promotion_Engine_Junction__c where Eligible__c = true and Rank__c = 4 and Opportunity__c =:opty.Id limit 1];
                   
                   opty.Apply_Promotions__c=true;
                   opty.Promo_Deal_Reg__c=SpecialCharacterConstant.TRUE_CAMEL_LITERAL;
                   opty.Deal_Reg_Approved__c = true; 
                   
                   update opty;
                   //proposalList[0].QuoteExpirationDate__c= proposalList[0].Deal_Registration_Expire_Date__c;
                   proposalList[0].QuoteExpirationDate__c= newdate;
                   update proposalList;
                   //SIConstants.isDealRegApproval =true;
                   
                   if(pejRank4.size()>0)
                   {
                        if(Opty.Custom_Deal_Reg_Percentage__c  != null)
                        {
                            pejRank4.get(0).Discount_Percentage__c = Opty.Custom_Deal_Reg_Percentage__c;
                        }
                        else
                        {
                            pejRank4.get(0).Discount_Percentage__c = Opty.Standard_Discount_Percentage__c;
                        }
                        update pejRank4;
                   }
                   if(opty.Service_type__c == UtilityConstant.ANIRA) {
                        list<End_Customer__c> endCust = new list<End_Customer__c>();
                        endCust = [SELECT Anira_Custom_Discount__c FROM End_Customer__c WHERE ID=:opty.End_Customer__c limit 1];
                        if(Opty.Custom_Deal_Reg_Percentage__c  != null) {
                            endCust.get(0).Anira_Custom_Discount__c = opty.Custom_Deal_Reg_Percentage__c;
                        }
                        if(endCust.size() > 0) {
                            update endCust;
                        }
                   }
               }
               PageReference dealPage=new PageReference('/'+optyID);
               dealPage.setRedirect(false);
               return dealPage;
            }
            else
            {
                    ApexPages.Message msg=new ApexPages.Message(ApexPages.Severity.FATAL,'Please click on calculate before Approving the deal ');
                    ApexPages.addMessage(msg);
                    return null;
            }
            
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }
    
    /*
        Name:dealApproveWithoutDiscount
        Description:This function should be called when Deal Approved without Discount.
    */
    public PageReference dealApproveWithoutDiscount()
    {
        try{   
            Decimal customDiscountPercentage;
            if(Opty.Custom_Deal_Reg_Percentage__c != null){
                customDiscountPercentage = Opty.Custom_Deal_Reg_Percentage__c;
            }
            if(Opty.Number_of_Products__c != null && Opty.Number_of_Products__c >= 75){
                system.debug('@@@Opty.Id'+Opty.Id);
                ID batchProcessId = database.executeBatch(new ATOMDealRegApprovalBatchProcess(Opty.Id, false, isAutoDealApproval, customDiscountPercentage),1);
                system.debug('@@@Batch Process Id'+batchProcessId);
            }
            else{     
                if (!Opty.X3rd_Party_Flag__c){
                    if(isAutoDealApproval){
                            Opty.StageName = SIConstants.OPTY_DEAL_Auto_Approved;
                        }else{
                            Opty.StageName = SIConstants.OPTY_DEAL_APPROVED;    
                        }
                }
                Opty.Discount_Amount__c = null;
                Opty.Discounted_Percentage__c = null;
                Opty.Custom_Deal_Reg_Percentage__c = null;
                Opty.Standard_Discount_Percentage__c =null;
                Opty.OTC_Discount_Amount__c = null;
                Opty.Discounted_Price__c =nonDiscountableListPrice+discountableListPrice;
                Opty.Cumulative_OTC_Discount_Price__c = nonDiscountableOTCPrice+discountableOTCPrice;
                opty.Apply_Promotions__c=true;
                opty.Promo_Deal_Reg__c=SpecialCharacterConstant.FALSE_CAMEL_LITERAL;
                opty.Deal_Reg_Approved__c = true; 
                update Opty;
                //proposalList[0].QuoteExpirationDate__c= proposalList[0].Deal_Registration_Expire_Date__c;
                proposalList[0].QuoteExpirationDate__c= newdate;
                update proposalList;
                SIConstants.isDealRegApproval =true;
            }
            PageReference dealPage=new PageReference('/'+optyID);
            dealPage.setRedirect(false);
            return dealPage;        
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }   
    
    /*
    Name:dealDenied
    Description:This function is called for Denying the Deal Registration.
    */
    
    public PageReference dealDenied()
    {
        try{       
            if (!Opty.X3rd_Party_Flag__c){
                Opty.StageName = SIConstants.PROD_DEAL_REG_DENY;
            }
            Opty.Discount_Amount__c = null;
            Opty.Discounted_Percentage__c = null;
            Opty.Custom_Deal_Reg_Percentage__c = null;
            Opty.Standard_Discount_Percentage__c =null;
            Opty.OTC_Discount_Amount__c = null;
            Opty.Cumulative_OTC_Discount_Price__c = null ;
            Opty.Discounted_Price__c = null ;
            update Opty;
            PageReference dealPage=new PageReference('/'+optyID);
            dealPage.setRedirect(false);
            return dealPage;   
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }
        
    /*
        Name:closeDealRegistrationPage
        Description:This function is to close the Deal Registration Page.
    */
    public pagereference closeDealRegistrationPage()
    {
        try{
            PageReference dealPage=new PageReference('/'+optyID);
            dealPage.setRedirect(false);
            return dealPage;
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }    
}