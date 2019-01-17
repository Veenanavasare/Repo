/************************************************************************************** 
 Apex Class Name     : CustomerManagementController
 Version             : 1.0 
 Created Date        : 01 Sep 2014
 Function            : This class handles the customer management functionality.
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mayank Agarwal            9/01/2014              Original Version
*************************************************************************************/
global with sharing class CustomerManagementController { 
    /*Name:CustomerManagementController*/
    global CustomerManagementController() {
    
        cust = ApexPages.currentPage().getParameters().get('newCustRec');
        if(cust != null){
            custPositionPage = positionCustomer(cust);      
        }else{
            custPositionPage = 1;
        }  
        if(ConsumeForUseAccount__c.getInstance(BuyflowConstant.METTEL) != null){
            ConsumeForUseAccount__c cS = ConsumeForUseAccount__c.getInstance(BuyflowConstant.METTEL);
            if(CS.name != null){
                consumeForUseAccount = CS.name;
            }
        }   
    }
    public id cust{get;set;}
    public integer custPositionPage{get;set;}
    private String soql {get;set;}
    public List<String> listAccID;
    public static List<String> listAccIDExisting;
    public Integer counter;
    private Integer list_size=5; //sets the page size or number of rows
    public Integer total_size; //used to show user the total size of the list
    private set<id> endCustIDSet ;
    public List<End_Customer__c> endCustListExisting {get;set;}
    public list<End_Customer__c> endCustNew{get;set;}
    public Boolean selectAccount{get;set;}
    public Boolean showExisting{get;set;}
    public Boolean existCustRecord{get;set;}
    public string quoteId {get;set;}
    public String prevCustId; // added for back button issue
    public static Id newcustId;
    public List<End_Customer__c> endCustList {get;set;}
    public string consumeForUseAccount {get;set;}
    
    //Adding new reIntialize method for resolving the veiw State error: RK
/* 
 Name: reInitialize
 Description: 
 */ 
    public void reInitialize() {
        try{
        soql = SIConstants.BLANKSPACE;
        endCustIDSet = NULL;
        listAccID = new List<String>();
        endCustListExisting = new List<End_Customer__c>();
    }
    catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    }
    
/* 
 Name: reLoad
 Description: 
 */ 
    public void reLoad() {
        try{
        prevCustId = ApexPages.currentPage().getParameters().get('newCustRec'); // added for back button issue
        displayCustomerDetails();
    } 
catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    }   
    //End: RK
    
    /*
     * Name  : CustomerManagementController
     * Description  : Constructor
     * Parameter    : ApexPages.StandardController controller 
     * Return Type  : N/A
     */
/* 
 Name: CustomerManagementController
 Description: 
 */ 
    public CustomerManagementController(ApexPages.StandardController controller) {
        quoteId = SpecialCharacterConstant.CONCAT;
        list_size = Global_Variable__c.getValues(BuyflowConstant.ENDCUSTOMERDATAPAGESIZE) != null ? Integer.valueOf(Global_Variable__c.getValues(BuyflowConstant.ENDCUSTOMERDATAPAGESIZE).Value__c) : 5;
    }
    
     /*
     * Name  : displayCustomerDetails
     * Description  : Retrive a end customer and capture different parameters.
     * Parameter    : None 
     * Return Type  : N/A
     */
/* 
 Name: displayCustomerDetails
 Description: 
 */ 
     public void displayCustomerDetails(){
        try{
            endCustIDSet = new set<id>();
            user  lstUser  = [select id, Contact.AccountId from User where id=:userInfo.getUserId()];
               
            existCustRecord = false;
            showExisting = false;           
            selectAccount = false;
            if(ApexPages.currentPage().getParameters().containsKey('records')){
                selectAccount = true;
                listAccID = new List<String>();
                listAccID = ApexPages.currentPage().getParameters().get('records').split(',');          
            }
           
            if(ApexPages.currentPage().getParameters().containsKey('existTable')){
                showExisting = true;
                listAccIDExisting = ApexPages.currentPage().getParameters().get('existTable').split(',');            
            }
            if(ApexPages.currentPage().getParameters().containsKey('existCustRec')){
                showExisting = true;
                existCustRecord = true;
                
                endCustListExisting = [Select Id,City__c,Name,Company_Legal_Name__c,DUNS_Number__c,
                                        State__c,Mailing_Street_Address__c,Zip__c
                                        From End_Customer__c 
                                        Where id =: ApexPages.currentPage().getParameters().get('existCustRec')];
                
            }
            counter = 0;           
        
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        
    }
    
    /*
     * Method name  : createquote
     * Description  : Method called from Create Quote button.
     * Parameter    : N/A 
     * Return Type  : PageReference
     */
/* 
 Name: createquote
 Description: 
 */ 
    public void createquote() {
        try{
            //Changes : RK
            String custId = apexpages.currentpage().getparameters().get(BuyflowConstant.SELECTED);
            Apttus_Proposal__Proposal__c apttusquote = new Apttus_Proposal__Proposal__c();
            User usr = new User();
            usr = [Select Id,Name,Is_Approver__c,ContactId,Email FROM User WHERE id=:userinfo.getuserId()];
            Contact con = new Contact();
            //ID cAccountID = SpecialCharacterConstant.CONCAT;
            ID cAccountID;
            if(usr.ContactId != null){
                con = [SELECT Id, Name, AccountId,Account.Name FROM Contact WHERE Id=:usr.ContactId];
                cAccountID = con.AccountId;
            }
            else{
                ATTDefaultAccount__c accName = ATTDefaultAccount__c.getValues(BuyflowConstant.ACCOUNTNAME);
                LIST<Account> idAcc=[SELECT Id FROM Account WHERE name=:accName.Account_Name__c limit 1 ];
                cAccountID = idAcc[0].id; 
            }
            List<Account> accList = [select id,ownerid from account where id =:cAccountID];
            if(accList.size()>0){
                apttusquote.Apttus_Proposal__Account__c = accList[0].id;
            }
            // @Gavin 11/01/2014 Start: DE83549, Shouldn't set product or term on quote creation
            //apttusquote.Product__c = BuyflowConstant.SIVARConst_01TM0000000ISDR;
            //apttusquote.Apttus_Proposal__Payment_Term__c = BuyflowConstant.SIVARConst_1YEAR;
            // @Gavin 11/01/2014 End: DE83549, Shouldn't set product or term on quote creation
            //Adding existing Quote Check: RK
            if(quoteId == SpecialCharacterConstant.CONCAT || quoteId == null) {
                apttusquote.Apttus_Proposal__ExpectedStartDate__c = system.today();
                apttusquote.Apttus_Proposal__ExpectedEndDate__c = system.today().addmonths(6);
            }
            /************************** changes Shoumya *******************************/
            apttusquote.Buyflow_Step__c=BuyflowConstant.ADDPRODUCT;
            /***************************************************************************/
            if(custId != null && custId != SpecialCharacterConstant.CONCAT) {
                apttusquote.End_Customer__c = custId;
                //qObj.Quote_Status__c = BuyflowConstant.DRAFT;
            }
            if(quoteId == SpecialCharacterConstant.CONCAT || quoteId == null) {
                insert apttusquote;
            } else {
                apttusquote.Id = quoteId;
                // back button issue - start
                if(prevCustId != null && custId != null &&  custId != prevCustId){
                    apttusquote.Apttus_Proposal__Proposal_Name__c = null;
                    apttusquote.Apttus_Proposal__Payment_Term__c = null;
                    apttusquote.Ethernet_Configuration__c = null;
                    apttusquote.Traffic_Jurisdiction__c = null;
                    apttusquote.Product__c = null;
                    apttusquote.Apttus_QPConfig__PriceListId__c = null;
                }
                // back button issue - end
                update apttusquote;
            }
                
            quoteId = apttusquote.Id;
        } catch(Exception e) {
             ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        //End: RK
    }
    
    
    //Start Changes for Dynamic Datatable: RK
    private static String searchText = SpecialCharacterConstant.CONCAT;
    
    
    /* Defines shape of JSON response*/
    global class Response {
        public Integer sEcho;
        public Integer iTotalRecords;
        public Integer iTotalDisplayRecords;
        Sobject[] aaData;
        Response(Integer echo, Integer total, Sobject[] sobs) {
            this.sEcho = echo;
            this.iTotalRecords = total;
            this.iTotalDisplayRecords = total;
            this.aaData = sobs;
        }
    }
    
    //Global Static Variable for Partner Account related End Customer Ids
    private static Set<Id> endCustomerIdSet = null; 
    @RemoteAction
    global static Response fetchEndCustomerRecords(List<Map<String, Object>> request) {
        Id accId = null;
        
        User lstUser  = [select id, Contact.AccountId from User where id=:userInfo.getUserId()];
        if(lstUser.Contact.AccountId != null) {
            accId = lstUser.Contact.AccountId;
        } else {
            ATTDefaultAccount__c accName = ATTDefaultAccount__c.getValues(BuyflowConstant.ACCOUNTNAME);
            if(accName != null && accName.Account_Name__c != null) {
                LIST<Account> idAcc = [SELECT Id FROM Account WHERE name=:accName.Account_Name__c limit 1 ];
                if(!idAcc.isEmpty()) {
                    accId = idAcc[0].Id;
                }
            }
        }
        endCustomerIdSet = new Set<Id>();
        for(Account_End_Customer_Junction__c endCustJunctObj : [Select Id, Account__c, End_Customer__c 
                                                                    From Account_End_Customer_Junction__c
                                                                    Where Account__c =: accId]) {
            endCustomerIdSet.add(endCustJunctObj.End_Customer__c);                                                      
        }
        Params p = new Params(request);
        String whereClauseText = SpecialCharacterConstant.CONCAT;
        if(p.searchString != null && p.searchString != SIConstants.BLANKSPACE) {
            searchText = '%'+string.escapeSingleQuotes(p.searchString)+'%';
            //whereClauseText = 'Name Like: searchText Or BillingStreet Like: searchText';
            whereClauseText = 'Name Like: searchText OR City__c Like: searchText OR State__c Like: searchText OR Zip__c Like: searchText';
        }
        
        String soql = ''
                + ' Select ' + String.join(p.columns, ', ')
                + ' From End_Customer__c'
                + ' Where API_IPQ_EndCust__c = false AND Id IN: endCustomerIdSet'
                + ((whereClauseText != null && whereClauseText != '') ? ' AND ('+whereClauseText+')' :'')
                + ' order by ' + String.join(orderBys(p), ', ')
                + ' limit :length'
                +  ' offset :start'
                ;
        
        Integer start = p.start;
        Integer length = p.length;

        Response res = null;
        if(whereClauseText == SpecialCharacterConstant.CONCAT) {
            res = new Response(
                p.echo,
                [select Count() from End_Customer__c Where API_IPQ_EndCust__c = false AND Id In: endCustomerIdSet limit 50000],
                Database.query(soql)
                );
        } else {
            res = new Response(
                p.echo,
                [select Count() from End_Customer__c Where API_IPQ_EndCust__c = false AND Id In: endCustomerIdSet AND (Name Like: searchText OR City__c Like: searchText OR State__c Like: searchText OR Zip__c Like: searchText) limit 50000],
                Database.query(soql)
                );
        }
        whereClauseText = SpecialCharacterConstant.CONCAT;
        return res;
    }
    /*Name:orderBys*/
    private static String[] orderBys(Params p) {
        Map<String, String> soqlDirections = new Map<String, String>{
                'asc' => 'asc nulls last',
                'desc' => 'desc nulls first'
                };
        String[] orderBys = new String[] {};
        Integer min = Math.min(p.sortColumns.size(), p.sortDirections.size());
        for (Integer i = 0; i < min; i++) {
             if(p.columns[p.sortColumns[i]] != BuyflowConstant.ID){
            orderBys.add(''
                    + p.columns[p.sortColumns[i]]
                    + ' '
                    + soqlDirections.get(p.sortDirections[i])
                    );
                    }
                    else{orderBys.add(''
                    + 'Name'
                    + ' '
                    + soqlDirections.get(p.sortDirections[i])
                    );}
        }
        return orderBys;
    }
    
    /*DataTable passes JSON definition of what server should do*/
    private class Params {
     
        Map<String, Object> m = new Map<String, Object>();
         
        Integer echo;
        Integer start;
        Integer length;
        String[] columns;
        String searchString;
        Integer[] sortColumns;
        String[] sortDirections;
        /*Name:params*/ 
        Params(List<Map<String, Object>> request) {
            for (Map<String, Object> r : request) {
                m.put((String) r.get(BuyflowConstant.NAME1), r.get(BuyflowConstant.VALUE));
            }
            echo = integer(BuyflowConstant.SECHO);
            start = integer(BuyflowConstant.IDISPLAYSTART);
            length = integer(BuyflowConstant.IDISPLAYLENGTH);
            columns = stringArray(BuyflowConstant.MDATAPROP);
            sortColumns = integerArray(BuyflowConstant.ISORTCOL);
            sortDirections = stringArray(BuyflowConstant.SSORTDIR);
            searchString = m.get(BuyflowConstant.SEARCHTEXT) != null ? (String)m.get(BuyflowConstant.SEARCHTEXT) : SpecialCharacterConstant.CONCAT;
        }
        /*stringArray*/ 
        String[] stringArray(String prefix) {
            String[] strings = new String[] {};
            for (Object o : array(prefix)) {
                strings.add(o != null ? esc(String.valueOf(o)) :null);
            }
            return strings;
        }
         /*integerArray*/  
        Integer[] integerArray(String prefix) {
            Integer[] integers = new Integer[] {};
            for (Object o : array(prefix)) {
                integers.add(o != null ? Integer.valueOf(o) : null);
            }
            return integers;
        }
        /*array*/
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
        /*Name:integer*/ 
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
         
        /* Guard against SOQL injection*/
        String esc(String s) {
            return s != null ? String.escapeSingleQuotes(s) : null;
        }
    }
 //Position of new customer method
/* 
 Name: positionCustomer
 Description: 
 */ 
                public static integer positionCustomer(id custID){
                    try{
                 Id accId = null;
                    
                    User lstUser  = [select id, Contact.AccountId from User where id=:userInfo.getUserId()];
                    if(lstUser.Contact.AccountId != null) {
                        accId = lstUser.Contact.AccountId;
                    } else {
                        ATTDefaultAccount__c accName = ATTDefaultAccount__c.getValues('AccountName');
                        if(accName != null && accName.Account_Name__c != null) {
                            LIST<Account> idAcc = [SELECT Id FROM Account WHERE name=:accName.Account_Name__c limit 1 ];
                            if(!idAcc.isEmpty()) {
                                accId = idAcc[0].Id;
                            }
                        }
                    }
                    endCustomerIdSet = new Set<Id>();
                    for(Account_End_Customer_Junction__c endCustJunctObj : [Select Id, Account__c, End_Customer__c 
                                                                                From Account_End_Customer_Junction__c
                                                                                Where Account__c =: accId]) {
                        endCustomerIdSet.add(endCustJunctObj.End_Customer__c);                                                      
                    }   
                    
                    
                Integer custPositionVal;
                Integer custPositionPage;
                
                       List<End_Customer__c> custList = [select Id,name from End_Customer__c where Id IN : endCustomerIdSet order by name asc];
                            for(integer i = 0; i < custList.size(); i++){
                                if(custID == custList[i].Id){
                                    custPositionVal = i+1;
                                    custPositionPage = i/8 + 1;
                                    break;
                            }
                         }
                         return custPositionPage;
                    }
                    catch(exception e){
                        ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                        return null;
                    }
                }
                /* Sprint 22- US725696 Starts*/     
    @RemoteAction
    global static  LIST<Account> FetchcustID() {
        Apttus_Proposal__Proposal__c apttusquote = new Apttus_Proposal__Proposal__c();
        User usr = new User();
        usr = [Select Id,Name,Is_Approver__c,ContactId,Email,Contact.AccountId,Contact.Account.Name FROM User WHERE id=:userinfo.getuserId()];
        ID cAccountID;
        LIST<Account> custIdAcc;
        if(usr.ContactId != null){
            cAccountID = usr.Contact.AccountId;
            custIdAcc=[SELECT Id,Name,Company_Address__c,Billing_Address__c,Billing_City__c,Billing_State__c,Billing_Zip_Code__c FROM Account WHERE id =: cAccountID limit 1 ];
           }     
        return custIdAcc;
    }
    /* Sprint 22- US725696 Ends*/     
    
}