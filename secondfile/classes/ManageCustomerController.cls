/************************************************************************************** 
    Apex Class Name     : ManageCustomerController
    Version             : 1.0 
    Created Date        : 10 Oct  2014
    Function            : This class handles the manage customer functionality.
    Modification Log    :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sruthy Dileep            10/10/2014              Original Version
    *************************************************************************************/
    global with sharing class ManageCustomerController{
    
    public String CustomerProfilePage { get; set; }
    
    public List<End_Customer__c> endCustListExisting {get;set;}
    public List<NewsroomPermission__c > newsroomName {get;set;}    
    public Boolean selectAccount{get;set;}
    public Boolean showExisting{get;set;}
    public string quoteId {get;set;}
    public boolean displayPopup {get; set;} 
    //public string FirstName{get;set;}
    public string BusName{get;set;}   
    //public string LastName{get;set;}
    public string Updation {get;set;}
    
/* 
 Name: ManageCustomerController
 Description: 
 */ 
    public ManageCustomerController() {
        //getting parameters from the page URL so as to dispaly the respective page messages
        //FirstName= ApexPages.currentPage().getParameters().get('FirstName');
        //LastName= ApexPages.currentPage().getParameters().get('LastName');
         newsroomName =[Select name from NewsroomPermission__c limit 1]; 
        BusName= ApexPages.currentPage().getParameters().get('BusinessName');
        Updation = ApexPages.currentPage().getParameters().get('Updation');
        
        //displaying the page messages of updation and save
        if (BusName!=null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, BusName +' has been added.'));
        }
        else if (Updation!=null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Updation+' has been updated.'));
        }
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
    
    }
    catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    }

    
    
    /*
    * Class name   : DeleteAction
    * Description  : On the click of Delete button, delete the customer from the object
    * Parameter    : N/A 
    * Return Type  : N/A
    */
/* 
 Name: DeleteAction
 Description: 
 */ 
    public void deleteAction() {
        displayPopup = false; 
        try{
            //making a list of the selected customers
            /*SelectedCustomer = new list<End_Customer__c> ();
            SelectedMap = new map<Boolean,list<EndCustWrapperCls>>();
            for (EndCustWrapperCls wrapCust: endCustWrapperList) {
                if (wrapCust.isSelected == true) {
                    Bol = true;
                    SelectedCustomer.add(wrapCust.EndCustInst);
                    if (SelectedMap.containsKey(True)){
                        SelectedMap.get(True).add(wrapcust);
                    }
                    else{
                        SelectedMap.put(True,new list<EndCustWrapperCls>{wrapcust});
                    }
                }else{
                    if (SelectedMap.containsKey(False)){
                        SelectedMap.get(False).add(wrapcust);
                    }
                    else{
                        SelectedMap.put(False,new list<EndCustWrapperCls>{wrapcust});
                    }
                }
                
                if (SelectedCustomer!=NULL && SelectedCustomer.size()>0){
                   // for(End_Customer__c sel : SelectedCustomer ){
                    //deleting the selected customers 
                      //  delete sel;           
                   // }
                    if(SelectedMap.containskey(False)){
                    //displaying the remaining customers after the delete action
                        endCustWrapperList = new List<EndCustWrapperCls>();
                        endCustWrapperList.addAll(SelectedMap.get(False));
                    }
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'The row has been successfully deleted'));
                    
                }
            }*/
            
            //Start: New Delete Functionality: RK
            String selectedCustId = ApexPages.currentPage().getParameters().get('selectedCustId');
            if(selectedCustId != null && selectedCustId != SpecialCharacterConstant.CONCAT) {
                List<String> selectedCustIdList = selectedCustId.split(SpecialCharacterConstant.SEMICOLON);
                if(selectedCustIdList != null && selectedCustIdList.size() > 0) {
                    List<Account_End_Customer_Junction__c> accountEndCustomerToDelList = [Select Id, End_Customer__r.Id From Account_End_Customer_Junction__c Where End_Customer__r.Id In: selectedCustIdList];
                    if(!accountEndCustomerToDelList.isEmpty()) {
                        delete accountEndCustomerToDelList;
                    }
                    List<End_Customer__c> endCustomerToDelList = [Select Id From End_Customer__c Where Id In: selectedCustIdList];
                    if(!endCustomerToDelList.isEmpty()) {
                        delete endCustomerToDelList;
                    }  
                }
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
           ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*
    * Class name   : closePopup
    * Description  : Method to close the delete popup
    * Parameter    : N/A 
    * Return Type  : N/A
    */    
/* 
 Name: closePopup
 Description: 
 */ 
    public void closePopup() {
try{        
        displayPopup = false;   
    }
    catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    }   
    
    /*
    * Class name   : showPopup
    * Description  : Method to open the delete popup
    * Parameter    : N/A 
    * Return Type  : N/A
    */       
    /* 
     Name: showPopup
     Description: 
     */ 
    public void showPopup() {  
        try{    
            displayPopup = true;   
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }   
    
    
    /* 
     Name: AddNewCustomerButton
     Description: 
     */ 
    public PageReference addNewCustomerButton(){
        try{
            PageReference addNewCustomerPage= new PageReference('/apex/PortalDesign_AddNewCustomers');
            addNewCustomerPage.setRedirect(true);
            return addNewCustomerPage; 
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }
    
    //Start Changes for Dynamic Datatable: RK
    private static String searchText = SpecialCharacterConstant.CONCAT;
    //Global Static Variable for Partner Account related End Customer Ids
    private static Set<Id> endCustomerIdSet = null; 
    /* 
     Class Name: Response
     Description: 
     */ 
    global class Response {
        public Integer sEcho;
        public Integer iTotalRecords;
        public Integer iTotalDisplayRecords;
        Sobject[] aaData;
        /* 
         Name: Response
         Description: Constructor
         */ 
       Response(Integer echo, Integer total, Sobject[] sobs) {
            this.sEcho = echo;
            this.iTotalRecords = total;
            this.iTotalDisplayRecords = total;
            this.aaData = sobs;
        }
    }
    
    /* 
     Name: fetchEndCustomerRecords
     Description: 
     */ 
    @RemoteAction
    global static Response fetchEndCustomerRecords(List<Map<String, Object>> request) {
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
        Params p = new Params(request);
        String whereClauseText = BuyflowConstant.BLANKQUOTES;
        if(p.searchString != null && p.searchString != BuyflowConstant.BLANKQUOTES) {
            searchText = '%'+p.searchString+'%';
            whereClauseText = 'Name Like: searchText '
                                +'OR City__c Like: searchText '
                                +'OR State__c Like: searchText '
                                +'OR Zip__c Like: searchText '
                                +'OR First_Name__c Like: searchText '
                                +'OR Last_Name__c Like: searchText';
        }
        
        String soql = ''
                + ' select ' + String.join(p.columns, ', ')
                + ' from End_Customer__c'
                + ' Where API_IPQ_EndCust__c = false AND Id IN: endCustomerIdSet'
                + ((whereClauseText != null && whereClauseText != '') ? ' AND ('+whereClauseText+')' :'')
                + ' order by ' + String.join(orderBys(p), ', ')
                + ' limit :length'
                + ' offset :start'
                ;
        
        Integer start = p.start;
        Integer length = p.length;

        Response res = null;
        List<End_Customer__c> endCustomerList = new List<End_Customer__c>();
        if(whereClauseText == SpecialCharacterConstant.CONCAT) {
            for(End_Customer__c endCustObj : Database.query(soql)) {
                if(endCustObj.Last_Name__c != null) {
                    endCustObj.Last_Name__c = endCustObj.Last_Name__c 
                                            + ((endCustObj.Last_Name__c != null && endCustObj.Last_Name__c != '') 
                                                ? ', '+endCustObj.First_Name__c:'');
                }
                
                endCustomerList.add(endCustObj);
            }
            res = new Response(
                                p.echo,
                                [select Count() from End_Customer__c Where API_IPQ_EndCust__c = false AND Id IN: endCustomerIdSet limit 50000],
                                endCustomerList//Database.query(soql)
                            );
        } else {
            for(End_Customer__c endCustObj : Database.query(soql)) {
                if(endCustObj.Last_Name__c != null) {
                    endCustObj.Last_Name__c = endCustObj.Last_Name__c 
                                            + ((endCustObj.Last_Name__c != null && endCustObj.Last_Name__c != '') 
                                                ? ', '+endCustObj.First_Name__c:'');
                }
                endCustomerList.add(endCustObj);
            }
            res = new Response(
                                p.echo,
                                [select Count() from End_Customer__c 
                                        Where API_IPQ_EndCust__c = false AND Id IN: endCustomerIdSet
                                        AND (Name Like: searchText 
                                        OR City__c Like: searchText 
                                        OR State__c Like: searchText 
                                        OR Zip__c Like: searchText 
                                        OR First_Name__c Like: searchText 
                                        OR Last_Name__c Like: searchText)
                                        limit 50000],
                                endCustomerList//Database.query(soql)
                            );
        }
        whereClauseText = SpecialCharacterConstant.CONCAT;
        return res;
    }
        
    /* 
     Name: orderBys
     Description: 
     */ 
    private static String[] orderBys(Params p) {
        Map<String, String> soqlDirections = new Map<String, String>{
                 'asc' => 'asc nulls last',
                SpecialCharacterConstant.DESC_CAPS_LITERAL => BuyflowConstant.DESCNULLS_FIRST
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
    
    /* 
     Class Name: Params
     Description: DataTable passes JSON definition of what server should do
     */  
    private class Params {
        Map<String, Object> m = new Map<String, Object>();
        
        Integer echo;
        Integer start;
        Integer length;
        String[] columns;
        String searchString;
        Integer[] sortColumns;
        String[] sortDirections;
         
         /* 
         Name: Params
         Description: Constructor
         */ 
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
            searchString = m.get('searchText') != null ? (String)m.get('searchText') : '';
            
        }
        
         /* 
         Name: stringArray
         Description: 
         */          
        String[] stringArray(String prefix) {
            String[] strings = new String[] {};
            for (Object o : array(prefix)) {
                strings.add(o != null ? esc(String.valueOf(o)) :null);
            }
            return strings;
        }
         /* 
         Name: integerArray
         Description: 
         */      
        Integer[] integerArray(String prefix) {
            Integer[] integers = new Integer[] {};
            for (Object o : array(prefix)) {
                integers.add(o != null ? Integer.valueOf(o) : null);
            }
            return integers;
        }
        
        /* 
         Name: array
         Description: 
         */   
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
        
        /* 
         Name: integer
         Description: 
         */   
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
         
        /* 
         Name: esc
         Description: Guard against SOQL injection
         */   
        String esc(String s) {
            return s != null ? String.escapeSingleQuotes(s) : null;
        }
    }
    
}