/************************************************************************************** 
Apex Class Name     : QuoteInfoController
Version             : 1.0 
Created Date        : 12 Sep 2014
Function            : This class handles the configure sites functionality.
Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mayank Agarwal            9/12/2014              Original Version
* Kumar Gaurav             10/21/2014              
*************************************************************************************/
/* 
 Name: QuoteInfoController_Anira
 Type: Class 
 
 Description: 
 */ 
public with sharing class QuoteInfoController_Anira {

    public boolean userBeginQuote{get; set;}
    public Double grandTot {get;set;}
    public String quoteId{get;set;}
    public String prodName;
    public String pncBandwidthOldQuote;
    public Boolean Isfinalized {get;set;}
    public Boolean isDuplicated {get;set;}
    public String cartId{get;set;}
    public String optionalQuoteName {get;set;}
    transient String priceListId;
    
    public  String mainproductId{get;set;}    
    private List<Apttus_CPQApi.CPQ.ProductOptionGroupDO> productOptionList;
    private Map <String, Double> priceProdMap = new Map <String, Double>();
   // private Map <String, String> prodCompMap = new Map <String, String>();
    Set <String> setProdIds = new Set <String>();
    private ApttusServiceUtilityHelper helper;
    private QuoteInfoHelper Quotehelper;

    public String selectedCustomer{get;set;}
    public Apttus_Proposal__Proposal__c quoteObj{get;set;}
    public boolean haserrors {get;set;}
    public String existingVPNName {get;set;}
    public String pncBandwidth {get;set;}    
    public Integer noDevicesNeeded {get;set;}
    public Integer noUsersNeeded {get;set;}        
    public String recomBandwidth {get;set;}
    private List<Decimal> lineNumbersLst;
    public List <SelectOption> pncBandLstOptions {get; set;}
    public List <ProductOption> productOptionLst {get; set;}

    //constructor
    
/* 
 Name: QuoteInfoController_Anira
 Description: 
 */ 
    public QuoteInfoController_Anira(){
        User userObj;
        userObj = [select id, Begin_Quote__c from User where id = :UserInfo.getUserId()];
        userBeginQuote = userObj.Begin_Quote__c;
    }

/* 
 Name: handleConfigureProductRequest
 Description: 
 */ 
    public void handleConfigureProductRequest() {
        quoteId = ApexPages.currentPage().getParameters().get('quoteId');
        
        grandTot = 0;
        haserrors = false;
        helper = new ApttusServiceUtilityHelper();
        quoteHelper = new QuoteInfoHelper();
        try{
            List <Apttus_Proposal__Proposal__c> quoteLst = new List<Apttus_Proposal__Proposal__c>();
            if(quoteId != null && quoteId != SpecialCharacterConstant.CONCAT) {
                quoteLst = [select Id, Name, End_Customer__c, End_Customer__r.Name, Apttus_Proposal__Approval_Stage__c,Apttus_Proposal__Proposal_Name__c,Product__c, Product__r.Name, Product__r.ProductCode,Apttus_Proposal__Payment_Term__c,Ethernet_Configuration__c,Traffic_Jurisdiction__c,Apttus_QPConfig__PriceListId__c from Apttus_Proposal__Proposal__c where id = :quoteId];                
                quoteObj=quoteLst[0];  
                priceProdMap = new Map <String, Double>();
                List <Apttus_Config2__PriceListItem__c> priceLstItemsLst = [select Apttus_Config2__ProductId__c, Apttus_Config2__PriceListId__c, Apttus_Config2__ListPrice__c from Apttus_Config2__PriceListItem__c where Apttus_Config2__PriceListId__c=:quoteObj.Apttus_QPConfig__PriceListId__c];
                for (Apttus_Config2__PriceListItem__c pItem : priceLstItemsLst ) {
                    priceProdMap.put(pItem.Apttus_Config2__ProductId__c, pItem.Apttus_Config2__ListPrice__c); 
                }  
                optionalQuoteName = SpecialCharacterConstant.CONCAT;
                isDuplicated=false;
                if(ApexPages.currentPage().getParameters().get('duplicated') != null) {
                    isDuplicated=true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Your original quote '+quoteObj.Apttus_Proposal__Proposal_Name__c+' has been saved'));
                }    
                Apttus_Config2__ProductConfiguration__c prodConfig = quoteHelper.retrieveExistingCartId(quoteId); 
                if(prodConfig != null && (ATTConstants.SAVED.equalsIgnoreCase(prodConfig.Apttus_Config2__Status__c) || ATTConstants.FINALIZED.equalsIgnoreCase(prodConfig.Apttus_Config2__Status__c))){
                    cartId = prodConfig.Id;
                }                         
                if(!String.isempty(cartId)){
                    IntializeQuote(prodConfig);            
                }
                else {
                    cartId = helper.createCart(quoteId);
                    if (isDuplicated==true) {
                        InitializeUI();  
                    }                
                    lineNumbersLst = helper.addMainProductIntoBundle(null , quoteObj.Product__c , cartId);
                }    
                productOptionList = helper.getProductOptionGroupDO(quoteObj.Product__c , quoteObj.Apttus_QPConfig__PriceListId__c);
                /*
                */
                pncBandLstOptions = new List<SelectOption>();
                pncBandLstOptions.add(new SelectOption('','-None-'));
                productOptionLst= new List <ProductOption>();
                for(Apttus_CPQApi.CPQ.ProductOptionGroupDO optg :productOptionList){          
                    for(Apttus_CPQApi.CPQ.ProductOptionComponentDO optgcomp: optg.OptionComponents){
                        ProductOption obj = new ProductOption();
                        obj.ComponentProductId=optgcomp.ComponentProductId;
                        obj.ComponentId=optgcomp.ComponentId;
                        obj.Name=optgcomp.Name;
                        obj.Quantity=1;
                        obj.deletionRequired=false;
                        obj.isSelected=false;
                        productOptionLst.add(obj);
                        pncBandLstOptions.add(new SelectOption(optgcomp.ComponentProductId,optgcomp.Name));                    
                        setProdIds.add(optgcomp.ComponentProductId);
                    }                 
                }
                if (isDuplicated==true) {
                    pncBandwidth=pncBandwidthOldQuote;
                    calcBwdthPrice();
                }
            }                
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));


        }
    }    


/* 
 Name: calcBwdthPrice
 Description: 
 */ 
    public void calcBwdthPrice() {
        grandTot =0;
        grandTot = priceProdMap.get(pncBandwidth);  
    }
    
/* 
 Name: SaveandExit
 Description: 
 */ 
    public PageReference SaveandExit() {
        try {
            Decimal lineNumber=1;          
            ProductOption selectedProduct=helper.getSelectedProduct(productOptionLst, 'PNC Bandwidth', pncBandwidth);
            helper.createLineItem(quoteId, lineNumber.intValue(), 'PNC Bandwidth', cartId, selectedProduct); 
            List <Apttus_Config2__LineItem__c> lineItemsLsts = [Select a.Apttus_Config2__LineNumber__c, Apttus_Config2__Description__c,
                                                                    Apttus_Config2__OptionId__c, Apttus_Config2__ProductOptionId__c,
                                                                    Apttus_Config2__ProductId__c, a.Apttus_Config2__OptionGroupLabel__c, 
                                                                    Apttus_Config2__NetPrice__c, a.Apttus_Config2__ConfigurationId__c 
                                                                    From Apttus_Config2__LineItem__c a 
                                                                    where a.Apttus_Config2__ConfigurationId__c=:cartId];
            for(Apttus_Config2__LineItem__c p: lineItemsLsts) {
                if(p.Apttus_Config2__ProductOptionId__c==pncBandwidth){
                    lineNumber=p.Apttus_Config2__LineNumber__c;
                    break;
                }
            }
            boolean pricingFlag = helper.computePrice(cartId, lineNumber.intValue());    
            Isfinalized = helper.finalizeCart(cartId);
           // quotehelper.updateByflowStep(quoteId);
            boolean flag = false;
            Quotehelper.saveProductConfiguration(cartId);
            if (isDuplicated==true&&optionalQuoteName!=SpecialCharacterConstant.CONCAT) {
                quoteObj.Apttus_Proposal__Proposal_Name__c=optionalQuoteName;
            }     
            if (quoteObj.Apttus_Proposal__Approval_Stage__c!=MiscConstant.DRAFT) {
                quoteObj.Apttus_Proposal__Approval_Stage__c=MiscConstant.DRAFT;
            }           
            update quoteObj;
            boolean found = false;
            List <Apttus_Proposal__Proposal_Line_Item__c> lineLst = [Select Existing_AVPN_Name__c, No_Of_Soho_CPE_Devices__c, No_Of_Remote_Access_Users__c, Apttus_QPConfig__ProductOptionId__c, Apttus_QPConfig__OptionId__c, Apttus_QPConfig__ConfigurationId__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c=:quoteId];
            if (lineLst!=null) {
                for(Apttus_Proposal__Proposal_Line_Item__c p: lineLst ){
                    if(p.Apttus_QPConfig__ProductOptionId__c!=null) {
                        found=true;
                        p.Existing_AVPN_Name__c=existingVPNName;
                        p.No_Of_Soho_CPE_Devices__c=noDevicesNeeded;
                        p.No_Of_Remote_Access_Users__c=noUsersNeeded;
                        break;    
                    }                                         
                } 
                if(found==true) {
                    try {    
                        update lineLst;
                        
                    }
                    catch(Exception e){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                       
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));


                        return null;
                    }                            
                }
            }
            PageReference retPageRef = Page.PortalDashboard_UI;
            retPageRef.setRedirect(true);
            return retPageRef;
                
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
           
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));


            return null;
        }   
    }
    
/* 
 Name: finalizeCart
 Description: 
 */ 
    public void finalizeCart() {
        try{
            Decimal lineNumber=1;          
            ProductOption selectedProduct=helper.getSelectedProduct(productOptionLst, 'PNC Bandwidth', pncBandwidth);
            helper.createLineItem(quoteId, lineNumber.intValue(), 'PNC Bandwidth', cartId, selectedProduct); 
            List <Apttus_Config2__LineItem__c> lineItemsLsts = [Select a.Apttus_Config2__LineNumber__c, Apttus_Config2__Description__c, Apttus_Config2__OptionId__c, Apttus_Config2__ProductOptionId__c, Apttus_Config2__ProductId__c, a.Apttus_Config2__OptionGroupLabel__c, Apttus_Config2__NetPrice__c, a.Apttus_Config2__ConfigurationId__c From Apttus_Config2__LineItem__c a where a.Apttus_Config2__ConfigurationId__c=:cartId];
            for(Apttus_Config2__LineItem__c p: lineItemsLsts){
                if(p.Apttus_Config2__ProductOptionId__c==pncBandwidth){
                    lineNumber=p.Apttus_Config2__LineNumber__c;
                    break;
                }
            }
            boolean pricingFlag = helper.computePrice(cartId, lineNumber.intValue());    
            Isfinalized = helper.finalizeCart(cartId);
            //quotehelper.updateByflowStep(quoteId);
            quoteObj.Buyflow_Step__c = MiscConstant.REVIEWQUOTE;
            if (isDuplicated==true&&optionalQuoteName!=SpecialCharacterConstant.CONCAT) {
                quoteObj.Apttus_Proposal__Proposal_Name__c=optionalQuoteName;
            }          
            if (quoteObj.Apttus_Proposal__Approval_Stage__c!=MiscConstant.DRAFT) {
                quoteObj.Apttus_Proposal__Approval_Stage__c=MiscConstant.DRAFT;
            }          
                 
            update quoteObj;
            
            boolean found = false;
            List <Apttus_Proposal__Proposal_Line_Item__c> lineLst = [Select Existing_AVPN_Name__c, No_Of_Soho_CPE_Devices__c, 
                                                                        No_Of_Remote_Access_Users__c, Apttus_QPConfig__ProductOptionId__c, 
                                                                        Apttus_QPConfig__OptionId__c, Apttus_QPConfig__ConfigurationId__c 
                                                                        from Apttus_Proposal__Proposal_Line_Item__c 
                                                                        where Apttus_Proposal__Proposal__c=:quoteId];
            if (lineLst!=null) {
                for(Apttus_Proposal__Proposal_Line_Item__c p: lineLst ) {
                    if(p.Apttus_QPConfig__ProductOptionId__c!=null) {
                        found=true;
                        p.Existing_AVPN_Name__c=existingVPNName;
                        p.No_Of_Soho_CPE_Devices__c=noDevicesNeeded;
                        p.No_Of_Remote_Access_Users__c=noUsersNeeded;
                        break;    
                    }                                         
                } 
                if(found==true) {
                    try {    
                        update lineLst;
                    } catch(Exception e) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                    
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));


                    }                            
                }
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
           
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));


        }
    }
    
/* 
 Name: handleClearUI
 Description: 
 */ 
    public void handleClearUI(){
        try{
        existingVPNName=SpecialCharacterConstant.CONCAT;
        pncBandwidth =null;
        noDevicesNeeded=null;
        noUsersNeeded=null;                     
    }
    catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    }
    
/* 
 Name: InitializeUI
 Description: 
 */ 
   public void InitializeUI() {   
try{   
        List <Apttus_Proposal__Proposal_Line_Item__c> lineLst = [Select id, Existing_AVPN_Name__c, No_Of_Soho_CPE_Devices__c, 
                                                                    No_Of_Remote_Access_Users__c, Apttus_QPConfig__ProductOptionId__c, 
                                                                    Apttus_QPConfig__OptionId__c, Apttus_QPConfig__ConfigurationId__c 
                                                                    from Apttus_Proposal__Proposal_Line_Item__c 
                                                                    where Apttus_Proposal__Proposal__c=:quoteId];
        if (lineLst!=null) {
            for(Apttus_Proposal__Proposal_Line_Item__c p: lineLst ){
                if(p.Apttus_QPConfig__ProductOptionId__c!=null) {
                    existingVPNName=p.Existing_AVPN_Name__c; 
                    pncBandwidthOldQuote=p.Apttus_QPConfig__OptionId__c;    
                    if(p.No_Of_Soho_CPE_Devices__c!=null) {
                        noDevicesNeeded=p.No_Of_Soho_CPE_Devices__c.intValue();    
                    }    
                    if(p.No_Of_Remote_Access_Users__c!=null) {
                        noUsersNeeded=p.No_Of_Remote_Access_Users__c.intValue();    
                    }  
                    break;   
                }                                         
            } 
        } 
    }
    catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}

   }
   
/* 
 Name: IntializeQuote
 Description: 
 */ 
    public void IntializeQuote(Apttus_Config2__ProductConfiguration__c prodConfig) {
        try{
            for(Apttus_Config2__LineItem__c p: prodConfig.Apttus_Config2__LineItems__r){
                if(p.Apttus_Config2__ProductOptionId__c!=null) {
                    pncBandwidth=p.Apttus_Config2__OptionId__c;
                    grandTot=p.Apttus_Config2__NetPrice__c;           
                }                                         
            }                                       
          
            List <Apttus_Proposal__Proposal_Line_Item__c> lineLst = [Select Existing_AVPN_Name__c, No_Of_Soho_CPE_Devices__c,
                                                                    No_Of_Remote_Access_Users__c, Apttus_QPConfig__ProductOptionId__c,
                                                                    Apttus_QPConfig__OptionId__c, Apttus_QPConfig__ConfigurationId__c 
                                                                    from Apttus_Proposal__Proposal_Line_Item__c 
                                                                    where Apttus_QPConfig__ConfigurationId__c=:prodConfig.id];
            if (lineLst!=null) {
                for(Apttus_Proposal__Proposal_Line_Item__c p: lineLst ){
                    if(p.Apttus_QPConfig__ProductOptionId__c!=null) {
                        existingVPNName=p.Existing_AVPN_Name__c;
                        if(p.No_Of_Soho_CPE_Devices__c!=null) {    
                            noDevicesNeeded=p.No_Of_Soho_CPE_Devices__c.intValue();
                        }
                        if(p.No_Of_Remote_Access_Users__c!=null) {   
                        noUsersNeeded=p.No_Of_Remote_Access_Users__c.intValue();
                        }     
                    }                                         
                } 
            } 
        } catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}

    }

/* 
 Name: ProductOption
 Type: Class 
 
 Description: 
 */ 
    public class ProductOption{
        public String ComponentId{get;set;}
        public String ComponentProductId{get;set;}
        public String Name{get;set;}
        public Integer Quantity{get;set;}
        public Decimal Price{get;set;}
        public Boolean isSelected{get;set;}
        public Boolean deletionRequired {get; set;}  
    }     
 }