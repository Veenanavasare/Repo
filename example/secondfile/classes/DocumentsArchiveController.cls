/************************************************************************************** 
Apex Class Name     : DocumentsArchiveController
Version             : 2.0  
Created Date        : 3rd August 2017
Function            : Controller for the Document Archive functionality
*************************************************************************************/
global with sharing class DocumentsArchiveController{
    
    public String quoteId{get;set;}
    public String pageToLoad{get;set;}  
    public list<SelectOption> actionList{get;set;} 
    public list <AttachmentsWrapper> lstAttachmentWrapper{get;set;}
    
    public DocumentsArchiveController(){
        quoteId = ApexPages.currentPage().getParameters().get('id') != null ? ApexPages.currentPage().getParameters().get('id') : '';
        pageToLoad = quoteId == '' ? 'PortalDesign_DocumentsArchive': 'PortalDesign_QuoteDocumentsArchive';
        actionList = getActionList();        
    }  
    
    /*To fetch all Opportunities in Order Submitted Stage*/
    @RemoteAction
    global static List<Opportunity> fetchOpportunityRecords() {
        try{
            User usr = new User();
            if(Test.isrunningTest()){
                usr = [select id,accountid ,Begin_Quote__c,contactId from User limit 1];
            }
            else{
                usr = [Select Id,ContactId FROM User WHERE id=:userinfo.getuserId()];
            }
            Contact con = new Contact();
            if(Test.isrunningTest()){
                con = [SELECT Id, AccountId FROM Contact LIMIT 1];
            }
            else if(usr.ContactId != null) {  
                con = [SELECT Id, AccountId FROM Contact WHERE Id=:usr.ContactId];
            }
            Id accId = con.AccountId; 
            set<String> opptyStages = new set<String>{'Order Submitted'}; 
            String soql ='select Id,Quote_ID__c, EndCustomerName__c, Sub_Account__c, Order_Submitted_Date__c, Service_Type_Formula__c, Number_of_Products__c,Block_Site_Level_Documents__c from Opportunity where AccountId =: accId and ATOM_Deal__c = TRUE and StageName in: opptyStages';
            return Database.query(soql);
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }  
    }
    
    /*To fetch all Opportunities in Order Submitted Stage*/
    @RemoteAction
    global static List<Opportunity> fetchSPProductRecords(String opptyId) {
        try{
            String soql ='select Id, Site_Friendly_Name__c, Site_Address__c, Product_Service_Type__c,Port_Speed_Name__c,Block_RDS_Details__c from SPProduct__c where Deal__c =: opptyId';
            return Database.query(soql); 
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }  
    }
    
    /*To fetch all Order Level and Site Level attachments*/
    @RemoteAction
    global static List<Attachment> fetchAttachments(String opptyId) {
        try{          
            Set<String> parentIds = new Set<String>();
            parentIds.add(opptyId);
            list<RDS_Pricing_Schedule_Detail__c> rdsPricingScheduleList = new list<RDS_Pricing_Schedule_Detail__c>();
            rdsPricingScheduleList = [Select id, Deal__c from RDS_Pricing_Schedule_Detail__c where Deal__c =: opptyId];
            for(RDS_Pricing_Schedule_Detail__c psr: rdsPricingScheduleList){
                parentIds.add(psr.Id);
            }
            String soql ='select Id, Name, ParentId, BodyLength, ContentType from Attachment where (NOT Name like \'%[APPROVED]_signed%\') and (NOT Name like \'%Network_Signed%\') and (NOT Name like \'%Service_Signed%\') and (NOT Name like \'%QuoteExport%\') and ParentId in: parentIds';
            system.debug('@@@SOQL Query: '+Database.query(soql));
            return Database.query(soql);            
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }  
    }
 
    /*To fetch the Action dropdown values*/
    public List<SelectOption> getActionList() {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('Select',''));
        options.add(new SelectOption(Label.VIEW_SITE_LEVEL_DOCU,Label.VIEW_SITE_LEVEL_DOCU));
        options.add(new SelectOption(Label.DOWNLOAD_DOCUMENTS,Label.DOWNLOAD_DOCUMENTS));
        return options;
    } 

    /*This method gets the attachment id and fetches and sends it back to VF page*/
    @RemoteAction
    public static List <AttachmentsWrapper> getDocumentCnt(String documentIds){
        system.debug('@@@Document Ids: '+documentIds); 
        List<Attachment> lstAttachments = new List<Attachment>();        
        List <AttachmentsWrapper> lstAttachmentWrapper = new List <AttachmentsWrapper>();
        AttachmentsWrapper wrapper = new AttachmentsWrapper();
        integer partNumber=0;
        integer subStringNumber = 0;
        
        lstAttachments = new List<Attachment>();
        lstAttachments = [SELECT Id, Name, ParentId, ContentType, Body, BodyLength FROM Attachment where Id=:documentIds];
        
        //Prepare the data for VF page
        for(Attachment att : lstAttachments){        
            wrapper.attid = att.Id;
            wrapper.attName = att.Name;
            wrapper.attEncodedBody = EncodingUtil.base64Encode(att.Body);
            System.debug('Attachment ID: '+att.Id +'Attachment Size: '+wrapper.attEncodedBody.length()); 
            wrapper.attFileSize = att.BodyLength;
            lstAttachmentWrapper.add(wrapper);
        }
        system.debug('@@@Attachments: '+lstAttachmentWrapper);
        return lstAttachmentWrapper;
    }
    
    /*This is the bean class for sending data to VF page*/
    public class AttachmentsWrapper{
        public String attid {get; set;}
        public String attEncodedBody {get; set;}
        public String attName {get; set;}
        public Integer attFileSize {get; set;}
        public String attLastAttachment {get; set;}
    }
    
    /*Refresh Data Table*/
    public void refreshDataTable(){
    }
}