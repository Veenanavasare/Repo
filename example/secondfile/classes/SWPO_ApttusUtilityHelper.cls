/************************************************************************************** 
 Apex Class Name     : SWPO_ApttusUtilityHelper
 Version             : 1.0 
 Created Date        : 14 Oct 2014
 Function            : This class is a uitlity to handle Apttus deal registration
 Modification Log    :
* Developer               Date                   Description
* ----------------------------------------------------------------------------                 
* Md Khalid Munavar Ali            11/5/2014              Original Version
*************************************************************************************/
public with sharing class SWPO_ApttusUtilityHelper {
    
     /*********************************************************************
     * Method name  : addMainProdcut
     * Description  : adds main product to the quote.
     * Return Type  : String 
     * Parameter    : Apttus_CPQApi.CPQ.SelectedProductDO
     ***********************************************************************/ 
    public Apttus_CPQApi.CPQ.SelectedProductDO addMainProdcut(String parentId) {                     
        Apttus_CPQApi.CPQ.SelectedProductDO SelectedProduct = new Apttus_CPQApi.CPQ.SelectedProductDO();
        try
        {            
            SelectedProduct.ProductId = parentId;
            SelectedProduct.Quantity = 1;
            SelectedProduct.SellingTerm = 1;
            SelectedProduct.StartDate = Date.Today();
            SelectedProduct.EndDate = Date.Today() + 12;
            SelectedProduct.Comments = 'Added by Code';            
        }
        catch(Exception e)
        {
            system.debug('method addMultiProducts Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in ApttusServiceUtilityHelper.addMainProductsIntoBundle', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        } 
        return SelectedProduct;
    }
    /*********************************************************************
     * Method name  : addMainProdcut1
     * Description  : adds main product to the quote and create line numbers.
     * Return Type  : String,String 
     * Parameter    : List<Decimal>
     ***********************************************************************/    
    
    public List<Decimal>  addMainProdcut1(String parentId , String cartId) {
        List<Decimal> lineNumbersLst = new List<Decimal>();
        List <Apttus_CPQApi.CPQ.SelectedProductDO> selectedProdDOList = new List <Apttus_CPQApi.CPQ.SelectedProductDO>();
        Apttus_CPQApi.CPQ.SelectedProductDO selProdDO = null;
        try
        {
            Apttus_CPQApi.CPQ.SelectedProductDO SelectedProduct = new Apttus_CPQApi.CPQ.SelectedProductDO();
            SelectedProduct.ProductId = parentId;
            SelectedProduct.Quantity = 1;
            SelectedProduct.SellingTerm = 1;
            SelectedProduct.StartDate = Date.Today();
            SelectedProduct.EndDate = Date.Today() + 12;
            SelectedProduct.Comments = 'Added by Code';
            selectedProdDOList.add(SelectedProduct); 
            Apttus_CPQApi.CPQ.AddMultiProductRequestDO bundleReqDO = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO();
            bundleReqDO.cartID = cartId;
            bundleReqDO.SelectedProducts = selectedProdDOList;
            Apttus_CPQApi.CPQ.AddMultiProductResponseDO bundleRespDO = Apttus_CPQApi.CPQWebService.addMultiProducts(bundleReqDO);       
            lineNumbersLst = bundleRespDO.LineNumbers;
        }
        catch(Exception e)
        {
            system.debug('method addMultiProducts Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in ApttusServiceUtilityHelper.addMainProductsIntoBundle', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        } 
        return lineNumbersLst;
    }
    
    /*********************************************************************
     * Method name  : createBundle
     * Description  : creates bundle for the and quote
     * Parameter    : String,String 
     * Return Type  : Apttus_CPQApi.CPQ.SelectedOptionDO
     ***********************************************************************/    
    
    public Apttus_CPQApi.CPQ.SelectedOptionDO createBundle(String ComponentId, String ComponentProductId) {
        Apttus_CPQApi.CPQ.SelectedOptionDO SelectedOption = new Apttus_CPQApi.CPQ.SelectedOptionDO();
        SelectedOption.ComponentId = ComponentId;
        SelectedOption.ComponentProductId = ComponentProductId;                
        SelectedOption.Quantity = 1;
        SelectedOption.SellingTerm = 1;
        SelectedOption.StartDate = Date.Today();
        SelectedOption.EndDate = Date.Today() + 12;
        SelectedOption.Comments = 'Added by Code';
        return SelectedOption;
    }
    
    /*********************************************************************
     * Method name  : finalizeCart
     * Description  : finalizes the cart
     * Parameter    : String
     * Return Type  : boolean
     ***********************************************************************/    
    
    public boolean finalizeCart(String cartId) {
        Apttus_CPQApi.CPQ.FinalizeCartRequestDO finReq = new Apttus_CPQApi.CPQ.FinalizeCartRequestDO();
        finReq.CartId = cartId; 
        Apttus_CPQApi.CPQ.FinalizeCartResponseDO resp = Apttus_CPQApi.CPQWebService.finalizeCart(finReq);
        return true;
    }
    
    /*********************************************************************
     * Method name  : updateLineItemWithSite
     * Description  : upadate every line item with site address
     * Parameter    : Map<Integer,string>,id
     * Return Type  : void
     ***********************************************************************/    
    
    public void updateLineItemWithSite(Map<Integer,string> siteLinenumberMap,id quoteId){
        System.debug(siteLinenumberMap+'siteLinenumberMap-----quoteId--'+quoteId);
        List<Apttus_Config2__ProductConfiguration__c> propsalLineList = new List<Apttus_Config2__ProductConfiguration__c>();
        if(quoteId != null)
        propsalLineList = [Select a.Id, a.Apttus_QPConfig__Proposald__c, (Select Id, AT_T_Customer_Site__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c  From Apttus_Config2__LineItems__r) From Apttus_Config2__ProductConfiguration__c a where Apttus_QPConfig__Proposald__c = :quoteId];
        List<Apttus_Config2__LineItem__c> updatePropsalList = new List<Apttus_Config2__LineItem__c>();
        system.debug('propsalLineList In update Cus site***'+propsalLineList);        
        try
        {       
            if(propsalLineList.size()>0){
                for(Apttus_Config2__LineItem__c p : propsalLineList[0].Apttus_Config2__LineItems__r){
                    if(!String.isempty(siteLinenumberMap.get(Integer.valueOf(p.Apttus_Config2__LineNumber__c)))){
                        p.AT_T_Customer_Site__c = siteLinenumberMap.get(Integer.valueOf(p.Apttus_Config2__LineNumber__c));
                        updatePropsalList.add(p);
                    }
                }
                update updatePropsalList;
            }
        }
        catch(Exception e)
        {
            system.debug('  Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in ApttusServiceUtilityHelper.updateLineItemWithSite', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*********************************************************************
     * Method name  : computePrice
     * Description  : computes the pricing based on standard apttus functionality
     * Parameter    : string, integer
     * Return Type  : boolean
     ***********************************************************************/    
       
    public boolean computePrice(String cartId, Integer lineNumber){
        //RE-PRICE 
        Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO netRequest = null;
        Apttus_CPQApi.CPQ.ComputeNetPriceResponseDO res = null;
        boolean isSuccess = false;
        try{
            netRequest = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            netRequest.CartId = cartId;
            netRequest.LineNumber = Integer.valueof(lineNumber);
            res = Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(netRequest);
            isSuccess = res.IsSuccess;
        }catch(Exception e){
            system.debug('Method computePrice   Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in ApttusServiceUtilityHelper.computePrice', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return isSuccess;
    }
    
    /*********************************************************************
     * Method name  : updateLineItem
     * Description  : update line item prodcut attribute value
     * Parameter    : decimal, string, string, string
     * Return Type  : void
     ***********************************************************************/    
    
    public void updateLineItem(decimal LineNum, string interfaceType, string accessType, string QuoteId) {
        set<string> prodconfigId = new set<string>();
        list<Apttus_Config2__LineItem__c> lineItems = new list<Apttus_Config2__LineItem__c>();
        list<Apttus_Config2__LineItem__c> linesToUpdate = new list<Apttus_Config2__LineItem__c>();
        list<Apttus_Config2__ProductConfiguration__c> prodConfig = new list<Apttus_Config2__ProductConfiguration__c>();
        list<Apttus_Config2__ProductAttributeValue__c> prodattr = new list<Apttus_Config2__ProductAttributeValue__c>();
        list<string> lineId = new list<string>();  
        Set<string> linesToUpdateCheck = new Set<string>();   
        try
        {
            prodConfig = new list<Apttus_Config2__ProductConfiguration__c>([select id, Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =: QuoteId]);            
            if(prodConfig !=null)
            {
                for(Apttus_Config2__ProductConfiguration__c pc : prodConfig)
                    prodconfigId.add(pc.Id);
            }            
            if(prodConfigId != null)
                lineItems = [Select a.Apttus_Config2__LineNumber__c,a.Apttus_Config2__OptionGroupLabel__c, a.Apttus_Config2__ConfigurationId__c, a.Apttus_Config2__AttributeValueId__c, a.Access_Speed__c, a.AT_T_Customer_Site__c From Apttus_Config2__LineItem__c a where a.Apttus_Config2__ConfigurationId__c in :prodConfigId];
            
            if(lineItems != null)
            {
                for(Apttus_Config2__LineItem__c line: lineItems)
                {
                    if(line.Apttus_Config2__OptionGroupLabel__c == 'Access Speed' && line.Apttus_Config2__LineNumber__c == lineNum)
                    {                       
                        lineId.add(line.id);                        
                    }
                }                                      
               for(Apttus_Config2__ProductAttributeValue__c pattr: [select id, Apttus_Config2__LineItemId__c from Apttus_Config2__ProductAttributeValue__c where Apttus_Config2__LineItemId__c in :lineId])
               {
                   for(Apttus_Config2__LineItem__c li: lineItems)
                   {
                        if(li.id == pattr.Apttus_Config2__LineItemId__c)
                        {
                            li.Apttus_Config2__AttributeValueId__c = pattr.Id;
                             if(!linesToUpdateCheck.contains(li.id)){
                                 linesToUpdate.add(li);
                                 linesToUpdateCheck.add(li.id);
                                 pattr.Access_Type__c = accessType;
                                 pattr.Interface_Type__c = interfaceType;                                 
                                 prodattr.add(pattr);
                             }
                        }
                   }
               }
            }
            
            if(linesToUpdate != null)
            {
                system.debug('-------> line Item'+linesToUpdate);
                update linesToUpdate;
                update prodattr;
            }
        }
        catch(Exception e)
        {
            system.debug('Line number - > '+e.getLineNumber()+ '  Message - >'+ e.getMessage());
            ATTException.createException('Error in ApttusServiceUtilityHelper.updateLineItem', e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }   
    } 
}