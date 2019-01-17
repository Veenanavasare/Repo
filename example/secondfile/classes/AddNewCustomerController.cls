/************************************************************************************** 
 Apex Class Name     : AddNewCustomerController
 Version             : 1.0 
 Created Date        : 12 Oct  2014
 Function            : This class handles the Add new customer functionality.
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sruthy Dileep            12/10/2014              Original Version
*************************************************************************************/
public with sharing class AddNewCustomerController {

    public string FirstName{get; set;}  
    public string BusinessWebsite{get; set;}
    public string BusinessName{get; set;}
    public string LastName{get; set;}
    public string DUNS{get; set;}
    public string Address{get;set;}
    public string Email{get; set;}
    public string Suite{get; set;}
    public string Floor{get; set;}
    public string City{get; set;}
    public string Phone{get; set;}
    public string ZIP {get;set;}
    public string state {get; set;}
    public list<SelectOption> PickList {get; set;}
    public list<SelectOption> pickList1 {get; set;}
    public boolean checkbox {get;set;}
    public string FirstNameParam{get;set;}
    public string LastNameParam{get;set;}
    public string Msg {get; set;}
    public list<CustomerSite__c> EndCustomerSite {get;set;}
    public list<CustomerSite__c> EndCustomerSiteFormer{get;set;}
    public list<CustomerSite__c> endCustomerSiteFormerBulk;
    public list<CustomerSite__c> custSite {get;set;}
    public CustomerSite__c customerSiteObj {get;set;}
    list<CustSiteWrapperCls> wrapperList = New List<CustSiteWrapperCls>();
    map<boolean, list<CustomerSite__c>> siteMap = new Map<Boolean, list<CustomerSite__c>>();
    public boolean bool {get;set;}
    public CustomerSite__c custsiteInst {get;set;}
    public End_Customer__c  cust;
    public string state1;
    public string zipSite;
    public string locationNo;
    //public string index{get;set;}
    public boolean bol {get;set;}
    public boolean displayPopup {get;set;}
    public list<CustSiteWrapperCls> CustSiteWrapperList{get;set;}
    public list<CustSiteWrapperCls> CustSiteWrapper_DeleteList{get;set;}
    public list<CustomerSite__c> selectedSite;
    public map<Boolean,list<CustSiteWrapperCls>> selectedMap;
    public boolean CheckVar {get;set;}
    public integer index {get;set;}
    public boolean Checkdelete {get;set;}
    public set<string> dupCheckList;
    
    public blob contentFile {get; set;}
    public String nameFile {get; set;}
    public string strDocUrl {get; set;}
    public string strDocUrlName {get; set;}    
    //public string strDocUrl2 {get; set;}
    string[] filelines = new String[]{};
    private list<CustomerSite__c> uploadedSites {get; private set;}
    public string BulkUploadMsg {get; set;}    
    public string fileContentType {get; set;}
    // Variable to store VASA response.
    public AddrValidServAvailResponseBean VASAresponse {get; private set;}
    // Varible to hold the parsed excel file.
    public string excelBody{get;set;}
    
    public boolean completeButton {get;set;}
    public boolean ACT1{get; set;}
    public boolean ACT2{get; set;}
    public boolean ACT3{get; set;}
    public boolean ACT4{get; set;}
    public boolean ACT5{get; set;}
    public boolean ACT6{get; set;}
    public boolean ACT7{get; set;}
    public boolean ACT8{get; set;}
    
    public boolean userBeginQuote{get; set;}
    /******************************************************************
    * Method name : AddNewCustomerController
    * Description : Constructor 
    * Return Type : null
    * Parameters  : None.
    *******************************************************************/ 
    public AddNewCustomerController(){
        
        bool = false;
        bol = false;
        checkbox = true;
        User userObj;
        userObj = [select id, Begin_Quote__c from User where id = :UserInfo.getUserId() LIMIT 1];
        userBeginQuote = userObj.Begin_Quote__c;
       // RedirectToErrorPage();
        //initialise variables related to Customer Sites
        EndCustomerSite = new list<CustomerSite__c>();
        EndCustomerSiteFormer = new list<CustomerSite__c>();
        custsiteInst = new CustomerSite__c();
        uploadedSites = new List<CustomerSite__c>();
        //getting parameters fromt the page URL
        Msg= ApexPages.currentPage().getParameters().get('display');
        if (Msg!=null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, CustomerConstant.UPLOAD_CSV_FILE ));
        }
    
        completeButton = false;
    
        //download template
        List<Document> docObj = new List<Document>([Select Name from Document where DeveloperName=: CustomerConstant.TEMPLATE_NAME  limit 1]);
        if (docObj !=NULL && docObj.size()>0){
            strDocUrl = '/servlet/servlet.FileDownload?file='+docObj[0].Id;
            strDocUrlName = docObj[0].Name;
        } 
    }
    /******************************************************************
    * Method name : getStatePicklist
    * Description : Get values from custom setting for State picklist 
    * Return Type : List<SelectOption>.
    * Parameters  : None.
    *******************************************************************/    
    public list<SelectOption> getStatePicklist(){
        try{
            list<SelectOption> statePicklist = new list<SelectOption>();
            list<ATT_StateMapping__c> stateList = ATT_StateMapping__c.getall().values();
            if (stateList!=NULL){
                StatePicklist.add(new SelectOption(SpecialCharacterConstant.CONCAT,SpecialCharacterConstant.SELECT_CAPS_LITERAL));
                    for(ATT_StateMapping__c item : stateList){
                        StatePicklist.add(new selectoption(item.State_Code__c,item.State_Code__c));
                }
            }
            StatePicklist.sort();
            SelectOption placeholderText;
                        
            return StatePicklist;
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }
    
    /******************************************************************
    * Method name : getLocationPicklist
    * Description : Get values from custom setting for Location picklist 
    * Return Type : List<SelectOption>.
    * Parameters  : None.
    *******************************************************************/    
    public list<SelectOption> getLocationPicklist(){
        try{
            list<SelectOption> locationPicklist = new list<SelectOption>();
            list<ATT_LocationMapping__c> locationList = ATT_LocationMapping__c.getall().values();
            if (LocationList!=NULL){
                LocationPicklist.add(new SelectOption(SpecialCharacterConstant.CONCAT,SpecialCharacterConstant.SELECT_CAPS_LITERAL));
                for(ATT_LocationMapping__c item : LocationList){
                    LocationPicklist.add(new selectoption(item.name,item.name));
                }
            }
            LocationPicklist.sort();
            return LocationPicklist;
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }

/******************************************************************
    * Method name : copySiteToTable
    * Description : copy data entered in Customer field to Table section
    * Return Type : null
    * Parameters  : None.
    *******************************************************************/
    public void copyAddressToTable(){
        //making address populate automatically in the site address
        try{
            custsiteInst.Site_Name__c = BusinessName;
            custsiteInst.Address_Line__c = Address;
            custsiteInst.Zip_Code__c = ZIP;
            custsiteInst.City__c = City;
            custsiteInst.State__c = State;
            custsiteInst.Location__c= Suite;
            if(string.isBlank(Floor)) {
                custsiteInst.Location_Number__c = null;
            } else {
                custsiteInst.Location_Number__c = Floor;                        
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /******************************************************************
    * Method name : AddSite
    * Description : on the click of Add Site button, make a temporary list of sites to be displayed
    * Return Type : null
    * Parameters  : None.
    *******************************************************************/
    public void addSite(){
        //making address populate automatically in the site address if the checkbox for the same is ticked
        try{         
            //adding the added site to the list of sites displayed if all the fields are filled
             if(string.isNotBlank(custsiteInst.Address_Line__c) 
                && string.isNotBlank(custsiteInst.City__c) 
                && string.isNotBlank(custsiteInst.State__c) 
                && string.isNotBlank(custsiteInst.Zip_Code__c)) {
           
                EndCustomerSiteFormer.add(custsiteInst);
                Sorting();
                CustSiteWrapperList = PopulateCustSiteWrapperList();                   
                Checkdelete=false;
                custsiteInst = new CustomerSite__c();
               
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, CustomerConstant.MANDATORY_FIELDS_SAVE ));
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
        
    /******************************************************************
    * Method name : Sorting
    * Description : Sorting the list of sites displayed so as to make the latest site appear on top
    * Return Type : null
    * Parameters  : None.
    *******************************************************************/
    public void sorting() {
        try{
            integer n = EndCustomerSiteFormer.size()-1;
            list<CustomerSite__c> displaySites = new list<CustomerSite__c>();
            
            IF(n != null && n != -1){ 
                for(integer i=n; i>=0; i--){
                    DisplaySites.add(EndCustomerSiteFormer[i]);
                }
            }    
            EndCustomerSite = new list<CustomerSite__c>();
            EndCustomerSite.addAll(DisplaySites);

        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    /******************************************************************
    * Method name : Save
    * Description : On the click of Complete button, save the customer and the sites associated to it, check for suplicate sites for the same user
    * Return Type : page
    * Parameters  : None.
    *******************************************************************/    
    public PageReference save() { 
        try{
            set<id>endCustIDSet = new set<id>();
            Boolean duplicate = false;
            
            Id accId = null;
            User lstUser  = [select id, Begin_Quote__c, Contact.AccountId from User where id=:userInfo.getUserId()LIMIT 1];
            userBeginQuote = lstUser.Begin_Quote__c;
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
            Account_End_Customer_Junction__c junctionObjectInstance = null;
            //check for duplicate address in the site
            set<id> endCustomerIdSet = new set<id>();

            List<End_Customer__c> endCustomerExistingListWithSameName = [Select Id,City__c, Office_Phone__c,Business_Website__c,Suite__c,Floor__c,
                                                                First_Name__c,Company_Legal_Name__c, Last_Name__c,Name,Email__c,DUNS_Number__c,State__c,Street__c,
                                                                Zip__c,Zip_Postal_Code__c,Mailing_Street_Address__c 
                                                                From End_Customer__c
                                                                Where Name=:BusinessName];     
                                                                                                               
            
            for ( End_Customer__c setid : endCustomerExistingListWithSameName )
                   endCustomerIdSet.add(setid.Id);
            
            if (endCustomerExistingListWithSameName != null && endCustomerExistingListWithSameName.size() > 0){
                Integer junctionCount = [Select Count() From Account_End_Customer_Junction__c Where End_Customer__c in: endCustomerIdSet AND Account__c =: accId ];
                if(junctionCount > 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, CustomerConstant.END_CUSTOMER_EXISTS ));
                    return null;
                } 
                else {
                    cust = new End_Customer__c();
                    cust.First_Name__c = FirstName;
                    cust.Last_Name__c = LastName;
                    cust.Name = BusinessName;
                    cust.Zip__c = ZIP;
                    cust.City__c = City;
                    cust.State__c = State;
                    cust.Mailing_Street_Address__c = Address;
                    cust.DUNS__c = DUNS;
                    cust.Email__c = Email;
                    cust.Business_Website__c = BusinessWebsite;
                    cust.Suite__c = Suite;
                    cust.Floor__c = Floor;
                    cust.Office_Phone__c = Phone;
                    cust.Mobile_Phone__c = Phone;
                    
                    insert cust;
                    
                    junctionObjectInstance = new Account_End_Customer_Junction__c(Account__c = accId, End_Customer__c = cust.Id);
                    insert junctionObjectInstance;
                }
            } else {
                cust = new End_Customer__c();
                cust.First_Name__c = FirstName;
                cust.Last_Name__c = LastName;
                cust.Name = BusinessName;
                cust.Zip__c = ZIP;
                cust.City__c = City;
                cust.State__c = State;
                cust.Mailing_Street_Address__c = Address;
                cust.DUNS__c = DUNS;
                cust.Email__c = Email;
                cust.Business_Website__c = BusinessWebsite;
                cust.Suite__c = Suite;
                cust.Floor__c = Floor;
                cust.Office_Phone__c = Phone;
                cust.Mobile_Phone__c = Phone;
                
                insert cust;
                
                junctionObjectInstance = new Account_End_Customer_Junction__c(Account__c = accId, End_Customer__c = cust.id);
                insert junctionObjectInstance;
            }
            
            map<string, CustomerSite__c> customerSiteMap = new Map<String, CustomerSite__c>();
            string serviceAvailKey = SpecialCharacterConstant.CONCAT;
            for (CustomerSite__c siteObj : EndCustomerSite) {
                //Site.End_Customer__c = cust.id;
                //Site.Account_End_Customer_Junction__c = junctionObjectInstance.id;
                serviceAvailKey = (siteObj.Address_Line__c != null ? siteObj.Address_Line__c.replaceAll(SpecialCharacterConstant.BLANK,SpecialCharacterConstant.CONCAT).trim() :SpecialCharacterConstant.CONCAT)
                                    +(siteObj.City__c != null ? siteObj.City__c.replaceAll(SpecialCharacterConstant.BLANK,SpecialCharacterConstant.CONCAT).trim() :SpecialCharacterConstant.CONCAT)
                                    +(siteObj.State__c != null ? siteObj.State__c.replaceAll(SpecialCharacterConstant.BLANK,SpecialCharacterConstant.CONCAT).trim() :SpecialCharacterConstant.CONCAT)
                                    +(siteObj.Zip_Code__c != null ? siteObj.Zip_Code__c.replaceAll(SpecialCharacterConstant.BLANK,SpecialCharacterConstant.CONCAT).trim() :SpecialCharacterConstant.CONCAT);
                customerSiteMap.put(serviceAvailKey.trim(),siteObj);
            }
            
            
            set<string> serviceAvailKeySet = new set<string>();
            for(CustomerSite__c existSiteObj : [Select Id, Account_End_Customer_Junction__c, End_Customer__c, Service_Avail_Key__c 
                                                From CustomerSite__c
                                                Where Service_Avail_Key__c IN: customerSiteMap.keySet()
                                                AND Account_End_Customer_Junction__c =: junctionObjectInstance.Id
                                                AND End_Customer__c =: cust.Id]) {
                serviceAvailKeySet.add(existSiteObj.Service_Avail_Key__c);
            }
            
            list<CustomerSite__c> insertList = new list<CustomerSite__c>();
            for(string key : customerSiteMap.keySet()) {
                if(!serviceAvailKeySet.contains(key)) {
                    if(customerSiteMap.get(key) != null) {
                        customerSiteMap.get(key).End_Customer__c = cust.id;
                        customerSiteMap.get(key).Account_End_Customer_Junction__c = junctionObjectInstance.id;
                        insertList.add(customerSiteMap.get(key));
                    }
                }
            }
            
            if(!insertList.isEmpty()) {
                insert insertList;
            }
            
            //navigate to the manage customers page
            PageReference page = system.page.PortalDesign_ManageCustomers;
            page.getParameters().put('BusinessName',BusinessName);
            return page;
            
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            //ATTException.createException(BuyflowConstant.ERRORIN_ADDNEWCUSTOMERCONTROLLER_SAVE, e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
             
        return null;
    }    
    /******************************************************************
    * Method name : ReadFile
    * Description : On the click of Bulk Upload, extract the sites from the csv file and store it in the temporary site list
    * Return Type : page
    * Parameters  : None.
    *******************************************************************/     
    public PageReference readFile(){
        try{
            EndCustomerSiteFormer.clear();
            PageReference pageRef;
            pageRef = ApexPages.currentPage();
            if ( string.IsNotBlank(excelBody)) {
                if (excelBody!=NULL && excelBody!= SpecialCharacterConstant.CONCAT) {           
                    //Split the complete string with new line character
                    List<String> allRows = excelBody.split(SpecialCharacterConstant.TIDAL);  
                    List<String> finalAllRows = new List<String>();
                    //Check if file has data
                    if(allRows.size() == 3) {
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Nothing to Process'));
                     return null;
                    }  
                   
                    string headerRow = allRows[0];
                    list<String> headerColumns = headerRow.split(SpecialCharacterConstant.COMMA);
                     // Check the headerColumns should be 6 if not throw Error 
                    if(headerColumns.size() != 6) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, CustomerConstant.INVALID_FILE ));
                        return null;
                    }
                    for(integer i=0;i<allrows.size(); i++){
                        list<string> st = allrows[i].split(SpecialCharacterConstant.COMMA);
                        boolean nullRowFound = false;
                        integer noOfCols = 0;
                   
                        for(integer j =0 ; j<st.size(); j++){                   
                            if( st[j]== null || st[j]== SpecialCharacterConstant.CONCAT || st[j]==SpecialCharacterConstant.SINGLE_SPACE || st[j]==SpecialCharacterConstant.TAB_SPACE || st[j] == BuyflowConstant.NAN || st[j] ==SpecialCharacterConstant.SINGLE_SPACE ){ //st[j]== SpecialCharacterConstant.BLANK || st[j]==SpecialCharacterConstant.TAB_SPACE ||st[j]== null || st[j]== SpecialCharacterConstant.CONCAT ||  || 
                                noOfCols+=1;
                            }
                        }
                        if(!(st.size()==noOfCols)){
                            finalAllRows.add(allrows[i]);
                        }
                    }
                    //loopin over the columns in the excel document and assigning it to the corresponding feilds in the customer sites object
                 
                    for(Integer i = 3; i < finalAllRows.size(); i++){                
                        list<String> inputvalues = new List<String>();
                        //inputvalues = filelines[i].split(SpecialCharacterConstant.COMMA);
                        inputvalues = getColumnsByEnhancedEscape(finalAllRows[i]);
                        CustomerSite__c custSite = new CustomerSite__c();
                    
                        integer temp = 6-finalAllRows[i].split(SpecialCharacterConstant.COMMA).size();
                        if(temp==0){                           
                            custSite.Site_Name__c = inputvalues[0];      
                            custSite.Address_Line__c = inputvalues[1];
                            custSite.City__c = inputvalues[2];
                            custSite.State__c = inputvalues[3].trim();  
                            if(inputvalues[4].length()!= 5){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Zipcode :'+inputvalues[4]+'.Please enter valid 5 digit number'));
                                return null;
                            } 
                            else{
                                custSite.Zip_Code__c = inputvalues[4]; 
                                custSite.Phone__c = inputvalues[5];
                                EndCustomerSiteFormer.add(custSite);
                            }   
                        }
                        else{
                            for(integer k=0;k<temp;k++){
                                inputvalues.add(null);
                            }
                            custSite.Site_Name__c = inputvalues[0];      
                            custSite.Address_Line__c = inputvalues[1];
                            custSite.City__c = inputvalues[2];
                            custSite.State__c = inputvalues[3].trim(); 
                            if(inputvalues[4].length()!= 5){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Zipcode :'+inputvalues[4]+'.Please enter valid 5 digit number'));
                                return null;
                            } 
                            else{
                               custSite.Zip_Code__c = inputvalues[4]; 
                               custSite.Phone__c = inputvalues[5];
                               EndCustomerSiteFormer.add(custSite); 
                            }
                        }   
                    }
                    Sorting();
                    CustSiteWrapperList = PopulateCustSiteWrapperList();
                    pageRef = ApexPages.currentPage();
                    pageRef.getParameters().put('mode','checkbox');
                    completedisable();
            
                }
                else{
                    if(pageRef != null) {
                        pageRef.getParameters().put('display','invalid'); 
                        pageRef.setRedirect(true);
                        return pageRef;
                    }
                } 
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, CustomerConstant.CORRECT_TEMPLATE_TEXT));
            } 
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }      
        return null;
    }
    
    /********************************************************************
    * Method name   : getColumnsByEnhancedEscape
    * Description   : To parse the string into list of reocrds
    * Parameter     : String 
    * Return type   : List of strings
    ********************************************************************/
    private static List<String> getColumnsByEnhancedEscape(String dataRow){
        try{
            //This variable is to hold the Quoted Row data
            
            boolean isQuotedData = false;
            string columnVal;        
            list<String> dataColumns = new list<String>(); //List to hold the column values
           // List<String> splittedByComma = dataRow.split(Constants.COMMA_CHARACTER);
            list<String> splittedByComma = dataRow.split(SpecialCharacterConstant.COMMA);
            
            for(Integer i = 0; i < splittedByComma.size(); i++) {               
                string val = splittedByComma[i]; //Hold the current value
                
                if(!String.IsBlank(val)) {                  
                    //Check if data is wrapped with Doule Quote, then directly move to the next column
                    if(val.trim().startsWith(SpecialCharacterConstant.DOUBLE_QOUTE) && val.trim().endsWith(SpecialCharacterConstant.DOUBLE_QOUTE)) {
                        
                        columnVal = val;
                        columnVal = columnVal.replaceAll(SpecialCharacterConstant.DOUBLE_QOUTE, SpecialCharacterConstant.CONCAT);
                
                    } else if(isQuotedData == false && val.trim().startsWith(SpecialCharacterConstant.DOUBLE_QOUTE)) {
                       
                        //mark this data as quoted data and move to the next column
                        isQuotedData = true;
                        columnVal = val;
                        continue;
                    } else if(isQuotedData == true && val.trim().endsWith(SpecialCharacterConstant.DOUBLE_QOUTE)) {
                        
                        //If Last data was quoted data and current data is also ends were " character, then consider this is one column
                        isQuotedData = false;
                        columnVal += SpecialCharacterConstant.COMMA + val;
                        columnVal = columnVal.replaceAll(SpecialCharacterConstant.DOUBLE_QOUTE, SpecialCharacterConstant.CONCAT);
                    } else if(isQuotedData) {
                        
                        //If last data was quoted, and it's not ended yet, then append values and continue
                        columnVal += SpecialCharacterConstant.COMMA + val;
                        continue;
                    } else {
                        //No Quoted data
                        columnVal = val;
                    }
                } else {
                    //Set as blank
                    columnVal = SpecialCharacterConstant.CONCAT;
                }
                //Add in List
                dataColumns.add(columnVal);
            }
            //Return 
            return dataColumns;
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }   
    /*******************************************************************
    * Class name   : CustSiteWrapperCls
    * Description  : Wrapper class to show values in Grid.
    * Parameter    : N/A 
    * Return Type  : N/A
    *******************************************************************/
    public class CustSiteWrapperCls {
    public Boolean isSelected {get;set;}
    public Boolean Selected {get;set;}
    public CustomerSite__c CustSiteInst {get;set;}
    public Integer counter { get; set; }

/* 
 Name: CustSiteWrapperCls
 Description: 
 */ 
        public  CustSiteWrapperCls(CustomerSite__c EndCust,Integer counter,Boolean selected) {
            CustSiteInst = EndCust;
            this.counter=counter;
            this.isSelected=selected;            
        }   
    }

    /******************************************************************
    * Method name : ACTION1
    * Description : Action support on filling First Name mandatory field
    * Return Type : null
    * Parameters  : None.
    *******************************************************************/  
    public void aCTION1() {
        try{
            ACT1 = true;
            completedisable();
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }    
    /******************************************************************
    * Method name : ACTION2
    * Description : Action support on filling Business Name mandatory field
    * Return Type : null
    * Parameters  : None.
    *******************************************************************/
    public void aCTION2() {
        try{
            ACT2 = true;
            completedisable();
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /******************************************************************
    * Method name : ACTION3
    * Description : Action support on filling Last Name mandatory field
    * Return Type : null
    * Parameters  : None.
    *******************************************************************/
    public void aCTION3() {
        try{
            ACT3 = true;
            completedisable();
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /******************************************************************
    * Method name : ACTION4
    * Description : Action support on filling Address mandatory field
    * Return Type : null
    * Parameters  : None.
    *******************************************************************/
    public void aCTION4() {
        try{
            ACT4 = true;
            completedisable();
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    /******************************************************************
    * Method name : ACTION5
    * Description : Action support on filling Email mandatory field
    * Return Type : null
    * Parameters  : None.
    *******************************************************************/
    public void aCTION5() {
        try{
            ACT5 = true;
            completedisable();
        }
            catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /******************************************************************
    * Method name : ACTION6
    * Description : Action support on filling Contact Phone mandatory field
    * Return Type : null
    * Parameters  : None.
    *******************************************************************/
    public void aCTION6() {
        try{
            ACT6 = true;
            completedisable();
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    /******************************************************************
    * Method name : ACTION7
    * Description : Action support on filling City mandatory field
    * Return Type : null
    * Parameters  : None.
    *******************************************************************/
    public void aCTION7() {
        try{
            ACT7 = true;
            completedisable();
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /******************************************************************
    * Method name : ACTION8
    * Description : Action support on filling ZIP mandatory field
    * Return Type : null
    * Parameters  : None.
    *******************************************************************/
    public void aCTION8() {
        try{
            ACT8 = true;
            completedisable();
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    /******************************************************************
    * Method name : completedisable
    * Description : Making the boolean of complete button disable/enable
    * Return Type : null
    * Parameters  : None.
    *******************************************************************/
    public void completedisable() {
        try{
            if(ACT1 == true && ACT2 == true && ACT3 == true && ACT4 == true && ACT5 == true && ACT6 == true && ACT7==true && ACT8==true) {
                completeButton = true;
               // bol = true;
            }else{
                completeButton = false;
               // bol = false;
            }
        } 
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }

    /******************************************************************
    * Method name  : PopulateCustSiteWrapperList
    * Description  : Method to populate wrapper list to show it in the grid.
    * Parameter    : N/A 
    * Return Type  : List<CustSiteWrapperCls>
    *******************************************************************/
    public List<CustSiteWrapperCls> populateCustSiteWrapperList(){
        try{
            //initialising the wrapper list and populating it
            CustSiteWrapperList = new List<CustSiteWrapperCls>();
            integer counter = 0;
            Boolean isSelected = false;
            
            for(CustomerSite__c endCustIns : EndCustomerSite) {
                counter = counter + 1;
                CustSiteWrapperList.add(new CustSiteWrapperCls(endCustIns,counter,isSelected));
            }

            return CustSiteWrapperList;
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }
    
    /******************************************************************
    * Method name : getselected
    * Description : Method to make isSelected variabe in the wrapper list true when a checkbox is selected 
    * Return Type : null
    * Parameters  : None.
    *******************************************************************/
    public void getselected(){
        try{
            WrapperList = New List<CustSiteWrapperCls>();
            for(CustSiteWrapperCls wrap1 : CustSiteWrapperList){
                if(wrap1.isSelected==false){
                    WrapperList.add(New CustSiteWrapperCls(wrap1.CustSiteInst,wrap1.Counter,wrap1.isSelected)); 
                }
            }
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }    
    /******************************************************************
    * Method name : DeleteAction
    * Description : Method to delete sites from the database 
    * Return Type : page
    * Parameters  : None.
    *******************************************************************/
    public Pagereference deleteAction(){
        try{
           CustSiteWrapperList = new list<CustSiteWrapperCls>();
           EndCustomerSiteFormer = new list<CustomerSite__c>();
           integer counter = 0;
           Boolean isSelected = false;
            for(CustSiteWrapperCls wrapCust: WrapperList){
                counter = counter + 1;
                EndCustomerSiteFormer.add(wrapCust.CustSiteInst);
                CustSiteWrapperList.add(new CustSiteWrapperCls(wrapCust.CustSiteInst,counter,false));
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return null;
    }
}