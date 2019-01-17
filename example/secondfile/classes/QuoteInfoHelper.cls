/************************************************************************************** 
 Apex Class Name     : QuoteInfoHelper
 Version             : 1.0 
 Created Date        : 27 Oct 2014
 Function            : This class is a uitlity to handle Apttus deal registration
 Modification Log    :
* Developer               Date                   Description
* ----------------------------------------------------------------------------                 
* Serena Bhayani         10/14/2014              Original Version
* Gaurav Kumar                                      Modified
*************************************************************************************/
public with sharing class QuoteInfoHelper  
{   
    /***********
    * Method name : validateApply
    * Description : 
    * Return Type : boolean.
    * Parameters : QuoteProducts.SelectPricingWrap,String.
    ***********/
    public boolean validateApply(QuoteProducts.SelectPricingWrap prodSelectWrap, String siteName)
    {        
        List<ApexPages.Message> errormessages = new List<ApexPages.Message>();
        boolean flag = true;
        try{
            for(QuoteProducts.Productoption prodOpt :prodSelectWrap.optionsList)
            {
                if(prodOpt.minOptions >= 1 && ( prodOpt.selectedProduct == null || ATTConstants.DSELECT.equalsIgnoreCase(prodOpt.selectedProduct)))
                {
                    flag = false;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,prodOpt.Name+ATTConstants.CONFIG_SITE_ERROR_MSG+' ['+siteName+']');
                    errormessages.add(myMsg);
                }
                else if((prodOpt.Name == ATTConstants.INTERFACE_TYPE || prodOpt.Name == ATTConstants.ACCESS_TYPE) && ( prodOpt.selectedProduct == null || ATTConstants.DSELECT.equalsIgnoreCase(prodOpt.selectedProduct)) && (!ATTConstants.PRIVATELINE.equalsIgnoreCase(prodSelectWrap.portTypeName)))
                {
                    flag = false;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,prodOpt.Name+ATTConstants.CONFIG_SITE_ERROR_MSG+' ['+siteName+']');
                    errormessages.add(myMsg);
                }else if(prodOpt.Name == ATTConstants.ACCESS_SPEED && prodOpt.price == 0){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ATTConstants.CONFIG_SITE_PRICING_ERROR_MSG+' ['+siteName+']');
                    errormessages.add(myMsg);
                }
                
            }
            if(flag)
            {
                prodSelectWrap.isProcessed = false;
            }
            
            if(errormessages!=null && errormessages.size()>0)
            {            
                for(ApexPages.Message errormessage : errormessages){
                    ApexPages.addMessage(errormessage);
                }
            }
            
        }
        catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }        
        return flag;
    }
    
    /***********
    * Method name : validateAccessSpeedPrice
    * Description : 
    * Return Type : boolean.
    * Parameters : QuoteProducts.SelectPricingWrap,String.
    ***********/
    public boolean validateAccessSpeedPrice(QuoteProducts.SelectPricingWrap prodSelectWrap, String siteName){
        List<ApexPages.Message> errormessages = new List<ApexPages.Message>();
        boolean flag = true;
        Decimal tprice = 0;
        try{
            if(prodSelectWrap != null && prodSelectWrap.optionsList != null){                
                for(QuoteProducts.ProductOption tempVal: prodSelectWrap.optionsList){
                    tprice =  checkNull(tempVal.price);  
                    if(ATTConstants.ACCESS_SPEED.equalsIgnoreCase(tempVal.Name) && tprice == 0){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,tempVal.Name+ATTConstants.CONFIG_SITE_ERROR_MSG+' ['+siteName+']');
                        errormessages.add(myMsg);
                        flag = false;
                    } 
                } 
            }          
        }catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return flag;
    }
    
    /*Method to update Hub*/
    public void updateHub(string selectedsite ,list<QuoteProducts.cCustomerSite> custSite)
    {
        try{
            for(QuoteProducts.cCustomerSite c :custSite)
            {
                if(c.custSiteIns.Id == selectedsite)
                {
                    c.SiteConnectionType = BuyflowConstant.HUB;
                }else{
                    c.SiteConnectionType = BuyflowConstant.SPOKE;
                }
            }
        }catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*Method to update Hub in Junction*/
    public void updatehubinJunction(string quoteId,string selectedsite)
    {
        List<AT_T_Customer_Site_Quote__c> custSiteQuoteLst = [Select Id, Name,AT_T_Customer_Site__c,AT_T_Quote__c,Customer__c,AT_T_Quote__r.Product__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,AT_T_Quote__r.Name,AT_T_Quote__r.Apttus_Proposal__Payment_Term__c,AT_T_Quote__r.Apttus_QPConfig__PriceListId__c,AT_T_Quote__r.Product__r.Name from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=:quoteId];
        List<AT_T_Customer_Site_Quote__c> custSiteQuoteLstupdate = new List<AT_T_Customer_Site_Quote__c>();
        try{
            for(AT_T_Customer_Site_Quote__c qs :custSiteQuoteLst)
            {
                 if(qs.AT_T_Customer_Site__c == selectedsite)
                 {
                    qs.Hub__c = true;
                 }
                 else{
                    qs.Hub__c = false;
                 }
                 custSiteQuoteLstupdate.add(qs);
            }
            if(custSiteQuoteLstupdate != null){
                update custSiteQuoteLstupdate;
            }
        }catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*Method to do Hub and Spoke Validation*/
    public void hubAndSpokeCIRValidationNew(list<QuoteProducts.cCustomerSite> custSites,QuoteInfoController_ASE qi, string quoteid)
    {
        integer hubCir = 0;
        Integer spokeCir = 0;
        integer p2pCir1 = 0;
        integer p2pCir2 = 0;
        integer count = 0;
        String cartId = null;
        ApttusServiceUtilityHelper helper = new ApttusServiceUtilityHelper();
        List<ApexPages.Message> errormessages = new List<ApexPages.Message>();
        Apttus_Config2__ProductConfiguration__c prodConfig = null;
        try{
            prodConfig = retrieveExistingCartId(quoteId);
            if(prodConfig != null && (ATTConstants.SAVED.equalsIgnoreCase(prodConfig.Apttus_Config2__Status__c) || ATTConstants.FINALIZED.equalsIgnoreCase(prodConfig.Apttus_Config2__Status__c))){
                cartId = prodConfig.Id;
            }
            QuoteProducts.SelectPricingWrap sPWrapTemp = null;
            QuoteProducts.SelectPricingWrap sPWrapGlobal = null;
            for(QuoteProducts.cCustomerSite cs : custSites){
                sPWrapTemp = qi.sitePricingMap.get(cs.custSiteIns.Id);
                if(sPWrapTemp != null && sPWrapTemp.optionsList != null){
                    sPWrapGlobal = sPWrapTemp;
                }
                for(Apttus_Config2__LineItem__c p: prodConfig.Apttus_Config2__LineItems__r){
                    if(cs.custSiteIns.id == p.AT_T_Customer_Site__c){   
                        if(ATTConstants.CLASS_OF_SERVICE.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                            cs.CoS = p.Apttus_Config2__OptionId__c;
                            cs.COSVal = qi.COSValue.get(p.Apttus_Config2__OptionId__r.Name); 
                        }else if(ATTConstants.CIR.equalsIgnoreCase(p.Apttus_Config2__OptionGroupLabel__c)){
                            cs.CIRVal = p.Apttus_Config2__OptionId__r.Name; 
                            cs.CIRSelectedId = p.Apttus_Config2__OptionId__c;   
                        }
                    }
                }
                
            }
            for(QuoteProducts.cCustomerSite cc : custSites){ 
                if(prodConfig != null){
                    sPWrapTemp = qi.sitePricingMap.get(cc.custSiteIns.Id);
                    if(sPWrapTemp == null){
                        sPWrapTemp = sPWrapGlobal;
                    }
                    cc.CIRSubset = helper.getCIROption(sPWrapTemp.optionsList ,  cc.CIRSelectedId); 
                }
            }            
                    
            for(QuoteProducts.cCustomerSite cc : custSites){
                if(cc.SiteConnectionType == BuyflowConstant.HUB && cc.CIRVal != null){
                    String[] splitedHub = cc.CIRVal.split(SpecialCharacterConstant.BLANK);
                    hubCir = integer.Valueof(splitedHub [0]);
                }else if(cc.SiteConnectionType == BuyflowConstant.SPOKE && cc.CIRVal != null){
                    String[] splitedSpoke = cc.CIRVal.split(SpecialCharacterConstant.BLANK);
                    spokeCir += integer.Valueof(splitedSpoke [0]);
                }else if(cc.CIRVal != null){
                    String[] splitedP2P = cc.CIRVal.split(SpecialCharacterConstant.BLANK);
                    if(count == 0){
                        p2pCir1 = integer.valueOf(splitedP2P[0]);
                    }
                    else{
                        p2pCir2 = integer.valueOf(splitedP2P[0]);
                    }
                    count++;
                }
            }    
            
            if(hubCir < spokeCir){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,+'CIR for hub should be greater than the sum of CIR for all sites. Hub CIR is '+hubCir+' Mbps');
                errormessages.add(myMsg);
            }
            if(qi.SelectSiteHub == null && qi.typeConnection == true){
                qi.haserrors = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,+'Select a hub');
                errormessages.add(myMsg);   
            }
            if(errormessages!=null && errormessages.size()>0)
            {
                qi.haserrors = true;
                for(ApexPages.Message errormessage : errormessages){
                    ApexPages.addMessage(errormessage);
                }
            }else{
                qi.haserrors = false;
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*Method to do Hub and Spoke CIR Validation*/
    public void hubAndSpokeCIRValidation(list<QuoteProducts.cCustomerSite> custSites,QuoteInfoController_ASE qi)
    {
        integer hubCir = 0;
        Integer spokeCir = 0;
        integer p2pCir1 = 0;
        integer p2pCir2 = 0;
        integer count = 0;
        
        List<ApexPages.Message> errormessages = new List<ApexPages.Message>();
        try{
            for(QuoteProducts.cCustomerSite cc : custSites){
                if(cc.SiteConnectionType == BuyflowConstant.HUB){
                    String[] splitedHub = cc.CIRVal.split(SpecialCharacterConstant.BLANK);
                    hubCir = integer.Valueof(splitedHub [0]);
                }else if(cc.SiteConnectionType == BuyflowConstant.SPOKE){
                    String[] splitedSpoke = cc.CIRVal.split(SpecialCharacterConstant.BLANK);
                    spokeCir += integer.Valueof(splitedSpoke [0]);
                }else{
                    String[] splitedP2P = cc.CIRVal.split(SpecialCharacterConstant.BLANK);
                    if(count == 0){
                        p2pCir1 = integer.valueOf(splitedP2P[0]);
                    }
                    else{
                        p2pCir2 = integer.valueOf(splitedP2P[0]);
                    }
                    count++;
                }
            }            
            
            if(hubCir < spokeCir){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,+'CIR for hub should be greater than the sum of CIR for all sites. Hub CIR is '+hubCir+' Mbps');
                errormessages.add(myMsg);
            }
            if(p2pCir1 !=0 && p2pCir2 !=0 && p2pCir1 != p2pCir2){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,+'CIR for Point to Point connection should be the same for both the sites');
                errormessages.add(myMsg);
            }
            if(errormessages!=null && errormessages.size()>0)
            {
                qi.haserrors = true;
                for(ApexPages.Message errormessage : errormessages){
                    ApexPages.addMessage(errormessage);
                }
            }else{
                qi.haserrors = false;
            }
        }catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*Method to initialize parameters*/
    public void initialiseparam(pageReference page, SiteConfigureController con)
    {
        try{
            con.QuoteId = page.getParameters().get('quoteId');
        }catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
       
    /*Method to initialise parameters for ASE*/
    public void initialiseparamASE(pageReference page, QuoteInfoController_ASE con)
    {
        try{
            con.QuoteId = page.getParameters().get('quoteId');
        }catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
   /*  public void initialiseparamSiteConfigASE(pageReference page, SiteConfigureController_ASE con)
    {
        try{
            con.QuoteId = page.getParameters().get('quoteId');
        }catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    } */
    /***********
    * Method name : updateLineItem
    * Description : 
    * Return Type : void.
    * Parameters : decimal , string , QuoteProducts.SelectPricingWrap .
    ***********/
    public void updateLineItem(decimal LineNum, string QuoteId, QuoteProducts.SelectPricingWrap prodSelectWrap)
    {
        set<string> prodconfigId = new set<string>();
        list<Apttus_Config2__LineItem__c> lineItems = new list<Apttus_Config2__LineItem__c>();
        list<Apttus_Config2__ProductConfiguration__c> prodConfig = new list<Apttus_Config2__ProductConfiguration__c>([select id, Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =: QuoteId]);
        try{
            if(prodConfig !=null)
            {
                for(Apttus_Config2__ProductConfiguration__c pc : prodConfig){
                    prodconfigId.add(pc.Id);
                }
            }
            
            if(prodConfigId != null){
                lineItems = [Select a.Apttus_Config2__LineNumber__c,a.Apttus_Config2__OptionGroupLabel__c, Apttus_Config2__NetPrice__c, a.Apttus_Config2__ConfigurationId__c, Apttus_Config2__ChargeType__c, a.Apttus_Config2__AttributeValueId__c, a.Access_Speed__c, a.AT_T_Customer_Site__c From Apttus_Config2__LineItem__c a where a.Apttus_Config2__ConfigurationId__c in :prodConfigId];
            }
            if(lineItems != null)
            {
                for(Apttus_Config2__LineItem__c line: lineItems)
                {
                     for(QuoteProducts.Productoption prodOpt :prodSelectWrap.optionsList)
                    {
                        if(line.Apttus_Config2__OptionGroupLabel__c == prodOpt.name && line.Apttus_Config2__LineNumber__c == lineNum)
                        {
                            prodOpt.price = line.Apttus_Config2__NetPrice__c;
                        }
                    }
                }   
            }
        }catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    
    /***********
    * Method name : updateLineItem
    * Description : 
    * Return Type : void.
    * Parameters : decimal , string , QuoteProducts.SelectPricingWrap .
    ***********/
    public void updateLineItemPriceUI(Integer LineNum, string cartId, QuoteProducts.SelectPricingWrap prodSelectWrap)
    {
        List<Apttus_Config2__ProductConfiguration__c> propsalLineList = [Select a.Id,a.Apttus_QPConfig__Proposald__c,(select id,Apttus_Config2__ProductId__c,Apttus_Config2__NetPrice__c,Apttus_Config2__ListPrice__c,Apttus_Config2__ProductOptionId__c,Apttus_Config2__Description__c, Apttus_Config2__OptionGroupLabel__c,Apttus_Config2__LineNumber__c,Apttus_Config2__OptionId__r.Name,Apttus_Config2__ChargeType__c,Apttus_Config2__LineType__c  from Apttus_Config2__LineItems__r where Apttus_Config2__LineNumber__c=:LineNum) From Apttus_Config2__ProductConfiguration__c a where Apttus_Config2__ProductConfiguration__c.Id=:cartID order by createdDate desc limit 2000]; //removed 1/26/2015
        try{
            if(propsalLineList.size()>0 && propsalLineList[0].Apttus_Config2__LineItems__r.size()>0){
                for(QuoteProducts.Productoption prodOpt :prodSelectWrap.optionsList){
                    for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                        if(p.Apttus_Config2__OptionId__r.Name == prodOpt.name && (!BuyflowConstant.OPTIONS.equalsIgnoreCase(prodOpt.name)) && p.Apttus_Config2__LineNumber__c == lineNum){
                            prodOpt.price = p.Apttus_Config2__NetPrice__c;
                        }else if(p.Apttus_Config2__OptionGroupLabel__c == prodOpt.name && p.Apttus_Config2__LineNumber__c == lineNum && (!BuyflowConstant.OPTIONS.equalsIgnoreCase(prodOpt.name))){
                            prodOpt.price = p.Apttus_Config2__NetPrice__c;
                        }
                    }
                }
            }    
        }catch(exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }    
    }
    
    /***********
    * Method name : get latest grand total
    * Description : 
    * Return Type : Decimal
    * Parameters :  string , 
    ***********/
    public Decimal getGrandTotalForCartId(string cartId){
        Decimal grandTot = 0;
        try{
            List<Apttus_Config2__SummaryGroup__c> summaryGroupList = [select Apttus_Config2__ConfigurationId__c,Apttus_Config2__ChargeType__c ,Apttus_Config2__LineType__c,Apttus_Config2__NetPrice__c,Apttus_Config2__ExtendedPrice__c from Apttus_Config2__SummaryGroup__c where Apttus_Config2__ConfigurationId__c =:cartId AND Apttus_Config2__LineType__c =: ATTConstants.GRAND_TOTAL];
            for(Apttus_Config2__SummaryGroup__c sum : summaryGroupList){
                if  (sum.Apttus_Config2__LineType__c == ATTConstants.GRAND_TOTAL ){
                    grandTot = sum.Apttus_Config2__NetPrice__c.setscale(2);
                    break;
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return grandTot;            
    }
    
    /***********
    * Method name : isAllSiteProcessed
    * Description : 
    * Return Type : Boolean.
    * Parameters : List<QuoteProducts.cCustomerSite> .
    ***********/
    public Boolean isAllSiteProcessed(List<QuoteProducts.cCustomerSite> ListCustomerSite){
        boolean flag = false;
        try{
            for(QuoteProducts.cCustomerSite ccs : ListCustomerSite){
                if(!ccs.isProcessed){
                    flag = true;
                    break;
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return flag;
    }
    
    /***********
    * Method name : checkNull
    * Description : 
    * Return Type : Decimal.
    * Parameters : Decimal .
    ***********/
    public Decimal checkNull(Decimal num){
        try{
            if (num == null){ num = 0;}
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return num;
    }
    
    /***********
    * Method name : saveProductConfiguration
    * Description : 
    * Return Type : void.
    * Parameters : String .
    ***********/
    public void saveProductConfiguration(String cartId){
        list<Apttus_Config2__ProductConfiguration__c> prodConfigLst = null;
        try{
            prodConfigLst = [select id, Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where Id =: cartId and Apttus_Config2__Status__c =: ATTConstants.NE_W  Order By CreatedDate DESC LIMIT 1];
            if(prodConfigLst.size() > 0){
                Apttus_Config2__ProductConfiguration__c prodConfig = prodConfigLst[0];
                prodConfig.Apttus_Config2__Status__c = ATTConstants.SAVED;
                update prodConfigLst;
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /***********
    * Method name : validateAnyProductHasAlreadySelected
    * Description : 
    * Return Type : boolean.
    * Parameters : QuoteProducts.SelectPricingWrap .
    ***********/    
    public boolean validateAnyProductHasAlreadySelected(QuoteProducts.SelectPricingWrap prodSelectWrap)
    {
        boolean flag = false;   
        try{
                
            for(QuoteProducts.Productoption prodOpt :prodSelectWrap.optionsList){
                if(prodOpt.selectedProduct == null || prodOpt.selectedProduct == BuyflowConstant.SELECT1){
                   continue;
                }else{
                    flag = true;
                    break;
                }           
            }    
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }           
        return flag;
    }
    
    /***********
    * Method name : retrieveExistingCartId
    * Description : 
    * Return Type : Apttus_Config2__ProductConfiguration__c.
    * Parameters : String.
    ***********/
    public Apttus_Config2__ProductConfiguration__c retrieveExistingCartId(String quoteId){
        System.debug('@@sfdc Inside QuoteInfoHelper retrieveExistingCartId method------');
        String cartId = null;
        Apttus_Config2__ProductConfiguration__c prodConfig = null;
        list<Apttus_Config2__ProductConfiguration__c> prodConfigLst = null;
        list<Apttus_Config2__ProductConfiguration__c> prodConfigLstNew = null;
        List<String> statusList = new List<String>();
        ApttusServiceUtilityHelper helper = new ApttusServiceUtilityHelper();
        statusList.add(SpecialCharacterConstant.NEW_CAPS_LITERAL);
        statusList.add(BuyflowConstant.SAVED);
        statusList.add(BuyflowConstant.FINALIZED);
        try{
            prodConfigLst = [select id, Apttus_QPConfig__Proposald__c, Apttus_Config2__Status__c,(Select Id, isPricingApplied__c,Apttus_Config2__ChargeType__c, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__Description__c,Apttus_Config2__OptionGroupLabel__c,Apttus_Config2__LineType__c,Apttus_Config2__NetPrice__c,Apttus_Config2__OptionId__r.Name,Apttus_Config2__PricingStatus__c, Apttus_Config2__ProductOptionId__c,Apttus_Config2__AttributeValueId__c, Apttus_Config2__ListPrice__c, Apttus_Config2__Quantity__c,Apttus_Config2__PriceType__c  From Apttus_Config2__LineItems__r) from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =: quoteId AND  Apttus_Config2__Status__c IN: statusList order by CreatedDate desc];
            if(prodConfigLst.size() > 0){
                prodConfig = prodConfigLst[0];
                if(ATTConstants.FINALIZED.equalsIgnoreCase(prodConfig.Apttus_Config2__Status__c)){
                    cartId = helper.createCart(quoteId);
                    prodConfigLstNew = [select id, Apttus_QPConfig__Proposald__c, Apttus_Config2__Status__c,(Select Id,isPricingApplied__c, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__Description__c,Apttus_Config2__OptionGroupLabel__c,Apttus_Config2__LineType__c,Apttus_Config2__NetPrice__c,Apttus_Config2__OptionId__r.Name,Apttus_Config2__PricingStatus__c, Apttus_Config2__ProductOptionId__c,Apttus_Config2__AttributeValueId__c,Apttus_Config2__ChargeType__c, Apttus_Config2__ListPrice__c, Apttus_Config2__Quantity__c,Apttus_Config2__PriceType__c  From Apttus_Config2__LineItems__r) from Apttus_Config2__ProductConfiguration__c where Id =: cartId];
                    if(prodConfigLstNew.size() > 0){
                        prodConfig = prodConfigLstNew[0];
                    }
                }               
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return prodConfig;
    }
    
    /***********
    * Method name : retrieveExistingFinalizedCartId
    * Description : 
    * Return Type : Apttus_Config2__ProductConfiguration__c.
    * Parameters : String.
    ***********/
    public Apttus_Config2__ProductConfiguration__c retrieveExistingFinalizedCartId(String quoteId){
        String cartId = null;
        Apttus_Config2__ProductConfiguration__c prodConfig = null;
        list<Apttus_Config2__ProductConfiguration__c> prodConfigLst = null;
        list<Apttus_Config2__ProductConfiguration__c> prodConfigLstNew = null;
        List<String> statusList = new List<String>();
        ApttusServiceUtilityHelper helper = new ApttusServiceUtilityHelper();
        statusList.add(BuyflowConstant.FINALIZED);
        try{
            prodConfigLst = [select id, Apttus_QPConfig__Proposald__c, Apttus_Config2__Status__c,(Select Id,isPricingApplied__c, Apttus_Config2__ChargeType__c, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__Description__c,Apttus_Config2__OptionGroupLabel__c,Apttus_Config2__LineType__c,Apttus_Config2__NetPrice__c,Apttus_Config2__OptionId__r.Name,Apttus_Config2__PricingStatus__c, Apttus_Config2__ProductOptionId__c,Apttus_Config2__AttributeValueId__c, Apttus_Config2__ListPrice__c, Apttus_Config2__Quantity__c  From Apttus_Config2__LineItems__r) from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =: quoteId AND  Apttus_Config2__Status__c IN: statusList];
            if(prodConfigLst.size() > 0){
                prodConfig = prodConfigLst[0];
            }
        }catch(Exception e){
             ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return prodConfig;
    }
    
    /***********
    * Method name : setSelectedProductInOptionsList
    * Description : 
    * Return Type : boolean.
    * Parameters : List<QuoteProducts.Productoption> , String , String , Decimal  .
    ***********/
    public void setSelectedProductInOptionsList(List<QuoteProducts.Productoption> optionsList, String productType, String productId, Decimal price){
        try{
            for(QuoteProducts.Productoption optgrp: optionslist){
                if(optgrp.name!= null &&  BuyflowConstant.OPTIONS.equalsIgnoreCase(productType) && optgrp.productId == productId){
                  optgrp.selectedProduct = productId;
                  optgrp.isSelected = true;
                }else if(optgrp.name!= null && optgrp.name.equalsIgnoreCase(productType)){
                  optgrp.selectedProduct = productId;
                }
            }
        }catch(Exception e){
             ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }   
    
    /* 
     Name: getAllMajorProducts
     Description: 
     */ 
    public Set<String> getAllMajorProducts(String productId){
        try{
            Set<String> myproducts = new Set<String>();
            List<Apttus_Config2__ProductOptionGroup__c> optList = [SELECT Option_Group_Name__c FROM Apttus_Config2__ProductOptionGroup__c where Apttus_Config2__ProductId__c =: productId];
            if(optList.size()>0){
                for(Apttus_Config2__ProductOptionGroup__c po : optList ){
                    myproducts.add(po.Option_Group_Name__c);
                }
            }
            return myproducts;
        }catch(Exception e){
             ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
             return null;
        }
    }
    
    /* 
     Name: retrieveLineItemsForGivenSite
     Description: 
     */ 
    public List<QuoteProducts.Productoption> retrieveLineItemsForGivenSite(Apttus_Config2__ProductConfiguration__c prodConfig, String siteId, Map<String, String> siteLabelAttrMapTemp){
        List<QuoteProducts.Productoption> lineitemList = new List<QuoteProducts.Productoption>();
        QuoteProducts.Productoption op = null;
        try{
            for(Apttus_Config2__LineItem__c p: prodConfig.Apttus_Config2__LineItems__r){
                if(siteId == p.AT_T_Customer_Site__c && p.Apttus_Config2__OptionId__c != null && (p.Apttus_Config2__OptionGroupLabel__c != 'Installation Options' || p.Apttus_Config2__ProductId__c == ProductId__c.getValues('AMIS').Product_Id__c)){
                    op = new QuoteProducts.Productoption();
                    op.productId = p.Apttus_Config2__OptionId__c;
                    op.componentId = p.Apttus_Config2__ProductOptionId__c;
                    if(!String.isEmpty(p.Apttus_Config2__AttributeValueId__c)){
                        siteLabelAttrMapTemp.put(p.Apttus_Config2__OptionGroupLabel__c,p.Apttus_Config2__AttributeValueId__c);
                    }
                    lineitemList.add(op);
                }
            }
            return lineitemList;
        }catch(Exception e){
             ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
             return null;
        }
    }
    
    /* 
     Name: retrieveAnyPendingLineitem
     Description: 
    */     
    public Map<Integer, String> retrieveAnyPendingLineitem(Apttus_Config2__ProductConfiguration__c prodConfig){
        Map<Integer, String> siteLineMapTemp = new Map<Integer, String>();
        try{
            if(prodConfig!=null && prodConfig.Apttus_Config2__LineItems__r != null){
                for(Apttus_Config2__LineItem__c p: prodConfig.Apttus_Config2__LineItems__r){
                    if(!ATTConstants.COMPLETE.equalsIgnoreCase(p.Apttus_Config2__PricingStatus__c) && !String.isempty(p.AT_T_Customer_Site__c)){
                        siteLineMapTemp.put(p.Apttus_Config2__LineNumber__c.intValue(), p.AT_T_Customer_Site__c);
                        break;
                    }
                }
            }        
            return siteLineMapTemp;
        }catch(Exception e){
             ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
             return null;
        }
    }
    
    /***********
    * Method name : retrieveExistingProductConfigusingCartId
    * Description : 
    * Return Type : Apttus_Config2__ProductConfiguration__c.
    * Parameters : String.
    ***********/ 
    public Apttus_Config2__ProductConfiguration__c retrieveExistingProductConfigusingCartId(String cartId){
        Apttus_Config2__ProductConfiguration__c prodConfig = null;
        list<Apttus_Config2__ProductConfiguration__c> prodConfigLst = null;        
        try{
            prodConfigLst = [select id, Apttus_QPConfig__Proposald__c, Apttus_Config2__Status__c,(Select Id, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__Description__c,Apttus_Config2__OptionGroupLabel__c,Apttus_Config2__LineType__c,Apttus_Config2__NetPrice__c,Apttus_Config2__PricingStatus__c, Apttus_Config2__ProductOptionId__c,Apttus_Config2__AttributeValueId__c,Apttus_Config2__OptionId__r.Name  From Apttus_Config2__LineItems__r) from Apttus_Config2__ProductConfiguration__c where Id =: cartId];
            if(prodConfigLst.size() > 0){
                prodConfig = prodConfigLst[0];               
            }
        }catch(Exception e){
             ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return prodConfig;
    }
    
    /* 
     Name: getQuote
     Description: 
    */     
    public Apttus_Proposal__Proposal__c getQuote(String quoteId){
        Apttus_Proposal__Proposal__c quoteObj = null;
        try{
            if(quoteid != null){
                List<Apttus_Proposal__Proposal__c> qoList = [select Name,Product_Name__c , End_Customer__c, Apttus_Proposal__Account__c, End_Customer__r.Name, Apttus_Proposal__Proposal_Name__c,Product__c,Product__r.Name,Product__r.ProductCode,Apttus_Proposal__Payment_Term__c,Ethernet_Configuration__c,Apttus_Proposal__Approval_Stage__c,applyAllFlag__c, Traffic_Jurisdiction__c from Apttus_Proposal__Proposal__c where id = :quoteId];                                   
                if(qoList.size()>0){
                    quoteObj = qoList[0];
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return  quoteObj;       
    }
    
    /* 
     Name: updateByflowStep
     Description: 
     */ 
    public void updateByflowStep(String quoteId){
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
        try{
            quoteList = [select Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where id =:quoteId];                                   
            quoteList[0].Buyflow_Step__c = BuyflowConstant.REVIEWQUOTE;
            if(quoteList[0].Apttus_Proposal__Approval_Stage__c == BuyflowConstant.DEALREG_DENIED){
                quoteList[0].Apttus_Proposal__Approval_Stage__c = BuyflowConstant.DRAFT;
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        update quoteList;
    }
    
    /* 
     Name: getEVCList
     Description: 
     */ 
    public list<QuoteProducts.cCustomerSite> getEVCList(list<QuoteProducts.cCustomerSite> sitelist, string quoteId){    
        list<QuoteProducts.cCustomerSite> evcListTemp = new list<QuoteProducts.cCustomerSite>();
        Integer counter = 0;
        integer p2pCir1 = 0; // added for CIR issue
        integer p2pCir2 = 0; // added for CIR issue
        integer count = 0; // added for CIR issue
        String idforEVC; // added for CIR issue
        String idforEVC1; // added for CIR issue
        String idforEVC2; // added for CIR issue
        try{
            list<AT_T_Customer_Site_Quote__c> custSiteQuoteLst = [Select Id, Name,AT_T_Customer_Site__c,AT_T_Customer_Site__r.Site_Name__c,AT_T_Quote__c,AT_T_Quote__r.Product__c,AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,AT_T_Quote__r.Name,AT_T_Quote__r.Apttus_Proposal__Payment_Term__c,AT_T_Quote__r.Apttus_QPConfig__PriceListId__c,AT_T_Quote__r.Product__r.Name from AT_T_Customer_Site_Quote__c where AT_T_Quote__c=:quoteId];
            AT_T_Customer_Site_Quote__c HubSiteQuoteJunt = null;
            AT_T_Customer_Site_Quote__c EVCFrom= null; 
            AT_T_Customer_Site_Quote__c EVCTo= null;
            integer maxCos = 0;
            string cosAssign = null; 
                
            if(custSiteQuoteLst != null && custSiteQuoteLst.size() >0){
                for(QuoteProducts.cCustomerSite ccs :sitelist){
                    for(AT_T_Customer_Site_Quote__c custSiteQuote : custSiteQuoteLst){
                            if(ccs.SiteConnectionType == BuyflowConstant.HUB && ccs.custSiteIns.Id == custSiteQuote.AT_T_Customer_Site__c){
                                HubSiteQuoteJunt = custSiteQuote;
                            }
                     }
                                                                    // added for EVC CIR issue
                    if(ccs.CIRVal != null && ccs.SiteConnectionType == BuyflowConstant.P2P){
                        String[] splitedP2P = ccs.CIRVal.split(SpecialCharacterConstant.BLANK);
                        if(count == 0){
                            p2pCir1 = integer.valueOf(splitedP2P[0]);
                            idforEVC1 = ccs.custSiteIns.Id;
                            
                            }
                        else{
                            p2pCir2 = integer.valueOf(splitedP2P[0]);
                            idforEVC2 = ccs.custSiteIns.Id;
                            }
                           count++;   
                        }
                                                                    // end CIR Issue
                }
                                                    // added for EVC CIR issue
                if(p2pCir1 !=0 && p2pCir2 !=0 ){
                                if(p2pCir1 <= p2pCir2){
                                    idforEVC = idforEVC1;
                                }
                                else{
                                    idforEVC = idforEVC2;
                                }
                }
            }
            if(custSiteQuoteLst != null && custSiteQuoteLst.size() >0){
                for(QuoteProducts.cCustomerSite ccs :sitelist){
                    for(AT_T_Customer_Site_Quote__c custSiteQuote : custSiteQuoteLst){
                            if(ccs.SiteConnectionType == BuyflowConstant.SPOKE && ccs.custSiteIns.Id == custSiteQuote.AT_T_Customer_Site__c){
                                ccs.EVCfrom = HubSiteQuoteJunt;
                                ccs.EVCto = custSiteQuote;
                            }else if(ccs.SiteConnectionType == BuyflowConstant.P2P && ccs.custSiteIns.Id == custSiteQuote.AT_T_Customer_Site__c){
                                if(counter == 0){
                                    EVCfrom = custSiteQuote;  
                                }else{
                                    EVCto = custSiteQuote;
                                }
                                counter++;                       
                            }
                            if(maxCos <= ccs.COSVal){
                                maxCos = ccs.cosval;
                                cosassign = ccs.cos;
                            }
                     }
                     
                }
                          
                for(QuoteProducts.cCustomerSite ccs :sitelist){
                    ccs.cosval = maxCos;
                    ccs.cos = cosassign;
                }
            }
            if(custSiteQuoteLst != null && custSiteQuoteLst.size() >0){
                for(QuoteProducts.cCustomerSite ccs :sitelist){
                    if(ccs.SiteConnectionType == BuyflowConstant.P2P){
                        if(EVCfrom != null && EVCto != null){
                            ccs.EVCfrom = EVCfrom;
                            ccs.EVCto = EVCTO;
                        }
                    }
                }
                    
            }
            for(QuoteProducts.cCustomerSite ccs :sitelist){
                if(ccs.SiteConnectionType == BuyflowConstant.SPOKE){
                    evcListTemp.add(ccs);
                }
                else if(ccs.SiteConnectionType == BuyflowConstant.P2P && ccs.EVCfrom != null && ccs.EVCto != null && IdforEVC != null && ccs.custSiteIns.Id != null && ccs.custSiteIns.Id == IdforEVC){ //changed condition for CIR issue
                    evcListTemp.add(ccs);
                    break;
                     
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return evcListTemp;
    }

    /* 
     Name: removeExistingCart
     Description: 
    */    
    public void removeExistingCart(String quoteId){
        Apttus_Config2__ProductConfiguration__c prodConfig = null;
        list<Apttus_Config2__ProductConfiguration__c> prodConfigLst = null;
        List<String> statusList = new List<String>();
        statusList.add(SpecialCharacterConstant.NEW_CAPS_LITERAL);
        statusList.add(BuyflowConstant.DRAFT);
        try{
            prodConfigLst = [select id, Apttus_QPConfig__Proposald__c, Apttus_Config2__Status__c from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =: quoteId AND  Apttus_Config2__Status__c IN: statusList];
            if(prodConfigLst.size() > 0){
                delete  prodConfigLst;             
            }
        }catch(Exception e){
             ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /* 
     Name: removeSelectedProductOptionsUI
     Description: 
     */ 
    public void removeSelectedProductOptionsUI(QuoteProducts.SelectPricingWrap prodSelectWrap, String selectedProductName){
        try{
            for(QuoteProducts.Productoption prodOpt :prodSelectWrap.optionsList){
                if(selectedProductName.equalsIgnoreCase(prodOpt.Name)){
                    prodOpt.selectedProduct = null;
                    prodOpt.isSelected = false;
                    prodOpt.showListOption = false; 
                    prodOpt.showOption = false;
                    prodOpt.isSelected = false;
                    prodOpt.prodOptnsLst = null;
                    prodOpt.price = 0.0;
                    prodOpt.deletionRequired = true;
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    
    /* 
     Name: makeSelectedProductOptionsEmptyUI
     Description: 
     */ 
    public void makeSelectedProductOptionsEmptyUI(QuoteProducts.SelectPricingWrap prodSelectWrap, String selectedProductName){
        try{
            for(QuoteProducts.Productoption prodOpt :prodSelectWrap.optionsList){
                if(selectedProductName.equalsIgnoreCase(prodOpt.Name)){
                    prodOpt.selectedProduct = null;
                    prodOpt.isSelected = false;
                    prodOpt.deletionRequired = true;
                    prodOpt.price = 0.0;
                    break;
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /* 
     Name: resetPriceSelectedProductOptionsUI
     Description: 
     */ 
    public void resetPriceSelectedProductOptionsUI(QuoteProducts.SelectPricingWrap prodSelectWrap, String selectedProductName){
        try{
            for(QuoteProducts.Productoption prodOpt :prodSelectWrap.optionsList){
                if(selectedProductName.equalsIgnoreCase(prodOpt.Name)){
                    prodOpt.price = 0.0;
                    break;
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /* 
     Name: makeProductSelectedUI
     Description: 
     */ 
    public QuoteProducts.Productoption makeProductSelectedUI(QuoteProducts.SelectPricingWrap prodSelectWrap, String selectedProductName, String selectedProductId){
        QuoteProducts.Productoption selectedProduct = null;
        try{
            for(QuoteProducts.Productoption prodOpt :prodSelectWrap.optionsList){
                if(selectedProductName.equalsIgnoreCase(prodOpt.Name)){
                    prodOpt.selectedProduct = selectedProductId;
                    prodOpt.isSelected = true;
                    selectedProduct = prodOpt;
                    break;
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return selectedProduct;
    }
    
    /* 
     Name: createCoSOnRouterSelection
     Description: 
     */ 
    public QuoteProducts.ProductOption createCoSOnRouterSelection(QuoteProducts.SelectPricingWrap sPricingWrap, String selectedProductName){
        QuoteProducts.ProductOption selectedProduct = null;
        try{
            for(QuoteProducts.ProductOption prodOpt : sPricingWrap.optionsList){ 
                if(selectedProductName.equalsIgnoreCase(prodOpt.Name) && prodOpt.isSelected == false){
                    prodOpt.isSelected = true;
                    selectedProduct = prodOpt;
                    break;
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return selectedProduct;
    }    
    
    /* 
     Name: cleanUIOnPortChange
     Description: 
     */ 
    public void cleanUIOnPortChange(QuoteProducts.SelectPricingWrap prodSelectWrap){
        try{
            if(prodSelectWrap != null && prodSelectWrap.optionsList != null){
                for(QuoteProducts.Productoption prodOpt :prodSelectWrap.optionsList){
                    if((!BuyflowConstant.OPTIONS.equalsIgnoreCase(prodOpt.Name)) && (!ATTConstants.PORT_TYPE.equalsIgnoreCase(prodOpt.Name))){
                        prodOpt.selectedProduct = null;
                        prodOpt.showListOption = false; 
                        prodOpt.price = 0;
                    }
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /* 
     Name: cleanUIOnOptionChange
     Description: 
    */ 
    public void cleanUIOnOptionChange(QuoteProducts.SelectPricingWrap prodSelectWrap){
        try{
            for(QuoteProducts.Productoption prodOpt :prodSelectWrap.optionsList){
                if((!BuyflowConstant.OPTIONS.equalsIgnoreCase(prodOpt.Name))){
                    prodOpt.selectedProduct = null;
                    if(!ATTConstants.PORT_TYPE.equalsIgnoreCase(prodOpt.Name)){
                        prodOpt.showListOption = false; 
                    }
                    prodOpt.price = 0;
                }
            }
        }catch(Exception e){
             ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }    
    
    /*
     * Method name  : addAttributeToLineItem
     * Description  : This method will add attribute to existing line item
     * Return Type  : void
     * Parameter    : string - Cart Id
     */
    public void addAttributeToLineItem(String optionGroupLabel,String optionName, String quantity, String cartID, String operation, Decimal linenumber){
        String prodId = null;
        List<Apttus_Config2__LineItem__c> pecsList = new List<Apttus_Config2__LineItem__c>();
        try{
            List<Apttus_Config2__ProductConfiguration__c> propsalLineList = [select Id,Name,(Select Id,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__LineItem__c.Apttus_Config2__OptionId__r.Name,Apttus_Config2__Description__c,Apttus_Config2__OptionGroupLabel__c,Apttus_Config2__LineType__c,Apttus_Config2__NetPrice__c,Apttus_Config2__PricingStatus__c, Apttus_Config2__ProductOptionId__c,Apttus_Config2__AttributeValueId__c, Access_Speed__c,AT_T_Customer_Site__c,Port_Speed__c  From Apttus_Config2__LineItems__r where Apttus_Config2__OptionGroupLabel__c=:optionGroupLabel AND Apttus_Config2__LineItem__c.Apttus_Config2__OptionId__r.Name=:optionName) from Apttus_Config2__ProductConfiguration__c where Apttus_Config2__ProductConfiguration__c.Id=:cartID];
            if(propsalLineList.size()>0 && propsalLineList[0].Apttus_Config2__LineItems__r.size()>0){
                for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                    if(optionName.equalsIgnoreCase(p.Apttus_Config2__OptionId__r.Name) && p.Apttus_Config2__LineNumber__c == linenumber){
                        if(ATTConstants.DELETES.equalsIgnoreCase(operation)){
                            prodId = p.Apttus_Config2__AttributeValueId__c;
                        }
                        pecsList.add(p);
                    }
                }
            }
            if(pecsList != null && pecsList.size()>0){
                if(ATTConstants.ADD.equalsIgnoreCase(operation)){
                    //Creating the ProductAttributeValue object as per selected policy and adding it to the Line item
                    Apttus_Config2__ProductAttributeValue__c obj = new  Apttus_Config2__ProductAttributeValue__c();
                    if(ATTConstants.VLAN.equalsIgnoreCase(pecsList[0].Apttus_Config2__OptionId__r.Name)){
                        obj.Port_Speed__c = quantity;
                    }else if(ATTConstants.HI_CAP_FLEX.equalsIgnoreCase(pecsList[0].Apttus_Config2__OptionId__r.Name)){
                        obj.Hi_Cap_Flex__c = true;
                    }
                    obj.Apttus_Config2__LineItemId__c = pecsList[0].Id;
                    if(pecsList[0].Apttus_Config2__AttributeValueId__c != null){
                        If(obj.Port_Speed__c == pecsList[0].Port_Speed__c){
                            obj.Id = pecsList[0].Apttus_Config2__AttributeValueId__c;
                            update obj;
                        }else{
                            insert obj;//changed on 1/30/2015
                        }
                    }else{
                        insert obj; 
                    }
                    for(Apttus_Config2__LineItem__c pecsObj: pecsList){          
                       pecsObj.Apttus_Config2__AttributeValueId__c = obj.Id;  
                    }
                }
                update pecsList;
                if(ATTConstants.DELETES.equalsIgnoreCase(operation)){
                    if(!String.isempty(prodId)){
                        Apttus_Config2__ProductAttributeValue__c obj = new  Apttus_Config2__ProductAttributeValue__c();
                        obj.id = prodId;
                        if(ATTConstants.VLAN.equalsIgnoreCase(pecsList[0].Apttus_Config2__OptionId__r.Name)){
                            obj.Port_Speed__c = SpecialCharacterConstant.CONCAT;
                        }else if(ATTConstants.HI_CAP_FLEX.equalsIgnoreCase(pecsList[0].Apttus_Config2__OptionId__r.Name)){
                            obj.Hi_Cap_Flex__c = false;
                        }
                        update obj;
                    }
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /* 
     Name: addAttributeHiCapToAllLineItem
     Description: 
     */ 
     public void addAttributeHiCapToAllLineItem(Integer linNum, String cartID, boolean operation){
        List<Apttus_Config2__LineItem__c> pecsList = new List<Apttus_Config2__LineItem__c>();
        List<Apttus_Config2__ProductAttributeValue__c> acpsList = new List<Apttus_Config2__ProductAttributeValue__c>();
        Map<String, String> attkey = new map<String, String>();
        Set<Id> attIds = new Set<Id>();
        String emptyId = null;
        try{
            List<Apttus_Config2__ProductConfiguration__c> propsalLineList = [select Id,Name,(Select Id,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__LineItem__c.Apttus_Config2__OptionId__r.Name,Apttus_Config2__Description__c,Apttus_Config2__OptionGroupLabel__c,Apttus_Config2__LineType__c,Apttus_Config2__NetPrice__c,Apttus_Config2__PricingStatus__c, Apttus_Config2__ProductOptionId__c,Apttus_Config2__AttributeValueId__c, Access_Speed__c  From Apttus_Config2__LineItems__r where Apttus_Config2__LineNumber__c =: linNum) from Apttus_Config2__ProductConfiguration__c where Apttus_Config2__ProductConfiguration__c.Id=:cartID];
            if(propsalLineList.size()>0 && propsalLineList[0].Apttus_Config2__LineItems__r.size()>0){
                for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                    Apttus_Config2__ProductAttributeValue__c obj = new  Apttus_Config2__ProductAttributeValue__c();
                    if(p.Apttus_Config2__AttributeValueId__c != null){
                        obj.id = p.Apttus_Config2__AttributeValueId__c;
                    }
                    obj.Hi_Cap_Flex__c = operation;
                    obj.Apttus_Config2__LineItemId__c = p.Id;
                    if((obj.id == null) || (!attIds.contains(obj.id))){
                        acpsList.add(obj);
                        attIds.add(obj.Id);
                        if(obj.id != null){
                            emptyId =  obj.id;
                        }
                    }
                }
                if (acpsList!=NULL && acpsList.size()>0){
                    upsert acpsList;
                }
                for(Apttus_Config2__ProductAttributeValue__c acp : acpsList){
                    attkey.put(acp.Apttus_Config2__LineItemId__c, acp.Id);
                }
                for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                    p.Apttus_Config2__AttributeValueId__c = attkey.get(p.Id) == null ? emptyId : attkey.get(p.Id); 
                    pecsList.add(p);
                }
                update pecsList;
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
     }
     
     /***********
    * Method name : retrieveOptionIdsForDelete
    * Description : 
    * Return Type : List<String>
    * Parameters : String.
    ***********/
    public List<String> retrieveOptionIdsForDelete(String cartId, String optionLabel, Integer linenumber){
        Apttus_Config2__ProductConfiguration__c prodConfig = null;
        list<Apttus_Config2__ProductConfiguration__c> prodConfigLst = null; 
        List<String> deleteProductIds = new List<String>();       
        try{
            prodConfigLst = [select id, Apttus_QPConfig__Proposald__c, Apttus_Config2__Status__c,(Select Id, AT_T_Customer_Site__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__OptionGroupLabel__c, Apttus_Config2__ProductOptionId__c,Apttus_Config2__OptionId__r.Name  From Apttus_Config2__LineItems__r where Apttus_Config2__LineNumber__c = :linenumber AND Apttus_Config2__OptionGroupLabel__c =: optionLabel) from Apttus_Config2__ProductConfiguration__c where Id =: cartId];
            if(prodConfigLst.size() > 0){
                prodConfig = prodConfigLst[0]; 
                if(prodConfig != null && prodConfig.Apttus_Config2__LineItems__r != null){
                    for(Apttus_Config2__LineItem__c p: prodConfig.Apttus_Config2__LineItems__r){
                        deleteProductIds.add(p.Apttus_Config2__ProductOptionId__c);               
                    }
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return deleteProductIds;
    }
    
    /***********
    * Method name : filterInterfaceType
    * Description : to filter interface type on the basis of port speed selection.
    * Return Type : Set<String>
    * Parameters : String.
    ***********/
    public Set<String> filterInterfaceType(QuoteProducts.Productoption selectedProductIns){
        String prodName =  selectedProductIns.name;
        Set<String> prodIdToRemove = new Set<String>();
        try{
            if(prodName != null && !prodName.contains('T1') && Integer.valueof((prodName.split(' Mbps')[0]).trim()) > 100){
                ProductId__c prodIdIns = ProductId__c.getInstance('ELECTRICAL');
                prodIdToRemove.add(prodIdIns.Product_Id__c);
            }else if(prodName != null && !prodName.contains('T1') && Integer.valueof((prodName.split(' Mbps')[0]).trim()) <= 100){
                ProductId__c prodIdIns = ProductId__c.getInstance('OPTICALSX');
                prodIdToRemove.add(prodIdIns.Product_Id__c);
                ProductId__c prodIdIns2 = ProductId__c.getInstance('OPTICALLX');
                prodIdToRemove.add(prodIdIns2.Product_Id__c);
            }

        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return prodIdToRemove;
    }
    
     /***********
    * Method name : checkOptionFlagInOptionsList
    * Description : 
    * Return Type : QuoteProducts.FlagStatus.
    * Parameters : List<QuoteProducts.Productoption>
    ***********/
    public QuoteProducts.FlagStatus checkOptionFlagInOptionsList(List<QuoteProducts.Productoption> optionsList){
        try{
            QuoteProducts.FlagStatus fStatus = new QuoteProducts.FlagStatus();
            if(optionsList!= null){
                for(QuoteProducts.Productoption optgrp: optionslist){
                    if(ATTConstants.VLAN.equalsIgnoreCase(optgrp.name)){
                      fStatus.vlanChecked = optgrp.isSelected;
                    }else if(ATTConstants.MANAGED_ROUTER.equalsIgnoreCase(optgrp.name)){
                      fStatus.manageRouterChecked = optgrp.isSelected;
                    }else if(ATTConstants.HI_CAP_FLEX.equalsIgnoreCase(optgrp.name)){
                      fStatus.hicapChecked = optgrp.isSelected;
                    }
                }
            }
            return fStatus;
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
        
    }
}