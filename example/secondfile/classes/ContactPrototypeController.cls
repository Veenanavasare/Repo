/******************Support Center Controller**************************/
public class ContactPrototypeController{
    public String userName{get;set;}
    public String contactName{get;set;}
    public String companyName{get;set;}
    public String contactEmail{get;set;}
    public String contactPhone{get;set;}
    Public List<Contact> userContact{get;set;}
    Public User userRecord {get;set;}
    public String displayName{get;set;}
    public String BDUserID {get;set;}       
    // Added by Eliza for caselist dashboard
    public class caseList{
        public string CaseComments{get;set;}
        public string CaseNumber{get;set;}
        public string Status{get;set;}
        public string Topic{get;set;}
        public string Category{get;set;}
        public string Product{get;set;}
        public string Contactname{get;set;}
        public string CreatedDate{get;set;}
        public string ClosedDate{get;set;}
        public string Subject{get;set;}
        public string CircuitID{get;set;}
        public string Description{get;set;}  
        public string Product_Family{get;set;}
        public string Billing_Account_Number_BAN{get;set;}
        public string Issue_Type{get;set;}
        public string Order_Number{get;set;}
        public string Asset_ID{get;set;}
        public string Asset_Type{get;set;}
        public string Mobility_Trouble_Type{get;set;}
        public string ATT_Trouble_Ticket_Number{get;set;}
        public string Information_Request_Subject{get;set;}
        public string SP_Internal_Ticket_Number{get;set;}        
        public string End_Customer_Company_Name{get;set;}
        public string Service_Address_Street{get;set;}
        public string Service_Address_City{get;set;}
        public string Service_Address_State{get;set;}
        public string Service_Address_Zip{get;set;}
        public string Service_Address_Country{get;set;} 
        public string liveTraffic{get;set;}  
        public string OpportunityID {get;set;}  
        public string subCategory{get;set;}       
    }     
    public list<caseList> listCase {get; set;}
    public List<String> commentList {get; set;}     
    public String spComment {get; set;} 
    public caseList cList{get; set;}
    public Boolean EmailCommentNotify{get;set;}
    public String emailCAM{get;set;}
    public String docLink{get;set;}   
    public String docLink1{get;set;}   
    
    //Service Delivery
    public String Product{get;set;}
    public String Topic{get;set;}
    public String Category{get;set;}
    public String subCategory{get;set;}
    public String Subject{get;set;}    
    public String Issue_Type{get;set;} 
    public String Issue_Type1{get;set;} 
    public String Issue_Type2{get;set;} 
    public String Issue_Type3{get;set;} 
    public String Issue_Type4{get;set;}
    public String Opportunity_ID{get;set;}  
    public String Order_Number{get;set;}     
    public String Service_Address_Street{get;set;}
    public String Service_Address_City{get;set;}
    public String Service_Address_State{get;set;}    
    public String Service_Address_Country {get;set;}
    public String Service_Address_Country_Other {get;set;}
    public String Access_Type{get;set;}
    public String Access_Speed{get;set;}
    public String Access_Speed_1{get;set;}
    public String Point_of_Contact_Name{get;set;}
    public String Point_of_Contact_Telephone_Number{get;set;}
    public String IMEI{get;set;}
    public String Trouble_Report{get;set;}
    public String Reason{get;set;}
    public String Reason_1{get;set;}
    public String Authorized_Contact_Email_Address{get;set;}
    public String Authorized_Contact_Name{get;set;}
    public String Authorized_Contact_Phone_Number{get;set;}
    public String Description {get;set;} 
    public String livetraffic{get;set;}           
    //Service Assurance    
    public String   Asset_Type  {get;set;}
    public String   Asset_ID    {get;set;}
    public String   Intrusive_Test_Authorization {get;set;}
    public String   Intrusive_Test_Window{get;set;}
    public String   End_Customer_Company_Name   {get;set;}
    public String   End_Customer_Local_Contact_Phone_Number     {get;set;}
    public String   End_Customer_Local_Contact_Name {get;set;}
    public String   End_Customer_Site_Access_Hours_M_F  {get;set;}
    public String   End_Customer_Site_Access_Hours_Sat_Sun{get;set;}
    public String   SP_Technical_Contact_Name   {get;set;}
    public String   SP_Technical_Contact_Phone  {get;set;}
    public String   SP_Technical_Contact_Email  {get;set;}
    public String   SP_Technical_Contact_Name_1   {get;set;}
    public String   SP_Technical_Contact_Phone_1 {get;set;}
    public String   SP_Technical_Contact_Email_1  {get;set;} 
    public String   Alternate_SP_Technical_Contact_Name {get;set;}
    public String   Alternate_SP_Technical_Contact_Phone {get;set;}
    public String   Alternate_SP_Technical_Contact_Email {get;set;}           
    public String   Alternate_SP_Technical_Contact_Name_1 {get;set;}
    public String   Alternate_SP_Technical_Contact_Phone_1 {get;set;}
    public String   Alternate_SP_Technical_Contact_Email_1 {get;set;}    
    public String   SP_Internal_Ticket_Number   {get;set;}
    public String   SP_Internal_Ticket_Number_1   {get;set;}
    public String   Mobility_Trouble_Type{get;set;}
    public String   SIM_Number  {get;set;} 
    public String   ATT_Trouble_Ticket_Number {get;set;}
    public String   ATT_Trouble_Ticket_Number_1 {get;set;} 
    public String   Information_Request_Subject {get;set;}
    public String   Information_Request_Subject_1 {get;set;}
    public String   Physical_Address {get;set;}    
    public String  Trouble_Report_1 {get;set;}
    public String  Trouble_Report_2 {get;set;}
    public String  Trouble_Report_3 {get;set;}
    public String  Trouble_Report_4 {get;set;}        
    public String Phone_Number_CTN{get;set;}
    public String Phone_Number_CTN_1 {get;set;}
    public String Phone_Number_CTN_2 {get;set;}
    public String Phone_Number_CTN_3 {get;set;}
    public String Phone_Number_CTN_4 {get;set;}        
    public String IMEI_1 {get;set;}
    public String IMEI_2 {get;set;}
    public String IMEI_3 {get;set;}
    public String SIM_Number_1{get;set;}
    public String SIM_Number_2{get;set;}
    public String SIM_Number_3{get;set;}
    public String Physical_Address_1{get;set;}
    public String Physical_Address_2{get;set;}    
    // Billing     
    public String  Product_Family {get;set;}
    public String Account_Number {get;set;}    
    public String Number_of_Invoices{get;set;}
    public String Number_of_Invoices_1{get;set;}
    public String Invoice_Dates{get;set;}
    public String Number_of_Circuit_IDs{get;set;}
    public String Circuit_IDs{get;set;}
    public string Number_of_Disputed_Telephone_Numbers{get;set;}
    public string Invoice_Number{get;set;}
    public string Type_of_fee_tax{get;set;}  
    public string Resolution_Service_Line{get;set;}
    public string Reported_Username {get;set;}     
   public Decimal Disputed_Amount{get;set;}
   public Decimal Disputed_Amount_1{get;set;}
   public String Billing_Account_Number_BAN{get;set;}
   public Date Customer_Requested_Due_Date{get;set;}
   public String Service_Address_Zip{get;set;}    
    //Document Mapping
    public String docName { get; set; }
    public String docDesc { get; set; }
    public String fileURL { get; set; } 
    public String DocURL { get; set; }
    public String folderName{ get; set; }    
    public Map<String, Document> mainFolderKeyMap{get;set;}        
    public String docId { get; set; }   
    public list<Folder> folderId; 
    public List<Document> DocMapSDEscalation{get; set;}        List<String> listSDEscalation = new List<String>();    Map<String, Document> keyMapSDEscalation = new  Map<String, Document>();   
    public List<Document> DocMapSDCancellation{get; set;}      List<String> listSDCancellation = new List<String>();  Map<String, Document> keyMapSDCancellation = new  Map<String, Document>();      
    public List<Document> DocMapSDOrderStatus{get; set;}       List<String> listSDOrderStatus = new List<String>();   Map<String, Document> keyMapSDOrderStatus = new  Map<String, Document>();   
    public List<Document> DocMapSDTTU{get; set;}  List<String> listSDTTU = new List<String>();  Map<String, Document> keyMapSDTTU = new  Map<String, Document>();   
    public List<Document> DocMapSDRDSAssistance{get; set;}     List<String> listSDRDSAssistance = new List<String>(); Map<String, Document> keyMapSDRDSAssistance= new  Map<String, Document>();       
    public List<Document> DocMapSDMacd{get; set;}     List<String> listSDMacd = new List<String>(); Map<String, Document> keyMapSDMacd= new  Map<String, Document>();     
    public List<Document> DocMapSATTEscalation{get; set;}      List<String> listSATTEscalation = new List<String>();  Map<String, Document> keyMapSATTEscalation = new  Map<String, Document>();   
    public List<Document> DocMapSATTCreation{get; set;}        List<String> listSATTCreation = new List<String>();    Map<String, Document> keyMapSATTCreation = new  Map<String, Document>(); 
    public List<Document> DocMapBTaxesExemptions{get; set;}    List<Integer> listBTaxesExemptions = new List<Integer>(); Map<Integer, Document> keyMapBTaxesExemptions = new  Map<Integer, Document>(); 
    public List<Document> DocMapBGeneralQ{get; set;}    List<Integer> listBGeneralQ = new List<Integer>(); Map<Integer, Document> keyMapBGeneralQ = new  Map<Integer, Document>();    
    public List<Document> DocMapBLDisputes{get; set;}    List<Integer> listBLDisputes = new List<Integer>(); Map<Integer, Document> keyMapBLDisputes = new  Map<Integer, Document>();   
    public List<Document> DocMapSDMobility{get; set;}     List<String> listSDMobility = new List<String>(); Map<String, Document> keyMapSDMobility= new  Map<String, Document>();   
    
    @RemoteAction
    public static List<String> getMessage(String CaseNumber)
    {
       List<User>  internalUser= [select id from user where contact.account.id !=null];       
       Set<String> internalUserId= new Set<String>();       
       if(internalUser.size()>0) { for (User us:internalUser){ internalUserId.add(us.id);}  } 
       List<Datetime> ecList = new List<Datetime>();
       Map<Datetime,String> mapDate = new Map<Datetime,String>();
       List<Datetime> sortedList = new List<Datetime>();
       List<String> commentList = new List<String>();                 
       System.debug('*****************************CaseNumber*****'+CaseNumber);
       if(CaseNumber!=null)  {                                
       case cs = [select (select CcAddress,FromName,ToAddress,FromAddress,ParentId,HtmlBody,textbody,CreatedDate,subject from EmailMessages),
                         (Select CreatedById,CreatedBy.Name,CreatedDate,CommentBody From CaseComments where IsPublished=true order by CreatedDate DESC),
                          CaseNumber,CreatedDate from case where CaseNumber=:CaseNumber];                          
       if(cs.EmailMessages.size()>0){ 
       system.debug('**********************EmailMessage Size*******************************'+cs.EmailMessages.size());                            
                        for(EmailMessage e:  cs.EmailMessages)  {  
                            ecList.add(e.createddate);       
                            Datetime dt = e.createddate;
                            String emailDate = dt.format('MM/dd/YY h:mm a','CST');  
                            String emailBody = e.HtmlBody; 
                            /*
                            if(emailBody!=null){
                             if(!emailbody.endsWithIgnoreCase('</html>')) {                                                                                  
                                 emailBody  = 'Content cannot be loaded on page';                           
                               }
                             }
                            */                                  
                            if(emailBody==null)  { 
                                emailBody = e.textbody;                                
                                if(emailbody.contains('--------------- Original Message ---------------')) {
                                emailbody  = emailbody.substringBefore('--------------- Original Message ---------------').trim(); }                                 
                                if (emailbody.contains('-----Original Message-----')){                                
                                emailbody  = emailbody.substringBefore('-----Original Message-----').trim();   
                                }                                                     
                            }           
                            if(emailBody!=null && emailbody.contains('ref:')) {                                                                                  
                                String part1 = emailbody.substringBetween('ref:',':ref');                             
                                String part2 = 'ref:'+part1+':ref';                             
                                emailBody  = emailbody.remove(part2);                           
                            }  
  system.debug('**********************emailBody - *****************************'+emailBody);                                                 
                            String emailto = '';
                            if(e.CcAddress!=null){ emailto = e.ToAddress+';'+e.CcAddress; }
                            else {emailto = e.ToAddress;}                               
                            String emailFrom = e.FromName+'&nbsp &lt;'+e.FromAddress+'&gt;';
                            String email = '<div class="comment-container"><span class="comment-body email-from from-line"><strong>From</strong>: '+emailFrom+' received on '+emailDate+'  CT'+
                                           '<div class="comment-block email-to to-line"><strong>To</strong>: ' +emailto+
                                           '</div><div class="comment-block subject-line"><strong>Subject</strong>: '+e.subject+
                                           '</div><div class="comment-block email-body">'+emailBody+'</div></span></div>';   
                            mapDate.put(e.createddate,email);                                              
                          }
                    }                                   
                    if(cs.CaseComments.size()>0){         
   System.debug('**********************CaseComment Size*******************************'+cs.CaseComments.size());             
                        for(CaseComment c:  cs.CaseComments)  {                       
                             ecList.add(c.createddate);   
                             Datetime dt = c.createddate;
                             String commentDate = dt.format('MM/dd/YY h:mm a','CST'); 
                             String CreatedByName = null;
                             String CreatedById =  String.valueOf(c.CreatedById);
                             if(internalUserId.size()>0){                         
                                if(internalUserId.contains(CreatedById)){CreatedByName = c.CreatedBy.Name;}
                                else{CreatedByName = '##Comment from AT&T Partner Exchange##'+'\n'+c.CreatedBy.Name;}
                              }
                             String comment = '<div class="comment-container"><span class="medium-font">' +CreatedByName+
                                              '</span> <span class="comment-date">' +commentDate+'  CT'+
                                              '</span><span class="comment-body">'+c.CommentBody+'</span></div>';
                              mapDate.put(c.createddate,comment);                         
                       }                               
                  }                      
             }
      System.debug('**********************ecList Size*******************************'+ecList.size());               
       ecList.sort();
       for(Integer i = ecList.size()-1; i>=0;i--)  { sortedList.add(ecList.get(i)); }       
       for(Datetime c:sortedList) { commentList.add(mapDate.get(c)); }        
       return commentList;
    }    
    
    
    public ContactPrototypeController(){      
    try{
       userRecord = [select contactId from User where Id=:UserInfo.getUserId()];   
       userContact = [select id,Account.Owner.email,Account.Name,Account.Id,FirstName,LastName,Email,Phone,Partner_Exchange_User_Name__c from Contact where Id=:userRecord.contactId];       
       TimeZone tz = UserInfo.getTimeZone();
       displayName= tz.getDisplayName();
       cList = new caseList();
       String caseNo = System.currentPageReference().getParameters().get('CaseNumber');       
       String caseId = System.currentPageReference().getParameters().get('caseId');
       String cNumber = (caseNo!=null)?caseNo:caseId;       
       if(cNumber!= null){        
       List<Case_Comment_Notification__c> cnObj= [select Please_notify_me__c,FollowingContact__c,Related_Case__c from 
                                            Case_Comment_Notification__c where Please_notify_me__c = True and 
                                            Related_Case__r.casenumber=:cNumber and
                                            FollowingContact__c=:userRecord.contactId];       
       if(cnObj.size()>0) EmailCommentNotify = cnObj[0].Please_notify_me__c;  
       }    
       listCase  = new List<caseList>();
       commentList = new List<String>();          
       if(userContact.size()>0){ 
           BDUserID = userContact[0].Partner_Exchange_User_Name__c;                   
           for(case cs : [select SubCategory__c,Opportunity_ID__c,LiveTraffic__c,id,Topic__c,Category__c,Status,CaseNumber,Product__c,Contact.name,ClosedDate,CreatedDate,Subject,Circuit_IDs__c,Description,
                          Product_Family__c,Billing_Account_Number_BAN__c,Issue_Type__c,Order_Number__c,Asset_ID__c,Asset_Type__c,
                          Mobility_Trouble_Type__c,ATT_Trouble_Ticket_Number__c,Information_Request_Subject__c,SP_Internal_Ticket_Number__c,End_Customer_Company_Name__c,
                          Service_Address_Street__c,Service_Address_City__c,Service_Address_State__c,Service_Address_Zip__c,Service_Address_Country__c
                          from case where Account.id  =: userContact[0].Account.Id 
                          AND Origin IN ('Support Center', 'Manually Created', 'Email-to-Case') 
                          AND RecordType.DeveloperName IN ('System_Access_Issue', 'Service_Delivery','Service_Assurance', 'Billing') ])
           {    // Case List
                caseList cl = new caseList();            
                    cl.CaseNumber = cs.CaseNumber;
                    cl.Status = cs.Status;
                    cl.Topic = cs.Topic__c;
                    cl.Category = cs.Category__c;
                    cl.Product = cs.Product__c;
                    cl.Contactname = cs.Contact.name;
                    if(cs.CreatedDate!=null){
                        Datetime dt = cs.CreatedDate;
                        String convertedDate = dt.format('MM/dd/YY h:mm a','CST');    
                        cl.CreatedDate = convertedDate;}
                    else
                    cl.CreatedDate = '';
                    if(cs.ClosedDate!=null){
                        Datetime dt = cs.ClosedDate;
                        String convertedDate= dt.format('MM/dd/YY h:mm a','CST');   
                        cl.ClosedDate = convertedDate;}
                    else
                    cl.ClosedDate = '';
                    cl.Order_Number =cs.Order_Number__c;     
                    cl.SP_Internal_Ticket_Number =cs.SP_Internal_Ticket_Number__c;     
                    cl.OpportunityID=cs.Opportunity_ID__c;  
                    cl.subCategory=cs.SubCategory__c;        
                listCase.add(cl);
                    // Case Details
                if(caseNo == cs.CaseNumber){                        
                    cList.CaseNumber = cs.CaseNumber;
                    cList.Status = cs.Status;
                    cList.Topic = cs.Topic__c;
                    cList.Category = cs.Category__c;
                    cList.subCategory=cs.SubCategory__c;
                    cList.Product = cs.Product__c;
                    cList.Contactname = cs.Contact.name;
                    if(cs.CreatedDate!=null){
                        Datetime dt = cs.CreatedDate;
                        String convertedDate= dt.format('MM/dd/YY h:mm a','CST');                     
                        cList.CreatedDate = convertedDate;} 
                    else
                    cList.CreatedDate = '';     
                    if(cs.ClosedDate!=null){                   
                        Datetime dt = cs.ClosedDate;
                        String convertedDate= dt.format('MM/dd/YY h:mm a','CST');                     
                        cList.ClosedDate = convertedDate;}
                    else
                    cList.ClosedDate = '';              
                    cList.Subject = cs.Subject;
                    cList.CircuitID = cs.Circuit_IDs__c;                   
                    cList.Description  = cs.Description;                                            
                    cList.Product_Family = cs.Product_Family__c;                                           
                    cList.Billing_Account_Number_BAN = cs.Billing_Account_Number_BAN__c;                                                
                    cList.Issue_Type = cs.Issue_Type__c;                                                
                    cList.Order_Number =cs.Order_Number__c;                           
                    cList.Asset_ID = cs.Asset_ID__c;  
                    cList.Asset_Type = cs.Asset_Type__c;                                            
                    cList.Mobility_Trouble_Type = cs.Mobility_Trouble_Type__c;                              
                    cList.ATT_Trouble_Ticket_Number = cs.ATT_Trouble_Ticket_Number__c;                   
                    cList.Information_Request_Subject = cs.Information_Request_Subject__c;                  
                    cList.SP_Internal_Ticket_Number =cs.SP_Internal_Ticket_Number__c;                
                    cList.End_Customer_Company_Name =cs.End_Customer_Company_Name__c;  
                    cList.Service_Address_Street =cs.Service_Address_Street__c; 
                    cList.Service_Address_City =cs.Service_Address_City__c; 
                    cList.Service_Address_State =cs.Service_Address_State__c;
                    cList.Service_Address_Zip =cs.Service_Address_Zip__c;
                    cList.Service_Address_Country =cs.Service_Address_Country__c;
                    cList.liveTraffic = cs.LiveTraffic__c;
                    cList.OpportunityID=cs.Opportunity_ID__c;    
            } }  }    
      
       if(userContact.size()>0)
       {
       String firstName = userContact[0].FirstName!=null?userContact[0].FirstName+' ':'';
       userName = firstName +userContact[0].LastName; 
       contactName = firstName +userContact[0].LastName;
       companyName = userContact[0].Account.Name;
       contactEmail = userContact[0].Email;
       contactPhone  = userContact[0].phone;
       }  
        // Document Management on support center page 
            folderId = new list<Folder>();            
            String pageUrl = URL.getSalesforceBaseUrl().getHost();                           
            folderId = [select id from Folder where Name = 'Support Center' and Type ='Document' Limit 1]; 
            List<Folder> mainFolderId = [select id from Folder where Name='CommonFolder' Limit 1];
            mainFolderKeyMap = new  Map<String, Document>(); 
            for(Document doc : [select id,URL,type,name,description,DeveloperName,keywords from Document where Document.FolderId =: mainFolderId[0].id]){
                mainFolderKeyMap.put(doc.DeveloperName,doc);         
            }  
            Support_Center__c sec = Support_Center__c.getvalues('sName');
            DocMapSDEscalation= new List<Document>();
            DocMapSDCancellation= new List<Document>();
            DocMapSDOrderStatus= new List<Document>();
            DocMapSDTTU= new List<Document>();
            DocMapSDRDSAssistance= new List<Document>();
            DocMapSDMacd= new List<Document>();
            DocMapSATTEscalation= new List<Document>();
            DocMapSATTCreation= new List<Document>();
            DocMapBTaxesExemptions= new List<Document>();
            DocMapBLDisputes= new List<Document>();             
            DocMapBGeneralQ= new List<Document>();                      
            DocMapSDMobility= new List<Document>();           
            if(folderId!=null && folderId.size()>0){            
                for(Document doc : [select id,URL,type,name,description,DeveloperName,keywords from Document where Document.FolderId =: folderId[0].id]){
                    DocURL = 'https://'+pageUrl+'/servlet/servlet.FileDownload?file='+doc.Id;
                    fileURL  = 'https://'+pageUrl+'/servlet/servlet.FileDownload?file=';  
                   if(doc.keywords==sec.SD_Escalation__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];keyMapSDEscalation.put(key,doc);listSDEscalation.add(key);}  //SDEscalation          
                   if(doc.keywords==sec.SD_Cancellation__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];keyMapSDCancellation.put(key,doc);listSDCancellation.add(key);}  //SDCancellation           
                   if(doc.keywords==sec.SD_OrderStatus__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];keyMapSDOrderStatus.put(key,doc);listSDOrderStatus.add(key);}  //SDOrderStatus
                   if(doc.keywords==sec.SD_TTU__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];keyMapSDTTU.put(key,doc);listSDTTU.add(key);}  //SDTTU                        
                   if(doc.keywords==sec.SD_Mobility__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];keyMapSDMobility.put(key,doc);listSDMobility.add(key);}  //SDMobility
                   if(doc.keywords==sec.SD_RDSAssistance__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];keyMapSDRDSAssistance.put(key,doc);listSDRDSAssistance.add(key);}  //SDRDSAssistance
                   if(doc.keywords==sec.SD_Macd__c){if(doc.DeveloperName.startsWith('Non_Contract_Impacting')) docLink = doc.id; if(doc.DeveloperName.startsWith('MACD_RDS')) docLink1 = doc.id;List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];keyMapSDMacd.put(key,doc);listSDMacd.add(key);}  //SDMacd                 
                   if(doc.keywords==sec.SA_TTCreation__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];keyMapSATTCreation.put(key,doc);listSATTCreation.add(key);}  //SATTCreation
                   if(doc.keywords==sec.SA_TTEscalation__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];keyMapSATTEscalation.put(key,doc);listSATTEscalation.add(key);}  //SATTEscalation                                 
if(doc.keywords==sec.BL_Disputes__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){String key1 = parts[parts.size()-2];if(key1=='C'){String key2 =doc.DeveloperName.substringBeforeLast('_'); String key3 =key2.substringBefore('_');keyMapBLDisputes.put(Integer.ValueOf(key),mainFolderKeyMap.get(key3));}
                   else{keyMapBLDisputes.put(Integer.ValueOf(key),doc);}listBLDisputes.add(Integer.ValueOf(key));} }  //BL_Disputes 
if(doc.keywords==sec.B_TaxesExemptions__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){String key1 = parts[parts.size()-2];if(key1=='C'){String key2 =doc.DeveloperName.substringBeforeLast('_'); String key3 =key2.substringBefore('_');keyMapBTaxesExemptions.put(Integer.ValueOf(key),mainFolderKeyMap.get(key3));}
                   else{keyMapBTaxesExemptions.put(Integer.ValueOf(key),doc);}listBTaxesExemptions.add(Integer.ValueOf(key));} }  //B_TaxesExemptions 
if(doc.keywords==sec.BGeneralQ__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){String key1 = parts[parts.size()-2];if(key1=='C'){String key2 =doc.DeveloperName.substringBeforeLast('_'); String key3 =key2.substringBefore('_');keyMapBGeneralQ.put(Integer.ValueOf(key),mainFolderKeyMap.get(key3));}
                   else{keyMapBGeneralQ.put(Integer.ValueOf(key),doc);}listBGeneralQ.add(Integer.ValueOf(key));} }  //BGeneralQ 
                } // END OF FOR LOOP                          
            } // END OF IF         
           listSDEscalation.sort();for(String i :listSDEscalation) { DocMapSDEscalation.add(keyMapSDEscalation.get(i));}              
           listSDCancellation.sort();for(String i :listSDCancellation) { DocMapSDCancellation.add(keyMapSDCancellation.get(i));}   
           listSDOrderStatus.sort();for(String i :listSDOrderStatus) { DocMapSDOrderStatus.add(keyMapSDOrderStatus.get(i));}   
           listSDTTU.sort();for(String i :listSDTTU) { DocMapSDTTU.add(keyMapSDTTU.get(i));}   
           listSDRDSAssistance.sort();for(String i :listSDRDSAssistance) { DocMapSDRDSAssistance.add(keyMapSDRDSAssistance.get(i));}
           listSDMacd.sort();for(String i :listSDMacd) { DocMapSDMacd.add(keyMapSDMacd.get(i));}
           listSATTCreation.sort();for(String i :listSATTCreation) { DocMapSATTCreation.add(keyMapSATTCreation.get(i));} 
           listSATTEscalation.sort();for(String i :listSATTEscalation) { DocMapSATTEscalation.add(keyMapSATTEscalation.get(i));}              
           listBLDisputes.sort();for(Integer i :listBLDisputes) {DocMapBLDisputes.add(keyMapBLDisputes.get(i));} 
           listBGeneralQ.sort();for(Integer i :listBGeneralQ) {DocMapBGeneralQ.add(keyMapBGeneralQ.get(i));}
           listBTaxesExemptions.sort();for(Integer i :listBTaxesExemptions) {DocMapBTaxesExemptions.add(keyMapBTaxesExemptions.get(i));}
           listSDMobility.sort();for(String i :listSDMobility) { DocMapSDMobility.add(keyMapSDMobility.get(i));} 
        emailCAM = userContact[0].Account.Owner.email;
        }
       catch (Exception e) {
       String exceptionString = ATTException.constructExceptionMessageString(e);
       System.debug('Exception ---- ' + e);
       ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);                        
       }   
   }  
   public PageReference commentSubmit(){  
   PageReference pageRef;
   String caseNo = System.currentPageReference().getParameters().get('CaseNumber');   
            try{
               CaseComment cc = new CaseComment();
               case ca = [Select Id from case where casenumber=:caseNo];
               cc.ParentId = ca.id;
               cc.IsPublished = true;
               cc.CommentBody = spComment;
               insert cc; 
           }
           catch (Exception e) {
               String exceptionString = ATTException.constructExceptionMessageString(e);
               System.debug('Exception ---- ' + e);
               ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);                        
           }      
   pageRef=new PageReference('/apex/Support_Center_Case_Details?CaseNumber='+caseNo);   
   pageRef.setRedirect(true);              
   return pageRef;           
   } 
   public PageReference emailNotifyOn_TY(){  
   PageReference pageRef;
   String caseNo = System.currentPageReference().getParameters().get('caseId');   
           try{
               List<Case_Comment_Notification__c> cnObj= [select Please_notify_me__c,FollowingContact__c,Related_Case__c from 
                                            Case_Comment_Notification__c where Please_notify_me__c = True and 
                                            Related_Case__r.casenumber=:caseNo and
                                            FollowingContact__c=:userRecord.contactId];
               case cs=[select contact.name,contactId,Id from case where casenumber=:caseNo];                            
               if(cnObj.size()>0){
                   if(cnObj[0].Please_notify_me__c==true){
                       cnObj[0].Followed_Until__c =System.now();
                       cnObj[0].Please_notify_me__c = false;
                       update cnObj[0];
                       EmailCommentNotify = false;
                   } 
              } 
              else{
                       Case_Comment_Notification__c nwObj = new Case_Comment_Notification__c();
                       nwObj.name= cs.contact.name;
                       nwObj.FollowingContact__c = cs.contactId;
                       nwObj.Related_Case__c = cs.Id;           
                       nwObj.Following_From__c = System.now();
                       nwObj.Please_notify_me__c = true;
                       insert nwObj ;
                       EmailCommentNotify = true;
              }                          
           }    
           catch (Exception e) {
               String exceptionString = ATTException.constructExceptionMessageString(e);
               System.debug('Exception ---- ' + e);
               ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);                        
           }      
   pageRef=new PageReference('/apex/Support_Center_TY?caseId='+caseNo);  
   pageRef.setRedirect(true);              
   return pageRef;           
   }    
   public PageReference emailNotifyOn_SD(){  
   PageReference pageRef;
   String caseNo = System.currentPageReference().getParameters().get('CaseNumber');   
          try{
               User userRecord = [select contact.name,contactId from User where Id=:UserInfo.getUserId()];  
               List<Case_Comment_Notification__c> cnObj= [select Please_notify_me__c,FollowingContact__c,Related_Case__c from 
                                            Case_Comment_Notification__c where Please_notify_me__c = True and 
                                            Related_Case__r.casenumber=:caseNo and
                                            FollowingContact__c=:userRecord.contactId];
               case cs=[select contact.name,contactId,Id from case where casenumber=:caseNo];                                            
               if(cnObj.size()>0){
                   if(cnObj[0].Please_notify_me__c==true){
                       cnObj[0].Followed_Until__c =System.now();
                       cnObj[0].Please_notify_me__c = false;
                       update cnObj[0];
                       EmailCommentNotify = false;
                   } 
              } 
              else{
                       Case_Comment_Notification__c nwObj = new Case_Comment_Notification__c();
                       nwObj.name = userRecord.contact.name;
                       nwObj.FollowingContact__c =userRecord.contactId;
                       nwObj.Related_Case__c = cs.Id;           
                       nwObj.Following_From__c = System.now();
                       nwObj.Please_notify_me__c = true;
                       insert nwObj ;
                       EmailCommentNotify = true;
              }                          
           }  
           catch (Exception e) {
               String exceptionString = ATTException.constructExceptionMessageString(e);
               System.debug('Exception ---- ' + e);
               ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);                        
           }      
   pageRef=new PageReference('/apex/Support_Center_Case_Details?CaseNumber='+caseNo);  
   pageRef.setRedirect(true);              
   return pageRef;           
   } 
   public PageReference onSubmit(){  
   PageReference pageRef;
   try{
       Case caseToCreate  = new Case();
       Case caseRecord  = new Case();
       String caseNumber = 'N/A';       
       //Fetching the assignment rules on case
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        caseToCreate.setOptions(dmlOpts);
       if(userContact.size()>0) {   
           caseToCreate.contactId = userContact[0].Id;
           caseToCreate.SuppliedPhone = contactPhone;           
           caseToCreate.Topic__c = Topic;
           caseToCreate.Category__c = Category;
           if(Topic=='System Access Issue')  caseToCreate.SubCategory__c = subCategory;
           else  caseToCreate.SubCategory__c = Category;
           caseToCreate.Subject = Subject;
           caseToCreate.Origin = 'Support Center';
           caseToCreate.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get(Topic).getRecordTypeId();     
           if(Product!='none')caseToCreate.Product__c=Product;     
           // Service Delivery
           caseToCreate.Opportunity_ID__c=Opportunity_ID;   
           caseToCreate.Order_Number__c=Order_Number;             
           caseToCreate.Service_Address_City__c=Service_Address_City;              
           caseToCreate.Point_of_Contact_Name__c = Point_of_Contact_Name;
           caseToCreate.Point_of_Contact_Telephone_Number__c= Point_of_Contact_Telephone_Number;
           caseToCreate.Customer_Requested_Due_Date__c=Customer_Requested_Due_Date;                     
           caseToCreate.Authorized_Contact_Email_Address__c=Authorized_Contact_Email_Address;
           caseToCreate.Authorized_Contact_Name__c=Authorized_Contact_Name;
           caseToCreate.Authorized_Contact_Phone_Number__c=Authorized_Contact_Phone_Number;
           if(Service_Address_State!='none')caseToCreate.Service_Address_State__c=Service_Address_State;
           if(Reason!='none')caseToCreate.Reason__c = Reason;
           if(Reason_1!='none')caseToCreate.Reason__c = Reason_1;
           if(Service_Address_Country!='none')caseToCreate.Service_Address_Country__c=Service_Address_Country;
           if(Access_Type!='none')caseToCreate.Access_Type__c = Access_Type;
           if(Issue_Type!=null && Issue_Type!='none')caseToCreate.Issue_Type__c=Issue_Type;
           if(Issue_Type1!=null && Issue_Type1!='none')caseToCreate.Issue_Type__c=Issue_Type1;
           if(Issue_Type2!=null && Issue_Type2!='none')caseToCreate.Issue_Type__c=Issue_Type2;
           if(Issue_Type3!=null && Issue_Type3!='none')caseToCreate.Issue_Type__c=Issue_Type3;
           if(Issue_Type4!=null && Issue_Type4!='none')caseToCreate.Issue_Type__c=Issue_Type4;
           System.debug('***********************Issue_Type******'+Issue_Type);
           System.debug('***********************Issue_Type******'+Issue_Type1);
           System.debug('***********************Issue_Type******'+Issue_Type2);
           System.debug('***********************Issue_Type******'+Issue_Type3);
           System.debug('***********************Issue_Type******'+Issue_Type4);
           if(Service_Address_Country_Other!='none')caseToCreate.Service_Address_Country_Other__c=Service_Address_Country_Other;
           if(Access_Speed!='none')caseToCreate.Access_Speed__c = Access_Speed;
           if(Access_Speed_1!='none')caseToCreate.Access_Speed__c = Access_Speed_1;           
           // Service Assurance           
           if(Asset_Type!='none')caseToCreate.Asset_Type__c=Asset_Type;
           caseToCreate.Asset_ID__c=Asset_ID;
           if(Intrusive_Test_Authorization!='none')caseToCreate.Intrusive_Test_Authorization__c=Intrusive_Test_Authorization;
           caseToCreate.Intrusive_Test_Window__c=Intrusive_Test_Window;
           caseToCreate.End_Customer_Company_Name__c=End_Customer_Company_Name;
           caseToCreate.End_Customer_Local_Contact_Phone_Number__c=End_Customer_Local_Contact_Phone_Number;
           caseToCreate.End_Customer_Local_Contact_Name__c=End_Customer_Local_Contact_Name;
           caseToCreate.End_Customer_Site_Access_Hours_M_F__c=End_Customer_Site_Access_Hours_M_F;
           caseToCreate.End_Customer_Site_Access_Hours_Sat_Sun__c=End_Customer_Site_Access_Hours_Sat_Sun;           
           if(SP_Technical_Contact_Name!=null && SP_Technical_Contact_Name!='')caseToCreate.SP_Technical_Contact_Name__c=SP_Technical_Contact_Name;
           if(SP_Technical_Contact_Phone!=null && SP_Technical_Contact_Phone!='')caseToCreate.SP_Technical_Contact_Phone__c=SP_Technical_Contact_Phone;
           if(SP_Technical_Contact_Email!=null &&SP_Technical_Contact_Email!='')caseToCreate.SP_Technical_Contact_Email__c=SP_Technical_Contact_Email;
           if(Alternate_SP_Technical_Contact_Name!=null && Alternate_SP_Technical_Contact_Name!='')caseToCreate.Alternate_SP_Technical_Contact_Name__c=Alternate_SP_Technical_Contact_Name;
           if(Alternate_SP_Technical_Contact_Phone!=null && Alternate_SP_Technical_Contact_Phone!='')caseToCreate.Alternate_SP_Technical_Contact_Phone__c=Alternate_SP_Technical_Contact_Phone;
           if(Alternate_SP_Technical_Contact_Email!=null && Alternate_SP_Technical_Contact_Email!='')caseToCreate.Alternate_SP_Technical_Contact_Email__c=Alternate_SP_Technical_Contact_Email;
           if(SP_Internal_Ticket_Number!=null && SP_Internal_Ticket_Number!='')caseToCreate.SP_Internal_Ticket_Number__c=SP_Internal_Ticket_Number;
           if(SP_Technical_Contact_Name_1!=null && SP_Technical_Contact_Name_1!='')caseToCreate.SP_Technical_Contact_Name__c=SP_Technical_Contact_Name_1;
           if(SP_Technical_Contact_Phone_1!=null && SP_Technical_Contact_Phone_1!='')caseToCreate.SP_Technical_Contact_Phone__c=SP_Technical_Contact_Phone_1;
           if(SP_Technical_Contact_Email_1!=null && SP_Technical_Contact_Email_1!='')caseToCreate.SP_Technical_Contact_Email__c=SP_Technical_Contact_Email_1;
           if(Alternate_SP_Technical_Contact_Name_1!=null && Alternate_SP_Technical_Contact_Name_1!='')caseToCreate.Alternate_SP_Technical_Contact_Name__c=Alternate_SP_Technical_Contact_Name_1;
           if(Alternate_SP_Technical_Contact_Phone_1!=null && Alternate_SP_Technical_Contact_Phone_1!='')caseToCreate.Alternate_SP_Technical_Contact_Phone__c=Alternate_SP_Technical_Contact_Phone_1;
           if(Alternate_SP_Technical_Contact_Email_1!=null && Alternate_SP_Technical_Contact_Email_1!='')caseToCreate.Alternate_SP_Technical_Contact_Email__c=Alternate_SP_Technical_Contact_Email_1;
           if(SP_Internal_Ticket_Number_1!=null && SP_Internal_Ticket_Number_1!='')caseToCreate.SP_Internal_Ticket_Number__c=SP_Internal_Ticket_Number_1;
           if(Mobility_Trouble_Type!='none')caseToCreate.Mobility_Trouble_Type__c=Mobility_Trouble_Type;           
           if(ATT_Trouble_Ticket_Number!=null && ATT_Trouble_Ticket_Number!='')caseToCreate.ATT_Trouble_Ticket_Number__c=ATT_Trouble_Ticket_Number;
           if(ATT_Trouble_Ticket_Number_1!=null && ATT_Trouble_Ticket_Number_1!='')caseToCreate.ATT_Trouble_Ticket_Number__c=ATT_Trouble_Ticket_Number_1;
           if(Information_Request_Subject!='none')caseToCreate.Information_Request_Subject__c=Information_Request_Subject;
           if(Information_Request_Subject_1!='none')caseToCreate.Information_Request_Subject__c=Information_Request_Subject_1;          
           caseToCreate.Service_Address_Street__c=Service_Address_Street;
           if(Physical_Address!=null && Physical_Address!='') caseToCreate.Service_Address_Street__c=Physical_Address;
           if(Physical_Address_1!=null && Physical_Address_1!='') caseToCreate.Service_Address_Street__c=Physical_Address_1;
           if(Physical_Address_2!=null && Physical_Address_2!='') caseToCreate.Service_Address_Street__c=Physical_Address_2;            
           caseToCreate.Description =Description;
           if(Trouble_Report!=null && Trouble_Report!='')caseToCreate.Description = Trouble_Report;      
           if(Trouble_Report_1!=null && Trouble_Report_1!='')caseToCreate.Description = Trouble_Report_1;
           if(Trouble_Report_2!=null && Trouble_Report_2!='')caseToCreate.Description = Trouble_Report_2;
           if(Trouble_Report_3!=null && Trouble_Report_3!='')caseToCreate.Description = Trouble_Report_3;           
           if(Trouble_Report_4!=null && Trouble_Report_4!='')caseToCreate.Description = Trouble_Report_4;                          
           caseToCreate.Phone_Number_CTN__c = Phone_Number_CTN;
           if(Phone_Number_CTN_1!=null && Phone_Number_CTN_1!='')caseToCreate.Phone_Number_CTN__c = Phone_Number_CTN_1;
           if(Phone_Number_CTN_2!=null && Phone_Number_CTN_2!='')caseToCreate.Phone_Number_CTN__c = Phone_Number_CTN_2;
           if(Phone_Number_CTN_3!=null && Phone_Number_CTN_3!='')caseToCreate.Phone_Number_CTN__c = Phone_Number_CTN_3;
           if(Phone_Number_CTN_4!=null && Phone_Number_CTN_4!='')caseToCreate.Phone_Number_CTN__c = Phone_Number_CTN_4;                      
           caseToCreate.IMEI__c = IMEI;
           if(IMEI_1!=null && IMEI_1!='')caseToCreate.IMEI__c = IMEI_1; 
           if(IMEI_2!=null && IMEI_2!='')caseToCreate.IMEI__c = IMEI_2; 
           if(IMEI_3!=null && IMEI_3!='')caseToCreate.IMEI__c = IMEI_3; 
           caseToCreate.SIM_Number__c=SIM_Number;
           if(SIM_Number_1!=null && SIM_Number_1!='')caseToCreate.SIM_Number__c=SIM_Number_1;
           if(SIM_Number_2!=null && SIM_Number_2!='')caseToCreate.SIM_Number__c=SIM_Number_2;
           if(SIM_Number_3!=null && SIM_Number_3!='')caseToCreate.SIM_Number__c=SIM_Number_3;           
           //Billing           
           if(Number_of_Invoices!='none')caseToCreate.Number_of_Invoices__c = Number_of_Invoices;
           if(Number_of_Invoices_1!='none')caseToCreate.Number_of_Invoices__c = Number_of_Invoices_1;           
           caseToCreate.Disputed_Amount__c= Disputed_Amount;
           if(Disputed_Amount_1!=null && Disputed_Amount_1!=0) caseToCreate.Disputed_Amount__c= Disputed_Amount_1;
           
           if(Product_Family!='none')caseToCreate.Product_Family__c = Product_Family;   
           caseToCreate.Account_Number__c=Account_Number;
           caseToCreate.Invoice_Dates__c=Invoice_Dates;             
           if(Number_of_Circuit_IDs!='none')caseToCreate.Number_of_Circuit_IDs__c=Number_of_Circuit_IDs;
           caseToCreate.Circuit_IDs__c=Circuit_IDs;           
            if(Number_of_Disputed_Telephone_Numbers!='none')caseToCreate.Number_of_Disputed_Telephone_Numbers__c=Number_of_Disputed_Telephone_Numbers;
           caseToCreate.Invoice_Number__c = Invoice_Number;
           caseToCreate.Type_of_fee_tax__c=Type_of_fee_tax;
           if(Resolution_Service_Line!='none')caseToCreate.Resolution_Service_Line__c=Resolution_Service_Line;
           caseToCreate.Reported_Username__c = Reported_Username;           
           caseToCreate.Billing_Account_Number_BAN__c=Billing_Account_Number_BAN;
           caseToCreate.Service_Address_Zip__c=Service_Address_Zip;  
           Boolean livetrafficID = (livetraffic=='Yes'?True:False);      
           caseToCreate.Is_there_live_traffic_on_this_circuit__c = livetrafficID ;
           insert caseToCreate;
       }
       if(caseToCreate.id!=null) 
       {
           caseRecord = [select id,contact.name,contactId,CaseNumber from Case where Id=:caseToCreate.id]; 
           caseNumber  = caseRecord.CaseNumber;   
           Case_Comment_Notification__c ccObj = new Case_Comment_Notification__c();
           ccObj.name = caseRecord.contact.name;
           ccObj.FollowingContact__c =caseRecord.contactId;
           ccObj.Related_Case__c = caseRecord.id;           
           ccObj.Following_From__c = System.now();
           ccObj.Please_notify_me__c = true;
           insert ccObj;
           
       }            
       
         
       pageRef=new PageReference('/apex/Support_Center_TY?caseId='+caseNumber);
       pageRef.setRedirect(true);                    
   }
   catch (Exception e) {
       String exceptionString = ATTException.constructExceptionMessageString(e);
       System.debug('Exception ---- ' + e);
       ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);                        
   } 
   return pageRef;           
   } 
}