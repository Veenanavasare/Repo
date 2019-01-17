/************************************************************************************** 
Apex Class Name     : QuotesAndOrdersDashboardController 
Version             : 1.0 
Created Date        : 28th Oct 2014
Function            : Controller for QuotesAndOrdersDashboard VF page.
Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Shoumyabrata Chanda        10/28/2014              Original Version
* Teja                       11/23/2014              DE89448 - Added IsApprover variable and a method CheckApprover
* Manish Tiwari              07/07/2016              Replaced  the Duplicate Quote method with the new logic as part of QC Defect 49120
*************************************************************************************/
global  class QuotesAndOrdersDashboardController {
    public List<Apttus_Config2__ProductConfiguration__c> prodConfigList;        
    public String siteConfigureId{get;set;} 
    public Apttus_Proposal__Proposal__c quoteObj{get;set;}
    public String selectedVal { get; set; }
    public String selectedVal1 { get; set; }
    public String selectedValParam { get; set; }
    public String inputText1 {get; set;}
    public List<SelectOption> items {get;set;}
    public string baseUrl;
    public List<Apttus_Proposal__Proposal__c> quoteDetails { get; set; }
    public Map<String,ItemCountWrapper> productsMap {get; set;}
    public Map<String,ItemCountWrapper> statusMap {get; set;}
    public Map<String,ItemCountWrapper> typeMap {get; set;}
    public Map<String,ItemCountWrapper> pricingStatusMap {get; set;}
    public List<ItemCountWrapper> productsCountList {get; set;}
    public List<ItemCountWrapper> statusCountList {get; set;}
    public List<ItemCountWrapper> typeCountList {get; set;}
    public List<ItemCountWrapper> pricingStatusCountList {get; set;}
    public String selectedType { get; set; }
    public String selectedStatus { get; set; }
    public String selectedProduct { get; set; }
    public String quoteId { get; set; }
    public String ErrorMessage{ get; set; }
    public String encryptedUrl { get; set; }
    public String typeVal{get;set;}
    public String subAccNo {get; set;} //defect 74987
    public String dealHashId; //defect 74987
    public String mOppId;  //defect 74987
    public String finalDeencryptedUrl { get; set; }
    public boolean isApprover { get;set; }    
    public user usr{get; private set;}    
    public boolean userBeginQuote{get; set;}    
    private String duplicatedQuoteId = SpecialCharacterConstant.CONCAT;
    public String currentUserId{get; set;}
    /* 
     Name: quoteFilterByType
     Description: 
     */ 
    public void quoteFilterByType() {
        try {        
            User usr = new User();
            usr = [Select Id,Name,Is_Approver__c,Approve_Contracts__c,ContactId,Email FROM User WHERE id=:userinfo.getuserId()];
            
            Contact con = new Contact();
            if(usr.ContactId != null) {  
                con = [SELECT Id, Name, AccountId,Account.Name FROM Contact WHERE Id=:usr.ContactId];
                quoteDetails = [SELECT Id,Name,Product_New_Name__c,End_Customer__r.Name,LastModifiedBy.Name,LastModifiedDate,Product__c,Product__r.Name,Product__r.productcode,Quote_Type__c,SP_Status__c,Pricing_Status__c,Lowest_Promotion_Expiry_Date__c FROM Apttus_Proposal__Proposal__c 
                WHERE API_IPQ_Quote__c = false and Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c =:con.AccountId and Apttus_Proposal__Proposal__c.Quote_Type__c =:string.escapeSingleQuotes(selectedType) and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') order by LastModifiedDate desc];
            }
            else
            {
                LIST<Account> idAcc=[SELECT Id FROM Account WHERE name='AT&T_SP' limit 1 ];
                quoteDetails = [SELECT Id,Name,Product_New_Name__c,End_Customer__r.Name,LastModifiedBy.Name,LastModifiedDate,Product__c,Product__r.Name,Product__r.productcode,Quote_Type__c,SP_Status__c,Pricing_Status__c,Lowest_Promotion_Expiry_Date__c FROM Apttus_Proposal__Proposal__c WHERE API_IPQ_Quote__c = false and Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c =:idAcc[0].id and Apttus_Proposal__Proposal__c.Quote_Type__c =:string.escapeSingleQuotes(selectedType) and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') order by LastModifiedDate desc
                limit 1000 ];  
    
            }
        } catch (Exception e) {
            String exceptionString = ATTException.constructExceptionMessageString(e);
            ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);                        
        }                
    }

    /* 
     Name: quoteFilterByProduct
     Description: 
    */     
    public void quoteFilterByProduct() {
        try {
            User usr = new User();
            usr = [Select Id,Name,Is_Approver__c,ContactId,Email FROM User WHERE id=:userinfo.getuserId()];
            Contact con = new Contact();
            if(usr.ContactId != null)
            {  
                con = [SELECT Id, Name, AccountId,Account.Name FROM Contact WHERE Id=:usr.ContactId];
                quoteDetails = [SELECT Id,Name,Product_New_Name__c,End_Customer__r.Name,LastModifiedBy.Name,LastModifiedDate,Product__c,Product__r.Name,Product__r.productcode,Quote_Type__c,SP_Status__c,Pricing_Status__c,Lowest_Promotion_Expiry_Date__c FROM Apttus_Proposal__Proposal__c 
                WHERE API_IPQ_Quote__c = false and Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c =:con.AccountId and Apttus_Proposal__Proposal__c.Product__r.Name =:selectedProduct and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') order by LastModifiedDate desc]; 
            }
            else
            {
                
                LIST<Account> idAcc=[SELECT Id FROM Account WHERE name='AT&T_SP' limit 1 ];
                quoteDetails = [SELECT Id,Name,Product_New_Name__c,End_Customer__r.Name,LastModifiedBy.Name,LastModifiedDate,Product__c,Product__r.Name,Product__r.productcode,Quote_Type__c,SP_Status__c,Pricing_Status__c,Lowest_Promotion_Expiry_Date__c FROM Apttus_Proposal__Proposal__c WHERE API_IPQ_Quote__c = false and Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c =:idAcc[0].id and Apttus_Proposal__Proposal__c.Product__r.Name =:selectedProduct and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') order by LastModifiedDate desc
                limit 1000 ];  
    
            }
        } catch (Exception e) {
            String exceptionString = ATTException.constructExceptionMessageString(e);
            ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);                        
        }        
    }

    /* 
     Name: quoteFilterByStatus
     Description: 
    */     
    public void quoteFilterByStatus() {    
        try {
            User usr = new User();
            usr = [Select Id,Name,Is_Approver__c,ContactId,Email FROM User WHERE id=:userinfo.getuserId()];
            Contact con = new Contact();
            if(usr.ContactId != null)
            {  
                con = [SELECT Id, Name, AccountId,Account.Name FROM Contact WHERE Id=:usr.ContactId];
                quoteDetails = [SELECT Id,Name,Product_New_Name__c,End_Customer__r.Name,LastModifiedBy.Name,LastModifiedDate,Product__c,Product__r.Name,Product__r.productcode,Quote_Type__c,SP_Status__c,Pricing_Status__c,Lowest_Promotion_Expiry_Date__c FROM Apttus_Proposal__Proposal__c 
                WHERE API_IPQ_Quote__c = false and Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c =:con.AccountId and Apttus_Proposal__Proposal__c.SP_Status__c =:selectedStatus and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') order by LastModifiedDate desc]; 
            }
            else
            {
                LIST<Account> idAcc=[SELECT Id FROM Account WHERE name='AT&T_SP' limit 1 ];
                quoteDetails = [SELECT Id,Name,Product_New_Name__c,End_Customer__r.Name,LastModifiedBy.Name,LastModifiedDate,Product__c,Product__r.Name,Product__r.productcode,Quote_Type__c,SP_Status__c,Pricing_Status__c,Lowest_Promotion_Expiry_Date__c FROM Apttus_Proposal__Proposal__c WHERE API_IPQ_Quote__c = false and Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c =:idAcc[0].id and Apttus_Proposal__Proposal__c.SP_Status__c =:selectedStatus and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') order by LastModifiedDate desc
                limit 1000 ];  
    
            }
        } catch (Exception e) {
            String exceptionString = ATTException.constructExceptionMessageString(e);
            ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);                        
        }        
    }

    /* 
     Name: ItemCountWrapper
     Type: Class  
     Description: 
     */ 
    public class ItemCountWrapper implements Comparable{
        public String itemQuantity {get;set;}
        public String  itemName {get;set;}
   
        /* 
         Name: ItemCountWrapper
         Description: 
         */ 
        public ItemCountWrapper(String itemQuantity,String itemName) {
            this.itemQuantity = itemQuantity;
            this.itemName = itemName;
        }
                public Integer compareTo(Object objToCompare) {
        
        
            return itemName.compareTo(((ItemCountWrapper)objToCompare).itemName);
        
        }
    }

    /* 
     Name: QuotesAndOrdersDashboardController
     Description: 
     */ 
    public QuotesAndOrdersDashboardController() { 
        User userObj;
        userObj = [select id, Begin_Quote__c from User where id = :UserInfo.getUserId()];
        userBeginQuote = userObj.Begin_Quote__c;
        currentUserId = UserInfo.getUserId();
    }

    /* 
     Name: initQuoteAndDashboardPage
     Description: 
     */ 
    public void initQuoteAndDashboardPage() {
        try {
            User usr = new User();
            usr = [Select Id,Name,Is_Approver__c,ContactId,Email FROM User WHERE id=:userinfo.getuserId()];
            Contact con = new Contact();
            String partnerAccId = SpecialCharacterConstant.CONCAT;
            if(usr.ContactId != null) {  
                con = [SELECT Id, Name, AccountId,Account.Name FROM Contact WHERE Id=:usr.ContactId];
                partnerAccId = con.AccountId;
                
            } else {
                LIST<Account> idAcc=[SELECT Id FROM Account WHERE name='AT&T_SP' limit 1 ];
                if(!idAcc.isEmpty()) {
                    partnerAccId = idAcc[0].Id;
                }
    
            }
            
            isApprover = CheckApprover(usr.id);
            productsMap = new Map<String, ItemCountWrapper>();
            statusMap = new Map<String, ItemCountWrapper>();
            typeMap = new Map<String, ItemCountWrapper>();
            pricingStatusMap = new Map<String, ItemCountWrapper>();
           
            productsCountList = new List<ItemCountWrapper>();
            statusCountList = new List<ItemCountWrapper>();
            typeCountList = new List<ItemCountWrapper>();
            pricingStatusCountList = new List<ItemCountWrapper>();
            
            ItemCountWrapper itemCountObj = null;
            Set<String> setIds = new Set<String>();       
            set<Apttus_Proposal__Proposal__c> myset = new set<Apttus_Proposal__Proposal__c>([select id from Apttus_Proposal__Proposal__c where (API_IPQ_Quote__c = false and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') and Apttus_Proposal__Approval_Stage__c = 'Draft' AND RelatedQuote__c !='' AND RelatedQuote__c != null )]);
            for (Apttus_Proposal__Proposal__c setid: myset) 
            {
                if( !setIds.contains(setid.id) ){
                
                    setIds.add(setid.id);
                }  
            }
            AggregateResult[] prodGroupedResults = [SELECT Product__c,  Product__r.Product_New_Name__c ProductName, COUNT(Id) prodCount
                                                      FROM Apttus_Proposal__Proposal__c
                                                      Where API_IPQ_Quote__c = false and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') and Apttus_Proposal__Account__c =: partnerAccId AND Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c != 'Deleted'  AND ( Quote_Type__c != '' AND Quote_Type_Backend__c != '' )  AND Id NOT IN:setIds
                                                      GROUP BY  Product__r.Product_New_Name__c,Product__c];
            for (AggregateResult ar : prodGroupedResults)  {
                if(ar.get('ProductName') != null) {
                    itemCountObj = new ItemCountWrapper(''+ar.get('prodCount'),(ar.get('ProductName') == null ? 'No Products':''+ar.get('ProductName')));
                    productsCountList.add(itemCountObj);
                    productsMap.put(''+ar.get('Product__c'),itemCountObj);
                }                
            }
            
            
            AggregateResult[] typeGroupedResults = [SELECT Quote_Type_Backend__c quoteType, COUNT(Id) quoteTypeCount
                                                    FROM Apttus_Proposal__Proposal__c
                                                    Where API_IPQ_Quote__c = false and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') and Apttus_Proposal__Account__c =: partnerAccId AND Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c != 'Deleted'  AND ( Quote_Type__c != '' AND Quote_Type_Backend__c != '' )  AND Id NOT IN:setIds
                                                    GROUP BY Quote_Type_Backend__c];
            for (AggregateResult ar : typeGroupedResults)  {
                if(ar.get('quoteType') != null) {
                    itemCountObj = new ItemCountWrapper(''+ar.get('quoteTypeCount'),(ar.get('quoteType') == null ? 'No Type':''+ar.get('quoteType')));
                    typeCountList.add(itemCountObj);
                    typeMap.put(''+ar.get('quoteType'),itemCountObj);
                }
                
            }
           // system.debug('partnerAccId-->'+partnerAccId);
            //system.debug('setIds-->'+setIds);
            AggregateResult[] statusGroupedResults = [SELECT SP_Status_Backend__c status, COUNT(Id) statusCount
                                                        FROM Apttus_Proposal__Proposal__c
                                                        Where API_IPQ_Quote__c = false and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') and Apttus_Proposal__Account__c =: partnerAccId
                                                         AND SP_Status_Backend__c!=: 'Expired' 
                                                        AND   Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c != 'Deleted'  AND ( Quote_Type__c != '' AND Quote_Type_Backend__c != '' )  AND Id NOT IN : setIds
                                                        GROUP BY SP_Status_Backend__c];
            for (AggregateResult ar : statusGroupedResults)  {
                if(ar.get('status') != null) {
               
                    itemCountObj = new ItemCountWrapper(''+ar.get('statusCount'),(ar.get('status') == null ? 'No Status':''+ar.get('status')));
                    statusCountList.add(itemCountObj);
                    statusMap.put(''+ar.get('status'),itemCountObj);
                }
            }
            system.debug('====@@@statusCountList==='+statusCountList);
            
             AggregateResult[] pricingGroupedResults = [SELECT Pricing_Status_Backend__c Prcingstatus, COUNT(Id) pricingCount
                                                      FROM Apttus_Proposal__Proposal__c
                                                      Where API_IPQ_Quote__c = false and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') and Apttus_Proposal__Account__c =: partnerAccId AND Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c != 'Deleted'  AND ( Quote_Type__c != '' AND Quote_Type_Backend__c != '' )  AND Id NOT IN:setIds
                                                      GROUP BY Pricing_Status_Backend__c];
            for (AggregateResult ar : pricingGroupedResults)  {
                if(ar.get('Prcingstatus') != null) {
                    itemCountObj = new ItemCountWrapper(''+ar.get('pricingCount'),(ar.get('Prcingstatus') == null ? 'No Pricing':''+ar.get('Prcingstatus')));
                    pricingStatusCountList.add(itemCountObj);
                    pricingStatusMap.put(''+ar.get('Prcingstatus'),itemCountObj);
                }                
            }
            system.debug('====@@@pricingStatusCountList==='+pricingStatusCountList);
     
        List<Apttus_Proposal__Proposal__c> expiredQuotesList = [SELECT SP_Status_Backend__c 
                                                        FROM Apttus_Proposal__Proposal__c
                                                        Where API_IPQ_Quote__c = false and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') and Apttus_Proposal__Account__c = : partnerAccId
                                                        AND SP_Status_Backend__c=: 'Expired'  
                                                        AND   Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c != 'Deleted'  AND ( Quote_Type__c != '' AND Quote_Type_Backend__c != '' )  AND Id NOT IN : setIds
                                                        AND Apttus_Proposal__Opportunity__r.Quote_Expiration_Date__c >: system.today().addDays(-30)
                                                        ];
                     if(expiredQuotesList!=null && expiredQuotesList.size()>0)
                     {
                     itemCountObj = new ItemCountWrapper(expiredQuotesList.size()+'','Expired');
                    statusCountList.add(itemCountObj);
                    statusMap.put('Expired',itemCountObj);
                     }  
               //system.debug('statusCountList  -->'+statusCountList);
               statusCountList.sort();
               // system.debug('statusCountList after sort -->'+statusCountList);       
        } catch (Exception e) {
            String exceptionString = ATTException.constructExceptionMessageString(e);
            ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);                        
        }
    }
    
    /*******************************************************************
    * Method name : checkApprover
    * Description : To know the user is an Approver or not.
    * Return Type : Boolean.
    * Parameters  : userid.
    *******************************************************************/   
    public boolean checkApprover(string userid) {
     
        boolean isApprover=false;
        try{
         User usr = new User();
        usr = [Select Id,Name,ContactId, Begin_Quote__c, Approve_Contracts__c from User where id=:userinfo.getuserid()];
        userBeginQuote = usr.Begin_Quote__c;
        if(usr.Approve_Contracts__c == true){
            isApprover = true;
        }
        else{
            isApprover = false; 
        }
        }
        catch(exception e) {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return isApprover;
     
    }
    
    /***********************************************************************************************
    Method: getActionOptns
    Description: 
    @Param : none
    @return: list<SelectOption> 
    @throws: none
    Version :  
    Modification Log :
    Developer        Date            Description
    ******************************************/ 
    public List<SelectOption> getActionOptns() {
        
        List<SelectOption> actionOptns = new List<SelectOption>();
        try{
            actionOptns.add(new selectOption(BuyflowConstant.SIVARConst_1,BuyflowConstant.REGISTERDEAL));
            actionOptns.add(new selectOption(BuyflowConstant.SIVARConst_2,BuyflowConstant.DUPLICATE));
            actionOptns.add(new selectOption(BuyflowConstant.SIVARConst_3,SpecialCharacterConstant.DELETE_CAPS_LITERAL));
        }catch(Exception excep){
            ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
        }
        return actionOptns;
        
    }

    /*******************************************************************
    * Method name : toggleManagepicklist
    * Description : Logic behind this method is to filter Quotes/proposal records based on the dropdown values(My Approvals Link/My Network Link)
    * Return Type : pageRef.
    * Parameters  : None.
    *******************************************************************/  
/* 
 Name: toggleManagepicklist
 Description: 
 */ 
    public PageReference toggleManagepicklist() {
        try {
            User usr = new User();
            usr = [Select Id,Name,Is_Approver__c,ContactId,Email FROM User WHERE id=:userinfo.getuserId()];
            Contact con = new Contact();
            
            if(selectedVal1==BuyflowConstant.SIVARConst_2)
            {
                if(usr.ContactId != null) {
                    con = [SELECT Id, Name, AccountId,Account.Name FROM Contact WHERE Id=:usr.ContactId];
                    quoteDetails = [SELECT Id,Name,Product_New_Name__c,End_Customer__r.Name,LastModifiedBy.Name,LastModifiedDate,Product__c,Product__r.productcode,Quote_Type__c,SP_Status__c,Pricing_Status__c,Lowest_Promotion_Expiry_Date__c FROM Apttus_Proposal__Proposal__c 
                    WHERE API_IPQ_Quote__c = false and Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c =: con.AccountId and (Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c ='Pricing Schedule Requested' 
                    OR Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c ='SP Approval Requested') and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress')  order by LastModifiedDate desc]; 
                } else {
                    LIST<Account> idAcc=[SELECT Id FROM Account WHERE name='AT&T_SP' limit 1 ];
                    quoteDetails = [SELECT Id,Name,Product_New_Name__c,End_Customer__r.Name,LastModifiedBy.Name,LastModifiedDate,Product__c,Product__r.productcode,Quote_Type__c,SP_Status__c,Pricing_Status__c,Lowest_Promotion_Expiry_Date__c FROM Apttus_Proposal__Proposal__c WHERE API_IPQ_Quote__c = false and Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c =:idAcc[0].Id and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') and (Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c ='Pricing Schedule Requested' OR Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c ='SP Approval Requested') order by LastModifiedDate desc]; 
                }            
            }
            if(selectedVal1==BuyflowConstant.SIVARConst_3)
            {
                
                if(usr.ContactId != null) {
                    con = [SELECT Id, Name, AccountId,Account.Name FROM Contact WHERE Id=:usr.ContactId];
                    quoteDetails = [SELECT Id,Name,Product_New_Name__c,End_Customer__r.Name,LastModifiedBy.Name,LastModifiedDate,Product__c,Product__r.productcode,Quote_Type__c,SP_Status__c,Pricing_Status__c,Lowest_Promotion_Expiry_Date__c FROM Apttus_Proposal__Proposal__c WHERE API_IPQ_Quote__c = false and Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c =: con.AccountId and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') order by LastModifiedDate desc]; 
                } else {
                    LIST<Account> idAcc=[SELECT Id FROM Account WHERE name='AT&T_SP' limit 1 ];
                    quoteDetails = [SELECT Id,Name,Product_New_Name__c,End_Customer__r.Name,LastModifiedBy.Name,LastModifiedDate,Product__c,Product__r.productcode,Quote_Type__c,SP_Status__c,Pricing_Status__c,Lowest_Promotion_Expiry_Date__c FROM Apttus_Proposal__Proposal__c 
                    WHERE API_IPQ_Quote__c = false and Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c =: idAcc[0].Id and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') order by LastModifiedDate desc limit 500];
                }
            }
            return null;
        } catch (Exception e) {
            String exceptionString = ATTException.constructExceptionMessageString(e);
            ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);                        
            return null;
        }
    }

    /*******************************************************************
    * Method name : checkBuyFlowStatusAndRedirect
    * Description : Logic behind this method is to redirect the Quotes/Proposal to the appropriate page based on Quote Approval Stage/Quote buyflow step/Opportunity Stage
    * Return Type : pageRef.
    * Parameters  : None.
    *******************************************************************/ 
/* 
 Name: checkBuyFlowStatusAndRedirect
 Description: 
 */ 
    public PageReference checkBuyFlowStatusAndRedirect() {
        try {
            
            PageReference pageRef ;
            Id quoteID = System.currentPageReference().getParameters().get('quotID');
            
            if(this.subAccNo == null){
                if(quoteID != null){
                    List<Apttus_Proposal__Proposal__c> quote = [Select Id, MasterOpportunity__r.Id from Apttus_Proposal__Proposal__c where id=: quoteID limit 1];
                    if(quote[0].MasterOpportunity__r.Id != null){
                        List<Opportunity> opp = [Select Id, RDS_Deal_Hash__r.id from Opportunity where  Id=: quote[0].MasterOpportunity__r.Id  limit 1];
                        if(opp[0].RDS_Deal_Hash__r.id != null){
                            Deal_Hash__c deal = [select Id,Sub_Account_Number__c from Deal_Hash__c where Id =: opp[0].RDS_Deal_Hash__r.id Limit 1];
                            this.subAccNo = deal.Sub_Account_Number__c;
                        }
                    }
                }
            }
            //Start Defect: DE97572 : Navigating the Duplicated quote to proper buyflow step: RK 01/08/2015
            //Checking the duplicatedQuoteId
            if(duplicatedQuoteId != null && duplicatedQuoteId != SpecialCharacterConstant.CONCAT) {
                quoteID = duplicatedQuoteId;
                duplicatedQuoteId = SpecialCharacterConstant.CONCAT;
            }
            //End: RK
            List<Apttus_Proposal__Proposal__c> quoteList=[select Id,Product__r.ProductCode,Rate_Card_Effective_Date__c,Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c,Eligible_for_RDS__c,vasa_modeA_request__c,
                                                            vasa_modeD_request__c,vasa_modeB_request__c, MACD_Change_Type__c,Name,Buyflow_Step__c,Apttus_Proposal__Approval_Stage__c,ASE_MACD_Deal__c,Product__c,Apttus_Proposal__Opportunity__r.stageName,
                                                            RelatedPremise__c,IPFlexTNCPage__c,Renewal_Contract__c,CR_Approved__c From Apttus_Proposal__Proposal__c Where Apttus_Proposal__Proposal__c.id=:quoteID limit 1];
            
            String loggedInUser=userInfo.getUserID();
            boolean isUserIsSPApprover = CheckApprover(loggedInUser);
            //system.debug('logged in user is : '+loggedInUser+' and is Approver : '+isUserIsSPApprover );
            for(Apttus_Proposal__Proposal__c quoteObj:quoteList) {
                Id qid=quoteObj.id;
                string code = SpecialCharacterConstant.CONCAT;
                string premiseid = SpecialCharacterConstant.CONCAT; 
                if(quoteObj.Product__c != null){
                     code = quoteObj.Product__r.ProductCode;
                }
                
                 if(quoteObj.RelatedPremise__c != null){
                     premiseid = quoteObj.RelatedPremise__c;
                }
                if(quoteObj.Renewal_Contract__c == false){
                    //AIA Page Redirection
                    if(quoteObj.Apttus_Proposal__Approval_Stage__c=='Order Submitted' && quoteObj.Apttus_Proposal__Opportunity__r.StageName=='Order Submitted' && code == 'AIA'){
                        pageRef  = new PageReference('/apex/dealreg?mode=orderConf&quoteid='+qid+'&code='+code);
                        pageRef.setRedirect(true);
                    }
                    else if (code == 'AIA'){
                        pageRef  = new PageReference('/apex/AIA_canvasDisplayPage?quoteid='+qid);
                        pageRef.setRedirect(true);
                    }     
                    if(quoteObj.Apttus_Proposal__Approval_Stage__c == 'SP Approval Request Denied'){  
                         if(quoteObj.MACD_Change_Type__c == 'AddSite')
                         {
                            pageRef = new PageReference('/apex/api_macd_dealreg?mode=TNC&quoteid='+qid);
                            pageRef.setRedirect(true);
                         }
                    else{
                        pageRef  = new PageReference('/apex/dealreg?intervalTime=&mode=orderConf&quoteId='+qid); 
                        pageRef.setRedirect(true);
                        }
                    }
              
                    if(quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.DRAFT || (code == BuyflowConstant.ASE && (quoteObj.Apttus_Proposal__Approval_Stage__c == 'Technical Review Requested' || quoteObj.Apttus_Proposal__Approval_Stage__c == 'Technical Review Approved' || quoteObj.Apttus_Proposal__Approval_Stage__c == 'Technical Review Denied' || quoteObj.Apttus_Proposal__Approval_Stage__c == 'Order Submitted'))){
                        if(code == BuyflowConstant.ANIRA){
                            if(quoteObj.buyflow_step__c==BuyflowConstant.ADDPRODUCT)
                            {
                                pageRef  = new PageReference('/apex/buyflow?mode=productinfo&quoteid='+qid); //working
                                pageRef.setRedirect(true);
                                
                            }
                            
                            if(quoteObj.buyflow_step__c==BuyflowConstant.ADDSITES|| quoteObj.buyflow_step__c==BuyflowConstant.CONFIGPROD || quoteObj.buyflow_step__c==BuyflowConstant.CONFIGURESITES || quoteObj.buyflow_step__c==BuyflowConstant.REVIEWQUOTE )
                            {
                              /* US US344613 Implementation */
                                pageRef  = new PageReference('/apex/ANIRA_Buyflow?quoteid='+qid);
                            pageRef.setRedirect(true);
                            }
                        }
                        else if(code == BuyflowConstant.STAAS1){
                            if(quoteObj.buyflow_step__c==BuyflowConstant.ADDPRODUCT)
                            {
                                pageRef  = new PageReference('/apex/buyflow?mode=productinfo&quoteid='+qid); //working
                                pageRef.setRedirect(true);
                                
                            }
                        }
                        
                        else if(code == BuyflowConstant.ASE){
                            if(quoteObj.buyflow_step__c==BuyflowConstant.ADDPRODUCT){
                                pageRef  = new PageReference('/apex/buyflow?mode=productinfo&quoteid='+qid); //working
                                pageRef.setRedirect(true);
                                
                            }
                            if(quoteObj.buyflow_step__c==BuyflowConstant.ADDSITES)
                            {
                                pageRef  = new PageReference('/apex/buyflow?mode=siteinfo&quoteid='+qid); // working
                                pageRef.setRedirect(true);
                            }
                            if(quoteObj.buyflow_step__c==BuyflowConstant.CONFIGURESITES)
                            {
                                pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=confsites&quoteid='+qid); //Not working.Not Able to update Quote Buy Flow step.Controller needs to be updated
                                pageRef.setRedirect(true);
                            }
                            if(quoteObj.buyflow_step__c==BuyflowConstant.REVIEWQUOTE)
                            {
                                pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=reviewquote&quoteid='+qid); //Not Working.Not Able to update Quote Buy Flow step.Controller needs to be updated
                                pageRef.setRedirect(true);
                            }
                        }
                        
                        else if(code == 'AVPN' || code == 'AMIS'){
                            if(quoteObj.buyflow_step__c=='Add Product'){
                                pageRef  = new PageReference('/apex/buyflow?mode=productinfo&quoteid='+qid); //working
                                pageRef.setRedirect(true);
                                
                            }
                            if(quoteObj.buyflow_step__c==BuyflowConstant.ADDCUSTOMER){
                                pageRef  = new PageReference('/apex/buyflow?mode=productinfo&quoteid='+qid); //working
                                pageRef.setRedirect(true);
                                
                            }
                            if( quoteObj.buyflow_step__c==BuyflowConstant.ADDSITES || quoteObj.buyflow_step__c==BuyflowConstant.ADDSITE){
                               if(quoteObj.MACD_Change_Type__c == 'AddSite'){
                                    pageRef  = new PageReference('/apex/API_MACD_Buyflow?nooverride=1&quoteid='+qid+'&sub_acount_number='+this.subAccNo);
                                    pageRef.setRedirect(true);
                                } else {
                                   pageRef  = new PageReference('/apex/buyflow?mode=siteinfo&quoteid='+qid); // working
                                   pageRef.setRedirect(true);
                                 }
                            }
                            if(quoteObj.buyflow_step__c==BuyflowConstant.CONFIGURESITES){
                                if(quoteObj.MACD_Change_Type__c == 'AddSite'){
                                    pageRef  = new PageReference('/apex/API_MACD_PortalDesign_AVPN_MIS_BuyFlow?mode=confsites&quoteid='+qid);
                                    pageRef.setRedirect(true);
                                } else {
                                    pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=confsites&quoteid='+qid);
                                    pageRef.setRedirect(true);
                                }
                            }
                            if(quoteObj.buyflow_step__c==BuyflowConstant.REVIEWQUOTE){
                                if(quoteObj.MACD_Change_Type__c == 'AddSite'){
                                    pageRef  = new PageReference('/apex/API_MACD_PortalDesign_AVPN_MIS_BuyFlow?quoteid='+qid+'&mode=reviewquote');
                                    pageRef.setRedirect(true);
                                } else {
                                    pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=reviewquote&quoteid='+qid);
                                    pageRef.setRedirect(true);
                                }
                            }
                        }
                        else if(code == BuyflowConstant.AIA){
                            if(quoteObj.buyflow_step__c==BuyflowConstant.ADDPRODUCT){
                                pageRef  = new PageReference('/apex/buyflow?mode=productinfo&quoteid='+qid); //working
                                pageRef.setRedirect(true);                            
                            }
                            if(quoteObj.buyflow_step__c==BuyflowConstant.ADDCUSTOMER){
                                pageRef  = new PageReference('/apex/buyflow?mode=productinfo&quoteid='+qid); //working
                                pageRef.setRedirect(true);
                                
                            }
                        }
                        else{
                            if(quoteObj.buyflow_step__c==BuyflowConstant.ADDPRODUCT){
                                pageRef  = new PageReference('/apex/buyflow?mode=productinfo&quoteid='+qid); //working
                                pageRef.setRedirect(true);
                                
                            }
                            if(quoteObj.buyflow_step__c==BuyflowConstant.ADDSITES){
                                pageRef  = new PageReference('/apex/buyflow?mode=siteinfo&quoteid='+qid); // working
                                pageRef.setRedirect(true);
                            }
                            if(quoteObj.buyflow_step__c==BuyflowConstant.CONFIGURESITES){
                                pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=confsites&quoteid='+qid);
                                pageRef.setRedirect(true);
                            }
                            if(quoteObj.buyflow_step__c==BuyflowConstant.REVIEWQUOTE){
                                pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=reviewquote&quoteid='+qid);
                                pageRef.setRedirect(true);
                            }
                        }
            }
            
            if(quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.BULKSERVICE_AVAILABILITY_REQUESTED){
                if(quoteObj.buyflow_step__c==BuyflowConstant.ADDSITES || quoteObj.buyflow_step__c==BuyflowConstant.ADDSITE){
                    if(quoteObj.vasa_modeA_request__c==true){
                        if ('AddSite'.equalsIgnoreCase(quoteObj.MACD_Change_Type__c)) {
                            pageRef  = new PageReference('/apex/MACD_BuyFlow_VASABulk?quoteid='+qid+'&vmode=A');
                            pageRef.setRedirect(true);
                        }else{
                            pageRef  = new PageReference('/apex/buyflow_vasabulk?quoteid='+qid+'&vmode=A'); 
                            pageRef.setRedirect(true);
                        }
                    }
                    else if(quoteObj.vasa_modeD_request__c==true){  
                        pageRef  = new PageReference('/apex/buyflow_vasabulk?quoteid='+qid+'&vmode=D'); 
                        pageRef.setRedirect(true);
                   }else if(quoteObj.vasa_modeB_request__c==true){
                        if ('AddSite'.equalsIgnoreCase(quoteObj.MACD_Change_Type__c)) {
                            pageRef  = new PageReference('/apex/MACD_BuyFlow_VASABulk?quoteid='+qid+'&vmode=B'); 
                            pageRef.setRedirect(true);
                        }else{
                            pageRef  = new PageReference('/apex/buyflow_vasabulk?quoteid='+qid+'&vmode=B'); 
                            pageRef.setRedirect(true);
                        }
                    }
                }
                if(quoteObj.buyflow_step__c==BuyflowConstant.CONFIGURESITES && quoteObj.vasa_modeB_request__c==true){
                    if ('AddSite'.equalsIgnoreCase(quoteObj.MACD_Change_Type__c)) {
                        pageRef  = new PageReference('/apex/MACD_BuyFlow_VASABulk?quoteid='+qid+'&vmode=B&mode=confsites'); 
                        pageRef.setRedirect(true);
                    } 
                    else{ 
                        pageRef  = new PageReference('/apex/BuyFlow_VASABulk?quoteid='+qid+'&vmode=B');
                        pageRef.setRedirect(true);
                    }
                }
                   if(quoteObj.buyflow_step__c==BuyflowConstant.CONFIGURESITES)
                         {
                              pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=confsites&quoteid='+qid); 
                              pageRef.setRedirect(true);
                         }
                     if(quoteObj.buyflow_step__c==BuyflowConstant.REVIEWQUOTE)
                         {
                              pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=reviewquote&quoteid='+qid); 
                              pageRef.setRedirect(true);
                         } 
            }
     
             
            if(quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.BULKSERVICE_AVAILABILITY_COMPLETED){
                if(code == BuyflowConstant.AIA){ 
                    if(quoteObj.buyflow_step__c==BuyflowConstant.ADDSITES || quoteObj.buyflow_step__c==BuyflowConstant.CONFIGURESITES ){
                        pageRef  = new PageReference('/apex/AIA_canvasDisplayPage?quoteid='+qid);
                        pageRef.setRedirect(true);
                    }
                }else{
                    if(quoteObj.buyflow_step__c==BuyflowConstant.ADDSITES){
                        if(quoteObj.MACD_Change_Type__c=='AddSite') {
                             pageRef  = new PageReference('/apex/API_MACD_Buyflow?mode=siteinfo&quoteid='+qid);
                        }else{
                              pageRef  = new PageReference('/apex/buyflow?mode=siteinfo&quoteid='+qid); //Not Working.Not Able to update Quote Buy Flow step.Controller needs to be updated
                         }
                         pageRef.setRedirect(true);
                    }
                    if(quoteObj.buyflow_step__c==BuyflowConstant.CONFIGURESITES){
                        if(quoteObj.MACD_Change_Type__c=='AddSite'){
                            pageRef  = new PageReference('/apex/API_MACD_PortalDesign_AVPN_MIS_BuyFlow?mode=confsites&quoteid='+qid);
                            pageRef.setRedirect(true);
                        }else{
                            pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=confsites&quoteid='+qid);
                            pageRef.setRedirect(true);
                        }
                    }else if(quoteObj.buyflow_step__c==BuyflowConstant.REVIEWQUOTE){
                        if(quoteObj.MACD_Change_Type__c=='AddSite'){
                            pageRef  = new PageReference('/apex/API_MACD_PortalDesign_AVPN_MIS_BuyFlow?mode=reviewquote&quoteid='+qid);
                            pageRef.setRedirect(true);
                        }else{
                            pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=reviewquote&quoteid='+qid);
                            pageRef.setRedirect(true);
                        }
                    }
                }
             }
                    
                     //Added by Prateek for Inflight Cancel Internal Enhancement
            if(quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.PENDINGCANCEL){
                        pageRef  = new PageReference('/apex/sitedetails?pid='+premiseid);
                        pageRef.setRedirect(true);
                    }
                    
            if(quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.CANCELLED && quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.CANCELLED){
                        if( code == 'ANIRA'){
                            pageRef  = new PageReference('/apex/buyflow_ANIRA?mode=reviewquote&quoteid='+qid); //Review Quote Page   -working
                            pageRef.setRedirect(true);
                        }
                        else{
                            pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=reviewquote&quoteid='+qid); //Review Quote Page   -working
                            pageRef.setRedirect(true);
                        }
            }
            else if( (quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.PENDINGDEAL_REG || quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.TSCREVIEW_REQUESTED) && (quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREGISTRATION_REQUESTED || quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.TSCREVIEW_REQUESTED)){
                        If( code == BuyflowConstant.ANIRA){
                            /* US US344613 Implementation */
                                pageRef  = new PageReference('/apex/ANIRA_Buyflow?quoteid='+qid);
                            pageRef.setRedirect(true);
                        }
                        else{
                            pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=reviewquote&quoteid='+qid); //Review Quote page (with Cancel button)   - Not working
                            pageRef.setRedirect(true);
                        }
            }
            else if( (quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.DEALREG_APPROVED || quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.TSCREVIEW_CONFIRMED) && (quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREGISTRATION_APPROVED || quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREG_AUTO_APPROVED || quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.TSCREVIEW_CONFIRMED || quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.PRICINGSCHEDULE_REQUESTED)){
                        if(quoteObj.MACD_Change_Type__c == 'AddSite'){  
                            pageRef  = new PageReference('/apex/api_macd_dealreg?intervalTime=&mode=TNC&quoteid='+qid);                        
                            //Defect fix 168687
                            if(quoteObj.Buyflow_Step__c == ATTConstants.CONFIGURE_SITES){
                                pageRef  = new PageReference('/apex/API_MACD_PortalDesign_AVPN_MIS_BuyFlow??mode=confsites&quoteid='+qid);
                            }                       
                            pageRef.setRedirect(true);
                        } 
                        else{
                            if( code == BuyflowConstant.ANIRA){
                            /* US US344613 Implementation */
                                pageRef  = new PageReference('/apex/ANIRA_Buyflow?quoteid='+qid);
                                pageRef.setRedirect(true);
                            }
                            else{
                                pageRef  = new PageReference('/apex/dealreg?mode=regdeal&quoteid='+qid+'&code='+code);//Post Deal Reg page (with Order Service button) -working
                                //Defect fix 168687
                                if(quoteObj.Buyflow_Step__c == ATTConstants.CONFIGURE_SITES){
                                    pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=confsites&quoteid='+qid);
                                }
                                pageRef.setRedirect(true);
                            }
                        }
                    }
                    else if(quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREGISTRATION_PENDING){
                        if(quoteObj.MACD_Change_Type__c == 'AddSite'){  
                            pageRef  = new PageReference('/apex/api_macd_dealreg?code='+code+'&flag=true&mode=orderConf&quoteid='+qid);
                            pageRef.setRedirect(true);
                        }
                    }
                    else if((quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.DEALREG_DENIED  || quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.TSCREVIEW_DENIED) && (quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREGISTRATION_DENIED || quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.TSCREVIEW_DENIED)){   
                        If( code == BuyflowConstant.ANIRA){
                            /* US US344613 Implementation */
                                pageRef  = new PageReference('/apex/ANIRA_Buyflow?quoteid='+qid);
                            pageRef.setRedirect(true);
                        }
                        else{
                            pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=reviewquote&quoteid='+qid);//Review Quote page (with Submit Deal button) -working
                            pageRef.setRedirect(true);
                        }
                    } 
                    else if(quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.SPECIALPRICING_REQUESTED && (quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREGISTRATION_APPROVED || quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREG_AUTO_APPROVED)){
                        if(quoteObj.MACD_Change_Type__c == 'AddSite'){  
                            pageRef  = new PageReference('/apex/api_macd_dealreg?mode=spclPriceConf&quoteid='+qid);
                            pageRef.setRedirect(true);
                        }
                        else{
                            pageRef  = new PageReference('/apex/dealreg?mode=spclPriceConf&quoteid='+qid); //Show Special Pricing Submitted Page   -working
                            pageRef.setRedirect(true);
                        }
                    }
                    else if((quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.SPECIALPRICING_APPROVED || quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.SPECIALPRICING_DENIED) && (quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREGISTRATION_APPROVED || quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREG_AUTO_APPROVED))
                    {
                        //Radhika
                        if(quoteObj.MACD_Change_Type__c == 'AddSite'){  
                            //Defect fix 168687
                            if(quoteObj.Buyflow_Step__c == ATTConstants.CONFIGURE_SITES){
                                pageRef  = new PageReference('/apex/API_MACD_PortalDesign_AVPN_MIS_BuyFlow??mode=confsites&quoteid='+qid);
                            }else{
                                pageRef  = new PageReference('/apex/api_macd_dealreg?intervalTime=&mode=cartmode&quoteid='+qid);
                            }
                            pageRef.setRedirect(true);
                        }                   
                        else{
                            //Defect fix 168687
                            if(quoteObj.Buyflow_Step__c == ATTConstants.CONFIGURE_SITES){
                                pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=confsites&quoteid='+qid);
                            }
                            else{
                                pageRef  = new PageReference('/apex/dealreg?mode=regdeal&quoteid='+qid);//  -working   Show ?Post Deal Reg? page with ?Special Pricing? discounts displayed and a success  message 
                            }
                            pageRef.setRedirect(true);
                        }
                     }    
                    else if(quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.SPECIALPRICING_DENIED && quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREGISTRATION_APPROVED){
                        pageRef  = new PageReference('/apex/dealreg?mode=regdeal&quoteid='+qid); //Show ?Post Deal Reg? page with failure message.        -Working
                        pageRef.setRedirect(true);
                    }
                      // Logic modified to accomodate Add site order when stage is SP approval requested- vineet
                    else if(quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.SPAPPROVAL_REQUESTED && (quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.PRICINGSCHEDULE_PENDING || quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREGISTRATION_APPROVED || quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREG_AUTO_APPROVED) && isUserIsSPApprover == false)
                    {    
                        if(quoteObj.MACD_Change_Type__c == 'AddSite'){  
                            pageRef  = new PageReference('/apex/api_macd_dealreg?intervalTime=&mode=orderConf&quoteid='+qid);
                            pageRef.setRedirect(true);
                            } 
                             else{
                        pageRef  = new PageReference('/apex/dealreg?mode=orderConf&quoteid='+qid+'&code='+code);//If logged in user is SP User:  -working
                        pageRef.setRedirect(true);  }
                    } 
                    else if(quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.SPAPPROVAL_REQUESTED && (quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.PRICINGSCHEDULE_PENDING || quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREGISTRATION_APPROVED || quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREG_AUTO_APPROVED) && isUserIsSPApprover == true)
                    {   
                     if(quoteObj.MACD_Change_Type__c == 'AddSite'){  
                            pageRef  = new PageReference('/apex/api_macd_dealreg?intervalTime=&mode=TNC&quoteid='+qid);
                            pageRef.setRedirect(true);
                            } 
                             else{
                             if(quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c!=null && date.parse(quoteObj.Rate_Card_Effective_Date__c).daysBetween(quoteObj.Apttus_QPConfig__PriceListId__r.Apttus_Config2__EffectiveDate__c.date())>0)
                               {
                                      pageRef  = new PageReference('/apex/dealreg?mode=regdeal&quoteid='+qid+'&code='+code);//If logged in user is SP Approver:  -working
                                      pageRef.setRedirect(true);                           
                               }
                            else{   
                        pageRef  = new PageReference('/apex/dealreg?mode=TNC&quoteid='+qid+'&code='+code);//If logged in user is SP Approver:  -working
                        pageRef.setRedirect(true);}  
                        }
                    }
                    else if(quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.PRICINGSCHEDULE_REQUESTED && quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.PRICINGSCHEDULE_REQUESTED){
                        if(quoteObj.MACD_Change_Type__c == BuyflowConstant.ADDSITE){      
                           pageRef  = new PageReference('/apex/api_macd_dealreg?code='+code+'&mode=orderConf&quoteid='+qid);
                           pageRef.setRedirect(true);
                        }
                        else{
                            pageRef  = new PageReference('/apex/dealreg?mode=orderConf&quoteid='+qid+'&code='+code);//THANK YOU -working
                            pageRef.setRedirect(true);
                        }
                    }
                    else if(quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.SPAPPROVAL_REQUEST_DENIED && quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.DEALREGISTRATION_APPROVED){
                        if(quoteObj.MACD_Change_Type__c == 'AddSite'){  
                            pageRef  = new PageReference('/apex/api_macd_dealreg?intervalTime=&mode=TNC&quoteid='+qid);
                            pageRef.setRedirect(true);
                        } else {
                            pageRef  = new PageReference('/apex/dealreg?intervalTime=&mode=TNC&quoteId='+qid); //Show Contract Denial page -working
                            pageRef.setRedirect(true);
                        }
                    }
                    else if(quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.PENDINGADDITIONAL_SITE_DETAILS && quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.ORDERSUBMITTED){
                        if(quoteObj.MACD_Change_Type__c == BuyflowConstant.ADDSITE){ // Added by Swastika to redirect to MACD Add Provisioning pages
                            if(code == BuyflowConstant.AVPN){
                                pageRef  = new PageReference('/apex/MACD_AVPNRDSProvisioning?mode=rdssubmit&quoteid='+qid+'&pendingAddSites='+'true');//Show AVPN RDS page -working
                                pageRef.setRedirect(true);
                            }
                            else if(code == BuyflowConstant.AMIS){
                                pageRef  = new PageReference('/apex/MACD_MISRDSProvisioning?mode=rdssubmit&quoteid='+qid+'&pendingAddSites='+'true');//Show AMIS RDS page -working
                                pageRef.setRedirect(true);
                            }
                        } else{
                            if(code == BuyflowConstant.AVPN){
                                pageRef  = new PageReference('/apex/RDSProvisioning?mode=rdssubmit&quoteid='+qid+'&pendingAddSites='+'true');//Show AVPN RDS page -working
                                pageRef.setRedirect(true);
                            }
                            else if(code == BuyflowConstant.AMIS){
                                pageRef  = new PageReference('/apex/MISRDSProvisioning?mode=rdssubmit&quoteid='+qid+'&pendingAddSites='+'true');//Show AMIS RDS page -working
                                pageRef.setRedirect(true);
                            }
                            else if(code == BuyflowConstant.ASES){
                                pageRef  = new PageReference('/apex/ASERDSProvisioning?mode=rdssubmit&quoteid='+qid);//Show ASE RDS page -working
                                pageRef.setRedirect(true);
                            }
                        }
                    }
                    else if(quoteObj.Apttus_Proposal__Approval_Stage__c==BuyflowConstant.ORDERSUBMITTED && quoteObj.Apttus_Proposal__Opportunity__r.StageName==BuyflowConstant.ORDERSUBMITTED){
                        if(quoteObj.Eligible_for_RDS__c){
                        
                            if(code == BuyflowConstant.AVPN){
                                if(quoteObj.MACD_Change_Type__c == BuyflowConstant.ADDSITE){
                                   pageRef  = new PageReference('/apex/MACD_AVPNRDSProvisioning?mode=rdsconf&quoteid='+qid); //MACD ADD site
                                   pageRef.setRedirect(true);
                                }
                                else{                            
                                    pageRef  = new PageReference('/apex/RDSProvisioning?mode=rdsconf&quoteid='+qid);//Show AVPN RDS page -working
                                    pageRef.setRedirect(true);
                                }
                            }
                            else if(code == BuyflowConstant.AMIS){    
                                if(quoteObj.MACD_Change_Type__c == BuyflowConstant.ADDSITE){
                                   //pageRef  = new PageReference('/apex/MACD_MISRDSProvisioning?quoteid='+qid); //MACD ADD site
                                   pageRef  = new PageReference('/apex/macd_misrdsprovisioning?mode=rdsconf&quoteid='+qid);
                                   pageRef.setRedirect(true);
                                }
                                else{
                                    pageRef  = new PageReference('/apex/MISRDSProvisioning?mode=rdsconf&quoteid='+qid);//Show AMIS RDS page -working
                                    pageRef.setRedirect(true);
                                }
                            }
                            else if(code == BuyflowConstant.ASES){
                                pageRef  = new PageReference('/apex/ASERDSProvisioning?mode=rdsconf&quoteid='+qid);//Show ASE RDS page -working
                                pageRef.setRedirect(true);
                            }
                            else if(code == BuyflowConstant.AIA){
                                pageRef  = new PageReference('/apex/dealreg?mode=orderConf&quoteid='+qid+'&code='+code);
                                pageRef.setRedirect(true);
                            }
                        }
                        else{
                           If( code == BuyflowConstant.ANIRA){
                            /* US US344613 Implementation */
                                pageRef  = new PageReference('/apex/ANIRA_Buyflow?quoteid='+qid);
                            pageRef.setRedirect(true);
                        }else{
                            pageRef  = new PageReference('/apex/dealreg?mode=orderConf&quoteid='+qid);//ORDER CONFIRMATION PAGE  -working
                            pageRef.setRedirect(true);
                           }
                        }
                    }
                    
                    //coded as per the defect 74987 starts
                    else if(quoteObj.MACD_Change_Type__c == BuyflowConstant.ADDSITE){
                    
                        if(quoteObj.buyflow_step__c==SpecialCharacterConstant.CONCAT || quoteObj.buyflow_step__c== null ){
                            pageRef  = new PageReference('/apex/API_MACD_Buyflow?nooverride=1&quoteid='+qid+'&sub_acount_number='+this.subAccNo);
                            pageRef.setRedirect(true);  
                        }else{
                            
                        }
                    }else{
                    }   
                    
                    //IPflex Redirection 
                    if(quoteObj.IPFlexTNCPage__c == true){
                        pageRef  = new PageReference('/apex/dealreg?mode=ipflexTNC&quoteid='+qid+'&code='+code);
                        pageRef.setRedirect(true);
                    } 
                    
                    //ASE Redirection
                    if(quoteObj.Apttus_Proposal__Approval_Stage__c=='Order Submitted' && quoteObj.Apttus_Proposal__Opportunity__r.StageName=='Order Submitted' && code == 'ASE' && quoteObj.ASE_MACD_Deal__c == false){
                        pageRef  = new PageReference('/apex/PortalDesign_Buyflow?mode=reviewquote&quoteid='+qid);
                        pageRef.setRedirect(true); 
                    }
                    if(quoteObj.ASE_MACD_Deal__c == true && code == 'ASE'){
                        pageRef  = new PageReference('/apex/MACD_ASE_NetworkSites?quoteid='+qid);
                        pageRef.setRedirect(true); 
                    }
                }
                //Contract Renewal Redirection
                if(quoteObj.Renewal_Contract__c == true){
                    if((quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('Draft') && quoteObj.Apttus_Proposal__Opportunity__c == null) || quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('Processing Renewal') || quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('Pending Deal Reg') || (quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('Deal Reg Approved') && quoteObj.CR_Approved__c == false)){
                        pageRef = new PageReference('/apex/RenewContract?mode=terminfo&quoteid='+qid+'&sub_account_number='+this.subAccNo);
                    }else if((quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('Draft') && quoteObj.Apttus_Proposal__Opportunity__c != null) || quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('Deal Reg Approved') || quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('Special Pricing Approved') || quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('Special Pricing Denied')){
                        pageRef = new PageReference('/apex/RenewContract?mode=reviewquote&quoteid='+qid+'&sub_account_number='+this.subAccNo);
                    }else if(quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('Special Pricing Requested')){
                        pageRef = new PageReference('/apex/RenewContract?mode=spclPriceConf&quoteid='+qid+'&sub_account_number='+this.subAccNo);
                    }else if((quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(BuyflowConstant.SPAPPROVAL_REQUESTED) && isUserIsSPApprover == true)){                
                        pageRef = new PageReference('/apex/RenewContract?mode=TNC&flow=contractRenewal&quoteid='+qid+'&sub_account_number='+this.subAccNo);   
                    }else if(quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(BuyflowConstant.PRICINGSCHEDULE_REQUESTED) || (quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(BuyflowConstant.SPAPPROVAL_REQUESTED) && isUserIsSPApprover == false) || quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(BuyflowConstant.SPAPPROVAL_REQUEST_DENIED) || quoteObj.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase(BuyflowConstant.ORDERSUBMITTED)){
                        pageRef = new PageReference('/apex/RenewContract?mode=orderConf&flow=contractRenewal&quoteid='+qid+'&sub_account_number='+this.subAccNo);
                    }
                    pageRef.setRedirect(true);
                }
            system.debug('pageref returned is: '+pageRef);
            }
            return pageRef;
        } catch (Exception e) {
            String exceptionString = ATTException.constructExceptionMessageString(e);
            ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);                        
            return null;
        }
    }

    /* 
     Name: setQuoteId
     Description: 
     */ 
    public void setQuoteId(){
        try{
            quoteId = System.currentPageReference().getParameters().get('quotID');
        }catch(Exception excep){
        ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
        }
    }
    /*********************************************
    * Method name : setErrorMessage
    * Description : sets error Meassage
    * Return Type : void
    * Parameter : None
    *********************************************/
/* 
 Name: setErrorMessage
 Description: 
 */ 
    public void setErrorMessage(){
        ErrorMessage = null;
    }
    /**************************************
    * Method name : callLoginDispatchService
    * Description : This method calls the service and return the url for the product information.
    * Return Type : String
    * Parameter : None
    **************************************/
/* 
 Name: callLoginDispatchService
 Description: 
 */ 
    public void callLoginDispatchService(){
        try{}
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    } 
/* 
 Name: callLoginDispatchServiceQO
 Description: 
 */ 
    public void callLoginDispatchServiceQO(){
        quoteId = System.currentPageReference().getParameters().get('quotID');
        String encryptedString=null;
        List<Map<String,String>> requestBeanList=null;
        try{
          User usr = new User();
            usr = [Select Id,Name,ContactId FROM User WHERE id=:userinfo.getuserId()];
            
            Contact cont = new Contact();
            if(usr.ContactId != null) {  
                cont = [SELECT Id, Name, AccountId,Account.Name, Premier_Login__c FROM Contact WHERE Id=:usr.ContactId];
               
            }
            Apex2JSON_LoginDispatchRequest requestBean = new Apex2JSON_LoginDispatchRequest();
            LoginDispatchService objService= new LoginDispatchService();
            Apttus_Proposal__Proposal__c quoteObject = new Apttus_Proposal__Proposal__c();
            if(!string.isBlank(quoteId)){
                quoteObject = [select id,Name, End_Customer__c, End_Customer__r.Name,Premier_Order_ID__c, Apttus_Proposal__Account__r.Current_Tier__c,Apttus_Proposal__Account__r.Premier_Login__c from Apttus_Proposal__Proposal__c where Apttus_Proposal__Proposal__c.id=: quoteId];
                List<String> qouteOb = new List<String>();
                qouteOb.add(quoteObject.End_Customer__r.Name);
                qouteOb.add(quoteObject.Apttus_Proposal__Account__r.Current_Tier__c);
                requestBeanList= new List<Map<String,String>>();
                Map<String,String> mapObj= new Map<String,String>();                        
                mapObj.put('ProvisioningServiceID',quoteObject.Name); //a2xm00000008ZC3AAM
                mapObj.put('SourceSystemUserID',quoteObject.End_Customer__r.Name);                     
                mapObj.put('ProfileType',(!string.isBlank(quoteObject.Apttus_Proposal__Account__r.Current_Tier__c)?quoteObject.Apttus_Proposal__Account__r.Current_Tier__c.toUpperCase():''));                                                
                mapObj.put('PremierLogin',(!string.isBlank(cont.Premier_Login__c)?cont.Premier_Login__c:'')); 
                mapObj.put('PremierOrderId',(!string.isBlank(quoteObject.Premier_Order_ID__c)?quoteObject.Premier_Order_ID__c:''));
                requestBeanList.add(mapObj);
            }
            requestBean = objService.populateRequestBean(requestBeanList);
            Apex2JSON_LoginDispatchResponse responseBean = new Apex2JSON_LoginDispatchResponse();
            responseBean =(Apex2JSON_LoginDispatchResponse)objService.handleLoginDispatchService(requestBean);
            if(responseBean!=null&& responseBean.LoginDispatchResponse!=null &&
                    responseBean.LoginDispatchResponse.LoginDispatch!=null &&
                    responseBean.LoginDispatchResponse.LoginDispatch.response!=null) {
                if(!responseBean.LoginDispatchResponse.LoginDispatch.response.code.equals('200') &&
                        responseBean.LoginDispatchResponse.LoginDispatch.response.description!=null &&
                        responseBean.LoginDispatchResponse.LoginDispatch.TokenURL == null) {
                    ErrorMessage = (!string.isBlank(responseBean.LoginDispatchResponse.LoginDispatch.response.description))?responseBean.LoginDispatchResponse.LoginDispatch.response.description:'';
                    encryptedUrl = '';
                    return;
                } else if(responseBean.LoginDispatchResponse.LoginDispatch.response.code.equals('200') &&
                        !String.isBlank(responseBean.LoginDispatchResponse.LoginDispatch.TokenURL)){
                    encryptedString=responseBean.LoginDispatchResponse.LoginDispatch.TokenURL;
                   Blob encryptedUrl1 = EncodingUtil.base64Decode(encryptedString);
                   ATnT_Encrypt_LD__c base64Key = ATnT_Encrypt_LD__c.getInstance();
                   Blob key = EncodingUtil.base64Decode(base64Key.Encrypted_Key_Value__c);
                   Blob deEncryptedUrlB = Crypto.decryptWithManagedIV('AES256', key, encryptedUrl1);
                   finalDeencryptedUrl = deEncryptedUrlB.toString();
                } else {
                    ErrorMessage = 'Premier is unavailable. Please try again later.';
                encryptedUrl = '';
                }
                         if(quoteObject !=null)
                        {
                            update quoteObject;
                        }
            }else {
                ErrorMessage = 'Premier is unavailable. Please try again later.';
                encryptedUrl = '';
                return;
            }
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
       ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }    
    
     public String duplicateQuoteID =SpecialCharacterConstant.CONCAT;
/* 
 Name: callDuplicate
 Description: 
 */ 
     public PageReference callDuplicate() {
        duplicateQuoteID = ApexPages.currentPage().getParameters().get('duplicateQuoteID');
        String  childobjecttypes1= 'Apttus_Proposal__Proposal_Line_Item__c,AT_T_Customer_Site_Quote__c,Apttus_Config2__ProductConfiguration__c';
         
         Apttus_Proposal__Proposal__c cloneproposalObj = new Apttus_Proposal__Proposal__c(); //proposalObj.clone();
         Apttus_Proposal__Proposal__c clonedQuote = null;
         Apttus_Proposal__Proposal__c clonedQuoteName = null;
         try{
            if (duplicateQuoteID != null) 
            {
                quoteObj = [select Name,Product_New_Name__c, Product__c, Apttus_Proposal__Account__c, End_Customer__c, End_Customer__r.Name, End_Customer__r.Mailing_Street_Address__c, End_Customer__r.City__c,
                    End_Customer__r.Zip__c, End_Customer__r.State__c, Apttus_QPConfig__PriceListId__c, End_Customer__r.DUNS__c, Owner.Name, Apttus_Proposal__ExpectedEndDate__c, Product__r.name,
                    Product__r.productcode, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Opportunity__r.StageName, Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Payment_Term__c,ASE_MACD_Deal__c,
                    Apttus_Proposal__Approval_Stage__c,Apttus_Proposal__Proposal_Expiration_Date__c, Ethernet_Configuration__c, Traffic_Jurisdiction__c, Buyflow_Step__c, Apttus_Proposal__ExpectedStartDate__c from
                    Apttus_Proposal__Proposal__c where id = : duplicateQuoteID ];
            }
            clonedQuote = quoteObj.clone();    
            clonedQuote.Apttus_Proposal__Account__c = quoteObj.Apttus_Proposal__Account__c;
            clonedQuote.End_Customer__c = quoteObj.End_Customer__c;
            clonedQuote.Apttus_Proposal__Approval_Stage__c=BuyflowConstant.DRAFT;
            clonedQuote.Apttus_Proposal__Opportunity__c=null;
            clonedQuote.Buyflow_Step__c=BuyflowConstant.CONFIGURESITES;
            clonedQuote.OwnerId=UserInfo.GetUserId();
            clonedQuote.Apttus_Proposal__ExpectedStartDate__c=System.Today();
            clonedQuote.Apttus_Proposal__Proposal_Name__c = quoteObj.Apttus_Proposal__Proposal_Name__c + '-Duplicate';
    
            insert clonedQuote;            
            
            List <AT_T_Customer_Site_Quote__c> custSiteQuoteLst = [Select Id, Name, AT_T_Customer_Site__c, hub__c, AT_T_Quote__c, Customer__c, AT_T_Quote__r.Product__c, AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,
                AT_T_Quote__r.Name, AT_T_Quote__r.Apttus_Proposal__Payment_Term__c, AT_T_Quote__r.Apttus_QPConfig__PriceListId__c, AT_T_Quote__r.Product__r.Name from AT_T_Customer_Site_Quote__c
                where AT_T_Quote__c = : duplicateQuoteID ];
            List <AT_T_Customer_Site_Quote__c> custSiteQuoteLstupdate = new List <AT_T_Customer_Site_Quote__c>();
    
            for (AT_T_Customer_Site_Quote__c cs: custSiteQuoteLst) 
            {
                AT_T_Customer_Site_Quote__c ncs = new AT_T_Customer_Site_Quote__c();
                ncs = cs.clone();
                ncs.AT_T_Quote__c = clonedQuote.id;
                ncs.Type__c = BuyflowConstant.NONMACD;
                //ncs.Site_ID__c = String.ValueOf(randNo + i++);
                custSiteQuoteLstupdate.add(ncs);
            }
            insert custSiteQuoteLstupdate;
            update custSiteQuoteLstupdate;
            
            List <AT_T_Customer_Site_Quote__c> newCustSiteQuoteLst = [Select Id, Name, AT_T_Customer_Site__c, hub__c, AT_T_Quote__c, Customer__c, AT_T_Quote__r.Product__c, AT_T_Quote__r.Apttus_Proposal__Proposal_Name__c,
                AT_T_Quote__r.Name, AT_T_Quote__r.Apttus_Proposal__Payment_Term__c, AT_T_Quote__r.Apttus_QPConfig__PriceListId__c, AT_T_Quote__r.Product__r.Name from AT_T_Customer_Site_Quote__c
                where AT_T_Quote__c = : clonedQuote.Id];
              
            for (AT_T_Customer_Site_Quote__c site: newCustSiteQuoteLst) 
            {
                site.Name = site.Id;
            }
            update newCustSiteQuoteLst;  
                
            prodConfigList = [select Apttus_Config2__Status__c, Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c = : quoteObj.id Limit 1];
            if (prodConfigList != null && prodConfigList.size() > 0) 
            {
                Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
                request.QuoteId = clonedQuote.Id;
                Apttus_CPQApi.CPQ.CreateCartResponseDO response = Apttus_CPQApi.CPQWebService.createCart(request);
                String cartId = response.CartID;
                                                                     
                List <Apttus_Config2__LineItem__c> lineItemList = new List < Apttus_Config2__LineItem__c > ();
                List <Apttus_Config2__LineItem__c> pli = [SELECT id,Apttus_Config2__LineNumber__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.id = : quoteObj.id and Apttus_Config2__ConfigurationId__c = : prodConfigList[0].Id];
               
                for(Apttus_Config2__LineItem__c plir : pli)
                {
                    String soqlline = API_Utils.getCreatableFieldsSOQL('Apttus_Config2__LineItem__c','id=\''+plir.Id+'\'');     
                    Apttus_Config2__LineItem__c pl = (Apttus_Config2__LineItem__c)Database.query(soqlline);
                    Apttus_Config2__LineItem__c newpl = pl.clone(false,true,true,true);
                    newpl.Apttus_Config2__ConfigurationId__c= cartId; 
                    lineItemList.add(newpl);
                }

                if (lineItemList.size() > 0) 
                {
                    insert lineItemList;
                }
                
                Set<Id> attributeIdsToClone = new Set<Id>();
                
                List <Apttus_Config2__LineItem__c> newLineItemList = [SELECT id, Apttus_Config2__LineNumber__c, Apttus_Config2__AttributeValueId__c,Apttus_Config2__ItemSequence__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.id = :clonedQuote.id and Apttus_Config2__ConfigurationId__c = :cartId ORDER BY Apttus_Config2__LineNumber__c, Apttus_Config2__ItemSequence__c];
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
                
                List<Apttus_Config2__ProductAttributeValue__c> oldAttributeList = [SELECT Access_Speed_AVPN__c,Access_Speed_MIS__c,Access_Type_AVPN__c,Access_Type_MIS__c,Access_Type__c,Additional_DNS__c,Apttus_Config2__Color__c,Apttus_Config2__IsTransient__c,Apttus_Config2__LineItemId__c,Apttus_Config2__Vendor__c,AT_T_Customer_Site__c,AT_T_IP_Flexible_Reach__c,cartId__c,Consume_for_Use_Fan__c,CoS__c,
                                                                                   CreatedById,CreatedDate,Dynamic__c,End_Customer_FAN__c,ethernet_configuration__c,First_Choice_AT_T_Data_Center__c,Hi_Cap_Flex__c,Id,Installation_Option_AVPN__c,Installation_Option_MIS__c,Install_Option_AVPN__c,Install_Option_MIS__c,Interface_Type_AVPN__c,Interface_Type_MIS__c,Interface_Type__c,IsDeleted,LastActivityDate,
                                                                                   LastModifiedById,LastModifiedDate,Line_Number__c,Managed_Router__c,MileageAbove20__c,MileageAbove50__c,Mileage__c,Name,Policy_1_Local_Protection__c,Policy_2_Remote_Application__c,Port_Speed_AVPN__c,Port_Speed_MIS__c,Port_Speed__c,Port_Type_AVPN__c,Port_Type_MIS__c,Static__c,SystemModstamp,
                                                                                   traffic_jurisdiction__c,VASA_Region__c,VLANs_Logical_Channels__c from Apttus_Config2__ProductAttributeValue__c where Id IN :attributeIdsToClone];
                
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
                for( Apttus_Config2__LineItem__c lineItem : lineItemList )
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
                update lineItemList;
            }
           PageReference reconfigurePage;
            if (quoteObj.Product__r.productcode == BuyflowConstant.AVPN || quoteObj.Product__r.productcode == BuyflowConstant.AMIS || quoteObj.Product__r.productcode == BuyflowConstant.ASES) {
                reconfigurePage = system.page.PortalDesign_Buyflow;
            }else {
                reconfigurePage = system.page.Buyflow;
            }
    
            reconfigurePage.getParameters().put('mode', 'confsites');
            reconfigurePage.getParameters().put('quoteid', clonedQuote.Id);
            reconfigurePage.getParameters().put('siteid', siteConfigureId);
            return reconfigurePage;
        } 
        catch (Exception e) {
           ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
          }
            
        return null;
     }
     
     // The Below method has been replaced with the above method as part of QC Defect 49120
    /* 
     Name: callDuplicateOld
     Description: 
     */ 
     public PageReference callDuplicateOld() {
        duplicateQuoteID = ApexPages.currentPage().getParameters().get('duplicateQuoteID');
        String  childobjecttypes1= 'Apttus_Proposal__Proposal_Line_Item__c,AT_T_Customer_Site_Quote__c,Apttus_Config2__ProductConfiguration__c';

        Apttus_Proposal__Proposal__c cloneproposalObj = new Apttus_Proposal__Proposal__c(); //proposalObj.clone();
        try{
            List<Apttus_Proposal__Proposal__c> listOfQuoteDetailsCloned = new List<Apttus_Proposal__Proposal__c>();
            if(Id.valueOf(duplicateQuoteID) != null){
                Apttus_Proposal__Proposal__c clonedAccObj = null;
                for(Apttus_Proposal__Proposal__c accObj: [select name,Apttus_QPConfig__PriceListId__c,Product__c,
                                                            Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Account__c,
                                                            Apttus_Proposal__Approval_Stage__c, Apttus_Proposal__Opportunity__c,
                                                            Apttus_Proposal__ExpectedStartDate__c, Traffic_Jurisdiction__c,
                                                            Apttus_Proposal__ExpectedEndDate__c, Related_End_Customer__c,
                                                            Apttus_Proposal__Payment_Term__c, Buyflow_Step__c, VASA_Validation_Indicator__c,
                                                            Parent_Quote__c from Apttus_Proposal__Proposal__c where Id=:duplicateQuoteID limit 1]) {
                    clonedAccObj = new Apttus_Proposal__Proposal__c();
                    clonedAccObj.Apttus_QPConfig__PriceListId__c = accObj.Apttus_QPConfig__PriceListId__c;
                    clonedAccObj.Product__c = accObj.Product__c;
                    clonedAccObj.Apttus_Proposal__Proposal_Name__c = accObj.Apttus_Proposal__Proposal_Name__c;
                    clonedAccObj.Apttus_Proposal__Account__c= accObj.Apttus_Proposal__Account__c;
                    clonedAccObj.Apttus_Proposal__Approval_Stage__c = accObj.Apttus_Proposal__Approval_Stage__c;
                    clonedAccObj.Apttus_Proposal__Opportunity__c = accObj.Apttus_Proposal__Opportunity__c;
                    clonedAccObj.Apttus_Proposal__ExpectedStartDate__c = accObj.Apttus_Proposal__ExpectedStartDate__c; 
                    clonedAccObj.Traffic_Jurisdiction__c = accObj.Traffic_Jurisdiction__c;
                    clonedAccObj.Apttus_Proposal__ExpectedEndDate__c = accObj.Apttus_Proposal__ExpectedEndDate__c;
                    clonedAccObj.Related_End_Customer__c = accObj.Related_End_Customer__c;
                    clonedAccObj.Apttus_Proposal__Payment_Term__c = accObj.Apttus_Proposal__Payment_Term__c;
                    clonedAccObj.Buyflow_Step__c = accObj.Buyflow_Step__c;
                    clonedAccObj.VASA_Validation_Indicator__c = accObj.VASA_Validation_Indicator__c;
                    clonedAccObj.Parent_Quote__c = accObj.Parent_Quote__c;
                    listOfQuoteDetailsCloned.add(clonedAccObj);
                }
                
                insert listOfQuoteDetailsCloned;
                
                List<Apttus_Proposal__Proposal_Line_Item__c> listOfLineItemsCloned = new List<Apttus_Proposal__Proposal_Line_Item__c>();
                Apttus_Proposal__Proposal_Line_Item__c clonedlistOfLineItemsObj = null;
                
                for(Apttus_Proposal__Proposal_Line_Item__c  line_ItemObj:[select Apttus_Proposal__Product__c,Apttus_Proposal__Proposal__c,
                                                                            Apttus_QPConfig__OptionId__c,Apttus_QPConfig__ChargeType__c, Apttus_QPConfig__ProductOptionId__c,
                                                                            Apttus_QPConfig__ClassificationId__c,Apttus_QPConfig__ConfigurationId__c, 
                                                                            Apttus_QPConfig__AdjustedPrice__c,Apttus_QPConfig__ItemSequence__c,
                                                                            Apttus_QPConfig__LineNumber__c, AT_T_Customer_Site__c,
                                                                            //Apttus_QPApprov__Approval_Status__c,
                                                                            Apttus_QPConfig__BaseExtendedPrice__c,
                                                                            Apttus_QPConfig__AssetId__c, Apttus_QPConfig__AssetLineItemId__c,
                                                                            Apttus_QPConfig__AttributeValueId__c,Apttus_QPConfig__LineStatus__c,
                                                                            Apttus_QPConfig__BaseProductId__c,Apttus_QPConfig__LineType__c,
                                                                            Apttus_QPConfig__ListPrice__c, Apttus_QPConfig__LocationId__c,
                                                                            Apttus_QPConfig__NetAdjustmentPercent__c,Apttus_QPConfig__NetPrice__c,
                                                                            Apttus_QPConfig__OptionCost__c,Apttus_QPConfig__OptionPrice__c,
                                                                            Apttus_QPConfig__Frequency__c,Apttus_QPConfig__Term__c,
                                                                            Apttus_QPConfig__PriceUom__c, Apttus_QPConfig__PrimaryLineNumber__c,
                                                                            Apttus_QPConfig__Uom__c,Apttus_QPConfig__Quantity2__c,
                                                                            Apttus_QPConfig__DerivedFromId__c, Apttus_QPConfig__EndDate__c,
                                                                            Apttus_QPConfig__ExtendedCost__c,Apttus_QPConfig__PriceListId__c,
                                                                            Apttus_QPConfig__PriceListItemId__c,Apttus_QPConfig__PriceMethod__c,
                                                                            Apttus_QPConfig__PriceType__c,Apttus_QPConfig__SellingFrequency__c,
                                                                            Apttus_QPConfig__SellingTerm__c, Apttus_QPConfig__StartDate__c,
                                                                            Apttus_QPConfig__SummaryGroupId__c
                                                                            From Apttus_Proposal__Proposal_Line_Item__c 
                                                                            Where Apttus_Proposal__Proposal__c=:duplicateQuoteID]) {
                    clonedlistOfLineItemsObj = new Apttus_Proposal__Proposal_Line_Item__c();
                    clonedlistOfLineItemsObj.Apttus_Proposal__Product__c = line_ItemObj.Apttus_Proposal__Product__c;
                    clonedlistOfLineItemsObj.Apttus_Proposal__Proposal__c = listOfQuoteDetailsCloned[0].id;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__ChargeType__c= line_ItemObj.Apttus_QPConfig__ChargeType__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__ProductOptionId__c= line_ItemObj.Apttus_QPConfig__ProductOptionId__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__ClassificationId__c= line_ItemObj.Apttus_QPConfig__ClassificationId__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__ConfigurationId__c= line_ItemObj.Apttus_QPConfig__ConfigurationId__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__AdjustedPrice__c= line_ItemObj.Apttus_QPConfig__AdjustedPrice__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__ItemSequence__c= line_ItemObj.Apttus_QPConfig__ItemSequence__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__LineNumber__c= line_ItemObj.Apttus_QPConfig__LineNumber__c;
                    clonedlistOfLineItemsObj.AT_T_Customer_Site__c= line_ItemObj.AT_T_Customer_Site__c;
                    //clonedlistOfLineItemsObj.Apttus_QPApprov__Approval_Status__c= line_ItemObj.Apttus_QPApprov__Approval_Status__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__BaseExtendedPrice__c= line_ItemObj.Apttus_QPConfig__BaseExtendedPrice__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__AssetId__c= line_ItemObj.Apttus_QPConfig__AssetId__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__AssetLineItemId__c= line_ItemObj.Apttus_QPConfig__AssetLineItemId__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__AttributeValueId__c= line_ItemObj.Apttus_QPConfig__AttributeValueId__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__LineStatus__c= line_ItemObj.Apttus_QPConfig__LineStatus__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__BaseProductId__c= line_ItemObj.Apttus_QPConfig__BaseProductId__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__LineType__c= line_ItemObj.Apttus_QPConfig__LineType__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__ListPrice__c= line_ItemObj.Apttus_QPConfig__ListPrice__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__LocationId__c= line_ItemObj.Apttus_QPConfig__LocationId__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__NetAdjustmentPercent__c= line_ItemObj.Apttus_QPConfig__NetAdjustmentPercent__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__NetPrice__c= line_ItemObj.Apttus_QPConfig__NetPrice__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__OptionCost__c= line_ItemObj.Apttus_QPConfig__OptionCost__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__OptionPrice__c= line_ItemObj.Apttus_QPConfig__OptionPrice__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__Frequency__c= line_ItemObj.Apttus_QPConfig__Frequency__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__Term__c= line_ItemObj.Apttus_QPConfig__Term__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__PriceUom__c= line_ItemObj.Apttus_QPConfig__PriceUom__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__PrimaryLineNumber__c= line_ItemObj.Apttus_QPConfig__PrimaryLineNumber__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__Uom__c= line_ItemObj.Apttus_QPConfig__Uom__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__Quantity2__c= line_ItemObj.Apttus_QPConfig__Quantity2__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__DerivedFromId__c= line_ItemObj.Apttus_QPConfig__DerivedFromId__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__EndDate__c= line_ItemObj.Apttus_QPConfig__EndDate__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__ExtendedCost__c= line_ItemObj.Apttus_QPConfig__ExtendedCost__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__PriceListId__c= line_ItemObj.Apttus_QPConfig__PriceListId__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__PriceListItemId__c= line_ItemObj.Apttus_QPConfig__PriceListItemId__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__PriceMethod__c= line_ItemObj.Apttus_QPConfig__PriceMethod__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__PriceType__c= line_ItemObj.Apttus_QPConfig__PriceType__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__SellingFrequency__c= line_ItemObj.Apttus_QPConfig__SellingFrequency__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__SellingTerm__c= line_ItemObj.Apttus_QPConfig__SellingTerm__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__StartDate__c= line_ItemObj.Apttus_QPConfig__StartDate__c;
                    clonedlistOfLineItemsObj.Apttus_QPConfig__SummaryGroupId__c= line_ItemObj.Apttus_QPConfig__SummaryGroupId__c;
                    
                    listOfLineItemsCloned.add(clonedlistOfLineItemsObj);
                }
                
                insert listOfLineItemsCloned ;
             
                //Site Quote
                List<AT_T_Customer_Site_Quote__c> listOfSiteQuotesCloned = new List<AT_T_Customer_Site_Quote__c>();
                AT_T_Customer_Site_Quote__c clonedSiteObj = new AT_T_Customer_Site_Quote__c();
                for(AT_T_Customer_Site_Quote__c  siteObj:[select name, AT_T_Customer_Site__c,
                                                            AT_T_Quote__c,Customer__c,Hub__c,IsSelected__c,
                                                            RDS_JSON_Request__c, VASARegion__c
                                                            from AT_T_Customer_Site_Quote__c where  AT_T_Quote__c=:duplicateQuoteID]) {
                    clonedSiteObj= new AT_T_Customer_Site_Quote__c();
                    clonedSiteObj.name= siteObj.name;
                    clonedSiteObj.AT_T_Customer_Site__c= siteObj.AT_T_Customer_Site__c;
                    clonedSiteObj.AT_T_Quote__c= listOfQuoteDetailsCloned[0].id;
                    clonedSiteObj.Customer__c= siteObj.Customer__c;
                    clonedSiteObj.Hub__c= siteObj.Hub__c;
                    clonedSiteObj.IsSelected__c= siteObj.IsSelected__c;
                    clonedSiteObj.RDS_JSON_Request__c= siteObj.RDS_JSON_Request__c;
                    clonedSiteObj.VASARegion__c= siteObj.VASARegion__c;
                
                    listOfSiteQuotesCloned.add(clonedSiteObj);
                }
                
                insert listOfSiteQuotesCloned ;
                
                //Site Product Configration
                
                List<Apttus_Config2__ProductConfiguration__c> listOfProdConfigCloned = new List<Apttus_Config2__ProductConfiguration__c>();
                Apttus_Config2__ProductConfiguration__c clonedProdObj = null;
                
                for(Apttus_Config2__ProductConfiguration__c  prodObj:[select Name,Apttus_Config2__SummaryGroupType__c,
                                                                            Apttus_Config2__BusinessObjectType__c, Apttus_Config2__Status__c,
                                                                            Apttus_Config2__AccountId__c, Apttus_Config2__LocationId__c,
                                                                            Apttus_Config2__PriceListId__c,Apttus_Config2__EffectivePriceListId__c,
                                                                            Apttus_QPConfig__Proposald__c, Apttus_Config2__PrimordialId__c,
                                                                            Apttus_Config2__AncestorId__c
                                                                            From Apttus_Config2__ProductConfiguration__c 
                                                                            Where Apttus_QPConfig__Proposald__c=:duplicateQuoteID]) {
                    clonedProdObj = new Apttus_Config2__ProductConfiguration__c();
                    clonedProdObj.Name = prodObj.Name;
                    clonedProdObj.Apttus_Config2__SummaryGroupType__c=prodObj.Apttus_Config2__SummaryGroupType__c;
                    clonedProdObj.Apttus_Config2__BusinessObjectType__c=prodObj.Apttus_Config2__BusinessObjectType__c;
                    clonedProdObj.Apttus_Config2__Status__c=prodObj.Apttus_Config2__Status__c;
                    clonedProdObj.Apttus_Config2__AccountId__c=prodObj.Apttus_Config2__AccountId__c;
                    clonedProdObj.Apttus_Config2__LocationId__c=prodObj.Apttus_Config2__LocationId__c;
                    clonedProdObj.Apttus_Config2__PriceListId__c=prodObj.Apttus_Config2__PriceListId__c;
                    clonedProdObj.Apttus_Config2__EffectivePriceListId__c=prodObj.Apttus_Config2__EffectivePriceListId__c;
                    clonedProdObj.Apttus_QPConfig__Proposald__c= listOfQuoteDetailsCloned[0].id;//prodObj.Apttus_QPConfig__Proposald__c;
                    clonedProdObj.Apttus_Config2__PrimordialId__c=prodObj.Apttus_Config2__PrimordialId__c;
                    clonedProdObj.Apttus_Config2__AncestorId__c=prodObj.Apttus_Config2__AncestorId__c;
                
                    listOfProdConfigCloned.add(clonedProdObj);
                }
                
                insert listOfProdConfigCloned;
            }
            
            //Start Defect: DE97572 : Navigating the Duplicated quote to proper buyflow step: RK 01/08/2015
            duplicatedQuoteId = listOfQuoteDetailsCloned[0].id;
            //Call checkBuyFlowStatusAndRedirect method to navigate to proper buyflow
            PageReference pageRef = checkBuyFlowStatusAndRedirect();
            duplicatedQuoteId = SpecialCharacterConstant.CONCAT;
            //PageReference  pageRef  = new PageReference(SpecialCharacterConstant.+listOfQuoteDetailsCloned[0].id);
            //End: RK
            //pageRef.setRedirect(true);
            return pageRef ;
        } catch(Exception e) {
            return null;
        }
        return null;
    }
    
    //Above method can be uncommented and checked for Duplicate action
    
    /*@Prem 28-11*/
    
    public String callDeleteID = SpecialCharacterConstant.CONCAT;
    /***********************************************************************************************
    Method: callDelete
    Description: 
    @Param : none
    @return: none 
    @throws: none
    Version :  
    Modification Log :
    Developer        Date            Description
    ******************************************/ 
    /* 
     Name: callDelete
     Description: 
     */ 
    public PageReference callDelete() {
        callDeleteID = ApexPages.currentPage().getParameters().get('callDeleteID');
        try{
            if(Id.valueOf(callDeleteID) != null){
                Apttus_Proposal__Proposal__c proposalObj = [select Id, Name, Apttus_Proposal__Approval_Stage__c 
                                                            From Apttus_Proposal__Proposal__c where Id =:callDeleteID];
                proposalObj.Apttus_Proposal__Approval_Stage__c = BuyflowConstant.DELETED;
                update proposalObj;
            }   
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        PageReference pageRef  = new PageReference('/apex/PortalDashboard_UI');
       
        return pageRef ;
        
    }
    
    /*
     * Start: Changes for Dynamic Datatable: RK
     *
     */
    private static String searchText = SpecialCharacterConstant.CONCAT;
    private static String searchText2 = SpecialCharacterConstant.CONCAT;
    
    /*
     * @description: Inner class to define shape of JSON response
     *
     */
    global class Response {
        public Integer sEcho;
        public Integer iTotalRecords;
        public Integer iTotalDisplayRecords;
        Sobject[] aaData;
    /***********************************************************************************************
    Method: Response
    Description: 
    @Param : Integer,Sobject
    @return: none 
    @throws: none
    Version :  
    Modification Log :
    Developer        Date            Description
    ******************************************/ 
/* 
 Name: Response
 Description: 
 */ 
        public Response(Integer echo, Integer total, Sobject[] sobs) {
            this.sEcho = echo;
            this.iTotalRecords = total;
            this.iTotalDisplayRecords = total;
            this.aaData = sobs;
        }
    }
    
    /*
     * @description: Remote Action which controls the dynamic behaviour of Datatable
     * @return type: Response
     * @param: List<Map<String, Object>>
        Modification Log :
         Developer        Date            Description
         Akshay Agarwal   7/26/2016        Hiding Expired  Quote from dashboard
     */
    @RemoteAction
    global static Response fetchQuoteRecords(List<Map<String, Object>> request) {
        Id partnerAccId;
        String deleted=BuyflowConstant.DELETED ;
        User usr = [Select Id,Name,Is_Approver__c,ContactId,Email FROM User WHERE id=:userinfo.getuserId()];
        Contact con = new Contact();
        if(usr.ContactId != null) {
            con = [SELECT Id, Name, AccountId,Account.Name FROM Contact WHERE Id=:usr.ContactId];
            if(con.AccountId != null) {
                partnerAccId = con.AccountId;
            }
        } else{
            LIST<Account> idAcc = [SELECT Id FROM Account WHERE name='AT&T_SP' limit 1 ];
            if(!idAcc.isEmpty()) {
                partnerAccId = idAcc[0].Id;
            }
            
        }
        Params p = new Params(request);
        String whereClauseText = '';
        String setclauseText='';
        
        if(p.searchStringDefault != null && p.searchStringDefault != SpecialCharacterConstant.CONCAT ) 
        {   
            searchText = '%'+p.searchStringDefault+'%';
            searchText2 = p.searchStringDefault;
            
            whereClauseText = 'Name Like: searchText '
                                +'OR End_Customer_Name__c Like: searchText '
                                +'OR ProposalName__c Like: searchText '
                                +'OR Quote_Type__c Like: searchText '
                                +'OR SP_Status__c =: searchText2 '
                                +'OR Product_New_Name__c Like: searchText '
                                +'OR Pricing_Status__c Like: searchText'
                                ;
            
        }
        String soql = '';
        
        List<String> approvalStageList = new List<String>();
         Set<String> setIds = new Set<String>();       
        set<Apttus_Proposal__Proposal__c> myset = new set<Apttus_Proposal__Proposal__c>([select id from Apttus_Proposal__Proposal__c where (API_IPQ_Quote__c = false and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') and Apttus_Proposal__Approval_Stage__c = 'Draft' AND RelatedQuote__c != null )]);
        for (Apttus_Proposal__Proposal__c setid: myset) 
        {
          if( !setIds.contains(setid.id) ){
          
              setIds.add(setid.id);
          }  
        }

    if(p.searchStringMyApproval != null && p.searchStringMyApproval != '') {
            approvalStageList.add('Pricing Schedule Requested');
            approvalStageList.add('SP Approval Requested');
            approvalStageList.add('Special Pricing Requested');
            approvalStageList.add('Pending Additional Site Details');
           
                    
            whereClauseText = 'Apttus_Proposal__Approval_Stage__c IN: approvalStageList';
            soql = ''
                    + ' Select ' + String.join(p.columns, ', ')
                    + ' From Apttus_Proposal__Proposal__c'
                    + ' Where API_IPQ_Quote__c = false and (Quote_State__c != \'Failure\' and Quote_State__c != \'In Progress\') AND Apttus_Proposal__Account__c =: partnerAccId AND Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c!=:Deleted AND QuoteExpired__c!= true AND ( Quote_Type__c != \'\' AND Quote_Type_Backend__c != \'\' )'
                    + ((whereClauseText != null && whereClauseText != '') ? ' AND '+whereClauseText :'')
                    + ' AND Id NOT IN:  setIds'
                    + ' order by ' + String.join(orderBys(p), ', ')
                    + ' limit :length'
                    + ' offset :start'
                    ;
        } else {
            String testId = 'a2xm00000009DGqAAM';
            soql = ''
                    + ' Select ' + String.join(p.columns, ', ')
                    + ' From Apttus_Proposal__Proposal__c'
                    + ' Where API_IPQ_Quote__c = false and (Quote_State__c != \'Failure\' and Quote_State__c != \'In Progress\') AND Apttus_Proposal__Account__c =: partnerAccId'
                    + ' AND Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c!=:Deleted AND QuoteExpired__c !=true AND ( Quote_Type__c != \'\' AND Quote_Type_Backend__c != \'\' )'
                    + ((whereClauseText != null && whereClauseText != '') ? ' AND ('+whereClauseText+')' :'')
                    + ' AND Id NOT IN:  setIds'
                    + ' order by ' + String.join(orderBys(p), ', ')
                    + ' limit :length'
                    + ' offset :start'
                    ;
            
        }
        
        
        Integer start = p.start;
        Integer length = p.length;
        Response res = null;
        if(whereClauseText == '') {
            soql = ''
                + ' Select ' + String.join(p.columns, ', ')
                + ' From Apttus_Proposal__Proposal__c'
                + ' Where API_IPQ_Quote__c = false and (Quote_State__c != \'Failure\' and Quote_State__c != \'In Progress\')  AND Apttus_Proposal__Account__c =: partnerAccId AND Apttus_Proposal__Proposal__c.Apttus_Proposal__Approval_Stage__c!=: Deleted  AND QuoteExpired__c!= true AND ( Quote_Type__c != \'\' AND Quote_Type_Backend__c != \'\' ) AND ID NOT IN: setIds'
            
                + ' order by ' + String.join(orderBys(p), ', ')
                + ' limit 10000'
                ;
            
            Integer defaultCount = [select Count() from Apttus_Proposal__Proposal__c Where API_IPQ_Quote__c = false and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') and Apttus_Proposal__Account__c =: partnerAccId AND Apttus_Proposal__Approval_Stage__c!=:Deleted AND QuoteExpired__c!= true AND( Quote_Type__c != '' AND Quote_Type_Backend__c != '' ) AND Id NOT IN: setIds];
            
            
            List<Sobject> sobjectList = (List<Sobject>)Database.query(soql);
            ApexPages.StandardSetController conObj = new ApexPages.StandardSetController(sobjectList);
            conObj.setPageSize(length);
            Integer pageNum = 1;
            if(start >= length) {
                pageNum = (start/length)+1;
            } 
            conObj.setpageNumber(pageNum);
            res = new Response(
                                p.echo,
                                defaultCount,
                                conObj.getRecords()
                            );
        } else {
            if(p.searchStringDefault != null && p.searchStringDefault != SpecialCharacterConstant.CONCAT) {
             if(! Test.isRunningTest()){
                               res = new Response(
                                p.echo,
                                [select Count() from Apttus_Proposal__Proposal__c 
                                    Where API_IPQ_Quote__c = false and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') AND Apttus_Proposal__Account__c =: partnerAccId 
                                    AND Apttus_Proposal__Approval_Stage__c!='Deleted' AND QuoteExpired__c!= true AND ( Quote_Type__c != '' AND Quote_Type_Backend__c != '')
                                    AND (Name Like: searchText 
                                    OR End_Customer_Name__c Like: searchText
                                    OR ProposalName__c Like: searchText
                                    OR Quote_Type__c Like: searchText
                                    OR SP_Status__c =: searchText2 
                                    OR Product_New_Name__c Like: searchText
                                    OR Pricing_Status__c Like: searchText
                                    )AND Id NOT IN: setIds
                                    ],
                                Database.query(soql)
                                  
                            );}
                            
                            else{
                                
                            }
            } else if(p.searchStringMyApproval != null && p.searchStringMyApproval != SpecialCharacterConstant.CONCAT ) {
                res = new Response(
                                p.echo,
                                [select Count() from Apttus_Proposal__Proposal__c 
                                        Where API_IPQ_Quote__c = false and (Quote_State__c != 'Failure' and Quote_State__c != 'In Progress') AND Apttus_Proposal__Account__c =: partnerAccId AND Apttus_Proposal__Approval_Stage__c !=:Constant.QD_DELETED AND QuoteExpired__c != true AND ( Quote_Type__c != :Constant.QD_NOSPACE AND Quote_Type_Backend__c != :Constant.QD_NOSPACE )
                                         AND Apttus_Proposal__Approval_Stage__c IN: approvalStageList AND Id NOT IN:setIds],                                         
                                Database.query(soql)
                                
                            );}
                            
                            else{
                                
                            }
                    
        }
        whereClauseText = '';
        return res;
    }
    
    
    /*
     * @description: method to arrange the columns in Order By format depending on input from UI i.e. either asc or desc
     * @return type: String[]
     * @param: Params
     */
    private static String[] orderBys(Params p) {
        Map<String, String> soqlDirections = new Map<String, String>{
                'asc' => 'asc nulls last',
                'desc' => 'desc nulls first'
                
                };
                
        String[] orderBys = new String[] {};
        Integer min = Math.min(p.sortColumns.size(), p.sortDirections.size());
        for (Integer i = 0; i < min; i++) {
            if(p.columns[p.sortColumns[i]] != 'Id'){
            orderBys.add(''
                    + p.columns[p.sortColumns[i]]
                    + ' '
                    + soqlDirections.get(p.sortDirections[i])
                    );
                    }
                    else{orderBys.add(''
                    + 'LastModifiedDate'
                    + ' '
                    + 'desc nulls first'
                    );}
        }
        return orderBys;
    }
    
    /*
     * @description: DataTable passes JSON definition of what server should do
     * This inner class is to get the params from UI to perform actions accordingly
     */
    private class Params {
        Map<String, Object> m = new Map<String, Object>();
        
        Integer echo;
        Integer start;
        Integer length;
        String[] columns;
        String searchStringDefault;
        /*String searchStringProductName;
        String searchStringSPStatus;
        String searchStringQuoteType;*/
        String searchStringMyApproval;
        Integer[] sortColumns;
        String[] sortDirections;
    /***********************************************************************************************
    Method: 
    Description: 
    @Param : List<Map<String, Object>>
    @return: none
    @throws: none
    Version :  
    Modification Log :
    Developer        Date            Description
    ******************************************/  
        Params(List<Map<String, Object>> request) {
            for (Map<String, Object> r : request) {
                m.put((String) r.get('name'), r.get('value'));
            }
            echo = integer('sEcho');
            start = integer('iDisplayStart');
            length = integer('iDisplayLength');
            columns = stringArray('mDataProp');
            sortColumns = integerArray('iSortCol');
            sortDirections = stringArray('sSortDir');
            searchStringDefault = m.get('searchStringDefault') != null ? (String)m.get('searchStringDefault') : '';
            searchStringMyApproval = m.get('searchStringMyApproval') != null ? (String)m.get('searchStringMyApproval') : '';
        }
    /***********************************************************************************************
    Method: 
    Description: 
    @Param : string
    @return: stringArray
    @throws: none
    Version :  
    Modification Log :
    Developer        Date            Description
    ******************************************/ 
        String[] stringArray(String prefix) {
            String[] strings = new String[] {};
            for (Object o : array(prefix)) {
                strings.add(o != null ? esc(String.valueOf(o)) :null);
            }
            return strings;
        }
    /***********************************************************************************************
    Method: 
    Description: 
    @Param : string
    @return: integerArray
    @throws: none
    Version :  
    Modification Log :
    Developer        Date            Description
    ******************************************/     
        Integer[] integerArray(String prefix) {
            Integer[] integers = new Integer[] {};
            for (Object o : array(prefix)) {
                integers.add(o != null ? Integer.valueOf(o) : null);
            }
            return integers;
        }
    /***********************************************************************************************
    Method: 
    Description: 
    @Param : string
    @return: array
    @throws: none
    Version :  
    Modification Log :
    Developer        Date            Description
    ******************************************/ 
        Object[] array(String prefix) {
            Object[] objects = new Object[] {};
            for (Integer i = 0; true; i++) {
                Object o = m.get(prefix + '_' + i);
                if (o != null) {
                    objects.add(o);
                } else {
                    break;
                }
            }
            return objects;
        }
    /***********************************************************************************************
    Method: 
    Description: 
    @Param : string
    @return: string
    @throws: none
    Version :  
    Modification Log :
    Developer        Date            Description
    ******************************************/  
        Integer integer(String name) {
            Object o = m.get(name);
            if (o instanceof Decimal) {
                return ((Decimal) o).intValue();
            } else if (o instanceof Integer) {
                return (Integer) o;
            } else {
                return null;
            }
        }
         
        // Guard against SOQL injection
    /***********************************************************************************************
    Method: 
    Description: 
    @Param : string
    @return: string
    @throws: none
    Version :  
    Modification Log :
    Developer        Date            Description
    ******************************************/ 
       String esc(String s) {
            return s != null ? String.escapeSingleQuotes(s) : null;
        }
    }

    /* 
     Name: selectFinalDeencryptedUrl
     Description: 
     */ 
    public void selectFinalDeencryptedUrl(){
        try{
        }catch(exception e){
             ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    public Map<String, ItemCountWrapper> sortMapQuote(Map<String, ItemCountWrapper> theMap, String theOrder) {
   
    Map<String, ItemCountWrapper> returnMap = new Map<String, ItemCountWrapper>();
   
    Set<String> keySet = theMap.keySet();
   
    List<String> keyList = new List<String>();
    keyList.addAll(keySet);
   
    keyList.sort();
    if (theOrder == 'DESC'){
   
        for (Integer i = (keyList.size() - 1); i >= 0; i--)
            returnMap.put(keyList[i], theMap.get(keyList[i]));
    }else{
   
        for (Integer i = 0; i < keyList.size(); i++)
            returnMap.put(keyList[i], theMap.get(keyList[i]));
   }
    return returnMap;
}
    }