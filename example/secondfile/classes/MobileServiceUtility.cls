/************************************************************************************** 
 Apex Class Name     : MobileServiceUtility
 Version             : 1.0 
 Created Date        : 06 Nov 2014
 Function            : This class provides service to create cart, bundles, line items.
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Dipendu chanda            06/11/2014              Original Version
*************************************************************************************/
    global with sharing class MobileServiceUtility {      
    
    private void updateLineItem(decimal LineNum,string QuoteId,String typeOfFan) {
        
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
            System.debug('lineItems ---->'+lineItems );
            if(lineItems != null)
            {
                for(Apttus_Config2__LineItem__c line: lineItems)
                {
                    if(line.Apttus_Config2__LineNumber__c == lineNum)
                    {                        
                        lineId.add(line.id);
                        system.debug(',lineId---->,'+lineId);                          
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
                             if(!String.isBlank(typeOfFan) && typeOfFan.equals('endCustomerFan'))
                             pattr.End_Customer_FAN__c = true;
                             if(!String.isBlank(typeOfFan) && typeOfFan.equals('consumeForUseFan'))                        
                             pattr.Consume_for_Use_Fan__c = true;                            
                             prodattr.add(pattr);  
                             system.debug('prodattr--->'+prodattr);                     
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
                                                                        
    public void ApttusHelper(String prodId, String quoteId,String typeOfFan) {   
        System.debug('Prod Id---->'+prodId);
        System.debug('Quote Id---->'+quoteId);
        System.debug('typeOfFan---->'+typeOfFan);    //endCustomerFan   or consumeForUseFan
        String cartId;
        try{
        Apttus_Proposal__Proposal__c quote = [select id from Apttus_Proposal__Proposal__c where name =:quoteId limit 1];//limit: as always be 1 for mobility
            system.debug('Quote______'+quote);
            if(!String.isBlank(prodId) && !String.isBlank(quoteId)) {            
                Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
                request.QuoteID = quote.id;  
                System.debug('Quote act id---->'+quote.id); //a2xm00000008b6gAAA
                System.debug('Request---->'+request);  //CreateCartRequestDO:[Properties=(), QuoteId=a2xm00000008b6gAAA]
                /*    
                ApttusServiceUtilityHelper helper2 = new ApttusServiceUtilityHelper();
                cartId = helper2.createCart(quote.id);         
                */
                Apttus_CPQApi.CPQ.CreateCartResponseDO cartRespDO = Apttus_CPQApi.CPQWebService.CreateCart(request);//request
                system.debug('cartRespDO  - > '+cartRespDO);  
                cartId = cartRespDO.cartID;
                system.debug('Cart created - > '+cartId);  
                SWPO_ApttusUtilityHelper helper = new SWPO_ApttusUtilityHelper();
                system.debug('testing0');                  
                helper.addMainProdcut1(prodId, cartId); 
                system.debug('testing1');
                updateLineItem(1,quote.id,typeOfFan);
                system.debug('testing2');
                helper.finalizeCart(cartId);
                system.debug('testing3');
            }
        }
        catch(Exception e){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.createException('Error in MobileServiceUtility.ApttusHelper', e.getTypeName(), ATTException.constructExceptionMessageString(e));
            System.debug('Error in MobileServiceUtility.ApttusHelper()at line number --->' + e.getLineNumber());   
            System.debug('Error in MobileServiceUtility.ApttusHelper() cause --->' + e.getCause());   
            System.debug('Error in MobileServiceUtility.ApttusHelper() message --->' + e.getMessage());   
      
        }
    }         
}